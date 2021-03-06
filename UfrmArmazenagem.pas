unit UfrmArmazenagem;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.Phys.PG,
  FireDAC.Phys.PGDef, FireDAC.VCLUI.Wait, FireDAC.Stan.Param, FireDAC.DatS,
  FireDAC.DApt.Intf, FireDAC.DApt, Data.DB, Vcl.Buttons, Vcl.ComCtrls,
  Vcl.StdCtrls, Vcl.Grids, Vcl.DBGrids, FireDAC.Comp.DataSet,
  FireDAC.Comp.Client, Vcl.WinXCalendars, System.UITypes;

type
  TfrmArmazenagem = class(TForm)
    pgConnection: TFDConnection;
    dbGridArmazenagem: TDBGrid;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label6: TLabel;
    txtCodigo: TEdit;
    txtProduto: TEdit;
    btnPesquisarProduto: TButton;
    Label7: TLabel;
    txtEndereco: TEdit;
    btnPesquisarEnde: TButton;
    txtQuantidade: TEdit;
    btnCancelar: TSpeedButton;
    btnEditar: TSpeedButton;
    btnExcluir: TSpeedButton;
    btnSave: TSpeedButton;
    btnNovo: TSpeedButton;
    Label4: TLabel;
    pickerDataEntrada: TCalendarPicker;
    pickerDataVencimento: TCalendarPicker;
    txtDescProduto: TEdit;
    txtEtiqueta: TEdit;
    GroupBox1: TGroupBox;
    btnPesquisa: TSpeedButton;
    txtPesquisa: TEdit;
    procedure FormShow(Sender: TObject);
    procedure btnNovoClick(Sender: TObject);
    procedure btnCancelarClick(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
    procedure btnEditarClick(Sender: TObject);
    procedure dbGridArmazenagemCellClick(Column: TColumn);
    procedure btnExcluirClick(Sender: TObject);
    procedure btnPesquisarProdutoClick(Sender: TObject);
    procedure btnPesquisarEndeClick(Sender: TObject);
    procedure btnPesquisaClick(Sender: TObject);
  private
    { Private declarations }

    pgQuery:TFDQuery;
    pgDataSource: TDataSource;
    pgStoreProc: TFDStoredProc;

    //VARS
    var quantidadeSaida:integer;

    //functions
    function  funcValidaCampos():boolean;

    //procedures
    procedure saveDatas(action:integer);
    procedure enableDesableControls(status:boolean);
    procedure clearFields();
    procedure formatDbGrid(grid:TDataSource);
    procedure delete();
    procedure loadDados(filtro:string);



  public
    { Public declarations }
    codigoEndereco, codigoProduto,saldo:integer;
    sku,descricaoProduto,nomeEndereco,etiquetaEndereco:string;

  end;

var
  frmArmazenagem: TfrmArmazenagem;

implementation

{$R *.dfm}

uses UfrmPesquisa, UfrmPesquisaEndereco;

//*CANCELAR
procedure TfrmArmazenagem.btnCancelarClick(Sender: TObject);
begin
  enableDesableControls(false);
  clearFields();
  btnEditar.Enabled := false;
  btnExcluir.Enabled := false;
end;

//*EDITAR
procedure TfrmArmazenagem.btnEditarClick(Sender: TObject);
begin
  if (quantidadeSaida = 0) then
    begin
      enableDesableControls(true);
      btnEditar.Enabled := false;
      btnExcluir.Enabled := false;
    end
  else
    begin
      ShowMessage('Endere?o possui saldo movimentado, opera??o n?o pode ser efetuada por essa tela');
    end;

end;

//*EXLCUIR
procedure TfrmArmazenagem.btnExcluirClick(Sender: TObject);
begin
  delete();
end;

//*NOVO
procedure TfrmArmazenagem.btnNovoClick(Sender: TObject);
begin
  enableDesableControls(true);
  btnEditar.Enabled := false;
  btnExcluir.Enabled := false;
  clearFields();
  txtQuantidade.SetFocus();
end;

//*PESQUISA CLICK
procedure TfrmArmazenagem.btnPesquisaClick(Sender: TObject);
begin
  if txtPesquisa.Text = EmptyStr then
      begin
        loadDados('x'); //carrega os 500 primeiros
      end
    else
      begin
        loadDados(txtPesquisa.Text);
      end;
    formatDbGrid(pgDataSource);
    pgDataSource.DataSet.Refresh;
  end;

//*PESQUISAR ENDERECO
procedure TfrmArmazenagem.btnPesquisarEndeClick(Sender: TObject);
begin
  //try
    frmPesquisaEndereco := TfrmPesquisaEndereco.Create(self);
    frmPesquisaEndereco.ShowModal();
  //finally
    //FreeAndNil(frmPesquisaEndereco);
  //end;
    txtEndereco.Text := nomeEndereco;
    txtEtiqueta.Text := etiquetaEndereco;
end;

//*PESQUISAR PRODUTO
procedure TfrmArmazenagem.btnPesquisarProdutoClick(Sender: TObject);
begin
  //try
//    Application.CreateForm(TfrmPesquisa, frmPesquisa);
    frmPesquisa := TfrmPesquisa.Create(self);
    frmPesquisa.ShowModal();
  //finally
    //FreeAndNil(frmPesquisa);
  //end;
    txtProduto.Text := sku;
    txtDescProduto.Text := descricaoProduto;
end;

//*SALVAR
procedure TfrmArmazenagem.btnSaveClick(Sender: TObject);
begin
  if not (funcValidaCampos) then
    begin
      ShowMessage('Campos Obrigatorios, verifique!');
      exit;
    end
  else
    begin
        if (txtCodigo.Text = EmptyStr) then
          begin
          //executa o insert
          saveDatas(1);
          enableDesableControls(false);
          clearFields();
          end
        else
          begin
            //executa o update
            saveDatas(2);
            enableDesableControls(false);
            clearFields();

          end;

    end;
end;

//*LIMPA CAMPOS
procedure TfrmArmazenagem.clearFields;
begin
  txtProduto.Text := EmptyStr;
  txtCodigo.Text := EmptyStr;
  txtEndereco.Text := EmptyStr;
  txtQuantidade.Text := EmptyStr;
  pickerDataEntrada.Date := date;
  pickerDataVencimento.Date := date;
  txtDescProduto.Text := EmptyStr;
  txtEtiqueta.Text := EmptyStr;

end;

//*CELL CLICK
procedure TfrmArmazenagem.dbGridArmazenagemCellClick(Column: TColumn);
begin
  if pgDataSource.DataSet.RecordCount <> 0 then
    begin

      txtCodigo.Text :=  pgDataSource.DataSet.FieldByName('codigo').AsString;
      txtQuantidade.Text := pgDataSource.DataSet.FieldByName('Quantidade_Entrada').AsString;
      txtProduto.Text := pgDataSource.DataSet.FieldByName('sku').AsString;
      txtDescProduto.Text := pgDataSource.DataSet.FieldByName('descricao').AsString;
      txtEndereco.Text := pgDataSource.DataSet.FieldByName('nome_endereco').AsString;
      txtEtiqueta.Text := pgDataSource.DataSet.FieldByName('etiqueta').AsString;
      pickerDataEntrada.Date := pgDataSource.DataSet.FieldByName('dataentrada').AsDateTime;
      pickerDataVencimento.Date := pgDataSource.DataSet.FieldByName('datavencimento').AsDateTime;


      codigoEndereco := pgDataSource.DataSet.FieldByName('endereco').AsInteger;
      etiquetaEndereco := pgDataSource.DataSet.FieldByName('etiqueta').AsString;
      codigoProduto := pgDataSource.DataSet.FieldByName('produto').AsInteger;
      descricaoProduto := pgDataSource.DataSet.FieldByName('descricao').AsString;
      saldo := pgDataSource.DataSet.FieldByName('saldo').AsInteger;
      quantidadeSaida := pgDataSource.DataSet.FieldByName('quantidade_saida').AsInteger;


      //habitar bot?es
      btnEditar.Enabled := true;
      btnExcluir.Enabled := true;
      btnCancelar.Enabled := true;
    end;


end;

//*DELETE
procedure TfrmArmazenagem.delete;
var confirm:integer;
begin


   confirm := MessageDlg('Deja realmente exlcuir o registro?',
              mtConfirmation,[mbYes,mbNo],1);

  //6=mbYes,7=mbNo
  if confirm = 6 then
    begin

      //criacao dos objetos (instancias)
      pgQuery := TFDQuery.Create(self);

      //configura??es
      pgQuery.Connection := pgConnection;

      if quantidadeSaida = 0 then
        begin
          //parametros da exclus?o
          with pgQuery do
          begin
            SQL.Clear();
            SQL.Add('DELETE FROM produtoendereco WHERE codigo = :codigo');
            ParamByName('codigo').AsInteger := strToInt(txtCodigo.Text);

            try
              pgConnection.Open(); //abre a conex?o
              ExecSQL;
              pgDataSource.DataSet.Refresh();
              dbGridArmazenagem.Refresh();
              showMessage('Armazenagem excluida com sucesso!!!')
            except on E: Exception do
              begin
                showMessage('Erro na exclus?o de dados!!!!')
              end;
            end;
          end;
        end
      else
        begin
          ShowMessage('Saldo do endere?o ja possui saida, impossivel ' +
          'concluir exclus?o. Movimente o saldo restantante para outro endereco'
          );
        end;


    end;
    enableDesableControls(false);
    btnExcluir.Enabled := false;
end;

//*HABILITA E DESABILTA CAMPOS
procedure TfrmArmazenagem.enableDesableControls(status: boolean);
begin
  txtQuantidade.Enabled := status;
  txtProduto.Enabled := status;
  txtEndereco.Enabled := status;
  pickerDataEntrada.Enabled := status;
  pickerDataVencimento.Enabled := status;
  btnPesquisarProduto.Enabled := status;
  btnPesquisarEnde.Enabled := status;

  btnNovo.Enabled := not status;
  btnEditar.Enabled := status;
  btnExcluir.Enabled := status;
  btnCancelar.Enabled := status;
  btnSave.Enabled := status;
end;

//*FORM SHOW
procedure TfrmArmazenagem.FormShow(Sender: TObject);
begin
  loadDados('x'); //carrega os 500 primeiros
  formatDbGrid(pgDataSource);
  pgDataSource.DataSet.Refresh;
end;

//*FORMAT DATA GRID IN LOAD
procedure TfrmArmazenagem.formatDbGrid(grid:TDataSource);
begin
  grid.DataSet.FieldByName('codigo').Visible := false;
  grid.DataSet.FieldByName('produto').Visible := false;
  grid.DataSet.FieldByName('endereco').Visible := false;
  grid.DataSet.FieldByName('sku').DisplayWidth:= 15;
  grid.DataSet.FieldByName('ean').DisplayWidth:= 13;
  grid.DataSet.FieldByName('descricao').DisplayWidth:= 20;
  grid.DataSet.FieldByName('tipobaixa').DisplayWidth:= 4;
  grid.DataSet.FieldByName('nome_endereco').DisplayWidth:= 8;
  grid.DataSet.FieldByName('etiqueta').DisplayWidth:= 10;
end;

//*FUN??O PARA VALIDAR PREENCHIMENTO DOS CAMPOS
function TfrmArmazenagem.funcValidaCampos: boolean;
begin
  if (txtProduto.Text = EmptyStr) or (txtEndereco.Text = EmptyStr)
      or (txtQuantidade.Text = EmptyStr) or (pickerDataEntrada.IsEmpty = true)
  then
    begin
      result := false;
    end
  else
    begin
      result := true;
    end;

end;

//*LOAD DADOS
procedure TfrmArmazenagem.loadDados(filtro: string);
begin
  pgQuery := TFDQuery.Create(self);
  pgDataSource := TDataSource.Create(self);

  pgConnection.Close;
  pgQuery.Connection := pgConnection;
  pgDataSource.DataSet := pgQuery;
  dbGridArmazenagem.DataSource := pgDataSource;

  pgQuery.sql.Add('SELECT * FROM selectprodutoendereco(:filtro)');
  pgQuery.ParamByName('filtro').AsString := filtro;
  try
     pgConnection.Open();
     pgQuery.open;
//     formatDbGrid(pgDataSource);

  except on E: Exception do
      ShowMessage('Erro ao carregar 10 primeiros registros');
  end;

end;

//*INSERE NOVO (1) OU ATUALIZA(2)
procedure TfrmArmazenagem.saveDatas(action: integer);
var saldoAtual:integer;
//ROTINA PARA GRAVAR NOVO REGISTRO
begin
    case (action) of
    //*INSERT
      1:
        begin
          if funcValidaCampos() = false then
            begin
                 ShowMessage('Todos os Campos s?o obrigatorios, favor verificar');
                 exit;
            end
          else
            begin
              pgStoreProc := TFDStoredProc.Create(self);
              pgStoreProc.Connection := pgConnection;


              with pgStoreProc do
              begin
                  try
                    StoredProcName := 'insertProdutoEndereco';
                    Prepare;
                    Params[0].Value := pickerDataEntrada.Date;
                    //Params[1].Value := txtProduto.Text;
                    //Params[2].Value:= txtEndereco.Text;
                    Params[1].Value := codigoProduto;
                    Params[2].Value:= codigoEndereco;
                    Params[3].Value := txtQuantidade.Text;
                    Params[4].Value := txtQuantidade.Text;
                    Params[5].Value := 0;
                    Params[6].Value := null;
                    Params[7].Value := pickerDataVencimento.Date;
                    pgConnection.Open();
                    ExecProc();
                    ShowMessage('Produto Armazenado com sucesso!!!');
                    pgDataSource.DataSet.Refresh;
                    dbGridArmazenagem.Refresh;
                  except on E: EFDDBEngineException do
                    begin
                      case E.Kind of
                        ekOther: ShowMessage('Erro ao inserir  registro');
                        //ekNoDataFound: ;
                        //ekTooManyRows: ;
                        ekUKViolated: ShowMessage('Produto '+txtProduto.Text+
                          ' j? armazenado no endereco ' + txtEtiqueta.Text +
                          '. Utilize outro endereco ou tente atualizar dados');
                        //ekFKViolated:ShowMessage('Existe Saldo alocado para esse produto. impossivel exlcuir') ;
                        //ekObjNotExists: ;
                        //ekUserPwdInvalid: ;
                        //ekUserPwdExpired: ;
                        //ekUserPwdWillExpire: ;
                        //ekCmdAborted: ;
                        //ekServerGone: ;
                        ekServerOutput: ShowMessage('Erro na conex?o com banco de dados') ;
                        //ekArrExecMalfunc: ;
                        //ekInvalidParams: ;
                      end;
                    end;
              end;
            end;
          end;
        end;//end case 1
        //*UPDATE
        2:
        begin
          if funcValidaCampos() = false then
            begin
                 ShowMessage('Todos os Campos s?o obrigatorios, favor verificar');
                 exit;
            end
          else
            begin
              pgStoreProc := TFDStoredProc.Create(self);
              pgStoreProc.Connection := pgConnection;

              //pega o saldo que ja estava e soma com a entra


              with pgStoreProc do
              begin
                  try
                    StoredProcName := 'updateprodutoendereco';
                    Prepare;

                    Params[0].Value := pickerDataEntrada.Date;
                    Params[1].Value := codigoProduto;
                    Params[2].Value := codigoEndereco;
                    Params[3].Value := txtQuantidade.Text;
                    Params[4].Value := txtQuantidade.Text;
                    Params[5].Value := 0; //qt saida
                    Params[6].Value := null;//dt saida
                    Params[7].Value := pickerDataVencimento.Date;
                    Params[8].Value := strToInt(txtCodigo.Text);

                    pgConnection.Open();
                    ExecProc();
                    ShowMessage('Endereco atualizado com sucesso!!!');
                    pgDataSource.DataSet.Refresh;
                    dbGridArmazenagem.Refresh;

                  except on E: Exception do
                    begin
                     ShowMessage('Erro ao tentar atualizar o endere?o');
                     exit;
                    end;
                  end;
               end;
            end;

        end;//end case 2
    end;

end;

end.
