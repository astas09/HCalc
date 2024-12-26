unit uCalcHistory;

interface

type
  THistoryUpdateType = (huptReplaceLast = 1, huptMergeLast = 2, huptAddNew = 10, huptDeleteLast = 20);

type
  TCalcHistory = class
  private
    FArrHist: array of string;
  public
    function HistoryToString: string;
    procedure Clear;
    procedure UpdateHistory(strHistoryElement: string; parAdd: THistoryUpdateType = huptMergeLast);
    function LastOperandIsEmpty(): boolean;
  end;

implementation

function TCalcHistory.HistoryToString: string;
var
  iLen: integer;
begin
  result := '';
  for iLen := Low(FArrHist) to High(FArrHist) do
  begin
    result := result + ' ' + FArrHist[iLen];
  end;
end;

procedure TCalcHistory.UpdateHistory(strHistoryElement: string; parAdd: THistoryUpdateType = huptMergeLast);
var
  iLen: integer;
begin
  iLen := length(FArrHist);

  if (parAdd = huptDeleteLast) or (LastOperandIsEmpty and (parAdd = huptAddNew)) then
  begin
    if iLen > 0 then
      SetLength(FArrHist, iLen - 1);
  end;

  if (parAdd = huptAddNew) or (iLen = 0) then
  begin
    SetLength(FArrHist, iLen + 1);
    iLen := length(FArrHist);
  end;

  if iLen > 0 then
  begin
    if (parAdd = huptMergeLast) or (parAdd = huptAddNew) then
      FArrHist[iLen - 1] := FArrHist[iLen - 1] + strHistoryElement
    else if (parAdd = huptReplaceLast) then
      FArrHist[iLen - 1] := strHistoryElement;
  end;
end;

function TCalcHistory.LastOperandIsEmpty(): boolean;
var iLen: integer;
begin
  result := false;
  iLen := length(FArrHist);
  if iLen > 0 then begin
    if (FArrHist[iLen - 1] = '0') or (FArrHist[iLen - 1] = '') then result := true;
  end;
end;

procedure TCalcHistory.Clear();
begin
  SetLength(FArrHist, 0);
end;

end.
