unit AddElements;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls;

type
  TfrAddElements = class(TForm)
    Panel1: TPanel;
    Button1: TButton;
    Button2: TButton;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    ComponentStr:String;
  end;


implementation

uses Main, DM;

{$R *.dfm}

procedure TfrAddElements.Button1Click(Sender: TObject);
Var
  S:String;
  i, y:Integer;
begin
  S:=ComponentDirectives[0].DirectivName+'=';
  If Length(ComponentDirectives)>1 then
  Begin
    For i:=1 to Length(ComponentDirectives) do
      If (ComponentDirectives[i].DirectivName<>'') and (ComponentDirectives[i].Value<>'') then
        S:=S+ComponentDirectives[i].DirectivName+'='+ComponentDirectives[i].Value+';'
      Else
        If ComponentDirectives[i].Value<>'' then
          S:=S+ComponentDirectives[i].Value+';';
  End
  Else
    If ComponentDirectives[i].Value<>'' then
      S:=S+ComponentDirectives[1].Value+';';

  ComponentStr:=S;

  i:=GetActiveEditor;
  If i<>-1 then
  Begin
    y:=ScrriptEditorsForms[i].Form.Memo1.Perform(EM_LINEFROMCHAR, ScrriptEditorsForms[i].Form.Memo1.SelStart, 0);
    ScrriptEditorsForms[i].Form.Memo1.Lines.Insert(y, S);
  End
  Else
  Begin
    If Assigned(SlideEditor) then
    Begin
      y:=SlideEditor.Memo1.Perform(EM_LINEFROMCHAR, SlideEditor.Memo1.SelStart, 0);
      SlideEditor.Memo1.Lines.Insert(y, S);
    End;
  End;

  Close;
end;

procedure TfrAddElements.Button2Click(Sender: TObject);
begin
  Close;
end;

procedure TfrAddElements.FormCreate(Sender: TObject);
begin
  ComponentStr:='';
end;

end.
