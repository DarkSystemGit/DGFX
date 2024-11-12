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
        this.palette[0]=0x000000;
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
            if(pix!=0){
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
    void draw(GFX gfx){
        foreach(i,ubyte pix;pixels){
            gfx.pixels[(((i/dims[0])+this.y)*320)+((i%dims[1])+this.x)]=pix;
        }
    }
    void rotate(float angle){
        ubyte[] newPixels=new ubyte[32*32];
        float pi=3.1415926;
        float rad=angle*(pi/180);
        if(rad>2*pi)rad=0;
        float sinr=rad.sin;
        float cosr=rad.cos;
        foreach(int i,ubyte pix;this.pixels){
            int x=i%dims[0];
            int y=i/dims[0];
            float nx=16+(x*cosr)+(y*sinr);
            float ny=16+(sinr*x)-(cosr*y);
            writeln(x," ",y," ",cast(int)nx," ",cast(int)ny);
            newPixels[cast(ulong)(nx+(ny*32))]=pix;
        }    
        this.pixels=newPixels;
        this.dims=[32,32];
    }
}