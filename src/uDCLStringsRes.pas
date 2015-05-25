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
    msBookmarks, msHour, msMinute, msSecond, msMSecond, msModeOff, msModeOn, msStringNum, msVisualCommand,
    msConnectionError, msErrorQuery, msBadFindParams, msErrorInExpression, msErrorQueryInExpression,
    msTooMachParams, msBadFieldFormad, msNoDATARegion, msNoTemplatesTable, msTemplateNotFound, msLabelNotFound,
    msTemplFileNotFound, msTableUsersNotFound, msOONotInstalled, msFailOpenDocument, msMSNotInstalled, msWord2000Req,
    msNoOfficeInstalled, msConvertionError, msAppRunError, msFileNotFound, msErrorInRaightExpression, msFieldNotFound);

procedure LoadLangRes(Lang:TISO639_3);
function GetDCLMessageString(MessID: TStringMessages): String;
function GetDCLErrorString(ErrorCode: Integer; AddText: String=''):string;
Function ToDOS(Buf: String): String;

implementation

uses
  uDCLData, uDCLUtils;

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
    'msBookmarks', 'msHour', 'msMinute', 'msSecond', 'msMSecond', 'msModeOff', 'msModeOn', 'msStringNum', 'msVisualCommand',
    'msConnectionError', 'msErrorQuery', 'msBadFindParams', 'msErrorInExpression', 'msErrorQueryInExpression',
    'msTooMachParams', 'msBadFieldFormad', 'msNoDATARegion', 'msNoTemplatesTable', 'msTemplateNotFound', 'msLabelNotFound',
    'msTemplFileNotFound', 'msTableUsersNotFound', 'msOONotInstalled', 'msFailOpenDocument', 'msMSNotInstalled', 'msWord2000Req',
    'msNoOfficeInstalled', 'msConvertionError', 'msAppRunError', 'msFileNotFound', 'msErrorInRaightExpression', 'msFieldNotFound');

type
  TTranscodeType=(ttDirect, ttSub, ttAdd);
  TTranscodeData=Record
    CodeFrom1, CodeFrom2, TargetGap:Integer;
    TagertCode:String;
    TranscodeType:TTranscodeType;
  end;

var
  StringMessages:array[TStringMessages] of string;
  TranscodeData:Array of TTranscodeData;


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
  //  Result:='';
    end;
  End;
end;

procedure LoadLangRes(Lang:TISO639_3);
var
  LangResFile:TStringList;
  FileName, S, msID, MessageString:string;
  i, p, k, Delims, StartDelim, EndDelim:Integer;
begin
  FileName:='DCLTranslate.'+LangIDToString(Lang);

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
    MessageText:=GetDCLMessageString(msConnectionError);
    -1100, -1101, -1119, -1102, -1106, -1107, -1112, -1200, -1201, -1113, -1114, -1115, -1116, -1118:
    MessageText:=GetDCLMessageString(msErrorQuery)+' '+IntToStr(ErrorCode);
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

procedure LoadTranscodeFile(FileName:String; Lang:TISO639_3);
var
  LangResFile:TStringList;
  S, c, vs1:String;
  i, p, k, d, v1:Integer;
  simbcodeflg:Boolean;
begin
  FileName:=FileName+'.'+LangIDToString(Lang);

  If FileExists(Path+FileName) then
  Begin
    LangResFile:=TStringList.Create;
    LangResFile.LoadFromFile(Path+FileName);

    For i:=1 to LangResFile.Count do
    Begin
      S:=LangResFile[i-1];
      p:=Pos(':', S);
      If p<>0 then
      Begin
        SetLength(TranscodeData, i);
        vs1:=Copy(S, 1, p-1);
        If (Pos('-', vs1)=0) then
        Begin
          k:=StrToInt(Copy(S, 1, p-1));
          TranscodeData[i-1].CodeFrom1:=k;
          TranscodeData[i-1].CodeFrom2:=k;
        End
        Else
        Begin
          k:=StrToInt(Copy(S, 1, Pos('-', vs1)-1));
          TranscodeData[i-1].CodeFrom1:=k;
          c:=Copy(S, Pos('-', vs1)+1, p-1-Pos('-', vs1));
          k:=StrToInt(c);
          TranscodeData[i-1].CodeFrom2:=k;
        End;

        d:=Pos(';', S);
        If d=0 then
          d:=Length(S);
        c:=Copy(S, p+1, d-p-1);
        simbcodeflg:=False;
        If Length(c)>0 then
        Begin
          vs1:='';
          TranscodeData[i-1].TranscodeType:=ttDirect;

          For v1:=1 to Length(c) do
          Begin
            If simbcodeflg and (c[v1] in ['0'..'9']) then
              vs1:=vs1+c[v1];

            If c[v1]='#' then
            Begin
              simbcodeflg:=True;
              If vs1<>'' then
                TranscodeData[i-1].TagertCode:=TranscodeData[i-1].TagertCode+Chr(StrToInt(vs1));
              vs1:='';
            End;
            If c[v1]='-' then
            Begin
              TranscodeData[i-1].TranscodeType:=ttSub;
              simbcodeflg:=True;
              If vs1<>'' then
                TranscodeData[i-1].TargetGap:=StrToInt(vs1);
            End;
            If c[v1]='+' then
            Begin
              TranscodeData[i-1].TranscodeType:=ttAdd;
              simbcodeflg:=True;
              If vs1<>'' then
                TranscodeData[i-1].TargetGap:=StrToInt(vs1);
            End;
          End;
          If vs1<>'' then
            TranscodeData[i-1].TagertCode:=TranscodeData[i-1].TagertCode+Chr(StrToInt(vs1));
          vs1:='';
        End;
      End;
    End;
  End;
end;


Function Transcode(const Buf: String): String;
Var
  i, j: Cardinal;
  Match:Boolean;
  ts:String;
begin
  Result:='';
  For i:=1 To Length(Buf) Do
  Begin
    Match:=False;
	  For j:=1 to Length(TranscodeData) do
	  Begin
	    If TranscodeData[j-1].CodeFrom1=TranscodeData[j-1].CodeFrom2 then
	    Begin
        If Ord(Buf[i])=TranscodeData[j-1].CodeFrom1 then
        Begin
          Match:=True;
          break;
        End;
			End
	    Else
  	    If TranscodeData[j-1].CodeFrom1<TranscodeData[j-1].CodeFrom2 then
  	    Begin
          If Ord(Buf[i])>=TranscodeData[j-1].CodeFrom1 then
            If Ord(Buf[i])<=TranscodeData[j-1].CodeFrom2 then
            Begin
              Match:=True;
              break;
            End;
	  	  End;
		End;

    If Match then
    Begin
    Case TranscodeData[j-1].TranscodeType of
    ttDirect:
      ts:=TranscodeData[j-1].TagertCode;
    ttAdd:
      ts:=Chr(Ord(Buf[i])+Ord(TranscodeData[j-1].TagertCode[1]));
    ttSub:
      ts:=Chr(Ord(Buf[i])-Ord(TranscodeData[j-1].TagertCode[1]));
		end;
    End
    Else
      ts:=Buf[i];

    Result:=Result+ts;
	End;
end;


end.
