program DCLReports;
{$IFDEF FPC}
  {$mode objfpc}{$H+}
{$ENDIF}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  {$IFDEF FPC}
  Interfaces,
  {$ENDIF}
  Forms,
  {$IFNDEF FPC}
  DBCtrls in 'units\DBCtrls.pas',
  DBGrids in 'units\DBGrids.pas',
  {$ENDIF}
  fReport in 'fReport.pas' {MainForm},
  FileBuffer in 'FileBuffer.pas',
  SumProps in 'SumProps.pas',
  uDCLConst in 'uDCLConst.pas',
  uDCLData in 'uDCLData.pas',
  uDCLDBUtils in 'uDCLDBUtils.pas',
  uDCLDownloader in 'uDCLDownloader.pas',
  uDCLMessageForm in 'uDCLMessageForm.pas',
  uDCLOfficeUtils in 'uDCLOfficeUtils.pas',
  uDCLOLE in 'uDCLOLE.pas',
  uDCLQuery in 'uDCLQuery.pas',
  uDCLResources in 'uDCLResources.pas',
  uDCLSQLMonitor in 'uDCLSQLMonitor.pas',
  uDCLStringsRes in 'uDCLStringsRes.pas',
  uDCLTypes in 'uDCLTypes.pas',
  uDCLUtils in 'uDCLUtils.pas',
  uGlass in 'uGlass.pas',
  uLogging in 'uLogging.pas',
  uLZW in 'uLZW.pas',
  uOfficeDocs in 'uOfficeDocs.pas',
  uOpenOffice in 'uOpenOffice.pas',
  uStringParams in 'uStringParams.pas',
  uUDL in 'uUDL.pas';

{$R *.res}

var
  MainForm: TMainForm;

begin
  {$IFDEF FPC}
  RequireDerivedFormResource := True;
  {$ENDIF}
  Application.Title := 'DCL Reports v.'+Version;
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;

  EndDCL;
end.
