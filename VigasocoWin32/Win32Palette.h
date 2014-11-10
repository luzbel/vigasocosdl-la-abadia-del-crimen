// Win32Palette.h
//
//	The one and the only palette (R, G, B, A. 8 bits per gun)
//
/////////////////////////////////////////////////////////////////////////////

#ifndef _WIN32_PALETTE_H_
#define _WIN32_PALETTE_H_


#include "IPalette.h"
#include "Types.h"


#pragma pack(push, paletteAlignment)
#pragma pack(1)

struct PaletteEntry {
	UINT8 B;
	UINT8 G;
	UINT8 R;
	UINT8 alpha;

	PaletteEntry(){}
	PaletteEntry(int r, int g, int b) { R = r; G = g; B = b; alpha = 0xff; }
	PaletteEntry(int r, int g, int b, int a) { R = r; G = g; B = b; alpha = a; }
};

#pragma pack(pop, paletteAlignment)


// the palette is a Singleton and a Notification Provider
class Win32Palette: public IPalette
{
// fields
protected:
	int _colors;								// total number of colors
	PaletteEntry *_palette;						// pointer to color entries

// methods:
public:
	// initialization and cleanup
	Win32Palette();
	virtual ~Win32Palette();
	virtual void init(int colors);
	virtual void end();

	// IPalette interface getters & setters
	virtual int getTotalColors() const { return _colors; }
	virtual void setColor(int index, UINT8 r, UINT8 g, UINT8 b);
	virtual void getColor(int index, UINT8 &r, UINT8 &g, UINT8 &b);
	
	// custom getters & setters
	void setColor(int index, PaletteEntry pe);
	PaletteEntry getColor(int index) const;
	PaletteEntry *getPalette() const { return _palette; }
	virtual UINT8* getRawPalette() { return (UINT8 *)_palette; }
};


#endif	// _WIN32_PALETTE_H_
