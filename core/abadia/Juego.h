// Juego.h
//
//		Clase principal del juego. Almacena el estado y las entidades del juego.
//
/////////////////////////////////////////////////////////////////////////////

#ifndef _ABADIA_JUEGO_H_
#define _ABADIA_JUEGO_H_


#include "../util/Singleton.h"
#include "../Types.h"

class CPC6128;					// definido en CPC6128.h
class TimingHandler;			// definido en TimingHandler.h

namespace Abadia {

class Controles;				// definido en Controles.h
class InfoJuego;				// definido en InfoJuego.h
class Logica;					// definido en Logica.h
class Marcador;					// definido en Marcador.h
class MotorGrafico;				// definido en MotorGrafico.h
class Objeto;					// definido en Objeto.h
class Paleta;					// definido en Paleta.h
class Pergamino;				// definido en Pergamino.h
class Personaje;				// definido en Personaje.h
class Puerta;					// definido en Puerta.h
class Sprite;					// definido en Sprite.h

#define elJuego Juego::getSingletonPtr()

class Juego : public Singleton<Juego>
{
// constantes
public:
	static const int numPersonajes = 8;
	static const int numPuertas = 7;
	static const int numObjetos = 8;

	static const int primerSpritePersonajes = 0;
	static const int primerSpritePuertas = primerSpritePersonajes + numPersonajes;
	static const int primerSpriteObjetos = primerSpritePuertas + numPuertas;
	static const int spritesReflejos = primerSpriteObjetos + numObjetos;
	static const int spriteLuz = spritesReflejos + 2;
	static const int numSprites = spriteLuz + 1;

// campos
public:
	CPC6128 *cpc6128;						// objeto de ayuda para realizar operaciones gráficas del cpc6128
	Controles *controles;					// acceso a los controles del juego
	Paleta *paleta;							// paleta del juego
	TimingHandler *timer;					// manejador del temporizador
	UINT8 buffer[8192];						// buffer para mezclar los sprites y para buscar las rutas
	UINT8 *roms;							// puntero a las roms originales

	Logica *logica;							// objeto que se encarga de gestionar la lógica del juego
	Pergamino *pergamino;					// pergamino para la presentación y el final
	Marcador *marcador;						// marcador del juego
	MotorGrafico *motor;					// motor gráfico

	Sprite *sprites[numSprites];			// sprites del juego
	Puerta *puertas[numPuertas];			// puertas del juego
	Objeto *objetos[numObjetos];			// objetos del juego
	Personaje *personajes[numPersonajes];	// personajes del juego

	volatile int contadorInterrupcion;		// contador incrementado en la interrupción para sincronizar el juego

	bool pausa;								// indica si el juego está pausado
	bool modoInformacion;					// modo de información del juego
	InfoJuego *infoJuego;					// objeto para mostrar información interna del juego

// métodos
public:
	void muestraFinal();
	void limpiaAreaJuego(int color);

	// bucle principal del juego
	void run();

	// inicialización y limpieza
	Juego(UINT8 *romData, CPC6128 *cpc);
	~Juego();

protected:
	void muestraPresentacion();
	void muestraIntroduccion();
	bool muestraPantallaFinInvestigacion();

	void creaEntidadesJuego();
	
	void actualizaLuz();
	void generaGraficosFlipeados();
	void flipeaGraficos(UINT8 *tablaFlip, UINT8 *src, UINT8 *dest, int ancho, int bytes);

	void compruebaPausa();
	bool compruebaLoad();
	void compruebaSave();
};


}

#endif	// _ABADIA_JUEGO_H_
