object fmMain: TfmMain
  Left = 0
  Top = 0
  ClientHeight = 200
  ClientWidth = 300
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  ScreenSnap = True
  PixelsPerInch = 96
  TextHeight = 13
  object Config: TValueListEditor
    Left = 0
    Top = 0
    Width = 300
    Height = 200
    Align = alClient
    DropDownRows = 12
    FixedCols = 1
    TabOrder = 0
    OnSetEditText = ConfigSetEditText
    OnValidate = ConfigValidate
    ColWidths = (
      150
      144)
  end
end
