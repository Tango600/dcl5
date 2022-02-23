unit uDCLQuery;
{$I DefineType.pas}

interface

uses
  SysUtils, Classes, uStringParams,
  Dialogs, StrUtils,
{$IFDEF ADO}
  WideStrings, ADODB, ADOConst, ADOInt,
{$ENDIF}
{$IFDEF IBX}
{$IFDEF NEWDELPHI}
  IBX.IBDatabase, IBX.IBTable, IBX.IBCustomDataSet, IBX.IBSQL, IBX.IBQuery,
  IBX.IBVisualConst, IBX.IBXConst, 
{$ELSE}
  IBDatabase, IBTable, IBCustomDataSet, IBSQL, IBQuery,
  IBVisualConst, IBXConst,
{$ENDIF}
  uIBUpdateSQLW,
{$ENDIF}
{$IFDEF SQLdbFamily}
  BufDataset, sqldb,
{$ENDIF}
{$IFDEF ZEOS}
  //ZConnection, ZDataset, ZSqlUpdate,
{$ENDIF}
  DB, uDCLTypes, uDCLData, uDCLConst;

const
  DisableControlsMode=False;
  FetchAllData=True;

type
  TTransactionType=(trtWrite, trtRead);
  TUpdateKind=(ukAll, ukKeys);
  TOperationsTypes=Array of TNotAllowedOperations;
  {$IFDEF UPDATESQLDB}
  TUpdateSQLObj=TUpdateObj;
  {$ELSE}
  TUpdateSQLObj=TDCLDialogQuery;
  {$ENDIF}

  { TDCLQuery }
  TDCLQuery=class(TDCLDialogQuery)
  private
{$IFDEF CACHEON}
    ShadowQuery: TDCLDialogQuery;
    {$IFDEF UPDATESQLDB}
    FUpdateSQL: TUpdateSQLObj;
    {$ELSE}
    FUpdateSQL: TDCLDialogQuery;
    {$ENDIF}
    FRefreshSQL:String;
    {$IFDEF TRANSACTIONDB}
    ShadowTransaction:TTransaction;
    {$ENDIF}
{$ENDIF}
    FMainTable, FKeyField: string;
    FAfterPost, FAfterCancel, FAfterOpen, FBeforePost, FBeforeInsert, FAfterDelete,
      FAfterInsert: TDataSetNotifyEvent;
    FNotAllowOperations: TOperationsTypes;
    FUpdateSQLDefined:Boolean;
    {$IFDEF ZEOS}
    FFieldsDefsDefined:Boolean;
    FieldsDefs:Array of TField;
    {$ENDIF}

    {$IFDEF TRANSACTIONDB}
    function CreateTR(RW:TTransactionType):TTransaction;
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

    Procedure SetNotAllowedOperations(Value: TOperationsTypes);
    Function GetNotAllowedOperations: TOperationsTypes;

    procedure SetSQL(const AValue: {$IFDEF WITH_WIDEDATASET}TWideStrings{$ELSE}TStringList{$ENDIF});
    function GetSQL: {$IFDEF WITH_WIDEDATASET}TWideStrings{$ELSE}TStringList{$ENDIF};

    Function FindNotAllowedOperation(Value: TNotAllowedOperations): Boolean;

  public
    constructor Create(DatabaseObj: TDBLogOn);
    destructor Destroy; override;

    procedure Open;
    procedure Append;
    procedure Insert;
    procedure Edit;
    procedure Delete;
    procedure SetUpdateSQL(TableName, KeyField: String);
    procedure ExecSQL;

    procedure SaveDB;
    procedure CancelDB;
    procedure DisableControls;
    procedure EnableControls;

    property NotAllowOperations: TOperationsTypes read GetNotAllowedOperations write SetNotAllowedOperations;
    property KeyField: String read FKeyField;
    property MainTable: String read FMainTable;
  published
    property SQL:{$IFDEF WITH_WIDEDATASET}TWideStrings{$ELSE}TStringList{$ENDIF} read GetSQL write SetSQL;
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
{$IFDEF ZEOS}
var
  i, j:Integer;
  LocalAfterOpen:TDataSetNotifyEvent;
{$ENDIF}
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
        TFloatField(FieldsDefs[j]).DisplayFormat:='#.#####0.00000';
        Inc(j);
      End;
      ftCurrency:Begin
        FieldsDefs[j]:=TCurrencyField.Create(Self);
        FieldsDefs[j].FieldName:=Fields[i-1].FieldName;
        TFloatField(FieldsDefs[j]).DisplayFormat:='#.##0.00';
        Inc(j);
      End;
      ftBCD, ftFMTBcd:Begin
        FieldsDefs[j]:=TNumericField.Create(Self);
        FieldsDefs[j].FieldName:=Fields[i-1].FieldName;
        TNumericField(FieldsDefs[j]).DisplayFormat:='#.#####0.00000';
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
    AfterOpen:=LocalAfterOpen;
  end;
{$ENDIF}
  If FetchAllData then
  begin
    inherited DisableControls;
    Last;
    First;
    inherited EnableControls;
  end;

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
{$IFDEF CACHEDDB}
  If RowsAffected<>-1 then
    CancelUpdates;
{$ENDIF}
{$IFDEF ZEOS}
  If not Connection.AutoCommit then
    Connection.Rollback;
{$ENDIF}
end;

