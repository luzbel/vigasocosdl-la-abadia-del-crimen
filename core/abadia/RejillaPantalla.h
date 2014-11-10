// RejillaPantalla.h
//
//	Clase que contiene los métodos para modificar la rejilla de una pantalla
//
/////////////////////////////////////////////////////////////////////////////

#ifndef _REJILLA_PANTALLA_H_
#define _REJILLA_PANTALLA_H_

#include "../Types.h"

namespace Abadia {

class MotorGrafico;					// definido en MotorGrafico.h
class Personaje;					// definido en Personaje.h
class PosicionJuego;				// definido en EntidadJuego.h


class RejillaPantalla
{
// campos
public:
	UINT8 *roms;
	MotorGrafico *motor;
	UINT8 bufAlturas[24][24];		// buffer de alturas de la rejilla (24x24, 1 byte por entrada)

	int minPosX;					// mínimo valor visible en x para recortar (en coordenadas de mundo)
	int minPosY;					// mínimo valor visible en y para recortar (en coordenadas de mundo)
	int minAltura;					// mínimo altura visible (en coordenadas de mundo)

	int bufCalculoAvance[4][4];		// buffer auxiliar para el cálculo del avance del personaje

protected:
	// tabla para el cálculo del avance según las posiciones que ocupa el personaje
	static int calculoAvancePosicion[4][8];

// métodos
public:
	void rellenaAlturasPantalla(Personaje *pers);
	void calculaMinimosValoresVisibles(Personaje *pers);

	bool estaEnRejillaCentral(PosicionJuego *pos, int &posXRejilla, int &posYRejilla);
	bool ajustaAPosRejilla(int posX, int posY, int &posXRejilla, int &posYRejilla);

	bool obtenerAlturaPosicionesAvance(Personaje *pers, int &difAltura1, int &difAltura2, int &avanceX, int &avanceY);
	bool obtenerAlturaPosicionesAvance2(Personaje *pers, int &difAltura1, int &difAltura2, int &avanceX, int &avanceY);

	RejillaPantalla(MotorGrafico *motorGrafico);
	~RejillaPantalla();

// métodos de ayuda
protected:
	bool obtenerAlturaPosicionesAvanceComun(Personaje *pers, int alturaLocal, int &difAltura1, int &difAltura2, int &avanceX, int &avanceY);
	void fijaAlturaRecortando(int posX, int posY, int altura);
};


}

#endif	// _REJILLA_PANTALLA_H_
