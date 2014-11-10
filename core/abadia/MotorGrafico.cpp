// MotorGrafico.cpp
//
/////////////////////////////////////////////////////////////////////////////

#include "../TimingHandler.h"

#include "EntidadJuego.h"
#include "GeneradorPantallas.h"
#include "Juego.h"
#include "Logica.h"
#include "MezcladorSprites.h"
#include "MotorGrafico.h"
#include "Objeto.h"
#include "Personaje.h"
#include "Puerta.h"
#include "RejillaPantalla.h"
#include "Sprite.h"
#include "TransformacionesCamara.h"

using namespace Abadia;

/////////////////////////////////////////////////////////////////////////////
// tabla con los desplazamientos según la orientación
/////////////////////////////////////////////////////////////////////////////

int MotorGrafico::tablaDespOri[4][2] = {
	{ +1,  0 },
	{  0, -1 },
	{ -1,  0 },
	{  0, +1 }
};

/////////////////////////////////////////////////////////////////////////////
// mapa de las plantas de la abadía
/////////////////////////////////////////////////////////////////////////////

UINT8 MotorGrafico::plantas[3][256] = {
	{
// planta baja
//
// X	00   01   02   03   04   05   06   07   08   09   0a   0b   0c   0d   0e  0f        Y
//		===============================================================================     ==
		0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   , // 00
		0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0x27,0   ,0x3e,0   ,0   ,0   ,0   ,0   , // 01
		0   ,0x0a,0x09,0   ,0x07,0x08,0x2a,0x28,0x26,0x29,0x37,0x38,0x39,0   ,0   ,0   , // 02
		0   ,0   ,0x02,0x01,0x00,0x0d,0x0e,0x24,0x23,0x25,0x2b,0x2c,0x2d,0   ,0   ,0   , // 03
		0   ,0   ,0x03,0   ,0x1f,0   ,0   ,0   ,0x22,0   ,0x2e,0x2f,0x30,0   ,0   ,0   , // 04
		0   ,0   ,0x04,0x1d,0x1e,0x3e,0x3d,0   ,0x21,0   ,0x31,0x32,0x33,0   ,0   ,0   , // 05
		0   ,0x0c,0x0b,0x1c,0x05,0x06,0x3c,0   ,0x20,0   ,0x34,0x35,0x36,0   ,0   ,0   , // 06
		0   ,0   ,0   ,0x0f,0x10,0x11,0x12,0   ,0x1b,0   ,0x1a,0x3a,0x3b,0   ,0   ,0   , // 07
		0   ,0   ,0   ,0   ,0   ,0   ,0x13,0x14,0x15,0x18,0x19,0   ,0   ,0   ,0   ,0   , // 08
		0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0x16,0   ,0   ,0   ,0   ,0   ,0   ,0   , // 09
		0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0x17,0   ,0   ,0   ,0   ,0   ,0   ,0   , // 0a
		0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   , // 0b
		0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   , // 0c
		0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   , // 0d
		0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   , // 0e
		0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0     // 0f
	},
	{
// primera planta
//
// X	00   01   02   03   04   05   06   07   08   09   0a   0b   0c   0d   0e  0f        Y
//		===============================================================================     ==
		0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   , // 00
		0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   , // 01
		0   ,0x45,0x44,0   ,0x48,0x49,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   , // 02
		0   ,0   ,0x43,0x47,0x4a,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   , // 03
		0   ,0   ,0x42,0   ,0x4b,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   , // 04
		0   ,0   ,0x41,0x40,0x4c,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   , // 05
		0   ,0x3f,0x46,0   ,0x4d,0x4e,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   , // 06
		0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   , // 07
		0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   , // 08
		0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   , // 09
		0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   , // 0a
		0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   , // 0b
		0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   , // 0c
		0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   , // 0d
		0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   , // 0e
		0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0     // 0f
	},
	{
// segunda planta
//
// X	00   01   02   03   04   05   06   07   08   09   0a   0b   0c   0d   0e  0f        Y
//		===============================================================================     ==
		0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   , // 00
		0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   , // 01
		0   ,0x67,0x66,0   ,0x65,0x64,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   , // 02
		0   ,0   ,0x6a,0x69,0x68,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   , // 03
		0   ,0   ,0x6c,0   ,0x6b,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   , // 04
		0   ,0   ,0x6f,0x6e,0x6d,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   , // 05
		0   ,0x73,0x72,0   ,0x71,0x70,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   , // 06
		0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   , // 07
		0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   , // 08
		0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   , // 09
		0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   , // 0a
		0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   , // 0b
		0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   , // 0c
		0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   , // 0d
		0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   , // 0e
		0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0     // 0f
	}
};

