// LinuxSDLWindow16bpp.cpp
//
/////////////////////////////////////////////////////////////////////////////

#include "LinuxSDLWindow16bpp.h"

bool LinuxSDLWindow16bpp::init(const VideoInfo *vi, IPalette *pal)  
{

	_isInitialized = LinuxSDL16bpp::init(vi,pal);

	return _isInitialized;
};
