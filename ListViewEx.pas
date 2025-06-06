unit ListViewEx;

interface

uses
  System.SysUtils, System.Classes, FMX.Types, FMX.Controls, FMX.InertialMovement, System.UITypes,
  FMX.Graphics, System.Generics.Collections, Types, FMX.Edit, FMX.StdCtrls, System.UIConsts;

const
  C_DEFAULT_ITEM_HEIGHT = 50;

type
  TListViewEx = class;

  TListViewExItem = class;
  TListViewExItemObject = class;

  TListViewItemExPurpose = (lvItem, lvHeader);
  TListViewItemExAccessory = (accNone, accMore, accCheckBox, accCheckBoxChecked);

  TListViewExItemClickEvent = procedure(Sender: TComponent; AItem: TListViewExItem; AObject: TListViewExItemObject) of object;

  TBubbleAlign = (baLeft, baRight);

  TListViewExPullToRefresh = class(TPersistent)
  private
    FEnabled: Boolean;
    FText: string;
  public
    constructor Create; virtual;
  published

    property Enabled: Boolean read FEnabled write FEnabled;
    property Text: string read FText write FText;
  end;

  TListViewExItemObject = class
  private
    FRect: TRectF;
    FHorzAlign: TTextAlign;
    FVertAlign: TTextAlign;
    FWidth: single;
    FHeight: single;
    FOffset: TPointF;
    FVisible: Boolean;
    FOwner: TListViewExItem;
    FListView: TListViewEx;
    FTagString: string;
    //procedure ClearBuffer; overload;
    //procedure ClearBuffer(Sender: TObject); overload;
    function CalculateRect(AItemRect: TRectF): TRectF;
    procedure SetHorzAlign(const Value: TTextAlign);
    procedure SetVertAlign(const Value: TTextAlign);
    procedure SetHeight(const Value: single); virtual;
    procedure SetWidth(const Value: single); virtual;
    procedure SetVisible(const Value: Boolean);
  protected
    procedure DrawObject(ACanvas: TCanvas; AObjectRect: TRectF); virtual;
    //procedure UpdateBuffer; virtual;
  public
    constructor Create(AItem: TListViewExItem); virtual;
    procedure SetSize(AWidth, AHeight: single);
    procedure SetOffset(AOffset: TPointF);
    procedure DrawToCanvas(ACanvas: TCanvas; AItemRect: TRectF); virtual;
    property Height: single read FHeight write SetHeight;
    property HorzAlign: TTextAlign read FHorzAlign write SetHorzAlign default TTextAlign.Leading;

    property Offset: TPointF read FOffset write SetOffset;
    property TagString: string read FTagString write FTagString;
    property VertAlign: TTextAlign read FVertAlign write SetVertAlign default TTextAlign.Center;
    property Width: single read FWidth write SetWidth;

    property Visible: Boolean read FVisible write SetVisible;
  end;


  TListViewExRectangle = class(TListViewExItemObject)
  private
    FFill: TBrush;
    FStroke: TStrokeBrush;
    FCornerRadius: single;
    procedure SetFill(const Value: TBrush);
    procedure SetStroke(const Value: TStrokeBrush);
    procedure SetCornerRadius(const Value: single);
  protected
    procedure DrawObject(ACanvas: TCanvas; AObjectRect: TRectF); override;
  public
    constructor Create(AItem: TListViewExItem); override;
    destructor Destroy; override;
    property Fill: TBrush read FFill write SetFill;
    property Stroke: TStrokeBrush read FStroke write SetStroke;
    property CornweRadius: single read FCornerRadius write SetCornerRadius;
  end;

  TListViewExItemPill = class(TListViewExRectangle)
  private
    FTextColor: TAlphaColor;
    FText: string;
    FFont: TFont;
    procedure SetText(const Value: string);
    procedure SetTextColor(const Value: TAlphaColor);
  protected
    procedure DrawObject(ACanvas: TCanvas; AObjectRect: TRectF); override;
  public
    constructor Create(AItem: TListViewExItem); override;
    destructor Destroy; override;
    property Text: string read FText write SetText;
    property TextColor: TAlphaColor read FTextColor write SetTextColor;
  end;




  TListViewExText = class(TListViewExItemObject)
  private
    //FBuffer: TBitmap;
    FText: string;
    FTextSettings: TTextSettings;
    procedure SetText(const Value: string);
  protected
    //procedure UpdateBuffer; override;
    procedure DrawObject(ACanvas: TCanvas; AObjectRect: TRectF); override;
  public
    constructor Create(AItem: TListViewExItem); override;
    destructor Destroy; override;
    property Text: string read FText write SetText;
    property TextSettings: TTextSettings read FTextSettings write FTextSettings;
  end;

  TListViewExImage = class(TListViewExItemObject)
  private
    FBitmap: TBitmap;
    procedure SetBitmap(const Value: TBitmap);
  protected
    procedure DrawObject(ACanvas: TCanvas; AObjectRect: TRectF); override;
  public
    constructor Create(AItem: TListViewExItem); override;
    destructor Destroy; override;

    property Bitmap: TBitmap read FBitmap write SetBitmap;
  end;

  TListViewExItemControl = class(TListViewExItemObject)
  private
    //FCache: TBitmap;
    FControl: TControl;
  protected

    function GetControl: TControl;
    function CreateControl: TControl; virtual; abstract;
    procedure DrawObject(ACanvas: TCanvas; AObjectRect: TRectF); override;
    procedure InitializeControl; virtual;

    procedure SetHeight(const Value: single); override;
    procedure SetWidth(const Value: single); override;
  public
    constructor Create(AItem: TListViewExItem); override;
    destructor Destroy; override;
    procedure HideControl;
  end;

  TListViewExItemProgressBar = class(TListViewExItemObject)
  private
    FMax: single;
    FColor: TAlphaColor;
    FBorder: TAlphaColor;
    FValue: single;
  protected
    procedure DrawObject(ACanvas: TCanvas; AObjectRect: TRectF); override;
  public
    property Value: single read FValue write FValue;
    property Max: single read FMax write FMax;
    property Color: TAlphaColor read FColor write FColor;
    property Border: TAlphaColor read FBorder write FBorder;
  end;



  TListViewExItemSwitch = class(TListViewExItemControl)
  private
    function GetSwitch: TSwitch;
  protected
    function CreateControl: TControl; override;
  public
    property Switch: TSwitch read GetSwitch;
  end;

  TListViewExItemCheckableControl = class(TListViewExItemControl)
  protected
    function GetIsChecked: Boolean; virtual; abstract;
    procedure SetIsChecked(const Value: Boolean); virtual; abstract;
  public
    property Checked: Boolean read GetIsChecked write SetIsChecked;
  end;

  TListViewExItemCheckbox = class(TListViewExItemCheckableControl)
  private
    function GetCheckbox: TCheckbox;
    procedure DoCheckboxResized(Sender: TObject);
  protected
    function GetIsChecked: Boolean; override;
    procedure SetIsChecked(const Value: Boolean); override;
    function CreateControl: TControl; override;
  public
    property Checkbox: TCheckBox read GetCheckbox;
  end;

  TListViewExItemRadiobutton = class(TListViewExItemCheckableControl)
  private
    function GetRadiobutton: TRadioButton;
    procedure DoRadioResized(Sender: TObject);
  protected
    function GetIsChecked: Boolean; override;
    procedure SetIsChecked(const Value: Boolean); override;
    function CreateControl: TControl; override;
  public
    property Radiobutton: TRadioButton read GetRadiobutton;
  end;

  TListViewExItemButton = class(TListViewExItemControl)
  private
    function GetButton: TButton;
    procedure DoClick(Sender: TObject);
    procedure DoButtonResized(Sender: TObject);
  protected

    function CreateControl: TControl; override;
    procedure InitializeControl; override;
  public

    property Button: TButton read GetButton;
  end;

  TListViewExItemEdit = class(TListViewExItemControl)
  private
    function GetEdit: TEdit;
  protected
    function CreateControl: TControl; override;
  public
    property Edit: TEdit read GetEdit;
  end;




  TListViewExItemObjects = class(TObjectList<TListViewExItemObject>)
  public
    function ObjectAtPos(x, y: single): TListViewExItemObject;
  end;

  TListViewExItem = class
  private
    [weak] FListViewEx: TListViewEx;
    FAccessory: TListViewItemExAccessory;
    FClickEffect: Boolean;
    FHeight: single;
    FIndex: integer;
    FObjects: TListViewExItemObjects;
    FImage: TListViewExImage;
    FTitle: TListViewExText;
    FSubTitle: TListViewExText;
    FDetail: TListViewExText;
    FCheckableControl: TListViewExItemCheckableControl;
    FItemRect: TRectF;
    FSelected: Boolean;
    FPurpose: TListViewItemExPurpose;
    FTag: integer;
    FTagString: string;
    FTagBool: Boolean;
    //FIsChecked: Boolean;
    FAutocheck: Boolean;
    FBackgroundColor: TAlphaColor;
    FShowBackgroundColor: Boolean;
    FUpdating: Boolean;
    procedure SetHeight(const Value: single);
    procedure SetPurpose(const Value: TListViewItemExPurpose);
    procedure DrawAccessory(ACanvas: TCanvas; ARect: TRectF);
    procedure SetIsChecked(const Value: Boolean);
    function GetIsCheckable: Boolean;
    function GetIsChecked: Boolean;
  protected
    procedure DrawToCanvas(ACanvas: TCanvas; ARect: TRectF);
  public
    constructor Create; virtual;
    destructor Destroy; override;

    procedure HideControls; virtual;

    function AddText(AText: string; AHorzAlign: TTextAlign; const AVertAlign: TTextAlign = TTextAlign.Center): TListViewExText;
    function AddRectangle(AHorzAlign: TTextAlign; const AVertAlign: TTextAlign = TTextAlign.Center): TListViewExRectangle;
    function AddImage(AImage: TBitmap; AHorzAlign: TTextAlign; const AVertAlign: TTextAlign = TTextAlign.Center): TListViewExImage;
    function AddCheckbox(AChecked: Boolean; AHorzAlign: TTextAlign; AVertAlign: TTextAlign): TListViewExItemCheckbox;
    function AddRadiobutton(AChecked: Boolean; AHorzAlign: TTextAlign; AVertAlign: TTextAlign): TListViewExItemRadiobutton;
    function AddSwitch(AChecked: Boolean; AHorzAlign: TTextAlign; AVertAlign: TTextAlign): TListViewExItemSwitch;
    function AddButton(AText: string; AWidth: single; AHorzAlign: TTextAlign; const AVertAlign: TTextAlign = TTextAlign.Center): TListViewExItemButton;
    function AddEdit(AText, APlaceholder: string; AHorzAlign: TTextAlign; const AVertAlign: TTextAlign = TTextAlign.Center): TListViewExItemEdit;
    function AddProgressBar(APos, AMax: integer;
                            AColor: TAlphaColor;
                            const ABorder: TAlphaColor = claDarkgray;
                            const AHorzAlign: TTextAlign = TTextAlign.Center;
                            const AVertAlign: TTextAlign = TTextAlign.Center): TListViewExItemProgressBar;
    function AddPill(AText: string; AColor, ATextColor: TAlphaColor; const AHorzAlign: TTextAlign = TTextAlign.Trailing): TListViewExItemPill;

    function MatchesFilter(AFilter: string): Boolean;

    property Accessory: TListViewItemExAccessory read FAccessory write FAccessory default accMore;
    property ClickEffect: Boolean read FClickEffect write FClickEffect;
    property Height: single read FHeight write SetHeight;
    property &Index: integer read FIndex;
    property Image: TListViewExImage read FImage;
    property Detail: TListViewExText read FDetail;

    property SubTitle: TListViewExText read FSubTitle;
    property Title: TListViewExText read FTitle;
    property ItemRect: TRectF read FItemRect write FItemRect;
    property Purpose: TListViewItemExPurpose read FPurpose write SetPurpose default lvItem;
    property IsCheckable: Boolean read GetIsCheckable;
    property IsChecked: Boolean read GetIsChecked write SetIsChecked;
    property AutoCheck: Boolean read FAutocheck write FAutocheck;
    property Tag: integer read FTag write FTag;
    property TagString: string read FTagString write FTagString;
    property TagBool: Boolean read FTagBool write FTagBool;
    property BackgroundColor: TAlphaColor read FBackgroundColor write FBackgroundColor default claNull;
    property ShowBackgroundColor: Boolean read FShowBackgroundColor write FShowBackgroundColor;
    property Objects: TListViewExItemObjects read FObjects;
  end;

  TListViewExItems = class(TObjectList<TListViewExItem>)
  private
    [weak]FListViewEx: TListViewEx;
    procedure Reindex;
    procedure ItemsInViewport(AViewport: TRectF; AItems: TList<TListViewExItem>);
    //function CalculateTextSize(const AText: string; const AFont: TFont; AMaxWidth, APadding: single): TSizeF;
  protected
    procedure Notify(const Value: TListViewExItem; Action: TCollectionNotification); override;
  public
    constructor Create(AOwner: TComponent);
    function AddItem(ATitle: string; const AAccessory: TListViewItemExAccessory = accNone): TListViewExItem; overload;
    function AddItem(AImg: TBitmap; ATitle: string; const AAccessory: TListViewItemExAccessory = accNone): TListViewExItem; overload;
    function AddItem(AImg: TBitmap; ATitle, ADetail: string; const AAccessory: TListViewItemExAccessory = accNone): TListViewExItem; overload;
    function AddBubbleItem(AText, ASender: string; ABubbleColor, ATextColor: TAlphaColor; ADateTime: TDateTime; AAlign: TBubbleAlign): TListViewExItem;
    function AddItemCheckbox(AImg: TBitmap; ATitle: string; AChecked: Boolean): TListViewExItem;
    function AddItemRadiobutton(AImg: TBitmap; ATitle: string; AChecked: Boolean): TListViewExItem;

    procedure AddSeperator;
    function AddHeader(AText: string): TListViewExItem;
  end;

  [ComponentPlatformsAttribute(pidAllPlatforms)]
  TListViewEx = class(TControl)
  private
    FMouseDownPoint: TPointF;
    FItems: TListViewExItems;
    FItemsInView: TList<TListViewExItem>;
    FItemHeight: integer;
    FScrollPos: single;
    FMaxScrollPos: single;
    FAniCalc: TAniCalculations;
    FTotalItemHeight: single;
    FShowSearch: Boolean;
    FEmptyText: string;
    FFilterEdit: TEdit;
    FShowSeperators: Boolean;
    FUpdateCount: integer;
    FPullToRefresh: TListViewExPullToRefresh;

    FOnScroll: TNotifyEvent;
    FOnPullRefresh: TNotifyEvent;
    FOnItemClick: TListViewExItemClickEvent;
    FBackgroundColor: TAlphaColor;
    FSaveScroll: single;
    procedure SetupInertialMovement;
    procedure SetScrollPos(const Value: single);
    procedure AniCalcChange(Sender: TObject);
    procedure AniCalcStart(Sender: TObject);
    procedure AniCalcStop(Sender: TObject);
    procedure UpdateScrollLimits;
    function GetViewport: TRectF;
    procedure SetItemHeight(const Value: integer);
    procedure CalculateItemRects;
    procedure DrawPullToRefresh(ACanvas: TCanvas);
    procedure SetShowSearch(const Value: Boolean);
    procedure DoFilterChange(Sender: TObject);
    procedure SetPullToRefresh(const Value: TListViewExPullToRefresh);
    procedure SetShowSeperators(const Value: Boolean);
    procedure SetEmptyText(const Value: string);
    procedure SetBackgroundColor(const Value: TAlphaColor);
    { Private declarations }
  protected
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; x, y: single); override;
    procedure MouseMove(Shift: TShiftState; x, y: single); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; x, y: single); override;
    procedure DoMouseLeave; override;

    procedure Loaded; override;
    procedure Paint; override;
    procedure Resize; override;

    { Protected declarations }

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function ItemAtPos(x, y: single): TListViewExItem;
    procedure Invalidate;
    procedure ScrollToItem(AItemIndex: integer);
    procedure ScrollToFirstChecked;
    procedure ScrollToEnd(AAnimate: Boolean);
    procedure ScrollToStart;
    procedure BeginUpdate; override;
    procedure EndUpdate; override;
    //procedure ScrollInView(AItem: TListViewExItem);
    property Items: TListViewExItems read FItems;
    property ItemsInView: TList<TListViewExItem> read FItemsInView;
    property ScrollPos: single read FScrollPos write SetScrollPos;
    property Viewport: TRectF read GetViewport;
    property MaxScrollPos: single read FMaxScrollPos;

    { Public declarations }
  published
    property Align;
    property Height;
    property EmptyText: string read FEmptyText write SetEmptyText;
    property PullToRefresh: TListViewExPullToRefresh read FPullToRefresh write SetPullToRefresh;
    property ShowSearch: Boolean read FShowSearch write SetShowSearch;
    property BackgroundColor: TAlphaColor read FBackgroundColor write SetBackgroundColor default claNull;
    property ItemHeight: integer read FItemHeight write SetItemHeight default C_DEFAULT_ITEM_HEIGHT;
    property Position;
    property Size;
    property ShowSeperators: Boolean read FShowSeperators write SetShowSeperators default True;
    property Width;
    property OnScroll: TNotifyEvent read FOnScroll write FOnScroll;
    property OnPullRefresh: TNotifyEvent read FOnPullRefresh write FOnPullRefresh;

    property OnItemClick: TListViewExItemClickEvent read FOnItemClick write FOnItemClick;
    property OnMouseDown;
    { Published declarations }
  end;

