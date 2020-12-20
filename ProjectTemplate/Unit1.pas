unit Unit1;

// My solution for day XXX - https://adventofcode.com/2020/day/XXX
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
  NbResult: integer;
begin
  NbResult := 0;
  // todo : à completer
  Edit1.Text := NbResult.Tostring;
  Edit1.SelectAll;
  Edit1.CopyToClipboard;
end;

procedure TForm1.Button2Click(Sender: TObject);
var
  NbResult: integer;
begin
  NbResult := 0;
  // todo : à completer
  Edit1.Text := NbResult.Tostring;
  Edit1.SelectAll;
  Edit1.CopyToClipboard;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  Memo1.Lines.Clear;
  Edit1.Text := '';
end;

end.
