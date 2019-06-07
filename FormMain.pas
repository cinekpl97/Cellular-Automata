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
    cmbGrainGrowth: TComboBox;
    cmbChooseGrainLocations: TComboBox;
    btnDrawGrainGrowth: TButton;
    TimerGrainGrowth: TTimer;
    cmbBoundaryConditions: TComboBox;
    edtRowCellAmount: TEdit;
    edtColumnCellAmount: TEdit;
    edtRandomAmount: TEdit;
    cmbHexagonalType: TComboBox;
    edtLocationRadius: TEdit;
    edtGrainGrowthRadiation: TEdit;
    btnMonteCarlo: TButton;
    cmbDrawGridOrEnergy: TComboBox;
    procedure edtTimeChange(Sender: TObject);
    procedure edtSzerokoscChange(Sender: TObject);
    procedure initGridArray;
    procedure FormCreate(Sender: TObject);
    procedure btnDrawClick(Sender: TObject);
    procedure edtRuleNoChange(Sender: TObject);
    procedure SetColor;
    procedure drawColourGrid;
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
    function mostFrequentValue(valuesArray: TArray<Integer>): Integer;
    procedure TimerGrainGrowthTimer(Sender: TObject);
    procedure btnDrawGrainGrowthClick(Sender: TObject);
    procedure cmbChooseGrainLocationsChange(Sender: TObject);
    procedure edtRowCellAmountChange(Sender: TObject);
    procedure edtColumnCellAmountChange(Sender: TObject);
    procedure cmbGrainGrowthChange(Sender: TObject);
    procedure btnMonteCarloClick(Sender: TObject);
    function countCellEnergy(X, Y: Integer): Integer;
    function getRandomNeighbourValue(X, Y: Integer): Integer;
    procedure drawEnergy;
    procedure cmbDrawGridOrEnergyChange(Sender: TObject);

  private
    { Private declarations }
  public
    { Public declarations }
  end;

  type
  TCellObject = class
    public
   value: Integer;
   amount: Integer;
   x, y : Integer;
   centerOfGravityX : Double;
   centerOfGravityY : Double;
   energy: Integer;
   ifMonteCarloChecked : Boolean;
   densityOfDislocation: Integer;
   recrystallization: Boolean;
   constructor Create( val : Integer = 0; amou : Integer = 0; x : Integer = 0; y : Integer = 0; centerOfGravityX : Double = 0; centerOfGravityY : Double = 0);
  end;

  type
  TGridArray = array of array of TCellObject;
var
  frmMain: TfrmMain;
  gridArray: TGridArray;
  maxWidth, maxTime:Integer;
  bitMap: TBitmap;
  FColorList : TList<TColor>;
type
    TRules = class
    public
     procedure ActivateChoosen1DRules(x, y: Integer);
     procedure rule1D(x, y, leftCellValue, middleCellValue, rightCellValue, trueOrFalse: Integer);
     procedure rule2D;
     procedure ruleVonNeumann;
     procedure Moore;
     procedure pentagonal;
     procedure hexagonal;
     procedure withRadius;
     procedure monteCarlo;
     function IntToBinLowByte(Value: LongWord): string;
     function modulo(x, m: Integer): Integer;
    private
     {}
    end;
 var rules: TRules;

 type TCoordinates = class
   public
   x, y : Integer;
   function countIfRadiusFromOtherPointHigher(pPoint : TCoordinates; userChoosenRadius : Integer):Boolean;
 end;


implementation

uses
  System.UITypes;

{$R *.dfm}

constructor TCellObject.Create( val : Integer = 0; amou : Integer = 0; x : Integer = 0; y : Integer = 0; centerOfGravityX : Double = 0; centerOfGravityY : Double = 0);
var positions : Double;
begin
  value := val;
  amount := amou;
  Self.x := x;
  Self.y := y;
  Self.ifMonteCarloChecked := False;
  positions := Random(3) - 1;
  if positions <> 0 then positions := positions/2;
  Self.centerOfGravityX := positions;
  positions := Random(3) - 1;
  if positions <> 0 then positions := positions/2;
  Self.centerOfGravityY := positions;
end;

procedure TfrmMain.FormCreate(Sender: TObject);
var cellPrintSize: Integer;
begin
  clearCanvas;
  edtSzerokosc.Text := '20';
  edtTime.Text := '10';

  boardImage.Canvas.Pen.Width := 1;

  boardImage.Canvas.Pen.Color := clBlack;
  FColorList := TList<TColor>.Create;
  FColorList.Add(clWhite);
  FColorList.Add(clBlack);
end;


{Section: Draw and set grid/canvas variations}

procedure TfrmMain.initGridArray;
var I,J: Integer;
begin
    gridArray[Round(maxWidth/2)-1][0].value := 1;
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
          gridArray[J][I] := TCellObject.Create;
        end;
      end;

      for I := 0 to maxTime - 1 do begin
        for J := 0 to maxWidth - 1 do begin
          gridArray[J][I].value := 0;
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
  drawColourGrid;
end;

procedure TfrmMain.drawCustom2DRuleGrid(typeOfStructure: String);
var X, Y: Integer;
begin
  clearGridArray;
  if typeOfStructure = 'losowy' then begin
    for X := 0 to maxWidth - 1 do begin
      for Y := 0 to maxTime - 1 do begin
         gridArray[X][Y].value := Random(2);
      end;
    end;
  end
  else if typeOfStructure = 'oscylator' then begin
    for X := 1 to maxWidth - 2 do begin
      for Y := 1 to maxTime - 2 do begin
        if (X mod 4 = 0) and (Y mod 5 = 0) then begin
         gridArray[X][Y].value := 1;
         gridArray[X - 1][Y].value := 1;
         gridArray[X + 1][Y].value := 1;
        end;
      end;
    end;
  end
  else if typeOfStructure = 'niezmienne' then begin
    for X := 1 to maxWidth - 3 do begin
      for Y := 1 to maxTime - 2 do begin
        if (X mod 5 = 0) and (Y mod 5 = 0) then begin
         gridArray[X - 1][Y].value := 1;
         gridArray[X + 2][Y].value := 1;
         gridArray[X][Y + 1].value := 1;
         gridArray[X + 1][Y + 1].value := 1;
         gridArray[X][Y - 1].value := 1;
         gridArray[X + 1][Y - 1].value := 1;
        end;
      end;
    end;
  end
  else if typeOfStructure = 'glider' then begin
    for X := 1 to maxWidth - 3 do begin
      for Y := 1 to maxTime - 2 do begin
        if (X mod 5 = 0) and (Y mod 5 = 0) then begin
         gridArray[X - 1][Y].value := 1;
         gridArray[X][Y].value := 1;
         gridArray[X][Y + 1].value := 1;
         gridArray[X + 1][Y + 1].value := 1;
         gridArray[X + 1][Y - 1].value := 1;
        end;
      end;
    end;
  end;

  drawColourGrid;
