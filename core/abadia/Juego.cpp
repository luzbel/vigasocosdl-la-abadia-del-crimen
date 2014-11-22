// Juego.cpp
//
/////////////////////////////////////////////////////////////////////////////

#include <string>

#include "../systems/CPC6128.h"
#include "../InputHandler.h"
#include "../IPalette.h"
#include "../TimingHandler.h"
#include "../Vigasoco.h"

#include "Abad.h"
#include "Adso.h"
#include "Berengario.h"
#include "Bernardo.h"
#include "BuscadorRutas.h"
#include "Controles.h"
#include "GestorFrases.h"
#include "Guillermo.h"
#include "InfoJuego.h"
#include "Jorge.h"
#include "Juego.h"
#include "Logica.h"
#include "Malaquias.h"
#include "Marcador.h"
#include "Monje.h"
#include "MotorGrafico.h"
#include "Objeto.h"
#include "Paleta.h"
#include "Pergamino.h"
#include "Personaje.h"
#include "PersonajeConIA.h"
#include "Puerta.h"
#include "RejillaPantalla.h"
#include "Severino.h"
#include "Sprite.h"
#include "SpriteLuz.h"
#include "SpriteMonje.h"

//#include "SDL.h" // Para cargar/grabar partidas con SDL_rwops.h
#include "SDL.h" // 
//666
#include "iostream"
#include "fstream"
using namespace std;

using namespace Abadia;

/////////////////////////////////////////////////////////////////////////////
// inicialización y limpieza
/////////////////////////////////////////////////////////////////////////////

Juego::Juego(UINT8 *romData, CPC6128 *cpc)
{
	// apunta a los datos del juego, pero saltándose la de la presentación
	roms = romData + 0x4000;
	cpc6128 = cpc;

	// inicia los sprites del juego
	for (int i = 0; i < numSprites; i++){
		sprites[i] = 0;
	}

	// inicia los personajes del juego
	for (int i = 0; i < numPersonajes; i++){
		personajes[i] = 0;
	}

	// inicia las puertas del juego
	for (int i = 0; i < numPuertas; i++){
		puertas[i] = 0;
	}

	// inicia los objetos del juego
	for (int i = 0; i < numObjetos; i++){
		objetos[i] = 0;
	}

	timer = 0;

	// crea los objetos principales que usará el juego
	paleta = new Paleta();
	pergamino = new Pergamino();
	motor = new MotorGrafico(buffer, 8192);
	marcador = new Marcador();
	logica = new Logica(roms, buffer, 8192); 
	infoJuego = new InfoJuego();
	controles = new Controles();

	pausa = false;
	modoInformacion = false;
}

Juego::~Juego()
{
	// borra los sprites del juego
	for (int i = 0; i < numSprites; i++){
		delete sprites[i];
	}

	// borra los personajes del juego
	for (int i = 0; i < numPersonajes; i++){
		delete personajes[i];
	}

	// borra las puertas del juego
	for (int i = 0; i < numPuertas; i++){
		delete puertas[i];
	}

	// borra los objetos del juego
	for (int i = 0; i < numObjetos; i++){
		delete objetos[i];
	}

	delete infoJuego;
	delete logica;
	delete marcador;
	delete motor;
	delete pergamino;
	delete paleta;

	delete controles;
}

/////////////////////////////////////////////////////////////////////////////
// método principal del juego
/////////////////////////////////////////////////////////////////////////////

