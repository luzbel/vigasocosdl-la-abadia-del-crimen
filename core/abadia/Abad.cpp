// Abad.cpp
//
/////////////////////////////////////////////////////////////////////////////

#include "Abad.h"
#include "Berengario.h"
#include "Bernardo.h"
#include "BuscadorRutas.h"
#include "GestorFrases.h"
#include "Guillermo.h"
#include "Jorge.h"
#include "Juego.h"
#include "Logica.h"
#include "Malaquias.h"
#include "Marcador.h"
#include "MotorGrafico.h"

using namespace Abadia;

/////////////////////////////////////////////////////////////////////////////
// posiciones a las que puede ir el personaje según el estado
/////////////////////////////////////////////////////////////////////////////

PosicionJuego Abad::posicionesPredef[10] = {
	PosicionJuego(ARRIBA, 0x88, 0x3c, 0x04),	// posición en el altar de la iglesia
	PosicionJuego(IZQUIERDA, 0x3d, 0x37, 0x02),	// posición en el refectorio
	PosicionJuego(DERECHA, 0x54, 0x3c, 0x02),	// posición en su celda
	PosicionJuego(ARRIBA, 0x88, 0x84, 0x02),	// posición en la entrada de la abadía
	PosicionJuego(ABAJO, 0xa4, 0x58, 0x00),		// posición de la primera parada durante el discurso de bienvenida
	PosicionJuego(DERECHA, 0xa5, 0x21, 0x02),	// posición para que entremos a nuestra celda
	PosicionJuego(DERECHA, 0x9c, 0x2a, 0x02),	// posición en la puerta de acceso de los monjes a la iglesia
	PosicionJuego(DERECHA, 0xc7, 0x27, 0x00),	// posición en la pantalla en la que presenta a jorge
	PosicionJuego(ABAJO, 0x68, 0x61, 0x02),		// posición en la puerta de la celda de severino
	PosicionJuego(DERECHA, 0x3a, 0x34, 0x0f)	// posición a la entrada del pasillo por el que lleva a la biblioteca
};

/////////////////////////////////////////////////////////////////////////////
// personajes que deben estar en la iglesia o en el refectorio según el día
/////////////////////////////////////////////////////////////////////////////

int Abad::monjesIglesiaEnPrima[7] = { 0, 0x36, 0x26, 0x26, 0xa6, 0x02, 0x02 };
int Abad::frasesIglesiaEnPrima[7] = { 0, 0x15, 0x18, 0x1a, 0, 0, 0x17 };
int Abad::monjesEnRefectorio[7] = {	0, 0x32, 0x22, 0x22, 0x02, 0x02, 0 };
int Abad::monjesIglesiaEnVisperas[7] = { 0x36, 0x36, 0x26, 0xa6, 0, 0x02, 0 };

/////////////////////////////////////////////////////////////////////////////
// inicialización y limpieza
/////////////////////////////////////////////////////////////////////////////

Abad::Abad(SpriteMonje *spr) : Monje(spr)
{
	// coloca los datos de la cara del abad
	datosCara[0] = 0xb167;
	datosCara[1] = 0xb167 + 0x32;

	mascarasPuertasBusqueda = 0x3f;

	// asigna las posiciones predefinidas
	posiciones = posicionesPredef;
}

Abad::~Abad()
{
}

/////////////////////////////////////////////////////////////////////////////
// comportamiento
/////////////////////////////////////////////////////////////////////////////