end;

procedure TfrmMain.SetColor;
var
  randomColor : TColor;
  I: Integer;
  isNew : Boolean;
begin
  randomColor := RGB(Random(255), Random(255), Random(255));
  isNew := False;

  while not isNew do begin
    for I := 0 to FColorList.Count - 1 do begin
      if randomColor = FColorList[I] then begin
        randomColor := RGB(Random(255), Random(255), Random(255));
        break;
      end;
    end;
    isNew := True;
  end;
  FColorList.Add(randomColor);
end;

procedure TfrmMain.drawColourGrid;
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
          boardImage.Canvas.Pen.Color := clBlack;
          boardImage.Canvas.Brush.Color := FColorList[gridArray[I][J].value];
          boardImage.Canvas.Rectangle(startX, startY,startX + cellPrintSize, startY + cellPrintSize);
         end
       end;
  end;

procedure TfrmMain.drawEnergy;
var I, J, startX, startY, cellPrintSize, energyValue: Integer;
    FColorEnergyList: TList<TColor>;
begin
  clearCanvas;
  cellPrintSize := setCellPrintSize();
  FColorEnergyList := TList<TColor>.Create;
  FColorEnergyList.Add(RGB(255, 204, 204));
  FColorEnergyList.Add(RGB(255, 153, 153));
  FColorEnergyList.Add(RGB(255, 102, 102));
  FColorEnergyList.Add(RGB(255, 51, 51));
  FColorEnergyList.Add(RGB(243, 0, 0));
  FColorEnergyList.Add(RGB(190, 0, 0));
  FColorEnergyList.Add(RGB(140, 0, 0));
  FColorEnergyList.Add(RGB(50, 0, 0));

  startX := 0;
  startY := 0;
   for I := 0 to maxWidth - 1 do begin
      for J := 0 to maxTime - 1 do begin
       startX := I * cellPrintSize;
       startY := J * cellPrintSize;
       boardImage.Canvas.Pen.Color := clBlack;
//       energyValue := countCellEnergy(I, J);
       boardImage.Canvas.Brush.Color := FColorEnergyList[gridArray[I][J].energy];
       boardImage.Canvas.Rectangle(startX, startY,startX + cellPrintSize, startY + cellPrintSize);
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
drawColourGrid;
//
end;

procedure TfrmMain.btnDrawGrainGrowthClick(Sender: TObject);
begin
  if TimerGrainGrowth.Enabled = True then begin
    TimerGrainGrowth.Enabled := False;
  end
  else if TimerGrainGrowth.Enabled = False then begin
    TimerGrainGrowth.Enabled := True;
  end;
  if btnDrawGrainGrowth.Caption = 'Rysuj' then begin
    btnDrawGrainGrowth.Caption := 'Zatrzymaj';
  end
  else if btnDrawGrainGrowth.Caption = 'Zatrzymaj' then begin
    btnDrawGrainGrowth.Caption := 'Rysuj';
  end;

  drawColourGrid;
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

  drawColourGrid;
end;

procedure TfrmMain.btnMonteCarloClick(Sender: TObject);
begin
  rules.monteCarlo;
  drawColourGrid;
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
  SetColor;
  drawColourGrid;

end;



{Section: OnChange}

procedure TfrmMain.cmbChooseGrainLocationsChange(Sender: TObject);
var X, Y, I, J, trueOrFalse, counter, xLocationStep, yLocationStep, distance: Integer;
    cellsList : TList<TCellObject>;
    ifRadiusOK : Boolean;
    coordinatesNew, coordinatesOld : TCoordinates;
begin
  counter := 1;
  clearGridArray;
  clearCanvas;
  if edtColumnCellAmount.Text = '' then edtColumnCellAmount.Text := '1';
  if edtRowCellAmount.Text = '' then edtRowCellAmount.Text := '1';
  if cmbChooseGrainLocations.Text = 'jednorodne' then begin
    edtRowCellAmount.Visible := True;
    edtColumnCellAmount.Visible := True;
    edtRandomAmount.Visible := False;
    edtGrainGrowthRadiation.Visible := False;
    xLocationStep := Trunc(maxWidth/(StrToInt(edtRowCellAmount.Text) + 1));
    yLocationStep := Trunc(maxTime/(StrToInt(edtColumnCellAmount.Text) + 1));
    for I := 1 to StrToInt(edtRowCellAmount.Text) do begin
      for J := 1 to StrToInt(edtColumnCellAmount.Text) do begin
        gridArray[I*xLocationStep - 1][J*yLocationStep - 1].value := counter;
        SetColor;
        counter := counter + 1;
      end;
    end;

  end
  else if cmbChooseGrainLocations.Text = 'losowe' then begin
    edtRowCellAmount.Visible := False;
    edtColumnCellAmount.Visible := False;
    edtRandomAmount.Visible := True;
    edtGrainGrowthRadiation.Visible := False;
    counter := 1;
    for X := 0 to maxWidth - 1 do begin
      for Y := 0 to maxTime - 1 do begin
        trueOrFalse := Random(20); //probability 1/20 to draw colour
        if trueOrFalse = 1 then begin
          if (StrToInt(edtRandomAmount.Text) >= counter) then begin
           gridArray[X][Y].value := counter;
           SetColor;
           counter := counter + 1;
          end;
        end;
      end;
    end;
  end
  else if cmbChooseGrainLocations.Text = 'z promieniem' then begin
    edtRowCellAmount.Visible := False;
    edtColumnCellAmount.Visible := False;
    edtRandomAmount.Visible := True;
    edtLocationRadius.Visible := True;
    edtGrainGrowthRadiation.Visible := False;
    counter := 1;
    cellsList := TList<TCellObject>.Create;
    ifRadiusOk := True;
    coordinatesOld := TCoordinates.Create;
    coordinatesNew := TCoordinates.Create;
    if (edtRandomAmount.Text <> '0') and (edtLocationRadius.Text <> '0') then begin
      while counter < StrToInt(edtRandomAmount.Text) do begin
         for X := 0 to maxWidth - 1 do begin
          for Y := 0 to maxTime - 1 do begin
            for I := 0 to cellsList.Count - 1 do begin
              coordinatesNew.x := X;
              coordinatesNew.y := Y;
              coordinatesOld.x := cellsList[I].x;
              coordinatesOld.y := cellsList[I].y;
              if coordinatesNew.countIfRadiusFromOtherPointHigher(coordinatesOld, StrToInt(edtLocationRadius.Text)) then begin
                ifRadiusOk := True;
              end
              else begin
                ifRadiusOk := False;
                break;
              end;
            end;

            if (ifRadiusOk) and (counter <= StrToInt(edtRandomAmount.Text)) then begin
             gridArray[X][Y].value := counter;
             gridArray[X][Y].x := X;
             gridArray[X][Y].y := Y;
             SetColor;
             cellsList.Add(gridArray[X][Y]);
             counter := counter + 1;
             if counter = StrToInt(edtRandomAmount.Text) then break;
             ifRadiusOk := False;
            end;
          end;
         end;
      end;

      

    end;

  end;
  drawColourGrid;

