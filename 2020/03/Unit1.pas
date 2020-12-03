unit Unit1;
// My solution for https://adventofcode.com/2020/day/3

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls;

type
  TForm1 = class(TForm)
    Memo1: TMemo;
    Panel1: TPanel;
    Button1: TButton;
    Button2: TButton;
    Edit1: TEdit;
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    { Déclarations privées }
    function CompteArbres(pasX, pasY: integer): integer;
  public
    { Déclarations publiques }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.Button1Click(Sender: TObject);
begin
  Edit1.Text := CompteArbres(3, 1).ToString;
end;

procedure TForm1.Button2Click(Sender: TObject);
var
  nbArbres: integer;
begin
  nbArbres := CompteArbres(1, 1);
  nbArbres := nbArbres * CompteArbres(3, 1);
  nbArbres := nbArbres * CompteArbres(5, 1);
  nbArbres := nbArbres * CompteArbres(7, 1);
  nbArbres := nbArbres * CompteArbres(1, 2);
  Edit1.Text := nbArbres.ToString;
end;

function TForm1.CompteArbres(pasX, pasY: integer): integer;
var
  x, y: integer;
begin
  result := 0;
  x := 1;
  y := 0;
  while (y < Memo1.Lines.Count) do
  begin
    while (x > Memo1.Lines[y].Length) do
      x := x - Memo1.Lines[y].Length;
    if (Memo1.Lines[y].Chars[x - 1] = '#') then
      inc(result);
    x := x + pasX;
    y := y + pasY;
  end;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  Memo1.Lines.Clear;
  Edit1.Text := '';
end;

end.
