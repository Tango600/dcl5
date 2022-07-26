unit uDCLMultiLang;
{$I DefineType.pas}

interface

uses
  SysUtils, Classes,
{$IFDEF FPC}
  LazUTF8,
{$ENDIF}
{$IFDEF MSWINDOWS}
  Windows, 
{$ENDIF}
  uDCLConst;

type
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
    msLoading, msTimeToExit, msDSStateSet, msCloseDialogQuery, msNotFilter);


procedure LoadLangRes(Lang:TLangName; Path:String);
function GetDCLMessageString(MessID: TStringMessages): String;
function GetDCLErrorString(ErrorCode: Integer; AddText: String=''):string;
function LoadTranscodeFile(DataType:TTranscodeDataType; FileName:String; Lang:TLangName):Boolean;
Function Transcode(DataType:TTranscodeDataType; const Buf: String): String;
function GetLacalaizedMonthName(MonthNum:Integer):string;

function GetSystemLanguage: String;
procedure InitLangEnv;

const
  DefaultLangDir='Lang';
  DefaultLanguage='RUS';

var
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
    'msLoading', 'msTimeToExit', 'msDSStateSet', 'msCloseDialogQuery', 'msNotFilter');

type
  TCharToUTF8Table=array [0..255] of String;
  TTranscodeType=(ttDirect, ttSub, ttAdd, ttVarLen);

  TTranscodeData=Record
    CodeFrom1, CodeFrom2, TargetGap:Integer;
    SourceLiteral, TagertCode:String;
    TranscodeType:TTranscodeType;
  end;

