// Win32Palette.cpp
//
/////////////////////////////////////////////////////////////////////////////

#include "Win32Palette.h"


/////////////////////////////////////////////////////////////////////////////
// initialization and cleanup
/////////////////////////////////////////////////////////////////////////////

Win32Palette::Win32Palette()
{
	_palette = 0;
	_colors = 0;
}

Win32Palette::~Win32Palette()
{
}

void Win32Palette::init(int colors)
{
	assert(_palette == 0);

	_palette = new PaletteEntry[colors];
	_colors = colors;
}

void Win32Palette::end()
{
	delete[] _palette;
}

/////////////////////////////////////////////////////////////////////////////
// getters & setters
/////////////////////////////////////////////////////////////////////////////

void Win32Palette::setColor(int index, UINT8 r, UINT8 g, UINT8 b)
{
	assert((index >= 0) && (index < _colors));

	_palette[index].R = r;
	_palette[index].G = g;
	_palette[index].B = b;
	_palette[index].alpha = 0xff;

	notify(index);
}

void Win32Palette::getColor(int index, UINT8 &r, UINT8 &g, UINT8 &b)
{
	assert((index >= 0) && (index < _colors));

	r = _palette[index].R;
	g = _palette[index].G;
	b = _palette[index].B;
}

void Win32Palette::setColor(int index, PaletteEntry pe)
{
	assert((index >= 0) && (index < _colors));

	_palette[index].R = pe.R;
	_palette[index].G = pe.G;
	_palette[index].B = pe.B;
	_palette[index].alpha = pe.alpha;

	notify(index);
}

PaletteEntry Win32Palette::getColor(int index) const
{
	assert((index >= 0) && (index < _colors));

	return _palette[index];
}
