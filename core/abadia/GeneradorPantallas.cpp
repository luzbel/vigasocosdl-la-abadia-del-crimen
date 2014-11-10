// GeneradorPantallas.cpp
//
/////////////////////////////////////////////////////////////////////////////

#include "Comandos.h"
#include "../systems/CPC6128.h"
#include "Juego.h"
#include "../IDrawPlugin.h"
#include "../TimingHandler.h"
#include "GeneradorPantallas.h"

using namespace Abadia;

/////////////////////////////////////////////////////////////////////////////
// inicialización y limpieza
/////////////////////////////////////////////////////////////////////////////

GeneradorPantallas::GeneradorPantallas()
{
	roms = elJuego->roms;
	cpc6128 = elJuego->cpc6128;

	cambioSistemaCoord = false;
	estadoOpsX[0] = 1;
	estadoOpsX[1] = 1;
	estadoOpsX[2] = 1;
	estadoOpsX[3] = 0;

	// crea los comandos de generación de bloques
	manejadores[0xff^0xff] = new EndBlock();
	manejadores[0xfe^0xff] = new WhileParam1();
	manejadores[0xfd^0xff] = new WhileParam2();
	manejadores[0xfc^0xff] = new PushTilePos();
	manejadores[0xfb^0xff] = new PopTilePos();
	manejadores[0xfa^0xff] = new EndWhile();
	manejadores[0xf9^0xff] = new DrawTileDecY();
	manejadores[0xf8^0xff] = new DrawTileIncX();
	manejadores[0xf7^0xff] = new UpdateReg();
	manejadores[0xf6^0xff] = new IncTilePosY();
	manejadores[0xf5^0xff] = new IncTilePosX();
	manejadores[0xf4^0xff] = new DecTilePosY();
	manejadores[0xf3^0xff] = new DecTilePosX();
	manejadores[0xf2^0xff] = new UpdateTilePosY();
	manejadores[0xf1^0xff] = new UpdateTilePosX();
	manejadores[0xf0^0xff] = new IncParam1();
	manejadores[0xef^0xff] = new IncParam2();
	manejadores[0xee^0xff] = new DecParam1();
	manejadores[0xed^0xff] = new DecParam2();
	manejadores[0xec^0xff] = new Call();
	manejadores[0xeb^0xff] = new DrawTileDecX();
	manejadores[0xea^0xff] = new ChangePC();
	manejadores[0xe9^0xff] = new FlipX();
	manejadores[0xe8^0xff] = new FlipX();
	manejadores[0xe7^0xff] = new FlipX();
	manejadores[0xe6^0xff] = new FlipX();
	manejadores[0xe5^0xff] = new FlipX();
	manejadores[0xe4^0xff] = new CallPreserve();

	// genera las máscaras para combinar los pixels
	generaMascaras();
}

GeneradorPantallas::~GeneradorPantallas()
{
	// elimina los comandos de generación de bloques
	for (int i = 0; i < 0x1c; i++){
		delete manejadores[i];
	}
}

/////////////////////////////////////////////////////////////////////////////
// métodos de generación de bloques
//
// Los bloques puede tener 3 o 4 bytes de longitud. El formato del bloque es:
//		byte 0:
//			bits 7-1: tipo del bloque a construir
//			bit 0: si es 1 indica que el bloque puede ocultar a los sprites
//		byte 1:
//			bits 7-5: parámetro 1 (su función depende del tipo de bloque a construir)
//			bits 4-0: posición inicial en x (sistema de coordenadas del buffer de tiles)
//		byte 2:
//			bits 7-5: parámetro 2 (su función depende del tipo de bloque a construir)
//			bits 4-0: posición inicial en y (sistema de coordenadas del buffer de tiles)
//		byte 3: altura inicial del bloque
//
/////////////////////////////////////////////////////////////////////////////

