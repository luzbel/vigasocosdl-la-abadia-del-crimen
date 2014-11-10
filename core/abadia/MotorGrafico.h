// MotorGrafico.h
//
//	Clase que contiene los métodos de generación de pantallas
//
/////////////////////////////////////////////////////////////////////////////

#ifndef _MOTOR_GRAFICO_H_
#define _MOTOR_GRAFICO_H_


#include "../util/Singleton.h"
#include "../Types.h"

namespace Abadia {

class EntidadJuego;					// definido en EntidadJuego.h
class GeneradorPantallas;			// definido en GeneradorPantallas.h
class MezcladorSprites;				// definido en MezcladorSprites.h
class Personaje;					// definido en Personaje.h
class RejillaPantalla;				// definido en RejillaPantalla.h
class TransformacionCamara;			// definido en TransformacionesCamara.h

#define elMotorGrafico MotorGrafico::getSingletonPtr()

class MotorGrafico : public Singleton<MotorGrafico>
{
// campos
public:
	RejillaPantalla *rejilla;		// objeto para realizar operaciones relacionadas con la rejilla de pantalla
	GeneradorPantallas *genPant;	// generador de pantallas interpretando los bloques de construcción
	MezcladorSprites *mezclador;	// mezclador de los sprites con el resto de la pantalla

	int posXPantalla;				// posición x de la pantalla actual en coordenadas de mundo
	int posYPantalla;				// posición y de la pantalla actual en coordenadas de mundo
	int alturaBasePantalla;			// altura base de la planta que se muestra en la pantalla actual
	bool pantallaIluminada;			// indica si la pantalla está iluminada o no
	bool hayQueRedibujar;			// indica que hay que redibujar la pantalla
	int numPantalla;				// número de la pantalla que muestra la cámara
	int oriCamara;					// orientación de la cámara para ver la pantalla actual

	Personaje *personaje;			// personaje al que sigue la cámara

	static int tablaDespOri[4][2];	// tabla con los desplazamientos según la orientación
	static UINT8 plantas[3][256];	// mapa de las plantas de la abadía

protected:
	UINT8 *roms;					// puntero a los datos del juego

	// objetos para la transformación de coordenadas según el tipo de cámara de la pantalla
	TransformacionCamara *transCamara[4];

// métodos
public:
	// comprobación del cambio de pantalla
	void compruebaCambioPantalla();

	// métodos relacionados con la altura
	int obtenerPlanta(int alturaBase);
	int obtenerAlturaBasePlanta(int altura);

	// transformaciones relacionadas con la cámara
	int ajustaOrientacionSegunCamara(int orientacion);
	void transCoordLocalesACoordCamara(int &x, int &y);
	int actualizaCoordCamara(EntidadJuego *entidad, int &posXPant, int &posYPant, int &sprPosY);

	// dibujo de la escena
	void dibujaPantalla();
	void dibujaSprites();

	// inicialización y limpieza
	MotorGrafico(UINT8 *buffer, int lgtudBuffer);
	~MotorGrafico();

// métodos de ayuda
protected:
	int obtenerDirPantalla(int numPant);

	// actualización de las entidades del juego según la cámara
	void actualizaPuertas();
	void actualizaObjetos();
	void actualizaPersonajes();
};


}

#endif	// _MOTOR_GRAFICO_H_
