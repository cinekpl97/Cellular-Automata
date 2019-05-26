object frmMain: TfrmMain
  Left = 0
  Top = 0
  Caption = 'Automaty Kom'#243'rkowe'
  ClientHeight = 845
  ClientWidth = 1084
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  PrintScale = poNone
  Scaled = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object boardImage: TImage
    Left = 0
    Top = 0
    Width = 897
    Height = 845
    Align = alClient
    AutoSize = True
    ParentShowHint = False
    Proportional = True
    ShowHint = False
    Stretch = True
    OnClick = boardImageClick
    ExplicitWidth = 100
  end
  object Panel1: TPanel
    Left = 897
    Top = 0
    Width = 187
    Height = 845
    Align = alRight
    Alignment = taLeftJustify
    BevelOuter = bvNone
    Color = clActiveCaption
    ParentBackground = False
    TabOrder = 0
    object lblRegula: TLabel
      Left = 6
      Top = 112
      Width = 39
      Height = 13
      Caption = 'Regu'#322'a'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Verdana'
      Font.Style = []
      ParentFont = False
    end
    object cmbCzas: TLabel
      Left = 6
      Top = 15
      Width = 28
      Height = 13
      Caption = 'Czas'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Verdana'
      Font.Style = []
      ParentFont = False
    end
    object lblSzerokosc: TLabel
      Left = 6
      Top = 42
      Width = 59
      Height = 13
      Caption = 'Szeroko'#347#263
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Verdana'
      Font.Style = []
      ParentFont = False
    end
    object edtTime: TEdit
      Left = 75
      Top = 12
      Width = 95
      Height = 21
      MaxLength = 5
      NumbersOnly = True
      TabOrder = 1
      Text = '0'
      OnChange = edtTimeChange
    end
    object edtSzerokosc: TEdit
      Left = 75
      Top = 39
      Width = 95
      Height = 21
      NumbersOnly = True
      TabOrder = 2
      Text = '0'
      OnChange = edtSzerokoscChange
    end
    object btnDraw: TButton
      Left = 46
      Top = 139
      Width = 81
      Height = 23
      Caption = 'Rysuj'
      Default = True
      DisabledImageIndex = 0
      DoubleBuffered = True
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Verdana'
      Font.Style = []
      HotImageIndex = 0
      ImageIndex = 0
      ParentDoubleBuffered = False
      ParentFont = False
      PressedImageIndex = 0
      SelectedImageIndex = 0
      StylusHotImageIndex = 0
      TabOrder = 3
      OnClick = btnDrawClick
    end
    object edtRuleNo: TEdit
      Left = 75
      Top = 108
      Width = 95
      Height = 21
      MaxLength = 3
      NumbersOnly = True
      TabOrder = 0
      Text = '0'
      OnChange = edtRuleNoChange
    end
    object cmbRuleType: TComboBox
      Left = 30
      Top = 81
      Width = 121
      Height = 21
      Style = csDropDownList
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Verdana'
      Font.Style = []
      ItemIndex = 0
      ParentFont = False
      TabOrder = 4
      Text = 'Rule1D'
      OnChange = cmbRuleTypeChange
      Items.Strings = (
        'Rule1D'
        'Rule2D'
        'Rozrost Ziaren')
    end
    object cmbChooseRule2D: TComboBox
      Left = 30
      Top = 112
      Width = 121
      Height = 21
      Style = csDropDownList
      ItemIndex = 2
      TabOrder = 5
      Text = 'r'#281'czna definicja'
      Visible = False
      OnChange = cmbChooseRule2DChange
      Items.Strings = (
        'niezmienne'
        'glider'
        'r'#281'czna definicja'
        'oscylator'
        'losowy')
    end
    object btnDrawRule2D: TButton
      Left = 48
      Top = 139
      Width = 81
      Height = 25
      Caption = 'Uruchom'
      TabOrder = 6
      Visible = False
      OnClick = btnDrawRule2DClick
    end
    object btnCleanRefreshGrid: TButton
      Left = 32
      Top = 200
      Width = 121
      Height = 25
      Caption = 'Wyczy'#347#263'/od'#347'wie'#380' siatk'#281
      TabOrder = 7
      OnClick = btnCleanRefreshGridClick
    end
    object cmbGrainGrowth: TComboBox
      Left = 32
      Top = 140
      Width = 121
      Height = 21
      Style = csDropDownList
      ItemIndex = 0
      TabOrder = 8
      Text = 'von Neumann'
      Visible = False
      Items.Strings = (
        'von Neumann'
        'Moore'
        'heksagonalne'
        'pentagonalne losowe')
    end
    object cmbChooseGrainLocations: TComboBox
      Left = 32
      Top = 112
      Width = 121
      Height = 21
      Style = csDropDownList
      ItemIndex = 3
      TabOrder = 9
      Text = 'r'#281'czna definicja'
      Visible = False
      OnChange = cmbChooseGrainLocationsChange
      Items.Strings = (
        'jednorodne'
        'losowe'
        'z promieniem'
        'r'#281'czna definicja')
    end
    object btnDrawGrainGrowth: TButton
      Left = 48
      Top = 170
      Width = 81
      Height = 23
      Caption = 'Rysuj'
      TabOrder = 10
      Visible = False
      OnClick = btnDrawGrainGrowthClick
    end
    object cmbBoundaryConditions: TComboBox
      Left = 32
      Top = 240
      Width = 121
      Height = 21
      Style = csDropDownList
      ItemIndex = 0
      TabOrder = 11
      Text = 'absorpcyjne'
      Items.Strings = (
        'absorpcyjne'
        'periodyczne')
    end
    object edtRowCellAmount: TEdit
      Left = 72
      Top = 288
      Width = 95
      Height = 21
      NumbersOnly = True
      TabOrder = 12
      Text = '0'
      Visible = False
      OnChange = edtRowCellAmountChange
    end
    object edtColumnCellAmount: TEdit
      Left = 72
      Top = 328
      Width = 95
      Height = 21
      NumbersOnly = True
      TabOrder = 13
      Text = '0'
      Visible = False
      OnChange = edtColumnCellAmountChange
    end
    object edtRandomAmount: TEdit
      Left = 72
      Top = 371
      Width = 95
      Height = 21
      NumbersOnly = True
      TabOrder = 14
      Text = '0'
      Visible = False
    end
  end
  object TimerRule2D: TTimer
    Enabled = False
    Interval = 500
    OnTimer = TimerRule2DTimer
    Left = 696
    Top = 264
  end
  object TimerGrainGrowth: TTimer
    Enabled = False
    Interval = 750
    OnTimer = TimerGrainGrowthTimer
    Left = 696
    Top = 200
  end
end
