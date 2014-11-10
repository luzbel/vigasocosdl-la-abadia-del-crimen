// WinMain.cpp
//
// VIGASOCO Project Win32 port (c) 2003 by MAB
//
//	See readme.txt for license and usage information.
//
/////////////////////////////////////////////////////////////////////////////

#include "VigasocoWin32.h"

typedef std::vector<std::string> Strings;

// default options
std::string g_game("abadia");
std::string g_drawPluginsDLL("mddraw.dll");
std::string g_drawPlugin("full16");

Strings g_inputPluginsDLLs;
Strings g_inputPlugins;
Strings g_paths;

// parser helper function
bool parseCommandLine(std::string cmdLine);

void showError(std::string error);
void showUsage(std::string error);

/////////////////////////////////////////////////////////////////////////////
//	WIN32 application entry point
/////////////////////////////////////////////////////////////////////////////

int APIENTRY WinMain(HINSTANCE hInstance, HINSTANCE, LPSTR szCmdLine, int iCmdShow)
{
	if (!parseCommandLine(szCmdLine)){
		showUsage("Unknown parameters! Read the documentation for detailed information about usage.");
		return -1;
	}

	VigasocoWin32 VIGASOCO(hInstance, g_game, g_drawPluginsDLL, g_drawPlugin,
							g_inputPluginsDLLs, g_inputPlugins,	g_paths);

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
		g_inputPluginsDLLs.push_back("DIKeyb.dll");
		g_inputPlugins.push_back("DIKeyb");
	}

	return true;
}

void showError(std::string error)
{
	if (error == ""){
		MessageBox(NULL, "Unexpected error loading VIGASOCO. "
						"Read the manual for usage information!",
						"Error!", MB_OK | MB_ICONINFORMATION);
	} else {
		MessageBox(NULL, error.c_str(), "Error!", MB_OK | MB_ICONINFORMATION);
	}
}

void showUsage(std::string error)
{
	MessageBox(NULL, (error +
		"\nUsage: vigasoco <game> "
		"-video:<pluginDLL>, <plugin> "
		"-input:{<pluginDLL>, <plugin>;}* <pluginDLL>, <plugin>"
		"-path:{<path>;}* <path>").c_str(), 
		"Error!", MB_OK | MB_ICONINFORMATION);
}