const
  TranscodeToDOS:Array[0..3] of TTranscodeData=((CodeFrom1:168;CodeFrom2:168; TagertCode:Chr(72); TranscodeType:ttAdd),
                                             (CodeFrom1:184;CodeFrom2:184; TagertCode:Chr(57); TranscodeType:ttAdd),
                                             (CodeFrom1:192;CodeFrom2:239; TagertCode:Chr(64); TranscodeType:ttSub),
                                             (CodeFrom1:240;CodeFrom2:255; TagertCode:Chr(16); TranscodeType:ttSub));

  TransliteSimbolsCount=68;
  RusTab: Array [0..TransliteSimbolsCount-1] Of String=('а', 'б', 'в', 'г', 'д', 'е', 'ё', 'ж', 'з', 'и', 'й',
    'к', 'л', 'м', 'н', 'о', 'п', 'р', 'с', 'т', 'у', 'ф', 'х', 'ц', 'ч', 'ш', 'щ', 'ы', 'ъ', 'ь',
    'э', 'ю', 'я', 'А', 'Б', 'В', 'Г', 'Д', 'Е', 'Ё', 'Ж', 'З', 'И', 'Й', 'К', 'Л', 'М', 'Н', 'О',
    'П', 'Р', 'С', 'Т', 'У', 'Ф', 'Х', 'Ц', 'Ч', 'Ш', 'Щ', 'Ы', 'Ъ', 'Ь', 'Э', 'Ю', 'Я', ' ', '№');
  LatTab: Array [0..TransliteSimbolsCount-1] Of String=('a', 'b', 'v', 'g', 'd', 'je', 'jo', 'zh', 'z', 'i',
    'j', 'k', 'l', 'm', 'n', 'o', 'p', 'r', 's', 't', 'u', 'f', 'h', 'ce', 'ch', 'sh', 'sch', 'y',
    '''', '', 'e', 'ju', 'ja', 'A', 'B', 'V', 'G', 'D', 'JE', 'JO', 'ZH', 'Z', 'I', 'J', 'K', 'L',
    'M', 'N', 'O', 'P', 'R', 'S', 'T', 'U', 'F', 'H', 'CE', 'CH', 'SH', 'SCH', 'Y', '''', '', 'E',
    'JU', 'JA', '_', '#');

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
  If LangName=DefaultLanguage then
  Begin
    case MesID of
    msNone:
    Result:='<Нет>';
    msNot:
    Result:='не';
    msIn:
    Result:='В';
    msClose:
    Result:='Закрыть';
    msCloseDialogQuery:
    Result:='Закрыть?';
    msOpen:
    Result:='Открыть';
    msEdit:
    Result:='Изменить';
    msDelete:
    Result:='Удалить';
    msDeleteRecord:
    Result:='Удалить запись';
    msClearContent:
    Result:='Очистить содержимое';
    msModified:
    Result:='Изменено';
    msInputVulues:
    Result:='Ввод значений';
    msInBegin:
    Result:='В начало';
    msInEnd:
    Result:='В конец';
    msPrior:
    Result:='Назад';
    msNext:
    Result:='Вперёд';
    msCancel:
    Result:='Отменить';
    msRefresh:
    Result:='Обновить';
    msInsert:
    Result:='Добавить';
    msPost:
    Result:='Записать';
    msEmptyUserName:
    Result:='Не заполнено имя пользователя.';
    msPage:
    Result:='Страница';
    msConnectDBError:
    Result:='Не удалось подсоединиться к БД.';
    msConnectionStringIncorrect:
    Result:='Строка соединения не корректна.';
    msNoField:
    Result:='Нет поля:';
    msLoad:
    Result:='Загрузить';
    msClear:
    Result:='Очистить';
    msApplay:
    Result:='Принять';
    msSave:
    Result:='Сохранить';
    msNotAllow:
    Result:='Вам не разрешено';
    msOpenForm:
    Result:='открывать эту форму.';
    msExecuteApps:
    Result:='запускать приложения.';
    msText:
    Result:='Текст';
    msAll:
    Result:='все';
    msFormated:
    Result:='Форматированный';
    msConfigurationFile:
    Result:='Файл конфигурации';
    msNotFoundM:
    Result:='не найден';
    msNotFoundF:
    Result:='не найдена';
    msTable:
    Result:='Таблица';
    msAppRunning:
    Result:='Приложение уже запущено (возможно оно свернуто на панели задач).';
    msNotSupportedS:
    Result:='не поддерживаются';
    msPaths:
    Result:='пути';
    msTheProduct:
    Result:='Продукт';
    msProducer:
    Result:='Изготовитель';
    msVersion:
    Result:='Версия';
    msStatus:
    Result:='статус';
    msUser:
    Result:='Пользователь';
    msRole:
    Result:='Роль';
    msDataBase:
    Result:='База данных';
    msConfiguration:
    Result:='Конфигурация';
    msDebugMode:
    Result:='Режим отладки';
    msInformationAbout:
    Result:='Сведения о';
    msBuildOf:
    Result:='сборке';
    msOS:
    Result:='ОС';
    msLang:
    Result:='Язык';
    msUsers:
    Result:='пользователей';
    msDoYouWontTerminate:
    Result:='Хотите завершить';
    msApplication:
    Result:='приложение';
    msDownloadInProgress:
    Result:='Идёт закачка';
    msClearAllFind:
    Result:='Очистить поиск';
    msFind:
    Result:='Поиск';
    msFindCurrCell:
    Result:='Поиск по текущей ячейки';
    msPrint:
    Result:='Печать';
    msCopy:
    Result:='Копировать';
    msCut:
    Result:='Вырезать';
    msPast:
    Result:='Вставить';
    msBookmark:
    Result:='закладка';
    msBookmarks:
    Result:='закладки';
    msStructure:
    Result:='Структура';
    msGotoBookmark:
    Result:='Перейти к закладке';
    msOldFormat:
    Result:='Старый формат';
    msOldBookmarkFormat:
    Result:='Старый формат закладок, нет секции Title';
    msVersionsGap:
    Result:='Существенная разница в версиях. Всё может не работать.';
    msOldVersion:
    Result:='Старая версия. Некоторые особенности могут не работать.';
    msToAll:
    Result:='Всем';
    msChangePassord:
    Result:='Смена пароля';
    msOldM:
    Result:='Старый';
    msNewM:
    Result:='Новый';
    msPassword:
    Result:='пароль';
    msConfirm:
    Result:='Подтверждение';
    msHashed:
    Result:='Хешированный';
    msToHashing:
    Result:='Хешировать';
    msLogonToSystem:
    Result:='Вход в систему';
    msUserName:
    Result:='Имя пользователя';
    msNoYes:
    Result:='Нет,Да';
    msDenyMessageDev:
    Result:='У Вас нет права разработчика.';
    msDenyMessageUsr:
    Result:='Вам не разрешён вход в систему.';
    msAccessLevelsSet:
    Result:='Отключен,Только чтение,Правка,Полные права,Уровень 1,Уровень 2,Уровень 3,Уровень 4,Разработчик';
    msNotifyActionsSet:
    Result:='Выполнено,Запуск скрипта,Сообщение,Запуск приложения с ожиданием,Запуск приложения,Выход по времени';
    msCodePage:
    Result:='Кодовая страница';
    msLock:
    Result:='Заблокировать';
    msChoose:
    Result:='Выбрать';
    msEditings:
    Result:='изменения';
    msData:
    Result:='Данные';
    msReset:
    Result:='Сбросить';
    msSettings:
    Result:='настройки';
    msFields:
    Result:='полей';
    msHour:
    Result:='ч';
    msMinute:
    Result:='м';
    msSecond:
    Result:='сек';
    msMSecond:
    Result:='мсек';
    msModeOff:
    Result:='Выкл';
    msModeOn:
    Result:='Вкл';
    msStringNum:
    Result:='строке №';
    msVisualCommand:
    Result:='Визуальный/Коммандный';
    msConnectionError:
    Result:='Ошибка соединения';
    msErrorQuery:
    Result:='Ошибочный запрос.';
    msBadFindParams:
    Result:='Ошибочный запрос или не верные условия поиска.';
    msErrorInExpression:
    Result:='Ошибка в выражении.';
    msErrorQueryInExpression:
    Result:='Ошибочный запрос в параметре.';
    msTooMachParams:
    Result:='Недостаточно или много параметров в предложении.';
    msBadFieldFormad:
    Result:='Неверный формат полей.';
    msNoDATARegion:
    Result:='Нет области данных "DATA".';
    msNoTemplatesTable:
    Result:='Нет таблицы шаблонов.';
    msTemplateNotFound:
    Result:='Нет такого шаблона - ';
    msLabelNotFound:
    Result:='Такой метки нет.';
    msTemplFileNotFound:
    Result:='Нет файла шаблона.';
    msTableUsersNotFound:
    Result:='Таблица пользователей не найдена.';
    msOONotInstalled:
    Result:='OpenOffice не установлен.';
    msFailOpenDocument:
    Result:='Открыть документ не удалось.';
    msMSNotInstalled:
    Result:='Microsoft Office не установлен.';
    msWord2000Req:
    Result:='Требуется WORD 2000/XP или выше.';
    msNoOfficeInstalled:
    Result:='Никакой офис не установлен.';
    msConvertionError:
    Result:='Ошибка преобразования.';
    msAppRunError:
    Result:='Ошибка запуска.';
    msFileNotFound:
    Result:='Файл не найден.';
    msErrorInRaightExpression:
    Result:='Ошибка в выражении прав доступа.';
    msFieldNotFound:
    Result:='Поле не найдено.';
    msJanuary:
    Result:='Январь';
    msFebruary:
    Result:='Февраль';
    msMarch:
    Result:='Март';
    msApril:
    Result:='Апрель';
    msMay:
    Result:='Май';
    msJune:
    Result:='Июнь';
    msJuly:
    Result:='Июль';
    msAugust:
    Result:='Август';
    msSeptember:
    Result:='Сентябрь';
    msOctober:
    Result:='Октябрь';
    msNovember:
    Result:='Ноябрь';
    msDecember:
    Result:='Декабрь';
    msMonday:
    Result:='Понедельник';
    msTuesday:
    Result:='Вторник';
    msWednesday:
    Result:='Среда';
    msThursday:
    Result:='Четверг';
    msFriday:
    Result:='Пятница';
    msSaturday:
    Result:='Суббота';
    msSunday:
    Result:='Воскресенье';
    msEditPassword:
    Result:='Изменить пароль';
    msOldPassword:
    Result:='Старый пароль';
    msNewPassword:
    Result:='Новый пароль';
    msHashPassword:
    Result:='Хешировать пароль';
    msResetAllFieldsSettings:
    Result:='Сбросить настройки всех полей';
    msResetAllFieldsSettingsQ:
    Result:=GetDCLMessageStringDefault(msResetAllFieldsSettings)+'?';
    msResetFieldsSettings:
    Result:='Сбросить настройки полей';
    msResetFieldsSettingsQ:
    Result:=GetDCLMessageStringDefault(msResetFieldsSettings)+'?';
    msDeleteAllBookmarks:
    Result:='Удалить все закладки';
    msDeleteAllBookmarksQ:
    Result:=GetDCLMessageStringDefault(msDeleteAllBookmarks)+'?';
    msSaveFieldsSettings:
    Result:='Сохранить настройки полей';
    msNotAllowOpenForm:
    Result:='Вам не разрешено открывать формы';
    msDeleteRecordQ:
    Result:=GetDCLMessageStringDefault(msDeleteRecord)+'?';
    msPathsNotSupported:
    Result:='пути не поддерживаются';
    msSaveEditings:
    Result:='Сохранить изменения';
    msSaveEditingsQ:
    Result:=GetDCLMessageStringDefault(msSaveEditings)+'?';
    msDoYouWontTerminateApplicationQ:
    Result:='Завершить приложение?';
    msConfigurationFileNotFound:
    Result:='Файл конфигурации не найден';
    msClearContentQ:
    Result:=GetDCLMessageStringDefault(msClearContent)+'?';
    msNotifycation:
    Result:='Уведомление';
    msForUser:
    Result:='Для пользователя';
    msLoading:
    Result:='Загрузка';
    msTimeToExit:
    Result:='Выход из системы через %d секунд.';
    msDSStateSet:
    Result:='Не активен,Просмотр,Редактирование,Вставка,Установка ключа,Вычисляемые поля,Фильтрация,Новое значение,Старое значение,Текущее значение,Блочное чтение,Внутренне вычисление,Открытие';
    msNotFilter:
    Result:='Отрицание';
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

