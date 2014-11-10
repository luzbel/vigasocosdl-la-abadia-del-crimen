// Adso.h
//
//	Clase que representa a Adso
//
/////////////////////////////////////////////////////////////////////////////

#ifndef _ADSO_H_
#define _ADSO_H_


#include "../Types.h"
#include "PersonajeConIA.h"

namespace Abadia {


class Adso : public PersonajeConIA
{
// campos
public:
	int oldEstado;								// indica el estado anterior de adso
	int movimientosFrustados;					// indica el número de movimientos frustados del personaje
	int cntParaDormir;							// contador para controlar el tiempo transcurrido desde que se le pregunta a guillermo si duermen

protected:
	static DatosFotograma tablaAnimacion[8];	// tabla con los distintos fotogramas de la animación del personaje
	static PosicionJuego posicionesPredef[3];	// posiciones a las que puede ir el personaje según el estado

	static int oriMovimiento[8][4];				// tabla con las orientaciones para probar movimientos
	static int despBufferSegunOri[4][2];		// tabla de desplzamientos dentro del buffer de alturas según la orientación 

// métodos
public:
	virtual void run();
	virtual void piensa();

	// inicialización y limpieza
	Adso(Sprite *spr);
	virtual ~Adso();

// métodos de ayuda
protected:
	void escribeSN(bool muestra);
	void grabaComandosAvance(int nuevaOri);
	void avanzaSegunGuillermo();
	void liberaPasoAGuillermo();
	void pruebaMover(int numEntrada);
};


}

#endif	// _ADSO_H_
