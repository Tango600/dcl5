unit TablePartMaster;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ComCtrls, Grids, Buttons;

type
  TFormTPMaster = class(TForm)
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    leTitle: TLabeledEdit;
    leSQL: TLabeledEdit;
    StringGrid1: TStringGrid;
    TabSheet3: TTabSheet;
    rgEditing: TRadioGroup;
    SpeedButton1: TSpeedButton;
    Button1: TButton;
    leMasterDataField: TLabeledEdit;
    leDependField: TLabeledEdit;
    rgFieldsStyle: TRadioGroup;
    procedure Button1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    ScrMain, tmpScrMain, ScrAdd, ScrEdit, ScrEditDialog:TStringList;
    ScrName:string;
    FieldsStyle:Byte;
  public
    { Public declarations }
  end;

implementation

uses
  DM, uUDL, uDCLData;

{$R *.dfm}

procedure TFormTPMaster.Button1Click(Sender: TObject);
var
  i:Byte;
  NoButtons:Boolean;
  ScrID:LongInt;
  S:string;
begin
  ScrMain:=TStringList.Create;
  tmpScrMain:=TStringList.Create;
  ScrAdd:=TStringList.Create;
  ScrEdit:=TStringList.Create;
  ScrEditDialog:=TStringList.Create;
  ScrName:=Trim(DM.Query1.FieldByName(GPT.DCLNameField).AsString);

  S:='TablePart=Title='+leTitle.Text+';SQL='+leSQL.Text+';MasterDataField='+leMasterDataField.Text+';DependField='+leDependField.Text+';';
  case rgEditing.ItemIndex of
  0,3:Begin
    S:=S+'ReadOnly=1;';
  End;
  end;
  ScrMain.Append(S);

  case rgEditing.ItemIndex of
  0,2:Begin
    S:=S+'ReadOnly=1;';
    ScrAdd.Append('Append_Part;');
    ScrAdd.Append('Dialog='+ScrName+'_'+leDependField.Text+'_Edit_Dlg;TablePart=0;');

    ScrEdit.Append('Edit_Part;');
    ScrEdit.Append('Dialog='+ScrName+'_'+leDependField.Text+'_Edit_Dlg;TablePart=0;');

    ScrEditDialog.Append('Caption='+leTitle.Text+' Редактирование;');
    Case rgFieldsStyle.ItemIndex of
    0:Begin
    ScrEditDialog.Append('Orientation=Horizontal;');
    ScrEditDialog.Append('Style=0;');
    End;
    1:ScrEditDialog.Append('Style=0;');
    2:ScrEditDialog.Append('Style=1;');
    End;

    ScrEditDialog.Append('[FIELDS]');
    ScrEditDialog.Append('*');

    ScrMain.Append('TablePartToolButton=Label=Добавить;CommandName='+ScrName+'_'+leDependField.Text+'_Append_Scr;');
    ScrMain.Append('TablePartToolButton=Label=Изменить;CommandName='+ScrName+'_'+leDependField.Text+'_Edit_Scr;');
  End;
  end;

  tmpScrMain.Text:=DM.Query1.FieldByName(GPT.DCLTextField).AsString;
//  tmpScrMain.Append('//-----------');
  DM.Query1.Edit;
  tmpScrMain.Insert(FindStrIndex(tmpScrMain, '[Fields]'), ScrMain.Text);
  DM.Query1.FieldByName(GPT.DCLTextField).AsString:=tmpScrMain.Text;
  DM.Query1.Post;
  tmpScrMain.Free;

  If ScrEdit.Count>0 then
  Begin
    DM.Query1.Insert;
    DM.Query1.FieldByName(GPT.NumSeqField).AsInteger:=GetGen_ID(GPT.GeneratorName);
    DM.Query1.FieldByName(GPT.DCLNameField).AsString:=ScrName+'_'+leDependField.Text+'_Edit_Scr';
    DM.Query1.FieldByName(GPT.DCLTextField).AsString:=ScrEdit.Text;
    DM.Query1.Post;
  End;

  If ScrAdd.Count>0 then
  Begin
    DM.Query1.Insert;
    DM.Query1.FieldByName(GPT.NumSeqField).AsInteger:=GetGen_ID(GPT.GeneratorName);
    DM.Query1.FieldByName(GPT.DCLNameField).AsString:=ScrName+'_'+leDependField.Text+'_Append_Scr';
    DM.Query1.FieldByName(GPT.DCLTextField).AsString:=ScrAdd.Text;
    DM.Query1.Post;
  End;

  If ScrEditDialog.Count>0 then
  Begin
    DM.Query1.Insert;
    DM.Query1.FieldByName(GPT.NumSeqField).AsInteger:=GetGen_ID(GPT.GeneratorName);
    DM.Query1.FieldByName(GPT.DCLNameField).AsString:=ScrName+'_'+leDependField.Text+'_Edit_Dlg';
    DM.Query1.FieldByName(GPT.DCLTextField).AsString:=ScrEditDialog.Text;
    DM.Query1.Post;
  End;

  Close;
end;

procedure TFormTPMaster.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action:=caFree;
end;

end.
