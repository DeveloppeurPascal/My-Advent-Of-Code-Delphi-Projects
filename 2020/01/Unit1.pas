unit Unit1;
// My solution for https://adventofcode.com/2020/day/1

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls;

type
  TForm1 = class(TForm)
    Memo1: TMemo;
    Button1: TButton;
    Edit1: TEdit;
    Panel1: TPanel;
    Button2: TButton;
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
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
  a, b: int64;
begin
  for i := 0 to Memo1.Lines.Count - 2 do
  begin
    try
      a := Memo1.Lines[i].Trim.ToInt64;
    except
      continue;
    end;
    for j := i + 1 to Memo1.Lines.Count - 1 do
    begin
      try
        b := Memo1.Lines[j].Trim.ToInt64;
      except
        continue;
      end;
      if (a + b = 2020) then
      begin
        Edit1.Text := (a * b).ToString;
        exit;
      end;
    end;
  end;
end;

procedure TForm1.Button2Click(Sender: TObject);
var
  i, j, k: integer;
  a, b, c: int64;
begin
  for i := 0 to Memo1.Lines.Count - 3 do
  begin
    try
      a := Memo1.Lines[i].Trim.ToInt64;
    except
      continue;
    end;
    for j := i + 1 to Memo1.Lines.Count - 2 do
    begin
      try
        b := Memo1.Lines[j].Trim.ToInt64;
      except
        continue;
      end;
      for k := j + 1 to Memo1.Lines.Count - 1 do
      begin
        try
          c := Memo1.Lines[k].Trim.ToInt64;
        except
          continue;
        end;
        if (a + b + c = 2020) then
        begin
          Edit1.Text := (a * b * c).ToString;
          exit;
        end;
      end;
    end;
  end;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  Memo1.Lines.Clear;
  Edit1.Text := '';
end;

end.
