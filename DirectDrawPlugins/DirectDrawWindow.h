// DirectDrawWindow.h
//
//	Abstract class that has common data and behaviour for windowed mode
//
/////////////////////////////////////////////////////////////////////////////

#ifndef _DIRECT_DRAW_WINDOW_H_
#define _DIRECT_DRAW_WINDOW_H_


#include "DirectDrawPlugin.h"

class DirectDrawWindow : public DirectDrawPlugin
{
// fields
protected:
	static const std::string g_properties[];
	static const int g_paramTypes[];

	LPDIRECTDRAWSURFACE _auxBuf;		// auxiliary surface to avoid flickering
	int _scale;							// game display scale
	bool _hardware;						// use hardware acceleration when scaling


// inherited methods
public:
	// initialization and cleanup
	DirectDrawWindow(Win32Settings *settings);
	virtual ~DirectDrawWindow();
	virtual bool init(const VideoInfo *vi, IPalette *pal);
	virtual void end();

	// drawing functions must be implemented in the subclasses

	// custom properties
	virtual const std::string *getProperties(int *num) const;
	virtual const int *getPropertiesType() const;
	virtual void setProperty(std::string prop, int data);
	virtual int getProperty(std::string prop) const;

protected:
	bool createAuxiliarySurface(int scaleScreen, int scaleWin);
};


#endif // _DIRECT_DRAW_WINDOW_H