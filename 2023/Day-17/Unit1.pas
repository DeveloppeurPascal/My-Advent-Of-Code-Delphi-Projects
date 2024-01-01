unit Unit1;

// L'algorithme de pathfinding de base utilisé a départ ne règle les déplacements
// que case par case sans tenir compte de la contrainte du nombre maximum de
// déplacements dans un sens.
//
// @NineBerry ayant partagé sa solutions en C# lors de la session sur Twitch,
// j'ai repris ce qu'il a fait pour la version finale de ce projet.
// https://dotnetfiddle.net/9DN6g5
//
// Dans mon cas j'ai le chemin parcourru, mais ce n'est pas nécessaire pour
// résoudre l'exercice 1 donc on part sur une file d'attente de cases parcourues
// dans un sens et avec un nombre courant de pas pour l'atteindre.
//
// 2 Solutons disponibles, à la main sous forme de liste chainée ou via TObjectList
{$DEFINE MyPriorityQueueBis }

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
  // CDataFile = '..\..\input-test2.txt';

  CNbPasMiniEx1 = 1; // minimum 1 case avant de regarder à gauche et à droite
  CNbPasMaxiEx1 = 3; // maximum 3 cases de déplacement

  CNbPasMiniEx2 = 4; // minimum 4 case avant de regarder à gauche et à droite
  CNbPasMaxiEx2 = 10; // maximum 10 cases de déplacement

const
  CPoidsMax = maxint - 10;
  // 10 étant le poids maxi d'une case (HeatLoss de 1 à 9)

type
{$SCOPEDENUMS ON}
  TDirection = (haut, droite, bas, gauche);

  TElem = class
  public
    // Données de base
    X, Y: int64;
    HeatLoss: int64;
    // Provenant du déplacement
    Direction: TDirection;
    NbPasCourants: int64;
    constructor Create(AX, AY: int64; AHeatLoss: int64; ADirection: TDirection;
      ANbPasCourants: int64);
  end;

  TMyPriorityQueue = class(TObjectList<TElem>)
  public
    procedure Push(Elem: TElem);
    function Pop: TElem;
  end;

  TMyPriorityQueueBis = class
  private type
    TItem = class
    public
      Prior, Next: TItem;
      Value: TElem;
      constructor Create;
    end;

  var
    FCount: int64;

  protected
    First, Last: TItem;
  public
    property Count: int64 read FCount;
    procedure Push(Elem: TElem);
    function Pop: TElem;
    constructor Create;
    destructor Destroy; override;
  end;

{$IFDEF MyPriorityQueueBis}

type
  TPriorityQueue = TMyPriorityQueueBis;
{$ELSE}

type
  TPriorityQueue = TMyPriorityQueue;
{$ENDIF}

  // TCellsVisited = class(TObjectList<TElem>)
  // function hasVisitedElem(AX, AY: int64; ADirection: TDirection;
  // ANbPasCourant: int64): boolean;
  // end;
  TCellsVisited = class(TDictionary<int64, boolean>)
  public
    function GetKey(AX, AY: int64; ADirection: TDirection; ANbPasCourant: int64)
      : int64; inline;
    function hasVisitedElem(AX, AY: int64; ADirection: TDirection;
      ANbPasCourant: int64): boolean;
    procedure Ajoute(AX, AY: int64; ADirection: TDirection;
      ANbPasCourant: int64);
  end;

  TCell = record
    HeatLoss: int64;
    PathFindingPoidsCellule: int64;
    PathFindingDejaPasse: boolean;
  end;

  TLig = array of TCell;
  TMap = array of TLig;

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
    Map: TMap;
    function TrouveLaFin(X, Y: int64; VX, VY: int64): int64;
    procedure PathFindingSurMap(EndX, EndY: int64);
    procedure DrawMap;
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

uses
  System.Math,
  System.StrUtils,
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

procedure TForm1.DrawMap;
var
  Col, Lig: int64;
  S: string;
