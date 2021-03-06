program DCLReports;
{$I DefineType.pas}

uses
  {$IFDEF FPC}
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces,
  {$IFDEF IBX}
   ibexpress,
  {$ENDIF}
  {$IFDEF ZEOS}
  zcomponent,
  {$ENDIF}
  {$ENDIF}
  Forms,
  {$IFNDEF FPC}
  {$IFDEF VCLFIX}
  VCLFixPack in 'VCLFixPack.pas',
  ControlsAtomFix in 'ControlsAtomFix.pas',
  {$ENDIF}
  {$IFDEF ThemedDBGrid}
  ThemedDBGrid in 'ThemedDBGrid.pas',
  {$ENDIF}
  {$IFDEF IBX}
  {$ENDIF}
  {$IFNDEF NEWDELPHI}
  DBCtrls in 'units\DBCtrls.pas',
  DBGrids in 'units\DBGrids.pas',
  {$ELSE}
  DBCtrls in 'unitsXE\DBCtrls.pas',
  DBGrids in 'unitsXE\DBGrids.pas',
  {$ENDIF}
  {$ENDIF}
  fReport in 'fReport.pas' {MainForm},
  uUDL in 'uUDL.pas',
  uStringParams in 'uStringParams.pas',
  uDCLData in 'uDCLData.pas',
  uDCLConst in 'uDCLConst.pas',
  uDCLNetUtils in 'uDCLNetUtils.pas',
  uDCLUtils in 'uDCLUtils.pas',
  uDCLTypes in 'uDCLTypes.pas',
  SumProps in 'SumProps.pas',
  uDCLMessageForm in 'uDCLMessageForm.pas',
  uDCLDBUtils in 'uDCLDBUtils.pas',
  uDCLOLE in 'uDCLOLE.pas',
  uDCLMultiLang in 'uDCLMultiLang.pas',
  uDCLOfficeUtils in 'uDCLOfficeUtils.pas',
  uLogging in 'uLogging.pas',
  uDCLResources in 'uDCLResources.pas',
  uDCLSQLMonitor in 'uDCLSQLMonitor.pas',
  uDCLDownloader in 'uDCLDownloader.pas',
  {$IFDEF MSWINDOWS}
  uOpenOffice In 'uOpenOffice.pas',
  uOfficeDocs in 'uOfficeDocs.pas',
  {$ENDIF}
  uLZW in 'uLZW.pas',
  FileBuffer in 'FileBuffer.pas',
  uDCLQuery in 'uDCLQuery.pas';

{$R DCLReports.res}

var
  MainForm: TMainForm;

begin
  {$IFDEF FPC}
  RequireDerivedFormResource := True;
  {$ENDIF}
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;

  EndDCL;
end.
