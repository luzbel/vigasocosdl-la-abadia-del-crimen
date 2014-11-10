// DirectDrawFullScreen.h
//
//	Abstract class that has common data and behaviour for fullscreen mode
//
/////////////////////////////////////////////////////////////////////////////

#ifndef _DIRECT_DRAW_FULLSCREEN_H
#define _DIRECT_DRAW_FULLSCREEN_H


#include "DirectDrawPlugin.h"
#include <list>

class DirectDrawFullScreen : public DirectDrawPlugin
{
// types
protected:
	struct DirectDrawMode {
		int width, height;
		int bpp;
		int refreshRate;

		DirectDrawMode(int modeWidth, int modeHeight, int bitsPerPixel, int herz)
		{
			width = modeWidth;
			height = modeHeight;
			bpp = bitsPerPixel;
			refreshRate = herz;
		}
	};

// fields
protected:
	static const std::string g_properties[];
	static const int g_paramTypes[];

	std::list<DirectDrawMode *> _modes;	// available graphic modes

	int _currWidth, _currHeight;		// selected mode information
	int _currRefreshRate;				// selected mode refresh rate
	int _centerX, _centerY;				// offsets to center the game bitmap

	bool _preSelectedMode;

// inherited methods
public:
	// initialization and cleanup
	DirectDrawFullScreen(Win32Settings *settings);
	virtual ~DirectDrawFullScreen();
	virtual bool init(const VideoInfo *vi, IPalette *pal);
	virtual void end();

	// drawing functions must be implemented in the subclasses

	// custom properties
	virtual const std::string* getProperties(int *num) const;
	virtual const int *getPropertiesType() const;
	virtual void setProperty(std::string prop, int data);
	virtual int getProperty(std::string prop) const;

	void addMode(int width, int height, int bpp, int refreshRate);

private:
	static BOOL WINAPI EnumDisplayModes(DDSURFACEDESC *DDSurfaceDesc, void *Context);

protected:
	bool setBestMode();
};


#endif // _DIRECT_DRAW_FULLSCREEN_H