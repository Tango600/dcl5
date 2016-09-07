unit Main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, Menus, ExtCtrls, uUDL, Buttons, AddElements, StdCtrls, DB,
  DM, ScrEditor, Grids, DBGrids, Mask, DBCtrls, SlaideEditor, uDCLData,
  uDCLTypes, uDCLConst, uDCLUtils;

Const
  DvVersion='4.1.6.1';
  AppName='Friday IDE';

  CompTopStep=25;
  ElementsCount=50;
  CodeButtonWidth=50;

type
  RComponentProperties=Record
    PropName, PropType:String;
  End;

  RComponent=Record
    Caption, NameComponent, Pict, MainProp:String;
    Props:Array of RComponentProperties;
  End;

  TForm1 = class(TForm)
    Panel1: TPanel;
    MainMenu1: TMainMenu;
    N1: TMenuItem;
    StatusBar1: TStatusBar;
    PageComponentsPalette: TPageControl;
    TabSheet1: TTabSheet;
    N2: TMenuItem;
    Panel2: TPanel;
    PageControl2: TPageControl;
    tabGrid: TTabSheet;
    tabBookmark: TTabSheet;
    Splitter1: TSplitter;
    Panel3: TPanel;
    DBGrid1: TDBGrid;
    OpenDialog1: TOpenDialog;
    Panel4: TPanel;
    DBEdit1: TDBEdit;
    DBEdit2: TDBEdit;
    DBEdit3: TDBEdit;
    ListBox1: TListBox;
    PopupMenu1: TPopupMenu;
    N3: TMenuItem;
    N4: TMenuItem;
    N5: TMenuItem;
    N6: TMenuItem;
    PopupMenu2: TPopupMenu;
    N7: TMenuItem;
    N8: TMenuItem;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    DBNavigator1: TDBNavigator;
    Edit1: TEdit;
    CheckBox1: TCheckBox;
    SpeedButton1: TSpeedButton;
    TabSheet2: TTabSheet;
    Panel5: TPanel;
    mitScrRun: TMenuItem;
    N9: TMenuItem;
    N10: TMenuItem;
    N11: TMenuItem;
    N12: TMenuItem;
    mitDebug: TMenuItem;
    N13: TMenuItem;
    itmDebugState: TMenuItem;
    TabSheet3: TTabSheet;
    Panel6: TPanel;
    SpeedButton2: TSpeedButton;
    SpeedButton3: TSpeedButton;
    SpeedButton4: TSpeedButton;
    N14: TMenuItem;
    N15: TMenuItem;
    N16: TMenuItem;
    N17: TMenuItem;
    N18: TMenuItem;
    procedure N2Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure DBGrid1DblClick(Sender: TObject);
    procedure N4Click(Sender: TObject);
    procedure ListBox1KeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure Del1Click(Sender: TObject);
    procedure Enter1Click(Sender: TObject);
    procedure ListBox1DblClick(Sender: TObject);
    procedure Edit1Change(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure N3Click(Sender: TObject);
    procedure N6Click(Sender: TObject);
    procedure N7Click(Sender: TObject);
    procedure N8Click(Sender: TObject);
    procedure N9Click(Sender: TObject);
    procedure N10Click(Sender: TObject);
    procedure N11Click(Sender: TObject);
    procedure N12Click(Sender: TObject);
    procedure itmDebugStateClick(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
    procedure SpeedButton3Click(Sender: TObject);
    procedure SpeedButton4Click(Sender: TObject);
    procedure N16Click(Sender: TObject);
  private
    CF:Text;
    CodeButton:TSpeedButton;

    Procedure OpenProject(FileName: String);
    procedure FindAndInsert(FindStr, InsertStr: String; InsMode: Byte);
    function FindString(FindStr: String): Integer;
  public
    Procedure GoToScript(ScrName: String);
    Procedure ShowScrEditor(ScrId: String);
    function GetCurrentEditor: TTScrEditor;
  end;

  TAddElementButtonClick=Class
    FieldsCombo:TComboBox;
    Check:TCheckBox;
    ColorBox:TColorBox;
    PropLabel:TLabel;
    Edit:TEdit;

    procedure Click(Sender:TObject);
    procedure ParseExpr(S:RComponent);
    procedure CreateComponent(ComponentType, ComponentLabel:String; NoProps:Boolean=False);
  End;

  TModifyDirectiveComponent=class
    procedure Edit(Sender:TObject);
  End;

  TComponentDirectives=Record
    DirectivName, Value:String;
  End;

  Function GetActiveEditor: Integer;

var
  ComponentDirectives:Array of TComponentDirectives;
  SlideEditor:TfrSlideEditor;


implementation

uses
  ProjectRunForm, DialogMaster, TablePartMaster, VerForm, FieldMaster,
  uStringParams;

Var
  ComponentTop,ComponentLeft,BookmarkTop:Word;
  ModifyDirectiveComponent:TModifyDirectiveComponent;
  ComponentsPalette:Array[1..ElementsCount] of RComponent;
  AddElementButtonClick:TAddElementButtonClick;
  ComponentCount:Word;
  Bookmarks: Array[1..50] of Cardinal;
  ElementForm:TfrAddElements;

{$R *.dfm}

function CompareString(S1, S2:String; Partial, CaseSens:Boolean):Boolean;
Begin
  Case Partial of
    True:Case CaseSens of
         True:Result:=(Pos(S1, S2)<>0) or (Pos(S2, S1)<>0);
         False:Result:=(PosEx(S1, S2)<>0) or (PosEx(S2, S1)<>0);
         End;
    False:Case CaseSens of
          True:Result:=S1=S2;
          False:Result:=AnsiLowerCase(S1)=AnsiLowerCase(S2);
          End;
  End;
End;

function LocateTo(Query:TDCLDialogQuery; KeyFields, Value:string; Options: TLocateOptions):Boolean;
var
  Bookmark:TBookmark;
begin
  Bookmark:=Query.GetBookmark;
  Query.DisableControls;
  Query.First;
  Result:=False;
  while not Query.Eof do
  begin
    If CompareString(TrimRight(Query.FieldByName(KeyFields).AsString), Value, loPartialKey in Options, not (loCaseInsensitive in Options)) then
    Begin
      Result:=True;
      Break;
    End;
    Query.Next;
  end;
  if not Result then
    Query.GotoBookmark(Bookmark);
  Try
    Query.FreeBookmark(Bookmark);
  Except
    //
  End;
  Query.EnableControls;
end;

function TForm1.GetCurrentEditor: TTScrEditor;
Begin
  Result:=(ActiveMDIChild as TTScrEditor);
end;

procedure TForm1.itmDebugStateClick(Sender: TObject);
begin
  GPT.DebugOn:=not GPT.DebugOn;
  itmDebugState.Checked:=GPT.DebugOn;
end;

procedure TForm1.FindAndInsert(FindStr, InsertStr: String; InsMode: Byte);
var
  Editor: TMemo;
  textPosSerch, Y: Word;
Begin
  Editor:=nil;
  If FindStr<>'' then
  Begin
    Editor:=GetCurrentEditor.Memo1;
    textPosSerch:=0;
    While (PosEx(FindStr, Editor.Lines[textPosSerch])=0)and(textPosSerch<Editor.Lines.Count-1) do
    Begin
      Inc(textPosSerch);
    end;
    Editor.Lines.Insert(textPosSerch, InsertStr);
  end;
  Case InsMode of
  0:
  Begin
    Y:=Editor.Perform(EM_LINEFROMCHAR, Editor.SelStart, 0);
    Editor.Lines.Insert(Y, InsertStr);
  end;
  1:
  Editor.Lines.Append(InsertStr);
  2:
  Editor.Lines.Insert(0, InsertStr);
  end;
end;

function TForm1.FindString(FindStr: String): Integer;
var
  Editor: TMemo;
  textPosSerch: Integer;
  Find: Boolean;
Begin
  textPosSerch:=0;
  Find:=False;
  If FindStr<>'' then
  Begin
    Editor:=GetCurrentEditor.Memo1;
    While (AnsiLowerCase(FindStr)<>AnsiLowerCase(Editor.Lines[textPosSerch]))and(textPosSerch<Editor.Lines.Count-1) do
    Begin
      Inc(textPosSerch);
      Find:=True;
    end;
  end;
  If Find then
    Result:=textPosSerch
  Else
    Result:= - 1;
end;

Function GetFormNum: Integer;
Var
  i: Integer;
Begin
  i:=1;
  While (ScrriptEditorsForms[i].Active<>False)and(i<>MaxScriptEditors) do  Inc(i);
  Result:=i;
End;

Function GetActiveEditor: Integer;
Var
  i:Byte;
Begin
  Result:=-1;
  For i:=1 to MaxScriptEditors do
    If ScrriptEditorsForms[i].Active then
    Begin
      Result:=i;
      break;
    End;
End;

Procedure TForm1.GoToScript(ScrName: String);
begin
  If ScrName<>'' then
  Begin
    LocateTo(Query1, GPT.DCLNameField, Trim(ScrName), [loCaseInsensitive]);
    ShowScrEditor(Query1.FieldByName(GPT.NumSeqField).AsString);
  End;
end;


Procedure TForm1.ShowScrEditor(ScrId: String);
var
  fn: Byte;
Begin
  fn:=GetFormNum;
  ScrriptEditorsForms[fn].NotSaved:=False;
  ScrriptEditorsForms[fn].ScriptName:=Trim(Query1.FieldByName(GPT.DCLNameField)
    .AsString);
  ScrriptEditorsForms[fn].Form:=TTScrEditor.Create(Application);
  ScrriptEditorsForms[fn].Tag:=fn;
  ScrriptEditorsForms[fn].Form.Tag:=fn;
  ScrriptEditorsForms[fn].Form.Memo1.Tag:=fn;
  ScrriptEditorsForms[fn].Form.Button1.Tag:=fn;
  ScrriptEditorsForms[fn].Form.ScrId:=ScrId;
  ScrriptEditorsForms[fn].Form.Memo1.Text:=Query1.FieldByName(GPT.DCLTextField).AsString;
  ScrriptEditorsForms[fn].Form.Caption:=Trim(Query1.FieldByName(GPT.DCLNameField).AsString);
  ScrriptEditorsForms[fn].Active:=True;
  ScrriptEditorsForms[fn].Form.Show;
End;

procedure TForm1.SpeedButton1Click(Sender: TObject);
var
  ValS:string;
begin
  valS:=TrimRight(DM.Query1.FieldByName(GPT.CommandField).AsString);
  LocateTo(DM.Query1, GPT.DCLNameField, ValS, [loCaseInsensitive]);
end;

procedure TForm1.SpeedButton2Click(Sender: TObject);
var
  FormDialogMaster: TFormDialogMaster;
begin
  FormDialogMaster:=TFormDialogMaster.Create(Self);
  FormDialogMaster.Show;
end;

procedure TForm1.SpeedButton3Click(Sender: TObject);
var
  FormFieldMaster: TFormFieldMaster;
begin
  FormFieldMaster:=TFormFieldMaster.Create(nil);
  FormFieldMaster.Show;
end;

procedure TForm1.SpeedButton4Click(Sender: TObject);
var
  FormTPMaster: TFormTPMaster;
begin
  FormTPMaster:=TFormTPMaster.Create(Self);
  FormTPMaster.Show;
end;

procedure TModifyDirectiveComponent.Edit(Sender: TObject);
Var
  Tag:Integer;
  VarVal:String;
begin
  Tag:=(Sender as TComponent).Tag;

  If Sender is TEdit then
    VarVal:=(Sender as TEdit).Text;

  If Sender is TComboBox then
    VarVal:=(Sender as TComboBox).Text;

  If Sender is TCheckBox then
    VarVal:=IntToStr(Ord((Sender as TCheckBox).Checked));

  If Sender is TRadioButton then
    VarVal:=IntToStr(Ord((Sender as TRadioButton).Checked));

  If Sender is TColorBox then
    VarVal:='h'+IntToHex((Sender as TColorBox).Selected, 6);

  ComponentDirectives[Tag].Value:=VarVal;
end;

procedure TAddElementButtonClick.CreateComponent(ComponentType, ComponentLabel:String; NoProps:Boolean=False);
Var
  Query:TDCLDialogQuery;
Begin
  PropLabel:=TLabel.Create(ElementForm);
  PropLabel.Parent:=ElementForm;
  PropLabel.Left:=5;
  PropLabel.Caption:=ComponentLabel;
  PropLabel.Top:=ComponentTop;

  If ComponentType='D' then
  Begin
    FieldsCombo:=TComboBox.Create(ElementForm);
    FieldsCombo.Parent:=ElementForm;
    FieldsCombo.Top:=ComponentTop;
    FieldsCombo.Left:=ComponentLeft;
    FieldsCombo.Tag:=ComponentCount+1;
    FieldsCombo.OnChange:=ModifyDirectiveComponent.Edit;

    Query:=TDCLDialogQuery.Create(nil);
    DCLMainLogOn.SetDBName(Query);
    Query.SQL.Text:='select '+GPT.DCLNameField+' from '+GPT.DCLTable+' where '+
    GPT.IdentifyField+' is null and '+GPT.ParentFlgField+' is null order by '+GPT.DCLNameField;
    Query.Open;
    While not Query.Eof do
    begin
      FieldsCombo.Items.Append(Trim(Query.Fields[0].AsString));
      Query.Next;
    end;
    Query.Close;
    Query.Free;

    Inc(ComponentTop, CompTopStep);
    Inc(ComponentCount);
    SetLength(ComponentDirectives, ComponentCount+1);
  End;

  If ComponentType='B' then
  Begin
    Check:=TCheckBox.Create(ElementForm);
    Check.Parent:=ElementForm;
    Check.Top:=ComponentTop;
    Check.Left:=ComponentLeft;
    Check.Tag:=ComponentCount+1;
    Check.OnClick:=ModifyDirectiveComponent.Edit;

    Inc(ComponentTop, CompTopStep);
    Inc(ComponentCount);
    SetLength(ComponentDirectives, ComponentCount+1);
  End;

  If ComponentType='F' then
  Begin
    FieldsCombo:=TComboBox.Create(ElementForm);
    FieldsCombo.Parent:=ElementForm;
    FieldsCombo.Top:=ComponentTop;
    FieldsCombo.Left:=ComponentLeft;
    FieldsCombo.Tag:=ComponentCount+1;
    FieldsCombo.OnChange:=ModifyDirectiveComponent.Edit;

    FieldsCombo.Items.AddStrings(DM.GetFieldsList(DM.GetQueryFromDialog(GetActiveEditor)));

    Inc(ComponentTop, CompTopStep);
    Inc(ComponentCount);
    SetLength(ComponentDirectives, ComponentCount+1);
  End;

  If ComponentType='CL' then
  Begin
    ColorBox:=TColorBox.Create(ElementForm);
    ColorBox.Parent:=ElementForm;
    ColorBox.Top:=ComponentTop;
    ColorBox.Left:=ComponentLeft;
    ColorBox.Tag:=ComponentCount+1;
    ColorBox.OnChange:=ModifyDirectiveComponent.Edit;

    Inc(ComponentTop, CompTopStep);
    Inc(ComponentCount);
    SetLength(ComponentDirectives, ComponentCount+1);
  End;

  If ComponentType='S' then
  Begin
    Edit:=TEdit.Create(ElementForm);
    Edit.Parent:=ElementForm;
    Edit.Top:=ComponentTop;
    Edit.Left:=ComponentLeft;
    Edit.Tag:=ComponentCount+1;
    Edit.OnChange:=ModifyDirectiveComponent.Edit;

    Inc(ComponentTop, CompTopStep);
    Inc(ComponentCount);
    SetLength(ComponentDirectives, ComponentCount+1);
  End;
  
  If ComponentType='I' then
  Begin
    Edit:=TEdit.Create(ElementForm);
    Edit.Parent:=ElementForm;
    Edit.Width:=50;
    Edit.Top:=ComponentTop;
    Edit.Left:=ComponentLeft;
    Edit.Tag:=ComponentCount+1;
    Edit.OnChange:=ModifyDirectiveComponent.Edit;

    Inc(ComponentTop, CompTopStep);
    Inc(ComponentCount);
    SetLength(ComponentDirectives, ComponentCount+1);
  End;

  If ComponentType='SI' then
  Begin
    FieldsCombo:=TComboBox.Create(ElementForm);
    FieldsCombo.Parent:=ElementForm;
    FieldsCombo.Top:=ComponentTop;
    FieldsCombo.Left:=ComponentLeft;
    FieldsCombo.Tag:=ComponentCount+1;
    FieldsCombo.OnChange:=ModifyDirectiveComponent.Edit;

    FieldsCombo.Items.Append('=');
    FieldsCombo.Items.Append('<>');
    FieldsCombo.Items.Append('>');
    FieldsCombo.Items.Append('<');
    FieldsCombo.Items.Append('<=');
    FieldsCombo.Items.Append('>=');

    Inc(ComponentTop, CompTopStep);
    Inc(ComponentCount);
    SetLength(ComponentDirectives, ComponentCount+1);
  End;

  If not NoProps then
    ComponentDirectives[ComponentCount].DirectivName:=ComponentLabel
  Else
    ComponentDirectives[ComponentCount].DirectivName:='';

  ElementForm.Height:=ComponentTop+120;
End;

procedure TAddElementButtonClick.ParseExpr(S: RComponent);
Var
  ipos:Word;
begin
  ComponentCount:=0;
  SetLength(ComponentDirectives, 1);
  ComponentDirectives[0].DirectivName:=S.NameComponent;

  If S.MainProp<>'' then
    CreateComponent(S.MainProp, S.NameComponent, True);

  If Length(S.Props)>0 then
  Begin
    For ipos:=0 to Length(S.Props)-1 do
      CreateComponent(S.Props[ipos].PropType, S.Props[ipos].PropName);
  End;
end;

procedure TAddElementButtonClick.Click(Sender: TObject);
Var
  bn:Integer;
begin
  bn:=(Sender as TComponent).Tag;
  ComponentTop:=15;
  ComponentLeft:=100;

  If Assigned(ElementForm) then
    ElementForm.Release;

  ElementForm:=TfrAddElements.Create(Application);

  ParseExpr(ComponentsPalette[bn]);

  ElementForm.Show;
end;

Procedure TForm1.OpenProject(FileName: String);
begin
  GPT.IniFileName:=FileName;
  SetCurrentDir(Path);
  Self.Caption:=AppName+' '+DvVersion+' - '+ExtractFileName(GPT.IniFileName);
  Application.Title:=DvVersion+' - '+ExtractFileName(GPT.IniFileName);

  DBGrid1.Columns.Clear;
  DBGrid1.Columns.Add.FieldName:=GPT.DCLNameField;
  DBGrid1.Columns[DBGrid1.Columns.Count-1].Title.Caption:='Ñêðèïò';

  Query1.SQL.Text:='select * from '+GPT.DCLTable+' order by '+GPT.DCLNameField;
  Query1.Open;
  DBEdit1.DataField:=GPT.IdentifyField;
  DBEdit2.DataField:=GPT.CommandField;
  DBEdit3.DataField:=GPT.ParentFlgField;

  ListBox1.Clear;
  If FileExists(Path+'Bookmarks.bmk') then
    ListBox1.Items.LoadFromFile(Path+'Bookmarks.bmk');
  // BookmarkTop:=Form4.ListBox1.Count;
  // CreateObjectsTree;
  itmDebugState.Checked:=GPT.DebugOn;
End;

Function CopyCut(var S: String; From, Count: Word): String;
Begin
  Result:=Copy(S, From, Count);
  Delete(S, From, Count);
End;

procedure TForm1.FormCreate(Sender: TObject);
Var
  S,S1,pp:String;
  i,j,k,DelimPos:Word;
begin
  PageComponentsPalette.ActivePageIndex:=0;

  If FileExists('Components\Components.cmp') then
  Begin
    AssignFile(CF, 'Components\Components.cmp');
    Reset(CF);

    i:=0;
    While not EOF(CF) do
    Begin
      Inc(i);
      ReadLn(CF, S);
      DelimPos:=Pos('|', S);
      S1:=Copy(S, 1, DelimPos-1);
      Delete(S, 1, DelimPos);
      ComponentsPalette[i].Caption:=S1;

      CodeButton:=TSpeedButton.Create(Panel2);
      CodeButton.Parent:=Panel2;
      CodeButton.Tag:=i;
      CodeButton.Align:=alLeft;
      CodeButton.Width:=CodeButtonWidth;
      CodeButton.ShowHint:=True;
      CodeButton.Hint:=S1;
      CodeButton.OnClick:=AddElementButtonClick.Click;

      DelimPos:=Pos('|', S);
      S1:=Copy(S, 1, DelimPos-1);
      Delete(S, 1, DelimPos);

      ComponentsPalette[i].MainProp:='';
      If Pos('=', S1)=0 then
        ComponentsPalette[i].NameComponent:=S1
      Else
      Begin
        ComponentsPalette[i].NameComponent:=CopyCut(S1, 1, Pos('=', S1)-1);
        ComponentsPalette[i].MainProp:=Copy(S1, 2, Length(S1)-1);
      End;

      DelimPos:=Pos('|', S);
      S1:=Copy(S, 1, DelimPos-1);
      Delete(S, 1, DelimPos);

      k:=ParamsCount(S1, ';', '');
      For j:=1 to k do
      Begin
        pp:=SortParams(S1, j, ';');
        If pp<>'' then
        Begin
          SetLength(ComponentsPalette[i].Props, j);

          ComponentsPalette[i].Props[j-1].PropName:=CopyCut(pp, 1, Pos('=', pp)-1);
          ComponentsPalette[i].Props[j-1].PropType:=Copy(pp, 2, Length(pp));
        End;
      End;

      If FileExists('Components\'+S) then
        CodeButton.Glyph.LoadFromFile('Components\'+S);
    End;

    CloseFile(CF);
  End;

  OpenProject(GPT.IniFileName);

  GPT.DisableFieldsList:=True;
  GPT.DialogsSettings:=False;
end;

procedure TForm1.Del1Click(Sender: TObject);
var
  i: Word;
Begin
  i:=ListBox1.ItemIndex;
  ListBox1.Items.Delete(i);
  Dec(BookmarkTop);
  For i:=1 to BookmarkTop+1 do
    Bookmarks[BookmarkTop]:=Bookmarks[BookmarkTop+1];
  ListBox1.Items.SaveToFile(Path+'Bookmarks.bmk');
end;

procedure TForm1.Edit1Change(Sender: TObject);
begin
    If Edit1.Text<>'' then
    Begin
      If CheckBox1.Checked then
        Query1.SQL.Text:='select * from '+GPT.DCLTable+' where upper('+
          GPT.DCLNameField+') like upper('''+Edit1.Text+'%'')'
      Else
        Query1.Locate(GPT.DCLNameField, Edit1.Text, [loCaseInsensitive, loPartialKey]);
    end
    Else If CheckBox1.Checked then
    Begin
      Query1.SQL.Text:='select * from '+GPT.DCLTable;
      Query1.Open;
    End;
end;

procedure TForm1.Enter1Click(Sender: TObject);
Begin
  ListBox1DblClick(ListBox1);
end;

procedure TForm1.ListBox1DblClick(Sender: TObject);
var
  j, i: Word;
  St, St1:String;
Begin
  If GPT.NumSeqField<>'' then
  Begin
    St:=ListBox1.Items[ListBox1.ItemIndex];
    i:=Length(St);
    j:=1;
    While (St[j]<>'\')and(i<>j) do
      Inc(j);
    St1:='';
    For i:=1 to j-1 do
      St1:=St1+St[i];

    Query1.Locate(GPT.NumSeqField, Trim(St1), [loCaseInsensitive]);
    PageControl2.TabIndex:=0;
  end;
end;

procedure TForm1.ListBox1KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  If Key=46 then
    Del1Click(ListBox1);
  If Key=13 then
    Enter1Click(ListBox1);
end;

procedure TForm1.N10Click(Sender: TObject);
begin
  ProjectPreviewForm:=TProjectPreviewForm.Create(Application);
  ProjectPreviewForm.Show;
  GPT.DialogsSettings:=False;
  GPT.DisableFieldsList:=True;
  DCLMainLogOn.CreateMenu(ProjectPreviewForm);
  GPT.DialogsSettings:=False;
  GPT.DisableFieldsList:=True;
end;

procedure TForm1.N11Click(Sender: TObject);
begin
  Sleep(500);
  uDCLUtils.ExecApp('DCLRun.exe "'+GPT.IniFileName+'"');
end;

procedure TForm1.N12Click(Sender: TObject);
var
  OPL1: TStringList;
  EditorNum:Integer;
Begin
  OPL1:=TStringList.Create;
  If EditorNum<>-1 then
    OPL1.Text:=ScrriptEditorsForms[EditorNum].Form.Memo1.Text
  Else
    OPL1.Text:=DM.Query1.FieldByName(GPT.DCLTextField).AsString;

  OPL1.Insert(0, 'script type=command;');

  GPT.DialogsSettings:=False;
  GPT.DisableFieldsList:=True;

  //CommandParser(TrimRight(OPL1.Text), False);  !!!!
  OPL1.Free;
end;

procedure TForm1.N16Click(Sender: TObject);
var
  frVerInfo: TfrVerInfo;
begin
  frVerInfo:=TfrVerInfo.Create(nil);
  frVerInfo.Show;

end;

procedure TForm1.N2Click(Sender: TObject);
begin
  If OpenDialog1.Execute then
    OpenProject(OpenDialog1.FileName);
end;

procedure TForm1.N3Click(Sender: TObject);
begin
  ShowScrEditor(Query1.FieldByName(GPT.NumSeqField).AsString);
end;

procedure TForm1.N4Click(Sender: TObject);
begin
  If not Assigned(SlideEditor) then
  Begin
    SlideEditor:=TfrSlideEditor.Create(Application);

    SlideEditor.Memo1.DataField:=GPT.DCLTextField;
    SlideEditor.Show;
  end;
end;

procedure TForm1.N6Click(Sender: TObject);
begin
  If GPT.NumSeqField<>'' then
  begin
    Inc(BookmarkTop);
    Bookmarks[BookmarkTop]:=DM.Query1.FieldByName(GPT.NumSeqField).AsInteger;
    ListBox1.Items.Append(DM.Query1.FieldByName(GPT.NumSeqField).AsString+' \ '+
      DM.Query1.FieldByName(GPT.DCLNameField).AsString);
    ListBox1.Items.SaveToFile(Path+'Bookmarks.bmk');
  end;
end;

procedure TForm1.N7Click(Sender: TObject);
begin
  ListBox1DblClick(ListBox1);
end;

procedure TForm1.N8Click(Sender: TObject);
Var
  i:Word;
begin
  i:=ListBox1.ItemIndex;
  ListBox1.Items.Delete(i);
  Dec(BookmarkTop);
  For i:=1 to BookmarkTop+1 do
    Bookmarks[BookmarkTop]:=Bookmarks[BookmarkTop+1];
  ListBox1.Items.SaveToFile(Path+'Bookmarks.bmk');
end;

procedure TForm1.N9Click(Sender: TObject);
var
  OPL1: TStringList;
  EditorNum:Integer;
Begin
  OPL1:=TStringList.Create;
  EditorNum:=GetActiveEditor;

  If EditorNum<>-1 then
    OPL1.Text:=ScrriptEditorsForms[EditorNum].Form.Memo1.Text
  Else
    OPL1.Text:=DM.Query1.FieldByName(GPT.DCLTextField).AsString;

  GPT.DialogsSettings:=False;
  GPT.DisableFieldsList:=True;
  DCLMainLogOn.CreateForm(GPT.DCLNameField, nil, nil, nil, nil, False, chmNone, nil, OPL1);
  OPL1.Free;
end;

procedure TForm1.DBGrid1DblClick(Sender: TObject);
begin
  ShowScrEditor(Query1.FieldByName(GPT.NumSeqField).AsString);
end;

end.
