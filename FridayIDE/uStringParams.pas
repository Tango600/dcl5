unit uStringParams;

interface

uses
{$IFDEF FPC}
  LConvEncoding,
{$IFDEF UNIX}
  cwstring,
{$ENDIF}
{$ENDIF}
  SysUtils;

const
  DefaultParamsSeparator=';';
  DefaultValuesSeparator=',';
  DefaultParamDelim='"';

Function FindParam(const KeyWord, StrParam: String): String;
Function SortParams(const ParamsSet: String; ParamNo: Word;
  SeparateChar: String=DefaultValuesSeparator; ParamDelim: String=DefaultParamDelim): String;
Function ParamPos(const ParamsSet: String; ParamNo: Word;
  SeparateChar: String=DefaultValuesSeparator; ParamDelim: String=DefaultParamDelim): Word;
Function ParamsCount(const ParamsSet: String; SeparateChar: String=DefaultValuesSeparator;
  ParamDelim: String=DefaultParamDelim): Word;
Function GetClearParam(const Param: String; ParamDelim: String=DefaultParamDelim): String;
Function PosEx(const SubStr, S: String): Cardinal;
Function InitCap(const S: String): String;
Function TrimSymbols(S: String; TrimS: String): String;
Function PosSet(SubSet, S: String; SepChar: String=DefaultValuesSeparator;
  Delim: String=DefaultParamDelim): Cardinal;
Function SourceToInterface(S: String): String;
Function BaseToSystem(S: String): String;
//Function InterfaceToBase(S: String): String;
{$IFNDEF FPC}
Function ConvertEncoding(Const S, FromEncoding, ToEncoding: String): String;
{$ENDIF}
Function AnsiToUTF8(S: String): String;
Function UTF8ToAnsi(S: String): String;
Function TextToString(Text: String): String;
function TrimChars(CharsSet, S:string):String;

Function SystemToInterface(S:String): String;
Function InterfaceToSystem(S:String): String;

Function DoublingApostrof(const S: String):String;

implementation

uses uDCLConst, uDCLData;

{$IFNDEF FPC}
Function ConvertEncoding(Const S, FromEncoding, ToEncoding: String): String;
Begin
  If (ToEncoding='utf8') and (PosEx('cp', FromEncoding)=1) and (FromEncoding<>'utf8') then
    Result:=System.AnsiToUtf8(S)
  Else
    Result:=S;
End;
{$ENDIF}

function AnsiToUTF8(S: String): string;
begin
  Result:=ConvertEncoding(S, DefaultSourceEncoding, EncodingUTF8);
end;

Function TextToString(Text: String): String;
Var
  L: Integer;
  itabsize: byte;
