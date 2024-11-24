

import std.stdio;
import gfx;
import std.random;
import bindbc.sdl;
import std.math;
import threading;
void main() {
    GFX screen=new GFX("test");
    
    TileMap tmap=new TileMap(new ubyte[16*16],[16,16],0,0);
    ubyte[64] tile;
    tile[]=245;
    
    tmap.setTileset(tile,0);
    tile[]=200;
    
    tmap.setTileset(tile,1);
    tmap.setTile(0,0,1);
    tmap.setTile(0,1,1);
    tmap.setTile(1,0,1);
    tmap.setTile(1,1,1);
    
    // The application loop
    bool running = true;
    bool white;    //R,G,B,A
    float s=0;
    Sprite sp;
    sp.pixels[]=0;
    for (int i;running;i++) {
        //long start=SDL_GetTicks();
        auto colchange = uniform(0, 255);
        screen.pixels[]=2;
        sp.rotate(5);
        sp.scale(1.005);
        sp.move(sp.x+0.05,sp.y+0.05);
        if((screen.events.length>0)&&(screen.events[screen.events.length-1]=="QuitEvent")){
            running=false;
        }
        if(i%256)sp.pixels[]=cast(ubyte)((sp.pixels[0]+1)-(floor(cast(float)(sp.pixels[0]+1)/255)*255));
        tmap.render(screen.pixels);
        sp.draw(screen.pixels);
        screen.pixels[]=screen.pixels[]+cast(ubyte)colchange;
        screen.render();
        //s+=(cast(float)1000/(cast(float)(SDL_GetTicks()-start)));
        //writef("FPS: %f\n",s/cast(float)i);
        
    } 
    screen.kill();
    return;
}