begin
  AddLog('Heat loss :');
  for Lig := 0 to length(Map[0]) - 1 do
  begin
    S := '';
    for Col := 0 to length(Map) - 1 do
      if Map[Col][Lig].PathFindingDejaPasse then
        S := S + '*'
      else
        S := S + Map[Col][Lig].HeatLoss.tostring;
    AddLog(S);
  end;
  AddLog('');
  AddLog('Poids:');
  for Lig := 0 to length(Map[0]) - 1 do
  begin
    S := '';
    for Col := 0 to length(Map) - 1 do
      S := S + ifthen(not S.isempty, ',', '') + Map[Col][Lig]
        .PathFindingPoidsCellule.tostring;
    AddLog(S);
  end;
  AddLog('');
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

  procedure VaVersLaGauche(Elem: TElem; Queue: TPriorityQueue);
  var
    newx, newy: int64;
    newdirection: TDirection;
  begin
    case Elem.Direction of
      TDirection.haut:
        begin
          newdirection := TDirection.gauche;
          newx := Elem.X - 1;
          newy := Elem.Y;
        end;
      TDirection.droite:
        begin
          newdirection := TDirection.haut;
          newx := Elem.X;
          newy := Elem.Y - 1;
        end;
      TDirection.bas:
        begin
          newdirection := TDirection.droite;
          newx := Elem.X + 1;
          newy := Elem.Y;
        end;
      TDirection.gauche:
        begin
          newdirection := TDirection.bas;
          newx := Elem.X;
          newy := Elem.Y + 1;
        end;
    end;

    // Dans la grille ?
    if (newx < 0) or (newy < 0) or (newx >= length(Map)) or
      (newy >= length(Map[0])) then
      exit;

    Queue.Push(TElem.Create(newx, newy, Elem.HeatLoss + Map[newx,
      newy].HeatLoss, newdirection, 1));
  end;
  procedure VaVersLaDroite(Elem: TElem; Queue: TPriorityQueue);
  var
    newx, newy: int64;
    newdirection: TDirection;
  begin
    case Elem.Direction of
      TDirection.haut:
        begin
          newdirection := TDirection.droite;
          newx := Elem.X + 1;
          newy := Elem.Y;
        end;
      TDirection.droite:
        begin
          newdirection := TDirection.bas;
          newx := Elem.X;
          newy := Elem.Y + 1;
        end;
      TDirection.bas:
        begin
          newdirection := TDirection.gauche;
          newx := Elem.X - 1;
          newy := Elem.Y;
        end;
      TDirection.gauche:
        begin
          newdirection := TDirection.haut;
          newx := Elem.X;
          newy := Elem.Y - 1;
        end;
    end;

    // Dans la grille ?
    if (newx < 0) or (newy < 0) or (newx >= length(Map)) or
      (newy >= length(Map[0])) then
      exit;

    Queue.Push(TElem.Create(newx, newy, Elem.HeatLoss + Map[newx,
      newy].HeatLoss, newdirection, 1));
  end;
  procedure VaDevant(Elem: TElem; Queue: TPriorityQueue);
  var
    newx, newy: int64;
  begin
    case Elem.Direction of
      TDirection.haut:
        begin
          newx := Elem.X;
          newy := Elem.Y - 1;
        end;
      TDirection.droite:
        begin
          newx := Elem.X + 1;
          newy := Elem.Y;
        end;
      TDirection.bas:
        begin
          newx := Elem.X;
          newy := Elem.Y + 1;
        end;
      TDirection.gauche:
        begin
          newx := Elem.X - 1;
          newy := Elem.Y;
        end;
    end;

    // Dans la grille ?
    if (newx < 0) or (newy < 0) or (newx >= length(Map)) or
      (newy >= length(Map[0])) then
      exit;

    Queue.Push(TElem.Create(newx, newy, Elem.HeatLoss + Map[newx,
      newy].HeatLoss, Elem.Direction, Elem.NbPasCourants + 1));
  end;

var
  Col, Lig: int64;
  Lignes: TArray<string>;
  Visited: TCellsVisited;
  Queue: TPriorityQueue;
  // X, Y, nbPas: int64;
  EndX, EndY: int64;
  Elem: TElem;
