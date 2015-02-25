unit uOfficeDocs;
{$I DefineType.pas}

interface

uses
  SysUtils, Classes, Variants,
{$IFDEF MSWINDOWS}
  ComObj, ShellAPI, ActiveX, uOpenOffice,
{$ENDIF}
{$IFDEF FPC}
  LConvEncoding,
{$ENDIF}
{$IFNDEF FPC}
  uStringParams,
{$ENDIF}
  DB,
  uDCLTypes, uDCLOLE, uLogging;

const
  VersionStr='1.1';


type
  TOfficeType=(otNone, otMSOffice, // тип используемого редактора
    otOpOffice);
  TDSPrintMode=(pmNone, pmField, pmTableGrow, pmTableInsert);

  TUniDataModule=class(TObject)
  private
    FDataModule: TDataModule;
    FDataSets: TList;
    FCount: Word;

    function GetDataSet(Index: Word): TDataSet;
  public
    constructor Create(DataModule: TDataModule);
    destructor Destroy; override;

    property DataSets[Index: Word]: TDataSet read GetDataSet; default;
    property Count: Word read FCount;
  end;

  TPrintDoc=class(TObject)
  private
    FMsWord, FWordDocument: OleVariant;
    FWordRuning: Boolean;
    FWordVer: Byte;
    FOfficeType: TOfficeType;
{$IFDEF MSWINDOWS}
    FOW: TOOWriter;
{$ENDIF}
    FDataModule: TDataModule;
    FTemplateFileName, FReportFileName: String;
    FLogObject: TLogging;

    function GetPossibleOffice(PriorytestOffice: TOfficeType): TOfficeType;
    Function RunWord(vVisible: Boolean=False): OleVariant;
    function LoadTemplate(FileName: String; vVisible: Boolean): Variant;
    function AddTemplate(FileName: string; PageBreak: Boolean): Boolean;
    function AddStrToTable(TableN, RowNum, RowCount: Integer): Boolean;
    function AddStrToTableObject(Table: Variant; RowNum, RowCount: Integer): Boolean;
    function InsertIntoTable(TableN, RowNum, ColNum: Integer; aText: string): Boolean;
    function SetCellTableObject(Table: Variant; RowNum, ColNum: Integer; aText: string): Boolean;
    function GetVersion: string;
    function GetMarker: string;
  public
    constructor Create(DataModule: TDataModule; PriorytestOffice: TOfficeType;
      Var LogObj: TLogging);
    destructor Destroy; override;

    property Version: String read GetVersion;
    property OfficeType: TOfficeType read FOfficeType;
    property MSOVer: Byte read FWordVer;
    property MarkerStr: string read GetMarker;
    property LogObject: TLogging read FLogObject write FLogObject;

    procedure PrintTemplate(FileName: String; Visible: Boolean);
    function Find(aFindText: string): Boolean;
    procedure FindAndReplace(aFindText, AReplaceText: ShortString);
    procedure SaveReport(FileName: String);
    procedure ShowReport;
  end;

implementation

uses
  uDCLUtils, uDCLData, uDCLConst;

const
  wdReplaceNone=$00000000;
  wdReplaceOne=$00000001;
  wdReplaceAll=$00000002;
  wdFirst=$00000001;
  wdWrapNever=$00000000;
  wdFindStop=$00000000;
  wdFindContinue=$00000001;
  wdFindAsk=$00000002;
  wdPageBreak=$00000007;
  wdWithInTable=12;
  wdGoToTable=2;
  wdMaximumNumberOfColumns=18;
  wdMaximumNumberOfRows=15;
  wdStartOfRangeColumnNumber=16;
  wdStartOfRangeRowNumber=13;

  MarkerGrow='grow';
  MarkerInsert='insert';
  DSMarkerSimbol='#';
  DSMarker=DSMarkerSimbol+DSMarkerSimbol;
  DSMarkerTerm=DSMarkerSimbol;
  DSNameAndFieldSeparator='.';
  DSNameAndPRSeparator='=';


function iifi(Cond: Boolean; ValIfTrue, ValIfFalse: Integer): Integer;
Begin
  If Cond then
    Result:=ValIfTrue
  else
    Result:=ValIfFalse;
End;

function TPrintDoc.GetMarker: string;
begin
  Result:=DSMarker;
