unit BsButton;

interface

uses
  System.SysUtils, System.Classes, FMX.Types, FMX.Controls, System.Generics.Collections,
  System.UITypes;

type
  TBsButtonStyle = (bsPrimary, bsSecondary, bsSuccess, bsDanger, bsWarning, bsInfo, bsLight, bsDark, bsLink);

  TBsButtonStyleInfo = record
    Style: TBsButtonStyle;
    Color: TAlphaColor;
    TextColor: TAlphaColor;
    SelectedTextColor: TAlphaColor;
  end;

  TGmButtonState = (bsNormal, bsHover, bsSelected);

  TBsButton = class(TControl)
  private
    FButtonStyle: TBsButtonStyle;
    FEnabled: Boolean;
    FStyles: TDictionary<TBsButtonStyle, TBsButtonStyleInfo>;
    FText: string;
    FState: TGmButtonState;
    FOutline: Boolean;
    FOnClick: TNotifyEvent;
    procedure BuildColorTable;
    procedure SetButtonStyle(const Value: TBsButtonStyle);
    procedure SetText(const Value: string);
    procedure SetOutline(const Value: Boolean);
    { Private declarations }
  protected
    procedure Paint; override;
    procedure SetName(const Value: TComponentName); override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Single); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Single); override;
    procedure SetEnabled(const Value: Boolean); override;

    { Protected declarations }
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    { Public declarations }
  published
    property Align;
    property Enabled: Boolean read FEnabled write SetEnabled default True;
    property Height;
    property Width;
    property Padding;
    property Margins;
    property Position;

    property Size;
    property Style: TBsButtonStyle read FButtonStyle write SetButtonStyle default bsPrimary;
    property Text: string read FText write SetText;
    property Outline: Boolean read FOutline write SetOutline;
    property OnClick: TNotifyEvent read FOnClick write FOnClick;
    { Published declarations }
  end;

procedure Register;

implementation

uses FMX.Graphics, System.UIConsts, System.Types;

const
  BS_PRIMARY = $FF0D6EFD;           // #0d6efd
  BS_SECONDARY = $FF6C757D;         // #6c757d
  BS_SUCCESS = $FF198754;           // #198754
  BS_DANGER = $FFDC3545;            // #dc3545
  BS_WARNING = $FFFFC107;           // #ffc107
  BS_INFO = $FF0DCAF0;              // #0dcaf0
  BS_LIGHT = $FFF8F9FA;             // #f8f9fa
  BS_DARK = $FF212529;              // #212529

function ButtonStyleInfo(AStyle: TBsButtonStyle; AColor, ATextColor, ASelectedTextColor: TAlphaColor): TBsButtonStyleInfo;
begin
  Result.Style := AStyle;
  Result.Color := AColor;
  Result.TextColor := ATextColor;
  Result.SelectedTextColor := ASelectedTextColor;
end;


procedure Register;
begin
  RegisterComponents('GmFmx', [TBsButton]);
end;

{ TBsButton }

procedure TBsButton.BuildColorTable;
begin
  FStyles.Clear;
  FStyles.Add(bsPrimary, ButtonStyleInfo(bsPrimary, BS_PRIMARY, BS_PRIMARY, claWhite));
  FStyles.Add(bsSecondary, ButtonStyleInfo(bsSecondary, BS_SECONDARY, BS_SECONDARY, claWhite));
  FStyles.Add(bsSuccess, ButtonStyleInfo(bsSuccess, BS_SUCCESS, BS_SUCCESS, claWhite));
  FStyles.Add(bsDanger, ButtonStyleInfo(bsDanger, BS_DANGER, BS_DANGER, claWhite));

  FStyles.Add(bsWarning, ButtonStyleInfo(bsWarning, BS_WARNING, BS_WARNING, claBlack));
  FStyles.Add(bsInfo, ButtonStyleInfo(bsInfo, BS_INFO, BS_INFO, claBlack));
  FStyles.Add(bsLight, ButtonStyleInfo(bsLight, BS_LIGHT, BS_LIGHT, claBlack));
  FStyles.Add(bsDark, ButtonStyleInfo(bsDark, BS_DARK, BS_DARK, claWhite));
  FStyles.Add(bsLink, ButtonStyleInfo(bsLink, claNull, BS_PRIMARY, BS_PRIMARY));
