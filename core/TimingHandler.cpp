// TimingHandler.cpp
//
/////////////////////////////////////////////////////////////////////////////

#include "TimingHandler.h"


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

	_numInterruptsPerSecond = 0;
	_numInterruptsPerVideoUpdate = 0;
	_numInterruptsPerLogicUpdate = 0;
	_throttle = true;
	_interruptNum = 0;
	_videoFrameSkip = 0;

	_numIntsModLogicInts = 0;
	_numIntsModVideoInts = 0;
	_numIntsModeBaseTimeUpdateInts = 0;

}

TimingHandler::~TimingHandler()
{
}

/////////////////////////////////////////////////////////////////////////////
// initialization and cleanup
/////////////////////////////////////////////////////////////////////////////

bool TimingHandler::init(ITimer *t, int intsPerSecond, int intsPerVideoUpdate, int intsPerLogicUpdate)
{
	_timer = t;

	// try to init the timer
	if (!_timer->init()){
		return false;
	}

	_numInterruptsPerSecond = intsPerSecond;
	_numInterruptsPerVideoUpdate = intsPerVideoUpdate;
	_numInterruptsPerLogicUpdate = intsPerLogicUpdate;

	// init throttling and frame skipping data
	_interruptNum = 0;
	_frameSkipCnt = 0;
	_videoFrameSkip = 0;

	// compute sleep time for 1 milisecond
	INT64 startTime = _timer->getTime();
	_timer->sleep(1);
	INT64 endTime = _timer->getTime();

	_ticksPerSleepMiliSec = (double)(endTime - startTime);
	_ticksPerSleepMiliSec2 = (double)(endTime - startTime);

	_ticksPerMiliSecond = _timer->getTicksPerSecond()/1000;
	_timePerInterrupt = (double)_timer->getTicksPerSecond()/(double)intsPerSecond;

	// init perfomance data
	_perfomance.framesSinceLastFPS = 0;
	_perfomance.currentFPS = 0.0;
	_perfomance.lastFpsTime = _timer->getTime();

	_lastFrameBase = _timer->getTime() - (int)(INTERRUPTS_PER_BASE_TIME_UPDATE*_numInterruptsPerVideoUpdate*_timePerInterrupt);

	return true;
}

void TimingHandler::end()
{
	_timer->end();
}

/////////////////////////////////////////////////////////////////////////////
// skipping methods
/////////////////////////////////////////////////////////////////////////////

bool TimingHandler::processLogicThisInterrupt()
{
	return _numIntsModLogicInts == 0;
}

bool TimingHandler::processVideoThisInterrupt()
{
	return _numIntsModVideoInts == 0;
}

bool TimingHandler::skipVideoThisInterrupt()
{
	_lastVideoFrameSkipped = g_skipTable[_videoFrameSkip][_frameSkipCnt];
	return _lastVideoFrameSkipped;
}

/////////////////////////////////////////////////////////////////////////////
// time related methods
/////////////////////////////////////////////////////////////////////////////

void TimingHandler::waitThisInterrupt()
{
	_numIntsModLogicInts = _interruptNum % _numInterruptsPerLogicUpdate;
	_numIntsModVideoInts = _interruptNum % _numInterruptsPerVideoUpdate;

	// if we're throttling, wait until target time
	if (_throttle){
		_numIntsModeBaseTimeUpdateInts = _interruptNum % (INTERRUPTS_PER_BASE_TIME_UPDATE*_numInterruptsPerVideoUpdate);
		speedThrottle();
	}

	// if we have to update video in this interrupt, update frameskip count and check if we have to compute FPS
	if (_numIntsModVideoInts == 0){
		computeFPS();
		_frameSkipCnt = (_frameSkipCnt + 1) % FRAMESKIP_LEVELS;
	}
}

void TimingHandler::endThisInterrupt()
{
	_interruptNum++;
}

void TimingHandler::speedThrottle()
{
	// recalculate base values each INTERRUPTS_PER_BASE_TIME_UPDATE*_numInterruptsPerVideoUpdate frames
	if (_numIntsModeBaseTimeUpdateInts == 0){
		_thisFrameBase = _lastFrameBase + (int)(INTERRUPTS_PER_BASE_TIME_UPDATE*_numInterruptsPerVideoUpdate*_timePerInterrupt);
	}

	INT64 targetTime = 	_thisFrameBase + (int)(_numIntsModeBaseTimeUpdateInts*_timePerInterrupt);
	INT64 currentTime = _timer->getTime();

	// check if we have to wait a bit
	if (currentTime - targetTime < 0){
		// if we need to wait and have time to sleep, do it
		while (currentTime - targetTime < 0){
			if ((targetTime - currentTime) > _ticksPerSleepMiliSec*1.20){
				_timer->sleep(1);
				INT64 nextTime = _timer->getTime();

				// evolutive adjust sleep time
				_ticksPerSleepMiliSec = _ticksPerSleepMiliSec*0.90 + ((double)(nextTime - currentTime))*0.10;
				currentTime = nextTime;
			} else {
				currentTime = _timer->getTime();
			}
		}
	}

	// recalculate base values each INTERRUPTS_PER_BASE_TIME_UPDATE*_numInterruptsPerVideoUpdate frames
	if (_numIntsModeBaseTimeUpdateInts == 0){
		if ((currentTime - targetTime) > _ticksPerSleepMiliSec){
			_lastFrameBase = currentTime;
		} else {
			_lastFrameBase = targetTime;
		}
	}
}

// sleeps for some time taking in account the actual frameskip
void TimingHandler::sleep(UINT32 milliSeconds)
{
	// if we aren't throttling, return immediately
	if (!_throttle){
		return;
	}

	// adjust milliseconds based on the frame skip level
	milliSeconds = (UINT32)(milliSeconds*(((double)(FRAMESKIP_LEVELS - _videoFrameSkip))/FRAMESKIP_LEVELS));

	INT64 currentTime = _timer->getTime();
	INT64 targetTime = 	currentTime + _ticksPerMiliSecond*(INT64)milliSeconds;

	// check if we have to wait a bit
	if (currentTime - targetTime < 0){
		// if we need to wait and have time to sleep, do it
		while (currentTime - targetTime < 0){
			if ((targetTime - currentTime) > _ticksPerSleepMiliSec2*1.10){
				_timer->sleep(1);
				INT64 nextTime = _timer->getTime();

				// evolutive adjust sleep time
				_ticksPerSleepMiliSec2 = _ticksPerSleepMiliSec2*0.85 + ((double)(nextTime - currentTime))*0.15;
				currentTime = nextTime;
			} else {
				currentTime = _timer->getTime();
			}
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

		// reset perfomance helper values
		_perfomance.lastFpsTime = currentTime;
		_perfomance.framesSinceLastFPS = 0;
	}
}