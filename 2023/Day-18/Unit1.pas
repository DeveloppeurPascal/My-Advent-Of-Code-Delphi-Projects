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
  // CDataFile = '..\..\input.txt';
  CDataFile = '..\..\input-test.txt';

type
  TPolygone = array of TPoint;
  TGrille = array of array of boolean;

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
    Grille: TGrille;
    procedure DrawGrille;
    // cf https://en.wikipedia.org/wiki/Point_in_polygon
    function PointInPolygon(Point: TPoint; const Polygon: TPolygone): boolean;
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

procedure TForm1.DrawGrille;
var
  x, y: int64;
  S: string;
begin
  for y := 0 to length(Grille[0]) - 1 do
  begin
    S := '';
    for x := 0 to length(Grille) - 1 do
      S := S + ifthen(Grille[x, y], 'X', '.');
    AddLog(S);
  end;
  AddLog(' ');
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
  Lig: int64;
  Lignes: TArray<string>;
  Tab: TArray<string>;
  Polygone: TPolygone;
  x, y: int64;
  XMin, YMin, XMax, YMax: int64;
  vx, vy: int64;
  Direction: char;
  NbCases: int64;
  NBPoints: int64;
  i: int64;
begin
  XMin := maxint;
  YMin := maxint;
  XMax := -maxint;
  YMax := -maxint;
  AddLog(XMin.tostring + ' / ' + XMax.tostring + ' / ' + YMin.tostring + ' / ' +
    YMax.tostring);

  Lignes := tfile.ReadAllLines(CDataFile);

  setlength(Polygone, length(Lignes) + 1);

  x := 0;
  y := 0;
  Polygone[0] := TPoint.Create(x, y);
  NBPoints := 1;
  vx := 0;
  vy := -1;

  // On "dessine" un polygone avec les données fournies.
  for Lig := 0 to length(Lignes) - 1 do
  begin
    if Lignes[Lig].isempty then
    begin
      setlength(Polygone, length(Polygone) - 1);
      continue;
    end;

    Tab := Lignes[Lig].split([' ']);
    Direction := Tab[0].Chars[0];
    NbCases := Tab[1].toint64;
    case Direction of
      'U': // up
        begin
          vx := 0;
          vy := -1;
        end;
      'R': // right
        begin
          vx := 1;
          vy := 0;
        end;
      'D': // down
        begin
          vx := 0;
          vy := 1;
        end;
      'L': // left
        begin
          vx := -1;
          vy := 0;
        end;
    end;
    x := x + vx * NbCases;
    y := y + vy * NbCases;
    Polygone[NBPoints] := TPoint.Create(x, y);
    inc(NBPoints);

    // On enregistre les extrémités de la zone de stockage du polygone.
    if XMin > x then
      XMin := x;
    if XMax < x then
      XMax := x;
    if YMin > y then
      YMin := y;
    if YMax < y then
      YMax := y;
  end;
  AddLog(XMin.tostring + ' / ' + XMax.tostring + ' / ' + YMin.tostring + ' / ' +
    YMax.tostring);

  assert((Polygone[0].x = Polygone[NBPoints - 1].x) and
    (Polygone[0].y = Polygone[NBPoints - 1].y), 'Polygone non fermé.');

  // On parcourt tous les points dans la zone pour savoir s'ils sont dans ou hors du polygone.
  setlength(Grille, XMax - XMin + 1);
  for x := XMin to XMax do
  begin
    setlength(Grille[x - XMin], YMax - YMin + 1);
    for y := YMin to YMax do
      try
        Grille[x - XMin, y - YMin] := PointInPolygon(TPoint.Create(x, y),
          Polygone);
      except
        AddLog('Bug : ' + x.tostring + ',' + y.tostring);
      end;
  end;

  DrawGrille;

  // On ajoute le contour car l'algorithme de test ne prend pas les bordures en bas et à droite
  x := Polygone[0].x;
  y := Polygone[0].y;
  for i := 1 to length(Polygone) - 1 do
    while (x <> Polygone[i].x) or (y <> Polygone[i].y) do
    begin
      Grille[x - XMin, y - YMin] := true;
      if x < Polygone[i].x then
        x := x + 1
      else if x > Polygone[i].x then
        x := x - 1;
      if y < Polygone[i].y then
        y := y + 1
      else if y > Polygone[i].y then
        y := y - 1;
    end;

  DrawGrille;

  // On compte le nombre de "true" dans la grille.
  result := 0;
  for x := XMin to XMax do
    for y := YMin to YMax do
      if Grille[x - XMin, y - YMin] then
      begin
        result := result + 1;
        // AddLog('OK : ' + x.tostring + ',' + y.tostring);
      end
  // else
  // AddLog('NOK : ' + x.tostring + ',' + y.tostring);
end;

function TForm1.Exercice2: int64;
var
  Lig: int64;
  Lignes: TArray<string>;
  Tab: TArray<string>;
  Polygone: TPolygone;
  x, y: int64;
  XMin, YMin, XMax, YMax: int64;
  vx, vy: int64;
  Direction: char;
  NbCases: int64;
  NBPoints: int64;
  i: int64;
