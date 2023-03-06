unit uDCLTypes;

interface

Uses
  Controls,
  StdCtrls, ComCtrls, Buttons,
  IBConnection, sqldb,
  Forms;

type
  TDialogButton=TBitBtn;

  TDCLDialogQuery=TSQLQuery;
  TReportQuery=TSQLQuery;
  TCommandQuery=TSQLQuery;
  TTransaction=TSQLTransaction;
  TDBLogOn=TIBConnection;

  TDCLMainPanel=TScrollBox;
  TDialogPanel=TScrollBox;
  TToolBarPanel=TToolBar;
  TDialogLabel=TLabel;

  TUserLevelsType=(ulDeny, ulReadOnly, ulWrite, ulExecute, ulLevel1, ulLevel2, ulLevel3, ulLevel4,
    ulDeveloper, ulUndefined);

implementation


end.
