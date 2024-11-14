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
    float angle=0;
     ubyte[] rpixels;
    void draw(GFX gfx){
        if(angle==0){foreach(i,ubyte pix;pixels){
            gfx.pixels[(((i/dims[0])+this.y)*320)+((i%dims[1])+this.x)]=pix;
        }}else{
            foreach(i,ubyte pix;rpixels){
            gfx.pixels[(((i/dims[0])+this.y)*320)+((i%dims[1])+this.x)]=pix;
        }
        }
    }
    void rotate(float angle){
        this.angle+=angle;
        if(this.angle>360)this.angle-=360*floor(this.angle/360);
        ubyte[] newPixels=new ubyte[24*24];
        float pi=3.1415926;
        float rad=this.angle*(pi/180);
        if(rad>2*pi)rad=0;
        float sinr=rad.sin;
        float cosr=rad.cos;
        writeln(this.angle);
        for(int x=0;x<16;x++){
            for(int y=0;y<16;y++){
                float ox=round(x*cosr+y*sinr);
                float oy=round(-1*x*sinr+y*cosr);
                /*float nx=16+(x*cosr)-(y*sinr);
                float ny=16+(sinr*x)+(cosr*y);*/
                //write(ox," ",oy," ",x," ",y);
                //if(cast(ulong)(ox+(oy*dims[1]))>255)newPixels.length=cast(ulong)(ox+(oy*dims[1]));
                if((ox>0)&&(oy>0)&&(cast(ulong)(ox+(oy*dims[1]))<pixels.length)){setitem(newPixels,x,y,pixels[cast(ulong)(ox+(oy*dims[1]))],dims);}else{setitem(newPixels,x,y,0,dims);}
            }
        }    
        this.rpixels=newPixels;
        this.dims=[16,16];
    }
}
void setitem(ref ubyte[] pixels,uint x,uint y,ubyte pix,ubyte[] dims){
    pixels[cast(ulong)(x+((y)*dims[1]))]=pix;
}
/*int[] getPixelRotated(ubyte[] pixels,uint x,uint y,float angle){

}*/