function LoadTranscodeFile(DataType:TTranscodeDataType; FileName:String; Lang:TLangName):Boolean;
var
  LangResFile:TStringList;
  S, c, vs1, tmp1:String;
  ii, p, k, d, v1, l:Integer;
  simbcodeflg:Boolean;
  lt:TIsDigitType;
begin
  If not FileExists(FileName) then
    FileName:=FileName+'.'+UpperCase(Lang);

  Result:=False;
{$IFNDEF SINGLELANG}
  If FileExists(FileName) then
  Begin
    LangResFile:=TStringList.Create;
    LangResFile.LoadFromFile(FileName{$IFNDEF FPC}, TEncoding.UTF8{$ENDIF});

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
    LangResFile.LoadFromFile(FileName{$IFNDEF FPC}, TEncoding.UTF8{$ENDIF});

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

          For k:=0 to Ord(High(NamedStringMessages)) do
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
    For k:=0 to Ord(High(NamedStringMessages)) do
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

procedure LoadLangRes(Lang:TLangName; Path:String);
var
  FileName:string;
begin
  FileName:=IncludeTrailingPathDelimiter(DefaultLangDir)+'DCLTranslate.'+UpperCase(Lang);

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
  If (MonthNum>0) and (MonthNum<13) then
    Result:=GetDCLMessageString(TStringMessages(MonthNum+Ord(msJanuary)-1))
  Else
    Result:='';
