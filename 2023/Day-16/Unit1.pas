unit Unit1;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.WinXCtrls,
  Vcl.StdCtrls,
  System.Generics.Collections;

Const
   CDataFile = '..\..\input.txt';
//  CDataFile = '..\..\input-test.txt';

type
{$SCOPEDENUMS ON}
  TDirection = (Gauche, Droite, Haut, Bas);

  TCell = record
    NbPassage: int64;
    TypeCase: char;
    DejaVenuDepuisGauche, DejaVenuDepuisDroite, DejaVenuDepuisHaut,
      DejaVenuDepuisBas: boolean;
  end;

  TLig = array of TCell;
  TMap = array of TLig;

  TForm1 = class(TForm)
    Button1: TButton;
    ActivityIndicator1: TActivityIndicator;
    Button2: TButton;
    Edit1: TEdit;
    Edit2: TEdit;
    Memo1: TMemo;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    procedure BeginTraitement;
    procedure EndTraitement;
    { Déclarations privées }
    function Exercice1: int64;
    function Exercice2: int64;
    procedure AddLog(Const S: String);
    function MsToTimeString(ms: int64): string;
  public
    { Déclarations publiques }
    Map: TMap;
    procedure EmetRayon(x, y: integer; Dir: TDirection);
    procedure DrawMap;
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

uses
  System.Math,
  System.DateUtils,
  System.RegularExpressions,
  System.Generics.Defaults,
  System.Diagnostics,
  System.IOUtils;

procedure TForm1.Button1Click(Sender: TObject);
begin
  BeginTraitement;
  Edit1.Text := 'Calcul en cours';
  try
    tthread.CreateAnonymousThread(
      procedure
      var
        time: TStopwatch;
      begin
        try
          try
            time.Start;
            try
              Edit1.Text := Exercice1.tostring;
            finally
              time.Stop;
              AddLog('Result : ' + Edit1.Text);
              AddLog('Elapsed time : ' +
                MsToTimeString(time.ElapsedMilliseconds));
            end;
            Edit1.SelectAll;
            Edit1.CopyToClipboard;
          finally
            EndTraitement;
          end;
          ShowMessage(Edit1.Text + ' copié dans le presse papier.');
        except
          Edit1.Text := 'Erreur';
        end;
      end).Start;
  except
    EndTraitement;
    Edit1.Text := 'Erreur';
  end;
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  BeginTraitement;
  Edit2.Text := 'Calcul en cours';
  try
    tthread.CreateAnonymousThread(
      procedure
      var
        time: TStopwatch;
      begin
        try
          try
            time.Start;
            try
              Edit2.Text := Exercice2.tostring;
            finally
              time.Stop;
              AddLog('Result : ' + Edit2.Text);
              AddLog('Elapsed time : ' +
                MsToTimeString(time.ElapsedMilliseconds));
            end;
            Edit2.SelectAll;
            Edit2.CopyToClipboard;
          finally
            EndTraitement;
          end;
          ShowMessage(Edit2.Text + ' copié dans le presse papier.');
        except
          Edit2.Text := 'Erreur';
        end;
      end).Start;
  except
    EndTraitement;
    Edit2.Text := 'Erreur';
  end;
end;

procedure TForm1.DrawMap;
var
  Col, Lig: integer;
  S: string;
begin
  for Lig := 0 to length(Map[0]) - 1 do
  begin
    S := '';
    for Col := 0 to length(Map) - 1 do
      if Map[Col][Lig].NbPassage > 0 then
        S := S + '*'
      else
        S := S + Map[Col][Lig].TypeCase;
    AddLog(S);
  end;
end;

procedure TForm1.AddLog(const S: String);
begin
  tthread.Synchronize(nil,
    procedure
    begin
      Memo1.Lines.Add(S);
    end);
end;

procedure TForm1.BeginTraitement;
begin
  Button1.Enabled := false;
  Button2.Enabled := false;
  ActivityIndicator1.animate := true;
end;

procedure TForm1.EmetRayon(x, y: integer; Dir: TDirection);
var
  NewX, NewY: integer;
