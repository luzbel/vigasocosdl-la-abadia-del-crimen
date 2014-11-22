// SDLBasicDrawPluginTemplates.cpp
//
/////////////////////////////////////////////////////////////////////////////

#include "SDLBasicDrawPlugin.h"
#include "IPalette.h"

template<typename T>
bool SDLBasicDrawPlugin<T>::init(const VideoInfo *vi, IPalette *pal)
{
	if ( SDL_Init(SDL_INIT_VIDEO) < 0 ) {
		fprintf(stderr,
				"Couldn't initialize SDL: %s\n", SDL_GetError());
		return false;
	}

	screen = SDL_SetVideoMode(vi->width, vi->height, _bpp, _flags);
	if ( screen == NULL ) {
		fprintf(stderr, "Couldn't set %dx%dx%d video mode: %s\n",
				vi->width,vi->height,_bpp,SDL_GetError());
		return false;
	}
	fprintf(stderr, "set %dx%dx%d video mode: %s\n",
				vi->width,vi->height,_bpp,SDL_GetError());

//	surface = SDL_CreateRGBSurface(SDL_HWSURFACE,screen->w, screen->h,screen->format->BitsPerPixel, 0, 0, 0, 0);
surface=screen;

	if (surface == NULL ) {
		fprintf(stderr, "Couldn't create surface: %s\n", SDL_GetError());
		_isInitialized=false;
		return false;
	}

	_originalPalette=pal;

	_palette = new T[pal->getTotalColors()];
	pal->attach(this);
	updateFullPalette(pal);
//fprintf(stderr,"vw %d vh %d w %d h %d\n",vi->width,vi->height,screen->w,screen->h);
updated=false;
/*
minX=vi->width-1;
maxX=0;
minY=vi->height-41;  // ;vi->height-1;
maxY=0;
updatedr1=false;
updatedr2=false;
r2.x=vi->width-1;
r2.y=vi->height-1;
r2.w=0;
r2.h=0;
*/
	_isInitialized = true;
	
	return _isInitialized;
};


template<typename T>
void SDLBasicDrawPlugin<T>::end()  { 
	if ( _originalPalette )
		_originalPalette->detach(this);
	_isInitialized = false;
};


/////////////////////////////////////////////////////////////////////////////
// Palette changes
/////////////////////////////////////////////////////////////////////////////

template<typename T>
void SDLBasicDrawPlugin<T>::updateFullPalette(IPalette *palette)
{
	for (int i = 0; i < palette->getTotalColors(); i++){
		UINT8 r, g, b;

		palette->getColor(i, r, g, b);
		_palette[i] = SDL_MapRGB(surface->format,r,g,b);
	}
}

template<typename T>
void SDLBasicDrawPlugin<T>::update(IPalette *palette, int data)
{
	if (data != -1){
		// single color update
		UINT8 r, g, b;

		palette->getColor(data, r, g, b);
		_palette[data] = SDL_MapRGB(surface->format,r,g,b);
	} else {
		// full palette update
		updateFullPalette(palette);	
	}
}

/////////////////////////////////////////////////////////////////////////////
// filled primitives
/////////////////////////////////////////////////////////////////////////////

// fills a rectangle
template<typename T>
void SDLBasicDrawPlugin<T>::fillRect(int x, int y, int width, int height, int color)
{
        int xLimit = width + x - 1;

        for (; height > 0; height--, y++){
                fillScanLine(x, xLimit, y, color);
        }
}

/////////////////////////////////////////////////////////////////////////////
// helper methods
/////////////////////////////////////////////////////////////////////////////

// fills a horizontal line with a color
template<typename T>
void SDLBasicDrawPlugin<T>::fillScanLine(int x0, int x1, int y, int color)
{
        if (x1 < x0) {
                std::swap<int>(x0, x1);
        }

        for (int x = x0; x <= x1; x++){
                setPixel(x, y, color);
        }
}



// drawing methods
template<typename T>
void SDLBasicDrawPlugin<T>::render(bool throttle)
{
	if ( updated )
	{
//	if ( SDL_BlitSurface(surface, NULL, screen, NULL) < 0 )
//		fprintf(stderr, "SDL error when BlitSurface %s\n", SDL_GetError());
	SDL_Flip(screen);
	}
/*	
if(updatedr1)
{
	SDL_Rect r;
	r.x=minX;
	r.y=minY;
	r.w=maxX-minX+1;
	r.h=maxY-minY+1;
//	fprintf(stderr,"RECT: %d , %d - %d , %d\n",minX,minY,maxX,maxY);
//	SDL_BlitSurface(surface,&r,screen,&r);
	//jSDL_UpdateRect(screen,minX,minY,maxX-minX,maxY-minY);
	SDL_UpdateRect(screen,r.x,r.y,r.w,r.h);
minX=screen->w-1;
maxX=0;
minY=screen->h-41; // screen->h-1;
maxY=0;
updatedr1=false;
}
if(updatedr2)
{
r2.w=r2.w-r2.x+1;
r2.h=r2.h-r2.y+1;
//	fprintf(stderr,"RECT2: %d , %d - %d , %d\n",r2.x,r2.y,r2.w,r2.h);
	SDL_UpdateRect(screen,r2.x,r2.y,r2.w,r2.h);
r2.x=screen->w-1;
r2.y=screen->h-1;
r2.w=0;
r2.h=0;
updatedr2=false;
}
*/
};
	
template<typename T>
void SDLBasicDrawPlugin<T>::setPixel(int x, int y, int color)
{
	/* Lock the surface for direct access to the pixels */
	if ( SDL_MUSTLOCK(surface) ) {
		if ( SDL_LockSurface(surface) < 0 ) {
			fprintf(stderr, "Can't lock surface: %s\n", SDL_GetError());
			return;
		}
	}
/* para un solo rect. 
updated=true;
if ( x < minX ) minX=x;
if ( x>maxX ) maxX = x; 
if ( y < minY ) minY=y;
if ( y>maxY ) maxY = y;
*/
	/*
if ( y<screen->h-41 )
{
updatedr1=true;
if ( x < minX ) minX=x;
if ( x>maxX ) maxX = x; 
if ( y < minY ) minY=y;
if ( y>maxY ) maxY = y;
}
else
{
updatedr2=true;
if (x < r2.x ) r2.x=x;
if (x>r2.w) r2.w=x;
if (y<r2.y) r2.y=y;
if (y>r2.h) r2.h=y;
} */

	int __bpp = surface->format->BytesPerPixel;
	/* Here p is the address to the pixel we want to set */
	Uint8 *p = (Uint8 *)surface->pixels + y * surface->pitch + x * __bpp;

	*(T *)p = _palette[color]; // Vale para todos los bpp, excepto 24bpp

	if ( SDL_MUSTLOCK(surface) ) {
		SDL_UnlockSurface(surface);
	}
};