begin
{$IFDEF MyPriorityQueueBis}
  AddLog('With TMyPriorityQueueBis (instances chain)');
{$ELSE}
  AddLog('With TMyPriorityQueue (TObjectList)');
{$ENDIF}
  Lignes := tfile.ReadAllLines(CDataFile);

  // Dimensionne la grille
  setlength(Map, length(Lignes[0]));
  for Col := 0 to length(Lignes[0]) - 1 do
    setlength(Map[Col], length(Lignes));

  // Remplit la grille
  for Lig := 0 to length(Lignes) - 1 do
    for Col := 0 to length(Lignes[Lig]) - 1 do
    begin
      Map[Col][Lig].HeatLoss := strtoint(Lignes[Lig].chars[Col]);
      Map[Col][Lig].PathFindingDejaPasse := false;
    end;
  // DrawMap;

{$REGION 'version path finding non adaptée à cet exercice'}
  if false then
  begin
    // Parcours avec pathfinding qui ne peut pas fonctionner dans notre cas à
    // cause des contraintes de nb case maximum lors du déplacement
    Map[0][0].PathFindingDejaPasse := true;
    Result := TrouveLaFin(0, 0, 1, 0);
    DrawMap;
  end;
{$ENDREGION}
{$REGION 'solution inspirée de @NineBerry (sur Twitch) : https://dotnetfiddle.net/9DN6g5'}
  // implémentation de path finding selon l'algorithme de Dijkstra
  // https://fr.wikipedia.org/wiki/Algorithme_de_Dijkstra
  // en tenant compte du nombre de pas possibles dans une direction avant de
  // devoir en changer
  Result := -1;
  Visited := TCellsVisited.Create;
  try
    Queue := TPriorityQueue.Create;
    try
      // On empile les mouvements possibles depuis la case de départ
      Queue.Push(TElem.Create(0, 0, 0, TDirection.haut, 0));
      Queue.Push(TElem.Create(0, 0, 0, TDirection.droite, 0));
      Queue.Push(TElem.Create(0, 0, 0, TDirection.bas, 0));
      Queue.Push(TElem.Create(0, 0, 0, TDirection.gauche, 0));

      EndX := length(Map) - 1;
      EndY := length(Map[0]) - 1;

      while (Queue.Count > 0) do
      begin
        Elem := Queue.Pop;
        if not assigned(Elem) then
          raise exception.Create('Elem is nil. It should never happen');

        // if (Elem.X = EndX) and (Elem.Y = EndY) and (elem.NbPasCourants>=CNbPasMiniEx1) and (elem.NbPasCourants<=CNbPasMaxiEx1) then
        if (Elem.X = EndX) and (Elem.Y = EndY) then
        begin
          Result := Elem.HeatLoss;
          Elem.free;
          break;
        end;

        if Visited.hasVisitedElem(Elem.X, Elem.Y, Elem.Direction,
          Elem.NbPasCourants) then
        begin
          Elem.free;
          continue;
        end;

        // Visited.Add(Elem);
        Visited.Ajoute(Elem.X, Elem.Y, Elem.Direction, Elem.NbPasCourants);

        if (Elem.NbPasCourants >= CNbPasMiniEx1) then
        // on ne peut tourner qu'après X pas minimum
        begin
          VaVersLaGauche(Elem, Queue);
          VaVersLaDroite(Elem, Queue);
        end;

        if Elem.NbPasCourants < CNbPasMaxiEx1 then
          // on ne peut pas avancer plus de X pas dans la même direction
          VaDevant(Elem, Queue);

        Elem.free;
      end;
    finally
      Queue.free;
    end;
  finally
    Visited.free;
  end;

{$ENDREGION}
end;

