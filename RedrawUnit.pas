unit RedrawUnit;

interface
uses TBacteryUnit,
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation, FMX.ScrollBox, FMX.Memo, FMX.Objects,
  FMX.TabControl, FMX.Layouts, FMX.Edit;


procedure RedrawBactery;
procedure RedrawFood;

{procedure RedrawBacteryEllipse;
procedure UpdateEllipse(Number:word);
procedure CreateEllipse(Number:word);}

var
i,j:word;

implementation uses MainUnit, MyUnit;

{
procedure RedrawBacteryEllipse;
begin
for i := 1 to 2000 do if bac[i].alive then if Assigned(Ellipse[i]) then UpdateEllipse(i) else CreateEllipse(i)
end;

procedure UpdateEllipse(Number:word);
begin
with  Ellipse[number] do
  begin
  Position.X:= bac[number].position.X;  Position.Y:= bac[number].position.Y;
  RotationAngle:= bac[number].movement.angle;
  end;
end;

procedure CreateEllipse(Number:word);
begin
  Ellipse[number]:=TEllipse.Create(Form1.Panel1);
  Ellipse[number].Parent:= Form1.Panel1;
  with  Ellipse[number] do
  begin
  Fill.Kind:= TBrushKind.Gradient;// добавить колонии и определять цвет по цвету колонии
  Fill.Gradient.Color:=TAlphaColorRec.Blue;
  Height:=bac[number].info.size*sett.AnimMas ; Width:=bac[number].info.size/2*sett.AnimMas ;
  end;
  UpdateEllipse(Number);
end;
}



procedure RedrawBactery;
begin
Form1.Image1.Bitmap.Canvas.BeginScene;
Form1.Image1.Bitmap.Canvas.Fill.Color :=TAlphaColorRec.Blue;
for i := 1 to sim.BacCount do
  begin
  Form1.Image1.Bitmap.Canvas.DrawPolygon(bac[i].poly, 50);
  Form1.Image1.Bitmap.Canvas.FillPolygon(bac[i].poly, 50);
  end;
Form1.Image1.Bitmap.Canvas.EndScene;
end;

procedure Redrawfood;
var ARect: TRectF; a:byte;
begin
a:=1;
Form1.Image1.Bitmap.Canvas.BeginScene;
Form1.Image1.Bitmap.Canvas.Fill.Color :=TAlphaColorRec.green;
for i := 1 to sim.Foodcount do
  begin
  //ARect:=TRectF.Create(food[i].x-a, food[i].y-a, food[i].x+a, food[i].y+a);
  //Form1.Image1.Bitmap.Canvas.DrawEllipse(ARect,40);
  Form1.Image1.Bitmap.Canvas.FillEllipse(TRectF.Create(food[i].x-a, food[i].y-a, food[i].x+a, food[i].y+a),40);
  end;
Form1.Image1.Bitmap.Canvas.EndScene;
end;
end.
