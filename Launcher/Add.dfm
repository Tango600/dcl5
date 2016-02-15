object fAddBase: TfAddBase
  Left = 192
  Height = 233
  Top = 107
  Width = 285
  BorderIcons = [biSystemMenu]
  Caption = 'Добавление...'
  ClientHeight = 233
  ClientWidth = 285
  Color = clBtnFace
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  OnShow = FormShow
  Position = poScreenCenter
  LCLVersion = '1.4.4.0'
  object Panel1: TPanel
    Left = 0
    Height = 169
    Top = 0
    Width = 285
    Align = alClient
    BevelInner = bvLowered
    ClientHeight = 169
    ClientWidth = 285
    TabOrder = 0
    object SpeedButton1: TSpeedButton
      Left = 248
      Height = 22
      Top = 75
      Width = 23
      Caption = '...'
      OnClick = SpeedButton1Click
    end
    object leNameBase: TLabeledEdit
      Left = 20
      Height = 21
      Top = 30
      Width = 250
      EditLabel.AnchorSideLeft.Control = leNameBase
      EditLabel.AnchorSideRight.Control = leNameBase
      EditLabel.AnchorSideRight.Side = asrBottom
      EditLabel.AnchorSideBottom.Control = leNameBase
      EditLabel.Left = 20
      EditLabel.Height = 13
      EditLabel.Top = 14
      EditLabel.Width = 250
      EditLabel.Caption = 'Название'
      EditLabel.ParentColor = False
      TabOrder = 0
    end
    object lePathIni: TLabeledEdit
      Left = 20
      Height = 21
      Top = 75
      Width = 220
      EditLabel.AnchorSideLeft.Control = lePathIni
      EditLabel.AnchorSideRight.Control = lePathIni
      EditLabel.AnchorSideRight.Side = asrBottom
      EditLabel.AnchorSideBottom.Control = lePathIni
      EditLabel.Left = 20
      EditLabel.Height = 13
      EditLabel.Top = 59
      EditLabel.Width = 220
      EditLabel.Caption = 'Путь'
      EditLabel.ParentColor = False
      TabOrder = 1
    end
    object leParams: TLabeledEdit
      Left = 20
      Height = 21
      Top = 128
      Width = 250
      EditLabel.AnchorSideLeft.Control = leParams
      EditLabel.AnchorSideRight.Control = leParams
      EditLabel.AnchorSideRight.Side = asrBottom
      EditLabel.AnchorSideBottom.Control = leParams
      EditLabel.Left = 20
      EditLabel.Height = 13
      EditLabel.Top = 112
      EditLabel.Width = 250
      EditLabel.Caption = 'Параметры'
      EditLabel.ParentColor = False
      TabOrder = 2
    end
  end
  object Panel2: TPanel
    Left = 0
    Height = 41
    Top = 169
    Width = 285
    Align = alBottom
    BevelInner = bvLowered
    ClientHeight = 41
    ClientWidth = 285
    TabOrder = 1
    object btOK: TButton
      Left = 20
      Height = 25
      Top = 9
      Width = 75
      Caption = 'OK'
      Default = True
      OnClick = btOKClick
      TabOrder = 0
    end
    object bkCancel: TButton
      Left = 110
      Height = 25
      Top = 9
      Width = 75
      Cancel = True
      Caption = 'Отмена'
      OnClick = bkCancelClick
      TabOrder = 1
    end
  end
  object StatusBar1: TStatusBar
    Left = 0
    Height = 23
    Top = 210
    Width = 285
    Panels = <>
  end
  object OpenDialog1: TOpenDialog
    DefaultExt = '.ini'
    Filter = 'ini файлы|*.ini|Все|*.*'
    left = 92
    top = 57
  end
end
