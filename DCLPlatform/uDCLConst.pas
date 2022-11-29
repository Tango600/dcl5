unit uDCLConst;
{$I DefineType.pas}

interface

uses
{$IFDEF FPC}
  LConvEncoding,
{$ENDIF}
{$IFnDEF FPC}
  Vcl.DBCtrls, Vcl.DBGrids,
{$ELSE}
  DBCtrls, DBGrids,
{$ENDIF}
  uStringParams;

const
{$IFDEF MSWINDOWS}
DefaultLibraryLocation='gds32.dll';
{$ENDIF}
{$IFDEF UNIX}
DefaultLibraryLocation='libfbclient.so';
{$ENDIF}
{$IFDEF ADO}
  DBEngineType='ADODB (Universal)';
{$ENDIF}
{$IFDEF IBX}
  DBEngineType='IBX';
{$ENDIF}
{$IFDEF ZEOS}
  DBEngineType='ZEOS (Universal)';
  DefaultIBPort=3050;
  DefaultDBType='firebird-3.0';
  DefaultDBTInterBaseType='interbase-6';
{$ENDIF}
{$IFDEF SQLdbIB}
  DBEngineType='SQLdb IB';
{$ENDIF}
{$IFDEF SQLdb}
  DBEngineType='SQLdb (Universal)';
{$ENDIF}
  Ver='10.3.0.3';
  VersionS='$VersionSignature$'+Ver+'$';

  CompotableVersion='9.1.129.309';

  JPEGCompressionQuality=85;

  EditWidth=230;
  {$IFDEF FPC}
  CalendarWidth=95;
  DateBoxWidth=95;
  {$ELSE}
  CalendarWidth=85;
  DateBoxWidth=85;
  {$ENDIF}
  DateTimeBoxWidth=110;
  DigitEditWidth=80;
  GetValueEditWidth=181;
  GetValueButtonGeom=22;
  FilterWidth=150;
  GrabComponentsWidth=200;
  GroupToolButtonTop=4;
  GroupToolButtonHeight=23;
  GroupButtonPanelHeight=GroupToolButtonHeight+GroupToolButtonTop*2;
  MemoWidth=250;
  MemoHeight=120;
  GraficWidth=166;
  GraficHeight=160;
  GroupHeight=160;
  CheckWidth=20;
  TablePartHeight=250;
  RollHeight=33;
  NavigatorHeight=25;

  MaxAllFieldsHeight=400;
  MaxAllFieldsWidth=600;

  LoginButtonWidth=75;
  LogOnFormControlsLeft=60;

  ToolLeftInterval=15;

