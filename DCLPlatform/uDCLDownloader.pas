unit uDCLDownloader;
{$I DefineType.pas}

interface

uses
  SysUtils,
{$IFDEF MSWINDOWS}
  uNewFonts, WinInet,
{$ENDIF}
  Forms, Classes, Controls, ExtCtrls, ComCtrls, Dialogs, Buttons,
  uDCLMultiLang, uDCLTypes, uDCLConst;

Type
  TDownloader=class(TObject)
  private
    FStopDownLoadFlg, FDownLoadProcess: Boolean;

    Procedure StopDownLoad(Sender: TObject);
    Function InetGetFile(URL, FileName: String; ResetDownload, Progress, Cancel: Boolean): Boolean;
  public
    constructor Create;
    destructor Destroy; override;

    Procedure DownLoadHTTP(URL, FileName: String; ResetDownload, Progress, Cancel: Boolean);

    property DownLoadProcess:Boolean read FDownLoadProcess;
  End;

var
  DownLoadProcess:Boolean;

implementation


Procedure TDownloader.StopDownLoad(Sender: TObject);
Begin
  FStopDownLoadFlg:=True;
End;

{$IFDEF MSWINDOWS}
Function TDownloader.InetGetFile(URL, FileName: String; ResetDownload, Progress, Cancel: Boolean): Boolean;
Var
  hInet, hURL: HINTERNET;
  fSize, InetFileSize, ReadLen, RestartPos, ProgressPos, lpdwReser, RLen: Cardinal;
  fBuf: Array [1..1024*8] Of byte;
  f: File;
  Header: String;
  ProgressForm: TForm;
  ProgressBar: TProgressBar;
  BCancel: TDialogButton;
  // ProgressLabel:TDialogLabel;
Begin
  RestartPos:=0;
  fSize:=0;
  ReadLen:=0;
  FStopDownLoadFlg:=False;

  If Progress Then
  Begin
    ProgressForm:=TForm.Create(Nil);
    ProgressForm.Caption:=GetDCLMessageString(msLoading)+'...';
    ProgressForm.Position:=poScreenCenter;
    ProgressForm.ClientWidth:=255;
    ProgressForm.ClientHeight:=110;
    ProgressForm.BorderIcons:=[biSystemMenu];
    ProgressForm.FormStyle:=fsStayOnTop;
    ProgressForm.BorderStyle:=bsSingle;
    ProgressBar:=TProgressBar.Create(ProgressForm);
    ProgressBar.Parent:=ProgressForm;
    ProgressBar.Top:=15;
    ProgressBar.Left:=10;
    ProgressBar.Width:=250-20;
    ProgressBar.Height:=18;
    ProgressBar.Min:=0;
    { ProgressLabel:=TDialogLabel.Create(ProgressForm);
      ProgressLabel.Parent:=ProgressForm;
      ProgressLabel.Top:=35;
      ProgressLabel.Left:=15;
      ProgressLabel.Caption:='0 %'; }

    If Cancel Then
    Begin
      BCancel:=TDialogButton.Create(ProgressForm);
      BCancel.Parent:=ProgressForm;
      BCancel.Caption:=GetDCLMessageString(msCancel);
      BCancel.Top:=32+15;
      BCancel.Left:=(250 Div 2)-(ButtonWidth Div 2);
      BCancel.Width:=ButtonWidth;
      BCancel.Height:=ButtonHeight;
      BCancel.OnClick:=StopDownLoad;
    End;
    ProgressForm.Show;
  End;

  If FileExists(FileName)And(Not ResetDownload) Then
  Begin
    AssignFile(f, FileName);
    Reset(f, 1);
    RestartPos:=System.FileSize(f);
    Seek(f, System.FileSize(f));
  End
  Else
  Begin
    AssignFile(f, FileName);
    ReWrite(f, 1);
  End;
  hInet:=InternetOpen('DCLRun', PRE_CONFIG_INTERNET_ACCESS, Nil, Nil, 0);
  Header:='Accept: */*'; // open URL
  hURL:=InternetOpenURL(hInet, PChar(URL), PChar(Header), StrLen(PChar(Header)), 0, 0);

  RLen:=4;
  lpdwReser:=0;
  HttpQueryInfoW(hURL, HTTP_QUERY_CONTENT_LENGTH Or HTTP_QUERY_FLAG_NUMBER, @InetFileSize, RLen,
    lpdwReser);
  If Progress Then
    ProgressBar.Max:=InetFileSize;

  If RestartPos>0 Then
    InternetSetFilePointer(hURL, RestartPos, Nil, 0, 0);
  InternetQueryDataAvailable(hURL, fSize, 0, 0);

  ProgressPos:=0;
  While (fSize<>0)Or(FStopDownLoadFlg) Do
  Begin
    InternetReadFile(hURL, @fBuf, SizeOf(fBuf), ReadLen);
    InternetQueryDataAvailable(hURL, fSize, 0, 0);
    BlockWrite(f, fBuf, ReadLen);
    Inc(ProgressPos, ReadLen);
    Application.ProcessMessages;
    FDownLoadProcess:=True;
    If Progress Then
    Begin
      ProgressBar.Position:=ProgressPos;
    End;
  End;

  ProgressPos:=System.FileSize(f);
  FDownLoadProcess:=False;
  InternetCloseHandle(hURL);
  InternetCloseHandle(hInet);
  CloseFile(f);

  If Progress Then
  Begin
    ProgressForm.Close;
    ProgressForm.Release;
  End;
  If InetFileSize<>ProgressPos Then
  Begin
    If FStopDownLoadFlg Then
      Result:=True
    Else
      Result:=False;
  End
  Else
    Result:=True;
End;

{$ELSE}

Function TDownloader.InetGetFile(URL, FileName: String; ResetDownload, Progress, Cancel: Boolean): Boolean;
Begin
  Result:=False;
End;
{$ENDIF}

constructor TDownloader.Create;
begin
  inherited Create;
end;

destructor TDownloader.Destroy;
begin
  inherited Destroy;
end;

procedure TDownloader.DownLoadHTTP(URL, FileName: String; ResetDownload, Progress, Cancel: Boolean);
Var
  ResetDownload2: Boolean;
Begin
  ResetDownload2:=ResetDownload;
  While Not InetGetFile(URL, FileName, ResetDownload2, Progress, Cancel) Do
  begin
    ResetDownload2:=False;
    Application.ProcessMessages;
  end;
End;

end.
