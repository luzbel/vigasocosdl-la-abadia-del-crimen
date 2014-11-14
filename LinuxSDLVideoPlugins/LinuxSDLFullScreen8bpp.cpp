// LinuxSDLFullScreen8bpp.cpp
//
/////////////////////////////////////////////////////////////////////////////

#include "LinuxSDLFullScreen8bpp.h"

bool LinuxSDLFullScreen8bpp::init(const VideoInfo *vi, IPalette *pal)  
{
	_flags|=SDL_FULLSCREEN;

	_isInitialized =  LinuxSDL8bpp::init(vi,pal);

	return _isInitialized;
};
