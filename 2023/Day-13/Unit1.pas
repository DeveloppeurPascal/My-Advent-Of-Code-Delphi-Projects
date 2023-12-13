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

type
  TCol = class(TList<boolean>)
  public
  end;

  TPattern = class(TObjectList<TCol>)
  private
  protected
    procedure SetElem(x, y: integer; IsRock: boolean);
    procedure AddToLog;
  public
    procedure AddAsh(x, y: integer); // point
    procedure AddRock(x, y: integer); // rock
    function IsRock(x, y: integer): boolean;
    function GetExercice1: int64;
    function GetExercice2(SecondCalcul: boolean = false): int64;
  end;

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
  Lig: integer;
  Lignes: TArray<string>;
  Pattern: TPattern;
  i, j: integer;
begin
  Lignes := tfile.ReadAllLines(CDataFile);
  Pattern := TPattern.create;
  try
    result := 0;
    j := 0;
    for Lig := 0 to length(Lignes) - 1 do
    begin
      if (Lignes[Lig].trim.isempty) then
      begin
        result := result + Pattern.GetExercice1;
        j := -1;
        Pattern.clear;
      end
      else
        for i := 0 to Lignes[Lig].length - 1 do
          if Lignes[Lig].chars[i] = '#' then
            Pattern.AddRock(i, j)
          else
            Pattern.AddAsh(i, j);
      inc(j);
    end;
    result := result + Pattern.GetExercice1;
  finally
    Pattern.free;
  end;
end;

function TForm1.Exercice2: int64;
var
  Lig: integer;
  Lignes: TArray<string>;
  Pattern: TPattern;
  i, j: integer;
begin
  Lignes := tfile.ReadAllLines(CDataFile);
  Pattern := TPattern.create;
  try
    result := 0;
    j := 0;
    for Lig := 0 to length(Lignes) - 1 do
    begin
      if (Lignes[Lig].trim.isempty) then
      begin
        result := result + Pattern.GetExercice2;
        j := -1;
        Pattern.clear;
      end
      else
        for i := 0 to Lignes[Lig].length - 1 do
          if Lignes[Lig].chars[i] = '#' then
            Pattern.AddRock(i, j)
          else
            Pattern.AddAsh(i, j);
      inc(j);
    end;
    result := result + Pattern.GetExercice2;
  finally
    Pattern.free;
  end;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  Edit1.Text := '';
  Edit2.Text := '';
  Memo1.clear;
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

{ TLig }

procedure TPattern.AddAsh(x, y: integer);
begin
  SetElem(x, y, false);
end;

procedure TPattern.SetElem(x, y: integer; IsRock: boolean);
var
  col: TCol;
begin
  if (y < 0) or (x < 0) then
    exit;

  if (y >= count) then
    while (y >= count) do
      Add(TCol.create);

  col := self[y];
  if (x >= col.count) then
    while (x >= col.count) do
      col.Add(false);

  col[x] := IsRock;
end;

procedure TPattern.AddRock(x, y: integer);
begin
  SetElem(x, y, true);
end;

function TPattern.GetExercice1: int64;
var
  x, y: integer;
  i: integer;
  ok: boolean;
begin
  result := 0;
  i:=0;

  // Test le miroir vertical
  for x := 0 to self[0].count - 2 do
    if IsRock(x, 0) = IsRock(x + 1, 0) then
    begin
      ok := true;
      y := 0;
      while ok and (y < count) do
      begin
        i := 0;
        while ok and (x + i + 1 < self[0].count) and (x - i >= 0) do
        begin
          ok := IsRock(x - i, y) = IsRock(x + i + 1, y);
          inc(i);
        end;
        inc(y);
      end;
      if ok then
      begin
        Form1.AddLog('ok ' + x.tostring);
        result := result + (x + 1);
        // x+1 car x commence à 0, les colonnes dans l'énoncé à 1
        break;
      end
      else
        Form1.AddLog('not ok (x=' + x.tostring + ', y=' + (y - 1).tostring +
          ', i=' + (i - 1).tostring + ')');
    end;

  // Test le miroir horizontal
  for y := 0 to count - 2 do
    if IsRock(0, y) = IsRock(0, y + 1) then
    begin
      ok := true;
      x := 0;
      while ok and (x < self[y].count) do
      begin
        i := 0;
        while ok and (y + i + 1 < count) and (y - i >= 0) do
        begin
          ok := IsRock(x, y - i) = IsRock(x, y + i + 1);
          inc(i);
        end;
        inc(x);
      end;
      if ok then
      begin
        Form1.AddLog('ok ' + y.tostring);
        result := result + (y + 1) * 100;
        // y+1 car y commence à 0, les lignes dans l'énoncé à 1
        break;
      end
      else
        Form1.AddLog('not ok (x=' + (x - 1).tostring + ', y=' + y.tostring +
          ', i=' + (i - 1).tostring + ')');
    end;