procedure Register;

implementation

uses Math, Math.Vectors, FMX.Forms, FMX.Ani, FMX.Platform, System.Threading, FMX.TextLayout, System.Skia, FMX.Skia, FMX.Skia.Canvas;


procedure Register;
begin
  RegisterComponents('GmFmx', [TListViewEx]);
end;

function CalculateTextSize(ACanvas: TCanvas; const AText: string; const AFont: TFont; AMaxWidth, APadding: single): TSizeF;
var
  TextLayout: TskTextLayout;
begin
  TextLayout := TSkTextLayout.Create(ACanvas);
  try
    // Set up the font
    TextLayout.Font.Assign(AFont);
    TextLayout.Text := AText;
    TextLayout.WordWrap := True;
    // Measure the text
    TextLayout.BeginUpdate;
    TextLayout.MaxSize := TPointF.Create(AMaxWidth, 1000); // Set a large enough width to avoid wrapping
    TextLayout.EndUpdate;
    Result.Height := TextLayout.Height;
    Result.Width := TextLayout.Width;
  finally
    TextLayout.Free;
  end;
end;



{ TListViewEx }

procedure TListViewEx.CalculateItemRects;
var
  AItem: TListViewExItem;
  y: single;
  vp: TRectF;
  AFilter: string;
begin
  FItemsInView.Clear;
  FTotalItemHeight := 0;
  y := 0;

  if FShowSearch then
  begin
    y := Round(FFilterEdit.Height);
    FTotalItemHeight := Round(FFilterEdit.Height);
  end;

  vp := Viewport;

  AFilter := Trim(FFilterEdit.Text);

  for AItem in FItems do
  begin
    if (FShowSearch = False) or (AItem.MatchesFilter(AFilter)) then
    begin
      AItem.ItemRect := RectF(0, y, Width, y+AItem.Height);
      if vp.IntersectsWith(AItem.ItemRect) then
      begin
        FItemsInView.Add(AItem);
      end
      else
        AItem.HideControls;
      //Inc(y, AItem.Height);
      y := y + AItem.Height;
      FTotalItemHeight := FTotalItemHeight + AItem.Height;
      //Inc(FTotalItemHeight, AItem.Height);
    end
    else
      AItem.HideControls;
  end;
