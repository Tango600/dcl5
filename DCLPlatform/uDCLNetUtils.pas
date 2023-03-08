unit uDCLNetUtils;
{$I DefineType.pas}

interface

uses
{$IFDEF MSWINDOWS}
  Windows;
{$ENDIF}
{$IFDEF UNIX}
  unix, sockets, lclintf;
{$ENDIF}

function GetUserFromSystem: string;

implementation

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

end.
