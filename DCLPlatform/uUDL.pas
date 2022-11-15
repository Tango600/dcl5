unit uUDL;
// DCLDialog multi platform
// forum : http://www.dcl5.5bb.ru/
// Unreal Software (C) 2002
// UnrealSoftware@inbox.ru
{$I DefineType.pas}

interface

Uses
  SysUtils,
{$IFDEF MSWINDOWS}
  uNewFonts, Windows, ComObj,
{$ENDIF}
{$IFDEF UNIX}
  cwstring, process, unix, lclintf, BaseUnix,
{$ENDIF}
{$IFNDEF FPC}
{$IFDEF VCLFIX}
  VCLFixPack, ControlsAtomFix,
{$ENDIF}
{$ENDIF}
  Messages, Variants, Classes, Graphics, Controls, Forms, ExtCtrls, ToolWin,
  Grids, DB, StdCtrls, ComCtrls, Dialogs, Buttons, ExtDlgs, Menus, ClipBrd,
{$IFnDEF FPC}
  Vcl.DBCtrls, Vcl.DBGrids,
{$ELSE}
  DBCtrls, DBGrids,
{$ENDIF}
  DateUtils, IniFiles,
{$IFNDEF NOFASTREPORTS}
  frxCross, frxClass, frxDBSet,
{$ENDIF}
{$IFDEF ADO}
  ActiveX, ADODB, ADOConst, ADOInt,
{$ENDIF}
{$IFDEF FPC}
  {$IFDEF IBX}
    IBDatabase, IBTable, IBCustomDataSet, IBHeader, IBSQL, IBQuery,
    IBXConst,
  {$ENDIF}
{$ELSE}
  {$IFDEF IBX}
    IBX.IBDatabase, IBX.IBTable, IBX.IBCustomDataSet, IBX.IBHeader, IBX.IBSQL, IBX.IBQuery,
    IBX.IBVisualConst, IBX.IBXConst,
  {$ENDIF}
{$ENDIF}
{$IFDEF ZEOS}
  ZDbcIntfs, // ZConnection, ZDataset, ZSqlUpdate,
{$ENDIF}
{$IFDEF SQLdbFamily}
  SQLDB, SQLDBLib,
{$ENDIF}
{$IFDEF FPC}
  FileUtil, LazUTF8, LConvEncoding, {$IFDEF ZVComponents}ZVDateTimePicker, {$ENDIF}
{$ENDIF}
{$IFNDEF FPC}
  JPEG,
{$ENDIF}
  uDCLDownloader,
  uDCLMessageForm, uDCLSQLMonitor, uDCLQuery, uLogging, MD5, uDCLNetUtils,
  uStringParams, uDCLData, uDCLConst, uDCLTypes;

Type
  TDCLCommand=class;
  TDCLGrid=class;
  TDCLForm=class;
  TLogOnForm=class;
  TDCLOfficeReport=class;
  TDCLTextReport=class;
  TDCLBinStore=class;
  TBinStore=class;
  TFieldGroup=class;
  TDCLMainMenu=class;
  TVariables=class;

  {$IFDEF SQLdbFamily}
  Params=TParams;
  {$ENDIF}
  {$IFDEF ADO}
  Params=TParameters;
  {$ENDIF}

  { TDCLLogOn }

  TDCLLogOn=class(TObject)
  private
    FDBLogOn: TDBLogOn;
{$IFDEF FPC}{$IFDEF SQLdbFamily}
    FSQLDBLibraryLoader: TSQLDBLibraryLoader;
{$ENDIF}{$ENDIF}
{$IFDEF TRANSACTIONDB}
    IBTransaction: TTransaction;
{$ENDIF}
    FDCLMainMenu: TDCLMainMenu;
    FMainForm: TForm;
    RoleOK: TLogOnStatus;
    SQLMon: TDCLSQLMon;
    KillerDog: TTimer;
    FBusyMode: Boolean;

    FAccessLevel: TUserLevelsType;
    FForms: TList;
    ReturnFormsValues: Array of TReturnFormValue;
    ShadowQuery: TDCLDialogQuery;
    PassRetries: Byte;
    MessagesTimer: TTimer;
    MessageFormObject: TMessageFormObject;
    ExitFlag, FUserID: Integer;
    TimeToExit: Cardinal;
    DCLSession: TDCLSession;
    Timer1: TTimer;
    VirtualScripts:array of RVirtualScript;

    function AddVirtualScript(Scr:RVirtualScript):Integer;
    function FindVirtualScript(ScriptName:String):Integer;

    function GetFormsCount: Integer;
    function GetForm(Index: Integer): TDCLForm;
    function LoadScrText(ScrName: String): TStringList;

    procedure GetUserName(AUserName: String);
    function CheckPass(UserName, EnterPass, Password: String): Boolean;

    procedure WaitNotify(Sender: TObject);
    procedure LoggingUser(Login: Boolean);
    procedure RunInitSkripts;

    function GetConnected: Boolean;

    procedure KillerForms(Sender:TObject);
    Function GetBusyMode:Boolean;
  public
    // Command: TDCLCommand;
    CurrentForm: Integer;
    LogonParams: TLogonParams;
    RoleRaightsLevel: Word;
    Variables: TVariables;
    EvalFormula: String;
    NewLogOn: Boolean;

    constructor Create(DBLogOn: TDBLogOn);
    destructor Destroy; override;

    procedure About(Sender: TObject);
    function Login(UserName, Password: String; ShowForm: Boolean): TLogOnStatus;
    procedure Lock;
    procedure WriteBaseUID;
    function GetBaseUID:String;

{$IFDEF TRANSACTIONDB}
    function NewTransaction(RW:TTransactionType): TTransaction;
{$ENDIF}

    function GetVirtualScript(ScriptName: String):RVirtualScript;
    function GetVirtualScriptNum(Index:Integer):RVirtualScript;

    function ReadConfig(ConfigName, UserID: String): String;
    procedure WriteConfig(ConfigName, NewValue, UserID: String);
    function TableExists(TableName: String): Boolean;

    procedure InitActions(Sender: TObject);
    procedure RunCommand(CommandName: String);
    procedure CreateMenu(MainForm: TForm);
    function CreateForm(FormName: String; ParentForm, CallerForm: TDCLForm; Query: TDCLDialogQuery;
      Data: TDataSource; ModalMode: Boolean; ReturnValueMode: TChooseMode;
      ReturnValueParams: TReturnValueParams=nil; Script:TStringList=nil): TDCLForm;
    procedure CloseForm(Form: TDCLForm);
    procedure CloseFormNum(FormNum: Integer);
    procedure CloseAllForms;

    procedure SetDBName(var Query: TDCLDialogQuery);

    procedure NotifyForms(Action: TFormsNotifyAction);

    procedure GetTableNames(var List: TStrings);

    procedure RePlaseVariables(var VariablesSet: String);
    procedure TranslateVal(var S: String);
    procedure ExecVBS(VBSScript: String);
    procedure ExecShellCommand(ShellCommandText: String);

    function GetRolesQueryText(QueryType: TSelectType; WhereStr: String): String;

    function GetConfigInfo: String;
    function GetConfigVersion: String;
    function GetFullRaight: Word;
    function GetSecKeyData(Data: TMemoryStream; UserName: String): String;
    procedure SignScriptFile(FileName, UserName: String);
    procedure ReSignScriptFile(FileName: String);
    procedure RunSkriptFromFile(FileName: String);
    procedure ExtractScriptFile(FileName: String);

    procedure WriteBaseUIDtoINI(FileName, SectionName:string);
    
    function ConnectDB: Integer;
    procedure Disconnect;
    procedure ReconnectDB;

    property FormsCount: Integer read GetFormsCount;
    property MainForm: TForm read FMainForm;
    property Forms[Index: Integer]: TDCLForm read GetForm;
    property AccessLevel: TUserLevelsType read FAccessLevel;
    property Connected: Boolean read GetConnected;
    property IsBusy:Boolean read GetBusyMode write FBusyMode;
  end;

  TVariables=class(TObject)
  private
    FVariables: Array of TVariable;
    FDCLLogOn: TDCLLogOn;
    FDCLForm: TDCLForm;

    function FindEmptyVariableSlot: Integer;
    function VariableNumByName(Const VariableName: String): Integer;
    function GetVariableByName(Const VariableName: String): String;
    procedure SetVariableByName(Const VariableName, Value: String);
    function GetAllVariables: TList;
  public
    constructor Create(var DCLLogOn: TDCLLogOn; DCLForm: TDCLForm);
    destructor Destroy; override;

    procedure NewVariable(Const VariableName: String; Value: String);
    procedure NewVariableWithTest(Const VariableName: String);
    procedure FreeVariable(Const VariableName: String);
    function Exists(Const VariableName: String): Boolean;
    procedure RePlaseVariables(var VariablesSet: String; Query: TDCLDialogQuery);

    property Variables[Const VariableName: String]: String read GetVariableByName
      write SetVariableByName;
    property VariablesList: TList read GetAllVariables;
  end;

  TMainFormAction=class
    procedure CloseMainForm(Sender: TObject; var { %H- } Action: TCloseAction);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  end;

  TNoScrollBarDBGrid=class(TDCLDBGrid)
{$IFNDEF FPC}
  private
    FScrollBars: TScrollStyle;
    procedure SetScrollBars(Value: TScrollStyle);
  published
    property ScrollBars: TScrollStyle read FScrollBars write SetScrollBars default ssBoth;
{$ENDIF}
  end;

  TToolGrid=TNoScrollBarDBGrid;

  TLookupTable=record
    DCLGrid: TDCLGrid;
    LookupPanel: TDialogPanel;
  end;

  { TDCLGrid }

  TDCLGrid=class(TComponent)
  private
    FromForm: String;
    FGridPanel: TDCLMainPanel;
    FDCLLogOn: TDCLLogOn;
    FForm: TDBForm;
    FDCLForm: TDCLForm;
    FGrid: TDCLDBGrid;
    FQueryGlob: TDCLQuery;
    FData: TDataSource;
    FDisplayMode: TDataControlType;
    FMultiSelect, FShowed, RefreshLock: Boolean;
    PreviousColumnIndex: Integer;
    PopupGridMenu: TPopupMenu;
    ItemMenu, ToItem: TMenuItem;
    Navig: TDBNavigator;
    FindGrid: TStringGrid;
    PosBookCreated, FReadOnly, FindProcess, PagePanelCreated: Boolean;
    FUserLevelLocal: TUserLevelsType;
    FOptions: TDBGridOptions;
    LabelField: TDialogLabel;
    FOrientation: TOrientation;
    PartButtonLeft, PartButtonTop, ToolPanelElementLeft: Word;
    EditField: TDBEdit;
    ColumnsList, FieldsList: TListBox;
    Splitter1, Splitter2: TSplitter;
    FindFields: TStringList;
    PagePanel, ToolPanel, FieldPanel: TDialogPanel;
    FTablePartsPages: TPageControl;
    FTablePartsTabs: TTabSheet;
    FLocalBookmark: TBookmark;
    SummString: String;
    FTableParts: Array of TDCLGrid;
    PartTabIndex, MaxStepFields: Integer;
    NotAllowedOperations: TOperationsTypes;
    RowColor, RowTextColor: TColor;
    SummGrid: TToolGrid;
    SumQuery: TDCLDialogQuery;
    SumData: TDataSource;
    RefreshTimer: TTimer;
    LastStateTimer, BaseChanged: Boolean;
    MediaFields: Array of TFieldGroup;
    KeyMarks: TKeyBookmarks;
    ButtonPanel: TDialogPanel;
    ToolButtonPanel: TToolBarPanel;
    ToolButtonsCount: Byte;
    ToolButtonPanelButtons: Array [1..ToolCommandsCount] of TDialogSpeedButton;
    ToolCommands: Array [1..ToolCommandsCount] of String;

    DateBoxes: Array of TDateBox;
    CheckBoxes: Array of RCheckBox;
    DBCheckBoxes: Array of TDBCheckBox;
    Lookups: Array of RLookups;
    ContextFieldButtons: Array of TContextFieldButton;
    RollBars: Array of TRollBar;
    BrushColors: Array of TBrushColors;
    ContextLists: Array of TContextList;
    DropBoxes: Array of TDropBox;
    LookupTables: Array of TLookupTable;

    EventsScroll, EventsBeforeScroll, EventsDelete, EventsAfterOpen, EventsAfterPost, EventsCancel,
      EventsInsert, LineDblClickEvents, EventsBeforePost: TEventsArray;

    StructModify: Array of RStructModify;
    OrderByFields: Array of String;

    procedure ToolButtonsOnClick(Sender: TObject);

    function AddTablePart(Parent: TWinControl; Data: TDataSource; Style:TDataControlType): Integer;
    function GetSummQuery: String;
    function QueryBuilder(QueryMode: Byte): String;
    function GetFingQuery: String;
    function FindRaightQuery(): String;
    procedure ChangeTabPage(Sender: TObject);
    function GetTablePartsCount:Integer;

    procedure ClickNavig(Sender: TObject; Button: TNavigateBtn);
    procedure SortDB(Column: TColumn);

    procedure AutorefreshTimer(Sender: TObject);
    procedure SetBookMark(Sender: TObject);
    procedure PosToBookMark(Sender: TObject);
    procedure DeleteMenuBookMark(BookMarkNum: Integer);

    procedure SaveDB;
    procedure CancelDB;

    // DataEvents
    procedure AfterInsert(Data: TDataSet);
    procedure ScrollDB(Data: TDataSet);
    procedure AfterOpen(Data: TDataSet);
    procedure AfterClose(Data: TDataSet);
    procedure AfterEdit(Data: TDataSet);
    procedure AfterPost(Data: TDataSet);
    procedure AfterCancel(Data: TDataSet);

    procedure BeforeScroll(Data: TDataSet);
    procedure BeforeOpen(Data: TDataSet);
    procedure BeforePost(Data: TDataSet);

    procedure OnDelete(Data: TDataSet);
    procedure AfterRefresh(Data: TDataSet);
    // End DataEvents
    procedure ExecEvents(EventsArray: TEventsArray);

    procedure RePlaseParams(var Params: String);

    procedure SetDataStatus(Status: TDataStatus);
    function GetSQL: String;
    procedure SetSQL(SQL: String);

    function GetDisplayMode: TDataControlType;
    procedure SetDisplayMode(DisplayMode: TDataControlType);
    function GetFieldCount: Integer;
    function GetQuery: TDCLQuery;
    procedure SetQuery(Query: TDCLQuery);
    procedure SetReadOnly(Value: Boolean);
    function GetReadOnly: Boolean;
    procedure SetGridOptions(Options: TDBGridOptions);
    procedure IncXYPos(StepTop, StepLeft: Word; var Field: RField);

    procedure DBEditClick(Sender: TObject);
    procedure EditClick(Sender: TObject);
    procedure EditOnFloatData(Sender: TObject; var Key: Char);
    procedure EditOnEdit(Sender: TObject);
    procedure OnChangeDateBox(Sender: TObject);
    procedure CheckOnClick(Sender: TObject);
    procedure GridDblClick(Sender: TObject);
    procedure LookupOnClick(Sender: TObject);
    procedure LookupDBScroll(Data: TDataSet);
    procedure ContextFieldButtonsClick(Sender: TObject);
    procedure RollBarOnChange(Sender: TObject);
    procedure ContextListKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure ContextListChange(Sender: TObject);
    procedure DropListOnSelectItem(Sender: TObject);

    function GetColumns: TDBGridColumns;
    procedure SetColumns(Cols: TDBGridColumns);

    // procedure SetRequiredFields;

    procedure DeleteList(Index: Word);
    procedure ColumnsManege(Sender: TObject);
    procedure FieldsManege(Sender: TObject);

    procedure ExecFilter(Sender: TObject);
    procedure ExecComboFilter(Sender: TObject);
    procedure OnContextFilter(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure CalendarOnChange(Sender: TObject);
    procedure OnNotCheckClick(Sender: TObject);

    function GetTablePart(Index: Integer): TDCLGrid;
    procedure SetTablePart(Index: Integer; Value: TDCLGrid);

    procedure AddPopupMenuItem(Caption, ItemName: String; Action: TNotifyEvent;
      AChortCutKey: String; Tag: Integer; PictType: String);
    procedure AddSubPopupItem(Caption, ItemName: String; Action: TNotifyEvent;
      ToMenu, Tag: Integer);
    procedure GridDrawDataCell(Sender: TObject; Const Rect: TRect; DataCol: Integer;
      Column: TColumn; State: TGridDrawState);
    procedure SetMultiselect(Value: Boolean);
    function GetMultiselect: Boolean;
    function GetFieldDataType(FieldName: String): TFieldType;

    property FQuery: TDCLQuery read GetQuery write SetQuery;
  public
    QueryName, DependField, MasterDataField, MasterValueVariableName: String;
    NoDataField: Boolean;
    TabType: TPageType;
    CurrentTabIndex, Tag: Integer;
    DataFields: Array of TDCLDataFields;
    QuerysStore: Array of TDCLQueryStore;
    DBFilters: Array of TDBFilter;
    Calendars: Array of RCalendar;
    Edits: Array of TDCLEdits;
    PartSplitter: TSplitter;

    constructor Create(var Form: TDCLForm; Parent: TWinControl; SurfType: TDataControlType;
      Query: TDCLDialogQuery; Data: TDataSource);
    destructor Destroy; override;

    procedure CreateFields(FOPL: TStringList);

    procedure RefreshBookMarkMenu;
    procedure CreateBookMarkMenu(MenuList: TStringList);
    function SaveBookMarkMenu: TStringList;
    procedure DeleteAllBookmarks;

    procedure OpenQuery(QText: String);
    procedure Open;
    procedure Close;
    procedure Show;
    procedure AddColumn(Field: RField);
    procedure CreatePartColumns;
    procedure AddField(Field: RField);
    procedure SetSQLToStore(SQL: String; QueryType: TQueryType; Raight: TUserLevelsType);
    function GetSQLFromStore(QueryType: TQueryType): String;
    procedure ReFreshQuery;
    procedure SetNewQuery(Data: TDataSource);

    procedure Structure(Sender: TObject);
    procedure PFind(Sender: TObject);
    procedure PSetFind(Sender: TObject);
    procedure PClearAllFind(Sender: TObject);
    procedure Print(Sender: TObject);
    procedure PCopy(Sender: TObject);
    procedure PCut(Sender: TObject);
    procedure PPaste(Sender: TObject);
    procedure PUndo(Sender: TObject);

    procedure AddLabel(Field: RField; Caption: String);
    procedure AddEdit(var Field: RField);
    procedure AddFieldBox(var Field: RField; FieldBoxType: TFieldBoxType; NamePrefix: String);
    procedure AddDateBox(var Field: RField);
    procedure AddSimplyCheckBox(var Field: RField);
    procedure AddCheckBox(var Field: RField);
    procedure AddDBCheckBox(var Field: RField);
    procedure AddLookUp(var Field: RField);
    procedure AddContextButton(var Field: RField);
    procedure AddRollBar(var Field: RField);
    procedure AddBrushColor(OPL: String);
    procedure AddContextList(var Field: RField);
    procedure AddDropBox(var Field: RField);
    procedure AddSumGrid(OPL: String);
    procedure AddLookupTable(var Field: RField);
    procedure AddMediaFieldGroup(Parent: TWinControl; Align: TAlign; GroupType: TGroupType;
      var Field: RField);

    function AddPartPage(Caption: String; Data: TDataSource; Style:TDataControlType): Integer;
    procedure AddToolPanel;
    procedure AddDBFilter(Filter: TDBFilter);
    procedure SetSQLDBFilter(SQL: String);
    procedure AddCalendar(Calendar: RCalendar);
    procedure AddToolPartButton(ButtonParam: RButtonParams);
    procedure ClearNotAllowedOperations;
    procedure ExcludeNotAllowedOperation(Operation: TNotAllowedOperations);
    procedure AddNotAllowedOperation(Operation: TNotAllowedOperations);
    function FindNotAllowedOperation(Operation: TNotAllowedOperations): Boolean;

    procedure TranslateVal(var Params: String);

    property SQL: String read GetSQL write SetSQL;
    property DisplayMode: TDataControlType read GetDisplayMode write SetDisplayMode;
    property DataSource: TDataSource read FData;
    property Query: TDCLQuery read GetQuery;
    property FieldCount: Integer read GetFieldCount;
    property ReadOnly: Boolean read GetReadOnly write SetReadOnly;
    property Options: TDBGridOptions read FOptions write SetGridOptions;
    property Columns: TDBGridColumns read GetColumns write SetColumns;
    property GridPanel: TDCLMainPanel read FGridPanel write FGridPanel;
    property Grid: TDCLDBGrid read FGrid;
    property TableParts[Index: Integer]: TDCLGrid read GetTablePart write SetTablePart;
    property TablePartsCount:Integer read GetTablePartsCount;
    property MultiSelect: Boolean read GetMultiselect write SetMultiselect;
  end;

  { TFieldGroup }

  TFieldGroup=class(TObject)
  private
    FData: TDataSource;
    ThumbPanel, ButtonPanel: TPanel;
    FieldCaption: TLabel;
    MemoField: TDBMemo;
    GraficField: TDBImage;
    RichField: {$IFDEF DELPHI}TDBRichEdit; {$ELSE}TDBMemo; {$ENDIF}
    FieldName: String;
    FGraphicFileType: TGraficFileType;
    FGroupType: TGroupType;
    LoadButton, SaveButton, ClearButton: TSpeedButton;
    OpenPictureDialog: TOpenPictureDialog;
    SavePictureDialog: TSavePictureDialog;
    OpenDialog: TOpenDialog;
    SaveDialog: TSaveDialog;

    procedure Load(Sender: TObject);
    procedure Save(Sender: TObject);
    procedure Clear(Sender: TObject);

    procedure SaveData(FileName: String);
    procedure LoadData(FileName: String);

    procedure OnDBImageRead(Sender: TObject; S: TStream; var GraphExt: String);
  public
    constructor Create(Parent: TWinControl; Data: TDataSource; var Field: RField; aAlign: TAlign;
      GroupType: TGroupType);
    destructor Destroy; override;
  end;

  TDCLCommandButton=class(TObject)
  private
    Commands: Array of String;
    CommandButton: Array of TDialogButton;
    FDCLForm: TDCLForm;
    FDCLLogOn: TDCLLogOn;

    procedure ExecCommand(Sender: TObject);
  public
    constructor Create(var DCLLogOn: TDCLLogOn; var DCLForm: TDCLForm);
    destructor Destroy; override;

    procedure AddCommand(Parent: TWinControl; ButtonParams: RButtonParams);
  end;

  { TDCLForm }

  TDCLForm=class(TComponent)
  private
    SingleMod: Boolean;
    FName, CloseQueryText: String;
    FCloseAction: TDCLFormCloseAction;
    FParentForm, FCallerForm: TDCLForm;
    UserLevelLocal: TUserLevelsType;
    FOPL: TStringList;
    FFormNum, FormHeight, FormWidth: Integer;
    TB: TFormPanelButton;
    FNewPage, NoVisual, NoStdKeys, FieldsSettingsReseted, SettingsLoaded,
    NoCloseable, CloseQuery, FormCanClose: Boolean;
    FForm: TDBForm;
    FDCLLogOn: TDCLLogOn;
    FGrids: Array of TDCLGrid;
    MainPanel: TDCLMainPanel;
    IncButtonPanelHeight: Word;
    ButtonLeft, ButtonTop: Integer;
    FPages: TPageControl;
    FTabs: TTabSheet;
    CurrentGridIndex, CurrentTabIndex, GridIndex: Integer;
    DataGlob: TDataSource;
    QueryGlobIndex: Integer;
    DBStatus: TStatusBar;
    GridPanel: TDialogPanel;
    ParentPanel: TWinControl;
    ItemMenu, ToItem: TMenuItem;
    Commands: TDCLCommandButton;
    EventsClose: TEventsArray;
    FRetunValue: TReturnFormValue;
    FReturningMode: TChooseMode;
    FReturnValueParams: TReturnValueParams;
    FFormMenu: TMainMenu;

    function AddGrid(Parent: TWinControl; SurfType: TDataControlType; Query: TDCLDialogQuery;
      Data: TDataSource): Integer;
    procedure AddMainPage(Query: TDCLDialogQuery; Data: TDataSource);
    procedure ChangeTabPage(Sender: TObject);
    procedure AddEvents(var Events: TEventsArray; EventsSet: String);

    function GetMainQuery: TDCLQuery;
    function GetDataSource: TDataSource;
    function GetPartQuery: TDCLQuery;

    function GetParentForm: TDCLForm;
    procedure ResizeDBForm(Sender: TObject);

    function GetTable(Index: Integer): TDCLGrid;
    procedure SetTable(Index: Integer; Value: TDCLGrid);
    function GetTablesCount: Integer;
    procedure ActivateForm(Sender: TObject);

    procedure ToolButtonClick(Sender: TObject);

    procedure CloseForm(Sender: TObject; var { %H- } Action: TCloseAction);
    procedure OnCloseQuery(Sender: TObject; var CanClose: Boolean);

    procedure ExecCommand(CommandName: String);

    function GetQueryToRaights(S: String): String;

    function ReadBaseINI(IniType:TINIType):TStringList;
    procedure WriteBaseINI(IniType:TINIType; Params:TStringList);
    procedure DeleteBaseINI(IniType:TINIType; All:Boolean);

    procedure LoadFormPos;
    procedure LoadFormPosINI;
    procedure LoadFormPosBase;
    procedure LoadFormPosUni(DialogParams: TStringList);
    procedure SaveFormPos;
    procedure SaveFormPosINI;
    procedure SaveFormPosBase;
    function SaveFormPosUni: TStringList;

    procedure DeleteFormPos(All:Boolean);
    procedure DeleteFormPosBase(All:Boolean);
    procedure DeleteFormPosINI(All:Boolean);
    procedure DeleteAllFormPos;

    procedure SaveBookMarkMenu;
    procedure SaveBookmarkMenuINI;
    procedure SaveBookmarkMenuBase;

    procedure LoadBookmarkMenu;
    procedure LoadBookmarkMenuINI;
    procedure LoadBookmarkMenuBase;

    procedure CreateBookMarkMenuUni(MenuList: TStringList);
    function SaveBookMarkMenuUni: TStringList;

    procedure AddSubItem(Caption, ItemName, Pict: String; Level: Integer; Action: TNotifyEvent);
    procedure AddMainItem(Caption, ItemName, Pict: String; Action: TNotifyEvent);

    procedure ResetFieldsSettings(Sender: TObject);
    procedure ResetAllFieldsSettings(Sender: TObject);
    procedure DeleteAllBookmarks(Sender: TObject);
    procedure SaveFieldsSettings(Sender: TObject);
  public
    LocalVariables: TVariables;
    Modal, NotDestroyedDCLForm, ExitNoSave: Boolean;
    FDialogName: String;
    ExitCode: Byte;

    constructor Create(DialogName: String; var DCLLogOn: TDCLLogOn; ParentForm, CallerForm: TDCLForm;
      aFormNum: Integer; OPL: TStringList; Query: TDCLDialogQuery; Data: TDataSource;
      Modal: Boolean=False; ReturnValueMode: TChooseMode=chmNone;
      ReturnValueParams: TReturnValueParams=nil);
    destructor Destroy; override;

    procedure CloseDialog;
    procedure Choose;
    function GetActive: Boolean;

    procedure RePlaseVariables(var VariablesSet: String);
    procedure RePlaseParams(var Params: String);
    procedure TranslateVal(var Params: String; CheckParams: Boolean);
    procedure SetDBStatus(StatusStr: String);
    procedure AddStatus(StatusStr: String; Width: Integer);
    procedure SetStatus(StatusStr: String; StatusNum, Width: Integer);
    procedure SetStatusWidth(StatusNum, Width: Integer);
    procedure DeleteStatus(StatusNum: Integer);
    procedure DeleteAllStatus;
    procedure SetRecNo;
    procedure SetTabIndex(Index: Integer);
    procedure RefreshForm;
    procedure CloseDatasets;
    procedure ResumeDatasets;
    procedure SetVariable(VarName, VValue: String);
    procedure GetChooseValue;
    function ChooseAndClose(Action: TChooseMode): TReturnFormValue;
    function GetPreviosForm:TDCLForm;

    property DialogName: String read FName write FName;
    property CurrentQuery: TDCLQuery read GetMainQuery;
    property DataSource: TDataSource read GetDataSource;
    property CurrentPartQuery: TDCLQuery read GetPartQuery;
    property Tables[Index: Integer]: TDCLGrid read GetTable write SetTable;
    property TablesCount: Integer read GetTablesCount;
    property CurrentTableIndex: Integer read CurrentGridIndex;
    property Form: TDBForm read FForm;
    property ParentForm: TDCLForm read FParentForm;
    property FormNum: Integer read FFormNum;
    property ReturnFormValue: TReturnFormValue read FRetunValue;
    property CloseAction: TDCLFormCloseAction read FCloseAction write FCloseAction;
    property IsSingle: Boolean read SingleMod write SingleMod;
  end;

  { TDCLCommand }

  TDCLCommand=class(TObject)
  private
    FCommandDCL, Spool: TStringList;
    FDCLForm: TDCLForm;
    RetVal: TReturnFormValue;
    FDCLLogOn: TDCLLogOn;
    DCLQuery, DCLQuery2: TDCLDialogQuery;
    Executed, StopFlag, Breaking: Boolean;
    TextReport: TDCLTextReport;
    OfficeReport: TDCLOfficeReport;
    BinStore: TBinStore;
    SpoolFileName: String;
    Downloader: TDownloader;

    procedure ExportData(Tagert: TSpoolType; Scr: String);
    procedure RePlaseVariabless(var Variables: String);
    procedure RePlaseParamss(var ParamsSet: String; Query: TDCLDialogQuery);
    procedure SetValue(S: String);
    function ExpressionParser(Expression: String): String;
    function GetRaightsByContext(InContext: Boolean): TUserLevelsType;
    procedure TranslateVals(var Params: String; Query: TDCLDialogQuery);
    procedure TranslateValContext(var Params: String);
    procedure RunSkriptFromFile(FileName: String);
    procedure ExtractScriptFile(FileName: String);
  public
    constructor Create(DCLForm: TDCLForm; var DCLLogOn: TDCLLogOn);
    destructor Destroy; override;

    procedure ExecSQLCommand(SQLCommand: String; InContext: Boolean);
    procedure SetVariable(VarName, VValue: String);

    procedure ExecCommand(Command: String; DCLForm: TDCLForm);
  end;

  { TDCLMainMenu }

  TDCLMainMenu=class(TObject)
  private
    ItemMenu, ToItem: TMenuItem;
    FDCLLogOn: TDCLLogOn;
    FMainForm: TForm;
    FMainMenu: TMainMenu;
    FForm: TForm;
    MainFormStatus: TStatusBar;
    FormBar: TToolBar;
    MainFormAction: TMainFormAction;

    procedure ExecCommand(Command: String);
    procedure AddMainItem(Caption, ItemName: String);
    procedure AddSubItem(Caption, ItemName: String; Level: Integer);
    procedure AddSubSubItem(Caption, ItemName: String; Level, Index: Integer);
    function FindMenuItemIndex(ItemName: String): Integer;
    function FindSubMenuItemIndex(ItemName: String; Level: Integer): Integer;
  public
    constructor Create(var DCLLogOn: TDCLLogOn; Form: TForm; Relogin: Boolean=False);
    destructor Destroy; override;

    procedure ClickMenu(Sender: TObject);
    procedure UpdateFormBar;

    procedure LockMenu;
    procedure UnLockMenu;
    procedure ChoseRunType(Command, DCLText, Name: String; Order: Byte);

    property MainForm: TForm read FMainForm;
  end;

  TLogOnForm=class(TObject)
  private
    RoleForm: TForm;
    Panel: TPanel;
    DCLLogo: TImage;
    RoleNameCombo: TComboBox;
    RoleNameEdit, RolePassEdit: TEdit;
    RoleLabel: TDialogLabel;
    RoleButtonOK, RoleButtonCancel, ChangePassButton: TDialogButton;
    RolesQuery1: TDCLDialogQuery;
    FDCLLogOn: TDCLLogOn;
    PressOK: TPassStatus;
    FEnterPassword, FUserName: String;
    ChangePassForm: TForm;
    OldPassEdit, NewPassEdit1, NewPassEdit2: TEdit;
    OkButton, CancelButton: TDialogButton;
    LabelPass: TDialogLabel;
    HashPassChk: TCheckbox;
    CountShowRole: Word;
    HashPass, FormCreated, NoShowRoleField: Boolean;

    procedure ChangePass(Sender: TObject);

    procedure OnShowForm(Sender: TObject);
    procedure OnCloseForm(Sender: TObject; var { %H- } Action: TCloseAction);
    procedure OnCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure OkButtonClick(Sender: TObject);
    procedure CancelButtonClick(Sender: TObject);
    procedure OkChangePass(Sender: TObject);
    procedure CancelChangePass(Sender: TObject);
    procedure OnSetHashPassword(Sender: TObject);

    procedure ShowChangePasswordForm;
    procedure ChangePassword(AUserID, NewPassword: String);
  public
    constructor Create(var DCLLogOn: TDCLLogOn; UserName: String; NoClose, Relogin: Boolean);
    destructor Destroy; override;

    procedure CreateForm(NoClose, Relogin: Boolean; UserName: String);
    procedure ShowForm;

    property EnterPass: String read FEnterPassword;
    property UserName: String read FUserName;
  end;

  TPrintBase=class(TObject)
    procedure Print(Grid: TDCLDBGrid; Query: TDCLDialogQuery; Caption: String);
  end;

  { TDCLTextReport }

  TDCLTextReport=class(TObject)
  private
    GlobalSQL, Template, RepParams, HeadLine, Body, Report, Futer, InitSkrypts,
      EndSkrypts: TStringList;
    FDCLLogOn: TDCLLogOn;
    FDCLGrid: TDCLGrid;
    FReportQuery: TDCLDialogQuery;
    GrabValueForm: TForm;
    VarsToControls: Array of String;
    FSaved: Boolean;

    procedure RePlaseVariables(var VarsSet: String);
    procedure GrabValListOnChange(Sender: TObject);
    procedure GrabDateOnChange(Sender: TObject);

    procedure GrabDialogButtonsOnClick(Sender: TObject);

    procedure ValComboOnChange(Sender: TObject);
    procedure GrabValOnEdit(Sender: TObject);

    function SetVarToControl(VarName: String): Integer;
  public
    FDialogRes: TModalResult;
    InConsoleCodePage:Boolean;

    constructor InitReport(DCLLogOn: TDCLLogOn; DCLGrid: TDCLGrid; OPL: TStringList;
      ParamsSet: Cardinal; Mode: TNewQueryMode);
    destructor Destroy; override;

    procedure CloseReport(FileName: String);

    procedure OpenReport(FileName: String; ViewMode: TReportViewMode);
    procedure PrintigReport;
    procedure ReplaseRepParams(var ReplaseText: TStringList);
    function TranslateRepParams(ParamName: String): String;
    function SaveReport(FileName: String): String;

    property DialogRes: TModalResult read FDialogRes;
  end;

  {$IFNDEF NOFASTREPORTS}
  TDCLFastReports=class(TObject)
  private
    FDCLLogOn:TDCLLogOn;
    FDataModule:TDataModule;
    FRXRep:TfrxReport;
    BinStore:TDCLBinStore;

  public
    constructor Create(DCLLogOn:TDCLLogOn; DataModule:TDataModule;
      ScriptLanguage:TFastReportsScriptLanguage=DefaultFRScriptLanguage);
    destructor Destroy; override;

    function LoadReportFile(FileName:string):Boolean;
    function LoadReportFromBinStore(DataName:string):Boolean;
    procedure ShowReport;
  end;
  {$ENDIF}

  TDCLOfficeReport=class(TObject)
  private
    BinStor: TDCLBinStore;
    FDCLLogOn: TDCLLogOn;
    FDCLGrid: TDCLGrid;
    OO, NF, Loc, Sheets, Sheet, Cell, Range, Desktop, Document, VariantArray: Variant;
{$IFDEF MSWINDOWS}
    MsWord, Excel, WBk: OleVariant;
{$ENDIF}
    WordVer: Byte;
  public
    OfficeDocumentFormat: TOfficeDocumentFormat;
    OfficeFormat: TOfficeFormat;

    constructor Create(DCLLogOn: TDCLLogOn; DCLGrid: TDCLGrid);
    destructor Destroy; override;

    procedure ReportOpenOfficeWriter(ParamStr: String; Save, Close: Boolean);
    procedure ReportOpenOfficeCalc(ParamStr: String; Save, Close: Boolean);
    procedure ReportWord(ParamStr: String; Save, Close: Boolean);
    procedure ReportExcel(ParamStr: String; Save, Close: Boolean);
  end;

  { TBaseBinStore }

  TBaseBinStore=class(TObject)
  private
    FErrorCode: Byte;
    FDCLLogOn: TDCLLogOn;
    DCLQuery: TDCLQuery;
    FTableName, FKeyField, FNameField, FDataField: String;
  public
    constructor Create(DCLLogOn: TDCLLogOn; TableName, KeyField, NameField, DataField: String);
    destructor Destroy; override;

    function GetData(DataName: String; FindType: TFindType): TMemoryStream;
    procedure SetData(DataName, Data: String; FindType: TFindType; Stream: TMemoryStream;
      Compress: Boolean);
    function IsDataExist(DataName: String; FindType: TFindType): Boolean;
    procedure DeleteData(DataName: String; FindType: TFindType);
    procedure ClearData(DataName: String; FindType: TFindType);

    procedure StoreFromFile(FileName, DataName, Data: String; FindType: TFindType;
      Compress: Boolean);
    procedure SaveToFile(FileName, DataName: String; FindType: TFindType);

    procedure CompressData(DataName, Data: String; FindType: TFindType);
    procedure DeCompressData(DataName, Data: String; FindType: TFindType);

    function MD5(DataName: String; FindType: TFindType): String;

    property ErrorCode: Byte read FErrorCode;
  end;

  { TBinStore }

  TBinStore=class(TBaseBinStore)
  private
    FFindType: TFindType;
  public
    constructor Create(DCLLogOn: TDCLLogOn; FindType: TFindType;
      TableName, KeyField, NameField, DataField: String);
    destructor Destroy; override;

    procedure StoreFromFile(FileName, DataName, Data: String; Compress: Boolean);
    procedure SaveToFile(FileName, DataName: String);

    function GetData(DataName: String): TMemoryStream;
    procedure SetData(DataName, Data: String; Stream: TMemoryStream; Compress: Boolean);
    function IsDataExist(DataName: String): Boolean;
    procedure DeleteData(DataName: String);
    procedure ClearData(DataName: String);

    procedure CompressData(DataName, Data: String);
    procedure DeCompressData(DataName, Data: String);

    function MD5(DataName: String): String;
  end;

  { TDCLBinStore }

  TDCLBinStore=class(TBinStore)
  private
    //
  public
    constructor Create(DCLLogOn: TDCLLogOn);
    destructor Destroy; override;

    function GetTemplateFile(Template, FileName, Ext: String): String;

    procedure StoreFromFile(FileName, DataName: String; Compress: Boolean);
    procedure SaveToFile(FileName, DataName: String);

    procedure DeleteData(DataName: String);
    procedure ClearData(DataName: String);

    procedure CompressData(DataName: String);
    procedure DeCompressData(DataName: String);

    function MD5(DataName: String): String;
  end;

{$IFDEF EMBEDDED}
  procedure InitDCL(DBLogOn: TDBLogOn);
{$ENDIF}
  procedure EndDCL;

{$IFNDEF FPC}
{$R units\dbgrids.res}
{$R units\dbctrls.res}
{$ENDIF}

var
  DCLMainLogOn: TDCLLogOn;
  Logger: TLogging;

implementation

Uses
  uDCLUtils, uDCLMultiLang, SumProps, uDCLDBUtils, uDCLOfficeUtils, uLZW;

{ TVariables }

function TVariables.FindEmptyVariableSlot: Integer;
var
  i: Integer;
begin
  For i:=1 to Length(FVariables) do
  begin
    If FVariables[i-1].Name='' Then
    begin
      Result:=i-1;
      break;
    end;
  end;
  i:=Length(FVariables);
  SetLength(FVariables, i+1);
  Result:=i;
end;

procedure TVariables.SetVariableByName(Const VariableName, Value: String);
var
  vv1: Integer;
begin
  vv1:=VariableNumByName(VariableName);
  If vv1<> - 1 Then
    FVariables[vv1].Value:=Value;
end;

function TVariables.VariableNumByName(Const VariableName: String): Integer;
var
  VarNum: Integer;
begin
  Result:= - 1;
  If VariableName<>'' Then
  begin
    For VarNum:=0 to Length(FVariables)-1 do
      If LowerCase(FVariables[VarNum].Name)=LowerCase(Trim(VariableName)) Then
      begin
        Result:=VarNum;
        break;
      end;
  end;
end;

constructor TVariables.Create(var DCLLogOn: TDCLLogOn; DCLForm: TDCLForm);
begin
  inherited Create;
  FDCLLogOn:=DCLLogOn;
  FDCLForm:=DCLForm
end;

destructor TVariables.Destroy;
begin
  //
end;

function TVariables.Exists(Const VariableName: String): Boolean;
var
  VarNum: Integer;
begin
  Result:=False;
  if VariableName<>'' then
    For VarNum:=0 to Length(FVariables)-1 do
      If UpperCase(Trim(VariableName))=UpperCase(FVariables[VarNum].Name) Then
      begin
        Result:=True;
        break;
      end;
end;

function TVariables.GetVariableByName(Const VariableName: String): String;
var
  vv1: Integer;
begin
  Result:='';
  vv1:=VariableNumByName(VariableName);
  If vv1<> - 1 Then
    Result:=FVariables[vv1].Value;
end;

procedure TVariables.NewVariable(Const VariableName: String; Value: String);
var
  RetVarNum: Integer;
begin
  if VariableName<>'' then
  begin
    RetVarNum:=VariableNumByName(VariableName);
    If RetVarNum= - 1 Then
    begin
      RetVarNum:=FindEmptyVariableSlot;
      If RetVarNum<> - 1 Then
      begin
        FVariables[RetVarNum].Name:=Trim(VariableName);
        FVariables[RetVarNum].Value:=Value;
      end;
    end
    Else
    begin
      FVariables[RetVarNum].Value:=Value;
    end;
  end;
end;

procedure TVariables.NewVariableWithTest(Const VariableName: String);
var
  RetVarNum: Integer;
begin
  if VariableName<>'' then
  begin
    RetVarNum:=VariableNumByName(VariableName);
    If RetVarNum= - 1 Then
    begin
      RetVarNum:=FindEmptyVariableSlot;
      If RetVarNum<> - 1 Then
      begin
        FVariables[RetVarNum].Name:=Trim(VariableName);
        FVariables[RetVarNum].Value:='';
      end;
    end;
  end;
end;

procedure TVariables.FreeVariable(Const VariableName: String);
var
  VarNum: Integer;
begin
  If VariableName<>'' Then
  begin
    VarNum:=VariableNumByName(VariableName);
    If VarNum<> - 1 Then
    begin
      If VarNum<Length(FVariables) Then
      begin
        FVariables[VarNum].Name:='';
        FVariables[VarNum].Value:='';
      end;
    end;
  end;
end;

function TVariables.GetAllVariables: TList;
var
  vv1: Integer;
begin
  Result:=TList.Create;
  Result.Clear;
  If Length(FVariables)>0 Then
  begin
    For vv1:=0 to Length(FVariables)-1 do
      Result.Add(@FVariables[vv1]);
  end;
end;


procedure TVariables.RePlaseVariables(var VariablesSet: String; Query: TDCLDialogQuery);
Const
  MaxSysVars=49;
  SysVarsSet: Array [1..MaxSysVars] of String=('_TIME_', '_TIMES_', '_DATE_', '_DATETIME_', // 4
    '_VERSION_', '_ISEMPTY_', '_DCLTABLE_', '_DCLNAMEFIELD_', '_DCLTEXTFIELD_', '_IDENTIFYFIELD_',
    // 10
    '_PARENTFLGFIELD_', '_COMMANDFIELD_', '_USERNAME_', '_PASSWORD_', '_ALIAS_', '_STRINGTYPECHAR_',
    // 16
    '_ROLENAME_', '_ROLEID_', '_ROLESTABLE_', '_ROLESMENU_', '_USERPASS_', '_LONGROLENAME_', // 22
    '_FOB_', '_EOB_', '_VALUESEPARATOR_', '_FULLVERSION_', '_APPPATH_', '_CURRENTSTRING_', // 28
    '_ENGINETYPE_', '_SCRIPTRESULT_', '_DCL_USER_NAME_', '_DCL_USERS_TABLE_', '_USERID_', // 33
    '_USERNAMEACCESSLEVELS_', '_USERGLOBALACCESSLEVEL_', '_USERACCESSLEVEL_', '_NOTIFYACTIONS_',
    // 37
    '_YESNO_', '_EVALFORMULA_', '_DSSTATE_', '_DSSTATENAME_', '_FULLRAIGHTS_', '_ROLEACCESSLEVEL_',
    // 43
    '_APPDATAPATH_', '_OS_', '_MAC_', '_USERPROFILE_', '_USERDOC_', '_DCLINI_'); // 49
var
  ReplaseVar, TmpStr: String;
  StartSel, ParamLen, StartSearch, pv1, pv2, pv3, FindVarNum, VarNameLength, MaxMatch: Integer;
  VarExists, SysVar, FindVar: Boolean;
begin
  StartSearch:=Pos(VariablePrefix, VariablesSet);
  While Pos(VariablePrefix, Copy(VariablesSet, StartSearch, Length(VariablesSet)))<>0 do
  begin
    StartSearch:=StartSearch+Pos(VariablePrefix, Copy(VariablesSet, StartSearch,
        Length(VariablesSet)))-1;
    StartSel:=StartSearch+Length(VariablePrefix)-1;
    ParamLen:=Length(VariablesSet);
    SysVar:=False;
    If ParamLen<>0 Then
    begin
      FindVarNum:= - 1;
      MaxMatch:=0;

      pv3:=0;
      While (Length(FVariables)>pv3) do
      begin
        FindVar:=True;
        pv2:=1;
        pv1:=StartSel+1;
        While (FindVar)and(pv1<=ParamLen)and(pv2<=Length(FVariables[pv3].Name)) do
        begin
          FindVar:=False;
          If Length(FVariables[pv3].Name)>=pv2 Then
          begin
            If UpperCase(VariablesSet[pv1])=UpperCase(FVariables[pv3].Name[pv2]) Then
            begin
              FindVar:=True;
              If MaxMatch<pv1 Then
              begin
                MaxMatch:=pv1;
                FindVarNum:=pv3;
              end;
            end;
          end;
          inc(pv1);
          inc(pv2);
        end;
        inc(pv3);
      end;

      If FindVarNum= - 1 Then
      begin
        pv3:=1;
        While (MaxSysVars>=pv3) do
        begin
          FindVar:=True;
          pv2:=1;
          pv1:=StartSel+1;
          While (FindVar)and(pv1<=ParamLen)and(pv2<=Length(SysVarsSet[pv3])) do
          begin
            FindVar:=False;
            If Length(SysVarsSet[pv3])>=pv2 Then
            begin
              If UpperCase(VariablesSet[pv1])=UpperCase(SysVarsSet[pv3][pv2]) Then
              begin
                FindVar:=True;
                If MaxMatch<pv1 Then
                begin
                  MaxMatch:=pv1;
                  FindVarNum:=pv3;
                  SysVar:=True;
                end;
              end;
            end;
            inc(pv1);
            inc(pv2);
          end;
          inc(pv3);
        end;
      end;

      If FindVarNum<> - 1 Then
      begin
        VarNameLength:=MaxMatch-StartSel;
        ReplaseVar:=Copy(VariablesSet, StartSel+1, VarNameLength);
      end
      Else
      begin
        VarNameLength:=0;
        ReplaseVar:='';
      end;

      If SysVar and(FindVarNum<> - 1) Then
      begin
        Case FindVarNum of
        1:
        begin
          TmpStr:=TimeToStr_(SysUtils.Time);
          If (TmpStr[5]=':') Then
            SetLength(TmpStr, 4);
          If (TmpStr[6]=':') Then
            SetLength(TmpStr, 5);
        end;
        2:
        TmpStr:=TimeToStr_(SysUtils.Time);
        3:
        TmpStr:=DateToStr_(Date);
        4:
        TmpStr:=TimeStampToStr(Now);
        5:
        TmpStr:=Version;
        6:
        begin
          If (Query.Eof and Query.Bof) Then
            TmpStr:='1'
          Else
            TmpStr:='0';
        end;
        7:
        TmpStr:=GPT.DCLTable;
        8:
        TmpStr:=GPT.DCLNameField;
        9:
        TmpStr:=GPT.DCLTextField;
        10:
        TmpStr:=GPT.IdentifyField;
        11:
        TmpStr:=GPT.ParentFlgField;
        12:
        TmpStr:=GPT.CommandField;
        13:
        TmpStr:=GPT.DBUserName;
        14:
        TmpStr:=GPT.DBPassword;
        16:
        TmpStr:=GPT.StringTypeChar;
        17:
        TmpStr:=GPT.DCLRoleName;
        18:
        TmpStr:=GPT.RoleID;
        19:
        TmpStr:=RolesTable;
        20:
        TmpStr:=RolesMenuTable;
        21:
        TmpStr:=GPT.DCLUserPass;
        22:
        TmpStr:=GPT.LongRoleName;
        23:
        begin
          If Query.Bof Then
            TmpStr:='1'
          Else
            TmpStr:='0';
        end;
        24:
        begin
          If Query.Eof Then
            TmpStr:='1'
          Else
            TmpStr:='0';
        end;
        25:
        TmpStr:=GPT.GetValueSeparator;
        26:
        TmpStr:=Version;
        27:
        TmpStr:=ExcludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0)));
        28:
        TmpStr:=IntToStr(GPT.CurrentRunningScrString);
        29:
        TmpStr:=DBEngineType;
        30:
        TmpStr:=EvalResultScript;
        31:
        TmpStr:=GPT.DCLUserName;
        32:
        TmpStr:=UsersTable;
        33:
        TmpStr:=GPT.UserID;
        34:
        TmpStr:=GetDCLMessageString(msAccessLevelsSet);
        35:
        TmpStr:=IntToStr(Ord(FDCLLogOn.AccessLevel));
        36:
        TmpStr:=IntToStr(Ord(FDCLForm.UserLevelLocal));
        37:
        TmpStr:=GetDCLMessageString(msNotifyActionsSet);
        38:
        TmpStr:=GetDCLMessageString(msNoYes);
        39:
        TmpStr:=FDCLLogOn.EvalFormula;
        40:
        TmpStr:=IntToStr(Ord(Query.State));
        41:
        TmpStr:=GetNameDSState(Query.State);
        42:
        TmpStr:=IntToStr(FDCLLogOn.RoleRaightsLevel);
        43:
        TmpStr:=IntToStr(FDCLLogOn.GetFullRaight);
        44:
        TmpStr:=ExcludeTrailingPathDelimiter(AppConfigDir);
        45:
        TmpStr:=OSType;
        46:
        TmpStr:=GetMACAddress;
        47:
        TmpStr:=UserProfileDir; // '_USERPROFILE_'
        48:
        TmpStr:=GetUserDocumentsDir; // '_USERDOC_'
        49:
        TmpStr:=GPT.IniFileName; // _DCLINI_
        end;
      end;

      VarExists:=Exists(ReplaseVar);
      If SysVar Then
        VarExists:=True;

      If VarExists Then
      begin
        Delete(VariablesSet, StartSel, VarNameLength+Length(VariablePrefix));
        If Not SysVar Then
          TmpStr:=Variables[ReplaseVar];
        Insert(TmpStr, VariablesSet, StartSel);
        inc(StartSearch, Length(TmpStr)+Length(VariablePrefix));
        TmpStr:='';
      end
      Else
        inc(StartSearch, Length(VariablePrefix)+1);
    end;
  end;
end;

{ TLogOnForm }

procedure TLogOnForm.CancelButtonClick(Sender: TObject);
begin
  FDCLLogOn.RoleOK:=lsRejected;
  PressOK:=psCanceled;
  RoleForm.Close;
end;

procedure TLogOnForm.CancelChangePass(Sender: TObject);
begin
  ChangePassForm.Close;
end;

procedure TLogOnForm.ChangePass(Sender: TObject);
begin
  If Assigned(RoleNameCombo) Then
    GPT.DCLUserName:=RoleNameCombo.Text
  Else If Assigned(RoleNameEdit) Then
    GPT.DCLUserName:=RoleNameEdit.Text;

  If GPT.DCLUserName<>'' Then
  begin
    FDCLLogOn.GetUserName(GPT.DCLUserName);
    ShowChangePasswordForm;
  end
  Else
    ShowErrorMessage(0, GetDCLMessageString(msEmptyUserName));
end;

procedure TLogOnForm.ChangePassword(AUserID, NewPassword: String);
begin
  RolesQuery1.Close;
  If Not HashPass Then
    RolesQuery1.SQL.Text:='update '+UsersTable+' set '+UserPassField+'='+GPT.StringTypeChar+
      NewPassword+GPT.StringTypeChar+' where '+UserIDField+'='+AUserID
  Else
    RolesQuery1.SQL.Text:='update '+UsersTable+' set '+UserPassField+'='+GPT.StringTypeChar+
      HashString(NewPassword)+GPT.StringTypeChar+' where '+UserIDField+'='+AUserID;

  try
    RolesQuery1.ExecSQL;
  Except
    //
  end;
end;

destructor TLogOnForm.Destroy;
begin
  If Assigned(RoleNameCombo) Then
    FreeAndNil(RoleNameCombo);
  If Assigned(RoleNameEdit) Then
    FreeAndNil(RoleNameEdit);
  If Assigned(RolePassEdit) Then
    FreeAndNil(RolePassEdit);

  If Assigned(RoleForm) Then
    RoleForm.Release;
end;

constructor TLogOnForm.Create(var DCLLogOn: TDCLLogOn; UserName: String; NoClose, Relogin: Boolean);
begin
  FormCreated:=False;
  FUserName:=UserName;
  NoShowRoleField:=False;
  PressOK:=psNone;
  FDCLLogOn:=DCLLogOn;
  If ConnectErrorCode=0 Then
  begin
    RolesQuery1:=TDCLDialogQuery.Create(nil);
    RolesQuery1.Name:='Roles1_'+IntToStr(UpTime);
    FDCLLogOn.SetDBName(RolesQuery1);

    RolesQuery1.SQL.Text:='select count(*) from '+UsersTable+' where '+GPT.ShowRoleField+'=1';
    try
      RolesQuery1.Open;
      CountShowRole:=RolesQuery1.Fields[0].AsInteger;
    Except
      CountShowRole:=0;
      NoShowRoleField:=True;
    end;

    If (GPT.ShowRoleField<>'')and((UserName='')or Relogin) Then
    begin
      If NoShowRoleField Then
      begin
        RolesQuery1.SQL.Text:='select count(*) from '+UsersTable;
        try
          RolesQuery1.Open;
          CountShowRole:=RolesQuery1.Fields[0].AsInteger;
        Except
          CountShowRole:=0;
          ShowErrorMessage( - 5008, '');
          FDCLLogOn.RoleOK:=lsRejected;
        end;
      end;

      If ConnectErrorCode=0 Then
        CreateForm(NoClose, Relogin, UserName);
    end;
  end
  Else
    FDCLLogOn.RoleOK:=lsRejected;
end;

procedure TLogOnForm.CreateForm(NoClose, Relogin: Boolean; UserName: String);
begin
  FormCreated:=True;
  DebugProc('Create LogOn Form');
  Application.Title:='DCLRun '+GetDCLMessageString(msLogonToSystem);
  RoleForm:=TForm.Create(nil);
  RoleForm.Caption:=GetDCLMessageString(msLogonToSystem);
  RoleForm.BorderStyle:=bsDialog;

  RoleForm.OnShow:=OnShowForm;
  RoleForm.OnClose:=OnCloseForm;
  If NoClose Then
    RoleForm.OnCloseQuery:=OnCloseQuery;
  RoleForm.Position:=poScreenCenter;
  DebugProc('   ... OK');

  Panel:=TPanel.Create(RoleForm);
  Panel.Parent:=RoleForm;
  Panel.Left:=LogOnFormControlsLeft+15;
  Panel.Top:=3;
  Panel.Width:=EditWidth+BeginStepLeft*2;
  Panel.Height:=(BeginStepTop*2)+(EditTopStep*1)+BevelWidth;
  Panel.BevelInner:=bvLowered;

  DCLLogo:=TImage.Create(RoleForm);
  DCLLogo.Parent:=RoleForm;
  DCLLogo.Left:=5;
  DCLLogo.Top:=17;
  DCLLogo.Picture.Bitmap:=DrawBMPButton('Logo');
  DCLLogo.Width:=65;
  DCLLogo.Height:=65;
  DCLLogo.Transparent:=True;
  DCLLogo.Stretch:=True;
  DCLLogo.Proportional:=True;

  If (CountShowRole>1)and( { (UserName='') or } Not Relogin) Then
  begin
    If (ConnectErrorCode=0)and Not FormCreated Then
      CreateForm(NoClose, Relogin, UserName);

    If NoShowRoleField Then
      RolesQuery1.SQL.Text:='select '+UserNameField+' from '+UsersTable
    Else
      RolesQuery1.SQL.Text:='select '+UserNameField+' from '+UsersTable+' where '+
        GPT.ShowRoleField+'=1';

    RolesQuery1.Open;
    RoleNameCombo:=TComboBox.Create(Panel);
    RoleNameCombo.Parent:=Panel;

    While Not RolesQuery1.Eof do
    begin
      RoleNameCombo.Items.Append(RolesQuery1.Fields[0].AsString);
      RolesQuery1.Next;
    end;
    RolesQuery1.Close;
    RoleNameCombo.Text:=AnsiUpperCase(GPT.DCLUserName);
    RoleNameCombo.Top:=BeginStepTop;
    RoleNameCombo.Left:=BeginStepLeft;
    RoleNameCombo.Width:=EditWidth;
  end
  Else
  begin
    RoleNameEdit:=TEdit.Create(Panel);
    RoleNameEdit.Parent:=Panel;
    RoleNameEdit.Text:=AnsiUpperCase(GPT.DCLUserName);
    RoleNameEdit.Top:=BeginStepTop;
    RoleNameEdit.Left:=BeginStepLeft;
    RoleNameEdit.Width:=EditWidth;
    If (UserName<>'')and Not Relogin Then
      RoleNameEdit.ReadOnly:=True;
  end;

  RoleLabel:=TDialogLabel.Create(Panel);
  RoleLabel.Parent:=Panel;
  RoleLabel.Left:=BeginStepLeft;
  RoleLabel.Top:=BeginStepTop-15;
  RoleLabel.Caption:=GetDCLMessageString(msUserName);

  RolePassEdit:=TEdit.Create(Panel);
  RolePassEdit.Parent:=Panel;
  RolePassEdit.PasswordChar:='#';

  RoleLabel:=TDialogLabel.Create(Panel);
  RoleLabel.Parent:=Panel;
  RoleLabel.Left:=BeginStepLeft;
  RoleLabel.Top:=BeginStepTop+EditTopStep-15;
  RoleLabel.Caption:=GetDCLMessageString(msPassword);

  RoleButtonOK:=TDialogButton.Create(RoleForm);
  RoleButtonOK.Parent:=RoleForm;
  RoleButtonOK.Default:=True;
  RoleButtonOK.Caption:=GetDCLMessageString(msApplay);
  RoleButtonOK.Width:=LoginButtonWidth;
  RoleButtonOK.Height:=ButtonHeight;
  RoleButtonOK.OnClick:=OkButtonClick;

  RoleButtonCancel:=TDialogButton.Create(RoleForm);
  RoleButtonCancel.Parent:=RoleForm;
  RoleButtonCancel.Cancel:=True;
  RoleButtonCancel.Caption:=GetDCLMessageString(msClose);
  RoleButtonCancel.Width:=LoginButtonWidth;
  RoleButtonCancel.Height:=ButtonHeight;
  If Not NoClose Then
    RoleButtonCancel.OnClick:=CancelButtonClick;

  ChangePassButton:=TDialogButton.Create(RoleForm);
  ChangePassButton.Parent:=RoleForm;
  ChangePassButton.Caption:=GetDCLMessageString(msEdit);
  ChangePassButton.Hint:=GetDCLMessageString(msEditPassword);
  ChangePassButton.ShowHint:=True;
  ChangePassButton.Width:=LoginButtonWidth;
  ChangePassButton.Height:=ButtonHeight;
  ChangePassButton.OnClick:=ChangePass;

  RolePassEdit.Top:=BeginStepTop+EditTopStep;
  RolePassEdit.Left:=BeginStepLeft;
  RolePassEdit.Width:=EditWidth;

  RoleButtonOK.Top:=(BeginStepTop*2)+(EditTopStep*1)+BevelWidth*3;
  RoleButtonOK.Left:=BeginStepLeft+LogOnFormControlsLeft;

  RoleButtonCancel.Top:=(BeginStepTop*2)+(EditTopStep*1)+BevelWidth*3;
  RoleButtonCancel.Left:=BeginStepLeft+ButtonsInterval+LoginButtonWidth+LogOnFormControlsLeft;

  ChangePassButton.Top:=(BeginStepTop*2)+(EditTopStep*1)+BevelWidth*3;
  ChangePassButton.Left:=BeginStepLeft+(ButtonsInterval*2+LoginButtonWidth*2)+LogOnFormControlsLeft;

  RoleForm.ClientHeight:=(BeginStepTop*2)+(EditTopStep*2)+BevelWidth;
  RoleForm.ClientWidth:=LogOnFormControlsLeft+15+EditWidth+BeginStepLeft*3;
end;

procedure TLogOnForm.OkButtonClick(Sender: TObject);
begin
  PressOK:=psConfirmed;
  RoleForm.OnCloseQuery:=nil;
  FEnterPassword:=RolePassEdit.Text;
  RoleForm.Close;
end;

procedure TLogOnForm.OkChangePass(Sender: TObject);
begin
  GPT.EnterPass:=OldPassEdit.Text;
  // GetUserName(GPT.DCLUserName);
  If GPT.DCLUserPass=GPT.EnterPass Then
  begin
    ChangePassword(GPT.UserID, NewPassEdit1.Text);
    ChangePassForm.Close;
    RolePassEdit.SetFocus;
  end;
end;

procedure TLogOnForm.OnCloseForm(Sender: TObject; var Action: TCloseAction);
begin
  If PressOK<>psConfirmed Then
  begin
    FDCLLogOn.RoleOK:=lsRejected;
    PressOK:=psCanceled;
  end;
  If Assigned(RolePassEdit) Then
    FEnterPassword:=RolePassEdit.Text;
  If Assigned(RoleNameCombo) Then
    FUserName:=RoleNameCombo.Text
  Else If Assigned(RoleNameEdit) Then
    FUserName:=RoleNameEdit.Text;
end;

procedure TLogOnForm.OnCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose:=False;
end;

procedure TLogOnForm.OnSetHashPassword(Sender: TObject);
begin
  HashPass:=(Sender as TCheckbox).Checked;
end;

procedure TLogOnForm.OnShowForm(Sender: TObject);
begin
  RolePassEdit.SetFocus;
end;

procedure TLogOnForm.ShowChangePasswordForm;
begin
  ChangePassForm:=TForm.Create(nil);
  ChangePassForm.Name:='ChangePassForm';
  ChangePassForm.FormStyle:=fsStayOnTop;
  ChangePassForm.BorderStyle:=bsSingle;
  ChangePassForm.BorderIcons:=[biSystemMenu];
  ChangePassForm.Caption:=GetDCLMessageString(msChangePassord);
  ChangePassForm.ClientWidth:=(BeginStepLeft*3)+EditWidth;
  ChangePassForm.ClientHeight:=(BeginStepTop*2)+EditTopStep*5-FilterLabelTop*2;
  ChangePassForm.Position:=poScreenCenter;

  OldPassEdit:=TEdit.Create(ChangePassForm);
  OldPassEdit.Parent:=ChangePassForm;
  OldPassEdit.Name:='OldPassEdit';
  OldPassEdit.PasswordChar:=MaskPassChar;
  OldPassEdit.Left:=BeginStepLeft;
  OldPassEdit.Width:=EditWidth;
  OldPassEdit.Top:=BeginStepTop;
  OldPassEdit.Clear;

  NewPassEdit1:=TEdit.Create(ChangePassForm);
  NewPassEdit1.Parent:=ChangePassForm;
  NewPassEdit1.Name:='NewPassEdit1';
  NewPassEdit1.PasswordChar:=MaskPassChar;
  NewPassEdit1.Left:=BeginStepLeft;
  NewPassEdit1.Width:=EditWidth;
  NewPassEdit1.Top:=BeginStepTop+EditTopStep;
  NewPassEdit1.Clear;

  NewPassEdit2:=TEdit.Create(ChangePassForm);
  NewPassEdit2.Parent:=ChangePassForm;
  NewPassEdit2.Name:='NewPassEdit2';
  NewPassEdit2.PasswordChar:=MaskPassChar;
  NewPassEdit2.Left:=BeginStepLeft;
  NewPassEdit2.Width:=EditWidth;
  NewPassEdit2.Top:=BeginStepTop+EditTopStep*2;
  NewPassEdit2.Clear;

  OkButton:=TDialogButton.Create(ChangePassForm);
  OkButton.Parent:=ChangePassForm;
  OkButton.Name:='OkButton';
  OkButton.OnClick:=OkChangePass;
  OkButton.Caption:=GetDCLMessageString(msEdit);
  OkButton.Default:=True;
  OkButton.Top:=BeginStepTop+EditTopStep*4-FilterLabelTop*2;
  OkButton.Left:=BeginStepLeft;

  CancelButton:=TDialogButton.Create(ChangePassForm);
  CancelButton.Parent:=ChangePassForm;
  CancelButton.Name:='CancelButton';
  CancelButton.OnClick:=CancelChangePass;
  CancelButton.Caption:=GetDCLMessageString(msCancel);;
  CancelButton.Cancel:=True;
  CancelButton.Top:=BeginStepTop+EditTopStep*4-FilterLabelTop*2;
  CancelButton.Left:=BeginStepLeft+ButtonsInterval+ButtonWidth;

  LabelPass:=TDialogLabel.Create(ChangePassForm);
  LabelPass.Parent:=ChangePassForm;
  LabelPass.Caption:=GetDCLMessageString(msOldPassword)+':';
  LabelPass.Top:=BeginStepTop-FilterLabelTop*2;
  LabelPass.Left:=BeginStepLeft;

  LabelPass:=TDialogLabel.Create(ChangePassForm);
  LabelPass.Parent:=ChangePassForm;
  LabelPass.Caption:=GetDCLMessageString(msNewPassword)+':';
  LabelPass.Top:=BeginStepTop+EditTopStep-FilterLabelTop*2;
  LabelPass.Left:=BeginStepLeft;

  LabelPass:=TDialogLabel.Create(ChangePassForm);
  LabelPass.Parent:=ChangePassForm;
  LabelPass.Caption:=GetDCLMessageString(msConfirm)+':';
  LabelPass.Top:=(BeginStepTop+EditTopStep*2)-FilterLabelTop*2;
  LabelPass.Left:=BeginStepLeft;

  HashPassChk:=TCheckbox.Create(ChangePassForm);
  HashPassChk.Parent:=ChangePassForm;
  HashPassChk.Caption:=GetDCLMessageString(msHashPassword);
  {HashPassChk.Hint:=GetDCLMessageString(msToHashing)+' '+
      GetDCLMessageString(msPassword);}
  HashPassChk.Top:=(BeginStepTop+EditTopStep*3)-FilterLabelTop;
  HashPassChk.Left:=BeginStepLeft;
  HashPassChk.Width:=200;
  HashPassChk.Checked:=GPT.HashPass;
  HashPassChk.Enabled:=Not GPT.HashPass;
  HashPassChk.OnClick:=OnSetHashPassword;

  ChangePassForm.ShowModal;
end;

procedure TLogOnForm.ShowForm;
begin
  If Not Assigned(RoleForm) Then
    CreateForm(False, False, GPT.DCLUserName);
  RoleForm.ShowModal;
end;

{ TDCLForm }

procedure TDCLForm.ActivateForm(Sender: TObject);
begin
  FDCLLogOn.CurrentForm:=FFormNum;
  If ShowFormPanel Then
    If Assigned(FDCLLogOn.FDCLMainMenu) Then
      FDCLLogOn.FDCLMainMenu.UpdateFormBar;

  If Assigned(Tables[ - 1]) Then
    If Assigned(Tables[ - 1].Query) then
      If Tables[ - 1].Query.Active Then
        Tables[ - 1].ScrollDB(Tables[ - 1].Query);
end;

procedure TDCLForm.AddEvents(var Events: TEventsArray; EventsSet: String);
var
  v1, v2: Word;
  tmp1: String;
begin
  For v1:=1 to ParamsCount(EventsSet) do
  begin
    tmp1:=Trim(SortParams(EventsSet, v1));
    If tmp1<>'' Then
    begin
      v2:=Length(Events);
      SetLength(Events, v2+1);
      Events[v2]:=tmp1;
    end;
  end;
end;

function TDCLForm.AddGrid(Parent: TWinControl; SurfType: TDataControlType; Query: TDCLDialogQuery;
  Data: TDataSource): Integer;
var
  v1: Integer;
begin
  v1:=Length(FGrids);
  SetLength(FGrids, v1+1);
  FGrids[v1]:=TDCLGrid.Create(Self, Parent, SurfType, Query, Data);
  FGrids[v1].Tag:=v1;
  FGrids[v1].QueryName:='Grid_'+IntToStr(v1);
  Result:=v1;
end;

procedure TDCLGrid.AddNotAllowedOperation(Operation: TNotAllowedOperations);
var
  i, l: Byte;
begin
  l:=Length(NotAllowedOperations);
  For i:=1 to l do
  begin
    If NotAllowedOperations[i-1]=Operation Then
      Exit;
  end;

  SetLength(NotAllowedOperations, l+1);
  NotAllowedOperations[l]:=Operation;
end;

procedure TDCLForm.AddMainPage(Query: TDCLDialogQuery; Data: TDataSource);
var
  Pc: Integer;
  ButtonParams: RButtonParams;
begin
  FNewPage:=True;

  If Not Assigned(FPages) Then
  begin
    FPages:=TPageControl.Create(MainPanel);
    FPages.Parent:=MainPanel;
    FPages.Name:='Pages_'+FForm.Name;
    FPages.Align:=alClient;
    FPages.OnChange:=ChangeTabPage;
{$IFNDEF FPC}
    FPages.TabHeight:=1;
    FPages.TabWidth:=1;
{$ELSE}
    FPages.ShowTabs:=False;
{$ENDIF}
  end
  Else
  begin
{$IFNDEF FPC}
    FPages.TabHeight:=0;
    FPages.TabWidth:=0;
{$ELSE}
    FPages.ShowTabs:=True;
{$ENDIF}
  end;

  Pc:=FPages.PageCount;
  FTabs:=TTabSheet.Create(FPages);
  FTabs.Caption:=GetDCLMessageString(msPage)+' '+IntToStr(Pc+1);
  FTabs.Name:='Page_'+IntToStr(Pc+1);
  FTabs.PageControl:=FPages;

  ParentPanel:=FTabs.PageControl.Pages[FPages.PageCount-1];

  GridIndex:=AddGrid(ParentPanel, dctMainGrid, Query, Data);

  FPages.ActivePage:=FPages.Pages[FPages.PageCount-1];
  FPages.ActivePageIndex:=FPages.PageCount-1;

  FTabs.PageControl.Pages[FPages.PageCount-1].Tag:=GridIndex;
  CurrentGridIndex:=GridIndex;
  QueryGlobIndex:=GridIndex;
  DataGlob:=FGrids[GridIndex].DataSource;
  FGrids[GridIndex].TabType:=ptMainPage;
  GridPanel:=FGrids[GridIndex].FGridPanel;

  FGrids[GridIndex].ToolButtonsCount:=0;
  FGrids[GridIndex].ToolButtonPanel:=TToolBarPanel.Create(FGrids[GridIndex].FGridPanel);
  FGrids[GridIndex].ToolButtonPanel.Parent:=FGrids[GridIndex].FGridPanel;
{$IFNDEF FPC}
  FGrids[GridIndex].ToolButtonPanel.DrawingStyle:=dsGradient;
{$ENDIF}
  FGrids[GridIndex].ToolButtonPanel.EdgeBorders:=[ebLeft, ebTop, ebRight, ebBottom];
  FGrids[GridIndex].ToolButtonPanel.Height:=ToolButtonPanelHeight;
  FGrids[GridIndex].ToolButtonPanel.ButtonHeight:=ToolButtonHeight;
  FGrids[GridIndex].ToolButtonPanel.Align:=alTop;

  ButtonLeft:=BeginStepLeft;
  ButtonTop:=ButtonsTop;
  If Not NoStdKeys Then
  begin
    IncButtonPanelHeight:=ButtonPanelHeight;
    FGrids[GridIndex].ButtonPanel:=TDialogPanel.Create(FGrids[GridIndex].FGridPanel);
    FGrids[GridIndex].ButtonPanel.Parent:=FGrids[GridIndex].FGridPanel;
    FGrids[GridIndex].ButtonPanel.Top:=30; // FForm.ClientHeight-2;
    FGrids[GridIndex].ButtonPanel.Height:=ButtonPanelHeight;
    FGrids[GridIndex].ButtonPanel.Align:=alBottom;

    ResetButtonParams(ButtonParams);
    ButtonParams.Caption:=GetDCLMessageString(msClose);
    ButtonParams.Command:='Close';
    ButtonParams.Pict:='esc';
    ButtonParams.Top:=ButtonTop;
    ButtonParams.Left:=ButtonLeft;
    ButtonParams.Width:=ButtonWidth;
    ButtonParams.Height:=ButtonHeight;
    ButtonParams.Cancel:=True;
    ButtonParams.Default:=False;

    Commands.AddCommand(FGrids[GridIndex].ButtonPanel, ButtonParams);
    inc(ButtonLeft, ButtonWidth+ButtonsInterval);

    If FReturningMode<>chmNone Then
    begin
      ResetButtonParams(ButtonParams);
      ButtonParams.Caption:=GetDCLMessageString(msChoose);
      Case FReturningMode of
      chmChoose:
      ButtonParams.Command:='Choose';
      chmChooseAndClose:
      ButtonParams.Command:='ChooseAndClose';
      end;
      ButtonParams.Pict:='Choose';
      ButtonParams.Top:=ButtonTop;
      ButtonParams.Left:=ButtonLeft;
      ButtonParams.Width:=ButtonWidth;
      ButtonParams.Height:=ButtonHeight;
      ButtonParams.Default:=True;

      Commands.AddCommand(FGrids[GridIndex].ButtonPanel, ButtonParams);
      inc(ButtonLeft, ButtonWidth+ButtonsInterval);
    end;
    // If CachedUpdates Then
    { If Not AutoApply Then
      Begin
      ResetButtonParams(ButtonParams);
      ButtonParams.Caption:=GetDCLMessageString();
      ButtonParams.Command:='SaveDB';
      ButtonParams.Pict:='save';
      ButtonParams.Top:=ButtonTop;
      ButtonParams.Left:=ButtonLeft;
      ButtonParams.Width:=ButtonWidth;
      ButtonParams.Height:=ButtonHeight;

      Commands.AddCommand(FGrids[GridIndex].ButtonPanel, ButtonParams);
      Inc(ButtonLeft, ButtonWidth+ButtonsInterval);
      End; }
  end;
end;

procedure TDCLForm.AddStatus(StatusStr: String; Width: Integer);
begin
  DBStatus.Panels.Insert(DBStatus.Panels.Count);
  DBStatus.Panels[DBStatus.Panels.Count-1].Width:=Width;
  DBStatus.Panels[DBStatus.Panels.Count-1].Text:=StatusStr;
end;

procedure TDCLForm.ChangeTabPage(Sender: TObject);
begin
  CurrentGridIndex:=(Sender as TPageControl).ActivePageIndex;
  QueryGlobIndex:=CurrentGridIndex;
  If Length(FGrids)>CurrentGridIndex then
  Begin
    DataGlob:=FGrids[CurrentGridIndex].DataSource;
    If Assigned(FGrids[CurrentGridIndex].FTablePartsPages) Then
      FGrids[CurrentGridIndex].ChangeTabPage(FGrids[CurrentGridIndex].FTablePartsPages);
  End;
end;

destructor TDCLForm.Destroy;
var
  i, j: Word;
  TB1: TFormPanelButton;
begin
  FDCLLogOn.IsBusy:=True;
  CloseAction:=fcaInProcess;
  FDCLLogOn.FForms.Remove(Self);

  FForm.OnResize:=nil;
  FForm.OnActivate:=nil;
  FForm.OnCloseQuery:=nil;

  If ExitCode=0 Then
  begin
    SaveFormPos;
    SaveBookMarkMenu;
  end;

  If Assigned(DBStatus) Then
    FreeAndNil(DBStatus);

  If ExitCode=0 Then
    For i:=1 to Length(EventsClose) do
      ExecCommand(EventsClose[i-1]);

  For i:=Length(FGrids) downto 1 do
  begin
    For j:=Length(FGrids[i-1].FTableParts) downto 1 do
    begin
      FreeAndNil(FGrids[i-1].FTableParts[j-1]);
    end;

    FreeAndNil(FGrids[i-1]);
  end;
  If Assigned(FPages) then
    FreeAndNil(FPages);

  If ShowFormPanel Then
  begin
    If Assigned(FDCLLogOn.FDCLMainMenu) Then
      If Assigned(FDCLLogOn.FDCLMainMenu.FormBar) Then
      begin
        TB1:=(FDCLLogOn.FDCLMainMenu.FormBar.FindComponent('TB'+IntToStr(FForm.Handle))
            as TFormPanelButton);
        If Assigned(TB1) then
          FreeAndNil(TB1);
      end;
  end;

  For i:=1 to FDCLLogOn.FormsCount do
  begin
    If Assigned(FDCLLogOn.Forms[i-1]) Then
      If Self=FDCLLogOn.Forms[i-1].FParentForm Then
        FDCLLogOn.CloseForm(FDCLLogOn.Forms[i-1]);
  end;

  Pointer(FParentForm):=nil;
  Pointer(FCallerForm):=nil;
  FForm.Release;
  //inherited Destroy;
end;

procedure TDCLForm.CloseForm(Sender: TObject; var Action: TCloseAction);
var
  I:Integer;
begin
  for I:=1 to Length(EventsClose) do
  begin
    ExecCommand(EventsClose[I-1]);
  end;
  FDCLLogOn.KillerDog.Enabled:=True;
  If FormCanClose then
    If Not NotDestroyedDCLForm Then
      CloseAction:=fcaClose;
end;

procedure TDCLForm.ExecCommand(CommandName: String);
var
  DCLCommand: TDCLCommand;
begin
  DCLCommand:=TDCLCommand.Create(Self, FDCLLogOn);
  Try
    DCLCommand.ExecCommand(CommandName, Self);
  Finally
    FreeAndNil(DCLCommand);
  End;
end;

function TDCLForm.GetQueryToRaights(S: String): String;
var
  RaightsStr, SQLStr: String;
  DCLQuery: TDCLDialogQuery;
  Factor:Word;
begin
  Result:=S;
  DCLQuery:=TDCLDialogQuery.Create(nil);
  FDCLLogOn.SetDBName(DCLQuery);
  RaightsStr:=FindParam('UserRaights=', S);
  RePlaseVariables(RaightsStr);
  FDCLLogOn.RePlaseVariables(RaightsStr);
  Factor:=0;
  TranslateProc(RaightsStr, Factor, nil);

  If (GPT.DCLUserName<>'')and(RaightsStr<>'')and(GPT.UserID<>'') Then
  begin
    SQLStr:='select count(*) from '+UsersTable+' u where u.'+UserIDField+' '+RaightsStr+' and u.'+
      UserIDField+'='+GPT.UserID;
    DCLQuery.SQL.Text:=SQLStr;
    try
      DCLQuery.Open;
    Except
      ShowErrorMessage( - 9000, 'SQL='+SQLStr);
    end;
    If DCLQuery.Fields[0].AsInteger<>0 Then
      Result:=S
    Else
      Result:='';
  end
  Else
    Result:=S;

  DCLQuery.Close;
  FreeAndNil(DCLQuery);
end;

procedure TDCLForm.LoadFormPos;
begin
  SettingsLoaded:=True;
  Case GPT.FormPosInDB of
  isDisk:
  LoadFormPosINI;
  isBase:
  LoadFormPosBase;
  isDiskAndBase:
  begin
    LoadFormPosINI;
    LoadFormPosBase;
  end;
  end;
end;

procedure TDCLForm.LoadFormPosINI;
var
  FileParams, DialogsParams: TStringList;
  appName:String;
begin
  If DialogName<>'' Then
    If GPT.DialogsSettings Then
    begin
      If FileExists(IncludeTrailingPathDelimiter(AppConfigDir)+'Dialogs.ini') Then
      begin
        FileParams:=TStringList.Create;
        FileParams.LoadFromFile(IncludeTrailingPathDelimiter(AppConfigDir)+'Dialogs.ini'{$IFNDEF FPC}, TEncoding.UTF8{$ENDIF});
        appName:='BaseUID:'+InternalAppName+FDCLLogOn.GetBaseUID+'/';
        DialogsParams:=CopyStrings(appName+'['+DialogName+']', appName+'[END '+DialogName+']', FileParams);
        LoadFormPosUni(DialogsParams);
        FreeAndNil(FileParams);
        FreeAndNil(DialogsParams);
      end;
    end;
end;

procedure TDCLForm.LoadFormPosBase;
begin
  LoadFormPosUni(ReadBaseINI(itFormPos));
end;

procedure TDCLForm.LoadFormPosUni(DialogParams: TStringList);
var
  ParamsCounter, FieldsCount, i, w: Word;
  g, T: Integer;
  Grid: TDCLGrid;
  S: String;
  DCLF: TDCLDataFields;
  F: RField;

  function FindDCLField(FieldName: String): TDCLDataFields;
  var
    i: Integer;
  begin
    ResetDCLField(Result);
    For i:=1 to Length(Grid.DataFields) do
    begin
      If CompareString(Grid.DataFields[i-1].Name, FieldName) Then
      begin
        Result:=Grid.DataFields[i-1];
        break;
      end;
    end;
  end;

begin
  If DialogName<>'' Then
    If GPT.DialogsSettings Then
    begin
      If DialogParams.Count>0 Then
      begin
        g:= - 1;
        T:= - 1;
        ParamsCounter:=0;

        If DialogParams.Count>0 Then
          While (ParamsCounter<DialogParams.Count) do
          begin
            S:=Trim(DialogParams[ParamsCounter]);
            If PosEx('FormTop=', S)=1 Then
              Form.Top:=StrToInt(FindParam('FormTop=', S));
            If PosEx('FormLeft=', S)=1 Then
              Form.Left:=StrToInt(FindParam('FormLeft=', S));
            If PosEx('FormHeight=', S)=1 Then
              Form.Height:=StrToInt(FindParam('FormHeight=', S));
            If PosEx('FormWidth=', S)=1 Then
              Form.Width:=StrToInt(FindParam('FormWidth=', S));

            If PosEx('[Page]', S)=1 Then
            begin
              T:= - 1;
              inc(g);
              If g> - 1 Then
                Grid:=Tables[g];
            end;

            If PosEx('[TablePart]', S)=1 Then
            begin
              inc(T);
              If T> - 1 Then
                If Assigned(FGrids) then
                  If TablesCount>g then
                    Grid:=Tables[g].TableParts[T];
            end;

            If PosEx('SplitterPos=', S)=1 Then
              If Assigned(Grid) Then
                If Assigned(Grid.PartSplitter) Then
                  Grid.FTablePartsPages.Height:=StrToInt(FindParam('SplitterPos=', S));

            If Not GPT.DisableFieldsList Then
              If PosEx('[Fields]', S)=1 Then
                If Assigned(Grid) Then
                  If Grid.DisplayMode in TDataGrid Then
                  begin
                    FieldsCount:=StrToIntEx(Trim(DialogParams[ParamsCounter+1]));
                    Grid.FGrid.Columns.Clear;

                    i:=ParamsCounter+2;
                    While (DialogParams.Count-1>i)and(FieldsCount<>0) do
                    begin
                      S:=Trim(DialogParams[i+1]);
                      w:=DefaultColumnSize;
                      If Pos(';', S)<>0 Then
                      begin
                        S:=Copy(S, 1, Pos(';', S)-1);
                        w:=StrToIntEx(FindParam('Width=', DialogParams[i+1]));
                      end;
                      DCLF:=FindDCLField(S);
                      DCLF.Width:=w;
                      DCLF.Name:=S;

                      DCLF.Caption:=Trim(DialogParams[i]);

                      F.Width:=DCLF.Width;
                      F.Caption:=DCLF.Caption;
                      F.FieldName:=DCLF.Name;
                      F.ReadOnly:=DCLF.ReadOnly;

                      Grid.AddColumn(F);
                      inc(i, 2);
                      Dec(FieldsCount);
                    end;
                    ParamsCounter:=i-1;
                  end;

            inc(ParamsCounter);
          end;
      end;
    end;
end;

procedure TDCLForm.OnCloseQuery(Sender: TObject; var CanClose: Boolean);
var
  S:String;
  DlgRes:Integer;
begin
  If NoCloseable then
  Begin
    CanClose:=not NoCloseable;
    FormCanClose:=CanClose;
    {$IFDEF MSWINDOWS}
      Beep(500, 500);
    {$ELSE}
      Beep;
    {$ENDIF}
    Exit;
  End;

  If CloseQuery then
  Begin
    S:=CloseQueryText;
    if S='' then
      S:=GetDCLMessageString(msClose);
    DlgRes:=ShowErrorMessage(10, S);
    CanClose:=DlgRes=1;
    FormCanClose:=CanClose;
  End;
end;

procedure TDCLForm.SaveFormPos;
begin
  Case GPT.FormPosInDB of
  isDisk:
  SaveFormPosINI;
  isBase:
  SaveFormPosBase;
  isDiskAndBase:
  begin
    SaveFormPosINI;
    SaveFormPosBase;
  end;
  end;
end;

procedure TDCLForm.SaveFormPosINI;
var
  FileParams, DialogsParams: TStringList;
  p1, p2, i, j: Integer;
  appName:String;
  fndFlg:Boolean;
begin
  p1:= - 1;
  p2:= - 1;
  fndFlg:=False;
  FileParams:=TStringList.Create;
  If DialogName<>'' Then
    If FileExists(IncludeTrailingPathDelimiter(AppConfigDir)+'Dialogs.ini') Then
    begin
      FileParams.LoadFromFile(IncludeTrailingPathDelimiter(AppConfigDir)+'Dialogs.ini'{$IFNDEF FPC}, TEncoding.UTF8{$ENDIF});
      appName:='BaseUID:'+InternalAppName+FDCLLogOn.GetBaseUID+'/';
      For i:=1 to FileParams.Count do
      begin
        If PosEx(appName+'['+DialogName+']', FileParams[i-1])=1 Then
        begin
          p1:=i-1;
          For j:=p1 to FileParams.Count-1 do
          begin
            If PosEx(appName+'[END '+DialogName+']', FileParams[j])=1 Then
            begin
              p2:=j;
              fndFlg:=True;
              break;
            end;
          end;
        end;
        if fndFlg then
          break;
      end;
    end;

  DialogsParams:=SaveFormPosUni;
  If (p1<p2)and(p1> - 1) Then
  begin
    For i:=0 to p2-p1 do
      FileParams.Delete(p1);
  end;
  FileParams.AddStrings(DialogsParams);
  FileParams.SaveToFile(IncludeTrailingPathDelimiter(AppConfigDir)+'Dialogs.ini'{$IFNDEF FPC}, TEncoding.UTF8{$ENDIF});
end;

procedure TDCLForm.SaveFormPosBase;
var
  DialogSettings: TStringList;
begin
  DialogSettings:=TStringList.Create;
  DialogSettings:=SaveFormPosUni;
  If DialogSettings.Count>0 then
    WriteBaseINI(itFormPos, SaveFormPosUni);
  FreeAndNil(DialogSettings);
end;

function TDCLForm.SaveFormPosUni: TStringList;
var
  i, j, T: Word;
  appName:String;
begin
  Result:=TStringList.Create;
  appName:='BaseUID:'+InternalAppName+FDCLLogOn.GetBaseUID+'/';
  If Not FieldsSettingsReseted Then
    If DialogName<>'' Then
    begin
      Result.Append(appName+'['+DialogName+']');
      Result.Append('FormTop='+IntToStr(Form.Top));
      Result.Append('FormLeft='+IntToStr(Form.Left));
      Result.Append('FormHeight='+IntToStr(Form.Height));
      Result.Append('FormWidth='+IntToStr(Form.Width));

      For i:=1 to Length(FGrids) do
      begin
        Result.Append('[Page]');
        If Assigned(FGrids[i-1].PartSplitter) Then
          Result.Append('SplitterPos='+IntToStr(FGrids[i-1].FTablePartsPages.Height));
        If FGrids[i-1].DisplayMode in TDataGrid Then
        begin
          Result.Append('[Fields]');
          Result.Append(IntToStr(FGrids[i-1].FGrid.Columns.Count));
          For j:=1 to FGrids[i-1].FGrid.Columns.Count do
          begin
            Result.Append(FGrids[i-1].FGrid.Columns[j-1].Title.Caption);
            Result.Append(FGrids[i-1].FGrid.Columns[j-1].FieldName+';Width='+
                IntToStr(FGrids[i-1].FGrid.Columns[j-1].Width));
          end;
        end;

        For T:=1 to Length(FGrids[i-1].FTableParts) do
        begin
          Result.Append('[TablePart]');
          If FGrids[i-1].TableParts[T-1].DisplayMode in TDataGrid Then
          begin
            Result.Append('[Fields]');
            Result.Append(IntToStr(FGrids[i-1].TableParts[T-1].FGrid.Columns.Count));
            For j:=1 to FGrids[i-1].TableParts[T-1].FGrid.Columns.Count do
            begin
              Result.Append(FGrids[i-1].TableParts[T-1].FGrid.Columns[j-1].Title.Caption);
              Result.Append(FGrids[i-1].TableParts[T-1].FGrid.Columns[j-1].FieldName+';Width='+
                  IntToStr(FGrids[i-1].TableParts[T-1].FGrid.Columns[j-1].Width));
            end;
          end;
        end;
      end;

      Result.Append(appName+'[END '+DialogName+']');
      //Result.Append('');
      {$IFDEF DCLDEBUG}
      Result.SaveToFile(DialogName+'.txt');
      {$ENDIF}
    end;
end;

procedure TDCLForm.SaveBookMarkMenu;
begin
  Case GPT.FormPosInDB of
  isDisk:
  SaveBookmarkMenuINI;
  isBase:
  SaveBookmarkMenuBase;
  isDiskAndBase:
  begin
    SaveBookmarkMenuINI;
    SaveBookmarkMenuBase;
  end;
  end;
end;

procedure TDCLForm.SaveBookmarkMenuINI;
var
  FileParams, DialogsParams: TStringList;
  p1, p2, i, j: Integer;
begin
  DialogsParams:=SaveBookMarkMenuUni;
  If DialogsParams.Count>0 Then
  begin
    p1:= - 1;
    p2:= - 1;
    FileParams:=TStringList.Create;
    If DialogName<>'' Then
      If FileExists(IncludeTrailingPathDelimiter(AppConfigDir)+'BookMark.ini') Then
      begin
        FileParams.LoadFromFile(IncludeTrailingPathDelimiter(AppConfigDir)+'BookMark.ini'{$IFNDEF FPC}, TEncoding.UTF8{$ENDIF});
        For i:=1 to FileParams.Count do
        begin
          If PosEx('['+DialogName+']', FileParams[i-1])=1 Then
          begin
            p1:=i-1;
            For j:=p1 to FileParams.Count-1 do
            begin
              If PosEx('[END '+DialogName+']', FileParams[j])=1 Then
              begin
                p2:=j;
                break;
              end;
            end;
          end;
        end;
      end;

    If (p1<p2)and(p1> - 1) Then
    begin
      For i:=p1 to p2-p1 do
        FileParams.Delete(p1);
    end;
    FileParams.AddStrings(DialogsParams);
    FileParams.SaveToFile(IncludeTrailingPathDelimiter(AppConfigDir)+'BookMark.ini'{$IFNDEF FPC}, TEncoding.UTF8{$ENDIF});
  end;
  FreeAndNil(DialogsParams);
end;

procedure TDCLForm.SaveBookmarkMenuBase;
var
  DialogSettings: TStringList;
begin
  DialogSettings:=TStringList.Create;
  DialogSettings:=SaveBookMarkMenuUni;
  if DialogSettings.Count>0 then
    WriteBaseINI(itBookmarkMenu, DialogSettings);
  FreeAndNil(DialogSettings);
end;

procedure TDCLForm.LoadBookmarkMenu;
begin
  Case GPT.FormPosInDB of
  isDisk:
  LoadBookmarkMenuINI;
  isBase:
  LoadBookmarkMenuBase;
  isDiskAndBase:
  begin
    LoadBookmarkMenuINI;
    LoadBookmarkMenuBase;
  end;
  end;
end;

procedure TDCLForm.LoadBookmarkMenuINI;
var
  MenuList, DialogsParams: TStringList;
begin
  If FileExists(IncludeTrailingPathDelimiter(AppConfigDir)+'BookMark.ini') Then
  begin
    MenuList:=TStringList.Create;
    MenuList.LoadFromFile(IncludeTrailingPathDelimiter(AppConfigDir)+'BookMark.ini'{$IFNDEF FPC}, TEncoding.UTF8{$ENDIF});
    DialogsParams:=CopyStrings('['+DialogName+']', '[END '+DialogName+']', MenuList);
    CreateBookMarkMenuUni(DialogsParams);
    MenuList.Free;
    DialogsParams.Free;
  end;
end;

procedure TDCLForm.LoadBookmarkMenuBase;
begin
  CreateBookMarkMenuUni(ReadBaseINI(itBookmarkMenu));
end;

procedure TDCLForm.CreateBookMarkMenuUni(MenuList: TStringList);
var
  ParamsCounter, i: Word;
  g, T: Integer;
  Grid: TDCLGrid;
  S: String;
  DialogParams: TStringList;
begin
  DialogParams:=TStringList.Create;
  DialogParams.Clear;

  If DialogName<>'' Then
    If MenuList.Count>0 Then
    begin
      g:= - 1;
      T:= - 1;
      Grid:=nil;
      ParamsCounter:=0;

      If MenuList.Count>0 Then
        While (ParamsCounter<MenuList.Count) do
        begin
          S:=Trim(MenuList[ParamsCounter]);

          If PosEx('[Page]', S)=1 Then
          begin
            inc(ParamsCounter);
            T:= - 1;
            inc(g);
            If g> - 1 Then
              Grid:=Tables[g];
          end;

          If PosEx('[TablePart]', S)=1 Then
          begin
            inc(ParamsCounter);
            inc(T);
            If g> - 1 Then
              If T> - 1 Then
                Grid:=Tables[g].TableParts[T];
            If ParamsCounter>=MenuList.Count Then
              break;
            If PosEx('[TablePart]', MenuList[ParamsCounter])=1 Then
            begin
              Grid:=nil;
            end;
          end;

          If Assigned(Grid) Then
          begin
            DialogParams.Clear;
            For i:=ParamsCounter to ParamsCounter+KeyMarksItems-1 do
              DialogParams.Append(MenuList[i]);
            Grid.CreateBookMarkMenu(DialogParams);
            inc(ParamsCounter, KeyMarksItems-1);
          end;

          inc(ParamsCounter);
        end;
    end;
  DialogParams.Free;
end;

function TDCLForm.SaveBookMarkMenuUni: TStringList;
var
  i, T, l: Word;
begin
  l:=0;
  Result:=TStringList.Create;
  If DialogName<>'' Then
  begin
    inc(l);
    Result.Append('['+DialogName+']');
    For i:=1 to Length(FGrids) do
    begin
      inc(l);
      Result.Append('[Page]');
      Result.AddStrings(FGrids[i-1].SaveBookMarkMenu);

      For T:=1 to Length(FGrids[i-1].FTableParts) do
      begin
        inc(l);
        Result.Append('[TablePart]');
        Result.AddStrings(FGrids[i-1].FTableParts[T-1].SaveBookMarkMenu);
      end;
    end;

    inc(l, 2);
    Result.Append('[END '+DialogName+']');
    Result.Append('');
  end;
  If l=Result.Count Then
    Result.Clear;
end;

procedure TDCLForm.AddSubItem(Caption, ItemName, Pict: String; Level: Integer;
  Action: TNotifyEvent);
begin
  If Level<> - 1 Then
  begin
    ToItem:=FFormMenu.Items[Level];
    ItemMenu:=TMenuItem.Create(ToItem);
    ItemMenu.Name:=ItemName;
    ItemMenu.Caption:=Caption;
    ItemMenu.OnClick:=Action;
    ItemMenu.Bitmap.Assign(DrawBMPButton(Pict));
    ToItem.OnClick:=nil;
    ToItem.Insert(ToItem.Count, ItemMenu);
  end;
end;

procedure TDCLForm.AddMainItem(Caption, ItemName, Pict: String; Action: TNotifyEvent);
begin
  ItemMenu:=TMenuItem.Create(FFormMenu);
  ItemMenu.Name:=ItemName;
  ItemMenu.Caption:=Caption;
  ItemMenu.OnClick:=Action;
  ItemMenu.Bitmap.Assign(DrawBMPButton(Pict));
  FFormMenu.Items.Add(ItemMenu);
end;

procedure TDCLForm.ResetAllFieldsSettings(Sender: TObject);
begin
  If ShowErrorMessage(10, GetDCLMessageString(msResetAllFieldsSettingsQ))=1 Then
  begin
    FieldsSettingsReseted:=True;
    DeleteAllFormPos;
  end;
end;

procedure TDCLForm.ResetFieldsSettings(Sender: TObject);
begin
  If ShowErrorMessage(10, GetDCLMessageString(msResetFieldsSettingsQ))=1 Then
  begin
    FieldsSettingsReseted:=True;
    DeleteFormPos(False);
  end;
end;

procedure TDCLForm.DeleteAllBookmarks(Sender: TObject);
begin
  If ShowErrorMessage(10, GetDCLMessageString(msDeleteAllBookmarksQ))=1 Then
    FGrids[CurrentGridIndex].DeleteAllBookmarks;
end;

procedure TDCLForm.DeleteAllFormPos;
begin
  DeleteFormPos(True);
end;

procedure TDCLForm.SaveFieldsSettings(Sender: TObject);
begin
  SaveFormPos;
end;

constructor TDCLForm.Create(DialogName: String; var DCLLogOn: TDCLLogOn; ParentForm, CallerForm: TDCLForm;
  aFormNum: Integer; OPL: TStringList; Query: TDCLDialogQuery; Data: TDataSource;
  Modal: Boolean=False; ReturnValueMode: TChooseMode=chmNone;
  ReturnValueParams: TReturnValueParams=nil);
var
  ScrStr, TmpStr, tmpStr2, tmpSQL, tmpSQL1: String;
  DisplayMode, tmpStyle: TDataControlType;
  QCreated, ModalOpen: Boolean;
  OPLLinesCount, ScrStrNum, v1, v2, v3, v4, v5, TabIndex: Integer;
  IsDigitType: TIsDigitType;
  ShadowQuery: TDCLDialogQuery;
  FFilter: TDBFilter;
  Calendar: RCalendar;
  UserLevel: TUserLevelsType;
  ButtonParams: RButtonParams;
  FField: RField;
  FieldsOPL: TStringList;

  procedure SetNewQuery(SQL: String);
  begin
    If Not QCreated Then
    begin
      QCreated:=True;
      GridIndex:=AddGrid(ParentPanel, dctMainGrid, Query, nil);
    end
    Else
    begin
      If Not Assigned(FGrids[GridIndex].FQueryGlob) Then
        FGrids[GridIndex].SetNewQuery(nil);
    end;
    FGrids[GridIndex].SetSQLToStore(SQL, qtMain, ulUndefined);

    QueryGlobIndex:=GridIndex;
    TranslateVal(SQL, False);
    FGrids[GridIndex].SQL:=SQL;
    FGrids[GridIndex].Open;
  end;

begin
  NoCloseable:=False;
  FormCanClose:=True;
  FCloseAction:=fcaNone;
  FieldsOPL:=nil;
  ExitCode:=0;
  FieldsSettingsReseted:=False;
  SettingsLoaded:=False;
  NotDestroyedDCLForm:=False;
  FParentForm:=ParentForm;
  FCallerForm:=CallerForm;
  FRetunValue.Choosen:=False;
  Modal:=ReturnValueMode<>chmNone;
  FReturnValueParams:=ReturnValueParams;
  FReturningMode:=ReturnValueMode;
  ResetChooseValue(FRetunValue);
  ModalOpen:=Modal;
  NoStdKeys:=False;
  LocalVariables:=TVariables.Create(FDCLLogOn, Self);
  FOPL:=TStringList.Create;
  FOPL:=OPL;
  FDCLLogOn:=DCLLogOn;
  FName:=DialogName;
  FDialogName:=DialogName;
  FFormNum:=aFormNum;
  GridIndex:= - 1;
  TabIndex:= - 1;
  Commands:=TDCLCommandButton.Create(DCLLogOn, Self);
  UserLevelLocal:=FDCLLogOn.AccessLevel;
  FormHeight:=DefaultFormHeight;
  FormWidth:=DefaultFormWidth;
  ExitNoSave:=False;
  SetLength(FGrids, 0);

  For v1:=1 to FDCLLogOn.FormsCount do
  begin
    If Assigned(FDCLLogOn.Forms[v1-1]) Then
      If FDCLLogOn.Forms[v1-1].IsSingle and (FDCLLogOn.Forms[v1-1].DialogName=DialogName) Then
      begin
        Exit;
        break;
      end;
  end;

  For v1:=1 to FDCLLogOn.FormsCount do
  begin
    If Assigned(FDCLLogOn.Forms[v1-1]) Then
      If FDCLLogOn.Forms[v1-1].Form.FormStyle=fsStayOnTop Then
      begin
        Modal:=True;
        break;
      end;
  end;

  FForm:=TDBForm.Create(Application);
  FForm.Name:=Trim(DialogName)+IntToStr(FForm.Handle);
  FForm.Width:=650;
  FForm.ClientHeight:=400;
  FForm.OnClose:=CloseForm;
  FForm.KeyPreview:=True;
  FForm.Position:=poScreenCenter;
  FForm.OnResize:=ResizeDBForm;
  FForm.OnActivate:=ActivateForm;
  FForm.OnCloseQuery:=OnCloseQuery;
  FForm.Tag:=aFormNum;
  FForm.Icon.Assign(GetIcon);
{$IFDEF SYSTEMFONT}{$IFDEF MSWINDOWS}
  FForm.ParentFont:=True;
  FForm.Font:=GUIFont;
{$ENDIF}{$ENDIF}

  FFormMenu:=TMainMenu.Create(FForm);
  // FFormMenu.Parent:=FForm;

  AddMainItem(InitCap(GetDCLMessageString(msSettings)), 'SettingsMenuItem',
    'Tools', nil);
  AddSubItem(GetDCLMessageString(msResetFieldsSettings), 'ResetFieldsSettings', '', 0, ResetFieldsSettings);
  AddSubItem(GetDCLMessageString(msResetAllFieldsSettings), 'ResetAllFieldsSettings', '', 0, ResetAllFieldsSettings);
  AddSubItem(GetDCLMessageString(msDeleteAllBookmarks), 'DeleteAllBookmarks', '', 0, DeleteAllBookmarks);

  AddSubItem('-', 'Splitter76113C76B41E4', '', 0, nil);
  AddSubItem(GetDCLMessageString(msSaveFieldsSettings), 'SaveFieldsSettings', '', 0, SaveFieldsSettings);

{$IFNDEF EMBEDDED}
  If Assigned(Application.MainForm) then
    If Application.MainForm.FormStyle=fsMDIForm Then
      FForm.FormStyle:=fsMDIChild;
{$ENDIF}
{$IFDEF MSWINDOWS}
  SetWindowLong(FForm.Handle, GWL_EXSTYLE, GetWindowLong(FForm.Handle, GWL_EXSTYLE)or
      WS_EX_APPWINDOW);
{$ENDIF}
{$IFDEF DCLDEBUG}
  FForm.Show;
{$ENDIF}
  If Assigned(FDCLLogOn.FDCLMainMenu) Then
    If ShowFormPanel and Assigned(FDCLLogOn.FDCLMainMenu.FormBar) Then
      If FDCLLogOn.FDCLMainMenu.FormBar.Parent<>FForm Then
      begin
        TB:=TFormPanelButton.Create(FDCLLogOn.FDCLMainMenu.FormBar);
        TB.Name:='TB'+IntToStr(FForm.Handle);
        TB.Parent:=FDCLLogOn.FDCLMainMenu.FormBar;
        TB.Width:=FormPanelButtonWidth;
        TB.Height:=FormPanelButtonHeight;
        TB.OnClick:=ToolButtonClick;
        TB.Tag:=FForm.Tag;
        TB.Margin:=PanelButtonTextRight;
        TB.Glyph:=DrawBMPButton('FormDotActive');
        TB.Font.Style:=[fsBold];
      end;

  DBStatus:=TStatusBar.Create(FForm);
  DBStatus.Parent:=FForm;
  DBStatus.SimplePanel:=False;
  DBStatus.Align:=alBottom;
  // DBStatus.Top:=FForm.ClientHeight;
  DBStatus.Panels.Insert(0);
  DBStatus.Panels.Insert(1);
  DBStatus.Panels.Insert(2);
  DBStatus.Panels[1].Width:=80;
  DBStatus.Panels[0].Width:=100;

  MainPanel:=TDCLMainPanel.Create(FForm);
  MainPanel.Parent:=FForm;
  MainPanel.Height:=470;
  MainPanel.Top:=50;
  MainPanel.Align:=alClient;

  QCreated:=True;
  AddMainPage(Query, Data);

  If Length(FOPL.Text)>3 Then
  begin
    QCreated:=True;
    ScrStrNum:=0;
    OPLLinesCount:=FOPL.Count;
    GPT.CurrentRunningScrString:=0;

    While ScrStrNum<OPLLinesCount do
    begin
      ScrStr:=Trim(FOPL[ScrStrNum]);
      inc(GPT.CurrentRunningScrString);

      If Pos('//', ScrStr)=1 Then
      begin
        inc(ScrStrNum);
        Continue;
      end;

      If PosEx('DialogName=', ScrStr)=1 Then
      begin
        TranslateVal(ScrStr, True);
        tmpSQL:=FindParam('DialogName=', ScrStr);
        DialogName:=tmpSQL;
        FName:=DialogName;
        FDialogName:=DialogName;
      end;

      If PosEx('Single;', ScrStr)=1 Then
      begin
        IsSingle:=True;
      end;

      If PosEx('Orientation=', ScrStr)=1 Then
      begin
        TranslateVal(ScrStr, True);
        tmpSQL:=LowerCase(FindParam('Orientation=', ScrStr));
        If tmpSQL='horizontal' Then
          FGrids[GridIndex].FOrientation:=oHorizontal;
        If tmpSQL='vertical' Then
          FGrids[GridIndex].FOrientation:=oVertical;
      end;

      If PosEx('AutoRefresh;', ScrStr)=1 Then
      begin
        TranslateVal(ScrStr, True);
        FGrids[GridIndex].RefreshTimer:=TTimer.Create(nil);
        FGrids[GridIndex].RefreshTimer.Tag:=GridIndex;
        FGrids[GridIndex].RefreshTimer.Interval:=AutoResfreshInterval;
        FGrids[GridIndex].RefreshTimer.OnTimer:=FGrids[GridIndex].AutorefreshTimer;
        FGrids[GridIndex].RefreshTimer.Enabled:=True;
        FGrids[GridIndex].LastStateTimer:=False;
      end;

      If PosEx('AutoRefresh=', ScrStr)=1 Then
      begin
        TranslateVal(ScrStr, True);
        tmpSQL:=ScrStr;
        RePlaseVariables(tmpSQL);
        v1:=StrToIntEx(FindParam('AutoRefresh=', tmpSQL))*1000;
        If v1>0 Then
        begin
          FGrids[GridIndex].RefreshTimer:=TTimer.Create(nil);
          FGrids[GridIndex].RefreshTimer.Tag:=GridIndex;
          FGrids[GridIndex].RefreshTimer.Interval:=v1;
          FGrids[GridIndex].RefreshTimer.OnTimer:=FGrids[GridIndex].AutorefreshTimer;
          FGrids[GridIndex].RefreshTimer.Enabled:=True;
          FGrids[GridIndex].LastStateTimer:=False;
        end;
      end;

      If PosEx('SetUserAccessRaight=', ScrStr)=1 Then
      begin
        If FDCLLogOn.AccessLevel>=ulLevel3 Then
        begin
          TranslateVal(ScrStr, True);
          tmpSQL:=FindParam('SetUserAccessRaight=', ScrStr);

          Case GetStringDataType(tmpSQL) of
          idDigit:
          UserLevelLocal:=TranslateDigitToUserLevel
            (StrToIntEx(FindParam('SetUserAccessRaight=', ScrStr)));
          idUserLevel:
          UserLevelLocal:=TranslateDigitToUserLevel(FindParam('SetUserAccessRaight=', ScrStr));
          end;
        end;
      end;

      If PosEx('UserAccessRaight=', ScrStr)=1 Then
      begin
        TranslateVal(ScrStr, True);
        tmpSQL:=FindParam('UserAccessRaight=', ScrStr);
        Case GetStringDataType(tmpSQL) of
        idDigit:
        UserLevel:=TranslateDigitToUserLevel(StrToIntEx(FindParam('UserAccessRaight=', ScrStr)));
        idUserLevel:
        UserLevel:=TranslateDigitToUserLevel(FindParam('UserAccessRaight=', ScrStr));
        end;
        If UserLevel>UserLevelLocal Then
        begin
          ShowErrorMessage(0, GetDCLMessageString(msNotAllowOpenForm));
          ExitCode:=1;
          Exit;
        end;
      end;

      If PosEx('DataReadOnly=', ScrStr)=1 Then
      begin
        TranslateVal(ScrStr, True);
        TmpStr:=Trim(FindParam('DataReadOnly=', ScrStr));
        FGrids[GridIndex].TranslateVal(TmpStr);

        If StrToIntEx(TmpStr)=1 Then
        Begin
         // FGrids[GridIndex].FQuery.CanModify:=False;
          FGrids[GridIndex].ReadOnly:=True;
          FGrids[GridIndex].AddNotAllowedOperation(dsoInsert);
          FGrids[GridIndex].AddNotAllowedOperation(dsoDelete);
          FGrids[GridIndex].AddNotAllowedOperation(dsoEdit);
        End;
      end;

      If PosEx('AddNotAllowOperation=', ScrStr)=1 Then
      begin
        TranslateVal(ScrStr, True);
        TmpStr:=FindParam('AddNotAllowOperation=', ScrStr);
        If PosEx('Insert', TmpStr)<>0 Then
          FGrids[GridIndex].AddNotAllowedOperation(dsoInsert);
        If PosEx('Delete', TmpStr)<>0 Then
          FGrids[GridIndex].AddNotAllowedOperation(dsoDelete);
        If PosEx('Edit', TmpStr)<>0 Then
          FGrids[GridIndex].AddNotAllowedOperation(dsoEdit);
      end;

      If PosEx('QueryKeyField=', ScrStr)=1 Then
      begin
        TranslateVal(ScrStr, True);
        FGrids[GridIndex].KeyMarks.KeyField:=FindParam('QueryKeyField=', ScrStr);
        FGrids[GridIndex].KeyMarks.TitleField:=FindParam('TitleField=', ScrStr);
        If FGrids[GridIndex].KeyMarks.TitleField='' Then
          FGrids[GridIndex].KeyMarks.TitleField:=FGrids[GridIndex].KeyMarks.KeyField;
      end;

      If PosEx('ReOpen;', ScrStr)=1 Then
      begin
        RefreshForm;
      end;

      If PosEx('ExitNoSave=', ScrStr)=1 Then
      begin
        TranslateVal(ScrStr, True);
        tmpSQL:=FindParam('exitnosave=', ScrStr);
        If tmpSQL='1' Then
          ExitNoSave:=True;
      end;

      If PosEx('SetFieldValue=', ScrStr)=1 Then
      begin
        ExecCommand(ScrStr);
      end;

      If PosEx('SetMainFormCaption=', ScrStr)=1 Then
      begin
        ExecCommand(ScrStr);
      end;

      If PosEx('Status=', ScrStr)=1 Then
      begin
        ExecCommand(ScrStr);
      end;

      If PosEx('AddStatus=', ScrStr)=1 Then
      begin
        ExecCommand(ScrStr);
      end;

      If PosEx('StatusWidth=', ScrStr)=1 Then
      begin
        ExecCommand(ScrStr);
      end;

      If PosEx('SetStatusText=', ScrStr)=1 Then
      begin
        ExecCommand(ScrStr);
      end;

      If PosEx('DeleteAllStatus;', ScrStr)=1 Then
      begin
        ExecCommand(ScrStr);
      end;

      If PosEx('DeleteStatus=', ScrStr)=1 Then
      begin
        ExecCommand(ScrStr);
      end;

      If PosEx('FormHeight=', ScrStr)=1 Then
      begin
        TranslateVal(ScrStr, True);
        FormHeight:=StrToIntEx(FindParam('FormHeight=', ScrStr));
        FForm.ClientHeight:=FormHeight;
      end;

      If PosEx('FormWidth=', ScrStr)=1 Then
      begin
        TranslateVal(ScrStr, True);
        FormWidth:=StrToIntEx(FindParam('FormWidth=', ScrStr));
        FForm.ClientWidth:=FormWidth;
      end;

      If PosEx('SeparateChar=', ScrStr)=1 Then
      begin
        GPT.StringTypeChar:=FindParam('SeparateChar=', ScrStr);
      end;

      If PosEx('SetValueSeparator=', ScrStr)=1 Then
      begin
        TranslateVal(ScrStr, True);
        GPT.GetValueSeparator:=FindParam('SetValueSeparator=', ScrStr);
      end;

      If PosEx('ReadOnly=', ScrStr)=1 Then
      begin
        TranslateVal(ScrStr, True);
        TmpStr:=Trim(FindParam('ReadOnly=', ScrStr));
        FGrids[GridIndex].TranslateVal(TmpStr);

        If StrToIntEx(TmpStr)=1 Then
          FGrids[GridIndex].SetReadOnly(True)
        Else
          FGrids[GridIndex].SetReadOnly(False);
      end;

      If PosEx('NoCloseable=', ScrStr)=1 Then
      begin
        TmpStr:=FindParam('NoCloseable=', ScrStr);
        NoCloseable:=Trim(TmpStr)='1';
      end;

      If PosEx('CloseQuery=', ScrStr)=1 Then
      begin
        CloseQueryText:=FindParam('CloseQuery=', ScrStr);
        CloseQuery:=True;
      end;

      If PosEx('Navigator=', ScrStr)=1 Then
      begin
        TranslateVal(ScrStr, True);
        tmpSQL:=FindParam('Navigator=', ScrStr);
        If tmpSQL='0' Then
        begin
          If Assigned(FGrids[GridIndex].Navig) Then
            FGrids[GridIndex].Navig.Hide;
        end
        Else
        begin
          If FindParam('buttons=', ScrStr)='' Then
            ScrStr:=ScrStr+';buttons='+DefaultNavigButtonsSet+';';
          If FindParam('buttons=', ScrStr)<>'' Then
          begin
            tmpSQL:=FindParam('buttons=', ScrStr);
            For v1:=1 to 10 do
              NavigVisiButtonsVar[v1]:=[];
            If PosEx('first', tmpSQL)<>0 Then
              NavigVisiButtonsVar[1]:=[nbFirst];
            If PosEx('last', tmpSQL)<>0 Then
              NavigVisiButtonsVar[4]:=[nbLast];
            If PosEx('insert', tmpSQL)<>0 Then
            begin
              If UserLevelLocal<>ulReadOnly Then
                NavigVisiButtonsVar[5]:=[nbInsert];
            end;
            If PosEx('delete', tmpSQL)<>0 Then
            begin
              If UserLevelLocal<>ulReadOnly Then
                NavigVisiButtonsVar[6]:=[nbDelete];
            end;
            If PosEx('edit', tmpSQL)<>0 Then
            begin
              If UserLevelLocal<>ulReadOnly Then
                NavigVisiButtonsVar[7]:=[nbEdit];
            end;
            If PosEx('post', tmpSQL)<>0 Then
              If UserLevelLocal<>ulReadOnly Then
                NavigVisiButtonsVar[8]:=[nbPost];
            If PosEx('cancel', tmpSQL)<>0 Then
              If UserLevelLocal<>ulReadOnly Then
                NavigVisiButtonsVar[9]:=[nbCancel];
            If PosEx('refresh', tmpSQL)<>0 Then
              NavigVisiButtonsVar[10]:=[nbRefresh];
            FGrids[GridIndex].Navig.VisibleButtons:=NavigVisiButtonsVar[1]+NavigVisiButtonsVar[2]+
              NavigVisiButtonsVar[3]+NavigVisiButtonsVar[4]+NavigVisiButtonsVar[5]+
              NavigVisiButtonsVar[6]+NavigVisiButtonsVar[7]+NavigVisiButtonsVar[8]+
              NavigVisiButtonsVar[9]+NavigVisiButtonsVar[10];
          end;

          If FindParam('Flat=', ScrStr)<>'' Then
          begin
            tmpSQL:=FindParam('Flat=', ScrStr);
            If tmpSQL='1' Then
              FGrids[GridIndex].Navig.Flat:=True;
          end;
        end;
      end;

      If PosEx('[QUERY]', ScrStr)=1 Then
      begin
        ScrStr:=GetQueryToRaights(ScrStr);
        v1:=ScrStrNum;
        tmpSQL:='';
        For v2:=v1 to OPLLinesCount do
          If CompareString(Trim(FOPL[v2]), '[END QUERY]') Then
          begin
            ScrStrNum:=v2;
            For v3:=v1+1 to v2-1 do
              tmpSQL:=tmpSQL+FOPL[v3]+' ';
            FNewPage:=False;
            SetNewQuery(tmpSQL);
            break;
          end;
      end;

      If PosEx('Query=', ScrStr)=1 Then
      begin
        ScrStr:=GetQueryToRaights(ScrStr);
        If ScrStr<>'' Then
        begin
          tmpSQL:=FindParam('Query=', ScrStr);
          FNewPage:=False;
          SetNewQuery(tmpSQL);
        end;
      end;

      If PosEx('QueryName=', ScrStr)=1 Then
      begin
        TranslateVal(ScrStr, True);
        tmpSQL:=FindParam('QueryName=', ScrStr);
        FGrids[GridIndex].QueryName:=tmpSQL;
      end;

      If PosEx('OrderByFields=', ScrStr)=1 Then
      begin
        TranslateVal(ScrStr, True);
        tmpSQL:=FindParam('OrderByFields=', ScrStr);
        v2:=ParamsCount(tmpSQL);
        For v1:=1 to v2 do
        begin
          v2:=Length(FGrids[GridIndex].OrderByFields);
          SetLength(FGrids[GridIndex].OrderByFields, v2+1);
          FGrids[GridIndex].OrderByFields[v2]:=SortParams(tmpSQL, v1);
        end;
      end;

      If PosEx('Message=', ScrStr)=1 Then
      begin
        ExecCommand(ScrStr);
      end;

      If (PosEx('UniqueTable=', ScrStr)=1)or
        (PosSet('UpdateResync=,LockType=,CursorType=', ScrStr)=1)or(PosEx('UniqueTable=', ScrStr)=1)
        or(PosEx('UpdateQuery=', ScrStr)=1)or
        (PosSet('AutoApply=,CashBase=,Live=,ParamCheck=', ScrStr)<>0)or
        (PosEx('UpdateTable=', ScrStr)=1) Then
      begin
        TranslateVal(ScrStr, True);
        If Assigned(FGrids[GridIndex].FQuery) Then
          FGrids[GridIndex].FQuery.SetUpdateSQL(FindParam('UpdateTable=', ScrStr),
            FindParam('KeyFields=', ScrStr));
        // FillDatasetUpdateSQL(FGrids[GridIndex].FQuery, {$IFDEF UPDATESQLDB}FGrids[GridIndex].UpdateSQL,{$ENDIF} ScrStr, FGrids[GridIndex].FUserLevelLocal, FGrids[GridIndex]);
      end;

      If PosEx('FindQuery=', ScrStr)=1 Then
      begin
        TranslateVal(ScrStr, False);
        tmpSQL:=FindParam('FindQuery=', ScrStr);
        FGrids[GridIndex].SetSQLToStore(tmpSQL, qtFind, ulUndefined);
      end;

      If PosEx('ExecCommand=', ScrStr)=1 Then
      begin
        TranslateVal(ScrStr, True);
        TmpStr:=FindParam('ExecCommand=', ScrStr);
        ExecCommand(TmpStr);
      end;

      If PosEx('SetValue=', ScrStr)=1 Then
      begin
        ExecCommand(ScrStr)
      end;

      If PosEx('Calendar=', ScrStr)=1 Then
      begin
        TranslateVal(ScrStr, True);
        ResetCalendarParams(Calendar);
        Calendar.Caption:=FindParam('Label=', ScrStr);

        Calendar.VarName:=FindParam('VariableName=', ScrStr);

        tmpSQL1:=FindParam('DefaultValue=', ScrStr);
        RePlaseVariables(tmpSQL1);
        If tmpSQL1<>'' Then
          Calendar.Value:=StrToDate(tmpSQL1)
        Else
          Calendar.Value:=Date;

        tmpSQL1:=FindParam('ReOpen=', ScrStr);
        RePlaseVariables(tmpSQL1);
        If tmpSQL1<>'' Then
          Calendar.ReOpen:=True
        Else
          Calendar.ReOpen:=False;

        FGrids[GridIndex].AddCalendar(Calendar);
      end;

      If PosEx('DBFilter=', ScrStr)=1 Then
      begin
        FFilter:=TDBFilter.Create;
        TranslateVal(ScrStr, True);
        FFilter.SQL:=FindParam('SQL=', ScrStr);
        If FFilter.SQL='' Then
          FFilter.SQL:=FindParam('DBFilterQuery=', ScrStr);
        If FFilter.SQL<>'' Then
        begin
          ResetFilterParams(FFilter);
          FFilter.FilterType:=ftDBFilter;

          FFilter.Caption:=FindParam('Label=', ScrStr);
          FFilter.Field:=FindParam('FilterField=', ScrStr);
          FFilter.ListField:=FindParam('List=', ScrStr);
          FFilter.KeyField:=FindParam('Key=', ScrStr);

          v3:=FilterWidth;
          If FindParam('Width=', ScrStr)<>'' Then
            v3:=StrToIntEx(Trim(FindParam('Width=', ScrStr)));
          FFilter.Width:=v3;

          If FindParam('VariableName=', ScrStr)<>'' Then
          begin
            FFilter.VarName:=FindParam('VariableName=', ScrStr);
            FDCLLogOn.Variables.NewVariableWithTest(FFilter.VarName);
          end;

          tmpSQL:=FindParam('KeyValue=', ScrStr);
          If tmpSQL<>'' Then
          begin
            RePlaseVariables(tmpSQL);
            If PosEx('select ', tmpSQL)<>0 Then
              If PosEx(' from ', tmpSQL)<>0 Then
              begin
                ShadowQuery:=TDCLDialogQuery.Create(nil);
                ShadowQuery.Name:='FormShadowK_'+IntToStr(UpTime);
                FDCLLogOn.SetDBName(ShadowQuery);
                ShadowQuery.SQL.Text:=tmpSQL;
                try
                  ShadowQuery.Open;
                  tmpSQL:=ShadowQuery.Fields[0].AsString;
                  If tmpSQL='' Then
                    tmpSQL:='-1';
                Except
                  ShowErrorMessage( - 1117, 'SQL='+tmpSQL);
                end;
              end;
            FFilter.KeyValue:=tmpSQL;
          end;

          FGrids[GridIndex].AddDBFilter(FFilter);
        end;
      end;

      If PosEx('ComboFilter=', ScrStr)=1 Then
      begin
        FFilter:=TDBFilter.Create;
        TranslateVal(ScrStr, True);
        ResetFilterParams(FFilter);
        FFilter.FilterType:=ftComboFilter;

        FFilter.Caption:=FindParam('Label=', ScrStr);
        FFilter.Field:=FindParam('FilterField=', ScrStr);
        FFilter.ListField:=FindParam('List=', ScrStr);

        v3:=FilterWidth;
        If FindParam('Width=', ScrStr)<>'' Then
          v3:=StrToIntEx(Trim(FindParam('Width=', ScrStr)));
        FFilter.Width:=v3;

        If FindParam('VariableName=', ScrStr)<>'' Then
        begin
          FFilter.VarName:=FindParam('VariableName=', ScrStr);
          FDCLLogOn.Variables.NewVariableWithTest(FFilter.VarName);
        end;

        tmpSQL:=FindParam('KeyValue=', ScrStr);
        If tmpSQL<>'' Then
        begin
          RePlaseVariables(tmpSQL);
          FFilter.KeyValue:=tmpSQL;
        end;

        FGrids[GridIndex].AddDBFilter(FFilter);
      end;

      If PosEx('ContextFilter=', ScrStr)=1 Then
      begin
        FFilter:=TDBFilter.Create;
        TranslateVal(ScrStr, True);
        ResetFilterParams(FFilter);
        FFilter.FilterType:=ftContextFilter;
        FFilter.Caption:=FindParam('Label=', ScrStr);
        FFilter.Field:=FindParam('FilterField=', ScrStr);

        v3:=FilterWidth;
        If FindParam('Width=', ScrStr)<>'' Then
          v3:=StrToIntEx(Trim(FindParam('Width=', ScrStr)));
        FFilter.Width:=v3;

        If FindParam('VariableName=', ScrStr)<>'' Then
        begin
          FFilter.VarName:=FindParam('VariableName=', ScrStr);
          FDCLLogOn.Variables.NewVariableWithTest(FFilter.VarName);
        end;

        If FindParam('MaxLength=', ScrStr)<>'' Then
        begin
          FFilter.MaxLength:=StrToIntEx(Trim(FindParam('MaxLength=', ScrStr)));
        end;

        TmpStr:=FindParam('WaitForEnter=', ScrStr);
        If TmpStr='1' Then
        begin
          FFilter.WaitForKey:=13;
        end;

        TmpStr:=FindParam('FilterMode=', ScrStr);
        If TmpStr<>'' Then
        begin
          If PosEx('Case', TmpStr)<>0 Then
            FFilter.CaseC:=True;

          If PosEx('NotLike', TmpStr)<>0 Then
            FFilter.NotLike:=True;

          If PosEx('Partial', TmpStr)<>0 Then
            FFilter.Partial:=True;
        end;

        If PosEx('ComponentName=', ScrStr)<>0 Then
          FFilter.FilterName:=FindParam('ComponentName=', ScrStr);

        FFilter.KeyValue:=FindParam('_Value=', ScrStr);

        FGrids[GridIndex].AddDBFilter(FFilter);
      end;

      If (PosEx('Between=', ScrStr)=1)or(PosEx('ContextBetween=', ScrStr)=1) Then
      begin
        TranslateVal(ScrStr, True);
        tmpSQL:=FindParam('between=', ScrStr);
        v3:=ParamsCount(tmpSQL);
        If v3 Mod 2=0 Then
        begin
          v2:=1;
          For v1:=1 to v3 div 2 do
          begin
            v3:=StrToIntEx(SortParams(tmpSQL, v2))-1;
            v5:=StrToIntEx(SortParams(tmpSQL, v2+1))-1;
            If v3<v5 then
            Begin
              v4:=v3;
              v3:=v5;
              v5:=v4;
            End;

            v4:=Length(FGrids[GridIndex].DBFilters);
            If v5<v4 then
            Begin
              If v3>0 then
                FGrids[GridIndex].DBFilters[v3].Between:=v5
              Else
                FGrids[GridIndex].DBFilters[v4+v3].Between:=v4+v5;
              If v5>0 then
                FGrids[GridIndex].DBFilters[v5].Between:=StopFilterFlg
              Else
                FGrids[GridIndex].DBFilters[v4+v5].Between:=StopFilterFlg;
            End;
            inc(v2, 1);
          end;
        end
        Else
          ShowErrorMessage( - 4000, LineEnding+ScrStr);
      end;

      If PosEx('TablePartToolButton=', ScrStr)=1 Then
      begin
        TranslateVal(ScrStr, True);
        If Not FindDisableAction(LowerCase(FindParam('action=', ScrStr))) Then
        begin
          tmpSQL1:=FindParam('AccessLevel=', ScrStr);
          v2:=0;
          If tmpSQL1<>'' Then
          begin
            IsDigitType:=GetStringDataType(tmpSQL1);
            Case IsDigitType of
            idDigit:
            If TranslateDigitToUserLevel(StrToIntEx(FindParam('AccessLevel=', ScrStr)))<=
              UserLevelLocal Then
              v2:=1
            Else
              v2:=0;
            idString:
            If TranslateDigitToUserLevel(FindParam('AccessLevel=', ScrStr))<=UserLevelLocal Then
              v2:=1
            Else
              v2:=0;
            end;
          end
          Else
            v2:=1;

          If v2=1 Then
          begin
            ResetButtonParams(ButtonParams);

            ButtonParams.Caption:=InitCap(FindParam('label=', ScrStr));
            If FindParam('_Default=', ScrStr)='1' Then
              ButtonParams.Default:=True;

            If FindParam('_Cancel=', ScrStr)='1' Then
              ButtonParams.Cancel:=True;

            ButtonParams.Hint:=InitCap(FindParam('hint=', ScrStr));

            TmpStr:=FindParam('Action=', ScrStr);
            If TmpStr<>'' Then
            begin
              ButtonParams.Command:=TmpStr;
              ButtonParams.Pict:=FindParam('action=', ScrStr);
            end
            Else
            begin
              If PosEx('CommandName=', ScrStr)<>0 Then
                ButtonParams.Command:=FindParam('commandname=', ScrStr);

              ButtonParams.Pict:=FindParam('Pict=', ScrStr);
            end;

            If PosEx('bold', FindParam('FontStyle=', ScrStr))<>0 Then
              ButtonParams.FontStyle:=ButtonParams.FontStyle+[fsBold];
            If PosEx('italic', FindParam('FontStyle=', ScrStr))<>0 Then
              ButtonParams.FontStyle:=ButtonParams.FontStyle+[fsItalic];
            If PosEx('underline', FindParam('FontStyle=', ScrStr))<>0 Then
              ButtonParams.FontStyle:=ButtonParams.FontStyle+[fsUnderLine];

            TmpStr:=FindParam('Width=', ScrStr);
            If TmpStr<>'' Then
            begin
              v5:=StrToIntEx(TmpStr);
              If v5>4 Then
                ButtonParams.Width:=v5;
            end
            Else
              ButtonParams.Width:=TablePartButtonWidth;

            ButtonParams.Height:=TablePartButtonHeight;

            FGrids[GridIndex].AddToolPartButton(ButtonParams);
          end;
        end;
      end;

      If PosEx('CommandButton=', ScrStr)=1 Then
      begin
        TranslateVal(ScrStr, True);
        If Not FindDisableAction(LowerCase(FindParam('action=', ScrStr))) Then
        begin
          tmpSQL1:=FindParam('AccessLevel=', ScrStr);
          If tmpSQL1<>'' Then
          begin
            IsDigitType:=GetStringDataType(tmpSQL1);
            Case IsDigitType of
            idDigit:
            If TranslateDigitToUserLevel(StrToIntEx(FindParam('AccessLevel=', ScrStr)))<=
              UserLevelLocal Then
              v2:=1
            Else
              v2:=0;
            idString:
            If TranslateDigitToUserLevel(FindParam('AccessLevel=', ScrStr))<=UserLevelLocal Then
              v2:=1
            Else
              v2:=0;
            end;
          end
          Else
            v2:=1;

          If v2=1 Then
          begin
            ResetButtonParams(ButtonParams);

            ButtonParams.Caption:=InitCap(FindParam('label=', ScrStr));
            If FindParam('_Default=', ScrStr)='1' Then
              ButtonParams.Default:=True;

            If FindParam('_Cancel=', ScrStr)='1' Then
              ButtonParams.Cancel:=True;

            ButtonParams.Hint:=InitCap(FindParam('hint=', ScrStr));

            TmpStr:=FindParam('Action=', ScrStr);
            If TmpStr<>'' Then
            begin
              ButtonParams.Command:=TmpStr;
              ButtonParams.Pict:=FindParam('Action=', ScrStr);
            end
            Else
            begin
              If PosEx('CommandName=', ScrStr)<>0 Then
                ButtonParams.Command:=FindParam('commandname=', ScrStr);

              ButtonParams.Pict:=FindParam('Pict=', ScrStr);
            end;

            If PosEx('bold', FindParam('FontStyle=', ScrStr))<>0 Then
              ButtonParams.FontStyle:=ButtonParams.FontStyle+[fsBold];
            If PosEx('italic', FindParam('FontStyle=', ScrStr))<>0 Then
              ButtonParams.FontStyle:=ButtonParams.FontStyle+[fsItalic];
            If PosEx('underline', FindParam('FontStyle=', ScrStr))<>0 Then
              ButtonParams.FontStyle:=ButtonParams.FontStyle+[fsUnderLine];

            TmpStr:=FindParam('Width=', ScrStr);
            If TmpStr<>'' Then
            begin
              v5:=StrToIntEx(TmpStr);
              If v5>4 Then
                ButtonParams.Width:=v5;
            end
            Else
              ButtonParams.Width:=ButtonWidth;

            ButtonParams.Height:=ButtonHeight;

            If ButtonLeft>ButtonLeftLimit Then
            begin
              ButtonLeft:=BeginStepLeft;
              inc(IncButtonPanelHeight, IncPanelHeight);
              FGrids[GridIndex].ButtonPanel.Height:=IncButtonPanelHeight;
              inc(ButtonTop, IncPanelHeight);
            end;

            ButtonParams.Top:=ButtonTop;
            ButtonParams.Left:=ButtonLeft;

            Commands.AddCommand(FGrids[GridIndex].ButtonPanel, ButtonParams);

            inc(ButtonLeft, ButtonParams.Width+ButtonsInterval);
          end;
        end;
      end;

      If PosEx('modal=', ScrStr)=1 Then
      begin
        TranslateVal(ScrStr, True);
        tmpSQL:=FindParam('Modal=', ScrStr);
        // If tmpSQL='0' Then Modal:=False;
        If tmpSQL='1' Then
          Modal:=True;
      end;

      If PosEx('GetFieldValue=', ScrStr)=1 Then
      begin
        ExecCommand(ScrStr);
      end;

      If PosEx('GetValue=', ScrStr)=1 Then
      begin
        ExecCommand(ScrStr);
      end;

      If PosEx('Orientation=', ScrStr)=1 Then
      begin
        If Assigned(FPages) Then
        begin
          TranslateVal(ScrStr, True);
          If LowerCase(FindParam('Orientation=', ScrStr))=LowerCase('top') Then
            FPages.TabPosition:=tpTop;
          If LowerCase(FindParam('Orientation=', ScrStr))=LowerCase('left') Then
            FPages.TabPosition:=tpLeft;
          If LowerCase(FindParam('Orientation=', ScrStr))=LowerCase('bottom') Then
            FPages.TabPosition:=tpBottom;
          If LowerCase(FindParam('Orientation=', ScrStr))=LowerCase('right') Then
            FPages.TabPosition:=tpRight;
        end;
      end;

      If PosEx('[Page]', ScrStr)=1 Then
      begin
        If Not FNewPage Then
        begin
          QCreated:=True;
          ButtonLeft:=BeginStepLeft;
          ButtonTop:=ButtonsTop;

          AddMainPage(Tables[GridIndex].Query, nil);
        end;

        If Assigned(FPages) Then
        begin
{$IFNDEF FPC}
          FPages.TabHeight:=0;
          FPages.TabWidth:=0;
{$ELSE}
          FPages.ShowTabs:=True;
{$ENDIF}
        end;
        FNewPage:=False;
      end;

      If PosEx('Caption=', ScrStr)=1 Then
      begin
        TranslateVal(ScrStr, True);
        tmpSQL:=InitCap(FindParam('caption=', ScrStr));
        FForm.Caption:=tmpSQL;
        If GPT.MainFormCaption<>'' then
          FForm.Caption:=FForm.Caption+' \'+Trim(GPT.MainFormCaption)+'\';
      end;

      If PosEx('Style=', ScrStr)=1 Then
      begin
        TranslateVal(ScrStr, True);
        tmpSQL:=FindParam('Style=', ScrStr);
        If tmpSQL='0' Then
          DisplayMode:=dctFields;
        If tmpSQL='1' Then
          DisplayMode:=dctFieldsStep;
        If tmpSQL='2' Then
          DisplayMode:=dctMainGrid;

        FGrids[GridIndex].DisplayMode:=DisplayMode;
      end;

      If PosEx('Title=', ScrStr)=1 Then
      begin
        TranslateVal(ScrStr, True);
        If Assigned(FPages) Then
          FTabs.Caption:=FindParam('Title=', ScrStr);
      end;

      If PosEx('SideGrid=', ScrStr)=1 Then
      begin
        TranslateVal(ScrStr, True);
        v1:=AddGrid(FForm, dctSideGrid, Query, nil);

        Tables[v1].Splitter1:=TSplitter.Create(FForm);
        Tables[v1].Splitter1.Name:='Splitter_SideGrid1';
        Tables[v1].Splitter1.Parent:=FForm;
        Tables[v1].Splitter1.Left:=250;
        Tables[v1].Splitter1.Align:=alLeft;

        ScrStr:=GetQueryToRaights(ScrStr);
        If ScrStr<>'' Then
        begin
          tmpSQL:=FindParam('SideGrid=', ScrStr);
          FNewPage:=False;
          SetNewQuery(tmpSQL);
        end;
      end;

      If PosEx('TablePart=', ScrStr)=1 Then
      begin
        TranslateVal(ScrStr, False);

        tmpSQL:=FindParam('Title=', ScrStr);

        tmpStyle:=dctMainGrid;
        tmpSQL1:=FindParam('Style=', ScrStr);
        If tmpSQL1='0' Then
          tmpStyle:=dctFields;
        If tmpSQL1='1' Then
          tmpStyle:=dctFieldsStep;
        If tmpSQL1='2' Then
          tmpStyle:=dctMainGrid;
        // ParentPanel.Align:=alClient;
        TabIndex:=FGrids[GridIndex].AddPartPage(tmpSQL, DataGlob, tmpStyle);
        If Not Assigned(FGrids[GridIndex].PartSplitter) Then
        begin
          FGrids[GridIndex].PartSplitter:=TSplitter.Create(FGrids[GridIndex].GridPanel);
          FGrids[GridIndex].PartSplitter.Parent:=FGrids[GridIndex].GridPanel;
          FGrids[GridIndex].PartSplitter.Align:=alBottom;

          FGrids[GridIndex].GridPanel.Align:=alClient;
        end;
        If TabIndex<> - 1 Then
        begin
          tmpSQL:=FindParam('SQL=', ScrStr);
          If tmpSQL<>'' Then
          begin
            If PosEx('Orientation=', ScrStr)=1 Then
            begin
              TranslateVal(ScrStr, True);
              tmpSQL1:=LowerCase(FindParam('Orientation=', ScrStr));
              If tmpSQL1='horizontal' Then
                FGrids[GridIndex].TableParts[TabIndex].FOrientation:=oHorizontal;
              If tmpSQL1='vertical' Then
                FGrids[GridIndex].TableParts[TabIndex].FOrientation:=oVertical;
            end;

            if (FindParam('UpdateTable=', ScrStr)<>'') and (FindParam('KeyFields=', ScrStr)<>'') then
              FGrids[GridIndex].TableParts[TabIndex].FQuery.SetUpdateSQL
                (FindParam('UpdateTable=', ScrStr), FindParam('KeyFields=', ScrStr));

            FGrids[GridIndex].TableParts[TabIndex].SQL:=tmpSQL;
            If FGrids[GridIndex].FQuery.Active Then
              try
                FGrids[GridIndex].TableParts[TabIndex].Open;
              Except
                On E: Exception do
                begin
                  ShowErrorMessage( - 1200, E.Message+' / SQL='+tmpSQL);
                end;
              end;
            FGrids[GridIndex].TableParts[TabIndex].Show;
            FGrids[GridIndex].TableParts[TabIndex].SetSQLToStore(tmpSQL, qtMain, ulUndefined);

            If FindParam('DependField=', ScrStr)<>'' Then
            begin
              FGrids[GridIndex].TableParts[TabIndex].DependField:=FindParam('DependField=', ScrStr);
            end;

            If FindParam('MasterDataField=', ScrStr)<>'' Then
            begin
              FGrids[GridIndex].TableParts[TabIndex].MasterDataField:=
                FindParam('MasterDataField=', ScrStr);
            end;

            FGrids[GridIndex].TableParts[TabIndex].NoDataField:=FindParam('NoDataField=', ScrStr)='1';
            If FindParam('VariableName=', ScrStr)<>'' Then
            begin
              FGrids[GridIndex].TableParts[TabIndex].MasterValueVariableName:=
                FindParam('VariableName=', ScrStr);
            end;

            If FindParam('Navigator=', ScrStr)='0' Then
            begin
              FGrids[GridIndex].TableParts[TabIndex].Navig.Hide;
            end;

            If FindParam('NavigatorButtons=', ScrStr)='' Then
              ScrStr:=ScrStr+';NavigatorButtons='+DefaultNavigButtonsSet+';';

            If PosEx('NavigatorButtons=', ScrStr)<>0 Then
            begin
              If Assigned(FGrids[GridIndex].TableParts[TabIndex].Navig) Then
              begin
                tmpSQL:=FindParam('NavigatorButtons=', ScrStr);
                For v1:=1 to 10 do
                  NavigVisiButtonsVar[v1]:=[];
                If PosEx('first', tmpSQL)<>0 Then
                  NavigVisiButtonsVar[1]:=[nbFirst];
                If PosEx('last', tmpSQL)<>0 Then
                  NavigVisiButtonsVar[4]:=[nbLast];
                If PosEx('insert', tmpSQL)<>0 Then
                begin
                  If UserLevelLocal<>ulReadOnly Then
                    NavigVisiButtonsVar[5]:=[nbInsert];
                end;
                If PosEx('delete', tmpSQL)<>0 Then
                begin
                  If UserLevelLocal<>ulReadOnly Then
                    NavigVisiButtonsVar[6]:=[nbDelete];
                end;
                If PosEx('edit', tmpSQL)<>0 Then
                begin
                  If UserLevelLocal<>ulReadOnly Then
                    NavigVisiButtonsVar[7]:=[nbEdit];
                end;
                If PosEx('post', tmpSQL)<>0 Then
                  If UserLevelLocal<>ulReadOnly Then
                    NavigVisiButtonsVar[8]:=[nbPost];
                If PosEx('cancel', tmpSQL)<>0 Then
                  NavigVisiButtonsVar[9]:=[nbCancel];
                If PosEx('refresh', tmpSQL)<>0 Then
                  NavigVisiButtonsVar[10]:=[nbRefresh];
                FGrids[GridIndex].TableParts[TabIndex].Navig.VisibleButtons:=NavigVisiButtonsVar[1]+
                  NavigVisiButtonsVar[2]+NavigVisiButtonsVar[3]+NavigVisiButtonsVar[4]+
                  NavigVisiButtonsVar[5]+NavigVisiButtonsVar[6]+NavigVisiButtonsVar[7]+
                  NavigVisiButtonsVar[8]+NavigVisiButtonsVar[9]+NavigVisiButtonsVar[10];
              end;
            end;

            TmpStr:=Trim(FindParam('ReadOnly=', ScrStr));
            If StrToIntEx(TmpStr)=1 Then
            begin
              FGrids[GridIndex].TableParts[TabIndex].ReadOnly:=True;
              FGrids[GridIndex].TableParts[TabIndex].Navig.VisibleButtons:=
                FGrids[GridIndex].TableParts[TabIndex].Navig.VisibleButtons-NavigatorEditButtons;
            end;

            If FindParam('Flat=', ScrStr)<>'' Then
            begin
              tmpSQL:=FindParam('Flat=', ScrStr);
              If tmpSQL='1' Then
                FGrids[GridIndex].TableParts[TabIndex].Navig.Flat:=True;
            end;

            TmpStr:=FindParam('Columns=', ScrStr);
            If TmpStr<>'' Then
            begin
              If Not Assigned(FieldsOPL) Then
                FieldsOPL:=TStringList.Create;
              FieldsOPL.Clear;
              FieldsOPL.Append(ScrStr);

              FGrids[GridIndex].TableParts[TabIndex].CreateFields(FieldsOPL);
            end;
          end;
        end;
      end;

      If PosEx('CurrentTablePart=', ScrStr)=1 Then
      begin
        tmpSQL:=Trim(FindParam('CurrentTablePart=', ScrStr));
        If FGrids[GridIndex].TablePartsCount>1 then
        Begin
          If tmpSQL='-1' then
            v1:=FGrids[GridIndex].TablePartsCount-1
          Else
            v1:=StrToIntEx(tmpSQL)-1;

          If (v1>=0) and (v1<FGrids[GridIndex].TablePartsCount) then
            FGrids[GridIndex].FTablePartsPages.ActivePageIndex:=v1;
        End;
      end;

      If PosEx('SummQuery=', ScrStr)=1 Then
      begin
        TranslateVal(ScrStr, False);
        FGrids[GridIndex].AddSumGrid(ScrStr);
      end;

      If PosEx('ApplicationTitle=', ScrStr)=1 Then
      begin
        TranslateVal(ScrStr, True);
        tmpSQL:=FindParam('ApplicationTitle=', ScrStr);
        Application.Title:=tmpSQL;
      end;

      If PosEx('Debug;', ScrStr)=1 Then
      begin
        GPT.DebugOn:=Not GPT.DebugOn;
      end;

      If PosEx('Events=', ScrStr)=1 Then
      begin
        TranslateVal(ScrStr, True);
        If PosEx('AfterOpenEvents=', ScrStr)<>0 Then
        begin
          TmpStr:=FindParam('AfterOpenEvents=', ScrStr);
          AddEvents(FGrids[GridIndex].EventsAfterOpen, TmpStr);
        end;

        If PosEx('CloseEvents=', ScrStr)<>0 Then
        begin
          TmpStr:=FindParam('CloseEvents=', ScrStr);
          AddEvents(EventsClose, TmpStr);
        end;

        If PosEx('BeforePostEvents=', ScrStr)<>0 Then
        begin
          TmpStr:=FindParam('BeforePostEvents=', ScrStr);
          AddEvents(FGrids[GridIndex].EventsBeforePost, TmpStr);
        end;

        If PosEx('AfterPostEvents=', ScrStr)<>0 Then
        begin
          TmpStr:=FindParam('AfterPostEvents=', ScrStr);
          AddEvents(FGrids[GridIndex].EventsAfterPost, TmpStr);
        end;

        If PosEx('CancelEvents=', ScrStr)<>0 Then
        begin
          TmpStr:=FindParam('CancelEvents=', ScrStr);
          AddEvents(FGrids[GridIndex].EventsCancel, TmpStr);
        end;

        If PosEx('BeforeScrollEvents=', ScrStr)<>0 Then
        begin
          TmpStr:=FindParam('BeforeScrollEvents=', ScrStr);
          AddEvents(FGrids[GridIndex].EventsBeforeScroll, TmpStr);
        end;

        If PosEx('ScrollEvents=', ScrStr)<>0 Then
        begin
          TmpStr:=FindParam('ScrollEvents=', ScrStr);
          AddEvents(FGrids[GridIndex].EventsScroll, TmpStr);
        end;

        If PosEx('InsertEvents=', ScrStr)<>0 Then
        begin
          TmpStr:=FindParam('InsertEvents=', ScrStr);
          AddEvents(FGrids[GridIndex].EventsInsert, TmpStr);
        end;

        If PosEx('DeleteEvents=', ScrStr)<>0 Then
        begin
          TmpStr:=FindParam('DeleteEvents=', ScrStr);
          AddEvents(FGrids[GridIndex].EventsDelete, TmpStr);
        end;

        If PosEx('LineDblClickEvents=', ScrStr)<>0 Then
        begin
          TmpStr:=FindParam('LineDblClickEvents=', ScrStr);
          AddEvents(FGrids[GridIndex].LineDblClickEvents, TmpStr);
        end;

        If PosEx('InsertPartEvents=', ScrStr)<>0 Then
        begin
          TmpStr:=FindParam('InsertPartEvents=', ScrStr);
          If TabIndex<> - 1 Then
            AddEvents(FGrids[GridIndex].TableParts[TabIndex].EventsInsert, TmpStr);
        end;

        If PosEx('ScrollPartEvents=', ScrStr)<>0 Then
        begin
          TmpStr:=FindParam('ScrollPartEvents=', ScrStr);
          If TabIndex<> - 1 Then
            AddEvents(FGrids[GridIndex].TableParts[TabIndex].EventsScroll, TmpStr);
        end;

        If PosEx('PostPartEvents=', ScrStr)<>0 Then
        begin
          TmpStr:=FindParam('PostPartEvents=', ScrStr);
          If TabIndex<> - 1 Then
            AddEvents(FGrids[GridIndex].TableParts[TabIndex].EventsAfterPost, TmpStr);
        end;
      end;

      If PosEx('Declare=', ScrStr)=1 Then
      begin
        ExecCommand(ScrStr);
      end;

      If PosEx('LocalDeclare=', ScrStr)=1 Then
      begin
        TranslateVal(ScrStr, True);
        TmpStr:=Trim(FindParam('LocalDeclare=', ScrStr));
        For v1:=1 to ParamsCount(TmpStr) do
        begin
          tmpStr2:=SortParams(TmpStr, v1);
          v2:=PosEx('=', tmpStr2);
          If v2=0 Then
          begin
            LocalVariables.NewVariable(tmpStr2, '');
          end
          Else
          begin
            tmpStr2:=Trim(Copy(tmpStr2, 1, v1-1));
            tmpSQL:=Copy(tmpStr2, v1+1, Length(tmpStr2)-v1);

            LocalVariables.NewVariable(tmpStr2, tmpSQL);
          end;
        end;
      end;

      If PosEx('Insert;', ScrStr)=1 Then
      begin
        FGrids[GridIndex].Query.Insert;
      end;

      If PosEx('Append;', ScrStr)=1 Then
      begin
        FGrids[GridIndex].Query.Append;
      end;

      If PosEx('Edit;', ScrStr)=1 Then
      begin
        FGrids[GridIndex].Query.Edit;
      end;

      If PosEx('Post;', ScrStr)=1 Then
      begin
        FGrids[GridIndex].Query.Post;
      end;

      If PosEx('First;', ScrStr)=1 Then
      begin
        FGrids[GridIndex].Query.First;
      end;

      If PosEx('Prior;', ScrStr)=1 Then
      begin
        FGrids[GridIndex].Query.Prior;
      end;

      If PosEx('Next;', ScrStr)=1 Then
      begin
        FGrids[GridIndex].Query.Next;
      end;

      If PosEx('Last;', ScrStr)=1 Then
      begin
        FGrids[GridIndex].Query.Last;
      end;

      If PosEx('Cancel;', ScrStr)=1 Then
      begin
        FGrids[GridIndex].Query.Cancel;
      end;

      If PosEx('Color=', ScrStr)=1 Then
      begin
        FGrids[GridIndex].AddBrushColor(ScrStr);
      end;

      If PosEx('DBImage=', ScrStr)=1 Then
      begin
        TranslateVal(ScrStr, True);

        ResetFieldParams(FField);
        FField.Width:=EditWidth;
        FField.Height:=GroupHeight;
        FField.FieldName:=FindParam('FieldName=', ScrStr);
        FField.ReadOnly:=StrToIntEx(FindParam('ReadOnly=', ScrStr))=1;

        FGrids[GridIndex].Splitter1:=TSplitter.Create(FGrids[GridIndex].GridPanel);
        FGrids[GridIndex].Splitter1.Name:='Splitter_DBImage_'+IntToStr(UpTime);
        FGrids[GridIndex].Splitter1.Parent:=FGrids[GridIndex].GridPanel;
        FGrids[GridIndex].Splitter1.Left:=10;
        FGrids[GridIndex].Splitter1.Align:=alRight;

        FGrids[GridIndex].AddMediaFieldGroup(FGrids[GridIndex].GridPanel, alRight,
          gtGrafic, FField);
      end;

      If PosEx('DBRichText=', ScrStr)=1 Then
      begin
        TranslateVal(ScrStr, True);

        ResetFieldParams(FField);
        FField.Width:=EditWidth;
        FField.Height:=GroupHeight;
        FField.FieldName:=FindParam('FieldName=', ScrStr);
        FField.ReadOnly:=StrToIntEx(FindParam('ReadOnly=', ScrStr))=1;

        FGrids[GridIndex].Splitter1:=TSplitter.Create(FGrids[GridIndex].GridPanel);
        FGrids[GridIndex].Splitter1.Name:='Splitter_DBRichText_'+IntToStr(UpTime);
        FGrids[GridIndex].Splitter1.Parent:=FGrids[GridIndex].GridPanel;
        FGrids[GridIndex].Splitter1.Left:=10;
        FGrids[GridIndex].Splitter1.Align:=alRight;

        FGrids[GridIndex].AddMediaFieldGroup(FGrids[GridIndex].GridPanel, alRight,
          gtRichText, FField);
      end;

      If PosEx('DBText=', ScrStr)=1 Then
      begin
        TranslateVal(ScrStr, True);

        ResetFieldParams(FField);
        FField.Width:=EditWidth;
        FField.Height:=GroupHeight;
        FField.FieldName:=FindParam('FieldName=', ScrStr);
        FField.ReadOnly:=StrToIntEx(FindParam('ReadOnly=', ScrStr))=1;

        FGrids[GridIndex].Splitter1:=TSplitter.Create(FGrids[GridIndex].GridPanel);
        FGrids[GridIndex].Splitter1.Name:='Splitter_DBMemo_'+IntToStr(UpTime);
        FGrids[GridIndex].Splitter1.Parent:=FGrids[GridIndex].GridPanel;
        FGrids[GridIndex].Splitter1.Left:=10;
        FGrids[GridIndex].Splitter1.Align:=alRight;

        FGrids[GridIndex].AddMediaFieldGroup(FGrids[GridIndex].GridPanel, alRight, gtMemo, FField);
      end;

      If PosEx('sqlmoon;', ScrStr)=1 Then
      begin
        FDCLLogOn.SQLMon.TrraceStatus:=Not FDCLLogOn.SQLMon.TrraceStatus;
      end;

      If PosEx('MultiSelect=', ScrStr)=1 Then
      begin
        ExecCommand(ScrStr);
      end;

      /// /========================================Fields========================================
      If (LowerCase(Trim(ScrStr))='[fields]')and Not NoVisual Then
      begin
        If Not Assigned(FieldsOPL) Then
          FieldsOPL:=TStringList.Create;
        If FOPL[ScrStrNum+1]='*' Then
          v5:=0
        Else If PosEx('LoadFromTable=', FOPL[ScrStrNum+1])<>0 Then
          v5:=0
        Else
          try
            v5:=StrToInt(Trim(FOPL[ScrStrNum+1]))*2;
          Except
            // ShowErrorMessage(-4002, '');
            v5:=0;
          end;
        FieldsOPL.Clear;
        For v1:=ScrStrNum to ScrStrNum+v5+1 do
          FieldsOPL.Append(FOPL[v1]);

        FGrids[GridIndex].CreateFields(FieldsOPL);
      end;

      /// //////////////////////////////
      inc(ScrStrNum);
{$IFDEF DCLDEBUG2}
      Application.ProcessMessages;
      Sleep(1000);
{$ENDIF}
    end;
    FreeAndNil(FieldsOPL);

    If ExitCode=0 Then
    begin
      // FItnQuery:=nil;
      QueryGlobIndex:=0;
      DataGlob:=FGrids[0].DataSource;

      For ScrStrNum:=1 to Length(FGrids) do
        FGrids[ScrStrNum-1].Show;

      MainPanel.Height:=120;
      MainPanel.Width:=350;
      MainPanel.Align:=alClient;

      If FormWidth>FForm.Width Then
        FForm.Width:=FormWidth;

      If Assigned(FDCLLogOn.FDCLMainMenu) Then
        If ShowFormPanel Then
          If Assigned(FDCLLogOn.FDCLMainMenu.FormBar) Then
            If FDCLLogOn.FDCLMainMenu.FormBar.Parent<>FForm Then
            begin
              TB.Caption:=FForm.Caption;
              TB.Hint:=FForm.Caption;
              TB.ShowHint:=True;
              TB.Show;
            end;

      FPages.ActivePageIndex:=0;
      ChangeTabPage(FPages);

      If FForm.Showing Then
        FForm.Hide;
      If Not FForm.Showing Then
        If ModalOpen Then
        Begin
          LoadFormPos;
          LoadBookmarkMenu;
          SettingsLoaded:=True;
          FForm.ShowModal;
        End
        Else
        begin
          FForm.Show;

          If FormHeight<>0 Then
            FForm.ClientHeight:=FormHeight;

          // Query.AfterScroll(Query);
{$IFNDEF DCLDEBUG}
          If Modal Then
            FForm.FormStyle:=fsStayOnTop;
{$ENDIF}
        end;
    end;
    If not SettingsLoaded then
    Begin
      LoadFormPos;
      LoadBookmarkMenu;
    End;
  end;
end;

procedure TDCLForm.DeleteAllStatus;
var
  i: Integer;
begin
  If DBStatus.Panels.Count>2 Then
    For i:=3 to DBStatus.Panels.Count do
      DeleteStatus(i-1);
end;

procedure TDCLForm.DeleteBaseINI(IniType: TINIType; All:Boolean);
var
  INIQuery:TDCLQuery;
  SQLParams:String;
begin
  INIQuery:=TDCLQuery.Create(FDCLLogOn.FDBLogOn);

  SQLParams:='delete from '+INITable+' where '+GetIniToRole(GPT.UserID)+
    ' INI_TYPE='+IntToStr(Ord(IniType));
  if All then
    SQLParams:=SQLParams+' and '+GPT.UpperString+IniDialogNameField+GPT.UpperStringEnd+
      '='+GPT.UpperString+GPT.StringTypeChar+InternalAppName+'_'+DialogName+GPT.StringTypeChar+
        GPT.UpperStringEnd;

  INIQuery.SQL.Text:=SQLParams;
  INIQuery.ExecSQL;

  FreeAndNil(INIQuery);
end;

procedure TDCLForm.DeleteFormPos(All:Boolean);
begin
  Case GPT.FormPosInDB of
  isDisk:
  DeleteFormPosINI(All);
  isBase:
  DeleteFormPosBase(All);
  isDiskAndBase:
  begin
    DeleteFormPosINI(All);
    DeleteFormPosBase(All);
  end;
  end;
end;

procedure TDCLForm.DeleteFormPosBase(All:Boolean);
begin
  DeleteBaseINI(itFormPos, All);
end;

procedure TDCLForm.DeleteFormPosINI(All:Boolean);
var
  FileParams: TStringList;
  p1, p2, i, j: Integer;
begin
  p1:= - 1;
  p2:= - 1;
  FileParams:=TStringList.Create;
  if not All then
    If DialogName<>'' Then
      If FileExists(IncludeTrailingPathDelimiter(AppConfigDir)+'Dialogs.ini') Then
      begin
        FileParams.LoadFromFile(IncludeTrailingPathDelimiter(AppConfigDir)+'Dialogs.ini'{$IFNDEF FPC}, TEncoding.UTF8{$ENDIF});
        For i:=1 to FileParams.Count do
        begin
          If PosEx('['+DialogName+']', FileParams[i-1])=1 Then
          begin
            p1:=i-1;
            For j:=p1 to FileParams.Count-1 do
            begin
              If PosEx('[END '+DialogName+']', FileParams[j])=1 Then
              begin
                p2:=j;
                break;
              end;
            end;
          end;
        end;
      end;

  If (p1<p2)and(p1> - 1) Then
  begin
    For i:=p1 to p2-p1 do
      FileParams.Delete(p1);
  end;
  FileParams.SaveToFile(IncludeTrailingPathDelimiter(AppConfigDir)+'Dialogs.ini'{$IFNDEF FPC}, TEncoding.UTF8{$ENDIF});
end;

procedure TDCLForm.DeleteStatus(StatusNum: Integer);
begin
  If StatusNum<0 Then
    StatusNum:=DBStatus.Panels.Count-1;
  If Assigned(DBStatus) Then
    If (DBStatus.Panels.Count>StatusNum)and(StatusNum>1) Then
    begin
      DBStatus.Panels.Delete(StatusNum);
    end;
end;

function TDCLGrid.FindNotAllowedOperation(Operation: TNotAllowedOperations): Boolean;
var
  l, i: Byte;
begin
  l:=Length(NotAllowedOperations);
  Result:=False;
  If l>0 Then
    For i:=1 to l do
    begin
      If NotAllowedOperations[i-1]=Operation Then
      begin
        Result:=True;
        break;
      end;
    end;
end;

function TDCLForm.GetActive: Boolean;
begin
  Result:=FForm.Showing;
end;

function TDCLForm.GetDataSource: TDataSource;
begin
  Result:=DataGlob;
end;

function TDCLForm.GetMainQuery: TDCLQuery;
begin
  Result:=nil;
  If (Length(FGrids)>QueryGlobIndex)and(QueryGlobIndex>=0) Then
    If Assigned(FGrids[QueryGlobIndex]) Then
      Result:=FGrids[QueryGlobIndex].FQuery;
end;

function TDCLForm.GetParentForm: TDCLForm;
begin
  Result:=FParentForm;
end;

function TDCLForm.GetPartQuery: TDCLQuery;
begin
  Result:=Tables[ - 1].TableParts[ - 1].Query;
end;

function TDCLForm.GetPreviosForm: TDCLForm;
begin
  if Assigned(FParentForm) then
    Result:=FParentForm
  else
    If Assigned(FCallerForm) then
      Result:=FCallerForm
    else
      Result:=nil;
end;

function TDCLForm.GetTable(Index: Integer): TDCLGrid;
var
  i, j: Integer;
begin
  Result:=nil;
  If Length(FGrids)>0 Then
  begin
    If (Index= - 1) Then
    begin
      If Assigned(FGrids[CurrentGridIndex]) Then
        Result:=FGrids[CurrentGridIndex];
    end
    Else
    begin
      If (Length(FGrids)>=0)and(Length(FGrids)>Index) Then
      begin
        j:= - 1;
        For i:=1 to Length(FGrids) do
        begin
          If Assigned(FGrids[i-1]) Then
          begin
            If FGrids[i-1].TabType=ptMainPage Then
              inc(j);
            If j=Index Then
            begin
              Result:=FGrids[i-1];
              break;
            end;
          end;
        end;
      end;
    end;
  end;
end;

function TDCLForm.GetTablesCount: Integer;
begin
  Result:=Length(FGrids);
end;

function TDCLForm.ReadBaseINI(IniType: TINIType):TStringList;
var
  FileParams: TStringList;
  INIQuery:TDCLQuery;
  appName:String;
begin
  Result:=TStringList.Create;
  If DialogName<>'' Then
    If GPT.DialogsSettings Then
    Begin
      FileParams:=TStringList.Create;
      INIQuery:=TDCLQuery.Create(FDCLLogOn.FDBLogOn);
      INIQuery.SQL.Text:='select '+IniParamValField+' from '+INITable+' where '+GetIniToRole(GPT.UserID)+
        GPT.UpperString+IniDialogNameField+GPT.UpperStringEnd+'='+GPT.UpperString+GPT.StringTypeChar+InternalAppName+'_'+DialogName+
          GPT.StringTypeChar+GPT.UpperStringEnd+' and INI_TYPE='+IntToStr(Ord(IniType));
      INIQuery.Open;
      If not INIQuery.IsEmpty then
      Begin
        appName:='BaseUID:'+InternalAppName+FDCLLogOn.GetBaseUID+'/';
        FileParams.Text:=INIQuery.FieldByName(IniParamValField).AsString;
        Result:=CopyStrings(appName+'['+DialogName+']', appName+'[END '+DialogName+']', FileParams);
      End;
      FreeAndNil(FileParams);
      FreeAndNil(INIQuery);
    End;
end;

procedure TDCLForm.RefreshForm;
var
  i: Integer;
begin
  For i:=1 to Length(FGrids) do
  begin
    FGrids[i-1].ReFreshQuery;
  end;
end;

procedure TDCLForm.CloseDatasets;
var
  i, j: Integer;
begin
  For i:=1 to Length(FGrids) do
  begin
    For j:=1 to Length(FGrids[i-1].FTableParts) do
      FGrids[i-1].FTableParts[j-1].Close;

    FGrids[i-1].Close;
  end;
end;

procedure TDCLForm.CloseDialog;
begin
  If Assigned(FForm) then
    FForm.Close;
  if FormCanClose then
    CloseAction:=fcaClose;
end;

procedure TDCLForm.ResumeDatasets;
var
  i, j: Integer;
begin
  For i:=1 to Length(FGrids) do
  begin
    FGrids[i-1].Open;
    For j:=1 to Length(FGrids[i-1].FTableParts) do
      FGrids[i-1].FTableParts[j-1].Open;
  end;
end;

procedure TDCLForm.RePlaseParams(var Params: String);
begin
  FGrids[CurrentGridIndex].RePlaseParams(Params);
end;

procedure TDCLForm.RePlaseVariables(var VariablesSet: String);
var
  Factor:Word;
begin
  LocalVariables.RePlaseVariables(VariablesSet, GetMainQuery);
  FDCLLogOn.RePlaseVariables(VariablesSet);
  Factor:=0;
  TranslateProc(VariablesSet, Factor, GetMainQuery);
end;

procedure TDCLForm.ResizeDBForm(Sender: TObject);
var
  Left, ToolBtnSize, i, j: Integer;
begin
  Left:=0;
  If Assigned(FForm) then
    For j:=1 to Length(FGrids) do
    begin
      If Assigned(FGrids[j-1]) Then
      If Assigned(FGrids[j-1].ToolButtonPanel) Then
        If (FGrids[j-1].ToolButtonPanel.Width>0)and(FGrids[j-1].ToolButtonsCount>0) Then
        begin
          ToolBtnSize:=(FGrids[j-1].ToolButtonPanel.Width-FGrids[j-1].ToolButtonsCount) div FGrids[j-1].ToolButtonsCount;
          For i:=1 to FGrids[j-1].ToolButtonsCount do
          begin
            FGrids[j-1].ToolButtonPanelButtons[i].Width:=ToolBtnSize;
            FGrids[j-1].ToolButtonPanelButtons[i].Left:=Left;
            Inc(Left, ToolBtnSize+1);
          end;
        end;
    end;
end;

procedure TDCLForm.SetDBStatus(StatusStr: String);
begin
  If Assigned(DBStatus) Then
  begin
    DBStatus.Panels[1].Text:=StatusStr;
  end;
end;

procedure TDCLForm.SetRecNo;
begin
  If GetActive Then
    If Assigned(DBStatus) Then
    begin
      DBStatus.Panels[0].Text:=IntToStr(CurrentQuery.RecNo)+'/'+IntToStr(CurrentQuery.RecordCount);
    end;
end;

procedure TDCLForm.SetStatus(StatusStr: String; StatusNum, Width: Integer);
begin
  If StatusNum<0 Then
    StatusNum:=DBStatus.Panels.Count-1;
  If StatusNum>DBStatus.Panels.Count Then
    StatusNum:=DBStatus.Panels.Count-1;
  If Assigned(DBStatus) Then
    If DBStatus.Panels.Count>StatusNum Then
    begin
      DBStatus.Panels[StatusNum].Text:=StatusStr;
      SetStatusWidth(StatusNum, Width);
    end;
end;

procedure TDCLForm.SetStatusWidth(StatusNum, Width: Integer);
begin
  If StatusNum<0 Then
    StatusNum:=DBStatus.Panels.Count-1;
  If StatusNum>DBStatus.Panels.Count Then
    StatusNum:=DBStatus.Panels.Count-1;
  If Assigned(DBStatus) Then
    If DBStatus.Panels.Count>StatusNum Then
    begin
      If Width>5 Then
        DBStatus.Panels[StatusNum].Width:=Width;
    end;
end;

procedure TDCLForm.SetTabIndex(Index: Integer);
begin
  If Assigned(FPages.Pages[Index]) Then
    FPages.ActivePageIndex:=Index;
end;

procedure TDCLForm.SetTable(Index: Integer; Value: TDCLGrid);
begin
  If (Length(FGrids)>Index)and(Index>=0) Then
    FGrids[Index]:=Value;
end;

procedure TDCLForm.SetVariable(VarName, VValue: String);
begin
  If LocalVariables.Exists(VarName) Then
    LocalVariables.Variables[VarName]:=VValue
  Else If FDCLLogOn.Variables.Exists(VarName) Then
    FDCLLogOn.Variables.Variables[VarName]:=VValue;
end;

procedure TDCLForm.GetChooseValue;
var
  CurrentGrid: TDCLGrid;
begin
  ResetChooseValue(FRetunValue);
  CurrentGrid:=Tables[ - 1];
  FRetunValue.Choosen:=False;
  If Assigned(CurrentGrid) Then
  begin
    If Assigned(FReturnValueParams) Then
    begin
      FRetunValue.Choosen:=True;
      FRetunValue.KeyModifyField:=FReturnValueParams.KeyModifyField;
      FRetunValue.ValueModifyField:=FReturnValueParams.ValueModifyField;

      FRetunValue.KeyEditName:=FReturnValueParams.KeyEditName;
      FRetunValue.ValueEditName:=FReturnValueParams.ValueEditName;

      FRetunValue.KeyVar:=FReturnValueParams.KeyVar;
      FRetunValue.ValueVar:=FReturnValueParams.ValueVar;

      If (FReturnValueParams.KeyField<>'') and CurrentGrid.Query.Active and FieldExists(FReturnValueParams.KeyField, CurrentGrid.Query) Then
        FRetunValue.Key:=CurrentGrid.Query.FieldByName(FReturnValueParams.KeyField).AsString;

      If (FReturnValueParams.ValueField<>'') and CurrentGrid.Query.Active and FieldExists(FReturnValueParams.ValueField, CurrentGrid.Query) Then
        FRetunValue.Val:=CurrentGrid.Query.FieldByName(FReturnValueParams.ValueField).AsString;
    end;
  end;
end;

procedure TDCLForm.Choose;
begin
  ChooseAndClose(FReturningMode);
end;

function TDCLForm.ChooseAndClose(Action: TChooseMode): TReturnFormValue;
begin
  GetChooseValue;
  FRetunValue.Choosen:=True;
  SetLength(FDCLLogOn.ReturnFormsValues, FFormNum+1);
  FDCLLogOn.ReturnFormsValues[FFormNum]:=FRetunValue;
  Result:=FRetunValue;

  Case Action of
  chmChooseAndClose:begin
    NotDestroyedDCLForm:=False;
    CloseAction:=fcaClose;
  end;
  chmChoose:begin
    NotDestroyedDCLForm:=False;
  end;
  End;
  CloseDialog;
end;

procedure TDCLForm.ToolButtonClick(Sender: TObject);
var
  TB1: TFormPanelButton;
begin
  If GetActive Then
  begin
    If Assigned(FForm) Then
    begin
      If FForm.WindowState=wsMinimized Then
        FForm.WindowState:=wsNormal;
      FForm.Show;
      FForm.BringToFront;
    end;
  end
  Else
  begin
    If Assigned(FDCLLogOn.FDCLMainMenu) Then
      If ShowFormPanel Then
      begin
        If Assigned(FDCLLogOn.FDCLMainMenu.FormBar) Then
        begin
          TB1:=(Sender as TFormPanelButton);
          FreeAndNil(TB1);
        end;
      end;
  end;
end;

procedure TDCLForm.TranslateVal(var Params: String; CheckParams: Boolean);
var
  Factor:Word;
begin
  If CheckParams Then
    RePlaseParams(Params);
  RePlaseVariables(Params);
  Factor:=0;
  TranslateProc(Params, Factor, nil);
end;

procedure TDCLForm.WriteBaseINI(IniType: TINIType; Params:TStringList);
var
  INIQuery:TDCLQuery;
  SQLParams, INIData:String;
begin
  If Assigned(Params) then
  Begin
    INIQuery:=TDCLQuery.Create(FDCLLogOn.FDBLogOn);
    INIQuery.SQL.Text:='select * from '+INITable+' where '+GetIniToRole(GPT.UserID)+
      GPT.UpperString+IniDialogNameField+GPT.UpperStringEnd+'='+GPT.UpperString+GPT.StringTypeChar+InternalAppName+'_'+DialogName+GPT.StringTypeChar+
        GPT.UpperStringEnd+' and INI_TYPE='+IntToStr(Ord(IniType));
    INIQuery.Open;

    INIData:=GPT.StringTypeChar+DoublingApostrof(Params.Text)+GPT.StringTypeChar;
    If INIQuery.IsEmpty then
    Begin
      If GPT.UserID<>'' then
        SQLParams:='insert into '+INITable+'('+IniDialogNameField+', '+IniParamValField+', INI_TYPE, '+IniUserFieldName+') '+
          'values('+GPT.StringTypeChar+InternalAppName+'_'+DialogName+GPT.StringTypeChar+', '+
          INIData+', '+IntToStr(Ord(IniType))+', '+GPT.UserID+')'
      Else
        SQLParams:='insert into '+INITable+'('+IniDialogNameField+', '+IniParamValField+', INI_TYPE) '+
          'values('+GPT.StringTypeChar+InternalAppName+'_'+DialogName+GPT.StringTypeChar+', '+
          INIData+', '+IntToStr(Ord(IniType))+')';
    End
    Else
    Begin
      SQLParams:='update '+INITable+' set '+IniParamValField+'='+
        INIData+' where '+GetIniToRole(GPT.UserID)+
        GPT.UpperString+IniDialogNameField+GPT.UpperStringEnd+'='+GPT.UpperString+GPT.StringTypeChar+InternalAppName+'_'+DialogName+GPT.StringTypeChar+
        GPT.UpperStringEnd+'and INI_TYPE='+IntToStr(Ord(IniType));
    End;
    INIQuery.Close;
    INIQuery.SQL.Text:=SQLParams;
    INIQuery.ExecSQL;

    FreeAndNil(INIQuery);
  End;
end;

{ TDCLCommand }

procedure TDCLCommand.SetValue(S: String);
var
  tmp1, tmp2, VarName, ReturnField, SQLText, KeyField: String;
  i, sv_v2, v2, v0: Integer;
  DCLQuery: TDCLDialogQuery;
  {$IFDEF TRANSACTIONDB}
  tmp_Transaction:TTransaction;
  {$ENDIF}
begin
  ReturnField:='';
  tmp2:=FindParam('SetValue=', S);
  If (PosEx('ReturnQuery=', S)=0)and(PosEx('SQL=', S)=0) Then
  begin
    TranslateValContext(tmp2);

    KeyField:=Trim(FindParam('TablePart=', S));
    If KeyField<>'' Then
    begin
      v2:=StrToIntEx(KeyField)-1;
      If v2=0 Then
        v2:=FDCLForm.CurrentTabIndex;
      If Assigned(FDCLForm) Then
        If Assigned(FDCLForm.Tables[ - 1]) Then
          If Assigned(FDCLForm.Tables[ - 1].TableParts[v2]) Then
            If FDCLForm.Tables[ - 1].TableParts[v2].Query.Active Then
              TranslateVals(tmp2, FDCLForm.Tables[ - 1].TableParts[v2].Query);
    end
    Else
      TranslateValContext(tmp2);

    sv_v2:=Pos('=', tmp2)-1;
    If sv_v2<=0 Then
      sv_v2:=Length(tmp2);
    VarName:=Copy(LowerCase(tmp2), 1, sv_v2);
    If FDCLLogOn.Variables.Exists(VarName) Then
      If Pos('=', tmp2)<>0 Then
      begin
        sv_v2:=Pos('=', tmp2)-1;
        Delete(tmp2, 1, sv_v2+1);

        KeyField:=Trim(FindParam('TablePart=', S));
        If KeyField<>'' Then
        begin
          v2:=StrToIntEx(KeyField)-1;
          If v2=0 Then
            v2:=FDCLForm.CurrentTabIndex;
          If Assigned(FDCLForm.Tables[ - 1]) Then
            If Assigned(FDCLForm.Tables[ - 1].TableParts[v2]) Then
              If FDCLForm.Tables[ - 1].Query.Active Then
                TranslateVals(tmp2, FDCLForm.Tables[ - 1].TableParts[v2].Query);
        end
        Else
          TranslateValContext(tmp2);

        TranslateValContext(tmp2);
        FDCLLogOn.Variables.Variables[VarName]:=tmp2;
      end
      Else
        FDCLLogOn.Variables.Variables[VarName]:='';
  end;

  If (PosEx('ReturnQuery=', S)<>0)or(PosEx('SQL=', S)<>0) Then
  begin
    SQLText:=FindParam('ReturnQuery=', S);
    If SQLText='' Then
      SQLText:=FindParam('SQL=', S);
    TranslateValContext(SQLText);
    If SQLText<>'' Then
    begin
      DCLQuery:=TDCLDialogQuery.Create(nil);
      DCLQuery.Name:='SetVal_Ret'+IntToStr(UpTime);
      FDCLLogOn.SetDBName(DCLQuery);

      {$IFDEF TRANSACTIONDB}
      tmp_Transaction:=FDCLLogOn.NewTransaction(trtWrite);
      DCLQuery.Transaction:=tmp_Transaction;
      tmp_Transaction.StartTransaction;
      {$ENDIF}

      DCLQuery.SQL.Text:=SQLText;
      Screen.Cursor:=crSQLWait;
      try
        DCLQuery.Open;
      Except
        Screen.Cursor:=crDefault;
        ShowErrorMessage( - 1105, 'SQL='+SQLText);
      end;
      Screen.Cursor:=crDefault;

      ReturnField:=FindParam('ReturnField=', S);
      DeleteNonPrintSimb(ReturnField);

      TranslateValContext(ReturnField);

      If ReturnField='' Then
        ReturnField:=DCLQuery.Fields[0].FieldName;

      tmp2:=FindParam('SetValue=', S);
      sv_v2:=Pos('=', tmp2)-1;
      If sv_v2<=0 Then
        sv_v2:=Length(tmp2);
      tmp1:=Copy(LowerCase(tmp2), 1, sv_v2);

      tmp2:=TrimRight(DCLQuery.FieldByName(ReturnField).AsString);
      TranslateValContext(tmp2);
      DCLQuery.Close;

      FDCLLogOn.Variables.NewVariable(tmp1, tmp2);

      {$IFDEF TRANSACTIONDB}
      tmp_Transaction.Commit;
      FreeAndNil(tmp_Transaction);
      {$ENDIF}
      FreeAndNil(DCLQuery);
    end;
  end;

  If FDCLLogOn.FormsCount>0 Then
    For v2:=0 to FDCLLogOn.FormsCount-1 do
    begin
      If Assigned(FDCLLogOn.Forms[v2]) Then
      begin
        For sv_v2:=1 to Length(FDCLLogOn.Forms[v2].FGrids) do
        begin
          If Assigned(FDCLLogOn.Forms[v2].FGrids[sv_v2-1]) Then
            For i:=1 to Length(FDCLLogOn.Forms[v2].FGrids[sv_v2-1].Edits) do
            begin
              Case FDCLLogOn.Forms[v2].FGrids[sv_v2-1].Edits[i-1].EditsType of
              fbtOutBox, fbtEditBox:
              FDCLLogOn.Forms[v2].FGrids[sv_v2-1].Edits[i-1].Edit.Text:=
                FDCLLogOn.Variables.Variables[FDCLLogOn.Forms[v2].FGrids[sv_v2-1].Edits[i-1]
                  .EditToVariables];
              end;
            end;

          If Assigned(FDCLLogOn.Forms[v2]) Then
            If Assigned(FDCLLogOn.Forms[v2].FGrids[sv_v2-1]) Then
              For v0:=1 to Length(FDCLLogOn.Forms[v2].FGrids[sv_v2-1].FTableParts) do
                If Length(FDCLLogOn.Forms[v2].FGrids[sv_v2-1].FTableParts[v0-1].Edits)>0 Then
                begin
                  For i:=1 to Length(FDCLLogOn.Forms[v2].FGrids[sv_v2-1].Edits) do
                  begin
                    Case FDCLLogOn.Forms[v2].FGrids[sv_v2-1].FTableParts[v0-1].Edits[i-1]
                      .EditsType of
                    fbtOutBox, fbtEditBox:
                    FDCLLogOn.Forms[v2].FGrids[sv_v2-1].FTableParts[v0-1].Edits[i-1].Edit.Text:=
                      FDCLLogOn.Variables.Variables
                      [FDCLLogOn.Forms[v2].FGrids[sv_v2-1].FTableParts[v0-1].Edits[i-1]
                        .EditToVariables];
                    end;
                  end;
                end;
        end;
      end;
    end;
end;

procedure TDCLCommand.SetVariable(VarName, VValue: String);
begin
  If Assigned(FDCLForm) Then
    FDCLForm.SetVariable(VarName, VValue)
  Else If FDCLLogOn.Variables.Exists(VarName) Then
    FDCLLogOn.Variables.Variables[VarName]:=VValue;
end;

procedure TDCLCommand.TranslateVals(var Params: String; Query: TDCLDialogQuery);
var
  Factor:Word;
begin
  RePlaseParams_(Params, Query);
  RePlaseVariabless(Params);
  Factor:=0;
  TranslateProc(Params, Factor, Query);
end;

procedure TDCLCommand.TranslateValContext(var Params: String);
begin
  If Assigned(FDCLForm) Then
  begin
    If Assigned(FDCLForm.CurrentQuery) Then
      TranslateVals(Params, FDCLForm.CurrentQuery);
  end
  Else
    TranslateVals(Params, nil);
end;

constructor TDCLCommand.Create(DCLForm: TDCLForm; var DCLLogOn: TDCLLogOn);
begin
  FCommandDCL:=TStringList.Create;
  FDCLLogOn:=DCLLogOn;
  FDCLForm:=DCLForm;

  DCLQuery:=TDCLDialogQuery.Create(nil);
  DCLQuery.Name:='Command_'+IntToStr(UpTime);
  FDCLLogOn.SetDBName(DCLQuery);

  DCLQuery2:=TDCLDialogQuery.Create(nil);
  DCLQuery2.Name:='Command2_'+IntToStr(UpTime);
  FDCLLogOn.SetDBName(DCLQuery2);

  Spool:=TStringList.Create;
  SpoolFileName:=IncludeTrailingPathDelimiter(AppConfigDir)+'Spool.txt';
end;

destructor TDCLCommand.Destroy;
begin
  FDCLLogOn.SQLMon.DelTrace(DCLQuery);
  FDCLLogOn.SQLMon.DelTrace(DCLQuery2);

  If Assigned(DCLQuery) Then
    FreeAndNil(DCLQuery);
  If Assigned(DCLQuery2) Then
    FreeAndNil(DCLQuery2);
end;

procedure TDCLCommand.ExecCommand(Command: String; DCLForm: TDCLForm);
var
  ModalOpen, InContext, Enything, EnythingElse, DownLoadCancel, DownloadProgress: Boolean;
  IfCounter, IfSign: Byte;
  RecCount, ScriptStrings, RetPoint, v1, v2, v3, RepIdParams: Integer;
  ScrStr, TmpStr, tmpStr1, tmpStr2, tmpStr3, tmp1, tmp2, tmp3, tmp4, RepTable: String;
  ChooseMode: TChooseMode;
  ReturnValueParams: TReturnValueParams;
  OpenDialog: TOpenDialog;
  SaveDialog: TSaveDialog;
  tmpDCL: TStringList;
  LocalCommand: TDCLCommand;
  Sign:TSigns;
  tmpDCLForm:TDCLForm;
  nextLine:Boolean;

  procedure GotoGoto(LabelName: String);
  var
    StringNum: Integer;
  begin
    For StringNum:=0 to FCommandDCL.Count-1 do
      If CompareString(FCommandDCL[StringNum], ':'+LabelName+';') Then
      begin
        ScriptStrings:=StringNum;
        break;
      end;
  end;

  procedure SetRetPoint;
  begin
    RetPoint:=ScriptStrings;
  end;

  procedure GetRetPoint;
  begin
    If RetPoint<> - 1 Then
    begin
      ScriptStrings:=RetPoint-1;
    end;
  end;

begin
  FDCLLogOn.SQLMon.AddTrace(DCLQuery);
  FDCLLogOn.SQLMon.AddTrace(DCLQuery2);
  IfCounter:=0;

  If FDCLLogOn.RoleOK<>lsLogonOK Then
    Exit;
  FDCLForm:=DCLForm;
  FDCLLogOn.NotifyForms(fnaPauseAutoRefresh);
  Command:=Trim(Command);
  Executed:=False;
  InContext:=Assigned(FDCLForm);

  If CompareString(Command, 'Choose') Then
  begin
    If Assigned(FDCLForm) Then
      FDCLForm.ChooseAndClose(chmChoose);
    Executed:=True;
  end;

  If CompareString(Command, 'ChooseAndClose') Then
  begin
    If Assigned(FDCLForm) Then
      FDCLForm.ChooseAndClose(chmChooseAndClose);
    Executed:=True;
  end;

  If CompareString(Command, 'Close') Then
  begin
    If Assigned(FDCLForm) Then
    begin
      FDCLForm.NotDestroyedDCLForm:=False;
      FDCLForm.CloseDialog;
    end;
    Executed:=True;
  end;

  If CompareString(Command, 'CloseDialog') Then
  begin
    If Assigned(FDCLForm) Then
    begin
      FDCLForm.NotDestroyedDCLForm:=False;
      FDCLForm.CloseDialog;
      FDCLForm.CloseAction:=fcaClose;
    end;
    Executed:=True;
  end;

  If CompareString(Command, 'Structure') Then
  begin
    FDCLForm.Tables[FDCLForm.CurrentGridIndex].Structure(nil);
    Executed:=True;
  end;

  If CompareString(Command, 'find') Then
  begin
    FDCLForm.Tables[FDCLForm.CurrentGridIndex].PFind(nil);
    Executed:=True;
  end;

  If CompareString(Command, 'print') Then
  begin
    FDCLForm.Tables[FDCLForm.CurrentGridIndex].Print(nil);
    Executed:=True;
  end;

  If CompareString(Command, 'SaveDB') Then
  begin
    If Assigned(FDCLForm) Then
      FDCLForm.Tables[ - 1].SaveDB;
    Executed:=True;
  end;

  If CompareString(Command, 'CancelDB') Then
  begin
    If Assigned(FDCLForm) Then
    begin
      FDCLForm.Tables[ - 1].CancelDB;
    end;
    Executed:=True;
  end;

  If CompareString(Command, 'PostClose') Then
  begin
    If Assigned(FDCLForm.CurrentQuery) then
    Begin
      If FDCLForm.CurrentQuery.State in dsEditModes Then
        FDCLForm.CurrentQuery.Post;
      If Assigned(FDCLForm) Then
        FDCLForm.CloseAction:=fcaClose;
    End;
    Executed:=True;
  end;

  If CompareString(Command, 'CancelClose') Then
  begin
    If Assigned(FDCLForm.CurrentQuery) then
    Begin
      If FDCLForm.CurrentQuery.State in dsEditModes Then
        FDCLForm.CurrentQuery.Cancel;
      If Assigned(FDCLForm) Then
        FDCLForm.CloseAction:=fcaClose;
    End;
    Executed:=True;
  end;

  If CompareString(Command, 'Post') Then
  begin
    If Assigned(FDCLForm.CurrentQuery) then
    If FDCLForm.CurrentQuery.State in dsEditModes Then
      FDCLForm.CurrentQuery.Post;
    Executed:=True;
  end;

  If CompareString(Command, 'Cancel') Then
  begin
    If Assigned(FDCLForm.CurrentQuery) then
    If FDCLForm.CurrentQuery.State in dsEditModes Then
      FDCLForm.CurrentQuery.Cancel;
    Executed:=True;
  end;

  If CompareString(Command, 'Delete') Then
  begin
    If Assigned(FDCLForm.CurrentQuery) then
    If GetRaightsByContext(InContext)>ulReadOnly Then
//      FDCLForm.FGrids[FDCLForm.CurrentGridIndex].DataSource.DataSet.Delete;
      FDCLForm.CurrentQuery.Delete;
    Executed:=True;
  end;

  If CompareString(Command, 'DeleteConf') Then
  begin
    If Assigned(FDCLForm.CurrentQuery) then
    If GetRaightsByContext(InContext)>ulReadOnly Then
      If ShowErrorMessage(10, GetDCLMessageString(msDeleteRecordQ))=1 Then
        FDCLForm.CurrentQuery.Delete;
    Executed:=True;
  end;

  If CompareString(Command, 'Insert') Then
  begin
    If Assigned(FDCLForm.CurrentQuery) then
    If GetRaightsByContext(InContext)>ulReadOnly Then
      FDCLForm.CurrentQuery.Insert;
    Executed:=True;
  end;

  If CompareString(Command, 'Append') Then
  begin
    If Assigned(FDCLForm.CurrentQuery) then
    If GetRaightsByContext(InContext)>ulReadOnly Then
      FDCLForm.CurrentQuery.Append;
    Executed:=True;
  end;

  // ==============================================================
  If CompareString(Command, 'Post_Part') Then
  begin
    If Assigned(FDCLForm.CurrentQuery) then
    If FDCLForm.CurrentPartQuery.State in dsEditModes Then
      FDCLForm.CurrentPartQuery.Post;
    Executed:=True;
  end;

  If CompareString(Command, 'Delete_Part') Then
  begin
    If Assigned(FDCLForm.CurrentQuery) then
    If GetRaightsByContext(InContext)>ulReadOnly Then
      FDCLForm.CurrentPartQuery.Delete;
    Executed:=True;
  end;

  If CompareString(Command, 'DeleteConf_Part') Then
  begin
    If Assigned(FDCLForm.CurrentPartQuery) then
    If GetRaightsByContext(InContext)>ulReadOnly Then
      If ShowErrorMessage(10, GetDCLMessageString(msDeleteRecordQ))=1 Then
        FDCLForm.CurrentPartQuery.Delete;
    Executed:=True;
  end;

  If CompareString(Command, 'Cancel_Part') Then
  begin
    If Assigned(FDCLForm.CurrentPartQuery) then
    FDCLForm.CurrentPartQuery.Cancel;
    Executed:=True;
  end;

  If CompareString(Command, 'Insert_Part') Then
  begin
    If Assigned(FDCLForm.CurrentPartQuery) then
    If GetRaightsByContext(InContext)>ulReadOnly Then
      FDCLForm.CurrentPartQuery.Insert;
    Executed:=True;
  end;

  If CompareString(Command, 'Append_Part') Then
  begin
    If Assigned(FDCLForm.CurrentPartQuery) then
    If GetRaightsByContext(InContext)>ulReadOnly Then
      FDCLForm.CurrentPartQuery.Append;
    Executed:=True;
  end;
  // ==============================================================

  If CompareString(Command, 'ClearAllContextFilters') Then
  begin
    If Assigned(FDCLForm) Then
      If Length(FDCLForm.Tables[ - 1].DBFilters)>0 Then
        For v1:=1 to Length(FDCLForm.Tables[ - 1].DBFilters) do
        begin
          If FDCLForm.Tables[ - 1].DBFilters[v1-1].FilterType=ftContextFilter Then
            If Assigned(FDCLForm.Tables[ - 1].DBFilters[v1-1].Edit) Then
              FDCLForm.Tables[ - 1].DBFilters[v1-1].Edit.Clear;
        end;
    Executed:=True;
  end;

  If CompareString(Command, 'About')or CompareString(Command, 'Version') Then
  begin
    FDCLLogOn.About(nil);
    Executed:=True;
  end;

  If CompareString(Command, 'Lock') Then
  begin
    FDCLLogOn.Lock;
    Executed:=True;
  end;

  If CompareString(Command, 'ExtractScript') Then
  begin
    If FDCLLogOn.AccessLevel>=ulReadOnly Then
    begin
      OpenDialog:=TOpenDialog.Create(nil);
      OpenDialog.DefaultExt:=SignedScriptExt;
      OpenDialog.Filter:='DCL script files|*'+SignedScriptExt;
      If OpenDialog.Execute Then
        ExtractScriptFile(OpenDialog.FileName);
      FreeAndNil(OpenDialog);
    end;
    Executed:=True;
  end;

  If CompareString(Command, 'OpenScript') Then
  begin
    If FDCLLogOn.AccessLevel>=ulReadOnly Then
    begin
      OpenDialog:=TOpenDialog.Create(nil);
      OpenDialog.DefaultExt:=SignedScriptExt;
      OpenDialog.Filter:='DCL script files|*'+SignedScriptExt;
      If OpenDialog.Execute Then
        RunSkriptFromFile(OpenDialog.FileName);
      FreeAndNil(OpenDialog);
    end;
    Executed:=True;
  end;

  If CompareString(Command, 'SignScript') Then
  begin
    If FDCLLogOn.AccessLevel=ulDeveloper Then
    begin
      OpenDialog:=TOpenDialog.Create(nil);
      OpenDialog.DefaultExt:=TextScriptFileExt;
      OpenDialog.Filter:='DCL script text|*'+TextScriptFileExt;
      If OpenDialog.Execute Then
        FDCLLogOn.SignScriptFile(OpenDialog.FileName, GPT.DCLUserName);
      FreeAndNil(OpenDialog);
    end;
    Executed:=True;
  end;

  If CompareString(Command, 'SQLMon_Clear') Then
  begin
    FDCLLogOn.SQLMon.Clear;
    Executed:=True;
  end;

  If CompareString(Command, 'SQLMon') Then
  begin
    FDCLLogOn.SQLMon.TrraceStatus:=Not FDCLLogOn.SQLMon.TrraceStatus;
    Executed:=True;
  end;

  If Not Executed Then
  begin
    RecCount:=0;
    If Pos('''', Command)=0 Then
      If Pos(#10, Command)=0 Then
      begin
        v1:=FDCLLogOn.FindVirtualScript(Command);
        If v1=-1 then
        Begin
          DCLQuery.Close;
          DCLQuery.SQL.Text:='select Count(*) from '+GPT.DCLTable+' where '+GPT.UpperString+
            GPT.DCLNameField+GPT.UpperStringEnd+'='+GPT.UpperString+GPT.StringTypeChar+Command+
            GPT.StringTypeChar+GPT.UpperStringEnd;
          try
            DCLQuery.Open;
            RecCount:=DCLQuery.Fields[0].AsInteger;
            DCLQuery.Close;
          Except
            DCLQuery.SQL.Clear;
            RecCount:=0;
          end;
          If RecCount>0 Then
          begin
            DCLQuery.Close;
            DCLQuery.SQL.Text:='select * from '+GPT.DCLTable+' where '+GPT.UpperString+
              GPT.DCLNameField+GPT.UpperStringEnd+'='+GPT.UpperString+GPT.StringTypeChar+Command+
              GPT.StringTypeChar+GPT.UpperStringEnd;
            DCLQuery.Open;
          end;
        End
        Else
        Begin
          Command:=FDCLLogOn.GetVirtualScriptNum(v1).ScrText;
        End;
      end;

    If RecCount=0 Then
    begin
      FCommandDCL.Clear;
      FCommandDCL.Text:=Command;
      /// DebugProc('Попытка исполнить команду: '+Command);
      /// If PosEx('script type=visual', FCommandDCL[0])<>0 Then Open(Nil, Nil, Nil, '', FCommandDCL);
    end
    Else
    begin
      FCommandDCL.Text:=DCLQuery.FieldByName(GPT.DCLTextField).AsString;
    end;
    DCLQuery.Close;

    StopFlag:=False;
    Breaking:=False;

    If FCommandDCL.Count<>0 Then
    begin
      GPT.CurrentRunningCmdString:=0;
      ScriptStrings:=0;
      RetPoint:= - 1;
      While ScriptStrings<FCommandDCL.Count do
      begin
        GPT.CurrentRunningCmdString:=ScriptStrings;

        ScrStr:=FCommandDCL[ScriptStrings];

        nextLine:=False;
        If Pos('//', ScrStr)=1 Then
        begin
          nextLine:=True;
        end;

        if not nextLine then
        begin
          TranslateValContext(ScrStr);

          If Not StopFlag Then
          begin
            If (PosEx('About;', ScrStr)=1)or(PosEx('Version;', ScrStr)=1) Then
            begin
              FDCLLogOn.About(nil);
            end;

            If PosEx('Lock;', ScrStr)=1 Then
            begin
              FDCLLogOn.Lock;
            end;

            If PosEx('GetScreen=', ScrStr)=1 Then
            begin
              tmpStr1:=FindParam('Qlty=', ScrStr);
              TmpStr:=FindParam('FileName=', ScrStr);
              If TmpStr<>'' then
              begin
                If tmpStr1<>'' then
                  ConvertToJPEG(GetScreen, StrToIntDef(tmpStr1, JPEGCompressionQuality)).SaveToFile(TmpStr)
                Else
                  GetScreen.SaveToFile(TmpStr);
              end;
            end;

            If PosEx('ExtractScript;', ScrStr)=1 Then
            begin
              If FDCLLogOn.AccessLevel>=ulReadOnly Then
              begin
                OpenDialog:=TOpenDialog.Create(nil);
                OpenDialog.DefaultExt:=SignedScriptExt;
                OpenDialog.Filter:='DCL script files|*'+SignedScriptExt;
                If OpenDialog.Execute Then
                  ExtractScriptFile(OpenDialog.FileName);
                FreeAndNil(OpenDialog);
              end;
            end;

            If PosEx('ExtractScript=', ScrStr)=1 Then
            begin
              If FDCLLogOn.AccessLevel>=ulReadOnly Then
              begin
                tmp1:=FindParam('FileName=', ScrStr);
                ExtractScriptFile(tmp1);
              end;
            end;

            If PosEx('OpenScript;', ScrStr)=1 Then
            begin
              If FDCLLogOn.AccessLevel>=ulReadOnly Then
              begin
                OpenDialog:=TOpenDialog.Create(nil);
                OpenDialog.DefaultExt:=SignedScriptExt;
                OpenDialog.Filter:='DCL script files|*'+SignedScriptExt;
                If OpenDialog.Execute Then
                  RunSkriptFromFile(OpenDialog.FileName);
                FreeAndNil(OpenDialog);
              end;
            end;

            If PosEx('OpenScript=', ScrStr)=1 Then
            begin
              If FDCLLogOn.AccessLevel>=ulReadOnly Then
              begin
                tmp1:=FindParam('FileName=', ScrStr);
                RunSkriptFromFile(tmp1);
              end;
            end;

            If PosEx('SignScript;', ScrStr)=1 Then
            begin
              If FDCLLogOn.AccessLevel=ulDeveloper Then
              begin
                OpenDialog:=TOpenDialog.Create(nil);
                OpenDialog.DefaultExt:=TextScriptFileExt;
                OpenDialog.Filter:='DCL script text|*'+TextScriptFileExt;
                If OpenDialog.Execute Then
                  FDCLLogOn.SignScriptFile(OpenDialog.FileName, GPT.DCLUserName);
                FreeAndNil(OpenDialog);
              end;
            end;

            If PosEx('SignScript=', ScrStr)=1 Then
            begin
              If FDCLLogOn.AccessLevel=ulDeveloper Then
              begin
                tmp1:=FindParam('FileName=', ScrStr);
                FDCLLogOn.SignScriptFile(tmp1, GPT.DCLUserName);
              end;
            end;

            If PosEx('ReSignScript;', ScrStr)=1 Then
            begin
              If FDCLLogOn.AccessLevel=ulDeveloper Then
              begin
                OpenDialog:=TOpenDialog.Create(nil);
                OpenDialog.DefaultExt:=SignedScriptExt;
                OpenDialog.Filter:='DCL script files|*'+SignedScriptExt;
                If OpenDialog.Execute Then
                  FDCLLogOn.ReSignScriptFile(OpenDialog.FileName);
                FreeAndNil(OpenDialog);
              end;
            end;

            If PosEx('ReSignScript=', ScrStr)=1 Then
            begin
              If FDCLLogOn.AccessLevel=ulDeveloper Then
              begin
                tmp1:=FindParam('FileName=', ScrStr);
                FDCLLogOn.ReSignScriptFile(tmp1);
              end;
            end;

            If PosEx('ExecCommand=', ScrStr)=1 Then
            begin
              tmp1:=FindParam('ExecCommand=', ScrStr);
              LocalCommand:=TDCLCommand.Create(FDCLForm, FDCLLogOn);
              LocalCommand.ExecCommand(tmp1, FDCLForm);
              FreeAndNil(LocalCommand);
            end;

            If PosEx('SeparateChar=', ScrStr)=1 Then
            begin
              GPT.StringTypeChar:=FindParam('SeparateChar=', ScrStr);
            end;

            If PosEx('SetValueSeparator=', ScrStr)=1 Then
            begin
              GPT.GetValueSeparator:=FindParam('SetValueSeparator=', ScrStr);
            end;

            If PosEx('Export=', ScrStr)=1 Then
            begin
              TmpStr:=FindParam('Spool=', ScrStr);
              If TmpStr='' Then
                TmpStr:='0';
              If TmpStr='1' Then
              begin
                ExportData(stSpool, ScrStr);
                Spool.SaveToFile(SpoolFileName);
              end;
              If TmpStr='0' Then
                ExportData(stText, ScrStr);
            end;

            If PosEx('DialogByName=', ScrStr)=1 Then
            begin
              TmpStr:=FindParam('DialogByName=', ScrStr);
              tmpStr1:=Copy(TmpStr, 1, Pos('.', TmpStr)-1);
              tmpStr2:=Copy(TmpStr, Pos('.', TmpStr)+1, Length(TmpStr));
              Enything:=False;
              v2:= - 1;
              For v1:=1 to FDCLLogOn.FormsCount do
              begin
                If CompareString(FDCLLogOn.Forms[v1-1].DialogName, tmpStr1) Then
                begin
                  Enything:=True;
                  v2:=v1;
                  break;
                end;
              end;
              If Enything Then
              begin
                If CompareString(tmpStr2, 'hide') Then
                  FDCLLogOn.Forms[v2].FForm.Hide;
                If CompareString(tmpStr2, 'show') Then
                  FDCLLogOn.Forms[v2].FForm.Show;
                If CompareString(tmpStr2, 'close') Then
                Begin
                  If Assigned(FDCLLogOn.Forms[v2]) then
                  Begin
                    tmpDCLForm:=FDCLLogOn.Forms[v2].GetParentForm;
                    FDCLLogOn.Forms[v2].Free;
                    FDCLForm:=tmpDCLForm;
                  End;
                End;
                If CompareString(tmpStr2, 'refresh') Then
                begin
                  For v3:=1 to FDCLLogOn.Forms[v2].GetTablesCount do
                    FDCLLogOn.Forms[v2].Tables[v3-1].ReFreshQuery;
                end;
              end;
            end;

            If PosEx('NoCloseable=', ScrStr)=1 Then
            begin
              TmpStr:=FindParam('NoCloseable=', ScrStr);
              If Assigned(FDCLForm) Then
              Begin
                FDCLForm.NoCloseable:=Trim(TmpStr)='1';
              End;
            end;

            If PosEx('Navigator=', ScrStr)=1 Then
            begin
              If FindParam('Navigator=', ScrStr)='0' Then
              begin
                If Assigned(FDCLForm.Tables[ - 1].Navig) Then
                begin
                  FDCLForm.Tables[ - 1].Navig.Hide;
                end;
              end
              Else
              begin
                If FindParam('buttons=', ScrStr)<>'' Then
                begin
                  TmpStr:=FindParam('buttons=', ScrStr);
                  For v1:=1 to 10 do
                    NavigVisiButtonsVar[v1]:=[];
                  If PosEx('first', TmpStr)<>0 Then
                    NavigVisiButtonsVar[1]:=[nbFirst];
                  If PosEx('prior', TmpStr)<>0 Then
                    NavigVisiButtonsVar[2]:=[nbPrior];
                  If PosEx('next', TmpStr)<>0 Then
                    NavigVisiButtonsVar[3]:=[nbNext];
                  If PosEx('last', TmpStr)<>0 Then
                    NavigVisiButtonsVar[4]:=[nbLast];
                  If PosEx('insert', TmpStr)<>0 Then
                    NavigVisiButtonsVar[5]:=[nbInsert];
                  If PosEx('delete', TmpStr)<>0 Then
                    NavigVisiButtonsVar[6]:=[nbDelete];
                  If PosEx('edit', TmpStr)<>0 Then
                    NavigVisiButtonsVar[7]:=[nbEdit];
                  If PosEx('post', TmpStr)<>0 Then
                    NavigVisiButtonsVar[8]:=[nbPost];
                  If PosEx('cancel', TmpStr)<>0 Then
                    NavigVisiButtonsVar[9]:=[nbCancel];
                  If PosEx('refresh', TmpStr)<>0 Then
                    NavigVisiButtonsVar[10]:=[nbRefresh];
                  FDCLForm.Tables[ - 1].Navig.VisibleButtons:=NavigVisiButtonsVar[1]+
                    NavigVisiButtonsVar[2]+NavigVisiButtonsVar[3]+NavigVisiButtonsVar[4]+
                    NavigVisiButtonsVar[5]+NavigVisiButtonsVar[6]+NavigVisiButtonsVar[7]+
                    NavigVisiButtonsVar[8]+NavigVisiButtonsVar[9]+NavigVisiButtonsVar[10];
                end;
                If FindParam('Flat=', ScrStr)<>'' Then
                begin
                  TmpStr:=FindParam('Flat=', ScrStr);
                  If TmpStr='1' Then
                    FDCLForm.Tables[ - 1].Navig.Flat:=True;
                end;
              end;
            end;

  {$IFDEF DELPHI}
            If PosEx('ParamCheck=', ScrStr)=1 Then
            begin
              TmpStr:=FindParam('ParamCheck=', ScrStr);
              If TmpStr='1' Then
                FDCLForm.Tables[ - 1].Query.ParamCheck:=True;
              If TmpStr='0' Then
                FDCLForm.Tables[ - 1].Query.ParamCheck:=False;
            end;
  {$ENDIF}
            If PosEx('DisableParams=', ScrStr)=1 Then
            begin
              If FindParam('DisableParams=', ScrStr)='1' Then
                TransParams:=True;

              If FindParam('DisableParams=', ScrStr)='0' Then
                TransParams:=False;
            end;

  {$IFDEF DELPHI}
            If PosEx('FieldsList=', ScrStr)=1 Then
            begin
              tmp1:=FindParam('FieldsList=', ScrStr);
              If Not IsFullPAth(tmp1) Then
                tmp1:=IncludeTrailingPathDelimiter(AppConfigDir)+tmp1;

              FDCLForm.Tables[ - 1].Query.FieldList.SaveToFile(tmp1);
            end;
  {$ENDIF}
            If PosEx('SetContextFilterText=', ScrStr)=1 Then
            begin
              TmpStr:=FindParam('ComponentName=', ScrStr);
              If TmpStr='' Then
              begin
                TmpStr:=FindParam('ComponentNumber=', ScrStr);
                If TmpStr='' Then
                  TmpStr:='ContextFilter_1'
                Else
                  TmpStr:='ContextFilter_'+TmpStr;
              end;
              If Assigned(FDCLForm) Then
                If Assigned(FDCLForm.Tables[ - 1].ToolPanel) Then
                  If Assigned(FDCLForm.Tables[ - 1].ToolPanel.FindComponent(TmpStr)) Then
                  begin
                    tmpStr1:=FindParam('SetContextFilterText=', ScrStr);
                    RePlaseVariabless(tmpStr1);
                    (FDCLForm.Tables[ - 1].ToolPanel.FindComponent(TmpStr) as TEdit).Text:=tmpStr1;
                  end;
            end;

            If PosEx('ClearAllContextFilters;', ScrStr)=1 Then
            begin
              If Assigned(FDCLForm) Then
                If Length(FDCLForm.Tables[ - 1].DBFilters)>0 Then
                  For v1:=1 to Length(FDCLForm.Tables[ - 1].DBFilters) do
                  begin
                    If FDCLForm.Tables[ - 1].DBFilters[v1-1].FilterType=ftContextFilter Then
                      If Assigned(FDCLForm.Tables[ - 1].DBFilters[v1-1].Edit) Then
                        FDCLForm.Tables[ - 1].DBFilters[v1-1].Edit.Clear;
                  end;
            end;

            If PosEx('DownloadHTTP=', ScrStr)=1 Then
            begin
              TmpStr:=FindParam('DownloadHTTP=', ScrStr);
              tmpStr1:=FindParam('Path=', ScrStr);
              tmpStr2:=FindParam('FileName=', ScrStr);
              Downloader:=TDownloader.Create;

              If tmpStr1='' Then
              begin
                If tmpStr2='' Then
                  tmp1:=ExtractFileName(TmpStr)
                Else
                  tmp1:=tmpStr2;
              end
              Else
                TmpStr:=tmpStr1+ExtractFileName(TmpStr);

              If FindParam('Progress=', ScrStr)='1' Then
                DownloadProgress:=True
              Else
                DownloadProgress:=False;

              If FindParam('Cancel=', ScrStr)='1' Then
                DownLoadCancel:=True
              Else
                DownLoadCancel:=False;

              DownLoadProcess:=True;
              tmpStr2:=Trim(FindParam('Reset=', ScrStr));
              If tmpStr2='1' Then
                Downloader.DownLoadHTTP(TmpStr, tmp1, True, DownloadProgress, DownLoadCancel)
              Else
                Downloader.DownLoadHTTP(TmpStr, tmp1, False, DownloadProgress, DownLoadCancel);
              DownLoadProcess:=False;

              Sleep(100);
              Downloader.Free;
            end;

            If PosEx('Execute=', ScrStr)=1 Then
            begin
              If GetRaightsByContext(InContext)>ulReadOnly Then
              Begin
                TmpStr:=FindParam('execute=', ScrStr);

                tmpStr1:=FindParam('WorkDir=', ScrStr);
                If tmpStr1='' Then
                  tmpStr1:=Path;

                If Not DirectoryExists(tmpStr1) Then
                  SetCurrentDir(Path)
                Else
                  SetCurrentDir(tmpStr1);

                try
                  If FindParam('Wait=', ScrStr)='1' Then
                  Begin
                    If Not ExecAndWait(TmpStr, SW_SHOWNORMAL, True) Then
                      ShowErrorMessage( - 8000, tmpStr1+TmpStr);
                  End
                  Else If FindParam('ShellExec=', ScrStr)='1' Then
                    Exec(TmpStr, tmpStr1)
                  Else
                    ExecApp(TmpStr);
                Except
                  ShowErrorMessage( - 8000, tmpStr1+TmpStr);
                end;
              End
              Else
                ShowErrorMessage(0, GetDCLMessageString(msNotAllowExecuteApps));
            end;

            If PosEx('Sleep=', ScrStr)=1 Then
            begin
              TmpStr:=FindParam('Sleep=', ScrStr);
              Sleep(StrToIntEx(TmpStr));
            end;

            If PosEx('Beep;', ScrStr)=1 Then
            begin
  {$IFDEF MSWINDOWS}
              Windows.Beep(500, 250)
  {$ELSE}
              Beep;
  {$ENDIF};
            end;

            If PosEx('Beep=', ScrStr)=1 Then
            begin
              TmpStr:=FindParam('Beep=', ScrStr);
              v1:=Pos(',', TmpStr);
              tmpStr1:=Copy(TmpStr, 1, v1-1);
              Delete(TmpStr, 1, v1);
              tmpStr2:=TmpStr;
  {$IFDEF MSWINDOWS}
              Windows.Beep(StrToIntEx(tmpStr1), StrToIntEx(tmpStr2));
  {$ELSE}
              Beep;
  {$ENDIF};
            end;

            If PosEx('ReOpen;', ScrStr)=1 Then
            begin
              If Assigned(FDCLForm) Then
                FDCLForm.RefreshForm;
            end;

            If PosEx('ReConnect;', ScrStr)=1 Then
            begin
              FDCLLogOn.ReconnectDB;
            end;

            If PosEx('GotoKey=', ScrStr)=1 Then
            begin
              TmpStr:=FindParam('KeyField=', ScrStr);
              tmpStr1:=FindParam('GotoKey=', ScrStr);
              If Assigned(FDCLForm.CurrentQuery) Then
                FDCLForm.CurrentQuery.Locate(tmpStr1, TmpStr, [loCaseInsensitive]);
            end;

            If PosEx('Goto=', ScrStr)=1 Then
            begin
              TmpStr:=FindParam('Goto=', ScrStr);
              SetRetPoint;
              GotoGoto(TmpStr);
            end;

            If PosEx('Return;', ScrStr)=1 Then
            begin
              GetRetPoint;
            end;

            If PosEx('Break;', ScrStr)=1 Then
            begin
              ScriptStrings:=FCommandDCL.Count;
            end;

            If PosEx('ExecQuery=', ScrStr)=1 Then
            begin
              TmpStr:=FindParam('ExecQuery=', ScrStr);
              TranslateValContext(TmpStr);
              ExecSQLCommand(TmpStr, InContext);
            end;

            If PosEx('Query=', ScrStr)=1 Then
            begin
              If Assigned(FDCLForm) Then
              begin
                FDCLLogOn.SetDBName(DCLQuery);
                TmpStr:=FindParam('Query=', ScrStr);
                FDCLForm.FGrids[FDCLForm.CurrentGridIndex].SetSQLToStore(TmpStr, qtMain, ulUndefined);
                If Not IsReturningQuery(TmpStr) Then
                begin
                  DCLQuery.Close;
                  DCLQuery.SQL.Text:=TmpStr;
                  If GetRaightsByContext(InContext)>ulWrite Then
                    DCLQuery.ExecSQL;
                end
                Else
                  try
                    FDCLForm.CurrentQuery.SQL.Text:=TmpStr;
                    FDCLForm.CurrentQuery.Open;
                  Except
                    ShowErrorMessage( - 1100);
                  end;
              end;
            end;

            If PosEx('GlobQuery=', ScrStr)=1 Then
            begin
              If Assigned(FDCLForm) Then
              begin
                FDCLForm.CurrentQuery.DisableControls;

                TmpStr:=FindParam('GlobQuery=', ScrStr);
                FDCLForm.FGrids[FDCLForm.CurrentGridIndex].SetSQLToStore(TmpStr, qtMain, ulUndefined);
                TranslateValContext(TmpStr);
                FDCLForm.FGrids[FDCLForm.CurrentGridIndex].Close;
                FDCLForm.FGrids[FDCLForm.CurrentGridIndex].SetSQL(TmpStr);
                try
                  FDCLForm.FGrids[FDCLForm.CurrentGridIndex].Open;
                Except
                  ShowErrorMessage( - 1113, 'SQL='+TmpStr);
                end;
                FDCLForm.CurrentQuery.EnableControls;
              end;
            end;

            If PosEx('MultiSelect=', ScrStr)=1 Then
            begin
              If Assigned(FDCLForm) Then
                FDCLForm.Tables[ - 1].MultiSelect:=FindParam('MultiSelect=', ScrStr)='1';
            end;

            If PosEx('TablePartQuery=', ScrStr)=1 Then
            begin
              If Assigned(FDCLForm) Then
              begin
                v1:=1;
                TmpStr:=Trim(FindParam('TablePartNum=', ScrStr));
                If TmpStr<>'' Then
                  v1:=StrToIntEx(TmpStr)-1;

                TmpStr:=FindParam('TablePartQuery=', ScrStr);
                FDCLForm.Tables[ - 1].TableParts[v1].SetSQLToStore(TmpStr, qtMain, ulUndefined);
                FDCLForm.TranslateVal(TmpStr, False);

                FDCLForm.Tables[ - 1].TableParts[v1].Query.SQL.Text:=TmpStr;
                try
                  FDCLForm.Tables[ - 1].TableParts[v1].Query.Open;
                Except
                  ShowErrorMessage( - 1201, 'SQL='+TmpStr);
                end;
              end;
            end;

            If PosEx('Report=', ScrStr)=1 Then
            begin
              tmpDCL:=TStringList.Create;
              RepIdParams:=0;
              RepTable:=FindParam('FromTable=', ScrStr);
              If RepTable='' Then
                RepTable:=GPT.DCLTable;
              tmp1:=FindParam('FromFile=', ScrStr);
              If tmp1='' Then
              begin
                tmp2:=FindParam('ReportName=', ScrStr);
                TranslateVals(tmp2, FDCLForm.CurrentQuery);
                DCLQuery.Close;
                DCLQuery.SQL.Text:='select Count(*) from '+RepTable+' where '+GPT.UpperString+
                  GPT.DCLNameField+GPT.UpperStringEnd+'='+GPT.UpperString+GPT.StringTypeChar+tmp2+
                  GPT.StringTypeChar+GPT.UpperStringEnd;
                DCLQuery.Open;
                RecCount:=DCLQuery.Fields[0].AsInteger;
                If RecCount=1 Then
                begin
                  DCLQuery.Close;
                  DCLQuery.SQL.Text:='select * from '+RepTable+' where '+GPT.UpperString+
                    GPT.DCLNameField+GPT.UpperStringEnd+'='+GPT.UpperString+GPT.StringTypeChar+tmp2+
                    GPT.StringTypeChar+GPT.UpperStringEnd;
                  DCLQuery.Open;
                  tmpDCL.Text:=DCLQuery.FieldByName(GPT.DCLTextField).AsString;
                  RepIdParams:=DCLQuery.FieldByName(GPT.IdentifyField).AsInteger;
                  DCLQuery.Close;
                end;
              end
              Else
              begin
                If Not IsFullPAth(tmp1) Then
                  tmp1:=IncludeTrailingPathDelimiter(AppConfigDir)+tmp1;
                If FileExists(tmp1) Then
                  tmpDCL.LoadFromFile(tmp1);
              end;
              tmp2:=FindParam('QueryMode=', ScrStr);
              v1:=0;
              If LowerCase(tmp2)='bkmode' Then
                v1:=1;
              If LowerCase(tmp2)='main' Then
                v1:=0;
              If LowerCase(tmp2)='isolate' Then
                v1:=2;
              Case v1 of
              0:
                If Assigned(FDCLForm) Then
                  TextReport:=TDCLTextReport.InitReport(FDCLLogOn,
                    FDCLForm.Tables[FDCLForm.CurrentTableIndex], tmpDCL, RepIdParams, nqmFromGrid);
              1:
                If Assigned(FDCLForm) Then
                  TextReport:=TDCLTextReport.InitReport(FDCLLogOn,
                    FDCLForm.Tables[FDCLForm.CurrentTableIndex], tmpDCL, RepIdParams, nqmNew);
              2:
                TextReport:=TDCLTextReport.InitReport(FDCLLogOn, nil, tmpDCL, RepIdParams, nqmNew);
              end;

              If Assigned(TextReport) then
              begin
                If TextReport.DialogRes=mrOk Then
                begin
                  tmp1:=Trim(FindParam('FileName=', ScrStr));
                  TranslateVals(tmp1, FDCLForm.CurrentQuery);
                  If FindParam('ToDos=', ScrStr)='1' Then
                    TextReport.InConsoleCodePage:=True;

                  v1:=StrToIntEx(Trim(FindParam('ViewMode=', ScrStr)));
                  TextReport.OpenReport(tmp1, TReportViewMode(v1));
                  tmp1:=TextReport.SaveReport(tmp1);

                  tmp2:=FindParam('NoPrint=', ScrStr);
                  TranslateVals(tmp2, FDCLForm.CurrentQuery);
                  If TReportViewMode(v1-1)=rvmMultitRecordReport Then
                    tmp2:='1';
                  If tmp2<>'1' Then
                    If FindParam('Viewer=', ScrStr)<>'' Then
                      ExecApp('"'+FindParam('Viewer=', ScrStr)+'" "'+tmp1+'"')
                    Else
                      ExecApp('"'+GPT.Viewer+'" "'+tmp1+'"');
                end;

                TextReport.CloseReport('Report.txt');
              end;
              FreeAndNil(tmpDCL);
            end;

            If PosEx('ReportOfficeSheet=', ScrStr)=1 Then
            begin
              If Assigned(FDCLForm) Then
              begin
                ScrStr:=FCommandDCL[ScriptStrings];
                Enything:=FindParam('Save=', ScrStr)='1';
                EnythingElse:=FindParam('Close=', ScrStr)='1';
                TmpStr:=LowerCase(FindParam('OfficeType=', ScrStr));
                OfficeReport:=TDCLOfficeReport.Create(FDCLLogOn,
                  FDCLForm.Tables[FDCLForm.CurrentTableIndex]);
                OfficeReport.OfficeFormat:=GetPossibleOffice(dtSheet, ConvertOfficeType(TmpStr), GPT.OfficeFormat);

                If FDCLForm.Tables[ - 1].DisplayMode in TDataGrid Then
                begin
                  if FDCLForm.Tables[ - 1].MultiSelect then
                  begin
                    if FDCLForm.Tables[ - 1].Grid.SelectedRows.Count>0 then
                    begin
                      For v1:=0 to FDCLForm.Tables[ - 1].Grid.SelectedRows.Count-1 do
                      begin
                        FDCLForm.Tables[ - 1].FQueryGlob.GoToBookmark(TBookmark(FDCLForm.Tables[ - 1].Grid.SelectedRows[v1]));

                        Case OfficeReport.OfficeFormat of
                        ofOO:
                        OfficeReport.ReportOpenOfficeCalc(ScrStr, Enything, EnythingElse);
                        ofMSO:
                        OfficeReport.ReportExcel(ScrStr, Enything, EnythingElse);
                        ofNone:
                        ShowErrorMessage( - 6200, '');
                        end;
                        end;
                    end;
                  end
                  else
                  begin
                    Case OfficeReport.OfficeFormat of
                    ofOO:
                    OfficeReport.ReportOpenOfficeCalc(ScrStr, Enything, EnythingElse);
                    ofMSO:
                    OfficeReport.ReportExcel(ScrStr, Enything, EnythingElse);
                    ofNone:
                    ShowErrorMessage( - 6200, '');
                    end;
                  end;
                end;
              end;
            end;

            If PosEx('ReportOfficeText=', ScrStr)=1 Then
            begin
              If Assigned(FDCLForm) Then
              begin
                ScrStr:=FCommandDCL[ScriptStrings];
                Enything:=FindParam('Save=', ScrStr)='1';
                EnythingElse:=FindParam('Close=', ScrStr)='1';
                TmpStr:=LowerCase(FindParam('OfficeType=', ScrStr));
                OfficeReport:=TDCLOfficeReport.Create(FDCLLogOn,
                  FDCLForm.Tables[FDCLForm.CurrentTableIndex]);
                OfficeReport.OfficeFormat:=GetPossibleOffice(dtText, ConvertOfficeType(TmpStr), GPT.OfficeFormat);

                If FDCLForm.Tables[ - 1].DisplayMode in TDataGrid Then
                begin
                  if FDCLForm.Tables[ - 1].MultiSelect then
                  begin
                    if FDCLForm.Tables[ - 1].Grid.SelectedRows.Count>0 then
                    begin
                      For v1:=0 to FDCLForm.Tables[ - 1].Grid.SelectedRows.Count-1 do
                      begin
                        FDCLForm.Tables[ - 1].FQueryGlob.GoToBookmark(TBookmark(FDCLForm.Tables[ - 1].Grid.SelectedRows[v1]));

                        Case OfficeReport.OfficeFormat of
                        ofOO:
                        OfficeReport.ReportOpenOfficeWriter(ScrStr, Enything, EnythingElse);
                        ofMSO:
                        OfficeReport.ReportWord(ScrStr, Enything, EnythingElse);
                        ofNone:
                        ShowErrorMessage( - 6200, '');
                        end;
                      end;
                    end;
                  end
                  else
                  begin
                    Case OfficeReport.OfficeFormat of
                    ofOO:
                    OfficeReport.ReportOpenOfficeWriter(ScrStr, Enything, EnythingElse);
                    ofMSO:
                    OfficeReport.ReportWord(ScrStr, Enything, EnythingElse);
                    ofNone:
                    ShowErrorMessage( - 6200, '');
                    end;
                  end;
                end;
              end;
            end;

            If PosEx('OpenFileDialog=', ScrStr)=1 Then
            begin
              tmp1:=FindParam('OpenFileDialog=', ScrStr);
              tmp2:=FindParam('Ext=', ScrStr);
              OpenDialog:=TOpenDialog.Create(nil);
              If tmp2<>'' Then
                OpenDialog.DefaultExt:=tmp2;
              If OpenDialog.Execute Then
                SetVariable(tmp1, OpenDialog.FileName)
              Else
                SetVariable(tmp1, '');
              FreeAndNil(OpenDialog);
            end;

            If PosEx('SaveFileDialog=', ScrStr)=1 Then
            begin
              tmp1:=FindParam('SaveFileDialog=', ScrStr);
              tmp2:=FindParam('Ext=', ScrStr);
              SaveDialog:=TSaveDialog.Create(nil);
              SaveDialog.FileName:=FindParam('FileName=', ScrStr);
              If tmp2<>'' Then
                SaveDialog.DefaultExt:=tmp2;
              If SaveDialog.Execute Then
                SetVariable(tmp1, SaveDialog.FileName)
              Else
                SetVariable(tmp1, '');
              FreeAndNil(SaveDialog);
            end;

            If PosEx('OpenFolder=', ScrStr)=1 Then
            begin
              tmp1:=FindParam('OpenFolder=', ScrStr);
              TranslateVals(tmp1, FDCLForm.CurrentQuery);
              OpenDir(tmp1);
            end;

            If PosEx('EditByName=', ScrStr)=1 Then
            begin
              TmpStr:=FindParam('EditByName=', ScrStr);
              tmpStr1:=Copy(TmpStr, 1, Pos('.', TmpStr)-1);
              tmpStr2:=Copy(TmpStr, Pos('.', TmpStr)+1, Length(TmpStr));
              If Assigned(FDCLForm) Then
                If Assigned((FDCLForm.Tables[ - 1].FieldPanel.FindComponent(tmpStr1) as TEdit)) Then
                begin
                  If FDCLForm.FForm.Showing Then
                    If LowerCase(tmpStr2)='setfocus' Then
                      (FDCLForm.Tables[ - 1].FieldPanel.FindComponent(tmpStr1) as TEdit).SetFocus;
                  If LowerCase(tmpStr2)='clear' Then
                    (FDCLForm.Tables[ - 1].FieldPanel.FindComponent(tmpStr1) as TEdit).Clear;
                  If LowerCase(tmpStr2)='show' Then
                    (FDCLForm.Tables[ - 1].FieldPanel.FindComponent(tmpStr1) as TEdit).Show;
                  If LowerCase(tmpStr2)='hide' Then
                    (FDCLForm.Tables[ - 1].FieldPanel.FindComponent(tmpStr1) as TEdit).Hide;
                  If LowerCase(tmpStr2)='enabled' Then
                    (FDCLForm.Tables[ - 1].FieldPanel.FindComponent(tmpStr1) as TEdit).Enabled:=True;
                  If LowerCase(tmpStr2)='disabled' Then
                    (FDCLForm.Tables[ - 1].FieldPanel.FindComponent(tmpStr1) as TEdit).Enabled:=False;
                  If LowerCase(tmpStr2)='select' Then
                    (FDCLForm.Tables[ - 1].FieldPanel.FindComponent(tmpStr1) as TEdit).SelectAll;
                  If LowerCase(tmpStr2)='settext' Then
                  begin
                    If PosEx('_Value=', ScrStr)<>0 Then
                    begin
                      TmpStr:=FindParam('_Value=', ScrStr);
                      TranslateVals(tmpStr, FDCLForm.CurrentQuery);
                      (FDCLForm.Tables[ - 1].FieldPanel.FindComponent(tmpStr1) as TEdit).Text:=TmpStr;
                    end;
                  end;
                end;
            end;

            If (PosEx('If ', ScrStr)=1)and(PosEx(' then', ScrStr)<>0) Then
            begin
              inc(IfCounter);

              If Breaking=False Then
              begin
                IfSign:=0;
                TmpStr:=ScrStr;
                tmp1:='';
                tmp2:='';
                tmp3:='';

                If (FindParam('Expression1=', TmpStr)='')and(FindParam('Expression2=', TmpStr)='')and
                  (FindParam('Sign=', TmpStr)='') Then
                begin
                  If PosEx('If ', TmpStr)<>0 Then
                    Delete(TmpStr, PosEx('If ', TmpStr), 3);
                  If PosEx(' then', TmpStr)<>0 Then
                    Delete(TmpStr, PosEx(' then', TmpStr), 5);

                  TranslateValContext(TmpStr);

                  v2:=LastDelimiter('<>=', TmpStr);
                  If v2<>0 Then
                  begin
                    v1:=FindSubstrInString(TmpStr, Signs);
                    If v1<0 then
                      v1:=0;
                    Sign:=TSigns(v1);
                    tmp3:=Signs[Sign];

                    v1:=Pos(Signs[Sign], TmpStr);
                    v2:=Length(Signs[Sign]);
                    Tmp1:=Copy(TmpStr, 1, v1-1);
                    Tmp2:=Copy(TmpStr, v1+v2, Length(TmpStr));
                    tmp1:=Trim(AnsiLowerCase(tmp1));
                    tmp2:=Trim(AnsiLowerCase(tmp2));
                  end;
                end
                Else
                begin
                  tmp1:=FindParam('Expression1=', TmpStr);
                  If tmp1<>'' Then
                    tmp1:=ExpressionParser(tmp1);
                  tmp2:=FindParam('Expression2=', TmpStr);
                  If tmp2<>'' Then
                    tmp2:=ExpressionParser(tmp2);
                  tmp3:=FindParam('Sign=', TmpStr);
                end;
                If tmp3<>'' Then
                begin
                  If tmp3='=' Then
                    IfSign:=0;
                  If tmp3='<>' Then
                    IfSign:=1;
                  If tmp3='>' Then
                    IfSign:=2;
                  If tmp3='<' Then
                    IfSign:=3;
                  If tmp3='<=' Then
                    IfSign:=4;
                  If tmp3='>=' Then
                    IfSign:=5;
                end;
                StopFlag:=True;
                Case IfSign of
                0:
                If tmp1=tmp2 Then
                  StopFlag:=False;
                1:
                If tmp1<>tmp2 Then
                  StopFlag:=False;
                2:
                If tmp1>tmp2 Then
                  StopFlag:=False;
                3:
                If tmp1<tmp2 Then
                  StopFlag:=False;
                4:
                If tmp1<=tmp2 Then
                  StopFlag:=False;
                5:
                If tmp1>=tmp2 Then
                  StopFlag:=False;
                end;
              end;
            end;

            If PosEx('Else', ScrStr)=1 Then
            begin
              If Breaking=False Then
                StopFlag:=Not StopFlag;
            end;

            If PosEx('EndIf', ScrStr)=1 Then
            begin
              Dec(IfCounter);
              If Breaking=False Then
                StopFlag:=False;
            end;

            If PosEx('Message=', ScrStr)=1 Then
            begin
              TmpStr:=FindParam('message=', ScrStr);
              TranslateValContext(TmpStr);
              tmpStr3:=FindParam('Flags=', ScrStr);
              If tmpStr3<>'' Then
              begin
                tmpStr2:=FindParam('VariableName=', ScrStr);
                FDCLLogOn.Variables.NewVariableWithTest(tmpStr2);

                If LowerCase(tmpStr3)='yesno' Then
                begin
                  If ShowErrorMessage(10, TmpStr)=1 Then
                    FDCLLogOn.Variables.Variables[tmpStr2]:='1'
                  Else
                    FDCLLogOn.Variables.Variables[tmpStr2]:='0';
                end
                Else If LowerCase(tmpStr3)='input' Then
                begin
                  TranslateValContext(tmpStr2);
                  tmpStr3:=FindParam('DefaultValue=', ScrStr);
                  TranslateValContext(tmpStr3);
                  FDCLLogOn.Variables.Variables[tmpStr2]:=InputBox(TmpStr, '', tmpStr3);
                end;
              end
              Else
                ShowErrorMessage(9, TmpStr);
            end;

            If PosEx('SetValue=', ScrStr)=1 Then
            begin
              SetValue(ScrStr);
            end;

            If PosEx('SetFieldValue=', ScrStr)=1 Then
            begin
              If GetRaightsByContext(InContext)>ulReadOnly Then
              begin
                TmpStr:=FindParam('SetFieldValue=', ScrStr);
                For v1:=1 to ParamsCount(TmpStr) do
                begin
                  tmpStr2:=SortParams(TmpStr, v1);
                  v2:=Pos('=', tmpStr2);
                  If v2<>0 Then
                  begin
                    tmp1:=Trim(Copy(tmpStr2, 1, v2-1));
                    tmp2:=Copy(tmpStr2, v2+1, Length(tmpStr2)-v2);
                    TranslateValContext(tmp2);
                    tmpStr3:=Trim(FindParam('TablePartNum=', ScrStr));
                    If GetRaightsByContext(InContext)>ulReadOnly Then
                      If tmpStr3<>'' Then
                      begin
                        v3:=StrToIntEx(tmpStr3)-1;
                        If Assigned(FDCLForm.Tables[ - 1]) Then
                          If Assigned(FDCLForm.Tables[ - 1].TableParts[v3]) Then
                          begin
                            If Not (FDCLForm.Tables[ - 1].TableParts[v3].Query.State
                                in dsEditModes) Then
                              FDCLForm.Tables[ - 1].TableParts[v3].Query.Edit;
                            FDCLForm.Tables[ - 1].TableParts[v3].Query.FieldByName(tmp1)
                              .AsString:=tmp2;
                          end;
                      end
                      Else
                      begin
                        If Not (FDCLForm.CurrentQuery.State in dsEditModes) Then
                          FDCLForm.CurrentQuery.Edit;
                        FDCLForm.CurrentQuery.FieldByName(tmp1).AsString:=tmp2;
                      end;
                  end;

                  If FindParam('Post=', ScrStr)='1' Then
                  begin
                    If GetRaightsByContext(InContext)>ulReadOnly Then
                      If Trim(FindParam('TablePartNum=', ScrStr))<>'' Then
                      begin
                        If FDCLForm.Tables[ - 1].TableParts[v1].Query.State in dsEditModes Then
                          FDCLForm.Tables[ - 1].TableParts[v1].Query.Post;
                      end
                      Else
                      begin
                        If FDCLForm.CurrentQuery.State in dsEditModes Then
                          FDCLForm.CurrentQuery.Post;
                      end;
                  end;
                end;
              end;
            end;

            If PosEx('GetFieldValue=', ScrStr)=1 Then
            begin
              TmpStr:=FindParam('GetFieldValue=', ScrStr);
              For v1:=1 to ParamsCount(TmpStr) do
              begin
                tmpStr2:=SortParams(TmpStr, v1);
                v2:=Pos('=', tmpStr2);
                If v2<>0 Then
                begin
                  tmp1:=Trim(Copy(tmpStr2, 1, v2-1));
                  tmp2:=Copy(tmpStr2, v2+1, Length(tmpStr2)-v2);
                  v3:=Pos('.', tmp2);
                  If v3<>0 Then
                  begin
                    tmp3:=Trim(Copy(tmp2, 1, v3-1));
                    tmp4:=Copy(tmp2, v3+1, Length(tmp2)-v3);
                    tmp3:=FindParam('where=', ScrStr);
                    TranslateValContext(tmp3);
                    DCLQuery.Close;
                    DCLQuery.SQL.Text:='select '+tmp4+' from '+tmp3;
                    If tmp3<>'' Then
                      DCLQuery.SQL.Text:='select '+tmp4+' from '+tmp3+' where '+tmp3;
                    DCLQuery.Open;
                    FDCLLogOn.Variables.Variables[tmp1]:=TrimRight(DCLQuery.Fields[0].AsString);
                    DCLQuery.Close;
                  end
                  Else
                  begin
                    TmpStr:=Trim(FindParam('TablePartNum=', ScrStr));
                    If TmpStr<>'' Then
                    begin
                      v3:=StrToIntEx(TmpStr)-1;
                      If Assigned(FDCLForm.Tables[ - 1].TableParts[v3]) Then
                        FDCLLogOn.Variables.Variables[tmp1]:=FDCLForm.Tables[ - 1].TableParts[v3]
                          .Query.FieldByName(tmp1).AsString;
                    end
                    Else
                    begin
                      FDCLLogOn.Variables.Variables[tmp1]:=
                        TrimRight(FDCLForm.CurrentQuery.FieldByName(tmp2).AsString);
                    end;
                  end;
                end;
              end;
            end;

            If PosEx('CurrentTablePart=', ScrStr)=1 Then
            begin
              tmpStr2:=Trim(FindParam('CurrentTablePart=', ScrStr));
              TranslateValContext(tmpStr2);
              If Assigned(FDCLForm) Then
              If tmpStr2<>'' Then
              begin
                If tmpStr2='-1' then
                  v1:=FDCLForm.Tables[-1].TablePartsCount-1
                Else
                  v1:=StrToIntEx(tmpStr2)-1;
                If Assigned(FDCLForm.Tables[ - 1].TableParts[v1]) Then
                  FDCLForm.Tables[ - 1].FTablePartsPages.ActivePageIndex:=v1;
              end;
            end;

            If PosEx('Insert_part;', ScrStr)=1 Then
            begin
              If GetRaightsByContext(InContext)>ulReadOnly Then
                If Assigned(FDCLForm) Then
                If Assigned(FDCLForm.Tables[ - 1].TableParts[FDCLForm.CurrentTabIndex]) Then
                  FDCLForm.Tables[ - 1].TableParts[FDCLForm.CurrentTabIndex].Query.Insert;
            end;

            If PosEx('Append_part;', ScrStr)=1 Then
            begin
              If GetRaightsByContext(InContext)>ulReadOnly Then
                If Assigned(FDCLForm) Then
                If Assigned(FDCLForm.Tables[ - 1].TableParts[FDCLForm.CurrentTabIndex]) Then
                  FDCLForm.Tables[ - 1].TableParts[FDCLForm.CurrentTabIndex].Query.Append;
            end;

            If PosEx('Post_part;', ScrStr)=1 Then
            begin
              If GetRaightsByContext(InContext)>ulReadOnly Then
                If Assigned(FDCLForm) Then
                If Assigned(FDCLForm.Tables[ - 1].TableParts[FDCLForm.CurrentTabIndex]) Then
                  FDCLForm.Tables[ - 1].TableParts[FDCLForm.CurrentTabIndex].Query.Post;
            end;

            If PosEx('Delete_part;', ScrStr)=1 Then
            begin
              If GetRaightsByContext(InContext)>ulReadOnly Then
                If Assigned(FDCLForm) Then
                If Assigned(FDCLForm.Tables[ - 1].TableParts[FDCLForm.CurrentTabIndex]) Then
                  FDCLForm.Tables[ - 1].TableParts[FDCLForm.CurrentTabIndex].Query.Delete;
            end;

            If PosEx('DeleteConf_part;', ScrStr)=1 Then
            begin
              If GetRaightsByContext(InContext)>ulReadOnly Then
                If Assigned(FDCLForm) Then
                If Assigned(FDCLForm.Tables[ - 1].TableParts[FDCLForm.CurrentTabIndex]) Then
                  If ShowErrorMessage(10, GetDCLMessageString(msDeleteRecordQ))=1 Then
                    FDCLForm.Tables[ - 1].TableParts[FDCLForm.CurrentTabIndex].Query.Delete;
            end;

            If PosEx('Edit_part;', ScrStr)=1 Then
            begin
              If GetRaightsByContext(InContext)>ulReadOnly Then
                If Assigned(FDCLForm) Then
                If Assigned(FDCLForm.Tables[ - 1].TableParts[FDCLForm.CurrentTabIndex]) Then
                  FDCLForm.Tables[ - 1].TableParts[FDCLForm.CurrentTabIndex].Query.Edit;
            end;

            If PosEx('Next_part;', ScrStr)=1 Then
            begin
              If GetRaightsByContext(InContext)>ulReadOnly Then
                If Assigned(FDCLForm) Then
                If Assigned(FDCLForm.Tables[ - 1].TableParts[FDCLForm.CurrentTabIndex]) Then
                  FDCLForm.Tables[ - 1].TableParts[FDCLForm.CurrentTabIndex].Query.Next;
            end;

            If PosEx('Prior_part;', ScrStr)=1 Then
            begin
              If GetRaightsByContext(InContext)>ulReadOnly Then
                If Assigned(FDCLForm) Then
                If Assigned(FDCLForm.Tables[ - 1].TableParts[FDCLForm.CurrentTabIndex]) Then
                  FDCLForm.Tables[ - 1].TableParts[FDCLForm.CurrentTabIndex].Query.Prior;
            end;

            If PosEx('First_part;', ScrStr)=1 Then
            begin
              If GetRaightsByContext(InContext)>ulReadOnly Then
                If Assigned(FDCLForm) Then
                If Assigned(FDCLForm.Tables[ - 1].TableParts[FDCLForm.CurrentTabIndex]) Then
                  FDCLForm.Tables[ - 1].TableParts[FDCLForm.CurrentTabIndex].Query.First;
            end;

            If PosEx('Last_part;', ScrStr)=1 Then
            begin
              If GetRaightsByContext(InContext)>ulReadOnly Then
                If Assigned(FDCLForm) Then
                If Assigned(FDCLForm.Tables[ - 1].TableParts[FDCLForm.CurrentTabIndex]) Then
                  FDCLForm.Tables[ - 1].TableParts[FDCLForm.CurrentTabIndex].Query.Last;
            end;

            If PosEx('Next;', ScrStr)=1 Then
            begin
              If Assigned(FDCLForm) Then
              If GetRaightsByContext(InContext)>ulReadOnly Then
                FDCLForm.CurrentQuery.Next;
            end;

            If PosEx('Prior;', ScrStr)=1 Then
            begin
              If Assigned(FDCLForm) Then
              If GetRaightsByContext(InContext)>ulReadOnly Then
                FDCLForm.CurrentQuery.Prior;
            end;

            If PosEx('First;', ScrStr)=1 Then
            begin
              If Assigned(FDCLForm) Then
              If GetRaightsByContext(InContext)>ulReadOnly Then
                FDCLForm.CurrentQuery.First;
            end;

            If PosEx('Last;', ScrStr)=1 Then
            begin
              If Assigned(FDCLForm) Then
              If GetRaightsByContext(InContext)>ulReadOnly Then
                FDCLForm.CurrentQuery.Last;
            end;

            If PosEx('Edit;', ScrStr)=1 Then
            begin
              If Assigned(FDCLForm) Then
              If GetRaightsByContext(InContext)>ulReadOnly Then
                FDCLForm.CurrentQuery.Edit;
            end;

            If PosEx('Post;', ScrStr)=1 Then
            begin
              If Assigned(FDCLForm) Then
              If GetRaightsByContext(InContext)>ulReadOnly Then
                If FDCLForm.CurrentQuery.CanModify and (FDCLForm.CurrentQuery.State in dsEditModes) Then
                try
                  FDCLForm.CurrentQuery.Post;
                finally
                  ////
                end;
            end;

            If PosEx('PostClose;', ScrStr)=1 Then
            begin
              If Assigned(FDCLForm) Then
              begin
                If FDCLForm.CurrentQuery.State in dsEditModes Then
                  FDCLForm.CurrentQuery.Post;
                tmpDCLForm:=FDCLForm.GetParentForm;
                FDCLForm.CloseAction:=fcaClose;
                FDCLForm:=tmpDCLForm;
              end;
            end;

            If PosEx('CancelClose;', ScrStr)=1 Then
            begin
              If Assigned(FDCLForm) Then
              begin
                If FDCLForm.CurrentQuery.State in dsEditModes Then
                  FDCLForm.CurrentQuery.Cancel;
                tmpDCLForm:=FDCLForm.GetParentForm;
                FDCLForm.CloseAction:=fcaClose;
                FDCLForm:=tmpDCLForm;
              end;
            end;

            If PosEx('PostRefresh;', ScrStr)=1 Then
            begin
              If Assigned(FDCLForm) then
              Begin
                FDCLForm.CurrentQuery.Post;
                FDCLForm.Tables[ - 1].ReFreshQuery;
              End;
            end;

            If PosEx('Cancel;', ScrStr)=1 Then
            begin
              If Assigned(FDCLForm) then
                If FDCLForm.CurrentQuery.State in dsEditModes Then
                  FDCLForm.CurrentQuery.Cancel;
            end;

            If PosEx('Delete;', ScrStr)=1 Then
            begin
              If Assigned(FDCLForm) then
                If GetRaightsByContext(InContext)>ulReadOnly Then
                  FDCLForm.CurrentQuery.Delete;
            end;

            If PosEx('DeleteConf;', ScrStr)=1 Then
            begin
              If Assigned(FDCLForm) then
                If GetRaightsByContext(InContext)>ulReadOnly Then
                  If ShowErrorMessage(10, GetDCLMessageString(msDeleteRecordQ))=1 Then
                    FDCLForm.CurrentQuery.Delete;
            end;

            If PosEx('Insert;', ScrStr)=1 Then
            begin
              If Assigned(FDCLForm) then
                FDCLForm.CurrentQuery.Insert;
            end;

            If PosEx('Append;', ScrStr)=1 Then
            begin
              If Assigned(FDCLForm) then
                FDCLForm.CurrentQuery.Append;
            end;

            If PosEx('Refresh;', ScrStr)=1 Then
            begin
              If Assigned(FDCLForm) then
                FDCLForm.Tables[ - 1].ReFreshQuery;
            end;

            If PosEx('EvalFormula=', ScrStr)=1 Then
            begin
              tmp1:=FindParam('EvalFormula=', ScrStr);
              If Assigned(FDCLForm) then
                TranslateVals(tmp1, FDCLForm.CurrentQuery)
              Else
                TranslateVals(tmp1, nil);

              FDCLLogOn.EvalFormula:=Calculate(tmp1);
            end;

            If PosEx('Dialog=', ScrStr)=1 Then
            begin
              TmpStr:=FindParam('Dialog=', ScrStr);
              ModalOpen:=FindParam('ModalOpen=', TmpStr)='1';
              ChooseMode:=chmNone;
              ReturnValueParams:=nil;
              If FindParam('ChooseMode=', ScrStr)<>'' Then
              begin
                v1:=StrToIntEx(FindParam('ChooseMode=', ScrStr));
                ChooseMode:=TChooseMode(v1);
                ReturnValueParams:=TReturnValueParams.Create(FindParam('KeyField=', ScrStr),
                  FindParam('ValueField=', ScrStr), FindParam('KeyEditName=', ScrStr), FindParam('ValueEditName=', ScrStr),
                  FindParam('KeyModifyField=', ScrStr), FindParam('ValueModifyField=', ScrStr),
                  FindParam('KeyVariable=', ScrStr), FindParam('ValueVariable=', ScrStr));
              end;

              If FindParam('Child=', ScrStr)='1' Then
              Begin
                If Assigned(FDCLForm) then
                  FDCLForm:=FDCLLogOn.CreateForm(TmpStr, FDCLForm, FDCLForm, nil, FDCLForm.GetDataSource,
                    ModalOpen, ChooseMode, ReturnValueParams);
              End
              Else
              Begin
                tmpStr2:=Trim(FindParam('TablePart=', ScrStr));
                If tmpStr2<>'' Then
                begin
                  If Assigned(FDCLForm) then
                  Begin
                    v1:=StrToIntEx(tmpStr2)-1;
                    If Assigned(FDCLForm.Tables[ - 1].TableParts[v1]) Then
                      FDCLForm:=FDCLLogOn.CreateForm(TmpStr, nil, FDCLForm,
                        FDCLForm.Tables[ - 1].TableParts[v1].Query, nil, ModalOpen, ChooseMode,
                        ReturnValueParams);
                  End;
                end
                Else
                  FDCLForm:=FDCLLogOn.CreateForm(TmpStr, nil, FDCLForm, FDCLForm.CurrentQuery, nil, ModalOpen, ChooseMode,
                    ReturnValueParams);

                  If Assigned(FDCLForm) Then
                  begin
                    If FDCLForm.ReturnFormValue.Choosen Then
                    begin
                      RetVal:=FDCLForm.ReturnFormValue;
                      FDCLForm:=FDCLForm.FCallerForm;

                      If FieldExists(RetVal.KeyModifyField, FDCLForm.CurrentQuery) Then
                      begin
                        If FDCLForm.CurrentQuery.Active and Not (FDCLForm.CurrentQuery.State in dsEditModes) Then
                        begin
                          if FDCLForm.CurrentQuery.CanModify then
                          begin
                            if Not (FDCLForm.CurrentQuery.State in dsEditModes) then
                              FDCLForm.CurrentQuery.Edit;
                            FDCLForm.CurrentQuery.FieldByName(RetVal.KeyModifyField).AsString:=RetVal.Key;
                          end;
                        end;
                      end;

                      If FieldExists(RetVal.ValueModifyField, FDCLForm.CurrentQuery) Then
                      begin
                        If FDCLForm.CurrentQuery.Active Then
                        begin
                          If FDCLForm.CurrentQuery.CanModify Then
                          begin
                            if Not (FDCLForm.CurrentQuery.State in dsEditModes) then
                              FDCLForm.CurrentQuery.Edit;
                            FDCLForm.CurrentQuery.FieldByName(RetVal.ValueModifyField).AsString:=RetVal.Val;
                          end;
                        end;
                      end;

                      If RetVal.KeyEditName<>'' Then
                      begin
                        If Assigned(FDCLForm.Tables[FDCLForm.CurrentGridIndex]) Then
                          If Length(FDCLForm.Tables[FDCLForm.CurrentGridIndex].Edits)>0 Then
                          begin
                            v1:=Length(FDCLForm.Tables[FDCLForm.CurrentGridIndex].Edits);
                            For v2:=1 to v1 do
                            begin
                              If CompareString(RetVal.KeyEditName, FDCLForm.Tables[FDCLForm.CurrentGridIndex]
                                  .Edits[v2-1].Edit.Name) Then
                              begin
                                FDCLForm.Tables[FDCLForm.CurrentGridIndex].Edits[v2-1].Edit.Text:=
                                  RetVal.Key;

                                break;
                              end;
                            end;
                          end;
                      end;

                      If RetVal.ValueEditName<>'' Then
                      begin
                        If Assigned(FDCLForm.Tables[FDCLForm.CurrentGridIndex]) Then
                          If Length(FDCLForm.Tables[FDCLForm.CurrentGridIndex].Edits)>0 Then
                          begin
                            v1:=Length(FDCLForm.Tables[FDCLForm.CurrentGridIndex].Edits);
                            For v2:=1 to v1 do
                            begin
                              If CompareString(RetVal.ValueEditName, FDCLForm.Tables[FDCLForm.CurrentGridIndex]
                                  .Edits[v2-1].Edit.Name) Then
                              begin
                                FDCLForm.Tables[FDCLForm.CurrentGridIndex].Edits[v2-1].Edit.Text:=
                                  RetVal.Val;

                                break;
                              end;
                            end;
                          end;
                      end;

                      if RetVal.KeyVar<>'' then
                      begin
                        FDCLLogOn.Variables.NewVariableWithTest(RetVal.KeyVar);
                        FDCLLogOn.Variables.SetVariableByName(RetVal.KeyVar, RetVal.Key);
                      end;

                      if RetVal.ValueVar<>'' then
                      begin
                        FDCLLogOn.Variables.NewVariableWithTest(RetVal.ValueVar);
                        FDCLLogOn.Variables.SetVariableByName(RetVal.ValueVar, RetVal.Val);
                      end;

                      If Assigned(ReturnValueParams) Then
                        FreeAndNil(ReturnValueParams);
                    end;
                  end;
              End;
            end;

            If PosEx('CloseDialog;', ScrStr)=1 Then
            begin
              If Assigned(FDCLForm) Then
              Begin
                tmpDCLForm:=FDCLForm.GetParentForm;
                FDCLForm.CloseAction:=fcaClose;
                FDCLForm:=tmpDCLForm;
              End;
            end;

            If PosEx('Hold;', ScrStr)=1 Then
            begin
  {$IFNDEF DCLDEBUG}
              If Assigned(FDCLForm) then
                FDCLForm.Form.FormStyle:=fsStayOnTop;
  {$ENDIF}
            end;

            If PosEx('HoldDown;', ScrStr)=1 Then
            begin
              If Assigned(FDCLForm) then
                If Not FDCLForm.Modal Then
                  FDCLForm.Form.FormStyle:=fsNormal;
            end;

            If PosEx('Declare=', ScrStr)=1 Then
            begin
              TmpStr:=Trim(FindParam('declare=', ScrStr));
              For v1:=1 to ParamsCount(TmpStr) do
              begin
                tmpStr1:=SortParams(TmpStr, v1);
                v2:=PosEx('=', tmpStr1);
                If v2=0 Then
                  FDCLLogOn.Variables.NewVariable(tmpStr1, '')
                Else
                begin
                  tmpStr2:=Trim(Copy(tmpStr1, 1, v2-1));
                  tmpStr3:=Copy(tmpStr1, v2+1, Length(tmpStr1)-v2);
                  TranslateValContext(tmpStr3);

                  FDCLLogOn.Variables.NewVariable(tmpStr2, tmpStr3);
                end;
              end;
            end;

            If PosEx('Dispose=', ScrStr)=1 Then
            begin
              tmpStr2:=FindParam('dispose=', ScrStr);
              For v1:=1 to ParamsCount(tmpStr2) do
                FDCLLogOn.Variables.FreeVariable(SortParams(tmpStr2, v1));
            end;

            If PosEx('Exit;', ScrStr)=1 Then
            begin
              Application.MainForm.Close;
            end;

            If PosEx('Debug;', ScrStr)=1 Then
            begin
              GPT.DebugOn:=Not GPT.DebugOn;
            end;

            If PosEx('SetMainFormCaption=', ScrStr)=1 Then
            begin
              TmpStr:=FindParam('SetMainFormCaption=', ScrStr);
              TranslateValContext(TmpStr);
              Application.MainForm.Caption:=TmpStr;
            end;

            If PosEx('SetFormCaption=', ScrStr)=1 Then
            begin
              If Assigned(FDCLForm) then
              Begin
                TmpStr:=FindParam('SetFormCaption=', ScrStr);
                TranslateValContext(TmpStr);
                FDCLForm.FForm.Caption:=TmpStr;
              End;
            end;

            If PosEx('ApplicationTitle=', ScrStr)=1 Then
            begin
              TmpStr:=FindParam('ApplicationTitle=', ScrStr);
              TranslateValContext(TmpStr);
              Application.Title:=TmpStr;
            end;

            If PosEx('Status=', ScrStr)=1 Then
            begin
              If Assigned(FDCLForm) then
              Begin
                TmpStr:=FindParam('Status=', ScrStr);
                TranslateValContext(TmpStr);
                FDCLForm.SetDBStatus(TmpStr);
              End;
            end;

            If PosEx('AddStatus=', ScrStr)=1 Then
            begin
              If Assigned(FDCLForm) then
              Begin
                TmpStr:=FindParam('AddStatus=', ScrStr);
                v1:= - 1;
                If FindParam('Width=', ScrStr)<>'' Then
                  v1:=StrToIntEx(FindParam('Width=', ScrStr));

                FDCLForm.AddStatus(TmpStr, v1);
              End;
            end;

            If PosEx('SetStatusText=', ScrStr)=1 Then
            begin
              If Assigned(FDCLForm) then
              Begin
                TmpStr:=FindParam('Status=', ScrStr);
                If TmpStr<>'' Then
                begin
                  If LowerCase(TmpStr)='last' Then
                    v1:=0
                  Else
                    v1:=StrToIntEx(Trim(FindParam('Status=', ScrStr)))
                end
                Else
                  v1:=0;

                TmpStr:=FindParam('SetStatusText=', ScrStr);
                TranslateValContext(TmpStr);
                v2:= - 1;
                If FindParam('Width=', ScrStr)<>'' Then
                  v2:=StrToIntEx(Trim(FindParam('Width=', ScrStr)));
                FDCLForm.SetStatus(TmpStr, v1-1, v2);
              End;
            end;

            If PosEx('StatusWidth=', ScrStr)=1 Then
            begin
              TmpStr:=FindParam('StatusWidth=', ScrStr);
              If TmpStr<>'' Then
              begin
                If LowerCase(TmpStr)='last' Then
                  v1:=0
                Else
                  v1:=StrToIntEx(Trim(FindParam('StatusWidth=', ScrStr)))
              end
              Else
                v1:=0;

              v2:= - 1;
              If FindParam('Width=', ScrStr)<>'' Then
                v2:=StrToIntEx(Trim(FindParam('Width=', ScrStr)));
              If Assigned(FDCLForm) then
                FDCLForm.SetStatusWidth(v1-1, v2);
            end;

            If PosEx('DeleteStatus=', ScrStr)=1 Then
            begin
              TmpStr:=FindParam('DeleteStatus=', ScrStr);
              If TmpStr<>'' Then
              begin
                If LowerCase(TmpStr)='last' Then
                  v1:=0
                Else
                  v1:=StrToIntEx(Trim(FindParam('DeleteStatus=', ScrStr)));
              end
              Else
                v1:=0;

              If Assigned(FDCLForm) then
                FDCLForm.DeleteStatus(v1);
            end;

            If PosEx('DeleteAllStatus;', ScrStr)=1 Then
            begin
              If Assigned(FDCLForm) then
                FDCLForm.DeleteAllStatus;
            end;

            If PosEx('WriteConfig=', ScrStr)=1 Then
            begin
              tmp1:=FindParam('WriteConfig=', ScrStr);
              tmp3:=FindParam('UserID=', ScrStr);
              tmp2:=Copy(ScrStr, PosEx('_Value=', ScrStr), Length(ScrStr));
              Delete(tmp2, 1, 7);

              FDCLLogOn.WriteConfig(tmp1, tmp2, tmp3);
            end;

            If PosEx('FormHeight=', ScrStr)=1 Then
            begin
              v1:=StrToIntEx(FindParam('FormHeight=', ScrStr));
              If Assigned(FDCLForm) Then
                FDCLForm.FForm.ClientHeight:=v1;
            end;

            If PosEx('FormWidth=', ScrStr)=1 Then
            begin
              v1:=StrToIntEx(FindParam('FormWidth=', ScrStr));
              If Assigned(FDCLForm) Then
                FDCLForm.FForm.ClientWidth:=v1;
            end;

            If (PosEx('PutInDB=', ScrStr)=1)or(PosEx('PutToDB=', ScrStr)=1) Then
            begin
              If GetRaightsByContext(InContext)>ulReadOnly Then
              begin
                TmpStr:=FindParam('FileName=', ScrStr);
                tmpStr2:=FindParam('Compress=', ScrStr);

                If Not IsFullPAth(TmpStr) Then
                  TmpStr:=IncludeTrailingPathDelimiter(AppConfigDir)+TmpStr;
                If FileExists(TmpStr) Then
                begin
                  If Not Assigned(BinStore) Then
                    BinStore:=TBinStore.Create(FDCLLogOn, ftSQL, '', '', '',
                      FindParam('DataField=', ScrStr));
                  BinStore.StoreFromFile(TmpStr, FindParam('SQL=', ScrStr), '', tmpStr2='1');
                end
                Else
                  ShowErrorMessage( - 8001, TmpStr);
              end;
            end;

            If PosEx('GetFromDB=', ScrStr)=1 Then
            begin
              If GetRaightsByContext(InContext)>ulReadOnly Then
              begin
                TmpStr:=FindParam('FileName=', ScrStr);
                If Not IsFullPAth(TmpStr) Then
                  TmpStr:=IncludeTrailingPathDelimiter(AppConfigDir)+TmpStr;

                If Not Assigned(BinStore) Then
                  BinStore:=TBinStore.Create(FDCLLogOn, ftSQL, '', '', '',
                    FindParam('DataField=', ScrStr));

                BinStore.SaveToFile(TmpStr, FindParam('SQL=', ScrStr));
              end;
            end;

            If PosEx('ClearBLOB=', ScrStr)=1 Then
            begin
              If GetRaightsByContext(InContext)>ulReadOnly Then
              begin
                tmpStr1:=FindParam('ClearBLOB=', ScrStr);

                If Not Assigned(BinStore) Then
                  BinStore:=TBinStore.Create(FDCLLogOn, ftSQL, '', '', '',
                    FindParam('DataField=', ScrStr));

                BinStore.ClearData(FindParam('SQL=', ScrStr));
              end;
            end;

            If PosEx('DeleteBLOB=', ScrStr)=1 Then
            begin
              If GetRaightsByContext(InContext)>ulReadOnly Then
              begin
                tmpStr1:=FindParam('DeleteBLOB=', ScrStr);

                If Not Assigned(BinStore) Then
                  BinStore:=TBinStore.Create(FDCLLogOn, ftSQL, '', '', '',
                    FindParam('DataField=', ScrStr));

                BinStore.DeleteData(FindParam('SQL=', ScrStr));
              end;
            end;

            If PosEx('DecompressData=', ScrStr)=1 Then
            begin
              If Not Assigned(BinStore) Then
                BinStore:=TBinStore.Create(FDCLLogOn, ftSQL, '', '', '',
                  FindParam('DataField=', ScrStr));

              BinStore.DeCompressData(FindParam('SQL=', ScrStr), '');
            end;

            If PosEx('CompressData=', ScrStr)=1 Then
            begin
              If Not Assigned(BinStore) Then
                BinStore:=TBinStore.Create(FDCLLogOn, ftSQL, '', '', '',
                  FindParam('DataField=', ScrStr));

              BinStore.CompressData(FindParam('SQL=', ScrStr), '');
            end;

            If PosEx('MD5Data=', ScrStr)=1 Then
            begin
              tmpStr1:=FindParam('MD5Data=', ScrStr);

              If Not Assigned(BinStore) Then
                BinStore:=TBinStore.Create(FDCLLogOn, ftSQL, '', '', '',
                  FindParam('DataField=', ScrStr));
              FDCLLogOn.Variables.NewVariable(tmpStr1, BinStore.MD5(FindParam('SQL=', ScrStr)));
            end;

            If PosEx('SQLmon_Clear;', ScrStr)=1 Then
            begin
              FDCLLogOn.SQLMon.Clear;
            end;

            If PosEx('SQLMon;', ScrStr)=1 Then
            begin
              FDCLLogOn.SQLMon.TrraceStatus:=Not FDCLLogOn.SQLMon.TrraceStatus;
            end;

            If PosEx('OpenSpool=', ScrStr)=1 Then
            begin
              SpoolFileName:=FindParam('OpenSpool=', ScrStr);
              If Not IsFullPAth(SpoolFileName) Then
                SpoolFileName:=IncludeTrailingPathDelimiter(AppConfigDir)+SpoolFileName;

              If Not Assigned(Spool) Then
                Spool:=TStringList.Create;
            end;

            If PosEx('Spool=', ScrStr)=1 Then
            begin
              If Not Assigned(Spool) Then
                Spool:=TStringList.Create;
              If SpoolFileName='' Then
                SpoolFileName:='spool.txt';

              If Not IsFullPAth(SpoolFileName) Then
                SpoolFileName:=IncludeTrailingPathDelimiter(AppConfigDir)+SpoolFileName;

              TmpStr:=Copy(ScrStr, 7, Length(ScrStr)-6);
              Spool.Append(TmpStr);
              Spool.SaveToFile(SpoolFileName);
            end;

            If PosEx('Evalute=', ScrStr)=1 Then
            begin
              tmp1:=FindParam('Evalute=', ScrStr);

              tmp2:=FindParam('ResultVar=', ScrStr);
              If Not FDCLLogOn.Variables.Exists(tmp2) Then
                tmp2:='';
              If tmp2='' Then
                EvalResultScript:=RunScript(tmp1)
              Else
              begin
                SetVariable(tmp2, RunScript(tmp1));
              end;
            end;

            If PosEx('AddFunctions=', ScrStr)=1 Then
            begin
              tmpDCL:=TStringList.Create;

              TmpStr:=FindParam('AddFunctions=', ScrStr);
              DCLQuery.Close;
              DCLQuery.SQL.Text:='select Count(*) from '+GPT.DCLTable+' where '+GPT.UpperString+
                GPT.DCLNameField+GPT.UpperStringEnd+'='+GPT.UpperString+GPT.StringTypeChar+TmpStr+
                GPT.StringTypeChar+GPT.UpperStringEnd;
              DCLQuery.Open;
              RecCount:=DCLQuery.Fields[0].AsInteger;
              If RecCount=1 Then
              begin
                DCLQuery.Close;
                DCLQuery.SQL.Text:='select '+GPT.DCLTextField+' from '+GPT.DCLTable+' where '+
                  GPT.UpperString+GPT.DCLNameField+GPT.UpperStringEnd+'='+GPT.UpperString+
                  GPT.StringTypeChar+TmpStr+GPT.StringTypeChar+GPT.UpperStringEnd;
                DCLQuery.Open;
                TmpStr:=DCLQuery.FieldByName(GPT.DCLTextField).AsString;
                If Assigned(FDCLForm) then
                  TranslateVals(TmpStr, FDCLForm.Tables[ - 1].FQuery);
                tmpDCL.Text:=TmpStr;
                AddCodeScript(tmpDCL);
              end;
              FreeAndNil(tmpDCL);
            end;

            If PosEx('ExecVBS=', ScrStr)=1 Then
            begin
              tmpDCL:=TStringList.Create;

              TmpStr:=FindParam('ExecVBS=', ScrStr);
              DCLQuery.Close;
              DCLQuery.SQL.Text:='select Count(*) from '+GPT.DCLTable+' where '+GPT.UpperString+
                GPT.DCLNameField+GPT.UpperStringEnd+'='+GPT.UpperString+GPT.StringTypeChar+TmpStr+
                GPT.StringTypeChar+GPT.UpperStringEnd;
              DCLQuery.Open;
              RecCount:=DCLQuery.Fields[0].AsInteger;
              If RecCount=1 Then
              begin
                DCLQuery.Close;
                DCLQuery.SQL.Text:='select '+GPT.DCLTextField+' from '+GPT.DCLTable+' where '+
                  GPT.UpperString+GPT.DCLNameField+GPT.UpperStringEnd+'='+GPT.UpperString+
                  GPT.StringTypeChar+TmpStr+GPT.StringTypeChar+GPT.UpperStringEnd;
                DCLQuery.Open;
                TmpStr:=DCLQuery.FieldByName(GPT.DCLTextField).AsString;
                If Assigned(FDCLForm) then
                  TranslateVals(TmpStr, FDCLForm.Tables[ - 1].FQuery);
                ExecVBS(TmpStr);
              end;
              FreeAndNil(tmpDCL);
            end;

            If PosEx('ReadOnly=', ScrStr)=1 Then
            begin
              If Assigned(FDCLForm) then
                FDCLForm.Tables[ - 1].ReadOnly:=Trim(FindParam('ReadOnly=', ScrStr))='1';
            end;

            If LowerCase(ScrStr)='print' Then
              If Assigned(FDCLForm) then
                FDCLForm.Tables[FDCLForm.CurrentGridIndex].Print(nil);

          end
          Else
          begin
            If PosEx('Else', ScrStr)=1 Then
            begin
              If Breaking=False Then
                StopFlag:=Not StopFlag;
            end;

            If PosEx('EndIf', ScrStr)=1 Then
            begin
              Dec(IfCounter);
              If Breaking=False Then
                StopFlag:=False;
            end;
          end;
        end;
        inc(ScriptStrings);
      end;
    end;
  end;

  DCLQuery.Close;
  FDCLLogOn.NotifyForms(fnaResumeAutoRefresh);
end;

procedure TDCLCommand.RunSkriptFromFile(FileName: String);
begin
  FDCLLogOn.RunSkriptFromFile(FileName);
end;

procedure TDCLCommand.ExecSQLCommand(SQLCommand: String; InContext: Boolean);
var
  ADOCommand: TCommandQuery;
  {$IFDEF TRANSACTIONDB}
  tmp_Transaction:TTransaction;
  {$ENDIF}
begin
  If GetRaightsByContext(InContext)>ulWrite Then
  begin
    ADOCommand:=TCommandQuery.Create(nil);
    ADOCommand.Name:='ExecSQL_'+IntToStr(UpTime);
    TranslateValContext(SQLCommand);
    If GPT.DebugOn Then
    begin
      DebugProc('ExecSQLCommand: '+SQLCommand);
      DebugProc('-=EndSQL command=-');
      DebugProc(SQLCommand);
      If GPT.DebugMesseges Then
        ShowMessage(SQLCommand);
    end;
    If FDCLLogOn.SQLMon.TrraceStatus Then
      FDCLLogOn.SQLMon.AddSQLText(SQLCommand);

    {$IFDEF ADO}
    ADOCommand.CommandType:=cmdText;
    ADOCommand.CommandText:=SQLCommand;
    ADOCommand.Connection:=FDCLLogOn.FDBLogOn;
    {$ELSE}
    ADOCommand.SQL.Text:=SQLCommand;
    FDCLLogOn.SetDBName(TDCLDialogQuery(ADOCommand));
    {$ENDIF}
    {$IFDEF TRANSACTIONDB}
    tmp_Transaction:=FDCLLogOn.NewTransaction(trtWrite);
    ADOCommand.Transaction:=tmp_Transaction;
    tmp_Transaction.StartTransaction;
    {$ENDIF}

    try
      If Not IsReturningQuery(SQLCommand) Then
        {$IFDEF ADO}
        ADOCommand.Execute
        {$ELSE}
        ADOCommand.ExecSQL
        {$ENDIF}
      Else
        {$IFDEF ADO}
        ADOCommand.Execute;
        {$ELSE}
        ADOCommand.Open;
        {$ENDIF}
    Except
      On ex: Exception do
        ShowErrorMessage( - 1110, 'SQL='+SQLCommand+' / '+ex.Message);
    end;
    {$IFDEF TRANSACTIONDB}
    tmp_Transaction.Commit;
    FreeAndNil(tmp_Transaction);
    {$ENDIF}

    FreeAndNil(ADOCommand);

    FDCLLogOn.NotifyForms(fnaRefresh);
  end;
end;

procedure TDCLCommand.ExportData(Tagert: TSpoolType; Scr: String);
var
  S1, S, Mode, FileName, tmp1, ExportTable, TableFields, BlobStr: String;
  T: TextFile;
  BlobPos: Cardinal;
  v1, v2: Word;
  MS: TMemoryStream;
  ExportingTable: TDCLDialogQuery;
  OpenDialog: TOpenDialog;

  procedure WriteSpool(var TT: Text; Spool: TStringList; S: String);
  begin
    If Tagert=stText Then
      WriteLn(TT, S)
    Else
      Spool.Append(S);
  end;

begin
  If Not Assigned(Spool) Then
    Spool:=TStringList.Create;

  ExportingTable:=TDCLDialogQuery.Create(nil);
  FDCLLogOn.SetDBName(ExportingTable);
  If FindParam('query=', Scr)<>'' Then
  begin
    tmp1:=FindParam('query=', Scr);
    ExportingTable.SQL.Text:=tmp1;
  end
  Else
    ExportingTable.SQL.Text:=FDCLForm.Tables[ - 1].Query.SQL.Text;

  try
    ExportingTable.Open;
  Except
    ShowErrorMessage( - 1119, 'SQL='+ExportingTable.SQL.Text);
  end;

  If FindParam('filename=', Scr)='' Then
  begin
    OpenDialog:=TOpenDialog.Create(nil);
    If OpenDialog.Execute Then
      FileName:=OpenDialog.FileName
    Else
      FileName:='Table1';
    FreeAndNil(OpenDialog);
  end
  Else
    FileName:=FindParam('filename=', Scr);
  If Not IsFullPAth(FileName) Then
    FileName:=IncludeTrailingPathDelimiter(AppConfigDir)+FileName;

  tmp1:='';
  tmp1:=LowerCase(FindParam('target=', Scr));
  If tmp1='' Then
    tmp1:='dbf';
  Mode:=LowerCase(LowerCase(FindParam('mode=', Scr)));
  If Mode='' Then
    Mode:='new';

  If LowerCase(tmp1)='oth' Then
  begin
    If PosEx('.OTH', FileName)=0 Then
      FileName:=FileName+'.OTH';
    If Tagert=stText Then
      AssignFile(T, FileName);

    If Mode='append' Then
    begin
      If Tagert=stText Then
        Append(T);
    end
    Else If Tagert=stText Then
      ReWrite(T);

    S:='[TABLE]';
    WriteSpool(T, Spool, S);
    S:=FindParam('table=', Scr);
    WriteSpool(T, Spool, S);
    S:='[FIELDS]';
    WriteSpool(T, Spool, S);
    For v1:=0 to ExportingTable.FieldCount-1 do
    begin
      S:=UpperCase(ExportingTable.Fields[v1].FieldName);
      WriteSpool(T, Spool, S);
    end;
    S:='[DATA]';
    WriteSpool(T, Spool, S);
    While Not ExportingTable.Eof do
    begin
      S:='';
      For v1:=0 to ExportingTable.FieldCount-1 do
      begin
        If (ExportingTable.Fields[v1].DataType<>ftMemo)or
          (ExportingTable.Fields[v1].DataType<>ftGraphic)or
          (ExportingTable.Fields[v1].DataType<>ftBlob) Then
        begin
          S1:=TrimRight(ExportingTable.Fields[v1].AsString);
          Case ExportingTable.Fields[v1].DataType of
          ftString:
          begin
            S:=S+GPT.StringTypeChar+S1+GPT.StringTypeChar+', ';
          end;
          ftDate, ftTime, ftDateTime, ftBCD, ftFloat, ftCurrency:
          begin
            If S1='' Then
              S:=S+S1+'null, '
            Else
              S:=S+GPT.StringTypeChar+S1+GPT.StringTypeChar+', ';
          end
        Else
        begin
          If S1='' Then
            S:=S+S1+'null, '
          Else
            S:=S+S1+', ';
        end;
          end;
        end;
        If v1=ExportingTable.FieldCount-1 Then
          Delete(S, Length(S)-1, 2);
      end;
      WriteSpool(T, Spool, S);
      ExportingTable.Next;
    end;
    S:='[ENDDATA]';
    WriteSpool(T, Spool, S);
    S:='END.';
    WriteSpool(T, Spool, S);

    If Tagert=stText Then
      CloseFile(T);
  end;

  If LowerCase(tmp1)='sql' Then
  begin
    If PosEx('.sql', FileName)=0 Then
      FileName:=FileName+'.sql';

    If Tagert=stText Then
      AssignFile(T, FileName);

    If Mode='append' Then
    begin
      If Tagert=stText Then
        Append(T);
    end
    Else If Tagert=stText Then
      ReWrite(T);

    If FindParam('table=', Scr)='' Then
    begin
      tmp1:=ExportingTable.SQL.Text;
      v2:=PosEx(' from ', tmp1)+5;
      tmp1:=Copy(ExportingTable.SQL.Text, v2, Length(ExportingTable.SQL.Text));
      tmp1:=TrimLeft(tmp1);
      tmp1:=Copy(tmp1, PosEx(' ', tmp1), Length(tmp1));
    end
    Else
      tmp1:=FindParam('table=', Scr);
    DeleteNonPrintSimb(tmp1);
    ExportTable:=tmp1;

    TableFields:='';
    BlobStr:='';
    For v1:=0 to ExportingTable.FieldCount-1 do
    begin
      TableFields:=TableFields+ExportingTable.Fields[v1].FieldName;
      If v1<>ExportingTable.FieldCount-1 Then
        TableFields:=TableFields+', ';
      If ExportingTable.Fields[v1].DataType in [ftMemo, ftBlob, ftGraphic] Then
      begin
        If BlobStr='' Then
          BlobStr:='SET BLOBFILE '''+FileName+'.lob'';';
      end;
    end;
    WriteSpool(T, Spool, BlobStr);

    MS:=TMemoryStream.Create;
    MS.Clear;
    MS.Seek(0, 0);
    BlobPos:=0;

    While Not ExportingTable.Eof do
    begin
      S:='insert into '+ExportTable+'('+TableFields+') values(';
      For v1:=0 to ExportingTable.FieldCount-1 do
      begin
        If ExportingTable.Fields[v1].DataType<>ftGraphic Then
        begin
          S1:=TrimRight(ExportingTable.Fields[v1].AsString);
          Case ExportingTable.Fields[v1].DataType of
          ftString:
          begin
            S:=S+GPT.StringTypeChar+S1+GPT.StringTypeChar+', ';
          end;
          ftDate, ftTime, ftDateTime, ftBCD, ftFloat, ftCurrency:
          begin
            If S1='' Then
              S:=S+S1+'null, '
            Else
              S:=S+GPT.StringTypeChar+S1+GPT.StringTypeChar+', ';
          end;
          ftSmallint, ftInteger, ftWord, ftBoolean, ftAutoInc:
          begin
            If S1='' Then
              S:=S+S1+'null, '
            Else
              S:=S+S1+', ';
          end;
          ftMemo, ftBlob, ftGraphic:
          begin
            If ExportingTable.Fields[v1].AsString<>'' Then
            begin
              (ExportingTable.Fields[v1] as TBlobField).SaveToStream(MS);
              S1:=':h'+IntToHex(BlobPos, 8)+'_'+IntToHex(ExportingTable.Fields[v1].Size, 8);
              inc(BlobPos, ExportingTable.Fields[v1].Size);
            end
            Else
              S1:='NULL';
            S:=S+S1;
          end;
          end;
        end;
        If v1<>ExportingTable.FieldCount-1 Then
          S:=S+', ';
      end;
      S:=S+');';
      WriteSpool(T, Spool, S);
      ExportingTable.Next;
    end;

    If MS.Size>0 Then
      MS.SaveToFile(FileName+'.lob');

    If Tagert=stText Then
      CloseFile(T);
  end;

  If SpoolFileName='' Then
    SpoolFileName:='spool.txt';

  If Not IsFullPAth(SpoolFileName) Then
    SpoolFileName:=IncludeTrailingPathDelimiter(AppConfigDir)+SpoolFileName;

  If Spool.Count>0 Then
    Spool.SaveToFile(SpoolFileName);
end;

function TDCLCommand.ExpressionParser(Expression: String): String;
var
  ExpressionTmp, ExpressionTmp1: String;
  DCLQuery: TDCLDialogQuery;
begin
  Result:='';
  ExpressionTmp:=FindParam('SQL=', Expression);
  If ExpressionTmp<>'' Then
  begin
    TranslateValContext(ExpressionTmp);

    DCLQuery:=TDCLDialogQuery.Create(nil);
    DCLQuery.Name:='Expression_'+IntToStr(UpTime);
    FDCLLogOn.SetDBName(DCLQuery);
    DCLQuery.SQL.Text:=ExpressionTmp;
    try
      DCLQuery.Open;
    Except
      ShowErrorMessage( - 1102, 'SQL='+ExpressionTmp);
    end;
    ExpressionTmp1:=FindParam('ReturnField=', Expression);
    TranslateValContext(ExpressionTmp1);
    If ExpressionTmp1='' Then
      If DCLQuery.Active Then
        ExpressionTmp1:=DCLQuery.Fields[0].FieldName;
    If DCLQuery.Active Then
      Result:=TrimRight(DCLQuery.FieldByName(ExpressionTmp1).AsString);
    If DCLQuery.Active Then
      DCLQuery.Close;
    FreeAndNil(DCLQuery);
  end
  Else
  begin
    TranslateValContext(Expression);
    Result:=Expression;
  end;
end;

procedure TDCLCommand.ExtractScriptFile(FileName: String);
begin
  FDCLLogOn.ExtractScriptFile(FileName);
end;

function TDCLCommand.GetRaightsByContext(InContext: Boolean): TUserLevelsType;
begin
  If InContext Then
    Result:=FDCLForm.UserLevelLocal
  Else
    Result:=FDCLLogOn.AccessLevel;
end;

procedure TDCLCommand.RePlaseParamss(var ParamsSet: String; Query: TDCLDialogQuery);
begin
  RePlaseParams_(ParamsSet, Query);
end;

procedure TDCLCommand.RePlaseVariabless(var Variables: String);
begin
  If Assigned(FDCLForm) Then
    FDCLForm.RePlaseVariables(Variables);
  FDCLLogOn.RePlaseVariables(Variables);
end;

{ TDCLLogOn }

procedure TDCLLogOn.About(Sender: TObject);
Const
  FormWidth=435;
  FormHeight=300;
  PanelLeft=8;
var
  AboutForm: TForm;
  DCLImage: TImage;
  AboutPanel: TPanel;
  AboutLabel: TLabel;
  OkButton: TButton;
  DBStringMemo: TMemo;
  DBString: String;
begin
  AboutForm:=TForm.Create(nil);
  With AboutForm do
  begin
    BorderStyle:=bsDialog;
    Caption:='?...';
    ClientHeight:=FormHeight;
    ClientWidth:=FormWidth;
    Position:=poScreenCenter;
  end;

  AboutPanel:=TPanel.Create(AboutForm);
  AboutPanel.Parent:=AboutForm;
  With AboutPanel do
  begin
    Left:=PanelLeft;
    Top:=8;
    Width:=FormWidth-PanelLeft*2;
    Height:=FormHeight-PanelLeft*2;
    BevelInner:=bvRaised;
    BevelOuter:=bvLowered;
    ParentColor:=True;
    TabOrder:=0;
  end;

  DCLImage:=TImage.Create(AboutPanel);
  DCLImage.Parent:=AboutPanel;
  DCLImage.Top:=10;
  DCLImage.Left:=8;
  DCLImage.Height:=64;
  DCLImage.Width:=64;
  DCLImage.Stretch:=True;

  DCLImage.Picture.Bitmap:=DrawBMPButton('Logo');

  DCLImage.Transparent:=True;

  AboutLabel:=TLabel.Create(AboutPanel);
  AboutLabel.Parent:=AboutPanel;
  With AboutLabel do
  begin
    Left:=80;
    Top:=8;
    Width:=150;
    Height:=13;
    Caption:=GetDCLMessageString(msTheProduct)+' : DCL Run ('+DBEngineType+')';
  end;

  AboutLabel:=TLabel.Create(AboutPanel);
  AboutLabel.Parent:=AboutPanel;
  With AboutLabel do
  begin
    Left:=80;
    Top:=45;
    Width:=44;
    Height:=13;
    Caption:=GetDCLMessageString(msProducer)+':';
  end;

  AboutLabel:=TLabel.Create(AboutPanel);
  AboutLabel.Parent:=AboutPanel;
  With AboutLabel do
  begin
    Left:=80+90;
    Top:=45;
    Width:=135;
    Height:=15;
    Caption:='Unreal Software (C) 2002-'+IntToStr(YearOf(Now));
    Font.Color:=clWindowText;
    Font.Height:= - 12;
    Font.Style:=[fsBold, fsItalic];
    ParentFont:=False;
  end;

  AboutLabel:=TLabel.Create(AboutPanel);
  AboutLabel.Parent:=AboutPanel;
  With AboutLabel do
  begin
    Left:=80;
    Top:=25;
    Width:=62;
    Height:=13;
    Caption:=GetDCLMessageString(msVersion)+' DCL : '+Version+', '+
        GetDCLMessageString(msStatus)+' : '+ReliseStatues[ReleaseStatus]+'.'
{$IFDEF IBX}+' IBX v.'{$IFNDEF FPC}+FloatToStr(IBX_Version){$ENDIF}{$ENDIF}
{$IFDEF ZEOS}+' ZEOS v.'+FDBLogOn.Version{$ENDIF}
{$IFDEF ADO}+' ADO.db v.'+FDBLogOn.Version{$ENDIF}
{$IFDEF SQLdbFamily}+' SQLdb v.'+AboutForm.LCLVersion{$ENDIF};
  end;

  AboutLabel:=TLabel.Create(AboutPanel);
  AboutLabel.Parent:=AboutPanel;
  With AboutLabel do
  begin
    Left:=80;
    Top:=65;
    Width:=62;
    Height:=13;
    Caption:=GetDCLMessageString(msUser)+'/ '+GetDCLMessageString(msRole)+' : '+
      GPT.DCLLongUserName+' ('+IntToStr(Ord(FAccessLevel))+') / '+GPT.LongRoleName+' ('+
      IntToStr(RoleRaightsLevel)+')';
  end;

{$IFDEF SERVERDB}
  DBString:=GPT.ServerName+':'+GPT.DBPath;
{$ENDIF}
{$IFDEF ADO}
  DBString:=GPT.ConnectionString;
{$ENDIF}
{$IFDEF ZEOS}
  DBString:='('+GPT.DBType+') '+DBString;
{$ENDIF}
  DBStringMemo:=TMemo.Create(AboutPanel);
  DBStringMemo.Parent:=AboutPanel;
  With DBStringMemo do
  begin
    ReadOnly:=True;
    Color:=AboutPanel.Color;
    //BorderStyle:=bsNone;
    Left:=8;
    Top:=95;
    Width:=FormWidth-PanelLeft*4;
    Height:=42;
    Text:=GetDCLMessageString(msDataBase)+' : '+DBString;
    Font.Color:=clWindowText;
    Font.Height:= - 12;
    //Font.Style:=[fsBold, fsItalic];
    ParentFont:=False;
  end;

  DBStringMemo:=TMemo.Create(AboutPanel);
  DBStringMemo.Parent:=AboutPanel;
  With DBStringMemo do
  begin
    ReadOnly:=True;
    Color:=AboutPanel.Color;
    //BorderStyle:=bsNone;
    Left:=8;
    Top:=95+42+8;
    Width:=FormWidth-PanelLeft*4;
    Height:=70;
    Text:=GetDCLMessageString(msConfiguration)+' : '+GetConfigInfo+
      ' /'+GetDCLMessageString(msVersion)+' : '+GetConfigVersion;
    Font.Color:=clWindowText;
    Font.Height:= - 12;
    //Font.Style:=[fsBold, fsItalic];
    ParentFont:=False;
  end;

  AboutLabel:=TLabel.Create(AboutPanel);
  AboutLabel.Parent:=AboutPanel;
  With AboutLabel do
  begin
    Left:=8;
    Top:=222;
    Width:=62;
    Caption:=GetDCLMessageString(msInformationAbout)+' '+
        GetDCLMessageString(msBuildOf)+': '+GetDCLMessageString(msOS)+': '+TargetOS+'. CPU: '+
      TargetCPU+'.'{$IFDEF FPC}+' fpc: '+fpcVersion+'. LCL version: '+AboutForm.LCLVersion+'.'
{$IFDEF UNIX}+' '+GetDCLMessageString(msLang)+': '+SysUtils.GetEnvironmentVariable
      ('LANG')+'.'{$ENDIF}
{$ENDIF};
  end;

  If GPT.DebugOn Then
  begin
    AboutLabel:=TLabel.Create(AboutPanel);
    AboutLabel.Parent:=AboutPanel;
    With AboutLabel do
    begin
      Left:=8;
      Top:=245;
      Width:=62;
      Caption:=GetDCLMessageString(msDebugMode)+': '+GetOnOffMode(GPT.DebugOn);
    end;
  end;

  OkButton:=TButton.Create(AboutForm);
  OkButton.Parent:=AboutForm;
  With OkButton do
  begin
    Left:=(FormWidth div 2)-(75 div 2);
    Top:=FormHeight-PanelLeft*2-30;
    Width:=75;
    Height:=25;
    Caption:='OK';
    default:=True;
    Cancel:=True;
    ModalResult:=1;
    TabOrder:=0;
  end;
  AboutForm.ShowModal;
  FreeAndNil(AboutForm);
end;

function TDCLLogOn.AddVirtualScript(Scr: RVirtualScript):Integer;
var
  l, f:Integer;
begin
  f:=FindVirtualScript(Scr.ScriptName);
  If f=-1 then
  Begin
    l:=Length(VirtualScripts);
    SetLength(VirtualScripts, l+1);
  End
  Else
    l:=f;

  VirtualScripts[l].ScriptName:=Scr.ScriptName;
  VirtualScripts[l].ScrCommand:=Scr.ScrCommand;
  VirtualScripts[l].ScrText:=Scr.ScrText;

  Result:=l;
end;

function TDCLLogOn.CheckPass(UserName, EnterPass, Password: String): Boolean;
begin
  If GPT.HashPass Then
    Result:=(Password=HashString(EnterPass))and(UserName<>'')and(Password<>'')
  Else
    Result:=(Password=EnterPass)and(UserName<>'')and(Password<>'');

  If Result Then
    RoleOK:=lsLogonOK;
end;

procedure TDCLLogOn.CloseAllForms;
var
  i:Integer;
begin
  FBusyMode:=True;
  i:=FForms.Count;
  while FForms.Count<>0 do
  begin
    If Assigned(Forms[i-1]) then
    Begin
      Try
        Forms[i-1].Destroy;
      Except
        //
      End;
    End
    Else
      FForms.Delete(i-1);
    i:=FForms.Count;
  end;
  FBusyMode:=False;
  while IsBusy do Application.HandleMessage;
end;

procedure TDCLLogOn.CloseForm(Form: TDCLForm);
begin
  FBusyMode:=True;
  If Assigned(Form) then
  begin
    Try
      Form.Destroy;
    Except
      KillerDog.Enabled:=False;
      FBusyMode:=False;
    End;
  end;
  FBusyMode:=False;
end;

procedure TDCLLogOn.CloseFormNum(FormNum: Integer);
begin
  If ((FForms.Count>FormNum) and (FormNum>=0)) Then
    If Assigned(Forms[FormNum]) Then
      CloseForm(Forms[FormNum]);
end;

destructor TDCLLogOn.Destroy;
begin
  CloseAllForms;
  while IsBusy do Application.HandleMessage;

  KillerDog.Enabled:=False;
  FreeAndNil(KillerDog);
  Disconnect;
end;

function TDCLLogOn.ConnectDB: Integer;
begin
{$IFDEF ADO}
  If Length(GPT.ConnectionString)>20 Then
  begin
    If CompareString(GPT.DBType, DBTypeFirebird) then
      GPT.IBAll:=True;

    GPT.NewConnectionString:='';
    FDBLogOn.ConnectionString:=GPT.ConnectionString;
    FDBLogOn.LoginPrompt:=False;

    try
      If FDBLogOn.Properties.Count>0 Then
        FDBLogOn.Open;
      Result:=0;
      ConnectErrorCode:=0;
    Except
      On E: Exception do
      begin
        DebugProc('  ... Fail');
        ConnectErrorCode:=255;
        ShowErrorMessage(0, GetDCLMessageString(msConnectDBError)+' 0000 / '+
              E.Message);
        Result:=255;
      end;
    end;
  end
  Else
  begin
    ConnectErrorCode:=255;
    Result:=255;
    ShowErrorMessage(0, GetDCLMessageString(msConnectionStringIncorrect)+
          ' 0100');
  end;
{$ENDIF}
{$IFDEF IBX}
  GPT.NewDBUserName:='';
  GPT.IBAll:=True;

  If Not Assigned(FDBLogOn.DefaultTransaction) Then
  begin
    IBTransaction:=TTransaction.Create(nil);
    IBTransaction.Params.Clear;
    IBTransaction.Params.Append('nowait');
    IBTransaction.Params.Append('read_committed');
    IBTransaction.Params.Append('rec_version');
    IBTransaction.DefaultAction:=TACommit;
    {$IFNDEF FPC}
    IBTransaction.AllowAutoStart:=True;
    {$ENDIF}
    IBTransaction.DefaultDataBase:=FDBLogOn;
    FDBLogOn.DefaultTransaction:=IBTransaction;
  end
  Else
    IBTransaction:=FDBLogOn.DefaultTransaction;

  If Not FDBLogOn.Connected Then
  begin
    If GPT.DBPath<>'' Then
    begin
      {$IFDEF FPC}
      If GPT.LibPath<>'' Then
        FDBLogOn.LibraryName:=GPT.LibPath
      Else
        FDBLogOn.LibraryName:=DefaultLibraryLocation;
      {$ENDIF}

      FDBLogOn.Params.Clear;
      If Not IsFullPAth(GPT.DBPath) Then
        GPT.DBPath:=ExtractFilePath(Application.ExeName)+GPT.DBPath;

      If IsUNCPath(GPT.DBPath) Then
      begin
        DebugProc('  DBPath: '+GPT.DBPath);
        DebugProc('UNC paths not supported.');
        ShowErrorMessage(0, 'UNC '+GetDCLMessageString(msPathsNotSupported)+'.');
        Result:=255;
        Exit;
      end;

      If GPT.ServerName<>'' Then
      begin
        FDBLogOn.DatabaseName:=GPT.ServerName+':'+GPT.DBPath;
        DebugProc('  DBPath: '+GPT.ServerName+':'+GPT.DBPath);
      end
      Else
      begin
        FDBLogOn.DatabaseName:=GPT.DBPath;
        DebugProc('  DBPath: '+GPT.DBPath);
      end;
      FDBLogOn.Params.Append('USER_NAME='+GPT.DBUserName);
      DebugProc('  USER NAME='+GPT.DBUserName);
      If GPT.DBPassword<>'' Then
      begin
        FDBLogOn.Params.Append('PASSWORD='+GPT.DBPassword);
        FDBLogOn.LoginPrompt:=False;
      end
      Else
        FDBLogOn.LoginPrompt:=True;

      If GPT.ServerCodePage='' Then
      Begin
        GPT.ServerCodePage:=ReplaseCPtoWIN(DefaultSystemEncoding);
        FDBLogOn.Params.Append('lc_ctype='+ReplaseCPtoWIN(DefaultSystemEncoding));
      End
      Else
        FDBLogOn.Params.Append('lc_ctype='+UpperCase(ReplaseCPtoWIN(GPT.ServerCodePage)));

      FDBLogOn.SQLDialect:=GPT.SQLDialect;
      try
        DebugProc('Connected...');
        FDBLogOn.Open;

        IBTransaction.DefaultAction:=TACommit; // Retaining;
        IBTransaction.DefaultDataBase:=FDBLogOn;
        FDBLogOn.DefaultTransaction:=IBTransaction;

        DebugProc('  ... OK');
        Result:=0;
        ConnectErrorCode:=0;
      Except
        On E: Exception do
        begin
          DebugProc('  ... Fail');
          ConnectErrorCode:=255;
          ShowErrorMessage(0, GetDCLMessageString(msConnectDBError)+' 0000 / '+
                E.Message);
          Result:=255;
        end;
      end;
    end;
  end
  Else
    Result:=0;
{$ENDIF}
{$IFDEF ZEOS}
  GPT.NewDBUserName:='';

  If Not FDBLogOn.Connected Then
  If GPT.DBPath<>'' Then
  begin
    If PosEx(DBTypeFirebird, GPT.DBType)>0 then
    Begin
      GPT.IBAll:=True;
      GPT.DBType:=DefaultDBType;
    End;
    If PosEx(DBTypeInterbase, GPT.DBType)>0 then
    Begin
      GPT.IBAll:=True;
      GPT.DBType:=DefaultDBTInterBaseType;
    End;

    If Not IsFullPAth(GPT.DBPath) Then
      GPT.DBPath:=ExtractFilePath(Application.ExeName)+GPT.DBPath;

    If IsUNCPath(GPT.DBPath) Then
    begin
      DebugProc('  DBPath: '+GPT.DBPath);
      DebugProc('UNC paths not supported.');
      ShowErrorMessage(0, 'UNC '+GetDCLMessageString(msmsPathsNotSupportedPaths)+'.');
      Result:=255;
      Exit;
    end;

    GPT.NewDBUserName:='';
    FDBLogOn.AutoEncodeStrings:=True;
    FDBLogOn.TransactIsolationLevel:=tiReadCommitted;
    FDBLogOn.AutoCommit:=True;
    FDBLogOn.SQLHourGlass:=True;

    FDBLogOn.Database:=GPT.DBPath;
    If GPT.ServerName<>'' Then
    begin
      If Pos('/', GPT.ServerName)<>0 Then
      begin
        GPT.Port:=StrToIntEx(Copy(GPT.ServerName, Pos('/', GPT.ServerName)+1,
            Length(GPT.ServerName)));
        Delete(GPT.ServerName, Pos('/', GPT.ServerName), Length(GPT.ServerName));
      end;
      FDBLogOn.HostName:=GPT.ServerName;
      If GPT.Port=0 Then
        GPT.Port:=DefaultIBPort;
      DebugProc('  DBPath: '+GPT.ServerName+':'+GPT.DBPath);
    end
    Else
    begin
      DebugProc('  DBPath: '+GPT.DBPath);
    end;

    FDBLogOn.User:=GPT.DBUserName;
    DebugProc('  USER NAME='+GPT.DBUserName);

    If GPT.Port<>0 Then
      FDBLogOn.Port:=GPT.Port;

    If GPT.DBPassword<>'' Then
    begin
      DebugProc('  Password=******');
      FDBLogOn.Password:=GPT.DBPassword;
      FDBLogOn.LoginPrompt:=False;
    end
    Else
      FDBLogOn.LoginPrompt:=True;

    FDBLogOn.Protocol:=GPT.DBType;
    If GPT.LibPath<>'' Then
      FDBLogOn.LibraryLocation:=GPT.LibPath
    Else
      FDBLogOn.LibraryLocation:=DefaultLibraryLocation;

{$IFDEF FPC}
    GPT.ServerCodePage:=NormalizeEncoding(GPT.ServerCodePage);
{$ENDIF}
    If GPT.ServerCodePage='' Then
    begin
      FDBLogOn.Properties.Append('lc_ctype='+DefaultSystemEncoding);
      GPT.ServerCodePage:=DefaultSystemEncoding;
    end
    Else
      FDBLogOn.Properties.Append('lc_ctype='+UpperCase(GPT.ServerCodePage));

    try
      DebugProc('Connected...');
      FDBLogOn.Connect;
      DebugProc('  ... OK');
      Result:=0;
      ConnectErrorCode:=0;
    Except
      On E: Exception do
      begin
        DebugProc('  ... Fail');
        ConnectErrorCode:=255;
        ShowErrorMessage(0, GetDCLMessageString(msConnectDBError)+' 0000 / '+
              E.Message);
        Result:=255;
      end;
    end;
  end;
{$ENDIF}
{$IFDEF SQLdbIB}
  DebugProc('Creating Connection...');
  FDBLogOn.Charset:='UTF8';

  if GPT.ServerCodePage='' then
    GPT.ServerCodePage:='utf8';

  GPT.IBAll:=True;
  If Not Assigned(FDBLogOn.Transaction) Then
  Begin
    IBTransaction:=TTransaction.Create(nil);
    IBTransaction.Params.Clear;
    IBTransaction.Params.Append('nowait');
    IBTransaction.Params.Append('read_committed');
    IBTransaction.Params.Append('rec_version');
    IBTransaction.Action:=caCommit;
    IBTransaction.DataBase:=FDBLogOn;
    FDBLogOn.Transaction:=IBTransaction;
  // IBTransaction.Action:=TACommitRetaining;
  End
  Else
    IBTransaction:=FDBLogOn.Transaction;

  If GPT.LibPath<>'' Then
  begin
    FSQLDBLibraryLoader:=TSQLDBLibraryLoader.Create(Application);
    FSQLDBLibraryLoader.ConnectionType:='Firebird';
    FSQLDBLibraryLoader.LibraryName:=GPT.LibPath;
    FSQLDBLibraryLoader.Enabled:=True;
  end;

  If Not FDBLogOn.Connected Then
  begin
    If GPT.DBPath<>'' Then
    begin
      If Not IsFullPAth(GPT.DBPath) Then
        GPT.DBPath:=ExtractFilePath(Application.ExeName)+GPT.DBPath;

      If GPT.ServerName<>'' Then
      begin
        FDBLogOn.DatabaseName:=GPT.DBPath;
        FDBLogOn.HostName:=GPT.ServerName;
        DebugProc('  DBPath: '+GPT.ServerName+':'+GPT.DBPath);
      end
      Else
      begin
        FDBLogOn.DatabaseName:=GPT.DBPath;
        FDBLogOn.HostName:='';
        DebugProc('  DBPath: '+GPT.DBPath);
      end;
      FDBLogOn.UserName:=GPT.DBUserName;
      DebugProc('  USER NAME='+GPT.DBUserName);
      If GPT.DBPassword<>'' Then
      begin
        FDBLogOn.Password:=GPT.DBPassword;
        FDBLogOn.LoginPrompt:=False;
      end
      Else
        FDBLogOn.LoginPrompt:=True;

      If GPT.ServerCodePage='' Then
        FDBLogOn.Charset:='utf8'
      Else
        FDBLogOn.Charset:=ReplaseCPtoWIN(GPT.ServerCodePage);

      FDBLogOn.Dialect:=GPT.SQLDialect;
      IBTransaction.Database:=FDBLogOn;
      try
        DebugProc('Connected...');
        FDBLogOn.Open;
        DebugProc('  ... OK');
        Result:=0;
        ConnectErrorCode:=0;
      Except
        On E: Exception do
        begin
          DebugProc('  ... Fail');
          ConnectErrorCode:=255;
          ShowErrorMessage(0, GetDCLMessageString(msConnectDBError)+' 0000 / '+
                E.Message);
          Result:=255;
        end;
      end;
    end;
  end
  else
    Result:=0; 
{$ENDIF}
{$IFDEF SQLdb}
  DebugProc('Creating Connection...');
  FDBLogOn.Charset:='UTF8';

  If PosEx(DBTypeFirebird, GPT.DBType)>0 then
  Begin
    GPT.IBAll:=True;
    GPT.DBType:=DBTypeFirebird;
  End;
  If PosEx(DBTypeInterbase, GPT.DBType)>0 then
  Begin
    GPT.IBAll:=True;
    GPT.DBType:=DBTypeFirebird;
  End;
  If Not Assigned(FDBLogOn.Transaction) Then
  Begin
    IBTransaction:=TTransaction.Create(nil);
    IBTransaction.Params.Clear;
    IBTransaction.Params.Append('nowait');
    IBTransaction.Params.Append('read_committed');
    If GPT.IBAll then
      IBTransaction.Params.Append('rec_version');
    IBTransaction.Action:=caCommit;
    IBTransaction.DataBase:=FDBLogOn;
    FDBLogOn.Transaction:=IBTransaction;
  End
  Else
    IBTransaction:=FDBLogOn.Transaction;

  If Not FDBLogOn.Connected Then
  begin
    If GPT.DBPath<>'' Then
    begin
      If Not IsFullPAth(GPT.DBPath) Then
        GPT.DBPath:=ExtractFilePath(Application.ExeName)+GPT.DBPath;

      FDBLogOn.ConnectorType:=GPT.DBType;
      If GPT.ServerName<>'' Then
      begin
        FDBLogOn.DatabaseName:=GPT.DBPath;
        FDBLogOn.HostName:=GPT.ServerName;
        DebugProc('  DBPath: '+GPT.ServerName+':'+GPT.DBPath);
      end
      Else
      begin
        FDBLogOn.DatabaseName:=GPT.DBPath;
        FDBLogOn.HostName:='';
        DebugProc('  DBPath: '+GPT.DBPath);
      end;
      FDBLogOn.UserName:=GPT.DBUserName;
      DebugProc('  USER NAME='+GPT.DBUserName);
      If GPT.DBPassword<>'' Then
      begin
        FDBLogOn.Password:=GPT.DBPassword;
        FDBLogOn.LoginPrompt:=False;
      end
      Else
        FDBLogOn.LoginPrompt:=True;

      If GPT.ServerCodePage='' Then
        FDBLogOn.Charset:='utf8'
      Else
        FDBLogOn.Charset:=ReplaseCPtoWIN(GPT.ServerCodePage);

      IBTransaction.Database:=FDBLogOn;
      try
        DebugProc('Connected...');
        FDBLogOn.Open;
        DebugProc('  ... OK');
        Result:=0;
        ConnectErrorCode:=0;
      Except
        On E: Exception do
        begin
          DebugProc('  ... Fail');
          ConnectErrorCode:=255;
          ShowErrorMessage(0, GetDCLMessageString(msConnectDBError)+' 0000 / '+
                E.Message);
          Result:=255;
        end;
      end;
    end;
  end
  else
    Result:=0;
{$ENDIF}

  If Not Assigned(ShadowQuery)and(Result=0) Then
  begin
    ShadowQuery:=TDCLDialogQuery.Create(nil);
    ShadowQuery.Name:='DCLLogOn_ShadowQuery';
    SetDBName(ShadowQuery);
  end;
end;

constructor TDCLLogOn.Create(DBLogOn: TDBLogOn);
begin
{$IFDEF ADO}
  CoInitialize(nil);
{$ENDIF}
  FBusyMode:=False;
  FForms:=TList.Create;
  RoleOK:=lsNotNeed;
  CurrentForm:= - 1;
  RoleRaightsLevel:=0;
  FAccessLevel:=ulExecute;
  Variables:=TVariables.Create(Self, nil);

  GPT.DBUserName:='';
  GPT.DCLUserName:='';
  GPT.DCLUserPass:='';
  GPT.EnterPass:='';
  GPT.LongRoleName:='';
  GPT.StringTypeChar:='''';
  GPT.SQLDialect:=3;
  GPT.DisableLogOnWithoutUser:=False;

  GPT.NoParamsTable:=False;

  GPT.DCLTable:=DCL_TablePrefix+'SCRIPTS';
  GPT.DCLNameField:='DCLName';
  GPT.DCLTextField:='DCLText';
  GPT.IdentifyField:='Ident';
  GPT.ParentFlgField:='Parent';
  GPT.CommandField:='Command';
  GPT.NumSeqField:='NumSeq';

  GPT.GPTTableName:=DCL_TablePrefix+'GLOBAL_PARAMS';
  GPT.GPTNameField:='Param_Name';
  GPT.GPTValueField:='Param_Value';
  GPT.GPTUserIDField:='PARAM_USERID';

  GPT.ACTIVE_USERS_TABLE:=DCL_TablePrefix+'ACTIVE_USERS';
  GPT.USER_LOGIN_HISTORY_TABLE:=DCL_TablePrefix+'USER_LOGIN_HISTORY';

  GPT.ShowRoleField:='SHOWINLIST';
  GPT.MultiRolesMode:=False;

  GPT.NotifycationsTable:=DCL_TablePrefix+'NOTIFYCATIONS';

  GPT.TemplatesTable:=DCL_TablePrefix+'TEMPLATES';
  GPT.TemplatesKeyField:='TEID';
  GPT.TemplatesNameField:='TEMPL_NAME';
  GPT.TemplatesDataField:='TEMPL_DATA';

  GPT.UpperString:=' upper(';
  GPT.UpperStringEnd:=') ';

  GPT.FormPosInDB:=isDisk;

  NewLogOn:=Not Assigned(DBLogOn);
  If NewLogOn Then
  begin
    FDBLogOn:=TDBLogOn.Create(Application);
    FDBLogOn.Name:='DCL_DBLogOn1';
  end
  Else
    FDBLogOn:=DBLogOn;

{$IFDEF ADO}
  FDBLogOn.KeepConnection:=True;
{$ENDIF}
  KillerDog:=TTimer.Create(nil);
  KillerDog.Interval:=KillerTimerInterval;
  KillerDog.OnTimer:=KillerForms;
  KillerDog.Enabled:=True;
end;

function TDCLLogOn.CreateForm(FormName: String; ParentForm, CallerForm: TDCLForm; Query: TDCLDialogQuery;
  Data: TDataSource; ModalMode: Boolean; ReturnValueMode: TChooseMode;
  ReturnValueParams: TReturnValueParams=nil; Script:TStringList=nil): TDCLForm;
var
  i: Integer;
  Scr: TStringList;
  FormPoint:Pointer;
begin
  For i:=1 to FForms.Count do
  begin
    If Assigned(Forms[i-1]) then
    if Forms[i-1].IsSingle and (Forms[i-1].DialogName=FormName) then
    begin
      Forms[i-1].Form.BringToFront;
      Result:=nil;
      Exit;
    end;
  end;

  If not Assigned(Script) then
    Scr:=LoadScrText(FormName)
  Else
  Begin
    Scr:=TStringList.Create;
    Scr.Text:=Script.Text;
  End;

  i:=FForms.Count;
  FormPoint:=TDCLForm.Create(FormName, Self, ParentForm, CallerForm, i, Scr, Query, Data, ModalMode,
    ReturnValueMode, ReturnValueParams);

  if Assigned(FormPoint) then
    FForms.Add(FormPoint);
  i:=FForms.Count-1;
  CurrentForm:=i;

  If Assigned(Forms[i]) then
  If Forms[i].ExitCode=0 Then
  begin
    If Assigned(FDCLMainMenu) Then
      FDCLMainMenu.UpdateFormBar;
    Result:=Forms[i];
  end
  Else
  begin
    CloseFormNum(i);
    Result:=nil;
  end;
  FreeAndNil(Scr);
end;

procedure TDCLLogOn.CreateMenu(MainForm: TForm);
begin
  FMainForm:=MainForm;
  If Not Assigned(MainForm) Then
    FMainForm:=TForm.Create(nil);

  If Assigned(FDCLMainMenu) Then
  begin
    FreeAndNil(FDCLMainMenu);
  end;

  FDCLMainMenu:=TDCLMainMenu.Create(Self, MainForm);
  If ConnectErrorCode=0 Then
    LoadMainFormPos(Self, MainForm, MainFormName);
end;

procedure TDCLLogOn.Disconnect;
begin
  LoggingUser(False);
{$IFNDEF EMBEDDED}
  If FDBLogOn.Connected then
    FDBLogOn.Connected:=False;
{$ENDIF}  
end;

procedure TDCLLogOn.ReconnectDB;
var
  i: Integer;
begin
  For i:=1 to FormsCount do
    TDCLForm(FForms[i-1]).CloseDatasets;

  FDBLogOn.Connected:=False;
  FDBLogOn.Connected:=True;

  For i:=1 to FormsCount do
    TDCLForm(FForms[i-1]).ResumeDatasets;
end;

procedure TDCLLogOn.ExecShellCommand(ShellCommandText: String);
var
  Bat: TStringList;
  sBAT: String;
begin
  Bat:=TStringList.Create;
  Bat.Text:=ShellCommandText;
  If Bat.Count>0 Then
  begin
    If PosEx('script type=ShellCommand', Bat[0])<>0 Then
      Bat.Delete(0);
  end;
  If Bat.Count>0 Then
  begin
{$IFDEF UNIX}
    Bat.Insert(0, '#/bin/sh');
{$ENDIF}
    sBAT:=Bat.Text;
    RePlaseVariables(sBAT);
    Bat.Text:=sBAT;
    Bat.SaveToFile(IncludeTrailingPathDelimiter(AppConfigDir)+'$Batch$.bat');
{$IFDEF UNIX}
    fpChmod(IncludeTrailingPathDelimiter(AppConfigDir)+'$Batch$.bat', &777);
{$ENDIF}
    ExecAndWait(PChar(IncludeTrailingPathDelimiter(AppConfigDir)+'$Batch$.bat'), SW_SHOWNORMAL, True);
    If FileExists(IncludeTrailingPathDelimiter(AppConfigDir)+'$Batch$.bat') Then
      DeleteFile(PChar(IncludeTrailingPathDelimiter(AppConfigDir)+'$Batch$.bat'));
  end;

  FreeAndNil(Bat);
end;

procedure TDCLLogOn.ExecVBS(VBSScript: String);
var
  VBSText: TStringList;
  tmpVBSText: String;
begin
  VBSText:=TStringList.Create;
  VBSText.Text:=VBSScript;
  If VBSText.Count>0 Then
  begin
    If PosEx('script type=VBScript', VBSText[0])<>0 Then
      VBSText.Delete(0);
  end;
  If VBSText.Count>0 Then
  begin
    tmpVBSText:=VBSText.Text;
    RePlaseVariables(tmpVBSText);
    ExecuteStatement(tmpVBSText);
  end;
  FreeAndNil(VBSText);
end;

procedure TDCLLogOn.ExtractScriptFile(FileName: String);
var
  Scr: TStringList;
  tmpMem: TMemoryStream;
  Key, SecKey, User: String;
  p: Integer;
begin
  If FileExists(FileName) Then
  begin
    tmpMem:=TMemoryStream.Create;
    tmpMem.LoadFromFile(FileName);
    Scr:=DecodeScriptData(tmpMem);
    tmpMem.Clear;

    If Scr.Count>1 Then
    begin
      User:='';
      p:=Pos('=', Scr[0]);
      If p<>0 Then
      begin
        User:=Copy(Scr[0], 2, p-2);
        Key:=Copy(Scr[0], p+1, 32);
      end
      Else
        Key:=Copy(Scr[0], 2, 32);
      Scr.Delete(0);
      Scr.SaveToStream(tmpMem);
      tmpMem.Position:=0;
      SecKey:=GetSecKeyData(tmpMem, User);
      If SecKey=Key Then
      begin
        Scr.SaveToFile(ChangeFileExt(FileName, TextScriptFileExt));
      end;
    end;
    FreeAndNil(Scr);
    FreeAndNil(tmpMem);
  end;
end;

function TDCLLogOn.FindVirtualScript(ScriptName: String): Integer;
var
  i:Integer;
begin
  Result:=-1;
  For i:=1 to Length(VirtualScripts) do
  Begin
    If AnsiLowerCase(VirtualScripts[i-1].ScriptName)=AnsiLowerCase(ScriptName) then
    Begin
      Result:=i-1;
      Break;
    End;
  End;
end;

function TDCLLogOn.GetBaseUID: String;
var
  ParamsQuery: TReportQuery;
begin
  Result:='';
  if not GPT.NoParamsTable then
  Begin
    ParamsQuery:=TDCLDialogQuery.Create(nil);
    ParamsQuery.Name:='UID_'+IntToStr(UpTime);
    SetDBName(ParamsQuery);
      ParamsQuery.SQL.Text:='select * from '+GPT.GPTTableName+' where '+GPT.UpperString+
        GPT.GPTNameField+GPT.UpperStringEnd+'='+GPT.UpperString+GPT.StringTypeChar+'BaseUID'+
        GPT.StringTypeChar+GPT.UpperStringEnd;
    ParamsQuery.Open;
    If ParamsQuery.FieldByName(GPT.GPTValueField).AsString='' then
    Begin
      WriteBaseUID;
      Result:=GetBaseUID;
    End
    Else
      Result:=ParamsQuery.FieldByName(GPT.GPTValueField).AsString;
    ParamsQuery.Close;
    FreeAndNil(ParamsQuery);
  End;
end;

function TDCLLogOn.GetBusyMode: Boolean;
begin
  Result:=FBusyMode;
end;

function TDCLLogOn.GetConfigInfo: String;
var
  Q: TDCLDialogQuery;
begin
  If GetConnected then
  Begin
    Q:=TDCLDialogQuery.Create(nil);
    Q.Name:='GetConfInfo_'+IntToStr(UpTime);
    SetDBName(Q);
    Q.SQL.Text:='select '+GPT.DCLTextField+' from '+GPT.DCLTable+' where '+GPT.IdentifyField+'=60000';
    Q.Open;
    Result:=Q.Fields[0].AsString;
    Q.Close;

    FreeAndNil(Q);
  End;
end;

function TDCLLogOn.GetConfigVersion: String;
var
  Q: TDCLDialogQuery;
begin
  If GetConnected then
  Begin
    Q:=TDCLDialogQuery.Create(nil);
    Q.Name:='GetConfVer_'+IntToStr(UpTime);
    SetDBName(Q);
    Q.SQL.Text:='select '+GPT.DCLNameField+' from '+GPT.DCLTable+' where '+GPT.IdentifyField+'=60001';
    Q.Open;
    Result:=Q.Fields[0].AsString;
    Q.Close;

    FreeAndNil(Q);
  End;
end;

function TDCLLogOn.GetConnected: Boolean;
begin
  Result:=FDBLogOn.Connected;
end;

function TDCLLogOn.GetForm(Index: Integer): TDCLForm;
begin
  Result:=nil;
  If FForms.Count>Index Then
    Result:=FForms[Index];
end;

function TDCLLogOn.GetFormsCount: Integer;
begin
  Result:=FForms.Count;
end;

function TDCLLogOn.GetFullRaight: Word;
begin
  Result:=RoleRaightsLevel*16+Ord(FAccessLevel);
end;

function TDCLLogOn.GetSecKeyData(Data: TMemoryStream; UserName: String): String;
var
  DataMD5, PassMD5: TMD5Digest;
  i, tmp1: Byte;
  Pass: String;
  ShadowQuery: TDCLDialogQuery;
begin
  Result:='';
  If Assigned(Data) Then
    If Data.Size>0 Then
    begin
      Data.Position:=0;
      DataMD5:=MD5Stream(Data);
      If UserName='' Then
        Pass:=GPT.DCLUserName+GPT.DCLUserPass
      Else
      begin
        ShadowQuery:=TDCLDialogQuery.Create(Application);
        SetDBName(ShadowQuery);
        ShadowQuery.SQL.Text:='select '+UserPassField+' from '+UsersTable+' where '+UserNameField+
          '='+GPT.StringTypeChar+UserName+GPT.StringTypeChar;
        ShadowQuery.Open;
        ShadowQuery.Last;
        ShadowQuery.First;
        Pass:=UserName;
        If ShadowQuery.RecordCount=1 Then
          Pass:=Pass+TrimRight(ShadowQuery.Fields[0].AsString);
        ShadowQuery.Close;
        FreeAndNil(ShadowQuery);
      end;
      PassMD5:=MD5String(Pass);

      For i:=0 to 15 do
      begin
        tmp1:=DataMD5.v[i] Mod PassMD5.v[i];
        Result:=Result+IntToHex(tmp1, 2);
      end;
    end;
end;

function TDCLLogOn.GetVirtualScript(ScriptName: String): RVirtualScript;
var
  i:Integer;
begin
  RVirtualScriptsClear(Result);
  i:=FindVirtualScript(ScriptName);
  If i<>-1 then
  Begin
    Result.ScrCommand:='';
    Result.ScriptName:=VirtualScripts[i].ScriptName;
    Result.ScrText:=VirtualScripts[i].ScrText;
  End;
end;

function TDCLLogOn.GetVirtualScriptNum(Index: Integer): RVirtualScript;
begin
  If (Index>=0) and (Index<Length(VirtualScripts)) then
  Begin
    Result.ScrCommand:='';
    Result.ScriptName:=VirtualScripts[Index].ScriptName;
    Result.ScrText:=VirtualScripts[Index].ScrText;
  End;
end;

procedure TDCLLogOn.SignScriptFile(FileName, UserName: String);
var
  Scr: TStringList;
  SecKey: String;
  tmpMem: TMemoryStream;
begin
  If FileExists(FileName) Then
  begin
    Scr:=TStringList.Create;
    Scr.LoadFromFile(FileName{$IFNDEF FPC}, TEncoding.UTF8{$ENDIF});
    tmpMem:=TMemoryStream.Create;
    Scr.SaveToStream(tmpMem);
    tmpMem.Position:=0;
    SecKey:=GetSecKeyData(tmpMem, UserName);

    If UserName='' Then
      Scr.Insert(0, '['+SecKey+']')
    Else
      Scr.Insert(0, '['+UserName+'='+SecKey+']');

    tmpMem:=EncodeScriptData(Scr);
    tmpMem.SaveToFile(ChangeFileExt(FileName, SignedScriptExt));
    FreeAndNil(tmpMem);
    FreeAndNil(Scr);
  end;
end;

procedure TDCLLogOn.ReSignScriptFile(FileName: String);
var
  Scr: TStringList;
  SecKey: String;
  tmpMem: TMemoryStream;
begin
  If FileExists(FileName) Then
  begin
    tmpMem:=TMemoryStream.Create;
    tmpMem.LoadFromFile(FileName);
    Scr:=DecodeScriptData(tmpMem);
    tmpMem.Clear;
    If Length(Scr.Text)>10 then
    Begin
      If (Pos('[', Scr[0])<>Pos(']', Scr[0])) and (Pos('[', Scr[0])>0) then
        Scr.Delete(0);

      Scr.SaveToStream(tmpMem);
      tmpMem.Position:=0;
      SecKey:=GetSecKeyData(tmpMem, GPT.DCLUserName);

      Scr.Insert(0, '['+GPT.DCLUserName+'='+SecKey+']');

      tmpMem:=EncodeScriptData(Scr);
      tmpMem.SaveToFile(FileName);
    End;
    FreeAndNil(tmpMem);
  end;
end;

procedure TDCLLogOn.RunSkriptFromFile(FileName: String);
var
  Scr, Scr2: TStringList;
  tmpMem: TMemoryStream;
  Key, SecKey, User, Ver, VirtScrName: String;
  p, vsi, vtmp: Integer;
  Command: TDCLCommand;
  Form: TDCLForm;
  VRS:RVirtualScript;

procedure MainParse(Scr:TStringList);
Begin
  If Scr.Count>0 then
  If CompareString(Scr[0], '[FORM]') Then
  begin
    Scr.Delete(0);
    Form:=CreateForm(VirtScrName, nil, nil, nil, nil, False,
      chmNone, nil, Scr);
  end
  Else
  begin
    If CompareString(Scr[0], '[COMMAND]') Then
      Scr.Delete(0);
    Command:=TDCLCommand.Create(nil, Self);
    Command.ExecCommand(Scr.Text, nil);
    FreeAndNil(Command);
  end;
End;

Function FindNextSkriptSection:TStringList;
var
  i, p, p1, j:Integer;
Begin
  Result:=TStringList.Create;
  For i:=1 to Scr.Count do
  Begin
    If (PosEx('[ScriptName=', Scr[i-1])<>0) and (Pos(']', Scr[i-1])=Length(Scr[i-1])) then
    Begin
      VirtScrName:=FindParam('ScriptName=', Scr[i-1]);
      VirtScrName:=Copy(VirtScrName, 1, Length(VirtScrName)-1);
      p:=i;
      For p1:=p to Scr.Count do
      Begin
        If (Scr[p1]='[END SCRIPT]') or (p1+1>=Scr.Count) then
        Begin
          For j:=p to p1 do
          begin
            Result.Append(Scr[p]);
            Scr.Delete(p);
          end;
          Scr.Delete(p-1);
          exit;
        End;
      End;
    End;
  End;
End;

begin
  If FileExists(FileName) Then
  begin
    tmpMem:=TMemoryStream.Create;
    tmpMem.LoadFromFile(FileName);
    Ver:=GetScriptVersion(tmpMem);
    Scr:=DecodeScriptData(tmpMem);
    tmpMem.Clear;

    If Scr.Count>1 Then
    begin
      User:='';
      p:=Pos('=', Scr[0]);
      If p<>0 Then
      begin
        User:=Copy(Scr[0], 2, p-2);
        Key:=Copy(Scr[0], p+1, 32);
      end
      Else
        Key:=Copy(Scr[0], 2, 32);
      Scr.Delete(0);
      Scr.SaveToStream(tmpMem);
      tmpMem.Position:=0;
      SecKey:=GetSecKeyData(tmpMem, User);
      If SecKey=Key Then
      begin
        If Ver='1.2' then
        Begin
          VirtScrName:=ChangeFileExt(ExtractFileName(FileName), '');
          MainParse(Scr);
        End;
        If Ver='1.3' then
        Begin
          vsi:=-1;
          Scr2:=FindNextSkriptSection;
          while Scr2.Count<>0 do
          Begin
            VRS.ScriptName:=VirtScrName;
            VRS.ScrCommand:='';
            VRS.ScrText:=Scr2.Text;
            vtmp:=AddVirtualScript(VRS);
            If vsi=-1 then
              vsi:=vtmp;
            Scr2:=FindNextSkriptSection;
          End;
          Scr2.Text:=GetVirtualScriptNum(vsi).ScrText;
          MainParse(Scr2);
        End;
      end;
    end;
    FreeAndNil(Scr);
    FreeAndNil(tmpMem);
  end;
end;

procedure TDCLLogOn.GetTableNames(var List: TStrings);
begin
{$IFDEF ADO}
  FDBLogOn.GetTableNames(List);
{$ENDIF}
{$IFDEF ZEOS}
  FDBLogOn.GetTableNames('', List);
{$ENDIF}
{$IFDEF SQLdb}
  FDBLogOn.GetTableNames(List, False);
{$ENDIF}
{$IFDEF SQLdbIB}
  FDBLogOn.GetTableNames(List, False);
{$ENDIF}
{$IFDEF IBX}
  FDBLogOn.GetTableNames(List, False);
{$ENDIF}
end;

function TDCLLogOn.GetRolesQueryText(QueryType: TSelectType; WhereStr: String): String;
var
  FromStr, WhereStr1: String;
begin
  If GPT.DCLUserName='' Then
  begin
    FromStr:=GPT.DCLTable+' s';
    WhereStr1:=' where '+WhereStr;
  end
  Else
    If GPT.MultiRolesMode Then
    begin
      FromStr:=GPT.DCLTable+' s, '+RolesMenuTable+' rm, '+RolesTable+' r, '+UsersTable+' u, '+
        RolesToUsersTable+' ru ';
      WhereStr1:='where r.'+RolesIDFiled+'=rm.'+RolesMenuIDFiled+' and rm.'+RoleMenuItemIDField+'=s.'+
        GPT.NumSeqField+' and ru.'+RolesToUsersRoleIDField+'=r.'+RolesIDFiled+' and u.'+UserIDField+
        '=ru.'+RolesToUsersUserIDField+' and u.'+UserIDField+'='+IntToStr(FUserID)+' and '+WhereStr;
    end
    Else
    begin
  {$IFDEF EMBEDDED}
      FromStr:=GPT.DCLTable+' s ';
      WhereStr1:='where '+WhereStr;
  {$ELSE}
      FromStr:=GPT.DCLTable+' s, '+RolesMenuTable+' rm, '+RolesTable+' r, '+UsersTable+' u ';
      WhereStr1:='where r.'+RolesIDFiled+'=rm.'+RolesMenuIDFiled+' and rm.'+RoleMenuItemIDField+'=s.'+
        GPT.NumSeqField+' and u.'+UserRoleField+'=r.'+RolesIDFiled+' and u.'+UserIDField+'='+
        IntToStr(FUserID)+' and '+WhereStr;
  {$ENDIF}
    end;

  Case QueryType of
  qtCount:
  Result:='select Count(*) from '+FromStr+WhereStr1;
  qtSelect:
  If GPT.MultiRolesMode Then
    Result:='select distinct s.* from '+FromStr+WhereStr1
  Else
    Result:='select s.* from '+FromStr+WhereStr1;
  end;
end;

function TDCLLogOn.LoadScrText(ScrName: String): TStringList;
var
  v1:Integer;
begin
  Result:=TStringList.Create;

  v1:=FindVirtualScript(ScrName);
  If v1=-1 then
  Begin
    ShadowQuery.Close;
    ShadowQuery.SQL.Text:='select * from DCL_SCRIPTS where lower(DCLNAME)=lower('''+ScrName+''')';
    ShadowQuery.Open;
    Result.Text:=ShadowQuery.FieldByName('DCLTEXT').AsString;
    ShadowQuery.Close;
  End
  Else
    Result.Text:=GetVirtualScriptNum(v1).ScrText;
end;

procedure TDCLLogOn.Lock;
var
  OldUserID: String;
  Res: TLogOnStatus;
{$IFNDEF EMBEDDED}
  LogOnForm: TLogOnForm;
{$ENDIF}
begin
{$IFNDEF EMBEDDED}
  NotifyForms(fnaHide);
  OldUserID:=GPT.UserID;

  LogOnForm:=TLogOnForm.Create(Self, GPT.DCLUserName, True, True);
  LogOnForm.CreateForm(True, True, GPT.DCLUserName);
  Res:=lsUnInitaliced;
  repeat
    LogOnForm.ShowForm;
    GetUserName(LogOnForm.UserName);
    If CheckPass(LogOnForm.UserName, LogOnForm.EnterPass, GPT.DCLUserPass) Then
      Res:=lsLogonOK;
    If LogOnForm.PressOK=psCanceled Then
      break;
  until Res=lsLogonOK;
  FreeAndNil(LogOnForm);

  If (Res=lsLogonOK)and(OldUserID<>GPT.UserID) Then
    CreateMenu(FMainForm);

  NotifyForms(fnaShow);
{$ENDIF}
end;

procedure TDCLLogOn.LoggingUser(Login: Boolean);
var
  LoggingQuery: TDCLDialogQuery;
  AddSQLStr1, AddSQLStr2:string;
begin
//{$IFNDEF EMBEDDED}
  If FDBLogOn.Connected then
  Begin
    LoggingQuery:=TDCLDialogQuery.Create(nil);
    LoggingQuery.Name:='LoggingUser_'+IntToStr(UpTime);
    SetDBName(LoggingQuery);

    If Login Then
    begin
      AddSQLStr1:='';
      AddSQLStr2:='';
      DCLSession.LoginTime:=TimeStampToStr(Now);
      DCLSession.ComputerName:=GetComputerName;
      DCLSession.IPAdress:=GetLocalIP;
      DCLSession.UserSystemName:=GetUserFromSystem;
      DCLSession.MAC:=GetMacAddress;
    end;

    If GPT.UserLogging Then
    begin
      If DCLSession.LoginTime<>'' Then
      begin
        If Login Then
        begin
          If FieldExists(AU_MAC, nil, GPT.ACTIVE_USERS_TABLE) then
          begin
            AddSQLStr1:=', '+AU_MAC;
            AddSQLStr2:=', '+Quote+DCLSession.MAC+Quote;
          end;

          LoggingQuery.SQL.Text:='insert into '+GPT.ACTIVE_USERS_TABLE+
            '(ACTIVE_USER_ID, ACTIVE_USER_HOST, ACTIVE_USER_IP, ACTIVE_USER_DCL_VER, ACTIVE_USER_LOGIN_TIME'+AddSQLStr1+') '
            +'values('+GPT.UserID+', '''+DCLSession.ComputerName+'/'+DCLSession.UserSystemName+
            ''', '''+DCLSession.IPAdress+''', '''+Version+''', '''+DCLSession.LoginTime+''' '+AddSQLStr2+')';
        end
        Else
          LoggingQuery.SQL.Text:='delete from '+GPT.ACTIVE_USERS_TABLE+' where ACTIVE_USER_ID='+
            GPT.UserID+' and ACTIVE_USER_HOST='''+DCLSession.ComputerName+'/'+
            DCLSession.UserSystemName+''' and '+'ACTIVE_USER_DCL_VER='''+Version+
            ''' and ACTIVE_USER_LOGIN_TIME='''+DCLSession.LoginTime+'''';

        try
          LoggingQuery.ExecSQL;
        Except

        end;
      end;
    end;

    If GPT.UserLoggingHistory Then
    begin
      If DCLSession.LoginTime<>'' Then
      begin
        If Login Then
        Begin
          If FieldExists(UL_MAC, nil, GPT.USER_LOGIN_HISTORY_TABLE) then
          begin
            AddSQLStr1:=', '+UL_MAC;
            AddSQLStr2:=', '+Quote+DCLSession.MAC+Quote;
          end;

          LoggingQuery.SQL.Text:='insert into '+GPT.USER_LOGIN_HISTORY_TABLE+
            '(UL_USER_ID, UL_LOGIN_TIME, UL_HOST_IP, UL_HOST_NAME, UL_DCL_VER'+AddSQLStr1+') '+
            'values('+GPT.UserID+
            ', '''+DCLSession.LoginTime+''', '''+DCLSession.IPAdress+''', '''+DCLSession.ComputerName+
            '/'+DCLSession.UserSystemName+''', '''+Version+''''+AddSQLStr2+')';
        End
        Else
          LoggingQuery.SQL.Text:='update '+GPT.USER_LOGIN_HISTORY_TABLE+' set UL_LOGOFF_TIME='''+
            TimeStampToStr(Now)+''' where '+'UL_USER_ID='+GPT.UserID+' and UL_LOGIN_TIME='''+
            DCLSession.LoginTime+''' and UL_HOST_NAME='''+DCLSession.ComputerName+'/'+
            DCLSession.UserSystemName+''' and UL_DCL_VER='''+Version+'''';
        try
          LoggingQuery.ExecSQL;
        Except

        end;
      end;
    end;

    FreeAndNil(LoggingQuery);
  End;
//{$ENDIF}
end;

function TDCLLogOn.Login(UserName, Password: String; ShowForm: Boolean): TLogOnStatus;
{$IFNDEF EMBEDDED}
var
  LogOnForm: TLogOnForm;
{$ENDIF}
begin
{$IFNDEF EMBEDDED}
  If Not GPT.DisableLogOnWithoutUser Then
    Result:=lsLogonOK
  Else
    Result:=lsRejected;

  GetUserName(UserName);
{$IFDEF DEVELOPERMODE}
  If FAccessLevel<>ulDeveloper Then
{$ELSE}
  If GPT.DisableLogOnWithoutUser Then
    If FAccessLevel=ulDeny Then
{$ENDIF}
    begin
      ShowErrorMessage(1, GetDCLMessageString({$IFDEF DEVELOPERMODE}msDenyMessageDev{$ELSE}msDenyMessageUsr{$ENDIF}));
      Halt;
    end;

  If (((UserName='')or(Password=''))and ShowForm)or GPT.DisableLogOnWithoutUser Then
  begin
    RoleOK:=lsRejected;
    LogOnForm:=TLogOnForm.Create(Self, UserName, False, False);
    LogOnForm.CreateForm(False, False, UserName);
    PassRetries:=0;

    If Not CheckPass(UserName, Password, GPT.DCLUserPass)or ShowForm Then
    begin
      RoleOK:=lsRejected;
      repeat
        Application.Initialize;
        LogOnForm.ShowForm;
        GetUserName(LogOnForm.UserName);
        If CheckPass(LogOnForm.UserName, LogOnForm.EnterPass, GPT.DCLUserPass) Then
        begin
          Result:=lsLogonOK;
          RoleOK:=lsLogonOK;
        end;
        inc(PassRetries);
        If LogOnForm.PressOK=psCanceled Then
        begin
          Halt(0);
        end;
      until (Result=lsLogonOK)or(PassRetries>3);
    end
    Else If CheckPass(UserName, Password, GPT.DCLUserPass) Then
    begin
      Result:=lsLogonOK;
      RoleOK:=lsLogonOK;
    end;

    FreeAndNil(LogOnForm);
  end
  Else
  begin
    If CheckPass(UserName, Password, GPT.DCLUserPass) Then
    begin
      Result:=lsLogonOK;
      RoleOK:=lsLogonOK;
    end;
  end;

  If GPT.UserLogging Then
    GPT.UserLogging:=TableExists(GPT.ACTIVE_USERS_TABLE);

  If GPT.UserLoggingHistory Then
    GPT.UserLoggingHistory:=TableExists(GPT.USER_LOGIN_HISTORY_TABLE);

  LoggingUser(True);

  GPT.UseMessages:=DCLMainLogOn.TableExists(GPT.NotifycationsTable);
  If GPT.UseMessages then
  Begin
    MessageFormObject:=TMessageFormObject.Create('', '');
    
    MessagesTimer:=TTimer.Create(nil);
    MessagesTimer.Interval:=IntervalTimeNotify;
    MessagesTimer.Enabled:=True;
    MessagesTimer.OnTimer:=WaitNotify;
    WaitNotify(nil);
  End;
{$ELSE}
  Result:=lsLogonOK;
  RoleOK:=lsLogonOK;
{$ENDIF}
end;

procedure TDCLLogOn.GetUserName(AUserName: String);
var
  FromStr, WhereStr, DBUserNameField, DBPasswordField: String;
begin
  DBPasswordField:='';
  DBUserNameField:='';
{$IFNDEF EMBEDDED}
  If not GPT.NoUsersTable then
  Begin
    GPT.DCLUserName:=AUserName;
    ShadowQuery.Close;
    SetDBName(ShadowQuery);
    If FieldExists(DBUSER_NAME_Field, nil, UsersTable) Then
      DBUserNameField:=', '+DBUSER_NAME_Field;
    If FieldExists(DBPASS_Field, nil, UsersTable) Then
      DBPasswordField:=', '+DBPASS_Field;

    DebugProc('Selecting role...');
    If LongUserNameField<>'' Then
    begin
      ShadowQuery.Close;
      ShadowQuery.SQL.Text:='select '+UserAdminField+', '+UserIDField+', '+UserPassField+', '+
        LongUserNameField+', '+UserRoleField+', '+RoleNameField+', '+LongRoleNameField+DBUserNameField
        +DBPasswordField+' from '+UsersTable+', '+RolesTable+' where '+GPT.UpperString+UserNameField+
        GPT.UpperStringEnd+'='+GPT.UpperString+GPT.StringTypeChar+AUserName+GPT.StringTypeChar+
        GPT.UpperStringEnd+' and '+UserRoleField+'='+RolesIDFiled;
      DebugProc('  Query: '+ShadowQuery.SQL.Text);
      try
        ShadowQuery.Open;
        DebugProc('  ... OK');
      Except
        On E: Exception do
        begin
          DebugProc('  ... Fail/ '+E.Message);
        end;
      end;
      GPT.DCLLongUserName:=TrimRight(ShadowQuery.FieldByName(LongUserNameField).AsString);
    end;

    If Not ShadowQuery.IsEmpty Then
    begin
      GPT.UserID:=ShadowQuery.FieldByName(UserIDField).AsString;
      FUserID:=ShadowQuery.FieldByName(UserIDField).AsInteger;
      GPT.RoleID:=ShadowQuery.FieldByName(UserRoleField).AsString;
      GPT.LongRoleName:=Trim(ShadowQuery.FieldByName(LongRoleNameField).AsString);
      GPT.DCLRoleName:=Trim(ShadowQuery.FieldByName(RoleNameField).AsString);
      If DBUserNameField<>'' Then
      begin
        Delete(DBUserNameField, 1, 1);
  {$IFDEF ADO}
        GPT.NewConnectionString:=Trim(ShadowQuery.FieldByName(Trim(DBUserNameField)).AsString);
  {$ELSE}
        GPT.NewDBUserName:=Trim(ShadowQuery.FieldByName(Trim(DBUserNameField)).AsString);
  {$ENDIF}
      end;

      If DBPasswordField<>'' Then
      begin
        Delete(DBPasswordField, 1, 1);
        GPT.NewDBPassword:=Trim(ShadowQuery.FieldByName(Trim(DBPasswordField)).AsString);
      end;

      If GPT.DisableLogOnWithoutUser Then
      begin
        try
          FAccessLevel:=TranslateDigitToUserLevel(ShadowQuery.FieldByName(UserAdminField).AsInteger);
        Except
          FAccessLevel:=ulExecute;
        end;
      end
      Else
        FAccessLevel:=ulExecute;

      If GPT.HashPass Then
        GPT.DCLUserPass:=TrimRight(ShadowQuery.FieldByName(UserPassField).AsString)
      Else
        GPT.DCLUserPass:=TrimRight(ShadowQuery.FieldByName(UserPassField).AsString);
    end;

    ShadowQuery.Close;
    If GPT.MultiRolesMode Then
    begin
      FromStr:='select max('+DCLROLE_ACCESSLEVEL_FIELD+') from '+RolesTable+' r, '+UsersTable+' u, '+
        RolesToUsersTable+' ru ';
      WhereStr:='where ru.'+RolesToUsersRoleIDField+'=r.'+RolesIDFiled+' and u.'+UserIDField+'=ru.'+
        RolesToUsersUserIDField;
    end
    Else
    begin
      FromStr:='select '+DCLROLE_ACCESSLEVEL_FIELD+' from '+RolesTable+' r, '+UsersTable+' u ';
      WhereStr:='where u.'+UserRoleField+'=r.'+RolesIDFiled;
    end;
    If GPT.UserID<>'' Then
    begin
      ShadowQuery.Close;
      ShadowQuery.SQL.Text:=FromStr+WhereStr+' and u.'+UserIDField+'='+GPT.UserID;
      try
        ShadowQuery.Open;
        DebugProc('  ... OK');
      Except
        DebugProc('  ... Fail');
      end;
    end;

    RoleRaightsLevel:=0;
    If Not ShadowQuery.IsEmpty Then
    begin
      try
        If FieldExists(DCLROLE_ACCESSLEVEL_FIELD, ShadowQuery) Then
          RoleRaightsLevel:=ShadowQuery.FieldByName(DCLROLE_ACCESSLEVEL_FIELD).AsInteger;
      Except
        RoleRaightsLevel:=0
      end;
    end
    Else
      RoleRaightsLevel:=0;

    ShadowQuery.Close;
  End
  Else
    FAccessLevel:=ulExecute;
{$ELSE}
  FAccessLevel:=ulExecute;
{$ENDIF}
end;

procedure TDCLLogOn.InitActions(Sender: TObject);
var
  MenuQuery: TDCLDialogQuery;
begin
  Timer1.Enabled:=False;
  FreeAndNil(Timer1);

  FDCLMainMenu.LockMenu;

  MenuQuery:=TDCLDialogQuery.Create(nil);
  MenuQuery.Name:='Menu_'+IntToStr(UpTime);
  SetDBName(MenuQuery);

  MenuQuery.SQL.Text:=GetRolesQueryText(qtSelect, ' s.'+GPT.IdentifyField+
      ' between 40001 and 40100 order by s.'+GPT.IdentifyField);
  MenuQuery.Open;
  While Not MenuQuery.Eof do
  begin
    FDCLMainMenu.ChoseRunType(MenuQuery.FieldByName(GPT.CommandField).AsString,
      MenuQuery.FieldByName(GPT.DCLTextField).AsString, MenuQuery.FieldByName(GPT.DCLNameField)
        .AsString, 1);
    MenuQuery.Next;
  end;
  MenuQuery.Close;

  If FileExists(GPT.LaunchScrFile) then
  Begin
    RunSkriptFromFile(GPT.LaunchScrFile);
  End;
  GPT.LaunchScrFile:='';

  If GPT.LaunchForm<>'' then
  Begin
    MenuQuery.SQL.Text:=GetRolesQueryText(qtSelect, ' s.'+GPT.DCLNameField+
        '='+GPT.StringTypeChar+GPT.LaunchForm+GPT.StringTypeChar);
    MenuQuery.Open;
    If Not MenuQuery.Eof then
    begin
      FDCLMainMenu.ChoseRunType('', '',
        MenuQuery.FieldByName(GPT.DCLNameField).AsString, 0);
    end;
    MenuQuery.Close;
  End;

  FDCLMainMenu.UnLockMenu;

  FreeAndNil(MenuQuery);
end;

procedure TDCLLogOn.KillerForms(Sender: TObject);
var
  i:Integer;
begin
  FBusyMode:=True;
  For i:=1 to FForms.Count do
  Begin
    If i<=FForms.Count then
    If Assigned(FForms[i-1]) then
      If TDCLForm(FForms[i-1]).CloseAction=fcaClose then
        CloseForm(FForms[i-1]);
  End;
  FBusyMode:=False;
end;

{$IFDEF TRANSACTIONDB}
function TDCLLogOn.NewTransaction(RW: TTransactionType): TTransaction;
begin
  Result:=TTransaction.Create(FDBLogOn);
  {$IFDEF IBX}
  Result.DefaultDatabase:=FDBLogOn;
  Result.DefaultAction:=TACommit;
  {$ENDIF}
  {$IFDEF SQLdbFamily}
  Result.Database:=FDBLogOn;
  Result.Action:=caCommit;
  {$ENDIF}
  Result.Params.Clear;
  Case RW of
  trtWrite:Begin
    Result.Params.Append('write');
  End;
  trtRead:Begin
    Result.Params.Append('read');
  End;
  End;
  Result.Params.Append('nowait');
  Result.Params.Append('read_committed');
  If GPT.IBAll then
    Result.Params.Append('rec_version');
end;
{$ENDIF}

procedure TDCLLogOn.NotifyForms(Action: TFormsNotifyAction);
var
  i, j, tmpCF: Integer;
begin
  tmpCF:=CurrentForm;
  If FForms.Count>0 Then
    For i:=0 to FormsCount-1 do
      If Assigned(FForms[i]) Then
        Case Action of
        fnaRefresh:
        Forms[i].RefreshForm;
        fnaClose:
        Forms[i].CloseDialog;
        fnaSetMDI:
        Forms[i].FForm.Parent:=MainForm;
        fnaResetMDI:
        Forms[i].FForm.Parent:=nil;
        fnaHide:
        Forms[i].FForm.Hide;
        fnaShow:
        Forms[i].FForm.Show;
        fnaStopAutoRefresh:
        begin
          For j:=1 to Forms[i].TablesCount do
            If Assigned(Forms[i].Tables[j-1].RefreshTimer) Then
              Forms[i].Tables[j-1].RefreshTimer.Enabled:=False;
        end;
        fnaStartAutoRefresh:
        begin
          For j:=1 to Forms[i].TablesCount do
            If Assigned(Forms[i].Tables[j-1]) Then
              If Assigned(Forms[i].Tables[j-1].RefreshTimer) Then
                Forms[i].Tables[j-1].RefreshTimer.Enabled:=True;
        end;
        fnaPauseAutoRefresh:
        begin
          For j:=1 to Forms[i].TablesCount do
            If Assigned(Forms[i].Tables[j-1]) Then
              If Assigned(Forms[i].Tables[j-1].RefreshTimer) Then
                If Forms[i].Tables[j-1].RefreshTimer.Enabled Then
                  Forms[i].Tables[j-1].LastStateTimer:=Forms[i].Tables[j-1]
                    .RefreshTimer.Enabled;
        end;
        fnaResumeAutoRefresh:
        begin
          For j:=1 to Forms[i].TablesCount do
            If Assigned(Forms[i].Tables[j-1]) Then
              If Assigned(Forms[i].Tables[j-1].RefreshTimer) Then
                If Not Forms[i].Tables[j-1].RefreshTimer.Enabled Then
                  Forms[i].Tables[j-1].RefreshTimer.Enabled:=
                    Forms[i].Tables[j-1].LastStateTimer;
        end;
        end;
  CurrentForm:=tmpCF;
end;

function TDCLLogOn.ReadConfig(ConfigName, UserID: String): String;
var
  ParamsQuery: TReportQuery;
  WhereUser: String;
begin
  Result:='';
  WhereUser:='';
  If Not GPT.NoParamsTable Then
  begin
    If UserID<>'' Then
      WhereUser:=' and '+GPT.GPTUserIDField+'='+UserID;

    ParamsQuery:=TDCLDialogQuery.Create(nil);
    ParamsQuery.Name:='Params_'+IntToStr(UpTime);
    SetDBName(ParamsQuery);
    ParamsQuery.SQL.Text:='select '+GPT.GPTValueField+' from '+GPT.GPTTableName+' where '+
      GPT.UpperString+GPT.GPTNameField+GPT.UpperStringEnd+'='+GPT.UpperString+GPT.StringTypeChar+
      ConfigName+GPT.StringTypeChar+GPT.UpperStringEnd+WhereUser;
    ParamsQuery.Open;
    Result:=TrimRight(ParamsQuery.Fields[0].AsString);
    ParamsQuery.Close;
    FreeAndNil(ParamsQuery);
  end;
end;

procedure TDCLLogOn.RePlaseVariables(var VariablesSet: String);
begin
  Variables.RePlaseVariables(VariablesSet, nil);
end;

procedure TDCLLogOn.RunCommand(CommandName: String);
var
  Command: TDCLCommand;
begin
  Command:=TDCLCommand.Create(nil, Self);
  Command.ExecCommand(CommandName, nil);
  FreeAndNil(Command);
end;

procedure TDCLLogOn.RunInitSkripts;
begin
  Timer1:=TTimer.Create(nil);
  Timer1.Interval:=IntervalTimeToInitScripts;
  Timer1.Enabled:=True;
  Timer1.OnTimer:=InitActions;
end;

procedure TDCLLogOn.SetDBName(var Query: TDCLDialogQuery);
begin
{$IFDEF ADO}
  Query.Connection:=FDBLogOn;
{$ENDIF}
{$IFDEF IBX}
  Query.Database:=FDBLogOn;
{$ENDIF}
{$IFDEF ZEOS}
  Query.Connection:=FDBLogOn;
{$ENDIF}
{$IFDEF SQLdbFamily}
  Query.Database:=FDBLogOn;
{$ENDIF}
{$IFDEF TRANSACTIONDB}
{$IFDEF SQLdbFamily}
Query.Transaction:=FDBLogOn.Transaction;
{$ENDIF}
{$IFDEF IBX}
Query.Transaction:=FDBLogOn.DefaultTransaction;
{$ENDIF}
{$ENDIF}
end;

function TDCLLogOn.TableExists(TableName: String): Boolean;
var
  Tables:TStrings;
  i:Integer;
begin
  Result:=False;
  Tables:=TStringList.Create;
  GetTableNames(Tables);
  For i:=1 to Tables.Count do
  Begin
    If UpperCase(Tables[i-1])=UpperCase(TableName) then
    Begin
      Result:=True;
      Break;
    End;
  End;
end;

procedure TDCLLogOn.TranslateVal(var S: String);
var
  Factor: Word;
begin
  RePlaseVariables(S);
  Factor:=0;
  TranslateProc(S, Factor, nil);
end;

procedure TDCLMainMenu.UpdateFormBar;
var
  i: Byte;
  TB1: TFormPanelButton;
begin
  If ShowFormPanel Then
    If Assigned(FormBar) Then
    begin
      For i:=1 to FDCLLogOn.FormsCount do
        If Assigned(FDCLLogOn.Forms[i-1]) Then
        begin
          TB1:=(FormBar.FindComponent('TB'+IntToStr(FDCLLogOn.Forms[i-1].FForm.Handle)) as TFormPanelButton);
          If Assigned(TB1) Then
          begin
            If FDCLLogOn.Forms[i-1].FForm=Screen.ActiveForm Then
            begin
              TB1.Glyph:=DrawBMPButton('FormDotActive');
              TB1.Font.Style:=[fsBold];
            end
            Else
            begin
              TB1.Glyph:=DrawBMPButton('FormDotInActive');
              TB1.Font.Style:=[];
            end
          end;
        end;
    end;
end;

procedure TDCLLogOn.WaitNotify(Sender: TObject);
var
  ShadowQuery, ShadowQuery1: TDCLDialogQuery;
  NowTime, TaskTimeStr, NowTimeStr: String;
  NowTimeStruct, TaskTime: TDateTimeItem;
  RunTask: Boolean;

  function GetNotifyAction(NA: Byte): TNotifyActionsType;
  begin
    // naDone, naScriptRun, naMessage, naExecAndWait, naExec, naExitToTime
    Case NA of
    0..Ord(High(TNotifyActionsType)):
    Result:=TNotifyActionsType(NA);
  Else
  Result:=naDone;
    end;
  end;

  procedure MessageToUser(Text: String);
  begin
    If GPT.UserID<>'' Then
      MessageFormObject:=TMessageFormObject.Create(GPT.DCLLongUserName, Text)
    Else
      MessageFormObject:=TMessageFormObject.Create
        ('<'+GetDCLMessageString(msToAll)+'>', Text);
  end;

begin
  // 4 - Выход по дате.
  // 2,3 - Запуск приложения.
  // 1 - Сообщение.
  // 5 - Запуск скрипта.
{$IFNDEF NODCLMESSAGES}
  If Not GPT.UseMessages Then
    Exit;

  ShadowQuery:=TDCLDialogQuery.Create(nil);
  ShadowQuery.Name:='Wait_'+IntToStr(UpTime);
  SetDBName(ShadowQuery);

  ShadowQuery1:=TDCLDialogQuery.Create(nil);
  ShadowQuery1.Name:='Wait1_'+IntToStr(UpTime);
  SetDBName(ShadowQuery1);

  ShadowQuery.Close;
  If GPT.UserID<>'' Then
  begin
    ShadowQuery.SQL.Text:='select first 1 NOTIFY_ACTION, NOTIFY_TIME, NOTIFY_ID, NOTIFY_TEXT from '+
      GPT.NotifycationsTable+' where USER_ID='+GPT.UserID+' and NOTIFY_STATE<>'+IntToStr(Ord(naDone)
      )+' order by NOTIFY_TIME, NOTIFY_ACTION';
  end
  Else
  begin
    ShadowQuery.SQL.Text:='select first 1 NOTIFY_ACTION, NOTIFY_TIME, NOTIFY_ID, NOTIFY_TEXT from '+
      GPT.NotifycationsTable+' where NOTIFY_STATE<>'+IntToStr(Ord(naDone))+
      ' order by NOTIFY_TIME, NOTIFY_ACTION';
  end;

  If TableExists(GPT.NotifycationsTable) Then
  begin
    try
      ShadowQuery.Open;
      GPT.UseMessages:=True;
    Except
      GPT.UseMessages:=False;
      MessagesTimer.Enabled:=False;
    end;
  end
  Else
    GPT.UseMessages:=False;

  If Not GPT.UseMessages Then
    Exit;

  If ExitFlag>1 Then
    inc(ExitFlag);

  If ExitFlag>1 Then
    If TimeToExit<=UpTime Then
      Application.MainForm.Close;

  If ExitFlag>1 Then
    If TimeToExit+TimeToTerminate<=UpTime Then
      Application.Terminate;

  If GPT.UseMessages Then
  begin
    ShadowQuery.First;
    While Not ShadowQuery.Eof do
    begin
      NowTime:=DateToStr(Date)+' '+TimeToStr(SysUtils.Time);
      DecodeDate(StrToDateTime(NowTime), NowTimeStruct.Year, NowTimeStruct.Month,
        NowTimeStruct.Day);
      DecodeDate(StrToDateTime(Trim(ShadowQuery.FieldByName('NOTIFY_TIME').AsString)),
        TaskTime.Year, TaskTime.Month, TaskTime.Day);

      DecodeTime(StrToDateTime(NowTime), NowTimeStruct.Hour, NowTimeStruct.Min, NowTimeStruct.Sec,
        NowTimeStruct.mSec);
      DecodeTime(StrToDateTime(Trim(ShadowQuery.FieldByName('NOTIFY_TIME').AsString)),
        TaskTime.Hour, TaskTime.Min, TaskTime.Sec, TaskTime.mSec);

      NowTimeStr:=IntToStr(NowTimeStruct.Year)+LeadingZero(NowTimeStruct.Month)+
        LeadingZero(NowTimeStruct.Day)+LeadingZero(NowTimeStruct.Hour)+
        LeadingZero(NowTimeStruct.Min)+LeadingZero(NowTimeStruct.Sec);
      TaskTimeStr:=IntToStr(TaskTime.Year)+LeadingZero(TaskTime.Month)+LeadingZero(TaskTime.Day)+
        LeadingZero(TaskTime.Hour)+LeadingZero(TaskTime.Min)+LeadingZero(TaskTime.Sec);

      RunTask:=TaskTimeStr<=NowTimeStr;

      If RunTask Then
      begin
        Case GetNotifyAction(ShadowQuery.FieldByName('NOTIFY_ACTION').AsInteger) of
        naScriptRun:
        begin
          RunCommand(Trim(ShadowQuery.FieldByName('NOTIFY_TEXT').AsString));
        end;
        naExecAndWait:
        begin
          ExecAndWait(Trim(ShadowQuery.FieldByName('NOTIFY_TEXT').AsString), SW_SHOWNORMAL, True);
        end;
        naExec:
        begin
          ExecApp(ShadowQuery.FieldByName('NOTIFY_TEXT').AsString);
        end;
        naMessage:
        begin
          MessageToUser(Trim(ShadowQuery.FieldByName('NOTIFY_TEXT').AsString));
        end;
        naExitToTime:
        begin
          If ExitFlag=0 Then
          begin
            MessageToUser(Format(GetDCLMessageString(msTimeToExit), [ExitTime]));
            ExitFlag:=1;
            TimeToExit:=UpTime+(ExitTime*1000);
          end;
        end
      Else
      MessageToUser(Trim(ShadowQuery.FieldByName('NOTIFY_TEXT').AsString));
        end;
        ShadowQuery1.Close;
        ShadowQuery1.SQL.Text:='update '+GPT.NotifycationsTable+' n set n.NOTIFY_STATE='+
          IntToStr(Ord(naDone))+' where n.NOTIFY_ID='+ShadowQuery.FieldByName('NOTIFY_ID').AsString;
        ShadowQuery1.ExecSQL;
      end;
      If ExitFlag>1 Then
        inc(ExitFlag);

      ShadowQuery.Next;
    end;
  end;

  FreeAndNil(ShadowQuery);
  FreeAndNil(ShadowQuery1);
{$ENDIF}
end;

procedure TDCLLogOn.WriteBaseUID;
var
  ParamsQuery: TReportQuery;
  guid:TGUID;
  sGuid:String;
begin
  if not GPT.NoParamsTable then
  Begin
    ParamsQuery:=TReportQuery.Create(Self.FDBLogOn);
    SetDBName(ParamsQuery);
    ParamsQuery.Name:='UID_'+IntToStr(UpTime);
      ParamsQuery.SQL.Text:='select count(*) from '+GPT.GPTTableName+' where '+GPT.UpperString+
        GPT.GPTNameField+GPT.UpperStringEnd+'='+GPT.UpperString+GPT.StringTypeChar+'BaseUID'+
        GPT.StringTypeChar+GPT.UpperStringEnd;
    ParamsQuery.Open;
    If ParamsQuery.Fields[0].AsInteger=0 Then
    begin
      If CreateGUID(guid)=0 then
      Begin
        sGuid:=GUIDToString(guid);
        sGuid:=sGuid.Replace('-', '').Replace('{', '').Replace('}', '');
        ParamsQuery.Close;
        ParamsQuery.SQL.Text:='insert into '+GPT.GPTTableName+'('+GPT.GPTNameField+', '+
          GPT.GPTValueField+') values('+GPT.StringTypeChar+'BaseUID'+GPT.StringTypeChar+', '+
          GPT.StringTypeChar+sGuid {MD5.MD5DigestToStr(MD5.MD5String(IntToStr(UpTime)))}+GPT.StringTypeChar+')';
        ParamsQuery.ExecSQL;
      End;
    end;
    ParamsQuery.Close;
    FreeAndNil(ParamsQuery);
  End;
end;

procedure TDCLLogOn.WriteBaseUIDtoINI(FileName, SectionName: string);
var
  S:String;
  Ini:TIniFile;
begin
  If SectionName<>'' then
  If Not GPT.NoParamsTable Then
  If FileExists(FileName) then
  begin
    S:=GetBaseUID;
    Ini:=TIniFile.Create(FileName);

    If Ini.SectionExists(SectionName) then
      Ini.WriteString(SectionName, 'BaseUID', S);
    Ini.Free;
  end;
end;

procedure TDCLLogOn.WriteConfig(ConfigName, NewValue, UserID: String);
var
  ParamsQuery: TReportQuery;
  WhereUser: String;
begin
  WhereUser:='';
  If Not GPT.NoParamsTable Then
  begin
    If UserID<>'' Then
      WhereUser:=' and '+GPT.GPTUserIDField+'='+UserID;

    ParamsQuery:=TDCLDialogQuery.Create(nil);
    ParamsQuery.Name:='WriteConfig_'+IntToStr(UpTime);
    SetDBName(ParamsQuery);
    ParamsQuery.SQL.Text:='select count(*) from '+GPT.GPTTableName+' where '+GPT.UpperString+
      GPT.GPTNameField+GPT.UpperStringEnd+'='+GPT.UpperString+GPT.StringTypeChar+ConfigName+
      GPT.StringTypeChar+GPT.UpperStringEnd+WhereUser;
    ParamsQuery.Open;
    If ParamsQuery.Fields[0].AsInteger>0 Then
    begin
      ParamsQuery.Close;
      ParamsQuery.SQL.Text:='update '+GPT.GPTTableName+' set '+GPT.GPTValueField+'='+
        GPT.StringTypeChar+NewValue+GPT.StringTypeChar+' where '+GPT.UpperString+GPT.GPTNameField+
        GPT.UpperStringEnd+'='+GPT.UpperString+GPT.StringTypeChar+ConfigName+GPT.StringTypeChar+
        GPT.UpperStringEnd+WhereUser;
      ParamsQuery.ExecSQL;
    end
    Else
    begin
      ParamsQuery.Close;
      If UserID='' Then
        ParamsQuery.SQL.Text:='insert into '+GPT.GPTTableName+'('+GPT.GPTValueField+', '+
          GPT.GPTNameField+') values('+GPT.StringTypeChar+NewValue+GPT.StringTypeChar+', '+
          GPT.StringTypeChar+ConfigName+GPT.StringTypeChar+')'
      Else
        ParamsQuery.SQL.Text:='insert into '+GPT.GPTTableName+'('+GPT.GPTValueField+', '+
          GPT.GPTNameField+', '+GPT.GPTUserIDField+') values('+GPT.StringTypeChar+NewValue+
          GPT.StringTypeChar+', '+GPT.StringTypeChar+ConfigName+GPT.StringTypeChar+', '+UserID+')';

      ParamsQuery.ExecSQL;
    end;
    FreeAndNil(ParamsQuery);
  end;
end;

{ TDCLMenu }
procedure CreateAboutItem(var MainMenu: TMainMenu; Form: TForm);
var
  ItemMenu: TMenuItem;
begin
  If Not Assigned(MainMenu) Then
    MainMenu:=TMainMenu.Create(Form);

  ItemMenu:=TMenuItem.Create(MainMenu);
  ItemMenu.Name:='ItemMeu_About';
  ItemMenu.Caption:='О...';
  ItemMenu.OnClick:=DCLMainLogOn.About;

  MainMenu.Items.Add(ItemMenu);
end;

procedure TDCLMainMenu.ExecCommand(Command: String);
var
  DCLCommand: TDCLCommand;
begin
  DCLCommand:=TDCLCommand.Create(nil, FDCLLogOn);
  DCLCommand.ExecCommand(Command, nil);
  FreeAndNil(DCLCommand);
end;

procedure TDCLMainMenu.AddMainItem(Caption, ItemName: String);
begin
  ItemMenu:=TMenuItem.Create(FMainMenu);
  ItemMenu.Name:=ItemName;
  ItemMenu.Caption:=Caption;
  ItemMenu.OnClick:=ClickMenu;
  FMainMenu.Items.Add(ItemMenu);
end;

procedure TDCLMainMenu.AddSubItem(Caption, ItemName: String; Level: Integer);
begin
  If Level<> - 1 Then
  begin
    ToItem:=FMainMenu.Items[Level];
    ItemMenu:=TMenuItem.Create(ToItem);
    ItemMenu.Name:=ItemName;
    ItemMenu.Caption:=Caption;
    ItemMenu.OnClick:=ClickMenu;
    ToItem.OnClick:=nil;
    ToItem.Insert(ToItem.Count, ItemMenu);
  end;
end;

procedure TDCLMainMenu.AddSubSubItem(Caption, ItemName: String; Level, Index: Integer);
begin
  If (Level<> - 1)and(Index<> - 1) Then
  begin
    ToItem:=FMainMenu.Items[Level][Index];
    ItemMenu:=TMenuItem.Create(ToItem);
    ItemMenu.Name:=ItemName;
    ItemMenu.Caption:=Caption;
    ItemMenu.OnClick:=ClickMenu;
    ToItem.OnClick:=nil;
    ToItem.Insert(ToItem.Count, ItemMenu);
  end;
end;

procedure TDCLMainMenu.ChoseRunType(Command, DCLText, Name: String; Order: Byte);
var
  DCL: TStringList;
begin
  If FDCLLogOn.RoleOK<>lsLogonOK Then
    Exit;
  DCL:=TStringList.Create;

  If (Trim(Command)<>'')and(Order<>0) Then
    ExecCommand(TrimRight(Command))
  Else
  begin
    DCL.Text:=DCLText;
    If (DCLText<>'') and (Order<>0) Then
    Begin
      If FindParam('script type=', LowerCase(DCL[0]))='command' Then
        ExecCommand(DCLText)
      Else
        If (Trim(Command)<>'') and (Order=1) Then
          ExecCommand(TrimRight(Command))
        Else
          ExecCommand(DCLText);

      If LowerCase(FindParam('script type=', LowerCase(DCL[0])))=LowerCase('ShellCommand') Then
        FDCLLogOn.ExecShellCommand(DCLText)
      Else If LowerCase(FindParam('script type=', LowerCase(DCL[0])))=LowerCase('VBScript') Then
        FDCLLogOn.ExecVBS(DCLText);
    End
    Else
      If Order=0 Then
      Begin
        If FindParam('script type=', LowerCase(DCL[0]))='command' Then
          ExecCommand(DCLText)
        Else
          FDCLLogOn.CreateForm(TrimRight(Name), nil, nil, nil, nil, False, chmNone);
      End
      Else
        ExecCommand(DCLText);
  end;
  FreeAndNil(DCL);
end;

procedure TDCLMainMenu.ClickMenu(Sender: TObject);
var
  tmp1: String;
  MenuQuery1: TDCLDialogQuery;
  RecCount: Integer;
begin
  MenuQuery1:=TDCLDialogQuery.Create(nil);
  MenuQuery1.Name:='ClickMenu_'+IntToStr(UpTime);
  FDCLLogOn.SetDBName(MenuQuery1);

  tmp1:=Copy((Sender as TMenuItem).Name, 10, Length((Sender as TMenuItem).Name));

  MenuQuery1.SQL.Text:='select Count(*) from '+GPT.DCLTable+' where '+GPT.IdentifyField+'='+tmp1;
  MenuQuery1.Open;
  RecCount:=MenuQuery1.Fields[0].AsInteger;

  If RecCount>0 Then
  begin
    MenuQuery1.Close;
    MenuQuery1.SQL.Text:='select * from '+GPT.DCLTable+' where '+GPT.IdentifyField+'='+tmp1;

    MenuQuery1.Open;
    tmp1:=TrimRight(MenuQuery1.FieldByName(GPT.CommandField).AsString);
    If tmp1<>'' Then
    begin
      MenuQuery1.Close;
      MenuQuery1.SQL.Text:='select Count(*) from '+GPT.DCLTable+' where '+GPT.UpperString+
        GPT.DCLNameField+GPT.UpperStringEnd+'='+GPT.UpperString+GPT.StringTypeChar+tmp1+
        GPT.StringTypeChar+GPT.UpperStringEnd;
      MenuQuery1.Open;
      RecCount:=MenuQuery1.Fields[0].AsInteger;
      MenuQuery1.Close;
      If RecCount<>0 Then
      begin
        MenuQuery1.Close;
        MenuQuery1.SQL.Text:='select * from '+GPT.DCLTable+' where '+GPT.UpperString+
          GPT.DCLNameField+GPT.UpperStringEnd+'='+GPT.UpperString+GPT.StringTypeChar+tmp1+
          GPT.StringTypeChar+GPT.UpperStringEnd;

        MenuQuery1.Open;
        ChoseRunType(MenuQuery1.FieldByName(GPT.CommandField).AsString,
          MenuQuery1.FieldByName(GPT.DCLTextField).AsString,
          MenuQuery1.FieldByName(GPT.DCLNameField).AsString, 0);
      end;
    end
    Else
      ChoseRunType(TrimRight(MenuQuery1.FieldByName(GPT.CommandField).AsString),
        TrimRight(MenuQuery1.FieldByName(GPT.DCLTextField).AsString),
        MenuQuery1.FieldByName(GPT.DCLNameField).AsString, 1);
  end;

  MenuQuery1.Close;
  FreeAndNil(MenuQuery1);
end;

destructor TDCLMainMenu.Destroy;
var
  MenuQuery: TDCLDialogQuery;
  RecCount: Integer;
begin
  MenuQuery:=TDCLDialogQuery.Create(nil);
  MenuQuery.Name:='DestroyMenu_'+IntToStr(UpTime);
  FDCLLogOn.SetDBName(MenuQuery);

  MenuQuery.SQL.Text:=FDCLLogOn.GetRolesQueryText(qtCount, ' s.'+GPT.IdentifyField+
      ' between 40101 and 40200');
  MenuQuery.Open;
  RecCount:=MenuQuery.Fields[0].AsInteger;

  If RecCount>0 Then
  begin
    MenuQuery.SQL.Text:=FDCLLogOn.GetRolesQueryText(qtSelect,
      ' s.'+GPT.IdentifyField+' between 40101 and 40200 order by s.'+GPT.IdentifyField);
    MenuQuery.Open;

    While Not MenuQuery.Eof do
    begin
      ChoseRunType(MenuQuery.FieldByName(GPT.CommandField).AsString,
        MenuQuery.FieldByName(GPT.DCLTextField).AsString, MenuQuery.FieldByName(GPT.DCLNameField)
          .AsString, 1);
      MenuQuery.Next;
    end;
  end;
  MenuQuery.Close;
  FreeAndNil(MenuQuery);

  If Assigned(MainFormStatus) Then
    FreeAndNil(MainFormStatus);
  If Assigned(FormBar) Then
    FreeAndNil(FormBar);
  If Assigned(FMainMenu) Then
    FreeAndNil(FMainMenu);
end;

constructor TDCLMainMenu.Create(var DCLLogOn: TDCLLogOn; Form: TForm; Relogin: Boolean=False);
Type
  TCompotableVersionNumbers=Array [1..4] of Word;
var
  ProgrammCompVer, BaseCompVer: TCompotableVersionNumbers;
  RecCount, SubNum, v1: Integer;
  NewMainForm: Boolean;
  SubQuery, MenuQuery, DCLQuery: TDCLDialogQuery;
  tmpSQL, tmpSQL1: String;
begin
  FDCLLogOn:=DCLLogOn;
  MainFormAction:=TMainFormAction.Create;
  FMainForm:=FDCLLogOn.MainForm;
  FForm:=Form;

  NewMainForm:=Not Assigned(Form);
  If NewMainForm Then
  begin
    If FDCLLogOn.RoleOK<>lsLogonOK Then
      Exit;
    FDCLLogOn.FMainForm:=Form;

    Form:=TDBForm.Create(nil);
    Form.Name:='DCLMainForm';

    MainFormStatus:=TStatusBar.Create(Form);
    MainFormStatus.Name:='MainStatusPanel';
    MainFormStatus.Parent:=Form;
    MainFormStatus.SimplePanel:=False;
    Form.Left:=50;
    Form.Top:=50;
  end;

  Form.Tag:=999;

  If FDCLLogOn.RoleOK<>lsLogonOK Then
  begin
    CreateAboutItem(FMainMenu, FMainForm);
    Exit;
  end;

  If ConnectErrorCode=0 Then
  begin
    If ShowFormPanel and Not Assigned(FormBar) Then
    begin
      FormBar:=TToolBar.Create(Form);
      FormBar.Parent:=Form;
      FormBar.Name:='FormBar';
      FormBar.ShowCaptions:=True;
      FormBar.Height:=FormPanelHeight;
      FormBar.ButtonHeight:=FormPanelButtonHeight;
      FormBar.ButtonWidth:=FormPanelButtonWidth;
      FormBar.Show;
    end;

    Form.OnClose:=MainFormAction.CloseMainForm;
    Form.OnCloseQuery:=MainFormAction.FormCloseQuery;

    MenuQuery:=TDCLDialogQuery.Create(nil);
    MenuQuery.Name:='CreateMenu_'+IntToStr(UpTime);
    FDCLLogOn.SetDBName(MenuQuery);

    If Assigned(FMainMenu)and Relogin Then
      FreeAndNil(FMainMenu);

    FMainMenu:=TMainMenu.Create(FForm);
{$IFDEF DELPHI}
    FMainMenu.AutoHotkeys:=maManual;
{$ENDIF}
    If not FDCLLogOn.TableExists(GPT.DCLTable) then
    Begin
      CreateAboutItem(FMainMenu, FForm);
    End
    Else
    Begin
      MenuQuery.SQL.Text:=FDCLLogOn.GetRolesQueryText(qtCount,
        ' s.'+GPT.IdentifyField+' between 20001 and 20050');

      RecCount:=0;
      DebugProc('Selecting components(20001):');
      DebugProc('  Query: '+MenuQuery.SQL.Text);
      try
        DebugProc('  ... selected');
        MenuQuery.Open;
        RecCount:=MenuQuery.Fields[0].AsInteger;
        DebugProc('  ... OK');
      Except
        DebugProc('  ... Fail');
      end;

      If RecCount>0 Then
      begin
        MenuQuery.Close;
        MenuQuery.SQL.Text:=FDCLLogOn.GetRolesQueryText(qtSelect,
          ' s.'+GPT.IdentifyField+' between 20001 and 20050 order by s.'+GPT.IdentifyField);

        MenuQuery.Open;
        If Assigned(MainFormStatus) Then
          FreeAndNil(MainFormStatus);

        If Not Assigned(MainFormStatus) Then
        begin
          MainFormStatus:=TStatusBar.Create(Form);
          MainFormStatus.Name:='MainStatusPanel';
          MainFormStatus.Parent:=Form;
          MainFormStatus.SimplePanel:=False;
        end;
        While Not MenuQuery.Eof do
        begin
          If MenuQuery.FieldByName(GPT.DCLTextField).AsString<>'' Then
            tmpSQL:=MenuQuery.FieldByName(GPT.DCLTextField).AsString
          Else
            tmpSQL:=TrimRight(MenuQuery.FieldByName(GPT.DCLNameField).AsString);
          If PosEx('select', tmpSQL)<>0 Then
            If PosEx('from', tmpSQL)<>0 Then
            begin
              DCLQuery:=TDCLDialogQuery.Create(nil);
              DCLQuery.Name:='Menu20001_'+IntToStr(UpTime);
              FDCLLogOn.SetDBName(DCLQuery);
              FDCLLogOn.RePlaseVariables(tmpSQL);
              DCLQuery.SQL.Text:=tmpSQL;
              DCLQuery.Open;
              tmpSQL:=TrimRight(DCLQuery.Fields[0].AsString);
              DCLQuery.Close;
              FreeAndNil(DCLQuery);
            end;
          If PosEx('ReturnValue=', tmpSQL)<>0 Then
          begin
            tmpSQL1:=FindParam('ReturnValue=', tmpSQL);
            DeleteNonPrintSimb(tmpSQL1);
            FDCLLogOn.RePlaseVariables(tmpSQL1);
            tmpSQL:=tmpSQL1;
          end;

          MainFormStatus.Panels.Insert(MainFormStatus.Panels.Count);
          MainFormStatus.Panels[MainFormStatus.Panels.Count-1].Text:=tmpSQL;
          If MenuQuery.FieldByName(GPT.ParentFlgField).AsInteger<>0 Then
            MainFormStatus.Panels[MainFormStatus.Panels.Count-1].Width:=
              MenuQuery.FieldByName(GPT.ParentFlgField).AsInteger
          Else
            MainFormStatus.Panels[MainFormStatus.Panels.Count-1].Width:=Length(tmpSQL)*CharWidth;
          MenuQuery.Next;
        end;
      end;
      MenuQuery.Close;

      MenuQuery.SQL.Text:=FDCLLogOn.GetRolesQueryText(qtSelect, ' s.'+GPT.IdentifyField+'=0');
      MenuQuery.Open;
      tmpSQL:=TrimRight(MenuQuery.FieldByName(GPT.DCLNameField).AsString);
      FDCLLogOn.RePlaseVariables(tmpSQL);
      tmpSQL:=tmpSQL+GPT.MainFormCaption;
      FForm.Caption:=tmpSQL;

      If NewMainForm Then
        FForm.Show;

      MenuQuery.Close;

      MenuQuery.SQL.Text:=FDCLLogOn.GetRolesQueryText(qtCount,
        ' s.'+GPT.IdentifyField+' between 1 and 1000');

      RecCount:=0;
      DebugProc('Selecting main menu:');
      DebugProc('  Query: '+MenuQuery.SQL.Text);
      try
        DebugProc('  ... selected');
        MenuQuery.Open;
        RecCount:=MenuQuery.Fields[0].AsInteger;
        DebugProc('  ... OK');
      Except
        DebugProc('  ... Fail');
      end;

      If RecCount>0 Then
      begin
        MenuQuery.Close;
        MenuQuery.SQL.Text:=FDCLLogOn.GetRolesQueryText(qtSelect,
          ' s.'+GPT.IdentifyField+' between 1 and 1000 order by s.'+GPT.IdentifyField);

        MenuQuery.Open;
        While Not MenuQuery.Eof do
        begin
          AddMainItem(TrimRight(MenuQuery.FieldByName(GPT.DCLNameField).AsString),
            'MenuItem_'+TrimRight(MenuQuery.FieldByName(GPT.IdentifyField).AsString));
          MenuQuery.Next;
        end;
      end
      Else
        CreateAboutItem(FMainMenu, FForm);

      MenuQuery.Close;

      MenuQuery.SQL.Text:=FDCLLogOn.GetRolesQueryText(qtSelect,
        ' s.'+GPT.IdentifyField+' between 1001 and 10000 order by s.'+GPT.IdentifyField);
      MenuQuery.Open;

      While Not MenuQuery.Eof do
      begin
        AddSubItem(TrimRight(MenuQuery.FieldByName(GPT.DCLNameField).AsString),
          'MenuItem_'+MenuQuery.FieldByName(GPT.IdentifyField).AsString,
          FMainMenu.Items.IndexOf((FMainMenu.FindComponent('MenuItem_'+
                  TrimRight(MenuQuery.FieldByName(GPT.ParentFlgField).AsString)) as TMenuItem)));
        MenuQuery.Next;
      end;
      MenuQuery.Close;

      MenuQuery.SQL.Text:=FDCLLogOn.GetRolesQueryText(qtSelect,
        ' s.'+GPT.IdentifyField+' between 10001 and 16000');
      MenuQuery.Open;

      SubQuery:=TDCLDialogQuery.Create(nil);
      SubQuery.Name:='MenuSub10001_'+IntToStr(UpTime);
      FDCLLogOn.SetDBName(SubQuery);

      If not (MenuQuery.Eof and MenuQuery.Bof) then
      Begin
        MenuQuery.Close;
        MenuQuery.SQL.Text:=FDCLLogOn.GetRolesQueryText(qtSelect,
          ' s.'+GPT.IdentifyField+' between 10001 and 16000 order by s.'+GPT.IdentifyField);
        MenuQuery.Open;

        SubQuery.SQL.Text:=FDCLLogOn.GetRolesQueryText(qtSelect, ' s.'+GPT.IdentifyField+'='+
            MenuQuery.FieldByName(GPT.ParentFlgField).AsString);
        SubQuery.Open;
        SubNum:=SubQuery.FieldByName(GPT.ParentFlgField).AsInteger;
        SubQuery.Close;

        While Not MenuQuery.Eof do
        begin
          v1:=FindMenuItemIndex('MenuItem_'+IntToStr(SubNum));
          If v1<> - 1 Then
            AddSubSubItem(TrimRight(MenuQuery.FieldByName(GPT.DCLNameField).AsString),
              'MenuItem_'+MenuQuery.FieldByName(GPT.IdentifyField).AsString, v1,
              FindSubMenuItemIndex('MenuItem_'+TrimRight(MenuQuery.FieldByName(GPT.ParentFlgField)
                    .AsString), v1));
          MenuQuery.Next;
        end;
        FreeAndNil(SubQuery);
      End;
      MenuQuery.Close;

      MenuQuery.SQL.Text:=FDCLLogOn.GetRolesQueryText(qtCount,
        ' s.'+GPT.IdentifyField+' between 20051 and 20100');

      RecCount:=0;
      DebugProc('Selecting components(20051):');
      DebugProc('  Query: '+MenuQuery.SQL.Text);
      try
        DebugProc('  ... selected');
        MenuQuery.Open;
        RecCount:=MenuQuery.Fields[0].AsInteger;
        DebugProc('  ... OK');
      Except
        DebugProc('  ... Fail');
      end;
      MenuQuery.Close;

      If RecCount>0 Then
      begin
        MenuQuery.SQL.Text:=FDCLLogOn.GetRolesQueryText(qtSelect,
          ' s.'+GPT.IdentifyField+' between 20051 and 20100 order by s.'+GPT.IdentifyField);
        MenuQuery.Open;
        tmpSQL:='';
        tmpSQL1:='';
        While Not MenuQuery.Eof do
        begin
          If MenuQuery.FieldByName(GPT.DCLTextField).AsString<>'' Then
            tmpSQL:=MenuQuery.FieldByName(GPT.DCLTextField).AsString
          Else
            tmpSQL:=TrimRight(MenuQuery.FieldByName(GPT.DCLNameField).AsString);
          If PosEx('select', tmpSQL)<>0 Then
          begin
            If PosEx('from', tmpSQL)<>0 Then
            begin
              DCLQuery:=TDCLDialogQuery.Create(nil);
              DCLQuery.Name:='Menu20051_'+IntToStr(UpTime);
              DCLQuery.SQL.Text:=tmpSQL;
              FDCLLogOn.SetDBName(DCLQuery);
              DCLQuery.Open;
              tmpSQL1:=tmpSQL1+TrimRight(DCLQuery.Fields[0].AsString);
              DCLQuery.Close;
              FreeAndNil(DCLQuery);
            end;
          end
          Else
            tmpSQL1:=tmpSQL1+tmpSQL;
          MenuQuery.Next;
        end;
        Form.Caption:=Form.Caption+tmpSQL1;
      end;
      MenuQuery.Close;

      FDCLLogOn.RunInitSkripts;

      MenuQuery.SQL.Text:='select Count(*) from '+GPT.DCLTable+' where '+GPT.IdentifyField+'=50000';
      RecCount:=0;
      DebugProc('Selecting components(50000):');
      DebugProc('  Query: '+MenuQuery.SQL.Text);
      try
        DebugProc('  ... selected');
        MenuQuery.Open;
        RecCount:=MenuQuery.Fields[0].AsInteger;
        DebugProc('  ... OK');
      Except
        DebugProc('  ... Fail');
      end;
      If RecCount>0 Then
      begin
        For RecCount:=1 to 4 do
          ProgrammCompVer[RecCount]:=StrToInt(SortParams(CompotableVersion, RecCount, '.'));

        MenuQuery.Close;
        MenuQuery.SQL.Text:='select '+GPT.DCLNameField+' from '+GPT.DCLTable+' where '+
          GPT.IdentifyField+'=50000';
        MenuQuery.Open;
        tmpSQL:=Trim(MenuQuery.FieldByName(GPT.DCLNameField).AsString);
        If Length(tmpSQL)>=11 Then
          For RecCount:=1 to 4 do
            BaseCompVer[RecCount]:=StrToInt(SortParams(tmpSQL, RecCount, '.'));

        v1:=0;
        SubNum:=0;
        For RecCount:=1 to 4 do
        Begin
          If (ProgrammCompVer[RecCount]<BaseCompVer[RecCount]) and (v1<SubNum) Then
          Begin
            If RecCount=1 Then
              ShowErrorMessage(1, GetDCLMessageString(msVersionsGap))
            Else
              ShowErrorMessage(1, GetDCLMessageString(msOldVersion));

            break;
          End
          Else
            If (ProgrammCompVer[RecCount]>BaseCompVer[RecCount]) and (v1>SubNum) Then
              break;
            
          Inc(v1, ProgrammCompVer[RecCount]);
          Inc(SubNum, BaseCompVer[RecCount]);
        End;
      end;
      MenuQuery.Close;

      FreeAndNil(MenuQuery);
    end;
  End;
end;

function TDCLMainMenu.FindMenuItemIndex(ItemName: String): Integer;
var
  v1: Integer;
begin
  Result:= - 1;
  For v1:=0 to FMainMenu.Items.Count-1 do
    If CompareString(ItemName, FMainMenu.Items[v1].Name) Then
    begin
      Result:=v1;
      break;
    end;
end;

function TDCLMainMenu.FindSubMenuItemIndex(ItemName: String; Level: Integer): Integer;
var
  v1: Integer;
begin
  Result:= - 1;
  For v1:=0 to FMainMenu.Items[Level].Count-1 do
    If CompareString(ItemName, FMainMenu.Items[Level][v1].Name) Then
    begin
      Result:=v1;
      break;
    end;
end;

procedure TDCLMainMenu.LockMenu;
var
  ItemCounter: Integer;
begin
  If Assigned(FMainForm) Then
    For ItemCounter:=0 to FMainMenu.Items.Count-1 do
      FMainMenu.Items[ItemCounter].Enabled:=False;
end;

procedure TDCLMainMenu.UnLockMenu;
var
  ItemCounter: Integer;
begin
  If Assigned(FMainForm) Then
    For ItemCounter:=0 to FMainMenu.Items.Count-1 do
      FMainMenu.Items[ItemCounter].Enabled:=True;
end;

{ TDCLGrid }

procedure TDCLGrid.AddBrushColor(OPL: String);
var
  l: Word;
  v1, v2: Integer;
  TmpStr, tmpStr2, BrushKey, Colors: String;
begin
  BrushKey:=FindParam('BrushKey=', OPL);
  Colors:=FindParam('Color=', OPL);

  For v1:=1 to ParamsCount(Colors) do
  begin
    l:=Length(BrushColors);
    SetLength(BrushColors, l+1);

    TmpStr:=SortParams(Colors, v1);
    v2:=Pos('=', TmpStr);
    tmpStr2:=Copy(TmpStr, v2+1, Length(TmpStr)-v2+1);
    Case GetStringDataType(tmpStr2) of
    idDigit:
    BrushColors[l].Color:=StrToIntEx(tmpStr2);
    idHex:
    BrushColors[l].Color:=HexToInt(tmpStr2);
    idColor:
    BrushColors[l].Color:=StringToColor(tmpStr2);
    end;
    BrushColors[l].Value:=Copy(TmpStr, 1, v2-1);
    BrushColors[l].Key:=BrushKey;
    If Not FieldExists(BrushColors[l].Key, FQuery) Then
    begin
      DebugProc('//!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
      DebugProc('В предложении Color=, указанно несуществующее поле : '+BrushColors[l].Key);
      DebugProc(OPL);
      DebugProc('//!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
    end;
  end;
end;

procedure TDCLGrid.AddCalendar(Calendar: RCalendar);
var
  l: Integer;
begin
  l:=Length(Calendars);
  SetLength(Calendars, l+1);

  Calendars[l].Num:=l;
  Calendars[l].Field:=Calendar.Field;
  Calendars[l].VarName:=Calendar.VarName;
  Calendars[l].ReOpen:=Calendar.ReOpen;

  AddToolPanel;

  LabelField:=TDialogLabel.Create(ToolPanel);
  LabelField.Parent:=ToolPanel;
  LabelField.Top:=FilterLabelTop;
  LabelField.Left:=BeginStepLeft+ToolPanelElementLeft;
  LabelField.Caption:=InitCap(Calendar.Caption);

  Calendars[l].Control:=DateTimePicker.Create(ToolPanel);
  Calendars[l].Control.Name:='Calendar_'+IntToStr(l);
  Calendars[l].Control.Parent:=ToolPanel;
  Calendars[l].Control.Tag:=l;
  Calendars[l].Control.Width:=CalendarWidth;

  Calendars[l].Control.Top:=FilterTop;
  Calendars[l].Control.Left:=BeginStepLeft+ToolPanelElementLeft;

  Calendars[l].Control.Date:=Calendar.Value;
  If Calendars[l].VarName<>'' Then
    FDCLLogOn.Variables.NewVariable(Calendars[l].VarName, DateToStr(Calendars[l].Control.Date))
  Else
    FDCLLogOn.Variables.NewVariable('Calendar_'+IntToStr(l), DateToStr(Calendars[l].Control.Date));

  Calendars[l].Control.OnChange:=CalendarOnChange;

  ToolPanelElementLeft:=ToolPanelElementLeft+CalendarLeft+Calendars[l].Control.Width;
end;

procedure TDCLGrid.AddSimplyCheckBox(var Field: RField);
var
  l: Integer;
  value1:String;
  state:Boolean;
begin
  Field.CurrentEdit:=True;
  l:=Length(CheckBoxes);
  SetLength(CheckBoxes, l+1);
  Field.CurrentEdit:=True;

  CheckBoxes[l].CheckBox:=TCheckbox.Create(FieldPanel);
  CheckBoxes[l].CheckBox.Parent:=FieldPanel;

  CheckBoxes[l].CheckBox.Name:='CheckBox_'+IntToStr(l);
  CheckBoxes[l].CheckBox.Caption:='';
  CheckBoxes[l].CheckBoxToFields:=Field.FieldName;

  If Field.Hint<>'' Then
  begin
    CheckBoxes[l].CheckBox.ShowHint:=True;
    CheckBoxes[l].CheckBox.Hint:=Field.Hint;
  end;

  state:=False;
  If Field.Variable<>'' Then
  begin
    FDCLLogOn.Variables.NewVariableWithTest(Field.Variable);
  end
  Else
  begin
    FDCLLogOn.Variables.NewVariableWithTest('CheckBox_'+Field.FieldName);
    Field.Variable:='CheckBox_'+Field.FieldName;
  end;

  value1:=FindParam('_Value=', Field.OPL);
  if value1<>'' then
  begin
    TranslateVal(value1);
    state:=value1='1';
  end;

  CheckBoxes[l].NoDataField:=Field.NoDataField;
  CheckBoxes[l].CheckBoxToVars:=Field.Variable;
  CheckBoxes[l].CheckBox.Checked:=state;

  If PosEx('_OnCheck;', Field.OPL)<>0 Then
    CheckBoxes[l].CheckBox.Checked:=True;
  If PosEx('_OffCheck;', Field.OPL)<>0 Then
    CheckBoxes[l].CheckBox.Checked:=False;

  CheckBoxes[l].CheckBox.Tag:=l;
  CheckBoxes[l].CheckBox.OnClick:=CheckOnClick;
  CheckBoxes[l].CheckBox.Left:=Field.Left;
  CheckBoxes[l].CheckBox.Top:=Field.Top;
  CheckBoxes[l].CheckBox.Width:=CheckWidth;
  Field.Height:=CheckBoxes[l].CheckBox.Height;

  Case CheckBoxes[l].CheckBox.Checked of
  True:
  FDCLLogOn.Variables.Variables[Field.Variable]:='1';
  False:
  FDCLLogOn.Variables.Variables[Field.Variable]:='0';
  end;
  IncXYPos(EditTopStep, EditWidth, Field);
end;

procedure TDCLGrid.AddCheckBox(var Field: RField);
begin
  If (not Field.NoDataField) and FQuery.Active and FieldExists(Field.FieldName, Query) Then
    AddDBCheckBox(Field)
  Else
    AddSimplyCheckBox(Field);
end;

procedure TDCLGrid.AddColumn(Field: RField);
var
  Col: TColumn;
begin
  If Assigned(FGrid) Then
  begin
    Col:=FGrid.Columns.Add;
    Col.FieldName:=Field.FieldName;
    Col.Title.Caption:=Field.Caption;
    If Col.Width>ColumnsLongerThis Then
      Col.Width:=DefaultColumnSize;

    If Field.Width<>0 Then
      Col.Width:=Field.Width;

    Col.ReadOnly:=Field.ReadOnly;
  end;
end;

procedure TDCLGrid.AddContextButton(var Field: RField);
var
  l: Word;
  TempStr: String;
begin
  l:=Length(ContextFieldButtons);
  SetLength(ContextFieldButtons, l+1);

  ContextFieldButtons[l].Button:=TDialogSpeedButton.Create(FieldPanel);
  ContextFieldButtons[l].Button.Parent:=FieldPanel;
  ContextFieldButtons[l].Button.Top:=Field.Top;
  ContextFieldButtons[l].Button.Left:=Field.Left+Field.Width+5;
  ContextFieldButtons[l].Button.Width:=GetValueButtonGeom;
  ContextFieldButtons[l].Button.Height:=GetValueButtonGeom;
  ContextFieldButtons[l].Button.Tag:=l;
  ContextFieldButtons[l].Button.Caption:='...';
  ContextFieldButtons[l].Button.Hint:=Field.Hint;
  ContextFieldButtons[l].Button.ShowHint:=True;
  ContextFieldButtons[l].Button.OnClick:=ContextFieldButtonsClick;

  Field.StepLeft:=Field.Left+Field.Width+5+GetValueButtonGeom;

  TempStr:=FindParam('CommandName=', Field.OPL);
  If TempStr<>'' Then
  begin
    ContextFieldButtons[l].Command:=TempStr;
  end;

  IncXYPos(0, Field.Width+5+GetValueButtonGeom, Field);
end;

procedure TDCLGrid.AddContextList(var Field: RField);
var
  l: Word;
  ShadowQuery: TDCLDialogQuery;
  lSQL: String;
begin
  l:=Length(ContextLists);
  SetLength(ContextLists, l+1);
  Field.CurrentEdit:=True;

  ContextLists[l].ContextList:=TComboBox.Create(FieldPanel);
  If FindParam('ComponentName=', Field.OPL)<>'' Then
    ContextLists[l].ContextList.Name:=FindParam('ComponentName=', Field.OPL)
  Else
    ContextLists[l].ContextList.Name:='ContextList'+IntToStr(l);
  ContextLists[l].ContextList.Parent:=FieldPanel;
  ContextLists[l].ContextList.Tag:=l;
  ContextLists[l].ContextList.Text:='';
  ContextLists[l].ContextList.Top:=Field.Top;
  ContextLists[l].ContextList.Left:=Field.Left;
  If Field.IsFieldWidth Then
    ContextLists[l].ContextList.Width:=Field.Width
  Else
    ContextLists[l].ContextList.Width:=EditWidth;
  Field.Height:=ContextLists[l].ContextList.Height;
  ContextLists[l].ContextList.Hint:=Field.Hint;
  ContextLists[l].ContextList.ShowHint:=True;

  ContextLists[l].Table:=FindParam('ContextListTable=', Field.OPL);
  ContextLists[l].Field:=FindParam('ContextListField=', Field.OPL);
  ContextLists[l].KeyField:=FindParam('ContextListKey=', Field.OPL);
  If FindParam('ContextListData=', Field.OPL)<>'' Then
    ContextLists[l].ListField:=FindParam('ContextListData=', Field.OPL)
  Else
    ContextLists[l].ListField:=ContextLists[l].Field;

  ContextLists[l].DataField:=Field.FieldName;
  ContextLists[l].Variable:=FindParam('VariableName=', Field.OPL);
  ContextLists[l].NoData:=Field.NoDataField;

  ShadowQuery:=TDCLDialogQuery.Create(nil);
  ShadowQuery.Name:='ContextList_'+IntToStr(UpTime);
  FDCLLogOn.SetDBName(ShadowQuery);

  lSQL:=FindParam('SQL=', Field.OPL);
  If lSQL<>'' Then
  begin
    ContextLists[l].SQL:=lSQL;
    ShadowQuery.SQL.Text:=lSQL;
  end
  Else
  begin
    ContextLists[l].SQL:='';
    ShadowQuery.SQL.Text:='select '+ContextLists[l].Field+' from '+ContextLists[l].Table+
      ' order by '+ContextLists[l].Field;
  end;
  ShadowQuery.Open;
  ShadowQuery.First;

  lSQL:=ContextLists[l].Field;
  if ContextLists[l].Field='' then
  begin
    lSQL:=ShadowQuery.Fields[0].FieldName;
  end;
  ContextLists[l].ContextList.Items.Clear;
  While Not ShadowQuery.Eof do
  begin
    If Trim(ShadowQuery.FieldByName(lSQL).AsString)<>'' Then
      ContextLists[l].ContextList.Items.Append
        (Trim(ShadowQuery.FieldByName(lSQL).AsString));
    ShadowQuery.Next;
  end;
  ShadowQuery.Close;
  FreeAndNil(ShadowQuery);

  ContextLists[l].ContextList.OnKeyDown:=ContextListKeyDown;
  ContextLists[l].ContextList.OnSelect:=ContextListChange;

  IncXYPos(EditTopStep, ContextLists[l].ContextList.Width, Field);
end;

procedure TDCLGrid.AddDateBox(var Field: RField);
var
  NeedValue, DateBoxCount: Word;
  TempStr, KeyField: String;
  ShadowQuery: TDCLDialogQuery;
begin
  DateBoxCount:=Length(DateBoxes);
  SetLength(DateBoxes, DateBoxCount+1);
  Field.CurrentEdit:=True;
  DateBoxes[DateBoxCount].DateBox:=DateTimePicker.Create(FieldPanel);

  If FindParam('ComponentName=', Field.OPL)='' Then
    DateBoxes[DateBoxCount].DateBox.Name:='DateBox_'+Field.FieldName
  Else
    DateBoxes[DateBoxCount].DateBox.Name:=FindParam('ComponentName=', Field.OPL);

  DateBoxes[DateBoxCount].NoDataField:=Field.NoDataField;

  If Field.Hint<>'' Then
  begin
    DateBoxes[DateBoxCount].DateBox.ShowHint:=True;
    DateBoxes[DateBoxCount].DateBox.Hint:=Field.Hint;
  end;

  DateBoxes[DateBoxCount].DateBox.Date:=Date;
  DateBoxes[DateBoxCount].DateBox.OnChange:=OnChangeDateBox;
  DateBoxes[DateBoxCount].DateBox.Tag:=DateBoxCount;
  DateBoxes[DateBoxCount].DateBoxToFields:=Field.FieldName;
  If Field.ReadOnly Then
    DateBoxes[DateBoxCount].DateBoxType:=1
  Else
    DateBoxes[DateBoxCount].DateBoxType:=0;
  DateBoxes[DateBoxCount].DateBox.Parent:=FieldPanel;

  If Field.IsFieldWidth Then
    DateBoxes[DateBoxCount].DateBox.Width:=Field.Width
  Else
    DateBoxes[DateBoxCount].DateBox.Width:=DateBoxWidth;
  Field.Height:=DateBoxes[DateBoxCount].DateBox.Height;

  DateBoxes[DateBoxCount].DateBox.Top:=Field.Top;
  DateBoxes[DateBoxCount].DateBox.Left:=Field.Left;
  If FindParam('Disabled=', Field.OPL)='1' Then
    DateBoxes[DateBoxCount].DateBox.Enabled:=False;
  NeedValue:=0;
  If FindParam('_Value=', Field.OPL)<>'' Then
    NeedValue:=1;
  If FindParam('SQL=', Field.OPL)<>'' Then
    NeedValue:=2;

  if not Field.NoDataField then
  begin
    If FQuery.Active Then
    Begin
      If FindParam('_ValueIfNull=', Field.OPL)<>'' Then
      Begin
        If FieldExists(Field.FieldName, FQuery) Then
          if FQuery.FieldByName(Field.FieldName).IsNull then
            NeedValue:=4;
      End;
    End;
  end;

  TempStr:='';
  Case NeedValue of
  0:
  If Query.Active Then
  begin
    If FieldExists(Field.FieldName, Query) Then
      TempStr:=TrimRight(Query.FieldByName(Field.FieldName).AsString);
  end
  Else
    TempStr:=DateToStr(Date);
  1:
  begin
    TempStr:=FindParam('_Value=', Field.OPL);
    RePlaseParams(TempStr);
    FDCLLogOn.RePlaseVariables(TempStr);
  end;
  2:
  begin
    ShadowQuery:=TDCLDialogQuery.Create(nil);
    ShadowQuery.Name:='DateBoxQ_'+IntToStr(UpTime);
    FDCLLogOn.SetDBName(ShadowQuery);
    TempStr:=FindParam('SQL=', Field.OPL);
    FDCLLogOn.RePlaseVariables(TempStr);
    RePlaseParams(TempStr);
    ShadowQuery.SQL.Text:=TempStr;
    ShadowQuery.Open;
    If FindParam('ReturnField=', Field.OPL)<>'' Then
      KeyField:=FindParam('ReturnField=', Field.OPL)
    Else
      KeyField:=ShadowQuery.Fields[0].FieldName;
    DeleteNonPrintSimb(KeyField);
    If FieldExists(KeyField, ShadowQuery) Then
      TempStr:=TrimRight(ShadowQuery.FieldByName(KeyField).AsString)
    Else
      TempStr:=DateToStr(Date);
    ShadowQuery.Close;
    FreeAndNil(ShadowQuery);
  end;
  4:begin
    TempStr:=FindParam('_ValueIfNull', Field.OPL);
  end;
  end;

  If FindParam('VariableName=', Field.OPL)<>'' Then
  begin
    FDCLLogOn.Variables.NewVariable(FindParam('VariableName=', Field.OPL), TempStr);
    KeyField:=FindParam('VariableName=', Field.OPL);
  end
  Else
  begin
    FDCLLogOn.Variables.NewVariable('DateBox_'+Field.FieldName, TempStr);
    KeyField:='DateBox_'+Field.FieldName;
  end;

  DateBoxes[DateBoxCount].DateBoxToVariables:=KeyField;
  If TempStr<>'' Then
    DateBoxes[DateBoxCount].DateBox.Date:=StrToDate(TempStr);

  If FindParam('NoDataField=', Field.OPL)='1' Then
  Begin
    DateBoxes[DateBoxCount].NoDataField:=True;
  End;
  OnChangeDateBox(DateBoxes[DateBoxCount].DateBox);

  Field.StepLeft:=DateBoxAddWidth;
  IncXYPos(EditTopStep, DateBoxes[DateBoxCount].DateBox.Width, Field);
end;

procedure TDCLGrid.AddDBCheckBox(var Field: RField);
var
  l: Word;
begin
  Field.CurrentEdit:=True;
  l:=Length(DBCheckBoxes);
  SetLength(DBCheckBoxes, l+1);
  DBCheckBoxes[l]:=TDBCheckBox.Create(FieldPanel);
  DBCheckBoxes[l].Parent:=FieldPanel;
  DBCheckBoxes[l].Left:=Field.Left;
  DBCheckBoxes[l].Top:=Field.Top;
  DBCheckBoxes[l].Width:=CheckWidth;
  Field.Height:=DBCheckBoxes[l].Height;
  DBCheckBoxes[l].ShowHint:=True;
  DBCheckBoxes[l].Hint:=Field.Hint;
  DBCheckBoxes[l].Caption:='';
  DBCheckBoxes[l].ReadOnly:=Field.ReadOnly;

  DBCheckBoxes[l].DataSource:=FData;
  DBCheckBoxes[l].DataField:=Field.FieldName;

  If Field.CheckValue<>'' Then
    DBCheckBoxes[l].ValueChecked:=Field.CheckValue;
  If Field.UnCheckValue<>'' Then
    DBCheckBoxes[l].ValueUnchecked:=Field.UnCheckValue;

  If PosEx('_OnCheck;', Field.OPL)<>0 Then
    DBCheckBoxes[l].Checked:=True;
  If PosEx('_OffCheck;', Field.OPL)<>0 Then
    DBCheckBoxes[l].Checked:=False;

  IncXYPos(EditTopStep, DBCheckBoxes[l].Width, Field);
end;

procedure TDCLGrid.AddDBFilter(Filter: TDBFilter);
var
  l, i: Integer;
  Key: Word;
  S: String;
  Item: TComboFilterItem;
begin
  l:=Length(DBFilters);
  SetLength(DBFilters, l+1);

  DBFilters[l]:=Filter;

  AddToolPanel;

  LabelField:=TDialogLabel.Create(ToolPanel);
  LabelField.Parent:=ToolPanel;
  LabelField.Top:=FilterLabelTop;
  LabelField.Left:=BeginStepLeft+ToolPanelElementLeft;
  LabelField.Caption:=InitCap(Filter.Caption);

  If Filter.FilterType=ftDBFilter Then
  begin
    DBFilters[l].CaseC:=False;
    DBFilters[l].NotLike:=True;
    DBFilters[l].FilterString:='';

    DBFilters[l].FilterQuery:=TDCLDialogQuery.Create(nil);
    DBFilters[l].FilterQuery.Name:='DBFilterQ_'+IntToStr(UpTime);
    FDCLLogOn.SetDBName(DBFilters[l].FilterQuery);
    DBFilters[l].FilterData:=TDataSource.Create(nil);
    DBFilters[l].FilterData.DataSet:=DBFilters[l].FilterQuery;
    DBFilters[l].FilterQuery.Tag:=l;
    DBFilters[l].FilterQuery.SQL.Text:=Filter.SQL;

    try
      DBFilters[l].FilterQuery.Open;
      DBFilters[l].FilterQuery.Last;
      DBFilters[l].FilterQuery.First;
    Except
      ShowErrorMessage( - 1116, 'SQL='+DBFilters[l].SQL);
    end;

    DBFilters[l].Lookup:=TDBLookupComboBox.Create(ToolPanel);
    DBFilters[l].Lookup.Parent:=ToolPanel;
    DBFilters[l].Lookup.Top:=FilterTop;
    DBFilters[l].Lookup.Tag:=l;

    DBFilters[l].Lookup.Left:=BeginStepLeft+ToolPanelElementLeft;
    DBFilters[l].Lookup.Name:='DBFilter'+IntToStr(l);
    DBFilters[l].Lookup.ListField:=Filter.ListField;
    DBFilters[l].Lookup.KeyField:=Filter.KeyField;

    If DBFilters[l].VarName<>'' Then
      FDCLLogOn.Variables.Variables[DBFilters[l].VarName]:=
        TrimRight(DBFilters[l].FilterQuery.FieldByName(DBFilters[l].Lookup.KeyField).AsString);

    DBFilters[l].Lookup.ListSource:=DBFilters[l].FilterData;
    DBFilters[l].FilterKey:=DBFilters[l].Lookup.KeyField;

    DBFilters[l].Lookup.Width:=Filter.Width;
    DBFilters[l].Lookup.ListField:=Filter.ListField+';'+Filter.KeyField;

    if Filter.Field<>'' then
    begin
      DBFilters[l].NotCheck:=TCheckBox.Create(ToolPanel);
      DBFilters[l].NotCheck.Parent:=ToolPanel;
      DBFilters[l].NotCheck.Tag:=l;
      DBFilters[l].NotCheck.Top:=FilterTop+EditHeight+LabelTopInterval;
      DBFilters[l].NotCheck.Left:=BeginStepLeft+ToolPanelElementLeft;
      DBFilters[l].NotCheck.Name:='NotCheck_'+IntToStr(l);
      DBFilters[l].NotCheck.Width:=Filter.Width;
      DBFilters[l].NotCheck.Caption:=GetDCLMessageString(msNotFilter);
      DBFilters[l].NotCheck.OnClick:=OnNotCheckClick;
    end;

{$IFDEF FPC}
    DBFilters[l].Lookup.OnSelect:=ExecFilter;
{$ELSE}
    DBFilters[l].Lookup.OnClick:=ExecFilter;
{$ENDIF}
  end;

  If Filter.FilterType=ftComboFilter Then
  begin
    DBFilters[l].CaseC:=False;
    DBFilters[l].NotLike:=True;
    DBFilters[l].FilterString:='';

    if Filter.ListField<>'' then
    begin
      DBFilters[l].Combo:=TComboBox.Create(ToolPanel);
      DBFilters[l].Combo.Style:=TComboBoxStyle.csDropDownList;
      DBFilters[l].Combo.Parent:=ToolPanel;
      DBFilters[l].Combo.Top:=FilterTop;
      DBFilters[l].Combo.Tag:=l;

      for I:=1 to ParamsCount(Filter.ListField) do
      begin
        S:=SortParams(Filter.ListField, i);

        Item:=TComboFilterItem.Create;
        Item.Value:=Copy(S, Pos('/', S)+1, Length(S));
        Item.Key:=Copy(S, 1, Pos('/', S)-1);

        DBFilters[l].Combo.AddItem(Copy(S, Pos('/', S)+1, Length(S)), Item);
      end;
      DBFilters[l].Combo.ItemIndex:=0;

      DBFilters[l].Combo.Left:=BeginStepLeft+ToolPanelElementLeft;
      DBFilters[l].Combo.Name:='DBComboFilter'+IntToStr(l);

      If DBFilters[l].VarName<>'' Then
        FDCLLogOn.Variables.Variables[DBFilters[l].VarName]:=
          TrimRight(DBFilters[l].FilterQuery.FieldByName(DBFilters[l].Lookup.KeyField).AsString);

      DBFilters[l].Combo.Width:=Filter.Width;

      if Filter.Field<>'' then
      begin
        DBFilters[l].NotCheck:=TCheckBox.Create(ToolPanel);
        DBFilters[l].NotCheck.Parent:=ToolPanel;
        DBFilters[l].NotCheck.Tag:=l;
        DBFilters[l].NotCheck.Top:=FilterTop+EditHeight+LabelTopInterval;
        DBFilters[l].NotCheck.Left:=BeginStepLeft+ToolPanelElementLeft;
        DBFilters[l].NotCheck.Name:='NotCheck_'+IntToStr(l);
        DBFilters[l].NotCheck.Width:=Filter.Width;
        DBFilters[l].NotCheck.Caption:=GetDCLMessageString(msNotFilter);
        DBFilters[l].NotCheck.OnClick:=OnNotCheckClick;
      end;

  {$IFDEF FPC}
      DBFilters[l].Combo.OnSelect:=ExecComboFilter;
  {$ELSE}
      DBFilters[l].Combo.OnClick:=ExecComboFilter;
  {$ENDIF}
    end;
  end;

  If Filter.FilterType=ftContextFilter Then
  begin
    DBFilters[l].Edit:=TEdit.Create(ToolPanel);
    DBFilters[l].Edit.Parent:=ToolPanel;

    If Filter.FilterName<>'' Then
      DBFilters[l].Edit.Name:=Filter.FilterName
    Else
      DBFilters[l].Edit.Name:='ContextFilter_'+IntToStr(l);

    DBFilters[l].Edit.Text:='';
    DBFilters[l].Edit.Top:=FilterTop;
    DBFilters[l].Edit.Left:=BeginStepLeft+ToolPanelElementLeft;
    DBFilters[l].Edit.Tag:=l;
    DBFilters[l].Edit.Width:=Filter.Width;
    DBFilters[l].Edit.OnKeyUp:=OnContextFilter;

    DBFilters[l].NotCheck:=TCheckBox.Create(ToolPanel);
    DBFilters[l].NotCheck.Parent:=ToolPanel;
    DBFilters[l].NotCheck.Tag:=l;
    DBFilters[l].NotCheck.Top:=FilterTop+EditHeight+LabelTopInterval;
    DBFilters[l].NotCheck.Left:=BeginStepLeft+ToolPanelElementLeft;
    DBFilters[l].NotCheck.Name:='NotCheck_'+IntToStr(l);
    DBFilters[l].NotCheck.Width:=Filter.Width;
    DBFilters[l].NotCheck.Caption:=GetDCLMessageString(msNotFilter);

    DBFilters[l].NotCheck.OnClick:=OnNotCheckClick;
  end;

  Case Filter.FilterType of
  ftDBFilter:
  ToolPanelElementLeft:=ToolPanelElementLeft+ToolLeftInterval+DBFilters[l].Lookup.Width;
  ftContextFilter:
  ToolPanelElementLeft:=ToolPanelElementLeft+ToolLeftInterval+DBFilters[l].Edit.Width;
  ftComboFilter:
  ToolPanelElementLeft:=ToolPanelElementLeft+ToolLeftInterval+DBFilters[l].Combo.Width;
  end;

  Case Filter.FilterType of
  ftDBFilter:
  begin
    If Filter.KeyValue<>'' Then
    begin
      try
        DBFilters[l].Lookup.KeyValue:=Filter.KeyValue;
        ExecFilter(DBFilters[l].Lookup);
      Except
        //
      end;
    end
    Else
    begin
      try
        DBFilters[l].Lookup.KeyValue:='-1';
      Except
        //
      end;
    end;
  end;
  ftComboFilter:
  begin
    If Filter.KeyValue<>'' Then
    begin
      for I:=1 to DBFilters[l].Combo.Items.Count do
      begin
        if (DBFilters[l].Combo.Items.Objects[i-1] as TComboFilterItem).Key=Filter.KeyValue then
        begin
          DBFilters[l].Combo.ItemIndex:=i-1;
          break;
        end;
      end;
      ExecComboFilter(DBFilters[l].Combo);
    end;
  end;
  ftContextFilter:
  begin
    If Filter.KeyValue<>'' Then
    begin
      FDCLLogOn.RePlaseVariables(Filter.KeyValue);
      DBFilters[l].Edit.Text:=Filter.KeyValue;
      Key:=13;
      OnContextFilter(DBFilters[l].Edit, Key, []);
    end;
  end;
  end;
end;

procedure TDCLGrid.AddDropBox(var Field: RField);
var
  l: Word;
  ShadowQuery: TDCLDialogQuery;
  TmpStr, tmpStr1, tmpSQL1: String;
  DropList: TComboBox;
  v1, v2: Integer;
begin
  If FQuery.Active and (FDisplayMode in TDataGrid) Then
  begin
    TmpStr:=FindParam('List=', Field.OPL);
    TranslateVal(TmpStr);
    If TmpStr<>'' Then
    begin
      Show;
      v2:=ParamsCount(TmpStr);
      For v1:=1 to v2 do
      begin
        tmpStr1:=SortParams(TmpStr, v1);
        If tmpStr1='' Then
          tmpStr1:='';
        FGrid.Columns[FGrid.Columns.Count-1].PickList.Append(tmpStr1);
      end;
    end;

    tmpSQL1:=FindParam('SQL=', Field.OPL);
    If tmpSQL1<>'' Then
    begin
      ShadowQuery:=TDCLDialogQuery.Create(nil);
      ShadowQuery.Name:='GroupBoxQ_'+IntToStr(UpTime);
      FDCLLogOn.SetDBName(ShadowQuery);

      TranslateVal(tmpSQL1);
      ShadowQuery.SQL.Text:=tmpSQL1;
      try
        ShadowQuery.Open;

        While Not ShadowQuery.Eof do
        begin
          If Trim(ShadowQuery.Fields[0].AsString)<>'' Then
            FGrid.Columns[FGrid.Columns.Count-1].PickList.Append
              (Trim(ShadowQuery.Fields[0].AsString))
          Else
            FGrid.Columns[FGrid.Columns.Count-1].PickList.Append(' ');
          ShadowQuery.Next;
        end;
        ShadowQuery.Close;
        FreeAndNil(ShadowQuery);
      Except
        ShowErrorMessage( - 1107, 'SQL='+tmpSQL1);
      end;
    end;
  end;

  If FDisplayMode in TDataFields Then
  begin
    l:=Length(DropBoxes);
    SetLength(DropBoxes, l+1);
    Field.CurrentEdit:=True;

    DropBoxes[l].DropList:=TComboBox.Create(FieldPanel);
    DropBoxes[l].DropList.Parent:=FieldPanel;
    DropBoxes[l].DropList.Name:='DropListBox_'+Field.FieldName;
    DropBoxes[l].DropList.Tag:=l;

    DropBoxes[l].FieldName:=Field.FieldName;
    DropBoxes[l].DropList.Top:=Field.Top;
    DropBoxes[l].DropList.Left:=Field.Left;
    Field.Height:=DropBoxes[l].DropList.Height;

    DropBoxes[l].DropList.OnSelect:=DropListOnSelectItem;

    DropBoxes[l].DropList.Clear;
    DropList:=DropBoxes[l].DropList;

    If FindParam('VariableName=', Field.OPL)<>'' Then
    begin
      tmpStr1:=FindParam('VariableName=', Field.OPL);
      DropBoxes[l].Variable:=tmpStr1;
      FDCLLogOn.Variables.NewVariableWithTest(tmpStr1);
    end;

    tmpSQL1:=FindParam('SQL=', Field.OPL);
    If tmpSQL1<>'' Then
    begin
      ShadowQuery:=TDCLDialogQuery.Create(nil);
      ShadowQuery.Name:='DropBoxQ_'+IntToStr(UpTime);
      FDCLLogOn.SetDBName(ShadowQuery);

      TranslateVal(tmpSQL1);
      ShadowQuery.SQL.Text:=tmpSQL1;
      try
        ShadowQuery.Open;

        While Not ShadowQuery.Eof do
        begin
          TmpStr:=Trim(ShadowQuery.Fields[0].AsString);
          If TmpStr='' Then
            TmpStr:='';
          DropList.Items.Append(TmpStr);

          ShadowQuery.Next;
        end;
        ShadowQuery.Close;
        FreeAndNil(ShadowQuery);
      Except
        ShowErrorMessage( - 1107, 'SQL='+tmpSQL1);
      end;
    end;

    If Field.IsFieldWidth Then
      DropList.Width:=Field.Width
    Else
      DropList.Width:=EditWidth;

    TmpStr:=FindParam('List=', Field.OPL);
    TranslateVal(TmpStr);
    v2:=ParamsCount(TmpStr);
    For v1:=1 to v2 do
    begin
      tmpStr1:=SortParams(TmpStr, v1);
      If tmpStr1='' Then
        tmpStr1:=' ';
      DropList.Items.Append(tmpStr1);
    end;

    If FQuery.Active Then
    begin
      If FindParam('SetIndexValue=', Field.OPL)='1' Then
      begin
        DropList.ItemIndex:=FQuery.FieldByName(Field.FieldName).AsInteger;
      end;
    end
    Else
      DropList.ItemIndex:=StrToIntEx(FindParam('SetIndexValue=', Field.OPL));

    IncXYPos(EditTopStep, DropList.Width, Field);
  end;
end;

procedure TDCLGrid.AddEdit(var Field: RField);
begin
  EditField:=TDBEdit.Create(FieldPanel);
  EditField.Parent:=FieldPanel;
  EditField.OnClick:=DBEditClick;
  EditField.DataSource:=FData;
  EditField.DataField:=Field.FieldName;
  EditField.CharCase:=Field.CharCase;
  EditField.PasswordChar:=Field.PasswordChar;
  If Field.PasswordChar<>#0 Then
    EditField.Tag:=1;

  If Field.Hint<>'' Then
  begin
    EditField.Hint:=Field.Hint;
    EditField.ShowHint:=True;
  end;
  EditField.Top:=Field.Top;
  EditField.Left:=Field.Left;
  If Field.ReadOnly Then
    EditField.ReadOnly:=True;
  If Field.Width=0 Then
    Field.Width:=EditWidth;
  EditField.Width:=Field.Width;
  Field.CurrentEdit:=False;
  Field.Height:=EditField.Height;

  IncXYPos(EditTopStep, Field.Width, Field);
end;

procedure TDCLGrid.AddField(Field: RField);
var
  i: Integer;
begin
  i:=Length(DataFields);
  SetLength(DataFields, i+1);
  DataFields[i].Name:=Field.FieldName;
  DataFields[i].Caption:=Field.Caption;
  DataFields[i].Width:=Field.Width;
end;

procedure TDCLGrid.AddFieldBox(var Field: RField; FieldBoxType: TFieldBoxType; NamePrefix: String);
var
  TempStr, KeyField: String;
  NeedValue: Byte;
  ShadowQuery: TDCLDialogQuery;
  EditsCount: Word;
begin
  EditsCount:=Length(Edits);
  SetLength(Edits, EditsCount+1);
  Field.CurrentEdit:=True;
  Edits[EditsCount].Edit:=TEdit.Create(FieldPanel);

  If FindParam('ComponentName=', Field.OPL)='' Then
    Edits[EditsCount].Edit.Name:=NamePrefix+Field.FieldName
  Else
    Edits[EditsCount].Edit.Name:=FindParam('ComponentName=', Field.OPL);

  If Field.Hint<>'' Then
  begin
    Edits[EditsCount].Edit.ShowHint:=True;
    Edits[EditsCount].Edit.Hint:=Field.Hint;
  end;

  Edits[EditsCount].Edit.PasswordChar:=Field.PasswordChar;
  Edits[EditsCount].EditsPasswordChar:=Field.PasswordChar;

  Edits[EditsCount].Edit.CharCase:=Field.CharCase;

  Edits[EditsCount].Edit.Tag:=EditsCount;
  Edits[EditsCount].Edit.ReadOnly:=Field.ReadOnly;
  Edits[EditsCount].EditsToFields:=Field.FieldName;
  Edits[EditsCount].Edit.Parent:=FieldPanel;
  Edits[EditsCount].Edit.OnClick:=EditClick;

  If Field.IsFieldWidth Then
    Edits[EditsCount].Edit.Width:=Field.Width
  Else
    Edits[EditsCount].Edit.Width:=EditWidth;

  If FieldBoxType<>fbtOutBox Then
  begin
    RePlaseParams(TempStr);
    FDCLForm.RePlaseVariables(TempStr);
    TempStr:=FindParam('Format=', Field.OPL);
    if TempStr<>'' then
    begin
      Edits[EditsCount].Edit.OnKeyPress:=EditOnFloatData;
      If LowerCase(TempStr)='float' Then
      begin
        Field.FieldTypeFormat:=fftFloat;
      end;
      if LowerCase(TempStr)='digit' then
      begin
        Field.FieldTypeFormat:=fftDigit;
      end;
      if LowerCase(TempStr)='trim' then
      begin
        Field.FieldTypeFormat:=fftTrim;
      end;
    end;
  end
  Else
    Edits[EditsCount].Edit.ReadOnly:=True;

  Edits[EditsCount].Edit.Top:=Field.Top;
  Edits[EditsCount].Edit.Left:=Field.Left;
  Edits[EditsCount].ModifyEdit:=0;
  Edits[EditsCount].EditsType:=FieldBoxType;
  If FindParam('Disabled=', Field.OPL)='1' Then
    Edits[EditsCount].Edit.Enabled:=False;
  Edits[EditsCount].Edit.Text:='';
  Edits[EditsCount].Edit.OnChange:=EditOnEdit;

  TempStr:=FindParam('MaxLength=', Field.OPL);
  If TempStr<>'' Then
    Edits[EditsCount].Edit.MaxLength:=StrToIntEx(Trim(TempStr));

  NeedValue:=0;
  If PosEx('_Value=', Field.OPL)<>0 Then
  Begin
    If FindParam('_Value=', Field.OPL)<>'' Then
      NeedValue:=1
    Else
    Begin
      NeedValue:=3;
    End;
  End;

  If FindParam('_ValueIfEmpty=', Field.OPL)<>'' Then
  Begin
    TempStr:=FindParam('_Value=', Field.OPL);
    RePlaseParams(TempStr);
    FDCLForm.RePlaseVariables(TempStr);

    if TempStr<>'' then
    begin
      NeedValue:=6;
    end;
  End;

  if not Field.NoDataField then
  begin
    If FQuery.Active Then
    Begin
      If FindParam('_ValueIfNull=', Field.OPL)<>'' Then
      Begin
        If FieldExists(Field.FieldName, FQuery) Then
          if FQuery.FieldByName(Field.FieldName).IsNull then
            NeedValue:=4;
      End;
      If FindParam('_ValueIfNotNull=', Field.OPL)<>'' Then
      Begin
        If FieldExists(Field.FieldName, FQuery) Then
          if not FQuery.FieldByName(Field.FieldName).IsNull then
            NeedValue:=5;
      End;
    End;
  end;

  If FindParam('SQL=', Field.OPL)<>'' Then
    NeedValue:=2;

  TempStr:='';
  Case NeedValue of
  0:
  if not Field.NoDataField then
  If FQuery.Active Then
    If FieldExists(Field.FieldName, FQuery) Then
      TempStr:=TrimRight(FQuery.FieldByName(Field.FieldName).AsString);
  1:
  begin
    TempStr:=FindParam('_Value=', Field.OPL);
    RePlaseParams(TempStr);
    FDCLForm.RePlaseVariables(TempStr);
  end;
  6:
  begin
    TempStr:=FindParam('_ValueIfEmpty=', Field.OPL);
    RePlaseParams(TempStr);
    FDCLForm.RePlaseVariables(TempStr);
  end;
  2:
  begin
    ShadowQuery:=TDCLDialogQuery.Create(nil);
    ShadowQuery.Name:='FieldBoxQ_'+IntToStr(UpTime);
    FDCLLogOn.SetDBName(ShadowQuery);
    TempStr:=FindParam('SQL=', Field.OPL);
    RePlaseParams(TempStr);
    FDCLForm.RePlaseVariables(TempStr);
    ShadowQuery.SQL.Text:=TempStr;
    ShadowQuery.Open;
    If FindParam('ReturnField=', Field.OPL)<>'' Then
      KeyField:=FindParam('ReturnField=', Field.OPL)
    Else
      KeyField:=ShadowQuery.Fields[0].FieldName;
    DeleteNonPrintSimb(KeyField);
    If FieldExists(KeyField, ShadowQuery) Then
      TempStr:=TrimRight(ShadowQuery.FieldByName(KeyField).AsString)
    Else
      TempStr:='';
    ShadowQuery.Close;
    FreeAndNil(ShadowQuery);
  end;
  3:
  TempStr:='';
  4:begin
    TempStr:=FindParam('_ValueIfNull=', Field.OPL);
    RePlaseParams(TempStr);
    FDCLForm.RePlaseVariables(TempStr);
  end;
  5:begin
    TempStr:=FindParam('_ValueIfNotNull=', Field.OPL);
    RePlaseParams(TempStr);
    FDCLForm.RePlaseVariables(TempStr);
  end;
  end;

  If FindParam('VariableName=', Field.OPL)<>'' Then
    KeyField:=FindParam('VariableName=', Field.OPL)
  Else
    KeyField:=NamePrefix+Field.FieldName;

  FDCLForm.LocalVariables.NewVariableWithTest(KeyField);

  Edits[EditsCount].EditToVariables:=KeyField;
  FDCLForm.LocalVariables.Variables[KeyField]:=TempStr;
  Edits[EditsCount].Edit.Text:=TempStr;
  Field.Height:=Edits[EditsCount].Edit.Height;

  Edits[EditsCount].DCLField:=Field;

  IncXYPos(EditTopStep, Edits[EditsCount].Edit.Width, Field);
end;

procedure TDCLGrid.AddLabel(Field: RField; Caption: String);
begin
  LabelField:=TDialogLabel.Create(FieldPanel);
  LabelField.Parent:=FieldPanel;
  LabelField.Caption:=Caption;
  LabelField.Top:=Field.Top-LabelHeight;
  LabelField.Left:=Field.Left;
end;

procedure TDCLGrid.AddLookUp(var Field: RField);
var
  l: Word;
  NoDataField: Boolean;
  TempStr: String;
  ShadowQuery: TDCLDialogQuery;
begin
  l:=Length(Lookups);
  SetLength(Lookups, l+1);
  Field.CurrentEdit:=True;

  TempStr:=FindParam('SQL=', Field.OPL);
  If TempStr='' Then
    TempStr:=FindParam('QueryLookup=', Field.OPL);
  If TempStr<>'' Then
  begin
    Lookups[l].LookupQuery:=TDCLDialogQuery.Create(nil);
    Lookups[l].LookupQuery.Name:='LookupQ_'+IntToStr(UpTime);
    Lookups[l].LookupQuery.Tag:=l;
    FDCLLogOn.SetDBName(Lookups[l].LookupQuery);
    TranslateVal(TempStr);
    Lookups[l].LookupQuery.SQL.Text:=TempStr;
    try
      Lookups[l].LookupQuery.Open;
      Lookups[l].LookupQuery.Last;
      Lookups[l].LookupQuery.First;
    Except
      ShowErrorMessage( - 1115, 'SQL='+TempStr);
    end;
    Lookups[l].LookupData:=TDataSource.Create(nil);
    Lookups[l].LookupData.Tag:=l;
    Lookups[l].LookupData.DataSet:=Lookups[l].LookupQuery;
  end
  Else
    ShowErrorMessage( - 3000, '');

  Lookups[l].Lookup:=TDBLookupComboBox.Create(FieldPanel);
  Lookups[l].Lookup.Parent:=FieldPanel;
  Lookups[l].Lookup.Name:='LookUpField_'+IntToStr(l);
  Lookups[l].Lookup.Tag:=l;
  {$IFnDEF FPC}
  Lookups[l].Lookup.DropDownRows:=12;
  {$ENDIF}

  Lookups[l].NoDataField:=Field.NoDataField;

  Lookups[l].Lookup.ShowHint:=True;
  Lookups[l].Lookup.Hint:=Field.Hint;

  If FQuery.Active Then
  begin
    If not Field.NoDataField Then
    begin
      If FieldExists(Field.FieldName, FQuery) Then
      begin
        If Not FForm.Showing Then
          FForm.Show;
        NoDataField:=False;
        Lookups[l].Lookup.DataSource:=FData;
        Lookups[l].Lookup.DataField:=Field.FieldName;
      end
      Else
        NoDataField:=True;
    end
    Else
      NoDataField:=True;
  end
  Else
    NoDataField:=True;

  Lookups[l].Lookup.ReadOnly:=Field.ReadOnly;
  Lookups[l].Lookup.ListSource:=Lookups[l].LookupData;
  Lookups[l].Lookup.Top:=Field.Top;
  Lookups[l].Lookup.Left:=Field.Left;
  If Field.IsFieldWidth Then
    Lookups[l].Lookup.Width:=Field.Width
  Else
    Lookups[l].Lookup.Width:=EditWidth;

  Field.Height:=Lookups[l].Lookup.Height;

  TempStr:=FindParam('VariableName=', Field.OPL);
  If TempStr<>'' Then
  begin
    FDCLLogOn.Variables.NewVariableWithTest(TempStr);
    Lookups[l].LookupToVars:=TempStr;
  end;

  Lookups[l].Lookup.KeyField:=FindParam('Key=', Field.OPL);
  Lookups[l].Lookup.ListField:=FindParam('List=', Field.OPL);

  TempStr:=FindParam('ModifyingEdit=', Field.OPL);
  If TempStr<>'' Then
    Lookups[l].ModifyEdits:=SortParams(TempStr, 1);

  TempStr:=FindParam('KeyValue=', Field.OPL);

  If (NoDataField) Then
    Lookups[l].LookupQuery.First;
  If TempStr<>'' Then
  begin
    TranslateVal(TempStr);
    If PosEx('select ', TempStr)<>0 Then
      If PosEx(' from ', TempStr)<>0 Then
      begin
        ShadowQuery:=TDCLDialogQuery.Create(nil);
        ShadowQuery.Name:='LookupShadow_'+IntToStr(UpTime);
        FDCLLogOn.SetDBName(ShadowQuery);
        ShadowQuery.SQL.Text:=TempStr;
        try
          ShadowQuery.Open;
          TempStr:=ShadowQuery.Fields[0].AsString;
          ShadowQuery.Close;
        Except
          ShowErrorMessage( - 1117, 'SQL='+TempStr);
        end;
        FreeAndNil(ShadowQuery);
      end;
    If (TempStr<>'') Then
    begin
      //If (Not FForm.Showing) and (Not NoDataField) Then
        FForm.Show;
      Lookups[l].Lookup.KeyValue:=TempStr;
      If (Not NoDataField) and Query.CanModify Then
      begin
        If (Not (FQuery.State in dsEditModes))and FQuery.Active and(Not NoDataField) Then
          Query.Edit;
        FData.DataSet.FieldByName(Field.FieldName).AsInteger:=StrToIntEx(TempStr);
      end;
    end;
  end;
  LookupOnClick(Lookups[l].Lookup);

  Lookups[l].LookupQuery.AfterScroll:=LookupDBScroll;

{$IFDEF FPC}
  Lookups[l].Lookup.OnSelect:=LookupOnClick;
{$ELSE}
  Lookups[l].Lookup.OnClick:=LookupOnClick;
{$ENDIF}

  IncXYPos(EditTopStep, Lookups[l].Lookup.Width, Field);
end;

procedure TDCLGrid.AddLookupTable(var Field: RField);
var
  l, FFactor: Word;
  TempStr, TmpStr, FieldName: String;
  v1, v2, v3: Integer;
  FField: RField;
begin
  l:=Length(LookupTables);
  SetLength(LookupTables, l+1);
  Field.CurrentEdit:=True;

  If Not Field.IsFieldHeight Then
    Field.Height:=LookupTableHeight;

  If Not Field.IsFieldWidth Then
    Field.Width:=EditWidth;

  LookupTables[l].LookupPanel:=TDialogPanel.Create(FieldPanel);
  LookupTables[l].LookupPanel.Parent:=FieldPanel;
  LookupTables[l].LookupPanel.Top:=Field.Top;
  LookupTables[l].LookupPanel.Left:=Field.Left;
  LookupTables[l].LookupPanel.Width:=Field.Width;
  LookupTables[l].LookupPanel.Height:=Field.Height;

  LookupTables[l].DCLGrid:=TDCLGrid.Create(FDCLForm, LookupTables[l].LookupPanel, dctLookupGrid,
    nil, FData);
  TempStr:=FindParam('SQL=', Field.OPL);
  FDCLForm.RePlaseVariables(TempStr);
  FFactor:=0;
  TranslateProc(TempStr, FFactor, Query);
  LookupTables[l].DCLGrid.SetSQL(TempStr);
  LookupTables[l].DCLGrid.ReadOnly:=Field.ReadOnly;
  LookupTables[l].DCLGrid.DependField:=FindParam('DependField=', Field.OPL);
  LookupTables[l].DCLGrid.NoDataField:=Field.NoDataField;

  LookupTables[l].DCLGrid.MasterValueVariableName:=FindParam('VariableName=', Field.OPL);

  if not Field.NoDataField then
  If FQuery.Active then
    If LookupTables[l].DCLGrid.MasterDataField='' then
      if FieldExists(LookupTables[l].DCLGrid.MasterDataField, FQuery) then
        LookupTables[l].DCLGrid.MasterDataField:=Field.FieldName;

  LookupTables[l].DCLGrid.Open;
  LookupTables[l].DCLGrid.Show;

  TempStr:=FindParam('Columns=', Field.OPL);
  If TempStr<>'' Then
  begin
    LookupTables[l].DCLGrid.Columns.Clear;
    v1:=ParamsCount(TempStr);
    For v2:=1 to v1 do
    begin
      v3:=0;
      TmpStr:=SortParams(TempStr, v2);
      FieldName:=Copy(TmpStr, 1, Pos('/', TmpStr)-1);
      if Pos('=', FieldName)<>0 then
      begin
        v3:=StrToIntEx(Copy(FieldName, Pos('=', FieldName)+1, Length(FieldName)));
        FieldName:=Copy(FieldName, 1, Pos('=', FieldName)-1);
      end;

      ResetFieldParams(FField);
      If FieldExists(FieldName, LookupTables[l].DCLGrid.Query) Then
      begin
        FField.FType:=LookupTables[l].DCLGrid.Query.FieldByName(FieldName).DataType;
        FField.FieldName:=FieldName;
        FField.Caption:=Copy(TmpStr, Pos('/', TmpStr)+1, Length(TmpStr)-1);
        if v3>10 then
          FField.Width:=v3;
      end
      Else
      begin
        FField.Caption:=GetDCLMessageString(msNoField)+FieldName;
      end;
      LookupTables[l].DCLGrid.AddColumn(FField);
    end;
  end;

  IncXYPos(LookupTables[l].LookupPanel.Height+EditTopStep, LookupTables[l].LookupPanel.Width, Field);
end;

procedure TDCLGrid.AddMediaFieldGroup(Parent: TWinControl; Align: TAlign; GroupType: TGroupType;
  var Field: RField);
var
  l: Word;
begin
  l:=Length(MediaFields);
  SetLength(MediaFields, l+1);
  MediaFields[l]:=TFieldGroup.Create(Parent, FData, Field, Align, GroupType);

  IncXYPos(EditTopStep, Field.Width, Field);
end;

function TDCLGrid.AddPartPage(Caption: String; Data: TDataSource; Style:TDataControlType): Integer;
var
  Pc: Integer;
begin
  If Not Assigned(FTablePartsPages) Then
  begin
    FTablePartsPages:=TPageControl.Create(FGridPanel);
    FTablePartsPages.Parent:=FGridPanel;
    FTablePartsPages.Top:=5;
    FTablePartsPages.Height:=150;
    FTablePartsPages.Align:=alTop;
    FTablePartsPages.OnChange:=ChangeTabPage;
    FTablePartsPages.Tag:=2;
    FTablePartsPages.Align:=alBottom;
  end;

  Pc:=FTablePartsPages.PageCount;
  FTablePartsTabs:=TTabSheet.Create(FTablePartsPages);
  If Caption='' Then
    FTablePartsTabs.Caption:=GetDCLMessageString(msPage)+' '+IntToStr(Pc+1)
  Else
    FTablePartsTabs.Caption:=InitCap(Caption);

  FTablePartsTabs.Name:='TablePart_'+IntToStr(Pc+1);
  FTablePartsTabs.PageControl:=FTablePartsPages;

  FTablePartsPages.ActivePage:=FTablePartsPages.Pages[0];
  FTablePartsPages.ActivePageIndex:=0;

  PartTabIndex:=AddTablePart(FTablePartsTabs.PageControl.Pages[FTablePartsPages.PageCount-1], Data, Style);
  FTablePartsTabs.PageControl.Pages[FTablePartsPages.PageCount-1].Tag:=PartTabIndex;
  Result:=PartTabIndex;
end;

procedure TDCLGrid.AddPopupMenuItem(Caption, ItemName: String; Action: TNotifyEvent;
  AChortCutKey: String; Tag: Integer; PictType: String);
begin
  ItemMenu:=TMenuItem.Create(PopupGridMenu);
  ItemMenu.Tag:=Tag;
  ItemMenu.Caption:=Caption;
  ItemMenu.Name:=ItemName;
  ItemMenu.OnClick:=Action;
  ItemMenu.Bitmap.Assign(DrawBMPButton(PictType));
  ItemMenu.Bitmap.TransparentColor:=clWhite;
  ItemMenu.Bitmap.TransparentMode:=tmAuto;

{$IFNDEF FPC}
  ItemMenu.ShortCut:=TextToShortCut(AChortCutKey);
{$ENDIF}
  PopupGridMenu.Items.Add(ItemMenu);
end;

procedure TDCLGrid.AddRollBar(var Field: RField);
var
  l: Word;
  TempStr: String;
begin
  Field.CurrentEdit:=True;
  l:=Length(RollBars);
  SetLength(RollBars, l+1);
  RollBars[l].RollBar:=TTrackBar.Create(FieldPanel);
  RollBars[l].RollBar.Parent:=FieldPanel;
  RollBars[l].RollBar.Top:=Field.Top;
  RollBars[l].RollBar.Left:=Field.Left;
  RollBars[l].RollBar.Width:=EditWidth;
  RollBars[l].RollBar.Height:=RollHeight;
  RollBars[l].RollBar.Tag:=l;

  TempStr:=FindParam('_Min=', Field.OPL);
  TranslateVal(TempStr);
  RollBars[l].RollBar.Min:=StrToIntEx(TempStr);

  TempStr:=FindParam('_Max=', Field.OPL);
  TranslateVal(TempStr);
  RollBars[l].RollBar.Max:=StrToIntEx(TempStr);

  TempStr:=FindParam('_VariableName=', Field.OPL);
  If TempStr<>'' Then
  begin
    If FDCLLogOn.Variables.Exists(TempStr) Then
    begin
      If Not FieldExists(Field.FieldName, Query) Then
        RollBars[l].RollBar.Position:=StrToInt(TempStr);
      RollBars[l].Variable:=TempStr;
    end
    Else
      FDCLLogOn.Variables.NewVariableWithTest(TempStr);
  end;

  If FieldExists(Field.FieldName, Query) Then
    RollBars[l].Field:=Field.FieldName;

  If FieldExists(Field.FieldName, Query) Then
    If Query.Active Then
      RollBars[l].RollBar.Position:=Query.FieldByName(Field.FieldName).AsInteger;

  RollBars[l].RollBar.OnChange:=RollBarOnChange;

  IncXYPos(EditTopStep, RollBars[l].RollBar.Width, Field);
end;

procedure TDCLGrid.AddSubPopupItem(Caption, ItemName: String; Action: TNotifyEvent;
  ToMenu, Tag: Integer);
begin
  If ToMenu<> - 1 Then
  begin
    ToItem:=PopupGridMenu.Items[ToMenu];
    ItemMenu:=TMenuItem.Create(ToItem);
    ItemMenu.Tag:=Tag;
    ItemMenu.Name:=ItemName;
    ItemMenu.Caption:=Caption;
    ItemMenu.OnClick:=Action;
    ToItem.OnClick:=nil;
    ToItem.Insert(ToItem.Count, ItemMenu);
  end;
end;

procedure TDCLGrid.AddSumGrid(OPL: String);
var
  TempStr, KeyField, tmpSQL, tmpSQL1: String;
  v1, v2: Integer;
begin
  SumQuery:=TDCLDialogQuery.Create(nil);
  SumQuery.Name:='SummQuery_'+IntToStr(UpTime);
  SummString:=FindParam('SummQuery=', OPL);
  SumQuery.SQL.Text:=GetSummQuery;
  FDCLLogOn.SetDBName(SumQuery);
  SumData:=TDataSource.Create(nil);
  SumData.DataSet:=SumQuery;
  SumQuery.Open;

  SummGrid:=TNoScrollBarDBGrid.Create(FGridPanel);
  SummGrid.Align:=alBottom;
  SummGrid.Height:=SummGridHeight;
  SummGrid.Name:='SumGrid';
  SummGrid.Parent:=FGridPanel;
  SummGrid.Options:=[dgColLines];
  SummGrid.DataSource:=SumData;
  SummGrid.ScrollBars:=ssNone;

  TempStr:=FindParam('Columns=', OPL);
  If TempStr<>'' Then
  begin
    SummGrid.Columns.Clear;
    v1:=ParamsCount(TempStr);
    For v2:=1 to v1 do
    begin
      KeyField:=SortParams(TempStr, v2);
      tmpSQL:=Copy(KeyField, 1, Pos('/', KeyField)-1);
      tmpSQL1:=Copy(KeyField, Pos('/', KeyField)+1, Length(KeyField));
      If FieldExists(tmpSQL, SumQuery) Then
      begin
        SummGrid.Columns.Add.FieldName:=tmpSQL;
        SummGrid.Columns[v2-1].Width:=StrToIntEx(tmpSQL1);
      end
      Else
      begin
        SummGrid.Columns.Add;
        SummGrid.Width:=StrToIntEx(tmpSQL1);
      end;
    end;
  end;
end;

function TDCLGrid.AddTablePart(Parent: TWinControl; Data: TDataSource; Style:TDataControlType): Integer;
var
  FPartsCount: Integer;
begin
  PagePanelCreated:=False;
  FPartsCount:=Length(FTableParts);
  SetLength(FTableParts, FPartsCount+1);
  FTableParts[FPartsCount]:=TDCLGrid.Create(FDCLForm, Parent, Style, nil, Data);
  Result:=FPartsCount;
end;

procedure TDCLGrid.AddToolPanel;
begin
  If Not Assigned(ToolPanel) Then
  begin
    ToolPanel:=TDialogPanel.Create(FGridPanel);
    ToolPanel.Parent:=FGridPanel;
    ToolPanel.Top:=1;
    ToolPanel.Height:=ToolPanelHeight;
    ToolPanel.Align:=alTop;
    ToolPanelElementLeft:=0;
  end;
end;

procedure TDCLGrid.AddToolPartButton(ButtonParam: RButtonParams);
begin
  If Not PagePanelCreated Then
  begin
    PagePanel:=TDialogPanel.Create(FTablePartsTabs.PageControl.Pages[FTablePartsPages.PageCount-1]);
    PagePanel.Parent:=FTablePartsTabs.PageControl.Pages[FTablePartsPages.PageCount-1];
    PagePanel.Align:=alTop;
    PagePanel.Height:=ToolPagePanelHeight;
    PagePanelCreated:=True;
    PartButtonLeft:=TablePartButtonLeft;
    PartButtonTop:=TablePartButtonTop;
  end;

  ButtonParam.Top:=PartButtonTop;
  ButtonParam.Left:=PartButtonLeft;
  FDCLForm.Commands.AddCommand(PagePanel, ButtonParam);

  inc(PartButtonLeft, ButtonParam.Width+TablePartButtonStep);
end;

procedure TDCLGrid.AfterCancel(Data: TDataSet);
var
  v1, v2: Integer;
begin
  ExecEvents(EventsCancel);

  SetDataStatus(dssSaved);
  ScrollDB(Data);
  For v1:=1 to FDCLLogOn.FormsCount do
  begin
    If Assigned(FDCLLogOn.Forms[v1-1]) Then
      If Assigned(FDCLLogOn.Forms[v1-1].ParentForm) Then
      begin
        If FDCLLogOn.Forms[v1-1].ParentForm=FDCLForm Then
          For v2:=1 to FDCLLogOn.Forms[v1-1].TablesCount do
            FDCLLogOn.Forms[v1-1].Tables[v2-1].ScrollDB(FQuery);
      end;
  end;

  For v1:=1 to FDCLLogOn.FormsCount do
  begin
    If Assigned(FDCLLogOn.Forms[v1-1]) Then
      If Assigned(FDCLLogOn.Forms[v1-1].ParentForm) Then
      begin
        If FDCLLogOn.Forms[v1-1].ParentForm=FDCLForm Then
          For v2:=1 to FDCLLogOn.Forms[v1-1].TablesCount do
            FDCLLogOn.Forms[v1-1].Tables[v2-1].AfterCancel(FQuery);
      end;
  end;
end;

procedure TDCLGrid.AfterClose(Data: TDataSet);
begin
  Screen.Cursor:=crDefault;
end;

procedure TDCLGrid.AfterEdit(Data: TDataSet);
var
  v1, v2: Integer;
begin
  If FUserLevelLocal<ulWrite Then
    Data.Cancel;

  For v1:=1 to FDCLLogOn.FormsCount do
  begin
    If Assigned(FDCLLogOn.Forms[v1-1]) Then
      If Assigned(FDCLLogOn.Forms[v1-1].ParentForm) Then
      begin
        If FDCLLogOn.Forms[v1-1].ParentForm=FDCLForm Then
          For v2:=1 to FDCLLogOn.Forms[v1-1].TablesCount do
            FDCLLogOn.Forms[v1-1].Tables[v2-1].ScrollDB(Data);
      end;
  end;
end;

procedure TDCLGrid.AfterInsert(Data: TDataSet);
var
  v1, v2: Integer;
  vv:String;
begin
  If FUserLevelLocal<ulWrite Then
    Data.Cancel
  Else
  begin
    If DependField<>'' Then
    Begin
      if not NoDataField then
      begin
        If MasterDataField<>'' Then
        begin
          Data.FieldByName(DependField).AsString:=FDCLForm.CurrentQuery.FieldByName
            (MasterDataField).AsString;
        end;
      end
      else
      begin
        if MasterValueVariableName<>'' then
        begin
          Data.FieldByName(DependField).AsString:=FDCLLogOn.Variables.GetVariableByName(MasterValueVariableName);
        end;
      end;
    End;

    ExecEvents(EventsInsert);

    SetDataStatus(dssChanged);
  end;

  For v1:=1 to FDCLLogOn.FormsCount do
  begin
    If Assigned(FDCLLogOn.Forms[v1-1]) Then
      If Assigned(FDCLLogOn.Forms[v1-1].ParentForm) Then
      begin
        If FDCLLogOn.Forms[v1-1].ParentForm=FDCLForm Then
          For v2:=1 to FDCLLogOn.Forms[v1-1].TablesCount do
            FDCLLogOn.Forms[v1-1].Tables[v2-1].AfterInsert(Data);
      end;
  end;
end;

procedure TDCLGrid.AfterOpen(Data: TDataSet);
var
  tmpSQL: String;
  v1, v2: Integer;
begin
  If Assigned(FDCLLogOn) Then
  begin
    Screen.Cursor:=crDefault;
    ExecEvents(EventsAfterOpen);

    If Assigned(SumQuery) Then
    begin
      tmpSQL:=GetSummQuery;
      TranslateVal(tmpSQL);
      SumQuery.Close;
      SumQuery.SQL.Text:=tmpSQL;
      try
        SumQuery.Open;
      Except
        ShowErrorMessage( - 1118, 'SQL='+tmpSQL);
      end;
    end;

    For v1:=1 to FDCLLogOn.FormsCount do
    begin
      If Assigned(FDCLLogOn.Forms[v1-1]) Then
        If Assigned(FDCLLogOn.Forms[v1-1].ParentForm) Then
        begin
          If FDCLLogOn.Forms[v1-1].ParentForm=FDCLForm Then
            For v2:=1 to FDCLLogOn.Forms[v1-1].TablesCount do
              FDCLLogOn.Forms[v1-1].Tables[v2-1].ScrollDB(Data);
        end;
    end;

    For v1:=1 to FDCLLogOn.FormsCount do
    begin
      If Assigned(FDCLLogOn.Forms[v1-1]) Then
        If Assigned(FDCLLogOn.Forms[v1-1].ParentForm) Then
        begin
          If FDCLLogOn.Forms[v1-1].ParentForm=FDCLForm Then
            For v2:=1 to FDCLLogOn.Forms[v1-1].TablesCount do
              FDCLLogOn.Forms[v1-1].Tables[v2-1].AfterOpen(Data);
        end;
    end;
  end;
end;

procedure TDCLGrid.AfterPost(Data: TDataSet);
var
  v1, v2: Integer;
begin
  SaveDB;
  ExecEvents(EventsAfterPost);

  For v1:=1 to FDCLLogOn.FormsCount do
  begin
    If Assigned(FDCLLogOn.Forms[v1-1]) Then
      If Assigned(FDCLLogOn.Forms[v1-1].ParentForm) Then
      begin
        If FDCLLogOn.Forms[v1-1].ParentForm=FDCLForm Then
          For v2:=1 to FDCLLogOn.Forms[v1-1].TablesCount do
            FDCLLogOn.Forms[v1-1].Tables[v2-1].ScrollDB(FQuery);
      end;
  end;

  For v1:=1 to FDCLLogOn.FormsCount do
  begin
    If Assigned(FDCLLogOn.Forms[v1-1]) Then
      If Assigned(FDCLLogOn.Forms[v1-1].ParentForm) Then
      begin
        If FDCLLogOn.Forms[v1-1].ParentForm=FDCLForm Then
          For v2:=1 to FDCLLogOn.Forms[v1-1].TablesCount do
            FDCLLogOn.Forms[v1-1].Tables[v2-1].AfterPost(FQuery);
      end;
  end;
  ReFreshQuery;
  FDCLLogOn.NotifyForms(fnaRefresh);
end;

procedure TDCLGrid.AfterRefresh(Data: TDataSet);
begin
  FDCLForm.SetDBStatus('');
  BaseChanged:=False;
end;

procedure TDCLGrid.AutorefreshTimer(Sender: TObject);
begin
  If Not RefreshLock Then
  begin
    RefreshLock:=True;
    If FQuery.State in [dsBrowse] Then
      ReFreshQuery;
    RefreshLock:=False;
  end;
end;

procedure TDCLGrid.BeforeOpen(Data: TDataSet);
begin
  Screen.Cursor:=crSQLWait;
end;

procedure TDCLGrid.BeforePost(Data: TDataSet);
var
  v1, v2: Integer;
begin
  ExecEvents(EventsBeforePost);

  For v1:=1 to FDCLLogOn.FormsCount do
  begin
    If Assigned(FDCLLogOn.Forms[v1-1]) Then
      If Assigned(FDCLLogOn.Forms[v1-1].ParentForm) Then
      begin
        If FDCLLogOn.Forms[v1-1].ParentForm=FDCLForm Then
          For v2:=1 to FDCLLogOn.Forms[v1-1].TablesCount do
            FDCLLogOn.Forms[v1-1].Tables[v2-1].BeforePost(FQuery);
      end;
  end;
end;

procedure TDCLGrid.BeforeScroll(Data: TDataSet);
var
  v1, v2: Integer;
begin
  ExecEvents(EventsBeforeScroll);

  For v1:=1 to FDCLLogOn.FormsCount do
  begin
    If Assigned(FDCLLogOn.Forms[v1-1]) Then
      If Assigned(FDCLLogOn.Forms[v1-1].ParentForm) Then
      begin
        If FDCLLogOn.Forms[v1-1].ParentForm=FDCLForm Then
          For v2:=1 to FDCLLogOn.Forms[v1-1].TablesCount do
            FDCLLogOn.Forms[v1-1].Tables[v2-1].BeforeScroll(FQuery);
      end;
  end;
end;

procedure TDCLGrid.CalendarOnChange(Sender: TObject);
var
  CalendarIdx: Integer;
  EdDate: String;
begin
  CalendarIdx:=(Sender as DateTimePicker).Tag;

  EdDate:=DateToStr((Sender as DateTimePicker).Date);
  FDCLLogOn.Variables.Variables[Calendars[CalendarIdx].VarName]:=EdDate;
  If Calendars[CalendarIdx].ReOpen Then
  begin
    FQuery.Close;
    EdDate:='Query='+FindRaightQuery();
    EdDate:=FindParam('Query=', EdDate);
    TranslateVal(EdDate);
    FQuery.SQL.Text:=EdDate;

    try
      FQuery.Open;
    Except
      ShowErrorMessage( - 1100, 'SQL='+EdDate);
    end;

    OpenQuery(QueryBuilder(0));
  end;
end;

procedure TDCLGrid.CancelDB;
begin
  SetDataStatus(dssSaved);
end;

procedure TDCLGrid.ChangeTabPage(Sender: TObject);
begin
  CurrentTabIndex:=(Sender as TPageControl).ActivePageIndex;
  FDCLForm.CurrentTabIndex:=CurrentTabIndex;
end;

procedure TDCLGrid.CheckOnClick(Sender: TObject);
var
  sd: String;
  isd: Integer;
begin
  isd:=(Sender as TCheckbox).Tag;
  sd:=CheckBoxes[isd].CheckBoxToVars;
  If FDCLLogOn.Variables.Exists(sd) Then
    Case (Sender as TCheckbox).Checked of
    True:
    FDCLLogOn.Variables.Variables[sd]:='1';
    False:
    FDCLLogOn.Variables.Variables[sd]:='0';
    end;
end;

procedure TDCLGrid.ClearNotAllowedOperations;
begin
  SetLength(NotAllowedOperations, 0);
end;

procedure TDCLGrid.ClickNavig(Sender: TObject; Button: TNavigateBtn);
begin
  If Button=nbRefresh Then
    ReFreshQuery;
end;

procedure TDCLGrid.Close;
begin
  If FQuery.Active Then
  begin
    If FQuery.State in dsEditModes Then
      FQuery.Post;
    FQuery.Close;
  end;
end;

procedure TDCLGrid.ColumnsManege(Sender: TObject);
var
  CIndex: Integer;
begin
  CIndex:=ColumnsList.ItemIndex;
  If CIndex<> - 1 Then
  begin
    FGrid.Columns.Delete(CIndex);
    ColumnsList.Items.Delete(CIndex);
    DeleteList(CIndex);
  end;
end;

procedure TDCLGrid.ContextFieldButtonsClick(Sender: TObject);
var
  i: Integer;
begin
  i:=(Sender as TComponent).Tag;
  If i<> - 1 Then
    If ContextFieldButtons[i].Command<>'' Then
      FDCLForm.ExecCommand(ContextFieldButtons[i].Command);
end;

procedure TDCLGrid.ContextListChange(Sender: TObject);
var
  ComboNum: Integer;
  Combo: TComboBox;
  tmpQuery: TDCLDialogQuery;
begin
  ComboNum:=(Sender as TComponent).Tag;
  Combo:=(Sender as TComboBox);
  If Trim(Combo.Text)<>'' Then
  begin
    tmpQuery:=TDCLDialogQuery.Create(nil);
    tmpQuery.Name:='tmpContextListQ_'+IntToStr(UpTime);
    FDCLLogOn.SetDBName(tmpQuery);

    If ContextLists[ComboNum].Table<>'' Then
      tmpQuery.SQL.Text:='select '+ContextLists[ComboNum].KeyField+' from '+ContextLists[ComboNum]
        .Table+' where '+ContextLists[ComboNum].Field+'='+GPT.StringTypeChar+Combo.Text+
        GPT.StringTypeChar
    Else
    begin
      If PosEx(' where ', ContextLists[ComboNum].SQL)<>0 Then
        tmpQuery.SQL.Text:=ContextLists[ComboNum].SQL+' and '+ContextLists[ComboNum].Field+'='+
          GPT.StringTypeChar+Combo.Text+GPT.StringTypeChar
      Else
        tmpQuery.SQL.Text:=ContextLists[ComboNum].SQL+' where '+ContextLists[ComboNum].Field+'='+
          GPT.StringTypeChar+Combo.Text+GPT.StringTypeChar;
    end;

    tmpQuery.Open;

    If Not tmpQuery.IsEmpty Then
    begin
      if not ContextLists[ComboNum].NoData and FQuery.CanModify then
      begin
        If (FQuery.State=dsBrowse) Then
          FQuery.Edit;
        FQuery.FieldByName(ContextLists[ComboNum].DataField).AsInteger:=
          tmpQuery.FieldByName(ContextLists[ComboNum].KeyField).AsInteger;
      end;
      if FDCLLogOn.Variables.Exists(ContextLists[ComboNum].Variable) then
      begin
        FDCLLogOn.Variables.Variables[ContextLists[ComboNum].Variable]:=tmpQuery.FieldByName(ContextLists[ComboNum].KeyField).AsString;
      end;
    end;
    tmpQuery.Close;
    FreeAndNil(tmpQuery);
  end;
end;

procedure TDCLGrid.ContextListKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  ComboNum: Integer;
  tmpQuery: TDCLDialogQuery;
  Combo: TComboBox;
begin
  ComboNum:=(Sender as TComponent).Tag;
  Combo:=(Sender as TComboBox);
  If (Key=13)and(Shift=[ssCtrl]) Then
    If Combo.Text<>'' Then
    begin
      tmpQuery:=TDCLDialogQuery.Create(nil);
      tmpQuery.Name:='ContextListKeyDown_'+IntToStr(UpTime);
      FDCLLogOn.SetDBName(tmpQuery);
      tmpQuery.SQL.Text:='select '+ContextLists[ComboNum].Field+', '+ContextLists[ComboNum].KeyField
        +' from '+ContextLists[ComboNum].Table+' where '+GPT.UpperString+ContextLists[ComboNum]
        .Field+GPT.UpperStringEnd+' like '+GPT.UpperString+GPT.StringTypeChar+'%'+Combo.Text+'%'+
        GPT.StringTypeChar+') ';
      tmpQuery.Open;
      tmpQuery.Last;
      tmpQuery.First;

      Combo.Items.Clear;

      If tmpQuery.RecordCount=1 Then
      begin
        if FieldExists(ContextLists[ComboNum].DataField, FQuery) then
        begin
          Combo.Text:=Trim(tmpQuery.FieldByName(ContextLists[ComboNum].Field).AsString);
          If (FQuery.Active and FQuery.CanModify and (FQuery.State=dsBrowse)) Then
          begin
            FQuery.Edit;
            FQuery.FieldByName(ContextLists[ComboNum].DataField).AsInteger:=
              tmpQuery.FieldByName(ContextLists[ComboNum].KeyField).AsInteger;
          end;
        end;
      end;
      While Not tmpQuery.Eof do
      begin
        If Trim(tmpQuery.FieldByName(ContextLists[ComboNum].Field).AsString)<>'' Then
          Combo.Items.Append(Trim(tmpQuery.FieldByName(ContextLists[ComboNum].Field).AsString));
        tmpQuery.Next;
      end;
      tmpQuery.Close;
      FreeAndNil(tmpQuery);

{$IFDEF MSWINDOWS}
      If SendMessage(Combo.Handle, CB_GETDROPPEDSTATE, 0, 0)<>1 Then
        SendMessage(Combo.Handle, CB_SHOWDROPDOWN, 1, 0);
{$ENDIF}
    end;
end;

constructor TDCLGrid.Create(var Form: TDCLForm; Parent: TWinControl; SurfType: TDataControlType;
  Query: TDCLDialogQuery; Data: TDataSource);
var
  v1: Integer;
begin
  inherited Create(Form);
  PosBookCreated:=False;
  FromForm:=Form.FName;
  FOrientation:=oVertical;
  MaxStepFields:=0;
  FShowed:=False;
  FDCLForm:=Form;
  FDisplayMode:=SurfType;
  FUserLevelLocal:=FDCLForm.UserLevelLocal;
  FForm:=FDCLForm.FForm;
  FDCLLogOn:=FDCLForm.FDCLLogOn;
  FData:=TDataSource.Create(nil);
  PagePanelCreated:=False;
  PartButtonLeft:=TablePartButtonLeft;
  PartButtonTop:=TablePartButtonTop;
  RowColor:=clWhite;
  RowTextColor:=clBlack;
  PreviousColumnIndex:=-1;

  FData.DataSet:=Query;
  If Not Assigned(Query) Then
  begin
    SetNewQuery(Data);
  end;

  If Assigned(Data) Then
    FQuery.DataSource:=Data;

  FDCLLogOn.SQLMon.AddTrace(FQuery);

  FGridPanel:=TDCLMainPanel.Create(Parent);
  FGridPanel.Parent:=Parent;
  FGridPanel.Align:=alClient;
  FGridPanel.Name:='GridPanel';

  Navig:=TDBNavigator.Create(FGridPanel);
  Navig.Parent:=FGridPanel;
  Navig.Name:='Fafigator';
  Navig.Align:=alTop;
  Navig.ShowHint:=True;
  Navig.DataSource:=FData;
  Navig.BeforeAction:=ClickNavig;

  For v1:=1 to Navig.ControlCount do
    If Navig.Controls[v1-1] is TNavButtons Then
      With Navig.Controls[v1-1] do
      begin
        Case TNavigateBtn((Navig.Controls[v1-1] as TNavButtons).Index) of
        nbFirst:
        Hint:=GetDCLMessageString(msInBegin);
        nbPrior:
        Hint:=GetDCLMessageString(msPrior);
        nbNext:
        Hint:=GetDCLMessageString(msNext);
        nbLast:
        Hint:=GetDCLMessageString(msInEnd);
        nbPost:
        Hint:=GetDCLMessageString(msPost);
        nbInsert:
        Hint:=GetDCLMessageString(msInsert);
        nbCancel:
        Hint:=GetDCLMessageString(msCancel);
        nbEdit:
        Hint:=GetDCLMessageString(msEdit);
        nbDelete:
        Hint:=GetDCLMessageString(msDelete);
        nbRefresh:
        Hint:=GetDCLMessageString(msRefresh);
        end;
      end;
end;

procedure TDCLGrid.CreateBookMarkMenu(MenuList: TStringList);
var
  v3, i: Integer;
  FileLine: String;
begin
  If MenuList.Count>0 Then
  begin
    For i:=1 to MenuList.Count div KeyMarksItems do
    begin
      FileLine:=MenuList[i-1];

      v3:=Length(KeyMarks.KeyBookMarks);
      SetLength(KeyMarks.KeyBookMarks, v3+1);

      FileLine:=MenuList[i-1];
      KeyMarks.KeyBookMarks[v3].KeyField:=FindParam('Key=', FileLine);

      FileLine:=MenuList[i];
      KeyMarks.KeyBookMarks[v3].KeyValue:=FindParam('Value=', FileLine);

      FileLine:=MenuList[i+1];
      If PosEx('Title=', FileLine)<>0 Then
        KeyMarks.KeyBookMarks[v3].Title:=FindParam('Title=', FileLine)
      Else
      begin
        ShowErrorMessage(0, GetDCLMessageString(msOldBookmarkFormat));
        Exit;
      end;
    end;
  end;

  RefreshBookMarkMenu;
end;

function TDCLGrid.SaveBookMarkMenu: TStringList;
var
  i: Integer;
begin
  Result:=TStringList.Create;
  If Length(KeyMarks.KeyBookMarks)>0 Then
  begin
    For i:=1 to Length(KeyMarks.KeyBookMarks) do
    begin
      If KeyMarks.KeyBookMarks[i-1].KeyValue<>'' Then
      begin
        Result.Append('Key='+KeyMarks.KeyBookMarks[i-1].KeyField);
        Result.Append('Value='+KeyMarks.KeyBookMarks[i-1].KeyValue);
        Result.Append('Title='+KeyMarks.KeyBookMarks[i-1].Title);
      end;
    end;
  end;
end;

procedure TDCLGrid.DeleteAllBookmarks;
var
  i: Integer;
begin
  For i:=1 to Length(KeyMarks.KeyBookMarks) do
    DeleteMenuBookMark(i-1);
end;

procedure TDCLGrid.CreatePartColumns;
var
  i: Word;
  FF: RField;
begin
  Show;
  If Assigned(FGrid) Then
  begin
    FGrid.Columns.Clear;
    For i:=1 to Length(DataFields) do
    begin
      FF.FieldName:=DataFields[i-1].Name;
      FF.Caption:=DataFields[i-1].Caption;
      FF.Width:=DataFields[i-1].Width;
      FF.ReadOnly:=DataFields[i-1].ReadOnly;

      AddColumn(FF);
    end;
  end;
end;

procedure TDCLGrid.CreateFields(FOPL: TStringList);
var
  FField: RField;
  FieldCaptScrStr, FieldNameStr, TmpStr, tmpStr2, ScrStr: String;
  ScrStrNum, v1, i1, CountFields, FieldNo, OPLStrNo: Integer;
  ShadowQuery: TDCLDialogQuery;
begin
  ScrStrNum:=0;
  If FOPL.Count>=1 Then
  begin
    If (LowerCase(Trim(FOPL[0]))<>'[fields]')and(FOPL.Count=1) Then
    begin
      ScrStr:=FOPL[0];
      TmpStr:=FindParam('Columns=', ScrStr);
      If TmpStr<>'' Then
      begin
        v1:=ParamsCount(TmpStr);
        FOPL.Append(IntToStr(v1));
        For i1:=1 to v1 do
        begin
          tmpStr2:=SortParams(TmpStr, i1);
          FieldCaptScrStr:=Copy(tmpStr2, 1, Pos('/', tmpStr2)-1);
          v1:=0;
          If Pos('=', FieldCaptScrStr)<>0 Then
          begin
            v1:=StrToIntEx(CopyCut(FieldCaptScrStr, Pos('=', FieldCaptScrStr)+1,
                Length(FieldCaptScrStr)));
            Delete(FieldCaptScrStr, PosEx('=', FieldCaptScrStr), Length(FieldCaptScrStr));
          end;

          ResetFieldParams(FField);
          If FieldExists(FieldCaptScrStr, Query) Then
          begin
            FField.FieldName:=FieldCaptScrStr;
            FField.Caption:=Copy(tmpStr2, Pos('/', tmpStr2)+1, Length(tmpStr2)-1);
            FField.Width:=v1;
          end
          Else
          begin
            FField.Caption:=GetDCLMessageString(msNoField)+FieldCaptScrStr;
            FField.Width:=v1;
          end;

          tmpStr2:=FField.FieldName;
          If v1<>0 Then
            tmpStr2:=tmpStr2+';Width='+IntToStr(v1)+';';

          FOPL.Append(FField.Caption);
          FOPL.Append(tmpStr2);
        end;
        FOPL[0]:='[Fields]';
      end;
    end;

    If (LowerCase(Trim(FOPL[0]))='[fields]')and(FOPL.Count>1) Then
    begin
      Show;
      Query.NotAllowOperations:=NotAllowedOperations;
      FField.Top:=BeginStepTop;
      FField.Left:=BeginStepLeft;
      If FOPL[ScrStrNum+1]='*' Then
      begin
        If (FieldCount>0)or(Query.Active) Then
          FOPL[ScrStrNum+1]:=IntToStr(FieldCount)
        Else
          FOPL[ScrStrNum+1]:='0';

        For v1:=1 to Query.FieldCount do
        begin
          FOPL.Insert(ScrStrNum+v1*2, Query.Fields[v1-1].FieldName);
          FOPL.Insert(ScrStrNum+1+v1*2, Query.Fields[v1-1].FieldName);
        end;
      end
      Else If PosEx('LoadFromTable=', FOPL[ScrStrNum+1])<>0 Then
      begin
        ShadowQuery:=TDCLDialogQuery.Create(nil);
        ShadowQuery.Name:='ShadFields_'+IntToStr(UpTime);
        FDCLLogOn.SetDBName(ShadowQuery);
        ShadowQuery.SQL.Text:=FindParam('SQL=', FOPL[ScrStrNum+1]);
        try
          ShadowQuery.Open;
        Except
          ShowErrorMessage(-1103, 'SQL='+ShadowQuery.SQL.Text);
        end;
        ShadowQuery.Last;
        ShadowQuery.First;
        FOPL[ScrStrNum+1]:=IntToStr(ShadowQuery.RecordCount);
        For v1:=0 to ShadowQuery.RecordCount-1 do
        begin
          FOPL.Insert(ScrStrNum+2+v1*2, Trim(ShadowQuery.Fields[0].AsString));
          FOPL.Insert(ScrStrNum+3+v1*2, Trim(ShadowQuery.Fields[1].AsString));
          ShadowQuery.Next;
        end;
        FreeAndNil(ShadowQuery);
      end;

      try
        CountFields:=StrToInt(Trim(FOPL[ScrStrNum+1]));
      Except
        CountFields:=0;
        ShowErrorMessage(-4002, '');
      end;

      Case DisplayMode of
      dctMainGrid:
      begin
        If Not ReadOnly Then
          ReadOnly:=(FUserLevelLocal=ulReadOnly)or(FindNotAllowedOperation(dsoEdit));
        If (FUserLevelLocal=ulReadOnly)or(FindNotAllowedOperation(dsoEdit)) Then
          If dgEditing in FGrid.Options then
            Options:=Options-[dgEditing];
      end;
      dctFields, dctFieldsStep:
      begin
        { FGrids[GridIndex].FieldPanel:=TDialogPanel.Create(FGrids[GridIndex].FGridPanel);
          FGrids[GridIndex].FieldPanel.Parent:=FGrids[GridIndex].FGridPanel;
          FGrids[GridIndex].FieldPanel.Align:=alClient; }
      end;

      end;

      FieldNo:=0;
      For OPLStrNo:=1 to CountFields do
      begin
        inc(FieldNo);
        ResetFieldParams(FField);
        If FOPL.Count<ScrStrNum+FieldNo+FieldNo+1 Then
          break;

        FieldCaptScrStr:=FOPL[ScrStrNum+FieldNo+FieldNo];
        FieldNameStr:=FOPL[ScrStrNum+FieldNo+FieldNo+1];
        FField.OPL:=FieldCaptScrStr+';'+FieldNameStr;

        inc(GPT.CurrentRunningScrString);

        If Pos('//', FOPL[ScrStrNum+FieldNo+FieldNo])=1 Then
          If ScrStrNum+FieldNo+FieldNo<FOPL.Count Then
          begin
            inc(FieldNo);
            Continue;
          end;

        If Pos('\', FOPL[ScrStrNum+FieldNo+FieldNo])<>0 Then
        begin
          i1:=1;
          While FOPL[ScrStrNum+FieldNo+FieldNo][i1]<>'\' do
            inc(i1);
          FField.Caption:=Copy(FOPL[ScrStrNum+FieldNo+FieldNo], 1, i1-1);
        end
        Else
        begin
          If Pos(';', FOPL[ScrStrNum+FieldNo+FieldNo])<>0 Then
          begin
            i1:=1;
            While FOPL[ScrStrNum+FieldNo+FieldNo][i1]<>';' do
              inc(i1);
            FField.Caption:=InitCap(Trim(Copy(FOPL[ScrStrNum+FieldNo+FieldNo], 1, i1-1)));
          end
          Else
            FField.Caption:=InitCap(Trim(FOPL[ScrStrNum+FieldNo+FieldNo]));
        end;

        TmpStr:=FOPL[ScrStrNum+FieldNo+FieldNo+1];
        If Pos(';', TmpStr)<>0 Then
        begin
          i1:=1;
          While TmpStr[i1]<>';' do
            inc(i1);
          FField.FieldName:=Trim(Copy(TmpStr, 1, i1-1));
        end
        Else
          FField.FieldName:=Trim(FOPL[ScrStrNum+FieldNo+FieldNo+1]);

        FField.Hint:=FindParam('Hint=', FOPL[ScrStrNum+FieldNo+FieldNo]);

        TmpStr:=FindParam('VariableName=', FOPL[ScrStrNum+FieldNo+FieldNo]);
        If TmpStr<>'' Then
          FField.Variable:=TmpStr;

        If FieldExists(FField.FieldName, Query) Then
          FField.FType:=Query.FieldByName(FField.FieldName).DataType
        Else
          FField.FType:=ftString;

        If PosEx('HidePassword;', FOPL[ScrStrNum+FieldNo+FieldNo])<>0 Then
          FField.PasswordChar:=MaskPassChar
        Else
          FField.PasswordChar:=#0;

        If PosEx('As_Logic;', FOPL[ScrStrNum+FieldNo+FieldNo])<>0 Then
        begin
          FField.FType:=ftBoolean;
          TmpStr:=Trim(FindParam('ValueChecked=', FOPL[ScrStrNum+FieldNo+FieldNo]));
          If TmpStr<>'' Then
            FField.CheckValue:=TmpStr;
          TmpStr:=Trim(FindParam('ValueUnChecked=', FOPL[ScrStrNum+FieldNo+FieldNo]));
          If TmpStr<>'' Then
            FField.UnCheckValue:=TmpStr;
        end;

        If PosEx('As_Graphic;', FOPL[ScrStrNum+FieldNo+FieldNo])<>0 Then
        begin
          FField.FType:=ftGraphic;
        end;

        If PosEx('As_Date;', FOPL[ScrStrNum+FieldNo+FieldNo])<>0 Then
        begin
          FField.FType:=ftDate;
        end;

        If PosEx('As_Memo;', FOPL[ScrStrNum+FieldNo+FieldNo])<>0 Then
        begin
          FField.FType:=ftMemo;
        end;

        If PosEx('As_RichText;', FOPL[ScrStrNum+FieldNo+FieldNo])<>0 Then
        begin
          FField.DataFieldType:=dftRichText;
          FField.FType:=ftFmtMemo;
        end;

        If PosEx('As_Float;', FOPL[ScrStrNum+FieldNo+FieldNo])<>0 Then
        begin
          FField.FType:=ftFloat;
        end;

        If DisplayMode in TDataFields Then
          Case FField.FType of
          ftDate, ftTime:
          FField.Width:=DateBoxWidth;
          ftDateTime:
          FField.Width:=DateTimeBoxWidth;
          ftFloat, ftCurrency, ftSmallint, ftInteger, ftWord, ftAutoInc, ftLargeint, ftBCD:
          FField.Width:=DigitEditWidth;
        Else
        FField.Width:=EditWidth;
          end;

        If FindParam('Width=', FField.OPL)<>'' Then
        begin
          FField.Width:=StrToIntEx(FindParam('Width=', FField.OPL));
          FField.IsFieldWidth:=True;
        end;

        If FindParam('Height=', FField.OPL)<>'' Then
        begin
          FField.Height:=StrToIntEx(FindParam('Height=', FField.OPL));
          FField.IsFieldHeight:=True;
        end;

        If FindParam('ReadOnly=', FField.OPL)<>'' Then
        begin
          FField.ReadOnly:=StrToIntEx(FindParam('ReadOnly=', FField.OPL))=1;
        end;

        If FindParam('NoDataField=', FField.OPL)='1' Then
        Begin
          FField.NoDataField:=True;
        End;

        Case DisplayMode of
        dctFields, dctFieldsStep:
        begin
          If PosEx('[FieldParagraphDown];', FOPL[ScrStrNum+FieldNo+FieldNo])<>0 Then
          begin
            Case FField.FType of
            ftGraphic:
            inc(FField.Top, GraficTopStep);
            ftMemo:
            inc(FField.Top, MemoHeight+FieldDownStep);
          Else
          inc(FField.Top, EditTopStep)
            end;
          end;

          AddLabel(FField, FField.Caption);

          If PosEx('ContextButton=', FieldCaptScrStr)<>0 Then
          begin
            AddContextButton(FField);
          end;

          // ----------------------------------------------------------------
          If PosEx('OutBox=', FieldCaptScrStr)<>0 Then
          begin
            AddFieldBox(FField, fbtOutBox, 'OutBox_');
          end;

          If PosEx('InputBox=', FieldCaptScrStr)<>0 Then
          begin
            AddFieldBox(FField, fbtInputBox, 'InputBox_');
          end;

          If PosEx('EditBox=', FieldCaptScrStr)<>0 Then
          begin
            AddFieldBox(FField, fbtEditBox, 'EditBox_');
          end;

          If PosEx('DateBox=', FieldCaptScrStr)<>0 Then
          begin
            AddDateBox(FField);
          end;

          If (not FField.NoDataField) and (PosEx('DBCheckBox=', FieldCaptScrStr)<>0) Then
          begin
            AddDBCheckBox(FField);
          end
          Else If PosEx('SimplyCheckBox=', FieldCaptScrStr)<>0 Then
          begin
            AddSimplyCheckBox(FField);
          end
          Else If PosEx('CheckBox=', FieldCaptScrStr)<>0 Then
          begin
            AddCheckBox(FField);
          end;

          If PosEx('LookUp=', FieldCaptScrStr)<>0 Then
          begin
            AddLookUp(FField);
          end;

          If PosEx('RollBar=', FieldCaptScrStr)<>0 Then
          begin
            AddRollBar(FField);
          end;

          If PosEx('ContextList=', FieldCaptScrStr)<>0 Then
          begin
            AddContextList(FField);
          end;

          If PosEx('DropListBox=', FieldCaptScrStr)<>0 Then
          begin
            AddDropBox(FField);
          end;

          If PosEx('LookupTable=', FieldCaptScrStr)<>0 Then
          begin
            AddLookupTable(FField);
          end;
        end;
        dctMainGrid:
        begin
          If Not FieldExists(FField.FieldName, Query) Then
            FField.Caption:=GetDCLMessageString(msNoField)+FField.FieldName;

          AddColumn(FField);
          If PosEx('DropListBox=', FField.OPL)<>0 Then
            AddDropBox(FField);
        end;
        end;
        AddField(FField);

        If DisplayMode in TDataFields Then
          If Not FField.CurrentEdit and FieldExists(FField.FieldName, Query) Then
          begin
            Case FField.FType of
            ftDate, ftTime, ftDateTime, ftFloat, ftCurrency, ftSmallint, ftInteger, ftWord,
              ftAutoInc, ftLargeint, ftBCD:
            begin
              AddEdit(FField);
            end;
            ftMemo, ftFmtMemo, ftBlob:
            begin
              If FField.DataFieldType=dftRichText Then
                AddMediaFieldGroup(FieldPanel, alNone, gtRichText, FField)
              Else
                AddMediaFieldGroup(FieldPanel, alNone, gtMemo, FField);
            end;
            ftGraphic, ftDBaseOle, ftParadoxOle, ftTypedBinary:
            begin
              AddMediaFieldGroup(FieldPanel, alNone, gtGrafic, FField);
            end;
            ftBoolean:
            begin
              AddDBCheckBox(FField);
            end
          Else
          AddEdit(FField);
            end;
          end;
      end;
    end;
  end;
end;

procedure TDCLGrid.DBEditClick(Sender: TObject);
var
  Edit: TDBEdit;
begin
  Edit:=Sender as TDBEdit;
  If Edit.PasswordChar=MaskPassChar Then
  begin
    If KeyState(VK_CONTROL) Then
      Edit.PasswordChar:=#0;
  end
  Else If Edit.Tag=1 Then
    If Edit.PasswordChar=#0 Then
    begin
      Edit.PasswordChar:=MaskPassChar;
    end;
end;

procedure TDCLGrid.DeleteList(Index: Word);
var
  ListCount: Integer;
begin
  If Index+1<Length(StructModify) Then
    For ListCount:=Index to Length(StructModify)-2-Index do
    begin
      StructModify[ListCount].ColumnsListCaption:=StructModify[ListCount+1].ColumnsListCaption;
      StructModify[ListCount].ColumnsListField:=StructModify[ListCount+1].ColumnsListField;
    end;
end;

procedure TDCLGrid.DeleteMenuBookMark(BookMarkNum: Integer);
begin
  KeyMarks.KeyBookMarks[BookMarkNum].KeyField:='';
  KeyMarks.KeyBookMarks[BookMarkNum].KeyValue:='';
  KeyMarks.KeyBookMarks[BookMarkNum].Title:='';

  RefreshBookMarkMenu;
end;

procedure TDCLGrid.DropListOnSelectItem(Sender: TObject);
var
  v1, v2: Integer;
begin
  v1:=(Sender as TComponent).Tag;
  v2:=(Sender as TCustomComboBox).ItemIndex;
  If FQuery.Active Then
  begin
    if FieldExists(DropBoxes[v1].FieldName, FQuery) then
    If (FQuery.FieldByName(DropBoxes[v1].FieldName).AsInteger<>v2) and FQuery.CanModify Then
    begin
      If Not (Query.State in dsEditModes) Then
        FQuery.Edit;

      If Query.State in dsEditModes Then
        FQuery.FieldByName(DropBoxes[v1].FieldName).AsInteger:=v2;
    end;
  end;

  If DropBoxes[v1].Variable<>'' Then
    FDCLLogOn.Variables.Variables[DropBoxes[v1].Variable]:=IntToStr(v2);
end;

procedure TDCLGrid.EditClick(Sender: TObject);
var
  Edit: TEdit;
begin
  Edit:=Sender as TEdit;
  If Edit.PasswordChar=Edits[Edit.Tag].EditsPasswordChar Then
  begin
    If KeyState(VK_CONTROL) Then
      Edit.PasswordChar:=#0;
  end
  Else If Edits[Edit.Tag].EditsPasswordChar<>#0 Then
    If Edit.PasswordChar=#0 Then
    begin
      Edit.PasswordChar:=Edits[Edit.Tag].EditsPasswordChar;
    end;
end;

procedure TDCLGrid.EditOnEdit(Sender: TObject);
var
  EdNamb: Word;
  l, k: Byte;
  ch, inFormat: Boolean;
  EdText: String;
begin
  EdNamb:=(Sender as TEdit).Tag;
  Edits[EdNamb].ModifyEdit:=1;
  EdText:=(Sender as TEdit).Text;

  {If Edits[EdNamb].EditsToFloat Then
  begin
    ch:=False;
    l:=Length(EdText);
    For k:=1 to l do
      If EdText[k]=FloatDelimiterFrom Then
      begin
        EdText[k]:=FloatDelimiterTo;
        ch:=True;
      end;
    If ch Then
      (Sender as TEdit).Text:=EdText;
  end;}

  inFormat:=True;
  case Edits[EdNamb].DCLField.FieldTypeFormat of
    fftDigit:begin
      if not IsDigits(EdText) then
      begin
        inFormat:=False;
        Edits[EdNamb].ModifyEdit:=0;
      end;
    end;
    fftTrim:Begin
      EdText:=Trim(EdText);
      (Sender as TEdit).Text:=EdText;
    End;
  end;

  if inFormat then
  // Update variables
    FDCLForm.LocalVariables.Variables[Edits[EdNamb].EditToVariables]:=EdText;
end;

procedure TDCLGrid.EditOnFloatData(Sender: TObject; var Key: Char);
var
  Text:String;
  EdNamb: Word;
begin
  Text:=(Sender as TEdit).Text;
  EdNamb:=(Sender as TEdit).Tag;

  case Edits[EdNamb].DCLField.FieldTypeFormat of
  fftFloat:
  begin
    If Key=FloatDelimiterFrom Then
      Key:=FloatDelimiterTo;
    If (Key='/') or (Key='?') or (Key='<') then
      Key:=FloatDelimiterTo;
    If (Key='б') or (Key='Б') or (Key='ю') or (Key='Ю') then
      Key:=FloatDelimiterTo;

    Case Key of
    // разрешаем ввод цифр
    '0'..'9':Key:=Key;
    // разрешаем ввод всего, что похоже на десятичный разделитель
    '.', ',':
    Begin
      // запрещаем ввод более 1 десятичного разделителя
      If Pos(FloatDelimiterTo, Text)=0 then
        Key:=FloatDelimiterTo
      Else key:=#0;
    End;
    '-':
    Begin
      // запрещаем ввод более 1 минуса
      If (Pos('-', Text)=0) then
        Key:='-'
      Else key:=#0;
    End;
    // разрешаем использование клавиш BackSpace и Delete
    #8:Key:=Key;
    // "гасим" все прочие клавиши
    Else key:=#0;
    End;
  end;
  fftDigit:begin
    Case Key of
    // разрешаем ввод цифр
    '0'..'9':Key:=Key;
    // разрешаем ввод всего, что похоже на десятичный разделитель
    '-':
    Begin
      // запрещаем ввод более 1 минуса
      If (Pos('-', Text)=0) then
        Key:='-'
      Else key:=#0;
    End;
    // разрешаем использование клавиш BackSpace и Delete
    #8:Key:=Key;
    // "гасим" все прочие клавиши
    Else key:=#0;
    End;
  end;
  end;
end;

procedure TDCLGrid.ExcludeNotAllowedOperation(Operation: TNotAllowedOperations);
var
  i, l: Byte;
begin
  l:=Length(NotAllowedOperations);
  For i:=1 to l do
  begin
    If NotAllowedOperations[i-1]=Operation Then
    begin
      l:=i-1;
      break;
    end;
  end;

  If (l>0)and(l<Length(NotAllowedOperations)) Then
  begin
    For i:=0 to l-1 do
      NotAllowedOperations[i]:=NotAllowedOperations[i+1];
    SetLength(NotAllowedOperations, l);
  end;
end;

procedure TDCLGrid.ExecEvents(EventsArray: TEventsArray);
var
  i: Word;
begin
  If Length(EventsArray)>0 Then
    For i:=0 to Length(EventsArray)-1 do
      FDCLForm.ExecCommand(EventsArray[i]);
end;

procedure TDCLGrid.ExecFilter(Sender: TObject);
var
  ExeplStr: String;
  FilterIdx: Integer;
begin
  FilterIdx:=(Sender as TDBLookupComboBox).Tag;
  If FilterIdx<> - 1 Then
  begin
    ExeplStr:=TrimRight((Sender as TDBLookupComboBox).KeyValue);
    DBFilters[FilterIdx].FilterString:=ExeplStr;

    FDCLLogOn.Variables.Variables[DBFilters[FilterIdx].VarName]:=TrimRight(ExeplStr);

    OpenQuery(QueryBuilder(0));
  end;
end;

procedure TDCLGrid.ExecComboFilter(Sender: TObject);
var
  ExeplStr: String;
  FilterIdx: Integer;
  cbx: TComboBox;
begin
  FilterIdx:=(Sender as TComboBox).Tag;
  If FilterIdx<> - 1 Then
  begin
    cbx:=Sender as TComboBox;

    if cbx.ItemIndex<>-1 then
    begin
      ExeplStr:=(cbx.Items.Objects[cbx.ItemIndex] as TComboFilterItem).Key;
      DBFilters[FilterIdx].FilterString:=ExeplStr;

      FDCLLogOn.Variables.Variables[DBFilters[FilterIdx].VarName]:=TrimRight(ExeplStr);

      OpenQuery(QueryBuilder(0));
    end;
  end;
end;

procedure TDCLGrid.FieldsManege(Sender: TObject);
var
  CIndex: Integer;
begin
  CIndex:=FieldsList.ItemIndex;
  If CIndex<> - 1 Then
  begin
    FGrid.Columns.Add.FieldName:=StructModify[CIndex].FieldsListField;
    FGrid.Columns[FGrid.Columns.Count-1].Title.Caption:=StructModify[CIndex].FieldsListCaption;
    ColumnsList.Items.Append(FGrid.Columns[FGrid.Columns.Count-1].Title.Caption+'\'+
        FGrid.Columns[FGrid.Columns.Count-1].FieldName);
    StructModify[CIndex].ColumnsListCaption:=StructModify[CIndex].FieldsListCaption;
    StructModify[CIndex].ColumnsListField:=FGrid.Columns[FGrid.Columns.Count-1].FieldName;
  end;
end;

procedure TDCLGrid.PFind(Sender: TObject);
var
  StrIndex: Byte;
  v1, FFactor: Word;
  FieldCaption, tmpSQL2: String;
begin
  If (Not (FDisplayMode in TDataGrid))or(Not Assigned(FGrid)) Then
    StrIndex:=1
  Else
    StrIndex:=0;

  If Not FindProcess Then
  begin
    FindProcess:=True;
    If Not Assigned(FindGrid) Then
    begin
      FindGrid:=TStringGrid.Create(FGridPanel);
      FindGrid.Parent:=FGridPanel;
      FindGrid.Top:=FGrid.Height-10;
      FindGrid.DefaultRowHeight:=17;
      FindGrid.Align:=alBottom;
      FindGrid.DefaultColWidth:=IndicatorWidth;
      FindGrid.FixedCols:=1;
      If FDisplayMode in [dctFields, dctFieldsStep] Then
      begin
        FindGrid.Height:=65;
        FindGrid.FixedRows:=1;
        FindGrid.RowCount:=2;
      end
      Else
      begin
        If Assigned(FGrid) Then
        begin
          FGrid.Align:=alTop;
          FGrid.Height:=FGrid.Height-46;
        end;

        FindGrid.Height:=45;
        FindGrid.FixedRows:=0;
        FindGrid.RowCount:=1;
      end;
    end
    Else
      FindGrid.Show;

    If Assigned(FGrid) Then
    begin
      FindGrid.ColCount:=FGrid.Columns.Count+1;
    end
    Else
    begin
      FindGrid.ColCount:=Length(DataFields);
    end;

    FindGrid.Options:=[goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect,
      goColSizing, goEditing, goTabs];
    FindGrid.Cells[0, StrIndex]:='?';

    FindFields:=TStringList.Create;
    If FDisplayMode in [dctFields, dctFieldsStep] Then
    begin
      For v1:=0 to Length(DataFields)-1 do
      begin
        FindGrid.ColWidths[v1+1]:=100;

        Case StrIndex of
        0:
        FieldCaption:=FGrid.Columns[v1].FieldName;
        1:
        FieldCaption:=UpperCase(DataFields[v1].Name);
        end;

        FindFields.Append(FieldCaption);

        Case StrIndex of
        0:
        FieldCaption:=InitCap(FGrid.Columns[v1].Title.Caption);
        1:
        FieldCaption:=InitCap(DataFields[v1].Caption);
        end;

        If StrIndex=1 Then
          FindGrid.Cells[v1+1, 0]:=FieldCaption;
      end;
    end
    Else
    begin
      For v1:=0 to FGrid.Columns.Count-1 do
      begin
        FindGrid.ColWidths[v1+1]:=FGrid.Columns[v1].Width;
        FindFields.Append(FGrid.Columns[v1].FieldName);
      end;
      FGrid.Align:=alClient;
    end;
  end
  Else
  begin
    FindGrid.Hide;
    FGrid.Align:=alClient;

    tmpSQL2:=QueryBuilder(0);

    FindProcess:=False;
    If Assigned(FindFields) Then
    begin
      FindFields.Clear;
      FreeAndNil(FindFields);
    end;

    FDCLForm.RePlaseVariables(tmpSQL2);
    FFactor:=0;
    TranslateProc(tmpSQL2, FFactor, Query);
    FQuery.SQL.Text:=tmpSQL2;
    try
      FQuery.Open;
    Except
      ShowErrorMessage(-1111, 'SQL='+tmpSQL2+CR+GetDCLMessageString(msBadFindParams));
    end;
  end;
end;

procedure TDCLGrid.PosToBookMark(Sender: TObject);
var
  v1: Word;
begin
  v1:=(Sender as TComponent).Tag;
  If KeyState(VK_CONTROL) Then
    DeleteMenuBookMark(v1)
  Else
    FQuery.Locate(KeyMarks.KeyBookMarks[v1].KeyField, KeyMarks.KeyBookMarks[v1].KeyValue,
      [loCaseInsensitive]);
end;

function TDCLGrid.FindRaightQuery(): String;
var
  v1: Integer;
begin
  Result:='';
  If Length(QuerysStore)>0 Then
    For v1:=Length(QuerysStore) downto 1 do
    begin
      If QuerysStore[v1-1].QuryType=qtMain Then
      begin
        Result:=QuerysStore[v1-1].QueryStr;
        break;
      end;
    end;
end;

destructor TDCLGrid.Destroy;
begin
  If Assigned(FLocalBookmark) Then
    try
      FQuery.FreeBookmark(FLocalBookmark);
    Except
      //
    end;

  try
    If Assigned(FQuery) Then
    begin
      If BaseChanged Then
        If FDCLForm.ExitNoSave=False Then
          If FQuery.Active Then
            If FQuery.State in dsEditModes Then
              If ShowErrorMessage(Ord(mbtConfirmation),
                GetDCLMessageString(msSaveEditingsQ))=1 Then
              begin
                try
                  FQuery.Post;
                Except
                  //
                end;
              end
              Else
              begin
                try
                  FQuery.Cancel;
                Except
                  //
                end;
              end;
    end;
    BaseChanged:=False;
    if Assigned(FGridPanel) then
      FreeAndNil(FGridPanel);
    if Assigned(FDCLLogOn) then
      if Assigned(FDCLLogOn.SQLMon) then
        if Assigned(FQueryGlob) then
          FDCLLogOn.SQLMon.DelTrace(FQueryGlob);
    If Assigned(FQueryGlob) then
      FreeAndNil(FQueryGlob);
  //  FromForm:='_Closed_'+FromForm;
    Except
      //
    end;
end;

procedure TDCLGrid.RefreshBookMarkMenu;
var
  v2, v3, i: Integer;
begin
  If Assigned(PopupGridMenu.FindComponent('PosToBookMark')) Then
  begin
    While (PopupGridMenu.FindComponent('PosToBookMark') as TMenuItem).ComponentCount<>0 do
      (PopupGridMenu.FindComponent('PosToBookMark') as TMenuItem).Components[0].Free;
  end;

  If Not PosBookCreated Then
  begin
    If Not Assigned(PopupGridMenu.FindComponent('PosToBookMark')) Then
      AddPopupMenuItem(GetDCLMessageString(msGotoBookmark)+'...',
        'PosToBookMark', nil, '', 0, '');
    PosBookCreated:=True;
  end;

  v3:=Length(KeyMarks.KeyBookMarks);
  If v3>0 Then
  begin
    For i:=1 to v3 do
    begin
      If KeyMarks.KeyBookMarks[i-1].KeyValue<>'' Then
      begin
        v2:=PopupGridMenu.Items.IndexOf(PopupGridMenu.FindComponent('PosToBookMark') as TMenuItem);

        If Not Assigned(PopupGridMenu.FindComponent('PosToBookMark'+IntToStr(i-1))) Then
          AddSubPopupItem(KeyMarks.KeyBookMarks[i-1].Title, 'PosBookMark'+IntToStr(i-1),
            PosToBookMark, v2, i-1);
      end;
    end;
  end;
end;

function TDCLGrid.GetColumns: TDBGridColumns;
begin
  If Assigned(FGrid) Then
    Result:=FGrid.Columns;
end;

function TDCLGrid.GetDisplayMode: TDataControlType;
begin
  Result:=FDisplayMode;
end;

function TDCLGrid.GetFieldCount: Integer;
begin
  If FQuery.Active Then
    Result:=FQuery.FieldCount
  Else
    Result:=0;
end;

function TDCLGrid.GetFieldDataType(FieldName: String): TFieldType;
var
  tmpFieldName: String;
begin
  tmpFieldName:=FieldName;
  If Pos('.', FieldName)<>0 Then
  begin
    tmpFieldName:=Copy(FieldName, Pos('.', FieldName)+1, Length(FieldName));
  end;
  Result:=Query.FieldByName(tmpFieldName).DataType;
end;

function TDCLGrid.GetFingQuery: String;
var
  StrIndex, FieldIndex: Integer;
  Enything: Boolean;

  procedure GetGridExemle(Const GridExemple, FindFieldName: String; var QueryString: String);
  var
    Sign, Exemple, Exemple1, Exemple2: String;
    OperationType: Byte;
  begin
    Exemple:=Trim(GridExemple);

    OperationType:=0;
    If PosEx('(', Exemple)=1 Then
      If PosEx(')', Exemple)=Length(Exemple) Then
        OperationType:=1;

    If PosEx('[', Exemple)=1 Then
      If PosEx(']', Exemple)<>0 Then
        OperationType:=2;

    If PosEx('!', Exemple)=1 Then
    begin
      Delete(Exemple, 1, 1);
      OperationType:=3;
    end;

    If PosEx('<=', Exemple)=1 Then
    begin
      Sign:=Copy(Exemple, 1, 2);
      Delete(Exemple, 1, 2);
      OperationType:=4;
    end
    Else If PosEx('<', Exemple)=1 Then
    begin
      Sign:=Copy(Exemple, 1, 1);
      Delete(Exemple, 1, 1);
      OperationType:=5;
    end;

    If Pos('>=', Exemple)=1 Then
    begin
      Sign:=Copy(Exemple, 1, 2);
      Delete(Exemple, 1, 2);
      OperationType:=6;
    end
    Else If Pos('>', Exemple)=1 Then
    begin
      Sign:=Copy(Exemple, 1, 1);
      Delete(Exemple, 1, 1);
      OperationType:=7;
    end;

    If OperationType in [4, 5, 6, 7] Then
    begin
      If GetSimplyFieldType(Query.FieldByName(FindFieldName).DataType)=sftDigit then
        QueryString:=QueryString+FindFieldName+Sign+Exemple
      Else
        QueryString:=QueryString+FindFieldName+Sign+GPT.StringTypeChar+Exemple+GPT.StringTypeChar;
    end;

    If OperationType=3 Then
    begin
      If GetSimplyFieldType(Query.FieldByName(FindFieldName).DataType)=sftDigit then
        QueryString:=QueryString+FindFieldName+' != '+Exemple
      Else
        QueryString:=QueryString+FindFieldName+' != '+GPT.StringTypeChar+Exemple+GPT.StringTypeChar;
    end;

    If OperationType=1 Then
    begin
      QueryString:=QueryString+FindFieldName+' in '+Exemple;
    end;

    If OperationType=2 Then
    begin
      Exemple1:=Copy(Exemple, 2, Pos(';', Exemple)-2);
      Exemple2:=Copy(Exemple, Pos(';', Exemple)+1, Pos(']', Exemple)-Pos(';', Exemple)-1);

      If GetSimplyFieldType(Query.FieldByName(FindFieldName).DataType)=sftDigit then
        QueryString:=QueryString+FindFieldName+' between '+Exemple1+' and '+Exemple2
      Else
        QueryString:=QueryString+FindFieldName+' between '+GPT.StringTypeChar+Exemple1+
          GPT.StringTypeChar+' and '+GPT.StringTypeChar+Exemple2+GPT.StringTypeChar;
    end;

    If OperationType=0 Then
    begin
      If GetSimplyFieldType(Query.FieldByName(FindFieldName).DataType)=sftDigit then
        QueryString:=QueryString+' '+FindFieldName+' = '+Exemple+' '
      Else
        QueryString:=QueryString+GPT.UpperString+FindFieldName+GPT.UpperStringEnd+' like '+
          GPT.UpperString+GPT.StringTypeChar+Exemple+GPT.StringTypeChar+GPT.UpperStringEnd;
    end;
  end;

begin
  Result:='';
  If Assigned(FindGrid) Then
  begin
    Enything:=False;
    If Not (DisplayMode in TDataGrid) Then
      StrIndex:=1
    Else
      StrIndex:=0;

    Result:=' ';
    If DisplayMode in TDataGrid Then
    begin
      For FieldIndex:=1 to FGrid.Columns.Count do
        If FindGrid.Cells[FieldIndex, StrIndex]<>'' Then
        begin
          Result:=Result+' ';
          If Enything Then
            Result:=Result+' and ';
          GetGridExemle(FindGrid.Cells[FieldIndex, StrIndex],
            FGrid.Columns[FieldIndex-1].FieldName, Result);
          Enything:=True;
        end;
      If Not Enything Then
      begin
        Result:='';
      end;
    end;

    If Not (DisplayMode in TDataGrid) Then
    begin
      For FieldIndex:=1 to FindFields.Count do
        If FindGrid.Cells[FieldIndex, StrIndex]<>'' Then
        begin
          Result:=Result+' ';
          If Enything Then
            Result:=Result+' and ';
          GetGridExemle(FindGrid.Cells[FieldIndex, StrIndex], FindFields[FieldIndex-1], Result);
          Enything:=True;
        end;
      If Not Enything Then
      begin
        Result:='';
      end;
    end;
  end;
end;

function TDCLGrid.GetMultiselect: Boolean;
begin
  If Assigned(FGrid) Then
    Result:=dgMultiSelect in FGrid.Options
  Else
    Result:=FMultiSelect;
end;

function TDCLGrid.GetQuery: TDCLQuery;
begin
  If not Assigned(FData) then
  Begin
    Result:=FQueryGlob;
  End
  Else
    If Assigned(FData.DataSet) then
      Result:=TDCLQuery(FData.DataSet) // FQuery;
    Else
      Result:=FQueryGlob;
end;

function TDCLGrid.GetReadOnly: Boolean;
begin
  If FDisplayMode in TDataGrid Then
  begin
    If Assigned(FGrid) Then
      Result:=not (dgEditing in FGrid.Options)
    Else
      Result:=FReadOnly;
  end;
  If FDisplayMode in TDataFields Then
  begin
    Result:=FReadOnly;
  end;
end;

function TDCLGrid.GetSQL: String;
begin
  Result:=FQuery.SQL.Text;
end;

function TDCLGrid.GetSQLFromStore(QueryType: TQueryType): String;
var
  i: Integer;
begin
  Result:='';
  If Length(QuerysStore)>0 Then
  begin
    For i:=Length(QuerysStore) downto 1 do
      If QuerysStore[i-1].QuryType=QueryType Then
      begin
        Result:=QuerysStore[i-1].QueryStr;
        break;
      end;
  end;
end;

function TDCLGrid.GetSummQuery: String;
var
  tmS, tmS1: String;
begin
  If Assigned(FQuery) Then
  begin
    tmS:=FQuery.SQL.Text;
    If tmS<>'' Then
    begin
      If PosEx(' order by ', tmS)<>0 Then
        Delete(tmS, PosEx(' order by ', tmS), Length(tmS));
      If PosEx(' group by ', tmS)<>0 Then
        Delete(tmS, PosEx(' group by ', tmS), Length(tmS));
      tmS1:=Copy(tmS, PosEx(' from ', tmS), Length(tmS));
      Result:='select '+SummString+' '+tmS1;
    end
    Else
      Result:='';
  end
  Else
    Result:='';
end;

function TDCLGrid.GetTablePart(Index: Integer): TDCLGrid;
begin
  Result:=nil;
  If Index<> - 1 Then
  begin
    If Length(FTableParts)>Index Then
      Result:=FTableParts[Index];
  end;
end;

function TDCLGrid.GetTablePartsCount: Integer;
begin
  Result:=Length(FTableParts);
end;

procedure TDCLGrid.GridDblClick(Sender: TObject);
begin
  ExecEvents(LineDblClickEvents);
end;

procedure TDCLGrid.GridDrawDataCell(Sender: TObject; Const Rect: TRect; DataCol: Integer;
  Column: TColumn; State: TGridDrawState);
var
  strTmp: String;
  ColorsCount: Byte;
  bmp: TBitmap;
begin
  With (Sender as TDCLDBGrid).Canvas do
  begin
    FillRect(Rect);
    If Column.Field is TGraphicField Then
    begin
      If GPT.ShowPicture Then
        try
          bmp:=TBitmap.Create;
          bmp.Assign(Column.Field);
          Draw(Rect.Left, Rect.Top, bmp);
        finally
          FreeAndNil(bmp);
        end;
    end
    Else
    begin
      RowColor:=clWhite;
      RowTextColor:=clBlack;

      For ColorsCount:=1 to Length(BrushColors) do
        If FieldExists(BrushColors[ColorsCount-1].Key, FQuery) Then
        begin
          strTmp:=BrushColors[ColorsCount-1].Value;
          If Pos('<>', strTmp)<>0 Then
          begin
            Delete(strTmp, PosEx('<>', strTmp), 2);
            strTmp:=Trim(strTmp);
            If LowerCase(strTmp)<>
              LowerCase(Trim(FQuery.FieldByName(BrushColors[ColorsCount-1].Key).AsString)) Then
            begin
              RowColor:=BrushColors[ColorsCount-1].Color;
              RowTextColor:=clWhite;
            end;
          end
          Else
          begin
            If Pos('>', strTmp)<>0 Then
            begin
              Delete(strTmp, PosEx('>', strTmp), 1);
              strTmp:=Trim(strTmp);
              If LowerCase(strTmp)<
                LowerCase(Trim(FQuery.FieldByName(BrushColors[ColorsCount-1].Key).AsString)) Then
              begin
                RowColor:=BrushColors[ColorsCount-1].Color;
                RowTextColor:=clWhite;
              end;
            end
            Else
            begin
              If Pos('<', strTmp)<>0 Then
              begin
                Delete(strTmp, PosEx('<', strTmp), 1);
                strTmp:=Trim(strTmp);
                If LowerCase(strTmp)>
                  LowerCase(Trim(FQuery.FieldByName(BrushColors[ColorsCount-1].Key).AsString)) Then
                begin
                  RowColor:=BrushColors[ColorsCount-1].Color;
                  RowTextColor:=clWhite;
                end;
              end
              Else
              begin
                If Pos('<=', strTmp)<>0 Then
                begin
                  Delete(strTmp, PosEx('<=', strTmp), 2);
                  strTmp:=Trim(strTmp);
                  If LowerCase(strTmp)<=
                    LowerCase(Trim(FQuery.FieldByName(BrushColors[ColorsCount-1].Key)
                        .AsString)) Then
                  begin
                    RowColor:=BrushColors[ColorsCount-1].Color;
                    RowTextColor:=clWhite;
                  end;
                end
                Else If Pos('>=', strTmp)<>0 Then
                begin
                  Delete(strTmp, PosEx('>=', strTmp), 2);
                  strTmp:=Trim(strTmp);
                  If LowerCase(strTmp)>=
                    LowerCase(Trim(FQuery.FieldByName(BrushColors[ColorsCount-1].Key)
                        .AsString)) Then
                  begin
                    RowColor:=BrushColors[ColorsCount-1].Color;
                    RowTextColor:=clWhite;
                  end;
                end
                Else
                begin
                  strTmp:=Trim(strTmp);
                  If LowerCase(strTmp)
                    =LowerCase(Trim(FQuery.FieldByName(BrushColors[ColorsCount-1].Key)
                        .AsString)) Then
                  begin
                    RowColor:=BrushColors[ColorsCount-1].Color;
                    RowTextColor:=clWhite;
                  end;
                end;
              end;
            end;
          end;
        end;
      TDCLDBGrid(Sender).Canvas.Brush.Color:=RowColor;
      TDCLDBGrid(Sender).Canvas.Font.Color:=RowTextColor;
      TDCLDBGrid(Sender).DefaultDrawColumnCell(Rect, DataCol, Column, State);
    end;
  end;
end;

procedure TDCLGrid.IncXYPos(StepTop, StepLeft: Word; var Field: RField);
begin
  Case FOrientation of
  oVertical:
  begin
    inc(Field.Top, StepTop);
    If MaxStepFields<StepLeft Then
      MaxStepFields:=StepLeft;
  end;
  oHorizontal:
  begin
    inc(Field.Left, StepLeft+FieldsStepLeft+Field.StepLeft);
    If MaxStepFields<Field.Height Then
      MaxStepFields:=Field.Height;
  end;
  end;

  If MaxAllFieldsHeight<Field.Top Then
  begin
    Field.Top:=BeginStepTop;
    inc(Field.Left, FieldsStepLeft+MaxStepFields);
  end;

  If MaxAllFieldsWidth<Field.Left Then
  begin
    Field.Left:=BeginStepLeft;
    inc(Field.Top, MaxStepFields+FieldDownStep);
  end;
end;

procedure TDCLGrid.LookupDBScroll(Data: TDataSet);
var
  v1: Integer;
  Look: TDBLookupComboBox;
begin
  v1:=Data.Tag;
  Look:=Lookups[v1].Lookup;
  If Assigned(Look) Then
  Begin
    if not Lookups[v1].NoDataField then
    begin
      FDCLLogOn.Variables.Variables[Lookups[v1].LookupToVars]:=
        TrimRight(Lookups[v1].LookupQuery.FieldByName(Look.KeyField).AsString);
    end;
  End;
end;

procedure TDCLGrid.LookupOnClick(Sender: TObject);
var
  KeyFiled, ListField, tmpSQL1: String;
  v4: Integer;
begin
  v4:=(Sender as TDBLookupComboBox).Tag;

  If Lookups[v4].ModifyEdits<>'' Then
  begin
    ListField:=(Sender as TDBLookupComboBox).ListField;

    tmpSQL1:=TrimRight(Lookups[v4].LookupQuery.FieldByName(ListField).AsString);
    (FieldPanel.FindComponent(Lookups[v4].ModifyEdits) as TEdit).Text:=tmpSQL1;
  end;

  if Lookups[v4].LookupToVars<>'' then
  begin
    KeyFiled:=(Sender as TDBLookupComboBox).KeyField;

    FDCLLogOn.Variables.Variables[Lookups[v4].LookupToVars]:=
      TrimRight(Lookups[v4].LookupQuery.FieldByName(KeyFiled).AsString);
  end;
end;

procedure TDCLGrid.OnChangeDateBox(Sender: TObject);
var
  DateBoxNamb: Byte;
  EdDate: String;
begin
  DateBoxNamb:=(Sender as DateTimePicker).Tag;
  DateBoxes[DateBoxNamb].ModifyDateBox:=1;
  // Update variables
  EdDate:=DateToStr((Sender as DateTimePicker).Date);
  FDCLLogOn.Variables.Variables[DateBoxes[DateBoxNamb].DateBoxToVariables]:=EdDate;

  If DateBoxes[DateBoxNamb].DateBoxType=0 Then
  begin
    if not DateBoxes[DateBoxNamb].NoDataField then
    Begin
      If Query.Active Then
      begin
        If FieldExists(DateBoxes[DateBoxNamb].DateBoxToFields, Query) Then
        begin
          if Query.CanModify then
          begin
            Query.Edit;
            Query.FieldByName(DateBoxes[DateBoxNamb].DateBoxToFields).AsString:=
              DateToStr(DateBoxes[DateBoxNamb].DateBox.Date);
          end;
        end;
      end;
    End;
  end;
end;

procedure TDCLGrid.OnContextFilter(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  FilterIdx: Integer;
  ExeplStr: String;
begin
  FilterIdx:=(Sender as TEdit).Tag;
  ExeplStr:=(Sender as TEdit).Text;

  If FQuery.Active then
  if FieldExists(DBFilters[FilterIdx].Field, FQuery) or (DBFilters[FilterIdx].VarName<>'') then
  Begin
    If DBFilters[FilterIdx].Field<>'' then
    Begin
      If not CheckStrFmtType(ExeplStr, GetSimplyFieldType(DBFilters[FilterIdx].Field, FQuery)) then
      Begin
        ExeplStr:='';
      End;
    End
    Else
    Begin
        FDCLLogOn.Variables.Variables[DBFilters[FilterIdx].VarName]:=TrimRight(ExeplStr);
    End;
  End;

  DBFilters[FilterIdx].FilterString:=ExeplStr;

  If DBFilters[FilterIdx].WaitForKey<>0 Then
  begin
    If Key=DBFilters[FilterIdx].WaitForKey Then
      OpenQuery(QueryBuilder(0));
  end
  Else
  begin
    OpenQuery(QueryBuilder(0));
  end;
end;

procedure TDCLGrid.OnDelete(Data: TDataSet);
begin
  ExecEvents(EventsDelete);

  SetDataStatus(dssChanged);
end;

procedure TDCLGrid.OnNotCheckClick(Sender: TObject);
var
  i:Integer;
begin
  i:=(Sender as TComponent).Tag;
  DBFilters[i].NotFilter:=(Sender as TCheckBox).Checked;

  OpenQuery(QueryBuilder(0));
end;

procedure TDCLGrid.Open;
begin
  If Length(FQuery.SQL.Text)>11 Then
  Try
    FQuery.Open;
  Except
    ShowErrorMessage( - 1100, 'SQL='+FQuery.SQL.Text);
    Exit;
  End;
end;

procedure TDCLGrid.OpenQuery(QText: String);
var
  FFactor: Word;
begin
  FQuery.SQL.Clear;
  FDCLForm.RePlaseVariables(QText);
  FFactor:=0;
  TranslateProc(QText, FFactor, nil);
  FQuery.SQL.Append(QText);

  try
    FQuery.Open;
  Except
    ShowErrorMessage( - 1100, 'SQL='+QText);
  end;
end;

procedure TDCLGrid.PClearAllFind(Sender: TObject);
var
  StrIndex, i:Integer;
begin
  If (Not (FDisplayMode in TDataGrid))or(Not Assigned(FGrid)) Then
    StrIndex:=1
  Else
    StrIndex:=0;

  If not FindProcess then
    PFind(Sender);
  If Assigned(FindGrid) then
    For i:=2 to FindGrid.ColCount do
      FindGrid.Cells[i-1, StrIndex]:='';
end;

procedure TDCLGrid.PCopy(Sender: TObject);
begin
  if Assigned(FGrid) then
    Clipboard.AsText:=FGrid.SelectedField.AsString;
end;

procedure TDCLGrid.PCut(Sender: TObject);
begin
  if Assigned(FGrid) then
  begin
    Clipboard.AsText:=FGrid.SelectedField.AsString;
    FGrid.SelectedField.Clear;
  end;
end;

procedure TDCLGrid.PPaste(Sender: TObject);
begin
  if Assigned(FGrid) then
    FGrid.SelectedField.AsString:=Clipboard.AsText;
end;

procedure TDCLGrid.Print(Sender: TObject);
var
  PrintBase: TPrintBase;
begin
  PrintBase:=TPrintBase.Create;
  PrintBase.Print(FGrid, FQuery, FDCLForm.FForm.Caption);
end;

procedure TDCLGrid.PSetFind(Sender: TObject);
var
  StrIndex, i:Integer;
  S:String;
begin
  If (Not (FDisplayMode in TDataGrid))or(Not Assigned(FGrid)) Then
    StrIndex:=1
  Else
    StrIndex:=0;

  If not FindProcess then
    PFind(Sender);
  If Assigned(FindGrid) then
  If Assigned(FGrid) then
  Begin
    S:=FGrid.SelectedField.AsString;
    i:=FGrid.SelectedIndex;
    FindGrid.Cells[i+1, StrIndex]:=S;
  End;
end;

procedure TDCLGrid.PUndo(Sender: TObject);
begin
  if Assigned(FGrid) then
  if FGrid.DataSource<>nil then
    if FGrid.DataSource.DataSet<>nil then
      FGrid.DataSource.DataSet.Cancel;
{$IFDEF MSWINDOWS}
  SendMessage(GetFocus, WM_UNDO, 0, 0);
{$ENDIF}
end;

function TDCLGrid.QueryBuilder(QueryMode: Byte): String;
var
  QFilterField, WhereStr, ExeplStr, Exempl2, OrderBy, GroupBy, tmpSQL, tmpSQL1,
    Query1String: String;
  FN, FFactor: Word;

  function ConstructQueryString(ExemplStr, FilterField: String; Upper, NotLike, Partial, NotWhere: Boolean;
    Between: Byte; Exempl2: String): String;
  var
    Delimiter, Prefix, Postfix, UpperPrefix, UpperPostfix, WhereStr, CondStr: String;
    procedure BetweenFormat;
    begin
      If (Between<>0)and(Exempl2<>'') Then
      begin
        Prefix:=' between ';
        CondStr:=UpperPrefix+Delimiter+TrimRight(ExemplStr)+Delimiter+UpperPostfix+' and '+
          UpperPrefix+Delimiter+Exempl2+Delimiter+UpperPostfix;
      end;
    end;

  begin
    Delimiter:=GetDelimiter(FilterField, Query);
    Prefix:='=';
    Postfix:='';
    UpperPrefix:='';
    UpperPostfix:='';
    CondStr:='';

    If NotWhere then
    begin
      Prefix:='!=';
    end;

    If Upper Then
    begin
      Case GetFieldDataType(FilterField) of
      ftString, ftFixedChar, ftWideString:
      begin
        UpperPrefix:=GPT.UpperString;
        UpperPostfix:=GPT.UpperStringEnd;

        BetweenFormat;
      end;
      end;
    end;

    If Not NotLike Then
    begin
      Case GetFieldDataType(FilterField) of
      ftString, ftFixedChar, ftWideString:
      begin
        Prefix:=' like ';
        If NotWhere then
        begin
          Prefix:=' not like ';
        end;
        Postfix:='%';
        if Partial then
        Begin
          ExemplStr:='%'+ExemplStr;
        End;
      end;
      end;
    end;
    BetweenFormat;

    If CondStr='' Then
      CondStr:=UpperPrefix+Delimiter+ExemplStr+Postfix+Delimiter+UpperPostfix;

    WhereStr:=' '+UpperPrefix+FilterField+UpperPostfix+Prefix+CondStr;
    Result:=WhereStr;
  end;

begin
  tmpSQL:=GetSQLFromStore(qtFind);
  If tmpSQL='' Then
    tmpSQL:=GetSQLFromStore(qtMain);

  Case QueryMode of
  0:
  begin
    OrderBy:='';
    If FindSQLWhere(tmpSQL, 'order by')<>0 then
    begin
      OrderBy:=Copy(tmpSQL, FindSQLWhere(tmpSQL, 'order by'), Length(tmpSQL));
      Delete(tmpSQL, FindSQLWhere(tmpSQL, 'order by'), Length(tmpSQL));
    end;
    GroupBy:='';
    If FindSQLWhere(tmpSQL, 'group by')<>0 Then
    begin
      GroupBy:=Copy(tmpSQL, FindSQLWhere(tmpSQL, 'group by'), Length(tmpSQL));
      Delete(tmpSQL, FindSQLWhere(tmpSQL, 'group by'), Length(tmpSQL));
    end;
  end;
  1:
  begin
    If FindSQLWhere(tmpSQL, 'group by')<>0 Then
      Delete(tmpSQL, FindSQLWhere(tmpSQL, 'group by'), Length(tmpSQL));

    If FindSQLWhere(tmpSQL, 'group by')<>0 Then
      Delete(tmpSQL, FindSQLWhere(tmpSQL, 'group by'), Length(tmpSQL));

    GroupBy:='';
    OrderBy:='';
  end;
  2:
  begin
    GroupBy:='';
    OrderBy:='';
  end;
  end;

  Query1String:='';
  WhereStr:='';
  If FindSQLWhere(tmpSQL, 'where')<>0 then
    WhereStr:=' ';

  If Length(DBFilters)>0 Then
    For FN:=0 to Length(DBFilters)-1 do
    begin
      If DBFilters[FN].FilterString<>'' Then
      begin
        ExeplStr:=DBFilters[FN].FilterString;
        QFilterField:=DBFilters[FN].Field;

        If ExeplStr='-1' Then
        begin
          FDCLForm.RePlaseVariables(tmpSQL);
          DBFilters[FN].FilterChengFlag:= - 1;
        end
        Else
        begin
          FDCLForm.RePlaseVariables(WhereStr);
          DBFilters[FN].FilterChengFlag:=1;

          If ExeplStr<>'-1' Then
          begin
            If DBFilters[FN].Between<>StopFilterFlg Then
            begin
              Exempl2:='';
              if QFilterField<>'' then
              begin
                If WhereStr>' ' Then
                  WhereStr:=WhereStr+' and ';
                If DBFilters[FN].Between<>0 Then
                  Exempl2:=DBFilters[DBFilters[FN].Between].FilterString;

                WhereStr:=WhereStr+' '+ConstructQueryString(ExeplStr, QFilterField,
                  Not DBFilters[FN].CaseC, DBFilters[FN].NotLike, DBFilters[FN].Partial, DBFilters[FN].NotFilter,
                  DBFilters[FN].Between, Exempl2);
              end;
            end;
          end
          Else
          begin
            DBFilters[FN].FilterChengFlag:= - 1;
          end;
        end;
      end;
    end;

  If Length(WhereStr)>3 Then
    If FindSQLWhere(tmpSQL, 'where')<>0 Then
      WhereStr:=' and '+WhereStr
    Else
      WhereStr:=' where '+WhereStr;

  Query1String:=GetFingQuery;
  If Query1String<>'' Then
    If (WhereStr>' ')or(FindSQLWhere(tmpSQL, 'where')<>0) Then
      WhereStr:=WhereStr+' and '+Query1String
    Else
      WhereStr:=' where '+Query1String;

  Case QueryMode of
  0:
  begin
    tmpSQL1:=tmpSQL+' '+WhereStr+' '+GroupBy+' '+OrderBy;
  end;
  1:
  begin
    tmpSQL1:=tmpSQL+' '+WhereStr+' ';
  end;
  end;
  FDCLForm.RePlaseVariables(tmpSQL1);
  FFactor:=0;
  TranslateProc(tmpSQL1, FFactor, nil);
  Result:=tmpSQL1;
end;

procedure TDCLGrid.ReFreshQuery;
var
  tpc: Byte;
begin
  If FQuery.Active Then
  Begin
    FLocalBookmark:=FQuery.GetBookmark;
    try
      If FQuery.State in dsEditModes Then
        FQuery.Post;

      FQuery.SaveDB;
      For tpc:=1 to Length(FTableParts) do
      begin
        FTableParts[tpc-1].Close;
      end;
      Close;
    Except
      //
    end;
  End;

  Open;

  If Assigned(FLocalBookmark) Then
    try
      If FQuery.Active then
      If FQuery.RecordCount<>0 then
        FQuery.GoToBookmark(FLocalBookmark);
    finally
      FQuery.FreeBookmark(FLocalBookmark);
    end;

  For tpc:=1 to Length(FTableParts) do
  begin
    FTableParts[tpc-1].Open;
  end;
end;

procedure TDCLGrid.RePlaseParams(var Params: String);
begin
  If Assigned(FQuery) Then
    RePlaseParams_(Params, FQuery);
end;

procedure TDCLGrid.RollBarOnChange(Sender: TObject);
var
  v1: Integer;
begin
  v1:=(Sender as TComponent).Tag;
  If Query.Active and FieldExists(RollBars[v1].Field, Query) Then
  begin
    if Query.CanModify then
    begin
      If Query.FieldByName(RollBars[v1].Field).AsString<>IntToStr((Sender as TTrackBar).Position) Then
      begin
        If Not (Query.State in dsEditModes) Then
          Query.Edit;

        Query.FieldByName(RollBars[v1].Field).AsString:=IntToStr((Sender as TTrackBar).Position);
      end;
    end;
  end;

  If RollBars[v1].Variable<>'' Then
    FDCLLogOn.Variables.Variables[RollBars[v1].Variable]:=IntToStr((Sender as TTrackBar).Position);
end;

procedure TDCLGrid.SaveDB;
begin
  SetDataStatus(dssSaved);
end;

procedure TDCLGrid.ScrollDB(Data: TDataSet);
var
  v1, v2: Word;
  TmpStr: String;
begin
  If (FromForm='')or(Pos('_Closed_', FromForm)=1) Then
  begin
    FDCLForm:=nil;
    Exit;
  end;
  If Not Assigned(FDCLForm) Then
    Exit;
  If Not Assigned(FQuery) Then //FQueryGlob
    Exit;
  If Not FQuery.Active Then
    Exit;
  For v1:=1 to Length(EventsScroll) do
  begin
    FDCLForm.ExecCommand(EventsScroll[v1-1]);
  end;

  FDCLForm.SetRecNo;

  If Length(Edits)>0 Then
    For v1:=1 to Length(Edits) do
    begin
      If (Edits[v1-1].EditsType in [fbtOutBox, fbtEditBox]) and not Edits[v1-1].DCLField.NoDataField Then
      begin
        If FieldExists(Edits[v1-1].EditsToFields, FQuery) Then
          Edits[v1-1].Edit.Text:=TrimRight(FQuery.FieldByName(Edits[v1-1].EditsToFields).AsString);
      end;
    end;

  If Length(DropBoxes)>0 Then
    For v1:=1 to Length(DropBoxes) do
    begin
      If FieldExists(DropBoxes[v1-1].FieldName, FQuery) Then
        If GetStringDataType(FQuery.FieldByName(DropBoxes[v1-1].FieldName).AsString)=idDigit then
          DropBoxes[v1-1].DropList.ItemIndex:=FQuery.FieldByName(DropBoxes[v1-1].FieldName).AsInteger
        Else
          DropBoxes[v1-1].DropList.ItemIndex:=DropBoxes[v1-1].DropList.Items.IndexOf(FQuery.FieldByName(DropBoxes[v1-1].FieldName).AsString);
    end;

  If Length(CheckBoxes)>0 Then
    For v1:=1 to Length(CheckBoxes) do
    begin
      If (not CheckBoxes[v1-1].NoDataField) and FieldExists(CheckBoxes[v1-1].CheckBoxToFields, FQuery) Then
      begin
        TmpStr:=TrimRight(FQuery.FieldByName(CheckBoxes[v1-1].CheckBoxToFields).AsString);
        If (TmpStr='0')or(TmpStr='') Then
          CheckBoxes[v1-1].CheckBox.Checked:=False;
        If TmpStr='1' Then
          CheckBoxes[v1-1].CheckBox.Checked:=True;
      end;
    end;

  If Length(DateBoxes)>0 Then
    For v1:=1 to Length(DateBoxes) do
    begin
      If (not DateBoxes[v1-1].NoDataField) and FieldExists(DateBoxes[v1-1].DateBoxToFields, FQuery) Then
        DateBoxes[v1-1].DateBox.Date:=FQuery.FieldByName(DateBoxes[v1-1].DateBoxToFields)
          .AsDateTime;
    end;

  If Length(RollBars)>0 Then
    For v1:=1 to Length(RollBars) do
    begin
      If RollBars[v1-1].Field<>'' Then
      begin
        If FieldExists(RollBars[v1-1].Field, FQuery) Then
          RollBars[v1-1].RollBar.Position:=FQuery.FieldByName(RollBars[v1-1].Field).AsInteger;
      end;
    end;

  If Length(ContextLists)>0 Then
    For v1:=1 to Length(ContextLists) do
    begin
      If FieldExists(ContextLists[v1-1].ListField, FQuery) Then
        ContextLists[v1-1].ContextList.Text:=
          FQuery.FieldByName(ContextLists[v1-1].ListField).AsString
      Else
      begin
        If FieldExists(ContextLists[v1-1].DataField, FQuery) Then
        begin
          ContextLists[v1-1].ContextList.Text:=GetFieldValue(ContextLists[v1-1].Table,
            ContextLists[v1-1].Field, ' where '+ContextLists[v1-1].KeyField+'='+
              IntToStr(FQuery.FieldByName(ContextLists[v1-1].DataField).AsInteger));
        end;
      end;
    end;

  For v1:=1 to FDCLLogOn.FormsCount do
  begin
    If Assigned(FDCLLogOn.Forms[v1-1]) Then
      If Assigned(FDCLLogOn.Forms[v1-1].ParentForm) Then
      begin
        If FDCLLogOn.Forms[v1-1].ParentForm=FDCLForm Then
          For v2:=1 to FDCLLogOn.Forms[v1-1].TablesCount do
            If FDCLLogOn.Forms[v1-1].Tables[v2-1]<>Self Then
              FDCLLogOn.Forms[v1-1].Tables[v2-1].ScrollDB(FQuery);
      end;
  end;
end;

procedure TDCLGrid.SetBookMark(Sender: TObject);
var
  l: Integer;
begin
  If (KeyMarks.KeyField<>'')and(FieldExists(KeyMarks.KeyField, FQuery)) Then
  begin
    l:=Length(KeyMarks.KeyBookMarks);
    SetLength(KeyMarks.KeyBookMarks, l+1);
    KeyMarks.KeyBookMarks[l].KeyField:=KeyMarks.KeyField;
    KeyMarks.KeyBookMarks[l].KeyValue:=FQuery.FieldByName(KeyMarks.KeyField).AsString;
    KeyMarks.KeyBookMarks[l].Title:=FQuery.FieldByName(KeyMarks.TitleField).AsString;

    RefreshBookMarkMenu;
  end;
end;

procedure TDCLGrid.SetColumns(Cols: TDBGridColumns);
begin
  If Assigned(FGrid) Then
    FGrid.Columns:=Cols;
end;

procedure TDCLGrid.SetDataStatus(Status: TDataStatus);
begin
  Case Status of
  dssChanged:
  begin
    If Assigned(FDCLForm.ParentForm) Then
    begin
      FDCLForm.ParentForm.SetDBStatus(GetDCLMessageString(msModified));
      BaseChanged:=True;
    end;

    FDCLForm.SetDBStatus(GetDCLMessageString(msModified));
    BaseChanged:=True;
  end;
  dssSaved:
  begin
    If Assigned(FDCLForm.ParentForm) Then
    begin
      FDCLForm.ParentForm.SetDBStatus('');
      BaseChanged:=False;
    end;

    FDCLForm.SetDBStatus('');
    BaseChanged:=False;
  end;
  end;
end;

procedure TDCLGrid.SetDisplayMode(DisplayMode: TDataControlType);
begin
  If Not FShowed Then
    FDisplayMode:=DisplayMode;
end;

procedure TDCLGrid.SetGridOptions(Options: TDBGridOptions);
begin
  FGrid.Options:=Options;
end;

procedure TDCLGrid.SetMultiselect(Value: Boolean);
begin
  If FDisplayMode in TDataGrid Then
  begin
    FMultiSelect:=Value;
    If Assigned(FGrid) Then
    begin
      If Value Then
        FGrid.Options:=FGrid.Options+[dgMultiSelect]
      Else
        FGrid.Options:=FGrid.Options-[dgMultiSelect]
    end;
  end;
end;

procedure TDCLGrid.SetNewQuery(Data: TDataSource);
begin
  FQueryGlob:=TDCLQuery.Create(FDCLLogOn.FDBLogOn);
  Case FDisplayMode of
  dctTablePart:FQueryGlob.Name:='DCLQuery_TP_'+FDCLForm.DialogName+'_'+IntToStr(UpTime);
  dctLookupGrid:FQueryGlob.Name:='DCLQuery_LG_'+FDCLForm.DialogName+'_'+IntToStr(UpTime);
  Else
    FQueryGlob.Name:='DCLQuery_'+FDCLForm.DialogName+'_'+IntToStr(UpTime);
  End;

  FQueryGlob.AfterInsert:=AfterInsert;
  FQueryGlob.AfterScroll:=ScrollDB;
  FQueryGlob.AfterClose:=AfterClose;
  FQueryGlob.AfterOpen:=AfterOpen;
  FQueryGlob.AfterEdit:=AfterEdit;
  FQueryGlob.AfterPost:=AfterPost;
  FQueryGlob.AfterCancel:=AfterCancel;
  FQueryGlob.AfterDelete:=OnDelete;
  FQueryGlob.AfterRefresh:=AfterRefresh;

  FQueryGlob.BeforeOpen:=BeforeOpen;
  FQueryGlob.BeforePost:=BeforePost;

  If Assigned(Data) Then
    FQueryGlob.DataSource:=Data;

  FData.DataSet:=FQueryGlob;
end;

procedure TDCLGrid.SetQuery(Query: TDCLQuery);
begin
  If Assigned(Query) Then
    FData.DataSet:=Query;
end;

procedure TDCLGrid.SetReadOnly(Value: Boolean);
begin
  FReadOnly:=Value;

  If Value Then
  begin
    If Assigned(Navig) Then
    begin
      if nbInsert in Navig.VisibleButtons then
        Navig.VisibleButtons:=Navig.VisibleButtons-[nbInsert];
      if nbDelete in Navig.VisibleButtons then
        Navig.VisibleButtons:=Navig.VisibleButtons-[nbDelete];
      if nbPost in Navig.VisibleButtons then
        Navig.VisibleButtons:=Navig.VisibleButtons-[nbPost];
      if nbCancel in Navig.VisibleButtons then
        Navig.VisibleButtons:=Navig.VisibleButtons-[nbCancel];
      if nbEdit in Navig.VisibleButtons then
        Navig.VisibleButtons:=Navig.VisibleButtons-[nbEdit];
    end;
    If Assigned(FGrid) Then
      If dgEditing in FGrid.Options then
        FGrid.Options:=FGrid.Options-[dgEditing];

    {AddNotAllowedOperation(dsoDelete);
    AddNotAllowedOperation(dsoInsert);
    AddNotAllowedOperation(dsoEdit);}
  end
  Else
  begin
    If Assigned(FGrid) Then
      If not (dgEditing in FGrid.Options) then
        FGrid.Options:=FGrid.Options+[dgEditing];
  end
end;

procedure TDCLGrid.SetSQL(SQL: String);
begin
  FQuery.SQL.Text:=SQL;
end;

procedure TDCLGrid.SetSQLDBFilter(SQL: String);
var
  l: Integer;
begin
  l:=Length(DBFilters);
  If l>0 Then
    DBFilters[l-1].FilterQuery.SQL.Text:=SQL;
end;

procedure TDCLGrid.SetSQLToStore(SQL: String; QueryType: TQueryType; Raight: TUserLevelsType);
var
  l: Word;
begin
  l:=Length(QuerysStore);
  SetLength(QuerysStore, l+1);
  QuerysStore[l].QueryStr:=SQL;
  QuerysStore[l].QuryType:=QueryType;
  QuerysStore[l].QueryRaights:=Raight;
end;

procedure TDCLGrid.SetTablePart(Index: Integer; Value: TDCLGrid);
begin
  If (Index>=0) and (Length(FTableParts)>Index) Then
    FTableParts[Index]:=Value;
end;

procedure TDCLGrid.Show;
var
  i1, ToolButtWidth, ActiveToolButtonsCount: Integer;
  TollButton: TDialogSpeedButton;

  procedure SetPopupMenuItems(WithStructure: Boolean);
  begin
    AddPopupMenuItem(GetDCLMessageString(msFind), 'Find', PFind, 'Ctrl+F',
      0, 'Find');
    If WithStructure Then
      AddPopupMenuItem(GetDCLMessageString(msFindCurrCell), 'FindCurrentCell', PSetFind, 'Alt+F',
        0, 'FindCurrCell');
    AddPopupMenuItem(GetDCLMessageString(msClearAllFind), 'ClearAllFind', PClearAllFind, 'Alt+C',
      0, 'ClearAllFind');
    AddPopupMenuItem('-', 'Separator4', nil, '', 0, '');
    AddPopupMenuItem(GetDCLMessageString(msPrint), 'Print', Print, 'Ctrl+P',
      0, 'Print');
    If WithStructure Then
      AddPopupMenuItem(GetDCLMessageString(msStructure), 'Structure', Structure,
        'Ctrl+S', 0, 'Structure');

    if Assigned(FGrid) then
    begin
      AddPopupMenuItem('-', 'Separator1', nil, '', 0, '');
      AddPopupMenuItem(GetDCLMessageString(msCopy), 'Copy', PCopy, 'Ctrl+C',
        0, 'Copy');
      if not FReadOnly then
      begin
        AddPopupMenuItem(GetDCLMessageString(msCut), 'Cut', PCut, 'Ctrl+X',
          0, 'Cut');
        AddPopupMenuItem(GetDCLMessageString(msPast), 'Paste', PPaste, 'Ctrl+V',
          0, 'Paste');
        AddPopupMenuItem('-', 'Separator2', nil, '', 0, '');
        AddPopupMenuItem(GetDCLMessageString(msCancel), 'Undo', PUndo, 'Ctrl+U',
          0, 'Undo');
      end;
    end;

    If (KeyMarks.KeyField<>'')and FieldExists(KeyMarks.KeyField, FQuery) Then
    begin
      AddPopupMenuItem('-', 'Separator3', nil, '', 0, '');
      AddPopupMenuItem(InitCap(GetDCLMessageString(msBookmark)), 'GetBookMark',
        SetBookMark, 'Ctrl+B', 0, 'BookMark');
    end;
  end;

begin
  If FUserLevelLocal<ulWrite Then
  begin
    AddNotAllowedOperation(dsoInsert);
    AddNotAllowedOperation(dsoDelete);
    AddNotAllowedOperation(dsoEdit);
  end;

  {If Assigned(FQuery) Then
    FQuery.NotAllowOperations:=NotAllowedOperations;}

  If Assigned(Navig) Then
  begin
    If FindNotAllowedOperation(dsoDelete) Then
      Navig.VisibleButtons:=Navig.VisibleButtons-[nbDelete];
    If FindNotAllowedOperation(dsoInsert) Then
    begin
      Navig.VisibleButtons:=Navig.VisibleButtons-[nbInsert];
      Navig.VisibleButtons:=Navig.VisibleButtons-[nbPost];
      Navig.VisibleButtons:=Navig.VisibleButtons-[nbCancel];
    end;
    If FindNotAllowedOperation(dsoEdit) Then
    begin
      Navig.VisibleButtons:=Navig.VisibleButtons-[nbEdit];
      Navig.VisibleButtons:=Navig.VisibleButtons-[nbPost];
      Navig.VisibleButtons:=Navig.VisibleButtons-[nbCancel];
    end;
  end;

  If Not FShowed Then
  begin
    If FDisplayMode in TDataGrid Then
    begin
      FGrid:=TDCLDBGrid.Create(FGridPanel);
      FGrid.Parent:=FGridPanel;
      FGrid.DataSource:=FData;
      Case FDisplayMode of
      dctMainGrid, dctTablePart, dctLookupGrid:
        FGrid.Align:=alClient;
      dctSideGrid:
        FGrid.Align:=alRight;
      end;
      FGrid.OnDblClick:=GridDblClick;
      FGrid.OnTitleClick:=SortDB;
{$IFDEF FPC}
      FGrid.AlternateColor:=GridAlternateColor;
{$ENDIF}
      If Not GPT.DisableColors Then
      begin
        FGrid.DefaultDrawing:=True;
        FGrid.OnDrawColumnCell:=GridDrawDataCell;
      end;

      PopupGridMenu:=TPopupMenu.Create(FGrid);

      SetPopupMenuItems(True);

      FGrid.PopupMenu:=PopupGridMenu;

      if FDisplayMode=dctLookupGrid then
      begin
        If Assigned(Navig) Then
        begin
          Navig.VisibleButtons:=Navig.VisibleButtons-[nbPrior];
          Navig.VisibleButtons:=Navig.VisibleButtons-[nbNext];
        end;
      end;
    end;

    If FDisplayMode in TDataFields Then
    begin
      FieldPanel:=TDialogPanel.Create(FGridPanel);
      FieldPanel.Parent:=FGridPanel;
      FieldPanel.Align:=alClient;

      PopupGridMenu:=TPopupMenu.Create(FieldPanel);

      SetPopupMenuItems(False);

      FieldPanel.PopupMenu:=PopupGridMenu;
    end;

    if Assigned(ToolButtonPanel) then
    begin
      ToolButtWidth:=0;
      ToolButtonsCount:=0;
      ActiveToolButtonsCount:=0;
      For i1:=1 to ToolCommandsCount do
      begin
        If ((FDisplayMode in TDataGrid)and(i1=1))or(FQuery.Active and(i1 in [2, 3])) Then
          Inc(ActiveToolButtonsCount);
      end;

      if ActiveToolButtonsCount>0 then
      begin
        ToolButtWidth:=ToolButtonPanel.Width div ActiveToolButtonsCount;
        For i1:=1 to ToolCommandsCount do
        begin
          If FQuery.Active and (FDisplayMode in TDataGrid) Then
          begin
            TollButton:=TSpeedButton.Create(ToolButtonPanel);
            TollButton.Parent:=ToolButtonPanel;
            TollButton.Top:=2;
            TollButton.Left:=(ToolButtWidth*(ToolButtonsCount))+1;
            TollButton.Width:=ToolButtWidth;
            TollButton.Align:=alLeft;
            TollButton.Flat:=ToolButtonsFlat;
            TollButton.Glyph:=DrawBMPButton(ToolButtonsCmd[i1]);
            TollButton.OnClick:=ToolButtonsOnClick;
            TollButton.Tag:=i1;

            Inc(ToolButtonsCount);
            ToolButtonPanelButtons[ToolButtonsCount]:=TollButton;
            ToolCommands[ToolButtonsCount]:=ToolButtonsCmd[i1];
          end;
        end;
      end;
    end;

    If ToolButtonsCount=0 Then
      FreeAndNil(ToolButtonPanel);
  end;
  SetReadOnly(FReadOnly);
  SetMultiselect(FMultiSelect);

  FShowed:=True;
end;

procedure TDCLGrid.SortDB(Column: TColumn);
var
  SortIt: Boolean;
  v1: Byte;
  OrderBy, tmpSQL1: String;
begin
  SortIt:=True;
  If Length(OrderByFields)>0 Then
  begin
    SortIt:=False;
    For v1:=1 to Length(OrderByFields) do
      If LowerCase(Column.FieldName)=LowerCase(OrderByFields[v1-1]) Then
      begin
        SortIt:=True;
        break;
      end;
  end;

  If SortIt Then
  begin
    FQuery.Close;
    tmpSQL1:=FQuery.SQL.Text;
    If PosEx('order by', tmpSQL1)<>0 Then
    begin
      OrderBy:=Copy(tmpSQL1, PosEx(' order by', tmpSQL1), Length(tmpSQL1));
      Delete(tmpSQL1, PosEx(' order by', tmpSQL1), Length(tmpSQL1));
    end;

    If KeyState(VK_CONTROL) Then
      OrderBy:=OrderBy+', '+Column.FieldName
    Else
      OrderBy:=' order by '+Column.FieldName;

    FQuery.SQL.Text:=tmpSQL1+' '+OrderBy;

    ReFreshQuery;

    If PreviousColumnIndex<> - 1 Then
      FGrid.Columns[PreviousColumnIndex].Title.Font.Style:=FGrid.Columns[PreviousColumnIndex]
        .Title.Font.Style-[fsBold];
    Column.Title.Font.Style:=Column.Title.Font.Style+[fsBold];

    PreviousColumnIndex:=Column.Index;
  end;
end;

procedure TDCLGrid.Structure(Sender: TObject);
var
  v1, v2: Word;
begin
  If FDisplayMode in TDataGrid Then
    If Not Assigned(FieldsList) Then
    begin
      FGrid.Align:=alLeft;
      v1:=FGrid.Width div 2;
      FGrid.Width:=v1;

      Splitter1:=TSplitter.Create(FGridPanel);
      Splitter1.Parent:=FGridPanel;
      Splitter1.Left:=(FDCLForm.FForm.Width div 2)+10;

      ColumnsList:=TListBox.Create(FGridPanel);
      ColumnsList.Parent:=FGridPanel;
      ColumnsList.OnDblClick:=ColumnsManege;
      ColumnsList.Left:=(FDCLForm.FForm.Width div 2)+10;
      ColumnsList.Align:=alLeft;

      Splitter2:=TSplitter.Create(FGridPanel);
      Splitter2.Parent:=FGridPanel;
      Splitter2.Left:=FDCLForm.FForm.Width-10;

      FieldsList:=TListBox.Create(FGridPanel);
      FieldsList.Parent:=FGridPanel;
      FieldsList.Left:=FDCLForm.FForm.Width-5;
      FieldsList.OnDblClick:=FieldsManege;

      FieldsList.Align:=alClient;
      v2:=v1 div 2;
      ColumnsList.Width:=v2;
      FieldsList.Width:=v2;

      SetLength(StructModify, FGrid.Columns.Count);
      For v1:=0 to FGrid.Columns.Count-1 do
      begin
        ColumnsList.Items.Append(FGrid.Columns[v1].Title.Caption+'\'+FGrid.Columns[v1].FieldName);
        StructModify[v1].ColumnsListField:=FGrid.Columns[v1].FieldName;
        StructModify[v1].ColumnsListCaption:=FGrid.Columns[v1].Title.Caption;
      end;

      If Length(StructModify)<Length(DataFields) Then
        SetLength(StructModify, Length(DataFields));
      If Length(DataFields)>0 Then
        For v1:=0 to Length(DataFields)-1 do
        begin
          FieldsList.Items.Append(DataFields[v1].Caption+'\'+DataFields[v1].Name);

          StructModify[v1].FieldsListCaption:=DataFields[v1].Caption;
          StructModify[v1].FieldsListField:=DataFields[v1].Name;
        end;
    end
    Else
    begin
      FreeAndNil(FieldsList);
      FreeAndNil(ColumnsList);
      FreeAndNil(Splitter1);
      FreeAndNil(Splitter2);
      FGrid.Align:=alClient;
    end;
end;

procedure TDCLGrid.ToolButtonsOnClick(Sender: TObject);
var
  NumBtn: Integer;
begin
  NumBtn:=(Sender as TDialogSpeedButton).Tag;
  FDCLForm.ExecCommand(ToolCommands[NumBtn]);
end;

procedure TDCLGrid.TranslateVal(var Params: String);
var
  FFactor: Word;
begin
  RePlaseParams(Params);
  FDCLForm.RePlaseVariables(Params);
  FFactor:=0;
  TranslateProc(Params, FFactor, Query);
end;

{ TDCLCommandButton }

procedure TDCLCommandButton.AddCommand(Parent: TWinControl; ButtonParams: RButtonParams);
var
  FButtonsCount: Integer;
  BinStore: TDCLBinStore;
  MS: TMemoryStream;
  BM: TBitmap;
begin
  FButtonsCount:=Length(Commands);
  inc(FButtonsCount);
  SetLength(Commands, FButtonsCount);
  SetLength(CommandButton, FButtonsCount);

  CommandButton[FButtonsCount-1]:=TDialogButton.Create(Parent);
  CommandButton[FButtonsCount-1].Parent:=Parent;
  CommandButton[FButtonsCount-1].Name:='CommandButton_'+IntToStr(FButtonsCount);
  CommandButton[FButtonsCount-1].Tag:=FButtonsCount-1;
  CommandButton[FButtonsCount-1].Caption:=ButtonParams.Caption;
  CommandButton[FButtonsCount-1].Hint:=ButtonParams.Hint;
  CommandButton[FButtonsCount-1].ShowHint:=ButtonParams.Hint<>'';
  CommandButton[FButtonsCount-1].OnClick:=ExecCommand;
  CommandButton[FButtonsCount-1].Top:=ButtonParams.Top;
  CommandButton[FButtonsCount-1].Left:=ButtonParams.Left;
  CommandButton[FButtonsCount-1].Width:=ButtonParams.Width;
  CommandButton[FButtonsCount-1].Height:=ButtonParams.Height;

  CommandButton[FButtonsCount-1].Default:=ButtonParams.Default;
  CommandButton[FButtonsCount-1].Cancel:=ButtonParams.Cancel;

  CommandButton[FButtonsCount-1].Glyph.Transparent:=True;
  If ButtonParams.Pict<>'' Then
  begin
    BM:=DrawBMPButton(ButtonParams.Pict);
    If BM.Width<>0 Then
    begin
      CommandButton[FButtonsCount-1].Glyph.Assign(BM);
    end
    Else
    begin
      BinStore:=TDCLBinStore.Create(FDCLLogOn);
      MS:=BinStore.GetData(ButtonParams.Pict);
      If MS.Size=0 Then
        CommandButton[FButtonsCount-1].Glyph.Assign(DrawBMPButton(ButtonParams.Pict))
      Else
      begin
        BM:=TBitmap.Create;
        MS.Position:=0;
        BM.LoadFromStream(MS);
        CommandButton[FButtonsCount-1].Glyph.TransparentMode:=tmFixed;
        CommandButton[FButtonsCount-1].Glyph.TransparentColor:=BM.Canvas.Pixels[0, 0];
        CommandButton[FButtonsCount-1].Glyph.Assign(BM);
        CommandButton[FButtonsCount-1].Glyph.Transparent:=True;
        MS.Free;
      end;
    end;
  end;

  If ButtonParams.FontStyle=[fsBold] Then
    CommandButton[FButtonsCount-1].Font.Style:=CommandButton[FButtonsCount-1].Font.Style+[fsBold];
  If ButtonParams.FontStyle=[fsItalic] Then
    CommandButton[FButtonsCount-1].Font.Style:=CommandButton[FButtonsCount-1].Font.Style+[fsItalic];
  If ButtonParams.FontStyle=[fsUnderLine] Then
    CommandButton[FButtonsCount-1].Font.Style:=CommandButton[FButtonsCount-1].Font.Style+
      [fsUnderLine];

  Commands[FButtonsCount-1]:=ButtonParams.Command;
end;

constructor TDCLCommandButton.Create(var DCLLogOn: TDCLLogOn; var DCLForm: TDCLForm);
begin
  FDCLForm:=DCLForm;
  FDCLLogOn:=DCLLogOn;
end;

destructor TDCLCommandButton.Destroy;
var
  i:Integer;
begin
  For i:=1 to Length(CommandButton) do
  Begin
    FreeAndNil(CommandButton[i-1]);
  End;
end;

procedure TDCLCommandButton.ExecCommand(Sender: TObject);
var
  Tag: Integer;
  FDCLCommand: TDCLCommand;
begin
  Tag:=(Sender as TDialogButton).Tag;
  FDCLCommand:=TDCLCommand.Create(FDCLForm, FDCLLogOn);
  FDCLCommand.ExecCommand(Commands[Tag], FDCLForm);
  FreeAndNil(FDCLCommand);
end;

{ TMainFormAction }

procedure TMainFormAction.CloseMainForm(Sender: TObject; var Action: TCloseAction);
begin
  If Assigned(DCLMainLogOn) then
  Begin
    SaveMainFormPos(DCLMainLogOn, DCLMainLogOn.MainForm, MainFormName);

    EndDCL;
  End;
end;

procedure TMainFormAction.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose:=False;
  If (Not GPT.ExitCnf)and(Not DownLoadProcess) Then
    CanClose:=True;
  If (GPT.ExitCnf)and(Not DownLoadProcess) Then
    If ShowErrorMessage(10, GetDCLMessageString(msDoYouWontTerminateApplicationQ))=1 Then
      CanClose:=True;

  If DownLoadProcess Then
    If ShowErrorMessage(10, GetDCLMessageString(msDownloadInProgress)+'. '+
          GetDCLMessageString(msDoYouWontTerminateApplicationQ))=1 Then
      CanClose:=True;
end;

{ TPrintBase }

procedure TPrintBase.Print(Grid: TDCLDBGrid; Query: TDCLDialogQuery; Caption: String);
var
  SeparatorLength, k, FieldsCounter: Word;
  Separator, S, S1, S2: String;
  PrintBox: TStringList;
begin
  PrintBox:=TStringList.Create;
  If DefaultSystemEncoding=EncodingUTF8 Then
    PrintBox.Append(UTF8BOM+Caption)
  Else If DefaultSystemEncoding='utf16' Then
    PrintBox.Append(UTF16LEBOM+Caption)
  Else
    PrintBox.Append(Caption);

  PrintBox.Append('');
  S:='|';
  If Not Assigned(Grid) Then
  begin
    For FieldsCounter:=0 to Query.FieldCount-1 do
    begin
      S1:='';
      S2:=TrimRight(Query.Fields[FieldsCounter].FieldName);
      If Length(S2)>Query.Fields[FieldsCounter].DataSize Then
        SetLength(S2, Query.Fields[FieldsCounter].DataSize+1);
      S:=S+S2;
      For k:=Length(TrimRight(Query.Fields[FieldsCounter].FieldName)) to Query.Fields
        [FieldsCounter].DataSize do
        S1:=S1+' ';
      S:=S+S1+'|';
    end;
    PrintBox.Append(S);
    SeparatorLength:=Length(S)-1;
    Separator:='';
    For FieldsCounter:=0 to SeparatorLength do
      Separator:=Separator+'-';
    PrintBox.Append(Separator);

    Query.First;
    While Not Query.Eof do
    begin
      S:='|';
      For FieldsCounter:=0 to Query.FieldCount-1 do
      begin
        S1:='';
        S2:=TrimRight(Query.Fields[FieldsCounter].AsString);
        If Length(S2)>Query.Fields[FieldsCounter].DataSize Then
          SetLength(S2, Query.Fields[FieldsCounter].DataSize+1);
        S:=S+S2;
        For k:=Length(TrimRight(Query.Fields[FieldsCounter].AsString)) to Query.Fields
          [FieldsCounter].DataSize do
          S1:=S1+' ';
        S:=S+S1+'|';
      end;
      PrintBox.Append(S);
      Query.Next;
    end;
    PrintBox.Append(Separator);
    Separator:='|'+IntToStr(Query.RecordCount);
  end
  Else
  begin
    For FieldsCounter:=0 to Grid.Columns.Count-1 do
    begin
      S1:='';
      S2:=TrimRight(Grid.Columns[FieldsCounter].Title.Caption);
      If Length(S2)>(Grid.Columns[FieldsCounter].Width div 7) Then
        SetLength(S2, (Grid.Columns[FieldsCounter].Width div 7)+1);
      S:=S+S2;
      For k:=Length(TrimRight(Grid.Columns[FieldsCounter].Title.Caption))
        to (Grid.Columns[FieldsCounter].Width div 7) do
        S1:=S1+' ';
      S:=S+S1+'|';
    end;
    PrintBox.Append(S);
    SeparatorLength:=Length(S)-1;
    Separator:='';
    For FieldsCounter:=0 to SeparatorLength do
      Separator:=Separator+'-';
    PrintBox.Append(Separator);

    Query.DisableControls;

    Query.First;
    While Not Query.Eof do
    begin
      S:='|';
      For FieldsCounter:=0 to Grid.Columns.Count-1 do
      begin
        S1:='';
        try
          S2:=Grid.Columns[FieldsCounter].Field.AsString;
        Except
          S2:=GetDCLMessageString(msNoField);
        end;
        If Length(S2)>(Grid.Columns[FieldsCounter].Width div 7) Then
          SetLength(S2, (Grid.Columns[FieldsCounter].Width div 7)+1);
        S:=S+S2;
        For k:=Length(TrimRight(Grid.Columns[FieldsCounter].Field.AsString))
          to (Grid.Columns[FieldsCounter].Width div 7) do
          S1:=S1+' ';
        S:=S+S1+'|';
      end;
      PrintBox.Append(TrimRight(S));
      Query.Next;
    end;
    Query.EnableControls;
    PrintBox.Append(Separator);
    Separator:='|'+IntToStr(Query.RecordCount);
  end;
  For FieldsCounter:=Length(Separator) to SeparatorLength-1 do
    Separator:=Separator+' ';
  Separator:=Separator+'|';
  PrintBox.Append(Separator);

  PrintBox.SaveToFile(IncludeTrailingPathDelimiter(AppConfigDir)+'table.tmp');
  FreeAndNil(PrintBox);
  ExecApp('"'+GPT.Viewer+'" "'+IncludeTrailingPathDelimiter(AppConfigDir)+'table.tmp"');
end;

procedure TDCLOfficeReport.ReportOpenOfficeWriter(ParamStr: String; Save, Close: Boolean);
var
  TextPointer, CursorPointer, BookmarksSupplier, InsLength, BookMark: Variant;
  BookmarckNum, LayotCount, FontSize, lastBookmarks: Word;
  DocNum: Cardinal;
  SQLStr, FileName, OutFileName, Ext, TemplateExt, InsStr, BookMarkName, LayotStr, LayotItem: String;
  Layot: TStringList;
  DCLQuery: TDCLDialogQuery;

  ToPDF, ToHTML, ToWrite, BookmarkFromLayot: Boolean;
  FontStyleRec: TFontStyleRec;
begin
{$IFDEF MSWINDOWS}
  Ext:='odt';
  TemplateExt:='ott';

  if FindParam('TemplateName=', ParamStr)<>'' then
  begin
    FileName:=BinStor.GetTemplateFile(FindParam('TemplateName=', ParamStr),
      FindParam('Template=', ParamStr), Ext);
  end;

  FileName:=FindParam('Template=', ParamStr);
  If not IsFullPath(FileName) then
    FileName:=AppConfigDir+FileName;

  If NoFileExt(FileName) then
  begin
    OfficeDocumentFormat:=odfOO;
    if FileExists(FileName+'.'+TemplateExt) then
    begin
      OfficeDocumentFormat:=odfOO;
      FileName:=FileName+'.'+TemplateExt;
    end
    else
    begin
      if FileExists(FileName+'.'+Ext) then
      begin
        OfficeDocumentFormat:=odfOO;
        FileName:=FileName+'.'+Ext;
      end;
    end;
  end
  else
  begin
    OfficeDocumentFormat:=GetDocumentType(FileName);
  end;

  OutFileName:=FindParam('FileName=', ParamStr);
  if not IsFullPath(OutFileName) then
    OutFileName:=AppConfigDir+OutFileName;

  If BinStor.ErrorCode=0 Then
  If FileExists(FileName) Then
  begin
    LayotStr:=FindParam('Layot=', ParamStr);
    If LayotStr<>'' Then
    begin
      Layot.Clear;
      LayotCount:=ParamsCount(LayotStr);
      For BookmarckNum:=1 to ParamsCount(LayotStr) do
      begin
        BookmarkFromLayot:=True;
        LayotItem:=SortParams(LayotStr, BookmarckNum);

        Layot.Append(LayotItem);
      end;
    end;

    DCLQuery:=TDCLDialogQuery.Create(nil);
    DCLQuery.Name:='OfficeReport_'+IntToStr(UpTime);
    FDCLLogOn.SetDBName(DCLQuery);
    try
      If VarIsEmpty(OO) Then
        OO:=CreateOleObject('com.sun.star.ServiceManager');

      Desktop:=OO.CreateInstance('com.sun.star.frame.Desktop');
      VariantArray:=VarArrayCreate([0, 0], varVariant);
      Case OfficeDocumentFormat of
      odfMSO2007:
      VariantArray[0]:=MakePropertyValue(OO, 'FilterName', 'MS Word 2007');
      odfMSO97:
      VariantArray[0]:=MakePropertyValue(OO, 'FilterName', 'MS Word 97');
      odfOO, odfPossible:
      VariantArray[0]:=MakePropertyValue(OO, 'FilterName', 'writer8');
      end;
    Except
      Sheets:=Unassigned;
      Sheet:=Unassigned;
      Document:=Unassigned;
      Desktop:=Unassigned;
      OO:=Unassigned;
      ShowErrorMessage( - 6002, '');
      Exit;
    end;

    If PosEx('ToPDF=1', ParamStr)<>0 Then
      ToPDF:=True
    Else
      ToPDF:=False;

    If PosEx('ToHTML=1', ParamStr)<>0 Then
      ToHTML:=True
    Else
      ToHTML:=False;

    SQLStr:=FindParam('SQL=', ParamStr);
    If (SQLStr='')and Assigned(FDCLGrid) Then
      SQLStr:=FDCLGrid.Query.SQL.Text;

    If Assigned(FDCLGrid) Then
      FDCLGrid.TranslateVal(SQLStr);
    DCLQuery.Close;
    DCLQuery.SQL.Clear;
    FDCLLogOn.SetDBName(DCLQuery);
    DCLQuery.SQL.Text:=SQLStr;
    try
      DCLQuery.Open;
    Except
      ShowErrorMessage( - 1104, 'SQL='+SQLStr);
    end;
    DCLQuery.First;

    DocNum:=1;
    While Not DCLQuery.Eof do
    begin
      Try
        Document:=Desktop.LoadComponentFromURL(FileNameToURL(FileName), '_blank', 0, VariantArray);
        OOSetVisible(Document, False);
        TextPointer:=Document.GetText;
      Except
        Document:=Unassigned;
        Desktop:=Unassigned;
        OO:=Unassigned;
        ShowErrorMessage( - 6003, '');
        Exit;
      End;
      CursorPointer:=TextPointer.CreateTextCursor;

      BookmarksSupplier:=Document.getBookmarks;
      If (Not BookmarkFromLayot)and(LayotCount=0) Then
        LayotCount:=BookmarksSupplier.Count;

      For BookmarckNum:=0 to LayotCount-1 do
      begin
        try
          FontSize:=0;
          BookmarksSupplier:=Document.getBookmarks;
          CursorPointer:=TextPointer.CreateTextCursor;

          lastBookmarks:=BookmarksSupplier.Count;

          if lastBookmarks=0 then break;

          If BookmarkFromLayot Then
          begin
            ToWrite:=False;

            FontStyleRec.Bold:=0;
            FontStyleRec.italic:=0;
            FontStyleRec.Undeline:=0;
            FontStyleRec.Center:=False;
            FontStyleRec.StrikeThrough:=0;

            LayotItem:=Layot[BookmarckNum];
            BookMarkName:=ExtractSection(LayotItem);
            LayotStr:=ExtractSection(LayotItem);
            If PosEx('B', LayotStr)<>0 Then
              FontStyleRec.Bold:=1;
            If PosEx('I', LayotStr)<>0 Then
              FontStyleRec.italic:=1;
            If PosEx('U', LayotStr)<>0 Then
              FontStyleRec.Undeline:=1;
            If PosEx('C', LayotStr)<>0 Then
              FontStyleRec.Center:=True;
            If PosEx('S', LayotStr)<>0 Then
              FontStyleRec.StrikeThrough:=1;

            LayotStr:=ExtractSection(LayotItem);
            If LayotStr<>'' Then
              FontSize:=StrToIntEx(LayotStr);

            LayotStr:=ExtractSection(LayotItem);
            If LayotStr<>'' Then
              If PosEx('W', LayotStr)<>0 Then
                ToWrite:=True
              Else
                ToWrite:=False;
          end
          Else
            BookMarkName:=BookmarksSupplier.getByIndex(BookmarckNum).getName;

          If FieldExists(BookMarkName, DCLQuery) Then
          begin
            BookMark:=BookmarksSupplier.getByIndex(BookmarckNum).getAnchor;
            If ToWrite Then
              InsStr:=MoneyToString(DCLQuery.FieldByName(BookMarkName).AsCurrency, True, False)
            Else
              InsStr:=Trim(DCLQuery.FieldByName(BookMarkName).AsString);

            //InsLength:=Variant(Length(InsStr));
            CursorPointer.GotoRange(BookMark.GetStart, False);
            //CursorPointer.GoRight(InsLength, True);
            //CursorPointer.setString('');
            If FontStyleRec.italic=1 Then
              CursorPointer.setPropertyValue('CharPosture', Ord(fsItalic));
            If FontStyleRec.Bold=1 Then
              CursorPointer.setPropertyValue('CharWeight', Ord(fsBold));
            If FontStyleRec.StrikeThrough=1 Then
              CursorPointer.setPropertyValue('CharStrikeout', Ord(fsStrikeout));
            If FontStyleRec.Undeline=1 Then
              CursorPointer.setPropertyValue('CharUnderline', Ord(fsUnderLine));
            If FontSize<>0 Then
              CursorPointer.setPropertyValue('CharHeight', FontSize);

            CursorPointer.setString(InsStr);
          end;
        Except
          OOSetVisible(Document, True);
          ShowErrorMessage( - 5005, '');
        end;
      end;

      If ToPDF Then
        OOExportToFormat(Document, AddToFileName(OutFileName, '_'+IntToStr(DocNum)), 'pdf');

      If ToHTML Then
        OOExportToFormat(Document, AddToFileName(OutFileName, '_'+IntToStr(DocNum)), 'html');

      OOSetVisible(Document, True);
      If Save Then
      begin
        Case OfficeDocumentFormat of
        odfMSO97:
        begin
          FileName:=FakeFileExt(OutFileName, 'doc');
          VariantArray[0]:=MakePropertyValue(OO, 'FilterName', 'MS Word 97');
        end;
        odfMSO2007:
        begin
          FileName:=FakeFileExt(OutFileName, 'docx');
          VariantArray[0]:=MakePropertyValue(OO, 'FilterName', 'MS Word 2007');
        end;
        odfOO, odfPossible:
        begin
          FileName:=FakeFileExt(OutFileName, 'odt');
          VariantArray[0]:=MakePropertyValue(OO, 'FilterName', 'writer8');
        end;
        end;

        Document.StoreAsURL(FileNameToURL(AddToFileName(OutFileName, '_'+IntToStr(DocNum))),
          VariantArray);
      end;

      If Close then
      Begin
        Document.Close(True);
        Document:=Unassigned;
      End;

      Sheets:=Unassigned;
      Sheet:=Unassigned;
      //Document:=Unassigned;
      //Desktop:=Unassigned;
      //OO:=Unassigned;

      If ToPDF Then
        Exec(FakeFileExt(AddToFileName(OutFileName, '_'+IntToStr(DocNum)), 'pdf'), '');

      If ToHTML Then
        Exec(FakeFileExt(AddToFileName(OutFileName, '_'+IntToStr(DocNum)), 'html'), '');

      inc(DocNum);
      DCLQuery.Next;
    end;
    DCLQuery.Close;

    Sheets:=Unassigned;
    Sheet:=Unassigned;
    //OO:=Unassigned;
  end
  Else
    ShowErrorMessage( - 5006, FileName);
{$ENDIF}
end;

procedure TDCLOfficeReport.ReportOpenOfficeCalc(ParamStr: String; Save, Close: Boolean);
var
  SQLStr, Fields, FileName, OutFileName, ColorStr, Ext, TemplateExt: String;
  ToPDF, ToHTML, EnableRowChColor, EnableColChColor: Boolean;
  v1: Byte;
  RecRepNum: Cardinal;
  StartRow, StartCol, RowRColor, RowBColor, RowGColor, ColRColor, ColBColor, ColGColor: Integer;
  DCLQuery: TDCLDialogQuery;
begin
{$IFDEF MSWINDOWS}
  Ext:='ods';
  TemplateExt:='ots';

  if FindParam('TemplateName=', ParamStr)<>'' then
  begin
    FileName:=BinStor.GetTemplateFile(FindParam('TemplateName=', ParamStr),
      FindParam('Template=', ParamStr), Ext);
  end;

  FileName:=FindParam('Template=', ParamStr);
  If not IsFullPath(FileName) then
    FileName:=AppConfigDir+FileName;
  If NoFileExt(FileName) then
  begin
    OfficeDocumentFormat:=odfOO;
    if FileExists(FileName+'.'+TemplateExt) then
    begin
      OfficeDocumentFormat:=odfOO;
      FileName:=FileName+'.'+TemplateExt;
    end
    else
    begin
      if FileExists(FileName+'.'+Ext) then
      begin
        OfficeDocumentFormat:=odfOO;
        FileName:=FileName+'.'+Ext;
      end;
    end;
  end
  else
  begin
    OfficeDocumentFormat:=GetDocumentType(FileName);
  end;

  OutFileName:=FindParam('FileName=', ParamStr);
  if not IsFullPath(OutFileName) then
    OutFileName:=AppConfigDir+OutFileName;

  If BinStor.ErrorCode=0 Then
    If FileExists(FileName) Then
    begin
      try
        OO:=CreateOleObject('com.sun.star.ServiceManager');
        Desktop:=OO.CreateInstance('com.sun.star.frame.Desktop');
        VariantArray:=VarArrayCreate([0, 0], varVariant);
        Case OfficeDocumentFormat of
        odfMSO2007:
        VariantArray[0]:=MakePropertyValue(OO, 'FilterName', 'MS Excel 2007');
        odfMSO97:
        VariantArray[0]:=MakePropertyValue(OO, 'FilterName', 'MS Excel 97');
        odfOO, odfPossible:
        VariantArray[0]:=MakePropertyValue(OO, 'FilterName', 'calc8');
        end;
      Except
        Sheets:=Unassigned;
        Sheet:=Unassigned;
        Document:=Unassigned;
        Desktop:=Unassigned;
        OO:=Unassigned;
        ShowErrorMessage( - 6001, '');
        Exit;
      end;
      Try
        Document:=Desktop.LoadComponentFromURL(FileNameToURL(FileName), '_blank', 0, VariantArray);
        OOSetVisible(Document, False);
        Sheets:=Document.GetSheets;
        Sheet:=Sheets.getByIndex(0);
      Except
        Sheets:=Unassigned;
        Sheet:=Unassigned;
        Document:=Unassigned;
        Desktop:=Unassigned;
        OO:=Unassigned;
        ShowErrorMessage( - 6003, '');
        Exit;
      End;

      try
        Range:=Sheet.getCellRangeByName('DATA');
        StartRow:=Range.RangeAddress.StartRow;
        StartCol:=Range.RangeAddress.StartColumn;
      Except
        OOSetVisible(Document, True);
        Document.Close(False);
        Sheets:=Unassigned;
        Sheet:=Unassigned;
        Document:=Unassigned;
        Desktop:=Unassigned;
        OO:=Unassigned;
        ShowErrorMessage( - 5002, '');
        Exit;
      end;

      NF:=Document.GetNumberFormats;
      Loc:=OO.Bridge_GetStruct('com.sun.star.lang.Locale');

      SQLStr:=FindParam('SQL=', ParamStr);
      If (SQLStr='') and Assigned(FDCLGrid) Then
        SQLStr:=FDCLGrid.Query.SQL.Text;

      Fields:=FindParam('FieldsSet=', ParamStr);

      if Fields<>'' then
      begin
        SQLStr:=ReplaceSQLFields(SQLStr, Fields);
      end;

      If Assigned(FDCLGrid) Then
        FDCLGrid.TranslateVal(SQLStr);

      DCLQuery:=TDCLDialogQuery.Create(nil);
      DCLQuery.Name:='OfficeReport2_'+IntToStr(UpTime);
      FDCLLogOn.SetDBName(DCLQuery);

      DCLQuery.SQL.Text:=SQLStr;
      try
        DCLQuery.Open;
      Except
        OOSetVisible(Document, True);
        ShowErrorMessage( - 1104, 'SQL='+SQLStr);
      end;
      DCLQuery.First;

      If PosEx('ToPDF=1', ParamStr)<>0 Then
        ToPDF:=True
      Else
        ToPDF:=False;

      If PosEx('ToHTML=1', ParamStr)<>0 Then
        ToHTML:=True
      Else
        ToHTML:=False;

      EnableRowChColor:=False;
      ColorStr:=FindParam('AlternationRowBackColor=', ParamStr);
      If ColorStr<>'' Then
      begin
        RowRColor:=HexToInt(Copy(ColorStr, 1, 2));
        RowBColor:=HexToInt(Copy(ColorStr, 3, 2));
        RowGColor:=HexToInt(Copy(ColorStr, 5, 2));
        EnableRowChColor:=True;
      end;

      EnableColChColor:=False;
      ColorStr:=FindParam('AlternationColBackColor=', ParamStr);
      If ColorStr<>'' Then
      begin
        ColRColor:=HexToInt(Copy(ColorStr, 1, 2));
        ColBColor:=HexToInt(Copy(ColorStr, 3, 2));
        ColGColor:=HexToInt(Copy(ColorStr, 5, 2));
        EnableColChColor:=True;
      end;

      RecRepNum:=1;
      While Not DCLQuery.Eof do
      begin
        For v1:=0 to DCLQuery.FieldCount-1 do
        begin
          SQLStr:=TrimRight(DCLQuery.Fields[v1].AsString);
          InsertTextByXY(Sheet, Cell, BaseToInterface(SQLStr), RecRepNum+StartRow-1,
            v1+1+StartCol-1);

          case DCLQuery.Fields[v1].DataType of
          ftString, ftMemo, ftFmtMemo, ftWideString, ftFixedWideChar,
            ftWideMemo:begin
            SetFormulaByXY(Loc, NF, Sheet, Cell, '@', RecRepNum+StartRow-1, v1+1+StartCol-1);
          end;
          ftSmallint, ftInteger, ftWord, ftAutoInc, ftLargeint, ftVariant,
            ftLongWord, ftShortint, ftBCD, ftByte:begin
            SetFormulaByXY(Loc, NF, Sheet, Cell, '# ##0', RecRepNum+StartRow-1, v1+1+StartCol-1);
          end;
          ftFloat, ftExtended, ftSingle:begin
            SetFormulaByXY(Loc, NF, Sheet, Cell, '@', RecRepNum+StartRow-1, v1+1+StartCol-1);
          end;
          ftCurrency:begin
            SetFormulaByXY(Loc, NF, Sheet, Cell, '# ##0,00', RecRepNum+StartRow-1, v1+1+StartCol-1);
          end;
          ftDate:begin
            SetFormulaByXY(Loc, NF, Sheet, Cell, 'DD.MM.YY', RecRepNum+StartRow-1, v1+1+StartCol-1);
          end;
          ftTime:begin
            SetFormulaByXY(Loc, NF, Sheet, Cell, 'HH:MM:SS', RecRepNum+StartRow-1, v1+1+StartCol-1);
          end;
          ftDateTime, ftTimeStamp, ftOraTimeStamp:begin
            SetFormulaByXY(Loc, NF, Sheet, Cell, 'DD.MM.YYYY HH:MM:SS', RecRepNum+StartRow-1, v1+1+StartCol-1);
          end;
          Else
            SetFormulaByXY(Loc, NF, Sheet, Cell, '@', RecRepNum+StartRow-1, v1+1+StartCol-1);
          end;

          If EnableRowChColor Then
            If RecRepNum Mod 2=0 Then
              Cell.cellBackColor:=(RowRColor or(RowGColor Shl 8)or(RowBColor Shl 16));
          If EnableColChColor Then
            If v1 Mod 2=0 Then
              Cell.cellBackColor:=(ColRColor or(ColGColor Shl 8)or(ColBColor Shl 16));
        end;
        inc(RecRepNum);
        DCLQuery.Next;
      end;
      DCLQuery.Close;

      FileName:=AddToFileName(FileName, '_Report');

      If ToPDF Then
        OOExportToFormat(Document, OutFileName, 'pdf');

      If ToHTML Then
        OOExportToFormat(Document, OutFileName, 'html');

      FileName:=FakeFileExt(OutFileName, Ext);
      OOSetVisible(Document, True);
      If Save Then
      begin
        Case OfficeDocumentFormat of
        odfMSO97:
        begin
          VariantArray[0]:=MakePropertyValue(OO, 'FilterName', 'MS Excel 97');
        end;
        odfMSO2007:
        begin
          VariantArray[0]:=MakePropertyValue(OO, 'FilterName', 'MS Excel 2007');
        end;
        odfOO, odfPossible:
        begin
          VariantArray[0]:=MakePropertyValue(OO, 'FilterName', 'calc8');
        end;
        end;

        Document.StoreAsURL(FileNameToURL(FileName), VariantArray);
      end;

      If Close Then
      Begin
        Document.Close(True);
        Document:=Unassigned;
      End;

      Sheets:=Unassigned;
      Sheet:=Unassigned;

      If ToPDF Then
        Exec(FakeFileExt(FileName, 'pdf'), '');

      If ToHTML Then
        Exec(FakeFileExt(FileName, 'html'), '');
    end
    Else
      ShowErrorMessage( - 5007, FileName);
{$ENDIF}
end;

procedure TDCLOfficeReport.ReportWord(ParamStr: String; Save, Close: Boolean);
{$IFDEF MSWINDOWS}
var
  StV: OleVariant;
  SQLStr, FileName, OutFileName, Ext, TemplateExt, LayotStr, LayotItem, BookmarckName: String;
  Layot: TStringList;
  DocNum: Cardinal;
  ParamNum, BookmarckNum, LayotCount, FontSize: Byte;

  ToWrite, BookmarkFromLayot: Boolean;
  FontStyleRec: TFontStyleRec;
  DCLQuery: TDCLDialogQuery;
{$ENDIF}
begin
{$IFDEF MSWINDOWS}
  Ext:='doc';
  TemplateExt:='dot';

  if FindParam('TemplateName=', ParamStr)<>'' then
  begin
    FileName:=BinStor.GetTemplateFile(FindParam('TemplateName=', ParamStr),
      FindParam('Template=', ParamStr), Ext);
  end;

  FileName:=FindParam('Template=', ParamStr);
  If not IsFullPath(FileName) then
    FileName:=AppConfigDir+FileName;

  If NoFileExt(FileName) then
  begin
    OfficeDocumentFormat:=odfOO;
    if FileExists(FileName+'.'+TemplateExt) then
    begin
      OfficeDocumentFormat:=odfOO;
      FileName:=FileName+'.'+TemplateExt;
    end
    else
    begin
      if FileExists(FileName+'.'+Ext) then
      begin
        OfficeDocumentFormat:=odfOO;
        FileName:=FileName+'.'+Ext;
      end;
    end;
  end
  else
  begin
    OfficeDocumentFormat:=GetDocumentType(FileName);
  end;

  OutFileName:=FindParam('FileName=', ParamStr);
  if not IsFullPath(OutFileName) then
    OutFileName:=AppConfigDir+OutFileName;

  If BinStor.ErrorCode=0 Then
  If FileExists(FileName) Then
  begin
    LayotStr:=FindParam('Layot=', ParamStr);
    If LayotStr<>'' Then
    begin
      Layot.Clear;
      LayotCount:=ParamsCount(LayotStr);
      For BookmarckNum:=1 to ParamsCount(LayotStr) do
      begin
        BookmarkFromLayot:=True;
        LayotItem:=SortParams(LayotStr, BookmarckNum);

        Layot.Append(LayotItem);
      end;
    end;

    SQLStr:=FindParam('SQL=', ParamStr);
    If (SQLStr='')and Assigned(FDCLGrid) Then
      SQLStr:=FDCLGrid.Query.SQL.Text;

    If Assigned(FDCLGrid) Then
      FDCLGrid.TranslateVal(SQLStr);
    DCLQuery:=TDCLDialogQuery.Create(nil);
    DCLQuery.Name:='OfRep3_'+IntToStr(UpTime);
    FDCLLogOn.SetDBName(DCLQuery);
    DCLQuery.SQL.Text:=SQLStr;
    try
      DCLQuery.Open;
    Except
      ShowErrorMessage( - 1104, 'SQL='+SQLStr);
    end;
    DCLQuery.First;

    DocNum:=1;
    While Not DCLQuery.Eof do
    begin
      WordRun(MsWord);
      WordOpen(MsWord, FileName);

      If (Not BookmarkFromLayot)and(LayotCount=0) Then
        LayotCount:=MsWord.ActiveDocument.BookMarks.Count;

      For BookmarckNum:=0 to LayotCount-1 do
      begin
        If BookmarkFromLayot Then
        begin
          ToWrite:=False;

          FontStyleRec.Bold:=0;
          FontStyleRec.italic:=0;
          FontStyleRec.Undeline:=0;
          FontStyleRec.Center:=False;
          FontStyleRec.StrikeThrough:=0;

          LayotItem:=Layot[BookmarckNum];
          BookmarckName:=ExtractSection(LayotItem);
          LayotStr:=ExtractSection(LayotItem);
          If PosEx('B', LayotStr)<>0 Then
            FontStyleRec.Bold:=1;
          If PosEx('I', LayotStr)<>0 Then
            FontStyleRec.italic:=1;
          If PosEx('U', LayotStr)<>0 Then
            FontStyleRec.Undeline:=1;
          If PosEx('C', LayotStr)<>0 Then
            FontStyleRec.Center:=True;
          If PosEx('S', LayotStr)<>0 Then
            FontStyleRec.StrikeThrough:=1;

          LayotStr:=ExtractSection(LayotItem);
          If LayotStr<>'' Then
            FontSize:=StrToIntEx(LayotStr);

          LayotStr:=ExtractSection(LayotItem);
          If LayotStr<>'' Then
            If PosEx('W', LayotStr)<>0 Then
              ToWrite:=True
            Else
              ToWrite:=False;
        end
        Else
          BookmarckName:=MsWord.ActiveDocument.BookMarks.Item(BookmarckNum+1).Name;

        StV:='';
        If FieldExists(BookmarckName, DCLQuery) Then
          If ToWrite Then
            StV:=MoneyToString(DCLQuery.FieldByName(BookmarckName).AsCurrency, True, False)
          Else
            StV:=Trim(DCLQuery.FieldByName(BookmarckName).AsString);

        WordInsert(MsWord, BookmarckName, StV, FontStyleRec.Bold, FontStyleRec.italic,
          FontStyleRec.StrikeThrough, FontStyleRec.Undeline, FontSize, FontStyleRec.Center);
      end;
      MsWord.Visible:=True;

      If Save Then
      begin
        StV:=AddToFileName(OutFileName, '_'+IntToStr(DocNum));
        If WordVer=9 Then
          MsWord.ActiveDocument.SaveAs(StV, EmptyParam, EmptyParam, EmptyParam, EmptyParam,
            EmptyParam, EmptyParam, EmptyParam, EmptyParam, EmptyParam) // Word 2000
        Else If WordVer>9 Then
          MsWord.ActiveDocument.SaveAs(StV, EmptyParam, EmptyParam, EmptyParam, EmptyParam,
            EmptyParam, EmptyParam, EmptyParam, EmptyParam, EmptyParam, EmptyParam, EmptyParam,
            EmptyParam, EmptyParam, EmptyParam, EmptyParam); // Word XP
      end;

      If Close then
      Begin
        CloseDocument(MsWord);
        WordClose(MsWord);
      End;

      DCLQuery.Next;
    end;
    end
    Else
      ShowErrorMessage( - 5004, FileName);

  FreeAndNil(Layot);
{$ENDIF}
end;

destructor TDCLOfficeReport.Destroy;
begin
  ///
end;

procedure TDCLOfficeReport.ReportExcel(ParamStr: String; Save, Close: Boolean);
var
  SQLStr, FileName, OutFileName, ColorStr, Ext, TemplateExt, Fields: String;
  EnableRowChColor, EnableColChColor: Boolean;
  RecRepNum, v1: Word;
  RowRColor, RowBColor, RowGColor, ColRColor, ColBColor, ColGColor: Integer;
  DCLQuery: TDCLDialogQuery;
  FillStrategy: TSheetFillStrategy;
begin
{$IFDEF MSWINDOWS}
  Ext:='xls';
  TemplateExt:='xlt';

  if FindParam('TemplateName=', ParamStr)<>'' then
  begin
    FileName:=BinStor.GetTemplateFile(FindParam('TemplateName=', ParamStr),
      FindParam('Template=', ParamStr), 'xlsx');
  end;

  FillStrategy:=sfsInsert;
  if FindParam('FillStrategy=', ParamStr)<>'' then
  begin
    if LowerCase(FindParam('FillStrategy=', ParamStr))='insert' then
    begin
      //FillStrategy:=sfsInsert;
    end else
    if LowerCase(FindParam('FillStrategy=', ParamStr))='replace' then
    begin
      FillStrategy:=sfsReplace;
    end;
  end;

  FileName:=FindParam('Template=', ParamStr);
  If not IsFullPath(FileName) then
    FileName:=AppConfigDir+FileName;
  If NoFileExt(FileName) then
  begin
    if FileExists(FileName+'.'+TemplateExt) then
    begin
      FileName:=FileName+'.'+TemplateExt;
    end
    else
    begin
      if FileExists(FileName+'.'+TemplateExt+'x') then
      begin
        TemplateExt:=TemplateExt+'x';
        FileName:=FileName+'.'+TemplateExt;
      end
      else
      begin
        if FileExists(FileName+'.'+Ext) then
        begin
          FileName:=FileName+'.'+Ext;
        end
        else
        begin
          if FileExists(FileName+'.'+TemplateExt+'x') then
          begin
            FileName:=FileName+'.'+TemplateExt;
          end;
        end;
      end;
    end;
  end;

  OutFileName:=FindParam('FileName=', ParamStr);
  if not IsFullPath(OutFileName) then
    OutFileName:=AppConfigDir+OutFileName;

  If BinStor.ErrorCode=0 Then
    If FileExists(FileName) Then
    begin
      try
        Excel:=CreateOleObject('Excel.Application');
        Excel.Visible:=False;
        WBk:=Excel.WorkBooks.Add(FileName);
      Except
        ShowErrorMessage( - 6000, '');
        Exit;
      end;
      try
        Excel.Sheets[1].Range['DATA'].Select;
      Except
        ShowErrorMessage( - 5002, '');
        Excel.Visible:=True;
        Exit;
      end;

      SQLStr:=FindParam('SQL=', ParamStr);
      If (SQLStr='')and Assigned(FDCLGrid) Then
        SQLStr:=FDCLGrid.Query.SQL.Text;

      Fields:=FindParam('FieldsSet=', ParamStr);

      if Fields<>'' then
      begin
        SQLStr:=ReplaceSQLFields(SQLStr, Fields);
      end;

      If Assigned(FDCLGrid) Then
        FDCLGrid.TranslateVal(SQLStr);

      DCLQuery:=TDCLDialogQuery.Create(nil);
      DCLQuery.Name:='OfficeReport2_'+IntToStr(UpTime);
      FDCLLogOn.SetDBName(DCLQuery);

      DCLQuery.SQL.Text:=SQLStr;
      try
        DCLQuery.Open;
      Except
        Excel.Visible:=True;
        ShowErrorMessage( - 1104, 'SQL='+SQLStr);
      end;
      DCLQuery.First;

      EnableRowChColor:=False;
      ColorStr:=FindParam('AlternationRowBackColor=', ParamStr);
      If ColorStr<>'' Then
      begin
        RowRColor:=HexToInt(Copy(ColorStr, 1, 2));
        RowBColor:=HexToInt(Copy(ColorStr, 3, 2));
        RowGColor:=HexToInt(Copy(ColorStr, 5, 2));
        EnableRowChColor:=True;
      end;

      EnableColChColor:=False;
      ColorStr:=FindParam('AlternationColBackColor=', ParamStr);
      If ColorStr<>'' Then
      begin
        ColRColor:=HexToInt(Copy(ColorStr, 1, 2));
        ColBColor:=HexToInt(Copy(ColorStr, 3, 2));
        ColGColor:=HexToInt(Copy(ColorStr, 5, 2));
        EnableColChColor:=True;
      end;

      RecRepNum:=0;
      case FillStrategy of
        sfsInsert:RecRepNum:=0;
        sfsReplace:RecRepNum:=1;
      end;
      While Not DCLQuery.Eof do
      begin
        if FillStrategy=sfsInsert then
          Excel.Sheets[1].Range['DATA'].Rows.Insert(-4121, 1);

        For v1:=0 to DCLQuery.FieldCount-1 do
        begin
          case DCLQuery.Fields[v1].DataType of
          ftString, ftMemo, ftFmtMemo, ftWideString, ftFixedWideChar,
            ftWideMemo:begin
            Excel.Sheets[1].Range['DATA'].Cells.Item[RecRepNum, v1+1].NumberFormat:=AnsiChar('@');
          end;
          ftSmallint, ftInteger, ftWord, ftAutoInc, ftLargeint, ftVariant,
            ftLongWord, ftShortint, ftBCD, ftByte:begin
            Excel.Sheets[1].Range['DATA'].Cells.Item[RecRepNum, v1+1].NumberFormat:=AnsiChar('#');
          end;
          ftFloat, ftExtended, ftSingle:begin
            Excel.Sheets[1].Range['DATA'].Cells.Item[RecRepNum, v1+1].NumberFormat:=AnsiChar('@');
          end;
          ftCurrency:begin
            Excel.Sheets[1].Range['DATA'].Cells.Item[RecRepNum, v1+1].NumberFormat:=AnsiString('# ##0.00');
          end;
          ftDate:begin
            Excel.Sheets[1].Range['DATA'].Cells.Item[RecRepNum, v1+1].NumberFormat:='ДД.ММ.ГГГГ';
          end;
          ftTime:begin
            Excel.Sheets[1].Range['DATA'].Cells.Item[RecRepNum, v1+1].NumberFormat:='ЧЧ:мм:сс';
          end;
          ftDateTime, ftTimeStamp, ftOraTimeStamp:begin
            Excel.Sheets[1].Range['DATA'].Cells.Item[RecRepNum, v1+1].NumberFormat:='ДД.ММ.ГГГГ ЧЧ:мм:сс';
          end;
          Else
            Excel.Sheets[1].Range['DATA'].Cells.Item[RecRepNum, v1+1].NumberFormat:='';
          end;

          Excel.Sheets[1].Range['DATA'].Cells.Item[RecRepNum, v1+1]:=
            Trim(DCLQuery.Fields[v1].AsString);

          If EnableRowChColor Then
            If RecRepNum Mod 2=0 Then
              Excel.Sheets[1].Range['DATA'].Cells.Item[RecRepNum, v1+1].Interior.Color:=
                RGB(RowRColor, RowGColor, RowBColor);
          If EnableColChColor Then
            If v1 Mod 2=0 Then
              Excel.Sheets[1].Range['DATA'].Cells.Item[RecRepNum, v1+1].Interior.Color:=
                RGB(ColRColor, ColGColor, ColBColor);
        end;
        if FillStrategy=sfsReplace then
          inc(RecRepNum);
        DCLQuery.Next;
      end;
      DCLQuery.Close;
      Excel.Visible:=True;

      FileName:=AddToFileName(OutFileName, '_Report');

      If Save Then
        ExcelSave(Excel, FileName);

      if Close then
        ExcelQuit(Excel);
    end
    Else
      ShowErrorMessage( - 5004, FileName);
{$ENDIF}
end;

// ==============================Reports===============================

procedure DeleteInString(var S: String; Index, Count: LongInt);
var
  T, t1: LongInt;
begin
  T:=Index;
  t1:=T;
  While (S[T]<>#10)and(T<=Length(S))and(T-t1<=Count-1) do
  begin
    inc(T);
  end;
  Delete(S, Index, T-t1);
end;

procedure FillCopy(Source: String; var Dest: String; Start, FillLength, ReplaceLen: Cardinal;
  Align: String);
var
  T, t1: Cardinal;
  tmpL: String;
begin
  DeleteInString(Dest, Start, ReplaceLen);
  tmpL:=Source;
  t1:=Length(Source);
  If PosEx('I', Align)<>0 Then
    DeleteInString(Dest, Start, FillLength);

  If PosEx('I', Align)=0 Then
  begin
    If PosEx('L', Align)<>0 Then
      If FillLength>t1 Then
        For T:=Length(tmpL)+1 to FillLength do
          tmpL:=tmpL+' ';
    If PosEx('R', Align)<>0 Then
      If FillLength>t1 Then
        For T:=Length(tmpL)+1 to FillLength do
          tmpL:=' '+tmpL;
    If PosEx('M', Align)<>0 Then
    begin
      If FillLength>t1 Then
      begin
        For T:=1 to (FillLength div 2)-(t1 div 2) do
          tmpL:=' '+tmpL;
        For T:=(FillLength div 2)-(t1 div 2)+t1+1 to FillLength do
          tmpL:=tmpL+' ';
      end;
    end;
  end;
  Insert(Copy(tmpL, 1, FillLength), Dest, Start);
end;

procedure TDCLTextReport.GrabValOnEdit(Sender: TObject);
begin
  If Length(VarsToControls)>(Sender as TEdit).Tag Then
    FDCLLogOn.Variables.Variables[VarsToControls[(Sender as TEdit).Tag]]:=(Sender as TEdit).Text;
end;

procedure TDCLTextReport.ValComboOnChange(Sender: TObject);
var
  Val: String;
begin
  If Length(VarsToControls)>(Sender as TDBLookupComboBox).Tag Then
  begin
    If (Sender as TDBLookupComboBox).KeyValue=null Then
      Val:=''
    Else
      Val:=(Sender as TDBLookupComboBox).KeyValue;

    FDCLLogOn.Variables.Variables[VarsToControls[(Sender as TDBLookupComboBox).Tag]]:=Val;
  end;
end;

procedure TDCLTextReport.GrabDialogButtonsOnClick(Sender: TObject);
begin
  If (Sender as TButton).Tag=0 Then
  begin
    GrabValueForm.Close;
    FDialogRes:=mrOk;
  end;
  If (Sender as TButton).Tag=1 Then
  begin
    GrabValueForm.Close;
    FDialogRes:=mrCancel;
  end;
end;

procedure TDCLTextReport.GrabDateOnChange(Sender: TObject);
begin
  If Length(VarsToControls)>(Sender as DateTimePicker).Tag Then
    FDCLLogOn.Variables.Variables[VarsToControls[(Sender as DateTimePicker).Tag]]:=
      DateToStr((Sender as DateTimePicker).Date);
end;

procedure TDCLTextReport.GrabValListOnChange(Sender: TObject);
begin
  If Length(VarsToControls)>(Sender as TComboBox).Tag Then
    FDCLLogOn.Variables.Variables[VarsToControls[(Sender as TComboBox).Tag]]:=
      (Sender as TComboBox).Text;
end;

constructor TDCLTextReport.InitReport(DCLLogOn: TDCLLogOn; DCLGrid: TDCLGrid; OPL: TStringList;
  ParamsSet: Cardinal; Mode: TNewQueryMode);
var
  RepParamsSet: TDCLDialogQuery;
  NewNew, GrabFormYes: Boolean;
  GrabValueEdit: TEdit;
  GrabDBLookupCombo: TDBLookupComboBox;
  GrabQuery: TDCLDialogQuery;
  GrabValueList: TComboBox;
  GrabDS: TDataSource;
  BtOk, BtCancel: TButton;
  ParamsCountList, ElementsTop: Word;
  GrabLabel: TDialogLabel;
  GrabDate: DateTimePicker;
  LocalVar1, LocalVar2, RecCount: Word;
  tmpSQL, tmpSQL1: String;

  procedure CreateGrabForm;
  begin
    If Not GrabFormYes Then
    begin
      GrabFormYes:=True;
      FDialogRes:=mrCancel;
      GrabValueForm:=TForm.Create(nil);
      GrabValueForm.Position:=poScreenCenter;
      GrabValueForm.BorderStyle:=bsSingle;
      GrabValueForm.BorderIcons:=[biSystemMenu, biMinimize];
      GrabValueForm.Caption:=GetDCLMessageString(msInputVulues);
    end;
  end;

begin
  InConsoleCodePage:=False;
  FSaved:=True;
  FDCLLogOn:=DCLLogOn;
  FDCLGrid:=DCLGrid;
  Body:=TStringList.Create;
  Report:=TStringList.Create;
  RepParams:=TStringList.Create;
  HeadLine:=TStringList.Create;
  Futer:=TStringList.Create;
  Template:=TStringList.Create;
  GlobalSQL:=TStringList.Create;
  InitSkrypts:=TStringList.Create;
  EndSkrypts:=TStringList.Create;

  FDialogRes:=mrOk;
  GrabFormYes:=False;

  InitSkrypts:=CopyStrings('[INIT REP]', '[END INIT]', OPL);
  GlobalSQL:=CopyStrings('[GLOBALQUERY]', '[END GLOBALQUERY]', OPL);
  RepParams:=CopyStrings('[PARAMS]', '[END PARAMS]', OPL);
  HeadLine:=CopyStrings('[HEADLINE]', '[END HEADLINE]', OPL);
  Template:=CopyStrings('[BODY]', '[END BODY]', OPL);
  Futer:=CopyStrings('[FUTER]', '[END FUTER]', OPL);
  EndSkrypts:=CopyStrings('[CLOSE REP]', '[END CLOSE]', OPL);

  // ParamsSet
  If ParamsSet<>0 Then
  begin
    RepParamsSet:=TDCLDialogQuery.Create(nil);
    RepParamsSet.Name:='RepParamsSet_'+IntToStr(UpTime);
    FDCLLogOn.SetDBName(RepParamsSet);
    RepParamsSet.SQL.Text:=FDCLLogOn.GetRolesQueryText(qtCount, ' s.'+GPT.ParentFlgField+'='+
        IntToStr(ParamsSet));
    RepParamsSet.Open;
    RecCount:=RepParamsSet.Fields[0].AsInteger;
    If RecCount>0 Then
    begin
      RepParamsSet.Close;
      RepParamsSet.SQL.Text:=FDCLLogOn.GetRolesQueryText(qtSelect, ' s.'+GPT.ParentFlgField+'='+
          IntToStr(ParamsSet));
      RepParamsSet.Open;

      While Not RepParamsSet.Eof do
      begin
        RepParams.Append(Trim(RepParamsSet.FieldByName(GPT.DCLNameField).AsString));
        RepParams.Append(Trim(RepParamsSet.FieldByName(GPT.DCLTextField).AsString));
        RepParamsSet.Next;
      end;
    end;
    RepParamsSet.Close;
    FreeAndNil(RepParamsSet);
  end;

  ElementsTop:=BeginStepTop;
  If InitSkrypts.Count>0 Then
    For LocalVar1:=0 to InitSkrypts.Count-1 do
    begin
      If PosEx('DeclareVariable=', InitSkrypts[LocalVar1])<>0 Then
      begin
        FDCLLogOn.Variables.NewVariableWithTest(FindParam('DeclareVariable=', InitSkrypts[LocalVar1]));
      end;

      If PosEx('GrabValueList=', InitSkrypts[LocalVar1])<>0 Then
      begin
        CreateGrabForm;
        GrabLabel:=TLabel.Create(GrabValueForm);
        GrabLabel.Parent:=GrabValueForm;
        GrabLabel.Name:='GrabLabel_'+IntToStr(LocalVar1);
        GrabLabel.Top:=ElementsTop-14;
        GrabLabel.Left:=8;
        tmpSQL:=FindParam('Label=', InitSkrypts[LocalVar1]);
        If tmpSQL<>'' Then
          GrabLabel.Caption:=tmpSQL
        Else
          GrabLabel.Caption:=FindParam('GrabValueList=', InitSkrypts[LocalVar1]);

        tmpSQL:=FindParam('GrabValueList=', InitSkrypts[LocalVar1]);
        FDCLLogOn.Variables.NewVariableWithTest(tmpSQL);
        GrabValueList:=TComboBox.Create(GrabValueForm);
        GrabValueList.Parent:=GrabValueForm;
        GrabValueList.Name:='GrabValList_'+IntToStr(LocalVar1);
        GrabValueList.Text:='';
        GrabValueList.Tag:=SetVarToControl(tmpSQL);

        tmpSQL:=FindParam('ListValues=', InitSkrypts[LocalVar1]);
        ParamsCountList:=ParamsCount(tmpSQL);
        For LocalVar2:=1 to ParamsCountList do
          GrabValueList.Items.Append(SortParams(tmpSQL, LocalVar2));

        GrabValueList.Top:=ElementsTop;
        GrabValueList.Left:=8;
        GrabValueList.Width:=GrabComponentsWidth;
        GrabValueList.OnChange:=GrabValListOnChange;
        tmpSQL:=Trim(FindParam('DefaultValue=', InitSkrypts[LocalVar1]));
        RePlaseVariables(tmpSQL);
        If tmpSQL<>'' Then
          GrabValueList.Text:=tmpSQL;
        inc(ElementsTop, EditTopStep);
      end;

      If PosEx('GrabValue=', InitSkrypts[LocalVar1])<>0 Then
      begin
        CreateGrabForm;
        GrabLabel:=TDialogLabel.Create(GrabValueForm);
        GrabLabel.Parent:=GrabValueForm;
        GrabLabel.Name:='GrabLabel_'+IntToStr(LocalVar1);
        GrabLabel.Top:=ElementsTop-14;
        GrabLabel.Left:=8;
        tmpSQL:=FindParam('Label=', InitSkrypts[LocalVar1]);
        If tmpSQL<>'' Then
          GrabLabel.Caption:=tmpSQL
        Else
          GrabLabel.Caption:=FindParam('GrabValue=', InitSkrypts[LocalVar1]);

        GrabValueEdit:=TEdit.Create(GrabValueForm);
        GrabValueEdit.Parent:=GrabValueForm;
        GrabValueEdit.Name:='GrabValEdit'+IntToStr(LocalVar1);
        GrabValueEdit.Text:='';
        GrabValueEdit.Tag:=SetVarToControl(FindParam('GrabValue=', InitSkrypts[LocalVar1]));
        GrabValueEdit.OnChange:=GrabValOnEdit;
        tmpSQL:=Trim(FindParam('Long=', InitSkrypts[LocalVar1]));
        If tmpSQL<>'' Then
          GrabValueEdit.MaxLength:=StrToIntEx(tmpSQL);

        tmpSQL:=Trim(FindParam('DefaultValue=', InitSkrypts[LocalVar1]));
        RePlaseVariables(tmpSQL);
        If tmpSQL<>'' Then
          GrabValueEdit.Text:=tmpSQL;

        GrabValueEdit.Top:=ElementsTop;
        GrabValueEdit.Left:=8;
        GrabValueEdit.Width:=GrabComponentsWidth;

        inc(ElementsTop, EditTopStep);
      end;

      If PosEx('GrabValueFromBase=', InitSkrypts[LocalVar1])<>0 Then
      begin
        CreateGrabForm;
        GrabLabel:=TDialogLabel.Create(GrabValueForm);
        GrabLabel.Parent:=GrabValueForm;
        GrabLabel.Name:='GrabLabel_'+IntToStr(LocalVar1);
        GrabLabel.Left:=8;
        GrabLabel.Top:=ElementsTop-14;
        tmpSQL:=FindParam('Label=', InitSkrypts[LocalVar1]);
        If tmpSQL<>'' Then
          GrabLabel.Caption:=tmpSQL
        Else
          GrabLabel.Caption:=FindParam('GrabValueFromBase=', InitSkrypts[LocalVar1]);

        GrabDBLookupCombo:=TDBLookupComboBox.Create(GrabValueForm);
        GrabDBLookupCombo.Parent:=GrabValueForm;
        GrabDBLookupCombo.Name:='GrabValCombo'+IntToStr(LocalVar1);
        GrabDBLookupCombo.Top:=ElementsTop;
        GrabDBLookupCombo.Left:=8;
        GrabDBLookupCombo.Width:=GrabComponentsWidth;
        GrabDBLookupCombo.Tag:=SetVarToControl(FindParam('GrabValueFromBase=',
            InitSkrypts[LocalVar1]));

        GrabQuery:=TDCLDialogQuery.Create(nil);
        GrabQuery.Name:='RepGabQ_'+IntToStr(UpTime);
        tmpSQL1:=FindParam('SQL=', InitSkrypts[LocalVar1]);
        RePlaseVariables(tmpSQL1);
        GrabQuery.SQL.Text:=tmpSQL1;

        FDCLLogOn.SetDBName(GrabQuery);
        try
          GrabQuery.Open;
          GrabQuery.Last;
          GrabQuery.First;
          GrabDS:=TDataSource.Create(nil);
          GrabDS.DataSet:=GrabQuery;
          GrabDBLookupCombo.ListSource:=GrabDS;
          GrabDBLookupCombo.ListField:=GrabQuery.Fields[0].FieldName;
          If GrabQuery.FieldCount=1 Then
            GrabDBLookupCombo.KeyField:=GrabQuery.Fields[0].FieldName
          Else
            GrabDBLookupCombo.KeyField:=GrabQuery.Fields[1].FieldName;

{$IFDEF FPC}
          GrabDBLookupCombo.OnSelect:=ValComboOnChange;
{$ELSE}
          GrabDBLookupCombo.OnClick:=ValComboOnChange;
{$ENDIF}
        Except
          ShowErrorMessage( - 1108, 'SQL='+tmpSQL1);
        end;

        inc(ElementsTop, EditTopStep);
      end;

      If PosEx('GrabDate=', InitSkrypts[LocalVar1])<>0 Then
      begin
        CreateGrabForm;
        GrabLabel:=TDialogLabel.Create(GrabValueForm);
        GrabLabel.Parent:=GrabValueForm;
        GrabLabel.Name:='GrabLabel_'+IntToStr(LocalVar1);
        GrabLabel.Left:=8;
        GrabLabel.Top:=ElementsTop-14;
        tmpSQL:=FindParam('Label=', InitSkrypts[LocalVar1]);
        If tmpSQL<>'' Then
          GrabLabel.Caption:=tmpSQL
        Else
          GrabLabel.Caption:=FindParam('GrabDate=', InitSkrypts[LocalVar1]);

        GrabDate:=DateTimePicker.Create(GrabValueForm);
        GrabDate.Parent:=GrabValueForm;
        GrabDate.Name:='GrabDate'+IntToStr(LocalVar1);
        GrabDate.Date:=Date;
        GrabDate.Top:=ElementsTop;
        GrabDate.Left:=8;
        GrabDate.Width:=GrabComponentsWidth;
        GrabDate.Tag:=SetVarToControl(FindParam('GrabDate=', InitSkrypts[LocalVar1]));
        FDCLLogOn.Variables.NewVariable(FindParam('GrabDate=', InitSkrypts[LocalVar1]),
          DateToStr(GrabDate.Date));

        tmpSQL:=Trim(FindParam('DefaultValue=', InitSkrypts[LocalVar1]));
        RePlaseVariables(tmpSQL);
        If tmpSQL<>'' Then
          GrabDate.Date:=StrToDate(tmpSQL);

        GrabDate.OnChange:=GrabDateOnChange;
        inc(ElementsTop, EditTopStep);
      end;
    end;

  If GrabFormYes Then
  begin
    GrabValueForm.ClientHeight:=ElementsTop+BeginStepTop+ButtonPanelHeight;
    BtOk:=TButton.Create(GrabValueForm);
    BtOk.Parent:=GrabValueForm;
    BtOk.Tag:=0;
    BtOk.Caption:='OK';
    BtOk.Default:=True;
    BtCancel:=TButton.Create(GrabValueForm);
    BtCancel.Parent:=GrabValueForm;
    BtCancel.Tag:=1;
    BtCancel.Caption:='Cancel';
    BtCancel.Cancel:=True;
    BtOk.OnClick:=GrabDialogButtonsOnClick;
    BtCancel.OnClick:=GrabDialogButtonsOnClick;

    BtOk.Top:=GrabValueForm.ClientHeight-35;
    BtCancel.Top:=GrabValueForm.ClientHeight-35;
    BtOk.Left:=10;
    BtCancel.Left:=95;
    GrabValueForm.ShowModal;
  end;

  If GrabFormYes Then
  begin
    GrabValueForm.Release;
    GrabValueForm:=nil;
  end;

  If DialogRes=mrCancel Then
    Exit;

  GrabFormYes:=False;

  NewNew:=False;
  If Mode=nqmNew Then
  begin
    NewNew:=True
  end
  Else
    NewNew:=Not Assigned(DCLGrid);

  If NewNew Then
  begin
    FReportQuery:=TReportQuery.Create(nil);
    FDCLLogOn.SetDBName(FReportQuery);
  end;

  If GlobalSQL.Count<>0 Then
  begin
    tmpSQL:=GlobalSQL.Text;
    FDCLLogOn.TranslateVal(tmpSQL);
    FReportQuery.Close;
    FReportQuery.SQL.Text:=tmpSQL;

    Screen.Cursor:=crSQLWait;
    try
      FReportQuery.Open;
      If GPT.DebugOn Then
        DebugProc('Report SQL query: '+tmpSQL);
    Except
      ShowErrorMessage( - 1106, 'SQL='+tmpSQL);
    end;
    Screen.Cursor:=crDefault;
  end;
end;

destructor TDCLTextReport.Destroy;
begin
  inherited Destroy;
end;

procedure TDCLTextReport.CloseReport(FileName: String);
var
  i: Word;
begin
  If EndSkrypts.Count>0 Then
    For i:=0 to EndSkrypts.Count-1 do
    begin
      If PosEx('DisposeVariable=', EndSkrypts[i])<>0 Then
        FDCLLogOn.Variables.FreeVariable(FindParam('DisposeVariable=', EndSkrypts[i]));
    end;

  If Not FSaved Then
    SaveReport(FileName);

  FreeAndNil(Body);
  FreeAndNil(Report);
  FreeAndNil(RepParams);
  FreeAndNil(HeadLine);
  FreeAndNil(Futer);
  FreeAndNil(Template);
  FreeAndNil(GlobalSQL);
  FreeAndNil(EndSkrypts);
  FreeAndNil(InitSkrypts);
end;

function TDCLTextReport.SaveReport(FileName: String): String;
var
  i: Integer;
begin
  If DialogRes=mrCancel Then
    Exit;

  If DefaultSystemEncoding=EncodingUTF8 Then
    Report.Append(UTF8BOM)
  Else If DefaultSystemEncoding='utf16' Then
    Report.Append(UTF16LEBOM);

  Report.AddStrings(HeadLine);
  Report.AddStrings(Body);
  Report.AddStrings(Futer);

  If FileName='' Then
    FileName:='Report.txt';
  If Not IsFullPAth(FileName) Then
    FileName:=IncludeTrailingPathDelimiter(AppConfigDir)+FileName;

  RePlaseVariables(FileName);

  i:=Length(FileName);
  While i<>0 do
  begin
    If (FileName[i]='"')or(FileName[i]=CrossDelim)or(FileName[i]='*')or(FileName[i]='?')or
      (FileName[i]='>')or(FileName[i]='<') Then
      Delete(FileName, i, 1);
    Dec(i);
  end;

  If InConsoleCodePage then
    Report.Text:=Transcode(tdtDOS, Report.Text);
  Report.SaveToFile(FileName);
  Result:=FileName;
  FSaved:=True;

  Body.Clear;
  Report.Clear;
end;

function TDCLTextReport.SetVarToControl(VarName: String): Integer;
var
  l: Integer;
begin
  l:=Length(VarsToControls);
  SetLength(VarsToControls, l+1);
  VarsToControls[l]:=VarName;
  Result:=l;
end;

function TDCLTextReport.TranslateRepParams(ParamName: String): String;
var
  ParamFieldNum: Byte;
  ParamNum: Word;
  ResultString, ReturnField, tmpSQL1: String;
  ParamsQuery: TReportQuery;
begin
  ParamNum:=0;
  While (UpperCase(RepParams[ParamNum])<>UpperCase(Trim(ParamName)))and
    (ParamNum+1<>RepParams.Count) do
    inc(ParamNum);
  If FindParam('SQL=', RepParams[ParamNum+1])<>'' Then
  begin
    ParamsQuery:=TReportQuery.Create(nil);
    FDCLLogOn.SetDBName(ParamsQuery);
    tmpSQL1:=FindParam('SQL=', RepParams[ParamNum+1]);
    RePlaseVariables(tmpSQL1);
    ParamsQuery.SQL.Text:=tmpSQL1;
    try
      ParamsQuery.Open;
      If GPT.DebugOn Then
        DebugProc('Report param SQL query: '+tmpSQL1);
    Except
      ShowErrorMessage( - 1109, RepParams[ParamNum]+' / SQL='+tmpSQL1);
    end;

    ReturnField:=FindParam('ReturnField=', RepParams[ParamNum+1]);
    DeleteNonPrintSimb(ReturnField);
    ResultString:='';
    If ReturnField='' Then
    begin
      While Not ParamsQuery.Eof do
      begin
        tmpSQL1:='';
        For ParamFieldNum:=0 to ParamsQuery.FieldCount-1 do
        begin
          tmpSQL1:=tmpSQL1+TrimRight(ParamsQuery.Fields[ParamFieldNum].AsString);
        end;

        ResultString:=ResultString+tmpSQL1+#10;
        ParamsQuery.Next;
      end;
    end
    Else
    begin
      While Not ParamsQuery.Eof do
      begin
        ResultString:=ResultString+TrimRight(ParamsQuery.FieldByName(ReturnField).AsString)+#10;
        ParamsQuery.Next;
      end;
    end;

    ResultString:=Copy(ResultString, 1, Length(ResultString)-1);
    RePlaseVariables(ResultString);

    ParamsQuery.Close;
    FreeAndNil(ParamsQuery);
  end
  Else
  begin
    ResultString:=FindParam('ReturnValue=', RepParams[ParamNum+1]);
    DeleteNonPrintSimb(ResultString);
    RePlaseVariables(ResultString);
  end;
  Result:=ResultString;
end;

procedure TDCLTextReport.ReplaseRepParams(var ReplaseText: TStringList);
var
  ParamValue, TmpStr, BodyText: String;
  InsMode:Boolean;
  ParamFill, ParamLen, CuteLen, k, k1, k3, DopLength, StringsCounter, StringNum, StartSel: Integer;
begin
  BodyText:=ReplaseText.Text;
  RePlaseVariables(BodyText);
  StringNum:=0;
  If (RepParams.Count div 2)>0 Then
  begin
    For StringsCounter:=0 to (RepParams.Count div 2)-1 do
    begin
      InsMode:=False;
      StartSel:=PosEx(RepParams[StringNum], BodyText);
      While StartSel<>0 do
      begin
        If StartSel<>0 Then
          ParamValue:=TranslateRepParams(RepParams[StringNum]);

        k:=StartSel+Length(RepParams[StringNum]);
        k1:=k;
        ParamFill:=0;
        DopLength:=0;
        If BodyText<>'' Then
          If BodyText[k]='(' Then
          begin
            While BodyText[k]<>')' do
              inc(k);
            TmpStr:=Copy(BodyText, k1+1, k-k1-1);
            ParamFill:=StrToIntEx(TmpStr);
            ParamLen:=ParamFill;
            DopLength:=k-k1+1;
          end
          else
            ParamLen:=Length(ParamValue);

        If StartSel<>0 Then
          If ParamFill=0 Then
            ParamFill:=Length(ParamValue);
        If ParamFill>Length(ParamValue) then
        Begin
          ParamFill:=ParamFill-Length(ParamValue);
        End;

        If PosEx('i', TmpStr)<>0 Then
        begin
          InsMode:=True;
          Delete(BodyText, StartSel, Length(RepParams[StringNum])+DopLength);
          CuteLen:=Length(RepParams[StringNum])+DopLength;
        end
        Else
        begin
          If PosEx('r', TmpStr)<>0 Then
          begin
            If ParamFill>0 Then
              For k:=1 to ParamFill do
                ParamValue:=' '+ParamValue;
          end
          Else If PosEx('m', TmpStr)<>0 Then
          begin
            If ParamFill>0 Then
            begin
              k3:=Length(ParamValue);
              For k:=1 to (ParamFill div 2)-(k3 div 2) do
                ParamValue:=' '+ParamValue;
              For k:=(ParamFill div 2)-(k3 div 2)+k3+1 to ParamFill do
                ParamValue:=ParamValue+' ';
            end;
          end
          Else
          begin
            If ParamFill>0 Then
              For k:=1 to ParamFill do
                ParamValue:=ParamValue+' ';
          end;
          Delete(BodyText, StartSel, Length(RepParams[StringNum])+DopLength);
        end;

        If not InsMode then
          Insert(Copy(ParamValue, 1, ParamLen), BodyText, StartSel)
        Else
        Begin
          If CuteLen>=ParamFill then
          Begin
            For k:=1 to CuteLen-ParamFill do
              ParamValue:=ParamValue+' ';
            Insert(ParamValue, BodyText, StartSel);
          End
          Else
          Begin
            DeleteInString(BodyText, StartSel, ParamFill-CuteLen);
            Insert(ParamValue, BodyText, StartSel);
          End;
        End;
        StartSel:=PosEx(RepParams[StringNum], BodyText);
      end;

      Inc(StringNum, 2);
    end;
  end;

  ReplaseText.Text:=BodyText;
end;

procedure TDCLTextReport.RePlaseVariables(var VarsSet: String);
begin
  If Assigned(FDCLGrid) Then
    FDCLGrid.TranslateVal(VarsSet);
  FDCLLogOn.TranslateVal(VarsSet);
end;

procedure TDCLTextReport.PrintigReport;
var
  TmpStr, BodyText, BodyText1: String;
  StartPos, LengthParam, DelLen: Cardinal;
  FieldsCounter, NameLength, StartSel, FFactor: Word;
  Alig: String;
begin
  If DialogRes=mrCancel Then
    Exit;
  FSaved:=False;
  BodyText:=Template.Text;

  If Not FReportQuery.IsEmpty Then
  begin
    For FieldsCounter:=0 to FReportQuery.FieldCount-1 do
    begin
      NameLength:=Length(FReportQuery.Fields[FieldsCounter].FieldName);

      StartSel:=PosEx(ParamPrefix+FReportQuery.Fields[FieldsCounter].FieldName, BodyText);
      While StartSel<>0 do
      begin
        Alig:='L';
        If StartSel<>0 Then
        begin
          If BodyText[StartSel+NameLength+1]='(' Then
          begin
            StartPos:=StartSel+NameLength+Length(ParamPrefix);
            While BodyText[StartPos]<>')' do
              inc(StartPos);
            TmpStr:=Copy(BodyText, StartSel+NameLength+2, StartPos-StartSel-NameLength-2);
            LengthParam:=StrToIntEx(TmpStr);
            If PosEx('R', TmpStr)=0 Then
              If PosEx('M', TmpStr)=0 Then
                If PosEx('L', TmpStr)=0 Then
                  If PosEx('I', TmpStr)=0 Then
                    TmpStr:='L';

            Alig:=TmpStr;
            DelLen:=StartPos-StartSel+1;

            If LengthParam=0 Then
              LengthParam:=Length(TrimRight(FReportQuery.Fields[FieldsCounter].AsString));
          end
          Else
          begin
            DelLen:=NameLength+Length(ParamPrefix);
            LengthParam:=Length(TrimRight(FReportQuery.Fields[FieldsCounter].AsString));
          end;

          FillCopy(TrimRight(FReportQuery.Fields[FieldsCounter].AsString), BodyText, StartSel,
            LengthParam, DelLen, Alig);

          StartSel:=PosEx(ParamPrefix+FReportQuery.Fields[FieldsCounter].FieldName, BodyText);
        end;
      end;
    end;
    BodyText1:=Copy(BodyText, 1, Length(BodyText)-Length(CR));
  end
  Else
    BodyText1:='';

  FFactor:=0;
  TranslateProc(BodyText1, FFactor, nil);
  Body.Append(BodyText1);
end;

procedure TDCLTextReport.OpenReport(FileName: String; ViewMode: TReportViewMode);
// 0-Normal 1 Record;  1-All Records;  2-Bookmarks; 3-All records (Num)
var
  BookMarks, Nubers: Cardinal;
begin
  If DialogRes=mrCancel Then
    Exit;
  If Not FReportQuery.IsEmpty Then
  begin
    Case ViewMode of
    rvmOneRecord:
    PrintigReport;
    rvmAllDS:
    begin
      FReportQuery.First;
      While Not FReportQuery.Eof do
      begin
        PrintigReport;
        FReportQuery.Next;
      end;
    end;
    rvmGrid:
    begin
      If Assigned(FDCLGrid) Then
        If FDCLGrid.DisplayMode in TDataGrid Then
          If FDCLGrid.Grid.SelectedRows.Count>0 Then
          begin
            For BookMarks:=0 to FDCLGrid.Grid.SelectedRows.Count-1 do
            begin
              FReportQuery.GoToBookmark(TBookmark(FDCLGrid.Grid.SelectedRows[BookMarks]));
              PrintigReport;
            end;
          end
          Else
            PrintigReport;
    end;
    rvmMultitRecordReport:
    begin
      If FileName='' Then
        FileName:='Report';
      FReportQuery.First;
      Nubers:=1;
      While Not FReportQuery.Eof do
      begin
        PrintigReport;
        SaveReport(FileName+'-'+IntToStr(Nubers)+'.txt');
        inc(Nubers);
        FReportQuery.Next;
      end;
    end;
    rvmBookmarcks:
    begin
      If Assigned(FDCLGrid) Then
        If FDCLGrid.DisplayMode in TDataGrid Then
          If FDCLGrid.Grid.SelectedRows.Count>0 Then
          begin
            Nubers:=1;
            For BookMarks:=0 to FDCLGrid.Grid.SelectedRows.Count-1 do
            begin
              FReportQuery.GoToBookmark(TBookmark(FDCLGrid.Grid.SelectedRows[BookMarks]));
              PrintigReport;
              SaveReport(FileName+'-'+IntToStr(Nubers)+'.txt');
              inc(Nubers);
            end;
          end;
    end;
    end;
  end
  Else
    PrintigReport;

  ReplaseRepParams(HeadLine);
  ReplaseRepParams(Futer);
end;
// =========================================Reports==============================

{ TDCLOfficeReport }

constructor TDCLOfficeReport.Create(DCLLogOn: TDCLLogOn; DCLGrid: TDCLGrid);
begin
  BinStor:=TDCLBinStore.Create(DCLLogOn);
  FDCLLogOn:=DCLLogOn;
  FDCLGrid:=DCLGrid;
  OfficeDocumentFormat:=GPT.OfficeDocumentFormat;
  OfficeFormat:=GPT.OfficeFormat;
end;

{ TDCLBinStore }

procedure TDCLBinStore.ClearData(DataName: String);
begin
  inherited ClearData(DataName);
end;

destructor TDCLBinStore.Destroy;
begin
  inherited Destroy;
end;

procedure TDCLBinStore.CompressData(DataName: String);
begin
  inherited CompressData(DataName, '');
end;

constructor TDCLBinStore.Create(DCLLogOn: TDCLLogOn);
begin
  inherited Create(DCLLogOn, ftByName, GPT.TemplatesTable, GPT.TemplatesKeyField,
    GPT.TemplatesNameField, GPT.TemplatesDataField);
end;

procedure TDCLBinStore.DeCompressData(DataName: String);
begin
  inherited DeCompressData(DataName, '');
end;

function TDCLBinStore.MD5(DataName: String): String;
begin
  Result:=inherited MD5(DataName);
end;

procedure TDCLBinStore.DeleteData(DataName: String);
begin
  inherited DeleteData(DataName);
end;

function TDCLBinStore.GetTemplateFile(Template, FileName, Ext: String): String;
var
  TempFile: String;
begin
  FErrorCode:=0;
  FDCLLogOn.TranslateVal(Template);

  If Template<>'' Then
  begin
    If IsDataExist(Template) Then
    begin
      If FileName<>'' Then
      begin
        If IsFullPAth(FileName) Then
          TempFile:=FakeFileExt(FileName, Ext)
        Else
          TempFile:=IncludeTrailingPathDelimiter(AppConfigDir)+FakeFileExt(FileName, Ext);
      end
      Else
        TempFile:=IncludeTrailingPathDelimiter(AppConfigDir)+GetTempFileName(Ext);

      GetData(Template).SaveToFile(TempFile);
    end
    Else
    begin
      ShowErrorMessage( - 5004, Template);
      FErrorCode:=4;
      TempFile:='';
    end;
  end;
  Result:=TempFile;
end;

procedure TDCLBinStore.SaveToFile(FileName, DataName: String);
begin
  inherited SaveToFile(FileName, DataName);
end;

procedure TDCLBinStore.StoreFromFile(FileName, DataName: String; Compress: Boolean);
begin
  inherited StoreFromFile(FileName, DataName, '', Compress);
end;

procedure DisconnectDB;
begin
  If Assigned(DCLMainLogOn) Then
    If DCLMainLogOn.Connected Then
    begin
      DCLMainLogOn.Disconnect;
    end;
end;

procedure EndDCL;
begin
  If Assigned(Logger) Then
    FreeAndNil(Logger);

  If Assigned(DCLMainLogOn) Then
  begin
    DCLMainLogOn.CloseAllForms;
//    DisconnectDB;
    FreeAndNil(DCLMainLogOn);
  end;

{$IFDEF ADO}
  CoUninitialize;
{$ENDIF}
  If GPT.DebugOn and GPT.DebugMesseges Then
    ExecApp('"'+GPT.Viewer+'" "'+IncludeTrailingPathDelimiter(AppConfigDir)+'DebugApp.txt"');
end;

procedure InitDCL(DBLogOn: TDBLogOn);
var
  v1: Integer;
  ShowLogOnForm: Boolean;
  ParamsQuery, RolesQuery1: TDCLDialogQuery;
  Params: TStringList;
{$IFDEF MSWINDOWS}
  MemHnd: HWND;
{$ENDIF}
begin
  ShowFormPanel:=True;
  Path:=ExtractFilePath(Application.ExeName);
  SetCurrentDir(Path);
  InitLangEnv;

  InitGetAppConfigDir;
  DCLMainLogOn:=TDCLLogOn.Create(DBLogOn);
  DCLMainLogOn.RoleOK:=lsNotNeed;
  LoadLangRes(LangName, Path);

  For v1:=1 to ParamCount do
    If ParamStr(v1)='/debug' Then
      GPT.DebugOn:=True;
  DebugProc('DCL version : '+Version);
  ConnectErrorCode:=0;
  If GPT.IniFileName='' Then
    GPT.IniFileName:=Path+'DCL.ini';
  DebugProc('Find ini file: '+GPT.IniFileName);

  {$IFDEF IBALL}
  GPT.IBAll:=True;
  {$ELSE}
  GPT.IBAll:=False;
  {$ENDIF}
  GPT.OldStyle:=False;
  GPT.DebugMesseges:=False;
  GPT.OneCopy:=False;
  GPT.ExitCnf:=False;
  GPT.UseMessages:=True;
  ScriptRunCreated:=False;
  GPT.DebugOn:=False;
  GPT.DialogsSettings:=True;
  GPT.Port:=0;
  {$IFDEF ZEOS}
  GPT.DBType:=DefaultDBType;
  {$ENDIF}
  GPT.UserLogging:=False;
  GPT.UserLoggingHistory:=False;
  GPT.OfficeFormat:=ofMSO;
  GPT.OfficeDocumentFormat:=odfMSO2007;

  GPT.TimeFormat:=DefaultTimeFormat;
  GPT.DateFormat:=DefaultDateFormat;
  GPT.DateSeparator:=DefaultDateSeparator;
  GPT.TimeSeparator:=DefaultTimeSeparator;
{$IFDEF MSWINDOWS}
  SysUtils.GetFormatSettings;
{$ENDIF}
{$IFDEF FPC}
  DefaultSystemEncoding:=GetDefaultTextEncoding;
{$ELSE}
  DefaultSystemEncoding:='cp'+IntToStr(GetACP);
{$ENDIF}
  Params:=TStringList.Create;
  If ParamStr(1)<>'' Then
    If FileExists(ParamStr(1)) Then
      GPT.IniFileName:=ParamStr(1)
    Else
    begin
      For v1:=1 to ParamCount do
      Begin
        If PosEx('-ini', ParamStr(v1))<>0 Then
          GPT.IniFileName:=ParamStr(v1+1);
        If PosEx('-user', ParamStr(v1))<>0 Then
          GPT.DCLUserName:=ParamStr(v1+1);
        If PosEx('-password', ParamStr(v1))<>0 Then
          GPT.EnterPass:=ParamStr(v1+1);
        If PosEx('-scr', ParamStr(v1))<>0 Then
          GPT.LaunchScrFile:=ParamStr(v1+1);
        If PosEx('-dialog', ParamStr(v1))<>0 Then
          GPT.LaunchForm:=ParamStr(v1+1);
      End;
    end;

  If {$IFNDEF EMBEDDED}FileExists(GPT.IniFileName){$ELSE}True{$ENDIF} Then
  Begin
{$IFNDEF EMBEDDED}
    try
      DebugProc('Open ini file: '+GPT.IniFileName);
      Params.LoadFromFile(GPT.IniFileName);
      DebugProc('Open : OK');
    Except
      DebugProc('Open ini file : Fail');
    end;
{$ENDIF}
    GetParamsStructure(Params);

    LoadLangRes(LangName, Path);

{$IFNDEF EMBEDDED}
    If ParamCount>0 Then
    begin
      For v1:=1 to ParamCount do
      Begin
        If PosEx('-ini', ParamStr(v1))<>0 Then
          GPT.IniFileName:=ParamStr(v1+1);
        If PosEx('-user', ParamStr(v1))<>0 Then
          GPT.DCLUserName:=ParamStr(v1+1);
        If PosEx('-password', ParamStr(v1))<>0 Then
          GPT.EnterPass:=ParamStr(v1+1);
      End;
    end;
{$ENDIF}

    Logger:=TLogging.Create(IncludeTrailingPathDelimiter(AppConfigDir)+'DebugApp.txt', GPT.DebugOn);
    Logger.Active:=GPT.DebugOn;

    If GPT.StringTypeChar='' Then
      GPT.StringTypeChar:='''';

{$IFDEF FPC}
{$IFDEF UNIX}
    FormatSettings.DateSeparator:=GPT.DateSeparator;
    FormatSettings.ShortDateFormat:=GPT.DateFormat;
    FormatSettings.LongTimeFormat:=GPT.TimeFormat;
    FormatSettings.TimeSeparator:=GPT.TimeSeparator;
{$ENDIF}
{$ENDIF}
    If GPT.Viewer='' Then
{$IFDEF MSWINDOWS}
      GPT.Viewer:='notepad';
{$ELSE}
      GPT.Viewer:='pluma';
{$ENDIF}

    TransParams:=True;

    ConnectErrorCode:=DCLMainLogOn.ConnectDB;
    If ConnectErrorCode=0 Then
    begin
{$IFNDEF EMBEDDED}
      GPT.NoParamsTable:=Not DCLMainLogOn.TableExists(GPT.GPTTableName);
      If Not GPT.NoParamsTable Then
      begin
        ParamsQuery:=TDCLDialogQuery.Create(nil);
        ParamsQuery.Name:='InitDCLParams_'+IntToStr(UpTime);
        ParamsQuery.SQL.Text:='select '+GPT.GPTNameField+', '+GPT.GPTValueField+' from '+
          GPT.GPTTableName;
        DCLMainLogOn.SetDBName(ParamsQuery);
        try
          try
            ParamsQuery.Open;
          Except
            GPT.NoParamsTable:=False;
          end;
          ParamsQuery.First;
          Params.Clear;
          While Not ParamsQuery.Eof do
          begin
            Params.Insert(0, ParamsQuery.FieldByName(GPT.GPTNameField).AsString+'='+
                ParamsQuery.FieldByName(GPT.GPTValueField).AsString);
            ParamsQuery.Next;
          end;
          ParamsQuery.Close;
          FreeAndNil(ParamsQuery);
          GetParamsStructure(Params);
        Except
          GPT.NoParamsTable:=False;
        end;
      end;

      GPT.RolesMenuTable:=RolesMenuTable;
{$ENDIF}
      FreeAndNil(Params);

      DCLMainLogOn.WriteBaseUID;

      GPT.TimeStampFormat:=GPT.DateFormat+' '+GPT.TimeFormat;

{$IFDEF MSWINDOWS}
      If GPT.OneCopy Then
      begin
        MemHnd:=CreateFileMapping(HWND($FFFFFFFF), nil, PAGE_READWRITE, 0, 127, MemFileName);
        If GetLastError=ERROR_ALREADY_EXISTS Then
        begin
          CloseHandle(MemHnd);
          ShowErrorMessage(1, GetDCLMessageString(msAppRunning));
          Halt;
        end;
      end;
{$ENDIF}
      ShowLogOnForm:=False;
      If ShiftDown Then
      begin
        ShowLogOnForm:=True;
        // GPT.DCLUserName:='';
        GPT.EnterPass:='';
      end;

      DCLMainLogOn.SQLMon:=TDCLSQLMon.Create(IncludeTrailingPathDelimiter(AppConfigDir)+
          'SQLMon.txt');

      RolesQuery1:=TDCLDialogQuery.Create(nil);
      RolesQuery1.Name:='InitRolesQuery_'+IntToStr(UpTime);
      DCLMainLogOn.SetDBName(RolesQuery1);
{$IFNDEF EMBEDDED}
      GPT.NoUsersTable:=not DCLMainLogOn.TableExists(UsersTable);
      If not GPT.NoUsersTable then
      Begin
        RolesQuery1.SQL.Text:='select count(*) from '+UsersTable;

        try
          RolesQuery1.Open;
          GPT.DisableLogOnWithoutUser:=RolesQuery1.Fields[0].AsInteger>0;
          RolesQuery1.Close;
        Except
          GPT.DCLUserName:='';
          ShowLogOnForm:=False;
          DebugProc(GetDCLMessageString(msTable)+' '+GetDCLMessageString(msUsers)+' "'+UsersTable+
              '" '+GetDCLMessageString(msNotFoundM)+'.');
        end;
      End
      Else
        GPT.DisableLogOnWithoutUser:=False;
{$ELSE}
      GPT.DisableLogOnWithoutUser:=False;
{$ENDIF}
      If DCLMainLogOn.Login(GPT.DCLUserName, GPT.EnterPass, ShowLogOnForm)<>lsLogonOK Then
        DCLMainLogOn.RoleOK:=lsRejected;
      If DCLMainLogOn.RoleOK=lsNotNeed Then
        DCLMainLogOn.RoleOK:=lsLogonOK;
    end;
  End
  Else
  begin
    ShowErrorMessage(1, GetDCLMessageString(msConfigurationFileNotFound)+' . 0010');
    DebugProc('Bye, Configuration file not fund.');
    ConnectErrorCode:=100;
  end;
end;

{ TNoScrollBarDBGrid }

{$IFDEF DELPHI}
procedure TNoScrollBarDBGrid.SetScrollBars(Value: TScrollStyle);
begin
  inherited;
end;
{$ENDIF}

{ TFieldGroup }

procedure TFieldGroup.Clear(Sender: TObject);
begin
  If ShowErrorMessage(10, GetDCLMessageString(msClearContentQ))=1 Then
  begin
    FData.Edit;
    FData.DataSet.FieldByName(FieldName).Clear;
  end;
end;

constructor TFieldGroup.Create(Parent: TWinControl; Data: TDataSource; var Field: RField;
  aAlign: TAlign; GroupType: TGroupType);
begin
  FData:=Data;
  FGroupType:=GroupType;

  ThumbPanel:=TPanel.Create(Parent);
  ThumbPanel.Parent:=Parent;
  ThumbPanel.Name:='ThumbPanel'+IntToStr(UpTime);
  ThumbPanel.Caption:='';
  ThumbPanel.Tag:=1;
  ThumbPanel.BevelInner:=bvLowered;

  If Not Field.IsFieldWidth Then
    Field.Width:=MemoWidth;
  ThumbPanel.Width:=Field.Width;
  ThumbPanel.Top:=Field.Top;
  ThumbPanel.Left:=Field.Left;
  ThumbPanel.Align:=aAlign;
  If Field.IsFieldHeight Then
    ThumbPanel.Height:=Field.Height
  Else
    ThumbPanel.Height:=GroupHeight;

  If Field.Caption<>'' Then
  begin
    FieldCaption:=TLabel.Create(ThumbPanel);
    FieldCaption.Parent:=ThumbPanel;
    FieldCaption.Caption:=Field.Caption;
    FieldCaption.Left:=140;
    FieldCaption.Top:=10;
    FieldCaption.Width:=100;
  end;

  ButtonPanel:=TPanel.Create(ThumbPanel);
  ButtonPanel.Parent:=ThumbPanel;
  ButtonPanel.BevelInner:=bvLowered;
  ButtonPanel.Align:=alTop;
  ButtonPanel.Height:=GroupButtonPanelHeight;
  FieldName:=Field.FieldName;

  Case GroupType of
  gtGrafic:
  begin
    FGraphicFileType:=gftJPEG;
    GraficField:=TDBImage.Create(ThumbPanel);
    GraficField.Parent:=ThumbPanel;
    GraficField.Name:='DBPic'+IntToStr(UpTime);
    GraficField.DataSource:=Data;
{$IFDEF FPC}
    GraficField.Caption:='';
    GraficField.OnDBImageRead:=OnDBImageRead;
{$ENDIF}
    GraficField.DataField:=Field.FieldName;
    GraficField.Align:=alClient;
    GraficField.Stretch:=False;
    GraficField.ReadOnly:=Field.ReadOnly;
    If Field.Hint<>'' Then
    begin
      GraficField.Hint:=Field.Hint;
      GraficField.ShowHint:=True;
    end;
  end;
  gtRichText:
  begin
    RichField:={$IFDEF DELPHI}TDBRichEdit{$ELSE}TDBMemo{$ENDIF}.Create(ThumbPanel);
    RichField.Parent:=ThumbPanel;
    RichField.Align:=alClient;
    RichField.ScrollBars:=ssBoth;
    RichField.DataSource:=Data;
    RichField.DataField:=Field.FieldName;
    RichField.ReadOnly:=Field.ReadOnly;
    If Field.Hint<>'' Then
    begin
      RichField.Hint:=Field.Hint;
      RichField.ShowHint:=True;
    end;
  end;
  gtMemo:
  begin
    MemoField:=TDBMemo.Create(ThumbPanel);
    MemoField.Parent:=ThumbPanel;
    MemoField.Align:=alClient;
    MemoField.ScrollBars:=ssBoth;
    MemoField.DataSource:=Data;
{$IFDEF FPC}
    MemoField.Caption:='';
{$ENDIF}
    MemoField.DataField:=FieldName;
    MemoField.ReadOnly:=Field.ReadOnly;
    If Field.Hint<>'' Then
    begin
      MemoField.Hint:=Field.Hint;
      MemoField.ShowHint:=True;
    end;
  end;
  end;

  If Not Field.ReadOnly Then
  begin
    LoadButton:=TSpeedButton.Create(ButtonPanel);
    LoadButton.Parent:=ButtonPanel;
    LoadButton.Name:='LoadButton'+IntToStr(UpTime);
    LoadButton.Tag:=0;
    LoadButton.Left:=BeginStepLeft+40;
    LoadButton.Top:=GroupToolButtonTop;
    LoadButton.Width:=25;
    LoadButton.Height:=GroupToolButtonHeight;
    LoadButton.Hint:=GetDCLMessageString(msLoad);
    LoadButton.ShowHint:=True;
    LoadButton.OnClick:=Load;
    LoadButton.Glyph.Assign(DrawBMPButton('Load'));

    ClearButton:=TSpeedButton.Create(ButtonPanel);
    ClearButton.Parent:=ButtonPanel;
    ClearButton.Name:='ClearButton'+IntToStr(UpTime);
    ClearButton.Tag:=1;
    ClearButton.Left:=BeginStepLeft+80;
    ClearButton.Top:=GroupToolButtonTop;
    ClearButton.Width:=25;
    ClearButton.Height:=GroupToolButtonHeight;
    ClearButton.Hint:=GetDCLMessageString(msClear);
    ClearButton.ShowHint:=True;
    ClearButton.OnClick:=Clear;
    ClearButton.Glyph.Assign(DrawBMPButton('Clear'));
  end;

  SaveButton:=TSpeedButton.Create(ButtonPanel);
  SaveButton.Parent:=ButtonPanel;
  SaveButton.Name:='SaveButton'+IntToStr(UpTime);
  SaveButton.Tag:=2;
  SaveButton.Left:=BeginStepLeft;
  SaveButton.Top:=GroupToolButtonTop;
  SaveButton.Width:=25;
  SaveButton.Height:=GroupToolButtonHeight;
  SaveButton.Hint:=GetDCLMessageString(msSave);
  SaveButton.ShowHint:=True;
  SaveButton.OnClick:=Save;
  SaveButton.Glyph.Assign(DrawBMPButton('Save'));
end;

destructor TFieldGroup.Destroy;
begin
  inherited Destroy;
end;

procedure TFieldGroup.Load(Sender: TObject);
begin
  Case FGroupType of
  gtGrafic:
  begin
    OpenPictureDialog:=TOpenPictureDialog.Create(nil);
    OpenPictureDialog.DefaultExt:='jpg';
    OpenPictureDialog.Filter:=GraphicFilter(TGraphic);
    If OpenPictureDialog.Execute Then
      LoadData(OpenPictureDialog.FileName);

    FreeAndNil(OpenPictureDialog);
  end;
  gtMemo, gtRichText:
  begin
    OpenDialog:=TOpenDialog.Create(nil);
    Case FGroupType of
    gtMemo:
    begin
      OpenDialog.DefaultExt:='txt';
      OpenDialog.Filter:=GetDCLMessageString(msText)+' (*.txt)|*.txt|'+
          InitCap(GetDCLMessageString(msAll)+' (*.*)|*.*');
    end;
    gtRichText:
    begin
      OpenDialog.DefaultExt:='rtf';
      OpenDialog.Filter:=GetDCLMessageString(msFormated)+
          GetDCLMessageString(msText)+' (*.rtf)|*.rtf|'+InitCap(GetDCLMessageString(msAll)+
          ' (*.*)|*.*');
    end;
    end;
    If OpenDialog.Execute Then
      LoadData(OpenDialog.FileName);

    FreeAndNil(OpenDialog);
  end;
  end;
end;

procedure TFieldGroup.LoadData(FileName: String);
var
  bmp: TBitmap;
  jpg: TJpegImage;
  MS: TMemoryStream;
  TS: TStringList;
begin
  FData.Edit;
  Case GetGraficFileType(FileName) of
  gftJPEG:
  begin
    jpg:=TJpegImage.Create;
    bmp:=TBitmap.Create;
    jpg.LoadFromFile(FileName);
    MS:=TMemoryStream.Create;
    bmp.Assign(jpg);
    bmp.SaveToStream(MS);
    TBlobField(FData.DataSet.FieldByName(FieldName)).LoadFromStream(MS);
    FreeAndNil(jpg);
    FreeAndNil(bmp);
    FreeAndNil(MS);
  end;
  gftBMP, gftNone:
  begin
    If FData.DataSet.FieldByName(FieldName).DataType in TBlobFields Then
      TBlobField(FData.DataSet.FieldByName(FieldName)).LoadFromFile(FileName)
    Else
    begin
      TS:=TStringList.Create;
      TS.LoadFromFile(FileName);
      FData.DataSet.FieldByName(FieldName).AsString:=TS.Text;
      FreeAndNil(TS);
    end;
  end;
  end;
end;

procedure TFieldGroup.OnDBImageRead(Sender: TObject; S: TStream; var GraphExt: String);
var
  Signature: Array of Byte;
  Source, Dest: TMemoryStream;
  Marker: Cardinal;
begin
  SetLength(Signature, 10);
  S.Read(Signature[0], 10);
  S.Position:=0;
  Marker:=0;
  S.Read(Marker, PAGSignatureSize);
  S.Position:=0;

  If Marker=PAGSignature Then
  // (Signature[0]=$50) and (Signature[1]=$41) and (Signature[2]=$47) then
  begin
    S.Position:=PAGSignatureSize;
    Source:=TMemoryStream.Create;
    Source.CopyFrom(S, S.Size-3);
    Dest:=TMemoryStream.Create;
    DecompressProc(Source, Dest);
    Dest.Position:=0;
    S.Position:=0;
    S.CopyFrom(Dest, Dest.Size);
    S.Position:=0;
    S.Read(Signature[0], 10);
    S.Position:=0;
    Source.Free;
    Dest.Free;
  end;

  If (Signature[0]=66)and(Signature[1]=77) Then
  begin
    GraphExt:='bmp';
    FGraphicFileType:=gftBMP;
  end
  Else If (Signature[0]=$FF)and(Signature[1]=$D8) Then
  begin
    GraphExt:='jpg';
    FGraphicFileType:=gftJPEG;
  end
  Else If (Signature[0]=$89)and(Signature[1]=$50)and(Signature[2]=$4E)and(Signature[3]=$47)and
    (Signature[4]=$0D)and(Signature[5]=$0A)and(Signature[6]=$1A)and(Signature[7]=$0A) Then
  begin
    GraphExt:='png';
    FGraphicFileType:=gftPNG;
  end
  Else If (Signature[0]=$47)and(Signature[1]=$49)and(Signature[2]=$46)and(Signature[3]=$38) Then
  begin
    GraphExt:='gif';
    FGraphicFileType:=gftGIF;
  end
  Else If ((Signature[0]=$49)and(Signature[1]=$49)and(Signature[2]=$2A)and(Signature[3]=$00))or
    ((Signature[4]=$4D)and(Signature[5]=$4D)and(Signature[6]=$00)and(Signature[7]=$2A)) Then
  begin
    GraphExt:='tiff';
    FGraphicFileType:=gftTIFF;
  end
  Else If (Signature[0]=$00)and(Signature[1]=$00)and((Signature[2]=$01)or(Signature[2]=$02))and
    (Signature[3]=$00)and(Signature[4]>=1) Then
  begin
    GraphExt:='ico';
    FGraphicFileType:=gftIcon;
  end
  Else
  begin
    GraphExt:='Unk';
    FGraphicFileType:=gftOther;
  end;
end;

procedure TFieldGroup.Save(Sender: TObject);
begin
  Case FGroupType of
  gtGrafic:
  begin
    SavePictureDialog:=TSavePictureDialog.Create(nil);
    SavePictureDialog.Name:='SavePictureDialog1';
    SavePictureDialog.DefaultExt:=GetExtByType(FGraphicFileType);
    SavePictureDialog.Filter:=GraphicFilter(TGraphic);

    If SavePictureDialog.Execute Then
      SaveData(SavePictureDialog.FileName);

    FreeAndNil(SavePictureDialog);
  end;
  gtMemo, gtRichText:
  begin
    SaveDialog:=TSaveDialog.Create(nil);
    Case FGroupType of
    gtMemo:
    begin
      SaveDialog.DefaultExt:='txt';
      SaveDialog.Filter:=GetDCLMessageString(msText)+' (*.txt)|*.txt|'+
          InitCap(GetDCLMessageString(msAll)+' (*.*)|*.*');
    end;
    gtRichText:
    begin
      SaveDialog.DefaultExt:='rtf';
      SaveDialog.Filter:=GetDCLMessageString(msFormated)+
          GetDCLMessageString(msText)+' (*.rtf)|*.rtf|'+InitCap(GetDCLMessageString(msAll)+
          ' (*.*)|*.*');
    end;
    end;
    If SaveDialog.Execute Then
      SaveData(SaveDialog.FileName);
    FreeAndNil(SaveDialog);
  end;
  end;
end;

procedure TFieldGroup.SaveData(FileName: String);
var
  bmp: TBitmap;
  jpg: TJpegImage;
  MS: TMemoryStream;
  TS: TStringList;
begin
  Case GetGraficFileType(FileName) of
  gftJPEG:
  begin
    MS:=TMemoryStream.Create;
    TBlobField(FData.DataSet.FieldByName(FieldName)).SaveToStream(MS);
    MS.Seek(0, soFromBeginning);
    bmp:=TBitmap.Create;
    bmp.LoadFromStream(MS);
    jpg:=TJpegImage.Create;
    jpg.Assign(bmp);
    jpg.CompressionQuality:=JPEGCompressionQuality;
    jpg.SaveToFile(FileName);
    FreeAndNil(bmp);
    FreeAndNil(jpg);
  end;
  gftBMP, gftNone:
  If FData.DataSet.FieldByName(FieldName).DataType in TBlobFields Then
    TBlobField(FData.DataSet.FieldByName(FieldName)).SaveToFile(FileName)
  Else
  begin
    TS:=TStringList.Create;
    TS.Text:=FData.DataSet.FieldByName(FieldName).AsString;
    TS.SaveToFile(FileName);
    FreeAndNil(TS);
  end;

  end;
end;

{ TBaseBinStore }

procedure TBaseBinStore.ClearData(DataName: String; FindType: TFindType);
begin
  DCLQuery.Close;
  Case FindType of
  ftByName:
  DCLQuery.SQL.Text:='update '+FTableName+' set '+FDataField+'=null where '+GPT.UpperString+
    FNameField+GPT.UpperStringEnd+'='+GPT.UpperString+GPT.StringTypeChar+DataName+GPT.StringTypeChar
    +GPT.UpperStringEnd;
  ftByIndex:
  DCLQuery.SQL.Text:='update '+FTableName+' set '+FDataField+'=null where '+FKeyField+'='+DataName;
  ftSQL:
  DCLQuery.SQL.Text:=DataName;
  end;
  try
    If IsReturningQuery(DCLQuery.SQL.Text) Then
    begin
      DCLQuery.Open;
      DCLQuery.Edit;
      DCLQuery.FieldByName(FDataField).Clear;
      DCLQuery.Post;
      DCLQuery.Close;
    end
    Else
      DCLQuery.ExecSQL;
  Except
    ShowErrorMessage( - 5003, FTableName);
    Exit;
  end;
end;

destructor TBaseBinStore.Destroy;
begin
  If Assigned(DCLQuery) Then
  begin
    If DCLQuery.Active Then
      DCLQuery.Close;
    // FreeAndNil(DCLQuery);
  end;
  inherited Destroy;
end;

procedure TBaseBinStore.CompressData(DataName, Data: String; FindType: TFindType);
var
  MS: TMemoryStream;
begin
  MS:=GetData(DataName, FindType);
  MS.Position:=0;
  SetData(DataName, Data, FindType, MS, True);
  MS.Free;
end;

constructor TBaseBinStore.Create(DCLLogOn: TDCLLogOn; TableName, KeyField, NameField,
  DataField: String);
begin
  FDCLLogOn:=DCLLogOn;
  FErrorCode:=0;
  FTableName:=TableName;
  FKeyField:=KeyField;
  FNameField:=NameField;
  FDataField:=DataField;

  DCLQuery:=TDCLQuery.Create(FDCLLogOn.FDBLogOn);
  //DCLQuery.NoRefreshSQL:=True;
end;

procedure TBaseBinStore.DeCompressData(DataName, Data: String; FindType: TFindType);
var
  MS: TMemoryStream;
begin
  MS:=GetData(DataName, FindType);
  SetData(DataName, Data, FindType, MS, False);
end;

function TBaseBinStore.MD5(DataName: String; FindType: TFindType): String;
var
  MS: TMemoryStream;
begin
  MS:=GetData(DataName, FindType);
  Result:=MD5DigestToStr(MD5Stream(MS));
end;

procedure TBaseBinStore.DeleteData(DataName: String; FindType: TFindType);
begin
  DCLQuery.Close;
  Case FindType of
  ftByName:
  DCLQuery.SQL.Text:='delete from '+FTableName+' where '+GPT.UpperString+FNameField+
    GPT.UpperStringEnd+'='+GPT.UpperString+GPT.StringTypeChar+DataName+GPT.StringTypeChar+
    GPT.UpperStringEnd;
  ftByIndex:
  DCLQuery.SQL.Text:='delete from '+FTableName+' where '+FNameField+'='+DataName;
  ftSQL:
  DCLQuery.SQL.Text:=DataName;
  end;
  try
    If IsReturningQuery(DCLQuery.SQL.Text) Then
    begin
      DCLQuery.Open;
      DCLQuery.Delete;
      DCLQuery.Close;
    end
    Else
      DCLQuery.ExecSQL;
  Except
    ShowErrorMessage( - 5003, FTableName);
    Exit;
  end;
end;

function TBaseBinStore.GetData(DataName: String; FindType: TFindType): TMemoryStream;
var
  BS, MS: TMemoryStream;
  Marker: Cardinal;
begin
  FErrorCode:=0;
  DCLQuery.Close;
  Result:=TMemoryStream.Create;
  Case FindType of
  ftByName:
  DCLQuery.SQL.Text:='select '+FDataField+' from '+FTableName+' where '+GPT.UpperString+FNameField+
    GPT.UpperStringEnd+'='+GPT.UpperString+GPT.StringTypeChar+DataName+GPT.StringTypeChar+
    GPT.UpperStringEnd;
  ftByIndex:
  DCLQuery.SQL.Text:='select '+FDataField+' from '+FTableName+' where '+FKeyField+'='+DataName;
  ftSQL:
  DCLQuery.SQL.Text:=DataName;
  end;
  try
    DCLQuery.Open;
    DCLQuery.Last;
    DCLQuery.First;
  Except
    FErrorCode:=3;
    ShowErrorMessage( - 5003, FTableName);
    Exit;
  end;
  If Not DCLQuery.IsEmpty Then
  begin
    try
      MS:=TMemoryStream.Create;
      Result:=TMemoryStream.Create;
      TBlobField(DCLQuery.FieldByName(FDataField)).SaveToStream(MS);
      If MS.Size>0 Then
      begin
        Marker:=0;
        MS.Position:=0;
        MS.Read(Marker, PAGSignatureSize);

        If Marker=PAGSignature Then // "PAG" Signature
        begin
          // Compressed/
          BS:=TMemoryStream.Create;
          BS.Position:=0;
          DecompressProc(MS, BS);
          BS.Position:=0;
          MS.Position:=0;
          MS.CopyFrom(BS, BS.Size);
          FreeAndNil(BS);
        end;

        MS.Position:=0;
        Result.CopyFrom(MS, MS.Size);
      end;
    Except
      //
    end;
  end;
  DCLQuery.Close;
end;

function TBaseBinStore.IsDataExist(DataName: String; FindType: TFindType): Boolean;
begin
  Result:=False;
  DCLQuery.Close;
  Case FindType of
  ftByName:
  DCLQuery.SQL.Text:='select '+FDataField+' from '+FTableName+' where '+GPT.UpperString+FNameField+
    GPT.UpperStringEnd+'='+GPT.UpperString+GPT.StringTypeChar+DataName+GPT.StringTypeChar+
    GPT.UpperStringEnd;
  ftByIndex:
  DCLQuery.SQL.Text:='select '+FDataField+' from '+FTableName+' where '+FKeyField+'='+DataName;
  ftSQL:
  DCLQuery.SQL.Text:=DataName;
  end;
  try
    DCLQuery.Open;
  Except
    ShowErrorMessage( - 5003, FTableName);
    FErrorCode:=3;
    Exit;
  end;
  Result:=Not DCLQuery.IsEmpty;
  DCLQuery.Close;
end;

procedure TBaseBinStore.SaveToFile(FileName, DataName: String; FindType: TFindType);
begin
  GetData(DataName, FindType).SaveToFile(FileName);
end;

procedure TBaseBinStore.SetData(DataName, Data: String; FindType: TFindType; Stream: TMemoryStream;
  Compress: Boolean);
var
  BS: TMemoryStream;
  tmpSQL, tmpSQL1, insSQL, valuesSQL, S, Value: String;
  i: Integer;
  Signature: Cardinal;
begin
  If Stream.Size>0 Then
  begin
    If Compress Then
    begin
      BS:=TMemoryStream.Create;
      Signature:=PAGSignature;
      BS.Write(Signature, PAGSignatureSize);
      Stream.Position:=0;
      CompressProc(Stream, BS);
      BS.Position:=0;
      Stream.Position:=0;
      Stream.CopyFrom(BS, BS.Size);
      FreeAndNil(BS);
    end;

    Case FindType of
    ftByName:
    tmpSQL:='select * from '+FTableName+' where '+GPT.UpperString+FNameField+GPT.UpperStringEnd+'='+
      GPT.UpperString+GPT.StringTypeChar+DataName+GPT.StringTypeChar+GPT.UpperStringEnd;
    ftByIndex:
    tmpSQL:='select * from '+FTableName+' where '+FKeyField+'='+DataName;
    ftSQL:
    tmpSQL:=DataName;
    end;
    DCLQuery.Close;
    {$IFDEF CACHEDDB}
    DCLQuery.CancelUpdates;
    {$ENDIF}
    DCLQuery.SQL.Text:=tmpSQL;
    try
      DCLQuery.Open;
    Except
      FErrorCode:=3;
      ShowErrorMessage( - 5003, FTableName);
      Exit;
    end;
    If DCLQuery.IsEmpty Then
    begin
      tmpSQL1:=tmpSQL;
      If FindType<>ftSQL Then
        DCLQuery.Close;
      Case FindType of
      ftByName:
      DCLQuery.SQL.Text:='insert into '+FTableName+'('+FNameField+') values('+GPT.StringTypeChar+
        DataName+GPT.StringTypeChar+')';
      ftByIndex:
      DCLQuery.SQL.Text:='insert into '+FTableName+'('+FKeyField+') values('+DataName+')';
      ftSQL:
      begin
        insSQL:='';
        valuesSQL:='';
        For i:=1 to ParamsCount(Data) do
        begin
          S:=SortParams(Data, i);
          Value:=CopyCut(S, Pos('=', S), Length(S));
          Delete(Value, 1, 1);
          insSQL:=insSQL+','+S;
          valuesSQL:=valuesSQL+','+GPT.StringTypeChar+Value+GPT.StringTypeChar;
        end;
        If insSQL<>'' Then
          Delete(insSQL, 1, 1);
        If valuesSQL<>'' Then
          Delete(valuesSQL, 1, 1);

        tmpSQL:='insert into '+FTableName+'('+insSQL+') values('+valuesSQL+')';
        DCLQuery.SQL.Text:=tmpSQL;
      end;
      end;
      DCLQuery.ExecSQL;
      DCLQuery.SaveDB;
      DCLQuery.SQL.Text:=tmpSQL1;
      DCLQuery.Open;
    end;
    If Not (DCLQuery.State in dsEditModes) Then
      DCLQuery.Edit;
    Stream.Position:=0;
    TBlobField(DCLQuery.FieldByName(FDataField)).LoadFromStream(Stream);
    try
      DCLQuery.Post;
      DCLQuery.SaveDB;
    finally
      DCLQuery.Close;
    end;
  end;
end;

procedure TBaseBinStore.StoreFromFile(FileName, DataName, Data: String; FindType: TFindType;
  Compress: Boolean);
var
  MS: TMemoryStream;
begin
  If FileExists(FileName) Then
  begin
    MS:=TMemoryStream.Create;
    MS.LoadFromFile(FileName);
    SetData(DataName, Data, FindType, MS, Compress);
  end;
end;

{ TBinStore }

procedure TBinStore.ClearData(DataName: String);
begin
  inherited ClearData(DataName, FFindType);
end;

destructor TBinStore.Destroy;
begin
  inherited Destroy;
end;

procedure TBinStore.CompressData(DataName, Data: String);
begin
  inherited CompressData(DataName, Data, FFindType);
end;

constructor TBinStore.Create(DCLLogOn: TDCLLogOn; FindType: TFindType;
  TableName, KeyField, NameField, DataField: String);
begin
  FFindType:=FindType;
  inherited Create(DCLLogOn, TableName, KeyField, NameField, DataField);
end;

procedure TBinStore.DeCompressData(DataName, Data: String);
begin
  inherited DeCompressData(DataName, Data, FFindType);
end;

function TBinStore.MD5(DataName: String): String;
begin
  Result:=inherited MD5(DataName, FFindType);
end;

procedure TBinStore.DeleteData(DataName: String);
begin
  inherited DeleteData(DataName, FFindType);
end;

function TBinStore.GetData(DataName: String): TMemoryStream;
begin
  Result:=inherited GetData(DataName, FFindType);
end;

function TBinStore.IsDataExist(DataName: String): Boolean;
begin
  Result:=inherited IsDataExist(DataName, FFindType);
end;

procedure TBinStore.SaveToFile(FileName, DataName: String);
begin
  inherited SaveToFile(FileName, DataName, FFindType);
end;

procedure TBinStore.SetData(DataName, Data: String; Stream: TMemoryStream; Compress: Boolean);
begin
  inherited SetData(DataName, Data, FFindType, Stream, Compress);
end;

procedure TBinStore.StoreFromFile(FileName, DataName, Data: String; Compress: Boolean);
begin
  inherited StoreFromFile(FileName, DataName, Data, FFindType, Compress);
end;

{ TDCLFastReports }

{$IFNDEF NOFASTREPORTS}
constructor TDCLFastReports.Create(DCLLogOn:TDCLLogOn; DataModule: TDataModule;
  ScriptLanguage:TFastReportsScriptLanguage=DefaultFRScriptLanguage);
begin
  FDCLLogOn:=DCLLogOn;
  FDataModule:=DataModule;

  FRXRep:=TfrxReport.Create(FDataModule);
  // FRXRep.DataSet:=dmReport.frxReportLstFDS;
  FRXRep.IniFile:='\Software\Fast Reports';
  FRXRep.StoreInDFM:=False;
  FRXRep.ScriptLanguage:=FastReportsScriptLanguages[ScriptLanguage];
end;

destructor TDCLFastReports.Destroy;
begin
  FRXRep.Free;
  inherited;
end;

function TDCLFastReports.LoadReportFile(FileName: string): Boolean;
begin
  If FileExists(FileName) then
    FRXRep.LoadFromFile(FileName);
end;

function TDCLFastReports.LoadReportFromBinStore(DataName: string): Boolean;
begin
  BinStore:=TDCLBinStore.Create(FDCLLogOn);
  FRXRep.LoadFromStream(BinStore.GetData(DataName));
  FreeAndNil(BinStore);
end;

procedure TDCLFastReports.ShowReport;
begin
  FRXRep.ShowReport(True);
end;
{$ENDIF}

{$IFNDEF EMBEDDED}
Initialization

  InitDCL(nil);

// Finalization
// EndDCL;
{$ENDIF}

end.
