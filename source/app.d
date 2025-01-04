

import std.stdio;
import dgfx;
import std.random;
import bindbc.sdl;
import std.math;
void main() {
    GFX screen=new GFX("test",[0,0]);
    
    TileMap tmap=new TileMap(new ubyte[20*10],[20,10],0,0);
    ubyte[64] tile;
    tile[]=245;
    tile[0..32]=255;
    foreach(int i,ubyte pix;tile){
        if((i%8)<4)tile[i]=6;
    }
    tmap.setTileset(tile,0);
    tile[]=200;
    tile[0..32]=50;
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
    screen.palette[1]=0x000000FF;
    for (int i;running;i++) {
        //long start=SDL_GetTicks();
        auto colchange = uniform(0, 255);
        screen.pixels[]=1;
        //screen.pixels[]=2;
        //sp.rotate(5);
        //sp.scale(1.005);
        //sp.move(sp.x+0.05,sp.y+0.05);
        if((screen.events.length>0)&&(screen.events[screen.events.length-1]=="QuitEvent")){
            running=false;
        }
        if(i%256)sp.pixels[]=cast(ubyte)((sp.pixels[0]+1)-(floor(cast(float)(sp.pixels[0]+1)/255)*255));
        tmap.x++;
        tmap.y++;
        tmap.mod=true;
        tmap.render(screen.pixels);
        sp.draw(screen.pixels);
        //screen.pixels[]=screen.pixels[]+cast(ubyte)colchange;
        screen.render();
        //writeln(screen.getPressedKeys());
        //s+=(cast(float)1000/(cast(float)(SDL_GetTicks()-start)));
        //writef("FPS: %f\n",s/cast(float)i);
        
    } 
    screen.kill();
    return;
}