// LinuxSDLWindow24bpp.cpp
//
/////////////////////////////////////////////////////////////////////////////

#include "LinuxSDLWindow24bpp.h"

bool LinuxSDLWindow24bpp::init(const VideoInfo *vi, IPalette *pal)  
{

	_isInitialized = LinuxSDL24bpp::init(vi,pal);

	return _isInitialized;
};
