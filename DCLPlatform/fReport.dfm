object MainForm: TMainForm
  Left = 633
  Top = 281
  ClientHeight = 79
  ClientWidth = 301
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Position = poDesktopCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object ButtonPrint: TButton
    Left = 16
    Top = 24
    Width = 75
    Height = 25
    Caption = 'Print'
    TabOrder = 0
    OnClick = ButtonPrintClick
  end
  object InDOSCodePage: TCheckBox
    Left = 120
    Top = 28
    Width = 149
    Height = 19
    Caption = 'DOS Codepage'
    TabOrder = 1
  end
  object OpenDialog1: TOpenDialog
    DefaultExt = '.drt'
    Filter = 'DCL '#1054#1090#1095#1105#1090#1099'|*.dcl;*.drt;*.dcr'
    Left = 17
    Top = 28
  end
  object Timer1: TTimer
    Enabled = False
    Interval = 800
    OnTimer = Timer1Timer
    Left = 264
    Top = 12
  end
end
