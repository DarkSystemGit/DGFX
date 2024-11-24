import gfxthread;
import std;
import core.atomic;
import core.thread;
import core.sync;
static import dsdl2;
import bindbc.sdl;
import defaultPalette;
float pi=3.1415926;
__gshared ubyte[] spixels=new ubyte[320*240];
shared bool srender;
__gshared string[] sevents;
__gshared uint[256] spalette;
__gshared bool running;

static void gfxThread(Tid owner){
    GFXThread gfxi;
    bool draw=true;
   
    receive((string name){    
        gfxi=new GFXThread(name,[640,480]);
        gfxi.palette=spalette;
        while(running){
             sevents=gfxi.events;
            if(srender){gfxi.renderPixels=spixels.dup;srender=false;}
            gfxi.loop();
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
        running=true;
    }
    void render(){
        srender=true;
        while(srender){}
        this.events=sevents;
    }
    void kill(){
        running=false;
    }
}
struct Sprite{
    uint[2] dims=[16,16];
    ubyte[] pixels=new ubyte[16*16];
    uint x;
    uint y;
    float angle=0;
    bool mod;
     ubyte[] mpixels;
     float[2] scaledDims=[16,16];
    void draw(ref ubyte[] rpixels){
        if(!mod){
        foreach(i,ubyte pix;pixels){
                int x=cast(int)(floor(cast(float)(i/dims[0]))+this.x);
                int y=cast(int)((i%dims[1])+this.y);
                if(
                    (pix!=0)&&(x<320)&&(y<240)&&(x>=0)&&(y>=0)
                ){
                    rpixels[cast(ulong)((y*320)+x)]=pix;
                }
            }
        }else{
            foreach(i,ubyte pix;mpixels){
                int x=cast(int)(floor(cast(float)(i/dims[0]))+this.x);
                int y=cast(int)((i%dims[1])+this.y);
                if(
                    (pix!=0)&&(x<320)&&(y<240)&&(x>=0)&&(y>=0)
                ){
                    
                    rpixels[cast(ulong)((y*320)+x)]=pix;
                     
                }

        }
        }
    }
    void rotatei(){
        uint[] dims=[32,32];
        if((dims[1]/2)*(dims[0]/2)<=64)this.dims=[dims[0]*2,dims[1]*2];
        this.mpixels=new ubyte[dims[0]*dims[1]];
        if(this.angle>360)this.angle-=360*floor(this.angle/360);
        float rad=this.angle*(pi/180);
        
        if(rad>2*pi)rad=0;
        for(int x=0;x<dims[0];x++){
            for(int y=0;y<dims[1];y++){
                float[] xy=matrix(x,y,dims,rad);
                float ox=xy[0];
                float oy=xy[1];
                if((ox>=0)&&(oy>=0)&&(ox<16)&&(oy<16)){
                    setitem(this.mpixels,x,y,pixels[cast(ulong)(ox+(oy*(16/2)))],dims);
                }else{
                    setitem(this.mpixels,x,y,0,dims);
                }
            }
        }   
          

    }
    void resizei(){
        float[2] relativeScale;
        relativeScale[0]=32/scaledDims[0];
        relativeScale[1]=32/scaledDims[1];
        //foreach final pixel, old=(round(x/scale[0]),round(y/scale[0])
        ubyte[] opixels=this.mpixels.dup;
        this.mpixels.length=0;
        this.mpixels=new ubyte[dims[0]*dims[1]];

        for(int y=0;y<dims[1];y++){
            for(int x=0;x<dims[0];x++){
                float ox=floor(x*relativeScale[0]);
                float oy=floor(y*relativeScale[1]);
            
                if((ox>=0)&&(oy>=0)&&(ox<32)&&(oy<32)){

                    this.mpixels[cast(ulong)(x+(y*dims[0]))]=opixels[cast(ulong)(ox+(oy*32))];
                }else{
                    
                    setitem(this.mpixels,x,y,0,dims);
                }
            }
        }

    }
    void addOp(SpriteOp op){
        
        switch(op.op){
            case SpriteOps.scale:
            this.scaledDims=[this.scaledDims[0]*op.args[0],this.scaledDims[1]*op.args[1]];
            break;
            case SpriteOps.rotate:
            this.angle+=op.args[0];
            break;
            case SpriteOps.move:
            this.x=cast(uint)round(op.args[0]);
            this.y=cast(uint)round(op.args[1]);
            break;
            case SpriteOps.resize:
            this.scaledDims=[op.args[0],op.args[1]];
            break;
            default:
            break;
        }
        this.mpixels=new ubyte[32*32];
        foreach(i,ubyte pix;mpixels){
            int x=cast(int)(floor(cast(float)(i/32)));
            int y=cast(int)((i%32));
            if(x<16&&y<16){
                setitem(this.mpixels,x,y,pixels[cast(ulong)(x+((y)*16))],[32,32]);
            }
        }
        this.mod=true;
        if(this.angle!=0){this.rotatei();}

        this.dims=[cast(uint)round(scaledDims[0]),cast(uint)round(scaledDims[1])];
        this.resizei();
        //this.dims=[this.dims[0]/2,this.dims[1]/2];
        
    }
    void resize(float width,float height){
        SpriteOp s;
        s.op=SpriteOps.resize;
        s.args=[width,height];
        this.addOp(s);
    }
    void scale(float multiplier){
        SpriteOp s;
        s.op=SpriteOps.scale;
        s.args=[multiplier,multiplier];
        this.addOp(s);
    }
    void move(float x,float y){
        SpriteOp m;
        m.op=SpriteOps.move;
        m.args=[x,y];
        this.addOp(m);
    }
    void rotate(float angle){
        SpriteOp r;
        r.op=SpriteOps.rotate;
        r.args=[angle];
        this.addOp(r);
    }
}
void setitem(ref ubyte[] pixels,uint x,uint y,ubyte pix,uint[] dims){
    if(cast(ulong)(x+((y)*dims[0]))>=pixels.length)return;
    pixels[cast(ulong)(x+((y)*dims[0]))]=pix;
}
float[] matrix(int x,int y,uint[] dims,float angle){
    float c=cos(angle);
    float s=sin(angle);
    int ox=cast(int)(dims[0]/4);
    int oy=cast(int)(dims[1]/4);
    x-=ox;
    y-=oy;
    return [
        round(x*c+y*s)+ox,
        round(y*c-x*s)+oy
    ];
}
enum SpriteOps{
    scale,
    rotate,
    resize,
    move
}
struct SpriteOp{
    SpriteOps op;
    float[] args;
}
class TileMap{
    ubyte[] tiles;
    uint[] dims;
    ubyte[64][512] tileset;
    int x;
    int y;
    bool mod;
    ubyte[320*240] pixels;
    this(ubyte[] tiles,uint[] dims,int x,int y){
        this.tiles=tiles;
        this.dims=dims;
        this.x=x;
        this.y=y;
        this.mod=true;
    }
    void draw(){
        if(!this.mod)return;
        foreach(p,ubyte tileid;tiles){
            int x=cast(int)(floor(cast(float)(p/dims[0]))+x)*8+this.x;
            int y=cast(int)((p%dims[1])+y)*8+this.y;
            ubyte[64] tile=tileset[tileid];
            for(int i=0;i<8;i++){
                for(int j=0;j<8;j++){
                    pixels[cast(ulong)((y+i)*320+(x+j))]=tile[cast(ulong)(i*8+j)];
                }
            }

        } 
        this.mod=false;   
    }
    void setTile(uint x,uint y,ubyte tileid){
        this.tiles[cast(ulong)(x+(y*dims[0]))]=tileid;
        this.mod=true;
    }
    void setTileset(ubyte[64] tile,uint tileid){
        this.tileset[tileid]=tile;
        this.mod=true;
    }
    void move(int x,int y){
        this.x=x;
        this.y=y;
        this.mod=true;
    }
    void resize(uint width,uint height){
        this.dims=[width,height];
        this.mod=true;
    }
    void render(ref ubyte[] rpixels){
        this.draw();
        foreach(i,ubyte pix;pixels){
            if(pix!=0)rpixels[i]=pix;
        }
    }    
}