object frVerInfo: TfrVerInfo
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = #1057#1074#1077#1076#1077#1085#1080#1103' '#1086' '#1074#1077#1088#1089#1080#1080' '#1080' '#1087#1088#1086#1076#1091#1082#1090#1077
  ClientHeight = 159
  ClientWidth = 484
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  FormStyle = fsMDIChild
  OldCreateOrder = False
  Position = poDefault
  Visible = True
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 8
    Top = 8
    Width = 465
    Height = 145
    BevelInner = bvLowered
    TabOrder = 0
    object Label1: TLabel
      Left = 24
      Top = 16
      Width = 139
      Height = 13
      Caption = #1057#1074#1077#1076#1077#1085#1080#1103' '#1086' '#1082#1086#1085#1092#1080#1075#1091#1088#1072#1094#1080#1080':'
    end
    object Label2: TLabel
      Left = 232
      Top = 16
      Width = 39
      Height = 13
      Caption = #1042#1077#1088#1089#1080#1103':'
    end
    object Panel2: TPanel
      Left = 232
      Top = 35
      Width = 210
      Height = 40
      BevelInner = bvLowered
      TabOrder = 0
      object VerNum1: TEdit
        Left = 10
        Top = 10
        Width = 40
        Height = 21
        TabOrder = 0
      end
      object VerNum2: TEdit
        Left = 60
        Top = 10
        Width = 40
        Height = 21
        TabOrder = 1
      end
      object VerNum3: TEdit
        Left = 110
        Top = 10
        Width = 40
        Height = 21
        TabOrder = 2
      end
      object VerNum4: TEdit
        Left = 160
        Top = 10
        Width = 40
        Height = 21
        TabOrder = 3
      end
    end
    object Button1: TButton
      Left = 367
      Top = 101
      Width = 75
      Height = 25
      Caption = #1047#1072#1087#1080#1089#1072#1090#1100
      TabOrder = 1
      OnClick = Button1Click
    end
    object MemoVerInfo: TMemo
      Left = 24
      Top = 35
      Width = 185
      Height = 89
      Lines.Strings = (
        'MemoVerInfo')
      TabOrder = 2
    end
  end
end