begin
  while true do
  begin
    if tthread.checkterminated then
      exit;

    case Dir of
      TDirection.Gauche:
        begin
          NewX := x - 1;
          NewY := y;
        end;
      TDirection.Droite:
        begin
          NewX := x + 1;
          NewY := y;
        end;
      TDirection.Haut:
        begin
          NewX := x;
          NewY := y - 1;
        end;
      TDirection.Bas:
        begin
          NewX := x;
          NewY := y + 1;
        end;
    end;

    if (NewX < 0) or (NewX >= length(Map)) or (NewY < 0) or
      (NewY >= length(Map[NewX])) then
      exit;

    Map[NewX, NewY].NbPassage := Map[NewX, NewY].NbPassage + 1;
    x := NewX;
    y := NewY;

    case Map[NewX, NewY].TypeCase of
      '-':
        case Dir of
          TDirection.Haut:
            begin
              if Map[NewX][NewY].DejaVenuDepuisBas then
                exit
              else
                Map[NewX][NewY].DejaVenuDepuisBas := true;
              EmetRayon(NewX, NewY, TDirection.Droite);
              Dir := TDirection.Gauche;
            end;
          TDirection.Bas:
            begin
              if Map[NewX][NewY].DejaVenuDepuisHaut then
                exit
              else
                Map[NewX][NewY].DejaVenuDepuisHaut := true;
              EmetRayon(NewX, NewY, TDirection.Droite);
              Dir := TDirection.Gauche;
            end;
        end;
      '|':
        case Dir of
          TDirection.Gauche:
            begin
              if Map[NewX][NewY].DejaVenuDepuisDroite then
                exit
              else
                Map[NewX][NewY].DejaVenuDepuisDroite := true;
              EmetRayon(NewX, NewY, TDirection.Haut);
              Dir := TDirection.Bas;
            end;
          TDirection.Droite:
            begin
              if Map[NewX][NewY].DejaVenuDepuisGauche then
                exit
              else
                Map[NewX][NewY].DejaVenuDepuisGauche := true;
              EmetRayon(NewX, NewY, TDirection.Haut);
              Dir := TDirection.Bas;
            end;
        end;
      '/':
        case Dir of
          TDirection.Gauche:
            if Map[NewX][NewY].DejaVenuDepuisDroite then
              exit
            else
            begin
              Map[NewX][NewY].DejaVenuDepuisDroite := true;
              Dir := TDirection.Bas;
            end;
          TDirection.Droite:
            if Map[NewX][NewY].DejaVenuDepuisGauche then
              exit
            else
            begin
              Map[NewX][NewY].DejaVenuDepuisGauche := true;
              Dir := TDirection.Haut;
            end;
          TDirection.Haut:
            if Map[NewX][NewY].DejaVenuDepuisBas then
              exit
            else
            begin
              Map[NewX][NewY].DejaVenuDepuisBas := true;
              Dir := TDirection.Droite;
            end;
          TDirection.Bas:
            if Map[NewX][NewY].DejaVenuDepuisHaut then
              exit
            else
            begin
              Map[NewX][NewY].DejaVenuDepuisHaut := true;
              Dir := TDirection.Gauche;
            end;
        end;
      '\':
        case Dir of
          TDirection.Gauche:
            if Map[NewX][NewY].DejaVenuDepuisDroite then
              exit
            else
            begin
              Map[NewX][NewY].DejaVenuDepuisDroite := true;
              Dir := TDirection.Haut;
            end;
          TDirection.Droite:
            if Map[NewX][NewY].DejaVenuDepuisGauche then
              exit
            else
            begin
              Map[NewX][NewY].DejaVenuDepuisGauche := true;
              Dir := TDirection.Bas;
            end;
          TDirection.Haut:
            if Map[NewX][NewY].DejaVenuDepuisBas then
              exit
            else
            begin
              Map[NewX][NewY].DejaVenuDepuisBas := true;
              Dir := TDirection.Gauche;
            end;
          TDirection.Bas:
            if Map[NewX][NewY].DejaVenuDepuisHaut then
              exit
            else
            begin
              Map[NewX][NewY].DejaVenuDepuisHaut := true;
              Dir := TDirection.Droite;
            end;
        end;
    end;
  end;
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

