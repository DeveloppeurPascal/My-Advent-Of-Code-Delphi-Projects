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
   CAreaMinEx1 = 200000000000000;
   CAreaMaxEx1 = 400000000000000;
//  CDataFile = '..\..\input-test.txt';
//  CAreaMinEx1 = 7;
//  CAreaMaxEx1 = 27;

type
  THailstone = class
  private
    FvZ: int64;
    FvX: int64;
    FvY: int64;
    FZ: int64;
    FX: int64;
    FY: int64;
    FXOutArray: int64;
    FYOutArray: int64;
    FXInArray: int64;
    FYInArray: int64;
    FTempsXMax: extended;
    FTempsXMin: extended;
    FTempsYMax: extended;
    FTempsYMin: extended;
    FB: extended;
    FA: extended;
    procedure SetvX(const Value: int64);
    procedure SetvY(const Value: int64);
    procedure SetvZ(const Value: int64);
    procedure SetX(const Value: int64);
    procedure SetY(const Value: int64);
    procedure SetZ(const Value: int64);
    function GetTempsXMax: extended;
    function GetTempsXMin: extended;
    function GetTempsYMax: extended;
    function GetTempsYMin: extended;
    function GetXInArray: int64;
    function GetXOutArray: int64;
    function GetYInArray: int64;
    function GetYOutArray: int64;
    procedure SetXInArray(const Value: int64);
    procedure SetXOutArray(const Value: int64);
    procedure SetYInArray(const Value: int64);
    procedure SetYOutArray(const Value: int64);
    procedure SetA(const Value: extended);
    procedure SetB(const Value: extended);
  public
    /// <summary>
    /// Coordonnée en X
    /// </summary>
    property X: int64 read FX write SetX;
    /// <summary>
    /// Coordonnée en Y
    /// </summary>
    property Y: int64 read FY write SetY;
    /// <summary>
    /// Coordonnée en Z
    /// </summary>
    property Z: int64 read FZ write SetZ;
    /// <summary>
    /// Vélocité en X
    /// </summary>
    property vX: int64 read FvX write SetvX;
    /// <summary>
    /// Vélocité en Y
    /// </summary>
    property vY: int64 read FvY write SetvY;
    /// <summary>
    /// Vélocité en Z
    /// </summary>
    property vZ: int64 read FvZ write SetvZ;
    property A: extended read FA write SetA;
    property B: extended read FB write SetB;
    /// <summary>
    /// Coordonnée en X d'entrée dans la zone
    /// </summary>
    property XInArray: int64 read GetXInArray;
    /// <summary>
    /// Coordonnée en Y d'entrée dans la zone
    /// </summary>
    property YInArray: int64 read GetYInArray;
    /// <summary>
    /// Coordonnée en X de sortie de la zone
    /// </summary>
    property XOutArray: int64 read GetXOutArray;
    /// <summary>
    /// Coordonnée en Y de sortie de la zone
    /// </summary>
    property YOutArray: int64 read GetYOutArray;
    /// <summary>
    /// Temps minimal pour que X atteigne son point d'entrée
    /// </summary>
    property TempsXMin: extended read GetTempsXMin;
    /// <summary>
    /// Temps minimal pour que Y atteigne son point d'entrée
    /// </summary>
    property TempsYMin: extended read GetTempsYMin;
    /// <summary>
    /// Temps minimal pour que X atteigne son point de sortie
    /// </summary>
    property TempsXMax: extended read GetTempsXMax;
    /// <summary>
    /// Temps minimal pour que Y atteigne son point de sortie
    /// </summary>
    property TempsYMax: extended read GetTempsYMax;
    /// <summary>
    /// Constructeur
    /// </summary>
    constructor Create(AX, AY, AZ, AvX, AvY, AvZ: int64);
    /// <summary>
    /// Teste si une ligne croisera la zone dans le futur
    /// </summary>
    function WillCrossArea(x1, y1, x2, y2: int64): boolean;

    procedure GetEquation(var A, B: extended);
  end;

  THailstonesList = TObjectList<THailstone>;

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
    HailstonesList: THailstonesList;
    procedure LoadData(TestCrossArea: boolean = false);
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
  i, j: integer;
  X, Y: extended;