end;

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

procedure TfrmMain.cmbDrawGridOrEnergyChange(Sender: TObject);
begin
  if cmbDrawGridOrEnergy.Text = 'siatka' then begin
    drawColourGrid;
  end else if cmbDrawGridOrEnergy.Text = 'energia' then begin
    drawEnergy;
  end;


end;

procedure TfrmMain.cmbGrainGrowthChange(Sender: TObject);
begin
  if cmbGrainGrowth.Text = 'heksagonalne' then begin
    cmbHexagonalType.Visible := True;
    edtGrainGrowthRadiation.Visible := False;
  end else if cmbGrainGrowth.Text = 'z promieniem' then begin
    edtGrainGrowthRadiation.Visible := True;
    cmbHexagonalType.Visible := False;
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

     cmbGrainGrowth.Visible := False;
     cmbChooseGrainLocations.Visible := False;
     btnDrawGrainGrowth.Visible := False;

     btnMonteCarlo.Visible := False;
   end
   else if cmbRuleType.Text = 'Rule2D' then begin
      clearCanvas;
      drawEmptyGrid;
     lblRegula.Visible := False;
     edtRuleNo.Visible := False;
     btnDraw.Visible := False;
     cmbChooseRule2D.Visible := True;
     btnDrawRule2D.Visible := True;

     cmbGrainGrowth.Visible := False;
     cmbChooseGrainLocations.Visible := False;
     btnDrawGrainGrowth.Visible := False;

     btnMonteCarlo.Visible := False;
   end
   else if cmbRuleType.Text = 'Rozrost Ziaren' then begin
     clearCanvas;
     drawEmptyGrid;
     lblRegula.Visible := False;
     edtRuleNo.Visible := False;
     btnDraw.Visible := False;
     cmbChooseRule2D.Visible := False;
     btnDrawRule2D.Visible := False;
     cmbGrainGrowth.Visible := True;
     cmbChooseGrainLocations.Visible := True;
     btnDrawGrainGrowth.Visible := True;
     btnMonteCarlo.Visible := False;
   end
   else if cmbRuleType.Text = 'Monte Carlo' then begin
     lblRegula.Visible := False;
     edtRuleNo.Visible := False;
     btnDraw.Visible := False;
     cmbChooseRule2D.Visible := False;
     btnDrawRule2D.Visible := False;
     cmbGrainGrowth.Visible := True;
     cmbChooseGrainLocations.Visible := True;
     btnDrawGrainGrowth.Visible := True;
     btnMonteCarlo.Visible := True;
   end;


end;

procedure TfrmMain.edtColumnCellAmountChange(Sender: TObject);
begin
  if edtColumnCellAmount.Text = '' then edtColumnCellAmount.Text := '1';
end;

procedure TfrmMain.edtRowCellAmountChange(Sender: TObject);
begin
  if edtRowCellAmount.Text = '' then edtRowCellAmount.Text := '1';
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
if cmbRuleType.Text = 'Rule2D' then begin
  if gridArray[x][y].value = 0 then begin
    gridArray[x][y].value := 1
  end
  else if gridArray[x][y].value = 1 then begin
    gridArray[x][y].value := 0;
  end;
end else if cmbRuleType.Text = 'Rozrost Ziaren' then begin
   gridArray[x][y].value := gridArray[x][y].value + 1;
end;



end;

procedure TfrmMain.TimerGrainGrowthTimer(Sender: TObject);
begin
  if cmbGrainGrowth.Text = 'von Neumann' then begin
    rules.ruleVonNeumann;
  end else if cmbGrainGrowth.Text = 'Moore' then begin
   rules.Moore;
  end else if cmbGrainGrowth.Text = 'pentagonalne losowe' then begin
    rules.pentagonal;
  end else if cmbGrainGrowth.Text = 'heksagonalne' then begin
    rules.hexagonal;
  end;
  drawColourGrid;
end;

procedure TfrmMain.TimerRule2DTimer(Sender: TObject);
var x: Integer;
begin
  rules.rule2D;
  drawColourGrid;
end;

function TfrmMain.mostFrequentValue(valuesArray: TArray<Integer>): Integer;
var
  I, Key, maxValue, frequency: Integer;
  dictionaryOfValues: TDictionary<Integer, Integer>;
  maxList: TList<Integer>;
  isValueFound: Boolean;
begin

    dictionaryOfValues := TDictionary<Integer, Integer>.Create;
    for I := 0 to Length(valuesArray) - 1 do begin
      Key := valuesArray[I];
      if (dictionaryOfValues.ContainsKey(Key)) and (Key <> 0) then begin
        frequency := dictionaryOfValues[Key];
        frequency := frequency + 1;
        dictionaryOfValues.AddOrSetValue(Key, frequency);
      end else begin
        if Key <> 0 then dictionaryOfValues.Add(Key, 1);
      end;
    end;

    maxValue := 0;
    Result := 0;
    for Key in dictionaryOfValues.Keys do begin
      if maxValue < dictionaryOfValues[Key] then begin
        Result := Key;
        maxValue := dictionaryOfValues[Key];
      end;
    end;
end;

function TCoordinates.countIfRadiusFromOtherPointHigher(pPoint: TCoordinates; userChoosenRadius : Integer):Boolean;
begin
    if Power(Self.x - pPoint.x, 2) + Power(Self.y - pPoint.y, 2) <= Power(userChoosenRadius, 2) then begin
    Result := False;
   end
    else Result := True;
