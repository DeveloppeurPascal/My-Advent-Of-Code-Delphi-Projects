unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, System.Generics.Collections,
  System.Generics.Defaults,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls;

type
  TForm1 = class(TForm, IComparer<uint64>)
    Memo1: TMemo;
    procedure FormShow(Sender: TObject);
  private
    { Déclarations privées }
    FichierOuvert: string;
    Fichier: Text;
    function getLigne(NomFichier: string): string;
    function FinDeFichier: boolean;
    procedure FermeFichier;
    procedure OuvreFichier(NomFichier: string);
    procedure AfficheResultat(Jour, Exercice: byte; Reponse: uint64);
    function BinToInt64(Bin: string): int64;
  public
    { Déclarations publiques }
    procedure Jour01_1;
    procedure Jour01_2;
    procedure Jour02_1;
    procedure Jour02_2;
    procedure Jour03_1;
    procedure Jour03_2;
    procedure Jour04_1;
    procedure Jour04_2;
    procedure Jour05_1;
    procedure Jour05_2;
    procedure Jour06_1;
    procedure Jour06_2;
    procedure Jour07_1;
    procedure Jour07_2;
    procedure Jour08_1;
    procedure Jour08_2;
    procedure Jour09_1;
    procedure Jour09_1_bis;
    procedure Jour09_2;
    procedure Jour10_1;
    procedure Jour10_2;
    procedure Jour11_1;
    procedure Jour11_2;
    procedure Jour12_1;
    procedure Jour12_1_bis;
    procedure Jour12_2;
    procedure Jour12_2_bis;
    procedure Jour13_1;
    procedure Jour13_2;
    procedure Jour14_1;
    procedure Jour14_2;
    procedure Jour15_1;
    procedure Jour15_2;
    procedure TemplateJour;

    function Compare(const Left, Right: uint64): Integer;
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

Uses
  System.RegularExpressions, System.IOUtils, System.threading,
  System.Diagnostics;

procedure TForm1.AfficheResultat(Jour, Exercice: byte; Reponse: uint64);
begin
  Memo1.Lines.Add('Jour ' + Jour.ToString + ' Exercice ' + Exercice.ToString +
    ' Reponse ' + Reponse.ToString);
end;

function TForm1.BinToInt64(Bin: string): int64;
var
  i: Integer;
begin
  result := 0;
  for i := 0 to Bin.Length - 1 do
    if (Bin.Chars[i] = '0') then
      result := result * 2
    else
      result := result * 2 + 1;
end;

function TForm1.Compare(const Left, Right: uint64): Integer;
begin
  if Left < Right then
    result := -1
  else if Left > Right then
    result := 1
  else
    result := 0;
end;

procedure TForm1.FermeFichier;
begin
  if not FichierOuvert.IsEmpty then
  begin
    closefile(Fichier);
    FichierOuvert := '';
  end;
end;

function TForm1.FinDeFichier: boolean;
begin
  result := (FichierOuvert = '') or eof(Fichier);
end;

procedure TForm1.FormShow(Sender: TObject);
begin
  Memo1.Lines.Clear;
  // https://adventofcode.com/2021/day/1
  // Jour01_1;
  // Jour01_2;

  // https://adventofcode.com/2021/day/2
  // Jour02_1;
  // Jour02_2;

  // https://adventofcode.com/2021/day/3
  // Jour03_1;
  // Jour03_2;

  // https://adventofcode.com/2021/day/4
  // Jour04_1;
  // Jour04_2;

  // https://adventofcode.com/2021/day/5
  // Jour05_1;
  // Jour05_2;

  // https://adventofcode.com/2021/day/6
  // Jour06_1;
  // Jour06_2;

  // https://adventofcode.com/2021/day/7
  // Jour07_1;
  // Jour07_2;

  // https://adventofcode.com/2021/day/8
  // Jour08_1;
  // Jour08_2;

  // https://adventofcode.com/2021/day/9
  // Jour09_1;
  // Jour09_1_bis;
  // Jour09_2;

  // https://adventofcode.com/2021/day/10
  // Jour10_1;
  // Jour10_2;

  // https://adventofcode.com/2021/day/11
  // Jour11_1; // trop long pour le faire systématiquement
  // Jour11_2; // TODO : voir comment l'optimiser (exemple : le faire une fois pour les 2 exercices)

  // https://adventofcode.com/2021/day/12
  // version avec chaînes de caractères
  // Jour12_1;
  // Jour12_2;

  // version un peu optimisée avec des entiers au lieu des chaines de caractères
  // Jour12_1_bis;
  // Jour12_2_bis;

  // https://adventofcode.com/2021/day/13
  // Jour13_1;
  // Jour13_2;

  // https://adventofcode.com/2021/day/14
  // Jour14_1;
  // Jour14_2;

  // https://adventofcode.com/2021/day/15
  Jour15_1;
  Jour15_2;
end;

function TForm1.getLigne(NomFichier: string): string;
begin
  if (NomFichier <> FichierOuvert) then
    OuvreFichier(NomFichier);
  if (not FinDeFichier) then
    readln(Fichier, result)
  else
    result := '';
  result := result.Trim;
end;

procedure TForm1.Jour01_1;
var
  PremiereLigneTraitee: boolean;
  Valeur_Ligne: word;
  Ligne: string;
  Valeur_Precedente: word;
  Nb_Increments: int64;
begin
  PremiereLigneTraitee := false;
  Valeur_Precedente := 0;
  Nb_Increments := 0;
  repeat
    Ligne := getLigne('..\..\input-01.txt');
    try
      Valeur_Ligne := Ligne.ToInteger;
      if PremiereLigneTraitee then
      begin
        if Valeur_Ligne > Valeur_Precedente then
          inc(Nb_Increments);
        Valeur_Precedente := Valeur_Ligne;
      end
      else
      begin
        Valeur_Precedente := Valeur_Ligne;
        PremiereLigneTraitee := true;
      end;
    except

    end;
  until FinDeFichier;
  FermeFichier;
  AfficheResultat(1, 1, Nb_Increments);
end;

procedure TForm1.Jour01_2;
var
  TroisPremieresLignesTraitees: boolean;
  Valeur_Ligne: word;
  Ligne: string;
  Valeur_1, Valeur_2: word;
  Nb_Increments: int64;
  Tab_Valeurs: array [0 .. 2] of word;
  Num_Ligne: int64;
begin
  TroisPremieresLignesTraitees := false;
  Valeur_1 := 0;
  Valeur_2 := 0;
  Nb_Increments := 0;
  Num_Ligne := 0;
  Tab_Valeurs[0] := 0;
  Tab_Valeurs[1] := 0;
  Tab_Valeurs[2] := 0;
  repeat
    Ligne := getLigne('..\..\input-01.txt');
    try
      Valeur_Ligne := Ligne.ToInteger;
      // On fait le cumul avec les valeurs existantes avant comparaison
      case Num_Ligne mod 3 of
        0:
          begin
            inc(Tab_Valeurs[1], Valeur_Ligne);
            inc(Tab_Valeurs[2], Valeur_Ligne);
          end;
        1:
          begin
            inc(Tab_Valeurs[0], Valeur_Ligne);
            inc(Tab_Valeurs[2], Valeur_Ligne);
          end;
        2:
          begin
            inc(Tab_Valeurs[0], Valeur_Ligne);
            inc(Tab_Valeurs[1], Valeur_Ligne);
          end;
      end;
      // Comparaison des valeurs à partir de la quatrième ligne remplie
      if TroisPremieresLignesTraitees then
      begin
        case Num_Ligne mod 3 of
          0:
            begin
              Valeur_1 := Tab_Valeurs[0];
              Valeur_2 := Tab_Valeurs[1];
            end;
          1:
            begin
              Valeur_1 := Tab_Valeurs[1];
              Valeur_2 := Tab_Valeurs[2];
            end;
          2:
            begin
              Valeur_1 := Tab_Valeurs[2];
              Valeur_2 := Tab_Valeurs[0];
            end;
        end;
        if Valeur_2 > Valeur_1 then
          inc(Nb_Increments);
      end
      else if (Num_Ligne = 2) then
        TroisPremieresLignesTraitees := true;
      // On initialise la valeur de la ligne en cours pour partir sur un nouveau cycle de 3 lignes
      Tab_Valeurs[Num_Ligne mod 3] := Valeur_Ligne;
      // Passage à la ligne suivante
      inc(Num_Ligne);
    except

    end;
  until FinDeFichier;
  FermeFichier;
  AfficheResultat(1, 1, Nb_Increments);
end;

procedure TForm1.Jour02_1;
var
  Ligne: string;
  Valeur_Ligne: word;
  Tab: tarray<string>;
  Operation: string;
  Profondeur: int64;
  DistanceParcourrue: int64;
begin
  Profondeur := 0;
  DistanceParcourrue := 0;
  repeat
    Ligne := getLigne('..\..\input-02.txt');
    try
      Tab := Ligne.Trim.Split([' ']);
      if (Length(Tab) = 2) then
      begin
        Valeur_Ligne := Tab[1].ToInteger;
        Operation := Tab[0].ToLower;
        if (Operation = 'up') then
          dec(Profondeur, Valeur_Ligne)
        else if (Operation = 'down') then
          inc(Profondeur, Valeur_Ligne)
        else if (Operation = 'forward') then
          inc(DistanceParcourrue, Valeur_Ligne);
      end;
    except

    end;
  until FinDeFichier;
  FermeFichier;
  AfficheResultat(2, 1, Profondeur * DistanceParcourrue);
end;

procedure TForm1.Jour02_2;
var
  Ligne: string;
  Valeur_Ligne: word;
  Tab: tarray<string>;
  Operation: string;
  Profondeur: int64;
  Objectif: int64;
  DistanceParcourrue: int64;
begin
  Profondeur := 0;
  Objectif := 0;
  DistanceParcourrue := 0;
  repeat
    Ligne := getLigne('..\..\input-02.txt');
    try
      Tab := Ligne.Trim.Split([' ']);
      if (Length(Tab) = 2) then
      begin
        Valeur_Ligne := Tab[1].ToInteger;
        Operation := Tab[0].ToLower;
        if (Operation = 'up') then
          dec(Objectif, Valeur_Ligne)
        else if (Operation = 'down') then
          inc(Objectif, Valeur_Ligne)
        else if (Operation = 'forward') then
        begin
          inc(DistanceParcourrue, Valeur_Ligne);
          inc(Profondeur, Valeur_Ligne * Objectif);
        end;
      end;
    except

    end;
  until FinDeFichier;
  FermeFichier;
  AfficheResultat(2, 2, Profondeur * DistanceParcourrue);
end;

procedure TForm1.Jour03_1;
type
  TTabBin = array [0 .. 1] of int64;
var
  Ligne: string;
  GammaRate: Integer;
  // composé par les bits les plus présents dans chaque colonne du fichier
  EpsilonRate: Integer;
  // composé par les bits les moins présents dans chaque colonne du fichier
  Tab: array of TTabBin; // Nombre d'occurrence de 0/1 par colonne
  PremiereLigne: boolean;
  i: Integer;
begin
  PremiereLigne := true;
  repeat
    Ligne := getLigne('..\..\input-03.txt');
    if (Ligne.Length > 0) then
      try
        if PremiereLigne then
        begin
          setlength(Tab, Ligne.Length);
          for i := 0 to Length(Tab) - 1 do
          begin
            Tab[i][0] := 0;
            Tab[i][1] := 0;
          end;
          PremiereLigne := false;
        end;
        for i := 0 to Length(Tab) - 1 do
          if (Ligne.Chars[i] = '0') then
            inc(Tab[i][0])
          else
            inc(Tab[i][1]);
      except

      end;
  until FinDeFichier;
  GammaRate := 0;
  EpsilonRate := 0;
  for i := 0 to Length(Tab) - 1 do
    if (Tab[i][1] > Tab[i][0]) then
    begin
      GammaRate := GammaRate * 2 + 1;
      EpsilonRate := EpsilonRate * 2 + 0;
    end
    else
    begin
      GammaRate := GammaRate * 2 + 0;
      EpsilonRate := EpsilonRate * 2 + 1;
    end;
  FermeFichier;
  AfficheResultat(3, 1, GammaRate * EpsilonRate);
end;

procedure TForm1.Jour03_2;
var
  Ligne: string;
  NumColonne, NbColonnes: byte;
  Nb0_Oxy, Nb1_Oxy: int64;
  Oxygene_Bin: string;
  Nb0_CO2, Nb1_CO2: int64;
  CO2_Bin: string;
  PremiereLigne: boolean;
