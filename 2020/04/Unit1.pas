unit Unit1;

// My solution for https://adventofcode.com/2020/day/4
interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls;

type

  TPassport = record
    byr, // (Birth Year)
    iyr, // (Issue Year)
    eyr, // (Expiration Year)
    hgt, // (Height)
    hcl, // (Hair Color)
    ecl, // (Eye Color)
    pid, // (Passport ID)
    cid: string; // (Country ID)
    procedure initialise;
    function isValid: boolean;
    function isStrictValid: boolean;
  end;

  TForm1 = class(TForm)
    Memo1: TMemo;
    Panel1: TPanel;
    Button1: TButton;
    Button2: TButton;
    Edit1: TEdit;
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    { Déclarations privées }
    procedure GetInfos(var LineIndex: Integer; var Passeport: TPassport);
  public
    { Déclarations publiques }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

uses
  RegularExpressions;

procedure TForm1.Button1Click(Sender: TObject);
var
  i: Integer;
  Passeport: TPassport;
  nb: Integer;
begin
  nb := 0;
  i := 0;
  while (i < Memo1.Lines.Count) do
  begin
    GetInfos(i, Passeport);
    if Passeport.isValid then
      inc(nb);
    inc(i);
  end;
  Edit1.Text := nb.ToString;
end;

procedure TForm1.Button2Click(Sender: TObject);
var
  i: Integer;
  Passeport: TPassport;
  nb: Integer;
begin
  nb := 0;
  i := 0;
  while (i < Memo1.Lines.Count) do
  begin
    GetInfos(i, Passeport);
    if Passeport.isStrictValid then
      inc(nb);
    inc(i);
  end;
  Edit1.Text := nb.ToString;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  Memo1.Lines.Clear;
  Edit1.Text := '';
end;

procedure TForm1.GetInfos(var LineIndex: Integer; var Passeport: TPassport);
var
  tab: tarray<string>;
  clevaleur: tarray<string>;
  i: Integer;
begin
  Passeport.initialise;
  while (LineIndex < Memo1.Lines.Count) and
    (not Memo1.Lines[LineIndex].IsEmpty) do
  begin
    tab := tregex.Split(Memo1.Lines[LineIndex], '[ ]');
    for i := 0 to length(tab) - 1 do
    begin
      clevaleur := tregex.Split(tab[i], '[:]');
      if length(clevaleur) = 2 then
        if clevaleur[0].ToLower = 'byr' then
          Passeport.byr := clevaleur[1]
        else if clevaleur[0].ToLower = 'iyr' then
          Passeport.iyr := clevaleur[1]
        else if clevaleur[0].ToLower = 'eyr' then
          Passeport.eyr := clevaleur[1]
        else if clevaleur[0].ToLower = 'hgt' then
          Passeport.hgt := clevaleur[1]
        else if clevaleur[0].ToLower = 'hcl' then
          Passeport.hcl := clevaleur[1]
        else if clevaleur[0].ToLower = 'ecl' then
          Passeport.ecl := clevaleur[1]
        else if clevaleur[0].ToLower = 'pid' then
          Passeport.pid := clevaleur[1]
        else if clevaleur[0].ToLower = 'cid' then
          Passeport.cid := clevaleur[1];
    end;
    inc(LineIndex);
  end;
end;

{ TPassport }

procedure TPassport.initialise;
begin
  byr := '';
  iyr := '';
  eyr := '';
  hgt := '';
  hcl := '';
  ecl := '';
  pid := '';
  cid := '';
end;

function TPassport.isStrictValid: boolean;
begin
  try
    // byr (Birth Year) - four digits; at least 1920 and at most 2002.
    result := (not byr.IsEmpty) and tregex.IsMatch(byr, '^[0-9]{4}$') and
      (byr >= '1920') and (byr <= '2002');
    // iyr (Issue Year) - four digits; at least 2010 and at most 2020.
    result := result and (not iyr.IsEmpty) and tregex.IsMatch(iyr, '^[0-9]{4}$')
      and (iyr >= '2010') and (iyr <= '2020');
    // eyr (Expiration Year) - four digits; at least 2020 and at most 2030.
    result := result and (not eyr.IsEmpty) and tregex.IsMatch(eyr, '^[0-9]{4}$')
      and (eyr >= '2020') and (eyr <= '2030');
    // hgt (Height) - a number followed by either cm or in:
    result := result and (not hgt.IsEmpty);
    // If cm, the number must be at least 150 and at most 193.
    if result and tregex.IsMatch(hgt, '^[0-9]{3}cm$') and (hgt >= '150cm') and
      (hgt <= '193cm') then
      // If in, the number must be at least 59 and at most 76.
    else if result and tregex.IsMatch(hgt, '^[0-9]{2}in$') and (hgt >= '59in')
      and (hgt <= '76in') then
    else
      result := false;
    // hcl (Hair Color) - a # followed by exactly six characters 0-9 or a-f.
    result := result and (not hcl.IsEmpty) and
      tregex.IsMatch(hcl, '^#[0-9a-f]{6}$');
    // ecl (Eye Color) - exactly one of: amb blu brn gry grn hzl oth.
    result := result and (not ecl.IsEmpty) and
      tregex.IsMatch(ecl, '^(amb|blu|brn|gry|grn|hzl|oth)$');
    // pid (Passport ID) - a nine-digit number, including leading zeroes.
    result := result and (not pid.IsEmpty) and
      tregex.IsMatch(pid, '^[0-9]{9}$');
  except
    result := false;
  end;
end;

function TPassport.isValid: boolean;
begin
  result := not(byr.IsEmpty or iyr.IsEmpty or eyr.IsEmpty or hgt.IsEmpty or
    hcl.IsEmpty or ecl.IsEmpty or pid.IsEmpty);
end;

end.
