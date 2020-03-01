program Roll;

{$MODE Delphi}

uses
  Forms, Interfaces,
  unRoll in 'unRoll.pas' {Form3};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm3, Form3);
  Application.Run;
end.
