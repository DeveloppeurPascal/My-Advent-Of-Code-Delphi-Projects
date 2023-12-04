unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.WinXCtrls, Vcl.StdCtrls;

Const
  CDataFile = '..\..\input.txt';
  // CDataFile = '..\..\input-test.txt';

type
  TForm1 = class(TForm)
    Button1: TButton;
    ActivityIndicator1: TActivityIndicator;
    Button2: TButton;
    Edit1: TEdit;
    Edit2: TEdit;
    Memo1: TMemo;
    Button3: TButton;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    procedure BeginTraitement;
    procedure EndTraitement;
    { Déclarations privées }
    function Exercice1: cardinal;
    function Exercice2: cardinal;
    function Exercice2Bis: cardinal;
    procedure AddLog(Const S: String);
    function MsToTimeString(ms: int64): string;
  public
    { Déclarations publiques }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

uses
  System.Math,
  System.DateUtils,
  System.RegularExpressions,
  System.Diagnostics,
  System.Generics.Collections,
  System.Generics.Defaults,
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
              if string((Sender as TButton).Name).endswith('3') then
                Edit2.Text := Exercice2Bis.tostring
              else
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

function TForm1.Exercice1: cardinal;
var
  Lignes: TArray<string>;
  i: integer;
  CurrentNumber: cardinal;
  j: integer;
  NumberValid: boolean;
begin
  Lignes := tfile.ReadAllLines(CDataFile);
  result := 0;
  for i := 0 to length(Lignes) - 1 do
  begin
    NumberValid := false;
    CurrentNumber := 0;
    for j := 0 to length(Lignes[i]) - 1 do
    begin
      if Lignes[i].Chars[j] in ['0' .. '9'] then
      begin
        CurrentNumber := CurrentNumber * 10 + strtoint(Lignes[i].Chars[j]);
        if not NumberValid then
        begin
          // à gauche du chiffre
          NumberValid := (j > 0) and
            (not(Lignes[i].Chars[j - 1] in ['0' .. '9', '.']));
          // en haut à gauche du chiffre
          NumberValid := NumberValid or
            ((j > 0) and (i > 0) and
            (not(Lignes[i - 1].Chars[j - 1] in ['0' .. '9', '.'])));
          // en bas à gauche du chiffre
          NumberValid := NumberValid or
            ((j > 0) and (i < length(Lignes) - 1) and
            (not(Lignes[i + 1].Chars[j - 1] in ['0' .. '9', '.'])));
          // à droite du chiffre
          NumberValid := NumberValid or
            ((j < length(Lignes[i]) - 1) and
            (not(Lignes[i].Chars[j + 1] in ['0' .. '9', '.'])));
          // en haut à droite du chiffre
          NumberValid := NumberValid or
            ((i > 0) and (j < length(Lignes[i - 1]) - 1) and
            (not(Lignes[i - 1].Chars[j + 1] in ['0' .. '9', '.'])));
          // en bas à droite du chiffre
          NumberValid := NumberValid or
            ((i < length(Lignes) - 1) and (j < length(Lignes[i + 1]) - 1) and
            (not(Lignes[i + 1].Chars[j + 1] in ['0' .. '9', '.'])));
          // au dessus du chiffre
          NumberValid := NumberValid or
            ((i > 0) and (not(Lignes[i - 1].Chars[j] in ['0' .. '9', '.'])));
          // sous le chiffre
          NumberValid := NumberValid or
            ((i < length(Lignes) - 1) and
            (not(Lignes[i + 1].Chars[j] in ['0' .. '9', '.'])));
        end;
      end
      else if NumberValid then
      begin
        // AddLog('Ok : ' + CurrentNumber.tostring);
        result := result + CurrentNumber;
        NumberValid := false;
        CurrentNumber := 0;
      end
      else if (CurrentNumber > 0) then
      begin
        // AddLog('Not Ok : ' + CurrentNumber.tostring);
        CurrentNumber := 0;
      end;
    end;
    if NumberValid then
      result := result + CurrentNumber;
  end;
end;

function TForm1.Exercice2: cardinal;
  function getNumber(const Lignes: TArray<string>; const Col, Lig: integer;
  out StartCol, EndCol: integer; Out Number: cardinal): boolean;
  var
    i: integer;
  begin
    if (Lig < 0) or (Lig > length(Lignes) - 1) or (Lig < 0) or
      (Lig > length(Lignes) - 1) then
    begin
{$IFDEF DEBUG}
      raise exception.Create
        ('Ce cas ne doit jamais se produire si les tests lors de l''appel sont corrects.');
{$ENDIF}
      result := false;
      exit;
    end;
    if Lignes[Lig].Chars[Col] in ['0' .. '9'] then
    begin
      result := true;
      StartCol := 0;
      EndCol := 0;
      for i := Col downto 0 do
        if Lignes[Lig].Chars[i] in ['0' .. '9'] then
          StartCol := i
        else
          break;
      Number := 0;
      for i := StartCol to length(Lignes[Lig]) - 1 do
        if Lignes[Lig].Chars[i] in ['0' .. '9'] then
        begin
          EndCol := i;
          Number := Number * 10 + strtoint(Lignes[Lig].Chars[i]);
        end
        else
          break;
    end
    else
      result := false;
  end;

