unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.WinXCtrls, Vcl.StdCtrls;

type
  TForm1 = class(TForm)
    Button1: TButton;
    Label1: TLabel;
    ActivityIndicator1: TActivityIndicator;
    Button2: TButton;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    procedure BeginTraitement;
    procedure EndTraitement;
    { Déclarations privées }
    function JourXXXExercice1: cardinal;
    function JourXXXExercice2: cardinal;
  public
    { Déclarations publiques }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

uses
  System.Math,
  System.IOUtils;

procedure TForm1.Button1Click(Sender: TObject);
begin
  BeginTraitement;
  try
    tthread.CreateAnonymousThread(
      procedure
      begin
        try
          Label1.Caption := JourXXXExercice1.tostring;
        finally
          EndTraitement;
        end;
      end).Start;
  except
    EndTraitement;
  end;
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  BeginTraitement;
  try
    tthread.CreateAnonymousThread(
      procedure
      begin
        try
          Label1.Caption := JourXXXExercice2.tostring;
        finally
          EndTraitement;
        end;
      end).Start;
  except
    EndTraitement;
  end;
end;

procedure TForm1.BeginTraitement;
begin
  Button1.Enabled := false;
  Button2.Enabled := false;
  ActivityIndicator1.animate := true;
end;

procedure TForm1.EndTraitement;
begin
  tthread.Queue(nil,
    procedure
    begin
      ActivityIndicator1.animate := false;
      Button1.Enabled := true;
      Button2.Enabled := true;
    end);
end;

function TForm1.JourXXXExercice1: cardinal;
var
  Lignes: TArray<string>;
  i: integer;
begin
  Lignes := tfile.ReadAllLines('..\..\input.txt');
  result := 0;
  for i := 0 to length(Lignes) - 1 do
  begin
    // result := result + ???;
  end;
end;

function TForm1.JourXXXExercice2: cardinal;
var
  i: integer;
  Lignes: TArray<string>;
begin
  Lignes := tfile.ReadAllLines('..\..\input.txt');
  result := 0;
  for i := 0 to length(Lignes) - 1 do
  begin
    // result := result + ???;
  end;
end;

end.
