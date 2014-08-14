object MainForm: TMainForm
  Left = 633
  Height = 79
  Top = 281
  Width = 280
  ClientHeight = 79
  ClientWidth = 280
  Color = clBtnFace
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  OnCreate = FormCreate
  LCLVersion = '1.2.4.0'
  object ButtonPrint: TButton
    Left = 16
    Height = 25
    Top = 24
    Width = 75
    Caption = 'Print'
    OnClick = ButtonPrintClick
    TabOrder = 0
  end
  object InDOSCodePage: TCheckBox
    Left = 120
    Height = 19
    Top = 28
    Width = 93
    Caption = 'DOS Codepage'
    TabOrder = 1
  end
  object OpenDialog1: TOpenDialog
    DefaultExt = '.drt'
    Filter = 'DCL Îò÷¸òû|*.dcl;*.drt;*.dcr'
    left = 17
    top = 28
  end
end
