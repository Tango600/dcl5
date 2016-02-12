{
Copyright (c) 2014 Andreas Hausladen

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
}

{$A8,B-,C+,D-,E-,F-,G+,H+,I-,J-,K-,L+,M-,N-,O+,P+,Q-,R-,S-,T-,U-,V+,W-,X+,Y+,Z1}
{$IFDEF DEBUG} {$D+} {$ENDIF}

{.$DEFINE TEST}

unit ControlsAtomFix;

{
  ControlsAtomFix fixes QC 90511 (Resource leak caused by RM_GetObjectInstance message)
  for Delphi 6-XE. The bug was fixed in XE2.

  How to use
  ==========
  This unit must be added to your DPR's uses-list before any of the VCL units but after any
  memory manager units.

  uses
    // MemoryManager,
    ControlsAtomFix,  // <<<< insert before "Forms"
    Forms,
    MyUnit in 'MyUnit.pas'...


  How this patch works
  ====================
  The patch redirects all RegisterWindowMessage() calls that come from VCLxx.BPL and the module
  that is using ControlsAtomFix to a hooked version. The hook checks for the ControlAtomString
  string and changes it to "DelphiRM_GetObjectInstance".

}

interface

implementation

{$IF CompilerVersion < 23.0} // Delphi 6 introduced the leak, XE2 fixed it
uses
  Windows;

{$IFDEF VER140} {$DEFINE DELPHI6}    {$ENDIF} // Delphi 6
{$IFDEF VER150} {$DEFINE DELPHI7}    {$ENDIF} // Delphi 7
{$IFDEF VER170} {$DEFINE DELPHI2005} {$ENDIF} // Delphi 2005
{$IFDEF VER180} {$DEFINE DELPHI2006} {$ENDIF} // Delphi 2006
{$IFDEF VER185} {$DEFINE DELPHI2007} {$UNDEF DELPHI2006} {$ENDIF} // Delphi 2007
{$IFDEF VER200} {$DEFINE DELPHI2009} {$ENDIF} // Delphi 2009
{$IFDEF VER210} {$DEFINE DELPHI2010} {$ENDIF} // Delphi 2010
{$IFDEF VER220} {$DEFINE DELPHIXE}   {$ENDIF} // Delphi XE

const
{$IF defined(DELPHI6)} // 6
  VclBpl = 'vcl60.bpl';
{$ELSEIF defined(DELPHI7)} // 7
  VclBpl = 'vcl70.bpl';
{$ELSEIF defined(DELPHI2005)} // 2005
  VclBpl = 'vcl90.bpl';
{$ELSEIF defined(DELPHI2006)} // 2006
  VclBpl = 'vcl100.bpl';
{$ELSEIF defined(DELPHI2007)} // 2007
  VclBpl = 'vcl100.bpl'; // "non breaking release"
{$ELSEIF defined(DELPHI2009)} // 2009
  VclBpl = 'vcl120.bpl';
{$ELSEIF defined(DELPHI2010)} // 2010
  VclBpl = 'vcl140.bpl';
{$ELSEIF defined(DELPHIXE)} // XE
  VclBpl = 'vcl150.bpl';
{$IFEND}

function StrCompare(S1, S2: PChar): Boolean;
var
  C1: Char;
begin
  Result := False;
  while True do
  begin
    C1 := S1^;
    if C1 <> S2^ then
      Exit;
    if C1 = #0 then
      Break;
    Inc(S1);
    Inc(S2);
  end;
  Result := True;
end;

function StrICompareA(S1, S2: PAnsiChar): Boolean;
var
  C1, C2: AnsiChar;
begin
  Result := False;
  while True do
  begin
    C1 := S1^;
    C2 := S2^;

    if C1 = C2 then
    begin
      if C1 = #0 then
        Break;
      Inc(S1);
      Inc(S2);
      Continue;
    end;

    case C1 of
      'A'..'Z':
        C1 := AnsiChar(Ord(C1) xor $20);
    end;

    case C2 of
      'A'..'Z':
        C2 := AnsiChar(Ord(C2) xor $20);
    end;

    if (C1 <> C2) then
      Exit;

    if C1 = #0 then
      Break;
    Inc(S1);
    Inc(S2);
  end;
  Result := True;
end;

function PeMapImgNtHeaders(const BaseAddress: Pointer): PImageNtHeaders;
begin
  Result := nil;
  if IsBadReadPtr(BaseAddress, SizeOf(TImageDosHeader)) then
    Exit;
  if (PImageDosHeader(BaseAddress)^.e_magic <> IMAGE_DOS_SIGNATURE) or
     (PImageDosHeader(BaseAddress)^._lfanew = 0) then
    Exit;
  Result := PImageNtHeaders(DWORD(BaseAddress) + DWORD(PImageDosHeader(BaseAddress)^._lfanew));
  if IsBadReadPtr(Result, SizeOf(TImageNtHeaders)) or (Result^.Signature <> IMAGE_NT_SIGNATURE) then
    Result := nil
