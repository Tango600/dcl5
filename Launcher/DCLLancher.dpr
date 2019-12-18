program DCLLancher;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

uses
{$IFDEF FPC}
  Interfaces,
{$ENDIF}
  Forms, Main in 'Main.pas' {Form1},
  Add in 'Add.pas' {Form2};

var
  Form1: TForm1;
  fAddBase: TfAddBase;


{$R *.res}

begin
  Application.Scaled:=True;
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TfAddBase, fAddBase);
  Application.Run;
end.
