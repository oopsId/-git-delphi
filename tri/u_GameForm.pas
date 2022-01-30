unit u_GameForm;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects,
  FMX.Layouts,  FMX.ListView.Types, FMX.ListView.Appearances,
  FMX.ListView.Adapters.Base, FMX.ListView, FMX.StdCtrls, System.ImageList,
  FMX.ImgList, FMX.MultiResBitmap, FMX.Controls.Presentation,
  FMX.Menus, FMX.Platform, System.IOUtils, FMX.Media;


type
    TIntArray = array of array of integer;

    TImageArray = array of array of TImage;

   TImageListHelper = class helper for TImageList
    function Add(aBitmap: TBitmap): integer;
   end;

   TSImage = class(TImage)
   public
     StringName: string;
   end;

  TGameForm = class(TForm)
    Timer1: TTimer;
    im1: TImageList;
    MediaPlayer1: TMediaPlayer;
    procedure Timer1Timer(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Layout1Click(Sender: TObject);

  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  GameForm: TGameForm;
  strok, stolb: Integer;
  clientScreenSize: TSize;
  map: TIntArray;
  D: TPoint;
  a: set of Char = ['0'..'9'];
  level, score:integer;
implementation

{$R *.fmx}

{$R 'Project2.res' 'Project2resource.rc'}

procedure GetMyDisplay ();
var
   clientScreenScale   : Single;
   clientScreenService : IFMXScreenService;
begin
 if TPlatformServices.Current.SupportsPlatformService(IFMXScreenService, IInterface(clientScreenService)) then
    clientScreenScale := clientScreenService.GetScreenScale
  else
    clientScreenScale := 1;

  // The display device's width:
  clientScreenSize.CX := Round(clientScreenService.GetScreenSize.X * clientScreenScale);
  // The display device's height:
  clientScreenSize.CY := Round(clientScreenService.GetScreenSize.Y * clientScreenScale);

end;

function TImageListHelper.Add(aBitmap: TBitmap): integer;
const
  SCALE = 1;
var
  vSource: TCustomSourceItem;
  vBitmapItem: TCustomBitmapItem;
  vDest: TCustomDestinationItem;
  vLayer: TLayer;
begin
  Result := -1;
  if (aBitmap.Width = 0) or (aBitmap.Height = 0) then exit;

  // add source bitmap
  vSource := Source.Add;
  vSource.MultiResBitmap.TransparentColor := TColorRec.Fuchsia;
  vSource.MultiResBitmap.SizeKind := TSizeKind.Source;
  vSource.MultiResBitmap.Width := Round(aBitmap.Width / SCALE);
  vSource.MultiResBitmap.Height := Round(aBitmap.Height / SCALE);
  vBitmapItem := vSource.MultiResBitmap.ItemByScale(SCALE, True, True);
  if vBitmapItem = nil then
  begin
    vBitmapItem := vSource.MultiResBitmap.Add;
    vBitmapItem.Scale := Scale;
  end;
  vBitmapItem.Bitmap.Assign(aBitmap);

  vDest := Destination.Add;
  vLayer := vDest.Layers.Add;
  vLayer.SourceRect.Rect := TRectF.Create(TPoint.Zero, vSource.MultiResBitmap.Width,
      vSource.MultiResBitmap.Height);
  vLayer.Name := vSource.Name;
  Result := vDest.Index;
end;

procedure TGameForm.FormCreate(Sender: TObject);
var
   i,m,j,p, cx,cy: Integer;
  R: TResourceStream;
  Image:TSImage;
  s:string;
  bufimage:Timage;
begin

GetMyDisplay();
cx:=clientScreenSize.cx; cy:=clientScreenSize.cy;


strok:=round (gameform.Height / 64);
stolb:=round (gameform.Width / 64);
//showmessage (inttostr(strok)+inttostr(stolb));

//showmessage('cx= '+inttostr(strok)+'cy= '+inttostr(stolb));
bufimage:=TImage.Create(self);
bufimage.parent:=gameform;
bufimage.Position.X:=0;
bufimage.Position.Y:=0;
bufimage.Width:=64;
bufimage.Height:=64;
 //SetLength(Map,strok+1,stolb+1);
 SetLength(Map,strok,stolb);

    for i := 0 to 9 do
              begin
               R:=TResourceStream.Create (hInstance, 'PngImage_' + inttostr(i) , RT_RCDATA);
               try
                bufImage.Bitmap.LoadFromStream(R);
                im1.Add(bufImage.Bitmap);
               finally
                R.Free;
                end;
              end;
 bufimage.DisposeOf;
 bufimage:=nil;


gameform.Fill.Bitmap.Bitmap:=im1.Source[0].MultiResBitmap.Items[0].Bitmap;
gameform.Fill.Kind:=Tbrushkind(3);

randomize;


       for m := 0 to stolb-1 do   begin
         for j := 0 to strok-1 do  begin
  Image := TSImage.Create(self);
  with Image do
  begin
  Name:='Image'+inttostr(m)+'V'+inttostr(j);
  StringName:='Image'+inttostr(m)+'V'+inttostr(j);
  Parent:=gameform;
  Position.X:=m*64;
  Position.Y:=j*64;
  Width:= 64;
  Height:= 64;
  Visible:= true;
  Enabled:=true;
  OnClick:=self.Layout1Click;       //!timage.onclick self!
  p:=Random(9);
  p:=p+1; if p=10 then p:=9;
  map[m,j]:=p;
  Bitmap:=im1.Source[p].MultiResBitmap.Items[0].Bitmap;
  s:=s+inttostr(map[m,j])+' ';
  end;
  //showmessage('map m='+inttostr(m)+' '+'map j='+inttostr(j)+' '+'map mj='+ inttostr(map[m,j]));


                                 end;

                            end;

 D.X:=-1;
 D.Y:=-1;
 timer1.Enabled:=true;
 //showmessage(s);
end;

procedure TGameForm.Layout1Click(Sender: TObject);
var
tBuf, ku: integer;
temp: boolean;
xx,yy, f, i, j, u:integer;
pl:string;
s, ss, xs, ys: unicodestring;
begin
//ShowMessage('Вы нажали '+TImage(Sender).Name);
temp:=false;
u:=0; tBuf:=0; xx:=0; yy:=0; f:=0; ss:=''; s:=''; xs:=''; ys:='';
// -1, first click
if d.X=-1 then
           begin
             s:=trim(TSImage(Sender).StringName);
             f:=Length(s);
             for u := 1 to f do
             if ((s[u] in a) or (s[u]='V')) then  ss:=ss+s[u];
             f:=Length(ss);
             u:=(Pos('V', ss))-1;
             for i:= 0 to u-1 do xs:=xs+ss[i];
             for j:= u+1 to f do ys:=ys+ss[j];
             //showmessage(xs+'=='+ys);
             d.X:=strtoint(trim(xs)); d.Y:=strtoint(trim(ys));
             temp:=true;
             MediaPlayer1.FileName:=System.IOUtils.TPath.GetDocumentsPath+PathDelim+'pick.wav';
             MediaPlayer1.Play;
           end;
 //>-1, second click
 if  ((d.X>-1)  and (temp=false)) then
           begin
           ss:=''; s:=''; xs:=''; ys:=''; f:=0;
           s:=trim(TSImage(Sender).StringName);
           f:=Length(s);
           for u := 1 to f do if ((s[u] in a) or (s[u]='V')) then ss:=ss+s[u];
           f:=Length(ss);
           u:=(Pos('V', ss))-1;
           for i:= 0 to u-1 do xs:=xs+ss[i];
           for j:= u+1 to f do ys:=ys+ss[j];
           xx:=strtoint(xs); yy:=strtoint(ys);
           //showmessage(xs+'<>'+ys);
           //  <> menyaem crystaly mestami
           // dalnost v i kletku
           if (((abs(d.X-xx))<=1) and ((abs(d.Y-yy))<=1))  then
                           //  zapret diagonali
                          if (((xx=d.X) and (yy=d.Y-1)) or ((xx=d.X) and (yy=d.Y+1))
                          or ((xx=d.X-1) and (yy=d.Y)) or ((xx=d.X+1) and (yy=d.Y)))
                             then
                                begin
                                  tBuf:=map[d.X,d.Y];
                                  map[d.X,d.Y]:=map[xx,yy];
                                  map[xx, yy]:=tBuf;
                                  d.X:=-1;
                                  d.Y:=-1;
                                  temp:=true;
                                  MediaPlayer1.FileName:=System.IOUtils.TPath.GetDocumentsPath+PathDelim+'pick.wav';
                                  MediaPlayer1.Play;
                                end;
           end;
end;

procedure TGameForm.Timer1Timer(Sender: TObject);
var
i, j,r, n, p, m, z, f,u, sx, sy, ku, jk :integer;
temp:boolean;
s, ss, ys, xs :string;
imname, hh:string;
begin
         // перерисовал изменения в мапе в таймере  и внесение их в имейджлист   s:=trim( VarToStr(TImage(gameform.Components[z]).Name));
              for z:=0 to gameform.ComponentCount - 1 do
         begin
         if (gameform.Components[z] is TSImage) and (TSImage(gameform.Components[z]).StringName<>'')  then
              begin
              u:=0; f:=0; ss:=''; s:=''; xs:=''; ys:='';
              s:=TSImage(gameform.Components[z]).StringName;
              f:=Length(s);
              if (s[f] in a) or (s<>'bufImage') then
                 begin ;     // bufimage
                 for u := 0 to f do if ((s[u] in a) or (s[u]='V')) then ss:=ss+s[u];
                 f:=Length(ss);  // showmessage(ss);
                 u:=(Pos('V', ss))-1;
                 for i:= 0 to u-1 do xs:=xs+ss[i];
                 for j:= u+1 to f do ys:=ys+ss[j];  //showmessage(xs+' '+ys);
                 sx:=strtoint(xs); sy:=strtoint(ys);
                 TSImage(gameform.Components[z]).Bitmap:=im1.Source[map[sx, sy]].MultiResBitmap.Items[0].Bitmap;
                 end;
              end;

          end;

 //  proverka gorizontali
 for j  := 0 to strok-1 do
   begin
    temp:=false;
    for i := 0 to stolb-1 do
    if (map[i,j]=map[i+1,j]) and (map[i+1,j]=map[i+2,j]) and (map[i,j]>0)
     then
        begin
          for n := i+1 to stolb-1 do
          begin
          if map[i,j]<>map[n,j] then temp:=true;
          if (map[i,j]=map[n,j]) and (temp=false) and (map[i,j]>0) then
           begin
           map[n,j]:=0;
           score:=score+1;
           end;
          end;
          map[i,j]:=0;
          score:=score+1;
        end;
   end;
       // proverka vertiklali
       for i  := 0 to stolb-1 do
   begin
    temp:=false;
    for j := 0 to strok-1 do
    if (map[i,j]=map[i,j+1]) and (map[i,j+1]=map[i,j+2])  and (map[i,j]>0)
     then
        begin
          for n := j+1 to strok-1 do
          begin
          if map[i,j]<>map[i,n] then temp:=true;
          if (map[i,j]=map[i,n]) and (temp=false) and (map[i,j]>0) then
           begin
           map[i,n]:=0;
           score:=score+1;
           end;
          end;
          map[i,j]:=0;
          score:=score+1;
        end;
   end;

     //padenie kristalov
      for i := 0 to stolb-1  do
       for j := 0 to strok-1  do
        begin    // 0 - eto 1 stolbez vezde
        if (map[i,j]=0) and (j=0) then begin r:=random(9); if r=0 then map[i,j]:=1 else map[i,j]:=r; end;

          if (map[i,j]=0) and (j>0) then
              begin
                map[i,j]:=map[i,j-1];
                map[i,j-1]:=0;
                //MediaPlayer1.FileName:=System.IOUtils.TPath.GetDocumentsPath+PathDelim+'line.wav';
                //MediaPlayer1.Play;
              end;

        end;

  end;



end.