constructor TDCLQuery.Create(DatabaseObj: TDBLogOn);
begin
  inherited Create(nil);
  FUpdateSQLDefined:=False;
{$IFDEF ZEOS}
  FFieldsDefsDefined:=False;
  Connection:=DatabaseObj;
{$ENDIF}
{$IFDEF ADO}
  Connection:=DatabaseObj;
{$ENDIF}
{$IFDEF IBX}
  Database:=DatabaseObj;
  {$IFDEF FPC}
  AutoStartTransaction:=True;
  AutoCommit:=True;
  AutoTrim:=True;
  {$ENDIF}
{$ENDIF}
{$IFDEF SQLdbFamily}
  Database:=DatabaseObj;
{$ENDIF}
{$IFDEF TRANSACTIONDB}
{$IFDEF UPDATESQLDB}
  Transaction:=CreateTR(trtRead);
{$ELSE}
  Transaction:=CreateTR(trtWrite);
{$ENDIF}
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
{$IFDEF TRANSACTIONDB}
{$IFDEF UPDATESQLDB}
  ShadowTransaction:=CreateTR(trtWrite);
  ShadowQuery.Transaction:=ShadowTransaction;
{$ELSE}
  ShadowTransaction:=CreateTR(trtRead);
  ShadowQuery.Transaction:=Transaction;
{$ENDIF}
{$ENDIF}
{$IFDEF ZEOS}
  ShadowQuery.Connection:=DatabaseObj;
{$ENDIF}
{$IFDEF IBX}
  ShadowQuery.Database:=DatabaseObj;
  {$IFDEF FPC}
  ShadowQuery.AutoStartTransaction:=True;
  ShadowQuery.AutoCommit:=True;
  ShadowQuery.AutoTrim:=True;
  {$ENDIF}
{$ENDIF}
{$IFDEF SQLdbFamily}
  ShadowQuery.Database:=DatabaseObj;
{$ENDIF}
{$ENDIF}
end;

Procedure TDCLQuery.FillDatasetUpdateSQL(KeyField, TableName: String;
  ToOpen: Boolean);
