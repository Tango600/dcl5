unit uDCLMultiLang;
{$I DefineType.pas}

interface

uses
  SysUtils, Classes,
{$IFDEF MSWINDOWS}
  Windows, 
{$ENDIF}
  uDCLConst;

type
  TLangID=LongWord;
  TLangName=String;

  TTranscodeDataType=(tdtUTF8, tdtDOS, tdtTranslit);
  TStringMessages=(msNone, msClose, msOpen, msEdit, msDelete, msModified, msInputVulues, msInBegin,
    msInEnd, msPrior, msNext, msCancel, msRefresh, msInsert, msPost, msEmptyUserName, msPage, msApplay,
    msConnectDBError, msClearContent, msConnectionStringIncorrect, msNoField, msDeleteRecord,
    msLoad, msClear, msSave, msNotAllow, msOpenForm, msExecuteApps, msText, msAll, msFormated,
    msConfigurationFile, msNotFoundM, msNotFoundF, msTable, msAppRunning, msNot, msNotSupportedS,
    msPaths, msTheProduct, msProducer, msVersion, msStatus, msUser, msRole, msDataBase, msConfiguration,
    msDebugMode, msInformationAbout, msBuildOf, msOS, msLang, msUsers, msDoYouWontTerminate, msClearAllFind,
    msApplication, msDownloadInProgress, msFind, msFindCurrCell, msPrint, msCopy, msCut, msPast, msBookmark,
    msStructure, msGotoBookmark, msOldFormat, msOldBookmarkFormat, msVersionsGap, msOldVersion,
    msChangePassord, msOldM, msNewM, msPassword, msConfirm, msHashed, msToHashing, msToAll, msIn,
    msLogonToSystem, msUserName, msNoYes, msDenyMessageDev, msDenyMessageUsr, msAccessLevelsSet, msNotifyActionsSet,
    msCodePage, msLock, msUnLock, msChoose, msEditings, msData, msReset, msSettings, msFields,
    msBookmarks, msHour, msMinute, msSecond, msMSecond, msModeOff, msModeOn, msStringNum, msVisualCommand,
    msConnectionError, msErrorQuery, msBadFindParams, msErrorInExpression, msErrorQueryInExpression,
    msTooMachParams, msBadFieldFormad, msNoDATARegion, msNoTemplatesTable, msTemplateNotFound, msLabelNotFound,
    msTemplFileNotFound, msTableUsersNotFound, msOONotInstalled, msFailOpenDocument, msMSNotInstalled, msWord2000Req,
    msNoOfficeInstalled, msConvertionError, msAppRunError, msFileNotFound, msErrorInRaightExpression, msFieldNotFound,
    msJanuary, msFebruary, msMarch, msApril, msMay, msJune, msJuly, msAugust, msSeptember, msOctober, msNovember,
    msDecember, msMonday, msTuesday, msWednesday, msThursday, msFriday, msSaturday, msSunday, msEditPassword,
    msOldPassword, msNewPassword, msHashPassword, msResetAllFieldsSettings, msResetAllFieldsSettingsQ,
    msResetFieldsSettings, msResetFieldsSettingsQ, msDeleteAllBookmarks, msDeleteAllBookmarksQ, msSaveFieldsSettings,
    msNotAllowOpenForm, msDeleteRecordQ, msNotAllowExecuteApps, msPathsNotSupported, msSaveEditings, msSaveEditingsQ,
    msDoYouWontTerminateApplicationQ, msConfigurationFileNotFound, msClearContentQ, msNotifycation, msForUser,
    msLoading, msTimeToExit);


procedure LoadLangRes(Lang:TLangID; Path:String);
function GetDCLMessageString(MessID: TStringMessages): String;
function GetDCLErrorString(ErrorCode: Integer; AddText: String=''):string;
function LoadTranscodeFile(DataType:TTranscodeDataType; FileName:String; LangID:TLangID):Boolean;
Function Transcode(DataType:TTranscodeDataType; const Buf: String): String;
function GetLacalaizedMonthName(MonthNum:Integer):string;
function LangIDToString(LangID:TLangID):String;
function LangNameToID(LangName:String):TLangID;

function GetSystemLanguage: String;
function GetSystemLanguageID: Integer;
procedure InitLangEnv;

const
  DefaultLangDir='Lang';
  DefaultLanguage='RUS';
  DefaultLanguageID=1049;

var
  LangID:TLangID;//   //TISO639_3;
  LangName:TLangName;

implementation

uses
  uDCLUtils, uStringParams;

