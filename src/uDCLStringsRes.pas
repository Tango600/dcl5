unit uDCLStringsRes;
{$I DefineType.pas}

interface

uses
  SysUtils;

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
    msLogonToSystem, msUserName, msNoYes, msDenyMessage, msAccessLevelsSet, msNotifyActionsSet,
    msCodePage, msLock, msUnLock, msChoose, msEditings, msData, msReset, msSettings, msFields,
    msBookmarks, msHour, msMinute, msSecond, msMSecond, msModeOff, msModeOn);

function GetDCLMessageString(MesID: TStringMessages): String;
function GetDCLErrorString(ErrorCode: Integer; AddText: String=''):string;
Function ToDOS(Buf: String): String;

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
//  Result:='';
//  Result:='';
//  Result:='';
//  Result:='';
  end;
end;

function GetDCLErrorString(ErrorCode: Integer; AddText: String=''):string;
Var
  MessageText: String;
Begin
  MessageText:='';
  Case ErrorCode Of
  -2, -3:
  MessageText:='���� ����������';
  -1100, -1101, -1119, -1102, -1106, -1107, -1112, -1200, -1201, -1113, -1114, -1115, -1116, -1118:
  MessageText:='��������� ������. '+IntToStr(ErrorCode);
  -1111:
  MessageText:='��������� ������ ��� �� ������ ������� ������. '+IntToStr(ErrorCode);
  -1103, -1104, -1105, -1108, -1110, -1117:
  MessageText:='������ � ���������. '+IntToStr(ErrorCode);
  -1109:
  MessageText:='��������� ������ � ���������. '+IntToStr(ErrorCode);
  -4000:
  MessageText:='������������ ��� ����� ���������� � �����������. '+IntToStr(ErrorCode);
  -4002:
  MessageText:='�������� ������ �����. '+IntToStr(ErrorCode);
  -5002:
  MessageText:='��� ������� ������ "DATA". '+IntToStr(ErrorCode);
  -5003:
  MessageText:='��� ������� �������� - '+IntToStr(ErrorCode);
  -5004:
  MessageText:='��� ������ ������� - '+IntToStr(ErrorCode);
  -5005:
  MessageText:='����� ����� ���. '+IntToStr(ErrorCode);
  -5006, -5007:
  MessageText:='��� ����� �������. '+IntToStr(ErrorCode);
  -5008:
  MessageText:='������� ������������� �� �������. '+IntToStr(ErrorCode);
  -6001, -6002: // OOo
  MessageText:='OpenOffice �� ����������. '+IntToStr(ErrorCode);
  -6003:
  MessageText:='������� �������� �� �������. '+IntToStr(ErrorCode);
  -6000, -6010:
  MessageText:='Microsoft Office �� ����������. '+IntToStr(ErrorCode);
  -6011:
  MessageText:='��������� WORD 2000/XP ��� ����. '+IntToStr(ErrorCode);
  -6020:
  MessageText:='������� ���� �� ����������. '+IntToStr(ErrorCode);
  -7000:
  MessageText:='������ ��������������. '+IntToStr(ErrorCode);
  -8000:
  MessageText:='������ �������. '+IntToStr(ErrorCode);
  -8001:
  MessageText:='���� �� ������. '+IntToStr(ErrorCode);
  -9000:
  MessageText:='������ � ��������� ���� �������. '+IntToStr(ErrorCode);
  -10000, -10001, -10002:
  MessageText:='���� �� �������. '+IntToStr(ErrorCode);
  Else
    MessageText:=AddText;
  End;
  Result:=MessageText;
End;

Function ToDOS(Buf: String): String;
Var
  i: Cardinal;
Begin
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
  Result:=Buf;
End;

end.
