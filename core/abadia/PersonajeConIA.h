// PersonajeConIA.h
//
//	Clase que representa un personaje del juego que tiene inteligencia artificial
//
/////////////////////////////////////////////////////////////////////////////

#ifndef _PERSONAJE_CON_IA_H_
#define _PERSONAJE_CON_IA_H_


#include "../Types.h"

#include "Personaje.h"

namespace Abadia {


enum PosicionesPredefinidas {
	POS_GUILLERMO = -1,
	POS_ABAD = -2,
	POS_LIBRO = -3,
	POS_PERGAMINO = -4
};

class PersonajeConIA : public Personaje
{
// campos
public:
	int numBitAcciones;					// indica el número de bits procesados del byte de acciones actual
	bool pensarNuevoMovimiento;			// indica si hay que pensar un nuevo movimiento
	UINT8 accionActual;					// indica las acciones que el personaje está procesando actualmente
	int posAcciones;					// posición de la acción actual en el buffer de acciones del personaje
	UINT8 bufAcciones[0x30];			// buffer de acciones del personaje actual

	UINT8 *lugares;						// datos de posición de los lugares a los que puede ir
	int mascarasPuertasBusqueda;		// máscara de las puertas que se comprobarán en la búsqueda
	int aDondeVa;						// indica al lugar que trata de ir actualmente
	int aDondeHaLlegado;				// indica a donde ha llegado el personaje

	PosicionJuego *posiciones;			// posiciones a las que puede ir el personaje

protected:
	static UINT16 comandosGirar[4][2];	// tabla con los comandos para cambiar de orientación
	static UINT16 comandosAvanzar[5][2];// tabla con los comandos para avanzar
	static int bufferDatosPersonaje[10];// buffer para guardar los datos del personaje por si hay que deshacer
	static int distanciasOri[4][4];		// tabla con las distancias permisibles según la orientación

// métodos
public:
	virtual void run();

	// métodos relacionados con la generación de comandos de movimiento
	void modificaOrientacion(int oriDeseada);
	void avanzaPosicion(int difAltura1, int difAltura2, int avanceX, int avanceY);
	void reiniciaPosicionBuffer();
	void descartarMovimientosPensados();
	void escribeComandos(UINT16 comandos, int bits);

	// inicialización y limpieza
	PersonajeConIA(Sprite *spr);
	virtual ~PersonajeConIA();

protected:
	// comportamiento del personaje
	virtual void piensa() = 0;

	// métodos relacionados con la ejecución de comandos de movimiento
	virtual void ejecutaMovimiento();

	int leeBit();
	int leeComando();

	void grabaEstado();
	void cargaEstado();

	// métodos auxiliares para la lógica
	bool estaCerca(Personaje *pers);
	bool siHaLlegadoAvanzaEstado();
};


}

#endif	// _PERSONAJE_CON_IA_H_