var
  UpdatesFieldsSet, KeyFieldsSet: String;
  v1, v2: Integer;
  KeyFields, UpdateFields: Array of String;
  UpdateKind:TUpdateKind;
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

      {$IFDEF UPDATESQLDB}
      If not Assigned(FUpdateSQL) then
      Begin
        FUpdateSQL:=TUpdateSQLObj.Create(Self);
        {$IFDEF TRANSACTIONDB}
        FUpdateSQL.UpdateTransaction:=ShadowTransaction;
        {$ENDIF}
      End;
      UpdateObject:=FUpdateSQL;
      {$ELSE}
      FUpdateSQL:=Self;
      {$ENDIF}

      ShadowQuery.SQL.Text:='select * from '+TableName+' where 1=0';
      ShadowQuery.Open;

      If KeyField='' then
      Begin
        UpdateKind:=ukAll;
        SetLength(KeyFields, ShadowQuery.FieldCount);
        For v1:=1 to ShadowQuery.FieldCount do
          KeyFields[v1-1]:=LowerCase(ShadowQuery.Fields[v1-1].FieldName);
      End
      Else
      Begin
        v1:=ParamsCount(KeyField);
        UpdateKind:=ukKeys;
        If v1>1 then
        Begin
          SetLength(KeyFields, v1);
          For v2:=1 to v1 do
          Begin
            KeyFields[v2-1]:=LowerCase(SortParams(KeyField, v2));
          End;
        End
        Else
        Begin
          SetLength(KeyFields, 1);
          KeyFields[0]:=LowerCase(KeyField);
        end;
      End;

      SetLength(UpdateFields, ShadowQuery.FieldCount);
      For v1:=1 to ShadowQuery.FieldCount do
        UpdateFields[v1-1]:=LowerCase(ShadowQuery.Fields[v1-1].FieldName);

      ShadowQuery.Close;

      UpdatesFieldsSet:='';
      For v1:=1 to Length(UpdateFields) do
        If UpdateKind=ukKeys then
        Begin
          If not AnsiMatchStr(UpdateFields[v1-1], KeyFields) then
            UpdatesFieldsSet:=UpdatesFieldsSet+UpdateFields[v1-1]+'=:'+UpdateFields[v1-1]+',';
        End
        Else
          UpdatesFieldsSet:=UpdatesFieldsSet+UpdateFields[v1-1]+'=:'+UpdateFields[v1-1]+',';

      If UpdatesFieldsSet<>'' then
        System.Delete(UpdatesFieldsSet, Length(UpdatesFieldsSet), 1);

      KeyFieldsSet:='';
      For v1:=1 to Length(KeyFields) do
        KeyFieldsSet:=KeyFieldsSet+KeyFields[v1-1]+'=:OLD_'+KeyFields[v1-1]+' and ';
      If KeyFieldsSet<>'' then
        System.Delete(KeyFieldsSet, Length(KeyFieldsSet)-4, 4);

      If not FindNotAllowedOperation(dsoEdit) then
        FUpdateSQL.{$IFNDEF SQLdbFamily}ModifySQL{$ELSE}UpdateSQL{$ENDIF}.Text:='update '+TableName+' set '+UpdatesFieldsSet+' where '+
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

{$IFDEF REFRESHSQLDB}
      KeyFieldsSet:='';
      For v1:=1 To Length(KeyFields) Do
        KeyFieldsSet:=KeyFieldsSet+KeyFields[v1-1]+'=:'+KeyFields[v1-1]+' and ';
      If KeyFieldsSet<>'' then
        System.Delete(KeyFieldsSet, Length(KeyFieldsSet)-4, 5);

      UpdatesFieldsSet:='';
      For v1:=1 To Length(KeyFields) Do
        UpdatesFieldsSet:=UpdatesFieldsSet+':'+KeyFields[v1-1]+' is null and ';
      If UpdatesFieldsSet<>'' then
        System.Delete(UpdatesFieldsSet, Length(UpdatesFieldsSet)-4, 5);

      FRefreshSQL:='select * from '+TableName+' where '+KeyFieldsSet;
      FUpdateSQL.RefreshSQL.Text:=FRefreshSQL;
{$ENDIF}
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
{$IFDEF FREQUIREDDB}
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

Function TDCLQuery.FindNotAllowedOperation(Value: TNotAllowedOperations): Boolean;
Var
  l, i: Byte;