end;

function TPrintDoc.GetPossibleOffice(PriorytestOffice: TOfficeType): TOfficeType;
begin
  Case PriorytestOffice of
  otMSOffice:
  Begin
    If IsWordInstall then
      Result:=otMSOffice
    else if IsWriterInstall then
      Result:=otOpOffice
    Else
      Result:=otNone;
  End;
  otOpOffice:
  begin
    If IsWriterInstall then
      Result:=otOpOffice
    else if IsWordInstall then
      Result:=otMSOffice
    Else
      Result:=otNone;
  End;
  End;
end;

function TPrintDoc.GetVersion: string;
begin
  Result:=VersionStr;
end;

Function TPrintDoc.RunWord(vVisible: Boolean=False): OleVariant;
Var
  verr, verr1: String;
  i: Integer;
Const
  DigitChar=['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
Begin
{$IFDEF MSWINDOWS}
  Try
    Result:=CreateOleObject('Word.Application');
    Result.Visible:=vVisible;
    FWordRuning:=True;
  Except
    // ShowErrorMessage(-6010, '');
    FWordRuning:=False;
  End;
  verr:=Trim(Result.Version);
  verr1:='';
  For i:=1 To Length(verr) Do
    If Not(verr[i] In DigitChar) Then
      Break
    Else
      verr1:=verr1+verr[i];
  FWordVer:=StrToInt(verr1);
  // If FWordVer<9 Then ShowErrorMessage(-6011, '');
{$ENDIF}
End;

function TPrintDoc.LoadTemplate(FileName: String; vVisible: Boolean): Variant;
var
  vDocumentVisible: OleVariant;
  OOOM: TOpenOM;
begin
  Result:=Null;
  FTemplateFileName:=FileName;
  // запуск редактора
  try
    case FOfficeType of
    otMSOffice: // Microsoft Word
    begin
      If Assigned(FLogObject) then
        FLogObject.WriteLog('Подключение к Microsoft Office...');
      if FMsWord=Unassigned then
        FMsWord:=RunWord(vVisible);
    end;
    otOpOffice: // OpenOffice
    begin
      If Assigned(FLogObject) then
        FLogObject.WriteLog('Подключение к OpenOffice...');
      if not Assigned(FOW) then
        FOW:=TOOWriter.Create;
    end;
    end;
  except
    on E: Exception do
    begin
      If Assigned(FLogObject) then
        FLogObject.WriteLog('Подключение к офису прошло с ошибкой.');
      case FOfficeType of
      otNone:
      ShowErrorMessage(-6010, E.Message);
      otMSOffice:
      ShowErrorMessage(-6000, E.Message);
      otOpOffice:
      ShowErrorMessage(-6001, E.Message);
      end;
      Abort;
    end;
  end;
  // попытка загрузки шаблона
  if (not VarIsNull(FMsWord))or Assigned(FOW) then
  begin
    try
      case FOfficeType of
      otMSOffice: // Microsoft Word
      begin
        vDocumentVisible:=True;
        // создание документа по шаблону
        Try
          FWordDocument:=FMsWord.Documents.Add(FTemplateFileName, EmptyParam, EmptyParam,
            vDocumentVisible);
          If Assigned(FLogObject) then
            FLogObject.WriteLog('Шаблон загружен');
        Except
          ShowErrorMessage(-5004, FileName);
          If Assigned(FLogObject) then
            FLogObject.WriteLog('-5004 / Шаблон не загружен, нет такого шаблона');
        End;
        // vWordDocument.Activate;
      end;
      otOpOffice: // OpenOffice
      begin
        FOW.Connect:=True;
        // создаем документ по шаблону
        OOOM:=[];
        If not vVisible then
          OOOM:=[oomHidden];
        FOW.OpenDocument(FTemplateFileName, [oomAsTemplate]+OOOM, ommAlwaysNoWarn);
        If Assigned(FLogObject) then
          FLogObject.WriteLog('Шаблон загружен');
        FOW.Visible:=vVisible;
      end;
      end;
    finally
      Result:=FTemplateFileName;
    end;
  end;
end;

procedure TPrintDoc.PrintTemplate(FileName: String; Visible: Boolean);
var
  vFileName, ooTextTable, ooCell: Variant;
  msTable, msCell: Variant;
  // ViewCursor:TOOViewCursor;
  FindIterateCount, PMFindIterateCount: Byte;
  Insert: Boolean;
  i, j, r, c, k, BeginRow, BeginCol, ColsCount, RowsCount, FillRows: Word;
  DS: TDataSet;
  DSName, Marker, CellName, RecStr: string;
  PrintMode: TDSPrintMode;
  UData: TUniDataModule;

  procedure FindPrintMode;
  Begin
    If Find(DSMarker+DSName+DSNameAndFieldSeparator) then
      PrintMode:=pmField
    Else If Find(DSMarker+DSName+DSNameAndPRSeparator) then
    Begin
      If Find(DSMarker+DSName+DSNameAndPRSeparator+MarkerGrow+DSMarkerTerm) then
        PrintMode:=pmTableGrow
      Else If Find(DSMarker+DSName+DSNameAndPRSeparator+MarkerInsert+DSMarkerTerm) then
        PrintMode:=pmTableInsert
      Else
        PrintMode:=pmNone;
    End
    Else
      PrintMode:=pmNone;
  end;

begin
  If FileExists(FileName) then
  begin
    FReportFileName:='';
    UData:=TUniDataModule.Create(FDataModule);

    If Assigned(FLogObject) then
      FLogObject.WriteLog('Загрузка шаблона...');
    vFileName:=LoadTemplate(FileName, Visible);
    If not VarIsNull(vFileName) then
    begin
      If Assigned(FLogObject) then
        FLogObject.WriteLog('...Загружен.');

      For i:=0 to UData.Count-1 do
      Begin
        DSName:=UData.DataSets[i].Name;
        FindPrintMode;
        If Assigned(FLogObject) then
          FLogObject.WriteLog('Набор данных : '+DSName);

        PMFindIterateCount:=0;
        repeat
          If PMFindIterateCount>15 then
            Break;
          If PrintMode<>pmNone then
          Begin
            DS:=UData.DataSets[i];

            If DS.FieldCount>0 then
            For j:=0 to DS.FieldCount-1 do
            Begin
              case PrintMode of
              pmField:
              Marker:=DSNameAndFieldSeparator+DS.Fields[j].FieldName;
              pmTableGrow:
              Marker:=DSNameAndPRSeparator+MarkerGrow;
              pmTableInsert:
              Marker:=DSNameAndPRSeparator+MarkerInsert;
              end;
              Marker:=DSMarker+DSName+Marker+DSMarkerTerm;

              FindIterateCount:=0;
              While Find(Marker) do
              Begin
                If FindIterateCount>15 then
                  Break;

                Case PrintMode of
                pmField:
                Begin
                  If Find(Marker) then
                  Begin
                    FindAndReplace(Marker, TrimRight(DS.Fields[j].AsString));
                    If Assigned(FLogObject) then
                      FLogObject.WriteLog('Маркер : '+Marker+', заменён на '+
                      TrimRight(DS.Fields[j].AsString));
                  End;
                End;
                pmTableGrow, pmTableInsert:
                begin
                  Case FOfficeType of
                  otMSOffice:
                  Begin
                    If FMsWord.Selection.Information[wdWithInTable]=True then
                    Begin
                      msTable:=FMsWord.Selection.Tables.Item(1);
                      msCell:=FMsWord.Selection.Cells.Item(1);

                      If Find(Marker) then
                      Begin
                        FindAndReplace(Marker, '');
                        ColsCount:=msTable.Columns.Count;
                        RowsCount:=msTable.Rows.Count;

                        BeginCol:=FMsWord.Selection.Cells.Item(1).Columnlndex;
                        BeginRow:=FMsWord.Selection.Cells.Item(1).RowIndex;

                        // DS.FetchAll;
                        DS.First;
                        Insert:=False;
                        Case PrintMode of
                        pmTableGrow:
                        FillRows:=iifi(RowsCount-BeginRow>=DS.RecordCount, DS.RecordCount,
                          RowsCount-BeginRow);
                        pmTableInsert:
                        FillRows:=DS.RecordCount;
                        End;
                        For r:=BeginRow to FillRows+BeginRow-1 do
                        Begin
                          If Insert then
                            msTable.InsertRows(r, 1);

                          For c:=BeginCol to ColsCount-1 do
                            SetCellTableObject(msTable, r, c, TrimRight(DS.Fields[c].AsString));

                          Case PrintMode of
                          pmTableInsert:
                          Insert:=True;
                          End;

                          DS.Next;
                        End;
                      End;
                    End;
                  End;
                  otOpOffice:
                  Begin
                    ooTextTable:=FOW.ViewCursor.CurrentTable;

                    If not VarIsEmpty(ooTextTable) then
                    Begin
                      If Find(Marker) then
                      Begin
                        FindAndReplace(Marker, '');
                        ooCell:=FOW.ViewCursor.CurrentCell;
                        CellName:=ooCell.CellName;
                        BeginCol:=Ord(Copy(UpperCase(CellName), 1, 1)[1])-65;
                        k:=2;
                        while CellName[k] in ['0'..'9'] do
                        Begin
                          If k=Length(CellName) then
                            Break;
                          Inc(k);
                        End;
                        BeginRow:=StrToInt(Copy(CellName, 2, k-1))-1;
                        ColsCount:=iifi(DS.FieldCount<=ooTextTable.getColumns.getCount,
                          DS.FieldCount, ooTextTable.getColumns.getCount);
                        RowsCount:=ooTextTable.getRows.getCount;

                        DS.First;
                        Insert:=False;
                        Case PrintMode of
                        pmTableGrow:
                        FillRows:=iifi(RowsCount-BeginRow>=DS.RecordCount, DS.RecordCount,
                          RowsCount-BeginRow);
                        pmTableInsert:
                        FillRows:=DS.RecordCount;
                        End;
                        For r:=BeginRow to FillRows+BeginRow-1 do
                        Begin
                          RecStr:='';
                          If Insert then
                            ooTextTable.getRows.InsertByIndex(r, 1);

                          For c:=BeginCol to ColsCount-1 do
                          Begin
                            SetCellTableObject(ooTextTable, r, c, TrimRight(DS.Fields[c].AsString));
                            RecStr:=RecStr+'['+TrimRight(DS.Fields[c].AsString)+'];';
                          End;

                          Case PrintMode of
                          pmTableInsert:
                          Insert:=True;
                          End;

                          DS.Next;
                        End;
                      End;
                    End;
                  end;
                  End;
                end;
                end;
                Inc(FindIterateCount);
              End;
            End;
            PrintMode:=pmNone;
          End;

          FindPrintMode;
          Inc(PMFindIterateCount);
        until PrintMode=pmNone;
      End;
    end;
  end;
end;

procedure TPrintDoc.ShowReport;
begin
  If FileExists(FReportFileName) then
    ShellExecute(0, nil, PChar(FReportFileName), nil, nil, SW_SHOWNORMAL);
end;

function TPrintDoc.Find(aFindText: string): Boolean;
var
  VOVFindText: OleVariant;
begin
  case FOfficeType of
  otMSOffice: // Find in Microsoft Word
  begin
    VOVFindText:=varAsType(aFindText, varOLEStr);
    if Length(Trim(aFindText))>0 then
    begin
      FWordDocument.Range(0, 0).Select;
      Result:=Boolean(FWordDocument.Application.Selection.Find.ExecuteOld(VOVFindText));
      { , EmptyParam, VOVMatchWholeWord, EmptyParam, EmptyParam,
        VOVMatchAllWords, VOVForward, VOVWrap, EmptyParam, EmptyParam, VOVReplace)); }
    end;
  end;
  otOpOffice: // Find in OpenOffice
  begin
    if Length(Trim(aFindText))>0 then
    begin
      Result:=FOW.FindFirst(aFindText, []);
      If Result then
        FOW.ViewCursor.SyncFrom(FOW.ModelCursor);
    end;
  end;
  end;
