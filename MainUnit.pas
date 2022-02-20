unit MainUnit;

interface

uses TBacteryUnit, RedrawUnit, MyUnit,
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, System.Diagnostics,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation, FMX.ScrollBox, FMX.Memo, FMX.Objects,
  FMX.TabControl, FMX.Layouts, FMX.Edit;

type
  TForm1 = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    Image1: TImage;
    AddBacButton: TButton;
    LogMemo: TMemo;
    TabControl1: TTabControl;
    TabItem1: TTabItem;
    TabItem2: TTabItem;
    TabItem3: TTabItem;
    Panel3: TPanel;
    GridPanelLayout1: TGridPanelLayout;
    CountEdit: TEdit;
    SizeEdit: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    SpeedEdit: TEdit;
    Label4: TLabel;
    Edit2: TEdit;
    Timer1: TTimer;
    Panel4: TPanel;
    Button1: TButton;
    TestButton: TButton;
    Label5: TLabel;
    Edit1: TEdit;
    Label6: TLabel;
    Label7: TLabel;
    Panel5: TPanel;
    GridPanelLayout2: TGridPanelLayout;
    FPSEdit: TEdit;
    AnimSpeedEdit: TEdit;
    Label8: TLabel;
    Label9: TLabel;
    Label10: TLabel;
    AnimMasEdit: TEdit;
    Label11: TLabel;
    Edit6: TEdit;
    Label12: TLabel;
    Edit7: TEdit;
    UpdateSettButton: TButton;
    Layout1: TLayout;
    FPSTextLabel: TLabel;
    FPSLabel: TLabel;
    FPSprocentLabel: TLabel;
    procedure AddBacButtonClick(Sender: TObject);
    procedure Panel1Resize(Sender: TObject);
    procedure Image1Resize(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure TestButtonClick(Sender: TObject);
    procedure UpdateSettButtonClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }

  end;
    procedure print(s:string);
    procedure Redraw;


var
  Form1: TForm1;
  i,j:word;
  FPSText:array[0..15] of string;

implementation

{$R *.fmx}
procedure print(s:string); begin  Form1.LogMemo.Lines.Add(s); end;

procedure Redraw;
begin
  Form1.Image1.Bitmap.Clear(TAlphaColors.White);
  //RedrawBacteryEllipse;
  RedrawBactery;
  RedrawFood;
  //позже будет добавлена отрисовка остальных объектов
end;








procedure TForm1.AddBacButtonClick(Sender: TObject);
var count:word;
begin
print('True='+BoolToStr(True)+'      False='+BoolToStr(False));
randomize;
count:=strtoint(Countedit.Text);
//добавление бактерий
for i := 1+sim.BacCount to count+sim.BacCount do
  begin
  Bac[i].Info.size:=strtofloat(SizeEdit.Text);
  Bac[i].Info.speed:=strtofloat(SpeedEdit.Text);

  Bac[i].Gen.ParentID:='0';
  Bac[i].Gen.Colony:=1;        //номер колонии
  Bac[i].Gen.Age:=0;
  Bac[i].Energy:=Bac[i].Info.size*10;

  Bac[i].Position.X:=random(round(Image1.Width)-20)+10;
  Bac[i].Position.Y:=random(round(Image1.Width)-20)+10;
  Bac[i].Movement.Angle:=random(359);
  CountSpeed(i);
  Bac[i].alive:=True;
  end;
 bac[0]:=bac[1];
inc(sim.BacCount,count);
LogMemo.lines.Add(inttostr(sim.BacCount));
Redraw;
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
Timer1.Enabled:=not(Timer1.Enabled);
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
sim.BacCount:=0;
sim.FoodCount:=0;
sett.AnimMas:=0.5;
sett.AnimSpeed:=0.5;
FPSTextLabel.Text:= 'Total'+#13#10+
                    'CountWorldFood'+#13#10+
                    'CountWorldBactery'+#13#10+
                    'Eat'+#13#10+
                    'Born-Die'+#13#10+
                    'CountWorldFood'+#13#10+
                    'CountWorldBactery'+#13#10+
                    'Think'+#13#10+
                    'Move'+#13#10+
                    'SpawnFood'+#13#10+
                    'Redraw';
FPSText[0] :='Total______________';
FPSText[1] :='CountWorldFood_____';
FPSText[2] :='CountWorldBactery__';
FPSText[3] :='Eat________________';
FPSText[4] :='Born-Die___________';
FPSText[5] :='SpawnFood__________';
FPSText[6] :='CountWorldFood_____';
FPSText[7] :='CountWorldBactery__';
FPSText[8] :='Think______________';
FPSText[9] :='Move_______________';
FPSText[10]:='Redraw_____________';


