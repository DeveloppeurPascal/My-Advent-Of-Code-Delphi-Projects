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
    function GetHash(S: string; ShowLog: boolean = true): int64;
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
  Lig: integer;
  Lignes: TArray<string>;
  tab: TArray<string>;
  i: integer;
begin
  Lignes := tfile.ReadAllLines(CDataFile);
  result := 0;
  for Lig := 0 to length(Lignes) - 1 do
  begin
    if Lignes[Lig].trim.isempty then
      continue;

    tab := Lignes[Lig].trim.split([',']);

    for i := 0 to length(tab) - 1 do
      result := result + GetHash(tab[i]);
  end;
end;

type
  TLens = class
  public
    Lbl: string;
    FocalLength: byte;
    constructor Create(ALabel: string; aFocalLength: byte);
  end;

  TBox = class(TObjectList<TLens>)
  public
    procedure UpdateLens(ALabel: string; aFocalLength: byte);
    procedure RemoveLens(ALabel: string);
    function Power(BoxNum: integer): int64;
  end;

function TForm1.Exercice2: int64;
var
  Lig: integer;
  Lignes: TArray<string>;
  tab, tab2: TArray<string>;
  i: integer;
  Boxes: array [0 .. 255] of TBox;
  Hash: byte;
begin
  for i := 0 to 255 do
    Boxes[i] := TBox.Create;
  try
    Lignes := tfile.ReadAllLines(CDataFile);
    for Lig := 0 to length(Lignes) - 1 do
    begin
      if Lignes[Lig].trim.isempty then
        continue;

      tab := Lignes[Lig].trim.split([',']);

      for i := 0 to length(tab) - 1 do
      begin
        tab2 := tab[i].split(['=', '-']);
        Hash := GetHash(tab2[0], false);
        if tab2[1].isempty then // -
          Boxes[Hash].RemoveLens(tab2[0])
        else // =
          Boxes[Hash].UpdateLens(tab2[0], tab2[1].tointeger);
      end;
    end;

    // Calcul total
    result := 0;
    for i := 0 to 255 do
      result := result + Boxes[i].Power(i + 1);
  finally
    for i := 0 to 255 do
      Boxes[i].Free;
  end;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  Edit1.Text := '';
  Edit2.Text := '';
  Memo1.Clear;
end;

function TForm1.GetHash(S: string; ShowLog: boolean): int64;
var
  i: integer;
begin
  result := 0;
  for i := 0 to S.length - 1 do
    result := ((result + ord(S.Chars[i])) * 17) mod 256;
  if ShowLog then
    AddLog(S + ' => ' + result.tostring);
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

{ TBox }

function TBox.Power(BoxNum: integer): int64;
var
  i: integer;
begin
  result := 0;
  for i := 0 to count - 1 do
    result := result + BoxNum * (i + 1) * items[i].FocalLength;
end;

procedure TBox.RemoveLens(ALabel: string);
var
  i: integer;
begin
  for i := 0 to count - 1 do
    if items[i].Lbl = ALabel then
    begin
      delete(i);
      break;
    end;
end;

procedure TBox.UpdateLens(ALabel: string; aFocalLength: byte);
var
  i: integer;
begin
  for i := 0 to count - 1 do
    if items[i].Lbl = ALabel then
    begin
      items[i].FocalLength := aFocalLength;
      exit;
    end;
  Add(TLens.Create(ALabel, aFocalLength));
end;

{ TLens }

constructor TLens.Create(ALabel: string; aFocalLength: byte);
begin
  inherited Create;
  Lbl := ALabel;
  FocalLength := aFocalLength;
end;

initialization

{$IFDEF DEBUG}
  ReportMemoryLeaksOnShutdown := true;
{$ENDIF}

end.
