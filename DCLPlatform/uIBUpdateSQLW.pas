unit uIBUpdateSQLW;
{$I DefineType.pas}

interface

uses
  SysUtils, Classes, DB,
{$IFDEF FPC}
  {$IFDEF IBX}
  IBCustomDataSet, IBQuery, IB, IBUpdateSQL, IBDatabase,
  {$ENDIF}
{$ELSE}
  {$IFDEF IBX}
  IBX.IBCustomDataSet, IBX.IBQuery, IBX.IB, IBX.IBUpdateSQL, IBX.IBDatabase,
  {$ENDIF}
{$ENDIF}

  Variants;

type
  TIBUpdateSQLW = class(TIBUpdateSQL)// UpdateObj)
  private
  // ��������� �� "�������" ����������
    FUpdateTransaction:TIBTransaction;
  // ����� ������� ������ "������" FQueries
    FQueriesW: array[TUpdateKind] of TIBQuery;
    procedure SetUpdateTransaction(Value:TIBTransaction);
  protected
  // ����� ������� ������ "������" GetQuery
    function  GetQueryW(UpdateKind: TUpdateKind): TIBQuery;
  // ����� ������� ������ "������" SQLChanged
    procedure SQLChangedW(Sender: TObject);
  // ������������� TIBQuery.Transaction
    procedure SetQueryTransaction(UpdateKind: TUpdateKind);
  // ������ ���������  ��� �������� fUpdateTransaction
    procedure Notification( AComponent: TComponent; Operation: TOperation); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    {$IFNDEF FPC}
    procedure Apply(UpdateKind: TUpdateKind); override;
    {$ELSE}
    procedure Apply(UpdateKind: TUpdateKind; buff: PChar); override;
    {$ENDIF}
  // ����� ������� ������ "������" ExecSQL
    procedure ExecSQLW(UpdateKind: TUpdateKind);
  // ����� ������� ������ "������" SetParams
    procedure SetParamsW(UpdateKind: TUpdateKind);
  // ����� ������� ������ "������" Query
    property QueryW[UpdateKind: TUpdateKind]: TIBQuery read GetQueryW;
  published
    property UpdateTransaction:TIBTransaction read fUpdateTransaction
                                              write SetUpdateTransaction;
  end;
  
procedure Register;

implementation

{ TIBUpdateSQLW }
procedure Register;
begin
  RegisterComponents('Interbase',[TIBUpdateSQLW]);
end;

constructor TIBUpdateSQLW.Create(AOwner: TComponent);
var
  UpdateKind: TUpdateKind;
begin
  inherited Create(AOwner);
  for UpdateKind := Low(TUpdateKind) to High(TUpdateKind) do
  begin
  // ������� ����������� OnChange ��� ��� ���������
  // TStringList
    TStringList(SQL[UpdateKind]).OnChange := SQLChangedW;
  end;
end;

destructor TIBUpdateSQLW.Destroy;
var
  UpdateKind: TUpdateKind;
begin
// ������� ������ FQueriesW
  for UpdateKind := Low(TUpdateKind) to High(TUpdateKind) do
  if Assigned(FQueriesW[UpdateKind]) then
  begin
    FQueriesW[UpdateKind].Free;
    FQueriesW[UpdateKind]:=nil;
  end;
  inherited Destroy;
end;


// ������� ���������� ��������� �� ������ TIBQuery �� ������
// ������� FWQueries
function TIBUpdateSQLW.GetQueryW(UpdateKind: TUpdateKind): TIBQuery;
begin
  if not Assigned(FQueriesW[UpdateKind]) then
  begin
    FQueriesW[UpdateKind] := TIBQuery.Create(Self);
    FQueriesW[UpdateKind].SQL.Assign(SQL[UpdateKind]);
    SetQueryTransaction(UpdateKind);
  end;
  Result := FQueriesW[UpdateKind];
end;

procedure TIBUpdateSQLW.SQLChangedW(Sender: TObject);
var
  UpdateKind: TUpdateKind;
