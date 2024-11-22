

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
    sp.pixels[]=3;
    //sp.x=100;
    //sp.y=100;
                     
    //sp.rotate(45);
    SpriteOp r;
    r.op=SpriteOps.rotate;
    r.args=[1];
    SpriteOp sc;
    sc.op=SpriteOps.scale;
    sc.args=[1,1];
    SpriteOp m;
    m.op=SpriteOps.move;
    m.args=[100,100];

    //sp.addOp(sc);
    //sp.addOp(r);
            //writeln(sp.mpixels);
    for (int i;running;i++) {
        long start=SDL_GetTicks();
        gfx.pixels[]=2;
        m.args=cast(float[])[sp.x+.5,sp.y+.5];
        sc.args[]*=1.001;
        sp.addOp(r);
        sp.addOp(sc);
        sp.addOp(m);
        if((gfx.events.length>0)&&(gfx.events[gfx.events.length-1]=="QuitEvent")){
            running=false;
        }
        
        //sp.resize([sp.dims[0]+1,sp.dims[1]+1]); 
         sp.draw(gfx);
        gfx.loop();
       
        s+=(cast(float)1000/(cast(float)(SDL_GetTicks()-start)));
        //writef("FPS: %f\n",s/cast(float)i);
        
    } 

}