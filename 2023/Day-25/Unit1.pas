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
  // CDataFile = '..\..\input.txt';
  CDataFile = '..\..\input-test.txt';

type
  TLiaisons = class(TDictionary<string, boolean>)
  private
  protected
  public
    function ToString(OnlyActif: boolean = false): string;
  end;

  TModuleLie = class
  private
    FEnabled: boolean;
    FManaged: boolean;
    procedure SetEnabled(const Value: boolean);
  public
    ModuleA, ModuleB: string;
    TagBool: boolean;
    property Enabled: boolean read FEnabled write SetEnabled;
    constructor Create(A, B: string);
  end;

  TModulesLies = class(TObjectList<TModuleLie>)
  public
    procedure AjouteLiaison(ModuleA, ModuleB: string);
    function GetListes(Const ListeLiaisons: TModulesLies): tstringlist;
  end;

  TModules = class(TObjectDictionary<string, TLiaisons>)
  private
  protected
  public
    procedure AjouteLiaison(ModuleA, ModuleB: string);
    procedure RetireLiaison(ModuleA, ModuleB: string);
    function ToString: string;
    function GetModulesLies(AModule: string; ACurListe: TLiaisons = nil)
      : TLiaisons;
    function GetListesModulesLies: tstringlist;
    function GetListeLiaisons: TModulesLies;
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
    procedure AddLog(Const S: String);
    function MsToTimeString(ms: int64): string;
  public
    { Déclarations publiques }
    function CoupeLiaisonsJusquAFinExercice1(Modules: TModules): tstringlist;
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
  System.StrUtils,
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
              Edit1.Text := Exercice1.ToString;
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
              Edit2.Text := Exercice2.ToString;
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

function TForm1.CoupeLiaisonsJusquAFinExercice1(Modules: TModules): tstringlist;
var
  ListeLiaisons: TModulesLies;
  i, j, k: integer;
  ok: boolean;
begin
  result := nil;
  ListeLiaisons := Modules.GetListeLiaisons;
  try
    AddLog(ListeLiaisons.count.ToString + ' liaisons entre modules');
    ok := false;
    for i := 0 to ListeLiaisons.count - 3 do
    begin
      ListeLiaisons[i].Enabled := false;
      for j := i + 1 to ListeLiaisons.count - 2 do
      begin
        ListeLiaisons[j].Enabled := false;
        for k := j + 1 to ListeLiaisons.count - 1 do
        begin
          ListeLiaisons[k].Enabled := false;
          result := ListeLiaisons.GetListes;
          if result.count = 2 then
          begin
            ok := true;
            break;
          end
          else
          begin
            result.free;
            ListeLiaisons[k].Enabled := true;
          end;
        end;
        if ok then
          break
        else
          ListeLiaisons[j].Enabled := true;
      end;
      if ok then
        break
      else
        ListeLiaisons[i].Enabled := true;
    end;
  finally
    ListeLiaisons.free;
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
  Modules: TModules;
  Tab: TArray<string>;
  i: integer;
  sl: tstringlist;
begin
  Modules := TModules.Create([tdictionaryownership.doOwnsValues]);
  try
    AddLog('lecture des données');

    Lignes := tfile.ReadAllLines(CDataFile);
    result := 0;
    for Lig := 0 to length(Lignes) - 1 do
    begin
      if Lignes[Lig].trim.isempty then
        continue;

      Tab := Lignes[Lig].split([':', ' ']);
      for i := 1 to length(Tab) - 1 do
        Modules.AjouteLiaison(Tab[0], Tab[i]);
    end;

    AddLog(Modules.ToString);

    AddLog('lancement du calcul');

    sl := CoupeLiaisonsJusquAFinExercice1(Modules);
    try
      if sl.count = 2 then
      begin
        Tab := sl[0].trim.split([' ']);
        result := length(Tab);
        Tab := sl[1].trim.split([' ']);
        result := result * length(Tab);
      end
      else
        result := -1;
    finally
      sl.free;
    end;
  finally
    Modules.free;
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
  S: string;
begin
  dt := 0;
  dt.addMilliSecond(ms);
  S := dt.GetMilliSecond.ToString;
  while length(S) < 3 do
    S := '0' + S;
  result := TimeToStr(dt) + ',' + S;
end;

{ TModules }

