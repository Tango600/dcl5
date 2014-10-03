unit uDCLQuery;
{$I DefineType.pas}

interface

uses
  SysUtils, Classes, uStringParams,
  Dialogs,
{$IFDEF ADO}
  WideStrings, ADODB, ADOConst, ADOInt,
{$ENDIF}
{$IFDEF BDE}
  BDE, DBClient, DBTables, Bdeconst,
{$ENDIF}
{$IFDEF IB}
  IBDatabase, IBTable, IBCustomDataSet, IBSQL, IBQuery,
  IBVisualConst, IBXConst,
{$ENDIF}
{$IFDEF ZEOS}
  // ZConnection, ZDataset, ZSqlUpdate,
{$ENDIF}
  DB, uDCLTypes, uDCLConst;

type
  TOperationsTypes=Array of TNotAllowedOperations;

  { TDCLQuery }

  TDCLQuery=class(TDCLDialogQuery)
  private
{$IFDEF CACHEON}
    ShadowQuery: TDCLDialogQuery;
    {$IFNDEF SQLdbIB}
    FUpdateSQL: UpdateObj;
    {$ELSE}
    FUpdateSQL: TDCLDialogQuery;
    {$ENDIF}
    FUpdSQL:String;
{$ENDIF}
    FNoRefreshSQL:Boolean;
    FMainTable, FKeyField: string;
    FAfterPost, FAfterCancel, FAfterOpen, FBeforePost, FBeforeInsert, FAfterDelete,
      FAfterInsert: TDataSetNotifyEvent;
    FNotAllowOperations: TOperationsTypes;
    FUpdateSQLDefined:Boolean;
    {$IFDEF ZEOS}
    FFieldsDefsDefined:Boolean;
    FieldsDefs:Array of TField;
    {$ENDIF}

    function GetPrimaryKeyField(TableName: string): string;
    function GetMainQueryTable: string;

    procedure SetRequiredFields;
    Procedure FillDatasetUpdateSQL(KeyField, TableName: String; ToOpen: Boolean);

    procedure AfterInsertData(Data: TDataSet);
    procedure AfterDeleteData(Data: TDataSet);
    procedure AfterPostData(Data: TDataSet);
    procedure AfterCancelData(Data: TDataSet);
    procedure AfterOpenData(Data: TDataSet);
    procedure BeforePostData(Data: TDataSet);
    procedure BeforeInsertData(Data: TDataSet);

    function GetAfterPostEvent: TDataSetNotifyEvent;
    procedure SetAfterPostEvent(Event: TDataSetNotifyEvent);
    function GetAfterCancelEvent: TDataSetNotifyEvent;
    procedure SetAfterCancelEvent(Event: TDataSetNotifyEvent);
    function GetAfterOpenEvent: TDataSetNotifyEvent;
    procedure SetAfterOpenEvent(Event: TDataSetNotifyEvent);
    function GetBeforePostEvent: TDataSetNotifyEvent;
    procedure SetBeforePostEvent(Event: TDataSetNotifyEvent);
    function GetBeforeInsertEvent: TDataSetNotifyEvent;
    procedure SetBeforeInsertEvent(Event: TDataSetNotifyEvent);
    function GetAfterDeleteEvent: TDataSetNotifyEvent;
    procedure SetAfterDeleteEvent(Event: TDataSetNotifyEvent);
    function GetAfterInsertEvent: TDataSetNotifyEvent;
    procedure SetAfterInsertEvent(Event: TDataSetNotifyEvent);

    procedure SaveDB;
    procedure CancelDB;

    Procedure SetOperations(Value: TOperationsTypes);
    Function GetOperations: TOperationsTypes;

    procedure SetSQL(const AValue: {$IFDEF ADO}TWideStrings{$ELSE}TStringList{$ENDIF});
    function GetSQL: {$IFDEF ADO}TWideStrings{$ELSE}TStringList{$ENDIF};

    Function FindNotAllowedOperation(Value: TNotAllowedOperations): Boolean;

    procedure SetNoRefreshSQL(Value:Boolean);
  public
    constructor Create(DatabaseObj: TDBLogOn);
    destructor Destroy; override;

    procedure Open;
    procedure Append;
    procedure Insert;
    procedure Edit;
    procedure Delete;
    procedure SetUpdateSQL(TableName, KeyField: String);

    property NotAllowOperations: TOperationsTypes read GetOperations write SetOperations;
    property KeyField: String read FKeyField;
    property MainTable: String read FMainTable;
    property NoRefreshSQL:Boolean read FNoRefreshSQL write SetNoRefreshSQL;
  published
    property SQL:{$IFDEF ADO}TWideStrings{$ELSE}TStringList{$ENDIF} read GetSQL write SetSQL;
    property AfterDelete: TDataSetNotifyEvent read GetAfterDeleteEvent write SetAfterDeleteEvent;
    property AfterPost: TDataSetNotifyEvent read GetAfterPostEvent write SetAfterPostEvent;
    property AfterCancel: TDataSetNotifyEvent read GetAfterCancelEvent write SetAfterCancelEvent;
    property AfterInsert: TDataSetNotifyEvent read GetAfterInsertEvent write SetAfterInsertEvent;
    property AfterOpen: TDataSetNotifyEvent read GetAfterOpenEvent write SetAfterOpenEvent;
    property BeforePost: TDataSetNotifyEvent read GetBeforePostEvent write SetBeforePostEvent;
    property BeforeInsert: TDataSetNotifyEvent read GetBeforeInsertEvent write SetBeforeInsertEvent;
    property UpdateSQLDefined:Boolean read FUpdateSQLDefined;
  end;