/////////////////////////////////////////////////////////////////////////////
// inicialización y limpieza
/////////////////////////////////////////////////////////////////////////////

MotorGrafico::MotorGrafico(UINT8 *buffer, int lgtudBuffer)
{
	roms = elJuego->roms;

	posXPantalla = posYPantalla = 0;
	alturaBasePantalla = 0;
	hayQueRedibujar = true;
	pantallaIluminada = true;

	personaje = 0;

	genPant = new GeneradorPantallas();
	rejilla = new RejillaPantalla(this);
	mezclador = new MezcladorSprites(genPant, buffer, lgtudBuffer);

	// crea las transformaciones dependientes de la cámara
	transCamara[0] = new Camara0();
	transCamara[1] = new Camara1();
	transCamara[2] = new Camara2();
	transCamara[3] = new Camara3();
}

MotorGrafico::~MotorGrafico()
{
	// borra las transformaciones depentdientes de la cámara
	for (int i = 0; i < 4; i++){
		delete transCamara[i];
	}

	delete mezclador;
	mezclador = 0;

	delete rejilla;
	rejilla = 0;

	delete genPant;
	genPant = 0;
}

/////////////////////////////////////////////////////////////////////////////
// comprobación del cambio de pantalla y actualización de entidades del juego
/////////////////////////////////////////////////////////////////////////////

// comprueba si el personaje al que sigue la cámara ha cambiado de pantalla y si es así, actualiza las variables del motor
// obtiene los datos de altura de la nueva pantalla y ajusta las posiciones de las entidades del juego
// según la orientación con la que se ve la pantalla actual
void MotorGrafico::compruebaCambioPantalla()
{
	// inicialmente no hay cambio de pantalla
	bool cambioPantalla = false;

	// si el personaje al que sigue la cámara cambia de pantalla en x
	if ((personaje->posX & 0xf0) != posXPantalla){
		cambioPantalla = true;

		// actualiza la posición x del motor
		posXPantalla = personaje->posX & 0xf0;
	}

	// si el personaje al que sigue la cámara cambia de pantalla en y
	if ((personaje->posY & 0xf0) != posYPantalla){
		cambioPantalla = true;

		// actualiza la posición y del motor
		posYPantalla = personaje->posY & 0xf0;
	}

	// si el personaje ha cambiado de planta
	if (obtenerAlturaBasePlanta(personaje->altura) != alturaBasePantalla){
		cambioPantalla = true;

		// actualiza la altura del motor
		alturaBasePantalla = obtenerAlturaBasePlanta(personaje->altura);
	}

	// si no se ha cambiado la pantalla que se muestra, sale
	if (!cambioPantalla) return;

	hayQueRedibujar = true;
	pantallaIluminada = true;

	// si está en la segunda planta, comprueba si es una de las pantallas iluminadas
	if (obtenerPlanta(alturaBasePantalla) == 2){
		// si no está detrás del espejo o en la habitación iluminada del laberinto
		if (posXPantalla >= 0x20){
			if (posXPantalla != 0x20){
				pantallaIluminada = false;
			} else {
				// si está en la pantalla del espejo
				pantallaIluminada = posYPantalla == 0x60;
			}
		}
	}

	// marca el sprite de la luz como no visible
	elJuego->sprites[Juego::spriteLuz]->esVisible = false;

	// obtiene el número de pantalla que se va a mostrar
	numPantalla = plantas[obtenerPlanta(alturaBasePantalla)][posYPantalla | ((posXPantalla  >> 4) & 0x0f)];

	// rellena el buffer de alturas con los datos de altura de la pantalla actual
	rejilla->rellenaAlturasPantalla(personaje);

	// calcula la orientación de la cámara para la pantalla que se va a mostrar
	oriCamara = (((posXPantalla >> 4)& 0x01) << 1) | (((posXPantalla  >> 4) & 0x01)^((posYPantalla  >> 4) & 0x01));

	// recorre las puertas, y para las visibles, actualiza su posición y marca la altura que ocupan
	actualizaPuertas();

	// recorre los objetos, y para los visibles, actualiza su posición
	actualizaObjetos();

	// recorre los personajes, y para los visibles, actualiza su posición y animación y marca la altura que ocupan
	actualizaPersonajes();
}

