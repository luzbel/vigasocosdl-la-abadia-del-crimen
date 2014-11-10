// DirectInputKeyboardPlugin.cpp
//
/////////////////////////////////////////////////////////////////////////////

#include <cassert>
#include "DirectInputKeyboardPlugin.h"
#include "Win32Settings.h"

UINT8 DirectInputKeyboardPlugin::g_keyMapping[END_OF_INPUTS];

/////////////////////////////////////////////////////////////////////////////
// initialization and cleanup
/////////////////////////////////////////////////////////////////////////////

DirectInputKeyboardPlugin::DirectInputKeyboardPlugin(Win32Settings *settings)
{
	_settings = settings;
	_pIDI = 0;
	_lpDIKeyboard = 0;
	_errorMsg = "";

	initRemapTable();
}

DirectInputKeyboardPlugin::~DirectInputKeyboardPlugin()
{
}

bool DirectInputKeyboardPlugin::init()
{
	// gest DirectInput interface
	if (FAILED(DirectInputCreate(_settings->getAppInstance(), DIRECTINPUT_VERSION, &_pIDI, 0))){
		_errorMsg = "DirectInputKeyboardPlugin ERROR: can't get IDirectInput interface";
		return false;
	}

	// get access to the keyboard
	if (FAILED(_pIDI->CreateDevice(GUID_SysKeyboard, &_lpDIKeyboard, 0))){
		_errorMsg = "DirectInputKeyboardPlugin ERROR: can't get keyboard device";
		return false;
	}

	// sets the cooperative level
	if (FAILED(_lpDIKeyboard->SetCooperativeLevel(_settings->getHWnd(), DISCL_NONEXCLUSIVE | DISCL_BACKGROUND))){
		_errorMsg = "DirectInputKeyboardPlugin ERROR: can't set cooperative level";
		return false;
	}

	// sets keyboard data format
	if (FAILED(_lpDIKeyboard->SetDataFormat(&c_dfDIKeyboard))){
		_errorMsg = "DirectInputKeyboardPlugin ERROR: can't set keyboard data format";
		return false;
	}

	// acquires the keyboard
	if (FAILED(_lpDIKeyboard->Acquire())){
		_errorMsg = "DirectInputKeyboardPlugin ERROR: can't acquire keyboard";
		return false;
	}

	return true;
}

void DirectInputKeyboardPlugin::end()
{
	if (_lpDIKeyboard){
		_lpDIKeyboard->Unacquire();
		_lpDIKeyboard->Release();
		_lpDIKeyboard = 0;
	}

	if (_pIDI){
		_pIDI->Release();
		_pIDI = 0;
	}
}


void DirectInputKeyboardPlugin::acquire()
{
	_lpDIKeyboard->Acquire();
}

void DirectInputKeyboardPlugin::unAcquire()
{
	_lpDIKeyboard->Unacquire();
}

/////////////////////////////////////////////////////////////////////////////
// input processing
/////////////////////////////////////////////////////////////////////////////

void DirectInputKeyboardPlugin::process(int *inputs)
{
	// read keyboard state
	if (_lpDIKeyboard->GetDeviceState(256, &_keys) != DI_OK){
		return;
	}

	// iterate through the inputs checking associated keys
	for (int i = 0; i < END_OF_INPUTS; i++){
		// if we're interested in that input, check it's value
		if (inputs[i] >= 0){
			// if the input is mapped and the key is pressed, update inputs
			if (g_keyMapping[i] != 0){
				if (_keys[g_keyMapping[i]] & 0x80){
					inputs[i]++;
				}
			}
		}
	}
}

/////////////////////////////////////////////////////////////////////////////
// helper methods
/////////////////////////////////////////////////////////////////////////////

