// Operations.cpp
//
/////////////////////////////////////////////////////////////////////////////

#include "Operations.h"

template <typename T, int bits>
T Operations::rotateLeft(T data)
{
	T msb = 1 << (bits - 1);
	return (data & msb) ? (data << 1) | 0x01 : (data << 1);
}

template <typename T, int bits>
T Operations::rotateRight(T data)
{
	T msb = 1 << (bits - 1);
	return (data & 0x01) ? (data >> 1) | msb : (data >> 1);
}

template <typename T>
T Operations::square(T data)
{
	return data*data;
}