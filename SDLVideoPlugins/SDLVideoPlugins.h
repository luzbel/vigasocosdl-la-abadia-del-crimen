// SDLVideoPlugins.h 
/////////////////////////////////////////////////////////////////////////////

#ifndef _SDL_VIDEO_PLUGINS_H_
#define _SDL_VIDEO_PLUGINS_H_

#include "SDLBasicDrawPlugin.h"

class SDLDrawPlugin8bpp : public SDLBasicDrawPlugin<UINT8>
{
	public:
		SDLDrawPlugin8bpp::SDLDrawPlugin8bpp() { _bpp = 8; }
		virtual void render(bool throttle);
		virtual void setPixel(int x, int y, int color);
	protected:
		// palette changed notification
		virtual void update(IPalette *palette, int data);
		virtual void updateFullPalette(IPalette *palette);
};

class SDLDrawPlugin16bpp : public SDLBasicDrawPlugin<UINT16>
{
	public:
		SDLDrawPlugin16bpp::SDLDrawPlugin16bpp() { _bpp = 16; }
};

class SDLDrawPlugin24bpp : public SDLBasicDrawPlugin<UINT32>
{
	public:
		SDLDrawPlugin24bpp::SDLDrawPlugin24bpp() { _bpp = 24; }
		virtual void setPixel(int x, int y, int color);
};

class SDLDrawPlugin32bpp : public SDLBasicDrawPlugin<UINT32>
{
	public:
		SDLDrawPlugin32bpp::SDLDrawPlugin32bpp() { _bpp = 32; }
};

class SDLDrawPluginPaletaGrises8bpp : public SDLBasicDrawPlugin<UINT8>
{
	public:
		SDLDrawPluginPaletaGrises8bpp::SDLDrawPluginPaletaGrises8bpp() { _bpp = 8; }
		virtual bool init(const VideoInfo *vi, IPalette *pal);
};

typedef SDLDrawPlugin8bpp SDLDrawPluginWindow8bpp;
typedef SDLDrawPlugin16bpp SDLDrawPluginWindow16bpp;
typedef SDLDrawPlugin24bpp SDLDrawPluginWindow24bpp;
typedef SDLDrawPlugin32bpp SDLDrawPluginWindow32bpp;
typedef SDLDrawPluginPaletaGrises8bpp SDLDrawPluginWindowPaletaGrises8bpp;

template <class T>
class SDLDrawPluginFullScreen: public T
{
	public:
		SDLDrawPluginFullScreen::SDLDrawPluginFullScreen() { _flags|=SDL_FULLSCREEN; }
};

typedef SDLDrawPluginFullScreen<SDLDrawPlugin8bpp> SDLDrawPluginFullScreen8bpp;
typedef SDLDrawPluginFullScreen<SDLDrawPlugin16bpp> SDLDrawPluginFullScreen16bpp;
typedef SDLDrawPluginFullScreen<SDLDrawPlugin24bpp> SDLDrawPluginFullScreen24bpp;
typedef SDLDrawPluginFullScreen<SDLDrawPlugin32bpp> SDLDrawPluginFullScreen32bpp;
typedef SDLDrawPluginFullScreen<SDLDrawPluginPaletaGrises8bpp> SDLDrawPluginFullScreenPaletaGrises8bpp;

#endif // _SDL_VIDEO_PLUGINS_H_
