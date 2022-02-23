unit uDCLNetUtils;
{$I DefineType.pas}

interface

uses
  SysUtils,
{$IFDEF MSWINDOWS}
  Windows, WinSock,
{$ENDIF}
{$IFDEF UNIX}
  cwstring, process, unix, sockets, linux, lclintf,
{$ENDIF}
{$IFDEF FPC}
  InterfaceBase, LCLType,
{$ENDIF}
  Classes;

function GetComputerName: string;
function GetUserFromSystem: string;
function GetLocalIP: string;
function GetMacAddress: string;

implementation

{$IFDEF MSWINDOWS}

const
  MAX_ADAPTER_NAME_LENGTH=256;
  MAX_ADAPTER_DESCRIPTION_LENGTH=128;
  MAX_ADAPTER_ADDRESS_LENGTH=8;
  IPHelper='iphlpapi.dll';

  // Типы адаптеров
  MIB_IF_TYPE_OTHER=1;
  MIB_IF_TYPE_ETHERNET=6; // <<<<
  MIB_IF_TYPE_TOKENRING=9;
  MIB_IF_TYPE_FDDI=15;
  MIB_IF_TYPE_PPP=23;
  MIB_IF_TYPE_LOOPBACK=24;
  MIB_IF_TYPE_SLIP=28;

type
  IP_ADDRESS_STRING=record
    S: array [0..15] of Char;
  end;

  IP_MASK_STRING=IP_ADDRESS_STRING;
  PIP_MASK_STRING=^IP_MASK_STRING;

  PIP_ADDR_STRING=^IP_ADDR_STRING;

  IP_ADDR_STRING=record
    Next: PIP_ADDR_STRING;
    IpAddress: IP_ADDRESS_STRING;
    IpMask: IP_MASK_STRING;
    Context: DWORD;
  end;

  time_t=Longint;

  PIP_ADAPTER_INFO=^IP_ADAPTER_INFO;

  IP_ADAPTER_INFO=record
    Next: PIP_ADAPTER_INFO;
    ComboIndex: DWORD;
    AdapterName: array [0..MAX_ADAPTER_NAME_LENGTH+3] of AnsiChar;
    Description: array [0..MAX_ADAPTER_DESCRIPTION_LENGTH+3] of AnsiChar;
    AddressLength: UINT;
    Address: array [0..MAX_ADAPTER_ADDRESS_LENGTH-1] of BYTE;
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

function GetAdaptersInfo(pAdapterInfo: PIP_ADAPTER_INFO; var pOutBufLen: ULONG): DWORD; stdcall;
  external IPHelper;
{$ENDIF}

function GetComputerName: string;
{$IFDEF MSWINDOWS}
var
  buffer: array [0..MAX_COMPUTERNAME_LENGTH+1] of Char;
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
end;

function GetUserFromSystem: string;
var
  UserName: string;
  UserNameLen: DWORD;
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
end;

{$IFDEF MSWINDOWS}

function GetLocalIP: string;
const
  WSVer=$101;
var
  wsaData: TWSAData;
  P: PHostEnt;
  Buf: array [0..127] of Char;
Begin
  Result:='127.0.0.1';
  If WSAStartup(WSVer, wsaData)=0 Then
  Begin
    If GetHostName(@Buf, 128)=0 Then
    Begin
      P:=GetHostByName(@Buf);
      If P<>Nil Then
        Result:=iNet_ntoa(PInAddr(P^.h_addr_list^)^);
    end;
    WSACleanup;
  end;
end;

{$ELSE}

function GetLocalIP: string;
var
  aProcess: TProcess;
  aStrings: TStringList;
  aString, aBuffer: string;
  i, p: Integer;
Begin
  Result:='00-00-00-00-00-00';
  aProcess:=TProcess.Create(Nil);
  aProcess.Commandline:='/sbin/ifconfig';
  aProcess.Options:=[poUsePipes, poNoConsole];
  aProcess.Execute;
  SetLength(aBuffer, 3000);
  repeat
    i:=aProcess.Output.Read(aBuffer[1], Length(aBuffer));
    aString:=aString+Copy(aBuffer, 1, i);
  until i=0;
  aProcess.Free;
  aStrings:=TStringList.Create;
  aStrings.Text:=aString;
  For i:=0 To aStrings.Count-1 Do
    If Not (Pos('inet addr:', aStrings[i])=0) Then
    Begin
      aString:=aStrings[i];
      Delete(aString, 1, Pos('inet addr:', aString)+9);
      p:=Pos(' ', aString);
      Result:=Copy(aString, 1, p);
      break;
    end;
  aStrings.Free;
end;
{$ENDIF}
{$IFDEF MSWINDOWS}

// -----------------------------------------------------------------------------
// Получаем список MAC-адресов сетевых карт (виртуальных и реальных)
// Используем правильный способ (не через BIOS)
// -----------------------------------------------------------------------------
function GetMACAddressOfNetwordDrives(var LstInfo: TStringList; var LstMAC: TStringList): boolean;
var
  TmpPointer, InterfaceInfo: PIP_ADAPTER_INFO;
  IP: PIP_ADDR_STRING;
  Len: ULONG;
  i: Integer;
  st: string;
Begin
  Result:=false;

  If GetAdaptersInfo(Nil, Len)=ERROR_BUFFER_OVERFLOW Then
  Begin
    GetMem(InterfaceInfo, Len);
    If GetAdaptersInfo(InterfaceInfo, Len)=ERROR_SUCCESS Then
    Begin
      TmpPointer:=InterfaceInfo;
      st:='';
      repeat
        If TmpPointer^.Type_=MIB_IF_TYPE_ETHERNET Then
        Begin
          Result:=True;
          For i:=0 To TmpPointer^.AddressLength-1 Do
          Begin
            st:=st+IntToHex(TmpPointer^.Address[i], 2);
            If i<TmpPointer^.AddressLength-1 Then
              st:=st+'-';
          end;
          If Assigned(LstInfo) Then
            LstInfo.Add(string(TmpPointer^.Description));
          // <-- в Description одни нули почему то, я ожидал "Сетевой адаптер Realtek RTL8187SE Wireless 802.11b/g 54 Мбит/с PCIE"
          If Assigned(LstMAC) Then
            LstMAC.Add(st); // <-- Здесь все верно - MAC-адрес
        end;

        TmpPointer:=TmpPointer.Next;
      until TmpPointer=Nil;
    end;
    FreeMem(InterfaceInfo);
  end;
end;

function GetMacAddress: string;
var
  LstMAC, LstInfo: TStringList;
Begin
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
  aString, aBuffer: string;
  i: Integer;
Begin
  Result:='00-00-00-00-00-00';
  aProcess:=TProcess.Create(Nil);
  aProcess.Commandline:='/sbin/ifconfig';
  aProcess.Options:=[poUsePipes, poNoConsole];
  aProcess.Execute;
  SetLength(aBuffer, 3000);
  repeat
    i:=aProcess.Output.Read(aBuffer[1], Length(aBuffer));
    aString:=aString+Copy(aBuffer, 1, i);
  until i=0;
  aProcess.Free;
  aStrings:=TStringList.Create;
  aStrings.Text:=aString;
  For i:=0 To aStrings.Count-1 Do
    If Not (Pos('HWaddr ', aStrings[i])=0) Then
    Begin
      aString:=aStrings[i];
      Delete(aString, 1, Pos('HWaddr ', aString)+6);
      Result:=aString;
      break;
    end;
  aStrings.Free;
end;
{$ENDIF}

end.
