// AbadiaDriver.cpp
//
/////////////////////////////////////////////////////////////////////////////

#include "AbadiaDriver.h"
#include "systems/CPC6128.h"
#include "systems/DskReader.h"
#include "ICriticalSection.h"
#include "IDrawPlugin.h"
#include "GameDataEntity.h"
#include "GameDriver.h"
#include "GfxData.h"
#include "InputHandler.h"
#include "Vigasoco.h"

#include "abadia/GestorFrases.h"
#include "abadia/Juego.h"

using namespace Abadia;

/////////////////////////////////////////////////////////////////////////////
// initialization and cleanup
/////////////////////////////////////////////////////////////////////////////

AbadiaDriver::AbadiaDriver() : GameDriver("abadia", "La abadia del crimen", 300)
{
	_videoInfo.width = 640;
	_videoInfo.height = 400;
	_videoInfo.visibleArea = Rect(_videoInfo.width, _videoInfo.height);
	_videoInfo.colors = 32;			// 16 del juego + 16 para mostrar información interna del juego
	_videoInfo.refreshRate = 50;

	_numInterruptsPerVideoUpdate = 6;
	_numInterruptsPerLogicUpdate = 1;

	_abadiaGame = 0;
	cpc6128 = 0;
	cs = 0;
	romsPtr = 0;

	createGameDataEntities();
	createGameGfxDescriptions();
	createGameInputsAndDips();
}

AbadiaDriver::~AbadiaDriver()
{
}

/////////////////////////////////////////////////////////////////////////////
// creates the necessary file info, graphics specifications and inputs
/////////////////////////////////////////////////////////////////////////////

void AbadiaDriver::createGameDataEntities()
{
	// el código y los gráficos están mezclados en la imagen
	GameDataEntity *roms = new GameDataEntity(MIXED, "Code + Graphics + Sound");
	roms->addFile(new GameFile("abadia.dsk", 0x00000, 0x27400, 0xd37cf8e7, 0));
	_gameFiles.push_back(roms);
}

void AbadiaDriver::createGameGfxDescriptions()
{
}

void AbadiaDriver::createGameInputsAndDips()
{
}

/////////////////////////////////////////////////////////////////////////////
// template method overrides to customize initialization
/////////////////////////////////////////////////////////////////////////////

void AbadiaDriver::filesLoaded()
{
	int bytesWritten;
	UINT8 auxBuffer[0xff00];

	// reserva espacio para los datos del juego
	romsPtr = new UINT8[0x24000];

	// extrae los datos del juego de la imagen del disco
	DskReader dsk(_gameFiles[0]->getData());

	// obtiene los datos de las pistas 0x01-0x11
	for (int i = 0x01; i <= 0x11; i++){
		dsk.getTrackData(i, &auxBuffer[(i - 0x01)*0x0f00], 0x0f00, bytesWritten);
	}

	// reordena los datos y los copia al destino
	reOrderAndCopy(&auxBuffer[0x0000], &romsPtr[0x00000], 0x4000);	// abadia0.bin
	reOrderAndCopy(&auxBuffer[0x4000], &romsPtr[0x0c000], 0x4000);	// abadia3.bin
	reOrderAndCopy(&auxBuffer[0x8000], &romsPtr[0x20000], 0x4000);	// abadia8.bin
	reOrderAndCopy(&auxBuffer[0xc000], &romsPtr[0x04100], 0x3f00);	// abadia1.bin

	// obtiene los datos de las pistas 0x12-0x16
	for (int i = 0x12; i <= 0x16; i++){
		dsk.getTrackData(i, &auxBuffer[(i - 0x12)*0x0f00], 0x0f00, bytesWritten);
	}

	// reordena los datos y los copia al destino
	reOrderAndCopy(&auxBuffer[0x0000], &romsPtr[0x1c000], 0x4000);	// abadia7.bin

	// obtiene los datos de las pistas 0x17-0x1b
	for (int i = 0x17; i <= 0x1b; i++){
		dsk.getTrackData(i, &auxBuffer[(i - 0x17)*0x0f00], 0x0f00, bytesWritten);
	}

	// reordena los datos y los copia al destino
	reOrderAndCopy(&auxBuffer[0x0000], &romsPtr[0x18000], 0x4000);	// abadia6.bin

	// obtiene los datos de las pistas 0x1c-0x21
	for (int i = 0x1c; i <= 0x21; i++){
		dsk.getTrackData(i, &auxBuffer[(i - 0x1c)*0x0f00], 0x0f00, bytesWritten);
	}

	// reordena los datos y los copia al destino
	reOrderAndCopy(&auxBuffer[0x0000], &romsPtr[0x14000], 0x4000);	// abadia5.bin

	// obtiene los datos de las pistas 0x21-0x25
	for (int i = 0x21; i <= 0x25; i++){
		dsk.getTrackData(i, &auxBuffer[(i - 0x21)*0x0f00], 0x0f00, bytesWritten);
	}

	// reordena los datos y los copia al destino
	reOrderAndCopy(&auxBuffer[0x0000], &romsPtr[0x08000], 0x4000);	// abadia2.bin
}