// Los estados en los que puede estar el abad son:
//		0x00 -> estado en el que está esperando a que guillermo llegue a la abadía
//		0x01 -> estado en el que va a la primera parada reproduciendo la frase
//		0x02 -> estado en el que va a la primera parada pero ya ha terminado de reproducir la frase
//		0x03 -> estado en el que va a la segunda parada reproduciendo la frase
//		0x04 -> se va a su celda y al llegar avanza el momento del día
//		0x05 -> cambia a este estado cuando está en vísperas para ir a misa
//		0x06 -> estado en completas después de que finalice la misa
//		0x07 -> estado al llegar a la entrada de la celda de guillermo
//		0x08 -> si guillermo tarda en entrar, le ordena que entre
//		0x09 -> va hacia la puerta que comunica las celdas con la iglesia
//		0x0a -> cierra la puerta que comunica las celdas con la iglesia, avanza el momento del día y se va a su celda
//		0x0b -> busca a guillermo y le dice que debe abandonar la abadía
//		0x0c -> estado en que el abad duerme 
//		0x0d -> estado en que el abad busca a guillermo para echarlo por la noche
//		0x0e -> cambia a este estado cuando está en prima para ir a misa
//		0x0f -> estado en el que se espera a que el abad termine la frase que le dice tras misa
//		0x10 -> cambia a este estado cuando está en sexta para ir al refectorio, o después de que el abad le diga a guillermo una frase al terminar la misa
//		0x11 -> estado al que se cambia cuando el abad le ha dicho a guillermo que se acerque después de misa
//		0x12 -> estado al que se cambia cuando termina la frase de acercarse y se dice la frase que tenía pensada
//		0x13 -> estado en el que el abad le ha dicho que hay que buscar a severino y van a su celda
//		0x15 -> va a su celda, deja el pergamino y avanza el momento del día
//		0x1f -> estado en el que va a la segunda parada pero ya ha terminado de reproducir la frase
// si el bit 7 del estado es 1 indica que está recriminandole algo a guillermo
void Abad::piensa()
{
	// si guillermo visita el ala izquierda de la abadía el primer día o cuando es prima, lo echa
	if ((laLogica->guillermo->posX < 0x60) && ((laLogica->dia == 1) || (laLogica->momentoDia == PRIMA))){
		estado = 0x0b;
	}

	// si guillermo visita la biblioteca cuando no es de noche, lo espera en la entrada de la biblioteca y lo echa
	if ((laLogica->momentoDia >= PRIMA) && (laLogica->guillermo->altura >= 0x16)){
		aDondeVa = 9;
		estado = 0x0b;

		return;
	}

	// si está en estado de echar a guillermo de la abadía
	if (estado == 0x0b){
		// va a por guillermo
		aDondeVa = POS_GUILLERMO;

		// si está cerca de guillermo
		if (estaCerca(laLogica->guillermo)){
			// si guillermo no ha muerto y se no se está reproduciendo ninguna frase, lo echa
			if (!laLogica->haFracasado){
				if (!elGestorFrases->mostrandoFrase){
					// pone en el marcador la frase NO HABEIS RESPETADO MIS ORDENES. ABANDONAD PARA SIEMPRE ESTA ABADIA
					elGestorFrases->muestraFrase(0x0e);

					laLogica->haFracasado = true;
				}
			}
		}

		return;
	}

	// si guillermo ha entrado en la habitación del abad
	if ((elMotorGrafico->numPantalla == 0x0d) && (laLogica->opcionPersonajeCamara == 0)){
		// si está cerca de guillermo le recrimina que haya entrado en su celda y le expulsa
		if (estaCerca(laLogica->guillermo)){
			aDondeVa = POS_GUILLERMO;

			// pone en el marcador la frase HABEIS ENTRADO EN MI CELDA
			elGestorFrases->muestraFrase(0x29);

			estado = 0x0b;
		} else {
			// va a su celda
			aDondeVa = 2;
		}

		return;
	}

	// si ha llegado a su celda y tiene el pergamino
	if ((aDondeHaLlegado == aDondeVa) && (aDondeHaLlegado == 2) && ((objetos & PERGAMINO) == PERGAMINO)){
		laLogica->pergaminoGuardado = true;

		// modifica la máscara de los objetos que puede coger para no coger el pergamino otra vez
		mascaraObjetos = 0;

		// deja el pergamino
		laLogica->dejaObjeto(this);

		laLogica->cntMovimiento = 0;

		// si está en el estado 0x15 y no tiene el pergamino, cambia de estado y avanza el momento del día
		if ((estado == 0x15) && ((objetos & PERGAMINO) == 0)){
			estado = 0x10;

			laLogica->avanzarMomentoDia = true;

			return;
		}
	}

	// si está en el estado 0x15, se va a su celda a dejar el pergamino
	if (estado == 0x15){
		aDondeVa = 2;

		return;
	}

	// si está recriminando a guillermo
	if (estado >= 0x80){
		// si ha terminado de reproducirse la frase, vuelve al estado anterior
		if (!elGestorFrases->mostrandoFrase){
			estado = estado & 0x7f;
		} else {
			// en otro caso va a por guillermo
			aDondeVa = POS_GUILLERMO;

			return;
		}
	}

	// si está en visperas, va a la iglesia y espera a que todos estén en su sitio para avanzar el momento del día
	if (laLogica->momentoDia == VISPERAS){
		estado = 0x05;

		// comprueba que guillermo esté en la posición correcta en la iglesia
		compruebaPosGuillermoEnIglesia();

		// se dirige al altar
		aDondeVa = 0;

		// frase OREMOS
		numFrase = 0x17;

		// comprueba si los personajes con IA están en su sitio para la misa de vísperas
		compruebaPosMonjesEnIglesiaEnVisperas(laLogica->dia);

		// espera a que el abad, guillermo y los personajes con IA estén en su sitio para comenzar la misa o la comida
		esperaParaComenzarActo();

		return;
	}

	// si está en prima, va a la iglesia y espera a que todos estén en su sitio para avanzar el momento del día
	if (laLogica->momentoDia == PRIMA){
		estado = 0x0e;

		// comprueba que guillermo esté en la posición correcta en la iglesia
		compruebaPosGuillermoEnIglesia();

		// se dirige al altar
		aDondeVa = 0;

		// frase OREMOS
		numFrase = 0x17;

		// comprueba si los personajes con IA están en su sitio para la misa de prima
		compruebaPosMonjesEnIglesiaEnPrima(laLogica->dia);

		// espera a que el abad, guillermo y los personajes con IA estén en su sitio para comenzar la misa o la comida
		esperaParaComenzarActo();

		return;
	}

	if (laLogica->momentoDia == SEXTA){
		estado = 0x10;

		// comprueba que guillermo esté en la posición correcta en el refectorio
		compruebaPosGuillermoEnRefectorio();

		// va al refectorio
		aDondeVa = 1;

		// frase PODEIS COMER, HERMANOS
		numFrase = 0x19;

		// comprueba si los personajes con IA están en su sitio para comer
		compruebaPosMonjesEnRefectorio(laLogica->dia);

		// espera a que el abad, guillermo y los personajes con IA estén en su sitio para comenzar la misa o la comida
		esperaParaComenzarActo();

		return;
	}

	// si es completas y estaba en el esatdo 0x05
	if ((laLogica->momentoDia == COMPLETAS) && (estado == 0x05)){
		estado = 0x06;

		// si están en la iglesia
		if (elMotorGrafico->numPantalla == 0x22){
			// pone en el marcador la frase PODEIS IR A VUESTRAS CELDAS
			elGestorFrases->muestraFrase(0x0d);
		}

		return;
	}

	// si berengario nos ha dicho que guillermo ha cogido el pergamino, va a por guillermo
	if (guillermoHaCogidoElPergamino){
		aDondeVa = POS_GUILLERMO;

		// si el abad le ha quitado el pergamino a guillermo, cambia de estado para dejarlo en su celda
		if ((objetos & PERGAMINO) == PERGAMINO){
			estado = 0x15;
			aDondeHaLlegado = POS_GUILLERMO;
			guillermoHaCogidoElPergamino = false;

			return;
		} else {
			// si está cerca de guillermo
			if (estaCerca(laLogica->guillermo)){
				// si el contador ha rebasado el límite, abronca a guillermo
				if (contador >= 0xc8){
					contador = 0;

					// muestra la frase DADME EL MANUSCRITO, FRAY GUILLERMO
					elGestorFrases->muestraFrase(0x05);
					elMarcador->decrementaObsequium(2);
				}

				contador++;
			} else {
				// pone el contador al nivel máximo para que le llame la atención a guillermo
				contador = 0xc9;
			}

			return;
		}
	}

	// si es completas
	if (laLogica->momentoDia == COMPLETAS){
		// si ha terminado la misa y no se está reproduciendo ninguna frase, se marcha a la entrada de la celda de guillermo
		if (estado == 0x06){
			if (!elGestorFrases->mostrandoFrase){
				contador = 0;
				aDondeVa = 5;

				// al llegar a la entrada de la celda de guillermo, avanza el estado
				siHaLlegadoAvanzaEstado();
			}
			
			return;
		}

		// si el abad está en la entrada a la celda de guillermo
		if (estado == 0x07){
			// si guillermo ha entrado en su celda, cambia de estado
			if (elMotorGrafico->numPantalla == 0x3e){
				estado = 0x09;
			} else {
				// si está cerca guillermo, le dice que entre en su celda y pasa al estado 0x08
				if (estaCerca(laLogica->guillermo)){
					estado = 0x08;

					// muestra la frase ENTRAD EN VUESTRA CELDA, FRAY GUILLERMO
					elGestorFrases->muestraFrase(0x10);
				} else {
					contador++;

					// si el contador ha sobrepasado el límite, cambia de estado
					if (contador >= 0x32){
						estado = 0x08;
					}
				}
			}

			return;
		}

		// si guillermo tarda en entrar en su celda, le ordena que entre
		if (estado == 0x08){
			// si guillermo ha entrado en su celda, cambia de estado
			if (elMotorGrafico->numPantalla == 0x3e){
				estado = 0x09;
			} else {
				contador++;

				// si el contador ha sobrepasado el límite, lo mantiene en el máximo
				if (contador >= 0x32){
					contador = 0x32;
				}

				// si está cerca de guillermo
				if (estaCerca(laLogica->guillermo)){
					// si el contador está al máximo, le echa una bronca y lo reinicia
					if (contador == 0x32){
						contador = 0;

						// muestra la frase ENTRAD EN VUESTRA CELDA, FRAY GUILLERMO
						elGestorFrases->muestraFrase(0x10);
						elMarcador->decrementaObsequium(2);
					}
				} else {
					// va a por guillermo
					aDondeVa = POS_GUILLERMO;
				}
			}

			return;
		}

		if (estado == 0x09){
			// si guillermo sigue en su celda, se mueve hacia la puerta
			if (elMotorGrafico->numPantalla == 0x3e){
				aDondeVa = 6;

				// al llegar a la puerta, avanza el estado
				siHaLlegadoAvanzaEstado();
			} else {
				// si guillermo ha salido de su celda, cambia al estado 0x08 y va a por él
				descartarMovimientosPensados();
				estado = 0x08;
				aDondeVa = POS_GUILLERMO;
			}

			return;
		}

		// si ha llegado a la puerta, la cierra y se avanza el momento del día
		if (estado == 0x0a){
			laLogica->avanzarMomentoDia = true;
			laLogica->mascaraPuertas &= 0xf7;
		}

		return;
	}

	// si es de noche
	if (laLogica->momentoDia == NOCHE){
		// va a su celda
		aDondeVa = 2;

		// si ha llegado a su celda después de cerrar la puerta, inicia el contador y cambia de estado
		if ((estado == 0x0a) && (aDondeHaLlegado == 2)){
			contador = 0;
			estado = 0x0c;
		}

		// si está durmiendo
		if (estado == 0x0c){
			// si guillermo no está en el ala izquierda de la abadía, sigue durmiendo
			if (laLogica->guillermo->posX >= 0x60){
				contador++;

				// si el contador ha sobrepasado el límite o es el quinto día y hemos cogido la llave del abad, se despierta
				if ((contador >= 0xfa) || ((laLogica->dia == 5) && ((laLogica->guillermo->objetos & LLAVE1) == LLAVE1))){
					estado = 0x0d;
				}
			}
			
			return;
		}

		// si el abad se ha despertado
		if (estado == 0x0d){
			// si guillermo está en el ala izquierda de la abadía o en su celda, se vuelve a dormir
			if ((laLogica->guillermo->posX < 0x60) || (elMotorGrafico->numPantalla == 0x3e)){
				estado = 0x0c;
				contador = 0x32;
			} else {
				// si está cerca de guillermo, lo echa
				if (estaCerca(laLogica->guillermo)){
					estado = 0x0b;
				}

				aDondeVa = POS_GUILLERMO;
			}
		}
		
		return;
	}

	// si es el primer día y nona, le explica a guillermo las normas de la abadía
	if (laLogica->dia == 1){
		if (laLogica->momentoDia == NONA){
			if (estado == 0x04){
				// va a su celda
				aDondeVa = 2;

				// si ha llegado a su celda, avanza el momento del día
				if (aDondeHaLlegado == 2){
					laLogica->avanzarMomentoDia = true;
				}
				
				return;
			}

			// si está esperando a que guillermo llegue a la abadía
			if (estado == 0x00){
				// si guillermo está cerca del abad, le da la bienvenida y le dice que le siga
				if (estaCerca(laLogica->guillermo)){
					// muestra la frase BIENVENIDO A ESTA ABADIA, HERMANO. OS RUEGO QUE ME SIGAIS. HA SUCEDIDO ALGO TERRIBLE
					elGestorFrases->muestraFrase(0x01);

					// cambia de estado y va a por guillermo
					estado = 0x01;
					aDondeVa = POS_GUILLERMO;
				} else {
					// va a la entrada de la abadía
					aDondeVa = 3;
				}

				return;
			}

			// si guillermo está cerca del abad, continúa normalmente
			if (estaCerca(laLogica->guillermo)){
				// si está diciendo la primera frase
				if (estado == 0x01){
					// si va a la primera parada y no se está reproduciendo ninguna voz, cambia al estado 0x02
					if ((aDondeVa == 4) && (!elGestorFrases->mostrandoFrase)){
						estado = 0x02;
					} else if (!elGestorFrases->mostrandoFrase){
						// si ha terminado la primera frase, dice la segunda y se va a la primera parada
						
						// muestra la frase TEMO QUE UNO DE LOS MONJES HA COMETIDO UN CRIMEN. OS RUEGO QUE LO ENCONTREIS ANTES DE QUE LLEGUE BERNARDO GUI, PUES	NO DESEO QUE SE MANCHE EL NOMBRE DE ESTA ABADIA
						elGestorFrases->muestraFrase(0x02);
						aDondeVa = 4;
					}
				}

				// si ya terminó la segunda frase, espera a que llegue al destino
				if (estado == 0x02){
					// va a la primera parada
					aDondeVa = 4;

					// si ha llegado a la primera parada y no está reproduciendo una frase, pasa al estado 0x03
					if ((aDondeHaLlegado == 4) && (!elGestorFrases->mostrandoFrase)){
						estado = 0x03;
					}
				}

				// si está diciendo la tercera frase
				if (estado == 0x03){
					// si va a la primera parada y no se está reproduciendo ninguna voz, cambia al estado 0x1f
					if ((aDondeVa == 5) && (!elGestorFrases->mostrandoFrase)){
						estado = 0x1f;
					} else if (!elGestorFrases->mostrandoFrase){
						// si ha terminado la segunda frase, dice la tercera y se va a la segunda parada

						// muestra la frase DEBEIS RESPETAR MIS ORDENES Y LAS DE LA ABADIA. ASISTIR A LOS OFICIOS Y A LA COMIDA. DE NOCHE DEBEIS ESTAR EN VUESTRA CELDA
						elGestorFrases->muestraFrase(0x03);
						aDondeVa = 5;
					}
				}

				// si ya terminó la tercera frase, espera a que llegue al destino
				if (estado == 0x1f){
					// va a la segunda parada (entrada de nuestra celda)
					aDondeVa = 5;

					// si ha llegado a la segunda parada y no está reproduciendo una frase, pasa al estado 0x04 y se despide
					if ((aDondeHaLlegado == 5) && (!elGestorFrases->mostrandoFrase)){
						estado = 0x04;

						// muestra la frase ESTA ES VUESTRA CELDA, DEBO IRME
						elGestorFrases->muestraFrase(0x07);
					}
				}
				
				return;
			} else {
				// si no está cerca de guillermo, le abronca
				recriminaAGuillermo();

				return;
			}
		}

		return;
	}

	if (laLogica->dia == 2){
		// DEBEIS SABER QUE LA BIBLIOTECA ES UN LUGAR SECRETO. SOLO MALAQUIAS PUEDE ENTRAR. PODEIS IROS
		numFrase = 0x16;

		// llama a guillermo para hablar con él
		avisaAGuillermoOPasea();

		return;
	}

	// si es el tercir día
	if (laLogica->dia == 3){
		// si guillermo se ha acercado a ver que quería el abad
		if ((estado == 0x10) && (laLogica->momentoDia == TERCIA)){
			// si guillermo está cerca, va al lugar donde está jorge
			if (estaCerca(laLogica->guillermo)){
				aDondeVa = 7;
			} else {
				// si han llegado a donde estaba jorge, reprime a guillermo y sigue por donde lo dejó
				if (laLogica->jorge->estado >= 0x1e){
					laLogica->jorge->estado--;

					return;
				}
				laLogica->avanzarMomentoDia = false;
				recriminaAGuillermo();
			}
		} else {
			// frase QUIERO QUE CONOZCAIS AL HOMBRE MAS VIEJO Y SABIO DE LA ABADIA
			numFrase = 0x30;

			// llama a guillermo para hablar con él
			avisaAGuillermoOPasea();
		}
		
		return;
	}

	// si es el cuarto día
	if (laLogica->dia == 4){
		// frase HA LLEGADO BERNARDO, DEBEIS ABANDONAR LA INVESTIGACION
		numFrase = 0x11;

		// llama a guillermo para hablar con él
		avisaAGuillermoOPasea();

		return;
	}

	// si es el quinto día
	if (laLogica->dia == 5){
		if (laLogica->momentoDia == NONA){
			// si ha llegado a la puerta de la celda de severino
			if (aDondeHaLlegado == 8){
				contador++;

				// si se ha esperado suficiente, cambia de estado e informa de la muerte de severino
				if (contador >= 0x1e){
					estado = 0x10;

					// muestra la frase DIOS SANTO... HAN ASESINADO A SEVERINO Y LE HAN ENCERRADO
					elGestorFrases->muestraFrase(0x1c);
					laLogica->avanzarMomentoDia = true;
				}
			} else {
				// si va a la celda de severino y está en el estado 0x13
				if ((aDondeVa == 8) || (estado == 0x13)){
					contador = 0;

					if (estado == 0x13){
						// si está cerca de guillermo, va a la celda de severino. En otro caso, le recrimina
						if (estaCerca(laLogica->guillermo)){
							aDondeVa = 8;
						} else {
							recriminaAGuillermo();
						}
					} else if (!elGestorFrases->mostrandoFrase) {
						// si no se está mostrando una frase, pasa al estado 0x13
						estado = 0x13;
					}
				} else {
					// muestra la frase VENID, FRAY GUILLERMO, DEBEMOS ENCONTRAR A SEVERINO
					elGestorFrases->muestraFraseYa(0x1b);

					// va a la celda de severino
					aDondeVa = 8;
				}
			}
		} else {
			// frase BERNARDO ABANDONARA HOY LA ABADIA
			numFrase = 0x1d;

			// llama a guillermo para hablar con él
			avisaAGuillermoOPasea();
		}

		return;
	}

	// si es el sexto día
	if (laLogica->dia == 6){
		// frase MAÑANA ABANDONAREIS LA ABADIA
		numFrase = 0x1e;

		// llama a guillermo para hablar con él
		avisaAGuillermoOPasea();

		return;
	}

	// si es el séptimo día
	if (laLogica->dia == 7){
		// frase DEBEIS ABANDONAR YA LA ABADIA
		numFrase = 0x25;

		// en tercia del septimo día termina el juego
		if (laLogica->momentoDia == TERCIA){
			laLogica->haFracasado = true;
		}

		// llama a guillermo para hablar con él
		avisaAGuillermoOPasea();

		return;
	}
}