{$IFDEF FPC}
  CalendarLeft={$IFDEF ZVComponents}25{$ELSE}15{$ENDIF};
  {$IFDEF LINUX}
  AddHeight=203;
  {$ELSE}
  AddHeight=20;
  {$ENDIF}
  DateBoxAddWidth={$IFDEF ZVComponents}20{$ELSE}30{$ENDIF};
{$ELSE}
  AddHeight=0;
  CalendarLeft=15;
  DateBoxAddWidth=0;
{$ENDIF}
  ToolButtonPanelHeight=29;
  ToolButtonHeight=25;
  ToolButtonsFlat=False;

  BeginStepLeft=15;
  BeginStepTop=25;

  ButtonWidth=90;
  ButtonHeight=25;
  ButtonsInLine=8;

  ButtonsInterval=10;
  LabelHeight=15;
  FilterLabelTop=7;
  FilterTop=FilterLabelTop+LabelHeight;

  ColumnsLongerThis=1000;
  DefaultColumnSize=350;

  BevelWidth=4;
  EditHeight=21;
  LabelTopInterval=4;
  ButtonsTop=12;
  ButtonsParagrapDown=11;
  IncPanelHeight=ButtonHeight+ButtonsParagrapDown;
  ButtonPanelHeight=ButtonsTop+IncPanelHeight;
  FullButtonWidth=ButtonWidth+ButtonsInterval;
  ButtonLeftLimit=FullButtonWidth*ButtonsInLine;
  NotCheckHeight=8;
  ToolPanelHeight=FilterTop+EditHeight+LabelHeight+LabelTopInterval+NotCheckHeight;

  FieldDownStep=LabelHeight+LabelTopInterval;
  EditTopStep=EditHeight+FieldDownStep;
  LookupTableHeight=145;
  LookupTableStepTop=LookupTableHeight+FieldDownStep;
  GraficTopStep=GraficHeight+FieldDownStep;
  GroupTopStep=GroupHeight+FieldDownStep;
  CheckStepTop=LabelHeight+LabelTopInterval+16;
  FieldsStepLeft=17;
  TablePartButtonLeft=10;
  TablePartButtonTop=5;
  TablePartButtonStep=10;
  TablePartButtonWidth=75;
  TablePartButtonHeight=24;
  FormPanelHeight=25;
  FormPanelButtonHeight=FormPanelHeight-5;
  FormPanelButtonWidth=85;
  ToolPagePanelHeight=TablePartButtonHeight+TablePartButtonTop*2;
  PanelButtonTextRight=3;
{$IFDEF UNIX}
  AddSummGridHeight=20;
{$ELSE}
  AddSummGridHeight=0;
{$ENDIF}
  SummGridHeight=27+AddSummGridHeight;
  SumPanelHeight=150;

  DefaultFormHeight=MaxAllFieldsHeight+ToolButtonPanelHeight+ButtonPanelHeight;
  DefaultFormWidth=MaxAllFieldsWidth+10;

  CharWidth=7;

  TextScriptFileExt='.dst';
  SignedScriptExt='.dcs';
  SignMethodVer='1.2';

  DBTypeFirebird='firebird';
  DBTypeInterbase='interbase';

  UserAdminField='ACCESSLEVEL';

  DCL_TablePrefix='DCL_';

  INITable=DCL_TablePrefix+'INI_PROFILES';
  IniKeyField='INI_ID';
  IniUserFieldName='INI_USER_ID';
  IniDialogNameField='INI_DIALOG_NAME';
  IniParamValField='INI_PARAM_VALUE';

  RolesTable=DCL_TablePrefix+'ROLES';
  RolesMenuTable=DCL_TablePrefix+'ROLESMENU';
  UsersTable=DCL_TablePrefix+'USERS';
  RolesIDFiled='RolesID';
  RolesMenuIDFiled='RoleID';
  RoleNameField='RoleName';
  LongRoleNameField='LONGROLENAME';
  RoleMenuItemIDField='MenuItemID';

  UserNameField=DCL_TablePrefix+'USER_NAME';
  UserIDField='UID';
  LongUserNameField='DCL_LONG_USER_NAME';
  UserPassField='DCL_USER_PASS';
  DBUSER_NAME_Field='DBUSER_NAME';
  DBPASS_Field='DBPASS';
  UserRoleField='DCL_ROLE';
  DCLROLE_ACCESSLEVEL_FIELD='ROLE_ACCESSLEVEL';

  RolesToUsersTable=DCL_TablePrefix+'ROLES_TO_USERS';
  RolesToUsersUserIDField='ru_userid';
  RolesToUsersRoleIDField='ru_roleid';

  AU_MAC='ACTIVE_USER_MAC';
  UL_MAC='UL_MAC';

  ScriptControlLanguage='VBScript';

  UserLevelsSet='ulDeny,ulReadOnly,ulWrite,ulExecute,ulLevel,ulDeveloper';

  SW_SHOWNORMAL=1;

