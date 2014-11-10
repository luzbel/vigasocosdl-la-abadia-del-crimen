// MezcladorSprites.cpp
//
/////////////////////////////////////////////////////////////////////////////

#include <cassert>

#include "../systems/CPC6128.h"

#include "GeneradorPantallas.h"
#include "Juego.h"
#include "MezcladorSprites.h"
#include "Sprite.h"

using namespace Abadia;

/////////////////////////////////////////////////////////////////////////////
// inicialización y limpieza
/////////////////////////////////////////////////////////////////////////////

MezcladorSprites::MezcladorSprites(GeneradorPantallas *generador, UINT8 *buffer, int lgtudBuffer)
{
	genPant = generador;

	roms = elJuego->roms;
	cpc6128 = elJuego->cpc6128;

	bufferMezclas = buffer;
	lgtudBufferMezclas = lgtudBuffer;
}

MezcladorSprites::~MezcladorSprites()
{
}

/////////////////////////////////////////////////////////////////////////////
// dibujo de los sprites del juego, mezclándolos con los tiles
/////////////////////////////////////////////////////////////////////////////

void MezcladorSprites::mezclaSprites(Sprite **sprites, int num)
{
	// inicia la primera posición vacía del buffer de sprites
	sgtePosBuffer = 0;

	// inicialmente no hay nungún sprite que procesar
	numSprites = numSpritesRedib = 0;

	// recorre los sprites y comprueba si hay que dibujar alguno
	for (int i = num - 1; i >= 0; i--){
		if (sprites[i]->esVisible){
			// si el sprite es visible, lo mete en la lista
			listaSprites[numSprites] = i;
			numSprites++;

			// incrementa el contador de sprites que deben ser redibujados, indica
			if (sprites[i]->haCambiado){
				numSpritesRedib++;
			}
		}
	}

	// si no había ningún sprite que redibujar, sale
	if (numSpritesRedib == 0) return;

	int i = 1;
	bool huboIntercambio;

	// ordena los sprites ascendentemente según su profundidad usando el método de la burbuja mejorado
	do {
		// inicialmente no hay intercambios
		huboIntercambio = false;

		// recorre los elementos no ordenados
		for (int j = numSprites - 1; j >= i; j--){
			if (sprites[listaSprites[j - 1]]->profundidad > sprites[listaSprites[j]]->profundidad){
				// realiza un intercambio
				int aux = listaSprites[j - 1];
				listaSprites[j - 1] = listaSprites[j];
				listaSprites[j] = aux;

				huboIntercambio = true;
			}
		}

		i++;
	} while (huboIntercambio || (i <  numSprites));

	// recorre los sprites de la lista, calculando el área que debe dibujarse y mezclándolos en el buffer de sprites
	for (int i = 0; i < numSprites; i++){
		// obtiene un puntero al sprite que se está procesando
		Sprite *spr = sprites[listaSprites[i]];

		// indica que el sprite no se ha procesado todavía
		spr->seHaProcesado = false;

		// si el sprite no ha cambiado, pasa a procesar el siguiente sprite
		if (!spr->haCambiado) continue;

		// calcula el area a redibujar según los tiles que contienen el sprite
		spr->ajustaATiles();

		// ajusta las dimensiones del area a redibujar para que abarque el sprite antiguo
		spr->ampliaDimViejo();

		// calcula el desplazamiento correspondiente a la posición inicial en el buffer de tiles. 
		// las coordenadas del sprite (32, 40) se corresponden al primer pixel del buffer de tiles
		bufTilesPosX = (4*spr->posXTile/16) - (32/16);
		bufTilesPosY = (spr->posYTile/8) - (40/8);

		// guarda la dirección del buffer de sprites obtenida
		spr->despBuffer = sgtePosBuffer;
		sgtePosBuffer = sgtePosBuffer + spr->anchoFinal*spr->altoFinal*4;

		// si no hay sitio para el sprite en el buffer de sprites, vuelca a pantalla los sprites procesados y repite el proceso con el resto
		if (sgtePosBuffer > lgtudBufferMezclas){
			// si el primer sprite es demasiado grande y no cabe en el buffer, error
			assert(sgtePosBuffer != 0);
			assert(spr->anchoFinal*spr->altoFinal*4 < lgtudBufferMezclas);

			postProcesaSprites(sprites, num);

			return;
		}

		// si hay espacio en el buffer de sprites, el sprite se procesa
		spr->seHaProcesado = true;

		// limpia la zona asignada del buffer de sprites
		memset(&bufferMezclas[spr->despBuffer], 0, spr->anchoFinal*spr->altoFinal*4);

		// empieza a dibujar desde la mínima profundidad
		int profMinX = 0, profMinY = 0;

		// recorre los sprites de la lista, mezclando la parte que se vea con el sprite que se está procesando
		for (int j = 0; j < numSprites; j++){
			// obtiene un puntero al sprite que se va a mezclar
			Sprite *sprAMezclar = sprites[listaSprites[j]];

			// si el sprite a mezclar va a desaparecer, pasa al siguiente sprite
			if (sprAMezclar->desaparece) continue;

			int lgtudClipX, lgtudClipY, dist1X, dist2X, dist1Y, dist2Y;

			// comprueba si el sprite a mezclar puede verse en la zona del sprite que se está dibujando
			if (!recortaSprite(spr->posXTile, spr->anchoFinal, sprAMezclar->posXPant, sprAMezclar->ancho, lgtudClipX, dist1X, dist2X)){
				continue;
			}

			// comprueba si el sprite a mezclar puede verse en la zona del sprite que se está dibujando
			if (!recortaSprite(spr->posYTile, spr->altoFinal, sprAMezclar->posYPant, sprAMezclar->alto, lgtudClipY, dist1Y, dist2Y)){
				continue;
			}

			// si llega aquí es porque alguna parte del sprite es visible

			// vuelca al buffer de sprites los tiles no dibujados que están detrás del sprite actual
			dibujaTilesEntreProfundidades(spr, profMinX, profMinY, sprAMezclar->posXLocal + 1, sprAMezclar->posYLocal + 1, spr->despBuffer, false);

			// actualiza el límite inferior de profundidad para la siguiente iteración
			profMinX = sprAMezclar->posXLocal + 1;
			profMinY = sprAMezclar->posYLocal + 1;

			// dibuja la parte visible del sprite que se está mezclando en el área ocupada por el sprite actual
			sprAMezclar->dibuja(spr, bufferMezclas, lgtudClipX, lgtudClipY, dist1X, dist2X, dist1Y, dist2Y);
		}

		// si falta algún tile por superponer al sprite, lo dibuja y limpia las marcas del buffer de tiles
		dibujaTilesEntreProfundidades(spr, profMinX, profMinY, 0xfd, 0xfd, spr->despBuffer, true);
	}

	// vuelca a pantalla los procesados
	postProcesaSprites(sprites, num);
}

