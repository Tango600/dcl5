{ ******************************************************* }
{ }
{ Borland Delphi Visual Component Library }
{ }
{ Copyright (c) 1999 Inprise Corporation }
{ }
{ �����������: 1998-2002 Polaris Software }
{ http://polesoft.da.ru }
{ ******************************************************* }

unit ADOConst;

interface

resourcestring
  SInvalidEnumValue='�������� Enum ��������';
  SMissingConnection='�� ������� Connection ��� ConnectionString';
  SNoDetailFilter='�������� Filter �� ����� �������������� ��� detail ������';
  SBookmarksRequired=
    '����� ������ (Dataset) �� ������������ �������� (bookmarks), ������� ��������� ��� ���������, ���������� � ������� ���������� �������';
  SMissingCommandText='�� ������� �������� %s';
  SNoResultSet='CommandText �� ���������� ���������';
  SADOCreateError=
    '������ �������� �������.  ����������, ���������, ��� Microsoft Data Access Components 2.1 (��� ����) ��������� �����������';
  SEventsNotSupported='������� �� �������������� � TableDirect ��������� �� ��������� �������';
  SUsupportedFieldType='���������������� ��� ���� (%s) � ���� %s';
  SNoMatchingADOType='��� ������������ ���� ������ ADO ��� %s';
  SConnectionRequired='����������� ��������� ��������� ��� �����. ExecuteOptions';
  SCantRequery='�� ���� ��������� ������ ����� ��������� ����������';
  SNoFilterOptions='FilterOptions �� ��������������';
{$IFNDEF VER130}
  SRecordsetNotOpen='����� ������ �� ������';
{$IFNDEF VER140}
  sNameAttr='Name';
  sValueAttr='Value';
{$ENDIF}
{$ENDIF}

implementation

end.
