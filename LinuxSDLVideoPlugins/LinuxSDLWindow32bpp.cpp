// LinuxSDLWindow32bpp.cpp
//
/////////////////////////////////////////////////////////////////////////////

#include "LinuxSDLWindow32bpp.h"

bool LinuxSDLWindow32bpp::init(const VideoInfo *vi, IPalette *pal)  
{

	_isInitialized = LinuxSDL32bpp::init(vi,pal);

	return _isInitialized;
};