end;

procedure TPrintDoc.FindAndReplace(aFindText, AReplaceText: ShortString);
var
  VOVReplaceText, VOVMatchAllWords, VOVMatchWholeWord, VOVWrap, VOVReplace, VOVFindText: OleVariant; // for Microsoft Word
  VReplaceText: ShortString; // for OpenOffice
begin
  case FOfficeType of
  otMSOffice: // Replace in Microsoft Word
  begin
    VOVReplaceText:=AReplaceText;
    VOVFindText:=aFindText;
    if Length(Trim(aFindText))>0 then
    begin
      VOVMatchAllWords:=False;
      VOVMatchWholeWord:=True;
      VOVWrap:=wdFindContinue;
      VOVReplace:=wdReplaceAll;

      if Length(Trim(AReplaceText))>0 then
        VOVReplaceText:=AReplaceText
      else
        VOVReplaceText:='';

      FWordDocument.Range(0, 0).Select;
      FWordDocument.Application.Selection.Find.ExecuteOld(VOVFindText, EmptyParam,
        VOVMatchWholeWord, EmptyParam, EmptyParam, VOVMatchAllWords, EmptyParam, VOVWrap,
        { EmptyParam, } EmptyParam, VOVReplaceText, VOVReplace);
    end;
  end;
  otOpOffice: // Replace in OpenOffice
  begin
    if Length(Trim(aFindText))>0 then
    begin
      if Length(Trim(AReplaceText))>0 then
        VReplaceText:=AReplaceText
      else
        VReplaceText:='';
      FOW.ReplaceAll(aFindText, ConvertEncoding(VReplaceText, EncodingUTF8, DefaultSystemEncoding), [orpWholeWords]);
    end;
  end;
  end;
