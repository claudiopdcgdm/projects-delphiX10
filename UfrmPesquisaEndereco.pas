unit UfrmPesquisaEndereco;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.Phys.PG,
  FireDAC.Phys.PGDef, FireDAC.VCLUI.Wait, FireDAC.Stan.Param, FireDAC.DatS,
  FireDAC.DApt.Intf, FireDAC.DApt, Data.DB, Vcl.StdCtrls, Vcl.Grids,
  Vcl.DBGrids, FireDAC.Comp.DataSet, FireDAC.Comp.Client, Vcl.Buttons;

type
    TfrmPesquisaEndereco = class(TForm)
    pgGridPesquisaEndereco: TDBGrid;
    GroupBox1: TGroupBox;
    btnPesquisa: TSpeedButton;
    txtPesquisa: TEdit;
    pgConnection: TFDConnection;
    pgDataSource: TDataSource;
    procedure FormShow(Sender: TObject);
    procedure btnPesquisaClick(Sender: TObject);
    procedure pgGridPesquisaEnderecoDblClick(Sender: TObject);
  private
    { Private declarations }
    procedure loadPesquisa(filtro:string);
    procedure formatDbGrid();

  public
    { Public declarations }
  end;

var
  frmPesquisaEndereco: TfrmPesquisaEndereco;

implementation

{$R *.dfm}

uses UfrmArmazenagem;

//FORM SHOW
procedure TfrmPesquisaEndereco.FormShow(Sender: TObject);
begin
  loadPesquisa('x');
  formatDbGrid();
end;

//LOAD PESQUISA
procedure TfrmPesquisaEndereco.loadPesquisa(filtro:string);

var pgQuery:TFDQuery;

begin
  pgQuery := TFDQuery.Create(self);
  pgDataSource := TDataSource.Create(self);

  pgQuery.Connection := pgConnection;
  pgDataSource.DataSet := pgQuery;
  pgGridPesquisaEndereco.DataSource := pgDataSource;

  try
    pgConnection.Open();
    pgQuery.sql.Add('SELECT * FROM selectendereco(:filtro)');
    pgQuery.ParamByName('filtro').AsString := filtro;
    pgQuery.Open();

  except on E: Exception do
    begin
      ShowMessage('Erro ao carregar dados do banco');
      exit;
    end;
  end;
  pgDataSource.DataSet.Refresh;
end;

//CELL DOUBLE CLICK
procedure TfrmPesquisaEndereco.pgGridPesquisaEnderecoDblClick(Sender: TObject);
begin
  frmArmazenagem.nomeEndereco := pgDataSource.DataSet.FieldByName('nome').AsString;
  frmArmazenagem.codigoEndereco := pgDataSource.DataSet.FieldByName('codigo').AsInteger;
  frmArmazenagem.etiquetaEndereco := pgDataSource.DataSet.FieldByName('etiqueta').AsString;
  frmPesquisaEndereco.Close();
end;


//PESQUISA ENDERECO
procedure TfrmPesquisaEndereco.btnPesquisaClick(Sender: TObject);
begin
  if txtPesquisa.Text <> EmptyStr then
    loadPesquisa(txtPesquisa.Text)
  else
    loadPesquisa('x');
  formatDbGrid();
end;

//FORMATA GRID
procedure TfrmPesquisaEndereco.formatDbGrid;
begin
  pgDataSource.DataSet.FieldByName('nome').DisplayWidth := 10;
  pgDataSource.DataSet.FieldByName('etiqueta').DisplayWidth := 10;
end;

end.
