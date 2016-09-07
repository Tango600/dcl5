unit FieldMaster;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, StdCtrls, ExtCtrls, Spin;

type
  RDirectives=record
    Capt, Val:string;
  end;

  TFormFieldMaster = class(TForm)
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    leFieldCapt: TLabeledEdit;
    ComboBox1: TComboBox;
    Label1: TLabel;
    chWoData: TCheckBox;
    lbl1: TLabel;
    se1: TSpinEdit;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    CompTop, CompLeft:Word;
    ComponentsDirective:array of RDirectives;
    PropEdit:TLabeledEdit;
    procedure CreateComponent(Sender:TObject; Num:Byte);
  public
    { Public declarations }
  end;


implementation

uses
  uUDL, uStringParams;

{$R *.dfm}

procedure TFormFieldMaster.CreateComponent(Sender:TObject; Num:Byte);
begin
  PropEdit:=TLabeledEdit.Create(Self);
//  PropEdit.Parent:=
//  Inc(CompTop, 21);
//  CompLeft
end;

procedure TFormFieldMaster.FormCreate(Sender: TObject);
var
  T:TextFile;
  S, S1, PCapt, PStr:string;
  i:Byte;
begin
  if FileExists('Components\Fields.fls') then
  Begin
    AssignFile(T, 'Components\Fields.fls');
    Reset(T);

    while not Eof(T) do
    begin
      Readln(T, S);
      for i:=1 to ParamsCount(S, '|') do
      Begin
        S1:=SortParams(S, i, '|');
        if Pos('=', S1)<>0 then
        Begin
          PCapt:=Copy(S1, 1, Pos('=', S1)-1);
          PStr:=Copy(S1, Pos('=', S1)+1, Length(S1));
        end
        else
        begin
          PCapt:=S1;
        end;
      end;
    end;


    CloseFile(T);
  end;
end;

procedure TFormFieldMaster.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  Action:=caFree;
end;

end.
