unit TBacteryUnit;

interface

uses Math,
      System.UITypes, System.Types, System.Math.Vectors, System.SysUtils,
      FMX.Objects, FMX.Graphics,FMX.Dialogs;


type TBacteryInfo=record //самые основные данные- то, что в будущем может мутировать
  size,               //размер
  speed:single;        //скорость
end;

type TPosition=record
  X,Y:single
end;

type TMovement=record
  Angle,                 // направление движения
  SpeedX, SpeedY:single; //Проекции скорости на оси X и Y
end;

type TGenetic=record
  ParentID:shortstring;
  Colony:byte;        //номер колонии, к которой относится бактерия-нужна так же для цвета
  Age:word;//возраст
  end;

type
TBactery=record
  alive,          //жива ли ячейка памяти bzw свободна ли ячейка памяти
  active:boolean; //может ли в этом ходу что либо еще сделать
  ID:shortstring;    //уникальный код бактерии-нужен будет для отслеживания поколений
  Info:TBacteryInfo;
  Gen:TGenetic; // данные о генах - родители, потомки - будет нужно в будущем
  Energy:single;        // Количество энергии
  Position:TPosition;   // Положение бактерии
  Movement:TMovement;   // переменные движения
  poly:TPolygon;
  end;

  //
  //    Привязать функции к массиву бактерий
  //


  // создание бактерии
  procedure Born(Parent, Child:word);//процедура рожания самой бактерией
                                     //исправить генерацию местоположения, направления движения
  //function Report:string;//функция возвращает строку, в которой записаны стандартные данные

  procedure CountSpeed(BacNumber:word); //процедура расчета SpeedX и SpeedY
  procedure CountPolygon(BacNumber:word; points:byte);
  //procedure Move;//процедура нормального шага
  ///procedure MoveTo(X,Y:single);//процедура телепортации - нужна ли она - фиг знает

  procedure Think(Number:word);

  function GetInfo(BacNumber:word):string;  // возвращает строку с основными данными бактери
  //overload;- для того чтобы можно было создавать много процедур с одинаковым названием

  procedure Move(BacNumber:word);


implementation uses MainUnit, MyUnit;

function generateID:shortstring; //функция генерации уникального ID для бактерии
begin
Result:='12345qwerty'
end;

function GetInfo(BacNumber:word):string;
begin
  Result:='size='+floattostr(bac[BacNumber].Info.size)+
          'speed='+floattostr(bac[BacNumber].Info.speed);
end;

procedure Born(Parent, Child:word); //в процедуру подается родитель
begin
bac[Child].Info:=     bac[Parent].Info; //копируются данные предка
bac[Child].Gen:=      bac[Parent].Gen;

bac[Child].Energy:=   bac[Parent].Energy/2; //забирает себе половину энергии предка

bac[Child].Gen.ParentID:=bac[Parent].ID; //записываем имя предка
bac[Child].ID:=generateID; // генерация уникального айди

bac[Child].alive:=true;   // жива
bac[Child].active:=true;  //активна
//
//        СЛЕДУЮЩИЙ КОД ПЕРЕРАБОТАТЬ
//
bac[Child].Position:= bac[Parent].Position; //появляется в той же точке
bac[Child].Movement:= bac[Parent].Movement; // движется туда же куда и родитель
CountSpeed(Child);  //просчитываются переменные движения SpeedX и SpeedY



end;

procedure CountSpeed(BacNumber:word);  //ось У направлена вниз, в отличии от значений от синуса и косинуса
begin
bac[BacNumber].Movement.speedX:=bac[BacNumber].Info.speed*sin(DegToRad(bac[BacNumber].Movement.angle))*sett.AnimSpeed;
bac[BacNumber].Movement.speedY:=-bac[BacNumber].Info.speed*cos(DegToRad(bac[BacNumber].Movement.angle))*sett.AnimSpeed;

end;


procedure Move(BacNumber:word);
begin

//добавить проверку, что если е
bac[BacNumber].Position.X:=bac[BacNumber].Position.X+bac[BacNumber].Movement.speedX;
bac[BacNumber].Position.Y:=bac[BacNumber].Position.Y+bac[BacNumber].Movement.speedY;
CountPolygon(BacNumber,10);

if bac[BacNumber].Position.X<20 then
  begin
  bac[BacNumber].Position.X:=21;
  bac[BacNumber].Movement.Angle:= 360-bac[BacNumber].Movement.Angle;
  CountSpeed(BacNumber);
  end;
if bac[BacNumber].Position.X>Form1.Image1.Height-20 then
  begin
  bac[BacNumber].Position.X:=Form1.Image1.Height-21;
  bac[BacNumber].Movement.Angle:= 360-bac[BacNumber].Movement.Angle;
  CountSpeed(BacNumber);
  end;
if bac[BacNumber].Position.Y<20 then
  begin
  bac[BacNumber].Position.Y:=21;
  bac[BacNumber].Movement.Angle:= 180-bac[BacNumber].Movement.Angle;
  CountSpeed(BacNumber);
  end;
if bac[BacNumber].Position.Y>Form1.Image1.Height-20 then
  begin
  bac[BacNumber].Position.Y:=Form1.Image1.Height-21;
  bac[BacNumber].Movement.Angle:= 180-bac[BacNumber].Movement.Angle;
  CountSpeed(BacNumber);
  end;

  //проверка на коллизии и оотталкивание объектов друг от друга
end;

procedure Think(Number:word);
var ziel:word; zielLength:single; founded:boolean; i:word;
begin
ziel:=0;
zielLength:=10000;
founded:=false;
for i := 1 to sim.FoodCount do
  if foodworld[i,number]<>-1 then
  if foodworld[i,number]<zielLength then
  begin
  zielLength:=foodworld[i,number];
  ziel:=i;
  founded:=true;
  end;
if founded then
  begin
  bac[number].Movement.Angle:= GetAngle(bac[number].Position.X, bac[number].Position.Y, food[Ziel].X, food[ziel].Y );
  Countspeed(number); // полигон позже просчитывается при движении
  end;
end;





procedure CountPolygon(BacNumber:word;points:byte);
var i:byte;X0,Y0,Rad:single;
begin
SetLength(bac[BacNumber].poly,points);
for i := 0 to points-1 do
  begin
 Rad:=i*(2*pi/points);
 X0:=bac[BacNumber].info.Size*cos(Rad)*Sett.AnimMas;
 Y0:=bac[BacNumber].info.Size*sin(Rad)/2*Sett.AnimMas;
 Rad:=DegToRad(bac[BacNumber].Movement.Angle+90);
 bac[BacNumber].poly[i].X:=x0*cos(Rad)-y0*sin(Rad)+bac[BacNumber].Position.X;
 bac[BacNumber].poly[i].Y:=x0*sin(Rad)+y0*cos(Rad)+bac[BacNumber].Position.Y;

 end;

end;


end.
