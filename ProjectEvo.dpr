program ProjectEvo;

uses
  System.StartUpCopy,
  FMX.Forms,
  MainUnit in 'MainUnit.pas' {Form1},
  TBacteryUnit in 'TBacteryUnit.pas',
  RedrawUnit in 'RedrawUnit.pas',
  MyUnit in 'MyUnit.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
