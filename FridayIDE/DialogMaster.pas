unit DialogMaster;
{$I DefineType.pas}

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, StdCtrls, ExtCtrls, CheckLst, uDCLData;

type
  TFormDialogMaster = class(TForm)
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    TabSheet3: TTabSheet;
    leFormCapt: TLabeledEdit;
    leScrName: TLabeledEdit;
    rgFieldsStyle: TRadioGroup;
    rgEditingStyle: TRadioGroup;
    rgEditing: TRadioGroup;
    TabSheet4: TTabSheet;
    CheckBox1: TCheckBox;
    ListNavButtons: TCheckListBox;
    Label1: TLabel;
    Button1: TButton;
    chDialogEditing: TCheckBox;
    chNavButtonsInEditing: TCheckBox;
    chHorizontalEditDialog: TCheckBox;
    chAddMenuItem: TCheckBox;
    chNewDialog: TCheckBox;
    cbTables: TComboBox;
    Label2: TLabel;
    procedure Button1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
  private
    ScrMain, ScrAdd, ScrEdit, ScrEditDialog, tmpScrMain:TStringList;
    FormCaption, ScrName:string;
    FieldsStyle:Byte;
  public
    { Public declarations }
  end;


implementation

uses
  DM, uUDL;

{$R *.dfm}

procedure TFormDialogMaster.Button1Click(Sender: TObject);
var
  i:Byte;
  NoButtons:Boolean;
  ScrID:LongInt;
  S:string;
begin
  ScrMain:=TStringList.Create;
  ScrAdd:=TStringList.Create;
  ScrEdit:=TStringList.Create;
  ScrEditDialog:=TStringList.Create;

  FormCaption:=leFormCapt.Text;
  ScrName:=leScrName.Text;
  FieldsStyle:=rgFieldsStyle.ItemIndex;

  ScrMain.Append('Caption='+leFormCapt.Text+';');

  ScrEditDialog.Append('Caption='+leFormCapt.Text+' Редактирование;');
  If chHorizontalEditDialog.Checked then
    ScrEditDialog.Append('Orientation=Horizontal;');
  ScrEditDialog.Append('Style=0;');

  ScrMain.Append('Query=select * from '+cbTables.Text);
  ScrMain.Append('UpdateQuery=UpdateTable='+cbTables.Text+';KeyFields=;');

  NoButtons:=True;
  for i:=0 to ListNavButtons.Count-1 do
    If ListNavButtons.Checked[i] then
    Begin
      NoButtons:=False;
      Break;
    End;

  If not NoButtons then
    ScrMain.Append('Navigator=0;')
  Else
  Begin
  S:='';
  for i:=0 to ListNavButtons.Count-1 do
    If ListNavButtons.Checked[i] then
    Begin
      case i of
      0:S:=S+'First,';
      1:S:=S+'Prior,';
      2:S:=S+'Next,';
      3:S:=S+'Last,';
      4:S:=S+'Insert,';
      5:S:=S+'Edit,';
      6:S:=S+'Post,';
      7:S:=S+'Delete,';
      8:S:=S+'Cancel,';
      9:S:=S+'Refresh,';
      end;
    End;
  If S<>'' then
    Delete(S, Length(S), 1);
  ScrMain.Append('Navigator=1;Buttons='+S+';')
  End;

  Case FieldsStyle of
  0:begin   //Таблица
    ScrMain.Append('Style=2;');

    case rgEditing.ItemIndex of
    0:begin   //в диалоге //обеими способами
      case rgEditingStyle.ItemIndex of
      0:begin  //по щелчку на таблице
        ScrAdd.Append('Dialog='+ScrName+'_Edit_Dlg;Child=1;');

        ScrEdit.Append('Edit;');
        ScrEdit.Append('Dialog='+ScrName+'_Edit_Dlg;Child=1;');

        If not chDialogEditing.Checked then
          ScrMain.Append('ReadOnly=1;');
        ScrMain.Append('Events=LineDblClickEvents='+ScrName+'_Edit_Scr;InsertEvents='+ScrName+'_Add_Scr;');

        ScrEditDialog.Append('Navigator=1;Buttons=Insert,Post,Cancel;');
//        ScrEditDialog.Append('');
      end;

      1:begin  //по кнопкам
        ScrAdd.Append('Append;');
        ScrAdd.Append('Dialog='+ScrName+'_Edit_Dlg;Child=1;');

        ScrEdit.Append('Edit;');
        ScrEdit.Append('Dialog='+ScrName+'_Edit_Dlg;Child=1;');

        If not chDialogEditing.Checked then
          ScrMain.Append('ReadOnly=1;');
        ScrMain.Append('CommandButton=Label=Изменить;CommandName='+ScrName+'_Edit_Scr;');
        ScrMain.Append('CommandButton=Label=Добавить;CommandName='+ScrName+'_Add_Scr;');

        If chNavButtonsInEditing.Checked then
          ScrEditDialog.Append('Navigator=1;Buttons=Post,Cancel;')
        Else
          ScrEditDialog.Append('Navigator=0;');
//        ScrEditDialog.Append('');
      end;
      2:begin  //по кнопкам навигации
        ScrEdit.Append('Dialog='+ScrName+'_Edit_Dlg;Child=1;');

        If not chDialogEditing.Checked then
          ScrMain.Append('ReadOnly=1;');
        ScrMain.Append('Events=InsertEvents='+ScrName+'_Edit_Dlg;');

        If chNavButtonsInEditing.Checked then
          ScrEditDialog.Append('Navigator=1;Buttons=Post,Cancel;')
        Else
          ScrEditDialog.Append('Navigator=0;');
