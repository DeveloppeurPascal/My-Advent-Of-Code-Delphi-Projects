unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.WinXCtrls, Vcl.StdCtrls;

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
  System.Generics.Collections,
  System.Generics.Defaults,
  System.RegularExpressions,
  System.Diagnostics,
  System.IOUtils;

var
  CardsEx1: string = '23456789TJQKA';
  CardsEx2: string = 'J23456789TQKA';

type
{$SCOPEDENUMS ON}
  THandType = (HighCard, OnePair, TwoPair, ThreeOfAKind, FullHouse, FourOfAKind,
    FiveOfAKind);

  THand = class
  public
    Cards: string;
    bid: uint64;
    handtype: THandType;
    constructor Create(ACards: string; ABid: uint64; useJoker: boolean = false);
  end;

  THandsList = class(TObjectList<THand>)
  public
    procedure SortHandsEx1;
    procedure SortHandsEx2;
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

function TForm1.Exercice1: uint64;
var
  Lig: integer;
  Lignes: TArray<string>;
  Tab: TArray<string>;
  Hands: THandsList;
  i: integer;
begin
  Hands := THandsList.Create;
  try
    Lignes := tfile.ReadAllLines(CDataFile);
    result := 0;
    for Lig := 0 to length(Lignes) - 1 do
    begin
      if Lignes[Lig].Trim.IsEmpty then
        break;
      Tab := Lignes[Lig].Trim.Split([' ']);
      Hands.Add(THand.Create(Tab[0], Tab[1].ToInt64));
    end;

    // AddLog(length(Lignes).tostring + ' lines in the file');
    // AddLog(Hands.count.tostring + ' lines in the list');

    Hands.SortHandsEx1;

    // AddLog(Hands.count.tostring + ' lines in the list');

    result := 0;
    for i := 1 to Hands.count do
      result := result + i * Hands[i - 1].bid;
  finally
    Hands.Free;
  end;
end;

function TForm1.Exercice2: uint64;
var
  Lig: integer;
  Lignes: TArray<string>;
  Tab: TArray<string>;
  Hands: THandsList;
  i: integer;
begin
  Hands := THandsList.Create;
  try
    Lignes := tfile.ReadAllLines(CDataFile);
    result := 0;
    for Lig := 0 to length(Lignes) - 1 do
    begin
      if Lignes[Lig].Trim.IsEmpty then
        break;
      Tab := Lignes[Lig].Trim.Split([' ']);
      Hands.Add(THand.Create(Tab[0], Tab[1].ToInt64, true));
    end;

    Hands.SortHandsEx2;

    result := 0;
    for i := 1 to Hands.count do
      result := result + i * Hands[i - 1].bid;
  finally
    Hands.Free;
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

{ THand }

constructor THand.Create(ACards: string; ABid: uint64; useJoker: boolean);
var
  i: integer;
  l: TDictionary<char, byte>;
  c, c2: char;
  nb: byte;
  enum: TDictionary<char, byte>.TValueEnumerator;
