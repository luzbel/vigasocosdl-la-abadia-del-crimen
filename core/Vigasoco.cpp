// Vigasoco.cpp
//
/////////////////////////////////////////////////////////////////////////////

#include "IDrawPlugin.h"
#include "FileLoader.h"
#include "InputHandler.h"
#include "IPalette.h"
#include "Timer.h"
#include "TimingHandler.h"
#include "Vigasoco.h"
#include "Pacmandriver.h"

/////////////////////////////////////////////////////////////////////////////
// initialization and cleanup
/////////////////////////////////////////////////////////////////////////////

Vigasoco::Vigasoco()
{
	_speedThrottle = true;
	_videoFrameSkip = _actualVideoFrameSkip = 0;

	_game = "pacman";
	_errorMsg = "";

	_driver = 0;
	_palette = 0;
	_drawPlugin = 0;
	_inputHandler = 0;
	_timingHandler = 0;
	_timer = 0;
}

Vigasoco::~Vigasoco()
{
}

/////////////////////////////////////////////////////////////////////////////
// init
/////////////////////////////////////////////////////////////////////////////

bool Vigasoco::init(std::string name)
{
	// calls template method to perform platform specific initialization
	if (!platformSpecificInit()){
		_errorMsg = "platformSpecificInit() failed";
		return false;
	}

	// creates the game driver
	_driver = createGameDriver(name);

	if (!_driver){
		_errorMsg = "unknown game " + name;
		return false;
	}

	// calls template method to create the palette
	createPalette();

	if (!_palette){
		_errorMsg = "createPalette() failed";
		return false;
	}

	// inits the palette
	_palette->init(_driver->getVideoInfo()->colors);

	// creates the FileLoader
	FileLoader *fl = new FileLoader();

	// calls template method to add custom loaders
	addCustomLoaders(fl);

	// inits the game driver (load files, decode gfx, preprocessing, etc)
	if (!_driver->init(_palette)){
		// calls template method to remove custom loaders
		removeCustomLoaders(fl);

		delete fl;

		_errorMsg = "driver->init() failed\n" + _driver->getError();

		return false;
	}

	// calls template method to remove custom loaders
	removeCustomLoaders(fl);

	// deletes the FileLoader
	delete fl;

	// calls template method to get a DrawPlugin
	createDrawPlugin();

	if (!_drawPlugin){
		_errorMsg = "createDrawPlugin() failed";
		return false;
	}

	// inits the DrawPlugin with the selected GameDriver
	if (!_drawPlugin->init(_driver->getVideoInfo(), _palette)){
		_errorMsg = "drawPlugin->init() failed";
		return false;
	}

	// notify the driver that the drawPlugin has been initialized
	_driver->videoInitEnd(_drawPlugin);

	// creates the input handler
	_inputHandler = new InputHandler();

	// calls template method to add input plugins
	addCustomInputPlugins();

	// inits the input handler
	if (!_inputHandler->init(_driver)){
		_errorMsg = "inputHandler->init() failed";
		return false;
	}

	// calls template method to get a high resolution timer
	createTimer();

	// creates the timing handler
	_timingHandler = new TimingHandler();

	// stores the minium frame skipping values for this game
	_actualVideoFrameSkip = _minVideoFrameSkip = _driver->getVideoFramesToSkip();

	// inits the timing handler
	if (!_timingHandler->init(_timer, _driver->getVideoInfo()->refreshRate, _driver->getLogicFramesToSkip(), _minVideoFrameSkip)){
		_errorMsg = "timerHandler->init() failed";
		return false;
	}

	return true;
}

/////////////////////////////////////////////////////////////////////////////
// end
/////////////////////////////////////////////////////////////////////////////

void Vigasoco::end()
{
	// stops and deallocates the timing handler
	if (_timingHandler){
		_timingHandler->end();
		delete _timingHandler;
		_timingHandler = 0;
	}

	// calls template method to dispose the high resolution timer
	destroyTimer();

	// stops and deallocates the input handler
	if (_inputHandler){
		_inputHandler->end();

		// calls template method to remove input plugins
		removeCustomInputPlugins();

		delete _inputHandler;
		_inputHandler = 0;
	}

	// notify the driver that the drawPlugin is going to be disposed
	if (_driver && _drawPlugin){
		if (_drawPlugin->isInitialized()){
			_driver->videoEndStart(_drawPlugin);
		}
	}

	// ends the draw plugin
	if (_drawPlugin){
		_drawPlugin->end();
	}

	// calls template method to stop and deallocate the draw plugin
	destroyDrawPlugin();

	// ends and deallocates the game driver
	if (_driver){
		_driver->end();
		delete _driver;
		_driver = 0;
	}

	// finish the palette
	if (_palette){
		_palette->end();
	}

	// calls template method to destroy the palette
	destroyPalette();

	// calls template method to perform platform specific finalization
	platformSpecificEnd();
}

/////////////////////////////////////////////////////////////////////////////
// main loop
/////////////////////////////////////////////////////////////////////////////

void Vigasoco::mainLoop()
{
	while (true){
		// call template method to process any platform specific events
		if (!processEvents()){
			// if we've received the quit message, exit

			return;
		}

		// calls template method to notify of the start of a frame
		initFrame();

		bool skipVideo = _timingHandler->skipThisVideoFrame();
		bool skipLogic = _timingHandler->skipThisLogicFrame();

		// waits if necessary before processing this frame
		_timingHandler->waitThisFrame();

		if (!skipLogic){
			// execute game logic
			_driver->run();
		}

		if (!skipVideo){
			// process inputs
			_inputHandler->process();

			// render game screen
			_driver->render(_drawPlugin);
			_driver->showGameLogic(_drawPlugin);
			_drawPlugin->render(_timingHandler->isThrottling());

			// change core state if necessary
			processCoreInputs();
		}

		// end of frame processing
		_timingHandler->endThisFrame();

		// call template method to notify of the end of a frame
		endFrame();
	}
}

/////////////////////////////////////////////////////////////////////////////
// helper methods
/////////////////////////////////////////////////////////////////////////////

GameDriver * Vigasoco::createGameDriver(std::string game)
{
	// TODO: move this to a factory
	if (game == "pacman"){
		return new PacmanDriver();
	} else {
		return 0;
	}
}

void Vigasoco::processCoreInputs()
{
	// F8 -> circular frameskip decrement
	if (_inputHandler->hasBeenPressed(FUNCTION_8)){
		_actualVideoFrameSkip = _actualVideoFrameSkip - 1;
		if (_actualVideoFrameSkip < _minVideoFrameSkip) _actualVideoFrameSkip = TimingHandler::FRAMESKIP_LEVELS - 1;
		_timingHandler->setVideoFrameSkip(_actualVideoFrameSkip);
	}

	// F8 -> circular frameskip increment
	if (_inputHandler->hasBeenPressed(FUNCTION_9)){
		_actualVideoFrameSkip = _actualVideoFrameSkip + 1;
		if (_actualVideoFrameSkip > (TimingHandler::FRAMESKIP_LEVELS - 1)) _actualVideoFrameSkip =  _minVideoFrameSkip;
		_timingHandler->setVideoFrameSkip(_actualVideoFrameSkip);
	}

	// F10 -> toggle throttling
	if (_inputHandler->hasBeenPressed(FUNCTION_10)){
		_speedThrottle = !_speedThrottle;
		_timingHandler->setSpeedThrottle(_speedThrottle);
	}
}