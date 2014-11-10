// ZipLoader.h
//
//	Plugin to load zipped files
//
//	Using ZipArchive library (c) 2000-2004 Tadeusz Dracz
//	(http://www.artpol-software.com)
//
//	To compile you need to include ZipArchive directory and add the reference
//	ZipArchive_STL.lib to the linker (be sure that the options used to build
//	the ZipArchive library (multithreaded run-time library)	match with the 
//	project settings
/////////////////////////////////////////////////////////////////////////////

#ifndef _ZIP_LOADER_H_
#define _ZIP_LOADER_H_

#pragma warning (disable : 4267)

#include "ILoader.h"
#include "ziparchive.h"

class ZipLoader : public ILoader
{
// fields
protected:
	std::string _path;
	bool _exception;
	CZipArchive _zip;

// methods
public:
	ZipLoader();
	virtual ~ZipLoader();

	// loader interface
	virtual void open(std::string path, std::string name);
	virtual UINT8 *load(std::string fileName, UINT32 fileSize, UINT32 CRC32);
	virtual void dispose(UINT8 *ptr);
	virtual void close();
};

#endif	// _ZIP_LOADER_H_