end;

function TfrmMain.countCellEnergy(X: Integer; Y: Integer): Integer;
var leftCell, rightCell, topCell, bottomCell, I, J, counter, neighboursCounter, xCell, yCell, xFirstCorner, yFirstCorner, xSecondCorner, ySecondCorner: Integer;
neighbourCellsArray: TArray<Integer>;
 begin
  if cmbGrainGrowth.Text = 'von Neumann' then begin
      counter := 0;
      neighbourCellsArray := TArray<Integer>.Create(0, 0, 0, 0);
      //tutaj dodaæ opcjê absorpcja albo nie
      if frmMain.cmbBoundaryConditions.Text = 'absorpcyjne' then begin
        leftCell := X - 1;
        rightCell := X + 1;
        topCell := Y - 1;
        bottomCell := Y + 1;
        if X - 1 < 0 then leftCell := 0;
        if X + 1 >= maxWidth then rightCell := maxWidth - 1;
        if Y + 1 >= maxTime then bottomCell := maxTime - 1;
        if Y - 1 < 0 then topCell := 0;
      end
      else if frmMain.cmbBoundaryConditions.Text = 'periodyczne' then begin
        leftCell := rules.modulo(X - 1, maxWidth);
        rightCell := rules.modulo(X + 1, maxWidth);
        topCell := rules.modulo(Y + 1, maxTime);
        bottomCell := rules.modulo(Y - 1, maxTime);
      end;

     neighbourCellsArray[0] := gridArray[leftCell][rules.modulo(Y, maxTime)].value;
     neighbourCellsArray[1] := gridArray[rules.modulo(X, maxWidth)][topCell].value;
     neighbourCellsArray[2] := gridArray[rightCell][rules.modulo(Y, maxTime)].value;
     neighbourCellsArray[3] := gridArray[rules.modulo(X, maxWidth)][bottomCell].value;

     for I := 0 to Length(neighbourCellsArray) - 1 do begin
       if neighbourCellsArray[I] <> gridArray[X][Y].value then begin
         counter := counter + 1;
       end;
     end;
     Result := counter;


  end else if cmbGrainGrowth.Text = 'Moore' then begin
      counter := 0;
      neighbourCellsArray := TArray<Integer>.Create(0, 0, 0, 0, 0, 0, 0, 0);
        for I := -1 to 1 do begin
          for J := -1 to 1 do begin
            if frmMain.cmbBoundaryConditions.Text = 'absorpcyjne' then begin
              xCell := rules.modulo(X + I, maxWidth);
              yCell := rules.modulo(Y + J, maxTime);
              if X + I <= 0 then xCell := 0;
              if X + I > maxWidth - 1 then xCell := maxWidth - 1;
              if Y + J > maxTime - 1 then yCell := maxTime - 1;
              if Y + J < 0 then yCell := 0;
              if not ((I = 0) and (J = 0)) then begin
                if gridArray[xCell][yCell].value <> gridArray[X][Y].value then begin
                  counter := counter + 1;
                end;
              end;
            end
            else if frmMain.cmbBoundaryConditions.Text = 'periodyczne' then begin
              if not ((I = 0) and (J = 0)) then begin
                if gridArray[rules.modulo(X + I, maxWidth)][rules.modulo(Y + J, maxTime)].value <> gridArray[X][Y].value then begin
                  counter := counter + 1;
                end;
              end;
            end;
         end;
        end;

        Result := counter;

  end else if cmbGrainGrowth.Text = 'heksagonalne' then begin
        counter := 0;
        neighbourCellsArray := TArray<Integer>.Create(0, 0, 0, 0, 0, 0);

    if frmMain.cmbHexagonalType.Text = 'lewo' then begin
      xFirstCorner := -1;
      yFirstCorner := 1;

      xSecondCorner := 1;
      ySecondCorner := -1;

    end else if frmMain.cmbHexagonalType.Text = 'prawo' then begin
      xFirstCorner := -1;
      yFirstCorner := -1;

      xSecondCorner := 1;
      ySecondCorner := 1;

    end else if frmMain.cmbHexagonalType.Text = 'losowe' then begin
      if Random(2) = 0 then begin
        xFirstCorner := -1;
        yFirstCorner := 1;

        xSecondCorner := 1;
        ySecondCorner := -1;
      end else begin
        xFirstCorner := -1;
        yFirstCorner := -1;

        xSecondCorner := 1;
        ySecondCorner := 1;
      end;


    end;

        neighboursCounter := 0;
    for I := -1 to 1 do begin
      for J := -1 to 1 do begin
        if not (((I = 0) and (J = 0)) or ((I = xFirstCorner) and (J = yFirstCorner))
          or ((I = xSecondCorner) and (J = ySecondCorner))) then begin
          if frmMain.cmbBoundaryConditions.Text = 'absorpcyjne' then begin
          xCell := rules.modulo(X + I, maxWidth);
          yCell := rules.modulo(Y + J, maxTime);
          if X + I <= 0 then xCell := 0;
          if X + I > maxWidth - 1 then xCell := maxWidth - 1;
          if Y + J > maxTime - 1 then yCell := maxTime - 1;
          if Y + J < 0 then yCell := 0;
          if gridArray[xCell][yCell].value <> gridArray[X][Y].value then begin
           counter := counter + 1;
          end;

          end else if frmMain.cmbBoundaryConditions.Text = 'periodyczne' then begin
            if gridArray[rules.modulo(X + I, maxWidth)][rules.modulo(Y + J, maxTime)].value <> gridArray[X][Y].value then counter := counter + 1;
          end;
        end;
     end;

    end;
    Result := counter;

  end else if cmbGrainGrowth.Text = 'pentagonalne losowe' then begin
      counter := 0;
