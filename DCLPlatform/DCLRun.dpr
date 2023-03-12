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
  uIBUpdateSQLW,
  {$ENDIF}
  {$IFDEF ZEOS}
  zcomponent,
  {$ENDIF}
  {$ENDIF}
  Forms,
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
  uLZW in 'uLZW.pas',
  FileBuffer in 'FileBuffer.pas',
  uDCLQuery in 'uDCLQuery.pas',
  {$IFNDEF FPC}
  {$IFDEF USEDELPHIThemes}
  Vcl.Themes,
  Vcl.Styles,
  {$ENDIF}{$ENDIF}
  uLogging, uDCLMD5;

{$R DCLRun.res}

var
  MainForm: TMainForm;

begin
  {$IFDEF FPC}
  RequireDerivedFormResource:=True;
  {$ENDIF}
  Application.Scaled:=True;
  Application.Initialize;
  {$IFDEF MSWINDOWS}
  Application.MainFormOnTaskbar:=True;
  Application.UpdateFormatSettings:=False;
  {$ENDIF}
  {$IFNDEF FPC}{$IFDEF USEDELPHIThemes}
  TStyleManager.TrySetStyle('Smokey Quartz Kamri');
  {$ENDIF}{$ENDIF}
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
