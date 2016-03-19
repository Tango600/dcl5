program DCLRun;
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
  {$IFnDEF USEDELPHIThemes}
  {$IFDEF ThemedDBGrid}
  ThemedDBGrid in 'ThemedDBGrid.pas',
  {$ENDIF}
  {$ENDIF}
  {$IFNDEF NEWDELPHI}
  {$IFDEF IBX}
  IBHeader in 'units\IBHeader.pas',
  IBSQL in 'units\IBSQL.pas',
  {$ENDIF}
  DBCtrls in 'units\DBCtrls.pas',
  DBGrids in 'units\DBGrids.pas',
  {$ELSE}
  {$IFDEF IBX}
  IBX.IBHeader in 'unitsXE\IBX.IBHeader.pas',
  IBX.IBSQL in 'unitsXE\IBX.IBSQL.pas',
  {$ENDIF}
  Vcl.DBCtrls in 'unitsXE\Vcl.DBCtrls.pas',
  Vcl.DBGrids in 'unitsXE\Vcl.DBGrids.pas',
  {$ENDIF}
  {$ENDIF}
  fMainForm in 'fMainForm.pas' {MainForm},
  uUDL in 'uUDL.pas',
  uStringParams in 'uStringParams.pas',
  uDCLData in 'uDCLData.pas',
  uDCLConst in 'uDCLConst.pas',
  uDCLUtils in 'uDCLUtils.pas',
  uDCLNetUtils in 'uDCLNetUtils.pas',
  uDCLTypes in 'uDCLTypes.pas',
  SumProps in 'SumProps.pas',
  uDCLMessageForm in 'uDCLMessageForm.pas',
  uDCLDBUtils in 'uDCLDBUtils.pas',
  uDCLOLE in 'uDCLOLE.pas',
  uDCLMultiLang in 'uDCLMultiLang.pas',
  uDCLOfficeUtils in 'uDCLOfficeUtils.pas',
  uDCLResources in 'uDCLResources.pas',
  uDCLSQLMonitor in 'uDCLSQLMonitor.pas',
  uDCLDownloader in 'uDCLDownloader.pas',
  {$IFDEF MSWINDOWS}
  uOpenOffice In 'uOpenOffice.pas',
  uOfficeDocs in 'uOfficeDocs.pas',
  {$ENDIF}
  uLZW in 'uLZW.pas',
  FileBuffer in 'FileBuffer.pas',
  uDCLQuery in 'uDCLQuery.pas',
  {$IFDEF USEDELPHIThemes}
  {$IFDEF NEWDELPHI}
  Vcl.Themes,
  Vcl.Styles,
  {$ENDIF}
  {$ENDIF}
  uLogging in 'uLogging.pas';

{$R DCLRun.res}

var
  MainForm: TMainForm;

begin
  {$IFDEF FPC}
  RequireDerivedFormResource := True;
  {$ENDIF}
  Application.Initialize;
  {$IFDEF USEDELPHIThemes}
  {$IFDEF NEWDELPHI}
  TStyleManager.TrySetStyle('Silver');
  {$ENDIF}
  {$ENDIF}
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
