import std;
static import dsdl;
import bindbc.sdl;
import defaultPalette;

class GFXThread
{
    dsdl.Window window;
    dsdl.Surface renderSurface;
    ubyte[] pixels;
    ubyte[] renderPixels;
    bool running;
    uint[2] dims;
    string[] events;
    string[] errors;
    uint[256] palette;
    uint[] renderBuffer;
    this(string name, uint[2] dimensions)
    {
        dsdl.loadSO();
        dsdl.init(video : true);
        this.dims = dimensions;
        this.window = new dsdl.Window(name, [0, 0], dims, false, false, false, false, true, false, false, true);
        this.renderPixels = new ubyte[320 * 240];
        this.renderSurface = new dsdl.Surface([320, 240], dsdl.PixelFormat.rgba8888);
        this.palette = defaultPalette.palette;
    }

    dsdl.Scancode[] getPressedKeys()
    {
        dsdl.Scancode[] keys;
        foreach (int i, bool key; dsdl.getKeyboardState())
        {
            if (key)
            {
                keys ~= cast(dsdl.Scancode) i;
            }
        }
        return keys;
    }

    void loop()
    {

        dsdl.pumpEvents();
        while (auto event = dsdl.pollEvent())
        {
            events ~= event.toString().replace("dsdl.", "").replace("()", "");
        }
        string err = SDL_GetError().to!string;
        if (err != "")
        {
            errors ~= err;
        }
        foreach (i, ubyte pix; renderPixels)
        {
            if (pix != 0)
            {
                (cast(uint*) this.renderSurface.buffer)[i] = palette[pix];
                //renderPixels[i]=0;
            }
        }
        window.surface.blitScaled(renderSurface, dsdl.Rect(0, 0, window.width, window.height));
        window.update();
    }

    ~this()
    {
        dsdl.quit();
    }
}
