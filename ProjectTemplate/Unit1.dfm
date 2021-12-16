object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Form1'
  ClientHeight = 299
  ClientWidth = 635
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Memo1: TMemo
    Left = 0
    Top = 0
    Width = 635
    Height = 258
    Align = alClient
    Lines.Strings = (
      'Memo1')
    TabOrder = 0
  end
  object Panel1: TPanel
    Left = 0
    Top = 258
    Width = 635
    Height = 41
    Align = alBottom
    Caption = 'Panel1'
    TabOrder = 1
    object Button1: TButton
      Left = 1
      Top = 1
      Width = 75
      Height = 39
      Align = alLeft
      Caption = 'Part1'
      TabOrder = 0
      OnClick = Button1Click
    end
    object Button2: TButton
      Left = 76
      Top = 1
      Width = 75
      Height = 39
      Align = alLeft
      Caption = 'Part2'
      TabOrder = 1
      OnClick = Button2Click
    end
    object Edit1: TEdit
      Left = 151
      Top = 1
      Width = 483
      Height = 39
      Align = alClient
      TabOrder = 2
      Text = 'fgnjghkhj;h'
      ExplicitHeight = 21
    end
  end
end
