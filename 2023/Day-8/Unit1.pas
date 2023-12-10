unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.WinXCtrls, Vcl.StdCtrls,
  System.Generics.Collections;

Const
  CDataFile = '..\..\input.txt';
  // CDataFile = '..\..\input-test.txt';
  // CDataFile = '..\..\input-test2.txt';
  // CDataFile = '..\..\input-test-ex2.txt';

type
  TNode = class
  public
    NodeName, Left, Right: string;
    isAnEnd: boolean;
    constructor Create(ANodeName, ALeftNode, ARightNode: string);
    function NextNode(Direction: char): string;
  end;

  TNetwork = class(TObjectDictionary<string, TNode>)
  public
    CompteurFinal: int64;
    NbOk: int64;
  end;

  TForm1 = class(TForm)
    Button1: TButton;
    ActivityIndicator1: TActivityIndicator;
    Button2: TButton;
    Edit1: TEdit;
    Edit2: TEdit;
    Memo1: TMemo;
    Button3: TButton;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Button3Click(Sender: TObject);
  private
    procedure BeginTraitement;
    procedure EndTraitement;
    { Déclarations privées }
    function Exercice1: int64;
    function Exercice2: int64;
    procedure Exercice2Loop(Const Network: TNetwork; StartNodeName: string;
      const Navigate: string);
    function Exercice2bis: int64;
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

procedure TForm1.Button3Click(Sender: TObject);
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
              Edit2.Text := Exercice2bis.tostring;
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
  Button3.Enabled := false;
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
      Button3.Enabled := true;
    end);
end;

function TForm1.Exercice1: int64;
var
  Lig: integer;
  Lignes: TArray<string>;
  NodeName: string;
  Network: TNetwork;
  Navigate: string;
  Tab: TArray<string>;
  i: integer;
begin
  Network := TNetwork.Create([doOwnsValues]);
  try
    Lignes := tfile.ReadAllLines(CDataFile);
    for Lig := 0 to length(Lignes) - 1 do
    begin
      case Lig of
        0:
          Navigate := Lignes[Lig];
      else
        if not Lignes[Lig].Trim.IsEmpty then
        begin
          Tab := Lignes[Lig].replace('(', '').replace(')', '').replace(' ', '')
            .Split(['=', ',']);
          assert(length(Tab) = 3, 'oups');
          Network.Add(Tab[0].Trim.ToUpper, TNode.Create(Tab[0].Trim.ToUpper,
            Tab[1].Trim.ToUpper, Tab[2].Trim.ToUpper));
        end;
      end;
    end;

    NodeName := 'AAA';
    result := 0;
    i := 0;
    while (NodeName <> 'ZZZ') and (Network.ContainsKey(NodeName)) do
    begin
      inc(result);
      NodeName := Network[NodeName].NextNode(Navigate.Chars[i]);
      inc(i);
      if (i >= Navigate.length) then
        i := 0;
    end;
  finally
    Network.Free;
  end;
end;

function TForm1.Exercice2: int64;
var
  Lig: integer;
  Lignes: TArray<string>;
  NodeName: string;
  NodesList: TList<string>;
  Network: TNetwork;
  Navigate: string;
  Tab: TArray<string>;
  i, j: integer;
  EndLoop: boolean;
begin
  Network := TNetwork.Create([doOwnsValues]);
  try
    Network.CompteurFinal := 0;
    Network.NbOk := 0;
    NodesList := TList<string>.Create;
    try
      Lignes := tfile.ReadAllLines(CDataFile);
      for Lig := 0 to length(Lignes) - 1 do
      begin
        case Lig of
          0:
            Navigate := Lignes[Lig];
        else
          if not Lignes[Lig].Trim.IsEmpty then
          begin
            Tab := Lignes[Lig].replace('(', '').replace(')', '')
              .replace(' ', '').Split(['=', ',']);
            assert(length(Tab) = 3, 'oups');
            Network.Add(Tab[0].Trim.ToUpper, TNode.Create(Tab[0].Trim.ToUpper,
              Tab[1].Trim.ToUpper, Tab[2].Trim.ToUpper));
          end;
        end;
      end;

      result := 0;
      for NodeName in Network.Keys do
        if NodeName.EndsWith('A') then
          NodesList.Add(NodeName)
        else if NodeName.EndsWith('Z') then
          inc(result);
      assert(result = NodesList.Count, 'Wrong xxA and xxZ count.');

      result := 0;
      for j := 0 to NodesList.Count - 1 do
        Exercice2Loop(Network, NodesList[j], Navigate);

      while (result = 0) do
      begin
        if tthread.CheckTerminated then
          abort;
        sleep(1000);
        System.TMonitor.Enter(Network);
        try
          if Network.NbOk = NodesList.Count then
            result := Network.CompteurFinal;
        finally
          System.TMonitor.exit(Network);
        end;
      end;

{$REGION 'methode trop longue en temps d''exécution'}
      // result := 0;
      // i := 0;
      // repeat
      // inc(result);
      //
      // EndLoop := true;
      // for j := 0 to NodesList.Count - 1 do
      // begin
      // assert(Network.ContainsKey(NodesList[j]),
      // 'Unknow node ' + NodesList[j]);
      // NodesList[j] := Network[NodesList[j]].NextNode(Navigate.Chars[i]);
      // EndLoop := EndLoop and NodesList[j].EndsWith('Z');
      // end;
      //
      // inc(i);
      // if (i >= Navigate.length) then
      // i := 0;
      // until EndLoop;
{$ENDREGION}
    finally
      NodesList.Free;
    end;
  finally
    Network.Free;
  end;
end;

