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
   CStepsEx1=64;
   CStepsEx2 = 26501365;
//  CDataFile = '..\..\input-test.txt';
//  CStepsEx1 = 6;
//  CStepsEx2 = 5000;

type
  TGrid = array of array of boolean;
  TPlotsList = TList<tpoint>;

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
    Grille: TGrid;
    procedure AddPlotToList(List: TPlotsList; x, y: integer);
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

procedure TForm1.AddPlotToList(List: TPlotsList; x, y: integer);
var
  i: integer;
  trouve: boolean;
begin
  trouve := false;
  for i := 0 to List.count - 1 do
    if (List[i].x = x) and (List[i].y = y) then
    begin
      trouve := true;
      break;
    end;
  if not trouve then
    List.Add(tpoint.create(x, y));
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
  x, y: integer;
  Plots, NewPlots: TPlotsList;
  Steps: integer;
  i: integer;
begin
  Plots := TPlotsList.create;
  try
    Lignes := tfile.ReadAllLines(CDataFile);
    setlength(Grille, length(Lignes));
    y := 0;
    for Lig := 0 to length(Lignes) - 1 do
    begin
      if Lignes[Lig].isempty then
        continue;

      setlength(Grille[y], length(Lignes[Lig]));
      for x := 0 to length(Lignes[Lig]) - 1 do
      begin
        Grille[y, x] := (Lignes[Lig].Chars[x] = '#');
        if (Lignes[Lig].Chars[x] = 'S') then
          Plots.Add(tpoint.create(x, y));
      end;
      inc(y);
    end;

    Steps := 0;
    repeat
      NewPlots := TPlotsList.create;
      for i := 0 to Plots.count - 1 do
      begin
        if (Plots[i].x > 0) and (not Grille[Plots[i].y, Plots[i].x - 1]) then
          AddPlotToList(NewPlots, Plots[i].x - 1, Plots[i].y);

        if (Plots[i].y > 0) and (not Grille[Plots[i].y - 1, Plots[i].x]) then
          AddPlotToList(NewPlots, Plots[i].x, Plots[i].y - 1);

        // addlog(length(grille).tostring+'x'+length(grille[Plots[i].y + 1]).tostring);
        // addlog (Plots[i].x.tostring+'<'+(length(Grille) - 1).tostring+' '+(Plots[i].y + 1).tostring+','+Plots[i].x.tostring);
        if (Plots[i].x < length(Grille[Plots[i].y]) - 1) and
          (not Grille[Plots[i].y, Plots[i].x + 1]) then
          AddPlotToList(NewPlots, Plots[i].x + 1, Plots[i].y);

        // AddLog(Plots[i].y.tostring + '<' + (length(Grille) - 1).tostring + ' ' +
        // (Plots[i].y + 1).tostring + ',' + Plots[i].x.tostring);
        if (Plots[i].y < length(Grille) - 1) and
          (not Grille[Plots[i].y + 1, Plots[i].x]) then
          AddPlotToList(NewPlots, Plots[i].x, Plots[i].y + 1);
      end;
      Plots.free;
      Plots := NewPlots;
      inc(Steps);
    until Steps = CStepsEx1;

    result := Plots.count;
  finally
    Plots.free;
  end;
end;

function TForm1.Exercice2: int64;
var
  Lig: integer;
  Lignes: TArray<string>;
  x, y: FixedInt;
  XMoinsUn, YMoinsUn: FixedInt;
  XPlusUn, YPlusUn: FixedInt;
  Plots, NewPlots: TPlotsList;
  Steps: integer;
  i: integer;
  NbLig, NbCol: FixedInt;
begin
  Plots := TPlotsList.create;
  try
    Lignes := tfile.ReadAllLines(CDataFile);
    setlength(Grille, length(Lignes));
    y := 0;
    for Lig := 0 to length(Lignes) - 1 do
    begin
      if Lignes[Lig].isempty then
        continue;

      setlength(Grille[y], length(Lignes[Lig]));
      for x := 0 to length(Lignes[Lig]) - 1 do
      begin
        Grille[y, x] := (Lignes[Lig].Chars[x] = '#');
        if (Lignes[Lig].Chars[x] = 'S') then
          Plots.Add(tpoint.create(x, y));
      end;
      inc(y);
    end;

    NbCol := length(Grille[0]);
    NbLig := length(Grille);
    Steps := 0;
    repeat
      NewPlots := TPlotsList.create;
      for i := 0 to Plots.count - 1 do
      begin
        x := Plots[i].x mod NbCol;
        while (x < 0) do
          x := x + NbCol;

        XMoinsUn := (Plots[i].x - 1) mod NbCol;
        while (XMoinsUn < 0) do
          XMoinsUn := XMoinsUn + NbCol;

        XPlusUn := (Plots[i].x + 1) mod NbCol;
        while (XPlusUn < 0) do
          XPlusUn := XPlusUn + NbCol;

        y := Plots[i].y mod NbLig;
        while (y < 0) do
          y := y + NbLig;

        YMoinsUn := (Plots[i].y - 1) mod NbLig;
        while (YMoinsUn < 0) do
          YMoinsUn := YMoinsUn + NbLig;

        YPlusUn := (Plots[i].y + 1) mod NbLig;
        while (YPlusUn < 0) do
          YPlusUn := YPlusUn + NbLig;

        try
          if (not Grille[y, XMoinsUn]) then
            AddPlotToList(NewPlots, Plots[i].x - 1, Plots[i].y);
        except
          AddLog(x.tostring + ',' + y.tostring + ' ' + NbCol.tostring + 'x' +
            NbLig.tostring + ' x-1=' + ((Plots[i].x - 1) mod NbCol).tostring);
        end;

        try
          if (not Grille[YMoinsUn, x]) then
            AddPlotToList(NewPlots, Plots[i].x, Plots[i].y - 1);
        except
          AddLog(x.tostring + ',' + y.tostring + ' ' + NbCol.tostring + 'x' +
            NbLig.tostring + ' y-1=' + ((Plots[i].y - 1) mod NbLig).tostring);
        end;

        try
          if (not Grille[y, XPlusUn]) then
            AddPlotToList(NewPlots, Plots[i].x + 1, Plots[i].y);
        except
          AddLog(x.tostring + ',' + y.tostring + ' ' + NbCol.tostring + 'x' +
            NbLig.tostring + ' x+1=' + ((Plots[i].x + 1) mod NbCol).tostring);
        end;

        try
          if (not Grille[YPlusUn, x]) then
            AddPlotToList(NewPlots, Plots[i].x, Plots[i].y + 1);
        except
          AddLog(x.tostring + ',' + y.tostring + ' ' + NbCol.tostring + 'x' +
            NbLig.tostring + ' y+1=' + ((Plots[i].y + 1) mod NbLig).tostring);
        end;
      end;
      Plots.free;
      Plots := NewPlots;
      inc(Steps);
    until Steps = CStepsEx2;

    result := Plots.count;
  finally
    Plots.free;
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

initialization

{$IFDEF DEBUG}
  ReportMemoryLeaksOnShutdown := true;
{$ENDIF}

end.
