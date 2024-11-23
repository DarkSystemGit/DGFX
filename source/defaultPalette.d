import std;
uint[256] palette=genPalette();
uint[256] genPalette(){
    uint[256] dpalette;
    for(uint i=1;i<256;i++){
        dpalette[i]=cast(uint)(dpalette[i-1]+4294967296/i+0x000000FF);   
    }
    return dpalette;
}