unit uLogging;

interface

uses
{$IFDEF FPC}
  LConvEncoding,
{$ENDIF}
  Classes, SysUtils
{$IFNDEF FPC}
  , Controls
{$ENDIF};

type
  TlogEventType=(etNone, etInformation, etWerring, etError);
  TLoggingState=(lsNew, lsResume);
  TLoggingTime=(ltNone, ltBegin, ltBeginEnd, ltAlways);

  TLogging=class(TObject)
  private
    FLoggingTime: TLoggingTime;
    FLogData: TStringList;
    FFirstLog, FActive: Boolean;
    FFileName: string;

    procedure SetActive(ActState:Boolean);
    procedure FlushLog;
  public
    constructor Create(FileName: string; Active:Boolean; State: TLoggingState=lsNew;
      WriteTime: TLoggingTime=ltNone);
    destructor Destroy; override;

    procedure WriteLog(S: string; EventType: TlogEventType=etNone);
    procedure WriteSeparator;
    procedure WriteDoubleSeparator;
    procedure ClearLog;

    property Active:Boolean read FActive write SetActive;
  end;

implementation

uses uDCLData, uDCLConst;

const
  TimeFormat='hh:mm:ss';
  SeparatorLine='--------------------------------------------------------------';
  DoubleSeparatorLine='==============================================================';
  WerringsSymbols: Array [TlogEventType] of String=('', ' ', '*', '!');

Function TimeToStr_(Time: TDate): String;
Begin
  DateTimeToString(Result, TimeFormat, Time);
End;

function InsertIntoString(const InsStr: string; Tail: Byte): string;
var
  l, l1, i: Word;
begin
  l1:=0;
  l:=Length(InsStr);
  If l<Tail then
    l1:=Tail-l;
  If l>Tail then
    l:=Tail;

  Result:=Copy(InsStr, 1, l);
  If l1>1 then
    For i:=1 to l1 do
      Result:=Result+' ';
end;

{ TLogging }

procedure TLogging.ClearLog;
begin
  FLogData.Clear;
end;

constructor TLogging.Create(FileName: String; Active:Boolean; State: TLoggingState=lsNew;
  WriteTime: TLoggingTime=ltNone);
begin
  FLoggingTime:=WriteTime;
  FFirstLog:=False;
  FFileName:=FileName;
  FActive:=Active;

  If not DirectoryExists(ExtractFileDir(FFileName)) then
    FFileName:='Log.txt';

  FLogData:=TStringList.Create;
  If DefaultSystemEncoding=EncodingUTF8 Then
    FLogData.Append(UTF8BOM)
  Else If DefaultSystemEncoding='utf16' Then
    FLogData.Append(UTF16LEBOM);

  Case State of
  lsNew:Begin
    FLogData.Clear;
  End;
  lsResume:
  Begin
    If FileExists(FFileName) then
      FLogData.LoadFromFile(FFileName);
    FLogData.Append('==============================================');
  End;
  End;

  FLogData.Append('Default system encoding: '+DefaultSystemEncoding);
  Case WriteTime of
  ltBegin, ltBeginEnd:
  Begin
    FFirstLog:=True;
    WriteLog('');
  End;
  End;

  WriteLog('-=Начало журнала=-', etNone);
end;

destructor TLogging.Destroy;
begin
  Case FLoggingTime of
  ltBeginEnd:
  Begin
    FFirstLog:=True;
    WriteLog('');
  End;
  End;

  WriteLog('-=Окончание журнала=-', etNone);
end;

procedure TLogging.FlushLog;
begin
  If Assigned(FLogData) then
    FLogData.SaveToFile(FFileName);
end;

procedure TLogging.SetActive(ActState: Boolean);
begin
  FActive:=ActState;
  FlushLog;
end;

procedure TLogging.WriteLog(S: string; EventType: TlogEventType=etNone);
begin
  If EventType<>etNone then
    if (FLoggingTime=ltAlways) or FFirstLog then
      S:=TimeToStr_(Now)+' '+S;

  If EventType<>etNone then
    S:=InsertIntoString(WerringsSymbols[EventType], 2)+S;

  FLogData.Append(S);
  If FActive then
    FLogData.SaveToFile(FFileName);
  FFirstLog:=False;
end;

procedure TLogging.WriteSeparator;
begin
  WriteLog(SeparatorLine, etNone);
end;

procedure TLogging.WriteDoubleSeparator;
begin
  WriteLog(DoubleSeparatorLine, etNone);
end;

end.
