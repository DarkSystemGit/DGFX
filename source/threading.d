import gfx;
import std;
static import dsdl2;
import bindbc.sdl;
__gshared ubyte[] spixels=new ubyte[320*240];
__gshared string[] sevents=new string[0];

static void gfxThread(Tid owner){
    GFXThread gfx;
     receive((string name){
        if(name=="__ReNdEr__"){ gfx.pixels[]=spixels[];gfx.render();}else{
    GFXThread gfx=new GFXThread(name,[640,480]);
    while(true){
        gfx.loop();
        
        sevents=gfx.events;
       
    };}
    });
}
class GFX{
    Tid thread;
    ubyte[] pixels;
    string[] events;
    this(string name){
        this.pixels=spixels;     
        this.thread = spawn(&gfxThread, thisTid);
        
        send(this.thread, name);
        this.events=sevents;
        
    }
    void render(){
        send(this.thread, "__ReNdEr__");
        this.pixels[]=0;
    }
}
