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
    function Jour2Exercice1: cardinal;
    function Jour2Exercice2: cardinal;
  public
    { Déclarations publiques }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

uses
  System.Math,
  System.RegularExpressions,
  System.IOUtils;

procedure TForm1.Button1Click(Sender: TObject);
begin
  BeginTraitement;
  try
    tthread.CreateAnonymousThread(
      procedure
      begin
        try
          Label1.Caption := Jour2Exercice1.tostring;
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
          Label1.Caption := Jour2Exercice2.tostring;
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

function TForm1.Jour2Exercice1: cardinal;
const
  CNbRedMax = 12;
  CNbGreenMax = 13;
  CNbBlueMax = 14;
var
  Lignes, Tab_Game, Tab_Sets, Tab_Colors: TArray<string>;
  i, j, k: integer;
  NumJeu, nbRed, NbGreen, NbBlue: integer;
  GameOk: boolean;
  s, Color: string;
  nb: integer;
begin
  Lignes := tfile.ReadAllLines('..\..\input.txt');
  result := 0;
  for i := 0 to length(Lignes) - 1 do
  begin
    Tab_Game := Lignes[i].Split([':']);
    NumJeu := Tab_Game[0].trim.Substring('Game '.length).ToInteger;
    Tab_Sets := Tab_Game[1].Split([';']);
    GameOk := true;
    for j := 0 to length(Tab_Sets) - 1 do
    begin
      Tab_Colors := Tab_Sets[j].Split([',']);
      nbRed := 0;
      NbGreen := 0;
      NbBlue := 0;
      for k := 0 to length(Tab_Colors) - 1 do
      begin
        s := Tab_Colors[k].trim;
        Color := s.Substring(s.IndexOf(' ') + 1).tolower;
        nb := s.Substring(0, s.IndexOf(' ')).ToInteger;
        if Color = 'red' then
          nbRed := nbRed + nb
        else if Color = 'green' then
          NbGreen := NbGreen + nb
        else if Color = 'blue' then
          inc(NbBlue, nb);
      end;
      GameOk := (nbRed <= CNbRedMax) and (NbGreen <= CNbGreenMax) and
        (NbBlue <= CNbBlueMax);
      if not GameOk then
        break;
    end;
    if GameOk then
      result := result + NumJeu;
  end;
end;

function TForm1.Jour2Exercice2: cardinal;
var
  Lignes, Tab_Game, Tab_Sets, Tab_Colors: TArray<string>;
  i, j, k: integer;
  nbRed, NbGreen, NbBlue: cardinal;
  s, Color: string;
  nb: integer;
begin
  Lignes := tfile.ReadAllLines('..\..\input.txt');
  result := 0;
  for i := 0 to length(Lignes) - 1 do
  begin
    Tab_Game := Lignes[i].Split([':']);
    Tab_Sets := Tab_Game[1].Split([';']);
    nbRed := 0;
    NbGreen := 0;
    NbBlue := 0;
    for j := 0 to length(Tab_Sets) - 1 do
    begin
      Tab_Colors := Tab_Sets[j].Split([',']);
      for k := 0 to length(Tab_Colors) - 1 do
      begin
        s := Tab_Colors[k].trim;
        Color := s.Substring(s.IndexOf(' ') + 1).tolower;
        nb := s.Substring(0, s.IndexOf(' ')).ToInteger;
        if (Color = 'red') and (nb > nbRed) then
          nbRed := nb
        else if (Color = 'green') and (nb > NbGreen) then
          NbGreen := nb
        else if (Color = 'blue') and (nb > NbBlue) then
          NbBlue := nb;
      end;
    end;
    result := result + nbRed * NbGreen * NbBlue;
  end;
end;

end.