Begin
  l:=Length(FNotAllowOperations);
  Result:=False;
  If l>0 then
    For i:=1 to l do
    Begin
      If FNotAllowOperations[i-1]=Value then
      Begin
        Result:=True;
        Break;
      End;
    End;
end;

destructor TDCLQuery.Destroy;
begin
  FAfterDelete:=nil;
  FAfterPost:=nil;
  FAfterCancel:=nil;
  FAfterInsert:=nil;
  FAfterOpen:=nil;
  FBeforePost:=nil;
  FBeforeInsert:=nil;

  Cancel;
  Close;
{$IFDEF UPDATESQLDB}
{$IFDEF TRANSACTIONDB}
  If Assigned(ShadowTransaction) then
    FreeAndNil(ShadowTransaction);
{$ENDIF}
  FreeAndNil(FUpdateSQL);
{$ENDIF}
{$IFDEF CACHEON}
  FreeAndNil(ShadowQuery);
{$ENDIF}
  inherited Destroy;
end;

procedure TDCLQuery.DisableControls;
begin
  if DisableControlsMode then
    inherited DisableControls;
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

Function TDCLQuery.GetNotAllowedOperations: TOperationsTypes;
begin
  Result:=FNotAllowOperations;
end;

procedure TDCLQuery.SetSQL(const AValue: {$IFDEF WITH_WIDEDATASET}TWideStrings{$ELSE}TStringList{$ENDIF});
begin
  FUpdateSQLDefined:=False;
  inherited Close;
  inherited SQL.Assign(AValue);
end;

function TDCLQuery.GetSQL: {$IFDEF WITH_WIDEDATASET}TWideStrings{$ELSE}TStringList{$ENDIF};
begin
  Result:={$IFDEF WITH_WIDEDATASET}TWideStrings{$ELSE}TStringList{$ENDIF}(inherited SQL);
end;

{$IFDEF TRANSACTIONDB}
function TDCLQuery.CreateTR(RW:TTransactionType): TTransaction;
begin
  Result:=TTransaction.Create(Self);
  {$IFDEF IBX}
  Result.DefaultDatabase:=Database;
  Result.DefaultAction:=TACommit;
  {$ENDIF}
  {$IFDEF SQLdbFamily}
  Result.Database:=Database;
  Result.Action:=caCommit;
  {$ENDIF}
  Result.Params.Clear;
  Case RW of
  trtWrite:Begin
    Result.Params.Append('nowait');
  End;
  trtRead:Begin
    Result.Params.Append('read');
  End;
  End;
  Result.Params.Append('read_committed');
  If GPT.IBAll then
    Result.Params.Append('rec_version');
end;
{$ENDIF}