begin
  HailstonesList := THailstonesList.Create;
  try
    LoadData;

    // for i := 0 to HailstonesList.count - 1 do
    // AddLog(HailstonesList[i].X.tostring + ',' + HailstonesList[i].Y.tostring +
    // ' ' + HailstonesList[i].vX.tostring + ',' + HailstonesList[i]
    // .vY.tostring + ' ' + HailstonesList[i].XInArray.tostring + ',' +
    // HailstonesList[i].YInArray.tostring + ' ' + HailstonesList[i]
    // .XOutArray.tostring + ',' + HailstonesList[i].YOutArray.tostring);

    result := 0;

    // Calcul d'intersection
    // https://www.mathopenref.com/coordintersection.html
    // Y1 = Y2 => A1xX+B1 = A2xX+B2 => (A1-A2)xX=B2-B1 => x=(B2-B1) / (A1-A2)
    // Y = A1xX + B1 = A2xX + B2
    for i := 0 to HailstonesList.count - 2 do
      for j := i + 1 to HailstonesList.count - 1 do
        if (HailstonesList[i].A <> HailstonesList[j].A) then
        begin
          X := (HailstonesList[j].B - HailstonesList[i].B) /
            (HailstonesList[i].A - HailstonesList[j].A);
          Y := HailstonesList[i].A * X + HailstonesList[i].B;
//          AddLog(X.tostring + ',' + Y.tostring);

          // coordonnées de croisement dans la zone de recherche
          // croisement dans le futur par rapport au point d'origine
          if (X >= CAreaMinEx1) and (X <= CAreaMaxEx1) and (Y >= CAreaMinEx1)
            and (Y <= CAreaMaxEx1) and
            (((HailstonesList[i].vX >= 0) and (HailstonesList[i].X <= X)) or
            ((HailstonesList[i].vX <= 0) and (HailstonesList[i].X >= X))) and
            (((HailstonesList[i].vY >= 0) and (HailstonesList[i].Y <= Y)) or
            ((HailstonesList[i].vY <= 0) and (HailstonesList[i].Y >= Y))) and
            (((HailstonesList[j].vX >= 0) and (HailstonesList[j].X <= X)) or
            ((HailstonesList[j].vX <= 0) and (HailstonesList[j].X >= X))) and
            (((HailstonesList[j].vY >= 0) and (HailstonesList[j].Y <= Y)) or
            ((HailstonesList[j].vY <= 0) and (HailstonesList[j].Y >= Y))) then
            result := result + 1;
        end;
  finally
    HailstonesList.free;
  end;
end;

function TForm1.Exercice2: int64;
var
  Lig: integer;
  Lignes: TArray<string>;
begin
  Lignes := tfile.ReadAllLines(CDataFile);
  result := 0;
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

procedure TForm1.LoadData(TestCrossArea: boolean);
var
  Lig: integer;
  Lignes: TArray<string>;
  tab: TArray<string>;
  // Hailstone: THailstone;
begin
  Lignes := tfile.ReadAllLines(CDataFile);
  for Lig := 0 to length(Lignes) - 1 do
  begin
    if Lignes[Lig].trim.isempty then
      continue;

    tab := Lignes[Lig].replace(' ', '').split([',', '@']);
    assert(length(tab) = 6, 'Wrong TAB size for line ' + Lig.tostring + '.');

    HailstonesList.Add(THailstone.Create(tab[0].ToInt64, tab[1].ToInt64,
      tab[2].ToInt64, tab[3].ToInt64, tab[4].ToInt64, tab[5].ToInt64));

    // Hailstone := THailstone.Create(tab[0].ToInt64, tab[1].ToInt64,
    // tab[2].ToInt64, tab[3].ToInt64, tab[4].ToInt64, tab[5].ToInt64);
    // if (not TestCrossArea) or Hailstone.WillCrossArea(CAreaMinEx1, CAreaMinEx1,
    // CAreaMaxEx1, CAreaMaxEx1) then
    // HailstonesList.Add(Hailstone)
    // else
    // Hailstone.free;
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

{ THailstone }

constructor THailstone.Create(AX, AY, AZ, AvX, AvY, AvZ: int64);
begin
  inherited Create;
  X := AX;
  Y := AY;
  Z := AZ;
  vX := AvX;
  vY := AvY;
  vZ := AvZ;
  GetEquation(FA, FB);
