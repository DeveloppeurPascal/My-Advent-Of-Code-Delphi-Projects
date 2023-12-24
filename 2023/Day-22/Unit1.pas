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
  TBrique = class;

  TTas = array of array of array of TBrique;

  TCoord3D = class
  private
    Fz: integer;
    Fx: integer;
    Fy: integer;
    procedure Setx(const Value: integer);
    procedure Sety(const Value: integer);
    procedure Setz(const Value: integer);
  protected
  public
    property x: integer read Fx write Setx;
    property y: integer read Fy write Sety;
    property z: integer read Fz write Setz;
    constructor Create(AX, AY, AZ: integer);
    function ToString: string;
  end;

  TBrique = class
  private
    FCoord2: TCoord3D;
    FCoord1: TCoord3D;
    procedure SetCoord1(const Value: TCoord3D);
    procedure SetCoord2(const Value: TCoord3D);
  protected
  public
    property Coord1: TCoord3D read FCoord1 write SetCoord1;
    property Coord2: TCoord3D read FCoord2 write SetCoord2;
    constructor Create(ACoord1, ACoord2: TCoord3D);
    destructor Destroy; override;
    procedure AddToStack(Stack: TTas);
    procedure RemoveFromStack(Stack: TTas);
    function IsDestructibleIn(Stack: TTas): boolean;
    function HasMoreThanOneSupportIn(Stack: TTas): boolean;
    function ToString: string;
    function NombreDeBriquesSupportees(Stack: TTas): integer;
  end;

  TBriquesList = class(TObjectList<TBrique>)
  private
  protected
  public
    procedure Log;
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
    procedure DescendreBrique(Brique: TBrique; TasDeBriques: TTas);
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

procedure TForm1.DescendreBrique(Brique: TBrique; TasDeBriques: TTas);
var
  x, y, z: integer;
  GoToZ: integer;
  EcartZ: integer;
  RienEnDessous: boolean;
begin
  if not assigned(Brique) then
    exit;

  GoToZ := min(Brique.Coord1.z, Brique.Coord2.z);
  for z := min(Brique.Coord1.z, Brique.Coord2.z) - 1 downto 1 do
  begin
    RienEnDessous := true;
    for x := min(Brique.Coord1.x, Brique.Coord2.x) to max(Brique.Coord1.x,
      Brique.Coord2.x) do
      for y := min(Brique.Coord1.y, Brique.Coord2.y) to max(Brique.Coord1.y,
        Brique.Coord2.y) do
        RienEnDessous := RienEnDessous and not assigned(TasDeBriques[x, y, z]);
    if RienEnDessous then
      GoToZ := z
    else
      break;
  end;

  EcartZ := min(Brique.Coord1.z, Brique.Coord2.z) - GoToZ;

  if (EcartZ > 0) then
  begin
    // retrait de la brique du tas
    Brique.RemoveFromStack(TasDeBriques);
    // changement coordonnées de la brique
    Brique.Coord1.z := Brique.Coord1.z - EcartZ;
    Brique.Coord2.z := Brique.Coord2.z - EcartZ;
    // ajout de la brique dans le tas
    Brique.AddToStack(TasDeBriques);
  end;

  // AddLog(Brique.ToString + ' - GotoZ=' + GotoZ.ToString+ ' - EcartZ=' + EcartZ.ToString);
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
  tab: TArray<string>;
  Briques: TBriquesList;
  Brique: TBrique;
  XMax, YMax, ZMax: integer;
  X1, X2, y1, Y2, Z1, Z2: integer;
  TasDeBriques: TTas;
  x, y, z: integer;
