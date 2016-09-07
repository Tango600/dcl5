object FormFieldMaster: TFormFieldMaster
  Left = 521
  Top = 288
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = #1052#1072#1089#1090#1077#1088' '#1087#1086#1083#1077#1081
  ClientHeight = 289
  ClientWidth = 554
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
  object PageControl1: TPageControl
    Left = 0
    Top = 0
    Width = 554
    Height = 289
    ActivePage = TabSheet1
    Align = alClient
    TabOrder = 0
    object TabSheet1: TTabSheet
      Caption = #1047#1072#1075#1086#1083#1086#1074#1086#1082' '#1080' '#1087#1086#1083#1077
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      object Label1: TLabel
        Left = 24
        Top = 96
        Width = 25
        Height = 13
        Caption = #1055#1086#1083#1077
      end
      object lbl1: TLabel
        Left = 245
        Top = 30
        Width = 40
        Height = 13
        Caption = #1064#1080#1088#1080#1085#1072
      end
      object leFieldCapt: TLabeledEdit
        Left = 24
        Top = 48
        Width = 161
        Height = 21
        EditLabel.Width = 53
        EditLabel.Height = 13
        EditLabel.Caption = #1047#1072#1075#1086#1083#1086#1074#1086#1082
        TabOrder = 0
      end
      object ComboBox1: TComboBox
        Left = 24
        Top = 115
        Width = 161
        Height = 21
        TabOrder = 1
      end
      object chWoData: TCheckBox
        Left = 24
        Top = 152
        Width = 65
        Height = 17
        Caption = #1041#1077#1079' '#1053#1044
        TabOrder = 2
      end
      object se1: TSpinEdit
        Left = 244
        Top = 45
        Width = 73
        Height = 22
        MaxValue = 0
        MinValue = 0
        TabOrder = 3
        Value = 0
      end
    end
    object TabSheet2: TTabSheet
      Caption = #1058#1080#1087' '#1080' '#1088#1072#1079#1084#1077#1088
      ImageIndex = 1
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
    end
  end
end
