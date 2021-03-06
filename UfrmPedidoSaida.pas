unit UfrmPedidoSaida;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Data.DB, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf,
  FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys,
  FireDAC.Phys.PG, FireDAC.Phys.PGDef, FireDAC.VCLUI.Wait, Vcl.StdCtrls,
  FireDAC.Comp.Client, Vcl.WinXCalendars, Vcl.Grids, Vcl.DBGrids, Vcl.Buttons,
  Vcl.ComCtrls, System.Actions, Vcl.ActnList;

type
  TfrmPedidoSaida = class(TForm)
    gridPedidoSaida: TDBGrid;
    Label1: TLabel;
    Label2: TLabel;
    btnCancelar: TSpeedButton;
    btnEditar: TSpeedButton;
    btnExcluir: TSpeedButton;
    btnSave: TSpeedButton;
    btnNovo: TSpeedButton;
    Label5: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Label10: TLabel;
    Label3: TLabel;
    cboPrioridade: TComboBox;
    cboDestino: TComboBox;
    GroupBox1: TGroupBox;
    btnPesquisa: TSpeedButton;
    cboStatus: TComboBox;
    PageControl: TPageControl;
    tabPedidosCabecalho: TTabSheet;
    tabPedidoItens: TTabSheet;
    pickerDataPedido: TCalendarPicker;
    txtCodigo: TEdit;
    txtDescPedido: TEdit;
    txtNumero: TEdit;
    txtPesquisa: TEdit;
    pgConnection: TFDConnection;
    gridItensPedidos: TDBGrid;
    btnAdd: TSpeedButton;
    btnRemove: TSpeedButton;
    btnFinaliza: TSpeedButton;
    GroupBox2: TGroupBox;
    btnPesquisaItemPedido: TSpeedButton;
    txtPesquisaItemPedido: TEdit;
    GroupBox3: TGroupBox;
    GroupBox4: TGroupBox;
    GroupBox5: TGroupBox;
    btnGerarSeparacao: TButton;
    GroupBox6: TGroupBox;
    procedure FormShow(Sender: TObject);
    procedure btnPesquisaClick(Sender: TObject);
    procedure btnNovoClick(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
    procedure btnEditarClick(Sender: TObject);
    procedure gridPedidoSaidaCellClick(Column: TColumn);
    procedure btnExcluirClick(Sender: TObject);
    procedure btnCancelarClick(Sender: TObject);
    procedure gridPedidoSaidaDblClick(Sender: TObject);
    procedure PageControlChange(Sender: TObject);
    procedure btnAddClick(Sender: TObject);
    procedure btnRemoveClick(Sender: TObject);
    procedure gridItensPedidosCellClick(Column: TColumn);
    procedure btnFinalizaClick(Sender: TObject);
    procedure btnPesquisaItemPedidoClick(Sender: TObject);
    procedure btnGerarSeparacaoClick(Sender: TObject);



  private
    //VAR
    pgQuery:TFDQuery;
    pgQueryItens:TFDQuery;
    pgDataSource:TDataSource;
    pgStoreProc:TFDStoredProc;
    pgDataSetConsultaSaldo:TDataSet;
    pgStoreProcItens :TFDStoredProc;



    //PROCEDURE
    procedure formatGrid();
    procedure saveDatas(action:integer);
    procedure enableDisableControls(active:boolean);
    procedure clearFields();
    procedure loadDados(filtro:string);
    procedure consultaSaldo(codigoproduto:integer;tipobaixa:string);
    
    procedure execInsertIntoSeparacao(codigopedido:integer;codigoproduto:integer;
    codigoendereco:integer;quantidadesaida, codigoprodutoendereco:integer);


    //FUNCTION
    function funcValidaCampos():boolean;
    function delete():boolean;
    function removeItem(codigoItem:integer):string;
    function geraRelatorioEmTela(numeropedido:string):boolean;
    function geraSeparacao(numeropedido:string):boolean;


  public
    { Public declarations }
    procedure loadPedidoItens(filtro1:string;filtro2:string);
    procedure formatGridItens();
    var codigoItem, quantidadeItem:integer;
    var skuItemPedido:string;
    pgDataSourceItens: TDataSource;
    pgDataSourceExibeRel:TDataSource;

  end;

var
  frmPedidoSaida: TfrmPedidoSaida;

implementation

{$R *.dfm}

uses UfrmAdicionarItem2, UfrmSeparacaoPedido;

//*ADD ITEM
procedure TfrmPedidoSaida.btnAddClick(Sender: TObject);
begin
  //flag := false;
  Application.CreateForm(TfrmAdicionarItem, frmAdicionarItem);
  frmAdicionarItem.ShowModal;
end;

//*CANCELA OPERACAO
procedure TfrmPedidoSaida.btnCancelarClick(Sender: TObject);
begin
  enableDisableControls(false);
  clearFields();
  btnEditar.Enabled := false;
  btnExcluir.Enabled := false;
end;

//*CLOSE
procedure TfrmPedidoSaida.btnFinalizaClick(Sender: TObject);
begin
  ShowMessage('Adi??o conclu?da. Clique em Gerar Separa??o. ');
  PageControl.ActivePage := tabPedidosCabecalho;
  btnGerarSeparacao.SetFocus();
end;

//*SEPARA??O PEDIDO SAIDA
procedure TfrmPedidoSaida.btnGerarSeparacaoClick(Sender: TObject);
begin

  //verificar se tem pedido selecionado
  if (txtNumero.Text = EmptyStr) then
    begin
      ShowMessage('Selecione um pedido');
      exit;
    end;

  //verifica se status do pedido ? pedente
  if cboStatus.Text[1] <> 'P' then
    begin
      ShowMessage('Pedido n?o consta como PENDENTE!');
      exit;
    end;

  //chama fun??o para que gera a separa??o passando o numero do pedido
  if not(geraSeparacao(txtNumero.Text)) then
    begin
      ShowMessage('Pedido selecionado n?o possui itens');
    end
  else
    begin
      if geraRelatorioEmTela(txtNumero.Text) then
        begin
          Application.CreateForm(TfrmSeparacaoPedido, frmSeparacaoPedido);
          frmSeparacaoPedido.ShowModal();
          frmPedidoSaida.Close;
          exit;
        end
      else
        begin
          ShowMessage('Sem dados para exibir gerar relatorio!!!');
        end;
    
      end;
end;

//*EDITAR HEADER
procedure TfrmPedidoSaida.btnEditarClick(Sender: TObject);
begin
  enableDisableControls(true);
  btnEditar.Enabled := false;
  btnExcluir.Enabled := false;
  cboDestino.Enabled := false;
  txtNumero.Enabled := false;
end;

//*EXCLUIR
procedure TfrmPedidoSaida.btnExcluirClick(Sender: TObject);
begin
  if (cboStatus.Text[1] ='P' ) or (cboStatus.Text[2]= 'a')then
    begin
      if (delete) then
        begin
          ShowMessage('Pedido excluido com sucesso');
          exit;
        end;
      ShowMessage('Falha ao tentar excluir registro');
    end
  else
    begin
      ShowMessage('Pedido na situacao '+ cboStatus.Text + ' . N?o pode ser Excluido');
      exit;
    end;
  enableDisableControls(false);
  btnExcluir.Enabled := false;
  btnEditar.Enabled := false;

end;

//*NOVO
procedure TfrmPedidoSaida.btnNovoClick(Sender: TObject);
begin
   enableDisableControls(true);
   clearFields();
   cboPrioridade.ItemIndex := 0;
   cboStatus.ItemIndex := 0;
   cboStatus.Enabled := false;
   btnEditar.Enabled := false;
   btnExcluir.Enabled := false;
end;

//*PESQUISA
procedure TfrmPedidoSaida.btnPesquisaClick(Sender: TObject);
begin
  if txtPesquisa.Text <> EmptyStr then
    begin
      loadDados(txtPesquisa.text);
    end
  else
    begin
      loadDados('x');
    end;
  formatGrid();
end;

//*PESQUISA ITEM PEDIDO
procedure TfrmPedidoSaida.btnPesquisaItemPedidoClick(Sender: TObject);
begin
  if txtPesquisaItemPedido.Text=EmptyStr then
    begin
      loadPedidoItens(txtNumero.Text,'x');
    end
  else
    begin
      loadPedidoItens(txtNumero.Text,txtPesquisaItemPedido.Text);
    end;
  pgDataSourceItens.DataSet.Refresh;
  formatGridItens();

end;

//*REMOVE
procedure TfrmPedidoSaida.btnRemoveClick(Sender: TObject);
begin
  if (codigoItem = 0) then
    begin
      ShowMessage('Selecione um tem para remover');
      exit;
    end;

  if (removeItem(codigoItem) = EmptyStr) then
    begin
      ShowMessage('Erro ao remover item do pedido');
      exit;
    end
  else
    begin
      ShowMessage('item: ' + skuItemPedido + ' removido com sucesso');
    end;



end;

//*SALVAR HEADER
procedure TfrmPedidoSaida.btnSaveClick(Sender: TObject);

var resultDlg:integer;

begin

  case funcValidaCampos of
    true:
      begin
          if txtCodigo.Text = EmptyStr then
            begin
              SaveDatas(1);
            end
           else
              begin
                //VERIFICA SE STATUS ESTA SENDO ALTERADO PARA CANCELADO
                if cboStatus.ItemIndex = 3 then
                  begin
                    resultDlg := MessageDlg('Deseja realmente alterar status para cancelado?',
                                  mtConfirmation,[mbYes,mbNo],1);
                    if resultDlg = 6 then
                       saveDatas(2);
                       clearFields();
                       enableDisableControls(false);
                       exit;
                  end;
              savedatas(2);
              end;
      clearFields();
      enableDisableControls(false);
      end;
    false:
      begin
         ShowMessage('Campos s?o obrigat?rios');
      end;
  end;

  
   
end;

//*FORMAT GRID PEDIDO HEADER
procedure TfrmPedidoSaida.formatGrid;

begin
  pgDataSource.DataSet.FieldByName('numero').DisplayWidth := 10;
  pgDataSource.DataSet.FieldByName('descricao').DisplayWidth := 15;
  pgDataSource.DataSet.FieldByName('status').DisplayWidth := 10;
  pgDataSource.DataSet.FieldByName('destino').DisplayWidth := 10;
  pgDataSource.DataSet.FieldByName('prioridade').DisplayWidth := 10;

end;

//*FORMAT GRID ITENS
procedure TfrmPedidoSaida.formatGridItens;

begin
  pgDataSourceItens.DataSet.FieldByName('numeropedido').DisplayWidth:= 7;
  pgDataSourceItens.DataSet.FieldByName('quantidadeitem').DisplayWidth:= 5;
  pgDataSourceItens.DataSet.FieldByName('sku').DisplayWidth:= 15;
  pgDataSourceItens.DataSet.FieldByName('descricaoproduto').DisplayWidth:= 30;
  pgDataSourceItens.DataSet.FieldByName('tipobaixa').DisplayWidth:= 4;
  pgDataSourceItens.DataSet.FieldByName('nomeendereco').Visible:= false;
  pgDataSourceItens.DataSet.FieldByName('etiquetaendereco').Visible:= false;
  pgDataSourceItens.DataSet.FieldByName('codigoproduto').Visible:= false;
  pgDataSourceItens.DataSet.FieldByName('codigoendereco').Visible:= false;
  pgDataSourceItens.DataSet.FieldByName('codigopedidoitem').Visible:= false;
  pgDataSourceItens.DataSet.FieldByName('codigopedido').Visible:= false;
  
end;

//*SHOW FORM HEADER
procedure TfrmPedidoSaida.FormShow(Sender: TObject);
begin
 codigoItem := 0;
 loadDados('x');
 PageControl.ActivePage := tabPedidosCabecalho;
 formatGrid();
end;

//*LOAD PEDIDOS HEADER
procedure TfrmPedidoSaida.loadDados(filtro:string);

begin
  
  pgQuery := TFDQuery.Create(self);
  pgDataSource := TDataSource.Create(self);

  pgQuery.Connection := pgConnection;
  pgDataSource.DataSet := pgQuery;
  gridPedidoSaida.DataSource := pgDataSource;


  pgQuery.sql.Add ('SELECT * FROM selectpedidosaida(:filtro)');
  pgQuery.ParamByName('filtro').asString := filtro;

  try
     pgConnection.Open();
     pgQuery.Open();
  except on E: EFDDBEngineException do
    begin
      case E.Kind of
        ekOther: ShowMessage('Erro ao carregar registros no banco');
        ekServerOutput:ShowMessage('Erro de conex?o com banco de dados');
      end;
    end;
  end;
  pgDataSource.DataSet.Refresh;
end;

//*LOAD ITENS PEDIDO
procedure TfrmPedidoSaida.loadPedidoItens(filtro1: string;filtro2:string);
begin

  pgQueryItens := TFDQuery.Create(self);
  pgDataSourceItens := TDataSource.Create(self);

  pgQueryItens.Connection := pgConnection;
  pgDataSourceItens.DataSet := pgQueryItens;
  gridItensPedidos.DataSource := pgDataSourceItens;

  pgQueryItens.sql.Add ('SELECT * FROM selectpedidosaidadetalhe2(:filtro1,:filtro2)');
  pgQueryItens.ParamByName('filtro1').AsString := filtro1;
  pgQueryItens.ParamByName('filtro2').AsString := filtro2;

  try
     pgConnection.Open();
     pgQueryItens.Open();
  except on E: EFDDBEngineException do
    begin
      case E.Kind of
        ekOther: ShowMessage('Erro ao carregar registros no banco');
        ekServerOutput:ShowMessage('Erro de conex?o com banco de dados');
      end;
    end;
  end;
end;

//*ON CHANGE
procedure TfrmPedidoSaida.PageControlChange(Sender: TObject);
begin
  if (txtNumero.Text = EmptyStr) and (PageControl.ActivePage = tabPedidoItens)
  then
    begin
      ShowMessage('Selecione um pedido para visualizar seus itens');
      PageControl.ActivePage := tabPedidosCabecalho;
      exit;
    end;
  loadPedidoItens(txtNumero.Text,'x');
  pgDataSourceItens.DataSet.Refresh;
  formatGridItens();
end;

//*REMOVE ITEM DO PEDIDO
function TfrmPedidoSaida.removeItem(codigoItem: integer): string;

var sql:String;

begin
  pgQueryItens := TFDQuery.Create(self);
  pgQueryItens.Connection := pgConnection;
  sql := 'DELETE FROM pedidosaidadetalhe WHERE "CODIGO"=:codigoItem';
  pgQueryItens.SQL.Add(sql);
  pgQueryItens.ParamByName('codigoItem').AsInteger := codigoItem;

  try
    pgConnection.Open();
    pgQueryItens.ExecSQL;
    result := skuItemPedido;
  except on E: EFDDBEngineException do
    begin
      case E.Kind of
        ekOther: ShowMessage('Erro ao remover item');
        ekServerOutput:ShowMessage('Erro de conex?o com banco de dados');
      end;
      result:= EmptyStr;
      exit;
    end;
  end;
  pgDataSourceItens.DataSet.Refresh;
  result := skuItemPedido;

end;

//*SAVE DATAS
procedure TfrmPedidoSaida.saveDatas(action:integer);
begin
  case (action) of
    1: //*INSERT
      begin
        pgStoreProc := TFDStoredProc.Create(self);
        pgStoreProc.Connection := pgConnection;

        pgStoreProc.StoredProcName := 'insertpedidosaida';
        pgStoreProc.Prepare;
        pgStoreProc.Params[0].Value:= txtNumero.Text;
        pgStoreProc.Params[1].Value:= txtDescPedido.Text;
        pgStoreProc.Params[2].Value:= pickerDataPedido.date;
        pgStoreProc.Params[3].Value:= cboDestino.text;
        pgStoreProc.Params[4].Value:= cboStatus.Text;
        pgStoreProc.Params[5].Value:= cboPrioridade.Text;

        try
           pgConnection.Open();
           pgStoreProc.ExecProc;
           ShowMessage('Pedido cadastrado com sucesso');
        except on E: EFDDBEngineException do
          begin
            case E.Kind of
              ekOther: ShowMessage('Erro ao carregar registros no banco');
              ekUKViolated: ShowMessage('Pedido j? cadastrado');
              ekServerOutput:ShowMessage('Erro de conex?o com banco de dados');
            end;
          end;
        end;
        pgDataSource.DataSet.Refresh;
      end;//end case 1


    2: //*UPDATE
      begin
        pgStoreProc := TFDStoredProc.Create(self);
        pgStoreProc.Connection := pgConnection;

        pgStoreProc.StoredProcName := 'updatepedidosaida';
        pgStoreProc.Prepare;
        pgStoreProc.Params[0].Value:= txtNumero.Text;
        pgStoreProc.Params[1].Value:= txtDescPedido.Text;
        pgStoreProc.Params[2].Value:= pickerDataPedido.date;
        pgStoreProc.Params[3].Value:= cboDestino.Text;
        pgStoreProc.Params[4].Value:= cboStatus.Text;
        pgStoreProc.Params[5].Value:= cboPrioridade.Text;
        pgStoreProc.Params[6].Value:= txtCodigo.Text;

        try
           pgConnection.Open();
           pgStoreProc.ExecProc;
           ShowMessage('Pedido atualizado com sucesso');
        except on E: EFDDBEngineException do
          begin
            case E.Kind of
              ekOther: ShowMessage('Erro ao atualizar registros no banco');
//            ekUKViolated: ShowMessage('Pedido j? cadastrado');
              ekServerOutput:ShowMessage('Erro de conex?o com banco de dados');
            end;
          end;
        end;
        pgDataSource.DataSet.Refresh;
      end;//end case 2
  end;
end;

//*ENABLEDESABLECONTROLS
procedure TfrmPedidoSaida.enableDisableControls(active:boolean);
begin
  //txtCodigo.Enabled := not active;
  txtNumero.Enabled := active;
  txtDescPedido.Enabled := active;
  cboDestino.Enabled := active;
  cboPrioridade.Enabled := active;
  cboStatus.Enabled := active;
  pickerDataPedido.Enabled := active;

  btnNovo.Enabled := not active;
  btnCancelar.Enabled := active;
  btnSave.Enabled := active;
end;

//*EXECINSERTINTOSEPARACAO
procedure TfrmPedidoSaida.execInsertIntoSeparacao(codigopedido, codigoproduto,
  codigoendereco, quantidadesaida,codigoprodutoendereco: integer);

  var pgStoreProcSep:TFDStoredProc;
  
begin
  pgStoreProcSep := TFDStoredProc.Create(self);
  pgStoreProcSep.Connection := pgConnection;

  pgStoreProcSep.StoredProcName := 'insertseparacao';
  pgStoreProcSep.Prepare;
  pgStoreProcSep.Params[0].Value := codigopedido;
  pgStoreProcSep.Params[1].Value := codigoproduto;
  pgStoreProcSep.Params[2].Value := codigoendereco;
  pgStoreProcSep.Params[3].Value := quantidadesaida;
  pgStoreProcSep.Params[4].Value := codigoprodutoendereco;
  try
    pgConnection.Open();
    pgStoreProcSep.ExecProc;
  except on E: Exception do
    ShowMessage('Erro na inser??o da separa??o!!!');
  end;
end;

//*CLEARFIELDS
procedure TfrmPedidoSaida.clearFields();
begin
  txtCodigo.Text := '';
  txtDescPedido.Text := '';
  txtNumero.Text := '';
  cboPrioridade.ItemIndex := -1;
  cboDestino.ItemIndex := -1;
  cboStatus.ItemIndex := -1;
  pickerDataPedido.Date := date;
end;

//*CONSULTA SALDO
procedure TfrmPedidoSaida.consultaSaldo(codigoproduto: integer; tipobaixa:string);

var sql:string;

begin

  pgQuery := TFDQuery.Create(self);
  pgDataSetConsultaSaldo := TDataSet.Create(self);

  pgQuery.Connection := pgConnection;
  pgDataSetConsultaSaldo := pgQuery;

  if tipobaixa='FIFO' then
    begin
       sql := 'SELECT * FROM produtoendereco WHERE "codigoProduto"= :codigoproduto'+
       ' AND "saldo" > 0 ORDER BY "dataentrada" ASC';
    end
  else
    if tipobaixa = 'LIFO' then
      begin
         sql := 'SELECT * FROM produtoendereco WHERE "codigoProduto" = :codigoproduto'+
         ' AND "saldo" > 0 ORDER BY "dataentrada" DESC';
      end
  else
    if tipobaixa = 'FEFO' then
      begin
        sql := 'SELECT * FROM produtoendereco WHERE "codigoProduto" = :codigoproduto'+
         ' AND "saldo" > 0 ORDER BY "datavencimento" ASC';
      end;

  //showmessage(sql);

  //passagens de parametros para sql
  pgQuery.SQL.Add(sql);
  pgQuery.ParamByName('codigoproduto').AsInteger := codigoproduto;

  try
    pgConnection.Open();
    pgQuery.Open();
  except on E: Exception do
    ShowMessage('erro na consulta de saldo');
  end;

  pgDataSetConsultaSaldo.Refresh;

end;

//*DELETE PEDIDO SAIDA HEADER
function TfrmPedidoSaida.delete: boolean;
begin

    //cria o componente TFDquery
    pgQuery:= TFDQuery.Create(self);
    pgQuery.Connection := pgConnection;
    pgQuery.SQL.Add('DELETE FROM pedidosaida WHERE "CODIGO" = :codigo');
    pgQuery.ParamByName('codigo').AsInteger := strToInt(txtCodigo.Text);
    try
        pgConnection.open;
        pgQuery.ExecSQL;
    except on E: EFDDBEngineException do
      begin
        case E.Kind of
          ekOther: ShowMessage('Erro ao excluir  registro');
          ekRecordLocked:ShowMessage('Registro em uso por outro processo. LOCK');
          ekFKViolated:ShowMessage('Existe itens vinculados ao pedido. Impossivel excluir ') ;
          ekServerOutput: ShowMessage('Erro na conex?o com banco de dados');
       end;
        result := false;
      end;
     end;
    pgDataSource.DataSet.Refresh;
    result := true;
    

end;

//*VALIDAR CAMPOS VAZIO
function TfrmPedidoSaida.funcValidaCampos():boolean;
begin

   //atribui??es de valores
    if (txtDescPedido.Text = '') or (txtNumero.Text = '')
    or (cboPrioridade.Text = 'Selecione...' ) or (cboDestino.text = 'Selecione...')
    or (cboStatus.text = 'Selecione...')
    then
      begin
        result := false;
      end
    else
      begin
        result := true;
      end;
end;

//*GERA RELATORIO EM TELA
function TfrmPedidoSaida.geraRelatorioEmTela(numeropedido:string):boolean;
var pgQueryGeraRel:TFDQuery; 
begin
  pgQueryGeraRel := TFDQuery.Create(self);
  pgDataSourceExibeRel := TDataSource.Create(self);
  
  pgQueryGeraRel.Connection := pgConnection;
  pgDataSourceExibeRel.DataSet := pgQueryGeraRel;

  pgQueryGeraRel.sql.Add('SELECT * FROM selectRelSeparacao(:numeropedido)');
  pgQueryGeraRel.ParamByName('numeropedido').asString := numeropedido;

  try
    pgConnection.Open();
    pgQueryGeraRel.Open;

  except on E: EFDDBEngineException do
    begin
        case E.Kind of
         ekOther: ShowMessage('Erro ao gerar relatorio');
         //ekUKViolated: ShowMessage('Esse produto j? consta no pedido.Exclua e insira novamente' ) ;
         ekServerOutput: ShowMessage('Erro na conex?o com banco de dados') ;
        end;
     result:=false;
    end;
  end;

  if pgDataSourceExibeRel.DataSet.RecordCount <> 0 then
     result:=true
  else
    result := false;
  
end;

//*GERA SEPARACAO
function TfrmPedidoSaida.geraSeparacao(numeropedido:string):boolean;

var codigoproduto,saldo,quantidadesolicitada,codigoendereco,codigopedido:integer;
var quantidadesaida,codigoprodutoendereco:integer;
var dataSetItensPedido:TDataSet;
var tipobaixa,skuproduto:String;
                                   
begin

  //executa procedure que carrega os dados num dataset
  loadPedidoItens(numeropedido, 'x');

  //recebe o dataset carregado na procedure loaditenspedidos
  dataSetItensPedido := pgDataSourceItens.DataSet;

  //verifica se pedido selecionado possui itens
  if dataSetItensPedido.RecordCount = 0 then
    begin
      result:= false;
      exit;
    end;

  //posiciona cursor no primeiro registro
  dataSetItensPedido.First;

  //percorre o dataset pegando os campos
  while not dataSetItensPedido.Eof do
    begin
        codigoproduto := dataSetItensPedido.FieldByName('codigoproduto').AsInteger;
        tipobaixa := dataSetItensPedido.FieldByName('tipobaixa').AsString;
        quantidadesolicitada := dataSetItensPedido.FieldByName('quantidadeitem').asInteger;
        codigopedido := dataSetItensPedido.FieldByName('codigopedido').AsInteger;
        skuproduto := dataSetItensPedido.FieldByName('sku').AsString; 

        //chama procedure para consultar os enderecos pelo codigoproduto e
        //o data set pgDataSetConsultaSaldo
        consultaSaldo(codigoproduto,tipobaixa);

        if pgDataSetConsultaSaldo.RecordCount <> 0 then 
          begin
            //Percorre o dataset que salvou os resultado da procedure consulta saldo        
            pgDataSetConsultaSaldo.First;
             while not pgDataSetConsultaSaldo.Eof do
              begin
                saldo := pgDataSetConsultaSaldo.FieldByName('saldo').asInteger;
                codigoendereco := pgDataSetConsultaSaldo.FieldByName('codigoEndereco').asInteger;
                codigoprodutoendereco := pgDataSetConsultaSaldo.FieldByName('codigo').AsInteger;

                //qtd=11 , saldo=33
                if quantidadesolicitada > saldo then
                  begin
                    quantidadesolicitada := quantidadesolicitada - saldo;
                    quantidadesaida := saldo;
                  end
                else
                  if quantidadesolicitada < saldo then
                    begin
                      saldo := saldo - quantidadesolicitada;
                      quantidadesaida := quantidadesolicitada;
                    end
                  else
                    begin
                      quantidadesaida := quantidadesolicitada;
                    end;

                execInsertIntoSeparacao(codigopedido,codigoproduto,
                codigoendereco,quantidadesaida,codigoprodutoendereco);

                pgDataSetConsultaSaldo.Next;
              end;
            end //fecha o if
          else
            begin
              ShowMessage('Produto: '+skuproduto+' n?o armazenado. N?o ser? gerado');
            end;
         dataSetItensPedido.Next;
    end;//fecha o primeiro while

  result:=true;
end;

//*CELL CLICK  GRIDITENSPEDIDOS
procedure TfrmPedidoSaida.gridItensPedidosCellClick(Column: TColumn);
begin
     codigoItem := pgDataSourceItens.DataSet.FieldByName('codigopedidoitem').AsInteger;
     skuItemPedido := pgDataSourceItens.DataSet.FieldByName('sku').AsString;
     quantidadeItem := pgDataSourceItens.DataSet.FieldByName('quantidadeitem').AsInteger;
end;

//*CELL CLICK  GRIDPEDIDOSAIDA HEADER
procedure TfrmPedidoSaida.gridPedidoSaidaCellClick(Column: TColumn);
begin
  if pgDataSource.DataSet.RecordCount <> 0 then
    begin
      txtCodigo.Text := pgDataSource.DataSet.FieldByName('codigo').AsString;
      txtNumero.Text := pgDataSource.DataSet.FieldByName('numero').AsString;
      pickerDataPedido.Date := pgDataSource.DataSet.FieldByName('datapedido').asDateTime;
      txtDescPedido.Text := pgDataSource.DataSet.FieldByName('descricao').AsString;
      cboPrioridade.Text := pgDataSource.DataSet.FieldByName('prioridade').AsString;
      cboDestino.Text := pgDataSource.DataSet.FieldByName('destino').AsString;
      cboStatus.Text := pgDataSource.DataSet.FieldByName('status').AsString;

      btnEditar.Enabled := true;
      btnExcluir.Enabled := true;
      btnCancelar.Enabled := true;



    end;
end;

//*CELL DOUBLE CLICK HEADER
procedure TfrmPedidoSaida.gridPedidoSaidaDblClick(Sender: TObject);

begin
  PageControl.ActivePage := tabPedidoItens;
  loadPedidoItens(txtNumero.Text,'x');
  pgDataSourceItens.DataSet.Refresh;
  formatGridItens();
end;

end.
