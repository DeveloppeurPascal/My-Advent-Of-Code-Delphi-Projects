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
  System.DateUtils,
  System.RegularExpressions,
  System.Generics.Defaults,
  System.Diagnostics,
  System.IOUtils;

type
{$SCOPEDENUMS ON}
  TElem = (Rien, RockCarre, RockRond);

  TCol = class(TList<TElem>)
  public
  end;

  TPattern = class(TObjectList<TCol>)
  private
  protected
    procedure SetElem(x, y: integer; TypeElem: TElem);
    procedure AddToLog;
  public
    procedure AddAsh(x, y: integer);
    procedure AddRockCarre(x, y: integer);
    procedure AddRockRond(x, y: integer);
    function GetElem(x, y: integer): TElem;
    function GetExercice1: int64;
    function GetExercice2: int64;
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
            Pattern.AddRockCarre(i, j)
          else if Lignes[Lig].chars[i] = 'O' then
            Pattern.AddRockRond(i, j)
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
            Pattern.AddRockCarre(i, j)
          else if Lignes[Lig].chars[i] = 'O' then
            Pattern.AddRockRond(i, j)
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

procedure TPattern.AddAsh(x, y: integer);
begin
  SetElem(x, y, TElem.Rien);
end;

procedure TPattern.SetElem(x, y: integer; TypeElem: TElem);
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
      col.Add(TElem.Rien);

  col[x] := TypeElem;
end;

procedure TPattern.AddRockCarre(x: integer; y: integer);
begin
  SetElem(x, y, TElem.RockCarre);
end;

procedure TPattern.AddRockRond(x: integer; y: integer);
begin
  SetElem(x, y, TElem.RockRond);
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
      case GetElem(x, y) of
        TElem.Rien:
          S := S + '.';
        TElem.RockCarre:
          S := S + '#';
        TElem.RockRond:
          S := S + 'O';
      end;
    Form1.AddLog(S);
  end;
end;

function TPattern.GetElem(x: integer; y: integer): TElem;
begin
  if (y >= 0) and (x >= 0) and (y < count) and (x < self[y].count) then
    result := self[y][x]
  else
    result := TElem.Rien;
end;

function TPattern.GetExercice1: int64;
var
  Lig, col: integer;
  i, j: integer;
begin
  result := 0;
  // vers le nord
  for Lig := 0 to self.count - 1 do
    for col := 0 to self[Lig].count - 1 do
      if (GetElem(col, Lig) = TElem.RockRond) then
      begin
        i := Lig;
        while (i > 0) and (GetElem(col, i - 1) = TElem.Rien) do
          dec(i);
        if GetElem(col, i) = TElem.Rien then
        begin // on peut se déplacer
          SetElem(col, i, TElem.RockRond);
          SetElem(col, Lig, TElem.Rien);
          result := result + self.count - i;
          // Censé être une optimisation mais rend le calcul plus long
          // j := Lig + 1;
          // while (j < self.count - 1) and (GetElem(col, j) = TElem.RockRond) do
          // begin
          // SetElem(col, i + j - Lig, TElem.RockRond);
          // if (i + j - Lig <= Lig) then
          // result := result + self.count - (i + j - Lig);
          // SetElem(col, j, TElem.Rien);
          // inc(j);
          // end;
        end
        else // on ne se déplace pas
          result := result + self.count - Lig;
      end;
end;

function TPattern.GetExercice2: int64;
var
  Lig, col: integer;
  i, j: integer;
  nb: integer;
  Moved: boolean;
begin
  for nb := 1 to 1_000_000_000 do
  begin
    Moved := false;
    // vers le nord
    for Lig := 0 to self.count - 1 do
      for col := 0 to self[Lig].count - 1 do
        if (GetElem(col, Lig) = TElem.RockRond) then
        begin
          i := Lig;
          while (i > 0) and (GetElem(col, i - 1) = TElem.Rien) do
            dec(i);
          if GetElem(col, i) = TElem.Rien then
          begin // on peut se déplacer
            if not Moved then
              Moved := true;
            SetElem(col, i, TElem.RockRond);
            SetElem(col, Lig, TElem.Rien);
            j := Lig + 1;
            while (j < self.count - 1) and (GetElem(col, j) = TElem.RockRond) do
            begin
              SetElem(col, i + j - Lig, TElem.RockRond);
              SetElem(col, j, TElem.Rien);
              inc(j);
            end;
          end;
        end;
    // vers l'ouest
    for col := 0 to self[0].count - 1 do
      for Lig := 0 to self.count - 1 do
        if (GetElem(col, Lig) = TElem.RockRond) then
        begin
          i := col;
          while (i > 0) and (GetElem(i - 1, Lig) = TElem.Rien) do
            dec(i);
          if GetElem(i, Lig) = TElem.Rien then
          begin // on peut se déplacer
            if not Moved then
              Moved := true;
            SetElem(i, Lig, TElem.RockRond);
            SetElem(col, Lig, TElem.Rien);
            j := col + 1;
            while (j < self[0].count - 1) and
              (GetElem(j, Lig) = TElem.RockRond) do
            begin
              SetElem(i + j - col, Lig, TElem.RockRond);
              SetElem(j, Lig, TElem.Rien);
              inc(j);
            end;
          end;
        end;
    // vers le sud
    for Lig := self.count - 1 downto 0 do
      for col := 0 to self[Lig].count - 1 do
        if (GetElem(col, Lig) = TElem.RockRond) then
        begin
          i := Lig;
          while (i < (self.count - 1) - 1) and
            (GetElem(col, i + 1) = TElem.Rien) do
            inc(i);
          if GetElem(col, i) = TElem.Rien then
          begin // on peut se déplacer
            if not Moved then
              Moved := true;
            SetElem(col, i, TElem.RockRond);
            SetElem(col, Lig, TElem.Rien);
            j := Lig - 1;
            while (j >= 0) and (GetElem(col, j) = TElem.RockRond) do
            begin
              SetElem(col, i + j - Lig, TElem.RockRond);
              SetElem(col, j, TElem.Rien);
              dec(j);
            end;
          end;
        end;
    // vers l'est
    for col := self[0].count - 1 downto 0 do
      for Lig := 0 to self.count - 1 do
        if (GetElem(col, Lig) = TElem.RockRond) then
        begin
          i := col;
          while (i < (self[0].count - 1) - 1) and
            (GetElem(i + 1, Lig) = TElem.Rien) do
            inc(i);
          if GetElem(i, Lig) = TElem.Rien then
          begin // on peut se déplacer
            if not Moved then
              Moved := true;
            SetElem(i, Lig, TElem.RockRond);
            SetElem(col, Lig, TElem.Rien);
            j := col - 1;
            while (j >= 0) and (GetElem(j, Lig) = TElem.RockRond) do
            begin
              SetElem(i + j - col, Lig, TElem.RockRond);
              SetElem(j, Lig, TElem.Rien);
              dec(j);
            end;
          end;
        end;
    if not Moved then
      break;
  end;

  result := 0;
  for Lig := self.count - 1 downto 0 do
    for col := 0 to self[Lig].count - 1 do
      if (GetElem(col, Lig) = TElem.RockRond) then
        result := result + self.count - Lig;
end;

initialization

{$IFDEF DEBUG}
  ReportMemoryLeaksOnShutdown := true;
{$ENDIF}

end.
