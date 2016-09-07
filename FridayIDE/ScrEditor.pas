unit ScrEditor;

interface

uses Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, ExtCtrls, uUDL, Menus, DB, uDCLData;

type
  TTScrEditor=class(TForm)
    Memo1: TMemo;
    Panel1: TPanel;
    StatusBar1: TStatusBar;
    Button1: TButton;
    PopupMenu2: TPopupMenu;
    N4: TMenuItem;
    N2: TMenuItem;
    N3: TMenuItem;
    N6: TMenuItem;
    N5: TMenuItem;
    MenuItem1: TMenuItem;
    N1: TMenuItem;
    N7: TMenuItem;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Button1Click(Sender: TObject);
    procedure N1Click(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure N4Click(Sender: TObject);
    procedure N2Click(Sender: TObject);
    procedure N3Click(Sender: TObject);
    procedure N6Click(Sender: TObject);
    procedure MenuItem1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Memo1Change(Sender: TObject);
  private
    { Private declarations }
  public
    ScrId: String;
    NotSaved, Active: Boolean;
  end;

var
  SQL: String;

implementation

uses DM, Main;

{$R *.dfm}

procedure TTScrEditor.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  ScrriptEditorsForms[(Sender as TForm).Tag].Active:=False;
  ScrriptEditorsForms[(Sender as TForm).Tag].Tag:= - 1;
  ScrriptEditorsForms[(Sender as TForm).Tag].ScriptName:='';
  Dec(ScrriptEditorsFormsPos);
  Action:=caFree;
end;

procedure TTScrEditor.FormCreate(Sender: TObject);
begin
  Inc(ScrriptEditorsFormsPos);
  NotSaved:=False;
end;

procedure TTScrEditor.Button1Click(Sender: TObject);
begin
  SQL:='select * from '+GPT.DCLTable+' dcl where dcl.'+GPT.NumSeqField+'='+ScrId;
  Query2.SQL.Text:=SQL;
  Query2.Open;

  Query2.Edit;
  Query2.FieldByName(GPT.DCLTextField).AsString:=Memo1.Text;
  Query2.Post;

  Query1.Refresh;
  NotSaved:=False;
  ScrriptEditorsForms[(Sender as TButton).Tag].NotSaved:=False;
end;

procedure TTScrEditor.N1Click(Sender: TObject);
begin
  Memo1.SelectAll;
end;

procedure TTScrEditor.FormActivate(Sender: TObject);
Var
  i:Integer;
begin
  For i:=1 to MaxScriptEditors do
    ScrriptEditorsForms[i].Active:=False;

  i:=(Sender as TForm).Tag;
  If i<>0 then
    ScrriptEditorsForms[i].Active:=True;
end;

procedure TTScrEditor.N4Click(Sender: TObject);
begin
  Memo1.CutToClipboard;
end;

procedure TTScrEditor.N2Click(Sender: TObject);
begin
  Memo1.CopyToClipboard;
end;

procedure TTScrEditor.N3Click(Sender: TObject);
begin
  Memo1.PasteFromClipboard;
end;

procedure TTScrEditor.N6Click(Sender: TObject);
begin
  Memo1.Undo;
end;

procedure TTScrEditor.Memo1Change(Sender: TObject);
begin
  NotSaved:=True;
  ScrriptEditorsForms[(Sender as TMemo).Tag].NotSaved:=True;
end;

procedure TTScrEditor.MenuItem1Click(Sender: TObject);
var
  i:Integer;
begin
  For i:=1 to Screen.FormCount do
  begin
    if Screen.Forms[i-1].Name='Form1' then
    begin
      TForm1(Screen.Forms[i-1]).GoToScript(Memo1.SelText);
      Break;
    end;
  end;
end;

end.