function TForm1.Exercice2: int64;

  procedure VaVersLaGauche(Elem: TElem; Queue: TPriorityQueue);
  var
    newx, newy: int64;
    newdirection: TDirection;
  begin
    case Elem.Direction of
      TDirection.haut:
        begin
          newdirection := TDirection.gauche;
          newx := Elem.X - 1;
          newy := Elem.Y;
        end;
      TDirection.droite:
        begin
          newdirection := TDirection.haut;
          newx := Elem.X;
          newy := Elem.Y - 1;
        end;
      TDirection.bas:
        begin
          newdirection := TDirection.droite;
          newx := Elem.X + 1;
          newy := Elem.Y;
        end;
      TDirection.gauche:
        begin
          newdirection := TDirection.bas;
          newx := Elem.X;
          newy := Elem.Y + 1;
        end;
    end;

    // Dans la grille ?
    if (newx < 0) or (newy < 0) or (newx >= length(Map)) or
      (newy >= length(Map[0])) then
      exit;

    Queue.Push(TElem.Create(newx, newy, Elem.HeatLoss + Map[newx,
      newy].HeatLoss, newdirection, 1));
  end;
  procedure VaVersLaDroite(Elem: TElem; Queue: TPriorityQueue);
  var
    newx, newy: int64;
    newdirection: TDirection;
  begin
    case Elem.Direction of
      TDirection.haut:
        begin
          newdirection := TDirection.droite;
          newx := Elem.X + 1;
          newy := Elem.Y;
        end;
      TDirection.droite:
        begin
          newdirection := TDirection.bas;
          newx := Elem.X;
          newy := Elem.Y + 1;
        end;
      TDirection.bas:
        begin
          newdirection := TDirection.gauche;
          newx := Elem.X - 1;
          newy := Elem.Y;
        end;
      TDirection.gauche:
        begin
          newdirection := TDirection.haut;
          newx := Elem.X;
          newy := Elem.Y - 1;
        end;
    end;

    // Dans la grille ?
    if (newx < 0) or (newy < 0) or (newx >= length(Map)) or
      (newy >= length(Map[0])) then
      exit;

    Queue.Push(TElem.Create(newx, newy, Elem.HeatLoss + Map[newx,
      newy].HeatLoss, newdirection, 1));
  end;
  procedure VaDevant(Elem: TElem; Queue: TPriorityQueue);
  var
    newx, newy: int64;
  begin
    case Elem.Direction of
      TDirection.haut:
        begin
          newx := Elem.X;
          newy := Elem.Y - 1;
        end;
      TDirection.droite:
        begin
          newx := Elem.X + 1;
          newy := Elem.Y;
        end;
      TDirection.bas:
        begin
          newx := Elem.X;
          newy := Elem.Y + 1;
        end;
      TDirection.gauche:
        begin
          newx := Elem.X - 1;
          newy := Elem.Y;
        end;
    end;

    // Dans la grille ?
    if (newx < 0) or (newy < 0) or (newx >= length(Map)) or
      (newy >= length(Map[0])) then
      exit;

    Queue.Push(TElem.Create(newx, newy, Elem.HeatLoss + Map[newx,
      newy].HeatLoss, Elem.Direction, Elem.NbPasCourants + 1));
  end;

var
  Col, Lig: int64;
  Lignes: TArray<string>;
  Visited: TCellsVisited;
  Queue: TPriorityQueue;
  EndX, EndY: int64;
  Elem: TElem;
begin
{$IFDEF MyPriorityQueueBis}
  AddLog('With TMyPriorityQueueBis (instances chain)');
{$ELSE}
  AddLog('With TMyPriorityQueue (TObjectList)');
{$ENDIF}
  Lignes := tfile.ReadAllLines(CDataFile);

  // Dimensionne la grille
  setlength(Map, length(Lignes[0]));
  for Col := 0 to length(Lignes[0]) - 1 do
    setlength(Map[Col], length(Lignes));

  // Remplit la grille
  for Lig := 0 to length(Lignes) - 1 do
    for Col := 0 to length(Lignes[Lig]) - 1 do
    begin
      Map[Col][Lig].HeatLoss := strtoint(Lignes[Lig].chars[Col]);
      Map[Col][Lig].PathFindingDejaPasse := false;
    end;
  // DrawMap;