begin
  for UpdateKind := Low(TUpdateKind) to High(TUpdateKind) do
    if Sender = SQL[UpdateKind] then
    begin
      if Assigned(FQueriesW[UpdateKind]) then
      begin
      // ���������� ����� SQL
        FQueriesW[UpdateKind].Params.Clear;
        FQueriesW[UpdateKind].SQL.Assign(SQL[UpdateKind]);
      end;
      Break;
    end;
end;

procedure TIBUpdateSQLW.SetParamsW(UpdateKind: TUpdateKind);
var
  I: Integer;
  Old: Boolean;
  Param: TParam;
  PName: string;
  Field: TField;
  Value: Variant;
begin
  if not Assigned(DataSet) then Exit;
  with QueryW[UpdateKind] do
  begin
    for I := 0 to Params.Count - 1 do
    begin
      Param := Params[I];
      PName := Param.Name;
      Old := CompareText(Copy(PName, 1, 4), 'OLD_') = 0; {do not localize}
      if Old then
        System.Delete(PName, 1, 4);
      Field := DataSet.FindField(PName);
      if not Assigned(Field) then
        Continue;
      if Old then
        Param.AssignFieldValue(Field, Field.OldValue) else
      begin
        Value := Field.NewValue;
        if VarIsEmpty(Value) then
          Value := Field.OldValue;
        Param.AssignFieldValue(Field, Value);
      end;
    end;
  end;
end;

procedure TIBUpdateSQLW.Apply(UpdateKind: TUpdateKind{$IFDEF FPC}; buff: PChar{$ENDIF});
begin
// �������� "����" ���������
  SetParamsW(UpdateKind);
  ExecSQLW(UpdateKind);
end;

procedure TIBUpdateSQLW.ExecSQLW(UpdateKind: TUpdateKind);
begin
  with QueryW[UpdateKind] do
  begin
  // ���� ��������� fUpdateTransaction
    if Assigned(fUpdateTransaction) and
    not fUpdateTransaction.InTransaction then
      fUpdateTransaction.StartTransaction;
    try
      Prepare;
      ExecSQL;
      if not RowsAffected=0 then
        if RowsAffected <> 1 then
          IBError(ibxeUpdateFailed, [nil]);
    finally
      if Assigned(fUpdateTransaction) then
      begin
        // � ����� ������ ����� Commit
        fUpdateTransaction.Commit;
      end;
    end;
  end;
end;

procedure TIBUpdateSQLW.SetQueryTransaction(UpdateKind: TUpdateKind);
begin
  if Assigned(FQueriesW[UpdateKind]) then
  begin
    if Assigned(fUpdateTransaction) then
    begin
      FQueriesW[UpdateKind].Database :=fUpdateTransaction.FindDefaultDatabase;
      FQueriesW[UpdateKind].Transaction :=fUpdateTransaction;
    end else
    // inherited
    if (DataSet is TIBCustomDataSet) then
    begin
      FQueriesW[UpdateKind].Database := TIBCustomDataSet(DataSet).DataBase;
      FQueriesW[UpdateKind].Transaction := TIBCustomDataSet(DataSet).Transaction;
    end;
  end;
end;

procedure TIBUpdateSQLW.Notification(AComponent: TComponent;
                                        Operation: TOperation);
var
  UpdateKind: TUpdateKind;
begin
  inherited Notification(AComponent, Operation);
    if (Operation = opRemove) then
    begin
      if AComponent = FUpdateTransaction then
      begin
       FUpdateTransaction := nil;
        for UpdateKind := Low(TUpdateKind) to High(TUpdateKind) do
        SetQueryTransaction(UpdateKind);
      end;
    end;
end;

// ��������� ������������� �������� FUpdateTransaction �
// ���������� IBDatabase � IBTransaction ��� ����
// IBQuery(Queries)
procedure TIBUpdateSQLW.SetUpdateTransaction(Value:TIBTransaction);
var
  UpdateKind: TUpdateKind;
begin
  FUpdateTransaction := Value;
  for UpdateKind := Low(TUpdateKind) to High(TUpdateKind) do
    SetQueryTransaction(UpdateKind);
end;

end.
