unit DM;
{$I DefineType.pas}

interface

uses
  SysUtils, Classes, uUDL, DB, ScrEditor, uDCLTypes, uDCLData,
  uStringParams, uDCLQuery;

type
  TDataModule1 = class(TDataModule)
    DataSource1: TDataSource;
    DataSource2: TDataSource;
    procedure DataModuleCreate(Sender: TObject);
  private
    { Private declarations }
  public
    procedure OnPostRecord(DataSet:TDataSet);
  end;

  TScriptEdit=Record
    Active, NotSaved: Boolean;
    Tag: Integer;
    ScriptName: String;
    Form:TTScrEditor;
  End;

Const
  MaxScriptEditors=20;

var
  Query1, Query2, Query3:TDCLQuery;

  ScrText: TStringList;
  ScrriptEditorsFormsPos, i: Byte;
  ScrriptEditorsForms: Array [1..MaxScriptEditors] of TScriptEdit;

  function GetGen_ID(GeneratorName:string):LongInt;
  procedure AddToRole(ScrID:LongInt);
  function FindStrIndex(Scr:TStrings; FindStr:string):Integer;
  Function GetFieldsList(SQL:String):TStringList;
  function GetQueryFromDialog(ActiveDialog:Integer):string;


implementation

uses Main;


{$R *.dfm}

function GetGen_ID(GeneratorName:string):LongInt;
var
  GenQ:TDCLDialogQuery;
begin
  GenQ:=TDCLDialogQuery.Create(nil);
  DCLMainLogOn.SetDBName(GenQ);
{$IFDEF ServerIB}
  GenQ.SQL.Text:='select gen_id('+GeneratorName+', 1) from rdb$database';
{$ELSE}
  GenQ.SQL.Text:='select max('+GPT.NumSeqField+')+1 from '+GPT.DCLTable;
{$ENDIF}
  GenQ.Open;
  Result:=GenQ.Fields[0].AsInteger;
  GenQ.Close;

  FreeAndNil(GenQ);
end;

procedure AddToRole(ScrID:LongInt);
var
  Q:TDCLDialogQuery;
begin
  If GPT.RoleID<>'' then
  Begin
    Q:=TDCLDialogQuery.Create(nil);
    DCLMainLogOn.SetDBName(Q);
    Q.SQL.Text:='insert into '+GPT.RolesMenuTable+'(ROLEID, MENUITEMID) values('+GPT.RoleID+', '+IntToStr(ScrID)+')';
    Q.ExecSQL;
    FreeAndNil(Q);
  End;
end;

function FindStrIndex(Scr:TStrings; FindStr:string):Integer;
var
  i:Word;
begin
  Result:=-1;
  i:=0;
  while i<=Scr.Count do
  begin
    If PosEx(FindStr, Scr[i])<>0 then
    Begin
      Result:=i;
      Break;
    End;

    Inc(i);
  end;
end;

Function GetFieldsList(SQL:String):TStringList;
var
  Q:TDCLDialogQuery;
  i:Word;
begin
  Result:=TStringList.Create;
  If SQL<>'' then
  Begin
    Q:=TDCLDialogQuery.Create(nil);
    DCLMainLogOn.SetDBName(Q);
    SQL:=StringReplace(SQL, '&', ':', [rfReplaceAll]);
    Q.SQL.Text:=SQL;
    Q.Open;
    For i:=0 to Q.FieldCount-1 do
      Result.Append(Q.Fields[i].FieldName);
    FreeAndNil(Q);
  End;
end;

function GetQueryFromDialog(ActiveDialog:Integer):string;
var
  i:Integer;
begin
  Result:='';
  If ActiveDialog<>-1 then
  Begin
    i:=FindStrIndex(ScrriptEditorsForms[ActiveDialog].Form.Memo1.Lines, 'Query=');
    If i<>-1 then
    begin
      Result:=FindParam('Query=', ScrriptEditorsForms[ActiveDialog].Form.Memo1.Lines[i]);
    end;
  End;
end;


procedure TDataModule1.DataModuleCreate(Sender: TObject);
begin
  Query1:=DCLMainLogOn.CreateDCLQuery;  //TDCLQuery.Create(DCLMainLogOn.d);
  Query2:=DCLMainLogOn.CreateDCLQuery;
  Query3:=DCLMainLogOn.CreateDCLQuery;

  DataSource1.DataSet:=Query1;
  DataSource2.DataSet:=Query3;

  //DCLMainLogOn.SetDBName(Query1);
  //DCLMainLogOn.SetDBName(Query2);
  //DCLMainLogOn.SetDBName(Query3);

  Query1.OnNewRecord:=OnPostRecord;
end;

procedure TDataModule1.OnPostRecord(DataSet: TDataSet);
begin
  If not (DataSet.State in [dsInsert, dsEdit]) then
    DataSet.Edit;
  DataSet.FieldByName(GPT.NumSeqField).AsInteger:=GetGen_ID(GPT.GeneratorName);
  //DataSet.Post;
end;

end.