// genera los capas de tiles que forman una pantalla dados los datos de los bloques que la forman
void GeneradorPantallas::genera(UINT8 *datosPantalla)
{
	// inicia la pila
	posPila = 0;

	// repite el proceso de generación de bloques hasta que no se encuentre el marcador de fin de datos
	while (*datosPantalla != 0xff){

		if (datosPantalla[0] == 0x2f){
			if ((datosPantalla[1] == 0x0e) && (datosPantalla[2] == 0xb0) && (datosPantalla[3] == 0x0e)){
				int a = 0;
			}
		}
		// los 7 bits más significativos del primer byte de los datos indican el tipo de bloque a construir
		int despTipoBloque = obtenerDir(0x156d + (datosPantalla[0] & 0xfe));

		// obtiene un puntero a los tiles que forman el bloque
		UINT8 *tilesBloque = &roms[obtenerDir(despTipoBloque)];
		
		// avanza el desplazamiento hasta los comandos que forman el bloque
		comandosBloque = despTipoBloque + 2;

		// lee la posición desde donde se dibujará el bloque
		tilePosX = datosPantalla[1] & 0x1f;
		tilePosY = datosPantalla[2] & 0x1f;

		// lee los parámetros del bloque
		datosBloque[12] = (datosPantalla[1] >> 5) & 0x07;
		datosBloque[13] = (datosPantalla[2] >> 5) & 0x07;

		// inicia la profundidad del bloque en la rejilla a (0, 0)
		datosBloque[15] = datosBloque[16] = 0;

		int altura = 0xff;

		// si la entrada es de 4 bytes, el cuarto byte indica la altura del bloque, y también implica
		// que se calcularán los datos de profundidad a lo largo del proceso de generación del bloque
		if (datosPantalla[0] & 0x01){
			altura = datosPantalla[3];
			datosPantalla++;
		}

		// avanza a la siguiente entrada
		datosPantalla += 3;

		// guarda la altura para después
		datosBloque[14] = altura;

		// inicia la evaluación del bloque
		iniciaInterpretacionBloque(tilesBloque, true, altura);
	}
}

// realiza la iniciación necesaria para interpretar los datos de un bloque
void GeneradorPantallas::iniciaInterpretacionBloque(UINT8 *tilesBloque, bool modificaTiles, int altura)
{
	if (modificaTiles){
		// copia los datos de los tiles que forman el bloque al buffer
		for (int i = 0; i < 12; i++){
			datosBloque[i] = tilesBloque[i];
		}
	}

	// transforma la posición del bloque en el buffer de tiles al sistema de coordenadas de la rejilla
	transformaCoordBloqueRejilla(altura);

	// comienza a interpretar los comandos
	interpretaComandos();
}

// transforma la posición del bloque en el buffer de tiles al sistema de coordenadas de la rejilla
// las ecuaciones de cambio de sistema de coordenadas son:
// mapa de tiles -> rejilla:		Xrejilla = Ymapa + Xmapa - 15
//									Yrejilla = Ymapa - Xmapa + 16
void GeneradorPantallas::transformaCoordBloqueRejilla(int altura)
{
	// solo realiza la transformación si el bloque puede ocultar a los sprites
	if (altura != 0xff){
		datosBloque[15] = (tilePosY + altura/2) + tilePosX - 15;
		datosBloque[16] = (tilePosY + altura/2) - tilePosX + 16;
	}
}

// interpreta los comandos que se indican en comandosBloque
void GeneradorPantallas::interpretaComandos()
{
	while (true){
		UINT8 *comando = &roms[comandosBloque];
		// obtiene el número de la rutina que está complementado
		int numRutina = (*comando) ^ 0xff;

		comandosBloque++;

		// llama a la rutina correspondiente para que realice su procesamiento
		bool terminado = manejadores[numRutina]->ejecutar(this);

		// si era el último comando de generación del bloque, sale
		if (terminado){
			break;
		}
	}
}

/////////////////////////////////////////////////////////////////////////////
// métodos de ayuda para los comandos de dibujo de los tiles
/////////////////////////////////////////////////////////////////////////////

// actualiza los datos de un tile del buffer de tiles
void GeneradorPantallas::actualizaTile(int tile, TileInfo *tileDesc)
{
	assert ((tile >= 0) && (tile < 0x100));

	int newProfX = datosBloque[15];
	int newProfY = datosBloque[16];

	for (int i = 1; i < nivelesProfTiles; i++){
		// obtiene los valores de mayor profundidad de esa entrada
		int oldProfX = tileDesc->profX[i];
		int oldProfY = tileDesc->profY[i];
		int oldTile = tileDesc->tile[i];

		// si el nuevo elemento que se dibuja en este tile tiene menor profundidad que el elemento que estaba
		// antes en este tile, ajusta la profundidad del elemento anterior a la profundidad del elemento
		if (newProfX < oldProfX){
			if (newProfY < oldProfY){
				oldProfX = newProfX;
				oldProfY = newProfY;
			}
		}
	
		// pasa los datos anteriores de mayor profundidad a la capa de menor profundidad
		tileDesc->profX[i - 1] = oldProfX;
		tileDesc->profY[i - 1] = oldProfY;
		tileDesc->tile[i - 1] = oldTile;
	}

	// graba los nuevos datos de mayor profundidad
	tileDesc->profX[nivelesProfTiles - 1] = newProfX;
	tileDesc->profY[nivelesProfTiles - 1] = newProfY;
	tileDesc->tile[nivelesProfTiles - 1] = tile;
}