/////////////////////////////////////////////////////////////////////////////
// actualización de las entidades del juego según la cámara
/////////////////////////////////////////////////////////////////////////////

void MotorGrafico::actualizaPuertas()
{
	// recorre las puertas, y para las visibles, actualiza su posición y marca la altura que ocupan
	for (int i = 0; i < Juego::numPuertas; i++){
		int posXPant, posYPant, sprPosY;

		Puerta *puerta = elJuego->puertas[i];

		// actualiza la posición del sprite según la cámara
		if (actualizaCoordCamara(puerta, posXPant, posYPant, sprPosY) != -1){
			puerta->notificaVisibleEnPantalla(posXPant, posYPant, sprPosY);
		} else {
			puerta->sprite->esVisible = false;
		}

		puerta->sprite->oldPosXPant = puerta->sprite->posXPant;
		puerta->sprite->oldPosYPant = puerta->sprite->posYPant;
	}
}

void MotorGrafico::actualizaObjetos()
{
	// recorre los objetos, y para los visibles, actualiza su posición
	for (int i = 0; i < Juego::numObjetos; i++){
		int posXPant, posYPant, sprPosY;

		Objeto *objeto = elJuego->objetos[i];

		// actualiza la posición del sprite según la cámara
		if (actualizaCoordCamara(objeto, posXPant, posYPant, sprPosY) != -1){
			objeto->notificaVisibleEnPantalla(posXPant, posYPant, sprPosY);
		} else {
			objeto->sprite->esVisible = false;
		}

		objeto->sprite->oldPosXPant = objeto->sprite->posXPant;
		objeto->sprite->oldPosYPant = objeto->sprite->posYPant;
	}
}

void MotorGrafico::actualizaPersonajes()
{
	// recorre los personajes, y para los visibles, actualiza su posición y animación y marca la altura que ocupan
	for (int i = 0; i < Juego::numPersonajes; i++){
		int posXPant, posYPant, sprPosY;

		Personaje *pers = elJuego->personajes[i];

		// actualiza la posición del sprite según la cámara
		if (actualizaCoordCamara(pers, posXPant, posYPant, sprPosY) != -1){
			pers->notificaVisibleEnPantalla(posXPant, posYPant, sprPosY);
		} else {
			pers->sprite->esVisible = false;
		}

		// si el personaje está en las posiciones centrales de la pantalla actual, marca las posiciones que ocupa
		pers->marcaPosicion(rejilla, pers->valorPosicion);
	}
}

/////////////////////////////////////////////////////////////////////////////
// dibujo de la escena
/////////////////////////////////////////////////////////////////////////////

void MotorGrafico::dibujaSprites()
{
	// si la habitación no está iluminada, evita dibujar los sprites visibles
	if (!pantallaIluminada){
		for (int i = 0; i < Juego::numSprites; i++){
			if (elJuego->sprites[i]->esVisible){
				elJuego->sprites[i]->haCambiado = false;
			}
		}
		
		// si adso es visible en la pantalla actual y tiene la lámpara, activa el sprite de la luz
		if ((elJuego->personajes[1]->sprite->esVisible) && ((elJuego->personajes[1]->objetos & LAMPARA) != 0)){
			elJuego->sprites[Juego::spriteLuz]->esVisible = true;
			elJuego->sprites[Juego::spriteLuz]->haCambiado = true;

			// fija una profundidad muy alta para que sea el último sprite que se dibuje
			elJuego->sprites[Juego::spriteLuz]->profundidad = 0x3c;
		}
	}

	// dibuja los sprites visibles que han cambiado
	mezclador->mezclaSprites(elJuego->sprites, Juego::numSprites);
}

