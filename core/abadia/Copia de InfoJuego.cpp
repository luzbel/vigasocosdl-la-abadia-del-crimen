// InfoJuego.cpp
//
/////////////////////////////////////////////////////////////////////////////

#include <cassert>
#include "../systems/CPC6128.h"
#include "../IDrawPlugin.h"
#include "../IPalette.h"
#include "../FontManager.h"
#include "../Vigasoco.h"
#include "GeneradorPantallas.h"
#include "InfoJuego.h"
#include "Juego.h"
#include "MotorGrafico.h"
#include "Objeto.h"
#include "Personaje.h"
#include "Puerta.h"
#include "RejillaPantalla.h"
#include "Sprite.h"

using namespace Abadia;

char InfoJuego::buf[1024];

/////////////////////////////////////////////////////////////////////////////
// inicialización y limpieza
/////////////////////////////////////////////////////////////////////////////

InfoJuego::InfoJuego()
{
	cpc6128 = elJuego->cpc6128;

	for (int i = 0; i < 3; i++){
		alturasPlanta[i] = 0;
	}
}

InfoJuego::~InfoJuego()
{
	for (int i = 0; i < 3; i++){
		delete [] alturasPlanta[i];
	}
}

/////////////////////////////////////////////////////////////////////////////
// tablas con datos acerca de las plantas
/////////////////////////////////////////////////////////////////////////////

int InfoJuego::zonaVisiblePlanta[3][4] = {
	{ 0x01, 0x0c, 0x01, 0x0a },
	{ 0x01, 0x05, 0x02, 0x06 },
	{ 0x01, 0x05, 0x02, 0x06 }
};

int InfoJuego::alturaBasePlanta[3] = {
	0x00, 0x0d, 0x18
};

/////////////////////////////////////////////////////////////////////////////
// métodos para mostrar información interna del juego
/////////////////////////////////////////////////////////////////////////////

// inicia los datos necesarios para poder mostrar la información sobre el comportamiento del juego más tarde
void InfoJuego::inicia()
{
	// inicia la paleta (los colores colores 0-3 no pueden usarse ya que los usa el juego)
	IPalette *paleta = VigasocoMain->getPalette();

	// tabla con los colores asignados a cada personaje en los mapas
	int colores[8][3] = {
		{ 0xff, 0x00, 0x00 },	// guillermo (rojo)
		{ 0xff, 0x00, 0x00 },	// adso (rojo)
		{ 0x00, 0xff, 0x00 },	// malaquías (verde)
		{ 0x00, 0x00, 0x00 },	// el abad (negro)
		{ 0x00, 0xff, 0xff },	// berengario (azul celeste)
		{ 0x00, 0x00, 0xff },	// severino (azul)
		{ 0x80, 0x00, 0xff },	// jorge (morado)
		{ 0xff, 0x00, 0xff }	// bernardo gui (rosa)
	};

	// fija el color de los personajes en los mapas
	for (int i = 0; i < 8; i++){
		paleta->setColor(4 + i, colores[i][0], colores[i][1], colores[i][2]);
	}

	// fija el color de los personajes en el mapa de alturas
	paleta->setColor(15, 0xff, 0x00, 0x00);

	int paso = 0x80/16;

	// crea un degradado de grises para mostrar el mapa de alturas
	for (int i = 0; i < 16; i++){
		paleta->setColor(16 + i, 0x80 + paso*i, 0x80 + paso*i, 0x80 + paso*i);
	}

	// guarda la altura de las pantallas de cada planta
	generaAlturasPlanta();
}

// muestra el mapa de alturas de la pantalla a la que sigue la cámara, y los mapas de las plantas
void InfoJuego::muestraInfo()
{

	// dibuja la rejilla del juego
	dibujaRejilla();

	// dibuja el mapa de la planta actual del personaje al que sigue la cámara
	int planta = elMotorGrafico->obtenerPlanta(elMotorGrafico->obtenerAlturaBasePlanta(elMotorGrafico->personaje->altura));
	//dibujaAlturaPlanta(planta);

	// para las plantas que no se muestran, dibuja el mapa pequeño de éstas
	int numMapas = 0;
	for (int i = 0; i < 3; i++){
		if (i != planta){
			dibujaMapa(4 + numMapas*100, i);
			numMapas++;
		}
	}

	// dibuja la posición de los personajes en los mapas
	//muestraPosicionMapaAlturas(planta);

	numMapas = 0;
	for (int i = 0; i < 3; i++){
		if (i != planta){
			muestraPosicionMapa(4 + numMapas*100, i);
			numMapas++;
		}
	}

	muestraInfoPersonaje(0, 500, 0);

//	muestraInfoCapaTiles(0, 10, 0);
//	muestraInfoCapaTiles(1, 10, 200);
}

