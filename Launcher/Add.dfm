object fAddBase: TfAddBase
  Left = 192
  Top = 107
  BorderIcons = [biSystemMenu]
  Caption = #1044#1077#1090#1072#1083#1080
  ClientHeight = 233
  ClientWidth = 285
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  Position = poScreenCenter
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 285
    Height = 169
    Align = alClient
    BevelInner = bvLowered
    TabOrder = 0
    object SpeedButton1: TSpeedButton
      Left = 248
      Top = 75
      Width = 23
      Height = 22
      Caption = '...'
      OnClick = SpeedButton1Click
    end
    object leNameBase: TLabeledEdit
      Left = 20
      Top = 30
      Width = 250
      Height = 21
      EditLabel.Width = 50
      EditLabel.Height = 13
      EditLabel.Caption = #1053#1072#1079#1074#1072#1085#1080#1077
      EditLabel.Color = clBtnFace
      EditLabel.ParentColor = False
      TabOrder = 0
      Text = ''
    end
    object lePathIni: TLabeledEdit
      Left = 20
      Top = 75
      Width = 220
      Height = 21
      EditLabel.Width = 70
      EditLabel.Height = 13
      EditLabel.Caption = #1055#1091#1090#1100' '#1082' DCL.ini'
      EditLabel.Color = clBtnFace
      EditLabel.ParentColor = False
      TabOrder = 1
      Text = ''
    end
    object leParams: TLabeledEdit
      Left = 20
      Top = 128
      Width = 250
      Height = 21
      EditLabel.Width = 59
      EditLabel.Height = 13
      EditLabel.Caption = #1055#1072#1088#1072#1084#1077#1090#1088#1099
      EditLabel.Color = clBtnFace
      EditLabel.ParentColor = False
      TabOrder = 2
      Text = ''
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 169
    Width = 285
    Height = 41
    Align = alBottom
    BevelInner = bvLowered
    TabOrder = 1
    object btOK: TButton
      Left = 20
      Top = 9
      Width = 75
      Height = 25
      Caption = 'OK'
      Default = True
      TabOrder = 0
      OnClick = btOKClick
    end
    object bkCancel: TButton
      Left = 110
      Top = 9
      Width = 75
      Height = 25
      Cancel = True
      Caption = #1054#1090#1084#1077#1085#1072
      TabOrder = 1
      OnClick = bkCancelClick
    end
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 210
    Width = 285
    Height = 23
    Panels = <>
  end
  object OpenDialog1: TOpenDialog
    DefaultExt = '.ini'
    Filter = 'ini '#1057#8222#1056#176#1056#8470#1056#187#1057#8249'|*.ini|'#1056#8217#1057#1027#1056#181'|*.*'
    Left = 92
    Top = 57
  end
end
