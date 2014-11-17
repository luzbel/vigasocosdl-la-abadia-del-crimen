// SDLDrawPluginPaletaGrises8bpp.cpp
//
/////////////////////////////////////////////////////////////////////////////

#include "SDLVideoPlugins.h"

bool SDLDrawPluginPaletaGrises8bpp::init(const VideoInfo *vi, IPalette *pal)
{
	// sobrecargamos el metodo init
	// e inicializamos a fuego
	// con una paleta de grises la pantalla
	_isInitialized = SDLBasicDrawPlugin<UINT8>::init(vi,pal);

	if ( _isInitialized )
	{
		SDL_Color colors[256];

		for (int i = 0; i < 256; i++){
			colors[i].r=i;
			colors[i].g=i;
			colors[i].b=i;
		}

		fprintf(stderr,"SDL_SetColors screen %d\n",SDL_SetColors(screen, colors, 0, 256)); 
		fprintf(stderr,"SDL_SetColors surface %d\n",SDL_SetColors(surface, colors, 0, 256)); 

		pal->attach(this);
		updateFullPalette(pal);
	}

	return _isInitialized;
}
