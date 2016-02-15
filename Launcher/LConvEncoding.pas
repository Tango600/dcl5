{
 *****************************************************************************
 *                                                                           *
 *  This file is part of the Lazarus Component Library (LCL)                 *
 *                                                                           *
 *  See the file COPYING.modifiedLGPL.txt, included in this distribution,    *
 *  for details about the copyright.                                         *
 *                                                                           *
 *  This program is distributed in the hope that it will be useful,          *
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of           *
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.                     *
 *                                                                           *
 *****************************************************************************
}
unit LConvEncoding;

{$mode objfpc}{$H+}

interface

{ $Define DisableAsianCodePages}

uses
  SysUtils, Classes, dos, LazUTF8
  {$IFDEF EnableIconvEnc},iconvenc{$ENDIF};
const
  EncodingUTF8 = 'utf8';
  EncodingAnsi = 'ansi';
  EncodingUTF8BOM = 'utf8bom'; // UTF-8 with byte order mark
  EncodingUCS2LE = 'ucs2le'; // UCS 2 byte little endian
  EncodingUCS2BE = 'ucs2be'; // UCS 2 byte big endian
  UTF8BOM = #$EF#$BB#$BF;
  UTF16BEBOM = #$FE#$FF;
  UTF16LEBOM = #$FF#$FE;
  UTF32BEBOM = #0#0#$FE#$FF;
  UTF32LEBOM = #$FE#$FF#0#0;

function GuessEncoding(const s: string): string;

function ConvertEncoding(const s, FromEncoding, ToEncoding: string): string;

// This routine should obtain the encoding utilized by ansistring in the RTL
function GetDefaultTextEncoding: string;
// This routine returns the console text encoding, which might be different
// from the normal system encoding in some Windows systems
// see http://mantis.freepascal.org/view.php?id=20552
function GetConsoleTextEncoding: string;
function NormalizeEncoding(const Encoding: string): string;

type
  TConvertEncodingFunction = function(const s: string): string;
  TCharToUTF8Table = array[char] of PChar;
  TUnicodeToCharID = function(Unicode: cardinal): integer;
var
  ConvertAnsiToUTF8: TConvertEncodingFunction = nil;
  ConvertUTF8ToAnsi: TConvertEncodingFunction = nil;

function UTF8BOMToUTF8(const s: string): string; // UTF8 with BOM
function CP1251ToUTF8(const s: string): string; // cyrillic
function CP866ToUTF8(const s: string): string;  // DOS and Windows console's cyrillic
function KOI8ToUTF8(const s: string): string;  // russian cyrillic
function SingleByteToUTF8(const s: string;
                          const Table: TCharToUTF8Table): string;
function UCS2LEToUTF8(const s: string): string; // UCS2-LE 2byte little endian
function UCS2BEToUTF8(const s: string): string; // UCS2-BE 2byte big endian

function UTF8ToUTF8BOM(const s: string): string; // UTF8 with BOM
function UTF8ToCP1251(const s: string): string; // cyrillic
function UTF8ToCP866(const s: string): string;  // DOS and Windows console's cyrillic
function UTF8ToKOI8(const s: string): string;  // russian cyrillic
function UTF8ToSingleByte(const s: string;
                          const UTF8CharConvFunc: TUnicodeToCharID): string;
function UTF8ToUCS2LE(const s: string): string; // UCS2-LE 2byte little endian without BOM
function UTF8ToUCS2BE(const s: string): string; // UCS2-BE 2byte big endian without BOM

procedure GetSupportedEncodings(List: TStrings);

implementation

{$IFDEF Windows}
uses Windows;
{$ENDIF}

var EncodingValid: boolean = false;
    DefaultTextEncoding: string = EncodingAnsi;

{$IFNDEF DisableAsianCodePages}
//{$include asiancodepages.inc}
//{$include asiancodepagefunctions.inc}
{$ENDIF}

{$IFDEF Windows}
// AConsole - If false, it is the general system encoding,
//            if true, it is the console encoding
function GetWindowsEncoding(AConsole: Boolean = False): string;
var
  cp : UINT;
{$IFDEF WinCE}
// CP_UTF8 is missing in the windows unit of the Windows CE RTL
const
  CP_UTF8 = 65001;
{$ENDIF}
begin
  if AConsole then cp := GetOEMCP
  else cp := GetACP;

  case cp of
    CP_UTF8: Result := EncodingUTF8;
  else
    Result:='cp'+IntToStr(cp);
  end;
end;
{$ELSE}
{$IFNDEF Darwin}
function GetUnixEncoding:string;
var
  Lang: string;
  i: integer;
begin
  Result:=EncodingAnsi;

  lang := GetEnv('LC_ALL');
  if Length(lang) = 0 then
  begin
    lang := GetEnv('LC_MESSAGES');
    if Length(lang) = 0 then
    begin
      lang := GetEnv('LANG');
    end;
  end;
  i:=pos('.',Lang);
  if (i>0) and (i<=length(Lang)) then
    Result:=copy(Lang,i+1,length(Lang)-i);
end;
{$ENDIF}
{$ENDIF}

function GetDefaultTextEncoding: string;
begin
  if EncodingValid then begin
    Result:=DefaultTextEncoding;
    exit;
  end;

  {$IFDEF Windows}
  Result:=GetWindowsEncoding;
  {$ELSE}
  {$IFDEF Darwin}
  Result:=EncodingUTF8;
  {$ELSE}
  Result:=GetUnixEncoding;
  {$ENDIF}
  {$ENDIF}

  Result:=NormalizeEncoding(Result);

  DefaultTextEncoding:=Result;
  EncodingValid:=true;
end;

function GetConsoleTextEncoding: string;
begin
  {$ifdef Windows}
  Result:=GetWindowsEncoding(True);
  Result:=NormalizeEncoding(Result);
  {$else}
  Result := GetDefaultTextEncoding;
  {$endif}
end;

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