end;

function GetISO639LangCode(LangCode: String): String;
var
  tmpLang: String;
begin
  tmpLang:=LowerCase(LangCode);
  if tmpLang='ru' then Result:='RUS';
  if tmpLang='en' then Result:='ENG';
  if tmpLang='pl' then Result:='POL';
  if tmpLang='be' then Result:='BEL';
end;

function GetSystemLanguage: String;
var
{$IFDEF MSWINDOWS}
  OutputBuffer: PChar;
{$ENDIF}
{$IFDEF UNIX}
  S:string;
{$ENDIF}
begin
{$IFDEF MSWINDOWS}
  Result:=DefaultLanguage;
  OutputBuffer:=StrAlloc(90);     //alocate memory for the PChar
  try
    GetLocaleInfo(LOCALE_USER_DEFAULT, LOCALE_SABBREVLANGNAME, OutputBuffer, 89);
    Result:=UpperCase(OutputBuffer);
  finally
    StrDispose(OutputBuffer);   //alway's free the memory alocated
  end;
{$ENDIF}
{$IFDEF UNIX}
  S:='';
  lazutf8.LazGetShortLanguageID(S);
  Result:=GetISO639LangCode(S);
{$ENDIF}
end;

procedure InitLangEnv;
begin
  LangName:=GetSystemLanguage;
end;

end.
