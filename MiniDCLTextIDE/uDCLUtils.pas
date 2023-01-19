unit uDCLUtils;

interface

uses
  SysUtils, Forms, ExtCtrls, StrUtils,
{$IFDEF MSWINDOWS}
  Windows, ShellApi,
{$ENDIF}
{$IFDEF UNIX}
  cwstring, process, unix, lclintf,
{$ENDIF}
{$IFDEF FPC}
  InterfaceBase, LCLType,
{$ENDIF}
  Dialogs,
  Controls, Classes, Graphics, DateUtils,
  uStringParams;


Function CompareString(S1, S2: String): Boolean;
Function CountSimb(S: String; C: Char): Integer;

Function IsUNCPath(Path: String): Boolean;
Function IsFullPath(Path: String): Boolean;
Function NoFileExt(const FileName:String):Boolean;

Function GetTempFileName(Ext: String): String;
Function UpTime: Cardinal;

Function FakeFileExt(Const FileName, Ext: String): String;
Function AddToFileName(Const FileName, AddStr: String): String;
{$IFDEF FPC}
Function Date: TDateTime;
Function Time: TDateTime;
{$ENDIF}

implementation

{$IFDEF FPC}
Function Date: TDateTime;
Begin
  Result:=Now;
End;

Function Time: TDateTime;
Begin
  Result:=Now;
End;
{$ENDIF}

Function CountSimb(S: String; C: Char): Integer;
Var
  L: Integer;
Begin
  Result:=0;
  For L:=1 To Length(S) Do
    If S[L]=C Then
      Inc(Result, 1);
End;

Function UpTime: Cardinal;
Begin
  Result:={$IFDEF MSWINDOWS}GetTickCount
{$ELSE}
    ((StrToInt(FormatDateTime('H', Time))*3600+StrToInt(FormatDateTime('N', Time))*60+
    StrToInt(FormatDateTime('S', Time)))*1000)+StrToInt(FormatDateTime('Z', Time));
{$ENDIF};
End;

Function GetTempFileName(Ext: String): String;
Begin
  If Ext<>'' then
  Begin
    If Ext[1]='.' then
      Delete(Ext, 1, 1);
    Result:='tmp'+IntToStr(UpTime)+'.'+Ext;
  End
  Else
    Result:='tmp'+IntToStr(UpTime);
End;

{$IFDEF MSWINDOWS}
Function KeyState(Key: Integer): Boolean;
Begin
{$R-}
  Result:=HiWord(GetKeyState(Key))<>0;
{$R+}
End;

{$ENDIF}

Function CompareString(S1, S2: String): Boolean;
Begin
  Result:=AnsiLowerCase(S1)=AnsiLowerCase(S2);
End;

function PosInSet(SimbolsSet, SourceStr: String): Cardinal;
Var
  i: Cardinal;
begin
  Result:=0;
  For i:=1 to Length(SourceStr) do
  Begin
    If PosEx(SourceStr[i], SimbolsSet)<>0 then
    Begin
      Result:=i;
      Break;
    End;
  End;
end;

Function NoFileExt(const FileName:String):Boolean;
var
  i, p, l, k:Integer;
begin
  p:=0;
  k:=0;
  i:=Length(FileName);
  l:=i-5;
  If i<=5 then
    l:=1;
  For i:=Length(FileName) downto l do
  Begin
    If FileName[i]='.' then
    Begin
      k:=p;
      Break;
    End;
    Inc(p);
  End;

  Result:=not (k>1);
end;

Function IsFullPath(Path: String): Boolean;
Begin
  If Length(Path)>1 then
    Result:=((Pos(':\', Path)=2)or(Path[1]='/')or(Path[1]='~')) and (LastDelimiter('/\', Path)<>0)
  Else
    Result:=False;
End;

Function IsUNCPath(Path: String): Boolean;
Begin
  Result:=Pos('\\', Path)=1;
End;

Function FakeFileExt(Const FileName, Ext: String): String;
Begin
  Result:=ChangeFileExt(FileName, '.'+Ext);
End;

Function AddToFileName(Const FileName, AddStr: String): String;
Var
  tmpS, P, Ext: String;
Begin
  tmpS:=ExtractFileName(ChangeFileExt(FileName, ''));
  P:=ExtractFilePath(FileName);
  Ext:=ExtractFileExt(FileName);
  Result:=P+tmpS+AddStr+Ext;
End;

end.
