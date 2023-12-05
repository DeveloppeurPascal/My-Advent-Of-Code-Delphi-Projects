unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.WinXCtrls, Vcl.StdCtrls;

Const
  CDataFile = '..\..\input.txt';
  // CDataFile = '..\..\input-test.txt';

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
    FStep: byte;
    procedure BeginTraitement;
    procedure EndTraitement;
    { Déclarations privées }
    function Exercice1: uint64;
    function Exercice2: uint64;
    procedure AddLog(Const S: String);
    function MsToTimeString(ms: int64): string;
    procedure SetStep(const Value: byte);
  public
    { Déclarations publiques }
    property Step: byte read FStep write SetStep;
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

uses
  System.Math,
  System.DateUtils,
  System.RegularExpressions,
  System.Generics.Collections,
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

type
  TMap = class
    Source, Destination, Interval: uint64;
    constructor Create(Const S: String);
  end;

  TDestination = class
    Start, Interval: uint64;
    constructor Create(AStart, AInterval: uint64);
  end;

  TDestinationsList = TObjectList<TDestination>;

  TMapsList = class(TObjectList<TMap>)
    function GetDestination(Source: uint64): uint64;
    function GetDestinationsList(Const SourcesList: TDestinationsList;
    FreeSourcesList: boolean = true): TDestinationsList;
  end;

function TForm1.Exercice1: uint64;
var
  Lig: integer;
  Lignes: TArray<string>;
  Seeds: TList<uint64>;
  SeedToSoil, SoilToFertilizer, FertilizerToWater, WaterToLight,
    LightToTemperature, TemperatureToHumidity, HumidityToLocation: TMapsList;
  tab: TArray<string>;
  Location: uint64;
begin
  Seeds := TList<uint64>.Create;
  try
    SeedToSoil := TMapsList.Create;
    try
      SoilToFertilizer := TMapsList.Create;
      try
        FertilizerToWater := TMapsList.Create;
        try
          WaterToLight := TMapsList.Create;
          try
            LightToTemperature := TMapsList.Create;
            try
              TemperatureToHumidity := TMapsList.Create;
              try
                HumidityToLocation := TMapsList.Create;
                try
                  Lignes := tfile.ReadAllLines(CDataFile);
                  Step := 0;
                  for Lig := 0 to length(Lignes) - 1 do
                    if Lignes[Lig].IsEmpty then
                      Step := 0
                    else
                      case Step of
                        0:
                          if Lignes[Lig].StartsWith('seeds') then
                          begin
                            tab := Lignes[Lig].Substring
                              (Lignes[Lig].indexof(':') + 1).Split([' ']);
                            for var i := 0 to length(tab) - 1 do
                              // addlog(tab[i]);
                              if not tab[i].IsEmpty then
                                Seeds.Add(tab[i].ToInt64);
                          end
                          else if Lignes[Lig].StartsWith('seed-to-soil') then
                            Step := 1
                          else if Lignes[Lig].StartsWith('soil-to-fertilizer')
                          then
                            Step := 2
                          else if Lignes[Lig].StartsWith('fertilizer-to-water')
                          then
                            Step := 3
                          else if Lignes[Lig].StartsWith('water-to-light') then
                            Step := 4
                          else if Lignes[Lig].StartsWith('light-to-temperature')
                          then
                            Step := 5
                          else if Lignes[Lig].StartsWith
                            ('temperature-to-humidity') then
                            Step := 6
                          else if Lignes[Lig].StartsWith('humidity-to-location')
                          then
                            Step := 7
                          else
                            raise exception.Create('Error line ' + (Lig + 1)
                              .tostring + ' : "' + Lignes[Lig] + '"');
                        1:
                          SeedToSoil.Add(TMap.Create(Lignes[Lig]));
                        2:
                          SoilToFertilizer.Add(TMap.Create(Lignes[Lig]));
                        3:
                          FertilizerToWater.Add(TMap.Create(Lignes[Lig]));
                        4:
                          WaterToLight.Add(TMap.Create(Lignes[Lig]));
                        5:
                          LightToTemperature.Add(TMap.Create(Lignes[Lig]));
                        6:
                          TemperatureToHumidity.Add(TMap.Create(Lignes[Lig]));
                        7:
                          HumidityToLocation.Add(TMap.Create(Lignes[Lig]));
                      end;

                  result := high(uint64);
                  for var seed in Seeds do
                  begin
                    Location := HumidityToLocation.GetDestination
                      (TemperatureToHumidity.GetDestination
                      (LightToTemperature.GetDestination
                      (WaterToLight.GetDestination
                      (FertilizerToWater.GetDestination
                      (SoilToFertilizer.GetDestination(SeedToSoil.GetDestination
                      (seed)))))));
                    if (Location < result) then
                      result := Location;
                  end;
                finally
                  HumidityToLocation.Free;
                end;
              finally
                TemperatureToHumidity.Free;
              end;
            finally
              LightToTemperature.Free;
            end;
          finally
            WaterToLight.Free;
          end;
        finally
          FertilizerToWater.Free;
        end;
      finally
        SoilToFertilizer.Free;
      end;
    finally
      SeedToSoil.Free;
    end;
  finally
    Seeds.Free;
  end;
