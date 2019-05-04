unit FormMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Grids,
  Vcl.WinXCtrls, System.Generics.Collections, System.ImageList, Vcl.ImgList, Math;

type
  TfrmMain = class(TForm)
    Panel1: TPanel;
    lblRegula: TLabel;
    cmbCzas: TLabel;
    edtTime: TEdit;
    lblSzerokosc: TLabel;
    edtSzerokosc: TEdit;
    boardImage: TImage;
    btnDraw: TButton;
    edtRuleNo: TEdit;
    cmbRuleType: TComboBox;
    cmbChooseRule2D: TComboBox;
    btnDrawRule2D: TButton;
    TimerRule2D: TTimer;
    btnCleanRefreshGrid: TButton;
    procedure edtTimeChange(Sender: TObject);
    procedure edtSzerokoscChange(Sender: TObject);
    procedure initGridArray;
    procedure FormCreate(Sender: TObject);
    procedure btnDrawClick(Sender: TObject);
    procedure edtRuleNoChange(Sender: TObject);
    procedure drawGrid;
    procedure clearCanvas;
    procedure clearGridArray;
    procedure setCellValue(x, y: Integer);
    function setCellPrintSize(): Integer;
    procedure boardImageClick(Sender: TObject);
    procedure cmbRuleTypeChange(Sender: TObject);
    procedure drawEmptyGrid;
    procedure btnDrawRule2DClick(Sender: TObject);
    procedure TimerRule2DTimer(Sender: TObject);
    procedure btnCleanRefreshGridClick(Sender: TObject);
    procedure cmbChooseRule2DChange(Sender: TObject);
    procedure drawCustom2DRuleGrid(typeOfStructure: String);
  private
    { Private declarations }
  public
    { Public declarations }
  end;
type
  TGridArray = array of array of Integer;
var
  frmMain: TfrmMain;
  gridArray: TGridArray;
  maxWidth, maxTime:Integer;
  bitMap: TBitmap;
type
    TRules = class
    public
     procedure ActivateChoosen1DRules(x, y: Integer);
     procedure rule1D(x, y, leftCellValue, middleCellValue, rightCellValue, trueOrFalse: Integer);
     procedure rule2D;
     function IntToBinLowByte(Value: LongWord): string;
    private
     {}
    end;
 var rules: TRules;
implementation

uses
  System.UITypes;

{$R *.dfm}

procedure TfrmMain.FormCreate(Sender: TObject);
var cellPrintSize: Integer;
begin
  clearCanvas;
  edtSzerokosc.Text := '20';
  edtTime.Text := '10';

  boardImage.Canvas.Pen.Width := 1;

  boardImage.Canvas.Pen.Color := clBlack;

end;


{Section: Draw and set grid/canvas variations}

procedure TfrmMain.initGridArray;
var I,J: Integer;
begin
    gridArray[Round(maxWidth/2)-1][0] := 1;
    for I := 0 to maxTime - 1 do begin
      for J := 0 to maxWidth - 1 do begin
          if cmbRuleType.Text = 'Rule1D' then begin
           rules.ActivateChoosen1DRules(J, I);
          end
      end;
    end;
end;

procedure TfrmMain.clearCanvas;
begin
  boardImage.Canvas.Pen.Color := TAlphaColor($d9d9d9);
  boardImage.Canvas.Brush.Color := TAlphaColor($d9d9d9);
  boardImage.Canvas.Pen.Width := 1;
  boardImage.Canvas.Rectangle(0, 0, boardImage.Width, boardImage.Height);
end;

procedure TfrmMain.clearGridArray;
var I, J: Integer;
begin
      for I := 0 to maxTime - 1 do begin
        for J := 0 to maxWidth - 1 do begin
          gridArray[J][I] := 0;
        end;
      end;
end;

procedure TfrmMain.drawEmptyGrid;
begin
  maxWidth := StrToInt(edtSzerokosc.Text);
  maxTime := StrToInt(edtTime.Text);
  SetLength(gridArray, maxWidth, maxTime);
  clearGridArray;
  boardImage.Canvas.Pen.Width := 1;
  drawGrid;
end;

procedure TfrmMain.drawCustom2DRuleGrid(typeOfStructure: String);
var X, Y: Integer;
begin
  clearGridArray;
  if typeOfStructure = 'losowy' then begin
    for X := 0 to maxWidth - 1 do begin
      for Y := 0 to maxTime - 1 do begin
         gridArray[X][Y] := Random(2);
      end;
    end;
  end
  else if typeOfStructure = 'oscylator' then begin
    for X := 1 to maxWidth - 2 do begin
      for Y := 1 to maxTime - 2 do begin
        if (X mod 4 = 0) and (Y mod 5 = 0) then begin
         gridArray[X][Y] := 1;
         gridArray[X - 1][Y] := 1;
         gridArray[X + 1][Y] := 1;
        end;
      end;
    end;
  end
  else if typeOfStructure = 'niezmienne' then begin
    for X := 1 to maxWidth - 3 do begin
      for Y := 1 to maxTime - 2 do begin
        if (X mod 5 = 0) and (Y mod 5 = 0) then begin
         gridArray[X - 1][Y] := 1;
         gridArray[X + 2][Y] := 1;
         gridArray[X][Y + 1] := 1;
         gridArray[X + 1][Y + 1] := 1;
         gridArray[X][Y - 1] := 1;
         gridArray[X + 1][Y - 1] := 1;
        end;
      end;
    end;
  end
  else if typeOfStructure = 'glider' then begin
    for X := 1 to maxWidth - 3 do begin
      for Y := 1 to maxTime - 2 do begin
        if (X mod 5 = 0) and (Y mod 5 = 0) then begin
         gridArray[X - 1][Y] := 1;
         gridArray[X][Y] := 1;
         gridArray[X][Y + 1] := 1;
         gridArray[X + 1][Y + 1] := 1;
         gridArray[X + 1][Y - 1] := 1;
        end;
      end;
    end;
  end;

  drawGrid;
