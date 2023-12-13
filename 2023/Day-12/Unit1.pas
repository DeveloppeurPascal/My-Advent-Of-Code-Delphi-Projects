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
  TNbList = TList<int64>;

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
    function CalculeArrangements(Const Arrangement: string; ArrIdx: int64;
      Const Nb: TNbList; NbIdx: int64): int64;
    function CalculeArrangementsBis(Const Arrangement: string; ArrIdx: int64;
      Const Nb: TNbList; NbIdx: int64; ACurNb: int64 = -1): int64;
      deprecated 'ne fonctionne pas';
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

uses
  System.Threading,
  System.SyncObjs,
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

// var
// RecurNb: integer;

function TForm1.CalculeArrangements(const Arrangement: string; ArrIdx: int64;
const Nb: TNbList; NbIdx: int64): int64;
var
  CurrentNb: int64;
  Point: boolean;
begin
  if tthread.checkterminated then
    exit;

  result := 0;
  CurrentNb := 0;
  Point := true;
  // AddLog(Arrangement.substring(ArrIdx) + ' ' + ArrIdx.tostring + ' ' +
  // NbIdx.tostring);
  while (ArrIdx < Arrangement.length) do
  begin
    // AddLog(Arrangement.chars[ArrIdx]);
    case Arrangement.chars[ArrIdx] of
      '.': // On passe au suivant sauf si on traitait des '#' et qu'il en reste
        if (CurrentNb > 0) then
          exit
        else
          Point := true;
      '?':
        begin
          if (CurrentNb > 0) then // série de '#' ou '?' en cours
            CurrentNb := CurrentNb - 1
          else // Soit '.', soit '#'
          begin
            // On le traite comme un '.'
            // inc(RecurNb);
            // AddLog('begin recur ' + RecurNb.tostring + ': ' + result.tostring);
            result := result + CalculeArrangements(Arrangement, ArrIdx + 1,
              Nb, NbIdx);
            // AddLog('end recur ' + RecurNb.tostring + ': ' + result.tostring);
            // dec(RecurNb);
            // On le traite comme un '#' et on démarre une nouvelle série
            if not Point then
              exit;
            NbIdx := NbIdx + 1;
            if NbIdx >= Nb.count then // Plus de série attendue, donc erreur
              exit
            else // On démarre une nouvelle série de '#'
              CurrentNb := Nb[NbIdx] - 1;
            // AddLog('new serie sur index ' + ArrIdx.tostring + ' attendus ' +
            // Nb[NbIdx].tostring);
          end;
          Point := false;
        end;
      '#':
        begin
          if (CurrentNb > 0) then // série de '#' ou '?' en cours
            CurrentNb := CurrentNb - 1
          else // Nouvelle série de dièse
          begin
            // On doit avoir un point entre deux séries
            if not Point then
              exit;
            // Série suivante
            NbIdx := NbIdx + 1;
            if NbIdx >= Nb.count then // Plus de série attendue
              exit
            else
              CurrentNb := Nb[NbIdx] - 1;
            // AddLog('new serie sur index ' + ArrIdx.tostring + ' attendus ' +
            // Nb[NbIdx].tostring);
          end;
          Point := false;
        end;
    else
      raise exception.create('Unknow character "' + Arrangement.chars
        [ArrIdx] + '" !');
    end;
    ArrIdx := ArrIdx + 1;
  end;
  if (NbIdx >= Nb.count) or ((CurrentNb = 0) and (NbIdx = Nb.count - 1)) then
    result := result + 1;
end;

function TForm1.CalculeArrangementsBis(Const Arrangement: string; ArrIdx: int64;
Const Nb: TNbList; NbIdx: int64; ACurNb: int64): int64;
// Version trop compliquée qui ne sort pas les bonnes valeurs dans tous les cas
// (laissée ici pour autopsie future)
var
  CurrentNb: int64;
  // NbInterro: int64;
  // i: integer;
  // res: int64;
