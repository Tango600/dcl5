unit uDCLUtils;
{$I DefineType.pas}

interface

uses
  SysUtils, Forms, ExtCtrls, StrUtils,
{$IFDEF MSWINDOWS}
  Windows, ShellApi, Variants, ShlObj,
  ActiveX, ComObj,
{$ENDIF}
{$IFDEF UNIX}
  cwstring, process, unix, lclintf,
{$ENDIF}
{$IFDEF FPC}
  InterfaceBase, LCLType,
{$ENDIF}
{$IFNDEF FPC}
  JPEG,
{$ENDIF}
  Dialogs,
  uUDL,
  uLZW, uDCLTypes,
  Controls, Classes, Graphics, DateUtils,
  uDCLData, uDCLConst, uStringParams;


function ValidObject(const AObj: TObject): Boolean;
Procedure GetParamsStructure(Params:TStringList);
Procedure DebugProc(ActionStr: String);
Function KeyState(Key: Integer): Boolean;
Function CompareString(S1, S2: String): Boolean;
Function ShowErrorMessage(ErrorCode: Integer; AddText: String=''): Integer;
Function StrToIntEx(St: String): LongInt;
Function StrToFloatEx(St: String): Real;
Function HexToInt64(HexStr: String): Int64;
Function HexToInt(HexStr: String): Integer;
Function Pow(const Base:Cardinal; PowNum: Word): Cardinal; overload;
Function Pow(Const Base: Real; PowNum: Word): Real; overload;
Procedure DeleteNonPrintSimb(Var S: String);
Function CountSimb(S: String; C: Char): Integer;
Function TimeStampToStr(NowDate: TDateTime): String;
Function TimeToStr_(Time: TDateTime): String;
Function DateToStr_(Date: TDate): String;
Function LeadingZero(Const aVal: Word): String;
Function CopyCut(Var S: String; From, Count: Word): String;
function ReplaseCPtoWIN(CodePageName:String):String;
function ReplaseWINtoCP(CodePageName:String):String;
//Function FindInArray(KeyWord:String; SourceArray:Array);

{$IFDEF MSWINDOWS}
procedure ShellExecute(const AWnd: HWND; const AOperation, AFileName: String; const AParameters: String = ''; const ADirectory: String = ''; const AShowCmd: Integer = SW_SHOWNORMAL);
{$ENDIF}

Function ExecAndWait(Const FileName: ShortString; Const WinState: Word; Wait:Boolean=True): Boolean;
Procedure Exec(Const FileName, Directory: String);
Procedure ExecApp(const App: String);
Procedure OpenDir(Dir: string);
Procedure InitGetAppConfigDir;
function GetUserDocumentsDir: String;
Function IsUNCPath(Path: String): Boolean;
Function IsFullPath(Path: String): Boolean;
Function NoFileExt(const FileName:String):Boolean;
Function FakeFileExt(Const FileName, Ext: String): String;
Function AddToFileName(Const FileName, AddStr: String): String;

Function DrawBMPButton(Const BMPType: String): TBitmap;
function GetIcon: TIcon;

Function FindDisableAction(Action: String): Boolean;
Function TranslateDigitToUserLevel(Level: byte): TUserLevelsType; overload;
Function TranslateDigitToUserLevel(Level: String): TUserLevelsType; overload;
Procedure TranslateProc(Var CallProc: String; Var Factor: Word; Query: TDCLDialogQuery);
Function GetStringDataType(const S: String): TIsDigitType;
function CheckStrFmtType(const S:string; SimplyFormatType:TSimplyFieldType):Boolean;
function FindSubstrInString(AText:string; AValues:Array of String):Integer;

Function GetFileNameToTranslite(Const FullFileName: String): String;
function PosInSet(SimbolsSet, SourceStr: String): Cardinal;
Function ShiftDown: Boolean;
Function GetTempFileName(Ext: String): String;
Function UpTime: Cardinal;
Function HashString(S: String): String;

Function IsReturningQuery(SQQL: String): Boolean;
function TrimSQLComment(SQLText: String): String;
function FindSQLWhere(SQL, FindToken:String; Opened:Boolean=True):Integer;

Procedure ExecuteStatement(Code: String);
Function GetOnOffMode(Mode: Boolean): String;
Function ExtractSection(Var SectionStr: String): String;
function GetGraficFileType(FileName: string): TGraficFileType;
function GetExtByType(FileType:TGraficFileType):String;
{$IFDEF FPC}
Function Date: TDateTime;
Function Time: TDateTime;
{$ENDIF}
Function Calculate(Formula: String): String; {$IFNDEF FPC}forward; {$ENDIF}
Function RunScript(Code: String): String;
procedure ExecVBS(VBSScript: String);
Procedure AddCodeScript(Code: TStringList);
Function CopyStrings(FromString, ToString: String; Where: TStringList): TStringList;

function GetIniToRole(UserID: String): String;
function GetFormPosString(FForm:TDBForm; DialogName:String): String;
procedure SaveMainFormPos(FDCLLogOn:TDCLLogOn; FForm:TDBForm; DialogName:String);
procedure LoadMainFormPos(FDCLLogOn:TDCLLogOn; var FForm:TDBForm; DialogName:String);

function GetScreen:TBitmap;
function ConvertToJPEG(BitMap:TBitmap; Quality:Byte=JPEGCompressionQuality):TJpegImage;

function ConvertBinToXBase(Data:TMemoryStream; Base:Byte):TMemoryStream;
function ConvertXBaseToBin(Data:TMemoryStream; Base:Byte):TMemoryStream;
function SaveFormatedBlock(Data:TMemoryStream; Width:Word):TMemoryStream;
function LoadFormatedBlock(Data:TMemoryStream):TMemoryStream;

function DecodeScriptData(Data:TMemoryStream):TStringList;
function EncodeScriptData(Script:TStringList):TMemoryStream;

function GetScriptVersion(Data:TMemoryStream):String;

function GetTimeFormat(mSec: Cardinal): String;

function IsDigits(Value: String): Boolean;

implementation

uses
  SumProps, uDCLResources, uDCLDBUtils, uDCLMultiLang, uDCLOfficeUtils, MD5;

function ValidObject(const AObj: TObject): Boolean;
begin
  Result:=Assigned(AObj){$IFDEF AUTOREFCOUNT}and(not AObj.Disposed){$ENDIF};
end;

Function LeadingZero(Const aVal: Word): String;
Begin
  If aVal<10 Then
    Result:='0'+IntToStr(aVal)
  Else
    Result:=IntToStr(aVal);
End;

{$IFDEF FPC}
Function Date: TDateTime;
Begin
  Result:=Now;
End;

Function Time: TDateTime;
Begin
  Result:=Now;
End;
{$ENDIF}

Function DateToStr_(Date: TDate): String;
Var
  tmpS: system.string;
Begin
  tmpS:='';
  DateTimeToString(tmpS, GPT.DateFormat, Date);
  Result:=tmpS;
End;

Function TimeToStr_(Time: TDateTime): String;
Var
  tmpS: system.string;
Begin
  tmpS:='';
  DateTimeToString(tmpS, GPT.TimeFormat, Time);
  Result:=tmpS;
End;

Function TimeStampToStr(NowDate: TDateTime): String;
Begin
  Result:=DateToStr_(NowDate)+' '+TimeToStr_(NowDate);
End;

Function ShowErrorMessage(ErrorCode: Integer; AddText: String=''): Integer;
Var
  MessageText: String;
Begin
  Result:=0;
  MessageText:=GetDCLErrorString(ErrorCode, AddText);

  If ErrorCode<0 Then
  Begin
    If GPT.CurrentRunningScrString>0 Then
      MessageText:=MessageText+' / '+AddText+LineEnding+
        GetDCLMessageString(msIn)+' '+GetDCLMessageString(msStringNum)+'('+GetDCLMessageString(msVisualCommand)+') : '+
        IntToStr(GPT.CurrentRunningScrString)+'/-1';

    Result:=MessageDlg(MessageText, mtError, [mbOK], 0);
  End
  Else
    Case ErrorCode Of
    1:
      Result:=MessageDlg(MessageText, mtWarning, [mbOK], 0);
    0:
      Result:=MessageDlg(MessageText, mtError, [mbOK], 0);
    9:
      Result:=MessageDlg(MessageText, mtInformation, [mbOK], 0);
    10:
      If MessageDlg(MessageText, mtConfirmation, mbOKCancel, 0)=1 Then
        Result:=1;
    End;
end;

Procedure DeleteNonPrintSimb(Var S: String);
Var
  L: Integer;
  itabsize: byte;
