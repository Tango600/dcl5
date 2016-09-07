unit ValVariables;

interface

uses Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Grids, ComCtrls, uUDL, uDCLData, Generics.Collections;

type
  TForm26=class(TForm)
    StatusBar1: TStatusBar;
    StringGrid1: TStringGrid;
    Button1: TButton;
    Button2: TButton;
    CheckBox1: TCheckBox;
    Button3: TButton;
    Button4: TButton;
    procedure Button1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure CheckBox1Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
  private
    procedure ScanVars;
  public
    { Public declarations }
  end;

var
  Form26: TForm26;
  VarMode: Byte;

implementation

uses EditValVars;

{$R *.dfm}

procedure TForm26.ScanVars;
Var
  AllVariables:TList<TVariable>;
  i:Word;
Begin
  AllVariables:=DCLMainLogOn.Variables.GetAllVariables;
  If AllVariables.Count>0 then
  Begin
    For i:=0 to AllVariables.Count-1 do
    Begin
      StringGrid1.Cells[0, i+1]:=DCLMainLogOn.Variables.VariablesList[i].Name;
      StringGrid1.Cells[1, i+1]:=DCLMainLogOn.Variables.VariablesList[i].Value;
      StringGrid1.RowCount:=i+1;
    end;
    StatusBar1.Panels[0].Text:='Всего переменных :'+IntToStr(AllVariables.Count);
  End;
end;

procedure TForm26.Button1Click(Sender: TObject);
Begin
  ScanVars;
end;

procedure TForm26.FormShow(Sender: TObject);
Begin
  ScanVars;
end;

procedure TForm26.Button2Click(Sender: TObject);
Begin
  VarMode:=0;
  Show;
end;

procedure TForm26.CheckBox1Click(Sender: TObject);
Begin
  If CheckBox1.Checked then
    FormStyle:=fsStayOnTop
  Else
    FormStyle:=fsNormal;
end;

procedure TForm26.Button4Click(Sender: TObject);
Begin
  DCLMainLogOn.Variables.FreeVariable(StringGrid1.Cells[0, StringGrid1.Row]);
end;

procedure TForm26.Button3Click(Sender: TObject);
Begin
  VarMode:=1;
  Show;
end;

end.
