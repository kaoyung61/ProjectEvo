unit MyUnit;

interface

uses TBacteryUnit, Math,
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls,
  FMX.Objects;


type
  TFood=record //���
      eated:boolean;
      X,Y:word;
    end;
  TSimulation=record   //�������� ������ � ��������
    X,Y, //������� ����
    BacCount, FoodCount,//���������� �������� � ���
    MaxBacCount:word;// ����������� �������������� ���������� �������� - ����������, ������� �������� ���� �������

  end;
  TSettings=record
    AnimSpeed,AnimMas,WorldMas:single;// ������� � �������� �������� ���������� ������� �������� �����
    kEnergy:single; // ���������� ����������� ������� �� ���� �������
    kRadEat:single; // ���������� ����������� �������, �� ������� ��������
    kRadSence:single; // ���������� �������� ���, �� ������� ��������
    EnergyRule:byte;
    FoodSpawn, FoodPower: word;  // ���������� ������������ ��� � ���� �������� � ������� ���� ���
    Mutshance, MutPower:byte; //����� ������� � ���������
  end;

  TColony=record
    color:TAlphaColor; //���� �������
    count,born,died:integer;     // ���������� �������� � �������
    Energy,       //������ �������
    MinEnergy,MaxEnergy, //���������� � ����������� ������ � �������

    Age:real;         //����� ������� ���� �������� � �������, �� ������� ��������
    minAge,MaxAge:real;  //����������� � ������������ ������� � �������
end;

type TBacworld=record
  path:single;
  Overlap, FirsTime:boolean;
end;
var
  i,j:word;
  Player:boolean;
  //          ������      �������
  //              food       bac
  foodworld:array[0..1000, 1..2000] of single;
  bacworld:array[0..2000, 0..2000] of single;  //0-player
  bacFirstOverlap:array[0..2000, 0..2000] of boolean; // ����, ���� �� ������� ������

  bac:array [0..2000] of TBactery;
  food:array[0..1000] of TFood;
  Colony: array[0..100] of TColony;// ������ �������. 0- ���



  //Ellipse:array[0..3000] of TEllipse;
  sett:TSettings;
  sim:TSimulation;

  function GetPath(x1, y1, x2, y2:real):real;
  function GetAngle(x1, y1, x2, y2:real):integer;

  procedure CountWorldBactery; //������� ���������� ����� ����������
  procedure CountWorldFood;    //������� ���������� ����� ���������� � ����

  procedure SpawnFood(count:byte);
  procedure EatFood;
  procedure EatBactery;
  function CheckOverlap(Bac1,Bac2:word):Boolean; //������� ���������, ��������� �� �������� ����� ����������
  function CheckPusch(Bac1,Bac2:word):Boolean; //������� ���������, ��������� �� �������� ����� �����
  procedure CheckBacCollision; // �������� �������� �� �������� � ����� ���, ��� ����������, ����� ��� �� ����������� ���� �����

implementation  uses MainUnit;

function GetPath(x1, y1, x2, y2:real):real;   //���������� ����� ����� �������
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
  a:=0; // a- ���������� ������������ �� ��������
  for j := 1 to sim.BacCount do
    if foodworld[i,j]<>-1 then
      if foodworld[i,j]<=bac[j].Info.size/2 then
        begin
        inc(a,1);
        SetLength(eat,a+1);
        eat[a]:=j;  //�������� ������ �� ������������ �� ��������
        end;
  if a<>0 then food[i].eated:=True; //��������
                                    //�������� ������ ������� ����� ����������
  end;


// ���� �������- �������-��������������� �������

{
����� ���� � ���� � ���� ��� �������- ���������� �� �� ����� ��������� ��� � ������ �
}

for i := sim.FoodCount downto 1 do //  ���� � �����
  if food[i].eated then//���� ��� �������
  if i=sim.FoodCount   // � ��� ��� ���������
  then
    sim.FoodCount:=sim.FoodCount-1  //�� ������ ��������� ���������� ��� �� ������� � ��� ������
  else
    begin                         //  ���� ����� � ��������
    food[i]:=food[sim.FoodCount]; // ��������� �� �� ����� ��������� ���- ��� �� ������ �� �������, ����� � ������� �� ������� ��
    sim.FoodCount:=sim.FoodCount-1; // � ��������� ���������� ��� �� ����
    end;


end;

function CheckOverlap(Bac1,Bac2:word):Boolean;//�������� ��������
begin

if BacWorld[Bac1,Bac2]<=(bac[bac1].Info.size+bac[bac2].Info.size)/2 then
Result:=True
else Result:=false;

