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
  msFind:
  Result:='�����';
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
  Result:=' ��������, ��� ������ Title';
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
  msDenyMessage:
  {$IFDEF DEVELOPERMODE}
  Result:='� ��� ��� ����� ������������.';
  {$ELSE}
  Result:='��� �� �������� ���� � �������.';
  {$ENDIF}
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
//  Result:='';
//  Result:='';
//  Result:='';
//  Result:='';
  end;
end;

end.
