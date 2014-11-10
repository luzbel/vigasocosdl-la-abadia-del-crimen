// TimingHandler.cpp
//
/////////////////////////////////////////////////////////////////////////////

#include "TimingHandler.h"
#include "Timer.h"


const bool TimingHandler::g_skipTable[FRAMESKIP_LEVELS][FRAMESKIP_LEVELS] = {
	{ false,false,false,false,false,false,false,false,false,false,false,false },
	{ false,false,false,false,false,false,false,false,false,false,false, true },
	{ false,false,false,false,false, true,false,false,false,false,false, true },
	{ false,false,false, true,false,false,false, true,false,false,false, true },
	{ false,false, true,false,false, true,false,false, true,false,false, true },
	{ false, true,false,false, true,false, true,false,false, true,false, true },
	{ false, true,false, true,false, true,false, true,false, true,false, true },
	{ false, true,false, true, true,false, true,false, true, true,false, true },
	{ false, true, true,false, true, true,false, true, true,false, true, true },
	{ false, true, true, true,false, true, true, true,false, true, true, true },
	{ false, true, true, true, true, true,false, true, true, true, true, true },
	{ false, true, true, true, true, true, true, true, true, true, true, true }
};

/////////////////////////////////////////////////////////////////////////////
// initialization and cleanup
/////////////////////////////////////////////////////////////////////////////

TimingHandler::TimingHandler()
{
	_timer = 0;
	_logicFrameSkip = 0;
	_videoFrameSkip = 0;
	_throttle = true;
}

TimingHandler::~TimingHandler()
{
}

/////////////////////////////////////////////////////////////////////////////
// initialization and cleanup
/////////////////////////////////////////////////////////////////////////////

bool TimingHandler::init(Timer *t, int fps, int logicFrameSkip, int videoFrameSkip)
{
	_timer = t;

	// try to init the timer
	if (!_timer->init()){
		return false;
	}

	_fps = fps;
	_logicFrameSkip = logicFrameSkip;
	_videoFrameSkip = videoFrameSkip;

	// init perfomance data
	_perfomance.lastFpsTime = _timer->getTime();
	_perfomance.framesSinceLastFPS = 0;
	_perfomance.currentFPS = 0.0;
	_perfomance.gameSpeedPercent = 0.0;

	// init throttling and frame skipping data
	_frameSkipCnt = 0;
	_timePerSleepMiliSec = (double)fps/1000.0;
	_timePerFrame = (double)_timer->getTicksPerSecond()/(double)fps;
	_lastSkip0Time = _timer->getTime() - (int)(FRAMESKIP_LEVELS*_timePerFrame);

	return true;
}

void TimingHandler::end()
{
	_timer->end();
}

/////////////////////////////////////////////////////////////////////////////
// skipping methods
/////////////////////////////////////////////////////////////////////////////

bool TimingHandler::skipThisLogicFrame()
{
	return TimingHandler::g_skipTable[_logicFrameSkip][_frameSkipCnt];
}

bool TimingHandler::skipThisVideoFrame()
{
	_lastVideoFrameSkipped = TimingHandler::g_skipTable[_videoFrameSkip][_frameSkipCnt];
	return _lastVideoFrameSkipped;
}

/////////////////////////////////////////////////////////////////////////////
// time related methods
/////////////////////////////////////////////////////////////////////////////

void TimingHandler::waitThisFrame()
{
	// if we're throttling, wait until target time
	if (_throttle){
		speedThrottle();
	}

	_frameSkipCnt = (_frameSkipCnt + 1) % FRAMESKIP_LEVELS;
}

void TimingHandler::endThisFrame()
{
	// check if we have to compute FPS
	computeFPS();
}

void TimingHandler::speedThrottle()
{
	// recalculate base values each FRAMESKIP_LEVELS frames
	if (_frameSkipCnt == 0){
		_thisFrameBase = _lastSkip0Time + (int)(FRAMESKIP_LEVELS*_timePerFrame);
	}

	INT64 targetTime = 	_thisFrameBase + (int)(_frameSkipCnt*_timePerFrame);
	INT64 currentTime = _timer->getTime();

	// check if we have to wait a bit
	if (currentTime - targetTime < 0){
		// if we need to wait and have time to sleep, do it
		while (currentTime - targetTime < 0){
			if ((targetTime - currentTime) > _timePerSleepMiliSec*1.20){
				_timer->sleep(1);
				INT64 nextTime = _timer->getTime();

				// evolutive adjust sleep time
				_timePerSleepMiliSec = _timePerSleepMiliSec*0.80 + ((double)(nextTime - currentTime))*0.20;
				currentTime = nextTime;
			} else {
				currentTime = _timer->getTime();
			}
		}
	}

	// recalculate base values each FRAMESKIP_LEVELS frames
	if (_frameSkipCnt == 0){
		if ((currentTime - targetTime) > _timePerSleepMiliSec){
			_lastSkip0Time = currentTime;
		} else {
			_lastSkip0Time = targetTime;
		}
	}
}

/////////////////////////////////////////////////////////////////////////////
// helper methods
/////////////////////////////////////////////////////////////////////////////

void TimingHandler::computeFPS()
{
	_perfomance.framesSinceLastFPS++;

	// if we didn't skip this video frame, adjust FPS if necessary
	if ((!_lastVideoFrameSkipped) && (_perfomance.framesSinceLastFPS >= FRAMES_PER_FPS_UPDATE*(_videoFrameSkip + 1))){
		INT64 currentTime = _timer->getTime();
        double secsElapsed = (double)(currentTime - _perfomance.lastFpsTime)*(1.0/_timer->getTicksPerSecond());

		// set perfomance data
		_perfomance.currentFPS = (double)_perfomance.framesSinceLastFPS/secsElapsed;
		_perfomance.gameSpeedPercent = 100.0*_perfomance.currentFPS/_fps;

		// reset perfomance helper values
		_perfomance.lastFpsTime = currentTime;
		_perfomance.framesSinceLastFPS = 0;
	}
}