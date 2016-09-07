unit EditValVars;

interface

uses Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, uUDL;

type
  TForm27=class(TForm)
    Panel1: TPanel;
    LabeledEdit1: TLabeledEdit;
    LabeledEdit2: TLabeledEdit;
    Button1: TButton;
    Button2: TButton;
    procedure Button2Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation

uses
  ValVariables;

{$R *.dfm}

procedure TForm27.Button2Click(Sender: TObject);
begin
  Close;
end;

procedure TForm27.Button1Click(Sender: TObject);
var
  i:Word;
begin
{  If VarMode=0 then
  begin
    Variables[Form26.StringGrid1.Row].Value:=Form27.LabeledEdit1.Text;
    For i:=1 to VariablesCount do
    begin
      Form26.StringGrid1.Cells[0, i]:=Variables[i].Name;
      Form26.StringGrid1.Cells[1, i]:=Variables[i].Value;
      Form26.StringGrid1.RowCount:=i+1;
    end;
  end
  Else
    DeclareVariable(Form27.LabeledEdit2.Text);

  StatusBar1.Panels[0].Text:='Всего переменных :'+IntToStr(VariablesCount);}
  Close;
end;

procedure TForm27.FormShow(Sender: TObject);
begin
  LabeledEdit2.Clear;
  LabeledEdit1.Clear;
  LabeledEdit2.ReadOnly:=False;
  LabeledEdit1.Hide;
  If VarMode=0 then
  begin
    {LabeledEdit2.Text:=Variables[StringGrid1.Row].Name;
    LabeledEdit1.Text:=Variables[StringGrid1.Row].Value;}
    LabeledEdit2.ReadOnly:=True;
    LabeledEdit1.Show;
  end;
end;

end.
