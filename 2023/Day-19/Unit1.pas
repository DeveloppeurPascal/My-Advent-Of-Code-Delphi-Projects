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
{$SCOPEDENUMS ON}
  TCondition = (MoreThan, LessThan, None);

  TRule = class
    Categorie: char;
    Condition: TCondition;
    Value: int64;
    Workflow: string;
  end;

  TRules = TObjectList<TRule>;

  TWorkflows = class(TObjectDictionary<string, TRules>)
    function GetAcceptedPart(x, m, a, s: int64;
      WorkflowName: string = 'in'): int64;
  end;

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
    procedure AddLog(Const s: String);
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

procedure TForm1.AddLog(const s: String);
begin
  tthread.Synchronize(nil,
    procedure
    begin
      Memo1.Lines.Add(s);
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
  Tab: TArray<string>;
  WorkflowsLoaded: boolean;
  x, m, a, s: int64;
  Workflows: TWorkflows;
  wfName: string;
  Rules: TRules;
  Rule: TRule;
  i: integer;
  ConditionPos, DeuxPointsPos: int64;
begin
  Workflows := TWorkflows.Create([TDictionaryOwnership.doOwnsValues]);
  try
    Lignes := tfile.ReadAllLines(CDataFile);
    result := 0;
    WorkflowsLoaded := false;
    for Lig := 0 to length(Lignes) - 1 do
    begin
      if Lignes[Lig].isempty then
        WorkflowsLoaded := true
      else if not WorkflowsLoaded then
      begin // charge la liste des workflows et leurs règles
        // px{a<2006:qkq,m>2090:A,rfg}
        wfName := Lignes[Lig].substring(0, Lignes[Lig].IndexOf('{'));
        Rules := TRules.Create;
        Tab := Lignes[Lig].substring(Lignes[Lig].IndexOf('{') + 1)
          .split([',', '}']);
        for i := 0 to length(Tab) - 1 do
          if not Tab[i].isempty then
          begin
            DeuxPointsPos := Tab[i].IndexOf(':');
            Rule := TRule.Create;
            if (DeuxPointsPos < 0) then
            begin
              Rule.Condition := TCondition.None;
              Rule.Workflow := Tab[i];
            end
            else
            begin
              Rule.Categorie := Tab[i].Chars[0];
              ConditionPos := 1;
              // "<" ou ">" suivent la lettre, inutile de le chercher dans la chaine
              case Tab[i].Chars[ConditionPos] of
                '<':
                  Rule.Condition := TCondition.LessThan;
                '>':
                  Rule.Condition := TCondition.MoreThan;
              else
                raise exception.Create('Unknown condition "' + Tab[i].Chars
                  [ConditionPos] + '" for workflox "' + Tab[i] + '".');
              end;
              Rule.Value := Tab[i].substring(ConditionPos + 1,
                DeuxPointsPos - ConditionPos - 1).ToInt64;
              Rule.Workflow := Tab[i].substring(DeuxPointsPos + 1);
            end;
            Rules.Add(Rule);
          end;
        Workflows.Add(wfName, Rules);
      end
      else
      begin // traite les "parts" (données à gérer)
        // {x=2127,m=1623,a=2188,s=1013}
        Tab := Lignes[Lig].substring(1, Lignes[Lig].length - 2).split([',']);
        for i := 0 to length(Tab) - 1 do
        begin
          case Tab[i].Chars[0] of
            'x':
              x := Tab[i].substring(2).ToInt64;
            'm':
              m := Tab[i].substring(2).ToInt64;
            'a':
              a := Tab[i].substring(2).ToInt64;
            's':
              s := Tab[i].substring(2).ToInt64;
          else
            raise exception.Create('Unknown category "' + Tab[i].Chars[0] +
              '" for part "' + Tab[i] + '".');
          end;
        end;

        result := result + Workflows.GetAcceptedPart(x, m, a, s);
      end;
    end;
  finally
    Workflows.free;
  end;
end;

function TForm1.Exercice2: int64;
var
  Lig: integer;
  Lignes: TArray<string>;
begin
  Lignes := tfile.ReadAllLines(CDataFile);
  result := 0;
  for Lig := 0 to length(Lignes) - 1 do
  begin
    // TODO : à compléter
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
  s: string;
begin
  dt := 0;
  dt.addMilliSecond(ms);
  s := dt.GetMilliSecond.tostring;
  while length(s) < 3 do
    s := '0' + s;
  result := TimeToStr(dt) + ',' + s;
end;

{ TWorkflows }

function TWorkflows.GetAcceptedPart(x, m, a, s: int64;
WorkflowName: string): int64;
var
  i: integer;
  Rules: TRules;
begin
  result := 0;

  //form1.addlog(WorkflowName+' '+x.tostring+' '+m.tostring+' '+a.tostring+' '+s.tostring);

  Rules := self[WorkflowName];
  if not assigned(Rules) then
    raise exception.Create('Workflow "' + WorkflowName + '" doesn''t exists !');

  for i := 0 to Rules.count - 1 do
    case Rules[i].Condition of
      TCondition.MoreThan:
        if ((Rules[i].Categorie = 'x') and (x > Rules[i].Value)) or
          ((Rules[i].Categorie = 'm') and (m > Rules[i].Value)) or
          ((Rules[i].Categorie = 'a') and (a > Rules[i].Value)) or
          ((Rules[i].Categorie = 's') and (s > Rules[i].Value)) then
        begin
          if Rules[i].Workflow = 'A' then
            result := x + m + a + s
          else if Rules[i].Workflow = 'R' then
            result := 0
          else
            result := GetAcceptedPart(x, m, a, s, Rules[i].Workflow);
          exit;
        end;
      TCondition.LessThan:
        if ((Rules[i].Categorie = 'x') and (x < Rules[i].Value)) or
          ((Rules[i].Categorie = 'm') and (m < Rules[i].Value)) or
          ((Rules[i].Categorie = 'a') and (a < Rules[i].Value)) or
          ((Rules[i].Categorie = 's') and (s < Rules[i].Value)) then
        begin
          if Rules[i].Workflow = 'A' then
            result := x + m + a + s
          else if Rules[i].Workflow = 'R' then
            result := 0
          else
            result := GetAcceptedPart(x, m, a, s, Rules[i].Workflow);
          exit;
        end;
      TCondition.None:
        begin
          if Rules[i].Workflow = 'A' then
            result := x + m + a + s
          else if Rules[i].Workflow = 'R' then
            result := 0
          else
            result := GetAcceptedPart(x, m, a, s, Rules[i].Workflow);
          exit;
        end;
    end;
end;

initialization

{$IFDEF DEBUG}
  ReportMemoryLeaksOnShutdown := true;
{$ENDIF}

end.
