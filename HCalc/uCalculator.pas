unit uCalculator;

interface

uses
  System.SysUtils, uInterfaces, uCalcHistory;

type
  TCalculator = class(TInterfacedObject, ICalculator)
  private
    FDisplay: ICalculatorDisplay;
    FHistory: TCalcHistory;
    FOperand: array [1 .. 2] of string;
    FOperandClosed: boolean;
    FSign: array [1 .. 2] of integer;
    FSeparator: array [1 .. 2] of boolean;
    FOperator: TOperatorEnum;
    FOperNum: integer;
    FDecSep: WideChar;
    FMemory: double;
    function OpToString(op: TOperatorEnum): string;
    function OperandIsEmpty(strOperand: string): boolean;
  public
    constructor Create(ADisplay: ICalculatorDisplay);
    destructor Destroy; override;
    // ICalculator
    procedure AddDigit(digit: integer);
    procedure AddDecimalSeparator;
    procedure SetOperator(op: TOperatorEnum);
    procedure Equals;
    procedure CancelAll;
    procedure CalcMemory(mdirection: integer);
  end;

implementation

constructor TCalculator.Create(ADisplay: ICalculatorDisplay);
begin
  FDisplay := ADisplay;
  FOperator := opNull;
  FOperandClosed := false;
  FOperNum := 1;
  FOperand[1] := '0';
  FSign[1] := 1;
  FOperand[2] := '0';
  FSign[2] := 1;
  FSeparator[1] := false;
  FSeparator[2] := false;
  FHistory := TCalcHistory.Create;
  FMemory := 0;
  // HideCaret
  With System.SysUtils.TFormatSettings.Create do
    FDecSep := DecimalSeparator;
end;

destructor TCalculator.Destroy;
begin

end;

procedure TCalculator.SetOperator(op: TOperatorEnum);
var intHistoryOperand: integer;
begin
  intHistoryOperand := FOperNum;
  if (FOperNum = 1) then
  begin
    // if this is first operand and it is zero
    if StrToFloatDef(FOperand[FOperNum], 0) = 0 then
    begin
      // then we change sign of operand
      if op = opSubtract then
        FSign[FOperNum] := -FSign[FOperNum]
    end
    else
    begin
      // if this is first operand and it is not zero
      if FSign[FOperNum] < 0 then
        FHistory.UpdateHistory('-');

      // FHistory.UpdateHistory(FOperand[FOperNum], huptReplaceLast);
      FHistory.UpdateHistory(OpToString(op), huptAddNew);

      FOperator := op;
      FOperNum := 2;
    end;
    FDisplay.UpdateUI(FOperand[intHistoryOperand], FHistory.HistoryToString, FMemory);
  end
  else // Opernum = 2
  begin
    if OperandIsEmpty(FOperand[FOperNum]) then begin
      intHistoryOperand := 1;
      FHistory.UpdateHistory(OpToString(op), huptReplaceLast);
      FOperator := op;
    end
    else begin
      Equals;
      intHistoryOperand := 1;
      FHistory.UpdateHistory(OpToString(op), huptAddNew);
      FOperator := op;
      FOperNum := 2;
    end;
    FDisplay.UpdateUI(FOperand[intHistoryOperand], FHistory.HistoryToString, FMemory);
  end;
end;

procedure TCalculator.AddDigit(digit: integer);
var HistoryAction: THistoryUpdateType;
begin
  HistoryAction := huptReplaceLast;
  if (digit >= 0) and (digit <= 9) then
  begin
    if OperandIsEmpty(FOperand[FOperNum]) then begin
      FOperand[FOperNum] := IntToStr(digit);
      HistoryAction := huptAddNew;
    end
    else begin
     FOperand[FOperNum] := FOperand[FOperNum] + IntToStr(digit);
    end;
    if FSign[FOperNum] < 0 then
    begin
      FOperand[FOperNum] := '-' + FOperand[FOperNum];
      FSign[FOperNum] := 1;
    end;
    FOperandClosed := false;
    FHistory.UpdateHistory(FOperand[FOperNum], HistoryAction);
  end;
  FDisplay.UpdateUI(FOperand[FOperNum], FHistory.HistoryToString, FMemory);
end;

