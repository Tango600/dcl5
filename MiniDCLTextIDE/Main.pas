unit Main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, IBConnection, SQLDBLib, SQLDB, Forms, Controls, Graphics,
  Dialogs, ComCtrls, ExtCtrls, StdCtrls, Buttons, uDCLUtils, Utils, DB,
  IniFiles;

type

  { TForm1 }

  TNullableInteger = Class
  public
    Value :Integer;
  end;

  TDCLScript = Class
    Id:Integer;
    Ident, Parent:TNullableInteger;
    Name, Command:String;
    DCLText:TMemoryStream;
    LastUpdate:TDateTime;
  end;

  TForm1 = class(TForm)
    btUpload: TBitBtn;
    btUnload: TBitBtn;
    GroupBox1: TGroupBox;
    FDBLogOn: TIBConnection;
    SQLDBLibraryLoader1: TSQLDBLibraryLoader;
    SQLQuery1: TSQLQuery;
    IBTransaction: TSQLTransaction;
    SQLQuery2: TSQLQuery;
    StatusBar1: TStatusBar;
    procedure btUnloadClick(Sender: TObject);
    procedure btUploadClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    ScriptDir, ScriptExt: String;
    GPT: TGPT;
    Scripts: Array of TDCLScript;
    procedure ConnectDB;
  public

  end;

implementation

uses
  FileUtil, uStringParams;

{$R *.lfm}

{ TForm1 }

procedure TForm1.ConnectDB;
Begin
  FDBLogOn.Charset:='UTF8';

  if GPT.ServerCodePage='' then
    GPT.ServerCodePage:='utf8';

  GPT.IBAll:=True;
  If Not Assigned(FDBLogOn.Transaction) Then
  Begin
    IBTransaction.Params.Clear;
    IBTransaction.Params.Append('nowait');
    IBTransaction.Params.Append('read_committed');
    IBTransaction.Params.Append('rec_version');
    IBTransaction.Action:=caCommit;
    IBTransaction.DataBase:=FDBLogOn;
    FDBLogOn.Transaction:=IBTransaction;
  // IBTransaction.Action:=TACommitRetaining;
  End
  Else
    IBTransaction:=FDBLogOn.Transaction;

  If GPT.LibPath<>'' Then
  begin
    //SQLDBLibraryLoader1:=TSQLDBLibraryLoader.Create(Application);
    SQLDBLibraryLoader1.ConnectionType:='Firebird';
    SQLDBLibraryLoader1.LibraryName:=GPT.LibPath;
    SQLDBLibraryLoader1.Enabled:=True;
  end;

  If Not FDBLogOn.Connected Then
  begin
    If GPT.DBPath<>'' Then
    begin
      If Not IsFullPAth(GPT.DBPath) Then
        GPT.DBPath:=ExtractFilePath(Application.ExeName)+GPT.DBPath;

      If GPT.ServerName<>'' Then
      begin
        FDBLogOn.DatabaseName:=GPT.DBPath;
        FDBLogOn.HostName:=GPT.ServerName;
      end
      Else
      begin
        FDBLogOn.DatabaseName:=GPT.DBPath;
        FDBLogOn.HostName:='';
      end;
      FDBLogOn.UserName:=GPT.DBUserName;
      If GPT.DBPassword<>'' Then
      begin
        FDBLogOn.Password:=GPT.DBPassword;
        FDBLogOn.LoginPrompt:=False;
      end
      Else
        FDBLogOn.LoginPrompt:=True;

      If GPT.ServerCodePage='' Then
        FDBLogOn.Charset:='utf8';

      FDBLogOn.Dialect:=GPT.SQLDialect;
      IBTransaction.Database:=FDBLogOn;
      try
        FDBLogOn.Open;
      Except

      end;
    end;
  end;
End;

procedure TForm1.FormCreate(Sender: TObject);
var
  IniFile: TIniFile;
begin
  SetLength(Scripts, 0);
  LoadIni('DCL.ini', GPT);

  ConnectDB;

  If FileExists('Settings.ini') then
  begin
    IniFile:=TIniFile.Create('Settings.ini');
    ScriptExt:=IniFile.ReadString('Directory', 'Ext', '.txt');
    ScriptDir:=IniFile.ReadString('Directory', 'Dir', 'Scripts');
  end;
