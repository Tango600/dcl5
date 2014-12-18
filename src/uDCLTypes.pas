unit uDCLTypes;
{$I DefineType.pas}

interface

Uses
  Controls,
  StdCtrls, ComCtrls, dbctrls, Buttons, DBGrids,
{$IFNDEF FPC}
  ThemedDBGrid,
{$ENDIF}
{$IFDEF ADO}
  ADODB, ADOConst, ADOInt,
{$ENDIF}
{$IFDEF BDE}
  BDE, DBClient, DBTables, Bdeconst,
{$ENDIF}
{$IFDEF IBX}
{$IFDEF NEWDELPHI}
  IBX.IBDatabase, IBX.IBTable, IBX.IBCustomDataSet, IBX.IBSQL, IBX.IBQuery,
  IBX.IBVisualConst, IBX.IBXConst, IBX.IBUpdateSQL, 
{$ELSE}
  IBDatabase, IBTable, IBCustomDataSet, IBSQL, IBQuery, IBUpdateSQL,
  IBVisualConst, IBXConst,
{$ENDIF}
  uIBUpdateSQLW,
{$ENDIF}
{$IFDEF ZEOS}
  ZConnection, ZDataset, ZSqlUpdate,
{$ENDIF}
{$IFDEF SQLdbFamily}
  IBConnection, sqldb, db,
{$ENDIF}
  Forms;

type
  TDBForm=TForm;
  TDialogButton=TBitBtn;
  {$IFNDEF FPC}
  TDCLDBGrid=TThemeDBGrid;
  {$ELSE}
  TDCLDBGrid=TDBGrid;
  {$ENDIF}

{$IFDEF ADO}
  TDCLDialogQuery=TADOQuery;
  TReportQuery=TADOQuery;
  TDBLogOn=TADOConnection;
  TCommandQuery=TADOCommand;
{$ENDIF}
{$IFDEF BDE}
  TDCLDialogQuery=TQuery;
  TReportQuery=TQuery;
  TDBLogOn=TDatabase;
  TUpdateObj=TUpdateSQL;
{$ENDIF}
{$IFDEF IBX}
  TDCLDialogQuery=TIBQuery;
  TReportQuery=TIBQuery;
  TDBLogOn=TIBDatabase;
  TCommandQuery=TIBQuery;
  TTransaction=TIBTransaction;
  TUpdateObj=TIBUpdateSQLW;
//  UpdateObj=TIBUpdateSQL;
{$ENDIF}
{$IFDEF ZEOS}
  TDBLogOn=TZConnection;
  TReportQuery=TZQuery;
  TDCLDialogQuery=TZQuery;
  TUpdateObj=TZUpdateSQL;
  TCommandQuery=TZReadOnlyQuery;
{$ENDIF}
{$IFDEF SQLdbIB}
  TDCLDialogQuery=TSQLQuery;
  TReportQuery=TSQLQuery;
  TDBLogOn=TIBConnection;
  TCommandQuery=TSQLQuery;
  TTransaction=TSQLTransaction;
{$ENDIF}
{$IFDEF SQLdb}
  TDCLDialogQuery=TSQLQuery;
  TReportQuery=TSQLQuery;
  TDBLogOn=TSQLConnector;
  TCommandQuery=TSQLQuery;
  TTransaction=TSQLTransaction;
{$ENDIF}

  TDCLMainPanel=TScrollBox;
  TDialogPanel=TScrollBox;
  TToolBarPanel=TToolBar;
  TDialogLabel=TLabel;

  TEventsArray=array of String;
  TDialogSpeedButton=TSpeedButton;
  TFormPanelButton=TSpeedButton;


implementation


end.
