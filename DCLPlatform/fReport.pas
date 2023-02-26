unit fReport;
{$I DefineType.pas}

interface

uses
{$IFDEF MSWINDOWS} Windows, Messages, {$ENDIF} SysUtils, Classes,
  Controls, Forms, Dialogs, StdCtrls,
{$IFDEF FPC}
  LCLType, InterfaceBase, LazUTF8,
{$ENDIF}
  uDCLConst, uUDL, uDCLData, uDCLMultiLang, ExtCtrls;

type
  TMainForm = class(TForm)
    ButtonPrint: TButton;
    InDOSCodePage: TCheckBox;
    OpenDialog1: TOpenDialog;
    Timer1: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure ButtonPrintClick(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
    Rep: TStringList;
    OldMainWin:THandle;
    RaE:Boolean;

    procedure LoadReportFromFile(FileName:String; InConsoleCodePage:Boolean);
{$IFDEF MSWINDOWS}
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
{$ENDIF}

procedure TMainForm.ButtonPrintClick(Sender: TObject);
begin
  If OpenDialog1.Execute then
    LoadReportFromFile(OpenDialog1.FileName, InDOSCodePage.Checked);
end;

{$IFnDEF FPC}
function UTF8ToWinCP(S: String): String;
begin
  Result:=S;
end;
{$ENDIF}

procedure TMainForm.FormCreate(Sender: TObject);
var
  i:Byte;
  FileName:string;
  ReportCP:Boolean;
  Command:TDCLCommand;
  {$IFDEF MSWINDOWS}
  AppH:THandle;
  {$ENDIF}
begin
  Caption:='DCL Reports v.'+Version+' ('+DBEngineType+')';
{$IFDEF MSWINDOWS}
  AppH:={$IFDEF FPC}WidgetSet.AppHandle{$ELSE}Application.Handle{$ENDIF};
  AppendMenu(GetSystemMenu(Handle, False), MF_SEPARATOR, 0, '');
  AppendMenu(GetSystemMenu(Handle, False), MF_STRING, AboutMenuItem,
    Pchar(UTF8ToWinCP('DCL version : '+uDCLConst.Version)));
  AppendMenu(GetSystemMenu(Handle, False), MF_STRING, LockMenuItem, PChar(UTF8ToWinCP(GetDCLMessageString(msLock)+'...')));
{$ENDIF}

  Rep:=TStringList.Create;
  InDOSCodePage.Caption:=GetDCLMessageString(msCodePage)+' DOS';
  ButtonPrint.Caption:=GetDCLMessageString(msPrint);

  ReportCP:=False;
  RaE:=False;
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
      If CompareString(ParamStr(i), '-cc') then
      Begin
        ReportCP:=True;
      End;
      If CompareString(ParamStr(i), '-rae') then  // run and exit
        RaE:=True;
    End;
    If FileExists(FileName) then
      LoadReportFromFile(FileName, ReportCP);
  End;
  If RaE then
    Timer1.Enabled:=True;
end;

procedure TMainForm.LoadReportFromFile(FileName:String; InConsoleCodePage:Boolean);
var
  DCLTextReport:TDCLTextReport;
begin
  If FileExists(FileName) then
  Begin
    Rep.LoadFromFile(FileName);
    DCLTextReport:=TDCLTextReport.InitReport('', DCLMainLogOn, nil, Rep, 0, nqmNew);
    DCLTextReport.InConsoleCodePage:=InConsoleCodePage;
    DCLTextReport.OpenReport('Result.txt', rvmAllDS);
    DCLTextReport.CloseReport('Result.txt');
    FreeAndNil(DCLTextReport);
    ExecApp(GPT.Viewer+' Result.txt', '');
  End;
end;

procedure TMainForm.Timer1Timer(Sender: TObject);
begin
  If RaE then
    Self.Close;
end;

end.
