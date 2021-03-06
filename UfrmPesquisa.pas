unit UfrmPesquisa;

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
  TfrmPesquisa = class(TForm)
    pgConnection: TFDConnection;
    pgGridPesquisaProduto: TDBGrid;
    GroupBox1: TGroupBox;
    txtPesquisa: TEdit;
    btnPesquisa: TSpeedButton;
    pgDataSource: TDataSource;
    procedure btnPesquisaClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure pgGridPesquisaProdutoDblClick(Sender: TObject);
  private
    { Private declarations }
    procedure formatDbGrid();
    procedure loadPesquisa(filtro:string);
  public
    { Public declarations }
  end;

var
  frmPesquisa: TfrmPesquisa;

implementation

{$R *.dfm}

uses UfrmArmazenagem;



//LOAD PESQUISA
procedure TfrmPesquisa.loadPesquisa(filtro:string);

var pgQuery:TFDQuery;

begin
  pgQuery := TFDQuery.Create(self);
  pgDataSource := TDataSource.Create(self);

  pgQuery.Connection := pgConnection;
  pgDataSource.DataSet := pgQuery;
  pgGridPesquisaProduto.DataSource := pgDataSource;

  try
    pgConnection.Open();
    pgQuery.sql.Add('SELECT * FROM selectproduto(:filtro)');
    pgQuery.ParamByName('filtro').AsString := filtro;
    pgQuery.Open();
    formatDbGrid();
    pgDataSource.DataSet.Refresh;
    pgGridPesquisaProduto.Refresh;
  except on E: Exception do
    begin
      ShowMessage('Erro ao carregar dados do banco');
      exit;
    end;
  end;
end;

//CELL DOUBLE CLICK
procedure TfrmPesquisa.pgGridPesquisaProdutoDblClick(Sender: TObject);
begin
  frmArmazenagem.codigoProduto := pgDataSource.DataSet.FieldByName('codigo').AsInteger;
  frmArmazenagem.sku := pgDataSource.DataSet.FieldByName('sku').AsString;
  frmArmazenagem.descricaoProduto := pgDataSource.DataSet.FieldByName('descricao').AsString;
  frmPesquisa.Close();
end;

//BOTAO PESQUISAR
procedure TfrmPesquisa.btnPesquisaClick(Sender: TObject);
begin
  loadPesquisa(txtPesquisa.Text);
end;

//formata o grid
procedure TfrmPesquisa.formatDbGrid;
begin

  pgDataSource.DataSet.FieldByName('descricao').DisplayWidth := 30;
  pgDataSource.DataSet.FieldByName('peso').DisplayWidth := 4;
  pgDataSource.DataSet.FieldByName('ean').DisplayWidth := 13;
  pgDataSource.DataSet.FieldByName('tipobaixa').DisplayWidth := 4;
  pgDataSource.DataSet.FieldByName('sku').DisplayWidth := 15;

end;

//FORM SHOW
procedure TfrmPesquisa.FormShow(Sender: TObject);
begin
  loadPesquisa('x');
end;
end.
