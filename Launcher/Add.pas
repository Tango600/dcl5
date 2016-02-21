unit Add;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

interface

uses
{$IFnDEF FPC}
  Windows,
{$ELSE}
  LCLIntf, LCLType, LMessages,
{$ENDIF}
  Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, ExtCtrls, ComCtrls, uBaseesStorage;

type

  { TfAddBase }

  TfAddBase=class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    StatusBar1: TStatusBar;
    leNameBase: TLabeledEdit;
    lePathIni: TLabeledEdit;
    SpeedButton1: TSpeedButton;
    btOK: TButton;
    bkCancel: TButton;
    OpenDialog1: TOpenDialog;
    leParams: TLabeledEdit;
    procedure btOKClick(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure bkCancelClick(Sender: TObject);
  private
    Params:RBaseParams;
  public
    EditMode: TEditActions;
    BaseName: String;
  end;


implementation


{$R *.dfm}

procedure TfAddBase.btOKClick(Sender: TObject);
begin
  Case EditMode of
  teaAdding:Begin
    Params.Title:=leNameBase.Text;
    Params.IniPath:=lePathIni.Text;
    Params.Params:=leParams.Text;
    Params.UID:='';

    AddBaseToIni(Path+'Bases.ini', Params);
  End;
  teaEditing:Begin
    Params.Title:=leNameBase.Text;
    Params.IniPath:=lePathIni.Text;
    Params.Params:=leParams.Text;
    Params.UID:='';

    EditBaseIni(Path+'Bases.ini', Params);
  End;
  End;
  Self.Close;
end;

procedure TfAddBase.SpeedButton1Click(Sender: TObject);
begin
  If OpenDialog1.Execute then
    lePathIni.Text:=OpenDialog1.FileName;
end;

procedure TfAddBase.FormShow(Sender: TObject);
begin
  Case EditMode of
  teaAdding:Begin
  leNameBase.Clear;
  lePathIni.Clear;
  leParams.Clear;
  End;
  teaEditing:Begin
  Params:=GetSection(Path+'Bases.ini', BaseName);
  leNameBase.Text:=Params.Title;
  lePathIni.Text:=Params.IniPath;
  leParams.Text:=Params.Params;
  End;
  End;
  leNameBase.SetFocus;
end;

procedure TfAddBase.bkCancelClick(Sender: TObject);
begin
  Self.Close;
end;


end.