void Juego::run()
{
	// obtiene los recursos para el juego
	timer = VigasocoMain->getTimingHandler();
	controles->init(VigasocoMain->getInputHandler());

	// muestra la imagen de presentación
	muestraPresentacion();

	// muestra el pergamino de presentación
	muestraIntroduccion();

	// crea las entidades del juego (sprites, personajes, puertas y objetos)
	creaEntidadesJuego();

	// genera los gráficos flipeados en x de las entidades que lo necesiten
	generaGraficosFlipeados();

	// inicialmente la cámara sigue a guillermo
	motor->personaje = personajes[0];

	// inicia el objeto que muestra información interna del juego
	infoJuego->inicia();

	// limpia el área que ocupa el marcador
	marcador->limpiaAreaMarcador();

	// obtiene las direcciones de los datos relativos a la habitación del espejo
	logica->despHabitacionEspejo();

	// aquí ya se ha completado la inicialización de datos para el juego
	// ahora realiza la inicialización para poder empezar a jugar una partida
	while (true){
		// inicia la lógica del juego
		logica->inicia();
despues_de_cargar_o_iniciar:
		// limpia el área de juego y dibuja el marcador
		limpiaAreaJuego(0);
		marcador->dibujaMarcador();

		// inicia el contador de la interrupción
		contadorInterrupcion = 0;

		// pone una posición de pantalla inválida para que se redibuje la pantalla
		motor->posXPantalla = motor->posYPantalla = -1;

		// dibuja los objetos que tiene guillermo en el marcador
		marcador->dibujaObjetos(personajes[0]->objetos, 0xff);

		// inicia el marcador (día y momento del día, obsequium y el espacio de las frases)
		marcador->muestraDiaYMomentoDia();
		marcador->decrementaObsequium(0);
		marcador->limpiaAreaFrases();
		
		while (true){	// el bucle principal del juego empieza aquí
			// actualiza el estado de los controles
			controles->actualizaEstado();

			// obtiene el contador de la animación de guillermo para saber si se generan caminos en esta iteración
			elBuscadorDeRutas->contadorAnimGuillermo = laLogica->guillermo->contadorAnimacion;

			// comprueba si se debe abrir el espejo
			logica->compruebaAbreEspejo();

			// comprueba si se ha pulsado la pausa
			compruebaPausa();

			//comprueba si se intenta cargar/grabar la partida
			compruebaSave();

			if ( compruebaLoad() ) goto despues_de_cargar_o_iniciar;

			// actualiza las variables relacionadas con el paso del tiempo
			logica->actualizaVariablesDeTiempo();

			// si guillermo ha muerto, empieza una partida
			if (muestraPantallaFinInvestigacion()){
				break;
			}

			// comprueba si guillermo lee el libro, y si lo hace sin guantes, lo mata
			logica->compruebaLecturaLibro();

			// comprueba si hay que avanzar la parte del momento del día en el marcador
			marcador->realizaScrollMomentoDia();

			// comprueba si hay que ejecutar las acciones programadas según el momento del día
			logica->ejecutaAccionesMomentoDia();

			// comprueba si hay opciones de que la cámara siga a otro personaje y calcula los bonus obtenidos
			logica->compruebaBonusYCambiosDeCamara();

			// comprueba si se ha cambiado de pantalla y actúa en consecuencia
			motor->compruebaCambioPantalla();

			// comprueba si los personajes cogen o dejan algún objeto
			logica->compruebaCogerDejarObjetos();

			// comprueba si se abre o se cierra alguna puerta
			logica->compruebaAbrirCerrarPuertas();

			// ejecuta la lógica de los personajes
			for (int i = 0; i < numPersonajes; i++){
				personajes[i]->run();
			}

			// indica que en esta iteración no se ha generado ningún camino
			logica->buscRutas->generadoCamino = false;

			// actualiza el sprite de la luz para que se mueva siguiendo a adso
			actualizaLuz();

			// si guillermo o adso están frente al espejo, muestra su reflejo
			laLogica->realizaReflejoEspejo();

			// si está en modo información, muestra la información interna del juego
			if (modoInformacion){
				infoJuego->muestraInfo();
			}

			// dibuja la pantalla si fuera necesario
			motor->dibujaPantalla();

			// dibuja los sprites visibles que hayan cambiado
			motor->dibujaSprites();

			// espera un poco para actualizar el estado del juego
			while (contadorInterrupcion < 0x24){
				timer->sleep(5);
			}

			// reinicia el contador de la interrupción
			contadorInterrupcion = 0;
		}
	}
}

// limpia el área de juego de color que se le pasa y los bordes de negro
void Juego::limpiaAreaJuego(int color)
{
	cpc6128->fillMode1Rect(0, 0, 32, 160, 3);
	cpc6128->fillMode1Rect(32, 0, 256, 160, color);
	cpc6128->fillMode1Rect(32 + 256, 0, 32, 160, 3);
}