//      neighbourCellsArray := TArray<Integer>.Create(0, 0, 0, 0, 0);
//  //needed to set random which row/column to cut
//  leftColumn := -1;
//  rightColumn := 1;
//  topRow := 1;
//  bottomRow := -1;
//  //setting cut values
//  exceptionRowOrColumnNumber := Random(2);
//  RowOrColumn := Random(2);
//  //each if means which row or column to cut, there are four possibilities
//  if (exceptionRowOrColumnNumber = 0) and (RowOrColumn = 0) then begin
//    bottomRow := 0;
//  end else if (exceptionRowOrColumnNumber = 1) and (RowOrColumn = 0) then begin
//    topRow := 0;
//  end else if (exceptionRowOrColumnNumber = 0) and (RowOrColumn = 1) then begin
//    leftColumn := 0;
//  end else if (exceptionRowOrColumnNumber = 1) and (RowOrColumn = 1) then begin
//    rightColumn := 0;
//  end;
//
//  for X := 0 to maxWidth - 1 do begin
//      for Y := 0 to maxTime - 1 do begin
//      neighboursCounter := 0;
//  // I and J are limited not to check neighbours for one column or row
//        for I := leftColumn to rightColumn do begin
//          for J := bottomRow to topRow do begin
//            if frmMain.cmbBoundaryConditions.Text = 'absorpcyjne' then begin
//              xCell := modulo(X + I, maxWidth);
//              yCell := modulo(Y + J, maxTime);
//              if X + I <= 0 then xCell := 0;
//              if X + I > maxWidth - 1 then xCell := maxWidth - 1;
//              if Y + J > maxTime - 1 then yCell := maxTime - 1;
//              if Y + J < 0 then yCell := 0;
//              if not ((I = 0) and (J = 0)) then begin
//
//                neighbourCellsArray[neighboursCounter] := gridArray[xCell][yCell].value;
//                neighboursCounter := neighboursCounter + 1;
//              end;
//            end
//            else if frmMain.cmbBoundaryConditions.Text = 'periodyczne' then begin
//              if not ((I = 0) and (J = 0)) then begin
//                neighbourCellsArray[neighboursCounter] := gridArray[modulo(X + I, maxWidth)][modulo(Y + J, maxTime)].value;
//                neighboursCounter := neighboursCounter + 1;
//              end;
//            end;
//         end;
//        end;
//
//        if gridArray[X][Y].value = 0 then begin
//         nextGridArray[X][Y].value := frmMain.mostFrequentValue(neighbourCellsArray);
//        end else begin
//         nextGridArray[X][Y].value := gridArray[X][Y].value;
//        end;
//
//      end;
//  end;
  end;
end;

function TfrmMain.getRandomNeighbourValue(X: Integer; Y: Integer): Integer;
var leftCell, rightCell, topCell, bottomCell, I, J, counter, neighboursCounter, xCell, yCell, rand, xFirstCorner, yFirstCorner, xSecondCorner, ySecondCorner: Integer;
neighbourCellsArray: TArray<Integer>;
begin
  if cmbGrainGrowth.Text = 'von Neumann' then begin
      counter := 0;
      neighbourCellsArray := TArray<Integer>.Create(0, 0, 0, 0);
      //tutaj dodaæ opcjê absorpcja albo nie
      if frmMain.cmbBoundaryConditions.Text = 'absorpcyjne' then begin
        leftCell := X - 1;
        rightCell := X + 1;
        topCell := Y - 1;
        bottomCell := Y + 1;
        if X - 1 < 0 then leftCell := 0;
        if X + 1 >= maxWidth then rightCell := maxWidth - 1;
        if Y + 1 >= maxTime then bottomCell := maxTime - 1;
        if Y - 1 < 0 then topCell := 0;
      end
      else if frmMain.cmbBoundaryConditions.Text = 'periodyczne' then begin
        leftCell := rules.modulo(X - 1, maxWidth);
        rightCell := rules.modulo(X + 1, maxWidth);
        topCell := rules.modulo(Y + 1, maxTime);
        bottomCell := rules.modulo(Y - 1, maxTime);
      end;

     neighbourCellsArray[0] := gridArray[leftCell][rules.modulo(Y, maxTime)].value;
     neighbourCellsArray[1] := gridArray[rules.modulo(X, maxWidth)][topCell].value;
     neighbourCellsArray[2] := gridArray[rightCell][rules.modulo(Y, maxTime)].value;
     neighbourCellsArray[3] := gridArray[rules.modulo(X, maxWidth)][bottomCell].value;
     Randomize;
     rand := Random(4);
     Result := neighbourCellsArray[rand];


  end else if cmbGrainGrowth.Text = 'Moore' then begin
      counter := 0;
      neighbourCellsArray := TArray<Integer>.Create(0, 0, 0, 0, 0, 0, 0, 0);
        for I := -1 to 1 do begin
          for J := -1 to 1 do begin
            if frmMain.cmbBoundaryConditions.Text = 'absorpcyjne' then begin
              xCell := rules.modulo(X + I, maxWidth);
              yCell := rules.modulo(Y + J, maxTime);
              if X + I <= 0 then xCell := 0;
              if X + I > maxWidth - 1 then xCell := maxWidth - 1;
              if Y + J > maxTime - 1 then yCell := maxTime - 1;
              if Y + J < 0 then yCell := 0;
              if not ((I = 0) and (J = 0)) then begin
                neighbourCellsArray[neighboursCounter] := gridArray[xCell][yCell].value;
                neighboursCounter := neighboursCounter + 1;
              end;
            end
            else if frmMain.cmbBoundaryConditions.Text = 'periodyczne' then begin
              if not ((I = 0) and (J = 0)) then begin
                neighbourCellsArray[neighboursCounter] := gridArray[rules.modulo(X + I, maxWidth)][rules.modulo(Y + J, maxTime)].value;
                neighboursCounter := neighboursCounter + 1;
              end;
            end;
         end;
        end;
        Randomize;
         rand := Random(8);
         Result := neighbourCellsArray[rand];
  end else if cmbGrainGrowth.Text = 'heksagonalne' then begin
  //hexagonal has only 6 neighbours
  neighbourCellsArray := TArray<Integer>.Create(0, 0, 0, 0, 0, 0);

    if frmMain.cmbHexagonalType.Text = 'lewo' then begin
      xFirstCorner := -1;
      yFirstCorner := 1;

      xSecondCorner := 1;
      ySecondCorner := -1;

    end else if frmMain.cmbHexagonalType.Text = 'prawo' then begin
      xFirstCorner := -1;
      yFirstCorner := -1;

      xSecondCorner := 1;
      ySecondCorner := 1;

    end else if frmMain.cmbHexagonalType.Text = 'losowe' then begin
      if Random(2) = 0 then begin
        xFirstCorner := -1;
        yFirstCorner := 1;

        xSecondCorner := 1;
        ySecondCorner := -1;
      end else begin
        xFirstCorner := -1;
        yFirstCorner := -1;

        xSecondCorner := 1;
        ySecondCorner := 1;
      end;
    end;

    neighboursCounter := 0;
      for I := -1 to 1 do begin
        for J := -1 to 1 do begin
          if not (((I = 0) and (J = 0)) or ((I = xFirstCorner) and (J = yFirstCorner))
            or ((I = xSecondCorner) and (J = ySecondCorner))) then begin
            if frmMain.cmbBoundaryConditions.Text = 'absorpcyjne' then begin
            xCell := rules.modulo(X + I, maxWidth);
            yCell := rules.modulo(Y + J, maxTime);
            if X + I <= 0 then xCell := 0;
            if X + I > maxWidth - 1 then xCell := maxWidth - 1;
            if Y + J > maxTime - 1 then yCell := maxTime - 1;
            if Y + J < 0 then yCell := 0;
              neighbourCellsArray[neighboursCounter] := gridArray[xCell][yCell].value;
              neighboursCounter := neighboursCounter + 1;
          end
          else if frmMain.cmbBoundaryConditions.Text = 'periodyczne' then begin
              neighbourCellsArray[neighboursCounter] := gridArray[rules.modulo(X + I, maxWidth)][rules.modulo(Y + J, maxTime)].value;
              neighboursCounter := neighboursCounter + 1;
          end;
          end;
       end;
      end;
     Randomize;
     rand := Random(6);
     Result := neighbourCellsArray[rand];
  end else if cmbGrainGrowth.Text = 'pentagonalne losowe' then begin

  end;
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
      if (gridArray[maxWidth - 1][y].value = leftCellValue) and (gridArray[x, y].value = middleCellValue) and (gridArray[x + 1, y].value = rightCellValue) then begin
         gridArray[x][y+1].value := trueOrFalse;
      end;
    end
    else if x = maxWidth - 1 then begin
      if (gridArray[x - 1][y].value = leftCellValue) and (gridArray[x][y].value = middleCellValue) and (gridArray[0][y].value = rightCellValue) then begin
         gridArray[x][y+1].value := trueOrFalse;
      end;
    end
    else
    begin
      if ((gridArray[x - 1][y].value = leftCellValue) and (gridArray[x][y].value = middleCellValue) and (gridArray[x + 1][y].value = rightCellValue)) then begin
          gridArray[x, y + 1].value := trueOrFalse;
      end;
    end;
  end;