end;

constructor TListViewEx.Create(AOwner: TComponent);
begin
  inherited;

  FAniCalc := TAniCalculations.Create(Self);
  FItems := TListViewExItems.Create(Self);
  FItemsInView := TList<TListViewExItem>.Create;
  FPullToRefresh := TListViewExPullToRefresh.Create;

  FFilterEdit := TEdit.Create(nil);
  FUpdateCount := 0;
  FFilterEdit.Visible := False;
  FFilterEdit.OnChangeTracking := DoFilterChange;
  FFilterEdit.Align := TAlignLayout.Top;
  FFilterEdit.TextPrompt := 'FILTER LIST';
  FFilterEdit.StyleLookup := 'searcheditbox';
  FFilterEdit.Stored := False;
  FFilterEdit.Locked := True;
  FFilterEdit.Parent := Self;


  FBackgroundColor := claNull;
  FUpdateCount := 0;
  FTotalItemHeight := 500;
  FItemHeight := C_DEFAULT_ITEM_HEIGHT;
  FShowSeperators := True;
  SetupInertialMovement;
  UpdateScrollLimits;
  ClipChildren := True;
end;

destructor TListViewEx.Destroy;
begin
  FItems.Free;
  FFilterEdit.Free;
  FAniCalc.Free;
  FItemsInView.Free;
  FPullToRefresh.Free;
  inherited;
end;

procedure TListViewEx.EndUpdate;
begin
  if FUpdateCount > 0 then
  begin
    Dec(FUpdateCount);
    if FUpdateCount = 0 then
    begin
      //AScrollPos := FScrollPos;
      FAniCalc.OnChanged := nil;
      FItems.Reindex;
      CalculateItemRects;
      UpdateScrollLimits;
      FScrollPos := FSaveScroll;
      FAniCalc.ViewportPosition := PointF(0, FScrollPos);
      //FAniCalc.UpdatePosImmediately(True);
      FAniCalc.UpdatePosImmediately(True);
   //   invalidate;
      FAniCalc.OnChanged := AniCalcChange;
    end;
  end;
end;

procedure TListViewEx.DoFilterChange(Sender: TObject);
begin
  UpdateScrollLimits;
end;

procedure TListViewEx.DoMouseLeave;
begin
  inherited;
  FAniCalc.MouseLeave;
end;

procedure TListViewEx.DrawPullToRefresh(ACanvas: TCanvas);
var
  y: single;
begin
  if ScrollPos >= 0 then
    Exit;
  y := 0;
  if FShowSearch then y := Round(FFilterEdit.Height);

  ACanvas.Stroke.Color := claSilver;
  ACanvas.Stroke.Thickness := 1;
  ACanvas.Stroke.Kind := TBrushKind.Solid;

  if Items.Count = 0 then
    ACanvas.DrawLine(PointF(0, y-FScrollPos), PointF(Width, y-FScrollPos), 1);

  Canvas.Fill.Color := claBlack;
  if FAniCalc.Down then
  begin
    Canvas.FillText(RectF(0, y, Width, y+60), FPullToRefresh.Text, False, 1, [], TTextAlign.Center);
  end;
end;

function TListViewEx.GetViewport: TRectF;
begin
  Result := RectF(0, 0, Width, Height);
  OffsetRect(Result, 0, FScrollPos);
end;

procedure TListViewEx.Invalidate;
begin
  InvalidateRect(ClipRect);
end;

function TListViewEx.ItemAtPos(x, y: single): TListViewExItem;
var
  AItem: TListViewExItem;
begin
  Result := nil;
  for AItem in FItemsInView do
  begin
    if PtInRect(AItem.ItemRect, PointF(x, FScrollPos+y)) then
    begin
      Result := AItem;
      Exit;
    end;
  end;
end;

procedure TListViewEx.Loaded;
begin
  inherited;
  // Restore HitTest at runtime
  if not (csDesigning in ComponentState) then
    FFilterEdit.HitTest := True;
end;

procedure TListViewEx.MouseDown(Button: TMouseButton; Shift: TShiftState; x, y: single);
begin
  inherited;
  FAniCalc.MouseDown(x, y);

  FMouseDownPoint := PointF(x, y);

end;

procedure TListViewEx.MouseMove(Shift: TShiftState; x, y: single);
begin
  inherited;
  FAniCalc.MouseMove(x, y);
end;

procedure TListViewEx.MouseUp(Button: TMouseButton; Shift: TShiftState; x, y: single);
var
  AItem: TListViewExItem;
  AHitRect: TRectF;
  AObj: TListViewExItemObject;
