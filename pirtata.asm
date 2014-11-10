; La versión pirata del juego tiene un cargador en basic:
; 
; 10 	Mode 0
; 	Border 0
; 20 	For i = 0 to 15
; 		Read a$
; 		Ink i,Val(a$)
; 	Next
; 30	Memory &9fff
; 	Load "abadia.bin", &a000
; 40	Call &A000
; 50	Data 	16, 00, 26, 24, 10, 15, 01, 00, 
; 				00, 00, 24, 00, 14, 03 ,00, 20
; 
;  que se encarga de fijar la paleta (que por cierto, no es la misma que la del juego original) y saltar al código siguiente,
; que carga los ficheros en los que han troceado los datos de las pistas del juego original en las mismas posiciones de memoria
; que la versión original

A000: F3          di				; deshabilita las interrupciones
A001: 21 0F A0    ld   hl,$A00F		; origen de los datos (abadia.bin)
A004: 11 50 00    ld   de,$0050		; direccion de destino
A007: 01 B0 00    ld   bc,$00B0		; longitud de los datos a copiar
A00A: ED B0       ldir				; copia los bytes del origen al destino
A00C: C3 50 00    jp   $0050		; salta a los datos copiados

A00F: ; datos copiados a 0x0050-0x00ff

; datos copiados desde abadia.bin y a los que se salta al inicio
0050: ld   hl,$C000					; apunta a la memoria de video
0053: ld   ($00F6),hl				; guarda direccion de destino en 0x00f6
0056: ld   a,$30
0058: ld   ($00F5),a				; coloca un 0 en el nombre del fichero (abadia0.bin)
005B: call $00D6					; muestra la pantalla de presentacion
005E: ld   bc,$7FC7					; fija configuracion 7 (0, 7, 2, 3)
0063: ld   hl,$4000
0066: ld   ($00F6),hl				; guarda direccion de destino en 0x00f6
0069: ld   a,$38
006B: ld   ($00F5),a				; coloca un 8 en el nombre del fichero (abadia8.bin)
006E: call $00D6					; carga el archivo en el banco 7
0071: ld   bc,$7FC6					; fija configuracion 6 (0, 6, 2, 3)
0074: out  (c),c
0076: call $00D6					; carga el archivo (abadia7.bin)
0079: ld   bc,$7FC5					; fija configuracion 5 (0, 5, 2, 3)
007C: out  (c),c
007E: call $00D6					; carga el archivo (abadia6.bin)
0081: ld   bc,$7FC4					; fija configuracion 4 (0, 4, 2, 3)
0084: out  (c),c
0086: call $00D6					; carga el archivo (abadia5.bin)
0089: ld   bc,$7FC0					; fija configuracion 0 (0, 1, 2, 3)
008C: out  (c),c
008E: ld   a,$32
0090: ld   ($00F5),a				; coloca un 2 en el nombre del fichero (abadia2.bin)
0093: call $00D6					; carga el archivo
0096: ld   hl,$0100
0099: ld   ($00F6),hl				; guarda la dirección de destino en 0x00f6
009C: call $00D6					; carga el archivo (abadia1.bin)

009F: di
00A0: ld   hl,$C7D0					; apunta a la memoria de video
00A3: ld   de,$0050					; apunta al destino
00A6: ld   bc,$0030
00A9: ldir							; copia unos bytes que lee de la pantalla de presentación (???)

00AB: ld   hl,$C000					; pone como destino 0xc000
00AE: ld   ($00F6),hl
00B1: ld   a,$33					; coloca un 3 en el nombre del fichero (abadia3.bin)
00B3: ld   ($00F5),a
00B6: call $00D6					; carga el archivo
00B9: di
00BA: ld   sp,$0100					; coloca la pila en 0x0100
00BD: ld   hl,$C000					; copia lo recien leido al hueco que había
00C0: ld   de,$8000
00C3: ld   bc,$4000
00C6: ldir
00C8: ld   hl,$0050					; copia lo que grabó de abadia0.bin a lo copiado de abadia3.bin (???)
00CB: ld   de,$C7D0
00CE: ld   bc,$0030
00D1: ldir

00D3: jp   $0400					; salta al inicio real del juego

00D6: ld   b,$07					; longitud del nombre
00D8: ld   de,$C000					; buffer de destino                																																																				
00DB: ld   hl,$00EF					; direccion del nombre             																																																				
00DE: call $BC77					; abre buffer y lee direccion      																																																				
00E1: ld   hl,($00F6)				; obtiene puntero de destino       																																																				
00E4: call $BC83					; lee el fichero completo a memoria																																																				
00E7: call $BC7A					; cierra el archivo                																																																				
00EA: ld   hl,$00F5                                        																																																													
00ED: dec  (hl)						; decrementa el nombre de archivo  																																																													
00EE: ret

00EF: ABADIA
