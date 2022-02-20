unit MyUnit;

interface

uses TBacteryUnit, Math,
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls,
  FMX.Objects;


type
  TFood=record //еда
      eated:boolean;
      X,Y:word;
    end;
  TSimulation=record   //основные данные о симул¤ции
    X,Y, //размеры мира
    BacCount, FoodCount,//количество бактерий и еды
    MaxBacCount:word;// максимально существовавшее количество бактерий - показывает, сколько эллипсов было создано

  end;
  TSettings=record
    AnimSpeed,AnimMas,WorldMas:single;// масштаб и скорость анимации отображени¤ размера бактерий форме
    kEnergy:single; // коэфициент расходовани¤ энергии дл¤ всей системы
    kRadEat:single; // коэфициент возможности поедани¤, от размера существа
    kRadSence:single; // коэфициент замечани¤ еды, от размера существа
    EnergyRule:byte;
    FoodSpawn, FoodPower: word;  // количество спавнейщейся еды в одну симул¤цию и энергия этой еды
    Mutshance, MutPower:byte; //шансы мутации в процентах
  end;

  TColony=record
    color:TAlphaColor; //цвет колонии
    count,born,died:integer;     // количество бактерий в колонии
    Energy,       //энерги¤ колонии
    MinEnergy,MaxEnergy, //минимальна¤ и максимальна¤ энерги¤ в колонии

    Age:real;         //общий возраст всех бактерий в колонии, дл¤ расчета среднего
    minAge,MaxAge:real;  //минимальный и максимальный возраст в колонии
end;

type TBacworld=record
  path:single;
  Overlap, FirsTime:boolean;
end;
var
  i,j:word;
  Player:boolean;
  //          строка      столбец
  //              food       bac
  foodworld:array[0..1000, 1..2000] of single;
  bacworld:array[0..2000, 0..2000] of single;  //0-player
  bacFirstOverlap:array[0..2000, 0..2000] of boolean; // инфа, была ли встреча первой

  bac:array [0..2000] of TBactery;
  food:array[0..1000] of TFood;
  Colony: array[0..100] of TColony;// массив колоний. 0- еда



  //Ellipse:array[0..3000] of TEllipse;
  sett:TSettings;
  sim:TSimulation;

  function GetPath(x1, y1, x2, y2:real):real;
  function GetAngle(x1, y1, x2, y2:real):integer;

  procedure CountWorldBactery; //просчет расстояний между бактериями
  procedure CountWorldFood;    //просчет расстояний между бактериями и едой

  procedure SpawnFood(count:byte);
  procedure EatFood;
  procedure EatBactery;
  function CheckOverlap(Bac1,Bac2:word):Boolean; //функция проверяет, произошла ли коллизия между бактериями
  function CheckPusch(Bac1,Bac2:word):Boolean; //функция проверяет, толкаются ли бактерии между собой
  procedure CheckBacCollision; // проверка бактерий на коллизии и сдвиг тех, кто встретился, чтобы они не перекрывали друг друга

implementation  uses MainUnit;

function GetPath(x1, y1, x2, y2:real):real;   //Расстояние между двумя точками
begin
Result:=Power( Power(x1-x2, 2)+Power(y1-y2, 2),0.5);
end;

function GetAngle(x1, y1, x2, y2:real):integer;
var x,y,m:real; nul:real;
begin
x:=x2-x1; y:=y2-y1;
m:=-y/GetPath(x1, y1, x2, y2);
Result:=round(   RadToDeg(   Arccos( m )   )   );
if x<0 then Result:=360-Result;
end;

procedure CountWorldBactery;
begin
for i := 1 to Sim.BacCount-2 do
    for j := i+1 to Sim.BacCount do
      begin
      if (abs(bac[i].Position.X-bac[j].Position.X)<50) and (abs(bac[i].Position.Y-bac[j].Position.Y)<50)
      then bacworld[i,j]:=GetPath(bac[i].Position.X, bac[i].Position.Y,
                                  bac[j].Position.X,bac[j].Position.Y)
      else bacworld[i,j]:=-1;
      bacworld[j,i]:=bacworld[i,j];
      end;

end;

procedure CountWorldFood;
begin
for i := 1 to Sim.FoodCount do
    for j := 1 to Sim.BacCount do
      if (abs(bac[j].Position.X-food[i].X)<50) and (abs(bac[j].Position.Y-food[i].Y)<50)
      then foodworld[i,j]:=GetPath(bac[j].Position.X, bac[j].Position.Y,
                                  food[i].X,food[i].Y)
      else foodworld[i,j]:=-1;
end;

procedure SpawnFood(count:byte);
begin
for i := 1 to count do
  begin
  sim.FoodCount:=sim.FoodCount+1;
  food[sim.FoodCount].x:=50+random(round(sim.x)-100);
  food[sim.FoodCount].y:=50+random(round(sim.y)-100);
  end;
end;


procedure EatFood;
var eat:array of word; a:byte; las:word; stop:boolean;
begin
for i := 1 to sim.FoodCount do
  begin
  a:=0; // a- количество претендентов на поедание
  for j := 1 to sim.BacCount do
    if foodworld[i,j]<>-1 then
      if foodworld[i,j]<=bac[j].Info.size/2 then
        begin
        inc(a,1);
        SetLength(eat,a+1);
        eat[a]:=j;  //собираем массив из претендентов на поедание
        end;
  if a<>0 then food[i].eated:=True; //поедание
                                    //добавить раздел энергии между бактериями
  end;


// если съедена- удаляем-переорганизация массива

{
можно идти с коца и если еда съедена- записывать на ее место последнюю еду в списке и
}