end;

destructor TPrintDoc.Destroy;
begin
  FMsWord:=Unassigned;
  FWordDocument:=Unassigned;
  FWordRuning:=False;
  FreeAndNil(FOW);
  FreeAndNil(FLogObject);
end;

function TPrintDoc.AddTemplate(FileName: string; PageBreak: Boolean): Boolean;
var
  typ, First, last, vFileName: OleVariant;
begin
  Result:=False;
  vFileName:=FileName;
  try
    case FOfficeType of
    otMSOffice: // Microsoft Word
    begin
      First:=FWordDocument.Characters.last.End_-1;
      last:=FWordDocument.Characters.last.End_-1;
      if PageBreak then
      begin
        typ:=wdPageBreak;
        FWordDocument.Range(First, last).InsertBreak(typ);
        First:=FWordDocument.Characters.last.End_-1;
        last:=FWordDocument.Characters.last.End_-1;
      end;
      FWordDocument.Range(First, last).InsertFile(vFileName, EmptyParam, EmptyParam, EmptyParam,
        EmptyParam);
    end;
    otOpOffice: // OpenOffice
    begin
      FOW.InsertDocument(vFileName, oipEndNewPage)
    end;
    end;
  finally
    Result:=True;
  end;
end;

constructor TPrintDoc.Create(DataModule: TDataModule; PriorytestOffice: TOfficeType;
  Var LogObj: TLogging);