begin
  XMin := maxint;
  YMin := maxint;
  XMax := -maxint;
  YMax := -maxint;
  AddLog(XMin.tostring + ' / ' + XMax.tostring + ' / ' + YMin.tostring + ' / ' +
    YMax.tostring);

  Lignes := tfile.ReadAllLines(CDataFile);

  setlength(Polygone, length(Lignes) + 1);

  x := 0;
  y := 0;
  Polygone[0] := TPoint.Create(x, y);
  NBPoints := 1;
  vx := 0;
  vy := -1;

  // On "dessine" un polygone avec les données fournies.
  AddLog('1/4 - Calcul polygone');
  for Lig := 0 to length(Lignes) - 1 do
  begin
    if Lignes[Lig].isempty then
    begin
      setlength(Polygone, length(Polygone) - 1);
      continue;
    end;

    Tab := Lignes[Lig].split([' ']);
    Tab[2]:=Tab[2].ToUpper.substring(2,length(Tab[2])-3); // "(#"+xxxxxx+")"

    Direction := Tab[2].Chars[length(Tab[2]) - 1];
    case Direction of
      '3': // up
        begin
          vx := 0;
          vy := -1;
        end;
      '0': // right
        begin
          vx := 1;
          vy := 0;
        end;
      '1': // down
        begin
          vx := 0;
          vy := 1;
        end;
      '2': // left
        begin
          vx := -1;
          vy := 0;
        end;
    end;

//    var s : string := '';
    NbCases := 0;
    for i := 0 to (length(Tab[2])- 2) do begin
    // on retire le '#' et la direction en fin de chaine
      case Tab[2].Chars[i] of
        '0' .. '9':
          NbCases := NbCases * 16 + ord(Tab[2].Chars[i]) - ord('0');
        'A' .. 'F':
          NbCases := NbCases * 16 + ord(Tab[2].Chars[i]) - ord('A') + 10;
          else
          addlog('erreur');
      end;
//      addlog(nbcases.tostring);
//      s := Tab[2].Chars[i]+s;
    end;
//    AddLog('"'+Tab[2]+'" '+Direction+'-'+s+' => '+NbCases.tostring);

    x := x + vx * NbCases;
    y := y + vy * NbCases;
    Polygone[NBPoints] := TPoint.Create(x, y);
    inc(NBPoints);

    // On enregistre les extrémités de la zone de stockage du polygone.
    if XMin > x then
      XMin := x;
    if XMax < x then
      XMax := x;
    if YMin > y then
      YMin := y;
    if YMax < y then
      YMax := y;
  end;
  AddLog(XMin.tostring + ' / ' + XMax.tostring + ' / ' + YMin.tostring + ' / ' +
    YMax.tostring);

  assert((Polygone[0].x = Polygone[NBPoints - 1].x) and
    (Polygone[0].y = Polygone[NBPoints - 1].y), 'Polygone non fermé.');

  // On parcourt tous les points dans la zone pour savoir s'ils sont dans ou hors du polygone.
  AddLog('2/4 - Test contenu du polygone');
  setlength(Grille, XMax - XMin + 1);
  for x := XMin to XMax do
  begin
    setlength(Grille[x - XMin], YMax - YMin + 1);
    for y := YMin to YMax do
      try
        Grille[x - XMin, y - YMin] := PointInPolygon(TPoint.Create(x, y),
          Polygone);
      except
        AddLog('Bug : ' + x.tostring + ',' + y.tostring);
      end;
  end;

  // DrawGrille;

  // On ajoute le contour car l'algorithme de test ne prend pas les bordures en bas et à droite
  AddLog('3/4 - Dessine polygone');
  x := Polygone[0].x;
  y := Polygone[0].y;
  for i := 1 to length(Polygone) - 1 do
    while (x <> Polygone[i].x) or (y <> Polygone[i].y) do
    begin
      Grille[x - XMin, y - YMin] := true;
      if x < Polygone[i].x then
        x := x + 1
      else if x > Polygone[i].x then
        x := x - 1;
      if y < Polygone[i].y then
        y := y + 1
      else if y > Polygone[i].y then
        y := y - 1;
    end;

  // DrawGrille;

  // On compte le nombre de "true" dans la grille.
  AddLog('4/4 - Comptage');
  result := 0;
  for x := XMin to XMax do
    for y := YMin to YMax do
      if Grille[x - XMin, y - YMin] then
      begin
        result := result + 1;
        // AddLog('OK : ' + x.tostring + ',' + y.tostring);
      end
  // else
  // AddLog('NOK : ' + x.tostring + ',' + y.tostring);
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

function TForm1.PointInPolygon(Point: TPoint; const Polygon: TPolygone)
  : boolean;
var
  rgn: HRGN;
begin
  rgn := CreatePolygonRgn(Polygon[0], length(Polygon), alternate);
  // rgn := CreatePolygonRgn(Polygon[0], length(Polygon), winding);
  result := PtInRegion(rgn, Point.x, Point.y);
  DeleteObject(rgn);
end;

initialization

{$IFDEF DEBUG}
  ReportMemoryLeaksOnShutdown := true;
{$ENDIF}

end.