implementation

uses uDCLUtils;

{ TDCLQuery }

procedure TDCLQuery.AfterCancelData(Data: TDataSet);
begin
  If Assigned(FAfterCancel) then
    FAfterCancel(Data);
  CancelDB;
end;

procedure TDCLQuery.AfterDeleteData(Data: TDataSet);
begin
  SaveDB;
  If Assigned(FAfterDelete) then
    FAfterDelete(Data);
end;

procedure TDCLQuery.AfterInsertData(Data: TDataSet);
begin
  If Assigned(FAfterInsert) then
    FAfterInsert(Data);
end;

procedure TDCLQuery.AfterOpenData(Data: TDataSet);
var
  i, j:Integer;
  LocalAfterOpen:TDataSetNotifyEvent;
begin
{
    ftCursor,
    ftADT, ftReference,
    ftDataSet, ftOraClob, ftInterface,
    ftIDispatch, ftGuid
}

{$IFDEF ZEOS}
  If not FFieldsDefsDefined then
  Begin
    FFieldsDefsDefined:=True;
    FieldDefs.Clear;
    j:=Fields.Count;
    SetLength(FieldsDefs, j);
    j:=0;
    For i:=1 to Fields.Count do
    Begin
      Case Fields[i-1].DataType of
      ftSmallint, ftInteger, ftLargeint, ftWord, ftAutoInc:Begin
        FieldsDefs[j]:=TIntegerField.Create(Self);
        FieldsDefs[j].FieldName:=Fields[i-1].FieldName;
        Inc(j);
      end;
      ftFloat:Begin
        FieldsDefs[j]:=TFloatField.Create(Self);
        FieldsDefs[j].FieldName:=Fields[i-1].FieldName;
        TFloatField(FieldsDefs[j]).Precision:=5;
        TFloatField(FieldsDefs[j]).DisplayFormat:='#.#####';
        Inc(j);
      End;
      ftCurrency:Begin
        FieldsDefs[j]:=TCurrencyField.Create(Self);
        FieldsDefs[j].FieldName:=Fields[i-1].FieldName;
        TFloatField(FieldsDefs[j]).DisplayFormat:='#.##';
        Inc(j);
      End;
      ftBCD, ftFMTBcd:Begin
        FieldsDefs[j]:=TNumericField.Create(Self);
        FieldsDefs[j].FieldName:=Fields[i-1].FieldName;
        TNumericField(FieldsDefs[j]).DisplayFormat:='#.#####';
        Inc(j);
      End;
      ftString, ftFixedChar, ftVariant:Begin
        FieldsDefs[j]:=TStringField.Create(Self);
        FieldsDefs[j].Size:=Fields[i-1].Size;
        FieldsDefs[j].FieldName:=Fields[i-1].FieldName;
        Inc(j);
      End;
      ftFixedWideChar, ftWideString:Begin
        FieldsDefs[j]:=TWideStringField.Create(Self);
        FieldsDefs[j].Size:=Fields[i-1].Size;
        FieldsDefs[j].FieldName:=Fields[i-1].FieldName;
        Inc(j);
      End;
      ftDate:Begin
        FieldsDefs[j]:=TDateField.Create(Self);
        FieldsDefs[j].FieldName:=Fields[i-1].FieldName;
        Inc(j);
      End;
      ftTime:Begin
        FieldsDefs[j]:=TTimeField.Create(Self);
        FieldsDefs[j].FieldName:=Fields[i-1].FieldName;
        Inc(j);
      End;
      ftDateTime{$IFDEF FPC}, ftTimeStamp{$ENDIF}:Begin
        FieldsDefs[j]:=TDateTimeField.Create(Self);
        FieldsDefs[j].FieldName:=Fields[i-1].FieldName;
        Inc(j);
      End;
      {$IFNDEF FPC}
      ftTimeStamp:Begin
        FieldsDefs[j]:=TSQLTimeStampField.Create(Self);
        FieldsDefs[j].FieldName:=Fields[i-1].FieldName;
        Inc(j);
      End;
      {$ENDIF}
      ftBoolean:Begin
        FieldsDefs[j]:=TBooleanField.Create(Self);
        FieldsDefs[j].FieldName:=Fields[i-1].FieldName;
        Inc(j);
      End;
      ftBytes, ftOraBlob, ftVarBytes, ftBlob, ftMemo, ftGraphic, ftFmtMemo,
      ftParadoxOle, ftDBaseOle, ftTypedBinary, ftArray,
      ftWideMemo:Begin
        FieldsDefs[j]:=TBlobField.Create(Self);
        FieldsDefs[j].FieldName:=Fields[i-1].FieldName;
        Inc(j);
      End;
      End;
    End;

    inherited Close;
    LocalAfterOpen:=AfterOpen;
    AfterOpen:=nil;
    FieldDefs.Clear;
    Fields.Clear;
    For i:=1 to Length(FieldsDefs) do
    Begin
      If Assigned(FieldsDefs[i-1]) then
      Begin
        FieldsDefs[i-1].Required:=False;
        FieldsDefs[i-1].DataSet:=Self;
      end;
    End;
    FieldDefs.Update;
    inherited Open;
  end;
{$ENDIF}

  If Assigned(FAfterOpen) then
    FAfterOpen(Data);
  SetRequiredFields;
