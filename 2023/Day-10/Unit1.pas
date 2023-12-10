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

  // Données de test pour exercice 1
  // CDataFile = '..\..\input-test.txt'; // Réponse 4
  // CDataFile = '..\..\input-test2.txt'; // Réponse 8

  // Données de test pour exercice 2
  // CDataFile = '..\..\input-test-ex2_0-result4.txt'; // Réponse 4
  // CDataFile = '..\..\input-test-ex2_1-result4.txt'; // Réponse 4
  // CDataFile = '..\..\input-test-ex2_2-result8.txt'; // Réponse 8
  // CDataFile = '..\..\input-test-ex2_3-result10.txt'; // Réponse 10

type
  TCoord = record
    x, y: integer;
  end;

  TPoly = array of TCoord;

  TPolyBis = array of TPoint;

  TCell = record
    Nord, Est, Sud, Ouest: boolean;
    Start: boolean;
    IsInPath: boolean;
    IsOutside: boolean;
    IsInside: boolean;
  end;

  TGrilleLig = array of TCell;
  TGrille = array of TGrilleLig;

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
    StartLig, StartCol: integer;
    Grille: TGrille;
    procedure GetDataAsGrille(FileName: string);
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
  Lig, Col: integer;
  Prov: char;
begin
  GetDataAsGrille(CDataFile);

  result := 0;
  Lig := StartLig;
  Col := StartCol;
  Prov := ' ';
  repeat
    result := result + 1;
    if Grille[Lig][Col].Nord and (Prov <> 'N') then
    begin
      Prov := 'S';
      Lig := Lig - 1;
    end
    else if Grille[Lig][Col].Sud and (Prov <> 'S') then
    begin
      Prov := 'N';
      Lig := Lig + 1;
    end
    else if Grille[Lig][Col].Est and (Prov <> 'E') then
    begin
      Prov := 'O';
      Col := Col + 1;
    end
    else if Grille[Lig][Col].Ouest and (Prov <> 'O') then
    begin
      Prov := 'E';
      Col := Col - 1;
    end
    else
      raise exception.Create('Chemin perdu.');
  until Grille[Lig][Col].Start;
  // until (Lig = StartLig) and (Col = StartCol);
  result := (result mod 2) + (result div 2);
end;

function TForm1.Exercice2: int64;
  function is_point_in_path(x, y: integer; const poly: TPoly): boolean;
  // ne semble pas fonctionner
  var
    num, i, j: integer;
  begin
    // Determine if the point is on the path, corner, or boundary of the polygon
    //
    // Args:
    // x -- The x coordinates of point.
    // y -- The y coordinates of point.
    // poly -- a list of tuples [(x, y), (x, y), ...]
    //
    // Returns:
    // True if the point is in the path or is a corner or on the boundary"""
    num := length(poly);
    j := num - 1;
    result := false;
    for i := 1 to num - 1 do
      if (x = poly[i].x) and (y = poly[i].y) then
      begin
        // point is a corner
        result := true;
        break;
      end
      else if (poly[i].y > y) <> (poly[j].y > y) then
      begin
        var
        slope := (x - poly[i].x) * (poly[j].y - poly[i].y) -
          (poly[j].x - poly[i].x) * (y - poly[i].y);
        if slope = 0 then
        begin
          // point is on boundary
          result := true;
          exit;
        end;
        if (slope < 0) <> (poly[j].y < poly[i].y) then
          result := not result;
      end;
    j := i;
  end;

  function PointInPolygon(Point: TPoint; const Polygon: TPolyBis): boolean;
  // passe correctement avec le calcul de vecteurs (alternate)
  var
    rgn: HRGN;
  begin
//    rgn := CreatePolygonRgn(Polygon[0], length(Polygon), alternate);
     rgn := CreatePolygonRgn(Polygon[0], length(Polygon), winding);
    result := PtInRegion(rgn, Point.x, Point.y);
    DeleteObject(rgn);
  end;

var
  Lig, Col: integer;
  Prov: char;
  PlusDeModif: boolean;
  IsOut: boolean;
  S: string;
  poly: TPoly; // TCoord
  PolyBis: TPolyBis; // TPoint
  pt: TPoint;