begin
  CoInitialize(Nil);

  //FLogObject:=TLogging.Create(IncludeTrailingPathDelimiter(AppConfigDir)+'DebugOffice.txt', GPT.DebugOn);

  LogObject:=LogObj;
  FMsWord:=Unassigned;
  FWordDocument:=Unassigned;
  FWordRuning:=False;
  FOfficeType:=otNone;
  FOW:=nil;
  FDataModule:=DataModule;
  FOfficeType:=GetPossibleOffice(PriorytestOffice);
end;

function TPrintDoc.AddStrToTable(TableN, RowNum, RowCount: Integer): Boolean;
var
  i: Integer;
  RN: OleVariant;
begin
  Result:=False;
  try
    case FOfficeType of
    otMSOffice: // Microsoft Word
    begin
      RN:=FWordDocument.Tables.Item(TableN+1).Rows.Item(RowNum+1);
      for i:=1 to RowCount do
        FWordDocument.Tables.Item(TableN+1).Rows.Add(RN);
    end;
    otOpOffice: // OpenOffice
    begin
      if FOW.Tables[TableN].Rows.Count<RowNum then
        FOW.Tables[TableN].Rows.Append(RowCount)
      else
        FOW.Tables[TableN].Rows.Insert(RowNum, RowCount);
    end;
    end;
    Result:=True;
  Except
    Result:=False;
  end;
end;

function TPrintDoc.AddStrToTableObject(Table: Variant; RowNum, RowCount: Integer): Boolean;
var
  i: Integer;
  RN: OleVariant;