function TForm1.Exercice1: int64;
var
  Col, Lig: integer;
  Lignes: TArray<string>;
  NbLigCol: integer;
begin
  Lignes := tfile.ReadAllLines(CDataFile);

  // Dimensionne la grille
  NbLigCol := length(Lignes);
  setlength(Map, NbLigCol);
  for Col := 0 to NbLigCol - 1 do
    setlength(Map[Col], NbLigCol);

  // Remplit la grille
  for Lig := 0 to length(Lignes) - 1 do
    for Col := 0 to length(Lignes[Lig]) - 1 do
    begin
      Map[Col][Lig].NbPassage := 0;
      Map[Col][Lig].TypeCase := Lignes[Lig].chars[Col];
      Map[Col][Lig].DejaVenuDepuisGauche := false;
      Map[Col][Lig].DejaVenuDepuisDroite := false;
      Map[Col][Lig].DejaVenuDepuisHaut := false;
      Map[Col][Lig].DejaVenuDepuisBas := false;
    end;

  // DrawMap;

  // Traite le tir de rayon (et ses séparations éventuelles)
  EmetRayon(-1, 0, TDirection.Droite);

  // DrawMap;

  // Calcul le nombre de cases touchées
  result := 0;
  for Col := 0 to length(Map) - 1 do
    for Lig := 0 to length(Map[Col]) - 1 do
      if Map[Col][Lig].NbPassage > 0 then
        inc(result);
end;

function TForm1.Exercice2: int64;
var
  Lignes: TArray<string>;
  NbLigCol: integer;
  CurrentResult: int64;
  i: integer;

  function Teste(StartX, StartY: integer; Dir: TDirection): int64;
  var
    Col, Lig: integer;

  begin
    // Remplit la grille
    for Lig := 0 to length(Lignes) - 1 do
      for Col := 0 to length(Lignes[Lig]) - 1 do
      begin
        Map[Col][Lig].NbPassage := 0;
        Map[Col][Lig].TypeCase := Lignes[Lig].chars[Col];
        Map[Col][Lig].DejaVenuDepuisGauche := false;
        Map[Col][Lig].DejaVenuDepuisDroite := false;
        Map[Col][Lig].DejaVenuDepuisHaut := false;
        Map[Col][Lig].DejaVenuDepuisBas := false;
      end;

    // DrawMap;

    // Traite le tir de rayon (et ses séparations éventuelles)
    EmetRayon(StartX, StartY, Dir);

    // DrawMap;

    // Calcul le nombre de cases touchées
    result := 0;
    for Col := 0 to length(Map) - 1 do
      for Lig := 0 to length(Map[Col]) - 1 do
        if Map[Col][Lig].NbPassage > 0 then
          inc(result);
  end;

begin
  Lignes := tfile.ReadAllLines(CDataFile);

  // Dimensionne la grille
  NbLigCol := length(Lignes);
  setlength(Map, NbLigCol);
  for i := 0 to NbLigCol - 1 do
    setlength(Map[i], NbLigCol);

  result := 0;
  for i := 0 to length(Map) - 1 do
  begin
    CurrentResult := Teste(-1, i, TDirection.Droite);
    if CurrentResult > result then
      result := CurrentResult;
    CurrentResult := Teste(length(Map), i, TDirection.Gauche);
    if CurrentResult > result then
      result := CurrentResult;
    CurrentResult := Teste(i, -1, TDirection.Bas);
    if CurrentResult > result then
      result := CurrentResult;
    CurrentResult := Teste(i, length(Map), TDirection.Haut);
    if CurrentResult > result then
      result := CurrentResult;
  end;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  Edit1.Text := '';
  Edit2.Text := '';
  Memo1.Clear;
end;

function TForm1.MsToTimeString(ms: int64): string;
var
  dt: TDatetime;
  S: string;
begin
  dt := 0;
  dt.addMilliSecond(ms);
  S := dt.GetMilliSecond.tostring;
  while length(S) < 3 do
    S := '0' + S;
  result := TimeToStr(dt) + ',' + S;
end;

initialization

{$IFDEF DEBUG}
  ReportMemoryLeaksOnShutdown := true;
{$ENDIF}

end.
