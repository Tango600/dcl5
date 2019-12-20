object FormDialogMaster: TFormDialogMaster
  Left = 0
  Top = 0
  Caption = #1052#1072#1089#1090#1077#1088' '#1076#1080#1072#1083#1086#1075#1086#1074
  ClientHeight = 323
  ClientWidth = 499
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  FormStyle = fsMDIChild
  OldCreateOrder = False
  Visible = True
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object PageControl1: TPageControl
    Left = 0
    Top = 0
    Width = 499
    Height = 323
    ActivePage = TabSheet4
    Align = alClient
    TabOrder = 0
    object TabSheet1: TTabSheet
      Caption = #1047#1072#1075#1086#1083#1086#1074#1086#1082' '#1080' '#1089#1082#1088#1080#1087#1090
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      object Label2: TLabel
        Left = 32
        Top = 152
        Width = 42
        Height = 13
        Caption = #1058#1072#1073#1083#1080#1094#1072
      end
      object leFormCapt: TLabeledEdit
        Left = 32
        Top = 40
        Width = 193
        Height = 21
        EditLabel.Width = 53
        EditLabel.Height = 13
        EditLabel.Caption = #1047#1072#1075#1086#1083#1086#1074#1086#1082
        TabOrder = 0
      end
      object leScrName: TLabeledEdit
        Left = 32
        Top = 104
        Width = 193
        Height = 21
        EditLabel.Width = 63
        EditLabel.Height = 13
        EditLabel.Caption = #1048#1084#1103' '#1089#1082#1088#1080#1087#1090#1072
        TabOrder = 1
      end
      object chAddMenuItem: TCheckBox
        Left = 32
        Top = 208
        Width = 225
        Height = 17
        Caption = #1044#1086#1073#1072#1074#1080#1090#1100' '#1089#1086#1087#1091#1090#1089#1090#1074#1091#1102#1097#1080#1081' '#1087#1091#1085#1082#1090' '#1084#1077#1085#1102
        TabOrder = 2
      end
      object chNewDialog: TCheckBox
        Left = 32
        Top = 8
        Width = 153
        Height = 17
        Caption = #1057#1086#1079#1076#1072#1090#1100' '#1085#1086#1074#1099#1081' '#1076#1080#1072#1083#1086#1075
        Checked = True
        State = cbChecked
        TabOrder = 3
      end
      object cbTables: TComboBox
        Left = 32
        Top = 168
        Width = 145
        Height = 21
        TabOrder = 4
      end
    end
    object TabSheet2: TTabSheet
      Caption = #1054#1090#1086#1073#1088#1072#1078#1077#1085#1080#1077' '#1076#1072#1085#1085#1099#1093
      ImageIndex = 1
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      object rgFieldsStyle: TRadioGroup
        Left = 16
        Top = 16
        Width = 185
        Height = 113
        Caption = ' '#1054#1090#1086#1073#1088#1072#1078#1077#1085#1080#1077' '
        ItemIndex = 0
        Items.Strings = (
          #1058#1072#1073#1083#1080#1094#1072
          #1055#1086#1083#1103' ('#1074#1077#1088#1090#1080#1082#1072#1083#1100#1085#1086')'
          #1055#1086#1083#1103' ('#1083#1077#1089#1077#1085#1082#1086#1081', '#1074#1077#1088#1090#1080#1082#1072#1083#1100#1085#1086')'
          #1055#1086#1083#1103' ('#1075#1086#1088#1080#1079#1086#1085#1090#1072#1083#1100#1085#1086')')
        TabOrder = 0
      end
    end
    object TabSheet3: TTabSheet
      Caption = #1056#1077#1076#1072#1082#1090#1080#1088#1086#1074#1072#1085#1080#1077
      ImageIndex = 2
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      object rgEditingStyle: TRadioGroup
        Left = 223
        Top = 16
        Width = 225
        Height = 105
        Caption = ' '#1057#1087#1086#1089#1086#1073' '#1088#1077#1076#1072#1082#1090#1080#1088#1086#1074#1072#1085#1080#1103' '
        ItemIndex = 1
        Items.Strings = (
          #1055#1086' '#1076#1074#1086#1081#1085#1086#1084#1091' '#1097#1077#1083#1095#1082#1091' '#1085#1072' '#1090#1072#1073#1083#1080#1094#1077
          #1055#1086' '#1082#1085#1086#1087#1082#1072#1084' ('#1048#1079#1084#1077#1085#1080#1090#1100', '#1044#1086#1073#1072#1074#1080#1090#1100')'
          #1055#1086' '#1082#1085#1086#1087#1082#1072#1084' '#1085#1072#1074#1080#1075#1072#1094#1080#1080
          #1055#1086' '#1097#1077#1083#1095#1082#1091' '#1080' '#1082#1085#1086#1087#1082#1072#1084)
        TabOrder = 0
      end
      object rgEditing: TRadioGroup
        Left = 16
        Top = 16
        Width = 185
        Height = 113
        Caption = ' '#1056#1077#1076#1072#1082#1090#1080#1088#1086#1074#1072#1085#1080#1077' '
        ItemIndex = 0
        Items.Strings = (
          #1042' '#1086#1090#1076#1077#1083#1100#1085#1086#1084' '#1076#1080#1072#1083#1086#1075#1077
          #1042' '#1101#1090#1086#1084' '#1076#1080#1072#1083#1086#1075#1077
          #1053#1077' '#1088#1077#1076#1072#1082#1090#1080#1088#1086#1074#1072#1090#1100)
        TabOrder = 1
      end
      object chDialogEditing: TCheckBox
        Left = 16
        Top = 183
        Width = 234
        Height = 17
        Caption = #1056#1072#1079#1088#1077#1096#1080#1090#1100' '#1088#1077#1076#1072#1082#1090#1080#1088#1086#1074#1072#1085#1080#1077' '#1074' '#1076#1080#1072#1083#1086#1075#1077
        TabOrder = 2
      end
      object chNavButtonsInEditing: TCheckBox
        Left = 16
        Top = 216
        Width = 345
        Height = 17
        Caption = #1048#1089#1087#1086#1083#1100#1079#1086#1074#1072#1090#1100' '#1082#1085#1086#1087#1082#1080' '#1085#1072#1074#1080#1075#1072#1090#1086#1088#1072' '#1074' '#1076#1080#1072#1083#1086#1075#1077' '#1088#1077#1076#1072#1082#1090#1080#1088#1086#1074#1072#1085#1080#1103
        TabOrder = 3
      end
      object chHorizontalEditDialog: TCheckBox
        Left = 16
        Top = 248
        Width = 313
        Height = 17
        Caption = #1043#1086#1088#1080#1079#1086#1085#1090#1072#1083#1100#1085#1099#1077' '#1087#1086#1083#1103' '#1074' '#1076#1080#1072#1083#1086#1075#1077' '#1088#1077#1076#1072#1082#1090#1080#1088#1086#1074#1072#1085#1080#1103
        TabOrder = 4
      end
    end
    object TabSheet4: TTabSheet
      Caption = #1042#1085#1077#1096#1085#1080#1081' '#1074#1080#1076
      ImageIndex = 3
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      object Label1: TLabel
        Left = 32
        Top = 45
        Width = 99
        Height = 13
        Caption = #1050#1085#1086#1087#1082#1080' '#1085#1072#1074#1080#1075#1072#1090#1086#1088#1072
      end
      object CheckBox1: TCheckBox
        Left = 32
        Top = 16
        Width = 129
        Height = 17
        Caption = #1055#1083#1086#1089#1082#1080#1081' '#1085#1072#1074#1080#1075#1072#1090#1086#1088
        TabOrder = 0
      end
      object ListNavButtons: TCheckListBox
        Left = 32
        Top = 64
        Width = 121
        Height = 141
        ItemHeight = 13
        Items.Strings = (
          #1042' '#1085#1072#1095#1072#1083#1086
          #1053#1072#1079#1072#1076
          #1042#1087#1077#1088#1105#1076
          #1042' '#1082#1086#1085#1077#1094
          #1042#1089#1090#1072#1074#1080#1090#1100
          #1056#1077#1076#1072#1082#1090#1080#1088#1086#1074#1072#1090#1100
          #1057#1086#1093#1088#1072#1085#1080#1090#1100
          #1059#1076#1072#1083#1080#1090#1100
          #1054#1090#1084#1077#1085#1080#1090#1100
          #1054#1073#1085#1086#1074#1080#1090#1100)
        TabOrder = 1
      end
      object Button1: TButton
        Left = 400
        Top = 248
        Width = 75
        Height = 25
        Caption = #1043#1086#1090#1086#1074#1086
        TabOrder = 2
        OnClick = Button1Click
      end
    end
  end
end
