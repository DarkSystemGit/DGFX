import std;
static import dsdl2;
import bindbc.sdl;

class GFX{
    dsdl2.Window window;
    dsdl2.Surface renderSurface;
    ubyte[] pixels;
    bool running;
    uint[2] dims;
    string[] events; 
    string[] errors;
    uint[255] palette;
    uint[] renderBuffer;
    this(string name,uint[2] dimensions){
        dsdl2.loadSO();
        dsdl2.init(video : true);
        this.dims=dimensions;
        this.window=new dsdl2.Window(name,[0,0],dims, false,false,false,false,true,false,false,true);
        this.pixels=new ubyte[320*240];
        this.renderSurface=new dsdl2.Surface([320,240],dsdl2.PixelFormat.rgba8888);
        this.palette[0]=0x000000FF;
    }
    void loop(){
        dsdl2.pumpEvents();
        while (auto event = dsdl2.pollEvent()) {
            events~=event.toString().replace("dsdl2.","").replace("()","");
        }
         string err=SDL_GetError().to!string;
        if(err!=""){
            errors~=err;
        }
        foreach(i,ubyte pix;pixels){
            if(pix!=1){
             (cast(uint*)this.renderSurface.buffer)[i]=palette[pix];
             pixels[i]=0;
            }
        }
        window.surface.blitScaled(renderSurface,dsdl2.Rect(0,0,window.width,window.height));
        window.update();
    }
    ~this(){
         dsdl2.quit();
    }
}
struct Sprite{
    ubyte[2] dims=[16,16];
    ubyte[] pixels=new ubyte[16*16];
    uint x;
    uint y;
    float angle=0;
     ubyte[] rpixels;
    void draw(GFX gfx){
        if(angle==0){foreach(i,ubyte pix;pixels){
            if(pix!=0)gfx.pixels[cast(ulong)(((floor(cast(float)(i/dims[0]))+this.x)*320)+((i%dims[1])+this.y))]=pix;
        }}else{
            foreach(i,ubyte pix;rpixels){
            if(pix!=0)gfx.pixels[cast(ulong)(((floor(cast(float)(i/dims[0]))+this.x)*320)+((i%dims[1])+this.y))]=pix;
        }
        }
    }
    void rotate(float angle){
        this.dims=[32,32];
        this.rpixels=new ubyte[32*32];
        this.angle+=angle;
        if(this.angle>360)this.angle-=360*floor(this.angle/360);
        float pi=3.1415926;
        float rad=this.angle*(pi/180);
        if(rad>2*pi)rad=0;
        for(int x=0;x<32;x++){
            for(int y=0;y<32;y++){
                float[] xy=matrix(x,y,dims,rad);
                float ox=xy[0];
                float oy=xy[1];
                /*float nx=16+(x*cosr)-(y*sinr);
                float ny=16+(sinr*x)+(cosr*y);*/
                //if(cast(ulong)(ox+(oy*dims[1]))>255)newPixels.length=cast(ulong)(ox+(oy*dims[1]));
                if((ox>0)&&(oy>0)&&(cast(ulong)(ox+(oy*16))<pixels.length)){
                    writeln(ox," ",oy," ",pixels[cast(ulong)(ox+(oy*16))]," ",dims);
                    setitem(rpixels,x,y,pixels[cast(ulong)(ox+(oy*16))],[32,32]);
                }else{
                    setitem(rpixels,x,y,0,[32,32]);
                    writeln(ox," ",oy," ",0," ",dims);
                }
            }
        }    
        
    }
}
void setitem(ref ubyte[] pixels,uint x,uint y,ubyte pix,ubyte[] dims){
    if(cast(ulong)(x+((y)*dims[1]))>=pixels.length)return;
    pixels[cast(ulong)(x+((y)*dims[1]))]=pix;
}
float[] matrix(int x,int y,ubyte[] dims,float angle){
    float c=cos(angle);
    float s=sin(angle);
    int ox=8;
    int oy=8;
    x-=ox;
    y-=oy;
    return [
        round(x*c+y*s)+ox,
        round(y*c-x*s)+oy
    ];
}
/*int[] getPixelRotated(ubyte[] pixels,uint x,uint y,float angle){

}*/