Begin
  Result:='';
  L:=Length(Text);
  While L<>0 Do
  Begin
    If Text[L]=#10 Then
      Text[L]:=' ';
    If Text[L]=#9 Then
    Begin
      For itabsize:=1 To TabSize Do
        Insert(' ', Text, L);
    End;
    If (Text[L]=#13)Or(Text[L]=#0) Then
      Delete(Text, L, 1);
    Dec(L);
  End;

  Result:=Text;
End;

Function InterfaceToSystem(S:String): String;
Begin
  Result:=ConvertEncoding(S, DefaultInterfaceEncoding, DefaultSystemEncoding);
End;

Function SystemToInterface(S:String): String;
Begin
  Result:=ConvertEncoding(S, DefaultSystemEncoding, DefaultInterfaceEncoding);
End;

Function BaseToSystem(S: String): String;
Begin
  Result:=ConvertEncoding(S, GPT.ServerCodePage, DefaultSystemEncoding);
End;

Function InterfaceToBase(S: String): String;
Begin
  Result:=ConvertEncoding(S, DefaultInterfaceEncoding, GPT.ServerCodePage);
End;

Function SourceToInterface(S: String): String;
Begin
  Result:=ConvertEncoding(S, DefaultSourceEncoding, DefaultInterfaceEncoding);
End;

Function UTF8ToAnsi(S: String): String;
Begin
  Result:=ConvertEncoding(S, EncodingUTF8, DefaultSystemEncoding);
End;

Function TrimSymbols(S: String; TrimS: String): String;
var
  i: Cardinal;
begin
  for i:=Length(S) downto 1 do
    if Pos(S[i], TrimS)<>0 then
      Delete(S, i, 1);

  Result:=S;
end;

Function FindParam(const KeyWord, StrParam: String): String;
var
  Start, EndStr, lp, StartPos: Integer;
  vStrParam: String;
  Find:Boolean;
begin
  Result:='';
  StartPos:=1;
  Find:=False;
  vStrParam:=DefaultParamsSeparator+StrParam+DefaultParamsSeparator;
  Start:=PosEx(KeyWord, Copy(vStrParam, StartPos, Length(vStrParam)));
  If Start<>0 then
  begin
    Repeat
      Result:='';
      Start:=PosEx(KeyWord, Copy(vStrParam, StartPos, Length(vStrParam)));
      If Start<>0 then
      If Pos(vStrParam[Start-2+StartPos], StopSimbols)<>0 then
      Begin
        lp:=Length(vStrParam);
        EndStr:=Start+StartPos-1+Length(KeyWord);
        While vStrParam[EndStr]<>DefaultParamsSeparator do
        begin
          if EndStr-1=lp then
            break;
          Result:=Result+vStrParam[EndStr];
          Inc(EndStr);
        end;
        Find:=True;
      End;
      Inc(StartPos);
    Until (Find) or (StartPos>Length(vStrParam));
  end;
end;

Function ParamsCount(const ParamsSet: String; SeparateChar: String=DefaultValuesSeparator;
  ParamDelim: String=DefaultParamDelim): Word;
var
  ParamCount, ParamLen, pv1: Word;
  StopSeparate: Boolean;
  DelimLeft, DelimRight, CurrDelim: Char;
begin
  if ParamDelim='' then
    ParamDelim:=DefaultParamDelim;

  if Length(ParamDelim)=2 then
  begin
    DelimLeft:=ParamDelim[1];
    DelimRight:=ParamDelim[2];
  end
  Else
  begin
    DelimLeft:=ParamDelim[1];
    DelimRight:=ParamDelim[1];
  end;

  if SeparateChar='' then
    SeparateChar:=DefaultValuesSeparator;
  ParamCount:=1;
  pv1:=1;
  ParamLen:=Length(ParamsSet);
  StopSeparate:=False;

  CurrDelim:=DelimLeft;
  While ParamLen>=pv1 do
  begin
    if (Pos(ParamsSet[pv1], SeparateChar)<>0)and not StopSeparate then
      Inc(ParamCount);
    if ParamsSet[pv1]=CurrDelim then
    begin
      StopSeparate:=not StopSeparate;
      if CurrDelim=DelimLeft then
        CurrDelim:=DelimRight
      Else if CurrDelim=DelimRight then
        CurrDelim:=DelimLeft;
    end;
    Inc(pv1);
  end;
  Result:=ParamCount;
end;

Function GetClearParam(const Param: String; ParamDelim: String=DefaultParamDelim): String;
var
  DelimLeft, DelimRight: Char;
begin
  if Length(ParamDelim)=2 then
  begin
    DelimLeft:=ParamDelim[1];
    DelimRight:=ParamDelim[2];
  end
  Else
  begin
    DelimLeft:=ParamDelim[1];
    DelimRight:=ParamDelim[1];
  end;
  Result:=Param;
  if Length(Param)>=2 then
    if (Param[1]=DelimLeft)and(Param[Length(Param)]=DelimRight) then
      Result:=Copy(Param, 2, Length(Param)-2)
    Else
      Result:=Param;
end;

Function SortParams(const ParamsSet: String; ParamNo: Word;
  SeparateChar: String=DefaultValuesSeparator; ParamDelim: String=DefaultParamDelim): String;
var
  ParamCount, ParamLen, pv1, pv2: Word;
  StopSeparate: Boolean;
  DelimLeft, DelimRight, CurrDelim: Char;
  S: string;
begin
  If ParamNo=0 then
  Begin
    Result:='';
    Exit;
  End;

  if ParamDelim='' then
    ParamDelim:=DefaultParamDelim;

  if Length(ParamDelim)=2 then
  begin
    DelimLeft:=ParamDelim[1];
    DelimRight:=ParamDelim[2];
  end
  Else
  begin
    DelimLeft:=ParamDelim[1];
    DelimRight:=ParamDelim[1];
  end;

  if SeparateChar='' then
    SeparateChar:=DefaultValuesSeparator;
  Dec(ParamNo);
  ParamCount:=0;
  pv1:=1;
  StopSeparate:=False;
  ParamLen:=Length(ParamsSet);
  if ParamLen<>0 then
  begin
    CurrDelim:=DelimLeft;
    While (ParamCount<>ParamNo)and(ParamLen+1<>pv1) do
    begin
      if (Pos(ParamsSet[pv1], SeparateChar)<>0)and not StopSeparate then
        Inc(ParamCount);
      if ParamsSet[pv1]=CurrDelim then
      begin
        StopSeparate:=not StopSeparate;
        if CurrDelim=DelimLeft then
          CurrDelim:=DelimRight
        Else if CurrDelim=DelimRight then
          CurrDelim:=DelimLeft;
      end;
      Inc(pv1);
    end;

    pv2:=pv1;
    While (ParamLen>=pv2)and(ParamCount=ParamNo) do
    begin
      if (Pos(ParamsSet[pv2], SeparateChar)<>0)and not StopSeparate then
        Inc(ParamCount);
      if ParamsSet[pv2]=CurrDelim then
      begin
        StopSeparate:=not StopSeparate;
        if CurrDelim=DelimLeft then
          CurrDelim:=DelimRight
        Else if CurrDelim=DelimRight then
          CurrDelim:=DelimLeft;
      end;
      Inc(pv2);
    end;
    if (pv2-1=ParamLen)and(ParamCount=ParamNo) then
      Inc(pv2);

    S:=Trim(Copy(ParamsSet, pv1, pv2-pv1-1));
    Result:=S;
  end
  Else
    Result:='';
end;

Function ParamPos(const ParamsSet: String; ParamNo: Word;
  SeparateChar: String=DefaultValuesSeparator; ParamDelim: String=DefaultParamDelim): Word;
var
  ParamCount, ParamLen, pv1: Word;
  StopSeparate: Boolean;
  DelimLeft, DelimRight, CurrDelim: Char;
begin
  If ParamNo=0 then
  Begin
    Result:=1;
    Exit;
  End;

  if ParamDelim='' then
    ParamDelim:=DefaultParamDelim;

  if Length(ParamDelim)=2 then
  begin
    DelimLeft:=ParamDelim[1];
    DelimRight:=ParamDelim[2];
  end
  Else
  begin
    DelimLeft:=ParamDelim[1];
    DelimRight:=ParamDelim[1];
  end;

  if SeparateChar='' then
    SeparateChar:=DefaultValuesSeparator;
  Dec(ParamNo);
  ParamCount:=0;
  pv1:=1;
  StopSeparate:=False;
  ParamLen:=Length(ParamsSet);
  if ParamLen<>0 then
  begin
    CurrDelim:=DelimLeft;
    While (ParamCount<>ParamNo)and(ParamLen+1<>pv1) do
    begin
      if (Pos(ParamsSet[pv1], SeparateChar)<>0)and not StopSeparate then
        Inc(ParamCount);
      if ParamsSet[pv1]=CurrDelim then
      begin
        StopSeparate:=not StopSeparate;
        if CurrDelim=DelimLeft then
          CurrDelim:=DelimRight
        Else if CurrDelim=DelimRight then
          CurrDelim:=DelimLeft;
      end;
      Inc(pv1);
    end;

    Result:=pv1;
  end
  Else
    Result:=1;
end;

Function PosEx(const SubStr, S: String): Cardinal;
begin
  Result:=Pos(AnsiLowerCase(SubStr), AnsiLowerCase(S));
end;

Function InitCap(const S: String): String;
begin
  if S<>'' then
    Result:=AnsiUpperCase(S[1])+Copy(S, 2, Length(S)-1)
  Else
    Result:='';
end;

Function PosSet(SubSet, S: String; SepChar: String=DefaultValuesSeparator;
  Delim: String=DefaultParamDelim): Cardinal;
Var
  p, i, Pos: Cardinal;
  ps: String;
Begin
  Result:=0;
  p:=ParamsCount(SubSet, SepChar, Delim);
  If p>0 then
    If p=1 then
    Begin
      Result:=PosEx(SortParams(SubSet, 1, SepChar, Delim), S);
    End
    else
    Begin
      For i:=1 to p do
      Begin
        Pos:=0;
        ps:=SortParams(SubSet, i, SepChar, Delim);
        If ps<>'' then
          Pos:=PosEx(ps, S);
        If Pos<>0 then
        Begin
          Result:=Pos;
          Exit;
        End;
      End;
    End;
End;

function TrimChars(CharsSet, S:string):String;
var
  i:Integer;
begin
  Result:='';
  For i:=1 to Length(S) do
  Begin
    If PosEx(S[i], CharsSet)=0 then
      Result:=Result+S[i];
  End;
end;

Function DoublingApostrof(const S: String):String;
var
  i, l:Integer;
begin
  Result:='';
  l:=Length(S);
  For i:=1 to l do
  begin
    Result:=Result+S[i];
    If S[i]=#39 then
      Result:=Result+#39;
  end;
end;

end.
