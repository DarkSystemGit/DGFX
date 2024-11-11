

import std.stdio;
import rel;
void main() {
    GFX gfx=new GFX("test",[640,480]);
    // The application loop
    bool running = true;
    bool white;
    while (running) {
        
        if(white){
            gfx.pixels[]=128;
            white=false;
        }else{
            gfx.pixels[]=64;
            white=true;
        }
        gfx.loop();
    } 

}