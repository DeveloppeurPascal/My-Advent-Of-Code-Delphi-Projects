unit Unit1;

// My solution for https://adventofcode.com/2020/day/5
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
  public
    { Déclarations publiques }
    function getRow(Place: string): integer;
    function getCol(Place: string): integer;
    function calcule(Place: string; debut, fin: integer): integer;
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

uses
  System.Character;

procedure TForm1.Button1Click(Sender: TObject);
var
  i: integer;
  Place: string;
  SeatID, RowNum, ColNum, BigSeatID: integer;
begin
  BigSeatID := 0;
  for i := 0 to Memo1.Lines.Count - 1 do
  begin
    Place := Memo1.Lines[i];
    RowNum := getRow(Place);
    ColNum := getCol(Place);
    SeatID := ColNum + RowNum * 8;
    if SeatID > BigSeatID then
      BigSeatID := SeatID;
  end;
  Edit1.Text := BigSeatID.ToString;
end;

procedure TForm1.Button2Click(Sender: TObject);
var
  i: integer;
  Place: string;
  SeatID, RowNum, ColNum: integer;
  tab: array [0 .. 127 * 8 + 7] of boolean;
begin
  for i := 0 to 127 * 8 + 7 do
    tab[i] := false;
  for i := 0 to Memo1.Lines.Count - 1 do
  begin
    Place := Memo1.Lines[i];
    RowNum := getRow(Place);
    ColNum := getCol(Place);
    SeatID := ColNum + RowNum * 8;
    tab[SeatID] := true;
  end;
  for i := 0 + 1 to 127 * 8 + 7 - 1 do
    if (not tab[i]) and tab[i - 1] and tab[i + 1] then
    begin
      // Memo1.Lines.Insert(0, i.ToString);
      Edit1.Text := i.ToString;
      break;
    end;
end;

function TForm1.calcule(Place: string; debut, fin: integer): integer;
var
  c: char;
  moitie: integer;
begin
  if Place.isempty then
  begin
    assert(debut = fin);
    result := debut;
  end
  else
  begin
    moitie := (debut + fin) div 2;
    c := Place.Chars[0];
    if c.IsInArray(['F', 'L']) then
      result := calcule(Place.Substring(1), debut, moitie)
    else if c.IsInArray(['B', 'R']) then
      result := calcule(Place.Substring(1), moitie + 1, fin)
    else
      raise exception.Create('wrong letter');
  end;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  Memo1.Lines.Clear;
  Edit1.Text := '';
end;

function TForm1.getCol(Place: string): integer;
begin
  result := calcule(Place.Substring(7, 3), 0, 7);
end;

function TForm1.getRow(Place: string): integer;
begin
  result := calcule(Place.Substring(0, 7), 0, 127);
end;

end.