var
  Lig, Col: integer;
  Lignes: TArray<string>;
  CurrentNumber: cardinal;
  MultOk: boolean;
  StartCol, EndCol: integer;
  NewNumber: cardinal;
begin
  Lignes := tfile.ReadAllLines(CDataFile);
  result := 0;
  for Lig := 0 to length(Lignes) - 1 do
    for Col := 0 to length(Lignes[Lig]) - 1 do
      if (Lignes[Lig].Chars[Col] = '*') then
      begin
        MultOk := false;
        CurrentNumber := 0;
        // à gauche de l'étoile
        if (Col > 0) and getNumber(Lignes, Col - 1, Lig, StartCol, EndCol,
          NewNumber) then
          CurrentNumber := NewNumber;
        // à droite de l'étoile
        if (Col < length(Lignes[Lig]) - 1) and getNumber(Lignes, Col + 1, Lig,
          StartCol, EndCol, NewNumber) then
          if (CurrentNumber <> 0) then
          begin
            CurrentNumber := CurrentNumber * NewNumber;
            MultOk := true;
          end
          else
            CurrentNumber := NewNumber;
        // Au dessus de l'étoile
        if (Lig > 0) then
        begin
          EndCol := 0;
          if (Col > 0) and getNumber(Lignes, Col - 1, Lig - 1, StartCol, EndCol,
            NewNumber) then
            if (CurrentNumber <> 0) then
            begin
              CurrentNumber := CurrentNumber * NewNumber;
              MultOk := true;
            end
            else
              CurrentNumber := NewNumber;
          if (Col > EndCol) and getNumber(Lignes, Col, Lig - 1, StartCol,
            EndCol, NewNumber) then
            if (CurrentNumber <> 0) then
            begin
              CurrentNumber := CurrentNumber * NewNumber;
              MultOk := true;
            end
            else
              CurrentNumber := NewNumber;
          if (Col > EndCol) and (Col < length(Lignes[Lig]) - 1) and
            getNumber(Lignes, Col + 1, Lig - 1, StartCol, EndCol, NewNumber)
          then
            if (CurrentNumber <> 0) then
            begin
              CurrentNumber := CurrentNumber * NewNumber;
              MultOk := true;
            end
            else
              CurrentNumber := NewNumber;
        end;
        // Sous l'étoile
        if (Lig < length(Lignes) - 1) then
        begin
          EndCol := 0;
          if (Col > 0) and getNumber(Lignes, Col - 1, Lig + 1, StartCol, EndCol,
            NewNumber) then
            if (CurrentNumber <> 0) then
            begin
              CurrentNumber := CurrentNumber * NewNumber;
              MultOk := true;
            end
            else
              CurrentNumber := NewNumber;
          if (Col > EndCol) and getNumber(Lignes, Col, Lig + 1, StartCol,
            EndCol, NewNumber) then
            if (CurrentNumber <> 0) then
            begin
              CurrentNumber := CurrentNumber * NewNumber;
              MultOk := true;
            end
            else
              CurrentNumber := NewNumber;
          if (Col > EndCol) and (Col < length(Lignes[Lig]) - 1) and
            getNumber(Lignes, Col + 1, Lig + 1, StartCol, EndCol, NewNumber)
          then
            if (CurrentNumber <> 0) then
            begin
              CurrentNumber := CurrentNumber * NewNumber;
              MultOk := true;
            end
            else
              CurrentNumber := NewNumber;
        end;

        if MultOk then
          result := result + CurrentNumber;
      end;
end;

type
  TEtoile = class
  public
    Value: cardinal;
    AuMoinsDeux: boolean;
    constructor Create;
  end;

  TEtoiles = TObjectDictionary<cardinal, TEtoile>;

function TForm1.Exercice2Bis: cardinal;
var
  Lignes: TArray<string>;
  i: integer;
  CurrentNumber: cardinal;
  j: integer;
  etoile: TEtoile;
  ListeEtoiles: TEtoiles;
  prevcoord, Coord: cardinal;
  ListeCoord: TList<cardinal>;
  NbColParLigne: integer;
  // stocker liste de coordonnées des étoiles avec la valeur en cours et le fait d'avoir 2 nombres multipliés
  // lors du parcours, pour chaque chiffre on regarde si une étoile est présente (au lieu du test d'avant)
  // si c'est oui, on liste les coordonnées de la ou des étoiles concernées par ce nombre
  // en fin de parcours du nombre, on traite la multiplication liée aux étoiles trouvées pour lui
  // en fin de fichier on cumule le total des valeurs des étoiles ayant eu des nombres multipliés entre eux
