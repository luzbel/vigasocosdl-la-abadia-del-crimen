// Personaje.h
//
//	Clase que representa un personaje del juego
//
/////////////////////////////////////////////////////////////////////////////

#ifndef _PERSONAJE_H_
#define _PERSONAJE_H_


#include "../Types.h"

#include "EntidadJuego.h"


namespace Abadia {

class RejillaPantalla;			// definido en RejillaPantalla.h

class Personaje : public EntidadJuego
{
// tipos
protected:
	struct DatosFotograma {
		int dirGfx;				// dirección de los gráficos de este fotograma de la animación
		int ancho;				// ancho de este fotograma de la animación (en múltiplos de 4 pixels)
		int alto;				// alto de este fotograma de la animación (en pixels)
	};

// campos
public:
	int estado;					// estado del personaje
	int contadorAnimacion;		// contador para animar el personaje
	bool bajando;				// indica si el personaje está bajando en altura
	bool enDesnivel;			// indica que el personaje está en un desnivel
	bool giradoEnDesnivel;		// indica que el personaje no está avanzando en el sentido del desnivel
	bool flipX;					// indica si los gráficos están girados en x
	int despFlipX;				// desplazamiento de los gráficos girados en x
	int despX;					// desplazamiento en x para dibujar el personaje (en múltiplos de 4 pixels)
	int despY;					// desplazamiento en y para dibujar el personaje (en pixels)
	int valorPosicion;			// valor a grabar en las posiciones de la rejilla en las que está el personaje

	bool puedeQuitarObjetos;	// indica si el personaje puede quitar objetos o a otro personaje
	int objetos;				// objetos que tiene el personaje
	int mascaraObjetos;			// máscara de los objetos que puede coger el personaje
	int contadorObjetos;		// contador para no coger/dejar los objetos varias veces

	int permisosPuertas;		// puertas que puede abrir el personaje

	DatosFotograma *animacion;	// tabla con los datos para las animaciones
	int numFotogramas;			// número de fotogramas de la tabla de animaciones

protected:
	// tabla para el cálculo del desplazamiento, según la animación y la cámara de un personaje
	static int difPosAnimCam[4][4][14];

// métodos
public:
	virtual void run() = 0;

	virtual void notificaVisibleEnPantalla(int posXPant, int posYPant, int profundidad);

	int puedeDejarObjeto(int &posXObj, int &posYObj, int &alturaObj);

	void marcaPosicion(RejillaPantalla *rejilla, int valor);
	void actualizaSprite();

	// inicialización y limpieza
	Personaje(Sprite *spr);
	virtual ~Personaje();

protected:
	virtual void ejecutaMovimiento() = 0;
	virtual void avanzaAnimacionOMueve();

	void mueve();

	void trataDeAvanzar(int difAltura1, int difAltura2, int avanceX, int avanceY);
	void incrementaPos(int avanceX, int avanceY);
	void gira(int difOrientacion);
	bool cambioCentro();

	void actualizaPosPantSprite(int posXPant, int posYPant, int profundidad);
	void avanzaAnimacion();
	virtual DatosFotograma *calculaFotograma();
	void actualizaAnimacion(DatosFotograma *da, int profundidad);
};


}

#endif	// _PERSONAJE_H_