{$REGION 'solution inspirée de @NineBerry (sur Twitch) : https://dotnetfiddle.net/9DN6g5'}
  // implémentation de path finding selon l'algorithme de Dijkstra
  // https://fr.wikipedia.org/wiki/Algorithme_de_Dijkstra
  // en tenant compte du nombre de pas possibles dans une direction avant de
  // devoir en changer
  Result := -1;
  Visited := TCellsVisited.Create;
  try
    Queue := TPriorityQueue.Create;
    try
      // On empile les mouvements possibles depuis la case de départ
      Queue.Push(TElem.Create(0, 0, 0, TDirection.haut, 0));
      Queue.Push(TElem.Create(0, 0, 0, TDirection.droite, 0));
      Queue.Push(TElem.Create(0, 0, 0, TDirection.bas, 0));
      Queue.Push(TElem.Create(0, 0, 0, TDirection.gauche, 0));

      EndX := length(Map) - 1;
      EndY := length(Map[0]) - 1;

      while (Queue.Count > 0) do
      begin
        Elem := Queue.Pop;
        if not assigned(Elem) then
          raise exception.Create('Elem is nil. It should never happen');

        if (Elem.X = EndX) and (Elem.Y = EndY) and
          (Elem.NbPasCourants >= CNbPasMiniEx2) and
          (Elem.NbPasCourants <= CNbPasMaxiEx2) then
        begin
          Result := Elem.HeatLoss;
          Elem.free;
          break;
        end;

        if Visited.hasVisitedElem(Elem.X, Elem.Y, Elem.Direction,
          Elem.NbPasCourants) then
        begin
          Elem.free;
          continue;
        end;

        // Visited.Add(Elem);
        Visited.Ajoute(Elem.X, Elem.Y, Elem.Direction, Elem.NbPasCourants);

        if (Elem.NbPasCourants >= CNbPasMiniEx2) then
        // on ne peut tourner qu'après X pas minimum
        begin
          VaVersLaGauche(Elem, Queue);
          VaVersLaDroite(Elem, Queue);
        end;

        if Elem.NbPasCourants < CNbPasMaxiEx2 then
          // on ne peut pas avancer plus de X pas dans la même direction
          VaDevant(Elem, Queue);

        Elem.free;
      end;
    finally
      Queue.free;
    end;
  finally
    Visited.free;
  end;

{$ENDREGION}
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
  Result := TimeToStr(dt) + ',' + S;
end;

procedure TForm1.PathFindingSurMap(EndX, EndY: int64);
var
  Col, Lig: int64;
  Modif: boolean;
  a, b, c, d, z: int64;
begin
  // algorithme utilisé : Dijkstra
  // https://fr.wikipedia.org/wiki/Algorithme_de_Dijkstra
  //
  // inspiré de l'exercice 1 du jour 15 de l'AoC 2021

  for Col := 0 to length(Map) - 1 do
    for Lig := 0 to length(Map[Col]) - 1 do
      Map[Col][Lig].PathFindingPoidsCellule := CPoidsMax;

  Map[EndX][EndY].PathFindingPoidsCellule := Map[EndX][EndY].HeatLoss;

  Modif := true;
  while (Modif) do
  begin
    if tthread.checkterminated then
      abort;

    Modif := false;

    for Col := 0 to length(Map) - 1 do
      for Lig := 0 to length(Map[Col]) - 1 do
      begin
        a := CPoidsMax;
        if Lig < length(Map[Col]) - 1 then
          a := Map[Col, Lig + 1].PathFindingPoidsCellule +
            Map[Col, Lig].HeatLoss;
        b := CPoidsMax;
        if Col < length(Map) - 1 then
          b := Map[Col + 1, Lig].PathFindingPoidsCellule +
            Map[Col, Lig].HeatLoss;
        c := CPoidsMax;
        if Lig > 0 then
          c := Map[Col, Lig - 1].PathFindingPoidsCellule +
            Map[Col, Lig].HeatLoss;
        d := CPoidsMax;
        if Col > 0 then
          d := Map[Col - 1, Lig].PathFindingPoidsCellule +
            Map[Col, Lig].HeatLoss;
        z := CPoidsMax;
        if a < z then
          z := a;
        if b < z then
          z := b;
        if c < z then
          z := c;
        if d < z then
          z := d;
        if not((Lig = EndX) and (Col = EndY)) then
        begin
          // On ne touche pas à la case d'arrivée
          Modif := Modif or (Map[Col, Lig].PathFindingPoidsCellule <> z);
          Map[Col, Lig].PathFindingPoidsCellule := z;
        end;
      end;
    // drawmap;
  end;
