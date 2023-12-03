unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.WinXCtrls, Vcl.StdCtrls;

const
   CDataFile = '..\..\input.txt';
  //CDataFile = '..\..\input-test.txt';

type
  TForm1 = class(TForm)
    Button1: TButton;
    Label1: TLabel;
    ActivityIndicator1: TActivityIndicator;
    Button2: TButton;
    Memo1: TMemo;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    procedure BeginTraitement;
    procedure EndTraitement;
    { Déclarations privées }
    function Jour3Exercice1: cardinal;
    function Jour3Exercice2: cardinal;
    procedure log(s: string);
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
          Label1.Caption := Jour3Exercice1.tostring;
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
          Label1.Caption := Jour3Exercice2.tostring;
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

function TForm1.Jour3Exercice1: cardinal;
var
  Lignes: TArray<string>;
  i: integer;
  CurrentNumber: cardinal;
  j: integer;
  NumberValid: boolean;
begin
  Lignes := tfile.ReadAllLines(CDataFile, tencoding.ASCII);
  result := 0;
  for i := 0 to length(Lignes) - 1 do
  begin
    NumberValid := false;
    CurrentNumber := 0;
    for j := 0 to length(Lignes[i]) - 1 do
    begin
      if Lignes[i].Chars[j] in ['0' .. '9'] then
      begin
        CurrentNumber := CurrentNumber * 10 + strtoint(Lignes[i].Chars[j]);
        if not NumberValid then
        begin
          // à gauche du chiffre
          NumberValid := (j > 0) and
            (not(Lignes[i].Chars[j - 1] in ['0' .. '9', '.']));
          // en haut à gauche du chiffre
          NumberValid := NumberValid or
            ((j > 0) and (i > 0) and
            (not(Lignes[i - 1].Chars[j - 1] in ['0' .. '9', '.'])));
          // en bas à gauche du chiffre
          NumberValid := NumberValid or
            ((j > 0) and (i < length(Lignes) - 1) and
            (not(Lignes[i + 1].Chars[j - 1] in ['0' .. '9', '.'])));
          // à droite du chiffre
          NumberValid := NumberValid or
            ((j < length(Lignes[i]) - 1) and
            (not(Lignes[i].Chars[j + 1] in ['0' .. '9', '.'])));
          // en haut à droite du chiffre
          NumberValid := NumberValid or
            ((i > 0) and (j < length(Lignes[i - 1]) - 1) and
            (not(Lignes[i - 1].Chars[j + 1] in ['0' .. '9', '.'])));
          // en bas à droite du chiffre
          NumberValid := NumberValid or
            ((i < length(Lignes) - 1) and (j < length(Lignes[i + 1]) - 1) and
            (not(Lignes[i + 1].Chars[j + 1] in ['0' .. '9', '.'])));
          // au dessus du chiffre
          NumberValid := NumberValid or
            ((i > 0) and (not(Lignes[i - 1].Chars[j] in ['0' .. '9', '.'])));
          // sous le chiffre
          NumberValid := NumberValid or
            ((i < length(Lignes) - 1) and
            (not(Lignes[i + 1].Chars[j] in ['0' .. '9', '.'])));
        end;
      end
      else if NumberValid then
      begin
        log('Ok : ' + CurrentNumber.tostring);
        result := result + CurrentNumber;
        NumberValid := false;
        CurrentNumber := 0;
      end
      else if (CurrentNumber > 0) then
      begin
        log('Not Ok : ' + CurrentNumber.tostring);
        CurrentNumber := 0;
      end;
    end;
    if NumberValid then
      result := result + CurrentNumber;
  end;
end;

function TForm1.Jour3Exercice2: cardinal;
  function getNumber(const Lignes: TArray<string>; const Col, Lig: integer;
  out StartCol, EndCol: integer; Out Number: cardinal): boolean;
  var
    i: integer;
  begin
    if (Lig < 0) or (Lig > length(Lignes) - 1) or (Lig < 0) or
      (Lig > length(Lignes) - 1) then
    begin
{$IFDEF DEBUG}
      raise exception.Create
        ('Ce cas ne doit jamais se produire si les tests lors de l''appel sont corrects.');
{$ENDIF}
      result := false;
      exit;
    end;
    if Lignes[Lig].Chars[Col] in ['0' .. '9'] then
    begin
      result := true;
      StartCol := 0;
      EndCol := 0;
      for i := Col downto 0 do
        if Lignes[Lig].Chars[i] in ['0' .. '9'] then
          StartCol := i
        else
          break;
      Number := 0;
      for i := StartCol to length(Lignes[Lig]) - 1 do
        if Lignes[Lig].Chars[i] in ['0' .. '9'] then
        begin
          EndCol := i;
          Number := Number * 10 + strtoint(Lignes[Lig].Chars[i]);
        end
        else
          break;
    end
    else
      result := false;
  end;