void MotorGrafico::dibujaPantalla()
{
	if (hayQueRedibujar){
		// elige un color de fondo según el tipo de pantalla
		int colorFondo = (pantallaIluminada) ? 0 : 3;

		// prepara el buffer de tiles y limpia la pantalla
		genPant->limpiaPantalla(colorFondo);

		// obtiene el desplazamiento de los datos a los bloques que forman la pantalla actual
		UINT8 *data = &roms[obtenerDirPantalla(numPantalla) + 1];

		// rellena el buffer de tiles interpretando los bloques que forman la pantalla
		genPant->genera(data);

		// si es una pantalla iluminada, dibuja el contenido del buffer de tiles
		if (pantallaIluminada){
			genPant->dibujaBufferTiles();
		}

		hayQueRedibujar = false;
	}
}

/////////////////////////////////////////////////////////////////////////////
// métodos relacionados con la transformación de cámara
/////////////////////////////////////////////////////////////////////////////

// actualiza el sprite con las nuevas coordenadas de cámara correspondiente a las coordenadas de mundo actuales
// y si es sprite es visible, devuelve en posXPant y posYPant las coordenadas de pantalla del sprite
int MotorGrafico::actualizaCoordCamara(EntidadJuego *entidad, int &posXPant, int &posYPant, int &sprPosY)
{
	// transforma las coordenadas de mundo en coordenadas locales
	int posXLocal = entidad->posX - (posXPantalla - 12);
	int posYLocal = entidad->posY - (posYPantalla - 12);
	int alturaLocal = entidad->altura - alturaBasePantalla;

	// si la entidad no está en la zona visible, devuelve false
	if ((posXLocal < 0) || (posXLocal >= 40)) return -1;
	if ((posYLocal < 0) || (posYLocal >= 40)) return -1;
	if (obtenerAlturaBasePlanta(entidad->altura) != alturaBasePantalla) return -1;
	
	// transforma las coordenadas locales a coordenadas de cámara
	transCoordLocalesACoordCamara(posXLocal, posYLocal);
	
	entidad->sprite->posXLocal = posXLocal;
	entidad->sprite->posYLocal = posYLocal;

	// convierte las coordenadas de cámara en coordenadas de pantalla
	posYPant = posXLocal + posYLocal - alturaLocal;

	if (posYPant < 0) return -1;
	posYPant = posYPant - 6;

	if ((posYPant < 8) || (posYPant >= 58)) return -1;

	posYPant = 4*(posYPant + 1);
	posXPant = 2*(posXLocal - posYLocal) + 80 - 40;
	if ((posXPant < 0) || (posXPant >= 80)) return -1;

	// calcula la profundidad usada para ordenar el dibujado de sprites
	sprPosY = posXLocal + posYLocal - 16;
	
	if (sprPosY < 0){
		sprPosY = 0;
	}

	return sprPosY;
}

// transforma las coordenadas locales según la orientación de la cámara
void MotorGrafico::transCoordLocalesACoordCamara(int &x, int &y)
{
	transCamara[oriCamara]->transforma(x, y);
}

// ajusta la orientación que se le pasa según la orientación de la cámara
int MotorGrafico::ajustaOrientacionSegunCamara(int orientacion)
{
	return (orientacion - oriCamara) & 0x03;
}

/////////////////////////////////////////////////////////////////////////////
// métodos relacionados con al altura
/////////////////////////////////////////////////////////////////////////////

// devuelve la altura base de la planta a la que corresponde la altura que se le pasa
int MotorGrafico::obtenerAlturaBasePlanta(int altura)
{
	if (altura < 0x0d) return 0x00;			// planta baja (0x00-0x0c)
	if (altura >= 0x18) return 0x16;		// segunda baja (0x18-0xff)
	return 0x0b;							// primera planta (0x0d-0x17)
}

// devuelve la planta a la que corresponde la altura base que se le pasa
int MotorGrafico::obtenerPlanta(int alturaBase)
{
	if (alturaBase == 0x00) return 0;		// planta baja
	if (alturaBase == 0x0b) return 1;		// primera planta
	if (alturaBase == 0x16) return 2;		// segunda planta

	assert(false);

	return 0;
}

/////////////////////////////////////////////////////////////////////////////
// métodos de ayuda
/////////////////////////////////////////////////////////////////////////////

// dada una pantalla, obtiene la dirección donde empieza
int MotorGrafico::obtenerDirPantalla(int numPant)
{
	int desp = 0x1c000;

	// recorre las pantallas hasta llegar a la que buscamos
	for (int i = 0; i < numPant; i++){
		desp += roms[desp];
	}

	return desp;
}
