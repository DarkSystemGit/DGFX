

import std.stdio;
import rel;
import std.random;
import bindbc.sdl;
void main() {
    GFX gfx=new GFX("test",[640,480]);
    // The application loop
    bool running = true;
    bool white;    //R,G,B,A
    gfx.palette[1]=0x00FF00FF;
    gfx.palette[2]=0xFF0000FF;
    gfx.palette[3]=0xFFFFFFFF;
    float s=0;
    Sprite sp;
    sp.pixels[]=2;
    sp.x=100;
    sp.y=100;
    //sp.rotate(45);
    for (int i;running;i++) {
        long start=SDL_GetTicks();
        gfx.pixels[]=3;
       
        if((gfx.events.length>0)&&(gfx.events[gfx.events.length-1]=="QuitEvent")){
            running=false;
        }
        
         sp.draw(gfx);
        gfx.loop();
        s+=(cast(float)1000/(cast(float)(SDL_GetTicks()-start)));
        //writef("FPS: %f\n",s/cast(float)i);
        
    } 

}