function TDCLQuery.GetPrimaryKeyField(TableName: string): string;
begin
  Result:='';
  If GPT.IBAll then
  Begin
{$IFDEF CACHEON}{$IFDEF IBALL}
    If TableName<>'' then
    Begin
      ShadowQuery.SQL.Text:='select RDB$FIELD_NAME '+
        'from RDB$RELATION_CONSTRAINTS C, RDB$INDICES I, RDB$INDEX_SEGMENTS S '+
        'where upper(C.RDB$RELATION_NAME) = upper(:TABLENAME) and '+
              'C.RDB$CONSTRAINT_TYPE = ''PRIMARY KEY'' and I.RDB$UNIQUE_FLAG = 1 and '+
              '((I.RDB$INDEX_INACTIVE = 0) or (I.RDB$INDEX_INACTIVE is null)) and '+
              'C.RDB$RELATION_NAME = I.RDB$RELATION_NAME and '+
              'I.RDB$INDEX_NAME = C.RDB$INDEX_NAME and '+
              'S.RDB$INDEX_NAME = I.RDB$INDEX_NAME '+
        'union '+
        'select RDB$FIELD_NAME '+
                'from RDB$RELATION_CONSTRAINTS C, RDB$INDICES I, RDB$INDEX_SEGMENTS S '+
                'where upper(C.RDB$RELATION_NAME) = upper(:TABLENAME) and '+
                      'C.RDB$CONSTRAINT_TYPE = ''UNIQUE'' and I.RDB$UNIQUE_FLAG = 1 and '+
                      '((I.RDB$INDEX_INACTIVE = 0) or (I.RDB$INDEX_INACTIVE is null)) and '+
                      'C.RDB$RELATION_NAME = I.RDB$RELATION_NAME and '+
                      'I.RDB$INDEX_NAME = C.RDB$INDEX_NAME and '+
                      'S.RDB$INDEX_NAME = I.RDB$INDEX_NAME and '+
                      'not exists(select * '+
                                       'from RDB$RELATION_CONSTRAINTS C1, RDB$INDICES I1 '+
                                       'where upper(C1.RDB$RELATION_NAME) = upper(:TABLENAME) and '+
                                             'C1.RDB$CONSTRAINT_TYPE = ''PRIMARY KEY'' and I1.RDB$UNIQUE_FLAG = 1 and '+
                                             '((I1.RDB$INDEX_INACTIVE = 0) or (I1.RDB$INDEX_INACTIVE is null)) and '+
                                             'C1.RDB$RELATION_NAME = I1.RDB$RELATION_NAME and '+
                                             'I1.RDB$INDEX_NAME = C1.RDB$INDEX_NAME)';

      ShadowQuery.ParamByName('TABLENAME').AsString:=TableName;
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
{$ENDIF}{$ENDIF}
  End;
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

procedure TDCLQuery.EnableControls;
begin
  if DisableControlsMode then
    inherited EnableControls;
end;

procedure TDCLQuery.ExecSQL;
begin
{$IFDEF UPDATESQLDB}
  If Assigned(ShadowQuery) then
  Begin
    ShadowQuery.SQL.Text:=SQL.Text;
    ShadowQuery.ExecSQL;
  End;
{$ELSE}
  inherited ExecSQL;
{$ENDIF}
end;

procedure TDCLQuery.Delete;
begin
  If not FindNotAllowedOperation(dsoDelete) then
    inherited Delete;
end;

procedure TDCLQuery.SaveDB;
begin
{$IFDEF CACHEDDB}
  If UpdatesPending then
    If CachedUpdates then
      ApplyUpdates;
{$IFDEF ZEOS}
  If Active then
    CommitUpdates;
  If not Connection.AutoCommit then
    Connection.Commit;
{$ENDIF}
{$ENDIF}
{$IFDEF UPDATESQLDB}
{$IFDEF TRANSACTIONDB}
  If Assigned(ShadowTransaction) then
{$IFDEF IBX}
  If ShadowTransaction.InTransaction then
{$ENDIF}
  If ShadowTransaction.Active then
    ShadowTransaction.Commit;
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

Procedure TDCLQuery.SetNotAllowedOperations(Value: TOperationsTypes);
begin
  FNotAllowOperations:=Value;
{$IFDEF CACHEON}
  If not FUpdateSQLDefined then
  Begin
    FMainTable:=GetMainQueryTable;
    FKeyField:=GetPrimaryKeyField(FMainTable);
  End;
  SetUpdateSQL(FKeyField, FMainTable);
//  FillDatasetUpdateSQL(FKeyField, FMainTable, True);

  If Assigned(FUpdateSQL) then
  Begin
    If FindNotAllowedOperation(dsoDelete) then
      FUpdateSQL.DeleteSQL.Clear;
    If FindNotAllowedOperation(dsoInsert) then
      FUpdateSQL.InsertSQL.Clear;
    If FindNotAllowedOperation(dsoEdit) then
      FUpdateSQL.{$IFNDEF SQLdbFamily}ModifySQL{$ELSE}UpdateSQL{$ENDIF}.Clear;
  End;
{$ENDIF}
end;

procedure TDCLQuery.SetRequiredFields;
Var
  v1: Word;
Begin
{$IFDEF FREQUIREDDB}
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
