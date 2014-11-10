// ZipLoader.cpp
//
/////////////////////////////////////////////////////////////////////////////

#include "ZipLoader.h"

/////////////////////////////////////////////////////////////////////////////
// initialization and cleanup
/////////////////////////////////////////////////////////////////////////////

ZipLoader::ZipLoader()
{
	_path = "";
	_exception = false;
}

ZipLoader::~ZipLoader()
{
}

/////////////////////////////////////////////////////////////////////////////
// data loading
/////////////////////////////////////////////////////////////////////////////

void ZipLoader::open(std::string path, std::string name)
{
	_exception = false;
	_path = path + "/" + name + ".zip";

	// try to open the zip file
	try {
		_zip.Open(_path.c_str(), CZipArchive::zipOpenReadOnly);
	} catch(...){
		_exception = true;
	}
}

UINT8 *ZipLoader::load(std::string fileName, UINT32 fileSize, UINT32 CRC32)
{
	if (_exception){
		return 0;
	}

	UINT8 *ptr = 0;

	try {
		int index = -1;

		// iterate through the zipped files searching the wanted one by CRC32
		for (int i = 0; i < _zip.GetCount(); i++){
			CZipFileHeader header;

			// get file information
			_zip.GetFileInfo(header, i);

			if (header.m_uCrc32 == CRC32){
				index = i;
				break;
			}
		}

		// not found, exit
		if (index == -1){
			return 0;
		}

		// if we found it, try to extract it to memory
		CZipMemFile mf;
		_zip.ExtractFile(index, mf);

		// if the size doesn't match, error
		if (fileSize != mf.GetLength()){
			return 0;
		}

		// otherwise get data
		ptr = mf.Detach();
	} catch(...){
		_exception = true;
	}

	return ptr;
}

void ZipLoader::dispose(UINT8 *ptr)
{
	free(ptr);
}

void ZipLoader::close()
{
	_zip.Close(_exception ? CZipArchive::afAfterException : CZipArchive::afNoException);
	_path = "";
}
