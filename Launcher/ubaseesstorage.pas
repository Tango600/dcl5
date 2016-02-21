unit uBaseesStorage;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

interface

uses
{$IFDEF FPC}
  LConvEncoding,
{$ENDIF}
  Classes, SysUtils, IniFiles;

type
  RBaseParams=Record
    Title, IniPath, Params, UID: String;
  end;

  TEditActions=(teaNone, teaEditing, teaAdding, teaDeleting);

  TBaseParams=Array of RBaseParams;

 procedure ReadIni(IniFileName:String; var BaseParams:TBaseParams);
 function GetSection(IniFileName, SectionName:String):RBaseParams;
 procedure AddBaseToIni(IniFileName:String; Params:RBaseParams);
 Function GetBaseParam(Index: Integer; var BaseParams:TBaseParams): String;
 procedure EditBaseIni(IniFileName:String; Params:RBaseParams);
 procedure DeleteBase(IniFileName, SectionName:String);
 function GetBaseUID(IniFileName, SectionName:String):String;

 function NormalizeEncoding(const Encoding: string): string;


var
  Path, DefaultSystemEncoding:String;

const
{$IFDEF DELPHI}
  EncodingUTF8='utf8';
  UTF8BOM=#$EF#$BB#$BF;
  UTF16LEBOM=#$FF#$FE;
  DefaultInterfaceEncoding='cp1251';
{$ENDIF}
{$IFDEF FPC}
  DefaultInterfaceEncoding=EncodingUTF8;
{$ENDIF}


implementation


function NormalizeEncoding(const Encoding: string): string;
var
  i: Integer;
begin
  Result:=Trim(LowerCase(Encoding));
  if Pos('win', Result)=1 then
  begin
    Delete(Result, 1, 3);
    Result:='cp'+Result;
  end;
  for i:=length(Result) downto 1 do
    if Result[i]='-' then System.Delete(Result,i,1);
end;

function ToInterface(S:String):String;
begin
  Result:=ConvertEncoding(S, DefaultSystemEncoding, DefaultInterfaceEncoding);
end;

function ToSystem(S:String):String;
begin
  Result:=ConvertEncoding(S, DefaultInterfaceEncoding, DefaultSystemEncoding);
end;

Function GetBaseParam(Index: Integer; var BaseParams:TBaseParams): String;
Begin
  If Length(BaseParams)>0 then
  Begin
    If Index<> - 1 then
    Begin
      Result:='-ini "'+BaseParams[Index].IniPath+'"';
      If BaseParams[Index].Params<>'' then
        Result:=Result+' '+BaseParams[Index].Params;
    end
    Else
      Result:='';
  end
  Else
    Result:='';
end;

procedure ReadIni(IniFileName:String; var BaseParams:TBaseParams);
var
  SectionNum: Word;
  Sections:TStringList;
  Ini:TIniFile;
begin
  Ini:=TIniFile.Create(IniFileNAme);
  Sections:=TStringList.Create;

  Ini.ReadSections(Sections);
  SetLength(BaseParams, Sections.Count);
  For SectionNum:=1 to Sections.Count do
  Begin
    BaseParams[SectionNum-1].Title:=ToInterface(Sections[SectionNum-1]); //Ini.ReadString(Sections[SectionNum-1], 'Title', '');
    BaseParams[SectionNum-1].IniPath:=Ini.ReadString(Sections[SectionNum-1], 'IniFile', '');
    BaseParams[SectionNum-1].Params:=Ini.ReadString(Sections[SectionNum-1], 'Params', '');
    BaseParams[SectionNum-1].UID:=Ini.ReadString(Sections[SectionNum-1], 'BaseUID', '');
  End;
  Ini.Free;
end;

function GetSection(IniFileName, SectionName:String):RBaseParams;
var
  Ini:TIniFile;
begin
  Ini:=TIniFile.Create(IniFileName);

  Result.Title:=ToInterface(Ini.ReadString(SectionName, 'Title', ''));
  Result.IniPath:=Ini.ReadString(SectionName, 'IniFile', '');
  Result.Params:=Ini.ReadString(SectionName, 'Params', '');
  Result.UID:=Ini.ReadString(SectionName, 'BaseUID', '');

  Ini.Free;
end;

procedure AddBaseToIni(IniFileName:String; Params:RBaseParams);
var
  Ini:TIniFile;
begin
  Ini:=TIniFile.Create(IniFileName);

  Ini.WriteString(ToSystem(Params.Title), 'Title', ToSystem(Params.Title));
  Ini.WriteString(ToSystem(Params.Title), 'IniFile', Params.IniPath);
  Ini.WriteString(ToSystem(Params.Title), 'Params', Params.Params);
  Ini.WriteString(ToSystem(Params.Title), 'BaseUID', Params.UID);

  Ini.Free;
end;

procedure EditBaseIni(IniFileName:String; Params:RBaseParams);
var
  Ini:TIniFile;
begin
  Ini:=TIniFile.Create(IniFileName);

  Ini.EraseSection(ToSystem(Params.Title));
  Ini.WriteString(ToSystem(Params.Title), 'Title', ToSystem(Params.Title));
  Ini.WriteString(ToSystem(Params.Title), 'IniFile', Params.IniPath);
  Ini.WriteString(ToSystem(Params.Title), 'Params', Params.Params);
  Ini.WriteString(ToSystem(Params.Title), 'BaseUID', Params.UID);

  Ini.Free;
end;

procedure DeleteBase(IniFileName, SectionName:String);
var
  Ini:TIniFile;
begin
  Ini:=TIniFile.Create(IniFileName);

  Ini.EraseSection(SectionName);

  Ini.Free;
end;

function GetBaseUID(IniFileName, SectionName:String):String;
var
  Ini:TIniFile;
begin
  Ini:=TIniFile.Create(IniFileName);
  Result:=Ini.ReadString(SectionName, 'BaseUID', '');
  Ini.Free;
end;

end.

