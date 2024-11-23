

import std.stdio;
import gfx;
import std.random;
import bindbc.sdl;
import std.math;
void main() {
    GFX screen=new GFX("test",[640,480]);
    // The application loop
    bool running = true;
    bool white;    //R,G,B,A
    float s=0;
    Sprite sp;
    sp.pixels[]=255;
    for (int i;running;i++) {
        long start=SDL_GetTicks();
        screen.pixels[]=2;
        sp.move(sp.x+.5,sp.y+.5);
        sp.rotate(45);
        sp.scale(1.05);
        sp.move(sp.x+.5,sp.y+.5);
        if((screen.events.length>0)&&(screen.events[screen.events.length-1]=="QuitEvent")){
            running=false;
        }
         sp.draw(screen);
        screen.loop();
       
        s+=(cast(float)1000/(cast(float)(SDL_GetTicks()-start)));
        writef("FPS: %f\n",s/cast(float)i);
        
    } 

}