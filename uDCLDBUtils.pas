unit uDCLDBUtils;
{$I DefineType.pas}

interface

uses
  SysUtils, uDCLTypes, uDCLConst, uDCLData, uUDL,
{$IFDEF ADO}
  ADODB, ADOConst, ADOInt,
{$ENDIF}
  DB;

Function QueryIsEmpty(Query: TDCLDialogQuery): Boolean;
Function GetDelimiter(Const FieldName: String; Query: TDCLDialogQuery): String;
Function GetNameDSState(State: TDataSetState): String;
procedure RePlaseParams_(var Params: string; Query: TDCLDialogQuery);
Function FieldExists(Const FieldName: String; Query: TDCLDialogQuery; Table: string=''): Boolean;
Procedure FillDatasetUpdateSQL(var Query: TDCLDialogQuery;
  {$IFDEF BDE_or_IB}var UpdateSQL: UpdateObj;
  {$ENDIF} UpdatesFields: String; UserLevelLocal: TUserLevelsType; DCLGrid: TDCLGrid;
  Open: Boolean=False);
function GetFieldFromParam(Param: String; Query: TDCLDialogQuery): TField;
Function GetField(Table, Field, Where: string): TField;
Function ExecQuery(SQL: String): TDCLDialogQuery;
Function GetFieldValue(Table, Field, Where: string): string;

implementation

uses
  uStringParams, uDCLUtils;

Function QueryIsEmpty(Query: TDCLDialogQuery): Boolean;
Begin
  Result:=Query.Eof And Query.Bof;
End;

Function GetNameDSState(State: TDataSetState): String;
Const
  StatesCount=12;
  DataSetStateNames: Array [0..StatesCount] Of String=('Не активен', 'Просмотр', 'Редактирование',
    'Вставка', 'Установка ключа', 'Вычисляемые поля', 'Фильтрация', 'Новое значение',
    'Старое значение', 'Текущее значение', 'Блочное чтение', 'Внутренне вычисление', 'Открытие');
Begin
  Result:=DataSetStateNames[Ord(State)];
End;

Function GetDelimiter(Const FieldName: String; Query: TDCLDialogQuery): String;
var
  tmpFieldName: string;
Begin
  tmpFieldName:=FieldName;
  If Pos('.', FieldName)<>0 then
  begin
    tmpFieldName:=Copy(FieldName, Pos('.', FieldName)+1, Length(FieldName));
  end;
  Case Query.FieldByName(tmpFieldName).DataType Of
  ftString, ftBCD, ftFloat, ftCurrency:
  Begin
    Result:=GPT.StringTypeChar
  End;
  ftSmallint, ftInteger, ftWord, ftBoolean, ftAutoInc, ftLargeint, ftBytes, ftVarBytes:
  Begin
    Result:='';
  End
Else
Result:=GPT.StringTypeChar;
  End;
End;

Function FieldExists(Const FieldName: String; Query: TDCLDialogQuery; Table: string=''): Boolean;
Var
  v1FieldNum: Word;
  TestQuery: TDCLDialogQuery;
  tmpFieldName: string;
Begin
  Result:=False;
  tmpFieldName:=FieldName;
  If Pos('.', FieldName)<>0 then
  begin
    tmpFieldName:=Copy(FieldName, Pos('.', FieldName)+1, Length(FieldName));
  end;

  If Table='' then
  Begin
    If Assigned(Query) then
    Begin
{$IFDEF DELPHI}
      If GPT.DebugOn Then
        Query.FieldList.SaveToFile(AppConfigDir+'Existing_Fields.txt');
{$ENDIF}
      If tmpFieldName<>'' then
        If Query.FieldCount<>0 Then
          For v1FieldNum:=0 To Query.FieldCount-1 Do
            If UpperCase(Trim(tmpFieldName))=UpperCase(Query.Fields[v1FieldNum].FieldName) Then
            Begin
              Result:=True;
              Break;
            End;
    End;
  End
  Else
  Begin
    TestQuery:=TDCLDialogQuery.Create(nil);
    DCLMainLogOn.SetDBName(TestQuery);
    TestQuery.SQL.Text:='select * from '+Table+' where 1=0';
    Try
      TestQuery.Open;
    Except
      FreeAndNil(TestQuery);
      Result:=False;
      Exit;
    End;
    Result:=FieldExists(tmpFieldName, TestQuery);
    TestQuery.Close;
    FreeAndNil(TestQuery);
  End;