{$IFDEF FPC}
  InternalAppNameSuffix='FPC';
  IndicatorWidth=12;

  AppBuildDate={$I %DATE%};
  fpcVersion={$I %FPCVERSION%};
  TargetCPU={$I %FPCTARGETCPU%};
  TargetOS={$I %FPCTARGETOS%};
{$ENDIF}
{$IFDEF DELPHI}
  InternalAppNameSuffix='Delphi';
{$IFDEF MSWINDOWS}
  LineEnding=#13#10;
{$ENDIF}
{$IFDEF WIN32}
  TargetCPU='i386';
{$ENDIF}
{$IFDEF WIN64}
  TargetCPU='x86-64';
{$ENDIF}
{$ENDIF}
  CR=LineEnding;
{$IFDEF UNIX}
  CrossDelim='\';
  PathDelim='/';
  ConfigDir='/.config/';
  OSType='posix';
{$ENDIF}
{$IFNDEF FPC}
{$IFDEF WIN32}
  TargetOS='Windows x32';
{$ENDIF}
{$IFDEF WIN64}
  TargetOS='Windows x64';
{$ENDIF}
{$ENDIF}
{$IFDEF MSWINDOWS}
  CrossDelim='/';
  PathDelim='\';
  ConfigDir='\';
  OSType='windows';
{$ENDIF}
{$IFDEF FPC}
  GridAlternateColor=$76DDFC;
  VK_SHIFT=16;
  VK_CONTROL=17;

  SW_SHOWNOACTIVATE=4;
  SW_NORMAL=1;
  SW_RESTORE=9;
  SW_SHOW=5;
{$ENDIF}
  MemFileName='DCL_Run_Unit_'+DBEngineType;

{$IFDEF DELPHI}
  EncodingUTF8='utf8';
  UTF8BOM=#$EF#$BB#$BF;
  UTF16LEBOM=#$FF#$FE;
  DefaultInterfaceEncoding='utf8';
{$ENDIF}
{$IFDEF FPC}
  DefaultInterfaceEncoding=EncodingUTF8;
{$ENDIF}
  InternalAppName='DCLPlatform_'+InternalAppNameSuffix;

  PAGSignatureSize=3;
  PAGSignature=$474150;
  ParamPrefix=':';
  FieldObjectPrefix='$';
  VariablePrefix='&';
  ParamsSepareteSimb=';';
  // DefaultValuesSeparator=',';
  // DefaultParamDelim='"';
  ProcPrefix='!!';
  MaskPassChar='#';
  ParamDelim='"';
  TabSize=2;

  FloatDelimiterFrom=',';
  FloatDelimiterTo='.';
  Quote=#39;

  /// Math
  AllOperands='*^/+-';

  PriorytestOperandsCount=5;
  PriorytestOperands: Array [1..PriorytestOperandsCount] Of String=('*', '^', '/', 'div', 'mod');
  SerialOperands='+-';
  Digits='0123456789.,';
  /// Math

  StopSimbols=DefaultParamsSeparator+DefaultValuesSeparator+DefaultParamDelim+'( )[],=\/+-^<>.%:;&$#@*'#39#10#13;

  KillerTimerInterval=400;
  IntervalTimeToInitScripts=700;
  IntervalTimeNotify=61007;
  TimeToTerminate=5000;
  ExitTime=30;
  AutoResfreshInterval=90*1000;

  MainFormName='MainForm';

  NavigatorEditButtons=[nbEdit, nbDelete, nbInsert, nbPost, nbCancel];
  NavigatorNavigateButtons=[nbFirst, nbLast, nbRefresh];

  DefaultNavigButtonsSet='First,Last,Edit,Delete,Insert,Post,Cancel,Refresh';

  DCLDir='DCL5'+PathDelim;
  DBFormName='DBForm';
  DefaultTimeSeparator=':';
  DefaultDateSeparator='.';
  DefaultDateFormat='dd'+DefaultDateSeparator+'mm'+DefaultDateSeparator+'yyyy';
  DefaultTimeFormat='hh'+DefaultTimeSeparator+'mm'+DefaultTimeSeparator+'ss';
  DefaultTimeStampFormat=DefaultDateFormat+' '+DefaultTimeFormat;

  StopFilterFlg=-1;

  ToolCommandsCount=3;
  ToolButtonsCmd: Array [1..ToolCommandsCount] Of String=('structure', 'print', 'find');

  QCount=20;
  PCount=40;
  KeyMarksItems=3;

  ScrDataBlockWidth=80;