for i := sim.FoodCount downto 1 do //  идем с конца
  if food[i].eated then//если еда съедена
  if i=sim.FoodCount   // и это уже последняя
  then
    sim.FoodCount:=sim.FoodCount-1  //то просто уменьшаем количество еды на единицу и все хорошо
  else
    begin                         //  если гдето в середине
    food[i]:=food[sim.FoodCount]; // переносим на ее место последнюю еду- она по любому не съедена, иначе в прошлом ее удалили бы
    sim.FoodCount:=sim.FoodCount-1; // и уменьшаем количество еды на один
    end;


end;

function CheckOverlap(Bac1,Bac2:word):Boolean;//проверка коллизии
begin

if BacWorld[Bac1,Bac2]<=(bac[bac1].Info.size+bac[bac2].Info.size)/2 then
Result:=True
else Result:=false;

end;

function CheckPusch(Bac1,Bac2:word):Boolean;
begin       // если в будущем расстояние уменьшится
if bacworld[Bac1,Bac2]>GetPath(bac[Bac1].Position.X+bac[Bac1].Movement.SpeedX, bac[Bac1].Position.Y+bac[Bac1].Movement.SpeedY,
                                  bac[Bac2].Position.X+bac[Bac2].Movement.SpeedX,bac[Bac2].Position.Y+bac[Bac2].Movement.SpeedY)
  then Result:=True  //значит они толкаются
  else Result:=False;
if Result then if bacFirstOverlap[i,j] then


end;


procedure EatBactery;
var a:word;
Lx,Ly:single;//расстояние по осям между бактериями
tx,ty:single;//время столкновения
Bac1_x_old,Bac1_y_old,Bac2_x_old,Bac2_y_old:single; //положение бактерий до столкновения
Vx,Vy:single; //смещение по осям, плюс половина размера
//тут нужно обработать все коллизии и определить, кто кого съел, а кто кого просто толкнул
begin
for i := 1 to Sim.BacCount-2 do    //идем по треугольнику,
    for j := i+1 to Sim.BacCount do
      if bacworld[i,j]<>-1 then  //если теоретически может произойти коллизия
      if CheckOverlap(i,j) then //проверяем есть ли она по факту
      begin
      //нужно сравнить размеры для съедания, но пока что это опустим
      //если кого то из бактерий можно будет съесть, то никого не двигаем, а съедаем
      //сравнивам, двигаются ли бактерии навстречу, это происходит, если последующее расстояние между бактериями в следующем ходу уменьшится
   //   if CheckPusch(i,j) then //если они "Толкаются"
      //то их нужно просто немного подвинуть туда, где по факту было столкновение
      //можно рассчитать положение за секунду до столкновения и затем определить где они конкретно остановились и тормознуть их там
        begin
        //для Х
        if    ((bac[i].Movement.SpeedX<0)Xor(bac[j].Movement.SpeedX<0))   //если оба не двигаются влево
          OR  ((bac[i].Movement.SpeedX>0)Xor(bac[j].Movement.SpeedX>0)) //или вправо
          then
          begin
     //     Bac1_x_old:=bac[i].Position.X-bac[i].Movement.SpeedX; //предыдущее положение бактерии i
     //     Bac2_x_old:=bac[j].Position.X-bac[j].Movement.SpeedX;//предыдущее положение бактерии j
     //     Lx:=abs(Bac1_x_old-Bac2_x_old);  //расстояние по осям между бактериями до столкновения
     //     tx:=(Lx-(bac[i].Info.size+bac[j].Info.size)/2)/(abs(bac[i].Movement.SpeedX)+abs(bac[j].Movement.SpeedX));
          Vx:=(bac[i].Movement.SpeedX+bac[j].Movement.SpeedX)/2; //средняя скорость бактерий -если они не первый раз встретились
          bac[i].Position.X:=bac[i].Position.X+Vx;
          bac[j].Position.X:=bac[j].Position.X+Vx;
          end;

        //для Y
        if    ((bac[i].Movement.SpeedY<0)Xor(bac[j].Movement.SpeedY<0))   //если оба не двигаются вниз
          OR  ((bac[i].Movement.SpeedY>0)Xor(bac[j].Movement.SpeedY>0)) // или оба вверх
          then
          begin
     //     Bac1_y_old:=bac[i].Position.Y-bac[i].Movement.SpeedY;
    //      Bac2_y_old:=bac[j].Position.Y-bac[j].Movement.SpeedY;
   //       Ly:=abs(Bac1_y_old-Bac2_y_old);
   //       ty:=(Ly-(bac[i].Info.size+bac[j].Info.size)/2)/(abs(bac[i].Movement.SpeedY)+abs(bac[j].Movement.SpeedY));
          bac[i].Position.Y:=bac[i].Position.Y+vY;
          bac[j].Position.Y:=bac[j].Position.Y+vY;
          end;

        //просчет нового положения мира
        bacworld[i,j]:=GetPath(bac[i].Position.X, bac[i].Position.Y,
                                    bac[j].Position.X,bac[j].Position.Y);
        bacworld[j,i]:=bacworld[i,j];
        //и для обоих нужно еще раз просчитать еду
        for a := 1 to Sim.FoodCount do
          if (abs(bac[j].Position.X-food[a].X)<50) and (abs(bac[j].Position.Y-food[a].Y)<50)
            then foodworld[a,j]:=GetPath(bac[j].Position.X, bac[j].Position.Y,
                                    food[a].X,food[a].Y)
            else foodworld[a,j]:=-1;
        for a := 1 to Sim.FoodCount do
          if (abs(bac[i].Position.X-food[a].X)<50) and (abs(bac[i].Position.Y-food[a].Y)<50)
            then foodworld[a,i]:=GetPath(bac[i].Position.X, bac[i].Position.Y,
                                    food[a].X,food[a].Y)
            else foodworld[a,i]:=-1;
        end;
      end;
end;















end.