function TRules.modulo(x, m: Integer): Integer;
begin
   Result := (x mod m + m) mod m;
end;

procedure TRules.rule2D;
var nextGridArray: TGridArray;
  X, Y, I, J, neighbours: Integer;
 begin

  SetLength(nextGridArray, maxWidth, maxTime);
      for I := 0 to maxTime - 1 do begin
        for J := 0 to maxWidth - 1 do begin
          nextGridArray[J][I] := TCellObject.Create;
        end;
      end;
  for X := 0 to maxWidth - 1 do begin
    for Y := 0 to maxTime - 1 do begin
    neighbours := 0;
      //small loops to check neighbourhood of choosen cell
      for I := - 1 to 1 do begin
        for J := -1 to 1 do begin

           neighbours := neighbours + gridArray[modulo(X+I, maxWidth)][modulo(Y + J, maxTime)].value;
        end;
      end;

      neighbours := neighbours - gridArray[X][Y].value;
      //rules of Game Of Life
      if (gridArray[X][Y].value = 1) and (neighbours < 2) then begin
       nextGridArray[X][Y].value := 0;
      end
      else if (gridArray[X][Y].value = 1) and (neighbours > 3) then begin
       nextGridArray[X][Y].value := 0;
      end
      else if (gridArray[X][Y].value = 0) and (neighbours = 3) then begin
       nextGridArray[X][Y].value := 1;
      end
      else begin
        nextGridArray[X][Y].value := gridArray[X][Y].value;
      end;


    end;

  end;
  gridArray := nextGridArray;
end;

procedure TRules.ruleVonNeumann;
var nextGridArray: TGridArray;
  X, Y, I, J, leftCell, rightCell, topCell, BottomCell: Integer;
  neighbourCellsArray: TArray<Integer>;
 begin
  SetLength(nextGridArray, maxWidth, maxTime);
  for I := 0 to maxTime - 1 do begin
    for J := 0 to maxWidth - 1 do begin
      nextGridArray[J][I] := TCellObject.Create;
    end;
  end;

  neighbourCellsArray := TArray<Integer>.Create(0, 0, 0, 0);

  for X := 0 to maxWidth - 1 do begin
    for Y := 0 to maxTime - 1 do begin
    nextGridArray[X][Y].value := gridArray[X][Y].value;


       if gridArray[X][Y].value = 0 then begin
          //tutaj dodaæ opcjê absorpcja albo nie
          if frmMain.cmbBoundaryConditions.Text = 'absorpcyjne' then begin
            leftCell := X - 1;
            rightCell := X + 1;
            topCell := Y - 1;
            bottomCell := Y + 1;
            if X - 1 < 0 then leftCell := 0;
            if X + 1 >= maxWidth then rightCell := maxWidth - 1;
            if Y + 1 >= maxTime then bottomCell := maxTime - 1;
            if Y - 1 < 0 then topCell := 0;
          end
          else if frmMain.cmbBoundaryConditions.Text = 'periodyczne' then begin
            leftCell := modulo(X - 1, maxWidth);
            rightCell := modulo(X + 1, maxWidth);
            topCell := modulo(Y + 1, maxTime);
            bottomCell := modulo(Y - 1, maxTime);
          end;

         neighbourCellsArray[0] := gridArray[leftCell][modulo(Y, maxTime)].value;
         neighbourCellsArray[1] := gridArray[modulo(X, maxWidth)][topCell].value;
         neighbourCellsArray[2] := gridArray[rightCell][modulo(Y, maxTime)].value;
         neighbourCellsArray[3] := gridArray[modulo(X, maxWidth)][bottomCell].value;

         nextGridArray[X][Y].value := frmMain.mostFrequentValue(neighbourCellsArray);
       end;

    end;
  end;
  gridArray := nextGridArray;
end;