const
  ArrayCP1251ToUTF8: TCharToUTF8Table = (
    #0,                 // #0
    #1,                 // #1
    #2,                 // #2
    #3,                 // #3
    #4,                 // #4
    #5,                 // #5
    #6,                 // #6
    #7,                 // #7
    #8,                 // #8
    #9,                 // #9
    #10,                // #10
    #11,                // #11
    #12,                // #12
    #13,                // #13
    #14,                // #14
    #15,                // #15
    #16,                // #16
    #17,                // #17
    #18,                // #18
    #19,                // #19
    #20,                // #20
    #21,                // #21
    #22,                // #22
    #23,                // #23
    #24,                // #24
    #25,                // #25
    #26,                // #26
    #27,                // #27
    #28,                // #28
    #29,                // #29
    #30,                // #30
    #31,                // #31
    ' ',                // ' '
    '!',                // '!'
    '"',                // '"'
    '#',                // '#'
    '$',                // '$'
    '%',                // '%'
    '&',                // '&'
    '''',               // ''''
    '(',                // '('
    ')',                // ')'
    '*',                // '*'
    '+',                // '+'
    ',',                // ','
    '-',                // '-'
    '.',                // '.'
    '/',                // '/'
    '0',                // '0'
    '1',                // '1'
    '2',                // '2'
    '3',                // '3'
    '4',                // '4'
    '5',                // '5'
    '6',                // '6'
    '7',                // '7'
    '8',                // '8'
    '9',                // '9'
    ':',                // ':'
    ';',                // ';'
    '<',                // '<'
    '=',                // '='
    '>',                // '>'
    '?',                // '?'
    '@',                // '@'
    'A',                // 'A'
    'B',                // 'B'
    'C',                // 'C'
    'D',                // 'D'
    'E',                // 'E'
    'F',                // 'F'
    'G',                // 'G'
    'H',                // 'H'
    'I',                // 'I'
    'J',                // 'J'
    'K',                // 'K'
    'L',                // 'L'
    'M',                // 'M'
    'N',                // 'N'
    'O',                // 'O'
    'P',                // 'P'
    'Q',                // 'Q'
    'R',                // 'R'
    'S',                // 'S'
    'T',                // 'T'
    'U',                // 'U'
    'V',                // 'V'
    'W',                // 'W'
    'X',                // 'X'
    'Y',                // 'Y'
    'Z',                // 'Z'
    '[',                // '['
    '\',                // '\'
    ']',                // ']'
    '^',                // '^'
    '_',                // '_'
    '`',                // '`'
    'a',                // 'a'
    'b',                // 'b'
    'c',                // 'c'
    'd',                // 'd'
    'e',                // 'e'
    'f',                // 'f'
    'g',                // 'g'
    'h',                // 'h'
    'i',                // 'i'
    'j',                // 'j'
    'k',                // 'k'
    'l',                // 'l'
    'm',                // 'm'
    'n',                // 'n'
    'o',                // 'o'
    'p',                // 'p'
    'q',                // 'q'
    'r',                // 'r'
    's',                // 's'
    't',                // 't'
    'u',                // 'u'
    'v',                // 'v'
    'w',                // 'w'
    'x',                // 'x'
    'y',                // 'y'
    'z',                // 'z'
    '{',                // '{'
    '|',                // '|'
    '}',                // '}'
    '~',                // '~'
    #127,               // #127
    #208#130,           // #128
    #208#131,           // #129
    #226#128#154,       // #130
    #209#147,           // #131
    #226#128#158,       // #132
    #226#128#166,       // #133
    #226#128#160,       // #134
    #226#128#161,       // #135
    #226#130#172,       // #136
    #226#128#176,       // #137
    #208#137,           // #138
    #226#128#185,       // #139
    #208#138,           // #140
    #208#140,           // #141
    #208#139,           // #142
    #208#143,           // #143
    #209#146,           // #144
    #226#128#152,       // #145
    #226#128#153,       // #146
    #226#128#156,       // #147
    #226#128#157,       // #148
    #226#128#162,       // #149
    #226#128#147,       // #150
    #226#128#148,       // #151
    #194#152,           // #152
    #226#132#162,       // #153
    #209#153,           // #154
    #226#128#186,       // #155
    #209#154,           // #156
    #209#156,           // #157
    #209#155,           // #158
    #209#159,           // #159
    #194#160,           // #160
    #208#142,           // #161
    #209#158,           // #162
    #208#136,           // #163
    #194#164,           // #164
    #210#144,           // #165
    #194#166,           // #166
    #194#167,           // #167
    #208#129,           // #168
    #194#169,           // #169
    #208#132,           // #170
    #194#171,           // #171
    #194#172,           // #172
    #194#173,           // #173
    #194#174,           // #174
    #208#135,           // #175
    #194#176,           // #176
    #194#177,           // #177
    #208#134,           // #178
    #209#150,           // #179
    #210#145,           // #180
    #194#181,           // #181
    #194#182,           // #182
    #194#183,           // #183
    #209#145,           // #184
    #226#132#150,       // #185
    #209#148,           // #186
    #194#187,           // #187
    #209#152,           // #188
    #208#133,           // #189
    #209#149,           // #190
    #209#151,           // #191
    #208#144,           // #192
    #208#145,           // #193
    #208#146,           // #194
    #208#147,           // #195
    #208#148,           // #196
    #208#149,           // #197
    #208#150,           // #198
    #208#151,           // #199
    #208#152,           // #200
    #208#153,           // #201
    #208#154,           // #202
    #208#155,           // #203
    #208#156,           // #204
    #208#157,           // #205
    #208#158,           // #206
    #208#159,           // #207
    #208#160,           // #208
    #208#161,           // #209
    #208#162,           // #210
    #208#163,           // #211
    #208#164,           // #212
    #208#165,           // #213
    #208#166,           // #214
    #208#167,           // #215
    #208#168,           // #216
    #208#169,           // #217
    #208#170,           // #218
    #208#171,           // #219
    #208#172,           // #220
    #208#173,           // #221
    #208#174,           // #222
    #208#175,           // #223
    #208#176,           // #224
    #208#177,           // #225
    #208#178,           // #226
    #208#179,           // #227
    #208#180,           // #228
    #208#181,           // #229
    #208#182,           // #230
    #208#183,           // #231
    #208#184,           // #232
    #208#185,           // #233
    #208#186,           // #234
    #208#187,           // #235
    #208#188,           // #236
    #208#189,           // #237
    #208#190,           // #238
    #208#191,           // #239
    #209#128,           // #240
    #209#129,           // #241
    #209#130,           // #242
    #209#131,           // #243
    #209#132,           // #244
    #209#133,           // #245
    #209#134,           // #246
    #209#135,           // #247
    #209#136,           // #248
    #209#137,           // #249
    #209#138,           // #250
    #209#139,           // #251
    #209#140,           // #252
    #209#141,           // #253
    #209#142,           // #254
    #209#143            // #255
  );


  ArrayCP866ToUTF8 : TCharToUTF8Table = (
    #0,                 //#0
    #1,                 //#1
    #2,                 //#2
    #3,                 //#3
    #4,                 //#4
    #5,                 //#5
    #6,                 //#6
    #7,                 //#7
    #8,                 //#8
    #9,                 //#9
    #10,                //#10
    #11,                //#11
    #12,                //#12
    #13,                //#13
    #14,                //#14
    #15,                //#15
    #16,                //#16
    #17,                //#17
    #18,                //#18
    #19,                //#19
    #20,                //#20
    #21,                //#21
    #22,                //#22
    #23,                //#23
    #24,                //#24
    #25,                //#25
    #26,                //#26
    #27,                //#27
    #28,                //#28
    #29,                //#29
    #30,                //#30
    #31,                //#31
    #32,                //#32
    #33,                //#33
    #34,                //#34
    #35,                //#35
    #36,                //#36
    #37,                //#37
    #38,                //#38
    #39,                //#39
    #40,                //#40
    #41,                //#41
    #42,                //#42
    #43,                //#43
    #44,                //#44
    #45,                //#45
    #46,                //#46
    #47,                //#47
    #48,                //#48
    #49,                //#49
    #50,                //#50
    #51,                //#51
    #52,                //#52
    #53,                //#53
    #54,                //#54
    #55,                //#55
    #56,                //#56
    #57,                //#57
    #58,                //#58
    #59,                //#59
    #60,                //#60
    #61,                //#61
    #62,                //#62
    #63,                //#63
    #64,                //#64
    #65,                //#65
    #66,                //#66
    #67,                //#67
    #68,                //#68
    #69,                //#69
    #70,                //#70
    #71,                //#71
    #72,                //#72
    #73,                //#73
    #74,                //#74
    #75,                //#75
    #76,                //#76
    #77,                //#77
    #78,                //#78
    #79,                //#79
    #80,                //#80
    #81,                //#81
    #82,                //#82
    #83,                //#83
    #84,                //#84
    #85,                //#85
    #86,                //#86
    #87,                //#87
    #88,                //#88
    #89,                //#89
    #90,                //#90
    #91,                //#91
    #92,                //#92
    #93,                //#93
    #94,                //#94
    #95,                //#95
    #96,                //#96
    #97,                //#97
    #98,                //#98
    #99,                //#99
    #100,               //#100
    #101,               //#101
    #102,               //#102
    #103,               //#103
    #104,               //#104
    #105,               //#105
    #106,               //#106
    #107,               //#107
    #108,               //#108
    #109,               //#109
    #110,               //#110
    #111,               //#111
    #112,               //#112
    #113,               //#113
    #114,               //#114
    #115,               //#115
    #116,               //#116
    #117,               //#117
    #118,               //#118
    #119,               //#119
    #120,               //#120
    #121,               //#121
    #122,               //#122
    #123,               //#123
    #124,               //#124
    #125,               //#125
    #126,               //#126
    #127,               //#127
    #208#144,           //#128
    #208#145,           //#129
    #208#146,           //#130
    #208#147,           //#131
    #208#148,           //#132
    #208#149,           //#133
    #208#150,           //#134
    #208#151,           //#135
    #208#152,           //#136
    #208#153,           //#137
    #208#154,           //#138
    #208#155,           //#139
    #208#156,           //#140
    #208#157,           //#141
    #208#158,           //#142
    #208#159,           //#143
    #208#160,           //#144
    #208#161,           //#145
    #208#162,           //#146
    #208#163,           //#147
    #208#164,           //#148
    #208#165,           //#149
    #208#166,           //#150
    #208#167,           //#151
    #208#168,           //#152
    #208#169,           //#153
    #208#170,           //#154
    #208#171,           //#155
    #208#172,           //#156
    #208#173,           //#157
    #208#174,           //#158
    #208#175,           //#159
    #208#176,           //#160
    #208#177,           //#161
    #208#178,           //#162
    #208#179,           //#163
    #208#180,           //#164
    #208#181,           //#165
    #208#182,           //#166
    #208#183,           //#167
    #208#184,           //#168
    #208#185,           //#169
    #208#186,           //#170
    #208#187,           //#171
    #208#188,           //#172
    #208#189,           //#173
    #208#190,           //#174
    #208#191,           //#175
    #226#150#145,       //#176
    #226#150#146,       //#177
    #226#150#147,       //#178
    #226#148#130,       //#179
    #226#148#164,       //#180
    #226#149#161,       //#181
    #226#149#162,       //#182
    #226#149#150,       //#183
    #226#149#149,       //#184
    #226#149#163,       //#185
    #226#149#145,       //#186
    #226#149#151,       //#187
    #226#149#157,       //#188
    #226#149#156,       //#189
    #226#149#155,       //#190
    #226#148#144,       //#191
    #226#148#148,       //#192
    #226#148#180,       //#193
    #226#148#172,       //#194
    #226#148#156,       //#195
    #226#148#128,       //#196
    #226#148#188,       //#197
    #226#149#158,       //#198
    #226#149#159,       //#199
    #226#149#154,       //#200
    #226#149#148,       //#201
    #226#149#169,       //#202
    #226#149#166,       //#203
    #226#149#160,       //#204
    #226#149#144,       //#205
    #226#149#172,       //#206
    #226#149#167,       //#207
    #226#149#168,       //#208
    #226#149#164,       //#209
    #226#149#165,       //#210
    #226#149#153,       //#211
    #226#149#152,       //#212
    #226#149#146,       //#213
    #226#149#147,       //#214
    #226#149#171,       //#215
    #226#149#170,       //#216
    #226#148#152,       //#217
    #226#148#140,       //#218
    #226#150#136,       //#219
    #226#150#132,       //#220
    #226#150#140,       //#221
    #226#150#144,       //#222
    #226#150#128,       //#223
    #209#128,           //#224
    #209#129,           //#225
    #209#130,           //#226
    #209#131,           //#227
    #209#132,           //#228
    #209#133,           //#229
    #209#134,           //#230
    #209#135,           //#231
    #209#136,           //#232
    #209#137,           //#233
    #209#138,           //#234
    #209#139,           //#235
    #209#140,           //#236
    #209#141,           //#237
    #209#142,           //#238
    #209#143,           //#239
    #208#129,           //#240
    #209#145,           //#241
    #208#132,           //#242
    #209#148,           //#243
    #208#135,           //#244
    #209#151,           //#245
    #208#142,           //#246
    #209#158,           //#247
    #194#176,           //#248
    #226#136#153,       //#249
    #194#183,           //#250
    #226#136#154,       //#251
    #226#132#150,       //#252
    #194#164,           //#253
    #226#150#160,       //#254
    #194#160            //#255
  );

  ArrayKOI8ToUTF8: TCharToUTF8Table = (
    #0,                 // #0
    #1,                 // #1
    #2,                 // #2
    #3,                 // #3
    #4,                 // #4
    #5,                 // #5
    #6,                 // #6
    #7,                 // #7
    #8,                 // #8
    #9,                 // #9
    #10,                // #10
    #11,                // #11
    #12,                // #12
    #13,                // #13
    #14,                // #14
    #15,                // #15
    #16,                // #16
    #17,                // #17
    #18,                // #18
    #19,                // #19
    #20,                // #20
    #21,                // #21
    #22,                // #22
    #23,                // #23
    #24,                // #24
    #25,                // #25
    #26,                // #26
    #27,                // #27
    #28,                // #28
    #29,                // #29
    #30,                // #30
    #31,                // #31
    ' ',                // ' '
    '!',                // '!'
    '"',                // '"'
    '#',                // '#'
    '$',                // '$'
    '%',                // '%'
    '&',                // '&'
    '''',               // ''''
    '(',                // '('
    ')',                // ')'
    '*',                // '*'
    '+',                // '+'
    ',',                // ','
    '-',                // '-'
    '.',                // '.'
    '/',                // '/'
    '0',                // '0'
    '1',                // '1'
    '2',                // '2'
    '3',                // '3'
    '4',                // '4'
    '5',                // '5'
    '6',                // '6'
    '7',                // '7'
    '8',                // '8'
    '9',                // '9'
    ':',                // ':'
    ';',                // ';'
    '<',                // '<'
    '=',                // '='
    '>',                // '>'
    '?',                // '?'
    '@',                // '@'
    'A',                // 'A'
    'B',                // 'B'
    'C',                // 'C'
    'D',                // 'D'
    'E',                // 'E'
    'F',                // 'F'
    'G',                // 'G'
    'H',                // 'H'
    'I',                // 'I'
    'J',                // 'J'
    'K',                // 'K'
    'L',                // 'L'
    'M',                // 'M'
    'N',                // 'N'
    'O',                // 'O'
    'P',                // 'P'
    'Q',                // 'Q'
    'R',                // 'R'
    'S',                // 'S'
    'T',                // 'T'
    'U',                // 'U'
    'V',                // 'V'
    'W',                // 'W'
    'X',                // 'X'
    'Y',                // 'Y'
    'Z',                // 'Z'
    '[',                // '['
    '\',                // '\'
    ']',                // ']'
    '^',                // '^'
    '_',                // '_'
    '`',                // '`'
    'a',                // 'a'
    'b',                // 'b'
    'c',                // 'c'
    'd',                // 'd'
    'e',                // 'e'
    'f',                // 'f'
    'g',                // 'g'
    'h',                // 'h'
    'i',                // 'i'
    'j',                // 'j'
    'k',                // 'k'
    'l',                // 'l'
    'm',                // 'm'
    'n',                // 'n'
    'o',                // 'o'
    'p',                // 'p'
    'q',                // 'q'
    'r',                // 'r'
    's',                // 's'
    't',                // 't'
    'u',                // 'u'
    'v',                // 'v'
    'w',                // 'w'
    'x',                // 'x'
    'y',                // 'y'
    'z',                // 'z'
    '{',                // '{'
    '|',                // '|'
    '}',                // '}'
    '~',                // '~'
    #127,               // #127
    '',                 // #128
    '',                 // #129
    '',                 // #130
    '',                 // #131
    '',                 // #132
    '',                 // #133
    '',                 // #134
    '',                 // #135
    '',                 // #136
    '',                 // #137
    '',                 // #138
    '',                 // #139
    '',                 // #140
    '',                 // #141
    '',                 // #142
    '',                 // #143
    '',                 // #144
    '',                 // #145
    '',                 // #146
    '',                 // #147
    '',                 // #148
    '',                 // #149
    '',                 // #150
    '',                 // #151
    '',                 // #152
    '',                 // #153
    '',                 // #154
    '',                 // #155
    '',                 // #156
    '',                 // #157
    '',                 // #158
    '',                 // #159
    '',                 // #160
    '',                 // #161
    '',                 // #162
    '',                 // #163
    '',                 // #164
    '',                 // #165
    '',                 // #166
    '',                 // #167
    '',                 // #168
    '',                 // #169
    '',                 // #170
    '',                 // #171
    '',                 // #172
    '',                 // #173
    '',                 // #174
    '',                 // #175
    '',                 // #176
    '',                 // #177
    '',                 // #178
    '',                 // #179
    '',                 // #180
    '',                 // #181
    '',                 // #182
    '',                 // #183
    '',                 // #184
    '',                 // #185
    '',                 // #186
    '',                 // #187
    '',                 // #188
    '',                 // #189
    '',                 // #190
    '',                 // #191
    #209#142,           // #192
    #208#176,           // #193
    #208#177,           // #194
    #209#134,           // #195
    #208#180,           // #196
    #208#181,           // #197
    #209#132,           // #198
    #208#179,           // #199
    #209#133,           // #200
    #208#184,           // #201
    #208#185,           // #202
    #208#186,           // #203
    #208#187,           // #204
    #208#188,           // #205
    #208#189,           // #206
    #208#190,           // #207
    #208#191,           // #208
    #209#143,           // #209
    #209#128,           // #210
    #209#129,           // #211
    #209#130,           // #212
    #209#131,           // #213
    #208#182,           // #214
    #208#178,           // #215
    #209#140,           // #216
    #209#139,           // #217
    #208#183,           // #218
    #209#136,           // #219
    #209#141,           // #220
    #209#137,           // #221
    #209#135,           // #222
    #209#138,           // #223
    #208#174,           // #224
    #208#144,           // #225
    #208#145,           // #226
    #208#166,           // #227
    #208#148,           // #228
    #208#149,           // #229
    #208#164,           // #230
    #208#147,           // #231
    #208#165,           // #232
    #208#152,           // #233
    #208#153,           // #234
    #208#154,           // #235
    #208#155,           // #236
    #208#156,           // #237
    #208#157,           // #238
    #208#158,           // #239
    #208#159,           // #240
    #208#175,           // #241
    #208#160,           // #242
    #208#161,           // #243
    #208#162,           // #244
    #208#163,           // #245
    #208#150,           // #246
    #208#146,           // #247
    #208#172,           // #248
    #208#171,           // #249
    #208#151,           // #250
    #208#168,           // #251
    #208#173,           // #252
    #208#169,           // #253
    #208#167,           // #254
    ''                  // #255
  );