begin
  GetDataAsGrille(CDataFile);

  Lig := StartLig;
  Col := StartCol;
  Prov := ' ';
  repeat
    Grille[Lig][Col].IsInPath := true;
    if Grille[Lig][Col].Nord and (Prov <> 'N') then
    begin
      if (Prov <> 'S') then
      begin
        setlength(poly, length(poly) + 1);
        poly[length(poly) - 1].y := Lig;
        poly[length(poly) - 1].x := Col;
      end;
      Prov := 'S';
      Lig := Lig - 1;
    end
    else if Grille[Lig][Col].Sud and (Prov <> 'S') then
    begin
      if (Prov <> 'N') then
      begin
        setlength(poly, length(poly) + 1);
        poly[length(poly) - 1].y := Lig;
        poly[length(poly) - 1].x := Col;
      end;
      Prov := 'N';
      Lig := Lig + 1;
    end
    else if Grille[Lig][Col].Est and (Prov <> 'E') then
    begin
      if (Prov <> 'O') then
      begin
        setlength(poly, length(poly) + 1);
        poly[length(poly) - 1].y := Lig;
        poly[length(poly) - 1].x := Col;
      end;
      Prov := 'O';
      Col := Col + 1;
    end
    else if Grille[Lig][Col].Ouest and (Prov <> 'O') then
    begin
      if (Prov <> 'E') then
      begin
        setlength(poly, length(poly) + 1);
        poly[length(poly) - 1].y := Lig;
        poly[length(poly) - 1].x := Col;
      end;
      Prov := 'E';
      Col := Col - 1;
    end
    else
      raise exception.Create('Chemin perdu.');
  until Grille[Lig][Col].Start;
  setlength(poly, length(poly) + 1);
  poly[length(poly) - 1].y := Lig;
  poly[length(poly) - 1].x := Col;

  setlength(PolyBis, length(poly));
  for var i := 0 to length(poly) - 1 do
  begin
    PolyBis[i].x := poly[i].x;
    PolyBis[i].y := poly[i].y;
  end;

  // for var i := 0 to length(poly) - 1 do
  // AddLog(poly[i].x.tostring + ',' + poly[i].y.tostring);

{$REGION 'algo valide pour les formes ouvertes avec plusieurs passages, pas optimisé'}
  (*
    repeat
    PlusDeModif := true;
    for Lig := 0 to length(Grille) - 1 do
    for Col := 0 to length(Grille[Lig]) - 1 do
    if (not Grille[Lig][Col].IsInPath) and (not Grille[Lig][Col].IsOutside)
    then
    begin
    Grille[Lig][Col].IsOutside := (Lig = 0) or (Col = 0) or
    (Lig = length(Grille) - 1) or (Col = length(Grille[Lig]) - 1) or
    Grille[Lig - 1][Col].IsOutside or Grille[Lig + 1][Col].IsOutside or
    Grille[Lig][Col - 1].IsOutside or Grille[Lig][Col + 1].IsOutside;
    if Grille[Lig][Col].IsOutside then
    PlusDeModif := false;
    end;
    until PlusDeModif;

    result := 0;
    for Lig := 0 to length(Grille) - 1 do
    for Col := 0 to length(Grille[Lig]) - 1 do
    begin
    Grille[Lig][Col].IsInside :=
    not(Grille[Lig][Col].IsInPath or Grille[Lig][Col].IsOutside);
    if Grille[Lig][Col].IsInside then
    inc(result);
    end;
  *)
{$ENDREGION}
  //
{$REGION 'pas mieux'}
  (*
    // Serait ok, mais finalmeent ne prend pas tout en charge (cas des chemins imbriqués)
    // https://en.wikipedia.org/wiki/Point_in_polygon
    result := 0;
    for Lig := 0 to length(Grille) - 1 do
    begin
    IsOut := true;
    S := '';
    for Col := 0 to length(Grille[Lig]) - 1 do
    begin
    if Grille[Lig][Col].IsInPath then
    begin
    if (not(Grille[Lig][Col].Est and Grille[Lig][Col].Ouest)) then
    IsOut := not IsOut
    end
    else if IsOut then
    Grille[Lig][Col].IsOutside := true
    else
    begin
    Grille[Lig][Col].IsInside := true;
    inc(result);
    end;
    if Grille[Lig][Col].IsInPath then
    S := S + '*'
    else if Grille[Lig][Col].IsOutside then
    S := S + 'O'
    else
    S := S + 'I';
    end;
    AddLog(S);
    end;
  *)
{$ENDREGION}
  //
  // Calcul des positions à partir du polygone du tracé du chemin
  // https://en.wikipedia.org/wiki/Even–odd_rule
  result := 0;
  for Lig := 0 to length(Grille) - 1 do
  begin
    S := '';
    for Col := 0 to length(Grille[Lig]) - 1 do
    begin
      pt.x := Col;
      pt.y := Lig;
      if Grille[Lig][Col].IsInPath then
        S := S + '*'
        // else if is_point_in_path(Col, Lig, poly) then
      else if PointInPolygon(pt, PolyBis) then
      begin
        S := S + 'I';
        result := result + 1;
      end
      else
        S := S + 'O';
    end;
    AddLog(S);
  end;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  Edit1.Text := '';
  Edit2.Text := '';
  Memo1.Clear;
