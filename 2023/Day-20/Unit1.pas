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
  System.Messaging,
  System.Generics.Collections;

Const
  CDataFile = '..\..\input.txt';
  // CDataFile = '..\..\input-test.txt';
  // CDataFile = '..\..\input-test2.txt';

type
{$SCOPEDENUMS ON}
  TPulseLevel = (LowPulse, HighPulse);

  TOutputModulesList = class;

  TModule = class
  private
    FName: string;
    FOutputModules: TOutputModulesList;
    procedure SetName(const Value: string);
    procedure SetOutputModules(const Value: TOutputModulesList);
  protected
  public
    property Name: string read FName write SetName;
    property OutputModules: TOutputModulesList read FOutputModules
      write SetOutputModules;
    constructor Create(AName: string); virtual;
    destructor Destroy; override;
    procedure ReceivePulse(Sender: TModule; PulseLevel: TPulseLevel); virtual;
    procedure SendPulse(PulseLevel: TPulseLevel);
    procedure AddOutputModule(AOutputModule: TModule);
  end;

  TOutputModulesList = class(TList<TModule>)
  end;

  TInputModulesList = class(TDictionary<TModule, TPulseLevel>)
  end;

  TBroadcasterModule = class(TModule)
  public
    procedure ReceivePulse(Sender: TModule; PulseLevel: TPulseLevel); override;
  end;

  TFlipFlopModule = class(TModule)
  private
    FIsOn: boolean;
    procedure SetIsOn(const Value: boolean);
  protected
  public
    property IsOn: boolean read FIsOn write SetIsOn;
    constructor Create(AName: string); override;
    procedure ReceivePulse(Sender: TModule; PulseLevel: TPulseLevel); override;
  end;

  TConjunctionModule = class(TModule)
  private
    FInputModules: TInputModulesList;
    procedure SetInputModules(const Value: TInputModulesList);
  protected
  public
    property InputModules: TInputModulesList read FInputModules
      write SetInputModules;
    constructor Create(AName: string); override;
    destructor Destroy; override;
    procedure ReceivePulse(Sender: TModule; PulseLevel: TPulseLevel); override;
    procedure AddInputModule(AInputModule: TModule);
  end;

  TRXModule = class(TModule)
  public
    procedure ReceivePulse(Sender: TModule; PulseLevel: TPulseLevel); override;
  end;

  TPulseMessage = class(tmessage)
  private
    FPulseLevel: TPulseLevel;
    FToModule: TModule;
    FFromModule: TModule;
    procedure SetFromModule(const Value: TModule);
    procedure SetPulseLevel(const Value: TPulseLevel);
    procedure SetToModule(const Value: TModule);
  protected
  public
    property FromModule: TModule read FFromModule write SetFromModule;
    property ToModule: TModule read FToModule write SetToModule;
    property PulseLevel: TPulseLevel read FPulseLevel write SetPulseLevel;
    constructor Create(AFromModule, AToModule: TModule;
      APulseLevel: TPulseLevel);
  end;

  TStartMachineMessage = class(tmessage)

  end;

  TModulesList = TObjectDictionary<string, TModule>;

  TTheMachine = class
  private
    FModules: TModulesList;
    FNbLowPulse: int64;
    FNbHighPulse: int64;
    FNBButtonPressed: int64;
    FIsStarted: boolean;
    procedure SetModules(const Value: TModulesList);
    procedure SetNbHighPulse(const Value: int64);
    procedure SetnbLowPulse(const Value: int64);
    procedure SetNBButtonPressed(const Value: int64);
    procedure SetIsStarted(const Value: boolean);
  protected
  public
    property IsStarted: boolean read FIsStarted write SetIsStarted;
    property Modules: TModulesList read FModules write SetModules;
    property NbLowPulse: int64 read FNbLowPulse write SetnbLowPulse;
    property NbHighPulse: int64 read FNbHighPulse write SetNbHighPulse;
    property NBButtonPressed: int64 read FNBButtonPressed
      write SetNBButtonPressed;
    constructor Create;
    destructor Destroy; override;
    procedure LoadFromFile(Filename: string);
    procedure Reset;
    procedure PressButton;
    procedure onReceivePulseMessage(const Sender: TObject; const M: tmessage);
    procedure onReceiveStartMachineMessage(const Sender: TObject;
      const M: tmessage);
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
  i: integer;
  TheMachine: TTheMachine;
begin
  TheMachine := TTheMachine.Create;
  try
    TheMachine.LoadFromFile(CDataFile);
    TheMachine.Reset;
    for i := 1 to 1000 do
      TheMachine.PressButton;
    result := TheMachine.NbLowPulse * TheMachine.NbHighPulse;
  finally
    TheMachine.free;
  end;
end;

function TForm1.Exercice2: int64;
var
  i: integer;
  TheMachine: TTheMachine;
