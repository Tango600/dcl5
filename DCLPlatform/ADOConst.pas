{ ******************************************************* }
{ }
{ Borland Delphi Visual Component Library }
{ }
{ Copyright (c) 1999 Inprise Corporation }
{ }
{ Русификация: 1998-2002 Polaris Software }
{ http://polesoft.da.ru }
{ ******************************************************* }

unit ADOConst;

interface

resourcestring
  SInvalidEnumValue='Неверное Enum значение';
  SMissingConnection='Не указано Connection или ConnectionString';
  SNoDetailFilter='Свойство Filter не может использоваться для detail таблиц';
  SBookmarksRequired=
    'Набор данных (Dataset) не поддерживает закладки (bookmarks), которые требуются для элементов, работающих с данными нескольких записей';
  SMissingCommandText='Не указано свойство %s';
  SNoResultSet='CommandText не возвращает результат';
  SADOCreateError=
    'Ошибка создания объекта.  Пожалуйста, проверьте, что Microsoft Data Access Components 2.1 (или выше) правильно установлены';
  SEventsNotSupported='События не поддерживаются с TableDirect курсорами на серверной стороне';
  SUsupportedFieldType='Неподдерживаемый тип поля (%s) в поле %s';
  SNoMatchingADOType='Нет совпадающего типа данных ADO для %s';
  SConnectionRequired='Соединяющий компонент требуется для асинх. ExecuteOptions';
  SCantRequery='Не могу выполнить запрос после изменения соединения';
  SNoFilterOptions='FilterOptions не поддерживается';
{$IFNDEF VER130}
  SRecordsetNotOpen='Набор данных не открыт';
{$IFNDEF VER140}
  sNameAttr='Name';
  sValueAttr='Value';
{$ENDIF}
{$ENDIF}

implementation

end.