begin
  PremiereLigne := true;
  NbColonnes := 0;
  NumColonne := 0;
  Oxygene_Bin := '';
  CO2_Bin := '';
  repeat
    Nb0_Oxy := 0;
    Nb1_Oxy := 0;
    Nb0_CO2 := 0;
    Nb1_CO2 := 0;
    repeat
      Ligne := getLigne('..\..\input-03.txt');
      if (Ligne.Length > 0) then
        try
          if PremiereLigne then
          begin
            PremiereLigne := false;
            NbColonnes := Ligne.Length;
          end;
          if (Oxygene_Bin.IsEmpty or (Ligne.StartsWith(Oxygene_Bin))) then
            if (Ligne.Chars[NumColonne] = '0') then
              inc(Nb0_Oxy)
            else
              inc(Nb1_Oxy);
          if (CO2_Bin.IsEmpty or (Ligne.StartsWith(CO2_Bin))) then
            if (Ligne.Chars[NumColonne] = '0') then
              inc(Nb0_CO2)
            else
              inc(Nb1_CO2);
        except

        end;
    until FinDeFichier;
    FermeFichier;
    if (Nb1_Oxy >= Nb0_Oxy) then
      Oxygene_Bin := Oxygene_Bin + '1'
    else
      Oxygene_Bin := Oxygene_Bin + '0';
    if ((Nb0_CO2 <= Nb1_CO2) and (Nb0_CO2 > 0)) or (Nb1_CO2 = 0) then
      CO2_Bin := CO2_Bin + '0'
    else
      CO2_Bin := CO2_Bin + '1';
    inc(NumColonne);
  until (NumColonne >= NbColonnes);
  AfficheResultat(3, 2, BinToInt64(Oxygene_Bin) * BinToInt64(CO2_Bin));
end;

// Types utilisés pour le Jour 4 : Bingo
type
  TJ4_Case = class
  public
    FNumero: Integer;
    FTire: boolean;
    constructor Create(ANumero: Integer);
  end;

  TJ4_Grille = array [1 .. 5, 1 .. 5] of TJ4_Case;

  TJ4_Carte = class
  public
    FGrille: TJ4_Grille;
    FGagnante: boolean;
    procedure Numero(ACol, ALig, ANumero: Integer); overload;
    function Numero(ACol, ALig: Integer): Integer; overload;
    function isLigneFinie(ALig: Integer): boolean;
    function isColonneFinie(ACol: Integer): boolean;
    function isGrilleGagnanteAvecNumero(ANumero: Integer): boolean;
    function TotalNumerosNonTires: Integer;
    constructor Create;
    destructor Destroy; override;
  end;

  TJ4_ListeDeCartes = class(TObjectList<TJ4_Carte>)
  public

  end;

procedure TForm1.Jour04_1;
var
  PremiereLigneTraitee: boolean;
  Ligne: string;
  sListeNumeros: string;
  numCol, NumLig, Numero: Integer;
  Board: TJ4_Carte;
  ListeCartes: TJ4_ListeDeCartes;
  NumeroTire: Integer;
  i: Integer;
begin
  // Lecture des données et remplissage
  ListeCartes := TJ4_ListeDeCartes.Create;
  try
    PremiereLigneTraitee := false;
    repeat
      Ligne := getLigne('..\..\input-04.txt');
      try
        if PremiereLigneTraitee then
        begin // charge les cartes de jeu
          if Ligne.IsEmpty then
          begin
            NumLig := 0;
            Board := TJ4_Carte.Create;
            ListeCartes.Add(Board);
          end
          else
          begin // Charge première ligne = numéros tirés
            Ligne := Ligne.Replace('  ', ' ');
            var
            Tab := Ligne.Split([' ']);
            if (Length(Tab) <> 5) then
              raise exception.Create('erreur : ' + Ligne);
            for numCol := 0 to 4 do
              Board.Numero(numCol + 1, NumLig + 1, Tab[numCol].Trim.ToInteger);
            inc(NumLig);
          end;
        end
        else
        begin // première ligne = numeros tirés
          PremiereLigneTraitee := true;
          sListeNumeros := Ligne;
        end;
      except

      end;
    until FinDeFichier;
    FermeFichier;

    // Tirage des numéros
    var
    Tab := sListeNumeros.Split([',']);
    var
    FinTirage := false;
    for i := 0 to Length(Tab) - 1 do
    begin
      NumeroTire := Tab[i].Trim.ToInteger;
      if (ListeCartes.Count > 0) then
        for Board in ListeCartes do
          if Board.isGrilleGagnanteAvecNumero(NumeroTire) then
          begin
            AfficheResultat(4, 1, NumeroTire * Board.TotalNumerosNonTires);
            FinTirage := true;
            break;
          end;
      if FinTirage then
        break;
    end;
  finally
    ListeCartes.Free;
  end;
end;

procedure TForm1.Jour04_2;
var
  PremiereLigneTraitee: boolean;
  Ligne: string;
  sListeNumeros: string;
  numCol, NumLig, Numero: Integer;
  Board, DerniereGrilleGagnante: TJ4_Carte;
  ListeCartes: TJ4_ListeDeCartes;
  NumeroTire, DernierNumeroTire: Integer;
  i: Integer;
begin
  // Lecture des données et remplissage
  ListeCartes := TJ4_ListeDeCartes.Create;
  try
    PremiereLigneTraitee := false;
    repeat
      Ligne := getLigne('..\..\input-04.txt');
      try
        if PremiereLigneTraitee then
        begin // charge les cartes de jeu
          if Ligne.IsEmpty then
          begin
            NumLig := 0;
            Board := TJ4_Carte.Create;
            ListeCartes.Add(Board);
          end
          else
          begin // Charge première ligne = numéros tirés
            Ligne := Ligne.Replace('  ', ' ');
            var
            Tab := Ligne.Split([' ']);
            if (Length(Tab) <> 5) then
              raise exception.Create('erreur : ' + Ligne);
            for numCol := 0 to 4 do
              Board.Numero(numCol + 1, NumLig + 1, Tab[numCol].Trim.ToInteger);
            inc(NumLig);
          end;
        end
        else
        begin // première ligne = numeros tirés
          PremiereLigneTraitee := true;
          sListeNumeros := Ligne;
        end;
      except

      end;
    until FinDeFichier;
    FermeFichier;

    // Tirage des numéros
    DerniereGrilleGagnante := nil;
    var
    Tab := sListeNumeros.Split([',']);
    var
    FinTirage := false;
    for i := 0 to Length(Tab) - 1 do
    begin
      NumeroTire := Tab[i].Trim.ToInteger;
      if (ListeCartes.Count > 0) then
        for Board in ListeCartes do
          if (not Board.FGagnante) and Board.isGrilleGagnanteAvecNumero
            (NumeroTire) then
          begin
            DernierNumeroTire := NumeroTire;
            DerniereGrilleGagnante := Board;
          end;
    end;
    if DerniereGrilleGagnante <> nil then
      AfficheResultat(4, 2, DernierNumeroTire *
        DerniereGrilleGagnante.TotalNumerosNonTires);
  finally
    ListeCartes.Free;
  end;
end;

// Types utilisés pour le Jour 5
type
  TJ5_Y = TDictionary<Integer, Integer>; // Y en clé, nb en valeur

  TJ5_X = class(TObjectDictionary<Integer, TJ5_Y>) // X en clé, (Y,nb) en valeur
  public
    procedure incremente(x, y: Integer);
    function getValeur(x, y: Integer): Integer;
  end;

procedure TForm1.Jour05_1;
Const
  CNumeroFichier = '05'; // 2 chiffres, en alpha
  CJour = 5; // Numéro du jour
  CExercice = 1; // Numéro exercice
var
  Ligne: string;
  Reponse: uint64;
  Map: TJ5_X;
  RegMatch: TMatchCollection;
  x1, y1, x2, y2: Integer;
  x, y: Integer;
begin
  Map := TJ5_X.Create;
  try
    repeat
      Ligne := getLigne('..\..\input-' + CNumeroFichier + '.txt');
      try
        if not Ligne.IsEmpty then
        begin // /([0-9]+),([0-9]+) -> ([0-9]+),([0-9]+)/gm
          RegMatch := tregex.matches(Ligne,
            '^([0-9]+),([0-9]+) -> ([0-9]+),([0-9]+)$');
          if (RegMatch.Count = 1) and (RegMatch[0].groups.Count = 5) then
          begin
            x1 := RegMatch[0].groups[1].Value.ToInteger;
            y1 := RegMatch[0].groups[2].Value.ToInteger;
            x2 := RegMatch[0].groups[3].Value.ToInteger;
            y2 := RegMatch[0].groups[4].Value.ToInteger;
            if (x1 = x2) or (y1 = y2) then
            begin
              if (x1 < x2) then
              begin
                for x := x1 to x2 do
                  if (y1 < y2) then
                    for y := y1 to y2 do
                      Map.incremente(x, y)
                  else
                    for y := y1 downto y2 do
                      Map.incremente(x, y);
              end
              else
              begin
                for x := x1 downto x2 do
                  if (y1 < y2) then
                    for y := y1 to y2 do
                      Map.incremente(x, y)
                  else
                    for y := y1 downto y2 do
                      Map.incremente(x, y);
              end;
            end;
          end;
          // x1 := tregex.Replace(Ligne,
          // '^([0-9]+),([0-9]+) -> ([0-9]+),([0-9]+)$', '$1').ToInteger;
          // y1 := tregex.Replace(Ligne,
          // '^([0-9]+),([0-9]+) -> ([0-9]+),([0-9]+)$', '$2').ToInteger;
          // x2 := tregex.Replace(Ligne,
          // '^([0-9]+),([0-9]+) -> ([0-9]+),([0-9]+)$', '$3').ToInteger;
          // y2 := tregex.Replace(Ligne,
          // '^([0-9]+),([0-9]+) -> ([0-9]+),([0-9]+)$', '$4').ToInteger;
        end;
      except

      end;
    until FinDeFichier;
    FermeFichier;
    Reponse := 0;
    for x in Map.keys do
      for y in Map.items[x].keys do
        if (Map.getValeur(x, y) > 1) then
          Reponse := Reponse + 1;
    AfficheResultat(CJour, CExercice, Reponse);
  finally
    Map.Free;
  end;
end;

procedure TForm1.Jour05_2;
Const
  CNumeroFichier = '05'; // 2 chiffres, en alpha
  CJour = 5; // Numéro du jour
  CExercice = 2; // Numéro exercice
var
  Ligne: string;
  Reponse: uint64;
  Map: TJ5_X;
  RegMatch: TMatchCollection;
  x1, y1, x2, y2: Integer;
  x, y: Integer;
  ix, iy: Integer;
begin
  Map := TJ5_X.Create;
  try
    repeat
      Ligne := getLigne('..\..\input-' + CNumeroFichier + '.txt');
      try
        if not Ligne.IsEmpty then
        begin // /([0-9]+),([0-9]+) -> ([0-9]+),([0-9]+)/gm
          RegMatch := tregex.matches(Ligne,
            '^([0-9]+),([0-9]+) -> ([0-9]+),([0-9]+)$');
          if (RegMatch.Count = 1) and (RegMatch[0].groups.Count = 5) then
          begin
            x1 := RegMatch[0].groups[1].Value.ToInteger;
            y1 := RegMatch[0].groups[2].Value.ToInteger;
            x2 := RegMatch[0].groups[3].Value.ToInteger;
            y2 := RegMatch[0].groups[4].Value.ToInteger;
            if (x1 = x2) or (y1 = y2) then
            begin
              if (x1 < x2) then
              begin
                for x := x1 to x2 do
                  if (y1 < y2) then
                    for y := y1 to y2 do
                      Map.incremente(x, y)
                  else
                    for y := y1 downto y2 do
                      Map.incremente(x, y);
              end
              else
              begin
                for x := x1 downto x2 do
                  if (y1 < y2) then
                    for y := y1 to y2 do
                      Map.incremente(x, y)
                  else
                    for y := y1 downto y2 do
                      Map.incremente(x, y);
              end;
            end
            else
            begin
              if (abs(x1 - x2) = abs(y1 - y2)) then
              begin
                if x1 > x2 then
                  ix := -1
                else if x1 < x2 then
                  ix := +1
                else
                  ix := 0;
                if y1 > y2 then
                  iy := -1
                else if y1 < y2 then
                  iy := 1
                else
                  iy := 0;
                x := x1;
                y := y1;
                repeat
                  Map.incremente(x, y);
                  x := x + ix;
                  y := y + iy;
                until (x = x2 + ix) and (y = y2 + iy);
              end;
            end;
          end;
        end;
      except

      end;
    until FinDeFichier;
    FermeFichier;
    // Dump sur jeu de test
    // var
    // s: string := '';
    // for y := 0 to 9 do
    // begin
    // s := '';
    // for x := 0 to 9 do
    // s := s + Map.getValeur(x, y).ToString + ' ';
    // Memo1.Lines.Add(s);
    // end;
    Reponse := 0;
    for x in Map.keys do
      for y in Map.items[x].keys do
        if (Map.getValeur(x, y) > 1) then
          Reponse := Reponse + 1;
    AfficheResultat(CJour, CExercice, Reponse);
  finally
    Map.Free;
  end;
end;

procedure TForm1.Jour06_1;
Const
  CNumeroFichier = '06'; // 2 chiffres, en alpha
  CJour = 6; // Numéro du jour
  CExercice = 1; // Numéro exercice
var
  PremiereLigneTraitee: boolean;
  Ligne: string;
  Reponse: uint64;
  poissons: tlist<Integer>;
  Jour: Integer;
  nb: Integer;
  i: Integer;