function UTF8BOMToUTF8(const s: string): string;
begin
  Result:=copy(s,4,length(s));
end;

function CP1251ToUTF8(const s: string): string;
begin
  Result:=SingleByteToUTF8(s,ArrayCP1251ToUTF8);
end;

function CP866ToUTF8(const s: string): string;
begin
  Result:=SingleByteToUTF8(s,ArrayCP866ToUTF8);
end;

function KOI8ToUTF8(const s: string): string;
begin
  Result:=SingleByteToUTF8(s,ArrayKOI8ToUTF8);
end;

function SingleByteToUTF8(const s: string; const Table: TCharToUTF8Table
  ): string;
var
  len: Integer;
  i: Integer;
  Src: PChar;
  Dest: PChar;
  p: PChar;
  c: Char;
begin
  if s='' then begin
    Result:=s;
    exit;
  end;
  len:=length(s);
  SetLength(Result,len*4);// UTF-8 is at most 4 bytes
  Src:=PChar(s);
  Dest:=PChar(Result);
  for i:=1 to len do begin
    c:=Src^;
    inc(Src);
    if ord(c)<128 then begin
      Dest^:=c;
      inc(Dest);
    end else begin
      p:=Table[c];
      if p<>nil then begin
        while p^<>#0 do begin
          Dest^:=p^;
          inc(p);
          inc(Dest);
        end;
      end;
    end;
  end;
  SetLength(Result,{%H-}PtrUInt(Dest)-PtrUInt(Result));
