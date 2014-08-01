unit fMainForm;
{$I DefineType.pas}

interface

uses
{$IFDEF MSWINDOWS} Windows, Messages, {$ENDIF} SysUtils, Classes,
  Controls, Forms, Dialogs,
{$IFDEF FPC}
  LCLType, LConvEncoding, InterfaceBase,
{$ELSE}
  uGlass,
{$ENDIF}
  uDCLConst, uUDL, uDCLData, uStringParams, uDCLStringsRes;

type
  { TMainForm }

  TMainForm=class(TForm)
    procedure FormCreate(Sender: TObject);
  private
{$IFDEF MSWINDOWS}
{$IFNDEF NEWDELPHI}
    OldMainWin:THandle;

    procedure CreateParams(var Params: TCreateParams); override;
{$ENDIF}
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
var
  i: Word;
begin
  Case message.CmdType of
  AboutMenuItem:
  uUDL.DCLMainLogOn.About;
  LockMenuItem:DCLMainLogOn.Lock;
  SC_MINIMIZE:
  begin
    ShowWindow(OldMainWin, SW_HIDE);
    for i:=Screen.FormCount-1 DownTo 0 do
      If OldMainWin<>Screen.Forms[i].Handle then
        ShowWindow(Screen.Forms[i].Handle, SW_MINIMIZE)
      Else
        ShowWindow(Screen.Forms[i].Handle, SW_HIDE);
    Message.Result:=0;
  end;
  SC_RESTORE:
  begin
    for i:=0 to Screen.FormCount-1 do
      If OldMainWin<>Screen.Forms[i].Handle then
        ShowWindow(Screen.Forms[i].Handle, SW_RESTORE);
    Message.Result:=0;
  end;
Else
inherited;
  End;
end;

{$IFNDEF NEWDELPHI}
procedure TMainForm.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);

  Params.ExStyle:=Params.ExStyle and not WS_EX_TOOLWINDOW or WS_EX_APPWINDOW;
  Params.WndParent:={$IFDEF FPC}WidgetSet.AppHandle{$ELSE}Application.Handle{$ENDIF};
end;
{$ENDIF}
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

function FindMainMenu: Boolean;
begin
  Result:=FindCommandStrParam('MainMenu=')='1';
end;

function FindMDI: Boolean;
begin
  Result:=FindCommandStrParam('MDI=')='1';
end;

procedure TMainForm.FormCreate(Sender: TObject);
var
  MDI: Boolean;
  S, DialogName: String;
  T: TextFile;
  AppH:THandle;
begin
  Caption:='DCL Run v.'+uDCLConst.Version;
  AppH:={$IFDEF FPC}WidgetSet.AppHandle{$ELSE}Application.Handle{$ENDIF};
{$IFDEF MSWINDOWS}
{$IFNDEF NEWDELPHI}
  OldMainWin:=AppH;
  ShowWindow(AppH, SW_HIDE);
  SetWindowLong(AppH, GWL_EXSTYLE, GetWindowLong(AppH, GWL_EXSTYLE) and not WS_EX_APPWINDOW or WS_EX_TOOLWINDOW);
  ShowWindow(AppH, SW_SHOW);
{$ENDIF}
  AppendMenu(GetSystemMenu(Handle, False), MF_SEPARATOR, 0, '');
  AppendMenu(GetSystemMenu(Handle, False), MF_STRING, AboutMenuItem,
    Pchar('DCL version : '+uDCLConst.Version));
  AppendMenu(GetSystemMenu(Handle, False), MF_STRING, LockMenuItem, PChar(ConvertEncoding(GetDCLMessageString(msLock), DefaultSourceEncoding, DefaultSystemEncoding)+'...'));
{$ENDIF}

{$IFNDEF NEWDELPHI}
  ShowWindow(OldMainWin, SW_HIDE);
{$ENDIF}
  MDI:=False;
  if FileExists('interface.ini')=True then
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

  if MDI or FindMDI then
    Self.FormStyle:=fsMDIForm;
{$IFNDEF NEWDELPHI}
{$IFNDEF FPC}
{$IFDEF MSWINDOWS}
  GlassForm(Self);
{$ENDIF}
{$ENDIF}
{$ENDIF}
  DialogName:=FindFormCall;
  if DialogName='' then
    uUDL.DCLMainLogOn.CreateMenu(Self)
  Else
  begin
    if FindMainMenu then
      uUDL.DCLMainLogOn.CreateMenu(Self);

    uUDL.DCLMainLogOn.CreateForm(DialogName, nil, nil, nil, False, chmNone);
  end;
end;

end.
