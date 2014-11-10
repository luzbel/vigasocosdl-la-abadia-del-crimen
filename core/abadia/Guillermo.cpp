// Guillermo.cpp
//
/////////////////////////////////////////////////////////////////////////////

#include "Controles.h"
#include "Guillermo.h"
#include "Juego.h"
#include "Logica.h"
#include "MotorGrafico.h"
#include "RejillaPantalla.h"
#include "Sprite.h"

using namespace Abadia;

/////////////////////////////////////////////////////////////////////////////
// tabla de la animación del personaje
/////////////////////////////////////////////////////////////////////////////

Personaje::DatosFotograma Guillermo::tablaAnimacion[8] = {
	{ 0xa3b4, 0x05, 0x22 },
	{ 0xa300, 0x05, 0x24 },
	{ 0xa3b4, 0x05, 0x22 },
	{ 0xa45e, 0x05, 0x22 },
	{ 0xa666, 0x04, 0x21 },
	{ 0xa508, 0x05, 0x23 },
	{ 0xa666, 0x04, 0x21 },
	{ 0xa5b7, 0x05, 0x21 }
};

/////////////////////////////////////////////////////////////////////////////
// inicialización y limpieza
/////////////////////////////////////////////////////////////////////////////

Guillermo::Guillermo(Sprite *spr) : Personaje(spr)
{
	// asigna la tabla de animación del personaje
	animacion = tablaAnimacion;
	numFotogramas = 8;

	incrPosY = 2;
}

Guillermo::~Guillermo()
{
}

/////////////////////////////////////////////////////////////////////////////
// movimiento
/////////////////////////////////////////////////////////////////////////////

// método llamado desde el bucle principal para que el personaje interactue con el mundo virtual
void Guillermo::run()
{
	mueve();
}

// mueve el personaje según el estado en el que se encuentra
void Guillermo::ejecutaMovimiento()
{
	// si está vivo, responde a la pulsación de los cursores
	if (estado == 0){
		// si la cámara no sigue a guillermo, sale
		if (laLogica->numPersonajeCamara != 0) return;

		// dependiendo de la tecla que se pulse, actúa en consecuencia
		if (losControles->estaSiendoPulsado(P1_LEFT)){
			gira(1);
		} else if (losControles->estaSiendoPulsado(P1_RIGHT)){
			gira(-1);
		} else if (losControles->estaSiendoPulsado(P1_UP)){
			int difAltura1, difAltura2, avanceX, avanceY;

			// obtiene la altura de las posiciones hacia las que se va a mover
			elMotorGrafico->rejilla->obtenerAlturaPosicionesAvance(this, difAltura1, difAltura2, avanceX, avanceY);
			trataDeAvanzar(difAltura1, difAltura2, avanceX, avanceY);
		}
	} else {
		// si ha llegado al último estado cuando está muerto, sale
		if (estado == 1) return;

		estado = estado - 1;

		// si ha caido en la trampa del espejo, lo mete en el agujero
		if (estado == 0x13){
			if (incrPosY == 2){
				posX = posX - 1;
				actualizaSprite();
				return;
			}
		}

        if (estado != 1){
			// modifica la posición y del sprite en pantalla
			sprite->posYPant += incrPosY;
			sprite->haCambiado = true;

			laLogica->hayMovimiento = true;
		} else {
			// en el estado 1 desaparece el sprite de guillermo
			sprite->esVisible = false;
		}
	}
}
