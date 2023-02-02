unit Utils;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, uStringParams;


Type
  TGPT=record
    OldStyle, DebugMesseges, OneCopy, ExitCnf, UseMessages, UserLogging, UserLoggingHistory, DebugOn,
    DisableFieldsList, HashPass, ShowPicture, DialogsSettings, DisableColors,
    DisableIniPasword, IBAll: Boolean;
    CurrentRunningScrString, CurrentRunningCmdString, Port: Integer;
    DateSeparator, TimeSeparator: Char;
    ServerCodePage, DateFormat, TimeFormat, Viewer, ConnectionString, MainFormCaption,
    NewConnectionString, DBPath, ServerName, NewDBUserName, DBType, GeneratorName: String;
    SQLDialect:Byte;
    NoParamsTable, NoUsersTable, DisableLogOnWithoutUser, MultiRolesMode: Boolean;
    DBUserName, DCLUserName, DCLUserPass, EnterPass, LongRoleName, GetValueSeparator, UpperString,
    UpperStringEnd, NotifycationsTable, IdentifyField, ParentFlgField, CommandField, NumSeqField,
    GPTTableName, GPTNameField, GPTValueField, GPTUserIDField, IniFileName, TemplatesTable,
    StringTypeChar, DCLNameField, DCLTextField, DCLTable, ShowRoleField, ACTIVE_USERS_TABLE,
    USER_LOGIN_HISTORY_TABLE, TemplatesNameField, TemplatesKeyField, TemplatesDataField,
    UserAdminField, {INITable,} RolesMenuTable, TimeStampFormat, DCLLongUserName, UserID, RoleID,
    DCLRoleName, NewDBPassword, DBPassword, LibPath, LaunchScrFile, LaunchForm: String;
  end;


  procedure LoadIni(FileName: String; var GPT: TGPT);

implementation

Function StrToIntEx(St: String): LongInt;
Var
  iI, L: Integer;
  tmpS: String;
Begin
  L:=Length(St);
  tmpS:='';
  For iI:=1 To L Do
  Begin
    If (St[iI]>='0')And(St[iI]<='9')Or(St[iI]='-') Then
      tmpS:=tmpS+St[iI];
  End;
  If tmpS='' Then
    tmpS:='0';
  Try
    Result:=StrToInt(tmpS);
  Except
    Result:=0;
  End;
End;

procedure LoadIni(FileName: String; var GPT: TGPT);
Var
  i:Integer;
  Params:TStringList;
Begin
  Params:=TStringList.Create;
  Params.LoadFromFile(FileName);

    If Params.Count>0 Then
    For i:=0 To Params.Count-1 Do
    Begin
      If Pos('//', TrimLeft(Params[i]))<>1 Then
      Begin
        If PosEx('CodePage=', Params[i])=1 Then
          GPT.ServerCodePage:=FindParam('CodePage=', Params[i]);
        If PosEx('MainFormCaption=', Params[i])=1 Then
          GPT.MainFormCaption:=FindParam('MainFormCaption=', Params[i]);
        If PosEx('ConfirmExit=', Params[i])=1 Then
        Begin
          If Trim(FindParam('ConfirmExit=', Params[i]))='1' Then
            GPT.ExitCnf:=True
          Else
            GPT.ExitCnf:=False;
        End;
        {$IFDEF CPU32}
        If PosEx('LibPath=', Params[i])=1 Then
        Begin
          GPT.LibPath:=FindParam('LibPath=', Params[i]);
        End;
        {$ENDIF}
        {$IFDEF CPU64}
        If PosEx('LibPath_x64=', Params[i])=1 Then
        Begin
          GPT.LibPath:=FindParam('LibPath_x64=', Params[i]);
        End;
        {$ENDIF}
        If PosEx('UserName=', Params[i])=1 Then
          GPT.DBUserName:=FindParam('UserName=', Params[i]);
        If PosEx('Password=', Params[i])=1 Then
          GPT.DBPassword:=FindParam('Password=', Params[i]);
        If PosEx('DBPath=', Params[i])=1 Then
          GPT.DBPath:=FindParam('DBPath=', Params[i]);
        If PosEx('ServerName=', Params[i])=1 Then
          GPT.ServerName:=FindParam('ServerName=', Params[i]);
        If PosEx('Port=', Params[i])=1 Then
          GPT.Port:=StrToIntEx(FindParam('Port=', Params[i]));
        If PosEx('DBType=', Params[i])=1 Then
          GPT.DBType:=FindParam('DBType=', Params[i]);
      End;
    End;
End;


end.

