// IThread.h
//
//	Abstract class that defines the interface of a thread
//
/////////////////////////////////////////////////////////////////////////////

#ifndef _ITHREAD_H_
#define _ITHREAD_H_


class IThread
{
protected:
	bool _isRunning;

public:
	virtual ~IThread();

	// abstract methods
	virtual bool start() = 0;
	virtual int run();
	virtual void end() = 0;

	virtual void pause() = 0;
	virtual void resume() = 0;

	// getters
	bool isRunning(){ return _isRunning; }

protected:
	IThread();
};

#endif	// _ITHREAD_H_
