unit UfrmAdicionarItem2;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Buttons, Vcl.StdCtrls,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf,
  FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async,
  FireDAC.Phys, FireDAC.VCLUI.Wait, Data.DB, FireDAC.Comp.Client,
  FireDAC.Phys.PG, FireDAC.Phys.PGDef;

type
  TfrmAdicionarItem = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    txtProduto: TEdit;
    txtQuantidadeItem: TEdit;
    GroupBox6: TGroupBox;
    btnClose: TSpeedButton;
    btnClear: TSpeedButton;
    btnOK: TSpeedButton;
    pgConnection: TFDConnection;
    lblDescricaoProd: TLabel;
    lblmsg: TLabel;
    procedure txtProdutoExit(Sender: TObject);
    procedure txtProdutoKeyPress(Sender: TObject; var Key: Char);
    procedure btnOKClick(Sender: TObject);
    procedure btnClearClick(Sender: TObject);
    procedure txtQuantidadeItemKeyPress(Sender: TObject; var Key: Char);
    procedure btnCloseClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
    //vars
    pgDataSource:TDataSource;
    pgQuery:TFDQuery;
    filtro:string;
    codigoProduto, codigoPedidoSaida:integer;
    descricaoproduto:string;

    //FUNCTION AND PROCEDURES
    function funcConsultaProduto(filtro:string):boolean;
    procedure saveData();
    procedure clearFields();
    procedure addItem();

  public
    { Public declarations }
  end;

var
  frmAdicionarItem: TfrmAdicionarItem;

implementation

{$R *.dfm}

uses UfrmPedidoSaida;

//*ADD ITEM
procedure TfrmAdicionarItem.addItem;
begin
  saveData();
  lblmsg.Caption := 'Utimo item adicionado '+#13+txtProduto.text+#13+descricaoproduto;
  clearFields();
end;

//*OK
procedure TfrmAdicionarItem.btnOKClick(Sender: TObject);
begin
    addItem();
end;

//*CLOSE
procedure TfrmAdicionarItem.btnCloseClick(Sender: TObject);
begin
  frmAdicionarItem.Close;
end;

//*CLEAR
procedure TfrmAdicionarItem.btnClearClick(Sender: TObject);
begin
  clearFields()
end;

//*CLEAR FIELDS
procedure TfrmAdicionarItem.clearFields;
begin
  txtProduto.Clear;
  txtProduto.Enabled := true;
  txtQuantidadeItem.Clear;
  lblDescricaoProd.Caption := '';
  txtProduto.SetFocus;
end;

//*FORM SHOW
procedure TfrmAdicionarItem.FormShow(Sender: TObject);
begin
   {
  if (frmPedidoSaida.flag = TRUE) then
    begin
      txtProduto.Text := frmPedidoSaida.skuItemPedido;
      txtProduto.Enabled := false;
      txtQuantidadeItem.Text := intToStr(frmPedidoSaida.quantidadeItem);
      codigoProduto := frmPedidoSaida.codigoItem;
    end;
    }
 end;

//*VERIFICA SE PRODUTO EST? CADASTRADO
function TfrmAdicionarItem.funcConsultaProduto(filtro: string): boolean;
begin
  pgQuery := TFDQuery.Create(self);
  pgDataSource := TDataSource.Create(self);

  pgQuery.Connection := pgConnection;
  pgDataSource.DataSet := pgQuery;

  try
    pgConnection.Open();
    pgQuery.sql.Add('SELECT DISTINCT codigo,sku,descricao FROM selectproduto(:filtro)');
    pgQuery.ParamByName('filtro').AsString := filtro;
    pgQuery.Open();
  except on E: Exception do
    begin
      ShowMessage('Erro ao carregar dados do banco');
      result := false;
      exit;
    end;
  end;

  //verifica se retornou algun registro no select
  codigoProduto := pgDataSource.DataSet.FieldByName('codigo').AsInteger;
  descricaoproduto := pgDataSource.DataSet.FieldByName('descricao').asString;
  //ShowMessage('codigo retornado ' + intToStr(codigoProduto));
  if codigoProduto <> 0 then
    begin
      result := true;
    end
  else
    begin
      result := false;
    end;




end;

//*SAVE DATA
procedure TfrmAdicionarItem.saveData;

var sql:string;

begin
  pgQuery := TFDQuery.Create(self);
  pgQuery.Connection := pgConnection;

  //recebe o codigo do pedido de saida
  codigoPedidoSaida := strToInt(frmPedidoSaida.txtCodigo.Text);

  sql := 'INSERT INTO pedidosaidadetalhe VALUES' +
  '(default,:codigoProduto,:quantidadeProduto,null,:codigoPedidoSaida)';
  pgQuery.SQL.Add(sql);
  pgQuery.ParamByName('codigoproduto').AsInteger := codigoProduto;
  pgQuery.ParamByName('quantidadeProduto').AsInteger :=strToInt(txtQuantidadeItem.Text);
  pgQuery.ParamByName('codigoPedidoSaida').AsInteger := codigoPedidoSaida;

    try
      pgConnection.Open();
      pgQuery.ExecSQL;
    except on E: EFDDBEngineException do
      begin
        case E.Kind of
         ekOther: ShowMessage('Erro ao Inserir  registro');
         ekUKViolated: ShowMessage('Esse produto j? consta no pedido.Exclua e insira novamente' ) ;
         ekServerOutput: ShowMessage('Erro na conex?o com banco de dados') ;
        end;
      end;
    end;
   frmPedidoSaida.loadPedidoItens(frmPedidoSaida.txtNumero.Text,'x');
   frmPedidoSaida.pgDataSourceItens.DataSet.Refresh;
   frmPedidoSaida.formatGridItens();
end;

//EVENTO EXIT DO TXTPRODUTO
procedure TfrmAdicionarItem.txtProdutoExit(Sender: TObject);
begin

  filtro := txtProduto.Text;

  //valida campo vazio
  if (filtro = '') then
    begin
       ShowMessage('Produto Inv?lido');
       txtProduto.SetFocus();
       exit;
    end;

  //valida retorna da fun??o
  if not (funcConsultaProduto(filtro)) then
    begin
      ShowMessage('Produto n?o encontrado e ou n?o cadastrado');
      txtProduto.SetFocus();
      exit;
    end;
  lblDescricaoProd.Caption := descricaoproduto;
  txtProduto.Enabled := false;
  txtQuantidadeItem.SetFocus();
end;

//EVENTO KEY PRESS - CAMPO PRODUTO
procedure TfrmAdicionarItem.txtProdutoKeyPress(Sender: TObject; var Key: Char);
begin
  begin
    If Key = #13 Then
      begin
        if (txtProduto.Focused) then
          txtQuantidadeItem.SetFocus;
          exit;
      end;
    end;
  end;

//EVENTO KEY PRESS - CAMPO QUANTIDADE ITEM
procedure TfrmAdicionarItem.txtQuantidadeItemKeyPress(Sender: TObject;
  var Key: Char);
begin
    If Key = #13 Then
      begin
        if (txtQuantidadeItem.Focused) then
        addItem();
        exit;
      end;
    end;

end.