begin
  ListeEtoiles := TEtoiles.Create([doOwnsValues]);
  try
    ListeCoord := TList<cardinal>.Create;
    try
      Lignes := tfile.ReadAllLines(CDataFile);
      result := 0;
      NbColParLigne := length(Lignes[0]);
      // on suppose que la ligne n'est pas vide et
      // que le nombre de caractères est le même sur chaque
      for i := 0 to length(Lignes) - 1 do
      begin
        CurrentNumber := 0;
        ListeCoord.Clear;
        for j := 0 to length(Lignes[i]) - 1 do
        begin
          if Lignes[i].IsEmpty then
            continue;

          if Lignes[i].Chars[j] in ['0' .. '9'] then
          begin
            CurrentNumber := CurrentNumber * 10 + strtoint(Lignes[i].Chars[j]);

            // à gauche du chiffre
            if (j > 0) and (Lignes[i].Chars[j - 1] = '*') then
              ListeCoord.Add(i * NbColParLigne + j - 1);

            // en haut à gauche du chiffre
            if ((j > 0) and (i > 0) and (Lignes[i - 1].Chars[j - 1] = '*')) then
              ListeCoord.Add((i - 1) * NbColParLigne + j - 1);

            // en bas à gauche du chiffre
            if ((j > 0) and (i < length(Lignes) - 1) and
              (Lignes[i + 1].Chars[j - 1] = '*')) then
              ListeCoord.Add((i + 1) * NbColParLigne + j - 1);

            // à droite du chiffre
            if ((j < length(Lignes[i]) - 1) and (Lignes[i].Chars[j + 1] = '*'))
            then
              ListeCoord.Add(i * NbColParLigne + j + 1);

            // en haut à droite du chiffre
            if ((i > 0) and (j < length(Lignes[i - 1]) - 1) and
              (Lignes[i - 1].Chars[j + 1] = '*')) then
              ListeCoord.Add((i - 1) * NbColParLigne + j + 1);

            // en bas à droite du chiffre
            if ((i < length(Lignes) - 1) and (j < length(Lignes[i + 1]) - 1) and
              (Lignes[i + 1].Chars[j + 1] = '*')) then
              ListeCoord.Add((i + 1) * NbColParLigne + j + 1);

            // au dessus du chiffre
            if ((i > 0) and (Lignes[i - 1].Chars[j] = '*')) then
              ListeCoord.Add((i - 1) * NbColParLigne + j);

            // sous le chiffre
            if ((i < length(Lignes) - 1) and (Lignes[i + 1].Chars[j] = '*'))
            then
              ListeCoord.Add((i + 1) * NbColParLigne + j);
          end
          else if (ListeCoord.Count > 0) then
          begin
            // AddLog('Ok : ' + CurrentNumber.tostring);
            prevcoord := high(cardinal);
            ListeCoord.Sort(TComparer<cardinal>.Construct(
              function(const a, b: cardinal): integer
              begin
                if a = b then
                  result := 0
                else if a < b then
                  result := -1
                else
                  result := 1;
              end));
            for Coord in ListeCoord do
              if (Coord <> prevcoord) then
              begin
                prevcoord := Coord;
                if not ListeEtoiles.TryGetValue(Coord, etoile) then
                begin
                  etoile := TEtoile.Create;
                  etoile.Value := CurrentNumber;
                  ListeEtoiles.Add(Coord, etoile);
                end
                else
                begin
                  etoile.Value := etoile.Value * CurrentNumber;
                  etoile.AuMoinsDeux := true;
                end;
              end;
            CurrentNumber := 0;
            ListeCoord.Clear;
          end
          else if (CurrentNumber > 0) then
          begin
            // AddLog('Not Ok : ' + CurrentNumber.tostring);
            CurrentNumber := 0;
          end;
        end;
        if (ListeCoord.Count > 0) then
        begin
          // AddLog('Ok : ' + CurrentNumber.tostring);
          prevcoord := high(cardinal);
          ListeCoord.Sort(TComparer<cardinal>.Construct(
            function(const a, b: cardinal): integer
            begin
              if a = b then
                result := 0
              else if a < b then
                result := -1
              else
                result := 1;
            end));
          for Coord in ListeCoord do
            if (Coord <> prevcoord) then
            begin
              prevcoord := Coord;
              if not ListeEtoiles.TryGetValue(Coord, etoile) then
              begin
                etoile := TEtoile.Create;
                etoile.Value := CurrentNumber;
                ListeEtoiles.Add(Coord, etoile);
              end
              else
              begin
                etoile.Value := etoile.Value * CurrentNumber;
                etoile.AuMoinsDeux := true;
              end;
            end;
          CurrentNumber := 0;
          ListeCoord.Clear;
        end;
      end;
      // calcul final
      result := 0;
      for etoile in ListeEtoiles.Values do
        if etoile.AuMoinsDeux then
          result := result + etoile.Value;
    finally
      ListeCoord.Free;
    end;
  finally
    ListeEtoiles.Free;
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

{ TEtoile }

constructor TEtoile.Create;
begin
  Value := 0;
  AuMoinsDeux := false;
end;

end.
