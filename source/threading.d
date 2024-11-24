import gfx;
import std;
import core.atomic;
import core.thread;
import core.sync;
static import dsdl2;
import bindbc.sdl;
import defaultPalette;

__gshared ubyte[] spixels=new ubyte[320*240];
shared bool srender;
__gshared string[] sevents;
__gshared uint[256] spalette;
__gshared bool running;

static void gfxThread(Tid owner){
    GFXThread gfxi;
    bool draw=true;
   
    receive((string name){    
        gfxi=new GFXThread(name,[640,480]);
        gfxi.palette=spalette;
        while(running){
             sevents=gfxi.events;
            if(srender){gfxi.renderPixels=spixels.dup;srender=false;}
            gfxi.loop();
        }
    }
    );
}
class GFX{
    Tid thread;
    ubyte[] pixels;
    string[] events;
    uint[256] palette;
    this(string name){
        spalette=defaultPalette.palette;
        this.pixels=spixels;     
        this.thread = spawn(&gfxThread, thisTid);
        send(this.thread, name);
        this.events=sevents;
        this.palette=spalette;
        running=true;
    }
    void render(){
        srender=true;
        while(srender){}
        this.events=sevents;
    }
    void kill(){
        running=false;
    }
}