end;

function CheckPusch(Bac1,Bac2:word):Boolean;
begin       // ���� � ������� ���������� ����������
if bacworld[Bac1,Bac2]>GetPath(bac[Bac1].Position.X+bac[Bac1].Movement.SpeedX, bac[Bac1].Position.Y+bac[Bac1].Movement.SpeedY,
                                  bac[Bac2].Position.X+bac[Bac2].Movement.SpeedX,bac[Bac2].Position.Y+bac[Bac2].Movement.SpeedY)
  then Result:=True  //������ ��� ���������
  else Result:=False;
if Result then if bacFirstOverlap[i,j] then


end;


procedure EatBactery;
var a:word;
Lx,Ly:single;//���������� �� ���� ����� ����������
tx,ty:single;//����� ������������
Bac1_x_old,Bac1_y_old,Bac2_x_old,Bac2_y_old:single; //��������� �������� �� ������������
Vx,Vy:single; //�������� �� ����, ���� �������� �������
//��� ����� ���������� ��� �������� � ����������, ��� ���� ����, � ��� ���� ������ �������
begin
for i := 1 to Sim.BacCount-2 do    //���� �� ������������,
    for j := i+1 to Sim.BacCount do
      if bacworld[i,j]<>-1 then  //���� ������������ ����� ��������� ��������
      if CheckOverlap(i,j) then //��������� ���� �� ��� �� �����
      begin
      //����� �������� ������� ��� ��������, �� ���� ��� ��� �������
      //���� ���� �� �� �������� ����� ����� ������, �� ������ �� �������, � �������
      //���������, ��������� �� �������� ���������, ��� ����������, ���� ����������� ���������� ����� ���������� � ��������� ���� ����������
   //   if CheckPusch(i,j) then //���� ��� "���������"
      //�� �� ����� ������ ������� ��������� ����, ��� �� ����� ���� ������������
      //����� ���������� ��������� �� ������� �� ������������ � ����� ���������� ��� ��� ��������� ������������ � ���������� �� ���
        begin
        //��� �
        if    ((bac[i].Movement.SpeedX<0)Xor(bac[j].Movement.SpeedX<0))   //���� ��� �� ��������� �����
          OR  ((bac[i].Movement.SpeedX>0)Xor(bac[j].Movement.SpeedX>0)) //��� ������
          then
          begin
     //     Bac1_x_old:=bac[i].Position.X-bac[i].Movement.SpeedX; //���������� ��������� �������� i
     //     Bac2_x_old:=bac[j].Position.X-bac[j].Movement.SpeedX;//���������� ��������� �������� j
     //     Lx:=abs(Bac1_x_old-Bac2_x_old);  //���������� �� ���� ����� ���������� �� ������������
     //     tx:=(Lx-(bac[i].Info.size+bac[j].Info.size)/2)/(abs(bac[i].Movement.SpeedX)+abs(bac[j].Movement.SpeedX));
          Vx:=(bac[i].Movement.SpeedX+bac[j].Movement.SpeedX)/2; //������� �������� �������� -���� ��� �� ������ ��� �����������
          bac[i].Position.X:=bac[i].Position.X+Vx;
          bac[j].Position.X:=bac[j].Position.X+Vx;
          end;

        //��� Y
        if    ((bac[i].Movement.SpeedY<0)Xor(bac[j].Movement.SpeedY<0))   //���� ��� �� ��������� ����
          OR  ((bac[i].Movement.SpeedY>0)Xor(bac[j].Movement.SpeedY>0)) // ��� ��� �����
          then
          begin
     //     Bac1_y_old:=bac[i].Position.Y-bac[i].Movement.SpeedY;
    //      Bac2_y_old:=bac[j].Position.Y-bac[j].Movement.SpeedY;
   //       Ly:=abs(Bac1_y_old-Bac2_y_old);
   //       ty:=(Ly-(bac[i].Info.size+bac[j].Info.size)/2)/(abs(bac[i].Movement.SpeedY)+abs(bac[j].Movement.SpeedY));
          bac[i].Position.Y:=bac[i].Position.Y+vY;
          bac[j].Position.Y:=bac[j].Position.Y+vY;
          end;

        //������� ������ ��������� ����
        bacworld[i,j]:=GetPath(bac[i].Position.X, bac[i].Position.Y,
                                    bac[j].Position.X,bac[j].Position.Y);
        bacworld[j,i]:=bacworld[i,j];
        //� ��� ����� ����� ��� ��� ���������� ���
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