begin
  result := 0;

  if Arrangement.isempty then
    exit;

  AddLog(Arrangement + ' ' + ArrIdx.tostring + ' ' + NbIdx.tostring);

  if (ArrIdx >= length(Arrangement)) then
  begin
    if (NbIdx >= Nb.count) then
      result := 1;
    exit;
  end
  else if (NbIdx >= Nb.count) then
  begin
    result := 0;
    exit;
  end;

  if (ACurNb > 0) then // on était dans une série de '#' ou '?'
    while (ArrIdx < length(Arrangement)) and
      (Arrangement.chars[ArrIdx] = '.') do
      ArrIdx := ArrIdx + 1;

  // fin de ligne ou on a un "?" ou un "#'

  if (ArrIdx >= length(Arrangement)) then
  begin
    if (NbIdx >= Nb.count) then
      result := 1;
    exit;
  end;

  if ACurNb >= 0 then
    CurrentNb := ACurNb
  else
    CurrentNb := Nb[NbIdx];

  if Arrangement.chars[ArrIdx] = '#' then
  begin // '#'
    while (ArrIdx < length(Arrangement)) and (CurrentNb > 0) and
      (Arrangement.chars[ArrIdx] in ['#', '?']) do
    begin
      CurrentNb := CurrentNb - 1;
      ArrIdx := ArrIdx + 1;
    end;

    if (CurrentNb = 0) then
    begin
      if (ArrIdx >= length(Arrangement)) then
        result := 1
      else if (Arrangement.chars[ArrIdx] = '#') then // 1 '#' de trop
      else
        result := CalculeArrangementsBis(Arrangement, ArrIdx + 1, Nb,
          NbIdx + 1);
      exit;
    end
    else
      // fin de ligne ou point
      exit;
  end;

  if Arrangement.chars[ArrIdx] = '?' then
  begin
    // '?' => '#'
    if (CurrentNb > 0) then
      result := result + CalculeArrangementsBis(Arrangement, ArrIdx + 1, Nb,
        NbIdx, CurrentNb - 1);
    // '?' => '.'
    result := result + CalculeArrangementsBis(Arrangement, ArrIdx + 1,
      Nb, NbIdx);
    (*
      NbInterro := 0;
      while ((ArrIdx + NbInterro) < length(Arrangement)) and
      (Arrangement.Chars[ArrIdx + NbInterro] = '?') do
      NbInterro := NbInterro + 1;

      if (NbInterro = CurrentNb) then
      begin
      if ((ArrIdx + NbInterro) >= length(Arrangement)) then
      if (NbIdx >= Nb.count - 1) then
      result := 1
      else
      exit;

      if (Arrangement.Chars[ArrIdx + NbInterro] = '.') then
      result := CalculeArrangementsBis(Arrangement, ArrIdx + NbInterro + 1, Nb,
      NbIdx + 1)
      else // forcément un '#' de trop, on prend le premier '?' pour un '.'
      result := CalculeArrangementsBis(Arrangement, ArrIdx + NbInterro + 1, Nb,
      NbIdx, CurrentNb);
      end
      else if (NbInterro < CurrentNb) then
      begin
      CurrentNb := CurrentNb - NbInterro;
      ArrIdx := ArrIdx + NbInterro;
      while (ArrIdx < length(Arrangement)) and (CurrentNb > 0) and
      (Arrangement.Chars[ArrIdx] in ['#', '?']) do
      begin
      CurrentNb := CurrentNb - 1;
      ArrIdx := ArrIdx + 1;
      end;
      if (CurrentNb = 0) then
      begin
      if (ArrIdx >= length(Arrangement)) then
      result := 1
      else if (Arrangement.Chars[ArrIdx] = '#') then // 1 '#' de trop
      else
      result := CalculeArrangementsBis(Arrangement, ArrIdx + 1, Nb, NbIdx + 1);
      exit;
      end
      else
      // fin de ligne ou point
      exit;
      end
      else
      for i := 0 to NbInterro - 1 do
      if ArrIdx + i + CurrentNb >= length(Arrangement) then
      result := result + 1
      else if Arrangement.Chars[ArrIdx + CurrentNb + i] in ['?', '.'] then
      result := result + CalculeArrangementsBis
      (string.Create('?', NbInterro - CurrentNb - i) +
      Arrangement.Substring(ArrIdx + NbInterro), 0, Nb, NbIdx + 1);
    *)
  end;
