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
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    procedure BeginTraitement;
    procedure EndTraitement;
    { Déclarations privées }
    function Exercice1: uint64;
    function Exercice2: uint64;
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

function TForm1.Exercice1: uint64;
var
  Lig: integer;
  Lignes: TArray<string>;
  TimeTab, DistanceTab: TArray<string>;
  i, j: integer;
  time, HighScore, Score: uint64;
  Cpt: uint64;
begin
  Lignes := tfile.ReadAllLines(CDataFile);
  result := 0;
  for Lig := 0 to length(Lignes) - 1 do
  begin
    while (Lignes[Lig].IndexOf('  ') >= 0) do
      Lignes[Lig] := Lignes[Lig].Replace('  ', ' ');
    // AddLog(Lignes[Lig]);
    if (Lig = 0) then
      TimeTab := Lignes[Lig].Split([' '])
    else if (Lig = 1) then
      DistanceTab := Lignes[Lig].Split([' ']);
  end;

  result := 0;
  for i := 1 to length(TimeTab) - 1 do
  begin
    time := TimeTab[i].ToInt64;
    HighScore := DistanceTab[i].ToInt64;
    Cpt := 0;
    for j := 1 to time - 1 do
    begin
      Score := j * (time - j);
      if (Score > HighScore) then
        inc(Cpt);
    end;
    if (Cpt > 0) then
      if (result = 0) then
        result := Cpt
      else
        result := result * Cpt;
  end;
end;

function TForm1.Exercice2: uint64;
var
  Lig: integer;
  Lignes: TArray<string>;
  TimeTab, DistanceTab: TArray<string>;
  i, j: integer;
  time, HighScore, Score: uint64;
  Cpt: uint64;
  s1, s2: string;
begin
  Lignes := tfile.ReadAllLines(CDataFile);
  result := 0;
  for Lig := 0 to length(Lignes) - 1 do
  begin
    while (Lignes[Lig].IndexOf('  ') >= 0) do
      Lignes[Lig] := Lignes[Lig].Replace('  ', ' ');
    // AddLog(Lignes[Lig]);
    if (Lig = 0) then
      TimeTab := Lignes[Lig].Split([' '])
    else if (Lig = 1) then
      DistanceTab := Lignes[Lig].Split([' ']);
  end;

  s1 := '';
  s2 := '';
  for i := 1 to length(TimeTab) - 1 do
  begin
    s1 := s1 + TimeTab[i];
    s2 := s2 + DistanceTab[i];
  end;

  result := 0;
  time := s1.ToInt64;
  HighScore := s2.ToInt64;
  Cpt := 0;
  for j := 1 to time - 1 do
  begin
    Score := j * (time - j);
    if (Score > HighScore) then
      inc(Cpt);
  end;
  if (Cpt > 0) then
    if (result = 0) then
      result := Cpt
    else
      result := result * Cpt;
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

end.