const
  StringDelim=#39;
  NamedStringMessages:Array[TStringMessages] of String=('msNone', 'msClose', 'msOpen', 'msEdit', 'msDelete', 'msModified', 'msInputVulues', 'msInBegin',
    'msInEnd', 'msPrior', 'msNext', 'msCancel', 'msRefresh', 'msInsert', 'msPost', 'msEmptyUserName', 'msPage', 'msApplay',
    'msConnectDBError', 'msClearContent', 'msConnectionStringIncorrect', 'msNoField', 'msDeleteRecord',
    'msLoad', 'msClear', 'msSave', 'msNotAllow', 'msOpenForm', 'msExecuteApps', 'msText', 'msAll', 'msFormated',
    'msConfigurationFile', 'msNotFoundM', 'msNotFoundF', 'msTable', 'msAppRunning', 'msNot', 'msNotSupportedS',
    'msPaths', 'msTheProduct', 'msProducer', 'msVersion', 'msStatus', 'msUser', 'msRole', 'msDataBase', 'msConfiguration',
    'msDebugMode', 'msInformationAbout', 'msBuildOf', 'msOS', 'msLang', 'msUsers', 'msDoYouWontTerminate', 'msClearAllFind',
    'msApplication', 'msDownloadInProgress', 'msFind', 'msFindCurrCell', 'msPrint', 'msCopy', 'msCut', 'msPast', 'msBookmark',
    'msStructure', 'msGotoBookmark', 'msOldFormat', 'msOldBookmarkFormat', 'msVersionsGap', 'msOldVersion',
    'msChangePassord', 'msOldM', 'msNewM', 'msPassword', 'msConfirm', 'msHashed', 'msToHashing', 'msToAll', 'msIn',
    'msLogonToSystem', 'msUserName', 'msNoYes', 'msDenyMessageDev', 'msDenyMessageUsr', 'msAccessLevelsSet', 'msNotifyActionsSet',
    'msCodePage', 'msLock', 'msUnLock', 'msChoose', 'msEditings', 'msData', 'msReset', 'msSettings', 'msFields',
    'msBookmarks', 'msHour', 'msMinute', 'msSecond', 'msMSecond', 'msModeOff', 'msModeOn', 'msStringNum', 'msVisualCommand',
    'msConnectionError', 'msErrorQuery', 'msBadFindParams', 'msErrorInExpression', 'msErrorQueryInExpression',
    'msTooMachParams', 'msBadFieldFormad', 'msNoDATARegion', 'msNoTemplatesTable', 'msTemplateNotFound', 'msLabelNotFound',
    'msTemplFileNotFound', 'msTableUsersNotFound', 'msOONotInstalled', 'msFailOpenDocument', 'msMSNotInstalled', 'msWord2000Req',
    'msNoOfficeInstalled', 'msConvertionError', 'msAppRunError', 'msFileNotFound', 'msErrorInRaightExpression', 'msFieldNotFound',
    'msJanuary', 'msFebruary', 'msMarch', 'msApril', 'msMay', 'msJune', 'msJuly', 'msAugust', 'msSeptember', 'msOctober', 'msNovember',
    'msDecember', 'msMonday', 'msTuesday', 'msWednesday', 'msThursday', 'msFriday', 'msSaturday', 'msSunday', 'msEditPassword',
    'msOldPassword', 'msNewPassword', 'msHashPassword', 'msResetAllFieldsSettings', 'msResetAllFieldsSettingsQ',
    'msResetFieldsSettings', 'msResetFieldsSettingsQ', 'msDeleteAllBookmarks', 'msDeleteAllBookmarksQ', 'msSaveFieldsSettings',
    'msNotAllowOpenForm', 'msDeleteRecordQ', 'msNotAllowExecuteApps', 'msPathsNotSupported', 'msSaveEditings', 'msSaveEditingsQ',
    'msDoYouWontTerminateApplicationQ', 'msConfigurationFileNotFound', 'msClearContentQ', 'msNotifycation', 'msForUser',
    'msLoading', 'msTimeToExit');

type
  TCharToUTF8Table=array [0..255] of String;
  TTranscodeType=(ttDirect, ttSub, ttAdd, ttVarLen);

  TTranscodeData=Record
    CodeFrom1, CodeFrom2, TargetGap:Integer;
    SourceLiteral, TagertCode:String;
    TranscodeType:TTranscodeType;
  end;

  TLangIDName=record
    ID:Integer;
    LangNameISO639, ShortName:string;
  end;