end;

function TForm1.TrouveLaFin(X, Y: int64; VX, VY: int64): int64;
var
  NbCases: int64;
  EndX, EndY: int64;
  PoidsDevant, PoidsCote1, PoidsCote2: int64;
  NbCol, NbLig: int64;
  VSwap: int64;
begin
  Result := 0;

  NbCol := length(Map);
  NbLig := length(Map[0]);
  // AddLog('Taille : ' + NbCol.tostring + '*' + NbLig.tostring);

  if (X < 0) or (Y < 0) or (X >= NbCol) or (Y >= NbLig) then
    exit;

  EndX := length(Map) - 1;
  EndY := length(Map[0]) - 1;
  // AddLog('Arrivee : ' + EndX.tostring + ',' + EndY.tostring);

  PathFindingSurMap(EndX, EndY);

  NbCases := 0;
  while not((X = EndX) and (Y = EndY)) do
  begin
    if tthread.checkterminated then
      abort;

    if (NbCases < 3) and (X + VX >= 0) and (X + VX < NbCol) and (Y + VY >= 0)
      and (Y + VY < NbLig) and (not Map[X + VX][Y + VY].PathFindingDejaPasse)
    then
      PoidsDevant := Map[X + VX][Y + VY].PathFindingPoidsCellule
    else
      PoidsDevant := CPoidsMax;

    if (X + VY >= 0) and (X + VY < NbCol) and (Y + VX >= 0) and (Y + VX < NbLig)
      and (not Map[X + VY][Y + VX].PathFindingDejaPasse) then
      PoidsCote1 := Map[X + VY][Y + VX].PathFindingPoidsCellule
    else
      PoidsCote1 := CPoidsMax;

    if (X - VY >= 0) and (X - VY < NbCol) and (Y - VX >= 0) and (Y - VX < NbLig)
      and (not Map[X - VY][Y - VX].PathFindingDejaPasse) then
      PoidsCote2 := Map[X - VY][Y - VX].PathFindingPoidsCellule
    else
      PoidsCote2 := CPoidsMax;

    if (PoidsDevant < PoidsCote1) and (PoidsDevant < PoidsCote2) then
      inc(NbCases)
    else if (PoidsCote1 < PoidsDevant) and (PoidsCote1 < PoidsCote2) then
    begin
      VSwap := VX;
      VX := VY;
      VY := VSwap;
      NbCases := 1;
    end
    else if (PoidsCote2 < PoidsDevant) and (PoidsCote2 < PoidsCote1) then
    begin
      VSwap := VX;
      VX := -VY;
      VY := -VSwap;
      NbCases := 1;
    end
    else
      AddLog('plusieurs poids identiques, direction douteuse, penser récursivité');

    X := X + VX;
    Y := Y + VY;
    Result := Result + Map[X][Y].HeatLoss;
    Map[X][Y].PathFindingDejaPasse := true;
    // AddLog(X.tostring + ',' + Y.tostring);
  end;
end;

{ TElem }

constructor TElem.Create(AX, AY: int64; AHeatLoss: int64;
ADirection: TDirection; ANbPasCourants: int64);
begin
  inherited Create;
  X := AX;
  Y := AY;
  HeatLoss := AHeatLoss;
  Direction := ADirection;
  NbPasCourants := ANbPasCourants;
end;

{ TCellsVisited }

procedure TCellsVisited.Ajoute(AX, AY: int64; ADirection: TDirection;
ANbPasCourant: int64);
begin
  Add(GetKey(AX, AY, ADirection, ANbPasCourant), true);
end;

function TCellsVisited.GetKey(AX, AY: int64; ADirection: TDirection;
ANbPasCourant: int64): int64;
begin
  Result := AX + AY * length(Form1.Map) + (ord(ADirection) + 1) *
    length(Form1.Map) * length(Form1.Map[0]) + ANbPasCourant * length(Form1.Map)
    * length(Form1.Map[0]) * 4;
end;

