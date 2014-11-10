// TimingHandler.h
//
//	Class that handles the speed of the current game (this is heavily based 
//	in M.A.M.E. frame skipping system).
//
/////////////////////////////////////////////////////////////////////////////

#ifndef _TIMING_HANDLER_H_
#define _TIMING_HANDLER_H_


#include "Types.h"
#include "util/Singleton.h"

class Timer;	// defined in Timer.h

class TimingHandler : public Singleton<TimingHandler>
{
// constants
public:
	static const int FRAMESKIP_LEVELS = 12;
	static const int FRAMES_PER_FPS_UPDATE = 12*5;

// types
protected:
	struct Perfomance {
		INT64 lastFpsTime;
		int framesSinceLastFPS;
		double currentFPS;
		double gameSpeedPercent;
	};

// fields
protected:
	static const bool g_skipTable[FRAMESKIP_LEVELS][FRAMESKIP_LEVELS];

public:
	int _fps;				// wanted frames per second
	Timer *_timer;			// timer used to track ellapsed time
	bool _throttle;			// speed throttling to _fps frames per second

	// throttling and frame skipping
	int _videoFrameSkip;
	int _logicFrameSkip;
	int _frameSkipCnt;
	INT64 _thisFrameBase;
	INT64 _lastSkip0Time;
	double _timePerFrame;
	double _timePerSleepMiliSec;

	// perfomance information
	Perfomance _perfomance;
	bool _lastVideoFrameSkipped;

// methods
public:
	bool init(Timer *t, int fps, int logicFrameSkip, int videoFrameSkip);
	void end();

	bool skipThisLogicFrame();
	bool skipThisVideoFrame();

	// getters & setters
	double getCurrenFPS() const { return _perfomance.currentFPS; }
	double getGameSpeedPercent() const { return _perfomance.gameSpeedPercent; }
	bool isThrottling() const { return _throttle; }
	int getLogicFrameSkip() const { return _logicFrameSkip; }
	int getVideoFrameSkip() const { return _videoFrameSkip; }
	void setSpeedThrottle(bool mode) { _throttle = mode; }
	void setLogicFrameSkip(int frameSkip) { _logicFrameSkip = frameSkip; }
	void setVideoFrameSkip(int frameSkip) { _videoFrameSkip = frameSkip; }

	void waitThisFrame();
	void endThisFrame();

	// initialization and cleanup
	TimingHandler();
	~TimingHandler();

// helper methods
protected:
	void speedThrottle();
	void computeFPS();
};

#endif	// _TIMING_HANDLER_H_
