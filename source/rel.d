import std;
static import dsdl2;
import bindbc.sdl;
class GFX{
    dsdl2.Window window;
    dsdl2.Surface renderSurface;
    ubyte[] pixels;
    bool running;
    uint[2] dims;
    SDL_EventType[] events; 
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
    }
    void loop(){
        dsdl2.pumpEvents();
        while (auto event = dsdl2.pollEvent()) {
            events~=event.sdlEventType();
        }
         string err=SDL_GetError().to!string;
        if(err!=""){
            errors~=err;
        }
        foreach(i,ubyte pix;pixels){
             (cast(uint*)this.renderSurface.buffer)[i]=palette[pix];
        }
        window.surface.blitScaled(renderSurface,dsdl2.Rect(0,0,window.width,window.height));
        window.update();
    }
    ~this(){
         dsdl2.quit();
    }
}