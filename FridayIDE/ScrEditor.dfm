object TScrEditor: TTScrEditor
  Left = 205
  Top = 111
  Caption = 'TScrEditor'
  ClientHeight = 300
  ClientWidth = 454
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
  OnActivate = FormActivate
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Memo1: TMemo
    Left = 0
    Top = 41
    Width = 454
    Height = 240
    Align = alClient
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Courier New'
    Font.Style = []
    ParentFont = False
    PopupMenu = PopupMenu2
    ScrollBars = ssBoth
    TabOrder = 0
    OnChange = Memo1Change
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 454
    Height = 41
    Align = alTop
    BevelInner = bvLowered
    TabOrder = 1
    object Button1: TButton
      Left = 15
      Top = 6
      Width = 75
      Height = 25
      Caption = #1057#1086#1093#1088#1072#1085#1080#1090#1100
      TabOrder = 0
      OnClick = Button1Click
    end
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 281
    Width = 454
    Height = 19
    Panels = <>
  end
  object PopupMenu2: TPopupMenu
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
    object N7: TMenuItem
      Caption = '-'
    end
    object N1: TMenuItem
      Caption = #1042#1099#1076#1077#1083#1080#1090#1100' '#1074#1089#1105
      ShortCut = 16449
      OnClick = N1Click
    end
    object N5: TMenuItem
      Caption = '-'
    end
    object MenuItem1: TMenuItem
      Caption = #1055#1077#1088#1077#1081#1090#1080' '#1082' '#1074#1099#1076#1077#1083#1077#1085#1085#1086#1084#1091' '#1089#1082#1088#1080#1087#1090#1091
      OnClick = MenuItem1Click
    end
  end
end