begin
  poissons := tlist<Integer>.Create;
  try
    PremiereLigneTraitee := false;
    repeat
      Ligne := getLigne('..\..\input-' + CNumeroFichier + '.txt');
      try
        if (not PremiereLigneTraitee) and (not Ligne.IsEmpty) then
        begin
          PremiereLigneTraitee := true;
          var
          Tab := Ligne.Split([',']);
          for i := 0 to Length(Tab) - 1 do
            poissons.Add(Tab[i].ToInteger);
        end;
      except

      end;
    until FinDeFichier;
    FermeFichier;

    // var nouveau:integer:=0;
    for Jour := 1 to 80 do
    begin
      nb := poissons.Count;
      for i := 0 to nb - 1 do
      begin
        if poissons[i] = 0 then
        begin
          poissons.Add(8);
          // inc(nouveau);
          poissons[i] := 6;
        end
        else
          poissons[i] := poissons[i] - 1;
      end;
    end;

    Reponse := poissons.Count;
    AfficheResultat(CJour, CExercice, Reponse);
  finally
    poissons.Free;
  end;
end;

procedure TForm1.Jour06_2;
Const
  CNumeroFichier = '06'; // 2 chiffres, en alpha
  CJour = 6; // Numéro du jour
  CExercice = 2; // Numéro exercice
var
  PremiereLigneTraitee: boolean;
  Ligne: string;
  Reponse: uint64;
  NbPoissonsParJourDeGestation: TDictionary<byte, uint64>;
  nb: uint64;
begin
  NbPoissonsParJourDeGestation := TDictionary<byte, uint64>.Create;
  try
    for var i := 0 to 8 do
      NbPoissonsParJourDeGestation.Add(i, 0);

    PremiereLigneTraitee := false;
    repeat
      Ligne := getLigne('..\..\input-' + CNumeroFichier + '.txt');
      try
        if (not PremiereLigneTraitee) and (not Ligne.IsEmpty) then
        begin
          PremiereLigneTraitee := true;
          var
          Tab := Ligne.Split([',']);
          for var i := 0 to Length(Tab) - 1 do
            NbPoissonsParJourDeGestation[Tab[i].ToInteger] :=
              NbPoissonsParJourDeGestation[Tab[i].ToInteger] + 1;
        end;
      except

      end;
    until FinDeFichier;
    FermeFichier;

    for var Jour := 1 to 256 do
    begin
      nb := NbPoissonsParJourDeGestation[0];
      for var i := 0 to 7 do
        NbPoissonsParJourDeGestation[i] := NbPoissonsParJourDeGestation[i + 1];
      NbPoissonsParJourDeGestation[8] := nb;
      NbPoissonsParJourDeGestation[6] := NbPoissonsParJourDeGestation[6] + nb;
    end;

    Reponse := 0;
    for var i := 0 to 8 do
      Reponse := Reponse + NbPoissonsParJourDeGestation[i];

    AfficheResultat(CJour, CExercice, Reponse);
  finally
    NbPoissonsParJourDeGestation.Free;
  end;
end;

procedure TForm1.Jour07_1;
Const
  CNumeroFichier = '07'; // 2 chiffres, en alpha
  CJour = 7; // Numéro du jour
  CExercice = 1; // Numéro exercice
var
  PremiereLigneTraitee: boolean;
  Ligne: string;
  Reponse: uint64;
  CrabPos: TDictionary<int64, int64>;
  // Dictionnaire de nombre de crabes par profondeur
  FuelMin: int64;
  posminval, posmaxval: int64;
begin
  CrabPos := TDictionary<int64, int64>.Create;
  try
    posminval := high(int64);
    posmaxval := low(int64);
    PremiereLigneTraitee := false;
    repeat
      Ligne := getLigne('..\..\input-' + CNumeroFichier + '.txt');
      try
        if not PremiereLigneTraitee then
        begin
          PremiereLigneTraitee := true;
          var
          Tab := Ligne.Split([',']);
          for var i := 0 to Length(Tab) - 1 do
          begin
            var
              Profondeur: int64 := Tab[i].ToInteger;
            if CrabPos.ContainsKey(Profondeur) then
              CrabPos[Profondeur] := CrabPos[Profondeur] + 1
            else
              CrabPos.Add(Profondeur, 1);
            if Profondeur > posmaxval then
              posmaxval := Profondeur;
            if Profondeur < posminval then
              posminval := Profondeur;
          end;
        end;
      except

      end;
    until FinDeFichier;
    FermeFichier;

    FuelMin := high(int64);

    for var i := posminval to posmaxval do
    begin
      var
        fuel: int64 := 0;
      for var j in CrabPos.keys do
        fuel := fuel + abs(j - i) * CrabPos[j];
      // différence entre profondeur qu'on regarde et celle de l'élément fois le nombre de crabes à cette profondeur
      if fuel < FuelMin then
        FuelMin := fuel;
    end;
    Reponse := FuelMin;
    AfficheResultat(CJour, CExercice, Reponse);
  finally
    CrabPos.Free;
  end;
end;

procedure TForm1.Jour07_2;
Const
  CNumeroFichier = '07'; // 2 chiffres, en alpha
  CJour = 7; // Numéro du jour
  CExercice = 2; // Numéro exercice

  function ToCrabFuel(Profondeur: int64): int64;
  begin
    result := 0;
    for var i := 1 to Profondeur do
      inc(result, i);
  end;

var
  PremiereLigneTraitee: boolean;
  Ligne: string;
  Reponse: uint64;
  CrabPos: TDictionary<int64, int64>;
  // Dictionnaire de nombre de crabes par profondeur
  FuelMin: int64;
  posminval, posmaxval: int64;
begin
  CrabPos := TDictionary<int64, int64>.Create;
  try
    posminval := high(int64);
    posmaxval := low(int64);
    PremiereLigneTraitee := false;
    repeat
      Ligne := getLigne('..\..\input-' + CNumeroFichier + '.txt');
      try
        if not PremiereLigneTraitee then
        begin
          PremiereLigneTraitee := true;
          var
          Tab := Ligne.Split([',']);
          for var i := 0 to Length(Tab) - 1 do
          begin
            var
              Profondeur: int64 := Tab[i].ToInteger;
            if CrabPos.ContainsKey(Profondeur) then
              CrabPos[Profondeur] := CrabPos[Profondeur] + 1
            else
              CrabPos.Add(Profondeur, 1);
            if Profondeur > posmaxval then
              posmaxval := Profondeur;
            if Profondeur < posminval then
              posminval := Profondeur;
          end;
        end;
      except

      end;
    until FinDeFichier;
    FermeFichier;

    FuelMin := high(int64);

    for var i := posminval to posmaxval do
    begin
      var
        fuel: int64 := 0;
      for var j in CrabPos.keys do
        fuel := fuel + ToCrabFuel(abs(j - i)) * CrabPos[j];
      // différence entre profondeur qu'on regarde et celle de l'élément fois le nombre de crabes à cette profondeur
      if fuel < FuelMin then
        FuelMin := fuel;
    end;
    Reponse := FuelMin;
    AfficheResultat(CJour, CExercice, Reponse);
  finally
    CrabPos.Free;
  end;
end;

procedure TForm1.Jour08_1;
Const
  CNumeroFichier = '08'; // 2 chiffres, en alpha
  CJour = 8; // Numéro du jour
  CExercice = 1; // Numéro exercice
  function trier(s: string): string;
  var
    Tab: tstringlist;
  begin
    Tab := tstringlist.Create;
    try
      for var i := 0 to 6 do
        if i < s.Length then
          Tab.Add(s.Chars[i]);
      Tab.Sort;
      result := '';
      for var i := 0 to Tab.Count - 1 do
        if Tab[i].Length > 0 then
          result := result + Tab[i];
    finally
      Tab.Free;
    end;
  end;

var
  Ligne: string;
  Reponse: uint64;
  Chiffres: array [0 .. 9] of string;
begin
  Reponse := 0;
  repeat
    Ligne := getLigne('..\..\input-' + CNumeroFichier + '.txt');
    try
      if not Ligne.IsEmpty then
      begin
        var
        Tab := Ligne.Split([' ']);
        if Length(Tab) = 15 then // 10 chiffres, le séparateur, 10 chiffres
        begin
          for var i := 0 to 9 do
          begin
            if Length(Tab[i]) = 2 then // 2 segments => chiffre 1
              Chiffres[1] := trier(Tab[i])
            else if Length(Tab[i]) = 4 then // 4 segments => chiffre 4
              Chiffres[4] := trier(Tab[i])
            else if Length(Tab[i]) = 3 then // 3 segments => chiffre 7
              Chiffres[7] := trier(Tab[i])
            else if Length(Tab[i]) = 7 then // 7 segments => chiffre 8
              Chiffres[8] := trier(Tab[i]);
          end;
          for var i := 11 to 14 do
          begin
            if (Chiffres[1] = trier(Tab[i])) then
              inc(Reponse)
            else if (Chiffres[4] = trier(Tab[i])) then
              inc(Reponse)
            else if (Chiffres[7] = trier(Tab[i])) then
              inc(Reponse)
            else if (Chiffres[8] = trier(Tab[i])) then
              inc(Reponse);
          end;
        end;
      end;
    except

    end;
  until FinDeFichier;
  FermeFichier;
  AfficheResultat(CJour, CExercice, Reponse);
end;

procedure TForm1.Jour08_2;
Const
  CNumeroFichier = '08'; // 2 chiffres, en alpha
  CJour = 8; // Numéro du jour
  CExercice = 2; // Numéro exercice
  function trier(s: string): string;
  var
    Tab: tstringlist;
  begin
    Tab := tstringlist.Create;
    try
      for var i := 0 to s.Length - 1 do
        if (Tab.IndexOf(s.Chars[i]) = -1) then
          Tab.Add(s.Chars[i]);
      Tab.Sort;
      result := '';
      for var i := 0 to Tab.Count - 1 do
        if Tab[i].Length > 0 then
          result := result + Tab[i];
    finally
      Tab.Free;
    end;
  end;

var
  Ligne: string;
  Reponse: uint64;
  Chiffres: array [0 .. 9] of string;
  i, k: Integer;
  nombre: uint64;
  valeur: string;
begin
  Reponse := 0;
  repeat
    Ligne := getLigne('..\..\input-' + CNumeroFichier + '.txt');
    try
      if not Ligne.IsEmpty then
      begin
        var
        Tab := Ligne.Split([' ']);
        if Length(Tab) = 15 then // 10 chiffres, le séparateur, 10 chiffres
        begin
          var
          Liste235 := tstringlist.Create;
          var
          Liste069 := tstringlist.Create;
          try
            // Récupération des chiffres à nombre de segment unique
            for i := 0 to 9 do
            begin
              if Length(Tab[i]) = 2 then // 2 segments => chiffre 1
                Chiffres[1] := trier(Tab[i])
              else if Length(Tab[i]) = 3 then // 3 segments => chiffre 7
                Chiffres[7] := trier(Tab[i])
              else if Length(Tab[i]) = 4 then // 4 segments => chiffre 4
                Chiffres[4] := trier(Tab[i])
              else if Length(Tab[i]) = 5 then
                // 5 segments => chiffres 2, 3 ou 5
                Liste235.Add(trier(Tab[i]))
              else if Length(Tab[i]) = 6 then
                // 6 segments => chiffres 0, 6 ou 9
                Liste069.Add(trier(Tab[i]))
              else if Length(Tab[i]) = 7 then // 7 segments => chiffre 8
                Chiffres[8] := trier(Tab[i]);
            end;

            // On récupère l'angle du 4 en lui enlevant les segment communs avec le 1
            var
              Chiffre4Ampute: string := '';
            for i := 0 to 3 do
              if Chiffres[1].IndexOf(Chiffres[4].Chars[i]) = -1 then
                Chiffre4Ampute := Chiffre4Ampute + Chiffres[4].Chars[i];

            // traitement des chiffres à 5 segments : 2, 3, 5
            for i := 0 to Liste235.Count - 1 do
            begin
              // recherche du 3 => celui qui a les deux lettres du 1
              if (Liste235[i].IndexOf(Chiffres[1].Chars[0]) > -1) and
                (Liste235[i].IndexOf(Chiffres[1].Chars[1]) > -1) then
                Chiffres[3] := Liste235[i]
                // recherche du 5 => celui qui a les mêmes deux lettres que le 4 si on lui enlève celles du 1
              else if (Liste235[i].IndexOf(Chiffre4Ampute.Chars[0]) > -1) and
                (Liste235[i].IndexOf(Chiffre4Ampute.Chars[1]) > -1) then
                Chiffres[5] := Liste235[i]
              else
                Chiffres[2] := Liste235[i];
            end;

            // Le 9 c'est un 5 avec les 2 segments du 1
            Chiffres[9] := trier(Chiffres[5] + Chiffres[1]);

            // traitement des chiffres à 6 segments : 0, 6, 9
            for i := 0 to Liste069.Count - 1 do
            begin
              // recherche du 6 => un seul segment commun avec le 1
              if (Liste069[i].IndexOf(Chiffres[1].Chars[0]) = -1) or
                (Liste069[i].IndexOf(Chiffres[1].Chars[1]) = -1) then
                Chiffres[6] := Liste069[i]
                // recherche du 0 => c'est celui qui n'est pas 9
              else if (Chiffres[9] <> Liste069[i]) then
                Chiffres[0] := Liste069[i];
            end;

          finally
            Liste069.Free;
            Liste235.Free;
          end;

          nombre := 0;
          for i := 11 to 14 do
          begin
            valeur := trier(Tab[i]);
            for k := 0 to 9 do
              if Chiffres[k] = valeur then
              begin
                nombre := nombre * 10 + k;
                break;
              end;
          end;
          // Memo1.Lines.Add(Ligne);
          // Memo1.Lines.Add(nombre.ToString);
          Reponse := Reponse + nombre;
        end
        else
          raise exception.Create('ligne à plus de 15 : ' + Ligne);
      end;
    except

    end;
  until FinDeFichier;
  FermeFichier;
  AfficheResultat(CJour, CExercice, Reponse);
