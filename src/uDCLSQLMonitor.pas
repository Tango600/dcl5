unit uDCLSQLMonitor;
{$I DefineType.pas}

interface

uses
{$IFDEF FPC}
  LConvEncoding,
{$ENDIF}
  Classes, DB, uDCLTypes, uDCLData, uDCLConst, uStringParams, SysUtils;

type
  RDSS=Record
    EventBeforeOpen: TDataSetNotifyEvent;
    DataSet: TDCLDialogQuery;
  End;

  TDCLSQLMon=class(TObject)
  private
    FSQLContaner: TStringList;
    FFileName: string;
    DSEvents: array of RDSS;
    FTrraceStatus: Boolean;

    procedure BeforeOpen(Data: TDataSet);
    procedure SetTrraceStatus(Status: Boolean);
  public
    constructor Create(FileName: string);
    destructor Destroy; override;

    procedure Stop;
    procedure Resume;
    procedure Clear;
    procedure AddSQLText(SQL: string);
    procedure AddTrace(DS: TDCLDialogQuery);
    procedure DelTrace(DS: TDCLDialogQuery);

    property TrraceStatus: Boolean read FTrraceStatus write SetTrraceStatus;
  end;

implementation

{ TDCLSQLMon }

procedure TDCLSQLMon.BeforeOpen(Data: TDataSet);
var
  i, j: Word;
begin
  For i:=1 to Length(DSEvents) do
  Begin
    If Assigned(DSEvents[i-1].DataSet) then
      If DSEvents[i-1].DataSet=Data then
      Begin
        AddSQLText(DSEvents[i-1].DataSet.SQL.Text);
        If not FTrraceStatus then
          If FSQLContaner.Count>12 then
            For j:=1 to 10 do
              FSQLContaner.Delete(1);

        If FTrraceStatus then
          FSQLContaner.SaveToFile(FFileName);
        If Assigned(DSEvents[i-1].EventBeforeOpen) then
          DSEvents[i-1].EventBeforeOpen(Data);
        Break;
      End;
  End;
end;

procedure TDCLSQLMon.Clear;
begin
  FSQLContaner.Clear;

  If DefaultSystemEncoding=EncodingUTF8 Then
    FSQLContaner.Append(UTF8BOM)
  Else If DefaultSystemEncoding='utf16' Then
    FSQLContaner.Append(UTF16LEBOM);
end;

constructor TDCLSQLMon.Create(FileName: string);
begin
  FSQLContaner:=TStringList.Create;
  Clear;
  FFileName:=FileName;
  FTrraceStatus:=False;
end;

procedure TDCLSQLMon.DelTrace(DS: TDCLDialogQuery);
var
  i: Word;
begin
  For i:=1 to Length(DSEvents) do
  Begin
    If Assigned(DSEvents[i-1].DataSet) then
      If DSEvents[i-1].DataSet=DS then
      Begin
        DSEvents[i-1].EventBeforeOpen:=nil;
        DSEvents[i-1].DataSet:=nil;
        Break;
      End;
  End;
end;

destructor TDCLSQLMon.Destroy;
var
  i:Integer;
begin
  If Length(DSEvents)>0 then
    For i:=1 to Length(DSEvents) do
    Begin
      DSEvents[i-1].EventBeforeOpen:=nil;
      DSEvents[i-1].DataSet:=nil;
    End;
  FSQLContaner.Free;
end;

procedure TDCLSQLMon.Resume;
begin
  FTrraceStatus:=True;
  FSQLContaner.SaveToFile(FFileName);
end;

procedure TDCLSQLMon.SetTrraceStatus(Status: Boolean);
begin
  FTrraceStatus:=Status;
  If Status then
    Resume
  Else
    Stop;
end;

procedure TDCLSQLMon.Stop;
begin
  FTrraceStatus:=False;
end;

procedure TDCLSQLMon.AddSQLText(SQL: string);
begin
  FSQLContaner.Append(TimeToStr(Now)+' '+TextToString(SQL)+';');
end;

procedure TDCLSQLMon.AddTrace(DS: TDCLDialogQuery);
var
  l, i: Word;
  FindIt: Boolean;
begin
  FindIt:=False;
  For i:=1 to Length(DSEvents) do
  Begin
    If Assigned(DSEvents[i-1].DataSet) then
      If DSEvents[i-1].DataSet=DS then
      Begin
        FindIt:=True;
        Break;
      End;
  End;
  If not FindIt then
  Begin
    l:=Length(DSEvents);
    SetLength(DSEvents, l+1);
    DSEvents[l].EventBeforeOpen:=DS.BeforeOpen;
    DSEvents[l].DataSet:=DS;

    DS.BeforeOpen:=BeforeOpen;
  End;
end;

end.