/////////////////////////////////////////////////////////////////////////////
// métodos para dibujar la rejilla
/////////////////////////////////////////////////////////////////////////////

// dibuja la rejilla
void InfoJuego::dibujaRejilla()
{
	// obtiene la rejilla de la pantalla actual
	RejillaPantalla *rejilla = elMotorGrafico->rejilla;

	// pinta la rejilla de un color dependiendo de su altura
	for (int j = 0; j < 24; j++){
		for (int i = 0; i < 24; i++){
			dibujaPosicionRejilla(i + 1, j, rejilla->bufAlturas[j][i]);
		}
	}
}

// dibuja una posición de la rejilla
void InfoJuego::dibujaPosicionRejilla(int x, int y, int valor)
{
	int color = (valor & 0x0f) + 16;

	// si en esa posición no hay un personaje, dibuja la altura
	if (valor < 0x10){
		for (int j = 0; j < 4; j++){
			for (int i = 0; i < 4; i++){
				dibujaPixelCuadrado(4*x + i, 4*y + j, color);
			}
		}
	} else {
		// si hay un personaje, dibuja un símbolo
		static int gfxPosPersonaje[4][4] = {
			{ 15,  0,  0, 15 },
			{  0, 15, 15,  0 },
			{  0, 15, 15,  0 },
			{ 15,  0,  0, 15 }
		};

		for (int j = 0; j < 4; j++){
			for (int i = 0; i < 4; i++){
				dibujaPixelCuadrado(4*x + i, 4*y + j, (gfxPosPersonaje[j][i] == 0) ? color : gfxPosPersonaje[j][i]);
			}
		}
	}
}

/////////////////////////////////////////////////////////////////////////////
// métodos para dibujar la altura del mapa de una planta
/////////////////////////////////////////////////////////////////////////////

// genera el mapa de alturas de cada pantalla y lo graba para después
void InfoJuego::generaAlturasPlanta()
{
	// crea un personaje ficticio para generar la altura de todas las pantallas de la planta
	Sprite spr;
	Personaje pers(&spr);

	// crea un objeto rejilla para obtener la altura de la pantalla en la que se encuentre el personaje
	RejillaPantalla *rejilla = new RejillaPantalla(elMotorGrafico);

	// genera la altura de las 3 plantas
	for (int numPlanta = 0; numPlanta < 3; numPlanta++){
		// calcula la memoria necesaria para guardar la altura de esta planta
		int minX = zonaVisiblePlanta[numPlanta][0];
		int maxX = zonaVisiblePlanta[numPlanta][1];
		int minY = zonaVisiblePlanta[numPlanta][2];
		int maxY = zonaVisiblePlanta[numPlanta][3];

		int longX = maxX - minX + 1;
		int longY = maxY - minY + 1;

		// reserva la memoria necesaria para guardar la altura de esta planta
		alturasPlanta[numPlanta] = new UINT8[longX*longY*16*16];
		UINT8 *alturas = alturasPlanta[numPlanta];

		// limpia la cache de alturas para el mapa
		for (int j = 0; j < longY; j++){
			for (int i = 0; i < longX; i++){
				UINT8 *alturaPantalla = &alturas[(longX*j + i)*16*16];

				for (int y = 0; y < 16; y++){
					for (int x = 0; x < 16; x++){
						alturaPantalla[16*y + x] = 0x00;
					}
				}
			}
		}

		// obtiene el mapa de la planta
		UINT8 *mapa = MotorGrafico::plantas[numPlanta];

		// recorre las pantallas del mapa, rellenando su altura
		for (int j = minY; j <= maxY; j++){
			for (int i = minX; i <= maxX; i++){

				// si la pantalla actual está definida, guarda su altura
				if ((mapa[16*j + i] != 0) || ((numPlanta == 0) && (i == 0x04) && (j == 0x03))){

					pers.posX = 16*i;
					pers.posY = 16*j;
					pers.altura = alturaBasePlanta[numPlanta];

					rejilla->rellenaAlturasPantalla(&pers);
					UINT8 *alturaPantalla = &alturas[(longX*(j - minY) + i - minX)*16*16];

					// recorre las 16x16 posiciones centrales de la rejilla y guarda su altura
					for (int y = 0; y < 16; y++){
						for (int x = 0; x < 16; x++){
							alturaPantalla[16*y + x] = 0x10 + ((rejilla->bufAlturas[y + 4][x + 4]) & 0x0f);
						}
					}
				}
			}
		}
	}
}