/////////////////////////////////////////////////////////////////////////////
// mezcla de tiles al buffer de sprites
/////////////////////////////////////////////////////////////////////////////

// vuelca al buffer de sprites los tiles no dibujados que están detrás del sprite actual
void MezcladorSprites::dibujaTilesEntreProfundidades(Sprite *spr, int profMinX, int profMinY, int profMaxX, int profMaxY, int desp, bool ultimaPasada)
{
	// calcula el número de tiles a procesar
	int numTilesX = spr->anchoFinal/4;
	int numTilesY = spr->altoFinal/8;

	// recorre los tiles en y que ocupa el sprite que se está procesando
	for (int j = 0; j < numTilesY; j++){
		int despX = desp;

		// recorre los tiles en x que ocupa el sprite que se está procesando
		for (int i = 0; i < numTilesX; i++){
			// si está dentro del buffer de tiles
			if (estaEnBufferTiles(bufTilesPosX + i, bufTilesPosY + j)){
				// obtiene la entrada actual del buffer de tiles
				GeneradorPantallas::TileInfo *ti = &genPant->bufferTiles[bufTilesPosY + j][bufTilesPosX + i];

				// inicialmente en esta llamada no se ha pintado en esta posición del buffer de tiles
				bool haPintado = false;

				// recorre las distintas capas de tiles del buffer de tiles
				for (int k = 0; k < GeneradorPantallas::nivelesProfTiles; k++){
					// si hay algún tile en la entrada actual
					if (ti->tile[k] != 0){
						bool visible = true;

						// si en esta llamada no se ha pintado en esta posición del buffer de tiles, 
						// comprueba si hay que pintar el tile que hay en esta capa de profundidad. 
						// Si se ha pintado en esta llamada y el tile de esta capa se había pintado
						// en otra iteración anterior, lo combina sin comprobar la profundidad
						if (!(haPintado && ((ti->profX[k] & 0x80) == 0x80))){
							// comprueba si el tile supera el límite inferior de profundidad
							if (ti->profX[k] < profMinX){
								if (ti->profY[k] < profMinY){
									visible = false;
								}
							}

							// comprueba si el tile no rebasa el límite superior de profundidad
							if (visible){
								if (ti->profY[k] >= profMaxY){
									visible = false;
								} else if (ti->profX[k] >= profMaxX){
									visible = false;
								}
							}
						} else {
							if (haPintado && ((ti->profX[k] & 0x80) == 0x80)){
								// combina el tile actual con lo que hay en el buffer de sprites
								combinaTile(spr, ti->tile[k], despX);
							}
						}

						// si el tile está entre los límites de profundidad y no se ha dibujado todavía
						if (visible && ((ti->profX[k] & 0x80) == 0)){
							// marca el tile como dibujado
							ti->profX[k] |= 0x80;

							// indica que en esta llamada ha pintado algún tile para esta posición del buffer de tiles
							haPintado = true;

							// combina el tile actual con lo que hay en el buffer de sprites
							combinaTile(spr, ti->tile[k], despX);
						}
					}

					if (ultimaPasada){
						// limpia la marca de dibujado
						ti->profX[k] &= 0x7f;
					}
				}
			}

			// avanza al pixel del siguiente tile en x dentro del buffer de sprites
			despX = despX + 16;
		}

		// avanza al pixel del siguiente tile en y dentro del buffer de sprites
		desp = desp + spr->anchoFinal*4*8;
	}
}