begin
  Result:=not VarIsNull(Table);
  if VarIsNull(Table) then
    Exit;
  try
    case FOfficeType of
    otMSOffice: // Microsoft Word
    begin
      RN:=Table.Rows.Item(RowNum+1);
      for i:=1 to RowCount do
        Table.Rows.Add(RN);
    end;
    otOpOffice: // OpenOffice
    begin
      if Table.getRows().getCount()<RowNum then
        Table.getRows.InsertByIndex(Table.getRows().getCount(), RowCount)
      else
        Table.getRows.InsertByIndex(RowNum, RowCount);
    end;
    end;
    Result:=True;
  Except
    Result:=False;
  end;
end;

function TPrintDoc.InsertIntoTable(TableN, RowNum, ColNum: Integer; aText: string): Boolean;
begin
  Result:=False;
  try
    case FOfficeType of
    otMSOffice: // Microsoft Word
    begin
      if (RowNum=1)and(ColNum=0) then
        AddStrToTableObject(TableN, 1, 1);
      FWordDocument.Tables.Item(TableN+1).Cell(RowNum+1, ColNum+1).Range.Text:=aText;
    end;
    otOpOffice: // OpenOffice
    begin
      if RowNum+1>FOW.Tables[TableN].Rows.Count then
        FOW.Tables[TableN].Rows.Append(RowNum+1-FOW.Tables[TableN].Rows.Count);
      FOW.Tables[TableN].Cell[ColNum, RowNum].AsText:=VarAsType(aText, varOleStr);
    end;
    end;
    Result:=True;
  Except
    Result:=False;
  end;
end;

procedure TPrintDoc.SaveReport(FileName: String);
begin
  FReportFileName:=FileName;
  Case FOfficeType of
  otMSOffice:
  Begin
    FWordDocument.SaveAs(FileName);
    FWordDocument.Close;

    if not VarIsNull(FMsWord) then
    begin
      FMsWord.Quit;
      FMsWord:=Unassigned;
    end;
  End;
  otOpOffice:
  begin
    FOW.SaveDocument(FileName, '');
    FOW.CloseDocument;
    if Assigned(FOW) then
      FreeAndNil(FOW);
  end;
  End;
end;

function TPrintDoc.SetCellTableObject(Table: Variant; RowNum, ColNum: Integer;
  aText: string): Boolean;
begin
  Result:=not VarIsNull(Table);
  If VarIsNull(Table) then
    Exit;
  try
    case FOfficeType of
    otMSOffice: // Microsoft Word
    begin
      // if (RowNum=1) and (ColNum = 0) then AddStrToTable(Table, 1, 1);
      Table.Cell(RowNum+1, ColNum+1).Range.Text:=aText; // InsertAfter
    end;
    otOpOffice: // OpenOffice
    begin
      If (RowNum+1>Table.getRows.getCount) then
        Table.getRows.InsertByIndex(Table.getRows.Count, RowNum+1-Table.getRows.getCount);

      Table.getCellByPosition(ColNum, RowNum).setString(aText);
    end;
    end;
    Result:=True;
  Except
    Result:=False;
  end;
end;

{ TUniDataModule }

function GetTextDatasetsNames(TextData: TStringList): TStringList;
Var
  i: Word;
  S: string;
Begin
  Result:=TStringList.Create;
  For i:=1 to TextData.Count do
  begin
    S:=TextData[i-1];
    If (S[1]='[')and(S[Length(S)]=']') then
    begin
      Result.Append(Copy(S, 2, Length(S)-2));
    end;
  end;
End;

constructor TUniDataModule.Create(DataModule: TDataModule);
var
  i: Word;
  vDS: TDataSet;
begin
  FDataModule:=DataModule;
  FDataSets:=TList.Create;

  FCount:=0;
  for i:=1 to FDataModule.ComponentCount do
    If FDataModule.Components[i-1] is TDCLDialogQuery then
    Begin
      vDS:=FDataModule.Components[i-1] as TDCLDialogQuery;
      FDataSets.Add(vDS);
      Inc(FCount);
    End;
end;

destructor TUniDataModule.Destroy;
begin
  FDataSets.Clear;
end;

function TUniDataModule.GetDataSet(Index: Word): TDataSet;
begin
  Result:=FDataSets[Index];
end;

end.
