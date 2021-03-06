unit UfrmCadastroEndereco;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.Phys.PG,
  FireDAC.Phys.PGDef, FireDAC.VCLUI.Wait, FireDAC.Stan.Param, FireDAC.DatS,
  FireDAC.DApt.Intf, FireDAC.DApt, Data.DB, Vcl.ExtCtrls, Vcl.DBCtrls,
  Vcl.StdCtrls, Vcl.Mask, FireDAC.Comp.DataSet, FireDAC.Comp.Client, Vcl.Grids,
  Vcl.DBGrids, Vcl.Buttons;

type
  TfrmCadEndereco = class(TForm)
    pgGrid: TDBGrid;
    pgConn: TFDConnection;
    btnCancelar: TSpeedButton;
    btnEditar: TSpeedButton;
    btnExcluir: TSpeedButton;
    btnSave: TSpeedButton;
    btnNovo: TSpeedButton;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Label10: TLabel;
    txtCodigo: TEdit;
    txtNome: TEdit;
    txtEtiqueta: TEdit;
    txtArea: TEdit;
    txtRua: TEdit;
    txtNivel: TEdit;
    txtVao: TEdit;
    txtLargura: TEdit;
    txtComprimento: TEdit;
    txtAltura: TEdit;
    procedure FormShow(Sender: TObject);
    procedure btnNovoClick(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
    procedure txtEtiquetaEnter(Sender: TObject);
    procedure btnEditarClick(Sender: TObject);
    procedure pgGridCellClick(Column: TColumn);
    procedure btnCancelarClick(Sender: TObject);
    procedure btnExcluirClick(Sender: TObject);

  private
    { Private declarations }
    pgQuery : TFDQuery;
    pgStoreProc : TFDStoredProc;
    pgDataSource : TDataSource;
    procedure loadDados(filtro:string);
    procedure formatDbGrid();
    procedure saveDatas(action:integer);
    procedure enableDesableControls(status:boolean);
    procedure clearFields();
    function funcVerificaCampos():boolean;
    var etiqueta:string;

  public
    { Public declarations }
  end;

var
  frmCadEndereco: TfrmCadEndereco;

implementation

{$R *.dfm}

//*FORM SHOW
procedure TfrmCadEndereco.FormShow(Sender: TObject);
begin
  loadDados('x');
  formatDbGrid();
end;

//*LOAD DADOS
procedure TfrmCadEndereco.loadDados(filtro: string);
begin
  pgQuery := TFDQuery.Create(self);
  pgDataSource := TDataSource.Create(self);

  pgQuery.Connection := pgConn;
  pgDataSource.DataSet := pgQuery;
  pgGrid.DataSource := pgDataSource;

  pgQuery.SQL.Add('select * from selectendereco(:filtro)');
  pgQuery.ParamByName('filtro').AsString := filtro;

  try
     pgConn.Open();
     pgQuery.Open();

  except on E: Exception do
    begin
      ShowMessage('Erro ao carregar registros do banco!!');
    end;
  end;

end;

//*CELL CLICK
procedure TfrmCadEndereco.pgGridCellClick(Column: TColumn);
begin
  if pgDataSource.DataSet.RecordCount <> 0 then
    begin
      txtCodigo.Text := pgDataSource.DataSet.FieldByName('codigo').AsString;
      txtNome.Text := pgDataSource.DataSet.FieldByName('nome').AsString;
      txtArea.Text := pgDataSource.DataSet.FieldByName('area').AsString;
      txtRua.Text := pgDataSource.DataSet.FieldByName('rua').AsString;
      txtNivel.Text := pgDataSource.DataSet.FieldByName('nivel').AsString;
      txtVao.Text := pgDataSource.DataSet.FieldByName('vao').AsString;
      txtLargura.Text := pgDataSource.DataSet.FieldByName('largura').AsString;
      txtComprimento.Text := pgDataSource.DataSet.FieldByName('comprimento').AsString;
      txtAltura.Text := pgDataSource.DataSet.FieldByName('altura').AsString;
      txtEtiqueta.Text := pgDataSource.DataSet.FieldByName('etiqueta').AsString;
      btnEditar.Enabled := true;
      btnExcluir.Enabled := true;
    end;

end;

//*SAVE DATA
procedure TfrmCadEndereco.saveDatas(action: integer);
begin

case (action) of
   1:
    begin
       pgStoreProc := TFDStoredProc.Create(self);

       with pgStoreProc do
       begin
        pgStoreProc.Connection := pgConn;

        StoredProcName := 'insertendereco';
        Prepare;
        Params[0].Value := strToInt(txtArea.Text);
        Params[1].Value := strToInt(txtRua.Text);
        Params[2].Value := strToInt(txtNivel.Text);
        Params[3].Value := txtNome.Text;
        Params[4].Value := strToFloat(txtLargura.Text);
        Params[5].Value := strToFloat(txtComprimento.Text);
        Params[6].Value := txtEtiqueta.Text;
        Params[7].Value := strToInt(txtVao.Text);
        Params[8].Value := strToFloat(txtAltura.Text);

        try
          pgConn.Open();
          ExecProc();
          pgDataSource.DataSet.Refresh;
          ShowMessage('Registro cadastrado com sucesso');
        except on E: EFDDBEngineException do
          begin
            case E.Kind of
              ekOther: ShowMessage('Erro ao Inserir Registro');
              ekUKViolated: ShowMessage('Endereco ja cadastro');
              ekServerOutput: ShowMessage('Erro na conex?o com banco de dados');
            end;
          end;


        end;

       end;

    end;//end case insert(case 1)
   2:
    begin
       pgStoreProc := TFDStoredProc.Create(self);

       with pgStoreProc do
       begin
        pgStoreProc.Connection := pgConn;

        StoredProcName := 'updateendereco';
        Prepare;
        Params[0].Value := strToInt(txtArea.Text);
        Params[1].Value := strToInt(txtRua.Text);
        Params[2].Value := strToInt(txtNivel.Text);
        Params[3].Value := txtNome.Text;
        Params[4].Value := strToFloat(txtLargura.Text);
        Params[5].Value := strToFloat(txtComprimento.Text);
        Params[6].Value := txtEtiqueta.Text;
        Params[7].Value := strToInt(txtVao.Text);
        Params[8].Value := strToFloat(txtAltura.Text);
        Params[9].Value := strToInt(txtCodigo.Text);

        try
          pgConn.Open();
          ExecProc();
          pgDataSource.DataSet.Refresh;
          ShowMessage('Registro atualizado com sucesso');
        except on E: Exception do
          begin
            ShowMessage('Erro ao atualizado endereco');
          end;
        end;

       end;
    end;
end;


end;

//*PREENCHE CAMPO ETIQUETA AUTOMATICAMENTE
procedure TfrmCadEndereco.txtEtiquetaEnter(Sender: TObject);
begin
  etiqueta := 'A'+txtArea.Text+'-R'+txtRua.Text+'-N'+txtNivel.Text
  +'-V'+txtVao.Text;
  txtEtiqueta.Text := etiqueta;
end;

//*FUNCTION PARA VERIFICAR PREENCHIMENTOS DE CAMPOS
function TfrmCadEndereco.funcVerificaCampos():boolean;
begin

  if (txtNome.Text = EmptyStr) or (txtArea.Text = EmptyStr)
    or (txtRua.Text = EmptyStr) or (txtNivel.Text = EmptyStr)
    or (txtLargura.Text = EmptyStr) or (txtAltura.Text =EmptyStr)
    or (txtEtiqueta.Text = EmptyStr) or (txtVao.Text = EmptyStr)
    or (txtComprimento.Text = EmptyStr) then
    begin
      result:=false;
    end
  else
    begin
      result:=true
    end;

end;

//*CANCELAR
procedure TfrmCadEndereco.btnCancelarClick(Sender: TObject);

begin
  enableDesableControls(false);
end;

//*EDITAR
procedure TfrmCadEndereco.btnEditarClick(Sender: TObject);
begin
  enableDesableControls(true);
  btnExcluir.Enabled := false;
  txtNome.SetFocus();
end;

//*EXCLUIR
procedure TfrmCadEndereco.btnExcluirClick(Sender: TObject);

var resultMsg:Integer;

begin
resultMsg := MessageDlg('Deja realmente exlcuir o registro?',
              mtConfirmation,[mbYes,mbNo],1);

  //6=mbYes,7=mbNo
  if resultMsg = 6 then
    begin
      pgQuery := TFDQuery.Create(self);
      pgQuery.Connection := pgConn;

      if txtCodigo.Text <> EmptyStr then
        begin
          pgQuery.SQL.Add('DELETE FROM endereco WHERE "CODIGO" = :codigo');
          pgQuery.ParamByName('codigo').AsInteger := strToInt(txtCodigo.Text);

          try
            pgConn.Open();
            pgQuery.ExecSQL();
            ShowMessage('Registro exlcuido com sucesso!!!');
            pgDataSource.DataSet.Refresh;
          except on E: Exception do
            begin
              ShowMessage('Erro na exclus?o de dados');
            end;
        end;
    end;
  end;
  enableDesableControls(false);
  clearFields();

end;

//*NOVO
procedure TfrmCadEndereco.btnNovoClick(Sender: TObject);
begin
    clearFields();
    enableDesableControls(true);
    txtNome.SetFocus();
end;

//*SAVE
procedure TfrmCadEndereco.btnSaveClick(Sender: TObject);
begin
  if funcVerificaCampos then
    begin
       if (txtCodigo.Text = EmptyStr)then
        begin
           saveDatas(1) //execute insert
        end
       else
        begin
           saveDatas(2); //execute update
        end;
       clearFields();
       enableDesableControls(false);
    end
 else
    ShowMessage('Campos s?o obrigatorios!!!');
    exit;
end;

//*FORMATA GRID
procedure TfrmCadEndereco.formatDbGrid;
begin

  pgDataSource.DataSet.FieldByName('codigo').DisplayWidth := 4;
  pgDataSource.DataSet.FieldByName('nome').DisplayWidth := 15;
  pgDataSource.DataSet.FieldByName('etiqueta').DisplayWidth := 15;
  pgDataSource.DataSet.FieldByName('area').DisplayWidth := 4;
  pgDataSource.DataSet.FieldByName('rua').DisplayWidth := 4;
  pgDataSource.DataSet.FieldByName('largura').DisplayWidth := 5;
  pgDataSource.DataSet.FieldByName('comprimento').DisplayWidth := 5;
end;

//*HABILITA E DESABILITA COMPONENTES
procedure TfrmCadEndereco.enableDesableControls(status: boolean);
begin
  txtNome.Enabled := status;
  txtNivel.Enabled := status;
  txtArea.Enabled := status;
  txtRua.Enabled := status;
  txtEtiqueta.Enabled := status;
  txtVao.Enabled := status;
  txtLargura.Enabled := status;
  txtComprimento.Enabled := status;
  txtAltura.Enabled := status;

  btnNovo.Enabled := not status;
  btnEditar.Enabled := status;
  btnExcluir.Enabled := status;
  btnCancelar.Enabled := status;
  btnSave.Enabled := status;
end;

//*LIMPA CAMPOS
procedure TfrmCadEndereco.clearFields;
begin
  txtCodigo.Text := EmptyStr;
  txtNome.Text := EmptyStr;
  txtEtiqueta.Text := EmptyStr;
  txtArea.Text := EmptyStr;
  txtRua.Text := EmptyStr;
  txtNivel.Text := EmptyStr;
  txtVao.Text := EmptyStr;
  txtLargura.Text := EmptyStr;
  txtComprimento.Text := EmptyStr;
  txtAltura.Text := EmptyStr;

end;


end.