begin
  inherited;
  FAniCalc.MouseUp(x, y);



  AHitRect.TopLeft := FMouseDownPoint;
  AHitRect.BottomRight := FMouseDownPoint;
  AHitRect.Inflate(4, 4);
  if PtInRect(AHitRect, PointF(x, y)) then
  begin
    AItem := ItemAtPos(x, y);
    if (AItem <> nil) and (AItem.Purpose <> lvHeader) then
    begin
      AItem.FSelected := True;

      if (AItem.IsCheckable) and (AItem.AutoCheck) then
      begin
        AItem.IsChecked := (not AItem.IsChecked) or (AItem.FCheckableControl is TListViewExItemRadiobutton);
      end;

      Repaint;

      AObj := AItem.FObjects.ObjectAtPos(x, y);
      TTask.Run(
        procedure
        begin
          Sleep(100);
          TThread.Synchronize(nil,
            procedure
            begin
              AItem.FSelected := False;
              Repaint;
              if Assigned(FOnItemClick) then
                FOnItemClick(Self, AItem, AObj);
            end
          );
        end
      );
    end;
  end;
end;

procedure TListViewEx.Paint;
var
  ARect: TRectF;
  AItem: TListViewExItem;
begin
  if FUpdateCount > 0 then
    Exit;
  if (csDesigning in ComponentState) then
    DrawDesignBorder(claDimgray, claDimgray);

  inherited Paint;

  Canvas.Fill.Color := FBackgroundColor;
  Canvas.FillRect(ClipRect, 0, 0, AllCorners, 1);

  if (FScrollPos < -30) and (FPullToRefresh.Enabled) then
    DrawPullToRefresh(Canvas);

  for AItem in FItemsInView do
  begin
    ARect := AItem.ItemRect;
    ARect.Offset(0, 0-FScrollPos);
    AItem.DrawToCanvas(Canvas, ARect);
  end;
  if (FItems.Count = 0) and (FEmptyText <> '') then
  begin
    Canvas.Fill.Color := claSilver;
    Canvas.Font.Size := 24;
    Canvas.FillText(ClipRect, FEmptyText, False, 1, [], TTextAlign.Center, TTextAlign.Center);
  end;
end;

procedure TListViewEx.Resize;
begin
  inherited;
  UpdateScrollLimits;
  Invalidate;
end;

procedure TListViewEx.ScrollToItem(AItemIndex: integer);
var
  AItem: TListViewExItem;
  AYPos: single;
begin
  AItem := FItems[AItemIndex];
  AYPos := AItem.ItemRect.Bottom - Height;
  if AYPos > 0 then
  begin
    ScrollPos := AYPos;
    FAniCalc.ViewportPosition := TPointD.Create(0, AYPos);
    FAniCalc.UpdatePosImmediately(True);
  end;
end;

procedure TListViewEx.ScrollToEnd(AAnimate: Boolean);
begin
  if Items.Count > 0 then
  begin
    case AAnimate of
      False: ScrollToItem(Items.Count-1);
      True: begin
              FAniCalc.UpdatePosImmediately(True);
              TAnimator.AnimateFloat(Self, 'ScrollPos', FMaxScrollPos);
            end;
    end;
  end;
end;

procedure TListViewEx.ScrollToStart;
begin
  FScrollPos := 0;
  if FUpdateCount = 0 then
    FAniCalc.UpdatePosImmediately(True);
end;

procedure TListViewEx.ScrollToFirstChecked;
var
  ICount: integer;
begin
  for ICount := 0 to FItems.Count-1 do
  begin
    if FItems[ICount].IsChecked then
    begin
      ScrollToItem(ICount);
      Exit;
    end;
  end;
end;

procedure TListViewEx.SetBackgroundColor(const Value: TAlphaColor);
begin
  if FBackgroundColor <> Value then
  begin
    FBackgroundColor := Value;
    Invalidate;
  end;
end;

procedure TListViewEx.SetEmptyText(const Value: string);
begin
  FEmptyText := Value;
  Invalidate;
end;

procedure TListViewEx.SetItemHeight(const Value: integer);
begin
  FItemHeight := Value;
end;

procedure TListViewEx.SetPullToRefresh(const Value: TListViewExPullToRefresh);
begin
  FPullToRefresh.Assign(Value);
end;

procedure TListViewEx.SetScrollPos(const Value: single);
begin
  if not SameValue(Value, FScrollPos, TEpsilon.Vector) then
  begin
    FScrollPos := Value;
    FAniCalc.ViewportPosition := TPointD.Create(0, FScrollPos);

    FItems.ItemsInViewport(Viewport, FItemsInView);



    Invalidate;




    if Assigned(FOnScroll) then
      FOnScroll(Self);

    if (FScrollPos <= -80) and (FAniCalc.Down) and (FPullToRefresh.Enabled) then
    begin
      FAniCalc.MouseLeave;
      if Assigned(FOnPullRefresh) then
        FOnPullRefresh(Self);
    end;

  end;
end;

procedure TListViewEx.SetShowSearch(const Value: Boolean);
begin
  FShowSearch := Value;
  FFilterEdit.Visible := Value;
  UpdateScrollLimits;
end;

procedure TListViewEx.SetShowSeperators(const Value: Boolean);
begin
  FShowSeperators := Value;
  Invalidate;
end;

procedure TListViewEx.AniCalcStart(Sender: TObject);
begin
  if Scene <> nil then
    Scene.ChangeScrollingState(Self, True);
end;

procedure TListViewEx.AniCalcChange(Sender: TObject);
begin
  ScrollPos := FAniCalc.ViewportPosition.y;
end;

procedure TListViewEx.AniCalcStop(Sender: TObject);
begin
  if Scene <> nil then
    Scene.ChangeScrollingState(nil, False);
end;

procedure TListViewEx.BeginUpdate;

begin
  FSaveScroll := FScrollPos;
  FAniCalc.UpdatePosImmediately(True);
  FAniCalc.MouseLeave;
  Inc(FUpdateCount);
end;

procedure TListViewEx.UpdateScrollLimits;
var
  Targets: array of TAniCalculations.TTarget;

begin
  CalculateItemRects;
  //if FTotalItemHeight = 0 then
  //  Exit;

  if FAniCalc <> nil then
  begin
    FAniCalc.OnStop := nil;
    FAniCalc.OnChanged := nil;
    SetLength(Targets, 2);
    Targets[0].TargetType := TAniCalculations.TTargetType.Min;
    Targets[0].Point := TPointD.Create(0, 0);
    Targets[1].TargetType := TAniCalculations.TTargetType.Max;

    FMaxScrollPos := Max((FTotalItemHeight - Height), 0);



    Targets[1].Point := TPointD.Create(0, FMaxScrollPos);
    FAniCalc.SetTargets(Targets);

    FAniCalc.ViewportPosition := PointF(0, FScrollPos);
    FAniCalc.OnChanged := AniCalcChange;
    FAniCalc.OnStop := AniCalcStop;
  end;
end;

procedure TListViewEx.SetupInertialMovement;
begin
  FAniCalc.OnChanged := AniCalcChange;
  FAniCalc.ViewportPositionF := PointF(0, FScrollPos);
  FAniCalc.UpdatePosImmediately;
  FAniCalc.Animation := True;
  FAniCalc.Averaging := True;
  FAniCalc.Interval := 8;
  FAniCalc.BoundsAnimation := True;
  FAniCalc.TouchTracking := [ttVertical];
  FAniCalc.OnChanged := AniCalcChange;
  FAniCalc.OnStart := AniCalcStart;
  FAniCalc.OnStop := AniCalcStop;
end;

{ TListViewExItem }

function TListViewExItem.AddCheckbox(AChecked: Boolean; AHorzAlign: TTextAlign; AVertAlign: TTextAlign): TListViewExItemCheckbox;
begin
  Result := TListViewExItemCheckbox.Create(Self);
  Result.HorzAlign := AHorzAlign;
  Result.VertAlign := AVertAlign;
  Result.Checked := AChecked;
  FObjects.Add(Result);

end;

function TListViewExItem.AddRadiobutton(AChecked: Boolean; AHorzAlign: TTextAlign; AVertAlign: TTextAlign): TListViewExItemRadiobutton;
begin
  Result := TListViewExItemRadiobutton.Create(Self);
  Result.HorzAlign := AHorzAlign;
  Result.VertAlign := AVertAlign;
  Result.Checked := AChecked;
  FObjects.Add(Result);
end;