end;

procedure TForm1.AddLog(const S: String);
begin
  if tthread.checkterminated then
    exit;

  tthread.queue(nil,
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
  tthread.queue(nil,
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
  Tab: TArray<string>;
  Arrangement: string;
  Nb: TNbList;
  i: integer;
begin
  Nb := TNbList.create;
  try
    Lignes := tfile.ReadAllLines(CDataFile);
    result := 0;
    for Lig := 0 to length(Lignes) - 1 do
    begin
      if Lignes[Lig].isempty then
        continue;

      Tab := Lignes[Lig].split([' ']);
      assert(length(Tab) = 2, 'line error');
      Arrangement := Tab[0];

      Tab := Tab[1].split([',']);
      Nb.clear;
      for i := 0 to length(Tab) - 1 do
        Nb.Add(Tab[i].toint64);

      result := result + CalculeArrangements(Arrangement, 0, Nb, -1);
    end;
  finally
    Nb.free;
  end;
end;

function TForm1.Exercice2: int64;
var
  Lignes: TArray<string>;
  NbLignes: int64;
  Total: int64;
  MutexTotal: TMutex;
begin
  Lignes := tfile.ReadAllLines(CDataFile);
  NbLignes := length(Lignes);
  Total := 0;
  MutexTotal := TMutex.create;
  try
    tparallel.for(0, NbLignes - 1,
      procedure(Lig: integer)
      var
        Tab: TArray<string>;
        Arrangement, ArrangementFinal: string;
        i, j: integer;
        TotalLigne, NbPourUne, NbPourDeux, NbPourTrois, NbPourQuatre,
          NbPourCinq: int64;
        Nb: TNbList;
      begin
        try
          if Lignes[Lig].isempty then
            exit;

          AddLog('Début de ligne ' + Lig.tostring);

          Nb := TNbList.create;
          try
            Tab := Lignes[Lig].split([' ']);
            assert(length(Tab) = 2, 'line error');

            Arrangement := Tab[0];

            Tab := Tab[1].split([',']);
            Nb.clear;
            // for j := 1 to 5 do
            for i := 0 to length(Tab) - 1 do
              Nb.Add(Tab[i].toint64);

            // ArrangementFinal := Arrangement + '?' + Arrangement + '?' +
            // Arrangement + '?' + Arrangement + '?' + Arrangement;
            // NbArrangements := CalculeArrangements(ArrangementFinal, 0, Nb, -1);

            TotalLigne := 0;

            NbPourUne := CalculeArrangements(Arrangement, 0, Nb, -1);

            for i := 0 to length(Tab) - 1 do
              Nb.Add(Tab[i].toint64);
            NbPourDeux := CalculeArrangements(Arrangement + '#' + Arrangement,
              0, Nb, -1);

            for i := 0 to length(Tab) - 1 do
              Nb.Add(Tab[i].toint64);
            NbPourTrois := CalculeArrangements(Arrangement + '#' + Arrangement +
              '#' + Arrangement, 0, Nb, -1);

            for i := 0 to length(Tab) - 1 do
              Nb.Add(Tab[i].toint64);
            NbPourQuatre := CalculeArrangements(Arrangement + '#' + Arrangement
              + '#' + Arrangement + '#' + Arrangement, 0, Nb, -1);

            for i := 0 to length(Tab) - 1 do
              Nb.Add(Tab[i].toint64);
            NbPourCinq := CalculeArrangements(Arrangement + '#' + Arrangement +
              '#' + Arrangement + '#' + Arrangement + '#' + Arrangement,
              0, Nb, -1);

            // ArrangementFinal := Arrangement + '.' + Arrangement + '.' +
            // Arrangement + '.' + Arrangement + '.' + Arrangement;
            TotalLigne := TotalLigne + NbPourUne * NbPourUne * NbPourUne *
              NbPourUne * NbPourUne;

            // ArrangementFinal := Arrangement + '#' + Arrangement + '.' +
            // Arrangement + '.' + Arrangement + '.' + Arrangement;
            TotalLigne := TotalLigne + NbPourDeux * NbPourUne * NbPourUne *
              NbPourUne;

            // ArrangementFinal := Arrangement + '.' + Arrangement + '#' +
            // Arrangement + '.' + Arrangement + '.' + Arrangement;
            TotalLigne := TotalLigne + NbPourUne * NbPourDeux * NbPourUne *
              NbPourUne;

            // ArrangementFinal := Arrangement + '#' + Arrangement + '#' +
            // Arrangement + '.' + Arrangement + '.' + Arrangement;
            TotalLigne := TotalLigne + NbPourTrois * NbPourUne * NbPourUne;

            // ArrangementFinal := Arrangement + '.' + Arrangement + '.' +
            // Arrangement + '#' + Arrangement + '.' + Arrangement;
            TotalLigne := TotalLigne + NbPourUne * NbPourUne * NbPourDeux *
              NbPourUne;

            // ArrangementFinal := Arrangement + '#' + Arrangement + '.' +
            // Arrangement + '#' + Arrangement + '.' + Arrangement;
            TotalLigne := TotalLigne + NbPourDeux * NbPourDeux * NbPourUne;

            // ArrangementFinal := Arrangement + '.' + Arrangement + '#' +
            // Arrangement + '#' + Arrangement + '.' + Arrangement;
            TotalLigne := TotalLigne + NbPourUne * NbPourTrois * NbPourUne;

            // ArrangementFinal := Arrangement + '#' + Arrangement + '#' +
            // Arrangement + '#' + Arrangement + '.' + Arrangement;
            TotalLigne := TotalLigne + NbPourQuatre * NbPourUne;

            // ArrangementFinal := Arrangement + '.' + Arrangement + '.' +
            // Arrangement + '.' + Arrangement + '#' + Arrangement;
            TotalLigne := TotalLigne + NbPourUne * NbPourUne * NbPourUne *
              NbPourDeux;

            // ArrangementFinal := Arrangement + '#' + Arrangement + '.' +
            // Arrangement + '.' + Arrangement + '#' + Arrangement;
            TotalLigne := TotalLigne + NbPourDeux * NbPourUne * NbPourDeux;

            // ArrangementFinal := Arrangement + '.' + Arrangement + '#' +
            // Arrangement + '.' + Arrangement + '#' + Arrangement;
            TotalLigne := TotalLigne + NbPourUne * NbPourDeux * NbPourDeux;

            // ArrangementFinal := Arrangement + '#' + Arrangement + '#' +
            // Arrangement + '.' + Arrangement + '#' + Arrangement;
            TotalLigne := TotalLigne + NbPourTrois * NbPourDeux;

            // ArrangementFinal := Arrangement + '.' + Arrangement + '.' +
            // Arrangement + '#' + Arrangement + '#' + Arrangement;
            TotalLigne := TotalLigne + NbPourUne * NbPourUne * NbPourTrois;

            // ArrangementFinal := Arrangement + '#' + Arrangement + '.' +
            // Arrangement + '#' + Arrangement + '#' + Arrangement;
            TotalLigne := TotalLigne + NbPourDeux * NbPourTrois;

            // ArrangementFinal := Arrangement + '.' + Arrangement + '#' +
            // Arrangement + '#' + Arrangement + '#' + Arrangement;
            TotalLigne := TotalLigne + NbPourUne * NbPourQuatre;

            // ArrangementFinal := Arrangement + '#' + Arrangement + '#' +
            // Arrangement + '#' + Arrangement + '#' + Arrangement;
            TotalLigne := TotalLigne + NbPourCinq;

            MutexTotal.Acquire;
            try
              dec(NbLignes);
              Total := Total + TotalLigne;
              AddLog('Fin de ligne ' + Lig.tostring + ', Total ligne=' +
                TotalLigne.tostring + ', Total=' + Total.tostring +
                ', Lignes restantes=' + NbLignes.tostring);
            finally
              MutexTotal.release;
            end;
          finally
            Nb.free;
          end;
        except
          on e: exception do
            AddLog('Erreur ligne ' + Lig.tostring + ' : ' + e.Message);
        end;
      end);
  finally
    MutexTotal.free;
  end;
  result := Total;
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

initialization

{$IFDEF DEBUG}
  ReportMemoryLeaksOnShutdown := true;
{$ENDIF}

end.