end;

type
  TIIDUnion = record
    case Integer of
      0: (Characteristics: DWORD);
      1: (OriginalFirstThunk: DWORD);
  end;

  PImageImportDescriptor = ^TImageImportDescriptor;
  TImageImportDescriptor = record
    Union: TIIDUnion;
    TimeDateStamp: DWORD;
    ForwarderChain: DWORD;
    Name: DWORD;
    FirstThunk: DWORD;
  end;

  PImageThunkData32 = ^TImageThunkData32;
  TImageThunkData32 = record
    case Integer of
      0: (ForwarderString: DWORD);
      1: (Function_: DWORD);
      2: (Ordinal: DWORD);
      3: (AddressOfData: DWORD);
  end;

function ReplaceDllImport(Base: Pointer; const ModuleName: PAnsiChar; FromProc, ToProc: Pointer): Boolean;
var
  NtHeader: PImageNtHeaders;
  ImportDir: TImageDataDirectory;
  ImportDesc: PImageImportDescriptor;
  CurrName: PAnsiChar;
  ImportEntry: PImageThunkData32;
  LastProtect, Dummy: Cardinal;
  CurProcess: DWORD;
  FirstChar: Byte;
begin
  Result := False;
  NtHeader := PeMapImgNtHeaders(Base);
  if (NtHeader = nil) or (FromProc = nil) or (ModuleName = nil) then
    Exit;

  ImportDir := NtHeader.OptionalHeader.DataDirectory[IMAGE_DIRECTORY_ENTRY_IMPORT];
  if ImportDir.VirtualAddress <> 0 then
  begin
    CurProcess := GetCurrentProcess;
    ImportDesc := PImageImportDescriptor(DWORD(Base) + ImportDir.VirtualAddress);
    FirstChar := Ord(ModuleName[0]) or $20;
    while ImportDesc^.Name <> 0 do
    begin
      CurrName := PAnsiChar(Base) + ImportDesc^.Name;

      {$WARNINGS OFF}
      if (Ord(CurrName[0]) or $20 = FirstChar) and StrICompareA(ModuleName, CurrName) then
      {$WARNINGS ON}
      begin
        ImportEntry := PImageThunkData32(PAnsiChar(Base) + ImportDesc^.FirstThunk);
        while ImportEntry^.Function_ <> 0 do
        begin
          if Pointer(ImportEntry^.Function_) = FromProc then
          begin
            if VirtualProtectEx(CurProcess, @ImportEntry^.Function_, SizeOf(ToProc), PAGE_READWRITE, @LastProtect) then
            begin
              ImportEntry^.Function_ := Cardinal(ToProc);
              VirtualProtectEx(CurProcess, @ImportEntry^.Function_, SizeOf(ToProc), LastProtect, Dummy);
              Result := True;
              if Base <> Pointer(HInstance) then
                Exit; // the VCLxx.BPL has only one RegisterWindowMessageA/W import
            end;
          end;
          Inc(ImportEntry);
        end;
      end;
      Inc(ImportDesc);
    end;
  end;
end;

procedure GetMainModuleName(Buf: PChar; MaxLen: Integer);
var
  P, NameStart: PChar;
begin
  Buf[GetModuleFileName(HInstance, Buf, MaxLen)] := #0;

  // Find last '\' and get the file's name
  P := Buf;
  NameStart := Buf;
  while True do
  begin
    case P^ of
      #0: Break;
      '\': NameStart := P + 1;
    end;
    Inc(P);
  end;
  if NameStart <> Buf then
  begin
    lstrcpyn(Buf, NameStart, MaxLen);
    Buf[P - NameStart] := #0;
  end;
end;

procedure ControlsAlreadyInitialized;
var
  FileName: array[0..MAX_PATH] of Char;
begin
  GetMainModuleName(FileName, MAX_PATH);
  MessageBox(0, 'Controls unit is already initialized. "Atom leak" patch cannot be applied. Please move the ControlsAtomFix unit above all VCL units in the DPR''s uses clause.',
    FileName, MB_OK or MB_ICONWARNING);
end;

{$IFDEF TEST}
procedure PatchApplied;
var
  FileName: array[0..MAX_PATH] of Char;
begin
  GetMainModuleName(FileName, MAX_PATH);
  MessageBox(0, 'ControlsAtomFix applied.', FileName, MB_OK or MB_ICONINFORMATION);