function TListViewExItem.AddRectangle(AHorzAlign: TTextAlign; const AVertAlign: TTextAlign): TListViewExRectangle;
begin
  Result := TListViewExRectangle.Create(Self);
  Result.HorzAlign := AHorzAlign;
  Result.VertAlign := AVertAlign;
  FObjects.Add(Result);
end;

function TListViewExItem.AddSwitch(AChecked: Boolean; AHorzAlign, AVertAlign: TTextAlign): TListViewExItemSwitch;
begin
  Result := TListViewExItemSwitch.Create(Self);
  Result.HorzAlign := AHorzAlign;
  Result.VertAlign := AVertAlign;
  FObjects.Add(Result);
end;

function TListViewExItem.AddButton(AText: string; AWidth: single; AHorzAlign: TTextAlign; const AVertAlign: TTextAlign = TTextAlign.Center): TListViewExItemButton;
begin
  Result := TListViewExItemButton.Create(Self);
  Result.HorzAlign := AHorzAlign;
  Result.VertAlign := AVertAlign;
  Result.Button.Text := AText;
  Result.Width := AWidth;
  FObjects.Add(Result);
end;

function TListViewExItem.AddText(AText: string; AHorzAlign: TTextAlign; const AVertAlign: TTextAlign = TTextAlign.Center): TListViewExText;
begin
  Result := TListViewExText.Create(Self);
  Result.Text := AText;
  Result.HorzAlign := AHorzAlign;
  Result.VertAlign := AVertAlign;

  FObjects.Add(Result);
end;

function TListViewExItem.AddEdit(AText, APlaceholder: string; AHorzAlign: TTextAlign; const AVertAlign: TTextAlign): TListViewExItemEdit;
begin
  Result := TListViewExItemEdit.Create(Self);
  Result.HorzAlign := AHorzAlign;
  Result.VertAlign := AVertAlign;
  Result.Edit.Text := AText;
  Result.Width := 200;
  Result.Edit.TextPrompt := APlaceholder;
  FObjects.Add(Result);
end;

function TListViewExItem.AddPill(AText: string; AColor, ATextColor: TAlphaColor; const AHorzAlign: TTextAlign = TTextAlign.Trailing): TListViewExItemPill;
begin
  Result := TListViewExItemPill.Create(Self);
  Result.Fill.Color := AColor;
  Result.Stroke.Color := AColor;
  Result.TextColor := ATextColor;
  Result.Text := AText;
  Result.HorzAlign := AHorzAlign;
  Result.VertAlign := TTextAlign.Center;
  FObjects.Add(Result);
end;

function TListViewExItem.AddProgressBar(APos, AMax: integer;
                                        AColor: TAlphaColor;
                                        const ABorder: TAlphaColor = claDarkgray;
                                        const AHorzAlign: TTextAlign = TTextAlign.Center;
                                        const AVertAlign: TTextAlign = TTextAlign.Center): TListViewExItemProgressBar;
begin
  Result := TListViewExItemProgressBar.Create(Self);
  Result.HorzAlign := AHorzAlign;
  Result.VertAlign := AVertAlign;
  Result.Max := AMax;
  Result.Value := APos;
  Result.Width := 180;
  Result.Height := 10;
  Result.Color := AColor;
  Result.Border := ABorder;
  FObjects.Add(Result);
end;

function TListViewExItem.AddImage(AImage: TBitmap; AHorzAlign: TTextAlign; const AVertAlign: TTextAlign = TTextAlign.Center): TListViewExImage;
begin
  Result := TListViewExImage.Create(Self);
  Result.Bitmap := AImage;
  Result.HorzAlign := AHorzAlign;
  Result.VertAlign := AVertAlign;
  FObjects.Add(Result);
end;

constructor TListViewExItem.Create;
begin
  FUpdating := True;

  FObjects := TListViewExItemObjects.Create;

  FImage := TListViewExImage.Create(Self);
  FImage.HorzAlign := TTextAlign.Leading;
  FImage.Width := 24;
  FImage.Height := 24;

  FTitle := TListViewExText.Create(Self);
  FTitle.HorzAlign := TTextAlign.Leading;


  FSubTitle := TListViewExText.Create(Self);
  FSubTitle.HorzAlign := TTextAlign.Leading;
  FSubTitle.FTextSettings.FontColor := claDarkgray;

  FDetail := TListViewExText.Create(Self);
  FDetail.HorzAlign := TTextAlign.Trailing;
  FDetail.FTextSettings.HorzAlign := TTextAlign.Trailing;
  FDetail.FTextSettings.FontColor := claDodgerblue;
  FDetail.FTextSettings.Font.Size := 14;

  FPurpose := lvItem;
  FAccessory := accNone;
  FSelected := False;
  FClickEffect := True;

  FAutocheck := False;

  FUpdating := False;
end;

destructor TListViewExItem.Destroy;
begin
  FObjects.Free;
  FImage.Free;
  FTitle.Free;
  FSubTitle.Free;
  FDetail.Free;

  inherited;
end;

procedure TListViewExItem.DrawAccessory(ACanvas: TCanvas; ARect: TRectF);
begin
  ACanvas.Stroke.Color := claSilver;
  ACanvas.Stroke.Thickness := 2;
  ACanvas.DrawLine(PointF(ARect.Right-4, ARect.CenterPoint.Y),
                   PointF(ARect.CenterPoint.X, ARect.CenterPoint.Y-8),
                   1);

  ACanvas.DrawLine(PointF(ARect.Right-4, ARect.CenterPoint.Y),
                   PointF(ARect.CenterPoint.X, ARect.CenterPoint.Y+8),
                   1);
  ACanvas.Stroke.Thickness := 1;

end;

procedure TListViewExItem.DrawToCanvas(ACanvas: TCanvas; ARect: TRectF);
var
  ADrawable: TListViewExItemObject;
  AInternalRect: TRectF;
  AColor: TAlphaColor;
  AState: TCanvasSaveState;
begin
  if FListViewEx.FUpdateCount > 0 then
    Exit;

  AState := ACanvas.SaveState;
  try
    ACanvas.IntersectClipRect(ARect);

    ACanvas.Stroke.Kind := TBrushKind.Solid;
    ACanvas.Stroke.Thickness := 1;

    AColor := claWhite;
    if (FShowBackgroundColor) and (FBackgroundColor > 0) then
      AColor := FBackgroundColor;

    case FPurpose of
      lvItem: ACanvas.Fill.Color := AColor;
      lvHeader: ACanvas.Fill.Color := claWhitesmoke;
    end;

    if (FSelected) and (FClickEffect) then
      ACanvas.Fill.Color := $FFC6EBFB;

    ACanvas.FillRect(ARect, 0, 0, AllCorners, 1);

    if (FTitle.Text <> '') and (FSubTitle.Text <> '') then
    begin
      // offset labels..
     FTitle.Offset := Point(0, -10);
    FSubTitle.Offset := Point(0, +10);
    end;

    AInternalRect := ARect;
    AInternalRect.Inflate(-4, 0);

    if not FImage.Bitmap.IsEmpty then
    begin

      FImage.DrawToCanvas(ACanvas, AInternalRect);

      AInternalRect.Left := AInternalRect.Left + 32 + (FImage.Width - 24);

    end;

    if FAccessory <> accNone then
    begin
      DrawAccessory(ACanvas,
                    RectF(ARect.Right-30, ARect.Top, ARect.Right-6, ARect.Bottom));
      case FAccessory of
        accMore: AInternalRect.Right := AInternalRect.Right - 20;
        accCheckBox,
        accCheckBoxChecked: AInternalRect.Right := AInternalRect.Right - 24;
      end;

    end;

    if FDetail.Text = '' then
    begin
      FTitle.Width := AInternalRect.Width;
      FSubTitle.Width := AInternalRect.Width;
    end
    else
    begin
      FTitle.Width := AInternalRect.Width / 1.5;
      FSubTitle.Width := AInternalRect.Width / 1.5;
      FDetail.Width := AInternalRect.Width / 1.5;
    end;



    FTitle.Height := CalculateTextSize(ACanvas, FTitle.Text, FTitle.TextSettings.Font, FTitle.Width, 0).Height;
    FSubTitle.Height := CalculateTextSize(ACanvas, FSubTitle.Text, FSubTitle.TextSettings.Font, FSubTitle.Width, 0).Height;
    FDetail.Height := CalculateTextSize(ACanvas, FDetail.Text, FDetail.TextSettings.Font, FDetail.Width, 0).Height;

    if FTitle.Text <> '' then FTitle.DrawToCanvas(ACanvas, AInternalRect);
    if FSubTitle.Text <> '' then FSubTitle.DrawToCanvas(ACanvas, AInternalRect);
    if FDetail.Text <> '' then FDetail.DrawToCanvas(ACanvas, AInternalRect);

    for ADrawable in FObjects do
    begin
      ADrawable.DrawToCanvas(ACanvas, AInternalRect);
    end;

    if (FPurpose <> lvHeader) and (FListViewEx.ShowSeperators) then
    begin
      ACanvas.Stroke.Color := claSilver;
      if (FIndex = 0) or ((FIndex > 0) and (FListViewEx.Items[FIndex-1].Purpose = lvHeader)) then
        ACanvas.DrawLine(PointF(ARect.Left, ARect.Top), PointF(ARect.Right, ARect.Top), 1);
      ACanvas.DrawLine(PointF(ARect.Left, ARect.Bottom), PointF(ARect.Right, ARect.Bottom), 1);
      ACanvas.Fill.Color := claBlack;
    end;
  finally
    ACanvas.RestoreState(AState);
  end;
