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
  // CDataFile = '..\..\input-test.txt';

type
  TModulesList = class;

  /// <summary>
  /// Liaison entre deux modules
  /// </summary>
  TLiaison = class
  public
    IDModuleA, IDModuleB: integer;
    constructor Create(AIDModuleA, AIDModuleB: integer);
  end;

  /// <summary>
  /// Liste des liaisons entre des modules
  /// </summary>
  TLiaisonsList = class(TObjectList<TLiaison>)
  public
    procedure AjouteLiaison(IDModuleA, IDModuleB: integer);
    function ToString(Modules: TModulesList): string;
  end;

  /// <summary>
  /// Liste des ID de modules
  /// </summary>
  TIDModulesList = class(TList<integer>)
  private
  protected
  public
    function ToString(Modules: TModulesList): string;
  end;

  /// <summary>
  /// Contenu d'un module
  /// </summary>
  TModule = class
  private
    FModuleName: string;
    FModulesLies: TIDModulesList;

    procedure SetModulesLies(const Value: TIDModulesList);
    procedure SetModuleName(const Value: string);
  protected
  public
    property ModuleName: string read FModuleName write SetModuleName;
    property ModulesLies: TIDModulesList read FModulesLies write SetModulesLies;
    constructor Create(AModuleName: string);
    destructor Destroy; override;
    procedure AjouteLienAvecModule(ModuleID: integer);
  end;

  /// <summary>
  /// Liste des modules
  /// </summary>
  TModulesList = class(TObjectList<TModule>)
  private
  protected
  public
    procedure AjouteLiaison(ModuleA, ModuleB: string);
    function ToString: string; override;
    function GetLiaisons: TLiaisonsList;
  end;

  TForm1 = class(TForm)
    Button1: TButton;
    ActivityIndicator1: TActivityIndicator;
    Button2: TButton;
    Edit1: TEdit;
    Edit2: TEdit;
    Memo1: TMemo;
    procedure Button1Click(Sender: tobject);
    procedure Button2Click(Sender: tobject);
    procedure FormCreate(Sender: tobject);
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
    function hasTwoModulesSets(Modules: TModulesList; Liaisons: TLiaisonsList;
      IDCanceledLiaison1, IDCanceledLiaison2, IDCanceledLiaison3: integer;
      var NbModulesInSet1, NbModulesInSet2: integer): boolean;
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
  System.threading,
  System.IOUtils;

procedure TForm1.Button1Click(Sender: tobject);
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

procedure TForm1.Button2Click(Sender: tobject);
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
  Modules: TModulesList;
  Tab: TArray<string>;
  i, j, k: integer;
  Liaisons: TLiaisonsList;
  NbModulesInSet1, NbModulesInSet2: integer;
begin
  result := -1;

  // contient la liste des noms de modules
  Modules := TModulesList.Create;
  try

    // Chargement du fichier et calcul des liaisons entre modules
    AddLog('Chargement des données');
    Lignes := tfile.ReadAllLines(CDataFile);
    for Lig := 0 to length(Lignes) - 1 do
    begin
      if Lignes[Lig].trim.isempty then
        continue;

      Tab := Lignes[Lig].split([':', ' ']);
      for i := 1 to length(Tab) - 1 do
        Modules.AjouteLiaison(Tab[0], Tab[i]);
    end;
    // AddLog(Modules.ToString);

    AddLog('Calcul des liaisons entre module');
    Liaisons := Modules.GetLiaisons;
    try
      // AddLog(Liaisons.ToString(Modules));

      AddLog('Recherche des liaisons à supprimer');