begin
  TheMachine := TTheMachine.Create;
  try
    TheMachine.LoadFromFile(CDataFile);
    TheMachine.Reset;
    repeat
      if tthread.checkterminated then
        exit;
      TheMachine.PressButton;
    until TheMachine.IsStarted;
    result := TheMachine.NBButtonPressed;
  finally
    TheMachine.free;
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

{ TModule }

procedure TModule.AddOutputModule(AOutputModule: TModule);
begin
  if (FOutputModules.IndexOf(AOutputModule) < 0) then
    FOutputModules.Add(AOutputModule);

  if AOutputModule is TConjunctionModule then
    (AOutputModule as TConjunctionModule).AddInputModule(Self);
end;

constructor TModule.Create(AName: string);
begin
  inherited Create;
  FName := AName;
  FOutputModules := TOutputModulesList.Create;
end;

destructor TModule.Destroy;
begin
  FOutputModules.free;
  inherited;
end;

procedure TModule.ReceivePulse(Sender: TModule; PulseLevel: TPulseLevel);
begin
  // nothing to do at this level
end;

procedure TModule.SendPulse(PulseLevel: TPulseLevel);
var
  M: TModule;
begin
  for M in OutputModules do
    TMessageManager.DefaultManager.SendMessage(Self, TPulseMessage.Create(Self,
      M, PulseLevel), true);
end;

procedure TModule.SetName(const Value: string);
begin
  FName := Value;
end;

procedure TModule.SetOutputModules(const Value: TOutputModulesList);
begin
  FOutputModules := Value;
end;

{ TFlipFlopModule }

constructor TFlipFlopModule.Create(AName: string);
begin
  inherited;
  FIsOn := false;
end;

procedure TFlipFlopModule.ReceivePulse(Sender: TModule;
PulseLevel: TPulseLevel);
begin
  if (PulseLevel = TPulseLevel.LowPulse) then
  begin
    FIsOn := not FIsOn;
    case FIsOn of
      true:
        SendPulse(TPulseLevel.HighPulse);
      false:
        SendPulse(TPulseLevel.LowPulse);
    end;
  end;
end;

procedure TFlipFlopModule.SetIsOn(const Value: boolean);
begin
  FIsOn := Value;
end;

{ TBroadcasterModule }

procedure TBroadcasterModule.ReceivePulse(Sender: TModule;
PulseLevel: TPulseLevel);
begin
  SendPulse(PulseLevel);
end;

{ TConjunction }

procedure TConjunctionModule.AddInputModule(AInputModule: TModule);
begin
  if not FInputModules.ContainsKey(AInputModule) then
    FInputModules.Add(AInputModule, TPulseLevel.LowPulse);
end;

constructor TConjunctionModule.Create(AName: string);
begin
  inherited;
  FInputModules := TInputModulesList.Create;
end;

destructor TConjunctionModule.Destroy;
begin
  FInputModules.free;
  inherited;
end;

procedure TConjunctionModule.ReceivePulse(Sender: TModule;
PulseLevel: TPulseLevel);
var
  M: TModule;
  pl: TPulseLevel;
  IsHighForAll: boolean;
begin
  InputModules.AddOrSetValue(Sender, PulseLevel);

  IsHighForAll := true;
  for pl in InputModules.values do
    IsHighForAll := IsHighForAll and (pl = TPulseLevel.HighPulse);

  if IsHighForAll then
    SendPulse(TPulseLevel.LowPulse)
  else
    SendPulse(TPulseLevel.HighPulse);
end;

procedure TConjunctionModule.SetInputModules(const Value: TInputModulesList);
begin
  FInputModules := Value;
end;

{ TPulseMessage }

constructor TPulseMessage.Create(AFromModule, AToModule: TModule;
APulseLevel: TPulseLevel);
begin
  inherited Create;
  FromModule := AFromModule;
  ToModule := AToModule;
  PulseLevel := APulseLevel;
end;

procedure TPulseMessage.SetFromModule(const Value: TModule);
begin
  FFromModule := Value;
end;

procedure TPulseMessage.SetPulseLevel(const Value: TPulseLevel);
begin
  FPulseLevel := Value;
end;

procedure TPulseMessage.SetToModule(const Value: TModule);
begin
  FToModule := Value;
end;

{ TTheMachine }

constructor TTheMachine.Create;
begin
  inherited Create;
  FModules := TModulesList.Create([TDictionaryOwnership.doOwnsValues]);
  FIsStarted := false;
  Reset;
  TMessageManager.DefaultManager.SubscribeToMessage(TPulseMessage,
    onReceivePulseMessage);
  TMessageManager.DefaultManager.SubscribeToMessage(TStartMachineMessage,
    onReceiveStartMachineMessage);
end;

