unit fMainForm;
{$I DefineType.pas}

interface

uses
{$IFNDEF FPC}
{$IFDEF VCLFIX}
  VCLFixPack, ControlsAtomFix,
{$ENDIF}
{$ENDIF}
{$IFDEF MSWINDOWS}
  uNewFonts, Windows, Messages,
{$ENDIF}
  SysUtils, Classes, Controls, Forms, Dialogs,
{$IFDEF FPC}
  LCLType, LConvEncoding, LazUTF8,
{$ELSE}
  uGlass,
{$ENDIF}
  uDCLConst, uUDL, uDCLData, uStringParams, uDCLMultiLang;

type
  { TMainForm }

  TMainForm=class(TForm)
    procedure FormCreate(Sender: TObject);
  private
{$IFDEF MSWINDOWS}
    procedure WMSysCommand(var message: TWMSysCommand); message WM_SysCommand;
{$ENDIF}
  public

  end;

{$IFDEF MSWINDOWS}
Const
  AboutMenuItem=WM_USER+1;
  LockMenuItem=AboutMenuItem+1;
{$ENDIF}

implementation

{$R *.dfm}

{$IFDEF MSWINDOWS}
procedure TMainForm.WMSysCommand(var message: TWMSysCommand);
begin
  Case message.CmdType of
  AboutMenuItem:
    uUDL.DCLMainLogOn.About(nil);
  LockMenuItem:
    DCLMainLogOn.Lock;
  Else
    inherited;
  End;
end;
{$ENDIF}

function FindCommandStrParam(Str: String): String;
var
  i: Byte;
begin
  For i:=1 to ParamCount do
  begin
    if PosEx(Str, ParamStr(i))<>0 then
    begin
      Result:=Copy(ParamStr(i), Length(Str)+1, Length(ParamStr(i)));
      break;
    end;
  end;
end;

function FindFormCall: String;
begin
  Result:=FindCommandStrParam('Form=');
end;

function FindScryptFileCall: String;
begin
  Result:=FindCommandStrParam('ScryptFile=');
end;

function FindMainMenu: Boolean;
begin
  Result:=FindCommandStrParam('MainMenu=')='1';
end;

function FindMDI: Boolean;
begin
  Result:=FindCommandStrParam('MDI=')='1';
end;

function FindSetBaseUID: String;
begin
  Result:=FindCommandStrParam('INISection=');
end;

function FindBasesINI: String;
begin
  Result:=FindCommandStrParam('BasesINI=');
end;

{$IFnDEF FPC}
function UTF8ToWinCP(S: String): String;
begin
  Result:=S;
end;
{$ENDIF}

procedure TMainForm.FormCreate(Sender: TObject);
var
  MDI: Boolean;
  S, DialogName: String;
  T: TextFile;
begin
  PixelsPerInch:=96;
  Caption:='DCL Run v.'+uDCLConst.Version;
{$IFDEF MSWINDOWS}
  ParentFont:=True;
  AppendMenu(GetSystemMenu(Handle, False), MF_SEPARATOR, 0, '');
  AppendMenu(GetSystemMenu(Handle, False), MF_STRING, AboutMenuItem,
    Pchar(UTF8ToWinCP('DCL '+GetDCLMessageString(msVersion)+' : '+uDCLConst.Version)));
  AppendMenu(GetSystemMenu(Handle, False), MF_STRING, LockMenuItem, PChar(UTF8ToWinCP(GetDCLMessageString(msLock)+'...')));
{$ENDIF}

  If (FindSetBaseUID<>'') and (FindBasesINI<>'') then
  Begin
    uUDL.DCLMainLogOn.WriteBaseUIDtoINI(FindBasesINI, FindSetBaseUID);
  End;

  MDI:=False;
  if FileExists('interface.ini') then
  begin
    AssignFile(T, 'interface.ini');
    ReSet(T);
    While not EOF(T) do
    begin
      ReadLn(T, S);
      if PosEx('MDI', S)<>0 then
        MDI:=True;
    end;
    CloseFile(T);
  end;

  S:=FindScryptFileCall;
  If S<>'' then
    uUDL.DCLMainLogOn.RunSkriptFromFile(S);

  if MDI or FindMDI then
    Self.FormStyle:=fsMDIForm;
  DialogName:=FindFormCall;
  if DialogName='' then
    uUDL.DCLMainLogOn.CreateMenu(Self)
  Else
  begin
    if FindMainMenu then
      uUDL.DCLMainLogOn.CreateMenu(Self);

    uUDL.DCLMainLogOn.CreateForm(DialogName, nil, nil, nil, nil, False, chmNone);
  end;
end;

end.
