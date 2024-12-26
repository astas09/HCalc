program HCalc;

uses
  System.StartUpCopy,
  FMX.Forms,
  uInterfaces in 'uInterfaces.pas',
  uCalculator in 'uCalculator.pas',
  FrmCalc in 'FrmCalc.pas' {FormCalc},
  uCalcHistory in 'uCalcHistory.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TFormCalc, FormCalc);
  Application.Run;
end.
