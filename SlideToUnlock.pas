{******************************************************************************}
{                                                                              }
{  TSlideToUnlock                                                              }
{                                                                              }
{  Description: Slide control to prevent accidental confirmation               }
{                                                                              }
{  Author:      Graham Murt                                                    }
{                                                                              }
{  Copyright (c) 2025 Graham Murt. All rights reserved.                        }
{                                                                              }
{  License: MIT                                                                }
{                                                                              }
{  Permission is hereby granted, free of charge, to any person obtaining a     }
{  copy of this software and associated documentation files (the "Software"),  }
{  to deal in the Software without restriction, including without limitation   }
{  the rights to use, copy, modify, merge, publish, distribute, sublicense,    }
{  and/or sell copies of the Software, and to permit persons to whom the       }
{  Software is furnished to do so, subject to the following conditions:        }
{                                                                              }
{  The above copyright notice and this permission notice shall be included     }
{  in all copies or substantial portions of the Software.                      }
{                                                                              }
{  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS     }
{  OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF                  }
{  MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.      }
{  IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY        }
{  CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,        }
{  TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE           }
{  SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.                      }
{                                                                              }
{******************************************************************************}

unit SlideToUnlock;

interface

uses FMX.Layouts, FMX.Objects, FMX.Controls, FMX.StdCtrls, Classes, FMX.Types, Generics.Collections,
System.UITypes, System.Types, FMX.Graphics;

type
  TSelectSegmentEvent = procedure(Sender: TObject; ASegmentIndex: integer) of object;

  [ComponentPlatformsAttribute(pidAllPlatforms)]

  TSlideToUnlock = class;

  TSlideToUnlockCaptions = class(TPersistent)
  private
    FOwner: TSlideToUnlock;
    FSlideToUnlockText: string;
    FUnlockedText: string;
    procedure SetSlideToUnlockText(const Value: string);
  public
    constructor Create(AOwner: TSlideToUnlock);
  published
    property SlideToUnlockText: string read FSlideToUnlockText write SetSlideToUnlockText;
    property UnlockedText: string read FUnlockedText write FUnlockedText;

  end;

  TSlideToUnlock = class(TPaintbox)
  private
    FCaptions: TSlideToUnlockCaptions;
    FMouseDown: Boolean;
    FStartX: single;
    FXPos: single;
    FUnlocked: Boolean;
    FOnUnlock: TNotifyEvent;
    FLockedBitmap: TBitmap;
    FUnlockedBitmap: TBitmap;
    procedure ResetThumb;
    procedure SetXPos(const Value: single);
    function ThumbRect: TRectF;
    function GebThumbWidth: single;
    procedure SetLockedBitmap(const Value: TBitmap);
    procedure SetUnlockedBitmap(const Value: TBitmap);
    procedure SetCaptions(const Value: TSlideToUnlockCaptions);
  protected
    procedure Paint; override;
    procedure DoMouseLeave; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Single); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Single); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Single); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Reset;
    property XPos: single read FXPos write SetXPos;
  published
    property Captions: TSlideToUnlockCaptions read FCaptions write SetCaptions;
    property LockedBitmap: TBitmap read FLockedBitmap write SetLockedBitmap;
    property UnlockedBitmap: TBitmap read FUnlockedBitmap write SetUnlockedBitmap;
    property OnUnlock: TNotifyEvent read FOnUnlock write FOnUnlock;
  end;

  procedure Register;

implementation

uses FMX.Ani, System.UIConsts, Math, SysUtils;


procedure Register;
begin
  RegisterComponents('GmFmx', [TSlideToUnlock]);
end;

{ TSlideToUnlock }

constructor TSlideToUnlock.Create(AOwner: TComponent);
begin
  inherited;
  FCaptions := TSlideToUnlockCaptions.Create(Self);
  FLockedBitmap := TBitmap.Create;
  FUnlockedBitmap := TBitmap.Create;
  Width := 200;
  Height := 56;
  SetAcceptsControls(False);
  FMouseDown := False;
end;


destructor TSlideToUnlock.Destroy;
begin
  FLockedBitmap.Free;
  FUnlockedBitmap.Free;
  FCaptions.Free;
  inherited;
end;

procedure TSlideToUnlock.DoMouseLeave;
begin
  inherited;
  FMouseDown := False;
  if not FUnlocked then
  begin
    ResetThumb;
  end;
end;

function TSlideToUnlock.GebThumbWidth: single;
begin
  Result := ThumbRect.Width;
