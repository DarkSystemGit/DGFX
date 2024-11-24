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
__gshared string[] sevents=new string[0];
__gshared uint[256] spalette;


static void gfxThread(Tid owner){
    GFXThread gfxi;
    bool draw=true;
    receive((string name){    
        gfxi=new GFXThread(name,[640,480]);
        while(true){
            if(srender){gfxi.renderPixels=spixels.dup;srender=false;}
            gfxi.palette=spalette;
            gfxi.loop();
            sevents=gfxi.events;
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
    }
    void render(){
        srender=true;
        while(srender){}
    }
}