// combina un tile con lo que hay en la posición actual del buffer de sprites
void MezcladorSprites::combinaTile(Sprite *spr, int tile, int despBufSprites)
{
	assert ((tile >= 0) && (tile < 0x100));

	// halla el desplazamiento del tile (cada tile ocupa 32 bytes)
	UINT8 *tileData = &roms[0x8300 + tile*32];

	// halla el desplazamiento de destino
	UINT8 *dest = &bufferMezclas[despBufSprites];

	// calcula el desplazamiento a la siguiente línea del buffer de sprites
	int despSgteLinea = spr->anchoFinal*4 - 16;

	// los tiles < 0x0b no tienen ninguna transparencia
	if (tile < 0x0b){
		// dibuja cada linea del tile
		for (int j = 0; j < 8; j++){
			// repite para 4 bytes (16 pixels)
			for (int i = 0; i < 4; i++){
				// lee un byte del gráfico (4 pixels)
				int data = *tileData;

				// para cada pixel del byte leido
				for (int k = 0; k < 4; k++){
					// obtiene el color del pixel
					*dest = cpc6128->unpackPixelMode1(data, k);
					dest++;
				}
	
				// avanza la posición del gráfico
				tileData++;
			}
			// avanza a la siguiente línea del sprite en el buffer de sprites
			dest += despSgteLinea;
		}
	} else {
		int numTabla = (tile & 0x80) ? 2 : 0;

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

					// obtiene el color del pixel en el buffer de sprites
					int oldColor = *dest;

					// combina el color del pixel del buffer de sprites con el nuevo
					*dest = (oldColor & genPant->mascaras[numTabla + 1][color]) | genPant->mascaras[numTabla][color];
					dest++;
				}

				// avanza la posición del gráfico
				tileData++;
			}
			// avanza a la siguiente línea del sprite en el buffer de sprites
			dest += despSgteLinea;
		}
	}
}

/////////////////////////////////////////////////////////////////////////////
// postprocesado de sprites
/////////////////////////////////////////////////////////////////////////////

void MezcladorSprites::postProcesaSprites(Sprite **sprites, int num)
{
	// recorre los sprites y comprueba si hay que dibujar alguno
	for (int i = 0; i < num; i++){
		// si el sprite no es visible, pasa al siguiente
		if (!sprites[i]->esVisible) continue;

		// si el sprite no se ha procesado, pasa al siguiente
		if (!sprites[i]->seHaProcesado) continue;

		// vuelca el buffer del sprite a pantalla, recortando lo que no sea visible
		vuelcaBufferAPantalla(sprites[i]);

		// indica que ya se ha dibujado el sprite
		sprites[i]->haCambiado = false;
		sprites[i]->seHaProcesado = false;

		// si el sprite es de un objeto que desaparece, marca el sprite como inactivo
		if (sprites[i]->desaparece){
			sprites[i]->desaparece = false;
			sprites[i]->esVisible = false;
		}
	}

	// si queda algún sprite por procesar lo dibuja
	mezclaSprites(sprites, num);
}