end;

procedure TForm1.Jour09_1;
Const
  CNumeroFichier = '09';
  // 2 chiffres, en alpha
  CJour = 9; // Numéro du jour
  CExercice = 1; // Numéro exercice
var
  LignePrecedente, LigneATraiter, LigneEnCours: string;
  Reponse: uint64;
begin
  Reponse := 0;
  LignePrecedente := '';
  LigneATraiter := '';
  LigneEnCours := '';
  repeat
    LignePrecedente := LigneATraiter;
    LigneATraiter := LigneEnCours;
    LigneEnCours := getLigne('..\..\input-' + CNumeroFichier + '.txt');
    try
      if not LigneATraiter.IsEmpty then
      begin
        var
        FinDeBoucle := LigneATraiter.Length - 1;
        for var i := 0 to FinDeBoucle do
        begin
          var
          c := LigneATraiter.Chars[i];
          if ((i = 0) or (c < LigneATraiter.Chars[i - 1])) and
            ((i = FinDeBoucle) or (c < LigneATraiter.Chars[i + 1])) and
            (LignePrecedente.IsEmpty or (c < LignePrecedente.Chars[i])) and
            (LigneEnCours.IsEmpty or (c < LigneEnCours.Chars[i])) then
            Reponse := Reponse + strtoint(c) + 1;
        end;
      end;
    except

    end;
  until FinDeFichier and LigneATraiter.IsEmpty;
  FermeFichier;
  AfficheResultat(CJour, CExercice, Reponse);
end;

procedure TForm1.Jour09_1_bis;
Const
  CNumeroFichier = '09';
  // 2 chiffres, en alpha
  CJour = 9; // Numéro du jour
  CExercice = 1; // Numéro exercice
var
  Ligne: string;
  Map: array [0 .. 99, 0 .. 99] of byte;
  Reponse: uint64;
  Lig, Col: Integer;
begin
  // Loading datas from text file to [100x100] array of byte
  var
  lignes := tfile.ReadAllLines('..\..\input-' + CNumeroFichier + '.txt');
  if (Length(lignes) > 100) then
    raise exception.Create('Plus de 100 lignes. Redimensionner tableau.');
  Lig := 0;
  for Ligne in lignes do
  begin
    if (Ligne.Length > 100) then
      raise exception.Create
        ('Plus de 100 caractères dans une ligne. Redimensionner tableau.');
    for Col := 0 to Ligne.Length - 1 do
      Map[Col, Lig] := strtoint(Ligne.Chars[Col]);
    inc(Lig);
  end;

  // Find low points
  Reponse := 0;
  for Lig := 0 to 99 do
    for Col := 0 to 99 do
      if ((Col = 0) or (Map[Col, Lig] < Map[Col - 1, Lig])) and
        ((Col = 99) or (Map[Col, Lig] < Map[Col + 1, Lig])) and
        ((Lig = 0) or (Map[Col, Lig] < Map[Col, Lig - 1])) and
        ((Lig = 99) or (Map[Col, Lig] < Map[Col, Lig + 1])) then
        Reponse := Reponse + Map[Col, Lig] + 1;

  // Show answer
  AfficheResultat(CJour, CExercice, Reponse);
end;

procedure TForm1.Jour09_2;
Const
  CNumeroFichier = '09';
  // 2 chiffres, en alpha
  CJour = 9; // Numéro du jour
  CExercice = 2; // Numéro exercice
type
  TMapJour09 = array [0 .. 99, 0 .. 99] of byte;

  function calculeTailleBassin(var Map: TMapJour09;
    Col, Lig, NiveauAComparer: Integer): Integer;
  begin
    if (Lig >= 0) and (Lig <= 99) and (Col >= 0) and (Col <= 99) and
      (Map[Col, Lig] >= NiveauAComparer) and (Map[Col, Lig] < 9) then
    begin
      NiveauAComparer := Map[Col, Lig];
      Map[Col, Lig] := 9;
      result := 1 + calculeTailleBassin(Map, Col - 1, Lig, NiveauAComparer) +
        calculeTailleBassin(Map, Col + 1, Lig, NiveauAComparer) +
        calculeTailleBassin(Map, Col, Lig - 1, NiveauAComparer) +
        calculeTailleBassin(Map, Col, Lig + 1, NiveauAComparer);
    end
    else
      result := 0;
  end;

var
  Ligne: string;
  Map: TMapJour09;
  Reponse: uint64;
  Lig, Col: Integer;
  TailleBassinMax: array [0 .. 2] of Integer;
  TailleBassin: Integer;
begin
  // Loading datas from text file to [100x100] array of byte
  var
  lignes := tfile.ReadAllLines('..\..\input-' + CNumeroFichier + '.txt');
  if (Length(lignes) > 100) then
    raise exception.Create('Plus de 100 lignes. Redimensionner tableau.');
  Lig := 0;
  for Ligne in lignes do
  begin
    if (Ligne.Length > 100) then
      raise exception.Create
        ('Plus de 100 caractères dans une ligne. Redimensionner tableau.');
    for Col := 0 to Ligne.Length - 1 do
      Map[Col, Lig] := strtoint(Ligne.Chars[Col]);
    inc(Lig);
  end;

  // Find low points
  for var i := 0 to 2 do
    TailleBassinMax[i] := 0;

  for Lig := 0 to 99 do
    for Col := 0 to 99 do
      if ((Col = 0) or (Map[Col, Lig] < Map[Col - 1, Lig])) and
        ((Col = 99) or (Map[Col, Lig] < Map[Col + 1, Lig])) and
        ((Lig = 0) or (Map[Col, Lig] < Map[Col, Lig - 1])) and
        ((Lig = 99) or (Map[Col, Lig] < Map[Col, Lig + 1])) then
      begin
        TailleBassin := calculeTailleBassin(Map, Col, Lig, Map[Col, Lig]);

        // Stockage des 3 valeurs les plus grandes
        for var i := 0 to 2 do
          if TailleBassin > TailleBassinMax[i] then
          begin
            var
            swap := TailleBassinMax[i];
            TailleBassinMax[i] := TailleBassin;
            TailleBassin := swap;
          end;
      end;

  // Show answer
  Reponse := TailleBassinMax[0] * TailleBassinMax[1] * TailleBassinMax[2];
  AfficheResultat(CJour, CExercice, Reponse);
end;

procedure TForm1.Jour10_1;
Const
  CNumeroFichier = '10';
  // 2 chiffres, en alpha
  CJour = 10; // Numéro du jour
  CExercice = 1; // Numéro exercice

  function getSymboleDeFin(Debut: char): char;
  begin
    case Debut of
      '(':
        result := ')';
      '<':
        result := '>';
      '{':
        result := '}';
      '[':
        result := ']';
    else
      result := #0;
    end;
  end;

var
  Ligne: string;
  Reponse: uint64;
  pile: tstack<char>;
  SymboleDebut: char;
  SymboleDeFin: char;
begin
  pile := tstack<char>.Create;
  try
    Reponse := 0;
    repeat
      pile.Clear;
      Ligne := getLigne('..\..\input-' + CNumeroFichier + '.txt');
      try
        for var i := 0 to Ligne.Length - 1 do
          if (Ligne.Chars[i] in ['(', '<', '[', '{']) then // symbole de début
            pile.Push(Ligne.Chars[i])
          else
          begin
            if pile.Count < 1 then
              SymboleDebut := #0
            else
              SymboleDebut := pile.Pop;
            SymboleDeFin := Ligne.Chars[i];
            if SymboleDeFin <> getSymboleDeFin(SymboleDebut) then
            begin
              case SymboleDeFin of
                ')':
                  Reponse := Reponse + 3; // )
                ']':
                  Reponse := Reponse + 57; // ]
                '}':
                  Reponse := Reponse + 1197; // }
                '>':
                  Reponse := Reponse + 25137; // >
              end;
              break;
            end;
          end;
      except

      end;
    until FinDeFichier;
    FermeFichier;
    AfficheResultat(CJour, CExercice, Reponse);
  finally
    pile.Free;
  end;
end;

procedure TForm1.Jour10_2;
Const
  CNumeroFichier = '10';
  // 2 chiffres, en alpha
  CJour = 10; // Numéro du jour
  CExercice = 2; // Numéro exercice

  function getSymboleDeFin(Debut: char): char;
  begin
    case Debut of
      '(':
        result := ')';
      '<':
        result := '>';
      '{':
        result := '}';
      '[':
        result := ']';
    else
      result := #0;
    end;
  end;

var
  Ligne: string;
  Reponse: uint64;
  pile: tstack<char>;
  SymboleDebut: char;
  SymboleDeFin: char;
  SyntaxError: boolean;
  Score: uint64;
  Scores: tlist<uint64>;
begin
  pile := tstack<char>.Create;
  try
    Scores := tlist<uint64>.Create;
    try
      Reponse := 0;
      repeat
        pile.Clear;
        SyntaxError := false;
        Ligne := getLigne('..\..\input-' + CNumeroFichier + '.txt');
        try
          for var i := 0 to Ligne.Length - 1 do
            if (Ligne.Chars[i] in ['(', '<', '[', '{']) then // symbole de début
              pile.Push(Ligne.Chars[i])
            else
            begin
              if pile.Count < 1 then
                SymboleDebut := #0
              else
                SymboleDebut := pile.Pop;
              SymboleDeFin := Ligne.Chars[i];
              if SymboleDeFin <> getSymboleDeFin(SymboleDebut) then
              begin
                SyntaxError := true;
                break;
              end;
            end;
          Score := 0;
          if not SyntaxError then
            // ligne cohérente, voir si elle est finie et la compléter
            while pile.Count > 0 do
            begin
              SymboleDebut := pile.Pop;
              case getSymboleDeFin(SymboleDebut) of
                ')':
                  Score := Score * 5 + 1;
                ']':
                  Score := Score * 5 + 2;
                '}':
                  Score := Score * 5 + 3;
                '>':
                  Score := Score * 5 + 4;
              end;
            end;
          if Score > 0 then
            Scores.Add(Score);
        except

        end;
      until FinDeFichier;
      FermeFichier;

      Scores.Sort(self);

      Reponse := Scores[Scores.Count div 2];
      AfficheResultat(CJour, CExercice, Reponse);
    finally
      Scores.Free;
    end;
  finally
    pile.Free;
  end;
end;

procedure TForm1.Jour11_1;
Const
  CNumeroFichier = '11';
  // 2 chiffres, en alpha
  CJour = 11; // Numéro du jour
  CExercice = 1; // Numéro exercice
type
  TOctopus = record
    NiveauEnergie: byte;
    AFlasheDurantCeTour: boolean;
  end;

  TOctopusses = array [1 .. 10, 1 .. 10] of TOctopus;

  function Flash(var Octopus: TOctopusses; Col, Lig: byte): Integer;
  begin
    result := 0;
    if (Col > 0) and (Col < 11) and (Lig > 0) and (Lig < 11) and
      (Octopus[Col, Lig].NiveauEnergie > 9) and
      (not Octopus[Col, Lig].AFlasheDurantCeTour) then
    begin
      Octopus[Col, Lig].AFlasheDurantCeTour := true;
      result := result + 1;
      for var i := Col - 1 to Col + 1 do
        for var j := Lig - 1 to Lig + 1 do
          if (i > 0) and (i < 11) and (j > 0) and (j < 11) and
            not((i = Col) and (j = Lig)) and
            (not Octopus[i, j].AFlasheDurantCeTour) then
          begin
            inc(Octopus[i, j].NiveauEnergie);
            result := result + Flash(Octopus, i, j);
          end;
      Octopus[Col, Lig].NiveauEnergie := 0;
    end
  end;

var
  Ligne: string;
  Reponse: uint64;
  Octopus: TOctopusses;
  Lig, Col: byte;
