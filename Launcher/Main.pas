unit Main;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

interface

uses
{$IFDEF FPC}
  LCLIntf, LCLType, LConvEncoding,
{$ENDIF}
{$IFDEF MSWINDOWS}
  Windows,
{$ENDIF}
  SysUtils, Variants, Classes, Graphics, Controls, Forms,
  IniFiles, Add, uBaseesStorage,
  Dialogs, StdCtrls, ComCtrls, Buttons, ExtCtrls;

type
  { TForm1 }

  TForm1=class(TForm)
    ListBox1: TListBox;
    Panel1: TPanel;
    btRunApp: TBitBtn;
    btRunConstructor: TBitBtn;
    StatusBar1: TStatusBar;
    Panel3: TPanel;
    btAdd: TButton;
    btEdit: TButton;
    btDelete: TButton;
    procedure FormCreate(Sender: TObject);
    procedure ListBox1Click(Sender: TObject);
    procedure btRunAppClick(Sender: TObject);
    procedure btRunConstructorClick(Sender: TObject);
    procedure btDeleteClick(Sender: TObject);
    procedure btAddClick(Sender: TObject);
    procedure btEditClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure ListBox1DblClick(Sender: TObject);
  private
    IniLancher:TIniFile;
    DCLRunPath, DCLDeveloperPath, BasePath, IniCodePage: String;

    Procedure RefreshBaseList;
    Procedure RunApplication(ListNum:Integer);
    function SetBaseUID(Index:Integer):String;
  public
    BaseParams: TBaseParams;
  end;

implementation

{$R *.dfm}

{$IFDEF UNIX}
procedure ExecApp(const App: String);
Var
  aProcess: TProcess;
Begin
  Try
    aProcess:=TProcess.Create(nil);
    aProcess.Commandline:=App;
    aProcess.Execute;
    Result:=True;
    FreeAndNil(aProcess);
  Except
    Result:=False;
  end;
End;
{$ELSE}
procedure ExecApp(const App: String);
var
  SI: TStartupInfo;
  PI: TProcessInformation;
  CmdLine: String;
begin
  Assert(App <> '');

  CmdLine := App;
  UniqueString(CmdLine);

  FillChar(SI, SizeOf(SI), 0);
  FillChar(PI, SizeOf(PI), 0);
  SI.cb := SizeOf(SI);
  SI.dwFlags := STARTF_USESHOWWINDOW;
  SI.wShowWindow := SW_SHOWNORMAL;

  SetLastError(ERROR_INVALID_PARAMETER);
  {$WARN SYMBOL_PLATFORM OFF}
  Win32Check(CreateProcess(nil, PChar(CmdLine), nil, nil, False, CREATE_DEFAULT_ERROR_MODE {$IFDEF UNICODE}or CREATE_UNICODE_ENVIRONMENT{$ENDIF}, nil, nil, SI, PI));
  {$WARN SYMBOL_PLATFORM ON}
  CloseHandle(PI.hThread);
  CloseHandle(PI.hProcess);
end;
{$ENDIF}

Function PosEx(const SubStr, S: String): Cardinal;
Begin
  Result:=Pos(AnsiLowerCase(SubStr), AnsiLowerCase(S));
end;

Function InitCap(const S: String): String;
Begin
  If S<>'' then
    Result:=AnsiUpperCase(S[1])+Copy(S, 2, Length(S)-1)
  Else
    Result:='';
end;

function TForm1.SetBaseUID(Index:Integer):String;
begin
  If FileExists(DCLRunPath) and (Index<>-1) and (GetBaseUID(Path+'Bases.ini', BaseParams[Index].Title)='') then
    Result:=' BasesINI="'+Path+'Bases.ini" INISection="'+BaseParams[Index].Title+'"';
end;


procedure TForm1.FormCreate(Sender: TObject);
Begin
{$IFDEF FPC}
  DefaultSystemEncoding:=GetDefaultTextEncoding;
{$ELSE}
  DefaultSystemEncoding:='cp'+IntToStr(GetACP);
{$ENDIF}

  BasePath:=Application.ExeName;
  Path:=ExtractFilePath(BasePath);

  ReadIni(Path+'Bases.ini', BaseParams);
  RefreshBaseList;

  IniLancher:=TIniFile.Create('Launcher.ini');
  DCLRunPath:=IniLancher.ReadString('Applications', 'DCLRun', '');
  DCLDeveloperPath:=IniLancher.ReadString('Applications', 'DCLDeveloper', '');
  IniCodePage:=DefaultSystemEncoding;

  StatusBar1.Panels[0].Text:=GetBaseParam(0, BaseParams);
end;

procedure TForm1.ListBox1Click(Sender: TObject);
Begin
  BasePath:=GetBaseParam(ListBox1.ItemIndex, BaseParams);
  StatusBar1.Panels[0].Text:=BasePath;
end;

procedure TForm1.btRunAppClick(Sender: TObject);
var
  d: Integer;
Begin
  d:=ListBox1.ItemIndex;
  RunApplication(d);
  Self.Close;
end;

procedure TForm1.btRunConstructorClick(Sender: TObject);
Begin
  ExecApp(DCLDeveloperPath+' '+BasePath);
  Self.Close;
end;

procedure TForm1.btDeleteClick(Sender: TObject);
var
  d: Integer;
Begin
  d:=ListBox1.ItemIndex;

  If d<> - 1 then
    If MessageDlg('Удалить?', mtConfirmation, mbOKCancel, 0)=1 then
    Begin
      DeleteBase(Path+'Bases.ini', BaseParams[d].Title);

      ReadIni(Path+'Bases.ini', BaseParams);
      RefreshBaseList;
    end;
end;

procedure TForm1.btAddClick(Sender: TObject);
var
  F2:TfAddBase;
Begin
  F2:=TfAddBase.Create(Self);
  F2.Caption:='Добавление проекта...';
  F2.EditMode:=teaAdding;
  F2.ShowModal;
  F2.Release;

  ReadIni(Path+'Bases.ini', BaseParams);
  RefreshBaseList;
end;

procedure TForm1.btEditClick(Sender: TObject);
var
  F2:TfAddBase;
Begin
  If Length(BaseParams)>0 then
  Begin
    F2:=TfAddBase.Create(Self);
    F2.Caption:='Изменение проекта...';
    F2.EditMode:=teaEditing;
    F2.BaseName:=BaseParams[ListBox1.ItemIndex].Title;
    F2.ShowModal;
    F2.Release;

    ReadIni(Path+'Bases.ini', BaseParams);
    RefreshBaseList;
  end;
end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
Begin
  IniLancher.Free;
end;

procedure TForm1.ListBox1DblClick(Sender: TObject);
var
  d: Integer;
Begin
  d:=ListBox1.ItemIndex;
  RunApplication(d);
  Self.Close;
end;

procedure TForm1.RefreshBaseList;
var
  i:Integer;
begin
  ListBox1.Items.Clear;
  If Length(BaseParams)>0 then
    For i:=1 to Length(BaseParams) do
      ListBox1.Items.Append(BaseParams[i-1].Title);
  If ListBox1.Count>0 then
    ListBox1.ItemIndex:=0;
end;

procedure TForm1.RunApplication(ListNum: Integer);
Begin
  If ListNum<>-1 then
  Begin
    BasePath:=GetBaseParam(ListNum, BaseParams);
    If FileExists(DCLRunPath) then
      ExecApp(DCLRunPath+' '+BasePath+SetBaseUID(ListNum));
  End;
end;

end.