end;

procedure TDCLQuery.AfterPostData(Data: TDataSet);
begin
  SaveDB;
  If Assigned(FAfterPost) then
    FAfterPost(Data);
end;

procedure TDCLQuery.BeforeInsertData(Data: TDataSet);
begin
  if FindNotAllowedOperation(dsoInsert) then
    Cancel;
  If Assigned(FBeforeInsert) then
    FBeforeInsert(Data);
end;

procedure TDCLQuery.BeforePostData(Data: TDataSet);
begin
  If FindNotAllowedOperation(dsoEdit) then
    Cancel;
  If Assigned(FBeforePost) then
    FBeforePost(Data);
end;

procedure TDCLQuery.CancelDB;
begin
{$IFDEF CACHEON}
  CancelUpdates;
{$ENDIF}
end;

constructor TDCLQuery.Create(DatabaseObj: TDBLogOn);
begin
  inherited Create(nil);
  Name:='DCLQuery'+IntToStr(UpTime);
  FUpdateSQLDefined:=False;
{$IFDEF IBALL}
  FNoRefreshSQL:=False;
{$ENDIF}
{$IFDEF ZEOS}
  FFieldsDefsDefined:=False;
  Connection:=DatabaseObj;
{$ENDIF}
{$IFDEF BDE}
  Database:=DatabaseObj;
{$ENDIF}
{$IFDEF ADO}
  Connection:=DatabaseObj;
{$ENDIF}
{$IFDEF IB}
  Database:=DatabaseObj;
  Transaction:=Database.DefaultTransaction;
{$ENDIF}
  inherited AfterDelete:=AfterDeleteData;
  inherited AfterInsert:=AfterInsertData;
  inherited AfterPost:=AfterPostData;
  inherited AfterCancel:=AfterCancelData;
  inherited AfterOpen:=AfterOpenData;
  inherited BeforePost:=BeforePostData;
  inherited BeforeInsert:=BeforeInsertData;

