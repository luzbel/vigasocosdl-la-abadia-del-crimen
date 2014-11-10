// NotificationProvider.h
//
//	Class that provides the functionality to add and remove observers, and
//	to notify observers of subject's changes (Observer pattern)
//
//	How to use it: class MySubject: public NotificationProvider<MySubject>
//
/////////////////////////////////////////////////////////////////////////////

#ifndef _NOTIFICATION_PROVIDER_H_
#define _NOTIFICATION_PROVIDER_H_

#include "INotificationSuscriber.h"
#include <list>


template <typename T>
class NotificationProvider
{
// types
protected:
	typedef std::list<INotificationSuscriber<T> *> Observers;

// fields
protected:
	Observers _observers;

// methods
public:
	NotificationProvider();
	virtual ~NotificationProvider();
	virtual void attach(INotificationSuscriber<T> *o);
	virtual void detach(INotificationSuscriber<T> *o);
	virtual void notify(int data);
};

#include "NotificationProvider.cpp"

#endif	// _NOTIFICATION_PROVIDER_H_