// vuelca el contenido del buffer de sprites a pantalla
void MezcladorSprites::vuelcaBufferAPantalla(Sprite *spr)
{
	int posX = spr->posXTile;
	int posY = spr->posYTile;
	int ancho = spr->anchoFinal;
	int alto = spr->altoFinal;
	int desp = spr->despBuffer;
	int distXSgteLinea = 0;

	// si la posición inicial en y está fuera del área visible, sale
	if (posY >= 200) return;

	// comprueba la distancia en y desde el inicio del sprite al inicio de la pantalla
	int distY = posY - 40;

	// si el sprite empieza antes que el inicio de la pantalla, recorta en y
	if (distY < 0){
		distY = -distY;

		// si no se ve ningúna parte del sprite en pantalla, sale
		if (distY >= alto){
			return;
		}

		// recorta la posición inicial y el alto
		alto = alto - distY;
		posY = 0;

		// avanza las lineas no visibles del sprite
		desp += spr->anchoFinal*distY*4;
	} else {
		posY = posY - 40;
	}

	// si la posición inicial en x está fuera del área visible, sale
	if (posX >= ((32 + 256)/4)) return;

	// comprueba la distancia en x desde el inicio del sprite al inicio de la pantalla
	int distX = posX - (32/4);

	if (distX < 0){
		distX = -distX;

		// si no se ve ningúna parte del sprite en pantalla, sale
		if (distX >= ancho){
			return;
		}

		// recorta la posición inicial y el ancho
		ancho = ancho - distX;
		posX = 0;

		// avanza los pixels no visibles del sprite
		desp += distX*4;

		distXSgteLinea += distX*4;
	} else {
		posX = posX - (32/4);
	}

	// si el sprite es más ancho que la zona visible de pantalla, lo recorta
	if ((posX + ancho) >= (256/4)){
		distX = posX + ancho - (256/4);
		ancho = ancho - distX;

		distXSgteLinea += distX*4;
	}

	// si el sprite es más alto que la zona visible de pantalla, lo recorta
	if ((posY + alto) >= 160){
		distY = posY + alto - 160;
		alto = alto - distY;
	}

	// convierte la posición x a pixels
	posX = posX*4 + 32;

	// obtiene un puntero al primer pixel visible
	UINT8 *src = &bufferMezclas[desp];

	// dibuja la parte visible del sprite
	for (int j = 0; j < alto; j++){
		for (int i = 0; i < ancho*4; i++){
			cpc6128->setMode1Pixel(posX + i, posY + j, *src);
			src++;
		}

		// salta los pixels recortados en x
		src += distXSgteLinea;
	}
}

/////////////////////////////////////////////////////////////////////////////
// métodos auxiliares
/////////////////////////////////////////////////////////////////////////////

// comprueba si el sprite a mezclar puede verse en la zona del sprite que se está dibujando
// si es así lo recorta al área que se está dibujando y devuelve true. En otro caso, devuelve false
bool MezcladorSprites::recortaSprite(int posVis, int lgtudVis, int pos, int lgtud, int &lgtudClip, int &dist1, int &dist2)
{
	// comprueba que sprite primero
	int dif = posVis - pos;

	// si los 2 sprites empiezan en la misma coordenada
	if (dif == 0){
		dist1 = dist2 = 0;

		lgtudClip = lgtudVis;

		// si la longitud del sprite original es mayor que la longitud del sprite a mezclar, recorta la longitud
		if (lgtudVis > lgtud){
			lgtudClip = lgtud;
		}
	} else if (dif > 0){
		// si el sprite a mezclar empieza antes que el original

		// si el sprite a mezclar termina antes de que empiece el sprite original, queda fuera del área visible
		if (dif >= lgtud){
			return false;
		}

		dist1 = 0;
		dist2 = dif;	// distancia del sprite a mezclar al sprite original

		// si el sprite a mezclar termina antes de que lo haga el sprite original, recorta la longitud
		if ((dif + lgtudVis) >= lgtud){
			lgtudClip = lgtud - dif;
		} else {
			// el sprite a mezclar ocupa toda la zona del sprite original, por lo que recorta la longitud
			lgtudClip = lgtudVis; 
		}
	} else {
		// si el sprite original empieza antes que el que hay que mezclar
		dif = -dif;

		// si el sprite a mezclar empieza después de que termine el sprite original, queda fuera del área visible
		if (dif >= lgtudVis){
			return false;
		}

		dist1 = dif;	// distancia de la posición original al inicio del sprite a mezclar
		dist2 = 0;

		// si el sprite a mezclar no termina antes de que lo haga el sprite original, recorta la longitud
		if ((lgtudVis - dif) <= lgtud){
			lgtudClip = lgtudVis - dif;
		} else {
			// el sprite a mezclar está contenido en el sprite original
			lgtudClip = lgtud; 
		}
	}

	return true;
}

// comprueba si una posición del buffer de tiles es válida
bool MezcladorSprites::estaEnBufferTiles(int bufPosX, int bufPosY)
{
	if (bufPosX < 0) return false;
	if (bufPosX >= 16) return false;

	if (bufPosY < 0) return false;
	if (bufPosY >= 20) return false;

	return true;
}