begin
  // Chargement des données de départ
  Lig := 1;
  repeat
    Ligne := getLigne('..\..\input-' + CNumeroFichier + '.txt');
    try
      if (not Ligne.IsEmpty) and (Ligne.Length = 10) then
        for Col := 1 to 10 do
          Octopus[Col, Lig].NiveauEnergie := Ligne.Substring(Col - 1, 1)
            .ToInteger;
      // Octopus[Col, Lig].NiveauEnergie := strtoint(Ligne.Chars[Col - 1]);
    except

    end;
    inc(Lig);
  until FinDeFichier or (Lig > 10);
  FermeFichier;

  // Traitement des tours
  Reponse := 0;
  for var i := 1 to 100 do
  begin
    // Incrément de l'énergie
    for Lig := 1 to 10 do
      for Col := 1 to 10 do
      begin
        inc(Octopus[Col, Lig].NiveauEnergie);
        Octopus[Col, Lig].AFlasheDurantCeTour := false;
      end;

    // Traitement (récursif) des flash
    for Lig := 1 to 10 do
      for Col := 1 to 10 do
        if Octopus[Col, Lig].NiveauEnergie > 9 then
          Reponse := Reponse + Flash(Octopus, Col, Lig);

    (*
      Memo1.Lines.Add('');
      Memo1.Lines.Add('Etape : ' + i.ToString);
      for Lig := 1 to 10 do
      begin
      Ligne := '';
      for Col := 1 to 10 do
      Ligne := Ligne + ' ' + Octopus[Col, Lig].NiveauEnergie.ToString;
      Memo1.Lines.Add(Ligne);
      end;
    *)
  end;

  AfficheResultat(CJour, CExercice, Reponse);
end;

procedure TForm1.Jour11_2;
Const
  CNumeroFichier = '11';
  // 2 chiffres, en alpha
  CJour = 11; // Numéro du jour
  CExercice = 2; // Numéro exercice
type
  TOctopus = record
    NiveauEnergie: byte;
    AFlasheDurantCeTour: boolean;
  end;

  TOctopusses = array [1 .. 10, 1 .. 10] of TOctopus;

  function Flash(var Octopus: TOctopusses; Col, Lig: byte): Integer;
  begin
    result := 0;
    if (Col > 0) and (Col < 11) and (Lig > 0) and (Lig < 11) and
      (Octopus[Col, Lig].NiveauEnergie > 9) and
      (not Octopus[Col, Lig].AFlasheDurantCeTour) then
    begin
      Octopus[Col, Lig].AFlasheDurantCeTour := true;
      result := result + 1;
      for var i := Col - 1 to Col + 1 do
        for var j := Lig - 1 to Lig + 1 do
          if (i > 0) and (i < 11) and (j > 0) and (j < 11) and
            not((i = Col) and (j = Lig)) and
            (not Octopus[i, j].AFlasheDurantCeTour) then
          begin
            inc(Octopus[i, j].NiveauEnergie);
            result := result + Flash(Octopus, i, j);
          end;
      Octopus[Col, Lig].NiveauEnergie := 0;
    end
  end;

var
  Ligne: string;
  Reponse: uint64;
  Octopus: TOctopusses;
  Lig, Col: byte;
  NbFlash: byte;
begin
  // Chargement des données de départ
  Lig := 1;
  repeat
    Ligne := getLigne('..\..\input-' + CNumeroFichier + '.txt');
    try
      if (not Ligne.IsEmpty) and (Ligne.Length = 10) then
        for Col := 1 to 10 do
          Octopus[Col, Lig].NiveauEnergie := Ligne.Substring(Col - 1, 1)
            .ToInteger;
      // Octopus[Col, Lig].NiveauEnergie := strtoint(Ligne.Chars[Col - 1]);
    except

    end;
    inc(Lig);
  until FinDeFichier or (Lig > 10);
  FermeFichier;

  Reponse := 0;
  // Traitement des tours
  repeat
    // Incrément de l'énergie
    for Lig := 1 to 10 do
      for Col := 1 to 10 do
      begin
        inc(Octopus[Col, Lig].NiveauEnergie);
        Octopus[Col, Lig].AFlasheDurantCeTour := false;
      end;

    // Traitement (récursif) des flash
    NbFlash := 0;
    for Lig := 1 to 10 do
      for Col := 1 to 10 do
        if Octopus[Col, Lig].NiveauEnergie > 9 then
          NbFlash := NbFlash + Flash(Octopus, Col, Lig);

    inc(Reponse);
  until NbFlash = 100;

  AfficheResultat(CJour, CExercice, Reponse);
end;

procedure TForm1.Jour12_1;
Const
  CNumeroFichier = '12';
  // 2 chiffres, en alpha
  CJour = 12; // Numéro du jour
  CExercice = 1; // Numéro exercice

type
  TSorties = TDictionary<string, boolean>;
  TSalles = TObjectDictionary<string, TSorties>;

  function isPetite(Salle: string): boolean; inline;
  begin
    result := Salle = Salle.ToLower;
  end;

  procedure AjoutePassage(DeSalle, VersSalle: string; var grottes: TSalles);
  begin
    if VersSalle = 'start' then // On ne revient pas sur la salle de départ
      exit;

    if DeSalle = 'end' then // On ne revient pas depuis la salle de fin
      exit;

    if not grottes.ContainsKey(DeSalle) then
      grottes.Add(DeSalle, TSorties.Create);
    if not grottes[DeSalle].ContainsKey(VersSalle) then
      grottes[DeSalle].Add(VersSalle, isPetite(VersSalle));
  end;

  function AjouteChemin(var chemins: tstringlist; grottes: TSalles;
    DeSalle: string; CheminEnCours: string): string;
  var
    VersSalle: string;
    isPetiteSalleEtDansChemin: boolean;
  begin
    if (DeSalle = 'end') then
    begin
      CheminEnCours := CheminEnCours + ' -> end';
      if chemins.IndexOf(CheminEnCours) < 0 then
        chemins.Add(CheminEnCours);
    end
    else
      for VersSalle in grottes[DeSalle].keys do
      begin
        isPetiteSalleEtDansChemin := grottes[DeSalle][VersSalle] and
          (CheminEnCours.IndexOf(' ' + VersSalle + ' ') >= 0);
        if (not isPetiteSalleEtDansChemin) then
          AjouteChemin(chemins, grottes, VersSalle, CheminEnCours + '-> ' +
            DeSalle + ' ');
      end;
  end;

var
  Ligne: string;
  Reponse: uint64;
  grottes: TSalles;
  chemins: tstringlist;
  Temps: TStopWatch;
begin
  grottes := TSalles.Create;
  try
    // Remplissage de la liste des passages possibles
    repeat
      Ligne := getLigne('..\..\input-' + CNumeroFichier + '.txt');
      try
        if not Ligne.IsEmpty then
        begin
          var
          Tab := Ligne.Split(['-']);
          if (Length(Tab) = 2) then
          begin
            AjoutePassage(Tab[0], Tab[1], grottes);
            AjoutePassage(Tab[1], Tab[0], grottes);
          end;
        end;
      except
      end;
    until FinDeFichier;
    FermeFichier;

    // Affichage de la liste des passages
    // for var DeSalle in grottes.keys do
    // for var VersSalle in grottes[DeSalle].keys do
    // Memo1.Lines.Add(DeSalle + '->' + VersSalle + ' (' + grottes[DeSalle]
    // [VersSalle].ToString + ')');

    chemins := tstringlist.Create;
    try
      Temps.Start;
      // Détermination des chemins possibles
      AjouteChemin(chemins, grottes, 'start', '');
      Temps.Stop;
      Memo1.Lines.Add('Calculé en ' +
        Temps.ElapsedMilliseconds.ToString + 'ms');

      // Affichage de la liste des chemins disponibles
      // for var ch in chemins do
      // Memo1.Lines.Add(ch);

      Reponse := chemins.Count;
      AfficheResultat(CJour, CExercice, Reponse);
    finally
      chemins.Free;
    end;
  finally
    grottes.Free;
  end;
end;

procedure TForm1.Jour12_1_bis;
Const
  CNumeroFichier = '12';
  // 2 chiffres, en alpha
  CJour = 12; // Numéro du jour
  CExercice = 1; // Numéro exercice

type
  TSorties = TDictionary<Integer, boolean>;
  TSalles = TObjectDictionary<Integer, TSorties>;
  TNomSalles = tlist<string>;

  function isPetite(Salle: string): boolean; inline;
  begin
    result := Salle = Salle.ToLower;
  end;

  procedure AjoutePassage(DeSalle, VersSalle: string; NomSalles: TNomSalles;
    var grottes: TSalles);
  var
    idxDeSalle, idxVersSalle: Integer;
  begin
    if VersSalle = 'start' then // On ne revient pas sur la salle de départ
      exit;

    if DeSalle = 'end' then // On ne revient pas depuis la salle de fin
      exit;

    idxDeSalle := NomSalles.IndexOf(DeSalle);
    if (idxDeSalle = -1) then
      idxDeSalle := NomSalles.Add(DeSalle);

    idxVersSalle := NomSalles.IndexOf(VersSalle);
    if (idxVersSalle = -1) then
      idxVersSalle := NomSalles.Add(VersSalle);

    if not grottes.ContainsKey(idxDeSalle) then
      grottes.Add(idxDeSalle, TSorties.Create);

    if not grottes[idxDeSalle].ContainsKey(idxVersSalle) then
      grottes[idxDeSalle].Add(idxVersSalle, isPetite(VersSalle));
  end;

  function AjouteChemin(chemins: tstringlist; grottes: TSalles;
    NomDesSalles: TNomSalles; idxDeSalle: Integer;
    CheminEnCours: tlist<Integer>; idxSalleDeFin: Integer): string;
  var
    idxVersSalle: Integer;
    isPetiteSalleEtDansChemin: boolean;
  begin
    if (idxDeSalle = idxSalleDeFin) then
    begin
      var
      chemin := '';
      for var i := 0 to CheminEnCours.Count - 1 do
        if chemin.IsEmpty then
          chemin := NomDesSalles[CheminEnCours.ToArray[i]]
        else
          chemin := chemin + ',' + NomDesSalles[CheminEnCours.ToArray[i]];
      chemin := chemin + ',end';
      if chemins.IndexOf(chemin) < 0 then
        chemins.Add(chemin);
    end
    else
      for idxVersSalle in grottes[idxDeSalle].keys do
      begin
        isPetiteSalleEtDansChemin := grottes[idxDeSalle][idxVersSalle] and
          (CheminEnCours.IndexOf(idxVersSalle) >= 0);
        if (not isPetiteSalleEtDansChemin) then
        begin
          CheminEnCours.Add(idxDeSalle);
          AjouteChemin(chemins, grottes, NomDesSalles, idxVersSalle,
            CheminEnCours, idxSalleDeFin);
          CheminEnCours.Delete(CheminEnCours.Count - 1);
        end;
      end;
  end;

var
  Ligne: string;
  Reponse: uint64;
  grottes: TSalles;
  chemins: tstringlist;
  Temps: TStopWatch;
  NomDesSalles: TNomSalles;
  CheminEnCours: tlist<Integer>;
begin
  NomDesSalles := TNomSalles.Create;
  try
    grottes := TSalles.Create;
    try
      // Remplissage de la liste des passages possibles
      repeat
        Ligne := getLigne('..\..\input-' + CNumeroFichier + '.txt');
        try
          if not Ligne.IsEmpty then
          begin
            var
            Tab := Ligne.Split(['-']);
            if (Length(Tab) = 2) then
            begin
              AjoutePassage(Tab[0], Tab[1], NomDesSalles, grottes);
              AjoutePassage(Tab[1], Tab[0], NomDesSalles, grottes);
            end;
          end;
        except
        end;
      until FinDeFichier;
      FermeFichier;

      // Affichage de la liste des passages
      // for var DeSalle in grottes.keys do
      // for var VersSalle in grottes[DeSalle].keys do
      // Memo1.Lines.Add(DeSalle + '->' + VersSalle + ' (' + grottes[DeSalle]
      // [VersSalle].ToString + ')');

      chemins := tstringlist.Create;
      try
        // Détermination des chemins possibles
        Temps.Start;
        CheminEnCours := tlist<Integer>.Create;
        try
          AjouteChemin(chemins, grottes, NomDesSalles,
            NomDesSalles.IndexOf('start'), CheminEnCours,
            NomDesSalles.IndexOf('end'));
        finally
          CheminEnCours.Free;
        end;
        Temps.Stop;
        Memo1.Lines.Add('Calculé en ' +
          Temps.ElapsedMilliseconds.ToString + 'ms');

        // Affichage de la liste des chemins disponibles
        // for var ch in chemins do
        // Memo1.Lines.Add(ch);

        Reponse := chemins.Count;
        AfficheResultat(CJour, CExercice, Reponse);
      finally
        chemins.Free;
      end;
    finally
      grottes.Free;
    end;
  finally
    NomDesSalles.Free;
  end;
end;

procedure TForm1.Jour12_2;
Const
  CNumeroFichier = '12';
  // 2 chiffres, en alpha
  CJour = 12; // Numéro du jour
  CExercice = 2; // Numéro exercice