// flipea respecto a x todos los gráficos del juego que lo necesiten
void Juego::generaGraficosFlipeados()
{
	UINT8 tablaFlipX[256];

	// inicia la tabla para flipear los gráficos
	for (int i = 0; i < 256; i++){
		// extrae los pixels
		int pixel0 = cpc6128->unpackPixelMode1(i, 0);
		int pixel1 = cpc6128->unpackPixelMode1(i, 1);
		int pixel2 = cpc6128->unpackPixelMode1(i, 2);
		int pixel3 = cpc6128->unpackPixelMode1(i, 3);

		int data = 0;

		// combina los pixels en orden inverso
		data = cpc6128->packPixelMode1(data, 0, pixel3);
		data = cpc6128->packPixelMode1(data, 1, pixel2);
		data = cpc6128->packPixelMode1(data, 2, pixel1);
		data = cpc6128->packPixelMode1(data, 3, pixel0);

		// guarda el resultado
		tablaFlipX[i] = data;
	}

	// genera los gráficos de las animaciones de guillermo flipeados respecto a x
	flipeaGraficos(tablaFlipX, &roms[0x0a300], &roms[0x16300], 5, 0x366);
	flipeaGraficos(tablaFlipX, &roms[0x0a666], &roms[0x16666], 4, 0x084);

	// genera los gráficos de las animaciones de adso flipeados respecto a x
	flipeaGraficos(tablaFlipX, &roms[0x0a6ea], &roms[0x166ea], 5, 0x1db);
	flipeaGraficos(tablaFlipX, &roms[0x0a8c5], &roms[0x168c5], 4, 0x168);

	// genera los gráficos de los trajes de los monjes flipeados respecto a x
	flipeaGraficos(tablaFlipX, &roms[0x0ab59], &roms[0x16b59], 5, 0x2d5);

	// genera los gráficos de las caras de los monjes flipeados respecto a x
	flipeaGraficos(tablaFlipX, &roms[0x0b103], &roms[0x17103], 5, 0x2bc);

	// genera los gráficos de las puertas flipeados respecto a x
	flipeaGraficos(tablaFlipX, &roms[0x0aa49], &roms[0x16a49], 6, 0x0f0);
}

// copia los gráficos de origen en el destino y los flipea
void Juego::flipeaGraficos(UINT8 *tablaFlip, UINT8 *src, UINT8 *dest, int ancho, int bytes)
{
	// copia los gráficos del origen al destino
	memcpy(dest, src, bytes);

	// calcula las variables que controlan el bucle
	int numLineas = bytes/ancho;
	int numIntercambios = (ancho + 1)/2;

	// recorre todas las líneas que forman el gráfico
	for (int j = 0; j < numLineas; j++){
		UINT8 *ptr1 = dest;
		UINT8 *ptr2 = ptr1 + ancho - 1;

		// realiza los intercambios necesarios para flipear esta línea
		for (int i = 0; i < numIntercambios; i++){
			UINT8 aux = *ptr1;
			*ptr1 = tablaFlip[*ptr2];
			*ptr2 = tablaFlip[aux];

			ptr1++;
			ptr2--;
		}

		// pasa a la siguiente línea
		dest = dest + ancho;
	}
}

// actualiza el sprite de la luz para que se mueva siguiendo a adso
void Juego::actualizaLuz()
{
	// desactiva el sprite de la luz
	sprites[spriteLuz]->esVisible = false;

	// si la pantalla está iluminada, sale
	if (motor->pantallaIluminada) return;

	// si adso no es visible en la pantalla actual
	if (!(personajes[1]->sprite->esVisible)){
		for (int i = 0; i < numSprites; i++){
			if (sprites[i]->esVisible){
				sprites[i]->haCambiado = false;
			}
		}

		return;
	}

	// actualiza las características del sprite de la luz según la posición del personaje
	SpriteLuz *sprLuz = (SpriteLuz *) sprites[spriteLuz];
	sprLuz->ajustaAPersonaje(personajes[1]);
}

// comprueba si se debe pausar el juego
void Juego::compruebaPausa()
{
	// si se ha pulsado suprimir, se para hasta que se vuelva a pulsar
	if (controles->seHaPulsado(KEYBOARD_SUPR)){
		pausa = true;

		while (true){
			controles->actualizaEstado();
			timer->sleep(10);
			if (controles->seHaPulsado(KEYBOARD_SUPR)){
				pausa = false;
				break;
			}
		}
	}
}