end;
{$ENDIF TEST}

{--------------------------------------------------------------------------------------------------}

var
  VclControlAtomString, ControlAtomString: array[0..10 + 8 + 8] of Char; // include #0
  OrgRegisterWindowMessage: function(lpString: PChar): UINT; stdcall;

function HookedVclRegisterWindowMessage(lpString: PChar): UINT; stdcall;
begin
  if (lpString <> nil) and (VclControlAtomString[0] <> #0) and (lpString[0] = 'C') and
     StrCompare(VclControlAtomString, lpString) then
  begin
    Result := OrgRegisterWindowMessage('DelphiRM_GetObjectInstance');
    VclControlAtomString[0] := #0; // our job is done, don't slow down other calls
    {$IFDEF TEST}
    PatchApplied;
    {$ENDIF TEST}
  end
  else
    Result := OrgRegisterWindowMessage(lpString);
end;

function HookedRegisterWindowMessage(lpString: PChar): UINT; stdcall;
begin
  if (lpString <> nil) and (ControlAtomString[0] <> #0) and (lpString[0] = 'C') and
     StrCompare(ControlAtomString, lpString) then
  begin
    Result := OrgRegisterWindowMessage('DelphiRM_GetObjectInstance');
    ControlAtomString[0] := #0; // our job is done, don't slow down other calls
    {$IFDEF TEST}
    PatchApplied;
    {$ENDIF TEST}
  end
  else
    Result := OrgRegisterWindowMessage(lpString);
end;

{--------------------------------------------------------------------------------------------------}

function wsprintf(Output: PChar; Format: PChar): Integer; cdecl; varargs;
  external user32 name {$IFDEF UNICODE}'wsprintfW'{$ELSE}'wsprintfA'{$ENDIF};

procedure MakeAtomString(Buf: PChar; Instance: LongWord; ThreadId: DWORD);
begin
  wsprintf(Buf, 'ControlOfs%.8X%.8X', Instance, ThreadId);
end;

procedure Init;
const
  RegisterWindowMessageName = {$IFDEF UNICODE}'RegisterWindowMessageW';{$ELSE}'RegisterWindowMessageA';{$ENDIF}
var
  VclBplHandle: THandle;
  ScreenP: ^TObject;
begin
  @OrgRegisterWindowMessage := GetProcAddress(GetModuleHandle(user32), RegisterWindowMessageName);
  if Assigned(OrgRegisterWindowMessage) then
  begin
    VclBplHandle := GetModuleHandle(VclBpl);
    if VclBplHandle <> 0 then
    begin
      // Hook only if Controls.InitControls wasn't called yet (Screen = nil).
      ScreenP := GetProcAddress(VclBplHandle, '@Forms@Screen');
      if ScreenP <> nil then
      begin
        if ScreenP^ = nil then
        begin
          // Patch the VCLxx.BPL package
          MakeAtomString(VclControlAtomString, VclBplHandle, GetCurrentThreadID);
          if not ReplaceDllImport(Pointer(VclBplHandle), user32, @OrgRegisterWindowMessage, @HookedVclRegisterWindowMessage) then
          begin
            {$IFDEF TEST}
            AllocConsole;
            WriteLn(VclBpl, ': ', RegisterWindowMessageName, ' import table slot not found');
            {$ENDIF TEST}
          end;
        end
        {$WARNINGS OFF}
        else if not IsLibrary and (DebugHook <> 0) then
        {$WARNINGS ON}
        begin
          ControlsAlreadyInitialized;
          Exit;
        end;
      end
      else
      begin
        {$IFDEF TEST}
        AllocConsole;
        WriteLn(VclBpl, ': ', '@Forms@Screen not found');
        {$ENDIF TEST}
      end;
    end;

    // Patch this module in case we don't use packages (e.g. we are just a DLL that was loaded into
    // a process that uses VCLxx.BPL)
    MakeAtomString(ControlAtomString, HInstance, GetCurrentThreadID);
    if not ReplaceDllImport(Pointer(HInstance), user32, @OrgRegisterWindowMessage, @HookedRegisterWindowMessage) then
    begin
      {$IFDEF TEST}
      AllocConsole;
      WriteLn('EXE/DLL: ', RegisterWindowMessageName, ' import table slot not not found');
      {$ENDIF TEST}
    end;
  end
  else
  begin
    {$IFDEF TEST}
    AllocConsole;
    WriteLn(user32, '.', RegisterWindowMessageName, ' not found');
    {$ENDIF TEST}
  end;
end;

initialization
  Init;
{$IFEND}

end.
