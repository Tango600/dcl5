unit uDCLOfficeUtils;

interface

uses
  uDCLConst
{$IFDEF MSWINDOWS}
  , Variants, Classes, ComObj, SysUtils, uDCLUtils
{$ENDIF};

{$IFDEF MSWINDOWS}
Procedure ExcelQuit(var Excel: OleVariant);
Procedure ExcelSave(var Excel: OleVariant; FileName: String);
Procedure WordInsert(var MsWord: OleVariant; Data, info: Variant;
  _bold, _italic, _StrikeThrough, _Underline: Integer; _Size: Integer; _center: Boolean);
Procedure WordOpen(var MsWord: OleVariant; FileName: OleVariant);
Procedure WordClose(var MsWord: OleVariant);
procedure WordDocumentClose(var MsWord: OleVariant; Save:Boolean);
Function CloseDocument(var MsWord: OleVariant): Boolean;
Function SaveDocumentAs(var MsWord: OleVariant; FileName: String): Boolean;
Procedure WordRun(var MsWord: OleVariant);
Procedure OOExportToFormat(var Document: Variant; FileName, Format: String);
Procedure OOCloseDocument(var Document: Variant);
Procedure OOClosePreview(var Document: Variant);
Procedure OOShowPreview(var Document: Variant);
Procedure OOSetVisible(var Document: Variant; Const Value: Boolean);
Function OOGetVisible(var Document: Variant): Boolean;
Procedure SetFormulaByXY(var Loc, NF, Sheet, Cell: Variant; Const Formula: String; row, col: Integer);
Procedure InsertTextByXY(var Sheet, Cell: Variant; Const Text: String; row, col: Integer);
Function GetTextByXY(var Sheet, Cell: Variant; Const row, col: Integer):String;
Function FileNameToURL(FileName: String): Variant;
Function MakePropertyValue(ServiceManager, PropertyName, PropertyValue: Variant): Variant;
{$ENDIF}
function GetPossibleOffice(DocType: TDocumentType; OfficeType, SettingOffice: TOfficeFormat): TOfficeFormat;
Function ConvertOfficeType(OfficeType: String): TOfficeFormat;
Function ConvertDocumentType(OfficeType: String): TOfficeDocumentFormat;
Function GetDocumentType(FileName: String): TOfficeDocumentFormat;

implementation

{$IFDEF MSWINDOWS}
uses
  uDCLOLE, uDCLMultiLang;

var
  WordRuning: Boolean;
  WordVer: Byte;
{$ENDIF}

{$IFDEF UNIX}
function GetPossibleOffice(DocType: TDocumentType; OfficeType, SettingOffice: TOfficeFormat): TOfficeFormat;
begin
  Result:=ofNone;
end;
{$ENDIF}

Function ConvertOfficeType(OfficeType: String): TOfficeFormat;
Begin
  If LowerCase(OfficeType)='oo' then
    Result:=ofOO
  Else If LowerCase(OfficeType)='mso' then
    Result:=ofMSO
  Else
    Result:=ofPossible;
End;

Function ConvertDocumentType(OfficeType: String): TOfficeDocumentFormat;
Begin
  If LowerCase(OfficeType)='oo' then
    Result:=odfOO
  Else If LowerCase(OfficeType)='mso' then
    Result:=odfMSO2007
  Else
    Result:=odfPossible;
End;

Function GetDocumentType(FileName: String): TOfficeDocumentFormat;
Var
  Ext: String;
Begin
  Ext:=ExtractFileExt(FileName);
  if (LowerCase(Ext)='.xlsx') or (LowerCase(Ext)='.xltx') or (LowerCase(Ext)='.docx') or (LowerCase(Ext)='.dotx') then
     Result:=odfMSO2007
  else
  if (LowerCase(Ext)='.xls') or (LowerCase(Ext)='.xlt') or (LowerCase(Ext)='.doc') or (LowerCase(Ext)='.dot') then
     Result:=odfMSO97
  else
    If (LowerCase(Ext)='.ods') or (LowerCase(Ext)='.ots') or (LowerCase(Ext)='.odt') or (LowerCase(Ext)='.ott') then
     Result:=odfOO;
End;

{$IFDEF MSWINDOWS}
function GetPossibleOffice(DocType: TDocumentType; OfficeType, SettingOffice: TOfficeFormat): TOfficeFormat;
begin
  Case DocType of
  dtSheet:
  If OfficeType=ofPossible then
  Begin
    If IsExcelInstall and (SettingOffice<>ofOO) then
      Result:=ofMSO
    else if IsOOInstall then
      Result:=ofOO
    Else
      Result:=ofNone;
  End
  Else
    Result:=OfficeType;
  dtText:
  If OfficeType=ofPossible then
  Begin
    If IsWordInstall and (SettingOffice<>ofOO) then
      Result:=ofMSO
    else if IsOOInstall then
      Result:=ofOO
    Else
      Result:=ofNone;
  End
  Else
    Result:=OfficeType;
  end;