end;

procedure TfrmMain.drawGrid;
var I, J, startX, startY, cellPrintSize: Integer;
begin
  clearCanvas;
  cellPrintSize := setCellPrintSize();
  startX := 0;
  startY := 0;

   for I := 0 to maxWidth - 1 do begin
     for J := 0 to maxTime - 1 do begin
     startX := I * cellPrintSize;
     startY := J * cellPrintSize;
       if gridArray[I][J] = 1 then begin
          boardImage.Canvas.Pen.Color := clBlack;
          boardImage.Canvas.Brush.Color := clBlack;
          boardImage.Canvas.Rectangle(startX, startY,startX + cellPrintSize, startY + cellPrintSize);
       end
       else if gridArray[I][J] = 0 then begin
          boardImage.Canvas.Pen.Color := clBlack;
          boardImage.Canvas.Brush.Color := clWhite;
          boardImage.Canvas.Rectangle(startX, startY,startX + cellPrintSize, startY + cellPrintSize);
       end;
     end;
  end;
end;


{Section: OnClicks}

procedure TfrmMain.btnCleanRefreshGridClick(Sender: TObject);
begin
  drawEmptyGrid;
end;

procedure TfrmMain.btnDrawClick(Sender: TObject);
var I, J: Integer;
begin
clearCanvas;
maxWidth := StrToInt(edtSzerokosc.Text);
maxTime := StrToInt(edtTime.Text);
SetLength(gridArray, maxWidth, maxTime);
clearGridArray;
initGridArray;
boardImage.Canvas.Pen.Width := 1;
drawGrid;
//
end;

procedure TfrmMain.btnDrawRule2DClick(Sender: TObject);
var I, x, y: Integer;
begin
  if TimerRule2D.Enabled = True then begin
    TimerRule2D.Enabled := False;
  end
  else if TimerRule2D.Enabled = False then begin
    TimerRule2D.Enabled := True;
  end;
  if btnDrawRule2D.Caption = 'Uruchom' then begin
    btnDrawRule2D.Caption := 'Zatrzymaj';
  end
  else if btnDrawRule2D.Caption = 'Zatrzymaj' then begin
    btnDrawRule2D.Caption := 'Uruchom';
  end;

  drawGrid;
end;

procedure TfrmMain.boardImageClick(Sender: TObject);
var
  pt : tPoint;
  x, y,cellLocationScaleX, cellLocationScaleY, cellPrintSize: Integer;
begin
  pt := Mouse.CursorPos;
  pt := ScreenToClient(pt);


  cellPrintSize := setCellPrintSize();

  x := Trunc((pt.X)/cellPrintSize);
  y := Trunc((pt.Y)/cellPrintSize);

  setCellValue(x, y);

  drawGrid;

end;


{Section: OnChange}

procedure TfrmMain.cmbChooseRule2DChange(Sender: TObject);
begin
  if cmbChooseRule2D.Text = 'oscylator' then begin
    drawCustom2DRuleGrid('oscylator');
  end
  else if cmbChooseRule2D.Text = 'glider' then begin
    drawCustom2DRuleGrid('glider');
  end
  else if cmbChooseRule2D.Text = 'rêczna definicja' then begin
    drawEmptyGrid;
  end
  else if cmbChooseRule2D.Text = 'niezmienne' then begin
    drawCustom2DRuleGrid('niezmienne');
  end
  else if cmbChooseRule2D.Text = 'losowy' then begin
     drawCustom2DRuleGrid('losowy');
  end;

end;

procedure TfrmMain.cmbRuleTypeChange(Sender: TObject);
begin
   if cmbRuleType.Text = 'Rule1D' then begin
      clearCanvas;
      drawEmptyGrid;
     lblRegula.Visible := True;
     edtRuleNo.Visible := True;
     btnDraw.Visible := True;
     cmbChooseRule2D.Visible := False;
     btnDrawRule2D.Visible := False;
   end
   else if cmbRuleType.Text = 'Rule2D' then begin
      clearCanvas;
      drawEmptyGrid;
     lblRegula.Visible := False;
     edtRuleNo.Visible := False;
     btnDraw.Visible := False;
     cmbChooseRule2D.Visible := True;
     btnDrawRule2D.Visible := True;
   end;

