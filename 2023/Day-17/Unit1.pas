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
//  CDataFile = '..\..\input.txt';
   CDataFile = '..\..\input-test.txt';

const
  CPoidsMax = maxint - 10;
  // 10 étant le poids maxi d'une case (HeatLoss de 1 à 9)

type
  TCell = record
    HeatLoss: byte;
    PathFindingPoidsCellule: int64;
    PathFindingDejaPasse: boolean;
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
    function TrouveLaFin(X, Y: integer; VX, VY: integer): int64;
    procedure PathFindingSurMap(EndX, EndY: integer);
    procedure DrawMap;
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

uses
  System.Math,
  System.StrUtils,
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
  AddLog('Heat loss :');
  for Lig := 0 to length(Map[0]) - 1 do
  begin
    S := '';
    for Col := 0 to length(Map) - 1 do
      if Map[Col][Lig].PathFindingDejaPasse then
        S := S + '*'
      else
        S := S + Map[Col][Lig].HeatLoss.tostring;
    AddLog(S);
  end;
  AddLog('');
  AddLog('Poids:');
  for Lig := 0 to length(Map[0]) - 1 do
  begin
    S := '';
    for Col := 0 to length(Map) - 1 do
      S := S + ifthen(not S.isempty, ',', '') + Map[Col][Lig]
        .PathFindingPoidsCellule.tostring;
    AddLog(S);
  end;
  AddLog('');
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
begin
  Lignes := tfile.ReadAllLines(CDataFile);

  // Dimensionne la grille
  setlength(Map, length(Lignes[0]));
  for Col := 0 to length(Lignes[0]) - 1 do
    setlength(Map[Col], length(Lignes));

  // Remplit la grille
  for Lig := 0 to length(Lignes) - 1 do
    for Col := 0 to length(Lignes[Lig]) - 1 do
    begin
      Map[Col][Lig].HeatLoss := strtoint(Lignes[Lig].chars[Col]);
      Map[Col][Lig].PathFindingDejaPasse := false;
    end;
  DrawMap;

  Map[0][0].PathFindingDejaPasse := true;

  Result := TrouveLaFin(0, 0, 1, 0);

  DrawMap;
end;

function TForm1.Exercice2: int64;
var
  Lig: integer;
  Lignes: TArray<string>;
begin
  Lignes := tfile.ReadAllLines(CDataFile);
  Result := 0;
  for Lig := 0 to length(Lignes) - 1 do
  begin
    // TODO : à compléter
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
  Result := TimeToStr(dt) + ',' + S;
end;

procedure TForm1.PathFindingSurMap(EndX, EndY: integer);
var
  Col, Lig: integer;
  Modif: boolean;
  a, b, c, d, z: integer;
begin
  // algorithme utilisé : Dijkstra
  // https://fr.wikipedia.org/wiki/Algorithme_de_Dijkstra
  //
  // inspiré de l'exercice 1 du jour 15 de l'AoC 2021

  for Col := 0 to length(Map) - 1 do
    for Lig := 0 to length(Map[Col]) - 1 do
      Map[Col][Lig].PathFindingPoidsCellule := CPoidsMax;

  Map[EndX][EndY].PathFindingPoidsCellule := Map[EndX][EndY].HeatLoss;

  Modif := true;
  while (Modif) do
  begin
    if tthread.checkterminated then
      abort;

    Modif := false;

    for Col := 0 to length(Map) - 1 do
      for Lig := 0 to length(Map[Col]) - 1 do
      begin
        a := CPoidsMax;
        if Lig < length(Map[Col]) - 1 then
          a := Map[Col, Lig + 1].PathFindingPoidsCellule +
            Map[Col, Lig].HeatLoss;
        b := CPoidsMax;
        if Col < length(Map) - 1 then
          b := Map[Col + 1, Lig].PathFindingPoidsCellule +
            Map[Col, Lig].HeatLoss;
        c := CPoidsMax;
        if Lig > 0 then
          c := Map[Col, Lig - 1].PathFindingPoidsCellule +
            Map[Col, Lig].HeatLoss;
        d := CPoidsMax;
        if Col > 0 then
          d := Map[Col - 1, Lig].PathFindingPoidsCellule +
            Map[Col, Lig].HeatLoss;
        z := CPoidsMax;
        if a < z then
          z := a;
        if b < z then
          z := b;
        if c < z then
          z := c;
        if d < z then
          z := d;
        if not((Lig = EndX) and (Col = EndY)) then
        begin
          // On ne touche pas à la case d'arrivée
          Modif := Modif or (Map[Col, Lig].PathFindingPoidsCellule <> z);
          Map[Col, Lig].PathFindingPoidsCellule := z;
        end;
      end;
    // drawmap;
  end;