end;

function UCS2LEToUTF8(const s: string): string;
var
  len: Integer;
  Src: PWord;
  Dest: PChar;
  i: Integer;
  c: Word;
begin
  if s='' then begin
    Result:=s;
    exit;
  end;
  len:=length(s) div 2;
  SetLength(Result,len*3);// UTF-8 is at most 3/2 times the size
  Src:=PWord(Pointer(s));
  Dest:=PChar(Result);
  for i:=1 to len do begin
    c:=LEtoN(Src^);
    inc(Src);
    if ord(c)<128 then begin
      Dest^:=chr(c);
      inc(Dest);
    end else begin
      inc(Dest,UnicodeToUTF8SkipErrors(c,Dest));
    end;
  end;
  len:={%H-}PtrUInt(Dest)-PtrUInt(Result);
  if len>length(Result) then
    raise Exception.Create('');
  SetLength(Result,len);
end;

function UCS2BEToUTF8(const s: string): string;
var
  len: Integer;
  Src: PWord;
  Dest: PChar;
  i: Integer;
  c: Word;
begin
  if s='' then begin
    Result:=s;
    exit;
  end;
  len:=length(s) div 2;
  SetLength(Result,len*3);// UTF-8 is at most three times the size
  Src:=PWord(Pointer(s));
  Dest:=PChar(Result);
  for i:=1 to len do begin
    c:=BEtoN(Src^);
    inc(Src);
    if ord(c)<128 then begin
      Dest^:=chr(c);
      inc(Dest);
    end else begin
      inc(Dest,UnicodeToUTF8SkipErrors(c,Dest));
    end;
  end;
  len:={%H-}PtrUInt(Dest)-PtrUInt(Result);
  if len>length(Result) then
    raise Exception.Create('');
  SetLength(Result,len);