// reordena los datos gráficos y los copia en el destino
void AbadiaDriver::reOrderAndCopy(UINT8 *src, UINT8 *dst, int size)
{
	for (int i = 0; i < size; i++){
		dst[size - i - 1] = src[i];
	}
}

void AbadiaDriver::finishInit()
{
	// crea e inicia la sección crítica para la sincronización del dibujado de gráficos
	cs = VigasocoMain->createCriticalSection();
	cs->init();

	//crea el objeto para tratar con gráficos del amstrad
	cpc6128 = new CPC6128(cs);

	// crea el objeto del juego
	_abadiaGame = new Abadia::Juego(romsPtr, cpc6128);
	_abadiaGame->contadorInterrupcion = 0;
}

void AbadiaDriver::videoInitialized(IDrawPlugin *dp)
{
}

/////////////////////////////////////////////////////////////////////////////
// template method overrides to customize cleanup
/////////////////////////////////////////////////////////////////////////////

void AbadiaDriver::videoFinalizing(IDrawPlugin *dp)
{
}

void AbadiaDriver::end()
{
	// destruye la sección crítica
	if (cs != 0){
		cs->destroy();
		delete cs;
	}

	// borra el objeto de ayuda para los gráficos
	delete cpc6128;

	// borra el objeto del juego
	delete _abadiaGame;

	// libera la memoria utilizada por las roms del juego
	delete[] romsPtr;
}

/////////////////////////////////////////////////////////////////////////////
// run and refresh methods
/////////////////////////////////////////////////////////////////////////////

void AbadiaDriver::runSync()
{
	if (!_abadiaGame->pausa){
		// incrementa el contador de la interrupción
		_abadiaGame->contadorInterrupcion++;

		// si se está mostrando alguna frase en el marcador, continúa mostrándola
		elGestorFrases->procesaFraseActual();
	}
}

void AbadiaDriver::runAsync()
{
	_abadiaGame->run();
}

void AbadiaDriver::render(IDrawPlugin *dp)
{
	UINT8 *posPant = cpc6128->screenBuffer;

	// dibuja los datos que el juego escribe en el otro hilo en el buffer de pantalla
	cs->enter();
	for (int y = 0; y < 200; y++){
		for (int x = 0; x < 640; x++){
			int data = *posPant;

			// si el pixel ha cambiado, lo dibuja y lo marca como no cambiado
			if ((data & 0x80) == 0x80){
				// marca el pixel como no cambiado
				data = data & 0x1f;
				*posPant = data;

				dp->setPixel(x, 2*y, data);
				dp->setPixel(x, 2*y + 1, data);
			}

			posPant++;
		}
	}
	cs->leave();
}

/////////////////////////////////////////////////////////////////////////////
// display internal game information
/////////////////////////////////////////////////////////////////////////////

void AbadiaDriver::showGameLogic(IDrawPlugin *dp)
{
	// actualiza el modo de información
	if (theInputHandler->hasBeenPressed(FUNCTION_5)){
		_abadiaGame->modoInformacion = !_abadiaGame->modoInformacion;
	}	
}
