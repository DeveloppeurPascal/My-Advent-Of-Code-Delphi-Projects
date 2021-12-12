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
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

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
  Jour01_1;
  Jour01_2;
  Jour02_1;
  Jour02_2;
  Jour03_1;
  Jour03_2;
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

procedure TForm1.OuvreFichier(NomFichier: string);
begin
  FermeFichier;
  assignfile(Fichier, NomFichier);
  reset(Fichier);
  FichierOuvert := NomFichier;
end;

end.
