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
  TTile = (Path, Forest, SlopeUp, SlopeDown, SlopeRight, SlopeLeft);

  TMap = array of array of TTile;

  TChemin = TList<int64>;

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
    procedure LoadMap(WithSlopes: boolean = true);
    function PromeneSurLaMap: int64;
    procedure DrawMap(CheminParcouru: TChemin = nil);
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

procedure TForm1.DrawMap(CheminParcouru: TChemin);
var
  x, y: integer;
  S: string;
  nblig, nbcol: integer;
begin
  nblig := length(Map);
  nbcol := length(Map[0]);
  for y := 0 to nblig - 1 do
  begin
    S := '';
    for x := 0 to length(Map[y]) - 1 do
      if assigned(CheminParcouru) and CheminParcouru.contains(x + y * nbcol)
      then
        S := S + 'O'
      else
        case Map[y, x] of
          TTile.Path:
            S := S + '.';
          TTile.Forest:
            S := S + '#';
          TTile.SlopeUp:
            S := S + '^';
          TTile.SlopeDown:
            S := S + 'v';
          TTile.SlopeRight:
            S := S + '>';
          TTile.SlopeLeft:
            S := S + '<';
        end;
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
begin
  LoadMap;
  // DrawMap;
  result := PromeneSurLaMap;
end;

function TForm1.Exercice2: int64;
begin
  LoadMap(false);
  // DrawMap;
  result := PromeneSurLaMap;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  Edit1.Text := '';
  Edit2.Text := '';
  Memo1.Clear;
end;

procedure TForm1.LoadMap(WithSlopes: boolean);
var
  Lig: integer;
  Lignes: TArray<string>;
  nblig, nbcol: integer;
  x, y: integer;
begin
  Lignes := tfile.ReadAllLines(CDataFile);
  nblig := length(Lignes);
  nbcol := length(Lignes[0]);
  setlength(Map, nblig);
  y := 0;
  for Lig := 0 to nblig - 1 do
  begin
    if Lignes[Lig].trim.isempty then
      continue;
    setlength(Map[y], nbcol);
    for x := 0 to nbcol - 1 do
      if WithSlopes then
        case Lignes[Lig].Chars[x] of
          '.':
            Map[y, x] := TTile.Path;
          '#':
            Map[y, x] := TTile.Forest;
          '^':
            Map[y, x] := TTile.SlopeUp;
          '>':
            Map[y, x] := TTile.SlopeRight;
          'v':
            Map[y, x] := TTile.SlopeDown;
          '<':
            Map[y, x] := TTile.SlopeLeft;
        else
          raise exception.create('Unknow tile "' + Lignes[Lig].Chars[x] +
            '" in line ' + Lig.tostring + '.');
        end
      else
        case Lignes[Lig].Chars[x] of
          '#':
            Map[y, x] := TTile.Forest;
        else
          Map[y, x] := TTile.Path;
        end;
    inc(y);
  end;
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

function TForm1.PromeneSurLaMap: int64;
  function Chemine(x, y, VX, VY: integer; CheminParcouru: TChemin;
  Steps: int64): int64;
  var
    nbcol, nblig: integer;
    PosXY: integer;
    CurrentStep: int64;
    PasDeMouvement: boolean;
    res: int64;
  begin
    nblig := length(Map);
    nbcol := length(Map[0]);
    // AddLog(Steps.tostring + ' ' + nblig.tostring + 'x' + nbcol.tostring);

    result := 0;
    CurrentStep := 0;

    repeat
      PasDeMouvement := true;
      if (x + VX < nbcol) and (y + VY < nblig) and (x + VX >= 0) and
        (y + VY >= 0) then // dans la grille
      begin
        if (Map[y + VY, x + VX] = TTile.Forest) or
          ((VX = -1) and (Map[y + VY, x + VX] = TTile.SlopeRight)) or
          ((VX = +1) and (Map[y + VY, x + VX] = TTile.SlopeLeft)) or
          ((VY = -1) and (Map[y + VY, x + VX] = TTile.SlopeDown)) or
          ((VY = +1) and (Map[y + VY, x + VX] = TTile.SlopeUp)) then
          // case interdite
          // AddLog('case interdite')
        else
        begin // case autorisée
          PosXY := x + VX + (y + VY) * nbcol;
          // AddLog(PosXY.tostring);
          if CheminParcouru.contains(PosXY) then
            // deja passé par là
            // AddLog('deja passe par la')
          else
          begin // pas encore passé par là
            inc(CurrentStep);
            x := x + VX;
            y := y + VY;
            PasDeMouvement := false;
            CheminParcouru.Add(PosXY);
            if Map[y, x] in [TTile.SlopeUp, TTile.SlopeDown, TTile.SlopeLeft,
              TTile.SlopeRight] then
            begin
              inc(CurrentStep);
              x := x + VX;
              y := y + VY;
              PosXY := x + y * nbcol;
              CheminParcouru.Add(PosXY);
            end;
          end;
        end;
      end
      else
        AddLog('hors grille');
      if not PasDeMouvement then
      begin
        res := Chemine(x, y, VY, VX, CheminParcouru, Steps + CurrentStep);
        if res > result then
          result := res;
        res := Chemine(x, y, -VY, -VX, CheminParcouru, Steps + CurrentStep);
        if res > result then
          result := res;
      end;
    until (y = nblig - 1) or PasDeMouvement;

    // DrawMap(CheminParcouru);

    // Si on a trouvé une sortie, c'est ce chemin qui compte
    if (y = nblig - 1) then
    begin
      result := Steps + CurrentStep;
      // AddLog('result : ' + result.tostring);
    end;

    // Dépile les déplacement de cette étape
    while (CheminParcouru.count > Steps) do
      CheminParcouru.delete(CheminParcouru.count - 1);
  end;

var
  x, y, VX, VY: integer;
  CheminParcouru: TChemin;
begin
  y := 0;
  x := 0;
  while (Map[y, x] <> TTile.Path) do
    inc(x);
  // X,Y correspondent aux coordonnées de départ
  VX := 0;
  VY := 1;
  // On descend par défaut
  CheminParcouru := TChemin.create;
  try
    result := Chemine(x, y, VX, VY, CheminParcouru, 0);
  finally
    CheminParcouru.free;
  end;
end;

initialization

{$IFDEF DEBUG}
  ReportMemoryLeaksOnShutdown := true;
{$ENDIF}

end.
