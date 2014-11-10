// GameDriver.h
//
//	Abstract class that models a game
//
//	All game drivers should inherit from this class. This class defines some
//	template methods in order to simplify common tasks.
//
//	The lifecycle of a game driver is:
//		* fill all game fields in the constructor (video info, game files, gfx
//		format, input ports, DIPS, etc).
//		* the core calls to GameDriver::init that does the following:
//			- load all the files in the game data entities.
//			- call template method filesLoaded, where the driver does specific
//			initialization (set color palette, unscramble gfx, etc).
//			- decode all game data entity of type GRAPHICS, using the items in
//			_gfxEncoding (the first graphic entity uses the first item, and so on).
//			- call template method graphicsDecoded, where the driver can do any
//			specific processing.
//			- deallocate the memory used by the game data entities.
//			- call template method finishInit, where the driver can do last
//			specific processing before the driver starts running.
//		* while the application is running, the core calls to:
//			- GameDriver::run, that executes the logic for a frame.
//			- GameDriver::render, that draws the game bitmap.
//			- GameDriver::showGameLogic, that it's used to show some internal 
//			data in order to better understand how the game works.
//		* when the application is closing, the core calls to GameDriver::end 
//		that does any needed cleanup and calls template method startEnd, where
//		the driver can perform any specific cleanup
//
/////////////////////////////////////////////////////////////////////////////

#ifndef _GAME_DRIVER_H_
#define _GAME_DRIVER_H_


#include "GameDataEntity.h"
#include <string>
#include "Types.h"
#include <vector>

class IDrawPlugin;		// defined in video/IDrawPlugin.h
struct GfxElement;		// defined in GfxData.h
struct GfxEncoding;		// defined in GfxData.h
class IPalette;			// defined in palette.h
class InputPort;		// defined in InputPort.h


class GameDriver
{
// types
public:
	typedef std::vector<GameDataEntity *> GameDataEntities;
	typedef std::vector<GfxEncoding *> GfxEncodings;
	typedef std::vector<GfxElement *> GfxElements;
	typedef std::vector<InputPort *> InputPorts;

// fields
protected:
	std::string _driverName;
	VideoInfo _videoInfo;

	int _logicFramesToSkip;
	int _videoFramesToSkip;

	GameDataEntities _gameFiles;
	GfxEncodings _gfxEncoding;
	GfxElements _gfx;
	InputPorts _inputs;

	IPalette *_palette;

	std::string _errorMsg;

// methods
public:
	// getters
	const VideoInfo *getVideoInfo() const { return &_videoInfo; }
	const std::string getDriverName() const { return _driverName; }
	const GameDataEntities* getGameFiles() const { return &_gameFiles; }
	const GfxEncodings* getGameGfxEncoding() const { return &_gfxEncoding; }
	const GfxElements* getGameGfx() const { return &_gfx; }
	InputPorts *getInputs() { return &_inputs; }
	int getLogicFramesToSkip() const { return _logicFramesToSkip; }
	int getVideoFramesToSkip() const { return _videoFramesToSkip; }
	const std::string getError() const { return _errorMsg; }

	// game driver initialization and cleanup
	bool init(IPalette *pal);
	virtual void end();

	virtual void run() = 0;
	virtual void render(IDrawPlugin *dp) = 0;
	virtual void showGameLogic(IDrawPlugin *dp){}

	// initialization and cleanup
	GameDriver(std::string driverName);
	virtual ~GameDriver();

	// template methods
	virtual void videoInitEnd(IDrawPlugin *dp){}
	virtual void videoEndStart(IDrawPlugin *dp){}

protected:
	// template methods
	virtual void filesLoaded(){}
	virtual void graphicsDecoded(){}
	virtual void finishInit(){}
	virtual void startEnd(){}

	// helper methods
	bool loadFiles();
	bool decodeGraphics();
	void deallocateFilesMemory();
};

#endif	// _GAME_DRIVER_H_