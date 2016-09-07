object frSlideEditor: TfrSlideEditor
  Left = 211
  Top = 121
  Caption = #1056#1077#1076#1072#1082#1090#1086#1088' '#1089#1082#1088#1080#1087#1090#1072
  ClientHeight = 411
  ClientWidth = 573
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  FormStyle = fsMDIChild
  OldCreateOrder = False
  Position = poDefault
  Visible = True
  OnClose = FormClose
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Memo1: TDBMemo
    Left = 0
    Top = 91
    Width = 573
    Height = 301
    Align = alClient
    DataSource = DataModule1.DataSource1
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Courier New'
    Font.Style = []
    ParentFont = False
    ScrollBars = ssBoth
    TabOrder = 0
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 392
    Width = 573
    Height = 19
    Panels = <>
  end
  object Panel2: TPanel
    Left = 0
    Top = 0
    Width = 573
    Height = 56
    Align = alTop
    BevelInner = bvLowered
    TabOrder = 2
    object Label1: TLabel
      Left = 15
      Top = 9
      Width = 45
      Height = 13
      Caption = #1050#1086#1084#1072#1085#1076#1072
    end
    object Label2: TLabel
      Left = 175
      Top = 10
      Width = 17
      Height = 13
      Caption = #1048#1076'.'
    end
    object Label3: TLabel
      Left = 250
      Top = 10
      Width = 73
      Height = 13
      Caption = #1048#1076'. '#1088#1086#1076#1080#1090#1077#1083#1100#1103
    end
    object Label4: TLabel
      Left = 380
      Top = 10
      Width = 81
      Height = 13
      Caption = #1056#1072#1079#1084#1077#1088' '#1096#1088#1080#1092#1090#1072
    end
    object SpeedButton9: TSpeedButton
      Left = 480
      Top = 24
      Width = 23
      Height = 22
      Hint = #1053#1072#1089#1090#1088#1086#1081#1082#1080' '#1096#1088#1080#1092#1090#1072
      Caption = 'F'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      ParentShowHint = False
      ShowHint = True
      OnClick = SpeedButton9Click
    end
    object SpeedButton10: TSpeedButton
      Left = 520
      Top = 24
      Width = 23
      Height = 22
      Hint = #1062#1074#1077#1090' '#1092#1086#1085#1072
      Caption = 'C'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clRed
      Font.Height = -13
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      ParentShowHint = False
      ShowHint = True
      OnClick = SpeedButton10Click
    end
    object SpeedButton11: TSpeedButton
      Left = 140
      Top = 24
      Width = 23
      Height = 22
      Hint = #1055#1077#1088#1077#1081#1090#1080
      Caption = '...'
      ParentShowHint = False
      ShowHint = True
    end
    object SpeedButton12: TSpeedButton
      Left = 332
      Top = 23
      Width = 23
      Height = 22
      Hint = #1055#1077#1088#1077#1081#1090#1080
      Caption = '...'
      ParentShowHint = False
      ShowHint = True
    end
    object DBEdit1: TDBEdit
      Left = 15
      Top = 24
      Width = 121
      Height = 21
      DataSource = DataModule1.DataSource1
      TabOrder = 0
    end
    object DBEdit2: TDBEdit
      Left = 175
      Top = 24
      Width = 55
      Height = 21
      DataSource = DataModule1.DataSource1
      TabOrder = 1
    end
    object DBEdit3: TDBEdit
      Left = 250
      Top = 24
      Width = 75
      Height = 21
      DataSource = DataModule1.DataSource1
      TabOrder = 2
    end
    object SpinEdit1: TSpinEdit
      Left = 380
      Top = 24
      Width = 58
      Height = 22
      MaxValue = 78
      MinValue = 5
      TabOrder = 3
      Value = 8
      OnChange = SpinEdit1Change
    end
  end
  object Panel3: TPanel
    Left = 0
    Top = 56
    Width = 573
    Height = 35
    Align = alTop
    BevelInner = bvLowered
    TabOrder = 3
    object SpeedButton1: TSpeedButton
      Left = 266
      Top = 6
      Width = 23
      Height = 22
      Hint = #1050#1086#1087#1080#1088#1086#1074#1072#1090#1100' '#1089#1082#1088#1080#1087#1090
      Glyph.Data = {
        36050000424D3605000000000000360400002800000010000000100000000100
        08000000000000010000130B0000130B00000001000000000000000000003535
        3500336600003366660066333300666600006B6B6B0000009900333399000000
        CC000000FF000033CC003366FF00009900003399000000FF000066CC33003399
        99001C9DD40000CCCC0000CCFF0000FFFF0033FFFF00669999006699FF0066CC
        CC0099000000993333009934340099353500993636009937370099663300CC00
        3300CC333300CC343400FF000000FF343400CC663300FF663400FF673400CC99
        0000CC993300FF993400CCCC3300FFFF66008686860093939300A1A1A100AEAE
        AE00BBBABA00BBBBBB0099CCCC0099FFFF00CC999900FFCC9900C9C9C900D6D6
        D600CCCCFF00CCFFFF00FFCCCC00E4E4E400F1F1F100FFFFFF00333333003333
        3600363636003636360033333300333336003636360036363600333333003333
        3600363636003636360033333300363636003636360002161300333333003333
        330033333300333333003333330033333300333333003333330033331B003636
        3600363636003633330033331B0036363600363636003333330033331B003636
        3600363636003333330033333000303030003030300030303300333333003333
        3300333333003333330033333300333333003333330033333300333333003333
        3300333333003333330031313100313131003131310033333300333333003333
        3300333333003333330033333300333333003333330033333300333333003333
        33003333330033333300333333001B3333003333330033333300333333003333
        3300333333003333330033333300333333003333330020333300333333003333
        3300333333003333330033333300333333003333330033333300333333003333
        330033333300333333003333330033333300333333001B333300333333003333
        33003F3F3F003F3F3F00333333003333330033333300062F2F00333333003333
        3000303030003030300033333300333333003333330033333300333333003333
        3300333333003333330033333300333333003333330033333300333333003636
        3600363636000216130036363600363636003619170017033300303020002020
        2000333333003333330036363600362F2F002F2F2F002F2F2F00333030003030
        3000303030003033330033333300333333003333330033333300333333003333
        3300333333003333330033333300333333003333330033333300333333003333
        3300333333003333330033333300333333003333330033333300333333003333
        330033333300333333003333330033333C003D3D3D003D3D3D00333333003333
        3C003D3D3D003D3D3D003333330033333C003D3D3D003D3D3D00333333003D3D
        3D003D3D3D001013000033333300331B1B001B1B330033333300333333003333
        33003333330033333300331B1B003D3D3D003D3D3D0036333300333333333333
        30303030303030303030333333333333303F3F3F3D3F3F3F3F30333333333333
        303F3F223D3D3F3F3F303030303030302E3D3D22223D3D3F3F30303F3F3F3F3F
        2222222222223D3D3F30303F3F3F2222222222222222223F3F30303F3F222222
        2222222222223F3F3F30303F22222222303F3F22223F3F3F3F30303F2222223F
        303F3F223F3F3F3F3F30303F3F223F3F303F3F3F3F3F30303030303F3F3F3F3F
        303F3F3F3F3F303F3F30303F3F3F3F3F303F3F3F3F3F303F3033303F3F3F3F3F
        30303030303030303333303F3F3F3F3F303F3F30333333333333303F3F3F3F3F
        303F303333333333333330303030303030303333333333333333}
      ParentShowHint = False
      ShowHint = True
    end
    object DBNavigator1: TDBNavigator
      Left = 15
      Top = 6
      Width = 222
      Height = 23
      DataSource = DataModule1.DataSource1
      VisibleButtons = [nbInsert, nbPost, nbCancel]
      TabOrder = 0
    end
  end
  object FontDialog1: TFontDialog
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    Left = 461
    Top = 224
  end
  object ColorDialog1: TColorDialog
    Left = 368
    Top = 220
  end
  object PopupMenu1: TPopupMenu
    Left = 113
    Top = 160
    object N4: TMenuItem
      Caption = #1042#1099#1088#1077#1079#1072#1090#1100
      ShortCut = 16472
      OnClick = N4Click
    end
    object N2: TMenuItem
      Caption = #1050#1086#1087#1080#1088#1086#1074#1072#1090#1100
      ShortCut = 16451
      OnClick = N2Click
    end
    object N3: TMenuItem
      Caption = #1042#1089#1090#1072#1074#1080#1090#1100
      ShortCut = 16464
      OnClick = N3Click
    end
    object N6: TMenuItem
      Caption = #1054#1090#1084#1077#1085#1080#1090#1100
      ShortCut = 16474
      OnClick = N6Click
    end
    object N8: TMenuItem
      Caption = '-'
    end
    object N7: TMenuItem
      Caption = #1042#1099#1076#1077#1083#1080#1090#1100' '#1074#1089#1105
      ShortCut = 16449
      OnClick = N7Click
    end
    object N5: TMenuItem
      Caption = '-'
    end
    object N1: TMenuItem
      Caption = #1055#1077#1088#1077#1081#1090#1080' '#1082' '#1074#1099#1076#1077#1083#1077#1085#1085#1086#1084#1091' '#1089#1082#1088#1080#1087#1090#1091
      OnClick = N1Click
    end
  end
end