end;

procedure TfrmMain.edtRuleNoChange(Sender: TObject);
begin
  if edtRuleNo.Text = '' then edtRuleNo.Text := '0';
  if StrToInt(edtRuleNo.Text)>255 then edtRuleNo.Text := '255';

end;

procedure TfrmMain.edtSzerokoscChange(Sender: TObject);
begin
  if edtSzerokosc.Text = '' then edtSzerokosc.Text := '0';
end;

procedure TfrmMain.edtTimeChange(Sender: TObject);
begin
  if edtTime.Text = '' then edtTime.Text := '0';
end;


{Section: Other functions}
function TfrmMain.setCellPrintSize(): Integer;
var scaleX, scaleY: Integer;
begin
  scaleX := Trunc(boardImage.Width/maxWidth);
  scaleY := Trunc(boardImage.Height/maxTime);
  Result := Min(scaleX, scaleY);
end;

procedure TfrmMain.setCellValue(x, y: Integer);
begin
  if gridArray[x][y] = 0 then begin
    gridArray[x][y] := 1
  end
  else if gridArray[x][y] = 1 then begin
    gridArray[x][y] := 0;
  end;
end;

procedure TfrmMain.TimerRule2DTimer(Sender: TObject);
var x, y: Integer;
    temp: Boolean;
begin
  rules.rule2D;
  drawGrid;
end;

{
TRules
}

procedure TRules.ActivateChoosen1DRules(x, y: Integer);
  var I: Integer;
      binaryRuleValueArray: string;
  begin
     binaryRuleValueArray := IntToBinLowByte(StrToInt(frmMain.edtRuleNo.Text));
          rules.rule1D(x, y, 0, 0 ,0, StrToInt(binaryRuleValueArray[8]));
          rules.rule1D(x, y, 0, 0 ,1, StrToInt(binaryRuleValueArray[7]));
          rules.rule1D(x, y, 0, 1 ,0, StrToInt(binaryRuleValueArray[6]));
          rules.rule1D(x, y, 0, 1 ,1, StrToInt(binaryRuleValueArray[5]));
          rules.rule1D(x, y, 1, 0 ,0, StrToInt(binaryRuleValueArray[4]));
          rules.rule1D(x, y, 1, 0 ,1, StrToInt(binaryRuleValueArray[3]));
          rules.rule1D(x, y, 1, 1 ,0, StrToInt(binaryRuleValueArray[2]));
          rules.rule1D(x, y, 1, 1 ,1, StrToInt(binaryRuleValueArray[1]));
end;

function TRules.IntToBinLowByte(Value: LongWord): string;
var
  i: Integer;
begin
  SetLength(Result, 8);
  for i := 1 to 8 do begin
    if ((Value shl (24+i-1)) shr 31) = 0 then begin
      Result[i] := '0'
    end else begin
      Result[i] := '1';
    end;
  end;
end;

procedure TRules.rule1D(x, y, leftCellValue, middleCellValue, rightCellValue, trueOrFalse: Integer);
  begin

    if x = 0 then begin
      if (gridArray[maxWidth -1][y] = leftCellValue) and (gridArray[x, y] = middleCellValue) and (gridArray[x + 1, y] = rightCellValue) then begin
         gridArray[x][y+1] := trueOrFalse;
      end;
    end
    else if x = maxWidth -1 then begin
      if (gridArray[x - 1][y] = leftCellValue) and (gridArray[x][y] = middleCellValue) and (gridArray[0][y] = rightCellValue) then begin
         gridArray[x][y+1] := trueOrFalse;
      end;
    end
    else
    begin
      if ((gridArray[x - 1][y] = leftCellValue) and (gridArray[x][y] = middleCellValue) and (gridArray[x + 1][y] = rightCellValue)) then begin
          gridArray[x, y + 1] := trueOrFalse;
      end;
    end;
  end;

procedure TRules.rule2D;
var nextGridArray: TGridArray;
  X, Y, I, J, neighbours: Integer;
 begin
  SetLength(nextGridArray, maxWidth, maxTime);
  // starting from 1s and subsiding 2 to dont care about boundary conditions
  for X := 1 to maxWidth - 2 do begin
    for Y := 1 to maxTime - 2 do begin
    neighbours := 0;
      //small loops to check neighbourhood of choosen cell
      for I := - 1 to 1 do begin
        for J := -1 to 1 do begin
           neighbours := neighbours + gridArray[X + I][Y + J];
        end;
      end;

      neighbours := neighbours - gridArray[X][Y];
      //rules of Game Of Life
      if (gridArray[X][Y] = 1) and (neighbours < 2) then begin
       nextGridArray[X][Y] := 0;
      end
      else if (gridArray[X][Y] = 1) and (neighbours > 3) then begin
       nextGridArray[X][Y] := 0;
      end
      else if (gridArray[X][Y] = 0) and (neighbours = 3) then begin
       nextGridArray[X][Y] := 1;
      end
      else begin
        nextGridArray[X][Y] := gridArray[X][Y];
      end;


    end;

  end;
  gridArray := nextGridArray;
end;
end.
