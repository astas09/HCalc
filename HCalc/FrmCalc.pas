unit FrmCalc;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Layouts, FMX.Edit,
  uInterfaces, uCalculator;

type
  TFormCalc = class(TForm, ICalculatorDisplay)
    pnText: TPanel;
    pnHistory: TPanel;
    pnButtons: TPanel;
    pnButtonsGrid: TGridPanelLayout;
    btn00: TButton;
    btn01: TButton;
    btn02: TButton;
    btn03: TButton;
    btn04: TButton;
    btn05: TButton;
    btn06: TButton;
    btn07: TButton;
    btn08: TButton;
    btn09: TButton;
    btnPlus: TButton;
    btnMinus: TButton;
    btnMult: TButton;
    btnDiv: TButton;
    btnPoint: TButton;
    btnEqual: TButton;
    btnMem: TButton;
    btnMPlus: TButton;
    btnMMinus: TButton;
    btnClear: TButton;
    txtMonitor: TLabel;
    lblHistory: TLabel;
    lblMemory: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
    procedure FormShow(Sender: TObject);
    procedure btnEqualClick(Sender: TObject);
    procedure btnPointClick(Sender: TObject);
    procedure DigitClick(Sender: TObject);
    procedure OperClick(Sender: TObject);
    procedure btnClearClick(Sender: TObject);
    procedure btnMemClick(Sender: TObject);
  private
    { Private declarations }
    FCalculator: ICalculator;
  public
    { Public declarations }
    procedure UpdateUI(strText: string; strHistory: string; dMemory: double);
  end;

var
  FormCalc: TFormCalc;

implementation

{$R *.fmx}

// uses uCalculator;

procedure TFormCalc.FormCreate(Sender: TObject);
begin
  FCalculator := TCalculator.Create(self);
end;

procedure TFormCalc.FormKeyDown(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
begin
  // if Key = VK_ESCAPE then begin
  // FCalculator.CancelAll; Key := 0; end
  // else if Key = VK_RETURN then begin
  // FCalculator.Equals; Key := 0;
  // end;
  // ActiveControl := txtHistory; txtHistory.SelStart := length(txtHistory.Text); txtHistory.SelLength := 0;
end;

procedure TFormCalc.FormShow(Sender: TObject);
begin
  // ActiveControl := txtHistory; txtHistory.SelStart := length(txtHistory.Text); txtHistory.SelLength := 0;
end;

procedure TFormCalc.btnClearClick(Sender: TObject);
begin
  FCalculator.CancelAll();
  // ActiveControl := txtHistory; txtHistory.SelStart := length(txtHistory.Text); txtHistory.SelLength := 0;
end;

procedure TFormCalc.DigitClick(Sender: TObject);
var
  CntrName: string;
  intDigit: integer;
begin
  try
    CntrName := (Sender as TControl).Name;
  except
    CntrName := '';
  end;
  if copy(CntrName, 1, 3) = 'btn' then
  begin
    intDigit := StrToIntDef(copy(CntrName, 4, 2), -1);
    if (intDigit >= 0) and (intDigit <= 9) then
      FCalculator.AddDigit(intDigit);
  end;
  // ActiveControl := txtHistory; txtHistory.SelStart := length(txtHistory.Text); txtHistory.SelLength := 0;
end;

procedure TFormCalc.btnEqualClick(Sender: TObject);
begin
  FCalculator.Equals;
  // ActiveControl := txtHistory; txtHistory.SelStart := length(txtHistory.Text); txtHistory.SelLength := 0;
end;

procedure TFormCalc.btnMemClick(Sender: TObject);
var
  CntrName: string;
begin
  try
    CntrName := (Sender as TControl).Name;
  except
    CntrName := '';
  end;
  if CntrName = 'btnMem' then
    FCalculator.calcMemory(0)
  else if CntrName = 'btnMPlus' then
    FCalculator.calcMemory(1)
  else if CntrName = 'btnMMinus' then
    FCalculator.calcMemory(-1);
end;

procedure TFormCalc.OperClick(Sender: TObject);
var
  CntrName: string;
  opOperator: TOperatorEnum;
begin
  try
    CntrName := (Sender as TControl).Name;
  except
    CntrName := '';
  end;
  // btnPlus; btnMinus; btnMult; btnDiv;
  opOperator := opNull;
  if CntrName = 'btnPlus' then
    opOperator := opAdd
  else if CntrName = 'btnMinus' then
    opOperator := opSubtract
  else if CntrName = 'btnMult' then
    opOperator := opMultiply
  else if CntrName = 'btnDiv' then
    opOperator := opDivide;

  FCalculator.SetOperator(opOperator);
  // ActiveControl := txtHistory; txtHistory.SelStart := length(txtHistory.Text); txtHistory.SelLength := 0;
end;

procedure TFormCalc.btnPointClick(Sender: TObject);
begin
  FCalculator.AddDecimalSeparator;
  // ActiveControl := txtHistory; txtHistory.SelStart := length(txtHistory.Text); txtHistory.SelLength := 0;
end;

procedure TFormCalc.UpdateUI(strText: string; strHistory: string; dMemory: double);
var iFontSize: integer;
begin
  iFontSize := 72;
  if length(strText) > 8 then iFontSize := 36;
  if txtMonitor.Font.Size <> iFontSize then
  txtMonitor.Font.Size := iFontSize;
  txtMonitor.Text := strText;

  iFontSize := 16;
  if length(strHistory) > 80 then iFontSize := 10;
  if lblHistory.Font.Size <> iFontSize then
  lblHistory.Font.Size := iFontSize;
  lblHistory.Text := strHistory;

  if trunc(abs(dMemory)) = 0 then
    lblMemory.Text := ''
  else
    lblMemory.Text := 'M: ' + FloatToStr(dMemory);
  // ActiveControl := txtHistory; txtHistory.SelStart := length(txtHistory.Text); txtHistory.SelLength := 0;
end;

end.
