unit uDCLNetUtils;
{$I DefineType.pas}

interface

uses
  SysUtils,
{$IFDEF MSWINDOWS}
  Windows, WinSock,
{$ENDIF}
{$IFDEF UNIX}
  cwstring, process, unix, libc, lclintf,
{$ENDIF}
{$IFDEF FPC}
  InterfaceBase, LCLType,
{$ENDIF}
  Classes;


function GetComputerName: string;
Function GetUserFromSystem: String;
Function GetLocalIP: String;
function GetMacAddress: string;


implementation

{$IFDEF MSWINDOWS}
const
 MAX_ADAPTER_NAME_LENGTH        = 256;
 MAX_ADAPTER_DESCRIPTION_LENGTH = 128;
 MAX_ADAPTER_ADDRESS_LENGTH     = 8;
 IPHelper = 'iphlpapi.dll';

 // Типы адаптеров
 MIB_IF_TYPE_OTHER     = 1;
 MIB_IF_TYPE_ETHERNET  = 6;   //<<<<
 MIB_IF_TYPE_TOKENRING = 9;
 MIB_IF_TYPE_FDDI      = 15;
 MIB_IF_TYPE_PPP       = 23;
 MIB_IF_TYPE_LOOPBACK  = 24;
 MIB_IF_TYPE_SLIP      = 28;

type
 IP_ADDRESS_STRING = record
   S: array [0..15] of Char;
 end;
 IP_MASK_STRING = IP_ADDRESS_STRING;
 PIP_MASK_STRING = ^IP_MASK_STRING;

 PIP_ADDR_STRING = ^IP_ADDR_STRING;
 IP_ADDR_STRING = record
   Next: PIP_ADDR_STRING;
   IpAddress: IP_ADDRESS_STRING;
   IpMask: IP_MASK_STRING;
   Context: DWORD;
 end;
 time_t = Longint;

 PIP_ADAPTER_INFO = ^IP_ADAPTER_INFO;
 IP_ADAPTER_INFO = record
   Next: PIP_ADAPTER_INFO;
   ComboIndex: DWORD;
   AdapterName:array [0..MAX_ADAPTER_NAME_LENGTH + 3] of AnsiChar;
   Description: array [0..MAX_ADAPTER_DESCRIPTION_LENGTH + 3] of AnsiChar;
   AddressLength: UINT;
   Address: array [0..MAX_ADAPTER_ADDRESS_LENGTH - 1] of BYTE;
   Index: DWORD;
   Type_: UINT;
   DhcpEnabled: UINT;
   CurrentIpAddress: PIP_ADDR_STRING;
   IpAddressList: IP_ADDR_STRING;
   GatewayList: IP_ADDR_STRING;
   DhcpServer: IP_ADDR_STRING;
   HaveWins: BOOL;
   PrimaryWinsServer: IP_ADDR_STRING;
   SecondaryWinsServer: IP_ADDR_STRING;
   LeaseObtained: time_t;
   LeaseExpires: time_t;
 end;

 function GetAdaptersInfo(pAdapterInfo: PIP_ADAPTER_INFO; var pOutBufLen: ULONG):DWORD; stdcall; external IPHelper;
{$ENDIF}


Function GetComputerName: String;
{$IFDEF MSWINDOWS}
Var
  buffer: Array [0..MAX_COMPUTERNAME_LENGTH+1] Of Char;
  Size: Cardinal;
{$ENDIF}
Begin
{$IFDEF MSWINDOWS}
  Size:=MAX_COMPUTERNAME_LENGTH+1;
  Windows.GetComputerName(@buffer, Size);
  Result:=StrPas(buffer);
{$ELSE}
  Result:=unix.GetHostName;
{$ENDIF}
End;

Function GetUserFromSystem: String;
Var
  UserName: String;
  UserNameLen: Dword;
Begin
{$IFDEF MSWINDOWS}
  UserNameLen:=255;
  SetLength(UserName, UserNameLen);
  If Windows.GetUserName(PChar(UserName), UserNameLen) Then
    Result:=Copy(UserName, 1, UserNameLen-1)
  Else
    Result:='<Unk.>';
{$ENDIF}
{$IFDEF UNIX}
  UserName:=GetEnvironmentVariable('HOME');
  Result:=Copy(UserName, 7, Length(UserName));
{$ENDIF}
End;

{$IFDEF MSWINDOWS}
Function GetLocalIP: String;
Const
  WSVer=$101;
Var
  wsaData: TWSAData;
  P: PHostEnt;
  Buf: Array [0..127] Of Char;
Begin
  Result:='127.0.0.1';
  If WSAStartup(WSVer, wsaData)=0 Then
  Begin
    If GetHostName(@Buf, 128)=0 Then
    Begin
      P:=GetHostByName(@Buf);
      If P<>Nil Then
        Result:=iNet_ntoa(PInAddr(P^.h_addr_list^)^);
    End;
    WSACleanup;
  End;
