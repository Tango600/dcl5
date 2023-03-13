unit uDCLSysUtils;
{$I DefineType.pas}

interface

uses
{$IFDEF MSWINDOWS}
  Windows,
{$ENDIF}
  SysUtils;

function GetUserFromSystem: string;

implementation

function GetUserFromSystem: string;
var
  UserName: string;
{$IFDEF MSWINDOWS}
  UserNameLen: DWORD;
Begin
  UserNameLen:=255;
  SetLength(UserName, UserNameLen);
  If Windows.GetUserName(PChar(UserName), UserNameLen) Then
    Result:=Copy(UserName, 1, UserNameLen-1)
  Else
    Result:='<Unk.>';
{$ENDIF}
{$IFDEF unix}
begin
  UserName:=GetEnvironmentVariable('HOME');
  Result:=Copy(UserName, 7, Length(UserName));
{$ENDIF}
end;

end.