end;

function TPattern.GetExercice2(SecondCalcul: boolean): int64;
var
  x, y: integer;
  i: integer;
  ok, HasChanged, FirstError, ErreurIsRock: boolean;
  ErreurX, ErreurY: integer;
begin
  result := 0;
  FirstError := true;
  HasChanged := SecondCalcul;

  if SecondCalcul then
    Form1.AddLog('recalcul post détection d''erreur');

  // Test le miroir horizontal
  Form1.AddLog('horizontal');
  for y := 0 to count - 2 do
    if IsRock(0, y) = IsRock(0, y + 1) then
    begin
      ok := true;
      x := 0;
      while ok and (x < self[y].count) do
      begin
        i := 0;
        while ok and (y + i + 1 < count) and (y - i >= 0) do
        begin
          ok := IsRock(x, y - i) = IsRock(x, y + i + 1);
          if (not ok) and FirstError then
          begin
            FirstError := false;
            ok := true;
            ErreurX := x;
            ErreurY := y - i;
            ErreurIsRock := IsRock(x, y + i + 1);
          end;
          inc(i);
        end;
        inc(x);
      end;
      if ok then
      begin
        Form1.AddLog('ok ' + y.tostring);
        if (not FirstError) and (not HasChanged) then
        begin
          Form1.AddLog('erreur en ' + ErreurX.tostring + ',' +
            ErreurY.tostring + '.');
          AddToLog;
          Form1.AddLog('-');
          SetElem(ErreurX, ErreurY, ErreurIsRock);
          HasChanged := true;
          AddToLog;
        end;
        result := result + (y + 1) * 100;
        // y+1 car y commence à 0, les lignes dans l'énoncé à 1
        break;
      end
      else
      begin
        Form1.AddLog('not ok (x=' + (x - 1).tostring + ', y=' + y.tostring +
          ', i=' + (i - 1).tostring + ')');
        FirstError := true;
      end;
    end;

  // Test le miroir vertical
  Form1.AddLog('vertical');
  for x := 0 to self[0].count - 2 do
    if IsRock(x, 0) = IsRock(x + 1, 0) then
    begin
      ok := true;
      y := 0;
      while ok and (y < count) do
      begin
        i := 0;
        while ok and (x + i + 1 < self[0].count) and (x - i >= 0) do
        begin
          ok := IsRock(x - i, y) = IsRock(x + i + 1, y);
          if (not ok) and FirstError then
          begin
            FirstError := false;
            ok := true;
            ErreurX := x - i;
            ErreurY := y;
            ErreurIsRock := IsRock(x + i + 1, y);
          end;
          inc(i);
        end;
        inc(y);
      end;
      if ok then
      begin
        Form1.AddLog('ok ' + x.tostring);
        if (not FirstError) and (not HasChanged) then
        begin
          Form1.AddLog('erreur en ' + ErreurX.tostring + ',' +
            ErreurY.tostring + '.');
          AddToLog;
          Form1.AddLog('-');
          SetElem(ErreurX, ErreurY, ErreurIsRock);
          HasChanged := true;
          AddToLog;
        end;
        result := result + (x + 1);
        // x+1 car x commence à 0, les colonnes dans l'énoncé à 1
        break;
      end
      else
      begin
        Form1.AddLog('not ok (x=' + x.tostring + ', y=' + (y - 1).tostring +
          ', i=' + (i - 1).tostring + ')');
         FirstError := true;
      end;
    end;

  if (not SecondCalcul) and HasChanged then
    result := GetExercice2(true);
end;

procedure TPattern.AddToLog;
var
  y: integer;
  S: string;
  x: integer;
begin
  for y := 0 to count - 1 do
  begin
    S := '';
    for x := 0 to self[y].count - 1 do
      S := S + ifthen(IsRock(x, y), '#', '.');
    Form1.AddLog(S);
  end;
end;

function TPattern.IsRock(x, y: integer): boolean;
begin
  result := (y >= 0) and (x >= 0) and (y < count) and (x < self[y].count) and
    (self[y][x]);
end;

initialization

{$IFDEF DEBUG}
  ReportMemoryLeaksOnShutdown := true;
{$ENDIF}

end.
