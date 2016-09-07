// ������� �� Email  "Paul Smirnoff" <smirnoff@stu.ru>
// � ����� �� ������� � ����������� fido7.ru.delphi.
// ��������� "Alexey Raymanov" aw_rv@beer.com �� ����������
// ----------------------------------------------------
// ������� MoneyToString �� �������� ������������� �����
// ���������� ��������� ������������� �������� �����.
//

unit SumProps;

interface

function MoneyToString(S: Currency; kpk: boolean; usd: boolean): string;
// ������� �� �������� ������������� ����� ������ Currency
// ���������� ��������� ������������� �������� �����, ����:
// '90235.03' -> '��������� ����� ������ �������� ���� ������ 03 �������' .
// ������ ��������� ������������� �������� ����� ����� ��������������
// ���� � ������ � ��������, ���� � �������� ��� � ������ ���.
// ��������� :
// S - ������������ �����, �� �������� �������� ���� �������������
// ����� ��������;
// kpk =True - ������ ������ ������,
// =False - ������ ������ ��������;
// usd =True - ������ ����� � �������� ��� � ������ ��� ,
// =False - ������ ����� � ������ � ��������.

implementation

uses
  SysUtils;

const
  m1: array [1..9] of string=('���� ', '��� ', '��� ', '������ ', '���� ', '����� ', '���� ',
    '������ ', '������ ');
  f1: array [1..9] of string=('���� ', '��� ', '��� ', '������ ', '���� ', '����� ', '���� ',
    '������ ', '������ ');
  n10: array [1..9] of string=('������ ', '�������� ', '�������� ', '����� ', '��������� ',
    '���������� ', '��������� ', '����������� ', '��������� ');
  first10: array [11..19] of string=('����������� ', '���������� ', '���������� ', '������������ ',
    '���������� ', '����������� ', '���������� ', '������������ ', '������������ ');
  n100: array [1..9] of string=('��� ', '������ ', '������ ', '��������� ', '������� ', '�������� ',
    '������� ', '��������� ', '��������� ');

  kop: array [1..3] of string=('�������', '�������', '������');
  rub: array [1..3] of string=('����� ', '����� ', '������ ');
  tsd: array [1..3] of string=('������ ', '������ ', '����� ');
  mln: array [1..3] of string=('������� ', '�������� ', '��������� ');
  mrd: array [1..3] of string=('�����ap� ', '������p�a ', '�����ap�o� ');
  trl: array [1..3] of string=('�������� ', '��������a ', '��������o� ');
  cnt: array [1..3] of string=('������ ', '������ ', '����� ');

  cent: array [1..3] of string=('���� ���', '����� ���', '������ ���');
  doll: array [1..3] of string=('������ ', '������� ', '�������� ');

function Triada(I, n: Integer; k: boolean; usd: boolean): string;
var
  a, gender, sfx: Integer;