begin
  if ACards.Trim.IsEmpty then
    abort;
  Cards := ACards;
  bid := ABid;
  l := TDictionary<char, byte>.Create;
  try
    for i := 0 to Cards.length - 1 do
    begin
      c := Cards.Chars[i];
      if l.ContainsKey(c) then
        l[c] := l[c] + 1
      else
        l.Add(c, 1);
    end;
    if useJoker and l.ContainsKey('J') then
    begin
      nb := 0;
      c2 := ' ';
      for c in l.Keys do
        if (nb < l[c]) and (c <> 'J') then
        begin
          nb := l[c];
          c2 := c;
        end;
      if (nb > 0) then
      begin
        // Form1.AddLog('--');
        l[c2] := l[c2] + l['J'];
        // Form1.AddLog(l.count.tostring);
        l.Remove('J');
        // Form1.AddLog(l.count.tostring);
        // var
        // S := '';
        // for c in l.Keys do
        // for i := 1 to l[c] do
        // S := S + c;
        // Form1.AddLog(Cards + ' => ' + S);
      end;
    end;
    if l.count = 1 then
      handtype := THandType.FiveOfAKind
    else if l.count = 2 then
    begin
      enum := l.Values.GetEnumerator;
      try
        enum.MoveNext;
        // Form1.AddLog('--');
        // Form1.AddLog(enum.Current.tostring);
        if enum.Current in [4, 1] then
          handtype := THandType.FourOfAKind
        else // 3,2
          handtype := THandType.FullHouse;
      finally
        enum.Free;
      end;
    end
    else if l.count = 3 then
    begin
      enum := l.Values.GetEnumerator;
      try
        enum.MoveNext;
        // Form1.AddLog('--');
        // Form1.AddLog(enum.Current.tostring);
        if enum.Current = 3 then // 3,1,1
          handtype := THandType.ThreeOfAKind
        else if enum.Current = 2 then // 2,2,1 or 2,1,2
          handtype := THandType.TwoPair
        else
        begin
          enum.MoveNext;
          // Form1.AddLog(enum.Current.tostring);
          if enum.Current = 2 then // 1,2,2
            handtype := THandType.TwoPair
          else // 1,1,3 or 1,3,1
            handtype := THandType.ThreeOfAKind
        end;
      finally
        enum.Free;
      end;
    end
    else if l.count = 4 then // 2,1,1,1
      handtype := THandType.OnePair
    else // 1,1,1,1,1
      handtype := THandType.HighCard;
  finally
    l.Free;
  end;
end;

{ THandsList }

procedure THandsList.SortHandsEx1;
begin
  self.Sort(TComparer<THand>.Construct(
    function(const a, b: THand): integer
    var
      i: integer;
      idxA, idxB: integer;
    begin
      result := 0;
      if a.handtype > b.handtype then
        result := 1
      else if a.handtype < b.handtype then
        result := -1
      else
        for i := 0 to a.Cards.length - 1 do
        begin
          idxA := CardsEx1.IndexOf(a.Cards.Chars[i]);
          // if (idxA < 0) then
          // Form1.AddLog(idxA.tostring);
          idxB := CardsEx1.IndexOf(b.Cards.Chars[i]);
          // if (idxB < 0) then
          // Form1.AddLog(idxB.tostring);
          if idxA > idxB then
          begin
            result := 1;
            break;
          end
          else if idxA < idxB then
          begin
            result := -1;
            break;
          end;
        end;
      // if result = 0 then
      // Form1.AddLog('Equal cards : ' + a.Cards + ' ' + b.Cards);
      // Form1.AddLog(a.Cards + ' ' + b.Cards + ' ' + result.tostring);
    end));
end;

procedure THandsList.SortHandsEx2;
begin
  self.Sort(TComparer<THand>.Construct(
    function(const a, b: THand): integer
    var
      i: integer;
      idxA, idxB: integer;
    begin
      result := 0;
      if a.handtype > b.handtype then
        result := 1
      else if a.handtype < b.handtype then
        result := -1
      else
        for i := 0 to a.Cards.length - 1 do
        begin
          idxA := CardsEx2.IndexOf(a.Cards.Chars[i]);
          // if (idxA < 0) then
          // Form1.AddLog(idxA.tostring);
          idxB := CardsEx2.IndexOf(b.Cards.Chars[i]);
          // if (idxB < 0) then
          // Form1.AddLog(idxB.tostring);
          if idxA > idxB then
          begin
            result := 1;
            break;
          end
          else if idxA < idxB then
          begin
            result := -1;
            break;
          end;
        end;
      // if result = 0 then
      // Form1.AddLog('Equal cards : ' + a.Cards + ' ' + b.Cards);
      // Form1.AddLog(a.Cards + ' ' + b.Cards + ' ' + result.tostring);
    end));
end;

initialization

ReportMemoryLeaksOnShutdown := true;

end.