End;

procedure RePlaseParams_(var Params: string; Query: TDCLDialogQuery);
Var
  ReplaseField, TmpStr, FieldNameLoc: String;
  StartSel, ParamLen, StartSearch, pv1, pv2, pv3, VarNameLength, MaxMatch: Word;
  FindParNum: Integer;
  FindVar: Boolean;
Begin
  If Assigned(Query) Then
    If (Query.FieldCount>0)And Query.Active Then
      If TransParams Then
      Begin
        StartSearch:=Pos(ParamPrefix, Params);
        While Pos(ParamPrefix, Copy(Params, StartSearch, Length(Params)))<>0 Do
        Begin
          StartSearch:=StartSearch+Pos(ParamPrefix, Copy(Params, StartSearch, Length(Params)))-1;
          StartSel:=StartSearch+Length(ParamPrefix)-1;
          ParamLen:=Length(Params);
          If ParamLen<>0 Then
          Begin
            pv3:=0;
            FindParNum:=-1;
            MaxMatch:=0;

            While (Query.FieldCount-1>=pv3) Do
            Begin
              FindVar:=True;
              pv2:=1;
              pv1:=StartSel+1;
              While (FindVar)And(pv1<=ParamLen)And(pv2<=Length(Query.Fields[pv3].FieldName)) Do
              Begin
                FindVar:=False;
                If Length(Query.Fields[pv3].FieldName)>=pv2 Then
                Begin
                  FieldNameLoc:=Query.Fields[pv3].FieldName;
                  If UpperCase(Params[pv1])=UpperCase(FieldNameLoc[pv2]) Then
                  Begin
                    FindVar:=True;
                    If MaxMatch<pv1 Then
                    Begin
                      MaxMatch:=pv1;
                      FindParNum:=pv3;
                    End;
                  End;
                End;
                Inc(pv1);
                Inc(pv2);
              End;
              Inc(pv3);
            End;

            If FindParNum<>-1 Then
            Begin
              VarNameLength:=MaxMatch-StartSel;
              ReplaseField:=Copy(Params, StartSel+1, VarNameLength);
            End
            Else
            Begin
              VarNameLength:=0;
              ReplaseField:='';
            End;

            If FieldExists(ReplaseField, Query) Then
            Begin
              Delete(Params, StartSel, VarNameLength+1);
              TmpStr:=TrimRight(Query.FieldByName(ReplaseField).AsString);
              Insert(TmpStr, Params, StartSel);
              Inc(StartSearch, Length(TmpStr)+Length(ParamPrefix));
              TmpStr:='';
            End
            Else
              Inc(StartSearch, Length(ParamPrefix)+1);
          End;
        End;
      End;
end;

Procedure FillDatasetUpdateSQL(var Query: TDCLDialogQuery;
  {$IFDEF BDE_or_IB}var UpdateSQL: UpdateObj;
  {$ENDIF} UpdatesFields: String; UserLevelLocal: TUserLevelsType; DCLGrid: TDCLGrid;
  Open: Boolean=False);
var
  ShadowQuery: TDCLDialogQuery;
  UpdateTable, KeyField, UpdateFieldsSet, KeyFieldsSet: String;
  KeyFieldsCount: Byte;
  UpdateFieldsCount, v1: Word;

  KeyFields, UpdateFields: Array of String;