var
  Lig, Col: integer;
  Lignes: TArray<string>;
  CurrentNumber: cardinal;
  MultOk: boolean;
  StartCol, EndCol: integer;
  NewNumber: cardinal;
begin
  Lignes := tfile.ReadAllLines(CDataFile);
  result := 0;
  for Lig := 0 to length(Lignes) - 1 do
    for Col := 0 to length(Lignes[Lig]) - 1 do
      if (Lignes[Lig].Chars[Col] = '*') then
      begin
        MultOk := false;
        CurrentNumber := 0;
        // à gauche de l'étoile
        if (Col > 0) and getNumber(Lignes, Col - 1, Lig, StartCol, EndCol,
          NewNumber) then
          CurrentNumber := NewNumber;
        // à droite de l'étoile
        if (Col < length(Lignes[Lig]) - 1) and getNumber(Lignes, Col + 1, Lig,
          StartCol, EndCol, NewNumber) then
          if (CurrentNumber <> 0) then
          begin
            CurrentNumber := CurrentNumber * NewNumber;
            MultOk := true;
          end
          else
            CurrentNumber := NewNumber;
        // Au dessus de l'étoile
        if (Lig > 0) then
        begin
          EndCol := 0;
          if (Col > 0) and getNumber(Lignes, Col - 1, Lig - 1, StartCol, EndCol,
            NewNumber) then
            if (CurrentNumber <> 0) then
            begin
              CurrentNumber := CurrentNumber * NewNumber;
              MultOk := true;
            end
            else
              CurrentNumber := NewNumber;
          if (Col > EndCol) and getNumber(Lignes, Col, Lig - 1, StartCol,
            EndCol, NewNumber) then
            if (CurrentNumber <> 0) then
            begin
              CurrentNumber := CurrentNumber * NewNumber;
              MultOk := true;
            end
            else
              CurrentNumber := NewNumber;
          if (Col > EndCol) and (Col < length(Lignes[Lig]) - 1) and
            getNumber(Lignes, Col + 1, Lig - 1, StartCol, EndCol, NewNumber)
          then
            if (CurrentNumber <> 0) then
            begin
              CurrentNumber := CurrentNumber * NewNumber;
              MultOk := true;
            end
            else
              CurrentNumber := NewNumber;
        end;
        // Sous l'étoile
        if (Lig < length(Lignes) - 1) then
        begin
          EndCol := 0;
          if (Col > 0) and getNumber(Lignes, Col - 1, Lig + 1, StartCol, EndCol,
            NewNumber) then
            if (CurrentNumber <> 0) then
            begin
              CurrentNumber := CurrentNumber * NewNumber;
              MultOk := true;
            end
            else
              CurrentNumber := NewNumber;
          if (Col > EndCol) and getNumber(Lignes, Col, Lig + 1, StartCol,
            EndCol, NewNumber) then
            if (CurrentNumber <> 0) then
            begin
              CurrentNumber := CurrentNumber * NewNumber;
              MultOk := true;
            end
            else
              CurrentNumber := NewNumber;
          if (Col > EndCol) and (Col < length(Lignes[Lig]) - 1) and
            getNumber(Lignes, Col + 1, Lig + 1, StartCol, EndCol, NewNumber)
          then
            if (CurrentNumber <> 0) then
            begin
              CurrentNumber := CurrentNumber * NewNumber;
              MultOk := true;
            end
            else
              CurrentNumber := NewNumber;
        end;

        if MultOk then
          result := result + CurrentNumber;
      end;
end;

procedure TForm1.log(s: string);
begin
  tthread.Synchronize(nil,
    procedure
    begin
      Memo1.Lines.Add(s);
    end);
end;

end.
