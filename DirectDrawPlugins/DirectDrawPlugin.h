// DirectDrawPlugin.h
//
//	Abstract class that has common data and behaviour for all DirectDraw plugins
//
/////////////////////////////////////////////////////////////////////////////

#ifndef _DIRECT_DRAW_PLUGIN_H_
#define _DIRECT_DRAW_PLUGIN_H_


#include <ddraw.h>
#include "BasicDrawPlugin.h"
#include "Types.h"
#include "Win32Settings.h"

struct PaletteConversion {
	int RShiftBits, GShiftBits, BShiftBits;
	int RIgnoredBits, GIgnoredBits, BIgnoredBits;
};

class DirectDrawPlugin : public BasicDrawPlugin
{
// fields
protected:
	Win32Settings *_settings;				// important win32 vars
	LPDIRECTDRAW2 _pIDD2;					// IDirectDraw2 interface
	LPDIRECTDRAWSURFACE _screenBuf;			// screen surface

	PaletteConversion _palConv;				// palette conversion data

// inherited methods
public:
	// initialization and cleanup
	DirectDrawPlugin(Win32Settings *settings);
	virtual ~DirectDrawPlugin();
	virtual bool init(const VideoInfo *vi, IPalette *pal);
	virtual void end();

	// drawing functions must be implemented in the subclasses

// helper methods
protected:
	void clearBuf(IDirectDrawSurface *buf, UINT32 color);
	bool getRGBMasks();
	bool createWnd();

	// color conversion
	static UINT16 convertColorTo16bpp(PaletteConversion *conv, int R, int G, int B);
	static void getMaskInfo(UINT32 mask, int &shiftBits, int &numBits);
};

#endif // _DIRECT_DRAW_PLUGIN_H_