procedure TCalculator.AddDecimalSeparator;
var HistoryAction: THistoryUpdateType;
begin
  HistoryAction := huptReplaceLast;
  if FOperandClosed then FOperand[FOperNum] := '0';

  if (Pos(FDecSep, FOperand[FOperNum]) = 0) then begin
    if OperandIsEmpty(FOperand[FOperNum]) then HistoryAction := huptAddNew;

    FOperand[FOperNum] := FOperand[FOperNum] + FDecSep;
    FHistory.UpdateHistory(FOperand[FOperNum], HistoryAction);
  end;
  FOperandClosed := false;
  FDisplay.UpdateUI(FOperand[FOperNum], FHistory.HistoryToString, FMemory);
  // FSeparator[FOperNum] := true;
end;

function TCalculator.OpToString(op: TOperatorEnum): string;
begin
  result := '';
  case op of
    opNull:
      result := '';
    opAdd:
      result := '+';
    opSubtract:
      result := '-';
    opMultiply:
      result := '*';
    opDivide:
      result := '/';
  end;
end;

procedure TCalculator.Equals;
var
  OpResult: double;
  iTmp: integer;
begin
  if FOperNum = 2 then
  begin
    for iTmp := 1 to 2 do
    begin
      if Copy(FOperand[iTmp], length(FOperand[iTmp]), 1) = FDecSep then
        FOperand[iTmp] := Copy(FOperand[iTmp], 1, length(FOperand[iTmp]) - 1);
    end;

    //FHistory.UpdateHistory(FOperand[2]);

    if (FOperator = opAdd) then
    begin
      OpResult := FSign[1] * StrToFloatDef(FOperand[1], 0) + FSign[2] * StrToFloatDef(FOperand[2], 0);
    end
    else if (FOperator = opSubtract) then
    begin
      OpResult := FSign[1] * StrToFloatDef(FOperand[1], 0) - FSign[2] * StrToFloatDef(FOperand[2], 0);
    end
    else if FOperator = opMultiply then
    begin
      OpResult := FSign[1] * StrToFloatDef(FOperand[1], 0) * FSign[2] * StrToFloatDef(FOperand[2], 0);
    end
    else if FOperator = opDivide then
    begin
      OpResult := (FSign[1] * StrToFloatDef(FOperand[1], 0)) / (FSign[2] * StrToFloatDef(FOperand[2], 0));
    end;

    FHistory.UpdateHistory('=', huptAddNew);
    // AddHistory(FloatToStr(OpResult));

    FOperand[1] := FloatToStr(OpResult);
    FSign[1] := 1;
    FOperand[2] := '0';
    FSeparator[2] := false;
    FSign[2] := 1;
    FOperNum := 1;
    FOperandClosed := true; // current operand (first operand) is closed, any digit or separator will overwrite it
    FHistory.UpdateHistory(FOperand[1], huptAddNew);
    FDisplay.UpdateUI(FOperand[1], FHistory.HistoryToString, FMemory);
  end;
end;

procedure TCalculator.CancelAll;
begin
  if (FOperator = opNull) and (FOperand[1] = '0') and (FOperand[2] = '0') then
  begin
    FMemory := 0;
  end;
  FOperator := opNull;
  FOperNum := 1;
  FOperand[1] := '0';
  FSeparator[1] := false;
  FSign[1] := 1;
  FOperand[2] := '0';
  FSeparator[2] := false;
  FSign[2] := 1;
  FHistory.Clear;
  FDisplay.UpdateUI(FOperand[FOperNum], FHistory.HistoryToString, FMemory);
end;

function TCalculator.OperandIsEmpty(strOperand: string): boolean;
begin
  result := false;
  if (strOperand = '0') or (strOperand = '') or (FOperandClosed) then result := true;
end;

procedure TCalculator.CalcMemory(mdirection: integer);
begin
  if (FOperNum = 2) then
  Equals;
  if mdirection = 0 then
    FMemory := StrToFloatDef(FOperand[1], 0)
  else
    FMemory := FMemory + mdirection * StrToFloatDef(FOperand[1], 0);
  FOperandClosed := true;
  FDisplay.UpdateUI(FOperand[FOperNum], FHistory.HistoryToString, FMemory);
end;

end.
