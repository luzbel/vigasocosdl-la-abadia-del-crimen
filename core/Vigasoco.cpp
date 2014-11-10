// Vigasoco.cpp
//
/////////////////////////////////////////////////////////////////////////////

#include <cmath>
#include "IDrawPlugin.h"
#include "FileLoader.h"
#include "FontManager.h"
#include "InputHandler.h"
#include "IPalette.h"
#include "IThread.h"
#include "ITimer.h"
#include "TimingHandler.h"
#include "Vigasoco.h"
#include "AbadiaDriver.h"

/////////////////////////////////////////////////////////////////////////////
// initialization and cleanup
/////////////////////////////////////////////////////////////////////////////

Vigasoco::Vigasoco()
{
	_speedThrottle = true;

	_game = "abadia";
	_errorMsg = "";

	_driver = 0;
	_palette = 0;
	_drawPlugin = 0;
	_inputHandler = 0;
	_timingHandler = 0;
	_timer = 0;
	_asyncThread = 0;
	_fontManager = 0;

	_numFrames = 0;
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

	// inits the palette (the last 2 colors are used by the core to display information)
	int numColors = _driver->getVideoInfo()->colors;
	_palette->init(numColors + 2);

	// init the colors used by the core to display information
	_palette->setColor(numColors + 0, 0x00, 0x00, 0x00);
	_palette->setColor(numColors + 1, 0xff, 0xff, 0xff);

	// inits the fonts used by the core
	_fontManager = new FontManager(_palette, numColors/2);
	_fontManager->init();

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
	_driver->videoInitialized(_drawPlugin);

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

	// inits the timing handler
	if (!_timingHandler->init(_timer, _driver->getNumInterruptsPerSecond(), _driver->getNumInterruptsPerVideoUpdate(), _driver->getnumInterruptsPerLogicUpdate())){
		_errorMsg = "timerHandler->init() failed";
		return false;
	}

	// creates the async thread
	createAsyncThread();

	if (!_asyncThread){
		_errorMsg = "createAsyncThread() failed";
		return false;
	}

	// calls template method to perform specific actions after initialization has been completed
	initCompleted();

	return true;
}

/////////////////////////////////////////////////////////////////////////////
// end
/////////////////////////////////////////////////////////////////////////////

void Vigasoco::end()
{
	// stops and deallocates the async thread
	if (_asyncThread){
		destroyAsyncThread();
	}

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
			_driver->videoFinalizing(_drawPlugin);
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

	// disposes the fonts used by the core
	delete _fontManager;
}

/////////////////////////////////////////////////////////////////////////////
// main loop
/////////////////////////////////////////////////////////////////////////////

void Vigasoco::initFrame()
{
	_numFrames++;
}

void Vigasoco::mainLoop()
{
	// start async game logic
	_asyncThread->start();

	// main sync loop
	while (true){
		// call template method to process any platform specific events
		if (!processEvents()){
			// if we've received the quit message, exit

			return;
		}

		// waits if necessary before processing this interrupt
		_timingHandler->waitThisInterrupt();

		bool processVideo = _timingHandler->processVideoThisInterrupt();
		bool processLogic = _timingHandler->processLogicThisInterrupt();

		// if we have to process game logic
		if (processLogic){
			// execute sync game logic
			_driver->runSync();
		}

		// if we have to process video
		if (processVideo){
			// calls template method to notify of the start of a frame
			initFrame();

			// process inputs
			_inputHandler->process();

			// change core state if necessary
			processCoreInputs();

			bool skipVideo = _timingHandler->skipVideoThisInterrupt();

			if (!skipVideo){
				// render game screen
				_driver->render(_drawPlugin);
				_driver->showGameLogic(_drawPlugin);
			}

			//showFPS(skipVideo);

			if (!skipVideo){
				// render game screen to our screen
				_drawPlugin->render(_timingHandler->isThrottling());
			}

			// call template method to notify the end of a frame
			endFrame();
		}

		// end this interrupt processing
		_timingHandler->endThisInterrupt();
	}
}

/////////////////////////////////////////////////////////////////////////////
// helper methods
/////////////////////////////////////////////////////////////////////////////

GameDriver * Vigasoco::createGameDriver(std::string game)
{
	// TODO: move this to a factory
	if (game == "abadia"){
		return new AbadiaDriver();
	} else {
		return 0;
	}
}

void Vigasoco::processCoreInputs()
{
	int _actualVideoFrameSkip;

	// F8 -> circular frameskip decrement
	if (_inputHandler->hasBeenPressed(FUNCTION_8)){
		_actualVideoFrameSkip = _timingHandler->getVideoFrameSkip() - 1;
		if (_actualVideoFrameSkip < 0) _actualVideoFrameSkip = TimingHandler::FRAMESKIP_LEVELS - 1;
		_timingHandler->setVideoFrameSkip(_actualVideoFrameSkip);
	}

	// F8 -> circular frameskip increment
	if (_inputHandler->hasBeenPressed(FUNCTION_9)){
		_actualVideoFrameSkip = _timingHandler->getVideoFrameSkip() + 1;
		if (_actualVideoFrameSkip > (TimingHandler::FRAMESKIP_LEVELS - 1)) _actualVideoFrameSkip =  0;
		_timingHandler->setVideoFrameSkip(_actualVideoFrameSkip);
	}

	// F10 -> toggle throttling
	if (_inputHandler->hasBeenPressed(FUNCTION_10)){
		_speedThrottle = !_speedThrottle;
		_timingHandler->setSpeedThrottle(_speedThrottle);
	}
}

void Vigasoco::showFPS(bool skipThisFrame)
{
	static char buf[256];

	int frameSkip = _timingHandler->getVideoFrameSkip();

	// check if we have to update current FPS
	if ((_numFrames % (TimingHandler::FRAMES_PER_FPS_UPDATE)*(frameSkip + 1)) == 0){

		int currentFPS = (int)floor(_timingHandler->getCurrenFPS() + 0.5);
		int gameFPS = _driver->getVideoInfo()->refreshRate;

		sprintf(buf, "%d/%d fps[fs %d]", currentFPS, gameFPS, frameSkip);
	}

	// show FPS
	if (!skipThisFrame){
		_fontManager->print(_drawPlugin, buf, 0, 0);
	}
}