procedure TRules.Moore;
var nextGridArray: TGridArray;
  X, Y, I, J, neighboursCounter, xCell, yCell: Integer;
  neighbourCellsArray: TArray<Integer>;
 begin
  SetLength(nextGridArray, maxWidth, maxTime);
  for I := 0 to maxTime - 1 do begin
    for J := 0 to maxWidth - 1 do begin
      nextGridArray[J][I] := TCellObject.Create;
    end;
  end;

  neighbourCellsArray := TArray<Integer>.Create(0, 0, 0, 0, 0, 0, 0, 0);

  for X := 0 to maxWidth - 1 do begin
      for Y := 0 to maxTime - 1 do begin
      neighboursCounter := 0;

        for I := -1 to 1 do begin
          for J := -1 to 1 do begin
            if frmMain.cmbBoundaryConditions.Text = 'absorpcyjne' then begin
              xCell := modulo(X + I, maxWidth);
              yCell := modulo(Y + J, maxTime);
              if X + I <= 0 then xCell := 0;
              if X + I > maxWidth - 1 then xCell := maxWidth - 1;
              if Y + J > maxTime - 1 then yCell := maxTime - 1;
              if Y + J < 0 then yCell := 0;
              if not ((I = 0) and (J = 0)) then begin
                neighbourCellsArray[neighboursCounter] := gridArray[xCell][yCell].value;
                neighboursCounter := neighboursCounter + 1;
              end;
            end
            else if frmMain.cmbBoundaryConditions.Text = 'periodyczne' then begin
              if not ((I = 0) and (J = 0)) then begin
                neighbourCellsArray[neighboursCounter] := gridArray[modulo(X + I, maxWidth)][modulo(Y + J, maxTime)].value;
                neighboursCounter := neighboursCounter + 1;
              end;
            end;
         end;
        end;

        if gridArray[X][Y].value = 0 then begin
         nextGridArray[X][Y].value := frmMain.mostFrequentValue(neighbourCellsArray);
        end else begin
         nextGridArray[X][Y].value := gridArray[X][Y].value;
        end;

      end;
  end;
  gridArray := nextGridArray;
end;

procedure TRules.pentagonal;
var nextGridArray: TGridArray;
  X, Y, I, J, neighboursCounter, xCell, yCell, exceptionRowOrColumnNumber,
   RowOrColumn, leftColumn, rightColumn, topRow, bottomRow: Integer;
  neighbourCellsArray: TArray<Integer>;
 begin
 //function mostly copied from Moore neighbourhood, added only limit for row or column
  SetLength(nextGridArray, maxWidth, maxTime);
  for I := 0 to maxTime - 1 do begin
    for J := 0 to maxWidth - 1 do begin
      nextGridArray[J][I] := TCellObject.Create;
    end;
  end;
  //pentagonal has only 5 neighbours
  neighbourCellsArray := TArray<Integer>.Create(0, 0, 0, 0, 0);
  //needed to set random which row/column to cut
  leftColumn := -1;
  rightColumn := 1;
  topRow := 1;
  bottomRow := -1;
  //setting cut values
  exceptionRowOrColumnNumber := Random(2);
  RowOrColumn := Random(2);
  //each if means which row or column to cut, there are four possibilities
  if (exceptionRowOrColumnNumber = 0) and (RowOrColumn = 0) then begin
    bottomRow := 0;
  end else if (exceptionRowOrColumnNumber = 1) and (RowOrColumn = 0) then begin
    topRow := 0;
  end else if (exceptionRowOrColumnNumber = 0) and (RowOrColumn = 1) then begin
    leftColumn := 0;
  end else if (exceptionRowOrColumnNumber = 1) and (RowOrColumn = 1) then begin
    rightColumn := 0;
  end;

  for X := 0 to maxWidth - 1 do begin
      for Y := 0 to maxTime - 1 do begin
      neighboursCounter := 0;
  // I and J are limited not to check neighbours for one column or row
        for I := leftColumn to rightColumn do begin
          for J := bottomRow to topRow do begin
            if frmMain.cmbBoundaryConditions.Text = 'absorpcyjne' then begin
              xCell := modulo(X + I, maxWidth);
              yCell := modulo(Y + J, maxTime);
              if X + I <= 0 then xCell := 0;
              if X + I > maxWidth - 1 then xCell := maxWidth - 1;
              if Y + J > maxTime - 1 then yCell := maxTime - 1;
              if Y + J < 0 then yCell := 0;
              if not ((I = 0) and (J = 0)) then begin

                neighbourCellsArray[neighboursCounter] := gridArray[xCell][yCell].value;
                neighboursCounter := neighboursCounter + 1;
              end;
            end
            else if frmMain.cmbBoundaryConditions.Text = 'periodyczne' then begin
              if not ((I = 0) and (J = 0)) then begin
                neighbourCellsArray[neighboursCounter] := gridArray[modulo(X + I, maxWidth)][modulo(Y + J, maxTime)].value;
                neighboursCounter := neighboursCounter + 1;
              end;
            end;
         end;
        end;

        if gridArray[X][Y].value = 0 then begin
         nextGridArray[X][Y].value := frmMain.mostFrequentValue(neighbourCellsArray);
        end else begin
         nextGridArray[X][Y].value := gridArray[X][Y].value;
        end;

      end;
  end;
  gridArray := nextGridArray;
end;

