unit uDCLMessageForm;

interface

uses
{$IFDEF MSWINDOWS}
  uNewFonts,
{$ENDIF}
  SysUtils, Classes, Forms, Graphics, Controls, ExtCtrls,
  StdCtrls, DateUtils,
  uDCLConst, uDCLData, uStringParams, uDCLMultiLang;

type
  TMessageFormObject=Class(TObject)
  private
    MessageForm: TForm;
    MessageLabel: TLabel;
    MessageEdit: TEdit;
    MessageMemo: TMemo;
  public
    constructor Create(nUserName, MessageText: String);
    destructor Destroy;
  End;

implementation

Function DateToStr_(Date: TDate): String;
Var
  tmpS: system.string;
Begin
  tmpS:='';
  DateTimeToString(tmpS, GPT.DateFormat, Date);
  Result:=tmpS;
End;

Function TimeToStr_(Time: TDateTime): String;
Var
  tmpS: system.string;
Begin
  tmpS:='';
  DateTimeToString(tmpS, GPT.TimeFormat, Time);
  Result:=tmpS;
End;

Function TimeStampToStr(NowDate: TDateTime): String;
Begin
  Result:=DateToStr_(NowDate)+' '+TimeToStr_(NowDate);
End;

{ TMessageFormObject }

constructor TMessageFormObject.Create(nUserName, MessageText: String);
begin
  inherited Create;
  If (nUserName='')and(MessageText='') then
    Exit;

  MessageForm:=TForm.Create(Nil);
  MessageForm.FormStyle:=fsStayOnTop;
  MessageForm.BorderStyle:=bsSingle;
  MessageForm.BorderIcons:=[biSystemMenu];
  MessageForm.Caption:=SourceToInterface(GetDCLMessageString(msNotifycation))+TimeStampToStr(Date);
  MessageForm.Position:=poScreenCenter;
  MessageForm.ClientWidth:=400;
  MessageForm.ClientHeight:=300;

  MessageLabel:=TLabel.Create(MessageForm);
  MessageLabel.Parent:=MessageForm;
  MessageLabel.Top:=10;
  MessageLabel.Left:=8;
  MessageLabel.Caption:=SourceToInterface(GetDCLMessageString(msForUser))+' : ';

  MessageEdit:=TEdit.Create(MessageForm);
  MessageEdit.Parent:=MessageForm;
  MessageEdit.ReadOnly:=True;
  MessageEdit.Text:=nUserName;
  MessageEdit.Top:=25;
  MessageEdit.Left:=8;
  MessageEdit.Width:=250;

  MessageMemo:=TMemo.Create(MessageForm);
  MessageMemo.Parent:=MessageForm;
  MessageMemo.ReadOnly:=True;
  MessageMemo.ScrollBars:=ssVertical;
  MessageMemo.Top:=55;
  MessageMemo.Left:=8;
  MessageMemo.Height:=200;
  MessageMemo.Width:=375;

  If (MessageText<>'') Then
  Begin
    MessageMemo.Lines.Append(MessageText);
    MessageForm.Show;
  End;
end;

destructor TMessageFormObject.Destroy;
begin
  MessageForm.Release;

  inherited Destroy;
end;

end.