// comprueba si se desea grabar la partida
void Juego::compruebaSave()
{
	if (controles->seHaPulsado(KEYBOARD_S)){
		ofstream out("abadia.save");
		logica->save(out);
	}
}


// comprueba si se desea cargar la partida
bool Juego::compruebaLoad()
{
	if (controles->seHaPulsado(KEYBOARD_L)){


/* Opcion  2: pantalla en negro, frase con pregunta
 * (o cursor , como en la version original en MSX , y a cargar ...

// con esto borramos la parte de arriba		limpiaAreaJuego(0); // fillMode1Rect
// se podria usar cambiando las coordenadas de imprimeFrase
elMarcador->limpiaAreaMarcador();
// probar tambien con un super fillMode1Rect que borre todo ...

//elMarcador->imprimeFrase("Partida cargada, continuar? S:N", 50, 164, 2, 3);
//?? por que se ve algo mal la frase ???
//SDL_Delay(1000);
//
// ooooohhhhh, imprime la frase en el marcador, pero el gestor
// de frases sigue escribiendo si tenia alguna frase pendiente
// va a ser mejor la opcion 1
//elMarcador->imprimeFrase("Cargar? S:N", 50, 164, 2, 3);
marcador->imprimeFrase("Cargar? S:N", 50, 164, 2, 3);
while (losControles->estaSiendoPulsado(KEYBOARD_S) == false)
{ 
	losControles->actualizaEstado();
}
*/

		ifstream in("abadia.save");
		logica->load(in);

		// esto lo borra el gestor de frases si ya estaba
		// escribiendo  alguna
		// marcador->imprimeFrase("Partida cargada", 148, 164, 2, 3);
		//
		//

/* Opcion 1: No queda mal, aunque es algo lento y me obliga a cambiar las
 * frases, y no se parece al funcionamiento original */
		elGestorFrases->muestraFraseYa(0x38);
	// si está mostrando una frase por el marcador, espera a que se termine de mostrar
	//porque sino la llamada a 	marcador->limpiaAreaFrases();
	//que hay despues de cargar , puede borrar algunos caracteres ...
	
	while (elGestorFrases->mostrandoFrase) elGestorFrases->actualizaEstado();
	// este while se podra quitar, si hacemos algo parecido a cuando adso
	// pregunta si dormimos, un bucle para leer teclado y salir cuando lea S o N
	
	// tambien hay que meter esto a la hora de salvar la partida ....

		return true;
	} else return false;
}

/////////////////////////////////////////////////////////////////////////////
// métodos para mostrar distintas las pantallas de distintas situaciones del juego
/////////////////////////////////////////////////////////////////////////////

// muestra la imagen de presentación del juego
void Juego::muestraPresentacion()
{
	// fija la paleta de la presentación
	paleta->setIntroPalette();

	// muestra la pantalla de la presentación
	cpc6128->showMode0Screen(roms - 0x4000);

	// espera 5 segundos
	timer->sleep(5000);
}

// muestra el pergamino de presentación
void Juego::muestraIntroduccion()
{
	// muestra la introducción
	pergamino->muestraTexto(Pergamino::pergaminoInicio);

	// coloca la paleta negra
	paleta->setGamePalette(0);

	// espera a que se suelte el botón
	bool espera = true;

	while (espera){
		controles->actualizaEstado();
		timer->sleep(1);
		espera = controles->estaSiendoPulsado(P1_BUTTON1);
	}
}

// muestra indefinidamente el pergamino del final
void Juego::muestraFinal()
{
	while (true){
		// muestra el texto del final
		pergamino->muestraTexto(Pergamino::pergaminoFinal);
	}
}

