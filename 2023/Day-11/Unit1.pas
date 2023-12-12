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
   CNBCell = 140;
   CDataFile = '..\..\input.txt';
//  CNBCell = 10;
//  CDataFile = '..\..\input-test.txt'; // 374 sur exercice 1

type
  TGalaxie = class
  private
    Fx: int64;
    Fy: int64;
    procedure Setx(const Value: int64);
    procedure Sety(const Value: int64);
  public
    property x: int64 read Fx write Setx;
    property y: int64 read Fy write Sety;
    constructor Create(AX, AY: int64);
  end;

  TGalaxiesListe = class(TObjectList<TGalaxie>)
  end;

  THasGalaxies = array [0 .. (CNBCell - 1)] of boolean;
  TExpansionUnivers = array [0 .. (CNBCell - 1)] of int64;

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
    procedure FormDestroy(Sender: TObject);
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
    GalaxiesSurLigne, GalaxiesSurColonne: THasGalaxies;
    Galaxies: TGalaxiesListe;
    procedure InitGrille;
    Procedure ChargeDonnees(ExpansionValue:int64);
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
    // tthread.CreateAnonymousThread(
    // procedure
    var
      time: TStopwatch;
      // begin
    try
      try
        time.Start;
        try
          Edit1.Text := Exercice1.tostring;
        finally
          time.Stop;
          AddLog('Result : ' + Edit1.Text);
          AddLog('Elapsed time : ' + MsToTimeString(time.ElapsedMilliseconds));
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
    // end).Start;
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

procedure TForm1.ChargeDonnees(ExpansionValue:int64);
var
  i, Col, Lig: int64;
  Lignes: TArray<string>;
  ExpansionUniversEnX, ExpansionUniversEnY: TExpansionUnivers;
  DecX, DecY: int64;
  galaxie: TGalaxie;
begin
  InitGrille;
  Galaxies.clear;
  Lignes := tfile.ReadAllLines(CDataFile);
  for Lig := 0 to length(Lignes) - 1 do
    for Col := 0 to length(Lignes[Lig]) - 1 do
      if Lignes[Lig].Chars[Col] = '#' then
      begin
        Galaxies.add(TGalaxie.Create(Col, Lig));
        Form1.GalaxiesSurColonne[Col] := true;
        Form1.GalaxiesSurLigne[Lig] := true;
      end;

  DecX := 0;
  DecY := 0;
  for i := 0 to CNBCell - 1 do
  begin
    if not GalaxiesSurColonne[i] then
      DecX := DecX + ExpansionValue-1;
    ExpansionUniversEnX[i] := DecX;
    if not GalaxiesSurLigne[i] then
      DecY := DecY + ExpansionValue-1;
    ExpansionUniversEnY[i] := DecY;
  end;

  for galaxie in Galaxies do
  begin
    galaxie.x := galaxie.x + ExpansionUniversEnX[galaxie.x];
    galaxie.y := galaxie.y + ExpansionUniversEnY[galaxie.y];
  end;
end;

procedure TForm1.AddLog(const S: String);
begin
  tthread.Synchronize(nil,
    procedure
    begin
      Memo1.Lines.add(S);
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
  i, j: int64;
begin
  ChargeDonnees(2);

  result := 0;
  for i := 0 to Galaxies.count - 1 do
    for j := i + 1 to Galaxies.count - 1 do
      result := result + abs(Galaxies[i].x - Galaxies[j].x) +
        abs(Galaxies[i].y - Galaxies[j].y);
end;

function TForm1.Exercice2: int64;
var
  i, j: int64;
begin
  ChargeDonnees(1_000_000);
//                               ChargeDonnees(100); // 8410 pour input_test

  result := 0;
  for i := 0 to Galaxies.count - 1 do
    for j := i + 1 to Galaxies.count - 1 do
      result := result + abs(Galaxies[i].x - Galaxies[j].x) +
        abs(Galaxies[i].y - Galaxies[j].y);
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  Edit1.Text := '';
  Edit2.Text := '';
  Memo1.clear;

  InitGrille;
  Galaxies := TGalaxiesListe.Create;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  Galaxies.free;
end;

procedure TForm1.InitGrille;
var
  i: int64;
begin
  for i := 0 to CNBCell - 1 do
  begin
    GalaxiesSurLigne[i] := false;
    GalaxiesSurColonne[i] := false;
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

{ TGalaxie }

constructor TGalaxie.Create(AX, AY: int64);
begin
  inherited Create;
  x := AX;
  y := AY;
end;

procedure TGalaxie.Setx(const Value: int64);
begin
  Fx := Value;
end;

procedure TGalaxie.Sety(const Value: int64);
begin
  Fy := Value;
end;

initialization

{$IFDEF DEBUG}
  ReportMemoryLeaksOnShutdown := true;
{$ENDIF}

end.
