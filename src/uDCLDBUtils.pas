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
Function GetSimplyFieldType(Const FieldName: String; Query: TDCLDialogQuery): TSimplyFieldType; overload;
Function GetSimplyFieldType(Const FieldType:TFieldType): TSimplyFieldType; overload;
Function GetNameDSState(State: TDataSetState): String;
procedure RePlaseParams_(var Params: string; Query: TDCLDialogQuery);
Function FieldExists(Const FieldName: String; Query: TDCLDialogQuery; Table: string=''): Boolean;
function GetFieldFromParam(Param: String; Query: TDCLDialogQuery): TField;
Function GetField(Table, Field, Where: string): TField;
Function ExecQuery(SQL: String): TDCLDialogQuery;
Function GetFieldValue(Table, Field, Where: string): string;

implementation

uses
  uDCLUtils;

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

Function NormalizeFieldName(Const FieldName: String): String;
Begin
  Result:=FieldName;
  If Pos('.', FieldName)<>0 then
  begin
    Result:=Copy(FieldName, Pos('.', FieldName)+1, Length(FieldName));
  end;
end;

Function GetDelimiter(Const FieldName: String; Query: TDCLDialogQuery): String;
var
  tmpFieldName:string;
Begin
  tmpFieldName:=NormalizeFieldName(FieldName);
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

Function GetSimplyFieldType(Const FieldName: String; Query: TDCLDialogQuery): TSimplyFieldType;
var
  tmpFieldName:string;
Begin
  tmpFieldName:=NormalizeFieldName(FieldName);
  If Query.FieldByName(tmpFieldName).DataType in TStringTypedFields then
    Result:=sftString
  Else
    If Query.FieldByName(tmpFieldName).DataType in TIntegerTypedFields then
      Result:=sftDigit
    Else
      If Query.FieldByName(tmpFieldName).DataType in TFloatTypedFields then
        Result:=sftFloat
      Else
        If Query.FieldByName(tmpFieldName).DataType in TDateTimeTypedFields then
          Result:=sftDateTime
        Else
          Result:=sftString;
End;

Function GetSimplyFieldType(Const FieldType:TFieldType): TSimplyFieldType; overload;
Begin
  If FieldType in TStringTypedFields then
    Result:=sftString
  Else
    If FieldType in TIntegerTypedFields then
      Result:=sftDigit
    Else
      If FieldType in TFloatTypedFields then
        Result:=sftFloat
      Else
        If FieldType in TDateTimeTypedFields then
          Result:=sftDateTime
        Else
          Result:=sftString;
End;


Function FieldExists(Const FieldName: String; Query: TDCLDialogQuery; Table: string=''): Boolean;
Var
  v1FieldNum: Word;
  TestQuery: TDCLDialogQuery;
  tmpFieldName: string;
Begin
  Result:=False;
  tmpFieldName:=NormalizeFieldName(FieldName);

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
    TestQuery.Name:='FieldExists_'+IntToStr(UpTime);
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

function GetFieldFromParam(Param: String; Query: TDCLDialogQuery): TField;
const
  StopSimbols='( )[],.%:;&$#@*'#39;
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
  Result.Name:='ExecQuery_'+IntToStr(UpTime);
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
  tmpFieldName: string;
Begin
  tmpFieldName:=NormalizeFieldName(Field);
  tmpQ:=ExecQuery('select '+tmpFieldName+' from '+Table+' '+Where);
  If Assigned(tmpQ) then
    Result:=tmpQ.FieldByName(tmpFieldName);
  tmpQ.Close;
  FreeAndNil(tmpQ);
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