{$IFDEF CACHEON}
  ShadowQuery:=TDCLDialogQuery.Create(nil);
{$IFDEF BDE}
  ShadowQuery.Database:=DatabaseObj;
{$ENDIF}
{$IFDEF ZEOS}
  ShadowQuery.Connection:=DatabaseObj;
{$ENDIF}
{$IFDEF IB}
  ShadowQuery.Database:=DatabaseObj;
  ShadowQuery.Transaction:=Database.DefaultTransaction;
{$ENDIF}
{$IFDEF SQLdbIB}
  ShadowQuery.Database:=DatabaseObj;
  ShadowQuery.Transaction:=DatabaseObj.Transaction;
{$ENDIF}
  ShadowQuery.Name:='ShadowQueryDCLQuery_'+IntToStr(UpTime);
{$ENDIF}
end;

procedure TDCLQuery.FillDatasetUpdateSQL(KeyField, TableName: String; ToOpen: Boolean);
var
  UpdatesFieldsSet, KeyFieldsSet: String;
  v1, v2: Integer;
  KeyFields, UpdateFields: Array of String;
Begin
  If TableName<>'' Then
  Begin
    FMainTable:=TableName;
{$IFDEF ADO}
    If ToOpen then
      If not Active Then
        If SQL.Text<>'' Then
          inherited Open;
    If Active Then
      Properties['Unique Table'].Value:=TableName;
{$ENDIF}
{$IFDEF CACHEON}
    If KeyField<>'' then
    Begin
      FUpdateSQLDefined:=True;
      FKeyField:=KeyField;
      If Active Then
        Close;

      {$IFNDEF SQLdbIB}
      FUpdateSQL:=UpdateObj.Create(Nil);
      FUpdateSQL.Name:='UpdateSQL_'+TableName;
      UpdateObject:=FUpdateSQL;
      CachedUpdates:=True;
      {$ELSE}
      FUpdateSQL:=Self;
      {$ENDIF}

      ShadowQuery.SQL.Text:='select * from '+TableName+' where 1=0';
      ShadowQuery.Open;

      If KeyField='' then
      Begin
        SetLength(KeyFields, ShadowQuery.FieldCount);
        For v1:=1 to ShadowQuery.FieldCount do
          KeyFields[v1-1]:=ShadowQuery.Fields[v1-1].FieldName;
      End
      Else
      Begin
        v1:=ParamsCount(KeyField);
        If v1>1 then
        Begin
          SetLength(KeyFields, v1);
          For v2:=1 to v1 do
          Begin
            KeyFields[v2-1]:=SortParams(KeyField, v2);
          End;
        End
        Else
        Begin
          SetLength(KeyFields, 1);
          KeyFields[0]:=KeyField;
        end;
      End;

      SetLength(UpdateFields, ShadowQuery.FieldCount);
      For v1:=1 to ShadowQuery.FieldCount do
        UpdateFields[v1-1]:=ShadowQuery.Fields[v1-1].FieldName;

      ShadowQuery.Close;

      UpdatesFieldsSet:='';
      For v1:=1 to Length(UpdateFields) do
        UpdatesFieldsSet:=UpdatesFieldsSet+UpdateFields[v1-1]+'=:'+UpdateFields[v1-1]+',';
      If UpdatesFieldsSet<>'' then
        System.Delete(UpdatesFieldsSet, Length(UpdatesFieldsSet), 1);

      KeyFieldsSet:='';
      For v1:=1 to Length(KeyFields) do
        KeyFieldsSet:=KeyFieldsSet+KeyFields[v1-1]+'=:OLD_'+KeyFields[v1-1]+' and ';
      If KeyFieldsSet<>'' then
        System.Delete(KeyFieldsSet, Length(KeyFieldsSet)-4, 4);

      If not FindNotAllowedOperation(dsoEdit) then
        FUpdateSQL.{$IFNDEF SQLdbIB}ModifySQL{$ELSE}UpdateSQL{$ENDIF}.Text:='update '+TableName+' set '+UpdatesFieldsSet+' where '+
          KeyFieldsSet;

      UpdatesFieldsSet:='';
      For v1:=1 To Length(UpdateFields) Do
        UpdatesFieldsSet:=UpdatesFieldsSet+UpdateFields[v1-1]+',';
      If UpdatesFieldsSet<>'' then
        System.Delete(UpdatesFieldsSet, Length(UpdatesFieldsSet), 1);

      KeyFieldsSet:='';
      For v1:=1 To Length(UpdateFields) Do
        KeyFieldsSet:=KeyFieldsSet+':'+UpdateFields[v1-1]+',';
      If KeyFieldsSet<>'' then
        System.Delete(KeyFieldsSet, Length(KeyFieldsSet), 1);

      If not FindNotAllowedOperation(dsoInsert) then
        FUpdateSQL.InsertSQL.Text:='insert into '+TableName+'('+UpdatesFieldsSet+') values('+
          KeyFieldsSet+')';

      KeyFieldsSet:='';
      For v1:=1 To Length(KeyFields) Do
        KeyFieldsSet:=KeyFieldsSet+KeyFields[v1-1]+'=:OLD_'+KeyFields[v1-1]+' and ';
      If KeyFieldsSet<>'' then
        System.Delete(KeyFieldsSet, Length(KeyFieldsSet)-4, 4);

      If not FindNotAllowedOperation(dsoDelete) then
        FUpdateSQL.DeleteSQL.Text:='delete from '+TableName+' where '+KeyFieldsSet;