begin
  Briques := TBriquesList.Create;
  try
    // Load briques list
    Lignes := tfile.ReadAllLines(CDataFile);
    // 1,0,1~1,2,1
    // 0,0,2~2,0,2
    // 0,2,3~2,2,3
    XMax := 0;
    YMax := 0;
    ZMax := 0;
    for Lig := 0 to length(Lignes) - 1 do
    begin
      if Lignes[Lig].trim.isempty then
        continue;

      tab := Lignes[Lig].split([',', '~']);
      assert(length(tab) = 6, 'Wrong line content : "' + Lignes[Lig] + '"');

      X1 := tab[0].tointeger;
      y1 := tab[1].tointeger;
      Z1 := tab[2].tointeger;
      X2 := tab[3].tointeger;
      Y2 := tab[4].tointeger;
      Z2 := tab[5].tointeger;
      Briques.Add(TBrique.Create(TCoord3D.Create(X1, y1, Z1),
        TCoord3D.Create(X2, Y2, Z2)));

      if XMax < X1 then
        XMax := X1;
      if XMax < X2 then
        XMax := X2;

      if YMax < y1 then
        YMax := y1;
      if YMax < Y2 then
        YMax := Y2;

      if ZMax < Z1 then
        ZMax := Z1;
      if ZMax < Z2 then
        ZMax := Z2;
    end;

    // Set TTas size
    setlength(TasDeBriques, XMax + 1);
    for x := 0 to XMax do
    begin
      setlength(TasDeBriques[x], YMax + 1);
      for y := 0 to YMax do
        setlength(TasDeBriques[x, y], ZMax + 1 + 1);
      // pour un étage au dessus vide
    end;

    // Put bricks in the stack
    for Brique in Briques do
      Brique.AddToStack(TasDeBriques);

    // Briques.Log;

    // Move all bricks down
    for z := 2 to ZMax do
      for x := 0 to XMax do
        for y := 0 to YMax do
          if assigned(TasDeBriques[x, y, z]) then
            DescendreBrique(TasDeBriques[x, y, z], TasDeBriques);

    // Briques.Log;

    // check for all bricks if they can be removed
    result := 0;
    for Brique in Briques do
      if Brique.IsDestructibleIn(TasDeBriques) then
        result := result + 1;
  finally
    Briques.free;
  end;
end;

function TForm1.Exercice2: int64;
var
  Lig: integer;
  Lignes: TArray<string>;
  tab: TArray<string>;
  Briques: TBriquesList;
  Brique: TBrique;
  XMax, YMax, ZMax: integer;
  X1, X2, y1, Y2, Z1, Z2: integer;
  TasDeBriques: TTas;
  x, y, z: integer;
begin
  Briques := TBriquesList.Create;
  try
    // Load briques list
    Lignes := tfile.ReadAllLines(CDataFile);
    // 1,0,1~1,2,1
    // 0,0,2~2,0,2
    // 0,2,3~2,2,3
    XMax := 0;
    YMax := 0;
    ZMax := 0;
    for Lig := 0 to length(Lignes) - 1 do
    begin
      if Lignes[Lig].trim.isempty then
        continue;

      tab := Lignes[Lig].split([',', '~']);
      assert(length(tab) = 6, 'Wrong line content : "' + Lignes[Lig] + '"');

      X1 := tab[0].tointeger;
      y1 := tab[1].tointeger;
      Z1 := tab[2].tointeger;
      X2 := tab[3].tointeger;
      Y2 := tab[4].tointeger;
      Z2 := tab[5].tointeger;
      Briques.Add(TBrique.Create(TCoord3D.Create(X1, y1, Z1),
        TCoord3D.Create(X2, Y2, Z2)));

      if XMax < X1 then
        XMax := X1;
      if XMax < X2 then
        XMax := X2;

      if YMax < y1 then
        YMax := y1;
      if YMax < Y2 then
        YMax := Y2;

      if ZMax < Z1 then
        ZMax := Z1;
      if ZMax < Z2 then
        ZMax := Z2;
    end;

    // Set TTas size
    setlength(TasDeBriques, XMax + 1);
    for x := 0 to XMax do
    begin
      setlength(TasDeBriques[x], YMax + 1);
      for y := 0 to YMax do
        setlength(TasDeBriques[x, y], ZMax + 1 + 1);
      // pour un étage au dessus vide
    end;

    // Put bricks in the stack
    for Brique in Briques do
      Brique.AddToStack(TasDeBriques);

    // Briques.Log;

    // Move all bricks down
    for z := 2 to ZMax do
      for x := 0 to XMax do
        for y := 0 to YMax do
          if assigned(TasDeBriques[x, y, z]) then
            DescendreBrique(TasDeBriques[x, y, z], TasDeBriques);

    // Briques.Log;

    // Pour chaque brique on regarde combien tombent si on la désintègre
    // (donc on s'occupe des briques qui n'étaient pas désintégrables dans l'exercice 1)
    result := 0;
    for Brique in Briques do
      if not Brique.IsDestructibleIn(TasDeBriques) then
        result := result + Brique.NombreDeBriquesSupportees(TasDeBriques);
  finally
    Briques.free;
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

{ TCoord3D }

constructor TCoord3D.Create(AX, AY, AZ: integer);
begin
  inherited Create;
  Fx := AX;
  Fy := AY;
  Fz := AZ;
end;

procedure TCoord3D.Setx(const Value: integer);
begin
  Fx := Value;
end;

procedure TCoord3D.Sety(const Value: integer);
begin
  Fy := Value;
end;

