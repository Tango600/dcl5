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
Procedure InsertTextByXY(var Sheet, Cell: Variant; Const Text: String; row, col: Integer);
Function GetTextByXY(var Sheet, Cell: Variant; Const row, col: Integer):String;
Function FileNameToURL(FileName: String): Variant;
Function MakePropertyValue(ServiceManager, PropertyName, PropertyValue: Variant): Variant;
{$ENDIF}
function GetPossibleOffice(DocType: TDocumentType; OfficeType: TOfficeDocumentFormat=odtPossible)
  : TOfficeDocumentFormat;
Function ConvertOfficeType(OfficeType: String): TOfficeDocumentFormat;

implementation

{$IFDEF MSWINDOWS}
uses
  uDCLOLE;

var
  WordRuning: Boolean;
  WordVer: Byte;
{$ENDIF}

{$IFDEF UNIX}
function GetPossibleOffice(DocType: TDocumentType; OfficeType: TOfficeDocumentFormat=odtPossible)
  : TOfficeDocumentFormat;
begin
  Result:=odtNone;
end;
{$ENDIF}

Function ConvertOfficeType(OfficeType: String): TOfficeDocumentFormat;
Begin
  If LowerCase(OfficeType)='oo' then
    Result:=odtOO
  Else If LowerCase(OfficeType)='mso' then
    Result:=odtMSO
  Else
    Result:=odtPossible;
End;

{$IFDEF MSWINDOWS}
function GetPossibleOffice(DocType: TDocumentType; OfficeType: TOfficeDocumentFormat=odtPossible)
  : TOfficeDocumentFormat;
begin
  Case DocType of
  dtSheet:
  If OfficeType=odtPossible then
  Begin
    If IsExcelInstall then
      Result:=odtMSO
    else if IsOOInstall then
      Result:=odtOO
    Else
      Result:=odtNone;
  End
  Else
    Result:=OfficeType;
  dtText:
  If OfficeType=odtPossible then
  Begin
    If IsWordInstall then
      Result:=odtMSO
    else if IsOOInstall then
      Result:=odtOO
    Else
      Result:=odtNone;
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
type
  TCharToUTF8Table=array [0..255] of String;
