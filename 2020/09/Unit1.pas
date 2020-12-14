unit Unit1;

// My solution for day 9 - https://adventofcode.com/2020/day/9
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

type
  tliste = array [0 .. 24] of LongInt;

procedure TForm1.Button1Click(Sender: TObject);
var
  i, j, k: integer;
  previous: tliste;
  actual: LongInt;
  ok: boolean;
begin
  for i := 0 to Memo1.Lines.Count - 1 do
  begin
    actual := Memo1.Lines[i].ToInteger;
    // calcul
    if (i >= 25) then
    begin
      ok := false;
      for j := 0 to 23 do
      begin
        for k := j + 1 to 24 do
        begin
          ok := (previous[j] + previous[k] = actual) and
            (previous[j] <> previous[k]);
          if ok then
            break;
        end;
        if ok then
          break;
      end;
      if not ok then
        break;
    end;
    // rotation
    for j := 0 to 23 do
      previous[j] := previous[j + 1];
    previous[24] := actual;
  end;
  Edit1.Text := actual.ToString;
end;

procedure TForm1.Button2Click(Sender: TObject);
var
  i, j, k: integer;
  previous: tliste;
  actual: LongInt;
  actual_i: integer;
  ok: boolean;
  smallest, largest: LongInt;
  total: LongInt;
  value: LongInt;
begin
  for i := 0 to Memo1.Lines.Count - 1 do
  begin
    actual := Memo1.Lines[i].ToInteger;
    // calcul
    if (i >= 25) then
    begin
      ok := false;
      for j := 0 to 23 do
      begin
        for k := j + 1 to 24 do
        begin
          ok := (previous[j] + previous[k] = actual) and
            (previous[j] <> previous[k]);
          if ok then
            break;
        end;
        if ok then
          break;
      end;
      if not ok then
      begin
        actual_i := i;
        break;
      end;
    end;
    // rotation
    for j := 0 to 23 do
      previous[j] := previous[j + 1];
    previous[24] := actual;
  end;
  // actual is the weakness
  for i := 0 to actual_i - 1 do
  begin
    total := Memo1.Lines[i].ToInteger;
    smallest := total;
    largest := total;
    for j := i + 1 to actual_i - 1 do
    begin
      value := Memo1.Lines[j].ToInteger;
      total := total + value;
      if total <= actual then
      begin
        if (value < smallest) then
          smallest := value
        else if (value > largest) then
          largest := value;
        if (total = actual) then
          break;
      end
      else
        break;
    end;
    if (total = actual) then
      break;
  end;
  Edit1.Text := (largest + smallest).ToString;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  Memo1.Lines.Clear;
  Edit1.Text := '';
end;

end.
