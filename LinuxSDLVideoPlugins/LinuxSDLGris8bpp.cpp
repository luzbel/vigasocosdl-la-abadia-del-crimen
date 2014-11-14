// LinuxSDLGris8bpp.cpp
//
/////////////////////////////////////////////////////////////////////////////

#include "LinuxSDLGris8bpp.h"

bool LinuxSDLGris8bpp::init(const VideoInfo *vi, IPalette *pal)
{
fprintf(stderr,"LinuxSDLGris8bpp::init\n");
	// sobrecargamos el metodo init
	// e inicializamos a fuego
	// con una paleta de grises
	// NO nos enganchamos al sistema de notificacion de cambio de paleta
	_bpp = 8;
//	_flags|=SDL_FULLSCREEN;
	_isInitialized = LinuxSDLBasicDrawPlugin::init(vi,pal);

	SDL_Color colors[256];

	for (int i = 0; i < 256; i++){
		colors[i].r=i;
		colors[i].g=i;
		colors[i].b=i;
	}

	fprintf(stderr,"SDL_SetColors screen %d\n",SDL_SetColors(screen, colors, 0, 256)); 
//	fprintf(stderr,"SDL_SetColors surface %d\n",SDL_SetColors(surface, colors, 0, 256)); 

	pal->attach(this);
	updateFullPalette(pal);

	return _isInitialized;
}
