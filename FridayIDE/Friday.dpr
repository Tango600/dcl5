program Friday;

uses
  Forms,
  Main in 'Main.pas' {Form1},
  uUDL in 'uUDL.pas',
  AddElements in 'AddElements.pas' {frAddElements},
  ScrEditor in 'ScrEditor.pas' {TScrEditor},
  DM in 'DM.pas' {DataModule1: TDataModule},
  SlaideEditor in 'SlaideEditor.pas' {frSlideEditor},
  ProjectRunForm in 'ProjectRunForm.pas' {ProjectPreviewForm},
  ValVariables in 'ValVariables.pas' {Form26},
  EditValVars in 'EditValVars.pas' {Form27},
  DialogMaster in 'DialogMaster.pas' {FormDialogMaster},
  FieldMaster in 'FieldMaster.pas' {FormFieldMaster},
  TablePartMaster in 'TablePartMaster.pas' {FormTPMaster},
  VerForm in 'VerForm.pas' {frVerInfo};

{$R *.res}

var
  Form1: TForm1;
  DataModule1: TDataModule1;

begin
  Application.Initialize;
  Application.CreateForm(TDataModule1, DataModule1);
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