sim.X:=round(Image1.Height);
sim.Y:=sim.X;
end;

procedure TForm1.Image1Resize(Sender: TObject);
begin
Image1.Bitmap.SetSize(round(Image1.Width), round(Image1.Height));
Image1.Bitmap.Clear(TAlphaColors.White);
end;

procedure TForm1.Panel1Resize(Sender: TObject);
begin
Panel1.Width:=Panel1.Height;
end;

procedure TForm1.TestButtonClick(Sender: TObject);
begin
bac[1].Movement.Angle:=strtofloat(Edit1.text);
CountSpeed(1);
print('bac[1].Movement.Angle=  '+floattostr(bac[1].Movement.Angle));
print('bac[1].Movement.speedX=  '+floattostr(bac[1].Movement.speedX));
print('bac[1].Movement.speedY=  '+floattostr(bac[1].Movement.speedY));
end;



procedure TForm1.Timer1Timer(Sender: TObject);
var SW: TStopwatch; FPS:array[0..11]of double;
begin


{
if BacteryCount<2000 then
 begin
  inc(BacteryCount,1);
  bac[BacteryCount]:=bac[0];
  bac[BacteryCount].alive:=true;
  bac[BacteryCount].Movement.Angle:=random(359);
  CountSpeed(BacteryCount);


 end
 else Timer1.Enabled:=false;}
logmemo.Lines.Clear;
label6.Text:=inttostr(sim.BacCount)+'  '+inttostr(sim.FoodCount);
SW:=TStopwatch.StartNew;
//logmemo.Lines.add(SW.Elapsed.TotalMilliseconds.tostring);
//просчитываем состояние мира-здесь добавим проверку наложения
CountWorldFood;                             FPS[1]:=SW.Elapsed.TotalMilliseconds;
CountWorldBactery;                          FPS[2]:=SW.Elapsed.TotalMilliseconds;
CheckBacCollision;                          FPS[3]:=SW.Elapsed.TotalMilliseconds;

EatBactery;
EatFood;

//рожение-смерть по энергии
                                            FPS[4]:=SW.Elapsed.TotalMilliseconds;
//спавн еды
If (sim.foodcount<900) then
  Spawnfood(10);                            FPS[5]:=SW.Elapsed.TotalMilliseconds;
//новый просчет
CountWorldFood;                             FPS[6]:=SW.Elapsed.TotalMilliseconds;
CountWorldBactery;                          FPS[7]:=SW.Elapsed.TotalMilliseconds;
//проверка наложения и составление кластеров коллизий
//Думаем
for i := 1 to sim.BacCount  do Think(i);    FPS[8]:=SW.Elapsed.TotalMilliseconds;
//и делаем ход-перед движением надо проверить, есть ли overlap и эти бактерии двигать усредненно
for i := 1 to sim.BacCount  do  Move(i);    FPS[9]:=SW.Elapsed.TotalMilliseconds;
//отрисовка
Redraw;                                     FPS[10]:=SW.Elapsed.TotalMilliseconds;


FPS[0]:=SW.Elapsed.TotalMilliseconds;
logmemo.Lines.add(FPSText[1]+floattostr(FPS[1]));
for i := 2 to 10 do
  logmemo.Lines.add(FPSText[i]+floattostr(round((FPS[i]-FPS[i-1])*100)/100) );
logmemo.Lines.add(FPSText[0]+floattostr(FPS[0]));
FPSLabel.Text:=floattostr(FPS[0])+#13#10+floattostr(FPS[1]);
FPSprocentLabel.Text:='%'+#13#10+floattostr(FPS[1]/FPS[0]*100);
for i := 2 to 10 do FPSLabel.Text:=FPSLabel.Text+#13#10+floattostr(FPS[i]-FPS[i-1]);
for i := 2 to 10 do FPSprocentLabel.Text:=FPSprocentLabel.Text+#13#10+floattostr(round((FPS[i]-FPS[i-1])/FPS[0]*100*100)/100);
end;

procedure TForm1.UpdateSettButtonClick(Sender: TObject);
var stand:boolean;
begin
stand:=Timer1.Enabled;
Timer1.Enabled:=False;
Timer1.Interval:=round(1000/strtoint(FPSEdit.Text));
sett.AnimSpeed:=strtofloat(AnimspeedEdit.Text);
sett.AnimMas:= strtofloat(AnimMasEdit.Text);
Timer1.Enabled:=stand;
end;

end.