{$IFDEF IBALL}
{$IFNDEF SQLdbIB}
      KeyFieldsSet:='';
      For v1:=1 To Length(KeyFields) Do
        KeyFieldsSet:=KeyFieldsSet+KeyFields[v1-1]+'=:'+KeyFields[v1-1]+',';
      If KeyFieldsSet<>'' then
        System.Delete(KeyFieldsSet, Length(KeyFieldsSet), 1);

      FUpdSQL:='select * from '+TableName+' where '+KeyFieldsSet;
      If not FNoRefreshSQL then
        FUpdateSQL.RefreshSQL.Text:=FUpdSQL;
{$ENDIF}{$ENDIF}
      // Query.FieldList.Update;
      If not Active Then
        If SQL.Text<>'' Then
          inherited Open;

      If Active then
        For v1:=1 to FieldCount do
          Fields[v1-1].Required:=False;
    End;
{$ENDIF}
  end;
{$IFDEF IBALL}
    If ToOpen then
      If not Active then
        If SQL.Text<>'' then
        Begin
          inherited Open;

          For v1:=1 to FieldCount do
            Fields[v1-1].Required:=False;
        End;
{$ENDIF}
  If ToOpen then
    If not Active Then
      If SQL.Text<>'' Then
        inherited Open;
End;

function TDCLQuery.FindNotAllowedOperation(Value: TNotAllowedOperations): Boolean;
Var
  l, i: Byte;
Begin
  l:=Length(FNotAllowOperations);
  Result:=False;
  If l>0 then
    For i:=0 to l-1 do
    Begin
      If FNotAllowOperations[i]=Value then
      Begin
        Result:=True;
        Break;
      End;
    End;
end;

