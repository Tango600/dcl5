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
  {$ENDIF}
  {$IFDEF FPC}
  DBCtrls,
  DBGrids,
  {$ELSE}
  Vcl.DBCtrls in 'units\Vcl.DBCtrls.pas',
  Vcl.DBGrids in 'units\Vcl.DBGrids.pas',
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
  Vcl.Themes,
  Vcl.Styles,
  {$ENDIF}
  uLogging in 'uLogging.pas';

{$R DCLRun.res}

var
  MainForm: TMainForm;

begin
  {$IFDEF FPC}
  ///RequireDerivedFormResource:=True;
  {$ENDIF}
  Application.Initialize;
  Application.MainFormOnTaskbar:=True;
  {$IFDEF USEDELPHIThemes}
  TStyleManager.TrySetStyle('Smokey Quartz Kamri');
  {$ENDIF}
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
