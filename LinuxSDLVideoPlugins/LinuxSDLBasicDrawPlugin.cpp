// LinuxSDLBasicDrawPlugin.cpp
//
/////////////////////////////////////////////////////////////////////////////

#include "LinuxSDLBasicDrawPlugin.h"
#include "IPalette.h"

void LinuxSDLBasicDrawPlugin::end()  { _isInitialized = false; };

// getters
bool LinuxSDLBasicDrawPlugin::isInitialized() const  { return _isInitialized; };
