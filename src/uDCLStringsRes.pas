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
