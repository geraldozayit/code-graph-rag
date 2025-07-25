program TestePascal;

{ Exemplo de programa Delphi/Pascal para testar o parser }

uses
  SysUtils, Classes, Forms;

type
  { Classe exemplo TMinhaClasse }
  TMinhaClasse = class(TObject)
  private
    FNome: string;
    FIdade: Integer;
  protected
    procedure SetNome(const Value: string);
  public
    constructor Create;
    destructor Destroy; override;

    function GetNomeCompleto: string;
    procedure ExibirInfo;

    property Nome: string read FNome write SetNome;
    property Idade: Integer read FIdade write FIdade;
  end;

  { Record exemplo }
  TPessoa = record
    Nome: string;
    Email: string;
    Telefone: string;
  end;

  { Interface exemplo }
  IProcessador = interface
    ['{12345678-1234-1234-1234-123456789012}']
    function Processar(const Dados: string): Boolean;
    procedure Configurar(const Parametros: array of string);
  end;

var
  MinhaInstancia: TMinhaClasse;
  Pessoa: TPessoa;

{ Implementação dos métodos da classe }

constructor TMinhaClasse.Create;
begin
  inherited Create;
  FNome := '';
  FIdade := 0;
end;

destructor TMinhaClasse.Destroy;
begin
  // Cleanup se necessário
  inherited Destroy;
end;

procedure TMinhaClasse.SetNome(const Value: string);
begin
  if Value <> FNome then
  begin
    FNome := Value;
    WriteLn('Nome alterado para: ' + FNome);
  end;
end;

function TMinhaClasse.GetNomeCompleto: string;
begin
  Result := Format('%s (Idade: %d)', [FNome, FIdade]);
end;

procedure TMinhaClasse.ExibirInfo;
begin
  WriteLn('Nome: ' + Nome);
  WriteLn('Idade: ' + IntToStr(Idade));
end;

{ Funções auxiliares }

function CalcularIdade(const DataNascimento: TDateTime): Integer;
var
  Anos: Integer;
begin
  Anos := YearOf(Now) - YearOf(DataNascimento);
  if MonthOf(Now) < MonthOf(DataNascimento) then
    Dec(Anos)
  else if (MonthOf(Now) = MonthOf(DataNascimento)) and
          (DayOf(Now) < DayOf(DataNascimento)) then
    Dec(Anos);

  Result := Anos;
end;

procedure ProcessarLista(Lista: TStringList);
var
  i: Integer;
  Item: string;
begin
  for i := 0 to Lista.Count - 1 do
  begin
    Item := Lista[i];
    WriteLn(Format('Item %d: %s', [i, Item]));
  end;
end;

{ Programa principal }
begin
  try
    MinhaInstancia := TMinhaClasse.Create;
    try
      MinhaInstancia.Nome := 'João Silva';
      MinhaInstancia.Idade := 30;
      MinhaInstancia.ExibirInfo;

      Pessoa.Nome := 'Maria';
      Pessoa.Email := 'maria@email.com';
      Pessoa.Telefone := '(11) 99999-9999';

      WriteLn('Processamento concluído com sucesso!');
    finally
      MinhaInstancia.Free;
    end;
  except
    on E: Exception do
      WriteLn('Erro: ' + E.Message);
  end;
end.