/////////////////////////////////////////////////////////////////////////////
// métodos de ayuda
/////////////////////////////////////////////////////////////////////////////

// le ordena a guillermo que vaya a donde está él
void Abad::recriminaAGuillermo()
{
	// si no acaba de recriminar a guillermo, lo hace ahora
	if (estado < 0x80){
		// descarta los movimientos que tenía pensados
		descartarMovimientosPensados();

		// muestra la frase OS ORDENO QUE VENGAIS y le decrementa la vida
		elGestorFrases->muestraFraseYa(0x08);
		elMarcador->decrementaObsequium(2);

		// indica que le acaba de llamar la atención
		estado = estado + 0x80;

		// en esta iteración no busca ninguna ruta
		elBuscadorDeRutas->seBuscaRuta = false;
	}
}

// espera a que el abad, guillermo y los personajes con IA estén en su sitio para comenzar la misa o la comida
void Abad::esperaParaComenzarActo()
{
	// si ha llegado a donde debía ir
	if (aDondeHaLlegado == aDondeVa){
		// si los monjes están listos
		if (lleganLosMonjes == 0){
			// si guillermo ha llegado a la pantalla del acto
			if (guillermoBienColocado >= 0x01){
				// si se ha superado el contador de puntualidad, lo reinicia y reprende a guillermo
				if (contador >= 0x32){
					contador = 0;

					// muestra la frase LLEGAIS TARDE, FRAY GUILLERMO
					elGestorFrases->muestraFrase(0x06);
					elMarcador->decrementaObsequium(2);
				} else {
					// si no se está mostrando ninguna frase
					if (!elGestorFrases->mostrandoFrase){
						// si guillermo no está en su sitio, incrementa el contador
						if (guillermoBienColocado == 2){
							contador++;

							// si el contador pasa el límite tolerable, le indica que ocupe su sitio
							if (contador >= 0x1e){
								contador = 0;

								// muestra la frase OCUPAD VUESTRO SITIO, FRAY GUILLERMO
								elGestorFrases->muestraFrase(0x2d);
								elMarcador->decrementaObsequium(2);
							}
							
							return;
						} else {
							// si guillermo está en su sitio, el abad habla y se avanzará el día cuando termine de hablar
							elGestorFrases->muestraFrase(numFrase);
							laLogica->avanzarMomentoDia = true;
						}
					}

					// si se tenía que avanzar el momento del día pero guillermo se ha movido del sitio, le reprime
					if ((laLogica->avanzarMomentoDia == true) && (guillermoBienColocado == 2)){
						contador = 0;

						laLogica->avanzarMomentoDia = false;

						// muestra la frase OCUPAD VUESTRO SITIO, FRAY GUILLERMO
						elGestorFrases->muestraFraseYa(0x2d);
						elMarcador->decrementaObsequium(2);
					}
				}
			} else {
				// si guillermo no ha llegado a la pantalla del acto

				// si se le ha esperado suficiente, le echa
				if (contador >= 0xc8){
					estado = 0x0b;
					laLogica->avanzarMomentoDia = true;
				} else {
					contador++;
				}
			}
		}
	} else {
		// si aun no ha llegado al destino, mantiene el contador a 0
		contador = 0;
	}
}

