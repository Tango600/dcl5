unit SlaideEditor;

interface

uses Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, DBCtrls, ExtCtrls, StdCtrls, Spin, Mask, Buttons,
  uUDL, Menus, DB, uDCLData;

type
  TfrSlideEditor=class(TForm)
    Memo1: TDBMemo;
    StatusBar1: TStatusBar;
    Panel2: TPanel;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    SpeedButton9: TSpeedButton;
    SpeedButton10: TSpeedButton;
    SpeedButton11: TSpeedButton;
    SpeedButton12: TSpeedButton;
    DBEdit1: TDBEdit;
    DBEdit2: TDBEdit;
    DBEdit3: TDBEdit;
    SpinEdit1: TSpinEdit;
    Panel3: TPanel;
    SpeedButton1: TSpeedButton;
    DBNavigator1: TDBNavigator;
    FontDialog1: TFontDialog;
    ColorDialog1: TColorDialog;
    PopupMenu1: TPopupMenu;
    N1: TMenuItem;
    N2: TMenuItem;
    N3: TMenuItem;
    N4: TMenuItem;
    N5: TMenuItem;
    N6: TMenuItem;
    N7: TMenuItem;
    N8: TMenuItem;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure SpinEdit1Change(Sender: TObject);
    procedure SpeedButton9Click(Sender: TObject);
    procedure SpeedButton10Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure N1Click(Sender: TObject);
    procedure N4Click(Sender: TObject);
    procedure N2Click(Sender: TObject);
    procedure N3Click(Sender: TObject);
    procedure N6Click(Sender: TObject);
    procedure N7Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;


implementation

uses DM, Main;

{$R *.dfm}

procedure TfrSlideEditor.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action:=caFree;
end;

procedure TfrSlideEditor.SpinEdit1Change(Sender: TObject);
begin
  Memo1.Font.Size:=SpinEdit1.Value;
end;

procedure TfrSlideEditor.SpeedButton9Click(Sender: TObject);
begin
  If FontDialog1.Execute then
    Memo1.Font:=FontDialog1.Font;
end;

procedure TfrSlideEditor.SpeedButton10Click(Sender: TObject);
begin
  If ColorDialog1.Execute then
    Memo1.Color:=ColorDialog1.Color;
end;

procedure TfrSlideEditor.FormShow(Sender: TObject);
begin
  DBEdit1.DataField:=GPT.CommandField;
  DBEdit2.DataField:=GPT.IdentifyField;
  DBEdit3.DataField:=GPT.ParentFlgField;
end;

procedure TfrSlideEditor.N1Click(Sender: TObject);
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

procedure TfrSlideEditor.N4Click(Sender: TObject);
begin
  Memo1.CutToClipboard;
end;

procedure TfrSlideEditor.N2Click(Sender: TObject);
begin
  Memo1.CopyToClipboard;
end;

procedure TfrSlideEditor.N3Click(Sender: TObject);
begin
  Memo1.PasteFromClipboard;
end;

procedure TfrSlideEditor.N6Click(Sender: TObject);
begin
  Memo1.Undo;
end;

procedure TfrSlideEditor.N7Click(Sender: TObject);
begin
  Memo1.SelectAll;
end;

end.