const
  ArrayCP1251ToUTF8: TCharToUTF8Table=(
    #0, // #0
    #1, // #1
    #2, // #2
    #3, // #3
    #4, // #4
    #5, // #5
    #6, // #6
    #7, // #7
    #8, // #8
    #9, // #9
    #10, // #10
    #11, // #11
    #12, // #12
    #13, // #13
    #14, // #14
    #15, // #15
    #16, // #16
    #17, // #17
    #18, // #18
    #19, // #19
    #20, // #20
    #21, // #21
    #22, // #22
    #23, // #23
    #24, // #24
    #25, // #25
    #26, // #26
    #27, // #27
    #28, // #28
    #29, // #29
    #30, // #30
    #31, // #31
    #32, // ' '
    #33, // !
    #34, // "
    #35, // #
    #36, // $
    #37, // %
    #38, // &
    #39, // '
    #40, // (
    #41, // )
    #42, // *
    #43, // +
    #44, // ,
    #45, // -
    #46, // .
    #47, // /
    #48, // 0
    #49, // 1
    #50, // 2
    #51, // 3
    #52, // 4
    #53, // 5
    #54, // 6
    #55, // 7
    #56, // 8
    #57, // 9
    #58, // :
    #59, // ;
    #60, // <
    #61, // =
    #62, // >
    #63, // ?
    #64, // @
    #65, // A
    #66, // B
    #67, // C
    #68, // D
    #69, // E
    #70, // F
    #71, // G
    #72, // H
    #73, // I
    #74, // J
    #75, // K
    #76, // L
    #77, // M
    #78, // N
    #79, // O
    #80, // P
    #81, // Q
    #82, // R
    #83, // S
    #84, // T
    #85, // U
    #86, // V
    #87, // W
    #88, // X
    #89, // Y
    #90, // Z
    #91, // [
    #92, // \
    #93, // ]
    #94, // ^
    #95, // _
    #96, // `
    #97, // a
    #98, // b
    #99, // c
    #100, // d
    #101, // e
    #102, // f
    #103, // g
    #104, // h
    #105, // i
    #106, // j
    #107, // k
    #108, // l
    #109, // m
    #110, // n
    #111, // o
    #112, // p
    #113, // q
    #114, // r
    #115, // s
    #116, // t
    #117, // u
    #118, // v
    #119, // w
    #120, // x
    #121, // y
    #122, // z
    #123, // {
    #124, // |
    #125, // }
    #126, // ~
    #127, // #127
    #208#130, // #128
    #208#131, // #129
    #226#128#154, // #130
    #209#147, // #131
    #226#128#158, // #132
    #226#128#166, // #133
    #226#128#160, // #134
    #226#128#161, // #135
    #226#130#172, // #136
    #226#128#176, // #137
    #208#137, // #138
    #226#128#185, // #139
    #208#138, // #140
    #208#140, // #141
    #208#139, // #142
    #208#143, // #143
    #209#146, // #144
    #226#128#152, // #145
    #226#128#153, // #146
    #226#128#156, // #147
    #226#128#157, // #148
    #226#128#162, // #149
    #226#128#147, // #150
    #226#128#148, // #151
    '', // #152
    #226#132#162, // #153
    #209#153, // #154
    #226#128#186, // #155
    #209#154, // #156
    #209#156, // #157
    #209#155, // #158
    #209#159, // #159
    #194#160, // #160
    #208#142, // #161
    #209#158, // #162
    #208#136, // #163
    #194#164, // #164
    #210#144, // #165
    #194#166, // #166
    #194#167, // #167
    #208#129, // #168
    #194#169, // #169
    #208#132, // #170
    #194#171, // #171
    #194#172, // #172
    #194#173, // #173
    #194#174, // #174
    #208#135, // #175
    #194#176, // #176
    #194#177, // #177
    #208#134, // #178
    #209#150, // #179
    #210#145, // #180
    #194#181, // #181
    #194#182, // #182
    #194#183, // #183
    #209#145, // #184
    #226#132#150, // #185
    #209#148, // #186
    #194#187, // #187
    #209#152, // #188
    #208#133, // #189
    #209#149, // #190
    #209#151, // #191
    #208#144, // #192
    #208#145, // #193
    #208#146, // #194
    #208#147, // #195
    #208#148, // #196
    #208#149, // #197
    #208#150, // #198
    #208#151, // #199
    #208#152, // #200
    #208#153, // #201
    #208#154, // #202
    #208#155, // #203
    #208#156, // #204
    #208#157, // #205
    #208#158, // #206
    #208#159, // #207
    #208#160, // #208
    #208#161, // #209
    #208#162, // #210
    #208#163, // #211
    #208#164, // #212
    #208#165, // #213
    #208#166, // #214
    #208#167, // #215
    #208#168, // #216
    #208#169, // #217
    #208#170, // #218
    #208#171, // #219
    #208#172, // #220
    #208#173, // #221
    #208#174, // #222
    #208#175, // #223
    #208#176, // #224
    #208#177, // #225
    #208#178, // #226
    #208#179, // #227
    #208#180, // #228
    #208#181, // #229
    #208#182, // #230
    #208#183, // #231
    #208#184, // #232
    #208#185, // #233
    #208#186, // #234
    #208#187, // #235
    #208#188, // #236
    #208#189, // #237
    #208#190, // #238
    #208#191, // #239
    #209#128, // #240
    #209#129, // #241
    #209#130, // #242
    #209#131, // #243
    #209#132, // #244
    #209#133, // #245
    #209#134, // #246
    #209#135, // #247
    #209#136, // #248
    #209#137, // #249
    #209#138, // #250
    #209#139, // #251
    #209#140, // #252
    #209#141, // #253
    #209#142, // #254
    #209#143 // #255
    );

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
      utf8ch:=ArrayCP1251ToUTF8[Ord(FileName[i])];
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
    MsWord.Visible:=True;
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
  MsWord.Selection.Delete(EmptyParam, C);

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
