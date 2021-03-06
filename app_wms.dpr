program app_wms;

uses
  Vcl.Forms,
  UfrmMain in 'UfrmMain.pas' {frmMain},
  UfrmCadastroProdutos in 'UfrmCadastroProdutos.pas' {frmCadastroProdutos},
  UfrmCadastroEndereco in 'UfrmCadastroEndereco.pas' {frmCadEndereco},
  UfrmArmazenagem in 'UfrmArmazenagem.pas' {frmArmazenagem},
  UfrmPesquisaEndereco in 'UfrmPesquisaEndereco.pas' {frmPesquisaEndereco},
  UfrmPesquisa in 'UfrmPesquisa.pas' {frmPesquisa},
  UfrmPedidoSaida in 'UfrmPedidoSaida.pas' {frmPedidoSaida},
  UfrmAdicionarItem2 in 'UfrmAdicionarItem2.pas' {frmAdicionarItem},
  UfrmSeparacaoPedido in 'UfrmSeparacaoPedido.pas' {frmSeparacaoPedido};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.