begin
  Result:='';
  sfx:=3;
  if n=2 then
    gender:=0
  else
    gender:=1;

  a:=I div 100;
  if (a>0) then
  begin
    Result:=Result+n100[a];
    I:=I-a*100;
  end;

  if (I>19) then
  begin
    a:=I div 10;
    if (a>0) then
    begin
      Result:=Result+n10[a];
      I:=I-a*10;
      if I>0 then
      begin
        if k then
          gender:=0;
        if gender=1 then
          Result:=Result+m1[I]
        else
          Result:=Result+f1[I];
        case I of
        1:
        sfx:=1;
        2..4:
        sfx:=2;
        5..9:
        sfx:=3;
        end;
      end;
    end;
  end
  else
  begin
    case I of
    1:
    begin
      if k then
        gender:=0;
      if gender=1 then
        Result:=Result+m1[I]
      else
        Result:=Result+f1[I];
      sfx:=1;
    end;
    2..4:
    begin
      if k then
        gender:=0;
      if gender=1 then
        Result:=Result+m1[I]
      else
        Result:=Result+f1[I];
      sfx:=2;
    end;
    5..9:
    begin
      if k then
        gender:=0;
      if gender=1 then
        Result:=Result+m1[I]
      else
        Result:=Result+f1[I];
      sfx:=3;
    end;
    10:
    begin
      Result:=Result+n10[1];
      sfx:=3;
    end;
    11..19:
    begin
      Result:=Result+first10[I];
      sfx:=3;
    end;
    end;
  end;
  case n of
  1:
  if not k then
    if usd then
      Result:=Result+doll[sfx]
    else
      Result:=Result+rub[sfx]
  else if usd then
    Result:=Result+cent[sfx]
  else
    Result:=Result+kop[sfx];
  2:
  if not k then
    Result:=Result+tsd[sfx]
  else if usd then
    Result:=Result+cent[sfx]
  else
    Result:=Result+kop[sfx];
  3:
  if not k then
    Result:=Result+mln[sfx]
  else if usd then
    Result:=Result+cent[sfx]
  else
    Result:=Result+kop[sfx];
  4:
  if not k then
    Result:=Result+mrd[sfx]
  else if usd then
    Result:=Result+cent[sfx]
  else
    Result:=Result+kop[sfx];
  5:
  if not k then
    Result:=Result+trl[sfx]
  else if usd then
    Result:=Result+cent[sfx]
  else
    Result:=Result+kop[sfx];
  end;
end; // function Triada(I,n:Integer;k:boolean;usd:boolean):string;

function TriadaK(I: Integer; kpk: boolean; usd: boolean): string;
var
  sfx, H: Integer;
begin
  if kpk then
  begin
    Result:='';
    sfx:=3;
    H:=(I mod 10);
    case H of
    1:
    sfx:=1;
    2..4:
    sfx:=2;
    end;
    if (I in [11..19]) then
      sfx:=3;
    if usd then
    begin
      if I<10 then
        Result:='0'+IntToStr(I)+' '+cent[sfx]
      else
        Result:=IntToStr(I)+' '+cent[sfx];
    end
    else
    begin
      if I<10 then
        Result:='0'+IntToStr(I)+' '+kop[sfx]
      else
        Result:=IntToStr(I)+' '+kop[sfx];
    end;
  end
  else
  begin
    if I=0 then
      if usd then
        Result:='00 ������ ���'
      else
        Result:='00 ������'
    else
      Result:=Triada(I, 1, true, usd);
  end;
end; // function TriadaK(I:integer;kpk:boolean;usd:boolean):string;

function MoneyToString(S: Currency; kpk: boolean; usd: boolean): string;
var
  I, H: LongInt;
  V: string;
  f, l: string;
  s1: Currency;
  dH: Currency;
begin
  V:='';
  s1:=S;

  dH:=1E12;
  I:=Trunc(S/dH);
  if (I>0) then
  begin
    V:=Triada(I, 5, false, usd);
    S:=S-Trunc(S/dH)*dH;
  end;

  dH:=1000000000;
  I:=Trunc(S/dH);
  if (I>0) then
  begin
    V:=V+Triada(I, 4, false, usd);
    S:=S-Trunc(S/dH)*dH;
  end;

  H:=1000000;
  I:=Trunc(S/H);
  if (I>0) then
  begin
    V:=V+Triada(I, 3, false, usd);
    S:=S-Trunc(S/H)*H;
  end;

  H:=1000;
  I:=Trunc(S/H);
  if (I>0) then
  begin
    V:=V+Triada(I, 2, false, usd);
    S:=S-Trunc(S/H)*H;
  end;

  H:=1;
  I:=Trunc(S/H);
  if (I>0) then
  begin
    V:=V+Triada(I, 1, false, usd);
    S:=S-Trunc(S/H)*H;
  end
  else if usd then
    V:=V+doll[3]
  else
    V:=V+rub[3];

  I:=Trunc(S*100);
  V:=V+TriadaK(I, kpk, usd);
  if s1<1 then
    V:='���� '+V;
  f:=AnsiUpperCase(Copy(V, 1, 1));
  l:=Copy(V, 2, 256);
  V:=f+l;
  Result:=V;
end; // function MoneyToString(S:Currency; kpk:boolean; usd:boolean):string;


end.