//        ScrEditDialog.Append('');
      end;
      3:begin  // по щелчку и кнопкам
        If not chDialogEditing.Checked then
          ScrMain.Append('ReadOnly=1;');
        ScrMain.Append('Events=LineDblClickEvents='+ScrName+'_Edit_Scr;');  //InsertEvents='+ScrName+'_Add_Scr;');

        ScrEditDialog.Append('Navigator=1;Buttons=Insert,Post,Cancel;');

        ScrAdd.Append('Append;');
        ScrAdd.Append('Dialog='+ScrName+'_Edit_Dlg;Child=1;');

        ScrEdit.Append('Edit;');
        ScrEdit.Append('Dialog='+ScrName+'_Edit_Dlg;Child=1;');

        If not chDialogEditing.Checked then
          ScrMain.Append('ReadOnly=1;');
        ScrMain.Append('CommandButton=Label=Изменить;CommandName='+ScrName+'_Edit_Scr;');
        ScrMain.Append('CommandButton=Label=Добавить;CommandName='+ScrName+'_Add_Scr;');

        If chNavButtonsInEditing.Checked then
          ScrEditDialog.Append('Navigator=1;Buttons=Post,Cancel;')
        Else
          ScrEditDialog.Append('Navigator=0;');
//        ScrEditDialog.Append('');

      end;
    end;
    end;
    2:begin
      ScrMain.Append('ReadOnly=1;');
    end;
    end;
  end;

  1:Begin
    ScrMain.Append('Style=0;');
  End;
  2:Begin
    ScrMain.Append('Style=1;');
  End;
  3:Begin
    ScrMain.Append('Orientation=Horizontal;');
    ScrMain.Append('Style=0;');
  End;
  End;

  If not chNavButtonsInEditing.Checked then
  begin
    ScrEditDialog.Append('NoKeys;');
    ScrEditDialog.Append('Events=CloseEvents=Cancel;');
    ScrEditDialog.Append('CommandButton=Label=Сохранить;Action=Post;_Default=1;FontStyle=Bold;');
    ScrEditDialog.Append('CommandButton=Label=Отменить;Action=CancelClose;_Cancel=1;');
  end;

  ScrEditDialog.Append('[Fields]');
  ScrEditDialog.Append('*');

  ScrMain.Append('[Fields]');
  ScrMain.Append('*');

  If chAddMenuItem.Checked and chNewDialog.Checked then
  begin
    DM.Query1.Insert;
    ScrID:=GetGen_ID(GPT.GeneratorName);
    DM.Query1.FieldByName(GPT.NumSeqField).AsInteger:=ScrID;
    DM.Query1.FieldByName(GPT.DCLNameField).AsString:=FormCaption;
    DM.Query1.FieldByName(GPT.CommandField).AsString:=ScrName;
    DM.Query1.Post;
    AddToRole(ScrID);
  end;

  If chNewDialog.Checked then
  Begin
    DM.Query1.Insert;
    DM.Query1.FieldByName(GPT.NumSeqField).AsInteger:=GetGen_ID(GPT.GeneratorName);
    DM.Query1.FieldByName(GPT.DCLNameField).AsString:=ScrName;
    DM.Query1.FieldByName(GPT.DCLTextField).AsString:=ScrMain.Text;
    DM.Query1.Post;
  End
  Else
  Begin
    tmpScrMain:=TStringList.Create;
    tmpScrMain.Text:=DM.Query1.FieldByName(GPT.DCLTextField).AsString;
  //  tmpScrMain.Append('//-----------');
    DM.Query1.Edit;
    tmpScrMain.Insert(FindStrIndex(tmpScrMain, '[Fields]'), ScrMain.Text);
    DM.Query1.FieldByName(GPT.DCLTextField).AsString:=tmpScrMain.Text;
    DM.Query1.Post;
    tmpScrMain.Free;
  End;

  If ScrEdit.Count>0 then
  Begin
    DM.Query1.Insert;
    DM.Query1.FieldByName(GPT.NumSeqField).AsInteger:=GetGen_ID(GPT.GeneratorName);
    DM.Query1.FieldByName(GPT.DCLNameField).AsString:=ScrName+'_Edit_Scr';
    DM.Query1.FieldByName(GPT.DCLTextField).AsString:=ScrEdit.Text;
    DM.Query1.Post;
  End;

  If ScrAdd.Count>0 then
  Begin
    DM.Query1.Insert;
    DM.Query1.FieldByName(GPT.NumSeqField).AsInteger:=GetGen_ID(GPT.GeneratorName);
    DM.Query1.FieldByName(GPT.DCLNameField).AsString:=ScrName+'_Add_Scr';
    DM.Query1.FieldByName(GPT.DCLTextField).AsString:=ScrAdd.Text;
    DM.Query1.Post;
  End;

  If ScrEditDialog.Count>0 then
  Begin
    DM.Query1.Insert;
    DM.Query1.FieldByName(GPT.NumSeqField).AsInteger:=GetGen_ID(GPT.GeneratorName);
    DM.Query1.FieldByName(GPT.DCLNameField).AsString:=ScrName+'_Edit_Dlg';
    DM.Query1.FieldByName(GPT.DCLTextField).AsString:=ScrEditDialog.Text;
    DM.Query1.Post;
  End;

  Self.Close;
end;

procedure TFormDialogMaster.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  Action:=caFree;
end;

procedure TFormDialogMaster.FormCreate(Sender: TObject);
begin
  cbTables.Clear;
  DCLMainLogOn.GetTableNames(cbTables.Items);
  PageControl1.ActivePageIndex:=0;
end;

end.
