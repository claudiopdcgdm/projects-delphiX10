unit UfrmCadastroProdutos;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.VCLUI.Wait,
  FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt,
  FireDAC.Comp.Client, Data.DB, FireDAC.Comp.DataSet, FireDAC.Phys.PG,
  FireDAC.Phys.PGDef, Vcl.Grids, Vcl.DBGrids, Vcl.Buttons, Vcl.ExtCtrls,
  Vcl.StdCtrls, Vcl.WinXCalendars,DateUtils;

type
  TfrmCadastroProdutos = class(TForm)
    pgConnection: TFDConnection;
    dbGridCadProduto: TDBGrid;
    Label1: TLabel;
    btnNovo: TSpeedButton;
    btnEditar: TSpeedButton;
    btnExcluir: TSpeedButton;
    btnCancelar: TSpeedButton;
    btnSave: TSpeedButton;
    GroupBox1: TGroupBox;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    txtDescricao: TEdit;
    txtPeso: TEdit;
    pickerDtCadastro: TCalendarPicker;
    txtEan: TEdit;
    txtSku: TEdit;
    Label9: TLabel;
    cboTipoBaixa: TComboBox;
    txtCodigo: TEdit;
    Label10: TLabel;
    txtPesquisa: TEdit;
    rbSku: TRadioButton;
    rbDescricao: TRadioButton;
    btnPesquisa: TSpeedButton;
    procedure FormShow(Sender: TObject);
    procedure btnNovoClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnEditarClick(Sender: TObject);
    procedure dbGridCadProdutoCellClick(Column: TColumn);
    procedure btnExcluirClick(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
    procedure btnCancelarClick(Sender: TObject);
    procedure btnPesquisaClick(Sender: TObject);


  private
    { Private declarations }
      var pgQuery: TFDQuery;
      var dsCadProduto: TDataSource;
      var pgStoreProc: TFDStoredProc;
      var sku,descricao,ean,tpBaixa:String;
      var peso:double;
      var dtCadastro, dtEntrada, dtVencimento:TDate;
      var action:String;

      //PROCEDURES
      procedure loadDados();
      procedure clearFields();
      procedure enableDisableControls(active:boolean);
      procedure save(action:integer);
      function funcValidaCampos():boolean;
      procedure formatDbGrid();
      procedure delete();
      

  public
    { Public declarations }
  end;

var
  frmCadastroProdutos: TfrmCadastroProdutos;
implementation

{$R *.dfm}

//*CANCELAR
procedure TfrmCadastroProdutos.btnCancelarClick(Sender: TObject);
begin
  clearFields();
  enableDisableControls(false);
  btnEditar.Enabled := false;
  btnExcluir.Enabled := false;
end;

//*EDITAR
procedure TfrmCadastroProdutos.btnEditarClick(Sender: TObject);
begin
  enableDisableControls(true);
  btnExcluir.Enabled :=false;
  txtCodigo.Enabled := false;

end;

//*EXCLUIR
procedure TfrmCadastroProdutos.btnExcluirClick(Sender: TObject);
var resultDlg:integer;
begin
    if txtCodigo.Text = '' then
      begin
       ShowMessage('Selecione um registro para excluir');
       exit;
      end
    else
      begin
        resultDlg := MessageDlg('Deja realmente exlcuir o registro?',
              mtConfirmation,[mbYes,mbNo],1);

        //6=mbYes,7=mbNo
        if resultDlg = 6 then
          begin
            delete();
          end;
        enableDisableControls(false);
        btnExcluir.Enabled := false;
        btnEditar.Enabled := false;
        clearFields();

      end;



        
end;

//*SALVAR
procedure TfrmCadastroProdutos.btnSaveClick(Sender: TObject);
begin

  //SE O CAMPO CODIGO FOR INFORMADO EXECUTA UM UPDATE
  //SE N?O EXECUTA UM INSERT
  if funcValidaCampos then
    begin
       if txtCodigo.Text = EmptyStr then
        begin
          save(1);

        end
       else
        begin
          save(2);
          btnEditar.Enabled := false;
          btnExcluir.Enabled := false;
        end;
    ClearFields();
    enableDisableControls(false);
    end
    else
      begin
        ShowMessage('Todos os campos s?o obrigatorios');
      end;

end;

//*NOVO
procedure TfrmCadastroProdutos.btnNovoClick(Sender: TObject);
begin
  clearFields();
  enableDisableControls(true);
end;

//*PESQUISAR
procedure TfrmCadastroProdutos.btnPesquisaClick(Sender: TObject);

var sql:String;

begin
  //cria o componente TFDquery
  pgQuery:= TFDQuery.Create(self);
  //cria o componente TDatasource
  dsCadProduto := TDataSource.Create(self);
  sql := 'SELECT "CODIGO","SKU","EAN","DESCRICAO","TIPOBAIXA","PESO",'+
  '"DATACADASTRO" FROM produto';
  

  if (txtPesquisa.Text <> '') then
    begin
      pgQuery.Connection := pgConnection;      
      dsCadProduto.DataSet := pgQuery;
      dbGridCadProduto.DataSource := dsCadProduto;

      if (rbSku.Checked = true) then
         begin
          pgQuery.SQL.Add( sql + ' WHERE "SKU" LIKE :filtro');
         end
      else
      if (rbDescricao.Checked = true) then
         begin
          pgQuery.SQL.Add(sql + ' WHERE "DESCRICAO" LIKE :filtro');
         end;
      try
          pgConnection.open;
          pgQuery.ParamByName('filtro').Value := '%'+txtPesquisa.text+'%';
          pgQuery.open;
      except on E:Exception do
        begin
          ShowMessage('Erro ao carregar dados');
        end;
      end;
    end
  else
    begin
         ShowMessage('Preencha o campo pesquisa');
         txtPesquisa.SetFocus;
         loadDados();
    end;
      
  
  
end;

//*CLEARFIELDS
procedure TfrmCadastroProdutos.clearFields;
begin
  txtCodigo.Text := '';
  txtSku.Text := '';
  txtDescricao.Text := '';
  txtEan.Text := '';
  txtPeso.Text := '';
  pickerDtCadastro.Date := date;
  cboTipoBaixa.Text := 'Selecione...';
  
  
end;

//*CELL CLICK DO GRID
procedure TfrmCadastroProdutos.dbGridCadProdutoCellClick(Column: TColumn);
begin

  if dsCadProduto.DataSet.RecordCount <> 0 then
    begin
      txtCodigo.Text := dsCadProduto.DataSet.FieldByName('codigo').AsString;
      txtSku.Text := dsCadProduto.DataSet.FieldByName('sku').AsString;
      txtDescricao.Text := dsCadProduto.DataSet.FieldByName('descricao').AsString;
      txtEan.Text := dsCadProduto.DataSet.FieldByName('ean').AsString;
      pickerDtCadastro.Date := dsCadProduto.DataSet.FieldByName('datacadastro').AsDateTime;
      txtPeso.Text := dsCadProduto.DataSet.FieldByName('peso').AsString;
      cboTipoBaixa.Text := dsCadProduto.DataSet.FieldByName('tipobaixa').AsString;
      //pickerDtVencimento.Date := dsCadProduto.DataSet.FieldByName('dataVencimento').AsDateTime;
      //pickerDataEntrada.Date := dsCadProduto.DataSet.FieldByName('dataentrada').AsDateTime;

      btnEditar.Enabled := true;
      btnCancelar.Enabled := true;
      btnExcluir.Enabled := true;
      btnSave.Enabled :=true;
      btnNovo.Enabled := false;
    end;


end;

//*DELETE
procedure TfrmCadastroProdutos.delete;
begin

    //cria o componente TFDquery
    pgQuery:= TFDQuery.Create(self);
    //cria o componente TDatasource
    //dsCadProduto := TDataSource.Create(self);

    //informa fonte dedados para grid
    dbGridCadProduto.DataSource := dsCadProduto;
    //informa o dataset para datasource
    dsCadProduto.DataSet := pgQuery;

    pgQuery.Connection := pgConnection;


    try
        pgConnection.open;
        pgQuery.SQL.Add('DELETE FROM produto WHERE "CODIGO" = :codigo');
        pgQuery.ParamByName('codigo').AsInteger := strToInt(txtCodigo.Text);
        pgQuery.ExecSQL;
        ShowMessage('Registro excluido com sucesso!!!');

    except on E: EFDDBEngineException do
      begin
        case E.Kind of
          ekOther: ShowMessage('Erro ao excluir  registro');
          //ekNoDataFound: ;
          //ekTooManyRows: ;
          ekRecordLocked:ShowMessage('Registro em uso por outro processo. LOCK');
          //ekUKViolated: ShowMessage('Produto ja cadastro') ;
          ekFKViolated:ShowMessage('Existe Saldo alocado para esse produto. impossivel exlcuir') ;
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
    loadDados();
 end;

//*ENABLEDESABLECONTROLS
procedure TfrmCadastroProdutos.enableDisableControls(active:boolean);
begin
  //txtCodigo.Enabled := not active;
  txtSku.Enabled := active;
  txtDescricao.Enabled := active;
  txtEan.Enabled := active;
  txtPeso.Enabled := active;
  pickerDtCadastro.Enabled := active;
  cboTipoBaixa.Enabled := active;

  btnNovo.Enabled := not active;
  btnCancelar.Enabled := active;
  btnSave.Enabled := active;


end;

//*FORMATA DB GRID
procedure TfrmCadastroProdutos.formatDbGrid;
begin
  dsCadProduto.DataSet.FieldByName('descricao').DisplayWidth := 30;
  dsCadProduto.DataSet.FieldByName('peso').DisplayWidth := 4;
  dsCadProduto.DataSet.FieldByName('ean').DisplayWidth := 13;
  dsCadProduto.DataSet.FieldByName('tipobaixa').DisplayWidth := 4;
  dsCadProduto.DataSet.FieldByName('sku').DisplayWidth := 15;
end;

//*FORM CLOSE
procedure TfrmCadastroProdutos.FormClose(Sender: TObject;
var Action: TCloseAction);

begin
    frmCadastroProdutos := nil;
//    pgQuery.Close;
    pgConnection.Close;
end;

//*FORM SHOW
procedure TfrmCadastroProdutos.FormShow(Sender: TObject);
begin
      loadDados();
end;

//*LOAD DADOS
procedure TfrmCadastroProdutos.loadDados;
var  MyClass: TObject;
var filtro:string;
begin
{
    pgConnection.Params.Database := 'app_wms';
    pgConnection.Params.DriverID := 'PG';
    pgConnection.Params.UserName := 'postgres';
    pgConnection.Params.Password := 'q1w2e3r4';
    pgConnection.Connected := True;


    //cria o componente TFDquery
    pgQuery:= TFDQuery.Create(self);

    //cria o componente TDatasource
    dsCadProduto := TDataSource.Create(self);
    try
        pgConnection.open;
        pgQuery.Connection := pgConnection;
        dsCadProduto.DataSet := pgQuery;
        pgQuery.sql.Text := 'SELECT * FROM produto';
        dbGridCadProduto.DataSource := dsCadProduto;
        pgquery.open;

    except on E:Exception do
      begin
        ShowMessage('Erro ao carregar dados');
      end;

    end;
}

  pgQuery := TFDQuery.Create(self);
  dsCadProduto := TDataSource.Create(self);
  filtro := 'x';

  pgQuery.Connection := pgConnection;
  dsCadProduto.DataSet := pgQuery;
  dbGridCadProduto.DataSource := dsCadProduto;

  try
    pgConnection.Open();
    pgQuery.sql.Add('SELECT * FROM selectproduto(:filtro)');
    pgQuery.ParamByName('filtro').AsString := filtro;
    pgQuery.Open();
    formatDbGrid();
  except on E: Exception do
    begin
      ShowMessage('Erro ao carregar dados do banco');
      exit;
    end;
  end;





end;

//* SAVE - PROCEDURE PARA SALVAR OS PROCESSOS
procedure TfrmCadastroProdutos.save(action: Integer);

var codigo:Integer;

begin
    case (action) of
      //*INSERT
      1:
        begin
          pgStoreProc := TFDStoredProc.Create(self);
          pgStoreProc.Connection := pgConnection;

          with pgStoreProc do
          begin
              try
                StoredProcName := 'insertProduto';
                Prepare;
                Params[0].Value := descricao;
                Params[1].Value := dtCadastro;
                Params[2].Value:= peso;
                Params[3].Value := ean;
                Params[4].Value := tpbaixa;
                Params[5].Value := sku;
                pgConnection.Open();
                ExecProc();
                ShowMessage('Dados inseridos com sucesso!!!');
              except on E: EFDDBEngineException do
                  begin
                    case E.Kind of
                      ekOther: ShowMessage('Erro ao Inserir  registro');
                      //ekNoDataFound: ;
                      //ekTooManyRows: ;
                      //ekRecordLocked:ShowMessage('Registro em uso por outro processo. LOCK');
                      ekUKViolated: ShowMessage('Produto ja cadastro') ;
                      //ekFKViolated:ShowMessage('Existe Saldo alocado para esse produto. impossivel alterar') ;
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

        end;//end case 1
        2: //*UPDATE
          begin
            pgStoreProc := TFDStoredProc.Create(self);
            pgStoreProc.Connection := pgConnection;
            codigo := strToInt(txtCodigo.Text);


            with pgStoreProc do
            begin
                try
                  StoredProcName := 'updateProduto';
                  Prepare;
                  Params[0].Value := descricao;
                  Params[1].Value := dtCadastro;
                  Params[2].Value:= peso;
                  Params[3].Value := ean;
                  Params[4].Value := tpbaixa;
                  Params[5].Value := sku;
                  Params[6].Value := codigo;
                  pgConnection.Open();
                  ExecProc();
                  ShowMessage('Dados atualizados com sucesso!!!');
                except on E: EFDDBEngineException do
                  begin
                    case E.Kind of
                      ekOther: ShowMessage('Erro ao atualizar  registro');
                      //ekNoDataFound: ;
                      //ekTooManyRows: ;
                      ekRecordLocked:ShowMessage('Registro em uso por outro processo. LOCK');
                      //ekUKViolated: ShowMessage('Produto ja cadastro') ;
                      ekFKViolated:ShowMessage('Existe Saldo alocado para esse produto. impossivel alterar') ;
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
    end;//end case 2
  dsCadProduto.DataSet.Refresh;
end;

//*VALIDAR CAMPOS VAZIO
function TfrmCadastroProdutos.funcValidaCampos():boolean;
begin

   //atribui??es de valores
    if (txtSku.Text = '') or (txtEan.Text = '') or (txtPeso.Text = '') or
    (cboTipoBaixa.Text = 'Selecione...')  or (pickerDtCadastro.IsEmpty = true)
    then
      begin
        result := false;
      end
    else
      begin
        descricao := txtDescricao.Text;
        sku := txtSku.Text;
        ean := txtEan.Text;
        peso := strToFloat(txtPeso.Text);
        tpBaixa := cboTipoBaixa.Text;
        dtCadastro := pickerDtCadastro.Date;
        result := true;
      end;
end;

end.//close program