const
  TranscodeToDOS:Array[0..3] of TTranscodeData=((CodeFrom1:168;CodeFrom2:168; TagertCode:Chr(72); TranscodeType:ttAdd),
                                             (CodeFrom1:184;CodeFrom2:184; TagertCode:Chr(57); TranscodeType:ttAdd),
                                             (CodeFrom1:192;CodeFrom2:239; TagertCode:Chr(64); TranscodeType:ttSub),
                                             (CodeFrom1:240;CodeFrom2:255; TagertCode:Chr(16); TranscodeType:ttSub));

  TransliteSimbolsCount=68;
  RusTab: Array [0..TransliteSimbolsCount-1] Of Char=('�', '�', '�', '�', '�', '�', '�', '�', '�', '�', '�',
    '�', '�', '�', '�', '�', '�', '�', '�', '�', '�', '�', '�', '�', '�', '�', '�', '�', '�', '�',
    '�', '�', '�', '�', '�', '�', '�', '�', '�', '�', '�', '�', '�', '�', '�', '�', '�', '�', '�',
    '�', '�', '�', '�', '�', '�', '�', '�', '�', '�', '�', '�', '�', '�', '�', '�', '�', ' ', '�');
  LatTab: Array [0..TransliteSimbolsCount-1] Of String=('a', 'b', 'v', 'g', 'd', 'je', 'jo', 'zh', 'z', 'i',
    'j', 'k', 'l', 'm', 'n', 'o', 'p', 'r', 's', 't', 'u', 'f', 'h', 'ce', 'ch', 'sh', 'sch', 'y',
    '''', '', 'e', 'ju', 'ja', 'A', 'B', 'V', 'G', 'D', 'JE', 'JO', 'ZH', 'Z', 'I', 'J', 'K', 'L',
    'M', 'N', 'O', 'P', 'R', 'S', 'T', 'U', 'F', 'H', 'CE', 'CH', 'SH', 'SCH', 'Y', '''', '', 'E',
    'JU', 'JA', '_', '#');

  LangIDsToName:Array[1..4] of TLangIDName=(
  (ID:1049; LangNameISO639:'RUS'; ShortName:'RU'),
  (ID:1033; LangNameISO639:'ENG'; ShortName:'EN'),
  (ID:1045; LangNameISO639:'POL'; ShortName:'PL'),
  (ID:1029; LangNameISO639:'CES'; ShortName:'CS')
  );

  ArrayCP1251ToUTF8: TCharToUTF8Table=(
    #0, // #0
    #1, // #1
    #2, // #2
    #3, // #3
    #4, // #4
    #5, // #5
    #6, // #6
    #7, // #7
    #8, // #8
    #9, // #9
    #10, // #10
    #11, // #11
    #12, // #12
    #13, // #13
    #14, // #14
    #15, // #15
    #16, // #16
    #17, // #17
    #18, // #18
    #19, // #19
    #20, // #20
    #21, // #21
    #22, // #22
    #23, // #23
    #24, // #24
    #25, // #25
    #26, // #26
    #27, // #27
    #28, // #28
    #29, // #29
    #30, // #30
    #31, // #31
    #32, // ' '
    #33, // !
    #34, // "
    #35, // #
    #36, // $
    #37, // %
    #38, // &
    #39, // '
    #40, // (
    #41, // )
    #42, // *
    #43, // +
    #44, // ,
    #45, // -
    #46, // .
    #47, // /
    #48, // 0
    #49, // 1
    #50, // 2
    #51, // 3
    #52, // 4
    #53, // 5
    #54, // 6
    #55, // 7
    #56, // 8
    #57, // 9
    #58, // :
    #59, // ;
    #60, // <
    #61, // =
    #62, // >
    #63, // ?
    #64, // @
    #65, // A
    #66, // B
    #67, // C
    #68, // D
    #69, // E
    #70, // F
    #71, // G
    #72, // H
    #73, // I
    #74, // J
    #75, // K
    #76, // L
    #77, // M
    #78, // N
    #79, // O
    #80, // P
    #81, // Q
    #82, // R
    #83, // S
    #84, // T
    #85, // U
    #86, // V
    #87, // W
    #88, // X
    #89, // Y
    #90, // Z
    #91, // [
    #92, // \
    #93, // ]
    #94, // ^
    #95, // _
    #96, // `
    #97, // a
    #98, // b
    #99, // c
    #100, // d
    #101, // e
    #102, // f
    #103, // g
    #104, // h
    #105, // i
    #106, // j
    #107, // k
    #108, // l
    #109, // m
    #110, // n
    #111, // o
    #112, // p
    #113, // q
    #114, // r
    #115, // s
    #116, // t
    #117, // u
    #118, // v
    #119, // w
    #120, // x
    #121, // y
    #122, // z
    #123, // {
    #124, // |
    #125, // }
    #126, // ~
    #127, // #127
    #208#130, // #128
    #208#131, // #129
    #226#128#154, // #130
    #209#147, // #131
    #226#128#158, // #132
    #226#128#166, // #133
    #226#128#160, // #134
    #226#128#161, // #135
    #226#130#172, // #136
    #226#128#176, // #137
    #208#137, // #138
    #226#128#185, // #139
    #208#138, // #140
    #208#140, // #141
    #208#139, // #142
    #208#143, // #143
    #209#146, // #144
    #226#128#152, // #145
    #226#128#153, // #146
    #226#128#156, // #147
    #226#128#157, // #148
    #226#128#162, // #149
    #226#128#147, // #150
    #226#128#148, // #151
    '', // #152
    #226#132#162, // #153
    #209#153, // #154
    #226#128#186, // #155
    #209#154, // #156
    #209#156, // #157
    #209#155, // #158
    #209#159, // #159
    #194#160, // #160
    #208#142, // #161
    #209#158, // #162
    #208#136, // #163
    #194#164, // #164
    #210#144, // #165
    #194#166, // #166
    #194#167, // #167
    #208#129, // #168
    #194#169, // #169
    #208#132, // #170
    #194#171, // #171
    #194#172, // #172
    #194#173, // #173
    #194#174, // #174
    #208#135, // #175
    #194#176, // #176
    #194#177, // #177
    #208#134, // #178
    #209#150, // #179
    #210#145, // #180
    #194#181, // #181
    #194#182, // #182
    #194#183, // #183
    #209#145, // #184
    #226#132#150, // #185
    #209#148, // #186
    #194#187, // #187
    #209#152, // #188
    #208#133, // #189
    #209#149, // #190
    #209#151, // #191
    #208#144, // #192
    #208#145, // #193
    #208#146, // #194
    #208#147, // #195
    #208#148, // #196
    #208#149, // #197
    #208#150, // #198
    #208#151, // #199
    #208#152, // #200
    #208#153, // #201
    #208#154, // #202
    #208#155, // #203
    #208#156, // #204
    #208#157, // #205
    #208#158, // #206
    #208#159, // #207
    #208#160, // #208
    #208#161, // #209
    #208#162, // #210
    #208#163, // #211
    #208#164, // #212
    #208#165, // #213
    #208#166, // #214
    #208#167, // #215
    #208#168, // #216
    #208#169, // #217
    #208#170, // #218
    #208#171, // #219
    #208#172, // #220
    #208#173, // #221
    #208#174, // #222
    #208#175, // #223
    #208#176, // #224
    #208#177, // #225
    #208#178, // #226
    #208#179, // #227
    #208#180, // #228
    #208#181, // #229
    #208#182, // #230
    #208#183, // #231
    #208#184, // #232
    #208#185, // #233
    #208#186, // #234
    #208#187, // #235
    #208#188, // #236
    #208#189, // #237
    #208#190, // #238
    #208#191, // #239
    #209#128, // #240
    #209#129, // #241
    #209#130, // #242
    #209#131, // #243
    #209#132, // #244
    #209#133, // #245
    #209#134, // #246
    #209#135, // #247
    #209#136, // #248
    #209#137, // #249
    #209#138, // #250
    #209#139, // #251
    #209#140, // #252
    #209#141, // #253
    #209#142, // #254
    #209#143 // #255
    );