Begin
  if not Assigned(Query) then
    Exit;
  If (PosSet
    ('UniqueTable=,UpdateResync=,LockType=,CursorType=,UpdateQuery=,modifysql=,insertsql=,deletesql=,RefreshSQL=,AutoApply=,CashBase=,Live=,ParamCheck=',
    UpdatesFields)<>0)or(PosSet('UpdateTable=,KeyFields=,UpdateFields=', UpdatesFields)<>0) then
  Begin
    UpdateTable:=FindParam('UniqueTable=', UpdatesFields);
    If UpdateTable='' then
      UpdateTable:=FindParam('UpdateTable=', UpdatesFields);

{$IFDEF ADO}
    If UpdateTable<>'' Then
    Begin
      If Query.Active Then
        Query.Properties['Unique Table'].Value:=UpdateTable;
    End;

    If PosEx('UpdateResync=', UpdatesFields)=1 Then
    Begin
      UpdateTable:=FindParam('UpdateResync=', UpdatesFields);
      If UpdateTable='1' Then
        If Query.Active Then
          Query.Properties['Update Resync'].Value:=$0000000F;
    End;

    If PosEx('LockType=', UpdatesFields)=1 Then
    Begin
      UpdateTable:=FindParam('LockType=', UpdatesFields);
      If LowerCase(UpdateTable)=LowerCase('Optimistic') Then
        Query.LockType:=ltOptimistic;
      If LowerCase(UpdateTable)=LowerCase('Pessimistic') Then
        Query.LockType:=ltPessimistic;
      If LowerCase(UpdateTable)=LowerCase('ReadOnly') Then
        Query.LockType:=ltReadOnly;
    End;

    If PosEx('CursorType=', UpdatesFields)=1 Then
    Begin
      UpdateTable:=FindParam('CursorType=', UpdatesFields);
      If LowerCase(UpdateTable)=LowerCase('Keyset') Then
        Query.CursorType:=ctKeyset;
      If LowerCase(UpdateTable)=LowerCase('Dynamic') Then
        Query.CursorType:=ctDynamic;
      If LowerCase(UpdateTable)=LowerCase('Static') Then
        Query.CursorType:=ctStatic;
    End;
{$ENDIF}
{$IFDEF CACHEON}
    If UserLevelLocal>ulReadOnly Then
      If PosEx('UpdateQuery=', UpdatesFields)<>0 Then
      Begin
        If Query.Active Then
          Query.Close;

        UpdateSQL:=UpdateObj.Create(Nil);
        UpdateSQL.Name:='UpdateSQL_'+IntToStr(UpTime)+UpdateTable;
        Query.CachedUpdates:=True;

        Query.UpdateObject:=UpdateSQL;
        // FormData[CurrentForm].Navig.VisibleButtons:=EditButtonsSet;

        ShadowQuery:=TDCLDialogQuery.Create(nil);
        DCLMainLogOn.SetDBName(ShadowQuery);

        ShadowQuery.SQL.Text:='select * from '+UpdateTable+' where 1=0';
        ShadowQuery.Open;

        KeyField:=FindParam('KeyFields=', UpdatesFields);
        SetLength(KeyFields, ParamsCount(KeyField, ',', '')+1);
        For v1:=1 to ParamsCount(KeyField, ',', '') do
          KeyFields[v1]:=SortParams(KeyField, v1, ',', '');
        KeyFieldsCount:=ParamsCount(KeyField);

        KeyField:=FindParam('UpdateFields=', UpdatesFields);
        If KeyField='' then
        Begin
          SetLength(UpdateFields, ShadowQuery.FieldCount+1);
          For v1:=0 to ShadowQuery.FieldCount-1 do
          Begin
            UpdateFields[v1+1]:=ShadowQuery.Fields[v1].FieldName;
          End;
          UpdateFieldsCount:=ShadowQuery.FieldCount;
        End
        Else
        Begin
          SetLength(UpdateFields, ParamsCount(KeyField, ',', '')+1);
          For v1:=1 to ParamsCount(KeyField, ',', '') do
            UpdateFields[v1]:=SortParams(KeyField, v1, ',', '');
          UpdateFieldsCount:=ParamsCount(KeyField);
        End;

        ShadowQuery.Close;
        FreeAndNil(ShadowQuery);

        UpdateFieldsSet:='';
        For v1:=1 to UpdateFieldsCount do
          UpdateFieldsSet:=UpdateFieldsSet+UpdateFields[v1]+'=:'+UpdateFields[v1]+',';
        If UpdateFieldsSet<>'' then
          Delete(UpdateFieldsSet, Length(UpdateFieldsSet), 1);

        KeyFieldsSet:='';
        For v1:=1 to KeyFieldsCount do
          KeyFieldsSet:=KeyFieldsSet+KeyFields[v1]+'=:OLD_'+KeyFields[v1]+' and ';
        If KeyFieldsSet<>'' then
          Delete(KeyFieldsSet, Length(KeyFieldsSet)-4, 4);

        If not DCLGrid.FindNotAllowedOperation(dsoEdit) then
        Begin
          If FindParam('modifysql=', UpdatesFields)<>'' Then
          Begin
            UpdateSQL.ModifySQL.Text:=FindParam('modifysql=', UpdatesFields);
          End
          Else
            UpdateSQL.ModifySQL.Text:='update '+UpdateTable+' set '+UpdateFieldsSet+' where '+
              KeyFieldsSet;
        End;

        If not DCLGrid.FindNotAllowedOperation(dsoInsert) then
        Begin
          If FindParam('insertsql=', UpdatesFields)='' Then
          Begin
            UpdateFieldsSet:='';
            For v1:=1 To UpdateFieldsCount Do
              UpdateFieldsSet:=UpdateFieldsSet+UpdateFields[v1]+',';
            If UpdateFieldsSet<>'' then
              Delete(UpdateFieldsSet, Length(UpdateFieldsSet), 1);

            KeyFieldsSet:='';
            For v1:=1 To UpdateFieldsCount Do
              KeyFieldsSet:=KeyFieldsSet+':'+UpdateFields[v1]+',';
            If KeyFieldsSet<>'' then
              Delete(KeyFieldsSet, Length(KeyFieldsSet), 1);

            UpdateSQL.InsertSQL.Text:='insert into '+UpdateTable+'('+UpdateFieldsSet+') values('+
              KeyFieldsSet+')';
          End
          Else
            UpdateSQL.InsertSQL.Text:=FindParam('insertsql=', UpdatesFields);
        End;

        If not DCLGrid.FindNotAllowedOperation(dsoDelete) then
        Begin
          If FindParam('deletesql=', UpdatesFields)='' Then
          Begin
            KeyFieldsSet:='';
            For v1:=1 To KeyFieldsCount Do
              KeyFieldsSet:=KeyFieldsSet+KeyFields[v1]+'=:OLD_'+KeyFields[v1]+' and ';
            If KeyFieldsSet<>'' then
              Delete(KeyFieldsSet, Length(KeyFieldsSet)-4, 4);

            UpdateSQL.DeleteSQL.Text:='delete from '+UpdateTable+' where '+KeyFieldsSet;
          End
          Else
            UpdateSQL.DeleteSQL.Text:=FindParam('deletesql=', UpdatesFields);
        End;
{$IFDEF IBALL}
        If FindParam('RefreshSQL=', UpdatesFields)='' Then
        Begin
          KeyFieldsSet:='';
          For v1:=1 To KeyFieldsCount Do
            KeyFieldsSet:=KeyFieldsSet+KeyFields[v1]+'=:'+KeyFields[v1]+',';
          If KeyFieldsSet<>'' then
            Delete(KeyFieldsSet, Length(KeyFieldsSet), 1);

          UpdateSQL.RefreshSQL.Text:='select * from '+UpdateTable+' where '+KeyFieldsSet;
        End
        Else
          UpdateSQL.RefreshSQL.Text:=FindParam('RefreshSQL=', UpdatesFields);
{$ENDIF}
        // Query.FieldList.Update;
        If Query.Active=False Then
          If Query.SQL.Text<>'' Then
            Query.Open;

        If Query.Active then
          For v1:=0 to Query.FieldCount-1 do
            Query.Fields[v1].Required:=False;
      End;
{$ENDIF}
{$IFDEF BDE}
    If PosEx('CashBase=', UpdatesFields)=1 Then
    Begin
      If FindParam('CashBase=', UpdatesFields)='1' Then
      Begin
        Query.CachedUpdates:=True;
      End;
      If FindParam('CashBase=', UpdatesFields)='0' Then
      Begin
        Query.CachedUpdates:=False;
      End;
    End;

    If PosEx('Live=', UpdatesFields)=1 Then
    Begin
      KeyField:=FindParam('live=', UpdatesFields);
      If KeyField='1' Then
      Begin
        FormData[CurrentForm].RequestLive:=True;
        If Query.Active Then
        Begin
          Query.Close;
          Query.RequestLive:=False;
          Query.Open;
        End
        Else
          Query.RequestLive:=True;
      End;
      If KeyField='0' Then
      Begin
        FormData[CurrentForm].RequestLive:=False;
        If Query.Active Then
        Begin
          Query.Close;
          Query.RequestLive:=False;
          Query.Open;
        End
        Else
          Query.RequestLive:=False;
        FormData[CurrentForm].Navig.VisibleButtons:=NavigatorNavigateButtons;
      End;
    End;
{$ENDIF}
{$IFDEF DELPHI}
    If PosEx('ParamCheck=', UpdatesFields)=1 Then
    Begin
      KeyField:=FindParam('ParamCheck=', UpdatesFields);
      If KeyField='1' Then
        Query.ParamCheck:=True;
      If KeyField='0' Then
        Query.ParamCheck:=False;
    End;
{$ENDIF}
{$IFDEF IBALL}
    If Open then
      If not Query.Active then
        If Query.SQL.Text<>'' then
        Begin
          Query.Open;

          For v1:=0 to Query.FieldCount-1 do
            Query.Fields[v1].Required:=False;
        End;
{$ENDIF}
  End;
