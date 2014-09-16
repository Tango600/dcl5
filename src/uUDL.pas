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
  Windows, ComObj,
{$ENDIF}
{$IFDEF UNIX}
  cwstring, process, unix, libc, lclintf, BaseUnix,
{$ENDIF}
  Messages, Variants, Classes, Graphics, Controls, Forms, ExtCtrls, ToolWin,
  Grids, DB, StdCtrls, ComCtrls, Dialogs, dbctrls, Buttons, ExtDlgs, Menus,
  DBGrids, DateUtils,
{$IFDEF ADO}
  ActiveX, ADODB, ADOConst, ADOInt,
{$ENDIF}
{$IFDEF BDE}
  BDE, DBClient, DBTables, Bdeconst,
{$ENDIF}
{$IFDEF IB}
  IBDatabase, IBTable, IBCustomDataSet, IBSQL, IBQuery,
  IBVisualConst, IBXConst,
{$ENDIF}
{$IFDEF ZEOS}
  ZDbcIntfs, // ZConnection, ZDataset, ZSqlUpdate,
{$ENDIF}
{$IFDEF SQLdbIB}
  IBConnection, sqldb,
{$ENDIF}
{$IFDEF FPC}
  FileUtil, EditBtn, LConvEncoding, {$IFDEF ZVComponents}ZVDateTimePicker, {$ENDIF}
{$ENDIF}
{$IFNDEF FPC}
  JPEG,
{$ENDIF}
  {$IFDEF MSWINDOWS}uOfficeDocs, {$ENDIF}
  uDCLMessageForm, uDCLSQLMonitor, uDCLQuery, uLogging, MD5,
  uStringParams, uDCLData, uDCLConst, uDCLTypes;

Type
  TDCLLogOn=class;
  TDCLCommand=class;
  TDCLGrid=class;
  TDCLForm=class;
  TLogOnForm=class;
  TDCLOfficeReport=class;
  TWordReport=class;
  TDCLTextReport=class;
  TDCLBinStore=class;
  TBinStore=class;
  TFieldGroup=class;

  TVariables=class(TObject)
  private
    FVariables: Array Of TVariable;
    FDCLLogOn: TDCLLogOn;
    FDCLForm: TDCLForm;

    function FindEmptyVariableSlot: Integer;
    Function VariableNumByName(Const VariableName: String): Integer;
    Function GetVariableByName(Const VariableName: String): String;
    procedure SetVariableByName(const VariableName, Value: String);
    Function GetAllVariables: TList;
  public
    constructor Create(var DCLLogOn: TDCLLogOn; DCLForm: TDCLForm);
    procedure NewVariable(const VariableName: String; Value: string='');
    procedure FreeVariable(const VariableName: string);
    Function Exists(Const VariableName: String): Boolean;
    procedure RePlaseVariables(Var VariablesSet: String; Query: TDCLDialogQuery);

    property Variables[const VariableName: string]: String read GetVariableByName
      write SetVariableByName;
    property VariablesList: TList read GetAllVariables;
  end;

  TMainFormAction=class
    Procedure CloseMainForm(Sender: TObject; Var {%H-}Action: TCloseAction);
    Procedure FormCloseQuery(Sender: TObject; Var CanClose: Boolean);
  End;

  TNoScrollBarDBGrid=Class(TDBGrid)
{$IFNDEF FPC}
  private
    FScrollBars: TScrollStyle;
    procedure SetScrollBars(Value: TScrollStyle);
  published
    property ScrollBars: TScrollStyle read FScrollBars write SetScrollBars default ssBoth;
{$ENDIF}
  End;

  TToolGrid=TNoScrollBarDBGrid;

  TLookupTable=record
    DCLGrid: TDCLGrid;
    LookupPanel: TDialogPanel;
  end;

  TDCLGrid=class(TObject)
  private
    FGridPanel: TDCLMainPanel;
    FDCLLogOn: TDCLLogOn;
    FForm: TDBForm;
    FDCLForm: TDCLForm;
    FGrid: TDBGrid;
    FQueryGlob: TDCLQuery;
    FData: TDataSource;
    FDisplayMode: TDataControlType;
    FMultiSelect, FShowed, RefreshLock: Boolean;
    PreviousColumnIndex: Integer;
    PopupGridMenu: TPopupMenu;
    ItemMenu, ToItem: TMenuItem;
    PosBookCreated: Boolean;
    Navig: TDBNavigator;
    FindGrid: TStringGrid;
    FReadOnly, FindProcess, PagePanelCreated: Boolean;
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
    FTableParts: array of TDCLGrid;
    PartTabIndex, MaxStepFields: Integer;
    PartQueryGlob: TDCLQuery;
    NotAllowedOperations: TOperationsTypes;
    RowColor, RowTextColor: TColor;
    SummGrid: TToolGrid;
    SumQuery: TDCLDialogQuery;
    SumData: TDataSource;
    RefreshTimer: TTimer;
    LastStateTimer, BaseChanged: Boolean;
    MediaFields: array of TFieldGroup;
    KeyMarks: TKeyBookmarks;
    ButtonPanel: TDialogPanel;
    ToolButtonPanel: TToolBarPanel;
    ToolButtonsCount: Byte;
    ToolButtonPanelButtons: Array [1..ToolCommandsCount] Of TDialogSpeedButton;
    ToolCommands: Array [1..ToolCommandsCount] Of String;

    DateBoxes: array of TDateBox;
    CheckBoxes: Array of RCheckBox;
    DBCheckBoxes: Array of TDBCheckBox;
    Lookups: array of RLookups;
    ContextFieldButtons: array of TContextFieldButton;
    RollBars: array of TRollBar;
    BrushColors: array of TBrushColors;
    ContextLists: array of TContextList;
    DropBoxes: array of TDropBox;
    LookupTables: array of TLookupTable;

    EventsScroll, EventsBeforeScroll, EventsDelete, EventsAfterOpen, EventsAfterPost, EventsCancel,
      EventsInsert, LineDblClickEvents, EventsBeforePost: TEventsArray;

    StructModify: array Of RStructModify;
    OrderByFields: array of string;

    procedure ToolButtonsOnClick(Sender: TObject);

    function AddTablePart(Parent: TWinControl; Data: TDataSource): Integer;
    Function GetSummQuery: String;
    Function QueryBuilder(GetQueryMode, QueryMode: Byte): String;
    function GetFingQuery: String;
    Function FindRaightQuery(St: String): String;
    Function GetQueryToRaights(S: String): String;
    procedure ChangeTabPage(Sender: TObject);

    procedure ClickNavig(Sender: TObject; Button: TNavigateBtn);
    Procedure SortDB(Column: TColumn);

    Procedure AutorefreshTimer(Sender: TObject);
    procedure CreateBookMarkMenu;
    Procedure SetBookMark(Sender: TObject);
    procedure PosToBookMark(Sender: TObject);
    Procedure DeleteMenuBookMark(BookMarkNum: Byte);

    procedure SaveDB;
    procedure CancelDB;

    // DataEvents
    Procedure AfterInsert(Data: TDataSet);
    Procedure ScrollDB(Data: TDataSet);
    procedure AfterOpen(Data: TDataSet);
    procedure AfterClose(Data: TDataSet);
    Procedure AfterEdit(Data: TDataSet);
    Procedure AfterPost(Data: TDataSet);
    Procedure AfterCancel(Data: TDataSet);

    Procedure BeforeScroll(Data: TDataSet);
    Procedure BeforeOpen(Data: TDataSet);
    Procedure BeforePost(Data: TDataSet);

    Procedure OnDelete(Data: TDataSet);
    procedure AfterRefresh(Data: TDataSet);
    // End DataEvents
    procedure ExecEvents(EventsArray: TEventsArray);

    procedure RePlaseParams(var Params: string);

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
    procedure EditOnFloatData(Sender: TObject; Var Key: Char);
    procedure EditOnEdit(Sender: TObject);
    procedure OnChangeDateBox(Sender: TObject);
    procedure CheckOnClick(Sender: TObject);
    Procedure GridDblClick(Sender: TObject);
    procedure LookupOnClick(Sender: TObject);
    procedure LookupDBScroll(Data: TDataSet);
    procedure ContextFieldButtonsClick(Sender: TObject);
    procedure RollBarOnChange(Sender: TObject);
    Procedure ContextListKeyDown(Sender: TObject; Var Key: Word; Shift: TShiftState);
    Procedure ContextListChange(Sender: TObject);
    Procedure DropListOnSelectItem(Sender: TObject);

    function GetColumns: TDBGridColumns;
    procedure SetColumns(Cols: TDBGridColumns);

    // procedure SetRequiredFields;

    procedure DeleteList(Index: Word);
    Procedure ColumnsManege(Sender: TObject);
    Procedure FieldsManege(Sender: TObject);

    Procedure ExecFilter(Sender: TObject);
    Procedure OnContextFilter(Sender: TObject; Var Key: Word; Shift: TShiftState);
    Procedure CalendarOnChange(Sender: TObject);

    function GetTablePart(Index: Integer): TDCLGrid;
    procedure SetTablePart(Index: Integer; Value: TDCLGrid);

    Procedure AddPopupMenuItem(Caption, ItemName: String; Action: TNotifyEvent;
      AChortCutKey: String; Tag: Integer; PictType: String);
    Procedure AddSubPopupItem(Caption, ItemName: String; Action: TNotifyEvent;
      ToMenu, Tag: Integer);
    Procedure GridDrawDataCell(Sender: TObject; Const Rect: TRect; DataCol: Integer;
      Column: TColumn; State: TGridDrawState);
    procedure SetMultiselect(Value: Boolean);
    function GetMultiselect: Boolean;
    function GetFieldDataType(FieldName: String): TFieldType;

    property FQuery: TDCLQuery read GetQuery write SetQuery;
  public
    QueryName, DependField, MasterDataField: String;
    TabType: TPageType;
    CurrentTabIndex, Tag: Integer;
    DataFields: array of TDCLDataFields;
    QuerysStore: array of TDCLQueryStore;
    DBFilters: array of TDBFilter;
    Calendars: array of RCalendar;
    Edits: Array Of TDCLEdits;
    PartSplitter: TSplitter;

    constructor Create(var Form: TDCLForm; Parent: TWinControl; SurfType: TDataControlType;
      Query: TDCLDialogQuery; Data: TDataSource);
    destructor Destroy; override;

    Procedure OpenQuery(QText: String);
    procedure Open;
    procedure Close;
    procedure Show;
    procedure AddColumn(Field: RField);
    procedure CreateColumns;
    procedure AddField(Field: RField);
    procedure SetSQLToStore(SQL: String; QueryType: TQueryType; Raight: TUserLevelsType);
    function GetSQLFromStore(QueryType: TQueryType): string;
    procedure ReFreshQuery;
    procedure SetNewQuery(Data: TDataSource);

    procedure Structure(Sender: TObject);
    procedure PFind(Sender: TObject);
    procedure Print(Sender: TObject);
    Procedure PCopy(Sender: TObject);
    Procedure PCut(Sender: TObject);
    Procedure PPaste(Sender: TObject);
    Procedure PUndo(Sender: TObject);

    procedure AddLabel(Field: RField; Caption: String);
    procedure AddEdit(var Field: RField);
    procedure AddFieldBox(Var Field: RField; FieldBoxType: TFieldBoxType; NamePrefix: String);
    procedure AddDateBox(Var Field: RField);
    procedure AddCheckBox(Var Field: RField);
    procedure AddDBCheckBox(Var Field: RField);
    procedure AddLookUp(Var Field: RField);
    procedure AddContextButton(Var Field: RField);
    procedure AddRollBar(Var Field: RField);
    procedure AddBrushColor(OPL: String);
    procedure AddContextList(Var Field: RField);
    procedure AddDropBox(Var Field: RField);
    procedure AddSumGrid(OPL: string);
    procedure AddLookupTable(Var Field: RField);
    procedure AddMediaFieldGroup(Parent: TWinControl; Align: TAlign; GroupType: TGroupType;
      Var Field: RField);

    function AddPartPage(Caption: string; Data: TDataSource): Integer;
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
    property Grid: TDBGrid read FGrid;
    property TableParts[Index: Integer]: TDCLGrid read GetTablePart write SetTablePart;
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
    FGraphicFileType:TGraficFileType;
    FGroupType: TGroupType;
    LoadButton, SaveButton, ClearButton: TSpeedButton;
    OpenPictureDialog: TOpenPictureDialog;
    SavePictureDialog: TSavePictureDialog;
    OpenDialog: TOpenDialog;
    SaveDialog: TSaveDialog;

    Procedure Load(Sender: TObject);
    Procedure Save(Sender: TObject);
    Procedure Clear(Sender: TObject);

    procedure SaveData(FileName: string);
    procedure LoadData(FileName: string);

    procedure OnDBImageRead(Sender: TObject; S: TStream; var GraphExt : string);
  public
    constructor Create(Parent: TWinControl; Data: TDataSource; var Field: RField; aAlign: TAlign;
      GroupType: TGroupType);
  end;

  TDCLCommandButton=class(TObject)
  private
    Commands: array of String;
    CommandButton: array of TDialogButton;
    FDCLForm: TDCLForm;
    FDCLLogOn: TDCLLogOn;

    procedure ExecCommand(Sender: TObject);
  public
    constructor Create(var DCLLogOn: TDCLLogOn; var DCLForm: TDCLForm);
    procedure AddCommand(Parent: TWinControl; ButtonParams: RButtonParams);
  end;

  { TDCLForm }

  TDCLForm=class(TObject)
  private
    FName: string;
    FParentForm: TDCLForm;
    UserLevelLocal: TUserLevelsType;
    FOPL: TStringList;
    FFormNum, FormHeight, FormWidth: Integer;
    TB: TFormPanelButton;
    FNewPage, NoVisual, NoStdKeys, NotDestroyedDCLForm: Boolean;
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
    QueryGlob: TDCLQuery;
    FItnQuery: TDCLQuery;
    DBStatus: TStatusBar;
    GridPanel: TDialogPanel;
    ParentPanel: TWinControl;
    // CachedUpdates:Boolean;
    Commands: TDCLCommandButton;
    EventsClose: TEventsArray;
    FRetunValue:TReturnFormValue;
    FReturningMode:TChooseMode;
    FReturnValueParams:TReturnValueParams;

    function AddGrid(Parent: TWinControl; SurfType: TDataControlType; Query: TDCLDialogQuery;
      Data: TDataSource): Integer;
    procedure AddMainPage(Query: TDCLDialogQuery; Data: TDataSource);
    procedure ChangeTabPage(Sender: TObject);
    function GridsCount: Word;
    procedure AddEvents(var Events: TEventsArray; EventsSet: String);

    function GetMainQuery: TDCLQuery;
    function GetDataSource: TDataSource;
    function GetPartQuery: TDCLQuery;

    function GetParentForm: TDCLForm;
    Procedure ResizeDBForm(Sender: TObject);

    function GetTable(Index: Integer): TDCLGrid;
    procedure SetTable(Index: Integer; Value: TDCLGrid);
    function GetTablesCount: Integer;
    procedure ActivateForm(Sender: TObject);

    procedure ToolButtonClick(Sender: TObject);

    procedure CloseForm(Sender: TObject; Var {%H-}Action: TCloseAction);

    procedure ExecCommand(CommandName:String);

    procedure LoadFormPos;
    procedure LoadFormPosINI;
    procedure LoadFormPosBase;
    procedure LoadFormPosUni(DialogParams:TStringList);
    procedure SaveFormPos;
    procedure SaveFormPosINI;
    procedure SaveFormPosBase;
    function SaveFormPosUni: TStringList;
  public
    LocalVariables: TVariables;
    Modal, BaseChanged, ExitNoSave: Boolean;
    FDialogName: String;

    constructor Create(DialogName: String; var DCLLogOn: TDCLLogOn; ParentForm: TDCLForm;
      aFormNum: Integer; OPL: TStringList; Query: TDCLDialogQuery; Data: TDataSource;
      Modal: Boolean=False; ReturnValueMode:TChooseMode=chmNone; ReturnValueParams:TReturnValueParams=nil);
    destructor Destroy; override;

    procedure SetInactive;
    procedure SetActive;
    function GetActive: Boolean;

    //procedure RunCommand(Command: String);
    procedure RePlaseVariables(var VariablesSet: String);
    procedure RePlaseParams(var Params: string);
    Procedure TranslateVal(Var Params: String);
    procedure SetDBStatus(StatusStr: String);
    procedure AddStatus(StatusStr: String; Width: Integer);
    procedure SetStatus(StatusStr: String; StatusNum, Width: Integer);
    procedure DeleteStatus(StatusNum: Integer);
    procedure DeleteAllStatus;
    procedure SetRecNo;
    procedure SetTabIndex(Index: Integer);
    procedure RefreshForm;
    procedure SetVariable(VarName, VValue: string);
    procedure GetChooseValue;
    Function ChooseAndClose(Action: TChooseMode):TReturnFormValue;

    property DialogName: string read FName write FName;
    property CurrentQuery: TDCLQuery read GetMainQuery;
    property DataSource: TDataSource read GetDataSource;
    property CurrentPartQuery: TDCLQuery read GetPartQuery;
    property Tables[Index: Integer]: TDCLGrid read GetTable write SetTable;
    property TablesCount: Integer read GetTablesCount;
    property CurrentTableIndex: Integer read CurrentGridIndex;
    property Form: TDBForm read FForm;
    property ParentForm: TDCLForm read FParentForm;
    property FormNum: Integer read FFormNum;
    property ReturnFormValue:TReturnFormValue read FRetunValue;
  end;

  TDCLCommand=class(TObject)
  private
    FCommandDCL, Spool: TStringList;
    FDCLForm: TDCLForm;
    RetVal:TReturnFormValue;
    FDCLLogOn: TDCLLogOn;
    DCLQuery, DCLQuery2: TDCLDialogQuery;
    Executed, StopFlag, Breaking: Boolean;
    TextReport: TDCLTextReport;
    OfficeReport: TDCLOfficeReport;
    WordReport: TWordReport;
    //DCLBinStore: TDCLBinStore;
    BinStore: TBinStore;
    SpoolFileName: String;

    Procedure ExportData(Tagert: TSpoolType; Scr: String);
    procedure OpenForm(FormName: String; ModalMode: Boolean);
    procedure RePlaseVariabless(var Variables: String);
    procedure RePlaseParamss(var ParamsSet: string; Query: TDCLDialogQuery);
    procedure SetValue(S: String);
    Function ExpressionParser(Expression: String): String;
    Function GetRaightsByContext(InContext: Boolean): TUserLevelsType;
    procedure TranslateVals(var Params: String; Query: TDCLDialogQuery);
    procedure TranslateValContext(var Params: String);
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

    Procedure ExecCommand(Command:String);
    Procedure AddMainItem(Caption, ItemName: String);
    Procedure AddSubItem(Caption, ItemName: String; Level: Integer);
    Procedure AddSubSubItem(Caption, ItemName: String; Level, Index: Integer);
    function FindMenuItemIndex(ItemName: string): Integer;
    function FindSubMenuItemIndex(ItemName: string; Level: Integer): Integer;
  public
    constructor Create(var DCLLogOn: TDCLLogOn; Form: TForm; Relogin: Boolean=False);
    destructor Destroy; override;

    procedure ClickMenu(Sender: TObject);
    procedure UpdateFormBar;

    procedure LockMenu;
    procedure UnLockMenu;
    Procedure ChoseRunType(Command, DCLText, Name: String; Order: Byte);

    property MainForm: TForm read FMainForm;
  end;

  { TDCLLogOn }

  TDCLLogOn=class(TObject)
  private
    FDBLogOn: TDBLogOn;
    {$IFDEF IB}
    IBTransaction: TTransaction;
    {$ENDIF}
    {$IFDEF SQLdbIB}
    IBTransaction: TTransaction;
    {$ENDIF}
    FDCLMainMenu: TDCLMainMenu;
    FMainForm: TForm;
    RoleOK: TLogOnStatus;
    SQLMon: TDCLSQLMon;

    FAccessLevel: TUserLevelsType;
    FForms: Array of TDCLForm;
    ActiveDCLForms: Array of Boolean;
    ReturnFormsValues: Array of TReturnFormValue;
    ShadowQuery: TDCLDialogQuery;
    PassRetries: Byte;
    MessagesTimer: TTimer;
    MessageFormObject: TMessageFormObject;
    ExitFlag, TimeToExit, FUserID: Integer;
    DCLSession: TDCLSession;
    Timer1: TTimer;

    function GetFormsCount: Integer;
    function GetNextForm: Integer;
    function GetForm(Index: Integer): TDCLForm;
    function LoadScrText(ScrName: String): TStringList;

    procedure GetUserName(AUserName: String);
    Function CheckPass(UserName, EnterPass, Password: String): Boolean;

    Procedure WaitNotify(Sender: TObject);
    Procedure LoggingUser(Login: Boolean);
    procedure RunInitSkripts;

    function GetConnected: Boolean;
    Function GetLastFormNum: Integer;
  public
    //Command: TDCLCommand;
    CurrentForm: Integer;
    LogonParams: TLogonParams;
    RoleRaightsLevel: Word;
    Variables: TVariables;
    EvalFormula: string;
    NewLogOn: Boolean;

    constructor Create(DBLogOn: TDBLogOn);
    destructor Destroy; override;

    procedure About(Sender:TObject);
    function Login(UserName, Password: String; ShowForm: Boolean): TLogOnStatus;
    procedure Lock;

    Function ReadConfig(ConfigName, UserID: String): String;
    Procedure WriteConfig(ConfigName, NewValue, UserID: String);
    Function TableExists(TableName: String): Boolean;

    procedure InitActions(Sender: TObject);
    procedure RunCommand(CommandName: String);
    procedure CreateMenu(MainForm: TForm);
    function CreateForm(FormName: String; ParentForm: TDCLForm; Query: TDCLDialogQuery;
      Data: TDataSource; ModalMode: Boolean; ReturnValueMode:TChooseMode;
        ReturnValueParams:TReturnValueParams=nil): TDCLForm;
    Function CloseForm(Form: TDCLForm):TReturnFormValue;
    procedure CloseFormNum(FormNum: Integer);
    procedure SetDBName(Query: TDCLDialogQuery);

    Procedure NotifyForms(Action: TFormsNotifyAction);
    Function GetMainFormNum: Integer;

    Procedure GetTableNames(var List:TStrings);

    procedure RePlaseVariables(Var VariablesSet: String);
    procedure TranslateVal(var S: String);
    procedure ExecVBS(VBSScript: String);
    Procedure ExecShellCommand(ShellCommandText: String);

    Function GetRolesQueryText(QueryType: TSelectType; WhereStr: String): String;

    Function GetConfigInfo: String;
    Function GetConfigVersion: String;
    Function GetFullRaight: Word;

    function ConnectDB: Integer;
    procedure Disconnect;

    property FormsCount: Integer read GetFormsCount;
    property MainForm: TForm read FMainForm;
    property Forms[Index: Integer]: TDCLForm read GetForm;
    property AccessLevel: TUserLevelsType read FAccessLevel;
    property Connected: Boolean read GetConnected;
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
    FEnterPassword, FUserName: string;
    ChangePassForm: TForm;
    OldPassEdit, NewPassEdit1, NewPassEdit2: TEdit;
    OkButton, CancelButton: TDialogButton;
    LabelPass: TDialogLabel;
    HashPassChk: TCheckbox;
    CountShowRole: Word;
    HashPass, FormCreated, NoShowRoleField: Boolean;

    procedure ChangePass(Sender: TObject);

    procedure OnShowForm(Sender: TObject);
    Procedure OnCloseForm(Sender: TObject; Var {%H-}Action: TCloseAction);
    Procedure OnCloseQuery(Sender: TObject; Var CanClose: Boolean);
    Procedure OkButtonClick(Sender: TObject);
    Procedure CancelButtonClick(Sender: TObject);
    Procedure OkChangePass(Sender: TObject);
    Procedure CancelChangePass(Sender: TObject);
    Procedure OnSetHashPassword(Sender: TObject);

    Procedure ShowChangePasswordForm;
    Procedure ChangePassword(AUserID, NewPassword: String);
  public
    constructor Create(var DCLLogOn: TDCLLogOn; UserName: String; NoClose, Relogin: Boolean);
    destructor Destroy; override;

    procedure CreateForm(NoClose, Relogin: Boolean; UserName: String);
    procedure ShowForm;

    property EnterPass: string read FEnterPassword;
    property UserName: String read FUserName;
  end;

  TPrintBase=class(TObject)
    Procedure Print(Grid: TDBGrid; Query: TDCLDialogQuery; Caption: String);
  End;

  { TDCLTextReport }

  TDCLTextReport=class(TObject)
  private
    GlobalSQL, Template, RepParams, HeadLine, Body, Report, Futer, InitSkrypts,
      EndSkrypts: TStringList;
    FDCLLogOn: TDCLLogOn;
    FDCLGrid: TDCLGrid;
    FReportQuery: TDCLDialogQuery;
    GrabValueForm: TForm;
    VarsToControls: array of string;
    FSaved: Boolean;

    procedure RePlaseVariables(Var VarsSet: string);
    Procedure GrabValListOnChange(Sender: TObject);
    Procedure GrabDateOnChange(Sender: TObject);

    Procedure GrabDialogButtonsOnClick(Sender: TObject);

    Procedure ValComboOnChange(Sender: TObject);
    Procedure GrabValOnEdit(Sender: TObject);

    function SetVarToControl(VarName: string): Integer;
  public
    FDialogRes: TModalResult;
    CodePage: TReportCodePage;

    constructor InitReport(DCLLogOn: TDCLLogOn; DCLGrid: TDCLGrid; OPL: TStringList;
      ParamsSet: Cardinal; Mode: TNewQueryMode);
    destructor Destroy; override;
    procedure CloseReport(FileName: String);

    Procedure OpenReport(FileName: String; ViewMode: TReportViewMode);
    Procedure PrintigReport;
    Procedure ReplaseRepParams(Var ReplaseText: TStringList);
    Function TranslateRepParams(ParamName: String): String;
    Function SaveReport(FileName: String): String;

    property DialogRes: TModalResult read FDialogRes;
  end;

  { TWordReport }

{$IFDEF MSWINDOWS}
  TWordReport=class(TObject)
  private
    BinStor: TDCLBinStore;
    FDCLLogOn: TDCLLogOn;
    OfficeDocumentFormat, OfficeTemplateFormat: TOfficeDocumentFormat;
    sQueryToDataSources: Array [0..QCount, 0..QCount] of String;
    RepParams: TStringList;

    procedure RePlaseVariables(Var VarsSet: string);
    Function TranslateRepParams(ParamName: String): String;
    function GetRepSQLArray(RepText: TStringList): TStrArray;
    procedure PrintWordReport(AReport: String; SQLs: TStrArray; ATemplate, AFileName: String);
  public
    constructor Create(DCLLogOn: TDCLLogOn);
    procedure Print(RepName, TemplateName, FileName: string);
  end;
{$ELSE}

  TWordReport=class(TObject)
  public
    constructor Create(DCLLogOn: TDCLLogOn);
  end;
{$ENDIF}

  TDCLOfficeReport=class(TObject)
  private
    BinStor: TDCLBinStore;
    FDCLLogOn: TDCLLogOn;
    FDCLGrid: TDCLGrid;
    OO, Sheets, Sheet, Cell, Range, Desktop, Document, VariantArray: Variant;
{$IFDEF MSWINDOWS}
    MsWord, Excel, WBk: OleVariant;
{$ENDIF}
    WordVer: Byte;
  public
    OfficeDocumentFormat, OfficeTemplateFormat: TOfficeDocumentFormat;

    constructor Create(DCLLogOn: TDCLLogOn; DCLGrid: TDCLGrid);

    Procedure ReportOpenOfficeWriter(ParamStr: String; Save: Boolean);
    Procedure ReportOpenOfficeCalc(ParamStr: String; Save: Boolean);
    Procedure ReportWord(ParamStr: String; Save: Boolean);
    Procedure ReportExcel(ParamStr: String; Save: Boolean);
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

    function GetData(DataName: string; FindType: TFindType): TMemoryStream;
    procedure SetData(DataName, Data: string; FindType: TFindType; Stream: TMemoryStream;
      Compress: Boolean);
    function IsDataExist(DataName: string; FindType: TFindType): Boolean;
    procedure DeleteData(DataName: string; FindType: TFindType);
    procedure ClearData(DataName: string; FindType: TFindType);

    procedure StoreFromFile(FileName, DataName, Data: string; FindType: TFindType; Compress: Boolean);
    procedure SaveToFile(FileName, DataName: string; FindType: TFindType);

    procedure CompressData(DataName, Data: string; FindType: TFindType);
    procedure DeCompressData(DataName, Data: string; FindType: TFindType);

    function MD5(DataName: string; FindType: TFindType):String;

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

    procedure StoreFromFile(FileName, DataName, Data: string; Compress: Boolean);
    procedure SaveToFile(FileName, DataName: string);

    function GetData(DataName: string): TMemoryStream;
    procedure SetData(DataName, Data: string; Stream: TMemoryStream; Compress: Boolean);
    function IsDataExist(DataName: string): Boolean;
    procedure DeleteData(DataName: string);
    procedure ClearData(DataName: string);

    procedure CompressData(DataName, Data: string);
    procedure DeCompressData(DataName, Data: string);

    function MD5(DataName: string):String;

    property ErrorCode;
  end;

  { TDCLBinStore }

  TDCLBinStore=class(TBinStore)
  private
    //
  public
    constructor Create(DCLLogOn: TDCLLogOn);
    destructor Destroy; override;

    Function GetTemplateFile(Template, FileName, Ext: String): String;

    procedure StoreFromFile(FileName, DataName: string; Compress: Boolean);
    procedure SaveToFile(FileName, DataName: string);

    procedure DeleteData(DataName: string);
    procedure ClearData(DataName: string);

    procedure CompressData(DataName: string);
    procedure DeCompressData(DataName: string);

    function MD5(DataName:String):String;

    property ErrorCode;
  end;

{$IFDEF EMBEDDED}
procedure InitDCL(DBLogOn: TDBLogOn);
{$ENDIF}
Procedure EndDCL;


Var
  DCLMainLogOn: TDCLLogOn;
  Params: TStringList;
  Logger: TLogging;

implementation

uses
  uDCLUtils, uDCLStringsRes, SumProps, uDCLDBUtils, uDCLOfficeUtils,
  uDCLDownloader, uLZW;


  { TWordReport }

{$IFDEF MSWINDOWS}
function TWordReport.GetRepSQLArray(RepText: TStringList): TStrArray;
var
  A: TStrArray;
  T, Skobli: String;
  i, c: Word;
  tmpT: TStringList;
begin
  SetLength(A, 0);
  Result:=A;
  Skobli:='[]';

  tmpT:=CopyStrings('[SQLS]', '[END SQLS]', RepText);

  T:=tmpT.Text;
  c:=ParamsCount(T, ';', Skobli);
  SetLength(A, c);

  For i:=1 to c do
    A[i-1]:=GetClearParam(SortParams(T, i, ';', Skobli), Skobli);

  Result:=A;
end;
{$ENDIF}

constructor TWordReport.Create(DCLLogOn: TDCLLogOn);
begin
{$IFDEF MSWINDOWS}
  RepParams:=TStringList.Create;

  BinStor:=TDCLBinStore.Create(DCLLogOn);
  FDCLLogOn:=DCLLogOn;
  OfficeDocumentFormat:=odtMSO;
  OfficeTemplateFormat:=odtMSO;
{$ENDIF}
end;

{$IFDEF MSWINDOWS}

procedure TWordReport.Print(RepName, TemplateName, FileName: string);
var
  tmpDCL, tmpDCL2: TStringList;
  DCLQuery, RepParamsSet: TDCLDialogQuery;
  RecCount, ParamsSet: Integer;
  Ext, TemplateFileName: String;
begin
  DCLQuery:=TDCLDialogQuery.Create(nil);
  DCLQuery.Name:='WordReportQuery_'+IntToStr(UpTime);
  FDCLLogOn.SetDBName(DCLQuery);
  DCLQuery.SQL.Clear;
  tmpDCL:=TStringList.Create;

  DCLQuery.SQL.Text:='select Count(*) from '+GPT.DCLTable+' where '+GPT.UpperString+GPT.DCLNameField
    +GPT.UpperStringEnd+'='+GPT.UpperString+GPT.StringTypeChar+RepName+GPT.StringTypeChar+
    GPT.UpperStringEnd;
  DCLQuery.Open;
  RecCount:=DCLQuery.Fields[0].AsInteger;
  ParamsSet:=0;
  If RecCount=1 Then
  Begin
    DCLQuery.Close;
    DCLQuery.SQL.Text:='select * from '+GPT.DCLTable+' where '+GPT.UpperString+GPT.DCLNameField+
      GPT.UpperStringEnd+'='+GPT.UpperString+GPT.StringTypeChar+RepName+GPT.StringTypeChar+
      GPT.UpperStringEnd;
    DCLQuery.Open;
    tmpDCL.Text:=DCLQuery.FieldByName(GPT.DCLTextField).AsString;
    ParamsSet:=DCLQuery.FieldByName(GPT.IdentifyField).AsInteger;
  End;

  // ParamsSet
  If ParamsSet<>0 Then
  Begin
    RepParamsSet:=TDCLDialogQuery.Create(Nil);
    RepParamsSet.Name:='Command_'+IntToStr(UpTime);
    FDCLLogOn.SetDBName(RepParamsSet);
    RepParamsSet.SQL.Text:=FDCLLogOn.GetRolesQueryText(qtCount, ' s.'+GPT.ParentFlgField+'='+
      IntToStr(ParamsSet));
    RepParamsSet.Open;
    RecCount:=RepParamsSet.Fields[0].AsInteger;
    If RecCount>0 Then
    Begin
      RepParamsSet.Close;
      RepParamsSet.SQL.Text:=FDCLLogOn.GetRolesQueryText(qtSelect, ' s.'+GPT.ParentFlgField+'='+
        IntToStr(ParamsSet));
      RepParamsSet.Open;

      While Not RepParamsSet.Eof Do
      Begin
        RepParams.Append(Trim(RepParamsSet.FieldByName(GPT.DCLNameField)
          .AsString));
        RepParams.Append(Trim(RepParamsSet.FieldByName(GPT.DCLTextField)
          .AsString));
        RepParamsSet.Next;
      End;
    End;
    RepParamsSet.Close;
    FreeAndNil(RepParamsSet);
  End;

  tmpDCL2:=CopyStrings('[DATASETS]', '[END DATASETS]', tmpDCL);

  RePlaseVariables(FileName);
  If FileName='' then
    FileName:=IncludeTrailingPathDelimiter(AppConfigDir)+'Report.doc';

  RepParams:=CopyStrings('[PARAMS]', '[END PARAMS]', tmpDCL);

  Case OfficeTemplateFormat Of
  odtMSO:
  Ext:='doc';
  odtOO, odtPossible:
  Ext:='odt';
  End;

  TemplateFileName:=BinStor.GetTemplateFile(TemplateName, FileName, Ext);
  If BinStor.ErrorCode=0 Then
    If FileExists(TemplateFileName) Then
      PrintWordReport(tmpDCL2.Text, GetRepSQLArray(tmpDCL), TemplateFileName, FileName);
end;

procedure TWordReport.PrintWordReport(AReport: String; SQLs: TStrArray;
  ATemplate, AFileName: String);
const
  AddFileName='-';
Var
  NotReloadedFlags: array [1..QCount] of TQueryBehavior;
  mQueries: Array [1..QCount] of TDCLDialogQuery;
  mDataSources: Array [1..QCount] of TDataSource;
  Templates: array [1..10] of string;
  i, m, vParamIndex, vQueryIndex, vDataSourceIndex: Integer;
  St: Cardinal;
  vType: TDataSetType;
  Pn, Pc, ppn, ppc, TemplatesCounter, TemplatesCount: Byte;
  vGenStrSection, vStrTmp1, vStrTmp2, ParamName: String;
  AllOk, TemplateExists, FirstRun: Boolean;
  IBDQ: TDataSet;
  Errors: Boolean;
  PrintWord: TPrintDoc;
  LogObj: TLogging;
  FFactor: Word;
  dmData: TDataModule;
  FReportOutputType: TReportType;

  Function FindQuery(QName: String): TDCLDialogQuery;
  Begin
    Result:=(dmData.FindComponent(QName) as TDCLDialogQuery);
  End;

  Function GetTimeFormat(mSec: Cardinal): String;
  Var
    h, m, S: Cardinal;
  Begin
    h:=mSec div 3600000;
    Dec(mSec, h*3600000);
    m:=mSec div 60000;
    Dec(mSec, m*60000);
    S:=mSec div 1000;
    Dec(mSec, S*1000);

    Result:=IntToStr(h)+' ч. '+IntToStr(m)+' м. '+IntToStr(S)+' с. '+IntToStr(mSec)+' мсек.';
  End;

  Function CreateQuery: TDCLDialogQuery;
  Begin
    try
      Result:=TDCLDialogQuery.Create(dmData);
      Result.Name:='WRQ_'+IntToStr(UpTime);
      FDCLLogOn.SetDBName(Result);
      Result.Close;
      Result.SQL.Clear;
    Except
      Result:=nil;
    End
  End;

  Function TrimSQLComment(SQLText: String): String;
  var
    p1, p2: Word;
  Begin
    p1:=Pos('/*', SQLText);
    p2:=Pos('*/', SQLText);
    If ((p1>0)and(p1<p2)) then
      Delete(SQLText, p1, p2-p1);
    Result:=SQLText;
  End;

  Procedure SetParams(var DestQuery: TDCLDialogQuery; SourceFieldsSet: TFields);
  var
    pv1: Word;
    MQF: TFields;
  Begin
{$IFDEF BDE_or_IB}
    If (DestQuery<>nil)and(SourceFieldsSet<>nil) then
      If SourceFieldsSet.Count>0 then
        If DestQuery.{$IFDEF PARAMS2}Params.Count{$ELSE}ParamCount{$ENDIF}>0 then
        Begin
          If Assigned(DestQuery.DataSource) then
          Begin
            If Assigned(DestQuery.DataSource.DataSet) then
            Begin
              MQF:=DestQuery.DataSource.DataSet.Fields;

              For pv1:=0 to DestQuery.{$IFDEF PARAMS2}Params.Count{$ELSE}ParamCount{$ENDIF}-1 do
              Begin
                If not Assigned(MQF.FindField(DestQuery.Params[pv1].Name)) then
                  If Assigned(SourceFieldsSet.FindField(DestQuery.Params[pv1].Name)) then
                    DestQuery.Params[pv1].Value:=
                      SourceFieldsSet.FieldByName(DestQuery.Params[pv1].Name).Value;
              End;
            End;
          End
          Else
            For pv1:=0 to DestQuery.{$IFDEF PARAMS2}Params.Count{$ELSE}ParamCount{$ENDIF}-1 do
            Begin
              If Assigned(SourceFieldsSet.FindField(DestQuery.Params[pv1].Name)) then
                DestQuery.Params[pv1].Value:=SourceFieldsSet.FieldByName
                  (DestQuery.Params[pv1].Name).Value;
            End;
        End;
{$ENDIF}
  End;

  procedure ProcessingQuery(QueryNum: Byte);
  var
    QSQLText: String;
    Pc: Byte;
  begin
    QSQLText:=mQueries[QueryNum].SQL.Text;
    If Length(TrimSQLComment(QSQLText))>11 then
    Begin
      try
        For Pc:=1 to QCount do
        Begin
          If sQueryToDataSources[QueryNum][Pc]<>'' then
          Begin
            IBDQ:=nil;
            try
              If Assigned(dmData.FindComponent(sQueryToDataSources[QueryNum][Pc])) then
                If dmData.FindComponent(sQueryToDataSources[QueryNum][Pc]) is TDCLDialogQuery then
                  IBDQ:=dmData.FindComponent(sQueryToDataSources[QueryNum][Pc]) as TDataSet;
              If dmData.FindComponent(sQueryToDataSources[QueryNum][Pc]) is TDataSource then
                If mQueries[QueryNum].DataSource<>
                  (dmData.FindComponent(sQueryToDataSources[QueryNum][Pc]) as TDataSource) then
                  IBDQ:=(dmData.FindComponent(sQueryToDataSources[QueryNum][Pc])
                    as TDataSource).DataSet;

              If Assigned(IBDQ) then
              Begin
                SetParams(mQueries[QueryNum], IBDQ.Fields);
                { If (IBDQ is TIBQuery)or(IBDQ is TIBDataSet) then
                  dmReport[ACurrentForm].DMForm.VariablesClass.RePlaceParams(QSQLText, IBDQ as TIBCustomDataSet, False); }
              End;
            Except
              LogObj.WriteLog('...Ошибка интерпритации параметров/ '+sQueryToDataSources
                [QueryNum][Pc]);
              Errors:=true;
            End;
          End;

          // If Assigned(mQueries[QueryNum].DataSource) then RePlaceParams(QSQLText, (mQueries[QueryNum].DataSource.DataSet as TIBCustomDataSet), False);
        End;

        // RePlaceParams(QSQLText, dmData.dmReport[ACurrentForm].DMForm.idsAReportLst, False);

        LogObj.WriteLog('Обработка['+IntToStr(QueryNum)+']... Query:'+mQueries[QueryNum].Name);
        If Assigned(mQueries[QueryNum].DataSource) then
          LogObj.WriteLog('     Data source: '+mQueries[QueryNum].DataSource.Name);
        LogObj.WriteLog('========SQL begin========');
        LogObj.WriteLog(QSQLText);
        LogObj.WriteLog('========SQL end==========');
        LogObj.WriteLog('Пытаемся открыть....');
        If IsReturningQuery(mQueries[QueryNum].SQL.Text) then
        Begin
          St:=GetTickCount;
          mQueries[QueryNum].Open;
          // mQueries[QueryNum].FetchAll;
          LogObj.WriteLog('... Успешно.');
          LogObj.WriteLog('Время выполнения: '+GetTimeFormat(GetTickCount-St));
          LogObj.WriteLog('Количество записей: '+IntToStr(mQueries[QueryNum].RecordCount));
          LogObj.WriteLog('');
          // mQueries[QueryNum].FetchAll;
        End
        else
        Begin
          mQueries[QueryNum].ExecSQL;
          LogObj.WriteLog('... Выполнен.');
        End;

      Except
        On E: Exception do
        Begin
          LogObj.WriteLog('Query['+IntToStr(QueryNum)+']: '+mQueries[QueryNum].Name);
          LogObj.WriteLog('Текст ошибки :');
          LogObj.WriteLog(E.Message);
          LogObj.WriteLog('----------------------------');
          AllOk:=False;
          Errors:=true;
        End;
      End;
    End
    else
    Begin
      LogObj.WriteLog('Обработка['+IntToStr(QueryNum)+']... Query:'+mQueries[QueryNum].Name);
      LogObj.WriteLog('... Пустое SQL предложение.');
    End;
    LogObj.WriteLog('');
  end;

Begin
  FFactor:=0;
  vQueryIndex:=0;
  vDataSourceIndex:=0;
  vGenStrSection:='';
  Errors:=False;
  FReportOutputType:=rtWord;
  dmData:=TDataModule.Create(nil);

  try
    AllOk:=true;
    LogObj:=TLogging.Create(IncludeTrailingPathDelimiter(AppConfigDir)+'DebugReportLog.txt', GPT.DebugOn);

    LogObj.WriteLog('----------------------------------------');
    LogObj.WriteLog('');
    LogObj.WriteLog('');

    FDCLLogOn.TranslateVal(AReport);
    FDCLLogOn.TranslateVal(ATemplate);
    TranslateProc(ATemplate, FFactor);
    TemplatesCount:=ParamsCount(ATemplate, ',');

    TemplateExists:=true;
    If TemplatesCount>1 then
    Begin
      LogObj.WriteLog('Файлы шаблонов ('+IntToStr(TemplatesCount)+') :');
      For TemplatesCounter:=1 to TemplatesCount do
      Begin
        vStrTmp1:=SortParams(ATemplate, TemplatesCounter);
        LogObj.WriteLog('Файл шаблона №'+IntToStr(TemplatesCounter)+' : '+vStrTmp1);
        TemplateExists:=FileExists(vStrTmp1);
        If TemplateExists then
          Templates[TemplatesCounter]:=vStrTmp1;
        If not TemplateExists then
        Begin
          LogObj.WriteLog('Файл шаблона не найден : '+Templates[TemplatesCounter]);
          break;
        End;
      End;
    End
    Else
    Begin
      TemplateExists:=FileExists(ATemplate);
      Templates[1]:=ATemplate;
      LogObj.WriteLog('Файл шаблона : '+ATemplate);
    End;

    TemplatesCounter:=1;
    If TemplateExists then
    Begin
      Case FReportOutputType of
      rtWord:
      begin
        PrintWord:=TPrintDoc.Create(dmData, otOpOffice, LogObj);
        LogObj.WriteLog('Веррсия PrintWord: '+PrintWord.Version);
        Case PrintWord.OfficeType of
        otNone:
        LogObj.WriteLog('Не установлен никакой офис.');
        otMSOffice:
        LogObj.WriteLog('Тип офиса : MS');
        otOpOffice:
        LogObj.WriteLog('Тип офиса : Open/Libre Office');
        End;
        LogObj.WriteLog('');
      end;
      End;

      For Pc:=1 to QCount do
        For i:=1 to QCount do
          sQueryToDataSources[Pc][i]:='';

      Pc:=ParamsCount(AReport, ';', '');
      For Pn:=1 to Pc do
      Begin
        vGenStrSection:=LowerCase(Trim(SortParams(AReport, Pn, ';', '')));
        If (vGenStrSection='')or(Pos('//', vGenStrSection)<>0) then
          Continue;
        i:=2;
        Case vGenStrSection[1] of
        'q':
        Begin
          inc(vQueryIndex);
          mQueries[vQueryIndex]:=CreateQuery;
          mQueries[vQueryIndex].Tag:=vQueryIndex;
          vType:=dstIBQ;
        End;
        'd':
        Begin
          inc(vDataSourceIndex);
          mDataSources[vDataSourceIndex]:=TDataSource.Create(dmData);
          mDataSources[vDataSourceIndex].Tag:=vDataSourceIndex;
          vType:=dstDataSet;
        End
      else
      Begin
        i:=1;
        inc(vQueryIndex);
        mQueries[vQueryIndex]:=CreateQuery;
        mQueries[vQueryIndex].Tag:=vQueryIndex;
        vType:=dstIBQ;
      End;
        End;

        vStrTmp1:='';
        If i<Length(vGenStrSection) then
          while (not(vGenStrSection[i] in ['(', '['])) do
          Begin
            vStrTmp1:=vStrTmp1+vGenStrSection[i];
            inc(i);
            If i>Length(vGenStrSection) then
              break;
          End;
        Case vType of
        dstIBQ:
        Begin
          If Pos('+', vStrTmp1)<>0 then
          Begin
            Delete(vStrTmp1, Pos('+', vStrTmp1), 1);
            NotReloadedFlags[vQueryIndex]:=qbNotReload;
          End
          Else If Pos('-', vStrTmp1)<>0 then
          Begin
            Delete(vStrTmp1, Pos('-', vStrTmp1), 1);
            NotReloadedFlags[vQueryIndex]:=qbEnding;
          End
          Else
            NotReloadedFlags[vQueryIndex]:=qbNormal;

          mQueries[vQueryIndex].Name:=Trim(vStrTmp1);

          vStrTmp1:=SQLs[vQueryIndex-1];
          FDCLLogOn.TranslateVal(vStrTmp1);
          mQueries[vQueryIndex].SQL.Text:=vStrTmp1;
        End;
        dstDataSet:
        mDataSources[vDataSourceIndex].Name:=Trim(vStrTmp1);
        End;
        /// ///////////////////////////////////////////////////////////////////////////////////////////////
        vStrTmp1:='';
        If i<Length(vGenStrSection) then
          If vGenStrSection[i]='[' then
          Begin
            inc(i);
            vStrTmp1:='';
            If i<length(vGenStrSection) then
              while (vGenStrSection[i]<>']') do
              Begin
                vStrTmp1:=vStrTmp1+vGenStrSection[i];
                inc(i);
                If i>Length(vGenStrSection) then
                  break;
              End;

            ppc:=ParamsCount(vStrTmp1, ',');
            For ppn:=1 to ppc do
            Begin
              If IsReturningQuery(mQueries[vQueryIndex].SQL.Text) then
              Begin
                mQueries[vQueryIndex].FieldDefs.Update;
                vStrTmp2:=Trim(SortParams(vStrTmp1, ppn, ','));
                If vStrTmp2<>'' then
                Begin
                  ParamName:=Copy(vStrTmp2, 1, Pos('=', vStrTmp2)-1);
                End;
              End;
            End;
          End;

        inc(i);
        ParamName:='';
        If i<Length(vGenStrSection) then
          while (not(vGenStrSection[i] in ['(', ')', ' ', ';'])) do
          Begin
            ParamName:=ParamName+vGenStrSection[i];
            inc(i);
            If i>Length(vGenStrSection) then
              break;
          End;
        ParamName:=LowerCase(ParamName);

        If Pos(',', ParamName)<>0 then
        Begin
          ppc:=ParamsCount(ParamName, ',');
          For ppn:=1 to ppc do
          Begin
            vStrTmp1:=Trim(SortParams(ParamName, ppn, ','));
            If vStrTmp1<>'' then
            Begin
              If vType=dstIBQ then
                If dmData.FindComponent(vStrTmp1) is TDataSource then
                  mQueries[vQueryIndex].DataSource:=dmData.FindComponent(vStrTmp1) as TDataSource;
              If not(dmData.FindComponent(vStrTmp1) is TDataSource) then
                sQueryToDataSources[vQueryIndex][ppn]:=vStrTmp1;
            End;
          End;
        End
        else
          Case vType of
          dstIBQ:
          Begin
            If Trim(ParamName)<>'' then
            Begin
              If dmData.FindComponent(ParamName) is TDCLDialogQuery then
              Begin
                sQueryToDataSources[vQueryIndex][1]:=ParamName;
              End
              else
                For m:=0 to dmData.ComponentCount-1 do
                  If ((dmData.Components[m] is TDataSource)and
                    (LowerCase(dmData.Components[m].Name)=Trim(ParamName))) then
                    mQueries[vQueryIndex].DataSource:=(dmData.Components[m]) as TDataSource;
            End;
          End;
          dstDataSet:
          Begin
            If Trim(ParamName)<>'' then
            Begin
              For m:=0 to dmData.ComponentCount-1 do
                If ((dmData.Components[m] is TDCLDialogQuery)and
                  (LowerCase(dmData.Components[m].Name)=Trim(ParamName))) then
                  mDataSources[vDataSourceIndex].DataSet:=(dmData.Components[m]) as TDCLDialogQuery;
            End
            else
              mDataSources[vDataSourceIndex].DataSet:=mQueries[vQueryIndex];
          End;
          End;
      End;

      FirstRun:=true;
      For TemplatesCounter:=1 to TemplatesCount do
      Begin
        LogObj.WriteLog('Время старта: '+TimeToStr(Now));
        LogObj.WriteLog('');
        For i:=1 to vQueryIndex do
        Begin
          If Assigned(mQueries[i]) then
            If NotReloadedFlags[i]<>qbEnding then
              If FirstRun or(not(NotReloadedFlags[i]=qbNotReload)) then
                ProcessingQuery(i);
        End;

        FirstRun:=False;
        If AllOk then
          LogObj.WriteLog('Все SQL-запросы выполнены без ошибок!');

        LogObj.WriteLog('');

        Case FReportOutputType of
        rtWord:
        begin
          LogObj.WriteLog('Генерация отчёта...');
          PrintWord:=TPrintDoc.Create(dmData, otMSOffice, LogObj);
          Try
            PrintWord.PrintTemplate(Templates[TemplatesCounter], GPT.DebugOn);
          Except
            On E: Exception do
            Begin
              LogObj.WriteLog('Ошибка генерации отчёта:');
              LogObj.WriteLog('  Текст ошибки :');
              LogObj.WriteLog(E.Message);
              LogObj.WriteLog('...НЕ успешно.');
              Errors:=true;
            End;
          end;
          If not Errors then
            LogObj.WriteLog('...Успешно.');

          If PrintWord.OfficeType=otMSOffice then
            LogObj.WriteLog('Версия MS офис : '+IntToStr(PrintWord.MSOVer));

          LogObj.WriteLog('[PrintVariables]');
          For i:=1 to FDCLLogOn.Variables.VariablesList.Count do
          Begin
            vStrTmp1:=TVariable(FDCLLogOn.Variables.VariablesList[i-1]^).Name;
            vStrTmp2:=TVariable(FDCLLogOn.Variables.VariablesList[i-1]^).Value;

            If PrintWord.Find(PrintWord.MarkerStr+vStrTmp1+PrintWord.MarkerStr) then
              PrintWord.FindAndReplace(PrintWord.MarkerStr+vStrTmp1+PrintWord.MarkerStr, vStrTmp2);

            LogObj.WriteLog(vStrTmp1+'='+vStrTmp2);
          End;

          LogObj.WriteLog('----------------------------------------------------------');
          LogObj.WriteLog('');

          If RepParams.Count>0 then
          Begin
            vParamIndex:=0;
            For i:=1 to RepParams.Count div 2 do
            Begin
              vStrTmp1:=Copy(RepParams[vParamIndex], 2, Length(RepParams[vParamIndex])-1);
              vStrTmp2:=TranslateRepParams(RepParams[vParamIndex]);

              If PrintWord.Find(PrintWord.MarkerStr+vStrTmp1+PrintWord.MarkerStr) then
                PrintWord.FindAndReplace(PrintWord.MarkerStr+vStrTmp1+PrintWord.MarkerStr,
                  vStrTmp2);

              LogObj.WriteLog(vStrTmp1+'='+vStrTmp2);

              inc(vParamIndex, 2);
            End;
          End;

          LogObj.WriteLog('Сохранение в : '+AFileName);
          PrintWord.SaveReport(AFileName);
          LogObj.WriteLog('Запуск документа ...');
          PrintWord.ShowReport;
        end;
        End;

        LogObj.WriteLog('');
        LogObj.WriteLog('Время финиша: '+TimeToStr(Now));
        LogObj.WriteLog('');
      End;

      LogObj.WriteLog('Обработка завершающих Query.');
      For i:=1 to vQueryIndex do
      Begin
        If Assigned(mQueries[i]) then
          If NotReloadedFlags[i]=qbEnding then
          Begin
            ProcessingQuery(i);
          End;
      End;
    End
    Else
    Begin
      Errors:=true;
      LogObj.WriteLog('Файл шаблона не найден!!!');
      LogObj.WriteLog(Templates[TemplatesCounter]);
    End;

    LogObj.WriteLog('=====================================');
    LogObj.WriteLog('');
    LogObj.WriteLog('=====Конец блока выполнения=====');
    LogObj.WriteLog('');
  finally
    Try
      If Errors then
      Begin
        LogObj.WriteLog('');
        LogObj.WriteLog('!!!!!!!!Что-то пошло не так.!!!!!!!!');
        LogObj.WriteLog('');
      End;

      LogObj.WriteLog('');
      LogObj.WriteLog('-=End debug message=-');

      {For i:=1 to QCount do
        If Assigned(mQueries[i]) then
          FreeAndNil(mQueries[i]);

      For i:=1 to QCount do
        If Assigned(mDataSources[i]) then
          FreeAndNil(mDataSources[i]);}

      Case FReportOutputType of
      rtWord:
      FreeAndNil(PrintWord);
      End;

      If Errors or GPT.DebugOn then
      Begin
        ExecApp('DebugSQLLog.txt');
      End;
    finally
      ///
    End;
  End;
end;

procedure TWordReport.RePlaseVariables(var VarsSet: string);
begin
  FDCLLogOn.TranslateVal(VarsSet);
end;

function TWordReport.TranslateRepParams(ParamName: String): String;
Var
  ParamFieldNum: Byte;
  ParamNum: Word;
  ResultString, ReturnField, tmpSQL1: String;
  ParamsQuery: TReportQuery;
Begin
  ParamNum:=0;
  While (UpperCase(RepParams[ParamNum])<>UpperCase(Trim(ParamName)))And
    (ParamNum+1<>RepParams.Count) Do
    inc(ParamNum);
  If FindParam('SQL=', RepParams[ParamNum+1])<>'' Then
  Begin
    ParamsQuery:=TReportQuery.Create(Nil);
    FDCLLogOn.SetDBName(ParamsQuery);
    tmpSQL1:=FindParam('SQL=', RepParams[ParamNum+1]);
    RePlaseVariables(tmpSQL1);
    ParamsQuery.SQL.Text:=tmpSQL1;
    Try
      ParamsQuery.Open;
      If GPT.DebugOn Then
        DebugProc('Report param SQL query: '+tmpSQL1);
    Except
      ShowErrorMessage(-1109, RepParams[ParamNum]+' / SQL='+tmpSQL1);
    End;

    ReturnField:=FindParam('ReturnField=', RepParams[ParamNum+1]);
    DeleteNonPrintSimb(ReturnField);
    ResultString:='';
    If ReturnField='' Then
    Begin
      While Not ParamsQuery.Eof Do
      Begin
        tmpSQL1:='';
        For ParamFieldNum:=0 To ParamsQuery.FieldCount-1 Do
        Begin
          tmpSQL1:=tmpSQL1+TrimRight(ParamsQuery.Fields[ParamFieldNum].AsString);
        End;

        ResultString:=ResultString+tmpSQL1+#10;
        ParamsQuery.Next;
      End;
    End
    Else
    Begin
      While Not ParamsQuery.Eof Do
      Begin
        ResultString:=ResultString+TrimRight(ParamsQuery.FieldByName(ReturnField).AsString)+#10;
        ParamsQuery.Next;
      End;
    End;

    ResultString:=Copy(ResultString, 1, Length(ResultString)-1);
    RePlaseVariables(ResultString);

    ParamsQuery.Close;
    FreeAndNil(ParamsQuery);
  End
  Else
  Begin
    ResultString:=FindParam('ReturnValue=', RepParams[ParamNum+1]);
    DeleteNonPrintSimb(ResultString);
    RePlaseVariables(ResultString);
  End;
  Result:=ResultString;
End;
{$ENDIF}
{ TVariables }

function TVariables.FindEmptyVariableSlot: Integer;
Var
  i: Integer;
Begin
  For i:=0 to length(FVariables)-1 do
  begin
    If FVariables[i].Name='' then
    Begin
      Result:=i;
      break;
    End;
  end;
  i:=length(FVariables);
  SetLength(FVariables, i+1);
  Result:=i;
End;

procedure TVariables.SetVariableByName(const VariableName, Value: String);
Var
  vv1: Integer;
  SumLabel, PayLabel: String;
Begin
  vv1:=VariableNumByName(VariableName);
  If vv1<>-1 Then
    FVariables[vv1].Value:=Value;
end;

Function TVariables.VariableNumByName(Const VariableName: String): Integer;
Var
  VarNum: Integer;
Begin
  Result:=-1;
  If VariableName<>'' Then
  Begin
    For VarNum:=0 to length(FVariables)-1 do
      If LowerCase(FVariables[VarNum].Name)=LowerCase(Trim(VariableName)) Then
      Begin
        Result:=VarNum;
        break;
      End;
  End;
End;

constructor TVariables.Create(var DCLLogOn: TDCLLogOn; DCLForm: TDCLForm);
begin
  FDCLLogOn:=DCLLogOn;
  FDCLForm:=DCLForm
end;

Function TVariables.Exists(Const VariableName: String): Boolean;
Var
  VarNum: Integer;
Begin
  Result:=False;
  For VarNum:=0 To length(FVariables)-1 Do
    If UpperCase(Trim(VariableName))=UpperCase(FVariables[VarNum].Name) Then
    Begin
      Result:=true;
      break;
    End;
End;

Function TVariables.GetVariableByName(Const VariableName: String): String;
Var
  vv1: Integer;
Begin
  Result:='';
  vv1:=VariableNumByName(VariableName);
  If vv1<>-1 Then
    Result:=FVariables[vv1].Value;
End;

Procedure TVariables.NewVariable(const VariableName: String; Value: string='');
Var
  RetVarNum: Integer;
Begin
  RetVarNum:=VariableNumByName(VariableName);
  If RetVarNum=-1 Then
  Begin
    RetVarNum:=FindEmptyVariableSlot;
    If RetVarNum<>-1 then
    Begin
      FVariables[RetVarNum].Name:=Trim(VariableName);
      FVariables[RetVarNum].Value:=Value;
    End;
  End
  Else
  Begin
    FVariables[RetVarNum].Value:=Value;
  End;
End;

Procedure TVariables.FreeVariable(const VariableName: string);
Var
  VarNum: Integer;
Begin
  If VariableName<>'' Then
  Begin
    VarNum:=VariableNumByName(VariableName);
    If VarNum<>-1 Then
    Begin
      If VarNum<length(FVariables) Then
      Begin
        FVariables[VarNum].Name:='';
        FVariables[VarNum].Value:='';
      End;
    End;
  End;
End;

Function TVariables.GetAllVariables: TList;
Var
  vv1: Integer;
Begin
  Result:=TList.Create;
  Result.Clear;
  If length(FVariables)>0 Then
  Begin
    For vv1:=0 To length(FVariables)-1 Do
      Result.Add(@FVariables[vv1]);
  End;
End;

Procedure TVariables.RePlaseVariables(Var VariablesSet: String; Query: TDCLDialogQuery);
Const
  MaxSysVars=48;
  SysVarsSet: Array [1..MaxSysVars] Of String=('_TIME_', '_TIMES_', '_DATE_', '_DATETIME_', // 4
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
    '_APPDATAPATH_', '_OS_', '_MAC_', '_USERPROFILE_', '_USERDOC_'); // 48
Var
  ReplaseVar, TmpStr: String;
  StartSel, ParamLen, StartSearch, pv1, pv2, pv3, FindVarNum, VarNameLength, MaxMatch: Integer;
  VarExists, SysVar, FindVar: Boolean;
Begin
  StartSearch:=Pos(VariablePrefix, VariablesSet);
  While Pos(VariablePrefix, Copy(VariablesSet, StartSearch, Length(VariablesSet)))<>0 Do
  Begin
    StartSearch:=StartSearch+Pos(VariablePrefix, Copy(VariablesSet, StartSearch,
      Length(VariablesSet)))-1;
    StartSel:=StartSearch+Length(VariablePrefix)-1;
    ParamLen:=Length(VariablesSet);
    SysVar:=False;
    If ParamLen<>0 Then
    Begin
      FindVarNum:=-1;
      MaxMatch:=0;

      pv3:=0;
      While (length(FVariables)>pv3) Do
      Begin
        FindVar:=true;
        pv2:=1;
        pv1:=StartSel+1;
        While (FindVar)And(pv1<=ParamLen)And(pv2<=length(FVariables[pv3].Name)) Do
        Begin
          FindVar:=False;
          If length(FVariables[pv3].Name)>=pv2 Then
          Begin
            If UpperCase(VariablesSet[pv1])=UpperCase(FVariables[pv3].Name[pv2]) Then
            Begin
              FindVar:=true;
              If MaxMatch<pv1 Then
              Begin
                MaxMatch:=pv1;
                FindVarNum:=pv3;
              End;
            End;
          End;
          inc(pv1);
          inc(pv2);
        End;
        inc(pv3);
      End;

      If FindVarNum=-1 then
      Begin
        pv3:=1;
        while (MaxSysVars>=pv3) do
        Begin
          FindVar:=true;
          pv2:=1;
          pv1:=StartSel+1;
          while (FindVar)and(pv1<=ParamLen)and(pv2<=length(SysVarsSet[pv3])) do
          Begin
            FindVar:=False;
            If length(SysVarsSet[pv3])>=pv2 then
            Begin
              If UpperCase(VariablesSet[pv1])=UpperCase(SysVarsSet[pv3][pv2]) then
              Begin
                FindVar:=true;
                If MaxMatch<pv1 then
                Begin
                  MaxMatch:=pv1;
                  FindVarNum:=pv3;
                  SysVar:=true;
                End;
              End;
            End;
            inc(pv1);
            inc(pv2);
          End;
          inc(pv3);
        End;
      End;

      If FindVarNum<>-1 Then
      Begin
        VarNameLength:=MaxMatch-StartSel;
        ReplaseVar:=Copy(VariablesSet, StartSel+1, VarNameLength);
      End
      Else
      Begin
        VarNameLength:=0;
        ReplaseVar:='';
      End;

      if SysVar and(FindVarNum<>-1) then
      Begin
        Case FindVarNum Of
        1:
        Begin
          TmpStr:=TimeToStr_(SysUtils.Time);
          If (TmpStr[5]=':') Then
            SetLength(TmpStr, 4);
          If (TmpStr[6]=':') Then
            SetLength(TmpStr, 5);
        End;
        2:
        TmpStr:=TimeToStr_(SysUtils.Time);
        3:
        TmpStr:=DateToStr_(Date);
        4:
        TmpStr:=TimeStampToStr(Date);
        5:
        TmpStr:=Version;
        6:
        Begin
          If (Query.Eof And Query.Bof) Then
            TmpStr:='1'
          Else
            TmpStr:='0';
        End;
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
        Begin
          If Query.Bof Then
            TmpStr:='1'
          Else
            TmpStr:='0';
        End;
        24:
        Begin
          If Query.Eof Then
            TmpStr:='1'
          Else
            TmpStr:='0';
        End;
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
        TmpStr:=SourceToInterface(GetDCLMessageString(msAccessLevelsSet));
        35:
        TmpStr:=IntToStr(Ord(FDCLLogOn.AccessLevel));
        36:
        TmpStr:=IntToStr(Ord(FDCLForm.UserLevelLocal));
        37:
        TmpStr:=SourceToInterface(GetDCLMessageString(msNotifyActionsSet));
        38:
        TmpStr:=SourceToInterface(GetDCLMessageString(msNoYes));
        39:
        TmpStr:=FDCLLogOn.EvalFormula;
        40:
        TmpStr:=IntToStr(Ord(Query.State));
        41:
        TmpStr:=SourceToInterface(GetNameDSState(Query.State));
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
        End;
      End;

      VarExists:=Exists(ReplaseVar);
      If SysVar Then
        VarExists:=true;

      If VarExists Then
      Begin
        Delete(VariablesSet, StartSel, VarNameLength+length(VariablePrefix));
        If Not SysVar Then
          TmpStr:=Variables[ReplaseVar];
        Insert(TmpStr, VariablesSet, StartSel);
        inc(StartSearch, Length(TmpStr)+length(VariablePrefix));
        TmpStr:='';
      End
      Else
        inc(StartSearch, length(VariablePrefix)+1);
    End;
  End;
End;

{ TLogOnForm }

procedure TLogOnForm.CancelButtonClick(Sender: TObject);
begin
  FDCLLogOn.RoleOK:=lsRejected;
  PressOK:=psCanceled;
  RoleForm.Close;
end;

procedure TLogOnForm.CancelChangePass(Sender: TObject);
Begin
  ChangePassForm.Close;
End;

procedure TLogOnForm.ChangePass(Sender: TObject);
begin
  If Assigned(RoleNameCombo) then
    GPT.DCLUserName:=RoleNameCombo.Text
  Else If Assigned(RoleNameEdit) then
    GPT.DCLUserName:=RoleNameEdit.Text;

  If GPT.DCLUserName<>'' Then
  Begin
    FDCLLogOn.GetUserName(GPT.DCLUserName);
    ShowChangePasswordForm;
  End
  Else
    ShowErrorMessage(0, SourceToInterface(GetDCLMessageString(msEmptyUserName)));
end;

procedure TLogOnForm.ChangePassword(AUserID, NewPassword: String);
Begin
  RolesQuery1.Close;
  If Not HashPass Then
    RolesQuery1.SQL.Text:='update '+UsersTable+' set '+UserPassField+'='+GPT.StringTypeChar+
      NewPassword+GPT.StringTypeChar+' where '+UserIDField+'='+AUserID
  Else
    RolesQuery1.SQL.Text:='update '+UsersTable+' set '+UserPassField+'='+GPT.StringTypeChar+
      HashString(NewPassword)+GPT.StringTypeChar+' where '+UserIDField+'='+AUserID;

  Try
    RolesQuery1.ExecSQL;
  Except
    //
  End;
End;

destructor TLogOnForm.Destroy;
begin
  If Assigned(RoleNameCombo) then
    FreeAndNil(RoleNameCombo);
  If Assigned(RoleNameEdit) then
    FreeAndNil(RoleNameEdit);
  If Assigned(RolePassEdit) then
    FreeAndNil(RolePassEdit);

  If Assigned(RoleForm) then
    RoleForm.Release;
end;

constructor TLogOnForm.Create(var DCLLogOn: TDCLLogOn; UserName: String; NoClose, Relogin: Boolean);
Begin
  FormCreated:=False;
  FUserName:=UserName;
  NoShowRoleField:=False;
  PressOK:=psNone;
  FDCLLogOn:=DCLLogOn;
  If ConnectErrorCode=0 Then
  Begin
    RolesQuery1:=TDCLDialogQuery.Create(nil);
    RolesQuery1.Name:='Roles1_'+IntToStr(UpTime);
    FDCLLogOn.SetDBName(RolesQuery1);

    RolesQuery1.SQL.Text:='select count(*) from '+UsersTable+' where '+GPT.ShowRoleField+'=1';
    Try
      RolesQuery1.Open;
      CountShowRole:=RolesQuery1.Fields[0].AsInteger;
    Except
      CountShowRole:=0;
      NoShowRoleField:=true;
    End;

    If (GPT.ShowRoleField<>'')And((UserName='')or Relogin) Then
    Begin
      If NoShowRoleField Then
      Begin
        RolesQuery1.SQL.Text:='select count(*) from '+UsersTable;
        Try
          RolesQuery1.Open;
          CountShowRole:=RolesQuery1.Fields[0].AsInteger;
        Except
          CountShowRole:=0;
          ShowErrorMessage(-5008, '');
          FDCLLogOn.RoleOK:=lsRejected;
        End;
      End;

      If ConnectErrorCode=0 Then
        CreateForm(NoClose, Relogin, UserName);
    End;
  End
  Else
    FDCLLogOn.RoleOK:=lsRejected;
End;

procedure TLogOnForm.CreateForm(NoClose, Relogin: Boolean; UserName: String);
begin
  FormCreated:=true;
  DebugProc('Create LogOn Form');
  Application.Title:=SourceToInterface('DCLRun '+GetDCLMessageString(msLogonToSystem)+'.');
  RoleForm:=TForm.Create(Nil);
  RoleForm.Caption:=SourceToInterface(GetDCLMessageString(msLogonToSystem));
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
  DCLLogo.Transparent:=true;
  DCLLogo.Stretch:=true;
  DCLLogo.Proportional:=true;

  If (CountShowRole>1)And( { (UserName='') or } not Relogin) Then
  Begin
    If (ConnectErrorCode=0)and not FormCreated Then
      CreateForm(NoClose, Relogin, UserName);

    If NoShowRoleField Then
      RolesQuery1.SQL.Text:='select '+UserNameField+' from '+UsersTable
    Else
      RolesQuery1.SQL.Text:='select '+UserNameField+' from '+UsersTable+' where '+
        GPT.ShowRoleField+'=1';

    RolesQuery1.Open;
    RoleNameCombo:=TComboBox.Create(Panel);
    RoleNameCombo.Parent:=Panel;

    While Not RolesQuery1.Eof Do
    Begin
      RoleNameCombo.Items.Append(RolesQuery1.Fields[0].AsString);
      RolesQuery1.Next;
    End;
    RolesQuery1.Close;
    RoleNameCombo.Text:=AnsiUpperCase(GPT.DCLUserName);
    RoleNameCombo.Top:=BeginStepTop;
    RoleNameCombo.Left:=BeginStepLeft;
    RoleNameCombo.Width:=EditWidth;
  End
  Else
  Begin
    RoleNameEdit:=TEdit.Create(Panel);
    RoleNameEdit.Parent:=Panel;
    RoleNameEdit.Text:=AnsiUpperCase(GPT.DCLUserName);
    RoleNameEdit.Top:=BeginStepTop;
    RoleNameEdit.Left:=BeginStepLeft;
    RoleNameEdit.Width:=EditWidth;
    If (UserName<>'')and not Relogin Then
      RoleNameEdit.ReadOnly:=true;
  End;

  RoleLabel:=TDialogLabel.Create(Panel);
  RoleLabel.Parent:=Panel;
  RoleLabel.Left:=BeginStepLeft;
  RoleLabel.Top:=BeginStepTop-15;
  RoleLabel.Caption:=SourceToInterface(GetDCLMessageString(msUserName));

  RolePassEdit:=TEdit.Create(Panel);
  RolePassEdit.Parent:=Panel;
  RolePassEdit.PasswordChar:='#';

  RoleLabel:=TDialogLabel.Create(Panel);
  RoleLabel.Parent:=Panel;
  RoleLabel.Left:=BeginStepLeft;
  RoleLabel.Top:=BeginStepTop+EditTopStep-15;
  RoleLabel.Caption:=SourceToInterface(GetDCLMessageString(msPassword));

  RoleButtonOK:=TDialogButton.Create(RoleForm);
  RoleButtonOK.Parent:=RoleForm;
  RoleButtonOK.Default:=true;
  RoleButtonOK.Caption:=AnsiToUTF8('Принять');
  RoleButtonOK.Width:=LoginButtonWidth;
  RoleButtonOK.Height:=ButtonHeight;
  RoleButtonOK.OnClick:=OkButtonClick;

  RoleButtonCancel:=TDialogButton.Create(RoleForm);
  RoleButtonCancel.Parent:=RoleForm;
  RoleButtonCancel.Cancel:=true;
  RoleButtonCancel.Caption:=SourceToInterface(GetDCLMessageString(msClose));
  RoleButtonCancel.Width:=LoginButtonWidth;
  RoleButtonCancel.Height:=ButtonHeight;
  If Not NoClose Then
    RoleButtonCancel.OnClick:=CancelButtonClick;

  ChangePassButton:=TDialogButton.Create(RoleForm);
  ChangePassButton.Parent:=RoleForm;
  ChangePassButton.Caption:=SourceToInterface(GetDCLMessageString(msEdit));
  ChangePassButton.Hint:=SourceToInterface(GetDCLMessageString(msEdit)+' '+GetDCLMessageString(msPassword));
  ChangePassButton.ShowHint:=true;
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
  RoleForm.OnCloseQuery:=Nil;
  FEnterPassword:=RolePassEdit.Text;
  RoleForm.Close;
end;

procedure TLogOnForm.OkChangePass(Sender: TObject);
Begin
  GPT.EnterPass:=OldPassEdit.Text;
  // GetUserName(GPT.DCLUserName);
  If GPT.DCLUserPass=GPT.EnterPass Then
  Begin
    ChangePassword(GPT.UserID, NewPassEdit1.Text);
    ChangePassForm.Close;
    RolePassEdit.SetFocus;
  End;
End;

procedure TLogOnForm.OnCloseForm(Sender: TObject; var Action: TCloseAction);
begin
  If PressOK<>psConfirmed then
  Begin
    FDCLLogOn.RoleOK:=lsRejected;
    PressOK:=psCanceled;
  End;
  If Assigned(RolePassEdit) then
    FEnterPassword:=RolePassEdit.Text;
  If Assigned(RoleNameCombo) then
    FUserName:=RoleNameCombo.Text
  Else If Assigned(RoleNameEdit) then
    FUserName:=RoleNameEdit.Text;
end;

procedure TLogOnForm.OnCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose:=False;
end;

procedure TLogOnForm.OnSetHashPassword(Sender: TObject);
Begin
  HashPass:=(Sender as TCheckbox).Checked;
End;

procedure TLogOnForm.OnShowForm(Sender: TObject);
begin
  RolePassEdit.SetFocus;
end;

procedure TLogOnForm.ShowChangePasswordForm;
Begin
  ChangePassForm:=TForm.Create(Nil);
  ChangePassForm.Name:='ChangePassForm';
  ChangePassForm.FormStyle:=fsStayOnTop;
  ChangePassForm.BorderStyle:=bsSingle;
  ChangePassForm.BorderIcons:=[biSystemMenu];
  ChangePassForm.Caption:=SourceToInterface(GetDCLMessageString(msChangePassord)+'.');
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
  OkButton.Caption:=SourceToInterface(GetDCLMessageString(msEdit));
  OkButton.Default:=true;
  OkButton.Top:=BeginStepTop+EditTopStep*4-FilterLabelTop*2;
  OkButton.Left:=BeginStepLeft;

  CancelButton:=TDialogButton.Create(ChangePassForm);
  CancelButton.Parent:=ChangePassForm;
  CancelButton.Name:='CancelButton';
  CancelButton.OnClick:=CancelChangePass;
  CancelButton.Caption:=SourceToInterface(GetDCLMessageString(msCancel));;
  CancelButton.Cancel:=true;
  CancelButton.Top:=BeginStepTop+EditTopStep*4-FilterLabelTop*2;
  CancelButton.Left:=BeginStepLeft+ButtonsInterval+ButtonWidth;

  LabelPass:=TDialogLabel.Create(ChangePassForm);
  LabelPass.Parent:=ChangePassForm;
  LabelPass.Caption:=SourceToInterface(GetDCLMessageString(msOldM)+' '+GetDCLMessageString(msPassword)+':');
  LabelPass.Top:=BeginStepTop-FilterLabelTop*2;
  LabelPass.Left:=BeginStepLeft;

  LabelPass:=TDialogLabel.Create(ChangePassForm);
  LabelPass.Parent:=ChangePassForm;
  LabelPass.Caption:=SourceToInterface(GetDCLMessageString(msNewM)+' '+GetDCLMessageString(msPassword)+':');
  LabelPass.Top:=BeginStepTop+EditTopStep-FilterLabelTop*2;
  LabelPass.Left:=BeginStepLeft;

  LabelPass:=TDialogLabel.Create(ChangePassForm);
  LabelPass.Parent:=ChangePassForm;
  LabelPass.Caption:=SourceToInterface(GetDCLMessageString(msConfirm)+':');
  LabelPass.Top:=(BeginStepTop+EditTopStep*2)-FilterLabelTop*2;
  LabelPass.Left:=BeginStepLeft;

  HashPassChk:=TCheckbox.Create(ChangePassForm);
  HashPassChk.Parent:=ChangePassForm;
  HashPassChk.Caption:=SourceToInterface(GetDCLMessageString(msHashed)+' '+GetDCLMessageString(msPassword));
  HashPassChk.Hint:=SourceToInterface(GetDCLMessageString(msToHashing)+' '+GetDCLMessageString(msPassword));
  HashPassChk.Top:=(BeginStepTop+EditTopStep*3)-FilterLabelTop;
  HashPassChk.Left:=BeginStepLeft;
  HashPassChk.Width:=200;
  HashPassChk.Checked:=GPT.HashPass;
  HashPassChk.Enabled:=not GPT.HashPass;
  HashPassChk.OnClick:=OnSetHashPassword;

  ChangePassForm.ShowModal;
End;

procedure TLogOnForm.ShowForm;
begin
  If not Assigned(RoleForm) then
    CreateForm(False, False, GPT.DCLUserName);
  RoleForm.ShowModal;
end;

{ TDCLForm }

procedure TDCLForm.ActivateForm(Sender: TObject);
begin
  FDCLLogOn.CurrentForm:=FFormNum;
  If ShowFormPanel Then
    If Assigned(FDCLLogOn.FDCLMainMenu) then
      FDCLLogOn.FDCLMainMenu.UpdateFormBar;

  If Assigned(Tables[-1]) then
    If Tables[-1].Query.Active then
      Tables[-1].ScrollDB(Tables[-1].Query);
end;

procedure TDCLForm.AddEvents(var Events: TEventsArray; EventsSet: String);
var
  v1, v2: Word;
  tmp1: String;
begin
  For v1:=1 To ParamsCount(EventsSet) Do
  Begin
    tmp1:=Trim(SortParams(EventsSet, v1));
    If tmp1<>'' then
    Begin
      v2:=length(Events);
      SetLength(Events, v2+1);
      Events[v2]:=tmp1;
    End;
  End;
end;

function TDCLForm.AddGrid(Parent: TWinControl; SurfType: TDataControlType; Query: TDCLDialogQuery;
  Data: TDataSource): Integer;
var
  v1: Integer;
begin
  v1:=length(FGrids);
  SetLength(FGrids, v1+1);
  FGrids[v1]:=TDCLGrid.Create(Self, Parent, SurfType, Query, Data);
  FGrids[v1].Tag:=v1;
  FGrids[v1].QueryName:='Grid_'+IntToStr(v1);
  Result:=v1;
end;

procedure TDCLGrid.AddNotAllowedOperation(Operation: TNotAllowedOperations);
Var
  i, l: Byte;
Begin
  l:=length(NotAllowedOperations);
  For i:=1 to l do
  Begin
    If NotAllowedOperations[i-1]=Operation then
      Exit;
  End;

  SetLength(NotAllowedOperations, l+1);
  NotAllowedOperations[l]:=Operation;
end;

procedure TDCLForm.AddMainPage(Query: TDCLDialogQuery; Data: TDataSource);
var
  Pc: Integer;
  ButtonParams: RButtonParams;
begin
  FNewPage:=true;

  If Not Assigned(FPages) Then
  Begin
    FPages:=TPageControl.Create(MainPanel);
    FPages.Parent:=MainPanel;
    FPages.Align:=alClient;
    FPages.OnChange:=ChangeTabPage;
    FPages.Tag:=1;
{$IFNDEF FPC}
    FPages.TabHeight:=1;
    FPages.TabWidth:=1;
{$ELSE}
    FPages.ShowTabs:=False;
{$ENDIF}
  End
  Else
  Begin
{$IFNDEF FPC}
    FPages.TabHeight:=0;
    FPages.TabWidth:=0;
{$ELSE}
    FPages.ShowTabs:=True;
{$ENDIF}
  End;

  Pc:=FPages.PageCount;
  FTabs:=TTabSheet.Create(FPages);
  FTabs.Caption:=SourceToInterface(GetDCLMessageString(msPage))+IntToStr(Pc+1);
  FTabs.Name:='Page_'+IntToStr(Pc+1);
  FTabs.PageControl:=FPages;

  // FForm.ClientHeight:=600;
  // Pages.ClientHeight:=400;
  ParentPanel:=FTabs.PageControl.Pages[FPages.PageCount-1];

  FPages.ActivePage:=FPages.Pages[FPages.PageCount-1];
  FPages.ActivePageIndex:=FPages.PageCount-1;

  GridIndex:=AddGrid(ParentPanel, dctMainGrid, Query, Data);
  FTabs.PageControl.Pages[FPages.PageCount-1].Tag:=GridIndex;
  CurrentGridIndex:=GridIndex;
  QueryGlob:=FGrids[GridIndex].Query;
  DataGlob:=FGrids[GridIndex].DataSource;
  FGrids[GridIndex].TabType:=ptMainPage;
  GridPanel:=FGrids[GridIndex].FGridPanel;

  FItnQuery:=FGrids[GridIndex].Query;

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
  If not NoStdKeys then
  Begin
    IncButtonPanelHeight:=ButtonPanelHeight;
    FGrids[GridIndex].ButtonPanel:=TDialogPanel.Create(FGrids[GridIndex].FGridPanel);
    FGrids[GridIndex].ButtonPanel.Parent:=FGrids[GridIndex].FGridPanel;
    FGrids[GridIndex].ButtonPanel.Top:=FForm.ClientHeight-1;
    FGrids[GridIndex].ButtonPanel.Height:=ButtonPanelHeight;
    FGrids[GridIndex].ButtonPanel.Align:=alBottom;

    ResetButtonParams(ButtonParams);
    ButtonParams.Caption:=SourceToInterface(GetDCLMessageString(msClose));
    ButtonParams.Command:='Close';
    ButtonParams.Pict:='esc';
    ButtonParams.Top:=ButtonTop;
    ButtonParams.Left:=ButtonLeft;
    ButtonParams.Width:=ButtonWidth;
    ButtonParams.Height:=ButtonHeight;
    ButtonParams.Cancel:=true;
    ButtonParams.Default:=False;

    Commands.AddCommand(FGrids[GridIndex].ButtonPanel, ButtonParams);
    inc(ButtonLeft, ButtonWidth+ButtonsInterval);

    If FReturningMode<>chmNone then
    Begin
      ResetButtonParams(ButtonParams);
      ButtonParams.Caption:=SourceToInterface(GetDCLMessageString(msChoose));
      Case FReturningMode of
      chmChoose:ButtonParams.Command:='Choose';
      chmChooseAndClose:ButtonParams.Command:='ChooseAndClose';
      End;
      ButtonParams.Pict:='Choose';
      ButtonParams.Top:=ButtonTop;
      ButtonParams.Left:=ButtonLeft;
      ButtonParams.Width:=ButtonWidth;
      ButtonParams.Height:=ButtonHeight;
      ButtonParams.Default:=True;

      Commands.AddCommand(FGrids[GridIndex].ButtonPanel, ButtonParams);
      inc(ButtonLeft, ButtonWidth+ButtonsInterval);
    End;
    // If CachedUpdates Then
    { If Not AutoApply Then
      Begin
      ResetButtonParams(ButtonParams);
      ButtonParams.Caption:=SourceToInterface(GetDCLMessageString());
      ButtonParams.Command:='SaveDB';
      ButtonParams.Pict:='save';
      ButtonParams.Top:=ButtonTop;
      ButtonParams.Left:=ButtonLeft;
      ButtonParams.Width:=ButtonWidth;
      ButtonParams.Height:=ButtonHeight;

      Commands.AddCommand(FGrids[GridIndex].ButtonPanel, ButtonParams);
      Inc(ButtonLeft, ButtonWidth+ButtonsInterval);
      End; }
  End;
end;

procedure TDCLForm.AddStatus(StatusStr: String; Width: Integer);
begin
  DBStatus.Panels.Insert(DBStatus.Panels.Count);
  DBStatus.Panels[DBStatus.Panels.Count-1].Width:=Width;
  DBStatus.Panels[DBStatus.Panels.Count-1].Text:=StatusStr;
end;

procedure TDCLForm.ChangeTabPage(Sender: TObject);
var
  v1: Integer;
begin
  v1:=(Sender as TPageControl).Tag;
  Case v1 of
  Ord(ptMainPage)+1:
  Begin
    CurrentGridIndex:=(Sender as TPageControl).ActivePage.Tag;
    QueryGlob:=FGrids[CurrentGridIndex].FQuery;
    DataGlob:=FGrids[CurrentGridIndex].DataSource;
  End;
  End;
end;

destructor TDCLForm.Destroy;
var
  i, j: Word;
  TB1: TFormPanelButton;
begin
  SaveFormPos; //(FDCLLogOn, FForm, DialogName);
  For i:=1 to Length(FGrids) do
  Begin
    For j:=1 to Length(FGrids[i-1].FTableParts) do
      FreeAndNil(FGrids[i-1].FTableParts[j-1]);

    FreeAndNil(FGrids[i-1]);
  End;

  If ShowFormPanel Then
  Begin
    If Assigned(FDCLLogOn.FDCLMainMenu) then
      If Assigned(FDCLLogOn.FDCLMainMenu.FormBar) Then
      Begin
        TB1:=(FDCLLogOn.FDCLMainMenu.FormBar.FindComponent('TB'+IntToStr(FFormNum))
          As TFormPanelButton);
        FreeAndNil(TB1);
      End;
  End;

  For i:=1 to length(EventsClose) do
    ExecCommand(EventsClose[i-1]);

  For i:=1 to FDCLLogOn.FormsCount do
  Begin
    If Assigned(FDCLLogOn.Forms[i-1]) then
      If FDCLLogOn.ActiveDCLForms[i-1] then
        If Self=FDCLLogOn.Forms[i-1].FParentForm then
          FDCLLogOn.Forms[i-1].Free;
  End;

  FParentForm:=nil;
  SetInactive;
  FForm.Close;
  FForm.Release;
end;

procedure TDCLForm.CloseForm(Sender: TObject; var Action: TCloseAction);
begin
  If GetActive and not NotDestroyedDCLForm then
    FDCLLogOn.CloseForm(Self);
end;

procedure TDCLForm.ExecCommand(CommandName: String);
var
  DCLCommand: TDCLCommand;
begin
  DCLCommand:=TDCLCommand.Create(Self, FDCLLogOn);
  DCLCommand.ExecCommand(CommandName, Self);
  FreeAndNil(DCLCommand);
end;

procedure TDCLForm.LoadFormPos;
begin
  Case GPT.FormPosInDB of
  isDisk:LoadFormPosINI;
  isBase:LoadFormPosBase;
  isDiskAndBase:Begin
    LoadFormPosINI;
    LoadFormPosBase;
  End;
  End;
end;

procedure TDCLForm.LoadFormPosINI;
Var
  FileParams, DialogsParams: TStringList;
  ParamsCounter, FieldsCount, i: Word;
begin
  If DialogName<>'' Then
    If GPT.DialogsSettings Then
    Begin
      If FileExists(IncludeTrailingPathDelimiter(AppConfigDir)+'Dialogs.ini') Then
      Begin
        FileParams:=TStringList.Create;
        FileParams.LoadFromFile(IncludeTrailingPathDelimiter(AppConfigDir)+'Dialogs.ini');
        DialogsParams:=CopyStrings('['+DialogName+']', '[END '+DialogName+']', FileParams);
        LoadFormPosUni(DialogsParams);
      End;
    End;
end;

procedure TDCLForm.LoadFormPosBase;
var
  INIStore:TBinStore;
  DialogsParams, FileParams: TStringList;
  MS:TMemoryStream;
begin
  DialogsParams:=TStringList.Create;
  FileParams:=TStringList.Create;
  INIStore:=TBinStore.Create(FDCLLogOn, ftSQL,
      INITable, IniKeyField, IniDialogNameField, IniParamValField);

  If DialogName<>'' Then
    If GPT.DialogsSettings Then
    Begin
      MS:=INIStore.GetData('select '+IniParamValField+' from '+INITable+' where '+GPT.UpperString+IniDialogNameField+
                                 GPT.UpperStringEnd+'='+GPT.UpperString+GPT.StringTypeChar+DialogName+GPT.StringTypeChar+
                                   GPT.UpperStringEnd+' and '+IniUserFieldName+'='+GPT.UserID);
      If MS.Size>0 Then
      Begin
        MS.Position:=0;
        FileParams.LoadFromStream(MS);

        DialogsParams:=CopyStrings('['+DialogName+']', '[END '+DialogName+']', FileParams);
        LoadFormPosUni(DialogsParams);
      End;
    End;
  FreeAndNil(INIStore);
end;

procedure TDCLForm.LoadFormPosUni(DialogParams:TStringList);
Var
  ParamsCounter, FieldsCount, i, w: Word;
  g:Integer;
  FieldsMode:Boolean;
  Grid:TDCLGrid;
  S:String;
  DCLF:TDCLDataFields;
  F:RField;

function FindDCLField(FieldName:String):TDCLDataFields;
var
  i:Integer;
Begin
  ResetDCLField(Result);
  For i:=1 to Length(Grid.DataFields) do
  Begin
    If CompareString(Grid.DataFields[i-1].Name, FieldName) then
    Begin
      Result:=Grid.DataFields[i-1];
      break;
    End;
  End;
End;

Begin
  If DialogName<>'' Then
    If GPT.DialogsSettings Then
    Begin
      If DialogParams.Count>0 Then
      Begin
        g:=-1;
        FieldsCount:=0;
        FieldsMode:=False;
        ParamsCounter:=0;

        If DialogParams.Count>0 then
          While (ParamsCounter<DialogParams.Count-1) Do
          Begin
            S:=Trim(DialogParams[ParamsCounter]);
            If PosEx('FormTop=', S)=1 then
              Form.Top:=StrToInt(FindParam('FormTop=', S));
            If PosEx('FormLeft=', S)=1 then
              Form.Left:=StrToInt(FindParam('FormLeft=', S));
            If PosEx('FormHeight=', S)=1 then
              Form.Height:=StrToInt(FindParam('FormHeight=', S));
            If PosEx('FormWidth=', S)=1 then
              Form.Width:=StrToInt(FindParam('FormWidth=', S));

            If PosEx('[Page]', S)=1 then
            Begin
              Inc(g);
              FieldsMode:=False;
              FieldsCount:=0;
              If g>-1 then
                Grid:=Tables[g];
            End;

            If PosEx('SplitterPos=', S)=1 then
              If Assigned(Grid) then
                If Assigned(Grid.PartSplitter) then
                  //Grid.GridPanel.Height
                  Grid.FTablePartsPages.Height:=StrToInt(FindParam('SplitterPos=', S));

            If not GPT.DisableFieldsList then
            If PosEx('[Fields]', S)=1 then
              If Assigned(Grid) then
              If Grid.DisplayMode in TDataGrid then
              Begin
                FieldsMode:=True;
                FieldsCount:=StrToIntEx(Trim(DialogParams[ParamsCounter+1]));
                Grid.FGrid.Columns.Clear;

                i:=ParamsCounter+2;
                While (DialogParams.Count-1>i) and (FieldsCount<>0) do
                Begin
                  S:=Trim(DialogParams[i+1]);
                  w:=DefaultColumnSize;
                  If Pos(';', S)<>0 then
                  Begin
                    S:=Copy(S, 1, Pos(';', S)-1);
                    w:=StrToIntEx(FindParam('Width=', DialogParams[i+1]));
                  End;
                  DCLF:=FindDCLField(S);
                  DCLF.Width:=w;
                  DCLF.Name:=S;

                  DCLF.Caption:=Trim(DialogParams[i]);

                  F.Width:=DCLF.Width;
                  F.Caption:=DCLF.Caption;
                  F.FieldName:=DCLF.Name;
                  F.ReadOnly:=DCLF.ReadOnly;

                  Grid.AddColumn(F);
                  Inc(i, 2);
                  Dec(FieldsCount);
                End;
                Inc(ParamsCounter, i);
              End;

            Inc(ParamsCounter);
          End;
      End;
    End;
End;

procedure TDCLForm.SaveFormPos;
begin
  Case GPT.FormPosInDB Of
  isDisk:
  SaveFormPosINI;
  isBase:
  SaveFormPosBase;
  isDiskAndBase:
  Begin
    SaveFormPosINI;
    SaveFormPosBase;
  End;
  End;
end;

procedure TDCLForm.SaveFormPosINI;
Var
  FileParams, DialogsParams: TStringList;
  p1, p2, i, j: Integer;
begin
  p1:=-1;
  p2:=-1;
  FileParams:=TStringList.Create;
  If DialogName<>'' Then
    If FileExists(IncludeTrailingPathDelimiter(AppConfigDir)+'Dialogs.ini') Then
    Begin
      FileParams.LoadFromFile(IncludeTrailingPathDelimiter(AppConfigDir)+'Dialogs.ini');
      For i:=1 to FileParams.Count do
      Begin
        If PosEx('['+DialogName+']', FileParams[i-1])=1 then
        Begin
          p1:=i-1;
          For j:=p1 to FileParams.Count-1 do
          Begin
            If PosEx('[END '+DialogName+']', FileParams[j])=1 then
            Begin
              p2:=j;
              break;
            End;
          End;
        End;
      End;
    End;

  DialogsParams:=SaveFormPosUni;
  If (p1<p2) and (p1>-1) then
  Begin
    For i:=p1 to p2-p1 do
      FileParams.Delete(p1);
  End;
  FileParams.AddStrings(DialogsParams);
  FileParams.SaveToFile(IncludeTrailingPathDelimiter(AppConfigDir)+'Dialogs.ini');
end;

procedure TDCLForm.SaveFormPosBase;
var
  INIStore:TBinStore;
  MS:TMemoryStream;
  DialogSettings:TStringList;
begin
  DialogSettings:=SaveFormPosUni;
  MS:=TMemoryStream.Create;
  DialogSettings.SaveToStream(MS);

  INIStore:=TBinStore.Create(FDCLLogOn, ftSQL,
      INITable, IniKeyField, IniDialogNameField, IniParamValField);
  INIStore.SetData('select * from '+INITable+' where '+GPT.UpperString+IniDialogNameField+
      GPT.UpperStringEnd+'='+GPT.UpperString+GPT.StringTypeChar+DialogName+GPT.StringTypeChar+
      GPT.UpperStringEnd+' and '+IniUserFieldName+'='+GPT.UserID, IniDialogNameField+'='+DialogName+','+
        IniUserFieldName+'='+GPT.UserID, MS, False);

  FreeAndNil(MS);
  FreeAndNil(INIStore);
end;

function TDCLForm.SaveFormPosUni: TStringList;
var
  i, j:Word;
begin
  Result:=TStringList.Create;
  If DialogName<>'' Then
  Begin
    Result.Append('['+DialogName+']');
    Result.Append('FormTop='+IntToStr(Form.Top));
    Result.Append('FormLeft='+IntToStr(Form.Left));
    Result.Append('FormHeight='+IntToStr(Form.Height));
    Result.Append('FormWidth='+IntToStr(Form.Width));

    For i:=1 to Length(FGrids) do
    Begin
      Result.Append('[Page]');
      If Assigned(FGrids[i-1].PartSplitter) then
        Result.Append('SplitterPos='+IntToStr(FGrids[i-1].FTablePartsPages.Height));
      If FGrids[i-1].DisplayMode in TDataGrid then
      Begin
        Result.Append('[Fields]');
        Result.Append(IntToStr(FGrids[i-1].FGrid.Columns.Count));
        For j:=1 to FGrids[i-1].FGrid.Columns.Count do
        Begin
          Result.Append(FGrids[i-1].FGrid.Columns[j-1].Title.Caption);
          Result.Append(FGrids[i-1].FGrid.Columns[j-1].FieldName+';Width='+IntToStr(FGrids[i-1].FGrid.Columns[j-1].Width));
        End;
      End;
    End;

    Result.Append('[END '+DialogName+']');
    Result.Append('');
  End;
end;

constructor TDCLForm.Create(DialogName: String; var DCLLogOn: TDCLLogOn; ParentForm: TDCLForm;
  aFormNum: Integer; OPL: TStringList; Query: TDCLDialogQuery; Data: TDataSource;
  Modal: Boolean=False; ReturnValueMode: TChooseMode=chmNone; ReturnValueParams:TReturnValueParams=nil);
var
  ScrStr, TmpStr, tmpStr2, tmpSQL, FieldCaptScrStr, FieldNameStr, tmpSQL1: string;
  DisplayMode: TDataControlType;
  QCreated, ModalOpen: Boolean;
  OPLLinesCount, ScrStrNum, OPLStrNo, FieldNo, CountFields, v1, v2, v3, v5, i1, TabIndex: Integer;
  IsDigitType: TIsDigitType;
  FFactor: Word;
  ShadowQuery: TDCLDialogQuery;
  FField: RField;
  FFilter: TDBFilter;
  Calendar: RCalendar;
  UserLevel: TUserLevelsType;
  ButtonParams: RButtonParams;

  procedure SetNewQuery;
  Begin
    If not QCreated then
    Begin
      QCreated:=true;
      GridIndex:=AddGrid(ParentPanel, dctMainGrid, Query, nil);
    End
    Else
    Begin
      If not Assigned(FGrids[GridIndex].FQueryGlob) then
        FGrids[GridIndex].SetNewQuery(nil);
    End;
    FGrids[GridIndex].SetSQLToStore(tmpSQL, qtMain, ulUndefined);

    QueryGlob:=FGrids[GridIndex].Query;
    TranslateVal(tmpSQL);
    FGrids[GridIndex].SQL:=tmpSQL;
    FGrids[GridIndex].Open;
  End;

begin
  NotDestroyedDCLForm:=False;
  FParentForm:=ParentForm;
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
  GridIndex:=-1;
  //DCLCommand:=TDCLCommand.Create(Self, FDCLLogOn);
  Commands:=TDCLCommandButton.Create(DCLLogOn, Self);
  UserLevelLocal:=FDCLLogOn.AccessLevel;
  FormHeight:=0;
  FormWidth:=0;
  ExitNoSave:=False;
  SetLength(FGrids, 0);
  // CachedUpdates:=False;

  FForm:=TDBForm.Create(Application);
  FForm.Name:=Trim(DialogName)+IntToStr(FFormNum);
  FForm.Width:=650;
  FForm.ClientHeight:=400;
  FForm.OnClose:=CloseForm;
  FForm.KeyPreview:=true;
  FForm.Position:=poScreenCenter;
  FForm.OnResize:=ResizeDBForm;
  FForm.OnActivate:=ActivateForm;
  FForm.Tag:=aFormNum;
  FForm.Icon:=GetIcon;
{$IFNDEF EMBEDDED}
  If Application.MainForm.FormStyle=fsMDIForm Then
    FForm.FormStyle:=fsMDIChild;
{$ENDIF}
{$IFDEF MSWINDOWS}
  SetWindowLong(FForm.Handle, GWL_EXSTYLE, GetWindowLong(FForm.Handle, GWL_EXSTYLE)or
    WS_EX_APPWINDOW);
{$ENDIF}
  // SetActive;
{$IFDEF DCLDEBUG}
  FForm.Show;
{$ENDIF}
  If Assigned(FDCLLogOn.FDCLMainMenu) then
    If ShowFormPanel And Assigned(FDCLLogOn.FDCLMainMenu.FormBar) Then
      If FDCLLogOn.FDCLMainMenu.FormBar.Parent<>FForm Then
      Begin
        TB:=TFormPanelButton.Create(FDCLLogOn.FDCLMainMenu.FormBar);
        TB.Name:='TB'+IntToStr(FForm.Tag);
        TB.Parent:=FDCLLogOn.FDCLMainMenu.FormBar;
        TB.Width:=FormPanelButtonWidth;
        TB.Height:=FormPanelButtonHeight;
        TB.OnClick:=ToolButtonClick;
        TB.Tag:=FForm.Tag;
        TB.Margin:=PanelButtonTextRight;
        TB.Glyph:=DrawBMPButton('FormDotActive');
        TB.Font.Style:=[fsBold];
      End;

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
  MainPanel.Height:=70;
  MainPanel.Top:=50;

  QCreated:=true;
  AddMainPage(Query, Data);

  If length(FOPL.Text)>3 then
  begin
    QCreated:=true;
    ScrStrNum:=0;
    OPLLinesCount:=FOPL.Count;
    GPT.CurrentRunningScrString:=0;

    While ScrStrNum<OPLLinesCount Do
    Begin
      ScrStr:=Trim(FOPL[ScrStrNum]);
      { RePlaseVariables(ScrStr);
        FFactor:=0;
        TranslateProc(ScrStr, FFactor); }
      inc(GPT.CurrentRunningScrString);

      If Pos('//', ScrStr)=1 Then
      Begin
        inc(ScrStrNum);
        Continue;
      End;

      If PosEx('Orientation=', ScrStr)=1 Then
      Begin
        tmpSQL:=LowerCase(FindParam('Orientation=', ScrStr));
        If tmpSQL='horizontal' then
          FGrids[GridIndex].FOrientation:=oHorizontal;
        If tmpSQL='vertical' then
          FGrids[GridIndex].FOrientation:=oVertical;
      End;

      If PosEx('AutoRefresh;', ScrStr)=1 Then
      Begin
        FGrids[GridIndex].RefreshTimer:=TTimer.Create(Nil);
        FGrids[GridIndex].RefreshTimer.Tag:=GridIndex;
        FGrids[GridIndex].RefreshTimer.Interval:=AutoResfreshInterval;
        FGrids[GridIndex].RefreshTimer.OnTimer:=FGrids[GridIndex].AutorefreshTimer;
        FGrids[GridIndex].RefreshTimer.Enabled:=true;
        FGrids[GridIndex].LastStateTimer:=False;
      End;

      If PosEx('AutoRefresh=', ScrStr)=1 Then
      Begin
        tmpSQL:=ScrStr;
        RePlaseVariables(tmpSQL);
        v1:=StrToIntEx(FindParam('AutoRefresh=', tmpSQL))*1000;
        If v1>0 Then
        Begin
          FGrids[GridIndex].RefreshTimer:=TTimer.Create(Nil);
          FGrids[GridIndex].RefreshTimer.Tag:=GridIndex;
          FGrids[GridIndex].RefreshTimer.Interval:=v1;
          FGrids[GridIndex].RefreshTimer.OnTimer:=FGrids[GridIndex].AutorefreshTimer;
          FGrids[GridIndex].RefreshTimer.Enabled:=true;
          FGrids[GridIndex].LastStateTimer:=False;
        End;
      End;

      If PosEx('SetUserAccessRaight=', ScrStr)=1 Then
      Begin
        If FDCLLogOn.AccessLevel>=ulLevel3 Then
        Begin
          tmpSQL:=FindParam('SetUserAccessRaight=', ScrStr);

          Case IsDigit(tmpSQL) Of
          idDigit:
          UserLevelLocal:=TranslateDigitToUserLevel
            (StrToIntEx(FindParam('SetUserAccessRaight=', ScrStr)));
          idUserLevel:
          UserLevelLocal:=TranslateDigitToUserLevel(FindParam('SetUserAccessRaight=', ScrStr));
          End;
        End;
      End;

      If PosEx('UserAccessRaight=', ScrStr)=1 Then
      Begin
        tmpSQL:=FindParam('UserAccessRaight=', ScrStr);
        Case IsDigit(tmpSQL) Of
        idDigit:
        UserLevel:=TranslateDigitToUserLevel(StrToIntEx(FindParam('UserAccessRaight=', ScrStr)));
        idUserLevel:
        UserLevel:=TranslateDigitToUserLevel(FindParam('UserAccessRaight=', ScrStr));
        End;
        If UserLevel>=UserLevelLocal Then
        Begin
          ShowErrorMessage(0, SourceToInterface(GetDCLMessageString(msNotAllow)+' '+
            GetDCLMessageString(msOpenForm)));
          FreeAndNil(Self);
          Exit;
        End;
      End;

      If PosEx('AddNotAllowOperation=', ScrStr)=1 Then
      Begin
        TmpStr:=FindParam('AddNotAllowOperation=', ScrStr);
        If PosEx('Insert', TmpStr)<>0 then
          FGrids[GridIndex].AddNotAllowedOperation(dsoInsert);
        If PosEx('Delete', TmpStr)<>0 then
          FGrids[GridIndex].AddNotAllowedOperation(dsoDelete);
        If PosEx('Edit', TmpStr)<>0 then
          FGrids[GridIndex].AddNotAllowedOperation(dsoEdit);
      End;

      If PosEx('QueryKeyField=', ScrStr)=1 Then
      Begin
        FGrids[GridIndex].KeyMarks.KeyField:=FindParam('QueryKeyField=', ScrStr);
        FGrids[GridIndex].KeyMarks.TitleField:=FindParam('TitleField=', ScrStr);
        If FGrids[GridIndex].KeyMarks.TitleField='' Then
          FGrids[GridIndex].KeyMarks.TitleField:=FGrids[GridIndex].KeyMarks.KeyField;
      End;

      If PosEx('ReOpen;', ScrStr)=1 Then
      Begin
        FGrids[GridIndex].ReFreshQuery;
      End;

      If PosEx('ExitNoSave=', ScrStr)=1 Then
      Begin
        tmpSQL:=FindParam('exitnosave=', ScrStr);
        If tmpSQL='1' Then
          ExitNoSave:=true;
      End;

      If PosEx('SetFieldValue=', ScrStr)=1 Then
      Begin
        ExecCommand(ScrStr);
      End;

      If PosEx('SetMainFormCaption=', ScrStr)=1 Then
      Begin
        ExecCommand(ScrStr);
      End;

      If PosEx('Status=', ScrStr)=1 Then
      Begin
        ExecCommand(ScrStr);
      End;

      If PosEx('AddStatus=', ScrStr)=1 Then
      Begin
        ExecCommand(ScrStr);
      End;

      If PosEx('SetStatusText=', ScrStr)=1 Then
      Begin
        ExecCommand(ScrStr);
      End;

      If PosEx('DeleteAllStatus;', ScrStr)=1 Then
      Begin
        ExecCommand(ScrStr);
      End;

      If PosEx('DeleteStatus=', ScrStr)=1 Then
      Begin
        ExecCommand(ScrStr);
      End;

      If PosEx('FormHeight=', ScrStr)=1 Then
      Begin
        FormHeight:=StrToIntEx(FindParam('FormHeight=', ScrStr));
        FForm.ClientHeight:=FormHeight;
      End;

      If PosEx('FormWidth=', ScrStr)=1 Then
      Begin
        FormWidth:=StrToIntEx(FindParam('FormWidth=', ScrStr));
        FForm.ClientWidth:=FormWidth;
      End;

      If PosEx('Execute=', ScrStr)=1 Then
      Begin
        ExecCommand(ScrStr);
      End;

      If PosEx('SeparateChar=', ScrStr)=1 Then
      Begin
        GPT.StringTypeChar:=FindParam('SeparateChar=', ScrStr);
      End;

      If PosEx('SetValueSeparator=', ScrStr)=1 Then
      Begin
        GPT.GetValueSeparator:=FindParam('SetValueSeparator=', ScrStr);
      End;

      If PosEx('ReadOnly=', ScrStr)=1 Then
      Begin
        TmpStr:=Trim(FindParam('ReadOnly=', ScrStr));
        FGrids[GridIndex].TranslateVal(TmpStr);

        If StrToIntEx(TmpStr)=1 Then
        Begin
          FGrids[GridIndex].ReadOnly:=true;
        End
        Else
          FGrids[GridIndex].ReadOnly:=False;
      End;

      If PosEx('Navigator=', ScrStr)=1 then
      Begin
        tmpSQL:=FindParam('Navigator=', ScrStr);
        If tmpSQL='0' then
        Begin
          If Assigned(FGrids[GridIndex].Navig) then
            FGrids[GridIndex].Navig.Hide;
        End
        Else
        Begin
          If FindParam('buttons=', ScrStr)='' Then
            ScrStr:=ScrStr+';buttons='+DefaultNavigButtonsSet+';';
          If FindParam('buttons=', ScrStr)<>'' Then
          Begin
            tmpSQL:=FindParam('buttons=', ScrStr);
            For v1:=1 To 10 Do
              NavigVisiButtonsVar[v1]:=[];
            If PosEx('first', tmpSQL)<>0 Then
              NavigVisiButtonsVar[1]:=[nbFirst];
            If PosEx('last', tmpSQL)<>0 Then
              NavigVisiButtonsVar[4]:=[nbLast];
            If PosEx('insert', tmpSQL)<>0 Then
            Begin
              If UserLevelLocal<>ulReadOnly then
                NavigVisiButtonsVar[5]:=[nbInsert];
            End;
            If PosEx('delete', tmpSQL)<>0 Then
            Begin
              If UserLevelLocal<>ulReadOnly then
                NavigVisiButtonsVar[6]:=[nbDelete];
            End;
            If PosEx('edit', tmpSQL)<>0 Then
            Begin
              If UserLevelLocal<>ulReadOnly then
                NavigVisiButtonsVar[7]:=[nbEdit];
            End;
            If PosEx('post', tmpSQL)<>0 Then
              If UserLevelLocal<>ulReadOnly then
                NavigVisiButtonsVar[8]:=[nbPost];
            If PosEx('cancel', tmpSQL)<>0 Then
              NavigVisiButtonsVar[9]:=[nbCancel];
            If PosEx('refresh', tmpSQL)<>0 Then
              NavigVisiButtonsVar[10]:=[nbRefresh];
            FGrids[GridIndex].Navig.VisibleButtons:=NavigVisiButtonsVar[1]+NavigVisiButtonsVar[2]+
              NavigVisiButtonsVar[3]+NavigVisiButtonsVar[4]+NavigVisiButtonsVar[5]+
              NavigVisiButtonsVar[6]+NavigVisiButtonsVar[7]+NavigVisiButtonsVar[8]+
              NavigVisiButtonsVar[9]+NavigVisiButtonsVar[10];
          End;

          If FindParam('Flat=', ScrStr)<>'' Then
          Begin
            tmpSQL:=FindParam('Flat=', ScrStr);
            If tmpSQL='1' Then
              FGrids[GridIndex].Navig.Flat:=true;
          End;
        End;
      End;

      If PosEx('[QUERY]', ScrStr)=1 then
      Begin
        v1:=ScrStrNum;
        tmpSQL:='';
        For v2:=v1 to OPLLinesCount do
          If CompareString(Trim(FOPL[v2]), '[END QUERY]') then
          Begin
            ScrStrNum:=v2;
            For v3:=v1+1 to v2-1 do
              tmpSQL:=tmpSQL+FOPL[v3]+' ';
            SetNewQuery;
            break;
          End;
      End;

      If PosEx('Query=', ScrStr)=1 then
      Begin
        FNewPage:=False;
        tmpSQL:=FindParam('query=', ScrStr);
        SetNewQuery;
      End;

      If PosEx('QueryName=', ScrStr)=1 then
      Begin
        tmpSQL:=FindParam('QueryName=', ScrStr);
        FGrids[GridIndex].QueryName:=tmpSQL;
      End;

      If PosEx('OrderByFields=', ScrStr)=1 Then
      Begin
        tmpSQL:=FindParam('OrderByFields=', ScrStr);
        v2:=ParamsCount(tmpSQL);
        For v1:=1 To v2 Do
        Begin
          v2:=length(FGrids[GridIndex].OrderByFields);
          SetLength(FGrids[GridIndex].OrderByFields, v2+1);
          FGrids[GridIndex].OrderByFields[v2]:=SortParams(tmpSQL, v1);
        End;
      End;

      If PosEx('Message=', ScrStr)=1 Then
      Begin
        ExecCommand(ScrStr);
      End;

      If (PosEx('UniqueTable=', ScrStr)=1)or
        (PosSet('UpdateResync=,LockType=,CursorType=', ScrStr)=1)or(PosEx('UniqueTable=', ScrStr)=1)
        or(PosEx('UpdateQuery=', ScrStr)=1)or
        (PosSet('AutoApply=,CashBase=,Live=,ParamCheck=', ScrStr)<>0)or
        (PosEx('UpdateTable=', ScrStr)=1) then
      Begin
{$IFDEF CACHEON}
        { CachedUpdates:=True;
          FGrids[GridIndex].CachedUpdates:=True; }
{$ENDIF}
        If Assigned(FGrids[GridIndex].FQuery) then
          FGrids[GridIndex].FQuery.SetUpdateSQL(FindParam('UpdateTable=', ScrStr),
            FindParam('KeyFields=', ScrStr));
        // FillDatasetUpdateSQL(FGrids[GridIndex].FQuery, {$IFDEF BDE_or_IB}FGrids[GridIndex].UpdateSQL,{$ENDIF} ScrStr, FGrids[GridIndex].FUserLevelLocal, FGrids[GridIndex]);
      End;

      If PosEx('FindQuery=', ScrStr)=1 then
      Begin
        tmpSQL:=FindParam('FindQuery=', ScrStr);
        FGrids[GridIndex].SetSQLToStore(tmpSQL, qtFind, ulUndefined);
      End;

      If PosEx('ExecCommand=', ScrStr)=1 Then
      Begin
        TmpStr:=FindParam('ExecCommand=', ScrStr);
        RePlaseParams(TmpStr);
        RePlaseVariables(TmpStr);
        ExecCommand(TmpStr);
      End;

      If PosEx('SetValue=', ScrStr)=1 Then
      Begin
        ExecCommand(ScrStr)
      End;

      If PosEx('Calendar=', ScrStr)=1 Then
      Begin
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
          Calendar.ReOpen:=true
        Else
          Calendar.ReOpen:=False;

        FGrids[GridIndex].AddCalendar(Calendar);
      End;

      If PosEx('DBFilter=', ScrStr)=1 Then
      Begin
        FFilter.SQL:=FindParam('SQL=', ScrStr);
        If FFilter.SQL='' then
          FFilter.SQL:=FindParam('DBFilterQuery=', ScrStr);
        RePlaseVariables(FFilter.SQL);
        FFactor:=0;
        TranslateProc(FFilter.SQL, FFactor);
        If FFilter.SQL<>'' Then
        Begin
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
          Begin
            FFilter.VarName:=FindParam('VariableName=', ScrStr);
            FDCLLogOn.Variables.NewVariable(FFilter.VarName);
          End;

          tmpSQL:=FindParam('KeyValue=', ScrStr);
          If tmpSQL<>'' Then
          Begin
            RePlaseVariables(tmpSQL);
            If PosEx('select ', tmpSQL)<>0 Then
              If PosEx(' from ', tmpSQL)<>0 Then
              Begin
                ShadowQuery:=TDCLDialogQuery.Create(Nil);
                ShadowQuery.Name:='FormShadowK_'+IntToStr(UpTime);
                FDCLLogOn.SetDBName(ShadowQuery);
                ShadowQuery.SQL.Text:=tmpSQL;
                Try
                  ShadowQuery.Open;
                  tmpSQL:=ShadowQuery.Fields[0].AsString;
                  If tmpSQL='' then
                    tmpSQL:='-1';
                Except
                  ShowErrorMessage(-1117, 'SQL='+tmpSQL);
                End;
              End;
            FFilter.KeyValue:=tmpSQL;
          End;

          FGrids[GridIndex].AddDBFilter(FFilter);
        End;
      End;

      If PosEx('ContextFilter=', ScrStr)=1 Then
      Begin
        ResetFilterParams(FFilter);
        FFilter.FilterType:=ftContextFilter;
        FFilter.Caption:=FindParam('Label=', ScrStr);
        FFilter.Field:=FindParam('FilterField=', ScrStr);

        v3:=FilterWidth;
        If FindParam('Width=', ScrStr)<>'' Then
          v3:=StrToIntEx(Trim(FindParam('Width=', ScrStr)));
        FFilter.Width:=v3;

        If FindParam('VariableName=', ScrStr)<>'' Then
        Begin
          FFilter.VarName:=FindParam('VariableName=', ScrStr);
          FDCLLogOn.Variables.NewVariable(FFilter.VarName);
        End;

        If FindParam('MaxLength=', ScrStr)<>'' Then
        Begin
          FFilter.MaxLength:=StrToIntEx(Trim(FindParam('MaxLength=', ScrStr)));
        End;

        TmpStr:=FindParam('WaitForEnter=', ScrStr);
        If TmpStr='1' Then
        Begin
          FFilter.WaitForKey:=13;
        End;

        TmpStr:=FindParam('FilterMode=', ScrStr);
        If TmpStr<>'' Then
        Begin
          If PosEx('Case', TmpStr)<>0 Then
            FFilter.CaseC:=true;

          If PosEx('NotLike', TmpStr)<>0 Then
            FFilter.NotLike:=true;
        End;

        If PosEx('ComponentName=', ScrStr)<>0 Then
          FFilter.FilterName:=FindParam('ComponentName=', ScrStr);

        FFilter.KeyValue:=FindParam('_Value=', ScrStr);

        FGrids[GridIndex].AddDBFilter(FFilter);
      End;

      If (PosEx('Between=', ScrStr)=1)or(PosEx('ContextBetween=', ScrStr)=1) Then
      Begin
        tmpSQL:=FindParam('between=', ScrStr);
        v3:=ParamsCount(tmpSQL);
        If v3 Mod 2=0 Then
        Begin
          v2:=1;
          For v1:=1 To v3 Div 2 Do
          Begin
            v5:=StrToIntEx(SortParams(tmpSQL, v2));
            v3:=StrToIntEx(SortParams(tmpSQL, v2+1));
            FGrids[GridIndex].DBFilters[v5].Between:=StopFilterFlg;
            FGrids[GridIndex].DBFilters[v5].Between:=v3;
            inc(v2, 1);
          End;
        End
        Else
          ShowErrorMessage(-4000, LineEnding+ScrStr);
      End;

      If PosEx('TablePartToolButton=', ScrStr)=1 Then
      Begin
        If Not FindDisableAction(LowerCase(FindParam('action=', ScrStr))) Then
        Begin
          tmpSQL1:=FindParam('AccessLevel=', ScrStr);
          RePlaseVariables(tmpSQL1);
          FFactor:=0;
          TranslateProc(tmpSQL1, FFactor);
          v2:=0;
          If tmpSQL1<>'' then
          Begin
            IsDigitType:=IsDigit(tmpSQL1);
            Case IsDigitType Of
            idDigit:
            If TranslateDigitToUserLevel(StrToIntEx(FindParam('AccessLevel=', ScrStr)))<=UserLevelLocal
            then
              v2:=1
            Else
              v2:=0;
            idString:
            If TranslateDigitToUserLevel(FindParam('AccessLevel=', ScrStr))<=UserLevelLocal then
              v2:=1
            Else
              v2:=0;
            End;
          End
          Else
            v2:=1;

          If v2=1 then
          Begin
            ResetButtonParams(ButtonParams);

            ButtonParams.Caption:=InitCap(FindParam('label=', ScrStr));
            If FindParam('_Default=', ScrStr)='1' Then
              ButtonParams.Default:=true;

            If FindParam('_Cancel=', ScrStr)='1' Then
              ButtonParams.Cancel:=true;

            ButtonParams.Hint:=InitCap(FindParam('hint=', ScrStr));

            ButtonParams.Action:=FindParam('action=', ScrStr);

            If FindParam('action=', ScrStr)<>'' then
              ButtonParams.Pict:=FindParam('action=', ScrStr)
            Else
              ButtonParams.Pict:=FindParam('Pict=', ScrStr);

            If PosEx('commandname=', ScrStr)<>0 Then
              ButtonParams.Command:=FindParam('commandname=', ScrStr);

            If PosEx('bold', FindParam('FontStyle=', ScrStr))<>0 Then
              ButtonParams.FontStyle:=ButtonParams.FontStyle+[fsBold];
            If PosEx('italic', FindParam('FontStyle=', ScrStr))<>0 Then
              ButtonParams.FontStyle:=ButtonParams.FontStyle+[fsItalic];
            If PosEx('underline', FindParam('FontStyle=', ScrStr))<>0 Then
              ButtonParams.FontStyle:=ButtonParams.FontStyle+[fsUnderLine];

            TmpStr:=FindParam('Width=', ScrStr);
            If TmpStr<>'' Then
            Begin
              v5:=StrToIntEx(TmpStr);
              If v5>4 Then
                ButtonParams.Width:=v5;
            End
            Else
              ButtonParams.Width:=TablePartButtonWidth;

            ButtonParams.Height:=TablePartButtonHeight;

            FGrids[GridIndex].AddToolPartButton(ButtonParams);
          End;
        End;
      End;

      If PosEx('CommandButton=', ScrStr)=1 Then
      Begin
        If Not FindDisableAction(LowerCase(FindParam('action=', ScrStr))) Then
        Begin
          tmpSQL1:=FindParam('AccessLevel=', ScrStr);
          RePlaseVariables(tmpSQL1);
          FFactor:=0;
          TranslateProc(tmpSQL1, FFactor);
          If tmpSQL1<>'' then
          Begin
            IsDigitType:=IsDigit(tmpSQL1);
            Case IsDigitType Of
            idDigit:
            If TranslateDigitToUserLevel(StrToIntEx(FindParam('AccessLevel=', ScrStr)))<=UserLevelLocal
            then
              v2:=1
            Else
              v2:=0;
            idString:
            If TranslateDigitToUserLevel(FindParam('AccessLevel=', ScrStr))<=UserLevelLocal then
              v2:=1
            Else
              v2:=0;
            End;
          End
          Else
            v2:=1;

          If v2=1 then
          Begin
            ResetButtonParams(ButtonParams);

            ButtonParams.Caption:=InitCap(FindParam('label=', ScrStr));
            If FindParam('_Default=', ScrStr)='1' Then
              ButtonParams.Default:=true;

            If FindParam('_Cancel=', ScrStr)='1' Then
              ButtonParams.Cancel:=true;

            ButtonParams.Hint:=InitCap(FindParam('hint=', ScrStr));

            ButtonParams.Action:=FindParam('action=', ScrStr);

            If FindParam('action=', ScrStr)<>'' then
              ButtonParams.Pict:=FindParam('action=', ScrStr)
            Else
              ButtonParams.Pict:=FindParam('Pict=', ScrStr);

            If PosEx('commandname=', ScrStr)<>0 Then
              ButtonParams.Command:=FindParam('commandname=', ScrStr);

            If PosEx('bold', FindParam('FontStyle=', ScrStr))<>0 Then
              ButtonParams.FontStyle:=ButtonParams.FontStyle+[fsBold];
            If PosEx('italic', FindParam('FontStyle=', ScrStr))<>0 Then
              ButtonParams.FontStyle:=ButtonParams.FontStyle+[fsItalic];
            If PosEx('underline', FindParam('FontStyle=', ScrStr))<>0 Then
              ButtonParams.FontStyle:=ButtonParams.FontStyle+[fsUnderLine];

            TmpStr:=FindParam('Width=', ScrStr);
            If TmpStr<>'' Then
            Begin
              v5:=StrToIntEx(TmpStr);
              If v5>4 Then
                ButtonParams.Width:=v5;
            End
            Else
              ButtonParams.Width:=ButtonWidth;

            ButtonParams.Height:=ButtonHeight;

            If ButtonLeft>ButtonLeftLimit Then
            Begin
              ButtonLeft:=BeginStepLeft;
              inc(IncButtonPanelHeight, IncPanelHeight);
              FGrids[GridIndex].ButtonPanel.Height:=IncButtonPanelHeight;
              inc(ButtonTop, IncPanelHeight);
            End;

            ButtonParams.Top:=ButtonTop;
            ButtonParams.Left:=ButtonLeft;

            Commands.AddCommand(FGrids[GridIndex].ButtonPanel, ButtonParams);

            inc(ButtonLeft, ButtonParams.Width+ButtonsInterval);
          End;
        End;
      End;

      If PosEx('modal=', ScrStr)=1 Then
      Begin
        tmpSQL:=FindParam('Modal=', ScrStr);
        If tmpSQL='0' Then
          Modal:=False;
        If tmpSQL='1' Then
          Modal:=true;
      End;

      If PosEx('GetFieldValue=', ScrStr)=1 Then
      Begin
        ExecCommand(ScrStr);
      End;

      If PosEx('GetValue=', ScrStr)=1 Then
      Begin
        ExecCommand(ScrStr);
      End;

      If PosEx('Orientation=', ScrStr)=1 Then
      Begin
        If Assigned(FPages) Then
        Begin
          If LowerCase(FindParam('Orientation=', ScrStr))=LowerCase('top') Then
            FPages.TabPosition:=tpTop;
          If LowerCase(FindParam('Orientation=', ScrStr))=LowerCase('left') Then
            FPages.TabPosition:=tpLeft;
          If LowerCase(FindParam('Orientation=', ScrStr))=LowerCase('bottom') Then
            FPages.TabPosition:=tpBottom;
          If LowerCase(FindParam('Orientation=', ScrStr))=LowerCase('right') Then
            FPages.TabPosition:=tpRight;
        End;
      End;

      If PosEx('[Page]', ScrStr)=1 Then
      Begin
        if not FNewPage then
        Begin
          QCreated:=true;
          ButtonLeft:=BeginStepLeft;
          ButtonTop:=ButtonsTop;

          AddMainPage(FItnQuery, nil);
        End;

        If Assigned(FPages) then
        Begin
{$IFNDEF FPC}
          FPages.TabHeight:=0;
          FPages.TabWidth:=0;
{$ELSE}
          FPages.ShowTabs:=True;
{$ENDIF}
          // FPages.ActivePage:=FPages.Pages[0];  //dep
          // FPages.ActivePageIndex:=0;           //dep
        End;
        FNewPage:=False;
      End;

      If PosEx('Caption=', ScrStr)=1 Then
      Begin
        tmpSQL:=InitCap(FindParam('caption=', ScrStr));
        RePlaseVariables(tmpSQL);
        RePlaseParams(tmpSQL);
        FForm.Caption:=tmpSQL;
      End;

      If PosEx('Style=', ScrStr)=1 Then
      Begin
        tmpSQL:=FindParam('Style=', ScrStr);
        If tmpSQL='0' Then
          DisplayMode:=dctFields;
        If tmpSQL='1' Then
          DisplayMode:=dctFieldsStep;
        If tmpSQL='2' Then
          DisplayMode:=dctMainGrid;

        FGrids[GridIndex].DisplayMode:=DisplayMode;
      End;

      If PosEx('Title=', ScrStr)=1 Then
      Begin
        If Assigned(FPages) Then
          FTabs.Caption:=FindParam('Title=', ScrStr);
      End;

      If PosEx('TablePart=', ScrStr)=1 Then
      begin
        tmpSQL:=FindParam('Title=', ScrStr);

        ParentPanel.Align:=alClient;
        TabIndex:=FGrids[GridIndex].AddPartPage(tmpSQL, DataGlob);
        If not Assigned(FGrids[GridIndex].PartSplitter) then
        Begin
          FGrids[GridIndex].PartSplitter:=TSplitter.Create(FGrids[GridIndex].GridPanel);
          FGrids[GridIndex].PartSplitter.Parent:=FGrids[GridIndex].GridPanel;
          FGrids[GridIndex].PartSplitter.Align:=alBottom;

          FGrids[GridIndex].GridPanel.Align:=alClient;
        End;
        If TabIndex<>-1 then
        Begin
          tmpSQL:=FindParam('SQL=', ScrStr);
          If tmpSQL<>'' Then
          Begin
            // FillDatasetUpdateSQL(FGrids[GridIndex].TableParts[TabIndex].FQuery, {$IFDEF BDE_or_IB}FGrids[GridIndex].TableParts[TabIndex].UpdateSQL,{$ENDIF} ScrStr, FGrids[GridIndex].TableParts[TabIndex].FUserLevelLocal, FGrids[GridIndex].TableParts[TabIndex]);
            FGrids[GridIndex].TableParts[TabIndex].FQuery.SetUpdateSQL
              (FindParam('UpdateTable=', ScrStr), FindParam('KeyFields=', ScrStr));

            FGrids[GridIndex].TableParts[TabIndex].DisplayMode:=dctTablePart;
            FGrids[GridIndex].TableParts[TabIndex].SQL:=tmpSQL;
            If FGrids[GridIndex].FQuery.Active then
              Try
                FGrids[GridIndex].TableParts[TabIndex].Open;
              Except
                ShowErrorMessage(-1200, 'SQL='+tmpSQL);
              End;
            FGrids[GridIndex].TableParts[TabIndex].Show;
            FGrids[GridIndex].TableParts[TabIndex].SetSQLToStore(tmpSQL, qtMain, ulUndefined);

            If FindParam('DependField=', ScrStr)<>'' Then
            Begin
              FGrids[GridIndex].TableParts[TabIndex].DependField:=FindParam('DependField=', ScrStr);
            End;

            If FindParam('MasterDataField=', ScrStr)<>'' Then
            Begin
              FGrids[GridIndex].TableParts[TabIndex].MasterDataField:=
                FindParam('MasterDataField=', ScrStr);
            End;

            If FindParam('Navigator=', ScrStr)='0' Then
            Begin
              FGrids[GridIndex].TableParts[TabIndex].Navig.Hide;
            End;

            If FindParam('NavigatorButtons=', ScrStr)='' Then
              ScrStr:=ScrStr+';NavigatorButtons='+DefaultNavigButtonsSet+';';

            If PosEx('NavigatorButtons=', ScrStr)<>0 Then
            Begin
              If Assigned(FGrids[GridIndex].TableParts[TabIndex].Navig) Then
              Begin
                tmpSQL:=FindParam('NavigatorButtons=', ScrStr);
                For v1:=1 To 10 Do
                  NavigVisiButtonsVar[v1]:=[];
                If PosEx('first', tmpSQL)<>0 Then
                  NavigVisiButtonsVar[1]:=[nbFirst];
                If PosEx('last', tmpSQL)<>0 Then
                  NavigVisiButtonsVar[4]:=[nbLast];
                If PosEx('insert', tmpSQL)<>0 Then
                Begin
                  If UserLevelLocal<>ulReadOnly then
                    NavigVisiButtonsVar[5]:=[nbInsert];
                End;
                If PosEx('delete', tmpSQL)<>0 Then
                Begin
                  If UserLevelLocal<>ulReadOnly then
                    NavigVisiButtonsVar[6]:=[nbDelete];
                End;
                If PosEx('edit', tmpSQL)<>0 Then
                Begin
                  If UserLevelLocal<>ulReadOnly then
                    NavigVisiButtonsVar[7]:=[nbEdit];
                End;
                If PosEx('post', tmpSQL)<>0 Then
                  If UserLevelLocal<>ulReadOnly then
                    NavigVisiButtonsVar[8]:=[nbPost];
                If PosEx('cancel', tmpSQL)<>0 Then
                  NavigVisiButtonsVar[9]:=[nbCancel];
                If PosEx('refresh', tmpSQL)<>0 Then
                  NavigVisiButtonsVar[10]:=[nbRefresh];
                FGrids[GridIndex].TableParts[TabIndex].Navig.VisibleButtons:=NavigVisiButtonsVar[1]+
                  NavigVisiButtonsVar[2]+NavigVisiButtonsVar[3]+NavigVisiButtonsVar[4]+
                  NavigVisiButtonsVar[5]+NavigVisiButtonsVar[6]+NavigVisiButtonsVar[7]+
                  NavigVisiButtonsVar[8]+NavigVisiButtonsVar[9]+NavigVisiButtonsVar[10];
              End;
            End;

            TmpStr:=Trim(FindParam('ReadOnly=', ScrStr));
            TranslateVal(TmpStr);
            If StrToIntEx(TmpStr)=1 Then
            Begin
              FGrids[GridIndex].TableParts[TabIndex].ReadOnly:=true;
              FGrids[GridIndex].TableParts[TabIndex].Navig.VisibleButtons:=
                FGrids[GridIndex].TableParts[TabIndex].Navig.VisibleButtons-NavigatorEditButtons;
            End;

            If FindParam('Flat=', ScrStr)<>'' Then
            Begin
              tmpSQL:=FindParam('Flat=', ScrStr);
              If tmpSQL='1' Then
                FGrids[GridIndex].TableParts[TabIndex].Navig.Flat:=true;
            End;

            TmpStr:=FindParam('Columns=', ScrStr);
            If TmpStr<>'' Then
            Begin
              v1:=ParamsCount(TmpStr);
              For v2:=1 To v1 Do
              Begin
                tmpStr2:=SortParams(TmpStr, v2);
                tmpSQL:=Copy(tmpStr2, 1, Pos('/', tmpStr2)-1);
                v1:=0;
                If Pos('=', tmpSQL)<>0 then
                Begin
                  v1:=StrToIntEx(CopyCut(tmpSQL, Pos('=', tmpSQL)+1, Length(tmpSQL)));
                  Delete(tmpSQL, PosEx('=', tmpSQL), Length(tmpSQL));
                End;

                ResetFieldParams(FField);
                If FieldExists(tmpSQL, FGrids[GridIndex].TableParts[TabIndex].FQuery) Then
                Begin
                  FField.FieldName:=tmpSQL;
                  FField.Caption:=Copy(tmpStr2, Pos('/', tmpStr2)+1, Length(tmpStr2)-1);
                  FField.Width:=v1;
                End
                Else
                Begin
                  FField.Caption:=SourceToInterface(GetDCLMessageString(msNoField))+tmpSQL;
                  FField.Width:=v1;
                End;

                FGrids[GridIndex].TableParts[TabIndex].AddField(FField);
              End;

              FGrids[GridIndex].TableParts[TabIndex].CreateColumns;
            End;
          End;
        End;
      end;

      If PosEx('SummQuery=', ScrStr)=1 Then
      Begin
        FGrids[GridIndex].AddSumGrid(ScrStr);
      End;

      If PosEx('ApplicationTitle=', ScrStr)=1 Then
      Begin
        tmpSQL:=FindParam('ApplicationTitle=', ScrStr);
        TranslateVal(tmpSQL);
        Application.Title:=tmpSQL;
      End;

      If PosEx('Debug;', ScrStr)=1 Then
      Begin
        GPT.DebugOn:=Not GPT.DebugOn;
      End;

      If PosEx('Events=', ScrStr)=1 Then
      Begin
        If PosEx('AfterOpenEvents=', ScrStr)<>0 Then
        Begin
          TmpStr:=FindParam('AfterOpenEvents=', ScrStr);
          AddEvents(FGrids[GridIndex].EventsAfterOpen, TmpStr);
        End;

        If PosEx('CloseEvents=', ScrStr)<>0 Then
        Begin
          TmpStr:=FindParam('CloseEvents=', ScrStr);
          AddEvents(EventsClose, TmpStr);
        End;

        If PosEx('BeforePostEvents=', ScrStr)<>0 Then
        Begin
          TmpStr:=FindParam('BeforePostEvents=', ScrStr);
          AddEvents(FGrids[GridIndex].EventsBeforePost, TmpStr);
        End;

        If PosEx('AfterPostEvents=', ScrStr)<>0 Then
        Begin
          TmpStr:=FindParam('AfterPostEvents=', ScrStr);
          AddEvents(FGrids[GridIndex].EventsAfterPost, TmpStr);
        End;

        If PosEx('CancelEvents=', ScrStr)<>0 Then
        Begin
          TmpStr:=FindParam('CancelEvents=', ScrStr);
          AddEvents(FGrids[GridIndex].EventsCancel, TmpStr);
        End;

        If PosEx('BeforeScrollEvents=', ScrStr)<>0 Then
        Begin
          TmpStr:=FindParam('BeforeScrollEvents=', ScrStr);
          AddEvents(FGrids[GridIndex].EventsBeforeScroll, TmpStr);
        End;

        If PosEx('ScrollEvents=', ScrStr)<>0 Then
        Begin
          TmpStr:=FindParam('ScrollEvents=', ScrStr);
          AddEvents(FGrids[GridIndex].EventsScroll, TmpStr);
        End;

        If PosEx('InsertEvents=', ScrStr)<>0 Then
        Begin
          TmpStr:=FindParam('InsertEvents=', ScrStr);
          AddEvents(FGrids[GridIndex].EventsInsert, TmpStr);
        End;

        If PosEx('DeleteEvents=', ScrStr)<>0 Then
        Begin
          TmpStr:=FindParam('DeleteEvents=', ScrStr);
          AddEvents(FGrids[GridIndex].EventsDelete, TmpStr);
        End;

        If PosEx('LineDblClickEvents=', ScrStr)<>0 Then
        Begin
          TmpStr:=FindParam('LineDblClickEvents=', ScrStr);
          AddEvents(FGrids[GridIndex].LineDblClickEvents, TmpStr);
        End;

        If PosEx('InsertPartEvents=', ScrStr)<>0 Then
        Begin
          TmpStr:=FindParam('InsertPartEvents=', ScrStr);
          AddEvents(FGrids[GridIndex].TableParts[TabIndex].EventsInsert, TmpStr);
        End;

        If PosEx('ScrollPartEvents=', ScrStr)<>0 Then
        Begin
          TmpStr:=FindParam('ScrollPartEvents=', ScrStr);
          AddEvents(FGrids[GridIndex].TableParts[TabIndex].EventsScroll, TmpStr);
        End;

        If PosEx('PostPartEvents=', ScrStr)<>0 Then
        Begin
          TmpStr:=FindParam('PostPartEvents=', ScrStr);
          AddEvents(FGrids[GridIndex].TableParts[TabIndex].EventsAfterPost, TmpStr);
        End;
      End;

      If PosEx('Declare=', ScrStr)=1 Then
      Begin
        ExecCommand(ScrStr);
      End;

      If PosEx('LocalDeclare=', ScrStr)=1 Then
      Begin
        TmpStr:=Trim(FindParam('LocalDeclare=', ScrStr));
        For v1:=1 To ParamsCount(TmpStr) Do
        Begin
          tmpStr2:=SortParams(TmpStr, v1);
          v2:=PosEx('=', tmpStr2);
          If v2=0 Then
          Begin
            LocalVariables.NewVariable(tmpStr2, '');
          End
          Else
          Begin
            tmpStr2:=Trim(Copy(tmpStr2, 1, v1-1));
            tmpSQL:=Copy(tmpStr2, v1+1, Length(tmpStr2)-v1);
            TranslateVal(tmpSQL);

            LocalVariables.NewVariable(tmpStr2, tmpSQL);
          End;
        End;
      End;

      If PosEx('Insert;', ScrStr)=1 Then
      Begin
        FGrids[GridIndex].Query.Insert;
      End;

      If PosEx('Append;', ScrStr)=1 Then
      Begin
        FGrids[GridIndex].Query.Append;
      End;

      If PosEx('Edit;', ScrStr)=1 Then
      Begin
        FGrids[GridIndex].Query.Edit;
      End;

      If PosEx('Post;', ScrStr)=1 Then
      Begin
        FGrids[GridIndex].Query.Post;
      End;

      If PosEx('First;', ScrStr)=1 Then
      Begin
        FGrids[GridIndex].Query.First;
      End;

      If PosEx('Prior;', ScrStr)=1 Then
      Begin
        FGrids[GridIndex].Query.Prior;
      End;

      If PosEx('Next;', ScrStr)=1 Then
      Begin
        FGrids[GridIndex].Query.Next;
      End;

      If PosEx('Last;', ScrStr)=1 Then
      Begin
        FGrids[GridIndex].Query.Last;
      End;

      If PosEx('Cancel;', ScrStr)=1 Then
      Begin
        FGrids[GridIndex].Query.Cancel;
      End;

      If PosEx('Color=', ScrStr)=1 Then
      Begin
        FGrids[GridIndex].AddBrushColor(ScrStr);
      End;

      If PosEx('DBImage=', ScrStr)=1 Then
      Begin
        TmpStr:=ScrStr;
        TranslateVal(TmpStr);
        ScrStr:=TmpStr;

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
      End;

      If PosEx('DBRichText=', ScrStr)=1 Then
      Begin
        TmpStr:=ScrStr;
        TranslateVal(TmpStr);
        ScrStr:=TmpStr;

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
      End;

      If PosEx('DBText=', ScrStr)=1 Then
      Begin
        TmpStr:=ScrStr;
        TranslateVal(TmpStr);
        ScrStr:=TmpStr;

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
      End;

      If PosEx('sqlmoon;', ScrStr)=1 Then
      Begin
        FDCLLogOn.SQLMon.TrraceStatus:=not FDCLLogOn.SQLMon.TrraceStatus;
      End;

      If PosEx('MultiSelect=', ScrStr)=1 Then
      Begin
        ExecCommand(ScrStr);
      End;

      /// /========================================Fields========================================
      If (LowerCase(ScrStr)=Trim('[fields]'))and not NoVisual Then
      begin
        FGrids[GridIndex].Show;
        FGrids[GridIndex].FQuery.NotAllowOperations:=FGrids[GridIndex].NotAllowedOperations;
        FField.Top:=BeginStepTop;
        FField.Left:=BeginStepLeft;
        If FOPL[ScrStrNum+1]='*' Then
        Begin
          If (FGrids[GridIndex].FieldCount>0)or(FGrids[GridIndex].Query.Active) then
            FOPL[ScrStrNum+1]:=IntToStr(FGrids[GridIndex].FieldCount)
          Else
            FOPL[ScrStrNum+1]:='0';

          For v1:=1 To FGrids[GridIndex].Query.FieldCount Do
          Begin
            FOPL.Insert(ScrStrNum+v1*2, FGrids[GridIndex].Query.Fields[v1-1].FieldName);
            FOPL.Insert(ScrStrNum+1+v1*2, FGrids[GridIndex].Query.Fields[v1-1].FieldName);
          End;
          OPLLinesCount:=FOPL.Count;
          // FOPL.SaveToFile('OPL.txt');
        End
        Else If PosEx('LoadFromTable=', FOPL[ScrStrNum+1])<>0 Then
        Begin
          ShadowQuery:=TDCLDialogQuery.Create(Nil);
          ShadowQuery.Name:='ShadFields_'+IntToStr(UpTime);
          FDCLLogOn.SetDBName(ShadowQuery);
          ShadowQuery.SQL.Text:=FindParam('SQL=', FOPL[ScrStrNum+1]);
          Try
            ShadowQuery.Open;
          Except
            // ShowErrorMessage(-1103, 'SQL='+ShadowQuery.SQL.Text);
          End;
          v2:=0;
          ShadowQuery.Last;
          ShadowQuery.First;
          FOPL[ScrStrNum+1]:=IntToStr(ShadowQuery.RecordCount);
          For v1:=0 To ShadowQuery.RecordCount-1 Do
          Begin
            FOPL.Insert(ScrStrNum+2+v1*2, Trim(ShadowQuery.Fields[0].AsString));
            FOPL.Insert(ScrStrNum+3+v1*2, Trim(ShadowQuery.Fields[1].AsString));
            ShadowQuery.Next;
            inc(v2);
          End;
          FreeAndNil(ShadowQuery);
        End;

        Try
          CountFields:=StrToInt(Trim(FOPL[ScrStrNum+1]));
        Except
          // ShowErrorMessage(-4002, '');
          CountFields:=0;
        End;

        Case DisplayMode of
        dctMainGrid:
        Begin
          If not FGrids[GridIndex].ReadOnly then
            FGrids[GridIndex].ReadOnly:=(FGrids[GridIndex].FUserLevelLocal=ulReadOnly)or
              (FGrids[GridIndex].FindNotAllowedOperation(dsoEdit));
          If (FGrids[GridIndex].FUserLevelLocal=ulReadOnly)or
            (FGrids[GridIndex].FindNotAllowedOperation(dsoEdit)) then
            FGrids[GridIndex].Options:=FGrids[GridIndex].Options-[dgEditing];
        End;
        dctFields, dctFieldsStep:
        begin
          { FGrids[GridIndex].FieldPanel:=TDialogPanel.Create(FGrids[GridIndex].FGridPanel);
            FGrids[GridIndex].FieldPanel.Parent:=FGrids[GridIndex].FGridPanel;
            FGrids[GridIndex].FieldPanel.Align:=alClient; }
        end;

        End;

        FieldNo:=0;
        For OPLStrNo:=1 To CountFields Do
        Begin
          inc(FieldNo);
          ResetFieldParams(FField);
          If FOPL.Count<ScrStrNum+FieldNo+FieldNo+1 then
            break;

          FieldCaptScrStr:=FOPL[ScrStrNum+FieldNo+FieldNo];
          FieldNameStr:=FOPL[ScrStrNum+FieldNo+FieldNo+1];
          FField.OPL:=FieldCaptScrStr+';'+FieldNameStr;

          inc(GPT.CurrentRunningScrString);

          If Pos('//', FOPL[ScrStrNum+FieldNo+FieldNo])=1 Then
            If ScrStrNum+FieldNo+FieldNo<OPLLinesCount Then
            Begin
              inc(FieldNo);
              Continue;
            End;

          If Pos('\', FOPL[ScrStrNum+FieldNo+FieldNo])<>0 Then
          Begin
            i1:=1;
            While FOPL[ScrStrNum+FieldNo+FieldNo][i1]<>'\' Do
              inc(i1);
            FField.Caption:=Copy(FOPL[ScrStrNum+FieldNo+FieldNo], 1, i1-1);
          End
          Else
          Begin
            If Pos(';', FOPL[ScrStrNum+FieldNo+FieldNo])<>0 Then
            Begin
              i1:=1;
              While FOPL[ScrStrNum+FieldNo+FieldNo][i1]<>';' Do
                inc(i1);
              FField.Caption:=InitCap(Trim(Copy(FOPL[ScrStrNum+FieldNo+FieldNo], 1, i1-1)));
            End
            Else
              FField.Caption:=InitCap(Trim(FOPL[ScrStrNum+FieldNo+FieldNo]));
          End;

          TmpStr:=FOPL[ScrStrNum+FieldNo+FieldNo+1];
          If Pos(';', TmpStr)<>0 Then
          Begin
            i1:=1;
            While TmpStr[i1]<>';' Do
              inc(i1);
            FField.FieldName:=Trim(Copy(TmpStr, 1, i1-1));
          End
          Else
            FField.FieldName:=Trim(FOPL[ScrStrNum+FieldNo+FieldNo+1]);

          FField.Hint:=FindParam('Hint=', FOPL[ScrStrNum+FieldNo+FieldNo]);

          TmpStr:=FindParam('VariableName=', FOPL[ScrStrNum+FieldNo+FieldNo]);
          If TmpStr<>'' Then
            FField.Variable:=TmpStr;

          If FieldExists(FField.FieldName, FGrids[GridIndex].Query) Then
            FField.FType:=FGrids[GridIndex].Query.FieldByName(FField.FieldName).DataType
          Else
            FField.FType:=ftString;

          If PosEx('HidePassword;', FOPL[ScrStrNum+FieldNo+FieldNo])<>0 Then
            FField.PasswordChar:=MaskPassChar
          Else
            FField.PasswordChar:=#0;

          If PosEx('As_Logic;', FOPL[ScrStrNum+FieldNo+FieldNo])<>0 Then
          Begin
            FField.FType:=ftBoolean;
            TmpStr:=Trim(FindParam('ValueChecked=', FOPL[ScrStrNum+FieldNo+FieldNo]));
            If TmpStr<>'' Then
              FField.CheckValue:=TmpStr;
            TmpStr:=Trim(FindParam('ValueUnChecked=', FOPL[ScrStrNum+FieldNo+FieldNo]));
            If TmpStr<>'' Then
              FField.UnCheckValue:=TmpStr;
          End;

          If PosEx('As_Graphic;', FOPL[ScrStrNum+FieldNo+FieldNo])<>0 Then
          Begin
            FField.FType:=ftGraphic;
          End;

          If PosEx('As_Memo;', FOPL[ScrStrNum+FieldNo+FieldNo])<>0 Then
          Begin
            FField.FType:=ftMemo;
          End;

          If PosEx('As_RichText;', FOPL[ScrStrNum+FieldNo+FieldNo])<>0 Then
          Begin
            FField.DataFieldType:=dftRichText;
            FField.FType:=ftFmtMemo;
          End;

          If PosEx('As_Float;', FOPL[ScrStrNum+FieldNo+FieldNo])<>0 Then
          Begin
            FField.FType:=ftFloat;
          End;

          If DisplayMode in TDataFields then
            Case FField.FType Of
            ftDate, ftTime:
            FField.Width:=DateBoxWidth;
            ftDateTime:
            FField.Width:=DateTimeBoxWidth;
            ftFloat, ftCurrency, ftSmallint, ftInteger, ftWord, ftAutoInc, ftLargeint, ftBCD:
            FField.Width:=DigitEditWidth;
          Else
          FField.Width:=EditWidth;
            End;

          If FindParam('Width=', FField.OPL)<>'' then
          Begin
            FField.Width:=StrToIntEx(FindParam('Width=', FField.OPL));
            FField.IsFieldWidth:=true;
          End;

          If FindParam('Height=', FField.OPL)<>'' then
          Begin
            FField.Height:=StrToIntEx(FindParam('Height=', FField.OPL));
            FField.IsFieldHeight:=true;
          End;

          If FindParam('ReadOnly=', FField.OPL)<>'' then
          Begin
            // Убрать везде
            FField.ReadOnly:=StrToIntEx(FindParam('ReadOnly=', FField.OPL))=1;
          End;

          Case DisplayMode of
          dctFields, dctFieldsStep:
          begin
            If PosEx('[FieldParagraphDown];', FOPL[ScrStrNum+FieldNo+FieldNo])<>0 Then
            Begin
              Case FField.FType Of
              ftGraphic:
              inc(FField.Top, GraficTopStep);
              ftMemo:
              inc(FField.Top, MemoHeight+FieldDownStep);
            Else
            inc(FField.Top, EditTopStep)
              End;
            End;

            FGrids[GridIndex].AddLabel(FField, FField.Caption);

            If PosEx('ContextButton=', FieldCaptScrStr)<>0 Then
            Begin
              FGrids[GridIndex].AddContextButton(FField);
            End;

            // ----------------------------------------------------------------
            If PosEx('OutBox=', FieldCaptScrStr)<>0 Then
            Begin
              FGrids[GridIndex].AddFieldBox(FField, fbtOutBox, 'OutBox_');
            End;

            If PosEx('InputBox=', FieldCaptScrStr)<>0 Then
            Begin
              FGrids[GridIndex].AddFieldBox(FField, fbtInputBox, 'InputBox_');
            End;

            If PosEx('EditBox=', FieldCaptScrStr)<>0 Then
            Begin
              FGrids[GridIndex].AddFieldBox(FField, fbtEditBox, 'EditBox_');
            End;

            If PosEx('DateBox=', FieldCaptScrStr)<>0 Then
            Begin
              FGrids[GridIndex].AddDateBox(FField);
            End;

            If PosEx('CheckBox=', FieldCaptScrStr)<>0 Then
            Begin
              FGrids[GridIndex].AddCheckBox(FField);
            End;

            If PosEx('LookUp=', FieldCaptScrStr)<>0 Then
            Begin
              FGrids[GridIndex].AddLookUp(FField);
            End;

            If PosEx('RollBar=', FieldCaptScrStr)<>0 Then
            Begin
              FGrids[GridIndex].AddRollBar(FField);
            End;

            If PosEx('ContextList=', FieldCaptScrStr)<>0 Then
            Begin
              FGrids[GridIndex].AddContextList(FField);
            End;

            If PosEx('DropListBox=', FieldCaptScrStr)<>0 Then
            Begin
              FGrids[GridIndex].AddDropBox(FField);
            End;

            If PosEx('LookupTable=', FieldCaptScrStr)<>0 Then
            Begin
              FGrids[GridIndex].AddLookupTable(FField);
            End;

          end;
          dctMainGrid:
          begin
            If not FieldExists(FField.FieldName, FGrids[GridIndex].Query) Then
              FField.Caption:=SourceToInterface(GetDCLMessageString(msNoField))+FField.FieldName;

            FGrids[GridIndex].AddColumn(FField);
            If PosEx('DropListBox=', FField.OPL)<>0 Then
              FGrids[GridIndex].AddDropBox(FField);
          end;
          End;
          FGrids[GridIndex].AddField(FField);

          If DisplayMode in TDataFields then
            If not FField.CurrentEdit and FieldExists(FField.FieldName, FGrids[GridIndex].Query)
            then
            begin
              Case FField.FType Of
              ftDate, ftTime, ftDateTime, ftFloat, ftCurrency, ftSmallint, ftInteger, ftWord,
                ftAutoInc, ftLargeint, ftBCD:
              Begin
                FGrids[GridIndex].AddEdit(FField);
              End;
              ftMemo, ftFmtMemo, ftBlob:
              Begin
                If FField.DataFieldType=dftRichText Then
                  FGrids[GridIndex].AddMediaFieldGroup(FGrids[GridIndex].FieldPanel, alNone,
                    gtRichText, FField)
                Else
                  FGrids[GridIndex].AddMediaFieldGroup(FGrids[GridIndex].FieldPanel, alNone,
                    gtMemo, FField);
              End;
              ftGraphic, ftDBaseOle, ftParadoxOle, ftTypedBinary:
              Begin
                FGrids[GridIndex].AddMediaFieldGroup(FGrids[GridIndex].FieldPanel, alNone,
                  gtGrafic, FField);
              End;
              ftBoolean:
              Begin
                FGrids[GridIndex].AddCheckBox(FField);
              End
            Else
            FGrids[GridIndex].AddEdit(FField);
              End;
            End;
        End;
      End;

      /// //////////////////////////////
      inc(ScrStrNum);
    end;

    QueryGlob:=FGrids[0].FQuery;
    DataGlob:=FGrids[0].DataSource;

    // MainPanel.Align:=alClient;
    // FGrids[GridIndex].ButtonPanel.Align:=alBottom;

    For ScrStrNum:=1 to length(FGrids) do
    begin
      FGrids[ScrStrNum-1].Show;
    end;

    MainPanel.Height:=120;
    MainPanel.Width:=350;
    MainPanel.Align:=alClient;

    If FormWidth>FForm.Width Then
      FForm.Width:=FormWidth;

    If Assigned(FDCLLogOn.FDCLMainMenu) then
      If ShowFormPanel Then
        If Assigned(FDCLLogOn.FDCLMainMenu.FormBar) Then
          If FDCLLogOn.FDCLMainMenu.FormBar.Parent<>FForm Then
          Begin
            TB.Caption:=FForm.Caption;
            TB.Hint:=FForm.Caption;
            TB.ShowHint:=true;
            TB.Show;
          End;

    FPages.ActivePageIndex:=0;

    If Not FForm.Showing Then
    If ModalOpen then
      FForm.ShowModal
    Else
    Begin
      FForm.Show;

      If FormHeight<>0 Then
        FForm.ClientHeight:=FormHeight;

      // Query.AfterScroll(Query);

{$IFNDEF DCLDEBUG}
      If Modal Then
        FForm.FormStyle:=fsStayOnTop;
{$ENDIF}
    End;
  End;
  LoadFormPos; //(FDCLLogOn, FForm, DialogName);
end;

procedure TDCLForm.DeleteAllStatus;
var
  i: Integer;
begin
  If DBStatus.Panels.Count>2 then
    For i:=3 to DBStatus.Panels.Count do
      DeleteStatus(i-1);
end;

procedure TDCLForm.DeleteStatus(StatusNum: Integer);
begin
  If StatusNum<0 then
    StatusNum:=DBStatus.Panels.Count-1;
  If Assigned(DBStatus) then
    If (DBStatus.Panels.Count>StatusNum)and(StatusNum>1) then
    Begin
      DBStatus.Panels.Delete(StatusNum);
    End;
end;

function TDCLGrid.FindNotAllowedOperation(Operation: TNotAllowedOperations): Boolean;
Var
  l, i: Byte;
Begin
  l:=length(NotAllowedOperations);
  Result:=False;
  If l>0 then
    For i:=0 to l-1 do
    Begin
      If NotAllowedOperations[i]=Operation then
      Begin
        Result:=true;
        break;
      End;
    End;
end;

function TDCLForm.GetActive: Boolean;
begin
  Result:=FDCLLogOn.ActiveDCLForms[FFormNum];
end;

function TDCLForm.GetDataSource: TDataSource;
begin
  Result:=DataGlob;
end;

function TDCLForm.GetMainQuery: TDCLQuery;
begin
  Result:=QueryGlob;
end;

function TDCLForm.GetParentForm: TDCLForm;
begin
  Result:=FParentForm;
end;

function TDCLForm.GetPartQuery: TDCLQuery;
begin
  Result:=Tables[-1].TableParts[-1].Query;
end;

function TDCLForm.GetTable(Index: Integer): TDCLGrid;
var
  i, j: Integer;
begin
  Result:=nil;
  If length(FGrids)>0 then
  Begin
    If ((Index=-1)or(Index=0))and(length(FGrids)>0) then
      Result:=FGrids[CurrentGridIndex]
    Else
    Begin
      j:=0;
      for i:=1 to length(FGrids) do
      Begin
        If FGrids[i-1].TabType=ptMainPage then
          inc(j);
        If j=Index then
        Begin
          Result:=FGrids[i-1];
          break;
        End;
      End;
    End;
  End;
end;

function TDCLForm.GetTablesCount: Integer;
begin
  Result:=length(FGrids);
end;

function TDCLForm.GridsCount: Word;
begin
  Result:=length(FGrids);
end;

procedure TDCLForm.RefreshForm;
var
  i: Integer;
begin
  For i:=1 to length(FGrids) do
  Begin
    FGrids[i-1].ReFreshQuery;
  End;
end;

procedure TDCLForm.RePlaseParams(var Params: string);
begin
  FGrids[CurrentGridIndex].RePlaseParams(Params);
end;

procedure TDCLForm.RePlaseVariables(var VariablesSet: String);
begin
  LocalVariables.RePlaseVariables(VariablesSet, QueryGlob);
  FDCLLogOn.RePlaseVariables(VariablesSet);
end;

procedure TDCLForm.ResizeDBForm(Sender: TObject);
Var
  ToolBtnSize: Word;
  i, j: Byte;
Begin
  For j:=1 to length(FGrids) do
  Begin
    If Assigned(FGrids[j-1].ToolButtonPanel) Then
      If (FGrids[j-1].ToolButtonPanel.Width>0)And(FGrids[j-1].ToolButtonsCount>0) Then
      Begin
        ToolBtnSize:=FGrids[j-1].ToolButtonPanel.Width Div FGrids[j-1].ToolButtonsCount;
        For i:=1 To FGrids[j-1].ToolButtonsCount Do
          FGrids[j-1].ToolButtonPanelButtons[i].Width:=ToolBtnSize;
      End;
  End;
End;

{procedure TDCLForm.RunCommand(Command: String);
Var
  vDCLCommand: TDCLCommand;
begin
  vDCLCommand:=TDCLCommand.Create(Self, FDCLLogOn);
  vDCLCommand.ExecCommand(Command, Self);
  FreeAndNil(vDCLCommand);
end; }


procedure TDCLForm.SetActive;
begin
  FDCLLogOn.ActiveDCLForms[FFormNum]:=True;
end;

procedure TDCLForm.SetDBStatus(StatusStr: String);
begin
  If Assigned(DBStatus) then
  Begin
    DBStatus.Panels[1].Text:=StatusStr;
  End;
end;

procedure TDCLForm.SetInactive;
begin
  FDCLLogOn.ActiveDCLForms[FFormNum]:=False;
end;

procedure TDCLForm.SetRecNo;
begin
  If Assigned(DBStatus) then
  Begin
    DBStatus.Panels[0].Text:=IntToStr(CurrentQuery.RecNo)+'/'+IntToStr(CurrentQuery.RecordCount);
  End;
end;

procedure TDCLForm.SetStatus(StatusStr: String; StatusNum, Width: Integer);
begin
  If StatusNum<0 then
    StatusNum:=DBStatus.Panels.Count-1;
  If Assigned(DBStatus) then
    If DBStatus.Panels.Count>StatusNum then
    Begin
      DBStatus.Panels[StatusNum].Text:=StatusStr;
      If Width>5 then
        DBStatus.Panels[StatusNum].Width:=Width;
    End;
end;

procedure TDCLForm.SetTabIndex(Index: Integer);
begin
  If Assigned(FPages.Pages[Index]) then
    FPages.ActivePageIndex:=Index;
end;

procedure TDCLForm.SetTable(Index: Integer; Value: TDCLGrid);
begin
  if length(FGrids)>Index then
    FGrids[Index]:=Value;
end;

procedure TDCLForm.SetVariable(VarName, VValue: string);
begin
  If LocalVariables.Exists(VarName) then
    LocalVariables.Variables[VarName]:=VValue
  Else If FDCLLogOn.Variables.Exists(VarName) then
    FDCLLogOn.Variables.Variables[VarName]:=VValue;
end;

procedure TDCLForm.GetChooseValue;
Var
  CurrentGrid:TDCLGrid;
  KeyField:String;
begin
  ResetChooseValue(FRetunValue);
  CurrentGrid:=Tables[-1];
  FRetunValue.Choosen:=False;
  If Assigned(CurrentGrid) then
  Begin
    If Assigned(FReturnValueParams) then
    Begin
      FRetunValue.Choosen:=True;
      KeyField:=CurrentGrid.Query.KeyField;
      FRetunValue.ModifyField:=FReturnValueParams.ModifyField;
      FRetunValue.EditName:=FReturnValueParams.EditName;

      If FReturnValueParams.KeyField<>'' then
        FRetunValue.Key:=CurrentGrid.Query.FieldByName(FReturnValueParams.KeyField).AsString
      Else
        If KeyField<>'' then
          FRetunValue.Val:=CurrentGrid.Query.FieldByName(KeyField).AsString;

      If FReturnValueParams.DataField<>'' then
        FRetunValue.Val:=CurrentGrid.Query.FieldByName(FReturnValueParams.DataField).AsString;
    End;
  End;
end;

function TDCLForm.ChooseAndClose(Action: TChooseMode): TReturnFormValue;
begin
  GetChooseValue;
  FRetunValue.Choosen:=True;
  SetLength(FDCLLogOn.ReturnFormsValues, FFormNum+1);
  FDCLLogOn.ReturnFormsValues[FFormNum]:=FRetunValue;
  Result:=FRetunValue;
  If Action=chmChooseAndClose then
  Begin
    NotDestroyedDCLForm:=True;
    FForm.Close;
  End;  
end;

procedure TDCLForm.ToolButtonClick(Sender: TObject);
Var
  TB1: TFormPanelButton;
Begin
  If GetActive Then
  Begin
    If Assigned(FForm) Then
    Begin
      If FForm.WindowState=wsMinimized Then
        FForm.WindowState:=wsNormal;
      FForm.Show;
      FForm.BringToFront;
    End;
  End
  Else
  Begin
    If Assigned(FDCLLogOn.FDCLMainMenu) then
      If ShowFormPanel Then
      Begin
        If Assigned(FDCLLogOn.FDCLMainMenu.FormBar) Then
        Begin
          TB1:=(Sender As TFormPanelButton);
          FreeAndNil(TB1);
        End;
      End;
  End;
End;

procedure TDCLForm.TranslateVal(var Params: String);
Var
  FFactor: Word;
Begin
  RePlaseParams(Params);
  RePlaseVariables(Params);
  FFactor:=0;
  TranslateProc(Params, FFactor);
End;

{ TDCLCommand }

procedure TDCLCommand.SetValue(S: String);
Var
  tmp1, tmp2, VarName, ReturnField, SQLText, KeyField: String;
  i, sv_v2, v2, v0: Integer;
  DCLQuery: TDCLDialogQuery;
Begin
  ReturnField:='';
  tmp2:=FindParam('SetValue=', S);
  If PosEx('ReturnQuery=', S)=0 Then
  Begin
    TranslateValContext(tmp2);

    KeyField:=Trim(FindParam('TablePart=', S));
    If KeyField<>'' Then
    Begin
      v2:=StrToIntEx(KeyField)-1;
      If v2=0 Then
        v2:=FDCLForm.CurrentTabIndex;
      If Assigned(FDCLForm) Then
        If Assigned(FDCLForm.Tables[-1]) Then
          If Assigned(FDCLForm.Tables[-1].TableParts[v2]) Then
            If FDCLForm.Tables[-1].TableParts[v2].Query.Active Then
              TranslateVals(tmp2, FDCLForm.Tables[-1].TableParts[v2].Query);
    End
    Else
      TranslateValContext(tmp2);

    sv_v2:=Pos('=', tmp2)-1;
    If sv_v2<=0 Then
      sv_v2:=Length(tmp2);
    VarName:=Copy(LowerCase(tmp2), 1, sv_v2);
    If FDCLLogOn.Variables.Exists(VarName) Then
      If Pos('=', tmp2)<>0 Then
      Begin
        sv_v2:=Pos('=', tmp2)-1;
        Delete(tmp2, 1, sv_v2+1);

        KeyField:=Trim(FindParam('TablePart=', S));
        If KeyField<>'' Then
        Begin
          v2:=StrToIntEx(KeyField)-1;
          If v2=0 Then
            v2:=FDCLForm.CurrentTabIndex;
          If Assigned(FDCLForm.Tables[-1]) Then
            If Assigned(FDCLForm.Tables[-1].TableParts[v2]) Then
              If FDCLForm.Tables[-1].Query.Active Then
                TranslateVals(tmp2, FDCLForm.Tables[-1].TableParts[v2].Query);
        End
        Else
          TranslateValContext(tmp2);

        TranslateValContext(tmp2);
        FDCLLogOn.Variables.Variables[VarName]:=tmp2;
      End
      Else
        FDCLLogOn.Variables.Variables[VarName]:='';
  End;

  If PosEx('ReturnQuery=', S)<>0 Then
  Begin
    SQLText:=FindParam('ReturnQuery=', S);
    TranslateValContext(SQLText);
    If SQLText<>'' Then
    Begin
      DCLQuery:=TDCLDialogQuery.Create(Nil);
      DCLQuery.Name:='SetVal_Ret'+IntToStr(UpTime);
      FDCLLogOn.SetDBName(DCLQuery);
      DCLQuery.SQL.Text:=SQLText;
      Screen.Cursor:=crSQLWait;
      Try
        DCLQuery.Open;
      Except
        Screen.Cursor:=crDefault;
        ShowErrorMessage(-1105, 'SQL='+SQLText);
      End;
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
      FDCLLogOn.Variables.NewVariable(tmp1);

      tmp2:=TrimRight(DCLQuery.FieldByName(ReturnField).AsString);
      TranslateValContext(tmp2);

      FDCLLogOn.Variables.Variables[tmp1]:=tmp2;
      DCLQuery.Close;
      FreeAndNil(DCLQuery);
    End;
  End;

  If FDCLLogOn.FormsCount>0 then
    For v2:=0 to FDCLLogOn.FormsCount-1 do
    Begin
      If Assigned(FDCLLogOn.Forms[v2]) then
      Begin
        If FDCLLogOn.ActiveDCLForms[v2] then
        Begin
          For sv_v2:=1 to length(FDCLLogOn.Forms[v2].FGrids) do
          Begin
            If Assigned(FDCLLogOn.Forms[v2].FGrids[sv_v2-1]) then
            For i:=1 To length(FDCLLogOn.Forms[v2].FGrids[sv_v2-1].Edits) Do
            Begin
              Case FDCLLogOn.Forms[v2].FGrids[sv_v2-1].Edits[i-1].EditsType Of
              fbtOutBox, fbtEditBox:
              FDCLLogOn.Forms[v2].FGrids[sv_v2-1].Edits[i-1].Edit.Text:=
                FDCLLogOn.Variables.Variables[FDCLLogOn.Forms[v2].FGrids[sv_v2-1].Edits[i-1]
                .EditToVariables];
              End;
            End;

            If Assigned(FDCLLogOn.Forms[v2]) then
            If Assigned(FDCLLogOn.Forms[v2].FGrids[sv_v2-1]) then
            For v0:=1 to length(FDCLLogOn.Forms[v2].FGrids[sv_v2-1].FTableParts) do
              If length(FDCLLogOn.Forms[v2].FGrids[sv_v2-1].FTableParts[v0-1].Edits)>0 Then
              Begin
                For i:=1 To length(FDCLLogOn.Forms[v2].FGrids[sv_v2-1].Edits) Do
                Begin
                  Case FDCLLogOn.Forms[v2].FGrids[sv_v2-1].FTableParts[v0-1].Edits[i-1].EditsType Of
                  fbtOutBox, fbtEditBox:
                  FDCLLogOn.Forms[v2].FGrids[sv_v2-1].FTableParts[v0-1].Edits[i-1].Edit.Text:=
                    FDCLLogOn.Variables.Variables
                    [FDCLLogOn.Forms[v2].FGrids[sv_v2-1].FTableParts[v0-1].Edits[i-1]
                    .EditToVariables];
                  End;
                End;
              End;
          End;
        End;
      End;
    End;
End;

procedure TDCLCommand.SetVariable(VarName, VValue: String);
begin
  If Assigned(FDCLForm) then
    FDCLForm.SetVariable(VarName, VValue)
  Else If FDCLLogOn.Variables.Exists(VarName) then
    FDCLLogOn.Variables.Variables[VarName]:=VValue;
end;

procedure TDCLCommand.TranslateVals(var Params: String; Query: TDCLDialogQuery);
Var
  FFactor: Word;
Begin
  RePlaseParams_(Params, Query);
  RePlaseVariabless(Params);
  FFactor:=0;
  TranslateProc(Params, FFactor);
End;

procedure TDCLCommand.TranslateValContext(var Params: String);
begin
  If Assigned(FDCLForm) then
  begin
    If Assigned(FDCLForm.CurrentQuery) then
      TranslateVals(Params, FDCLForm.CurrentQuery);
  end
  else
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
  If Assigned(DCLQuery) then
    FreeAndNil(DCLQuery);
  If Assigned(DCLQuery2) then
    FreeAndNil(DCLQuery2);
end;

procedure TDCLCommand.ExecCommand(Command: String; DCLForm: TDCLForm);
var
  ModalOpen, InContext, Enything: Boolean;
  IfCounter, IfSign: Byte;
  RecCount, ScriptStrings, RetPoint, v1, v2, v3, RepIdParams: Integer;
  ScrStr, TmpStr, tmpStr1, tmpStr2, tmpStr3, tmp1, tmp2, tmp3, tmp4, RepTable: string;
  ChooseMode: TChooseMode;
  ReturnValueParams:TReturnValueParams;
  OpenDialog: TOpenDialog;
  SaveDialog: TSaveDialog;
  BookMark: TBookmark;
  tmpDCL: TStringList;
  LocalCommand: TDCLCommand;
  FormsStack: array of TDCLForm;

  Procedure GotoGoto(LabelName: String);
  Var
    StringNum: Integer;
  Begin
    For StringNum:=0 To FCommandDCL.Count-1 Do
      If CompareString(FCommandDCL[StringNum], ':'+LabelName+';') then
      // If LowerCase(FCommandDCL[StringNo])=':'+LowerCase(LabelName)+';' Then
      Begin
        ScriptStrings:=StringNum;
        break;
      End;
  End;

  Procedure SetRetPoint;
  Begin
    RetPoint:=ScriptStrings;
  End;

  Procedure GetRetPoint;
  Begin
    If RetPoint<>-1 then
    Begin
      ScriptStrings:=RetPoint-1;
    End;
  End;

  procedure Pushf(Form: TDCLForm);
  var
    l: Word;
  begin
    l:=length(FormsStack);
    SetLength(FormsStack, l+1);
    FormsStack[l]:=Form;
  end;

  function Popf: TDCLForm;
  var
    l: Word;
  begin
    Result:=nil;
    l:=length(FormsStack);
    If l>0 then
    begin
      If Assigned(FormsStack[l-1]) then
        Result:=FormsStack[l-1]
      else
        ScriptStrings:=FCommandDCL.Count;
      SetLength(FormsStack, l-1);
    end
    else
      ScriptStrings:=FCommandDCL.Count;
  end;

begin
  FDCLLogOn.SQLMon.AddTrace(DCLQuery);
  FDCLLogOn.SQLMon.AddTrace(DCLQuery2);
  IfCounter:=0;

  If FDCLLogOn.RoleOK<>lsLogonOK then
    Exit;
  FDCLForm:=DCLForm;
  FDCLLogOn.NotifyForms(fnaPauseAutoRefresh);
  Command:=Trim(Command);
  Executed:=False;
  { MainForm:=FDCLForm;
    CurrentForm:=FDCLForm; }
  InContext:=Assigned(FDCLForm);

  If CompareString(Command, 'Choose') then
  Begin
    if Assigned(FDCLForm) then
      FDCLForm.ChooseAndClose(chmChoose);
  End;

  If CompareString(Command, 'ChooseAndClose') then
  Begin
    if Assigned(FDCLForm) then
      FDCLForm.ChooseAndClose(chmChooseAndClose);
    Exit;
  End;

  If CompareString(Command, 'Close') then
  Begin
    if Assigned(FDCLForm) then
      FDCLLogOn.CloseForm(FDCLForm);
    //FDCLForm:=Popf;
    Executed:=true;
    Exit;
  End;

  If CompareString(Command, 'Structure') then
  Begin
    FDCLForm.Tables[FDCLForm.CurrentGridIndex].Structure(nil);
    Executed:=true;
  End;

  If CompareString(Command, 'find') then
  Begin
    FDCLForm.Tables[FDCLForm.CurrentGridIndex].PFind(nil);
    Executed:=true;
  End;

  If CompareString(Command, 'print') then
  Begin
    FDCLForm.Tables[FDCLForm.CurrentGridIndex].Print(nil);
    Executed:=true;
  End;

  If CompareString(Command, 'SaveDB') Then
  Begin
    if Assigned(FDCLForm) then
      FDCLForm.Tables[-1].SaveDB;
    Executed:=true;
  End;

  If CompareString(Command, 'CancelDB') Then
  Begin
    if Assigned(FDCLForm) then
    Begin
      // FDCLForm.Tables[-1].ca
    End;
    Executed:=true;
  End;

  If CompareString(Command, 'CloseDialog') Then
  Begin
    if Assigned(FDCLForm) then
      FDCLLogOn.CloseForm(FDCLForm);
    FDCLForm:=Popf;
    Executed:=true;
  End;

  If CompareString(Command, 'PostClose') Then
  Begin
    If FDCLForm.CurrentQuery.State in [dsEdit, dsInsert] Then
      FDCLForm.CurrentQuery.Post;
    if Assigned(FDCLForm) then
      FreeAndNil(FDCLForm);
    Executed:=true;
  End;

  If CompareString(Command, 'CancelClose') Then
  Begin
    If FDCLForm.CurrentQuery.State in [dsEdit, dsInsert] Then
      FDCLForm.CurrentQuery.Cancel;
    if Assigned(FDCLForm) then
      FreeAndNil(FDCLForm);
    Executed:=true;
  End;

  If CompareString(Command, 'Post') Then
  Begin
    If FDCLForm.CurrentQuery.State in [dsEdit, dsInsert] Then
      FDCLForm.CurrentQuery.Post;
    Executed:=true;
  End;

  If CompareString(Command, 'Delete') Then
  Begin
    If GetRaightsByContext(InContext)>ulReadOnly Then
      FDCLForm.CurrentQuery.Delete;
    Executed:=true;
  End;

  If CompareString(Command, 'DeleteConf') Then
  Begin
    If GetRaightsByContext(InContext)>ulReadOnly Then
      If ShowErrorMessage(10, SourceToInterface('Удалить запись?'))=1 Then
        FDCLForm.CurrentQuery.Delete;
    Executed:=true;
  End;

  If CompareString(Command, 'Insert') Then
  Begin
    If GetRaightsByContext(InContext)>ulReadOnly Then
      FDCLForm.CurrentQuery.Insert;
    Executed:=true;
  End;

  If CompareString(Command, 'Append') Then
  Begin
    If GetRaightsByContext(InContext)>ulReadOnly Then
      FDCLForm.CurrentQuery.Append;
    Executed:=true;
  End;

  // ==============================================================
  If CompareString(Command, 'Post_Part') Then
  Begin
    If FDCLForm.CurrentPartQuery.State in [dsEdit, dsInsert] Then
      FDCLForm.CurrentPartQuery.Post;
    Executed:=true;
  End;

  If CompareString(Command, 'Delete_Part') Then
  Begin
    If GetRaightsByContext(InContext)>ulReadOnly Then
      FDCLForm.CurrentPartQuery.Delete;
    Executed:=true;
  End;

  If CompareString(Command, 'DeleteConf_Part') Then
  Begin
    If GetRaightsByContext(InContext)>ulReadOnly Then
      If ShowErrorMessage(10, SourceToInterface(GetDCLMessageString(msDeleteRecord)+'?'))=1 Then
        FDCLForm.CurrentPartQuery.Delete;
    Executed:=true;
  End;

  If CompareString(Command, 'Cancel_Part') Then
  Begin
    FDCLForm.CurrentPartQuery.Cancel;
    Executed:=true;
  End;

  If CompareString(Command, 'Insert_Part') Then
  Begin
    If GetRaightsByContext(InContext)>ulReadOnly Then
      FDCLForm.CurrentPartQuery.Insert;
    Executed:=true;
  End;

  If CompareString(Command, 'Append_Part') Then
  Begin
    If GetRaightsByContext(InContext)>ulReadOnly Then
      FDCLForm.CurrentPartQuery.Append;
    Executed:=true;
  End;
  // ==============================================================

  If CompareString(Command, 'ClearAllContextFilters') Then
  Begin
    If Assigned(FDCLForm) then
      If length(FDCLForm.Tables[-1].DBFilters)>0 Then
        For v1:=1 to length(FDCLForm.Tables[-1].DBFilters) do
        Begin
          if FDCLForm.Tables[-1].DBFilters[v1-1].FilterType=ftContextFilter then
            If Assigned(FDCLForm.Tables[-1].DBFilters[v1-1].Edit) Then
              FDCLForm.Tables[-1].DBFilters[v1-1].Edit.Clear;
        End;
  End;

  If CompareString(Command, 'About')or CompareString(Command, 'Version') Then
  Begin
    FDCLLogOn.About(nil);
    Executed:=true;
  End;

  If CompareString(Command, 'Lock') Then
  Begin
    FDCLLogOn.Lock;
    Executed:=true;
  End;

  If CompareString(Command, 'SQLMon_Clear') Then
  Begin
    FDCLLogOn.SQLMon.Clear;
    Executed:=true;
  End;

  If CompareString(Command, 'SQLMon') Then
  Begin
    FDCLLogOn.SQLMon.TrraceStatus:=not FDCLLogOn.SQLMon.TrraceStatus;
    Executed:=true;
  End;

  If not Executed Then
  Begin
    RecCount:=0;
    If Pos('''', Command)=0 Then
      If Pos(#10, Command)=0 Then
      Begin
        DCLQuery.Close;
        DCLQuery.SQL.Text:='select Count(*) from '+GPT.DCLTable+' where '+GPT.UpperString+
          GPT.DCLNameField+GPT.UpperStringEnd+'='+GPT.UpperString+GPT.StringTypeChar+Command+
          GPT.StringTypeChar+GPT.UpperStringEnd;
        Try
          DCLQuery.Open;
          RecCount:=DCLQuery.Fields[0].AsInteger;
        Except
          DCLQuery.SQL.Clear;
          RecCount:=0;
        End;
        If RecCount>0 Then
        Begin
          DCLQuery.Close;
          DCLQuery.SQL.Text:='select * from '+GPT.DCLTable+' where '+GPT.UpperString+
            GPT.DCLNameField+GPT.UpperStringEnd+'='+GPT.UpperString+GPT.StringTypeChar+Command+
            GPT.StringTypeChar+GPT.UpperStringEnd;
          DCLQuery.Open;
        End;
      End;

    If RecCount=0 Then
    Begin
      FCommandDCL.Clear;
      FCommandDCL.Text:=Command;
      /// DebugProc('Попытка исполнить команду: '+Command);
      /// If PosEx('script type=visual', FCommandDCL[0])<>0 Then Open(Nil, Nil, Nil, '', FCommandDCL);
    End
    Else
    Begin
      FCommandDCL.Text:=DCLQuery.FieldByName(GPT.DCLTextField).AsString;
    End;
    DCLQuery.Close;

    StopFlag:=False;
    Breaking:=False;

    If FCommandDCL.Count<>0 Then
    Begin
      GPT.CurrentRunningCmdString:=0;
      ScriptStrings:=0;
      RetPoint:=-1;
      While ScriptStrings<FCommandDCL.Count Do
      Begin
        GPT.CurrentRunningCmdString:=ScriptStrings;

        ScrStr:=FCommandDCL[ScriptStrings];
        TranslateValContext(ScrStr);

        If Not StopFlag Then
        Begin
          If (PosEx('About;', ScrStr)=1)or(PosEx('Version;', ScrStr)=1) Then
          Begin
            FDCLLogOn.About(nil);
          End;

          If PosEx('Lock;', ScrStr)=1 Then
          Begin
            FDCLLogOn.Lock;
          End;

          If PosEx('ExecCommand=', ScrStr)=1 Then
          Begin
            tmp1:=FindParam('ExecCommand=', ScrStr);
            LocalCommand:=TDCLCommand.Create(FDCLForm, FDCLLogOn);
            LocalCommand.ExecCommand(tmp1, FDCLForm);
            FreeAndNil(LocalCommand);
          End;

          If PosEx('SeparateChar=', ScrStr)=1 Then
          Begin
            GPT.StringTypeChar:=FindParam('SeparateChar=', ScrStr);
          End;

          If PosEx('SetValueSeparator=', ScrStr)=1 Then
          Begin
            GPT.GetValueSeparator:=FindParam('SetValueSeparator=', ScrStr);
          End;

          If PosEx('Export=', ScrStr)=1 Then
          Begin
            TmpStr:=FindParam('Spool=', ScrStr);
            If TmpStr='' Then
              TmpStr:='0';
            If TmpStr='1' Then
            Begin
              ExportData(stSpool, ScrStr);
              Spool.SaveToFile(SpoolFileName);
            End;
            If TmpStr='0' Then
              ExportData(stText, ScrStr);
          End;

          If PosEx('DialogByName=', ScrStr)=1 Then
          Begin
            TmpStr:=FindParam('DialogByName=', ScrStr);
            tmpStr1:=Copy(TmpStr, 1, Pos('.', TmpStr)-1);
            tmpStr2:=Copy(TmpStr, Pos('.', TmpStr)+1, length(TmpStr));
            Enything:=False;
            v2:=-1;
            For v1:=1 To FDCLLogOn.FormsCount Do
            Begin
              If CompareString(FDCLLogOn.Forms[v1-1].DialogName, tmpStr1) Then
              Begin
                Enything:=True;
                v2:=v1;
                Break;
              End;
            End;
            If Enything Then
            Begin
              If CompareString(tmpStr2, 'hide') Then
                FDCLLogOn.Forms[v2].FForm.Hide;
              If CompareString(tmpStr2, 'show') Then
                FDCLLogOn.Forms[v2].FForm.Show;
              If CompareString(tmpStr2, 'close') Then
                DCLMainLogOn.Forms[v2].Free;
              If CompareString(tmpStr2, 'refresh') Then
              Begin
                For v3:=1 to FDCLLogOn.Forms[v2].GridsCount do
                  FDCLLogOn.Forms[v2].Tables[v3-1].ReFreshQuery;
              End;
            End;
          End;

          If PosEx('Navigator=', ScrStr)=1 Then
          Begin
            If FindParam('Navigator=', ScrStr)='0' Then
            Begin
              If Assigned(FDCLForm.Tables[-1].Navig) Then
              Begin
                FDCLForm.Tables[-1].Navig.Hide;
              End;
            End
            Else
            Begin
              If FindParam('buttons=', ScrStr)<>'' Then
              Begin
                TmpStr:=FindParam('buttons=', ScrStr);
                For v1:=1 To 10 Do
                  NavigVisiButtonsVar[v1]:=[];
                If PosEx('first', TmpStr)<>0 Then
                  NavigVisiButtonsVar[1]:=[nbFirst];
                { If PosEx('prior', KeyField)<>0 Then
                  NavigVisiButtonsVar[2]:= [nbPrior];
                  If PosEx('next', KeyField)<>0 Then
                  NavigVisiButtonsVar[3]:= [nbNext]; }
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
                FDCLForm.Tables[-1].Navig.VisibleButtons:=NavigVisiButtonsVar[1]+NavigVisiButtonsVar
                  [2]+NavigVisiButtonsVar[3]+NavigVisiButtonsVar[4]+NavigVisiButtonsVar[5]+
                  NavigVisiButtonsVar[6]+NavigVisiButtonsVar[7]+NavigVisiButtonsVar[8]+
                  NavigVisiButtonsVar[9]+NavigVisiButtonsVar[10];
              End;
              If FindParam('Flat=', ScrStr)<>'' Then
              Begin
                TmpStr:=FindParam('Flat=', ScrStr);
                If TmpStr='1' Then
                  FDCLForm.Tables[-1].Navig.Flat:=true;
              End;
            End;
          End;

{$IFDEF DELPHI}
          If PosEx('ParamCheck=', ScrStr)=1 Then
          Begin
            TmpStr:=FindParam('ParamCheck=', ScrStr);
            If TmpStr='1' Then
              FDCLForm.Tables[-1].Query.ParamCheck:=true;
            If TmpStr='0' Then
              FDCLForm.Tables[-1].Query.ParamCheck:=False;
          End;
{$ENDIF}
          If PosEx('DisableParams=', ScrStr)=1 Then
          Begin
            If FindParam('DisableParams=', ScrStr)='1' Then
              TransParams:=true;

            If FindParam('DisableParams=', ScrStr)='0' Then
              TransParams:=False;
          End;

{$IFDEF DELPHI}
          If PosEx('FieldsList=', ScrStr)=1 Then
          Begin
            tmp1:=FindParam('FieldsList=', ScrStr);
            If not IsFullPAth(tmp1) then
              tmp1:=IncludeTrailingPathDelimiter(AppConfigDir)+tmp1;

            FDCLForm.Tables[-1].Query.FieldList.SaveToFile(tmp1);
          End;
{$ENDIF}
          If PosEx('SetContextFilterText=', ScrStr)=1 Then
          Begin
            TmpStr:=FindParam('ComponentName=', ScrStr);
            If TmpStr='' Then
            Begin
              TmpStr:=FindParam('ComponentNumber=', ScrStr);
              If TmpStr='' Then
                TmpStr:='ContextFilter_1'
              Else
                TmpStr:='ContextFilter_'+TmpStr;
            End;
            If Assigned(FDCLForm) then
              If Assigned(FDCLForm.Tables[-1].ToolPanel) Then
                If Assigned(FDCLForm.Tables[-1].ToolPanel.FindComponent(TmpStr)) Then
                Begin
                  tmpStr1:=FindParam('SetContextFilterText=', ScrStr);
                  RePlaseVariabless(tmpStr1);
                  (FDCLForm.Tables[-1].ToolPanel.FindComponent(TmpStr) As TEdit).Text:=tmpStr1;
                End;
          End;

          If PosEx('ClearAllContextFilters;', ScrStr)=1 Then
          Begin
            If Assigned(FDCLForm) then
              If length(FDCLForm.Tables[-1].DBFilters)>0 Then
                For v1:=1 to length(FDCLForm.Tables[-1].DBFilters) do
                Begin
                  if FDCLForm.Tables[-1].DBFilters[v1-1].FilterType=ftContextFilter then
                    If Assigned(FDCLForm.Tables[-1].DBFilters[v1-1].Edit) Then
                      FDCLForm.Tables[-1].DBFilters[v1-1].Edit.Clear;
                End;
          End;

          If PosEx('DownloadHTTP=', ScrStr)=1 Then
          Begin
            TmpStr:=FindParam('DownloadHTTP=', ScrStr);
            tmpStr1:=FindParam('Path=', ScrStr);
            tmpStr2:=FindParam('FileName=', ScrStr);

            If tmpStr1='' Then
            Begin
              If tmpStr2='' Then
                tmp1:=ExtractFileNameEx(TmpStr)
              Else
                tmp1:=tmpStr2;
            End
            Else
              TmpStr:=tmpStr1+ExtractFileNameEx(TmpStr);

            If FindParam('Progress=', ScrStr)='1' Then
              DownloadProgress:=true
            Else
              DownloadProgress:=False;

            If FindParam('Cancel=', ScrStr)='1' Then
              DownLoadCancel:=true
            Else
              DownLoadCancel:=False;

            tmpStr2:=Trim(FindParam('Reset=', ScrStr));
            If tmpStr2='1' Then
              DownLoadHTTP(TmpStr, tmp1, true, DownloadProgress, DownLoadCancel)
            Else
              DownLoadHTTP(TmpStr, tmp1, False, DownloadProgress, DownLoadCancel);

            Sleep(100);
          End;

          If PosEx('Execute=', ScrStr)=1 Then
          Begin
            If GetRaightsByContext(InContext)>ulReadOnly Then
            Begin
              TmpStr:=FindParam('execute=', ScrStr);

              tmpStr1:=FindParam('WorkDir=', ScrStr);
              If tmpStr1='' Then
                tmpStr1:=Path;

              If Not{$IFDEF FPC}DirectoryExistsUTF8(tmpStr1){$ELSE}DirectoryExists
                (tmpStr1){$ENDIF} Then
                SetCurrentDir(Path)
              Else
                SetCurrentDir(tmpStr1);

              Try
                If FindParam('Wait=', ScrStr)='1' Then
                Begin
                  If Not ExecAndWait(TmpStr, SW_SHOWNORMAL) Then
                    ShowErrorMessage(-8000, tmpStr1+TmpStr);
                End
                Else If FindParam('ShellExec=', ScrStr)='1' Then
                  Exec(TmpStr, tmpStr1)
                Else
                  ExecApp(TmpStr);
              Except
                ShowErrorMessage(-8000, tmpStr1+TmpStr);
              End;
            End
            Else
              ShowErrorMessage(0, SourceToInterface(GetDCLMessageString(msNotAllow)+' '+
                GetDCLMessageString(msExecuteApps)));
          End;

          If PosEx('Sleep=', ScrStr)=1 Then
          Begin
            TmpStr:=FindParam('Sleep=', ScrStr);
            Sleep(StrToIntEx(TmpStr));
          End;

          If PosEx('Beep;', ScrStr)=1 Then
          Begin
{$IFDEF MSWINDOWS}
            Windows.Beep(500, 250)
{$ELSE}
            Beep;
{$ENDIF};
          End;

          If PosEx('Beep=', ScrStr)=1 Then
          Begin
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
          End;

          If PosEx('ReOpen;', ScrStr)=1 Then
          Begin
            FDCLForm.RefreshForm;
          End;

          If PosEx('GotoKey=', ScrStr)=1 Then
          Begin
            TmpStr:=FindParam('KeyField=', ScrStr);
            tmpStr1:=FindParam('GotoKey=', ScrStr);
            If Assigned(FDCLForm.CurrentQuery) then
              FDCLForm.CurrentQuery.Locate(tmpStr1, TmpStr, [loCaseInsensitive]);
          End;

          If PosEx('Goto=', ScrStr)=1 Then
          Begin
            TmpStr:=FindParam('Goto=', ScrStr);
            SetRetPoint;
            GotoGoto(TmpStr);
          End;

          If PosEx('Return;', ScrStr)=1 Then
          Begin
            GetRetPoint;
          End;

          If PosEx('Break;', ScrStr)=1 Then
          Begin
            ScriptStrings:=FCommandDCL.Count;
          End;

          If PosEx('ExecQuery=', ScrStr)=1 Then
          Begin
            TmpStr:=FindParam('ExecQuery=', ScrStr);
            TranslateValContext(TmpStr);
            If not IsReturningQuery(TmpStr) Then
              ExecSQLCommand(TmpStr, InContext);
          End;

          If PosEx('Query=', ScrStr)=1 Then
          Begin
            FDCLLogOn.SetDBName(DCLQuery);
            TmpStr:=FindParam('Query=', ScrStr);
            TranslateValContext(TmpStr);
            If not IsReturningQuery(TmpStr) Then
            Begin
              DCLQuery.Close;
              DCLQuery.SQL.Text:=TmpStr;
              If GetRaightsByContext(InContext)>ulWrite Then
                DCLQuery.ExecSQL;
            End
            Else
              Try
                FDCLForm.CurrentQuery.SQL.Text:=TmpStr;
                FDCLForm.CurrentQuery.Open;
              Except
                ShowErrorMessage(-1100);
              End;
          End;

          If PosEx('GlobQuery=', ScrStr)=1 Then
          Begin
            If Assigned(FDCLForm) then
            Begin
              FDCLForm.CurrentQuery.DisableControls;

              BookMark:=FDCLForm.CurrentQuery.GetBookmark;
              TmpStr:=FindParam('GlobQuery=', ScrStr);
              TranslateValContext(TmpStr);
              FDCLForm.CurrentQuery.Close;
              FDCLForm.CurrentQuery.SQL.Clear;
              FDCLForm.CurrentQuery.SQL.Text:=TmpStr;
              Try
                FDCLForm.CurrentQuery.Open;
              Except
                ShowErrorMessage(-1113, 'SQL='+TmpStr);
              End;
              Try
                FDCLForm.CurrentQuery.GoToBookmark(BookMark);
              Finally
                FDCLForm.CurrentQuery.FreeBookmark(BookMark);
                FDCLForm.CurrentQuery.EnableControls;
              End;
            End;
          End;

          If PosEx('MultiSelect=', ScrStr)=1 Then
          Begin
            FDCLForm.Tables[-1].MultiSelect:=FindParam('MultiSelect=', ScrStr)='1';
          End;

          If PosEx('TablePartQuery=', ScrStr)=1 Then
          Begin
            TmpStr:=Trim(FindParam('TablePartNum=', ScrStr));
            If TmpStr<>'' Then
            Begin
              v1:=StrToIntEx(TmpStr)-1;
            End;

            TmpStr:=FindParam('TablePartQuery=', ScrStr);
            FDCLForm.TranslateVal(TmpStr);

            FDCLForm.Tables[-1].TableParts[v1].Query.SQL.Text:=TmpStr;
            Try
              FDCLForm.Tables[-1].TableParts[v1].Query.Open;
            Except
              ShowErrorMessage(-1201, 'SQL='+TmpStr);
            End;
          End;

          If PosEx('Report=', ScrStr)=1 Then
          Begin
            tmpDCL:=TStringList.Create;
            RepIdParams:=0;
            RepTable:=FindParam('FromTable=', ScrStr);
            If RepTable='' Then
              RepTable:=GPT.DCLTable;
            tmp1:=FindParam('FromFile=', ScrStr);
            If tmp1='' Then
            Begin
              tmp2:=FindParam('ReportName=', ScrStr);
              TranslateVals(tmp2, FDCLForm.CurrentQuery);
              DCLQuery.Close;
              DCLQuery.SQL.Text:='select Count(*) from '+RepTable+' where '+GPT.UpperString+
                GPT.DCLNameField+GPT.UpperStringEnd+'='+GPT.UpperString+GPT.StringTypeChar+tmp2+
                GPT.StringTypeChar+GPT.UpperStringEnd;
              DCLQuery.Open;
              RecCount:=DCLQuery.Fields[0].AsInteger;
              If RecCount=1 Then
              Begin
                DCLQuery.Close;
                DCLQuery.SQL.Text:='select * from '+RepTable+' where '+GPT.UpperString+
                  GPT.DCLNameField+GPT.UpperStringEnd+'='+GPT.UpperString+GPT.StringTypeChar+tmp2+
                  GPT.StringTypeChar+GPT.UpperStringEnd;
                DCLQuery.Open;
                tmpDCL.Text:=DCLQuery.FieldByName(GPT.DCLTextField).AsString;
                RepIdParams:=DCLQuery.FieldByName(GPT.IdentifyField).AsInteger;
                DCLQuery.Close;
              End;
            End
            Else
            Begin
              If not IsFullPAth(tmp1) then
                tmp1:=IncludeTrailingPathDelimiter(AppConfigDir)+tmp1;
              If FileExists(tmp1) Then
                tmpDCL.LoadFromFile(tmp1);
            End;
            tmp2:=FindParam('QueryMode=', ScrStr);
            v1:=0;
            If LowerCase(tmp2)='bkmode' Then
              v1:=1;
            If LowerCase(tmp2)='main' Then
              v1:=0;
            If LowerCase(tmp2)='isolate' Then
              v1:=2;
            Case v1 Of
            0:
            TextReport:=TDCLTextReport.InitReport(FDCLLogOn,
              FDCLForm.Tables[FDCLForm.CurrentTableIndex], tmpDCL, RepIdParams, nqmFromGrid);
            1:
            TextReport:=TDCLTextReport.InitReport(FDCLLogOn,
              FDCLForm.Tables[FDCLForm.CurrentTableIndex], tmpDCL, RepIdParams, nqmNew);
            2:
            TextReport:=TDCLTextReport.InitReport(FDCLLogOn, nil, tmpDCL, RepIdParams, nqmNew);
            End;
            // TextReport.OpenReport('Report.txt', 1);

            If TextReport.DialogRes=mrOk Then
            Begin
              tmp1:=Trim(FindParam('FileName=', ScrStr));
              TranslateVals(tmp1, FDCLForm.CurrentQuery);
              If FindParam('ToDos=', ScrStr)='1' Then
                TextReport.CodePage:=rcp866;

              v1:=StrToIntEx(Trim(FindParam('ViewMode=', ScrStr)));
              TextReport.OpenReport(tmp1, TReportViewMode(v1-1));
              tmp1:=TextReport.SaveReport(tmp1);

              tmp2:=FindParam('NoPrint=', ScrStr);
              TranslateVals(tmp2, FDCLForm.CurrentQuery);
              If TReportViewMode(v1-1)=rvmMultitRecordReport then
                tmp2:='1';
              If tmp2<>'1' Then
                If FindParam('Viewer=', ScrStr)<>'' Then
                  ExecApp('"'+FindParam('Viewer=', ScrStr)+'" "'+tmp1+'"')
                Else
                  ExecApp('"'+GPT.Viewer+'" "'+tmp1+'"');
            End;

            TextReport.CloseReport('Report.txt');
            FreeAndNil(tmpDCL);
          End;

          If PosEx('ReportExcel=', ScrStr)=1 Then
          Begin
            Enything:=FindParam('Save=', ScrStr)='1';
            OfficeReport:=TDCLOfficeReport.Create(FDCLLogOn,
              FDCLForm.Tables[FDCLForm.CurrentTableIndex]);
            OfficeReport.ReportExcel(ScrStr, Enything);
          End;

          If PosEx('ReportOOCalc=', ScrStr)=1 Then
          Begin
            OfficeReport:=TDCLOfficeReport.Create(FDCLLogOn,
              FDCLForm.Tables[FDCLForm.CurrentTableIndex]);
            Enything:=FindParam('Save=', ScrStr)='1';
            OfficeReport.ReportOpenOfficeCalc(ScrStr, Enything);
          End;

          If PosEx('ReportOfficeSheet=', ScrStr)=1 Then
          Begin
            Enything:=FindParam('Save=', ScrStr)='1';
            TmpStr:=LowerCase(FindParam('OfficeType=', ScrStr));
            OfficeReport:=TDCLOfficeReport.Create(FDCLLogOn,
              FDCLForm.Tables[FDCLForm.CurrentTableIndex]);
            Case GetPossibleOffice(dtSheet, ConvertOfficeType(TmpStr)) of
            odtOO:
            OfficeReport.ReportOpenOfficeCalc(ScrStr, Enything);
            odtMSO:
            OfficeReport.ReportExcel(ScrStr, Enything);
            odtNone:
            ShowErrorMessage(-6200, '');
            End;
          End;

          If PosEx('ReportWord=', ScrStr)=1 Then
          Begin
            Enything:=FindParam('Save=', ScrStr)='1';
            OfficeReport:=TDCLOfficeReport.Create(FDCLLogOn,
              FDCLForm.Tables[FDCLForm.CurrentTableIndex]);
            OfficeReport.ReportWord(ScrStr, Enything);
          End;

          If PosEx('ReportOOWriter=', ScrStr)=1 Then
          Begin
            Enything:=FindParam('Save=', ScrStr)='1';
            OfficeReport:=TDCLOfficeReport.Create(FDCLLogOn,
              FDCLForm.Tables[FDCLForm.CurrentTableIndex]);
            OfficeReport.ReportOpenOfficeWriter(ScrStr, Enything);
          End;

          If PosEx('ReportOfficeText=', ScrStr)=1 Then
          Begin
            Enything:=FindParam('Save=', ScrStr)='1';
            TmpStr:=LowerCase(FindParam('OfficeType=', ScrStr));
            OfficeReport:=TDCLOfficeReport.Create(FDCLLogOn,
              FDCLForm.Tables[FDCLForm.CurrentTableIndex]);
            Case GetPossibleOffice(dtSheet, ConvertOfficeType(TmpStr)) of
            odtOO:
            OfficeReport.ReportOpenOfficeWriter(ScrStr, Enything);
            odtMSO:
            OfficeReport.ReportWord(ScrStr, Enything);
            odtNone:
            ShowErrorMessage(-6200, '');
            End;
          End;

          If PosEx('WordReport=', ScrStr)=1 Then
          Begin
{$IFDEF MSWINDOWS}
            tmp1:=FindParam('ReportName=', ScrStr);
            tmp2:=FindParam('FileName=', ScrStr);
            tmp3:=FindParam('TemplateName=', ScrStr);
            WordReport:=TWordReport.Create(FDCLLogOn);
            WordReport.Print(tmp1, tmp3, tmp2);
            WordReport.Free;
{$ENDIF}
          End;

          If PosEx('OpenFileDialog=', ScrStr)=1 Then
          Begin
            tmp1:=FindParam('OpenFileDialog=', ScrStr);
            tmp2:=FindParam('Ext=', ScrStr);
            OpenDialog:=TOpenDialog.Create(Nil);
            If tmp2<>'' then
              OpenDialog.DefaultExt:=tmp2;
            If OpenDialog.Execute Then
              SetVariable(tmp1, UTF8ToSys(OpenDialog.FileName))
            Else
              SetVariable(tmp1, '');
            FreeAndNil(OpenDialog);
          End;

          If PosEx('SaveFileDialog=', ScrStr)=1 Then
          Begin
            tmp1:=FindParam('SaveFileDialog=', ScrStr);
            tmp2:=FindParam('Ext=', ScrStr);
            SaveDialog:=TSaveDialog.Create(Nil);
            SaveDialog.FileName:=FindParam('FileName=', ScrStr);
            If tmp2<>'' then
              SaveDialog.DefaultExt:=tmp2;
            If SaveDialog.Execute Then
              SetVariable(tmp1, UTF8ToSys(SaveDialog.FileName))
            Else
              SetVariable(tmp1, '');
            FreeAndNil(SaveDialog);
          End;

          If PosEx('OpenFolder=', ScrStr)=1 Then
          Begin
            tmp1:=FindParam('OpenFolder=', ScrStr);
            TranslateVals(tmp1, FDCLForm.CurrentQuery);
            OpenDir(tmp1);
          End;

          If PosEx('EditByName=', ScrStr)=1 Then
          Begin
            TmpStr:=FindParam('EditByName=', ScrStr);
            tmpStr1:=Copy(TmpStr, 1, Pos('.', TmpStr)-1);
            tmpStr2:=Copy(TmpStr, Pos('.', TmpStr)+1, length(TmpStr));
            If Assigned(FDCLForm) then
              If Assigned((FDCLForm.Tables[-1].FieldPanel.FindComponent(tmpStr1) As TEdit)) Then
              Begin
                If FDCLForm.FForm.Showing Then
                  If LowerCase(tmpStr2)='setfocus' Then
                    (FDCLForm.Tables[-1].FieldPanel.FindComponent(tmpStr1) As TEdit).SetFocus;
                If LowerCase(tmpStr2)='clear' Then
                  (FDCLForm.Tables[-1].FieldPanel.FindComponent(tmpStr1) As TEdit).Clear;
                If LowerCase(tmpStr2)='show' Then
                  (FDCLForm.Tables[-1].FieldPanel.FindComponent(tmpStr1) As TEdit).Show;
                If LowerCase(tmpStr2)='hide' Then
                  (FDCLForm.Tables[-1].FieldPanel.FindComponent(tmpStr1) As TEdit).Hide;
                If LowerCase(tmpStr2)='enabled' Then
                  (FDCLForm.Tables[-1].FieldPanel.FindComponent(tmpStr1) As TEdit).Enabled:=true;
                If LowerCase(tmpStr2)='disabled' Then
                  (FDCLForm.Tables[-1].FieldPanel.FindComponent(tmpStr1) As TEdit).Enabled:=False;
                If LowerCase(tmpStr2)='select' Then
                  (FDCLForm.Tables[-1].FieldPanel.FindComponent(tmpStr1) As TEdit).SelectAll;
                If LowerCase(tmpStr2)='settext' Then
                Begin
                  If PosEx('_Value=', ScrStr)<>0 Then
                  Begin
                    TmpStr:=FindParam('_Value=', ScrStr);
                    // RePlaseVariables(tmpStr);
                    (FDCLForm.Tables[-1].FieldPanel.FindComponent(tmpStr1) As TEdit).Text:=TmpStr;
                  End;
                End;
              End;
          End;

          If (PosEx('If ', ScrStr)=1)And(PosEx(' then', ScrStr)<>0) Then
          Begin
            inc(IfCounter);

            If Breaking=False Then
            Begin
              IfSign:=0;
              TmpStr:=ScrStr;
              tmp1:='';
              tmp2:='';
              tmp3:='';

              If (FindParam('Expression1=', TmpStr)='')and(FindParam('Expression2=', TmpStr)='')and
                (FindParam('Sign=', TmpStr)='') then
              Begin
                If PosEx('If ', TmpStr)<>0 then
                  Delete(TmpStr, PosEx('If ', TmpStr), 3);
                If PosEx(' then', TmpStr)<>0 then
                  Delete(TmpStr, PosEx(' then', TmpStr), 5);

                TranslateValContext(TmpStr);

                v2:=PosInSet('<>=', TmpStr);
                If v2<>0 then
                Begin
                  v3:=v2+1;
                  If TmpStr[v3] in ['>', '<', '='] then
                    inc(v3);
                  tmp3:=Copy(TmpStr, v2, v3-v2);

                  tmp1:=Copy(TmpStr, 1, v2-1);
                  tmp2:=Copy(TmpStr, v3, length(TmpStr));
                  tmp1:=Trim(AnsiLowerCase(tmp1));
                  tmp2:=Trim(AnsiLowerCase(tmp2));
                End;
              End
              Else
              Begin
                tmp1:=FindParam('Expression1=', TmpStr);
                If tmp1<>'' Then
                  tmp1:=ExpressionParser(tmp1);
                tmp2:=FindParam('Expression2=', TmpStr);
                If tmp2<>'' Then
                  tmp2:=ExpressionParser(tmp2);
                tmp3:=FindParam('Sign=', TmpStr);
              End;
              If tmp3<>'' Then
              Begin
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
              End;
              StopFlag:=true;
              Case IfSign Of
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
              End;
            End;
          End;

          If PosEx('Else', ScrStr)=1 Then
          Begin
            If Breaking=False Then
              StopFlag:=Not StopFlag;
          End;

          If PosEx('EndIf', ScrStr)=1 Then
          Begin
            Dec(IfCounter);
            If Breaking=False Then
              StopFlag:=False;
          End;

          If PosEx('Message=', ScrStr)=1 Then
          Begin
            TmpStr:=FindParam('message=', ScrStr);
            TranslateValContext(TmpStr);
            tmpStr3:=FindParam('Flags=', ScrStr);
            If tmpStr3<>'' Then
            Begin
              tmpStr2:=FindParam('VariableName=', ScrStr);
              FDCLLogOn.Variables.NewVariable(tmpStr2);

              If LowerCase(tmpStr3)='yesno' Then
              Begin
                If ShowErrorMessage(10, TmpStr)=1 Then
                  FDCLLogOn.Variables.Variables[tmpStr2]:='1'
                Else
                  FDCLLogOn.Variables.Variables[tmpStr2]:='0';
              End
              Else If LowerCase(tmpStr3)='input' Then
              Begin
                TranslateValContext(tmpStr2);
                tmpStr3:=FindParam('DefaultValue=', ScrStr);
                TranslateValContext(tmpStr3);
                FDCLLogOn.Variables.Variables[tmpStr2]:=InputBox(TmpStr, '', tmpStr3);
              End;
            End
            Else
              ShowErrorMessage(9, TmpStr);
          End;

          If PosEx('SetValue=', ScrStr)=1 Then
          Begin
            SetValue(ScrStr);
          End;

          If PosEx('SetFieldValue=', ScrStr)=1 Then
          Begin
            If GetRaightsByContext(InContext)>ulReadOnly then
            Begin
              TmpStr:=FindParam('SetFieldValue=', ScrStr);
              For v1:=1 To ParamsCount(TmpStr) Do
              Begin
                tmpStr2:=SortParams(TmpStr, v1);
                v2:=Pos('=', tmpStr2);
                If v2<>0 Then
                Begin
                  tmp1:=Trim(Copy(tmpStr2, 1, v2-1));
                  tmp2:=Copy(tmpStr2, v2+1, Length(tmpStr2)-v2);
                  TranslateValContext(tmp2);
                  tmpStr3:=Trim(FindParam('TablePartNum=', ScrStr));
                  If GetRaightsByContext(InContext)>ulReadOnly Then
                    If tmpStr3<>'' Then
                    Begin
                      v3:=StrToIntEx(tmpStr3)-1;
                      If Assigned(FDCLForm.Tables[-1]) then
                        If Assigned(FDCLForm.Tables[-1].TableParts[v3]) then
                        Begin
                          If not(FDCLForm.Tables[-1].TableParts[v3].Query.State
                            in [dsEdit, dsInsert]) Then
                            FDCLForm.Tables[-1].TableParts[v3].Query.Edit;
                          FDCLForm.Tables[-1].TableParts[v3].Query.FieldByName(tmp1).AsString:=tmp2;
                        End;
                    End
                    Else
                    Begin
                      If not(FDCLForm.CurrentQuery.State in [dsInsert, dsEdit]) then
                        FDCLForm.CurrentQuery.Edit;
                      FDCLForm.CurrentQuery.FieldByName(tmp1).AsString:=tmp2;
                    End;
                End;

                If FindParam('Post=', ScrStr)='1' Then
                Begin
                  If GetRaightsByContext(InContext)>ulReadOnly Then
                    If Trim(FindParam('TablePartNum=', ScrStr))<>'' Then
                    Begin
                      If FDCLForm.Tables[-1].TableParts[v1].Query.State in [dsEdit, dsInsert] Then
                        FDCLForm.Tables[-1].TableParts[v1].Query.Post;
                    End
                    Else
                    Begin
                      If FDCLForm.CurrentQuery.State in [dsEdit, dsInsert] Then
                        FDCLForm.CurrentQuery.Post;
                    End;
                End;

                If FindParam('Commit=', ScrStr)='1' Then
                Begin
                  If GetRaightsByContext(InContext)>ulWrite Then
                    If FDCLForm.CurrentQuery.State in [dsEdit, dsInsert] Then
                      FDCLForm.CurrentQuery.Post;
{$IFDEF ADO}
                  FDCLForm.CurrentQuery.Connection.CommitTrans;
{$ENDIF}
                End;
              End;
            End;
          End;

          If PosEx('GetFieldValue=', ScrStr)=1 Then
          Begin
            TmpStr:=FindParam('GetFieldValue=', ScrStr);
            For v1:=1 To ParamsCount(TmpStr) Do
            Begin
              tmpStr2:=SortParams(TmpStr, v1);
              v2:=Pos('=', tmpStr2);
              If v2<>0 Then
              Begin
                tmp1:=Trim(Copy(tmpStr2, 1, v2-1));
                tmp2:=Copy(tmpStr2, v2+1, Length(tmpStr2)-v2);
                v3:=Pos('.', tmp2);
                If v3<>0 Then
                Begin
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
                End
                Else
                Begin
                  TmpStr:=Trim(FindParam('TablePartNum=', ScrStr));
                  If TmpStr<>'' Then
                  Begin
                    v3:=StrToIntEx(TmpStr)-1;
                    If Assigned(FDCLForm.Tables[-1].TableParts[v3]) then
                      FDCLLogOn.Variables.Variables[tmp1]:=FDCLForm.Tables[-1].TableParts[v3]
                        .Query.FieldByName(tmp1).AsString;
                  End
                  Else
                  Begin
                    FDCLLogOn.Variables.Variables[tmp1]:=
                      TrimRight(FDCLForm.CurrentQuery.FieldByName(tmp2).AsString);
                  End;
                End;
              End;
            End;
          End;

          If PosEx('CurrentTablePart=', ScrStr)=1 Then
          Begin
            tmpStr2:=Trim(FindParam('CurrentTablePart=', ScrStr));
            TranslateValContext(tmpStr2);
            If tmpStr2<>'' Then
            Begin
              v1:=StrToIntEx(tmpStr2)-1;
              If Assigned(FDCLForm.Tables[-1].TableParts[v1]) then
                FDCLForm.SetTabIndex(v1);
            End;
          End;

          If PosEx('Insert_part;', ScrStr)=1 Then
          Begin
            If GetRaightsByContext(InContext)>ulReadOnly then
              If Assigned(FDCLForm.Tables[-1].TableParts[FDCLForm.CurrentTabIndex]) then
                FDCLForm.Tables[-1].TableParts[FDCLForm.CurrentTabIndex].Query.Insert;
          End;

          If PosEx('Append_part;', ScrStr)=1 Then
          Begin
            If GetRaightsByContext(InContext)>ulReadOnly then
              If Assigned(FDCLForm.Tables[-1].TableParts[FDCLForm.CurrentTabIndex]) then
                FDCLForm.Tables[-1].TableParts[FDCLForm.CurrentTabIndex].Query.Append;
          End;

          If PosEx('Post_part;', ScrStr)=1 Then
          Begin
            If GetRaightsByContext(InContext)>ulReadOnly then
              If Assigned(FDCLForm.Tables[-1].TableParts[FDCLForm.CurrentTabIndex]) then
                FDCLForm.Tables[-1].TableParts[FDCLForm.CurrentTabIndex].Query.Post;
          End;

          If PosEx('Delete_part;', ScrStr)=1 Then
          Begin
            If GetRaightsByContext(InContext)>ulReadOnly then
              If Assigned(FDCLForm.Tables[-1].TableParts[FDCLForm.CurrentTabIndex]) then
                FDCLForm.Tables[-1].TableParts[FDCLForm.CurrentTabIndex].Query.Delete;
          End;

          If PosEx('DeleteConf_part;', ScrStr)=1 Then
          Begin
            If GetRaightsByContext(InContext)>ulReadOnly then
              If Assigned(FDCLForm.Tables[-1].TableParts[FDCLForm.CurrentTabIndex]) then
                If ShowErrorMessage(10, SourceToInterface(GetDCLMessageString(msDeleteRecord)+
                  '?'))=1 Then
                  FDCLForm.Tables[-1].TableParts[FDCLForm.CurrentTabIndex].Query.Delete;
          End;

          If PosEx('Edit_part;', ScrStr)=1 Then
          Begin
            If GetRaightsByContext(InContext)>ulReadOnly then
              If Assigned(FDCLForm.Tables[-1].TableParts[FDCLForm.CurrentTabIndex]) then
                FDCLForm.Tables[-1].TableParts[FDCLForm.CurrentTabIndex].Query.Edit;
          End;

          If PosEx('Edit;', ScrStr)=1 Then
          Begin
            If GetRaightsByContext(InContext)>ulReadOnly then
              FDCLForm.CurrentQuery.Edit;
          End;

          If PosEx('Post;', ScrStr)=1 Then
          Begin
            If GetRaightsByContext(InContext)>ulReadOnly then
              If FDCLForm.CurrentQuery.State in [dsEdit, dsInsert] Then
                FDCLForm.CurrentQuery.Post;
          End;

          If PosEx('PostClose;', ScrStr)=1 Then
          Begin
            If FDCLForm.CurrentQuery.State in [dsEdit, dsInsert] Then
              FDCLForm.CurrentQuery.Post;
            FreeAndNil(FDCLForm);
          End;

          If PosEx('CancelClose;', ScrStr)=1 Then
          Begin
            If FDCLForm.CurrentQuery.State in [dsEdit, dsInsert] Then
              FDCLForm.CurrentQuery.Cancel;
            if Assigned(FDCLForm) then
              FreeAndNil(FDCLForm);
          End;

          If PosEx('PostRefresh;', ScrStr)=1 Then
          Begin
            FDCLForm.CurrentQuery.Post;
            FDCLForm.Tables[-1].ReFreshQuery;
          End;

          If PosEx('Cancel;', ScrStr)=1 Then
          Begin
            If FDCLForm.CurrentQuery.State in [dsEdit, dsInsert] Then
              FDCLForm.CurrentQuery.Cancel;
          End;

          If PosEx('Delete;', ScrStr)=1 Then
          Begin
            If GetRaightsByContext(InContext)>ulReadOnly then
              FDCLForm.CurrentQuery.Delete;
          End;

          If PosEx('DeleteConf;', ScrStr)=1 Then
          Begin
            If GetRaightsByContext(InContext)>ulReadOnly Then
              If ShowErrorMessage(10, SourceToInterface(GetDCLMessageString(msDeleteRecord)+
                '?'))=1 Then
                FDCLForm.CurrentQuery.Delete;
          End;

          If PosEx('Insert;', ScrStr)=1 Then
          Begin
            FDCLForm.CurrentQuery.Insert;
          End;

          If PosEx('Append;', ScrStr)=1 Then
          Begin
            FDCLForm.CurrentQuery.Append;
          End;

          If PosEx('Refresh;', ScrStr)=1 Then
          Begin
            FDCLForm.Tables[-1].ReFreshQuery;
          End;

          If PosEx('EvalFormula=', ScrStr)=1 Then
          Begin
            tmp1:=FindParam('EvalFormula=', ScrStr);
            TranslateVals(tmp1, FDCLForm.CurrentQuery);

            FDCLLogOn.EvalFormula:=Calculate(tmp1);
          End;

          If PosEx('Dialog=', ScrStr)=1 Then
          Begin
            TmpStr:=FindParam('Dialog=', ScrStr);
            ModalOpen:=FindParam('ModalOpen=', TmpStr)='1';
            ChooseMode:=chmNone;
            If FindParam('ChooseMode=', ScrStr)<>'' then
            Begin
              v1:=StrToIntEx(FindParam('ChooseMode=', ScrStr));
              ChooseMode:=TChooseMode(v1);
              ReturnValueParams:=TReturnValueParams.Create(FindParam('KeyField=', ScrStr),
                FindParam('DataField=', ScrStr), FindParam('EditName=', ScrStr), FindParam('ModifyField=', ScrStr));
            End;

            Pushf(FDCLForm);
            If FindParam('Child=', ScrStr)='1' then
              FDCLForm:=FDCLLogOn.CreateForm(TmpStr, FDCLForm, FDCLForm.CurrentQuery, nil,
                ModalOpen, ChooseMode, ReturnValueParams)
            Else
            Begin
              tmpStr2:=Trim(FindParam('TablePart=', ScrStr));
              If tmpStr2<>'' Then
              Begin
                v1:=StrToIntEx(tmpStr2)-1;
                If Assigned(FDCLForm.Tables[-1].TableParts[v1]) then
                  FDCLForm:=FDCLLogOn.CreateForm(TmpStr, nil,
                    FDCLForm.Tables[-1].TableParts[v1].Query, nil, ModalOpen, ChooseMode, ReturnValueParams);
              End
              Else
                FDCLForm:=FDCLLogOn.CreateForm(TmpStr, nil, nil, nil, ModalOpen, ChooseMode, ReturnValueParams);
            End;

            If FDCLForm.ReturnFormValue.Choosen then
            Begin
              RetVal:=FDCLForm.ReturnFormValue;
              If ChooseMode=chmChooseAndClose then
                FDCLLogOn.CloseForm(FDCLForm);
              FDCLForm:=Popf;
              If FieldExists(RetVal.ModifyField, FDCLForm.CurrentQuery) then
              Begin
                If not (FDCLForm.CurrentQuery.State in [dsEdit, dsInsert]) then
                  FDCLForm.CurrentQuery.Edit;
                If RetVal.EditName='' then
                  FDCLForm.CurrentQuery.FieldByName(RetVal.ModifyField).AsString:=RetVal.Val
                Else
                  FDCLForm.CurrentQuery.FieldByName(RetVal.ModifyField).AsString:=RetVal.Key;
              End;

              If RetVal.EditName<>'' then
              If Assigned(FDCLForm.Tables[FDCLForm.CurrentGridIndex]) then
                If Length(FDCLForm.Tables[FDCLForm.CurrentGridIndex].Edits)>0 then
                Begin
                  v1:=Length(FDCLForm.Tables[FDCLForm.CurrentGridIndex].Edits);
                  For v2:=1 to v1 do
                  Begin
                    If CompareString(RetVal.EditName, FDCLForm.Tables[FDCLForm.CurrentGridIndex].Edits[v2-1].Edit.Name) then
                    Begin
                      FDCLForm.Tables[FDCLForm.CurrentGridIndex].Edits[v2-1].Edit.Text:=RetVal.Val;

                      break;
                    End;
                  End;
                End;
              //EditName
            End;

            FreeAndNil(ReturnValueParams);
            // FDCLForm:=CurrentForm;
          End;

          If PosEx('CloseDialog;', ScrStr)=1 Then
          Begin
            if Assigned(FDCLForm) then
              FDCLLogOn.CloseForm(FDCLForm);
            FDCLForm:=Popf;
          End;

          If PosEx('Hold;', ScrStr)=1 Then
          Begin
{$IFNDEF DCLDEBUG}
            FDCLForm.Form.FormStyle:=fsStayOnTop;
{$ENDIF}
          End;

          If PosEx('HoldDown;', ScrStr)=1 Then
          Begin
            If Not FDCLForm.Modal Then
              FDCLForm.Form.FormStyle:=fsNormal;
          End;

          If PosEx('Declare=', ScrStr)=1 Then
          Begin
            TmpStr:=Trim(FindParam('declare=', ScrStr));
            For v1:=1 To ParamsCount(TmpStr) Do
            Begin
              tmpStr1:=SortParams(TmpStr, v1);
              v2:=PosEx('=', tmpStr1);
              If v2=0 Then
                FDCLLogOn.Variables.NewVariable(tmpStr1, '')
              Else
              Begin
                tmpStr2:=Trim(Copy(tmpStr1, 1, v2-1));
                tmpStr3:=Copy(tmpStr1, v2+1, Length(tmpStr1)-v2);
                TranslateValContext(tmpStr3);

                FDCLLogOn.Variables.NewVariable(tmpStr2, tmpStr3);
              End;
            End;
          End;

          If PosEx('Dispose=', ScrStr)=1 Then
          Begin
            tmpStr2:=FindParam('dispose=', ScrStr);
            For v1:=1 To ParamsCount(tmpStr2) Do
              FDCLLogOn.Variables.FreeVariable(SortParams(tmpStr2, v1));
          End;

          If PosEx('Exit;', ScrStr)=1 Then
          Begin
            Application.MainForm.Close;
          End;

          If PosEx('Debug;', ScrStr)=1 Then
          Begin
            GPT.DebugOn:=Not GPT.DebugOn;
          End;

          If PosEx('SetMainFormCaption=', ScrStr)=1 Then
          Begin
            TmpStr:=FindParam('SetMainFormCaption=', ScrStr);
            TranslateValContext(TmpStr);
            Application.MainForm.Caption:=TmpStr;
          End;

          If PosEx('SetFormCaption=', ScrStr)=1 Then
          Begin
            TmpStr:=FindParam('SetFormCaption=', ScrStr);
            TranslateValContext(TmpStr);
            FDCLForm.FForm.Caption:=TmpStr;
          End;

          If PosEx('ApplicationTitle=', ScrStr)=1 Then
          Begin
            TmpStr:=FindParam('ApplicationTitle=', ScrStr);
            TranslateValContext(TmpStr);
            Application.Title:=TmpStr;
          End;

          If PosEx('Status=', ScrStr)=1 Then
          Begin
            TmpStr:=FindParam('Status=', ScrStr);
            TranslateValContext(TmpStr);
            If Assigned(FDCLForm) Then
              FDCLForm.SetDBStatus(TmpStr);
          End;

          If PosEx('AddStatus=', ScrStr)=1 Then
          Begin
            TmpStr:=FindParam('AddStatus=', ScrStr);
            v1:=-1;
            If FindParam('Width=', ScrStr)<>'' Then
              v1:=StrToIntEx(FindParam('Width=', ScrStr));

            FDCLForm.AddStatus(TmpStr, v1);
          End;

          If PosEx('SetStatusText=', ScrStr)=1 Then
          Begin
            TmpStr:=FindParam('Status=', ScrStr);
            If TmpStr<>'' Then
            Begin
              If LowerCase(TmpStr)='last' Then
                v1:=0
              Else
                v1:=StrToIntEx(Trim(FindParam('Status=', ScrStr)))
            End
            Else
              v1:=0;

            TmpStr:=FindParam('SetStatusText=', ScrStr);
            TranslateValContext(TmpStr);
            v2:=-1;
            If FindParam('Width=', ScrStr)<>'' Then
              v2:=StrToIntEx(Trim(FindParam('Width=', ScrStr)));
            FDCLForm.SetStatus(TmpStr, v1-1, v2);
          End;

          If PosEx('DeleteStatus=', ScrStr)=1 Then
          Begin
            TmpStr:=FindParam('DeleteStatus=', ScrStr);
            If TmpStr<>'' Then
            Begin
              If LowerCase(TmpStr)='last' Then
                v1:=0
              Else
                v1:=StrToIntEx(Trim(FindParam('DeleteStatus=', ScrStr)));
            End
            Else
              v1:=0;

            FDCLForm.DeleteStatus(v1);
          End;

          If PosEx('DeleteAllStatus;', ScrStr)=1 Then
          Begin
            FDCLForm.DeleteAllStatus;
          End;

          If PosEx('WriteConfig=', ScrStr)=1 Then
          Begin
            tmp1:=FindParam('WriteConfig=', ScrStr);
            tmp3:=FindParam('UserID=', ScrStr);
            tmp2:=Copy(ScrStr, PosEx('_Value=', ScrStr), length(ScrStr));
            Delete(tmp2, 1, 7);

            FDCLLogOn.WriteConfig(tmp1, tmp2, tmp3);
          End;

          If PosEx('FormHeight=', ScrStr)=1 Then
          Begin
            v1:=StrToIntEx(FindParam('FormHeight=', ScrStr));
            If Assigned(FDCLForm) then
              FDCLForm.FForm.ClientHeight:=v1;
          End;

          If PosEx('FormWidth=', ScrStr)=1 Then
          Begin
            v1:=StrToIntEx(FindParam('FormWidth=', ScrStr));
            If Assigned(FDCLForm) then
              FDCLForm.FForm.ClientWidth:=v1;
          End;

          If (PosEx('PutInDB=', ScrStr)=1) or (PosEx('PutToDB=', ScrStr)=1) Then
          Begin
            If GetRaightsByContext(InContext)>ulReadOnly Then
            Begin
              TmpStr:=FindParam('FileName=', ScrStr);
              tmpStr2:=FindParam('Compress=', ScrStr);

              If not IsFullPAth(TmpStr) then
                TmpStr:=IncludeTrailingPathDelimiter(AppConfigDir)+TmpStr;
              If {$IFDEF FPC}FileExistsUTF8(TmpStr){$ELSE}FileExists(TmpStr){$ENDIF} Then
              Begin
                If not Assigned(BinStore) then
                  BinStore:=TBinStore.Create(FDCLLogOn, ftSQL, '', '', '',
                    FindParam('DataField=', ScrStr));
                BinStore.StoreFromFile(TmpStr, FindParam('SQL=', ScrStr), '', tmpStr2='1');
              End
              Else
                ShowErrorMessage(-8001, TmpStr);
            End;
          End;

          If PosEx('GetFromDB=', ScrStr)=1 Then
          Begin
            If GetRaightsByContext(InContext)>ulReadOnly Then
            Begin
              TmpStr:=FindParam('FileName=', ScrStr);
              If not IsFullPAth(TmpStr) then
                TmpStr:=IncludeTrailingPathDelimiter(AppConfigDir)+TmpStr;

              If not Assigned(BinStore) then
                BinStore:=TBinStore.Create(FDCLLogOn, ftSQL, '', '', '',
                  FindParam('DataField=', ScrStr));

              BinStore.SaveToFile(TmpStr, FindParam('SQL=', ScrStr));
            End;
          End;

          If PosEx('ClearBLOB=', ScrStr)=1 Then
          Begin
            If GetRaightsByContext(InContext)>ulReadOnly Then
            Begin
              tmpStr1:=FindParam('ClearBLOB=', ScrStr);

              If not Assigned(BinStore) then
                BinStore:=TBinStore.Create(FDCLLogOn, ftSQL, '', '', '',
                  FindParam('DataField=', ScrStr));

              BinStore.ClearData(FindParam('SQL=', ScrStr));
            End;
          End;

          If PosEx('DeleteBLOB=', ScrStr)=1 Then
          Begin
            If GetRaightsByContext(InContext)>ulReadOnly Then
            Begin
              tmpStr1:=FindParam('DeleteBLOB=', ScrStr);

              If not Assigned(BinStore) then
                BinStore:=TBinStore.Create(FDCLLogOn, ftSQL, '', '', '',
                  FindParam('DataField=', ScrStr));

              BinStore.DeleteData(FindParam('SQL=', ScrStr));
            End;
          End;

          If PosEx('DecompressData=', ScrStr)=1 Then
          Begin
            If not Assigned(BinStore) then
              BinStore:=TBinStore.Create(FDCLLogOn, ftSQL, '', '', '',
                FindParam('DataField=', ScrStr));

            BinStore.DeCompressData(FindParam('SQL=', ScrStr), '');
          End;

          If PosEx('CompressData=', ScrStr)=1 Then
          Begin
            If not Assigned(BinStore) then
              BinStore:=TBinStore.Create(FDCLLogOn, ftSQL, '', '', '',
                FindParam('DataField=', ScrStr));

            BinStore.CompressData(FindParam('SQL=', ScrStr), '');
          End;

          If PosEx('MD5Data=', ScrStr)=1 Then
          Begin
            tmpStr1:=FindParam('MD5Data=', ScrStr);

            If not Assigned(BinStore) then
              BinStore:=TBinStore.Create(FDCLLogOn, ftSQL, '', '', '',
                FindParam('DataField=', ScrStr));
            If not FDCLLogOn.Variables.Exists(tmpStr1) then
              FDCLLogOn.Variables.NewVariable(tmpStr1);
            FDCLLogOn.Variables.Variables[tmpStr1]:=BinStore.MD5(FindParam('SQL=', ScrStr));
          End;

          If PosEx('SQLmon_Clear;', ScrStr)=1 Then
          Begin
            FDCLLogOn.SQLMon.Clear;
          End;

          If PosEx('SQLMon;', ScrStr)=1 Then
          Begin
            FDCLLogOn.SQLMon.TrraceStatus:=not FDCLLogOn.SQLMon.TrraceStatus;
          End;

          If PosEx('OpenSpool=', ScrStr)=1 Then
          Begin
            SpoolFileName:=FindParam('OpenSpool=', ScrStr);
            If not IsFullPAth(SpoolFileName) then
              SpoolFileName:=IncludeTrailingPathDelimiter(AppConfigDir)+SpoolFileName;

            If Not Assigned(Spool) Then
              Spool:=TStringList.Create;
          End;

          If PosEx('Spool=', ScrStr)=1 Then
          Begin
            If Not Assigned(Spool) Then
              Spool:=TStringList.Create;
            If SpoolFileName='' Then
              SpoolFileName:='spool.txt';

            If not IsFullPAth(SpoolFileName) then
              SpoolFileName:=IncludeTrailingPathDelimiter(AppConfigDir)+SpoolFileName;

            TmpStr:=Copy(ScrStr, 7, Length(ScrStr)-6);
            Spool.Append(TmpStr);
            Spool.SaveToFile(SpoolFileName);
          End;

          If PosEx('Evalute=', ScrStr)=1 Then
          Begin
            tmp1:=FindParam('Evalute=', ScrStr);

            tmp2:=FindParam('ResultVar=', ScrStr);
            If Not FDCLLogOn.Variables.Exists(tmp2) Then
              tmp2:='';
            If tmp2='' Then
              EvalResultScript:=RunScript(tmp1)
            Else
            Begin
              SetVariable(tmp2, RunScript(tmp1));
            End;
          End;

          If PosEx('AddFunctions=', ScrStr)=1 Then
          Begin
            tmpDCL:=TStringList.Create;

            TmpStr:=FindParam('AddFunctions=', ScrStr);
            DCLQuery.Close;
            DCLQuery.SQL.Text:='select Count(*) from '+GPT.DCLTable+' where '+GPT.UpperString+
              GPT.DCLNameField+GPT.UpperStringEnd+'='+GPT.UpperString+GPT.StringTypeChar+TmpStr+
              GPT.StringTypeChar+GPT.UpperStringEnd;
            DCLQuery.Open;
            RecCount:=DCLQuery.Fields[0].AsInteger;
            If RecCount=1 Then
            Begin
              DCLQuery.Close;
              DCLQuery.SQL.Text:='select '+GPT.DCLTextField+' from '+GPT.DCLTable+' where '+
                GPT.UpperString+GPT.DCLNameField+GPT.UpperStringEnd+'='+GPT.UpperString+
                GPT.StringTypeChar+TmpStr+GPT.StringTypeChar+GPT.UpperStringEnd;
              DCLQuery.Open;
              TmpStr:=DCLQuery.FieldByName(GPT.DCLTextField).AsString;
              TranslateVals(TmpStr, FDCLForm.Tables[-1].FQuery);
              tmpDCL.Text:=TmpStr;
              AddCodeScript(tmpDCL);
            End;
            FreeAndNil(tmpDCL);
          End;

          If PosEx('ExecVBS=', ScrStr)=1 Then
          Begin
            tmpDCL:=TStringList.Create;

            TmpStr:=FindParam('ExecVBS=', ScrStr);
            DCLQuery.Close;
            DCLQuery.SQL.Text:='select Count(*) from '+GPT.DCLTable+' where '+GPT.UpperString+
              GPT.DCLNameField+GPT.UpperStringEnd+'='+GPT.UpperString+GPT.StringTypeChar+TmpStr+
              GPT.StringTypeChar+GPT.UpperStringEnd;
            DCLQuery.Open;
            RecCount:=DCLQuery.Fields[0].AsInteger;
            If RecCount=1 Then
            Begin
              DCLQuery.Close;
              DCLQuery.SQL.Text:='select '+GPT.DCLTextField+' from '+GPT.DCLTable+' where '+
                GPT.UpperString+GPT.DCLNameField+GPT.UpperStringEnd+'='+GPT.UpperString+
                GPT.StringTypeChar+TmpStr+GPT.StringTypeChar+GPT.UpperStringEnd;
              DCLQuery.Open;
              TmpStr:=DCLQuery.FieldByName(GPT.DCLTextField).AsString;
              TranslateVals(TmpStr, FDCLForm.Tables[-1].FQuery);
              ExecVBS(TmpStr);
            End;
            FreeAndNil(tmpDCL);
          End;

          If PosEx('ReadOnly=', ScrStr)=1 Then
          Begin
            FDCLForm.Tables[-1].ReadOnly:=Trim(FindParam('ReadOnly=', ScrStr))='1';
          End;

          // If LowerCase(ScrStr)='bkprint' Then PrintBase.Print(Nil, FormData[CurrentForm].QueryGlob);

          If LowerCase(ScrStr)='print' Then
            FDCLForm.Tables[FDCLForm.CurrentGridIndex].Print(nil);

        End
        Else
        Begin
          If PosEx('Else', ScrStr)=1 Then
          Begin
            If Breaking=False Then
              StopFlag:=Not StopFlag;
          End;

          If PosEx('EndIf', ScrStr)=1 Then
          Begin
            Dec(IfCounter);
            If Breaking=False Then
              StopFlag:=False;
          End;
        End;

        inc(ScriptStrings);
      End;
    End;
  End;

  FDCLLogOn.NotifyForms(fnaResumeAutoRefresh);
end;

procedure TDCLCommand.ExecSQLCommand(SQLCommand: String; InContext: Boolean);
Var
  ADOCommand: TCommandQuery;
Begin
{$IFDEF ADO}
  If GetRaightsByContext(InContext)>ulWrite Then
  Begin
    ADOCommand:=TCommandQuery.Create(Nil);
    ADOCommand.CommandType:=cmdText;
    TranslateValContext(SQLCommand);
    If GPT.DebugOn Then
    Begin
      DebugProc('ExecSQLCommand('+SQLCommand+')');
      DebugProc(SQLCommand);
      If GPT.DebugMesseges Then
        ShowMessage(SQLCommand);
    End;
    If FDCLLogOn.SQLMon.TrraceStatus then
      FDCLLogOn.SQLMon.AddSQLText(SQLCommand);

    ADOCommand.CommandText:=SQLCommand;
    ADOCommand.Connection:=FDCLLogOn.FDBLogOn;
    Try
      ADOCommand.Execute;
    Except
      ShowErrorMessage(-1110, 'SQL='+SQLCommand);
    End;
    FreeAndNil(ADOCommand);

    FDCLLogOn.NotifyForms(fnaRefresh);
  End;
{$ENDIF}
{$IFDEF BDE}
  If GetRaightsByContext(InContext)>ulWrite Then
  Begin
    ADOCommand:=TDCLDialogQuery.Create(Nil);
    ADOCommand.Name:='ExecSQL_'+IntToStr(UpTime);
    TranslateValContext(SQLCommand);
    If GPT.DebugOn Then
    Begin
      DebugProc('ExecSQLCommand('+SQLCommand+')');
      DebugProc(SQLCommand);
      If GPT.DebugMesseges Then
        ShowMessage(SQLCommand);
    End;
    If FDCLLogOn.SQLMon.TrraceStatus then
      FDCLLogOn.SQLMon.AddSQLText(SQLCommand);

    ADOCommand.SQL.Text:=SQLCommand;
    SetDBName(ADOCommand);
    Try
      ADOCommand.ExecSQL;
    Except
      ShowErrorMessage(-1110, 'SQL='+SQLCommand);
    End;
    FreeAndNil(ADOCommand);

    FDCLLogOn.NotifyForms(fnaRefresh);
  End;
{$ENDIF}
{$IFDEF IB}
  If GetRaightsByContext(InContext)>ulWrite Then
  Begin
    ADOCommand:=TCommandQuery.Create(Nil);
    ADOCommand.Name:='ExecSQL_'+IntToStr(UpTime);
    TranslateValContext(SQLCommand);
    If GPT.DebugOn Then
    Begin
      DebugProc('ExecSQLCommand('+SQLCommand+')');
      DebugProc(SQLCommand);
      If GPT.DebugMesseges Then
        ShowMessage(SQLCommand);
    End;
    If FDCLLogOn.SQLMon.TrraceStatus then
      FDCLLogOn.SQLMon.AddSQLText(SQLCommand);

    ADOCommand.SQL.Text:=SQLCommand;
    FDCLLogOn.SetDBName(ADOCommand);
    Try
      ADOCommand.ExecSQL;
    Except
      ShowErrorMessage(-1110, 'SQL='+SQLCommand);
    End;
    FreeAndNil(ADOCommand);

    FDCLLogOn.NotifyForms(fnaRefresh);
  End;
{$ENDIF}
{$IFDEF ZEOS}
  If GetRaightsByContext(InContext)>ulWrite Then
  Begin
    ADOCommand:=TCommandQuery.Create(Nil);
    ADOCommand.Name:='ExecSQL_'+IntToStr(UpTime);
    TranslateValContext(SQLCommand);
    If GPT.DebugOn Then
    Begin
      DebugProc('ExecSQLCommand('+SQLCommand+')');
      DebugProc(SQLCommand);
      If GPT.DebugMesseges Then
        ShowMessage(SQLCommand);
    End;
    If FDCLLogOn.SQLMon.TrraceStatus then
      FDCLLogOn.SQLMon.AddSQLText(SQLCommand);

    ADOCommand.SQL.Text:=SQLCommand;
    ADOCommand.Connection:=FDCLLogOn.FDBLogOn;
    Try
      ADOCommand.ExecSQL;
    Except
      ShowErrorMessage(-1110, 'SQL='+SQLCommand);
    End;
    FreeAndNil(ADOCommand);

    FDCLLogOn.NotifyForms(fnaRefresh);
  End;
{$ENDIF}
{$IFDEF SQLdbIB}
  If GetRaightsByContext(InContext)>ulWrite Then
  Begin
    ADOCommand:=TCommandQuery.Create(Nil);
    ADOCommand.Name:='ExecSQL_'+IntToStr(UpTime);
    TranslateValContext(SQLCommand);
    If GPT.DebugOn Then
    Begin
      DebugProc('ExecSQLCommand('+SQLCommand+')');
      DebugProc(SQLCommand);
      If GPT.DebugMesseges Then
        ShowMessage(SQLCommand);
    End;
    If FDCLLogOn.SQLMon.TrraceStatus then
      FDCLLogOn.SQLMon.AddSQLText(SQLCommand);

    ADOCommand.SQL.Text:=SQLCommand;
    ADOCommand.Database:=FDCLLogOn.FDBLogOn;
    ADOCommand.Transaction:=FDCLLogOn.FDBLogOn.Transaction;
    Try
      ADOCommand.ExecSQL;
    Except
      ShowErrorMessage(-1110, 'SQL='+SQLCommand);
    End;
    FreeAndNil(ADOCommand);

    FDCLLogOn.NotifyForms(fnaRefresh);
  End;
{$ENDIF}
End;

procedure TDCLCommand.ExportData(Tagert: TSpoolType; Scr: String);
Var
  S1, S, Mode, FileName, tmp1, ExportTable, TableFields, BlobStr: String;
  T: TextFile;
  BlobPos: Cardinal;
  v1, v2: Word;
  MS: TMemoryStream;
  ExportingTable: TDCLDialogQuery;
  OpenDialog: TOpenDialog;

  Procedure WriteSpool(Var TT: Text; Spool: TStringList; S: String);
  Begin
    If Tagert=stText Then
      WriteLn(TT, S)
    Else
      Spool.Append(S);
  End;

Begin
  If Not Assigned(Spool) Then
    Spool:=TStringList.Create;

  ExportingTable:=TDCLDialogQuery.Create(Nil);
  FDCLLogOn.SetDBName(ExportingTable);
  If FindParam('query=', Scr)<>'' Then
  Begin
    tmp1:=FindParam('query=', Scr);
    ExportingTable.SQL.Text:=tmp1;
  End
  Else
    ExportingTable.SQL.Text:=FDCLForm.Tables[-1].Query.SQL.Text;

  Try
    ExportingTable.Open;
  Except
    ShowErrorMessage(-1119, 'SQL='+ExportingTable.SQL.Text);
  End;

  If FindParam('filename=', Scr)='' Then
  Begin
    OpenDialog:=TOpenDialog.Create(Nil);
    If OpenDialog.Execute Then
      FileName:=OpenDialog.FileName
    Else
      FileName:='Table1';
    FreeAndNil(OpenDialog);
  End
  Else
    FileName:=FindParam('filename=', Scr);
  If not IsFullPAth(FileName) then
    FileName:=IncludeTrailingPathDelimiter(AppConfigDir)+FileName;

  tmp1:='';
  tmp1:=LowerCase(FindParam('target=', Scr));
  If tmp1='' Then
    tmp1:='dbf';
  Mode:=LowerCase(LowerCase(FindParam('mode=', Scr)));
  If Mode='' Then
    Mode:='new';

  If LowerCase(tmp1)='oth' Then
  Begin
    If PosEx('.OTH', FileName)=0 Then
      FileName:=FileName+'.OTH';
    If Tagert=stText Then
      AssignFile(T, FileName);

    If Mode='append' Then
    Begin
      If Tagert=stText Then
        Append(T);
    End
    Else If Tagert=stText Then
      ReWrite(T);

    S:='[TABLE]';
    WriteSpool(T, Spool, S);
    S:=FindParam('table=', Scr);
    WriteSpool(T, Spool, S);
    S:='[FIELDS]';
    WriteSpool(T, Spool, S);
    For v1:=0 To ExportingTable.FieldCount-1 Do
    Begin
      S:=UpperCase(ExportingTable.Fields[v1].FieldName);
      WriteSpool(T, Spool, S);
    End;
    S:='[DATA]';
    WriteSpool(T, Spool, S);
    While Not ExportingTable.Eof Do
    Begin
      S:='';
      For v1:=0 To ExportingTable.FieldCount-1 Do
      Begin
        If (ExportingTable.Fields[v1].DataType<>ftMemo)Or
          (ExportingTable.Fields[v1].DataType<>ftGraphic)Or
          (ExportingTable.Fields[v1].DataType<>ftBlob) Then
        Begin
          S1:=TrimRight(ExportingTable.Fields[v1].AsString);
          Case ExportingTable.Fields[v1].DataType Of
          ftString:
          Begin
            S:=S+GPT.StringTypeChar+S1+GPT.StringTypeChar+', ';
          End;
          ftDate, ftTime, ftDateTime, ftBCD, ftFloat, ftCurrency:
          Begin
            If S1='' Then
              S:=S+S1+'null, '
            Else
              S:=S+GPT.StringTypeChar+S1+GPT.StringTypeChar+', ';
          End
        Else
        Begin
          If S1='' Then
            S:=S+S1+'null, '
          Else
            S:=S+S1+', ';
        End;
          End;
        End;
        If v1=ExportingTable.FieldCount-1 Then
          Delete(S, Length(S)-1, 2);
      End;
      WriteSpool(T, Spool, S);
      ExportingTable.Next;
    End;
    S:='[ENDDATA]';
    WriteSpool(T, Spool, S);
    S:='END.';
    WriteSpool(T, Spool, S);

    If Tagert=stText Then
      CloseFile(T);
  End;

  If LowerCase(tmp1)='sql' Then
  Begin
    If PosEx('.sql', FileName)=0 Then
      FileName:=FileName+'.sql';

    If Tagert=stText Then
      AssignFile(T, FileName);

    If Mode='append' Then
    Begin
      If Tagert=stText Then
        Append(T);
    End
    Else If Tagert=stText Then
      ReWrite(T);

    If FindParam('table=', Scr)='' Then
    Begin
      tmp1:=ExportingTable.SQL.Text;
      v2:=PosEx(' from ', tmp1)+5;
      tmp1:=Copy(ExportingTable.SQL.Text, v2, length(ExportingTable.SQL.Text));
      tmp1:=TrimLeft(tmp1);
      tmp1:=Copy(tmp1, PosEx(' ', tmp1), length(tmp1));
    End
    Else
      tmp1:=FindParam('table=', Scr);
    DeleteNonPrintSimb(tmp1);
    ExportTable:=tmp1;

    TableFields:='';
    BlobStr:='';
    For v1:=0 To ExportingTable.FieldCount-1 Do
    Begin
      TableFields:=TableFields+ExportingTable.Fields[v1].FieldName;
      If v1<>ExportingTable.FieldCount-1 Then
        TableFields:=TableFields+', ';
      If ExportingTable.Fields[v1].DataType In [ftMemo, ftBlob, ftGraphic] Then
      Begin
        If BlobStr='' Then
          BlobStr:='SET BLOBFILE '''+FileName+'.lob'';';
      End;
    End;
    WriteSpool(T, Spool, BlobStr);

    MS:=TMemoryStream.Create;
    MS.Clear;
    MS.Seek(0, 0);
    BlobPos:=0;

    While Not ExportingTable.Eof Do
    Begin
      S:='insert into '+ExportTable+'('+TableFields+') values(';
      For v1:=0 To ExportingTable.FieldCount-1 Do
      Begin
        If ExportingTable.Fields[v1].DataType<>ftGraphic Then
        Begin
          S1:=TrimRight(ExportingTable.Fields[v1].AsString);
          Case ExportingTable.Fields[v1].DataType Of
          ftString:
          Begin
            S:=S+GPT.StringTypeChar+S1+GPT.StringTypeChar+', ';
          End;
          ftDate, ftTime, ftDateTime, ftBCD, ftFloat, ftCurrency:
          Begin
            If S1='' Then
              S:=S+S1+'null, '
            Else
              S:=S+GPT.StringTypeChar+S1+GPT.StringTypeChar+', ';
          End;
          ftSmallint, ftInteger, ftWord, ftBoolean, ftAutoInc:
          Begin
            If S1='' Then
              S:=S+S1+'null, '
            Else
              S:=S+S1+', ';
          End;
          ftMemo, ftBlob, ftGraphic:
          Begin
            If ExportingTable.Fields[v1].AsString<>'' Then
            Begin
              (ExportingTable.Fields[v1] As TBlobField).SaveToStream(MS);
              S1:=':h'+IntToHex(BlobPos, 8)+'_'+IntToHex(ExportingTable.Fields[v1].Size, 8);
              inc(BlobPos, ExportingTable.Fields[v1].Size);
            End
            Else
              S1:='NULL';
            S:=S+S1;
          End;
          End;
        End;
        If v1<>ExportingTable.FieldCount-1 Then
          S:=S+', ';
      End;
      S:=S+');';
      WriteSpool(T, Spool, S);
      ExportingTable.Next;
    End;

    If MS.Size>0 Then
      MS.SaveToFile(FileName+'.lob');

    If Tagert=stText Then
      CloseFile(T);
  End;

  If SpoolFileName='' Then
    SpoolFileName:='spool.txt';

  If not IsFullPAth(SpoolFileName) then
    SpoolFileName:=IncludeTrailingPathDelimiter(AppConfigDir)+SpoolFileName;

  If Spool.Count>0 Then
    Spool.SaveToFile(SpoolFileName);
End;

function TDCLCommand.ExpressionParser(Expression: String): String;
Var
  ExpressionTmp, ExpressionTmp1: String;
  DCLQuery: TDCLDialogQuery;
Begin
  Result:='';
  ExpressionTmp:=FindParam('SQL=', Expression);
  If ExpressionTmp<>'' Then
  Begin
    TranslateValContext(ExpressionTmp);

    DCLQuery:=TDCLDialogQuery.Create(nil);
    DCLQuery.Name:='Expression_'+IntToStr(UpTime);
    FDCLLogOn.SetDBName(DCLQuery);
    DCLQuery.SQL.Text:=ExpressionTmp;
    Try
      DCLQuery.Open;
    Except
      ShowErrorMessage(-1102, 'SQL='+ExpressionTmp);
    End;
    ExpressionTmp1:=FindParam('ReturnField=', Expression);
    // DeleteNonPrintSimb(ExpressionTmp1);
    TranslateValContext(ExpressionTmp1);
    If ExpressionTmp1='' Then
      If DCLQuery.Active Then
        ExpressionTmp1:=DCLQuery.Fields[0].FieldName;
    If DCLQuery.Active Then
      Result:=TrimRight(DCLQuery.FieldByName(ExpressionTmp1).AsString);
    If DCLQuery.Active Then
      DCLQuery.Close;
    FreeAndNil(DCLQuery);
  End
  Else
  Begin
    TranslateValContext(Expression);
    Result:=Expression;
  End;
End;

function TDCLCommand.GetRaightsByContext(InContext: Boolean): TUserLevelsType;
Begin
  If InContext then
    Result:=FDCLForm.UserLevelLocal
  Else
    Result:=FDCLLogOn.AccessLevel;
End;

procedure TDCLCommand.OpenForm(FormName: String; ModalMode: Boolean);
begin
  FDCLForm:=FDCLLogOn.CreateForm(FormName, nil, nil, nil, ModalMode, chmNone);
end;

procedure TDCLCommand.RePlaseParamss(var ParamsSet: string; Query: TDCLDialogQuery);
begin
  RePlaseParams_(ParamsSet, Query);
end;

procedure TDCLCommand.RePlaseVariabless(Var Variables: String);
begin
  If Assigned(FDCLForm) then
    FDCLForm.RePlaseVariables(Variables);
  FDCLLogOn.RePlaseVariables(Variables);
end;

{ TDCLLogOn }

procedure TDCLLogOn.About(Sender:TObject);
Const
  FormWidth=520;
  FormHeight=430;
  PanelLeft=8;
Var
  AboutForm: TForm;
  DCLImage: TImage;
  AboutPanel: TPanel;
  AboutLabel: TLabel;
  OkButton: TButton;
  DBStringMemo: TMemo;
  DBString: String;
Begin
  AboutForm:=TForm.Create(Nil);
  With AboutForm Do
  Begin
    BorderStyle:=bsDialog;
    Caption:='?...';
    ClientHeight:=FormHeight;
    ClientWidth:=FormWidth;
    Position:=poScreenCenter;
  End;

  AboutPanel:=TPanel.Create(AboutForm);
  AboutPanel.Parent:=AboutForm;
  With AboutPanel Do
  Begin
    Left:=PanelLeft;
    Top:=8;
    Width:=FormWidth-PanelLeft*2;
    Height:=FormHeight-PanelLeft*2;
    BevelInner:=bvRaised;
    BevelOuter:=bvLowered;
    ParentColor:=true;
    TabOrder:=0;
  End;

  DCLImage:=TImage.Create(AboutPanel);
  DCLImage.Parent:=AboutPanel;
  DCLImage.Top:=10;
  DCLImage.Left:=8;
  DCLImage.Height:=64;
  DCLImage.Width:=64;
  DCLImage.Stretch:=true;

  DCLImage.Picture.Bitmap:=DrawBMPButton('Logo');

  DCLImage.Transparent:=true;

  AboutLabel:=TLabel.Create(AboutPanel);
  AboutLabel.Parent:=AboutPanel;
  With AboutLabel Do
  Begin
    Left:=80;
    Top:=8;
    Width:=150;
    Height:=13;
    Caption:=SourceToInterface(GetDCLMessageString(msTheProduct)+' : DCL Run ('+DBEngineType+')');
  End;

  AboutLabel:=TLabel.Create(AboutPanel);
  AboutLabel.Parent:=AboutPanel;
  With AboutLabel Do
  Begin
    Left:=80;
    Top:=45;
    Width:=44;
    Height:=13;
    Caption:=SourceToInterface(GetDCLMessageString(msProducer)+':');
  End;

  AboutLabel:=TLabel.Create(AboutPanel);
  AboutLabel.Parent:=AboutPanel;
  With AboutLabel Do
  Begin
    Left:=80;
    Top:=60;
    Width:=135;
    Height:=15;
    Caption:='Unreal Software (C) 2002-'+IntToStr(YearOf(Now));
    Font.Color:=clWindowText;
    Font.Height:=-12;
    // Font.Name:='Times New Roman';
    Font.Style:=[fsBold, fsItalic];
    ParentFont:=False;
  End;

  AboutLabel:=TLabel.Create(AboutPanel);
  AboutLabel.Parent:=AboutPanel;
  With AboutLabel Do
  Begin
    Left:=80;
    Top:=25;
    Width:=62;
    Height:=13;
    Caption:=SourceToInterface(GetDCLMessageString(msVersion)+' DCL : '+Version
{$IFDEF IB}+'. IBX v.'+FloatToStr(IBX_Version){$ENDIF}
{$IFDEF ZEOS}+'. ZEOS v.'+FDBLogOn.Version{$ENDIF}
{$IFDEF ADO}+'. ADO.db v.'+FDBLogOn.Version{$ENDIF}
{$IFDEF SQLdbIB}+'. SQLdb v.'+AboutForm.LCLVersion{$ENDIF})+
      SourceToInterface('. '+GetDCLMessageString(msStatus)+' : '+ReliseStatues[ReleaseStatus]+'.');
    // SQLDA_CURRENT_VERSION
  End;

  AboutLabel:=TLabel.Create(AboutPanel);
  AboutLabel.Parent:=AboutPanel;
  With AboutLabel Do
  Begin
    Left:=80;
    Top:=80;
    Width:=62;
    Height:=13;
    Caption:=SourceToInterface(GetDCLMessageString(msUser)+'/ '+GetDCLMessageString(msRole)+' : ')+GPT.DCLLongUserName+' ('+IntToStr(Ord(FAccessLevel))
      +') / '+GPT.LongRoleName+' ('+IntToStr(RoleRaightsLevel)+')';
  End;

{$IFDEF IB}
  DBString:=GPT.ServerName+':'+GPT.DBPath;
{$ENDIF}
{$IFDEF BDE}
  DBString:=GPT.Driver_Name+' '+GPT.Alias+' '+GPT.ServerName+' '+GPT.DBPath;
{$ENDIF}
{$IFDEF ADO}
  DBString:=GPT.ConnectionString;
{$ENDIF}
{$IFDEF ZEOS}
  DBString:='('+GPT.DBType+') '+GPT.ServerName+':'+GPT.DBPath;
{$ENDIF}
{$IFDEF SQLdbIB}
  DBString:=GPT.ServerName+':'+GPT.DBPath;
{$ENDIF}

  DBStringMemo:=TMemo.Create(AboutPanel);
  DBStringMemo.Parent:=AboutPanel;
  With DBStringMemo Do
  Begin
    ReadOnly:=true;
    Color:=AboutPanel.Color;
    BorderStyle:=bsNone;
    Left:=8;
    Top:=105;
    Width:=FormWidth-30;
    Height:=95;
    Text:=SourceToInterface(GetDCLMessageString(msDataBase)+' : ')+DBString;
    Font.Color:=clWindowText;
    Font.Height:=-12;
    // Font.Style:=[fsBold, fsItalic];
    ParentFont:=False;
  End;

  DBStringMemo:=TMemo.Create(AboutPanel);
  DBStringMemo.Parent:=AboutPanel;
  With DBStringMemo Do
  Begin
    ReadOnly:=true;
    Color:=AboutPanel.Color;
    BorderStyle:=bsNone;
    Left:=8;
    Top:=105+105;
    Width:=FormWidth-30;
    Height:=105;
    Text:=SourceToInterface(GetDCLMessageString(msConfiguration)+' : ')+GetConfigInfo+
      SourceToInterface(' /'+GetDCLMessageString(msVersion)+' : ')+GetConfigVersion;
    Font.Color:=clWindowText;
    Font.Height:=-12;
    // Font.Style:=[fsBold, fsItalic];
    ParentFont:=False;
  End;

  AboutLabel:=TLabel.Create(AboutPanel);
  AboutLabel.Parent:=AboutPanel;
  With AboutLabel Do
  Begin
    Left:=8;
    Top:=320;
    Width:=62;
    Caption:=SourceToInterface(GetDCLMessageString(msInformationAbout)+' '+GetDCLMessageString(msBuildOf)+
      ' : '+GetDCLMessageString(msOS))+':'+TargetOS+'. CPU: '+TargetCPU+'.'{$IFDEF FPC}+
      ' fpc: '+fpcVersion+'. LCL version'+AboutForm.LCLVersion+'.'
{$IFDEF UNIX}+' '+SourceToInterface(GetDCLMessageString(msLang))+':'+SysUtils.GetEnvironmentVariable('LANG')+'.'{$ENDIF}
{$ENDIF};
  End;

  If GPT.DebugOn then
  Begin
    AboutLabel:=TLabel.Create(AboutPanel);
    AboutLabel.Parent:=AboutPanel;
    With AboutLabel Do
    Begin
      Left:=8;
      Top:=345;
      Width:=62;
      Caption:=SourceToInterface(GetDCLMessageString(msDebugMode))+' : '+AnsiToUTF8(GetOnOffMode(GPT.DebugOn));
    End;
  End;

  OkButton:=TButton.Create(AboutForm);
  OkButton.Parent:=AboutForm;
  With OkButton Do
  Begin
    Left:=(FormWidth Div 2)-(75 Div 2);
    Top:=FormHeight-PanelLeft*2-30;
    Width:=75;
    Height:=25;
    Caption:='OK';
    Default:=true;
    Cancel:=true;
    ModalResult:=1;
    TabOrder:=0;
  End;
{$IFNDEF VER150}
  // If GetMainFormNum<>-1 then AboutForm.PopupParent := FormData[GetMainFormNum].DBForm;
{$ENDIF}
  AboutForm.ShowModal;
  FreeAndNil(AboutForm);
End;

function TDCLLogOn.CheckPass(UserName, EnterPass, Password: String): Boolean;
begin
  If GPT.HashPass Then
    Result:=(Password=HashString(EnterPass))And(UserName<>'')and(Password<>'')
  Else
    Result:=(Password=EnterPass)And(UserName<>'')and(Password<>'');

  If Result then
    RoleOK:=lsLogonOK;
end;

function TDCLLogOn.CloseForm(Form: TDCLForm):TReturnFormValue;
var
  v1: Integer;
begin
  For v1:=1 to length(FForms) do
    If Form=FForms[v1-1] then
    Begin
      Result:=FForms[v1-1].FRetunValue;
      FreeAndNil(FForms[v1-1]);
      break;
    End;
end;

procedure TDCLLogOn.CloseFormNum(FormNum: Integer);
begin
  If length(FForms)>FormNum then
    FreeAndNil(FForms[FormNum]);
end;

destructor TDCLLogOn.Destroy;
begin
  Disconnect;
end;

function TDCLLogOn.ConnectDB: Integer;
begin
{$IFDEF ADO}
  If length(GPT.ConnectionString)>20 Then
  Begin
    GPT.NewConnectionString:='';
    FDBLogOn.ConnectionString:=GPT.ConnectionString;
    FDBLogOn.LoginPrompt:=False;

    Try
      If Params.Count>0 Then
        FDBLogOn.Open;
      Result:=0;
      ConnectErrorCode:=0;
    Except
      On E: Exception do
      Begin
        DebugProc('  ... Fail');
        ConnectErrorCode:=255;
        ShowErrorMessage(0, SourceToInterface(GetDCLMessageString(msConnectDBError)+' 0000 / '+E.Message));
        Result:=255;
      End;
    End;
  End
  Else
  Begin
    ConnectErrorCode:=255;
    Result:=255;
    ShowErrorMessage(0, SourceToInterface(GetDCLMessageString(msConnectionStringIncorrect)+
      ' 0100'));
  End;
{$ENDIF}
{$IFDEF BDE}
  If not IsFullPAth(GPT.DBPath) Then
    GPT.DBPath:=ExtractFilePath(Application.ExeName)+GPT.DBPath;

  If IsUNCPath(GPT.DBPath) then
  Begin
    DebugProc('  DBPath: '+GPT.DBPath);
    DebugProc('UNC paths not supported.');
    ShowErrorMessage(0, SourceToInterface('UNC '+GetDCLMessageString(msPaths)+' '+
        GetDCLMessageString(msNotSupportedS)+'.'));
    Result:=255;
    Exit;
  End;

  If GPT.Driver_Name='' then
    FDBLogOn.DriverName:='STANDARD';

  FDBLogOn.DatabaseName:='DCL_LogOn_$_Main';
  If GPT.Alias<>'' then
    FDBLogOn.AliasName:=GPT.Alias;
  DebugProc('  Connection Alias: '+GPT.Alias);
  GPT.NewDBUserName:='';

  If GPT.DBPath<>'' Then
  Begin
    DebugProc('  DBPath: '+GPT.DBPath);
    FDBLogOn.Params.Append('PATH='+GPT.DBPath);
    If GPT.DEFAULT_DRIVER<>'' Then
    Begin
      FDBLogOn.Params.Append('DEFAULT DRIVER='+GPT.DEFAULT_DRIVER);
      DebugProc('  DEFAULT DRIVER='+GPT.DEFAULT_DRIVER);
    End;
    Session.AddPassword(GPT.DBPassword);
    DebugProc('  Session.AddPassword(*********)');
    FDBLogOn.LoginPrompt:=False;
  End
  Else
  Begin
    If GPT.DBUserName<>'' then
    Begin
      FDBLogOn.Params.Append('USER NAME='+GPT.DBUserName);
      DebugProc('  USER NAME='+GPT.DBUserName);
    End;
    If GPT.DBPassword<>'' then
      FDBLogOn.Params.Append('PASSWORD='+GPT.DBPassword);

    If GPT.ServerName<>'' Then
    Begin
      FDBLogOn.Params.Append('SERVER NAME='+GPT.ServerName);
      DebugProc('  SERVER NAME='+GPT.ServerName);
      FDBLogOn.LoginPrompt:=true;
    End
    Else
      FDBLogOn.LoginPrompt:=False;

    If GPT.DBPassword<>'' Then
      FDBLogOn.LoginPrompt:=False
    Else If GPT.Alias<>'' then
      FDBLogOn.LoginPrompt:=true;
  End;
  If GPT.Driver_Name<>'' Then
  Begin
    FDBLogOn.DriverName:=GPT.Driver_Name;
    DebugProc('  Connection.DriverName='+GPT.Driver_Name);
  End;
  FDBLogOn.KeepConnection:=true;
  Try
    DebugProc('Connected...');
    FDBLogOn.Open;
    DebugProc('  ... OK');
    Result:=0;
    ConnectErrorCode:=0;
  Except
    On E: Exception do
    Begin
      DebugProc('  ... Fail');
      ConnectErrorCode:=255;
      ShowErrorMessage(0, SourceToInterface(GetDCLMessageString(msConnectDBError)+' 0000 / '+E.Message));
      Result:=255;
    End;
  End;
{$ENDIF}
{$IFDEF IB}
  GPT.NewDBUserName:='';
  If not Assigned(FDBLogOn.DefaultTransaction) then
  Begin
    IBTransaction:=TTransaction.Create(Nil);
    IBTransaction.Params.Clear;
    IBTransaction.DefaultAction:=TACommit;
    IBTransaction.AllowAutoStart:=true;
    IBTransaction.DefaultDataBase:=FDBLogOn;
    FDBLogOn.DefaultTransaction:=IBTransaction;
  End
  Else
    IBTransaction:=FDBLogOn.DefaultTransaction;

  If not FDBLogOn.Connected then
  Begin
    If GPT.DBPath<>'' Then
    Begin
      FDBLogOn.Params.Clear;
      If not IsFullPAth(GPT.DBPath) Then
        GPT.DBPath:=ExtractFilePath(Application.ExeName)+GPT.DBPath;

      If IsUNCPath(GPT.DBPath) then
      Begin
        DebugProc('  DBPath: '+GPT.DBPath);
        DebugProc('UNC paths not supported.');
        ShowErrorMessage(0, SourceToInterface('UNC '+GetDCLMessageString(msPaths)+' '+
        GetDCLMessageString(msNotSupportedS)+'.'));
        Result:=255;
        Exit;
      End;

      If GPT.ServerName<>'' Then
      Begin
        FDBLogOn.DatabaseName:=GPT.ServerName+':'+GPT.DBPath;
        DebugProc('  DBPath: '+GPT.ServerName+':'+GPT.DBPath);
      End
      Else
      Begin
        FDBLogOn.DatabaseName:=GPT.DBPath;
        DebugProc('  DBPath: '+GPT.DBPath);
      End;
      FDBLogOn.Params.Append('USER_NAME='+GPT.DBUserName);
      DebugProc('  USER NAME='+GPT.DBUserName);
      If GPT.DBPassword<>'' Then
      Begin
        FDBLogOn.Params.Append('PASSWORD='+GPT.DBPassword);
        FDBLogOn.LoginPrompt:=False;
      End
      Else
        FDBLogOn.LoginPrompt:=true;

      If GPT.ServerCodePage='' Then
        FDBLogOn.Params.Append('lc_ctype=WIN1251')
      Else
        FDBLogOn.Params.Append('lc_ctype='+GPT.ServerCodePage);

      FDBLogOn.SQLDialect:=GPT.SQLDialect;
      Try
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
        Begin
          DebugProc('  ... Fail');
          ConnectErrorCode:=255;
          ShowErrorMessage(0, SourceToInterface(GetDCLMessageString(msConnectDBError)+' 0000 / '+E.Message));
          Result:=255;
        End;
      End;
    End;
  End
  Else
  Begin
    Result:=0;
  End;
{$ENDIF}
{$IFDEF ZEOS}
  GPT.NewDBUserName:='';

  If GPT.DBPath<>'' Then
  Begin
    If not IsFullPAth(GPT.DBPath) Then
      GPT.DBPath:=ExtractFilePath(Application.ExeName)+GPT.DBPath;

    If IsUNCPath(GPT.DBPath) then
    Begin
      DebugProc('  DBPath: '+GPT.DBPath);
      DebugProc('UNC paths not supported.');
      ShowErrorMessage(0, SourceToInterface('UNC '+GetDCLMessageString(msPaths)+' '+
        GetDCLMessageString(msNotSupportedS)+'.'));
      Result:=255;
      Exit;
    End;

    GPT.NewDBUserName:='';
    FDBLogOn.AutoEncodeStrings:=True;
    FDBLogOn.TransactIsolationLevel:=tiReadCommitted;
    FDBLogOn.AutoCommit:=true;
    FDBLogOn.SQLHourGlass:=true;

    FDBLogOn.Database:=GPT.DBPath;
    If GPT.ServerName<>'' Then
    Begin
      If Pos('/', GPT.ServerName)<>0 Then
      Begin
        GPT.Port:=StrToIntEx(Copy(GPT.ServerName, Pos('/', GPT.ServerName)+1,
          length(GPT.ServerName)));
        Delete(GPT.ServerName, Pos('/', GPT.ServerName), length(GPT.ServerName));
      End;
      FDBLogOn.HostName:=GPT.ServerName;
      If GPT.Port=0 then
        GPT.Port:=DefaultIBPort;
      DebugProc('  DBPath: '+GPT.ServerName+':'+GPT.DBPath);
    End
    Else
    Begin
      DebugProc('  DBPath: '+GPT.DBPath);
    End;

    FDBLogOn.User:=GPT.DBUserName;
    DebugProc('  USER NAME='+GPT.DBUserName);

    If GPT.Port<>0 Then
      FDBLogOn.Port:=GPT.Port;

    If GPT.DBPassword<>'' Then
    Begin
      DebugProc('  Password=******');
      FDBLogOn.Password:=GPT.DBPassword;
      FDBLogOn.LoginPrompt:=False;
    End
    Else
      FDBLogOn.LoginPrompt:=true;

    FDBLogOn.Protocol:=GPT.DBType;
    If GPT.LibPath<>'' then
      FDBLogOn.LibraryLocation:=GPT.LibPath
    Else
      FDBLogOn.LibraryLocation:=DefaultLibraryLocation;

{$IFDEF FPC}
    GPT.ServerCodePage:=NormalizeEncoding(GPT.ServerCodePage);
{$ENDIF}
    If GPT.ServerCodePage='' Then
    Begin
      FDBLogOn.Properties.Append('lc_ctype=cp1251');
      GPT.ServerCodePage:='cp1251';
    End
    Else
      FDBLogOn.Properties.Append('lc_ctype='+GPT.ServerCodePage);

    Try
      DebugProc('Connected...');
      FDBLogOn.Connect;
      DebugProc('  ... OK');
      Result:=0;
      ConnectErrorCode:=0;
    Except
      On E: Exception do
      Begin
        DebugProc('  ... Fail');
        ConnectErrorCode:=255;
        ShowErrorMessage(0, SourceToInterface(GetDCLMessageString(msConnectDBError)+' 0000 / '+E.Message));
        Result:=255;
      End;
    End;
  End;
{$ENDIF}
{$IFDEF SQLdbIB}
    DebugProc('Creating Connection...');
    FDBLogOn.Charset:='UTF8';

    If GPT.DBPath<>'' Then
    Begin
      If Pos(':\', GPT.DBPath)=0 Then
        GPT.DBPath:=ExtractFilePath(Application.ExeName)+GPT.DBPath;

      IBTransaction:=TTransaction.Create(Nil);
      // IBTransaction.DefaultAction:=TACommitRetaining;

      FDBLogOn.Transaction:=IBTransaction;
      If GPT.ServerName<>'' Then
      Begin
        FDBLogOn.DatabaseName:=GPT.ServerName+':'+GPT.DBPath;
        DebugProc('  DBPath: '+GPT.ServerName+':'+GPT.DBPath);
      End
      Else
      Begin
        FDBLogOn.DatabaseName:=GPT.DBPath;
        DebugProc('  DBPath: '+GPT.DBPath);
      End;
      FDBLogOn.UserName:=GPT.DBUserName;
      DebugProc('  USER NAME='+GPT.DBUserName);
      If GPT.DBPassword<>'' Then
      Begin
        FDBLogOn.Password:=GPT.DBPassword;
        FDBLogOn.LoginPrompt:=False;
      End
      Else
        FDBLogOn.LoginPrompt:=True;

      If GPT.ServerCodePage='' Then
        FDBLogOn.Charset:='utf8'
      Else
        FDBLogOn.Charset:=GPT.ServerCodePage;

      FDBLogOn.Dialect:=GPT.SQLDialect;
      IBTransaction.Database:=FDBLogOn;
      Try
        DebugProc('Connected...');
        FDBLogOn.Open;
        DebugProc('  ... OK');
        Result:=0;
        ConnectErrorCode:=0;
      Except
        DebugProc('  ... Fail');
        ConnectErrorCode:=255;
        ShowErrorMessage(0, 'Не удалось подсоединиться к БД. 0000');
        Result:=255;
      End;
    End;
{$ENDIF}

  if not Assigned(ShadowQuery) then
  begin
    ShadowQuery:=TDCLDialogQuery.Create(nil);
    ShadowQuery.Name:='DCLLogOn_ShadowQuery';
    SetDBName(ShadowQuery);
  end;
end;

constructor TDCLLogOn.Create(DBLogOn: TDBLogOn);
begin
{$IFDEF ADO}
  CoInitialize(Nil);
{$ENDIF}
  RoleOK:=lsNotNeed;
  CurrentForm:=-1;
  RoleRaightsLevel:=0;
  FAccessLevel:=ulExecute;
  Variables:=TVariables.Create(Self, nil);

  GPT.DBUserName:='';
  GPT.DCLUserName:='';
  GPT.DCLUserPass:='';
  GPT.EnterPass:='';
  GPT.LongRoleName:='';
{$IFDEF BDE}
  GPT.StringTypeChar:='"';
{$ELSE}
  GPT.StringTypeChar:='''';
{$ENDIF}
{$IFDEF IB}
  GPT.SQLDialect:=3;
{$ENDIF}
{$IFDEF SQLdbIB}
  GPT.StringTypeChar:='''';
  GPT.SQLDialect:=3;
{$ENDIF}

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

  //Command:=TDCLCommand.Create(nil, Self);

  NewLogOn:=not Assigned(DBLogOn);
  If NewLogOn then
  Begin
    FDBLogOn:=TDBLogOn.Create(Application);
    FDBLogOn.Name:='DCL_DBLogOn1';
  End
  Else
    FDBLogOn:=DBLogOn;

{$IFDEF ADO}
  FDBLogOn.KeepConnection:=True;
{$ENDIF}
end;

function TDCLLogOn.CreateForm(FormName: String; ParentForm: TDCLForm; Query: TDCLDialogQuery;
  Data: TDataSource; ModalMode: Boolean; ReturnValueMode:TChooseMode;
  ReturnValueParams:TReturnValueParams=nil): TDCLForm;
var
  i: Integer;
  Scr: TStringList;
begin
  // Scr:=LoadScrText(FormName);

  ShadowQuery.Close;
  ShadowQuery.SQL.Text:='select * from DCL_SCRIPTS where lower(DCLNAME)=lower('''+FormName+''')';
  ShadowQuery.Open;
  Scr:=TStringList.Create;
  Scr.Text:=ShadowQuery.FieldByName('DCLTEXT').AsString;
  ShadowQuery.Close;

  i:=GetNextForm;
  FForms[i]:=TDCLForm.Create(FormName, Self, ParentForm, i, Scr, Query, Data,
                                       ModalMode, ReturnValueMode, ReturnValueParams);
  CurrentForm:=i;
  ActiveDCLForms[i]:=true;

  If Assigned(FDCLMainMenu) then
    FDCLMainMenu.UpdateFormBar;
  Result:=FForms[i];
  FreeAndNil(Scr);
end;

procedure TDCLLogOn.CreateMenu(MainForm: TForm);
begin
  FMainForm:=MainForm;
  If not Assigned(MainForm) then
    FMainForm:=TForm.Create(Nil);

  If Assigned(FDCLMainMenu) then
  Begin
    FreeAndNil(FDCLMainMenu);
  End;

  FDCLMainMenu:=TDCLMainMenu.Create(Self, MainForm);
  LoadMainFormPos(Self, MainForm, 'MainForm');
end;

procedure TDCLLogOn.Disconnect;
begin
  LoggingUser(False);
  FDBLogOn.Connected:=False;
end;

procedure TDCLLogOn.ExecShellCommand(ShellCommandText: String);
Var
  Bat: TStringList;
  sBAT: string;
Begin
  Bat:=TStringList.Create;
  Bat.Text:=ShellCommandText;
  If Bat.Count>0 Then
  Begin
    If PosEx('script type=ShellCommand', Bat[0])<>0 Then
      Bat.Delete(0);
  End;
  If Bat.Count>0 Then
  Begin
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

    ExecAndWait(PChar(IncludeTrailingPathDelimiter(AppConfigDir)+'$Batch$.bat'), SW_SHOWNORMAL);
    If FileExists(IncludeTrailingPathDelimiter(AppConfigDir)+'$Batch$.bat') Then
      DeleteFile(PChar(IncludeTrailingPathDelimiter(AppConfigDir)+'$Batch$.bat'));
  End;

  FreeAndNil(Bat);
End;

procedure TDCLLogOn.ExecVBS(VBSScript: String);
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
    RePlaseVariables(tmpVBSText);
    ExecuteStatement(tmpVBSText);
  End;
  FreeAndNil(VBSText);
End;

function TDCLLogOn.GetConfigInfo: String;
Var
  Q: TDCLDialogQuery;
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

function TDCLLogOn.GetConfigVersion: String;
Var
  Q: TDCLDialogQuery;
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

function TDCLLogOn.GetConnected: Boolean;
begin
  Result:=FDBLogOn.Connected;
end;

function TDCLLogOn.GetForm(Index: Integer): TDCLForm;
begin
  If length(FForms)>Index then
    Result:=FForms[Index]
  Else
    Result:=nil;
end;

function TDCLLogOn.GetFormsCount: Integer;
begin
  Result:=Length(FForms);
end;

function TDCLLogOn.GetFullRaight: Word;
Begin
  Result:=RoleRaightsLevel*16+Ord(FAccessLevel);
End;

function TDCLLogOn.GetLastFormNum: Integer;
Var
  i: Byte;
Begin
  Result:=-1;
  For i:=FormsCount downto 1 Do
    If ActiveDCLForms[i-1] Then
    Begin
      Result:=i;
      break;
    End;
End;

function TDCLLogOn.GetMainFormNum: Integer;
Begin
  Result:=-1;
  { For i:=1 To MaxFormsCount Do
    If FormData[i].MainForm Then
    Begin
    Result:=i;
    Break;
    End; }
End;

procedure TDCLLogOn.GetTableNames(var List: TStrings);
begin
{$IFDEF ADO}
  FDBLogOn.GetTableNames(List);
{$ENDIF}
{$IFDEF ZEOS}
  FDBLogOn.GetTableNames('', List);
{$ENDIF}
{$IFDEF IB}

{$ENDIF}
end;

function TDCLLogOn.GetNextForm: Integer;
var
  i: Integer;
  Find: Boolean;
begin
  Find:=False;
  For i:=1 to FormsCount do
    if not Assigned(FForms[i-1]) then
    begin
      FForms[i-1]:=nil;
      Result:=i-1;
      Find:=true;
      break;
    end;

  If Not Find then
  Begin
    i:=length(FForms);
    SetLength(FForms, i+1);
    SetLength(ActiveDCLForms, i+1);
    ActiveDCLForms[i]:=False;
    Result:=i;
  End;
end;

function TDCLLogOn.GetRolesQueryText(QueryType: TSelectType; WhereStr: String): String;
Var
  FromStr, WhereStr1: String;
Begin
  If GPT.DCLUserName='' Then
  Begin
    FromStr:=GPT.DCLTable+' s';
    WhereStr1:=' where '+WhereStr;
  End
  Else If GPT.MultiRolesMode Then
  Begin
    FromStr:=GPT.DCLTable+' s, '+RolesMenuTable+' rm, '+RolesTable+' r, '+UsersTable+' u, '+
      RolesToUsersTable+' ru ';
    WhereStr1:='where r.'+RolesIDFiled+'=rm.'+RolesMenuIDFiled+' and rm.'+RoleMenuItemIDField+'=s.'+
      GPT.NumSeqField+' and ru.'+RolesToUsersRoleIDField+'=r.'+RolesIDFiled+' and u.'+UserIDField+
      '=ru.'+RolesToUsersUserIDField+' and u.'+UserIDField+'='+IntToStr(FUserID)+' and '+WhereStr;
  End
  Else
  Begin
{$IFDEF EMBEDDED}
    FromStr:=GPT.DCLTable+' s ';
    WhereStr1:='where '+WhereStr;
{$ELSE}
    FromStr:=GPT.DCLTable+' s, '+RolesMenuTable+' rm, '+RolesTable+' r, '+UsersTable+' u ';
    WhereStr1:='where r.'+RolesIDFiled+'=rm.'+RolesMenuIDFiled+' and rm.'+RoleMenuItemIDField+'=s.'+
      GPT.NumSeqField+' and u.'+UserRoleField+'=r.'+RolesIDFiled+' and u.'+UserIDField+'='+
      IntToStr(FUserID)+' and '+WhereStr;
{$ENDIF}
  End;

  Case QueryType Of
  qtCount:
  Result:='select Count(*) from '+FromStr+WhereStr1;
  qtSelect:
  If GPT.MultiRolesMode Then
    Result:='select distinct s.* from '+FromStr+WhereStr1
  Else
    Result:='select s.* from '+FromStr+WhereStr1;
  End;
End;

function TDCLLogOn.LoadScrText(ScrName: String): TStringList;
begin
  Result:=TStringList.Create;
  ShadowQuery.Close;
  ShadowQuery.SQL.Text:='select * from DCL_SCRIPTS where lower(DCLNAME)=lower('''+ScrName+''')';
  ShadowQuery.Open;
  Result.Text:=ShadowQuery.FieldByName('DCLTEXT').AsString;
  ShadowQuery.Close;
end;

procedure TDCLLogOn.Lock;
Var
  OldUserID: String;
  Res: TLogOnStatus;
{$IFNDEF EMBEDDED}
  LogOnForm: TLogOnForm;
{$ENDIF}
Begin
{$IFNDEF EMBEDDED}
  NotifyForms(fnaHide);
  OldUserID:=GPT.UserID;

  LogOnForm:=TLogOnForm.Create(Self, GPT.DCLUserName, true, true);
  LogOnForm.CreateForm(true, true, GPT.DCLUserName);
  repeat
    LogOnForm.ShowForm;
    GetUserName(LogOnForm.UserName);
    If CheckPass(LogOnForm.UserName, LogOnForm.EnterPass, GPT.DCLUserPass) then
      Res:=lsLogonOK;
    if LogOnForm.PressOK=psCanceled then
      break;
  until Res=lsLogonOK;
  FreeAndNil(LogOnForm);

  If (Res=lsLogonOK)and(OldUserID<>GPT.UserID) then
    CreateMenu(FMainForm);

  NotifyForms(fnaShow);
{$ENDIF}
End;

procedure TDCLLogOn.LoggingUser(Login: Boolean);
Var
  LoggingQuery: TDCLDialogQuery;
begin
{$IFNDEF EMBEDDED}
  LoggingQuery:=TDCLDialogQuery.Create(nil);
  LoggingQuery.Name:='LoggingUser_'+IntToStr(UpTime);
  SetDBName(LoggingQuery);

  If Login Then
  Begin
    DCLSession.LoginTime:=TimeStampToStr(Now);
    DCLSession.ComputerName:=GetComputerName;
    DCLSession.IPAdress:=GetLocalIP;
    DCLSession.UserSystemName:=GetUserFromSystem;
  End;

  If GPT.UserLogging Then
  Begin
    If DCLSession.LoginTime<>'' Then
    Begin
      If Login Then
      Begin
        LoggingQuery.SQL.Text:='insert into '+GPT.ACTIVE_USERS_TABLE+
          '(ACTIVE_USER_ID, ACTIVE_USER_HOST, ACTIVE_USER_IP, ACTIVE_USER_DCL_VER, ACTIVE_USER_LOGIN_TIME) '
          +'values('+GPT.UserID+', '''+DCLSession.ComputerName+'/'+DCLSession.UserSystemName+
          ''', '''+DCLSession.IPAdress+''', '''+Version+''', '''+DCLSession.LoginTime+''' )';
      End
      Else
        LoggingQuery.SQL.Text:='delete from '+GPT.ACTIVE_USERS_TABLE+' where ACTIVE_USER_ID='+
          GPT.UserID+' and ACTIVE_USER_HOST='''+DCLSession.ComputerName+'/'+
          DCLSession.UserSystemName+''' and '+'ACTIVE_USER_DCL_VER='''+Version+
          ''' and ACTIVE_USER_LOGIN_TIME='''+DCLSession.LoginTime+'''';

      Try
        LoggingQuery.ExecSQL;
      Except

      End;
    End;
  End;

  If GPT.UserLoggingHistory Then
  Begin
    If DCLSession.LoginTime<>'' Then
    Begin
      If Login Then
      Begin
        LoggingQuery.SQL.Text:='insert into '+GPT.USER_LOGIN_HISTORY_TABLE+
          '(UL_USER_ID, UL_LOGIN_TIME, UL_HOST_IP, UL_HOST_NAME, UL_DCL_VER) '+'values('+GPT.UserID+
          ', '''+DCLSession.LoginTime+''', '''+DCLSession.IPAdress+''', '''+DCLSession.ComputerName+
          '/'+DCLSession.UserSystemName+''', '''+Version+''')';
      End
      Else
        LoggingQuery.SQL.Text:='update '+GPT.USER_LOGIN_HISTORY_TABLE+' set UL_LOGOFF_TIME='''+
          TimeStampToStr(Now)+''' where '+'UL_USER_ID='+GPT.UserID+' and UL_LOGIN_TIME='''+
          DCLSession.LoginTime+''' and UL_HOST_NAME='''+DCLSession.ComputerName+'/'+
          DCLSession.UserSystemName+''' and UL_DCL_VER='''+Version+'''';
      Try
        LoggingQuery.ExecSQL;
      Except

      End;
    End;
  End;

  FreeAndNil(LoggingQuery);
{$ENDIF}
end;

function TDCLLogOn.Login(UserName, Password: String; ShowForm: Boolean): TLogOnStatus;
{$IFNDEF EMBEDDED}
var
  LogOnForm: TLogOnForm;
{$ENDIF}
begin
{$IFNDEF EMBEDDED}
  If not GPT.DisableLogOnWithoutUser then
    Result:=lsLogonOK
  Else
    Result:=lsRejected;

  GetUserName(UserName);
{$IFDEF DEVELOPERMODE}
  If FAccessLevel<>ulDeveloper Then
{$ELSE}
  If GPT.DisableLogOnWithoutUser then
    If FAccessLevel=ulDeny Then
{$ENDIF}
    Begin
      ShowErrorMessage(1, SourceToInterface(GetDCLMessageString(msDenyMessage)));
      Halt;
    End;

  If (((UserName='')or(Password=''))and ShowForm)or GPT.DisableLogOnWithoutUser Then
  begin
    RoleOK:=lsRejected;
    LogOnForm:=TLogOnForm.Create(Self, UserName, False, False);
    LogOnForm.CreateForm(False, False, UserName);
    PassRetries:=0;

    If Not CheckPass(UserName, Password, GPT.DCLUserPass)Or ShowForm Then
    Begin
      RoleOK:=lsRejected;
      repeat
        Application.Initialize;
        LogOnForm.ShowForm;
        GetUserName(LogOnForm.UserName);
        If CheckPass(LogOnForm.UserName, LogOnForm.EnterPass, GPT.DCLUserPass) then
        Begin
          Result:=lsLogonOK;
          RoleOK:=lsLogonOK;
        End;
        inc(PassRetries);
        if LogOnForm.PressOK=psCanceled then
          break;
      until (Result=lsLogonOK)or(PassRetries>3);
    End
    Else If CheckPass(UserName, Password, GPT.DCLUserPass) then
    Begin
      Result:=lsLogonOK;
      RoleOK:=lsLogonOK;
    End;

    FreeAndNil(LogOnForm);
  end
  else
  begin
    If CheckPass(UserName, Password, GPT.DCLUserPass) then
    Begin
      Result:=lsLogonOK;
      RoleOK:=lsLogonOK;
    End;
  end;

  If GPT.UserLogging then
    GPT.UserLogging:=TableExists(GPT.ACTIVE_USERS_TABLE);

  If GPT.UserLoggingHistory Then
    GPT.UserLoggingHistory:=TableExists(GPT.USER_LOGIN_HISTORY_TABLE);

  LoggingUser(True);

  MessageFormObject:=TMessageFormObject.Create('', '');
  If GPT.UseMessages Then
  Begin
    MessagesTimer:=TTimer.Create(Nil);
    MessagesTimer.Interval:=IntervalTimeNotify;
    MessagesTimer.Enabled:=true;
    MessagesTimer.OnTimer:=WaitNotify;
    WaitNotify(Nil);
  End;
{$ELSE}
  Result:=lsLogonOK;
  RoleOK:=lsLogonOK;
{$ENDIF}
end;

procedure TDCLLogOn.GetUserName(AUserName: String);
Var
  FromStr, WhereStr, DBUserNameField, DBPasswordField: String;
Begin
  DBPasswordField:='';
  DBUserNameField:='';
{$IFNDEF EMBEDDED}
  GPT.DCLUserName:=AUserName;
  ShadowQuery.Close;
  SetDBName(ShadowQuery);
  If FieldExists(DBUSER_NAME_Field, nil, UsersTable) then
    DBUserNameField:=', '+DBUSER_NAME_Field;
  If FieldExists(DBPASS_Field, nil, UsersTable) then
    DBPasswordField:=', '+DBPASS_Field;

  DebugProc('Selecting role...');
  If LongUserNameField<>'' then
  Begin
    ShadowQuery.Close;
    ShadowQuery.SQL.Text:='select '+UserAdminField+', '+UserIDField+', '+UserPassField+', '+
      LongUserNameField+', '+UserRoleField+', '+RoleNameField+', '+LongRoleNameField+DBUserNameField
      +DBPasswordField+' from '+UsersTable+', '+RolesTable+' where '+GPT.UpperString+UserNameField+
      GPT.UpperStringEnd+'='+GPT.UpperString+GPT.StringTypeChar+AUserName+GPT.StringTypeChar+
      GPT.UpperStringEnd+' and '+UserRoleField+'='+RolesIDFiled;
    DebugProc('  Query: '+ShadowQuery.SQL.Text);
    Try
      ShadowQuery.Open;
      DebugProc('  ... OK');
    Except
      On E: Exception do
      Begin
        DebugProc('  ... Fail/ '+E.Message);
      End;
    End;
    GPT.DCLLongUserName:=TrimRight(ShadowQuery.FieldByName(LongUserNameField).AsString);
  End;
  GPT.UserID:=ShadowQuery.FieldByName(UserIDField).AsString;
  FUserID:=ShadowQuery.FieldByName(UserIDField).AsInteger;
  GPT.RoleID:=ShadowQuery.FieldByName(UserRoleField).AsString;
  GPT.LongRoleName:=Trim(ShadowQuery.FieldByName(LongRoleNameField).AsString);
  GPT.DCLRoleName:=Trim(ShadowQuery.FieldByName(RoleNameField).AsString);
  If DBUserNameField<>'' then
  Begin
    Delete(DBUserNameField, 1, 1);
{$IFDEF ADO}
    GPT.NewConnectionString:=Trim(ShadowQuery.FieldByName(Trim(DBUserNameField)).AsString);
{$ELSE}
    GPT.NewDBUserName:=Trim(ShadowQuery.FieldByName(Trim(DBUserNameField)).AsString);
{$ENDIF}
  End;

  If DBPasswordField<>'' then
  Begin
    Delete(DBPasswordField, 1, 1);
    GPT.NewDBPassword:=Trim(ShadowQuery.FieldByName(Trim(DBPasswordField)).AsString);
  End;

  If GPT.DisableLogOnWithoutUser then
  Begin
    Try
      FAccessLevel:=TranslateDigitToUserLevel(ShadowQuery.FieldByName(UserAdminField).AsInteger);
    Except
      FAccessLevel:=ulExecute;
    End;
  End
  Else
    FAccessLevel:=ulExecute;

  If GPT.HashPass then
    GPT.DCLUserPass:=TrimRight(ShadowQuery.FieldByName(UserPassField).AsString)
  Else
    GPT.DCLUserPass:=TrimRight(ShadowQuery.FieldByName(UserPassField).AsString);

  ShadowQuery.Close;
  If GPT.MultiRolesMode Then
  Begin
    FromStr:='select max('+DCLROLE_ACCESSLEVEL_FIELD+') from '+RolesTable+' r, '+UsersTable+' u, '+
      RolesToUsersTable+' ru ';
    WhereStr:='where ru.'+RolesToUsersRoleIDField+'=r.'+RolesIDFiled+' and u.'+UserIDField+'=ru.'+
      RolesToUsersUserIDField;
  End
  Else
  Begin
    FromStr:='select '+DCLROLE_ACCESSLEVEL_FIELD+' from '+RolesTable+' r, '+UsersTable+' u ';
    WhereStr:='where u.'+UserRoleField+'=r.'+RolesIDFiled;
  End;
  if GPT.UserID<>'' then
  Begin
    ShadowQuery.Close;
    ShadowQuery.SQL.Text:=FromStr+WhereStr+' and u.'+UserIDField+'='+GPT.UserID;
    Try
      ShadowQuery.Open;
      DebugProc('  ... OK');
    Except
      DebugProc('  ... Fail');
    End;
  End;

  RoleRaightsLevel:=0;
  If not ShadowQuery.IsEmpty then
  Begin
    Try
      If FieldExists(DCLROLE_ACCESSLEVEL_FIELD, ShadowQuery) then
        RoleRaightsLevel:=ShadowQuery.FieldByName(DCLROLE_ACCESSLEVEL_FIELD).AsInteger;
    Except
      RoleRaightsLevel:=0
    End;
  End
  Else
    RoleRaightsLevel:=0;

  ShadowQuery.Close;
{$ELSE}
  FAccessLevel:=ulExecute;
{$ENDIF}
end;

procedure TDCLLogOn.InitActions(Sender: TObject);
Var
  MenuQuery: TDCLDialogQuery;
  RecCount: Cardinal;
Begin
  Timer1.Enabled:=False;

  FDCLMainMenu.LockMenu;

  MenuQuery:=TDCLDialogQuery.Create(Nil);
  MenuQuery.Name:='Menu_'+IntToStr(UpTime);
  SetDBName(MenuQuery);
  MenuQuery.SQL.Text:=GetRolesQueryText(qtCount, ' s.'+GPT.IdentifyField+
    ' between 40001 and 40100');
  MenuQuery.Open;
  RecCount:=MenuQuery.Fields[0].AsInteger;

  If RecCount>0 Then
  Begin
    MenuQuery.Close;
    MenuQuery.SQL.Text:=GetRolesQueryText(qtSelect, ' s.'+GPT.IdentifyField+
      ' between 40001 and 40100 order by s.'+GPT.IdentifyField);
    MenuQuery.Open;
    While Not MenuQuery.Eof Do
    Begin
      FDCLMainMenu.ChoseRunType(MenuQuery.FieldByName(GPT.CommandField).AsString,
        MenuQuery.FieldByName(GPT.DCLTextField).AsString, MenuQuery.FieldByName(GPT.DCLNameField)
        .AsString, 1);
      MenuQuery.Next;
    End;
  End;
  Timer1.Enabled:=False;
  FreeAndNil(Timer1);

  FDCLMainMenu.UnLockMenu;

  MenuQuery.Close;
  FreeAndNil(MenuQuery);
End;

procedure TDCLLogOn.NotifyForms(Action: TFormsNotifyAction);
Var
  i, tmpCF, mfn: Integer;
Begin
  tmpCF:=CurrentForm;
  mfn:=GetMainFormNum;
  If length(FForms)>0 then
    For i:=0 To FormsCount-1 Do
      If mfn<>i Then
        If ActiveDCLForms[i] Then
          If Assigned(FForms[i]) Then
            Case Action Of
            fnaRefresh:
            FForms[i].RefreshForm;
            fnaClose:
            FreeAndNil(FForms[i]);
            { fnaSetMDI:
              FForms[i].FForm.Parent:=FormData[mfn].DBForm; }
            fnaResetMDI:
            FForms[i].FForm.Parent:=Nil;
            fnaHide:
            FForms[i].FForm.Hide;
            fnaShow:
            FForms[i].FForm.Show;
            { fnaStopAutoRefresh:
              If Assigned(FormData[i].RefreshTimer) Then
              FormData[i].RefreshTimer.Enabled:=False;
              fnaStartAutoRefresh:
              If Assigned(FormData[i].RefreshTimer) Then
              FormData[i].RefreshTimer.Enabled:=True;
              fnaPauseAutoRefresh:
              If Assigned(FormData[i].RefreshTimer) Then
              If FormData[i].RefreshTimer.Enabled then
              FormData[i].LastStateTimer:=FormData[i].RefreshTimer.Enabled;
              fnaResumeAutoRefresh:
              If Assigned(FormData[i].RefreshTimer) Then
              If not FormData[i].RefreshTimer.Enabled then
              FormData[i].RefreshTimer.Enabled:=FormData[i].LastStateTimer; }
            End;
  CurrentForm:=tmpCF;
  // FForms[CurrentForm].BringToFront;
end;

function TDCLLogOn.ReadConfig(ConfigName, UserID: String): String;
Var
  ParamsQuery: TReportQuery;
  WhereUser: String;
Begin
  Result:='';
  WhereUser:='';
  If Not GPT.NoParamsTable Then
  Begin
    If UserID<>'' Then
      WhereUser:=' and '+GPT.GPTUserIDField+'='+UserID;

    ParamsQuery:=TDCLDialogQuery.Create(Nil);
    ParamsQuery.Name:='Params_'+IntToStr(UpTime);
    SetDBName(ParamsQuery);
    ParamsQuery.SQL.Text:='select '+GPT.GPTValueField+' from '+GPT.GPTTableName+' where '+
      GPT.UpperString+GPT.GPTNameField+GPT.UpperStringEnd+'='+GPT.UpperString+GPT.StringTypeChar+
      ConfigName+GPT.StringTypeChar+GPT.UpperStringEnd+WhereUser;
    ParamsQuery.Open;
    Result:=TrimRight(ParamsQuery.Fields[0].AsString);
    ParamsQuery.Close;
    FreeAndNil(ParamsQuery);
  End;
End;

procedure TDCLLogOn.RePlaseVariables(var VariablesSet: String);
begin
  Variables.RePlaseVariables(VariablesSet, nil);
end;

procedure TDCLLogOn.RunCommand(CommandName: String);
var
  Command:TDCLCommand;
begin
  Command:=TDCLCommand.Create(nil, Self);
  Command.ExecCommand(CommandName, nil);
  FreeAndNil(Command);
end;

procedure TDCLLogOn.RunInitSkripts;
begin
  Timer1:=TTimer.Create(Nil);
  Timer1.Interval:=IntervalTimeToInitScripts;
  Timer1.Enabled:=true;
  Timer1.OnTimer:=InitActions;
end;

procedure TDCLLogOn.SetDBName(Query: TDCLDialogQuery);
begin
{$IFDEF ADO}
  Query.Connection:=FDBLogOn;
{$ENDIF}
{$IFDEF BDE}
  If GPT.Alias<>'' then
    Query.DatabaseName:=GPT.Alias
  Else
    Query.DatabaseName:=FDBLogOn.DatabaseName; // 'DCL_LogOn_$_Main';
{$ENDIF}
{$IFDEF IB}
  Query.Database:=FDBLogOn;
  Query.Transaction:=IBTransaction;
{$ENDIF}
{$IFDEF ZEOS}
  Query.Connection:=FDBLogOn;
{$ENDIF}
{$IFDEF SQLdbIB}
  Query.Database:=FDBLogOn;
  Query.Transaction:=IBTransaction;
{$ENDIF}
end;

function TDCLLogOn.TableExists(TableName: String): Boolean;
Var
  TestQuery: TDCLDialogQuery;
Begin
  TestQuery:=TDCLDialogQuery.Create(nil);
  TestQuery.Name:='TebleExists_'+IntToStr(UpTime);
  SetDBName(TestQuery);
{$IFDEF IBALL}
  TestQuery.SQL.Text:=
    'select count(*) from RDB$RELATION_FIELDS f where upper(f.RDB$RELATION_NAME)=upper(:RN)';
  TestQuery.ParamByName('RN').AsString:=TableName;
  Try
    TestQuery.Open;
  Except
    FreeAndNil(TestQuery);
    Result:=False;
    Exit;
  End;
  Result:=TestQuery.Fields[0].AsInteger>0;
  FreeAndNil(TestQuery);
{$ELSE}
  TestQuery.SQL.Text:='select * from '+TableName+' where 1=0';
  Try
    TestQuery.Open;
    Result:=true;
  Except
    FreeAndNil(TestQuery);
    Result:=False;
    Exit;
  End;
  FreeAndNil(TestQuery);
{$ENDIF}
End;

procedure TDCLLogOn.TranslateVal(var S: String);
Var
  Factor: Word;
begin
  RePlaseVariables(S);
  Factor:=0;
  TranslateProc(S, Factor);
end;

procedure TDCLMainMenu.UpdateFormBar;
Var
  i: Byte;
  TB1: TFormPanelButton;
Begin
  If ShowFormPanel Then
    If Assigned(FormBar) Then
    Begin
      For i:=1 to FDCLLogOn.FormsCount do
        If FDCLLogOn.ActiveDCLForms[i-1] then
          If Assigned(FDCLLogOn.Forms[i-1]) then
          Begin
            TB1:=(FormBar.FindComponent('TB'+IntToStr(FDCLLogOn.Forms[i-1].FForm.Tag))
              As TFormPanelButton);
            If Assigned(TB1) then
            Begin
              If FDCLLogOn.Forms[i-1].FForm=Screen.ActiveForm then
              begin
                TB1.Glyph:=DrawBMPButton('FormDotActive');
                TB1.Font.Style:=[fsBold];
              End
              Else
              Begin
                TB1.Glyph:=DrawBMPButton('FormDotInActive');
                TB1.Font.Style:=[];
              End
            End;
          End;
    End;
End;

procedure TDCLLogOn.WaitNotify(Sender: TObject);
Var
  ShadowQuery, ShadowQuery1: TDCLDialogQuery;
  NowTime, TaskTimeStr, NowTimeStr: String;
  NowTimeStruct, TaskTime: TDateTimeItem;
  RunTask: Boolean;

  Function GetNotifyAction(NA: Byte): TNotifyActionsType;
  Begin
    // naDone, naScriptRun, naMessage, naExecAndWait, naExec, naExitToTime
    Case NA Of
    0:
    Result:=naDone;
    1:
    Result:=naScriptRun;
    2:
    Result:=naMessage;
    3:
    Result:=naExecAndWait;
    4:
    Result:=naExec;
    5:
    Result:=naExitToTime;
  Else
  Result:=naDone;
    End;
  End;

  Procedure MessageToUser(Text: String);
  Begin
    If GPT.UserID<>'' Then
      MessageFormObject:=TMessageFormObject.Create(GPT.DCLLongUserName, Text)
    Else
      MessageFormObject:=TMessageFormObject.Create(SourceToInterface('<'+GetDCLMessageString(msToAll)+'>'), Text);
  End;

Begin
  // 4 - Выход по дате.
  // 2,3 - Запуск приложения.
  // 1 - Сообщение.
  // 5 - Запуск скрипта.
{$IFNDEF NODCLMESSAGES}
  If Not GPT.UseMessages Then
    Exit;

  ShadowQuery:=TDCLDialogQuery.Create(Nil);
  ShadowQuery.Name:='Wait_'+IntToStr(UpTime);
  SetDBName(ShadowQuery);

  ShadowQuery1:=TDCLDialogQuery.Create(Nil);
  ShadowQuery1.Name:='Wait1_'+IntToStr(UpTime);
  SetDBName(ShadowQuery1);

  ShadowQuery.Close;
  If GPT.UserID<>'' Then
  Begin
    ShadowQuery.SQL.Text:='select first 1 NOTIFY_ACTION, NOTIFY_TIME, NOTIFY_ID, NOTIFY_TEXT from '+
      GPT.NotifycationsTable+' where USER_ID='+GPT.UserID+' and NOTIFY_STATE<>'+IntToStr(Ord(naDone)
      )+' order by NOTIFY_TIME, NOTIFY_ACTION';
  End
  Else
  Begin
    ShadowQuery.SQL.Text:='select first 1 NOTIFY_ACTION, NOTIFY_TIME, NOTIFY_ID, NOTIFY_TEXT from '+
      GPT.NotifycationsTable+' where NOTIFY_STATE<>'+IntToStr(Ord(naDone))+
      ' order by NOTIFY_TIME, NOTIFY_ACTION';
  End;

  If TableExists(GPT.NotifycationsTable) then
  Begin
    Try
      ShadowQuery.Open;
      GPT.UseMessages:=true;
    Except
      GPT.UseMessages:=False;
      MessagesTimer.Enabled:=False;
    End;
  End
  Else
    GPT.UseMessages:=False;

  If not GPT.UseMessages then
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
  Begin
    ShadowQuery.First;
    While Not ShadowQuery.Eof Do
    Begin
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
      Begin
        Case GetNotifyAction(ShadowQuery.FieldByName('NOTIFY_ACTION').AsInteger) Of
        naScriptRun:
        Begin
          RunCommand(Trim(ShadowQuery.FieldByName('NOTIFY_TEXT').AsString));
        End;
        naExecAndWait:
        Begin
          ExecAndWait(Trim(ShadowQuery.FieldByName('NOTIFY_TEXT').AsString), SW_SHOWNORMAL);
        End;
        naExec:
        Begin
          Exec(ShadowQuery.FieldByName('NOTIFY_TEXT').AsString, '');
        End;
        naMessage:
        Begin
          MessageToUser(Trim(ShadowQuery.FieldByName('NOTIFY_TEXT').AsString));
        End;
        naExitToTime:
        Begin
          If ExitFlag=0 Then
          Begin
            MessageToUser(AnsiToUTF8('Выход из системы через '+IntToStr(ExitTime)+' секунд.'));
            ExitFlag:=1;
            TimeToExit:=UpTime+(ExitTime*1000);
          End;
        End
      Else
      MessageToUser(Trim(ShadowQuery.FieldByName('NOTIFY_TEXT').AsString));
        End;
        ShadowQuery1.Close;
        ShadowQuery1.SQL.Text:='update '+GPT.NotifycationsTable+' n set n.NOTIFY_STATE='+
          IntToStr(Ord(naDone))+' where n.NOTIFY_ID='+ShadowQuery.FieldByName('NOTIFY_ID').AsString;
        ShadowQuery1.ExecSQL;
      End;
      If ExitFlag>1 Then
        inc(ExitFlag);

      ShadowQuery.Next;
    End;
  End;

  FreeAndNil(ShadowQuery);
  FreeAndNil(ShadowQuery1);
{$ENDIF}
End;

procedure TDCLLogOn.WriteConfig(ConfigName, NewValue, UserID: String);
Var
  ParamsQuery: TReportQuery;
  WhereUser: String;
Begin
  WhereUser:='';
  If Not GPT.NoParamsTable Then
  Begin
    If UserID<>'' Then
      WhereUser:=' and '+GPT.GPTUserIDField+'='+UserID;

    ParamsQuery:=TDCLDialogQuery.Create(Nil);
    ParamsQuery.Name:='WriteConfig_'+IntToStr(UpTime);
    SetDBName(ParamsQuery);
    ParamsQuery.SQL.Text:='select count(*) from '+GPT.GPTTableName+' where '+GPT.UpperString+
      GPT.StringTypeChar+GPT.UpperStringEnd+'='+GPT.UpperString+GPT.StringTypeChar+ConfigName+
      GPT.StringTypeChar+GPT.UpperStringEnd+WhereUser;
    ParamsQuery.Open;
    If ParamsQuery.Fields[0].AsInteger>0 Then
    Begin
      ParamsQuery.Close;
      ParamsQuery.SQL.Text:='update '+GPT.GPTTableName+' set '+GPT.GPTValueField+'='+
        GPT.StringTypeChar+NewValue+GPT.StringTypeChar+' where '+GPT.UpperString+GPT.GPTNameField+
        GPT.UpperStringEnd+'='+GPT.UpperString+GPT.StringTypeChar+ConfigName+GPT.StringTypeChar+
        GPT.UpperStringEnd+WhereUser;
      ParamsQuery.ExecSQL;
    End
    Else
    Begin
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
    End;
    FreeAndNil(ParamsQuery);
  End;
End;

{ TDCLMenu }
Procedure CreateAboutItem(Var MainMenu: TMainMenu; Form: TForm);
Var
  ItemMenu: TMenuItem;
Begin
  If not Assigned(MainMenu) then
    MainMenu:=TMainMenu.Create(Form);

  ItemMenu:=TMenuItem.Create(MainMenu);
  ItemMenu.Name:='ItemMeu_About';
  ItemMenu.Caption:='О...';
  ItemMenu.OnClick:=DCLMainLogOn.About;
  MainMenu.Items.Add(ItemMenu);
End;

procedure TDCLMainMenu.ExecCommand(Command: String);
var
  DCLCommand:TDCLCommand;
begin
  DCLCommand:=TDCLCommand.Create(nil, FDCLLogOn);
  DCLCommand.ExecCommand(Command, nil);
  FreeAndNil(DCLCommand);
end;

procedure TDCLMainMenu.AddMainItem(Caption, ItemName: String);
Begin
  ItemMenu:=TMenuItem.Create(FMainMenu);
  ItemMenu.Name:=ItemName;
  ItemMenu.Caption:=Caption;
  ItemMenu.OnClick:=ClickMenu;
  FMainMenu.Items.Add(ItemMenu);
End;

procedure TDCLMainMenu.AddSubItem(Caption, ItemName: String; Level: Integer);
Begin
  If Level<>-1 Then
  Begin
    ToItem:=FMainMenu.Items[Level];
    ItemMenu:=TMenuItem.Create(ToItem);
    ItemMenu.Name:=ItemName;
    ItemMenu.Caption:=Caption;
    ItemMenu.OnClick:=ClickMenu;
    ToItem.OnClick:=Nil;
    ToItem.Insert(ToItem.Count, ItemMenu);
  End;
End;

procedure TDCLMainMenu.AddSubSubItem(Caption, ItemName: String; Level, Index: Integer);
Begin
  If (Level<>-1)and(Index<>-1) Then
  Begin
    ToItem:=FMainMenu.Items[Level][Index];
    ItemMenu:=TMenuItem.Create(ToItem);
    ItemMenu.Name:=ItemName;
    ItemMenu.Caption:=Caption;
    ItemMenu.OnClick:=ClickMenu;
    ToItem.OnClick:=Nil;
    ToItem.Insert(ToItem.Count, ItemMenu);
  End;
End;

procedure TDCLMainMenu.ChoseRunType(Command, DCLText, Name: String; Order: Byte);
Var
  DCL: TStringList;
Begin
  If FDCLLogOn.RoleOK<>lsLogonOK then
    Exit;
  DCL:=TStringList.Create;

  If (Trim(Command)<>'')And(Order<>0) Then
    ExecCommand(TrimRight(Command))
  Else
  Begin
    DCL.Text:=DCLText;
    If DCLText<>'' Then
      If FindParam('script type=', LowerCase(DCL[0]))='command' Then
      Begin
        If Trim(Command)<>'' Then
          ExecCommand(TrimRight(Command))
        Else
          ExecCommand(DCLText);
      End
      Else If LowerCase(FindParam('script type=', LowerCase(DCL[0])))=LowerCase('ShellCommand') Then
        FDCLLogOn.ExecShellCommand(DCLText)
      Else If LowerCase(FindParam('script type=', LowerCase(DCL[0])))=LowerCase('VBScript') Then
        FDCLLogOn.ExecVBS(DCLText)
      Else If Order=0 Then
        FDCLLogOn.CreateForm(TrimRight(Name), nil, nil, nil, False, chmNone)
      Else
        ExecCommand(DCLText);
  End;
  FreeAndNil(DCL);
End;

procedure TDCLMainMenu.ClickMenu(Sender: TObject);
Var
  tmp1: String;
  MenuQuery1: TDCLDialogQuery;
  RecCount: Integer;
Begin
  MenuQuery1:=TDCLDialogQuery.Create(Nil);
  MenuQuery1.Name:='ClickMenu_'+IntToStr(UpTime);
  FDCLLogOn.SetDBName(MenuQuery1);

  tmp1:=Copy((Sender As TMenuItem).Name, 10, length((Sender As TMenuItem).Name));

  MenuQuery1.SQL.Text:='select Count(*) from '+GPT.DCLTable+' where '+GPT.IdentifyField+'='+tmp1;
  MenuQuery1.Open;
  RecCount:=MenuQuery1.Fields[0].AsInteger;

  If RecCount>0 Then
  Begin
    MenuQuery1.Close;
    MenuQuery1.SQL.Text:='select * from '+GPT.DCLTable+' where '+GPT.IdentifyField+'='+tmp1;

    MenuQuery1.Open;
    tmp1:=TrimRight(MenuQuery1.FieldByName(GPT.CommandField).AsString);
    If tmp1<>'' Then
    Begin
      MenuQuery1.Close;
      MenuQuery1.SQL.Text:='select Count(*) from '+GPT.DCLTable+' where '+GPT.UpperString+
        GPT.DCLNameField+GPT.UpperStringEnd+'='+GPT.UpperString+GPT.StringTypeChar+tmp1+
        GPT.StringTypeChar+GPT.UpperStringEnd;
      MenuQuery1.Open;
      RecCount:=MenuQuery1.Fields[0].AsInteger;
      MenuQuery1.Close;
      If RecCount<>0 Then
      Begin
        MenuQuery1.Close;
        MenuQuery1.SQL.Text:='select * from '+GPT.DCLTable+' where '+GPT.UpperString+
          GPT.DCLNameField+GPT.UpperStringEnd+'='+GPT.UpperString+GPT.StringTypeChar+tmp1+
          GPT.StringTypeChar+GPT.UpperStringEnd;

        MenuQuery1.Open;
        ChoseRunType(MenuQuery1.FieldByName(GPT.CommandField).AsString,
          MenuQuery1.FieldByName(GPT.DCLTextField).AsString,
          MenuQuery1.FieldByName(GPT.DCLNameField).AsString, 0);
      End;
    End
    Else
      ChoseRunType(TrimRight(MenuQuery1.FieldByName(GPT.CommandField).AsString),
        TrimRight(MenuQuery1.FieldByName(GPT.DCLTextField).AsString),
        MenuQuery1.FieldByName(GPT.DCLNameField).AsString, 1);
  End;

  MenuQuery1.Close;
  FreeAndNil(MenuQuery1);
End;

destructor TDCLMainMenu.Destroy;
var
  MenuQuery: TDCLDialogQuery;
  RecCount: Integer;
begin
  MenuQuery:=TDCLDialogQuery.Create(Nil);
  MenuQuery.Name:='DestroyMenu_'+IntToStr(UpTime);
  FDCLLogOn.SetDBName(MenuQuery);

  MenuQuery.SQL.Text:=FDCLLogOn.GetRolesQueryText(qtCount, ' s.'+GPT.IdentifyField+
    ' between 40101 and 40200');
  MenuQuery.Open;
  RecCount:=MenuQuery.Fields[0].AsInteger;

  If RecCount>0 Then
  Begin
    MenuQuery.SQL.Text:=FDCLLogOn.GetRolesQueryText(qtSelect,
      ' s.'+GPT.IdentifyField+' between 40101 and 40200 order by s.'+GPT.IdentifyField);
    MenuQuery.Open;

    While Not MenuQuery.Eof Do
    Begin
      ChoseRunType(MenuQuery.FieldByName(GPT.CommandField).AsString,
        MenuQuery.FieldByName(GPT.DCLTextField).AsString, MenuQuery.FieldByName(GPT.DCLNameField)
        .AsString, 1);
      MenuQuery.Next;
    End;
  End;
  MenuQuery.Close;
  FreeAndNil(MenuQuery);

  If Assigned(MainFormStatus) then
    FreeAndNil(MainFormStatus);
  If Assigned(FormBar) then
    FreeAndNil(FormBar);
  If Assigned(FMainMenu) then
    FreeAndNil(FMainMenu);
end;

constructor TDCLMainMenu.Create(var DCLLogOn: TDCLLogOn; Form: TForm; Relogin: Boolean=False);
Type
  TCompotableVersionNumbers=Array [1..4] Of Word;
Var
  ProgrammCompVer, BaseCompVer: TCompotableVersionNumbers;
  RecCount, SubNum, v1: Integer;
  NewMainForm: Boolean;
  SubQuery, MenuQuery, DCLQuery: TDCLDialogQuery;
  tmpSQL, tmpSQL1, Parent: String;
begin
  FDCLLogOn:=DCLLogOn;
  MainFormAction:=TMainFormAction.Create;
  FMainForm:=FDCLLogOn.MainForm;
  FForm:=Form;

  NewMainForm:=Not Assigned(Form);
  If NewMainForm then
  Begin
    If FDCLLogOn.RoleOK<>lsLogonOK then
      Exit;
    FDCLLogOn.FMainForm:=Form;

    Form:=TDBForm.Create(Nil);
    Form.Name:='DCLMainForm';

    MainFormStatus:=TStatusBar.Create(Form);
    MainFormStatus.Name:='MainStatusPanel';
    MainFormStatus.Parent:=Form;
    MainFormStatus.SimplePanel:=False;
    Form.Left:=50;
    Form.Top:=50;
  End;

  Form.Tag:=999;

  If FDCLLogOn.RoleOK<>lsLogonOK then
  Begin
    CreateAboutItem(FMainMenu, FMainForm);
  End;

  If ShowFormPanel and not Assigned(FormBar) Then
  Begin
    FormBar:=TToolBar.Create(Form);
    FormBar.Parent:=Form;
    FormBar.Name:='FormBar';
    FormBar.ShowCaptions:=true;
    FormBar.Height:=FormPanelHeight;
    FormBar.ButtonHeight:=FormPanelButtonHeight;
    FormBar.ButtonWidth:=FormPanelButtonWidth;
    FormBar.Show;
  End;

  Form.OnClose:=MainFormAction.CloseMainForm;
  Form.OnCloseQuery:=MainFormAction.FormCloseQuery;

  // Form.OnActivate:=DBDialogFormActions.ActivateDBForm;

  MenuQuery:=TDCLDialogQuery.Create(Nil);
  MenuQuery.Name:='CreateMenu_'+IntToStr(UpTime);
  FDCLLogOn.SetDBName(MenuQuery);

  If Assigned(FMainMenu)and Relogin then
    FreeAndNil(FMainMenu);

  FMainMenu:=TMainMenu.Create(FForm);
{$IFDEF DELPHI}
  FMainMenu.AutoHotkeys:=maManual;
{$ENDIF}
  MenuQuery.SQL.Text:=FDCLLogOn.GetRolesQueryText(qtCount, ' s.'+GPT.IdentifyField+
    ' between 20001 and 20050');

  RecCount:=0;
  DebugProc('Selecting components(20001):');
  DebugProc('  Query: '+MenuQuery.SQL.Text);
  Try
    DebugProc('  ... selected');
    MenuQuery.Open;
    RecCount:=MenuQuery.Fields[0].AsInteger;
    DebugProc('  ... OK');
  Except
    DebugProc('  ... Fail');
  End;

  If RecCount>0 Then
  Begin
    MenuQuery.Close;
    MenuQuery.SQL.Text:=FDCLLogOn.GetRolesQueryText(qtSelect,
      ' s.'+GPT.IdentifyField+' between 20001 and 20050 order by s.'+GPT.IdentifyField);

    MenuQuery.Open;
    If Assigned(MainFormStatus) Then
      FreeAndNil(MainFormStatus);

    If Not Assigned(MainFormStatus) Then
    Begin
      MainFormStatus:=TStatusBar.Create(Form);
      MainFormStatus.Name:='MainStatusPanel';
      MainFormStatus.Parent:=Form;
      MainFormStatus.SimplePanel:=False;
    End;
    While Not MenuQuery.Eof Do
    Begin
      If MenuQuery.FieldByName(GPT.DCLTextField).AsString<>'' Then
        tmpSQL:=MenuQuery.FieldByName(GPT.DCLTextField).AsString
      Else
        tmpSQL:=TrimRight(MenuQuery.FieldByName(GPT.DCLNameField).AsString);
      If PosEx('select', tmpSQL)<>0 Then
        If PosEx('from', tmpSQL)<>0 Then
        Begin
          DCLQuery:=TDCLDialogQuery.Create(Nil);
          DCLQuery.Name:='Menu20001_'+IntToStr(UpTime);
          FDCLLogOn.SetDBName(DCLQuery);
          FDCLLogOn.RePlaseVariables(tmpSQL);
          DCLQuery.SQL.Text:=tmpSQL;
          DCLQuery.Open;
          tmpSQL:=TrimRight(DCLQuery.Fields[0].AsString);
          DCLQuery.Close;
          FreeAndNil(DCLQuery);
        End;
      If PosEx('ReturnValue=', tmpSQL)<>0 Then
      Begin
        tmpSQL1:=FindParam('ReturnValue=', tmpSQL);
        DeleteNonPrintSimb(tmpSQL1);
        FDCLLogOn.RePlaseVariables(tmpSQL1);
        tmpSQL:=tmpSQL1;
      End;

      MainFormStatus.Panels.Insert(MainFormStatus.Panels.Count);
      MainFormStatus.Panels[MainFormStatus.Panels.Count-1].Text:=tmpSQL;
      If MenuQuery.FieldByName(GPT.ParentFlgField).AsInteger<>0 Then
        MainFormStatus.Panels[MainFormStatus.Panels.Count-1].Width:=
          MenuQuery.FieldByName(GPT.ParentFlgField).AsInteger
      Else
        MainFormStatus.Panels[MainFormStatus.Panels.Count-1].Width:=Length(tmpSQL)*CharWidth;
      MenuQuery.Next;
    End;
  End;
  MenuQuery.Close;

  MenuQuery.SQL.Text:=FDCLLogOn.GetRolesQueryText(qtSelect, ' s.'+GPT.IdentifyField+'=0');
  MenuQuery.Open;
  tmpSQL:=TrimRight(MenuQuery.FieldByName(GPT.DCLNameField).AsString);
  FDCLLogOn.RePlaseVariables(tmpSQL);
  tmpSQL:=tmpSQL+AnsiToUTF8(GPT.MainFormCaption);
  FForm.Caption:=tmpSQL;

  If NewMainForm Then
    FForm.Show;

  MenuQuery.Close;

  MenuQuery.SQL.Text:=FDCLLogOn.GetRolesQueryText(qtCount, ' s.'+GPT.IdentifyField+
    ' between 1 and 1000');

  RecCount:=0;
  DebugProc('Selecting main menu:');
  DebugProc('  Query: '+MenuQuery.SQL.Text);
  Try
    DebugProc('  ... selected');
    MenuQuery.Open;
    RecCount:=MenuQuery.Fields[0].AsInteger;
    DebugProc('  ... OK');
  Except
    DebugProc('  ... Fail');
  End;
  If RecCount>0 Then
  Begin
    MenuQuery.Close;
    MenuQuery.SQL.Text:=FDCLLogOn.GetRolesQueryText(qtSelect,
      ' s.'+GPT.IdentifyField+' between 1 and 1000 order by s.'+GPT.IdentifyField);

    MenuQuery.Open;
    While Not MenuQuery.Eof Do
    Begin
      AddMainItem(TrimRight(MenuQuery.FieldByName(GPT.DCLNameField).AsString),
        'MenuItem_'+TrimRight(MenuQuery.FieldByName(GPT.IdentifyField).AsString));
      MenuQuery.Next;
    End;
  End
  Else
    CreateAboutItem(FMainMenu, FForm);

  MenuQuery.Close;

  MenuQuery.SQL.Text:=FDCLLogOn.GetRolesQueryText(qtCount, ' s.'+GPT.IdentifyField+
    ' between 1001 and 10000');

  RecCount:=0;
  DebugProc('Selecting sub menu:');
  DebugProc('  Query: '+MenuQuery.SQL.Text);
  Try
    DebugProc('  ... selected');
    MenuQuery.Open;
    RecCount:=MenuQuery.Fields[0].AsInteger;
    DebugProc('  ... OK');
  Except
    DebugProc('  ... Fail');
  End;

  MenuQuery.Close;
  If RecCount>0 Then
  Begin
    MenuQuery.SQL.Text:=FDCLLogOn.GetRolesQueryText(qtSelect,
      ' s.'+GPT.IdentifyField+' between 1001 and 10000 order by s.'+GPT.IdentifyField);
    MenuQuery.Open;

    While Not MenuQuery.Eof Do
    Begin
      AddSubItem(TrimRight(MenuQuery.FieldByName(GPT.DCLNameField).AsString),
        'MenuItem_'+MenuQuery.FieldByName(GPT.IdentifyField).AsString,
        FMainMenu.Items.IndexOf((FMainMenu.FindComponent('MenuItem_'+
        TrimRight(MenuQuery.FieldByName(GPT.ParentFlgField).AsString)) As TMenuItem)));
      MenuQuery.Next;
    End;
  End;
  MenuQuery.Close;

  MenuQuery.SQL.Text:=FDCLLogOn.GetRolesQueryText(qtCount, ' s.'+GPT.IdentifyField+
    ' between 10001 and 16000');

  RecCount:=0;
  DebugProc('Selecting sub sub menu:');
  DebugProc('  Query: '+MenuQuery.SQL.Text);
  Try
    DebugProc('  ... selected');
    MenuQuery.Open;
    RecCount:=MenuQuery.Fields[0].AsInteger;
    DebugProc('  ... OK');
  Except
    DebugProc('  ... Fail');
  End;

  If RecCount>0 Then
  Begin
    SubQuery:=TDCLDialogQuery.Create(Nil);
    SubQuery.Name:='MenuSub10001_'+IntToStr(UpTime);
    FDCLLogOn.SetDBName(SubQuery);

    MenuQuery.Close;
    MenuQuery.SQL.Text:=FDCLLogOn.GetRolesQueryText(qtSelect,
      ' s.'+GPT.IdentifyField+' between 10001 and 16000 order by s.'+GPT.IdentifyField);
    MenuQuery.Open;

    SubQuery.SQL.Text:=FDCLLogOn.GetRolesQueryText(qtSelect, ' s.'+GPT.IdentifyField+'='+
      MenuQuery.FieldByName(GPT.ParentFlgField).AsString);
    SubQuery.Open;
    SubNum:=SubQuery.FieldByName(GPT.ParentFlgField).AsInteger;
    SubQuery.Close;

    While Not MenuQuery.Eof Do
    Begin
      v1:=FindMenuItemIndex('MenuItem_'+IntToStr(SubNum));
      AddSubSubItem(TrimRight(MenuQuery.FieldByName(GPT.DCLNameField).AsString),
        'MenuItem_'+MenuQuery.FieldByName(GPT.IdentifyField).AsString, v1,
        FindSubMenuItemIndex('MenuItem_'+TrimRight(MenuQuery.FieldByName(GPT.ParentFlgField)
        .AsString), v1));
      MenuQuery.Next;
    End;
    FreeAndNil(SubQuery);
  End;
  MenuQuery.Close;

  MenuQuery.SQL.Text:=FDCLLogOn.GetRolesQueryText(qtCount, ' s.'+GPT.IdentifyField+
    ' between 20051 and 20100');

  RecCount:=0;
  DebugProc('Selecting components(20051):');
  DebugProc('  Query: '+MenuQuery.SQL.Text);
  Try
    DebugProc('  ... selected');
    MenuQuery.Open;
    RecCount:=MenuQuery.Fields[0].AsInteger;
    DebugProc('  ... OK');
  Except
    DebugProc('  ... Fail');
  End;

  If RecCount>0 Then
  Begin
    MenuQuery.Close;
    MenuQuery.SQL.Text:=FDCLLogOn.GetRolesQueryText(qtSelect,
      ' s.'+GPT.IdentifyField+' between 20051 and 20100 order by s.'+GPT.IdentifyField);
    MenuQuery.Open;
    tmpSQL:='';
    tmpSQL1:='';
    While Not MenuQuery.Eof Do
    Begin
      If MenuQuery.FieldByName(GPT.DCLTextField).AsString<>'' Then
        tmpSQL:=MenuQuery.FieldByName(GPT.DCLTextField).AsString
      Else
        tmpSQL:=TrimRight(MenuQuery.FieldByName(GPT.DCLNameField).AsString);
      If PosEx('select', tmpSQL)<>0 Then
      Begin
        If PosEx('from', tmpSQL)<>0 Then
        Begin
          DCLQuery:=TDCLDialogQuery.Create(Nil);
          DCLQuery.Name:='Menu20051_'+IntToStr(UpTime);
          DCLQuery.SQL.Text:=tmpSQL;
          FDCLLogOn.SetDBName(DCLQuery);
          DCLQuery.Open;
          tmpSQL1:=tmpSQL1+TrimRight(DCLQuery.Fields[0].AsString);
          DCLQuery.Close;
          FreeAndNil(DCLQuery);
        End;
      End
      Else
        tmpSQL1:=tmpSQL1+tmpSQL;
      MenuQuery.Next;
    End;
    Form.Caption:=Form.Caption+tmpSQL1;
  End;
  MenuQuery.Close;

  MenuQuery.SQL.Text:=FDCLLogOn.GetRolesQueryText(qtCount, ' s.'+GPT.IdentifyField+
    ' between 40001 and 40100');

  RecCount:=0;
  DebugProc('Selecting components(40001):');
  DebugProc('  Query: '+MenuQuery.SQL.Text);
  Try
    DebugProc('  ... selected');
    MenuQuery.Open;
    RecCount:=MenuQuery.Fields[0].AsInteger;
    DebugProc('  ... OK');
  Except
    DebugProc('  ... Fail');
  End;

  If RecCount>0 Then
  Begin
    FDCLLogOn.RunInitSkripts;
  End;
  MenuQuery.Close;

  MenuQuery.SQL.Text:='select Count(*) from '+GPT.DCLTable+' where '+GPT.IdentifyField+'=50000';
  RecCount:=0;
  DebugProc('Selecting components(50000):');
  DebugProc('  Query: '+MenuQuery.SQL.Text);
  Try
    DebugProc('  ... selected');
    MenuQuery.Open;
    RecCount:=MenuQuery.Fields[0].AsInteger;
    DebugProc('  ... OK');
  Except
    DebugProc('  ... Fail');
  End;
  If RecCount>0 Then
  Begin
    For RecCount:=1 To 4 Do
      ProgrammCompVer[RecCount]:=StrToInt(SortParams(CompotableVersion, RecCount, '.'));

    MenuQuery.Close;
    MenuQuery.SQL.Text:='select '+GPT.DCLNameField+' from '+GPT.DCLTable+' where '+
      GPT.IdentifyField+'=50000';
    MenuQuery.Open;
    tmpSQL:=Trim(MenuQuery.FieldByName(GPT.DCLNameField).AsString);
    If length(tmpSQL)>=11 Then
      For RecCount:=1 To 4 Do
        BaseCompVer[RecCount]:=StrToInt(SortParams(tmpSQL, RecCount, '.'));

    For RecCount:=1 To 4 Do
      If ProgrammCompVer[RecCount]<BaseCompVer[RecCount] Then
      Begin
        If RecCount=1 Then
          ShowErrorMessage(1,
            SourceToInterface(GetDCLMessageString(msVersionsGap)))
        Else
          ShowErrorMessage(1,
            SourceToInterface(GetDCLMessageString(msOldVersion)));

        break;
      End
      Else If ProgrammCompVer[RecCount]>BaseCompVer[RecCount] Then
        break;
  End;
  MenuQuery.Close;

  FreeAndNil(MenuQuery);
end;

function TDCLMainMenu.FindMenuItemIndex(ItemName: string): Integer;
var
  v1: Integer;
begin
  Result:=-1;
  for v1:=0 to FMainMenu.Items.Count-1 do
    If CompareString(ItemName, FMainMenu.Items[v1].Name) then
    Begin
      Result:=v1;
      break;
    End;
end;

function TDCLMainMenu.FindSubMenuItemIndex(ItemName: string; Level: Integer): Integer;
var
  v1: Integer;
begin
  Result:=-1;
  for v1:=0 to FMainMenu.Items[Level].Count-1 do
    If CompareString(ItemName, FMainMenu.Items[Level][v1].Name) then
    Begin
      Result:=v1;
      break;
    End;
end;

procedure TDCLMainMenu.LockMenu;
var
  ItemCounter: Integer;
begin
  If Assigned(FMainForm) Then
    For ItemCounter:=0 To FMainMenu.Items.Count-1 Do
      FMainMenu.Items[ItemCounter].Enabled:=False;
end;

procedure TDCLMainMenu.UnLockMenu;
var
  ItemCounter: Integer;
begin
  If Assigned(FMainForm) Then
    For ItemCounter:=0 To FMainMenu.Items.Count-1 Do
      FMainMenu.Items[ItemCounter].Enabled:=true;
end;

{ TDCLGrid }

procedure TDCLGrid.AddBrushColor(OPL: String);
var
  l: Word;
  v1, v2: Integer;
  TmpStr, tmpStr2, BrushKey, Colors: String;
begin
  l:=length(BrushColors);
  SetLength(BrushColors, l+1);

  BrushKey:=FindParam('BrushKey=', OPL);
  Colors:=FindParam('Color=', OPL);

  For v1:=1 To ParamsCount(Colors) Do
  Begin
    TmpStr:=SortParams(Colors, v1);
    // RePlaseVariables(tmpStr3);
    v2:=Pos('=', TmpStr);
    tmpStr2:=Copy(TmpStr, v2+1, Length(TmpStr)-v2+1);
    // RePlaseVariables(tmpSQL2);
    Case IsDigit(tmpStr2) Of
    idDigit:
    BrushColors[l].Color:=StrToIntEx(tmpStr2);
    idHex:
    BrushColors[l].Color:=HexToInt(tmpStr2);
    idColor:
    BrushColors[l].Color:=StringToColor(tmpStr2);
    End;
    BrushColors[l].Value:=Copy(TmpStr, 1, v2-1);
    BrushColors[l].Key:=BrushKey;
    If Not FieldExists(BrushColors[l].Key, FQuery) Then
    Begin
      DebugProc('//!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
      DebugProc('В предложении Color=, указанно несуществующее поле : '+BrushColors[l].Key);
      DebugProc(OPL);
      DebugProc('//!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
    End;
  End;
end;

procedure TDCLGrid.AddCalendar(Calendar: RCalendar);
var
  l: Integer;
begin
  l:=length(Calendars);
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

procedure TDCLGrid.AddCheckBox(var Field: RField);
Var
  l: Integer;
begin
  Field.CurrentEdit:=true;
  l:=length(CheckBoxes);
  SetLength(CheckBoxes, l+1);
  Field.CurrentEdit:=true;

  CheckBoxes[l].CheckBox:=TCheckbox.Create(FieldPanel);
  CheckBoxes[l].CheckBox.Parent:=FieldPanel;

  CheckBoxes[l].CheckBox.Name:='CheckBox_'+IntToStr(l);
  CheckBoxes[l].CheckBox.Caption:=Field.Caption;
  CheckBoxes[l].CheckBoxToFields:=Field.FieldName;

  If Field.Hint<>'' Then
  Begin
    CheckBoxes[l].CheckBox.ShowHint:=true;
    CheckBoxes[l].CheckBox.Hint:=Field.Hint;
  End;

  If Field.Variable<>'' Then
    FDCLLogOn.Variables.NewVariable(Field.Variable)
  Else
  Begin
    FDCLLogOn.Variables.NewVariable('CheckBox_'+Field.FieldName);
    Field.Variable:='CheckBox_'+Field.FieldName;
  End;

  CheckBoxes[l].CheckBoxToVars:=Field.Variable;
  CheckBoxes[l].CheckBox.Checked:=False;
  If PosEx('_OnCheck;', Field.OPL)<>0 Then
    CheckBoxes[l].CheckBox.Checked:=true;

  CheckBoxes[l].CheckBox.Tag:=l;
  CheckBoxes[l].CheckBox.OnClick:=CheckOnClick;
  CheckBoxes[l].CheckBox.Left:=Field.Left;
  CheckBoxes[l].CheckBox.Top:=Field.Top;
  CheckBoxes[l].CheckBox.Width:=EditWidth;

  Case CheckBoxes[l].CheckBox.Checked Of
  true:
  FDCLLogOn.Variables.Variables[Field.Variable]:='1';
  False:
  FDCLLogOn.Variables.Variables[Field.Variable]:='0';
  End;
  IncXYPos(EditTopStep, EditWidth, Field);
end;

procedure TDCLGrid.AddColumn(Field: RField);
var
  Col: TColumn;
begin
  If Assigned(FGrid) then
  Begin
    Col:=FGrid.Columns.Add;
    Col.FieldName:=Field.FieldName;
    Col.Title.Caption:=Field.Caption;
    If Col.Width>ColumnsLongerThis Then
      Col.Width:=DefaultColumnSize;

    If Field.Width<>0 then
      Col.Width:=Field.Width;

    Col.ReadOnly:=Field.ReadOnly;
  End;
end;

procedure TDCLGrid.AddContextButton(var Field: RField);
var
  l: Word;
  TempStr: string;
begin
  l:=length(ContextFieldButtons);
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
  ContextFieldButtons[l].Button.ShowHint:=true;
  ContextFieldButtons[l].Button.OnClick:=ContextFieldButtonsClick;

  TempStr:=FindParam('CommandName=', Field.OPL);
  If TempStr<>'' Then
  Begin
    ContextFieldButtons[l].Command:=TempStr;
  End;
end;

procedure TDCLGrid.AddContextList(var Field: RField);
var
  l: Word;
  ShadowQuery: TDCLDialogQuery;
begin
  l:=length(ContextLists);
  SetLength(ContextLists, l+1);
  Field.CurrentEdit:=true;

  ContextLists[l].ContextList:=TComboBox.Create(FieldPanel);
  If FindParam('ComponentName=', Field.OPL)<>'' then
    ContextLists[l].ContextList.Name:=FindParam('ComponentName=', Field.OPL)
  Else
    ContextLists[l].ContextList.Name:='ContextList'+IntToStr(l);
  ContextLists[l].ContextList.Parent:=FieldPanel;
  ContextLists[l].ContextList.Tag:=l;
  ContextLists[l].ContextList.Text:='';
  ContextLists[l].ContextList.Top:=Field.Top;
  ContextLists[l].ContextList.Left:=Field.Left;
  if Field.IsFieldWidth then
    ContextLists[l].ContextList.Width:=Field.Width
  Else
    ContextLists[l].ContextList.Width:=EditWidth;
  ContextLists[l].ContextList.Hint:=Field.Hint;
  ContextLists[l].ContextList.ShowHint:=true;

  ContextLists[l].Table:=FindParam('ContextListTable=', Field.OPL);
  ContextLists[l].Field:=FindParam('ContextListField=', Field.OPL);
  ContextLists[l].KeyField:=FindParam('ContextListKey=', Field.OPL);
  If FindParam('ContextListData=', Field.OPL)<>'' then
    ContextLists[l].ListField:=FindParam('ContextListData=', Field.OPL)
  Else
    ContextLists[l].ListField:=ContextLists[l].Field;

  ContextLists[l].DataField:=Field.FieldName;

  ShadowQuery:=TDCLDialogQuery.Create(Nil);
  ShadowQuery.Name:='ContextList_'+IntToStr(UpTime);
  FDCLLogOn.SetDBName(ShadowQuery);

  ShadowQuery.SQL.Text:='select '+ContextLists[l].Field+' from '+ContextLists[l].Table+' order by '+
    ContextLists[l].Field;
  ShadowQuery.Open;
  ShadowQuery.First;

  ContextLists[l].ContextList.Items.Clear;
  While Not ShadowQuery.Eof Do
  Begin
    If Trim(ShadowQuery.FieldByName(ContextLists[l].Field).AsString)<>'' Then
      ContextLists[l].ContextList.Items.Append
        (Trim(ShadowQuery.FieldByName(ContextLists[l].Field).AsString));
    ShadowQuery.Next;
  End;
  ShadowQuery.Close;
  FreeAndNil(ShadowQuery);

  ContextLists[l].ContextList.OnKeyDown:=ContextListKeyDown;
  ContextLists[l].ContextList.OnSelect:=ContextListChange;

  IncXYPos(EditTopStep, ContextLists[l].ContextList.Width, Field);
end;

procedure TDCLGrid.AddDateBox(var Field: RField);
Var
  NeedValue, DateBoxCount: Word;
  TempStr, KeyField: String;
  ShadowQuery: TDCLDialogQuery;
begin
  DateBoxCount:=length(DateBoxes);
  SetLength(DateBoxes, DateBoxCount+1);
  Field.CurrentEdit:=true;
  DateBoxes[DateBoxCount].DateBox:=DateTimePicker.Create(FieldPanel);

  If FindParam('ComponentName=', Field.OPL)='' Then
    DateBoxes[DateBoxCount].DateBox.Name:='DateBox_'+Field.FieldName
  Else
    DateBoxes[DateBoxCount].DateBox.Name:=FindParam('ComponentName=', Field.OPL);

  If Field.Hint<>'' Then
  Begin
    DateBoxes[DateBoxCount].DateBox.ShowHint:=true;
    DateBoxes[DateBoxCount].DateBox.Hint:=Field.Hint;
  End;

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

  DateBoxes[DateBoxCount].DateBox.Top:=Field.Top;
  DateBoxes[DateBoxCount].DateBox.Left:=Field.Left;
  If FindParam('Disabled=', Field.OPL)='1' Then
    DateBoxes[DateBoxCount].DateBox.Enabled:=False;
  NeedValue:=0;
  If FindParam('_Value=', Field.OPL)<>'' Then
    NeedValue:=1;
  If FindParam('SQL=', Field.OPL)<>'' Then
    NeedValue:=2;

  TempStr:='';
  Case NeedValue Of
  0:
  If Query.Active Then
  Begin
    If FieldExists(Field.FieldName, Query) Then
      TempStr:=TrimRight(Query.FieldByName(Field.FieldName).AsString);
  End
  Else
    TempStr:=DateToStr(Date);
  1:
  Begin
    TempStr:=FindParam('_Value=', Field.OPL);
    RePlaseParams(TempStr);
    FDCLLogOn.RePlaseVariables(TempStr);
  End;
  2:
  Begin
    ShadowQuery:=TDCLDialogQuery.Create(Nil);
    ShadowQuery.Name:='DateBoxQ_'+IntToStr(UpTime);
    FDCLLogOn.SetDBName(ShadowQuery);
    TempStr:=FindParam('SQL=', Field.OPL);
    FDCLLogOn.RePlaseVariables(TempStr);
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
  End;
  End;

  If FindParam('VariableName=', Field.OPL)<>'' Then
  Begin
    FDCLLogOn.Variables.NewVariable(FindParam('VariableName=', Field.OPL), TempStr);
    KeyField:=FindParam('VariableName=', Field.OPL);
  End
  Else
  Begin
    FDCLLogOn.Variables.NewVariable('DateBox_'+Field.FieldName, TempStr);
    KeyField:='DateBox_'+Field.FieldName;
  End;

  DateBoxes[DateBoxCount].DateBoxToVariables:=KeyField;
  If TempStr<>'' then
    DateBoxes[DateBoxCount].DateBox.Date:=StrToDate(TempStr);

  IncXYPos(EditTopStep, DateBoxes[DateBoxCount].DateBox.Width, Field);
end;

procedure TDCLGrid.AddDBCheckBox(var Field: RField);
var
  l: Word;
begin
  l:=length(DBCheckBoxes);
  SetLength(DBCheckBoxes, l+1);
  DBCheckBoxes[l]:=TDBCheckBox.Create(FieldPanel);
  DBCheckBoxes[l].Parent:=FieldPanel;
  DBCheckBoxes[l].Left:=Field.Left;
  DBCheckBoxes[l].Top:=Field.Top;
  If Field.Width<>0 Then
    DBCheckBoxes[l].Width:=Field.Width
  Else
    DBCheckBoxes[l].Width:=CheckWidth;
  DBCheckBoxes[l].ShowHint:=true;
  DBCheckBoxes[l].Hint:=Field.Hint;
  DBCheckBoxes[l].Caption:=Field.Caption;
  DBCheckBoxes[l].ReadOnly:=Field.ReadOnly;

  DBCheckBoxes[l].DataSource:=FData;
  DBCheckBoxes[l].DataField:=Field.FieldName;

  If Field.CheckValue<>'' Then
    DBCheckBoxes[l].ValueChecked:=Field.CheckValue;
  If Field.UnCheckValue<>'' Then
    DBCheckBoxes[l].ValueUnchecked:=Field.UnCheckValue;

  IncXYPos(EditTopStep, DBCheckBoxes[l].Width, Field);
end;

procedure TDCLGrid.AddDBFilter(Filter: TDBFilter);
var
  l: Integer;
  Key: Word;
begin
  l:=length(DBFilters);
  SetLength(DBFilters, l+1);

  DBFilters[l].FilterNum:=l;
  DBFilters[l].FilterName:='DBFilter'+IntToStr(l);
  DBFilters[l].Field:=Filter.Field;
  DBFilters[l].VarName:=Filter.VarName;
  DBFilters[l].MaxLength:=Filter.MaxLength;
  DBFilters[l].FilterType:=Filter.FilterType;

  AddToolPanel;

  LabelField:=TDialogLabel.Create(ToolPanel);
  LabelField.Parent:=ToolPanel;
  LabelField.Top:=FilterLabelTop;
  LabelField.Left:=BeginStepLeft+ToolPanelElementLeft;
  LabelField.Caption:=InitCap(Filter.Caption);

  If Filter.FilterType=ftDBFilter then
  Begin
    DBFilters[l].CaseC:=False;
    DBFilters[l].NotLike:=true;
    DBFilters[l].FilterString:='';

    DBFilters[l].FilterQuery:=TDCLDialogQuery.Create(Nil);
    DBFilters[l].FilterQuery.Name:='DBFilterQ_'+IntToStr(UpTime);
    FDCLLogOn.SetDBName(DBFilters[l].FilterQuery);
    DBFilters[l].FilterData:=TDataSource.Create(Nil);
    DBFilters[l].FilterData.DataSet:=DBFilters[l].FilterQuery;
    DBFilters[l].FilterQuery.Tag:=l;
    DBFilters[l].FilterQuery.SQL.Text:=Filter.SQL;

    Try
      DBFilters[l].FilterQuery.Open;
      DBFilters[l].FilterQuery.Last;
      DBFilters[l].FilterQuery.First;
    Except
      ShowErrorMessage(-1116, 'SQL='+DBFilters[l].SQL);
    End;

    DBFilters[l].Lookup:=TDBLookupComboBox.Create(ToolPanel);
    DBFilters[l].Lookup.Parent:=ToolPanel;
    DBFilters[l].Lookup.Top:=FilterTop;
    DBFilters[l].Lookup.Tag:=l;

    DBFilters[l].Lookup.Left:=BeginStepLeft+ToolPanelElementLeft;
    DBFilters[l].Lookup.Name:='DBFilter'+IntToStr(l);
    DBFilters[l].Lookup.ListField:=Filter.ListField;
    DBFilters[l].Lookup.KeyField:=Filter.KeyField;

    If DBFilters[l].VarName<>'' then
      FDCLLogOn.Variables.Variables[DBFilters[l].VarName]:=
        TrimRight(DBFilters[l].FilterQuery.FieldByName(DBFilters[l].Lookup.KeyField).AsString);

    DBFilters[l].Lookup.ListSource:=DBFilters[l].FilterData;
    DBFilters[l].FilterKey:=DBFilters[l].Lookup.KeyField;

    DBFilters[l].Lookup.Width:=Filter.Width;
    DBFilters[l].Lookup.ListField:=Filter.ListField+';'+Filter.KeyField;

{$IFDEF FPC}
    DBFilters[l].Lookup.OnSelect:=ExecFilter;
{$ELSE}
    DBFilters[l].Lookup.OnClick:=ExecFilter;
{$ENDIF}
  End;
  If Filter.FilterType=ftContextFilter then
  Begin
    DBFilters[l].CaseC:=Filter.CaseC;
    DBFilters[l].NotLike:=Filter.NotLike;

    DBFilters[l].WaitForKey:=Filter.WaitForKey;
    DBFilters[l].Edit:=TEdit.Create(ToolPanel);
    DBFilters[l].Edit.Parent:=ToolPanel;
    DBFilters[l].FilterName:=Filter.FilterName;

    If Filter.FilterName<>'' then
      DBFilters[l].Edit.Name:=Filter.FilterName
    Else
      DBFilters[l].Edit.Name:='ContextFilter_'+IntToStr(l);

    DBFilters[l].Edit.Text:='';
    DBFilters[l].Edit.Top:=FilterTop;
    DBFilters[l].Edit.Left:=BeginStepLeft+ToolPanelElementLeft;
    DBFilters[l].Edit.Tag:=l;
    DBFilters[l].Edit.Width:=Filter.Width;
    DBFilters[l].Edit.OnKeyUp:=OnContextFilter;

    DBFilters[l].Field:=Filter.Field;
  End;

  Case Filter.FilterType of
  ftDBFilter:
  ToolPanelElementLeft:=ToolPanelElementLeft+ToolLeftInterval+DBFilters[l].Lookup.Width;
  ftContextFilter:
  ToolPanelElementLeft:=ToolPanelElementLeft+ToolLeftInterval+DBFilters[l].Edit.Width;
  End;

  Case Filter.FilterType of
  ftDBFilter:
  Begin
    If Filter.KeyValue<>'' Then
    Begin
      Try
        DBFilters[l].Lookup.KeyValue:=Filter.KeyValue;
        ExecFilter(DBFilters[l].Lookup);
      Except
        //
      End;
    End
    Else
    Begin
      Try
        DBFilters[l].Lookup.KeyValue:='-1';
      Except
        //
      End;
    End;
  End;
  ftContextFilter:
  Begin
    If Filter.KeyValue<>'' Then
    Begin
      FDCLLogOn.RePlaseVariables(Filter.KeyValue);
      DBFilters[l].Edit.Text:=Filter.KeyValue;
      Key:=13;
      OnContextFilter(DBFilters[l].Edit, Key, []);
    End;
  End;
  End;
end;

procedure TDCLGrid.AddDropBox(var Field: RField);
var
  l: Word;
  ShadowQuery: TDCLDialogQuery;
  TmpStr, tmpStr1, tmpSQL1: String;
  DropListValues: TDBComboBox;
  DropList: TCustomComboBox;
  v1, v2: Integer;
begin
  If FDisplayMode in TDataGrid then
  Begin
    TmpStr:=FindParam('DropListBox=', Field.OPL);
    TranslateVal(TmpStr);
    If TmpStr<>'' Then
    Begin
      Show;
      v2:=ParamsCount(TmpStr);
      For v1:=1 To v2 Do
      Begin
        tmpStr1:=SortParams(TmpStr, v1);
        If tmpStr1='' Then
          tmpStr1:='';
        FGrid.Columns[FGrid.Columns.Count-1].PickList.Append(tmpStr1);
      End;
    End;

    tmpSQL1:=FindParam('SQL=', Field.OPL);
    If tmpSQL1<>'' Then
    Begin
      ShadowQuery:=TDCLDialogQuery.Create(Nil);
      ShadowQuery.Name:='GroupBoxQ_'+IntToStr(UpTime);
      FDCLLogOn.SetDBName(ShadowQuery);

      TranslateVal(tmpSQL1);
      ShadowQuery.SQL.Text:=tmpSQL1;
      Try
        ShadowQuery.Open;

        While Not ShadowQuery.Eof Do
        Begin
          If Trim(ShadowQuery.Fields[0].AsString)<>'' Then
            FGrid.Columns[FGrid.Columns.Count-1].PickList.Append
              (Trim(ShadowQuery.Fields[0].AsString))
          Else
            FGrid.Columns[FGrid.Columns.Count-1].PickList.Append(' ');
          ShadowQuery.Next;
        End;
        ShadowQuery.Close;
        FreeAndNil(ShadowQuery);
      Except
        ShowErrorMessage(-1107, 'SQL='+tmpSQL1);
      End;
    End;
  End;

  If FDisplayMode in TDataFields then
  Begin
    l:=length(DropBoxes);
    SetLength(DropBoxes, l+1);
    Field.CurrentEdit:=true;

    TmpStr:=FindParam('SetIndexValue=', Field.OPL);
    If (TmpStr='1')Or Not FQuery.Active Then
    Begin
      DropBoxes[l].DropList:=TComboBox.Create(FieldPanel);
      DropBoxes[l].DropList.Parent:=FieldPanel;
      DropBoxes[l].DropList.Name:='DropListBox_'+Field.FieldName;
      DropBoxes[l].DropList.Tag:=l;

      DropBoxes[l].FieldName:=Field.FieldName;
      DropBoxes[l].DropList.Top:=Field.Top;
      DropBoxes[l].DropList.Left:=Field.Left;

      DropBoxes[l].DropList.OnSelect:=DropListOnSelectItem;

      DropBoxes[l].DropList.Clear;
      DropList:=DropBoxes[l].DropList;

      If FindParam('VariableName=', Field.OPL)<>'' Then
      Begin
        tmpStr1:=FindParam('VariableName=', Field.OPL);
        DropBoxes[l].Variable:=tmpStr1;
        FDCLLogOn.Variables.NewVariable(tmpStr1);
      End;
    End
    Else
    Begin
      DropListValues:=TDBComboBox.Create(FieldPanel);
      DropListValues.Parent:=FieldPanel;
      DropListValues.DataSource:=FData;
      DropListValues.DataField:=Field.FieldName;
      DropListValues.Name:='DropListBox_'+Field.FieldName;
      DropListValues.Top:=Field.Top;
      DropListValues.Left:=Field.Left;

      DropListValues.Clear;
      DropList:=DropListValues;

      tmpSQL1:=FindParam('SQL=', Field.OPL);
      If tmpSQL1<>'' Then
      Begin
        ShadowQuery:=TDCLDialogQuery.Create(Nil);
        ShadowQuery.Name:='DropBoxQ_'+IntToStr(UpTime);
        FDCLLogOn.SetDBName(ShadowQuery);

        TranslateVal(tmpSQL1);
        ShadowQuery.SQL.Text:=tmpSQL1;
        Try
          ShadowQuery.Open;

          While Not ShadowQuery.Eof Do
          Begin
            TmpStr:=Trim(ShadowQuery.Fields[0].AsString);
            If TmpStr='' Then
              TmpStr:='';
            DropList.Items.Append(TmpStr);

            ShadowQuery.Next;
          End;
          ShadowQuery.Close;
          FreeAndNil(ShadowQuery);
        Except
          ShowErrorMessage(-1107, 'SQL='+tmpSQL1);
        End;
      End;
    End;

    If Field.IsFieldWidth then
      DropList.Width:=Field.Width
    Else
      DropList.Width:=EditWidth;

    TmpStr:=FindParam('List=', Field.OPL);
    TranslateVal(TmpStr);
    v2:=ParamsCount(TmpStr);
    For v1:=1 To v2 Do
    Begin
      tmpStr1:=SortParams(TmpStr, v1);
      If tmpStr1='' Then
        tmpStr1:=' ';
      DropList.Items.Append(tmpStr1);
    End;

    If FQuery.Active Then
    Begin
      If FindParam('SetIndexValue=', Field.OPL)='1' Then
      Begin
        DropList.ItemIndex:=FQuery.FieldByName(Field.FieldName).AsInteger;
      End;
    End
    Else
      DropList.ItemIndex:=StrToIntEx(FindParam('SetIndexValue=', Field.OPL));

    IncXYPos(EditTopStep, DropList.Width, Field);
  End;
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
  Begin
    EditField.Hint:=Field.Hint;
    EditField.ShowHint:=true;
  End;
  EditField.Top:=Field.Top;
  EditField.Left:=Field.Left;
  If Field.ReadOnly Then
    EditField.ReadOnly:=true;
  If Field.Width=0 Then
    Field.Width:=EditWidth;
  EditField.Width:=Field.Width;
  Field.CurrentEdit:=False;

  IncXYPos(EditTopStep, Field.Width, Field);
end;

procedure TDCLGrid.AddField(Field: RField);
var
  i: Integer;
begin
  i:=length(DataFields);
  SetLength(DataFields, i+1);
  DataFields[i].Name:=Field.FieldName;
  DataFields[i].Caption:=Field.Caption;
  DataFields[i].Width:=Field.Width;
end;

procedure TDCLGrid.AddFieldBox(var Field: RField; FieldBoxType: TFieldBoxType; NamePrefix: String);
Var
  TempStr, KeyField: String;
  NeedValue: Byte;
  ShadowQuery: TDCLDialogQuery;
  EditsCount: Word;
begin
  EditsCount:=length(Edits);
  SetLength(Edits, EditsCount+1);
  Field.CurrentEdit:=true;
  Edits[EditsCount].Edit:=TEdit.Create(FieldPanel);

  If FindParam('ComponentName=', Field.OPL)='' Then
    Edits[EditsCount].Edit.Name:=NamePrefix+Field.FieldName
  Else
    Edits[EditsCount].Edit.Name:=FindParam('ComponentName=', Field.OPL);

  If Field.Hint<>'' Then
  Begin
    Edits[EditsCount].Edit.ShowHint:=true;
    Edits[EditsCount].Edit.Hint:=Field.Hint;
  End;

  Edits[EditsCount].Edit.PasswordChar:=Field.PasswordChar;
  Edits[EditsCount].EditsPasswordChar:=Field.PasswordChar;

  Edits[EditsCount].Edit.CharCase:=Field.CharCase;

  Edits[EditsCount].Edit.Tag:=EditsCount;
  Edits[EditsCount].EditsToFields:=Field.FieldName;
  Edits[EditsCount].Edit.Parent:=FieldPanel;
  Edits[EditsCount].Edit.OnClick:=EditClick;

  If Field.IsFieldWidth Then
    Edits[EditsCount].Edit.Width:=Field.Width
  Else
    Edits[EditsCount].Edit.Width:=EditWidth;

  If FieldBoxType<>fbtOutBox then
  Begin
    Edits[EditsCount].EditsToFloat:=False;
    TempStr:=FindParam('Format=', Field.OPL);
    If LowerCase(TempStr)='float' Then
    Begin
      Edits[EditsCount].EditsToFloat:=true;
      Edits[EditsCount].Edit.OnKeyPress:=EditOnFloatData;
    End;
  End
  Else
    Edits[EditsCount].Edit.ReadOnly:=true;

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
    If FindParam('_Value=', Field.OPL)<>'' Then
      NeedValue:=1
    Else
      NeedValue:=3;
  If FindParam('SQL=', Field.OPL)<>'' Then
    NeedValue:=2;

  TempStr:='';
  Case NeedValue Of
  0:
  If FQuery.Active Then
    If FieldExists(Field.FieldName, FQuery) Then
      TempStr:=TrimRight(FQuery.FieldByName(Field.FieldName).AsString);
  1:
  Begin
    TempStr:=FindParam('_Value=', Field.OPL);
    RePlaseParams(TempStr);
    FDCLForm.RePlaseVariables(TempStr);
  End;
  2:
  Begin
    ShadowQuery:=TDCLDialogQuery.Create(Nil);
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
  End;
  3:
  TempStr:='';
  End;

  If FindParam('VariableName=', Field.OPL)<>'' Then
    KeyField:=FindParam('VariableName=', Field.OPL)
  Else
    KeyField:=NamePrefix+Field.FieldName;

  FDCLForm.LocalVariables.NewVariable(KeyField);

  Edits[EditsCount].EditToVariables:=KeyField;
  FDCLForm.LocalVariables.Variables[KeyField]:=TempStr;
  Edits[EditsCount].Edit.Text:=TempStr;

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
  TempStr: string;
  ShadowQuery: TDCLDialogQuery;
begin
  l:=length(Lookups);
  SetLength(Lookups, l+1);
  Field.CurrentEdit:=true;

  TempStr:=FindParam('SQL=', Field.OPL);
  If TempStr='' then
    TempStr:=FindParam('QueryLookup=', Field.OPL);
  If TempStr<>'' Then
  Begin
    Lookups[l].LookupQuery:=TDCLDialogQuery.Create(Nil);
    Lookups[l].LookupQuery.Name:='LookupQ_'+IntToStr(UpTime);
    Lookups[l].LookupQuery.Tag:=l;
    FDCLLogOn.SetDBName(Lookups[l].LookupQuery);
    TranslateVal(TempStr);
    Lookups[l].LookupQuery.SQL.Text:=TempStr;
    Lookups[l].LookupQuery.AfterScroll:=LookupDBScroll;
    Try
      Lookups[l].LookupQuery.Open;
      Lookups[l].LookupQuery.Last;
      Lookups[l].LookupQuery.First;
    Except
      ShowErrorMessage(-1115, 'SQL='+TempStr);
    End;
    Lookups[l].LookupData:=TDataSource.Create(Nil);
    Lookups[l].LookupData.Tag:=l;
    Lookups[l].LookupData.DataSet:=Lookups[l].LookupQuery;
  End
  Else
    ShowErrorMessage(-3000, '');

  Lookups[l].Lookup:=TDBLookupComboBox.Create(FieldPanel);
  Lookups[l].Lookup.Parent:=FieldPanel;
  Lookups[l].Lookup.Name:='LookUpField_'+IntToStr(l);
  Lookups[l].Lookup.Tag:=l;

  Lookups[l].Lookup.ShowHint:=true;
  Lookups[l].Lookup.Hint:=Field.Hint;

  If FQuery.Active Then
  Begin
    If FindParam('NoDataField=', Field.OPL)<>'1' Then
    Begin
      If not FForm.Showing then
        FForm.Show;
      NoDataField:=False;
      Lookups[l].Lookup.DataSource:=FData;
      Lookups[l].Lookup.DataField:=Field.FieldName;
    End
    Else
      NoDataField:=true;
  End
  Else
    NoDataField:=true;

  Lookups[l].Lookup.ReadOnly:=Field.ReadOnly;
  Lookups[l].Lookup.ListSource:=Lookups[l].LookupData;
  Lookups[l].Lookup.Top:=Field.Top;
  Lookups[l].Lookup.Left:=Field.Left;
  If Field.IsFieldWidth then
    Lookups[l].Lookup.Width:=Field.Width
  Else
    Lookups[l].Lookup.Width:=EditWidth;

  TempStr:=FindParam('VariableName=', Field.OPL);
  If TempStr<>'' Then
  Begin
    FDCLLogOn.Variables.NewVariable(TempStr);
    Lookups[l].LookupToVars:=TempStr;
  End;

  Lookups[l].Lookup.KeyField:=FindParam('Key=', Field.OPL);
  Lookups[l].Lookup.ListField:=FindParam('List=', Field.OPL);

{$IFDEF FPC}
  Lookups[l].Lookup.OnSelect:=LookupOnClick;
{$ELSE}
  Lookups[l].Lookup.OnClick:=LookupOnClick;
{$ENDIF}
  TempStr:=FindParam('ModifyingEdit=', Field.OPL);
  If TempStr<>'' Then
    Lookups[l].ModifyEdits:=SortParams(TempStr, 1);

  TempStr:=FindParam('KeyValue=', Field.OPL);
  Lookups[l].LookupQuery.First;
  If TempStr<>'' Then
  Begin
    TranslateVal(TempStr);
    If PosEx('select ', TempStr)<>0 Then
      If PosEx(' from ', TempStr)<>0 Then
      Begin
        ShadowQuery:=TDCLDialogQuery.Create(Nil);
        ShadowQuery.Name:='LookupShadow_'+IntToStr(UpTime);
        FDCLLogOn.SetDBName(ShadowQuery);
        ShadowQuery.SQL.Text:=TempStr;
        Try
          ShadowQuery.Open;
          TempStr:=ShadowQuery.Fields[0].AsString;
          ShadowQuery.Close;
          // If tmpSQL='' then tmpSQL:='-1';
        Except
          ShowErrorMessage(-1117, 'SQL='+TempStr);
        End;
        FreeAndNil(ShadowQuery);
      End;
    If TempStr<>'' Then
    Begin
      If (not(FQuery.State in [dsInsert, dsEdit]))and FQuery.Active and(not NoDataField) then
        Query.Edit;
      Lookups[l].Lookup.KeyValue:=TempStr;
      LookupOnClick(Lookups[l].Lookup);
    End;
  End;

  IncXYPos(EditTopStep, Lookups[l].Lookup.Width, Field);
end;

procedure TDCLGrid.AddLookupTable(var Field: RField);
var
  l, FFactor: Word;
  TempStr, TmpStr, FieldName: string;
  v1, v2: Integer;
  FField: RField;
begin
  l:=length(LookupTables);
  SetLength(LookupTables, l+1);
  Field.CurrentEdit:=true;

  if not Field.IsFieldHeight then
    Field.Height:=LookupTableHeight;

  If not Field.IsFieldWidth then
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
  TranslateProc(TempStr, FFactor);
  LookupTables[l].DCLGrid.SetSQL(TempStr);
  LookupTables[l].DCLGrid.ReadOnly:=Field.ReadOnly;
  LookupTables[l].DCLGrid.DependField:=FindParam('DependField=', Field.OPL);
  LookupTables[l].DCLGrid.MasterDataField:=Field.FieldName;

  If FQuery.Active then
    LookupTables[l].DCLGrid.Open;
  LookupTables[l].DCLGrid.Show;

  TempStr:=FindParam('Columns=', Field.OPL);
  If TempStr<>'' Then
  Begin
    LookupTables[l].DCLGrid.Columns.Clear;
    v1:=ParamsCount(TempStr);
    For v2:=1 To v1 Do
    Begin
      TmpStr:=SortParams(TempStr, v2);
      FieldName:=Copy(TmpStr, 1, Pos('/', TmpStr)-1);
      ResetFieldParams(FField);
      If FieldExists(FieldName, LookupTables[l].DCLGrid.Query) Then
      Begin
        FField.FType:=LookupTables[l].DCLGrid.Query.FieldByName(FieldName).DataType;
        FField.FieldName:=FieldName;
        FField.Caption:=Copy(TmpStr, Pos('/', TmpStr)+1, length(TmpStr)-1);
      End
      Else
      Begin
        FField.Caption:=SourceToInterface(GetDCLMessageString(msNoField))+Field.FieldName;
      End;
      LookupTables[l].DCLGrid.AddColumn(FField);
    End;
  End;

  IncXYPos(EditTopStep, LookupTables[l].LookupPanel.Width, Field);
end;

procedure TDCLGrid.AddMediaFieldGroup(Parent: TWinControl; Align: TAlign; GroupType: TGroupType;
  var Field: RField);
var
  l: Word;
begin
  l:=length(MediaFields);
  SetLength(MediaFields, l+1);
  MediaFields[l]:=TFieldGroup.Create(Parent, FData, Field, Align, GroupType);

  IncXYPos(EditTopStep, Field.Width, Field);
end;

function TDCLGrid.AddPartPage(Caption: string; Data: TDataSource): Integer;
var
  Pc: Integer;
begin
  If Not Assigned(FTablePartsPages) Then
  Begin
    FTablePartsPages:=TPageControl.Create(FGridPanel);
    FTablePartsPages.Parent:=FGridPanel;
    FTablePartsPages.Top:=5;
    FTablePartsPages.OnChange:=ChangeTabPage;
    FTablePartsPages.Tag:=2;
    FTablePartsPages.Height:=350;
    FTablePartsPages.Align:=alBottom;
  End;

  Pc:=FTablePartsPages.PageCount;
  FTablePartsTabs:=TTabSheet.Create(FTablePartsPages);
  If Caption='' then
    FTablePartsTabs.Caption:=SourceToInterface(GetDCLMessageString(msPage)+' ')+IntToStr(Pc+1)
  Else
    FTablePartsTabs.Caption:=InitCap(Caption);

  FTablePartsTabs.Name:='TablePart_'+IntToStr(Pc+1);
  FTablePartsTabs.PageControl:=FTablePartsPages;

  FTablePartsPages.ActivePage:=FTablePartsPages.Pages[0];
  FTablePartsPages.ActivePageIndex:=0;

  PartTabIndex:=AddTablePart(FTablePartsTabs.PageControl.Pages[FTablePartsPages.PageCount-1], Data);
  FTablePartsTabs.PageControl.Pages[FTablePartsPages.PageCount-1].Tag:=PartTabIndex;
  PartQueryGlob:=FTableParts[PartTabIndex].Query;
  Result:=PartTabIndex;
end;

procedure TDCLGrid.AddPopupMenuItem(Caption, ItemName: String; Action: TNotifyEvent;
  AChortCutKey: String; Tag: Integer; PictType: String);
Begin
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
End;

procedure TDCLGrid.AddRollBar(var Field: RField);
var
  l: Word;
  TempStr: string;
begin
  Field.CurrentEdit:=true;
  l:=length(RollBars);
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
  Begin
    If FDCLLogOn.Variables.Exists(TempStr) Then
    Begin
      If Not FieldExists(Field.FieldName, Query) Then
        RollBars[l].RollBar.Position:=StrToInt(TempStr);
      RollBars[l].Variable:=TempStr;
    End
    Else
      FDCLLogOn.Variables.NewVariable(TempStr);
  End;

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
Begin
  If ToMenu<>-1 Then
  Begin
    ToItem:=PopupGridMenu.Items[ToMenu];
    ItemMenu:=TMenuItem.Create(ToItem);
    ItemMenu.Tag:=Tag;
    ItemMenu.Name:=ItemName;
    ItemMenu.Caption:=Caption;
    ItemMenu.OnClick:=Action;
    ToItem.OnClick:=Nil;
    ToItem.Insert(ToItem.Count, ItemMenu);
  End;
End;

procedure TDCLGrid.AddSumGrid(OPL: string);
var
  TempStr, KeyField, tmpSQL, tmpSQL1: String;
  v1, v2: Integer;
begin
  SumQuery:=TDCLDialogQuery.Create(Nil);
  SumQuery.Name:='SummQuery_'+IntToStr(UpTime);
  SummString:=FindParam('SummQuery=', OPL);
  SumQuery.SQL.Text:=GetSummQuery;
  FDCLLogOn.SetDBName(SumQuery);
  SumData:=TDataSource.Create(Nil);
  SumData.DataSet:=SumQuery;
  SumQuery.Open;

  SummGrid:=TToolGrid.Create(FGridPanel);
  SummGrid.Align:=alBottom;
  SummGrid.Height:=SummGridHeight;
  SummGrid.Name:='SumGrid';
  SummGrid.Parent:=FGridPanel;
  SummGrid.Options:=[dgIndicator, dgColLines, dgRowLines, dgCancelOnExit];
  SummGrid.DataSource:=SumData;
  SummGrid.ScrollBars:=ssNone;

  TempStr:=FindParam('Columns=', OPL);
  If TempStr<>'' Then
  Begin
    SummGrid.Columns.Clear;
    v1:=ParamsCount(TempStr);
    For v2:=1 To v1 Do
    Begin
      KeyField:=SortParams(TempStr, v2);
      tmpSQL:=Copy(KeyField, 1, Pos('/', KeyField)-1);
      tmpSQL1:=Copy(KeyField, Pos('/', KeyField)+1, length(KeyField));
      If FieldExists(tmpSQL, SumQuery) Then
      Begin
        SummGrid.Columns.Add.FieldName:=tmpSQL;
        SummGrid.Columns[v2-1].Width:=StrToIntEx(tmpSQL1);
      End
      Else
      Begin
        SummGrid.Columns.Add;
        SummGrid.Width:=StrToIntEx(tmpSQL1);
      End;
    End;
  End;
end;

function TDCLGrid.AddTablePart(Parent: TWinControl; Data: TDataSource): Integer;
var
  FPartsCount: Integer;
begin
  PagePanelCreated:=False;
  FPartsCount:=length(FTableParts);
  SetLength(FTableParts, FPartsCount+1);
  FTableParts[FPartsCount]:=TDCLGrid.Create(FDCLForm, Parent, dctTablePart, nil, Data);
  Result:=FPartsCount;
end;

procedure TDCLGrid.AddToolPanel;
begin
  If Not Assigned(ToolPanel) Then
  Begin
    ToolPanel:=TDialogPanel.Create(FGridPanel);
    ToolPanel.Parent:=FGridPanel;
    ToolPanel.Top:=1;
    ToolPanel.Height:=ToolPanelHeight;
    ToolPanel.Align:=alTop;
    ToolPanelElementLeft:=0;
  End;
end;

procedure TDCLGrid.AddToolPartButton(ButtonParam: RButtonParams);
begin
  If not PagePanelCreated Then
  Begin
    PagePanel:=TDialogPanel.Create(FTablePartsTabs.PageControl.Pages[FTablePartsPages.PageCount-1]);
    PagePanel.Parent:=FTablePartsTabs.PageControl.Pages[FTablePartsPages.PageCount-1];
    PagePanel.Align:=alTop;
    PagePanel.Height:=ToolPagePanelHeight;
    PagePanelCreated:=true;
    PartButtonLeft:=TablePartButtonLeft;
    PartButtonTop:=TablePartButtonTop;
  End;

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
  Begin
    If Assigned(FDCLLogOn.Forms[v1-1]) then
      If FDCLLogOn.ActiveDCLForms[v1-1] then
        If Assigned(FDCLLogOn.Forms[v1-1].ParentForm) then
        Begin
          If FDCLLogOn.Forms[v1-1].ParentForm=FDCLForm then
            For v2:=1 to FDCLLogOn.Forms[v1-1].TablesCount do
              FDCLLogOn.Forms[v1-1].Tables[v2-1].ScrollDB(FQuery);
        End;
  End;

  For v1:=1 to FDCLLogOn.FormsCount do
  Begin
    If Assigned(FDCLLogOn.Forms[v1-1]) then
      If FDCLLogOn.ActiveDCLForms[v1-1] then
        If Assigned(FDCLLogOn.Forms[v1-1].ParentForm) then
        Begin
          If FDCLLogOn.Forms[v1-1].ParentForm=FDCLForm then
            For v2:=1 to FDCLLogOn.Forms[v1-1].TablesCount do
              FDCLLogOn.Forms[v1-1].Tables[v2-1].AfterCancel(FQuery);
        End;
  End;
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
    Data.Cancel
  Else
  Begin
    SetDataStatus(dssChanged);
  End;

  For v1:=1 to FDCLLogOn.FormsCount do
  Begin
    If Assigned(FDCLLogOn.Forms[v1-1]) then
      If FDCLLogOn.ActiveDCLForms[v1-1] then
        If Assigned(FDCLLogOn.Forms[v1-1].ParentForm) then
        Begin
          If FDCLLogOn.Forms[v1-1].ParentForm=FDCLForm then
            For v2:=1 to FDCLLogOn.Forms[v1-1].TablesCount do
              FDCLLogOn.Forms[v1-1].Tables[v2-1].ScrollDB(Data);
        End;
  End;
end;

procedure TDCLGrid.AfterInsert(Data: TDataSet);
var
  v1, v2: Integer;
Begin
  If FUserLevelLocal<ulWrite Then
    Data.Cancel
  Else
  Begin
    If DependField<>'' Then
      If MasterDataField<>'' Then
      Begin
        Data.FieldByName(DependField).AsString:=FDCLForm.CurrentQuery.FieldByName
          (MasterDataField).AsString;
      End;

    ExecEvents(EventsInsert);

    SetDataStatus(dssChanged);
  End;

  For v1:=1 to FDCLLogOn.FormsCount do
  Begin
    If Assigned(FDCLLogOn.Forms[v1-1]) then
      If FDCLLogOn.ActiveDCLForms[v1-1] then
        If Assigned(FDCLLogOn.Forms[v1-1].ParentForm) then
        Begin
          If FDCLLogOn.Forms[v1-1].ParentForm=FDCLForm then
            For v2:=1 to FDCLLogOn.Forms[v1-1].TablesCount do
              FDCLLogOn.Forms[v1-1].Tables[v2-1].AfterInsert(Data);
        End;
  End;
end;

procedure TDCLGrid.AfterOpen(Data: TDataSet);
var
  tmpSQL: string;
  v1, v2: Integer;
begin
  Screen.Cursor:=crDefault;
  ExecEvents(EventsAfterOpen);

  If Assigned(SumQuery) Then
  Begin
    tmpSQL:=GetSummQuery;
    TranslateVal(tmpSQL);
    SumQuery.Close;
    SumQuery.SQL.Text:=tmpSQL;
    Try
      SumQuery.Open;
    Except
      ShowErrorMessage(-1118, 'SQL='+tmpSQL);
    End;
  End;

  For v1:=1 to FDCLLogOn.FormsCount do
  Begin
    If Assigned(FDCLLogOn.Forms[v1-1]) then
      If FDCLLogOn.ActiveDCLForms[v1-1] then
        If Assigned(FDCLLogOn.Forms[v1-1].ParentForm) then
        Begin
          If FDCLLogOn.Forms[v1-1].ParentForm=FDCLForm then
            For v2:=1 to FDCLLogOn.Forms[v1-1].TablesCount do
              FDCLLogOn.Forms[v1-1].Tables[v2-1].ScrollDB(Data);
        End;
  End;

  For v1:=1 to FDCLLogOn.FormsCount do
  Begin
    If Assigned(FDCLLogOn.Forms[v1-1]) then
      If FDCLLogOn.ActiveDCLForms[v1-1] then
        If Assigned(FDCLLogOn.Forms[v1-1].ParentForm) then
        Begin
          If FDCLLogOn.Forms[v1-1].ParentForm=FDCLForm then
            For v2:=1 to FDCLLogOn.Forms[v1-1].TablesCount do
              FDCLLogOn.Forms[v1-1].Tables[v2-1].AfterOpen(Data);
        End;
  End;
end;

procedure TDCLGrid.AfterPost(Data: TDataSet);
var
  v1, v2: Integer;
begin
  SaveDB;
  ExecEvents(EventsAfterPost);

  SetDataStatus(dssSaved);

  For v1:=1 to FDCLLogOn.FormsCount do
  Begin
    If Assigned(FDCLLogOn.Forms[v1-1]) then
      If FDCLLogOn.ActiveDCLForms[v1-1] then
        If Assigned(FDCLLogOn.Forms[v1-1].ParentForm) then
        Begin
          If FDCLLogOn.Forms[v1-1].ParentForm=FDCLForm then
            For v2:=1 to FDCLLogOn.Forms[v1-1].TablesCount do
              FDCLLogOn.Forms[v1-1].Tables[v2-1].ScrollDB(FQuery);
        End;
  End;

  For v1:=1 to FDCLLogOn.FormsCount do
  Begin
    If Assigned(FDCLLogOn.Forms[v1-1]) then
      If FDCLLogOn.ActiveDCLForms[v1-1] then
        If Assigned(FDCLLogOn.Forms[v1-1].ParentForm) then
        Begin
          If FDCLLogOn.Forms[v1-1].ParentForm=FDCLForm then
            For v2:=1 to FDCLLogOn.Forms[v1-1].TablesCount do
              FDCLLogOn.Forms[v1-1].Tables[v2-1].AfterPost(FQuery);
        End;
  End;
  FDCLLogOn.NotifyForms(fnaRefresh);
end;

procedure TDCLGrid.AfterRefresh(Data: TDataSet);
begin
  FDCLForm.SetDBStatus('');
  FDCLForm.BaseChanged:=False;
  BaseChanged:=False;
end;

procedure TDCLGrid.AutorefreshTimer(Sender: TObject);
Begin
  If Not RefreshLock Then
  Begin
    RefreshLock:=true;
    If FQuery.State In [dsBrowse] Then
      ReFreshQuery;
    RefreshLock:=False;
  End;
End;

procedure TDCLGrid.BeforeOpen(Data: TDataSet);
begin
  Screen.Cursor:=crSQLWait;
end;

procedure TDCLGrid.BeforePost(Data: TDataSet);
var
  v1, v2: Integer;
begin
  /// deprecated;
  ExecEvents(EventsBeforePost);

  For v1:=1 to FDCLLogOn.FormsCount do
  Begin
    If Assigned(FDCLLogOn.Forms[v1-1]) then
      If FDCLLogOn.ActiveDCLForms[v1-1] then
        If Assigned(FDCLLogOn.Forms[v1-1].ParentForm) then
        Begin
          If FDCLLogOn.Forms[v1-1].ParentForm=FDCLForm then
            For v2:=1 to FDCLLogOn.Forms[v1-1].TablesCount do
              FDCLLogOn.Forms[v1-1].Tables[v2-1].BeforePost(FQuery);
        End;
  End;
end;

procedure TDCLGrid.BeforeScroll(Data: TDataSet);
var
  v1, v2: Integer;
begin
  ExecEvents(EventsBeforeScroll);

  For v1:=1 to FDCLLogOn.FormsCount do
  Begin
    If Assigned(FDCLLogOn.Forms[v1-1]) then
      If FDCLLogOn.ActiveDCLForms[v1-1] then
        If Assigned(FDCLLogOn.Forms[v1-1].ParentForm) then
        Begin
          If FDCLLogOn.Forms[v1-1].ParentForm=FDCLForm then
            For v2:=1 to FDCLLogOn.Forms[v1-1].TablesCount do
              FDCLLogOn.Forms[v1-1].Tables[v2-1].BeforeScroll(FQuery);
        End;
  End;
end;

procedure TDCLGrid.CalendarOnChange(Sender: TObject);
Var
  CalendarIdx: Integer;
  EdDate: String;
Begin
  CalendarIdx:=(Sender As DateTimePicker).Tag;

  EdDate:=DateToStr((Sender As DateTimePicker).Date);
  FDCLLogOn.Variables.Variables[Calendars[CalendarIdx].VarName]:=EdDate;
  If Calendars[CalendarIdx].ReOpen Then
  Begin
    FQuery.Close;
    EdDate:='Query='+FindRaightQuery('Query=');
    EdDate:=FindParam('Query=', EdDate);
    TranslateVal(EdDate);
    FQuery.SQL.Text:=EdDate;

    Try
      FQuery.Open;
    Except
      ShowErrorMessage(-1100, 'SQL='+EdDate);
    End;

    OpenQuery(QueryBuilder(0, 0));
  End;
End;

procedure TDCLGrid.CancelDB;
Begin
  SetDataStatus(dssSaved);
End;

procedure TDCLGrid.ChangeTabPage(Sender: TObject);
begin
  CurrentTabIndex:=(Sender as TPageControl).ActivePage.Tag;
  PartQueryGlob:=Query;
  FDCLForm.CurrentTabIndex:=CurrentTabIndex;
end;

procedure TDCLGrid.CheckOnClick(Sender: TObject);
Var
  sd: String;
  isd: Integer;
Begin
  isd:=(Sender As TCheckbox).Tag;
  sd:=CheckBoxes[isd].CheckBoxToVars;
  If FDCLLogOn.Variables.Exists(sd) Then
    Case (Sender As TCheckbox).Checked Of
    true:
    FDCLLogOn.Variables.Variables[sd]:='1';
    False:
    FDCLLogOn.Variables.Variables[sd]:='0';
    End;
End;

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
  If FQuery.Active then
    FLocalBookmark:=FQuery.GetBookmark;
end;

procedure TDCLGrid.ColumnsManege(Sender: TObject);
Var
  CIndex: Integer;
Begin
  CIndex:=ColumnsList.ItemIndex;
  FGrid.Columns.Delete(CIndex);
  ColumnsList.Items.Delete(CIndex);
  DeleteList(CIndex);
End;

procedure TDCLGrid.ContextFieldButtonsClick(Sender: TObject);
Var
  i: Integer;
begin
  i:=(Sender as TComponent).Tag;
  If i<>-1 then
    If ContextFieldButtons[i].Command<>'' then
      FDCLForm.ExecCommand(ContextFieldButtons[i].Command);
end;

procedure TDCLGrid.ContextListChange(Sender: TObject);
Var
  ComboNum: Integer;
  Combo: TComboBox;
  tmpQuery: TDCLDialogQuery;
Begin
  ComboNum:=(Sender As TComponent).Tag;
  Combo:=(Sender As TComboBox);
  If Trim(Combo.Text)<>'' Then
  Begin
    tmpQuery:=TDCLDialogQuery.Create(Nil);
    tmpQuery.Name:='tmpContextListQ_'+IntToStr(UpTime);
    FDCLLogOn.SetDBName(tmpQuery);

    tmpQuery.SQL.Text:='select '+ContextLists[ComboNum].KeyField+' from '+ContextLists[ComboNum]
      .Table+' where '+ContextLists[ComboNum].Field+'='+GPT.StringTypeChar+Combo.Text+
      GPT.StringTypeChar;
    tmpQuery.Open;

    If not tmpQuery.IsEmpty then
    Begin
      If (FQuery.State=dsBrowse) Then
        FQuery.Edit;
      FQuery.FieldByName(ContextLists[ComboNum].DataField).AsInteger:=
        tmpQuery.FieldByName(ContextLists[ComboNum].KeyField).AsInteger;
      // If pre=1 then FormData[CurrentForm].QueryGlob.Post;
    End;
    tmpQuery.Close;
    FreeAndNil(tmpQuery);
  End;
End;

procedure TDCLGrid.ContextListKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
Var
  ComboNum: Integer;
  tmpQuery: TDCLDialogQuery;
  Combo: TComboBox;
Begin
  ComboNum:=(Sender As TComponent).Tag;
  Combo:=(Sender As TComboBox);
  If (Key=13)and(Shift=[ssCtrl]) Then
    If Combo.Text<>'' Then
    Begin
      tmpQuery:=TDCLDialogQuery.Create(Nil);
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

      If tmpQuery.RecordCount=1 then
      Begin
        Combo.Text:=Trim(tmpQuery.FieldByName(ContextLists[ComboNum].Field)
          .AsString);
        If (FQuery.State=dsBrowse) Then
          FQuery.Edit;
        FQuery.FieldByName(ContextLists[ComboNum].DataField).AsInteger:=
          tmpQuery.FieldByName(ContextLists[ComboNum].KeyField).AsInteger;
        // If pre=1 then FormData[CurrentForm].QueryGlob.Post;
      End
      Else
      Begin
        While Not tmpQuery.Eof Do
        Begin
          If Trim(tmpQuery.FieldByName(ContextLists[ComboNum].Field).AsString)<>'' Then
            Combo.Items.Append
              (Trim(tmpQuery.FieldByName(ContextLists[ComboNum].Field).AsString));
          tmpQuery.Next;
        End;
      End;
      tmpQuery.Close;
      FreeAndNil(tmpQuery);

{$IFDEF MSWINDOWS}
      If SendMessage(Combo.Handle, CB_GETDROPPEDSTATE, 0, 0)<>1 then
        SendMessage(Combo.Handle, CB_SHOWDROPDOWN, 1, 0);
{$ENDIF}
    End;
End;

constructor TDCLGrid.Create(var Form: TDCLForm; Parent: TWinControl; SurfType: TDataControlType;
  Query: TDCLDialogQuery; Data: TDataSource);
var
  v1: Integer;
begin
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

  If not Assigned(Query) then
  Begin
    SetNewQuery(Data);
    FData.DataSet:=FQuery;
  End
  Else
    // FQuery:=Query; // Query.Query;
    FData.DataSet:=Query;

  If Assigned(Data) then
    FQuery.DataSource:=Data;

  FDCLLogOn.SQLMon.AddTrace(FQuery);

  FGridPanel:=TDCLMainPanel.Create(Parent);
  FGridPanel.Parent:=Parent;
  FGridPanel.Align:=alClient;

  Navig:=TDBNavigator.Create(FGridPanel);
  Navig.Parent:=FGridPanel;
  Navig.Align:=alTop;
  Navig.ShowHint:=true;
  // Navig.Flat:=True;
  Navig.DataSource:=FData;
  Navig.OnClick:=ClickNavig;

  For v1:=1 To Navig.ControlCount Do
    If Navig.Controls[v1-1] Is TNavButtons Then
      with Navig.Controls[v1-1] do
      Begin
        Case TNavigateBtn((Navig.Controls[v1-1] As TNavButtons).Index) Of
        nbFirst:
        Hint:=SourceToInterface(GetDCLMessageString(msInBegin));
        nbPrior:
        Hint:=SourceToInterface(GetDCLMessageString(msPrior));
        nbNext:
        Hint:=SourceToInterface(GetDCLMessageString(msNext));
        nbLast:
        Hint:=SourceToInterface(GetDCLMessageString(msInEnd));
        nbPost:
        Hint:=SourceToInterface(GetDCLMessageString(msPost));
        nbInsert:
        Hint:=SourceToInterface(GetDCLMessageString(msInsert));
        nbCancel:
        Hint:=SourceToInterface(GetDCLMessageString(msCancel));
        nbEdit:
        Hint:=SourceToInterface(GetDCLMessageString(msEdit));
        nbDelete:
        Hint:=SourceToInterface(GetDCLMessageString(msDelete));
        nbRefresh:
        Hint:=SourceToInterface(GetDCLMessageString(msRefresh));
        End;
      End;
end;

procedure TDCLGrid.CreateBookMarkMenu;
var
  T: TextFile;
  v1, v2, v3: Integer;
  FileLine: String;
begin
  If FileExists(IncludeTrailingPathDelimiter(AppConfigDir)+'BookMark.ini') Then
  Begin
    PosBookCreated:=False;
    AssignFile(T, IncludeTrailingPathDelimiter(AppConfigDir)+'BookMark.ini');
    Reset(T);

    PopupGridMenu.FindComponent('PosToBookMark').Free;

    v1:=1;
    If Assigned(PopupGridMenu.FindComponent('PosToBookMark')) Then
    Begin
      v1:=(PopupGridMenu.FindComponent('PosToBookMark') As TMenuItem).ComponentCount;
      inc(v1);
    End;

    While Not Eof(T) Do
    Begin
      ReadLn(T, FileLine);
      If FindParam('DialogName=', FileLine)=FDCLForm.FDialogName Then
      Begin
        v3:=Length(KeyMarks.KeyBookMarks);
        SetLength(KeyMarks.KeyBookMarks, v3+1);

        If Not PosBookCreated Then
        Begin
          If Not Assigned(PopupGridMenu.FindComponent('PosToBookMark')) Then
            AddPopupMenuItem(SourceToInterface(GetDCLMessageString(msGotoBookmark))+'...', 'PosToBookMark', Nil, '', 0, '');
          PosBookCreated:=true;
        End;

        v2:=PopupGridMenu.Items.IndexOf(PopupGridMenu.FindComponent('PosToBookMark') As TMenuItem);
        If v2>1 Then
        Begin
          KeyMarks.KeyBookMarks[v3].DialogName:=FindParam('DialogName=', FileLine);

          ReadLn(T, FileLine);
          KeyMarks.KeyBookMarks[v3].KeyField:=FindParam('Key=', FileLine);

          ReadLn(T, FileLine);
          KeyMarks.KeyBookMarks[v3].KeyValue:=FindParam('Value=', FileLine);

          ReadLn(T, FileLine);
          If PosEx('Title=', FileLine)<>0 Then
            KeyMarks.KeyBookMarks[v3].Title:=FindParam('Title=', FileLine)
          Else
          Begin
            ShowErrorMessage(0, SourceToInterface(GetDCLMessageString(msOldFormat)+GetDCLMessageString(msOldBookmarkFormat)));
            Exit;
          End;

          AddSubPopupItem(KeyMarks.KeyBookMarks[v3].Title, 'PosBookMark'+IntToStr(v3),
            PosToBookMark, v2, v3);
        End;
      End;
    End;
    CloseFile(T);
  End;
end;

procedure TDCLGrid.CreateColumns;
var
  i: Word;
  FF: RField;
begin
  Show;
  If Assigned(FGrid) then
  Begin
    FGrid.Columns.Clear;
    For i:=1 to length(DataFields) do
    Begin
      FF.FieldName:=DataFields[i-1].Name;
      FF.Caption:=DataFields[i-1].Caption;
      FF.Width:=DataFields[i-1].Width;
      FF.ReadOnly:=DataFields[i-1].ReadOnly;

      AddColumn(FF);
    End;
  End;
end;

procedure TDCLGrid.DBEditClick(Sender: TObject);
Var
  Edit: TDBEdit;
Begin
  Edit:=Sender As TDBEdit;
  If Edit.PasswordChar=MaskPassChar Then
  Begin
    If KeyState(VK_CONTROL) Then
      Edit.PasswordChar:=#0;
  End
  Else If Edit.Tag=1 Then
    If Edit.PasswordChar=#0 Then
    Begin
      Edit.PasswordChar:=MaskPassChar;
    End;
end;

procedure TDCLGrid.DeleteList(Index: Word);
Var
  ListCount: Word;
Begin
  If Index<length(StructModify) then
    For ListCount:=Index To length(StructModify)-1-Index Do
    Begin
      StructModify[ListCount].ColumnsListCaption:=StructModify[ListCount+1].ColumnsListCaption;
      StructModify[ListCount].ColumnsListField:=StructModify[ListCount+1].ColumnsListField;
    End;
End;

procedure TDCLGrid.DeleteMenuBookMark(BookMarkNum: Byte);
Var
  BookMarkFile: TStringList;
  v1: Integer;
Begin
  BookMarkFile:=TStringList.Create;
  If FileExists(IncludeTrailingPathDelimiter(AppConfigDir)+'BookMark.ini') Then
    BookMarkFile.LoadFromFile(IncludeTrailingPathDelimiter(AppConfigDir)+'BookMark.ini');

  v1:=0;
  While Not((KeyMarks.KeyBookMarks[BookMarkNum].DialogName=FindParam('DialogName=',
    BookMarkFile[v1]))And(KeyMarks.KeyBookMarks[BookMarkNum].KeyValue=FindParam('Value=',
    BookMarkFile[v1+2]))) Do
    inc(v1, 4);

  BookMarkFile.Delete(v1);
  BookMarkFile.Delete(v1);
  BookMarkFile.Delete(v1);
  BookMarkFile.Delete(v1);

  BookMarkFile.SaveToFile(IncludeTrailingPathDelimiter(AppConfigDir)+'BookMark.ini');
  FreeAndNil(BookMarkFile);
  CreateBookMarkMenu;
End;

procedure TDCLGrid.DropListOnSelectItem(Sender: TObject);
Var
  v1, v2: Integer;
Begin
  v1:=(Sender As TComponent).Tag;
  v2:=(Sender As TCustomComboBox).ItemIndex;
  If FQuery.Active Then
  Begin
    If FQuery.FieldByName(DropBoxes[v1].FieldName).AsInteger<>v2 Then
    Begin
      If Not(Query.State In [dsInsert, dsEdit]) Then
        FQuery.Edit;

      If Query.State In [dsInsert, dsEdit] Then
        FQuery.FieldByName(DropBoxes[v1].FieldName).AsInteger:=v2;
    End;
  End;

  If DropBoxes[v1].Variable<>'' Then
    FDCLLogOn.Variables.Variables[DropBoxes[v1].Variable]:=IntToStr(v2);
End;

procedure TDCLGrid.EditClick(Sender: TObject);
Var
  Edit: TEdit;
Begin
  Edit:=Sender As TEdit;
  If Edit.PasswordChar=Edits[Edit.Tag].EditsPasswordChar Then
  Begin
    If KeyState(VK_CONTROL) Then
      Edit.PasswordChar:=#0;
  End
  Else If Edits[Edit.Tag].EditsPasswordChar<>#0 Then
    If Edit.PasswordChar=#0 Then
    Begin
      Edit.PasswordChar:=Edits[Edit.Tag].EditsPasswordChar;
    End;
end;

procedure TDCLGrid.EditOnEdit(Sender: TObject);
Var
  EdNamb: Word;
  l, k: Byte;
  ch: Boolean;
  EdText: String;
Begin
  EdNamb:=(Sender As TEdit).Tag;
  Edits[EdNamb].ModifyEdit:=1;
  EdText:=(Sender As TEdit).Text;

  If Edits[EdNamb].EditsToFloat Then
  Begin
    ch:=False;
    l:=length(EdText);
    For k:=1 To l Do
      If EdText[k]=FloatDelimiterFrom Then
      Begin
        EdText[k]:=FloatDelimiterTo;
        ch:=true;
      End;
    If ch Then
      (Sender As TEdit).Text:=EdText;
  End;

  // Update variables
  FDCLForm.LocalVariables.Variables[Edits[EdNamb].EditToVariables]:=EdText;
end;

procedure TDCLGrid.EditOnFloatData(Sender: TObject; Var Key: Char);
begin
  If Key=FloatDelimiterFrom Then
    Key:=FloatDelimiterTo;
  If (CountSimb((Sender As TEdit).Text, FloatDelimiterTo)>=1)And(Key=FloatDelimiterTo) Then
    Key:=#0;
  If ((Key<'0')Or(Key>'9'))And(Key<>'.')And(Key<>#8)And(Key<>'-') Then
    Key:=#0;
end;

procedure TDCLGrid.ExcludeNotAllowedOperation(Operation: TNotAllowedOperations);
var
  i, l: Byte;
begin
  l:=length(NotAllowedOperations);
  For i:=1 to l do
  Begin
    If NotAllowedOperations[i-1]=Operation then
    Begin
      l:=i-1;
      break;
    End;
  End;

  If (l>0)and(l<length(NotAllowedOperations)) then
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
  If length(EventsArray)>0 then
    For i:=0 to length(EventsArray)-1 Do
      FDCLForm.ExecCommand(EventsArray[i]);
end;

procedure TDCLGrid.ExecFilter(Sender: TObject);
Var
  ExeplStr: String;
  FilterIdx: Integer;
Begin
  FilterIdx:=(Sender As TDBLookupComboBox).Tag;
  If FilterIdx<>-1 Then
  Begin
    ExeplStr:=TrimRight((Sender As TDBLookupComboBox).KeyValue);
    DBFilters[FilterIdx].FilterString:=ExeplStr;

    FDCLLogOn.Variables.Variables[DBFilters[FilterIdx].VarName]:=TrimRight(ExeplStr);

    OpenQuery(QueryBuilder(0, 0));
  End;
End;

procedure TDCLGrid.FieldsManege(Sender: TObject);
Var
  CIndex: Byte;
Begin
  CIndex:=FieldsList.ItemIndex;
  FGrid.Columns.Add.FieldName:=StructModify[CIndex].FieldsListField;
  FGrid.Columns[FGrid.Columns.Count-1].Title.Caption:=StructModify[CIndex].FieldsListCaption;
  ColumnsList.Items.Append(FGrid.Columns[FGrid.Columns.Count-1].Title.Caption+'\'+
    FGrid.Columns[FGrid.Columns.Count-1].FieldName);
  StructModify[CIndex].ColumnsListCaption:=StructModify[CIndex].FieldsListCaption;
  StructModify[CIndex].ColumnsListField:=FGrid.Columns[FGrid.Columns.Count-1].FieldName;
End;

procedure TDCLGrid.PFind(Sender: TObject);
Var
  StrIndex: Byte;
  v1, FFactor: Word;
  FieldCaption, tmpSQL2: String;
begin
  If (not(FDisplayMode in [dctMainGrid, dctTablePart]))or(not Assigned(FGrid)) Then
    StrIndex:=1
  Else
    StrIndex:=0;

  If Not FindProcess Then
  Begin
    FindProcess:=true;
    If Not Assigned(FindGrid) Then
    Begin
      FindGrid:=TStringGrid.Create(FGridPanel);
      FindGrid.Parent:=FGridPanel;
      FindGrid.Top:=FGrid.Height-10;
      FindGrid.DefaultRowHeight:=17;
      FindGrid.Align:=alBottom;
      FindGrid.DefaultColWidth:=IndicatorWidth;
      FindGrid.FixedCols:=1;
      If FDisplayMode in [dctFields, dctFieldsStep] Then
      Begin
        FindGrid.Height:=65;
        FindGrid.FixedRows:=1;
        FindGrid.RowCount:=2;
      End
      Else
      Begin
        If Assigned(FGrid) Then
        Begin
          FGrid.Align:=alTop;
          FGrid.Height:=FGrid.Height-46;
          // FGrid.Align:=alClient;
        End;

        FindGrid.Height:=45;
        FindGrid.FixedRows:=0;
        FindGrid.RowCount:=1;
      End;
    End
    Else
      FindGrid.Show;

    If Assigned(FGrid) Then
    Begin
      FindGrid.ColCount:=FGrid.Columns.Count+1;
    End
    Else
    Begin
      FindGrid.ColCount:=length(DataFields);
    End;

    FindGrid.Options:=[goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect,
      goColSizing, goEditing, goTabs];
    FindGrid.Cells[0, StrIndex]:='?';

    FindFields:=TStringList.Create;
    If FDisplayMode in [dctFields, dctFieldsStep] Then
    Begin
      For v1:=0 To length(DataFields)-1 Do
      Begin
        FindGrid.ColWidths[v1+1]:=100;

        Case StrIndex of
        0:
        FieldCaption:=FGrid.Columns[v1].FieldName;
        1:
        FieldCaption:=UpperCase(DataFields[v1].Name);
        End;

        FindFields.Append(FieldCaption);

        Case StrIndex of
        0:
        FieldCaption:=InitCap(FGrid.Columns[v1].Title.Caption);
        1:
        FieldCaption:=InitCap(DataFields[v1].Caption);
        End;

        If StrIndex=1 then
          FindGrid.Cells[v1+1, 0]:=FieldCaption;
      End;
    End
    Else
    Begin
      For v1:=0 To FGrid.Columns.Count-1 Do
      Begin
        FindGrid.ColWidths[v1+1]:=FGrid.Columns[v1].Width;
        FindFields.Append(FGrid.Columns[v1].FieldName);
      End;
      FGrid.Align:=alClient;
    End;
    // FindGrid.Align:=alBottom;
  End
  Else
  Begin
    FindGrid.Hide;
    FGrid.Align:=alClient;

    tmpSQL2:=QueryBuilder(1, 0);

    FindProcess:=False;
    If Assigned(FindFields) Then
    Begin
      FindFields.Clear;
      FreeAndNil(FindFields);
    End;

    FDCLForm.RePlaseVariables(tmpSQL2);
    FFactor:=0;
    TranslateProc(tmpSQL2, FFactor);
    FQuery.SQL.Text:=tmpSQL2;
    Try
      FQuery.Open;
    Except
      // ShowErrorMessage(-1111, 'SQL='+tmpSQL1+CR+SourceToInterface('Условия поиска=')+FindSQL);
    End;
  End;
end;

procedure TDCLGrid.PosToBookMark(Sender: TObject);
Var
  v1: Word;
Begin
  v1:=(Sender As TComponent).Tag;
  If KeyState(VK_CONTROL) Then
    DeleteMenuBookMark(v1)
  Else
    FQuery.Locate(KeyMarks.KeyBookMarks[v1].KeyField, KeyMarks.KeyBookMarks[v1].KeyValue,
      [loCaseInsensitive]);
End;

function TDCLGrid.FindRaightQuery(St: String): String;
Var
  v1: Integer;
Begin
  Result:='';
  If length(QuerysStore)>0 Then
    For v1:=length(QuerysStore) downto 1 Do
    Begin
      If QuerysStore[v1-1].QuryType=qtMain then
      begin
        Result:=QuerysStore[v1-1].QueryStr;
        break;
      End;
    End;
End;

destructor TDCLGrid.Destroy;
var
  Q:TDCLQuery;
begin
  If Assigned(FQuery) then
  Begin
    If BaseChanged Then
      If FDCLForm.ExitNoSave=False Then
        If FQuery.Active Then
          If BaseChanged or (FQuery.State In [dsEdit, dsInsert]) Then
            If ShowErrorMessage(10, SourceToInterface(GetDCLMessageString(msSave)+' '+GetDCLMessageString(msEditings)+'?'))=1 Then
            Begin
              Try
                FQuery.Post;
                BaseChanged:=False;
              Except
                //
              End;
            End
            Else
            Begin
              Try
                BaseChanged:=False;
                FQuery.Cancel;
              Except
                //
              End;
            End;

    {Q:=FQuery;
    FreeAndNil(Q);}
  End;
end;

function TDCLGrid.GetColumns: TDBGridColumns;
begin
  if Assigned(FGrid) then
    Result:=FGrid.Columns;
end;

function TDCLGrid.GetDisplayMode: TDataControlType;
begin
  Result:=FDisplayMode;
end;

function TDCLGrid.GetFieldCount: Integer;
begin
  If FQuery.Active then
    Result:=FQuery.FieldCount
  Else
    Result:=0;
end;

function TDCLGrid.GetFieldDataType(FieldName: String): TFieldType;
var
  tmpFieldName: string;
Begin
  tmpFieldName:=FieldName;
  If Pos('.', FieldName)<>0 then
  begin
    tmpFieldName:=Copy(FieldName, Pos('.', FieldName)+1, length(FieldName));
  end;
  Result:=Query.FieldByName(tmpFieldName).DataType;
End;

function TDCLGrid.GetFingQuery: String;
Var
  StrIndex, FieldIndex: Byte;
  Enything: Boolean;

  Procedure GetGridExemle(Const GridExemple, FindFieldName: String; var QueryString: String);
  Var
    Sign, Exemple, Exemple1, Exemple2: String;
    OperationType: Byte;
  Begin
    Exemple:=Trim(GridExemple);

    OperationType:=0;
    If PosEx('(', Exemple)=1 Then
      If PosEx(')', Exemple)=Length(Exemple) Then
        OperationType:=1;

    If PosEx('[', Exemple)=1 Then
      If PosEx(']', Exemple)<>0 Then
        OperationType:=2;

    If PosEx('!', Exemple)=1 Then
    Begin
      Delete(Exemple, 1, 1);
      OperationType:=3;
    End;

    If PosEx('<=', Exemple)=1 Then
    Begin
      Sign:=Copy(Exemple, 1, 2);
      Delete(Exemple, 1, 2);
      OperationType:=4;
    End
    Else If PosEx('<', Exemple)=1 Then
    Begin
      Sign:=Copy(Exemple, 1, 1);
      Delete(Exemple, 1, 1);
      OperationType:=5;
    End;

    If Pos('>=', Exemple)=1 Then
    Begin
      Sign:=Copy(Exemple, 1, 2);
      Delete(Exemple, 1, 2);
      OperationType:=6;
    End
    Else If Pos('>', Exemple)=1 Then
    Begin
      Sign:=Copy(Exemple, 1, 1);
      Delete(Exemple, 1, 1);
      OperationType:=7;
    End;

    If OperationType In [4, 5, 6, 7] Then
    Begin
      Case Query.FieldByName(FindFieldName).DataType Of
      ftString, ftFixedChar, ftWideString:
      Begin
        QueryString:=QueryString+FindFieldName+Sign+GPT.StringTypeChar+Exemple+GPT.StringTypeChar;
      End;
      ftSmallint, ftInteger, ftWord, ftBoolean, ftAutoInc, ftLargeint:
      Begin
        QueryString:=QueryString+FindFieldName+Sign+Exemple;
      End
    Else
    QueryString:=QueryString+FindFieldName+Sign+GPT.StringTypeChar+Exemple+GPT.StringTypeChar;
      End;
    End;

    If OperationType=3 Then
    Begin
      Case Query.FieldByName(FindFieldName).DataType Of
      ftString, ftFixedChar, ftWideString:
      Begin
        QueryString:=QueryString+FindFieldName+' != '+GPT.StringTypeChar+Exemple+GPT.StringTypeChar;
      End;
      ftSmallint, ftInteger, ftWord, ftBoolean, ftAutoInc, ftLargeint:
      Begin
        QueryString:=QueryString+FindFieldName+' != '+Exemple;
      End
    Else
    QueryString:=QueryString+FindFieldName+' != '+GPT.StringTypeChar+Exemple+GPT.StringTypeChar;
      End;
    End;

    If OperationType=1 Then
    Begin
      QueryString:=QueryString+FindFieldName+' in '+Exemple;
    End;

    If OperationType=2 Then
    Begin
      Exemple1:=Copy(Exemple, 2, Pos(';', Exemple)-2);
      Exemple2:=Copy(Exemple, Pos(';', Exemple)+1, Pos(']', Exemple)-Pos(';', Exemple)-1);

      Case Query.FieldByName(FindFieldName).DataType Of
      ftString, ftFixedChar, ftWideString:
      Begin
        QueryString:=QueryString+FindFieldName+' between '+GPT.StringTypeChar+Exemple1+
          GPT.StringTypeChar+' and '+GPT.StringTypeChar+Exemple2+GPT.StringTypeChar;
      End;
      ftSmallint, ftInteger, ftWord, ftBoolean, ftAutoInc, ftLargeint:
      Begin
        QueryString:=QueryString+FindFieldName+' between '+Exemple1+' and '+Exemple2;
      End
    Else
    QueryString:=QueryString+FindFieldName+' between '+GPT.StringTypeChar+Exemple1+
      GPT.StringTypeChar+' and '+GPT.StringTypeChar+Exemple2+GPT.StringTypeChar;
      End;
    End;

    If OperationType=0 Then
    Begin
      Case Query.FieldByName(FindFieldName).DataType Of
      ftString, ftFixedChar, ftWideString:
      Begin
        QueryString:=QueryString+GPT.UpperString+FindFieldName+GPT.UpperStringEnd+' like '+
          GPT.UpperString+GPT.StringTypeChar+Exemple+GPT.StringTypeChar+GPT.UpperStringEnd;
      End;
      ftSmallint, ftInteger, ftWord, ftBoolean, ftAutoInc, ftLargeint:
      Begin
        QueryString:=QueryString+' '+FindFieldName+' = '+Exemple+' ';
      End
    Else
    QueryString:=QueryString+' '+FindFieldName+' = '+GPT.StringTypeChar+Exemple+
      GPT.StringTypeChar+' ';
      End;
    End;
  End;

Begin
  If Assigned(FindGrid) Then
  Begin
    Enything:=False;
    If not(DisplayMode in [dctMainGrid, dctTablePart]) Then
      StrIndex:=1
    Else
      StrIndex:=0;

    Result:=' ';
    If DisplayMode in [dctMainGrid, dctTablePart] Then
    Begin
      For FieldIndex:=1 To FGrid.Columns.Count Do
        If FindGrid.Cells[FieldIndex, StrIndex]<>'' Then
        Begin
          Result:=Result+' ';
          If Enything Then
            Result:=Result+' and ';
          GetGridExemle(FindGrid.Cells[FieldIndex, StrIndex],
            FGrid.Columns[FieldIndex-1].FieldName, Result);
          Enything:=true;
        End;
      If Not Enything Then
      Begin
        Result:='';
      End;
    End;

    If not(DisplayMode in [dctMainGrid, dctTablePart]) Then
    Begin
      For FieldIndex:=1 To FindFields.Count Do
        If FindGrid.Cells[FieldIndex, StrIndex]<>'' Then
        Begin
          Result:=Result+' ';
          If Enything Then
            Result:=Result+' and ';
          GetGridExemle(FindGrid.Cells[FieldIndex, StrIndex], FindFields[FieldIndex-1], Result);
          Enything:=true;
        End;
      If Not Enything Then
      Begin
        Result:='';
      End;
    End;

  End;
End;

function TDCLGrid.GetMultiselect: Boolean;
begin
  If Assigned(FGrid) then
    Result:=dgMultiSelect in FGrid.Options
  Else
    Result:=FMultiSelect;
end;

function TDCLGrid.GetQuery: TDCLQuery;
begin
  Result:=TDCLQuery(FData.DataSet); // FQuery;
end;

function TDCLGrid.GetQueryToRaights(S: String): String;
Var
  RaightsStr, SQLStr: String;
  DCLQuery: TDCLDialogQuery;
Begin
  Result:=S;
  { DCLQuery:=TDCLDialogQuery.Create(Nil);
    SetDBName(DCLQuery);
    RaightsStr:=FindParam('UserRaights=', S);
    RePlaseVariables(RaightsStr);
    FFactor:=0;
    TranslateProc(RaightsStr, FFactor);

    If (GPT.DCLUserName<>'')And(RaightsStr<>'')And(GPT.UserID<>'') Then
    Begin
    SQLStr:='select count(*) from '+UsersTable+' u where u.'+UserIDField+' '+RaightsStr+' and u.'+
    UserIDField+'='+GPT.UserID;
    DCLQuery.SQL.Text:=SQLStr;
    Try
    DCLQuery.Open;
    Except
    ShowErrorMessage(-9000, 'SQL='+SQLStr);
    End;
    If DCLQuery.Fields[0].AsInteger<>0 Then
    Result:=S
    Else
    Result:='';
    End
    Else
    Result:=S;

    DCLQuery.Close;
    FreeAndNil(DCLQuery); }
End;

function TDCLGrid.GetReadOnly: Boolean;
begin
  If FDisplayMode in TDataGrid then
  Begin
    If Assigned(FGrid) then
      Result:=dgEditing in FGrid.Options
    Else
      Result:=FReadOnly;
  End;
  If FDisplayMode in TDataFields then
  Begin
    Result:=FReadOnly;
  End;
end;

function TDCLGrid.GetSQL: String;
begin
  Result:=FQuery.SQL.Text;
end;

function TDCLGrid.GetSQLFromStore(QueryType: TQueryType): string;
var
  i: Integer;
begin
  Result:='';
  If length(QuerysStore)>0 then
  Begin
    For i:=length(QuerysStore) downto 1 do
      If QuerysStore[i-1].QuryType=QueryType then
      Begin
        Result:=QuerysStore[i-1].QueryStr;
        break;
      End;
  End;
end;

function TDCLGrid.GetSummQuery: String;
Var
  tmS, tmS1: String;
Begin
  If Assigned(FQuery) Then
  Begin
    tmS:=FQuery.SQL.Text;
    If tmS<>'' Then
    Begin
      If PosEx(' order by ', tmS)<>0 Then
        Delete(tmS, PosEx(' order by ', tmS), Length(tmS));
      If PosEx(' group by ', tmS)<>0 Then
        Delete(tmS, PosEx(' group by ', tmS), Length(tmS));
      tmS1:=Copy(tmS, PosEx(' from ', tmS), Length(tmS));
      Result:='select '+SummString+' '+tmS1;
    End
    Else
      Result:='';
  End
  Else
    Result:='';
End;

function TDCLGrid.GetTablePart(Index: Integer): TDCLGrid;
begin
  If Index<>-1 then
  begin
    If length(FTableParts)>Index then
      Result:=FTableParts[Index];
  end
  else
    Result:=nil;
end;

procedure TDCLGrid.GridDblClick(Sender: TObject);
Begin
  ExecEvents(LineDblClickEvents);
End;

procedure TDCLGrid.GridDrawDataCell(Sender: TObject; const Rect: TRect; DataCol: Integer;
  Column: TColumn; State: TGridDrawState);
Var
  strTmp: String;
  ColorsCount: Byte;
  bmp: TBitmap;
Begin
  With (Sender As TDBGrid).Canvas Do
  Begin
    FillRect(Rect);
    If Column.Field Is TGraphicField Then
    Begin
      If GPT.ShowPicture Then
        Try
          bmp:=TBitmap.Create;
          bmp.Assign(Column.Field);
          Draw(Rect.Left, Rect.Top, bmp);
        Finally
          FreeAndNil(bmp);
        End;
    End
    Else
    Begin
      RowColor:=clWhite;
      RowTextColor:=clBlack;

      For ColorsCount:=1 To length(BrushColors) Do
        If FieldExists(BrushColors[ColorsCount-1].Key, FQuery) Then
        Begin
          strTmp:=BrushColors[ColorsCount-1].Value;
          If Pos('<>', strTmp)<>0 Then
          Begin
            Delete(strTmp, PosEx('<>', strTmp), 2);
            strTmp:=Trim(strTmp);
            If LowerCase(strTmp)<>
              LowerCase(Trim(FQuery.FieldByName(BrushColors[ColorsCount-1].Key).AsString)) Then
            Begin
              RowColor:=BrushColors[ColorsCount-1].Color;
              RowTextColor:=clWhite;
            End;
          End
          Else
          Begin
            If Pos('>', strTmp)<>0 Then
            Begin
              Delete(strTmp, PosEx('>', strTmp), 1);
              strTmp:=Trim(strTmp);
              If LowerCase(strTmp)<
                LowerCase(Trim(FQuery.FieldByName(BrushColors[ColorsCount-1].Key).AsString)) Then
              Begin
                RowColor:=BrushColors[ColorsCount-1].Color;
                RowTextColor:=clWhite;
              End;
            End
            Else
            Begin
              If Pos('<', strTmp)<>0 Then
              Begin
                Delete(strTmp, PosEx('<', strTmp), 1);
                strTmp:=Trim(strTmp);
                If LowerCase(strTmp)>
                  LowerCase(Trim(FQuery.FieldByName(BrushColors[ColorsCount-1].Key).AsString)) Then
                Begin
                  RowColor:=BrushColors[ColorsCount-1].Color;
                  RowTextColor:=clWhite;
                End;
              End
              Else
              Begin
                If Pos('<=', strTmp)<>0 Then
                Begin
                  Delete(strTmp, PosEx('<=', strTmp), 2);
                  strTmp:=Trim(strTmp);
                  If LowerCase(strTmp)<=
                    LowerCase(Trim(FQuery.FieldByName(BrushColors[ColorsCount-1].Key)
                    .AsString)) Then
                  Begin
                    RowColor:=BrushColors[ColorsCount-1].Color;
                    RowTextColor:=clWhite;
                  End;
                End
                Else If Pos('>=', strTmp)<>0 Then
                Begin
                  Delete(strTmp, PosEx('>=', strTmp), 2);
                  strTmp:=Trim(strTmp);
                  If LowerCase(strTmp)>=
                    LowerCase(Trim(FQuery.FieldByName(BrushColors[ColorsCount-1].Key)
                    .AsString)) Then
                  Begin
                    RowColor:=BrushColors[ColorsCount-1].Color;
                    RowTextColor:=clWhite;
                  End;
                End
                Else
                Begin
                  strTmp:=Trim(strTmp);
                  If LowerCase(strTmp)
                    =LowerCase(Trim(FQuery.FieldByName(BrushColors[ColorsCount-1].Key)
                    .AsString)) Then
                  Begin
                    RowColor:=BrushColors[ColorsCount-1].Color;
                    RowTextColor:=clWhite;
                  End;
                End;
              End;
            End;
          End;
        End;
      TDBGrid(Sender).Canvas.Brush.Color:=RowColor;
      TDBGrid(Sender).Canvas.Font.Color:=RowTextColor;
      TDBGrid(Sender).DefaultDrawColumnCell(Rect, DataCol, Column, State);
    End;
  End;
End;

procedure TDCLGrid.IncXYPos(StepTop, StepLeft: Word; var Field: RField);
begin
  Case FOrientation of
  oVertical:
  begin
    inc(Field.Top, StepTop);
    If MaxStepFields<StepLeft then
      MaxStepFields:=StepLeft;
  end;
  oHorizontal:
  Begin
    inc(Field.Left, StepLeft+FieldsStepLeft);
    If MaxStepFields<Field.Height then
      MaxStepFields:=Field.Height;
  End;
  End;

  If MaxAllFieldsHeight<Field.Top then
  Begin
    Field.Top:=BeginStepTop;
    inc(Field.Left, FieldsStepLeft+MaxStepFields);
  End;

  If MaxAllFieldsWidth<Field.Left then
  Begin
    Field.Left:=BeginStepLeft;
    inc(Field.Top, MaxStepFields);
  End;
end;

procedure TDCLGrid.LookupDBScroll(Data: TDataSet);
Var
  v1: Integer;
  Look: TDBLookupComboBox;
Begin
  v1:=Data.Tag;
  Look:=Lookups[v1].Lookup;
  If Assigned(Look) Then
    FDCLLogOn.Variables.Variables[Lookups[v1].LookupToVars]:=
      TrimRight(Lookups[v1].LookupQuery.FieldByName(Look.KeyField).AsString);
End;

procedure TDCLGrid.LookupOnClick(Sender: TObject);
Var
  ListField, tmpSQL1: String;
  v4: Integer;
Begin
  v4:=(Sender As TDBLookupComboBox).Tag;
  ListField:=(Sender as TDBLookupComboBox).ListField;

  If Lookups[v4].ModifyEdits<>'' Then
  Begin
    tmpSQL1:=TrimRight(Lookups[v4].LookupQuery.FieldByName(ListField).AsString);
    (FieldPanel.FindComponent(Lookups[v4].ModifyEdits) As TEdit).Text:=tmpSQL1;
  End;
End;

procedure TDCLGrid.OnChangeDateBox(Sender: TObject);
Var
  DateBoxNamb: Byte;
  EdDate: String;
Begin
  DateBoxNamb:=(Sender As DateTimePicker).Tag;
  DateBoxes[DateBoxNamb].ModifyDateBox:=1;
  // Update variables
  EdDate:=DateToStr((Sender As DateTimePicker).Date);
  FDCLLogOn.Variables.Variables[DateBoxes[DateBoxNamb].DateBoxToVariables]:=EdDate;

  If DateBoxes[DateBoxNamb].DateBoxType=0 Then
  Begin
    If Query.Active Then
    Begin
      If FieldExists(DateBoxes[DateBoxNamb].DateBoxToFields, Query) Then
      Begin
        Query.Edit;
        Query.FieldByName(DateBoxes[DateBoxNamb].DateBoxToFields).AsString:=
          DateToStr(DateBoxes[DateBoxNamb].DateBox.Date);
      End;
    End;
  End;
end;

procedure TDCLGrid.OnContextFilter(Sender: TObject; var Key: Word; Shift: TShiftState);
Var
  FilterIdx: Integer;
  ExeplStr: String;
Begin
  FilterIdx:=(Sender As TEdit).Tag;

  ExeplStr:=(Sender As TEdit).Text;
  DBFilters[FilterIdx].FilterString:=ExeplStr;

  If DBFilters[FilterIdx].WaitForKey<>0 Then
  Begin
    If Key=DBFilters[FilterIdx].WaitForKey Then
      OpenQuery(QueryBuilder(0, 0));
  End
  Else
  Begin
    OpenQuery(QueryBuilder(0, 0));
  End;
End;

procedure TDCLGrid.OnDelete(Data: TDataSet);
begin
  ExecEvents(EventsDelete);

  SetDataStatus(dssChanged);
end;

procedure TDCLGrid.Open;
begin
  If length(FQuery.SQL.Text)>11 then
    FQuery.Open;

  If Assigned(FLocalBookmark) then
    try
      FQuery.GoToBookmark(FLocalBookmark);
    finally
      FQuery.FreeBookmark(FLocalBookmark);
    end;
end;

procedure TDCLGrid.OpenQuery(QText: String);
Var
  FFactor: Word;
Begin
  FQuery.SQL.Clear;
  FDCLForm.RePlaseVariables(QText);
  FFactor:=0;
  TranslateProc(QText, FFactor);
  FQuery.SQL.Append(QText);

  Try
    FQuery.Open;
  Except
    ShowErrorMessage(-1100, 'SQL='+QText);
  End;
End;

procedure TDCLGrid.PCopy(Sender: TObject);
begin
{$IFDEF MSWINDOWS}
  SendMessage(GetFocus, WM_COPY, 0, 0);
{$ENDIF}
end;

procedure TDCLGrid.PCut(Sender: TObject);
begin
{$IFDEF MSWINDOWS}
  SendMessage(GetFocus, WM_CUT, 0, 0);
{$ENDIF}
end;

procedure TDCLGrid.PPaste(Sender: TObject);
begin
{$IFDEF MSWINDOWS}
  SendMessage(GetFocus, WM_PASTE, 0, 0);
{$ENDIF}
end;

procedure TDCLGrid.Print(Sender: TObject);
Var
  PrintBase: TPrintBase;
begin
  PrintBase:=TPrintBase.Create;
  PrintBase.Print(FGrid, FQuery, FDCLForm.FForm.Caption);
end;

procedure TDCLGrid.PUndo(Sender: TObject);
begin
{$IFDEF MSWINDOWS}
  SendMessage(GetFocus, WM_UNDO, 0, 0);
{$ENDIF}
end;

function TDCLGrid.QueryBuilder(GetQueryMode, QueryMode: Byte): String;
Var
  QFilterField, WhereStr, ExeplStr, Exempl2, OrderBy, GroupBy, tmpSQL, tmpSQL1,
    Query1String: String;
  FN, FFactor: Word;

  Function ConstructQueryString(ExemplStr, FilterField: String; Upper, NotLike: Boolean;
    Between: Byte; Exempl2: String): String;
  Var
    Delimiter, Prefix, Postfix, UpperPrefix, UpperPostfix, WhereStr, CondStr: String;
    Procedure BetweenFormat;
    Begin
      If (Between<>0)And(Exempl2<>'') Then
      Begin
        Prefix:=' between ';
        CondStr:=UpperPrefix+Delimiter+TrimRight(ExemplStr)+Delimiter+UpperPostfix+' and '+
          UpperPrefix+Delimiter+Exempl2+Delimiter+UpperPostfix;
      End;
    End;

  Begin
    Delimiter:=GetDelimiter(FilterField, Query);
    Prefix:='=';
    Postfix:='';
    UpperPrefix:='';
    UpperPostfix:='';
    CondStr:='';

    If Upper Then
    Begin
      Case GetFieldDataType(FilterField) Of
      ftString, ftFixedChar, ftWideString:
      Begin
        UpperPrefix:=GPT.UpperString;
        UpperPostfix:=GPT.UpperStringEnd;
        BetweenFormat;
      End;
      End;
    End;

    If Not NotLike Then
    Begin
      Case GetFieldDataType(FilterField) Of
      ftString, ftFixedChar, ftWideString:
      Begin
        Prefix:=' like ';
        Postfix:='%';
      End;
      End;
    End
    Else
      BetweenFormat;

    If CondStr='' Then
      CondStr:=UpperPrefix+Delimiter+ExemplStr+Postfix+Delimiter+UpperPostfix;

    WhereStr:=' '+UpperPrefix+FilterField+UpperPostfix+Prefix+CondStr;
    Result:=WhereStr;
  End;

Begin
  Case GetQueryMode Of
  0:
  Begin
    tmpSQL:=GetSQLFromStore(qtFind);
    If tmpSQL='' Then
      tmpSQL:=GetSQLFromStore(qtMain);
  End;
  1:
  Begin
    tmpSQL:=GetSQLFromStore(qtMain);
  End;
  End;

  Case QueryMode Of
  0:
  Begin
    OrderBy:='';
    If PosEx('order by', tmpSQL)<>0 Then
    Begin
      OrderBy:=Copy(tmpSQL, PosEx(' order by', tmpSQL), Length(tmpSQL));
      Delete(tmpSQL, PosEx(' order by', tmpSQL), Length(tmpSQL));
    End;
    GroupBy:='';
    If PosEx('group by ', tmpSQL)<>0 Then
    Begin
      GroupBy:=Copy(tmpSQL, PosEx(' group by', tmpSQL), Length(tmpSQL));
      Delete(tmpSQL, PosEx(' group by', tmpSQL), Length(tmpSQL));
    End;
  End;
  1:
  Begin
    If PosEx('order by', tmpSQL)<>0 Then
      Delete(tmpSQL, PosEx(' order by', tmpSQL), Length(tmpSQL));

    If PosEx('group by ', tmpSQL)<>0 Then
      Delete(tmpSQL, PosEx(' group by', tmpSQL), Length(tmpSQL));

    GroupBy:='';
    OrderBy:='';
  End;
  2:
  Begin
    GroupBy:='';
    OrderBy:='';
  End;
  End;

  Query1String:='';
  WhereStr:='';
  If PosEx(' where ', tmpSQL)<>0 Then
    WhereStr:=' ';

  If length(DBFilters)>0 then
    For FN:=0 To length(DBFilters)-1 Do
    Begin
      If DBFilters[FN].FilterString<>'' Then
      Begin
        ExeplStr:=DBFilters[FN].FilterString;
        QFilterField:=DBFilters[FN].Field;
        // Delimiter:=GetDelimiter(QFilterField);

        If ExeplStr='-1' Then
        Begin
          FDCLForm.RePlaseVariables(tmpSQL);
          DBFilters[FN].FilterChengFlag:=-1;
        End
        Else
        Begin
          FDCLForm.RePlaseVariables(WhereStr);
          DBFilters[FN].FilterChengFlag:=1;

          If ExeplStr<>'-1' Then
          Begin
            If DBFilters[FN].Between<>StopFilterFlg Then
            Begin
              Exempl2:='';
              If WhereStr>' ' Then
                WhereStr:=WhereStr+' and ';
              If DBFilters[FN].Between<>0 then
                Exempl2:=DBFilters[DBFilters[FN].Between].FilterString;

              WhereStr:=WhereStr+' '+ConstructQueryString(ExeplStr, QFilterField,
                not DBFilters[FN].CaseC, DBFilters[FN].NotLike, DBFilters[FN].Between, Exempl2);
            End;
          End
          Else
          Begin
            DBFilters[FN].FilterChengFlag:=-1;
          End;
        End;
      End;
    End;

  If length(WhereStr)>3 Then
    If PosEx(' where ', tmpSQL)<>0 Then
      WhereStr:=' and '+WhereStr
    Else
      WhereStr:=' where '+WhereStr;

  Query1String:=GetFingQuery;
  If Query1String<>'' Then
    If (WhereStr>' ')Or(PosEx(' where ', tmpSQL)<>0) Then
      WhereStr:=WhereStr+' and '+Query1String
    Else
      WhereStr:=' where '+Query1String;

  Case QueryMode Of
  0:
  Begin
    tmpSQL1:=tmpSQL+' '+WhereStr+' '+GroupBy+' '+OrderBy;
  End;
  1:
  Begin
    tmpSQL1:=tmpSQL+' '+WhereStr+' ';
  End;
  End;
  FDCLForm.RePlaseVariables(tmpSQL1);
  FFactor:=0;
  TranslateProc(tmpSQL1, FFactor);
  Result:=tmpSQL1;
End;

procedure TDCLGrid.ReFreshQuery;
Var
  tpc: Byte;
begin
  FQuery.DisableControls;

  If FQuery.Active Then
  Begin
    For tpc:=1 To length(FTableParts) Do
    Begin
      FTableParts[tpc-1].Close;
    End;
    Close;
  End;

  Open;
  For tpc:=1 To length(FTableParts) Do
  Begin
    FTableParts[tpc-1].Open;
  End;

  FQuery.EnableControls;
end;

procedure TDCLGrid.RePlaseParams(var Params: string);
Begin
  If Assigned(FQuery) Then
    RePlaseParams_(Params, FQuery);
end;

procedure TDCLGrid.RollBarOnChange(Sender: TObject);
Var
  v1: Integer;
Begin
  v1:=(Sender As TComponent).Tag;
  If Query.Active And FieldExists(RollBars[v1].Field, Query) Then
  Begin
    If Query.FieldByName(RollBars[v1].Field).AsString<>IntToStr((Sender As TTrackBar).Position) Then
    Begin
      If Not(Query.State In [dsInsert, dsEdit]) Then
        Query.Edit;

      Query.FieldByName(RollBars[v1].Field).AsString:=IntToStr((Sender As TTrackBar).Position);
    End;
  End;

  If RollBars[v1].Variable<>'' Then
    FDCLLogOn.Variables.Variables[RollBars[v1].Variable]:=IntToStr((Sender As TTrackBar).Position);
End;

procedure TDCLGrid.SaveDB;
Begin
  SetDataStatus(dssSaved);
End;

procedure TDCLGrid.ScrollDB(Data: TDataSet);
Var
  v1, v2: Word;
  TmpStr: string;
Begin
  If Not FQuery.Active Then
    Exit;
  For v1:=1 to length(EventsScroll) Do
  Begin
    FDCLForm.ExecCommand(EventsScroll[v1-1]);
  End;

  FDCLForm.SetRecNo;

  If length(Edits)>0 Then
    For v1:=1 To length(Edits) Do
    Begin
      If Edits[v1-1].EditsType in [fbtOutBox, fbtEditBox] Then
      Begin
        If FieldExists(Edits[v1-1].EditsToFields, FQuery) Then
          Edits[v1-1].Edit.Text:=TrimRight(FQuery.FieldByName(Edits[v1-1].EditsToFields).AsString);
      End;
    End;

  If length(DropBoxes)>0 Then
    For v1:=1 To length(DropBoxes) Do
    Begin
      If FieldExists(DropBoxes[v1-1].FieldName, FQuery) Then
        DropBoxes[v1-1].DropList.ItemIndex:=FQuery.FieldByName(DropBoxes[v1-1].FieldName).AsInteger;
    End;

  If length(CheckBoxes)>0 Then
    For v1:=1 To length(CheckBoxes) Do
    Begin
      If FieldExists(CheckBoxes[v1-1].CheckBoxToFields, FQuery) Then
      Begin
        TmpStr:=TrimRight(FQuery.FieldByName(CheckBoxes[v1-1].CheckBoxToFields).AsString);
        If (TmpStr='0')Or(TmpStr='') Then
          CheckBoxes[v1-1].CheckBox.Checked:=False;
        If TmpStr='1' Then
          CheckBoxes[v1-1].CheckBox.Checked:=true;
      End;
    End;

  If length(DateBoxes)>0 Then
    For v1:=1 To length(DateBoxes) Do
    Begin
      If FieldExists(DateBoxes[v1-1].DateBoxToFields, FQuery) Then
        DateBoxes[v1-1].DateBox.Date:=FQuery.FieldByName(DateBoxes[v1-1].DateBoxToFields)
          .AsDateTime;
    End;

  If length(RollBars)>0 Then
    For v1:=1 To length(RollBars) Do
    Begin
      If RollBars[v1-1].Field<>'' Then
      Begin
        If FieldExists(RollBars[v1-1].Field, FQuery) Then
          RollBars[v1-1].RollBar.Position:=FQuery.FieldByName(RollBars[v1-1].Field).AsInteger;
      End;
    End;

  If length(ContextLists)>0 Then
    For v1:=1 To length(ContextLists) Do
    Begin
      If FieldExists(ContextLists[v1-1].ListField, FQuery) Then
        ContextLists[v1-1].ContextList.Text:=
          FQuery.FieldByName(ContextLists[v1-1].ListField).AsString
      Else
      Begin
        If FieldExists(ContextLists[v1-1].DataField, FQuery) Then
        Begin
          ContextLists[v1-1].ContextList.Text:=GetFieldValue(ContextLists[v1-1].Table,
            ContextLists[v1-1].Field, ' where '+ContextLists[v1-1].KeyField+'='+
            IntToStr(FQuery.FieldByName(ContextLists[v1-1].DataField).AsInteger));
        End;
      End;
    End;

  For v1:=1 to FDCLLogOn.FormsCount do
  Begin
    If Assigned(FDCLLogOn.Forms[v1-1]) then
      If FDCLLogOn.ActiveDCLForms[v1-1] then
        If Assigned(FDCLLogOn.Forms[v1-1].ParentForm) then
        Begin
          If FDCLLogOn.Forms[v1-1].ParentForm=FDCLForm then
            For v2:=1 to FDCLLogOn.Forms[v1-1].TablesCount do
              FDCLLogOn.Forms[v1-1].Tables[v2-1].ScrollDB(FQuery);
        End;
  End;
End;

procedure TDCLGrid.SetBookMark(Sender: TObject);
Var
  BookMarkFile: TStringList;
Begin
  If (KeyMarks.KeyField<>'')And(FieldExists(KeyMarks.KeyField, FQuery)) Then
  Begin
    BookMarkFile:=TStringList.Create;
    If FileExists(IncludeTrailingPathDelimiter(AppConfigDir)+'BookMark.ini') Then
      BookMarkFile.LoadFromFile(IncludeTrailingPathDelimiter(AppConfigDir)+'BookMark.ini');
    BookMarkFile.Append('DialogName='+FDCLForm.FDialogName);
    BookMarkFile.Append('Key='+KeyMarks.KeyField);
    BookMarkFile.Append('Value='+FQuery.FieldByName(KeyMarks.KeyField).AsString);
    BookMarkFile.Append('Title='+FQuery.FieldByName(KeyMarks.TitleField).AsString);
    BookMarkFile.SaveToFile(IncludeTrailingPathDelimiter(AppConfigDir)+'BookMark.ini');
    FreeAndNil(BookMarkFile);

    CreateBookMarkMenu;
  End;
End;

procedure TDCLGrid.SetColumns(Cols: TDBGridColumns);
begin
  if Assigned(FGrid) then
    FGrid.Columns:=Cols;
end;

procedure TDCLGrid.SetDataStatus(Status: TDataStatus);
begin
  Case Status of
  dssChanged:
  begin
    If Assigned(FDCLForm.ParentForm) then
    Begin
      FDCLForm.ParentForm.SetDBStatus(SourceToInterface(GetDCLMessageString(msModified)));
      FDCLForm.ParentForm.BaseChanged:=True;
      BaseChanged:=True;
    End;

    FDCLForm.SetDBStatus(SourceToInterface(GetDCLMessageString(msModified)));
    FDCLForm.BaseChanged:=True;
    BaseChanged:=True;
  end;
  dssSaved:
  begin
    If Assigned(FDCLForm.ParentForm) then
    Begin
      FDCLForm.ParentForm.SetDBStatus(SourceToInterface(GetDCLMessageString(msNone)));
      FDCLForm.ParentForm.BaseChanged:=False;
      BaseChanged:=False;
    End;

    FDCLForm.SetDBStatus(SourceToInterface(GetDCLMessageString(msNone)));
    FDCLForm.BaseChanged:=False;
    BaseChanged:=False;
  end;
  End;
end;

procedure TDCLGrid.SetDisplayMode(DisplayMode: TDataControlType);
begin
  If not FShowed then
    FDisplayMode:=DisplayMode;
end;

procedure TDCLGrid.SetGridOptions(Options: TDBGridOptions);
begin
  FGrid.Options:=Options;
end;

procedure TDCLGrid.SetMultiselect(Value: Boolean);
begin
  If FDisplayMode in TDataGrid then
  Begin
    FMultiSelect:=Value;
    If Assigned(FGrid) then
    Begin
      If Value then
        FGrid.Options:=FGrid.Options+[dgMultiSelect]
      Else
        FGrid.Options:=FGrid.Options-[dgMultiSelect]
    End;
  End;
end;

procedure TDCLGrid.SetNewQuery(Data: TDataSource);
begin
  FQueryGlob:=TDCLQuery.Create(FDCLLogOn.FDBLogOn);
  FQueryGlob.Name:='DCLQuery_'+FDCLForm.DialogName+'_'+IntToStr(UpTime);

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

  If Assigned(Data) then
    FQueryGlob.DataSource:=Data;

  FData.DataSet:=FQueryGlob;
end;

procedure TDCLGrid.SetQuery(Query: TDCLQuery);
begin
  If Assigned(Query) then
    FData.DataSet:=Query;
end;

procedure TDCLGrid.SetReadOnly(Value: Boolean);
begin
  FReadOnly:=Value;

  if Value then
  Begin
    If Assigned(Navig) Then
      Navig.VisibleButtons:=Navig.VisibleButtons-NavigatorEditButtons;
    If Assigned(FGrid) then
      FGrid.Options:=FGrid.Options+[dgEditing];
  End
  Else
  Begin
    If Assigned(Navig) Then
      Navig.VisibleButtons:=Navig.VisibleButtons+NavigatorEditButtons;
    If Assigned(FGrid) then
      FGrid.Options:=FGrid.Options-[dgEditing];
  End
end;

{ procedure TDCLGrid.SetRequiredFields;
  Var
  v1:Word;
  Begin
  $IFDEF BDE_or_IB
  If Assigned(FQuery) then
  If FQuery.Active then
  For v1:=0 to FQuery.FieldCount-1 do
  FQuery.Fields[v1].Required:=False;
  $ENDIF
  End; }

procedure TDCLGrid.SetSQL(SQL: String);
begin
  FQuery.SQL.Text:=SQL;
end;

procedure TDCLGrid.SetSQLDBFilter(SQL: String);
var
  l: Integer;
begin
  l:=length(DBFilters);
  If l>0 then
    DBFilters[l-1].FilterQuery.SQL.Text:=SQL;
end;

procedure TDCLGrid.SetSQLToStore(SQL: String; QueryType: TQueryType; Raight: TUserLevelsType);
var
  l: Word;
begin
  l:=length(QuerysStore);
  SetLength(QuerysStore, l+1);
  QuerysStore[l].QueryStr:=SQL;
  QuerysStore[l].QuryType:=QueryType;
  QuerysStore[l].QueryRaights:=Raight;
end;

procedure TDCLGrid.SetTablePart(Index: Integer; Value: TDCLGrid);
begin
  If length(FTableParts)>Index then
    FTableParts[Index]:=Value;
end;

procedure TDCLGrid.Show;
var
  i1: Integer;
  TollButton: TDialogSpeedButton;

procedure SetPopupMenuItems(WithStructure:Boolean);
begin
  AddPopupMenuItem(SourceToInterface(GetDCLMessageString(msFind)), 'Find', PFind, 'Ctrl+F', 0, 'Find');
  AddPopupMenuItem(SourceToInterface(GetDCLMessageString(msPrint)), 'Print', Print, 'Ctrl+P', 0, 'Print');
  If WithStructure then
    AddPopupMenuItem(SourceToInterface(GetDCLMessageString(msStructure)), 'Structure', Structure, 'Ctrl+S', 0, 'Structure');
  AddPopupMenuItem('-', 'Separator1', Nil, '', 0, '');
  AddPopupMenuItem(SourceToInterface(GetDCLMessageString(msCopy)), 'Copy', PCopy, 'Ctrl+C', 0, 'Copy');
  AddPopupMenuItem(SourceToInterface(GetDCLMessageString(msCut)), 'Cut', PCut, 'Ctrl+X', 0, 'Cut');
  AddPopupMenuItem(SourceToInterface(GetDCLMessageString(msPast)), 'Paste', PPaste, 'Ctrl+V', 0, 'Paste');
  AddPopupMenuItem('-', 'Separator2', Nil, '', 0, '');
  AddPopupMenuItem(SourceToInterface(GetDCLMessageString(msCancel)), 'Undo', PUndo, 'Ctrl+U', 0, 'Undo');
  AddPopupMenuItem('-', 'Separator3', Nil, '', 0, '');

  If (KeyMarks.KeyField<>'')And FieldExists(KeyMarks.KeyField, FQuery) Then
    AddPopupMenuItem(SourceToInterface(GetDCLMessageString(msBookmark)), 'GetBookMark', SetBookMark, 'Ctrl+B', 0, 'BookMark');
end;

begin
  If FUserLevelLocal<ulExecute then
    If FUserLevelLocal<ulWrite then
    Begin
      AddNotAllowedOperation(dsoInsert);
      AddNotAllowedOperation(dsoDelete);
      AddNotAllowedOperation(dsoEdit);
    End;

  If Assigned(FQuery) then
    FQuery.NotAllowOperations:=NotAllowedOperations;

  If Assigned(Navig) then
  Begin
    If FindNotAllowedOperation(dsoDelete) then
      Navig.VisibleButtons:=Navig.VisibleButtons-[nbDelete];
    If FindNotAllowedOperation(dsoInsert) then
      Navig.VisibleButtons:=Navig.VisibleButtons-[nbInsert];
    If FindNotAllowedOperation(dsoEdit) then
      Navig.VisibleButtons:=Navig.VisibleButtons-[nbEdit];
  End;

  If not FShowed then
  Begin
    if FDisplayMode in TDataGrid then
    begin
      FGrid:=TDBGrid.Create(FGridPanel);
      FGrid.Parent:=FGridPanel;
      FGrid.DataSource:=FData;
      FGrid.Align:=alClient;
      FGrid.OnDblClick:=GridDblClick;
      FGrid.OnTitleClick:=SortDB;
{$IFDEF FPC}
      FGrid.AlternateColor:=GridAlternateColor;
{$ENDIF}
      If not GPT.DisableColors Then
      Begin
        FGrid.DefaultDrawing:=true;
        FGrid.OnDrawColumnCell:=GridDrawDataCell;
      End;

      PopupGridMenu:=TPopupMenu.Create(FGrid);

      SetPopupMenuItems(True);

      CreateBookMarkMenu;

      FGrid.PopupMenu:=PopupGridMenu;
    End;

    if FDisplayMode in TDataFields then
    begin
      FieldPanel:=TDialogPanel.Create(FGridPanel);
      FieldPanel.Parent:=FGridPanel;
      FieldPanel.Align:=alClient;

      PopupGridMenu:=TPopupMenu.Create(FieldPanel);

      SetPopupMenuItems(False);

      CreateBookMarkMenu;

      FieldPanel.PopupMenu:=PopupGridMenu;
    end;

    ToolButtonsCount:=0;
    For i1:=1 To ToolCommandsCount Do
    Begin
      If ((FDisplayMode in TDataGrid)and(i1=1))or(FQuery.Active and(i1 in [2, 3])) then
      Begin
        TollButton:=TSpeedButton.Create(ToolButtonPanel);
        TollButton.Parent:=ToolButtonPanel;
        TollButton.Align:=alLeft;
        TollButton.Left:=50;
        TollButton.Flat:=ToolButtonsFlat;
        TollButton.Glyph:=DrawBMPButton(ToolButtonsCmd[i1]);
        TollButton.OnClick:=ToolButtonsOnClick;
        TollButton.Tag:=i1;

        Inc(ToolButtonsCount);
        ToolButtonPanelButtons[ToolButtonsCount]:=TollButton;
        ToolCommands[ToolButtonsCount]:=ToolButtonsCmd[i1];
      End;
    End;

    If ToolButtonsCount=0 then
      FreeAndNil(ToolButtonPanel);
  End;
  FShowed:=true;
end;

procedure TDCLGrid.SortDB(Column: TColumn);
Var
  SortIt: Boolean;
  v1: Byte;
  OrderBy, tmpSQL1: String;
Begin
  SortIt:=true;
  If length(OrderByFields)>0 Then
  Begin
    SortIt:=False;
    For v1:=1 To length(OrderByFields) Do
      If LowerCase(Column.FieldName)=LowerCase(OrderByFields[v1-1]) Then
      Begin
        SortIt:=true;
        break;
      End;
  End;

  If SortIt Then
  Begin
    FQuery.Close;
    tmpSQL1:=FQuery.SQL.Text;
    If PosEx('order by', tmpSQL1)<>0 Then
    Begin
      OrderBy:=Copy(tmpSQL1, PosEx(' order by', tmpSQL1), Length(tmpSQL1));
      Delete(tmpSQL1, PosEx(' order by', tmpSQL1), Length(tmpSQL1));
    End;

    If KeyState(VK_CONTROL) Then
      OrderBy:=OrderBy+', '+Column.FieldName
    Else
      OrderBy:=' order by '+Column.FieldName;

    FQuery.SQL.Text:=tmpSQL1+' '+OrderBy;

    ReFreshQuery;

    If PreviousColumnIndex<>-1 Then
      FGrid.Columns[PreviousColumnIndex].Title.Font.Style:=FGrid.Columns[PreviousColumnIndex]
        .Title.Font.Style-[fsBold];
    Column.Title.Font.Style:=Column.Title.Font.Style+[fsBold];

    PreviousColumnIndex:=Column.Index;
  End;
End;

procedure TDCLGrid.Structure(Sender: TObject);
var
  v1, v2: Word;
begin
  If FDisplayMode in TDataGrid Then
    If Not Assigned(FieldsList) Then
    Begin
      FGrid.Align:=alLeft;
      v1:=FGrid.Width Div 2;
      FGrid.Width:=v1;

      Splitter1:=TSplitter.Create(FGridPanel);
      Splitter1.Parent:=FGridPanel;
      Splitter1.Left:=(FDCLForm.FForm.Width Div 2)+10;

      ColumnsList:=TListBox.Create(FGridPanel);
      ColumnsList.Parent:=FGridPanel;
      ColumnsList.OnDblClick:=ColumnsManege;
      ColumnsList.Left:=(FDCLForm.FForm.Width Div 2)+10;
      ColumnsList.Align:=alLeft;

      Splitter2:=TSplitter.Create(FGridPanel);
      Splitter2.Parent:=FGridPanel;
      Splitter2.Left:=FDCLForm.FForm.Width-10;

      FieldsList:=TListBox.Create(FGridPanel);
      FieldsList.Parent:=FGridPanel;
      FieldsList.Left:=FDCLForm.FForm.Width-5;
      FieldsList.OnDblClick:=FieldsManege;

      FieldsList.Align:=alClient;
      v2:=v1 Div 2;
      ColumnsList.Width:=v2;
      FieldsList.Width:=v2;

      SetLength(StructModify, FGrid.Columns.Count);
      For v1:=0 To FGrid.Columns.Count-1 Do
      Begin
        ColumnsList.Items.Append(FGrid.Columns[v1].Title.Caption+'\'+FGrid.Columns[v1].FieldName);
        StructModify[v1].ColumnsListField:=FGrid.Columns[v1].FieldName;
        StructModify[v1].ColumnsListCaption:=FGrid.Columns[v1].Title.Caption;
      End;

      If length(StructModify)<length(DataFields) then
        SetLength(StructModify, length(DataFields));
      If length(DataFields)>0 then
        For v1:=0 to length(DataFields)-1 do
        Begin
          FieldsList.Items.Append(DataFields[v1].Caption+'\'+DataFields[v1].Name);

          StructModify[v1].FieldsListCaption:=DataFields[v1].Caption;
          StructModify[v1].FieldsListField:=DataFields[v1].Name;
        End;
    End
    Else
    Begin
      FreeAndNil(FieldsList);
      FreeAndNil(ColumnsList);
      FreeAndNil(Splitter1);
      FreeAndNil(Splitter2);
      FGrid.Align:=alClient;
    End;
end;

procedure TDCLGrid.ToolButtonsOnClick(Sender: TObject);
Var
  NumBtn: Integer;
Begin
  NumBtn:=(Sender As TDialogSpeedButton).Tag;
  FDCLForm.ExecCommand(ToolCommands[NumBtn]);
End;

procedure TDCLGrid.TranslateVal(var Params: String);
Var
  FFactor: Word;
Begin
  RePlaseParams(Params);
  FDCLForm.RePlaseVariables(Params);
  FFactor:=0;
  TranslateProc(Params, FFactor);
End;

{ TDCLCommandButton }

procedure TDCLCommandButton.AddCommand(Parent: TWinControl; ButtonParams: RButtonParams);
var
  FButtonsCount: Integer;
begin
  FButtonsCount:=length(Commands);
  inc(FButtonsCount);
  SetLength(Commands, FButtonsCount);
  SetLength(CommandButton, FButtonsCount);

  CommandButton[FButtonsCount-1]:=TDialogButton.Create(Parent);
  CommandButton[FButtonsCount-1].Parent:=Parent;
  CommandButton[FButtonsCount-1].Name:='CommandButton_'+IntToStr(FButtonsCount);
  CommandButton[FButtonsCount-1].Tag:=FButtonsCount-1;
  CommandButton[FButtonsCount-1].Caption:=ButtonParams.Caption;
  CommandButton[FButtonsCount-1].Hint:=ButtonParams.Hint;
  CommandButton[FButtonsCount-1].OnClick:=ExecCommand;
  CommandButton[FButtonsCount-1].Top:=ButtonParams.Top;
  CommandButton[FButtonsCount-1].Left:=ButtonParams.Left;
  CommandButton[FButtonsCount-1].Width:=ButtonParams.Width;
  CommandButton[FButtonsCount-1].Height:=ButtonParams.Height;

  CommandButton[FButtonsCount-1].Default:=ButtonParams.Default;
  CommandButton[FButtonsCount-1].Cancel:=ButtonParams.Cancel;

  CommandButton[FButtonsCount-1].Glyph.Transparent:=true;
  If ButtonParams.Pict<>'' then
    CommandButton[FButtonsCount-1].Glyph.Assign(DrawBMPButton(ButtonParams.Pict));

  If ButtonParams.FontStyle=[fsBold] then
    CommandButton[FButtonsCount-1].Font.Style:=CommandButton[FButtonsCount-1].Font.Style+[fsBold];
  If ButtonParams.FontStyle=[fsItalic] then
    CommandButton[FButtonsCount-1].Font.Style:=CommandButton[FButtonsCount-1].Font.Style+[fsItalic];
  If ButtonParams.FontStyle=[fsUnderLine] then
    CommandButton[FButtonsCount-1].Font.Style:=CommandButton[FButtonsCount-1].Font.Style+
      [fsUnderLine];

  Commands[FButtonsCount-1]:=ButtonParams.Command;
end;

constructor TDCLCommandButton.Create(var DCLLogOn: TDCLLogOn; var DCLForm: TDCLForm);
begin
  FDCLForm:=DCLForm;
  FDCLLogOn:=DCLLogOn;
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
var
  v1: Integer;
begin
  SaveMainFormPos(DCLMainLogOn, DCLMainLogOn.MainForm, 'MainForm');

  For v1:=1 to DCLMainLogOn.FormsCount do
  Begin
    if Assigned(DCLMainLogOn.Forms[v1-1]) then
      If DCLMainLogOn.ActiveDCLForms[v1-1] then
        FreeAndNil(DCLMainLogOn.FForms[v1-1]);
  End;

  EndDCL;
end;

procedure TMainFormAction.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose:=False;
  If (Not GPT.ExitCnf)And(Not DownLoadProcess) Then
    CanClose:=true;
  If (GPT.ExitCnf)And(Not DownLoadProcess) Then
    If ShowErrorMessage(10, SourceToInterface(GetDCLMessageString(msDoYouWontTerminate)+' '+GetDCLMessageString(msApplication)+'?'))=1 Then
      CanClose:=true;

  If DownLoadProcess Then
    If ShowErrorMessage(10, SourceToInterface(GetDCLMessageString(msDownloadInProgress)+'.'+GetDCLMessageString(msDoYouWontTerminate)+' '+GetDCLMessageString(msApplication)+'?'))=1 Then
      CanClose:=true;
end;

{ TPrintBase }

procedure TPrintBase.Print(Grid: TDBGrid; Query: TDCLDialogQuery; Caption: String);
Var
  SeparatorLength, k, FieldsCounter: Word;
  Separator, S, S1, S2: String;
  PrintBox: TStringList;
Begin
  PrintBox:=TStringList.Create;
  If DefaultSystemEncoding=EncodingUTF8 Then
    PrintBox.Append(UTF8BOM+InterfaceToSystem(Caption))
  Else If DefaultSystemEncoding='utf16' Then
    PrintBox.Append(UTF16LEBOM+InterfaceToSystem(Caption))
  Else
    PrintBox.Append(InterfaceToSystem(Caption));

  PrintBox.Append('');
  S:='|';
  If Not Assigned(Grid) Then
  Begin
    For FieldsCounter:=0 To Query.FieldCount-1 Do
    Begin
      S1:='';
      S2:=InterfaceToSystem(Query.Fields[FieldsCounter].FieldName);
      If length(S2)>Query.Fields[FieldsCounter].DataSize Then
        SetLength(S2, Query.Fields[FieldsCounter].DataSize+1);
      S:=S+S2;
      For k:=length(InterfaceToSystem(Query.Fields[FieldsCounter].FieldName)) To Query.Fields[FieldsCounter]
        .DataSize Do
        S1:=S1+' ';
      S:=S+S1+'|';
    End;
    PrintBox.Append(S);
    SeparatorLength:=length(S)-1;
    Separator:='';
    For FieldsCounter:=0 To SeparatorLength Do
      Separator:=Separator+'-';
    PrintBox.Append(Separator);

    Query.First;
    While Not Query.Eof Do
    Begin
      S:='|';
      For FieldsCounter:=0 To Query.FieldCount-1 Do
      Begin
        S1:='';
        S2:=InterfaceToSystem(Query.Fields[FieldsCounter].AsString);
        If length(S2)>Query.Fields[FieldsCounter].DataSize Then
          SetLength(S2, Query.Fields[FieldsCounter].DataSize+1);
        S:=S+S2;
        For k:=length(InterfaceToSystem(Query.Fields[FieldsCounter].AsString)) To Query.Fields[FieldsCounter]
          .DataSize Do
          S1:=S1+' ';
        S:=S+S1+'|';
      End;
      PrintBox.Append(S);
      Query.Next;
    End;
    PrintBox.Append(Separator);
    Separator:='|'+IntToStr(Query.RecordCount);
  End
  Else
  Begin
    For FieldsCounter:=0 To Grid.Columns.Count-1 Do
    Begin
      S1:='';
      S2:=InterfaceToSystem(Grid.Columns[FieldsCounter].Title.Caption);
      If Length(S2)>(Grid.Columns[FieldsCounter].Width Div 7) Then
        SetLength(S2, (Grid.Columns[FieldsCounter].Width Div 7)+1);
      S:=S+S2;
      For k:=Length(InterfaceToSystem(Grid.Columns[FieldsCounter].Title.Caption))
        To (Grid.Columns[FieldsCounter].Width Div 7) Do
        S1:=S1+' ';
      S:=S+S1+'|';
    End;
    PrintBox.Append(S);
    SeparatorLength:=Length(S)-1;
    Separator:='';
    For FieldsCounter:=0 To SeparatorLength Do
      Separator:=Separator+'-';
    PrintBox.Append(Separator);

    Query.DisableControls;

    Query.First;
    While Not Query.Eof Do
    Begin
      S:='|';
      For FieldsCounter:=0 To Grid.Columns.Count-1 Do
      Begin
        S1:='';
        Try
          S2:=Grid.Columns[FieldsCounter].Field.AsString;
        Except
          S2:=SourceToInterface(GetDCLMessageString(msNoField));
        End;
        If Length(S2)>(Grid.Columns[FieldsCounter].Width Div 7) Then
          SetLength(S2, (Grid.Columns[FieldsCounter].Width Div 7)+1);
        S:=S+S2;
        For k:=Length(InterfaceToSystem(Grid.Columns[FieldsCounter].Field.AsString))
          To (Grid.Columns[FieldsCounter].Width Div 7) Do
          S1:=S1+' ';
        S:=S+S1+'|';
      End;
      PrintBox.Append(InterfaceToSystem(S));
      Query.Next;
    End;
    Query.EnableControls;
    PrintBox.Append(Separator);
    Separator:='|'+IntToStr(Query.RecordCount);
  End;
  For FieldsCounter:=length(Separator) To SeparatorLength-1 Do
    Separator:=Separator+' ';
  Separator:=Separator+'|';
  PrintBox.Append(Separator);

  PrintBox.SaveToFile(IncludeTrailingPathDelimiter(AppConfigDir)+'table.tmp');
  FreeAndNil(PrintBox);
  ExecApp('"'+GPT.Viewer+'" "'+IncludeTrailingPathDelimiter(AppConfigDir)+'table.tmp"');
End;

Procedure TDCLOfficeReport.ReportOpenOfficeWriter(ParamStr: String; Save: Boolean);
Var
  TextPointer, CursorPointer, BookmarksSupplier, InsLength, BookMark: Variant;
  BookmarckNum, LayotCount, FontSize: Word;
  DocNum: Cardinal;
  SQLStr, FileName, Ext, InsStr, BookMarkName, LayotStr, LayotItem: String;
  Layot: TStringList;
  DCLQuery: TDCLDialogQuery;

  ToPDF, ToHTML, ToWrite, BookmarkFromLayot: Boolean;
  FontStyleRec: TFontStyleRec;
Begin
{$IFDEF MSWINDOWS}
  Case OfficeTemplateFormat Of
  odtMSO:
  Ext:='doc';
  odtOO, odtPossible:
  Ext:='odt';
  End;

  LayotCount:=0;
  Layot:=TStringList.Create;
  FileName:=BinStor.GetTemplateFile(FindParam('TemplateName=', ParamStr),
    FindParam('FileName=', ParamStr), Ext);
  If BinStor.ErrorCode=0 Then
    If FileExists(FileName) Then
    Begin
      LayotStr:=FindParam('Layot=', ParamStr);
      If LayotStr<>'' Then
      Begin
        Layot.Clear;
        LayotCount:=ParamsCount(LayotStr);
        For BookmarckNum:=1 To ParamsCount(LayotStr) Do
        Begin
          BookmarkFromLayot:=true;
          LayotItem:=SortParams(LayotStr, BookmarckNum);

          Layot.Append(LayotItem);
        End;
      End;

      DCLQuery:=TDCLDialogQuery.Create(nil);
      DCLQuery.Name:='OfficeReport_'+IntToStr(UpTime);
      FDCLLogOn.SetDBName(DCLQuery);
      Try
        If VarIsEmpty(OO) Then
          OO:=CreateOleObject('com.sun.star.ServiceManager');

        Desktop:=OO.CreateInstance('com.sun.star.frame.Desktop');
        VariantArray:=VarArrayCreate([0, 0], varVariant);
        Case OfficeTemplateFormat Of
        odtMSO:
        VariantArray[0]:=MakePropertyValue(OO, 'FilterName', 'MS Word 97');
        odtOO, odtPossible:
        VariantArray[0]:=MakePropertyValue(OO, 'FilterName', 'writer8');
        End;
      Except
        ShowErrorMessage(-6002, '');
        Exit;
      End;

      If PosEx('ToPDF=1', ParamStr)<>0 Then
        ToPDF:=true
      Else
        ToPDF:=False;

      If PosEx('ToHTML=1', ParamStr)<>0 Then
        ToHTML:=true
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
      Try
        DCLQuery.Open;
      Except
        ShowErrorMessage(-1104, 'SQL='+SQLStr);
      End;
      DCLQuery.First;

      BookmarksSupplier:=Document.getBookmarks;
      If (Not BookmarkFromLayot)And(LayotCount=0) Then
        LayotCount:=BookmarksSupplier.Count;

      DocNum:=1;
      While Not DCLQuery.Eof Do
      Begin
        Document:=Desktop.LoadComponentFromURL(FileNameToURL(FileName), '_blank', 0, VariantArray);
        TextPointer:=Document.GetText;
        CursorPointer:=TextPointer.CreateTextCursor;

        For BookmarckNum:=0 To LayotCount-1 Do
        Begin
          Try
            FontSize:=0;
            If BookmarkFromLayot Then
            Begin
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
                FontStyleRec.Center:=true;
              If PosEx('S', LayotStr)<>0 Then
                FontStyleRec.StrikeThrough:=1;

              LayotStr:=ExtractSection(LayotItem);
              If LayotStr<>'' Then
                FontSize:=StrToIntEx(LayotStr);

              LayotStr:=ExtractSection(LayotItem);
              If LayotStr<>'' Then
                If PosEx('W', LayotStr)<>0 Then
                  ToWrite:=true
                Else
                  ToWrite:=False;
            End
            Else
              BookMarkName:=BookmarksSupplier.getByIndex(BookmarckNum).getName;

            If FieldExists(BookMarkName, DCLQuery) then
            Begin
              BookMark:=BookmarksSupplier.getByIndex(BookmarckNum).getAnchor;
              If ToWrite Then
                InsStr:=MoneyToString(DCLQuery.FieldByName(BookMarkName).AsCurrency, true, False)
              Else
                InsStr:=Trim(DCLQuery.FieldByName(BookMarkName).AsString);

              InsLength:=Variant(Length(InsStr));
              CursorPointer.GotoRange(BookMark.GetStart, False);
              CursorPointer.GoRight(InsLength, true);
              CursorPointer.setString('');
              If FontStyleRec.italic=1 then
                CursorPointer.setPropertyValue('CharPosture', Ord(fsItalic));
              If FontStyleRec.Bold=1 then
                CursorPointer.setPropertyValue('CharWeight', Ord(fsBold));
              If FontStyleRec.StrikeThrough=1 then
                CursorPointer.setPropertyValue('CharStrikeout', Ord(fsStrikeout));
              If FontStyleRec.Undeline=1 then
                CursorPointer.setPropertyValue('CharUnderline', Ord(fsUnderLine));
              If FontSize<>0 then
                CursorPointer.setPropertyValue('CharHeight', FontSize);

              CursorPointer.setString(InsStr);
            End;
          Except
            ShowErrorMessage(-5005, '');
          End;
        End;

        If ToPDF Then
          OOExportToFormat(Document, AddToFileName(FileName, '_'+IntToStr(DocNum)), 'pdf');

        If ToHTML Then
          OOExportToFormat(Document, AddToFileName(FileName, '_'+IntToStr(DocNum)), 'html');

        If Save Then
        Begin
          Case OfficeDocumentFormat Of
          odtMSO:
          Begin
            FileName:=FakeFileExt(FileName, 'doc');
            VariantArray[0]:=MakePropertyValue(OO, 'FilterName', 'MS Word 97');
          End;
          odtOO, odtPossible:
          Begin
            FileName:=FakeFileExt(FileName, 'odt');
            VariantArray[0]:=MakePropertyValue(OO, 'FilterName', 'writer8');
          End;
          End;

          Document.StoreAsURL(FileNameToURL(AddToFileName(FileName, '_'+IntToStr(DocNum))),
            VariantArray);
          Document.Close(true);
          Document:=Unassigned;
        End;

        If ToPDF Then
          Exec(FakeFileExt(AddToFileName(FileName, '_'+IntToStr(DocNum)), 'pdf'), '');

        If ToHTML Then
          Exec(FakeFileExt(AddToFileName(FileName, '_'+IntToStr(DocNum)), 'html'), '');

        inc(DocNum);
        DCLQuery.Next;
      End;
      DCLQuery.Close;

      If Not Save Then
        If FileName<>'' Then
          If FileExists(FileName) Then
            Try
              DeleteFile(PChar(FileName));
            Except
              //
            End;

      OO:=Unassigned;
    End
    Else
      ShowErrorMessage(-5006, FileName);
{$ENDIF}
End;

Procedure TDCLOfficeReport.ReportOpenOfficeCalc(ParamStr: String; Save: Boolean);
Var
  SQLStr, FileName, ColorStr, Ext: String;
  ToPDF, ToHTML, EnableRowChColor, EnableColChColor: Boolean;
  v1: Byte;
  RecRepNum: Cardinal;
  StartRow, StartCol, RowRColor, RowBColor, RowGColor, ColRColor, ColBColor, ColGColor: Integer;
  DCLQuery: TDCLDialogQuery;
Begin
{$IFDEF MSWINDOWS}
  Case OfficeTemplateFormat Of
  odtMSO:
  Ext:='xls';
  odtOO, odtPossible:
  Ext:='ods';
  End;

  FileName:=BinStor.GetTemplateFile(FindParam('TemplateName=', ParamStr),
    FindParam('FileName=', ParamStr), Ext);
  If BinStor.ErrorCode=0 Then
    If FileExists(FileName) Then
    Begin
      Try
        If VarIsEmpty(OO) Then
          OO:=CreateOleObject('com.sun.star.ServiceManager');
        Desktop:=OO.CreateInstance('com.sun.star.frame.Desktop');
        VariantArray:=VarArrayCreate([0, 0], varVariant);
        Case OfficeTemplateFormat Of
        odtMSO:
        VariantArray[0]:=MakePropertyValue(OO, 'FilterName', 'MS Excel 97');
        odtOO, odtPossible:
        VariantArray[0]:=MakePropertyValue(OO, 'FilterName', 'calc8');
        End;
        Document:=Desktop.LoadComponentFromURL(FileNameToURL(FileName), '_blank', 0, VariantArray);
        Sheets:=Document.GetSheets;
        Sheet:=Sheets.getByIndex(0);
      Except
        ShowErrorMessage(-6001, '');
        Exit;
      End;
      Try
        Range:=Sheet.getCellRangeByName('DATA');
        StartRow:=Range.RangeAddress.StartRow;
        StartCol:=Range.RangeAddress.StartColumn;
      Except
        ShowErrorMessage(-5002, '');
        Exit;
      End;

      SQLStr:=FindParam('SQL=', ParamStr);
      If (SQLStr='')and Assigned(FDCLGrid) Then
        SQLStr:=FDCLGrid.Query.SQL.Text;

      If Assigned(FDCLGrid) Then
        FDCLGrid.TranslateVal(SQLStr);
      DCLQuery:=TDCLDialogQuery.Create(nil);
      DCLQuery.Name:='OfficeReport2_'+IntToStr(UpTime);
      FDCLLogOn.SetDBName(DCLQuery);
      DCLQuery.SQL.Text:=SQLStr;
      Try
        DCLQuery.Open;
      Except
        ShowErrorMessage(-1104, 'SQL='+SQLStr);
      End;
      DCLQuery.First;

      If PosEx('ToPDF=1', ParamStr)<>0 Then
        ToPDF:=true
      Else
        ToPDF:=False;

      If PosEx('ToHTML=1', ParamStr)<>0 Then
        ToHTML:=true
      Else
        ToHTML:=False;

      EnableRowChColor:=False;
      ColorStr:=FindParam('AlternationRowBackColor=', ParamStr);
      If ColorStr<>'' Then
      Begin
        RowRColor:=HexToInt(Copy(ColorStr, 1, 2));
        RowBColor:=HexToInt(Copy(ColorStr, 3, 2));
        RowGColor:=HexToInt(Copy(ColorStr, 5, 2));
        EnableRowChColor:=true;
      End;

      EnableColChColor:=False;
      ColorStr:=FindParam('AlternationColBackColor=', ParamStr);
      If ColorStr<>'' Then
      Begin
        ColRColor:=HexToInt(Copy(ColorStr, 1, 2));
        ColBColor:=HexToInt(Copy(ColorStr, 3, 2));
        ColGColor:=HexToInt(Copy(ColorStr, 5, 2));
        EnableColChColor:=true;
      End;

      RecRepNum:=1;
      While Not DCLQuery.Eof Do
      Begin
        For v1:=0 To DCLQuery.FieldCount-1 Do
        Begin
          SQLStr:=TrimRight(DCLQuery.Fields[v1].AsString);
          InsertTextByXY(Sheet, Cell, uStringParams.UTF8ToAnsi(SQLStr), RecRepNum+StartRow-1,
            v1+1+StartCol-1);
          If EnableRowChColor Then
            If RecRepNum Mod 2=0 Then
              Cell.cellBackColor:=(RowRColor Or(RowGColor Shl 8)Or(RowBColor Shl 16));
          If EnableColChColor Then
            If v1 Mod 2=0 Then
              Cell.cellBackColor:=(ColRColor Or(ColGColor Shl 8)Or(ColBColor Shl 16));
        End;
        inc(RecRepNum);
        DCLQuery.Next;
      End;
      DCLQuery.Close;

      If ToPDF Then
        OOExportToFormat(Document, FileName, 'pdf');

      If ToHTML Then
        OOExportToFormat(Document, FileName, 'html');

      If Save Then
      Begin
        Case OfficeDocumentFormat Of
        odtMSO:
        Begin
          FileName:=FakeFileExt(FileName, 'xls');
          VariantArray[0]:=MakePropertyValue(OO, 'FilterName', 'MS Excel 97');
        End;
        odtOO, odtPossible:
        Begin
          FileName:=FakeFileExt(FileName, 'ods');
          VariantArray[0]:=MakePropertyValue(OO, 'FilterName', 'calc8');
        End;
        End;

        Document.StoreAsURL(FileNameToURL(FileName), VariantArray);
        Document.Close(true);
        Document:=Unassigned;
      End;
      OO:=Unassigned;

      If Not Save Then
        If FileName<>'' Then
          If FileExists(FileName) Then
            Try
              DeleteFile(PChar(FileName));
            Except
              //
            End;

      If ToPDF Then
        Exec(FakeFileExt(FileName, 'pdf'), '');

      If ToHTML Then
        Exec(FakeFileExt(FileName, 'html'), '');
    End
    Else
      ShowErrorMessage(-5007, FileName);
{$ENDIF}
End;

Procedure TDCLOfficeReport.ReportWord(ParamStr: String; Save: Boolean);
{$IFDEF MSWINDOWS}
Var
  StV: OleVariant;
  SQLStr, FileName, LayotStr, LayotItem, BookmarckName: String;
  Layot: TStringList;
  DocNum: Cardinal;
  ParamNum, BookmarckNum, LayotCount, FontSize: Byte;

  ToWrite, BookmarkFromLayot: Boolean;
  FontStyleRec: TFontStyleRec;
  DCLQuery: TDCLDialogQuery;
{$ENDIF}
Begin
{$IFDEF MSWINDOWS}
  LayotCount:=0;
  Layot:=TStringList.Create;
  FileName:=BinStor.GetTemplateFile(FindParam('TemplateName=', ParamStr),
    FindParam('FileName=', ParamStr), 'doc');
  If BinStor.ErrorCode=0 Then
    If FileExists(FileName) Then
    Begin
      LayotStr:=FindParam('Layot=', ParamStr);
      If LayotStr<>'' Then
      Begin
        Layot.Clear;
        LayotCount:=ParamsCount(LayotStr);
        For ParamNum:=1 To ParamsCount(LayotStr) Do
        Begin
          BookmarkFromLayot:=true;
          LayotItem:=SortParams(LayotStr, ParamNum);

          Layot.Append(LayotItem);
        End;
      End;

      SQLStr:=FindParam('SQL=', ParamStr);
      If (SQLStr='')and Assigned(FDCLGrid) Then
        SQLStr:=FDCLGrid.Query.SQL.Text;

      If Assigned(FDCLGrid) Then
        FDCLGrid.TranslateVal(SQLStr);
      DCLQuery:=TDCLDialogQuery.Create(nil);
      DCLQuery.Name:='OfRep3_'+IntToStr(UpTime);
      FDCLLogOn.SetDBName(DCLQuery);
      DCLQuery.SQL.Text:=SQLStr;
      Try
        DCLQuery.Open;
      Except
        ShowErrorMessage(-1104, 'SQL='+SQLStr);
      End;
      DCLQuery.First;

      If (Not BookmarkFromLayot)And(LayotCount=0) Then
        LayotCount:=MsWord.ActiveDocument.BookMarks.Count;

      DocNum:=1;
      While Not DCLQuery.Eof Do
      Begin
        WordRun(MsWord);
        WordOpen(MsWord, FileName);

        For BookmarckNum:=0 To LayotCount-1 Do
        Begin
          If BookmarkFromLayot Then
          Begin
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
              FontStyleRec.Center:=true;
            If PosEx('S', LayotStr)<>0 Then
              FontStyleRec.StrikeThrough:=1;

            LayotStr:=ExtractSection(LayotItem);
            If LayotStr<>'' Then
              FontSize:=StrToIntEx(LayotStr);

            LayotStr:=ExtractSection(LayotItem);
            If LayotStr<>'' Then
              If PosEx('W', LayotStr)<>0 Then
                ToWrite:=true
              Else
                ToWrite:=False;
          End
          Else
            BookmarckName:=MsWord.ActiveDocument.BookMarks.Item(BookmarckNum+1).Name;

          StV:='';
          If FieldExists(BookmarckName, DCLQuery) then
            If ToWrite Then
              StV:=MoneyToString(DCLQuery.FieldByName(BookmarckName).AsCurrency, true, False)
            Else
              StV:=Trim(DCLQuery.FieldByName(BookmarckName).AsString);

          WordInsert(MsWord, BookmarckName, StV, FontStyleRec.Bold, FontStyleRec.italic,
            FontStyleRec.StrikeThrough, FontStyleRec.Undeline, FontSize, FontStyleRec.Center);

          If Save Then
          Begin
            StV:=AddToFileName(FileName, '_'+IntToStr(DocNum));
            If WordVer=9 Then
              MsWord.ActiveDocument.SaveAs(StV, EmptyParam, EmptyParam, EmptyParam, EmptyParam,
                EmptyParam, EmptyParam, EmptyParam, EmptyParam, EmptyParam) // Word 2000
            Else If WordVer>9 Then
              MsWord.ActiveDocument.SaveAs(StV, EmptyParam, EmptyParam, EmptyParam, EmptyParam,
                EmptyParam, EmptyParam, EmptyParam, EmptyParam, EmptyParam, EmptyParam, EmptyParam,
                EmptyParam, EmptyParam, EmptyParam, EmptyParam); // Word XP

            StV:=true;
            MsWord.ActiveDocument.Close(StV, EmptyParam, EmptyParam);
          End;
        End;
        DCLQuery.Next;
      End;
      If Save Then
        WordClose(MsWord);
    End
    Else
      ShowErrorMessage(-5004, FileName);

  FreeAndNil(Layot);
{$ENDIF}
End;

Procedure TDCLOfficeReport.ReportExcel(ParamStr: String; Save: Boolean);
Var
  SQLStr, FileName, ColorStr: String;
  v1: Byte;
  EnableRowChColor, EnableColChColor: Boolean;
  RecRepNum: Word;
  RowRColor, RowBColor, RowGColor, ColRColor, ColBColor, ColGColor: Integer;
  DCLQuery: TDCLDialogQuery;
Begin
{$IFDEF MSWINDOWS}
  FileName:=BinStor.GetTemplateFile(FindParam('TemplateName=', ParamStr),
    FindParam('FileName=', ParamStr), 'xls');
  If BinStor.ErrorCode=0 Then
    If FileExists(FileName) Then
    Begin
      Try
        Excel:=CreateOleObject('Excel.Application');
        Excel.Visible:=False;
        WBk:=Excel.WorkBooks.Add(FileName);
      Except
        ShowErrorMessage(-6000, '');
        Exit;
      End;
      Try
        Excel.ActiveSheet.Range['DATA'].Select;
      Except
        ShowErrorMessage(-5002, '');
        Excel.Visible:=true;
        Exit;
      End;

      SQLStr:=FindParam('SQL=', ParamStr);
      If (SQLStr='')and Assigned(FDCLGrid) Then
        SQLStr:=FDCLGrid.Query.SQL.Text;

      If Assigned(FDCLGrid) Then
        FDCLGrid.TranslateVal(SQLStr);
      DCLQuery:=TDCLDialogQuery.Create(nil);
      DCLQuery.Name:='OfRep4_'+IntToStr(UpTime);
      FDCLLogOn.SetDBName(DCLQuery);
      DCLQuery.SQL.Text:=SQLStr;
      Try
        DCLQuery.Open;
      Except
        ShowErrorMessage(-1104, 'SQL='+SQLStr);
      End;
      DCLQuery.First;

      EnableRowChColor:=False;
      ColorStr:=FindParam('AlternationRowBackColor=', ParamStr);
      If ColorStr<>'' Then
      Begin
        RowRColor:=HexToInt(Copy(ColorStr, 1, 2));
        RowBColor:=HexToInt(Copy(ColorStr, 3, 2));
        RowGColor:=HexToInt(Copy(ColorStr, 5, 2));
        EnableRowChColor:=true;
      End;

      EnableColChColor:=False;
      ColorStr:=FindParam('AlternationColBackColor=', ParamStr);
      If ColorStr<>'' Then
      Begin
        ColRColor:=HexToInt(Copy(ColorStr, 1, 2));
        ColBColor:=HexToInt(Copy(ColorStr, 3, 2));
        ColGColor:=HexToInt(Copy(ColorStr, 5, 2));
        EnableColChColor:=true;
      End;

      RecRepNum:=1;
      While Not DCLQuery.Eof Do
      Begin
        For v1:=0 To DCLQuery.FieldCount-1 Do
        Begin
          Excel.ActiveSheet.Range['DATA'].Cells.Item[RecRepNum, v1+1]:=
            Trim(DCLQuery.Fields[v1].AsString);
          If EnableRowChColor Then
            If RecRepNum Mod 2=0 Then
              Excel.ActiveSheet.Range['DATA'].Cells.Item[RecRepNum, v1+1].Interior.Color:=
                RGB(RowRColor, RowGColor, RowBColor);
          If EnableColChColor Then
            If v1 Mod 2=0 Then
              Excel.ActiveSheet.Range['DATA'].Cells.Item[RecRepNum, v1+1].Interior.Color:=
                RGB(ColRColor, ColGColor, ColBColor);
        End;
        inc(RecRepNum);
        DCLQuery.Next;
      End;
      DCLQuery.Close;

      If Save Then
      Begin
        ExcelSave(Excel, FileName);
        ExcelQuit(Excel);
      End
      Else
        Excel.Visible:=true;
    End
    Else
      ShowErrorMessage(-5004, FileName);
{$ENDIF}
End;

// ==============================Reports===============================

Procedure DeleteInString(Var S: String; Index, Count: LongInt);
Var
  T, t1: LongInt;
Begin
  T:=Index;
  t1:=T;
  While (S[T]<>#10)And(T<=Length(S))And(T-t1<=Count-1) Do
  Begin
    inc(T);
  End;
  Delete(S, Index, T-t1);
End;

Procedure FillCopy(Source: String; Var Dest: String; Start, FillLength, ReplaceLen: Cardinal;
  Align: String);
Var
  T, t1: Cardinal;
  tmpL: String;
Begin
  DeleteInString(Dest, Start, ReplaceLen);
  tmpL:=Source;
  t1:=Length(Source);
  If PosEx('I', Align)<>0 Then
    DeleteInString(Dest, Start, FillLength);

  If PosEx('I', Align)=0 Then
  Begin
    If PosEx('L', Align)<>0 Then
      If FillLength>t1 Then
        For T:=Length(tmpL)+1 To FillLength Do
          tmpL:=tmpL+' ';
    If PosEx('R', Align)<>0 Then
      If FillLength>t1 Then
        For T:=Length(tmpL)+1 To FillLength Do
          tmpL:=' '+tmpL;
    If PosEx('M', Align)<>0 Then
    Begin
      If FillLength>t1 Then
      Begin
        For T:=1 To (FillLength Div 2)-(t1 Div 2) Do
          tmpL:=' '+tmpL;
        For T:=(FillLength Div 2)-(t1 Div 2)+t1+1 To FillLength Do
          tmpL:=tmpL+' ';
      End;
    End;
  End;
  Insert(Copy(tmpL, 1, FillLength), Dest, Start);
End;

procedure TDCLTextReport.GrabValOnEdit(Sender: TObject);
Begin
  If length(VarsToControls)>(Sender As TEdit).Tag Then
    FDCLLogOn.Variables.Variables[VarsToControls[(Sender As TEdit).Tag]]:=(Sender As TEdit).Text;
End;

procedure TDCLTextReport.ValComboOnChange(Sender: TObject);
Var
  val: String;
Begin
  If length(VarsToControls)>(Sender As TDBLookupComboBox).Tag Then
  Begin
    If (Sender As TDBLookupComboBox).KeyValue=null Then
      val:=''
    Else
      val:=(Sender As TDBLookupComboBox).KeyValue;

    FDCLLogOn.Variables.Variables[VarsToControls[(Sender As TDBLookupComboBox).Tag]]:=val;
  End;
End;

procedure TDCLTextReport.GrabDialogButtonsOnClick(Sender: TObject);
Begin
  If (Sender As TButton).Tag=0 Then
  Begin
    GrabValueForm.Close;
    FDialogRes:=mrOk;
  End;
  If (Sender As TButton).Tag=1 Then
  Begin
    GrabValueForm.Close;
    FDialogRes:=mrCancel;
  End;
End;

procedure TDCLTextReport.GrabDateOnChange(Sender: TObject);
Begin
  If length(VarsToControls)>(Sender As DateTimePicker).Tag Then
    FDCLLogOn.Variables.Variables[VarsToControls[(Sender As DateTimePicker).Tag]]:=
      DateToStr((Sender As DateTimePicker).Date);
End;

procedure TDCLTextReport.GrabValListOnChange(Sender: TObject);
Begin
  If length(VarsToControls)>(Sender As TComboBox).Tag Then
    FDCLLogOn.Variables.Variables[VarsToControls[(Sender As TComboBox).Tag]]:=
      (Sender As TComboBox).Text;
End;

constructor TDCLTextReport.InitReport(DCLLogOn: TDCLLogOn; DCLGrid: TDCLGrid; OPL: TStringList;
  ParamsSet: Cardinal; Mode: TNewQueryMode);
Var
  RepParamsSet: TDCLDialogQuery;
  NewNew, GrabFormYes: Boolean;
  GrabValueEdit: TEdit;
  GrabDBLookupCombo: TDBLookupComboBox;
  GrabQuery: TDCLDialogQuery;
  GrabValueList: TComboBox;
  GrabDS: TDataSource;
  BtOk, BtCancel: TButton;
  ParamsCountList: Byte;
  ElementsTop: Word;
  GrabLabel: TDialogLabel;
  GrabDate: DateTimePicker;
  LocalVar1, LocalVar2, RecCount: Word;
  tmpSQL, tmpSQL1: string;

  Procedure CreateGrabForm;
  Begin
    If not GrabFormYes Then
    Begin
      GrabFormYes:=true;
      FDialogRes:=mrCancel;
      GrabValueForm:=TForm.Create(Nil);
      GrabValueForm.Position:=poScreenCenter;
      GrabValueForm.BorderStyle:=bsSingle;
      GrabValueForm.BorderIcons:=[biSystemMenu, biMinimize];
      GrabValueForm.Caption:=SourceToInterface(GetDCLMessageString(msInputVulues));
    End;
  End;

Begin
  CodePage:=rcp1251;
  FSaved:=true;
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
  Begin
    RepParamsSet:=TDCLDialogQuery.Create(Nil);
    RepParamsSet.Name:='RepParamsSet_'+IntToStr(UpTime);
    FDCLLogOn.SetDBName(RepParamsSet);
    RepParamsSet.SQL.Text:=FDCLLogOn.GetRolesQueryText(qtCount, ' s.'+GPT.ParentFlgField+'='+
      IntToStr(ParamsSet));
    RepParamsSet.Open;
    RecCount:=RepParamsSet.Fields[0].AsInteger;
    If RecCount>0 Then
    Begin
      RepParamsSet.Close;
      RepParamsSet.SQL.Text:=FDCLLogOn.GetRolesQueryText(qtSelect, ' s.'+GPT.ParentFlgField+'='+
        IntToStr(ParamsSet));
      RepParamsSet.Open;

      While Not RepParamsSet.Eof Do
      Begin
        RepParams.Append(Trim(RepParamsSet.FieldByName(GPT.DCLNameField)
          .AsString));
        RepParams.Append(Trim(RepParamsSet.FieldByName(GPT.DCLTextField)
          .AsString));
        RepParamsSet.Next;
      End;
    End;
    RepParamsSet.Close;
    FreeAndNil(RepParamsSet);
  End;

  ElementsTop:=BeginStepTop;
  If InitSkrypts.Count>0 Then
    For LocalVar1:=0 To InitSkrypts.Count-1 Do
    Begin
      If PosEx('DeclareVariable=', InitSkrypts[LocalVar1])<>0 Then
      Begin
        FDCLLogOn.Variables.NewVariable(FindParam('DeclareVariable=', InitSkrypts[LocalVar1]));
      End;

      If PosEx('GrabValueList=', InitSkrypts[LocalVar1])<>0 Then
      Begin
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
        FDCLLogOn.Variables.NewVariable(tmpSQL);
        GrabValueList:=TComboBox.Create(GrabValueForm);
        GrabValueList.Parent:=GrabValueForm;
        GrabValueList.Name:='GrabValList_'+IntToStr(LocalVar1);
        GrabValueList.Text:='';
        GrabValueList.Tag:=SetVarToControl(tmpSQL);

        tmpSQL:=FindParam('ListValues=', InitSkrypts[LocalVar1]);
        ParamsCountList:=ParamsCount(tmpSQL);
        For LocalVar2:=1 To ParamsCountList Do
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
      End;

      If PosEx('GrabValue=', InitSkrypts[LocalVar1])<>0 Then
      Begin
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
        GrabValueEdit.Tag:=SetVarToControl(FindParam('GrabValue=', InitSkrypts[LocalVar1]));

        inc(ElementsTop, EditTopStep);
      End;

      If PosEx('GrabValueFromBase=', InitSkrypts[LocalVar1])<>0 Then
      Begin
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

        GrabQuery:=TDCLDialogQuery.Create(Nil);
        GrabQuery.Name:='RepGabQ_'+IntToStr(UpTime);
        tmpSQL1:=FindParam('SQL=', InitSkrypts[LocalVar1]);
        RePlaseVariables(tmpSQL1);
        GrabQuery.SQL.Text:=tmpSQL1;

        FDCLLogOn.SetDBName(GrabQuery);
        Try
          GrabQuery.Open;
          GrabQuery.Last;
          GrabQuery.First;
          GrabDS:=TDataSource.Create(Nil);
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
          ShowErrorMessage(-1108, 'SQL='+tmpSQL1);
        End;

        inc(ElementsTop, EditTopStep);
      End;

      If PosEx('GrabDate=', InitSkrypts[LocalVar1])<>0 Then
      Begin
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
      End;
    End;

  If GrabFormYes Then
  Begin
    GrabValueForm.ClientHeight:=ElementsTop+BeginStepTop+ButtonPanelHeight;
    BtOk:=TButton.Create(GrabValueForm);
    BtOk.Parent:=GrabValueForm;
    BtOk.Tag:=0;
    BtOk.Caption:='OK';
    BtOk.Default:=true;
    BtCancel:=TButton.Create(GrabValueForm);
    BtCancel.Parent:=GrabValueForm;
    BtCancel.Tag:=1;
    BtCancel.Caption:='Cancel';
    BtCancel.Cancel:=true;
    BtOk.OnClick:=GrabDialogButtonsOnClick;
    BtCancel.OnClick:=GrabDialogButtonsOnClick;

    BtOk.Top:=GrabValueForm.ClientHeight-35;
    BtCancel.Top:=GrabValueForm.ClientHeight-35;
    BtOk.Left:=10;
    BtCancel.Left:=95;
    GrabValueForm.ShowModal;
  End;

  If GrabFormYes Then
  Begin
    GrabValueForm.Release;
    GrabValueForm:=Nil;
  End;

  If DialogRes=mrCancel Then
    Exit;

  GrabFormYes:=False;

  NewNew:=False;
  If Mode=nqmNew Then
  Begin
    NewNew:=True
  End
  Else
    NewNew:=Not Assigned(DCLGrid);

  If NewNew Then
  Begin
    FReportQuery:=TReportQuery.Create(Nil);
    FDCLLogOn.SetDBName(FReportQuery);
  End;

  If GlobalSQL.Count<>0 Then
  Begin
    tmpSQL:=GlobalSQL.Text;
    FDCLLogOn.TranslateVal(tmpSQL);
    FReportQuery.Close;
    FReportQuery.SQL.Text:=tmpSQL;

    Screen.Cursor:=crSQLWait;
    Try
      FReportQuery.Open;
      If GPT.DebugOn Then
        DebugProc('Report SQL query: '+tmpSQL);
    Except
      ShowErrorMessage(-1106, 'SQL='+tmpSQL);
    End;
    Screen.Cursor:=crDefault;
  End;
End;

destructor TDCLTextReport.Destroy;
begin
  inherited Destroy;
end;

procedure TDCLTextReport.CloseReport(FileName: String);
Var
  i: Word;
Begin
  If EndSkrypts.Count>0 Then
    For i:=0 To EndSkrypts.Count-1 Do
    Begin
      If PosEx('DisposeVariable=', EndSkrypts[i])<>0 Then
        FDCLLogOn.Variables.FreeVariable(FindParam('DisposeVariable=', EndSkrypts[i]));
    End;

  If not FSaved then
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
End;

function TDCLTextReport.SaveReport(FileName: String): String;
Var
  i: Word;
Begin
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
  If not IsFullPAth(FileName) then
    FileName:=IncludeTrailingPathDelimiter(AppConfigDir)+FileName;

  RePlaseVariables(FileName);

  i:=Length(FileName);
  While i<>0 Do
  Begin
    If (FileName[i]='"')Or(FileName[i]=CrossDelim)Or(FileName[i]='*')Or(FileName[i]='?')Or
      (FileName[i]='>')Or(FileName[i]='<') Then
      Delete(FileName, i, 1);
    Dec(i);
  End;

  case CodePage of
  rcp866:
  Report.Text:=ToDOSf(Report.Text);
  end;
  Report.SaveToFile(FileName);
  Result:=FileName;
  FSaved:=true;

  Body.Clear;
  Report.Clear;
End;

function TDCLTextReport.SetVarToControl(VarName: string): Integer;
var
  l: Word;
begin
  l:=length(VarsToControls);
  SetLength(VarsToControls, l+1);
  VarsToControls[l]:=VarName;
  Result:=l;
end;

function TDCLTextReport.TranslateRepParams(ParamName: String): String;
Var
  ParamFieldNum: Byte;
  ParamNum: Word;
  ResultString, ReturnField, tmpSQL1: String;
  ParamsQuery: TReportQuery;
Begin
  ParamNum:=0;
  While (UpperCase(RepParams[ParamNum])<>UpperCase(Trim(ParamName)))And
    (ParamNum+1<>RepParams.Count) Do
    inc(ParamNum);
  If FindParam('SQL=', RepParams[ParamNum+1])<>'' Then
  Begin
    ParamsQuery:=TReportQuery.Create(Nil);
    FDCLLogOn.SetDBName(ParamsQuery);
    tmpSQL1:=FindParam('SQL=', RepParams[ParamNum+1]);
    RePlaseVariables(tmpSQL1);
    ParamsQuery.SQL.Text:=tmpSQL1;
    Try
      ParamsQuery.Open;
      If GPT.DebugOn Then
        DebugProc('Report param SQL query: '+tmpSQL1);
    Except
      ShowErrorMessage(-1109, RepParams[ParamNum]+' / SQL='+tmpSQL1);
    End;

    ReturnField:=FindParam('ReturnField=', RepParams[ParamNum+1]);
    DeleteNonPrintSimb(ReturnField);
    ResultString:='';
    If ReturnField='' Then
    Begin
      While Not ParamsQuery.Eof Do
      Begin
        tmpSQL1:='';
        For ParamFieldNum:=0 To ParamsQuery.FieldCount-1 Do
        Begin
          tmpSQL1:=tmpSQL1+TrimRight(ParamsQuery.Fields[ParamFieldNum].AsString);
        End;

        ResultString:=ResultString+tmpSQL1+#10;
        ParamsQuery.Next;
      End;
    End
    Else
    Begin
      While Not ParamsQuery.Eof Do
      Begin
        ResultString:=ResultString+TrimRight(ParamsQuery.FieldByName(ReturnField).AsString)+#10;
        ParamsQuery.Next;
      End;
    End;

    ResultString:=Copy(ResultString, 1, Length(ResultString)-1);
    RePlaseVariables(ResultString);

    ParamsQuery.Close;
    FreeAndNil(ParamsQuery);
  End
  Else
  Begin
    ResultString:=FindParam('ReturnValue=', RepParams[ParamNum+1]);
    DeleteNonPrintSimb(ResultString);
    RePlaseVariables(ResultString);
  End;
  Result:=ResultString;
End;

procedure TDCLTextReport.ReplaseRepParams(var ReplaseText: TStringList);
Var
  ParamValue, TmpStr, BodyText: String;
  ParamFill, k, k1, k3, DopLength, StringsCounter, StringNum, StartSel: Word;
Begin
  BodyText:=ReplaseText.Text;
  StringNum:=0;
  If (RepParams.Count Div 2)>0 Then
  Begin
    For StringsCounter:=0 To (RepParams.Count Div 2)-1 Do
    Begin

      StartSel:=PosEx(RepParams[StringNum], BodyText);
      While StartSel<>0 Do
      Begin
        If StartSel<>0 Then
          ParamValue:=TranslateRepParams(RepParams[StringNum]);

        k:=StartSel+Length(RepParams[StringNum]);
        k1:=k;
        ParamFill:=0;
        DopLength:=0;
        If BodyText<>'' Then
          If BodyText[k]='(' Then
          Begin
            While BodyText[k]<>')' Do
              inc(k);
            TmpStr:=Copy(BodyText, k1+1, k-k1-1);
            ParamFill:=StrToIntEx(TmpStr);
            DopLength:=k-k1+1;
          End;
        If StartSel<>0 Then
          If ParamFill=0 Then
            ParamFill:=Length(ParamValue);

        If PosEx('i', TmpStr)<>0 Then
        Begin
          Delete(BodyText, StartSel, Length(RepParams[StringNum])+DopLength);
          Delete(BodyText, StartSel, Length(ParamValue));
        End
        Else
        Begin
          If PosEx('r', TmpStr)<>0 Then
          Begin
            If ParamFill>0 Then
              For k:=Length(ParamValue)+1 To ParamFill Do
                ParamValue:=' '+ParamValue;
          End
          Else If PosEx('m', TmpStr)<>0 Then
          Begin
            If ParamFill>0 Then
            Begin
              k3:=Length(ParamValue);
              For k:=1 To (ParamFill Div 2)-(k3 Div 2) Do
                ParamValue:=' '+ParamValue;
              For k:=(ParamFill Div 2)-(k3 Div 2)+k3+1 To ParamFill Do
                ParamValue:=ParamValue+' ';
            End;
          End
          Else
          Begin
            If ParamFill>0 Then
              For k:=Length(ParamValue)+1 To ParamFill Do
                ParamValue:=ParamValue+' ';
          End;
          Delete(BodyText, StartSel, Length(RepParams[StringNum])+DopLength);
        End;

        Insert(Copy(ParamValue, 1, ParamFill), BodyText, StartSel);
        StartSel:=PosEx(RepParams[StringNum], BodyText);
      End;

      inc(StringNum, 2);
    End;
  End;

  ReplaseText.Text:=BodyText;
End;

procedure TDCLTextReport.RePlaseVariables(var VarsSet: string);
begin
  If Assigned(FDCLGrid) then
    FDCLGrid.TranslateVal(VarsSet);
  FDCLLogOn.TranslateVal(VarsSet);
end;

procedure TDCLTextReport.PrintigReport;
Var
  TmpStr, BodyText, BodyText1: String;
  StartPos, LengthParam, DelLen: Cardinal;
  NameLength, StartSel, FFactor: Word;
  FieldsCounter: Byte;
  Alig: String;
Begin
  If DialogRes=mrCancel Then
    Exit;
  FSaved:=False;
  BodyText:=Template.Text;

  If Not FReportQuery.IsEmpty Then
  Begin
    For FieldsCounter:=0 To FReportQuery.FieldCount-1 Do
    Begin
      NameLength:=length(FReportQuery.Fields[FieldsCounter].FieldName);

      StartSel:=PosEx(ParamPrefix+FReportQuery.Fields[FieldsCounter].FieldName, BodyText);
      While StartSel<>0 Do
      Begin
        Alig:='L';
        If StartSel<>0 Then
        Begin
          If BodyText[StartSel+NameLength+1]='(' Then
          Begin
            StartPos:=StartSel+NameLength+length(ParamPrefix);
            While BodyText[StartPos]<>')' Do
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
          End
          Else
          Begin
            DelLen:=NameLength+length(ParamPrefix);
            LengthParam:=Length(TrimRight(FReportQuery.Fields[FieldsCounter].AsString));
          End;

          FillCopy(TrimRight(FReportQuery.Fields[FieldsCounter].AsString), BodyText, StartSel,
            LengthParam, DelLen, Alig);

          StartSel:=PosEx(ParamPrefix+FReportQuery.Fields[FieldsCounter].FieldName, BodyText);
        End;
      End;
    End;
    BodyText1:=Copy(BodyText, 1, Length(BodyText)-2);
  End
  Else
    BodyText1:='';

  FFactor:=0;
  TranslateProc(BodyText1, FFactor);
  Body.Append(BodyText1);
End;

procedure TDCLTextReport.OpenReport(FileName: String; ViewMode: TReportViewMode
  );
// 0-Normal 1 Record;  1-All Records;  2-Bookmarks; 3-All records (Num)
Var
  BookMarks, Nubers: Cardinal;
Begin
  If DialogRes=mrCancel Then
    Exit;
  If Not FReportQuery.IsEmpty Then
  Begin
    Case ViewMode Of
    rvmOneRecord:
    PrintigReport;
    rvmAllDS:
    Begin
      FReportQuery.First;
      While Not FReportQuery.Eof Do
      Begin
        PrintigReport;
        FReportQuery.Next;
      End;
    End;
    rvmGrid:
    Begin
      If Assigned(FDCLGrid) Then
        If FDCLGrid.DisplayMode in [dctTablePart, dctMainGrid] then
          If FDCLGrid.Grid.SelectedRows.Count>0 Then
          Begin
            For BookMarks:=0 To FDCLGrid.Grid.SelectedRows.Count-1 Do
            Begin
              FReportQuery.GoToBookmark(TBookmark(FDCLGrid.Grid.SelectedRows[BookMarks]));
              PrintigReport;
            End;
          End
          Else
            PrintigReport;
    End;
    rvmMultitRecordReport:
    Begin
      If FileName='' Then
        FileName:='Report';
      FReportQuery.First;
      Nubers:=1;
      While Not FReportQuery.Eof Do
      Begin
        PrintigReport;
        SaveReport(FileName+'-'+IntToStr(Nubers)+'.txt');
        inc(Nubers);
        FReportQuery.Next;
      End;
    End;
    rvmBookmarcks:
    Begin
      If Assigned(FDCLGrid) Then
        If FDCLGrid.DisplayMode in [dctTablePart, dctMainGrid] then
          If FDCLGrid.Grid.SelectedRows.Count>0 Then
          Begin
            Nubers:=1;
            For BookMarks:=0 To FDCLGrid.Grid.SelectedRows.Count-1 Do
            Begin
              FReportQuery.GoToBookmark(TBookmark(FDCLGrid.Grid.SelectedRows[BookMarks]));
              PrintigReport;
              SaveReport(FileName+'-'+IntToStr(Nubers)+'.txt');
              inc(Nubers);
            End;
          End;
    End;
    End;
  End
  Else
    PrintigReport;

  ReplaseRepParams(HeadLine);
  ReplaseRepParams(Futer);
End;
// =========================================Reports==============================

{ TDCLOfficeReport }

constructor TDCLOfficeReport.Create(DCLLogOn: TDCLLogOn; DCLGrid: TDCLGrid);
begin
  BinStor:=TDCLBinStore.Create(DCLLogOn);
  FDCLLogOn:=DCLLogOn;
  FDCLGrid:=DCLGrid;
  OfficeDocumentFormat:=odtMSO;
  OfficeTemplateFormat:=odtMSO;
end;

{ TDCLBinStore }

procedure TDCLBinStore.ClearData(DataName: string);
begin
  inherited ClearData(DataName);
end;

destructor TDCLBinStore.Destroy;
begin
  inherited Destroy;
end;

procedure TDCLBinStore.CompressData(DataName: string);
begin
  inherited CompressData(DataName, '');
end;

constructor TDCLBinStore.Create(DCLLogOn: TDCLLogOn);
begin
  inherited Create(DCLLogOn, ftByName, GPT.TemplatesTable, GPT.TemplatesKeyField,
    GPT.TemplatesNameField, GPT.TemplatesDataField);
end;

procedure TDCLBinStore.DeCompressData(DataName: string);
begin
  inherited DeCompressData(DataName, '');
end;

function TDCLBinStore.MD5(DataName: String):String;
begin
  Result:=inherited MD5(DataName);
end;

procedure TDCLBinStore.DeleteData(DataName: string);
begin
  inherited DeleteData(DataName);
end;

function TDCLBinStore.GetTemplateFile(Template, FileName, Ext: String): String;
Var
  TempFile: String;
Begin
  FErrorCode:=0;
  FDCLLogOn.TranslateVal(Template);

  If Template<>'' Then
  Begin
    If IsDataExist(Template) then
    Begin
      If FileName<>'' Then
      Begin
        If IsFullPAth(FileName) Then
          TempFile:=FakeFileExt(FileName, Ext)
        Else
          TempFile:=IncludeTrailingPathDelimiter(AppConfigDir)+FakeFileExt(FileName, Ext);
      End
      Else
        TempFile:=IncludeTrailingPathDelimiter(AppConfigDir)+GetTempFileName(Ext);

      GetData(Template).SaveToFile(TempFile);
    End
    Else
    Begin
      ShowErrorMessage(-5004, Template);
      FErrorCode:=4;
      TempFile:='';
    End;

  End;
  Result:=TempFile;
End;

procedure TDCLBinStore.SaveToFile(FileName, DataName: string);
begin
  inherited SaveToFile(FileName, DataName);
end;

procedure TDCLBinStore.StoreFromFile(FileName, DataName: string; Compress: Boolean);
begin
  inherited StoreFromFile(FileName, DataName, '', Compress);
end;

procedure DisconnectDB;
Begin
  If Assigned(DCLMainLogOn) Then
    If DCLMainLogOn.Connected Then
    Begin
      DCLMainLogOn.LoggingUser(False);
      DCLMainLogOn.Disconnect;
    End;
End;

Procedure EndDCL;
Begin
  If Assigned(DCLMainLogOn) Then
  Begin
    If DCLMainLogOn.NewLogOn then
    Begin
      DisconnectDB;
      FreeAndNil(DCLMainLogOn);
    End;
  End;

{$IFDEF ADO}
  CoUninitialize;
{$ENDIF}
  If GPT.DebugOn And GPT.DebugMesseges Then
    ExecApp('"'+GPT.Viewer+'" "'+IncludeTrailingPathDelimiter(AppConfigDir)+'DebugApp.txt"');
End;

procedure InitDCL(DBLogOn: TDBLogOn);
var
  TmpStr: string;
  v1: Integer;
  ShowLogOnForm: Boolean;
  ParamsQuery, RolesQuery1: TDCLDialogQuery;
{$IFDEF MSWINDOWS}
  MemHnd: HWND;
{$ENDIF}
begin
  ShowFormPanel:=true;
  InitGetAppConfigDir;
  DCLMainLogOn:=TDCLLogOn.Create(DBLogOn);
  DCLMainLogOn.RoleOK:=lsNotNeed;

  For v1:=1 To ParamCount Do
    If ParamStr(v1)='/debug' Then
      GPT.DebugOn:=true;
  DebugProc('DCL version : '+Version);
  ConnectErrorCode:=0;
  If GPT.IniFileName='' Then
    GPT.IniFileName:=Path+'DCL.ini';
  DebugProc('Find ini file: '+GPT.IniFileName);

  GPT.OldStyle:=true;
  GPT.DebugMesseges:=False;
  GPT.OneCopy:=False;
  GPT.ExitCnf:=False;
  GPT.UseMessages:=true;
  ScriptRunCreated:=False;
  GPT.DebugOn:=False;
  GPT.Port:=0;
{$IFDEF ZEOS}
  GPT.DBType:=DefaultDBType;
{$ENDIF}
  GPT.UserLogging:=False;
  GPT.UserLoggingHistory:=False;

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
  DefaultSystemEncoding:=DefaultSourceEncoding;
{$ENDIF}

  Params:=TStringList.Create;
  If ParamStr(1)<>'' Then
    If FileExists(ParamStr(1)) Then
      GPT.IniFileName:=ParamStr(1)
    Else
    Begin
      For v1:=1 To ParamCount Do
        If PosEx('-ini', ParamStr(v1))<>0 Then
          GPT.IniFileName:=ParamStr(v1+1);
    End;

  If {$IFNDEF EMBEDDED}FileExists(GPT.IniFileName){$ELSE}true{$ENDIF} Then
  Begin
{$IFNDEF EMBEDDED}
    Try
      DebugProc('Open ini file: '+GPT.IniFileName);
      Params.LoadFromFile(GPT.IniFileName);
      DebugProc('Open : OK');
    Except
      DebugProc('Open ini file : Fail');
    End;
{$ENDIF}
    GetParamsStructure;

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
    TmpStr:=Application.ExeName;
    Path:=ExtractFilePath(TmpStr);
    SetCurrentDir(Path);

    TransParams:=true;

    If DCLMainLogOn.ConnectDB=0 then
    Begin
{$IFNDEF EMBEDDED}
      GPT.NoParamsTable:=not DCLMainLogOn.TableExists(GPT.GPTTableName);
      If Not GPT.NoParamsTable Then
      Begin
        ParamsQuery:=TDCLDialogQuery.Create(Nil);
        ParamsQuery.Name:='InitDCLParams_'+IntToStr(UpTime);
        ParamsQuery.SQL.Text:='select '+GPT.GPTNameField+', '+GPT.GPTValueField+' from '+
          GPT.GPTTableName;
        DCLMainLogOn.SetDBName(ParamsQuery);
        Try
          Try
            ParamsQuery.Open;
          Except
            GPT.NoParamsTable:=False;
          End;
          ParamsQuery.First;
          While Not ParamsQuery.Eof Do
          Begin
            Params.Insert(0, ParamsQuery.FieldByName(GPT.GPTNameField).AsString+'='+
              ParamsQuery.FieldByName(GPT.GPTValueField).AsString);
            ParamsQuery.Next;
          End;
          ParamsQuery.Close;
          FreeAndNil(ParamsQuery);
          GetParamsStructure;
        Except
          GPT.NoParamsTable:=False;
        End;
      End;

      GPT.RolesMenuTable:=RolesMenuTable;
{$ENDIF}
      FreeAndNil(Params);

      GPT.TimeStampFormat:=GPT.DateFormat+' '+GPT.TimeFormat;

      If GPT.OneCopy Then
      Begin
{$IFDEF MSWINDOWS}
        MemHnd:=CreateFileMapping(HWND($FFFFFFFF), Nil, PAGE_READWRITE, 0, 127, MemFileName);
        If GetLastError=ERROR_ALREADY_EXISTS Then
        Begin
          ShowErrorMessage(1,
            SourceToInterface(GetDCLMessageString(msAppRunning)));
          Halt;
        End;
{$ENDIF}
      End;
    End;

    ShowLogOnForm:=False;
    If ShiftDown Then
    Begin
      ShowLogOnForm:=true;
      // GPT.DCLUserName:='';
      GPT.EnterPass:='';
    End;

    DCLMainLogOn.SQLMon:=TDCLSQLMon.Create(IncludeTrailingPathDelimiter(AppConfigDir)+'SQLMon.txt');

    RolesQuery1:=TDCLDialogQuery.Create(Nil);
    RolesQuery1.Name:='InitRolesQuery_'+IntToStr(UpTime);
    DCLMainLogOn.SetDBName(RolesQuery1);
{$IFNDEF EMBEDDED}
    RolesQuery1.SQL.Text:='select count(*) from '+UsersTable;

    If DCLMainLogOn.TableExists(UsersTable) then
      Try
        RolesQuery1.Open;
        GPT.DisableLogOnWithoutUser:=RolesQuery1.Fields[0].AsInteger>0;
        RolesQuery1.Close;
      Except
        GPT.DCLUserName:='';
        ShowLogOnForm:=False;
        DebugProc(GetDCLMessageString(msTable)+' '+GetDCLMessageString(msUsers)+' "'+UsersTable+'" '+
          GetDCLMessageString(msNotFoundM)+'.');
      End;
{$ELSE}
    GPT.DisableLogOnWithoutUser:=False;
{$ENDIF}
    If DCLMainLogOn.Login(GPT.DCLUserName, GPT.EnterPass, ShowLogOnForm)<>lsLogonOK then
      DCLMainLogOn.RoleOK:=lsRejected;
    If DCLMainLogOn.RoleOK=lsNotNeed then
      DCLMainLogOn.RoleOK:=lsLogonOK;
  End
  Else
  Begin
    ShowErrorMessage(1, SourceToInterface(GetDCLMessageString(msConfigurationFile)+' '+
      GetDCLMessageString(msNotFoundM)+'. 0010'));
    DebugProc('Bye, Configuration file not fund.');
    ConnectErrorCode:=100;
  End;
end;

{ TNoScrollBarDBGrid }

{$IFDEF DELPHI}
procedure TNoScrollBarDBGrid.SetScrollBars(Value: TScrollStyle);
begin
  Inherited;
end;
{$ENDIF}

{ TFieldGroup }

procedure TFieldGroup.Clear(Sender: TObject);
begin
  If ShowErrorMessage(10, SourceToInterface(GetDCLMessageString(msClearContent)+'?'))=1 Then
  Begin
    FData.Edit;
    FData.DataSet.FieldByName(FieldName).Clear;
  End;
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

  If not Field.IsFieldWidth Then
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
  Begin
    FieldCaption:=TLabel.Create(ThumbPanel);
    FieldCaption.Parent:=ThumbPanel;
    FieldCaption.Caption:=Field.Caption;
    FieldCaption.Left:=140;
    FieldCaption.Top:=10;
    FieldCaption.Width:=100;
  End;

  ButtonPanel:=TPanel.Create(ThumbPanel);
  ButtonPanel.Parent:=ThumbPanel;
  ButtonPanel.BevelInner:=bvLowered;
  ButtonPanel.Align:=alTop;
  ButtonPanel.Height:=GroupButtonPanelHeight;
  FieldName:=Field.FieldName;

  Case GroupType of
  gtGrafic:
  Begin
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
    Begin
      GraficField.Hint:=Field.Hint;
      GraficField.ShowHint:=true;
    End;
  End;
  gtRichText:
  Begin
    RichField:={$IFDEF DELPHI}TDBRichEdit{$ELSE}TDBMemo{$ENDIF}.Create(ThumbPanel);
    RichField.Parent:=ThumbPanel;
    RichField.Align:=alClient;
    RichField.ScrollBars:=ssBoth;
    RichField.DataSource:=Data;
    RichField.DataField:=Field.FieldName;
    RichField.ReadOnly:=Field.ReadOnly;
    If Field.Hint<>'' Then
    Begin
      RichField.Hint:=Field.Hint;
      RichField.ShowHint:=true;
    End;
  End;
  gtMemo:
  Begin
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
    Begin
      MemoField.Hint:=Field.Hint;
      MemoField.ShowHint:=true;
    End;
  End;
  End;

  If not Field.ReadOnly Then
  Begin
    LoadButton:=TSpeedButton.Create(ButtonPanel);
    LoadButton.Parent:=ButtonPanel;
    LoadButton.Name:='LoadButton'+IntToStr(UpTime);
    LoadButton.Tag:=0;
    LoadButton.Left:=BeginStepLeft+40;
    LoadButton.Top:=GroupToolButtonTop;
    LoadButton.Width:=25;
    LoadButton.Height:=GroupToolButtonHeight;
    LoadButton.Hint:=SourceToInterface(GetDCLMessageString(msLoad));
    LoadButton.ShowHint:=true;
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
    ClearButton.Hint:=SourceToInterface(GetDCLMessageString(msClear));
    ClearButton.ShowHint:=true;
    ClearButton.OnClick:=Clear;
    ClearButton.Glyph.Assign(DrawBMPButton('Clear'));
  End;

  SaveButton:=TSpeedButton.Create(ButtonPanel);
  SaveButton.Parent:=ButtonPanel;
  SaveButton.Name:='SaveButton'+IntToStr(UpTime);
  SaveButton.Tag:=2;
  SaveButton.Left:=BeginStepLeft;
  SaveButton.Top:=GroupToolButtonTop;
  SaveButton.Width:=25;
  SaveButton.Height:=GroupToolButtonHeight;
  SaveButton.Hint:=SourceToInterface(GetDCLMessageString(msSave));
  SaveButton.ShowHint:=true;
  SaveButton.OnClick:=Save;
  SaveButton.Glyph.Assign(DrawBMPButton('Save'));
end;

procedure TFieldGroup.Load(Sender: TObject);
Begin
  Case FGroupType of
  gtGrafic:
  Begin
    OpenPictureDialog:=TOpenPictureDialog.Create(Nil);
    OpenPictureDialog.DefaultExt:='jpg';
    OpenPictureDialog.Filter:=GraphicFilter(TGraphic);
    If OpenPictureDialog.Execute Then
      LoadData(OpenPictureDialog.FileName);

    FreeAndNil(OpenPictureDialog);
  End;
  gtMemo, gtRichText:
  Begin
    OpenDialog:=TOpenDialog.Create(Nil);
    Case FGroupType of
    gtMemo:
    Begin
      OpenDialog.DefaultExt:='txt';
      OpenDialog.Filter:=SourceToInterface(GetDCLMessageString(msText)+' (*.txt)|*.txt|'+GetDCLMessageString(msAll)+' (*.*)|*.*');
    End;
    gtRichText:
    Begin
      OpenDialog.DefaultExt:='rtf';
      OpenDialog.Filter:=SourceToInterface(GetDCLMessageString(msFormated)+
        GetDCLMessageString(msText)+' (*.rtf)|*.rtf|'+GetDCLMessageString(msAll)+' (*.*)|*.*');
    End;
    End;
    If OpenDialog.Execute Then
      LoadData(OpenDialog.FileName);

    FreeAndNil(OpenDialog);
  End;
  End;
End;

procedure TFieldGroup.LoadData(FileName: string);
Var
  bmp: TBitmap;
  jpg: TJpegImage;
  MS: TMemoryStream;
  TS: TStringList;
begin
  FData.Edit;
  Case GetGraficFileType(FileName) Of
  gftJPEG:
  Begin
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
  End;
  gftBMP, gftNone:
  Begin
    If FData.DataSet.FieldByName(FieldName).DataType in TBlobFields then
      TBlobField(FData.DataSet.FieldByName(FieldName)).LoadFromFile(FileName)
    Else
    Begin
      TS:=TStringList.Create;
      TS.LoadFromFile(FileName);
      FData.DataSet.FieldByName(FieldName).AsString:=TS.Text;
      FreeAndNil(TS);
    End;
  End;
  End;
end;

procedure TFieldGroup.OnDBImageRead(Sender: TObject; S: TStream;
  var GraphExt: string);
Var
  Signature:Array of Byte;
begin
  SetLength(Signature, 10);
  S.Read(Signature[0], 10);
  S.Position:=0;

  If (Signature[0]=66) and (Signature[1]=77) then
  Begin
    GraphExt:='bmp';
    FGraphicFileType:=gftBMP;
  End
  Else
  If (Signature[0]=$FF) and (Signature[1]=$D8) then
  Begin
    GraphExt:='jpg';
    FGraphicFileType:=gftJPEG;
  End
  Else
  If (Signature[0]=$89) and (Signature[1]=$50) and (Signature[2]=$4E) and (Signature[3]=$47) and (Signature[4]=$0D) and
   (Signature[5]=$0A) and (Signature[6]=$1A) and (Signature[7]=$0A) then
  Begin
    GraphExt:='png';
    FGraphicFileType:=gftPNG;
  End
  Else
  If (Signature[0]=$47) and (Signature[1]=$49) and (Signature[2]=$46) and (Signature[3]=$38) then
  Begin
    GraphExt:='gif';
    FGraphicFileType:=gftGIF;
  End
  Else
  If ((Signature[0]=$49) and (Signature[1]=$49) and (Signature[2]=$2A) and (Signature[3]=$00)) or
    ((Signature[4]=$4D) and (Signature[5]=$4D) and (Signature[6]=$00) and (Signature[7]=$2A)) then
  Begin
    GraphExt:='tiff';
    FGraphicFileType:=gftTIFF;
  End
  Else
  If (Signature[0]=$00) and (Signature[1]=$00) and ((Signature[2]=$01) or (Signature[2]=$02)) and
    (Signature[3]=$00) and (Signature[4]>=1) then
  Begin
    GraphExt:='ico';
    FGraphicFileType:=gftIcon;
  End
  Else
  Begin
    GraphExt:='Unk';
    FGraphicFileType:=gftOther;
  End;
end;

procedure TFieldGroup.Save(Sender: TObject);
Begin
  Case FGroupType of
  gtGrafic:
  Begin
    SavePictureDialog:=TSavePictureDialog.Create(Nil);
    SavePictureDialog.Name:='SavePictureDialog1';
    SavePictureDialog.DefaultExt:=GetExtByType(FGraphicFileType);
    SavePictureDialog.Filter:=GraphicFilter(TGraphic);
    //SavePictureDialog.Filter:='JPEG Image File (*.jpeg)|*.jpeg;*.jpg|Bitmaps (*.bmp)|*.bmp';

    If SavePictureDialog.Execute then
      SaveData(SavePictureDialog.FileName);

    FreeAndNil(SavePictureDialog);
  End;
  gtMemo, gtRichText:
  Begin
    SaveDialog:=TSaveDialog.Create(Nil);
    Case FGroupType of
    gtMemo:
    Begin
      SaveDialog.DefaultExt:='txt';
      SaveDialog.Filter:=SourceToInterface(GetDCLMessageString(msText)+' (*.txt)|*.txt|'+GetDCLMessageString(msAll)+' (*.*)|*.*');
    End;
    gtRichText:
    Begin
      SaveDialog.DefaultExt:='rtf';
      SaveDialog.Filter:=SourceToInterface(GetDCLMessageString(msFormated)+
        GetDCLMessageString(msText)+' (*.rtf)|*.rtf|'+GetDCLMessageString(msAll)+' (*.*)|*.*');
    End;
    End;
    If SaveDialog.Execute Then
      SaveData(SaveDialog.FileName);
    FreeAndNil(SaveDialog);
  End;
  End;
End;

procedure TFieldGroup.SaveData(FileName: string);
Var
  bmp: TBitmap;
  jpg: TJpegImage;
  MS: TMemoryStream;
  TS: TStringList;
begin
  Case GetGraficFileType(FileName) of
  gftJPEG:
  Begin
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
  End;
  gftBMP, gftNone:
  If FData.DataSet.FieldByName(FieldName).DataType in TBlobFields then
    TBlobField(FData.DataSet.FieldByName(FieldName)).SaveToFile(FileName)
  Else
  Begin
    TS:=TStringList.Create;
    TS.Text:=FData.DataSet.FieldByName(FieldName).AsString;
    TS.SaveToFile(FileName);
    FreeAndNil(TS);
  End;

  End;
end;

{ TBaseBinStore }

procedure TBaseBinStore.ClearData(DataName: string; FindType: TFindType);
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
  End;
  Try
    If IsReturningQuery(DCLQuery.SQL.Text) then
    Begin
      DCLQuery.Open;
      DCLQuery.Edit;
      DCLQuery.FieldByName(FDataField).Clear;
      DCLQuery.Post;
      DCLQuery.Close;
    End
    Else
      DCLQuery.ExecSQL;
  Except
    ShowErrorMessage(-5003, FTableName);
    Exit;
  End;
end;

destructor TBaseBinStore.Destroy;
begin
  If Assigned(DCLQuery) then
  Begin
    If DCLQuery.Active then
      DCLQuery.Close;
    //FreeAndNil(DCLQuery);
  End;
end;

procedure TBaseBinStore.CompressData(DataName, Data: string; FindType: TFindType);
Var
  MS: TMemoryStream;
begin
  MS:=GetData(DataName, FindType);
  MS.Position:=0;
  SetData(DataName, Data, FindType, MS, true);
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
  DCLQuery.Name:='BaseBinStore'+IntToStr(UpTime);
  DCLQuery.NoRefreshSQL:=True;
end;

procedure TBaseBinStore.DeCompressData(DataName, Data: string; FindType: TFindType);
var
  MS: TMemoryStream;
begin
  MS:=GetData(DataName, FindType);
  SetData(DataName, Data, FindType, MS, False);
end;

function TBaseBinStore.MD5(DataName: string; FindType: TFindType): String;
var
  MS:TMemoryStream;
begin
  MS:=GetData(DataName, FindType);
  Result:=MD5DigestToStr(MD5Stream(MS));
end;

procedure TBaseBinStore.DeleteData(DataName: string; FindType: TFindType);
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
  End;
  Try
    If IsReturningQuery(DCLQuery.SQL.Text) then
    Begin
      DCLQuery.Open;
      DCLQuery.Delete;
      DCLQuery.Close;
    End
    Else
      DCLQuery.ExecSQL;
  Except
    ShowErrorMessage(-5003, FTableName);
    Exit;
  End;
end;

function TBaseBinStore.GetData(DataName: string; FindType: TFindType): TMemoryStream;
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
  End;
  Try
    DCLQuery.Open;
    DCLQuery.Last;
    DCLQuery.First;
  Except
    FErrorCode:=3;
    ShowErrorMessage(-5003, FTableName);
    Exit;
  End;
  If not DCLQuery.IsEmpty then
  Begin
    Try
      MS:=TMemoryStream.Create;
      Result:=TMemoryStream.Create;
      TBlobField(DCLQuery.FieldByName(FDataField)).SaveToStream(MS);
      If MS.Size>0 Then
      Begin
        Marker:=0;
        MS.Position:=0;
        MS.Read(Marker, 3);

        If Marker=PAGSignature Then // "PAG" Signature
        Begin
          // Compressed/
          BS:=TMemoryStream.Create;
          BS.Position:=0;
          DecompressProc(MS, BS);
          BS.Position:=0;
          MS.Position:=0;
          MS.CopyFrom(BS, BS.Size);
          FreeAndNil(BS);
        End;

        MS.Position:=0;
        Result.CopyFrom(MS, MS.Size);
      End;
    Except
      //
    End;
  End;
  DCLQuery.Close;
end;

function TBaseBinStore.IsDataExist(DataName: string; FindType: TFindType): Boolean;
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
  End;
  Try
    DCLQuery.Open;
  Except
    ShowErrorMessage(-5003, FTableName);
    FErrorCode:=3;
    Exit;
  End;
  Result:=not DCLQuery.IsEmpty;
  DCLQuery.Close;
end;

procedure TBaseBinStore.SaveToFile(FileName, DataName: string; FindType: TFindType);
begin
  GetData(DataName, FindType).SaveToFile(FileName);
end;

procedure TBaseBinStore.SetData(DataName, Data: string; FindType: TFindType; Stream: TMemoryStream;
  Compress: Boolean);
var
  BS: TMemoryStream;
  tmpSQL, insSQL, valuesSQL, S, Value: String;
  i:Integer;
  Signature: Cardinal;
begin
  If Stream.Size>0 then
  Begin
    If Compress then
    Begin
      BS:=TMemoryStream.Create;
      Signature:=PAGSignature;
      BS.Write(Signature, 3);
      Stream.Position:=0;
      CompressProc(Stream, BS);
      BS.Position:=0;
      Stream.Position:=0;
      Stream.CopyFrom(BS, BS.Size);
      FreeAndNil(BS);
    End;

    Case FindType of
    ftByName:
    tmpSQL:='select * from '+FTableName+' where '+GPT.UpperString+FNameField+
      GPT.UpperStringEnd+'='+GPT.UpperString+GPT.StringTypeChar+DataName+GPT.StringTypeChar+
      GPT.UpperStringEnd;
    ftByIndex:
    tmpSQL:='select * from '+FTableName+' where '+FKeyField+'='+DataName;
    ftSQL:
    tmpSQL:=DataName;
    End;
    DCLQuery.Close;
    DCLQuery.SQL.Text:=tmpSQL;
    Try
      DCLQuery.Open;
    Except
      FErrorCode:=3;
      ShowErrorMessage(-5003, FTableName);
      Exit;
    End;
    If DCLQuery.IsEmpty then
    Begin
      If FindType<>ftSQL then
        DCLQuery.Close;
      Case FindType of
      ftByName:
      DCLQuery.SQL.Text:='insert into '+FTableName+'('+FNameField+') values('+GPT.StringTypeChar+
        DataName+GPT.StringTypeChar+')';
      ftByIndex:
      DCLQuery.SQL.Text:='insert into '+FTableName+'('+FKeyField+') values('+DataName+')';
      ftSQL:
      Begin
        insSQL:='';
        valuesSQL:='';
        For i:=1 to ParamsCount(Data) do
        Begin
          S:=SortParams(Data, i);
          Value:=CopyCut(S, Pos('=', S), Length(S));
          Delete(Value, 1, 1);
          insSQL:=insSQL+','+S;
          valuesSQL:=valuesSQL+','+GPT.StringTypeChar+Value+GPT.StringTypeChar;
          //DCLQuery.FieldByName(S).AsString:=Value;
        End;
        If insSQL<>'' then
          Delete(insSQL, 1, 1);
        If valuesSQL<>'' then
          Delete(valuesSQL, 1, 1);

        tmpSQL:='insert into '+FTableName+'('+insSQL+') values('+valuesSQL+')';
      End;
      End;
      DCLQuery.ExecSQL;
      DCLQuery.SQL.Text:=tmpSQL;
      DCLQuery.Open;
    End;
    If not (DCLQuery.State in [dsInsert, dsEdit]) then
      DCLQuery.Edit;
    Stream.Position:=0;
    TBlobField(DCLQuery.FieldByName(FDataField)).LoadFromStream(Stream);
    Try
      DCLQuery.Post;
    Finally
      DCLQuery.Close;
    End;
  End;
end;

procedure TBaseBinStore.StoreFromFile(FileName, DataName, Data: string; FindType: TFindType;
  Compress: Boolean);
var
  MS: TMemoryStream;
begin
  If FileExists(FileName) then
  Begin
    MS:=TMemoryStream.Create;
    MS.LoadFromFile(FileName);
    SetData(DataName, Data, FindType, MS, Compress);
  End;
end;

{ TBinStore }

procedure TBinStore.ClearData(DataName: string);
begin
  inherited ClearData(DataName, FFindType);
end;

destructor TBinStore.Destroy;
begin
  inherited Destroy;
end;

procedure TBinStore.CompressData(DataName, Data: string);
begin
  inherited CompressData(DataName, Data, FFindType);
end;

constructor TBinStore.Create(DCLLogOn: TDCLLogOn; FindType: TFindType;
  TableName, KeyField, NameField, DataField: String);
begin
  FFindType:=FindType;
  inherited Create(DCLLogOn, TableName, KeyField, NameField, DataField);
end;

procedure TBinStore.DeCompressData(DataName, Data: string);
begin
  inherited DeCompressData(DataName, Data, FFindType);
end;

function TBinStore.MD5(DataName: string): String;
begin
  Result:=inherited MD5(DataName, FFindType);
end;

procedure TBinStore.DeleteData(DataName: string);
begin
  inherited DeleteData(DataName, FFindType);
end;

function TBinStore.GetData(DataName: string): TMemoryStream;
begin
  Result:=inherited GetData(DataName, FFindType);
end;

function TBinStore.IsDataExist(DataName: string): Boolean;
begin
  Result:=inherited IsDataExist(DataName, FFindType);
end;

procedure TBinStore.SaveToFile(FileName, DataName: string);
begin
  inherited SaveToFile(FileName, DataName, FFindType);
end;

procedure TBinStore.SetData(DataName, Data: string; Stream: TMemoryStream; Compress: Boolean);
begin
  inherited SetData(DataName, Data, FFindType, Stream, Compress);
end;

procedure TBinStore.StoreFromFile(FileName, DataName, Data: string; Compress: Boolean);
begin
  inherited StoreFromFile(FileName, DataName, Data, FFindType, Compress);
end;

{$IFNDEF EMBEDDED}
Initialization

  InitDCL(nil);

//Finalization

//  EndDCL;
{$ENDIF}

end.
