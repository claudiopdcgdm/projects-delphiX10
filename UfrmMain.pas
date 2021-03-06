unit UfrmMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.ComCtrls,
  Vcl.Imaging.jpeg, Vcl.Menus;

type
  TfrmMain = class(TForm)
    stbInformation: TStatusBar;
    timerDataHora: TTimer;
    MainMenu1: TMainMenu;
    mnuArquivo: TMenuItem;
    mnuSair: TMenuItem;
    Cadastros1: TMenuItem;
    mnuCadProduto: TMenuItem;
    mnuCadEndereco: TMenuItem;
    mnuMovimentos: TMenuItem;
    mnuMovArmazenar: TMenuItem;
    mnuMovExpedicao: TMenuItem;
    mnuRelatorios: TMenuItem;
    mnuRelPedidoSaida: TMenuItem;
    Image1: TImage;
    menuPedidoSaida: TMenuItem;
    ProgressBar1: TProgressBar;
    procedure timerDataHoraTimer(Sender: TObject);
    procedure mnuCadProdutoClick(Sender: TObject);
    procedure mnuSairClick(Sender: TObject);
    procedure mnuCadEnderecoClick(Sender: TObject);
    procedure mnuMovArmazenarClick(Sender: TObject);
    procedure menuPedidoSaidaClick(Sender: TObject);
    procedure mnuRelPedidoSaidaClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmMain: TfrmMain;

implementation

{$R *.dfm}

uses UfrmCadastroProdutos, UfrmCadastroEndereco, UfrmArmazenagem,
  UfrmPedidoSaida, URelatorioPedidoSaida;


procedure TfrmMain.menuPedidoSaidaClick(Sender: TObject);
begin
   try
        Application.CreateForm(TfrmPedidoSaida, frmPedidoSaida);
        frmPedidoSaida.ShowModal;
    finally
        FreeAndNil(frmPedidoSaida);
    end;
end;

procedure TfrmMain.mnuCadEnderecoClick(Sender: TObject);
begin
     try
        Application.CreateForm(TfrmCadEndereco, frmCadEndereco);
        frmCadEndereco.ShowModal;
    finally
        FreeAndNil(frmCadEndereco);
    end;
end;

procedure TfrmMain.mnuCadProdutoClick(Sender: TObject);
begin
    try
        Application.CreateForm(TfrmCadastroProdutos, frmCadastroProdutos);
        frmCadastroProdutos.ShowModal;
    finally
        FreeAndNil(frmCadastroProdutos);
    end;
end;

procedure TfrmMain.mnuMovArmazenarClick(Sender: TObject);
begin
    try
        Application.CreateForm(TfrmArmazenagem, frmArmazenagem);
        frmArmazenagem.ShowModal;
    finally
        FreeAndNil(frmArmazenagem);
    end;
end;

procedure TfrmMain.mnuRelPedidoSaidaClick(Sender: TObject);
begin
    try
        Application.CreateForm(TfrmRelatorioPedidoSaida, frmRelatorioPedidoSaida);
        frmRelatorioPedidoSaida.ShowModal;
    finally
        FreeAndNil(frmRelatorioPedidoSaida);
    end;
end;

procedure TfrmMain.mnuSairClick(Sender: TObject);
begin
    close();
end;

procedure TfrmMain.timerDataHoraTimer(Sender: TObject);
begin
    stbInformation.Panels[0].Text := 'Simple App WMS';
    stbInformation.Panels[1].Text := 'Data:' + dateToStr(date);
    stbInformation.Panels[2].Text := 'Hora:' + dateToStr(time);

end;

end.
