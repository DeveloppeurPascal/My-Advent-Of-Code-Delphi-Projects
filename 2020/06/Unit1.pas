unit Unit1;

// My solution for day 6 (2020) : https://adventofcode.com/2020/day/6
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
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.Button1Click(Sender: TObject);
var
  i, j: integer;
  q, ch: string;
  nb_total: integer;
begin
  nb_total := 0;
  q := '';
  for i := 0 to Memo1.Lines.Count - 1 do
  begin
    ch := Memo1.Lines[i].Trim;
    if ch.IsEmpty then
    begin
      nb_total := nb_total + q.Length;
      q := '';
    end
    else
      for j := 0 to ch.Length - 1 do
        if not q.Contains(ch.Chars[j]) then
          q := q + ch.Chars[j];
  end;
  if not ch.IsEmpty then // cas où pas de ligne vide après le dernier groupe
    nb_total := nb_total + q.Length;
  Edit1.Text := nb_total.ToString;
end;

procedure TForm1.Button2Click(Sender: TObject);
var
  i, j: integer;
  ch: string;
  nb_total: integer;
  nb_personnes: integer;
  q: array [ord('a') .. ord('z')] of byte;
begin
  nb_total := 0;
  nb_personnes := 0;
  for j := low(q) to high(q) do
    q[j] := 0;
  for i := 0 to Memo1.Lines.Count - 1 do
  begin
    ch := Memo1.Lines[i].Trim;
    if ch.IsEmpty then
    begin
      for j := low(q) to high(q) do
      begin
        if q[j] = nb_personnes then
          inc(nb_total);
        q[j] := 0;
      end;
      nb_personnes := 0;
    end
    else
    begin
      inc(nb_personnes);
      for j := 0 to ch.Length - 1 do
        inc(q[ord(ch.Chars[j])]);
    end;
  end;
  if not ch.IsEmpty then
    // cas où pas de ligne vide après le dernier groupe
    for j := low(q) to high(q) do
    begin
      if q[j] = nb_personnes then
        inc(nb_total);
    end;
  Edit1.Text := nb_total.ToString;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  Memo1.Lines.Clear;
  Edit1.Text := '';
end;

end.
