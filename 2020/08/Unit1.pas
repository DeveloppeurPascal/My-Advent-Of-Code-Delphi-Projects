unit Unit1;

// My solution for https://adventofcode.com/2020/day/8
interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls;

type
  TForm1 = class(TForm)
    Memo1: TMemo;
    Panel1: TPanel;
    Button1: TButton;
    Button2: TButton;
    Edit1: TEdit;
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    { Déclarations privées }
  public
    { Déclarations publiques }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

uses
  System.RegularExpressions, System.Math;

procedure TForm1.Button1Click(Sender: TObject);
var
  accumulator: integer;
  num_lig: integer;
  cmd: TMatchCollection;
begin
  accumulator := 0;
  num_lig := 0;
  while (num_lig < Memo1.Lines.Count) and (Memo1.Lines[num_lig] <> '-') do
  begin
    cmd := tregex.matches(Memo1.Lines[num_lig], '^(.+)\s([\+\-]{1})(\d+)$');
    Memo1.Lines[num_lig] := '-';
    if (cmd.Count = 1) and (cmd[0].Groups.Count = 4) then
      if cmd[0].Groups[1].Value = 'jmp' then
        num_lig := num_lig + ifthen(cmd[0].Groups[2].Value = '+', 1, -1) *
          cmd[0].Groups[3].Value.ToInteger
      else
      begin
        if cmd[0].Groups[1].Value = 'acc' then
          accumulator := accumulator + ifthen(cmd[0].Groups[2].Value = '+', 1,
            -1) * cmd[0].Groups[3].Value.ToInteger;
        inc(num_lig);
      end;
  end;
  Edit1.Text := accumulator.ToString;
end;

procedure TForm1.Button2Click(Sender: TObject);

  function CalculeAccumulator(var OAccumulator: integer; num_lig: integer = 0;
    listelignes: string = ''; IAccumulator: integer = 0;
    changed: boolean = false): boolean;
  var
    cmd: TMatchCollection;
  begin
    while (num_lig < Memo1.Lines.Count) and
      (not listelignes.Contains('/' + num_lig.ToString + '/')) do
    begin
      cmd := tregex.matches(Memo1.Lines[num_lig], '^(.+)\s([\+\-]{1})(\d+)$');
      listelignes := listelignes + '/' + num_lig.ToString + '/';
      if (cmd.Count = 1) and (cmd[0].Groups.Count = 4) then
        if (cmd[0].Groups[1].Value = 'jmp') then
        begin
          if CalculeAccumulator(OAccumulator,
            num_lig + ifthen(cmd[0].Groups[2].Value = '+', 1, -1) *
            cmd[0].Groups[3].Value.ToInteger, listelignes, IAccumulator, changed)
          then
          begin
            result := true;
            exit;
          end
          else if not changed then
          begin
            inc(num_lig);
            changed := true;
          end;
        end
        else if (cmd[0].Groups[1].Value = 'nop') then
        begin
          if (not changed) and CalculeAccumulator(OAccumulator,
            num_lig + ifthen(cmd[0].Groups[2].Value = '+', 1, -1) *
            cmd[0].Groups[3].Value.ToInteger, listelignes, IAccumulator, true)
          then
            exit
          else
            inc(num_lig);
        end
        else
        begin
          if cmd[0].Groups[1].Value = 'acc' then
            IAccumulator := IAccumulator + ifthen(cmd[0].Groups[2].Value = '+',
              1, -1) * cmd[0].Groups[3].Value.ToInteger;
          inc(num_lig);
        end;
    end;
    result := (num_lig = Memo1.Lines.Count);
    OAccumulator := IAccumulator
  end;

var
  accumulator: integer;
begin
  accumulator := 0;
  CalculeAccumulator(accumulator);
  Edit1.Text := accumulator.ToString;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  Memo1.Lines.Clear;
  Edit1.Text := '';
end;

end.
