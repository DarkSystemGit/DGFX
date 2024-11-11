

import std.stdio;
import rel;
import std.random;
import bindbc.sdl;
void main() {
    GFX gfx=new GFX("test",[640,480]);
    // The application loop
    bool running = true;
    bool white;    //R,G,B,A
    gfx.palette[0]=0x0000FFFF;
    gfx.palette[1]=0x00FF00FF;
    gfx.palette[2]=0xFF0000FF;
    gfx.palette[3]=0xFFFFFFFF;
   float s=0;
    for (int i;running;i++) {
           long start=SDL_GetTicks();
        if((i%2)==0){
            for(int x=0;x<320;x++){
                for(int j=0;j<240;j++){
                    gfx.pixels[((j*320)+x)]=cast(ubyte)uniform(0, 3);
                }
            }
        }
        if((gfx.events.length>0)&&(gfx.events[gfx.events.length-1]==SDL_QUIT)){
            running=false;
        }
        gfx.loop();
        s+=(cast(float)1000/(cast(float)(SDL_GetTicks()-start)));
        writef("FPS: %f\n",s/cast(float)i);
        
    } 

}