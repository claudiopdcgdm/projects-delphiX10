object frmRelatorioPedidoSaida: TfrmRelatorioPedidoSaida
  Left = 0
  Top = 0
  Caption = 'Relatorio pedido saida'
  ClientHeight = 604
  ClientWidth = 673
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 21
    Top = 27
    Width = 85
    Height = 24
    Caption = 'Pesquisar'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -20
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object DBGrid1: TDBGrid
    Left = 0
    Top = 88
    Width = 673
    Height = 516
    Align = alBottom
    TabOrder = 0
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -11
    TitleFont.Name = 'Tahoma'
    TitleFont.Style = []
  end
  object TEdit
    Left = 112
    Top = 24
    Width = 393
    Height = 32
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -20
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    ParentShowHint = False
    ShowHint = True
    TabOrder = 1
    TextHint = 'Numero pedido'
  end
  object btnIr: TButton
    Left = 511
    Top = 24
    Width = 75
    Height = 32
    Caption = 'IR'
    TabOrder = 2
    OnClick = btnIrClick
  end
  object FDConnection1: TFDConnection
    Params.Strings = (
      'Database=app_wms'
      'User_Name=postgres'
      'Password=q1w2e3r4'
      'Server=localhost'
      'DriverID=PG')
    Left = 640
    Top = 16
  end
end