end;

Function MakePropertyValue(ServiceManager, PropertyName, PropertyValue: Variant): Variant;
Begin
  Result:=ServiceManager.Bridge_GetStruct('com.sun.star.beans.PropertyValue');
  Case Variants.VarType(PropertyName) Of
  varString, $0102 { varUString } :
  Result.Name:=VarAsType(PropertyName, varOleStr);
  Else
    Result.Name:=PropertyName;
  End;
  Case Variants.VarType(PropertyValue) Of
  varString, $0102 { varUString } :
  Result.Value:=VarAsType(PropertyValue, varOleStr);
  Else
    Result.Value:=PropertyValue;
  End;
End;

Function FileNameToURL(FileName: String): Variant;
Var
  i: Integer;
  j: Byte;
  utf8ch: String;
Begin
  Result:='';
  For i:=1 To Length(FileName) Do
  Begin
    Case Ord(FileName[i]) Of
    $00..$7F:Begin
      Case Ord(FileName[i]) of
      $20:Result:=Result+'%20';
      $5C:Result:=Result+'/';
      $3A:Result:=Result+'|';
      Else
        Result:=Result+FileName[i];
      End;
    End;
    $80..$FF:Begin
      utf8ch:=Transcode(tdtUTF8, FileName[i]);
      For j:=1 to Length(utf8ch) do
        Result:=Result+'%'+IntToHex(Ord(utf8ch[j]), 2);
    End;
    End;
  End;
  Result:=VarAsType('file:///'+Result, varOleStr);
End;

Procedure InsertTextByXY(var Sheet, Cell: Variant; Const Text: String; row, col: Integer);
Begin
  Cell:=Sheet.getCellByPosition(col, row);
  Cell.setString(VarAsType(Text, varOleStr));
End;

Procedure SetFormulaByXY(var Loc, NF, Sheet, Cell: Variant; Const Formula: String; row, col: Integer);
var
  NF_id : Integer;
Begin
  NF_id:=NF.QueryKey(Formula, Loc, False);
  if NF_id=-1 then
    NF_id:=NF.AddNew(Formula, Loc);

  Cell:=Sheet.getCellByPosition(col, row);
  Cell.NumberFormat:=NF_id;
End;

Function GetTextByXY(var Sheet, Cell: Variant; Const row, col: Integer):String;
begin
  Cell:=Sheet.getCellByPosition(col, row);
  Result:=Cell.getString;
end;

Function OOGetVisible(var Document: Variant): Boolean;
Var
  v: Variant;
Begin
  v:=Document.GetCurrentController.GetFrame.GetContainerWindow;
  Result:=(v.getPosSize.Width<>0)Or(v.getPosSize.Height<>0);
  v:=Unassigned;
End;

Procedure OOSetVisible(var Document: Variant; Const Value: Boolean);
Begin
  Document.GetCurrentController.GetFrame.GetContainerWindow.SetVisible(Value);
End;
{$ENDIF}

Procedure OOShowPreview(var Document: Variant);
{$IFDEF MSWINDOWS}
Var
  OODispatcher: Variant;
  Ar, SM: Variant;
{$ENDIF}
Begin
{$IFDEF MSWINDOWS}
  SM:=CreateOleObject('com.sun.star.ServiceManager');
  OODispatcher:=SM.CreateInstance('com.sun.star.frame.DispatchHelper');
  Ar:=VarArrayCreate([0, 0], varVariant);
  Ar[0]:=SM.Bridge_GetStruct('com.sun.star.beans.PropertyValue');
  OODispatcher.ExecuteDispatch(Document.GetCurrentController.GetFrame, '.uno:PrintPreview',
    '', 0, Ar);
  OODispatcher:=Unassigned;
  Ar:=Unassigned;
  SM:=Unassigned;
{$ENDIF}
End;

Procedure OOClosePreview(var Document: Variant);
Var
  OODispatcher: Variant;
  Ar, SM: Variant;
Begin
{$IFDEF MSWINDOWS}
  SM:=CreateOleObject('com.sun.star.ServiceManager');
  OODispatcher:=SM.CreateInstance('com.sun.star.frame.DispatchHelper');
  Ar:=VarArrayCreate([0, 0], varVariant);
  Ar[0]:=SM.Bridge_GetStruct('com.sun.star.beans.PropertyValue');
  OODispatcher.ExecuteDispatch(Document.GetCurrentController.GetFrame, '.uno:ClosePreview',
    '', 0, Ar);
  OODispatcher:=Unassigned;
  Ar:=Unassigned;
  SM:=Unassigned;
{$ENDIF}
End;

Procedure OOCloseDocument(var Document: Variant);
Begin
  {$IFDEF MSWINDOWS}
  Document.Close(True);
  Document:=Unassigned;
  {$ENDIF}
