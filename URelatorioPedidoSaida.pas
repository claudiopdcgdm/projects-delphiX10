unit URelatorioPedidoSaida;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Data.DB, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf,
  FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys,
  FireDAC.Phys.PG, FireDAC.Phys.PGDef, FireDAC.VCLUI.Wait, FireDAC.Comp.Client,
  Vcl.StdCtrls, Vcl.Grids, Vcl.DBGrids;

type
  TfrmRelatorioPedidoSaida = class(TForm)
    DBGrid1: TDBGrid;
    Label1: TLabel;
    FDConnection1: TFDConnection;
    btnIr: TButton;
    procedure btnIrClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmRelatorioPedidoSaida: TfrmRelatorioPedidoSaida;

implementation

{$R *.dfm}

uses UfrmSeparacaoPedido, UfrmPedidoSaida;

procedure TfrmRelatorioPedidoSaida.btnIrClick(Sender: TObject);
var pgQuery:TFDQuery;

begin
  pgQuery:= TFDQuery.Create(self);
  pgQuery.Connection := FDConnection1;
  DBGrid1.DataSource.DataSet := pgQuery;

  pgQuery.SQL.Add('SELECT * FROM selectrelseparacao(:numeropedido)');
  pgQuery.ParamByName(':numeropedido');


  try
    FDConnection1.Open();
    pgQuery.Open();
  except on E: Exception do
    ShowMessage('Erro ao tentar consultar pedido!!!');
  end;

end;

end.