end;

procedure TForm1.GetDataAsGrille(FileName: string);
var
  Lig, Col: integer;
  Lignes: TArray<string>;
  c: char;
  nb: byte;
begin
  Lignes := tfile.ReadAllLines(CDataFile);
  setlength(Grille, length(Lignes));
  for Lig := 0 to length(Lignes) - 1 do
  begin
    setlength(Grille[Lig], length(Lignes[Lig]));
    // | is a vertical pipe connecting north and south.
    // - is a horizontal pipe connecting east and west.
    // L is a 90-degree bend connecting north and east.
    // J is a 90-degree bend connecting north and west.
    // 7 is a 90-degree bend connecting south and west.
    // F is a 90-degree bend connecting south and east.
    // . is ground; there is no pipe in this tile.
    // S is the starting position of the animal; there is a pipe on this tile, but your sketch doesn't show what shape the pipe has.
    for Col := 0 to length(Lignes[Lig]) - 1 do
    begin
      c := Lignes[Lig].Chars[Col];
      Grille[Lig][Col].Nord := c in ['|', 'L', 'J'];
      Grille[Lig][Col].Est := c in ['-', 'L', 'F'];
      Grille[Lig][Col].Sud := c in ['|', '7', 'F'];
      Grille[Lig][Col].Ouest := c in ['-', 'J', '7'];
      Grille[Lig][Col].Start := c = 'S';
      if Grille[Lig][Col].Start then
      begin
        StartLig := Lig;
        StartCol := Col;
      end;
      Grille[Lig][Col].IsInPath := false;
      Grille[Lig][Col].IsOutside := false;
      Grille[Lig][Col].IsInside := false;
    end;
  end;
  // On cherche les destinations possibles sur le Start.
  nb := 0;
  Grille[StartLig][StartCol].Ouest := (StartCol > 0) and
    Grille[StartLig][StartCol - 1].Est;
  if Grille[StartLig][StartCol].Ouest then
    inc(nb);
  Grille[StartLig][StartCol].Est := (StartCol < length(Grille[StartLig]) - 1)
    and Grille[StartLig][StartCol + 1].Ouest;
  if Grille[StartLig][StartCol].Est then
    inc(nb);
  Grille[StartLig][StartCol].Nord := (StartLig > 0) and Grille[StartLig - 1]
    [StartCol].Sud;
  if Grille[StartLig][StartCol].Nord then
    inc(nb);
  Grille[StartLig][StartCol].Sud := (StartLig < length(Grille) - 1) and
    Grille[StartLig + 1][StartCol].Nord;
  if Grille[StartLig][StartCol].Sud then
    inc(nb);
  assert(nb = 2, 'Nombre de connexions sur S différent de 2 (nb=' +
    nb.tostring + ').');
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
