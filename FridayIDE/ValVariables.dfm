object Form26: TForm26
  Left = 192
  Top = 107
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = #1054#1090#1083#1072#1076#1082#1072' - '#1087#1077#1088#1077#1084#1077#1085#1085#1099#1077
  ClientHeight = 455
  ClientWidth = 398
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
  object StatusBar1: TStatusBar
    Left = 0
    Top = 436
    Width = 398
    Height = 19
    Panels = <
      item
        Width = 50
      end>
  end
  object StringGrid1: TStringGrid
    Left = 3
    Top = 4
    Width = 387
    Height = 365
    ColCount = 2
    DefaultColWidth = 90
    DefaultRowHeight = 17
    FixedCols = 0
    RowCount = 2
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goRowSizing, goColSizing]
    TabOrder = 1
    ColWidths = (
      118
      164)
  end
  object Button1: TButton
    Left = 7
    Top = 380
    Width = 75
    Height = 25
    Caption = #1054#1073#1085#1086#1074#1080#1090#1100
    TabOrder = 2
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 135
    Top = 380
    Width = 75
    Height = 25
    Caption = #1048#1079#1084#1077#1085#1080#1090#1100
    TabOrder = 3
    OnClick = Button2Click
  end
  object CheckBox1: TCheckBox
    Left = 10
    Top = 412
    Width = 97
    Height = 17
    Caption = #1055#1086#1074#1077#1088#1093' '#1074#1089#1077#1093
    TabOrder = 4
    OnClick = CheckBox1Click
  end
  object Button3: TButton
    Left = 225
    Top = 380
    Width = 75
    Height = 25
    Caption = #1057#1086#1079#1076#1072#1090#1100
    TabOrder = 5
    OnClick = Button3Click
  end
  object Button4: TButton
    Left = 315
    Top = 380
    Width = 75
    Height = 25
    Caption = #1059#1076#1072#1083#1080#1090#1100
    TabOrder = 6
    OnClick = Button4Click
  end
end
