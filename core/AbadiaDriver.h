// AbadiaDriver.h
//
//	Driver para "La abadía del crimen"
//
//	Dedicado a la memoria de Paco Menendez
//
//	Reingeniería inversa por Manuel Abadía <vigasoco@gmail.com>
//
//	Notas de la conversión:
//	=======================
//		* la conversión se ha hecho trabajando sobre la versión de Amstrad CPC 6128, que fue
//		el ordenador en el que se creó originalmente el juego, entendiendo el código del Z80
//		y creando una serie de objetos que interactuan entre si para que el resultado sea
//		equivalente al juego original.
//
//		* el juego original tiene 2 capas de tiles para generar las pantallas y crear un efecto
//		de profundidad. Para una gran parte de las pantallas, estas 2 capas son suficiente, 
//		aunque para algunas pantallas con gran cantidad de bloques que coinciden en los mismos
//		tiles, como la pantalla 0x34, esto provoca ligeras imperfecciones gráficas. Probablemente 
//		en el juego original no se usaron más capas porque cada capa adicional supone 960 bytes,
//		una pasada más a la hora de dibujar la pantalla y una pasada más en el bucle interior del
//		dibujado de sprites, y este incremento en memoria y cálculos consigue una mejora gráfica
//		muy pequeña. Aprovechando que ahora los ordenadores son más potentes, he generalizado los
//		algoritmos que tratan con las capas de forma que el número de capas que se usan viene 
//		determinado por la constante nivelesProfTiles de la clase GeneradorPantallas (que por
//		defecto vale 3, para que las pantallas se vean sin errores gráficos).
//
//		* el juego posee un intérprete para la construcción de los bloques que forman las
//		pantallas. Actualmente se interpretan los bloques ya compilados (que están en los 
//		datos originales), aunque estaría bien crear ficheros con los scripts de cada bloque 
//		y un compilador de bloques, de forma que se interprete el código que genere el 
//		compilador de bloques en vez del que viene en los datos originales.
//
//		* el comportamiento de los personajes se basa en el intérprete de scripts que trae el
//		juego original. En la conversión, el comportamiento se ha pasado directamente a C++.
//
//	Por hacer:
//	==========
//		* añadir sonido
//
//		* cargar/grabar partidas
//
/////////////////////////////////////////////////////////////////////////////

#ifndef _ABADIA_DRIVER_H_
#define _ABADIA_DRIVER_H_


#include "GameDriver.h"

#include "abadia/Juego.h"

class CPC6128;						// definido en CPC6128.h
class ICriticalSection;				// definido en ICriticalSection.h

class AbadiaDriver : public GameDriver
{
// campos
protected:
	Abadia::Juego *_abadiaGame;		// objeto principal del juego
	CPC6128 *cpc6128;				// clase de ayuda para realizar operaciones gráficas
	ICriticalSection *cs;			// sección crítica para sincronizar la escritura de gráficos
	UINT8 *romsPtr;					// puntero a los datos del juego una vez extraidos del disco
	IDrawPlugin *_dp;

// métodos
public:
	// iniciación y limpieza
	AbadiaDriver(IDrawPlugin *dp);
	virtual ~AbadiaDriver();

	virtual void runSync();
	virtual void runAsync();
	virtual void render(IDrawPlugin *dp);
	virtual void showGameLogic(IDrawPlugin *dp);

	// template methods overrides
	virtual void videoInitialized(IDrawPlugin *dp);
	virtual void videoFinalizing(IDrawPlugin *dp);

protected:
	// template methods overrides
	virtual void filesLoaded();
	virtual void finishInit();
	virtual void end();

	// métodos de ayuda
	void createGameDataEntities();
	void createGameGfxDescriptions();
	void createGameInputsAndDips();

	void drawGrid(IDrawPlugin *dp);
	void drawDestPos(IDrawPlugin *dp);

	void reOrderAndCopy(UINT8 *src, UINT8 *dst, int size);
};

#endif	// _ABADIA_DRIVER_H_
