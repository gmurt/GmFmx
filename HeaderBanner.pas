{******************************************************************************}
{                                                                              }
{  THeaderBanner                                                               }
{                                                                              }
{  Description: Header banner control                                          }
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

unit HeaderBanner;

interface

uses FMX.Objects, FMX.Controls, FMX.StdCtrls, Classes, FMX.Types,
  FMX.Graphics, Types, System.UITypes, System.UIConsts;

type

  [ComponentPlatformsAttribute(
    pidAllPlatforms
    )]
  THeaderBanner = class(TPaintBox)
  private
    FBitmap: TBitmap;
    FText: string;
    FButton: TButton;
    FButtonText: string;
    FButtonAction: string;
    FButtonUrl: string;
    FBackground: TAlphaColor;
    FOnButtonClick: TNotifyEvent;

    procedure SetButtonText(const Value: string);
    procedure SetBitmap(const Value: TBitmap);
    procedure SetText(const Value: string);
    procedure SetBackground(const Value: TAlphaColor);
    procedure DoButtonClick(Sender: TObject);
  protected
    procedure Paint;  override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function ContentRect: TRectF;
  published

    property Background: TAlphaColor read FBackground write SetBackground default claLightyellow;
    property ButtonText: string read FButtonText write SetButtonText;
    property ButtonAction: string read FButtonAction write FButtonAction;
    property ButtonUrl: string read FButtonUrl write FButtonUrl;
    property Bitmap: TBitmap read FBitmap write SetBitmap;
    property Text: string read FText write SetText;
    property OnButtonClick: TNotifyEvent read FOnButtonClick write FOnButtonClick;
  end;

  procedure Register;

implementation



procedure Register;
begin
  RegisterComponents('GmFmx', [THeaderBanner]);
end;

{ THeaderBanner }

function THeaderBanner.ContentRect: TRectF;
begin
  Result := ClipRect;
  Result.Inflate(-5, -5);
end;

constructor THeaderBanner.Create(AOwner: TComponent);
begin
  inherited;
  Align := TAlignLayout.Top;
  Height := 50;
  //Fill.Color := claWhite;

  SetAcceptsControls(False);
  FBitmap := TBitmap.Create;


  FButton := TButton.Create(Self);
  FButton.CanFocus := False;
  FButton.Stored := False;
  FButton.OnClick := DoButtonClick;
  FButton.Align := TAlignLayout.Right;
  FButton.StyleLookup := 'listitembutton';
  FButton.Width := 100;
  Padding.Rect := RectF(6,6,6,6);

  FText := '';


  FButtonText := '';

  FBackground := claLightyellow;

  AddObject(FButton);


end;

destructor THeaderBanner.Destroy;
begin
  FBitmap.Free;
  FButton.Free;
  inherited;
end;



procedure THeaderBanner.DoButtonClick(Sender: TObject);
begin



  if Assigned(FOnButtonClick) then
    FOnButtonClick(Self);
end;

procedure THeaderBanner.Paint;
var
  ARect: TRectF;
begin
  Canvas.BeginScene;
  try
    Canvas.Stroke.Thickness := 1.5;
    Canvas.Stroke.Kind := TBrushKind.Solid;
    Canvas.Stroke.Color := claSilver;
    Canvas.DrawRectSides(ClipRect, 0, 0, AllCorners, 1, [TSide.Top, TSide.Bottom]);


    Canvas.Fill.Color := FBackground;
    Canvas.FillRect(ClipRect, 0, 0, AllCorners, 1);


    ARect := ContentRect;
    ARect.Width := ARect.Height;
    ARect.Inflate(-8, -8);
    Canvas.DrawBitmap(FBitmap, RectF(0,0, FBitmap.Width, FBitmap.Height), ARect, 1);


    ARect := ContentRect;
    ARect.Left := ARect.Left + ARect.Height + 8;
    ARect.Right := ARect.Right + FButton.Width;
    Canvas.Fill.Color := claBlack;
    Canvas.Font.Size := 14;
    Canvas.FillText(ARect, FText, True, 1, [], TTextAlign.Leading);
  finally
    Canvas.EndScene;
  end;
end;

procedure THeaderBanner.SetBackground(const Value: TAlphaColor);
begin
  FBackground := Value;
  InvalidateRect(ClipRect);
end;

procedure THeaderBanner.SetBitmap(const Value: TBitmap);
begin
  FBitmap.Assign(Value);
  InvalidateRect(ClipRect);
end;

procedure THeaderBanner.SetButtonText(const Value: string);
begin
  FButtonText := Value;
  FButton.Text := Value;
  InvalidateRect(ClipRect);
end;


procedure THeaderBanner.SetText(const Value: string);
begin
  FText := Value;
  InvalidateRect(ClipRect);
end;

end.
