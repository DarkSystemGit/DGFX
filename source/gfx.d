import std;
static import dsdl2;
import bindbc.sdl;
import defaultPalette;
float pi=3.1415926;
class GFX{
    dsdl2.Window window;
    dsdl2.Surface renderSurface;
    ubyte[] pixels;
    bool running;
    uint[2] dims;
    string[] events; 
    string[] errors;
    uint[256] palette;
    uint[] renderBuffer;
    this(string name,uint[2] dimensions){
        dsdl2.loadSO();
        dsdl2.init(video : true);
        this.dims=dimensions;
        this.window=new dsdl2.Window(name,[0,0],dims, false,false,false,false,true,false,false,true);
        this.pixels=new ubyte[320*240];
        this.renderSurface=new dsdl2.Surface([320,240],dsdl2.PixelFormat.rgba8888);
        this.palette=defaultPalette.dpalette;
    }
    void loop(){
        dsdl2.pumpEvents();
        while (auto event = dsdl2.pollEvent()) {
            events~=event.toString().replace("dsdl2.","").replace("()","");
        }
         string err=SDL_GetError().to!string;
        if(err!=""){
            errors~=err;
        }
        foreach(i,ubyte pix;pixels){
            if(pix!=1){
             (cast(uint*)this.renderSurface.buffer)[i]=palette[pix];
             pixels[i]=0;
            }
        }
        window.surface.blitScaled(renderSurface,dsdl2.Rect(0,0,window.width,window.height));
        window.update();
    }
    ~this(){
         dsdl2.quit();
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
    void draw(GFX gfx){
        if(!mod){
        foreach(i,ubyte pix;pixels){
                int x=cast(int)(floor(cast(float)(i/dims[0]))+this.x);
                int y=cast(int)((i%dims[1])+this.y);
                if(
                    (pix!=0)&&(x<320)&&(y<240)&&(x>=0)&&(y>=0)
                ){
                    gfx.pixels[cast(ulong)((y*320)+x)]=pix;
                }
            }
        }else{
            foreach(i,ubyte pix;mpixels){
                int x=cast(int)(floor(cast(float)(i/dims[0]))+this.x);
                int y=cast(int)((i%dims[1])+this.y);
                if(
                    (pix!=0)&&(x<320)&&(y<240)&&(x>=0)&&(y>=0)
                ){
                    
                    gfx.pixels[cast(ulong)((y*320)+x)]=pix;
                     
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
/*int[] getPixelRotated(ubyte[] pixels,uint x,uint y,float angle){

}*/