end;

function TListViewExItem.GetIsCheckable: Boolean;
begin
  Result := (FCheckableControl <> nil);
end;

function TListViewExItem.GetIsChecked: Boolean;
begin
  Result := False;
  if Assigned(FCheckableControl) then
    Result := FCheckableControl.Checked;
end;

procedure TListViewExItem.HideControls;
var
  AObj: TListViewExItemObject;
  ACtrl: TListViewExItemControl;
begin
  for AObj in FObjects do
  begin
    if (AObj is TListViewExItemControl)  then
    begin
      ACtrl := (AObj as TListViewExItemControl);
      ACtrl.HideControl;
    end;
  end;
end;

function TListViewExItem.MatchesFilter(AFilter: string): Boolean;
begin
  Result := (AFilter = '') or (FTitle.Text.ToLower.Contains(AFilter.ToLower));
end;

procedure TListViewExItem.SetHeight(const Value: single);
begin
  if not SameValue(Value, FHeight, TEpsilon.Vector) then
  begin
    FHeight := Value;
    FListViewEx.CalculateItemRects;
    FListViewEx.Invalidate;
  end;
end;

procedure TListViewExItem.SetIsChecked(const Value: Boolean);
begin
  if FCheckableControl <> nil then FCheckableControl.Checked := Value;
end;

procedure TListViewExItem.SetPurpose(const Value: TListViewItemExPurpose);
begin
  FPurpose := Value;
end;
                {
procedure TListViewExItem.SetTitle(const Value: TListViewExText);
begin
  FTitle.Assign(Value);
  FListViewEx.Invalidate;
end;    }

{ TListViewExItems }

function TListViewExItems.AddHeader(AText: string): TListViewExItem;
begin
  Result := AddItem(AText);
  Result.Purpose := lvHeader;
  Result.Title.Offset := PointF(0, 8);
end;

function TListViewExItems.AddItem(ATitle: string; const AAccessory: TListViewItemExAccessory = accNone): TListViewExItem;
begin
  Result := AddItem(nil, ATitle, AAccessory);

end;

function TListViewExItems.AddItem(AImg: TBitmap; ATitle: string; const AAccessory: TListViewItemExAccessory = accNone): TListViewExItem;
begin
  Result := TListViewExItem.Create;
  Result.FListViewEx := FListViewEx;
  Result.Title.Text := ATitle;
  Result.Height := FListViewEx.ItemHeight;
  Result.Accessory := AAccessory;
  Add(Result);

  if FListViewEx.FUpdateCount = 0 then
  begin
    Reindex;
    FListViewEx.CalculateItemRects;
    FListViewEx.UpdateScrollLimits;
  end;
end;

function TListViewExItems.AddItem(AImg: TBitmap; ATitle, ADetail: string; const AAccessory: TListViewItemExAccessory = accNone): TListViewExItem;
begin
   Result := AddItem(AImg, ATitle, AAccessory);
   Result.Detail.Text := ADetail;
end;

function TListViewExItems.AddBubbleItem(AText, ASender: string; ABubbleColor, ATextColor: TAlphaColor; ADateTime: TDateTime; AAlign: TBubbleAlign): TListViewExItem;
var
  ATextObj: TListViewExText;
  ARectangle: TListViewExRectangle;
  ABubbleAlign: TTextAlign;
  ASize: TSizeF;
  ASenderObj: TListViewExText;

begin

  Result := AddItem('');


  Result.ClickEffect := False;
  ABubbleAlign := TTextAlign.Leading;
  case AAlign of
    baLeft: ABubbleAlign := TTextAlign.Leading;
    baRight: ABubbleAlign := TTextAlign.Trailing;
  end;

  ASenderObj := Result.AddText(FormatDateTime('h:nn am/pm', ADateTime)+'  '+ ASender, ABubbleAlign, TTextAlign.Leading);
  ASenderObj.TextSettings.font.Size := 13;
  ASenderObj.TextSettings.HorzAlign := ABubbleAlign;

  ARectangle := Result.AddRectangle(ABubbleAlign, TTextAlign.Leading);
  ARectangle.Fill.Color := ABubbleColor;
  ARectangle.Stroke.Color := ABubbleColor;


  ARectangle.VertAlign := TTextAlign.Leading;
  ATextObj := Result.AddText('', ABubbleAlign, TTextAlign.Center);
  ATextObj.VertAlign := TTextAlign.Leading;

  ATextObj.TextSettings.Font.Size := 15;
  ATextObj.TextSettings.FontColor := ATextColor;
  ATextObj.Text := AText;

  //AObj.Offset := TPointF.Create(0, 30);
  ASize.Height := 1000;
  ASize := CalculateTextSize(nil, AText, ATextObj.TextSettings.Font, (FListViewEx.Width*0.6), 8);

  ATextObj.Height := ASize.Height;
  ATextObj.Width := ASize.Width;


  ATextObj.Offset := TPointF.Create(0, 8);
  case ABubbleAlign of
    TTextAlign.Leading: ATextObj.Offset.Offset(8, 0);
    TTextAlign.Trailing: ATextObj.Offset.Offset(-8, 0);
  end;


  ARectangle.Width := ATextObj.Width+16;
  ARectangle.Height := ATextObj.Height+16;

  ARectangle.Offset := TPointF.Create(0, 22);
  ATextObj.Offset.Offset(0, 22);


  Result.Height := ARectangle.Height+36;

end;


function TListViewExItems.AddItemCheckbox(AImg: TBitmap; ATitle: string; AChecked: Boolean): TListViewExItem;
begin
  Result := AddItem(AImg, ATitle, accNone);
  Result.FCheckableControl := Result.AddCheckbox(AChecked, TTextAlign.Trailing, TTextAlign.Center);
  Result.AutoCheck := True;
  Result.IsChecked := AChecked;
end;

function TListViewExItems.AddItemRadiobutton(AImg: TBitmap; ATitle: string; AChecked: Boolean): TListViewExItem;
begin
  Result := AddItem(AImg, ATitle, accNone);
  Result.FCheckableControl := Result.AddRadiobutton(AChecked, TTextAlign.Trailing, TTextAlign.Center);
  Result.AutoCheck := True;
end;

procedure TListViewExItems.AddSeperator;
var
  AItem: TListViewExItem;
begin
  AItem := AddHeader('');
  AItem.Height := 20;
end;

constructor TListViewExItems.Create(AOwner: TComponent);
begin
  inherited Create;
  FListViewEx := AOwner as TListViewEx;
end;

procedure TListViewExItems.ItemsInViewport(AViewport: TRectF; AItems: TList<TListViewExItem>);
var
  ARectF: TRectF;
  AItem: TListViewExItem;
begin
  AItems.Clear;

  for AItem in Self do
  begin
    if (FListViewEx.FShowSearch = False) or (AItem.MatchesFilter(FListViewEx.FFilterEdit.Text)) then
    begin
      ARectF := AItem.ItemRect;
      if AViewport.IntersectsWith(ARectF) then
        AItems.Add(AItem)
      else
        AItem.HideControls;
    end
    else
    begin
      // hide controls outside of viewport
      AItem.HideControls;
    end;
  end;
end;

