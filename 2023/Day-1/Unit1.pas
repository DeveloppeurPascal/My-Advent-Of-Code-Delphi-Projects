unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.WinXCtrls, Vcl.StdCtrls;

type
  TForm1 = class(TForm)
    Button1: TButton;
    Label1: TLabel;
    ActivityIndicator1: TActivityIndicator;
    Button2: TButton;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    procedure BeginTraitement;
    procedure EndTraitement;
    { Déclarations privées }
    function Jour1Exercice1: cardinal;
    function Jour1Exercice2: cardinal;
  public
    { Déclarations publiques }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

uses
  System.Math,
  System.IOUtils;

procedure TForm1.Button1Click(Sender: TObject);
begin
  BeginTraitement;
  try
    tthread.CreateAnonymousThread(
      procedure
      begin
        try
          Label1.Caption := Jour1Exercice1.tostring;
        finally
          EndTraitement;
        end;
      end).Start;
  except
    EndTraitement;
  end;
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  BeginTraitement;
  try
    tthread.CreateAnonymousThread(
      procedure
      begin
        try
          Label1.Caption := Jour1Exercice2.tostring;
        finally
          EndTraitement;
        end;
      end).Start;
  except
    EndTraitement;
  end;
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

function TForm1.Jour1Exercice1: cardinal;
begin
  var
  Lignes := tfile.ReadAllLines('..\..\input.txt');
  result := 0;
  for var i := 0 to length(Lignes) - 1 do
  begin
    var
      CalibrationValue: byte := 0;
    var
    ch := Lignes[i];
    for var j := 0 to ch.length - 1 do
      if (ch.Chars[j] in ['0' .. '9']) then
      begin
        CalibrationValue := strtoint(ch.Chars[j]) * 10;
        break;
      end;
    for var j := ch.length - 1 downto 0 do
      if (ch.Chars[j] in ['0' .. '9']) then
      begin
        CalibrationValue := CalibrationValue + strtoint(ch.Chars[j]);
        break;
      end;
    result := result + CalibrationValue;
  end;
end;

function TForm1.Jour1Exercice2: cardinal;
  function getNumberAsString(InString: string; LeftToRight: boolean;
  var FoundNumber, NumberPosition: integer): boolean;
  var
    Numbers: array of string;
    i: integer;
    idx: integer;
  begin
    Numbers := ['', 'one', 'two', 'three', 'four', 'five', 'six', 'seven',
      'eight', 'nine'];
    FoundNumber := 0;
    NumberPosition := ifthen(LeftToRight, InString.length, -1);
    for i := 1 to 9 do
      if LeftToRight then
      begin
        idx := InString.IndexOf(Numbers[i]);
        if (idx >= 0) and (idx < NumberPosition) then
        begin
          NumberPosition := idx;
          FoundNumber := i;
        end
      end
      else
      begin
        idx := InString.lastIndexOf(Numbers[i]);
        if (idx >= 0) and (idx > NumberPosition) then
        begin
          NumberPosition := idx;
          FoundNumber := i;
        end
      end;
    result := FoundNumber > 0;
  end;

var
  i, j: integer;
  Lignes: TArray<string>;
  CalibrationValue: byte;
  ch: string;
  nb, idx: integer;
begin
  Lignes := tfile.ReadAllLines('..\..\input.txt');
  result := 0;
  for i := 0 to length(Lignes) - 1 do
  begin
    CalibrationValue := 0;
    ch := Lignes[i].tolower;
    for j := 0 to ch.length - 1 do
      if (ch.Chars[j] in ['0' .. '9']) then
      begin
        if getNumberAsString(ch, true, nb, idx) and (idx < j) then
          CalibrationValue := nb * 10
        else
          CalibrationValue := strtoint(ch.Chars[j]) * 10;
        break;
      end;
    for j := ch.length - 1 downto 0 do
      if (ch.Chars[j] in ['0' .. '9']) then
      begin
        if getNumberAsString(ch, false, nb, idx) and (idx > j) then
          CalibrationValue := CalibrationValue + nb
        else
          CalibrationValue := CalibrationValue + strtoint(ch.Chars[j]);
        break;
      end;
    result := result + CalibrationValue;
  end;
end;

end.
