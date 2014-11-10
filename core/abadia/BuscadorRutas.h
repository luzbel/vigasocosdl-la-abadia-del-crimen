// BuscadorRutas.h
//
//	Clase que contiene los métodos para buscar rutas y caminos entre posiciones
//
/////////////////////////////////////////////////////////////////////////////

#ifndef _BUSCADOR_RUTAS_H_
#define _BUSCADOR_RUTAS_H_


#include "../util/Singleton.h"
#include "../Types.h"

#include "EntidadJuego.h"

namespace Abadia {

class FijarOrientacion;						// definido en FijarOrientacion.h
class PersonajeConIA;						// definido en PersonajeConIA.h
class RejillaPantalla;						// definido en RejillaPantalla.h

#define elBuscadorDeRutas BuscadorRutas::getSingletonPtr()

class BuscadorRutas : public Singleton<BuscadorRutas>
{
// campos
public:
	bool generadoCamino;					// indica si se ha generado algún camino en esta iteración del bucle principal
	bool seBuscaRuta;						// indica si se ejecuta el buscador de rutas o no
	int contadorAnimGuillermo;				// contador de la animación de guillermo al inicio de esta iteración del bucle principal

	int numAlternativas;					// número de alternativas generadas
	int alternativaActual;					// alternativa que se está probando actualmente
	int nivelRecursion;						// nivel de recursión de la última ejecución del algoritmo de búsqueda de caminos
	int posXIni, posYIni;					// datos sobre la posición final de las búsquedas
	int posXFinal, posYFinal, oriFinal;		// datos sobre la posición final de las búsquedas

	RejillaPantalla *rejilla;				// objeto para realizar operaciones relacionadas con la rejilla de pantalla

protected:
	INT32 *buffer;							// buffer para la búsqueda de caminos
	int lgtudBuffer;						// longitud del buffer de búsqueda

	static UINT8 habitaciones[3][256];		// tabla con las habitaciones alcanzables desde una habitación concreta
	static UINT8 habitacionesPuerta[6][4];	// tabla con las puertas y las habitaciones que comunican
	static PosicionJuego alternativas[5];	// posiciones alternativas para la búsqueda del camino
	static int despOrientacion[4][2];		// tabla de desplazamientos según la orientación
	static int posDestinoOrientacion[4][2];	// tabla con las posiciones de destino según la orientación
	
	int posPila;							// posición actual de la pila
	int posProcesadoPila;					// posición de la pila mientras se examinan las alternativas

	FijarOrientacion *fijaPosOri[4];		// objetos para indicar las posiciones a las que hay que ir según la orientación a coger

// métodos
public:
	// inicialización y limpieza
	BuscadorRutas(UINT8 *buf, int lgtud);
	~BuscadorRutas();

	void modificaPuertasRuta(int mascara);
	void generaAccionesMovimiento(PersonajeConIA *pers);

	int buscaCamino(PersonajeConIA *origen, PosicionJuego *destino);
	bool buscaEnPantalla(int posXDest, int posYDest);
	bool esPosicionDestino(int posX, int posY, int altura, int alturaBase, bool buscandoSolucion);
	void limpiaBitsBusquedaEnPantalla();

// métodos de ayuda
protected:
	// métodos de más alto nivel relacionados con la búsqueda y generación de rutas
	void generaAlternativas(PosicionJuego *pos, int oriInicial, int oldOri);
	void generaAlternativa(PosicionJuego *pos, int orientacion, int oldOri);
	void procesaAlternativas(PersonajeConIA *pers, PosicionJuego *destino);
	
	int generaCaminoAPantalla(PersonajeConIA *pers, int numPlanta);
	
	void generaAlturasPantalla(PersonajeConIA *pers);
	bool estaCerca(int coord1, int coord2, int &distancia);

	int generaCaminoAPosicion(PersonajeConIA *pers, int posXDest, int posYDest);
	int generaCaminoAPosicionSiAlcanzable(PersonajeConIA *pers, int posXDest, int posYDest);
	int compruebaFinCamino(PersonajeConIA *pers, bool encontrado);

	void grabaComandosCamino(PersonajeConIA *pers);
	void reconstruyeCamino(PersonajeConIA *pers);

	// métodos relacionados con la búsqueda de caminos en una pantalla
	bool buscaEnPantalla();
	bool buscaEnPantallaSiAlcanzable(int posXDest, int posYDest);
	bool buscaEnPantallaComun();
	bool esPosicionAlcanzable(int posX, int posY, int altura);
	bool esPosicionDestino(int posX, int posY, int alturaBase);

	// métodos relacionados con la búsqueda de caminos entre pantallas
	bool buscaPantalla(int numPlanta, int mascara);
	bool buscaPantalla(int posXDest, int posYDest, int numPlanta);
	bool esPantallaDestino(int posX, int posY, int numPlanta, int mascara, int mascaraDestino);
	void limpiaBitsBusquedaPantalla(int numPlanta);

	// operaciones sobre la pila
	void push(INT32 val1, INT32 val2);
	void pop(INT32 &val1, INT32 &val2);
	void elem(int posicion, INT32 &val1, INT32 &val2);
	void pushInv(int &posicion, INT32 val1, INT32 val2);
	void pushInv(int &posicion, INT32 val1);
	void popInv(int &posicion, INT32 &val1);
	void popInv(int &posicion, INT32 &val1, INT32 &val2);
};


}

#endif	// _BUSCADOR_RUTAS_H_