{$REGION 'trop lent sur de gros volumes'}
      if false then
      begin
        for i := 0 to Liaisons.count - 1 - 2 do
        begin
          for j := i + 1 to Liaisons.count - 1 - 1 do
          begin
            for k := j + 1 to Liaisons.count - 1 do
            begin
              // addlog(i.tostring+'-'+j.tostring+'-'+k.tostring);
              // tparallel.for(j + 1, Liaisons.count - 1, procedure begin
              if hasTwoModulesSets(Modules, Liaisons, i, j, k, NbModulesInSet1,
                NbModulesInSet2) then
              begin
                // SetResult(NbModulesInSet1 * NbModulesInSet2);
                result := NbModulesInSet1 * NbModulesInSet2;
                break;
              end;
              // end);
            end;
            if result > 0 then
              break;
          end;
          if result > 0 then
            break;
        end;
      end;
{$ENDREGION}
    finally
      Liaisons.free;
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

procedure TForm1.FormCreate(Sender: tobject);
begin
  Edit1.Text := '';
  Edit2.Text := '';
  Memo1.Clear;
end;

function TForm1.hasTwoModulesSets(Modules: TModulesList;
Liaisons: TLiaisonsList; IDCanceledLiaison1, IDCanceledLiaison2,
  IDCanceledLiaison3: integer; var NbModulesInSet1, NbModulesInSet2
  : integer): boolean;

  function GetNbElementsInSet(ID: integer;
  var ModulesNonTraites: TList<integer>;
  AModulesLies: TList < integer >= nil): integer;
  var
    ModulesLies: TList<integer>;
    IDModuleLie, j: integer;
    IDModuleA, IDModuleB: integer;
  begin
    if ModulesNonTraites.Contains(ID) then
      ModulesNonTraites.remove(ID)
    else
      // begin
      // AddLog('sortie');
      exit;
    // end;

    if assigned(AModulesLies) then
      ModulesLies := AModulesLies
    else
      ModulesLies := TList<integer>.Create;

    try

      if ModulesLies.Contains(ID) then // existe déjà, ça ne devrait pas
        raise exception.Create('anomalie');

      ModulesLies.Add(ID);

      for j := 0 to Modules[ID].ModulesLies.count - 1 do
      begin
        IDModuleLie := Modules[ID].ModulesLies[j];

        IDModuleA := min(ID, IDModuleLie);
        IDModuleB := max(ID, IDModuleLie);

        if ((IDModuleA = Liaisons[IDCanceledLiaison1].IDModuleA) and
          (IDModuleB = Liaisons[IDCanceledLiaison1].IDModuleB)) or
          ((IDModuleA = Liaisons[IDCanceledLiaison2].IDModuleA) and
          (IDModuleB = Liaisons[IDCanceledLiaison2].IDModuleB)) or
          ((IDModuleA = Liaisons[IDCanceledLiaison3].IDModuleA) and
          (IDModuleB = Liaisons[IDCanceledLiaison3].IDModuleB)) then
          // liaisons coupées, on ne fait rien
          // AddLog('liaison coupée')
        else
          GetNbElementsInSet(IDModuleLie, ModulesNonTraites, ModulesLies);
      end;

    finally
      result := ModulesLies.count;
      if not assigned(AModulesLies) then
        ModulesLies.free;
    end;
  end;

var
  ID: integer;
  ModulesNonTraites: TList<integer>;
begin
  result := false;
  ModulesNonTraites := TList<integer>.Create;
  try
    for ID := 0 to Modules.count - 1 do
      ModulesNonTraites.Add(ID);

    // AddLog(ModulesNonTraites.count.ToString);

    if ModulesNonTraites.count > 0 then
      NbModulesInSet1 := GetNbElementsInSet(ModulesNonTraites[0],
        ModulesNonTraites)
    else
      NbModulesInSet1 := -1;

    // AddLog(NbModulesInSet1.ToString);
    // AddLog(ModulesNonTraites.count.ToString);

    if ModulesNonTraites.count > 0 then
      NbModulesInSet2 := GetNbElementsInSet(ModulesNonTraites[0],
        ModulesNonTraites)
    else
      NbModulesInSet2 := -1;

    // AddLog(NbModulesInSet2.ToString);
    // AddLog(ModulesNonTraites.count.ToString);

    result := (ModulesNonTraites.count = 0) and (NbModulesInSet1 > 0) and
      (NbModulesInSet2 > 0);
  finally
    ModulesNonTraites.free;
  end;
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