// comprueba la posición de guillermo en la iglesia
void Abad::compruebaPosGuillermoEnIglesia()
{
	compruebaPosGuillermo(0x84, 0x4b, ABAJO);
}

// comprueba la posición de guillermo en el refectorio
void Abad::compruebaPosGuillermoEnRefectorio()
{
	compruebaPosGuillermo(0x38, 0x39, ABAJO);
}

// comprueba que guillermo esté en una posición determinada (de la planta baja)
void Abad::compruebaPosGuillermo(int posX, int posY, int orientacion)
{
	// inicialmente guillermo no está bien colocado ni en la habitación de destino
	guillermoBienColocado = 0;

	// si no está en la planta baja, sale devolviendo 0
	if (laLogica->guillermo->altura >= 0x0b) return;

	// halla la diferencia de posición en X y en Y
	int difX = laLogica->guillermo->posX ^ posX;
	int difY = laLogica->guillermo->posY ^ posY;
	int dif = (difX | difY);

	// si no está en la misma habitación, sale devolviendo 0
	if (dif >= 0x10) return;

	// aquí por lo menos está en la misma habitación de destino
	guillermoBienColocado = 2;

	// si no está en la posición de destino, sale devolviendo 2
	if (dif != 0) return;

	// si está en la posición de destino y con la orientación deseada, sale devolviendo 1
	if (laLogica->guillermo->orientacion == orientacion){
		guillermoBienColocado = 1;
	}
}