procedure TDCLQuery.SetNoRefreshSQL(Value: Boolean);
begin
{$IFDEF IBALL}
  FNoRefreshSQL:=Value;
  If Assigned(FUpdateSQL) then
  Begin
    If Value then
      FUpdateSQL.RefreshSQL.Text:=''
    Else
      FUpdateSQL.RefreshSQL.Text:=FUpdSQL;
  End;
{$ENDIF}
end;

destructor TDCLQuery.Destroy;
begin
{$IFDEF CACHEON}
  FreeAndNil(FUpdateSQL);
{$ENDIF}
end;

function TDCLQuery.GetAfterCancelEvent: TDataSetNotifyEvent;
begin
  Result:=FAfterCancel;
end;

function TDCLQuery.GetAfterDeleteEvent: TDataSetNotifyEvent;
begin
  Result:=FAfterDelete;
end;

function TDCLQuery.GetAfterInsertEvent: TDataSetNotifyEvent;
begin
  Result:=FAfterInsert;
end;

function TDCLQuery.GetAfterOpenEvent: TDataSetNotifyEvent;
begin
  Result:=FAfterOpen;
end;

function TDCLQuery.GetAfterPostEvent: TDataSetNotifyEvent;
begin
  Result:=FAfterPost;
end;

function TDCLQuery.GetBeforeInsertEvent: TDataSetNotifyEvent;
begin
  Result:=FBeforeInsert;
end;

function TDCLQuery.GetBeforePostEvent: TDataSetNotifyEvent;
begin
  Result:=FBeforePost;
end;

function TDCLQuery.GetMainQueryTable: string;
var
  S, tmp1, Tables: String;
  v1, pos1: Integer;
  tmpSQL: TStringList;
begin
  Result:='';
  S:=SQL.Text;
  tmpSQL:=TStringList.Create;
  tmpSQL.Clear;
  for v1:=1 to ParamsCount(S, ', ', '"') do
  Begin
    tmp1:=LowerCase(SortParams(S, v1, ', ', '"'));
    If Trim(tmp1)<>'' then
      tmpSQL.Append(tmp1);
  End;

  pos1:=-1;
  for v1:=1 to tmpSQL.Count do
  Begin
    If tmpSQL[v1-1]='from' then
    begin
      pos1:=v1;
      Break;
    end;
  End;

  If pos1>0 then
  Begin
    Tables:=tmpSQL[pos1];
    if Pos('(', Tables)=Pos(')', Tables) then
      Result:=Tables;
  End;
end;

function TDCLQuery.GetOperations: TOperationsTypes;
begin
  Result:=FNotAllowOperations;
end;

procedure TDCLQuery.SetSQL(const AValue: {$IFDEF ADO}TWideStrings{$ELSE}TStringList{$ENDIF});
begin
  FUpdateSQLDefined:=False;
  inherited Close;
  inherited SQL.Assign(AValue);
end;

function TDCLQuery.GetSQL: {$IFDEF ADO}TWideStrings{$ELSE}TStringList{$ENDIF};
begin
  Result:={$IFDEF ADO}TWideStrings{$ELSE}TStringList{$ENDIF}(inherited SQL);
end;

