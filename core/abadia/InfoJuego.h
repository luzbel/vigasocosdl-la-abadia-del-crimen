// InfoJuego.h
//
//	Clase que muestra información interna del juego
//
//	Cuando se llama al método muestraInfo() se sobreescribe parte de la pantalla con mapas
//	del juego. En la esquina superior derecha se muestra el mapa de alturas para la 
//	pantalla que sigue la cámara. A la derecha del mapa de alturas se muestra el mapa de 
//	alturas completo de la planta en la que está el personaje al que sigue la cámara.
//	Debajo del mapa de alturas de la pantalla actual se muestran los mapas de las plantas
//	en las que no se encuentra el personaje.
//
//	Como actualmente VIGASOCO no soporte múltiples bitmpaps desde distintos threads, no
//	hay más remedio que dibujar encima del bitmap principal, por lo que aunque se desactive
//	parte de la información que se muestra, la zona de juego estará sucia hasta que no se
//	redibuje, y la parte que no cae en la zona de juego no se limpiará. Cuando VIGASOCO
//	soporte múltiples bitmaps en distintos threads esto se corregirá.
//
/////////////////////////////////////////////////////////////////////////////

#ifndef _INFO_JUEGO_H_
#define _INFO_JUEGO_H_

#include <sstream>
#include <string>
#include "../Types.h"

class CPC6128;							// definido en CPC6128.h

namespace Abadia {

class EntidadJuego;						// definido en EntidadJuego.h
class Objeto;							// definido en Objeto.h
class Personaje;						// definido en Personaje.h
class Puerta;							// definido en Puerta.h
class Sprite;							// definido en Sprite.h

class InfoJuego
{
// campos
protected:
	int numPersonaje;					// indica que personaje se está mostrando actualmente
	int numObjeto;						// indica que objeto se está mostrando actualmente
	int numPuerta;						// indica que puerta se está mostrando actualmente
	bool mostrarLogica;					// indica si se muestran los datos relacionados con la lógica
	bool mostrarRejilla;				// indica si se muestra la rejilla de pantalla
	bool mostrarMapaPlantaActual;		// indica si se muestra el mapa de la planta actual
	bool mostrarMapaRestoPlantas;		// indica si se muestra el mapa de las plantas en las que no estamos

	CPC6128	*cpc6128;					// objeto de ayuda para realizar operaciones gráficas del cpc6128
	UINT8 *alturasPlanta[3];			// array de punteros a los buffers donde se almacenan las alturas de cada planta

	// tablas
	static int alturaBasePlanta[3];		// altura base de cada planta
	static int zonaVisiblePlanta[3][4];	// zonas visibles para cada planta

// métodos
public:
	void inicia();
	void muestraInfo();

	// inicialización y limpieza
	InfoJuego();
	virtual ~InfoJuego();

// métodos de ayuda
protected:
	// dibujo de la rejilla
	void dibujaRejilla();
	void dibujaPosicionRejilla(int x, int y, int valor);

	// dibujo de los mapas
	void generaAlturasPlanta();
	void dibujaAlturaPlanta(int numPlanta);
	void dibujaAlturaPosicionPlanta(int posX, int posY, int x, int y, int zoom, UINT8 *alturas);
	void dibujaMapa(int posX, int numPlanta);

	// dibujo de la posición de los personajes
	void muestraPosicionMapaAlturas(int numPlanta);
	void muestraPosicionMapa(int posX, int numPlanta);

	// mostrar información sobre la lógica y las entidades del juego
	void muestraInfoLogica(int x, int y);
	void muestraInfoPersonaje(int i, int x, int y);
	void muestraInfoPuerta(int i, int x, int y);
	void muestraInfoObjeto(int i, int x, int y);

	// dibujo de pixels
	void dibujaPixelCuadrado(int x, int y, int color);
	void dibujaPixelCuadradoZoom(int posX, int posY, int i, int j, int zoom, int color);

	// conversión de tipos a cadenas
	std::string muestraEntidad(EntidadJuego *entidad);
	std::string muestraPersonaje(int i, Personaje *pers);
	std::string muestraPuerta(Puerta *puerta);
	std::string muestraObjeto(Objeto *obj);
	std::string muestraSprite(Sprite *spr);

	// conversión de valores a cadenas
	std::string muestra(int valor);
	std::string muestra(bool valor);
};


}

#endif	// _INFO_JUEGO_H_