{ TModule }

procedure TModule.AjouteLienAvecModule(ModuleID: integer);
begin
  if not FModulesLies.Contains(ModuleID) then
    FModulesLies.Add(ModuleID);
end;

constructor TModule.Create(AModuleName: string);
begin
  inherited Create;
  FModuleName := AModuleName;
  FModulesLies := TIDModulesList.Create;
end;

destructor TModule.Destroy;
begin
  FModulesLies.free;
  inherited;
end;

procedure TModule.SetModulesLies(const Value: TIDModulesList);
begin
  FModulesLies := Value;
end;

procedure TModule.SetModuleName(const Value: string);
begin
  FModuleName := Value;
end;

{ TModulesList }

procedure TModulesList.AjouteLiaison(ModuleA, ModuleB: string);
var
  IDModuleA, IDModuleB: integer;
  ID: integer;
begin
  if ModuleA.isempty or ModuleB.isempty or (ModuleA = ModuleB) then
    exit;

  // cherche les ID des deux modules s'ils existent
  IDModuleA := -1;
  IDModuleB := -1;
  for ID := 0 to self.count - 1 do
    if ModuleA = self[ID].ModuleName then
      IDModuleA := ID
    else if ModuleB = self[ID].ModuleName then
      IDModuleB := ID;

  // crée le ModuleA car non trouvé dans la liste
  if (IDModuleA < 0) then
    IDModuleA := Add(TModule.Create(ModuleA));

  // crée le ModuleB car non trouvé dans la liste
  if (IDModuleB < 0) then
    IDModuleB := Add(TModule.Create(ModuleB));

  self[IDModuleA].AjouteLienAvecModule(IDModuleB);
  self[IDModuleB].AjouteLienAvecModule(IDModuleA);
end;

function TModulesList.GetLiaisons: TLiaisonsList;
var
  ID, j: integer;
begin
  result := TLiaisonsList.Create;
  for ID := 0 to count - 1 do
    for j := 0 to self[ID].ModulesLies.count - 1 do
      result.AjouteLiaison(ID, self[ID].ModulesLies[j]);
end;

function TModulesList.ToString: string;
var
  ID: integer;
begin
  result := '';
  for ID := 0 to count - 1 do
    result := result + self[ID].ModuleName + ':' + self[ID].ModulesLies.ToString
      (self) + slinebreak;
end;

{ TIDModulesList }

function TIDModulesList.ToString(Modules: TModulesList): string;
var
  i: integer;
begin
  result := '';
  for i := 0 to count - 1 do
    result := result + ' ' + Modules[self[i]].ModuleName;
end;

{ TLiaisonsList }

procedure TLiaisonsList.AjouteLiaison(IDModuleA, IDModuleB: integer);
var
  idA, idB: integer;
  i: integer;
  trouve: boolean;
begin
  idA := min(IDModuleA, IDModuleB);
  idB := max(IDModuleA, IDModuleB);

  trouve := false;
  for i := 0 to count - 1 do
  begin
    trouve := (idA = self[i].IDModuleA) and (idB = self[i].IDModuleB);
    if trouve then
      break;
  end;

  if not trouve then
    Add(TLiaison.Create(idA, idB));
end;

function TLiaisonsList.ToString(Modules: TModulesList): string;
var
  i: integer;
begin
  result := '';
  for i := 0 to count - 1 do
    result := result + Modules[self[i].IDModuleA].ModuleName + ' - ' +
      Modules[self[i].IDModuleB].ModuleName + slinebreak;
end;

{ TLiaison }

constructor TLiaison.Create(AIDModuleA, AIDModuleB: integer);
begin
  inherited Create;
  IDModuleA := AIDModuleA;
  IDModuleB := AIDModuleB;
end;

initialization

{$IFDEF DEBUG}
  ReportMemoryLeaksOnShutdown := true;
{$ENDIF}

end.