// si el tile es visible, actualiza el buffer de tiles
void GeneradorPantallas::grabaTile(int tile)
{
	// comprueba si el tile es de la parte central, trasladando la parte central al origen
	int posX = tilePosX - 8;
	int posY = tilePosY - 8;

	if ((posX < 0) || (posX >= 16)) return;
	if ((posY < 0) || (posY >= 20)) return;

	// actualiza la información de esa entrada del tile en el buffer de tiles
	actualizaTile(tile, &bufferTiles[posY][posX]);
}

/////////////////////////////////////////////////////////////////////////////
// operaciones sobre la pila
/////////////////////////////////////////////////////////////////////////////

// mete un dato en la pila
void GeneradorPantallas::push(int data)
{
	assert(posPila < 64);

	pila[posPila] = data;
	posPila++;
}

// saca un dato en la pila
int GeneradorPantallas::pop()
{
	assert(posPila > 0);

	posPila--;
	return pila[posPila];
}

/////////////////////////////////////////////////////////////////////////////
// operaciones sobre registros y expresiones del generador de bloques
/////////////////////////////////////////////////////////////////////////////

// obtiene un valor inmediato o el contenido de un registro
int GeneradorPantallas::leeDatoORegistro(int *posReg)
{
	// lee un dato del buffer
	int dato = roms[comandosBloque];
	comandosBloque++;

	// si el dato es menor que 0x60, es un valor inmediato
	if (dato < 0x60){
		return dato;
	}

	// el 0x82 es un marcador que indica que hay que devolver el siguiente byte
	if (dato == 0x82){
		dato = roms[comandosBloque];
		comandosBloque++;

		return dato;
	}

	// si se cambió el sentido de las x, intercambia los registros 0x70 y 0x71
	if (dato >= 0x70){
		dato = dato ^ estadoOpsX[3];
	}

	// en otro caso, es una lectura de un registro del buffer con los datos del bloque
	int pos = dato - 0x61;

	// si se nos solicitó la posición del registro, la graba
	if (posReg != 0){
		*posReg = pos;
	}

	// devuelve el dato que había en el registro
	return datosBloque[pos];
}

// obtiene el valor de un registro de generación el bloque actual
int GeneradorPantallas::obtenerRegistro(int reg, int *posReg)
{
	assert((reg != 0x82) && (reg > 0x60));

	// si se cambió el sentido de las x, intercambia los registros 0x70 y 0x71
	if (reg >= 0x70){
		reg = estadoOpsX[3];
	}

	int pos = reg - 0x61;

	// si se nos solicitó la posición del registro, la graba
	if (posReg != 0){
		*posReg = pos;
	}

	// devuelve el dato que había en el registro
	return datosBloque[pos];
}

// actualiza un registro de generación del bloque actual
int GeneradorPantallas::actualizaRegistro(int reg, int delta)
{
	assert((reg != 0x82) && (reg > 0x60));

	// si se cambió el sentido de las x, intercambia los registros 0x70 y 0x71
	if (reg >= 0x70){
		reg = reg ^ estadoOpsX[3];
	}

	int pos = reg - 0x61;

	// actualiza el registro y devuelve el nuevo valor
	datosBloque[pos] = datosBloque[pos] + delta;

	return datosBloque[pos];
}

// evalua una ristra de bytes calculando la expresión generada
int GeneradorPantallas::evaluaExpresion(int rdo)
{
	while (true){
		// lee un byte de datos
		int op = roms[comandosBloque];

		// si se ha terminado la expresión, sale
		if (op >= 0xc8){
			return rdo;
		}

		// 0x84 indica el cambio de signo de la expresión calculada
		if (op == 0x84){
			rdo = -rdo;
			comandosBloque++;
		} else {
			// en otro caso, suma un registro o valor inmediato
			rdo += (INT8)leeDatoORegistro(0);
		}
	}
}

/////////////////////////////////////////////////////////////////////////////
// métodos de dibujo del buffer de tiles
/////////////////////////////////////////////////////////////////////////////

// dibuja en pantalla el contenido del buffer de tiles desde el centro hacia fuera
void GeneradorPantallas::dibujaBufferTiles()
{
	// posición inicial en el buffer de tiles
	int x = 7;
	int y = 8;

	// obtiene acceso al temporizador
	TimingHandler *timer = elJuego->timer;

	// fija las variables de recorrido
	int abajo = 4;
	int derecha = 1;
	int arriba = abajo + 1;
	int izquierda = derecha + 1;

	// milisegundos que esperar entre iteraciones para ver el efecto
	const int retardo = 100;

	// repite mientras no se complete toda la pantalla visible
	while (abajo < 20){
		// guarda el instante actual de tiempo
		INT64 tIni = timer->getTime();

		// dibuja 4 tiras: una hacia abajo, otra a la derecha, otra hacia arriba y la otra a la izquierda
		dibujaTira(x, y, 0, 1,  abajo);
		dibujaTira(x, y, 1, 0,  derecha);
		dibujaTira(x, y, 0, -1,  arriba);
		dibujaTira(x, y, -1, 0, izquierda);

		// aumenta el tamaño del rectángulo que dibuja
		abajo += 2;
		derecha += 2;
		arriba += 2;
		izquierda += 2;

		// espera un poco para que se vea el resultado
		timer->sleep(retardo);
	}
}

