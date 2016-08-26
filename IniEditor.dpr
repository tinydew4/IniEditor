program IniEditor;

uses
  Vcl.Forms,
  _fmMain in '_fmMain.pas' {fmMain},
  Vcl.Themes,
  Vcl.Styles;

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title := 'Ini Editor';
  TStyleManager.TrySetStyle('Cyan Night');
  Application.CreateForm(TfmMain, fmMain);
  Application.Run;
end.