procedure TRules.hexagonal;
var nextGridArray: TGridArray;
  X, Y, I, J, neighboursCounter, xCell, yCell,
   xFirstCorner, yFirstCorner, xSecondCorner, ySecondCorner: Integer;
  neighbourCellsArray: TArray<Integer>;
 begin
 //function mostly copied from pentagonal neighbourhood, changed to corner options
  SetLength(nextGridArray, maxWidth, maxTime);
  for I := 0 to maxTime - 1 do begin
    for J := 0 to maxWidth - 1 do begin
      nextGridArray[J][I] := TCellObject.Create;
    end;
  end;
  //hexagonal has only 6 neighbours
  neighbourCellsArray := TArray<Integer>.Create(0, 0, 0, 0, 0, 0);

  if frmMain.cmbHexagonalType.Text = 'lewo' then begin
    xFirstCorner := -1;
    yFirstCorner := 1;

    xSecondCorner := 1;
    ySecondCorner := -1;

  end else if frmMain.cmbHexagonalType.Text = 'prawo' then begin
    xFirstCorner := -1;
    yFirstCorner := -1;

    xSecondCorner := 1;
    ySecondCorner := 1;

  end else if frmMain.cmbHexagonalType.Text = 'losowe' then begin
    if Random(2) = 0 then begin
      xFirstCorner := -1;
      yFirstCorner := 1;

      xSecondCorner := 1;
      ySecondCorner := -1;
    end else begin
      xFirstCorner := -1;
      yFirstCorner := -1;

      xSecondCorner := 1;
      ySecondCorner := 1;
    end;


  end;
  for X := 0 to maxWidth - 1 do begin
      for Y := 0 to maxTime - 1 do begin
      neighboursCounter := 0;
        for I := -1 to 1 do begin
          for J := -1 to 1 do begin
            if not (((I = 0) and (J = 0)) or ((I = xFirstCorner) and (J = yFirstCorner))
              or ((I = xSecondCorner) and (J = ySecondCorner))) then begin
              if frmMain.cmbBoundaryConditions.Text = 'absorpcyjne' then begin
              xCell := modulo(X + I, maxWidth);
              yCell := modulo(Y + J, maxTime);
              if X + I <= 0 then xCell := 0;
              if X + I > maxWidth - 1 then xCell := maxWidth - 1;
              if Y + J > maxTime - 1 then yCell := maxTime - 1;
              if Y + J < 0 then yCell := 0;
                neighbourCellsArray[neighboursCounter] := gridArray[xCell][yCell].value;
                neighboursCounter := neighboursCounter + 1;
            end
            else if frmMain.cmbBoundaryConditions.Text = 'periodyczne' then begin
                neighbourCellsArray[neighboursCounter] := gridArray[modulo(X + I, maxWidth)][modulo(Y + J, maxTime)].value;
                neighboursCounter := neighboursCounter + 1;
            end;
            end;
         end;
        end;

        if gridArray[X][Y].value = 0 then begin
         nextGridArray[X][Y].value := frmMain.mostFrequentValue(neighbourCellsArray);
        end else begin
         nextGridArray[X][Y].value := gridArray[X][Y].value;
        end;

      end;
  end;
  gridArray := nextGridArray;
end;

procedure TRules.withRadius;
var nextGridArray: TGridArray;
  X, Y, I, J, neighboursCounter, xCell, yCell, exceptionRowOrColumnNumber,
   RowOrColumn, leftColumn, rightColumn, topRow, bottomRow: Integer;
  neighbourCellsArray: TArray<Integer>;
 begin
 //creating Cells array for new iteration
  SetLength(nextGridArray, maxWidth, maxTime);
  for I := 0 to maxTime - 1 do begin
    for J := 0 to maxWidth - 1 do begin
      nextGridArray[J][I] := TCellObject.Create;
    end;
  end;
  //the amount of neighbour cells need to be counted every time by the radius
  neighbourCellsArray := TArray<Integer>.Create(0, 0, 0, 0, 0);

  for X := 0 to maxWidth - 1 do begin
      for Y := 0 to maxTime - 1 do begin
      neighboursCounter := 0;
  // I and J are limited not to check neighbours for one column or row
        for I := leftColumn to rightColumn do begin
          for J := bottomRow to topRow do begin
            if frmMain.cmbBoundaryConditions.Text = 'absorpcyjne' then begin
              xCell := modulo(X + I, maxWidth);
              yCell := modulo(Y + J, maxTime);
              if X + I <= 0 then xCell := 0;
              if X + I > maxWidth - 1 then xCell := maxWidth - 1;
              if Y + J > maxTime - 1 then yCell := maxTime - 1;
              if Y + J < 0 then yCell := 0;
              if not ((I = 0) and (J = 0)) then begin

                neighbourCellsArray[neighboursCounter] := gridArray[xCell][yCell].value;
                neighboursCounter := neighboursCounter + 1;
              end;
            end
            else if frmMain.cmbBoundaryConditions.Text = 'periodyczne' then begin
              if not ((I = 0) and (J = 0)) then begin
                neighbourCellsArray[neighboursCounter] := gridArray[modulo(X + I, maxWidth)][modulo(Y + J, maxTime)].value;
                neighboursCounter := neighboursCounter + 1;
              end;
            end;
         end;
        end;

        if gridArray[X][Y].value = 0 then begin
         nextGridArray[X][Y].value := frmMain.mostFrequentValue(neighbourCellsArray);
        end else begin
         nextGridArray[X][Y].value := gridArray[X][Y].value;
        end;

      end;
  end;
  gridArray := nextGridArray;
end;

procedure TRules.monteCarlo;
  var X, Y, I, J, counter, randomX, randomY, energyBefore, energyAfter, randomNeighbourValue, delta: Integer;
      probability, randomForProbability, kt: Double;
      nextGridArray: TGridArray;
      checkIfEmpty: Boolean;
begin
  Randomize;
  checkIfEmpty := False;
 //creating Cells array for new iteration
  SetLength(nextGridArray, maxWidth, maxTime);
  for I := 0 to maxTime - 1 do begin
    for J := 0 to maxWidth - 1 do begin
      nextGridArray[J][I] := TCellObject.Create;
    end;
  end;

  //checking if array doesnt have any empty cells
  for X := 0 to maxWidth - 1 do begin
   for Y := 0 to maxTime - 1 do begin
     if gridArray[X][Y].value = 0 then begin
       checkIfEmpty := True;
     end;
   end;
  end;
  if checkIfEmpty = True then ShowMessage('the grid is not filled');

  //setting Cells to begin Monte Carlo, no cell was checked
  for X := 0 to maxWidth - 1 do begin
    for Y := 0 to maxTime - 1 do begin
      gridArray[X][Y].ifMonteCarloChecked := False;
    end;
  end;

  counter := 0;
  //needs to work till every cell is checked
  while counter < maxWidth * maxTime do begin
    randomX := Random(maxWidth);
    randomY := Random(maxTime);

    if not gridArray[randomX][randomY].ifMonteCarloChecked then begin
      gridArray[randomX][randomY].ifMonteCarloChecked := True;
      energyBefore := 0;
      energyAfter := 0;

      energyBefore := frmMain.countCellEnergy(randomX, randomY);
      randomNeighbourValue := frmMain.getRandomNeighbourValue(randomX, randomY);
      energyAfter := frmMain.countCellEnergy(randomX, randomY);

      delta := energyAfter - energyBefore;
      if delta <= 0 then begin
        gridArray[randomX][randomY].value := randomNeighbourValue;
        gridArray[randomX][randomY].energy := energyBefore;
      end else begin
        kt := 0.9;
        probability := Exp(-(delta/kt));
        randomForProbability := Random;
        if randomForProbability <= probability then begin
          gridArray[randomX][randomY].value := randomNeighbourValue;
          gridArray[randomX][randomY].energy := energyAfter;
        end;
      end;
      counter := counter + 1;
    end;

  end;


end;
end.