// dibuja el mapa completo de la planta en una posición determinada
void InfoJuego::dibujaAlturaPlanta(int numPlanta)
{
	// calcula el zoom a usar según la planta que se muestra
	int zoom = (numPlanta == 0) ? 1 : 2;

	// obtiene el mapa de la planta
	UINT8 *mapa = MotorGrafico::plantas[numPlanta];

	// obtiene la altura de la planta
	UINT8 *alturas = alturasPlanta[numPlanta];

	// obtiene la zona visible de la planta
	int minX = zonaVisiblePlanta[numPlanta][0];
	int maxX = zonaVisiblePlanta[numPlanta][1];
	int minY = zonaVisiblePlanta[numPlanta][2];
	int maxY = zonaVisiblePlanta[numPlanta][3];
	int longX = maxX - minX + 1;
	int posX = 320 - 4 - longX*16*zoom;

	// pinta las casillas del mapa que tienen una pantalla asociada
	for (int j = minY; j <= maxY; j++){
		for (int i = minX; i <= maxX; i++){
			// si la pantalla actual está definida, la pinta
			if ((mapa[16*j + i] != 0) || ((numPlanta == 0) && (i == 0x04) && (j == 0x03))){

				UINT8 *alturaPantalla = &alturas[(longX*(j - minY) + i - minX)*16*16];
				dibujaAlturaPosicionPlanta(posX, 0, i - minX, j - minY, zoom, alturaPantalla);
			}
		}
	}
}

// dibuja la altura de una pantalla de la planta con un determinado factor de zoom
void InfoJuego::dibujaAlturaPosicionPlanta(int posX, int posY, int i, int j, int zoom, UINT8 *alturas)
{
	for (int y = 0; y < 16; y++){
		for (int x = 0; x < 16; x++){
			for (int zoomY = 0; zoomY < zoom; zoomY++){
				for (int zoomX = 0; zoomX < zoom; zoomX++){
					dibujaPixelCuadrado(posX + (16*i + x)*zoom + zoomX, posY + (16*j + y)*zoom + zoomY, alturas[16*y + x]);
				}
			}
		}
	}
}

/////////////////////////////////////////////////////////////////////////////
// métodos para dibujar el mapa de una planta
/////////////////////////////////////////////////////////////////////////////

// dibuja el mapa completo de la planta en una posición determinada
void InfoJuego::dibujaMapa(int posX, int numPlanta)
{
	// calcula el zoom a usar según la planta que se muestra
	int zoom = (numPlanta == 0) ? 6 : 8;

	// obtiene el mapa de la planta
	UINT8 *mapa = MotorGrafico::plantas[numPlanta];

	// obtiene la zona visible de la planta
	int minX = zonaVisiblePlanta[numPlanta][0];
	int maxX = zonaVisiblePlanta[numPlanta][1];
	int minY = zonaVisiblePlanta[numPlanta][2];
	int maxY = zonaVisiblePlanta[numPlanta][3];

	int longY = maxY - minY + 1;
	int posY = 100 + (160 - 100 - longY*zoom)/2;

	// pinta las casillas del mapa que tienen una pantalla asociada
	for (int j = minY; j <= maxY; j++){
		for (int i = minX; i <= maxX; i++){
			// si la pantalla actual está definida, la pinta
			if ((mapa[16*j + i] != 0) || ((numPlanta == 0) && (i == 0x04) && (j == 0x03))){
				dibujaPixelCuadradoZoom(posX, posY, i - minX, j - minY, zoom, 0x1f);
			}
		}
	}
}

/////////////////////////////////////////////////////////////////////////////
// métodos para dibujar las posiciones en los mapas
/////////////////////////////////////////////////////////////////////////////

