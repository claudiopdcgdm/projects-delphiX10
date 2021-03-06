unit UfrmSeparacaoPedido;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Data.DB, Vcl.Grids, Vcl.DBGrids;

type
  TfrmSeparacaoPedido = class(TForm)
    gridRelatorioSeparacao: TDBGrid;
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
    procedure formatGrid();

  public
    { Public declarations }
  end;

var
  frmSeparacaoPedido: TfrmSeparacaoPedido;

implementation

{$R *.dfm}

uses UfrmPedidoSaida;

procedure TfrmSeparacaoPedido.FormShow(Sender: TObject);
begin
  gridRelatorioSeparacao.DataSource := frmPedidoSaida.pgDataSourceExibeRel;
  formatGrid();
end;

//*FORMAT GRID ITENS
procedure TfrmSeparacaoPedido.formatGrid();

begin
  frmPedidoSaida.pgDataSourceExibeRel.DataSet.FieldByName('numeroseparacao').DisplayWidth:= 5;
  frmPedidoSaida.pgDataSourceExibeRel.DataSet.FieldByName('numero_pedido').DisplayWidth:= 5;
  frmPedidoSaida.pgDataSourceExibeRel.DataSet.FieldByName('destino').DisplayWidth:= 5;
  //frmPedidoSaida.pgDataSourceExibeRel.DataSet.FieldByName('datapedido').DisplayWidth:= ;
  frmPedidoSaida.pgDataSourceExibeRel.DataSet.FieldByName('prioridade').DisplayWidth:= 7;
  frmPedidoSaida.pgDataSourceExibeRel.DataSet.FieldByName('sku').DisplayWidth:= 15;
  frmPedidoSaida.pgDataSourceExibeRel.DataSet.FieldByName('descricao').DisplayWidth:= 20;
  frmPedidoSaida.pgDataSourceExibeRel.DataSet.FieldByName('tipobaixa').DisplayWidth:= 4;
  frmPedidoSaida.pgDataSourceExibeRel.DataSet.FieldByName('nome').DisplayWidth:= 10;
  frmPedidoSaida.pgDataSourceExibeRel.DataSet.FieldByName('endereco_coleta').DisplayWidth:= 13;
  frmPedidoSaida.pgDataSourceExibeRel.DataSet.FieldByName('quantidadesaida').DisplayWidth:= 2;

end;


end.