Begin
  L:=Length(S);
  While L<>0 Do
  Begin
    If S[L]=#10 Then
      S[L]:=' ';
    If S[L]=#9 Then
    Begin
      For itabsize:=1 To TabSize Do
        Insert(' ', S, L);
    End;
    If (S[L]=#13)Or(S[L]=#0) Then
      Delete(S, L, 1);
    Dec(L);
  End;
End;

Function CountSimb(S: String; C: Char): Integer;
Var
  L: Integer;
Begin
  Result:=0;
  For L:=1 To Length(S) Do
    If S[L]=C Then
      Inc(Result, 1);
End;

Function UpTime: Cardinal;
Begin
  Result:={$IFDEF MSWINDOWS}GetTickCount
{$ELSE}
    ((StrToInt(FormatDateTime('H', Time))*3600+StrToInt(FormatDateTime('N', Time))*60+
    StrToInt(FormatDateTime('S', Time)))*1000)+StrToInt(FormatDateTime('Z', Time));
{$ENDIF};
End;

Function GetTempFileName(Ext: String): String;
Begin
  If Ext<>'' then
  Begin
    If Ext[1]='.' then
      Delete(Ext, 1, 1);
    Result:='tmp'+IntToStr(UpTime)+'.'+Ext;
  End
  Else
    Result:='tmp'+IntToStr(UpTime);
End;

function CheckStrFmtType(const S:string; SimplyFormatType:TSimplyFieldType):Boolean;
Begin
  Case SimplyFormatType of
  sftNotDefine, sftString:Result:=True;
  sftDigit:Result:=GetStringDataType(S)=idDigit;
  sftFloat:Result:=GetStringDataType(S)=idFloatDigit;
  sftDateTime:Result:=GetStringDataType(S)=idDateTime;
  End;
End;

function FindSubstrInString(AText:string; AValues:Array of String):Integer;
var
  i, MaxLong:Integer;
Begin
  Result:=-1;
  MaxLong:=0;
  For I := Low(AValues) to High(AValues) do
    If PosEx(AValues[I], AText)<>0 then
    begin
      If MaxLong<Length(AValues[I]) then
      Begin
        MaxLong:=Length(AValues[I]);
        Result:=i;
      End;
    end;
End;

Function GetFileNameToTranslite(Const FullFileName: String): String;
Var
  FileName, NewFileName, FilePath: String;
Begin
  FileName:=ExtractFileName(FullFileName);
  FilePath:=ExtractFilePath(FullFileName);

  NewFileName:=Transcode(tdtTranslit, FileName);

  Result:=FilePath+NewFileName;
End;

{$IFDEF MSWINDOWS}
Function KeyState(Key: Integer): Boolean;
Begin
{$R-}
  Result:=HiWord(GetKeyState(Key))<>0;
{$R+}
End;

Function ExecAndWait(Const FileName: ShortString; Const WinState: Word; Wait:Boolean=True): Boolean;
Var
  StartInfo: TStartupInfo;
  ProcInfo: TProcessInformation;
  CmdLine: ShortString;
Begin
  CmdLine:=FileName;
  FillChar(StartInfo, SizeOf(StartInfo), #0);
  With StartInfo Do
  Begin
    cb:=SizeOf(StartInfo);
    dwFlags:=STARTF_USESHOWWINDOW;
    wShowWindow:=WinState;
  End;
  Result:=CreateProcess(Nil, PChar(String(CmdLine)), Nil, Nil, False, CREATE_NEW_CONSOLE Or
    NORMAL_PRIORITY_CLASS, Nil, Nil, StartInfo, ProcInfo);
  { Ожидаем завершения приложения }
  If Result and Wait Then
  Begin
    WaitForSingleObject(ProcInfo.hProcess, INFINITE);
    { Free the Handles }
    CloseHandle(ProcInfo.hProcess);
    CloseHandle(ProcInfo.hThread);
  End;
End;

procedure ShellExecute(const AWnd: HWND; const AOperation, AFileName: String; const AParameters: String = ''; const ADirectory: String = ''; const AShowCmd: Integer = SW_SHOWNORMAL);
var
  ExecInfo: TShellExecuteInfo;
  NeedUninitialize: Boolean;
begin
  Assert(AFileName <> '');
 
  NeedUninitialize := SUCCEEDED(CoInitializeEx(nil, COINIT_APARTMENTTHREADED or COINIT_DISABLE_OLE1DDE));
  try
    FillChar(ExecInfo, SizeOf(ExecInfo), 0);
    ExecInfo.cbSize := SizeOf(ExecInfo);
 
    ExecInfo.Wnd := AWnd;
    ExecInfo.lpVerb := Pointer(AOperation);
    ExecInfo.lpFile := PChar(AFileName);
    ExecInfo.lpParameters := Pointer(AParameters);
    ExecInfo.lpDirectory := Pointer(ADirectory);
    ExecInfo.nShow := AShowCmd;
    ExecInfo.fMask := {$IFnDEF FPC}SEE_MASK_NOASYNC{$ELSE}SEE_MASK_FLAG_DDEWAIT{$ENDIF}
                   or SEE_MASK_FLAG_NO_UI;
    {$IFDEF UNICODE}
    // Необязательно, см. http://www.transl-gunsmoker.ru/2015/01/what-does-SEEMASKUNICODE-flag-in-ShellExecuteEx-actually-do.html
    ExecInfo.fMask := ExecInfo.fMask or SEE_MASK_UNICODE;
    {$ENDIF}
 
    {$WARN SYMBOL_PLATFORM OFF}
    Win32Check({$IFDEF FPC}{$ifdef UNICODE}ShellExecuteExW{$ELSE}ShellExecuteExA{$ENDIF}{$ELSE}ShellExecuteEx{$ENDIF}(@ExecInfo));
    {$WARN SYMBOL_PLATFORM ON}
  finally
    if NeedUninitialize then
      CoUninitialize;
  end;
end;

procedure ExecApp(const App: String);
var
  SI: TStartupInfo;
  PI: TProcessInformation;
  CmdLine: String;
begin
  Assert(App <> '');

  CmdLine := App;
  UniqueString(CmdLine);

  FillChar(SI, SizeOf(SI), 0);
  FillChar(PI, SizeOf(PI), 0);
  SI.cb := SizeOf(SI);
  SI.dwFlags := STARTF_USESHOWWINDOW;
  SI.wShowWindow := SW_SHOWNORMAL;

  SetLastError(ERROR_INVALID_PARAMETER);
  {$WARN SYMBOL_PLATFORM OFF}
  Win32Check(CreateProcess(nil, PChar(CmdLine), nil, nil, False, CREATE_DEFAULT_ERROR_MODE {$IFDEF UNICODE}or CREATE_UNICODE_ENVIRONMENT{$ENDIF}, nil, nil, SI, PI));
  {$WARN SYMBOL_PLATFORM ON}
  CloseHandle(PI.hThread);
  CloseHandle(PI.hProcess);
end;

Procedure Exec(Const FileName, Directory: String);
Begin
  ShellExecute(0, '', FileName, '', Directory, SW_SHOWNORMAL);
End;

Procedure OpenDir(Dir: string);
Begin
  ExecApp('EXPLORER.exe /e, '+PChar(Dir));
End;

function GetSpecialPath(CSIDL: Word): string;
var
  S: string;
begin
  SetLength(S, MAX_PATH-1);
  if not SHGetSpecialFolderPath(0, PChar(S), CSIDL, True) then
    S:='';
  S:=S+#0#0;
  Result:=String(PChar(S));
end;

{$ENDIF}
{$IFDEF UNIX}

function GetMacAddress: string;
var
  aProcess: TProcess;
  aStrings: TStringList;
  aString, aBuffer: String;
  i: Integer;
begin
  Result:='00-00-00-00-00-00';
  aProcess:=TProcess.Create(Nil);
  aProcess.Commandline:='/sbin/ifconfig';
  aProcess.Options:=[poUsePipes, poNoConsole];
  aProcess.Execute;
  SetLength(aBuffer, 3000);
  Repeat
    i:=aProcess.Output.Read(aBuffer[1], Length(aBuffer));
    aString:=aString+Copy(aBuffer, 1, i);
  Until i=0;
  aProcess.Free;
  aStrings:=TStringList.Create;
  aStrings.Text:=aString;
  For i:=0 To aStrings.Count-1 Do
    If Not(Pos('HWaddr ', aStrings[i])=0) Then
    Begin
      aString:=aStrings[i];
      Delete(aString, 1, Pos('HWaddr ', aString)+6);
      Result:=aString;
    End;
  aStrings.Free;
end;

Function KeyState(Key: Integer): Boolean;
Begin
  Result:=GetKeyState(Key)<>0;
End;

Function ExecuteApp(App: String; Wait: Boolean=False): Boolean;
Var
  aProcess: TProcess;
Begin
  Try
    aProcess:=TProcess.Create(nil);
    aProcess.Commandline:=App;
    If Wait then
      aProcess.Options:=aProcess.Options+[poWaitOnExit, poUsePipes];
    aProcess.Execute;
    Result:=True;
    FreeAndNil(aProcess);
  Except
    Result:=False;
  end;
End;

Procedure ExecApp(const App: String);
Begin
  ExecuteApp(App);
End;

Function ExecAndWait(Const FileName: ShortString; Const WinState: Word; Wait:Boolean=True): Boolean;
Begin
  Result:=ExecuteApp(FileName, Wait);
End;

Procedure Exec(Const FileName, Directory: String);
Begin
  ExecuteApp(FileName);
End;

Procedure OpenDir(Dir: string);
Begin
  ExecuteApp('xdg-open '+Dir);
End;

{$ENDIF}

Function ShiftDown: Boolean;
Begin
  Result:=KeyState(VK_SHIFT);
End;

Function CompareString(S1, S2: String): Boolean;
Begin
  Result:=AnsiLowerCase(S1)=AnsiLowerCase(S2);
End;

function GetIcon: TIcon;
Var
  Marker: Cardinal;
  MS, BS: TMemoryStream;
Begin
  MS:=TMemoryStream.Create;
  MS.Write(DCLRunIcon, Length(DCLRunIcon));

  If MS.Size>0 Then
  Begin
    Marker:=0;
    MS.Position:=0;
    MS.Read(Marker, 3);

    If Marker=PAGSignature Then // PAG Signature
    Begin
      // Compressed BMP/
      BS:=TMemoryStream.Create;
      BS.Position:=0;
      DecompressProc(MS, BS);
      BS.Position:=0;
      MS.Position:=0;
      MS.CopyFrom(BS, BS.Size);
      FreeAndNil(BS);
    End;

    Result:=TIcon.Create;
    MS.Position:=0;
    Result.LoadFromStream(MS);
  End
  Else
    Result:=TIcon.Create;

  FreeAndNil(MS);
End;

Function DrawBMPButton(Const BMPType: String): TBitmap;
Const
  BMPPos=0;
Var
  Marker: Cardinal;
  MS, BS: TMemoryStream;
Begin
  MS:=TMemoryStream.Create;
  If CompareString(BMPType, 'find') Then
    MS.Write(FindBMP, Length(FindBMP));
  If CompareString(BMPType, 'FindCurrCell') Then
    MS.Write(FindCurrCellBMP, Length(FindCurrCellBMP));
  If CompareString(BMPType, 'ClearAllFind') Then
    MS.Write(FindCurrCellBMP_Neg, Length(FindCurrCellBMP_Neg));
  If CompareString(BMPType, 'print') Then
    MS.Write(PrintBMP, Length(PrintBMP));
  If CompareString(BMPType, 'structure') Then
    MS.Write(StructBMP, Length(StructBMP));
  If CompareString(BMPType, 'esc') Then
    MS.Write(Esc, Length(Esc));
  If CompareString(BMPType, 'bookmark') Then
    MS.Write(Bitmap_BookMark, Length(Bitmap_BookMark));
  If CompareString(BMPType, 'load') Then
    MS.Write(Bitmap_Load, Length(Bitmap_Load));
  If CompareString(BMPType, 'save') Then
    MS.Write(Bitmap_Save, Length(Bitmap_Save));
  If CompareString(BMPType, 'clear') Then
    MS.Write(Bitmap_Clear, Length(Bitmap_Clear));
  If CompareString(BMPType, 'cancel') Then
    MS.Write(Bitmap_X, Length(Bitmap_X));
  If CompareString(BMPType, 'FormDotActive') Then
    MS.Write(FormDotActive, Length(FormDotActive));
  If CompareString(BMPType, 'FormDotInactive') Then
    MS.Write(FormDotInactive, Length(FormDotInactive));

  If CompareString(BMPType, 'cut') Then
    MS.Write(Bitmap_Cut, Length(Bitmap_Cut));
  If CompareString(BMPType, 'copy') Then
    MS.Write(Bitmap_Copy, Length(Bitmap_Copy));
  If CompareString(BMPType, 'paste') Then
    MS.Write(Bitmap_Paste, Length(Bitmap_Paste));
  If CompareString(BMPType, 'undo') Then
    MS.Write(Bitmap_Undo, Length(Bitmap_Undo));

  If CompareString(BMPType, 'edit') Then
    MS.Write(Bitmap_Pen, Length(Bitmap_Pen));
  If CompareString(BMPType, 'new') or CompareString(BMPType, 'append') Then
    MS.Write(Bitmap_New, Length(Bitmap_New));

  If CompareString(BMPType, 'tools') Then
    MS.Write(Tools16, Length(Tools16));

  If CompareString(BMPType, 'Cancel') or CompareString(BMPType, 'CancelClose') Then
    MS.Write(Bitmap_Cancel, Length(Bitmap_Cancel));
  If CompareString(BMPType, 'Post') or CompareString(BMPType, 'PostClose') Then
    MS.Write(Bitmap_Post, Length(Bitmap_Post));

  If CompareString(BMPType, 'logo') Then
    MS.Write(DCLbmp, Length(DCLbmp));

  If CompareString(BMPType, 'logo_small') Then
    MS.Write(DCLbmp_Small, Length(DCLbmp_Small));

  If MS.Size>0 Then
  Begin
    Marker:=0;
    MS.Position:=0;
    MS.Read(Marker, 3);

    If Marker=PAGSignature Then  // 80, 65, 71
    Begin
      // Compressed BMP/
      BS:=TMemoryStream.Create;
      BS.Position:=0;
      DecompressProc(MS, BS);
      BS.Position:=0;
      MS.Position:=0;
      MS.CopyFrom(BS, BS.Size);
      FreeAndNil(BS);
    End;

    Result:=TBitmap.Create;
    MS.Position:=BMPPos;
    Result.LoadFromStream(MS);
    Result.TransparentColor:=Result.Canvas.Pixels[0, 0];
    Result.TransparentMode:=tmFixed;
    Result.Transparent:=True;
  End
  Else
    Result:=TBitmap.Create;

  FreeAndNil(MS);
End;



// ========================Math=================================

Function Pow(const Base:Cardinal; PowNum: Word): Cardinal; overload;
var
  i: Word;
  s: Cardinal;
Begin
  s:=Base;
  If PowNum>1 then
  For i:=1 to PowNum-1 do
    s:=s*Base;
  Result:=s;
End;

Function Pow(Const Base: Real; PowNum: Word): Real; overload;
Var
  i: Word;
  S: Real;
Begin
  S:=Base;
  If PowNum>1 then
  For i:=1 To PowNum-1 Do
    S:=S*Base;
  Result:=S;
End;

Function StrToIntEx(St: String): LongInt;
Var
  iI, L: Integer;
  tmpS: String;
Begin
  St:=Calculate(St);
  L:=Length(St);
  tmpS:='';
  For iI:=1 To L Do
  Begin
    If (St[iI]>='0')And(St[iI]<='9')Or(St[iI]='-') Then
      tmpS:=tmpS+St[iI];
  End;
  If tmpS='' Then
    tmpS:='0';
  Try
    Result:=StrToInt(tmpS);
  Except
    Result:=0;
  End;
End;

Function StrToFloatEx(St: String): Real;
Var
  iI, L: Integer;
  tmpS: String;
Begin
  L:=Length(St);
  tmpS:='';
  For iI:=L Downto 1 Do
    If Pos(St[iI], '.,')<>0 Then
      St[iI]:=FormatSettings.DecimalSeparator;

  St:=Calculate(St);
  L:=Length(St);
  tmpS:='';
  For iI:=1 To L Do
  Begin
    If (St[iI]>='0')And(St[iI]<='9')Or(St[iI]='-')Or(St[iI]='.')Or(St[iI]=',') Then
      tmpS:=tmpS+St[iI];
  End;
  If tmpS='' Then
    tmpS:='0';
  Try
    Result:=StrToFloat(tmpS);
  Except
    Result:=0;
  End;
End;

Function InString(Const Sub, S: String; FullMatch: Boolean): Word;
Var
  i: Word;
Begin
  Result:=0;
  If FullMatch Then
  Begin
    Result:=Pos(Sub, S);
  End
  Else
    For i:=1 To Length(Sub) Do
    Begin
      Result:=Pos(Sub[i], S);
      If Result<>0 Then
        Break;
    End;
End;

Function FindOperate(Const Formula: String): TSignInfo;
Var
  OperPos, Long, i: Word;
Begin
  For i:=1 To PriorytestOperandsCount Do
  Begin
    OperPos:=InString(PriorytestOperands[i], Formula, True);
    Long:=Length(PriorytestOperands[i]);
    If OperPos<>0 Then
      Break;
  End;

  If OperPos=0 Then
  Begin
    OperPos:=InString(SerialOperands, Formula, False);
    If OperPos=1 Then
    Begin
      OperPos:=InString(SerialOperands, Copy(Formula, 2, Length(Formula)-1), False);
      If OperPos<>0 Then
        Inc(OperPos);
    End;
    Long:=1;
  End;

  Result.SignPos:=OperPos;
  Result.SignLong:=Long;
End;

Function FindOperands(Const Formula: String): Boolean;
Begin
  Result:=FindOperate(Formula).SignPos<>0;
End;

Function FormulaEval(Formula: TExpr): String;
Begin
  If Formula.Sign='-' Then
    Result:=FloatToStr(Formula.Oper1-Formula.Oper2);
  If Formula.Sign='+' Then
    Result:=FloatToStr(Formula.Oper1+Formula.Oper2);
  If Formula.Sign='*' Then
    Result:=FloatToStr(Formula.Oper1*Formula.Oper2);
  If Formula.Sign='/' Then
    Result:=FloatToStr(Formula.Oper1/Formula.Oper2);
  If Formula.Sign='^' Then
    Result:=FloatToStr(Pow(Formula.Oper1, Round(Formula.Oper2)));
  If Formula.Sign='div' Then
    Result:=FloatToStr(Round(Formula.Oper1)Div Round(Formula.Oper2));
  If Formula.Sign='mod' Then
    Result:=FloatToStr(Round(Formula.Oper1)Mod Round(Formula.Oper2));
End;

Function CopyCut(Var S: String; From, Count: Word): String;
Begin
  Result:=Copy(S, From, Count);
  Delete(S, From, Count);
End;

Procedure GetOperandsPair(Var Formula: String);
Var
  Sign: TSignInfo;
  OperPos, DigitPos, i: Word;
  ValRes: TExpr;
Begin
  While FindOperands(Formula) Do
  Begin
    Sign:=FindOperate(Formula);
    ValRes.Sign:=CopyCut(Formula, Sign.SignPos, Sign.SignLong);

    OperPos:=Sign.SignPos;
    DigitPos:=Sign.SignPos;
    If Copy(Formula, DigitPos, 1)='-' Then
      Inc(DigitPos);

    For i:=DigitPos to Length(Formula) do
    Begin
      If Pos(Formula[DigitPos], Digits)=0 then
        Break;
      Inc(DigitPos);
    End;

    ValRes.Oper2:=StrToFloatEx(CopyCut(Formula, OperPos, DigitPos-OperPos));

    DigitPos:=OperPos-1;

    For i:=DigitPos downto 1 do
    Begin
      If Pos(Formula[DigitPos], Digits)=0 then
        Break;
      Dec(DigitPos);
    End;

    If DigitPos=0 Then
      DigitPos:=1;

    If DigitPos<>1 Then
      If Pos(Formula[DigitPos-1], AllOperands)=0 Then
        Inc(DigitPos);

    ValRes.Oper1:=StrToFloatEx(CopyCut(Formula, DigitPos, OperPos-DigitPos));

    Insert(FormulaEval(ValRes), Formula, DigitPos);
  End;
End;

Procedure GetBreakets(Var Formula: String);
Var
  BeginBrPos, EndBrPos, j: Word;
  BrFormula: String;
Begin
  While Pos('(', Formula)<>0 Do
  Begin
    EndBrPos:=0;
    BrFormula:='';
    BeginBrPos:=Pos('(', Formula);
    If BeginBrPos<>0 Then
    Begin
      For j:=Length(Formula)-1 Downto BeginBrPos+1 Do
        If Formula[j]='(' Then
        Begin
          BeginBrPos:=j;
          Break;
        End;

      For j:=BeginBrPos+1 To Length(Formula) Do
        If Formula[j]=')' Then
        Begin
          EndBrPos:=j;
          Break;
        End;

      If (EndBrPos>0) and (BeginBrPos<EndBrPos) then
      Begin
        BrFormula:=CopyCut(Formula, BeginBrPos, EndBrPos-BeginBrPos+1);
        BrFormula:=CopyCut(BrFormula, 2, Length(BrFormula)-2);
        GetOperandsPair(BrFormula);
        Insert(BrFormula, Formula, BeginBrPos);
      End;
    End;
  End;
End;

Function Normalize(Formula: String): String;
Var
  i: Word;
Begin
  For i:=Length(Formula) Downto 1 Do
  Begin
    If (Formula[i]=' ')Or(Formula[i]=#9)Or(Formula[i]=';')Or(Formula[i]=#10)Or(Formula[i]=#13) Then
      Delete(Formula, i, 1);
  End;

  Formula:=LowerCase(Formula);

  Result:=Formula;
End;

Function Calculate(Formula: String): String;
Begin
  Formula:=Normalize(Formula);
  GetBreakets(Formula);
  GetOperandsPair(Formula);
  Result:=Formula;
End;

// ========================Math=================================

function PosInSet(SimbolsSet, SourceStr: String): Cardinal;
Var
  i: Cardinal;
begin
  Result:=0;
  For i:=1 to Length(SourceStr) do
  Begin
    If PosEx(SourceStr[i], SimbolsSet)<>0 then
    Begin
      Result:=i;
      Break;
    End;
  End;
end;

Function FindDisableAction(Action: String): Boolean;
Var
  iI: Byte;
Begin
  Result:=False;
  For iI:=1 To ToolCommandsCount Do
    If LowerCase(ToolButtonsCmd[iI])=LowerCase(Action) Then
    Begin
      Result:=True;
      Break;
    End;
End;

Function TranslateDigitToUserLevel(Level: byte): TUserLevelsType; overload;
Begin
  Result:=TUserLevelsType(Level);
  { Case Level Of
    0:
    Result:=ulDeny;
    1:
    Result:=ulReadOnly;
    2:
    Result:=ulWrite;
    3:
    Result:=ulExecute;
    4:
    Result:=ulLevel1;
    5:
    Result:=ulLevel2;
    6:
    Result:=ulLevel3;
    7:
    Result:=ulLevel4;
    8:
    Result:=ulDeveloper;
    Else
    $IFDEF DEVELOPERMODE
    Result:=ulDeveloper;
    $ELSE
    Result:=ulExecute;
    $ENDIF
    End; }
End;

Function TranslateDigitToUserLevel(Level: String): TUserLevelsType; overload;
Begin
  If CompareString(Level, 'ulDeny') Then
    Result:=ulDeny
  Else If CompareString(Level, 'ulReadOnly') Then
    Result:=ulReadOnly
  Else If CompareString(Level, 'ulWrite') Then
    Result:=ulWrite
  Else If CompareString(Level, 'ulExecute') Then
    Result:=ulExecute
  Else If CompareString(Level, 'ulLevel1') Then
    Result:=ulLevel1
  Else If CompareString(Level, 'ulLevel2') Then
    Result:=ulLevel2
  Else If CompareString(Level, 'ulLevel3') Then
    Result:=ulLevel3
  Else If CompareString(Level, 'ulLevel4') Then
    Result:=ulLevel4
  Else If CompareString(Level, 'ulDeveloper') Then
    Result:=ulDeveloper
  Else
{$IFDEF DEVELOPERMODE}
    Result:=ulDeveloper;
{$ELSE}
    Result:=ulExecute;
{$ENDIF}
End;

Procedure TranslateProc(Var CallProc: String; Var Factor: Word; Query: TDCLDialogQuery);
Const
  ProcCount=27;
  ProcNames: Array [1..ProcCount] Of String=('ConvertOraDates', 'ConvertToOraDates', 'ToFloat', // 3
    'ConvertToAccessDate', 'DeleteNonFilesSimb', 'GetFileNameToTranslite', 'ExtractFileName', // 7
    'MoneyToString', 'ByIndex', 'Count', 'IndexOf', 'ReadConfig', 'WriteConfig', 'NVL', 'iif', // 15
    'GetTempFileName', 'DaysInAMonth', 'GetMonthName', 'LeadingZero', 'GetAccessLevelByName', // 20
    'DaysInMonth', 'MonthByDate', 'Upper', 'Lower', 'MD5File', 'MD5String', 'Eval'); // 27
Var
  ReplaseProc, Param, TmpStr, TmpStr2, TmpStr3: String;
  StartSel, ParamLen, StartSearch, pv1, pv2, pv3, pv4, FindProcNum, Skobki, VarNameLength,
    MaxMatch: Word;
  FindVar: Boolean;
  FunctionParams: Array Of String;
  FunctionParamsCount: Byte;
  Sign:TSigns;
Begin
  Inc(Factor);
  StartSearch:=Pos(ProcPrefix, CallProc);
  While Pos(ProcPrefix, Copy(CallProc, StartSearch, Length(CallProc)))<>0 Do
  Begin
    StartSearch:=StartSearch+Pos(ProcPrefix, Copy(CallProc, StartSearch, Length(CallProc)))-1;
    StartSel:=StartSearch+Length(ProcPrefix);

    ParamLen:=Length(CallProc);
    If ParamLen<>0 Then
    Begin
      pv3:=1;
      FindProcNum:=0;
      MaxMatch:=0;

      While (ProcCount>=pv3) Do
      Begin
        FindVar:=True;
        pv2:=1;
        pv1:=StartSel;
        While (FindVar)And(pv1<=ParamLen)And(pv2<=Length(ProcNames[pv3])) Do
        Begin
          FindVar:=False;
          If Length(ProcNames[pv3])>=pv2 Then
          Begin
            If UpperCase(CallProc[pv1])=UpperCase(ProcNames[pv3][pv2]) Then
            Begin
              FindVar:=True;
              If MaxMatch<pv1 Then
              Begin
                MaxMatch:=pv1;
                FindProcNum:=pv3;
              End;
            End;
          End;
          Inc(pv1);
          Inc(pv2);
        End;
        Inc(pv3);
      End;

      If FindProcNum<>0 Then
      Begin
        VarNameLength:=MaxMatch-StartSel+1;
        ReplaseProc:=Copy(CallProc, StartSel, VarNameLength);
        pv2:=1;
        FindVar:=False;
        While (pv2<=ProcCount)And(FindVar=False) Do
        Begin
          If UpperCase(ReplaseProc)=UpperCase(ProcNames[pv2]) Then
          Begin
            FindVar:=True;
            FindProcNum:=pv2;
          End;
          Inc(pv2);
        End;
        If FindVar Then
        Begin
          Dec(StartSel, Length(ProcPrefix));
          Delete(CallProc, StartSel, Length(ProcPrefix));
          Dec(MaxMatch, Length(ProcPrefix));
        End;
      End
      Else
      Begin
        VarNameLength:=0;
        ReplaseProc:='';
      End;

      pv1:=MaxMatch;

      Skobki:=0;
      Repeat
        If CallProc[pv1]='(' Then
          Skobki:=1;
        Inc(pv1);
      Until (CallProc[pv1]<>'(')And(ParamLen+1>=pv1);
      pv2:=pv1;

      While (Skobki<>0)And(pv1<=ParamLen) Do
      Begin
        If CallProc[pv1]=')' Then
          Dec(Skobki)
        Else If CallProc[pv1]='(' Then
          Inc(Skobki);

        Inc(pv1);
      End;
      MaxMatch:=pv1;

      Param:=Copy(CallProc, pv2, pv1-pv2-1);
      TranslateProc(Param, Factor, Query);

      FunctionParamsCount:=ParamsCount(Param);
      SetLength(FunctionParams, FunctionParamsCount+1);
      FunctionParams[0]:=ProcNames[FindProcNum];
      For pv1:=1 To FunctionParamsCount Do
      Begin
        FunctionParams[pv1]:=SortParams(Param, pv1);
        // RePlaseVariables(FunctionParams[pv1]);
      End;

      If Skobki=0 Then
        Case FindProcNum Of
        // ConvertOraDates
        1:
        Begin
          TmpStr:=Copy(FunctionParams[1], 9, 2)+'.'+Copy(FunctionParams[1], 6, 2)+'.'+
            Copy(FunctionParams[1], 1, 4);
        End;

        // ConvertToOraDates
        2:
        Begin
          TmpStr:=Copy(FunctionParams[1], 7, 4)+'-'+Copy(FunctionParams[1], 4, 2)+'-'+
            Copy(FunctionParams[1], 1, 2)+' 00:00:00';
        End;

        // tofloat
        3:
        Begin
          Trim(FunctionParams[1]);
          If Pos('.', FunctionParams[1])=0 Then
            TmpStr:=FunctionParams[1]+'.00'
          Else
          Begin
            TmpStr:=Copy(FunctionParams[1], Pos('.', FunctionParams[1])+1,
              Length(FunctionParams[1])-Pos('.', FunctionParams[1])+1);
            If Length(TmpStr)=1 Then
              TmpStr:=TmpStr+'0'
            Else
              TmpStr:=FunctionParams[1];
          End;
        End;

        // ConvertToAccessDate
        4:
        Begin
          If Pos('.', FunctionParams[1])<>0 Then
            TmpStr:=Copy(FunctionParams[1], 4, 2)+'/'+Copy(FunctionParams[1], 1, 2)+'/'+
              Copy(FunctionParams[1], 7, 4)
          Else
            TmpStr:=FunctionParams[1];
        End;

        // deletenonfilessimb
        5:
        Begin
          ParamLen:=Length(FunctionParams[1]);
          While ParamLen<>0 Do
          Begin
            If (FunctionParams[1][ParamLen]='"') Or (FunctionParams[1][ParamLen]=CrossDelim) Or
              (FunctionParams[1][ParamLen]=':') or (FunctionParams[1][ParamLen]='*') Or
            { (FunctionParams[1][ParamLen]='&') or } (FunctionParams[1][ParamLen]='>') Or
              (FunctionParams[1][ParamLen]='<') Then
              Delete(FunctionParams[1], ParamLen, 1);
            Dec(ParamLen);
          End;
          TmpStr:=FunctionParams[1];
        End;

        // GetFileNameToTranslite
        6:
        Begin
          TmpStr:=GetFileNameToTranslite(FunctionParams[1]);
        End;

        // ExtractFileName
        7:
        Begin
          TmpStr:=ExtractFileName(FunctionParams[1]);
        End;

        // SumWrite
        8:
        Begin
          TmpStr2:=FunctionParams[1];
          If Length(FunctionParams)>2 then
            If FunctionParams[2]<>'' then
              TmpStr2:=FunctionParams[1]+'.'+FunctionParams[2];
          TmpStr:=MoneyToString(StrToFloatEx(TmpStr2), True, False);
        End;

        // ByIndex
        9:
        Begin
          TmpStr2:='';
          For pv3:=2 To FunctionParamsCount Do
          Begin
            TmpStr2:=TmpStr2+FunctionParams[pv3]+',';
          End;
          TmpStr:=SortParams(TmpStr2, StrToInt(FunctionParams[1]));
        End;

        // Count
        10:
        Begin
          // RePlaseVariables(FunctionParams[1]);
          TmpStr:=IntToStr(ParamsCount(FunctionParams[1]));
        End;

        // IndexOf
        11:
        Begin
          TmpStr:='';
          pv4:=0;
          For pv3:=2 To FunctionParamsCount Do
          Begin
            pv2:=ParamsCount(FunctionParams[pv3]);
            For pv1:=1 To pv2 Do
            Begin
              If AnsiLowerCase(FunctionParams[1])
                =AnsiLowerCase(SortParams(FunctionParams[pv3], pv1)) Then
              Begin
                TmpStr:=IntToStr(pv1+pv4);
                Break;
              End;
            End;
            Inc(pv4, pv2);
          End;
        End;

        12: // ReadConfig
        Begin
          If FunctionParamsCount=1 Then
            TmpStr:=DCLMainLogOn.ReadConfig(FunctionParams[1], '')
          Else
            TmpStr:=DCLMainLogOn.ReadConfig(FunctionParams[1], FunctionParams[2]);
        End;

        13: // WriteConfig
        Begin
          If FunctionParamsCount=2 Then
            DCLMainLogOn.WriteConfig(FunctionParams[1], FunctionParams[2], '')
          Else
            DCLMainLogOn.WriteConfig(FunctionParams[1], FunctionParams[2], FunctionParams[3]);

          TmpStr:='';
        End;

        14: // NVL
        Begin
          If FunctionParamsCount=2 Then
          If Assigned(Query) then
          If Query.Active then
            If GetFieldFromParam(FunctionParams[1], Query)<>nil then
            Begin
              If GetFieldFromParam(FunctionParams[1], Query).IsNull then
                TmpStr:=FunctionParams[2]
              Else
                TmpStr:=GetFieldFromParam(FunctionParams[1], Query).AsString;
            End;
        End;

        15: // iif
        Begin
          If FunctionParamsCount=3 Then
          Begin
            pv1:=LastDelimiter('<>=', FunctionParams[1]);
            If pv1<>0 then
            Begin
              Sign:=TSigns(AnsiIndexStr(FunctionParams[1], Signs));

              pv1:=Pos(Signs[Sign], FunctionParams[1]);
              pv2:=Length(Signs[Sign]);
              TmpStr2:=Copy(FunctionParams[1], 1, pv1-1);
              TmpStr3:=Copy(FunctionParams[1], pv1+pv2+1, Length(FunctionParams[1]));
              TmpStr2:=Trim(AnsiLowerCase(TmpStr2));
              TmpStr3:=Trim(AnsiLowerCase(TmpStr3));

              If Sign=sEquals then
              Begin
                If TmpStr2=TmpStr3 then
                  TmpStr:=FunctionParams[2]
                Else
                  TmpStr:=FunctionParams[3];
              End
              Else If Sign=sLess then
              Begin
                If TmpStr2>TmpStr3 then
                  TmpStr:=FunctionParams[2]
                Else
                  TmpStr:=FunctionParams[3];
              End
              Else If Sign=sGreater then
              Begin
                If TmpStr2<TmpStr3 then
                  TmpStr:=FunctionParams[2]
                Else
                  TmpStr:=FunctionParams[3];
              End
              Else If Sign=sNotEqual then
              Begin
                If TmpStr2<>TmpStr3 then
                  TmpStr:=FunctionParams[2]
                Else
                  TmpStr:=FunctionParams[3];
              End
              Else If Sign=sGreaterEq then
              Begin
                If TmpStr2<=TmpStr3 then
                  TmpStr:=FunctionParams[2]
                Else
                  TmpStr:=FunctionParams[3];
              End
              Else If Sign=sLessEq then
              Begin
                If TmpStr2>=TmpStr3 then
                  TmpStr:=FunctionParams[2]
                Else
                  TmpStr:=FunctionParams[3];
              End;
            End;
          End;
        End;
        16: // GetTempFileName
        Begin
          TmpStr:=GetTempFileName(FunctionParams[1]);
        End;
        17, 21: // DaysInMonth
        Begin
          TmpStr:=IntToStr(DaysInAMonth(StrToInt(FunctionParams[2]), StrToInt(FunctionParams[1])));
        End;
        18: // GetMonthName
        Begin
          tmpStr:=FunctionParams[1];
          pv1:=StrToIntEx(tmpStr);
          If ((pv1>0) and (pv1<13)) then
            TmpStr:=GetLacalaizedMonthName(pv1);
        End;
        19: // LeadingZero
        Begin
          TmpStr:=FunctionParams[1];
          If StrToInt(FunctionParams[2])>0 then
          Begin
            If Length(TmpStr)<StrToInt(FunctionParams[2]) then
              For pv1:=1 to StrToInt(FunctionParams[2]) do
                TmpStr:='0'+TmpStr;
          End;
        End;
        20: // GetAccessLevelByName
        Begin
          TmpStr:=IntToStr(Ord(TranslateDigitToUserLevel(FunctionParams[1])));
        End;
        22: // MonthByDate
        Begin
          tmpStr:=FunctionParams[1];
          try
            pv1:=MonthOf(StrToDate(tmpStr));
            If ((pv1>0) and (pv1<13)) then
              TmpStr:=GetLacalaizedMonthName(pv1);
          Except
            TmpStr:='';
          End;
        End;
        23:
        Begin
          TmpStr:=AnsiUpperCase(FunctionParams[1]);
        End;
        24:
        Begin
          TmpStr:=AnsiLowerCase(FunctionParams[1]);
        End;
        25:Begin
          If FileExists(FunctionParams[1]) then
          Begin
            TmpStr:=MD5FileToStr(FunctionParams[1]);
          End;
        End;
        26:Begin
          TmpStr:=MD5DigestToStr(MD5String(FunctionParams[1]));
        End;
        27:Begin // Eval
          TmpStr:=Calculate(FunctionParams[1]);
        End;
        End;

      Delete(CallProc, StartSel, MaxMatch-StartSel);
//      If Factor=1 then
      Insert(GetClearParam(TmpStr), CallProc, StartSel);
//      Else Insert(TmpStr, CallProc, StartSel);

      Inc(StartSearch, Length(TmpStr)+1);
    End;
  End;
  Dec(Factor);
End;


Function GetStringDataType(const S: String): TIsDigitType;
Var
  iI: Word;
Begin
  Result:=idString;
  If S<>'' Then
  Begin
    If Length(S)>1 then
    Begin
      If (PosEx('cl', S)=1) and (Length(S)>4) Then
      Begin
        Result:=idColor;
        Exit;
      End;
      If (PosEx('ul', S)=1) and (PosSet(UserLevelsSet, S)<>0) and (Length(S)>5)
      then
      Begin
        Result:=idUserLevel;
        Exit;
      End;
      If (LowerCase(S[1])='h') or (S[1]='$') Then
      Begin
        For iI:=2 To Length(S) Do
        Begin
          If PosEx(S[iI], '0123456789ABCDEF')=0 then
          Begin
            Result:=idString;
            Exit;
          End;
        End;
        Result:=idHex;
        Exit;
      End;
      For iI:=1 To Length(S) Do
      Begin
        If Pos(S[iI], '0123456789-.,')=0 then
        Begin
          If (Pos(S[iI], '0123456789-.: ')<>0) and (Length(S)>=9) then
          Begin
            Result:=idDateTime;
            Exit;
          End;
          Result:=idString;
          Exit;
        End
        Else
        Begin
          If Pos(S[iI], '0123456789-')<>0 then
            Result:=idDigit
          Else
            If Pos(S[iI], '0123456789-,.')<>0 then
              Result:=idFloatDigit;
          Exit;
        End;
      End;
    End
    Else
    Begin
      If Pos(S, '0123456789')=0 then
      Begin
        Result:=idString;
        Exit;
      End
      Else
      Begin
        Result:=idDigit;
        Exit;
      End;
    End;
  End
  Else
    Result:=idString;
End;

Procedure DebugProc(ActionStr: String);
Begin
  If GPT.DebugOn then
    Logger.WriteLog(ActionStr);
End;

Procedure GetParamsStructure(Params:TStringList);
Var
  i: Word;
Begin
  If Params.Count>0 Then
    For i:=0 To Params.Count-1 Do
    Begin
      If Pos('//', TrimLeft(Params[i]))<>1 Then
      Begin
{$IFDEF ADO}
        If PosEx('ConnectionString=', Params[i])=1 Then
          GPT.ConnectionString:=Copy(Params[i], 18, Length(Params[i]));
{$ENDIF}
{$IFDEF SERVERDB}
        If PosEx('UserName=', Params[i])=1 Then
          GPT.DBUserName:=FindParam('UserName=', Params[i]);
        If PosEx('Password=', Params[i])=1 Then
          GPT.DBPassword:=FindParam('Password=', Params[i]);
        If PosEx('DBPath=', Params[i])=1 Then
          GPT.DBPath:=FindParam('DBPath=', Params[i]);
        If PosEx('ServerName=', Params[i])=1 Then
          GPT.ServerName:=FindParam('ServerName=', Params[i]);
        If PosEx('Port=', Params[i])=1 Then
          GPT.Port:=StrToIntEx(FindParam('Port=', Params[i]));
        If PosEx('DBType=', Params[i])=1 Then
          GPT.DBType:=FindParam('DBType=', Params[i]);
        If PosEx('SQLDialect=', Params[i])=1 Then
          GPT.SQLDialect:=StrToIntEx(FindParam('SQLDialect=', Params[i]));
{$ENDIF}
        If PosEx('DBTypeIB=', Params[i])=1 Then
          GPT.IBAll:=FindParam('DBTypeIB=', Params[i])='1';
        If PosEx('CodePage=', Params[i])=1 Then
          GPT.ServerCodePage:=FindParam('CodePage=', Params[i]);
        If PosEx('StringTypeChar=', Params[i])=1 Then
          GPT.StringTypeChar:=Trim(FindParam('StringTypeChar=', Params[i]));
        If PosEx('Viewer=', Params[i])=1 Then
          GPT.Viewer:=FindParam('Viewer=', Params[i]);
        If PosEx('MainFormCaption=', Params[i])=1 Then
          GPT.MainFormCaption:=FindParam('MainFormCaption=', Params[i]);

        If PosEx('DCLUserName=', Params[i])=1 Then
          GPT.DCLUserName:=FindParam('DCLUserName=', Params[i]);
        If PosEx('DCLUserPass=', Params[i])=1 Then
          GPT.EnterPass:=FindParam('DCLUserPass=', Params[i]);

{$IFDEF DEVELOPERMODE}
        If PosEx('DCLTable=', Params[i])=1 Then
          GPT.DCLTable:=FindParam('DCLTable=', Params[i]);
        If PosEx('DCLNameField=', Params[i])=1 Then
          GPT.DCLNameField:=FindParam('DCLNameField=', Params[i]);
        If PosEx('DCLTextField=', Params[i])=1 Then
          GPT.DCLTextField:=FindParam('DCLTextField=', Params[i]);
        If PosEx('IdentifyField=', Params[i])=1 Then
          GPT.IdentifyField:=FindParam('IdentifyField=', Params[i]);
        If PosEx('ParentFlgField=', Params[i])=1 Then
          GPT.ParentFlgField:=FindParam('ParentFlgField=', Params[i]);
        If PosEx('CommandField=', Params[i])=1 Then
          GPT.CommandField:=FindParam('CommandField=', Params[i]);
        If PosEx('NumSeqField=', Params[i])=1 Then
          GPT.NumSeqField:=FindParam('NumSeqField=', Params[i]);

        If PosEx('RolesToUsersTable=', Params[i])=1 Then
          GPT.RolesToUsersTable:=FindParam('RolesToUsersTable=', Params[i]);
        If PosEx('RolesToUsersUserIDField=', Params[i])=1 Then
          GPT.RolesToUsersUserIDField:=FindParam('RolesToUsersUserIDField=', Params[i]);
        If PosEx('RolesToUsersRoleIDField=', Params[i])=1 Then
          GPT.RolesToUsersRoleIDField:=FindParam('RolesToUsersRoleIDField=', Params[i]);

        If PosEx('TemplatesTable=', Params[i])=1 Then
          GPT.TemplatesTable:=FindParam('TemplatesTable=', Params[i]);
        If PosEx('TemplatesNameField=', Params[i])=1 Then
          GPT.TemplatesNameField:=FindParam('TemplatesNameField=', Params[i]);
        If PosEx('TemplatesDataField=', Params[i])=1 Then
          GPT.TemplatesDataField:=FindParam('TemplatesDataField=', Params[i]);
        If PosEx('TemplatesKeyField=', Params[i])=1 Then
          GPT.TemplatesKeyField:=FindParam('TemplatesKeyField=', Params[i]);

        If PosEx('GeneratorName=', Params[i])=1 Then
          GPT.GeneratorName:=FindParam('GeneratorName=', Params[i]);
{$ENDIF}
        If PosEx('DisableFieldsList=', Params[i])=1 Then
          If Trim(FindParam('DisableFieldsList=', Params[i]))='1' Then
            GPT.DisableFieldsList:=True;
        If PosEx('GetValueSeparator=', Params[i])=1 Then
          GPT.GetValueSeparator:=FindParam('GetValueSeparator=', Params[i]);

        If PosEx('MultiRoles=', Params[i])=1 Then
        Begin
          If Trim(FindParam('MultiRoles=', Params[i]))='1' Then
            GPT.MultiRolesMode:=True;
        End;

        If PosEx('OldStyle=', Params[i])=1 Then
        Begin
          If Trim(FindParam('OldStyle=', Params[i]))='1' Then
            GPT.OldStyle:=False
          Else
            GPT.OldStyle:=True;
        End;
        If PosEx('Debug=', Params[i])=1 Then
        Begin
          If Trim(FindParam('Debug=', Params[i]))='1' Then
          Begin
            GPT.DebugOn:=True;
          End
          Else
            GPT.DebugOn:=False;
        End;

        If PosEx('SQLMonitor=1', Params[i])=1 Then
        Begin
          // SQLMonActions.StartSQLTrace;
        End;

        If PosEx('DebugMesseges=', Params[i])=1 Then
        Begin
          If Trim(FindParam('DebugMesseges=', Params[i]))='1' Then
            GPT.DebugMesseges:=True
          Else
            GPT.DebugMesseges:=False;
        End;

        If PosEx('UpperBase=', Params[i])=1 Then
        Begin
          If Trim(FindParam('UpperBase=', Params[i]))='1' Then
          Begin
            GPT.UpperString:=' upper(';
            GPT.UpperStringEnd:=') ';
          End
          Else
          Begin
            GPT.UpperString:=' ';
            GPT.UpperStringEnd:=' ';
          End;
        End;

        If PosEx('HashPass=', Params[i])=1 Then
        Begin
          If Trim(FindParam('HashPass=', Params[i]))='1' Then
          Begin
            GPT.HashPass:=True;
          End
          Else
          Begin
            GPT.HashPass:=False;
          End;
        End;

        If PosEx('ShowFormPanel=', Params[i])=1 Then
        Begin
          If Trim(FindParam('ShowFormPanel=', Params[i]))='1' Then
            ShowFormPanel:=True
          Else
            ShowFormPanel:=False;
        End;

        If PosEx('UseMessages=', Params[i])=1 Then
        Begin
          If Trim(FindParam('UseMessages=', Params[i]))='1' Then
            GPT.UseMessages:=True
          Else
            GPT.UseMessages:=False;
        End;

        If PosEx('ConfirmExit=', Params[i])=1 Then
        Begin
          If Trim(FindParam('ConfirmExit=', Params[i]))='1' Then
            GPT.ExitCnf:=True
          Else
            GPT.ExitCnf:=False;
        End;

        If PosEx('ShowPicture=', Params[i])=1 Then
        Begin
          If Trim(FindParam('ShowPicture=', Params[i]))='1' Then
            GPT.ShowPicture:=True
          Else
            GPT.ShowPicture:=False;
        End;
        If PosEx('DialogsSettings=', Params[i])=1 Then
        Begin
          If Trim(FindParam('DialogsSettings=', Params[i]))='1' Then
            GPT.DialogsSettings:=True
          Else
            GPT.DialogsSettings:=False;
        End;
        If PosEx('DisableColors=', Params[i])=1 Then
        Begin
          If Trim(FindParam('DisableColors=', Params[i]))='1' Then
            GPT.DisableColors:=True
          Else
            GPT.DisableColors:=False;
        End;
        If PosEx('OneCopy=', Params[i])=1 Then
        Begin
          If Trim(FindParam('OneCopy=', Params[i]))='1' Then
            GPT.OneCopy:=True
          Else
            GPT.OneCopy:=False;
        End;

        If PosEx('DisableIniPasword=1', Params[i])=1 Then
        Begin
          GPT.DisableIniPasword:=True;
        End;

        If PosEx('FormPosInDB=', Params[i])=1 Then
        Begin
          GPT.FormPosInDB:=TIniStore(StrToInt(FindParam('FormPosInDB=', Params[i])));
        End;

{$IFDEF CPU32}
        If PosEx('LibPath=', Params[i])=1 Then
        Begin
          GPT.LibPath:=FindParam('LibPath=', Params[i]);
        End;
{$ENDIF}
{$IFDEF CPU64}
        If PosEx('LibPath_x64=', Params[i])=1 Then
        Begin
          GPT.LibPath:=FindParam('LibPath_x64=', Params[i]);
        End;
{$ENDIF}
        If PosEx('UserLogging=1', Params[i])=1 Then
        Begin
          GPT.UserLogging:=True;
        End;

        If PosEx('UserLoggingHistory=1', Params[i])=1 Then
        Begin
          GPT.UserLoggingHistory:=True;
        End;

        {If PosEx('UseUTF8=', Params[i])=1 Then
        Begin
          If Trim(FindParam('UseUTF8=', Params[i]))='1' Then
            DecodeBase:=True
          Else
            DecodeBase:=False;
        End;}

        If PosEx('DateFormat=', Params[i])=1 Then
        Begin
          GPT.DateFormat:=Trim(FindParam('DateFormat=', Params[i]));
        End;

        If PosEx('Language=', Params[i])=1 Then
        Begin
          LangName:=Trim(FindParam('Language=', Params[i]));
        End;

        If PosEx('DateSeparator=', Params[i])=1 Then
        Begin
          GPT.DateFormat:=Trim(FindParam('DateSeparator=', Params[i]));
        End;

        If PosEx('TimeFormat=', Params[i])=1 Then
        Begin
          GPT.TimeFormat:=Trim(FindParam('TimeFormat=', Params[i]));
        End;

        If PosEx('TimeSeparator=', Params[i])=1 Then
        Begin
          GPT.TimeFormat:=Trim(FindParam('TimeSeparator=', Params[i]));
        End;

        If PosEx('OfficeFormat=', Params[i])=1 Then
        Begin
          GPT.OfficeFormat:=ConvertOfficeType(Trim(FindParam('OfficeFormat=', Params[i])));
        End;

        If PosEx('OfficeDocumentFormat=', Params[i])=1 Then
        Begin
          GPT.OfficeDocumentFormat:=GetDocumentType(Trim(FindParam('OfficeDocumentFormat=', Params[i])));
        End;

        If PosEx('UserLocalProfile=', Params[i])=1 Then
        Begin
          AppConfigDir:=Trim(FindParam('UserLocalProfile=', Params[i]));
          DCLMainLogOn.TranslateVal(AppConfigDir);
          AppConfigDir:=IncludeTrailingPathDelimiter(AppConfigDir);
        End;
      End;
    End;
End;

Function HashString(S: String): String;
Begin
  Result:=MD5DigestToStr(MD5String(S));
End;

Function NoFileExt(const FileName:String):Boolean;
var
  i, p, l, k:Integer;
begin
  p:=0;
  k:=0;
  i:=Length(FileName);
  l:=i-5;
  If i<=5 then
    l:=1;
  For i:=Length(FileName) downto l do
  Begin
    If FileName[i]='.' then
    Begin
      k:=p;
      Break;
    End;
    Inc(p);
  End;

  Result:=not (k>1);
end;

Function IsFullPath(Path: String): Boolean;
Begin
  If Length(Path)>1 then
    Result:=((Pos(':\', Path)=2)or(Path[1]='/')or(Path[1]='~')) and (LastDelimiter('/\', Path)<>0)
  Else
    Result:=False;
End;

Function IsUNCPath(Path: String): Boolean;
Begin
  Result:=Pos('\\', Path)=1;
End;

Function ExpandShortPath(Path: String): String;
Begin
  if Pos('.', Path)=1 then
  Begin

  End;
End;

Procedure InitGetAppConfigDir;
Begin
{$IFDEF UNIX}
  UserProfileDir:=ExcludeTrailingPathDelimiter(GetEnvironmentVariable('HOME'));
{$ENDIF}
{$IFDEF MSWINDOWS}
  UserProfileDir:=ExcludeTrailingPathDelimiter(GetSpecialPath(CSIDL_APPDATA));
{$ENDIF}
  if not DirectoryExists(UserProfileDir) then
    ForceDirectories(UserProfileDir);

  AppConfigDir:=UserProfileDir+PathDelim+DCLDir;
  If not DirectoryExists(AppConfigDir) then
    ForceDirectories(AppConfigDir);
End;

function GetUserDocumentsDir: String;
Begin
{$IFDEF UNIX}
  Result:=GetEnvironmentVariable('HOME');
{$ENDIF}
{$IFDEF MSWINDOWS}
  Result:=GetSpecialPath(CSIDL_PERSONAL);
{$ENDIF}
End;

function TrimSQLComment(SQLText: String): String;
var
  p1, p2: Word;
begin
  p1:=Pos('/*', SQLText);
  p2:=Pos('*/', SQLText);
  If ((p1>0)and(p1<p2)) Then
    Delete(SQLText, p1, p2-p1);
  Result:=SQLText;
end;

Function IsReturningQuery(SQQL: String): Boolean;
Begin
  Result:=False;
  If PosEx('select', SQQL)<=5 then
    If PosEx('from', SQQL)>8 then
      Result:=True;

  If not Result then
  Begin
    If (PosEx('update', SQQL)<=5)and(PosEx('set', SQQL)>10) then
      Result:=False
    Else If (PosEx('delete', SQQL)<=5)and(PosEx('from', SQQL)>7) then
      Result:=False
    Else If (PosEx('insert', SQQL)<=5)and(PosEx('into', SQQL)>7) then
      Result:=False
    Else If (PosEx('execute', SQQL)<=5)and(PosEx('procedure', SQQL)>8) then
      Result:=False;
  End;
End;

function FindSQLWhere(SQL, FindToken:String; Opened:Boolean=True):Integer;
var
  i, skb, l:Integer;
  First, Last:Boolean;
  tmp1, DelimsSet, OpenerSet, CloseerSet:String;
begin
  Result:=0;
  DelimsSet:='( )[]'#39;
  OpenerSet:='(';
  CloseerSet:=')';
  First:=True;
  Last:=False;
  l:=Length(FindToken);
  i:=1;
  skb:=0;
  while i<Length(SQL) do
  Begin
    Last:=i=Length(SQL);

    If Opened then
      If Pos(SQL[i], OpenerSet)<>0 then
        Inc(skb)
      Else
        If Pos(SQL[i], CloseerSet)<>0 then
          Dec(skb);

    If (Pos(SQL[i], DelimsSet)<>0) or First then
    Begin
      If i+Length(FindToken)<Length(SQL) then
      Begin
        If (Pos(SQL[i+l+1], DelimsSet)<>0) or Last then
        Begin
          tmp1:=LowerCase(Copy(SQL, i+1, l));
          If skb=0 then
            If LowerCase(tmp1)=LowerCase(FindToken) then
            Begin
              Result:=i+1;
              Break;
            End;
        End;
      End;
    End;
    Inc(i);
    First:=False;
  End;
end;

/// ////////////////////////////////////////////////////////////

Procedure CreateScriptRun;
Begin
{$IFDEF MSWINDOWS}
  If Not ScriptRunCreated Then
  Begin
    ScriptRun:=CreateOleObject('ScriptControl');
    ScriptRun.Language:=ScriptControlLanguage;
    ScriptRun.UseSafeSubset:=False;
    ScriptRun.Timeout:=-1;
    ScriptRunCreated:=True;
  End;
{$ENDIF}
End;

Function RunScript(Code: String): String;
{$IFDEF MSWINDOWS}
Var
  Res: OleVariant;
Begin
  CreateScriptRun;
  Res:=ScriptRun.Eval(Code);
  Result:=Res;
{$ELSE}
Begin
{$ENDIF}
End;

Procedure ExecuteStatement(Code: String);
Begin
{$IFDEF MSWINDOWS}
  CreateScriptRun;
  ScriptRun.ExecuteStatement(Code);
{$ENDIF}
End;

Procedure ResetScript;
Begin
{$IFDEF MSWINDOWS}
  If ScriptRunCreated Then
    ScriptRun.Reset;
{$ENDIF}
End;

Procedure AddCodeScript(Code: TStringList);
Begin
{$IFDEF MSWINDOWS}
  CreateScriptRun;
  ScriptRun.AddCode(Code.Text);
{$ENDIF}
End;

procedure ExecVBS(VBSScript: String);
Var
  VBSText: TStringList;
  tmpVBSText: String;
Begin
  VBSText:=TStringList.Create;
  VBSText.Text:=VBSScript;
  If VBSText.Count>0 Then
  Begin
    If PosEx('script type=VBScript', VBSText[0])<>0 Then
      VBSText.Delete(0);
  End;
  If VBSText.Count>0 Then
  Begin
    tmpVBSText:=VBSText.Text;
    ExecuteStatement(tmpVBSText);
  End;
  FreeAndNil(VBSText);
End;

Procedure DestroyScript;
Begin
{$IFDEF MSWINDOWS}
  If ScriptRunCreated Then
  Begin
    //FreeAndNil(ScriptRun);
    ScriptRun:=Unassigned;
    ScriptRunCreated:=False;
  End;
{$ENDIF}
End;

Function GetOnOffMode(Mode: Boolean): String;
Begin
  If Mode then
    Result:=GetDCLMessageString(msModeOn)+'.'
  else
    Result:=GetDCLMessageString(msModeOff)+'.';
End;

Function HexToInt64(HexStr: String): Int64;
Var
  RetVar: Int64;
  i: Word;
Begin
  HexStr:=UpperCase(HexStr);
  If UpperCase(HexStr[Length(HexStr)])='H' Then
    Delete(HexStr, Length(HexStr), 1);
  RetVar:=0;
  For i:=1 To Length(HexStr) Do
  Begin
    RetVar:=RetVar Shl 4;
    If HexStr[i] In ['0'..'9'] Then
      RetVar:=RetVar+(byte(HexStr[i])-48)
    Else If HexStr[i] In ['A'..'F'] Then
      RetVar:=RetVar+(byte(HexStr[i])-55);
  End;
  Result:=RetVar;
End;

Function HexToInt(HexStr: String): Integer;
Var
  RetVar: Integer;
  i: Word;
Begin
  HexStr:=UpperCase(HexStr);
  If UpperCase(HexStr[Length(HexStr)])='H' Then
    Delete(HexStr, Length(HexStr), 1);
  RetVar:=0;
  For i:=1 To Length(HexStr) Do
  Begin
    RetVar:=RetVar Shl 4;
    If HexStr[i] In ['0'..'9'] Then
      RetVar:=RetVar+(byte(HexStr[i])-48)
    Else If HexStr[i] In ['A'..'F'] Then
      RetVar:=RetVar+(byte(HexStr[i])-55);
  End;
  Result:=RetVar;
End;

Function FakeFileExt(Const FileName, Ext: String): String;
Begin
  Result:=ChangeFileExt(FileName, '.'+Ext);
End;

Function AddToFileName(Const FileName, AddStr: String): String;
Var
  tmpS, P, Ext: String;
Begin
  tmpS:=ExtractFileName(ChangeFileExt(FileName, ''));
  P:=ExtractFilePath(FileName);
  Ext:=ExtractFileExt(FileName);
  Result:=P+tmpS+AddStr+Ext;
End;

Function ExtractSection(Var SectionStr: String): String;
Var
  PosD: Word;
Begin
  PosD:=Pos('/', SectionStr);
  If PosD=0 Then
  Begin
    Result:=SectionStr;
    SectionStr:='';
  End
  Else
  Begin
    Result:=Copy(SectionStr, 1, PosD-1);
    Delete(SectionStr, 1, PosD);
  End;
End;

function GetGraficFileType(FileName: string): TGraficFileType;
var
  Ext: String;
Begin
  Result:=gftNone;
  Ext:=LowerCase(ExtractFileExt(FileName));
  If Ext='.bmp' then
    Result:=gftBMP;
  If (Ext='.jpg')or(Ext='.jpeg') then
    Result:=gftJPEG;
End;

function GetExtByType(FileType:TGraficFileType):String;
Begin
  Case FileType of
  gftBMP:Result:='bmp';
  gftJPEG, gftOther:Result:='jpg';
  gftPNG:Result:='png';
  gftIcon:Result:='ico';
  gftGIF:Result:='gif';
  gftTIFF:Result:='tiff';
  end;
End;

Function CopyStrings(FromString, ToString: String; Where: TStringList): TStringList;
Var
  li, FromPos, CurrPos: Integer;
Begin
  Result:=TStringList.Create;
  Result.Clear;
  If Where.Count>0 Then
  Begin
    CurrPos:=0;
    While (UpperCase(Where[CurrPos])<>UpperCase(FromString)) And
      (CurrPos+1<>Where.Count) Do
      Inc(CurrPos);
    FromPos:=CurrPos;
    While (UpperCase(Where[CurrPos])<>UpperCase(ToString)) And
      (CurrPos+1<>Where.Count) Do
      Inc(CurrPos);
    For li:=FromPos+1 To CurrPos-1 Do
      Result.Append(Where[li]);
  End;
End;

function GetFormPosString(FForm:TDBForm; DialogName:String): String;
begin
  Result:=DialogName+'=Top='+IntToStr(FForm.Top)+';Left='+IntToStr(FForm.Left)+';Height='+
    IntToStr(FForm.ClientHeight)+';Width='+IntToStr(FForm.Width)+';';
end;

procedure SaveMainFormPosINI(FForm:TDBForm; DialogName:String);
Var
  DialogsParams: TStringList;
  i: Integer;
  Yes: Boolean;
begin
  If Assigned(FForm) Then
  Begin
    Yes:=False;
    DialogsParams:=TStringList.Create;
    If FileExists(IncludeTrailingPathDelimiter(AppConfigDir)+'Dialogs.ini') Then
      DialogsParams.LoadFromFile(IncludeTrailingPathDelimiter(AppConfigDir)+'Dialogs.ini'{$IFNDEF FPC}, TEncoding.UTF8{$ENDIF});
    If DialogsParams.Count<>0 Then
    Begin
      For i:=1 To DialogsParams.Count Do
        If PosEx(DialogName+'=', DialogsParams[i-1])=1 Then
        Begin
          DialogsParams[i-1]:=GetFormPosString(FForm, DialogName);
          Yes:=true;
          break;
        End;
      If Yes=False Then
        DialogsParams.Append(GetFormPosString(FForm, DialogName));
    End
    Else
      DialogsParams.Append(GetFormPosString(FForm, DialogName));

    DialogsParams.SaveToFile(IncludeTrailingPathDelimiter(AppConfigDir)+'Dialogs.ini'{$IFNDEF FPC}, TEncoding.UTF8{$ENDIF});
    FreeAndNil(DialogsParams);
  End;
end;

function GetIniToRole(UserID: String): String;
Begin
  Result:='';
  If GPT.DCLUserName<>'' Then
    Result:=IniUserFieldName+'='+UserID+' and ';
End;

procedure SaveMainFormPosBase(FDCLLogOn:TDCLLogOn; FForm:TDBForm; DialogName:String);
Var
  DCLQueryL: TDCLDialogQuery;
  i: Integer;
Begin
  If Assigned(FForm) Then
  Begin
    If FDCLLogOn.TableExists(INITable) then
    Begin
      DCLQueryL:=TDCLDialogQuery.Create(nil);
      DCLQueryL.Name:='SaveFormPosOLD_'+IntToStr(UpTime);
      FDCLLogOn.SetDBName(DCLQueryL);

      DCLQueryL.SQL.Text:='select count(*) from '+INITable+' where '+GetIniToRole(GPT.UserID)+
        IniDialogNameField+'='+GPT.StringTypeChar+DialogName+GPT.StringTypeChar;

      DCLQueryL.Open;
      i:=DCLQueryL.Fields[0].AsInteger;
      DCLQueryL.Close;

      If i<>0 Then
      Begin
        DCLQueryL.SQL.Text:='update '+INITable+' set '+IniParamValField+'='+GPT.StringTypeChar+
          GetFormPosString(FForm, DialogName)+GPT.StringTypeChar+' where '+GetIniToRole(GPT.UserID)+IniDialogNameField+
          '='+GPT.StringTypeChar+DialogName+GPT.StringTypeChar;
      End
      Else
      Begin
        if GPT.UserID<>'' then
          DCLQueryL.SQL.Text:='insert into '+INITable+'('+IniUserFieldName+', '+IniDialogNameField+', '+
            IniParamValField+') values('+GPT.UserID+', '+GPT.StringTypeChar+DialogName+
            GPT.StringTypeChar+', '+GPT.StringTypeChar+GetFormPosString(FForm, DialogName)+GPT.StringTypeChar+')'
        else
          DCLQueryL.SQL.Text:='insert into '+INITable+'('+IniDialogNameField+', '+
            IniParamValField+') values('+GPT.StringTypeChar+DialogName+
            GPT.StringTypeChar+', '+GPT.StringTypeChar+GetFormPosString(FForm, DialogName)+GPT.StringTypeChar+')';
      End;
      Try
        DCLQueryL.ExecSQL;
      Except
        //Logger.WriteLog('', etError);
        //ShowMessage('Error!');
      End;
      FreeAndNil(DCLQueryL);
    End;
  End;
end;

procedure SaveMainFormPos(FDCLLogOn:TDCLLogOn; FForm:TDBForm; DialogName:String);
begin
  Case GPT.FormPosInDB Of
  isDisk:
  SaveMainFormPosINI(FForm, DialogName);
  isBase:
  SaveMainFormPosBase(FDCLLogOn, FForm, DialogName);
  isDiskAndBase:
  Begin
    SaveMainFormPosINI(FForm, DialogName);
    SaveMainFormPosBase(FDCLLogOn, FForm, DialogName);
  End;
  End;
end;

procedure LoadMainFormPosINI(var FForm:TDBForm; DialogName:String);
Var
  DialogsParams: TStringList;
  ParamsCounter: Word;
Begin
  If DialogName<>'' Then
    If GPT.DialogsSettings Then
    Begin
      If FileExists(IncludeTrailingPathDelimiter(AppConfigDir)+'Dialogs.ini') Then
      Begin
        DialogsParams:=TStringList.Create;
        DialogsParams.LoadFromFile(IncludeTrailingPathDelimiter(AppConfigDir)+'Dialogs.ini'{$IFNDEF FPC}, TEncoding.UTF8{$ENDIF});
        For ParamsCounter:=0 To DialogsParams.Count-1 Do
        Begin
          If PosEx(DialogName+'=', DialogsParams[ParamsCounter])=1 Then
          Begin
            FForm.Top:=StrToInt(FindParam('Top=', DialogsParams[ParamsCounter]));
            FForm.Left:=StrToInt(FindParam('Left=', DialogsParams[ParamsCounter]));
            FForm.ClientHeight:=StrToInt(FindParam('Height=', DialogsParams[ParamsCounter]))+AddHeight;
            FForm.Width:=StrToInt(FindParam('Width=', DialogsParams[ParamsCounter]));
            break;
          End;
        End;
        FreeAndNil(DialogsParams);
      End;
    End;
end;

procedure LoadMainFormPosBase(FDCLLogOn:TDCLLogOn; var FForm:TDBForm; DialogName:String);
Var
  DCLQueryL: TDCLDialogQuery;
  IniVal: String;
Begin
  If DialogName<>'' Then
  Begin
    If FDCLLogOn.TableExists(INITable) then
    Begin
      DCLQueryL:=TDCLDialogQuery.Create(Nil);
      DCLQueryL.Name:='LoadFormPosOLD_'+IntToStr(UpTime);
      FDCLLogOn.SetDBName(DCLQueryL);

      DCLQueryL.SQL.Text:='select * from '+INITable+' where '+GetIniToRole(GPT.UserID)+
        IniDialogNameField+'='+GPT.StringTypeChar+DialogName+GPT.StringTypeChar;
      DCLQueryL.Open;

      If Not DCLQueryL.IsEmpty Then
      Begin
        IniVal:=DCLQueryL.FieldByName(IniParamValField).AsString;

        If GPT.DialogsSettings and (IniVal<>'') Then
        Begin
          FForm.Top:=StrToInt(FindParam('Top=', IniVal));
          FForm.Left:=StrToInt(FindParam('Left=', IniVal));
          FForm.ClientHeight:=StrToInt(FindParam('Height=', IniVal))+AddHeight;
          FForm.Width:=StrToInt(FindParam('Width=', IniVal));
        End;
      End;
      DCLQueryL.Close;
      FreeAndNil(DCLQueryL);
    End;
  End;
end;

procedure LoadMainFormPos(FDCLLogOn:TDCLLogOn; var FForm:TDBForm; DialogName:String);
begin
  Case GPT.FormPosInDB of
  isDisk:
  LoadMainFormPosINI(FForm, DialogName);
  isBase:
  LoadMainFormPosBase(FDCLLogOn, FForm, DialogName);
  isDiskAndBase:
  Begin
    LoadMainFormPosINI(FForm, DialogName);
    LoadMainFormPosBase(FDCLLogOn, FForm, DialogName);
  End;
  End;
end;

function GetScreen:TBitmap;
var
  DC:HDC;
{$IFNDEF FPC}
  r:TRect;
  c:TCanvas;
  w, h:Word;
{$ENDIF}
begin
  Result:=TBitmap.Create;
{$IFNDEF FPC}
  w:=GetSystemMetrics(SM_CXSCREEN);
  h:=GetSystemMetrics(SM_CYSCREEN);
  c:=TCanvas.Create;
  DC:=GetDesktopWindow;
  c.Handle:=GetWindowDC(DC);
  try
    r:=Rect(0, 0, w, h);
    Result.Width:=w;
    Result.Height:=h;
    Result.Canvas.CopyRect(r, c, r);
  finally
    ReleaseDC(DC, c.Handle);
    c.Free;
  end;
{$ELSE}
  DC:=WidgetSet.GetDC(0);
  try
    Result.LoadFromDevice(DC);
  finally
    WidgetSet.ReleaseDC(0, DC);
  end;
{$ENDIF}
end;

function ConvertToJPEG(BitMap:TBitmap; Quality:Byte=JPEGCompressionQuality):TJpegImage;
begin
  if Quality=0 then
    Quality:=JPEGCompressionQuality;
  Result:=TJpegImage.Create;
{$IFNDEF FPC}
  Result.ProgressiveEncoding:=True;
{$ENDIF}
  try
    Result.CompressionQuality:=Quality;
    Result.Assign(BitMap);
  finally
    ///
  end;
end;

function ConvertBinToXBase(Data:TMemoryStream; Base:Byte):TMemoryStream;
var
  BaseStep:Byte;
  BasseSet:Array[0..64] of Byte;
  Buffer:Int64;
  i:Integer;
  S:String;
begin
  Result:=TMemoryStream.Create;
  If Data.Size>0 then
  Begin
    For i:=0 to 9 do
      BasseSet[i]:=Ord('0')+i;
    For i:=10 to Base do
      BasseSet[i]:=Ord('A')+i-10;

    BaseStep:=1;//(Base div 8)+((8+(Base mod 8)-1) div 8);
    Data.Position:=0;

    While Data.Position<Data.Size do
    Begin
      Buffer:=0;
      Data.Read(Buffer, BaseStep);
      S:=IntToHex(Buffer, 2);
      For i:=1 to Length(S) do
        Result.WriteBuffer(S[i], 1);
		End;
	End;
end;

function ConvertXBaseToBin(Data:TMemoryStream; Base:Byte):TMemoryStream;
var
  BasseSet:Array[0..64] of Byte;
  SingleDig, b:Byte;
  S:string;
  i:Integer;
Begin
  Result:=TMemoryStream.Create;
  If Data.Size>0 then
  Begin
    For i:=0 to 9 do
      BasseSet[i]:=Ord('0')+i;
    For i:=10 to Base do
      BasseSet[i]:=Ord('A')+i-10;

    Data.Position:=0;
    While Data.Position<Data.Size-1 do
    Begin
      S:='';
      For i:=1 to ((Base div 8)+((8+(Base mod 8)-1) div 8)) do
      Begin
        Data.Read(SingleDig, 1);
        S:=S+Chr(SingleDig);
  		End;
      b:=HexToInt(S);
      Result.Write(b, 1);
  	End;
	End;
End;

function SaveFormatedBlock(Data:TMemoryStream; Width:Word):TMemoryStream;
var
  Buffer:array of Byte;
  i:Integer;
  S:String;
Begin
  S:=CR;
  Result:=TMemoryStream.Create;
  If Data.Size>0 then
  Begin
    Data.Position:=0;
    While Data.Position<Data.Size-1 do
    Begin
      If Data.Size-Data.Position>=Width then
        SetLength(Buffer, Width+Length(CR))
      Else
        SetLength(Buffer, Data.Size-Data.Position+Length(CR));

      Data.Read(Buffer[0], Width);
      For i:=1 to Length(S) do
        Buffer[Length(Buffer)-Length(S)+i-1]:=Ord(S[i]);
      Result.WriteBuffer(Buffer[0], Length(Buffer));
    End;
  End;
End;

function LoadFormatedBlock(Data:TMemoryStream):TMemoryStream;
var
  Buffer:array of Byte;
  i, p, l:Integer;
Begin
  Result:=TMemoryStream.Create;
  SetLength(Buffer, 100);
  If Data.Size>0 then
  Begin
    Data.Position:=0;
    While Data.Position<Data.Size-1 do
    Begin
      l:=Data.Read(Buffer[0], 100);
      p:=0;
      For i:=1 to l do
      Begin
        If Chr(Buffer[i-1]) in ['A'..'Z', '0'..'9'] then
        Begin
          Buffer[p]:=Buffer[i-1];
          Inc(p);
        End;
      End;

      Result.WriteBuffer(Buffer[0], p);
    End;
  End;
End;

function GetScriptVersion(Data:TMemoryStream):String;
var
  tmp:TStringList;
Begin
  Result:='';
  If Data.Size>0 then
  Begin
    Data.Position:=0;
    tmp:=TStringList.Create;
    tmp.LoadFromStream(Data);
    If (Pos('[', tmp[0])<Pos(']', tmp[0])) and (Pos('[', tmp[0])>0) then
      If tmp[0]='['+SignMethodVer+']' then
      Begin
        Result:=GetClearParam(tmp[0], '[]');
      End;
    FreeAndNil(tmp);
  End;
End;

function DecodeScriptData(Data:TMemoryStream):TStringList;
var
  tmpMem, tmpArc: TMemoryStream;
  tmp:TStringList;
Begin
  Result:=TStringList.Create;
  If Data.Size>0 then
  Begin
    Data.Position:=0;
    tmp:=TStringList.Create;
    tmp.LoadFromStream(Data);
    If (Pos('[', tmp[0])<Pos(']', tmp[0])) and (Pos('[', tmp[0])>0) then
      If tmp[0]='['+SignMethodVer+']' then
      Begin
        tmp.Delete(0);
        Data.Clear;
        tmp.SaveToStream(Data);
        Data.Position:=0;
        tmpArc:=ConvertXBaseToBin(LoadFormatedBlock(Data), 16);
        tmpArc.Position:=0;
        tmpMem:=TMemoryStream.Create;
        DecompressProc(tmpArc, tmpMem);
        tmpMem.Position:=0;
        Result.LoadFromStream(tmpMem);
        FreeAndNil(tmpMem);
        FreeAndNil(tmpArc);
      End;
    FreeAndNil(tmp);
  End;
End;

function EncodeScriptData(Script:TStringList):TMemoryStream;
var
  tmpMem, tmpArc: TMemoryStream;
  i:Byte;
  Buffer:Array of Byte;
  S:string;
Begin
  Result:=TMemoryStream.Create;
  S:='['+SignMethodVer+']'+CR;
  SetLength(Buffer, Length(S));
  For i:=1 to Length(S) do
    Buffer[i-1]:=Ord(S[i]);
  Result.Write(Buffer[0], Length(Buffer));

  tmpArc:=TMemoryStream.Create;
  tmpMem:=TMemoryStream.Create;
  Script.SaveToStream(tmpMem);
  tmpMem.Position:=0;
  CompressProc(tmpMem, tmpArc);
  tmpArc.Position:=0;
  Result.CopyFrom(SaveFormatedBlock(ConvertBinToXBase(tmpArc, 16), ScrDataBlockWidth), 0);
  Result.Position:=0;
  FreeAndNil(tmpArc);
  FreeAndNil(tmpMem);
End;

function GetTimeFormat(mSec: Cardinal): String;
var
  h, m, S: Cardinal;
begin
  h:=mSec div 3600000;
  Dec(mSec, h*3600000);
  m:=mSec div 60000;
  Dec(mSec, m*60000);
  S:=mSec div 1000;
  Dec(mSec, S*1000);

  Result:=IntToStr(h)+' '+GetDCLMessageString(msHour)+'. '+IntToStr(m)+' '+
    GetDCLMessageString(msMinute)+'. '+IntToStr(S)+' '+
      GetDCLMessageString(msSecond)+'. '+IntToStr(mSec)+' '+GetDCLMessageString(msMSecond)+'.';
end;

function ReplaseCPtoWIN(CodePageName:String):String;
begin
  Result:=CodePageName;
  If PosEx('cp', CodePageName)=1 then
  Begin
    Result:='WIN'+Copy(CodePageName, 3, Length(CodePageName));
  End;
end;

function ReplaseWINtoCP(CodePageName:String):String;
begin
  Result:='';
  If PosEx('win', CodePageName)=1 then
  Begin
    Result:='cp'+Copy(CodePageName, 4, Length(CodePageName));
  End;
end;

function IsDigits(Value: String): Boolean;
var
  i: Integer;
begin
  Result:=False;

  if Length(Value)>0 then
  begin
  for I:=1 to Length(Value) do
    if not ((Value[i] in ['0'..'9']) or (Value[I] in ['-', '+'])) then
    begin
      exit;
    end;
  end;
  Result:=True;
end;

end.