type
  TSorties = TDictionary<string, boolean>;
  TSalles = TObjectDictionary<string, TSorties>;

  function AjouteChemin(chemins: tstringlist; grottes: TSalles; DeSalle: string;
    CheminEnCours: string; DejaDeuxFois: boolean): string;
  var
    VersSalle: string;
    isPetiteSalleEtDansChemin: boolean;
  begin
    if (DeSalle = 'end') then
    begin
      CheminEnCours := CheminEnCours + ' -> end';
      if chemins.IndexOf(CheminEnCours) < 0 then
        chemins.Add(CheminEnCours);
    end
    else
      for VersSalle in grottes[DeSalle].keys do
      begin
        isPetiteSalleEtDansChemin := grottes[DeSalle][VersSalle] and
          (CheminEnCours.IndexOf(' ' + VersSalle + ' ') >= 0);
        if (isPetiteSalleEtDansChemin and (not DejaDeuxFois)) then
          AjouteChemin(chemins, grottes, VersSalle, CheminEnCours + '-> ' +
            DeSalle + ' ', true)
        else if (not isPetiteSalleEtDansChemin) then
          AjouteChemin(chemins, grottes, VersSalle, CheminEnCours + '-> ' +
            DeSalle + ' ', DejaDeuxFois);
      end;
  end;

  function isPetite(Salle: string): boolean; inline;
  begin
    result := Salle = Salle.ToLower;
  end;

  procedure AjoutePassage(DeSalle, VersSalle: string; var grottes: TSalles);
  begin
    if VersSalle = 'start' then
      // On ne revient pas sur la salle de départ
      exit;

    if DeSalle = 'end' then // On ne revient pas depuis la salle de fin
      exit;

    if not grottes.ContainsKey(DeSalle) then
      grottes.Add(DeSalle, TSorties.Create);
    if not grottes[DeSalle].ContainsKey(VersSalle) then
      grottes[DeSalle].Add(VersSalle, isPetite(VersSalle));
  end;

var
  Ligne: string;
  Reponse: uint64;
  grottes: TSalles;
  chemins: tstringlist;
begin
  grottes := TSalles.Create;
  try
    // Remplissage de la liste des passages possibles
    repeat
      Ligne := getLigne('..\..\input-' + CNumeroFichier + '.txt');
      try
        if not Ligne.IsEmpty then
        begin
          var
          Tab := Ligne.Split(['-']);
          if (Length(Tab) = 2) then
          begin
            AjoutePassage(Tab[0], Tab[1], grottes);
            AjoutePassage(Tab[1], Tab[0], grottes);
          end;
        end;
      except
      end;
    until FinDeFichier;
    FermeFichier;

    // Affichage de la liste des passages
    // for var DeSalle in grottes.keys do
    // for var VersSalle in grottes[DeSalle].keys do
    // Memo1.Lines.Add(DeSalle + '->' + VersSalle + ' (' + grottes[DeSalle]
    // [VersSalle].ToString + ')');

    chemins := tstringlist.Create;
    try
      // Détermination des chemins possibles
      AjouteChemin(chemins, grottes, 'start', '', false);

      // Affichage de la liste des chemins disponibles
      // for var ch in chemins do
      // Memo1.Lines.Add(ch);

      Reponse := chemins.Count;
      AfficheResultat(CJour, CExercice, Reponse);
    finally
      chemins.Free;
    end;
  finally
    grottes.Free;
  end;
end;

procedure TForm1.Jour12_2_bis;
Const
  CNumeroFichier = '12';
  // 2 chiffres, en alpha
  CJour = 12; // Numéro du jour
  CExercice = 1; // Numéro exercice

type
  TSorties = TDictionary<Integer, boolean>;
  TSalles = TObjectDictionary<Integer, TSorties>;
  TNomSalles = tlist<string>;

  function isPetite(Salle: string): boolean; inline;
  begin
    result := Salle = Salle.ToLower;
  end;

  procedure AjoutePassage(DeSalle, VersSalle: string; NomSalles: TNomSalles;
    var grottes: TSalles);
  var
    idxDeSalle, idxVersSalle: Integer;
  begin
    if VersSalle = 'start' then // On ne revient pas sur la salle de départ
      exit;

    if DeSalle = 'end' then // On ne revient pas depuis la salle de fin
      exit;

    idxDeSalle := NomSalles.IndexOf(DeSalle);
    if (idxDeSalle = -1) then
      idxDeSalle := NomSalles.Add(DeSalle);

    idxVersSalle := NomSalles.IndexOf(VersSalle);
    if (idxVersSalle = -1) then
      idxVersSalle := NomSalles.Add(VersSalle);

    if not grottes.ContainsKey(idxDeSalle) then
      grottes.Add(idxDeSalle, TSorties.Create);

    if not grottes[idxDeSalle].ContainsKey(idxVersSalle) then
      grottes[idxDeSalle].Add(idxVersSalle, isPetite(VersSalle));
  end;

  function AjouteChemin(chemins: tstringlist; grottes: TSalles;
    NomDesSalles: TNomSalles; idxDeSalle: Integer;
    CheminEnCours: tlist<Integer>; idxSalleDeFin: Integer;
    DejaDeuxFois: boolean): string;
  var
    idxVersSalle: Integer;
    isPetiteSalleEtDansChemin: boolean;
  begin
    if (idxDeSalle = idxSalleDeFin) then
    begin
      var
      chemin := '';
      for var i := 0 to CheminEnCours.Count - 1 do
        if chemin.IsEmpty then
          chemin := NomDesSalles[CheminEnCours.ToArray[i]]
        else
          chemin := chemin + ',' + NomDesSalles[CheminEnCours.ToArray[i]];
      chemin := chemin + ',end';
      if chemins.IndexOf(chemin) < 0 then
        chemins.Add(chemin);
    end
    else
      for idxVersSalle in grottes[idxDeSalle].keys do
      begin
        isPetiteSalleEtDansChemin := grottes[idxDeSalle][idxVersSalle] and
          (CheminEnCours.IndexOf(idxVersSalle) >= 0);
        if (isPetiteSalleEtDansChemin and (not DejaDeuxFois)) then
        begin
          CheminEnCours.Add(idxDeSalle);
          AjouteChemin(chemins, grottes, NomDesSalles, idxVersSalle,
            CheminEnCours, idxSalleDeFin, true);
          CheminEnCours.Delete(CheminEnCours.Count - 1);
        end
        else if (not isPetiteSalleEtDansChemin) then
        begin
          CheminEnCours.Add(idxDeSalle);
          AjouteChemin(chemins, grottes, NomDesSalles, idxVersSalle,
            CheminEnCours, idxSalleDeFin, DejaDeuxFois);
          CheminEnCours.Delete(CheminEnCours.Count - 1);
        end;
      end;
  end;

var
  Ligne: string;
  Reponse: uint64;
  grottes: TSalles;
  chemins: tstringlist;
  Temps: TStopWatch;
  NomDesSalles: TNomSalles;
  CheminEnCours: tlist<Integer>;
begin
  NomDesSalles := TNomSalles.Create;
  try
    grottes := TSalles.Create;
    try
      // Remplissage de la liste des passages possibles
      repeat
        Ligne := getLigne('..\..\input-' + CNumeroFichier + '.txt');
        try
          if not Ligne.IsEmpty then
          begin
            var
            Tab := Ligne.Split(['-']);
            if (Length(Tab) = 2) then
            begin
              AjoutePassage(Tab[0], Tab[1], NomDesSalles, grottes);
              AjoutePassage(Tab[1], Tab[0], NomDesSalles, grottes);
            end;
          end;
        except
        end;
      until FinDeFichier;
      FermeFichier;

      // Affichage de la liste des passages
      // for var DeSalle in grottes.keys do
      // for var VersSalle in grottes[DeSalle].keys do
      // Memo1.Lines.Add(DeSalle + '->' + VersSalle + ' (' + grottes[DeSalle]
      // [VersSalle].ToString + ')');

      chemins := tstringlist.Create;
      try
        // Détermination des chemins possibles
        Temps.Start;
        CheminEnCours := tlist<Integer>.Create;
        try
          AjouteChemin(chemins, grottes, NomDesSalles,
            NomDesSalles.IndexOf('start'), CheminEnCours,
            NomDesSalles.IndexOf('end'), false);
        finally
          CheminEnCours.Free;
        end;
        Temps.Stop;
        Memo1.Lines.Add('Calculé en ' +
          Temps.ElapsedMilliseconds.ToString + 'ms');

        // Affichage de la liste des chemins disponibles
        // for var ch in chemins do
        // Memo1.Lines.Add(ch);

        Reponse := chemins.Count;
        AfficheResultat(CJour, CExercice, Reponse);
      finally
        chemins.Free;
      end;
    finally
      grottes.Free;
    end;
  finally
    NomDesSalles.Free;
  end;
end;

type
  TCoord = class
  public
    x, y: Integer;
    constructor Create(AX, AY: Integer);
  end;

  TCoords = class(TObjectList<TCoord>)
  public
    /// <summary>
    /// Ajoute les coordonnées à la liste si elles n'y sont pas encore.
    /// </summary>
    procedure Ajoute(AX, AY: Integer);

    /// <summary>
    /// Retourne True si la liste contient déjà un élément à ces coordonnées
    /// </summary>
    function ContientCoordonnees(AX, AY: Integer): boolean;
  end;

procedure TForm1.Jour13_1;
Const
  CNumeroFichier = '13';
  // 2 chiffres, en alpha
  CJour = 13; // Numéro du jour
  CExercice = 1; // Numéro exercice
  procedure PlieEnColonne(Feuille: TCoords; x: Integer);
  begin
    for var i := Feuille.Count - 1 downto 0 do
      if Feuille[i].x = x then
        Feuille.Delete(i)
      else if Feuille[i].x > x then
      begin
        Feuille.Ajoute(x * 2 - Feuille[i].x, Feuille[i].y);
        Feuille.Delete(i);
      end;
  end;
  procedure PlieEnLigne(Feuille: TCoords; y: Integer);
  begin
    for var i := Feuille.Count - 1 downto 0 do
      if Feuille[i].y = y then
        Feuille.Delete(i)
      else if Feuille[i].y > y then
      begin
        Feuille.Ajoute(Feuille[i].x, y * 2 - Feuille[i].y);
        Feuille.Delete(i);
      end;
  end;

var
  Ligne: string;
  Reponse: uint64;
  Feuille: TCoords;
begin
  Feuille := TCoords.Create;
  try
    Reponse := 0;

    // Récupération des points (coordonnées) jusqu'à ligne vide
    repeat
      Ligne := getLigne('..\..\input-' + CNumeroFichier + '.txt');
      try
        if not Ligne.IsEmpty then
        begin
          var
          Tab := Ligne.Split([',']);
          if (Length(Tab) = 2) then
            Feuille.Ajoute(Tab[0].ToInteger, Tab[1].ToInteger);
        end;
      except

      end;
    until FinDeFichier or Ligne.IsEmpty;

    if not FinDeFichier then
    begin
      // Lecture de la première ligne de pliage
      Ligne := getLigne('..\..\input-' + CNumeroFichier + '.txt');
      if Ligne.StartsWith('fold along x=') then // pliage vertical
        PlieEnColonne(Feuille, Ligne.Substring('fold along x='.Length)
          .ToInteger)
      else if Ligne.StartsWith('fold along y=') then // pliage horizontal
        PlieEnLigne(Feuille, Ligne.Substring('fold along y='.Length).ToInteger);
    end;

    // Nombre de points restants après pliage
    Reponse := Feuille.Count;

    FermeFichier;
    AfficheResultat(CJour, CExercice, Reponse);
  finally
    Feuille.Free;
  end;
end;

procedure TForm1.Jour13_2;
Const
  CNumeroFichier = '13';
  // 2 chiffres, en alpha
  CJour = 13; // Numéro du jour
  CExercice = 2; // Numéro exercice
  procedure PlieEnColonne(Feuille: TCoords; x: Integer);
  begin
    for var i := Feuille.Count - 1 downto 0 do
      if Feuille[i].x = x then
        Feuille.Delete(i)
      else if Feuille[i].x > x then
      begin
        Feuille.Ajoute(x * 2 - Feuille[i].x, Feuille[i].y);
        Feuille.Delete(i);
      end;
  end;
  procedure PlieEnLigne(Feuille: TCoords; y: Integer);
  begin
    for var i := Feuille.Count - 1 downto 0 do
      if Feuille[i].y = y then
        Feuille.Delete(i)
      else if Feuille[i].y > y then
      begin
        Feuille.Ajoute(Feuille[i].x, y * 2 - Feuille[i].y);
        Feuille.Delete(i);
      end;
  end;

var
  Ligne: string;
  Reponse: uint64;
  Feuille: TCoords;
  Resultat: array of string;
