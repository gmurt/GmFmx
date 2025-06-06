unit MapViewExt;

interface

uses
  System.SysUtils, System.Classes, FMX.Types, FMX.Controls, FMX.Maps;

type


  TMapViewExt = class(TMapView)
  private
    { Private declarations }
  protected
    { Protected declarations }
  public
    { Public declarations }
  published
    { Published declarations }
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('GmFmx', [TMapViewExt]);
end;

end.
