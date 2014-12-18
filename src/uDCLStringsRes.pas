unit uDCLStringsRes;
{$I DefineType.pas}

interface

type
  TStringMessages=(msNone, msClose, msOpen, msEdit, msDelete, msModified, msInputVulues, msInBegin,
    msInEnd, msPrior, msNext, msCancel, msRefresh, msInsert, msPost, msEmptyUserName, msPage,
    msConnectDBError, msClearContent, msConnectionStringIncorrect, msNoField, msDeleteRecord,
    msLoad, msClear, msSave, msNotAllow, msOpenForm, msExecuteApps, msText, msAll, msFormated,
    msConfigurationFile, msNotFoundM, msNotFoundF, msTable, msAppRunning, msNot, msNotSupportedS,
    msPaths, msTheProduct, msProducer, msVersion, msStatus, msUser, msRole, msDataBase, msConfiguration,
    msDebugMode, msInformationAbout, msBuildOf, msOS, msLang, msUsers, msDoYouWontTerminate,
    msApplication, msDownloadInProgress, msFind, msPrint, msCopy, msCut, msPast, msBookmark,
    msStructure, msGotoBookmark, msOldFormat, msOldBookmarkFormat, msVersionsGap, msOldVersion,
    msChangePassord, msOldM, msNewM, msPassword, msConfirm, msHashed, msToHashing, msToAll, msIn,
    msLogonToSystem, msUserName, msNoYes, msDenyMessage, msAccessLevelsSet, msNotifyActionsSet,
    msCodePage, msLock, msUnLock, msChoose, msEditings, msData, msReset, msSettings, msFields,
    msBookmarks);

function GetDCLMessageString(MesID: TStringMessages): String;

implementation

function GetDCLMessageString(MesID: TStringMessages): String;
begin
  case MesID of
  msNone:
  Result:='';
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
  msFind:
  Result:='Поиск';
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
  msDenyMessage:
  {$IFDEF DEVELOPERMODE}
  Result:='У Вас нет права разработчика.';
  {$ELSE}
  Result:='Вам не разрешён вход в систему.';
  {$ENDIF}
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
//  Result:='';
//  Result:='';
//  Result:='';
//  Result:='';
  end;
end;

end.