begin
  Feuille := TCoords.Create;
  try
    Reponse := 0;

    // Récupération des points (coordonnées) jusqu'à ligne vide
    repeat
      Ligne := getLigne('..\..\input-' + CNumeroFichier + '.txt');
      try
        if not Ligne.IsEmpty then
        begin
          var
          Tab := Ligne.Split([',']);
          if (Length(Tab) = 2) then
            Feuille.Ajoute(Tab[0].ToInteger, Tab[1].ToInteger);
        end;
      except

      end;
    until FinDeFichier or Ligne.IsEmpty;

    while not FinDeFichier do
    begin
      // Lecture de la première ligne de pliage
      Ligne := getLigne('..\..\input-' + CNumeroFichier + '.txt');
      if Ligne.StartsWith('fold along x=') then // pliage vertical
        PlieEnColonne(Feuille, Ligne.Substring('fold along x='.Length)
          .ToInteger)
      else if Ligne.StartsWith('fold along y=') then // pliage horizontal
        PlieEnLigne(Feuille, Ligne.Substring('fold along y='.Length).ToInteger);
    end;

    for var coord in Feuille do
    begin
      if (coord.y >= Length(Resultat)) then
        setlength(Resultat, coord.y + 1);
      if (Resultat[coord.y].Length <= coord.x) then
        for var i := Resultat[coord.y].Length to coord.x do
          Resultat[coord.y] := Resultat[coord.y] + '_';
      Resultat[coord.y][coord.x + 1] := '#';
      // Chaîne à l'ancienne, donc commence à 1 (depuis 10.4 Sydney)
    end;

    FermeFichier;
    AfficheResultat(CJour, CExercice, Reponse);

    for var i := 0 to Length(Resultat) - 1 do
      Memo1.Lines.Add(Resultat[i]);
  finally
    Feuille.Free;
  end;
end;

procedure TForm1.Jour14_1;
Const
  CNumeroFichier = '14';
  // 2 chiffres, en alpha
  CJour = 14; // Numéro du jour
  CExercice = 1; // Numéro exercice

  procedure IncrementeLettre(nb: TDictionary<char, uint64>; Lettre: char);
  begin
    if not nb.ContainsKey(Lettre) then
      nb.Add(Lettre, 1)
    else
      nb[Lettre] := nb[Lettre] + 1;
  end;

var
  Ligne: string;
  Reponse: uint64;
  Polymere: string;
  Remplacements: TDictionary<string, char>;
  nb: TDictionary<char, uint64>;
  ValMax, ValMin: uint64;
  NumChar: uint64;
  Paire: string;
  LettreAjoutee: char;
begin
  nb := TDictionary<char, uint64>.Create;
  try
    Remplacements := TDictionary<string, char>.Create;
    try
      // Ligne de départ : polymère à son état initial
      Polymere := getLigne('..\..\input-' + CNumeroFichier + '.txt');

      // Ligne de séparation
      Ligne := getLigne('..\..\input-' + CNumeroFichier + '.txt');

      // Liste des remplacements
      repeat
        Ligne := getLigne('..\..\input-' + CNumeroFichier + '.txt');
        try
          if not Ligne.IsEmpty then
            Remplacements.Add(Ligne.Substring(0, 2),
              Ligne.Chars[Ligne.Length - 1]);
        except

        end;
      until FinDeFichier;
      FermeFichier;

      // Calcul des occurences de départ
      for var i := 0 to Polymere.Length - 1 do
        IncrementeLettre(nb, Polymere.Chars[i]);

      // Polymérisation
      for var i := 1 to 10 do
      begin
        NumChar := 0;
        while (NumChar < Polymere.Length - 1) do
        begin
          Paire := Polymere.Substring(NumChar, 2);
          if Remplacements.ContainsKey(Paire) then
          begin
            LettreAjoutee := Remplacements[Paire];
            Polymere.Insert(NumChar + 1, LettreAjoutee);
            IncrementeLettre(nb, LettreAjoutee);
            inc(NumChar, 2);
          end
          else
            inc(NumChar, 1);
        end;
        if i < 5 then
          Memo1.Lines.Add(Polymere);
      end;

      // Calcul du min et max des lettres utilisées
      ValMin := high(uint64);
      ValMax := low(uint64);
      for var Lettre in nb.keys do
      begin
        if nb[Lettre] < ValMin then
        begin
          if (ValMin > ValMax) and (ValMin < high(uint64)) then
            ValMax := ValMin;
          ValMin := nb[Lettre];
        end
        else if nb[Lettre] > ValMax then
        begin
          if (ValMax < ValMin) and (ValMax > low(uint64)) then
            ValMin := ValMax;
          ValMax := nb[Lettre];
        end;
      end;

      Reponse := ValMax - ValMin;
      AfficheResultat(CJour, CExercice, Reponse);
    finally
      Remplacements.Free;
    end;
  finally
    nb.Free;
  end;
end;

procedure TForm1.Jour14_2;
Const
  CNumeroFichier = '14';
  // 2 chiffres, en alpha
  CJour = 14; // Numéro du jour
  CExercice = 2; // Numéro exercice

  procedure IncrementeLettre(nb: TDictionary<char, uint64>; Lettre: char;
    Increment: uint64 = 1);
  begin
    if not nb.ContainsKey(Lettre) then
      nb.Add(Lettre, Increment)
    else
      nb[Lettre] := nb[Lettre] + Increment;
  end;

  procedure AjoutePaire(PairesEnCours: TDictionary<string, uint64>;
    Paire: string; Increment: uint64 = 1);
  begin
    if not PairesEnCours.ContainsKey(Paire) then
      PairesEnCours.Add(Paire, Increment)
    else
      PairesEnCours[Paire] := PairesEnCours[Paire] + Increment;
  end;

var
  Ligne: string;
  Reponse: uint64;
  Polymere: string;
  Remplacements: TDictionary<string, char>;
  nb: TDictionary<char, uint64>;
  ValMax, ValMin: uint64;
  NumChar: uint64;
  Paire: string;
  LettreAjoutee: char;
  PairesEnCours, NouvellesPaires, SwapPaires: TDictionary<string, uint64>;
begin
  NouvellesPaires := TDictionary<string, uint64>.Create;
  try
    PairesEnCours := TDictionary<string, uint64>.Create;
    try
      nb := TDictionary<char, uint64>.Create;
      try
        Remplacements := TDictionary<string, char>.Create;
        try
          // Ligne de départ : polymère à son état initial
          Polymere := getLigne('..\..\input-' + CNumeroFichier + '.txt');

          // Ligne de séparation
          Ligne := getLigne('..\..\input-' + CNumeroFichier + '.txt');

          // Liste des remplacements
          repeat
            Ligne := getLigne('..\..\input-' + CNumeroFichier + '.txt');
            try
              if not Ligne.IsEmpty then
                Remplacements.Add(Ligne.Substring(0, 2),
                  Ligne.Chars[Ligne.Length - 1]);
            except

            end;
          until FinDeFichier;
          FermeFichier;

          // Calcul des occurences de départ
          for var i := 0 to Polymere.Length - 1 do
            IncrementeLettre(nb, Polymere.Chars[i]);

          // Découpe le polymère en paires
          PairesEnCours.Clear;
          for var i := 0 to Polymere.Length - 2 do
            AjoutePaire(PairesEnCours, Polymere.Substring(i, 2));

          // Polymérisation
          for var i := 1 to 40 do
          begin
            // Nouveau tour, pas de paires à ajouter pour le moment
            NouvellesPaires.Clear;

            // Parcours des paires existentes pour création de la nouvelle chaine du polèmere
            for Paire in PairesEnCours.keys do
            begin
              if Remplacements.ContainsKey(Paire) then
              begin
                LettreAjoutee := Remplacements[Paire];
                AjoutePaire(NouvellesPaires, Paire.Chars[0] + LettreAjoutee,
                  PairesEnCours[Paire]);
                AjoutePaire(NouvellesPaires, LettreAjoutee + Paire.Chars[1],
                  PairesEnCours[Paire]);
                IncrementeLettre(nb, LettreAjoutee, PairesEnCours[Paire]);
                inc(NumChar, 2);
              end
              else
                inc(NumChar, 1);
            end;

            // On a finit avec le polymère actuel, on bascule sur le nouveau
            SwapPaires := PairesEnCours;
            PairesEnCours := NouvellesPaires;
            NouvellesPaires := SwapPaires;
          end;

          // Calcul du min et max des lettres utilisées
          ValMin := high(uint64);
          ValMax := low(uint64);
          for var Lettre in nb.keys do
          begin
            if nb[Lettre] < ValMin then
            begin
              if (ValMin > ValMax) and (ValMin < high(uint64)) then
                ValMax := ValMin;
              ValMin := nb[Lettre];
            end
            else if nb[Lettre] > ValMax then
            begin
              if (ValMax < ValMin) and (ValMax > low(uint64)) then
                ValMin := ValMax;
              ValMax := nb[Lettre];
            end;
          end;

          Reponse := ValMax - ValMin;
          AfficheResultat(CJour, CExercice, Reponse);
        finally
          Remplacements.Free;
        end;
      finally
        nb.Free;
      end;
    finally
      PairesEnCours.Free;
    end;
  finally
    NouvellesPaires.Free;
  end;
end;

// procedure TForm1.Jour15_1;
// Const
// CNumeroFichier = '15';
// // 2 chiffres, en alpha
// CJour = 15; // Numéro du jour
// CExercice = 1; // Numéro exercice
// type
// TChitons = array of array of byte;
//
// procedure ChercheChemin(x, y: Integer; Chitons: TChitons;
// CheminActuel: TCoords; ActualRiskLevel: uint64; var LowerRiskLevel: uint64);
// var
// NiveauDeRisque: byte;
// begin
// // si coordonnées hors grille, on ne fait rien
// if (x < 0) or (y < 0) or (x >= Length(Chitons[0])) or (y >= Length(Chitons))
// then
// exit;
// // si la case demandée est dans la liste déjà parcourrue pour ce chemin, on ne fait rien
// if (CheminActuel.ContientCoordonnees(x, y)) then
// exit;
// // On vérifie le risque de ce chemin par rapport au risque du plus faible actuel
// NiveauDeRisque := Chitons[y][x];
// if (ActualRiskLevel + NiveauDeRisque < LowerRiskLevel) then
// begin
// // Niveau de risque actuel inférieur au plus petit, on peut continuer à chercher la case suivante
// if (x = Length(Chitons[0]) - 1) and (y = Length(Chitons) - 1) then
// begin // On a atteint notre dernière case, on est sur le nouveau plus court chemin
// LowerRiskLevel := ActualRiskLevel + NiveauDeRisque;
// end
// else
// begin // On est sur une case de la grille, on continue avec les suivantes
// CheminActuel.Ajoute(x, y);
// ChercheChemin(x + 1, y, Chitons, CheminActuel,
// ActualRiskLevel + NiveauDeRisque, LowerRiskLevel);
// ChercheChemin(x, y + 1, Chitons, CheminActuel,
// ActualRiskLevel + NiveauDeRisque, LowerRiskLevel);
// ChercheChemin(x - 1, y, Chitons, CheminActuel,
// ActualRiskLevel + NiveauDeRisque, LowerRiskLevel);
// ChercheChemin(x, y - 1, Chitons, CheminActuel,
// ActualRiskLevel + NiveauDeRisque, LowerRiskLevel);
// CheminActuel.Delete(CheminActuel.Count - 1);
// end;
// end;
// end;
//
// var
// Ligne: string;
// Reponse: uint64;
// Chitons: TChitons;
// CheminActuel: TCoords; // liste de coordonnées (X,Y)
// begin
// CheminActuel := TCoords.Create;
// try
//
// // Stockage de la grille de travail
// repeat
// Ligne := getLigne('..\..\input-' + CNumeroFichier + '.txt');
// try
// if not Ligne.IsEmpty then
// begin
// // ajout d'une ligne
// setlength(Chitons, Length(Chitons) + 1);
//
// // nb de colonnes dans la ligne
// setlength(Chitons[Length(Chitons) - 1], Ligne.Length);
//
// for var i := 1 to Ligne.Length do
// Chitons[Length(Chitons) - 1][i - 1] := strtoint(Ligne[i]);
// // Chitons[Length(Chitons) - 1][i - 1] := ord(Ligne[i]) - 48;
// // 48 = ord('0');
// end;
// except
//
// end;
// until FinDeFichier;
// FermeFichier;
//
// // La case de départ (x,y)=(0,0) ne compte pas, donc risk level = 0
// Chitons[0][0] := 0;
//
// // Recherche du chemin le plus court avec stockage de son "risque"
// Reponse := high(uint64);
// CheminActuel.Clear;
// ChercheChemin(0, 0, Chitons, CheminActuel, 0, Reponse);
//
// // Affichage du résultat calculé
// AfficheResultat(CJour, CExercice, Reponse);
// finally
// CheminActuel.Free;
// end;
// end;

procedure TForm1.Jour15_1;
Const
  CNumeroFichier = '15';
  // 2 chiffres, en alpha
  CJour = 15; // Numéro du jour
  CExercice = 1; // Numéro exercice
  CValMax = high(uint64) - 10; // (maxInt - maxRisk)
type
  TChitons = array of array of uint64;
var
  Ligne: string;
  Reponse: uint64;
  Risk, Chitons: TChitons;
  a, b, c, d, z: uint64;
  i, x, y: uint64;
  RiskModifie: boolean;