end;

function UnicodeToCP1251(Unicode: cardinal): integer;
begin
  case Unicode of
  0..127: Result:=Unicode;
  160: Result:=160;
  164: Result:=164;
  166..167: Result:=Unicode;
  169: Result:=169;
  171..174: Result:=Unicode;
  176..177: Result:=Unicode;
  181..183: Result:=Unicode;
  187: Result:=187;
  1025: Result:=168;
  1026..1027: Result:=Unicode-898;
  1028: Result:=170;
  1029: Result:=189;
  1030: Result:=178;
  1031: Result:=175;
  1032: Result:=163;
  1033: Result:=138;
  1034: Result:=140;
  1035: Result:=142;
  1036: Result:=141;
  1038: Result:=161;
  1039: Result:=143;
  1040..1103: Result:=Unicode-848;
  1105: Result:=184;
  1106: Result:=144;
  1107: Result:=131;
  1108: Result:=186;
  1109: Result:=190;
  1110: Result:=179;
  1111: Result:=191;
  1112: Result:=188;
  1113: Result:=154;
  1114: Result:=156;
  1115: Result:=158;
  1116: Result:=157;
  1118: Result:=162;
  1119: Result:=159;
  1168: Result:=165;
  1169: Result:=180;
  8211..8212: Result:=Unicode-8061;
  8216..8217: Result:=Unicode-8071;
  8218: Result:=130;
  8220..8221: Result:=Unicode-8073;
  8222: Result:=132;
  8224..8225: Result:=Unicode-8090;
  8226: Result:=149;
  8230: Result:=133;
  8240: Result:=137;
  8249: Result:=139;
  8250: Result:=155;
  8364: Result:=136;
  8470: Result:=185;
  8482: Result:=153;
  else Result:=-1;
  end;