end;

procedure THailstone.GetEquation(var A, B: extended);
Var
  Temps: extended;
begin
  // Y = AX+B
  // https://www.mathopenref.com/coordequation.html
  Temps := X / vX; // temps passé pour obtenir le X actuel en partant de zéro

  B := Y - vY * Temps; // valeur de B quand X était à 0

  A := (Y - B) / X; // pente de la courbe
end;

function THailstone.GetTempsXMax: extended;
begin
  if FTempsXMax = 0 then
    FTempsXMax := max(abs(X - CAreaMinEx1) / abs(vX),
      abs(X - CAreaMaxEx1) / abs(vX));
  result := FTempsXMax;
end;

function THailstone.GetTempsXMin: extended;
begin
  if FTempsXMin = 0 then
    FTempsXMin := min(abs(X - CAreaMinEx1) / abs(vX),
      abs(X - CAreaMaxEx1) / abs(vX));
  result := FTempsXMin;
end;

function THailstone.GetTempsYMax: extended;
begin
  if FTempsYMax = 0 then
    FTempsYMax := max(abs(Y - CAreaMinEx1) / abs(vY),
      abs(Y - CAreaMaxEx1) / abs(vY));
  result := FTempsYMax;
end;

function THailstone.GetTempsYMin: extended;
begin
  if FTempsYMin = 0 then
    FTempsYMin := min(abs(Y - CAreaMinEx1) / abs(vY),
      abs(Y - CAreaMaxEx1) / abs(vY));
  result := FTempsYMin;
end;

function THailstone.GetXInArray: int64;
begin
  if (FXInArray = 0) then
    FXInArray := X + trunc(vX * TempsXMin);
  result := FXInArray;
end;

function THailstone.GetXOutArray: int64;
begin
  if (FXOutArray = 0) then
    FXOutArray := X + trunc(vX * TempsXMax);
  result := FXOutArray;
end;

function THailstone.GetYInArray: int64;
begin
  if (FYInArray = 0) then
    FYInArray := Y + trunc(vY * TempsYMin);
  result := FYInArray;
end;

function THailstone.GetYOutArray: int64;
begin
  if (FYOutArray = 0) then
    FYOutArray := Y + trunc(vY * TempsYMax);
  result := FYOutArray;
end;

procedure THailstone.SetA(const Value: extended);
begin
  FA := Value;
end;

procedure THailstone.SetB(const Value: extended);
begin
  FB := Value;
end;

procedure THailstone.SetvX(const Value: int64);
begin
  FvX := Value;
end;

procedure THailstone.SetvY(const Value: int64);
begin
  FvY := Value;
end;

procedure THailstone.SetvZ(const Value: int64);
begin
  FvZ := Value;
end;

procedure THailstone.SetX(const Value: int64);
begin
  FX := Value;
end;

procedure THailstone.SetXInArray(const Value: int64);
begin
  FXInArray := Value;
end;

procedure THailstone.SetXOutArray(const Value: int64);
begin
  FXOutArray := Value;
end;

procedure THailstone.SetY(const Value: int64);
begin
  FY := Value;
end;

procedure THailstone.SetYInArray(const Value: int64);
begin
  FYInArray := Value;
end;

procedure THailstone.SetYOutArray(const Value: int64);
begin
  FYOutArray := Value;
end;

procedure THailstone.SetZ(const Value: int64);
begin
  FZ := Value;
end;

function THailstone.WillCrossArea(x1, y1, x2, y2: int64): boolean;
begin
  if (((X <= x2) and (vX > 0)) or ((X >= x1) and (vX < 0))) and
    (((Y <= y2) and (vY > 0)) or ((Y >= y1) and (vY < 0))) then
  begin
    // On vérifie que la ligne touchera bien le cadre
    // max(TpsMin) nous donne le temps pris pour que x,y soit dans la zone
    // min(TpsMax) nous donne le temps pris pour que x,y sorte de la zone
    if (max(TempsXMin, TempsYMin) < min(TempsXMax, TempsYMax)) then
      result := true
    else
      result := false;
  end
  else
    result := false;
end;

initialization

{$IFDEF DEBUG}
  ReportMemoryLeaksOnShutdown := true;
{$ENDIF}

end.
