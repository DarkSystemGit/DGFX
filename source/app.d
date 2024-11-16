

import std.stdio;
import rel;
import std.random;
import bindbc.sdl;
import std.math;
void main() {
    GFX gfx=new GFX("test",[640,480]);
    // The application loop
    bool running = true;
    bool white;    //R,G,B,A
    gfx.palette[1]=0;
        gfx.palette[2]=0xFFFFFFFF;
    gfx.palette[3]=0xFF0000FF;
    gfx.palette[4]=0x00FF00FF;
    gfx.palette[5]=0x0000FFFF;
    gfx.palette[6]=0x00FFFFFF;
    float s=0;
    Sprite sp;
    for(int i;i<sp.pixels.length;i++){
        sp.pixels[i]=((i%16)%3)+3;
        if(floor(cast(float)(i)/16)==1)sp.pixels[i]=6;
    }
    sp.x=100;
    sp.y=100;
                     


    for (int i;running;i++) {
        long start=SDL_GetTicks();
        gfx.pixels[]=2;

        if((gfx.events.length>0)&&(gfx.events[gfx.events.length-1]=="QuitEvent")){
            running=false;
        }
        sp.rotate(.5); 
         sp.draw(gfx);
        gfx.loop();
        s+=(cast(float)1000/(cast(float)(SDL_GetTicks()-start)));
        //writef("FPS: %f\n",s/cast(float)i);
        
    } 

}