end;

function UnicodeToCP866(Unicode: cardinal): integer;
begin
  case Unicode of
  0..127: Result:=Unicode;
  1040..1087 : Result := Unicode-912;
  9617..9619 : Result := Unicode-9441;
  9474 : Result := 179;
  9508 : Result := 180;
  9569 : Result := 181;
  9570 : Result := 182;
  9558 : Result := 183;
  9557 : Result := 184;
  9571 : Result := 185;
  9553 : Result := 186;
  9559 : Result := 187;
  9565 : Result := 188;
  9564 : Result := 189;
  9563 : Result := 190;
  9488 : Result := 191;
  9492 : Result := 192;
  9524 : Result := 193;
  9516 : Result := 194;
  9500 : Result := 195;
  9472 : Result := 196;
  9532 : Result := 197;
  9566 : Result := 198;
  9567 : Result := 199;
  9562 : Result := 200;
  9556 : Result := 201;
  9577 : Result := 202;
  9574 : Result := 203;
  9568 : Result := 204;
  9552 : Result := 205;
  9580 : Result := 206;
  9575 : Result := 207;
  9576 : Result := 208;
  9572 : Result := 209;
  9573 : Result := 210;
  9561 : Result := 211;
  9560 : Result := 212;
  9554 : Result := 213;
  9555 : Result := 214;
  9579 : Result := 215;
  9578 : Result := 216;
  9496 : Result := 217;
  9484 : Result := 218;
  9608 : Result := 219;
  9604 : Result := 220;
  9612 : Result := 221;
  9616 : Result := 222;
  9600 : Result := 223;
  1088..1103 : Result := Unicode-864;
  1025 : Result := 240;
  1105 : Result := 241;
  1028 : Result := 242;
  1108 : Result := 243;
  1031 : Result := 244;
  1111 : Result := 245;
  1038 : Result := 246;
  1118 : Result := 247;
  176  : Result := 248;
  8729 : Result := 249;
  183  : Result := 250;
  8730 : Result := 251;
  8470 : Result := 252;
  164  : Result := 253;
  9632 : Result := 254;
  160  : Result := 255;
  else Result:=-1;
  end;
end;

function UnicodeToKOI8(Unicode: cardinal): integer;
begin
  case Unicode of
  0..127: Result:=Unicode;
  1040..1041: Result:=Unicode-815;
  1042: Result:=247;
  1043: Result:=231;
  1044..1045: Result:=Unicode-816;
  1046: Result:=246;
  1047: Result:=250;
  1048..1055: Result:=Unicode-815;
  1056..1059: Result:=Unicode-814;
  1060: Result:=230;
  1061: Result:=232;
  1062: Result:=227;
  1063: Result:=254;
  1064: Result:=251;
  1065: Result:=253;
  1067: Result:=249;
  1068: Result:=248;
  1069: Result:=252;
  1070: Result:=224;
  1071: Result:=241;
  1072..1073: Result:=Unicode-879;
  1074: Result:=215;
  1075: Result:=199;
  1076..1077: Result:=Unicode-880;
  1078: Result:=214;
  1079: Result:=218;
  1080..1087: Result:=Unicode-879;
  1088..1091: Result:=Unicode-878;
  1092: Result:=198;
  1093: Result:=200;
  1094: Result:=195;
  1095: Result:=222;
  1096: Result:=219;
  1097: Result:=221;
  1098: Result:=223;
  1099: Result:=217;
  1100: Result:=216;
  1101: Result:=220;
  1102: Result:=192;
  1103: Result:=209;
  else Result:=-1;
  end;
end;

function UTF8ToUTF8BOM(const s: string): string;
begin
  Result:=UTF8BOM+s;
end;

function UTF8ToCP1251(const s: string): string;
begin
  Result:=UTF8ToSingleByte(s,@UnicodeToCP1251);
end;

function UTF8ToCP866(const s: string): string;
begin
  Result:=UTF8ToSingleByte(s,@UnicodeToCP866);
end;

function UTF8ToKOI8(const s: string): string;
begin
  Result:=UTF8ToSingleByte(s,@UnicodeToKOI8);
end;

function UTF8ToSingleByte(const s: string;
  const UTF8CharConvFunc: TUnicodeToCharID): string;
