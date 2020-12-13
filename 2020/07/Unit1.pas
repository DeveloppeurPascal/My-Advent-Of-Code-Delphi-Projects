unit Unit1;

// My solution for day 7 (2020) - https://adventofcode.com/2020/day/7
interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls;

type
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
  public
    { Déclarations publiques }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

uses
  System.RegularExpressions, System.Generics.Collections, System.Types;

type
  TSousListe = TDictionary<string, integer>;
  TListe = TObjectDictionary<string, TSousListe>;

procedure TForm1.Button1Click(Sender: TObject);
var
  ch: string;
  i, j, k: integer;
  liste: TListe;
  elem: TSousListe;
  nb_total: integer;
  decoupage: TMatchCollection;
  CouleursTrouvees: string;

  procedure recherche(SearchedColor: string; var ColorsFound: string;
    var Nb: integer);
  var
    ListeElem: TListe.TPairEnumerator;
    SousListeElem: TSousListe.TPairEnumerator;
  begin
    ListeElem := liste.GetEnumerator;
    while ListeElem.MoveNext do
    begin
      if not ColorsFound.Contains('/' + ListeElem.Current.key + '/') then
        if ListeElem.Current.Value.Count > 0 then
        begin
          SousListeElem := ListeElem.Current.Value.GetEnumerator;
          while SousListeElem.MoveNext do
            if (SousListeElem.Current.key = SearchedColor) then
            begin
              ColorsFound := ColorsFound + '/' + ListeElem.Current.key + '/';
              inc(Nb);
              recherche(ListeElem.Current.key, ColorsFound, Nb);
              break;
            end;
        end;
    end;
  end;

begin
  liste := TListe.Create;
  try
    for i := 0 to Memo1.Lines.Count - 1 do
    begin
      ch := Memo1.Lines[i].Trim;
      decoupage := tregex.Matches('0 ' + ch, '(\d+)\s([^\d]+)\sbag');
      // Memo1.lines.Add('Total : ' + decoupage.count.ToString);
      // for j := 0 to decoupage.count - 1 do
      // begin
      // Memo1.lines.Add(decoupage[j].value);
      // Memo1.lines.Add('Total ' + j.ToString + ' : ' + decoupage[j]
      // .groups.count.ToString);
      // for k := 0 to decoupage[j].groups.count - 1 do
      // begin
      // Memo1.lines.Add(decoupage[j].groups[k].value);
      // end;
      // end;
      if decoupage.Count > 0 then
      begin
        elem := TSousListe.Create;
        for j := 1 to decoupage.Count - 1 do
          elem.Add(decoupage[j].groups[2].Value,
            decoupage[j].groups[1].Value.ToInteger);
        if decoupage[0].groups[2].Value.Contains('no other') then
          liste.Add(decoupage[0].groups[2].Value.Substring(0,
            decoupage[0].groups[2].Value.IndexOf(' bag')), elem)
        else
          liste.Add(decoupage[0].groups[2].Value, elem);
      end;
    end;
    nb_total := 0;
    CouleursTrouvees := '';
    recherche('shiny gold', CouleursTrouvees, nb_total);
    Edit1.Text := nb_total.ToString;
  finally
    liste.free;
  end;
end;

procedure TForm1.Button2Click(Sender: TObject);
var
  ch: string;
  i, j, k: integer;
  liste: TListe;
  elem: TSousListe;
  nb_total: integer;
  decoupage: TMatchCollection;
  CouleursTrouvees: string;

  function TotalBags(SearchedColor: string): integer;
  var
    SousListeElem: TSousListe.TPairEnumerator;
    Nb: integer;
  begin
    result := 1;
    if liste[SearchedColor].Count > 0 then
    begin
      SousListeElem := liste[SearchedColor].GetEnumerator;
      while SousListeElem.MoveNext do
        result := result + SousListeElem.Current.Value *
          TotalBags(SousListeElem.Current.key);
    end;
  end;

begin
  liste := TListe.Create;
  try
    for i := 0 to Memo1.Lines.Count - 1 do
    begin
      ch := Memo1.Lines[i].Trim;
      decoupage := tregex.Matches('0 ' + ch, '(\d+)\s([^\d]+)\sbag');
      if decoupage.Count > 0 then
      begin
        elem := TSousListe.Create;
        for j := 1 to decoupage.Count - 1 do
          elem.Add(decoupage[j].groups[2].Value,
            decoupage[j].groups[1].Value.ToInteger);
        if decoupage[0].groups[2].Value.Contains('no other') then
          liste.Add(decoupage[0].groups[2].Value.Substring(0,
            decoupage[0].groups[2].Value.IndexOf(' bag')), elem)
        else
          liste.Add(decoupage[0].groups[2].Value, elem);
      end;
    end;
    Edit1.Text := (TotalBags('shiny gold') - 1).ToString;
  finally
    liste.free;
  end;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  Memo1.Lines.Clear;
  Edit1.Text := '';
end;

end.
