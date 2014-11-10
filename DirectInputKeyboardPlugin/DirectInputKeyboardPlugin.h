// DirectInputKeyboardPlugin.h
//
//	Class that handles keyboard input using DirectInput
//
/////////////////////////////////////////////////////////////////////////////

#ifndef _DIRECT_INPUT_KEYBOARD_PLUGIN_H_
#define _DIRECT_INPUT_KEYBOARD_PLUGIN_H_


#define DIRECTINPUT_VERSION 0x0500
#include <dinput.h>
#include "IInputPlugin.h"

class Win32Settings;	// defined in Win32Settings.h

class DirectInputKeyboardPlugin: public IInputPlugin
{
// fields
protected:
	static const std::string g_properties[];
	static const int g_paramTypes[];

	Win32Settings *_settings;					// important win32 vars
	LPDIRECTINPUT _pIDI;						// DirectInput interface
	LPDIRECTINPUTDEVICE _lpDIKeyboard;			// keyboard interface
	UINT8 _keys[256];							// keys state

	static UINT8 g_keyMapping[END_OF_INPUTS];	// VIGASOCO input to DirectInput mapping

	std::string _errorMsg;						// error message

// methods
public:
	// initialization and cleanup
	DirectInputKeyboardPlugin(Win32Settings *settings);
	virtual ~DirectInputKeyboardPlugin();
	virtual bool init();
	virtual void end();

	virtual void acquire();
	virtual void unAcquire();

	virtual void process(int *inputs);

	// custom properties
	virtual const std::string *getProperties(int *num) const;
	virtual const int *getPropertiesType() const;
	virtual void setProperty(std::string prop, int data);
	virtual void setProperty(std::string prop, int index, int data);
	virtual int getProperty(std::string prop) const;
	virtual int getProperty(std::string prop, int index) const;

protected:
	void initRemapTable();
};


#endif	// _DIRECT_INPUT_KEYBOARD_PLUGIN_H_