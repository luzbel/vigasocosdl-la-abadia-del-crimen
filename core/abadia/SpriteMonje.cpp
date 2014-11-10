// SpriteMonje.cpp
//
/////////////////////////////////////////////////////////////////////////////

#include "Juego.h"
#include "SpriteMonje.h"
#include "../systems/CPC6128.h"

using namespace Abadia;

/////////////////////////////////////////////////////////////////////////////
// tabla de desplazamientos a los datos gráficos de los trajes de los monjes
/////////////////////////////////////////////////////////////////////////////

int SpriteMonje::despAnimTraje[16] = {
	0x0ab59 + 0x0082,  
	0x0ab59 + 0x0000,
	0x0ab59 + 0x0082,
	0x0ab59 + 0x00fa,
	0x0ab59 + 0x0262,
	0x0ab59 + 0x0172,
	0x0ab59 + 0x0262,
	0x0ab59 + 0x01ef,
	0x16b59 + 0x0262,
	0x16b59 + 0x0172,
	0x16b59 + 0x0262,
	0x16b59 + 0x01ef,
	0x16b59 + 0x0082,
	0x16b59 + 0x0000,
	0x16b59 + 0x0082,
	0x16b59 + 0x00fa
};

/////////////////////////////////////////////////////////////////////////////
// inicialización y limpieza
/////////////////////////////////////////////////////////////////////////////

SpriteMonje::SpriteMonje()
{
	animacionTraje = 0;
}

SpriteMonje::~SpriteMonje()
{
}


/////////////////////////////////////////////////////////////////////////////
// dibujado de sprites
/////////////////////////////////////////////////////////////////////////////

// dibuja la parte visible del sprite actual en el área ocupada por el sprite que se le pasa como parámetro
void SpriteMonje::dibuja(Sprite *spr, UINT8 *bufferMezclas, int lgtudClipX, int lgtudClipY, int dist1X, int dist2X, int dist1Y, int dist2Y)
{
	// obtiene los objetos que se usan luego
	UINT8 *roms = elJuego->roms;
	CPC6128 *cpc6128 = elJuego->cpc6128;

	int despSrc;

	// si ya ha pasado la zona de la cabeza, obtiene los gráficos de la parte del traje
	if (dist2Y >= 10){
		despSrc = despAnimTraje[animacionTraje] + (dist2Y - 10)*ancho + dist2X;
	} else {
		despSrc = despGfx + dist2Y*ancho + dist2X;
	}

	// calcula la dirección de destino de los gráficos en el buffer de sprites
	int despDest = spr->despBuffer + (dist1Y*spr->anchoFinal + dist1X)*4;

	// recorre los pixels visibles en Y
	for (int lgtudY = 0; lgtudY < lgtudClipY; lgtudY++){
		UINT8 *src = &roms[despSrc];
		UINT8 *dest = &bufferMezclas[despDest];

		// recorre los pixels visibles en X
		for (int lgtudX = 0; lgtudX < lgtudClipX; lgtudX++){
			// lee un byte del gráfico (4 pixels)
			int data = *src;

			// para cada pixel del byte leido
			for (int k = 0; k < 4; k++){
				// obtiene el color del pixel
				int color = cpc6128->unpackPixelMode1(data, k);

				// si no es un pixel transparente lo copia al destino
				if (color != 0){
					*dest = color;
				}
				dest++;
			}
			src++;
		}

		despSrc += ancho;
		despDest += spr->anchoFinal*4;

		dist2Y++;

		// si ya se ha dibujado la cabeza, obtiene los gráficos de la parte del traje
		if (dist2Y == 10){
			despSrc = despAnimTraje[animacionTraje] + dist2X;
		}
	}
}
