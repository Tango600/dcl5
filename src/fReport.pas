unit fReport;
{$I DefineType.pas}

interface

uses
{$IFDEF MSWINDOWS} Windows, Messages, {$ENDIF} SysUtils, Classes,
  Controls, Forms, Dialogs, StdCtrls,
{$IFDEF FPC}
  LCLType, InterfaceBase, EditBtn,
{$ELSE}
  uGlass,
{$ENDIF}
  uDCLConst, uUDL, uDCLData, uStringParams, uDCLStringsRes;

type
  TMainForm = class(TForm)
    ButtonPrint: TButton;
    InDOSCodePage: TCheckBox;
    OpenDialog1: TOpenDialog;
    procedure FormCreate(Sender: TObject);
    procedure ButtonPrintClick(Sender: TObject);
  private
    Rep: TStringList;
    OldMainWin:THandle;

    procedure LoadReportFromFile(FileName:String; ReportCP:TReportCodePage);
{$IFDEF MSWINDOWS}
{$IFNDEF NEWDELPHI}

    procedure CreateParams(var Params: TCreateParams); override;
{$ENDIF}
    procedure WMSysCommand(var message: TWMSysCommand); message WM_SysCommand;
{$ENDIF}
  public
    //
  end;

{$IFDEF MSWINDOWS}
Const
  AboutMenuItem=WM_USER+1;
  LockMenuItem=AboutMenuItem+1;
{$ENDIF}

implementation

uses
  uDCLUtils;

{$R *.dfm}

{$IFDEF MSWINDOWS}
procedure TMainForm.WMSysCommand(var message: TWMSysCommand);
var
  i: Word;
begin
  Case message.CmdType of
  AboutMenuItem:
  uUDL.DCLMainLogOn.About(nil);
  LockMenuItem:DCLMainLogOn.Lock;
  SC_MINIMIZE:
  begin
    ShowWindow(OldMainWin, SW_HIDE);
    for i:=Screen.FormCount-1 DownTo 0 do
      ShowWindow(Screen.Forms[i].Handle, SW_MINIMIZE);
    Message.Result:=0;
  end;
  SC_RESTORE:
  begin
    for i:=0 to Screen.FormCount-1 do
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

procedure TMainForm.ButtonPrintClick(Sender: TObject);
begin
  If OpenDialog1.Execute then
  Begin
    if InDOSCodePage.Checked then
      LoadReportFromFile(OpenDialog1.FileName, rcp866)
    Else
      LoadReportFromFile(OpenDialog1.FileName, rcp1251);
  End;
end;

procedure TMainForm.FormCreate(Sender: TObject);
var
  i:Byte;
  FileName:string;
  ReportCP:TReportCodePage;
  Command:TDCLCommand;
  AppH:THandle;
begin
  Caption:='DCL Reports v.'+Version+' ('+DBEngineType+')';
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
  AppendMenu(GetSystemMenu(Handle, False), MF_STRING, LockMenuItem, Pchar(GetDCLMessageString(msLock)+'...'));
{$ENDIF}
{$IFNDEF NEWDELPHI}
{$IFNDEF FPC}
  GlassForm(Self);
{$ENDIF}
{$IFNDEF NEWDELPHI}
  ShowWindow(OldMainWin, SW_HIDE);
{$ENDIF}
{$ENDIF}

  Rep:=TStringList.Create;
  InDOSCodePage.Caption:=SourceToInterface(GetDCLMessageString(msCodePage)+' DOS');
  ButtonPrint.Caption:=SourceToInterface(GetDCLMessageString(msPrint));

  If ParamCount>0 then
  Begin
    For i:=1 to ParamCount do
    Begin
      If CompareString(ParamStr(i), '-c') then
      Begin
        Command:=TDCLCommand.Create(nil, DCLMainLogOn);
        Command.ExecCommand(ParamStr(i+1), nil);
        FreeAndNil(Command);
      End;
      If CompareString(ParamStr(i), '-r') then
        If FileExists(ParamStr(i+1)) then
          FileName:=ParamStr(i+1);
      If CompareString(ParamStr(i), '-cp') then
      Begin
        If CompareString(ParamStr(i+1), '866') then
          ReportCP:=rcp866;
        If CompareString(ParamStr(i+1), '1251') then
          ReportCP:=rcp1251;
      End;
    End;
    If FileExists(FileName) then
      LoadReportFromFile(FileName, ReportCP);
  End;
end;

procedure TMainForm.LoadReportFromFile(FileName:String; ReportCP:TReportCodePage);
var
  DCLTextReport:TDCLTextReport;
begin
  If FileExists(FileName) then
  Begin
    Rep.LoadFromFile(FileName);
    DCLTextReport:=TDCLTextReport.InitReport(DCLMainLogOn, nil, Rep, 0, nqmNew);
    DCLTextReport.CodePage:=ReportCP;
    DCLTextReport.OpenReport('Result.txt', rvmAllDS);
    DCLTextReport.CloseReport('Result.txt');
    FreeAndNil(DCLTextReport);
    ExecApp(GPT.Viewer+' Result.txt');
  End;
end;

end.