end;

procedure TForm1.btUnloadClick(Sender: TObject);
var
  r, idMenu:Integer;
  Scr:TDCLScript;
  MS:TMemoryStream;
  MetadataFileName:String;
  ScriptTime:TDateTime;
  Ident, PaertId:TNullableInteger;
  ScriptFileName, Sname:String;
  MDFile:Text;
  IsMenu, nextMenu:Boolean;
begin
  if FDBLogOn.Connected then
  begin
    if ScriptDir<>'' then
      if not DirectoryExists(ScriptDir) then
        CreateDir(ScriptDir);
      if not DirectoryExists(ScriptDir + '\.metadata') then
        CreateDir(ScriptDir + '\.metadata');
      if not DirectoryExists(ScriptDir + '\.metadata\Menu') then
        CreateDir(ScriptDir + '\.metadata\Menu');

    SQLQuery1.SQL.Text:='select * from DCL_SCRIPTS order by IDENT desc, PARENT desc';
    SQLQuery1.Open;
    r:=0;
    While not SQLQuery1.EOF do
    Begin
      IsMenu:=False;
      ScriptFileName:='';
      ScriptTime:=0;
      SetLength(Scripts, r+1);

      if ((SQLQuery1.FieldByName('IDENT').AsInteger>=1) and (SQLQuery1.FieldByName('IDENT').AsInteger<=1000)) or ((not SQLQuery1.FieldByName('PARENT').IsNull) and (SQLQuery1.FieldByName('IDENT').AsInteger>=1001) and (SQLQuery1.FieldByName('IDENT').AsInteger<=10000)) then
        IsMenu:=True;

      Scr:=TDCLScript.Create;
      Scr.Id:=SQLQuery1.FieldByName('NUMSEQ').AsInteger;
      Scr.Name:=SQLQuery1.FieldByName('DCLNAME').AsString;
      Scr.Command:=SQLQuery1.FieldByName('COMMAND').AsString;

      MetadataFileName:=IncludeTrailingPathDelimiter(ScriptDir)+'.metadata\'+Scr.Name + '.md';

      Scr.DCLText:=TMemoryStream.Create;
      (SQLQuery1.FieldByName('DCLTEXT') as TBlobField).SaveToStream(Scr.DCLText);
      Scr.LastUpdate:=SQLQuery1.FieldByName('UPDATES').AsDateTime;

      if (Scr.DCLText<>nil) and (Scr.Name<>'') and (Scr.DCLText.Size>0) and not IsMenu then
      begin
        ScriptFileName:=ScriptDir + '\' + Scr.Name + ScriptExt;

        if FileExists(ScriptFileName) then
        begin
          FileAge(ScriptFileName, ScriptTime, True);
        end;

        if ScriptTime<Scr.LastUpdate then
        begin
          MS:=TMemoryStream.Create;
          (SQLQuery1.FieldByName('DCLTEXT') as TBlobField).SaveToStream(MS);
          MS.SaveToFile(ScriptFileName);
          FreeAndNil(MS);

          FileSetDate(ScriptFileName, DateTimeToFileDate(Scr.LastUpdate));
        end;
      end;

      if not SQLQuery1.FieldByName('IDENT').IsNull then
      begin
        Ident:=TNullableInteger.Create;
        Ident.Value:=SQLQuery1.FieldByName('IDENT').AsInteger;

        Scr.Ident:=Ident;
      end;

      if not SQLQuery1.FieldByName('PARENT').IsNull then
      begin
        PaertId:=TNullableInteger.Create;
        PaertId.Value:=SQLQuery1.FieldByName('PARENT').AsInteger;

        Scr.Parent:=PaertId;
      end;

      if Scr.Name<>'' then
      begin
        if Scr.Ident<>nil then
        begin
           if (SQLQuery1.FieldByName('IDENT').AsInteger>=1) and (SQLQuery1.FieldByName('IDENT').AsInteger<=16000) then
             IsMenu:=True;

          if (SQLQuery1.FieldByName('IDENT').AsInteger>=1) and (SQLQuery1.FieldByName('IDENT').AsInteger<=16000) then
          begin
            SName:=SQLQuery1.FieldByName('DCLNAME').AsString;
            idMenu:=SQLQuery1.FieldByName('PARENT').AsInteger;
            Repeat
              SQLQuery2.SQL.Text:='select * from DCL_SCRIPTS where IDENT=:ID';
              SQLQuery2.ParamByName('ID').AsInteger:=idMenu;
              SQLQuery2.Open;
              SQLQuery2.Last;

              SName:=SQLQuery2.FieldByName('DCLNAME').AsString + PathDelim + SName;
              nextMenu:=SQLQuery2.FieldByName('PARENT').IsNull or (SQLQuery2.FieldByName('PARENT').AsInteger=0);
              if not nextMenu then
              begin
                idMenu:=SQLQuery2.FieldByName('PARENT').AsInteger;
              end;
              SQLQuery2.Close;
            until nextMenu;
            SQLQuery2.Close;

            ForceDirectories(IncludeTrailingPathDelimiter(ScriptDir)+'.metadata\Menu\'+SName);
            MetadataFileName:=IncludeTrailingPathDelimiter(ScriptDir)+'.metadata\Menu\'+SName + '\Metadata.id';
          end
        end;

        AssignFile(MDFile, MetadataFileName);
        Rewrite(MDFile);
        WriteLn(MDFile, 'ID=' + IntToStr(Scr.Id));

        if Scr.Command<>'' then
        begin
          WriteLn(MDFile, 'Command=' + Scr.Command);
        end;

        if Scr.Ident<>nil then
        begin
          WriteLn(MDFile, 'IDENT=' + IntToStr(SQLQuery1.FieldByName('IDENT').AsInteger));
        end;

        if Scr.Parent<>nil then
        begin
          WriteLn(MDFile, 'PARENT=' + IntToStr(SQLQuery1.FieldByName('PARENT').AsInteger));
        end;

        CloseFile(MDFile);
      end;

      Scripts[r]:=Scr;

      SQLQuery1.Next;
      Inc(r);
    End;
    SQLQuery1.Close;
  end;
end;

procedure TForm1.btUploadClick(Sender: TObject);
var
  Scr: TDCLScript;
  SRec: TSearchRec;
  Ident: TNullableInteger;
  retval, i: Integer;
  FileDate, DBLastUpdate: TDateTime;
  MetadataFileName:String;
  ScrName, FileName: String;
  MS:TMemoryStream;
  Modified, MetaDataExist:Boolean;
  MDFile:TStringList;
begin
  MDFile:=TStringList.Create;

  if not IBTransaction.Active then
    IBTransaction.StartTransaction;
  Modified:=False;
  retval:=FindFirst(IncludeTrailingPathDelimiter(ScriptDir)+'*'+ScriptExt, faAnyFile, SRec);
  While retval=0 Do
  Begin
    If (SRec.Attr and(faDirectory or faVolumeID))=0 Then
    Begin
      FileName:=IncludeTrailingPathDelimiter(ScriptDir)+SRec.name;
      FileDate:=FileDateToDateTime(FileAge(FileName));

      ScrName:=ExtractFileNameWithoutExt(SRec.name);
      SQLQuery1.SQL.Text:='select * from DCL_SCRIPTS where DCLNAME='''+ScrName+'''';
      SQLQuery1.Open;
      SQLQuery1.Last;
      if SQLQuery1.RecordCount=1 then
      begin
        DBLastUpdate:=SQLQuery1.FieldByName('UPDATES').AsDateTime;
        SQLQuery1.Close;

        if FileDate>DBLastUpdate then
        begin
          MS:=TMemoryStream.Create;
          MS.LoadFromFile(FileName);

          SQLQuery2.SQL.Text:='update DCL_SCRIPTS set DCLTEXT=:DCLTEXT where DCLNAME='''+ScrName+'''';
          SQLQuery2.ParamByName('DCLTEXT').LoadFromStream(MS, ftMemo);
          SQLQuery2.ExecSQL;

          FreeAndNil(MS);
          Modified:=True;
        end;
      end
      else
      begin
        if SQLQuery1.RecordCount=0 then
        begin
          SQLQuery1.Close;
          Scr:=TDCLScript.Create;

          MetaDataExist:=False;
          MetadataFileName:=IncludeTrailingPathDelimiter(ScriptDir)+'.metadata\'+ScrName + '.md';
          if FileExists(MetadataFileName) then
          begin
            MetaDataExist:=True;
            MDFile.LoadFromFile(MetadataFileName);

            For i:=1 to MDFile.Count do
            begin
              if FindParam('ID=', MDFile[i-1])<>'' then
              begin
                Scr.Id:=StrToInt(FindParam('ID=', MDFile[i-1]));
              end;

              if FindParam('IDENT=', MDFile[i-1])<>'' then
              begin
                Ident:=TNullableInteger.Create;
                Ident.Value:=StrToInt(FindParam('IDENT=', MDFile[i-1]));
                Scr.Ident:=Ident;
              end;

              if FindParam('PARENT=', MDFile[i-1])<>'' then
              begin
                Ident:=TNullableInteger.Create;
                Ident.Value:=StrToInt(FindParam('PARENT=', MDFile[i-1]));
                Scr.Parent:=Ident;
              end;

              if FindParam('COMMAND=', MDFile[i-1])<>'' then
              begin
                Scr.Command:=FindParam('COMMAND=', MDFile[i-1]);
              end;

            end;
          end;

          MS:=TMemoryStream.Create;
          MS.LoadFromFile(FileName);

          SQLQuery2.SQL.Text:='insert into DCL_SCRIPTS (NUMSEQ, IDENT, PARENT, COMMAND, DCLNAME, DCLTEXT) '+
          'values(:NUMSEQ, :IDENT, :PARENT, :COMMAND, :DCLNAME, :DCLTEXT)';
          SQLQuery2.ParamByName('DCLNAME').AsString:=ScrName;
          SQLQuery2.ParamByName('DCLTEXT').LoadFromStream(MS, ftMemo);
          if MetaDataExist then
            SQLQuery2.ParamByName('NUMSEQ').AsInteger:=Scr.Id
          else
            SQLQuery2.ParamByName('NUMSEQ').Value:=Null;

          if Assigned(Scr.Ident) and MetaDataExist then
             SQLQuery2.ParamByName('IDENT').AsInteger:=Scr.Ident.Value
          else
             SQLQuery2.ParamByName('IDENT').Value:=Null;

          if Assigned(Scr.Parent) and MetaDataExist then
             SQLQuery2.ParamByName('PARENT').AsInteger:=Scr.Parent.Value
          else
             SQLQuery2.ParamByName('PARENT').Value:=Null;

          if (Scr.Command<>'') and MetaDataExist then
             SQLQuery2.ParamByName('COMMAND').AsString:=Scr.Command
          else
             SQLQuery2.ParamByName('COMMAND').Value:=Null;

          SQLQuery2.ExecSQL;

          FreeAndNil(MS);

          Modified:=True;
        end;
      end;
    End;
    retval:=FindNext(SRec);
  End;

  retval:=FindFirst(IncludeTrailingPathDelimiter(ScriptDir)+IncludeTrailingPathDelimiter('Delete')+'*'+ScriptExt, faAnyFile, SRec);
  While retval=0 Do
  Begin
    If (SRec.Attr and(faDirectory or faVolumeID))=0 Then
    Begin
      FileName:=IncludeTrailingPathDelimiter(ScriptDir)+SRec.name;
      ScrName:=ExtractFileNameWithoutExt(SRec.name);
      SQLQuery1.SQL.Text:='select * from DCL_SCRIPTS where DCLNAME='''+ScrName+'''';
      SQLQuery1.Open;
      SQLQuery1.Last;
      if SQLQuery1.RecordCount=1 then
      begin
        SQLQuery1.Close;
        SQLQuery1.SQL.Text:='delete from DCL_SCRIPTS where DCLNAME='''+ScrName+'''';
        SQLQuery1.ExecSQL;
        Modified:=True;
      end;
    end;
    retval:=FindNext(SRec);
  end;
  if Modified then
    IBTransaction.Commit;
  if IBTransaction.Active then
    IBTransaction.EndTransaction;
end;

end.

