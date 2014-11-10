// Operations.h
//
//	Common used operations
//
/////////////////////////////////////////////////////////////////////////////

#ifndef _OPERATIONS_H_
#define _OPERATIONS_H_


#include "Types.h"

class Operations
{
// methods
public:
	// bit rotate
	template <typename T, int bits> static T rotateLeft(T data);
	template <typename T, int bits> static T rotateRight(T data);

	// square
	template <typename T> static T square(T data);
};

#include "Operations.cpp"

#endif	// _OPERATIONS_H_
