object Form27: TForm27
  Left = 225
  Top = 122
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = #1048#1079#1084#1077#1085#1077#1085#1080#1077' '#1087#1077#1088#1077#1084#1077#1085#1085#1086#1081
  ClientHeight = 171
  ClientWidth = 229
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 2
    Top = 2
    Width = 223
    Height = 163
    BevelInner = bvLowered
    TabOrder = 0
    object LabeledEdit1: TLabeledEdit
      Left = 15
      Top = 89
      Width = 125
      Height = 21
      EditLabel.Width = 48
      EditLabel.Height = 13
      EditLabel.Caption = #1047#1085#1072#1095#1077#1085#1080#1077
      TabOrder = 0
    end
    object LabeledEdit2: TLabeledEdit
      Left = 15
      Top = 25
      Width = 125
      Height = 21
      EditLabel.Width = 64
      EditLabel.Height = 13
      EditLabel.Caption = #1055#1077#1088#1077#1084#1077#1085#1085#1072#1103
      ReadOnly = True
      TabOrder = 1
    end
    object Button1: TButton
      Left = 16
      Top = 125
      Width = 75
      Height = 25
      Caption = #1055#1088#1080#1085#1103#1090#1100
      TabOrder = 2
      OnClick = Button1Click
    end
    object Button2: TButton
      Left = 131
      Top = 125
      Width = 75
      Height = 25
      Caption = #1047#1072#1082#1088#1099#1090#1100
      TabOrder = 3
      OnClick = Button2Click
    end
  end
end