void DirectInputKeyboardPlugin::initRemapTable()
{
	memset(g_keyMapping, 0, sizeof(g_keyMapping));

	// game driver inputs
	g_keyMapping[P1_UP] = DIK_UP;
	g_keyMapping[P1_LEFT] = DIK_LEFT;
	g_keyMapping[P1_DOWN] = DIK_DOWN;
	g_keyMapping[P1_RIGHT] = DIK_RIGHT;
	g_keyMapping[P1_BUTTON1] = DIK_LCONTROL;
	g_keyMapping[P1_BUTTON2] = DIK_LMENU;

	g_keyMapping[P2_UP] = DIK_W;
	g_keyMapping[P2_LEFT] = DIK_A;
	g_keyMapping[P2_DOWN] = DIK_S;
	g_keyMapping[P2_RIGHT] = DIK_D;
	g_keyMapping[P2_BUTTON1] = DIK_Y;
	g_keyMapping[P2_BUTTON2] = DIK_U;

	g_keyMapping[START_1] = DIK_1;
	g_keyMapping[START_2] = DIK_2;
	g_keyMapping[COIN_1] = DIK_5;
	g_keyMapping[COIN_2] = DIK_6;
	g_keyMapping[SERVICE_1] = DIK_9;
	g_keyMapping[SERVICE_2] = DIK_0;

	// keyboard inputs
	g_keyMapping[KEYBOARD_A] = DIK_A;
	g_keyMapping[KEYBOARD_B] = DIK_B;
	g_keyMapping[KEYBOARD_C] = DIK_C;
	g_keyMapping[KEYBOARD_D] = DIK_D;
	g_keyMapping[KEYBOARD_E] = DIK_E;
	g_keyMapping[KEYBOARD_F] = DIK_F;
	g_keyMapping[KEYBOARD_G] = DIK_G;
	g_keyMapping[KEYBOARD_H] = DIK_H;
	g_keyMapping[KEYBOARD_I] = DIK_I;
	g_keyMapping[KEYBOARD_J] = DIK_J;
	g_keyMapping[KEYBOARD_K] = DIK_K;
	g_keyMapping[KEYBOARD_L] = DIK_L;
	g_keyMapping[KEYBOARD_M] = DIK_M;
	g_keyMapping[KEYBOARD_N] = DIK_N;
	g_keyMapping[KEYBOARD_O] = DIK_O;
	g_keyMapping[KEYBOARD_P] = DIK_P;
	g_keyMapping[KEYBOARD_Q] = DIK_Q;
	g_keyMapping[KEYBOARD_R] = DIK_R;
	g_keyMapping[KEYBOARD_S] = DIK_S;
	g_keyMapping[KEYBOARD_T] = DIK_T;
	g_keyMapping[KEYBOARD_U] = DIK_U;
	g_keyMapping[KEYBOARD_V] = DIK_V;
	g_keyMapping[KEYBOARD_W] = DIK_W;
	g_keyMapping[KEYBOARD_X] = DIK_X;
	g_keyMapping[KEYBOARD_Y] = DIK_Y;
	g_keyMapping[KEYBOARD_Z] = DIK_Z;
	g_keyMapping[KEYBOARD_0] = DIK_0;
	g_keyMapping[KEYBOARD_1] = DIK_1;
	g_keyMapping[KEYBOARD_2] = DIK_2;
	g_keyMapping[KEYBOARD_3] = DIK_3;
	g_keyMapping[KEYBOARD_4] = DIK_4;
	g_keyMapping[KEYBOARD_5] = DIK_5;
	g_keyMapping[KEYBOARD_6] = DIK_6;
	g_keyMapping[KEYBOARD_7] = DIK_7;
	g_keyMapping[KEYBOARD_8] = DIK_8;
	g_keyMapping[KEYBOARD_9] = DIK_9;
	g_keyMapping[KEYBOARD_SPACE] = DIK_SPACE;
	g_keyMapping[KEYBOARD_INTRO] = DIK_NUMPADENTER;
	g_keyMapping[KEYBOARD_SUPR] = DIK_DELETE;

	// core inputs
	g_keyMapping[FUNCTION_1] = DIK_F1;
	g_keyMapping[FUNCTION_2] = DIK_F2;
	g_keyMapping[FUNCTION_3] = DIK_F3;
	g_keyMapping[FUNCTION_4] = DIK_F4;
	g_keyMapping[FUNCTION_5] = DIK_F5;
	g_keyMapping[FUNCTION_6] = DIK_F6;
	g_keyMapping[FUNCTION_7] = DIK_F7;
	g_keyMapping[FUNCTION_8] = DIK_F8;
	g_keyMapping[FUNCTION_9] = DIK_F9;
	g_keyMapping[FUNCTION_10] = DIK_F10;
	g_keyMapping[FUNCTION_11] = DIK_F11;
	g_keyMapping[FUNCTION_12] = DIK_F12;

	// check that all inputs have been mapped (for safety)
	for (int i = 0; i < END_OF_INPUTS; i++){
		assert(g_keyMapping[i] != 0);
	}
}

/////////////////////////////////////////////////////////////////////////////
// Custom plugin properties
/////////////////////////////////////////////////////////////////////////////

const std::string DirectInputKeyboardPlugin::g_properties[] = {
	"keyConfig"
};

const int DirectInputKeyboardPlugin::g_paramTypes[] = {
	PARAM_ARRAY | PARAM_INPUT
};

const int * DirectInputKeyboardPlugin::getPropertiesType() const
{
	return DirectInputKeyboardPlugin::g_paramTypes;
}

const std::string * DirectInputKeyboardPlugin::getProperties(int *num) const 
{
	*num = sizeof(g_paramTypes)/sizeof(g_paramTypes[0]);
	return DirectInputKeyboardPlugin::g_properties;
}

void DirectInputKeyboardPlugin::setProperty(std::string prop, int data)
{
}

void DirectInputKeyboardPlugin::setProperty(std::string prop, int index, int data)
{
	if (prop == "keyConfig"){
		if ((index >= 0) && (index < END_OF_INPUTS)){
			g_keyMapping[index] = data;
		}
	}
}

int DirectInputKeyboardPlugin::getProperty(std::string prop) const
{
	return -1;
};

int DirectInputKeyboardPlugin::getProperty(std::string prop, int index) const
{
	if (prop == "keyConfig"){
		if ((index >= 0) && (index < END_OF_INPUTS)){
			return g_keyMapping[index];
		}
	} 
	return -1; 
};