end;

function TForm1.Exercice2: uint64;
var
  Lig: integer;
  Lignes: TArray<string>;
  Seeds: TList<uint64>;
  SeedToSoil, SoilToFertilizer, FertilizerToWater, WaterToLight,
    LightToTemperature, TemperatureToHumidity, HumidityToLocation: TMapsList;
  tab: TArray<string>;
  Location: uint64;
  DestList: TDestinationsList;
  i: uint64;
begin
  Seeds := TList<uint64>.Create;
  try
    SeedToSoil := TMapsList.Create;
    try
      SoilToFertilizer := TMapsList.Create;
      try
        FertilizerToWater := TMapsList.Create;
        try
          WaterToLight := TMapsList.Create;
          try
            LightToTemperature := TMapsList.Create;
            try
              TemperatureToHumidity := TMapsList.Create;
              try
                HumidityToLocation := TMapsList.Create;
                try
                  Lignes := tfile.ReadAllLines(CDataFile);
                  Step := 0;
                  for Lig := 0 to length(Lignes) - 1 do
                    if Lignes[Lig].IsEmpty then
                      Step := 0
                    else
                      case Step of
                        0:
                          if Lignes[Lig].StartsWith('seeds') then
                          begin
                            tab := Lignes[Lig].Substring
                              (Lignes[Lig].indexof(':') + 1).Split([' ']);
                            for i := 0 to length(tab) - 1 do
                              // addlog(tab[i]);
                              if not tab[i].IsEmpty then
                                Seeds.Add(tab[i].ToInt64);
                          end
                          else if Lignes[Lig].StartsWith('seed-to-soil') then
                            Step := 1
                          else if Lignes[Lig].StartsWith('soil-to-fertilizer')
                          then
                            Step := 2
                          else if Lignes[Lig].StartsWith('fertilizer-to-water')
                          then
                            Step := 3
                          else if Lignes[Lig].StartsWith('water-to-light') then
                            Step := 4
                          else if Lignes[Lig].StartsWith('light-to-temperature')
                          then
                            Step := 5
                          else if Lignes[Lig].StartsWith
                            ('temperature-to-humidity') then
                            Step := 6
                          else if Lignes[Lig].StartsWith('humidity-to-location')
                          then
                            Step := 7
                          else
                            raise exception.Create('Error line ' + (Lig + 1)
                              .tostring + ' : "' + Lignes[Lig] + '"');
                        1:
                          SeedToSoil.Add(TMap.Create(Lignes[Lig]));
                        2:
                          SoilToFertilizer.Add(TMap.Create(Lignes[Lig]));
                        3:
                          FertilizerToWater.Add(TMap.Create(Lignes[Lig]));
                        4:
                          WaterToLight.Add(TMap.Create(Lignes[Lig]));
                        5:
                          LightToTemperature.Add(TMap.Create(Lignes[Lig]));
                        6:
                          TemperatureToHumidity.Add(TMap.Create(Lignes[Lig]));
                        7:
                          HumidityToLocation.Add(TMap.Create(Lignes[Lig]));
                      end;

                  DestList := TDestinationsList.Create;
                  try
                    i := 0;
                    while (i < Seeds.count) do
                    begin
                      DestList.Add(TDestination.Create(Seeds[i], Seeds[i + 1]));
                      i := i + 2;
                    end;

                    DestList := HumidityToLocation.GetDestinationsList
                      (TemperatureToHumidity.GetDestinationsList
                      (LightToTemperature.GetDestinationsList
                      (WaterToLight.GetDestinationsList
                      (FertilizerToWater.GetDestinationsList
                      (SoilToFertilizer.GetDestinationsList
                      (SeedToSoil.GetDestinationsList(DestList)))))));

                    result := high(uint64);
                    for i := 0 to DestList.count - 1 do
                      if (DestList[i].Start < result) then
                        result := DestList[i].Start;

                  finally
                    DestList.Free;
                  end;