procedure TListViewExItems.Notify(const Value: TListViewExItem; Action: TCollectionNotification);
begin
  inherited;
  if Action in [cnAdding, cnAdded] then
  begin
    Value.FListViewEx := FListViewEx;
    Value.FHeight := FListViewEx.ItemHeight;
  end;

  if FListViewEx.FUpdateCount > 0 then
    Exit;
  Reindex;
  FListViewEx.CalculateItemRects;
  FListViewEx.UpdateScrollLimits;
end;

procedure TListViewExItems.Reindex;
var
  AIndex: integer;
begin
  for AIndex := 0 to Count-1 do
    Items[AIndex].FIndex := AIndex;
end;

{ TListViewExItemObject }

function TListViewExItemObject.CalculateRect(AItemRect: TRectF): TRectF;
begin
  Result := RectF(AItemRect.Left, AItemRect.Top, AItemRect.Left+FWidth, AItemRect.Top+FHeight);

  case FHorzAlign of
    TTextAlign.Center: Result.Offset((AItemRect.Width - Result.Width) / 2, 0);
    TTextAlign.Trailing: Result.Offset((AItemRect.Width - Result.Width), 0);
  end;
  case FVertAlign of
    TTextAlign.Center: Result.Offset(0, (AItemRect.Height - Result.Height) / 2);
    TTextAlign.Trailing: Result.Offset(0, (AItemRect.Height - Result.Height));
  end;
  Result.Offset(FOffset);
end;
                    {
procedure TListViewExItemObject.ClearBuffer(Sender: TObject);
begin
  ClearBuffer;
end;

procedure TListViewExItemObject.ClearBuffer;
begin

end;         }

constructor TListViewExItemObject.Create(AItem: TListViewExItem);
begin
  inherited Create;
  FListView := AItem.FListViewEx;
  FOwner := AItem;
  FVisible := True;
end;

procedure TListViewExItemObject.DrawObject(ACanvas: TCanvas; AObjectRect: TRectF);
begin

end;

procedure TListViewExItemObject.DrawToCanvas(ACanvas: TCanvas; AItemRect: TRectF);
begin

  if (FVisible) then
  begin
    //AItemRect.Inflate(-8, -6);    *****
    AItemRect.Inflate(-8, 0);
    FRect := CalculateRect(AItemRect);
    DrawObject(ACanvas, FRect);
  end;
end;



procedure TListViewExItemObject.SetHeight(const Value: single);
begin
  if CompareValue(FHeight, Value, TEpsilon.Vector) <> 0 then
  begin
    FHeight := Value;
    //ClearBuffer;
  end;
end;

procedure TListViewExItemObject.SetHorzAlign(const Value: TTextAlign);
begin
  if FHorzAlign <> Value then
  begin
    FHorzAlign := Value;
    //ClearBuffer;
  end;
end;

procedure TListViewExItemObject.SetOffset(AOffset: TPointF);
begin
  FOffset := AOffset;
  //ClearBuffer;
end;

procedure TListViewExItemObject.SetSize(AWidth, AHeight: single);
begin
  FWidth := AWidth;
  FHeight := AHeight;
  //ClearBuffer;
end;

procedure TListViewExItemObject.SetVertAlign(const Value: TTextAlign);
begin
  if FVertAlign <> Value then
  begin
    FVertAlign := Value;
    //ClearBuffer;
  end;
end;

procedure TListViewExItemObject.SetVisible(const Value: Boolean);
begin
  if FVisible <> Value then
  begin
    FVisible := Value;
    //ClearBuffer;
  end;
end;

procedure TListViewExItemObject.SetWidth(const Value: single);
begin
  if CompareValue(FWidth, Value, TEpsilon.Vector) <> 0 then
  begin
    FWidth := Value;
    //ClearBuffer;
  end;
end;

{procedure TListViewExItemObject.UpdateBuffer;
begin
  //
end;}

{ TListViewExText }

constructor TListViewExText.Create(AItem: TListViewExItem);
begin
  inherited Create(AItem);
  FTextSettings := TTextSettings.Create(nil);
  FTextSettings.Font.Size := 16;
  //FTextSettings.OnChanged := ClearBuffer;
  FWidth := 150;
  //FBuffer := TBitmap.Create;
end;

destructor TListViewExText.Destroy;
begin
  FTextSettings.Free;
  //FBuffer.Free;
  inherited;
end;

procedure TListViewExText.DrawObject(ACanvas: TCanvas; AObjectRect: TRectF);
var
  ALayout: TSkTextLayout;
begin
  inherited;
  try
    ACanvas.Fill.Color := claBlack;
    ACanvas.Font.Assign(FTextSettings.Font);
    ACanvas.Fill.Color := FTextSettings.FontColor;
    ALayout := TSkTextLayout.Create(ACanvas);
    try
      ALayout.BeginUpdate;
      ALayout.Text := FText;
      ALayout.Font.Assign(FTextSettings.Font);
      ALayout.Color := FTextSettings.FontColor;
      ALayout.HorizontalAlign := FTextSettings.HorzAlign;

      ALayout.WordWrap := True;
      ALayout.MaxSize := TPointF.Create(AObjectRect.Width, 1000);
      ALayout.TopLeft := AObjectRect.TopLeft;
      ALayout.EndUpdate;
      ALayout.RenderLayout(ACanvas) ;
      //ACanvas.Stroke.Color := claRed;
      //ACanvas.DrawRect(AObjectRect, 1);
    finally
      ALayout.Free;
    end;
  finally


  end;
end;


procedure TListViewExText.SetText(const Value: string);
begin
  if FText <> Value then
  begin
    FText := Value;
    //FBuffer.SetSize(0,0);
  end;
end;

{ TListViewExImage }

constructor TListViewExImage.Create(AItem: TListViewExItem);
begin
  inherited Create(AItem);
  FBitmap := TBitmap.Create;
end;

destructor TListViewExImage.Destroy;
begin
  FBitmap.Free;
  inherited;
end;

procedure TListViewExImage.DrawObject(ACanvas: TCanvas; AObjectRect: TRectF);
begin
  inherited;
  ACanvas.DrawBitmap(FBitmap,
                     RectF(0, 0, FBitmap.Width, FBitmap.Height),
                     AObjectRect,
                     1,
                     True);
end;

procedure TListViewExImage.SetBitmap(const Value: TBitmap);
begin
  FBitmap.Assign(Value);
  FWidth := 28;
  FHeight := 28;

end;

{ TListViewExItemSwitch }

function TListViewExItemSwitch.CreateControl: TControl;
begin
  Result := TSwitch.Create(FListView);
end;

function TListViewExItemSwitch.GetSwitch: TSwitch;
begin
  Result := (GetControl as TSwitch);
end;

{ TListViewExItemControl }

constructor TListViewExItemControl.Create(AItem: TListViewExItem);
begin
  inherited Create(AItem);
  FControl := CreateControl;
  FOwner.FListViewEx.AddObject(FControl);

  InitializeControl;
  FWidth := Round(FControl.Width);
  FHeight := Round(FControl.Height);


  FControl.Visible := False;
end;

destructor TListViewExItemControl.Destroy;
begin
  FControl.Free;
  inherited;
end;

procedure TListViewExItemControl.DrawObject(ACanvas: TCanvas; AObjectRect: TRectF);
begin
  inherited;

  FControl.SetBounds(AObjectRect.Left, AObjectRect.Top, AObjectRect.Width, AObjectRect.Height);
  if not FControl.Visible then
  begin
    FControl.Visible := True;
    FControl.SendToBack;
    //FCache.SaveToFile('c:\temp\control.png');
  end;
end;

function TListViewExItemControl.GetControl: TControl;
begin
  Result := FControl;
end;

procedure TListViewExItemControl.HideControl;
begin
  FControl.Visible := False;
end;

procedure TListViewExItemControl.InitializeControl;
begin
  //
end;

procedure TListViewExItemControl.SetHeight(const Value: single);
begin
  inherited;
  FControl.Height := Value;
end;

procedure TListViewExItemControl.SetWidth(const Value: single);
begin
  inherited;
  FControl.Width := Value;
end;

{ TListViewExItemButton }