var
  StringMessages:array[TStringMessages] of string;
  TranscodeData:array[TTranscodeDataType] of Array of TTranscodeData;


function GetDCLMessageStringDefault(MesID: TStringMessages): String;
begin
  Case LangID of
  DefaultLanguageID:
    case MesID of
    msNone:
    Result:='<���>';
    msNot:
    Result:='��';
    msIn:
    Result:='�';
    msClose:
    Result:='�������';
    msOpen:
    Result:='�������';
    msEdit:
    Result:='��������';
    msDelete:
    Result:='�������';
    msDeleteRecord:
    Result:='������� ������';
    msClearContent:
    Result:='�������� ����������';
    msModified:
    Result:='��������';
    msInputVulues:
    Result:='���� ��������';
    msInBegin:
    Result:='� ������';
    msInEnd:
    Result:='� �����';
    msPrior:
    Result:='�����';
    msNext:
    Result:='�����';
    msCancel:
    Result:='��������';
    msRefresh:
    Result:='��������';
    msInsert:
    Result:='��������';
    msPost:
    Result:='��������';
    msEmptyUserName:
    Result:='�� ��������� ��� ������������.';
    msPage:
    Result:='��������';
    msConnectDBError:
    Result:='�� ������� �������������� � ��.';
    msConnectionStringIncorrect:
    Result:='������ ���������� �� ���������.';
    msNoField:
    Result:='��� ����:';
    msLoad:
    Result:='���������';
    msClear:
    Result:='��������';
    msApplay:
    Result:='�������';
    msSave:
    Result:='���������';
    msNotAllow:
    Result:='��� �� ���������';
    msOpenForm:
    Result:='��������� ��� �����.';
    msExecuteApps:
    Result:='��������� ����������.';
    msText:
    Result:='�����';
    msAll:
    Result:='���';
    msFormated:
    Result:='���������������';
    msConfigurationFile:
    Result:='���� ������������';
    msNotFoundM:
    Result:='�� ������';
    msNotFoundF:
    Result:='�� �������';
    msTable:
    Result:='�������';
    msAppRunning:
    Result:='���������� ��� �������� (�������� ��� �������� �� ������ �����).';
    msNotSupportedS:
    Result:='�� ��������������';
    msPaths:
    Result:='����';
    msTheProduct:
    Result:='�������';
    msProducer:
    Result:='������������';
    msVersion:
    Result:='������';
    msStatus:
    Result:='������';
    msUser:
    Result:='������������';
    msRole:
    Result:='����';
    msDataBase:
    Result:='���� ������';
    msConfiguration:
    Result:='������������';
    msDebugMode:
    Result:='����� �������';
    msInformationAbout:
    Result:='�������� �';
    msBuildOf:
    Result:='������';
    msOS:
    Result:='��';
    msLang:
    Result:='����';
    msUsers:
    Result:='�������������';
    msDoYouWontTerminate:
    Result:='������ ���������';
    msApplication:
    Result:='����������';
    msDownloadInProgress:
    Result:='��� �������';
    msClearAllFind:
    Result:='�������� �����';
    msFind:
    Result:='�����';
    msFindCurrCell:
    Result:='����� �� ������� ������';
    msPrint:
    Result:='������';
    msCopy:
    Result:='����������';
    msCut:
    Result:='��������';
    msPast:
    Result:='��������';
    msBookmark:
    Result:='��������';
    msBookmarks:
    Result:='��������';
    msStructure:
    Result:='���������';
    msGotoBookmark:
    Result:='������� � ��������';
    msOldFormat:
    Result:='������ ������';
    msOldBookmarkFormat:
    Result:='������ ������ ��������, ��� ������ Title';
    msVersionsGap:
    Result:='������������ ������� � �������. �� ����� �� ��������.';
    msOldVersion:
    Result:='������ ������. ��������� ����������� ����� �� ��������.';
    msToAll:
    Result:='����';
    msChangePassord:
    Result:='����� ������';
    msOldM:
    Result:='������';
    msNewM:
    Result:='�����';
    msPassword:
    Result:='������';
    msConfirm:
    Result:='�������������';
    msHashed:
    Result:='������������';
    msToHashing:
    Result:='����������';
    msLogonToSystem:
    Result:='���� � �������';
    msUserName:
    Result:='��� ������������';
    msNoYes:
    Result:='���,��';
    msDenyMessageDev:
    Result:='� ��� ��� ����� ������������.';
    msDenyMessageUsr:
    Result:='��� �� �������� ���� � �������.';
    msAccessLevelsSet:
    Result:='��������,������ ������,������,������ �����,������� 1,������� 2,������� 3,������� 4,�����������';
    msNotifyActionsSet:
    Result:='���������,������ �������,���������,������ ���������� � ���������,������ ����������,����� �� �������';
    msCodePage:
    Result:='������� ��������';
    msLock:
    Result:='�������������';
    msChoose:
    Result:='�������';
    msEditings:
    Result:='���������';
    msData:
    Result:='������';
    msReset:
    Result:='��������';
    msSettings:
    Result:='���������';
    msFields:
    Result:='�����';
    msHour:
    Result:='�';
    msMinute:
    Result:='�';
    msSecond:
    Result:='���';
    msMSecond:
    Result:='����';
    msModeOff:
    Result:='����';
    msModeOn:
    Result:='���';
    msStringNum:
    Result:='������ �';
    msVisualCommand:
    Result:='����������/����������';
    msConnectionError:
    Result:='������ ����������';
    msErrorQuery:
    Result:='��������� ������.';
    msBadFindParams:
    Result:='��������� ������ ��� �� ������ ������� ������.';
    msErrorInExpression:
    Result:='������ � ���������.';
    msErrorQueryInExpression:
    Result:='��������� ������ � ���������.';
    msTooMachParams:
    Result:='������������ ��� ����� ���������� � �����������.';
    msBadFieldFormad:
    Result:='�������� ������ �����.';
    msNoDATARegion:
    Result:='��� ������� ������ "DATA".';
    msNoTemplatesTable:
    Result:='��� ������� ��������.';
    msTemplateNotFound:
    Result:='��� ������ ������� - ';
    msLabelNotFound:
    Result:='����� ����� ���.';
    msTemplFileNotFound:
    Result:='��� ����� �������.';
    msTableUsersNotFound:
    Result:='������� ������������� �� �������.';
    msOONotInstalled:
    Result:='OpenOffice �� ����������.';
    msFailOpenDocument:
    Result:='������� �������� �� �������.';
    msMSNotInstalled:
    Result:='Microsoft Office �� ����������.';
    msWord2000Req:
    Result:='��������� WORD 2000/XP ��� ����.';
    msNoOfficeInstalled:
    Result:='������� ���� �� ����������.';
    msConvertionError:
    Result:='������ ��������������.';
    msAppRunError:
    Result:='������ �������.';
    msFileNotFound:
    Result:='���� �� ������.';
    msErrorInRaightExpression:
    Result:='������ � ��������� ���� �������.';
    msFieldNotFound:
    Result:='���� �� �������.';
    msJanuary:
    Result:='������';
    msFebruary:
    Result:='�������';
    msMarch:
    Result:='����';
    msApril:
    Result:='������';
    msMay:
    Result:='���';
    msJune:
    Result:='����';
    msJuly:
    Result:='����';
    msAugust:
    Result:='������';
    msSeptember:
    Result:='��������';
    msOctober:
    Result:='�������';
    msNovember:
    Result:='������';
    msDecember:
    Result:='�������';
    msMonday:
    Result:='�����������';
    msTuesday:
    Result:='�������';
    msWednesday:
    Result:='�����';
    msThursday:
    Result:='�������';
    msFriday:
    Result:='�������';
    msSaturday:
    Result:='�������';
    msSunday:
    Result:='�����������';
    msEditPassword:
    Result:='�������� ������';
    msOldPassword:
    Result:='������ ������';
    msNewPassword:
    Result:='����� ������';
    msHashPassword:
    Result:='���������� ������';
    msResetAllFieldsSettings:
    Result:='�������� ��������� ���� �����';
    msResetAllFieldsSettingsQ:
    Result:=GetDCLMessageStringDefault(msResetAllFieldsSettings)+'?';
    msResetFieldsSettings:
    Result:='�������� ��������� �����';
    msResetFieldsSettingsQ:
    Result:=GetDCLMessageStringDefault(msResetFieldsSettings)+'?';
    msDeleteAllBookmarks:
    Result:='������� ��� ��������';
    msDeleteAllBookmarksQ:
    Result:=GetDCLMessageStringDefault(msDeleteAllBookmarks)+'?';
    msSaveFieldsSettings:
    Result:='��������� ��������� �����';
    msNotAllowOpenForm:
    Result:='��� �� ��������� ��������� �����';
    msDeleteRecordQ:
    Result:=GetDCLMessageStringDefault(msDeleteRecord)+'?';
    msPathsNotSupported:
    Result:='���� �� ��������������';
    msSaveEditings:
    Result:='��������� ���������';
    msSaveEditingsQ:
    Result:=GetDCLMessageStringDefault(msSaveEditings)+'?';
    msDoYouWontTerminateApplicationQ:
    Result:='��������� ����������?';
    msConfigurationFileNotFound:
    Result:='���� ������������ �� ������';
    msClearContentQ:
    Result:=GetDCLMessageStringDefault(msClearContent)+'?';
    msNotifycation:
    Result:='�����������';
    msForUser:
    Result:='��� ������������';
    msLoading:
    Result:='��������';
    msTimeToExit:
    Result:='����� �� ������� ����� %d ������.';
    end;
  End;