// muestra la parte de misión completada. Si se ha completado el juego, muestra el final
bool Juego::muestraPantallaFinInvestigacion()
{
	// si guillermo está vivo, sale
	if (!logica->haFracasado) return false;

	// indica que la cámara siga a guillermo y lo haga ya
	laLogica->numPersonajeCamara = 0x80;

	// si está mostrando una frase por el marcador, espera a que se termine de mostrar
	if (elGestorFrases->mostrandoFrase) return false;

	// oculta el área de juego
	limpiaAreaJuego(3);

	// calcula el porcentaje de misión completada. Si se ha completado el juego, muestra el final
	int porc = logica->calculaPorcentajeMision();

	std::string porcentaje = "  XX POR CIENTO";
	porcentaje[2] = ((porc/10) % 10) + 0x30;
	porcentaje[3] = (porc % 10) + 0x30;

	marcador->imprimeFrase("HAS RESUELTO EL", 96, 32, 2, 3);
	marcador->imprimeFrase(porcentaje, 88, 48, 2, 3);
	marcador->imprimeFrase("DE LA INVESTIGACION", 90, 64, 2, 3);
	marcador->imprimeFrase("PULSA ESPACIO PARA EMPEZAR", 56, 128, 2, 3);

	// espera a que se pulse y se suelte el botón
	bool espera = true;

	while (espera){
		controles->actualizaEstado();
		timer->sleep(1);
		espera = !(controles->estaSiendoPulsado(P1_BUTTON1) || controles->estaSiendoPulsado(KEYBOARD_SPACE));
	}

	espera = true;

	while (espera){
		controles->actualizaEstado();
		timer->sleep(1);
		espera = controles->estaSiendoPulsado(P1_BUTTON1) || controles->estaSiendoPulsado(KEYBOARD_SPACE);
	}

	return true;
}

/////////////////////////////////////////////////////////////////////////////
// creación de las entidades del juego
/////////////////////////////////////////////////////////////////////////////

// crea los sprites, personajes, puertas y objetos del juego
void Juego::creaEntidadesJuego()
{
	// sprites de los personajes

	// sprite de guillermo
	sprites[0] = new Sprite();

	// sprite de adso
	sprites[1] = new Sprite();

	// sprite de los monjes
	for (int i = 2; i < 8; i++){
		sprites[i] = new SpriteMonje();
	}

	// sprite de las puertas
	for (int i = primerSpritePuertas; i < primerSpritePuertas + numPuertas; i++){
		sprites[i] = new Sprite();
		sprites[i]->ancho = sprites[i]->oldAncho = 0x06;
		sprites[i]->alto = sprites[i]->oldAlto = 0x28;
	}

	int despObjetos[8] = { 0x88f0, 0x9fb0, 0x9f80, 0xa010, 0x9fe0, 0x9fe0, 0x9fe0, 0x88c0 };

	// sprite de los objetos
	for (int i = primerSpriteObjetos; i < primerSpriteObjetos + numObjetos; i++){
		sprites[i] = new Sprite();
		sprites[i]->ancho = sprites[i]->oldAncho = 0x04;
		sprites[i]->alto = sprites[i]->oldAlto = 0x0c;
		sprites[i]->despGfx = despObjetos[i - primerSpriteObjetos];
	}

	// sprite de los reflejos en el espejo
	sprites[spritesReflejos] = new Sprite();
	sprites[spritesReflejos + 1] = new Sprite();

	// sprite de la luz
	sprites[spriteLuz] = new SpriteLuz();

	// crea los personajes del juego
	personajes[0] = new Guillermo(sprites[0]);
	personajes[1] = new Adso(sprites[1]);
	personajes[2] = new Malaquias((SpriteMonje *)sprites[2]);
	personajes[3] = new Abad((SpriteMonje *)sprites[3]);
	personajes[4] = new Berengario((SpriteMonje *)sprites[4]);
	personajes[5] = new Severino((SpriteMonje *)sprites[5]);
	personajes[6] = new Jorge((SpriteMonje *)sprites[6]);
	personajes[7] = new Bernardo((SpriteMonje *)sprites[7]);

	// inicia los valores comunes
	for (int i = 0; i < 8; i++){
		personajes[i]->despX = -2;
		personajes[i]->despY = -34;
	}
	personajes[1]->despY = -32;
	
	// crea las puertas del juego
	for (int i = 0; i < numPuertas; i++){
		puertas[i] = new Puerta(sprites[primerSpritePuertas + i]);
	}

	// crea los objetos del juego
	for (int i = 0; i < numObjetos; i++){
		objetos[i] = new Objeto(sprites[primerSpriteObjetos + i]);
	}
}
