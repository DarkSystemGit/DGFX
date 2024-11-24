import std;
static import dsdl2;
import bindbc.sdl;
import defaultPalette;
class GFXThread{
    dsdl2.Window window;
    dsdl2.Surface renderSurface;
    ubyte[] pixels;
    ubyte[] renderPixels;
    bool running;
    uint[2] dims;
    string[] events; 
    string[] errors;
    uint[256] palette;
    uint[] renderBuffer;
    this(string name,uint[2] dimensions){
        dsdl2.loadSO();
        dsdl2.init(video : true);
        this.dims=dimensions;
        this.window=new dsdl2.Window(name,[0,0],dims, false,false,false,false,true,false,false,true);
        this.renderPixels=new ubyte[320*240];
        this.renderSurface=new dsdl2.Surface([320,240],dsdl2.PixelFormat.rgba8888);
        this.palette=defaultPalette.palette;
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
        foreach(i,ubyte pix;renderPixels){
            if(pix!=0){
             (cast(uint*)this.renderSurface.buffer)[i]=palette[pix];
             //renderPixels[i]=0;
            }
        }
        window.surface.blitScaled(renderSurface,dsdl2.Rect(0,0,window.width,window.height));
        window.update();
    }
   
    ~this(){
         dsdl2.quit();
    }
}
