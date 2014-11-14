///   PRUEBA 8 BITS CON PALETA DE GRISES , ¡¡¡ OJO !!! 8 BITS, no 32


// LinuxSDLWindow32bpp.cpp
//
/////////////////////////////////////////////////////////////////////////////

#include "LinuxSDLWindow32bpp.h"
#include "IPalette.h"

#ifdef DEBUG
#include <stdio.h>
#define DEBUG_FAIL_FUNC printf("%s\n",__func__);
#else
#define DEBUG_FAIL_FUNC 
#endif


	bool LinuxSDLWindow32bpp::init(const VideoInfo *vi, IPalette *pal)  
	{
		if ( SDL_Init(SDL_INIT_VIDEO) < 0 ) {
#ifdef DEBUG
			fprintf(stderr,
                	"Couldn't initialize SDL: %s\n", SDL_GetError());
#endif
			return false;
		}

		screen = SDL_SetVideoMode(640, 480, 8, SDL_HWSURFACE|SDL_DOUBLEBUF);
		if ( screen == NULL ) {
#ifdef DEBUG
		        fprintf(stderr, "Couldn't set 640x480x32 video mode: %s\n",
                        SDL_GetError());
#endif
		        return false;
	    	}
	SDL_Color colors[256];

	for (int i = 0; i < 256; i++){
		colors[i].r=i;
		colors[i].g=i;
		colors[i].b=i;
	}

	fprintf(stderr,"SDL_SetColors screen %d\n",SDL_SetColors(screen, colors, 0, 256)); 

	        // gets a pointer to the game's palette
	        _palette = (UINT32 *)pal->getRawPalette();
		palette=pal;

		_isInitialized = true;

		return true;
	};

	void LinuxSDLWindow32bpp::end()  { LinuxSDLBasicDrawPlugin::end(); };

	// no se porque el linkador se queja sin esto, ?no deberia tomar la virtual de LinuxSDLBasicDrawPlugin ?
	bool LinuxSDLWindow32bpp::isInitialized() const  { return LinuxSDLBasicDrawPlugin::isInitialized(); };


	bool LinuxSDLWindow32bpp::isFullScreen() const  { DEBUG_FAIL_FUNC };

	// bitmap creation/destruction
	int LinuxSDLWindow32bpp::createBitmap(int width, int height) { DEBUG_FAIL_FUNC };  
	void LinuxSDLWindow32bpp::destroyBitmap(int bitmap) { DEBUG_FAIL_FUNC };  

	// bitmap methods
	void LinuxSDLWindow32bpp::setActiveBitmap(int bitmap) { DEBUG_FAIL_FUNC };  
	void LinuxSDLWindow32bpp::compose(int bitmap, int mode, int attr) { DEBUG_FAIL_FUNC };  
	void LinuxSDLWindow32bpp::getDimensions(int &width, int &height) const   { DEBUG_FAIL_FUNC };

	// clipping methods
	const Rect *LinuxSDLWindow32bpp::getClipArea() const   { DEBUG_FAIL_FUNC };
	void LinuxSDLWindow32bpp::setClipArea(int x, int y, int width, int height) { DEBUG_FAIL_FUNC };  
	void LinuxSDLWindow32bpp::setNoClip() { DEBUG_FAIL_FUNC };  

	// drawing methods
	void LinuxSDLWindow32bpp::render(bool throttle)
	{
		// SDL_UpdateRect(screen, 0, 0, 0, 0);
		SDL_Flip(screen);
	};

	void LinuxSDLWindow32bpp::setPixel(int x, int y, int color)
	{
		/* Lock the screen for direct access to the pixels */
		if ( SDL_MUSTLOCK(screen) ) {
			if ( SDL_LockSurface(screen) < 0 ) {
#ifdef DEBUG
		            fprintf(stderr, "Can't lock screen: %s\n", SDL_GetError());
#endif
		            return;
		        }
		}


		int bpp = screen->format->BytesPerPixel;
    		/* Here p is the address to the pixel we want to set */
		Uint8 *p = (Uint8 *)screen->pixels + y * screen->pitch + x * bpp;

//		*(Uint32 *)p = _palette[color]; // este es el codigo para 32 bits, y no para 8

		// *p=color; // asi se ve muy oscuro y no escoge el mejor gris para el color que viene

		UINT8 r, g, b;

		palette->getColor(color, r, g, b);
		//*(Uint32 *)p = SDL_MapRGB(screen->format,r,g,b);  // Con exto salen rayajos ...
		*p = SDL_MapRGB(screen->format,r,g,b);  // Asi, si


		if ( SDL_MUSTLOCK(screen) ) {
			SDL_UnlockSurface(screen);
		}
	};

	void LinuxSDLWindow32bpp::drawLine(int x0, int y0, int x1, int y1, int color) { DEBUG_FAIL_FUNC };  
	void LinuxSDLWindow32bpp::drawRect(Rect *rect, int color) { DEBUG_FAIL_FUNC };  
	void LinuxSDLWindow32bpp::drawRect(int x0, int y0, int width, int height, int color) { DEBUG_FAIL_FUNC };  
	void LinuxSDLWindow32bpp::drawCircle(int x, int y, int radius, int color) { DEBUG_FAIL_FUNC };  
	void LinuxSDLWindow32bpp::drawEllipse(int x, int y, int a, int b, int color) { DEBUG_FAIL_FUNC };  

	void LinuxSDLWindow32bpp::fillRect(Rect *rect, int color) { DEBUG_FAIL_FUNC };  
	void LinuxSDLWindow32bpp::fillRect(int x0, int y0, int width, int height, int color) { DEBUG_FAIL_FUNC };  
	void LinuxSDLWindow32bpp::fillCircle(int x, int y, int radius, int color) { DEBUG_FAIL_FUNC };  
	void LinuxSDLWindow32bpp::fillEllipse(int x, int y, int a, int b, int color) { DEBUG_FAIL_FUNC };  

	void LinuxSDLWindow32bpp::drawGfx(GfxElement *gfx, int code, int color, int x, int y, int attr) { DEBUG_FAIL_FUNC };  
	void LinuxSDLWindow32bpp::drawGfxClip(GfxElement *gfx, int code, int color, int x, int y, int attr) { DEBUG_FAIL_FUNC };  
	void LinuxSDLWindow32bpp::drawGfxTrans(GfxElement *gfx, int code, int color, int x, int y, int attr, int transData) { DEBUG_FAIL_FUNC };  
	void LinuxSDLWindow32bpp::drawGfxClipTrans(GfxElement *gfx, int code, int color, int x, int y, int attr, int transData) { DEBUG_FAIL_FUNC };  

	// access to custom plugin properties
	const std::string *LinuxSDLWindow32bpp::getProperties(int *num) const  { DEBUG_FAIL_FUNC }; 
	const int *LinuxSDLWindow32bpp::getPropertiesType() const   { DEBUG_FAIL_FUNC };
	void LinuxSDLWindow32bpp::setProperty(std::string prop, int data) { DEBUG_FAIL_FUNC };  
	void LinuxSDLWindow32bpp::setProperty(std::string prop, int index, int data) { DEBUG_FAIL_FUNC };  
	int LinuxSDLWindow32bpp::getProperty(std::string prop) const   { DEBUG_FAIL_FUNC };
	int LinuxSDLWindow32bpp::getProperty(std::string prop, int index) const   { DEBUG_FAIL_FUNC };