End;

{$ELSE}
Function GetLocalIP: String;
Var
  listDevInfo, listDev, ipList: TStringList;
  i: Integer;
  sfp: LongInt;
  req: TIfreq;
Begin
  Result:='127.0.0.1';
  listDevInfo:=TStringList.Create;
  listDev:=TStringList.Create;
  Try
    listDevInfo.LoadFromFile('/proc/net/dev');
    For i:=2 To listDevInfo.Count-1 Do
      If Trim(LeftStr(listDevInfo[i], Pos(':', listDevInfo[i])-1))<>'lo' Then
        listDev.Append(Trim(LeftStr(listDevInfo[i], Pos(':', listDevInfo[i])-1)));

    sfp:=socket(AF_INET, SOCK_DGRAM, 0);

    If sfp>-1 Then
    Begin
      ipList:=TStringList.Create;
      req.ifr_ifrn.ifrn_name:=PChar(listDev[0]);
      If ioctl(sfp, SIOCGIFADDR, @req)>-1 Then
        ipList.Append(iNet_ntoa(req.ifr_ifru.ifru_addr.sin_addr));
      If ipList.Count>0 Then
        Result:=ipList[0]
      Else
        Result:='127.0.0.1';
    End
    Else
      Result:='127.0.0.1';
  Finally
    FreeAndNil(listDevInfo);
    FreeAndNil(listDev);
  End;
End;
{$ENDIF}

{$IFDEF MSWINDOWS}
// -----------------------------------------------------------------------------
// Получаем список MAC-адресов сетевых карт (виртуальных и реальных)
// Используем правильный способ (не через BIOS)
// -----------------------------------------------------------------------------
function GetMACAddressOfNetwordDrives(var LstInfo:TStringList; var LstMAC:TStringList):boolean;
var
  TmpPointer, InterfaceInfo: PIP_ADAPTER_INFO;
  IP: PIP_ADDR_STRING;
  Len: ULONG;
  i:integer;
  st:string;
begin
  Result:=false;

  if GetAdaptersInfo(nil, Len) = ERROR_BUFFER_OVERFLOW then
  begin
    GetMem(InterfaceInfo, Len);
    if GetAdaptersInfo(InterfaceInfo, Len) = ERROR_SUCCESS then begin
      TmpPointer := InterfaceInfo;
      st:='';
      repeat
        If TmpPointer^.Type_=MIB_IF_TYPE_ETHERNET then
        begin
          Result:=True;
          for i:=0 to TmpPointer^.AddressLength-1 do
          begin
            st:=st+IntToHex(TmpPointer^.Address[i],2);
            if i<TmpPointer^.AddressLength-1 then st:=st+'-';
          end;
          If Assigned(LstInfo) then
            LstInfo.Add(string(TmpPointer^.Description));//  <-- в Description одни нули почему то, я ожидал "Сетевой адаптер Realtek RTL8187SE Wireless 802.11b/g 54 Мбит/с PCIE"
          If Assigned(LstMAC) then
            LstMAC.Add(st);// <-- Здесь все верно - MAC-адрес
        end;

        TmpPointer := TmpPointer.Next;
      until TmpPointer = nil;
    end;
    FreeMem(InterfaceInfo);
  end;
end;

function GetMacAddress:string;
var
  LstMAC, LstInfo:TStringList;
begin
  LstMAC:=TStringList.Create;
  LstInfo:=TStringList.Create;
  
  GetMACAddressOfNetwordDrives(LstInfo, LstMAC);
  Result:=LstMAC[0];
end;
{$ENDIF}
{$IFDEF UNIX}

function GetMacAddress: string;
var
  aProcess: TProcess;
  aStrings: TStringList;
  aString, aBuffer: String;
  i: Integer;
begin
  Result:='00-00-00-00-00-00';
  aProcess:=TProcess.Create(Nil);
  aProcess.Commandline:='/sbin/ifconfig';
  aProcess.Options:=[poUsePipes, poNoConsole];
  aProcess.Execute;
  SetLength(aBuffer, 3000);
  Repeat
    i:=aProcess.Output.Read(aBuffer[1], Length(aBuffer));
    aString:=aString+Copy(aBuffer, 1, i);
  Until i=0;
  aProcess.Free;
  aStrings:=TStringList.Create;
  aStrings.Text:=aString;
  For i:=0 To aStrings.Count-1 Do
    If Not(Pos('HWaddr ', aStrings[i])=0) Then
    Begin
      aString:=aStrings[i];
      Delete(aString, 1, Pos('HWaddr ', aString)+6);
      Result:=aString;
    End;
  aStrings.Free;
end;
{$ENDIF}



end.
