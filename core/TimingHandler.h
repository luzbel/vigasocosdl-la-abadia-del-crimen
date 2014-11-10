// TimingHandler.h
//
//	Class that handles the speed of the current game (this is heavily based 
//	in M.A.M.E. frame skipping system).
//
/////////////////////////////////////////////////////////////////////////////

#ifndef _TIMING_HANDLER_H_
#define _TIMING_HANDLER_H_


#include "ITimer.h"
#include "Types.h"
#include "util/Singleton.h"


class TimingHandler : public Singleton<TimingHandler>
{
// constants
public:
	static const int INTERRUPTS_PER_BASE_TIME_UPDATE = 12;
	static const int FRAMESKIP_LEVELS = 12;
	static const int FRAMES_PER_FPS_UPDATE = 12;

// types
protected:
	struct Perfomance {
		INT64 lastFpsTime;
		int framesSinceLastFPS;
		double currentFPS;
	};

// fields
protected:
	static const bool g_skipTable[FRAMESKIP_LEVELS][FRAMESKIP_LEVELS];

protected:
	ITimer *_timer;						// timer used to track elapsed time

	int _numInterruptsPerSecond;		// numer of interrupts per second
	int _numInterruptsPerVideoUpdate;	// numer of interrupts per video update
	int _numInterruptsPerLogicUpdate;	// numer of interrupts per logic update

	int _interruptNum;					// number of interrupts elapsed since the game started
	
	bool _throttle;						// throttle speed

	INT64 _thisFrameBase;				// base time for the next interrupts
	INT64 _lastFrameBase;				// last time base for the last interrupts
	INT64 _ticksPerMiliSecond;			// number of ticks per millisecond
	double _timePerInterrupt;			// time elapsed between two consecutive interrupts
	double _ticksPerSleepMiliSec;		// average of time elapsed for the lasts sleep(1) calls
	double _ticksPerSleepMiliSec2;		// average of time elapsed for the lasts sleep(1) calls

	Perfomance _perfomance;				// perfomance information to calculate FPS

	int _frameSkipCnt;					// current frameskip count
	int _videoFrameSkip;				// number of video frames to skip
	bool _lastVideoFrameSkipped;		// true if we skipped the last video frame

	int _numIntsModLogicInts;
	int _numIntsModVideoInts;
	int _numIntsModeBaseTimeUpdateInts;

// methods
public:
	bool init(ITimer *t, int intsPerSecond, int intsPerVideoUpdate, int intsPerLogicUpdate);
	void end();

	bool processLogicThisInterrupt();
	bool processVideoThisInterrupt();
	bool skipVideoThisInterrupt();

	// getters & setters
	double getCurrenFPS() const { return _perfomance.currentFPS; }
	bool isThrottling() const { return _throttle; }
	int getVideoFrameSkip() const { return _videoFrameSkip; }
	void setSpeedThrottle(bool mode) { _throttle = mode; }
	void setVideoFrameSkip(int frameSkip) { _videoFrameSkip = frameSkip; }

	void waitThisInterrupt();
	void endThisInterrupt();

	// timer functions
	INT64 getTime(){ return _timer->getTime(); }
	INT64 getTicksPerSecond(){ return _timer->getTicksPerSecond(); }
	void sleep(UINT32 milliSeconds);

	// initialization and cleanup
	TimingHandler();
	~TimingHandler();

// helper methods
protected:
	void speedThrottle();
	void computeFPS();
};

#endif	// _TIMING_HANDLER_H_