Type
  TReliseStatus=(rsAlpha, rsBetta, rsPreRelase, rsUnstable, rsStable);
  TUserLevelsType=(ulDeny, ulReadOnly, ulWrite, ulExecute, ulLevel1, ulLevel2, ulLevel3, ulLevel4,
    ulDeveloper, ulUndefined);
  TPageType=(ptMainPage, ptTablePart);
  TDataControlType=(dctFields, dctFieldsStep, dctMainGrid, dctSideGrid, dctTablePart, dctLookupGrid);

  TNotAllowedOperations=(dsoNone, dsoDelete, dsoInsert, dsoEdit);

  TLogOnStatus=(lsUnInitaliced, lsLogonOK, lsRejected, lsNotNeed);
  TPassStatus=(psNone, psConfirmed, psCanceled);
  TFormsNotifyAction=(fnaRefresh, fnaClose, fnaMinimize, fnaMaximaze, fnaSetMDI, fnaResetMDI,
    fnaHide, fnaShow, fnaStopAutoRefresh, fnaStartAutoRefresh, fnaPauseAutoRefresh,
    fnaResumeAutoRefresh);
  TIsDigitType=(idString, idDigit, idFloatDigit, idHex, idColor, idDateTime, idUserLevel);
  TDataStatus=(dssChanged, dssSaved);
  TIniStore=(isDisk, isBase, isDiskAndBase, isNone);
  TNotifyActionsType=(naDone, naScriptRun, naMessage, naExecAndWait, naExec, naExitToTime);
  TQueryType=(qtMain, qtFind, qtDefault);
  TFilterType=(ftNone, ftDBFilter, ftContextFilter, ftComboFilter);
  TOfficeFormat=(ofNone, ofMSO, ofOO, ofPossible);
  TOfficeDocumentFormat=(odfNone, odfMSO97, odfMSO2007, odfOO, odfPossible);
  TDocumentType=(dtNone, dtSheet, dtText);
  TReportViewMode=(rvmOneRecord, rvmAllDS, rvmGrid, rvmMultitRecordReport, rvmBookmarcks);
  TFieldBoxType=(fbtOutBox, fbtInputBox, fbtEditBox);
  TGraficFileType=(gftNone, gftBMP, gftJPEG, gftPNG, gftIcon, gftGIF, gftTIFF, gftOther);
  TDataFieldTypeType=(dftDefault, dftMemo, dftGrafic, dftRichText, dftLogic, dftFloat);
  TSpoolType=(stNone, stSpool, stText);
  TGroupType=(gtGrafic, gtMemo, gtRichText);
  TQueryBehavior=(qbNormal, qbNotReload, qbEnding);
  TDataSetType=(dstIBQ, dstDataSet, dstFRX);
  TReportType=(rtWord, rtFast);
  TSelectType=(qtCount, qtSelect);
  TFindType=(ftByIndex, ftByName, ftSQL);
  TNewQueryMode=(nqmNew, nqmFromGrid);
  TChooseMode=(chmNone, chmChoose, chmChooseAndClose);
  TMessageType=(mbtError=0, mbtWarning=1, mbtInformation=9, mbtConfirmation=10);
  TSigns=(sEquals, sGreater, sLess, sNotEqual, sGreaterEq, sLessEq);
  TSimplyFieldType=(sftNotDefine, sftString, sftDigit, sftFloat, sftDateTime);
  TDCLFormCloseAction=(fcaNone, fcaClose, fcaInProcess);
  TFastReportsScriptLanguage=(fslPascal, fslBasic, fslCppScript, fslJScript);
  TINIType=(itNone, itFormPos, itBookmarkMenu);
  TFieldFormat=(fftNone, fftDigit, fftDate, fftTime, fftDateTime, fftTrim, fftFloat);
  TSheetFillStrategy=(sfsInsert, sfsReplace);

const
  ReleaseStatus=rsBetta;
  ReliseStatues:Array[TReliseStatus] of String=('Alpha', 'Betta', 'Pre relase', 'Unstable', 'Stable');
  Signs:Array[TSigns] of String=('=', '<', '>', '<>', '<=', '>=');
  FastReportsScriptLanguages:array[TFastReportsScriptLanguage] of String=('PascalScript', 'BasicScript', 'C++Script', 'JScript');

  DefaultFRScriptLanguage=fslPascal;

 function Version:String;

implementation

function Version:String;
var
  i:Integer;
begin
  Result:='';
  i:=19;
  While VersionS[i]<>'$' do
  begin
    Result:=Result+VersionS[i];
    Inc(i);
  end;
end;

end.
