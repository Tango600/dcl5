unit uNewFonts;
{$I DefineType.pas}
//Плюс для каждой формы вы должны установить ей ParentFont = True.
//Вот и всё. Теперь ваша программа будет использовать шрифт для UI, установленный в системе. 
interface
 
uses
  Graphics;
 
function GUIFont: TFont;
function MonoFont: TFont;
 
implementation
 
uses
  Windows, SysUtils;
 
var
  FGUIFont: TFont;
  FMonoFont: TFont;
 
function GUIFont: TFont;
begin
  Result := FGUIFont;
end;
 
function MonoFont: TFont;
begin
  Result := FMonoFont;
end;
 
procedure InitDefFontData;
var
  Metrics: TNonClientMetrics;
begin
  FGUIFont := TFont.Create;
  FMonoFont := TFont.Create;
 
  FillChar(Metrics, SizeOf(Metrics), 0);
  Metrics.cbSize:={$IFnDEF FPC}Metrics.SizeOf{$ELSE}SizeOf(Metrics){$ENDIF};
  if SystemParametersInfo(SPI_GETNONCLIENTMETRICS, Metrics.cbSize, @Metrics, 0) then
  begin
    FGUIFont.Handle := CreateFontIndirect(Metrics.lfMessageFont);
 
    DefFontData.Height := FGUIFont.Height;
    DefFontData.Orientation := FGUIFont.Orientation;
    DefFontData.Pitch := FGUIFont.Pitch;
    DefFontData.Style := FGUIFont.Style;
    DefFontData.Charset := FGUIFont.Charset;
    DefFontData.Name := {$IFnDEF FPC}UTF8EncodeToShortString(FGUIFont.Name){$ELSE}AnsiToUTF8(FGUIFont.Name){$ENDIF};
{$IFnDEF FPC}
    DefFontData.Quality := FGUIFont.Quality; // Только для Delphi XE и выше
{$ENDIF}
  end;
 
  FMonoFont.Handle := GetStockObject(ANSI_FIXED_FONT);
end;
 
initialization

  InitDefFontData;
 
finalization

  FreeAndNil(FMonoFont);
  FreeAndNil(FGUIFont);
 
end.