// comprueba que todos los personajes con IA estén en su sitio para la misa de vísperas
void Abad::compruebaPosMonjesEnIglesiaEnVisperas(int numDia)
{
	// el quinto día tiene un tratamiento especial 
	if (numDia == 5){
		// si malaquías se está muriendo
		if (laLogica->malaquias->estaMuerto >= 0x01){
			// frase MALAQUIAS HA MUERTO
			numFrase = 0x20;

			// indica que todos los monjes están en su sitio
			lleganLosMonjes = 0;
		} else {
			// indica que aún no están todos en su sitio
			lleganLosMonjes = 1;
		}

		return;
	}

	// en otro caso, comprueba que los monjes que deben estar presentes hayan llegado a la iglesia
	if (monjesIglesiaEnVisperas[numDia - 1] != 0){
		lleganLosMonjes = 0;

		// recorre los personajes y los que interesan, los combina con el resultado
		for (int i = 1; i < Juego::numPersonajes; i++){
			if ((monjesIglesiaEnVisperas[numDia - 1] & (1 << i)) != 0){
				PersonajeConIA *pers = (PersonajeConIA *)elJuego->personajes[i];
				lleganLosMonjes |= pers->aDondeHaLlegado;
			}
		}
	}
}

// comprueba que todos los personajes con IA estén en su sitio para la misa de prima
void Abad::compruebaPosMonjesEnIglesiaEnPrima(int numDia)
{
	// fija la frase a decir según el día que sea
	if (frasesIglesiaEnPrima[numDia - 1] != 0){
		numFrase = frasesIglesiaEnPrima[numDia - 1];
	}

	// comprueba que los monjes que deben estar presentes hayan llegado a la iglesia y cambia la frase a mostrar
	if (monjesIglesiaEnPrima[numDia - 1] != 0){
		lleganLosMonjes = 0;

		// recorre los personajes y los que interesan, los combina con el resultado
		for (int i = 1; i < Juego::numPersonajes; i++){
			if ((monjesIglesiaEnPrima[numDia - 1] & (1 << i)) != 0){
				PersonajeConIA *pers = (PersonajeConIA *)elJuego->personajes[i];
				lleganLosMonjes |= pers->aDondeHaLlegado;
			}
		}
	}
}

