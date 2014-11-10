// VIGASOCO Project (c) 2003 by MAB
//
//	See readme.txt for license and usage information.
//
//	Contact information: vigasoco@yahoo.es
//
/////////////////////////////////////////////////////////////////////////////

// Vigasoco.h
//
//	Abstract class that defines the structure of a VIGASOCO port.
//
//	All ports should inherit from this class. This class defines some template 
//	methods in order to provide a common main loop for a VIGASOCO port.
//
/////////////////////////////////////////////////////////////////////////////

#ifndef _VIGASOCO_H_
#define _VIGASOCO_H_


#include "util/Singleton.h"
#include <string>
#include "Types.h"

class IDrawPlugin;		// defined in video/IDrawPlugin.h
class FileLoader;		// defined in FileLoader.h
class GameDriver;		// defined in GameDriver.h
class InputHandler;		// defined in InputHandler.h
class IPalette;			// defined in IPalette.h
class Timer;			// defined in Timer.h
class TimingHandler;	// defined in TimingHandler.h

class Vigasoco : public Singleton<Vigasoco>
{
// fields
protected:
	bool _speedThrottle;
	int _videoFrameSkip;
	int _actualVideoFrameSkip;
	int _minVideoFrameSkip;

	std::string _game;
	std::string _errorMsg;
	GameDriver *_driver;
	IPalette *_palette;
	IDrawPlugin *_drawPlugin;
	InputHandler *_inputHandler;
	Timer *_timer;
	TimingHandler *_timingHandler;

// methods
public:
	// initialization and cleanup
	Vigasoco();
	virtual ~Vigasoco();

	virtual bool init(std::string name);
	virtual void end();

	virtual void mainLoop();

	// getters
	IDrawPlugin *getDrawPlugin() const { return _drawPlugin; }
	InputHandler *getInputHandler() const { return _inputHandler; }
	TimingHandler *getTimingHandler() const { return _timingHandler; }
	const std::string getError() const { return _errorMsg; }

protected:
	// template methods

	// construction
	virtual bool platformSpecificInit() = 0;
	virtual void createPalette() = 0;
	virtual void addCustomLoaders(FileLoader *fl) = 0;
	virtual void createDrawPlugin() = 0;
	virtual void addCustomInputPlugins() = 0;
	virtual void createTimer() = 0;

	// destruction
	virtual void destroyTimer() = 0;
	virtual void removeCustomInputPlugins() = 0;
	virtual void destroyDrawPlugin() = 0;
	virtual void removeCustomLoaders(FileLoader *fl) = 0;
	virtual void destroyPalette() = 0;
	virtual void platformSpecificEnd() = 0;

	virtual bool processEvents() = 0;
	virtual void initFrame(){}
	virtual void endFrame(){}

	// helper methods
	GameDriver *createGameDriver(std::string game);
	void processCoreInputs();
};

#endif	// _VIGASOCO_H_

// 4568M-5694