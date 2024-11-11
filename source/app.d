

import std.stdio;
import std.conv : to;
import std.math;
static import dsdl2;
import bindbc.sdl;
void main() {
    // SDL initialization
    dsdl2.loadSO();
    dsdl2.init(video : true);
    uint[2] dims=[1280, 720];


    auto window = new dsdl2.Window("My Window", [0, 0], dims);
    auto windowSurface = window.surface;
    // dfmt on
    ubyte[] pixels=new ubyte[dims[0] * dims[1] * 4];
    pixels[]=20;
    long timer=0;
    long timeStart=dsdl2.getTicks();
    // The application loop
    bool running = true;
    bool white;
    long frames=0;
    float avged=0;
    while (running) {
        // Gets incoming events
        timer=dsdl2.getTicks()-timeStart;
        float avgFPS = cast(float)frames / ( cast(float)timer / 1000 );
                if( avgFPS > 2000000 )
                {
                    avgFPS = 0;
                }
        frames++;
        if(isNaN(avged)){avged=0;}
        avged+=avgFPS;
        writeln("Avg: ",avged/frames);
        writeln("FPS: ",avgFPS);
        dsdl2.pumpEvents();
        while (auto event = dsdl2.pollEvent()) {
            // On quit
            if (cast(dsdl2.QuitEvent) event) {
                running = false;
            }
        }
        string err=SDL_GetError().to!string;
        if(err!=""){
            writeln(err);
            running=false;
        }
        windowSurface.buffer[]=pixels;
        if(white){
            pixels[]=128;
            white=false;
        }else{
            pixels[]=64;
            white=true;
        }
        window.update();
    } 

    // Quits SDL
    dsdl2.quit();
}