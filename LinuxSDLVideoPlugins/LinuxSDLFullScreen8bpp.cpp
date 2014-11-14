// LinuxSDLFullScreen8bpp.cpp
//
/////////////////////////////////////////////////////////////////////////////

#include "LinuxSDLFullScreen8bpp.h"
#include "IPalette.h"

#ifdef DEBUG
#include <stdio.h>
#define DEBUG_FAIL_FUNC printf("%s\n",__func__);
#else
#define DEBUG_FAIL_FUNC 
#endif

#define FLAG_MASK       (SDL_HWSURFACE | SDL_FULLSCREEN | SDL_DOUBLEBUF | \
		SDL_SRCCOLORKEY | SDL_SRCALPHA | SDL_RLEACCEL  | \
		SDL_RLEACCELOK)




	bool LinuxSDLFullScreen8bpp::init(const VideoInfo *vi, IPalette *pal)  
	{
		_bpp = 8;

		_flags|=SDL_FULLSCREEN;

		_isInitialized =  LinuxSDLBasicDrawPlugin::init(vi,pal);

		return _isInitialized;
	};



	//void LinuxSDLFullScreen8bpp::end()  { _pal->detach(this); LinuxSDLBasicDrawPlugin::end(); };
	void LinuxSDLFullScreen8bpp::end()  {  LinuxSDLBasicDrawPlugin::end(); };

	// no se porque el linkador se queja sin esto, ?no deberia tomar la virtual de LinuxSDLBasicDrawPlugin ?
	bool LinuxSDLFullScreen8bpp::isInitialized() const  { return LinuxSDLBasicDrawPlugin::isInitialized(); };


	bool LinuxSDLFullScreen8bpp::isFullScreen() const  { DEBUG_FAIL_FUNC };

	// bitmap creation/destruction
	int LinuxSDLFullScreen8bpp::createBitmap(int width, int height) { DEBUG_FAIL_FUNC };  
	void LinuxSDLFullScreen8bpp::destroyBitmap(int bitmap) { DEBUG_FAIL_FUNC };  

	// bitmap methods
	void LinuxSDLFullScreen8bpp::setActiveBitmap(int bitmap) { DEBUG_FAIL_FUNC };  
	void LinuxSDLFullScreen8bpp::compose(int bitmap, int mode, int attr) { DEBUG_FAIL_FUNC };  
	void LinuxSDLFullScreen8bpp::getDimensions(int &width, int &height) const   { DEBUG_FAIL_FUNC };

	// clipping methods
	const Rect *LinuxSDLFullScreen8bpp::getClipArea() const   { DEBUG_FAIL_FUNC };
	void LinuxSDLFullScreen8bpp::setClipArea(int x, int y, int width, int height) { DEBUG_FAIL_FUNC };  
	void LinuxSDLFullScreen8bpp::setNoClip() { DEBUG_FAIL_FUNC };  

/////////////////////////////////////////////////////////////////////////////
//// Palette changes
///////////////////////////////////////////////////////////////////////////////

void LinuxSDLFullScreen8bpp::updateFullPalette(IPalette *palette)
{
	SDL_Color colors[256];
			fprintf(stderr,"LinuxSDLFullScreen8bpp::updateFullPalette\n");
	for (int i = 0; i < palette->getTotalColors(); i++){
		UINT8 r, g, b;

		palette->getColor(i, r, g, b);
		colors[i].r=r;
		colors[i].g=g;
		colors[i].b=b;
	}
	SDL_SetColors(surface, colors, 0, 256);
//	SDL_SetColors(screen, colors, 0, 256); 
}

