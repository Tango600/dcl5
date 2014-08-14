unit uDCLOLE;

interface

{$IFDEF MSWINDOWS}
uses
  Variants, ComObj, ActiveX
{$IFDEF FPC}
    , types
{$ENDIF};
{$ENDIF}

function IsWordInstall: Boolean;
function IsWriterInstall: Boolean;
function IsExcelInstall: Boolean;
function IsOOInstall: Boolean;

implementation

{$IFDEF MSWINDOWS}
Function IsOLEObjectInstalled(Name: String): Boolean;
Var
  ClassID: TCLSID;
  Rez: HRESULT;
Begin
  Rez:=CLSIDFromProgID(PWideChar(WideString(Name)), ClassID);
  Result:=Rez=S_OK;
End;
{$ELSE}
Function IsOLEObjectInstalled(Name: String): Boolean;
Begin
  Result:=False;
End;
{$ENDIF}

function IsWordInstall: Boolean;
begin
  Result:=IsOLEObjectInstalled('Word.Application');
end;

function IsExcelInstall: Boolean;
begin
  Result:=IsOLEObjectInstalled('Excel.Application');
end;

function IsOOInstall: Boolean;
begin
  Result:=IsOLEObjectInstalled('com.sun.star.ServiceManager');
end;

function IsWriterInstall: Boolean;
begin
  Result:=IsOLEObjectInstalled('com.sun.star.ServiceManager');
end;

end.
