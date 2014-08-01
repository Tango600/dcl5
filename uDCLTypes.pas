unit uDCLTypes;
{$I DefineType.pas}

interface

Uses
  Controls,
  StdCtrls, ComCtrls, dbctrls, Buttons,
{$IFDEF ADO}
  ADODB, ADOConst, ADOInt,
{$ENDIF}
{$IFDEF BDE}
  BDE, DBClient, DBTables, Bdeconst,
{$ENDIF}
{$IFDEF IB}
  IBDatabase, IBTable, IBCustomDataSet, IBSQL, IBQuery, IBUpdateSQL,
  IBVisualConst, IBXConst,
{$ENDIF}
{$IFDEF ZEOS}
  ZConnection, ZDataset, ZSqlUpdate,
{$ENDIF}
  Forms;

type
  TDBForm=TForm;
  TDialogButton=TBitBtn;

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
  UpdateObj=TUpdateSQL;
{$ENDIF}
{$IFDEF IB}
  TDCLDialogQuery=TIBQuery;
  TReportQuery=TIBQuery;
  TDBLogOn=TIBDatabase;
  TCommandQuery=TIBQuery;
  TTransaction=TIBTransaction;
  UpdateObj=TIBUpdateSQL;
{$ENDIF}
{$IFDEF ZEOS}
  TDBLogOn=TZConnection;
  TReportQuery=TZQuery;
  TDCLDialogQuery=TZQuery;
  UpdateObj=TZUpdateSQL;
  TCommandQuery=TZReadOnlyQuery;
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
