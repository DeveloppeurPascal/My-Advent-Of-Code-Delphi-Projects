unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls;

type
  TForm1 = class(TForm)
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
    procedure AfficheResultat(Jour, Exercice: byte; Reponse: int64);
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
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

Uses
  System.Generics.Collections;

procedure TForm1.AfficheResultat(Jour, Exercice: byte; Reponse: int64);
begin
  Memo1.Lines.Add('Jour ' + Jour.ToString + ' Exercice ' + Exercice.ToString +
    ' Reponse ' + Reponse.ToString);
end;

function TForm1.BinToInt64(Bin: string): int64;
var
  i: integer;
begin
  result := 0;
  for i := 0 to Bin.Length - 1 do
    if (Bin.Chars[i] = '0') then
      result := result * 2
    else
      result := result * 2 + 1;
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
  Jour01_1;
  Jour01_2;
  // https://adventofcode.com/2021/day/2
  Jour02_1;
  Jour02_2;
  // https://adventofcode.com/2021/day/3
  Jour03_1;
  Jour03_2;
  // https://adventofcode.com/2021/day/4
  Jour04_1;
  Jour04_2;
end;

function TForm1.getLigne(NomFichier: string): string;
begin
  if (NomFichier <> FichierOuvert) then
    OuvreFichier(NomFichier);
  if (not FinDeFichier) then
    readln(Fichier, result);
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
  GammaRate: integer;
  // composé par les bits les plus présents dans chaque colonne du fichier
  EpsilonRate: integer;
  // composé par les bits les moins présents dans chaque colonne du fichier
  Tab: array of TTabBin; // Nombre d'occurrence de 0/1 par colonne
  PremiereLigne: boolean;
  i: integer;
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
    FNumero: integer;
    FTire: boolean;
    constructor Create(ANumero: integer);
  end;

  TJ4_Grille = array [1 .. 5, 1 .. 5] of TJ4_Case;

  TJ4_Carte = class
  public
    FGrille: TJ4_Grille;
    FGagnante: boolean;
    procedure Numero(ACol, ALig, ANumero: integer); overload;
    function Numero(ACol, ALig: integer): integer; overload;
    function isLigneFinie(ALig: integer): boolean;
    function isColonneFinie(ACol: integer): boolean;
    function isGrilleGagnanteAvecNumero(ANumero: integer): boolean;
    function TotalNumerosNonTires: integer;
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
  numCol, NumLig, Numero: integer;
  Board: TJ4_Carte;
  ListeCartes: TJ4_ListeDeCartes;
  NumeroTire: integer;
  i: integer;
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
  numCol, NumLig, Numero: integer;
  Board, DerniereGrilleGagnante: TJ4_Carte;
  ListeCartes: TJ4_ListeDeCartes;
  NumeroTire, DernierNumeroTire: integer;
  i: integer;
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

procedure TForm1.OuvreFichier(NomFichier: string);
begin
  FermeFichier;
  assignfile(Fichier, NomFichier);
  reset(Fichier);
  FichierOuvert := NomFichier;
end;

{ TJ4_Carte }

constructor TJ4_Carte.Create;
var
  col, lig: integer;
begin
  for col := 1 to 5 do
    for lig := 1 to 5 do
      FGrille[col, lig] := nil;
  FGagnante := false;
end;

procedure TJ4_Carte.Numero(ACol, ALig, ANumero: integer);
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
  col, lig: integer;
begin
  for col := 1 to 5 do
    for lig := 1 to 5 do
      if (FGrille[col, lig] <> nil) then
        FGrille[col, lig].Free;
  inherited;
end;

function TJ4_Carte.isColonneFinie(ACol: integer): boolean;
var
  lig: integer;
begin
  result := false;
  if (ACol in [1 .. 5]) then
  begin
    result := true;
    for lig := 1 to 5 do
      result := result and (FGrille[ACol, lig] <> nil) and
        FGrille[ACol, lig].FTire;
  end;
end;

function TJ4_Carte.isGrilleGagnanteAvecNumero(ANumero: integer): boolean;
var
  col, lig: integer;
begin
  result := false;
  for col := 1 to 5 do
    for lig := 1 to 5 do
      if (FGrille[col, lig] <> nil) and (FGrille[col, lig].FNumero = ANumero)
      then
      begin
        FGrille[col, lig].FTire := true;
        if isLigneFinie(lig) or isColonneFinie(col) then
        begin
          result := true;
          FGagnante := true;
          exit;
        end;
      end;
end;

function TJ4_Carte.isLigneFinie(ALig: integer): boolean;
var
  col: integer;
begin
  result := false;
  if (ALig in [1 .. 5]) then
  begin
    result := true;
    for col := 1 to 5 do
      result := result and (FGrille[col, ALig] <> nil) and
        FGrille[col, ALig].FTire;
  end;
end;

function TJ4_Carte.Numero(ACol, ALig: integer): integer;
begin
  if (ACol in [1 .. 5]) and (ALig in [1 .. 5]) and (FGrille[ACol, ALig] <> nil)
  then
    result := FGrille[ACol, ALig].FNumero
  else
    raise exception.Create('Pas dans la grille ou pas de case');
end;

function TJ4_Carte.TotalNumerosNonTires: integer;
var
  col, lig: integer;
begin
  result := 0;
  for col := 1 to 5 do
    for lig := 1 to 5 do
      if (FGrille[col, lig] <> nil) and (not FGrille[col, lig].FTire) then
        result := result + FGrille[col, lig].FNumero;
end;

{ TJ4_Case }

constructor TJ4_Case.Create(ANumero: integer);
begin
  FNumero := ANumero;
  FTire := false;
end;

end.
