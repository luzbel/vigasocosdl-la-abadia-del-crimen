// Sprite.h
//
//	Clase que representa un sprite genérico
//
/////////////////////////////////////////////////////////////////////////////

#ifndef _SPRITE_H_
#define _SPRITE_H_


#include "../Types.h"

namespace Abadia {


class Sprite
{
// campos
public:
	bool esVisible;			// indica si el sprite es visible
	bool haCambiado;		// indica si el sprite ha cambiado desde que se dibujó por última vez
	bool seHaProcesado;		// indica si el sprite ha sido procesado por el mezclador
	int profundidad;		// profundidad del sprite (coordenada y de pantalla)

	int posXPant;			// coordenada x del sprite en la pantalla (en múltiplos de 4 pixels)
	int posYPant;			// coordenada y del sprite en la pantalla (en pixels)
	int oldPosXPant;		// anterior coordenada x del sprite en la pantalla (en múltiplos de 4 pixels)
	int oldPosYPant;		// anterior coordenada y del sprite en la pantalla (en pixels)

	bool desaparece;		// indica si el sprite va a desaparecer de la pantalla
	int ancho;				// ancho del sprite (en múltiplos de 4 pixels)
	int alto;				// alto del sprite (en pixels)
	int despGfx;			// desplazamiento a los gráficos que forman el sprite
	int oldAncho;			// anterior ancho del sprite (en bytes)
	int oldAlto;			// anterior alto del sprite (en pixels)

	int posXTile;			// coordenada x del tile en el que se empieza a dibujar el sprite (en múltiplos de 4 pixels)
	int posYTile;			// coordenada y del tile en el que se empieza a dibujar el sprite (en pixels)
	int anchoFinal;			// ancho final del área a dibujar del sprite (en bytes)
	int altoFinal;			// alto final del área a dibujar del sprite (en pixels)
	int despBuffer;			// desplazamiento en el buffer para mezclar los sprites
	int posXLocal;			// coordenada x en la coordenadas locales de la cámara
	int posYLocal;			// coordenada y en la coordenadas locales de la cámara

// métodos
public:
	// ajuste de las dimensiones para el dibujado
	void ajustaATiles();
	void ampliaDimViejo();

	void preparaParaCambio();

	// dibujo del sprite
	virtual void dibuja(Sprite *spr, UINT8 *bufferMezclas, int lgtudClipX, int lgtudClipY, int dist1X, int dist2X, int dist1Y, int dist2Y);

	// inicialización y limpieza
	Sprite();
	virtual ~Sprite();
};


}

#endif	// _SPRITE_H_