// muestra la posición de los personajes que están en el mapa de alturas
void InfoJuego::muestraPosicionMapaAlturas(int numPlanta)
{
	// calcula el zoom a usar según la planta que se muestra
	int zoom = (numPlanta == 0) ? 1 : 2;

	// obtiene la zona visible de la planta
	int minX = zonaVisiblePlanta[numPlanta][0];
	int maxX = zonaVisiblePlanta[numPlanta][1];
	int minY = zonaVisiblePlanta[numPlanta][2];

	int longX = maxX - minX + 1;
	int posX = 320 - 4 - longX*16*zoom;

	// recorre los personajes pintando la posición que ocupan
	for (int i = 0; i < Juego::numPersonajes; i++){
		Personaje *pers = elJuego->personajes[i];

		// si el personaje no está en la abadía, pasa al siguiente personaje
		if ((pers->posX == 0) && (pers->posY == 0) && (pers->altura == 0)) continue;

		// si el personaje no está en esta planta, pasa al siguiente
		if (elMotorGrafico->obtenerPlanta(elMotorGrafico->obtenerAlturaBasePlanta(pers->altura)) != numPlanta) continue;

		// calcula el desplazamiento dentro del mapa
		int despX = (((pers->posX & 0xf0) >> 4) - minX)*16 + (pers->posX & 0x0f);
		int despY = (((pers->posY & 0xf0) >> 4) - minY)*16 + (pers->posY & 0x0f);

		// dibuja la posición dentro del mapa
		dibujaPixelCuadradoZoom(posX, 0, despX, despY, zoom, 4 + i);
	}
}

// muestra la posición de los personajes que están en los mapas pequeños
void InfoJuego::muestraPosicionMapa(int posX, int numPlanta)
{
	// calcula el zoom a usar según la planta que se muestra
	int zoom = (numPlanta == 0) ? 6 : 8;

	// obtiene la zona visible de la planta
	int minX = zonaVisiblePlanta[numPlanta][0];
	int minY = zonaVisiblePlanta[numPlanta][2];
	int maxY = zonaVisiblePlanta[numPlanta][3];

	int longY = maxY - minY + 1;
	int posY = 100 + (160 - 100 - longY*zoom)/2;

	// recorre los personajes pintando la posición que ocupan
	for (int i = 0; i < Juego::numPersonajes; i++){
		Personaje *pers = elJuego->personajes[i];

		// si el personaje no está en la abadía, pasa al siguiente personaje
		if ((pers->posX == 0) && (pers->posY == 0) && (pers->altura == 0)) continue;

		// si el personaje no está en esta planta, pasa al siguiente
		if (elMotorGrafico->obtenerPlanta(elMotorGrafico->obtenerAlturaBasePlanta(pers->altura)) != numPlanta) continue;

		// calcula el desplazamiento dentro del mapa
		int despX = (((pers->posX & 0xf0) >> 4) - minX)*zoom + (pers->posX & 0x0f)*zoom/16;
		int despY = (((pers->posY & 0xf0) >> 4) - minY)*zoom + (pers->posY & 0x0f)*zoom/16;

		// dibuja la posición dentro del mapa
		dibujaPixelCuadrado(posX + despX, posY + despY, 4 + i);
	}
}

/////////////////////////////////////////////////////////////////////////////
// métodos para mostrar información sobre los personajes
/////////////////////////////////////////////////////////////////////////////

void InfoJuego::muestraInfoPersonaje(int i, int x, int y)
{
	Personaje *pers = elJuego->personajes[i];
	Sprite *spr = pers->sprite;

	sprintf(buf,	"Personaje = %02x\n"
					"================\n"
					"pos = (%02x, %02x, %02x)\n"
					"ori = %02x\n"
					"cntAnim = %02x\n"
					"bajando = %02x\n"
					"enDesnivel = %02x\n"
					"giroDesnivel = %02x\n"
					"flipX = %02x\n"
					"\n"
					"Sprite asociado\n"
					"===============\n"
					"esVisible = %02x\n"
					"haCambiado = %02x\n"
					"desaparece = %02x\n"
					"profundidad = %02x\n"
					"posPant = (%02x, %02x)\n"
					"oldPosPant = (%02x, %02x)\n"
					"dim = (%02x %02x)\n"
					"oldDim = (%02x %02x)\n"
					"posTile = (%02x %02x)\n"
					"dimFinal = (%02x %02x)\n"
					"posLocal = (%02x %02x)",

					i,
					pers->posX, pers->posY, pers->altura,
					pers->orientacion,
					pers->contadorAnimacion,
					(int)pers->bajando,
					(int)pers->enDesnivel,
					(int)pers->giradoEnDesnivel,
					(int)pers->flipX,

					(int)spr->esVisible,
					(int)spr->haCambiado,
					(int)spr->desaparece,
					spr->profundidad,
					spr->posXPant, spr->posYPant, 
					spr->oldPosXPant, spr->oldPosYPant,
					spr->ancho, spr->alto,
					spr->oldAncho, spr->oldAlto,
					spr->posXTile, spr->posYTile,
					spr->anchoFinal, spr->altoFinal,
					spr->posXLocal, spr->posYLocal
			);

	theFontManager->print(VigasocoMain->getDrawPlugin(), buf, x, y);
}

