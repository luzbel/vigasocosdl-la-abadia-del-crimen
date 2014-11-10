// NotificationProvider.cpp
//
/////////////////////////////////////////////////////////////////////////////

#include <cassert>

/////////////////////////////////////////////////////////////////////////////
// initialization and cleanup
/////////////////////////////////////////////////////////////////////////////

template <typename T> NotificationProvider<T>::NotificationProvider()
{
}

template <typename T> NotificationProvider<T>::~NotificationProvider()
{
	assert(_observers.size() == 0);
}

/////////////////////////////////////////////////////////////////////////////
// notification
/////////////////////////////////////////////////////////////////////////////

template <typename T> void NotificationProvider<T>::attach(INotificationSuscriber<T> *o)
{
	_observers.push_back(o);
}

template <typename T> void NotificationProvider<T>::detach(INotificationSuscriber<T> *o)
{
	_observers.remove(o);
}

template <typename T> void NotificationProvider<T>::notify(int data)
{
	Observers::iterator i; // Esto da error con el gcc 4.0 de la Fedora Core 4 Test 2 y si va con la siguiente declaracion
	//std::_List_iterator<INotificationSuscriber<T>*> i;

	// notify all observers of the change
	for (i = _observers.begin(); i != _observers.end(); i++){
		(*i)->update((T *)(this), data);
	}
}
