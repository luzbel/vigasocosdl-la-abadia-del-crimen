// VigasocoLinuxSDL.h
//
/////////////////////////////////////////////////////////////////////////////

#ifndef _VIGASOCO_LINUXSDL_H_
#define _VIGASOCO_LINUXSDL_H_


#include "Vigasoco.h"
#include "PluginHandler.h"
#include "ILoader.h"
#include <string>
#include <vector>

class VigasocoLinuxSDL : public Vigasoco
{
// types
public:
	typedef std::vector<std::string> Strings;

// constants
protected:
	static int g_currentVideoPluginVersion;
	static int g_currentInputPluginVersion;
	static int g_currentLoaderPluginVersion;

	static std::string g_videoPluginPath;
	static std::string g_inputPluginPath;
	static std::string g_loaderPluginPath;

// types
protected:
	typedef std::vector<DLLEntry> DLLEntries;

// fields
protected:
	// port options
	std::string _sDrawPluginsDLL;
	std::string _sDrawPlugin;
	Strings _sInputPluginsDLLs;
	Strings _sInputPlugins;
	Strings _sPaths;

	// DLL stuff
	PluginHandler *_pluginHandler;
	DLLEntry _drawPluginInfo;
	DLLEntries _inputPluginsInfo;
	DLLEntries _loaderPluginsInfo;

// methods
public:
	// initialization and cleanup
	VigasocoLinuxSDL(std::string game, std::string drawPluginsDLL,
			std::string drawPlugin, Strings inputPluginsDLLs, 
			Strings inputPlugins, Strings paths);
	virtual ~VigasocoLinuxSDL();

	// platform services
	virtual ICriticalSection *createCriticalSection();

protected:
	// template methods overrides

	// construction
	virtual bool platformSpecificInit();
	virtual void createPalette();
	virtual void addCustomLoaders(FileLoader *fl);
	virtual void createDrawPlugin();
	virtual void addCustomInputPlugins();
	virtual void createTimer();
	virtual void createAsyncThread();
	virtual void initCompleted();

	// destruction
	virtual void destroyAsyncThread();
	virtual void destroyTimer();
	virtual void removeCustomInputPlugins();
	virtual void destroyDrawPlugin();
	virtual void removeCustomLoaders(FileLoader *fl);
	virtual void destroyPalette();
	virtual void platformSpecificEnd();

	virtual bool processEvents();

private:
};

#endif	// _VIGASOCO_LINUXSDL_H_