function TCellsVisited.hasVisitedElem(AX, AY: int64; ADirection: TDirection;
ANbPasCourant: int64): boolean;
begin
  // Result := false;
  // for var Elem in self do
  // if (Elem.X = AX) and (Elem.Y = AY) and (Elem.Direction = ADirection) and
  // (Elem.NbPasCourants = ANbPasCourant) then
  // begin
  // Result := true;
  // break;
  // end;
  Result := containskey(GetKey(AX, AY, ADirection, ANbPasCourant));
end;

{ TMyPriorityQueue }

function TMyPriorityQueue.Pop: TElem;
begin
  Result := self.Extractat(0);
end;

procedure TMyPriorityQueue.Push(Elem: TElem);
var
  idx: integer;
  Added: boolean;
begin
  // Add(Elem);
  // sort(TComparer<TElem>.construct(
  // function(const a, b: TElem): integer
  // begin
  // if a.HeatLoss < b.HeatLoss then
  // Result := -1
  // else if a.HeatLoss > b.HeatLoss then
  // Result := 1
  // else
  // Result := 0;
  // end));

  Added := false;
  for idx := 0 to Count - 1 do
    if (self[idx].HeatLoss > Elem.HeatLoss) then
    begin
      insert(idx, Elem);
      Added := true;
      break;
    end;

  if not Added then
    Add(Elem);
end;

{ TMyPriorityQueueBis }

constructor TMyPriorityQueueBis.Create;
begin
  inherited Create;
  First := nil;
  Last := nil;
  FCount := 0;
end;

destructor TMyPriorityQueueBis.Destroy;
begin
  while (FCount > 0) do
    Pop.free;
  inherited;
end;

function TMyPriorityQueueBis.Pop: TElem;
var
  FirstItem: TItem;
begin
  if assigned(First) then
  begin
    FCount := FCount - 1;
    FirstItem := First;
    if Last = First then
    begin
      assert(FCount = 0, 'Items lost in the TMyPriorityQueueBis : ' +
        FCount.tostring);
      First := nil;
      Last := nil;
      FCount := 0;
    end
    else
    begin
      First := FirstItem.Next;
      First.Prior := nil;
    end;
    Result := FirstItem.Value;
    FirstItem.free;
  end
  else
    Result := nil;
end;

procedure TMyPriorityQueueBis.Push(Elem: TElem);
var
  NewItem: TItem;
  Item: TItem;
begin
  if not assigned(Elem) then
    exit;

  FCount := FCount + 1;

  NewItem := TItem.Create;
  NewItem.Value := Elem;

  Item := First;
  // while assigned(Item) and (Item.Value.HeatLoss <= NewItem.Value.HeatLoss) do
  while assigned(Item) and (Item.Value.HeatLoss < NewItem.Value.HeatLoss) do
    Item := Item.Next;

  if assigned(Item) then
  begin
    if (Item = First) then
      First := NewItem;
    NewItem.Prior := Item.Prior;
    if assigned(NewItem.Prior) then
      NewItem.Prior.Next := NewItem;
    Item.Prior := NewItem;
    NewItem.Next := Item;
    // Form1.AddLog('ajout newitem ' + NewItem.Tag.tostring + ' devant item ' +
    // Item.Tag.tostring + ' / ' + FCount.tostring + ' / ' +
    // NewItem.Value.HeatLoss.tostring + '/' + Item.Value.HeatLoss.tostring);
  end
  else
  begin
    if not assigned(First) then
      First := NewItem;
    if assigned(Last) then
    begin
      Last.Next := NewItem;
      NewItem.Prior := Last;
    end;
    Last := NewItem;
    // Form1.AddLog('ajout newitem ' + NewItem.Tag.tostring + ' en dernier / ' +
    // FCount.tostring + ' / ' + NewItem.Value.HeatLoss.tostring);
  end;
end;

{ TMyPriorityQueueBis.TItem }

constructor TMyPriorityQueueBis.TItem.Create;
begin
  inherited Create;
  Prior := nil;
  Next := nil;
  Value := nil;
end;

initialization

{$IFDEF DEBUG}
  ReportMemoryLeaksOnShutdown := true;
{$ENDIF}

end.
