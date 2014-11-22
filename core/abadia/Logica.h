// Logica.h
//
//		Clase que encapsula la lógica del juego
//
/////////////////////////////////////////////////////////////////////////////

#ifndef _LOGICA_H_
#define _LOGICA_H_


#include "../util/Singleton.h"
#include "../Types.h"

//666 temporal salvar/cargar
#include <fstream>
#include <iostream>
using namespace std;

namespace Abadia {


// momentos del día
enum MomentosDia {
	NOCHE = 0,
	PRIMA = 1,
	TERCIA = 2,
	SEXTA = 3,
	NONA = 4,
	VISPERAS = 5,
	COMPLETAS = 6
};


// objetos del juego
enum ObjetosJuego {
	LIBRO = 0x80,
	GUANTES = 0x40,
	GAFAS = 0x20,
	PERGAMINO = 0x10,
	LLAVE1 = 0x08,
	LLAVE2 = 0x04,
	LLAVE3 = 0x02,
	LAMPARA = 0x01
};

class Abad;						// definido en Abad.h
class AccionesDia;				// definido en AccionesDia.h
class Adso;						// definido en Adso.h
class Berengario;				// definido en Berengario.h
class Bernardo;					// definido en Bernardo.h
class BuscadorRutas;			// definido en BuscadorRutas.h
class GestorFrases;				// definido en GestorFrases.h
class Guillermo;				// definido en Guillermo.h
class Jorge;					// definido en Jorge.h
class Malaquias;				// definido en Malaquias.h
class Personaje;				// definido en Personaje.h
class Severino;					// definido en Severino.h
class Sprite;					// definido en Sprite.h

#define laLogica Logica::getSingletonPtr()

class Logica : public Singleton<Logica>
{
// campos
public:
	UINT8 *roms;				// puntero a las roms originales

	AccionesDia *accionesDia;	// ejecutor de las acciones dependiendo del momento del día
	BuscadorRutas *buscRutas;	// buscador y generador de rutas
	GestorFrases *gestorFrases;	// gestor de las frases del juego

	Guillermo *guillermo;		// guillermo
	Adso *adso;					// adso
	Malaquias *malaquias;		// malaquias
	Abad *abad;					// el abad
	Berengario *berengario;		// berengario
	Severino *severino;			// severino
	Jorge *jorge;				// jorge
	Bernardo *bernardo;			// bernardo gui

	int dia;					// dia actual
	int momentoDia;				// momento del día
	int duracionMomentoDia;		// indica lo que falta para pasar al siguiente momento del día
	int oldMomentoDia;			// indica el momento del día de las últimas acciones programadas ejecutadas
	bool avanzarMomentoDia;		// indica si debe avanzar el momento del día
	int obsequium;				// nivel de obsequium (de 0 a 31)
	bool haFracasado;			// indica si guillermo ha fracasado en la investigación
	bool investigacionCompleta;	// indica si se ha completado la investigación
	int bonus;					// bonus que se han conseguido
	
	int mascaraPuertas;			// máscara de las puertas que pueden abrirse

	bool espejoCerrado;			// indica si el espejo está cerrado o se ha abierto
	int numeroRomano;			// indica el número romano de la habitación del espejo (en el caso de que se haya generado)
	int despDatosAlturaEspejo;	// desplazamiento hasta el final de los datos de altura de la habitación del espejo
	int despBloqueEspejo;		// desplazamiento hasta los datos del bloque que forma el espejo

	bool seAcabaLaNoche;		// indica si falta poco para que se termine la noche
	bool haAmanecido;			// indica si ya ha amanecido
	bool usandoLampara;			// indica si se está usando la lámpara
	bool lamparaDesaparecida;	// indica si ha desaparecido la lámpara
	int tiempoUsoLampara;		// contador del tiempo de uso de la lámpara
	int cambioEstadoLampara;	// indica un cambio en el estado de la lámpara
	int cntTiempoAOscuras;		// contador del tiempo que pueden ir a oscuras por la biblioteca

	int cntLeeLibroSinGuantes;	// contador para llevar un control del tiempo que lee guillermo el libro sin los guantes
	bool pergaminoGuardado;		// indica que el pergamino lo tiene el abad en su habitación o está detrás de la habitación del espejo

	int numeroAleatorio;		// número aleatorio

	bool hayMovimiento;			// cuando hay algún movimiento de un personaje, esto se pone a true
	int cntMovimiento;			// contador que se pone a 0 con cada movimiento de guillermo (usado para cambios de cámara)

	int numPersonajeCamara;		// indica el personaje al que sigue la cámara actualmente
	int opcionPersonajeCamara;	// indica el personaje al que podría seguir la cámara si no hay movimiento

// métodos
public:
	void inicia();

	void compruebaLecturaLibro();
	void compruebaBonusYCambiosDeCamara();
	void compruebaCogerDejarObjetos();
	void compruebaCogerObjetos();
	void dejaObjeto(Personaje *pers);
	void compruebaAbrirCerrarPuertas();

	void actualizaVariablesDeTiempo();
	void compruebaFinMomentoDia();
	void compruebaFinLampara();
	void compruebaFinNoche();
	void reiniciaContadoresLampara();
	void ejecutaAccionesMomentoDia();

	int calculaPorcentajeMision();

	void compruebaAbreEspejo();
	int pulsadoQR();
	void realizaReflejoEspejo();
	void despHabitacionEspejo();

	// inicialización y limpieza
	Logica(UINT8 *romData, UINT8 *buf, int lgtud);
	~Logica();


	// cargar/salvar 666 temporal
	void load(ifstream &in);
	void save(ofstream &out);


// métodos de ayuda
protected:
	// inicialización
	void iniciaSprites();
	void iniciaPersonajes();
	void iniciaPuertas();
	void iniciaObjetos();
	void iniciaHabitacionEspejo();

	void generaNumeroRomano();
	bool reflejaPersonaje(Personaje *pers, Sprite *spr);

	void actualizaBonusYCamara();
};


}

#endif	// _LOGICA_H_