function TListViewExItemButton.CreateControl: TControl;
begin
  Result := TButton.Create(FListView);
  (Result as TButton).StyleLookup := 'listitembutton';
  (Result as TButton).CanFocus := False;
  (Result as TButton).OnClick := DoClick;
  //(Result as TButton).Width := 100 / GetScreenScale;
end;

procedure TListViewExItemButton.DoButtonResized(Sender: TObject);
begin
  FWidth := (Sender as TButton).Width;
  FHeight := (Sender as TButton).Height;
end;

procedure TListViewExItemButton.DoClick(Sender: TObject);
begin
  if Assigned(FListView.OnItemClick) then
  begin
    FListView.OnItemClick(FListView, FOwner, Self);
  end;

end;

(*procedure TListViewExItemButton.DrawObject(ACanvas: TCanvas; AObjectRect: TRectF);
var
  ABtn: TButton;
  ABitmap: TBitmap;
begin
  inherited;

//  ABtn := Button;
//  ABtn.SetBounds(AObjectRect.Left, AObjectRect.Top, AObjectRect.Width, AObjectRect.Height);

{  ABitmap := ABtn.MakeScreenshot;
  ABitmap.SaveToFile('c:\temp\button.png');
  ABitmap.Free;       }


 { if not ABtn.Visible then
  begin
    ABtn.Visible := True;
    ABtn.SendToBack;
  end;}    *
end;      *)

function TListViewExItemButton.GetButton: TButton;
begin
  Result := (GetControl as TButton);

end;


procedure TListViewExItemButton.InitializeControl;
begin
  inherited;
  Button.ApplyStyleLookup;
  Button.RecalcSize;
  FWidth := Button.Width;
  FHeight:= Button.Height;
  Button.OnResize := DoButtonResized;
end;

{ TListViewExItemRadioButton }

function TListViewExItemRadioButton.CreateControl: TControl;
begin
  Result := TRadioButton.Create(FListView);
  Result.Width := 24;
  Result.OnResize := DoRadioResized;
end;

procedure TListViewExItemRadiobutton.DoRadioResized(Sender: TObject);
begin
  FHeight := Radiobutton.Height;
  FWidth := FHeight;
end;

function TListViewExItemRadiobutton.GetIsChecked: Boolean;
begin
  Result := Radiobutton.IsChecked;
end;

{
procedure TListViewExItemRadioButton.DrawObject(ACanvas: TCanvas; AObjectRect: TRectF);
var
  ARadio: TRadioButton;
begin
  inherited;
  ARadio := Radiobutton;
  ARadio.SetBounds(AObjectRect.Left, AObjectRect.Top, AObjectRect.Width, AObjectRect.Height);
  if not ARadio.Visible then
  begin
    ARadio.Visible := True;
    ARadio.SendToBack;
  end;
end;  }

function TListViewExItemRadioButton.GetRadioButton: TRadioButton;
begin
  Result := (FControl as TRadioButton);
end;

procedure TListViewExItemRadiobutton.SetIsChecked(const Value: Boolean);
begin
  Radiobutton.IsChecked := Value;
end;

{ TListViewExPullToRefresh }

constructor TListViewExPullToRefresh.Create;
begin
  FText := 'PULL TO REFRESH';
end;

{ TListViewExItemObjects }

function TListViewExItemObjects.ObjectAtPos(x, y: single): TListViewExItemObject;
var
  AObj: TListViewExItemObject;
begin
  Result := nil;
  for AObj in Self do
  begin
    if PtInRect(AObj.FRect, PointF(x, y)) then
    begin
      Result := AObj;
      Exit;
    end;
  end;
end;

{ TListViewExItemEdit }

function TListViewExItemEdit.CreateControl: TControl;
begin
  Result := TEdit.Create(FListView);
 // (Result as TEdit).OnEnter := OnFocus;
end;

function TListViewExItemEdit.GetEdit: TEdit;
begin
  Result := (FControl as TEdit);
end;

{ TListViewExItemProgressBar }

procedure TListViewExItemProgressBar.DrawObject(ACanvas: TCanvas; AObjectRect: TRectF);
var
  AState: TCanvasSaveState;
  ABarRect: TRectF;
begin
  inherited;
  ABarRect := AObjectRect;
 AState := ACanvas.SaveState;
  try
    ACanvas.IntersectClipRect(AObjectRect);
    ACanvas.Stroke.Kind := TBrushKind.None;
    ACanvas.Fill.Kind := TBrushKind.Solid;
    ABarRect.Width := (ABarRect.Width / FMax) * FValue;

    ACanvas.Fill.Color := claWhitesmoke;
    ACanvas.FillRect(AObjectRect, 0,0, AllCorners, 1);

    ACanvas.Fill.Color := FColor;
    ACanvas.FillRect(ABarRect, 0,0, AllCorners, 0.6);

    ACanvas.Stroke.Color := FBorder;

    ACanvas.Stroke.Kind := TBrushKind.Solid;
    ACanvas.DrawRect(AObjectRect, 0,0, AllCorners, 1);
  finally
    ACanvas.RestoreState(AState);
  end;
end;

{ TListViewExItemCheckbox }

function TListViewExItemCheckbox.CreateControl: TControl;
begin
  Result := TCheckBox.Create(FListView);
  Result.Width := 24;
  Result.OnResize := DoCheckboxResized;
end;

procedure TListViewExItemCheckbox.DoCheckboxResized(Sender: TObject);
begin
  FHeight := Checkbox.Height;
  FWidth := FHeight;
end;

function TListViewExItemCheckbox.GetCheckbox: TCheckbox;
begin
  Result := (FControl as TCheckBox);
end;

function TListViewExItemCheckbox.GetIsChecked: Boolean;
begin
  Result := Checkbox.IsChecked;
end;

procedure TListViewExItemCheckbox.SetIsChecked(const Value: Boolean);
begin
  Checkbox.IsChecked := Value;
end;

{ TListViewExRectangle }

constructor TListViewExRectangle.Create(AItem: TListViewExItem);
begin
  inherited;
  FFill := TBrush.Create(TBrushKind.Solid, claGainsboro);
  FStroke := TStrokeBrush.Create(TBrushKind.Solid, claBlack);
  FCornerRadius := 4;
end;

destructor TListViewExRectangle.Destroy;
begin
  FFill.Free;
  FStroke.Free;
  inherited;
end;

procedure TListViewExRectangle.DrawObject(ACanvas: TCanvas; AObjectRect: TRectF);
begin
  inherited;
  ACanvas.Fill.Assign(FFill);
  aCanvas.FillRect(AObjectRect, FCornerRadius, FCornerRadius, AllCorners, 1);
  ACanvas.Stroke.Assign(FStroke);
  ACanvas.DrawRect(AObjectRect, FCornerRadius, FCornerRadius, AllCorners, 1);
end;

procedure TListViewExRectangle.SetCornerRadius(const Value: single);
begin
  FCornerRadius := Value;
  FListView.Invalidate;
end;

procedure TListViewExRectangle.SetFill(const Value: TBrush);
begin
  FFill.Assign(Value);
end;

procedure TListViewExRectangle.SetStroke(const Value: TStrokeBrush);
begin
  FStroke.Assign(Value);
end;

{ TListViewExItemPill }

constructor TListViewExItemPill.Create(AItem: TListViewExItem);
begin
  inherited;
  FFont := TFont.Create;
  Width := 100;
  Height := 24;
  FCornerRadius := 12;
end;

destructor TListViewExItemPill.Destroy;
begin
  FFont.Free;
  inherited;
end;

procedure TListViewExItemPill.DrawObject(ACanvas: TCanvas; AObjectRect: TRectF);
var
  ARect: TRectF;
begin
  inherited;
  ACanvas.Font.Assign(FFont);
  ACanvas.Fill.Color := FTextColor;
  ACanvas.Fill.Kind := TBrushKind.Solid;
  ARect := AObjectRect;
  ARect.Inflate(-8, 0);
  ACanvas.FillText(ARect, FText, False, 1, [], TTextAlign.Center);
end;

procedure TListViewExItemPill.SetText(const Value: string);
var
  ASize: TSizeF;
begin
  FText := Value;
  FFont.Size := 12;
  ASize := CalculateTextSize(nil, FText, FFont, FListView.Width, 0);
  Width := ASize.Width + 16;
end;

procedure TListViewExItemPill.SetTextColor(const Value: TAlphaColor);
begin
  FTextColor := Value;
end;

end.
