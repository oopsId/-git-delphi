program tri_v_ryad_nostable;





{$R *.dres}

uses
  System.StartUpCopy,
  FMX.Forms,
  u_GameForm in 'u_GameForm.pas' {GameForm};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TGameForm, GameForm);
  Application.Run;
end.