End;

Procedure OOExportToFormat(var Document: Variant; FileName, Format: String);
Var
  FName, FType: String;
  FExt: String;
  Ar: Variant;
  SM: Variant;
  Ext: String;
Begin
{$IFDEF MSWINDOWS}
  SM:=CreateOleObject('com.sun.star.ServiceManager');
  If Format='' Then
    Format:='pdf';
  If Format='html' Then
    FType:='HTML (StarWriter)'
  Else If Format='pdf' Then
    FType:='writer_web_pdf_Export'; // 'writer_pdf_Export';
  FExt:='.'+Format;
  Ext:=UpperCase(ExtractFileExt(FileName));
  If Ext<>'.'+Format Then
    FName:=Copy(FileName, 1, Length(FileName)-4)+FExt
  Else
    FName:=FileName;
  FName:=FileNameToURL(FName);
  Ar:=VarArrayCreate([0, 1], varVariant);
  Ar[0]:=MakePropertyValue(SM, 'FilterName', FType);
  Ar[1]:=MakePropertyValue(SM, 'Overwrite', True);
  Document.StoreToURL(FName, Ar);
  Ar:=Unassigned;
  SM:=Unassigned;
{$ENDIF}
End;

{$IFDEF MSWINDOWS}
Procedure WordRun(var MsWord: OleVariant);
Var
  verr, verr1: String;
  i: Integer;
Const
  DigiChar=['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
Begin
  Try
    MsWord:=CreateOleObject('Word.Application');
    MsWord.Visible:=False;
    WordRuning:=True;
  Except
    ShowErrorMessage(-6010, '');
  End;
  verr:=Trim(MsWord.Version);
  verr1:='';
  For i:=1 To Length(verr) Do
    If Not(verr[i] In DigiChar) Then
      Break
    Else
      verr1:=verr1+verr[i];
  WordVer:=StrToInt(verr1);
  If WordVer<9 Then
    ShowErrorMessage(-6011, '');
End;

Function SaveDocumentAs(var MsWord: OleVariant; FileName: String): Boolean;
Begin
  Result:=False;
  If WordRuning Then
  Begin
    Result:=True;
    Try
      MsWord.ActiveDocument.SaveAs(FileName);
    Except
      Result:=False;
    End;
  End;
End;

Function CloseDocument(var MsWord: OleVariant): Boolean;
Begin
  Result:=False;
  If WordRuning Then
  Begin
    Result:=True;
    Try
      MsWord.ActiveDocument.Close;
    Except
      Result:=False;
    End;
  End;
End;

Procedure WordClose(var MsWord: OleVariant);
Begin
  If WordRuning Then
  Begin
    MsWord.Quit;
    WordRuning:=False;
    MsWord:=Unassigned;
  End;
End;

procedure WordDocumentClose(var MsWord: OleVariant; Save:Boolean);
var
  StV: OleVariant;
Begin
  If WordRuning Then
  Begin
    StV:=Save;
    MsWord.ActiveDocument.Close(StV, EmptyParam, EmptyParam);
  End;
End;

Procedure WordOpen(var MsWord: OleVariant; FileName: OleVariant);
Begin
  Try
    MsWord.Documents.Add(FileName, EmptyParam, EmptyParam, EmptyParam);
  Except
    ShowErrorMessage(-5004, FileName);
  End;
End;

Procedure WordInsert(var MsWord: OleVariant; Data, info: Variant;
  _bold, _italic, _StrikeThrough, _Underline: Integer; _Size: Integer; _center: Boolean);
Var
  C, What, Which, Count, Name: OleVariant;
Begin
  What:=-1;
  Which:=Unassigned;
  Count:=Unassigned;
  Name:=Data;
{$IFDEF FPC}
  MsWord.Selection.&GoTo(What, Which, Count, Name);
{$ELSE}
  MsWord.Selection.Goto(What, Which, Count, Name);
{$ENDIF}
  C:=Length(info);
  MsWord.Selection.Font.Bold:=_bold;
  MsWord.Selection.Font.italic:=_italic;
  MsWord.Selection.Font.StrikeThrough:=_StrikeThrough;
  MsWord.Selection.Font.Underline:=_Underline;
  If _Size<>0 Then
    MsWord.Selection.Font.Size:=_Size;
  If _center Then
    MsWord.Selection.ParagraphFormat.Alignment:=1;
  MsWord.Selection.TypeText(VarAsType(info, varOleStr));
End;

Procedure ExcelSave(var Excel: OleVariant; FileName: String);
Begin
  Excel.DisplayAlerts:=False;
  Excel.ActiveWorkBook.SaveAs(FileName);
End;

Procedure ExcelQuit(var Excel: OleVariant);
Begin
  Excel.Quit;
End;
{$ENDIF}

end.
