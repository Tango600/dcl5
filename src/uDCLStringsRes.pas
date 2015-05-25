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
