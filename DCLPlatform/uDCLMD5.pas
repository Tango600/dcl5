unit uDCLMD5;

interface

uses
{$IFnDEF FPC}
  System.Hash,
{$ELSE}
  md5,
{$ENDIF}
  Classes, SysUtils;

  function MD5File(FileName: String): String;
  function MD5String(S: String): String;
  function MD5Stream(Data: TStream): String;

implementation

function MD5File(FileName: String): String;
begin
  {$IFDEF FPC}
  Result:=MD5Print(md5.MD5File(FileName, 1024*1024));
  {$ELSE}
  Result:=THashMD5.GetHashStringFromFile(FileName);
  {$ENDIF}
end;

function MD5String(S: String): String;
begin
  {$IFDEF FPC}
  Result:=MD5Print(md5.MD5String(S));
  {$ELSE}
  Result:=THashMD5.GetHashString(S);
  {$ENDIF}
end;

function MD5Stream(Data: TStream): String;
  {$IFDEF FPC}
var
  Buf: TBytes;
begin
  Data.WriteBuffer(Buf, Data.Size);
  Result:=MD5Print(MD5Buffer(Buf, Data.Size));
  {$ELSE}
begin
  Result:=THashMD5.GetHashString(Data);
  {$ENDIF}
end;

end.

