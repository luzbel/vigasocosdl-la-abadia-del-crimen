// LinuxSDLMain.cpp
//
// Based on VIGASOCO Project Win32 port (c) 2003 by MAB
//	LinuxSDL port @2005 by Luzbel
//
//	See readme.txt for license and usage information.
//
/////////////////////////////////////////////////////////////////////////////

#include "VigasocoLinuxSDL.h"
// Para los mensajes de error
#include "iostream"

//666 temporal para SDL_Quit
#include "SDL.h"

typedef std::vector<std::string> Strings;

// default options
std::string g_game("abadia");
std::string g_drawPluginsDLL("libVigasocoLinuxSDLDrawPlugin.so");
std::string g_drawPlugin("win32");
//std::string g_drawPlugin("win8");

Strings g_inputPluginsDLLs;
Strings g_inputPlugins;
Strings g_paths;

// parser helper function
bool parseCommandLine(std::string cmdLine);

void showError(std::string error);
void showUsage(std::string error);

/////////////////////////////////////////////////////////////////////////////
//	LinuxSDL application entry point
/////////////////////////////////////////////////////////////////////////////

int main(int argc,char **argv)
{
	std::string szCmdLine;
	for ( int icont=1;icont<argc;icont++)
	{
		szCmdLine+=argv[icont];
		szCmdLine+=" ";	
	}

	if (!parseCommandLine(szCmdLine)){
		showUsage("Unknown parameters! Read the documentation for detailed information about usage.");
		return -1;
	}

std::cout << g_game << std::endl;
	VigasocoLinuxSDL VIGASOCO( g_game, g_drawPluginsDLL, g_drawPlugin,
				g_inputPluginsDLLs, g_inputPlugins, g_paths);

	// init the game
	if (!VIGASOCO.init(g_game)){
		VIGASOCO.end();

		// if there was an error, show it and exit
		showError(VIGASOCO.getError());

		return -1;
	}

	// run until the user has closed the window
	VIGASOCO.mainLoop();

	// cleanup
	VIGASOCO.end();

// 666 temporal
// quizas deberia ir en VigasocoLinuxSDL.end() 
// o con atexit() ...
SDL_Quit();
	return 0;
}


/////////////////////////////////////////////////////////////////////////////
//	Parser helper functions
/////////////////////////////////////////////////////////////////////////////

void split(std::string source, char splitChar, Strings *strings)
{
	std::string::size_type index, prevIndex = 0;
	
	do {
		// find next occurrence of the splitChar
		index = source.find(splitChar, prevIndex);

		// get substring from previous occurrence to this occurrence
		std::string substr = (source.substr(prevIndex, index - prevIndex));

		// if it's not the empty substring, save it
		if (substr.size() != 0){
			strings->push_back(substr);
		}

		prevIndex = index + 1;
	} while (index != std::string::npos);
}

bool parseVideo(Strings &params)
{
	for (std::string::size_type i = 1; i < params.size(); i++){
		Strings subParams;

		// split parameter in DLL and plugin
		split(params[i], ',', &subParams);

		if (subParams.size() != 2){
			return false;
		}

		// save DLL and plugin
		g_drawPluginsDLL = subParams[0];
		g_drawPlugin = subParams[1];
	}

	return true;
}

bool parseInputs(Strings &params)
{
	for (std::string::size_type i = 1; i < params.size(); i++){
		Strings subParams;

		// split parameter in DLL and plugin groups
		split(params[i], ';', &subParams);

		for (std::string::size_type j = 0; j < subParams.size(); j++){
			Strings pluginInfo;

			// split parameter in DLL and plugin
			split(subParams[j], ',', &pluginInfo);

			if (pluginInfo.size() != 2){
				return false;
			}

			// save DLL and plugin
			g_inputPluginsDLLs.push_back(pluginInfo[0]);
			g_inputPlugins.push_back(pluginInfo[1]);
		}
	}

	return true;
}

bool parsePaths(Strings &params)
{
	if (params.size() != 2){
		return false;
	}

	// split multiple paths
	split(params[1], ';', &g_paths);

	return true;
}

bool parseCommands(Strings &params)
{
	for (std::string::size_type i = 1; i < params.size(); i++){
		Strings subParams;

		// split parameter in command and arguments
		split(params[i], ':', &subParams);

		// process known commands
		if (subParams[0] == "-video"){
			if (!parseVideo(subParams))	return false;
		} else if (subParams[0] == "-input"){
			if (!parseInputs(subParams))	return false;
		} else if (subParams[0] == "-path"){
			if (!parsePaths(subParams))	return false;
		} else {	// error
			return false;
		}
	}

	return true;
}

bool parseCommandLine(std::string cmdLine)
{
	Strings params;

	// split user parameters
	split(cmdLine, ' ', &params);

	// parse user parameters
	if (params.size() > 0){
		g_game = params[0];

		if (params.size() > 1){
			if (!parseCommands(params)){
				return false;
			}
		}
	}

	// if the user hasn't set any input plugin, set the default one
	if (g_inputPluginsDLLs.size() == 0){
		g_inputPluginsDLLs.push_back("libVigasocoLinuxSDLInputPlugin.so");
		g_inputPlugins.push_back("LinuxSDLInputPlugin");
	}

	return true;
}

void showError(std::string error)
{
	if (error == ""){
		std::cerr << 
		"Unexpected error loading VIGASOCO. "
		"Read the manual for usage information!" << std::endl <<
		"Error!" << std::endl;
	} else {
		std::cerr << error.c_str() << std::endl << "Error!" << std::endl;
	} 
}

void showUsage(std::string error)
{
	std::cerr << (error +
		"\nUsage: vigasoco <game> "
		"-video:<pluginDLL>, <plugin> "
		"-input:{<pluginDLL>, <plugin>;}* <pluginDLL>, <plugin>"
		"-path:{<path>;}* <path>"
		) << std::endl << "Error!" << std::endl;
}
