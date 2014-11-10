// Paleta.cpp
/////////////////////////////////////////////////////////////////////////////

#include "../systems/CPC6128.h"
#include "../Vigasoco.h"

#include "Juego.h"
#include "Paleta.h"

using namespace Abadia;

/////////////////////////////////////////////////////////////////////////////
// paletas del juego
/////////////////////////////////////////////////////////////////////////////

int Paleta::introPalette[16] = { 07, 20, 11, 03, 06, 12, 04, 21, 13, 05, 14, 29, 00, 28, 31, 27 };

int Paleta::palettes[4][4] = {
	{ 20, 20, 20, 20 },		// paleta negra
	{ 07, 28, 20, 12 },		// paleta del pergamino
	{ 06, 14, 03, 20 },		// paleta de día durante el juego
	{ 04, 29, 00, 20 }		// paleta de noche durante el juego
};

/////////////////////////////////////////////////////////////////////////////
// inicialización y limpieza
/////////////////////////////////////////////////////////////////////////////

Paleta::Paleta()
{
	paleta = VigasocoMain->getPalette();
	cpc6128 = elJuego->cpc6128;
}

Paleta::~Paleta()
{
}

/////////////////////////////////////////////////////////////////////////////
// métodos
/////////////////////////////////////////////////////////////////////////////

// coloca la paleta de la introducción
void Paleta::setIntroPalette()
{
	for (int i = 0; i < 16; i++){
		cpc6128->setHardwareColor(paleta, i, introPalette[i]);
	}

	cpc6128->markAllPixelsDirty();
}


// coloca una paleta
void Paleta::setGamePalette(int pal)
{
	for (int i = 0; i < 4; i++){
		cpc6128->setHardwareColor(paleta, i, palettes[pal][i]);
	}

	cpc6128->markAllPixelsDirty();
}
