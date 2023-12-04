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
    function Exercice1: cardinal;
    function Exercice2: cardinal;
    function Exercice2Bis: cardinal; // foireux
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
  System.Generics.Collections,
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

function TForm1.Exercice1: cardinal;
var
  Lig: integer;
  Lignes: TArray<string>;
  tab: TArray<string>;
  Tirage: TArray<string>;
  Carte: TArray<string>;
  Points: cardinal;
  i, j: integer;
begin
  Lignes := tfile.ReadAllLines(CDataFile);
  result := 0;
  for Lig := 0 to length(Lignes) - 1 do
  begin
    tab := Lignes[Lig].Substring(Lignes[Lig].indexof(':')).Split(['|']);

    Tirage := tab[0].Split([' ']);
    for i := 0 to length(Tirage) - 1 do
    begin
      Tirage[i] := Tirage[i].Trim;
      // AddLog('tirage : ' + Tirage[i]);
    end;

    Points := 0;

    Carte := tab[1].Split([' ']);
    for i := 0 to length(Carte) - 1 do
    begin
      Carte[i] := Carte[i].Trim;
      // AddLog('carte : ' + Carte[i]);
      for j := 0 to length(Tirage) - 1 do
        if (Carte[i] = Tirage[j]) and not Carte[i].isempty then
        begin
          if Points > 0 then
            Points := Points * 2
          else
            Points := 1;
          break;
        end;
    end;
    // AddLog('points : '+Points.tostring);
    result := result + Points;
  end;
end;

function TForm1.Exercice2: cardinal;
var
  Lig: integer;
  Lignes: TArray<string>;
  tab: TArray<string>;
  Tirage: TArray<string>;
  Carte: TArray<string>;
  Points: cardinal;
  i, j: integer;
  Poids: TList<cardinal>;
begin
  Poids := TList<cardinal>.create;
  try
    Lignes := tfile.ReadAllLines(CDataFile);
    for Lig := 0 to length(Lignes) - 1 do
      Poids.Add(1);

    result := 0;
    for Lig := 0 to length(Lignes) - 1 do
    begin
      tab := Lignes[Lig].Substring(Lignes[Lig].indexof(':')).Split(['|']);

      Tirage := tab[0].Split([' ']);
      for i := 0 to length(Tirage) - 1 do
      begin
        Tirage[i] := Tirage[i].Trim;
        // AddLog('tirage : ' + Tirage[i]);
      end;

      Points := 0;

      Carte := tab[1].Split([' ']);
      for i := 0 to length(Carte) - 1 do
      begin
        Carte[i] := Carte[i].Trim;
        // AddLog('carte : ' + Carte[i]);
        for j := 0 to length(Tirage) - 1 do
          if (Carte[i] = Tirage[j]) and not Carte[i].isempty then
          begin
            if Points > 0 then
              Points := Points + 1
            else
              Points := 1;
            break;
          end;
      end;

      for i := 1 to Points do
        Poids[Lig + i] := Poids[Lig + i] + Poids[Lig];
    end;
    result := 0;
    for i := 0 to Poids.Count - 1 do
      result := result + Poids[i];
  finally
    Poids.Free;
  end;
end;

function TForm1.Exercice2Bis: cardinal;
// approche foireuse : la copie de lignes dans l'ensemble est chronophage
// et a un risque de boucle infinie selon comment on s'y prend
var
  Lig: integer;
  Lignes_Orig: TArray<string>;
  Lignes_Final: TList<string>;
  tab: TArray<string>;
  Tirage: TArray<string>;
  Carte: TArray<string>;
  Points: cardinal;
  i, j: integer;
  idx_lig: integer;
begin
  Lignes_Final := TList<string>.create;
  try
    Lignes_Orig := tfile.ReadAllLines(CDataFile);
    for i := 0 to length(Lignes_Orig) - 1 do
      Lignes_Final.Add(Lignes_Orig[i]);

    Lig := 0;
    while (Lig < Lignes_Final.Count) do
    begin
      tab := Lignes_Final[Lig].Split([':']);
      idx_lig := tab[0].Substring(Lignes_Final[Lig].indexof(' ')).ToInteger;
      // AddLog(idx_lig.tostring);

      tab := Lignes_Final[Lig].Substring(Lignes_Final[Lig].indexof(':'))
        .Split(['|']);

      Tirage := tab[0].Split([' ']);
      for i := 0 to length(Tirage) - 1 do
      begin
        Tirage[i] := Tirage[i].Trim;
        // AddLog('tirage : ' + Tirage[i]);
      end;

      Points := 0;

      Carte := tab[1].Split([' ']);
      for i := 0 to length(Carte) - 1 do
      begin
        Carte[i] := Carte[i].Trim;
        // AddLog('carte : ' + Carte[i]);
        for j := 0 to length(Tirage) - 1 do
          if (Carte[i] = Tirage[j]) and not Carte[i].isempty then
          begin
            if Points > 0 then
              Points := Points + 1
            else
              Points := 1;
            break;
          end;
      end;
      // AddLog('--');
      // AddLog(idx_lig.tostring);
      // AddLog(Points.tostring);
      for i := 1 to Points do
        Lignes_Final.Add(Lignes_Final[idx_lig + i - 1]);

      inc(Lig);
    end;

    result := Lignes_Final.Count;
  finally
    Lignes_Final.Free;
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

end.