end;

constructor TBsButton.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FStyles := TDictionary<TBsButtonStyle, TBsButtonStyleInfo>.Create;
  FEnabled := True;
  Width := 150;
  Height := 40;
  BuildColorTable;
  Text := Name;
  FState := bsNormal;
  FOutline := False;
end;

destructor TBsButton.Destroy;
begin
  FStyles.Free;
  inherited;
end;

procedure TBsButton.MouseDown(Button: TMouseButton; Shift: TShiftState; X,
  Y: Single);
begin
  inherited;
  if FEnabled = False then
    Exit;
  FState := bsSelected;
  InvalidateRect(ClipRect);
end;

procedure TBsButton.MouseUp(Button: TMouseButton; Shift: TShiftState; X,
  Y: Single);
begin
  inherited;
  if FEnabled = False then
    Exit;

  TThread.CreateAnonymousThread(
    procedure
    begin
      Sleep(100);
      TThread.Synchronize(nil,
        procedure
        begin
          FState := bsNormal;
          InvalidateRect(ClipRect);
          if Assigned(FOnClick) then
            FOnClick(Self);
        end
      );
    end
  ).Start;
end;

procedure TBsButton.Paint;
var
  AState: TCanvasSaveState;
  ARect: TRectF;
  AStyle: TBsButtonStyleInfo;
begin
  inherited;
  AState := Canvas.SaveState;
  try
    ARect := ClipRect;
    FStyles.TryGetValue(FButtonStyle, AStyle);

    Canvas.Stroke.Thickness := 1;
    ARect.Inflate(- Canvas.Stroke.Thickness, - Canvas.Stroke.Thickness);
    Canvas.IntersectClipRect(ClipRect);
    Canvas.Stroke.Color := AStyle.Color;

    Canvas.Font.Size := 16;
    Canvas.Stroke.Kind := TBrushKind.Solid;
    Canvas.Fill.Color := AStyle.Color;

    if not FEnabled then
      Opacity := 0.5;

    if (FOutline = False) or (FState = bsSelected) then
    begin
      if FEnabled then
      begin
        if (FState = bsSelected) and (not FOutline) then
          Opacity := 0.7
        else
          Opacity := 1;
      end;
      Canvas.DrawRect(ARect, 6, 6, AllCorners, Opacity);
      Canvas.FillRect(ARect, 6, 6, AllCorners, Opacity);
      Canvas.Fill.Color := AStyle.SelectedTextColor;
      Canvas.FillText(ARect, FText, False, 1, [], TTextAlign.Center);
    end
    else
    begin
      Canvas.Fill.Color := AStyle.TextColor;
      Canvas.DrawRect(ARect, 6, 6, AllCorners, 1);
      Canvas.FillText(ARect, FText, False, 1, [], TTextAlign.Center);
    end;

   
  finally
    Canvas.RestoreState(AState);
  end;
end;

procedure TBsButton.SetButtonStyle(const Value: TBsButtonStyle);
begin
  if FButtonStyle <> Value then
  begin
    FButtonStyle := Value;
    InvalidateRect(ClipRect);
  end;
end;

procedure TBsButton.SetEnabled(const Value: Boolean);
begin
  FEnabled := Value;
  Repaint;
end;

procedure TBsButton.SetName(const Value: TComponentName);
begin
  inherited SetName(Value);
  // Only set caption at design time to avoid runtime interference
  if Name <> '' then
    Exit;

  if (csDesigning in ComponentState) and (Value <> '') then
  begin
    FText := Value;
    Repaint;
  end;
end;

procedure TBsButton.SetOutline(const Value: Boolean);
begin
  FOutline := Value;
  Repaint;
end;

procedure TBsButton.SetText(const Value: string);
begin
  FText := Value;
end;

end.