end;

procedure TSlideToUnlock.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
  inherited;
  FMouseDown := (X < Height) and (ssLeft in Shift);
  if FMouseDown then
  begin
    FStartX := X;
    FXPos := 0;
  end;
end;

procedure TSlideToUnlock.MouseMove(Shift: TShiftState; X, Y: Single);
begin
  inherited;
  if (FMouseDown) and (not FUnlocked) then
  begin
    SetXPos(Min((X - FStartX), (Width-Height)));
    InvalidateRect(ClipRect)
  end;
end;

procedure TSlideToUnlock.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
  inherited;
  FMouseDown := False;
  if not FUnlocked then
    ResetThumb;
end;

procedure TSlideToUnlock.Paint;
var
  r: TRectF;
  ABmp: TBitmap;
begin
  inherited;
  Canvas.Stroke.Color := claSilver;
  Canvas.Stroke.Kind := TBrushKind.Solid;
  Canvas.Stroke.Thickness := 1;

  case FUnlocked of
    False: Canvas.Fill.Color := claWhitesmoke;
    True: Canvas.Fill.Color := claPalegreen;
  end;

  Canvas.FillRect(ClipRect, Height / 2, Height / 2, AllCorners, 1);
  Canvas.DrawRect(ClipRect, Height / 2, Height / 2, AllCorners, 1);

  Canvas.Stroke.Color := claSilver;
  Canvas.Stroke.Kind := TBrushKind.Solid;

  if not FUnlocked then
  begin
    Canvas.Fill.color := claDimgray;
    Canvas.Font.Size := 14;
    Canvas.FillText(ClipRect, FCaptions.FSlideToUnlockText, False, 1, [], TTextAlign.Center);
  end
  else
  begin
    Canvas.Fill.color := claDarkgreen;
    Canvas.FillText(ClipRect, FCaptions.FUnlockedText, False, 1, [], TTextAlign.Center);
   end;
  r := ThumbRect;
  r.Inflate(-6, -6);
  Canvas.Fill.Color := claWhite;
  Canvas.FillEllipse(r, 1);
  Canvas.DrawEllipse(r, 1);
  Canvas.Fill.Color := claBlack;



  case FUnlocked of
    True: ABmp := FUnlockedBitmap;
    False: ABmp := FLockedBitmap;
  end;
  r.Inflate(-8, -8);
  Canvas.DrawBitmap(ABmp, RectF(0,0,ABmp.Width, ABmp.Height), r, 1);

end;

procedure TSlideToUnlock.Reset;
begin
  FUnlocked := False;
  SetXPos(0);
  ResetThumb;
end;

procedure TSlideToUnlock.ResetThumb;
begin
  TAnimator.AnimateFloat(Self, 'XPos', 0);
  FUnlocked := False;
end;

procedure TSlideToUnlock.SetCaptions(const Value: TSlideToUnlockCaptions);
begin
  FCaptions.Assign(Value);
end;

procedure TSlideToUnlock.SetLockedBitmap(const Value: TBitmap);
begin
  FLockedBitmap.Assign(Value);
end;

procedure TSlideToUnlock.SetUnlockedBitmap(const Value: TBitmap);
begin
  FUnlockedBitmap.Assign(Value);
end;

procedure TSlideToUnlock.SetXPos(const Value: single);
begin
  if not FUnlocked then
  begin
    FXPos := Value;

    FUnlocked := FXPos >= (Width-GebThumbWidth);
    if FUnlocked then
    begin
      if Assigned(FOnUnlock) then
        FOnUnlock(Self);
    end;
  end
  else
    FXPos := Width - ThumbRect.Width;

  InvalidateRect(ClipRect);
end;

function TSlideToUnlock.ThumbRect: TRectF;
begin
  Result := RectF(0, 0, Height, Height);

  if FUnlocked then
  begin
    Result.Offset(Width-Height, 0);
  end
  else
    Result.Offset(FXPos, 0);
end;

{ TSlideToUnlockCaptions }

constructor TSlideToUnlockCaptions.Create(AOwner: TSlideToUnlock);
begin
  inherited Create;
  FOwner := AOwner;
  FSlideToUnlockText := 'SLIDE TO UNLOCK';
  FUnlockedText := 'UNLOCKED';
end;

procedure TSlideToUnlockCaptions.SetSlideToUnlockText(const Value: string);
begin
  FSlideToUnlockText := Value;
end;

end.