begin
  // Solution provenant de
  // https://github.com/mikewarot/Advent_of_Code_in_Pascal/blob/master/2021/advent2021_15a.lpr
  //
  // algorythme utilisé : Dijkstra
  // https://fr.wikipedia.org/wiki/Algorithme_de_Dijkstra

  // Stockage de la grille de travail
  repeat
    Ligne := getLigne('..\..\input-' + CNumeroFichier + '.txt');
    try
      if not Ligne.IsEmpty then
      begin
        // ajout d'une ligne
        setlength(Chitons, Length(Chitons) + 1);

        // nb de colonnes dans la ligne
        setlength(Chitons[Length(Chitons) - 1], Ligne.Length);

        for i := 1 to Ligne.Length do
          Chitons[Length(Chitons) - 1][i - 1] := strtoint(Ligne[i]);
        // Chitons[Length(Chitons) - 1][i - 1] := ord(Ligne[i]) - 48;
        // 48 = ord('0');
      end;
    except

    end;
  until FinDeFichier;
  FermeFichier;

  // Initialisation du tableau des valeurs de risque
  setlength(Risk, Length(Chitons));
  for y := 0 to Length(Risk) - 1 do
  begin
    setlength(Risk[y], Length(Chitons[0]));
    for x := 0 to Length(Risk[y]) - 1 do
      Risk[y][x] := CValMax;
  end;

  // Le risque de la case finale prend la valeur de son risque
  Risk[Length(Risk) - 1][Length(Risk[0]) - 1] := Chitons[Length(Chitons) - 1]
    [Length(Chitons[0]) - 1];

  // Chaque boucle déplace le risque calculé depuis la case finale (en bas à droite) d'un cran vers la gauche et/ou vers le haut.
  // On arrête de boucler lorsque la case d'arrivée a un risque stable deux boucles d'affilée.
  RiskModifie := true;
  while (RiskModifie) do
  begin
    RiskModifie := false;
    // Memo1.Lines.Add(i.ToString + ' ' + Risk[0, 0].ToString);
    for y := 0 to Length(Risk) - 1 do
      for x := 0 to Length(Risk[y]) - 1 do
      begin
        // Chaque case du tableau des risques prend son risque officiel ajouté
        // la valeur de risque (calculé) de la case adjacente la plus faible
        a := CValMax;
        if x < Length(Risk[y]) - 1 then
          a := Risk[y, x + 1] + Chitons[y, x];
        b := CValMax;
        if y < Length(Risk) - 1 then
          b := Risk[y + 1, x] + Chitons[y, x];
        c := CValMax;
        if x > 0 then
          c := Risk[y, x - 1] + Chitons[y, x];
        d := CValMax;
        if y > 0 then
          d := Risk[y - 1, x] + Chitons[y, x];
        z := CValMax;
        if a < z then
          z := a;
        if b < z then
          z := b;
        if c < z then
          z := c;
        if d < z then
          z := d;
        if not((x = Length(Risk[y]) - 1) AND (y = Length(Risk) - 1)) then
        begin // On ne touche pas à la case d'arrivée
          RiskModifie := riskmodifie or (Risk[y, x] <> z);
          Risk[y, x] := z;
        end;
      end;
  end;

  // On prend le risque minimum total rapatrié depuis la case de fin moins celui de la case de début qu'on ne doit pas comptabiliser
  Reponse := Risk[0, 0] - Chitons[0, 0];

  // Affichage du résultat calculé
  AfficheResultat(CJour, CExercice, Reponse);
end;

procedure TForm1.Jour15_2;
Const
  CNumeroFichier = '15';
  // 2 chiffres, en alpha
  CJour = 15; // Numéro du jour
  CExercice = 2; // Numéro exercice
  CValMax = high(uint64) - 10; // (maxInt - maxRisk)
type
  TChitons = array of array of uint64;
var
  lignes: tstringlist;
  Reponse: uint64;
  Risk, Chitons: TChitons;
  a, b, c, d, z: uint64;
  i, x, y: uint64;
  LargeurLigne, LargeurGrille, NbLignes, HauteurGrille: uint64;
  RiskModifie: boolean;
begin
  // Chargement du fichier
  lignes := tstringlist.Create;
  try
    lignes.LoadFromFile('..\..\input-' + CNumeroFichier + '.txt');

    // Définition de la taille de la grille de risques des chitons
    LargeurLigne := lignes[0].Length;
    LargeurGrille := LargeurLigne * 5;

    // Chargement de la grille (première série de lignes)
    HauteurGrille := 0;
    NbLignes := 0;
    for y := 0 to lignes.Count - 1 do
      if not lignes[y].IsEmpty then
      begin
        inc(HauteurGrille);
        inc(NbLignes);
        setlength(Chitons, HauteurGrille);
        setlength(Chitons[HauteurGrille - 1], LargeurGrille);
        for x := 0 to LargeurGrille - 1 do
          if (x >= LargeurLigne) then
          begin
            if Chitons[y][x - LargeurLigne] = 9 then
              Chitons[y][x] := 1
            else
              Chitons[y][x] := Chitons[y][x - LargeurLigne] + 1;
          end
          else
            Chitons[y][x] := strtoint(lignes[y].Chars[x]);
      end;

    // extrapolation des 4 séries de lignes suivantes à partir de la première série
    while (HauteurGrille < NbLignes * 5) do
    begin
      inc(HauteurGrille);
      setlength(Chitons, HauteurGrille);
      setlength(Chitons[HauteurGrille - 1], LargeurGrille);
      for x := 0 to LargeurGrille - 1 do
        if Chitons[(HauteurGrille - 1) - NbLignes][x] = 9 then
          Chitons[HauteurGrille - 1][x] := 1
        else
          Chitons[HauteurGrille - 1][x] :=
            Chitons[(HauteurGrille - 1) - NbLignes][x] + 1;
    end;
  finally
    lignes.Free;
  end;

  // Initialisation du tableau des valeurs de risque
  setlength(Risk, HauteurGrille);
  for y := 0 to HauteurGrille - 1 do
  begin
    setlength(Risk[y], LargeurGrille);
    for x := 0 to LargeurGrille - 1 do
      Risk[y][x] := CValMax;
  end;

  // Le risque de la case finale prend la valeur de son risque
  Risk[HauteurGrille - 1][LargeurGrille - 1] := Chitons[HauteurGrille - 1]
    [LargeurGrille - 1];

  // Chaque boucle déplace le risque calculé depuis la case finale (en bas à droite) d'un cran vers la gauche et/ou vers le haut.
  // On arrête de boucler lorsque la case d'arrivée a un risque stable deux boucles d'affilée.
  RiskModifie := true;
  while (RiskModifie) do
  begin
    RiskModifie := false;
    // Memo1.Lines.Add(i.ToString + ' ' + Risk[0, 0].ToString);
    for y := 0 to HauteurGrille - 1 do
      for x := 0 to LargeurGrille - 1 do
      begin
        // Chaque case du tableau des risques prend son risque officiel ajouté
        // la valeur de risque (calculé) de la case adjacente la plus faible
        a := CValMax;
        if x < LargeurGrille - 1 then
          a := Risk[y, x + 1] + Chitons[y, x];
        b := CValMax;
        if y < HauteurGrille - 1 then
          b := Risk[y + 1, x] + Chitons[y, x];
        c := CValMax;
        if x > 0 then
          c := Risk[y, x - 1] + Chitons[y, x];
        d := CValMax;
        if y > 0 then
          d := Risk[y - 1, x] + Chitons[y, x];
        z := CValMax;
        if a < z then
          z := a;
        if b < z then
          z := b;
        if c < z then
          z := c;
        if d < z then
          z := d;
        if not((x = Length(Risk[y]) - 1) AND (y = Length(Risk) - 1)) then
        begin // On ne touche pas à la case d'arrivée
          RiskModifie := riskmodifie or (Risk[y, x] <> z);
          Risk[y, x] := z;
        end;
      end;
  end;

  // On prend le risque minimum total rapatrié depuis la case de fin moins celui de la case de début qu'on ne doit pas comptabiliser
  Reponse := Risk[0, 0] - Chitons[0, 0];

  // Affichage du résultat calculé
  AfficheResultat(CJour, CExercice, Reponse);
end;

procedure TForm1.OuvreFichier(NomFichier: string);
begin
  FermeFichier;
  assignfile(Fichier, NomFichier);
  reset(Fichier);
  FichierOuvert := NomFichier;
end;

procedure TForm1.TemplateJour;
Const
  CNumeroFichier = '05';
  // 2 chiffres, en alpha
  CJour = 5; // Numéro du jour
  CExercice = 1; // Numéro exercice
var
  PremiereLigneTraitee: boolean;
  Ligne: string;
  Reponse: uint64;
begin
exit;
  Reponse := 0;
  PremiereLigneTraitee := false;
  repeat
    Ligne := getLigne('..\..\input-' + CNumeroFichier + '.txt');
    try
      if PremiereLigneTraitee then
      begin
      end
      else
      begin
        PremiereLigneTraitee := true;
      end;
    except

    end;
  until FinDeFichier;
  FermeFichier;
  AfficheResultat(CJour, CExercice, Reponse);
end;

{ TJ4_Carte }

constructor TJ4_Carte.Create;
var
  Col, Lig: Integer;
begin
  for Col := 1 to 5 do
    for Lig := 1 to 5 do
      FGrille[Col, Lig] := nil;
  FGagnante := false;
end;

procedure TJ4_Carte.Numero(ACol, ALig, ANumero: Integer);
begin
  if (ACol in [1 .. 5]) and (ALig in [1 .. 5]) then
  begin
    if (FGrille[ACol, ALig] = nil) then
      FGrille[ACol, ALig] := TJ4_Case.Create(ANumero)
    else
    begin
      FGrille[ACol, ALig].FNumero := ANumero;
      FGrille[ACol, ALig].FTire := false;
    end;
  end
  else
    raise exception.Create('Pas dans la grille');
end;

destructor TJ4_Carte.Destroy;
var
  Col, Lig: Integer;
begin
  for Col := 1 to 5 do
    for Lig := 1 to 5 do
      if (FGrille[Col, Lig] <> nil) then
        FGrille[Col, Lig].Free;
  inherited;
end;

function TJ4_Carte.isColonneFinie(ACol: Integer): boolean;
var
  Lig: Integer;
begin
  result := false;
  if (ACol in [1 .. 5]) then
  begin
    result := true;
    for Lig := 1 to 5 do
      result := result and (FGrille[ACol, Lig] <> nil) and
        FGrille[ACol, Lig].FTire;
  end;
end;

function TJ4_Carte.isGrilleGagnanteAvecNumero(ANumero: Integer): boolean;
var
  Col, Lig: Integer;
begin
  result := false;
  for Col := 1 to 5 do
    for Lig := 1 to 5 do
      if (FGrille[Col, Lig] <> nil) and (FGrille[Col, Lig].FNumero = ANumero)
      then
      begin
        FGrille[Col, Lig].FTire := true;
        if isLigneFinie(Lig) or isColonneFinie(Col) then
        begin
          result := true;
          FGagnante := true;
          exit;
        end;
      end;
end;

function TJ4_Carte.isLigneFinie(ALig: Integer): boolean;
var
  Col: Integer;
begin
  result := false;
  if (ALig in [1 .. 5]) then
  begin
    result := true;
    for Col := 1 to 5 do
      result := result and (FGrille[Col, ALig] <> nil) and
        FGrille[Col, ALig].FTire;
  end;
end;

function TJ4_Carte.Numero(ACol, ALig: Integer): Integer;
begin
  if (ACol in [1 .. 5]) and (ALig in [1 .. 5]) and (FGrille[ACol, ALig] <> nil)
  then
    result := FGrille[ACol, ALig].FNumero
  else
    raise exception.Create('Pas dans la grille ou pas de case');
end;

function TJ4_Carte.TotalNumerosNonTires: Integer;
var
  Col, Lig: Integer;
begin
  result := 0;
  for Col := 1 to 5 do
    for Lig := 1 to 5 do
      if (FGrille[Col, Lig] <> nil) and (not FGrille[Col, Lig].FTire) then
        result := result + FGrille[Col, Lig].FNumero;
end;

{ TJ4_Case }

constructor TJ4_Case.Create(ANumero: Integer);
begin
  FNumero := ANumero;
  FTire := false;
end;

{ TJ5_X }

function TJ5_X.getValeur(x, y: Integer): Integer;
begin
  if ContainsKey(x) and items[x].ContainsKey(y) then
    result := items[x].items[y]
  else
    result := 0;
end;

procedure TJ5_X.incremente(x, y: Integer);
begin
  if not ContainsKey(x) then
    Add(x, TJ5_Y.Create);
  if not items[x].ContainsKey(y) then
    items[x].Add(y, 0);
  items[x].items[y] := items[x].items[y] + 1;
end;

{ TCoords }

procedure TCoords.Ajoute(AX, AY: Integer);
var
  coord: TCoord;
  ExisteDeja: boolean;
begin
  ExisteDeja := false;
  for coord in self do
    if (coord.x = AX) and (coord.y = AY) then
    begin
      ExisteDeja := true;
      break;
    end;
  if not ExisteDeja then
    Add(TCoord.Create(AX, AY));
end;

function TCoords.ContientCoordonnees(AX, AY: Integer): boolean;
begin
  result := false;
  for var i := Count - 1 downto 0 do
    if (items[i].x = AX) and (items[i].y = AY) then
    begin
      result := true;
      exit;
    end;
end;

{ TCoord }

constructor TCoord.Create(AX, AY: Integer);
begin
  inherited Create;
  x := AX;
  y := AY;
end;

initialization

ReportMemoryLeaksOnShutdown := true;

end.
