// LinuxSDLWindow8bpp.cpp
//
/////////////////////////////////////////////////////////////////////////////

#include "LinuxSDLWindow8bpp.h"
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


void PrintFlags(Uint32 flags)
{
	printf("0x%8.8x", (flags & FLAG_MASK));
	if ( flags & SDL_HWSURFACE ) {
		printf(" SDL_HWSURFACE");
	} else {
		printf(" SDL_SWSURFACE");
	}
	if ( flags & SDL_FULLSCREEN ) {
		printf(" | SDL_FULLSCREEN");
	}
	if ( flags & SDL_DOUBLEBUF ) {
		printf(" | SDL_DOUBLEBUF");
	}
	if ( flags & SDL_SRCCOLORKEY ) {
		printf(" | SDL_SRCCOLORKEY");
	}
	if ( flags & SDL_SRCALPHA ) {
		printf(" | SDL_SRCALPHA");
	}
	if ( flags & SDL_RLEACCEL ) {
		printf(" | SDL_RLEACCEL");
	}
	if ( flags & SDL_RLEACCELOK ) {
		printf(" | SDL_RLEACCELOK");
	}
	printf("\n");
	fflush(stdin);
}


	bool LinuxSDLWindow8bpp::init(const VideoInfo *vi, IPalette *pal)  
	{
		if ( SDL_Init(SDL_INIT_VIDEO) < 0 ) {
#ifdef DEBUG
			fprintf(stderr,
                	"Couldn't initialize SDL: %s\n", SDL_GetError());
#endif
			return false;
		}

		//screen = SDL_SetVideoMode(640, 480, 8, SDL_HWSURFACE|SDL_DOUBLEBUF);
		screen = SDL_SetVideoMode(vi->width, vi->height, 8, SDL_HWSURFACE|SDL_DOUBLEBUF);
		if ( screen == NULL ) {
#ifdef DEBUG
		        fprintf(stderr, "Couldn't set 640x480x8 video mode: %s\n",
                        SDL_GetError());
#endif
		        return false;
	    	}
PrintFlags(screen->flags);

		surface = SDL_CreateRGBSurface(SDL_HWSURFACE,screen->w, screen->h,8, 0, 0, 0, 0);
		//surface=screen;

	        // gets a pointer to the game's palette
	        _palette = (UINT32 *)pal->getRawPalette();
//prueba
_pal = pal;

        pal->attach(this);
	        updateFullPalette(pal);


        
		_isInitialized = true;

		return true;
	};

	void LinuxSDLWindow8bpp::end()  { LinuxSDLBasicDrawPlugin::end(); };

	// no se porque el linkador se queja sin esto, ?no deberia tomar la virtual de LinuxSDLBasicDrawPlugin ?
	bool LinuxSDLWindow8bpp::isInitialized() const  { return LinuxSDLBasicDrawPlugin::isInitialized(); };


	bool LinuxSDLWindow8bpp::isFullScreen() const  { DEBUG_FAIL_FUNC };

	// bitmap creation/destruction
	int LinuxSDLWindow8bpp::createBitmap(int width, int height) { DEBUG_FAIL_FUNC };  
	void LinuxSDLWindow8bpp::destroyBitmap(int bitmap) { DEBUG_FAIL_FUNC };  

	// bitmap methods
	void LinuxSDLWindow8bpp::setActiveBitmap(int bitmap) { DEBUG_FAIL_FUNC };  
	void LinuxSDLWindow8bpp::compose(int bitmap, int mode, int attr) { DEBUG_FAIL_FUNC };  
	void LinuxSDLWindow8bpp::getDimensions(int &width, int &height) const   { DEBUG_FAIL_FUNC };

	// clipping methods
	const Rect *LinuxSDLWindow8bpp::getClipArea() const   { DEBUG_FAIL_FUNC };
	void LinuxSDLWindow8bpp::setClipArea(int x, int y, int width, int height) { DEBUG_FAIL_FUNC };  
	void LinuxSDLWindow8bpp::setNoClip() { DEBUG_FAIL_FUNC };  

	// drawing methods
	void LinuxSDLWindow8bpp::render(bool throttle)
	{
		// SDL_UpdateRect(screen, 0, 0, 0, 0);
		SDL_BlitSurface(surface, NULL, screen, NULL);
		SDL_Flip(screen);
	};

	void LinuxSDLWindow8bpp::setPixel(int x, int y, int color)
	{
		        int bpp = surface->format->BytesPerPixel;
			        Uint8 *p = (Uint8 *)surface->pixels + y * surface->pitch + x * bpp;
				        *p=color;

	};

	void LinuxSDLWindow8bpp::drawLine(int x0, int y0, int x1, int y1, int color) { DEBUG_FAIL_FUNC };  
	void LinuxSDLWindow8bpp::drawRect(Rect *rect, int color) { DEBUG_FAIL_FUNC };  
	void LinuxSDLWindow8bpp::drawRect(int x0, int y0, int width, int height, int color) { DEBUG_FAIL_FUNC };  
	void LinuxSDLWindow8bpp::drawCircle(int x, int y, int radius, int color) { DEBUG_FAIL_FUNC };  
	void LinuxSDLWindow8bpp::drawEllipse(int x, int y, int a, int b, int color) { DEBUG_FAIL_FUNC };  

	void LinuxSDLWindow8bpp::fillRect(Rect *rect, int color) { DEBUG_FAIL_FUNC };  
	void LinuxSDLWindow8bpp::fillRect(int x0, int y0, int width, int height, int color) { DEBUG_FAIL_FUNC };  
	void LinuxSDLWindow8bpp::fillCircle(int x, int y, int radius, int color) { DEBUG_FAIL_FUNC };  
	void LinuxSDLWindow8bpp::fillEllipse(int x, int y, int a, int b, int color) { DEBUG_FAIL_FUNC };  

	void LinuxSDLWindow8bpp::drawGfx(GfxElement *gfx, int code, int color, int x, int y, int attr) { DEBUG_FAIL_FUNC };  
	void LinuxSDLWindow8bpp::drawGfxClip(GfxElement *gfx, int code, int color, int x, int y, int attr) { DEBUG_FAIL_FUNC };  
	void LinuxSDLWindow8bpp::drawGfxTrans(GfxElement *gfx, int code, int color, int x, int y, int attr, int transData) { DEBUG_FAIL_FUNC };  
	void LinuxSDLWindow8bpp::drawGfxClipTrans(GfxElement *gfx, int code, int color, int x, int y, int attr, int transData) { DEBUG_FAIL_FUNC };  

	// access to custom plugin properties
	const std::string *LinuxSDLWindow8bpp::getProperties(int *num) const  { DEBUG_FAIL_FUNC }; 
	const int *LinuxSDLWindow8bpp::getPropertiesType() const   { DEBUG_FAIL_FUNC };
	void LinuxSDLWindow8bpp::setProperty(std::string prop, int data) { DEBUG_FAIL_FUNC };  
	void LinuxSDLWindow8bpp::setProperty(std::string prop, int index, int data) { DEBUG_FAIL_FUNC };  
	int LinuxSDLWindow8bpp::getProperty(std::string prop) const   { DEBUG_FAIL_FUNC };
	int LinuxSDLWindow8bpp::getProperty(std::string prop, int index) const   { DEBUG_FAIL_FUNC };

void LinuxSDLWindow8bpp::updateFullPalette(IPalette *palette)
{
	        SDL_Color colors[256];

		        for (int i = 0; i < palette->getTotalColors(); i++){
				                UINT8 r, g, b;

						                palette->getColor(i, r, g, b);
								                colors[i].r=r;
										                colors[i].g=g;
												                colors[i].b=b;
														        }
			        SDL_SetColors(surface, colors, 0, 256);
}

void LinuxSDLWindow8bpp::update(IPalette *palette, int data)
{
	        if (data != -1){
			                UINT8 r, g, b;
					                SDL_Color color;

							                palette->getColor(data, r, g, b);
									                color.r=r;
											                color.g=g;
													                color.b=b;

															                SDL_SetColors(surface, &color, data, 1);
																	        } else {
																			                updateFullPalette(palette);
																					        }
}

