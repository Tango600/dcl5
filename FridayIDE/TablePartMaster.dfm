object FormTPMaster: TFormTPMaster
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'FormTPMaster'
  ClientHeight = 299
  ClientWidth = 564
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  PixelsPerInch = 96
  TextHeight = 13
  object PageControl1: TPageControl
    Left = 0
    Top = 0
    Width = 564
    Height = 299
    ActivePage = TabSheet1
    Align = alClient
    TabOrder = 0
    object TabSheet1: TTabSheet
      Caption = #1047#1072#1075#1086#1083#1086#1074#1086#1082
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      object leTitle: TLabeledEdit
        Left = 16
        Top = 32
        Width = 177
        Height = 21
        EditLabel.Width = 53
        EditLabel.Height = 13
        EditLabel.Caption = #1047#1072#1075#1086#1083#1086#1074#1086#1082
        TabOrder = 0
      end
    end
    object TabSheet2: TTabSheet
      Caption = #1047#1072#1087#1088#1086#1089', '#1082#1072#1083#1086#1085#1082#1080
      ImageIndex = 1
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      object SpeedButton1: TSpeedButton
        Left = 464
        Top = 32
        Width = 23
        Height = 22
        Hint = #1055#1086#1083#1091#1095#1080#1090#1100' '#1087#1086#1083#1103
        Caption = '...'
        ParentShowHint = False
        ShowHint = True
      end
      object leSQL: TLabeledEdit
        Left = 24
        Top = 32
        Width = 433
        Height = 21
        EditLabel.Width = 35
        EditLabel.Height = 13
        EditLabel.Caption = #1047#1072#1087#1088#1086#1089
        TabOrder = 0
      end
      object StringGrid1: TStringGrid
        Left = 24
        Top = 96
        Width = 193
        Height = 120
        ColCount = 2
        DefaultRowHeight = 17
        FixedCols = 0
        RowCount = 2
        TabOrder = 1
        ColWidths = (
          83
          91)
      end
      object leMasterDataField: TLabeledEdit
        Left = 272
        Top = 96
        Width = 121
        Height = 21
        EditLabel.Width = 160
        EditLabel.Height = 13
        EditLabel.Caption = #1057#1074#1103#1079#1072#1090#1100' '#1089' '#1087#1086#1083#1077#1084' '#1074' '#1086#1089#1085#1086#1074#1085#1086#1084' '#1053#1044
        TabOrder = 2
      end
      object leDependField: TLabeledEdit
        Left = 272
        Top = 144
        Width = 121
        Height = 21
        EditLabel.Width = 156
        EditLabel.Height = 13
        EditLabel.Caption = #1055#1086#1083#1077' '#1076#1083#1103' '#1089#1074#1103#1079#1080' '#1089' '#1086#1089#1085#1086#1074#1085#1099#1084' '#1053#1044
        TabOrder = 3
      end
    end
    object TabSheet3: TTabSheet
      Caption = #1056#1077#1076#1072#1082#1090#1080#1088#1086#1074#1072#1085#1080#1077
      ImageIndex = 2
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      object rgEditing: TRadioGroup
        Left = 19
        Top = 16
        Width = 185
        Height = 105
        Caption = ' '#1057#1087#1086#1089#1086#1073' '#1088#1077#1076#1072#1082#1090#1080#1088#1086#1074#1072#1085#1080#1103' '
        ItemIndex = 0
        Items.Strings = (
          #1042' '#1076#1080#1072#1083#1086#1075#1077
          #1042' '#1090#1072#1073#1083#1080#1094#1077
          #1054#1073#1077#1080#1084#1080' '#1089#1087#1086#1089#1086#1073#1072#1084#1080
          #1053#1077' '#1088#1077#1076#1072#1082#1090#1080#1088#1086#1074#1072#1090#1100)
        TabOrder = 0
      end
      object Button1: TButton
        Left = 456
        Top = 232
        Width = 75
        Height = 25
        Caption = #1043#1086#1090#1086#1074#1086
        TabOrder = 1
        OnClick = Button1Click
      end
      object rgFieldsStyle: TRadioGroup
        Left = 248
        Top = 16
        Width = 185
        Height = 105
        Caption = ' '#1055#1086#1088#1103#1076#1086#1082' '#1087#1086#1083#1077#1081' '
        ItemIndex = 0
        Items.Strings = (
          #1043#1086#1088#1080#1079#1086#1085#1090#1072#1083#1100#1085#1086
          #1042#1077#1088#1090#1080#1082#1072#1083#1100#1085#1086
          #1042#1077#1088#1090#1080#1082#1072#1083#1100#1085#1086' '#1083#1077#1089#1077#1085#1082#1086#1081)
        TabOrder = 2
      end
    end
  end
end