end;

function GetDCLMessageString(MessID: TStringMessages): String;
begin
  Result:=StringMessages[MessID];
end;

function GetDCLErrorString(ErrorCode: Integer; AddText: String=''):string;
Var
  MessageText: String;
Begin
  MessageText:='';
  Case ErrorCode Of
  -2, -3:
  MessageText:=GetDCLMessageString(msConnectionError);
  -1100, -1101, -1119, -1102, -1106, -1107, -1112, -1200, -1201, -1113, -1114, -1115, -1116, -1118:
  MessageText:=GetDCLMessageString(msErrorQuery)+' '+IntToStr(ErrorCode)+' / '+AddText;
  -1111:
  MessageText:=GetDCLMessageString(msBadFindParams)+' '+IntToStr(ErrorCode);
  -1103, -1104, -1105, -1108, -1110, -1117:
  MessageText:=GetDCLMessageString(msErrorInExpression)+' '+IntToStr(ErrorCode);
  -1109:
  MessageText:=GetDCLMessageString(msErrorQueryInExpression)+' '+IntToStr(ErrorCode);
  -4000:
  MessageText:=GetDCLMessageString(msTooMachParams)+' '+IntToStr(ErrorCode);
  -4002:
  MessageText:=GetDCLMessageString(msBadFieldFormad)+' '+IntToStr(ErrorCode);
  -5002:
  MessageText:=GetDCLMessageString(msNoDATARegion)+' '+IntToStr(ErrorCode);
  -5003:
  MessageText:=GetDCLMessageString(msNoTemplatesTable)+' '+IntToStr(ErrorCode);
  -5004:
  MessageText:=GetDCLMessageString(msTemplateNotFound)+' '+IntToStr(ErrorCode);
  -5005:
  MessageText:=GetDCLMessageString(msLabelNotFound)+' '+IntToStr(ErrorCode);
  -5006, -5007:
  MessageText:=GetDCLMessageString(msTemplFileNotFound)+' '+IntToStr(ErrorCode);
  -5008:
  MessageText:=GetDCLMessageString(msTableUsersNotFound)+' '+IntToStr(ErrorCode);
  -6001, -6002: // OOo
  MessageText:=GetDCLMessageString(msOONotInstalled)+' '+IntToStr(ErrorCode);
  -6003:
  MessageText:=GetDCLMessageString(msFailOpenDocument)+' '+IntToStr(ErrorCode);
  -6000, -6010:
  MessageText:=GetDCLMessageString(msMSNotInstalled)+' '+IntToStr(ErrorCode);
  -6011:
  MessageText:=GetDCLMessageString(msWord2000Req)+' '+IntToStr(ErrorCode);
  -6020:
  MessageText:=GetDCLMessageString(msNoOfficeInstalled)+' '+IntToStr(ErrorCode);
  -7000:
  MessageText:=GetDCLMessageString(msConvertionError)+' '+IntToStr(ErrorCode);
  -8000:
  MessageText:=GetDCLMessageString(msAppRunError)+' '+IntToStr(ErrorCode);
  -8001:
  MessageText:=GetDCLMessageString(msFileNotFound)+' '+IntToStr(ErrorCode);
  -9000:
  MessageText:=GetDCLMessageString(msErrorInRaightExpression)+' '+IntToStr(ErrorCode);
  -10000, -10001, -10002:
  MessageText:=GetDCLMessageString(msFieldNotFound)+' '+IntToStr(ErrorCode);
  Else
    MessageText:=AddText;
  End;

  Result:=MessageText;
