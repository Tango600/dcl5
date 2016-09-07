unit VerForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Mask, DBCtrls, StdCtrls, ExtCtrls;

type
  TfrVerInfo = class(TForm)
    Panel1: TPanel;
    Label1: TLabel;
    Label2: TLabel;
    Panel2: TPanel;
    VerNum1: TEdit;
    VerNum2: TEdit;
    VerNum3: TEdit;
    VerNum4: TEdit;
    Button1: TButton;
    MemoVerInfo: TMemo;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation

uses
  DM, uUDL, uDCLData, uStringParams;

{$R *.dfm}

procedure TfrVerInfo.Button1Click(Sender: TObject);
var
  S,S1:string;
  i:Byte;
begin
  Query3.SQL.Text:='select count(*) from '+GPT.DCLTable+' where '+GPT.IdentifyField+'=60000';
  Query3.Open;
  If Query3.Fields[0].AsInteger=0 then
  Begin
    Query3.SQL.Text:='insert into '+GPT.DCLTable+'('+GPT.DCLTextField+','+GPT.IdentifyField+') values(:VERINFO, 60000)';
//+GPT.StringTypeChar+MemoVerInfo.Text+GPT.StringTypeChar
    //Query3.Parameters.ParamByName('VERINFO').Value:=MemoVerInfo.Text;
    Query3.ExecSQL;
  End
  Else
  begin
    Query3.SQL.Text:='update '+GPT.DCLTable+' set '+GPT.DCLTextField+'=:VERINFO'+' where '+GPT.IdentifyField+'=60000';
//+GPT.StringTypeChar+MemoVerInfo.Text+GPT.StringTypeChar
    //Query3.Parameters.ParamByName('VERINFO').Value:=MemoVerInfo.Text;
    Query3.ExecSQL;
  end;

  S:='';
  For i:=1 To 4 Do
  Begin
    S1:=(FindComponent('VerNum'+IntToStr(i)) as TEdit).Text;
    If S1<>'' then
      S:=S+S1+'.';
  End;
  Delete(S, Length(S), 1);

  Query3.SQL.Text:='select count(*) from '+GPT.DCLTable+' where '+GPT.IdentifyField+'=60001';
  Query3.Open;
  If Query3.Fields[0].AsInteger=0 then
    Query3.SQL.Text:='insert into '+GPT.DCLTable+'('+GPT.DCLNameField+','+GPT.IdentifyField+') values('+GPT.StringTypeChar+S+GPT.StringTypeChar+', 60001)'
  Else
    Query3.SQL.Text:='update '+GPT.DCLTable+' set '+GPT.DCLNameField+'='+GPT.StringTypeChar+S+GPT.StringTypeChar+' where '+GPT.IdentifyField+'=60001';
  Query3.ExecSQL;

  Close;
end;

procedure TfrVerInfo.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action:=caFree;
end;

procedure TfrVerInfo.FormCreate(Sender: TObject);
Type
  TVersionNumbers=Array[1..4] Of Word;
var
  VerS, S:string;
  i:Byte;
  Ver, BaseCompVer:TVersionNumbers;
begin
  Query3.SQL.Text:='select '+GPT.DCLTextField+' from '+GPT.DCLTable+' where '+GPT.IdentifyField+'=60000';
  Query3.Open;
  MemoVerInfo.Text:=Trim(Query3.Fields[0].AsString);
  Query3.Close;

  Query3.SQL.Text:='select '+GPT.DCLNameField+' from '+GPT.DCLTable+' where '+GPT.IdentifyField+'=60001';
  Query3.Open;
  VerS:=Query3.Fields[0].AsString;
  Query3.Close;

  For i:=1 To 4 Do
  Begin
    S:=SortParams(VerS, i, '.');
    (FindComponent('VerNum'+IntToStr(i)) as TEdit).Text:=S;
    If S<>'' then
      Ver[i]:=StrToInt(S);
  End;
    

end;

end.