function TDCLQuery.GetPrimaryKeyField(TableName: string): string;
begin
  Result:='';
{$IFDEF IBALL}
  If TableName<>'' then
  Begin
    ShadowQuery.SQL.Text:='select RDB$FIELD_NAME '+
      'from RDB$RELATION_CONSTRAINTS C, RDB$INDICES I, RDB$INDEX_SEGMENTS S '+
      'where UPPER(C.RDB$RELATION_NAME) = UPPER('''+TableName+''') and '+
      'C.RDB$CONSTRAINT_TYPE = ''PRIMARY KEY'' and I.RDB$UNIQUE_FLAG = 1 and '+
      '((I.RDB$INDEX_INACTIVE = 0) or (I.RDB$INDEX_INACTIVE is null)) and '+
      'C.RDB$RELATION_NAME = I.RDB$RELATION_NAME and I.RDB$INDEX_NAME = C.RDB$INDEX_NAME and '+
      'I.RDB$UNIQUE_FLAG = 1 and S.RDB$INDEX_NAME = I.RDB$INDEX_NAME';
    ShadowQuery.Open;
    while not ShadowQuery.Eof do
    Begin
      Result:=Result+Trim(ShadowQuery.Fields[0].AsString)+',';
      ShadowQuery.Next;
    End;
    ShadowQuery.Close;
    If Result<>'' then
      Result:=Copy(Result, 1, Length(Result)-1);
  End;
{$ENDIF}
end;

procedure TDCLQuery.Open;
begin
  Close;
  If not FUpdateSQLDefined then
  Begin
    FMainTable:=GetMainQueryTable;
    FKeyField:=GetPrimaryKeyField(FMainTable);
  End;
  FillDatasetUpdateSQL(FKeyField, FMainTable, True);
end;

procedure TDCLQuery.Append;
begin
  If not FindNotAllowedOperation(dsoInsert) then
     inherited Append;
end;

procedure TDCLQuery.Insert;
begin
  If not FindNotAllowedOperation(dsoInsert) then
     inherited Insert;
end;

procedure TDCLQuery.Edit;
begin
  If not FindNotAllowedOperation(dsoEdit) then
     inherited Edit;
end;

procedure TDCLQuery.Delete;
begin
  If not FindNotAllowedOperation(dsoDelete) then
     inherited Delete;
end;

procedure TDCLQuery.SaveDB;
begin
{$IFDEF CACHEON}
  ApplyUpdates;
{$IFDEF BDE}
  CommitUpdates;
{$ENDIF}
{$IFDEF ZEOS}
  CommitUpdates;
{$ENDIF}
{$ENDIF}
end;

procedure TDCLQuery.SetAfterCancelEvent(Event: TDataSetNotifyEvent);
begin
  If (@FAfterCancel<>@AfterCancel)or(@FAfterCancel=nil) then
    FAfterCancel:=Event;
end;

procedure TDCLQuery.SetAfterDeleteEvent(Event: TDataSetNotifyEvent);
begin
  If (@FAfterDelete<>@AfterDelete)or(@FAfterDelete=nil) then
    FAfterDelete:=Event;
end;

procedure TDCLQuery.SetAfterInsertEvent(Event: TDataSetNotifyEvent);
begin
  If (@FAfterInsert<>@AfterInsert)or(@FAfterInsert=nil) then
    FAfterInsert:=Event;
end;

procedure TDCLQuery.SetAfterOpenEvent(Event: TDataSetNotifyEvent);
begin
  If (@FAfterOpen<>@AfterOpen)or(@FAfterOpen=nil) then
    FAfterOpen:=Event;
end;

procedure TDCLQuery.SetAfterPostEvent(Event: TDataSetNotifyEvent);
begin
  If (@FAfterPost<>@AfterPost)or(@FAfterPost=nil) then
    FAfterPost:=Event;
end;

procedure TDCLQuery.SetBeforeInsertEvent(Event: TDataSetNotifyEvent);
begin
  If (@FBeforeInsert<>@BeforeInsert)or(@FBeforeInsert=nil) then
    FBeforeInsert:=Event;
end;

procedure TDCLQuery.SetBeforePostEvent(Event: TDataSetNotifyEvent);
begin
  If (@FBeforePost<>@BeforePost)or(@FBeforePost=nil) then
    FBeforePost:=Event;
end;

procedure TDCLQuery.SetOperations(Value: TOperationsTypes);
begin
  FNotAllowOperations:=Value;
end;

procedure TDCLQuery.SetRequiredFields;
Var
  v1: Word;
Begin
{$IFDEF BDE_or_IB}
  If Active then
    For v1:=1 to FieldCount do
      Fields[v1-1].Required:=False;
{$ENDIF}
end;

procedure TDCLQuery.SetUpdateSQL(TableName, KeyField: String);
begin
  If not FUpdateSQLDefined then
    FillDatasetUpdateSQL(KeyField, TableName, False);
end;

end.