End;

procedure ClearTranscodeData(var Data:TTranscodeData);
begin
  Data.CodeFrom1:=0;
  Data.CodeFrom2:=0;
  Data.TargetGap:=0;
  Data.SourceLiteral:='';
  Data.TagertCode:='';
  Data.TranscodeType:=ttDirect;
end;

function LoadTranscodeFile(DataType:TTranscodeDataType; FileName:String; LangID:TLangID):Boolean;
var
  LangResFile:TStringList;
  S, c, vs1, tmp1:String;
  ii, p, k, d, v1, l:Integer;
  simbcodeflg:Boolean;
  lt:TIsDigitType;
begin
  If not FileExists(FileName) then
    FileName:=FileName+'.'+LangIDToString(LangID);

  Result:=False;
{$IFNDEF SINGLELANG}
  If FileExists(FileName) then
  Begin
    LangResFile:=TStringList.Create;
    LangResFile.LoadFromFile(FileName);

    For ii:=1 to LangResFile.Count do
    Begin
      S:=LangResFile[ii-1];
      If Pos(';', S)<>1 then
      Begin
        p:=Pos(':', S);
        If p<>0 then
        Begin
          l:=Length(TranscodeData[DataType]);
          SetLength(TranscodeData[DataType], l+1);
          ClearTranscodeData(TranscodeData[DataType][l]);
          vs1:=GetClearParam(Copy(S, 1, p-1), #39);
          If (Pos('-', vs1)=0) then
          Begin
            tmp1:=GetClearParam(Copy(S, 1, p-1), #39);
            lt:=GetStringDataType(tmp1);
            Case lt of
            idDigit, idHex:Begin
              If lt=idHex then
                k:=HexToInt(tmp1)
              Else
                k:=StrToInt(tmp1);
              TranscodeData[DataType][l].CodeFrom1:=k;
              TranscodeData[DataType][l].CodeFrom2:=k;
            End;
            idString:Begin
              TranscodeData[DataType][l].SourceLiteral:=tmp1;
            End;
            End;
          End
          Else
          Begin
            tmp1:=GetClearParam(Copy(S, 1, Pos('-', vs1)-1), #39);
            lt:=GetStringDataType(tmp1);
            Case lt of
            idDigit, idHex:Begin
              If lt=idHex then
                k:=HexToInt(tmp1)
              Else
                k:=StrToInt(tmp1);
              TranscodeData[DataType][l].CodeFrom1:=k;
            end;
            end;

            tmp1:=Copy(S, Pos('-', vs1)+1, p-1-Pos('-', vs1));
            lt:=GetStringDataType(tmp1);
            Case lt of
            idDigit, idHex:Begin
              If lt=idHex then
                k:=HexToInt(tmp1)
              Else
                k:=StrToInt(tmp1);
              TranscodeData[DataType][l].CodeFrom2:=k;
            End;
            End;
          End;

          d:=Pos(';', S);
          If d=0 then
            d:=Length(S);
          c:=Copy(S, p+1, d-p-1);
          simbcodeflg:=False;
          If Length(c)>0 then
          Begin
            vs1:='';
            If (c[1]=#39) and (Length(c)>1) and (c[Length(c)]=#39) then
            Begin
              vs1:=GetClearParam(c, #39);
              TranscodeData[DataType][l].TranscodeType:=ttVarLen;
              simbcodeflg:=False;
            End
            Else
            Begin
              TranscodeData[DataType][l].TranscodeType:=ttDirect;

              For v1:=1 to Length(c) do
              Begin
                If simbcodeflg and (c[v1] in ['0'..'9']) then
                  vs1:=vs1+c[v1];

                If c[v1]='#' then
                Begin
                  simbcodeflg:=True;
                  If vs1<>'' then
                    TranscodeData[DataType][l].TagertCode:=TranscodeData[DataType][l].TagertCode+Chr(StrToInt(vs1));
                  vs1:='';
                End;
                If c[v1]='-' then
                Begin
                  TranscodeData[DataType][l].TranscodeType:=ttSub;
                  simbcodeflg:=True;
                  If vs1<>'' then
                    TranscodeData[DataType][l].TargetGap:=StrToInt(vs1);
                End;
                If c[v1]='+' then
                Begin
                  TranscodeData[DataType][l].TranscodeType:=ttAdd;
                  simbcodeflg:=True;
                  If vs1<>'' then
                    TranscodeData[DataType][l].TargetGap:=StrToInt(vs1);
                End;
              End;
            End;

            if simbcodeflg then
            Begin
              If vs1<>'' then
                TranscodeData[DataType][l].TagertCode:=TranscodeData[DataType][l].TagertCode+Chr(StrToInt(vs1));
            End
            Else
              If vs1<>'' then
                TranscodeData[DataType][l].TagertCode:=TranscodeData[DataType][l].TagertCode+vs1;
            vs1:='';
          End;
        End;
      End;
    End;

    Result:=True;
  End;
{$ENDIF}  
end;

Function Transcode(DataType:TTranscodeDataType; const Buf: String): String;
Var
  i, j, k: Cardinal;
  Match:Boolean;
  ts:String;
begin
  Result:='';
  i:=1;
  while i<=Length(Buf) Do
  Begin
    Match:=False;
	  For j:=1 to Length(TranscodeData[DataType]) do
	  Begin
      If (TranscodeData[DataType][j-1].SourceLiteral<>'') then
      Begin
        If TranscodeData[DataType][j-1].SourceLiteral[1]=Buf[i] then
        Begin
          If Length(TranscodeData[DataType][j-1].SourceLiteral)>1 then
          Begin
            k:=1;
            while (TranscodeData[DataType][j-1].SourceLiteral[k]=Buf[i+k]) and (k<=Length(TranscodeData[DataType][j-1].SourceLiteral)) do
            Begin
              Inc(k);
            End;
            If k=Length(TranscodeData[DataType][j-1].SourceLiteral) then
            begin
              Match:=True;
              break;
            end;
          End
          Else
          Begin
            Match:=True;
            break;
          End;
        End;
      End
      Else
        If TranscodeData[DataType][j-1].CodeFrom1=TranscodeData[DataType][j-1].CodeFrom2 then
        Begin
          If Ord(Buf[i])=TranscodeData[DataType][j-1].CodeFrom1 then
          Begin
            Match:=True;
            break;
          End;
        End
        Else
          If TranscodeData[DataType][j-1].CodeFrom1<TranscodeData[DataType][j-1].CodeFrom2 then
          Begin
            If Ord(Buf[i])>=TranscodeData[DataType][j-1].CodeFrom1 then
              If Ord(Buf[i])<=TranscodeData[DataType][j-1].CodeFrom2 then
              Begin
                Match:=True;
                break;
              End;
          End;
		End;

    If Match then
    Begin
      Case TranscodeData[DataType][j-1].TranscodeType of
      ttDirect:
        ts:=TranscodeData[DataType][j-1].TagertCode;
      ttAdd:
        ts:=Chr(Ord(Buf[i])+Ord(TranscodeData[DataType][j-1].TagertCode[1]));
      ttSub:
        ts:=Chr(Ord(Buf[i])-Ord(TranscodeData[DataType][j-1].TagertCode[1]));
      ttVarLen:
        ts:=TranscodeData[DataType][j-1].TagertCode;
      end;
    End
    Else
      ts:=Buf[i];

    Result:=Result+ts;
    Inc(i);
	End;
end;

procedure LoadLangFile(FileName:String);
var
  LangResFile:TStringList;
  S, msID, MessageString:string;
  i, p, k, Delims, StartDelim, EndDelim:Integer;
begin
{$IFNDEF SINGLELANG}
  If FileExists(FileName) then
  Begin
    LangResFile:=TStringList.Create;
    LangResFile.LoadFromFile(FileName);

    For i:=1 to LangResFile.Count do
    Begin
      S:=LangResFile[i-1];

      p:=Pos(':=', S);
      If p>0 then
      Begin
        msID:=LowerCase(Trim(Copy(S, 1, p-1)));
        Delims:=-1;
        StartDelim:=-1;
        EndDelim:=-1;
        For k:=p to Length(S) do
        Begin
          If Delims=-1 then
          Begin
            If S[k]=StringDelim then
            Begin
              Inc(Delims);
              StartDelim:=k+1;
            End;
          End
          Else
            If Delims=0 then
              If S[k]=StringDelim then
              Begin
                Dec(Delims);
                EndDelim:=k-1;
              End;
        End;

        If (StartDelim<EndDelim) and (StartDelim>0) then
        Begin
          MessageString:=Copy(S, StartDelim, EndDelim-StartDelim+1);

          For k:=0 to Ord(High(NamedStringMessages))-1 do
          Begin
            If LowerCase(NamedStringMessages[TStringMessages(k)])=msID then
            Begin
              If MessageString<>'' then
                StringMessages[TStringMessages(k)]:=MessageString
              Else
                StringMessages[TStringMessages(k)]:=GetDCLMessageStringDefault(TStringMessages(k));
              Break;
            End;
          End;
        End;
      End;
    End;

    LangResFile.Free;
  End
  Else
{$ENDIF}
    For k:=0 to Ord(High(NamedStringMessages))-1 do
      StringMessages[TStringMessages(k)]:=GetDCLMessageStringDefault(TStringMessages(k));
end;

procedure SetDefaultTranscodeUTF8;
var
  i:Integer;
begin
  SetLength(TranscodeData[tdtUTF8], 256);
  For i:=0 to 255 do
  Begin
    TranscodeData[tdtUTF8][i].CodeFrom1:=i;
    TranscodeData[tdtUTF8][i].CodeFrom2:=i;
    TranscodeData[tdtUTF8][i].TagertCode:=ArrayCP1251ToUTF8[i];
  End;
end;

procedure SetDefaultTranscodeDOS;
var
  i:Integer;
begin
  SetLength(TranscodeData[tdtDOS], Length(TranscodeToDOS));
  For i:=1 to Length(TranscodeToDOS) do
    TranscodeData[tdtDOS][i-1]:=TranscodeToDOS[i-1];
end;

procedure SetDefaultTranslite;
var
  i:Integer;
begin
  SetLength(TranscodeData[tdtTranslit], TransliteSimbolsCount);
  For i:=1 to TransliteSimbolsCount do
  Begin
    TranscodeData[tdtTranslit][i-1].SourceLiteral:=RusTab[i-1];
    TranscodeData[tdtTranslit][i-1].TagertCode:=LatTab[i-1];
  End;
end;

procedure LoadLangRes(Lang:TLangID; Path:String);
var
  FileName:string;
begin
  FileName:=IncludeTrailingPathDelimiter(DefaultLangDir)+'DCLTranslate.'+LangIDToString(Lang);

  LoadLangFile(Path+FileName);
  If not LoadTranscodeFile(tdtDOS, 'DCLTranscodeDOS', Lang) then
    SetDefaultTranscodeDOS;
  If not LoadTranscodeFile(tdtUTF8, 'DCLTranscodeUTF8', Lang) then
    SetDefaultTranscodeUTF8;
  If not LoadTranscodeFile(tdtTranslit, 'DCLTranslite', Lang) then
    SetDefaultTranslite;
end;

function GetLacalaizedMonthName(MonthNum:Integer):string;
begin
  Result:=GetDCLMessageString(TStringMessages(MonthNum+Ord(msJanuary)-1));
end;

function LangIDToString(LangID:TLangID):String;
var
  i:Integer;
begin
  Result:=IntToStr(LangID);
  For i:=1 to Length(LangIDsToName) do
  Begin
    If LangIDsToName[i].ID=LangID then
    Begin
      Result:=LangIDsToName[i].LangNameISO639;
      Break;
    End;
  End;
end;

function LangNameToID(LangName:String):TLangID;
var
  i:Integer;
begin
  Result:=DefaultLanguageID;
  For i:=1 to Length(LangIDsToName) do
  Begin
    If UpperCase(LangIDsToName[i].LangNameISO639)=UpperCase(LangName) then
    Begin
      Result:=LangIDsToName[i].ID;
      Break;
    End;
  End;
end;

function GetLangNameISO639ByShort(LangName:String):String;
var
  i:Integer;
begin
  Result:=DefaultLanguage;
  For i:=1 to Length(LangIDsToName) do
  Begin
    If UpperCase(LangIDsToName[i].ShortName)=UpperCase(LangName) then
    Begin
      Result:=LangIDsToName[i].LangNameISO639;
      Break;
    End;
  End;
end;

function GetSystemLanguage: String;
var
{$IFDEF MSWINDOWS}
  OutputBuffer: PChar;
{$ENDIF}
  S, Lang:string;
begin
{$IFDEF MSWINDOWS}
  OutputBuffer:=StrAlloc(90);     //alocate memory for the PChar
  try
    try
      GetLocaleInfo(LOCALE_USER_DEFAULT, LOCALE_SABBREVLANGNAME, OutputBuffer, 89);
      Result:=UpperCase(OutputBuffer);
    except
      Result:=DefaultLanguage;
    end;
  finally
    StrDispose(OutputBuffer);   //alway's free the memory alocated
  end;
{$ENDIF}
{$IFDEF UNIX}
  S:=SysUtils.GetEnvironmentVariable('LANG');
  Lang:=Copy(S, 1, Pos('_', S)-1);
  Result:=GetLangNameISO639ByShort(Lang);
{$ENDIF}
end;

function GetSystemLanguageID: Integer;
var
{$IFDEF MSWINDOWS}
  SelectedLCID: LCID;       //DWORD constand in Windows.pas
{$ENDIF}
  S, Lang:string;
begin
{$IFDEF MSWINDOWS}
  try
    try
      SelectedLCID:=GetUserDefaultLCID;
      Result:=SelectedLCID
    except
      Result:=DefaultLanguageID;
    end;
  finally
    //
  end;
{$ENDIF}
{$IFDEF UNIX}
  S:=SysUtils.GetEnvironmentVariable('LANG');
  Lang:=Copy(S, 1, Pos('_', S)-1);
  Result:=LangNameToID(GetLangNameISO639ByShort(Lang));
{$ENDIF}
end;

procedure InitLangEnv;
begin
  LangID:=GetSystemLanguageID;
  LangName:=GetSystemLanguage;
end;

end.