procedure TModules.AjouteLiaison(ModuleA, ModuleB: string);
begin
  if ModuleA.trim.isempty or ModuleB.trim.isempty or (ModuleA = ModuleB) then
    exit;

  if not self.ContainsKey(ModuleA) then
    Add(ModuleA, TLiaisons.Create);

  if not self[ModuleA].ContainsKey(ModuleB) then
    self[ModuleA].Add(ModuleB, true);

  if not self.ContainsKey(ModuleB) then
    Add(ModuleB, TLiaisons.Create);

  if not self[ModuleB].ContainsKey(ModuleA) then
    self[ModuleB].Add(ModuleA, true);
end;

function TModules.GetListeLiaisons: TModulesLies;
var
  ModuleName: string;
  S: string;
begin
  result := TModulesLies.Create;
  for ModuleName in self.keys do
    for S in self[ModuleName].keys do
      result.AjouteLiaison(ModuleName, S);
end;

function TModules.GetListesModulesLies: tstringlist;
var
  S: string;
  ModulesLies: TLiaisons;
  sResult: string;
begin
  result := tstringlist.Create;
  for S in self.keys do
  begin
    ModulesLies := GetModulesLies(S);
    try
      sResult := ModulesLies.ToString;
      if not result.Contains(sResult) then
        result.Add(sResult);
    finally
      ModulesLies.free;
    end;
  end;
end;

function TModules.GetModulesLies(AModule: string; ACurListe: TLiaisons)
  : TLiaisons;
var
  i: integer;
  Modif: boolean;
  Liste: TLiaisons;
  CurModule: string;
begin
  if assigned(ACurListe) then
    result := ACurListe
  else
    result := TLiaisons.Create;

  if not result.ContainsKey(AModule) then
    result.Add(AModule, true);

  for CurModule in self[AModule].keys do
    if self[AModule][CurModule] and (not result.ContainsKey(CurModule)) then
      result := GetModulesLies(CurModule, result);
end;

procedure TModules.RetireLiaison(ModuleA, ModuleB: string);
begin
  self[ModuleA].Remove(ModuleB);
  self[ModuleB].Remove(ModuleA);
end;

function TModules.ToString: string;
var
  S: string;
  ModulesLies: TLiaisons;
begin
  result := '';
  for S in self.keys do
  begin
    result := result + S + ' :' + self[S].ToString + slinebreak;
    ModulesLies := GetModulesLies(S);
    try
      result := result + '=> ' + ModulesLies.ToString + slinebreak;
    finally
      ModulesLies.free;
    end;
  end;
end;

{ TLiaisons }

function TLiaisons.ToString(OnlyActif: boolean): string;
var
  ModuleName: string;
begin
  result := '';
  for ModuleName in keys do
    if (not OnlyActif) or (OnlyActif and self[ModuleName]) then
      result := result + ' ' + ModuleName;
end;

{ TModuleLie }

constructor TModuleLie.Create(A, B: string);
begin
  inherited Create;
  ModuleA := A;
  ModuleB := B;
  FEnabled := true;
  TagBool := false;
end;

procedure TModuleLie.SetEnabled(const Value: boolean);
begin
  FEnabled := Value;
end;

{ TModulesLies }

procedure TModulesLies.AjouteLiaison(ModuleA, ModuleB: string);
var
  m1, m2: string;
  i: integer;
  trouve: boolean;
begin
  if string.Compare(ModuleA, ModuleB) < 0 then
  begin
    m1 := ModuleA;
    m2 := ModuleB;
  end
  else
  begin
    m1 := ModuleB;
    m2 := ModuleA;
  end;

  trouve := false;
  for i := 0 to count - 1 do
    if (self[i].ModuleA = m1) and (self[i].ModuleB = m2) then
    begin
      trouve := true;
      break;
    end;

  if not trouve then
    Add(TModuleLie.Create(m1, m2));
end;

function TModulesLies.GetListes(const ListeLiaisons: TModulesLies): tstringlist;
var
  i, j: integer;
  S: string;
begin
  for i := 0 to ListeLiaisons.count - 1 do
    ListeLiaisons[i].TagBool := false;

  result := tstringlist.Create;

  for i := 0 to ListeLiaisons.count - 1 do begin
  s:='';
    while (ListeLiaisons[i].Enabled and not ListeLiaisons[i].TagBool) do
    begin
    // TODO
    end;
  end;
end;

initialization

{$IFDEF DEBUG}
  ReportMemoryLeaksOnShutdown := true;
{$ENDIF}

end.
