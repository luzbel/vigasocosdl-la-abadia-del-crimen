// RDTSCTimer.h
//
//	High resolution timer using RDTSC
//
/////////////////////////////////////////////////////////////////////////////

#ifndef _RDTSC_TIMER_H_
#define _RDTSC_TIMER_H_


#include "ITimer.h"

class RDTSCTimer : public ITimer
{
// fields
protected:
	INT64 _ticksPerSecond;
	INT64 _ticksPerMilliSecond;

// methods
public:
	virtual bool init();
	virtual void end();

	virtual INT64 getTime();
	virtual INT64 getTicksPerSecond();
	virtual void sleep(UINT32 milliseconds);

	// initialization and cleanup
	RDTSCTimer();
	virtual ~RDTSCTimer();

// helper methods
protected:
	INT64 calcTicksPerSecond();
	bool supportsRDTSC();
};

#endif	// _RDTSC_TIMER_H_