// comprueba que todos los personajes con IA estén en su sitio para comer
void Abad::compruebaPosMonjesEnRefectorio(int numDia)
{
	lleganLosMonjes = 1;

	// comprueba que los monjes que deben estar presentes hayan llegado a la iglesia y cambia la frase a mostrar
	if (monjesEnRefectorio[numDia - 1] != 0){
		// recorre los personajes y los que interesan, los combina con el resultado
		for (int i = 1; i < Juego::numPersonajes; i++){
			if ((monjesEnRefectorio[numDia - 1] & (1 << i)) != 0){
				PersonajeConIA *pers = (PersonajeConIA *)elJuego->personajes[i];
				lleganLosMonjes &= pers->aDondeHaLlegado;
			}
		}

		// invierte el resultado
		lleganLosMonjes = lleganLosMonjes ^ 1;
	}
}

// si es tercia, habla con guillermo. En otro caso se pasea
void Abad::avisaAGuillermoOPasea()
{
	if (estado == 0x10){
		paseaPorLaAbadia();
	} else {
		if (laLogica->momentoDia == TERCIA){
			diceFraseAGuillermoEnTercia();
		}
	}
}

// se pasea por la abadía
void Abad::paseaPorLaAbadia()
{
	// si malaquías, berengario o bernardo van a por el abad
	if ((laLogica->malaquias->aDondeVa == POS_ABAD) || (laLogica->berengario->aDondeVa == POS_ABAD) || (laLogica->bernardo->aDondeVa == POS_ABAD)){
		// si el abad ha llegado a donde quería ir, se queda quieto esperándoles
		if (aDondeHaLlegado == aDondeVa){
			elBuscadorDeRutas->seBuscaRuta = false;
		} else {
			// se va a su celda
			aDondeVa = 2;

			// si bernardo tiene el pergamino, va a la entrada de la abadía a esperarle
			if ((laLogica->bernardo->objetos & PERGAMINO) == PERGAMINO){
				aDondeVa = 3;
			}
		}
	} else {
		// si el abad tiene el pergamino, va a su celda a dejarlo
		if ((objetos & PERGAMINO) == PERGAMINO){
			aDondeVa = 2;
		}

		// si ha llegado a donde quería ir, se mueve aleatoriamente
		if (aDondeHaLlegado == aDondeVa){
			aDondeVa = (laLogica->numeroAleatorio & 0x03) + 2;
		}
	}
	
}