{$REGION 'calcul trop long et couteux en mémoire' }
                  // Version qui peut durer très/trop longtemps
                  // var i := 0;
                  // while (i < Seeds.count) do
                  // begin
                  // for var j := 0 to Seeds[i + 1] - 1 do
                  // begin
                  // Location := HumidityToLocation.GetDestination
                  // (TemperatureToHumidity.GetDestination
                  // (LightToTemperature.GetDestination
                  // (WaterToLight.GetDestination
                  // (FertilizerToWater.GetDestination
                  // (SoilToFertilizer.GetDestination
                  // (SeedToSoil.GetDestination(Seeds[i] + j)))))));
                  // if (Location < result) then
                  // result := Location;
                  // end;
                  // i := i + 2;
                  // end;
{$ENDREGION}
                finally
                  HumidityToLocation.Free;
                end;
              finally
                TemperatureToHumidity.Free;
              end;
            finally
              LightToTemperature.Free;
            end;
          finally
            WaterToLight.Free;
          end;
        finally
          FertilizerToWater.Free;
        end;
      finally
        SoilToFertilizer.Free;
      end;
    finally
      SeedToSoil.Free;
    end;
  finally
    Seeds.Free;
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

procedure TForm1.SetStep(const Value: byte);
begin
  FStep := Value;
  // AddLog('Step: ' + FStep.tostring);
end;

{ TMap }

constructor TMap.Create(Const S: String);
var
  tab: TArray<string>;
begin
  inherited Create;
  if S.Trim.IsEmpty then
    abort;
  tab := S.Split([' ']);
  if (length(tab) <> 3) then
  begin
    Form1.AddLog('Error : "' + S + '"');
    abort;
  end;
  Destination := tab[0].ToInt64;
  Source := tab[1].ToInt64;
  Interval := tab[2].ToInt64;
end;

{ TMapsList }

function TMapsList.GetDestination(Source: uint64): uint64;
begin
  for var map in self do
    if (map.Source <= Source) and (Source < map.Source + map.Interval) then
    begin
      result := map.Destination + Source - map.Source;
      exit;
    end;
  result := Source;
end;

function TMapsList.GetDestinationsList(Const SourcesList: TDestinationsList;
FreeSourcesList: boolean): TDestinationsList;
var
  i: integer;
  Found: boolean;
  Ecart: uint64;
begin
  result := TDestinationsList.Create;
  try
    Form1.AddLog('Nb Dest:' + SourcesList.count.tostring);
    i := 0;
    while (i < SourcesList.count) do
    begin
      Found := false;
      for var map in self do
        if (map.Source <= SourcesList[i].Start) and
          (SourcesList[i].Start < map.Source + map.Interval) then
        begin
          if (map.Source + map.Interval >= SourcesList[i].Start + SourcesList[i]
            .Interval) then
            result.Add(TDestination.Create(map.Destination + SourcesList[i]
              .Start - map.Source, SourcesList[i].Interval))
          else
          begin
            Ecart := map.Source + map.Interval - SourcesList[i].Start;
            result.Add(TDestination.Create(map.Destination + SourcesList[i]
              .Start - map.Source, Ecart));
            SourcesList.Add(TDestination.Create(SourcesList[i].Start + Ecart,
              SourcesList[i].Interval - Ecart));
          end;
          Found := true;
          break;
        end;
      if not Found then
        result.Add(TDestination.Create(SourcesList[i].Start,
          SourcesList[i].Interval));
      inc(i);
    end;
  finally
    if FreeSourcesList then
      SourcesList.Free;
  end;
end;

{ TDestination }

constructor TDestination.Create(AStart, AInterval: uint64);
begin
  inherited Create;
  Start := AStart;
  Interval := AInterval;
  Form1.AddLog('Add : ' + Start.tostring + ' ' + Interval.tostring);
end;

initialization

ReportMemoryLeaksOnShutdown := true;

end.
