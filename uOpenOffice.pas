// ******************************************************************************
// *                    Written by Yuri (aka Yuric74)                           *
// *           http://www.sql.ru/forum/actualthread.aspx?tid=405083             *
// *                 all version at http://yuri.elmeh.ru                        *
// ******************************************************************************
unit uOpenOffice;
{$I DefineType.pas}

interface

// {$DEFINE WITH_EVENTS}

uses
  Graphics, Windows, Variants, Classes, ComObj
{$IFDEF WITH_EVENTS}
    , ActiveX, uOpenOffice_TLB
{$ENDIF}
    ;

// All sizes (Width,Height,...) in 1/100 millimeters

const
  // Font weight constants
  ofwDontKnow: integer=0;
  ofwThin: integer=50;
  ofwUltraLight: integer=60;
  ofwLight: integer=75;
  ofwSemiLight: integer=90;
  ofwNormal: integer=100;
  ofwSemiBold: integer=110;
  ofwBold: integer=150;
  ofwUltraBold: integer=175;
  ofwBlack: integer=200;

  // Shape type constants
  ostNone='None';
  ostText='com.sun.star.drawing.TextShape';
  ostGraphic='com.sun.star.drawing.GraphicObjectShape';
  ostLine='com.sun.star.drawing.LineShape';
  ostRectangle='com.sun.star.drawing.RectangleShape';
  ostEllipse='com.sun.star.drawing.EllipseShape';
  ostMeasure='com.sun.star.drawing.MeasureShape';
  ostConnector='com.sun.star.drawing.ConnectorShape';

  // Diagram type constants
  odgBar='com.sun.star.chart.BarDiagram';
  odgArea='com.sun.star.chart.AreaDiagram';
  odgLine='com.sun.star.chart.LineDiagram';
  odgPie='com.sun.star.chart.PieDiagram';
  odgDonut='com.sun.star.chart.DonutDiagram';
  odgNet='com.sun.star.chart.NetDiagram';
  odgXY='com.sun.star.chart.XYDiagram';
  odgStock='com.sun.star.chart.StockDiagram';

  // ChartSymbolType constants
  ocstNone: integer=-3;
  ocstAuto: integer=-2;
  ocstBitmapURL: integer=-1;
  ocstSymbol0: integer=0;
  ocstSymbol1: integer=1;
  ocstSymbol2: integer=2;
  ocstSymbol3: integer=3;
  ocstSymbol4: integer=4;
  ocstSymbol5: integer=5;
  ocstSymbol6: integer=6;
  ocstSymbol7: integer=7;

  // ChartDataCaption constants
  ocdcNone: integer=0;
  ocdcValue: integer=1;
  ocdcPercent: integer=2;
  ocdcText: integer=4;
  ocdcSymbol: integer=16;

type
  TOpenHA=(ohaDefault, ohaLeft, ohaCenter, ohaRight); // Cell horizontal Alignment
  TOpenVA=(ovaDefault, ovaTop, ovaCenter, ovaBottom); // Cell vertical Alignment
  TOpenPF=(opfA3, opfA4, opfA5, opfB4, opfB5, opfLetter, opfLegal, opfTabloid, opfUser);
  // Paper format
  TOpenPO=(opoPortrait, opoLandscape); // Paper orientation
  TOpenPHA=(ophLeft, ophRight, ophBlock, ophCenter, ophStretch); // Paragraph horizontal adjustment
  TOpenPVA=(opvAutomatic, opvBaseLine, opvTop, opvCenter, opvBottom);
  // Paragraph vertical adjustment
  TOpenSP=set of (ospWholeWords, ospCaseSensitive, ospBackwards, ospRegExp); // Search parameters
  TOpenRP=set of (orpWholeWords, orpCaseSensitive); // Replace parameters
  TOpenDT=(odtEmpty, odtNumber, odtText, odtFormula); // Data type of cell
  TOpenMM=(ommNever, ommList, ommAlways, ommConfig, ommAlwaysNoWarn, ommConfigReject,
    ommConfigApprove, ommListNoWarn, ommListSignedWarn, ommListSignedNoWarn);
  // Macro execution mode
  TOpenOM=set of (oomHidden, oomAsTemplate, oomReadOnly); // Document open mode
  TOpenIM=(oimNone, oimDown, oimRight, oimRows, oimColumns); // Cell insert mode
  TOpenDM=(odmNone, odmUp, odmLeft, odmRows, odmColumns); // Cell delete mode
  TOpenLS=(olsProp, olsMinimum, olsLeading, olsFix); // Line spacing mode
  TOpenCM=(ocmNone, ocmUpper, ocmLower, ocmTitle, ocmSmallcaps); // Case map mode
  TOpenIP=(oipCurrent, oipEnd, oipEndNewPage); // Insert document mode
  TOpenPT=set of (optCopyCount, optFileName, optCollate, optPages); // Print options
  TOpenPL=(oplAll, oplLeft, oplRight, oplMirrored); // Page style layout
  TOpenCT=(octOther, octWriter); // Cursor type for check if cursor in TOOWriter class
  TOpenSF=(osfNone, osfTopLeft, osfTopRight, osfBottomLeft, osfBottomRight); // Shadow format
  TOpenFSR=(owmNone, owmThrought, owmParallel, owmDynamic, owmLeft, owmRight); // Frame surround
  TOpenFHO=(ofhoNone, ofhoRight, ofhoCenter, ofhoLeft, ofhoInside, ofhoOutside, ofhoFull,
    ofhoLeftWidth); // Text frame hori orientation
  TOpenFVO=(ofvoNone, ofvoTop, ofvoCenter, ofvoBottom, ofvoCharTop, ofvoCharCenter, ofvoCharBottom,
    ofvoLineTop, ofvoLineCenter, ofvoLineBottom); // Text frame vert orientation
  TOpenRO=(oroFrame, oroPrintArea, oroChar, oroPageLeft, oroPageRight, oroFrameLeft, oroFrameRight,
    oroPageFrame, oroPagePrintArea); // Rel orientation
  TOpenCH=(ochNone, ochLeftPageHeaderLeft, ochLeftPageHeaderCenter, ochLeftPageHeaderRight,
    ochRightPageHeaderLeft, ochRightPageHeaderCenter, ochRightPageHeaderRight,
    ochLeftPageFooterLeft, ochLeftPageFooterCenter, ochLeftPageFooterRight, ochRightPageFooterLeft,
    ochRightPageFooterCenter, ochRightPageFooterRight);
  // Type of header or footer in Calc page style
  TOpenWH=(owhNone, owhHeader, owhLeftPageHeader, owhRightPageHeader, owhFooter, owhLeftPageFooter,
    owhRightPageFooter); // Type of header or footer in Writer page style
  TOpenFU=(ofuNone, ofuSingle, ofuDouble, ofuDotted, ofuDontKnow, ofuDash, ofuLongDash, ofuDashDot,
    ofuDashDotDot, ofuSmallWave, ofuWave, ofuDoubleWave, ofuBold, ofuBoldDotted, ofuBoldDash,
    ofuBoldLongDash, ofuBoldDashDot, ofuBoldDashDotDot, ofuBoldWave); // Font underlined style
  TOpenFP=(ofpNone, ofpOblique, ofpItalic, ofpDontKnow, ofpReverseOblique, ofpReverseItalic);
  // Font posture style
  TOpenFS=(ofsNone, ofsSingle, ofsDouble, ofsDontKnow, ofsBold, ofsSlash, ofsX);
  // Font strikeout style
  TOpenFE=(ofeNone, ofeDotAbove, ofeCircleAbove, ofeDiskAbove, ofeAccentAbove, ofeDotBelow,
    ofeCircleBelow, ofeDiskBelow, ofeAccentBelow); // Font Emphasis style
  TOpenBT=(obtNone, obtColumnBefore, obtColumnAfter, obtColumnBoth, obtPageBefore, obtPageAfter,
    obtPageBoth); // Break type
  TOpenCR=(ocrStandard, ocrGreys, ocrMono, ocrWatermark); // Color mode
  TOpenGT=(ogtEmpty, ogtPixel, ogtVector); // Graphic type
  TOpenFD=(ofdToBottom, ofdToRight, ofdToTop, ofdToLeft); // Fill series direction
  TOpenFM=(ofmSimple, ofmLinear, ofmGrowth, ofmDate, ofmAuto); // Fill series mode
  TOpenFDM=(ofdmDay, ofdmWeekday, ofdmMonth, ofdmYear); // Fill series date mode
  TOpenFR=(ofrNone, ofrEmbossed, ofrEngraved); // Font relief
  TOpenTB=(otbNone, otbOuter, otbOuterHori, otbOuterVert, otbOuterHoriVert); // Table border lines

  TOpenSLS=(oslsNone, oslsSolid, oslsDash); // Shape line style
  TOpenSDS=(osdsRect, osdsRound, osdsRectRelative, osdsRoundRelative); // Shape dash style
  TOpenSTF=(ostfNone, ostfProportional, ostfAllLines, ostfResizeAttr); // Text fit to size mode
  TOpenSHA=(oshaLeft, oshaCenter, oshaRight, oshaBlock); // Text horizontal alignment
  TOpenSVA=(osvaTop, osvaCenter, osvaBottom, osvaBlock); // Text vertical alignment
  TOpenSAD=(osadLeft, osadRight, osadUp, osadDown); // Animation direction
  TOpenSAK=(osakNone, osakBlink, osakScroll, osakAlternate, osakSlide); // Animation kind
  TOpenSLJ=(osljNone, osljMiddle, osljBevel, osljMiter, osljRound); // Line joint
  TOpenSFS=(osfsNone, osfsSolid, osfsGradient, osfsHatch, osfsBitmap); // Fill style
  TOpenSGS=(osgsLinear, osgsAxial, osgsRadial, osgsElliptical, osgsSquare, osgsRect);
  // Gradient style
  TOpenSHS=(oshsSingle, oshsDouble, oshsTriple); // Hatch style
  TOpenSCK=(osckFull, osckSection, osckCut, osckArc); // Circle kind
  TOpenSMK=(osmkStandard, osmkRadius); // Measure kind
  TOpenSMH=(osmhAuto, osmhLeftOutside, osmhInside, osmhRightOutside);
  // Measure text horizontal position
  TOpenSMV=(osmvAuto, osmvEast, osmvBreakedLine, osmvWest, osmvCentered);
  // Measure text vertical position
  TOpenCLP=(olpNone, olpLeft, olpTop, olpRight, olpBottom); // Chart legend position
  TOpenSPT=(osptNone, osptCubic, osptBSpline); // Spline type
  TOpenCDS=(ocdsRows, ocdsColumns); // Chart data source
  TOpenDLP=(odlpAvoidOverlap, odlpCenter, odlpTop, odlpTopLeft, odlpLeft, odlpBottomLeft,
    odlpBottom, odlpBottomRight, odlpRight, odlpTopRight, odlpInside, odlpOutside, odlpNearOrigin);
  // Chart data label placement
  TOpenCST=(ocstRectangularSolid, ocstCylinder, ocstCone, ocstPyramid);
  // Chart solid type, only for Bar3D

  TOpenSR=(osrAuto, osrNumeric, osrAlphaNumeric); // Sort field type
  TOpenTO=(otoColumns, otoRows); // Table orientation

  TOpenPoint=record
    X, Y: integer;
  end;

  TOpenSize=record
    Width, Height: integer;
  end;

  TOpenRect=record
    X, Y, Width, Height: integer;
  end;

  TOpenBorderLine=record
    Color: TColor;
    InnerLineWidth: integer;
    OuterLineWidth: integer;
    LineDistance: integer;
  end;

  TOpenLineSpacing=record
    Mode: TOpenLS;
    Height: integer;
  end;

  TOpenShadowFormat=record
    Location: TOpenSF;
    ShadowWidth: integer;
    IsTransparent: boolean;
    Color: TColor;
  end;

  TOpenDropCapFormat=record
    Lines: integer;
    Count: integer;
    Distance: integer;
  end;

  TOpenRangeAddress=record
    Sheet, StartColumn, StartRow, EndColumn, EndRow: integer;
  end;

  TOpenRangeAddresses=array of TOpenRangeAddress;

  TOpenGraphicCrop=record
    Top, Bottom, Left, Right: integer;
  end;

  TOpenLineDash=record
    Style: TOpenSDS;
    Dots, DotLen, Dashes, DashLen, Distance: integer;
  end;

  TOpenGradient=record
    Style: TOpenSGS;
    StartColor, EndColor: TColor;
    Angle, Border, XOffset, YOffset, StartIntensity, EndIntensity, StepCount: integer;
  end;

  TOpenHatch=record
    Style: TOpenSHS;
    Color: TColor;
    Distance, Angle: integer;
  end;

  TOpenLine=record
    C1, C2, C3: double;
  end;

  TOpenMatrix=record
    L1, L2, L3: TOpenLine;
  end;

  TOpenSortField=record
    FieldNum: integer;
    IsAscending, IsCaseSensitive: boolean;
    FieldType: TOpenSR;
  end;

  TOpenLocale=record
    Language, Country, Variant: string;
  end;

  TOpenSortFields=array of TOpenSortField;

  // Forward declaration
  TOOBaseCursor=class;
  TOOCalcColumns=class;
  TOOCalcRows=class;
  TOOParaMargin=class;
  TOOBorderDistance=class;
  TOOCalcSheets=class;
  TOOWriterTableRows=class;
  TOOTable=class;
  TOOTables=class;
  TOOCalcPageStyle=class;
  TOOWriterPageStyle=class;
  TOOPageStyles=class;
  TOOCalcPageStyles=class;
  TOOWriterPageStyles=class;
  TOOTextCursor=class;
  TOOTextTableCursor=class;
  TOOModelCursor=class;
  TOOViewCursor=class;
  TOOBookmark=class;
  TOOBookmarks=class;
  TOOBaseFrame=class;
  TOOTextFrames=class;
  TOOGraphicFrames=class;
  TOOCalc=class;
  TOOWriter=class;
  TOpenOffice=class;
  TOOBaseShLine=class;
  TOOBaseTextCursor=class;
  TOOBaseShape=class;
  TOOCharProperties=class;
  TOOShFill=class;

  // Classes declaration

{$IFDEF WITH_EVENTS}

  TListener=class(TAutoObject, IListener)
  private
    FParent: TOpenOffice;
  protected
    procedure Disposing(const Source: IDispatch); safecall;
    procedure NotifyEvent(const Event: IDispatch); safecall;
  end;
{$ENDIF}

  TOOGlobalLocale=class
  private
    FDocument: Variant;
    procedure FreeVariants; virtual;
  protected
    property Document: Variant read FDocument write FDocument;
  public
    function DateSeparator: string; overload;
    function DateSeparator(Language, Country, VarLocale: string): string; overload;
    function TimeSeparator: string; overload;
    function TimeSeparator(Language, Country, VarLocale: string): string; overload;
    function Time100SecSeparator: string; overload;
    function Time100SecSeparator(Language, Country, VarLocale: string): string; overload;
    function ThousandSeparator: string; overload;
    function ThousandSeparator(Language, Country, VarLocale: string): string; overload;
    function DecimalSeparator: string; overload;
    function DecimalSeparator(Language, Country, VarLocale: string): string; overload;
    function MeasurementSystem: string; overload;
    function MeasurementSystem(Language, Country, VarLocale: string): string; overload;
  end;

  TOONumberFormats=class
  private
    FDocument: Variant;
    procedure FreeVariants; virtual;
  protected
    property Document: Variant read FDocument write FDocument;
  public
    function Add(Format: string): integer;
    function Find(Format: string): integer;
  end;

  TOOBaseChartObj=class
  private
    FObj: Variant;
    FFont: TOOCharProperties;
    FLine: TOOBaseShLine;
    procedure FreeVariants; virtual;
    function GetPosition: TOpenPoint;
    procedure SetPosition(const Value: TOpenPoint);
    function GetFont: TOOCharProperties;
    function GetLine: TOOBaseShLine;
  protected
    property Obj: Variant read FObj write FObj;
  public
    constructor Create;
    destructor Destroy; override;
    property Position: TOpenPoint read GetPosition write SetPosition;
    property Font: TOOCharProperties read GetFont;
    property Line: TOOBaseShLine read GetLine;
  end;

  TOOChartLegend=class(TOOBaseChartObj)
  private
    function GetAlignment: TOpenCLP;
    procedure SetAlignment(const Value: TOpenCLP);
  public
    property Alignment: TOpenCLP read GetAlignment write SetAlignment;
  end;

  TOOChartTitle=class(TOOBaseChartObj)
  private
    function GetText: string;
    procedure SetText(const Value: string);
    function GetRotation: integer;
    procedure SetRotation(const Value: integer);
  public
    property Text: string read GetText write SetText;
    property Rotation: integer read GetRotation write SetRotation;
  end;

  TOOChartDataPoint=class
  private
    FObj: Variant;
    FFont: TOOCharProperties;
    FLine: TOOBaseShLine;
    FFill: TOOShFill;
    procedure FreeVariants;
    function GetDataCaption: integer;
    procedure SetDataCaption(const Value: integer);
    function GetLabelSeparator: string;
    procedure SetLabelSeparator(const Value: string);
    function GetNumberFormat: integer;
    procedure SetNumberFormat(const Value: integer);
    function GetPercentNumberFormat: integer;
    procedure SetPercentNumberFormat(const Value: integer);
    function GetLabelPlacement: TOpenDLP;
    procedure SetLabelPlacement(const Value: TOpenDLP);
    function GetSymbolType: integer;
    procedure SetSymbolType(const Value: integer);
    function GetSegmentOffset: integer;
    procedure SetSegmentOffset(const Value: integer);
    function GetBar3DType: TOpenCST;
    procedure SetBar3DType(const Value: TOpenCST);
    function GetFont: TOOCharProperties;
    function GetLine: TOOBaseShLine;
    function GetFill: TOOShFill;
    function GetLabelRotation: integer;
    procedure SetLabelRotation(const Value: integer);
  protected
    property Obj: Variant read FObj write FObj;
  public
    constructor Create;
    destructor Destroy; override;
    property Font: TOOCharProperties read GetFont;
    property Line: TOOBaseShLine read GetLine;
    property Fill: TOOShFill read GetFill;
    property DataCaption: integer read GetDataCaption write SetDataCaption;
    property LabelSeparator: string read GetLabelSeparator write SetLabelSeparator;
    property NumberFormat: integer read GetNumberFormat write SetNumberFormat;
    property PercentNumberFormat: integer read GetPercentNumberFormat write SetPercentNumberFormat;
    property LabelPlacement: TOpenDLP read GetLabelPlacement write SetLabelPlacement;
    property LabelRotation: integer read GetLabelRotation write SetLabelRotation;
    property SymbolType: integer read GetSymbolType write SetSymbolType;
    property SegmentOffset: integer read GetSegmentOffset write SetSegmentOffset;
    property Bar3DType: TOpenCST read GetBar3DType write SetBar3DType;
  end;

  TOOChartDataRow=class
  private
    FObj: Variant;
    FDataPoint: TOOChartDataPoint;
    procedure FreeVariants;
    function GetDataPoint: TOOChartDataPoint;
  protected
    property Obj: Variant read FObj write FObj;
  public
    constructor Create;
    destructor Destroy; override;
    property DataPoints: TOOChartDataPoint read GetDataPoint;
  end;

  TOOBaseChart=class
  private
    FDType: string;
    FDocument: Variant;
    FObj: Variant;
    FMainTitle: TOOChartTitle;
    FSubTitle: TOOChartTitle;
    FLegend: TOOChartLegend;
    FDataRow: TOOChartDataRow;
    FDataPoint: TOOChartDataPoint;
    procedure FreeVariants; virtual;
    function GetHasMainTitle: boolean;
    procedure SetHasMainTitle(const Value: boolean);
    function GetDiagramType: string;
    function GetMainTitle: TOOChartTitle;
    function GetHasSubTitle: boolean;
    procedure SetHasSubTitle(const Value: boolean);
    function GetSubTitle: TOOChartTitle;
    function GetHasLegend: boolean;
    procedure SetHasLegend(const Value: boolean);
    function GetLegend: TOOChartLegend;
    function GetDim3D: boolean;
    procedure SetDim3D(const Value: boolean);
    function GetPerspective: integer;
    procedure SetPerspective(const Value: integer);
    function GetRotationHorizontal: integer;
    procedure SetRotationHorizontal(const Value: integer);
    function GetRotationVertical: integer;
    procedure SetRotationVertical(const Value: integer);
    function GetPercent: boolean;
    procedure SetPercent(const Value: boolean);
    function GetStacked: boolean;
    procedure SetStacked(const Value: boolean);
    function GetDataCaption: integer;
    procedure SetDataCaption(const Value: integer);
    function GetDataSource: TOpenCDS;
    procedure SetDataSource(const Value: TOpenCDS);
    function GetDataRow(Index: integer): TOOChartDataRow;
    function GetDataPoint(DataRow, PointIndex: integer): TOOChartDataPoint;
  protected
    property Document: Variant read FDocument write FDocument;
    property Obj: Variant read FObj write FObj;
    // 3D-chart properties
    property Dim3D: boolean read GetDim3D write SetDim3D;
    property Perspective: integer read GetPerspective write SetPerspective;
    property RotationHorizontal: integer read GetRotationHorizontal write SetRotationHorizontal;
    property RotationVertical: integer read GetRotationVertical write SetRotationVertical;
    // Stackable diagram properties
    property Percent: boolean read GetPercent write SetPercent;
    property Stacked: boolean read GetStacked write SetStacked;
  public
    constructor Create;
    destructor Destroy; override;
    property HasMainTitle: boolean read GetHasMainTitle write SetHasMainTitle;
    property MainTitle: TOOChartTitle read GetMainTitle;
    property HasSubTitle: boolean read GetHasSubTitle write SetHasSubTitle;
    property SubTitle: TOOChartTitle read GetSubTitle;
    property HasLegend: boolean read GetHasLegend write SetHasLegend;
    property Legend: TOOChartLegend read GetLegend;
    property DiagramType: string read GetDiagramType;
    property DataCaption: integer read GetDataCaption write SetDataCaption;
    property DataSource: TOpenCDS read GetDataSource write SetDataSource;
    property DataRow[Index: integer]: TOOChartDataRow read GetDataRow;
    property DataPoint[DataRow, PointIndex: integer]: TOOChartDataPoint read GetDataPoint;
  end;

  TOOAreaChart=class(TOOBaseChart)
  private
    function GetDeep: boolean;
    procedure SetDeep(const Value: boolean);
    function GetVertical: boolean;
    procedure SetVertical(const Value: boolean);
  protected
  public
    constructor Create;
    property Dim3D;
    property Perspective;
    property RotationHorizontal;
    property RotationVertical;
    property Percent;
    property Stacked;
    property Deep: boolean read GetDeep write SetDeep;
    property Vertical: boolean read GetVertical write SetVertical;
  end;

  TOOPieChart=class(TOOBaseChart)
  private
  protected
  public
    constructor Create;
    property Dim3D;
    property RotationHorizontal;
    property RotationVertical;
    property Stacked;
  end;

  TOOBarChart=class(TOOBaseChart)
  private
    function GetVertical: boolean;
    procedure SetVertical(const Value: boolean);
    function GetDeep: boolean;
    procedure SetDeep(const Value: boolean);
  protected
  public
    constructor Create;
    property Dim3D;
    property Perspective;
    property RotationHorizontal;
    property RotationVertical;
    property Percent;
    property Stacked;
    property Vertical: boolean read GetVertical write SetVertical;
    property Deep: boolean read GetDeep write SetDeep;
  end;

  TOOLineChart=class(TOOBaseChart)
  private
    function GetSymbolType: integer;
    procedure SetSymbolType(const Value: integer);
    function GetSymbolSize: TOpenSize;
    procedure SetSymbolSize(const Value: TOpenSize);
    function GetShowLines: boolean;
    procedure SetShowLines(const Value: boolean);
    function GetSplineType: TOpenSPT;
    procedure SetSplineType(const Value: TOpenSPT);
    function GetSplineOrder: integer;
    procedure SetSplineOrder(const Value: integer);
    function GetSplineResolution: integer;
    procedure SetSplineResolution(const Value: integer);
  protected
  public
    constructor Create;
    property Dim3D;
    property Perspective;
    property RotationHorizontal;
    property RotationVertical;
    property Percent;
    property Stacked;
    property SymbolType: integer read GetSymbolType write SetSymbolType;
    property SymbolSize: TOpenSize read GetSymbolSize write SetSymbolSize;
    property ShowLines: boolean read GetShowLines write SetShowLines;
    property SplineType: TOpenSPT read GetSplineType write SetSplineType;
    property SplineOrder: integer read GetSplineOrder write SetSplineOrder;
    property SplineResolution: integer read GetSplineResolution write SetSplineResolution;
  end;

  TOOBaseCharts=class
  private
    FDType: string;
    FDocument: Variant;
    FSheetObj: Variant;
    procedure FreeVariants; virtual;
    function GetCount: integer;
  protected
    property Document: Variant read FDocument write FDocument;
    property SheetObj: Variant read FSheetObj write FSheetObj;
  public
    constructor Create;
    procedure Append(ChartName: string; Rect: TOpenRect; RangeAddresses: TOpenRangeAddresses;
      ColHeaders, RowHeaders: boolean);
    procedure Delete(ChartName: string);
    function IsExist(ChartName: string): boolean;
    property Count: integer read GetCount;
  end;

  TOOAreaCharts=class(TOOBaseCharts)
  private
    FAreaChart: TOOAreaChart;
    procedure FreeVariants; override;
    function GetAreaChart(Index: integer): TOOAreaChart;
    function GetAreaChartByName(ChartName: string): TOOAreaChart;
  protected
  public
    constructor Create;
    destructor Destroy; override;
    property Items[Index: integer]: TOOAreaChart read GetAreaChart; default;
    property ItemsByName[ChartName: string]: TOOAreaChart read GetAreaChartByName;
  end;

  TOOPieCharts=class(TOOBaseCharts)
  private
    FPieChart: TOOPieChart;
    procedure FreeVariants; override;
    function GetPieChart(Index: integer): TOOPieChart;
    function GetPieChartByName(ChartName: string): TOOPieChart;
  protected
  public
    constructor Create;
    destructor Destroy; override;
    property Items[Index: integer]: TOOPieChart read GetPieChart; default;
    property ItemsByName[ChartName: string]: TOOPieChart read GetPieChartByName;
  end;

  TOOBarCharts=class(TOOBaseCharts)
  private
    FBarChart: TOOBarChart;
    procedure FreeVariants; override;
    function GetBarChart(Index: integer): TOOBarChart;
    function GetBarChartByName(ChartName: string): TOOBarChart;
  protected
  public
    constructor Create;
    destructor Destroy; override;
    property Items[Index: integer]: TOOBarChart read GetBarChart; default;
    property ItemsByName[ChartName: string]: TOOBarChart read GetBarChartByName;
  end;

  TOOLineCharts=class(TOOBaseCharts)
  private
    FLineChart: TOOLineChart;
    procedure FreeVariants; override;
    function GetLineChart(Index: integer): TOOLineChart;
    function GetLineChartByName(ChartName: string): TOOLineChart;
  protected
  public
    constructor Create;
    destructor Destroy; override;
    property Items[Index: integer]: TOOLineChart read GetLineChart; default;
    property ItemsByName[ChartName: string]: TOOLineChart read GetLineChartByName;
  end;

  TOOBaseShLine=class
  private
    FObj: Variant;
    procedure FreeVariants; virtual;
    function GetColor: TColor;
    procedure SetColor(const Value: TColor);
    function GetWidth: integer;
    procedure SetWidth(const Value: integer);
    function GetStyle: TOpenSLS;
    procedure SetStyle(const Value: TOpenSLS);
    function GetDash: TOpenLineDash;
    procedure SetDash(const Value: TOpenLineDash);
    function GetDashName: string;
    procedure SetDashName(const Value: string);
    function GetTransparence: integer;
    procedure SetTransparence(const Value: integer);
    function GetJoint: TOpenSLJ;
    procedure SetJoint(const Value: TOpenSLJ);
  protected
    property Obj: Variant read FObj write FObj;
  public
    property Color: TColor read GetColor write SetColor;
    property Width: integer read GetWidth write SetWidth;
    property Transparence: integer read GetTransparence write SetTransparence;
    property Style: TOpenSLS read GetStyle write SetStyle;
    property Dash: TOpenLineDash read GetDash write SetDash;
    property DashName: string read GetDashName write SetDashName;
    property Joint: TOpenSLJ read GetJoint write SetJoint;
  end;

  TOOShLine=class(TOOBaseShLine)
  private
    function GetStartName: string;
    procedure SetStartName(const Value: string);
    function GetEndName: string;
    procedure SetEndName(const Value: string);
    function GetStartCenter: boolean;
    procedure SetStartCenter(const Value: boolean);
    function GetEndCenter: boolean;
    procedure SetEndCenter(const Value: boolean);
    function GetStartWidth: integer;
    procedure SetStartWidth(const Value: integer);
    function GetEndWidth: integer;
    procedure SetEndWidth(const Value: integer);
  public
    property StartName: string read GetStartName write SetStartName;
    property EndName: string read GetEndName write SetEndName;
    property StartCenter: boolean read GetStartCenter write SetStartCenter;
    property EndCenter: boolean read GetEndCenter write SetEndCenter;
    property StartWidth: integer read GetStartWidth write SetStartWidth;
    property EndWidth: integer read GetEndWidth write SetEndWidth;
  end;

  TOOShText=class
  private
    FObj: Variant;
    FCursor: TOOBaseTextCursor;
    FOldName: string;
    FOldSType: string;
    procedure FreeVariants; virtual;
    function GetAutoGrowWidth: boolean;
    procedure SetAutoGrowWidth(const Value: boolean);
    function GetAutoGrowHeight: boolean;
    procedure SetAutoGrowHeight(const Value: boolean);
    function GetContourFrame: boolean;
    procedure SetContourFrame(const Value: boolean);
    function GetFitToSize: TOpenSTF;
    procedure SetFitToSize(const Value: TOpenSTF);
    function GetHoriAlignment: TOpenSHA;
    procedure SetHoriAlignment(const Value: TOpenSHA);
    function GetVertAlignment: TOpenSVA;
    procedure SetVertAlignment(const Value: TOpenSVA);
    function GetLeftDistance: integer;
    procedure SetLeftDistance(const Value: integer);
    function GetRightDistance: integer;
    procedure SetRightDistance(const Value: integer);
    function GetUpperDistance: integer;
    procedure SetUpperDistance(const Value: integer);
    function GetLowerDistance: integer;
    procedure SetLowerDistance(const Value: integer);
    function GetMinimumFrameWidth: integer;
    procedure SetMinimumFrameWidth(const Value: integer);
    function GetMinimumFrameHeight: integer;
    procedure SetMinimumFrameHeight(const Value: integer);
    function GetMaximumFrameWidth: integer;
    procedure SetMaximumFrameWidth(const Value: integer);
    function GetMaximumFrameHeight: integer;
    procedure SetMaximumFrameHeight(const Value: integer);
    function GetAnimationAmount: integer;
    procedure SetAnimationAmount(const Value: integer);
    function GetAnimationCount: integer;
    procedure SetAnimationCount(const Value: integer);
    function GetAnimationDelay: integer;
    procedure SetAnimationDelay(const Value: integer);
    function GetAnimationDirection: TOpenSAD;
    procedure SetAnimationDirection(const Value: TOpenSAD);
    function GetAnimationKind: TOpenSAK;
    procedure SetAnimationKind(const Value: TOpenSAK);
    function GetAnimationStartInside: boolean;
    procedure SetAnimationStartInside(const Value: boolean);
    function GetAnimationStopInside: boolean;
    procedure SetAnimationStopInside(const Value: boolean);
    function GetCursor: TOOBaseTextCursor;
  protected
    property Obj: Variant read FObj write FObj;
  public
    constructor Create;
    destructor Destroy; override;
    property AutoGrowWidth: boolean read GetAutoGrowWidth write SetAutoGrowWidth;
    property AutoGrowHeight: boolean read GetAutoGrowHeight write SetAutoGrowHeight;
    property ContourFrame: boolean read GetContourFrame write SetContourFrame;
    property FitToSize: TOpenSTF read GetFitToSize write SetFitToSize;
    property HoriAlignment: TOpenSHA read GetHoriAlignment write SetHoriAlignment;
    property VertAlignment: TOpenSVA read GetVertAlignment write SetVertAlignment;
    property LeftDistance: integer read GetLeftDistance write SetLeftDistance;
    property RightDistance: integer read GetRightDistance write SetRightDistance;
    property UpperDistance: integer read GetUpperDistance write SetUpperDistance;
    property LowerDistance: integer read GetLowerDistance write SetLowerDistance;
    property MinimumFrameWidth: integer read GetMinimumFrameWidth write SetMinimumFrameWidth;
    property MinimumFrameHeight: integer read GetMinimumFrameHeight write SetMinimumFrameHeight;
    property MaximumFrameWidth: integer read GetMaximumFrameWidth write SetMaximumFrameWidth;
    property MaximumFrameHeight: integer read GetMaximumFrameHeight write SetMaximumFrameHeight;
    property AnimationAmount: integer read GetAnimationAmount write SetAnimationAmount;
    property AnimationCount: integer read GetAnimationCount write SetAnimationCount;
    property AnimationDelay: integer read GetAnimationDelay write SetAnimationDelay;
    property AnimationDirection: TOpenSAD read GetAnimationDirection write SetAnimationDirection;
    property AnimationKind: TOpenSAK read GetAnimationKind write SetAnimationKind;
    property AnimationStartInside: boolean read GetAnimationStartInside
      write SetAnimationStartInside;
    property AnimationStopInside: boolean read GetAnimationStopInside write SetAnimationStopInside;
    property Cursor: TOOBaseTextCursor read GetCursor;
  end;

  TOOShShadow=class
  private
    FObj: Variant;
    procedure FreeVariants; virtual;
    function GetEnable: boolean;
    procedure SetEnable(const Value: boolean);
    function GetColor: TColor;
    procedure SetColor(const Value: TColor);
    function GetTransparence: integer;
    procedure SetTransparence(const Value: integer);
    function GetXDistance: integer;
    procedure SetXDistance(const Value: integer);
    function GetYDistance: integer;
    procedure SetYDistance(const Value: integer);
  protected
    property Obj: Variant read FObj write FObj;
  public
    property Enable: boolean read GetEnable write SetEnable;
    property Color: TColor read GetColor write SetColor;
    property Transparence: integer read GetTransparence write SetTransparence;
    property XDistance: integer read GetXDistance write SetXDistance;
    property YDistance: integer read GetYDistance write SetYDistance;
  end;

  TOOShFill=class
  private
    FObj: Variant;
    procedure FreeVariants; virtual;
    function GetStyle: TOpenSFS;
    procedure SetStyle(const Value: TOpenSFS);
    function GetColor: TColor;
    procedure SetColor(const Value: TColor);
    function GetTransparence: integer;
    procedure SetTransparence(const Value: integer);
    function GetTransparenceGradientName: string;
    procedure SetTransparenceGradientName(const Value: string);
    function GetTransparenceGradient: TOpenGradient;
    procedure SetTransparenceGradient(const Value: TOpenGradient);
    function GetGradientName: string;
    procedure SetGradientName(const Value: string);
    function GetGradient: TOpenGradient;
    procedure SetGradient(const Value: TOpenGradient);
    function GetHatchName: string;
    procedure SetHatchName(const Value: string);
    function GetHatch: TOpenHatch;
    procedure SetHatch(const Value: TOpenHatch);
    function GetBackground: boolean;
    procedure SetBackground(const Value: boolean);
  protected
    property Obj: Variant read FObj write FObj;
  public
    property Style: TOpenSFS read GetStyle write SetStyle;
    property Color: TColor read GetColor write SetColor;
    property Transparence: integer read GetTransparence write SetTransparence;
    property TransparenceGradientName: string read GetTransparenceGradientName
      write SetTransparenceGradientName;
    property TransparenceGradient: TOpenGradient read GetTransparenceGradient
      write SetTransparenceGradient;
    property GradientName: string read GetGradientName write SetGradientName;
    property Gradient: TOpenGradient read GetGradient write SetGradient;
    property HatchName: string read GetHatchName write SetHatchName;
    property Hatch: TOpenHatch read GetHatch write SetHatch;
    property Background: boolean read GetBackground write SetBackground;
  end;

  TOOBaseShape=class
  private
    FSType: string;
    FShapeObj: Variant;
    FLine: TOOShLine;
    FText: TOOShText;
    FShadow: TOOShShadow;
    FFill: TOOShFill;
    procedure FreeVariants; virtual;
    function GetShapeType: string;
    function GetName: string;
    procedure SetName(const Value: string);
    function GetPositionProtect: boolean;
    procedure SetPositionProtect(const Value: boolean);
    function GetSizeProtect: boolean;
    procedure SetSizeProtect(const Value: boolean);
    function GetPrintable: boolean;
    procedure SetPrintable(const Value: boolean);
    function GetPosition: TOpenPoint;
    procedure SetPosition(const Value: TOpenPoint);
    function GetSize: TOpenSize;
    procedure SetSize(const Value: TOpenSize);
    function GetLine: TOOShLine;
    function GetText: TOOShText;
    function GetShadow: TOOShShadow;
    function GetFill: TOOShFill;
    function GetTransformation: TOpenMatrix;
    procedure SetTransformation(const Value: TOpenMatrix);
  protected
    property ShapeObj: Variant read FShapeObj write FShapeObj;
    property Line: TOOShLine read GetLine;
    property Text: TOOShText read GetText;
    property Shadow: TOOShShadow read GetShadow;
    property Fill: TOOShFill read GetFill;
  public
    constructor Create;
    destructor Destroy; override;
    property ShapeType: string read GetShapeType;
    property Name: string read GetName write SetName;
    property Position: TOpenPoint read GetPosition write SetPosition;
    property PositionProtect: boolean read GetPositionProtect write SetPositionProtect;
    property Size: TOpenSize read GetSize write SetSize;
    property SizeProtect: boolean read GetSizeProtect write SetSizeProtect;
    property Printable: boolean read GetPrintable write SetPrintable;
    property Transformation: TOpenMatrix read GetTransformation write SetTransformation;
  end;

  TOOTextShape=class(TOOBaseShape)
  private
    function GetCornerRadius: integer;
    procedure SetCornerRadius(const Value: integer);
  public
    constructor Create;
    property Line;
    property Text;
    property Shadow;
    property Fill;
    property CornerRadius: integer read GetCornerRadius write SetCornerRadius;
  end;

  TOOLineShape=class(TOOBaseShape)
  private
  public
    constructor Create;
    property Line;
    property Text;
    property Shadow;
  end;

  TOOGraphicShape=class(TOOBaseShape)
  private
    function GetAdjustTransparence: integer;
    procedure SetAdjustTransparence(const Value: integer);
    function GetAdjustLuminance: integer;
    procedure SetAdjustLuminance(const Value: integer);
    function GetAdjustContrast: integer;
    procedure SetAdjustContrast(const Value: integer);
    function GetAdjustRed: integer;
    procedure SetAdjustRed(const Value: integer);
    function GetAdjustGreen: integer;
    procedure SetAdjustGreen(const Value: integer);
    function GetAdjustBlue: integer;
    procedure SetAdjustBlue(const Value: integer);
    function GetGamma: double;
    procedure SetGamma(const Value: double);
    function GetColorMode: TOpenCR;
    procedure SetColorMode(const Value: TOpenCR);
  public
    constructor Create;
    procedure LoadFromFile(FileName: string);
    property Text;
    property Shadow;
    property Transparence: integer read GetAdjustTransparence write SetAdjustTransparence;
    property AdjustLuminance: integer read GetAdjustLuminance write SetAdjustLuminance;
    property AdjustContrast: integer read GetAdjustContrast write SetAdjustContrast;
    property AdjustRed: integer read GetAdjustRed write SetAdjustRed;
    property AdjustGreen: integer read GetAdjustGreen write SetAdjustGreen;
    property AdjustBlue: integer read GetAdjustBlue write SetAdjustBlue;
    property Gamma: double read GetGamma write SetGamma;
    property ColorMode: TOpenCR read GetColorMode write SetColorMode;
  end;

  TOOEllipseShape=class(TOOBaseShape)
  private
    function GetKind: TOpenSCK;
    procedure SetKind(const Value: TOpenSCK);
    function GetStartAngle: integer;
    procedure SetStartAngle(const Value: integer);
    function GetEndAngle: integer;
    procedure SetEndAngle(const Value: integer);
  public
    constructor Create;
    property Line;
    property Text;
    property Shadow;
    property Fill;
    property Kind: TOpenSCK read GetKind write SetKind;
    property StartAngle: integer read GetStartAngle write SetStartAngle;
    property EndAngle: integer read GetEndAngle write SetEndAngle;
  end;

  TOORectangleShape=class(TOOBaseShape)
  private
    function GetCornerRadius: integer;
    procedure SetCornerRadius(const Value: integer);
  public
    constructor Create;
    property Line;
    property Text;
    property Shadow;
    property Fill;
    property CornerRadius: integer read GetCornerRadius write SetCornerRadius;
  end;

  TOOMeasureShape=class(TOOBaseShape)
  private
    function GetStartPosition: TOpenPoint;
    procedure SetStartPosition(const Value: TOpenPoint);
    function GetEndPosition: TOpenPoint;
    procedure SetEndPosition(const Value: TOpenPoint);
    function GetBelowReferenceEdge: boolean;
    procedure SetBelowReferenceEdge(const Value: boolean);
    function GetHelpLine1Length: integer;
    procedure SetHelpLine1Length(const Value: integer);
    function GetHelpLine2Length: integer;
    procedure SetHelpLine2Length(const Value: integer);
    function GetHelpLineDistance: integer;
    procedure SetHelpLineDistance(const Value: integer);
    function GetHelpLineOverhang: integer;
    procedure SetHelpLineOverhang(const Value: integer);
    function GetKind: TOpenSMK;
    procedure SetKind(const Value: TOpenSMK);
    function GetLineDistance: integer;
    procedure SetLineDistance(const Value: integer);
    function GetOverhang: integer;
    procedure SetOverhang(const Value: integer);
    function GetShowUnit: boolean;
    procedure SetShowUnit(const Value: boolean);
    function GetTextAutoAngle: boolean;
    procedure SetTextAutoAngle(const Value: boolean);
    function GetTextAutoAngleView: integer;
    procedure SetTextAutoAngleView(const Value: integer);
    function GetTextFixedAngle: integer;
    procedure SetTextFixedAngle(const Value: integer);
    function GetTextHorizontalPosition: TOpenSMH;
    procedure SetTextHorizontalPosition(const Value: TOpenSMH);
    function GetTextVerticalPosition: TOpenSMV;
    procedure SetTextVerticalPosition(const Value: TOpenSMV);
    function GetTextIsFixedAngle: boolean;
    procedure SetTextIsFixedAngle(const Value: boolean);
    function GetTextRotate90: boolean;
    procedure SetTextRotate90(const Value: boolean);
    function GetTextUpsideDown: boolean;
    procedure SetTextUpsideDown(const Value: boolean);
    function GetDecimalPlaces: integer;
    procedure SetDecimalPlaces(const Value: integer);
  public
    constructor Create;
    property Line;
    property Text;
    property Shadow;
    property StartPosition: TOpenPoint read GetStartPosition write SetStartPosition;
    property EndPosition: TOpenPoint read GetEndPosition write SetEndPosition;
    property BelowReferenceEdge: boolean read GetBelowReferenceEdge write SetBelowReferenceEdge;
    property HelpLine1Length: integer read GetHelpLine1Length write SetHelpLine1Length;
    property HelpLine2Length: integer read GetHelpLine2Length write SetHelpLine2Length;
    property HelpLineDistance: integer read GetHelpLineDistance write SetHelpLineDistance;
    property HelpLineOverhang: integer read GetHelpLineOverhang write SetHelpLineOverhang;
    property Kind: TOpenSMK read GetKind write SetKind;
    property LineDistance: integer read GetLineDistance write SetLineDistance;
    property Overhang: integer read GetOverhang write SetOverhang;
    property ShowUnit: boolean read GetShowUnit write SetShowUnit;
    property TextAutoAngle: boolean read GetTextAutoAngle write SetTextAutoAngle;
    property TextAutoAngleView: integer read GetTextAutoAngleView write SetTextAutoAngleView;
    property TextFixedAngle: integer read GetTextFixedAngle write SetTextFixedAngle;
    property TextHorizontalPosition: TOpenSMH read GetTextHorizontalPosition
      write SetTextHorizontalPosition;
    property TextVerticalPosition: TOpenSMV read GetTextVerticalPosition
      write SetTextVerticalPosition;
    property TextIsFixedAngle: boolean read GetTextIsFixedAngle write SetTextIsFixedAngle;
    property TextRotate90: boolean read GetTextRotate90 write SetTextRotate90;
    property TextUpsideDown: boolean read GetTextUpsideDown write SetTextUpsideDown;
    property DecimalPlaces: integer read GetDecimalPlaces write SetDecimalPlaces;
  end;

  TOOBaseShapes=class
  private
    FSType: string;
    FDocument: Variant;
    FDrawPageObj: Variant;
    procedure FreeVariants; virtual;
    function GetCount: integer;
  protected
    property Document: Variant read FDocument write FDocument;
    property DrawPageObj: Variant read FDrawPageObj write FDrawPageObj;
  public
    constructor Create;
    procedure Append(X, Y, Width, Height: integer; ShapeName: string);
    function IsExist(ShapeName: string): boolean;
    property Count: integer read GetCount;
  end;

  TOOTextShapes=class(TOOBaseShapes)
  private
    FTextShape: TOOTextShape;
    procedure FreeVariants; override;
    function GetTextShape(Index: integer): TOOTextShape;
    function GetTextShapeByName(ShapeName: string): TOOTextShape;
  protected
  public
    constructor Create;
    destructor Destroy; override;
    property Items[Index: integer]: TOOTextShape read GetTextShape; default;
    property ItemsByName[ShapeName: string]: TOOTextShape read GetTextShapeByName;
  end;

  TOOLineShapes=class(TOOBaseShapes)
  private
    FLineShape: TOOLineShape;
    procedure FreeVariants; override;
    function GetLineShape(Index: integer): TOOLineShape;
    function GetLineShapeByName(ShapeName: string): TOOLineShape;
  protected
  public
    constructor Create;
    destructor Destroy; override;
    property Items[Index: integer]: TOOLineShape read GetLineShape; default;
    property ItemsByName[ShapeName: string]: TOOLineShape read GetLineShapeByName;
  end;

  TOOGraphicShapes=class(TOOBaseShapes)
  private
    FGraphicShape: TOOGraphicShape;
    procedure FreeVariants; override;
    function GetGraphicShape(Index: integer): TOOGraphicShape;
    function GetGraphicShapeByName(ShapeName: string): TOOGraphicShape;
  protected
  public
    constructor Create;
    destructor Destroy; override;
    property Items[Index: integer]: TOOGraphicShape read GetGraphicShape; default;
    property ItemsByName[ShapeName: string]: TOOGraphicShape read GetGraphicShapeByName;
  end;

  TOOEllipseShapes=class(TOOBaseShapes)
  private
    FEllipseShape: TOOEllipseShape;
    procedure FreeVariants; override;
    function GetEllipseShape(Index: integer): TOOEllipseShape;
    function GetEllipseShapeByName(ShapeName: string): TOOEllipseShape;
  protected
  public
    constructor Create;
    destructor Destroy; override;
    property Items[Index: integer]: TOOEllipseShape read GetEllipseShape; default;
    property ItemsByName[ShapeName: string]: TOOEllipseShape read GetEllipseShapeByName;
  end;

  TOORectangleShapes=class(TOOBaseShapes)
  private
    FRectangleShape: TOORectangleShape;
    procedure FreeVariants; override;
    function GetRectangleShape(Index: integer): TOORectangleShape;
    function GetRectangleShapeByName(ShapeName: string): TOORectangleShape;
  protected
  public
    constructor Create;
    destructor Destroy; override;
    property Items[Index: integer]: TOORectangleShape read GetRectangleShape; default;
    property ItemsByName[ShapeName: string]: TOORectangleShape read GetRectangleShapeByName;
  end;

  TOOMeasureShapes=class(TOOBaseShapes)
  private
    FMeasureShape: TOOMeasureShape;
    procedure FreeVariants; override;
    function GetMeasureShape(Index: integer): TOOMeasureShape;
    function GetMeasureShapeByName(ShapeName: string): TOOMeasureShape;
  protected
  public
    constructor Create;
    destructor Destroy; override;
    property Items[Index: integer]: TOOMeasureShape read GetMeasureShape; default;
    property ItemsByName[ShapeName: string]: TOOMeasureShape read GetMeasureShapeByName;
  end;

  TOOCharProperties=class
  private
    FCharPropertiesObj: Variant;
    FOnChange: TNotifyEvent;
    procedure FreeVariants; virtual;
    procedure DoChange;
    function GetFontName: string;
    procedure SetFontName(const Value: string);
    function GetFontStyleName: string;
    procedure SetFontStyleName(const Value: string);
    function GetColor: TColor;
    procedure SetColor(const Value: TColor);
    function GetEscapement: integer;
    procedure SetEscapement(const Value: integer);
    function GetHeight: integer;
    procedure SetHeight(const Value: integer);
    function GetUnderline: TOpenFU;
    procedure SetUnderline(const Value: TOpenFU);
    function GetWeight: integer;
    procedure SetWeight(const Value: integer);
    function GetPosture: TOpenFP;
    procedure SetPosture(const Value: TOpenFP);
    function GetAutoKerning: boolean;
    procedure SetAutoKerning(const Value: boolean);
    function GetBackColor: TColor;
    procedure SetBackColor(const Value: TColor);
    function GetBackColorTransparent: boolean;
    procedure SetBackColorTransparent(const Value: boolean);
    function GetCaseMap: TOpenCM;
    procedure SetCaseMap(const Value: TOpenCM);
    function GetCrossedOut: boolean;
    procedure SetCrossedOut(const Value: boolean);
    function GetFlash: boolean;
    procedure SetFlash(const Value: boolean);
    function GetStrikeout: TOpenFS;
    procedure SetStrikeout(const Value: TOpenFS);
    function GetWordMode: boolean;
    procedure SetWordMode(const Value: boolean);
    function GetKerning: integer;
    procedure SetKerning(const Value: integer);
    function GetKeepTogether: boolean;
    procedure SetKeepTogether(const Value: boolean);
    function GetNoLineBreak: boolean;
    procedure SetNoLineBreak(const Value: boolean);
    function GetShadowed: boolean;
    procedure SetShadowed(const Value: boolean);
    function GetStyleName: string;
    procedure SetStyleName(const Value: string);
    function GetContoured: boolean;
    procedure SetContoured(const Value: boolean);
    function GetCombineIsOn: boolean;
    procedure SetCombineIsOn(const Value: boolean);
    function GetCombinePrefix: string;
    procedure SetCombinePrefix(const Value: string);
    function GetCombineSuffix: string;
    procedure SetCombineSuffix(const Value: string);
    function GetEmphasis: TOpenFE;
    procedure SetEmphasis(const Value: TOpenFE);
    function GetRelief: TOpenFR;
    procedure SetRelief(const Value: TOpenFR);
    function GetRotation: integer;
    procedure SetRotation(const Value: integer);
    function GetRotationIsFitToLine: boolean;
    procedure SetRotationIsFitToLine(const Value: boolean);
    function GetScaleWidth: integer;
    procedure SetScaleWidth(const Value: integer);
    function GetEscapementHeight: integer;
    procedure SetEscapementHeight(const Value: integer);
    function GetNoHyphenation: boolean;
    procedure SetNoHyphenation(const Value: boolean);
    function GetUnderlineColor: TColor;
    procedure SetUnderlineColor(const Value: TColor);
    function GetUnderlineHasColor: boolean;
    procedure SetUnderlineHasColor(const Value: boolean);
    function GetHidden: boolean;
    procedure SetHidden(const Value: boolean);
  protected
    property CharPropertiesObj: Variant read FCharPropertiesObj write FCharPropertiesObj;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  public
    property FontName: string read GetFontName write SetFontName;
    property FontStyleName: string read GetFontStyleName write SetFontStyleName;
    property Color: TColor read GetColor write SetColor;
    property Escapement: integer read GetEscapement write SetEscapement;
    property Height: integer read GetHeight write SetHeight;
    property Underline: TOpenFU read GetUnderline write SetUnderline;
    property Weight: integer read GetWeight write SetWeight;
    property Posture: TOpenFP read GetPosture write SetPosture;
    property AutoKerning: boolean read GetAutoKerning write SetAutoKerning;
    property BackColor: TColor read GetBackColor write SetBackColor;
    property BackColorTransparent: boolean read GetBackColorTransparent
      write SetBackColorTransparent;
    property CaseMap: TOpenCM read GetCaseMap write SetCaseMap;
    property CrossedOut: boolean read GetCrossedOut write SetCrossedOut;
    property Flash: boolean read GetFlash write SetFlash;
    property Strikeout: TOpenFS read GetStrikeout write SetStrikeout;
    property WordMode: boolean read GetWordMode write SetWordMode;
    property Kerning: integer read GetKerning write SetKerning;
    property KeepTogether: boolean read GetKeepTogether write SetKeepTogether;
    property NoLineBreak: boolean read GetNoLineBreak write SetNoLineBreak;
    property Shadowed: boolean read GetShadowed write SetShadowed;
    property StyleName: string read GetStyleName write SetStyleName;
    property Contoured: boolean read GetContoured write SetContoured;
    property CombineIsOn: boolean read GetCombineIsOn write SetCombineIsOn;
    property CombinePrefix: string read GetCombinePrefix write SetCombinePrefix;
    property CombineSuffix: string read GetCombineSuffix write SetCombineSuffix;
    property Emphasis: TOpenFE read GetEmphasis write SetEmphasis;
    property Relief: TOpenFR read GetRelief write SetRelief;
    property Rotation: integer read GetRotation write SetRotation;
    property RotationIsFitToLine: boolean read GetRotationIsFitToLine write SetRotationIsFitToLine;
    property ScaleWidth: integer read GetScaleWidth write SetScaleWidth;
    property EscapementHeight: integer read GetEscapementHeight write SetEscapementHeight;
    property NoHyphenation: boolean read GetNoHyphenation write SetNoHyphenation;
    property UnderlineColor: TColor read GetUnderlineColor write SetUnderlineColor;
    property UnderlineHasColor: boolean read GetUnderlineHasColor write SetUnderlineHasColor;
    property Hidden: boolean read GetHidden write SetHidden;
  end;

  TOOParaProperties=class
  private
    FParaMargin: TOOParaMargin;
    FParaPropertiesObj: Variant;
    FBorder: TOOBorderDistance;
    FOnChange: TNotifyEvent;
    procedure FreeVariants; virtual;
    procedure DoChange;
    function GetHoriAlignment: TOpenPHA;
    procedure SetHoriAlignment(const Value: TOpenPHA);
    function GetVertAlignment: TOpenPVA;
    procedure SetVertAlignment(const Value: TOpenPVA);
    function GetLineSpacing: TOpenLineSpacing;
    procedure SetLineSpacing(const Value: TOpenLineSpacing);
    function GetBackColor: TColor;
    procedure SetBackColor(const Value: TColor);
    function GetBackColorTransparent: boolean;
    procedure SetBackColorTransparent(const Value: boolean);
    function GetLastLineAlignment: TOpenPHA;
    procedure SetLastLineAlignment(const Value: TOpenPHA);
    function GetExpandSingleWord: boolean;
    procedure SetExpandSingleWord(const Value: boolean);
    function GetMargin: TOOParaMargin;
    function GetLineNumberCount: boolean;
    procedure SetLineNumberCount(const Value: boolean);
    function GetLineNumberStartValue: integer;
    procedure SetLineNumberStartValue(const Value: integer);
    function GetPageDescName: string;
    procedure SetPageDescName(const Value: string);
    function GetPageNumberOffset: integer;
    procedure SetPageNumberOffset(const Value: integer);
    function GetRegisterModeActive: boolean;
    procedure SetRegisterModeActive(const Value: boolean);
    function GetStyleName: string;
    procedure SetStyleName(const Value: string);
    function GetPageStyleName: string;
    function GetDropCapFormat: TOpenDropCapFormat;
    procedure SetDropCapFormat(const Value: TOpenDropCapFormat);
    function GetDropCapWholeWord: boolean;
    procedure SetDropCapWholeWord(const Value: boolean);
    function GetKeepTogether: boolean;
    procedure SetKeepTogether(const Value: boolean);
    function GetSplit: boolean;
    procedure SetSplit(const Value: boolean);
    function GetNumberingLevel: integer;
    procedure SetNumberingLevel(const Value: integer);
    function GetNumberingStartValue: integer;
    procedure SetNumberingStartValue(const Value: integer);
    function GetIsNumberingRestart: boolean;
    procedure SetIsNumberingRestart(const Value: boolean);
    function GetNumberingStyleName: string;
    procedure SetNumberingStyleName(const Value: string);
    function GetOrphans: integer;
    procedure SetOrphans(const Value: integer);
    function GetWidows: integer;
    procedure SetWidows(const Value: integer);
    function GetShadowFormat: TOpenShadowFormat;
    procedure SetShadowFormat(const Value: TOpenShadowFormat);
    function GetBorder: TOOBorderDistance;
    function GetBorderDistance: integer;
    procedure SetBorderDistance(const Value: integer);
    function GetBreakType: TOpenBT;
    procedure SetBreakType(const Value: TOpenBT);
    function GetDropCapCharStyleName: string;
    procedure SetDropCapCharStyleName(const Value: string);
    function GetFirstLineIndent: integer;
    procedure SetFirstLineIndent(const Value: integer);
    function GetIsAutoFirstLineIndent: boolean;
    procedure SetIsAutoFirstLineIndent(const Value: boolean);
    function GetIsHyphenation: boolean;
    procedure SetIsHyphenation(const Value: boolean);
    function GetHyphenationMaxHyphens: integer;
    procedure SetHyphenationMaxHyphens(const Value: integer);
    function GetHyphenationMaxLeadingChars: integer;
    procedure SetHyphenationMaxLeadingChars(const Value: integer);
    function GetHyphenationMaxTrailingChars: integer;
    procedure SetHyphenationMaxTrailingChars(const Value: integer);
    function GetIsConnectBorder: boolean;
    procedure SetIsConnectBorder(const Value: boolean);
  protected
    procedure DoMarginChange(Sender: TObject);
    procedure DoBorderChange(Sender: TObject);
    property ParaPropertiesObj: Variant read FParaPropertiesObj write FParaPropertiesObj;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  public
    constructor Create;
    destructor Destroy; override;
    property HoriAlignment: TOpenPHA read GetHoriAlignment write SetHoriAlignment;
    property VertAlignment: TOpenPVA read GetVertAlignment write SetVertAlignment;
    property LastLineAlignment: TOpenPHA read GetLastLineAlignment write SetLastLineAlignment;
    property LineSpacing: TOpenLineSpacing read GetLineSpacing write SetLineSpacing;
    property BackColor: TColor read GetBackColor write SetBackColor;
    property BackColorTransparent: boolean read GetBackColorTransparent
      write SetBackColorTransparent;
    property FirstLineIndent: integer read GetFirstLineIndent write SetFirstLineIndent;
    property IsAutoFirstLineIndent: boolean read GetIsAutoFirstLineIndent
      write SetIsAutoFirstLineIndent;
    property ExpandSingleWord: boolean read GetExpandSingleWord write SetExpandSingleWord;
    property Margin: TOOParaMargin read GetMargin;
    property LineNumberCount: boolean read GetLineNumberCount write SetLineNumberCount;
    property LineNumberStartValue: integer read GetLineNumberStartValue
      write SetLineNumberStartValue;
    property PageDescName: string read GetPageDescName write SetPageDescName;
    property PageNumberOffset: integer read GetPageNumberOffset write SetPageNumberOffset;
    property RegisterModeActive: boolean read GetRegisterModeActive write SetRegisterModeActive;
    property StyleName: string read GetStyleName write SetStyleName;
    property PageStyleName: string read GetPageStyleName;
    property DropCapFormat: TOpenDropCapFormat read GetDropCapFormat write SetDropCapFormat;
    property DropCapWholeWord: boolean read GetDropCapWholeWord write SetDropCapWholeWord;
    property DropCapCharStyleName: string read GetDropCapCharStyleName
      write SetDropCapCharStyleName;
    property KeepTogether: boolean read GetKeepTogether write SetKeepTogether;
    property Split: boolean read GetSplit write SetSplit;
    property NumberingLevel: integer read GetNumberingLevel write SetNumberingLevel;
    property NumberingStartValue: integer read GetNumberingStartValue write SetNumberingStartValue;
    property IsNumberingRestart: boolean read GetIsNumberingRestart write SetIsNumberingRestart;
    property NumberingStyleName: string read GetNumberingStyleName write SetNumberingStyleName;
    property Orphans: integer read GetOrphans write SetOrphans;
    property Widows: integer read GetWidows write SetWidows;
    property ShadowFormat: TOpenShadowFormat read GetShadowFormat write SetShadowFormat;
    property Border: TOOBorderDistance read GetBorder;
    property BorderDistance: integer read GetBorderDistance write SetBorderDistance;
    property BreakType: TOpenBT read GetBreakType write SetBreakType;
    property IsHyphenation: boolean read GetIsHyphenation write SetIsHyphenation;
    property HyphenationMaxHyphens: integer read GetHyphenationMaxHyphens
      write SetHyphenationMaxHyphens;
    property HyphenationMaxLeadingChars: integer read GetHyphenationMaxLeadingChars
      write SetHyphenationMaxLeadingChars;
    property HyphenationMaxTrailingChars: integer read GetHyphenationMaxTrailingChars
      write SetHyphenationMaxTrailingChars;
    property IsConnectBorder: boolean read GetIsConnectBorder write SetIsConnectBorder;
  end;

  TOOMargin=class
  private
    FMarginObj: Variant;
    FOnChange: TNotifyEvent;
    procedure FreeVariants; virtual;
    procedure DoChange;
    function GetLeft: integer;
    procedure SetLeft(const Value: integer);
    function GetRight: integer;
    procedure SetRight(const Value: integer);
    function GetTop: integer;
    procedure SetTop(const Value: integer);
    function GetBottom: integer;
    procedure SetBottom(const Value: integer);
  protected
    property MarginObj: Variant read FMarginObj write FMarginObj;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  public
    property Left: integer read GetLeft write SetLeft;
    property Right: integer read GetRight write SetRight;
    property Top: integer read GetTop write SetTop;
    property Bottom: integer read GetBottom write SetBottom;
  end;

  TOOParaMargin=class
  private
    FMarginObj: Variant;
    FOnChange: TNotifyEvent;
    procedure FreeVariants; virtual;
    procedure DoChange;
    function GetLeft: integer;
    procedure SetLeft(const Value: integer);
    function GetRight: integer;
    procedure SetRight(const Value: integer);
    function GetTop: integer;
    procedure SetTop(const Value: integer);
    function GetBottom: integer;
    procedure SetBottom(const Value: integer);
  protected
    property MarginObj: Variant read FMarginObj write FMarginObj;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  public
    property Left: integer read GetLeft write SetLeft;
    property Right: integer read GetRight write SetRight;
    property Top: integer read GetTop write SetTop;
    property Bottom: integer read GetBottom write SetBottom;
  end;

  TOOBorder=class
  private
    FBorderObj: Variant;
    FOnChange: TNotifyEvent;
    procedure FreeVariants; virtual;
    procedure DoChange;
    function GetLeft: TOpenBorderLine;
    procedure SetLeft(const Value: TOpenBorderLine);
    function GetRight: TOpenBorderLine;
    procedure SetRight(const Value: TOpenBorderLine);
    function GetTop: TOpenBorderLine;
    procedure SetTop(const Value: TOpenBorderLine);
    function GetBottom: TOpenBorderLine;
    procedure SetBottom(const Value: TOpenBorderLine);
  protected
    property BorderObj: Variant read FBorderObj write FBorderObj;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  public
    property Left: TOpenBorderLine read GetLeft write SetLeft;
    property Right: TOpenBorderLine read GetRight write SetRight;
    property Top: TOpenBorderLine read GetTop write SetTop;
    property Bottom: TOpenBorderLine read GetBottom write SetBottom;
  end;

  TOOBorderDistance=class(TOOBorder)
  private
    function GetLeftDistance: integer;
    procedure SetLeftDistance(const Value: integer);
    function GetRightDistance: integer;
    procedure SetRightDistance(const Value: integer);
    function GetTopDistance: integer;
    procedure SetTopDistance(const Value: integer);
    function GetBottomDistance: integer;
    procedure SetBottomDistance(const Value: integer);
  public
    property LeftDistance: integer read GetLeftDistance write SetLeftDistance;
    property RightDistance: integer read GetRightDistance write SetRightDistance;
    property TopDistance: integer read GetTopDistance write SetTopDistance;
    property BottomDistance: integer read GetBottomDistance write SetBottomDistance;
  end;

  TOOHeaderBorderDistance=class(TOOBorder)
  private
    function GetLeftDistance: integer;
    procedure SetLeftDistance(const Value: integer);
    function GetRightDistance: integer;
    procedure SetRightDistance(const Value: integer);
    function GetTopDistance: integer;
    procedure SetTopDistance(const Value: integer);
    function GetBottomDistance: integer;
    procedure SetBottomDistance(const Value: integer);
  public
    property LeftDistance: integer read GetLeftDistance write SetLeftDistance;
    property RightDistance: integer read GetRightDistance write SetRightDistance;
    property TopDistance: integer read GetTopDistance write SetTopDistance;
    property BottomDistance: integer read GetBottomDistance write SetBottomDistance;
  end;

  TOOTableBorder=class
  private
    FTableBorderObj: Variant;
    procedure FreeVariants; virtual;
    function GetLeft: TOpenBorderLine;
    procedure SetLeft(const Value: TOpenBorderLine);
    function GetRight: TOpenBorderLine;
    procedure SetRight(const Value: TOpenBorderLine);
    function GetTop: TOpenBorderLine;
    procedure SetTop(const Value: TOpenBorderLine);
    function GetBottom: TOpenBorderLine;
    procedure SetBottom(const Value: TOpenBorderLine);
    function GetHorizontal: TOpenBorderLine;
    procedure SetHorizontal(const Value: TOpenBorderLine);
    function GetVertical: TOpenBorderLine;
    procedure SetVertical(const Value: TOpenBorderLine);
  protected
    property TableBorderObj: Variant read FTableBorderObj write FTableBorderObj;
  public
    procedure SetAll(const Value: TOpenBorderLine; Lines: TOpenTB);
    property Left: TOpenBorderLine read GetLeft write SetLeft;
    property Right: TOpenBorderLine read GetRight write SetRight;
    property Top: TOpenBorderLine read GetTop write SetTop;
    property Bottom: TOpenBorderLine read GetBottom write SetBottom;
    property Horizontal: TOpenBorderLine read GetHorizontal write SetHorizontal;
    property Vertical: TOpenBorderLine read GetVertical write SetVertical;
  end;

  TOOPrinter=class
  private
    FDocument: Variant;
    FCopyCount: integer;
    FFileName: string;
    FCollate: boolean;
    FPages: string;
    procedure FreeVariants; virtual;
    function GetValue(VariantArray: Variant; Name: string): Variant;
    procedure SetValue(var VariantArray: Variant; Name: string; Value: Variant);
    function GetName: string;
    procedure SetName(const Value: string);
    function GetPaperFormat: TOpenPF;
    procedure SetPaperFormat(const Value: TOpenPF);
    function GetPaperOrientation: TOpenPO;
    procedure SetPaperOrientation(const Value: TOpenPO);
    function GetPaperSize: TOpenSize;
    procedure SetPaperSize(const Value: TOpenSize);
    procedure SetCopyCount(const Value: integer);
    procedure SetFileName(const Value: string);
    procedure SetCollate(const Value: boolean);
    procedure SetPages(const Value: string);
    function GetIsBusy: boolean;
  protected
    property Document: Variant read FDocument write FDocument;
  public
    constructor Create;
    procedure Print(Options: TOpenPT);
    property Name: string read GetName write SetName;
    property PaperFormat: TOpenPF read GetPaperFormat write SetPaperFormat;
    property PaperOrientation: TOpenPO read GetPaperOrientation write SetPaperOrientation;
    property PaperSize: TOpenSize read GetPaperSize write SetPaperSize;
    property CopyCount: integer read FCopyCount write SetCopyCount;
    property FileName: string read FFileName write SetFileName;
    property Collate: boolean read FCollate write SetCollate;
    property Pages: string read FPages write SetPages;
    property IsBusy: boolean read GetIsBusy;
  end;

  TOOCalcPrinter=class(TOOPrinter)
  private
  public
  end;

  TOOWriterPrinter=class(TOOPrinter)
  private
    function GetLeftMargin: integer;
    procedure SetLeftMargin(const Value: integer);
    function GetRightMargin: integer;
    procedure SetRightMargin(const Value: integer);
    function GetTopMargin: integer;
    procedure SetTopMargin(const Value: integer);
    function GetBottomMargin: integer;
    procedure SetBottomMargin(const Value: integer);
    function GetPageRows: integer;
    procedure SetPageRows(const Value: integer);
    function GetPageColumns: integer;
    procedure SetPageColumns(const Value: integer);
    function GetHoriMargin: integer;
    procedure SetHoriMargin(const Value: integer);
    function GetVertMargin: integer;
    procedure SetVertMargin(const Value: integer);
    function GetLandscape: boolean;
    procedure SetLandscape(const Value: boolean);
  public
    // Multiple Pages on one Page
    procedure PrintPages(Options: TOpenPT);
    // Multiple Pages on one Page
    property LeftMargin: integer read GetLeftMargin write SetLeftMargin;
    property RightMargin: integer read GetRightMargin write SetRightMargin;
    property TopMargin: integer read GetTopMargin write SetTopMargin;
    property BottomMargin: integer read GetBottomMargin write SetBottomMargin;
    property PageRows: integer read GetPageRows write SetPageRows;
    property PageColumns: integer read GetPageColumns write SetPageColumns;
    property HoriMargin: integer read GetHoriMargin write SetHoriMargin;
    property VertMargin: integer read GetVertMargin write SetVertMargin;
    property Landscape: boolean read GetLandscape write SetLandscape;
  end;

  TOpenOffice=class
  private
    FNewName: string;
    FProgType: string;
    FNumberFormats: TOONumberFormats;
    FLocale: TOOGlobalLocale;
{$IFDEF WITH_EVENTS}
    FDocEvent: TListener;
{$ENDIF}
    FDesktop: Variant;
    FDocument: Variant;
{$IFDEF WITH_EVENTS}
    FBeforeSave: TNotifyEvent;
    FAfterSave: TNotifyEvent;
    FBeforeSaveAs: TNotifyEvent;
    FAfterSaveAs: TNotifyEvent;
    FBeforeClose: TNotifyEvent;
    FAfterClose: TNotifyEvent;
    FUnfocus: TNotifyEvent;
    FFocus: TNotifyEvent;
{$ENDIF}
    procedure FreeVariants; virtual;
    function GetConnect: boolean;
    procedure SetConnect(const Value: boolean);
    function GetVisible: boolean;
    procedure SetVisible(const Value: boolean);
    function GetModified: boolean;
    procedure SetModified(const Value: boolean);
    function GetNumberFormats: TOONumberFormats;
    function GetGlobalLocale: TOOGlobalLocale;
    function GetDocLocale: TOpenLocale;
    procedure SetDocLocale(const Value: TOpenLocale);
    function GetCurrentController: Variant;
  protected
    property Document: Variant read FDocument;
{$IFDEF WITH_EVENTS}
    procedure OnBeforeSave;
    procedure OnAfterSave;
    procedure OnBeforeSaveAs;
    procedure OnAfterSaveAs;
    procedure OnBeforeClose;
    procedure OnAfterClose;
    procedure OnUnfocus;
    procedure OnFocus;
{$ENDIF}
  public
    constructor Create;
    destructor Destroy; override;
    procedure OpenDocument(FileName: string; OpenMode: TOpenOM; Macro: TOpenMM); virtual;
    procedure SaveDocument(FileName, FileType: string); virtual; abstract;
    function ConnectTo(FileName: string): boolean;
    procedure ExportToPDF(FileName: string); virtual;
    procedure CloseDocument;
    procedure ShowPreview;
    procedure ClosePreview;
    procedure ExecMacro(MacroName: string);
    property Connect: boolean read GetConnect write SetConnect;
    property Visible: boolean read GetVisible write SetVisible;
    property NumberFormats: TOONumberFormats read GetNumberFormats;
    property Modified: boolean read GetModified write SetModified;
    property GlobalLocale: TOOGlobalLocale read GetGlobalLocale;
    property DocLocale: TOpenLocale read GetDocLocale write SetDocLocale;
    property CurrentController: Variant read GetCurrentController;
{$IFDEF WITH_EVENTS}
    property BeforeSave: TNotifyEvent read FBeforeSave write FBeforeSave;
    property AfterSave: TNotifyEvent read FAfterSave write FAfterSave;
    property BeforeSaveAs: TNotifyEvent read FBeforeSaveAs write FBeforeSaveAs;
    property AfterSaveAs: TNotifyEvent read FAfterSaveAs write FAfterSaveAs;
    property BeforeClose: TNotifyEvent read FBeforeClose write FBeforeClose;
    property AfterClose: TNotifyEvent read FAfterClose write FAfterClose;
    property Unfocus: TNotifyEvent read FUnfocus write FUnfocus;
    property Focus: TNotifyEvent read FFocus write FFocus;
{$ENDIF}
  end;

  TOOBaseCell=class
  private
    FFont: TOOCharProperties;
    FPara: TOOParaProperties;
    FBorder: TOOBorder;
    FCellObj: Variant;
    FIsNewCell: boolean;
    procedure FreeVariants; virtual;
    function GetFont: TOOCharProperties; virtual;
    function GetPara: TOOParaProperties; virtual;
    function GetBorder: TOOBorder;
    function GetFormat: integer;
    procedure SetFormat(const Value: integer);
  protected
    property CellObj: Variant read FCellObj write FCellObj;
    property IsNewCell: boolean read FIsNewCell write FIsNewCell;
  public
    constructor Create;
    destructor Destroy; override;
    property Font: TOOCharProperties read GetFont;
    property Para: TOOParaProperties read GetPara;
    property Border: TOOBorder read GetBorder;
    property Format: integer read GetFormat write SetFormat;
  end;

  TOOCalcBaseCell=class(TOOBaseCell)
  private
    FDocument: Variant;
    FParentSheetObj: Variant;
    procedure FreeVariants; override;
    function GetBackColor: TColor;
    procedure SetBackColor(const Value: TColor);
    function GetBackColorTransparent: boolean;
    procedure SetBackColorTransparent(const Value: boolean);
    procedure SetRotate(const Value: integer);
    procedure SetHoriAlignment(const Value: TOpenHA);
    procedure SetVertAlignment(const Value: TOpenVA);
    procedure SetTextWrap(const Value: boolean);
    function GetMerge: boolean;
    procedure SetMerge(const Value: boolean);
    procedure SetCellName(const Value: string);
    function GetAddress: TOpenRangeAddress;
    function GetRotate: integer;
    function GetHoriAlignment: TOpenHA;
    function GetVertAlignment: TOpenVA;
    function GetTextWrap: boolean;
  protected
    property ParentSheetObj: Variant read FParentSheetObj write FParentSheetObj;
    property Document: Variant read FDocument write FDocument;
  public
    procedure ReplaceAll(SearchString: string; ReplaceString: string; Param: TOpenRP);
    procedure Copy(ToSheet, ToCol, ToRow: integer); overload;
    procedure Copy(ToSheet, ToCol, ToRow: integer; Mode: TOpenIM); overload;
    procedure Move(ToSheet, ToCol, ToRow: integer);
    procedure Insert(Mode: TOpenIM);
    procedure Remove(Mode: TOpenDM);
    property CellName: string write SetCellName;
    property BackColor: TColor read GetBackColor write SetBackColor;
    property BackColorTransparent: boolean read GetBackColorTransparent
      write SetBackColorTransparent;
    property Rotate: integer read GetRotate write SetRotate;
    property HoriAlignment: TOpenHA read GetHoriAlignment write SetHoriAlignment;
    property VertAlignment: TOpenVA read GetVertAlignment write SetVertAlignment;
    property TextWrap: boolean read GetTextWrap write SetTextWrap;
    property Merge: boolean read GetMerge write SetMerge;
    property Address: TOpenRangeAddress read GetAddress;
  end;

  TOOCalcCell=class(TOOCalcBaseCell)
  private
    FTextCursor: TOOBaseTextCursor;
    function GetDataType: TOpenDT;
    function GetAsText: string;
    procedure SetAsText(const Value: string);
    function GetAsDate: TDateTime;
    procedure SetAsDate(const Value: TDateTime);
    function GetAsFormula: string;
    procedure SetAsFormula(const Value: string);
    function GetAsNumber: double;
    procedure SetAsNumber(const Value: double);
    function GetLeft: integer;
    function GetTop: integer;
    function GetWidth: integer;
    function GetHeight: integer;
    function GetTextCursor: TOOBaseTextCursor;
    function GetAnnotation: string;
    procedure SetAnnotation(const Value: string);
  public
    constructor Create;
    destructor Destroy; override;
    function MergedRange(var RangeAddress: TOpenRangeAddress): boolean;
    property DataType: TOpenDT read GetDataType;
    property AsText: string read GetAsText write SetAsText;
    property AsDate: TDateTime read GetAsDate write SetAsDate;
    property AsFormula: string read GetAsFormula write SetAsFormula;
    property AsNumber: double read GetAsNumber write SetAsNumber;
    property Left: integer read GetLeft;
    property Top: integer read GetTop;
    property Width: integer read GetWidth;
    property Height: integer read GetHeight;
    property TextCursor: TOOBaseTextCursor read GetTextCursor;
    property Annotation: string read GetAnnotation write SetAnnotation;
  end;

  TOOCalcCellRange=class(TOOCalcBaseCell)
  private
    FTableBorder: TOOTableBorder;
    procedure FreeVariants; override;
    function GetTableBorder: TOOTableBorder;
    function GetAsArray: Variant;
    procedure SetAsArray(const Value: Variant);
    function GetAsFormulaArray: Variant;
    procedure SetAsFormulaArray(const Value: Variant);
    function GetMaxSortFieldsCount: integer;
  public
    constructor Create;
    destructor Destroy; override;
    procedure SetAsTitleColumns;
    procedure SetAsTitleRows;
    procedure FillSeries(FDirection: TOpenFD; FMode: TOpenFM; FDateMode: TOpenFDM;
      Step, EndValue: double);
    procedure Sort(SortColumns, ContainsHeader: boolean; FieldsArray: TOpenSortFields);
    procedure SortTo(Sheet, Col, Row: integer; SortColumns, BindFormatsToContent,
      ContainsHeader: boolean; FieldsArray: TOpenSortFields);
    procedure Group(Orientation: TOpenTO);
    procedure Ungroup(Orientation: TOpenTO);
    procedure GroupsClear;
    procedure GroupHideDetail;
    procedure GroupShowDetail;
    procedure GroupShowLevel(Level: integer; Orientation: TOpenTO);
    property TableBorder: TOOTableBorder read GetTableBorder;
    // к результату AsArray обращаться Result[Row][Column]
    property AsArray: Variant read GetAsArray write SetAsArray;
    property AsFormulaArray: Variant read GetAsFormulaArray write SetAsFormulaArray;
    property MaxSortFieldsCount: integer read GetMaxSortFieldsCount;
  end;

  TOOWriterBaseCell=class(TOOBaseCell)
  private
    FTTCursor: Variant;
    procedure FreeVariants; override;
    function GetFont: TOOCharProperties; override;
    function GetPara: TOOParaProperties; override;
    function GetBackColor: TColor;
    procedure SetBackColor(const Value: TColor);
    function GetBackColorTransparent: boolean;
    procedure SetBackColorTransparent(const Value: boolean);
    function GetName: string;
    procedure SetVertAlignment(const Value: TOpenFVO);
    function GetVertAlignment: TOpenFVO;
  protected
    property TTCursor: Variant read FTTCursor write FTTCursor;
  public
    function Merge: boolean;
    function Split(Count: integer; Horizontal: boolean): boolean;
    property BackColor: TColor read GetBackColor write SetBackColor;
    property BackColorTransparent: boolean read GetBackColorTransparent
      write SetBackColorTransparent;
    property RangeName: string read GetName;
    property VertAlignment: TOpenFVO read GetVertAlignment write SetVertAlignment;
  end;

  TOOWriterCell=class(TOOWriterBaseCell)
  private
    function GetDataType: TOpenDT;
    function GetAsText: string;
    procedure SetAsText(const Value: string);
    function GetAsDate: TDateTime;
    procedure SetAsDate(const Value: TDateTime);
    function GetAsFormula: string;
    procedure SetAsFormula(const Value: string);
    function GetAsNumber: double;
    procedure SetAsNumber(const Value: double);
  public
    property DataType: TOpenDT read GetDataType;
    property AsText: string read GetAsText write SetAsText;
    property AsDate: TDateTime read GetAsDate write SetAsDate;
    property AsFormula: string read GetAsFormula write SetAsFormula;
    property AsNumber: double read GetAsNumber write SetAsNumber;
  end;

  TOOWriterCellRange=class(TOOWriterBaseCell)
  private
    function GetAsArray: Variant;
    procedure SetAsArray(const Value: Variant);
  public
    // к результату AsArray обращаться Result[Row][Column]
    property AsArray: Variant read GetAsArray write SetAsArray;
  end;

  TOOCalcSheet=class
  private
    FColumns: TOOCalcColumns;
    FRows: TOOCalcRows;
    FCell: TOOCalcCell;
    FCellRange: TOOCalcCellRange;
    FTextShapes: TOOTextShapes;
    FLineShapes: TOOLineShapes;
    FGraphicShapes: TOOGraphicShapes;
    FEllipseShapes: TOOEllipseShapes;
    FRectangleShapes: TOORectangleShapes;
    FMeasureShapes: TOOMeasureShapes;
    FBarCharts: TOOBarCharts;
    FLineCharts: TOOLineCharts;
    FPieCharts: TOOPieCharts;
    FAreaCharts: TOOAreaCharts;
    FSheetObj: Variant;
    FDocument: Variant;
    procedure FreeVariants; virtual;
    function GetName: string;
    procedure SetName(const Value: string);
    function GetPageStyle: string;
    procedure SetPageStyle(const Value: string);
    function GetColumns: TOOCalcColumns;
    function GetRows: TOOCalcRows;
    function GetCell(Col, Row: integer): TOOCalcCell;
    function GetCellByName(CellName: string): TOOCalcCell;
    function GetCellRange(StartCol, StartRow, EndCol, EndRow: integer): TOOCalcCellRange;
    function GetCellRangeByName(CellRangeName: string): TOOCalcCellRange;
    function GetRepeatTitleColumns: boolean;
    procedure SetRepeatTitleColumns(const Value: boolean);
    function GetRepeatTitleRows: boolean;
    procedure SetRepeatTitleRows(const Value: boolean);
    function GetVisible: boolean;
    procedure SetVisible(const Value: boolean);
    function GetSheetIndex: integer;
    function GetUsedArea: TOpenRangeAddress;
    function GetTextShapes: TOOTextShapes;
    function GetLineShapes: TOOLineShapes;
    function GetGraphicShapes: TOOGraphicShapes;
    function GetEllipseShapes: TOOEllipseShapes;
    function GetRectangleShapes: TOORectangleShapes;
    function GetMeasureShapes: TOOMeasureShapes;
    function GetBarCharts: TOOBarCharts;
    function GetLineCharts: TOOLineCharts;
    function GetPieCharts: TOOPieCharts;
    function GetAreaCharts: TOOAreaCharts;
  protected
    property SheetObj: Variant read FSheetObj write FSheetObj;
    property Document: Variant read FDocument write FDocument;
  public
    constructor Create;
    destructor Destroy; override;
    procedure ReplaceAll(SearchString: string; ReplaceString: string; Param: TOpenRP);
    procedure Copy(NewSheetName: string; Index: integer);
    property Name: string read GetName write SetName;
    property PageStyle: string read GetPageStyle write SetPageStyle;
    property Columns: TOOCalcColumns read GetColumns;
    property Rows: TOOCalcRows read GetRows;
    property Cell[Col, Row: integer]: TOOCalcCell read GetCell;
    property CellByName[CellName: string]: TOOCalcCell read GetCellByName;
    property CellRange[StartCol, StartRow, EndCol, EndRow: integer]: TOOCalcCellRange
      read GetCellRange;
    property CellRangeByName[CellName: string]: TOOCalcCellRange read GetCellRangeByName;
    property RepeatTitleColumns: boolean read GetRepeatTitleColumns write SetRepeatTitleColumns;
    property RepeatTitleRows: boolean read GetRepeatTitleRows write SetRepeatTitleRows;
    property Visible: boolean read GetVisible write SetVisible;
    property SheetIndex: integer read GetSheetIndex;
    property UsedArea: TOpenRangeAddress read GetUsedArea;
    property TextShapes: TOOTextShapes read GetTextShapes;
    property LineShapes: TOOLineShapes read GetLineShapes;
    property GraphicShapes: TOOGraphicShapes read GetGraphicShapes;
    property EllipseShapes: TOOEllipseShapes read GetEllipseShapes;
    property RectangleShapes: TOORectangleShapes read GetRectangleShapes;
    property MeasureShapes: TOOMeasureShapes read GetMeasureShapes;
    property BarCharts: TOOBarCharts read GetBarCharts;
    property LineCharts: TOOLineCharts read GetLineCharts;
    property PieCharts: TOOPieCharts read GetPieCharts;
    property AreaCharts: TOOAreaCharts read GetAreaCharts;
  end;

  TOOCalcSheets=class
  private
    FSheet: TOOCalcSheet;
    FDocument: Variant;
    procedure FreeVariants; virtual;
    function GetCount: integer;
    function GetSheet(Index: integer): TOOCalcSheet;
    function GetActiveIndex: integer;
    procedure SetActiveIndex(const Value: integer);
    function GetActiveName: string;
    procedure SetActiveName(const Value: string);
    function GetActiveSheet: TOOCalcSheet;
  protected
    property Document: Variant read FDocument write FDocument;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Insert(NewSheetName: string; NewSheetIndex: integer; SetActive: boolean);
    procedure DeleteByIndex(Index: integer);
    procedure DeleteByName(Name: string);
    function IsExist(SheetName: string): boolean;
    property Count: integer read GetCount;
    property Items[Index: integer]: TOOCalcSheet read GetSheet; default;
    property Active: TOOCalcSheet read GetActiveSheet;
    property ActiveByIndex: integer read GetActiveIndex write SetActiveIndex;
    property ActiveByName: string read GetActiveName write SetActiveName;
  end;

  TOOCalcRowCol=class
  private
    FRowColObj: Variant;
    procedure FreeVariants; virtual;
    function GetIsVisible: boolean;
    procedure SetIsVisible(const Value: boolean);
    function GetIsStartOfNewPage: boolean;
    procedure SetIsStartOfNewPage(const Value: boolean);
  protected
    property RowColObj: Variant read FRowColObj write FRowColObj;
  public
    property IsVisible: boolean read GetIsVisible write SetIsVisible;
    property IsStartOfNewPage: boolean read GetIsStartOfNewPage write SetIsStartOfNewPage;
  end;

  TOOCalcColumn=class(TOOCalcRowCol)
  private
    function GetWidth: integer;
    procedure SetWidth(const Value: integer);
    function GetOptimalWidth: boolean;
    procedure SetOptimalWidth(const Value: boolean);
  public
    property Width: integer read GetWidth write SetWidth;
    property OptimalWidth: boolean read GetOptimalWidth write SetOptimalWidth;
  end;

  TOOCalcColumns=class
  private
    FColumn: TOOCalcColumn;
    FParentSheetObj: Variant;
    procedure FreeVariants; virtual;
    function GetColumn(Index: integer): TOOCalcColumn;
  protected
    property ParentSheetObj: Variant read FParentSheetObj write FParentSheetObj;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Insert(Index, Count: integer);
    procedure Delete(Index, Count: integer);
    property Items[Index: integer]: TOOCalcColumn read GetColumn; default;
  end;

  TOOCalcRow=class(TOOCalcRowCol)
  private
    function GetHeight: integer;
    procedure SetHeight(const Value: integer);
    function GetOptimalHeight: boolean;
    procedure SetOptimalHeight(const Value: boolean);
  public
    property Height: integer read GetHeight write SetHeight;
    property OptimalHeight: boolean read GetOptimalHeight write SetOptimalHeight;
  end;

  TOOCalcRows=class
  private
    FRow: TOOCalcRow;
    FParentSheetObj: Variant;
    procedure FreeVariants; virtual;
    function GetRow(Index: integer): TOOCalcRow;
  protected
    property ParentSheetObj: Variant read FParentSheetObj write FParentSheetObj;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Insert(Index, Count: integer);
    procedure Delete(Index, Count: integer);
    property Items[Index: integer]: TOOCalcRow read GetRow; default;
  end;

  TOOCalc=class(TOpenOffice)
  private
    FCell: TOOCalcCell;
    FSheets: TOOCalcSheets;
    FScreenUpdating: boolean;
    FPageStyles: TOOCalcPageStyles;
    FPrinter: TOOCalcPrinter;
    procedure FreeVariants; override;
    procedure SetScreenUpdating(Value: boolean);
    function GetSheets: TOOCalcSheets;
    function GetPrinter: TOOCalcPrinter;
    function GetPageStyles: TOOCalcPageStyles;
    function GetExpandReferences: boolean;
    procedure SetExpandReferences(const Value: boolean);
    function GetExtendFormat: boolean;
    procedure SetExtendFormat(const Value: boolean);
  public
    constructor Create;
    destructor Destroy; override;
    procedure SaveDocument(FileName, FileType: string); override;
    procedure ReplaceAll(SearchString: string; ReplaceString: string; Param: TOpenRP);
    function HasFreezeAtCurrentSheet: boolean;
    procedure FreezeAtCurrentSheet(Cols, Rows: integer);
    property ScreenUpdating: boolean read FScreenUpdating write SetScreenUpdating;
    property Sheets: TOOCalcSheets read GetSheets;
    property PageStyles: TOOCalcPageStyles read GetPageStyles;
    property Printer: TOOCalcPrinter read GetPrinter;
    property ExpandReferences: boolean read GetExpandReferences write SetExpandReferences;
    property ExtendFormat: boolean read GetExtendFormat write SetExtendFormat;
  end;

  TOOWriterTableRow=class
  private
    FRowObj: Variant;
    procedure FreeVariants; virtual;
    function GetBackColor: TColor;
    procedure SetBackColor(const Value: TColor);
    function GetBackColorTransparent: boolean;
    procedure SetBackColorTransparent(const Value: boolean);
    function GetHeight: integer;
    procedure SetHeight(const Value: integer);
    function GetAutoHeight: boolean;
    procedure SetAutoHeight(const Value: boolean);
    function GetSeparator(Num: integer): integer;
    procedure SetSeparator(Num: integer; const Value: integer);
  protected
    property RowObj: Variant read FRowObj write FRowObj;
  public
    property BackColor: TColor read GetBackColor write SetBackColor;
    property BackColorTransparent: boolean read GetBackColorTransparent
      write SetBackColorTransparent;
    property Height: integer read GetHeight write SetHeight;
    property AutoHeight: boolean read GetAutoHeight write SetAutoHeight;
    property Separator[Num: integer]: integer read GetSeparator write SetSeparator;
  end;

  TOOWriterTableRows=class
  private
    FParentTableObj: Variant;
    FRow: TOOWriterTableRow;
    procedure FreeVariants; virtual;
    function GetCount: integer;
    function GetRow(Index: integer): TOOWriterTableRow;
  protected
    property ParentTableObj: Variant read FParentTableObj write FParentTableObj;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Append(Count: integer);
    procedure Insert(Index, Count: integer);
    procedure Delete(Index, Count: integer);
    property Count: integer read GetCount;
    property Items[Index: integer]: TOOWriterTableRow read GetRow; default;
  end;

  TOOWriterTableColumns=class
  private
    FParentTableObj: Variant;
    procedure FreeVariants; virtual;
    function GetCount: integer;
  protected
    property ParentTableObj: Variant read FParentTableObj write FParentTableObj;
  public
    procedure Append(Count: integer);
    procedure Insert(Index, Count: integer);
    procedure Delete(Index, Count: integer);
    property Count: integer read GetCount;
  end;

  TOOTable=class
  private
    FRows: TOOWriterTableRows;
    FColumns: TOOWriterTableColumns;
    FCell: TOOWriterCell;
    FCellRange: TOOWriterCellRange;
    FTableObj: Variant;
    FTableBorder: TOOTableBorder;
    FTextTableCursor: TOOTextTableCursor;
    FMargin: TOOMargin;
    FOldName: string;
    procedure FreeVariants; virtual;
    function GetName: string;
    procedure SetName(const Value: string);
    function GetRepeatHeadline: boolean;
    procedure SetRepeatHeadline(const Value: boolean);
    function GetRows: TOOWriterTableRows;
    function GetColumns: TOOWriterTableColumns;
    function GetBackColor: TColor;
    procedure SetBackColor(const Value: TColor);
    function GetBackColorTransparent: boolean;
    procedure SetBackColorTransparent(const Value: boolean);
    function GetCell(Col, Row: integer): TOOWriterCell;
    function GetCellByName(CellName: string): TOOWriterCell;
    function GetCellRange(StartCol, StartRow, EndCol, EndRow: integer): TOOWriterCellRange;
    function GetCellRangeByName(CellRange: string): TOOWriterCellRange;
    function GetSeparator(Num: integer): integer;
    procedure SetSeparator(Num: integer; const Value: integer);
    function GetShadowFormat: TOpenShadowFormat;
    procedure SetShadowFormat(const Value: TOpenShadowFormat);
    function GetTableBorder: TOOTableBorder;
    function GetTextTableCursor: TOOTextTableCursor;
    function GetMargin: TOOMargin;
    function GetBreakType: TOpenBT;
    procedure SetBreakType(const Value: TOpenBT);
    function GetHoriOrient: TOpenFHO;
    procedure SetHoriOrient(const Value: TOpenFHO);
    function GetKeepTogether: boolean;
    procedure SetKeepTogether(const Value: boolean);
    function GetSplit: boolean;
    procedure SetSplit(const Value: boolean);
    function GetPageNumberOffset: integer;
    procedure SetPageNumberOffset(const Value: integer);
    function GetPageDescName: string;
    procedure SetPageDescName(const Value: string);
    function GetHeaderRowCount: integer;
    procedure SetHeaderRowCount(const Value: integer);
    function GetWidth: integer;
    procedure SetWidth(const Value: integer);
    function GetRelativeWidth: integer;
    procedure SetRelativeWidth(const Value: integer);
    function GetIsWidthRelative: boolean;
    procedure SetIsWidthRelative(const Value: boolean);
  protected
    property TableObj: Variant read FTableObj write FTableObj;
  public
    constructor Create;
    destructor Destroy; override;
    property Name: string read GetName write SetName;
    property Margin: TOOMargin read GetMargin;
    property RepeatHeadline: boolean read GetRepeatHeadline write SetRepeatHeadline;
    property Rows: TOOWriterTableRows read GetRows;
    property Columns: TOOWriterTableColumns read GetColumns;
    property Cell[Col, Row: integer]: TOOWriterCell read GetCell;
    property CellByName[CellName: string]: TOOWriterCell read GetCellByName;
    property CellRange[StartCol, StartRow, EndCol, EndRow: integer]: TOOWriterCellRange
      read GetCellRange;
    property CellRangeByName[CellRange: string]: TOOWriterCellRange read GetCellRangeByName;
    property BackColor: TColor read GetBackColor write SetBackColor;
    property BackColorTransparent: boolean read GetBackColorTransparent
      write SetBackColorTransparent;
    property Separator[Num: integer]: integer read GetSeparator write SetSeparator;
    property ShadowFormat: TOpenShadowFormat read GetShadowFormat write SetShadowFormat;
    property TableBorder: TOOTableBorder read GetTableBorder;
    property TextTableCursor: TOOTextTableCursor read GetTextTableCursor;
    property BreakType: TOpenBT read GetBreakType write SetBreakType;
    property HoriOrient: TOpenFHO read GetHoriOrient write SetHoriOrient;
    property KeepTogether: boolean read GetKeepTogether write SetKeepTogether;
    property Split: boolean read GetSplit write SetSplit;
    property PageNumberOffset: integer read GetPageNumberOffset write SetPageNumberOffset;
    property PageDescName: string read GetPageDescName write SetPageDescName;
    property HeaderRowCount: integer read GetHeaderRowCount write SetHeaderRowCount;
    property Width: integer read GetWidth write SetWidth;
    property RelativeWidth: integer read GetRelativeWidth write SetRelativeWidth;
    property IsWidthRelative: boolean read GetIsWidthRelative write SetIsWidthRelative;
  end;

  TOOTables=class
  private
    FDocument: Variant;
    FTable: TOOTable;
    procedure FreeVariants; virtual;
    function GetTable(Index: integer): TOOTable;
    function GetTableByName(TableName: string): TOOTable;
    function GetCount: integer;
    function GetCurrent: TOOTable;
  protected
    property Document: Variant read FDocument write FDocument;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Insert(Cols, Rows: integer; TableName: string; Cursor: TOOTextCursor);
    function IsExist(TableName: string): boolean;
    procedure DeleteByIndex(Index: integer);
    procedure DeleteByName(TableName: string);
    property Items[Index: integer]: TOOTable read GetTable; default;
    property ItemsByName[TableName: string]: TOOTable read GetTableByName;
    property Count: integer read GetCount;
    property Current: TOOTable read GetCurrent;
  end;

  TOOBaseCursor=class
  private
    FDocument: Variant;
    FCursorType: TOpenCT;
    FFont: TOOCharProperties;
    FPara: TOOParaProperties;
    FCursorObj: Variant;
    FOnFontChange: TNotifyEvent;
    FOnParaChange: TNotifyEvent;
    procedure FreeVariants; virtual;
    function GetFont: TOOCharProperties;
    function GetPara: TOOParaProperties;
  protected
    procedure DoFontChange(Sender: TObject);
    procedure DoParaChange(Sender: TObject);
    property OnFontChange: TNotifyEvent read FOnFontChange write FOnFontChange;
    property OnParaChange: TNotifyEvent read FOnFontChange write FOnFontChange;
    property Document: Variant read FDocument write FDocument;
    property CursorObj: Variant read FCursorObj write FCursorObj;
  public
    constructor Create;
    destructor Destroy; override;
    function GoLeft(Count: integer; Expand: boolean): boolean;
    function GoRight(Count: integer; Expand: boolean): boolean;
    function GoUp(Count: integer; Expand: boolean): boolean;
    function GoDown(Count: integer; Expand: boolean): boolean;
    procedure GotoStart(Expand: boolean);
    procedure GotoEnd(Expand: boolean); virtual;
    property Font: TOOCharProperties read GetFont;
    property Para: TOOParaProperties read GetPara;
    property CursorType: TOpenCT read FCursorType;
  end;

  TOOBaseTextCursor=class(TOOBaseCursor)
  private
    FOnTextChange: TNotifyEvent;
    function GetText: string;
    procedure SetText(const Value: string);
  protected
    property OnTextChange: TNotifyEvent read FOnTextChange write FOnTextChange;
  public
    constructor Create;
    procedure GotoEnd(Expand: boolean); override;
    procedure CollapseToStart;
    procedure CollapseToEnd;
    function IsCollapsed: boolean;
    property Text: string read GetText write SetText;
  end;

  TOOTextTableCursor=class(TOOBaseCursor)
  private
    function GetRangeName: string;
  public
    function GotoCellByName(CellName: string; Expand: boolean): boolean;
    function MergeRange: boolean;
    function SplitRange(Count: integer; Horizontal: boolean): boolean;
    property RangeName: string read GetRangeName;
  end;

  TOOTextCursor=class(TOOBaseTextCursor)
  private
    function GetBreakType: TOpenBT;
    procedure SetBreakType(const Value: TOpenBT);
  public
    constructor Create;
    procedure InsertDateTime(IsFixed, IsDate: boolean; Format, Adjust: integer);
    procedure InsertPageNumber;
    procedure InsertPageCount;
    property BreakType: TOpenBT read GetBreakType write SetBreakType;
  end;

  TOOModelCursor=class(TOOTextCursor)
  protected
    FWriterHFType: TOpenWH; // тип курсора для header и footer
    procedure Sync(V: Variant);
  public
    constructor Create;
    procedure SyncFrom(Cursor: TOOViewCursor);

    function GotoNextWord(Expand: boolean): boolean;
    function GotoPreviousWord(Expand: boolean): boolean;
    function GotoStartOfWord(Expand: boolean): boolean;
    function GotoEndOfWord(Expand: boolean): boolean;
    function IsStartOfWord: boolean;
    function IsEndOfWord: boolean;

    function GotoNextSentence(Expand: boolean): boolean;
    function GotoPreviousSentence(Expand: boolean): boolean;
    function GotoStartOfSentence(Expand: boolean): boolean;
    function GotoEndOfSentence(Expand: boolean): boolean;
    function IsStartOfSentence: boolean;
    function IsEndOfSentence: boolean;

    function GotoNextParagraph(Expand: boolean): boolean;
    function GotoPreviousParagraph(Expand: boolean): boolean;
    function GotoStartOfParagraph(Expand: boolean): boolean;
    function GotoEndOfParagraph(Expand: boolean): boolean;
    function IsStartOfParagraph: boolean;
    function IsEndOfParagraph: boolean;
  end;

  TOOViewCursor=class(TOOTextCursor)
  private
    function GetTable: Variant;
    function GetPageNumber: integer;
    function GetPageStyleName: string;
    procedure SetPageStyleName(const Value: string);
    function GetCell: Variant;
  public
    procedure SyncFrom(Cursor: TOOModelCursor);

    function JumpToPage(PageNumber: integer): boolean;
    function JumpToFirstPage: boolean;
    function JumpToLastPage: boolean;
    function JumpToNextPage: boolean;
    function JumpToPreviousPage: boolean;
    function JumpToStartOfPage: boolean;
    function JumpToEndOfPage: boolean;

    procedure GotoStartOfLine(Expand: boolean);
    procedure GotoEndOfLine(Expand: boolean);
    function IsAtStartOfLine: boolean;
    function IsAtEndOfLine: boolean;

    property PageStyleName: string read GetPageStyleName write SetPageStyleName;
    property PageNumber: integer read GetPageNumber;
    property CurrentTable: Variant read GetTable;
    property CurrentCell: Variant read GetCell;
  end;

  TOOPageStyle=class
  private
    FDocument: Variant;
    FStyleObj: Variant;
    FBorder: TOOHeaderBorderDistance;
    FMargin: TOOMargin;
    procedure FreeVariants; virtual;
    function GetName: string;
    procedure SetName(const Value: string);
    function GetIsUserDefined: boolean;
    function GetIsInUse: boolean;
    function GetWidth: integer;
    procedure SetWidth(const Value: integer);
    function GetHeight: integer;
    procedure SetHeight(const Value: integer);
    function GetLandscape: boolean;
    procedure SetLandscape(const Value: boolean);
    function GetBackColor: TColor;
    procedure SetBackColor(const Value: TColor);
    function GetBackColorTransparent: boolean;
    procedure SetBackColorTransparent(const Value: boolean);
    function GetPageStyleLayout: TOpenPL;
    procedure SetPageStyleLayout(const Value: TOpenPL);
    function GetDistance: integer;
    procedure SetDistance(const Value: integer);
    function GetSize: TOpenSize;
    procedure SetSize(const Value: TOpenSize);
    function GetShadowFormat: TOpenShadowFormat;
    procedure SetShadowFormat(const Value: TOpenShadowFormat);

    function GetHeaderBackColor: TColor;
    procedure SetHeaderBackColor(const Value: TColor);
    function GetHeaderBackColorTransparent: boolean;
    procedure SetHeaderBackColorTransparent(const Value: boolean);
    function GetHeaderLeftMargin: integer;
    procedure SetHeaderLeftMargin(const Value: integer);
    function GetHeaderRightMargin: integer;
    procedure SetHeaderRightMargin(const Value: integer);
    function GetHeaderLeftBorder: TOpenBorderLine;
    procedure SetHeaderLeftBorder(const Value: TOpenBorderLine);
    function GetHeaderRightBorder: TOpenBorderLine;
    procedure SetHeaderRightBorder(const Value: TOpenBorderLine);
    function GetHeaderTopBorder: TOpenBorderLine;
    procedure SetHeaderTopBorder(const Value: TOpenBorderLine);
    function GetHeaderBottomBorder: TOpenBorderLine;
    procedure SetHeaderBottomBorder(const Value: TOpenBorderLine);
    function GetHeaderLeftDistance: integer;
    procedure SetHeaderLeftDistance(const Value: integer);
    function GetHeaderRightDistance: integer;
    procedure SetHeaderRightDistance(const Value: integer);
    function GetHeaderTopDistance: integer;
    procedure SetHeaderTopDistance(const Value: integer);
    function GetHeaderBottomDistance: integer;
    procedure SetHeaderBottomDistance(const Value: integer);
    function GetHeaderDistance: integer;
    procedure SetHeaderDistance(const Value: integer);
    function GetHeaderBodyDistance: integer;
    procedure SetHeaderBodyDistance(const Value: integer);
    function GetHeaderShadowFormat: TOpenShadowFormat;
    procedure SetHeaderShadowFormat(const Value: TOpenShadowFormat);
    function GetHeaderHeight: integer;
    procedure SetHeaderHeight(const Value: integer);
    function GetHeaderIsDynamicHeight: boolean;
    procedure SetHeaderIsDynamicHeight(const Value: boolean);
    function GetHeaderIsShared: boolean;
    procedure SetHeaderIsShared(const Value: boolean);
    function GetHeaderIsOn: boolean;
    procedure SetHeaderIsOn(const Value: boolean);

    function GetFooterBackColor: TColor;
    procedure SetFooterBackColor(const Value: TColor);
    function GetFooterBackColorTransparent: boolean;
    procedure SetFooterBackColorTransparent(const Value: boolean);
    function GetFooterLeftMargin: integer;
    procedure SetFooterLeftMargin(const Value: integer);
    function GetFooterRightMargin: integer;
    procedure SetFooterRightMargin(const Value: integer);
    function GetFooterLeftBorder: TOpenBorderLine;
    procedure SetFooterLeftBorder(const Value: TOpenBorderLine);
    function GetFooterRightBorder: TOpenBorderLine;
    procedure SetFooterRightBorder(const Value: TOpenBorderLine);
    function GetFooterTopBorder: TOpenBorderLine;
    procedure SetFooterTopBorder(const Value: TOpenBorderLine);
    function GetFooterBottomBorder: TOpenBorderLine;
    procedure SetFooterBottomBorder(const Value: TOpenBorderLine);
    function GetFooterLeftDistance: integer;
    procedure SetFooterLeftDistance(const Value: integer);
    function GetFooterRightDistance: integer;
    procedure SetFooterRightDistance(const Value: integer);
    function GetFooterTopDistance: integer;
    procedure SetFooterTopDistance(const Value: integer);
    function GetFooterBottomDistance: integer;
    procedure SetFooterBottomDistance(const Value: integer);
    function GetFooterDistance: integer;
    procedure SetFooterDistance(const Value: integer);
    function GetFooterBodyDistance: integer;
    procedure SetFooterBodyDistance(const Value: integer);
    function GetFooterShadowFormat: TOpenShadowFormat;
    procedure SetFooterShadowFormat(const Value: TOpenShadowFormat);
    function GetFooterHeight: integer;
    procedure SetFooterHeight(const Value: integer);
    function GetFooterIsDynamicHeight: boolean;
    procedure SetFooterIsDynamicHeight(const Value: boolean);
    function GetFooterIsShared: boolean;
    procedure SetFooterIsShared(const Value: boolean);
    function GetFooterIsOn: boolean;
    procedure SetFooterIsOn(const Value: boolean);
    function GetBorder: TOOHeaderBorderDistance;
    function GetMargin: TOOMargin;
  protected
    property Document: Variant read FDocument write FDocument;
    property StyleObj: Variant read FStyleObj write FStyleObj;
  public
    constructor Create;
    destructor Destroy; override;
    property Name: string read GetName write SetName;
    property IsUserDefined: boolean read GetIsUserDefined;
    property IsInUse: boolean read GetIsInUse;
    property Margin: TOOMargin read GetMargin;
    property Size: TOpenSize read GetSize write SetSize;
    property Width: integer read GetWidth write SetWidth;
    property Height: integer read GetHeight write SetHeight;
    property Landscape: boolean read GetLandscape write SetLandscape;

    property BackColor: TColor read GetBackColor write SetBackColor;
    property BackColorTransparent: boolean read GetBackColorTransparent
      write SetBackColorTransparent;
    property PageStyleLayout: TOpenPL read GetPageStyleLayout write SetPageStyleLayout;
    property Border: TOOHeaderBorderDistance read GetBorder;
    property Distance: integer read GetDistance write SetDistance;
    property ShadowFormat: TOpenShadowFormat read GetShadowFormat write SetShadowFormat;

    property HeaderBackColor: TColor read GetHeaderBackColor write SetHeaderBackColor;
    property HeaderBackColorTransparent: boolean read GetHeaderBackColorTransparent
      write SetHeaderBackColorTransparent;
    property HeaderLeftMargin: integer read GetHeaderLeftMargin write SetHeaderLeftMargin;
    property HeaderRightMargin: integer read GetHeaderRightMargin write SetHeaderRightMargin;
    property HeaderLeftBorder: TOpenBorderLine read GetHeaderLeftBorder write SetHeaderLeftBorder;
    property HeaderRightBorder: TOpenBorderLine read GetHeaderRightBorder
      write SetHeaderRightBorder;
    property HeaderTopBorder: TOpenBorderLine read GetHeaderTopBorder write SetHeaderTopBorder;
    property HeaderBottomBorder: TOpenBorderLine read GetHeaderBottomBorder
      write SetHeaderBottomBorder;
    property HeaderLeftDistance: integer read GetHeaderLeftDistance write SetHeaderLeftDistance;
    property HeaderRightDistance: integer read GetHeaderRightDistance write SetHeaderRightDistance;
    property HeaderTopDistance: integer read GetHeaderTopDistance write SetHeaderTopDistance;
    property HeaderBottomDistance: integer read GetHeaderBottomDistance
      write SetHeaderBottomDistance;
    property HeaderDistance: integer read GetHeaderDistance write SetHeaderDistance;
    property HeaderBodyDistance: integer read GetHeaderBodyDistance write SetHeaderBodyDistance;
    property HeaderShadowFormat: TOpenShadowFormat read GetHeaderShadowFormat
      write SetHeaderShadowFormat;
    property HeaderHeight: integer read GetHeaderHeight write SetHeaderHeight;
    property HeaderIsDynamicHeight: boolean read GetHeaderIsDynamicHeight
      write SetHeaderIsDynamicHeight;
    property HeaderIsShared: boolean read GetHeaderIsShared write SetHeaderIsShared;
    property HeaderIsOn: boolean read GetHeaderIsOn write SetHeaderIsOn;

    property FooterBackColor: TColor read GetFooterBackColor write SetFooterBackColor;
    property FooterBackColorTransparent: boolean read GetFooterBackColorTransparent
      write SetFooterBackColorTransparent;
    property FooterLeftMargin: integer read GetFooterLeftMargin write SetFooterLeftMargin;
    property FooterRightMargin: integer read GetFooterRightMargin write SetFooterRightMargin;
    property FooterLeftBorder: TOpenBorderLine read GetFooterLeftBorder write SetFooterLeftBorder;
    property FooterRightBorder: TOpenBorderLine read GetFooterRightBorder
      write SetFooterRightBorder;
    property FooterTopBorder: TOpenBorderLine read GetFooterTopBorder write SetFooterTopBorder;
    property FooterBottomBorder: TOpenBorderLine read GetFooterBottomBorder
      write SetFooterBottomBorder;
    property FooterLeftDistance: integer read GetFooterLeftDistance write SetFooterLeftDistance;
    property FooterRightDistance: integer read GetFooterRightDistance write SetFooterRightDistance;
    property FooterTopDistance: integer read GetFooterTopDistance write SetFooterTopDistance;
    property FooterBottomDistance: integer read GetFooterBottomDistance
      write SetFooterBottomDistance;
    property FooterDistance: integer read GetFooterDistance write SetFooterDistance;
    property FooterBodyDistance: integer read GetFooterBodyDistance write SetFooterBodyDistance;
    property FooterShadowFormat: TOpenShadowFormat read GetFooterShadowFormat
      write SetFooterShadowFormat;
    property FooterHeight: integer read GetFooterHeight write SetFooterHeight;
    property FooterIsDynamicHeight: boolean read GetFooterIsDynamicHeight
      write SetFooterIsDynamicHeight;
    property FooterIsShared: boolean read GetFooterIsShared write SetFooterIsShared;
    property FooterIsOn: boolean read GetFooterIsOn write SetFooterIsOn;
  end;

  TOOCalcPageStyle=class(TOOPageStyle)
  private
    FModelCursor: TOOModelCursor;
    FOldCursorType: TOpenCH;
    FOldContent: Variant;
    procedure FreeVariants; override;
    function GetPageScale: integer;
    procedure SetPageScale(const Value: integer);
    function GetScaleToPages: integer;
    procedure SetScaleToPages(const Value: integer);
    function GetFirstPageNumber: integer;
    procedure SetFirstPageNumber(const Value: integer);
    function GetCenterHorizontally: boolean;
    procedure SetCenterHorizontally(const Value: boolean);
    function GetCenterVertically: boolean;
    procedure SetCenterVertically(const Value: boolean);
    function GetPrintAnnotations: boolean;
    procedure SetPrintAnnotations(const Value: boolean);
    function GetPrintGrid: boolean;
    procedure SetPrintGrid(const Value: boolean);
    function GetPrintHeaders: boolean;
    procedure SetPrintHeaders(const Value: boolean);
    function GetPrintCharts: boolean;
    procedure SetPrintCharts(const Value: boolean);
    function GetPrintObjects: boolean;
    procedure SetPrintObjects(const Value: boolean);
    function GetPrintDrawing: boolean;
    procedure SetPrintDrawing(const Value: boolean);
    function GetPrintFormulas: boolean;
    procedure SetPrintFormulas(const Value: boolean);
    function GetPrintZeroValues: boolean;
    procedure SetPrintZeroValues(const Value: boolean);
    function GetPrintDownFirst: boolean;
    procedure SetPrintDownFirst(const Value: boolean);
    function GetScaleToPagesX: integer;
    procedure SetScaleToPagesX(const Value: integer);
    function GetScaleToPagesY: integer;
    procedure SetScaleToPagesY(const Value: integer);
    function GetModelCursor(CursorType: TOpenCH): TOOModelCursor;
    procedure DoTextChange(Sender: TObject);
  public
    constructor Create;
    destructor Destroy; override;
    property PageScale: integer read GetPageScale write SetPageScale;
    property ScaleToPages: integer read GetScaleToPages write SetScaleToPages;
    property ScaleToPagesX: integer read GetScaleToPagesX write SetScaleToPagesX;
    property ScaleToPagesY: integer read GetScaleToPagesY write SetScaleToPagesY;
    property FirstPageNumber: integer read GetFirstPageNumber write SetFirstPageNumber;
    property CenterHorizontally: boolean read GetCenterHorizontally write SetCenterHorizontally;
    property CenterVertically: boolean read GetCenterVertically write SetCenterVertically;
    property PrintAnnotations: boolean read GetPrintAnnotations write SetPrintAnnotations;
    property PrintGrid: boolean read GetPrintGrid write SetPrintGrid;
    property PrintHeaders: boolean read GetPrintHeaders write SetPrintHeaders;
    property PrintCharts: boolean read GetPrintCharts write SetPrintCharts;
    property PrintObjects: boolean read GetPrintObjects write SetPrintObjects;
    property PrintDrawing: boolean read GetPrintDrawing write SetPrintDrawing;
    property PrintFormulas: boolean read GetPrintFormulas write SetPrintFormulas;
    property PrintZeroValues: boolean read GetPrintZeroValues write SetPrintZeroValues;
    property PrintDownFirst: boolean read GetPrintDownFirst write SetPrintDownFirst;
    property ModelCursor[CursorType: TOpenCH]: TOOModelCursor read GetModelCursor;
  end;

  TOOWriterPageStyle=class(TOOPageStyle)
  private
    FModelCursor: TOOModelCursor;
    FOldCursorType: TOpenWH;
    procedure FreeVariants; override;
    function GetModelCursor(CursorType: TOpenWH): TOOModelCursor;
  public
    constructor Create;
    destructor Destroy; override;
    property ModelCursor[CursorType: TOpenWH]: TOOModelCursor read GetModelCursor;
  end;

  TOOPageStyles=class
  private
    FDocument: Variant;
    procedure FreeVariants; virtual;
    function GetCount: integer;
  protected
    property Document: Variant read FDocument write FDocument;
  public
    procedure Append(StyleName: string);
    procedure DeleteByName(StyleName: string);
    procedure DeleteByIndex(Index: integer);
    property Count: integer read GetCount;
  end;

  TOOCalcPageStyles=class(TOOPageStyles)
  private
    FStyle: TOOCalcPageStyle;
    procedure FreeVariants; override;
    function GetPageStyle(Index: integer): TOOCalcPageStyle;
    function GetPageStyleByName(StyleName: string): TOOCalcPageStyle;
  public
    constructor Create;
    destructor Destroy; override;
    property Items[Index: integer]: TOOCalcPageStyle read GetPageStyle; default;
    property ItemsByName[StyleName: string]: TOOCalcPageStyle read GetPageStyleByName;
  end;

  TOOWriterPageStyles=class(TOOPageStyles)
  private
    FStyle: TOOWriterPageStyle;
    procedure FreeVariants; override;
    function GetPageStyle(Index: integer): TOOWriterPageStyle;
    function GetPageStyleByName(StyleName: string): TOOWriterPageStyle;
  public
    constructor Create;
    destructor Destroy; override;
    property Items[Index: integer]: TOOWriterPageStyle read GetPageStyle; default;
    property ItemsByName[StyleName: string]: TOOWriterPageStyle read GetPageStyleByName;
  end;

  TOOBookmark=class
  private
    FDocument: Variant;
    FBookmarkObj: Variant;
    procedure FreeVariants; virtual;
    function GetName: string;
    procedure SetName(const Value: string);
  protected
    property Document: Variant read FDocument write FDocument;
    property BookmarkObj: Variant read FBookmarkObj write FBookmarkObj;
  public
    procedure SetCursorPosition(Cursor: TOOTextCursor);
    property Name: string read GetName write SetName;
  end;

  TOOBookmarks=class
  private
    FDocument: Variant;
    FBookmark: TOOBookmark;
    procedure FreeVariants; virtual;
    function GetCount: integer;
    function GetBookmark(Index: integer): TOOBookmark;
    function GetBookmarkByName(BookmarkName: string): TOOBookmark;
  protected
    property Document: Variant read FDocument write FDocument;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Append(BookmarkName: string; Cursor: TOOTextCursor);
    function IsExist(BookmarkName: string): boolean;
    procedure DeleteByIndex(Index: integer);
    procedure DeleteByName(BookmarkName: string);
    procedure DeleteAll;
    property Count: integer read GetCount;
    property Items[Index: integer]: TOOBookmark read GetBookmark; default;
    property ItemsByName[BookmarkName: string]: TOOBookmark read GetBookmarkByName;
  end;

  TOOBaseFrame=class
  private
    FDocument: Variant;
    FMargin: TOOMargin;
    FFrameObj: Variant;
    FBorder: TOOBorder;
    procedure FreeVariants; virtual;
    function GetName: string;
    procedure SetName(const Value: string); virtual;
    function GetWidth: integer;
    procedure SetWidth(const Value: integer);
    function GetHeight: integer;
    procedure SetHeight(const Value: integer);
    function GetRelativeWidth: integer;
    procedure SetRelativeWidth(const Value: integer);
    function GetRelativeHeight: integer;
    procedure SetRelativeHeight(const Value: integer);
    function GetBackColor: TColor;
    function GetBackColorTransparent: boolean;
    procedure SetBackColor(const Value: TColor);
    procedure SetBackColorTransparent(const Value: boolean);
    function GetDistance: integer;
    procedure SetDistance(const Value: integer);
    function GetContentProtected: boolean;
    procedure SetContentProtected(const Value: boolean);
    function GetPositionProtected: boolean;
    procedure SetPositionProtected(const Value: boolean);
    function GetSizeProtected: boolean;
    procedure SetSizeProtected(const Value: boolean);
    function GetSyncWidthToHeight: boolean;
    procedure SetSyncWidthToHeight(const Value: boolean);
    function GetSyncHeightToWidth: boolean;
    procedure SetSyncHeightToWidth(const Value: boolean);
    function GetOpaque: boolean;
    procedure SetOpaque(const Value: boolean);
    function GetPageToggle: boolean;
    procedure SetPageToggle(const Value: boolean);
    function GetPrint: boolean;
    procedure SetPrint(const Value: boolean);
    function GetShadowFormat: TOpenShadowFormat;
    procedure SetShadowFormat(const Value: TOpenShadowFormat);
    function GetSurround: TOpenFSR;
    procedure SetSurround(const Value: TOpenFSR);
    function GetHoriOrient: TOpenFHO;
    procedure SetHoriOrient(const Value: TOpenFHO);
    function GetHoriOrientPosition: integer;
    procedure SetHoriOrientPosition(const Value: integer);
    function GetHoriOrientRelation: TOpenRO;
    procedure SetHoriOrientRelation(const Value: TOpenRO);
    function GetVertOrient: TOpenFVO;
    procedure SetVertOrient(const Value: TOpenFVO);
    function GetVertOrientPosition: integer;
    procedure SetVertOrientPosition(const Value: integer);
    function GetVertOrientRelation: TOpenRO;
    procedure SetVertOrientRelation(const Value: TOpenRO);
    function GetBorder: TOOBorder;
    function GetMargin: TOOMargin;
  protected
    property Document: Variant read FDocument write FDocument;
    property FrameObj: Variant read FFrameObj write FFrameObj;
  public
    constructor Create;
    destructor Destroy; override;
    property Name: string read GetName write SetName;
    property Width: integer read GetWidth write SetWidth;
    property Height: integer read GetHeight write SetHeight;
    property RelativeWidth: integer read GetRelativeWidth write SetRelativeWidth;
    property RelativeHeight: integer read GetRelativeHeight write SetRelativeHeight;
    property BackColor: TColor read GetBackColor write SetBackColor;
    property BackColorTransparent: boolean read GetBackColorTransparent
      write SetBackColorTransparent;
    property Margin: TOOMargin read GetMargin;
    property Border: TOOBorder read GetBorder;
    property Distance: integer read GetDistance write SetDistance;
    property ContentProtected: boolean read GetContentProtected write SetContentProtected;
    property PositionProtected: boolean read GetPositionProtected write SetPositionProtected;
    property SizeProtected: boolean read GetSizeProtected write SetSizeProtected;
    property SyncWidthToHeight: boolean read GetSyncWidthToHeight write SetSyncWidthToHeight;
    property SyncHeightToWidth: boolean read GetSyncHeightToWidth write SetSyncHeightToWidth;
    property Opaque: boolean read GetOpaque write SetOpaque;
    property PageToggle: boolean read GetPageToggle write SetPageToggle;
    property Print: boolean read GetPrint write SetPrint;
    property ShadowFormat: TOpenShadowFormat read GetShadowFormat write SetShadowFormat;
    property Surround: TOpenFSR read GetSurround write SetSurround;
    property HoriOrient: TOpenFHO read GetHoriOrient write SetHoriOrient;
    property HoriOrientPosition: integer read GetHoriOrientPosition write SetHoriOrientPosition;
    property HoriOrientRelation: TOpenRO read GetHoriOrientRelation write SetHoriOrientRelation;
    property VertOrient: TOpenFVO read GetVertOrient write SetVertOrient;
    property VertOrientPosition: integer read GetVertOrientPosition write SetVertOrientPosition;
    property VertOrientRelation: TOpenRO read GetVertOrientRelation write SetVertOrientRelation;
  end;

  TOOTextFrame=class(TOOBaseFrame)
  private
    FModelCursor: TOOModelCursor;
    FOldName: string;
    procedure FreeVariants; override;
    procedure SetName(const Value: string); override;
    function GetModelCursor: TOOModelCursor;
    function GetAutoHeight: boolean;
    procedure SetAutoHeight(const Value: boolean);
  public
    constructor Create;
    destructor Destroy; override;
    property AutoHeight: boolean read GetAutoHeight write SetAutoHeight;
    property ModelCursor: TOOModelCursor read GetModelCursor;
  end;

  TOOTextFrames=class
  private
    FDocument: Variant;
    FTextFrame: TOOTextFrame;
    procedure FreeVariants; virtual;
    function GetCount: integer;
    function GetTextFrame(Index: integer): TOOTextFrame;
    function GetTextFrameByName(TextFrameName: string): TOOTextFrame;
  protected
    property Document: Variant read FDocument write FDocument;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Append(TextFrameName: string; Cursor: TOOTextCursor);
    function IsExist(TextFrameName: string): boolean;
    property Count: integer read GetCount;
    property Items[Index: integer]: TOOTextFrame read GetTextFrame; default;
    property ItemsByName[TextFrameName: string]: TOOTextFrame read GetTextFrameByName;
  end;

  TOOGraphicFrame=class(TOOBaseFrame)
  private
    function GetSurroundContour: boolean;
    procedure SetSurroundContour(const Value: boolean);
    function GetContourOutside: boolean;
    procedure SetContourOutside(const Value: boolean);
    function GetCrop: TOpenGraphicCrop;
    procedure SetCrop(const Value: TOpenGraphicCrop);
    function GetHoriMirroredOnEvenPages: boolean;
    procedure SetHoriMirroredOnEvenPages(const Value: boolean);
    function GetHoriMirroredOnOddPages: boolean;
    procedure SetHoriMirroredOnOddPages(const Value: boolean);
    function GetVertMirrored: boolean;
    procedure SetVertMirrored(const Value: boolean);
    function GetActualSize: TOpenSize;
    procedure SetActualSize(const Value: TOpenSize);
    function GetAdjustLuminance: integer;
    procedure SetAdjustLuminance(const Value: integer);
    function GetAdjustContrast: integer;
    procedure SetAdjustContrast(const Value: integer);
    function GetAdjustRed: integer;
    procedure SetAdjustRed(const Value: integer);
    function GetAdjustGreen: integer;
    procedure SetAdjustGreen(const Value: integer);
    function GetAdjustBlue: integer;
    procedure SetAdjustBlue(const Value: integer);
    function GetGamma: double;
    procedure SetGamma(const Value: double);
    function GetIsInverted: boolean;
    procedure SetIsInverted(const Value: boolean);
    function GetTransparency: integer;
    procedure SetTransparency(const Value: integer);
    function GetColorMode: TOpenCR;
    procedure SetColorMode(const Value: TOpenCR);
  public
    procedure LoadFromFile(FileName: string);
    property SurroundContour: boolean read GetSurroundContour write SetSurroundContour;
    property ContourOutside: boolean read GetContourOutside write SetContourOutside;
    property Crop: TOpenGraphicCrop read GetCrop write SetCrop;
    property HoriMirroredOnEvenPages: boolean read GetHoriMirroredOnEvenPages
      write SetHoriMirroredOnEvenPages;
    property HoriMirroredOnOddPages: boolean read GetHoriMirroredOnOddPages
      write SetHoriMirroredOnOddPages;
    property VertMirrored: boolean read GetVertMirrored write SetVertMirrored;
    property ActualSize: TOpenSize read GetActualSize write SetActualSize;
    property AdjustLuminance: integer read GetAdjustLuminance write SetAdjustLuminance;
    property AdjustContrast: integer read GetAdjustContrast write SetAdjustContrast;
    property AdjustRed: integer read GetAdjustRed write SetAdjustRed;
    property AdjustGreen: integer read GetAdjustGreen write SetAdjustGreen;
    property AdjustBlue: integer read GetAdjustBlue write SetAdjustBlue;
    property Gamma: double read GetGamma write SetGamma;
    property IsInverted: boolean read GetIsInverted write SetIsInverted;
    property Transparency: integer read GetTransparency write SetTransparency;
    property ColorMode: TOpenCR read GetColorMode write SetColorMode;
  end;

  TOOGraphicFrames=class
  private
    FDocument: Variant;
    FGraphicFrame: TOOGraphicFrame;
    procedure FreeVariants; virtual;
    function GetCount: integer;
    function GetGraphicFrame(Index: integer): TOOGraphicFrame;
    function GetGraphicFrameByName(GraphicFrameName: string): TOOGraphicFrame;
  protected
    property Document: Variant read FDocument write FDocument;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Append(GraphicFrameName: string; Cursor: TOOTextCursor);
    function IsExist(GraphicFrameName: string): boolean;
    property Count: integer read GetCount;
    property Items[Index: integer]: TOOGraphicFrame read GetGraphicFrame; default;
    property ItemsByName[GraphicFrameName: string]: TOOGraphicFrame read GetGraphicFrameByName;
  end;

  TOOWriter=class(TOpenOffice)
  private
    FSD: Variant; // Search descriptor
    FSF: Variant; // Search result
    FTables: TOOTables;
    FModelCursor: TOOModelCursor;
    FViewCursor: TOOViewCursor;
    FPageStyles: TOOWriterPageStyles;
    FBookmarks: TOOBookmarks;
    FTextFrames: TOOTextFrames;
    FGraphicFrames: TOOGraphicFrames;
    FPrinter: TOOWriterPrinter;
    procedure FreeVariants; override;
    function GetPageCount: integer;
    function GetPrinter: TOOWriterPrinter;
    function GetTables: TOOTables;
    function GetPageStyles: TOOWriterPageStyles;
    function GetBookmarks: TOOBookmarks;
    function GetTextFrames: TOOTextFrames;
    function GetGraphicFrames: TOOGraphicFrames;
    function GetModelCursor: TOOModelCursor;
    function GetViewCursor: TOOViewCursor;
  public
    constructor Create;
    destructor Destroy; override;
    procedure InsertDocument(FileName: string; InsertPosition: TOpenIP);
    procedure OpenDocument(FileName: string; OpenMode: TOpenOM; Macro: TOpenMM); override;
    procedure SaveDocument(FileName, FileType: string); override;
    procedure ReplaceAll(SearchString: string; ReplaceString: string; Param: TOpenRP);
    function FindFirst(SearchString: string; Param: TOpenSP): boolean;
    function FindNext: boolean;
    property Tables: TOOTables read GetTables;
    property ModelCursor: TOOModelCursor read GetModelCursor;
    property ViewCursor: TOOViewCursor read GetViewCursor;
    property PageStyles: TOOWriterPageStyles read GetPageStyles;
    property Bookmarks: TOOBookmarks read GetBookmarks;
    property TextFrames: TOOTextFrames read GetTextFrames;
    property GraphicFrames: TOOGraphicFrames read GetGraphicFrames;
    property Printer: TOOWriterPrinter read GetPrinter;
    property PageCount: integer read GetPageCount;
  end;

function ConvertToURL(FileName: string): variant;
function PSize(Width, Height: integer): TOpenSize;
function PPoint(X, Y: integer): TOpenPoint;
function PRect(X, Y, Width, Height: integer): TOpenRect;
function RAddress(Sheet, StartColumn, StartRow, EndColumn, EndRow: integer): TOpenRangeAddress;
function LSpacing(Mode: TOpenLS; Height: integer): TOpenLineSpacing;
function BLine(Color: TColor; InnerLineWidth: integer; OuterLineWidth: integer;
  LineDistance: integer): TOpenBorderLine;
function SFormat(Location: TOpenSF; ShadowWidth: integer; IsTransparent: boolean; Color: TColor)
  : TOpenShadowFormat;
function DCFormat(Lines, Count, Distance: integer): TOpenDropCapFormat;
function GCrop(Top, Bottom, Left, Right: integer): TOpenGraphicCrop;
function LDash(Style: TOpenSDS; Dots, DotLen, Dashes, DashLen, Distance: integer): TOpenLineDash;
function FGradient(Style: TOpenSGS; StartColor, EndColor: TColor;
  Angle, Border, XOffset, YOffset, StartIntensity, EndIntensity, StepCount: integer): TOpenGradient;
function FHatch(Style: TOpenSHS; Color: TColor; Distance, Angle: integer): TOpenHatch;
function TMatrix(L1C1, L1C2, L1C3, L2C1, L2C2, L2C3, L3C1, L3C2, L3C3: double): TOpenMatrix;
function ASortField(FieldNum: integer; IsAscending, IsCaseSensitive: boolean; FieldType: TOpenSR)
  : TOpenSortField;

implementation

uses SysUtils, ComServ;

function MakePV(ServiceManager: Variant; PropertyName: string; PropertyValue: Variant): Variant;
begin
  Result:=ServiceManager.Bridge_GetStruct('com.sun.star.beans.PropertyValue');
  case VarType(PropertyName) of
  varString, $0102 { varUString } :
  Result.Name:=VarAsType(PropertyName, varOleStr);
else
Result.Name:=PropertyName;
  end;
  case VarType(PropertyValue) of
  varString, $0102 { varUString } :
  Result.Value:=VarAsType(PropertyValue, varOleStr);
else
Result.Value:=PropertyValue;
  end;
end;

function ConvertToURL(FileName: string): variant;
type
  TCharToUTF8Table=array [0..255] of PChar;
const
  ArrayCP1251ToUTF8: TCharToUTF8Table=(#0, // #0
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
    ' ', // ' '
    '!', // '!'
    '"', // '"'
    '#', // '#'
    '$', // '$'
    '%', // '%'
    '&', // '&'
    '''', // ''''
    '(', // '('
    ')', // ')'
    '*', // '*'
    '+', // '+'
    ',', // ','
    '-', // '-'
    '.', // '.'
    '/', // '/'
    '0', // '0'
    '1', // '1'
    '2', // '2'
    '3', // '3'
    '4', // '4'
    '5', // '5'
    '6', // '6'
    '7', // '7'
    '8', // '8'
    '9', // '9'
    ':', // ':'
    ';', // ';'
    '<', // '<'
    '=', // '='
    '>', // '>'
    '?', // '?'
    '@', // '@'
    'A', // 'A'
    'B', // 'B'
    'C', // 'C'
    'D', // 'D'
    'E', // 'E'
    'F', // 'F'
    'G', // 'G'
    'H', // 'H'
    'I', // 'I'
    'J', // 'J'
    'K', // 'K'
    'L', // 'L'
    'M', // 'M'
    'N', // 'N'
    'O', // 'O'
    'P', // 'P'
    'Q', // 'Q'
    'R', // 'R'
    'S', // 'S'
    'T', // 'T'
    'U', // 'U'
    'V', // 'V'
    'W', // 'W'
    'X', // 'X'
    'Y', // 'Y'
    'Z', // 'Z'
    '[', // '['
    '\', // '\'
    ']', // ']'
    '^', // '^'
    '_', // '_'
    '`', // '`'
    'a', // 'a'
    'b', // 'b'
    'c', // 'c'
    'd', // 'd'
    'e', // 'e'
    'f', // 'f'
    'g', // 'g'
    'h', // 'h'
    'i', // 'i'
    'j', // 'j'
    'k', // 'k'
    'l', // 'l'
    'm', // 'm'
    'n', // 'n'
    'o', // 'o'
    'p', // 'p'
    'q', // 'q'
    'r', // 'r'
    's', // 's'
    't', // 't'
    'u', // 'u'
    'v', // 'v'
    'w', // 'w'
    'x', // 'x'
    'y', // 'y'
    'z', // 'z'
    '{', // '{'
    '|', // '|'
    '}', // '}'
    '~', // '~'
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
  i: integer;
  j: Byte;
  ch: Char;
  utf8ch: PChar;
Begin
  Result:='';
  For i:=1 To Length(FileName) Do
  Begin
    ch:=FileName[i];
    Case ch Of
    'А'..'Я', 'а'..'я':
    begin
      utf8ch:=ArrayCP1251ToUTF8[Ord(ch)];
      for j:=0 to Length(utf8ch)-1 do
        Result:=Result+'%'+IntToHex(Ord(utf8ch[j]), 2);
    end;
    { ' ':
      Result:=Result+'%20'; }
    '\':
    Result:=Result+'/';
    { ':':
      Result:=Result+'|'; }
  Else
  Result:=Result+ch;
    End;
  End;
  Result:=VarAsType('file:///'+Result, varOleStr);
End;

function ASortField(FieldNum: integer; IsAscending, IsCaseSensitive: boolean; FieldType: TOpenSR)
  : TOpenSortField;
begin
  Result.FieldNum:=FieldNum;
  Result.IsAscending:=IsAscending;
  Result.IsCaseSensitive:=IsCaseSensitive;
  Result.FieldType:=FieldType;
end;

function TMatrix(L1C1, L1C2, L1C3, L2C1, L2C2, L2C3, L3C1, L3C2, L3C3: double): TOpenMatrix;
begin
  Result.L1.C1:=L1C1;
  Result.L1.C2:=L1C2;
  Result.L1.C3:=L1C3;
  Result.L2.C1:=L2C1;
  Result.L2.C2:=L2C2;
  Result.L2.C3:=L2C3;
  Result.L3.C1:=L3C1;
  Result.L3.C2:=L3C2;
  Result.L3.C3:=L3C3;
end;

function FHatch(Style: TOpenSHS; Color: TColor; Distance, Angle: integer): TOpenHatch;
begin
  Result.Style:=Style;
  Result.Color:=Color;
  Result.Distance:=Distance;
  Result.Angle:=Angle;
end;

function FGradient(Style: TOpenSGS; StartColor, EndColor: TColor;
  Angle, Border, XOffset, YOffset, StartIntensity, EndIntensity, StepCount: integer): TOpenGradient;
begin
  Result.Style:=Style;
  Result.StartColor:=StartColor;
  Result.EndColor:=EndColor;
  Result.Angle:=Angle;
  Result.Border:=Border;
  Result.XOffset:=XOffset;
  Result.YOffset:=YOffset;
  Result.StartIntensity:=StartIntensity;
  Result.EndIntensity:=EndIntensity;
  Result.StepCount:=StepCount;
end;

function LDash(Style: TOpenSDS; Dots, DotLen, Dashes, DashLen, Distance: integer): TOpenLineDash;
begin
  Result.Style:=Style;
  Result.Dots:=Dots;
  Result.DotLen:=DotLen;
  Result.Dashes:=Dashes;
  Result.DashLen:=DashLen;
  Result.Distance:=Distance;
end;

function PPoint(X, Y: integer): TOpenPoint;
begin
  Result.X:=X;
  Result.Y:=Y;
end;

function PRect(X, Y, Width, Height: integer): TOpenRect;
begin
  Result.X:=X;
  Result.Y:=Y;
  Result.Width:=Width;
  Result.Height:=Height;
end;

function RAddress(Sheet, StartColumn, StartRow, EndColumn, EndRow: integer): TOpenRangeAddress;
begin
  Result.Sheet:=Sheet;
  Result.StartColumn:=StartColumn;
  Result.StartRow:=StartRow;
  Result.EndColumn:=EndColumn;
  Result.EndRow:=EndRow;
end;

function GCrop(Top, Bottom, Left, Right: integer): TOpenGraphicCrop;
begin
  Result.Top:=Top;
  Result.Bottom:=Bottom;
  Result.Left:=Left;
  Result.Right:=Right;
end;

function DCFormat(Lines, Count, Distance: integer): TOpenDropCapFormat;
begin
  Result.Lines:=Lines;
  Result.Count:=Count;
  Result.Distance:=Distance;
end;

function SFormat(Location: TOpenSF; ShadowWidth: integer; IsTransparent: boolean; Color: TColor)
  : TOpenShadowFormat;
begin
  Result.Location:=Location;
  Result.ShadowWidth:=ShadowWidth;
  Result.IsTransparent:=IsTransparent;
  Result.Color:=Color;
end;

function BLine(Color: TColor; InnerLineWidth: integer; OuterLineWidth: integer;
  LineDistance: integer): TOpenBorderLine;
begin
  Result.Color:=Color;
  Result.InnerLineWidth:=InnerLineWidth;
  Result.OuterLineWidth:=OuterLineWidth;
  Result.LineDistance:=LineDistance;
end;

function LSpacing(Mode: TOpenLS; Height: integer): TOpenLineSpacing;
begin
  Result.Mode:=Mode;
  Result.Height:=Height;
end;

function PSize(Width, Height: integer): TOpenSize;
begin
  Result.Width:=Width;
  Result.Height:=Height;
end;

function NameCR(Col, Row: integer): string;
begin
  if Col>25 then
    Result:=Chr(((Col+1)div 26)+Ord('A')-1)+Chr((Col mod 26)+Ord('A'))
  else
    Result:=Chr((Col mod 26)+Ord('A'));
  Result:=Result+IntToStr(Row+1);
end;

// ******************************************************************************
{ TOOMargin }
// ******************************************************************************

procedure TOOMargin.FreeVariants;
begin
  FMarginObj:=Unassigned;
end;

procedure TOOMargin.DoChange;
begin
  if Assigned(FOnChange) then
    FOnChange(Self);
end;

function TOOMargin.GetLeft: integer;
begin
  Result:=FMarginObj.LeftMargin;
end;

procedure TOOMargin.SetLeft(const Value: integer);
begin
  FMarginObj.LeftMargin:=Value;
  DoChange;
end;

function TOOMargin.GetRight: integer;
begin
  Result:=FMarginObj.RightMargin;
end;

procedure TOOMargin.SetRight(const Value: integer);
begin
  FMarginObj.RightMargin:=Value;
  DoChange;
end;

function TOOMargin.GetTop: integer;
begin
  Result:=FMarginObj.TopMargin;
end;

procedure TOOMargin.SetTop(const Value: integer);
begin
  FMarginObj.TopMargin:=Value;
  DoChange;
end;

function TOOMargin.GetBottom: integer;
begin
  Result:=FMarginObj.BottomMargin;
end;

procedure TOOMargin.SetBottom(const Value: integer);
begin
  FMarginObj.BottomMargin:=Value;
  DoChange;
end;

// ******************************************************************************
{ TOOParaMargin }
// ******************************************************************************

procedure TOOParaMargin.FreeVariants;
begin
  FMarginObj:=Unassigned;
end;

procedure TOOParaMargin.DoChange;
begin
  if Assigned(FOnChange) then
    FOnChange(Self);
end;

function TOOParaMargin.GetLeft: integer;
begin
  Result:=FMarginObj.ParaLeftMargin;
end;

procedure TOOParaMargin.SetLeft(const Value: integer);
begin
  FMarginObj.ParaLeftMargin:=Value;
  DoChange;
end;

function TOOParaMargin.GetRight: integer;
begin
  Result:=FMarginObj.ParaRightMargin;
end;

procedure TOOParaMargin.SetRight(const Value: integer);
begin
  FMarginObj.ParaRightMargin:=Value;
  DoChange;
end;

function TOOParaMargin.GetTop: integer;
begin
  Result:=FMarginObj.ParaTopMargin;
end;

procedure TOOParaMargin.SetTop(const Value: integer);
begin
  FMarginObj.ParaTopMargin:=Value;
  DoChange;
end;

function TOOParaMargin.GetBottom: integer;
begin
  Result:=FMarginObj.ParaBottomMargin;
end;

procedure TOOParaMargin.SetBottom(const Value: integer);
begin
  FMarginObj.ParaBottomMargin:=Value;
  DoChange;
end;

// ******************************************************************************
{ TOOBorder }
// ******************************************************************************

procedure TOOBorder.FreeVariants;
begin
  FBorderObj:=Unassigned;
end;

procedure TOOBorder.DoChange;
begin
  if Assigned(FOnChange) then
    FOnChange(Self);
end;

function TOOBorder.GetLeft: TOpenBorderLine;
var
  i: TColor;
begin
  i:=FBorderObj.LeftBorder.Color;
  Result.Color:=RGB(GetBValue(i), GetGValue(i), GetRValue(i));
  Result.InnerLineWidth:=FBorderObj.LeftBorder.InnerLineWidth;
  Result.OuterLineWidth:=FBorderObj.LeftBorder.OuterLineWidth;
  Result.LineDistance:=FBorderObj.LeftBorder.LineDistance;
end;

procedure TOOBorder.SetLeft(const Value: TOpenBorderLine);
var
  BL: Variant;
  SM: Variant;
begin
  SM:=CreateOleObject('com.sun.star.ServiceManager');
  BL:=SM.Bridge_GetStruct('com.sun.star.table.BorderLine');
  BL.Color:=RGB(GetBValue(Value.Color), GetGValue(Value.Color), GetRValue(Value.Color));
  BL.InnerLineWidth:=Value.InnerLineWidth;
  BL.OuterLineWidth:=Value.OuterLineWidth;
  BL.LineDistance:=Value.LineDistance;
  FBorderObj.LeftBorder:=BL;
  BL:=Unassigned;
  SM:=Unassigned;
  DoChange;
end;

function TOOBorder.GetRight: TOpenBorderLine;
var
  i: TColor;
begin
  i:=FBorderObj.RightBorder.Color;
  Result.Color:=RGB(GetBValue(i), GetGValue(i), GetRValue(i));
  Result.InnerLineWidth:=FBorderObj.RightBorder.InnerLineWidth;
  Result.OuterLineWidth:=FBorderObj.RightBorder.OuterLineWidth;
  Result.LineDistance:=FBorderObj.RightBorder.LineDistance;
end;

procedure TOOBorder.SetRight(const Value: TOpenBorderLine);
var
  BL: Variant;
  SM: Variant;
begin
  SM:=CreateOleObject('com.sun.star.ServiceManager');
  BL:=SM.Bridge_GetStruct('com.sun.star.table.BorderLine');
  BL.Color:=RGB(GetBValue(Value.Color), GetGValue(Value.Color), GetRValue(Value.Color));
  BL.InnerLineWidth:=Value.InnerLineWidth;
  BL.OuterLineWidth:=Value.OuterLineWidth;
  BL.LineDistance:=Value.LineDistance;
  FBorderObj.RightBorder:=BL;
  BL:=Unassigned;
  SM:=Unassigned;
  DoChange;
end;

function TOOBorder.GetTop: TOpenBorderLine;
var
  i: TColor;
begin
  i:=FBorderObj.TopBorder.Color;
  Result.Color:=RGB(GetBValue(i), GetGValue(i), GetRValue(i));
  Result.InnerLineWidth:=FBorderObj.TopBorder.InnerLineWidth;
  Result.OuterLineWidth:=FBorderObj.TopBorder.OuterLineWidth;
  Result.LineDistance:=FBorderObj.TopBorder.LineDistance;
end;

procedure TOOBorder.SetTop(const Value: TOpenBorderLine);
var
  BL: Variant;
  SM: Variant;
begin
  SM:=CreateOleObject('com.sun.star.ServiceManager');
  BL:=SM.Bridge_GetStruct('com.sun.star.table.BorderLine');
  BL.Color:=RGB(GetBValue(Value.Color), GetGValue(Value.Color), GetRValue(Value.Color));
  BL.InnerLineWidth:=Value.InnerLineWidth;
  BL.OuterLineWidth:=Value.OuterLineWidth;
  BL.LineDistance:=Value.LineDistance;
  FBorderObj.TopBorder:=BL;
  BL:=Unassigned;
  SM:=Unassigned;
  DoChange;
end;

function TOOBorder.GetBottom: TOpenBorderLine;
var
  i: TColor;
begin
  i:=FBorderObj.BottomBorder.Color;
  Result.Color:=RGB(GetBValue(i), GetGValue(i), GetRValue(i));
  Result.InnerLineWidth:=FBorderObj.BottomBorder.InnerLineWidth;
  Result.OuterLineWidth:=FBorderObj.BottomBorder.OuterLineWidth;
  Result.LineDistance:=FBorderObj.BottomBorder.LineDistance;
end;

procedure TOOBorder.SetBottom(const Value: TOpenBorderLine);
var
  BL: Variant;
  SM: Variant;
begin
  SM:=CreateOleObject('com.sun.star.ServiceManager');
  BL:=SM.Bridge_GetStruct('com.sun.star.table.BorderLine');
  BL.Color:=RGB(GetBValue(Value.Color), GetGValue(Value.Color), GetRValue(Value.Color));
  BL.InnerLineWidth:=Value.InnerLineWidth;
  BL.OuterLineWidth:=Value.OuterLineWidth;
  BL.LineDistance:=Value.LineDistance;
  FBorderObj.BottomBorder:=BL;
  BL:=Unassigned;
  SM:=Unassigned;
  DoChange;
end;

// ******************************************************************************
{ TOOBorderDistance }
// ******************************************************************************

function TOOBorderDistance.GetLeftDistance: integer;
begin
  Result:=FBorderObj.LeftDistance;
end;

procedure TOOBorderDistance.SetLeftDistance(const Value: integer);
begin
  FBorderObj.LeftDistance:=Value;
  DoChange;
end;

function TOOBorderDistance.GetRightDistance: integer;
begin
  Result:=FBorderObj.RightDistance;
end;

procedure TOOBorderDistance.SetRightDistance(const Value: integer);
begin
  FBorderObj.RightDistance:=Value;
  DoChange;
end;

function TOOBorderDistance.GetTopDistance: integer;
begin
  Result:=FBorderObj.TopDistance;
end;

procedure TOOBorderDistance.SetTopDistance(const Value: integer);
begin
  FBorderObj.TopDistance:=Value;
  DoChange;
end;

function TOOBorderDistance.GetBottomDistance: integer;
begin
  Result:=FBorderObj.BottomDistance;
end;

procedure TOOBorderDistance.SetBottomDistance(const Value: integer);
begin
  FBorderObj.BottomDistance:=Value;
  DoChange;
end;

// ******************************************************************************
{ TOOHeaderBorderDistance }
// ******************************************************************************

function TOOHeaderBorderDistance.GetLeftDistance: integer;
begin
  Result:=FBorderObj.LeftBorderDistance;
end;

procedure TOOHeaderBorderDistance.SetLeftDistance(const Value: integer);
begin
  FBorderObj.LeftBorderDistance:=Value;
  DoChange;
end;

function TOOHeaderBorderDistance.GetRightDistance: integer;
begin
  Result:=FBorderObj.RightBorderDistance;
end;

procedure TOOHeaderBorderDistance.SetRightDistance(const Value: integer);
begin
  FBorderObj.RightBorderDistance:=Value;
  DoChange;
end;

function TOOHeaderBorderDistance.GetTopDistance: integer;
begin
  Result:=FBorderObj.TopBorderDistance;
end;

procedure TOOHeaderBorderDistance.SetTopDistance(const Value: integer);
begin
  FBorderObj.TopBorderDistance:=Value;
  DoChange;
end;

function TOOHeaderBorderDistance.GetBottomDistance: integer;
begin
  Result:=FBorderObj.BottomBorderDistance;
end;

procedure TOOHeaderBorderDistance.SetBottomDistance(const Value: integer);
begin
  FBorderObj.BottomBorderDistance:=Value;
  DoChange;
end;

// ******************************************************************************
{ TOOTableBorder }
// ******************************************************************************

procedure TOOTableBorder.FreeVariants;
begin
  FTableBorderObj:=Unassigned;
end;

function TOOTableBorder.GetLeft: TOpenBorderLine;
var
  i: TColor;
begin
  i:=FTableBorderObj.TableBorder.LeftLine.Color;
  Result.Color:=RGB(GetBValue(i), GetGValue(i), GetRValue(i));
  Result.InnerLineWidth:=FTableBorderObj.TableBorder.LeftLine.InnerLineWidth;
  Result.OuterLineWidth:=FTableBorderObj.TableBorder.LeftLine.OuterLineWidth;
  Result.LineDistance:=FTableBorderObj.TableBorder.LeftLine.LineDistance;
end;

procedure TOOTableBorder.SetLeft(const Value: TOpenBorderLine);
var
  TB, BL: Variant;
  SM: Variant;
begin
  SM:=CreateOleObject('com.sun.star.ServiceManager');
  TB:=SM.Bridge_GetStruct('com.sun.star.table.TableBorder');
  BL:=SM.Bridge_GetStruct('com.sun.star.table.BorderLine');
  BL.Color:=RGB(GetBValue(Value.Color), GetGValue(Value.Color), GetRValue(Value.Color));
  BL.InnerLineWidth:=Value.InnerLineWidth;
  BL.OuterLineWidth:=Value.OuterLineWidth;
  BL.LineDistance:=Value.LineDistance;
  TB.LeftLine:=BL;
  TB.IsLeftLineValid:=true;
  TB.IsRightLineValid:=false;
  TB.IsTopLineValid:=false;
  TB.IsBottomLineValid:=false;
  TB.IsHorizontalLineValid:=false;
  TB.IsVerticalLineValid:=false;
  TB.IsDistanceValid:=false;
  FTableBorderObj.TableBorder:=TB;
  BL:=Unassigned;
  TB:=Unassigned;
  SM:=Unassigned;
end;

function TOOTableBorder.GetRight: TOpenBorderLine;
var
  i: TColor;
begin
  i:=FTableBorderObj.TableBorder.RightLine.Color;
  Result.Color:=RGB(GetBValue(i), GetGValue(i), GetRValue(i));
  Result.InnerLineWidth:=FTableBorderObj.TableBorder.RightLine.InnerLineWidth;
  Result.OuterLineWidth:=FTableBorderObj.TableBorder.RightLine.OuterLineWidth;
  Result.LineDistance:=FTableBorderObj.TableBorder.RightLine.LineDistance;
end;

procedure TOOTableBorder.SetRight(const Value: TOpenBorderLine);
var
  TB, BL: Variant;
  SM: Variant;
begin
  SM:=CreateOleObject('com.sun.star.ServiceManager');
  TB:=SM.Bridge_GetStruct('com.sun.star.table.TableBorder');
  BL:=SM.Bridge_GetStruct('com.sun.star.table.BorderLine');
  BL.Color:=RGB(GetBValue(Value.Color), GetGValue(Value.Color), GetRValue(Value.Color));
  BL.InnerLineWidth:=Value.InnerLineWidth;
  BL.OuterLineWidth:=Value.OuterLineWidth;
  BL.LineDistance:=Value.LineDistance;
  TB.RightLine:=BL;
  TB.IsLeftLineValid:=false;
  TB.IsRightLineValid:=true;
  TB.IsTopLineValid:=false;
  TB.IsBottomLineValid:=false;
  TB.IsHorizontalLineValid:=false;
  TB.IsVerticalLineValid:=false;
  TB.IsDistanceValid:=false;
  FTableBorderObj.TableBorder:=TB;
  BL:=Unassigned;
  TB:=Unassigned;
  SM:=Unassigned;
end;

function TOOTableBorder.GetTop: TOpenBorderLine;
var
  i: TColor;
begin
  i:=FTableBorderObj.TableBorder.TopLine.Color;
  Result.Color:=RGB(GetBValue(i), GetGValue(i), GetRValue(i));
  Result.InnerLineWidth:=FTableBorderObj.TableBorder.TopLine.InnerLineWidth;
  Result.OuterLineWidth:=FTableBorderObj.TableBorder.TopLine.OuterLineWidth;
  Result.LineDistance:=FTableBorderObj.TableBorder.TopLine.LineDistance;
end;

procedure TOOTableBorder.SetTop(const Value: TOpenBorderLine);
var
  TB, BL: Variant;
  SM: Variant;
begin
  SM:=CreateOleObject('com.sun.star.ServiceManager');
  TB:=SM.Bridge_GetStruct('com.sun.star.table.TableBorder');
  BL:=SM.Bridge_GetStruct('com.sun.star.table.BorderLine');
  BL.Color:=RGB(GetBValue(Value.Color), GetGValue(Value.Color), GetRValue(Value.Color));
  BL.InnerLineWidth:=Value.InnerLineWidth;
  BL.OuterLineWidth:=Value.OuterLineWidth;
  BL.LineDistance:=Value.LineDistance;
  TB.TopLine:=BL;
  TB.IsLeftLineValid:=false;
  TB.IsRightLineValid:=false;
  TB.IsTopLineValid:=true;
  TB.IsBottomLineValid:=false;
  TB.IsHorizontalLineValid:=false;
  TB.IsVerticalLineValid:=false;
  TB.IsDistanceValid:=false;
  FTableBorderObj.TableBorder:=TB;
  BL:=Unassigned;
  TB:=Unassigned;
  SM:=Unassigned;
end;

function TOOTableBorder.GetBottom: TOpenBorderLine;
var
  i: TColor;
begin
  i:=FTableBorderObj.TableBorder.BottomLine.Color;
  Result.Color:=RGB(GetBValue(i), GetGValue(i), GetRValue(i));
  Result.InnerLineWidth:=FTableBorderObj.TableBorder.BottomLine.InnerLineWidth;
  Result.OuterLineWidth:=FTableBorderObj.TableBorder.BottomLine.OuterLineWidth;
  Result.LineDistance:=FTableBorderObj.TableBorder.BottomLine.LineDistance;
end;

procedure TOOTableBorder.SetBottom(const Value: TOpenBorderLine);
var
  TB, BL: Variant;
  SM: Variant;
begin
  SM:=CreateOleObject('com.sun.star.ServiceManager');
  TB:=SM.Bridge_GetStruct('com.sun.star.table.TableBorder');
  BL:=SM.Bridge_GetStruct('com.sun.star.table.BorderLine');
  BL.Color:=RGB(GetBValue(Value.Color), GetGValue(Value.Color), GetRValue(Value.Color));
  BL.InnerLineWidth:=Value.InnerLineWidth;
  BL.OuterLineWidth:=Value.OuterLineWidth;
  BL.LineDistance:=Value.LineDistance;
  TB.BottomLine:=BL;
  TB.IsLeftLineValid:=false;
  TB.IsRightLineValid:=false;
  TB.IsTopLineValid:=false;
  TB.IsBottomLineValid:=true;
  TB.IsHorizontalLineValid:=false;
  TB.IsVerticalLineValid:=false;
  TB.IsDistanceValid:=false;
  FTableBorderObj.TableBorder:=TB;
  BL:=Unassigned;
  TB:=Unassigned;
  SM:=Unassigned;
end;

function TOOTableBorder.GetHorizontal: TOpenBorderLine;
var
  i: TColor;
begin
  i:=FTableBorderObj.TableBorder.HorizontalLine.Color;
  Result.Color:=RGB(GetBValue(i), GetGValue(i), GetRValue(i));
  Result.InnerLineWidth:=FTableBorderObj.TableBorder.HorizontalLine.InnerLineWidth;
  Result.OuterLineWidth:=FTableBorderObj.TableBorder.HorizontalLine.OuterLineWidth;
  Result.LineDistance:=FTableBorderObj.TableBorder.HorizontalLine.LineDistance;
end;

procedure TOOTableBorder.SetHorizontal(const Value: TOpenBorderLine);
var
  TB, BL: Variant;
  SM: Variant;
begin
  SM:=CreateOleObject('com.sun.star.ServiceManager');
  TB:=SM.Bridge_GetStruct('com.sun.star.table.TableBorder');
  BL:=SM.Bridge_GetStruct('com.sun.star.table.BorderLine');
  BL.Color:=RGB(GetBValue(Value.Color), GetGValue(Value.Color), GetRValue(Value.Color));
  BL.InnerLineWidth:=Value.InnerLineWidth;
  BL.OuterLineWidth:=Value.OuterLineWidth;
  BL.LineDistance:=Value.LineDistance;
  TB.HorizontalLine:=BL;
  TB.IsLeftLineValid:=false;
  TB.IsRightLineValid:=false;
  TB.IsTopLineValid:=false;
  TB.IsBottomLineValid:=false;
  TB.IsHorizontalLineValid:=true;
  TB.IsVerticalLineValid:=false;
  TB.IsDistanceValid:=false;
  FTableBorderObj.TableBorder:=TB;
  BL:=Unassigned;
  TB:=Unassigned;
  SM:=Unassigned;
end;

function TOOTableBorder.GetVertical: TOpenBorderLine;
var
  i: TColor;
begin
  i:=FTableBorderObj.TableBorder.VerticalLine.Color;
  Result.Color:=RGB(GetBValue(i), GetGValue(i), GetRValue(i));
  Result.InnerLineWidth:=FTableBorderObj.TableBorder.VerticalLine.InnerLineWidth;
  Result.OuterLineWidth:=FTableBorderObj.TableBorder.VerticalLine.OuterLineWidth;
  Result.LineDistance:=FTableBorderObj.TableBorder.VerticalLine.LineDistance;
end;

procedure TOOTableBorder.SetVertical(const Value: TOpenBorderLine);
var
  TB, BL: Variant;
  SM: Variant;
begin
  SM:=CreateOleObject('com.sun.star.ServiceManager');
  TB:=SM.Bridge_GetStruct('com.sun.star.table.TableBorder');
  BL:=SM.Bridge_GetStruct('com.sun.star.table.BorderLine');
  BL.Color:=RGB(GetBValue(Value.Color), GetGValue(Value.Color), GetRValue(Value.Color));
  BL.InnerLineWidth:=Value.InnerLineWidth;
  BL.OuterLineWidth:=Value.OuterLineWidth;
  BL.LineDistance:=Value.LineDistance;
  TB.VerticalLine:=BL;
  TB.IsLeftLineValid:=false;
  TB.IsRightLineValid:=false;
  TB.IsTopLineValid:=false;
  TB.IsBottomLineValid:=false;
  TB.IsHorizontalLineValid:=false;
  TB.IsVerticalLineValid:=true;
  TB.IsDistanceValid:=false;
  FTableBorderObj.TableBorder:=TB;
  BL:=Unassigned;
  TB:=Unassigned;
  SM:=Unassigned;
end;

procedure TOOTableBorder.SetAll(const Value: TOpenBorderLine; Lines: TOpenTB);
var
  TB, BL, NullBL: Variant;
  SM: Variant;
begin
  SM:=CreateOleObject('com.sun.star.ServiceManager');
  TB:=SM.Bridge_GetStruct('com.sun.star.table.TableBorder');
  BL:=SM.Bridge_GetStruct('com.sun.star.table.BorderLine');
  NullBL:=SM.Bridge_GetStruct('com.sun.star.table.BorderLine');
  NullBL.Color:=0;
  NullBL.InnerLineWidth:=0;
  NullBL.OuterLineWidth:=0;
  NullBL.LineDistance:=0;
  BL.Color:=RGB(GetBValue(Value.Color), GetGValue(Value.Color), GetRValue(Value.Color));
  BL.InnerLineWidth:=Value.InnerLineWidth;
  BL.OuterLineWidth:=Value.OuterLineWidth;
  BL.LineDistance:=Value.LineDistance;
  if (Lines<>otbNone) then
  begin
    TB.LeftLine:=BL;
    TB.RightLine:=BL;
    TB.TopLine:=BL;
    TB.BottomLine:=BL;
  end
  else
  begin
    TB.LeftLine:=NullBL;
    TB.RightLine:=NullBL;
    TB.TopLine:=NullBL;
    TB.BottomLine:=NullBL;
  end;
  if (Lines=otbOuterHori)or(Lines=otbOuterHoriVert) then
    TB.HorizontalLine:=BL
  else
    TB.HorizontalLine:=NullBL;
  if (Lines=otbOuterVert)or(Lines=otbOuterHoriVert) then
    TB.VerticalLine:=BL
  else
    TB.VerticalLine:=NullBL;
  TB.IsLeftLineValid:=true;
  TB.IsRightLineValid:=true;
  TB.IsTopLineValid:=true;
  TB.IsBottomLineValid:=true;
  TB.IsHorizontalLineValid:=true;
  TB.IsVerticalLineValid:=true;
  TB.IsDistanceValid:=false;
  FTableBorderObj.TableBorder:=TB;
  NullBL:=Unassigned;
  BL:=Unassigned;
  TB:=Unassigned;
  SM:=Unassigned;
end;

// ******************************************************************************
{ TOpenOffice }
// ******************************************************************************

constructor TOpenOffice.Create;
begin
  inherited;
  FNumberFormats:=TOONumberFormats.Create;
  FLocale:=TOOGlobalLocale.Create;
{$IFDEF WITH_EVENTS}
  FDocEvent:=TListener.Create;
  FDocEvent.FParent:=Self;
{$ENDIF}
  FDesktop:=Unassigned;
  FDocument:=Unassigned;
  FNewName:='';
  FProgType:='';
end;

destructor TOpenOffice.Destroy;
begin
  FLocale.Free;
  FNumberFormats.Free;
  inherited;
end;

procedure TOpenOffice.FreeVariants;
begin
  FDocument:=Unassigned;
  FLocale.FreeVariants;
  FNumberFormats.FreeVariants;
end;

function TOpenOffice.GetConnect: boolean;
begin
  Result:=not(VarIsEmpty(FDesktop)or VarIsNull(FDesktop)or VarIsClear(FDesktop));
end;

procedure TOpenOffice.SetConnect(const Value: boolean);
var
  SM: Variant;
begin
  if Value then
  begin
    try
      SM:=CreateOleObject('com.sun.star.ServiceManager');
      if (VarType(SM)=varDispatch) then
        FDesktop:=SM.CreateInstance('com.sun.star.frame.Desktop');
    except
      FDesktop:=Unassigned;
    end;
  end
  else
  begin
    FreeVariants;
  end;
  SM:=Unassigned;
end;

function TOpenOffice.GetVisible: boolean;
var
  V: Variant;
begin
  V:=FDocument.GetCurrentController.GetFrame.GetContainerWindow;
  Result:=(V.getPosSize.Width<>0)or(V.getPosSize.Height<>0);
  V:=Unassigned;
end;

procedure TOpenOffice.SetVisible(const Value: boolean);
begin
  FDocument.GetCurrentController.GetFrame.GetContainerWindow.SetVisible(Value);
end;

function TOpenOffice.GetModified: boolean;
begin
  Result:=FDocument.IsModified;
end;

procedure TOpenOffice.SetModified(const Value: boolean);
begin
  FDocument.SetModified(Value);
end;

{$IFDEF WITH_EVENTS}

procedure TOpenOffice.OnBeforeSave;
begin
  if Assigned(FBeforeSave) then
    FBeforeSave(Self);
end;

procedure TOpenOffice.OnAfterSave;
begin
  if Assigned(FAfterSave) then
    FAfterSave(Self);
end;

procedure TOpenOffice.OnBeforeSaveAs;
begin
  if Assigned(FBeforeSaveAs) then
    FBeforeSaveAs(Self);
end;

procedure TOpenOffice.OnAfterSaveAs;
begin
  if Assigned(FAfterSaveAs) then
    FAfterSaveAs(Self);
end;

procedure TOpenOffice.OnBeforeClose;
begin
  if Assigned(FBeforeClose) then
    FBeforeClose(Self);
end;

procedure TOpenOffice.OnAfterClose;
begin
  if Assigned(FAfterClose) then
  begin
    FAfterClose(Self);
    FDocument.RemoveEventListener(FDocEvent as Listener);
    SetConnect(false);
  end;
end;

procedure TOpenOffice.OnFocus;
begin
  if Assigned(FFocus) then
    FFocus(Self);
end;

procedure TOpenOffice.OnUnfocus;
begin
  if Assigned(FUnfocus) then
    FUnfocus(Self);
end;
{$ENDIF}

procedure TOpenOffice.OpenDocument(FileName: string; OpenMode: TOpenOM; Macro: TOpenMM);
var
  FilePath: variant;
  Ar, SM: Variant;
begin
  if (FileName<>'') then
    if ConnectTo(FileName) then
      Exit;
  SM:=CreateOleObject('com.sun.star.ServiceManager');
  if (FileName='') then
    FilePath:=VarAsType(FNewName, varOleStr)
  else
    FilePath:=ConvertToURL(FileName);
  Ar:=VarArrayCreate([0, 3], varVariant);
  Ar[0]:=MakePV(SM, 'AsTemplate', oomAsTemplate in OpenMode);
  Ar[1]:=MakePV(SM, 'ReadOnly', oomReadOnly in OpenMode);
  Ar[2]:=MakePV(SM, 'MacroExecutionMode', Macro);
  Ar[3]:=MakePV(SM, 'Hidden', oomHidden in OpenMode);

  FDocument:=FDesktop.LoadComponentFromURL(FilePath, '_blank', 0, Ar);
{$IFDEF WITH_EVENTS}
  FDocument.AddEventListener(FDocEvent as Listener);
{$ENDIF}
  Ar:=Unassigned;
  SM:=Unassigned;
end;

function TOpenOffice.ConnectTo(FileName: string): boolean;
var
  Enum, V: Variant;
begin
  Result:=false;
  Enum:=FDesktop.GetComponents.CreateEnumeration;
  while Enum.HasMoreElements do
  begin
    V:=Enum.NextElement;
    if (FProgType='writer')and(V.SupportsService('com.sun.star.text.TextDocument')) then
      if UpperCase(V.URL)=UpperCase(ConvertToURL(FileName)) then
      begin
        FDocument:=V;
        Result:=true;
        Break;
      end;
    if (FProgType='calc')and(V.SupportsService('com.sun.star.sheet.SpreadsheetDocument')) then
      if UpperCase(V.URL)=UpperCase(ConvertToURL(FileName)) then
      begin
        FDocument:=V;
        Result:=true;
        Break;
      end;
  end;
  V:=Unassigned;
  Enum:=Unassigned;
end;

procedure TOpenOffice.ExportToPDF(FileName: string);
var
  FName, FType: string;
  FExt: string;
  Ar: Variant;
  SM: Variant;
  Ext: string;
begin
  SM:=CreateOleObject('com.sun.star.ServiceManager');
  FType:=FProgType+'_pdf_Export';
  FExt:='.pdf';
  Ext:=UpperCase(ExtractFileExt(FileName));
  if Ext<>'.PDF' then
    FName:=FileName+FExt
  else
    FName:=FileName;
  FName:=ConvertToURL(FName);
  Ar:=VarArrayCreate([0, 1], varVariant);
  Ar[0]:=MakePV(SM, 'FilterName', FType);
  Ar[1]:=MakePV(SM, 'Overwrite', true);
  FDocument.StoreToURL(FName, Ar);
  Ar:=Unassigned;
  SM:=Unassigned;
end;

procedure TOpenOffice.CloseDocument;
begin
  FDocument.Close(true);
  FreeVariants;
  if FDesktop.Frames.Count=0 then
  begin
    FDesktop.Terminate;
    SetConnect(false);
    FDesktop:=Unassigned;
  end;
end;

function TOpenOffice.GetNumberFormats: TOONumberFormats;
begin
  FNumberFormats.Document:=FDocument;
  Result:=FNumberFormats;
end;

function TOpenOffice.GetGlobalLocale: TOOGlobalLocale;
begin
  FLocale.Document:=FDocument;
  Result:=FLocale;
end;

function TOpenOffice.GetDocLocale: TOpenLocale;
begin
  Result.Language:=FDocument.CharLocale.Language;
  Result.Country:=FDocument.CharLocale.Country;
  Result.Variant:=FDocument.CharLocale.Variant;
end;

function TOpenOffice.GetCurrentController: Variant;
Begin
  Result:=FDocument.GetCurrentController; // .GetFrame;
end;

procedure TOpenOffice.SetDocLocale(const Value: TOpenLocale);
var
  SM, Lc: Variant;
begin
  SM:=CreateOleObject('com.sun.star.ServiceManager');
  Lc:=SM.Bridge_GetStruct('com.sun.star.lang.Locale');
  Lc.Language:=Value.Language;
  Lc.Country:=Value.Country;
  Lc.Variant:=Value.Variant;
  FDocument.CharLocale:=Lc;
  Lc:=Unassigned;
  SM:=Unassigned;
end;

procedure TOpenOffice.ShowPreview;
var
  OODispatcher: Variant;
  Ar, SM: Variant;
begin
  SM:=CreateOleObject('com.sun.star.ServiceManager');
  OODispatcher:=SM.CreateInstance('com.sun.star.frame.DispatchHelper');
  Ar:=VarArrayCreate([0, 0], varVariant);
  Ar[0]:=SM.Bridge_GetStruct('com.sun.star.beans.PropertyValue');
  OODispatcher.ExecuteDispatch(FDocument.GetCurrentController.GetFrame, '.uno:PrintPreview',
    '', 0, Ar);
  OODispatcher:=Unassigned;
  Ar:=Unassigned;
  SM:=Unassigned;
end;

procedure TOpenOffice.ClosePreview;
var
  OODispatcher: Variant;
  Ar, SM: Variant;
begin
  SM:=CreateOleObject('com.sun.star.ServiceManager');
  OODispatcher:=SM.CreateInstance('com.sun.star.frame.DispatchHelper');
  Ar:=VarArrayCreate([0, 0], varVariant);
  Ar[0]:=SM.Bridge_GetStruct('com.sun.star.beans.PropertyValue');
  OODispatcher.ExecuteDispatch(FDocument.GetCurrentController.GetFrame, '.uno:ClosePreview',
    '', 0, Ar);
  OODispatcher:=Unassigned;
  Ar:=Unassigned;
  SM:=Unassigned;
end;

procedure TOpenOffice.ExecMacro(MacroName: string);
var
  OODispatcher: Variant;
  Ar, SM: Variant;
begin
  SM:=CreateOleObject('com.sun.star.ServiceManager');
  OODispatcher:=SM.CreateInstance('com.sun.star.frame.DispatchHelper');
  Ar:=VarArrayCreate([0, 0], varVariant);
  Ar[0]:=SM.Bridge_GetStruct('com.sun.star.beans.PropertyValue');
  OODispatcher.ExecuteDispatch(FDesktop.GetCurrentFrame, 'macro:///'+MacroName, '', 0, Ar);
  OODispatcher:=Unassigned;
  Ar:=Unassigned;
  SM:=Unassigned;
end;

// ******************************************************************************
{ TOOCalc }
// ******************************************************************************

constructor TOOCalc.Create;
begin
  inherited;
  FNewName:='private:factory/scalc';
  FProgType:='calc';
  FCell:=TOOCalcCell.Create;
  FSheets:=TOOCalcSheets.Create;
  FPageStyles:=TOOCalcPageStyles.Create;
  FPrinter:=TOOCalcPrinter.Create;
end;

destructor TOOCalc.Destroy;
begin
  FPrinter.Free;
  FPageStyles.Free;
  FCell.Free;
  FSheets.Free;
  inherited;
end;

procedure TOOCalc.SetScreenUpdating(Value: boolean);
begin
  if Value then
  begin
    FDocument.UnLockControllers;
    FDocument.RemoveActionLock;
  end
  else
  begin
    FDocument.LockControllers;
    FDocument.AddActionLock;
  end;
  FScreenUpdating:=Value;
end;

procedure TOOCalc.ReplaceAll(SearchString: string; ReplaceString: string; Param: TOpenRP);
var
  RD: Variant;
  i: integer;
begin
  RD:=FDocument.GetCurrentController.GetActiveSheet.CreateReplaceDescriptor;
  RD.SearchString:=SearchString;
  RD.ReplaceString:=ReplaceString;
  RD.SearchWords:=orpWholeWords in Param;
  RD.SearchCaseSensitive:=orpCaseSensitive in Param;
  for i:=0 to Sheets.Count-1 do
    FDocument.GetSheets.GetByIndex(i).ReplaceAll(RD);
  RD:=Unassigned;
end;

function TOOCalc.HasFreezeAtCurrentSheet: boolean;
begin
  Result:=FDocument.GetCurrentController.HasFrozenPanes;
end;

procedure TOOCalc.FreezeAtCurrentSheet(Cols, Rows: integer);
begin
  FDocument.GetCurrentController.FreezeAtPosition(Cols, Rows);
end;

procedure TOOCalc.SaveDocument(FileName, FileType: string);
var
  FName, FType: string;
  FExt: string;
  Ar, SM: Variant;
  Ext: string;
begin
  SM:=CreateOleObject('com.sun.star.ServiceManager');
  FType:='calc8';
  FExt:='.ods';
  Ext:=UpperCase(ExtractFileExt(FileName));
  if (FileType='Excel97')or(Ext='.XLS') then
  begin
    FType:='MS Excel 97';
    FExt:='.xls';
  end;
  if (FileType='Calc')or(Ext='.ODS') then
  begin
    FType:='calc8';
    FExt:='.ods';
  end;
  if Ext<>UpperCase(FExt) then
    FName:=FileName+FExt
  else
    FName:=FileName;
  FName:=ConvertToURL(FName);
  Ar:=VarArrayCreate([0, 1], varVariant);
  Ar[0]:=MakePV(SM, 'FilterName', FType);
  Ar[1]:=MakePV(SM, 'Overwrite', true);
  FDocument.StoreAsURL(FName, Ar);
  Ar:=Unassigned;
  SM:=Unassigned;
end;

procedure TOOCalc.FreeVariants;
begin
  inherited;
  FCell.FreeVariants;
  FSheets.FreeVariants;
  FPageStyles.FreeVariants;
  FPrinter.FreeVariants;
end;

function TOOCalc.GetSheets: TOOCalcSheets;
begin
  FSheets.Document:=FDocument;
  Result:=FSheets;
end;

function TOOCalc.GetPrinter: TOOCalcPrinter;
begin
  FPrinter.Document:=FDocument;
  Result:=FPrinter;
end;

function TOOCalc.GetPageStyles: TOOCalcPageStyles;
begin
  FPageStyles.Document:=FDocument;
  Result:=FPageStyles;
end;

function TOOCalc.GetExpandReferences: boolean;
var
  GSS, SM: Variant;
begin
  SM:=CreateOleObject('com.sun.star.ServiceManager');
  GSS:=SM.CreateInstance('com.sun.star.sheet.GlobalSheetSettings');
  Result:=GSS.ExpandReferences;
  GSS:=Unassigned;
  SM:=Unassigned;
end;

procedure TOOCalc.SetExpandReferences(const Value: boolean);
var
  GSS, SM: Variant;
begin
  SM:=CreateOleObject('com.sun.star.ServiceManager');
  GSS:=SM.CreateInstance('com.sun.star.sheet.GlobalSheetSettings');
  GSS.ExpandReferences:=Value;
  GSS:=Unassigned;
  SM:=Unassigned;
end;

function TOOCalc.GetExtendFormat: boolean;
var
  GSS, SM: Variant;
begin
  SM:=CreateOleObject('com.sun.star.ServiceManager');
  GSS:=SM.CreateInstance('com.sun.star.sheet.GlobalSheetSettings');
  Result:=GSS.ExtendFormat;
  GSS:=Unassigned;
  SM:=Unassigned;
end;

procedure TOOCalc.SetExtendFormat(const Value: boolean);
var
  GSS, SM: Variant;
begin
  SM:=CreateOleObject('com.sun.star.ServiceManager');
  GSS:=SM.CreateInstance('com.sun.star.sheet.GlobalSheetSettings');
  GSS.ExtendFormat:=Value;
  GSS:=Unassigned;
  SM:=Unassigned;
end;

// ******************************************************************************
{ TOOCalcCell }
// ******************************************************************************

constructor TOOCalcCell.Create;
begin
  inherited Create;
  FTextCursor:=TOOBaseTextCursor.Create;
end;

destructor TOOCalcCell.Destroy;
begin
  FTextCursor.Free;
  inherited;
end;

function TOOCalcCell.MergedRange(var RangeAddress: TOpenRangeAddress): boolean;
var
  Cr: Variant;
begin
  Cr:=FParentSheetObj.CreateCursorByRange(FCellObj);
  Cr.CollapseToMergedArea;
  RangeAddress.Sheet:=Cr.RangeAddress.Sheet;
  RangeAddress.StartColumn:=Cr.RangeAddress.StartColumn;
  RangeAddress.StartRow:=Cr.RangeAddress.StartRow;
  RangeAddress.EndColumn:=Cr.RangeAddress.EndColumn;
  RangeAddress.EndRow:=Cr.RangeAddress.EndRow;
  Result:=(RangeAddress.StartColumn<>RangeAddress.EndColumn)or
    (RangeAddress.StartRow<>RangeAddress.EndRow);
  if not Result then
  begin
    RangeAddress.Sheet:=-1;
    RangeAddress.StartColumn:=-1;
    RangeAddress.StartRow:=-1;
    RangeAddress.EndColumn:=-1;
    RangeAddress.EndRow:=-1;
  end;
  Cr:=Unassigned;
end;

function TOOCalcCell.GetDataType: TOpenDT;
begin
{$IFDEF FPC}
  Result:=FCellObj.&Type;
{$ELSE}
  Result:=FCellObj.Type;
{$ENDIF}
end;

function TOOCalcCell.GetAsText: string;
begin
  Result:=FCellObj.GetString;
end;

procedure TOOCalcCell.SetAsText(const Value: string);
begin
  FCellObj.SetString(Value);
end;

function TOOCalcCell.GetAsDate: TDateTime;
begin
  Result:=FCellObj.GetValue;
end;

procedure TOOCalcCell.SetAsDate(const Value: TDateTime);
begin
  FCellObj.SetValue(Value);
end;

function TOOCalcCell.GetAsFormula: string;
begin
  Result:=FCellObj.GetFormula;
end;

procedure TOOCalcCell.SetAsFormula(const Value: string);
begin
  FCellObj.SetFormula(Value);
end;

function TOOCalcCell.GetAsNumber: double;
begin
  Result:=FCellObj.GetValue;
end;

procedure TOOCalcCell.SetAsNumber(const Value: double);
begin
  FCellObj.SetValue(Value);
end;

function TOOCalcCell.GetLeft: integer;
begin
  Result:=FCellObj.Position.X;
end;

function TOOCalcCell.GetTop: integer;
begin
  Result:=FCellObj.Position.Y;
end;

function TOOCalcCell.GetWidth: integer;
begin
  Result:=FCellObj.Size.Width;
end;

function TOOCalcCell.GetHeight: integer;
begin
  Result:=FCellObj.Size.Height;
end;

function TOOCalcCell.GetTextCursor: TOOBaseTextCursor;
begin
  FTextCursor.Document:=Document;
  if FIsNewCell or VarIsEmpty(FTextCursor.CursorObj) then
    FTextCursor.CursorObj:=FCellObj.GetText.CreateTextCursor;
  Result:=FTextCursor;
end;

function TOOCalcCell.GetAnnotation: string;
var
  i: integer;
  AnnAll, AN, CA: Variant;
begin
  Result:='null';
  AnnAll:=FParentSheetObj.GetAnnotations;
  CA:=FCellObj.GetCellAddress;
  for i:=0 to AnnAll.Count-1 do
  begin
    AN:=AnnAll.GetByIndex(i);
    if (AN.Position.Sheet=CA.Sheet)and(AN.Position.Column=CA.Column)and(AN.Position.Row=CA.Row) then
      Result:= {$IFDEF FPC} AN.&String; {$ELSE} AN.String; {$ENDIF}
  end;
  AnnAll:=Unassigned;
  CA:=Unassigned;
  AN:=Unassigned;
end;

procedure TOOCalcCell.SetAnnotation(const Value: string);
var
  CA, AnnAll, NewCA, SM: Variant;
begin
  CA:=FCellObj.GetCellAddress;
  AnnAll:=FParentSheetObj.GetAnnotations;
  SM:=CreateOleObject('com.sun.star.ServiceManager');
  NewCA:=SM.Bridge_GetStruct('com.sun.star.table.CellAddress');
  NewCA.Sheet:=CA.Sheet;
  NewCA.Column:=CA.Column;
  NewCA.Row:=CA.Row;
  AnnAll.InsertNew(NewCA, Value);
  AnnAll:=Unassigned;
  CA:=Unassigned;
  NewCA:=Unassigned;
  SM:=Unassigned;
end;

// ******************************************************************************
{ TOOCalcSheet }
// ******************************************************************************

constructor TOOCalcSheet.Create;
begin
  inherited Create;
  FColumns:=TOOCalcColumns.Create;
  FRows:=TOOCalcRows.Create;
  FCell:=TOOCalcCell.Create;
  FCellRange:=TOOCalcCellRange.Create;
  FTextShapes:=TOOTextShapes.Create;
  FLineShapes:=TOOLineShapes.Create;
  FGraphicShapes:=TOOGraphicShapes.Create;
  FEllipseShapes:=TOOEllipseShapes.Create;
  FRectangleShapes:=TOORectangleShapes.Create;
  FMeasureShapes:=TOOMeasureShapes.Create;
  FBarCharts:=TOOBarCharts.Create;
  FLineCharts:=TOOLineCharts.Create;
  FPieCharts:=TOOPieCharts.Create;
  FAreaCharts:=TOOAreaCharts.Create;
end;

destructor TOOCalcSheet.Destroy;
begin
  FAreaCharts.Free;
  FPieCharts.Free;
  FLineCharts.Free;
  FBarCharts.Free;
  FMeasureShapes.Free;
  FRectangleShapes.Free;
  FEllipseShapes.Free;
  FGraphicShapes.Free;
  FLineShapes.Free;
  FTextShapes.Free;
  FCellRange.Free;
  FCell.Free;
  FRows.Free;
  FColumns.Free;
  inherited;
end;

procedure TOOCalcSheet.FreeVariants;
begin
  FSheetObj:=Unassigned;
  FDocument:=Unassigned;
  FColumns.FreeVariants;
  FRows.FreeVariants;
  FCell.FreeVariants;
  FCellRange.FreeVariants;
  FTextShapes.FreeVariants;
  FLineShapes.FreeVariants;
  FGraphicShapes.FreeVariants;
  FEllipseShapes.FreeVariants;
  FRectangleShapes.FreeVariants;
  FMeasureShapes.FreeVariants;
  FBarCharts.FreeVariants;
  FLineCharts.FreeVariants;
  FPieCharts.FreeVariants;
  FAreaCharts.FreeVariants;
end;

procedure TOOCalcSheet.ReplaceAll(SearchString, ReplaceString: string; Param: TOpenRP);
var
  RD: Variant;
begin
  RD:=FSheetObj.CreateReplaceDescriptor;
  RD.SearchString:=SearchString;
  RD.ReplaceString:=ReplaceString;
  RD.SearchWords:=orpWholeWords in Param;
  RD.SearchCaseSensitive:=orpCaseSensitive in Param;
  FSheetObj.ReplaceAll(RD);
  RD:=Unassigned;
end;

procedure TOOCalcSheet.Copy(NewSheetName: string; Index: integer);
var
  s: string;
begin
  if FDocument.GetSheets.HasByName(NewSheetName) then
    Raise Exception.Create('Sheet with specified name already exist.');
  s:=FSheetObj.Name;
  FDocument.GetSheets.CopyByName(s, NewSheetName, Index);
end;

function TOOCalcSheet.GetName: string;
begin
  Result:=FSheetObj.Name;
end;

procedure TOOCalcSheet.SetName(const Value: string);
begin
  FSheetObj.Name:=Value;
end;

function TOOCalcSheet.GetPageStyle: string;
begin
  Result:=FSheetObj.PageStyle;
end;

procedure TOOCalcSheet.SetPageStyle(const Value: string);
begin
  FSheetObj.PageStyle:=Value;
end;

function TOOCalcSheet.GetColumns: TOOCalcColumns;
begin
  FColumns.ParentSheetObj:=FSheetObj;
  Result:=FColumns;
end;

function TOOCalcSheet.GetRows: TOOCalcRows;
begin
  FRows.ParentSheetObj:=FSheetObj;
  Result:=FRows;
end;

function TOOCalcSheet.GetCell(Col, Row: integer): TOOCalcCell;
var
  OldCellName, NewCellName: string;
  OldCellX, OldCellY, NewCellX, NewCellY: integer;
begin
  OldCellName:='';
  OldCellX:=-1;
  OldCellY:=-1;
  if VarType(FCell.CellObj)=varDispatch then
  begin
    OldCellName:=FCell.CellObj.AbsoluteName;
    OldCellX:=FCell.CellObj.Position.X;
    OldCellY:=FCell.CellObj.Position.Y;
  end;
  FCell.CellObj:=FSheetObj.GetCellByPosition(Col, Row);
  NewCellName:=FCell.CellObj.AbsoluteName;
  NewCellX:=FCell.CellObj.Position.X;
  NewCellY:=FCell.CellObj.Position.Y;
  FCell.IsNewCell:=(OldCellName<>NewCellName)or(OldCellX<>NewCellX)or(OldCellY<>NewCellY);
  FCell.ParentSheetObj:=FSheetObj;
  FCell.Document:=FDocument;
  Result:=FCell;
end;

function TOOCalcSheet.GetCellByName(CellName: string): TOOCalcCell;
var
  OldCell: Variant;
begin
  if Pos(':', CellName)=0 then
  begin
    OldCell:=FCell.CellObj;
    FCell.CellObj:=FSheetObj.GetCellRangeByName(CellName);
    FCell.IsNewCell:=@OldCell<>@FCell.CellObj;
    FCell.ParentSheetObj:=FSheetObj;
    FCell.Document:=FDocument;
    Result:=FCell;
  end
  else
    Raise Exception.Create('Try to return CellRange, expect Cell.');
end;

function TOOCalcSheet.GetCellRange(StartCol, StartRow, EndCol, EndRow: integer): TOOCalcCellRange;
begin
  FCellRange.CellObj:=FSheetObj.GetCellRangeByPosition(StartCol, StartRow, EndCol, EndRow);
  FCellRange.ParentSheetObj:=FSheetObj;
  FCellRange.Document:=FDocument;
  Result:=FCellRange;
end;

function TOOCalcSheet.GetCellRangeByName(CellRangeName: string): TOOCalcCellRange;
begin
  FCellRange.CellObj:=FSheetObj.GetCellRangeByName(CellRangeName);
  FCellRange.ParentSheetObj:=FSheetObj;
  FCellRange.Document:=FDocument;
  Result:=FCellRange;
end;

function TOOCalcSheet.GetRepeatTitleColumns: boolean;
begin
  Result:=FSheetObj.GetPrintTitleColumns;
end;

procedure TOOCalcSheet.SetRepeatTitleColumns(const Value: boolean);
begin
  FSheetObj.SetPrintTitleColumns(Value);
end;

function TOOCalcSheet.GetRepeatTitleRows: boolean;
begin
  Result:=FSheetObj.GetPrintTitleRows;
end;

procedure TOOCalcSheet.SetRepeatTitleRows(const Value: boolean);
begin
  FSheetObj.SetPrintTitleRows(Value);
end;

function TOOCalcSheet.GetVisible: boolean;
begin
  Result:=FSheetObj.IsVisible;
end;

procedure TOOCalcSheet.SetVisible(const Value: boolean);
begin
  FSheetObj.IsVisible:=Value;
end;

function TOOCalcSheet.GetTextShapes: TOOTextShapes;
begin
  FTextShapes.Document:=FDocument;
  FTextShapes.DrawPageObj:=FSheetObj.DrawPage;
  Result:=FTextShapes;
end;

function TOOCalcSheet.GetSheetIndex: integer;
var
  i: integer;
begin
  Result:=-1;
  for i:=0 to FDocument.Sheets.Count-1 do
  begin
    if FDocument.GetSheets.GetByIndex(i).GetName=Name then
    begin
      Result:=i;
      Break;
    end;
  end;
end;

function TOOCalcSheet.GetUsedArea: TOpenRangeAddress;
var
  V: Variant;
begin
  V:=SheetObj.CreateCursor;
  V.GotoStartOfUsedArea(false);
  Result.Sheet:=V.RangeAddress.Sheet;
  Result.StartColumn:=V.RangeAddress.StartColumn;
  Result.StartRow:=V.RangeAddress.StartRow;
  V.GotoEndOfUsedArea(false);
  Result.EndColumn:=V.RangeAddress.EndColumn;
  Result.EndRow:=V.RangeAddress.EndRow;
  V:=Unassigned;
end;

function TOOCalcSheet.GetLineShapes: TOOLineShapes;
begin
  FLineShapes.Document:=FDocument;
  FLineShapes.DrawPageObj:=FSheetObj.DrawPage;
  Result:=FLineShapes;
end;

function TOOCalcSheet.GetGraphicShapes: TOOGraphicShapes;
begin
  FGraphicShapes.Document:=FDocument;
  FGraphicShapes.DrawPageObj:=FSheetObj.DrawPage;
  Result:=FGraphicShapes;
end;

function TOOCalcSheet.GetEllipseShapes: TOOEllipseShapes;
begin
  FEllipseShapes.Document:=FDocument;
  FEllipseShapes.DrawPageObj:=FSheetObj.DrawPage;
  Result:=FEllipseShapes;
end;

function TOOCalcSheet.GetRectangleShapes: TOORectangleShapes;
begin
  FRectangleShapes.Document:=FDocument;
  FRectangleShapes.DrawPageObj:=FSheetObj.DrawPage;
  Result:=FRectangleShapes;
end;

function TOOCalcSheet.GetMeasureShapes: TOOMeasureShapes;
begin
  FMeasureShapes.Document:=FDocument;
  FMeasureShapes.DrawPageObj:=FSheetObj.DrawPage;
  Result:=FMeasureShapes;
end;

function TOOCalcSheet.GetBarCharts: TOOBarCharts;
begin
  FBarCharts.Document:=FDocument;
  FBarCharts.SheetObj:=FSheetObj;
  Result:=FBarCharts;
end;

function TOOCalcSheet.GetLineCharts: TOOLineCharts;
begin
  FLineCharts.Document:=FDocument;
  FLineCharts.SheetObj:=FSheetObj;
  Result:=FLineCharts;
end;

function TOOCalcSheet.GetPieCharts: TOOPieCharts;
begin
  FPieCharts.Document:=FDocument;
  FPieCharts.SheetObj:=FSheetObj;
  Result:=FPieCharts;
end;

function TOOCalcSheet.GetAreaCharts: TOOAreaCharts;
begin
  FAreaCharts.Document:=FDocument;
  FAreaCharts.SheetObj:=FSheetObj;
  Result:=FAreaCharts;
end;

// ******************************************************************************
{ TOOCalcSheets }
// ******************************************************************************

constructor TOOCalcSheets.Create;
begin
  inherited Create;
  FSheet:=TOOCalcSheet.Create;
end;

destructor TOOCalcSheets.Destroy;
begin
  FSheet.Free;
  inherited;
end;

procedure TOOCalcSheets.FreeVariants;
begin
  FDocument:=Unassigned;
  FSheet.FreeVariants;
end;

function TOOCalcSheets.GetCount: integer;
begin
  Result:=FDocument.GetSheets.GetCount;
end;

function TOOCalcSheets.GetSheet(Index: integer): TOOCalcSheet;
begin
  FSheet.SheetObj:=FDocument.GetSheets.GetByIndex(Index);
  FSheet.Document:=FDocument;
  Result:=FSheet;
end;

function TOOCalcSheets.GetActiveSheet: TOOCalcSheet;
begin
  FSheet.SheetObj:=FDocument.GetCurrentController.GetActiveSheet;
  FSheet.Document:=FDocument;
  Result:=FSheet;
end;

function TOOCalcSheets.GetActiveIndex: integer;
var
  i: integer;
  Count: integer;
begin
  Result:=-1;
  Count:=FDocument.GetSheets.GetCount;
  for i:=0 to Count-1 do
  begin
    if FDocument.GetSheets.GetByIndex(i).GetName=FDocument.GetCurrentController.GetActiveSheet.GetName
    then
    begin
      Result:=i;
      Break;
    end;
  end;
end;

procedure TOOCalcSheets.SetActiveIndex(const Value: integer);
begin
  FDocument.GetCurrentController.SetActiveSheet(FDocument.GetSheets.GetByIndex(Value));
end;

function TOOCalcSheets.GetActiveName: string;
begin
  Result:=FDocument.GetCurrentController.GetActiveSheet.GetName;
end;

procedure TOOCalcSheets.SetActiveName(const Value: string);
begin
  FDocument.GetCurrentController.SetActiveSheet(FDocument.GetSheets.GetByName(Value));
end;

procedure TOOCalcSheets.Insert(NewSheetName: string; NewSheetIndex: integer; SetActive: boolean);
begin
  FDocument.GetSheets.InsertNewByName(NewSheetName, NewSheetIndex);
  if SetActive then
    FDocument.GetCurrentController.SetActiveSheet(FDocument.GetSheets.GetByIndex(NewSheetIndex));
end;

procedure TOOCalcSheets.DeleteByIndex(Index: integer);
var
  s: string;
begin
  s:=FDocument.GetSheets.GetByIndex(Index).GetName;
  FDocument.GetSheets.RemoveByName(s);
end;

procedure TOOCalcSheets.DeleteByName(Name: string);
begin
  FDocument.GetSheets.RemoveByName(Name);
end;

function TOOCalcSheets.IsExist(SheetName: string): boolean;
begin
  Result:=FDocument.GetSheets.HasByName(SheetName);
end;

// ******************************************************************************
{ TOOWriter }
// ******************************************************************************

constructor TOOWriter.Create;
begin
  inherited;
  FNewName:='private:factory/swriter';
  FProgType:='writer';
  FTables:=TOOTables.Create;
  FModelCursor:=TOOModelCursor.Create;
  FViewCursor:=TOOViewCursor.Create;
  FPageStyles:=TOOWriterPageStyles.Create;
  FBookmarks:=TOOBookmarks.Create;
  FTextFrames:=TOOTextFrames.Create;
  FGraphicFrames:=TOOGraphicFrames.Create;
  FPrinter:=TOOWriterPrinter.Create;
end;

destructor TOOWriter.Destroy;
begin
  FSD:=Unassigned;
  FPrinter.Free;
  FGraphicFrames.Free;
  FTextFrames.Free;
  FBookmarks.Free;
  FPageStyles.Free;
  FViewCursor.Free;
  FModelCursor.Free;
  FTables.Free;
  inherited;
end;

procedure TOOWriter.FreeVariants;
begin
  inherited;
  FSD:=Unassigned;
  FSF:=Unassigned;
  FTables.FreeVariants;
  FModelCursor.FreeVariants;
  FViewCursor.FreeVariants;
  FPageStyles.FreeVariants;
  FBookmarks.FreeVariants;
  FTextFrames.FreeVariants;
  FGraphicFrames.FreeVariants;
  FPrinter.FreeVariants;
end;

procedure TOOWriter.InsertDocument(FileName: string; InsertPosition: TOpenIP);
var
  FilePath: string;
  Ar: Variant;
begin
  FilePath:=ConvertToURL(FileName);
  Ar:=VarArrayCreate([0, -1], varVariant);
  case InsertPosition of
  oipCurrent:
  begin
  end;
  oipEnd:
  begin
    ModelCursor.GotoEnd(false);
  end;
  oipEndNewPage:
  begin
    ModelCursor.GotoEnd(false);
    ModelCursor.BreakType:=obtPageBefore;
    ModelCursor.GotoEnd(false);
  end;
  end;
  ModelCursor.CursorObj.InsertDocumentFromURL(FilePath, Ar);
  Ar:=Unassigned;
end;

procedure TOOWriter.OpenDocument(FileName: string; OpenMode: TOpenOM; Macro: TOpenMM);
begin
  inherited;
  FSD:=Unassigned;
  FSF:=Unassigned;
  FModelCursor.CursorObj:=FDocument.GetText.CreateTextCursor;
  FViewCursor.CursorObj:=FDocument.GetCurrentController.GetViewCursor;
  FViewCursor.CursorObj.GotoEnd(false);
  FModelCursor.CursorObj.GotoEnd(false);
end;

procedure TOOWriter.SaveDocument(FileName, FileType: string);
var
  FName, FType: string;
  FExt: string;
  Ar, SM: Variant;
  Ext: string;
begin
  SM:=CreateOleObject('com.sun.star.ServiceManager');
  FType:='writer8';
  FExt:='.odt';
  Ext:=UpperCase(ExtractFileExt(FileName));
  if (FileType='Word97')or(Ext='.DOC') then
  begin
    FType:='MS Word 97';
    FExt:='.doc';
  end;
  if (FileType='Writer')or(Ext='.ODT') then
  begin
    FType:='writer8';
    FExt:='.odt';
  end;
  if Ext<>UpperCase(FExt) then
    FName:=FileName+FExt
  else
    FName:=FileName;
  FName:=ConvertToURL(FName);
  Ar:=VarArrayCreate([0, 1], varVariant);
  Ar[0]:=MakePV(SM, 'FilterName', FType);
  Ar[1]:=MakePV(SM, 'Overwrite', true);
  FDocument.StoreAsURL(VarAsType(FName, varOleStr), Ar);
  Ar:=Unassigned;
  SM:=Unassigned;
end;

function TOOWriter.FindFirst(SearchString: string; Param: TOpenSP): boolean;
begin
  FSD:=Unassigned;
  FSF:=Unassigned;
  FSD:=FDocument.CreateSearchDescriptor;
  FSD.SearchString:=VarAsType(SearchString, varOleStr);
  FSD.SearchBackwards:=ospBackwards in Param;
  FSD.SearchCaseSensitive:=ospCaseSensitive in Param;
  FSD.SearchWords:=ospWholeWords in Param;
  FSD.SearchRegularExpression:=ospRegExp in Param;
  FSF:=FDocument.FindFirst(FSD);
  Result:=not VarIsClear(FSF);
  if Result then
    try
      FModelCursor.Sync(FSF);
    except
      //
    end;
end;

function TOOWriter.FindNext: boolean;
begin
  if VarIsClear(FSF) then
    Raise Exception.Create('Method FindNext without FindFirst.');
  FSF:=FDocument.FindNext({$IFDEF FPC} FSF.&End {$ELSE} FSF.End {$ENDIF}, FSD);
  Result:=not VarIsClear(FSF);
  if Result then
    try
      FModelCursor.Sync(FSF);
    except
      //
    end;
end;

procedure TOOWriter.ReplaceAll(SearchString: string; ReplaceString: string; Param: TOpenRP);
var
  RD: Variant;
begin
  RD:=FDocument.CreateReplaceDescriptor;
  RD.SearchString:=VarAsType(SearchString, varOleStr);
  RD.ReplaceString:=VarAsType(ReplaceString, varOleStr);
  RD.SearchWords:=orpWholeWords in Param;
  RD.SearchCaseSensitive:=orpCaseSensitive in Param;
  FDocument.ReplaceAll(RD);
  RD:=Unassigned;
end;

function TOOWriter.GetPageCount: integer;
begin
  FDocument.Refresh;
  Result:=FDocument.GetCurrentController.PageCount;
end;

function TOOWriter.GetPrinter: TOOWriterPrinter;
begin
  FPrinter.Document:=FDocument;
  Result:=FPrinter;
end;

function TOOWriter.GetTables: TOOTables;
begin
  FTables.Document:=FDocument;
  Result:=FTables;
end;

function TOOWriter.GetPageStyles: TOOWriterPageStyles;
begin
  FPageStyles.Document:=FDocument;
  Result:=FPageStyles;
end;

function TOOWriter.GetBookmarks: TOOBookmarks;
begin
  FBookmarks.Document:=FDocument;
  Result:=FBookmarks;
end;

function TOOWriter.GetTextFrames: TOOTextFrames;
begin
  FTextFrames.Document:=FDocument;
  Result:=FTextFrames;
end;

function TOOWriter.GetGraphicFrames: TOOGraphicFrames;
begin
  FGraphicFrames.Document:=FDocument;
  Result:=FGraphicFrames;
end;

function TOOWriter.GetModelCursor: TOOModelCursor;
begin
  FModelCursor.Document:=FDocument;
  Result:=FModelCursor;
end;

function TOOWriter.GetViewCursor: TOOViewCursor;
begin
  FViewCursor.Document:=FDocument;
  Result:=FViewCursor;
end;

// ******************************************************************************
{ TOOTable }
// ******************************************************************************

constructor TOOTable.Create;
begin
  inherited Create;
  FRows:=TOOWriterTableRows.Create;
  FCell:=TOOWriterCell.Create;
  FCellRange:=TOOWriterCellRange.Create;
  FColumns:=TOOWriterTableColumns.Create;
  FTableBorder:=TOOTableBorder.Create;
  FTextTableCursor:=TOOTextTableCursor.Create;
  FMargin:=TOOMargin.Create;
  FOldName:='';
end;

destructor TOOTable.Destroy;
begin
  FMargin.Free;
  FTextTableCursor.Free;
  FTableBorder.Free;
  FCellRange.Free;
  FCell.Free;
  FRows.Free;
  FColumns.Free;
  inherited;
end;

procedure TOOTable.FreeVariants;
begin
  FOldName:='';
  FTableObj:=Unassigned;
  FRows.FreeVariants;
  FColumns.FreeVariants;
  FCell.FreeVariants;
  FCellRange.FreeVariants;
  FTableBorder.FreeVariants;
  FTextTableCursor.FreeVariants;
  FMargin.FreeVariants;
end;

function TOOTable.GetName: string;
begin
  Result:=FTableObj.GetName;
end;

procedure TOOTable.SetName(const Value: string);
begin
  FOldName:='';
  FTableObj.SetName(Value);
end;

function TOOTable.GetRepeatHeadline: boolean;
begin
  Result:=FTableObj.RepeatHeadline;
end;

procedure TOOTable.SetRepeatHeadline(const Value: boolean);
begin
  FTableObj.RepeatHeadline:=Value;
end;

function TOOTable.GetRows: TOOWriterTableRows;
begin
  FRows.ParentTableObj:=FTableObj;
  Result:=FRows;
end;

function TOOTable.GetColumns: TOOWriterTableColumns;
begin
  FColumns.ParentTableObj:=FTableObj;
  Result:=FColumns;
end;

function TOOTable.GetBackColor: TColor;
begin
  Result:=RGB(GetBValue(FTableObj.BackColor), GetGValue(FTableObj.BackColor),
    GetRValue(FTableObj.BackColor));
end;

procedure TOOTable.SetBackColor(const Value: TColor);
begin
  FTableObj.BackColor:=RGB(GetBValue(Value), GetGValue(Value), GetRValue(Value));
end;

function TOOTable.GetBackColorTransparent: boolean;
begin
  Result:=FTableObj.BackTransparent;
end;

procedure TOOTable.SetBackColorTransparent(const Value: boolean);
begin
  FTableObj.BackTransparent:=Value;
end;

function TOOTable.GetCell(Col, Row: integer): TOOWriterCell;
begin
  FCell.CellObj:=FTableObj.GetCellByPosition(Col, Row);
  FCell.TTCursor:=FTableObj.CreateCursorByCellName(NameCR(Col, Row));
  Result:=FCell;
end;

function TOOTable.GetCellByName(CellName: string): TOOWriterCell;
begin
  FCell.CellObj:=FTableObj.GetCellByName(CellName);
  FCell.TTCursor:=FTableObj.CreateCursorByCellName(CellName);
  Result:=FCell;
end;

function TOOTable.GetCellRange(StartCol, StartRow, EndCol, EndRow: integer): TOOWriterCellRange;
begin
  FCellRange.CellObj:=FTableObj.GetCellRangeByPosition(StartCol, StartRow, EndCol, EndRow);
  FCellRange.TTCursor:=FTableObj.CreateCursorByCellName(NameCR(StartCol, StartRow)+':'+
    NameCR(EndCol, EndRow));
  FCellRange.TTCursor.GotoCellByName(NameCR(EndCol, EndRow), true);
  Result:=FCellRange;
end;

function TOOTable.GetCellRangeByName(CellRange: string): TOOWriterCellRange;
begin
  FCellRange.CellObj:=FTableObj.GetCellRangeByName(CellRange);
  FCellRange.TTCursor:=FTableObj.CreateCursorByCellName(CellRange);
  FCellRange.TTCursor.GotoCellByName(Copy(CellRange, Pos(':', CellRange)+1,
    Length(CellRange)), true);
  Result:=FCellRange;
end;

function TOOTable.GetSeparator(Num: integer): integer;
var
  Sep: Variant;
begin
  Sep:=FTableObj.TableColumnSeparators;
  Result:=Sep[Num].Position;
  Sep:=Unassigned;
end;

procedure TOOTable.SetSeparator(Num: integer; const Value: integer);
var
  Sep: Variant;
begin
  Sep:=FTableObj.TableColumnSeparators;
  Sep[Num].Position:=Value;
  FTableObj.TableColumnSeparators:=Sep;
  Sep:=Unassigned;
end;

function TOOTable.GetShadowFormat: TOpenShadowFormat;
var
  SF: Variant;
begin
  SF:=FTableObj.ShadowFormat;
  Result.Location:=SF.Location;
  Result.ShadowWidth:=SF.ShadowWidth;
  Result.IsTransparent:=SF.IsTransparent;
  Result.Color:=RGB(GetBValue(SF.Color), GetGValue(SF.Color), GetRValue(SF.Color));
  SF:=Unassigned;
end;

procedure TOOTable.SetShadowFormat(const Value: TOpenShadowFormat);
var
  SF: Variant;
  SM: Variant;
begin
  SM:=CreateOleObject('com.sun.star.ServiceManager');
  SF:=SM.Bridge_GetStruct('com.sun.star.table.ShadowFormat');
  SF.Location:=Ord(Value.Location);
  SF.ShadowWidth:=Value.ShadowWidth;
  SF.IsTransparent:=Value.IsTransparent;
  SF.Color:=RGB(GetBValue(Value.Color), GetGValue(Value.Color), GetRValue(Value.Color));
  FTableObj.ShadowFormat:=SF;
  SF:=Unassigned;
  SM:=Unassigned;
end;

function TOOTable.GetTableBorder: TOOTableBorder;
begin
  FTableBorder.TableBorderObj:=FTableObj;
  Result:=FTableBorder;
end;

function TOOTable.GetTextTableCursor: TOOTextTableCursor;
begin
  if FOldName=FTableObj.GetName then
  begin
    Result:=FTextTableCursor;
  end
  else
  begin
    FTextTableCursor.CursorObj:=FTableObj.CreateCursorByCellName('A1');
    FOldName:=FTableObj.GetName;
    Result:=FTextTableCursor;
  end;
end;

function TOOTable.GetMargin: TOOMargin;
begin
  FMargin.MarginObj:=FTableObj;
  Result:=FMargin;
end;

function TOOTable.GetBreakType: TOpenBT;
begin
  Result:=FTableObj.BreakType;
end;

procedure TOOTable.SetBreakType(const Value: TOpenBT);
begin
  FTableObj.BreakType:=Ord(Value);
end;

function TOOTable.GetHoriOrient: TOpenFHO;
begin
  Result:=FTableObj.HoriOrient;
end;

procedure TOOTable.SetHoriOrient(const Value: TOpenFHO);
begin
  FTableObj.HoriOrient:=Ord(Value);
end;

function TOOTable.GetKeepTogether: boolean;
begin
  Result:=FTableObj.KeepTogether;
end;

procedure TOOTable.SetKeepTogether(const Value: boolean);
begin
  FTableObj.KeepTogether:=Value;
end;

function TOOTable.GetSplit: boolean;
begin
  Result:=FTableObj.Split;
end;

procedure TOOTable.SetSplit(const Value: boolean);
begin
  FTableObj.Split:=Value;
end;

function TOOTable.GetPageNumberOffset: integer;
begin
  Result:=FTableObj.PageNumberOffset;
end;

procedure TOOTable.SetPageNumberOffset(const Value: integer);
begin
  FTableObj.PageNumberOffset:=Value;
end;

function TOOTable.GetPageDescName: string;
begin
  Result:=FTableObj.PageDescName;
end;

procedure TOOTable.SetPageDescName(const Value: string);
begin
  FTableObj.PageDescName:=Value;
end;

function TOOTable.GetHeaderRowCount: integer;
begin
  Result:=FTableObj.HeaderRowCount;
end;

procedure TOOTable.SetHeaderRowCount(const Value: integer);
begin
  FTableObj.HeaderRowCount:=Value;
end;

function TOOTable.GetWidth: integer;
begin
  Result:=FTableObj.Width;
end;

procedure TOOTable.SetWidth(const Value: integer);
begin
  FTableObj.Width:=Value;
end;

function TOOTable.GetRelativeWidth: integer;
begin
  Result:=FTableObj.RelativeWidth;
end;

procedure TOOTable.SetRelativeWidth(const Value: integer);
begin
  FTableObj.RelativeWidth:=Value;
end;

function TOOTable.GetIsWidthRelative: boolean;
begin
  Result:=FTableObj.IsWidthRelative;
end;

procedure TOOTable.SetIsWidthRelative(const Value: boolean);
begin
  FTableObj.IsWidthRelative:=Value;
end;

// ******************************************************************************
{ TOOTables }
// ******************************************************************************

constructor TOOTables.Create;
begin
  inherited Create;
  FTable:=TOOTable.Create;
end;

destructor TOOTables.Destroy;
begin
  FTable.Free;
  inherited;
end;

procedure TOOTables.FreeVariants;
begin
  FDocument:=Unassigned;
  FTable.FreeVariants;
end;

function TOOTables.GetCount: integer;
begin
  Result:=FDocument.GetTextTables.Count;
end;

function TOOTables.GetCurrent: TOOTable;
begin
  Result:=GetTableByName(FDocument.GetTextTables.GetName);
end;

function TOOTables.GetTable(Index: integer): TOOTable;
begin
  FTable.TableObj:=FDocument.GetTextTables.GetByIndex(Index);
  Result:=FTable;
end;

function TOOTables.GetTableByName(TableName: string): TOOTable;
begin
  FTable.TableObj:=FDocument.GetTextTables.GetByName(TableName);
  Result:=FTable;
end;

procedure TOOTables.Insert(Cols, Rows: integer; TableName: string; Cursor: TOOTextCursor);
var
  Tbl: Variant;
begin
  if Cursor.CursorType=octOther then
    Raise Exception.Create('Cursor must be a Writer property.');
  Tbl:=FDocument.CreateInstance('com.sun.star.text.TextTable');
  Tbl.Initialize(Rows, Cols);
  FDocument.Text.InsertTextContent(Cursor.CursorObj, Tbl, false);
  if TableName<>'' then
    Tbl.SetName(TableName);
  Tbl:=Unassigned;
end;

function TOOTables.IsExist(TableName: string): boolean;
begin
  Result:=FDocument.GetTextTables.HasByName(TableName);
end;

procedure TOOTables.DeleteByIndex(Index: integer);
begin
  try
    FDocument.Text.RemoveTextContent(FDocument.GetTextTables.GetByIndex(Index));
  except
    Raise Exception.Create('Table index out of bounds.');
  end;
end;

procedure TOOTables.DeleteByName(TableName: string);
begin
  try
    FDocument.Text.RemoveTextContent(FDocument.GetTextTables.GetByName(TableName));
  except
    Raise Exception.Create('Table with specified name not exist.');
  end;
end;

// ******************************************************************************
{ TOOWriterTableRows }
// ******************************************************************************

constructor TOOWriterTableRows.Create;
begin
  inherited Create;
  FRow:=TOOWriterTableRow.Create;
end;

destructor TOOWriterTableRows.Destroy;
begin
  FRow.Free;
  inherited;
end;

procedure TOOWriterTableRows.FreeVariants;
begin
  FParentTableObj:=Unassigned;
  FRow.FreeVariants;
end;

function TOOWriterTableRows.GetCount: integer;
begin
  Result:=FParentTableObj.GetRows.Count;
end;

function TOOWriterTableRows.GetRow(Index: integer): TOOWriterTableRow;
begin
  FRow.RowObj:=FParentTableObj.GetRows.GetByIndex(Index);
  Result:=FRow;
end;

procedure TOOWriterTableRows.Append(Count: integer);
begin
  FParentTableObj.GetRows.InsertByIndex(FParentTableObj.GetRows.Count, Count);
end;

procedure TOOWriterTableRows.Insert(Index, Count: integer);
begin
  if Count>0 then
    FParentTableObj.GetRows.InsertByIndex(Index, Count);
end;

procedure TOOWriterTableRows.Delete(Index, Count: integer);
begin
  if Count>0 then
    FParentTableObj.GetRows.RemoveByIndex(Index, Count);
end;

// ******************************************************************************
{ TOOWriterTableColumns }
// ******************************************************************************

procedure TOOWriterTableColumns.FreeVariants;
begin
  FParentTableObj:=Unassigned;
end;

function TOOWriterTableColumns.GetCount: integer;
begin
  Result:=FParentTableObj.GetColumns.Count;
end;

procedure TOOWriterTableColumns.Append(Count: integer);
begin
  FParentTableObj.GetColumns.InsertByIndex(FParentTableObj.GetColumns.Count, Count);
end;

procedure TOOWriterTableColumns.Insert(Index, Count: integer);
begin
  if Count>0 then
    FParentTableObj.GetColumns.InsertByIndex(Index, Count);
end;

procedure TOOWriterTableColumns.Delete(Index, Count: integer);
begin
  if Count>0 then
    FParentTableObj.GetColumns.RemoveByIndex(Index, Count);
end;

// ******************************************************************************
{ TOOWriterTableRow }
// ******************************************************************************

procedure TOOWriterTableRow.FreeVariants;
begin
  FRowObj:=Unassigned;
end;

function TOOWriterTableRow.GetBackColor: TColor;
var
  i: integer;
begin
  i:=FRowObj.BackColor;
  Result:=RGB(GetBValue(i), GetGValue(i), GetRValue(i));
end;

procedure TOOWriterTableRow.SetBackColor(const Value: TColor);
begin
  FRowObj.BackColor:=RGB(GetBValue(Value), GetGValue(Value), GetRValue(Value));
end;

function TOOWriterTableRow.GetBackColorTransparent: boolean;
begin
  Result:=FRowObj.BackTransparent;
end;

procedure TOOWriterTableRow.SetBackColorTransparent(const Value: boolean);
begin
  FRowObj.BackTransparent:=Value;
end;

function TOOWriterTableRow.GetHeight: integer;
begin
  Result:=FRowObj.Height;
end;

procedure TOOWriterTableRow.SetHeight(const Value: integer);
begin
  FRowObj.Height:=Value
end;

function TOOWriterTableRow.GetAutoHeight: boolean;
begin
  Result:=FRowObj.IsAutoHeight;
end;

procedure TOOWriterTableRow.SetAutoHeight(const Value: boolean);
begin
  FRowObj.IsAutoHeight:=Value;
end;

function TOOWriterTableRow.GetSeparator(Num: integer): integer;
var
  Sep: Variant;
begin
  Sep:=FRowObj.TableColumnSeparators;
  Result:=Sep[Num].Position;
  Sep:=Unassigned;
end;

procedure TOOWriterTableRow.SetSeparator(Num: integer; const Value: integer);
var
  Sep: Variant;
begin
  Sep:=FRowObj.TableColumnSeparators;
  Sep[Num].Position:=Value;
  FRowObj.TableColumnSeparators:=Sep;
  Sep:=Unassigned;
end;

// ******************************************************************************
{ TOOWriterCell }
// ******************************************************************************

function TOOWriterCell.GetDataType: TOpenDT;
begin
  Result:=FCellObj.{$IFDEF FPC}&Type{$ELSE} Type {$ENDIF};
end;

function TOOWriterCell.GetAsText: string;
begin
  Result:=FCellObj.GetString;
end;

procedure TOOWriterCell.SetAsText(const Value: string);
begin
  FCellObj.SetString(Value);
end;

function TOOWriterCell.GetAsDate: TDateTime;
begin
  Result:=FCellObj.GetValue;
end;

procedure TOOWriterCell.SetAsDate(const Value: TDateTime);
begin
  FCellObj.SetValue(Value);
end;

function TOOWriterCell.GetAsFormula: string;
begin
  Result:=FCellObj.GetFormula;
end;

procedure TOOWriterCell.SetAsFormula(const Value: string);
begin
  FCellObj.SetFormula(Value);
end;

function TOOWriterCell.GetAsNumber: double;
begin
  Result:=FCellObj.GetValue;
end;

procedure TOOWriterCell.SetAsNumber(const Value: double);
begin
  FCellObj.SetValue(Value);
end;

// ******************************************************************************
{ TOOViewCursor }
// ******************************************************************************

procedure TOOViewCursor.SyncFrom(Cursor: TOOModelCursor);
begin
  if Cursor.CursorType=octOther then
    Raise Exception.Create('Cursor must be a Writer property.');
  FCursorObj.GotoRange(Cursor.CursorObj.GetStart, false);
  FCursorObj.GotoRange(Cursor.CursorObj.GetEnd, true);
end;

function TOOViewCursor.GetCell: Variant;
begin
  If FCursorType=octOther then
    Raise Exception.Create('Cursor must be a Writer property.');
  Result:=FCursorObj.Cell;
end;

function TOOViewCursor.GetPageNumber: integer;
begin
  Result:=FCursorObj.GetPage;
end;

function TOOViewCursor.GetPageStyleName: string;
begin
  Result:=FCursorObj.PageStyleName;
end;

function TOOViewCursor.GetTable: Variant;
Begin
  If FCursorType=octOther then
    Raise Exception.Create('Cursor must be a Writer property.');
  Result:=FCursorObj.TextTable;
end;

procedure TOOViewCursor.SetPageStyleName(const Value: string);
begin
  FCursorObj.PageDescName:=Value;
end;

function TOOViewCursor.JumpToEndOfPage: boolean;
begin
  Result:=FCursorObj.JumpToEndOfPage;
end;

function TOOViewCursor.JumpToFirstPage: boolean;
begin
  Result:=FCursorObj.JumpToFirstPage;
end;

function TOOViewCursor.JumpToLastPage: boolean;
begin
  Result:=FCursorObj.JumpToLastPage;
end;

function TOOViewCursor.JumpToNextPage: boolean;
begin
  Result:=FCursorObj.JumpToNextPage;
end;

function TOOViewCursor.JumpToPage(PageNumber: integer): boolean;
begin
  Result:=FCursorObj.JumpToPage(PageNumber);
end;

function TOOViewCursor.JumpToPreviousPage: boolean;
begin
  Result:=FCursorObj.JumpToPreviousPage;
end;

function TOOViewCursor.JumpToStartOfPage: boolean;
begin
  Result:=FCursorObj.JumpToStartOfPage;
end;

function TOOViewCursor.IsAtStartOfLine: boolean;
begin
  Result:=FCursorObj.IsAtStartOfLine;
end;

function TOOViewCursor.IsAtEndOfLine: boolean;
begin
  Result:=FCursorObj.IsAtEndOfLine;
end;

procedure TOOViewCursor.GotoStartOfLine(Expand: boolean);
begin
  FCursorObj.GotoStartOfLine(Expand);
end;

procedure TOOViewCursor.GotoEndOfLine(Expand: boolean);
begin
  FCursorObj.GotoEndOfLine(Expand);
end;

// ******************************************************************************
{ TOOPageStyles }
// ******************************************************************************

procedure TOOPageStyles.FreeVariants;
begin
  FDocument:=Unassigned;
end;

function TOOPageStyles.GetCount: integer;
begin
  Result:=FDocument.StyleFamilies.GetByName('PageStyles').Count;
end;

procedure TOOPageStyles.Append(StyleName: string);
var
  PS: Variant;
begin
  if StyleName<>'' then
  begin
    PS:=FDocument.CreateInstance('com.sun.star.style.PageStyle');
    PS.SetName(StyleName);
    FDocument.StyleFamilies.GetByName('PageStyles').InsertByName(StyleName, PS);
    PS:=Unassigned;
  end
  else
    Raise Exception.Create('Cannot append new page style with empty name.');
end;

procedure TOOPageStyles.DeleteByName(StyleName: string);
begin
  if FDocument.StyleFamilies.GetByName('PageStyles').HasByName(StyleName) then
  begin
    if FDocument.StyleFamilies.GetByName('PageStyles').GetByName(StyleName).IsUserDefined then
      FDocument.StyleFamilies.GetByName('PageStyles').RemoveByName(StyleName)
    else
      Raise Exception.Create('Specified page style is the default style.');
  end
  else
    Raise Exception.Create('Page style with specified name not exist.');
end;

procedure TOOPageStyles.DeleteByIndex(Index: integer);
begin
  if (Index>-1)and(Index<FDocument.StyleFamilies.GetByName('PageStyles').Count) then
  begin
    if FDocument.StyleFamilies.GetByName('PageStyles').GetByIndex(Index).IsUserDefined then
      FDocument.StyleFamilies.GetByName('PageStyles').RemoveByIndex(Index)
    else
      Raise Exception.Create('Specified page style is the default style.');
  end
  else
    Raise Exception.Create('Page style index out of bounds.');
end;

// ******************************************************************************
{ TOOCalcPageStyles }
// ******************************************************************************

constructor TOOCalcPageStyles.Create;
begin
  inherited Create;
  FStyle:=TOOCalcPageStyle.Create;
end;

destructor TOOCalcPageStyles.Destroy;
begin
  FStyle.Free;
  inherited;
end;

procedure TOOCalcPageStyles.FreeVariants;
begin
  inherited;
  FStyle.FreeVariants;
end;

function TOOCalcPageStyles.GetPageStyle(Index: integer): TOOCalcPageStyle;
begin
  FStyle.Document:=FDocument;
  FStyle.StyleObj:=FDocument.StyleFamilies.GetByName('PageStyles').GetByIndex(Index);
  Result:=FStyle;
end;

function TOOCalcPageStyles.GetPageStyleByName(StyleName: string): TOOCalcPageStyle;
begin
  FStyle.Document:=FDocument;
  FStyle.StyleObj:=FDocument.StyleFamilies.GetByName('PageStyles').GetByName(StyleName);
  Result:=FStyle;
end;

// ******************************************************************************
{ TOOWriterPageStyles }
// ******************************************************************************

constructor TOOWriterPageStyles.Create;
begin
  inherited Create;
  FStyle:=TOOWriterPageStyle.Create;
end;

destructor TOOWriterPageStyles.Destroy;
begin
  FStyle.Free;
  inherited;
end;

procedure TOOWriterPageStyles.FreeVariants;
begin
  inherited;
  FStyle.FreeVariants;
end;

function TOOWriterPageStyles.GetPageStyle(Index: integer): TOOWriterPageStyle;
begin
  FStyle.Document:=FDocument;
  FStyle.StyleObj:=FDocument.StyleFamilies.GetByName('PageStyles').GetByIndex(Index);
  Result:=FStyle;
end;

function TOOWriterPageStyles.GetPageStyleByName(StyleName: string): TOOWriterPageStyle;
begin
  FStyle.Document:=FDocument;
  FStyle.StyleObj:=FDocument.StyleFamilies.GetByName('PageStyles').GetByName(StyleName);
  Result:=FStyle;
end;

// ******************************************************************************
{ TOOPageStyle }
// ******************************************************************************

constructor TOOPageStyle.Create;
begin
  inherited Create;
  FBorder:=TOOHeaderBorderDistance.Create;
  FMargin:=TOOMargin.Create;
end;

destructor TOOPageStyle.Destroy;
begin
  FMargin.Free;
  FBorder.Free;
  inherited;
end;

procedure TOOPageStyle.FreeVariants;
begin
  FStyleObj:=Unassigned;
  FDocument:=Unassigned;
  FBorder.FreeVariants;
  FMargin.FreeVariants;
end;

function TOOPageStyle.GetName: string;
begin
  Result:=FStyleObj.GetName;
end;

procedure TOOPageStyle.SetName(const Value: string);
begin
  if FStyleObj.IsUserDefined then
    FStyleObj.SetName(Value)
  else
    Raise Exception.Create('Specified page style is the default style.');
end;

function TOOPageStyle.GetIsUserDefined: boolean;
begin
  Result:=FStyleObj.IsUserDefined;
end;

function TOOPageStyle.GetIsInUse: boolean;
begin
  Result:=FStyleObj.IsInUse;
end;

function TOOPageStyle.GetLandscape: boolean;
begin
  Result:=FStyleObj.IsLandscape;
end;

procedure TOOPageStyle.SetLandscape(const Value: boolean);
var
  Old: boolean;
  W, H: integer;
begin
  Old:=FStyleObj.IsLandscape;
  if Old<>Value then
  begin
    W:=FStyleObj.Width;
    H:=FStyleObj.Height;
    FStyleObj.Width:=H;
    FStyleObj.Height:=W;
    FStyleObj.IsLandscape:=Value;
  end;
end;

function TOOPageStyle.GetBackColor: TColor;
var
  i: TColor;
begin
  i:=FStyleObj.BackColor;
  Result:=RGB(GetBValue(i), GetGValue(i), GetRValue(i));
end;

procedure TOOPageStyle.SetBackColor(const Value: TColor);
begin
  FStyleObj.BackColor:=RGB(GetBValue(Value), GetGValue(Value), GetRValue(Value));
end;

function TOOPageStyle.GetBackColorTransparent: boolean;
begin
  Result:=FStyleObj.BackTransparent;
end;

procedure TOOPageStyle.SetBackColorTransparent(const Value: boolean);
begin
  FStyleObj.BackTransparent:=Value;
end;

function TOOPageStyle.GetPageStyleLayout: TOpenPL;
begin
  Result:=FStyleObj.PageStyleLayout;
end;

procedure TOOPageStyle.SetPageStyleLayout(const Value: TOpenPL);
begin
  FStyleObj.PageStyleLayout:=Ord(Value);
end;

function TOOPageStyle.GetDistance: integer;
begin
  Result:=FStyleObj.Distance;
end;

procedure TOOPageStyle.SetDistance(const Value: integer);
begin
  FStyleObj.Distance:=Value;
end;

function TOOPageStyle.GetWidth: integer;
begin
  Result:=FStyleObj.Width;
end;

procedure TOOPageStyle.SetWidth(const Value: integer);
begin
  FStyleObj.Width:=Value;
end;

function TOOPageStyle.GetHeight: integer;
begin
  Result:=FStyleObj.Height;
end;

procedure TOOPageStyle.SetHeight(const Value: integer);
begin
  FStyleObj.Height:=Value;
end;

function TOOPageStyle.GetSize: TOpenSize;
var
  Sz: Variant;
begin
  Sz:=FStyleObj.Size;
  Result.Width:=Sz.Width;
  Result.Height:=Sz.Height;
  Sz:=Unassigned;
end;

procedure TOOPageStyle.SetSize(const Value: TOpenSize);
var
  Sz: Variant;
  SM: Variant;
begin
  SM:=CreateOleObject('com.sun.star.ServiceManager');
  Sz:=SM.Bridge_GetStruct('com.sun.star.awt.Size');
  Sz.Width:=Value.Width;
  Sz.Height:=Value.Height;
  FStyleObj.Size:=Sz;
  Sz:=Unassigned;
  SM:=Unassigned;
end;

function TOOPageStyle.GetShadowFormat: TOpenShadowFormat;
var
  SF: Variant;
begin
  SF:=FStyleObj.ShadowFormat;
  Result.Location:=SF.Location;
  Result.ShadowWidth:=SF.ShadowWidth;
  Result.IsTransparent:=SF.IsTransparent;
  Result.Color:=RGB(GetBValue(SF.Color), GetGValue(SF.Color), GetRValue(SF.Color));
  SF:=Unassigned;
end;

procedure TOOPageStyle.SetShadowFormat(const Value: TOpenShadowFormat);
var
  SF: Variant;
  SM: Variant;
begin
  SM:=CreateOleObject('com.sun.star.ServiceManager');
  SF:=SM.Bridge_GetStruct('com.sun.star.table.ShadowFormat');
  SF.Location:=Ord(Value.Location);
  SF.ShadowWidth:=Value.ShadowWidth;
  SF.IsTransparent:=Value.IsTransparent;
  SF.Color:=RGB(GetBValue(Value.Color), GetGValue(Value.Color), GetRValue(Value.Color));
  FStyleObj.ShadowFormat:=SF;
  SF:=Unassigned;
  SM:=Unassigned;
end;

function TOOPageStyle.GetHeaderBackColor: TColor;
var
  i: TColor;
begin
  i:=FStyleObj.HeaderBackColor;
  Result:=RGB(GetBValue(i), GetGValue(i), GetRValue(i));
end;

procedure TOOPageStyle.SetHeaderBackColor(const Value: TColor);
begin
  FStyleObj.HeaderBackColor:=RGB(GetBValue(Value), GetGValue(Value), GetRValue(Value));
end;

function TOOPageStyle.GetHeaderBackColorTransparent: boolean;
begin
  Result:=FStyleObj.HeaderBackTransparent;
end;

procedure TOOPageStyle.SetHeaderBackColorTransparent(const Value: boolean);
begin
  FStyleObj.HeaderBackTransparent:=Value;
end;

function TOOPageStyle.GetHeaderLeftMargin: integer;
begin
  Result:=FStyleObj.HeaderLeftMargin;
end;

procedure TOOPageStyle.SetHeaderLeftMargin(const Value: integer);
begin
  FStyleObj.HeaderLeftMargin:=Value;
end;

function TOOPageStyle.GetHeaderRightMargin: integer;
begin
  Result:=FStyleObj.HeaderRightMargin;
end;

procedure TOOPageStyle.SetHeaderRightMargin(const Value: integer);
begin
  FStyleObj.HeaderRightMargin:=Value;
end;

function TOOPageStyle.GetHeaderLeftBorder: TOpenBorderLine;
var
  i: TColor;
begin
  i:=FStyleObj.HeaderLeftBorder.Color;
  Result.Color:=RGB(GetBValue(i), GetGValue(i), GetRValue(i));
  Result.InnerLineWidth:=FStyleObj.HeaderLeftBorder.InnerLineWidth;
  Result.OuterLineWidth:=FStyleObj.HeaderLeftBorder.OuterLineWidth;
  Result.LineDistance:=FStyleObj.HeaderLeftBorder.LineDistance;
end;

procedure TOOPageStyle.SetHeaderLeftBorder(const Value: TOpenBorderLine);
var
  BL: Variant;
  SM: Variant;
begin
  SM:=CreateOleObject('com.sun.star.ServiceManager');
  BL:=SM.Bridge_GetStruct('com.sun.star.table.BorderLine');
  BL.Color:=RGB(GetBValue(Value.Color), GetGValue(Value.Color), GetRValue(Value.Color));
  BL.InnerLineWidth:=Value.InnerLineWidth;
  BL.OuterLineWidth:=Value.OuterLineWidth;
  BL.LineDistance:=Value.LineDistance;
  FStyleObj.HeaderLeftBorder:=BL;
  BL:=Unassigned;
  SM:=Unassigned;
end;

function TOOPageStyle.GetHeaderRightBorder: TOpenBorderLine;
var
  i: TColor;
begin
  i:=FStyleObj.HeaderRightBorder.Color;
  Result.Color:=RGB(GetBValue(i), GetGValue(i), GetRValue(i));
  Result.InnerLineWidth:=FStyleObj.HeaderRightBorder.InnerLineWidth;
  Result.OuterLineWidth:=FStyleObj.HeaderRightBorder.OuterLineWidth;
  Result.LineDistance:=FStyleObj.HeaderRightBorder.LineDistance;
end;

procedure TOOPageStyle.SetHeaderRightBorder(const Value: TOpenBorderLine);
var
  BL: Variant;
  SM: Variant;
begin
  SM:=CreateOleObject('com.sun.star.ServiceManager');
  BL:=SM.Bridge_GetStruct('com.sun.star.table.BorderLine');
  BL.Color:=RGB(GetBValue(Value.Color), GetGValue(Value.Color), GetRValue(Value.Color));
  BL.InnerLineWidth:=Value.InnerLineWidth;
  BL.OuterLineWidth:=Value.OuterLineWidth;
  BL.LineDistance:=Value.LineDistance;
  FStyleObj.HeaderRightBorder:=BL;
  BL:=Unassigned;
  SM:=Unassigned;
end;

function TOOPageStyle.GetHeaderTopBorder: TOpenBorderLine;
var
  i: TColor;
begin
  i:=FStyleObj.HeaderTopBorder.Color;
  Result.Color:=RGB(GetBValue(i), GetGValue(i), GetRValue(i));
  Result.InnerLineWidth:=FStyleObj.HeaderTopBorder.InnerLineWidth;
  Result.OuterLineWidth:=FStyleObj.HeaderTopBorder.OuterLineWidth;
  Result.LineDistance:=FStyleObj.HeaderTopBorder.LineDistance;
end;

procedure TOOPageStyle.SetHeaderTopBorder(const Value: TOpenBorderLine);
var
  BL: Variant;
  SM: Variant;
begin
  SM:=CreateOleObject('com.sun.star.ServiceManager');
  BL:=SM.Bridge_GetStruct('com.sun.star.table.BorderLine');
  BL.Color:=RGB(GetBValue(Value.Color), GetGValue(Value.Color), GetRValue(Value.Color));
  BL.InnerLineWidth:=Value.InnerLineWidth;
  BL.OuterLineWidth:=Value.OuterLineWidth;
  BL.LineDistance:=Value.LineDistance;
  FStyleObj.HeaderTopBorder:=BL;
  BL:=Unassigned;
  SM:=Unassigned;
end;

function TOOPageStyle.GetHeaderBottomBorder: TOpenBorderLine;
var
  i: TColor;
begin
  i:=FStyleObj.HeaderBottomBorder.Color;
  Result.Color:=RGB(GetBValue(i), GetGValue(i), GetRValue(i));
  Result.InnerLineWidth:=FStyleObj.HeaderBottomBorder.InnerLineWidth;
  Result.OuterLineWidth:=FStyleObj.HeaderBottomBorder.OuterLineWidth;
  Result.LineDistance:=FStyleObj.HeaderBottomBorder.LineDistance;
end;

procedure TOOPageStyle.SetHeaderBottomBorder(const Value: TOpenBorderLine);
var
  BL: Variant;
  SM: Variant;
begin
  SM:=CreateOleObject('com.sun.star.ServiceManager');
  BL:=SM.Bridge_GetStruct('com.sun.star.table.BorderLine');
  BL.Color:=RGB(GetBValue(Value.Color), GetGValue(Value.Color), GetRValue(Value.Color));
  BL.InnerLineWidth:=Value.InnerLineWidth;
  BL.OuterLineWidth:=Value.OuterLineWidth;
  BL.LineDistance:=Value.LineDistance;
  FStyleObj.HeaderBottomBorder:=BL;
  BL:=Unassigned;
  SM:=Unassigned;
end;

function TOOPageStyle.GetHeaderLeftDistance: integer;
begin
  Result:=FStyleObj.HeaderLeftDistance;
end;

procedure TOOPageStyle.SetHeaderLeftDistance(const Value: integer);
begin
  FStyleObj.HeaderLeftDistance:=Value;
end;

function TOOPageStyle.GetHeaderRightDistance: integer;
begin
  Result:=FStyleObj.HeaderRightDistance;
end;

procedure TOOPageStyle.SetHeaderRightDistance(const Value: integer);
begin
  FStyleObj.HeaderRightDistance:=Value;
end;

function TOOPageStyle.GetHeaderTopDistance: integer;
begin
  Result:=FStyleObj.HeaderTopDistance;
end;

procedure TOOPageStyle.SetHeaderTopDistance(const Value: integer);
begin
  FStyleObj.HeaderTopDistance:=Value;
end;

function TOOPageStyle.GetHeaderBottomDistance: integer;
begin
  Result:=FStyleObj.HeaderBottomDistance;
end;

procedure TOOPageStyle.SetHeaderBottomDistance(const Value: integer);
begin
  FStyleObj.HeaderBottomDistance:=Value;
end;

function TOOPageStyle.GetHeaderDistance: integer;
begin
  Result:=FStyleObj.HeaderDistance;
end;

procedure TOOPageStyle.SetHeaderDistance(const Value: integer);
begin
  FStyleObj.HeaderDistance:=Value;
end;

function TOOPageStyle.GetHeaderBodyDistance: integer;
begin
  Result:=FStyleObj.HeaderBodyDistance;
end;

procedure TOOPageStyle.SetHeaderBodyDistance(const Value: integer);
begin
  FStyleObj.HeaderBodyDistance:=Value;
end;

function TOOPageStyle.GetHeaderShadowFormat: TOpenShadowFormat;
var
  SF: Variant;
begin
  SF:=FStyleObj.HeaderShadowFormat;
  Result.Location:=SF.Location;
  Result.ShadowWidth:=SF.ShadowWidth;
  Result.IsTransparent:=SF.IsTransparent;
  Result.Color:=RGB(GetBValue(SF.Color), GetGValue(SF.Color), GetRValue(SF.Color));
  SF:=Unassigned;
end;

procedure TOOPageStyle.SetHeaderShadowFormat(const Value: TOpenShadowFormat);
var
  SF: Variant;
  SM: Variant;
begin
  SM:=CreateOleObject('com.sun.star.ServiceManager');
  SF:=SM.Bridge_GetStruct('com.sun.star.table.ShadowFormat');
  SF.Location:=Ord(Value.Location);
  SF.ShadowWidth:=Value.ShadowWidth;
  SF.IsTransparent:=Value.IsTransparent;
  SF.Color:=RGB(GetBValue(Value.Color), GetGValue(Value.Color), GetRValue(Value.Color));
  FStyleObj.HeaderShadowFormat:=SF;
  SF:=Unassigned;
  SM:=Unassigned;
end;

function TOOPageStyle.GetHeaderHeight: integer;
begin
  Result:=FStyleObj.HeaderHeight;
end;

procedure TOOPageStyle.SetHeaderHeight(const Value: integer);
begin
  FStyleObj.HeaderHeight:=Value;
end;

function TOOPageStyle.GetHeaderIsDynamicHeight: boolean;
begin
  Result:=FStyleObj.HeaderIsDynamicHeight;
end;

procedure TOOPageStyle.SetHeaderIsDynamicHeight(const Value: boolean);
begin
  FStyleObj.HeaderIsDynamicHeight:=Value;
end;

function TOOPageStyle.GetHeaderIsShared: boolean;
begin
  Result:=FStyleObj.HeaderIsShared;
end;

procedure TOOPageStyle.SetHeaderIsShared(const Value: boolean);
begin
  FStyleObj.HeaderIsShared:=Value;
end;

function TOOPageStyle.GetHeaderIsOn: boolean;
begin
  Result:=FStyleObj.HeaderIsOn;
end;

procedure TOOPageStyle.SetHeaderIsOn(const Value: boolean);
begin
  FStyleObj.HeaderIsOn:=Value;
end;

function TOOPageStyle.GetFooterBackColor: TColor;
var
  i: TColor;
begin
  i:=FStyleObj.FooterBackColor;
  Result:=RGB(GetBValue(i), GetGValue(i), GetRValue(i));
end;

procedure TOOPageStyle.SetFooterBackColor(const Value: TColor);
begin
  FStyleObj.FooterBackColor:=RGB(GetBValue(Value), GetGValue(Value), GetRValue(Value));
end;

function TOOPageStyle.GetFooterBackColorTransparent: boolean;
begin
  Result:=FStyleObj.FooterBackTransparent;
end;

procedure TOOPageStyle.SetFooterBackColorTransparent(const Value: boolean);
begin
  FStyleObj.FooterBackTransparent:=Value;
end;

function TOOPageStyle.GetFooterLeftMargin: integer;
begin
  Result:=FStyleObj.FooterLeftMargin;
end;

procedure TOOPageStyle.SetFooterLeftMargin(const Value: integer);
begin
  FStyleObj.FooterLeftMargin:=Value;
end;

function TOOPageStyle.GetFooterRightMargin: integer;
begin
  Result:=FStyleObj.FooterRightMargin;
end;

procedure TOOPageStyle.SetFooterRightMargin(const Value: integer);
begin
  FStyleObj.FooterRightMargin:=Value;
end;

function TOOPageStyle.GetFooterLeftBorder: TOpenBorderLine;
var
  i: TColor;
begin
  i:=FStyleObj.FooterLeftBorder.Color;
  Result.Color:=RGB(GetBValue(i), GetGValue(i), GetRValue(i));
  Result.InnerLineWidth:=FStyleObj.FooterLeftBorder.InnerLineWidth;
  Result.OuterLineWidth:=FStyleObj.FooterLeftBorder.OuterLineWidth;
  Result.LineDistance:=FStyleObj.FooterLeftBorder.LineDistance;
end;

procedure TOOPageStyle.SetFooterLeftBorder(const Value: TOpenBorderLine);
var
  BL: Variant;
  SM: Variant;
begin
  SM:=CreateOleObject('com.sun.star.ServiceManager');
  BL:=SM.Bridge_GetStruct('com.sun.star.table.BorderLine');
  BL.Color:=RGB(GetBValue(Value.Color), GetGValue(Value.Color), GetRValue(Value.Color));
  BL.InnerLineWidth:=Value.InnerLineWidth;
  BL.OuterLineWidth:=Value.OuterLineWidth;
  BL.LineDistance:=Value.LineDistance;
  FStyleObj.FooterLeftBorder:=BL;
  BL:=Unassigned;
  SM:=Unassigned;
end;

function TOOPageStyle.GetFooterRightBorder: TOpenBorderLine;
var
  i: TColor;
begin
  i:=FStyleObj.FooterRightBorder.Color;
  Result.Color:=RGB(GetBValue(i), GetGValue(i), GetRValue(i));
  Result.InnerLineWidth:=FStyleObj.FooterRightBorder.InnerLineWidth;
  Result.OuterLineWidth:=FStyleObj.FooterRightBorder.OuterLineWidth;
  Result.LineDistance:=FStyleObj.FooterRightBorder.LineDistance;
end;

procedure TOOPageStyle.SetFooterRightBorder(const Value: TOpenBorderLine);
var
  BL: Variant;
  SM: Variant;
begin
  SM:=CreateOleObject('com.sun.star.ServiceManager');
  BL:=SM.Bridge_GetStruct('com.sun.star.table.BorderLine');
  BL.Color:=RGB(GetBValue(Value.Color), GetGValue(Value.Color), GetRValue(Value.Color));
  BL.InnerLineWidth:=Value.InnerLineWidth;
  BL.OuterLineWidth:=Value.OuterLineWidth;
  BL.LineDistance:=Value.LineDistance;
  FStyleObj.FooterRightBorder:=BL;
  BL:=Unassigned;
  SM:=Unassigned;
end;

function TOOPageStyle.GetFooterTopBorder: TOpenBorderLine;
var
  i: TColor;
begin
  i:=FStyleObj.FooterTopBorder.Color;
  Result.Color:=RGB(GetBValue(i), GetGValue(i), GetRValue(i));
  Result.InnerLineWidth:=FStyleObj.FooterTopBorder.InnerLineWidth;
  Result.OuterLineWidth:=FStyleObj.FooterTopBorder.OuterLineWidth;
  Result.LineDistance:=FStyleObj.FooterTopBorder.LineDistance;
end;

procedure TOOPageStyle.SetFooterTopBorder(const Value: TOpenBorderLine);
var
  BL: Variant;
  SM: Variant;
begin
  SM:=CreateOleObject('com.sun.star.ServiceManager');
  BL:=SM.Bridge_GetStruct('com.sun.star.table.BorderLine');
  BL.Color:=RGB(GetBValue(Value.Color), GetGValue(Value.Color), GetRValue(Value.Color));
  BL.InnerLineWidth:=Value.InnerLineWidth;
  BL.OuterLineWidth:=Value.OuterLineWidth;
  BL.LineDistance:=Value.LineDistance;
  FStyleObj.FooterTopBorder:=BL;
  BL:=Unassigned;
  SM:=Unassigned;
end;

function TOOPageStyle.GetFooterBottomBorder: TOpenBorderLine;
var
  i: TColor;
begin
  i:=FStyleObj.FooterBottomBorder.Color;
  Result.Color:=RGB(GetBValue(i), GetGValue(i), GetRValue(i));
  Result.InnerLineWidth:=FStyleObj.FooterBottomBorder.InnerLineWidth;
  Result.OuterLineWidth:=FStyleObj.FooterBottomBorder.OuterLineWidth;
  Result.LineDistance:=FStyleObj.FooterBottomBorder.LineDistance;
end;

procedure TOOPageStyle.SetFooterBottomBorder(const Value: TOpenBorderLine);
var
  BL: Variant;
  SM: Variant;
begin
  SM:=CreateOleObject('com.sun.star.ServiceManager');
  BL:=SM.Bridge_GetStruct('com.sun.star.table.BorderLine');
  BL.Color:=RGB(GetBValue(Value.Color), GetGValue(Value.Color), GetRValue(Value.Color));
  BL.InnerLineWidth:=Value.InnerLineWidth;
  BL.OuterLineWidth:=Value.OuterLineWidth;
  BL.LineDistance:=Value.LineDistance;
  FStyleObj.FooterBottomBorder:=BL;
  BL:=Unassigned;
  SM:=Unassigned;
end;

function TOOPageStyle.GetFooterLeftDistance: integer;
begin
  Result:=FStyleObj.FooterLeftDistance;
end;

procedure TOOPageStyle.SetFooterLeftDistance(const Value: integer);
begin
  FStyleObj.FooterLeftDistance:=Value;
end;

function TOOPageStyle.GetFooterRightDistance: integer;
begin
  Result:=FStyleObj.FooterRightDistance;
end;

procedure TOOPageStyle.SetFooterRightDistance(const Value: integer);
begin
  FStyleObj.FooterRightDistance:=Value;
end;

function TOOPageStyle.GetFooterTopDistance: integer;
begin
  Result:=FStyleObj.FooterTopDistance;
end;

procedure TOOPageStyle.SetFooterTopDistance(const Value: integer);
begin
  FStyleObj.FooterTopDistance:=Value;
end;

function TOOPageStyle.GetFooterBottomDistance: integer;
begin
  Result:=FStyleObj.FooterBottomDistance;
end;

procedure TOOPageStyle.SetFooterBottomDistance(const Value: integer);
begin
  FStyleObj.FooterBottomDistance:=Value;
end;

function TOOPageStyle.GetFooterDistance: integer;
begin
  Result:=FStyleObj.FooterDistance;
end;

procedure TOOPageStyle.SetFooterDistance(const Value: integer);
begin
  FStyleObj.FooterDistance:=Value;
end;

function TOOPageStyle.GetFooterBodyDistance: integer;
begin
  Result:=FStyleObj.FooterBodyDistance;
end;

procedure TOOPageStyle.SetFooterBodyDistance(const Value: integer);
begin
  FStyleObj.FooterBodyDistance:=Value;
end;

function TOOPageStyle.GetFooterShadowFormat: TOpenShadowFormat;
var
  SF: Variant;
begin
  SF:=FStyleObj.FooterShadowFormat;
  Result.Location:=SF.Location;
  Result.ShadowWidth:=SF.ShadowWidth;
  Result.IsTransparent:=SF.IsTransparent;
  Result.Color:=RGB(GetBValue(SF.Color), GetGValue(SF.Color), GetRValue(SF.Color));
  SF:=Unassigned;
end;

procedure TOOPageStyle.SetFooterShadowFormat(const Value: TOpenShadowFormat);
var
  SF: Variant;
  SM: Variant;
begin
  SM:=CreateOleObject('com.sun.star.ServiceManager');
  SF:=SM.Bridge_GetStruct('com.sun.star.table.ShadowFormat');
  SF.Location:=Ord(Value.Location);
  SF.ShadowWidth:=Value.ShadowWidth;
  SF.IsTransparent:=Value.IsTransparent;
  SF.Color:=RGB(GetBValue(Value.Color), GetGValue(Value.Color), GetRValue(Value.Color));
  FStyleObj.FooterShadowFormat:=SF;
  SF:=Unassigned;
  SM:=Unassigned;
end;

function TOOPageStyle.GetFooterHeight: integer;
begin
  Result:=FStyleObj.FooterHeight;
end;

procedure TOOPageStyle.SetFooterHeight(const Value: integer);
begin
  FStyleObj.FooterHeight:=Value;
end;

function TOOPageStyle.GetFooterIsDynamicHeight: boolean;
begin
  Result:=FStyleObj.FooterIsDynamicHeight;
end;

procedure TOOPageStyle.SetFooterIsDynamicHeight(const Value: boolean);
begin
  FStyleObj.FooterIsDynamicHeight:=Value;
end;

function TOOPageStyle.GetFooterIsShared: boolean;
begin
  Result:=FStyleObj.FooterIsShared;
end;

procedure TOOPageStyle.SetFooterIsShared(const Value: boolean);
begin
  FStyleObj.FooterIsShared:=Value;
end;

function TOOPageStyle.GetFooterIsOn: boolean;
begin
  Result:=FStyleObj.FooterIsOn;
end;

procedure TOOPageStyle.SetFooterIsOn(const Value: boolean);
begin
  FStyleObj.FooterIsOn:=Value;
end;

function TOOPageStyle.GetBorder: TOOHeaderBorderDistance;
begin
  FBorder.BorderObj:=FStyleObj;
  Result:=FBorder;
end;

function TOOPageStyle.GetMargin: TOOMargin;
begin
  FMargin.MarginObj:=FStyleObj;
  Result:=FMargin;
end;

// ******************************************************************************
{ TOOCalcPageStyle }
// ******************************************************************************

constructor TOOCalcPageStyle.Create;
begin
  inherited Create;
  FModelCursor:=TOOModelCursor.Create;
  FOldCursorType:=ochNone;
  FOldContent:=Unassigned;
  FModelCursor.OnTextChange:=DoTextChange;
  FModelCursor.OnFontChange:=DoTextChange;
  FModelCursor.OnParaChange:=DoTextChange;
end;

destructor TOOCalcPageStyle.Destroy;
begin
  FModelCursor.Free;
  inherited;
end;

procedure TOOCalcPageStyle.FreeVariants;
begin
  inherited;
  FOldCursorType:=ochNone;
  FOldContent:=Unassigned;
  FModelCursor.FreeVariants;
end;

function TOOCalcPageStyle.GetPageScale: integer;
begin
  Result:=FStyleObj.PageScale;
end;

procedure TOOCalcPageStyle.SetPageScale(const Value: integer);
begin
  FStyleObj.PageScale:=Value;
end;

function TOOCalcPageStyle.GetScaleToPages: integer;
begin
  Result:=FStyleObj.ScaleToPages;
end;

procedure TOOCalcPageStyle.SetScaleToPages(const Value: integer);
begin
  FStyleObj.ScaleToPages:=Value;
end;

function TOOCalcPageStyle.GetFirstPageNumber: integer;
begin
  Result:=FStyleObj.FirstPageNumber;
end;

procedure TOOCalcPageStyle.SetFirstPageNumber(const Value: integer);
begin
  FStyleObj.FirstPageNumber:=Value;
end;

function TOOCalcPageStyle.GetCenterHorizontally: boolean;
begin
  Result:=FStyleObj.CenterHorizontally;
end;

procedure TOOCalcPageStyle.SetCenterHorizontally(const Value: boolean);
begin
  FStyleObj.CenterHorizontally:=Value;
end;

function TOOCalcPageStyle.GetCenterVertically: boolean;
begin
  Result:=FStyleObj.CenterVertically;
end;

procedure TOOCalcPageStyle.SetCenterVertically(const Value: boolean);
begin
  FStyleObj.CenterVertically:=Value;
end;

function TOOCalcPageStyle.GetPrintAnnotations: boolean;
begin
  Result:=FStyleObj.PrintAnnotations;
end;

procedure TOOCalcPageStyle.SetPrintAnnotations(const Value: boolean);
begin
  FStyleObj.PrintAnnotations:=Value;
end;

function TOOCalcPageStyle.GetPrintGrid: boolean;
begin
  Result:=FStyleObj.PrintGrid;
end;

procedure TOOCalcPageStyle.SetPrintGrid(const Value: boolean);
begin
  FStyleObj.PrintGrid:=Value;
end;

function TOOCalcPageStyle.GetPrintHeaders: boolean;
begin
  Result:=FStyleObj.PrintHeaders;
end;

procedure TOOCalcPageStyle.SetPrintHeaders(const Value: boolean);
begin
  FStyleObj.PrintHeaders:=Value;
end;

function TOOCalcPageStyle.GetPrintCharts: boolean;
begin
  Result:=FStyleObj.PrintCharts;
end;

procedure TOOCalcPageStyle.SetPrintCharts(const Value: boolean);
begin
  FStyleObj.PrintCharts:=Value;
end;

function TOOCalcPageStyle.GetPrintObjects: boolean;
begin
  Result:=FStyleObj.PrintObjects;
end;

procedure TOOCalcPageStyle.SetPrintObjects(const Value: boolean);
begin
  FStyleObj.PrintObjects:=Value;
end;

function TOOCalcPageStyle.GetPrintDrawing: boolean;
begin
  Result:=FStyleObj.PrintDrawing;
end;

procedure TOOCalcPageStyle.SetPrintDrawing(const Value: boolean);
begin
  FStyleObj.PrintDrawing:=Value;
end;

function TOOCalcPageStyle.GetPrintFormulas: boolean;
begin
  Result:=FStyleObj.PrintFormulas;
end;

procedure TOOCalcPageStyle.SetPrintFormulas(const Value: boolean);
begin
  FStyleObj.PrintFormulas:=Value;
end;

function TOOCalcPageStyle.GetPrintZeroValues: boolean;
begin
  Result:=FStyleObj.PrintZeroValues;
end;

procedure TOOCalcPageStyle.SetPrintZeroValues(const Value: boolean);
begin
  FStyleObj.PrintZeroValues:=Value;
end;

function TOOCalcPageStyle.GetPrintDownFirst: boolean;
begin
  Result:=FStyleObj.PrintDownFirst;
end;

procedure TOOCalcPageStyle.SetPrintDownFirst(const Value: boolean);
begin
  FStyleObj.PrintDownFirst:=Value;
end;

function TOOCalcPageStyle.GetModelCursor(CursorType: TOpenCH): TOOModelCursor;
begin
  if CursorType<>ochNone then
  begin
    if FOldCursorType<>CursorType then
    begin
      FModelCursor.CursorObj:=Unassigned;
      if not VarIsEmpty(FOldContent) then
        case FOldCursorType of
        ochLeftPageHeaderLeft, ochLeftPageHeaderCenter, ochLeftPageHeaderRight:
        FStyleObj.SetPropertyValue('LeftPageHeaderContent', FOldContent);
        ochRightPageHeaderLeft, ochRightPageHeaderCenter, ochRightPageHeaderRight:
        FStyleObj.SetPropertyValue('RightPageHeaderContent', FOldContent);
        ochLeftPageFooterLeft, ochLeftPageFooterCenter, ochLeftPageFooterRight:
        FStyleObj.SetPropertyValue('LeftPageFooterContent', FOldContent);
        ochRightPageFooterLeft, ochRightPageFooterCenter, ochRightPageFooterRight:
        FStyleObj.SetPropertyValue('RightPageFooterContent', FOldContent);
        end;
      case CursorType of
      ochLeftPageHeaderLeft, ochLeftPageHeaderCenter, ochLeftPageHeaderRight:
      FOldContent:=FStyleObj.LeftPageHeaderContent;
      ochRightPageHeaderLeft, ochRightPageHeaderCenter, ochRightPageHeaderRight:
      FOldContent:=FStyleObj.RightPageHeaderContent;
      ochLeftPageFooterLeft, ochLeftPageFooterCenter, ochLeftPageFooterRight:
      FOldContent:=FStyleObj.LeftPageFooterContent;
      ochRightPageFooterLeft, ochRightPageFooterCenter, ochRightPageFooterRight:
      FOldContent:=FStyleObj.RightPageFooterContent;
      end;
      case CursorType of
      ochLeftPageHeaderLeft, ochRightPageHeaderLeft, ochLeftPageFooterLeft, ochRightPageFooterLeft:
      FModelCursor.CursorObj:=FOldContent.GetLeftText.CreateTextCursor;
      ochLeftPageHeaderCenter, ochRightPageHeaderCenter, ochLeftPageFooterCenter,
        ochRightPageFooterCenter:
      FModelCursor.CursorObj:=FOldContent.GetCenterText.CreateTextCursor;
      ochLeftPageHeaderRight, ochRightPageHeaderRight, ochLeftPageFooterRight,
        ochRightPageFooterRight:
      FModelCursor.CursorObj:=FOldContent.GetRightText.CreateTextCursor;
      end;
      FOldCursorType:=CursorType;
    end;
    FModelCursor.Document:=FDocument;
    Result:=FModelCursor;
  end
  else
    Raise Exception.Create('Cursor type "ohfNone" only for internal use.');
end;

procedure TOOCalcPageStyle.DoTextChange(Sender: TObject);
begin
  if not VarIsEmpty(FOldContent) then
    case FOldCursorType of
    ochLeftPageHeaderLeft, ochLeftPageHeaderCenter, ochLeftPageHeaderRight:
    FStyleObj.SetPropertyValue('LeftPageHeaderContent', FOldContent);
    ochRightPageHeaderLeft, ochRightPageHeaderCenter, ochRightPageHeaderRight:
    FStyleObj.SetPropertyValue('RightPageHeaderContent', FOldContent);
    ochLeftPageFooterLeft, ochLeftPageFooterCenter, ochLeftPageFooterRight:
    FStyleObj.SetPropertyValue('LeftPageFooterContent', FOldContent);
    ochRightPageFooterLeft, ochRightPageFooterCenter, ochRightPageFooterRight:
    FStyleObj.SetPropertyValue('RightPageFooterContent', FOldContent);
    end;
end;

function TOOCalcPageStyle.GetScaleToPagesX: integer;
begin
  Result:=FStyleObj.ScaleToPagesX;
end;

procedure TOOCalcPageStyle.SetScaleToPagesX(const Value: integer);
begin
  FStyleObj.ScaleToPagesX:=Value;
end;

function TOOCalcPageStyle.GetScaleToPagesY: integer;
begin
  Result:=FStyleObj.ScaleToPagesY;
end;

procedure TOOCalcPageStyle.SetScaleToPagesY(const Value: integer);
begin
  FStyleObj.ScaleToPagesY:=Value;
end;

// ******************************************************************************
{ TOOPrinter }
// ******************************************************************************

constructor TOOPrinter.Create;
begin
  inherited Create;
  FCopyCount:=1;
  FFileName:='';
  FCollate:=false;
  FPages:='';
end;

procedure TOOPrinter.FreeVariants;
begin
  FDocument:=Unassigned;
end;

function TOOPrinter.GetValue(VariantArray: Variant; Name: string): Variant;
var
  i: integer;
begin
  Result:=Unassigned;
  for i:=0 to VarArrayHighBound(VariantArray, 1) do
    if LowerCase(VariantArray[i].Name)=LowerCase(Name) then
    begin
      Result:=VariantArray[i].Value;
      Break;
    end;
end;

procedure TOOPrinter.SetValue(var VariantArray: Variant; Name: string; Value: Variant);
var
  i: integer;
begin
  for i:=0 to VarArrayHighBound(VariantArray, 1) do
    if LowerCase(VariantArray[i].Name)=LowerCase(Name) then
    begin
      VariantArray[i].Value:=Value;
      Break;
    end;
end;

function TOOPrinter.GetName: string;
var
  Ar: Variant;
begin
  Ar:=FDocument.GetPrinter;
  Result:=GetValue(Ar, 'Name');
  Ar:=Unassigned;
end;

procedure TOOPrinter.SetName(const Value: string);
var
  Ar: Variant;
begin
  Ar:=FDocument.GetPrinter;
  SetValue(Ar, 'Name', Value);
  FDocument.SetPrinter(Ar);
  Ar:=Unassigned;
end;

function TOOPrinter.GetPaperFormat: TOpenPF;
var
  Ar: Variant;
begin
  Ar:=FDocument.GetPrinter;
  Result:=GetValue(Ar, 'PaperFormat');
  Ar:=Unassigned;
end;

procedure TOOPrinter.SetPaperFormat(const Value: TOpenPF);
var
  Ar: Variant;
begin
  Ar:=FDocument.GetPrinter;
  SetValue(Ar, 'PaperFormat', Value);
  FDocument.SetPrinter(Ar);
  Ar:=Unassigned;
end;

function TOOPrinter.GetPaperOrientation: TOpenPO;
var
  Ar: Variant;
begin
  Ar:=FDocument.GetPrinter;
  Result:=GetValue(Ar, 'PaperOrientation');
  Ar:=Unassigned;
end;

procedure TOOPrinter.SetPaperOrientation(const Value: TOpenPO);
var
  Ar: Variant;
begin
  Ar:=FDocument.GetPrinter;
  SetValue(Ar, 'PaperOrientation', Value);
  FDocument.SetPrinter(Ar);
  Ar:=Unassigned;
end;

function TOOPrinter.GetPaperSize: TOpenSize;
var
  Ar: Variant;
begin
  Ar:=FDocument.GetPrinter;
  Result.Width:=GetValue(Ar, 'PaperSize').Width;
  Result.Height:=GetValue(Ar, 'PaperSize').Height;
  Ar:=Unassigned;
end;

procedure TOOPrinter.SetPaperSize(const Value: TOpenSize);
var
  Ar: Variant;
  i: integer;
begin
  Ar:=FDocument.GetPrinter;
  for i:=0 to VarArrayHighBound(Ar, 1) do
    if Ar[i].Name='PaperSize' then
    begin
      Ar[i].Value.Width:=Value.Width;
      Ar[i].Value.Height:=Value.Height;
      FDocument.SetPrinter(Ar);
      Break;
    end;
  Ar:=Unassigned;
end;

procedure TOOPrinter.SetCopyCount(const Value: integer);
begin
  if Value>0 then
    FCopyCount:=Value
  else
    Raise ERangeError.Create('CopyCount property must be greater then 0.');
end;

procedure TOOPrinter.SetFileName(const Value: string);
begin
  FFileName:=ConvertToURL(Value);
end;

procedure TOOPrinter.SetCollate(const Value: boolean);
begin
  FCollate:=Value;
end;

procedure TOOPrinter.SetPages(const Value: string);
begin
  FPages:=Value;
end;

procedure TOOPrinter.Print(Options: TOpenPT);
var
  Ar: Variant;
  SM: Variant;
begin
  SM:=CreateOleObject('com.sun.star.ServiceManager');
  Ar:=VarArrayCreate([0, -1], varVariant);
  if optCopyCount in Options then
  begin
    VarArrayRedim(Ar, VarArrayHighBound(Ar, 1)+1);
    Ar[VarArrayHighBound(Ar, 1)]:=MakePV(SM, 'CopyCount', FCopyCount);
  end;
  if optFileName in Options then
  begin
    VarArrayRedim(Ar, VarArrayHighBound(Ar, 1)+1);
    Ar[VarArrayHighBound(Ar, 1)]:=MakePV(SM, 'FileName', FFileName);
  end;
  if optCollate in Options then
  begin
    VarArrayRedim(Ar, VarArrayHighBound(Ar, 1)+1);
    Ar[VarArrayHighBound(Ar, 1)]:=MakePV(SM, 'Collate', FCollate);
  end;
  if optPages in Options then
  begin
    VarArrayRedim(Ar, VarArrayHighBound(Ar, 1)+1);
    Ar[VarArrayHighBound(Ar, 1)]:=MakePV(SM, 'Pages', FPages);
  end;
  FDocument.Print(Ar);
  Ar:=Unassigned;
  SM:=Unassigned;
end;

function TOOPrinter.GetIsBusy: boolean;
var
  Ar: Variant;
begin
  Ar:=FDocument.GetPrinter;
  Result:=GetValue(Ar, 'IsBusy');
  Ar:=Unassigned;
end;

// ******************************************************************************
{ TOOWriterPrinter }
// ******************************************************************************

function TOOWriterPrinter.GetLeftMargin: integer;
var
  Ar: Variant;
begin
  Ar:=FDocument.GetPagePrintSettings;
  Result:=GetValue(Ar, 'LeftMargin');
  Ar:=Unassigned;
end;

procedure TOOWriterPrinter.SetLeftMargin(const Value: integer);
var
  Ar: Variant;
begin
  Ar:=FDocument.GetPagePrintSettings;
  SetValue(Ar, 'LeftMargin', Value);
  FDocument.SetPagePrintSettings(Ar);
  Ar:=Unassigned;
end;

function TOOWriterPrinter.GetRightMargin: integer;
var
  Ar: Variant;
begin
  Ar:=FDocument.GetPagePrintSettings;
  Result:=GetValue(Ar, 'RightMargin');
  Ar:=Unassigned;
end;

procedure TOOWriterPrinter.SetRightMargin(const Value: integer);
var
  Ar: Variant;
begin
  Ar:=FDocument.GetPagePrintSettings;
  SetValue(Ar, 'RightMargin', Value);
  FDocument.SetPagePrintSettings(Ar);
  Ar:=Unassigned;
end;

function TOOWriterPrinter.GetTopMargin: integer;
var
  Ar: Variant;
begin
  Ar:=FDocument.GetPagePrintSettings;
  Result:=GetValue(Ar, 'TopMargin');
  Ar:=Unassigned;
end;

procedure TOOWriterPrinter.SetTopMargin(const Value: integer);
var
  Ar: Variant;
begin
  Ar:=FDocument.GetPagePrintSettings;
  SetValue(Ar, 'TopMargin', Value);
  FDocument.SetPagePrintSettings(Ar);
  Ar:=Unassigned;
end;

function TOOWriterPrinter.GetBottomMargin: integer;
var
  Ar: Variant;
begin
  Ar:=FDocument.GetPagePrintSettings;
  Result:=GetValue(Ar, 'BottomMargin');
  Ar:=Unassigned;
end;

procedure TOOWriterPrinter.SetBottomMargin(const Value: integer);
var
  Ar: Variant;
begin
  Ar:=FDocument.GetPagePrintSettings;
  SetValue(Ar, 'BottomMargin', Value);
  FDocument.SetPagePrintSettings(Ar);
  Ar:=Unassigned;
end;

function TOOWriterPrinter.GetPageRows: integer;
var
  Ar: Variant;
begin
  Ar:=FDocument.GetPagePrintSettings;
  Result:=GetValue(Ar, 'PageRows');
  Ar:=Unassigned;
end;

procedure TOOWriterPrinter.SetPageRows(const Value: integer);
var
  Ar: Variant;
begin
  Ar:=FDocument.GetPagePrintSettings;
  SetValue(Ar, 'PageRows', Value);
  FDocument.SetPagePrintSettings(Ar);
  Ar:=Unassigned;
end;

function TOOWriterPrinter.GetPageColumns: integer;
var
  Ar: Variant;
begin
  Ar:=FDocument.GetPagePrintSettings;
  Result:=GetValue(Ar, 'PageColumns');
  Ar:=Unassigned;
end;

procedure TOOWriterPrinter.SetPageColumns(const Value: integer);
var
  Ar: Variant;
begin
  Ar:=FDocument.GetPagePrintSettings;
  SetValue(Ar, 'PageColumns', Value);
  FDocument.SetPagePrintSettings(Ar);
  Ar:=Unassigned;
end;

function TOOWriterPrinter.GetHoriMargin: integer;
var
  Ar: Variant;
begin
  Ar:=FDocument.GetPagePrintSettings;
  Result:=GetValue(Ar, 'HoriMargin');
  Ar:=Unassigned;
end;

procedure TOOWriterPrinter.SetHoriMargin(const Value: integer);
var
  Ar: Variant;
begin
  Ar:=FDocument.GetPagePrintSettings;
  SetValue(Ar, 'HoriMargin', Value);
  FDocument.SetPagePrintSettings(Ar);
  Ar:=Unassigned;
end;

function TOOWriterPrinter.GetVertMargin: integer;
var
  Ar: Variant;
begin
  Ar:=FDocument.GetPagePrintSettings;
  Result:=GetValue(Ar, 'VertMargin');
  Ar:=Unassigned;
end;

procedure TOOWriterPrinter.SetVertMargin(const Value: integer);
var
  Ar: Variant;
begin
  Ar:=FDocument.GetPagePrintSettings;
  SetValue(Ar, 'VertMargin', Value);
  FDocument.SetPagePrintSettings(Ar);
  Ar:=Unassigned;
end;

function TOOWriterPrinter.GetLandscape: boolean;
var
  Ar: Variant;
begin
  Ar:=FDocument.GetPagePrintSettings;
  Result:=GetValue(Ar, 'IsLandscape');
  Ar:=Unassigned;
end;

procedure TOOWriterPrinter.SetLandscape(const Value: boolean);
var
  Ar: Variant;
begin
  Ar:=FDocument.GetPagePrintSettings;
  SetValue(Ar, 'IsLandscape', Value);
  FDocument.SetPagePrintSettings(Ar);
  Ar:=Unassigned;
end;

procedure TOOWriterPrinter.PrintPages(Options: TOpenPT);
var
  Ar: Variant;
  SM: Variant;
begin
  SM:=CreateOleObject('com.sun.star.ServiceManager');
  Ar:=VarArrayCreate([0, -1], varVariant);
  if optCopyCount in Options then
  begin
    VarArrayRedim(Ar, VarArrayHighBound(Ar, 1)+1);
    Ar[VarArrayHighBound(Ar, 1)]:=MakePV(SM, 'CopyCount', FCopyCount);
  end;
  if optFileName in Options then
  begin
    VarArrayRedim(Ar, VarArrayHighBound(Ar, 1)+1);
    Ar[VarArrayHighBound(Ar, 1)]:=MakePV(SM, 'FileName', FFileName);
  end;
  if optCollate in Options then
  begin
    VarArrayRedim(Ar, VarArrayHighBound(Ar, 1)+1);
    Ar[VarArrayHighBound(Ar, 1)]:=MakePV(SM, 'Collate', FCollate);
  end;
  if optPages in Options then
  begin
    VarArrayRedim(Ar, VarArrayHighBound(Ar, 1)+1);
    Ar[VarArrayHighBound(Ar, 1)]:=MakePV(SM, 'Pages', FPages);
  end;
  FDocument.PrintPages(Ar);
  Ar:=Unassigned;
  SM:=Unassigned;
end;

// ******************************************************************************
{ TOOBaseCursor }
// ******************************************************************************

constructor TOOBaseCursor.Create;
begin
  inherited Create;
  FCursorType:=octOther;
  FFont:=TOOCharProperties.Create;
  FPara:=TOOParaProperties.Create;
  FFont.OnChange:=DoFontChange;
  FPara.OnChange:=DoParaChange;
end;

destructor TOOBaseCursor.Destroy;
begin
  FPara.Free;
  FFont.Free;
  inherited;
end;

procedure TOOBaseCursor.FreeVariants;
begin
  FCursorObj:=Unassigned;
  FDocument:=Unassigned;
  FFont.FreeVariants;
  FPara.FreeVariants;
end;

function TOOBaseCursor.GetFont: TOOCharProperties;
begin
  FFont.CharPropertiesObj:=FCursorObj;
  Result:=FFont;
end;

function TOOBaseCursor.GetPara: TOOParaProperties;
begin
  FPara.ParaPropertiesObj:=FCursorObj;
  Result:=FPara;
end;

procedure TOOBaseCursor.DoFontChange(Sender: TObject);
begin
  if Assigned(FOnFontChange) then
    FOnFontChange(Self);
end;

procedure TOOBaseCursor.DoParaChange(Sender: TObject);
begin
  if Assigned(FOnParaChange) then
    FOnParaChange(Self);
end;

function TOOBaseCursor.GoLeft(Count: integer; Expand: boolean): boolean;
begin
  Result:=FCursorObj.GoLeft(Count, Expand);
end;

function TOOBaseCursor.GoRight(Count: integer; Expand: boolean): boolean;
begin
  Result:=FCursorObj.GoRight(Count, Expand);
end;

function TOOBaseCursor.GoUp(Count: integer; Expand: boolean): boolean;
begin
  Result:=FCursorObj.GoUp(Count, Expand);
end;

function TOOBaseCursor.GoDown(Count: integer; Expand: boolean): boolean;
begin
  Result:=FCursorObj.GoDown(Count, Expand);
end;

procedure TOOBaseCursor.GotoStart(Expand: boolean);
begin
  FCursorObj.GotoStart(Expand);
end;

procedure TOOBaseCursor.GotoEnd(Expand: boolean);
begin
  FCursorObj.GotoEnd(Expand);
end;

// ******************************************************************************
{ TOOTextTableCursor }
// ******************************************************************************

function TOOTextTableCursor.GetRangeName: string;
begin
  Result:=FCursorObj.GetRangeName;
end;

function TOOTextTableCursor.GotoCellByName(CellName: string; Expand: boolean): boolean;
begin
  Result:=FCursorObj.GotoCellByName(CellName, Expand);
end;

function TOOTextTableCursor.MergeRange: boolean;
begin
  Result:=FCursorObj.MergeRange;
end;

function TOOTextTableCursor.SplitRange(Count: integer; Horizontal: boolean): boolean;
begin
  Result:=FCursorObj.SplitRange(Count, Horizontal);
end;

// ******************************************************************************
{ TOOTextCursor }
// ******************************************************************************

constructor TOOTextCursor.Create;
begin
  inherited Create;
  FCursorType:=octWriter;
end;

function TOOTextCursor.GetBreakType: TOpenBT;
begin
  Result:=FCursorObj.BreakType;
end;

procedure TOOTextCursor.SetBreakType(const Value: TOpenBT);
begin
  FCursorObj.BreakType:=Ord(Value);
end;

procedure TOOTextCursor.InsertDateTime(IsFixed, IsDate: boolean; Format, Adjust: integer);
var
  DT, SM: Variant;
begin
  SM:=CreateOleObject('com.sun.star.ServiceManager');
  DT:=FDocument.CreateInstance('com.sun.star.text.TextField.DateTime');
  DT.SetPropertyValue('IsDate', IsDate);
  try
    DT.SetPropertyValue('NumberFormat', Format);
    DT.SetPropertyValue('IsFixed', IsFixed);
    DT.SetPropertyValue('Adjust', Adjust);
  except
  end;
  FCursorObj.GetText.InsertTextContent(FCursorObj, DT, false);
  DT:=Unassigned;
  SM:=Unassigned;
  if Assigned(FOnTextChange) then
    FOnTextChange(Self);
end;

procedure TOOTextCursor.InsertPageCount;
var
  PC, SM: Variant;
begin
  SM:=CreateOleObject('com.sun.star.ServiceManager');
  PC:=FDocument.CreateInstance('com.sun.star.text.TextField.PageCount');
  PC.SetPropertyValue('NumberingType', 4);
  FCursorObj.GetText.InsertTextContent(FCursorObj, PC, false);
  PC:=Unassigned;
  SM:=Unassigned;
  if Assigned(FOnTextChange) then
    FOnTextChange(Self);
end;

procedure TOOTextCursor.InsertPageNumber;
var
  PN, SM: Variant;
begin
  SM:=CreateOleObject('com.sun.star.ServiceManager');
  PN:=FDocument.CreateInstance('com.sun.star.text.TextField.PageNumber');
  PN.SetPropertyValue('NumberingType', 4);
  FCursorObj.GetText.InsertTextContent(FCursorObj, PN, false);
  PN:=Unassigned;
  SM:=Unassigned;
  if Assigned(FOnTextChange) then
    FOnTextChange(Self);
end;

// ******************************************************************************
{ TOOModelCursor }
// ******************************************************************************

constructor TOOModelCursor.Create;
begin
  inherited Create;
  FFont.OnChange:=DoFontChange;
  FWriterHFType:=owhNone;
end;

procedure TOOModelCursor.Sync(V: Variant);
begin
  // Recreate cursor object
  FCursorObj:=Unassigned;
  FCursorObj:=V.GetText.CreateTextCursor;
  FCursorObj.GotoRange(V.GetStart, false);
  FCursorObj.GotoRange(V.GetEnd, true);
end;

procedure TOOModelCursor.SyncFrom(Cursor: TOOViewCursor);
begin
  if Cursor.CursorType<>octWriter then
    Raise Exception.Create('Cursor must be a Writer property.');
  FCursorObj.GotoRange(Cursor.CursorObj.GetStart, false);
  FCursorObj.GotoRange(Cursor.CursorObj.GetEnd, true);
end;

function TOOModelCursor.GotoNextWord(Expand: boolean): boolean;
begin
  Result:=FCursorObj.GotoNextWord(Expand);
end;

function TOOModelCursor.GotoPreviousWord(Expand: boolean): boolean;
begin
  Result:=FCursorObj.GotoPreviousWord(Expand);
end;

function TOOModelCursor.GotoStartOfWord(Expand: boolean): boolean;
begin
  Result:=FCursorObj.GotoStartOfWord(Expand);
end;

function TOOModelCursor.GotoEndOfWord(Expand: boolean): boolean;
begin
  Result:=FCursorObj.GotoEndOfWord(Expand);
end;

function TOOModelCursor.IsStartOfWord: boolean;
begin
  Result:=FCursorObj.IsStartOfWord;
end;

function TOOModelCursor.IsEndOfWord: boolean;
begin
  Result:=FCursorObj.IsEndOfWord;
end;

function TOOModelCursor.GotoNextSentence(Expand: boolean): boolean;
begin
  Result:=FCursorObj.GotoNextSentence(Expand);
end;

function TOOModelCursor.GotoPreviousSentence(Expand: boolean): boolean;
begin
  Result:=FCursorObj.GotoPreviousSentence(Expand);
end;

function TOOModelCursor.GotoStartOfSentence(Expand: boolean): boolean;
begin
  Result:=FCursorObj.GotoStartOfSentence(Expand);
end;

function TOOModelCursor.GotoEndOfSentence(Expand: boolean): boolean;
begin
  Result:=FCursorObj.GotoEndOfSentence(Expand);
end;

function TOOModelCursor.IsStartOfSentence: boolean;
begin
  Result:=FCursorObj.IsStartOfSentence;
end;

function TOOModelCursor.IsEndOfSentence: boolean;
begin
  Result:=FCursorObj.IsEndOfSentence;
end;

function TOOModelCursor.GotoNextParagraph(Expand: boolean): boolean;
begin
  Result:=FCursorObj.GotoNextParagraph(Expand);
end;

function TOOModelCursor.GotoPreviousParagraph(Expand: boolean): boolean;
begin
  Result:=FCursorObj.GotoPreviousParagraph(Expand);
end;

function TOOModelCursor.GotoStartOfParagraph(Expand: boolean): boolean;
begin
  Result:=FCursorObj.GotoStartOfParagraph(Expand);
end;

function TOOModelCursor.GotoEndOfParagraph(Expand: boolean): boolean;
begin
  Result:=FCursorObj.GotoEndOfParagraph(Expand);
end;

function TOOModelCursor.IsStartOfParagraph: boolean;
begin
  Result:=FCursorObj.IsStartOfParagraph;
end;

function TOOModelCursor.IsEndOfParagraph: boolean;
begin
  Result:=FCursorObj.IsEndOfParagraph;
end;

// ******************************************************************************
{ TOOBokmarks }
// ******************************************************************************

constructor TOOBookmarks.Create;
begin
  inherited Create;
  FBookmark:=TOOBookmark.Create;
end;

destructor TOOBookmarks.Destroy;
begin
  FBookmark.Free;
  inherited;
end;

procedure TOOBookmarks.FreeVariants;
begin
  FDocument:=Unassigned;
  FBookmark.FreeVariants;
end;

function TOOBookmarks.GetCount: integer;
begin
  Result:=FDocument.GetBookmarks.Count;
end;

function TOOBookmarks.GetBookmark(Index: integer): TOOBookmark;
begin
  FBookmark.BookmarkObj:=FDocument.GetBookmarks.GetByIndex(Index);
  Result:=FBookmark;
end;

function TOOBookmarks.GetBookmarkByName(BookmarkName: string): TOOBookmark;
begin
  FBookmark.BookmarkObj:=FDocument.GetBookmarks.GetByName(BookmarkName);
  Result:=FBookmark;
end;

function TOOBookmarks.IsExist(BookmarkName: string): boolean;
begin
  Result:=FDocument.GetBookmarks.HasByName(BookmarkName);
end;

procedure TOOBookmarks.Append(BookmarkName: string; Cursor: TOOTextCursor);
var
  Bmk: Variant;
begin
  if not IsExist(BookmarkName) then
  begin
    Bmk:=FDocument.CreateInstance('com.sun.star.text.Bookmark');
    FDocument.Text.InsertTextContent(Cursor.CursorObj, Bmk, true);
    if BookmarkName<>'' then
      Bmk.SetName(BookmarkName);
    Bmk:=Unassigned;
  end
  else
    Raise Exception.Create('Bookmark with specified name is already exists.');
end;

procedure TOOBookmarks.DeleteByIndex(Index: integer);
begin
  try
    FDocument.Text.RemoveTextContent(FDocument.GetBookmarks.GetByIndex(Index));
  except
    Raise Exception.Create('Bookmark index out of bounds.');
  end;
end;

procedure TOOBookmarks.DeleteByName(BookmarkName: string);
begin
  try
    FDocument.Text.RemoveTextContent(FDocument.GetBookmarks.GetByName(BookmarkName));
  except
    Raise Exception.Create('Bookmark with specified name not exist.');
  end;
end;

procedure TOOBookmarks.DeleteAll;
begin
  while FDocument.GetBookmarks.Count>0 do
    FDocument.Text.RemoveTextContent(FDocument.GetBookmarks.GetByIndex(0));
end;

// ******************************************************************************
{ TOOBookmark }
// ******************************************************************************

procedure TOOBookmark.FreeVariants;
begin
  FBookmarkObj:=Unassigned;
  FDocument:=Unassigned;
end;

function TOOBookmark.GetName: string;
begin
  Result:=FBookmarkObj.GetName;
end;

procedure TOOBookmark.SetName(const Value: string);
begin
  FBookmarkObj.SetName(Value);
end;

procedure TOOBookmark.SetCursorPosition(Cursor: TOOTextCursor);
begin
  if Cursor.CursorType=octOther then
    Raise Exception.Create('Cursor must be a Writer property.');
  Cursor.CursorObj.GotoRange(BookmarkObj.GetAnchor.GetStart, false);
  Cursor.CursorObj.GotoRange(BookmarkObj.GetAnchor.GetEnd, true);
end;

// ******************************************************************************
{ TOOTextFrames }
// ******************************************************************************

constructor TOOTextFrames.Create;
begin
  inherited Create;
  FTextFrame:=TOOTextFrame.Create;
end;

destructor TOOTextFrames.Destroy;
begin
  FTextFrame.Free;
  inherited;
end;

procedure TOOTextFrames.FreeVariants;
begin
  FDocument:=Unassigned;
  FTextFrame.FreeVariants;
end;

procedure TOOTextFrames.Append(TextFrameName: string; Cursor: TOOTextCursor);
var
  Tfr: Variant;
begin
  if Cursor.CursorType=octOther then
    Raise Exception.Create('Cursor must be a Writer property.');
  if (not IsExist(TextFrameName))and(not FDocument.GetGraphicObjects.HasByName(TextFrameName)) then
  begin
    Tfr:=FDocument.CreateInstance('com.sun.star.text.TextFrame');
    FDocument.Text.InsertTextContent(Cursor.CursorObj, Tfr, true);
    if TextFrameName<>'' then
      Tfr.SetName(TextFrameName);
    Tfr:=Unassigned;
  end
  else
    Raise Exception.Create('Text frame with specified name is already exists.');
end;

function TOOTextFrames.IsExist(TextFrameName: string): boolean;
begin
  Result:=FDocument.GetTextFrames.HasByName(TextFrameName);
end;

function TOOTextFrames.GetCount: integer;
begin
  Result:=FDocument.GetTextFrames.Count;
end;

function TOOTextFrames.GetTextFrame(Index: integer): TOOTextFrame;
begin
  FTextFrame.Document:=FDocument;
  FTextFrame.FrameObj:=FDocument.GetTextFrames.GetByIndex(Index);
  Result:=FTextFrame;
end;

function TOOTextFrames.GetTextFrameByName(TextFrameName: string): TOOTextFrame;
begin
  FTextFrame.Document:=FDocument;
  FTextFrame.FrameObj:=FDocument.GetTextFrames.GetByName(TextFrameName);
  Result:=FTextFrame;
end;

// ******************************************************************************
{ TOOBaseFrame }
// ******************************************************************************

constructor TOOBaseFrame.Create;
begin
  inherited Create;
  FBorder:=TOOBorder.Create;
  FMargin:=TOOMargin.Create;
end;

destructor TOOBaseFrame.Destroy;
begin
  FMargin.Free;
  FBorder.Free;
  inherited;
end;

procedure TOOBaseFrame.FreeVariants;
begin
  FFrameObj:=Unassigned;
  FDocument:=Unassigned;
  FMargin.FreeVariants;
  FBorder.FreeVariants;
end;

function TOOBaseFrame.GetName: string;
begin
  Result:=FFrameObj.GetName;
end;

procedure TOOBaseFrame.SetName(const Value: string);
begin
  FFrameObj.SetName(Value);
end;

function TOOBaseFrame.GetWidth: integer;
begin
  Result:=FFrameObj.Width;
end;

procedure TOOBaseFrame.SetWidth(const Value: integer);
begin
  FFrameObj.Width:=Value;
end;

function TOOBaseFrame.GetHeight: integer;
begin
  Result:=FFrameObj.Height;
end;

procedure TOOBaseFrame.SetHeight(const Value: integer);
begin
  FFrameObj.Height:=Value;
end;

function TOOBaseFrame.GetRelativeWidth: integer;
begin
  Result:=FFrameObj.RelativeWidth;
end;

procedure TOOBaseFrame.SetRelativeWidth(const Value: integer);
begin
  FFrameObj.RelativeWidth:=Value;
end;

function TOOBaseFrame.GetRelativeHeight: integer;
begin
  Result:=FFrameObj.RelativeHeight;
end;

procedure TOOBaseFrame.SetRelativeHeight(const Value: integer);
begin
  FFrameObj.RelativeHeight:=Value;
end;

function TOOBaseFrame.GetBackColor: TColor;
var
  i: integer;
begin
  i:=FFrameObj.BackColor;
  Result:=RGB(GetBValue(i), GetGValue(i), GetRValue(i));
end;

procedure TOOBaseFrame.SetBackColor(const Value: TColor);
begin
  FFrameObj.BackColor:=RGB(GetBValue(Value), GetGValue(Value), GetRValue(Value));
end;

function TOOBaseFrame.GetBackColorTransparent: boolean;
begin
  Result:=FFrameObj.BackTransparent;
end;

procedure TOOBaseFrame.SetBackColorTransparent(const Value: boolean);
begin
  FFrameObj.BackTransparent:=Value;
end;

function TOOBaseFrame.GetDistance: integer;
begin
  Result:=FFrameObj.Distance;
end;

procedure TOOBaseFrame.SetDistance(const Value: integer);
begin
  FFrameObj.Distance:=Value;
end;

function TOOBaseFrame.GetContentProtected: boolean;
begin
  Result:=FFrameObj.ContentProtected;
end;

procedure TOOBaseFrame.SetContentProtected(const Value: boolean);
begin
  FFrameObj.ContentProtected:=Value;
end;

function TOOBaseFrame.GetPositionProtected: boolean;
begin
  Result:=FFrameObj.PositionProtected;
end;

procedure TOOBaseFrame.SetPositionProtected(const Value: boolean);
begin
  FFrameObj.PositionProtected:=Value;
end;

function TOOBaseFrame.GetSizeProtected: boolean;
begin
  Result:=FFrameObj.SizeProtected;
end;

procedure TOOBaseFrame.SetSizeProtected(const Value: boolean);
begin
  FFrameObj.SizeProtected:=Value;
end;

function TOOBaseFrame.GetSyncWidthToHeight: boolean;
begin
  Result:=FFrameObj.IsSyncWidthToHeight;
end;

procedure TOOBaseFrame.SetSyncWidthToHeight(const Value: boolean);
begin
  FFrameObj.IsSyncWidthToHeight:=Value;
end;

function TOOBaseFrame.GetSyncHeightToWidth: boolean;
begin
  Result:=FFrameObj.IsSyncHeightToWidth;
end;

procedure TOOBaseFrame.SetSyncHeightToWidth(const Value: boolean);
begin
  FFrameObj.IsSyncHeightToWidth:=Value;
end;

function TOOBaseFrame.GetOpaque: boolean;
begin
  Result:=FFrameObj.Opaque;
end;

procedure TOOBaseFrame.SetOpaque(const Value: boolean);
begin
  FFrameObj.Opaque:=Value;
end;

function TOOBaseFrame.GetPageToggle: boolean;
begin
  Result:=FFrameObj.PageToggle;
end;

procedure TOOBaseFrame.SetPageToggle(const Value: boolean);
begin
  FFrameObj.PageToggle:=Value;
end;

function TOOBaseFrame.GetPrint: boolean;
begin
  Result:=FFrameObj.Print;
end;

procedure TOOBaseFrame.SetPrint(const Value: boolean);
begin
  FFrameObj.Print:=Value;
end;

function TOOBaseFrame.GetShadowFormat: TOpenShadowFormat;
var
  SF: Variant;
begin
  SF:=FFrameObj.ShadowFormat;
  Result.Location:=SF.Location;
  Result.ShadowWidth:=SF.ShadowWidth;
  Result.IsTransparent:=SF.IsTransparent;
  Result.Color:=RGB(GetBValue(SF.Color), GetGValue(SF.Color), GetRValue(SF.Color));
  SF:=Unassigned;
end;

procedure TOOBaseFrame.SetShadowFormat(const Value: TOpenShadowFormat);
var
  SF: Variant;
  SM: Variant;
begin
  SM:=CreateOleObject('com.sun.star.ServiceManager');
  SF:=SM.Bridge_GetStruct('com.sun.star.table.ShadowFormat');
  SF.Location:=Ord(Value.Location);
  SF.ShadowWidth:=Value.ShadowWidth;
  SF.IsTransparent:=Value.IsTransparent;
  SF.Color:=RGB(GetBValue(Value.Color), GetGValue(Value.Color), GetRValue(Value.Color));
  FFrameObj.ShadowFormat:=SF;
  SF:=Unassigned;
  SM:=Unassigned;
end;

function TOOBaseFrame.GetSurround: TOpenFSR;
begin
  Result:=FFrameObj.Surround;
end;

procedure TOOBaseFrame.SetSurround(const Value: TOpenFSR);
begin
  FFrameObj.Surround:=Ord(Value);
end;

function TOOBaseFrame.GetHoriOrient: TOpenFHO;
begin
  Result:=FFrameObj.HoriOrient;
end;

procedure TOOBaseFrame.SetHoriOrient(const Value: TOpenFHO);
begin
  FFrameObj.HoriOrient:=Ord(Value);
end;

function TOOBaseFrame.GetHoriOrientPosition: integer;
begin
  Result:=FFrameObj.HoriOrientPosition;
end;

procedure TOOBaseFrame.SetHoriOrientPosition(const Value: integer);
begin
  FFrameObj.HoriOrientPosition:=Ord(Value);
end;

function TOOBaseFrame.GetHoriOrientRelation: TOpenRO;
begin
  Result:=FFrameObj.HoriOrientRelation;
end;

procedure TOOBaseFrame.SetHoriOrientRelation(const Value: TOpenRO);
begin
  FFrameObj.HoriOrientRelation:=Ord(Value);
end;

function TOOBaseFrame.GetVertOrient: TOpenFVO;
begin
  Result:=FFrameObj.VertOrient;
end;

procedure TOOBaseFrame.SetVertOrient(const Value: TOpenFVO);
begin
  FFrameObj.VertOrient:=Ord(Value);
end;

function TOOBaseFrame.GetVertOrientPosition: integer;
begin
  Result:=FFrameObj.VertOrientPosition;
end;

procedure TOOBaseFrame.SetVertOrientPosition(const Value: integer);
begin
  FFrameObj.VertOrientPosition:=Ord(Value);
end;

function TOOBaseFrame.GetVertOrientRelation: TOpenRO;
begin
  Result:=FFrameObj.VertOrientRelation;
end;

procedure TOOBaseFrame.SetVertOrientRelation(const Value: TOpenRO);
begin
  FFrameObj.VertOrientRelation:=Ord(Value);
end;

function TOOBaseFrame.GetBorder: TOOBorder;
begin
  FBorder.BorderObj:=FFrameObj;
  Result:=FBorder;
end;

function TOOBaseFrame.GetMargin: TOOMargin;
begin
  FMargin.MarginObj:=FFrameObj;
  Result:=FMargin;
end;

// ******************************************************************************
{ TOOCalcRowCol }
// ******************************************************************************

procedure TOOCalcRowCol.FreeVariants;
begin
  FRowColObj:=Unassigned;
end;

function TOOCalcRowCol.GetIsVisible: boolean;
begin
  Result:=FRowColObj.IsVisible;
end;

procedure TOOCalcRowCol.SetIsVisible(const Value: boolean);
begin
  FRowColObj.IsVisible:=Value;
end;

function TOOCalcRowCol.GetIsStartOfNewPage: boolean;
begin
  Result:=FRowColObj.IsStartOfNewPage;
end;

procedure TOOCalcRowCol.SetIsStartOfNewPage(const Value: boolean);
begin
  FRowColObj.IsStartOfNewPage:=Value;
end;

// ******************************************************************************
{ TOOCalcColumns }
// ******************************************************************************

constructor TOOCalcColumns.Create;
begin
  inherited Create;
  FColumn:=TOOCalcColumn.Create;
end;

destructor TOOCalcColumns.Destroy;
begin
  FColumn.Free;
  inherited;
end;

procedure TOOCalcColumns.FreeVariants;
begin
  FParentSheetObj:=Unassigned;
  FColumn.FreeVariants;
end;

procedure TOOCalcColumns.Insert(Index, Count: integer);
begin
  if Count>0 then
    FParentSheetObj.GetColumns.InsertByIndex(Index, Count);
end;

procedure TOOCalcColumns.Delete(Index, Count: integer);
begin
  if Count>0 then
    FParentSheetObj.GetColumns.RemoveByIndex(Index, Count);
end;

function TOOCalcColumns.GetColumn(Index: integer): TOOCalcColumn;
begin
  FColumn.RowColObj:=FParentSheetObj.GetColumns.GetByIndex(Index);
  Result:=FColumn;
end;

// ******************************************************************************
{ TOOCalcColumn }
// ******************************************************************************

function TOOCalcColumn.GetWidth: integer;
begin
  Result:=FRowColObj.Width;
end;

procedure TOOCalcColumn.SetWidth(const Value: integer);
begin
  FRowColObj.Width:=Value;
end;

function TOOCalcColumn.GetOptimalWidth: boolean;
begin
  Result:=FRowColObj.OptimalWidth;
end;

procedure TOOCalcColumn.SetOptimalWidth(const Value: boolean);
begin
  FRowColObj.OptimalWidth:=Value;
end;

// ******************************************************************************
{ TOOCalcRows }
// ******************************************************************************

constructor TOOCalcRows.Create;
begin
  inherited Create;
  FRow:=TOOCalcRow.Create;
end;

destructor TOOCalcRows.Destroy;
begin
  FRow.Free;
  inherited;
end;

procedure TOOCalcRows.FreeVariants;
begin
  FParentSheetObj:=Unassigned;
  FRow.FreeVariants;
end;

procedure TOOCalcRows.Insert(Index, Count: integer);
begin
  if Count>0 then
    FParentSheetObj.GetRows.InsertByIndex(Index, Count);
end;

procedure TOOCalcRows.Delete(Index, Count: integer);
begin
  if Count>0 then
    FParentSheetObj.GetRows.RemoveByIndex(Index, Count);
end;

function TOOCalcRows.GetRow(Index: integer): TOOCalcRow;
begin
  FRow.RowColObj:=FParentSheetObj.GetRows.GetByIndex(Index);
  Result:=FRow;
end;

// ******************************************************************************
{ TOOCalcRow }
// ******************************************************************************

function TOOCalcRow.GetHeight: integer;
begin
  Result:=FRowColObj.Height;
end;

procedure TOOCalcRow.SetHeight(const Value: integer);
begin
  FRowColObj.Height:=Value;
end;

function TOOCalcRow.GetOptimalHeight: boolean;
begin
  Result:=FRowColObj.OptimalHeight;
end;

procedure TOOCalcRow.SetOptimalHeight(const Value: boolean);
begin
  FRowColObj.OptimalHeight:=Value;
end;

// ******************************************************************************
{ TOOCharProperties }
// ******************************************************************************

procedure TOOCharProperties.FreeVariants;
begin
  FCharPropertiesObj:=Unassigned;
end;

procedure TOOCharProperties.DoChange;
begin
  if Assigned(FOnChange) then
    FOnChange(Self);
end;

function TOOCharProperties.GetFontName: string;
begin
  Result:=FCharPropertiesObj.CharFontName;
end;

procedure TOOCharProperties.SetFontName(const Value: string);
begin
  FCharPropertiesObj.CharFontName:=Value;
  DoChange;
end;

function TOOCharProperties.GetFontStyleName: string;
begin
  Result:=FCharPropertiesObj.CharFontStyleName;
end;

procedure TOOCharProperties.SetFontStyleName(const Value: string);
begin
  FCharPropertiesObj.CharFontStyleName:=Value;
  DoChange;
end;

function TOOCharProperties.GetColor: TColor;
var
  i: integer;
begin
  i:=FCharPropertiesObj.CharColor;
  Result:=RGB(GetBValue(i), GetGValue(i), GetRValue(i));
end;

procedure TOOCharProperties.SetColor(const Value: TColor);
begin
  FCharPropertiesObj.CharColor:=RGB(GetBValue(Value), GetGValue(Value), GetRValue(Value));
  DoChange;
end;

function TOOCharProperties.GetEscapement: integer;
begin
  Result:=FCharPropertiesObj.CharEscapement;
end;

procedure TOOCharProperties.SetEscapement(const Value: integer);
begin
  FCharPropertiesObj.CharEscapement:=Value;
  DoChange;
end;

function TOOCharProperties.GetHeight: integer;
begin
  Result:=FCharPropertiesObj.CharHeight;
end;

procedure TOOCharProperties.SetHeight(const Value: integer);
begin
  FCharPropertiesObj.CharHeight:=Value;
  DoChange;
end;

function TOOCharProperties.GetUnderline: TOpenFU;
begin
  Result:=FCharPropertiesObj.CharUnderline;
end;

procedure TOOCharProperties.SetUnderline(const Value: TOpenFU);
begin
  FCharPropertiesObj.CharUnderline:=Ord(Value);
  DoChange;
end;

function TOOCharProperties.GetWeight: integer;
begin
  Result:=FCharPropertiesObj.CharWeight;
end;

procedure TOOCharProperties.SetWeight(const Value: integer);
begin
  FCharPropertiesObj.CharWeight:=Value;
  DoChange;
end;

function TOOCharProperties.GetPosture: TOpenFP;
begin
  Result:=FCharPropertiesObj.CharPosture;
end;

procedure TOOCharProperties.SetPosture(const Value: TOpenFP);
begin
  FCharPropertiesObj.CharPosture:=Ord(Value);
  DoChange;
end;

function TOOCharProperties.GetAutoKerning: boolean;
begin
  Result:=FCharPropertiesObj.CharAutoKerning;
end;

procedure TOOCharProperties.SetAutoKerning(const Value: boolean);
begin
  FCharPropertiesObj.CharAutoKerning:=Value;
  DoChange;
end;

function TOOCharProperties.GetBackColor: TColor;
var
  i: integer;
begin
  i:=FCharPropertiesObj.CharBackColor;
  Result:=RGB(GetBValue(i), GetGValue(i), GetRValue(i));
end;

procedure TOOCharProperties.SetBackColor(const Value: TColor);
begin
  FCharPropertiesObj.CharBackColor:=RGB(GetBValue(Value), GetGValue(Value), GetRValue(Value));
  DoChange;
end;

function TOOCharProperties.GetBackColorTransparent: boolean;
begin
  Result:=FCharPropertiesObj.CharBackTransparent;
end;

procedure TOOCharProperties.SetBackColorTransparent(const Value: boolean);
begin
  FCharPropertiesObj.CharBackTransparent:=Value;
  DoChange;
end;

function TOOCharProperties.GetCaseMap: TOpenCM;
begin
  Result:=FCharPropertiesObj.CharCaseMap;
end;

procedure TOOCharProperties.SetCaseMap(const Value: TOpenCM);
begin
  FCharPropertiesObj.CharCaseMap:=Ord(Value);
  DoChange;
end;

function TOOCharProperties.GetCrossedOut: boolean;
begin
  Result:=FCharPropertiesObj.CharCrossedOut;
end;

procedure TOOCharProperties.SetCrossedOut(const Value: boolean);
begin
  FCharPropertiesObj.CharCrossedOut:=Value;
  DoChange;
end;

function TOOCharProperties.GetFlash: boolean;
begin
  Result:=FCharPropertiesObj.CharFlash;
end;

procedure TOOCharProperties.SetFlash(const Value: boolean);
begin
  FCharPropertiesObj.CharFlash:=Value;
  DoChange;
end;

function TOOCharProperties.GetStrikeout: TOpenFS;
begin
  Result:=FCharPropertiesObj.CharStrikeout;
end;

procedure TOOCharProperties.SetStrikeout(const Value: TOpenFS);
begin
  FCharPropertiesObj.CharStrikeout:=Ord(Value);
  DoChange;
end;

function TOOCharProperties.GetWordMode: boolean;
begin
  Result:=FCharPropertiesObj.CharWordMode;
end;

procedure TOOCharProperties.SetWordMode(const Value: boolean);
begin
  FCharPropertiesObj.CharWordMode:=Value;
  DoChange;
end;

function TOOCharProperties.GetKerning: integer;
begin
  Result:=FCharPropertiesObj.CharKerning;
end;

procedure TOOCharProperties.SetKerning(const Value: integer);
begin
  FCharPropertiesObj.CharKerning:=Value;
  DoChange;
end;

function TOOCharProperties.GetKeepTogether: boolean;
begin
  Result:=FCharPropertiesObj.CharKeepTogether;
end;

procedure TOOCharProperties.SetKeepTogether(const Value: boolean);
begin
  FCharPropertiesObj.CharKeepTogether:=Value;
  DoChange;
end;

function TOOCharProperties.GetNoLineBreak: boolean;
begin
  Result:=FCharPropertiesObj.CharNoLineBreak;
end;

procedure TOOCharProperties.SetNoLineBreak(const Value: boolean);
begin
  FCharPropertiesObj.CharNoLineBreak:=Value;
  DoChange;
end;

function TOOCharProperties.GetShadowed: boolean;
begin
  Result:=FCharPropertiesObj.CharShadowed;
end;

procedure TOOCharProperties.SetShadowed(const Value: boolean);
begin
  FCharPropertiesObj.CharShadowed:=Value;
  DoChange;
end;

function TOOCharProperties.GetStyleName: string;
begin
  Result:=FCharPropertiesObj.CharStyleName;
end;

procedure TOOCharProperties.SetStyleName(const Value: string);
begin
  FCharPropertiesObj.CharStyleName:=Value;
  DoChange;
end;

function TOOCharProperties.GetContoured: boolean;
begin
  Result:=FCharPropertiesObj.CharContoured;
end;

procedure TOOCharProperties.SetContoured(const Value: boolean);
begin
  FCharPropertiesObj.CharContoured:=Value;
  DoChange;
end;

function TOOCharProperties.GetCombineIsOn: boolean;
begin
  Result:=FCharPropertiesObj.CharCombineIsOn;
end;

procedure TOOCharProperties.SetCombineIsOn(const Value: boolean);
begin
  FCharPropertiesObj.CharCombineIsOn:=Value;
  DoChange;
end;

function TOOCharProperties.GetCombinePrefix: string;
begin
  Result:=FCharPropertiesObj.CharCombinePrefix;
end;

procedure TOOCharProperties.SetCombinePrefix(const Value: string);
begin
  FCharPropertiesObj.CharCombinePrefix:=Value;
  DoChange;
end;

function TOOCharProperties.GetCombineSuffix: string;
begin
  Result:=FCharPropertiesObj.CharCombineSuffix;
end;

procedure TOOCharProperties.SetCombineSuffix(const Value: string);
begin
  FCharPropertiesObj.CharCombineSuffix:=Value;
  DoChange;
end;

function TOOCharProperties.GetEmphasis: TOpenFE;
begin
  Result:=FCharPropertiesObj.CharEmphasis;
end;

procedure TOOCharProperties.SetEmphasis(const Value: TOpenFE);
begin
  FCharPropertiesObj.CharEmphasis:=Ord(Value);
  DoChange;
end;

function TOOCharProperties.GetRelief: TOpenFR;
begin
  Result:=FCharPropertiesObj.CharRelief;
end;

procedure TOOCharProperties.SetRelief(const Value: TOpenFR);
begin
  FCharPropertiesObj.CharRelief:=Ord(Value);
  DoChange;
end;

function TOOCharProperties.GetRotation: integer;
begin
  Result:=FCharPropertiesObj.CharRotation;
end;

procedure TOOCharProperties.SetRotation(const Value: integer);
begin
  FCharPropertiesObj.CharRotation:=Value;
  DoChange;
end;

function TOOCharProperties.GetRotationIsFitToLine: boolean;
begin
  Result:=FCharPropertiesObj.CharRotationIsFitToLine;
end;

procedure TOOCharProperties.SetRotationIsFitToLine(const Value: boolean);
begin
  FCharPropertiesObj.CharRotationIsFitToLine:=Value;
  DoChange;
end;

function TOOCharProperties.GetScaleWidth: integer;
begin
  Result:=FCharPropertiesObj.CharScaleWidth;
end;

procedure TOOCharProperties.SetScaleWidth(const Value: integer);
begin
  FCharPropertiesObj.CharScaleWidth:=Value;
  DoChange;
end;

function TOOCharProperties.GetEscapementHeight: integer;
begin
  Result:=FCharPropertiesObj.CharEscapementHeight;
end;

procedure TOOCharProperties.SetEscapementHeight(const Value: integer);
begin
  FCharPropertiesObj.CharEscapementHeight:=Value;
  DoChange;
end;

function TOOCharProperties.GetNoHyphenation: boolean;
begin
  Result:=FCharPropertiesObj.CharNoHyphenation;
end;

procedure TOOCharProperties.SetNoHyphenation(const Value: boolean);
begin
  FCharPropertiesObj.CharNoHyphenation:=Value;
  DoChange;
end;

function TOOCharProperties.GetUnderlineColor: TColor;
var
  i: integer;
begin
  i:=FCharPropertiesObj.CharUnderlineColor;
  Result:=RGB(GetBValue(i), GetGValue(i), GetRValue(i));
end;

procedure TOOCharProperties.SetUnderlineColor(const Value: TColor);
begin
  FCharPropertiesObj.CharUnderlineColor:=RGB(GetBValue(Value), GetGValue(Value), GetRValue(Value));
  DoChange;
end;

function TOOCharProperties.GetUnderlineHasColor: boolean;
begin
  Result:=FCharPropertiesObj.CharUnderlineHasColor;
end;

procedure TOOCharProperties.SetUnderlineHasColor(const Value: boolean);
begin
  FCharPropertiesObj.CharUnderlineHasColor:=Value;
  DoChange;
end;

function TOOCharProperties.GetHidden: boolean;
begin
  Result:=FCharPropertiesObj.CharHidden;
end;

procedure TOOCharProperties.SetHidden(const Value: boolean);
begin
  FCharPropertiesObj.CharHidden:=Value;
  DoChange;
end;

// ******************************************************************************
{ TOOParaProperties }
// ******************************************************************************

constructor TOOParaProperties.Create;
begin
  inherited Create;
  FParaMargin:=TOOParaMargin.Create;
  FParaMargin.OnChange:=DoMarginChange;
  FBorder:=TOOBorderDistance.Create;
  FBorder.OnChange:=DoBorderChange;
end;

destructor TOOParaProperties.Destroy;
begin
  FBorder.Free;
  FParaMargin.Free;
  inherited;
end;

procedure TOOParaProperties.FreeVariants;
begin
  FParaPropertiesObj:=Unassigned;
  FParaMargin.FreeVariants;
  FBorder.FreeVariants;
end;

procedure TOOParaProperties.DoChange;
begin
  if Assigned(FOnChange) then
    FOnChange(Self);
end;

procedure TOOParaProperties.DoMarginChange(Sender: TObject);
begin
  DoChange;
end;

procedure TOOParaProperties.DoBorderChange(Sender: TObject);
begin
  DoChange;
end;

function TOOParaProperties.GetHoriAlignment: TOpenPHA;
begin
  Result:=FParaPropertiesObj.ParaAdjust;
end;

procedure TOOParaProperties.SetHoriAlignment(const Value: TOpenPHA);
begin
  FParaPropertiesObj.ParaAdjust:=Ord(Value);
  DoChange;
end;

function TOOParaProperties.GetVertAlignment: TOpenPVA;
begin
  Result:=FParaPropertiesObj.ParaVertAlignment;
end;

procedure TOOParaProperties.SetVertAlignment(const Value: TOpenPVA);
begin
  FParaPropertiesObj.ParaVertAlignment:=Ord(Value);
  DoChange;
end;

function TOOParaProperties.GetLineSpacing: TOpenLineSpacing;
begin
  Result.Mode:=FParaPropertiesObj.ParaLineSpacing.Mode;
  Result.Height:=FParaPropertiesObj.ParaLineSpacing.Height;
end;

procedure TOOParaProperties.SetLineSpacing(const Value: TOpenLineSpacing);
var
  LS: Variant;
  SM: Variant;
begin
  SM:=CreateOleObject('com.sun.star.ServiceManager');
  LS:=SM.Bridge_GetStruct('com.sun.star.style.LineSpacing');
  LS.Mode:=Ord(Value.Mode);
  LS.Height:=Value.Height;
  FParaPropertiesObj.ParaLineSpacing:=LS;
  LS:=Unassigned;
  SM:=Unassigned;
  DoChange;
end;

function TOOParaProperties.GetBackColor: TColor;
var
  i: TColor;
begin
  i:=FParaPropertiesObj.ParaBackColor;
  Result:=RGB(GetBValue(i), GetGValue(i), GetRValue(i));
end;

procedure TOOParaProperties.SetBackColor(const Value: TColor);
begin
  FParaPropertiesObj.ParaBackColor:=RGB(GetBValue(Value), GetGValue(Value), GetRValue(Value));
  DoChange;
end;

function TOOParaProperties.GetBackColorTransparent: boolean;
begin
  Result:=FParaPropertiesObj.ParaBackTransparent;
end;

procedure TOOParaProperties.SetBackColorTransparent(const Value: boolean);
begin
  FParaPropertiesObj.ParaBackTransparent:=Value;
  DoChange;
end;

function TOOParaProperties.GetLastLineAlignment: TOpenPHA;
begin
  Result:=FParaPropertiesObj.ParaLastLineAdjust;
end;

procedure TOOParaProperties.SetLastLineAlignment(const Value: TOpenPHA);
begin
  FParaPropertiesObj.ParaLastLineAdjust:=Ord(Value);
  DoChange;
end;

function TOOParaProperties.GetExpandSingleWord: boolean;
begin
  Result:=FParaPropertiesObj.ParaExpandSingleWord;
end;

procedure TOOParaProperties.SetExpandSingleWord(const Value: boolean);
begin
  FParaPropertiesObj.ParaExpandSingleWord:=Value;
  DoChange;
end;

function TOOParaProperties.GetMargin: TOOParaMargin;
begin
  FParaMargin.MarginObj:=FParaPropertiesObj;
  Result:=FParaMargin;
end;

function TOOParaProperties.GetLineNumberCount: boolean;
begin
  Result:=FParaPropertiesObj.ParaLineNumberCount;
end;

procedure TOOParaProperties.SetLineNumberCount(const Value: boolean);
begin
  FParaPropertiesObj.ParaLineNumberCount:=Value;
  DoChange;
end;

function TOOParaProperties.GetLineNumberStartValue: integer;
begin
  Result:=FParaPropertiesObj.ParaLineNumberStartValue;
end;

procedure TOOParaProperties.SetLineNumberStartValue(const Value: integer);
begin
  FParaPropertiesObj.ParaLineNumberStartValue:=Value;
  DoChange;
end;

function TOOParaProperties.GetPageDescName: string;
begin
  Result:=FParaPropertiesObj.PageDescName;
end;

procedure TOOParaProperties.SetPageDescName(const Value: string);
begin
  FParaPropertiesObj.PageDescName:=Value;
  DoChange;
end;

function TOOParaProperties.GetPageNumberOffset: integer;
begin
  Result:=FParaPropertiesObj.PageNumberOffset;
end;

procedure TOOParaProperties.SetPageNumberOffset(const Value: integer);
begin
  FParaPropertiesObj.PageNumberOffset:=Value;
  DoChange;
end;

function TOOParaProperties.GetRegisterModeActive: boolean;
begin
  Result:=FParaPropertiesObj.ParaRegisterModeActive;
end;

procedure TOOParaProperties.SetRegisterModeActive(const Value: boolean);
begin
  FParaPropertiesObj.ParaRegisterModeActive:=Value;
  DoChange;
end;

function TOOParaProperties.GetStyleName: string;
begin
  Result:=FParaPropertiesObj.ParaStyleName;
end;

procedure TOOParaProperties.SetStyleName(const Value: string);
begin
  FParaPropertiesObj.ParaStyleName:=Value;
  DoChange;
end;

function TOOParaProperties.GetPageStyleName: string;
begin
  Result:=FParaPropertiesObj.PageStyleName;
end;

function TOOParaProperties.GetDropCapFormat: TOpenDropCapFormat;
begin
  Result.Lines:=FParaPropertiesObj.DropCapFormat.Lines;
  Result.Count:=FParaPropertiesObj.DropCapFormat.Count;
  Result.Distance:=FParaPropertiesObj.DropCapFormat.Distance;
end;

procedure TOOParaProperties.SetDropCapFormat(const Value: TOpenDropCapFormat);
var
  DCF: Variant;
  SM: Variant;
begin
  SM:=CreateOleObject('com.sun.star.ServiceManager');
  DCF:=SM.Bridge_GetStruct('com.sun.star.style.DropCapFormat');
  DCF.Lines:=Value.Lines;
  DCF.Count:=Value.Count;
  DCF.Distance:=Value.Distance;
  FParaPropertiesObj.DropCapFormat:=DCF;
  DCF:=Unassigned;
  SM:=Unassigned;
  DoChange;
end;

function TOOParaProperties.GetDropCapWholeWord: boolean;
begin
  Result:=FParaPropertiesObj.DropCapWholeWord;
end;

procedure TOOParaProperties.SetDropCapWholeWord(const Value: boolean);
begin
  FParaPropertiesObj.DropCapWholeWord:=Value;
  DoChange;
end;

function TOOParaProperties.GetKeepTogether: boolean;
begin
  Result:=FParaPropertiesObj.ParaKeepTogether;
end;

procedure TOOParaProperties.SetKeepTogether(const Value: boolean);
begin
  FParaPropertiesObj.ParaKeepTogether:=Value;
  DoChange;
end;

function TOOParaProperties.GetSplit: boolean;
begin
  Result:=FParaPropertiesObj.ParaSplit;
end;

procedure TOOParaProperties.SetSplit(const Value: boolean);
begin
  FParaPropertiesObj.ParaSplit:=Value;
  DoChange;
end;

function TOOParaProperties.GetNumberingLevel: integer;
begin
  Result:=FParaPropertiesObj.NumberingLevel;
end;

procedure TOOParaProperties.SetNumberingLevel(const Value: integer);
begin
  FParaPropertiesObj.NumberingLevel:=Value;
  DoChange;
end;

function TOOParaProperties.GetNumberingStartValue: integer;
begin
  Result:=FParaPropertiesObj.NumberingStartValue;
end;

procedure TOOParaProperties.SetNumberingStartValue(const Value: integer);
begin
  FParaPropertiesObj.NumberingStartValue:=Value;
  DoChange;
end;

function TOOParaProperties.GetIsNumberingRestart: boolean;
begin
  Result:=FParaPropertiesObj.ParaIsNumberingRestart;
end;

procedure TOOParaProperties.SetIsNumberingRestart(const Value: boolean);
begin
  FParaPropertiesObj.ParaIsNumberingRestart:=Value;
  DoChange;
end;

function TOOParaProperties.GetNumberingStyleName: string;
begin
  Result:=FParaPropertiesObj.NumberingStyleName;
end;

procedure TOOParaProperties.SetNumberingStyleName(const Value: string);
begin
  FParaPropertiesObj.NumberingStyleName:=Value;
  DoChange;
end;

function TOOParaProperties.GetOrphans: integer;
begin
  Result:=FParaPropertiesObj.ParaOrphans;
end;

procedure TOOParaProperties.SetOrphans(const Value: integer);
begin
  FParaPropertiesObj.ParaOrphans:=Value;
  DoChange;
end;

function TOOParaProperties.GetWidows: integer;
begin
  Result:=FParaPropertiesObj.ParaWidows;
end;

procedure TOOParaProperties.SetWidows(const Value: integer);
begin
  FParaPropertiesObj.ParaWidows:=Value;
  DoChange;
end;

function TOOParaProperties.GetShadowFormat: TOpenShadowFormat;
var
  SF: Variant;
begin
  SF:=FParaPropertiesObj.ShadowFormat;
  Result.Location:=SF.Location;
  Result.ShadowWidth:=SF.ShadowWidth;
  Result.IsTransparent:=SF.IsTransparent;
  Result.Color:=RGB(GetBValue(SF.Color), GetGValue(SF.Color), GetRValue(SF.Color));
  SF:=Unassigned;
end;

procedure TOOParaProperties.SetShadowFormat(const Value: TOpenShadowFormat);
var
  SF: Variant;
  SM: Variant;
begin
  SM:=CreateOleObject('com.sun.star.ServiceManager');
  SF:=SM.Bridge_GetStruct('com.sun.star.table.ShadowFormat');
  SF.Location:=Ord(Value.Location);
  SF.ShadowWidth:=Value.ShadowWidth;
  SF.IsTransparent:=Value.IsTransparent;
  SF.Color:=RGB(GetBValue(Value.Color), GetGValue(Value.Color), GetRValue(Value.Color));
  FParaPropertiesObj.ShadowFormat:=SF;
  SF:=Unassigned;
  SM:=Unassigned;
  DoChange;
end;

function TOOParaProperties.GetBorder: TOOBorderDistance;
begin
  FBorder.BorderObj:=FParaPropertiesObj;
  Result:=FBorder;
end;

function TOOParaProperties.GetBorderDistance: integer;
begin
  Result:=FParaPropertiesObj.BorderDistance;
end;

procedure TOOParaProperties.SetBorderDistance(const Value: integer);
begin
  FParaPropertiesObj.BorderDistance:=Value;
  DoChange;
end;

function TOOParaProperties.GetBreakType: TOpenBT;
begin
  Result:=FParaPropertiesObj.BreakType;
end;

procedure TOOParaProperties.SetBreakType(const Value: TOpenBT);
begin
  FParaPropertiesObj.BreakType:=Ord(Value);
  DoChange;
end;

function TOOParaProperties.GetDropCapCharStyleName: string;
begin
  Result:=FParaPropertiesObj.DropCapCharStyleName;
end;

procedure TOOParaProperties.SetDropCapCharStyleName(const Value: string);
begin
  FParaPropertiesObj.DropCapCharStyleName:=Value;
  DoChange;
end;

function TOOParaProperties.GetFirstLineIndent: integer;
begin
  Result:=FParaPropertiesObj.ParaFirstLineIndent;
end;

procedure TOOParaProperties.SetFirstLineIndent(const Value: integer);
begin
  FParaPropertiesObj.ParaFirstLineIndent:=Value;
  DoChange;
end;

function TOOParaProperties.GetIsAutoFirstLineIndent: boolean;
begin
  Result:=FParaPropertiesObj.ParaIsAutoFirstLineIndent;
end;

procedure TOOParaProperties.SetIsAutoFirstLineIndent(const Value: boolean);
begin
  FParaPropertiesObj.ParaIsAutoFirstLineIndent:=Value;
  DoChange;
end;

function TOOParaProperties.GetIsHyphenation: boolean;
begin
  Result:=FParaPropertiesObj.ParaIsHyphenation;
end;

procedure TOOParaProperties.SetIsHyphenation(const Value: boolean);
begin
  FParaPropertiesObj.ParaIsHyphenation:=Value;
  DoChange;
end;

function TOOParaProperties.GetHyphenationMaxHyphens: integer;
begin
  Result:=FParaPropertiesObj.ParaHyphenationMaxHyphens;
end;

procedure TOOParaProperties.SetHyphenationMaxHyphens(const Value: integer);
begin
  FParaPropertiesObj.ParaHyphenationMaxHyphens:=Value;
  DoChange;
end;

function TOOParaProperties.GetHyphenationMaxLeadingChars: integer;
begin
  Result:=FParaPropertiesObj.ParaHyphenationMaxLeadingChars;
end;

procedure TOOParaProperties.SetHyphenationMaxLeadingChars(const Value: integer);
begin
  FParaPropertiesObj.ParaHyphenationMaxLeadingChars:=Value;
  DoChange;
end;

function TOOParaProperties.GetHyphenationMaxTrailingChars: integer;
begin
  Result:=FParaPropertiesObj.ParaHyphenationMaxTrailingChars;
end;

procedure TOOParaProperties.SetHyphenationMaxTrailingChars(const Value: integer);
begin
  FParaPropertiesObj.ParaHyphenationMaxTrailingChars:=Value;
  DoChange;
end;

function TOOParaProperties.GetIsConnectBorder: boolean;
begin
  Result:=FParaPropertiesObj.ParaIsConnectBorder;
end;

procedure TOOParaProperties.SetIsConnectBorder(const Value: boolean);
begin
  FParaPropertiesObj.ParaIsConnectBorder:=Value;
  DoChange;
end;

// ******************************************************************************
{ TOONumberFormats }
// ******************************************************************************

function TOONumberFormats.Add(Format: string): integer;
var
  NF: Variant;
  Loc: Variant;
  SM: Variant;
begin
  SM:=CreateOleObject('com.sun.star.ServiceManager');
  NF:=FDocument.GetNumberFormats;
  Loc:=SM.Bridge_GetStruct('com.sun.star.lang.Locale');
  Result:=NF.QueryKey(Format, Loc, false);
  if Result=-1 then
    Result:=NF.AddNew(Format, Loc);
  Loc:=Unassigned;
  NF:=Unassigned;
  SM:=Unassigned;
end;

function TOONumberFormats.Find(Format: string): integer;
var
  NF: Variant;
  Loc: Variant;
  SM: Variant;
begin
  SM:=CreateOleObject('com.sun.star.ServiceManager');
  NF:=FDocument.GetNumberFormats;
  Loc:=SM.Bridge_GetStruct('com.sun.star.lang.Locale');
  Result:=NF.QueryKey(Format, Loc, false);
  Loc:=Unassigned;
  NF:=Unassigned;
  SM:=Unassigned;
end;

procedure TOONumberFormats.FreeVariants;
begin
  FDocument:=Unassigned;
end;

// ******************************************************************************
{ TOOBaseCell }
// ******************************************************************************

constructor TOOBaseCell.Create;
begin
  inherited Create;
  FFont:=TOOCharProperties.Create;
  FPara:=TOOParaProperties.Create;
  FBorder:=TOOBorder.Create;
  FIsNewCell:=true;
end;

destructor TOOBaseCell.Destroy;
begin
  FBorder.Free;
  FPara.Free;
  FFont.Free;
  inherited;
end;

procedure TOOBaseCell.FreeVariants;
begin
  FCellObj:=Unassigned;
  FFont.FreeVariants;
  FPara.FreeVariants;
  FBorder.FreeVariants;
end;

function TOOBaseCell.GetFont: TOOCharProperties;
begin
  FFont.CharPropertiesObj:=FCellObj;
  Result:=FFont;
end;

function TOOBaseCell.GetPara: TOOParaProperties;
begin
  FPara.ParaPropertiesObj:=FCellObj;
  Result:=FPara;
end;

function TOOBaseCell.GetBorder: TOOBorder;
begin
  FBorder.BorderObj:=FCellObj;
  Result:=FBorder;
end;

function TOOBaseCell.GetFormat: integer;
begin
  Result:=FCellObj.NumberFormat;
end;

procedure TOOBaseCell.SetFormat(const Value: integer);
begin
  FCellObj.NumberFormat:=Value;
end;

// ******************************************************************************
{ TOOCalcBaseCell }
// ******************************************************************************

procedure TOOCalcBaseCell.FreeVariants;
begin
  inherited;
  FDocument:=Unassigned;
  FParentSheetObj:=Unassigned;
end;

procedure TOOCalcBaseCell.ReplaceAll(SearchString, ReplaceString: string; Param: TOpenRP);
var
  RD: Variant;
begin
  RD:=FParentSheetObj.CreateReplaceDescriptor;
  RD.SearchString:=SearchString;
  RD.ReplaceString:=ReplaceString;
  RD.SearchWords:=orpWholeWords in Param;
  RD.SearchCaseSensitive:=orpCaseSensitive in Param;
  FCellObj.ReplaceAll(RD);
  RD:=Unassigned;
end;

procedure TOOCalcBaseCell.Copy(ToSheet, ToCol, ToRow: integer);
var
  CRA: Variant;
  CA: Variant;
  SM: Variant;
begin
  SM:=CreateOleObject('com.sun.star.ServiceManager');
  CRA:=FCellObj.GetRangeAddress;
  CA:=SM.Bridge_GetStruct('com.sun.star.table.CellAddress');

  CA.Sheet:=ToSheet;
  CA.Column:=ToCol;
  CA.Row:=ToRow;

  FParentSheetObj.CopyRange(CA, CRA);
  CRA:=Unassigned;
  CA:=Unassigned;
  SM:=Unassigned;
end;

procedure TOOCalcBaseCell.Copy(ToSheet, ToCol, ToRow: integer; Mode: TOpenIM);
var
  SCRA: Variant;
  TCRA: Variant;
  TCA: Variant;
  SM: Variant;
begin
  SM:=CreateOleObject('com.sun.star.ServiceManager');
  SCRA:=FCellObj.GetRangeAddress;

  TCRA:=SM.Bridge_GetStruct('com.sun.star.table.CellRangeAddress');
  TCRA.Sheet:=ToSheet;
  TCRA.StartColumn:=ToCol;
  TCRA.StartRow:=ToRow;
  TCRA.EndColumn:=ToCol+SCRA.EndColumn-SCRA.StartColumn;
  TCRA.EndRow:=ToRow+SCRA.EndRow-SCRA.StartRow;
  ParentSheetObj.InsertCells(TCRA, Ord(Mode));
  TCRA:=Unassigned;

  TCA:=SM.Bridge_GetStruct('com.sun.star.table.CellAddress');
  TCA.Sheet:=ToSheet;
  TCA.Column:=ToCol;
  TCA.Row:=ToRow;
  SCRA:=FCellObj.GetRangeAddress;
  ParentSheetObj.CopyRange(TCA, SCRA);
  SCRA:=Unassigned;
  TCA:=Unassigned;
  SM:=Unassigned;
end;

procedure TOOCalcBaseCell.Move(ToSheet, ToCol, ToRow: integer);
var
  CRA: Variant;
  CA: Variant;
  SM: Variant;
begin
  SM:=CreateOleObject('com.sun.star.ServiceManager');
  CRA:=FCellObj.GetRangeAddress;
  CA:=SM.Bridge_GetStruct('com.sun.star.table.CellAddress');

  CA.Sheet:=ToSheet;
  CA.Column:=ToCol;
  CA.Row:=ToRow;

  FParentSheetObj.MoveRange(CA, CRA);
  CRA:=Unassigned;
  CA:=Unassigned;
  SM:=Unassigned;
end;

procedure TOOCalcBaseCell.Insert(Mode: TOpenIM);
var
  CRA: Variant;
begin
  CRA:=FCellObj.GetRangeAddress;
  FParentSheetObj.InsertCells(CRA, Ord(Mode));
  CRA:=Unassigned;
end;

procedure TOOCalcBaseCell.Remove(Mode: TOpenDM);
var
  CRA: Variant;
begin
  CRA:=FCellObj.GetRangeAddress;
  FParentSheetObj.RemoveRange(CRA, Ord(Mode));
  CRA:=Unassigned;
end;

procedure TOOCalcBaseCell.SetCellName(const Value: string);
var
  CRA: Variant;
  CA: Variant;
  s: string;
  SM: Variant;
begin
  SM:=CreateOleObject('com.sun.star.ServiceManager');
  CRA:=FCellObj.GetRangeAddress;
  CA:=SM.Bridge_GetStruct('com.sun.star.table.CellAddress');

  CA.Sheet:=CRA.Sheet;
  CA.Column:=CRA.StartColumn;
  CA.Row:=CRA.StartRow;

  if (CRA.StartColumn=CRA.EndColumn)and(CRA.StartRow=CRA.EndRow) then
    s:=NameCR(CRA.StartColumn, CRA.StartRow)
  else
    s:=NameCR(CRA.StartColumn, CRA.StartRow)+':'+NameCR(CRA.EndColumn, CRA.EndRow);
  FDocument.NamedRanges.AddNewByName(Value, s, CA, 0);
  CRA:=Unassigned;
  CA:=Unassigned;
  SM:=Unassigned;
end;

function TOOCalcBaseCell.GetBackColor: TColor;
var
  i: integer;
begin
  i:=FCellObj.CellBackColor;
  Result:=RGB(GetBValue(i), GetGValue(i), GetRValue(i));
end;

procedure TOOCalcBaseCell.SetBackColor(const Value: TColor);
begin
  FCellObj.CellBackColor:=RGB(GetBValue(Value), GetGValue(Value), GetRValue(Value));
end;

function TOOCalcBaseCell.GetBackColorTransparent: boolean;
begin
  Result:=FCellObj.IsCellBackgroundTransparent;
end;

procedure TOOCalcBaseCell.SetBackColorTransparent(const Value: boolean);
begin
  FCellObj.IsCellBackgroundTransparent:=Value;
end;

function TOOCalcBaseCell.GetRotate: integer;
begin
  Result:=FCellObj.RotateAngle;
end;

procedure TOOCalcBaseCell.SetRotate(const Value: integer);
begin
  FCellObj.RotateAngle:=Value;
end;

function TOOCalcBaseCell.GetHoriAlignment: TOpenHA;
begin
  Result:=FCellObj.HoriJustify;
end;

procedure TOOCalcBaseCell.SetHoriAlignment(const Value: TOpenHA);
begin
  FCellObj.HoriJustify:=Ord(Value);
end;

function TOOCalcBaseCell.GetVertAlignment: TOpenVA;
begin
  Result:=FCellObj.VertJustify;
end;

procedure TOOCalcBaseCell.SetVertAlignment(const Value: TOpenVA);
begin
  FCellObj.VertJustify:=Ord(Value);
end;

function TOOCalcBaseCell.GetTextWrap: boolean;
begin
  Result:=FCellObj.IsTextWrapped;
end;

procedure TOOCalcBaseCell.SetTextWrap(const Value: boolean);
begin
  FCellObj.IsTextWrapped:=Value;
end;

function TOOCalcBaseCell.GetMerge: boolean;
begin
  Result:=FCellObj.GetIsMerged;
end;

procedure TOOCalcBaseCell.SetMerge(const Value: boolean);
begin
  FCellObj.Merge(Value);
end;

function TOOCalcBaseCell.GetAddress: TOpenRangeAddress;
var
  CRA: Variant;
begin
  CRA:=FCellObj.GetRangeAddress;
  Result.Sheet:=CRA.Sheet;
  Result.StartColumn:=CRA.StartColumn;
  Result.StartRow:=CRA.StartRow;
  Result.EndColumn:=CRA.EndColumn;
  Result.EndRow:=CRA.EndRow;
  CRA:=Unassigned;
end;

// ******************************************************************************
{ TOOCalcCellRange }
// ******************************************************************************

constructor TOOCalcCellRange.Create;
begin
  inherited Create;
  FTableBorder:=TOOTableBorder.Create;
end;

destructor TOOCalcCellRange.Destroy;
begin
  FTableBorder.Free;
  inherited;
end;

procedure TOOCalcCellRange.FreeVariants;
begin
  inherited;
  FTableBorder.FreeVariants;
end;

function TOOCalcCellRange.GetTableBorder: TOOTableBorder;
begin
  FTableBorder.TableBorderObj:=FCellObj;
  Result:=FTableBorder;
end;

procedure TOOCalcCellRange.Group(Orientation: TOpenTO);
begin
  FParentSheetObj.Group(FCellObj.GetRangeAddress, Ord(Orientation));
end;

procedure TOOCalcCellRange.Ungroup(Orientation: TOpenTO);
begin
  FParentSheetObj.Ungroup(FCellObj.GetRangeAddress, Ord(Orientation));
end;

procedure TOOCalcCellRange.GroupsClear;
begin
  FParentSheetObj.ClearOutline;
end;

procedure TOOCalcCellRange.GroupHideDetail;
begin
  FParentSheetObj.HideDetail(FCellObj.GetRangeAddress);
end;

procedure TOOCalcCellRange.GroupShowDetail;
begin
  FParentSheetObj.ShowDetail(FCellObj.GetRangeAddress);
end;

procedure TOOCalcCellRange.GroupShowLevel(Level: integer; Orientation: TOpenTO);
begin
  FParentSheetObj.ShowLevel(Level, Ord(Orientation));
end;

function TOOCalcCellRange.GetAsArray: Variant;
begin
  Result:=FCellObj.GetDataArray;
end;

procedure TOOCalcCellRange.SetAsArray(const Value: Variant);
begin
  FCellObj.SetDataArray(Value);
end;

function TOOCalcCellRange.GetAsFormulaArray: Variant;
begin
  Result:=FCellObj.GetFormulaArray;
end;

procedure TOOCalcCellRange.SetAsFormulaArray(const Value: Variant);
begin
  FCellObj.SetFormulaArray(Value);
end;

procedure TOOCalcCellRange.SetAsTitleColumns;
begin
  FParentSheetObj.SetTitleColumns(FCellObj.GetRangeAddress);
end;

procedure TOOCalcCellRange.SetAsTitleRows;
begin
  FParentSheetObj.SetTitleRows(FCellObj.GetRangeAddress);
end;

procedure TOOCalcCellRange.FillSeries(FDirection: TOpenFD; FMode: TOpenFM; FDateMode: TOpenFDM;
  Step, EndValue: double);
begin
  FCellObj.FillSeries(Ord(FDirection), Ord(FMode), Ord(FDateMode), Step, EndValue);
end;

function TOOCalcCellRange.GetMaxSortFieldsCount: integer;
var
  V: Variant;
  i: integer;
begin
  Result:=0;
  V:=FCellObj.CreateSortDescriptor;
  for i:=0 to VarArrayHighBound(V, 1) do
    if V[i].Name='MaxFieldCount' then
    begin
      Result:=V[i].Value;
      Break;
    end;
end;

procedure TOOCalcCellRange.Sort(SortColumns, ContainsHeader: boolean; FieldsArray: TOpenSortFields);
var
  Ar, F, UW: Variant;
  SM: Variant;
  i: integer;
begin
  if Length(FieldsArray)>GetMaxSortFieldsCount then
    Raise Exception.Create('Too many values in FieldsArray.');
  if Length(FieldsArray)=0 then
    Raise Exception.Create('No values in FieldsArray.');
  SM:=CreateOleObject('com.sun.star.ServiceManager');
  Ar:=VarArrayCreate([0, 6], varVariant);
  Ar[0]:=MakePV(SM, 'IsSortColumns', not SortColumns);
  Ar[1]:=MakePV(SM, 'BindFormatsToContent', false);
  Ar[2]:=MakePV(SM, 'ContainsHeader', ContainsHeader);
  Ar[3]:=MakePV(SM, 'CopyOutputData', false);
  Ar[4]:=MakePV(SM, 'IsUserListEnabled', false);
  Ar[5]:=MakePV(SM, 'UserListIndex', 0);
  F:=VarArrayCreate([0, Length(FieldsArray)-1], varVariant);
  for i:=0 to Length(FieldsArray)-1 do
  begin
    F[i]:=SM.Bridge_GetStruct('com.sun.star.table.TableSortField');
    F[i].Field:=FieldsArray[i].FieldNum;
    F[i].IsAscending:=FieldsArray[i].IsAscending;
    F[i].IsCaseSensitive:=FieldsArray[i].IsCaseSensitive;
    F[i].FieldType:=Ord(FieldsArray[i].FieldType);
  end;
  UW:=SM.Bridge_GetValueObject;
  UW.{$IFDEF FPC} &Set {$ELSE} Set {$ENDIF}('[]com.sun.star.table.TableSortField', F);
  Ar[6]:=MakePV(SM, 'SortFields', UW);
  FCellObj.Sort(Ar);
  UW:=Unassigned;
  F:=Unassigned;
  Ar:=Unassigned;
  SM:=Unassigned;
end;

procedure TOOCalcCellRange.SortTo(Sheet, Col, Row: integer;
  SortColumns, BindFormatsToContent, ContainsHeader: boolean; FieldsArray: TOpenSortFields);
var
  Ar, F, Ad, UW: Variant;
  SM: Variant;
  i: integer;
begin
  if Length(FieldsArray)>GetMaxSortFieldsCount then
    Raise Exception.Create('Too many values in FieldsArray.');
  if Length(FieldsArray)=0 then
    Raise Exception.Create('No values in FieldsArray.');
  SM:=CreateOleObject('com.sun.star.ServiceManager');
  Ar:=VarArrayCreate([0, 7], varVariant);
  Ar[0]:=MakePV(SM, 'IsSortColumns', not SortColumns);
  Ar[1]:=MakePV(SM, 'BindFormatsToContent', BindFormatsToContent);
  Ar[2]:=MakePV(SM, 'ContainsHeader', ContainsHeader);
  Ar[3]:=MakePV(SM, 'CopyOutputData', true);
  Ar[4]:=MakePV(SM, 'IsUserListEnabled', false);
  Ar[5]:=MakePV(SM, 'UserListIndex', 0);
  F:=VarArrayCreate([0, Length(FieldsArray)-1], varVariant);
  for i:=0 to Length(FieldsArray)-1 do
  begin
    F[i]:=SM.Bridge_GetStruct('com.sun.star.table.TableSortField');
    F[i].Field:=FieldsArray[i].FieldNum;
    F[i].IsAscending:=FieldsArray[i].IsAscending;
    F[i].IsCaseSensitive:=FieldsArray[i].IsCaseSensitive;
    F[i].FieldType:=Ord(FieldsArray[i].FieldType);
  end;
  UW:=SM.Bridge_GetValueObject;
  UW.{$IFDEF FPC} &Set {$ELSE} Set {$ENDIF}('[]com.sun.star.table.TableSortField', F);
  Ar[6]:=MakePV(SM, 'SortFields', UW);
  Ad:=SM.Bridge_GetStruct('com.sun.star.table.CellAddress');
  Ad.Sheet:=Sheet;
  Ad.Column:=Col;
  Ad.Row:=Row;
  Ar[7]:=MakePV(SM, 'OutputPosition', Ad);
  FCellObj.Sort(Ar);
  UW:=Unassigned;
  Ad:=Unassigned;
  F:=Unassigned;
  Ar:=Unassigned;
  SM:=Unassigned;
end;

// ******************************************************************************
{ TOOWriterBaseCell }
// ******************************************************************************

procedure TOOWriterBaseCell.FreeVariants;
begin
  inherited;
  FTTCursor:=Unassigned;
end;

function TOOWriterBaseCell.GetFont: TOOCharProperties;
begin
  FFont.CharPropertiesObj:=FTTCursor;
  Result:=FFont;
end;

function TOOWriterBaseCell.GetPara: TOOParaProperties;
begin
  FPara.ParaPropertiesObj:=FTTCursor;
  Result:=FPara;
end;

function TOOWriterBaseCell.GetBackColor: TColor;
var
  i: integer;
begin
  i:=FCellObj.BackColor;
  Result:=RGB(GetBValue(i), GetGValue(i), GetRValue(i));
end;

procedure TOOWriterBaseCell.SetBackColor(const Value: TColor);
begin
  FCellObj.BackColor:=RGB(GetBValue(Value), GetGValue(Value), GetRValue(Value));
end;

function TOOWriterBaseCell.GetBackColorTransparent: boolean;
begin
  Result:=FCellObj.BackTransparent;
end;

procedure TOOWriterBaseCell.SetBackColorTransparent(const Value: boolean);
begin
  FCellObj.BackTransparent:=Value;
end;

function TOOWriterBaseCell.GetName: string;
begin
  Result:=FTTCursor.GetRangeName;
end;

function TOOWriterBaseCell.Merge: boolean;
begin
  Result:=FTTCursor.MergeRange;
end;

function TOOWriterBaseCell.Split(Count: integer; Horizontal: boolean): boolean;
begin
  Result:=FTTCursor.SplitRange(Count, Horizontal);
end;

function TOOWriterBaseCell.GetVertAlignment: TOpenFVO;
begin
  Result:=FCellObj.VertOrient;
end;

procedure TOOWriterBaseCell.SetVertAlignment(const Value: TOpenFVO);
begin
  FCellObj.VertOrient:=Ord(Value);
end;

// ******************************************************************************
{ TOOWriterCellRange }
// ******************************************************************************

function TOOWriterCellRange.GetAsArray: Variant;
begin
  Result:=FCellObj.GetDataArray;
end;

procedure TOOWriterCellRange.SetAsArray(const Value: Variant);
begin
  FCellObj.SetDataArray(Value);
end;

// ******************************************************************************
{ TOOTextFrame }
// ******************************************************************************

constructor TOOTextFrame.Create;
begin
  inherited Create;
  FModelCursor:=TOOModelCursor.Create;
  FOldName:='';
end;

destructor TOOTextFrame.Destroy;
begin
  FModelCursor.Free;
  inherited;
end;

procedure TOOTextFrame.FreeVariants;
begin
  inherited;
  FOldName:='';
  FModelCursor.FreeVariants;
end;

procedure TOOTextFrame.SetName(const Value: string);
begin
  FOldName:='';
  inherited;
end;

function TOOTextFrame.GetAutoHeight: boolean;
begin
  Result:=FFrameObj.FrameIsAutomaticHeight;
end;

procedure TOOTextFrame.SetAutoHeight(const Value: boolean);
begin
  FFrameObj.FrameIsAutomaticHeight:=Value;
end;

function TOOTextFrame.GetModelCursor: TOOModelCursor;
begin
  if FOldName=FFrameObj.GetName then
  begin
    FModelCursor.Document:=FDocument;
    Result:=FModelCursor;
  end
  else
  begin
    FModelCursor.CursorObj:=Unassigned;
    FModelCursor.CursorObj:=FFrameObj.GetText.CreateTextCursor;
    FOldName:=FFrameObj.GetName;
    FModelCursor.Document:=FDocument;
    Result:=FModelCursor;
  end;
end;

// ******************************************************************************
{ TOOGraphicFrames }
// ******************************************************************************

constructor TOOGraphicFrames.Create;
begin
  inherited Create;
  FGraphicFrame:=TOOGraphicFrame.Create;
end;

destructor TOOGraphicFrames.Destroy;
begin
  FGraphicFrame.Free;
  inherited;
end;

procedure TOOGraphicFrames.FreeVariants;
begin
  FDocument:=Unassigned;
  FGraphicFrame.FreeVariants;
end;

function TOOGraphicFrames.GetCount: integer;
begin
  Result:=FDocument.GetGraphicObjects.Count;
end;

procedure TOOGraphicFrames.Append(GraphicFrameName: string; Cursor: TOOTextCursor);
var
  Gfr: Variant;
begin
  if Cursor.CursorType=octOther then
    Raise Exception.Create('Cursor must be a Writer property.');
  if (not IsExist(GraphicFrameName))and(not FDocument.GetTextFrames.HasByName(GraphicFrameName))
  then
  begin
    Gfr:=FDocument.CreateInstance('com.sun.star.text.TextGraphicObject');
    Cursor.CursorObj.GetText.InsertTextContent(Cursor.CursorObj, Gfr, true);
    if GraphicFrameName<>'' then
      Gfr.SetName(GraphicFrameName);
    Gfr:=Unassigned;
  end
  else
    Raise Exception.Create('Frame with specified name is already exists.');
end;

function TOOGraphicFrames.IsExist(GraphicFrameName: string): boolean;
begin
  Result:=FDocument.GetGraphicObjects.HasByName(GraphicFrameName);
end;

function TOOGraphicFrames.GetGraphicFrame(Index: integer): TOOGraphicFrame;
begin
  FGraphicFrame.Document:=FDocument;
  FGraphicFrame.FrameObj:=FDocument.GetGraphicObjects.GetByIndex(Index);
  Result:=FGraphicFrame;
end;

function TOOGraphicFrames.GetGraphicFrameByName(GraphicFrameName: string): TOOGraphicFrame;
begin
  FGraphicFrame.Document:=FDocument;
  FGraphicFrame.FrameObj:=FDocument.GetGraphicObjects.GetByName(GraphicFrameName);
  Result:=FGraphicFrame;
end;

// ******************************************************************************
{ TOOGraphicFrame }
// ******************************************************************************

procedure TOOGraphicFrame.LoadFromFile(FileName: string);
var
  SM, Ar: Variant;
  GP, GD: Variant;
  GType: TOpenGT;
begin
  if not FileExists(FileName) then
    Raise Exception.Create('File not found.');
  SM:=CreateOleObject('com.sun.star.ServiceManager');
  GP:=SM.CreateInstance('com.sun.star.graphic.GraphicProvider');
  Ar:=VarArrayCreate([0, 0], varVariant);
  Ar[0]:=MakePV(SM, 'URL', ConvertToURL(FileName));
  GD:=GP.QueryGraphicDescriptor(Ar);
  GType:=GD.GetPropertyValue('GraphicType');
  if GType<>ogtEmpty then
  begin
    if not VarIsClear(FFrameObj.Graphic) then
      FFrameObj.Graphic:=Unassigned;
    FFrameObj.Graphic:=GP.QueryGraphic(Ar);
  end;
  Ar:=Unassigned;
  GP:=Unassigned;
  SM:=Unassigned;
  if GType=ogtEmpty then
    Raise Exception.Create('File format not support.');
end;

function TOOGraphicFrame.GetSurroundContour: boolean;
begin
  Result:=FFrameObj.SurroundContour;
end;

procedure TOOGraphicFrame.SetSurroundContour(const Value: boolean);
begin
  FFrameObj.SurroundContour:=Value;
end;

function TOOGraphicFrame.GetContourOutside: boolean;
begin
  Result:=FFrameObj.ContourOutside;
end;

procedure TOOGraphicFrame.SetContourOutside(const Value: boolean);
begin
  FFrameObj.ContourOutside:=Value;
end;

function TOOGraphicFrame.GetCrop: TOpenGraphicCrop;
begin
  Result.Top:=FFrameObj.GraphicCrop.Top;
  Result.Bottom:=FFrameObj.GraphicCrop.Bottom;
  Result.Left:=FFrameObj.GraphicCrop.Left;
  Result.Right:=FFrameObj.GraphicCrop.Right;
end;

procedure TOOGraphicFrame.SetCrop(const Value: TOpenGraphicCrop);
var
  GC: Variant;
  SM: Variant;
begin
  SM:=CreateOleObject('com.sun.star.ServiceManager');
  GC:=SM.Bridge_GetStruct('com.sun.star.text.GraphicCrop');
  GC.Top:=Value.Top;
  GC.Bottom:=Value.Bottom;
  GC.Left:=Value.Left;
  GC.Right:=Value.Right;
  FFrameObj.GraphicCrop:=GC;
  GC:=Unassigned;
  SM:=Unassigned;
end;

function TOOGraphicFrame.GetHoriMirroredOnEvenPages: boolean;
begin
  Result:=FFrameObj.HoriMirroredOnEvenPages;
end;

procedure TOOGraphicFrame.SetHoriMirroredOnEvenPages(const Value: boolean);
begin
  FFrameObj.HoriMirroredOnEvenPages:=Value;
end;

function TOOGraphicFrame.GetHoriMirroredOnOddPages: boolean;
begin
  Result:=FFrameObj.HoriMirroredOnOddPages;
end;

procedure TOOGraphicFrame.SetHoriMirroredOnOddPages(const Value: boolean);
begin
  FFrameObj.HoriMirroredOnOddPages:=Value;
end;

function TOOGraphicFrame.GetVertMirrored: boolean;
begin
  Result:=FFrameObj.VertMirrored;
end;

procedure TOOGraphicFrame.SetVertMirrored(const Value: boolean);
begin
  FFrameObj.VertMirrored:=Value;
end;

function TOOGraphicFrame.GetActualSize: TOpenSize;
begin
  Result.Width:=FFrameObj.ActualSize.Width;
  Result.Height:=FFrameObj.ActualSize.Height;
end;

procedure TOOGraphicFrame.SetActualSize(const Value: TOpenSize);
var
  Sz: Variant;
  SM: Variant;
begin
  SM:=CreateOleObject('com.sun.star.ServiceManager');
  Sz:=SM.Bridge_GetStruct('com.sun.star.awt.Size');
  Sz.Width:=Value.Width;
  Sz.Height:=Value.Height;
  FFrameObj.ActualSize:=Sz;
  Sz:=Unassigned;
  SM:=Unassigned;
end;

function TOOGraphicFrame.GetAdjustLuminance: integer;
begin
  Result:=FFrameObj.AdjustLuminance;
end;

procedure TOOGraphicFrame.SetAdjustLuminance(const Value: integer);
begin
  FFrameObj.AdjustLuminance:=Value;
end;

function TOOGraphicFrame.GetAdjustContrast: integer;
begin
  Result:=FFrameObj.AdjustContrast;
end;

procedure TOOGraphicFrame.SetAdjustContrast(const Value: integer);
begin
  FFrameObj.AdjustContrast:=Value;
end;

function TOOGraphicFrame.GetAdjustRed: integer;
begin
  Result:=FFrameObj.AdjustRed;
end;

procedure TOOGraphicFrame.SetAdjustRed(const Value: integer);
begin
  FFrameObj.AdjustRed:=Value;
end;

function TOOGraphicFrame.GetAdjustGreen: integer;
begin
  Result:=FFrameObj.AdjustGreen;
end;

procedure TOOGraphicFrame.SetAdjustGreen(const Value: integer);
begin
  FFrameObj.AdjustGreen:=Value;
end;

function TOOGraphicFrame.GetAdjustBlue: integer;
begin
  Result:=FFrameObj.AdjustBlue;
end;

procedure TOOGraphicFrame.SetAdjustBlue(const Value: integer);
begin
  FFrameObj.AdjustBlue:=Value;
end;

function TOOGraphicFrame.GetGamma: double;
begin
  Result:=FFrameObj.Gamma;
end;

procedure TOOGraphicFrame.SetGamma(const Value: double);
begin
  FFrameObj.Gamma:=Value;
end;

function TOOGraphicFrame.GetIsInverted: boolean;
begin
  Result:=FFrameObj.GraphicIsInverted;
end;

procedure TOOGraphicFrame.SetIsInverted(const Value: boolean);
begin
  FFrameObj.GraphicIsInverted:=Value;
end;

function TOOGraphicFrame.GetTransparency: integer;
begin
  Result:=FFrameObj.Transparency;
end;

procedure TOOGraphicFrame.SetTransparency(const Value: integer);
begin
  FFrameObj.Transparency:=Value;
end;

function TOOGraphicFrame.GetColorMode: TOpenCR;
begin
  Result:=FFrameObj.GraphicColorMode;
end;

procedure TOOGraphicFrame.SetColorMode(const Value: TOpenCR);
begin
  FFrameObj.GraphicColorMode:=Ord(Value);
end;

// ******************************************************************************
{ TOOWriterPageStyle }
// ******************************************************************************

constructor TOOWriterPageStyle.Create;
begin
  inherited Create;
  FModelCursor:=TOOModelCursor.Create;
  FOldCursorType:=owhNone;
end;

destructor TOOWriterPageStyle.Destroy;
begin
  FModelCursor.Free;
  inherited;
end;

procedure TOOWriterPageStyle.FreeVariants;
begin
  inherited;
  FOldCursorType:=owhNone;
  FModelCursor.FreeVariants;
end;

function TOOWriterPageStyle.GetModelCursor(CursorType: TOpenWH): TOOModelCursor;
begin
  FModelCursor.FWriterHFType:=CursorType;
  if CursorType<>owhNone then
  begin
    if FOldCursorType<>CursorType then
    begin
      FModelCursor.CursorObj:=Unassigned;
      case CursorType of
      owhHeader:
      FModelCursor.CursorObj:=FStyleObj.HeaderText.GetText.CreateTextCursor;
      owhLeftPageHeader:
      FModelCursor.CursorObj:=FStyleObj.HeaderTextLeft.GetText.CreateTextCursor;
      owhRightPageHeader:
      FModelCursor.CursorObj:=FStyleObj.HeaderTextRight.GetText.CreateTextCursor;
      owhFooter:
      FModelCursor.CursorObj:=FStyleObj.FooterText.GetText.CreateTextCursor;
      owhLeftPageFooter:
      FModelCursor.CursorObj:=FStyleObj.FooterTextLeft.GetText.CreateTextCursor;
      owhRightPageFooter:
      FModelCursor.CursorObj:=FStyleObj.FooterTextRight.GetText.CreateTextCursor;
      end;
      FOldCursorType:=CursorType;
    end;
    FModelCursor.Document:=FDocument;
    Result:=FModelCursor;
  end
  else
    Raise Exception.Create('Cursor type "owhNone" only for internal use.');
end;

// ******************************************************************************
{ TOOBaseShape }
// ******************************************************************************

constructor TOOBaseShape.Create;
begin
  inherited;
  FSType:=ostNone;
  FLine:=TOOShLine.Create;
  FText:=TOOShText.Create;
  FShadow:=TOOShShadow.Create;
  FFill:=TOOShFill.Create;
end;

destructor TOOBaseShape.Destroy;
begin
  FFill.Free;
  FShadow.Free;
  FText.Free;
  FLine.Free;
  inherited;
end;

procedure TOOBaseShape.FreeVariants;
begin
  FShapeObj:=Unassigned;
  FLine.FreeVariants;
  FText.FreeVariants;
  FShadow.FreeVariants;
  FFill.FreeVariants;
end;

function TOOBaseShape.GetShapeType: string;
begin
  Result:=FShapeObj.GetShapeType;
end;

function TOOBaseShape.GetName: string;
begin
  Result:=FShapeObj.Name;
end;

procedure TOOBaseShape.SetName(const Value: string);
begin
  FShapeObj.Name:=Value;
end;

function TOOBaseShape.GetPositionProtect: boolean;
begin
  Result:=FShapeObj.MoveProtect;
end;

procedure TOOBaseShape.SetPositionProtect(const Value: boolean);
begin
  FShapeObj.MoveProtect:=Value;
end;

function TOOBaseShape.GetSizeProtect: boolean;
begin
  Result:=FShapeObj.SizeProtect;
end;

procedure TOOBaseShape.SetSizeProtect(const Value: boolean);
begin
  FShapeObj.SizeProtect:=Value;
end;

function TOOBaseShape.GetPrintable: boolean;
begin
  Result:=FShapeObj.Printable;
end;

procedure TOOBaseShape.SetPrintable(const Value: boolean);
begin
  FShapeObj.Printable:=Value;
end;

function TOOBaseShape.GetPosition: TOpenPoint;
var
  Pt: Variant;
begin
  Pt:=FShapeObj.GetPosition;
  Result.X:=Pt.X;
  Result.Y:=Pt.Y;
  Pt:=Unassigned;
end;

procedure TOOBaseShape.SetPosition(const Value: TOpenPoint);
var
  Pt: Variant;
  SM: Variant;
begin
  SM:=CreateOleObject('com.sun.star.ServiceManager');
  Pt:=SM.Bridge_GetStruct('com.sun.star.awt.Point');
  Pt.X:=Value.X;
  Pt.Y:=Value.Y;
  FShapeObj.SetPosition(Pt);
  Pt:=Unassigned;
  SM:=Unassigned;
end;

function TOOBaseShape.GetSize: TOpenSize;
var
  Sz: Variant;
begin
  Sz:=FShapeObj.GetSize;
  Result.Width:=Sz.Width;
  Result.Height:=Sz.Height;
  Sz:=Unassigned;
end;

procedure TOOBaseShape.SetSize(const Value: TOpenSize);
var
  Sz: Variant;
  SM: Variant;
begin
  SM:=CreateOleObject('com.sun.star.ServiceManager');
  Sz:=SM.Bridge_GetStruct('com.sun.star.awt.Size');
  Sz.Width:=Value.Width;
  Sz.Height:=Value.Height;
  FShapeObj.SetSize(Sz);
  Sz:=Unassigned;
  SM:=Unassigned;
end;

function TOOBaseShape.GetLine: TOOShLine;
begin
  FLine.Obj:=FShapeObj;
  Result:=FLine;
end;

function TOOBaseShape.GetText: TOOShText;
begin
  FText.Obj:=FShapeObj;
  Result:=FText;
end;

function TOOBaseShape.GetShadow: TOOShShadow;
begin
  FShadow.Obj:=FShapeObj;
  Result:=FShadow;
end;

function TOOBaseShape.GetFill: TOOShFill;
begin
  FFill.Obj:=FShapeObj;
  Result:=FFill;
end;

function TOOBaseShape.GetTransformation: TOpenMatrix;
var
  M: Variant;
begin
  M:=FShapeObj.Transformation;
  Result.L1.C1:=M.Line1.Column1;
  Result.L1.C2:=M.Line1.Column2;
  Result.L1.C3:=M.Line1.Column3;
  Result.L2.C1:=M.Line2.Column1;
  Result.L2.C2:=M.Line2.Column2;
  Result.L2.C3:=M.Line2.Column3;
  Result.L3.C1:=M.Line3.Column1;
  Result.L3.C2:=M.Line3.Column2;
  Result.L3.C3:=M.Line3.Column3;
  M:=Unassigned;
end;

procedure TOOBaseShape.SetTransformation(const Value: TOpenMatrix);
var
  M, L1, L2, L3: Variant;
  SM, UW: Variant;
begin
  SM:=CreateOleObject('com.sun.star.ServiceManager');
  M:=SM.Bridge_GetStruct('com.sun.star.drawing.HomogenMatrix3');
  L1:=SM.Bridge_GetStruct('com.sun.star.drawing.HomogenMatrixLine3');
  L2:=SM.Bridge_GetStruct('com.sun.star.drawing.HomogenMatrixLine3');
  L3:=SM.Bridge_GetStruct('com.sun.star.drawing.HomogenMatrixLine3');
  L1.Column1:=Value.L1.C1;
  L1.Column2:=Value.L1.C2;
  L1.Column3:=Value.L1.C3;
  L2.Column1:=Value.L2.C1;
  L2.Column2:=Value.L2.C2;
  L2.Column3:=Value.L2.C3;
  L3.Column1:=Value.L3.C1;
  L3.Column2:=Value.L3.C2;
  L3.Column3:=Value.L3.C3;
  M.Line1:=L1;
  M.Line2:=L2;
  M.Line3:=L3;
  UW:=SM.Bridge_GetValueObject;
  UW.{$IFDEF FPC} &Set {$ELSE} Set {$ENDIF}('com.sun.star.drawing.HomogenMatrix3', M);
  FShapeObj.Transformation:=UW;
  L1:=Unassigned;
  L2:=Unassigned;
  L3:=Unassigned;
  M:=Unassigned;
  SM:=Unassigned;
  UW:=Unassigned;
end;

// ******************************************************************************
{ TOOShapes }
// ******************************************************************************

constructor TOOBaseShapes.Create;
begin
  inherited;
  FSType:=ostNone;
end;

procedure TOOBaseShapes.FreeVariants;
begin
  FDocument:=Unassigned;
  FDrawPageObj:=Unassigned;
end;

function TOOBaseShapes.GetCount: integer;
var
  i: integer;
begin
  Result:=0;
  for i:=0 to FDrawPageObj.GetCount-1 do
    if FDrawPageObj.GetByIndex(i).GetShapeType=FSType then
      Result:=Result+1;
end;

procedure TOOBaseShapes.Append(X, Y, Width, Height: integer; ShapeName: string);
var
  Sh: Variant;
  Sz, PS: Variant;
  SM: Variant;
  i: integer;
  NameExist: boolean;
begin
  NameExist:=false;
  for i:=0 to FDrawPageObj.GetCount-1 do
    if FDrawPageObj.GetByIndex(i).Name=ShapeName then
      NameExist:=true;
  if NameExist then
    Raise Exception.Create('Shape with specified name already exist.');
  SM:=CreateOleObject('com.sun.star.ServiceManager');
  PS:=SM.Bridge_GetStruct('com.sun.star.awt.Point');
  PS.X:=X;
  PS.Y:=Y;
  Sz:=SM.Bridge_GetStruct('com.sun.star.awt.Size');
  Sz.Width:=Width;
  Sz.Height:=Height;
  Sh:=Document.CreateInstance(FSType);
  Sh.Position:=PS;
  Sh.Size:=Sz;
  Sh.Name:=ShapeName;
  FDrawPageObj.Add(Sh);
  Sz:=Unassigned;
  PS:=Unassigned;
  Sh:=Unassigned;
  SM:=Unassigned;
end;

function TOOBaseShapes.IsExist(ShapeName: string): boolean;
var
  i: integer;
begin
  Result:=false;
  for i:=0 to FDrawPageObj.GetCount-1 do
    if (FDrawPageObj.GetByIndex(i).GetShapeType=FSType)and(FDrawPageObj.GetByIndex(i).Name=ShapeName)
    then
      Result:=true;
end;

// ******************************************************************************
{ TOOTextShape }
// ******************************************************************************

constructor TOOTextShape.Create;
begin
  inherited;
  FSType:=ostText;
end;

function TOOTextShape.GetCornerRadius: integer;
begin
  Result:=FShapeObj.CornerRadius;
end;

procedure TOOTextShape.SetCornerRadius(const Value: integer);
begin
  FShapeObj.CornerRadius:=Value;
end;

// ******************************************************************************
{ TOOLineShape }
// ******************************************************************************

constructor TOOLineShape.Create;
begin
  inherited;
  FSType:=ostLine;
end;

// ******************************************************************************
{ TOOGraphicShape }
// ******************************************************************************

constructor TOOGraphicShape.Create;
begin
  inherited;
  FSType:=ostGraphic;
end;

procedure TOOGraphicShape.LoadFromFile(FileName: string);
var
  SM, Ar: Variant;
  GP, GD: Variant;
  GType: TOpenGT;
begin
  SM:=CreateOleObject('com.sun.star.ServiceManager');
  GP:=SM.CreateInstance('com.sun.star.graphic.GraphicProvider');
  Ar:=VarArrayCreate([0, 0], varVariant);
  Ar[0]:=MakePV(SM, 'URL', ConvertToURL(FileName));
  GD:=GP.QueryGraphicDescriptor(Ar);
  GType:=GD.GetPropertyValue('GraphicType');
  if GType<>ogtEmpty then
    FShapeObj.Graphic:=GP.QueryGraphic(Ar);
  if GType=ogtEmpty then
    Raise Exception.Create('File format not support.');
  GD:=Unassigned;
  Ar:=Unassigned;
  GP:=Unassigned;
  SM:=Unassigned;
end;

function TOOGraphicShape.GetAdjustTransparence: integer;
begin
  Result:=FShapeObj.Transparency;
end;

procedure TOOGraphicShape.SetAdjustTransparence(const Value: integer);
begin
  FShapeObj.Transparency:=Value;
end;

function TOOGraphicShape.GetAdjustLuminance: integer;
begin
  Result:=FShapeObj.AdjustLuminance;
end;

procedure TOOGraphicShape.SetAdjustLuminance(const Value: integer);
begin
  FShapeObj.AdjustLuminance:=Value;
end;

function TOOGraphicShape.GetAdjustContrast: integer;
begin
  Result:=FShapeObj.AdjustContrast;
end;

procedure TOOGraphicShape.SetAdjustContrast(const Value: integer);
begin
  FShapeObj.AdjustContrast:=Value;
end;

function TOOGraphicShape.GetAdjustRed: integer;
begin
  Result:=FShapeObj.AdjustRed;
end;

procedure TOOGraphicShape.SetAdjustRed(const Value: integer);
begin
  FShapeObj.AdjustRed:=Value;
end;

function TOOGraphicShape.GetAdjustGreen: integer;
begin
  Result:=FShapeObj.AdjustGreen;
end;

procedure TOOGraphicShape.SetAdjustGreen(const Value: integer);
begin
  FShapeObj.AdjustGreen:=Value;
end;

function TOOGraphicShape.GetAdjustBlue: integer;
begin
  Result:=FShapeObj.AdjustBlue;
end;

procedure TOOGraphicShape.SetAdjustBlue(const Value: integer);
begin
  FShapeObj.AdjustBlue:=Value;
end;

function TOOGraphicShape.GetGamma: double;
begin
  Result:=FShapeObj.Gamma;
end;

procedure TOOGraphicShape.SetGamma(const Value: double);
begin
  FShapeObj.Gamma:=Value;
end;

function TOOGraphicShape.GetColorMode: TOpenCR;
begin
  Result:=FShapeObj.ColorMode;
end;

procedure TOOGraphicShape.SetColorMode(const Value: TOpenCR);
begin
  FShapeObj.ColorMode:=Ord(Value);
end;

// ******************************************************************************
{ TOOTextShapes }
// ******************************************************************************

constructor TOOTextShapes.Create;
begin
  inherited;
  FSType:=ostText;
  FTextShape:=TOOTextShape.Create;
end;

destructor TOOTextShapes.Destroy;
begin
  FTextShape.Free;
  inherited;
end;

procedure TOOTextShapes.FreeVariants;
begin
  inherited;
  FTextShape.FreeVariants;
end;

function TOOTextShapes.GetTextShape(Index: integer): TOOTextShape;
var
  i, j: integer;
begin
  i:=GetCount;
  if (Index<0)or(Index>=i) then
    Raise Exception.Create('Text shape index out of bounds.');
  i:=0;
  for j:=0 to FDrawPageObj.GetCount-1 do
  begin
    if (FDrawPageObj.GetByIndex(j).GetShapeType=FSType) then
    begin
      if i=Index then
      begin
        i:=j;
        Break;
      end
      else
        i:=i+1;
    end;
  end;
  FTextShape.ShapeObj:=FDrawPageObj.GetByIndex(i);
  Result:=FTextShape;
end;

function TOOTextShapes.GetTextShapeByName(ShapeName: string): TOOTextShape;
var
  i, j: integer;
begin
  i:=-1;
  for j:=0 to FDrawPageObj.GetCount-1 do
    if (FDrawPageObj.GetByIndex(j).GetShapeType=FSType)and(FDrawPageObj.GetByIndex(j).Name=ShapeName)
    then
      i:=j;
  if (i<0) then
    Raise Exception.Create('Text shape with specified name does not exist.');
  FTextShape.ShapeObj:=FDrawPageObj.GetByIndex(i);
  Result:=FTextShape;
end;

// ******************************************************************************
{ TOOLineShapes }
// ******************************************************************************

constructor TOOLineShapes.Create;
begin
  inherited;
  FSType:=ostLine;
  FLineShape:=TOOLineShape.Create;
end;

destructor TOOLineShapes.Destroy;
begin
  FLineShape.Free;
  inherited;
end;

procedure TOOLineShapes.FreeVariants;
begin
  inherited;
  FLineShape.FreeVariants;
end;

function TOOLineShapes.GetLineShape(Index: integer): TOOLineShape;
var
  i, j: integer;
begin
  i:=GetCount;
  if (Index<0)or(Index>=i) then
    Raise Exception.Create('Line shape index out of bounds.');
  i:=0;
  for j:=0 to FDrawPageObj.GetCount-1 do
  begin
    if (FDrawPageObj.GetByIndex(j).GetShapeType=FSType) then
    begin
      if i=Index then
      begin
        i:=j;
        Break;
      end
      else
        i:=i+1;
    end;
  end;
  FLineShape.ShapeObj:=FDrawPageObj.GetByIndex(i);
  Result:=FLineShape;
end;

function TOOLineShapes.GetLineShapeByName(ShapeName: string): TOOLineShape;
var
  i, j: integer;
begin
  i:=-1;
  for j:=0 to FDrawPageObj.GetCount-1 do
    if (FDrawPageObj.GetByIndex(j).GetShapeType=FSType)and(FDrawPageObj.GetByIndex(j).Name=ShapeName)
    then
      i:=j;
  if (i<0) then
    Raise Exception.Create('Line shape with specified name does not exist.');
  FLineShape.ShapeObj:=FDrawPageObj.GetByIndex(i);
  Result:=FLineShape;
end;

// ******************************************************************************
{ TOOGraphicShapes }
// ******************************************************************************

constructor TOOGraphicShapes.Create;
begin
  inherited;
  FSType:=ostGraphic;
  FGraphicShape:=TOOGraphicShape.Create;
end;

destructor TOOGraphicShapes.Destroy;
begin
  FGraphicShape.Free;
  inherited;
end;

procedure TOOGraphicShapes.FreeVariants;
begin
  inherited;
  FGraphicShape.FreeVariants;
end;

function TOOGraphicShapes.GetGraphicShape(Index: integer): TOOGraphicShape;
var
  i, j: integer;
begin
  i:=GetCount;
  if (Index<0)or(Index>=i) then
    Raise Exception.Create('Graphic shape index out of bounds.');
  i:=0;
  for j:=0 to FDrawPageObj.GetCount-1 do
  begin
    if (FDrawPageObj.GetByIndex(j).GetShapeType=FSType) then
    begin
      if i=Index then
      begin
        i:=j;
        Break;
      end
      else
        i:=i+1;
    end;
  end;
  FGraphicShape.ShapeObj:=FDrawPageObj.GetByIndex(i);
  Result:=FGraphicShape;
end;

function TOOGraphicShapes.GetGraphicShapeByName(ShapeName: string): TOOGraphicShape;
var
  i, j: integer;
begin
  i:=-1;
  for j:=0 to FDrawPageObj.GetCount-1 do
    if (FDrawPageObj.GetByIndex(j).GetShapeType=FSType)and(FDrawPageObj.GetByIndex(j).Name=ShapeName)
    then
      i:=j;
  if (i<0) then
    Raise Exception.Create('Graphic shape with specified name does not exist.');
  FGraphicShape.ShapeObj:=FDrawPageObj.GetByIndex(i);
  Result:=FGraphicShape;
end;

// ******************************************************************************
{ TOOBaseShLine }
// ******************************************************************************

procedure TOOBaseShLine.FreeVariants;
begin
  FObj:=Unassigned;
end;

function TOOBaseShLine.GetColor: TColor;
var
  i: integer;
begin
  i:=FObj.LineColor;
  Result:=RGB(GetBValue(i), GetGValue(i), GetRValue(i));
end;

procedure TOOBaseShLine.SetColor(const Value: TColor);
begin
  FObj.LineColor:=RGB(GetBValue(Value), GetGValue(Value), GetRValue(Value));
end;

function TOOBaseShLine.GetWidth: integer;
begin
  Result:=FObj.LineWidth;
end;

procedure TOOBaseShLine.SetWidth(const Value: integer);
begin
  FObj.LineWidth:=Value;
end;

function TOOBaseShLine.GetStyle: TOpenSLS;
begin
  Result:=FObj.LineStyle;
end;

procedure TOOBaseShLine.SetStyle(const Value: TOpenSLS);
begin
  FObj.LineStyle:=Ord(Value);
end;

function TOOBaseShLine.GetDash: TOpenLineDash;
var
  DS: Variant;
begin
  DS:=FObj.LineDash;
  Result.Style:=DS.Style;
  Result.Dots:=DS.Dots;
  Result.DotLen:=DS.DotLen;
  Result.Dashes:=DS.Dashes;
  Result.DashLen:=DS.DashLen;
  Result.Distance:=DS.Distance;
  DS:=Unassigned;
end;

procedure TOOBaseShLine.SetDash(const Value: TOpenLineDash);
var
  DS: Variant;
  SM: Variant;
begin
  SM:=CreateOleObject('com.sun.star.ServiceManager');
  DS:=SM.Bridge_GetStruct('com.sun.star.drawing.LineDash');
  DS.Style:=Ord(Value.Style);
  DS.Dots:=Value.Dots;
  DS.DotLen:=Value.DotLen;
  DS.Dashes:=Value.Dashes;
  DS.DashLen:=Value.DashLen;
  DS.Distance:=Value.Distance;
  FObj.LineDash:=DS;
  DS:=Unassigned;
  SM:=Unassigned;
end;

function TOOBaseShLine.GetDashName: string;
begin
  Result:=FObj.LineDashName;
end;

procedure TOOBaseShLine.SetDashName(const Value: string);
begin
  FObj.LineDashName:=Value;
end;

function TOOBaseShLine.GetTransparence: integer;
begin
  Result:=FObj.LineTransparence;
end;

procedure TOOBaseShLine.SetTransparence(const Value: integer);
begin
  FObj.LineTransparence:=Value;
end;

function TOOBaseShLine.GetJoint: TOpenSLJ;
begin
  Result:=FObj.LineJoint;
end;

procedure TOOBaseShLine.SetJoint(const Value: TOpenSLJ);
begin
  FObj.LineJoint:=Ord(Value);
end;

// ******************************************************************************
{ TOOShLine }
// ******************************************************************************

function TOOShLine.GetStartName: string;
begin
  Result:=FObj.LineStartName;
end;

procedure TOOShLine.SetStartName(const Value: string);
begin
  FObj.LineStartName:=Value;
end;

function TOOShLine.GetEndName: string;
begin
  Result:=FObj.LineEndName;
end;

procedure TOOShLine.SetEndName(const Value: string);
begin
  FObj.LineEndName:=Value;
end;

function TOOShLine.GetStartCenter: boolean;
begin
  Result:=FObj.LineStartCenter;
end;

procedure TOOShLine.SetStartCenter(const Value: boolean);
begin
  FObj.LineStartCenter:=Value;
end;

function TOOShLine.GetEndCenter: boolean;
begin
  Result:=FObj.LineEndCenter;
end;

procedure TOOShLine.SetEndCenter(const Value: boolean);
begin
  FObj.LineEndCenter:=Value;
end;

function TOOShLine.GetStartWidth: integer;
begin
  Result:=FObj.LineStartWidth;
end;

procedure TOOShLine.SetStartWidth(const Value: integer);
begin
  FObj.LineStartWidth:=Value;
end;

function TOOShLine.GetEndWidth: integer;
begin
  Result:=FObj.LineEndWidth;
end;

procedure TOOShLine.SetEndWidth(const Value: integer);
begin
  FObj.LineEndWidth:=Value;
end;

// ******************************************************************************
{ TOOShText }
// ******************************************************************************

constructor TOOShText.Create;
begin
  inherited;
  FCursor:=TOOBaseTextCursor.Create;
  FOldName:='';
  FOldSType:='';
end;

destructor TOOShText.Destroy;
begin
  FCursor.Free;
  inherited;
end;

procedure TOOShText.FreeVariants;
begin
  FOldName:='';
  FOldSType:='';
  FObj:=Unassigned;
  FCursor.FreeVariants;
end;

function TOOShText.GetAutoGrowWidth: boolean;
begin
  Result:=FObj.TextAutoGrowWidth;
end;

procedure TOOShText.SetAutoGrowWidth(const Value: boolean);
begin
  FObj.TextAutoGrowWidth:=Value;
end;

function TOOShText.GetAutoGrowHeight: boolean;
begin
  Result:=FObj.TextAutoGrowHeight;
end;

procedure TOOShText.SetAutoGrowHeight(const Value: boolean);
begin
  FObj.TextAutoGrowHeight:=Value;
end;

function TOOShText.GetContourFrame: boolean;
begin
  Result:=FObj.TextContourFrame;
end;

procedure TOOShText.SetContourFrame(const Value: boolean);
begin
  FObj.TextContourFrame:=Value;
end;

function TOOShText.GetFitToSize: TOpenSTF;
begin
  Result:=FObj.TextFitToSize;
end;

procedure TOOShText.SetFitToSize(const Value: TOpenSTF);
begin
  FObj.TextFitToSize:=Ord(Value);
end;

function TOOShText.GetHoriAlignment: TOpenSHA;
begin
  Result:=FObj.TextHorizontalAdjust;
end;

procedure TOOShText.SetHoriAlignment(const Value: TOpenSHA);
begin
  FObj.TextHorizontalAdjust:=Ord(Value);
end;

function TOOShText.GetVertAlignment: TOpenSVA;
begin
  Result:=FObj.TextVerticalAdjust;
end;

procedure TOOShText.SetVertAlignment(const Value: TOpenSVA);
begin
  FObj.TextVerticalAdjust:=Ord(Value);
end;

function TOOShText.GetLeftDistance: integer;
begin
  Result:=FObj.TextLeftDistance;
end;

procedure TOOShText.SetLeftDistance(const Value: integer);
begin
  FObj.TextLeftDistance:=Value;
end;

function TOOShText.GetRightDistance: integer;
begin
  Result:=FObj.TextRightDistance;
end;

procedure TOOShText.SetRightDistance(const Value: integer);
begin
  FObj.TextRightDistance:=Value;
end;

function TOOShText.GetUpperDistance: integer;
begin
  Result:=FObj.TextUpperDistance;
end;

procedure TOOShText.SetUpperDistance(const Value: integer);
begin
  FObj.TextUpperDistance:=Value;
end;

function TOOShText.GetLowerDistance: integer;
begin
  Result:=FObj.TextLowerDistance;
end;

procedure TOOShText.SetLowerDistance(const Value: integer);
begin
  FObj.TextLowerDistance:=Value;
end;

function TOOShText.GetMinimumFrameWidth: integer;
begin
  Result:=FObj.TextMinimumFrameWidth;
end;

procedure TOOShText.SetMinimumFrameWidth(const Value: integer);
begin
  FObj.TextMinimumFrameWidth:=Value;
end;

function TOOShText.GetMinimumFrameHeight: integer;
begin
  Result:=FObj.TextMinimumFrameHeight;
end;

procedure TOOShText.SetMinimumFrameHeight(const Value: integer);
begin
  FObj.TextMinimumFrameHeight:=Value;
end;

function TOOShText.GetMaximumFrameWidth: integer;
begin
  Result:=FObj.TextMaximumFrameWidth;
end;

procedure TOOShText.SetMaximumFrameWidth(const Value: integer);
begin
  FObj.TextMaximumFrameWidth:=Value;
end;

function TOOShText.GetMaximumFrameHeight: integer;
begin
  Result:=FObj.TextMaximumFrameHeight;
end;

procedure TOOShText.SetMaximumFrameHeight(const Value: integer);
begin
  FObj.TextMaximumFrameHeight:=Value;
end;

function TOOShText.GetAnimationAmount: integer;
begin
  Result:=FObj.TextAnimationAmount;
end;

procedure TOOShText.SetAnimationAmount(const Value: integer);
begin
  FObj.TextAnimationAmount:=Value;
end;

function TOOShText.GetAnimationCount: integer;
begin
  Result:=FObj.TextAnimationCount;
end;

procedure TOOShText.SetAnimationCount(const Value: integer);
begin
  FObj.TextAnimationCount:=Value;
end;

function TOOShText.GetAnimationDelay: integer;
begin
  Result:=FObj.TextAnimationDelay;
end;

procedure TOOShText.SetAnimationDelay(const Value: integer);
begin
  FObj.TextAnimationDelay:=Value;
end;

function TOOShText.GetAnimationDirection: TOpenSAD;
begin
  Result:=FObj.TextAnimationDirection;
end;

procedure TOOShText.SetAnimationDirection(const Value: TOpenSAD);
begin
  FObj.TextAnimationDirection:=Ord(Value);
end;

function TOOShText.GetAnimationKind: TOpenSAK;
begin
  Result:=FObj.TextAnimationKind;
end;

procedure TOOShText.SetAnimationKind(const Value: TOpenSAK);
begin
  FObj.TextAnimationKind:=Ord(Value);
end;

function TOOShText.GetAnimationStartInside: boolean;
begin
  Result:=FObj.TextAnimationStartInside;
end;

procedure TOOShText.SetAnimationStartInside(const Value: boolean);
begin
  FObj.TextAnimationStartInside:=Value;
end;

function TOOShText.GetAnimationStopInside: boolean;
begin
  Result:=FObj.TextAnimationStopInside;
end;

procedure TOOShText.SetAnimationStopInside(const Value: boolean);
begin
  FObj.TextAnimationStopInside:=Value;
end;

function TOOShText.GetCursor: TOOBaseTextCursor;
begin
  if (FOldName=FObj.Name)and(FOldSType=FObj.GetShapeType) then
  begin
    Result:=FCursor;
  end
  else
  begin
    FCursor.CursorObj:=Unassigned;
    FCursor.CursorObj:=FObj.GetText.CreateTextCursor;
    FOldName:=FObj.Name;
    FOldSType:=FObj.GetShapeType;
    Result:=FCursor;
  end;
end;

// ******************************************************************************
{ TOOShShadow }
// ******************************************************************************

procedure TOOShShadow.FreeVariants;
begin
  FObj:=Unassigned;
end;

function TOOShShadow.GetEnable: boolean;
begin
  Result:=FObj.Shadow;
end;

procedure TOOShShadow.SetEnable(const Value: boolean);
begin
  FObj.Shadow:=Value;
end;

function TOOShShadow.GetColor: TColor;
var
  i: integer;
begin
  i:=FObj.ShadowColor;
  Result:=RGB(GetBValue(i), GetGValue(i), GetRValue(i));
end;

procedure TOOShShadow.SetColor(const Value: TColor);
begin
  FObj.ShadowColor:=RGB(GetBValue(Value), GetGValue(Value), GetRValue(Value));
end;

function TOOShShadow.GetTransparence: integer;
begin
  Result:=FObj.ShadowTransparence;
end;

procedure TOOShShadow.SetTransparence(const Value: integer);
begin
  FObj.ShadowTransparence:=Value;
end;

function TOOShShadow.GetXDistance: integer;
begin
  Result:=FObj.ShadowXDistance;
end;

procedure TOOShShadow.SetXDistance(const Value: integer);
begin
  FObj.ShadowXDistance:=Value;
end;

function TOOShShadow.GetYDistance: integer;
begin
  Result:=FObj.ShadowYDistance;
end;

procedure TOOShShadow.SetYDistance(const Value: integer);
begin
  FObj.ShadowYDistance:=Value;
end;

// ******************************************************************************
{ TOOShFill }
// ******************************************************************************

procedure TOOShFill.FreeVariants;
begin
  FObj:=Unassigned;
end;

function TOOShFill.GetStyle: TOpenSFS;
begin
  Result:=FObj.FillStyle;
end;

procedure TOOShFill.SetStyle(const Value: TOpenSFS);
begin
  FObj.FillStyle:=Ord(Value);
end;

function TOOShFill.GetColor: TColor;
var
  i: integer;
begin
  i:=FObj.FillColor;
  Result:=RGB(GetBValue(i), GetGValue(i), GetRValue(i));
end;

procedure TOOShFill.SetColor(const Value: TColor);
begin
  FObj.FillColor:=RGB(GetBValue(Value), GetGValue(Value), GetRValue(Value));
end;

function TOOShFill.GetTransparence: integer;
begin
  Result:=FObj.FillTransparence;
end;

procedure TOOShFill.SetTransparence(const Value: integer);
begin
  FObj.FillTransparence:=Value;
end;

function TOOShFill.GetTransparenceGradientName: string;
begin
  Result:=FObj.FillTransparenceGradientName;
end;

procedure TOOShFill.SetTransparenceGradientName(const Value: string);
begin
  FObj.FillTransparenceGradientName:=Value;
end;

function TOOShFill.GetTransparenceGradient: TOpenGradient;
var
  G: Variant;
begin
  G:=FObj.FillTransparenceGradient;
  Result.Style:=G.Style;
  Result.StartColor:=G.StartColor;
  Result.EndColor:=G.EndColor;
  Result.Angle:=G.Angle;
  Result.Border:=G.Border;
  Result.XOffset:=G.XOffset;
  Result.YOffset:=G.YOffset;
  Result.StartIntensity:=G.StartIntensity;
  Result.EndIntensity:=G.EndIntensity;
  Result.StepCount:=G.StepCount;
  G:=Unassigned;
end;

procedure TOOShFill.SetTransparenceGradient(const Value: TOpenGradient);
var
  G: Variant;
  SM: Variant;
begin
  SM:=CreateOleObject('com.sun.star.ServiceManager');
  G:=SM.Bridge_GetStruct('com.sun.star.awt.Gradient');
  G.Style:=Ord(Value.Style);
  G.StartColor:=Value.StartColor;
  G.EndColor:=Value.EndColor;
  G.Angle:=Value.Angle;
  G.Border:=Value.Border;
  G.XOffset:=Value.XOffset;
  G.YOffset:=Value.YOffset;
  G.StartIntensity:=Value.StartIntensity;
  G.EndIntensity:=Value.EndIntensity;
  G.StepCount:=Value.StepCount;
  FObj.FillTransparenceGradient:=G;
  G:=Unassigned;
  SM:=Unassigned;
end;

function TOOShFill.GetGradientName: string;
begin
  Result:=FObj.FillGradientName;
end;

procedure TOOShFill.SetGradientName(const Value: string);
begin
  FObj.FillGradientName:=Value;
end;

function TOOShFill.GetGradient: TOpenGradient;
var
  G: Variant;
begin
  G:=FObj.FillGradient;
  Result.Style:=G.Style;
  Result.StartColor:=G.StartColor;
  Result.EndColor:=G.EndColor;
  Result.Angle:=G.Angle;
  Result.Border:=G.Border;
  Result.XOffset:=G.XOffset;
  Result.YOffset:=G.YOffset;
  Result.StartIntensity:=G.StartIntensity;
  Result.EndIntensity:=G.EndIntensity;
  Result.StepCount:=G.StepCount;
  G:=Unassigned;
end;

procedure TOOShFill.SetGradient(const Value: TOpenGradient);
var
  G: Variant;
  SM: Variant;
begin
  SM:=CreateOleObject('com.sun.star.ServiceManager');
  G:=SM.Bridge_GetStruct('com.sun.star.awt.Gradient');
  G.Style:=Ord(Value.Style);
  G.StartColor:=Value.StartColor;
  G.EndColor:=Value.EndColor;
  G.Angle:=Value.Angle;
  G.Border:=Value.Border;
  G.XOffset:=Value.XOffset;
  G.YOffset:=Value.YOffset;
  G.StartIntensity:=Value.StartIntensity;
  G.EndIntensity:=Value.EndIntensity;
  G.StepCount:=Value.StepCount;
  FObj.FillGradient:=G;
  G:=Unassigned;
  SM:=Unassigned;
end;

function TOOShFill.GetHatchName: string;
begin
  Result:=FObj.FillHatchName;
end;

procedure TOOShFill.SetHatchName(const Value: string);
begin
  FObj.FillHatchName:=Value;
end;

function TOOShFill.GetHatch: TOpenHatch;
var
  H: Variant;
begin
  H:=FObj.FillHatch;
  Result.Style:=H.Style;
  Result.Color:=H.Color;
  Result.Distance:=H.Distance;
  Result.Angle:=H.Angle;
  H:=Unassigned;
end;

procedure TOOShFill.SetHatch(const Value: TOpenHatch);
var
  H: Variant;
  SM: Variant;
begin
  SM:=CreateOleObject('com.sun.star.ServiceManager');
  H:=SM.Bridge_GetStruct('com.sun.star.drawing.Hatch');
  H.Style:=Ord(Value.Style);
  H.Color:=Value.Color;
  H.Distance:=Value.Distance;
  H.Angle:=Value.Angle;
  FObj.FillHatch:=H;
  H:=Unassigned;
  SM:=Unassigned;
end;

function TOOShFill.GetBackground: boolean;
begin
  Result:=FObj.FillBackground;
end;

procedure TOOShFill.SetBackground(const Value: boolean);
begin
  FObj.FillBackground:=Value;
end;

// ******************************************************************************
{ TOOEllipseShape }
// ******************************************************************************

constructor TOOEllipseShape.Create;
begin
  inherited;
  FSType:=ostEllipse;
end;

function TOOEllipseShape.GetKind: TOpenSCK;
begin
  Result:=FShapeObj.CircleKind;
end;

procedure TOOEllipseShape.SetKind(const Value: TOpenSCK);
begin
  FShapeObj.CircleKind:=Ord(Value);
end;

function TOOEllipseShape.GetStartAngle: integer;
begin
  Result:=FShapeObj.CircleStartAngle;
end;

procedure TOOEllipseShape.SetStartAngle(const Value: integer);
begin
  FShapeObj.CircleStartAngle:=Value;
end;

function TOOEllipseShape.GetEndAngle: integer;
begin
  Result:=FShapeObj.CircleEndAngle;
end;

procedure TOOEllipseShape.SetEndAngle(const Value: integer);
begin
  FShapeObj.CircleEndAngle:=Value;
end;

// ******************************************************************************
{ TOOEllipseShapes }
// ******************************************************************************

constructor TOOEllipseShapes.Create;
begin
  inherited;
  FSType:=ostEllipse;
  FEllipseShape:=TOOEllipseShape.Create;
end;

destructor TOOEllipseShapes.Destroy;
begin
  FEllipseShape.Free;
  inherited;
end;

procedure TOOEllipseShapes.FreeVariants;
begin
  inherited;
  FEllipseShape.FreeVariants;
end;

function TOOEllipseShapes.GetEllipseShape(Index: integer): TOOEllipseShape;
var
  i, j: integer;
begin
  i:=GetCount;
  if (Index<0)or(Index>=i) then
    Raise Exception.Create('Ellipse shape index out of bounds.');
  i:=0;
  for j:=0 to FDrawPageObj.GetCount-1 do
  begin
    if (FDrawPageObj.GetByIndex(j).GetShapeType=FSType) then
    begin
      if i=Index then
      begin
        i:=j;
        Break;
      end
      else
        i:=i+1;
    end;
  end;
  FEllipseShape.ShapeObj:=FDrawPageObj.GetByIndex(i);
  Result:=FEllipseShape;
end;

function TOOEllipseShapes.GetEllipseShapeByName(ShapeName: string): TOOEllipseShape;
var
  i, j: integer;
begin
  i:=-1;
  for j:=0 to FDrawPageObj.GetCount-1 do
    if (FDrawPageObj.GetByIndex(j).GetShapeType=FSType)and(FDrawPageObj.GetByIndex(j).Name=ShapeName)
    then
      i:=j;
  if (i<0) then
    Raise Exception.Create('Ellipse shape with specified name does not exist.');
  FEllipseShape.ShapeObj:=FDrawPageObj.GetByIndex(i);
  Result:=FEllipseShape;
end;

// ******************************************************************************
{ TOORectangleShape }
// ******************************************************************************

constructor TOORectangleShape.Create;
begin
  inherited;
  FSType:=ostRectangle;
end;

function TOORectangleShape.GetCornerRadius: integer;
begin
  Result:=FShapeObj.CornerRadius;
end;

procedure TOORectangleShape.SetCornerRadius(const Value: integer);
begin
  FShapeObj.CornerRadius:=Value;
end;

// ******************************************************************************
{ TOORectangleShapes }
// ******************************************************************************

constructor TOORectangleShapes.Create;
begin
  inherited;
  FSType:=ostRectangle;
  FRectangleShape:=TOORectangleShape.Create;
end;

destructor TOORectangleShapes.Destroy;
begin
  FRectangleShape.Free;
  inherited;
end;

procedure TOORectangleShapes.FreeVariants;
begin
  inherited;
  FRectangleShape.FreeVariants;
end;

function TOORectangleShapes.GetRectangleShape(Index: integer): TOORectangleShape;
var
  i, j: integer;
  s: string;
begin
  i:=GetCount;
  if (Index<0)or(Index>=i) then
    Raise Exception.Create('Rectangle shape index out of bounds.');
  i:=0;
  for j:=0 to FDrawPageObj.GetCount-1 do
  begin
    s:=FDrawPageObj.GetByIndex(j).GetShapeType;
    if (s=FSType) then
    begin
      if i=Index then
      begin
        i:=j;
        Break;
      end
      else
        i:=i+1;
    end;
  end;
  FRectangleShape.ShapeObj:=FDrawPageObj.GetByIndex(i);
  Result:=FRectangleShape;
end;

function TOORectangleShapes.GetRectangleShapeByName(ShapeName: string): TOORectangleShape;
var
  i, j: integer;
begin
  i:=-1;
  for j:=0 to FDrawPageObj.GetCount-1 do
    if (FDrawPageObj.GetByIndex(j).GetShapeType=FSType)and(FDrawPageObj.GetByIndex(j).Name=ShapeName)
    then
      i:=j;
  if (i<0) then
    Raise Exception.Create('Rectangle shape with specified name does not exist.');
  FRectangleShape.ShapeObj:=FDrawPageObj.GetByIndex(i);
  Result:=FRectangleShape;
end;

// ******************************************************************************
{ TOOShapeCursor }
// ******************************************************************************

constructor TOOBaseTextCursor.Create;
begin
  inherited Create;
  FCursorType:=octOther;
end;

function TOOBaseTextCursor.GetText: string;
begin
  Result:=FCursorObj.GetString;
end;

procedure TOOBaseTextCursor.SetText(const Value: string);
begin
  FCursorObj.SetString(Value);
  if Assigned(FOnTextChange) then
    FOnTextChange(Self);
end;

procedure TOOBaseTextCursor.CollapseToStart;
begin
  FCursorObj.CollapseToStart;
end;

procedure TOOBaseTextCursor.CollapseToEnd;
begin
  FCursorObj.CollapseToEnd;
end;

procedure TOOBaseTextCursor.GotoEnd(Expand: boolean);
begin
  FCursorObj.GotoEnd(Expand);
  if not Expand then // бага(?), не работает снятие выделения
    CollapseToEnd; // поэтому снимем вручную
end;

function TOOBaseTextCursor.IsCollapsed: boolean;
begin
  Result:=FCursorObj.IsCollapsed;
end;

// ******************************************************************************
{ TOOMeasureShape }
// ******************************************************************************

constructor TOOMeasureShape.Create;
begin
  inherited;
  FSType:=ostMeasure;
end;

function TOOMeasureShape.GetStartPosition: TOpenPoint;
var
  Pt: Variant;
begin
  Pt:=FShapeObj.StartPosition;
  Result.X:=Pt.X;
  Result.Y:=Pt.Y;
  Pt:=Unassigned;
end;

procedure TOOMeasureShape.SetStartPosition(const Value: TOpenPoint);
var
  Pt: Variant;
  SM: Variant;
begin
  SM:=CreateOleObject('com.sun.star.ServiceManager');
  Pt:=SM.Bridge_GetStruct('com.sun.star.awt.Point');
  Pt.X:=Value.X;
  Pt.Y:=Value.Y;
  FShapeObj.StartPosition:=Pt;
  Pt:=Unassigned;
  SM:=Unassigned;
end;

function TOOMeasureShape.GetEndPosition: TOpenPoint;
var
  Pt: Variant;
begin
  Pt:=FShapeObj.EndPosition;
  Result.X:=Pt.X;
  Result.Y:=Pt.Y;
  Pt:=Unassigned;
end;

procedure TOOMeasureShape.SetEndPosition(const Value: TOpenPoint);
var
  Pt: Variant;
  SM: Variant;
begin
  SM:=CreateOleObject('com.sun.star.ServiceManager');
  Pt:=SM.Bridge_GetStruct('com.sun.star.awt.Point');
  Pt.X:=Value.X;
  Pt.Y:=Value.Y;
  FShapeObj.EndPosition:=Pt;
  Pt:=Unassigned;
  SM:=Unassigned;
end;

function TOOMeasureShape.GetBelowReferenceEdge: boolean;
begin
  Result:=FShapeObj.MeasureBelowReferenceEdge;
end;

procedure TOOMeasureShape.SetBelowReferenceEdge(const Value: boolean);
begin
  FShapeObj.MeasureBelowReferenceEdge:=Value;
end;

function TOOMeasureShape.GetHelpLine1Length: integer;
begin
  Result:=FShapeObj.MeasureHelpLine1Length;
end;

procedure TOOMeasureShape.SetHelpLine1Length(const Value: integer);
begin
  FShapeObj.MeasureHelpLine1Length:=Value;
end;

function TOOMeasureShape.GetHelpLine2Length: integer;
begin
  Result:=FShapeObj.MeasureHelpLine2Length;
end;

procedure TOOMeasureShape.SetHelpLine2Length(const Value: integer);
begin
  FShapeObj.MeasureHelpLine2Length:=Value;
end;

function TOOMeasureShape.GetHelpLineDistance: integer;
begin
  Result:=FShapeObj.MeasureHelpLineDistance;
end;

procedure TOOMeasureShape.SetHelpLineDistance(const Value: integer);
begin
  FShapeObj.MeasureHelpLineDistance:=Value;
end;

function TOOMeasureShape.GetHelpLineOverhang: integer;
begin
  Result:=FShapeObj.MeasureHelpLineOverhang;
end;

procedure TOOMeasureShape.SetHelpLineOverhang(const Value: integer);
begin
  FShapeObj.MeasureHelpLineOverhang:=Value;
end;

function TOOMeasureShape.GetKind: TOpenSMK;
begin
  Result:=FShapeObj.MeasureKind;
end;

procedure TOOMeasureShape.SetKind(const Value: TOpenSMK);
begin
  FShapeObj.MeasureKind:=Ord(Value);
end;

function TOOMeasureShape.GetLineDistance: integer;
begin
  Result:=FShapeObj.MeasureLineDistance;
end;

procedure TOOMeasureShape.SetLineDistance(const Value: integer);
begin
  FShapeObj.MeasureLineDistance:=Value;
end;

function TOOMeasureShape.GetOverhang: integer;
begin
  Result:=FShapeObj.MeasureOverhang;
end;

procedure TOOMeasureShape.SetOverhang(const Value: integer);
begin
  FShapeObj.MeasureOverhang:=Value;
end;

function TOOMeasureShape.GetShowUnit: boolean;
begin
  Result:=FShapeObj.MeasureShowUnit;
end;

procedure TOOMeasureShape.SetShowUnit(const Value: boolean);
begin
  FShapeObj.MeasureShowUnit:=Value;
end;

function TOOMeasureShape.GetTextAutoAngle: boolean;
begin
  Result:=FShapeObj.MeasureTextAutoAngle;
end;

procedure TOOMeasureShape.SetTextAutoAngle(const Value: boolean);
begin
  FShapeObj.MeasureTextAutoAngle:=Value;
end;

function TOOMeasureShape.GetTextAutoAngleView: integer;
begin
  Result:=FShapeObj.MeasureTextAutoAngleView;
end;

procedure TOOMeasureShape.SetTextAutoAngleView(const Value: integer);
begin
  FShapeObj.MeasureTextAutoAngleView:=Value;
end;

function TOOMeasureShape.GetTextFixedAngle: integer;
begin
  Result:=FShapeObj.MeasureTextFixedAngle;
end;

procedure TOOMeasureShape.SetTextFixedAngle(const Value: integer);
begin
  FShapeObj.MeasureTextFixedAngle:=Value;
end;

function TOOMeasureShape.GetTextHorizontalPosition: TOpenSMH;
begin
  Result:=FShapeObj.MeasureTextHorizontalPosition;
end;

procedure TOOMeasureShape.SetTextHorizontalPosition(const Value: TOpenSMH);
begin
  FShapeObj.MeasureTextHorizontalPosition:=Ord(Value);
end;

function TOOMeasureShape.GetTextVerticalPosition: TOpenSMV;
begin
  Result:=FShapeObj.MeasureTextVerticalPosition;
end;

procedure TOOMeasureShape.SetTextVerticalPosition(const Value: TOpenSMV);
begin
  FShapeObj.MeasureTextVerticalPosition:=Ord(Value);
end;

function TOOMeasureShape.GetTextIsFixedAngle: boolean;
begin
  Result:=FShapeObj.MeasureTextIsFixedAngle;
end;

procedure TOOMeasureShape.SetTextIsFixedAngle(const Value: boolean);
begin
  FShapeObj.MeasureTextIsFixedAngle:=Value;
end;

function TOOMeasureShape.GetTextRotate90: boolean;
begin
  Result:=FShapeObj.MeasureTextRotate90;
end;

procedure TOOMeasureShape.SetTextRotate90(const Value: boolean);
begin
  FShapeObj.MeasureTextRotate90:=Value;
end;

function TOOMeasureShape.GetTextUpsideDown: boolean;
begin
  Result:=FShapeObj.MeasureTextUpsideDown;
end;

procedure TOOMeasureShape.SetTextUpsideDown(const Value: boolean);
begin
  FShapeObj.MeasureTextUpsideDown:=Value;
end;

function TOOMeasureShape.GetDecimalPlaces: integer;
begin
  Result:=FShapeObj.MeasureDecimalPlaces;
end;

procedure TOOMeasureShape.SetDecimalPlaces(const Value: integer);
begin
  FShapeObj.MeasureDecimalPlaces:=Value;
end;

// ******************************************************************************
{ TOOMeasureShapes }
// ******************************************************************************

constructor TOOMeasureShapes.Create;
begin
  inherited;
  FSType:=ostMeasure;
  FMeasureShape:=TOOMeasureShape.Create;
end;

destructor TOOMeasureShapes.Destroy;
begin
  FMeasureShape.Free;
  inherited;
end;

procedure TOOMeasureShapes.FreeVariants;
begin
  inherited;
  FMeasureShape.FreeVariants;
end;

function TOOMeasureShapes.GetMeasureShape(Index: integer): TOOMeasureShape;
var
  i, j: integer;
begin
  i:=GetCount;
  if (Index<0)or(Index>=i) then
    Raise Exception.Create('Measure shape index out of bounds.');
  i:=0;
  for j:=0 to FDrawPageObj.GetCount-1 do
  begin
    if (FDrawPageObj.GetByIndex(j).GetShapeType=FSType) then
    begin
      if i=Index then
      begin
        i:=j;
        Break;
      end
      else
        i:=i+1;
    end;
  end;
  FMeasureShape.ShapeObj:=FDrawPageObj.GetByIndex(i);
  Result:=FMeasureShape;
end;

function TOOMeasureShapes.GetMeasureShapeByName(ShapeName: string): TOOMeasureShape;
var
  i, j: integer;
begin
  i:=-1;
  for j:=0 to FDrawPageObj.GetCount-1 do
    if (FDrawPageObj.GetByIndex(j).GetShapeType=FSType)and(FDrawPageObj.GetByIndex(j).Name=ShapeName)
    then
      i:=j;
  if (i<0) then
    Raise Exception.Create('Measure shape with specified name does not exist.');
  FMeasureShape.ShapeObj:=FDrawPageObj.GetByIndex(i);
  Result:=FMeasureShape;
end;

// ******************************************************************************
{ TOOCharts }
// ******************************************************************************

constructor TOOBaseCharts.Create;
begin
  inherited;
  FDType:='';
end;

procedure TOOBaseCharts.FreeVariants;
begin
  FDocument:=Unassigned;
  FSheetObj:=Unassigned;
end;

procedure TOOBaseCharts.Append(ChartName: string; Rect: TOpenRect;
  RangeAddresses: TOpenRangeAddresses; ColHeaders, RowHeaders: boolean);
var
  SM: Variant;
  RAd, Rc, Ar, ch: Variant;
  i: integer;
begin
  if FSheetObj.GetCharts.HasByName(ChartName) then
    Raise Exception.Create('Chart with specified name already exist.');
  SM:=CreateOleObject('com.sun.star.ServiceManager');
  Rc:=SM.Bridge_GetStruct('com.sun.star.awt.Rectangle');
  Rc.X:=Rect.X;
  Rc.Y:=Rect.Y;
  Rc.Width:=Rect.Width;
  Rc.Height:=Rect.Height;
  Ar:=VarArrayCreate([0, Length(RangeAddresses)-1], varVariant);
  RAd:=VarArrayCreate([0, Length(RangeAddresses)-1], varVariant);
  for i:=0 to Length(RangeAddresses)-1 do
  begin
    RAd[i]:=SM.Bridge_GetStruct('com.sun.star.table.CellRangeAddress');
    RAd[i].Sheet:=RangeAddresses[i].Sheet;
    RAd[i].StartColumn:=RangeAddresses[i].StartColumn;
    RAd[i].StartRow:=RangeAddresses[i].StartRow;
    RAd[i].EndColumn:=RangeAddresses[i].EndColumn;
    RAd[i].EndRow:=RangeAddresses[i].EndRow;
    Ar[i]:=RAd[i];
  end;
  FSheetObj.GetCharts.AddNewByName(ChartName, Rc, Ar, ColHeaders, RowHeaders);
  ch:=FSheetObj.GetCharts.GetByName(ChartName).EmbeddedObject;
  ch.SetDiagram(ch.CreateInstance(FDType));
  Ar:=Unassigned;
  Rc:=Unassigned;
  for i:=0 to Length(RangeAddresses)-1 do
    RAd[i]:=Unassigned;
  SM:=Unassigned;
end;

procedure TOOBaseCharts.Delete(ChartName: string);
begin
  FSheetObj.GetCharts.RemoveByName(ChartName);
end;

function TOOBaseCharts.GetCount: integer;
var
  i: integer;
  ch: Variant;
begin
  Result:=0;
  for i:=0 to FSheetObj.GetCharts.GetCount-1 do
  begin
    ch:=FSheetObj.GetCharts.GetByIndex(i);
    if ch.EmbeddedObject.GetDiagram.GetDiagramType=FDType then
      Result:=Result+1;
  end;
  ch:=Unassigned;
end;

function TOOBaseCharts.IsExist(ChartName: string): boolean;
begin
  Result:=FSheetObj.GetCharts.HasByName(ChartName);
end;

// ******************************************************************************
{ TOOBaseChart }
// ******************************************************************************

constructor TOOBaseChart.Create;
begin
  inherited;
  FDType:='';
  FMainTitle:=TOOChartTitle.Create;
  FSubTitle:=TOOChartTitle.Create;
  FLegend:=TOOChartLegend.Create;
  FDataRow:=TOOChartDataRow.Create;;
  FDataPoint:=TOOChartDataPoint.Create;
end;

destructor TOOBaseChart.Destroy;
begin
  FDataPoint.Free;
  FDataRow.Free;
  FLegend.Free;
  FSubTitle.Free;
  FMainTitle.Free;
  inherited;
end;

procedure TOOBaseChart.FreeVariants;
begin
  FDocument:=Unassigned;
  FObj:=Unassigned;
  FMainTitle.FreeVariants;
  FSubTitle.FreeVariants;
  FLegend.FreeVariants;
  FDataRow.FreeVariants;
  FDataPoint.FreeVariants;
end;

function TOOBaseChart.GetHasMainTitle: boolean;
begin
  Result:=FObj.HasMainTitle;
end;

procedure TOOBaseChart.SetHasMainTitle(const Value: boolean);
begin
  FObj.HasMainTitle:=Value;
end;

function TOOBaseChart.GetDiagramType: string;
begin
  Result:=FObj.GetDiagram.GetDiagramType;
end;

function TOOBaseChart.GetMainTitle: TOOChartTitle;
begin
  FMainTitle.Obj:=FObj.GetTitle;
  Result:=FMainTitle;
end;

function TOOBaseChart.GetHasSubTitle: boolean;
begin
  Result:=FObj.HasSubTitle;
end;

procedure TOOBaseChart.SetHasSubTitle(const Value: boolean);
begin
  FObj.HasSubTitle:=Value;
end;

function TOOBaseChart.GetSubTitle: TOOChartTitle;
begin
  FSubTitle.Obj:=FObj.GetSubTitle;
  Result:=FSubTitle;
end;

function TOOBaseChart.GetHasLegend: boolean;
begin
  Result:=FObj.HasLegend;
end;

procedure TOOBaseChart.SetHasLegend(const Value: boolean);
begin
  FObj.HasLegend:=Value;
end;

function TOOBaseChart.GetLegend: TOOChartLegend;
begin
  FLegend.Obj:=FObj.GetLegend;
  Result:=FLegend;
end;

function TOOBaseChart.GetDim3D: boolean;
begin
  Result:=FObj.GetDiagram.Dim3D;
end;

procedure TOOBaseChart.SetDim3D(const Value: boolean);
begin
  FObj.GetDiagram.Dim3D:=Value;
end;

function TOOBaseChart.GetPerspective: integer;
begin
  Result:=FObj.GetDiagram.Perspective;
end;

procedure TOOBaseChart.SetPerspective(const Value: integer);
begin
  FObj.GetDiagram.Perspective:=Value;
end;

function TOOBaseChart.GetRotationHorizontal: integer;
begin
  Result:=FObj.GetDiagram.RotationHorizontal;
end;

procedure TOOBaseChart.SetRotationHorizontal(const Value: integer);
begin
  FObj.GetDiagram.RotationHorizontal:=Value;
end;

function TOOBaseChart.GetRotationVertical: integer;
begin
  Result:=FObj.GetDiagram.RotationVertical;
end;

procedure TOOBaseChart.SetRotationVertical(const Value: integer);
begin
  FObj.GetDiagram.RotationVertical:=Value;
end;

function TOOBaseChart.GetPercent: boolean;
begin
  Result:=FObj.GetDiagram.Percent;
end;

procedure TOOBaseChart.SetPercent(const Value: boolean);
begin
  FObj.GetDiagram.Percent:=Value;
end;

function TOOBaseChart.GetStacked: boolean;
begin
  Result:=FObj.GetDiagram.Stacked;
end;

procedure TOOBaseChart.SetStacked(const Value: boolean);
begin
  FObj.GetDiagram.Stacked:=Value;
end;

function TOOBaseChart.GetDataCaption: integer;
begin
  Result:=FObj.GetDiagram.DataCaption;
end;

procedure TOOBaseChart.SetDataCaption(const Value: integer);
begin
  FObj.GetDiagram.DataCaption:=Value;
end;

function TOOBaseChart.GetDataSource: TOpenCDS;
begin
  Result:=FObj.GetDiagram.DataRowSource;
end;

procedure TOOBaseChart.SetDataSource(const Value: TOpenCDS);
begin
  FObj.GetDiagram.DataRowSource:=Ord(Value);
end;

function TOOBaseChart.GetDataRow(Index: integer): TOOChartDataRow;
begin
  try
    FDataRow.Obj:=FObj.GetDiagram.GetDataRowProperties(Index);
  except
    Raise Exception.Create('Data row index out of bounds.');
  end;
  Result:=FDataRow;
end;

function TOOBaseChart.GetDataPoint(DataRow, PointIndex: integer): TOOChartDataPoint;
begin
  try
    FDataPoint.Obj:=FObj.GetDiagram.GetDataPointProperties(PointIndex, DataRow);
  except
    Raise Exception.Create('Data point index out of bounds.');
  end;
  Result:=FDataPoint;
end;

// ******************************************************************************
{ TOOBaseChartObj }
// ******************************************************************************

constructor TOOBaseChartObj.Create;
begin
  inherited;
  FFont:=TOOCharProperties.Create;
  FLine:=TOOBaseShLine.Create;
end;

destructor TOOBaseChartObj.Destroy;
begin
  FLine.Free;
  FFont.Free;
  inherited;
end;

procedure TOOBaseChartObj.FreeVariants;
begin
  FObj:=Unassigned;
  FFont.FreeVariants;
  FLine.FreeVariants;
end;

function TOOBaseChartObj.GetPosition: TOpenPoint;
var
  Pt: Variant;
begin
  Pt:=FObj.GetPosition;
  Result.X:=Pt.X;
  Result.Y:=Pt.Y;
  Pt:=Unassigned;
end;

procedure TOOBaseChartObj.SetPosition(const Value: TOpenPoint);
var
  Pt: Variant;
  SM: Variant;
begin
  SM:=CreateOleObject('com.sun.star.ServiceManager');
  Pt:=SM.Bridge_GetStruct('com.sun.star.awt.Point');
  Pt.X:=Value.X;
  Pt.Y:=Value.Y;
  FObj.SetPosition(Pt);
  Pt:=Unassigned;
  SM:=Unassigned;
end;

function TOOBaseChartObj.GetFont: TOOCharProperties;
begin
  FFont.CharPropertiesObj:=FObj;
  Result:=FFont;
end;

function TOOBaseChartObj.GetLine: TOOBaseShLine;
begin
  FLine.Obj:=FObj;
  Result:=FLine;
end;

// ******************************************************************************
{ TOOChartTitle }
// ******************************************************************************

function TOOChartTitle.GetText: string;
begin
  Result:=FObj.{$IFDEF FPC} &String {$ELSE} String {$ENDIF};
end;

procedure TOOChartTitle.SetText(const Value: string);
begin
  FObj.{$IFDEF FPC} &String {$ELSE} String {$ENDIF}:=Value;
end;

function TOOChartTitle.GetRotation: integer;
begin
  Result:=FObj.TextRotation;
end;

procedure TOOChartTitle.SetRotation(const Value: integer);
begin
  FObj.TextRotation:=Value;
end;

// ******************************************************************************
{ TOOChartLegend }
// ******************************************************************************

function TOOChartLegend.GetAlignment: TOpenCLP;
begin
  Result:=FObj.Alignment;
end;

procedure TOOChartLegend.SetAlignment(const Value: TOpenCLP);
begin
  FObj.Alignment:=Ord(Value);
end;

// ******************************************************************************
{ TOOBarChart }
// ******************************************************************************

constructor TOOBarChart.Create;
begin
  inherited;
  FDType:=odgBar;
end;

function TOOBarChart.GetVertical: boolean;
begin
  Result:=not FObj.GetDiagram.Vertical;
end;

procedure TOOBarChart.SetVertical(const Value: boolean);
begin
  FObj.GetDiagram.Vertical:=not Value;
end;

function TOOBarChart.GetDeep: boolean;
begin
  Result:=FObj.GetDiagram.Deep;
end;

procedure TOOBarChart.SetDeep(const Value: boolean);
begin
  FObj.GetDiagram.Deep:=Value;
end;

// ******************************************************************************
{ TOOBarCharts }
// ******************************************************************************

constructor TOOBarCharts.Create;
begin
  inherited;
  FDType:=odgBar;
  FBarChart:=TOOBarChart.Create;
end;

destructor TOOBarCharts.Destroy;
begin
  FBarChart.Free;
  inherited;
end;

procedure TOOBarCharts.FreeVariants;
begin
  inherited;
  FBarChart.FreeVariants;
end;

function TOOBarCharts.GetBarChart(Index: integer): TOOBarChart;
var
  i, k: integer;
begin
  if (Index<0)or(Index>=GetCount) then
    Raise Exception.Create('BarChart index out of bounds.');
  FBarChart.Obj:=Unassigned;
  FBarChart.Document:=FDocument;
  k:=0;
  for i:=0 to FSheetObj.GetCharts.GetCount-1 do
  begin
    if FSheetObj.GetCharts.GetByIndex(i).EmbeddedObject.GetDiagram.GetDiagramType=FDType then
    begin
      if k=Index then
      begin
        FBarChart.Obj:=FSheetObj.GetCharts.GetByIndex(i).EmbeddedObject;
        Break;
      end;
      k:=k+1;
    end;
  end;
  Result:=FBarChart;
end;

function TOOBarCharts.GetBarChartByName(ChartName: string): TOOBarChart;
begin
  if FSheetObj.GetCharts.GetByName(ChartName).EmbeddedObject.GetDiagram.GetDiagramType<>FDType then
    Raise Exception.Create('Chart "'+ChartName+'" is not a bar chart.');
  FBarChart.Document:=FDocument;
  FBarChart.Obj:=FSheetObj.GetCharts.GetByName(ChartName).EmbeddedObject;
  Result:=FBarChart;
end;

// ******************************************************************************
{ TOOLineChart }
// ******************************************************************************

constructor TOOLineChart.Create;
begin
  inherited;
  FDType:=odgLine;
end;

function TOOLineChart.GetSymbolType: integer;
begin
  Result:=FObj.GetDiagram.SymbolType;
end;

procedure TOOLineChart.SetSymbolType(const Value: integer);
begin
  FObj.GetDiagram.SymbolType:=Value;
end;

function TOOLineChart.GetSymbolSize: TOpenSize;
var
  Sz: Variant;
begin
  Sz:=FObj.GetDiagram.SymbolSize;
  Result.Width:=Sz.Width;
  Result.Height:=Sz.Height;
  Sz:=Unassigned;
end;

procedure TOOLineChart.SetSymbolSize(const Value: TOpenSize);
var
  Sz: Variant;
  SM: Variant;
begin
  SM:=CreateOleObject('com.sun.star.ServiceManager');
  Sz:=SM.Bridge_GetStruct('com.sun.star.awt.Size');
  Sz.Width:=Value.Width;
  Sz.Height:=Value.Height;
  FObj.GetDiagram.SymbolSize:=Sz;
  Sz:=Unassigned;
  SM:=Unassigned;
end;

function TOOLineChart.GetShowLines: boolean;
begin
  Result:=FObj.GetDiagram.Lines;
end;

procedure TOOLineChart.SetShowLines(const Value: boolean);
begin
  FObj.GetDiagram.Lines:=Value;
end;

function TOOLineChart.GetSplineType: TOpenSPT;
begin
  Result:=FObj.GetDiagram.SplineType;
end;

procedure TOOLineChart.SetSplineType(const Value: TOpenSPT);
begin
  FObj.GetDiagram.SplineType:=Ord(Value);
end;

function TOOLineChart.GetSplineOrder: integer;
begin
  Result:=FObj.GetDiagram.SplineOrder;
end;

procedure TOOLineChart.SetSplineOrder(const Value: integer);
begin
  FObj.GetDiagram.SplineOrder:=Value;
end;

function TOOLineChart.GetSplineResolution: integer;
begin
  Result:=FObj.GetDiagram.SplineResolution;
end;

procedure TOOLineChart.SetSplineResolution(const Value: integer);
begin
  FObj.GetDiagram.SplineResolution:=Value;
end;

// ******************************************************************************
{ TOOLineCharts }
// ******************************************************************************

constructor TOOLineCharts.Create;
begin
  inherited;
  FDType:=odgLine;
  FLineChart:=TOOLineChart.Create;
end;

destructor TOOLineCharts.Destroy;
begin
  FLineChart.Free;
  inherited;
end;

procedure TOOLineCharts.FreeVariants;
begin
  inherited;
  FLineChart.FreeVariants;
end;

function TOOLineCharts.GetLineChart(Index: integer): TOOLineChart;
var
  i, k: integer;
begin
  if (Index<0)or(Index>=GetCount) then
    Raise Exception.Create('LineChart index out of bounds.');
  FLineChart.Obj:=Unassigned;
  FLineChart.Document:=FDocument;
  k:=0;
  for i:=0 to FSheetObj.GetCharts.GetCount-1 do
  begin
    if FSheetObj.GetCharts.GetByIndex(i).EmbeddedObject.GetDiagram.GetDiagramType=FDType then
    begin
      if k=Index then
      begin
        FLineChart.Obj:=FSheetObj.GetCharts.GetByIndex(i).EmbeddedObject;
        Break;
      end;
      k:=k+1;
    end;
  end;
  Result:=FLineChart;
end;

function TOOLineCharts.GetLineChartByName(ChartName: string): TOOLineChart;
begin
  if FSheetObj.GetCharts.GetByName(ChartName).EmbeddedObject.GetDiagram.GetDiagramType<>FDType then
    Raise Exception.Create('Chart "'+ChartName+'" is not a line chart.');
  FLineChart.Document:=FDocument;
  FLineChart.Obj:=FSheetObj.GetCharts.GetByName(ChartName).EmbeddedObject;
  Result:=FLineChart;
end;

// ******************************************************************************
{ TOOChartDataRow }
// ******************************************************************************

constructor TOOChartDataRow.Create;
begin
  inherited;
  FDataPoint:=TOOChartDataPoint.Create;
end;

destructor TOOChartDataRow.Destroy;
begin
  FDataPoint.Free;
  inherited;
end;

procedure TOOChartDataRow.FreeVariants;
begin
  FDataPoint.FreeVariants;
  FObj:=Unassigned;
end;

function TOOChartDataRow.GetDataPoint: TOOChartDataPoint;
begin
  FDataPoint.Obj:=FObj;
  Result:=FDataPoint;
end;

// ******************************************************************************
{ TOOChartDataPoint }
// ******************************************************************************

constructor TOOChartDataPoint.Create;
begin
  inherited;
  FFont:=TOOCharProperties.Create;
  FLine:=TOOBaseShLine.Create;
  FFill:=TOOShFill.Create;
end;

destructor TOOChartDataPoint.Destroy;
begin
  FFill.Free;
  FLine.Free;
  FFont.Free;
  inherited;
end;

procedure TOOChartDataPoint.FreeVariants;
begin
  FObj:=Unassigned;
  FLine.FreeVariants;
  FFont.FreeVariants;
  FFill.FreeVariants;
end;

function TOOChartDataPoint.GetDataCaption: integer;
begin
  Result:=FObj.DataCaption;
end;

procedure TOOChartDataPoint.SetDataCaption(const Value: integer);
begin
  FObj.DataCaption:=Value;
end;

function TOOChartDataPoint.GetLabelSeparator: string;
begin
  Result:=FObj.LabelSeparator;
end;

procedure TOOChartDataPoint.SetLabelSeparator(const Value: string);
begin
  FObj.LabelSeparator:=Value;
end;

function TOOChartDataPoint.GetNumberFormat: integer;
begin
  Result:=FObj.NumberFormat;
end;

procedure TOOChartDataPoint.SetNumberFormat(const Value: integer);
begin
  FObj.NumberFormat:=Value;
end;

function TOOChartDataPoint.GetPercentNumberFormat: integer;
begin
  Result:=FObj.PercentageNumberFormat;
end;

procedure TOOChartDataPoint.SetPercentNumberFormat(const Value: integer);
begin
  FObj.PercentageNumberFormat:=Value;
end;

function TOOChartDataPoint.GetLabelPlacement: TOpenDLP;
begin
  Result:=FObj.LabelPlacement;
end;

procedure TOOChartDataPoint.SetLabelPlacement(const Value: TOpenDLP);
begin
  FObj.LabelPlacement:=Ord(Value);
end;

function TOOChartDataPoint.GetSymbolType: integer;
begin
  Result:=FObj.SymbolType;
end;

procedure TOOChartDataPoint.SetSymbolType(const Value: integer);
begin
  FObj.SymbolType:=Value;
end;

function TOOChartDataPoint.GetSegmentOffset: integer;
begin
  Result:=FObj.SegmentOffset;
end;

procedure TOOChartDataPoint.SetSegmentOffset(const Value: integer);
begin
  FObj.SegmentOffset:=Value;
end;

function TOOChartDataPoint.GetBar3DType: TOpenCST;
begin
  Result:=FObj.SolidType;
end;

procedure TOOChartDataPoint.SetBar3DType(const Value: TOpenCST);
begin
  FObj.SolidType:=Ord(Value);
end;

function TOOChartDataPoint.GetFont: TOOCharProperties;
begin
  FFont.CharPropertiesObj:=FObj;
  Result:=FFont;
end;

function TOOChartDataPoint.GetLine: TOOBaseShLine;
begin
  FLine.Obj:=FObj;
  Result:=FLine;
end;

function TOOChartDataPoint.GetFill: TOOShFill;
begin
  FFill.Obj:=FObj;
  Result:=FFill;
end;

function TOOChartDataPoint.GetLabelRotation: integer;
begin
  Result:=FObj.TextRotation;
end;

procedure TOOChartDataPoint.SetLabelRotation(const Value: integer);
begin
  FObj.TextRotation:=Value;
end;

// ******************************************************************************
{ TOOPieChart }
// ******************************************************************************

constructor TOOPieChart.Create;
begin
  inherited;
  FDType:=odgPie;
end;

// ******************************************************************************
{ TOOPieCharts }
// ******************************************************************************

constructor TOOPieCharts.Create;
begin
  inherited;
  FDType:=odgPie;
  FPieChart:=TOOPieChart.Create;
end;

destructor TOOPieCharts.Destroy;
begin
  FPieChart.Free;
  inherited;
end;

procedure TOOPieCharts.FreeVariants;
begin
  inherited;
  FPieChart.FreeVariants;
end;

function TOOPieCharts.GetPieChart(Index: integer): TOOPieChart;
var
  i, k: integer;
begin
  if (Index<0)or(Index>=GetCount) then
    Raise Exception.Create('PieChart index out of bounds.');
  FPieChart.Obj:=Unassigned;
  FPieChart.Document:=FDocument;
  k:=0;
  for i:=0 to FSheetObj.GetCharts.GetCount-1 do
  begin
    if FSheetObj.GetCharts.GetByIndex(i).EmbeddedObject.GetDiagram.GetDiagramType=FDType then
    begin
      if k=Index then
      begin
        FPieChart.Obj:=FSheetObj.GetCharts.GetByIndex(i).EmbeddedObject;
        Break;
      end;
      k:=k+1;
    end;
  end;
  Result:=FPieChart;
end;

function TOOPieCharts.GetPieChartByName(ChartName: string): TOOPieChart;
begin
  if FSheetObj.GetCharts.GetByName(ChartName).EmbeddedObject.GetDiagram.GetDiagramType<>FDType then
    Raise Exception.Create('Chart "'+ChartName+'" is not a pie chart.');
  FPieChart.Document:=FDocument;
  FPieChart.Obj:=FSheetObj.GetCharts.GetByName(ChartName).EmbeddedObject;
  Result:=FPieChart;
end;

// ******************************************************************************
{ TOOAreaChart }
// ******************************************************************************

constructor TOOAreaChart.Create;
begin
  inherited;
  FDType:=odgArea;
end;

function TOOAreaChart.GetDeep: boolean;
begin
  Result:=FObj.GetDiagram.Deep;
end;

procedure TOOAreaChart.SetDeep(const Value: boolean);
begin
  FObj.GetDiagram.Deep:=Value;
end;

function TOOAreaChart.GetVertical: boolean;
begin
  Result:=not FObj.GetDiagram.Vertical;
end;

procedure TOOAreaChart.SetVertical(const Value: boolean);
begin
  FObj.GetDiagram.Vertical:=not Value;
end;

// ******************************************************************************
{ TOOAreaCharts }
// ******************************************************************************

constructor TOOAreaCharts.Create;
begin
  inherited;
  FDType:=odgArea;
  FAreaChart:=TOOAreaChart.Create;
end;

destructor TOOAreaCharts.Destroy;
begin
  FAreaChart.Free;
  inherited;
end;

procedure TOOAreaCharts.FreeVariants;
begin
  inherited;
  FAreaChart.FreeVariants;
end;

function TOOAreaCharts.GetAreaChart(Index: integer): TOOAreaChart;
var
  i, k: integer;
begin
  if (Index<0)or(Index>=GetCount) then
    Raise Exception.Create('AreaChart index out of bounds.');
  FAreaChart.Obj:=Unassigned;
  FAreaChart.Document:=FDocument;
  k:=0;
  for i:=0 to FSheetObj.GetCharts.GetCount-1 do
  begin
    if FSheetObj.GetCharts.GetByIndex(i).EmbeddedObject.GetDiagram.GetDiagramType=FDType then
    begin
      if k=Index then
      begin
        FAreaChart.Obj:=FSheetObj.GetCharts.GetByIndex(i).EmbeddedObject;
        Break;
      end;
      k:=k+1;
    end;
  end;
  Result:=FAreaChart;
end;

function TOOAreaCharts.GetAreaChartByName(ChartName: string): TOOAreaChart;
begin
  if FSheetObj.GetCharts.GetByName(ChartName).EmbeddedObject.GetDiagram.GetDiagramType<>FDType then
    Raise Exception.Create('Chart "'+ChartName+'" is not a area chart.');
  FAreaChart.Document:=FDocument;
  FAreaChart.Obj:=FSheetObj.GetCharts.GetByName(ChartName).EmbeddedObject;
  Result:=FAreaChart;
end;

// ******************************************************************************
{ TOOGlobalLocale }
// ******************************************************************************

procedure TOOGlobalLocale.FreeVariants;
begin
  FDocument:=Unassigned;
end;

function TOOGlobalLocale.DateSeparator: string;
var
  L: Variant;
  LI: Variant;
  SM: Variant;
  LocaleData: Variant;
begin
  SM:=CreateOleObject('com.sun.star.ServiceManager');
  LocaleData:=SM.CreateInstance('com.sun.star.i18n.LocaleData');
  L:=FDocument.CharLocale;
  LI:=LocaleData.GetLocaleItem(L);
  Result:=LI.DateSeparator;
  LocaleData:=Unassigned;
  L:=Unassigned;
  LI:=Unassigned;
  SM:=Unassigned;
end;

function TOOGlobalLocale.DateSeparator(Language, Country, VarLocale: string): string;
var
  L: Variant;
  LI: Variant;
  SM: Variant;
  LocaleData: Variant;
begin
  SM:=CreateOleObject('com.sun.star.ServiceManager');
  LocaleData:=SM.CreateInstance('com.sun.star.i18n.LocaleData');
  L:=SM.Bridge_GetStruct('com.sun.star.lang.Locale');
  L.Language:=Language;
  L.Country:=Country;
  L.Variant:=VarLocale;
  LI:=LocaleData.GetLocaleItem(L);
  Result:=LI.DateSeparator;
  LocaleData:=Unassigned;
  L:=Unassigned;
  LI:=Unassigned;
  SM:=Unassigned;
end;

function TOOGlobalLocale.TimeSeparator: string;
var
  L: Variant;
  LI: Variant;
  SM: Variant;
  LocaleData: Variant;
begin
  SM:=CreateOleObject('com.sun.star.ServiceManager');
  LocaleData:=SM.CreateInstance('com.sun.star.i18n.LocaleData');
  L:=FDocument.CharLocale;
  LI:=LocaleData.GetLocaleItem(L);
  Result:=LI.TimeSeparator;
  LocaleData:=Unassigned;
  L:=Unassigned;
  LI:=Unassigned;
  SM:=Unassigned;
end;

function TOOGlobalLocale.TimeSeparator(Language, Country, VarLocale: string): string;
var
  L: Variant;
  LI: Variant;
  SM: Variant;
  LocaleData: Variant;
begin
  SM:=CreateOleObject('com.sun.star.ServiceManager');
  LocaleData:=SM.CreateInstance('com.sun.star.i18n.LocaleData');
  L:=SM.Bridge_GetStruct('com.sun.star.lang.Locale');
  L.Language:=Language;
  L.Country:=Country;
  L.Variant:=VarLocale;
  LI:=LocaleData.GetLocaleItem(L);
  Result:=LI.TimeSeparator;
  LocaleData:=Unassigned;
  L:=Unassigned;
  LI:=Unassigned;
  SM:=Unassigned;
end;

function TOOGlobalLocale.Time100SecSeparator: string;
var
  L: Variant;
  LI: Variant;
  SM: Variant;
  LocaleData: Variant;
begin
  SM:=CreateOleObject('com.sun.star.ServiceManager');
  LocaleData:=SM.CreateInstance('com.sun.star.i18n.LocaleData');
  L:=FDocument.CharLocale;
  LI:=LocaleData.GetLocaleItem(L);
  Result:=LI.Time100SecSeparator;
  LocaleData:=Unassigned;
  L:=Unassigned;
  LI:=Unassigned;
  SM:=Unassigned;
end;

function TOOGlobalLocale.Time100SecSeparator(Language, Country, VarLocale: string): string;
var
  L: Variant;
  LI: Variant;
  SM: Variant;
  LocaleData: Variant;
begin
  SM:=CreateOleObject('com.sun.star.ServiceManager');
  LocaleData:=SM.CreateInstance('com.sun.star.i18n.LocaleData');
  L:=SM.Bridge_GetStruct('com.sun.star.lang.Locale');
  L.Language:=Language;
  L.Country:=Country;
  L.Variant:=VarLocale;
  LI:=LocaleData.GetLocaleItem(L);
  Result:=LI.Time100SecSeparator;
  LocaleData:=Unassigned;
  L:=Unassigned;
  LI:=Unassigned;
  SM:=Unassigned;
end;

function TOOGlobalLocale.ThousandSeparator: string;
var
  L: Variant;
  LI: Variant;
  SM: Variant;
  LocaleData: Variant;
begin
  SM:=CreateOleObject('com.sun.star.ServiceManager');
  LocaleData:=SM.CreateInstance('com.sun.star.i18n.LocaleData');
  L:=FDocument.CharLocale;
  LI:=LocaleData.GetLocaleItem(L);
  Result:=LI.ThousandSeparator;
  LocaleData:=Unassigned;
  L:=Unassigned;
  LI:=Unassigned;
  SM:=Unassigned;
end;

function TOOGlobalLocale.ThousandSeparator(Language, Country, VarLocale: string): string;
var
  L: Variant;
  LI: Variant;
  SM: Variant;
  LocaleData: Variant;
begin
  SM:=CreateOleObject('com.sun.star.ServiceManager');
  LocaleData:=SM.CreateInstance('com.sun.star.i18n.LocaleData');
  L:=SM.Bridge_GetStruct('com.sun.star.lang.Locale');
  L.Language:=Language;
  L.Country:=Country;
  L.Variant:=VarLocale;
  LI:=LocaleData.GetLocaleItem(L);
  Result:=LI.ThousandSeparator;
  LocaleData:=Unassigned;
  L:=Unassigned;
  LI:=Unassigned;
  SM:=Unassigned;
end;

function TOOGlobalLocale.DecimalSeparator: string;
var
  L: Variant;
  LI: Variant;
  SM: Variant;
  LocaleData: Variant;
begin
  SM:=CreateOleObject('com.sun.star.ServiceManager');
  LocaleData:=SM.CreateInstance('com.sun.star.i18n.LocaleData');
  L:=FDocument.CharLocale;
  LI:=LocaleData.GetLocaleItem(L);
  Result:=LI.DecimalSeparator;
  LocaleData:=Unassigned;
  L:=Unassigned;
  LI:=Unassigned;
  SM:=Unassigned;
end;

function TOOGlobalLocale.DecimalSeparator(Language, Country, VarLocale: string): string;
var
  L: Variant;
  LI: Variant;
  SM: Variant;
  LocaleData: Variant;
begin
  SM:=CreateOleObject('com.sun.star.ServiceManager');
  LocaleData:=SM.CreateInstance('com.sun.star.i18n.LocaleData');
  L:=SM.Bridge_GetStruct('com.sun.star.lang.Locale');
  L.Language:=Language;
  L.Country:=Country;
  L.Variant:=VarLocale;
  LI:=LocaleData.GetLocaleItem(L);
  Result:=LI.DecimalSeparator;
  LocaleData:=Unassigned;
  L:=Unassigned;
  LI:=Unassigned;
  SM:=Unassigned;
end;

function TOOGlobalLocale.MeasurementSystem: string;
var
  L: Variant;
  LI: Variant;
  SM: Variant;
  LocaleData: Variant;
begin
  SM:=CreateOleObject('com.sun.star.ServiceManager');
  LocaleData:=SM.CreateInstance('com.sun.star.i18n.LocaleData');
  L:=FDocument.CharLocale;
  LI:=LocaleData.GetLocaleItem(L);
  Result:=LI.MeasurementSystem;
  LocaleData:=Unassigned;
  L:=Unassigned;
  LI:=Unassigned;
  SM:=Unassigned;
end;

function TOOGlobalLocale.MeasurementSystem(Language, Country, VarLocale: string): string;
var
  L: Variant;
  LI: Variant;
  SM: Variant;
  LocaleData: Variant;
begin
  SM:=CreateOleObject('com.sun.star.ServiceManager');
  LocaleData:=SM.CreateInstance('com.sun.star.i18n.LocaleData');
  L:=SM.Bridge_GetStruct('com.sun.star.lang.Locale');
  L.Language:=Language;
  L.Country:=Country;
  L.Variant:=VarLocale;
  LI:=LocaleData.GetLocaleItem(L);
  Result:=LI.MeasurementSystem;
  LocaleData:=Unassigned;
  L:=Unassigned;
  LI:=Unassigned;
  SM:=Unassigned;
end;

// ******************************************************************************
{ TListener }
// ******************************************************************************

{$IFDEF WITH_EVENTS}

procedure TListener.Disposing(const Source: IDispatch);
begin
end;

procedure TListener.NotifyEvent(const Event: IDispatch);
var
  e: OleVariant;
begin
  e:=Event;
  if e.EventName='OnSave' then
    FParent.OnBeforeSave;
  if e.EventName='OnSaveDone' then
    FParent.OnAfterSave;
  if e.EventName='OnSaveAs' then
    FParent.OnBeforeSaveAs;
  if e.EventName='OnSaveAsDone' then
    FParent.OnAfterSaveAs;
  if e.EventName='OnPrepareUnload' then
    FParent.OnBeforeClose;
  if e.EventName='OnUnload' then
    FParent.OnAfterClose;
  if e.EventName='OnUnfocus' then
    FParent.OnUnfocus;
  if e.EventName='OnFocus' then
    FParent.OnFocus;
end;

initialization

TAutoObjectFactory.Create(ComServer, TListener, Class_Listener, ciMultiInstance, tmApartment);
{$ENDIF}

end.
