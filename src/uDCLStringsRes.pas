unit uDCLStringsRes;
{$I DefineType.pas}

interface

uses
  SysUtils, Classes,
  uDCLConst;

type
  TStringMessages=(msNone, msClose, msOpen, msEdit, msDelete, msModified, msInputVulues, msInBegin,
    msInEnd, msPrior, msNext, msCancel, msRefresh, msInsert, msPost, msEmptyUserName, msPage,
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
    msBookmarks, msHour, msMinute, msSecond, msMSecond, msModeOff, msModeOn, msStringNum, msVisualCommand);

procedure LoadLangRes(Lang:TISO639_3);
function GetDCLMessageString(MessID: TStringMessages): String;
function GetDCLErrorString(ErrorCode: Integer; AddText: String=''):string;
Function ToDOS(Buf: String): String;

implementation

uses
  uDCLData;

const
  StringDelim=#39;
  NamedStringMessages:Array[TStringMessages] of String=('msNone', 'msClose', 'msOpen', 'msEdit', 'msDelete', 'msModified', 'msInputVulues', 'msInBegin',
    'msInEnd', 'msPrior', 'msNext', 'msCancel', 'msRefresh', 'msInsert', 'msPost', 'msEmptyUserName', 'msPage',
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
    'msBookmarks', 'msHour', 'msMinute', 'msSecond', 'msMSecond', 'msModeOff', 'msModeOn', 'msStringNum', 'msVisualCommand');

var
  StringMessages:array[TStringMessages] of string;

function GetDCLMessageStringDefault(MesID: TStringMessages): String;
begin
  Case GPT.Lang of
  lgRUS:
    case MesID of
    msNone:
    Result:='<Нет>';
    msNot:
    Result:='не';
    msIn:
    Result:='В';
    msClose:
    Result:='Закрыть';
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
    Result:=' закладок, нет секции Title';
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
  //  Result:='';
  //  Result:='';
    end;
  End;
end;

procedure LoadLangRes(Lang:TISO639_3);
var
  LangResFile:TStringList;
  FileName, S, msID, MessageString:string;
  i, p, k, FindNum, Delims, StartDelim, EndDelim:Integer;
begin
  FileName:='DCLTranslate.';
  Case Lang of
  lgRUS:FileName:=FileName+'RUS';
  lgENG:FileName:=FileName+'ENG';
  End;

  If FileExists(Path+FileName) then
  Begin
    LangResFile:=TStringList.Create;
    LangResFile.LoadFromFile(Path+FileName);

    For i:=1 to LangResFile.Count do
    Begin
      S:=LangResFile[i-1];

      p:=Pos(':=', S);
      If p>0 then
      Begin
        FindNum:=-1;
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
              FindNum:=k;
              StringMessages[TStringMessages(FindNum)]:=MessageString;
              Break;
            End;
          End;
        End;
      End;

    End;

    LangResFile.Free;
  End
  Else
    For k:=0 to Ord(High(NamedStringMessages))-1 do
      StringMessages[TStringMessages(k)]:=GetDCLMessageStringDefault(TStringMessages(k));
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
  Case GPT.Lang of
  lgRUS:
    Case ErrorCode Of
    -2, -3:
    MessageText:='Сбой соединения';
    -1100, -1101, -1119, -1102, -1106, -1107, -1112, -1200, -1201, -1113, -1114, -1115, -1116, -1118:
    MessageText:='Ошибочный запрос. '+IntToStr(ErrorCode);
    -1111:
    MessageText:='Ошибочный запрос или не верные условия поиска. '+IntToStr(ErrorCode);
    -1103, -1104, -1105, -1108, -1110, -1117:
    MessageText:='Ошибка в выражении. '+IntToStr(ErrorCode);
    -1109:
    MessageText:='Ошибочный запрос в параметре. '+IntToStr(ErrorCode);
    -4000:
    MessageText:='Недостаточно или много параметров в предложении. '+IntToStr(ErrorCode);
    -4002:
    MessageText:='Неверный формат полей. '+IntToStr(ErrorCode);
    -5002:
    MessageText:='Нет области данных "DATA". '+IntToStr(ErrorCode);
    -5003:
    MessageText:='Нет таблицы шаблонов - '+IntToStr(ErrorCode);
    -5004:
    MessageText:='Нет такого шаблона - '+IntToStr(ErrorCode);
    -5005:
    MessageText:='Такой метки нет. '+IntToStr(ErrorCode);
    -5006, -5007:
    MessageText:='Нет файла шаблона. '+IntToStr(ErrorCode);
    -5008:
    MessageText:='Таблица пользователей не найдена. '+IntToStr(ErrorCode);
    -6001, -6002: // OOo
    MessageText:='OpenOffice не установлен. '+IntToStr(ErrorCode);
    -6003:
    MessageText:='Открыть документ не удалось. '+IntToStr(ErrorCode);
    -6000, -6010:
    MessageText:='Microsoft Office не установлен. '+IntToStr(ErrorCode);
    -6011:
    MessageText:='Требуется WORD 2000/XP или выше. '+IntToStr(ErrorCode);
    -6020:
    MessageText:='Никакой офис не установлен. '+IntToStr(ErrorCode);
    -7000:
    MessageText:='Ошибка преобразования. '+IntToStr(ErrorCode);
    -8000:
    MessageText:='Ошибка запуска. '+IntToStr(ErrorCode);
    -8001:
    MessageText:='Файл не найден. '+IntToStr(ErrorCode);
    -9000:
    MessageText:='Ошибка в выражении прав доступа. '+IntToStr(ErrorCode);
    -10000, -10001, -10002:
    MessageText:='Поле не найдено. '+IntToStr(ErrorCode);
    Else
      MessageText:=AddText;
    End;
  End;
  Result:=MessageText;
End;

Function ToDOS(Buf: String): String;
Var
  i: Cardinal;
Begin
  Case GPT.Lang of
  lgRUS:
    For i:=1 To Length(Buf) Do
    Begin
      Case Ord(Buf[i]) Of
      168:
      Buf[i]:=Chr(240);
      184:
      Buf[i]:=Chr(241);
      192..239:
      Buf[i]:=Chr(Ord(Buf[i])-64);
      240..255:
      Buf[i]:=Chr(Ord(Buf[i])-16);
      End
    End;
  End;
  Result:=Buf;
End;

end.