end;

function TForm1.TrouveLaFin(X, Y: integer; VX, VY: integer): int64;
var
  NbCases: byte;
  EndX, EndY: integer;
  PoidsDevant, PoidsCote1, PoidsCote2: integer;
  NbCol, NbLig: integer;
  VSwap: integer;
begin
  Result := 0;

  NbCol := length(Map);
  NbLig := length(Map[0]);
//  AddLog('Taille : ' + NbCol.tostring + '*' + NbLig.tostring);

  if (X < 0) or (Y < 0) or (X >= NbCol) or (Y >= NbLig) then
    exit;

  EndX := length(Map) - 1;
  EndY := length(Map[0]) - 1;
//  AddLog('Arrivee : ' + EndX.tostring + ',' + EndY.tostring);

  PathFindingSurMap(EndX, EndY);

  NbCases := 0;
  while not((X = EndX) and (Y = EndY)) do
  begin
    if tthread.checkterminated then
      abort;

    if (NbCases < 3) and (X + VX >= 0) and (X + VX < NbCol) and (Y + VY >= 0)
      and (Y + VY < NbLig) and (not Map[X + VX][Y + VY].PathFindingDejaPasse)
    then
      PoidsDevant := Map[X + VX][Y + VY].PathFindingPoidsCellule
    else
      PoidsDevant := CPoidsMax;

    if (X + VY >= 0) and (X + VY < NbCol) and (Y + VX >= 0) and (Y + VX < NbLig)
      and (not Map[X + VY][Y + VX].PathFindingDejaPasse) then
      PoidsCote1 := Map[X + VY][Y + VX].PathFindingPoidsCellule
    else
      PoidsCote1 := CPoidsMax;

    if (X - VY >= 0) and (X - VY < NbCol) and (Y - VX >= 0) and (Y - VX < NbLig)
      and (not Map[X - VY][Y - VX].PathFindingDejaPasse) then
      PoidsCote2 := Map[X - VY][Y - VX].PathFindingPoidsCellule
    else
      PoidsCote2 := CPoidsMax;

    if (PoidsDevant < PoidsCote1) and (PoidsDevant < PoidsCote2) then
      inc(NbCases)
    else if (PoidsCote1 < PoidsDevant) and (PoidsCote1 < PoidsCote2) then
    begin
      VSwap := VX;
      VX := VY;
      VY := VSwap;
      NbCases := 1;
    end
    else if (PoidsCote2 < PoidsDevant) and (PoidsCote2 < PoidsCote1) then
    begin
      VSwap := VX;
      VX := -VY;
      VY := -VSwap;
      NbCases := 1;
    end
    else
      AddLog('plusieurs poids identiques, direction douteuse, penser récursivité');

    X := X + VX;
    Y := Y + VY;
    Result := Result + Map[X][Y].HeatLoss;
    Map[X][Y].PathFindingDejaPasse := true;
    // AddLog(X.tostring + ',' + Y.tostring);
  end;
end;

initialization

{$IFDEF DEBUG}
  ReportMemoryLeaksOnShutdown := true;
{$ENDIF}

end.