void LinuxSDLFullScreen8bpp::update(IPalette *palette, int data)
{
	if (data != -1){
		// single color update
		UINT8 r, g, b;
		SDL_Color color;

		palette->getColor(data, r, g, b);
		color.r=r;
		color.g=g;
		color.b=b;

		SDL_SetColors(surface, &color, data, 1);
//		SDL_SetColors(screen, &color, data, 1); // esto hace cosas raras ??? 
	} else {
		// full palette update
		updateFullPalette(palette);
	}
}
	//
	// drawing methods
	void LinuxSDLFullScreen8bpp::render(bool throttle)
	{
		// SDL_UpdateRect(screen, 0, 0, 0, 0);
		if ( SDL_BlitSurface(surface, NULL, screen, NULL) < 0 )
			fprintf(stderr, "SDL error when BlitSurface %s\n", SDL_GetError());
//		else fprintf(stderr, "OK\n");
		SDL_Flip(screen);
	};

	void LinuxSDLFullScreen8bpp::setPixel(int x, int y, int color)
	{
		/* Lock the screen for direct access to the pixels */
		if ( SDL_MUSTLOCK(surface) ) {
			if ( SDL_LockSurface(surface) < 0 ) {
#ifdef DEBUG
		            fprintf(stderr, "Can't lock surface: %s\n", SDL_GetError());
#endif
		            return;
		        }
		}


		int bpp = surface->format->BytesPerPixel;
    		/* Here p is the address to the pixel we want to set */
		Uint8 *p = (Uint8 *)surface->pixels + y * surface->pitch + x * bpp;
//*p=255;
*p=color;
//		 *p = _palette[color]; // esto se ve mal, pero al menos va rapido ;-)
// 666 esto es una prueba leyendo a lo bruto ...
// cambiar por un codigo en condiciones...
// _palette es una clase...
// ?quizas deberia cambiar LinuxSDLPalette por las estructuras de paleta de SDL
// y usar el SDL_MapRGB cuando hagan un SetColor y aqui hacer simplemente un GetColor
// asi puede que todas las clases LinuxSDLWindow??bpp compartan mucho codigo ...
/*
		Uint8 *tmp = (Uint8 *)&(_palette[color]);
		Uint8 b = *tmp;
		tmp++;
		Uint8 g = *tmp;
		tmp++;
		Uint8 r = *tmp;

		*p = SDL_MapRGB(surface->format,r,g,b);
		*/

		/* esto no va, struct PaletteEntry no es una estructura conocida, es interna a LinuxSDLPalette ...
		struct PaletteEntry *_PaletteEntry;
		_PaletteEntry= (PaletteEntry*)_palette; // Mejor crearlo en el init y que la variable sea de la clase

		*p = SDL_MapRGB(surface->format,_PaletteEntry[color].r,_PaletteEntry[color].g,_PaletteEntry[color].b);
		*/

		/* otra prueba , pero va muy lento
		Uint8 b,g,r;
		_pal->getColor(color,r,g,b);
		*p = SDL_MapRGB(surface->format,r,g,b); 
		*/



		if ( SDL_MUSTLOCK(surface) ) {
			SDL_UnlockSurface(surface);
		}
	};

	void LinuxSDLFullScreen8bpp::drawLine(int x0, int y0, int x1, int y1, int color) { DEBUG_FAIL_FUNC };  
	void LinuxSDLFullScreen8bpp::drawRect(Rect *rect, int color) { DEBUG_FAIL_FUNC };  
	void LinuxSDLFullScreen8bpp::drawRect(int x0, int y0, int width, int height, int color) { DEBUG_FAIL_FUNC };  
	void LinuxSDLFullScreen8bpp::drawCircle(int x, int y, int radius, int color) { DEBUG_FAIL_FUNC };  
	void LinuxSDLFullScreen8bpp::drawEllipse(int x, int y, int a, int b, int color) { DEBUG_FAIL_FUNC };  

	void LinuxSDLFullScreen8bpp::fillRect(Rect *rect, int color) { DEBUG_FAIL_FUNC };  
	void LinuxSDLFullScreen8bpp::fillRect(int x0, int y0, int width, int height, int color) { DEBUG_FAIL_FUNC };  
	void LinuxSDLFullScreen8bpp::fillCircle(int x, int y, int radius, int color) { DEBUG_FAIL_FUNC };  
	void LinuxSDLFullScreen8bpp::fillEllipse(int x, int y, int a, int b, int color) { DEBUG_FAIL_FUNC };  

	void LinuxSDLFullScreen8bpp::drawGfx(GfxElement *gfx, int code, int color, int x, int y, int attr) { DEBUG_FAIL_FUNC };  
	void LinuxSDLFullScreen8bpp::drawGfxClip(GfxElement *gfx, int code, int color, int x, int y, int attr) { DEBUG_FAIL_FUNC };  
	void LinuxSDLFullScreen8bpp::drawGfxTrans(GfxElement *gfx, int code, int color, int x, int y, int attr, int transData) { DEBUG_FAIL_FUNC };  
	void LinuxSDLFullScreen8bpp::drawGfxClipTrans(GfxElement *gfx, int code, int color, int x, int y, int attr, int transData) { DEBUG_FAIL_FUNC };  

	// access to custom plugin properties
	const std::string *LinuxSDLFullScreen8bpp::getProperties(int *num) const  { DEBUG_FAIL_FUNC }; 
	const int *LinuxSDLFullScreen8bpp::getPropertiesType() const   { DEBUG_FAIL_FUNC };
	void LinuxSDLFullScreen8bpp::setProperty(std::string prop, int data) { DEBUG_FAIL_FUNC };  
	void LinuxSDLFullScreen8bpp::setProperty(std::string prop, int index, int data) { DEBUG_FAIL_FUNC };  
	int LinuxSDLFullScreen8bpp::getProperty(std::string prop) const   { DEBUG_FAIL_FUNC };
	int LinuxSDLFullScreen8bpp::getProperty(std::string prop, int index) const   { DEBUG_FAIL_FUNC };