function LCM(A, B: int64): int64;
// https://wiki.freepascal.org/Greatest_common_divisor#function_greatestCommonDivisor
  function greatestCommonDivisor(A, B: int64): int64;
  var
    temp: int64;
  begin
    while B <> 0 do
    begin
      temp := B;
      B := A mod B;
      A := temp
    end;
    result := A
  end;
// https://wiki.freepascal.org/Least_common_multiple
  function leastCommonMultiple(A, B: int64): int64;
  begin
    result := B * (A div greatestCommonDivisor(A, B));
  end;

begin
  result := leastCommonMultiple(A, B);
end;

// le nombre de sauts entre un début et une fin sont toujours les mêmes par
// chemin. Une fois calculé ce nombre il suffit de récupérer le plus petit
// multiple commun de chaque chemin possible.

// https://en.wikipedia.org/wiki/Least_common_multiple
// https://www.reddit.com/r/adventofcode/comments/18df7px/2023_day_8_solutions/
function TForm1.Exercice2bis: int64;
var
  Lig: integer;
  Lignes: TArray<string>;
  NodeName: string;
  NodesList: TList<string>;
  Network: TNetwork;
  Navigate: string;
  Tab: TArray<string>;
  i, j: integer;
  EndLoop: boolean;
  Compteur: int64;
begin
  Network := TNetwork.Create([doOwnsValues]);
  try
    Network.CompteurFinal := 0;
    Network.NbOk := 0;
    NodesList := TList<string>.Create;
    try
      Lignes := tfile.ReadAllLines(CDataFile);
      for Lig := 0 to length(Lignes) - 1 do
      begin
        case Lig of
          0:
            Navigate := Lignes[Lig];
        else
          if not Lignes[Lig].Trim.IsEmpty then
          begin
            Tab := Lignes[Lig].replace('(', '').replace(')', '')
              .replace(' ', '').Split(['=', ',']);
            assert(length(Tab) = 3, 'oups');
            Network.Add(Tab[0].Trim.ToUpper, TNode.Create(Tab[0].Trim.ToUpper,
              Tab[1].Trim.ToUpper, Tab[2].Trim.ToUpper));
          end;
        end;
      end;

      result := 0;
      for NodeName in Network.Keys do
        if NodeName.EndsWith('A') then
          NodesList.Add(NodeName)
        else if NodeName.EndsWith('Z') then
          inc(result);
      assert(result = NodesList.Count, 'Wrong xxA and xxZ count.');

      result := 0;
      for j := 0 to NodesList.Count - 1 do
      begin
        Compteur := 0;
        i := 0;
        repeat
          inc(Compteur);

          EndLoop := true;
          assert(Network.ContainsKey(NodesList[j]),
            'Unknow node ' + NodesList[j]);
          NodesList[j] := Network[NodesList[j]].NextNode(Navigate.Chars[i]);
          EndLoop := EndLoop and NodesList[j].EndsWith('Z');

          inc(i);
          if (i >= Navigate.length) then
            i := 0;
        until EndLoop;
        if result = 0 then
          result := Compteur
        else
          result := LCM(result, Compteur);
      end;
    finally
      NodesList.Free;
    end;
  finally
    Network.Free;
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

procedure TForm1.Exercice2Loop(Const Network: TNetwork; StartNodeName: string;
const Navigate: string);
begin
  tthread.CreateAnonymousThread(
    procedure
    var
      NodeName: string;
      Compteur: int64;
      NavIndex: int64;
      ReBoucle: boolean;
    begin
      NodeName := StartNodeName;
      NavIndex := 0;
      Compteur := 0;
      repeat
        if tthread.CheckTerminated then
          abort;
        repeat
          if tthread.CheckTerminated then
            abort;
          inc(Compteur);
          NodeName := Network[NodeName].NextNode(Navigate.Chars[NavIndex]);
          inc(NavIndex);
          if (NavIndex >= Navigate.length) then
            NavIndex := 0;
        until (Network[NodeName].isAnEnd);
        ReBoucle := false;
        System.TMonitor.Enter(Network);
        try
          if Network.CompteurFinal < Compteur then
          begin
            Network.NbOk := 1;
            Network.CompteurFinal := Compteur;
            tthread.Queue(nil,
              procedure
              begin
                Form1.Button2.caption := StartNodeName + ' : ' +
                  Compteur.tostring;
              end);
          end
          else if Network.CompteurFinal = Compteur then
            Network.NbOk := Network.NbOk + 1
          else
            ReBoucle := true;
        finally
          System.TMonitor.exit(Network);
        end;
        // tthread.Synchronize(nil,
        // procedure
        // begin
        // Form1.AddLog(StartNodeName + ' : ' + Compteur.tostring);
        // end);
        repeat
          sleep(5);
          if tthread.CheckTerminated then
            abort;
          System.TMonitor.Enter(Network);
          try
            ReBoucle := (Network.CompteurFinal <> Compteur);
          finally
            System.TMonitor.exit(Network);
          end;
        until ReBoucle;
      until (not ReBoucle);
    end).Start;
end;

{ TNode }

constructor TNode.Create(ANodeName, ALeftNode, ARightNode: string);
begin
  inherited Create;
  Left := ALeftNode;
  Right := ARightNode;
  NodeName := ANodeName;
  isAnEnd := NodeName.EndsWith('Z');
end;

function TNode.NextNode(Direction: char): string;
begin
  case Direction of
    'L':
      result := Left;
    'R':
      result := Right;
  else
    exception.Create('Unknow direction ' + Direction + '.');
  end;
end;

initialization

ReportMemoryLeaksOnShutdown := true;

end.
