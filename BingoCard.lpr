program BingoCard;

{$MODE Delphi}

uses
  Forms, Interfaces,
  unBingoCard in 'unBingoCard.pas' {Form1},
  unAbout in 'unAbout.pas' {fmAbout};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TfmAbout, fmAbout);
  Application.Run;
end.