// dibuja una tira de tiles
void GeneradorPantallas::dibujaTira(int &x, int &y, int deltaX, int deltaY, int veces)
{
	// para cada tile de la tira
	for (int i = 0; i < veces; i++){
		// por cada capa de profundidad
		for (int k = 0; k < nivelesProfTiles; k++){
			// obtiene el número de tile asociado a esta profundidad del buffer de tiles
			int tile = bufferTiles[y][x].tile[k];

			// si hay algún tile, lo dibuja
			if (tile != 0){
				dibujaTile(32 + x*16, y*8, tile);
			}
		}

		// pasa a la siguiente posición
		x = x + deltaX;
		y = y + deltaY;
	}
}

// dibuja un tile de 16x8 en la posición indicada
void GeneradorPantallas::dibujaTile(int x, int y, int num)
{
	assert((num >= 0x00) && (num < 0x100));

	// halla el desplazamiento del tile (cada tile ocupa 32 bytes)
	UINT8 *tileData = &roms[0x8300 + num*32];

	int numTabla = (num & 0x80) ? 2 : 0;

	// dibuja cada linea del tile
	for (int j = 0; j < 8; j++){
		// repite para 4 bytes (16 pixels)
		for (int i = 0; i < 4; i++){
			// lee un byte del gráfico (4 pixels)
			int data = *tileData;

			// para cada pixel del byte leido
			for (int k = 0; k < 4; k++){
				// obtiene el color del pixel
				int color = cpc6128->unpackPixelMode1(data, k);

				// obtiene el color del pixel en pantalla
				int oldColor = cpc6128->getMode1Pixel(x, y);

				// combina el color del pixel de pantalla con el nuevo
				color = (oldColor & mascaras[numTabla + 1][color]) | mascaras[numTabla][color];

				// pinta el color resultante
				cpc6128->setMode1Pixel(x, y, color);

				// avanza al siguiente pixel
				x++;
			}

			// avanza la posición del gráfico
			tileData++;
		}
		// pasa a la siguiente línea de pantalla
		x -= 16;
		y++;
	}
}


/////////////////////////////////////////////////////////////////////////////
// métodos de ayuda
/////////////////////////////////////////////////////////////////////////////

// obtiene la dirección de memoria que hay en una dirección de memoria
int GeneradorPantallas::obtenerDir(int direccion)
{
	UINT8 *aux = &roms[direccion];
	return aux[0] | (aux [1] << 8);
}

// genera las máscaras necesarias para combinar los gráficos
void GeneradorPantallas::generaMascaras()
{
	// rellena las tablas de las máscaras
	for (int i = 0; i < 4; i++){
		int bit0 = (i >> 0) & 0x01;
		int bit1 = (i >> 1) & 0x01;

		// tabla de máscaras or (0->0, 1->1, 2->0, 3->3)
		mascaras[0][i] = ((bit1 & bit0) << 1) | bit0;

		// tabla de máscaras and (0->0, 1->0, 2->3, 3->0)
		mascaras[1][i] = (((bit1 ^ bit0) & bit1) << 1) | ((bit1 ^ bit0) & bit1);

		// tabla de máscaras or (0->0, 1->0, 2->2, 3->3)
		mascaras[2][i] = ((bit1) << 1) | (bit1 & bit0);

		// tabla de máscaras and (0->0, 1->3, 2->0, 3->0)
		mascaras[3][i] = (((bit1 ^ bit0) & bit0) << 1) | ((bit1 ^ bit0) & bit0);
	}
}

// prepara el buffer de tiles y limpia el área de juego
void GeneradorPantallas::limpiaPantalla(int color)
{
	// limpia el buffer de tiles
	for (int j = 0; j < 20; j++){
		for (int i = 0; i < 16; i++){
			for (int k = 0; k < nivelesProfTiles; k++){
				bufferTiles[j][i].profX[k] = 0;
				bufferTiles[j][i].profY[k] = 0;
				bufferTiles[j][i].tile[k] = 0;
			}
		}
	}

	// limpia el área de juego
	cpc6128->fillMode1Rect(32, 0, 256, 160, color);
}