// llama a guillermo y le dice una frase, para finalmente pasar al estado 0x10
void Abad::diceFraseAGuillermoEnTercia()
{
	// si acaba de terminar la misa de prima, le dice a guillermo que se acerque
	if (estado == 0x0e){
		// muestra la frase VENID AQUI, FRAY GUILLERMO
		elGestorFrases->muestraFrase(0x14);
		estado = 0x11;
	}

	// si le ha dicho a guillermo que se acerque
	if (estado == 0x11){
		// si no se está mostrando ninguna frase, pasa al estado 0x12
		if (!elGestorFrases->mostrandoFrase){
			estado = 0x12;
			contador = 0;
		}
	}

	// si ha terminado la frase que le indicaba que se acercase, comienza a decir la frase que tenía pensada
	if (estado == 0x12){
		estado = 0x0f;
		aDondeVa = 0;

		// muestra la frase que tenía almacenada
		elGestorFrases->muestraFrase(numFrase);

		return;
	}

	// si está esperando a que el abad termine la frase
	if (estado == 0x0f){
		// si no se está mostrando ninguna frase, pasa al estado 0x10 y sale
		if (!elGestorFrases->mostrandoFrase){
			estado = 0x10;
		} else {

			// si guillermo no está cerca del abad, se lo recrimina
			if (!estaCerca(laLogica->guillermo)){
				estado = 0x12;

				recriminaAGuillermo();
			}
		}
	}
}