var
  len: Integer;
  Src: PChar;
  Dest: PChar;
  c: Char;
  Unicode: LongWord;
  CharLen: integer;
  i: integer;
begin
  if s='' then begin
    Result:='';
    exit;
  end;
  len:=length(s);
  SetLength(Result,len);
  Src:=PChar(s);
  Dest:=PChar(Result);
  while len>0 do begin
    c:=Src^;
    if c<#128 then begin
      Dest^:=c;
      inc(Dest);
      inc(Src);
      dec(len);
    end else begin
      Unicode:=UTF8CharacterToUnicode(Src,CharLen);
      inc(Src,CharLen);
      dec(len,CharLen);
      i:=UTF8CharConvFunc(Unicode);
      if i>=0 then begin
        Dest^:=chr(i);
        inc(Dest);
      end;
    end;
  end;
  SetLength(Result,Dest-PChar(Result));
end;

function UTF8ToUCS2LE(const s: string): string;
var
  len: Integer;
  Src: PChar;
  Dest: PWord;
  c: Char;
  Unicode: LongWord;
  CharLen: integer;
begin
  if s='' then begin
    Result:='';
    exit;
  end;
  len:=length(s);
  SetLength(Result,len*2);
  Src:=PChar(s);
  Dest:=PWord(Pointer(Result));
  while len>0 do begin
    c:=Src^;
    if c<#128 then begin
      Dest^:=NtoLE(Word(ord(c)));
      inc(Dest);
      inc(Src);
      dec(len);
    end else begin
      Unicode:=UTF8CharacterToUnicode(Src,CharLen);
      inc(Src,CharLen);
      dec(len,CharLen);
      if Unicode<=$ffff then begin
        Dest^:=NtoLE(Word(Unicode));
        inc(Dest);
      end;
    end;
  end;
  len:={%H-}PtrUInt(Dest)-PtrUInt(Result);
  if len>length(Result) then
    raise Exception.Create('');
  SetLength(Result,len);
end;

function UTF8ToUCS2BE(const s: string): string;
var
  len: Integer;
  Src: PChar;
  Dest: PWord;
  c: Char;
  Unicode: LongWord;
  CharLen: integer;
begin
  if s='' then begin
    Result:='';
    exit;
  end;
  len:=length(s);
  SetLength(Result,len*2);
  Src:=PChar(s);
  Dest:=PWord(Pointer(Result));
  while len>0 do begin
    c:=Src^;
    if c<#128 then begin
      Dest^:=NtoBE(Word(ord(c)));
      inc(Dest);
      inc(Src);
      dec(len);
    end else begin
      Unicode:=UTF8CharacterToUnicode(Src,CharLen);
      inc(Src,CharLen);
      dec(len,CharLen);
      if Unicode<=$ffff then begin
        Dest^:=NtoBE(Word(Unicode));
        inc(Dest);
      end;
    end;
  end;
  len:={%H-}PtrUInt(Dest)-PtrUInt(Result);
  if len>length(Result) then
    raise Exception.Create('');
  SetLength(Result,len);
end;

procedure GetSupportedEncodings(List: TStrings);
begin
  List.Add('UTF-8');
  List.Add('UTF-8BOM');
  List.Add('Ansi');
  List.Add('CP1251');
  List.Add('CP866');
  List.Add('KOI-8');
  List.Add('UCS-2LE');
  List.Add('UCS-2BE');

  List.Add('ISO-8859-1');
end;