End;

function GetFieldFromParam(Param: String; Query: TDCLDialogQuery): TField;
const
  StopSimbols='( )[],.%:;&$#@*';
var
  FieldName: String;
  L: Word;
  i: Byte;
Begin
  Result:=nil;
  If Pos(FieldObjectPrefix, Param)<>0 then
  begin
    FieldName:='';
    L:=Length(Param);
    i:=Pos(FieldObjectPrefix, Param)+Length(FieldObjectPrefix);
    while i<L do
    Begin
      If Pos(Param[i], StopSimbols)<>0 then
      Begin
        Break;
      End;
      FieldName:=FieldName+Param[i];
      Inc(i);
    End;
    If Query.Active then
    Begin
      If FieldExists(FieldName, Query) then
        Result:=Query.FieldByName(FieldName);
    End;
  end;
End;

Function ExecQuery(SQL: String): TDCLDialogQuery;
Begin
  Result:=TDCLDialogQuery.Create(nil);
  DCLMainLogOn.SetDBName(Result);
  Result.SQL.Text:=SQL;

  If IsReturningQuery(SQL) then
    Result.Open
  Else
  Begin
    Result.ExecSQL;
    FreeAndNil(Result);
  End;
End;

Function GetField(Table, Field, Where: string): TField;
Var
  tmpQ: TDCLDialogQuery;
Begin
  tmpQ:=ExecQuery('select '+Field+' from '+Table+' '+Where);
  If Assigned(tmpQ) then
    Result:=tmpQ.FieldByName(Field);
End;

Function GetFieldValue(Table, Field, Where: string): string;
Var
  tmpQ: TField;
Begin
  tmpQ:=GetField(Table, Field, Where);
  If Assigned(tmpQ) then
  Begin
    Result:=tmpQ.AsString;
    tmpQ.DataSet.Close;
    tmpQ.DataSet.Free;
    // FreeAndNil(tmpQ);
  End;
End;

end.