procedure TCoord3D.Setz(const Value: integer);
begin
  Fz := Value;
end;

function TCoord3D.ToString: string;
begin
  result := x.ToString + ',' + y.ToString + ',' + z.ToString;
end;

{ TBrique }

procedure TBrique.AddToStack(Stack: TTas);
var
  x, y, z: integer;
begin
  for x := min(Coord1.x, Coord2.x) to max(Coord1.x, Coord2.x) do
    for y := min(Coord1.y, Coord2.y) to max(Coord1.y, Coord2.y) do
      for z := min(Coord1.z, Coord2.z) to max(Coord1.z, Coord2.z) do
        Stack[x, y, z] := self;
end;

constructor TBrique.Create(ACoord1, ACoord2: TCoord3D);
begin
  inherited Create;
  Coord1 := ACoord1;
  Coord2 := ACoord2;
end;

destructor TBrique.Destroy;
begin
  Coord1.free;
  Coord2.free;
  inherited;
end;

function TBrique.HasMoreThanOneSupportIn(Stack: TTas): boolean;
var
  Support: TBrique;
  x, y, z: integer;
begin
  Support := nil;
  z := min(Coord1.z, Coord2.z) - 1;
  if z = 0 then
    result := true
  else
  begin
    result := false;
    for x := min(Coord1.x, Coord2.x) to max(Coord1.x, Coord2.x) do
      for y := min(Coord1.y, Coord2.y) to max(Coord1.y, Coord2.y) do
        if assigned(Stack[x, y, z]) then
          if Support = nil then
            Support := Stack[x, y, z]
          else if (Support <> Stack[x, y, z]) then
          begin
            result := true;
            exit;
          end;
  end;
end;

function TBrique.IsDestructibleIn(Stack: TTas): boolean;
var
  x, y, z: integer;
begin
  result := true;
  z := max(Coord1.z, Coord2.z) + 1;
  for x := min(Coord1.x, Coord2.x) to max(Coord1.x, Coord2.x) do
    for y := min(Coord1.y, Coord2.y) to max(Coord1.y, Coord2.y) do
      if assigned(Stack[x, y, z]) then
        result := result and Stack[x, y, z].HasMoreThanOneSupportIn(Stack);
end;

function TBrique.NombreDeBriquesSupportees(Stack: TTas): integer;
var
  Liste: TList<TBrique>;
  Brique: TBrique;
  x, y, z: integer;
begin
  result := 0;
  Liste := TList<TBrique>.Create;
  try
    z := max(Coord1.z, Coord2.z) + 1;
    for x := min(Coord1.x, Coord2.x) to max(Coord1.x, Coord2.x) do
      for y := min(Coord1.y, Coord2.y) to max(Coord1.y, Coord2.y) do
        if assigned(Stack[x, y, z]) and not Liste.Contains(Stack[x, y, z]) then
          Liste.Add(Stack[x, y, z]);

    // Form1.AddLog(ToString + ' -> ' + Liste.count.ToString);
    for Brique in Liste do
      if not Brique.HasMoreThanOneSupportIn(Stack) then
        result := result + 1 + Brique.NombreDeBriquesSupportees(Stack);

    // TODO :finir calcul ici
    // -> marquer les briques de dessus (sans autre support) comme étant détruites
    // -> modifier le test des supports
    // -> parcourrir les briques au dessus d'elles 1 seule fois et compter celles qui tombent
    // -> marquer les briques comme non détruites au retour
  finally
    Liste.free;
  end;
end;

procedure TBrique.RemoveFromStack(Stack: TTas);
var
  x, y, z: integer;
begin
  for x := min(Coord1.x, Coord2.x) to max(Coord1.x, Coord2.x) do
    for y := min(Coord1.y, Coord2.y) to max(Coord1.y, Coord2.y) do
      for z := min(Coord1.z, Coord2.z) to max(Coord1.z, Coord2.z) do
        Stack[x, y, z] := nil;
end;

procedure TBrique.SetCoord1(const Value: TCoord3D);
begin
  FCoord1 := Value;
end;

procedure TBrique.SetCoord2(const Value: TCoord3D);
begin
  FCoord2 := Value;
end;

function TBrique.ToString: string;
begin
  result := Coord1.ToString + '~' + Coord2.ToString;
end;

{ TBriquesList }

procedure TBriquesList.Log;
var
  Brique: TBrique;
begin
  Form1.AddLog('----------');
  for Brique in self do
    Form1.AddLog(Brique.ToString);
end;

initialization

{$IFDEF DEBUG}
  ReportMemoryLeaksOnShutdown := true;
{$ENDIF}

end.