function GuessEncoding(const s: string): string;

  function CompareI(p1, p2: PChar; Count: integer): boolean;
  var
    i: Integer;
    Chr1: Byte;
    Chr2: Byte;
  begin
    for i:=1 to Count do begin
      Chr1 := byte(p1^);
      Chr2 := byte(p2^);
      if Chr1<>Chr2 then begin
        if Chr1 in [97..122] then
          dec(Chr1,32);
        if Chr2 in [97..122] then
          dec(Chr2,32);
        if Chr1<>Chr2 then exit(false);
      end;
      inc(p1);
      inc(p2);
    end;
    Result:=true;
  end;

  {$IFDEF VerboseIDEEncoding}
  function PosToStr(p: integer): string;
  var
    y: Integer;
    x: Integer;
    i: Integer;
  begin
    y:=1;
    x:=1;
    i:=1;
    while (i<=length(s)) and (i<p) do begin
      if s[i] in [#10,#13] then begin
        inc(i);
        x:=1;
        inc(y);
        if (i<=length(s)) and (s[i] in [#10,#13]) and (s[i]<>s[i-1]) then
          inc(i);
      end else begin
        inc(i);
        inc(x);
      end;
    end;
    Result:='x='+IntToStr(x)+',y='+IntToStr(y);
  end;
  {$ENDIF}

var
  l: Integer;
  p: PChar;
  EndPos: PChar;
  i: LongInt;
begin
  l:=length(s);
  if l=0 then begin
    Result:='';
    exit;
  end;
  p:=PChar(s);

  // try UTF-8 BOM (Byte Order Mark)
  if CompareI(p,UTF8BOM,3) then begin
    Result:=EncodingUTF8BOM;
    exit;
  end;

  // try ucs-2le BOM FF FE (ToDo: nowadays this BOM is UTF16LE)
  if (p^=#$FF) and (p[1]=#$FE) then begin
    Result:=EncodingUCS2LE;
    exit;
  end;

  // try ucs-2be BOM FE FF (ToDo: nowadays this BOM is UTF16BE)
  if (p^=#$FE) and (p[1]=#$FF) then begin
    Result:=EncodingUCS2BE;
    exit;
  end;

  // try {%encoding eee}
  if CompareI(p,'{%encoding ',11) then begin
    inc(p,length('{%encoding '));
    while (p^ in [' ',#9]) do inc(p);
    EndPos:=p;
    while not (EndPos^ in ['}',' ',#9,#0]) do inc(EndPos);
    Result:=NormalizeEncoding(copy(s,p-PChar(s)+1,EndPos-p));
    exit;
  end;

  // try UTF-8 (this includes ASCII)
  p:=PChar(s);
  repeat
    if ord(p^)<128 then begin
      // ASCII
      if (p^=#0) and (p-PChar(s)>=l) then begin
        Result:=EncodingUTF8;
        exit;
      end;
      inc(p);
    end else begin
      i:=UTF8CharacterStrictLength(p);
      //DebugLn(['GuessEncoding ',i,' ',DbgStr(s[p])]);
      if i=0 then begin
        {$IFDEF VerboseIDEEncoding}
        DebugLn(['GuessEncoding non UTF-8 found at ',PosToStr(p-PChar(s)+1),' ',dbgstr(copy(s,p-PChar(s)-10,20))]);
        {$ENDIF}
        break;
      end;
      inc(p,i);
    end;
  until false;

  // use system encoding
  Result:=GetDefaultTextEncoding;

  if NormalizeEncoding(Result)=EncodingUTF8 then begin
    // the system encoding is UTF-8, but the text is not UTF-8
    // use ISO-8859-1 instead. This encoding has a full 1:1 mapping to unicode,
    // so no character is lost during conversion back and forth.
    Result:='ISO-8859-1';
  end;
end;

function ConvertEncoding(const s, FromEncoding, ToEncoding: string): string;
var
  AFrom, ATo, SysEnc : String;
  Encoded : Boolean;
  {$ifdef EnableIconvEnc}
  Dummy: String;
  {$endif}
begin
  AFrom:=NormalizeEncoding(FromEncoding);
  ATo:=NormalizeEncoding(ToEncoding);
  SysEnc:=NormalizeEncoding(GetDefaultTextEncoding);
  if AFrom=EncodingAnsi then AFrom:=SysEnc
  else if AFrom='' then AFrom:=EncodingUTF8;
  if ATo=EncodingAnsi then ATo:=SysEnc
  else if ATo='' then ATo:=EncodingUTF8;
  if AFrom=ATo then begin
    Result:=s;
    exit;
  end;
  if s='' then begin
    if ATo=EncodingUTF8BOM then
      Result:=UTF8BOM;
    exit;
  end;
  //DebugLn(['ConvertEncoding ',AFrom,' ',ATo]);

  if (AFrom=EncodingUTF8) then begin
    if ATo=EncodingUTF8BOM then begin Result:=UTF8ToUTF8BOM(s); exit; end;
    if ATo='cp1251' then begin Result:=UTF8ToCP1251(s); exit; end;
    if ATo='cp866' then begin  Result:=UTF8ToCP866(s);  exit; end;
    if ATo='koi8' then begin  Result:=UTF8ToKOI8(s);  exit; end;
    if ATo=EncodingUCS2LE then begin Result:=UTF8ToUCS2LE(s); exit; end;
    if ATo=EncodingUCS2BE then begin Result:=UTF8ToUCS2BE(s); exit; end;

    if (ATo=SysEnc) and Assigned(ConvertUTF8ToAnsi) then begin
      Result:=ConvertUTF8ToAnsi(s);
      exit;
    end;
  end else if ATo=EncodingUTF8 then begin
    if AFrom=EncodingUTF8BOM then begin Result:=UTF8BOMToUTF8(s); exit; end;
    if AFrom='cp1251' then begin Result:=CP1251ToUTF8(s); exit; end;
    if AFrom='cp866' then begin  Result:=CP866ToUTF8(s);  exit; end;
    if AFrom='koi8' then begin  Result:=KOI8ToUTF8(s);  exit; end;
    if AFrom=EncodingUCS2LE then begin Result:=UCS2LEToUTF8(s); exit; end;
    if AFrom=EncodingUCS2BE then begin Result:=UCS2BEToUTF8(s); exit; end;

    if (AFrom=SysEnc) and Assigned(ConvertAnsiToUTF8) then begin
      Result:=ConvertAnsiToUTF8(s);
      exit;
    end;
  end
  else begin
    //ATo and AFrom <> EncodingUTF8. Need to do ANSI->UTF8->ANSI.
    //TempStr := s;
    Encoded := false;

    //ANSI->UTF8
    if AFrom='cp1251' then begin
      Result:=CP1251ToUTF8(s);
      Encoded := true;
    end
    else if AFrom='cp866' then begin
      Result:=CP866ToUTF8(s);
      Encoded := true;
    end
    else if AFrom='koi8' then begin
      Result:=KOI8ToUTF8(s);
      Encoded := true;
    end
    else if (AFrom=SysEnc) and Assigned(ConvertAnsiToUTF8) then begin
      Result:=ConvertAnsiToUTF8(s);
      Encoded := true;
    end;

    if Encoded = true then begin
      //UTF8->ANSI
      Encoded := false;
      if ATo='cp1251' then begin
        Result:=UTF8ToCP1251(Result);
        Encoded := true;
      end
      else if ATo='cp866' then begin
        Result:=UTF8ToCP866(Result);
        Encoded := true;
      end
      else if ATo='koi8' then begin
        Result:=UTF8ToKOI8(Result);
        Encoded := true;
      end
      else if (ATo=SysEnc) and Assigned(ConvertUTF8ToAnsi) then begin
        Result:=ConvertUTF8ToAnsi(Result);
        Encoded := true;
      end;
    end;

    //Exit if encoded succesfully.
    if Encoded = true then begin
      exit;
    end;

  end;

  Result:=s;
  {$ifdef EnableIconvEnc}
  try
    if not IconvLibFound and not InitIconv(Dummy) then
    begin
      {$IFNDEF DisableChecks}
      DebugLn(['Can not init iconv: ',Dummy]);
      {$ENDIF}
      Exit;
    end;
    if Iconvert(s, Result, AFrom, ATo)<>0 then
    begin
      Result:=s;
      Exit;
    end;
  except
  end;
  {$endif}
end;

end.
