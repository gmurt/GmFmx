unit SegmentButtons;

interface

uses FMX.Layouts, FMX.Objects, FMX.Controls, FMX.StdCtrls, Classes, FMX.Types, Generics.Collections, System.UITypes;

type
  TSelectSegmentEvent = procedure(Sender: TObject; ASegmentIndex: integer) of object;

  [ComponentPlatformsAttribute(
    pidAllPlatforms
    )]
  TSegmentButtons = class(TPaintBox)
  private
    FButtonWidth: single;
    FSegments: TStrings;
    FItemIndex: integer;
    FThumbPos: single;
    FOnSelectSegment: TSelectSegmentEvent;
    procedure SetSegments(const Value: TStrings);
    procedure SetItemIndex(Value: integer);

    procedure SetThumbPos(const Value: single);
  protected
    procedure Paint; override;
    procedure Click; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Single); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property ThumbPos: single read FThumbPos write SetThumbPos;
  published
    property Segments: TStrings read FSegments write SetSegments;
    property ItemIndex: integer read FItemIndex write SetItemIndex default -1;
    property OnSelectSegment: TSelectSegmentEvent read FOnSelectSegment write FOnSelectSegment;

  end;

  procedure Register;

implementation

uses FMX.Graphics, FMX.Ani, System.Types, System.UIConsts, Math;


procedure Register;
begin
  RegisterComponents('GmFmx', [TSegmentButtons]);
end;

{ TSegmentButtons }

procedure TSegmentButtons.Click;
begin
  inherited;
end;

constructor TSegmentButtons.Create(AOwner: TComponent);
begin
  inherited;
  FSegments := TStringList.Create;
  FThumbPos := 0;
  FItemIndex := -1;
  Width := 200;
  Height := 56;
  SetAcceptsControls(False);
end;

destructor TSegmentButtons.Destroy;
begin
  FSegments.Free;
  inherited;
end;

procedure TSegmentButtons.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Single);
var
  AIndex: integer;
begin
  inherited;
  AIndex := Trunc(X / FButtonWidth);
  if AIndex > FSegments.Count-1 then
    AIndex := FSegments.Count-1;
  if AIndex <> FItemIndex then
  begin

    ItemIndex := AIndex;
  end;
end;

procedure TSegmentButtons.Paint;
var
  ARect: TRectF;
  AState: TCanvasSaveState;
  AIndex: integer;
  AStr: string;
  AThumbRect: TRectF;
begin
  inherited;
  AState := Canvas.SaveState;
  try
    Canvas.IntersectClipRect(ClipRect);

    AThumbRect := ClipRect;
    AThumbRect.Inflate(-8, -8);

    if FSegments.Count = 0 then
      FItemIndex := -1
    else
    begin
      if FItemIndex = -1 then
        FItemIndex := 0;
    end;

    ARect := AThumbRect;
    Canvas.Fill.Kind := TBrushKind.Solid;
    Canvas.Fill.Color := claBlack;
    Canvas.Stroke.Kind := TBrushKind.Solid;
    Canvas.Stroke.Color := claGainsboro;
    Canvas.Stroke.Thickness := 5;
    Canvas.Fill.Color := claGainsboro;
    //Canvas.Stroke.Thickness := 4;
    Canvas.DrawRect(ARect, 16, 16, AllCorners, 1);
    Canvas.FillRect(ARect, 16, 16, AllCorners, 1);

    FButtonWidth := ARect.Width / FSegments.Count;


    ARect.Width := FButtonWidth;
    Canvas.Stroke.Kind := TBrushKind.Solid;
    Canvas.Fill.Color := claWhite;
    Canvas.Stroke.Thickness := 0;

    // thumb...
    Canvas.Fill.Color := claWhite;
    AThumbRect := ARect;
    AThumbRect.Offset(FThumbPos, 0);
    Canvas.FillRect(AThumbRect, 16, 16, AllCorners, 1);



    for AIndex := 0 to FSegments.Count-1 do
    begin
      AStr := FSegments[AIndex];

      if AIndex = FItemIndex then
      begin
        Canvas.font.Style := [TFontStyle.fsBold];
        Canvas.Fill.Color := claBlack;
      end
      else
      begin
        Canvas.Font.Style := [];
        Canvas.Fill.Color := claSilver;
      end;

      //Canvas.FillRect(ARect, 16, 16, AllCorners, 1);
      Canvas.Fill.Color := claBlack;
      Canvas.Font.Size := 15;
      Canvas.FillText(ARect, AStr, False, 1, [], TTextAlign.Center, TTextAlign.Center);
      ARect.Offset(FButtonWidth, 0);
    end;




  finally
    Canvas.RestoreState(AState);
  end;
end;


procedure TSegmentButtons.SetItemIndex(Value: integer);
var
  bw: single;
begin
  if Value > FSegments.Count-1 then Value := FSegments.Count-1;
  
  if (Value < 0) and (FSegments.Count > 0) then Value := 0;


  if FItemIndex <> Value then
  begin
    FItemIndex := Value;



    bw := FButtonWidth;
    if csDesigning in ComponentState then
    begin
      ThumbPos := FItemIndex * bw;
    end
    else
      TAnimator.AnimateFloat(Self, 'ThumbPos', FItemIndex * bw);

    if Assigned(FOnSelectSegment) then
      FOnSelectSegment(Self, FItemIndex);
  end;
end;

procedure TSegmentButtons.SetSegments(const Value: TStrings);
begin
  FSegments.Assign(Value);
end;

procedure TSegmentButtons.SetThumbPos(const Value: single);
begin
  FThumbPos := Value;
  InvalidateRect(ClipRect);
end;


end.