#include <iomanip>
#include <sstream>
#include <string>

void InfoJuego::muestraInfoCapaTiles(int l, int x, int y)
{
	std::ostringstream strBuf;

	// obtiene acceso al generador de pantallas
	GeneradorPantallas *gen = elMotorGrafico->genPant;

	int numBytes = 0;
	int numLineas = 0;
	int minLinea = 50;
	int maxLinea = 90;

	for (int j = 0; j < 20; j++){
		for (int i = 0; i < 16; i++){
			for (int k = 0; k < GeneradorPantallas::nivelesProfTiles; k++){
				if ((numLineas >= minLinea) && (numLineas <= maxLinea)){
					strBuf << std::setfill('0') << std::setw(2) << std::hex << (int)gen->bufferTiles[j][i].profX[k];
				}

				numBytes++;
				if (numBytes != 16){
					if ((numLineas >= minLinea) && (numLineas <= maxLinea)){
						if (numBytes != 8){
							strBuf << " ";
						} else {
							strBuf << "-";
						}
					}
				} else {
					if ((numLineas >= minLinea) && (numLineas <= maxLinea)){
						strBuf << std::endl;
					}
					numBytes = 0;
					numLineas++;
				}

				if ((numLineas >= minLinea) && (numLineas <= maxLinea)){
					strBuf << std::setfill('0') << std::setw(2) << std::hex << (int)gen->bufferTiles[j][i].profY[k];
				}

				numBytes++;
				if (numBytes != 16){
					if ((numLineas >= minLinea) && (numLineas <= maxLinea)){
						if (numBytes != 8){
							strBuf << " ";
						} else {
							strBuf << "-";
						}
					}
				} else {
					if ((numLineas >= minLinea) && (numLineas <= maxLinea)){
						strBuf << std::endl;
					}
					numBytes = 0;
					numLineas++;
				}
				
				if ((numLineas >= minLinea) && (numLineas <= maxLinea)){
					strBuf << std::setfill('0') << std::setw(2) << std::hex << (int)gen->bufferTiles[j][i].tile[k];
				}
				
				numBytes++;
				if (numBytes != 16){
					if ((numLineas >= minLinea) && (numLineas <= maxLinea)){
						if (numBytes != 8){
							strBuf << " ";
						} else {
							strBuf << "-";
						}
					}
				} else {
					if ((numLineas >= minLinea) && (numLineas <= maxLinea)){
						strBuf << std::endl;
					}
					numBytes = 0;
					numLineas++;
				}
			}
		}
	}

	theFontManager->print(VigasocoMain->getDrawPlugin(), strBuf.str(), x, y);
}

/////////////////////////////////////////////////////////////////////////////
// métodos auxiliares
/////////////////////////////////////////////////////////////////////////////

// dibuja un pixel que ocupe 2x2 posiciones en el bitmap final
void InfoJuego::dibujaPixelCuadrado(int x, int y, int color)
{
	assert((x >= 0) && (x < 320));
	assert((y >= 0) && (y < 200));
	assert((color >= 0) && (color < 32));

	cpc6128->setPixel(2*x, y, color);
	cpc6128->setPixel(2*x + 1, y, color);
}

// igual que el método anterior pero con un factor de zoom
void InfoJuego::dibujaPixelCuadradoZoom(int posX, int posY, int i, int j, int zoom, int color)
{
	for (int zoomY = 0; zoomY < zoom; zoomY++){
		for (int zoomX = 0; zoomX < zoom; zoomX++){
			dibujaPixelCuadrado(posX + i*zoom + zoomX, posY + j*zoom + zoomY, color);
		}
	}
}