destructor TTheMachine.Destroy;
begin
  TMessageManager.DefaultManager.unSubscribe(TStartMachineMessage,
    onReceiveStartMachineMessage, true);
  TMessageManager.DefaultManager.unSubscribe(TPulseMessage,
    onReceivePulseMessage, true);
  FModules.free;
  inherited;
end;

procedure TTheMachine.LoadFromFile(Filename: string);
var
  Lig: integer;
  Lignes: TArray<string>;
  Phase: byte;
  tab: TArray<string>;
  ModuleName: string;
  i: integer;
begin
  // broadcaster -> a, b, c
  // %a -> b
  // &inv -> a

  Lignes := tfile.ReadAllLines(CDataFile);
  for Phase := 1 to 2 do
  begin
    for Lig := 0 to length(Lignes) - 1 do
    begin
      if Lignes[Lig].isempty then
        continue;

      case Phase of
        1: // Creation des modules dans la liste
          begin
            ModuleName := Lignes[Lig].substring(0, Lignes[Lig].IndexOf(' '));
            if ModuleName.Chars[0] = '&' then
              FModules.Add(ModuleName.substring(1),
                TConjunctionModule.Create(ModuleName.substring(1)))
            else if ModuleName.Chars[0] = '%' then
              FModules.Add(ModuleName.substring(1),
                TFlipFlopModule.Create(ModuleName.substring(1)))
            else if ModuleName = 'broadcaster' then
              FModules.Add(ModuleName, TBroadcasterModule.Create(ModuleName))
            else if ModuleName = 'rx' then
              FModules.Add(ModuleName, TRXModule.Create(ModuleName))
            else
              FModules.Add(ModuleName, TModule.Create(ModuleName));
          end;
        2: // Chainage entre les modules
          begin
            ModuleName := Lignes[Lig].substring(0, Lignes[Lig].IndexOf(' '));
            if (ModuleName.Chars[0] in ['&', '%']) then
              ModuleName := ModuleName.substring(1);
            tab := Lignes[Lig].substring(Lignes[Lig].IndexOf('>') + 2)
              .split([',', ' ']);
            for i := 0 to length(tab) - 1 do
              if (not tab[i].isempty) then
              begin
                if not FModules.ContainsKey(tab[i]) then
                  if tab[i] = 'rx' then
                    FModules.Add(tab[i], TRXModule.Create(tab[i]))
                  else
                    FModules.Add(tab[i], TModule.Create(tab[i]));
                FModules[ModuleName].AddOutputModule(FModules[tab[i]]);
              end;
          end;
      end;
    end;

    // for var key in FModules.keys do
    // Form1.AddLog(key);
  end;
end;

procedure TTheMachine.onReceivePulseMessage(const Sender: TObject;
const M: tmessage);
var
  pm: TPulseMessage;
begin
  if M is TPulseMessage then
  begin
    pm := M as TPulseMessage;
    if pm.PulseLevel = TPulseLevel.LowPulse then
      NbLowPulse := NbLowPulse + 1
    else if pm.PulseLevel = TPulseLevel.HighPulse then
      NbHighPulse := NbHighPulse + 1;
    pm.ToModule.ReceivePulse(pm.FromModule, pm.PulseLevel);
  end;
end;

procedure TTheMachine.onReceiveStartMachineMessage(const Sender: TObject;
const M: tmessage);
begin
  FIsStarted := M is TStartMachineMessage;
end;

procedure TTheMachine.PressButton;
begin
  FNBButtonPressed := FNBButtonPressed + 1;
  TMessageManager.DefaultManager.SendMessage(Self, TPulseMessage.Create(nil,
    FModules['broadcaster'], TPulseLevel.LowPulse), true);
end;

procedure TTheMachine.Reset;
begin
  FNbLowPulse := 0;
  FNbHighPulse := 0;
  FNBButtonPressed := 0;
end;

procedure TTheMachine.SetIsStarted(const Value: boolean);
begin
  FIsStarted := Value;
end;

procedure TTheMachine.SetModules(const Value: TModulesList);
begin
  FModules := Value;
end;

procedure TTheMachine.SetNBButtonPressed(const Value: int64);
begin
  FNBButtonPressed := Value;
end;

procedure TTheMachine.SetNbHighPulse(const Value: int64);
begin
  FNbHighPulse := Value;
end;

procedure TTheMachine.SetnbLowPulse(const Value: int64);
begin
  FNbLowPulse := Value;
end;

{ TRXModule }

procedure TRXModule.ReceivePulse(Sender: TModule; PulseLevel: TPulseLevel);
begin
  inherited;
  if PulseLevel = TPulseLevel.LowPulse then
    TMessageManager.DefaultManager.SendMessage(Self,
      TStartMachineMessage.Create, true);
end;

initialization

{$IFDEF DEBUG}
  ReportMemoryLeaksOnShutdown := true;
{$ENDIF}

end.
