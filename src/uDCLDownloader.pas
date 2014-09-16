unit uDCLDownloader;
{$I DefineType.pas}

interface

uses
  SysUtils,
{$IFDEF MSWINDOWS}
  WinInet,
{$ENDIF}
  Forms, Classes, Graphics, Controls, ExtCtrls,
  ComCtrls, Dialogs, Buttons,
  uDCLTypes, uDCLConst;

Procedure DownLoadHTTP(URL, FileName: String; ResetDownload, Progress, Cancel: Boolean);

Var
  DownLoadProcess, DownLoadCancel, DownloadProgress: Boolean;

implementation

Type
  TDownloadProgressActions=class
    Procedure StopDownLoad(Sender: TObject);
  End;

var
  StopDownLoadFlg: Boolean;
  DownloadProgressActions: TDownloadProgressActions;

Procedure TDownloadProgressActions.StopDownLoad(Sender: TObject);
Begin
  StopDownLoadFlg:=True;
End;

{$IFDEF MSWINDOWS}

Function InetGetFile(URL, FileName: String; ResetDownload, Progress, Cancel: Boolean): Boolean;
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
  StopDownLoadFlg:=False;

  If Progress Then
  Begin
    ProgressForm:=TForm.Create(Nil);
    ProgressForm.Caption:='Загрузка....';
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
      BCancel.Caption:='Отменить';
      BCancel.Top:=32+15;
      BCancel.Left:=(250 Div 2)-(ButtonWidth Div 2);
      BCancel.Width:=ButtonWidth;
      BCancel.Height:=ButtonHeight;
      BCancel.OnClick:=DownloadProgressActions.StopDownLoad;
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
  Header:='Accept: */*'; // открываем URL
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
  While (fSize<>0)Or(StopDownLoadFlg) Do
  Begin
    InternetReadFile(hURL, @fBuf, SizeOf(fBuf), ReadLen);
    InternetQueryDataAvailable(hURL, fSize, 0, 0);
    BlockWrite(f, fBuf, ReadLen);
    Inc(ProgressPos, ReadLen);
    Application.ProcessMessages;
    DownLoadProcess:=True;
    If Progress Then
    Begin
      ProgressBar.Position:=ProgressPos;
    End;
  End;

  ProgressPos:=System.FileSize(f);
  DownLoadProcess:=False;
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
    If StopDownLoadFlg Then
      Result:=True
    Else
      Result:=False;
  End
  Else
    Result:=True;
End;

{$ELSE}

Function InetGetFile(URL, FileName: String; ResetDownload, Progress, Cancel: Boolean): Boolean;
Begin
  Result:=False;
End;
{$ENDIF}

Procedure DownLoadHTTP(URL, FileName: String; ResetDownload, Progress, Cancel: Boolean);
Var
  ResetDownload2: Boolean;
Begin
  ResetDownload2:=ResetDownload;
  While Not InetGetFile(URL, FileName, ResetDownload2, Progress, Cancel) Do
    ResetDownload2:=False;
End;

end.
