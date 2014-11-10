// SpriteLuz.cpp
//
/////////////////////////////////////////////////////////////////////////////

#include "Juego.h"
#include "Personaje.h"
#include "SpriteLuz.h"
#include "../systems/CPC6128.h"

using namespace Abadia;

/////////////////////////////////////////////////////////////////////////////
// tabla con el patrón de relleno de la luz
/////////////////////////////////////////////////////////////////////////////

int SpriteLuz::rellenoLuz[16] = {
	0x00e0,
	0x03f8,
	0x07fc,
	0x07fc,
	0x0ffe,
	0x0ffe,
	0x1fff,
	0x1fff,
	0x1fff,
	0x1fff,
	0x0ffe,
	0x0ffe,
	0x07fc,
	0x07fc,
	0x03f8,
	0x00e0
};

/////////////////////////////////////////////////////////////////////////////
// inicialización y limpieza
/////////////////////////////////////////////////////////////////////////////

SpriteLuz::SpriteLuz()
{
	ancho = oldAncho = 80/4;
	alto = oldAlto = 80;

	posXLocal = posYLocal = 0xfe;

	flipX = false;
	rellenoAbajo = 0;
	rellenoArriba = 0;
	rellenoDerecha = 0;
	rellenoIzquierda = 0;
}

SpriteLuz::~SpriteLuz()
{
}

/////////////////////////////////////////////////////////////////////////////
// colocación de la luz
/////////////////////////////////////////////////////////////////////////////

// ajusta el sprite de la luz a la posición del personaje que se le pasa
void SpriteLuz::ajustaAPersonaje(Personaje *pers)
{
	// asigna una profundidad en pantalla muy alta al sprite de la luz
	posXLocal = 0xfe;
	posYLocal = 0xfe;

	// calcula los rellenos del sprite de la luz según la posición del personaje
	rellenoIzquierda = (pers->sprite->posXPant & 0x03)*4;
	rellenoDerecha = (4 - (pers->sprite->posXPant & 0x03))*4;
	rellenoArriba = ((pers->sprite->posYPant & 0x07) >= 4) ? 0xf0*4 : 0xa0*4;
	rellenoAbajo = ((pers->sprite->posYPant & 0x07) >= 4) ? 0xa0*4 : 0xf0*4;

	// coloca la posición de la luz basada en la posición del personaje (ajustando la posición al inicio de un tile)
	posXPant = (pers->sprite->posXPant & 0xfc) - 8;
	if (posXPant < 0) posXPant = 0;
	posYPant = (pers->sprite->posYPant & 0xf8) - 24;
	if (posYPant < 0) posYPant = 0;

	oldPosXPant = posXPant;
	oldPosYPant = posYPant;

	// obtiene si el personaje está girado
	flipX = pers->flipX;
}

/////////////////////////////////////////////////////////////////////////////
// dibujado de sprites
/////////////////////////////////////////////////////////////////////////////

// dibuja la parte visible del sprite actual en el área ocupada por el sprite que se le pasa como parámetro
void SpriteLuz::dibuja(Sprite *spr, UINT8 *bufferMezclas, int lgtudClipX, int lgtudClipY, int dist1X, int dist2X, int dist1Y, int dist2Y)
{
	// rellena de negro la parte superior del sprite
	for (int i = 0; i < rellenoArriba; i++){
		*bufferMezclas = 3;
		bufferMezclas++;
	}

	// para 15 bloques
	for (int j = 0; j < 15; j++){
		// guarda la posición inicial de este bloque
		UINT8 *posBuffer = bufferMezclas;

		// obtiene el patrón para rellenar este bloque
		int patron = rellenoLuz[j];

		// rellena 4 líneas de alto en la parte de la izquierda
		for (int i = 0; i < rellenoIzquierda; i++){
			bufferMezclas[0] = 3;
			bufferMezclas[20*4] = 3;
			bufferMezclas[40*4] = 3;
			bufferMezclas[60*4] = 3;

			bufferMezclas++;
		}

		// modifica levemente el patrón dependiendo de a donde mira el personaje
		if (flipX){
			patron = patron << 1;
		}

		// completa el sprite de la luz según el patrón de relleno
		for (int i = 0; i < 16; i++){
			// si el bit actual es 0, rellena de negro un bloque de 4x4
			if ((patron & 0x8000) == 0){
				for (int k = 0; k < 4; k++){
					bufferMezclas[0] = 3;
					bufferMezclas[20*4] = 3;
					bufferMezclas[40*4] = 3;
					bufferMezclas[60*4] = 3;

					bufferMezclas++;
				}
			} else {
				bufferMezclas += 4;
			}

			patron = patron << 1;
		}

		// rellena 4 líneas de alto en la parte de la derecha
		for (int i = 0; i < rellenoDerecha; i++){
			bufferMezclas[0] = 3;
			bufferMezclas[20*4] = 3;
			bufferMezclas[40*4] = 3;
			bufferMezclas[60*4] = 3;

			bufferMezclas++;
		}

		// avanza la posición hasta la del siguiente bloque
		bufferMezclas = posBuffer + 80*4;
	}

	// rellena de negro la parte inferior del sprite
	for (int i = 0; i < rellenoAbajo; i++){
		*bufferMezclas = 3;
		bufferMezclas++;
	}
}
