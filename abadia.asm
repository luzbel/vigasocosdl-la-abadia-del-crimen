; --------------- Desensamblado comentado del juego "La abadía del crimen" para Amstrad CPC 6128, por Manuel Abadía ------------------
;
; Hay 2 versiones del juego circulando, la original, que se carga con '|cpm', y la pirata, que se carga con 'run "abadia'
; Las versión pirata es igual que la original, excepto que la pantalla de presentación usa otros colores para la paleta, y que los
; datos del juego no están guardados directamente en las pistas como en el original, sino que el disco tiene un sistema de ficheros.
; Otra desventaja de la versión pirata es que como el juego permite grabar la partida, y lo hace en los cilindros donde estaba la
; información en el juego original, pero como los datos en la versión pirata no están en el mismo sitio y el disco no tiene el mismo
; formato, no se graban correctamente.
;
; Para entender como funciona el juego, hay una serie de archivos que acompañan a éste. Estos archivos son:
; * mapamemoria.txt -> contiene el mapa de memoria del juego
; * maparoms.txt -> contiene el mapa de memoria de los archivos del juego
; * mapadisco.txt -> contiene información sobre que datos y de que manera se guardan en el disco original del juego
; * pista0.asm -> contiene el código de la pista 0 del disco del juego que carga los datos a memoria y salta al inicio del juego
; * pirata.asm -> contiene el código para cargar los datos del juego y saltar al inicio del juego en la versión pirata
;
; Para nombrar las zonas de datos, se usa el nombre del archivo que contiene los datos en el juego pirata, puesto que es más manejable
; decir que coloca en 0x4000-0x7fff los datos de abadia7.bin a decir que carga los datos de las pistas 0x12-0x16
;
; Durante el arranque del juego, los bancos de memoria del amstrad han quedado en el siguiente estado:
; 0 -> abadia1.bin (a partir de 0x100)
; 1 -> abadia2.bin
; 2 -> abadia3.bin
; 3 -> abadia0.bin (memoria de pantalla)
; 4 -> abadia5.bin
; 5 -> abadia6.bin
; 6 -> abadia7.bin
; 7 -> abadia8.bin
;
; La configuración de memoria usada normalmente a lo largo del programa es la (0, 1, 2, 3)
; A lo largo de todo el juego, en las posiciones 0x0000-0x3fff, 0x8000-0xbfff y 0xc000-0xffff se mapean los bancos 0, 2 y 3 respectivamente
; En la zona 0x4000-0x7fff suele estar mapeado el banco 1, aunque cuando es necesario se mapean los bancos 4, 5, 6 y 7
; El banco 4 contiene un depurador para el Z80, que supongo fue usado por Paco Menendez para depurar el juego. El código comentado de
; este depurador está disponible en el archivo depurador.asm y el mapa de memoria asociado está en el fichero depmem.txt
;
; Una vez completada la carga, se salta a 0x0400, que es donde realmente empieza el juego
;
; NOTA: algunos comentarios pueden estar desfasados o ser incorrectos, pero no he tenido tiempo de repasar todo el código
; ------------------------------------------------------------------------------------------------------------------




; abadia1.bin (0x0100-0x3fff)
; -------------- de 0x0103 a 0x03ff hay código que se sobreescribe con datos del programa --------------------------
0100: F3          di
0101: 31 00 01    ld   sp,$0100		; pone la pila
0104: 21 00 03    ld   hl,$0300		; mete como dirección de retorno 0x0300 (??? no hay código válido en 0x0300)
0107: E5          push hl
0108: 01 8D 7F    ld   bc,$7F8D		; gate array -> 10001101 (select screen mode, rom cfig and int control)
010B: ED 49       out  (c),c		;  selecciona el modo 1 y deshabilita la rom superior e inferior
010D: CD 82 01    call $0182		; escribe la paleta de colores
		00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00	; color del borde y de las plumas (del 15 al 0)

0121: 3E 01       ld   a,$01
0123: 01 7E FA    ld   bc,$FA7E		; activa el motor de la unidad de disco
0126: ED 79       out  (c),a
0128: 3E 03       ld   a,$03
012A: CD B5 01    call $01B5		; retardo a veces

012D: 01 C7 01    ld   bc,$01C7		; pista inicial = 1, configuración de memoria 7 (0, 7, 2, 3)
0130: 21 FF FF    ld   hl,$FFFF		; los datos empiezan a copiarse desde 0xffff hacia abajo
0133: 3E 11       ld   a,$11		; copia en 0xc000-0xffff abadia0.bin en 0x8000-0xbfff abadia3, en 0x4000-0x7fff abadia8.bin y en 0x0100-0x3fff abadia1.bin
0135: CD 5C 01    call $015C		; lee datos del disco desde a pistas desde la pista b, fijando la configuración de memoria indicada por c, y guardando los datos en hl (hacia abajo)
0138: 01 C6 12    ld   bc,$12C6		; copia en el banco 6 (pistas 0x12-0x16) (abadia7.bin)
013B: CD 57 01    call $0157		; lee datos del disco desde la pista b hasta la pista b+4, fijando la configuración de memoria indicada por c, y guardando los datos en 0x4000-0x7fff
013E: 01 C5 17    ld   bc,$17C5		; copia en el banco 5 (pistas 0x17-0x1b) (abadia6.bin)
0141: CD 57 01    call $0157		; lee datos del disco desde la pista b hasta la pista b+4, fijando la configuración de memoria indicada por c, y guardando los datos en 0x4000-0x7fff
0144: 01 C4 1C    ld   bc,$1CC4		; copia en el banco 4 (pistas 0x1c-0x20) (abadia5.bin)
0147: CD 57 01    call $0157		; lee datos del disco desde la pista b hasta la pista b+4, fijando la configuración de memoria indicada por c, y guardando los datos en 0x4000-0x7fff
014A: 01 C0 21    ld   bc,$21C0		; copia en el banco 0 (pistas 0x21-0x25) (abadia2.bin)
014D: CD 57 01    call $0157		; lee datos del disco desde la pista b hasta la pista b+4, fijando la configuración de memoria indicada por c, y guardando los datos en 0x4000-0x7fff
0150: AF          xor  a
0151: 01 7E FA    ld   bc,$FA7E
0154: ED 79       out  (c),a		; apaga el motor de la unidad de disco
0156: C9          ret				; salta a 0x0300

; lee datos del disco desde la pista b hasta la pista b+4, fijando la configuración de memoria indicada por c, y guardando los datos en 0x4000-0x7fff
0157: 21 FF 7F    ld   hl,$7FFF		; copiar en 0x4000-0x7fff
015A: 3E 05       ld   a,$05		; copia 5 pistas

; lee datos del disco desde a pistas desde la pista b, fijando la configuración de memoria indicada por c, y guardando los datos en hl (hacia abajo)
; a = número de pistas a copiar
; b = pista inicial
; c = configuración de memoria a fijar
; hl = posición de memoria donde empezar a copiar los datos (copia desde arriba hacia abajo)
015C: 80          add  a,b
015D: 32 7E 01    ld   ($017E),a	; modifica una instrucción con la última pista a leer
0160: 78          ld   a,b			; a = pista inicial
0161: 06 7F       ld   b,$7F
0163: ED 49       out  (c),c		; fija la configuración de memoria que se le pasa en c
0165: 01 7E FB    ld   bc,$FB7E		; bc = registro principal de la unidad de disco

0168: F5          push af
0169: 32 25 02    ld   ($0225),a	; modifica la pista del comando
016C: CD 96 01    call $0196		; escribe un comando de búsqueda de la pista a
016F: 11 22 02    ld   de,$0222		; apunta a los datos del comando de lectura
0172: CD C0 01    call $01C0		; escribe el comando apuntado por de a la unidad
0175: CD 18 02    call $0218		; lee los bytes de la unidad de disco y los copia a memoria de forma descendente
0178: CD CD 01    call $01CD		; lee los bytes que manda la unidad de disco después de un comando, y los guarda en un buffer
017B: F1          pop  af
017C: 3C          inc  a			; avanza a la siguiente pista
017D: FE 12       cp   $12			; instrucción modificada desde fuera con la última pista a leer
017F: 20 E7       jr   nz,$0168
0181: C9          ret

; escribe la paleta de colores
0182: E1          pop  hl			; obtiene la dirección de retorno
0183: 3E 11       ld   a,$11
0185: 06 7F       ld   b,$7F		; selección de pluma y borde
0187: 4F          ld   c,a
0188: 0D          dec  c
0189: ED 49       out  (c),c		; selecciona una pluma o un borde
018B: 4E          ld   c,(hl)
018C: 23          inc  hl
018D: CB F1       set  6,c
018F: ED 49       out  (c),c
0191: 3D          dec  a
0192: 20 F3       jr   nz,$0187		; repite hasta completar los colores
0194: E5          push hl
0195: C9          ret

; escribe un comando de búsqueda de la pista a
0196: F5          push af
0197: 3E 0F       ld   a,$0F		; comando de búsqueda
0199: CD F8 01    call $01F8		; espera a que la unidad esté lista, y si se puede, se mandan datos
019C: AF          xor  a			; cabeza 0, unidad 0
019D: CD F8 01    call $01F8		; espera a que la unidad esté lista, y si se puede, se mandan datos
01A0: F1          pop  af			; recupera la pista a buscar
01A1: CD F8 01    call $01F8		; espera a que la unidad esté lista, y si se puede, se mandan datos
01A4: 3E 01       ld   a,$01
01A6: 11 20 4E    ld   de,$4E20
01A9: CD B5 01    call $01B5		; pequeño retardo
01AC: 3E 08       ld   a,$08		; comando para obtener información del estado
01AE: CD F8 01    call $01F8		; espera a que la unidad esté lista, y si se puede, se mandan datos
01B1: CD CD 01    call $01CD		; lee los bytes que manda la unidad de disco después de un comando, y los guarda en un buffer
01B4: C9          ret

; espera una cantidad de tiempo proporcional a a y de
01B5: F5          push af
01B6: 1B          dec  de
01B7: 7B          ld   a,e
01B8: B2          or   d
01B9: 20 FB       jr   nz,$01B6		; mientras de no sea 0, lo decrementa
01BB: F1          pop  af
01BC: 3D          dec  a			; repite a veces
01BD: 20 F6       jr   nz,$01B5
01BF: C9          ret

; escribe el comando apuntado por de a la unidad
01C0: 1A          ld   a,(de)		; lee el número de bytes del comando
01C1: 13          inc  de
01C2: F5          push af			; guarda el número de bytes del comando
01C3: 1A          ld   a,(de)
01C4: CD F8 01    call $01F8		; espera a que la unidad esté lista, y si se puede, se mandan datos
01C7: 13          inc  de			; pasa a la siguiente posición
01C8: F1          pop  af
01C9: 3D          dec  a
01CA: 20 F6       jr   nz,$01C2		; repite hasta que se terminen los bytes del comando
01CC: C9          ret

; lee los bytes que manda la unidad de disco después de un comando, y los guarda en un buffer
01CD: E5          push hl
01CE: D5          push de
01CF: 16 00       ld   d,$00		; inicia el contador de bytes escritos
01D1: 21 64 00    ld   hl,$0064		; apunta a un buffer
01D4: E5          push hl
01D5: ED 78       in   a,(c)		; lee el registro de estado 0
01D7: FE C0       cp   $C0
01D9: 38 FA       jr   c,$01D5		; espera a que la unidad esté lista
01DB: 0C          inc  c			; apunta al registro de datos
01DC: ED 78       in   a,(c)		; lee el resultado del comando de búsqueda
01DE: 0D          dec  c			; apunta al registro de estado
01DF: 77          ld   (hl),a		; guarda el dato leido
01E0: 23          inc  hl
01E1: 14          inc  d
01E2: 3E 05       ld   a,$05		; espera un poco
01E4: 3D          dec  a
01E5: 20 FD       jr   nz,$01E4
01E7: ED 78       in   a,(c)		; espera a que termine la transferencia
01E9: E6 10       and  $10
01EB: 20 E8       jr   nz,$01D5
01ED: E1          pop  hl			; recupera la posición inicial del buffer
01EE: 7E          ld   a,(hl)		; comprueba el estado de la operación
01EF: E6 C0       and  $C0
01F1: 2B          dec  hl
01F2: 72          ld   (hl),d		; graba el número de bytes leidos
01F3: D1          pop  de
01F4: E1          pop  hl
01F5: C0          ret  nz			; si ha habido algún error, sale
01F6: 37          scf				; si la cosa ha ido bien, pone el flag de acarreo
01F7: C9          ret

; espera a que la unidad esté lista, y si se puede, se mandan datos
01F8: F5          push af
01F9: F5          push af
01FA: ED 78       in   a,(c)		; lee el registro de estado de la unidad
01FC: 87          add  a,a
01FD: 30 FB       jr   nc,$01FA		; espera a que el registro de datos esté listo para recibir o enviar datos
01FF: 87          add  a,a
0200: 30 03       jr   nc,$0205		; si hay que hacer una transferencia del procesador al registro de datos, salta
0202: F1          pop  af
0203: F1          pop  af
0204: C9          ret

; aquí llega si la unidad espera datos
0205: F1          pop  af			; recupera el valor
0206: 0C          inc  c			; apunta al registro de datos
0207: ED 79       out  (c),a		; escribe el valor en el registro de datos
0209: 0D          dec  c			; apunta al registro de control
020A: 3E 05       ld   a,$05
020C: 3D          dec  a
020D: 00          nop
020E: 20 FC       jr   nz,$020C		; espera un poco
0210: F1          pop  af
0211: C9          ret

; lee un byte de la unidad de disco y lo copia a memoria
0212: 0C          inc  c			; apunta al registro de datos
0213: ED 78       in   a,(c)		; lee un byte del sector seleccionado de la pista actual
0215: 77          ld   (hl),a		; lo guarda en memoria
0216: 0D          dec  c			; apunta al registro de estado
0217: 2B          dec  hl			; decrementa el puntero del buffer

; lee los bytes de la unidad de disco y los copia a memoria de forma descendente
0218: ED 78       in   a,(c)		; lee el registro de estado
021A: F2 18 02    jp   p,$0218
021D: E6 20       and  $20
021F: 20 F1       jr   nz,$0212		; si no se ha completado la operación de lectura, lee otro byte
0221: C9          ret

; datos de un comando de lectura
0222: 	09 -> número de bytes del comando
		66 -> comando de lectura de datos, doble densidad, monopista
		00 -> cabeza 0, unidad 0
		25 -> número de pista (modificada desde fuera)
		00 -> cabeza 0
		21 -> número de sector inicial de la lectura
		01 -> número de bytes por sector (en múltiplos de 0x100)
		2F -> número de sector final de la lectura
		0E -> longitud de separación (GAP3)
		1F -> no usado

; datos de un comando de escritura
022C: 	09 -> número de bytes del comando
		45 -> comando de escritura de datos, doble densidad, monopista
		00 -> cabeza 0, unidad 0
		11 -> número de pista
		00 -> cabeza 0
		21 -> número de sector inicial de la escritura
		01 -> número de bytes por sector (en múltiplos de 0x100)
		2F -> número de sector final de la escritura
		0E -> longitud de separación (GAP3)
		FF -> no usado

; ??? nunca se llama a esta rutina
0236: F3          di
0237: 3E 01       ld   a,$01
0239: 01 7E FA    ld   bc,$FA7E		; activa el motor de la unidad de disco
023C: ED 79       out  (c),a
023E: 3E 06       ld   a,$06
0240: CD B5 01    call $01B5		; retardo a veces

0243: CD D5 02    call $02D5		; recalibra la unidad de disco

0246: 31 00 01    ld   sp,$0100		; coloca la pila
0249: CD 21 01    call $0121		; carga todos los datos del juego
024C: 3E 12       ld   a,$12
024E: 32 7E 01    ld   ($017E),a	; modifica el valor de una rutina (última pista en leer de la lectura de datos)
0251: 31 00 01    ld   sp,$0100		; coloca la pila otra vez

0254: F3          di
0255: CD EF 02    call $02EF		; copia el cursor de 4x8 a la esquina superior izquierda de pantalla y guarda lo que ha sobreescrito de pantalla
0258: 3E 01       ld   a,$01
025A: 11 10 27    ld   de,$2710
025D: CD B5 01    call $01B5		; espera un rato
0260: CD EF 02    call $02EF		; quita el cursor de la esquina superior izquierda y restaura lo que había en la pantalla
0263: 3E 01       ld   a,$01
0265: 11 10 27    ld   de,$2710
0268: CD B5 01    call $01B5		; espera un rato
026B: CD 0C 03    call $030C		; comprueba si se ha pulsado el espacio
026E: 20 E4       jr   nz,$0254		; mientras no se haya pulsado el espacio, sigue mostrando el cursor parpadeando

0270: 3E 01       ld   a,$01
0272: 01 7E FA    ld   bc,$FA7E		; activa el motor de la unidad de disco
0275: ED 79       out  (c),a
0277: 3E 06       ld   a,$06
0279: CD B5 01    call $01B5		; retardo a veces
027C: CD D5 02    call $02D5		; recalibra la unidad de disco
027F: 01 C7 01    ld   bc,$01C7		; pista inicial = 1, configuración de memoria 7 (0, 7, 2, 3)
0282: 21 FF FF    ld   hl,$FFFF		; los datos empiezan a copiarse desde 0xffff hacia abajo
0285: 3E 11       ld   a,$11		; copia 0xc000-0xffff abadia0.bin, 0x8000-0xbfff abadia3, 0x4000-0x7fff abadia8.bin y 0x0100-0x3fff abadia1.bin a disco
0287: CD AF 02    call $02AF		; graba datos al disco desde a pistas desde la pista b, fijando la configuración de memoria indicada por c, y leyendo los datos de hl (hacia abajo)
028A: 01 C6 12    ld   bc,$12C6		; graba lo que hay en el banco 6 (pistas 0x12-0x16) (abadia7.bin)
028D: CD AA 02    call $02AA		; copia los datos al disco desde la pista b hasta la pista b+4, fijando la configuración de memoria indicada por c, y leyendo los datos en 0x4000-0x7fff
0290: 01 C5 17    ld   bc,$17C5		; graba lo que hay en el banco 5 (pistas 0x17-0x1b) (abadia6.bin)
0293: CD AA 02    call $02AA		; copia los datos al disco desde la pista b hasta la pista b+4, fijando la configuración de memoria indicada por c, y leyendo los datos en 0x4000-0x7fff
0296: 01 C4 1C    ld   bc,$1CC4		; graba lo que hay en el banco 4 (pistas 0x1c-0x20) (abadia5.bin)
0299: CD AA 02    call $02AA		; copia los datos al disco desde la pista b hasta la pista b+4, fijando la configuración de memoria indicada por c, y leyendo los datos en 0x4000-0x7fff
029C: 01 C0 21    ld   bc,$21C0		; graba lo que hay en el banco 0 (pistas 0x21-0x25) (abadia2.bin)
029F: CD AA 02    call $02AA		; copia los datos al disco desde la pista b hasta la pista b+4, fijando la configuración de memoria indicada por c, y leyendo los datos en 0x4000-0x7fff
02A2: AF          xor  a
02A3: 01 7E FA    ld   bc,$FA7E
02A6: ED 79       out  (c),a		; apaga el motor de la unidad de disco
02A8: 18 AA       jr   $0254		; salta a la rutina que espera a que se pulse espacio para volver a grabar los datos

; graba datos al disco desde la pista b hasta la pista b+4, fijando la configuración de memoria indicada por c, y leyendo los datos de 0x4000-0x7fff
02AA: 21 FF 7F    ld   hl,$7FFF
02AD: 3E 05       ld   a,$05

; graba datos al disco desde a pistas desde la pista b, fijando la configuración de memoria indicada por c, y leyendo los datos de hl (hacia abajo)
; a = número de pistas a grabar
; b = pista inicial
; c = configuración de memoria a fijar
; hl = posición de memoria donde empezar a coger los datos (graba desde arriba hacia abajo)
02AF: 80          add  a,b
02B0: 32 D1 02    ld   ($02D1),a	; modifica una instrucción con la última pista a grabar
02B3: 78          ld   a,b			; a = pista inicial
02B4: 06 7F       ld   b,$7F
02B6: ED 49       out  (c),c		; fija la configuración de memoria que se le pasa en c
02B8: 01 7E FB    ld   bc,$FB7E		; bc = registro principal de la unidad de disco
02BB: F5          push af
02BC: 32 2F 02    ld   ($022F),a	; modifica la pista del comando
02BF: CD 96 01    call $0196		; escribe un comando de búsqueda de la pista a
02C2: 11 2C 02    ld   de,$022C		; apunta a los datos del comando de escritura
02C5: CD C0 01    call $01C0		; escribe el comando apuntado por de a la unidad
02C8: CD 44 03    call $0344		; escribe los bytes de memoria a la unidad de disco
02CB: CD CD 01    call $01CD		; lee los bytes que manda la unidad de disco después de un comando, y los guarda en un buffer
02CE: F1          pop  af
02CF: 3C          inc  a			; avanza a la siguiente pista
02D0: FE 12       cp   $12			; instrucción modificada desde fuera con la última pista a grabar
02D2: 20 E7       jr   nz,$02BB
02D4: C9          ret

; recalibra la unidad de disco
02D5: 01 7E FB    ld   bc,$FB7E		; bc = registro principal de la unidad de disco
02D8: 3E 07       ld   a,$07		; comando para recalibrar la unidad
02DA: CD F8 01    call $01F8		; espera a que la unidad esté lista, y si se puede, se mandan datos
02DD: AF          xor  a			; unidad 0
02DE: CD F8 01    call $01F8		; espera a que la unidad esté lista, y si se puede, se mandan datos
02E1: 3E 03       ld   a,$03
02E3: CD B5 01    call $01B5		; espera a que la unidad esté lista, y si se puede, se mandan datos
02E6: 3E 08       ld   a,$08		; comando para obtener información del estado
02E8: CD F8 01    call $01F8		; espera a que la unidad esté lista, y si se puede, se mandan datos
02EB: CD CD 01    call $01CD		; lee los bytes que manda la unidad de disco después de un comando, y los guarda en un buffer
02EE: C9          ret

; copia un rectángulo de 4x8 pixels de un buffer a pantalla, y guarda lo que hay en la pantalla en el buffer
02EF: 21 00 C0    ld   hl,$C000		; apunta a pantalla
02F2: 11 04 03    ld   de,$0304		; apunta a un buffer

; copia un rectángulo de 4x8 pixels de de a hl, y guarda lo de hl en el de
02F5: 06 08       ld   b,$08		; 8 bytes (32 pixels)
02F7: 4E          ld   c,(hl)		; lee un byte de pantalla
02F8: 1A          ld   a,(de)		; lee un byte del buffer
02F9: 77          ld   (hl),a		; copia el byte del buffer a pantalla
02FA: 79          ld   a,c
02FB: 12          ld   (de),a		; copia el byte de pantalla al buffer
02FC: 13          inc  de			; pasa a la siguiente posición del buffer
02FD: 7C          ld   a,h
02FE: C6 08       add  a,$08		; pasa a la siguiente línea de pantalla
0300: 67          ld   h,a
0301: 10 F4       djnz $02F7
0303: C9          ret

; buffer para la rutina anterior
0304: 00 00 0F 0F F0 F0 FF FF

; comprueba si se ha pulsado el espacio
030C: F3          di
030D: 01 0E F4    ld   bc,$F40E		; 1111 0100 0000 1110 (8255 PPI puerto A)
0310: ED 49       out  (c),c
0312: 06 F6       ld   b,$F6
0314: ED 78       in   a,(c)
0316: E6 30       and  $30
0318: 4F          ld   c,a
0319: F6 C0       or   $C0
031B: ED 79       out  (c),a		; operación PSG escribir índice de registro (activa el 14 para comunicación por el puerto A)
031D: ED 49       out  (c),c		; operación PSG: inactivo
031F: 04          inc  b			; apunta al puerto de control del 8255 PPI
0320: 3E 92       ld   a,$92		; 1001 0010 (puerto A: entrada, puerto B: entrada, puerto C superior: salida, puerto C inferior: salida)
0322: ED 79       out  (c),a
0324: C5          push bc

0325: 3E 45       ld   a,$45
0327: B1          or   c
0328: 4F          ld   c,a
0329: 06 F6       ld   b,$F6		; operación PSG: leer datos del registro (linea 5)
032B: ED 49       out  (c),c
032D: 06 F4       ld   b,$F4
032F: ED 78       in   a,(c)
0331: C1          pop  bc
0332: F5          push af			; guarda la línea leida
0333: 3E 82       ld   a,$82		; 1001 0010 (puerto A: salida, puerto B: entrada, puerto C superior: salida, puerto C inferior: salida)
0335: ED 79       out  (c),a
0337: 05          dec  b
0338: ED 49       out  (c),c		; operación PSG: inactivo
033A: F1          pop  af			; recupera la línea leida
033B: E6 80       and  $80			; se queda con el bit de la barra espaciadora
033D: C9          ret

; graba un byte de memoria a la unidad de disco
033E: 0C          inc  c			; apunta al registro de datos
033F: 7E          ld   a,(hl)		; lee un byte de la memoria
0340: ED 79       out  (c),a		; lo guarda en el sector seleccionado de la pista actual
0342: 0D          dec  c			; apunta al registro de estado
0343: 2B          dec  hl			; apunta al siguiente byte a grabar

; graba los bytes desde la memoria a la unidad de disco
0344: ED 78       in   a,(c)		; lee el registro de estado
0346: F2 44 03    jp   p,$0344
0349: E6 20       and  $20
034B: 20 F1       jr   nz,$033E		; si no se ha completado la operación de escritura, graba otro byte
034D: C9          ret

; ??? nunca se llama a esta rutina
034E: F1          pop  af
034F: 3C          inc  a
0350: FE 00       cp   $00
0352: 20 E7       jr   nz,$033B
0354: C9          ret

; recalibra la unidad de disco
0355: 01 7E FB    ld   bc,$FB7E		; bc = registro principal de la unidad de disco
0358: 3E 07       ld   a,$07		; comando para recalibrar la unidad
035A: CD F8 01    call $01F8		; espera a que la unidad esté lista, y si se puede, se mandan datos
035D: AF          xor  a            ; unidad 0
035E: CD F8 01    call $01F8        ; espera a que la unidad esté lista, y si se puede, se mandan datos
0361: 3E 03       ld   a,$03
0363: CD B5 01    call $01B5        ; espera a que la unidad esté lista, y si se puede, se mandan datos
0366: 3E 08       ld   a,$08        ; comando para obtener información del estado
0368: CD F8 01    call $01F8        ; espera a que la unidad esté lista, y si se puede, se mandan datos
036B: CD CD 01    call $01CD        ; lee los bytes que manda la unidad de disco después de un comando, y los guarda en un buffer
036E: C9          ret

; copia un rectángulo de 4x8 pixels de un buffer a pantalla, y guarda lo que hay en la pantalla en el buffer
036F: 21 00 C0    ld   hl,$C000		; apunta a pantalla
0372: 11 04 03    ld   de,$0304		; apunta a un buffer

; copia un rectángulo de 4x8 pixels de de a hl, y guarda lo de hl en el de
0375: 06 08       ld   b,$08        ; 8 bytes (32 pixels)
0377: 4E          ld   c,(hl)       ; lee un byte de pantalla
0378: 1A          ld   a,(de)       ; lee un byte del buffer
0379: 77          ld   (hl),a       ; copia el byte del buffer a pantalla
037A: 79          ld   a,c
037B: 12          ld   (de),a       ; copia el byte de pantalla al buffer
037C: 13          inc  de           ; pasa a la siguiente posición del buffer
037D: 7C          ld   a,h
037E: C6 08       add  a,$08        ; pasa a la siguiente línea de pantalla
; la rutina está incompleta...
; de 0x380 a 0x3ff hay 0x00
; -------------- fin del código que se sobreescribe con datos del programa --------------------------

; --------------------------------- inicio real del juego --------------------------
; aquí se llega después de copiar las ROMs a los distintos bancos de memoria
0400: C3 9A 24    jp   $249A	; salta a realizar la iniciación del juego

; -------------- código para grabar las partidas guardadas en memoria a disco --------------------------

; escribe un comando de búsqueda de la pista a
0403: F5          push af
0404: 3E 0F       ld   a,$0F	; comando de búsqueda
0406: CD 65 04    call $0465	; espera a que la unidad esté lista, y si se puede, se mandan datos
0409: AF          xor  a		; cabeza 0, unidad 0
040A: CD 65 04    call $0465	; espera a que la unidad esté lista, y si se puede, se mandan datos
040D: F1          pop  af       ; recupera la pista a buscar
040E: CD 65 04    call $0465	; espera a que la unidad esté lista, y si se puede, se mandan datos
0411: 3E 01       ld   a,$01
0413: 11 20 4E    ld   de,$4E20
0416: CD 22 04    call $0422	; pequeño retardo
0419: 3E 08       ld   a,$08    ; comando para obtener información del estado
041B: CD 65 04    call $0465	; espera a que la unidad esté lista, y si se puede, se mandan datos
041E: CD 3A 04    call $043A	; lee los bytes que manda la unidad de disco después de un comando, y los guarda en un buffer
0421: C9          ret

; espera una cantidad de tiempo proporcional a a y de
0422: F5          push af
0423: 1B          dec  de
0424: 7B          ld   a,e
0425: B2          or   d
0426: 20 FB       jr   nz,$0423		; mientras de no sea 0, lo decrementa
0428: F1          pop  af
0429: 3D          dec  a
042A: 20 F6       jr   nz,$0422		; repite a veces
042C: C9          ret

; escribe el comando apuntado por de a la unidad
042D: 1A          ld   a,(de)		; lee el número de bytes del comando
042E: 13          inc  de
042F: F5          push af           ; guarda el número de bytes del comando
0430: 1A          ld   a,(de)
0431: CD 65 04    call $0465		; espera a que la unidad esté lista, y si se puede, se mandan datos
0434: 13          inc  de           ; pasa a la siguiente posición
0435: F1          pop  af
0436: 3D          dec  a
0437: 20 F6       jr   nz,$042F     ; repite hasta que se terminen los bytes del comando
0439: C9          ret

; lee los bytes que manda la unidad de disco después de un comando, y los guarda en un buffer
043A: E5          push hl
043B: D5          push de
043C: 16 00       ld   d,$00			; inicia el contador de bytes escritos
043E: 21 64 00    ld   hl,$0064         ; apunta a un buffer
0441: E5          push hl
0442: ED 78       in   a,(c)			; lee el registro de estado 0
0444: FE C0       cp   $C0
0446: 38 FA       jr   c,$0442          ; espera a que la unidad esté lista
0448: 0C          inc  c				; apunta al registro de datos
0449: ED 78       in   a,(c)            ; lee el resultado del comando de búsqueda
044B: 0D          dec  c				; apunta al registro de estado
044C: 77          ld   (hl),a           ; guarda el dato leido
044D: 23          inc  hl
044E: 14          inc  d
044F: 3E 05       ld   a,$05            ; espera un poco
0451: 3D          dec  a
0452: 20 FD       jr   nz,$0451
0454: ED 78       in   a,(c)            ; espera a que termine la transferencia
0456: E6 10       and  $10
0458: 20 E8       jr   nz,$0442
045A: E1          pop  hl               ; recupera la posición inicial del buffer
045B: 7E          ld   a,(hl)           ; comprueba el estado de la operación
045C: E6 C0       and  $C0
045E: 2B          dec  hl
045F: 72          ld   (hl),d           ; graba el número de bytes leidos
0460: D1          pop  de
0461: E1          pop  hl
0462: C0          ret  nz               ; si ha habido algún error, sale
0463: 37          scf                   ; si la cosa ha ido bien, pone el flag de acarreo
0464: C9          ret

; espera a que la unidad esté lista, y si se puede, se mandan datos
0465: F5          push af
0466: F5          push af
0467: ED 78       in   a,(c)		; lee el registro de estado
0469: 87          add  a,a
046A: 30 FB       jr   nc,$0467		; espera a que el registro de datos esté listo para recibir o enviar datos
046C: 87          add  a,a
046D: 30 03       jr   nc,$0472		; si hay que hacer una transferencia del procesador al registro de datos, salta
046F: F1          pop  af
0470: F1          pop  af
0471: C9          ret

; aquí llega si la unidad espera datos
0472: F1          pop  af			; recupera el valor
0473: 0C          inc  c            ; apunta al registro de datos
0474: ED 79       out  (c),a		; escribe el valor en el registro de datos
0476: 0D          dec  c            ; apunta al registro de control
0477: 3E 05       ld   a,$05
0479: 3D          dec  a
047A: 00          nop
047B: 20 FC       jr   nz,$0479     ; espera un poco
047D: F1          pop  af
047E: C9          ret

; datos de un comando de escritura
047F: 	09 -> número de bytes del comando
		45 -> comando de escritura de datos, doble densidad, monopista
		00 -> cabeza 0, unidad 0
		11 -> número de pista
		00 -> cabeza 0
		21 -> número de sector inicial de la escritura
		01 -> número de bytes por sector (en múltiplos de 0x100)
		2F -> número de sector final de la escritura
		0E -> longitud de separación (GAP3)
		FF -> no usado

; comprueba si se pulsó ctrl+tab y actúa en consecuencia
0489: 3E 44       ld   a,$44
048B: CD 72 34    call $3472		; comprueba si ha habido algún cambio en el estado del tabulador
048E: C8          ret  z			; si no ha habido cambio, sale
048F: 3E 17       ld   a,$17
0491: CD 82 34    call $3482		; comprueba si está pulsado el control
0494: C8          ret  z			; si no, sale

; aquí entra al pulsar ctrl+tab
0495: F3          di
0496: 3E 07       ld   a,$07
0498: 0E 3F       ld   c,$3F
049A: CD 4E 13    call $134E		; deshabilita la salida de sonido
049D: 3E 01       ld   a,$01
049F: 01 7E FA    ld   bc,$FA7E		; activa el motor de la unidad de disco
04A2: ED 79       out  (c),a
04A4: 3E 06       ld   a,$06
04A6: CD 22 04    call $0422		; retardo
04A9: CD 36 05    call $0536		; recalibra la unidad de disco
04AC: 3E 01       ld   a,$01		; pista incial
04AE: F5          push af
04AF: CD 03 04    call $0403		; escribe un comando de búsqueda de la pista a
04B2: F1          pop  af
04B3: 3C          inc  a			; avanza a la siguiente pista
04B4: FE 11       cp   $11
04B6: 38 F6       jr   c,$04AE		; al finalizar este bucle está en el cilindro 0x11

04B8: CD 50 05    call $0550		; muestra el gráfico del cursor
04BB: 3E 01       ld   a,$01
04BD: 11 10 27    ld   de,$2710
04C0: CD 22 04    call $0422		; retardo
04C3: CD 50 05    call $0550		; oculta el gráfico del cursor
04C6: 3E 01       ld   a,$01
04C8: 11 10 27    ld   de,$2710
04CB: CD 22 04    call $0422		; retardo
04CE: CD 6D 05    call $056D		; comprueba si se pulso la S o la N
04D1: 28 E5       jr   z,$04B8		; repite hasta que se pulse alguna
04D3: 30 21       jr   nc,$04F6		; si se pulsó la N, salta

04D5: 2A D9 34    ld   hl,($34D9)	; obtiene la dirección de fín de la altura de la habitación del espejo
04D8: 01 C6 7F    ld   bc,$7FC6		; pone abadia7 en 0x4000
04DB: ED 49       out  (c),c
04DD: 7E          ld   a,(hl)		; lee el último byte
04DE: F5          push af
04DF: E5          push hl
04E0: 36 FF       ld   (hl),$FF		; restaura la altura original
04E2: 01 C6 12    ld   bc,$12C6		; graba lo que hay en el banco 6 (pistas 0x12-0x16) (abadia7.bin)
04E5: CD 0B 05    call $050B		; copia los datos al disco desde la pista b hasta la pista b+4, fijando la configuración de memoria indicada por c, y leyendo los datos en 0x4000-0x7fff
04E8: 01 C5 17    ld   bc,$17C5		; graba lo que hay en el banco 5 (pistas 0x17-0x1b) (abadia6.bin)
04EB: CD 0B 05    call $050B		; copia los datos al disco desde la pista b hasta la pista b+4, fijando la configuración de memoria indicada por c, y leyendo los datos en 0x4000-0x7fff
04EE: E1          pop  hl
04EF: F1          pop  af
04F0: 01 C6 7F    ld   bc,$7FC6		; coloca abadia7 en 0x4000
04F3: ED 49       out  (c),c
04F5: 77          ld   (hl),a		; restaura el último byte

04F6: AF          xor  a			; apaga el motor de la unidad de disco
04F7: 01 7E FA    ld   bc,$FA7E
04FA: ED 79       out  (c),a
04FC: 01 C0 7F    ld   bc,$7FC0		; fija la configuración original
04FF: ED 49       out  (c),c
0501: 3E 01       ld   a,$01
0503: 11 10 27    ld   de,$2710
0506: CD 22 04    call $0422		; retardo
0509: FB          ei
050A: C9          ret

; graba datos al disco desde la pista b hasta la pista b+4, fijando la configuración de memoria indicada por c, y leyendo los datos de 0x4000-0x7fff
050B: 21 FF 7F    ld   hl,$7FFF
050E: 3E 05       ld   a,$05		; longitud de los datos = 5 cilindros

; graba datos al disco desde a pistas desde la pista b, fijando la configuración de memoria indicada por c, y leyendo los datos de hl (hacia abajo)
; a = número de pistas a grabar
; b = pista inicial
; c = configuración de memoria a fijar
; hl = posición de memoria donde empezar a coger los datos (graba desde arriba hacia abajo)
0510: 80          add  a,b			; modifica una instrucción con la última pista a grabar
0511: 32 32 05    ld   ($0532),a	; a = pista inicial
0514: 78          ld   a,b
0515: 06 7F       ld   b,$7F		; fija la configuración de memoria que se le pasa en c
0517: ED 49       out  (c),c        ; bc = registro principal de la unidad de disco
0519: 01 7E FB    ld   bc,$FB7E
051C: F5          push af
051D: 32 82 04    ld   ($0482),a	; modifica la pista del comando
0520: CD 03 04    call $0403		; escribe un comando de búsqueda de la pista a
0523: 11 7F 04    ld   de,$047F		; apunta a los datos del comando de escritura
0526: CD 2D 04    call $042D		; escribe el comando apuntado por de a la unidad
0529: CD 86 05    call $0586		; escribe los bytes de memoria a la unidad de disco
052C: CD 3A 04    call $043A        ; lee los bytes que manda la unidad de disco después de un comando, y los guarda en un buffer
052F: F1          pop  af
0530: 3C          inc  a			; avanza a la siguiente pista
0531: FE 00       cp   $00			; instrucción modificada desde fuera con la última pista a grabar
0533: 20 E7       jr   nz,$051C
0535: C9          ret

; recalibra la unidad de disco
0536: 01 7E FB    ld   bc,$FB7E		; bc = registro principal de la unidad de disco
0539: 3E 07       ld   a,$07        ; comando para recalibrar la unidad
053B: CD 65 04    call $0465		; espera a que la unidad esté lista, y si se puede, se mandan datos
053E: AF          xor  a            ; unidad 0
053F: CD 65 04    call $0465		; espera a que la unidad esté lista, y si se puede, se mandan datos
0542: 3E 03       ld   a,$03
0544: CD 22 04    call $0422		; espera a que la unidad esté lista, y si se puede, se mandan datos
0547: 3E 08       ld   a,$08        ; comando para obtener información del estado
0549: CD 65 04    call $0465		; espera a que la unidad esté lista, y si se puede, se mandan datos
054C: CD 3A 04    call $043A		; lee los bytes que manda la unidad de disco después de un comando, y los guarda en un buffer
054F: C9          ret

; copia un rectángulo de 4x8 pixels de un buffer a pantalla, y guarda lo que hay en la pantalla en el buffer
0550: 21 00 C0    ld   hl,$C000		; apunta a pantalla
0553: 11 65 05    ld   de,$0565		; apunta a los datos gráficos del cursor

; copia un rectángulo de 4x8 pixels de de a hl, y guarda lo de hl en el de
0556: 06 08       ld   b,$08		; 8 bytes (32 pixels)
0558: 4E          ld   c,(hl)       ; lee un byte de pantalla
0559: 1A          ld   a,(de)		; lee un byte del buffer
055A: 77          ld   (hl),a       ; copia el byte del buffer a pantalla
055B: 79          ld   a,c
055C: 12          ld   (de),a       ; copia el byte de pantalla al buffer
055D: 13          inc  de           ; pasa a la siguiente posición del buffer
055E: 7C          ld   a,h
055F: C6 08       add  a,$08        ; pasa a la siguiente línea de pantalla
0561: 67          ld   h,a
0562: 10 F4       djnz $0558
0564: C9          ret

; gráfico del cursor que se muestra al pulsar ctrl+tab, y espacio para guardar lo que había en pantalla
0565: 00 00 0F 0F F0 F0 FF FF

; comprueba si se pulsó la S o la N
056D: CD BC 32    call $32BC	; lee el estado de las teclas y lo guarda en los buffers de teclado
0570: 3E 3C       ld   a,$3C
0572: CD 72 34    call $3472	; comprueba si cambia el estado de la S
0575: 37          scf
0576: C0          ret  nz		; si ha cambiado sale (con carry)
0577: 3E 2E       ld   a,$2E
0579: CD 72 34    call $3472	; comprueba si cambia el estado de la N
057C: C8          ret  z		; si no ha cambiado sale
057D: F6 FF       or   $FF		; si ha cambiado, a = 0xff
057F: C9          ret

; graba un byte de memoria a la unidad de disco
0580: 0C          inc  c			; apunta al registro de datos
0581: 7E          ld   a,(hl)       ; lee un byte de la memoria
0582: ED 79       out  (c),a        ; lo guarda en el sector seleccionado de la pista actual
0584: 0D          dec  c            ; apunta al registro de estado
0585: 2B          dec  hl           ; apunta al siguiente byte a grabar

; graba los bytes desde la memoria a la unidad de disco
0586: ED 78       in   a,(c)		; lee el registro de estado
0588: F2 86 05    jp   p,$0586
058B: E6 20       and  $20
058D: 20 F1       jr   nz,$0580		; si no se ha completado la operación de escritura, graba otro byte
058F: C9          ret
; -------------- fin del código para grabar las partidas guardadas en memoria a disco --------------------------

; ------------------------ datos relacionados con la búsqueda de caminos --------------------------------

0590: C3 9A 24    jp   $249A
0591: 00 00

; buffer de posiciones alternativas. Cada posición ocupa 3 bytes
0593: 	00 00 00
		00 00 00
		00 00 00
		00 00 00
		00 00 00
		FF

05A3: 0000	; puntero a la alternativa que está probando

; tabla de desplazamientos según la orientación
05A5: 	02 00 -> [+2 00]
		00 FE -> [00 -2]
		FE 00 -> [-2 00]
		00 02 -> [00 +2]

; tabla de desplazamientos relacionada con las orientaciones de las puertas
; cada entrada ocupa 8 bytes
; byte 0: relacionado con la posición x de pantalla
; byte 1: relacionado con la posición y de pantalla
; byte 2: relacionado con la profundidad de los sprites
; byte 3: indica el estado de flipx de los gráficos que necesita la puerta
; byte 4: relacionado con la posición x de la rejilla
; byte 5: relacionado con la posición y de la rejilla
; byte 6-7: no usado, pero es el desplazamiento en el buffer de alturas
05AD: 	FF DE 01 00 00 00 0001 -> -01 -34  +01  00    00  00   +01
		FF D6 00 01 00 00 FFE8 -> -01 -42   00 +01    00  00   -24
		FB D6 00 00 00 00 FFFF -> -05 -42   00  00    00  00   -01
		FB DE 01 01 01 01 0018 -> -05 -34  +01 +01   +01 +01   +24

05CD: tablas con las conexiones de las habitaciones de las plantas
si el bit 0 = 0, indica si es una habitación de la que puede salir por la derecha
si el bit 1 = 0, indica si es una habitación de la que puede salir por la arriba
si el bit 2 = 0, indica si es una habitación de la que puede salir por la izquierda
si el bit 3 = 0, indica si se una habitación de la que puede salir por la abajo
si el bit 4 = 1, indica si por esa pantalla se puede subir a otra planta
si el bit 5 = 1, indica si por esa pantalla se puede bajar a otra planta
; X 00 01 02 03 04 05 06 07 08 09 0a 0b 0c 0d 0e 0f  Y
; ================================================== ==
	00 00 00 00 00 00 00 00 08 00 08 08 00 00 00 00  00
	00 08 08 00 08 08 08 09 07 0D 07 07 0C 00 00 00  01
	01 1E 03 0D 06 0A 0A 0B 0C 02 08 08 03 04 00 00  02
	00 03 04 0A 01 0E 0A 0A 02 08 0A 0A 01 04 00 00  03
	00 01 05 0F 05 06 03 07 05 07 06 02 01 04 00 00  04
	00 09 04 02 01 0C 07 05 05 05 04 00 01 04 00 00  05
	01 1E 08 00 08 1B 05 05 05 05 04 08 09 04 00 00  06
	00 02 03 0C 0A 0A 01 0D 05 0D 05 06 02 00 00 00  07
	00 00 00 02 02 03 0C 0A 00 0A 09 06 00 00 00 00  08
	00 00 00 00 00 00 02 03 05 06 02 02 00 00 00 00  09
	00 00 00 00 00 00 00 01 0D 04 00 00 00 00 00 00  0a
	00 00 00 00 00 00 00 00 02 00 00 00 00 00 00 00  0b

067D y 0x685:
; X 00 01 02 03 04 05 06 07 08 09 0a 0b 0c 0d 0e 0f  Y
; ================================================== ==
	XX XX XX XX XX XX XX XX XX XX XX XX XX XX XX XX  00
	00 08 08 00 08 08 00 00 XX XX XX XX XX XX XX XX  01
	01 2E 03 0D 06 1B 0D 06 XX XX XX XX XX XX XX XX  02
	00 03 04 0A 01 0E 0A 08 XX XX XX XX XX XX XX XX  03
	00 01 05 0F 05 06 03 07 XX XX XX XX XX XX XX XX  04
	00 09 04 0A 01 0C 01 05 XX XX XX XX XX XX XX XX  05
	01 2E 09 0F 0C 2B 05 05 XX XX XX XX XX XX XX XX  06
	00 02 03 0C 0A 0A 01 0D XX XX XX XX XX XX XX XX  07

; X 00 01 02 03 04 05 06 07 08 09 0a 0b 0c 0d 0e 0f  Y
; ================================================== ==
	XX XX XX XX XX XX XX XX XX XX XX XX XX XX XX XX 00
	00 08 08 00 08 08 00 00 XX XX XX XX XX XX XX XX 01
	01 0E 03 0D 06 2B 0D 06 XX XX XX XX XX XX XX XX 02
	00 03 04 0A 01 0E 0A 08 XX XX XX XX XX XX XX XX 03
	00 01 05 0F 05 06 03 07 XX XX XX XX XX XX XX XX 04
	00 09 04 0A 01 0C 01 05 XX XX XX XX XX XX XX XX 05
	01 0E 09 0F 0C 0B 05 05 XX XX XX XX XX XX XX XX 06
	00 02 03 0C 0A 0A 01 0D XX XX XX XX XX XX XX XX 07

; ---------------------- fin de los datos relacionados con la búsqueda de caminos ------------------------------

; ejecuta el comportamiento de malaquías
06FD: FD 21 54 30 ld   iy,$3054		; apunta a las características de malaquías
0701: DD 21 AB 3C ld   ix,$3CAB		; apunta a las variables de movimiento de malaquías
0705: AF          xor  a
0706: 32 9C 3C    ld   ($3C9C),a	; indica que el personaje inicialmente si quiere moverse
0709: CD 5E 57    call $575E		; ejecuta la lógica de malaquías (puede cambiar 0x3c9c)
070C: 0E 3F       ld   c,$3F
070E: CD A4 3E    call $3EA4		; modifica la tabla de 0x05cd con información de la tabla de las puertas y entre que habitaciones están
0711: 21 C2 2B    ld   hl,$2BC2		; apunta a la tabla de datos para mover a malaquías
0714: CD 1D 29    call $291D		; comprueba si el personaje puede moverse a donde quiere y actualiza su sprite y el buffer de alturas
0717: DD 21 AB 3C ld   ix,$3CAB		; apunta a las variables de movimiento de malaquías
071B: C3 3C 07    jp   $073C		; salta a generar más comandos de movimiento para malaquías según donde quiera moverse

; ejecuta el comportamiento del abad
071E: FD 21 63 30 ld   iy,$3063		; iy apunta a las características del abad
0722: DD 21 C9 3C ld   ix,$3CC9		; apunta a las variables de movimiento del abad
0726: AF          xor  a
0727: 32 9C 3C    ld   ($3C9C),a	; indica que el personaje inicialmente si quiere moverse
072A: CD CB 5F    call $5FCB		; ejecuta la lógica del abad
072D: 0E 3F       ld   c,$3F
072F: CD A4 3E    call $3EA4		; modifica la tabla de 0x05cd con información de la tabla de las puertas y entre que habitaciones están
0732: 21 CC 2B    ld   hl,$2BCC		; apunta a la tabla para mover al abad
0735: CD 1D 29    call $291D		; comprueba si el personaje puede moverse a donde quiere y actualiza su sprite y el buffer de alturas
0738: DD 21 C9 3C ld   ix,$3CC9		; apunta a las variables de movimiento del abad
	; genera más comandos de movimiento para el abad según donde quiera moverse

; ----------------- generación de movimientos para los personajes con IA ------------------------------
; aquí saltan todos los personajes que "piensan" para llenar su buffer de acciones
; ix = las variables de la lógica del personaje
; iy = datos de posición del personaje
073C: FD CB 09 7E bit  7,(iy+$09)	; si tiene un movimiento pensado, salta la siguiente parte
0740: CA 72 08    jp   z,$0872

; aquí llega si el personaje no tiene un movimiento pensado
0743: 3A 9C 3C    ld   a,($3C9C)	; si el personaje no tiene que ir a ninguna parte, sale
0746: A7          and  a
0747: C0          ret  nz

0748: DD E5       push ix
074A: DD 7E FF    ld   a,(ix-$01)	; lee a donde hay que ir
074D: FE FF       cp   $FF
074F: 28 4D       jr   z,$079E		; si hay que ir a por guillermo, salta
0751: FE FE       cp   $FE
0753: 28 44       jr   z,$0799		; si hay que ir a por el abad, salta
0755: FE FD       cp   $FD
0757: 28 3B       jr   z,$0794		; si hay que ir a por el libro, salta
0759: FE FC       cp   $FC
075B: 28 32       jr   z,$078F		; si hay que ir a por el pergamino, salta

; aquí llega si en ix-1 no encontró 0xff, 0xfe, 0xfd ni 0xfc
075D: 4F          ld   c,a			; c = a
075E: 87          add  a,a			; a = 2*a
075F: 81          add  a,c			; a = 3*a
0760: 4F          ld   c,a
0761: 06 00       ld   b,$00		; bc = 3*a (cada entrada ocupa 3 bytes)
0763: DD 09       add  ix,bc		; indexa en la tabla de sitios a donde suele ir el personaje
0765: DD E5       push ix
0767: E1          pop  hl			; hl = dirección obtenida
0768: E5          push hl
0769: 11 93 05    ld   de,$0593		; apunta al destino
076C: ED A0       ldi
076E: ED A0       ldi
0770: ED A0       ldi				; copia 3 bytes al buffer que se usa en los algoritmos de posición
0772: 3E FF       ld   a,$FF
0774: 12          ld   (de),a		; marca el final de la entrada
0775: E1          pop  hl			; recupera la dirección obtenida
0776: 2B          dec  hl
0777: 2B          dec  hl			; retrocede 2 posiciones, para tratar la entrada como un dato de posición
0778: 11 94 05    ld   de,$0594		; apunta a la siguiente posición libre del buffer -2
077B: 18 27       jr   $07A4		; salta a generar las alternativas

; aquí se salta para procesar una alternativa
; ix posición generada en el buffer
; iy apunta a los datos de posición del personaje
077D: CD 8A 09    call $098A		; va a por un personaje que no está en la misma zona de pantalla que se muestra (iy a por ix)
0780: DD E1       pop  ix			; recupera el puntero a las variables de lógica del personaje
0782: 3A B6 2D    ld   a,($2DB6)	; si no está en el destino, sale
0785: FE FD       cp   $FD
0787: C0          ret  nz
0788: DD 7E FF    ld   a,(ix-$01)	; si ha llegado al sitio, lo indica
078B: DD 77 FD    ld   (ix-$03),a
078E: C9          ret

; aquí llega si se encontró 0xfc
078F: 21 17 30    ld   hl,$3017		; apunta a los datos de posición del pergamino
0792: 18 0D       jr   $07A1

; aquí llega si se encontró 0xfd
0794: 21 08 30    ld   hl,$3008		; apunta a los datos de posición del libro
0797: 18 08       jr   $07A1

; aquí llega si se encontró 0xfe
0799: 21 63 30    ld   hl,$3063		; apunta a los datos de posición del abad
079C: 18 03       jr   $07A1

; aquí llega si se encontró 0xff
079E: 21 36 30    ld   hl,$3036		; apunta a los datos de posición de guillermo

07A1: 11 91 05    ld   de,$0591		; apunta a la primera posición libre del buffer - 2

; hl tiene la dirección de los datos de posición de un personaje o de un objeto al que se quiere llegar
; de apunta a una posición vacía del buffer para buscar caminos alternativos
; iy apunta a los datos de posición del personaje que se quiere mover
07A4: FD E5       push iy				; guarda los datos de posición del personaje
07A6: CD BD 07    call $07BD			; genera una propuesta de movimiento a la posición indicada por hl por cada orientación posible y la graba en el buffer de de
07A9: DD 21 93 05 ld   ix,$0593			; apunta a la primera entrada de datos del buffer
07AD: DD 22 A3 05 ld   ($05A3),ix		; inicia el puntero a la primera posición alternativa
07B1: DD 7E 00    ld   a,(ix+$00)
07B4: FE FF       cp   $FF				; si se han terminado las alternativas, sale
07B6: FD E1       pop  iy
07B8: 20 C3       jr   nz,$077D			; si hay al menos una entrada, salta
07BA: DD E1       pop  ix
07BC: C9          ret

; genera una propuesta de movimiento al lado de la posición indicada por hl por cada orientación posible y la graba en el buffer de de
; hl tiene la dirección de los datos de posición de un personaje o de un objeto al que se quiere llegar
; de apunta a una posición vacía del buffer para buscar caminos alternativos
; iy apunta a los datos de posición del personaje que se quiere mover
07BD: E5          push hl
07BE: DD E1       pop  ix			; ix = hl
07C0: D5          push de
07C1: FD E1       pop  iy			; iy = de
07C3: DD 46 01    ld   b,(ix+$01)	; lee la orientación del personaje/objeto al que se quiere llegar
07C6: CD D2 07    call $07D2		; dados los datos de posición de ix, genera una propuesta para llegar 2 posiciones al lado del personaje según la orientación de b
07C9: 04          inc  b
07CA: CD D2 07    call $07D2		; dados los datos de posición de ix, genera una propuesta para llegar 2 posiciones al lado del personaje según la orientación de b
07CD: 04          inc  b
07CE: CD D2 07    call $07D2		; dados los datos de posición de ix, genera una propuesta para llegar 2 posiciones al lado del personaje según la orientación de b
07D1: 04          inc  b

; dados los datos de posición de ix, genera una propuesta para llegar 2 posiciones al lado del personaje según la orientación de b
; ix tiene la dirección de los datos de posición de un personaje o de un objeto al que se quiere llegar
; iy apunta a una posición vacía del buffer para buscar caminos alternativos
;  b = orientación
07D2: 21 A5 05    ld   hl,$05A5		; apunta a la tabla de desplazamientos según la orientación
07D5: 78          ld   a,b
07D6: E6 03       and  $03
07D8: 47          ld   b,a			; b = b & 0x03 (ajusta la orientación para que esté entre las 4 válidas)
07D9: 87          add  a,a			; cada entrada ocupa 2 bytes
07DA: CD 2D 16    call $162D		; hl = hl + a
07DD: 78          ld   a,b			; a = orientación ajustada
07DE: 0F          rrca
07DF: 0F          rrca				; pone los 2 bits de la orientación como los 2 bits más significativos de a
07E0: EE 80       xor  $80			; invierte la orientación en x y en y
07E2: E6 C0       and  $C0			; se queda solo con los 2 bits de orientación
07E4: DD B6 04    or   (ix+$04)		; combina con la altura/orientación de destino con la actual y la guarda en c
07E7: 4F          ld   c,a
07E8: DD 7E 04    ld   a,(ix+$04)	; copia la altura/orientación de destino deseada al buffer
07EB: FD 77 04    ld   (iy+$04),a
07EE: DD 7E 02    ld   a,(ix+$02)	; obtiene la posición x del destino
07F1: 86          add  a,(hl)
07F2: 23          inc  hl
07F3: FD 77 02    ld   (iy+$02),a	; copia la posición x de destino más un pequeño desplazamiento según la orientación en el buffer
07F6: DD 7E 03    ld   a,(ix+$03)	; obtiene la posición y del destino
07F9: 86          add  a,(hl)
07FA: FD 77 03    ld   (iy+$03),a	; copia la posición y de destino más un pequeño desplazamiento según la orientación en el buffer
07FD: DD E5       push ix
07FF: C5          push bc
									; llamado con iy = dirección de los datos de posición asociados al personaje/objeto
0800: CD BE 0C    call $0CBE		; si la posición a la que ir no es una de las del centro de la pantalla que se muestra, CF=1
									; en otro caso, devuelve en ix un puntero a la entrada de la tabla de alturas de la posición correspondiente
0803: C1          pop  bc
0804: FD 71 04    ld   (iy+$04),c	; guarda la altura/orientación combinada con la de destino
0807: DD 7E 00    ld   a,(ix+$00)	; lee el posible contenido del buffer de alturas
080A: DD E1       pop  ix
080C: 38 17       jr   c,$0825		; si la posición no es una de las que hay en el buffer de pantalla, salta

; aquí llega si en a se leyó la altura de la posición a la que ir porque es una de las posiciones que se muestran en pantalla
080E: E6 EF       and  $EF			; elimina de los datos del buffer de alturas el de los personajes que hay (excepto adso) (???)
0810: C5          push bc
0811: 4F          ld   c,a			; guarda la altura de la casilla en c
0812: DD 7E 04    ld   a,(ix+$04)	; obtiene la altura del destino
0815: CD 73 24    call $2473		; dependiendo de la altura, devuelve la altura base de la planta en b
0818: 90          sub  b			; le resta a la altura del destino la altura base de la planta
0819: 91          sub  c			; le resta la altura en el buffer de alturas
081A: 3C          inc  a
081B: FE 06       cp   $06
081D: C1          pop  bc
081E: 38 05       jr   c,$0825		; si hay poca diferencia de altura, pone el marcador de fin al final de esta entrada
0820: FD 36 02 FF ld   (iy+$02),$FF	; pone el marcador de fin al inicio de esta entrada (esta entrada queda descartada)
0824: C9          ret

; aquí llega si la posición a la que se quiere ir no es una de las del buffer de alturas de la pantalla
0825: FD 23       inc  iy
0827: FD 23       inc  iy
0829: FD 23       inc  iy
082B: FD 36 02 FF ld   (iy+$02),$FF	; pone el marcador de fin al final de esta entrada
082F: C9          ret

; ejecuta el comportamiento de berengario
0830: FD 21 72 30 ld   iy,$3072		; apunta a los datos de posición de berengario
0834: DD 21 EA 3C ld   ix,$3CEA		; apunta a las variables de movimiento de berengario
0838: AF          xor  a
0839: 32 9C 3C    ld   ($3C9C),a	; indica que inicialmente se quiere mover
083C: CD 3F 59    call $593F		; ejecuta la lógica de berengario
083F: 0E 3F       ld   c,$3F
0841: CD A4 3E    call $3EA4		; modifica la tabla de 0x05cd con información de la tabla de las puertas y entre que habitaciones están
0844: 21 D6 2B    ld   hl,$2BD6		; apunta a la tabla de berengario
0847: CD 1D 29    call $291D		; comprueba si el personaje puede moverse a donde quiere y actualiza su sprite y el buffer de alturas
084A: DD 21 EA 3C ld   ix,$3CEA		; apunta a las variables de movimiento de berengario
084E: C3 3C 07    jp   $073C		; salta a generar más comandos de movimiento para berengario según donde quiera moverse

; ejecuta el comportamiento de severino
0851: FD 21 81 30 ld   iy,$3081		; apunta a los datos de posición de severino
0855: DD 21 02 3D ld   ix,$3D02		; apunta a las variables de estado de severino
0859: AF          xor  a
085A: 32 9C 3C    ld   ($3C9C),a	; indica que el personaje quiere moverse
085D: CD C6 5B    call $5BC6		; ejecuta los cambios de estado de severino/jorge
0860: 0E 2F       ld   c,$2F
0862: CD A4 3E    call $3EA4		; modifica la tabla de 0x05cd con información de la tabla de las puertas y entre que habitaciones están
0865: 21 E0 2B    ld   hl,$2BE0		; apunta a la tabla de severino
0868: CD 1D 29    call $291D		; comprueba si el personaje puede moverse a donde quiere y actualiza su sprite y el buffer de alturas
086B: DD 21 02 3D ld   ix,$3D02		; apunta a las variables de estado de severino
086F: C3 3C 07    jp   $073C		; salta a generar más comandos de movimiento para severino según donde quiera moverse

; aquí llega si tiene un movimiento pensado
0872: 3A C1 2D    ld   a,($2DC1)
0875: FE FF       cp   $FF			; si no hay movimiento
0877: C2 BE 08    jp   nz,$08BE		; descarta los movimientos pensados e indica que hay que pensar un nuevo movimiento
087A: C9          ret

; ----------------- fin de la generación de movimientos para los personajes con IA ------------------------------

; comportamiento de adso
087B: FD 21 45 30 ld   iy,$3045		; apunta a los datos de posición de adso
087F: DD 21 14 3D ld   ix,$3D14		; apunta a los datos de estado de adso
0883: AF          xor  a
0884: 32 9C 3C    ld   ($3C9C),a	; indica que el personaje inicialmente si quiere moverse
0887: CD A1 5D    call $5DA1		; procesa el comportamiento de adso
088A: 0E 3C       ld   c,$3C
088C: CD A4 3E    call $3EA4		; modifica la tabla de 0x05cd con información de la tabla de las puertas y entre que habitaciones están
088F: 21 B8 2B    ld   hl,$2BB8		; apunta a la tabla para mover a adso
0892: CD 1D 29    call $291D		; comprueba si el personaje puede moverse a donde quiere y actualiza su sprite y el buffer de alturas
0895: DD 21 14 3D ld   ix,$3D14
0899: 3A 13 3D    ld   a,($3D13)	; lee a donde debe ir adso
089C: FE FF       cp   $FF
089E: C2 3C 07    jp   nz,$073C		; si no tiene que seguir a guillermo, salta

08A1: 3A 8F 3C    ld   a,($3C8F)	; lee el personaje al que sigue la cámara
08A4: FE 02       cp   $02
08A6: D0          ret  nc			; si la cámara no sigue a guillermo o a adso, sale

08A7: FD CB 09 7E bit  7,(iy+$09)
08AB: 20 22       jr   nz,$08CF		; si no tiene un movimiento pensado, salta

; aquí llega si tenía un movimiento pensado
08AD: 21 AA 2D    ld   hl,$2DAA		; apunta al contador de movimientos frustados
08B0: 3A C1 2D    ld   a,($2DC1)	; si el personaje se pudo mover hacia donde quería, sale
08B3: FE FF       cp   $FF
08B5: C8          ret  z

08B6: 7E          ld   a,(hl)		; obtiene el contador y lo incrementa
08B7: 3C          inc  a
08B8: 77          ld   (hl),a
08B9: FE 0A       cp   $0A			; si es < 10, sale
08BB: D8          ret  c
08BC: AF          xor  a
08BD: 77          ld   (hl),a		; mantiene el valor entre 0 y 9

; aquí llega si el contador ese se desborda a 0

; descarta los movimientos pensados e indica que hay que pensar un nuevo movimiento
08BE: FD 6E 0C    ld   l,(iy+$0c)		; hl = dirección de datos de las acciones
08C1: FD 66 0D    ld   h,(iy+$0d)
08C4: 36 10       ld   (hl),$10			; escribe el comando para que ponga el bit 7,(9)
08C6: FD 36 09 00 ld   (iy+$09),$00
08CA: FD 36 0B 00 ld   (iy+$0b),$00
08CE: C9          ret

; aquí llega si no tenía un movimiento pensado

; si tiene el control pulsado, adso se queda quieto
08CF: 3E 17       ld   a,$17
08D1: CD 82 34    call $3482		; comprueba si se pulsa control
08D4: CD C6 41    call $41C6		; pone a en 0, para que nunca de como pulsado el control
08D7: C0          ret  nz			; antes esto hacía que si se pulsaba el control, sale

08D8: FD 21 45 30 ld   iy,$3045
08DC: AF          xor  a
08DD: 32 B6 2D    ld   ($2DB6),a	; indica que de momento no ha encontrado una ruta hasta guillermo
08E0: CD BE 0C    call $0CBE		; si la posición no es una de las del centro de la pantalla que se muestra, CF=1
									; en otro caso, devuelve en ix un puntero a la entrada de la tabla de alturas de la posición correspondiente
08E3: DA 7F 09    jp   c,$097F		; si adso no está en la pantalla que se muestra, salta
08E6: 3E 00       ld   a,$00
08E8: CD 82 34    call $3482		; si no pulsa cursor arriba, salta
08EB: 28 1C       jr   z,$0909

; aquí llega si adso está en el centro de la pantalla y se pulsa cursor arriba
08ED: FD 21 36 30 ld   iy,$3036		; apunta a los datos de posición de guillermo
08F1: CD B4 27    call $27B4		; comprueba la altura de las posiciones a las que va a moverse guillermo y las devuelve en a y c
									; si el personaje no está visible, se devuelve lo mismo que se pasó en a
08F4: FD 21 45 30 ld   iy,$3045		; apunta a los datos de posición de adso
08F8: 21 C6 2D    ld   hl,$2DC6		; apunta al buffer auxiliar para el cálculo de las alturas a los movimientos usado por la rutina anterior
08FB: 7E          ld   a,(hl)		; combina el contenido de las 2 casillas por las que va a moverse guillermo
08FC: 23          inc  hl
08FD: B6          or   (hl)
08FE: 23          inc  hl			; pasa a la siguiente línea
08FF: 23          inc  hl
0900: 23          inc  hl
0901: B6          or   (hl)			; combina las 2 casillas en las que está guillermo
0902: 23          inc  hl
0903: B6          or   (hl)
0904: CB 6F       bit  5,a
0906: C2 A4 45    jp   nz,$45A4		; si adso no está en alguna de esas, escribe comandos para moverse hacia ellas

; aquí llega si no se pulsa cursor arriba o si adso no molestaba a guillermo para avanzar
0909: 3E 02       ld   a,$02
090B: CD 82 34    call $3482
090E: C2 82 45    jp   nz,$4582		; si se pusa cursor abajo, salta

0911: FD 21 36 30 ld   iy,$3036		; apunta a los datos posición de guillermo
0915: 0E 00       ld   c,$00
0917: CD EF 28    call $28EF		; si la posición del sprite es central y la altura está bien, limpia las posiciones que ocupa guillermo en el buffer de alturas
091A: FD 21 45 30 ld   iy,$3045		; apunta a los datos posición de adso
091E: 0E 00       ld   c,$00
0920: CD EF 28    call $28EF		; si la posición del sprite es central y la altura está bien, limpia las posiciones que ocupa adso en el de alturas

0923: 2A 47 30    ld   hl,($3047)	; obtiene la posición de adso
0926: CD 9B 27    call $279B		; ajusta la posición pasada en hl a las 20x20 posiciones centrales que se muestran. Si la posición está fuera, CF=1
0929: 22 B4 2D    ld   ($2DB4),hl	; guarda la posición relativa de adso
092C: 2A 38 30    ld   hl,($3038)	; obtiene la posición de guillermo
092F: CD 9B 27    call $279B		; ajusta la posición pasada en hl a las 20x20 posiciones centrales que se muestran. Si la posición está fuera, CF=1
0932: 22 B2 2D    ld   ($2DB2),hl	; guarda la posición relativa de guillermo
0935: CD 29 44    call $4429		; busca el camino para ir de guillermo a adso (o viceversa)
0938: 22 6B 46    ld   ($466B),hl	; guarda la dirección de la pila donde están los movimientos realizados
093B: CD AE 0B    call $0BAE		; elimina todos los rastros de la búsqueda del buffer de alturas

093E: FD 21 36 30 ld   iy,$3036		; apunta a los datos posición de guillermo
0942: FD 4E 0E    ld   c,(iy+$0e)
0945: CD EF 28    call $28EF		; si la posición del sprite es central y la altura está bien, pone c en las posiciones que ocupa del buffer de alturas
0948: FD 21 45 30 ld   iy,$3045		; apunta a los datos posición de adso
094C: FD 4E 0E    ld   c,(iy+$0e)
094F: CD EF 28    call $28EF		; si la posición del sprite es central y la altura está bien, pone c en las posiciones que ocupa del buffer de alturas
0952: 3A B6 2D    ld   a,($2DB6)
0955: A7          and  a
0956: C8          ret  z			; si no encontró un camino del origen al destino, sale

; aquí llega si se encontró un camino del origen al destino
; iy apunta a los datos de posición de adso
0957: 0E 04       ld   c,$04		; mínimo número de iteraciones del algoritmo
0959: FD CB 05 7E bit  7,(iy+$05)
095D: 20 11       jr   nz,$0970		; si el personaje ocupa una sola posición en el buffer de alturas, salta
095F: 0D          dec  c			; si ocupa 4 posiciones, se permite una iteración menos
0960: 2A 38 30    ld   hl,($3038)	; obtiene la posición de guillermo
0963: FD 7E 02    ld   a,(iy+$02)	; obtiene la posición x del personaje
0966: BD          cp   l
0967: 28 07       jr   z,$0970		; si las posiciones x son iguales, salta
0969: FD 7E 03    ld   a,(iy+$03)	; obtiene la posición y del personaje
096C: BC          cp   h
096D: 28 01       jr   z,$0970		; si las posiciones y son iguales, salta
096F: 0C          inc  c			; si ninguna de las 2 coordenadas son iguales, se incrementa el número de iteraciones mínimas del algoritmo

0970: 3A 19 44    ld   a,($4419)	; obtiene el nivel de recursión de la rutina de búsqueda
0973: B9          cp   c			; si el número de iteraciones es menor que el tolerable, sale
0974: D8          ret  c

0975: 3A 18 44    ld   a,($4418)	; obtiene la última orientación que se utilizó para encontrar al personaje en la rutina de búsqueda
0978: 4F          ld   c,a			; c = última orientación usada en el algoritmo de búsqueda
0979: CD 3F 46    call $463F		; escribe un comando para avanzar en la nueva orientación del personaje
097C: C3 7B 08    jp   $087B		; vuelve a llamar al comportamiento de adso

; aquí llega si adso no está en zona de la pantalla que se muestra
; iy apunta a los datos de adso
097F: DD 21 38 30 ld   ix,$3038		; apunta a la posición de guillermo
0983: CD 8A 09    call $098A		; va a por un personaje que no está en la misma zona de pantalla que se muestra (iy a por ix)
0986: DA 7B 08    jp   c,$087B		; si encontró un camino, vuelve a ejecutar el movimiento de adso
0989: C9          ret

; ---------------- algoritmo de alto nivel para la búsqueda de caminos entre 2 posiciones -------------------------

; algoritmo de búsqueda de caminos entre 2 puntos
; iy apunta a los datos del personaje que busca a otro
; ix apunta a la posición del personaje/objeto que se busca
098A: 3E FE       ld   a,$FE
098C: 32 B6 2D    ld   ($2DB6),a	; indica que no se ha podido buscar un camino
098F: 3E 00       ld   a,$00		; modificado desde el bucle principal del juego con la animación de guillermo
0991: E6 01       and  $01
0993: C0          ret  nz			; si está en la mitad de la animación, sale

0994: 3A A9 2D    ld   a,($2DA9)	; si en esta iteración ya se ha encontrado un camino, sale (sólo se busca un camino por iteración)
0997: A7          and  a			; si ya se ha encontrado un camino, sale
0998: C0          ret  nz

0999: 3E 76       ld   a,$76
099B: 32 A4 48    ld   ($48A4),a	; indica que hay que buscar una posición con el bit 6 en el algoritmo de búsqueda de caminos
099E: AF          xor  a
099F: 32 B6 2D    ld   ($2DB6),a	; indica que de momento no se ha encontrado un camino
09A2: FD 7E 04    ld   a,(iy+$04)	; obtiene la altura del personaje que busca a otro
09A5: CD 73 24    call $2473		; dependiendo de la altura, devuelve la altura base de la planta en b
09A8: 58          ld   e,b			; e = altura base de la planta del personaje que busca a otro
09A9: DD 7E 02    ld   a,(ix+$02)	; obtiene la altura del personaje buscado
09AC: E6 3F       and  $3F
09AE: CD 73 24    call $2473		; dependiendo de la altura, devuelve la altura base de la planta en b

09B1: 7B          ld   a,e			; a = altura base de la planta del personaje que busca a otro
09B2: 21 CD 05    ld   hl,$05CD		; apunta a tabla con las conexiones de las habitaciones (planta baja)
09B5: A7          and  a
09B6: 28 0A       jr   z,$09C2		; si el personaje que busca a otro está en la planta baja, salta
09B8: 21 7D 06    ld   hl,$067D		; apunta a tabla con las conexiones de las habitaciones (primera planta)
09BB: FE 0B       cp   $0B
09BD: 28 03       jr   z,$09C2		; si el personaje que busca a otro está en la primera planta, salta
09BF: 21 85 06    ld   hl,$0685		; apunta a tabla con las conexiones de las habitaciones (segunda planta)

09C2: 22 0A 44    ld   ($440A),hl	; guarda la dirección de la tabla
09C5: B8          cp   b
09C6: 28 6F       jr   z,$0A37		; si están en la misma planta, salta

; aquí llega si los personajes no están en la misma planta
09C8: 3E 10       ld   a,$10
09CA: 38 02       jr   c,$09CE		; si el personaje que busca a otro está en una planta inferior al personaje de destino, a = 0x10
09CC: 3E 20       ld   a,$20		; en otro caso, a = 0x20

09CE: 4F          ld   c,a			; c = indicador de si hay que subir o bajar planta
09CF: FD 7E 03    ld   a,(iy+$03)	; obtiene la posición y del personaje que busca a otro
09D2: E6 F0       and  $F0			; se queda con la parte más significativa de la posición y
09D4: 5F          ld   e,a
09D5: FD 7E 02    ld   a,(iy+$02)	; obtiene la posición x del personaje que busca a otro
09D8: 0F          rrca
09D9: 0F          rrca
09DA: 0F          rrca
09DB: 0F          rrca
09DC: E6 0F       and  $0F			; se queda con la parte más significativa de la posición x en el nibble inferior
09DE: B3          or   e			; combina las posiciones para hallar en que habitación de la planta está
09DF: CD 2D 16    call $162D		; indexa en la tabla de la planta
09E2: 7E          ld   a,(hl)		; lee el valor correspondiente a la habitación en la que está el personaje que busca a otro
09E3: A1          and  c
09E4: 79          ld   a,c			; a = indicador de si hay que subir o bajar planta
09E5: 20 25       jr   nz,$0A0C		; si desde la habitación en la que está se puede subir o bajar de planta, salta

; aquí llega si desde la habitación actual no se puede ni subir ni bajar
09E7: FE 10       cp   $10			; si había que subir, a = 0x66 (que compruebe el bit 4)
09E9: 3E 66       ld   a,$66
09EB: 28 02       jr   z,$09EF
09ED: 3E 6E       ld   a,$6E		; si había que bajar, a = 0x6e (que compruebe el bit 5)
09EF: 32 A4 48    ld   ($48A4),a	; modifica una instrucción
09F2: CD 8E 0A    call $0A8E		; devuelve en la parte menos significativa de hl la parte más significativa de la posición del personaje que se le pasa en iy
09F5: 22 B2 2D    ld   ($2DB2),hl	; guarda la posición más significativa del personaje que busca a otro
09F8: CD 30 48    call $4830		; busca la orientación que hay que seguir para encontrar las escaleras más próximas en esta planta
09FB: CD A3 0A    call $0AA3		; limpia los bits usados para la búsqueda de recorridos en la tabla actual
09FE: 3E 76       ld   a,$76
0A00: 32 A4 48    ld   ($48A4),a	; restaura la instrucción para indicar que tiene que buscar el bit 6
0A03: 3A B6 2D    ld   a,($2DB6)
0A06: A7          and  a
0A07: C8          ret  z			; si no se encontró ningún camino, sale

; aquí llega si desde la habitación actual no se puede ni subir ni bajar, pero ha encontrado un camino a una habitación de la planta con escaleras
0A08: EB          ex   de,hl		; pone en hl la pantalla de destino
0A09: C3 C4 0A    jp   $0AC4		; busca un camino para ir de la habitación actual a la habitación destino. Si encuentra el camino,
									;  recrea la habitación y genera la ruta para llegar a donde se quiere

; aquí llega si desde la habitación actual se puede subir o bajar
0A0C: FE 10       cp   $10			; si había que subir, a = 0x0d. si había que bajar a = 0x01;
0A0E: 3E 0D       ld   a,$0D
0A10: 28 02       jr   z,$0A14
0A12: 3E 01       ld   a,$01
0A14: 32 22 0A    ld   ($0A22),a	; modifica una instrucción
0A17: CD BF 0B    call $0BBF		; rellena en un buffer las alturas de la pantalla actual del personaje indicado por iy, marca las casillas ocupadas por los personajes
									; que están cerca de la pantalla actual y por las puertas y limpia las casillas que ocupa el personaje que llama a esta rutina
0A1A: 21 F4 96    ld   hl,$96F4		; hl apunta al inicio del buffer de alturas donde se ha almacenado la altura de la pantalla actual
0A1D: 01 40 02    ld   bc,$0240		; bc = longitud del buffer (24*24)
0A20: 7E          ld   a,(hl)		; lee un byte
0A21: FE 00       cp   $00			; instrucción modificada desde fuera con un valor dependiente de si se quiere subir o bajar
0A23: 20 02       jr   nz,$0A27		; si no coincide con el valor, salta
0A25: CB F6       set  6,(hl)		; marca la posición como un objetivo a buscar
0A27: 23          inc  hl
0A28: 0B          dec  bc			; continúa procesando el buffer de alturas hasta terminar
0A29: 78          ld   a,b
0A2A: B1          or   c
0A2B: 20 F3       jr   nz,$0A20

0A2D: ED 43 B4 2D ld   ($2DB4),bc	; pone a 0 la posición de destino
0A31: CD 88 0F    call $0F88		; limita las opciones a probar a la primera opción
0A34: C3 FD 0A    jp   $0AFD		; busca la ruta y pone las instrucciones para llegar a las escaleras

; aqui llega buscando un camino entre 2 personajes que están en la misma planta
; iy apunta a los datos del personaje que busca a otro
; ix apunta a los datos del personaje buscado
0A37: DD 6E 00    ld   l,(ix+$00)	; obtiene la coordenada x de la posición a la que se quiere llegar
0A3A: DD 66 01    ld   h,(ix+$01)	; obtiene la coordenada y de la posición a la que se quiere llegar
0A3D: FD 7E 02    ld   a,(iy+$02)	; obtiene la posición x del personaje que busca al otro
0A40: AD          xor  l
0A41: 4F          ld   c,a
0A42: E6 F0       and  $F0
0A44: 20 6E       jr   nz,$0AB4		; si no está en la misma habitación en x, salta a buscar un camino para ir de la habitación actual
									; a la habitación destino (hl). Si lo encuentra, recrea la habitación y genera la ruta para llegar a donde se quiere
0A46: FD 7E 03    ld   a,(iy+$03)	; obtiene la posición y del personaje que busca al otro
0A49: AC          xor  h
0A4A: 47          ld   b,a
0A4B: E6 F0       and  $F0
0A4D: 20 65       jr   nz,$0AB4		; si no está en la misma habitación en y, salta a buscar un camino para ir de la habitación actual
									; a la habitación destino (hl). Si lo encuentra, recrea la habitación y genera la ruta para llegar a donde se quiere

; aqui llega si están en la misma habitación
0A4F: 3E FD       ld   a,$FD
0A51: 32 B6 2D    ld   ($2DB6),a	; indica que los personajes están en la misma habitación
0A54: 78          ld   a,b
0A55: B1          or   c
0A56: 20 24       jr   nz,$0A7C		; si la posición de origen no es igual que la de destino, salta

0A58: DD 7E 02    ld   a,(ix+$02)	; lee la altura y la orientación de la posición de destino
0A5B: 07          rlca
0A5C: 07          rlca
0A5D: E6 03       and  $03			; se queda con la orientación en los 2 bits menos significativos
0A5F: 4F          ld   c,a
0A60: FD 7E 01    ld   a,(iy+$01)	; lee la orientación del personaje que busca
0A63: B9          cp   c
0A64: C8          ret  z			; si las orientaciones son iguales, sale

0A65: CD 73 0A    call $0A73		; fija la primera posición del buffer de comandos
0A68: CD C3 47    call $47C3		; escribe unos comandos para cambiar la orientación del personaje
0A6B: 21 00 10    ld   hl,$1000
0A6E: 06 0C       ld   b,$0C
0A70: CD E9 0C    call $0CE9		; escribe b bits del comando que se le pasa en hl del personaje pasado en iy

; fija la primera posición del buffer de comandos
0A73: FD 36 09 00 ld   (iy+$09),$00
0A77: FD 36 0B 00 ld   (iy+$0b),$00
0A7B: C9          ret

; llega cuando las 2 posiciones están dentro de la misma habitación pero en distinto lugar
0A7C: AF          xor  a
0A7D: 32 B6 2D    ld   ($2DB6),a	; indica que la búsqueda ha fallado
0A80: E5          push hl
0A81: CD BF 0B    call $0BBF		; rellena en un buffer las alturas de la pantalla actual del personaje indicado por iy, marca las casillas ocupadas por los personajes
									; que están cerca de la pantalla actual y por las puertas y limpia las casillas que ocupa el personaje que llama a esta rutina
0A84: E1          pop  hl			; hl = posición de destino
0A85: CD 9B 27    call $279B		; ajusta la posición pasada en hl a las 20x20 posiciones centrales que se muestran. Si la posición está fuera, CF=1
0A88: 22 B4 2D    ld   ($2DB4),hl
0A8B: C3 0E 0B    jp   $0B0E		; rutina llamada para buscar la ruta desde la posición del personaje a lo grabado en 0x2db4-0x2db5

; devuelve en la parte menos significativa de hl la parte más significativa de la posición del personaje que se le pasa en iy
0A8E: FD 7E 02    ld   a,(iy+$02)		; obtiene la posición x del personaje
0A91: 0F          rrca
0A92: 0F          rrca
0A93: 0F          rrca
0A94: 0F          rrca
0A95: E6 0F       and  $0F
0A97: 6F          ld   l,a				; l = parte más significativa de la posición x del personaje en el nibble inferior
0A98: FD 7E 03    ld   a,(iy+$03)		; obtiene la posición y del personaje
0A9B: 0F          rrca
0A9C: 0F          rrca
0A9D: 0F          rrca
0A9E: 0F          rrca
0A9F: E6 0F       and  $0F
0AA1: 67          ld   h,a				; h = parte más significativa de la posición y del personaje en el nibble inferior
0AA2: C9          ret

; se asegura de que la tabla de 0x05cd esté entre 0x00 y 0x3f
0AA3: 21 CD 05    ld   hl,$05CD
0AA6: 01 30 01    ld   bc,$0130		; 0x130 bytes
0AA9: 7E          ld   a,(hl)
0AAA: E6 3F       and  $3F
0AAC: 77          ld   (hl),a		; [hl] = [hl] & 0x3f
0AAD: 23          inc  hl
0AAE: 0B          dec  bc
0AAF: 78          ld   a,b
0AB0: B1          or   c
0AB1: 20 F6       jr   nz,$0AA9		; repite hasta que haya terminado
0AB3: C9          ret

; desplaza las posiciones al nibble inferior
0AB4: CB 3C       srl  h
0AB6: CB 3C       srl  h
0AB8: CB 3C       srl  h
0ABA: CB 3C       srl  h
0ABC: CB 3D       srl  l
0ABE: CB 3D       srl  l
0AC0: CB 3D       srl  l
0AC2: CB 3D       srl  l

; busca un camino para ir de la habitación actual a la habitación destino. Si lo encuentra, recrea la habitación y genera la ruta para llegar a donde se quiere
;  hl = pantalla de destino
;  iy = datos de posición de personaje que quiere ir a la posición de destino
0AC4: 22 B2 2D    ld   ($2DB2),hl	; guarda la pantalla de destino
0AC7: CD 8E 0A    call $0A8E		; devuelve en la parte menos significativa de hl la parte más significativa de la posición del personaje que se le pasa en iy
0ACA: 22 B4 2D    ld   ($2DB4),hl	; guarda la pantalla de origen
0ACD: CD 26 48    call $4826		; busca un camino para ir de la habitación actual a la habitación destino
0AD0: CD A3 0A    call $0AA3		; limpia los bits usados para la búsqueda de recorridos en la tabla actual
0AD3: 3A B6 2D    ld   a,($2DB6)
0AD6: A7          and  a
0AD7: C8          ret  z			; si no se ha encontrado el camino, sale

0AD8: 3A 18 44    ld   a,($4418)	; obtiene la orientación que se ha de seguir para llegar al camino
0ADB: 87          add  a,a
0ADC: 87          add  a,a			; cada entrada ocupa 4 bytes
0ADD: 21 8A 0C    ld   hl,$0C8A		; hl apunta a una tabla auxiliar para marcar las posiciones a las que debe ir el personaje
0AE0: 85          add  a,l
0AE1: 6F          ld   l,a
0AE2: 8C          adc  a,h
0AE3: 95          sub  l
0AE4: 67          ld   h,a			; indexa en la tabla
0AE5: 5E          ld   e,(hl)
0AE6: 23          inc  hl
0AE7: 56          ld   d,(hl)		; de = [hl]
0AE8: ED 53 FB 0A ld   ($0AFB),de	; modifica la rutina a llamar
0AEC: 23          inc  hl
0AED: CD 88 0F    call $0F88		; limita las opciones a probar a la primera opción
0AF0: 5E          ld   e,(hl)
0AF1: 23          inc  hl
0AF2: 56          ld   d,(hl)		; de = siguiente valor de la entrada
0AF3: ED 53 B4 2D ld   ($2DB4),de	; guarda la posición de destino
0AF7: CD BF 0B    call $0BBF		; rellena en un buffer las alturas de la pantalla actual del personaje indicado por iy, marca las casillas ocupadas por los personajes
									; que están cerca de la pantalla actual y por las puertas y limpia las casillas que ocupa el personaje que llama a esta rutina

0AFA: CD 00 00    call $0000		; instrucción modificada desde fuera con la rutina a llamar según la orientación a seguir
									; esta rutina pone el bit 6 de las posiciones del buffer de alturas de la orientación que se debe seguir
									; para pasar a la pantalla según calculo el buscador de caminos


0AFD: FD 66 03    ld   h,(iy+$03)	; obtiene la posición del personaje
0B00: FD 6E 02    ld   l,(iy+$02)
0B03: CD 9B 27    call $279B		; ajusta la posición pasada en hl a las 20x20 posiciones centrales que se muestran. Si la posición está fuera, CF=1
0B06: 22 B2 2D    ld   ($2DB2),hl	; pone el origen de la búsqueda
0B09: CD 29 44    call $4429		; rutina llamada para buscar la ruta desde la posición que se le pasa en 0x2db2-0x2db3 a la que hay en 0x2db4-0x2db5 y las que tengan el bit 6 a 1
0B0C: 18 0F       jr   $0B1D

0B0E: FD 66 03    ld   h,(iy+$03)	; obtiene la posición del personaje
0B11: FD 6E 02    ld   l,(iy+$02)
0B14: CD 9B 27    call $279B		; ajusta la posición pasada en hl a las 20x20 posiciones centrales que se muestran. Si la posición está fuera, CF=1
0B17: 22 B2 2D    ld   ($2DB2),hl	; pone el origen de la búsqueda
0B1A: CD 35 44    call $4435		; rutina llamada para buscar la ruta desde la posición que se le pasa en 0x2db2-0x2db3 a la que tiene puesto el bit 6

0B1D: 22 6B 46    ld   ($466B),hl	; guarda el puntero al movimiento de la pila que dio la solución
0B20: 3A B6 2D    ld   a,($2DB6)
0B23: A7          and  a
0B24: 20 45       jr   nz,$0B6B		; si se encontró un camino, salta

; aquí llega si no se encontró un camino
0B26: DD 2A A3 05 ld   ix,($05A3)	; obtiene el puntero a la alternativa que ha probado
0B2A: DD 23       inc  ix
0B2C: DD 23       inc  ix
0B2E: DD 23       inc  ix
0B30: DD 22 A3 05 ld   ($05A3),ix	; avanza el puntero a la siguiente alternativa
0B34: DD 7E 00    ld   a,(ix+$00)	; si se han probado todas las alternativas, salta
0B37: FE FF       cp   $FF
0B39: 28 2B       jr   z,$0B66
0B3B: CD AE 0B    call $0BAE		; elimina todos los rastros de la búsqueda del buffer de alturas

0B3E: DD 6E 00    ld   l,(ix+$00)	; obtiene la posición de la siguiente alternativa
0B41: DD 66 01    ld   h,(ix+$01)
0B44: 3E FD       ld   a,$FD
0B46: 32 B6 2D    ld   ($2DB6),a	; indica que los personajes están en la misma habitación
0B49: FD 7E 02    ld   a,(iy+$02)	; obtiene la posición x del personaje
0B4C: AD          xor  l
0B4D: 4F          ld   c,a			; c = diferencia de posición x del personaje
0B4E: FD 7E 03    ld   a,(iy+$03)	; obtiene la posición y del personaje
0B51: AC          xor  h
0B52: B1          or   c			; c = diferencia de posición del personaje en x y en y
0B53: F5          push af
0B54: CC 58 0A    call z,$0A58		; si la posición de la alternativa es la misma que la del personaje, genera los comandos para obtener la orientación correcta
0B57: F1          pop  af
0B58: 28 0C       jr   z,$0B66		; si la posición de la alternativa es la misma que la del personaje, sale

0B5A: AF          xor  a
0B5B: 32 B6 2D    ld   ($2DB6),a	; indica que no se ha encontrado un camino

0B5E: CD 9B 27    call $279B		; ajusta la posición pasada en hl a las 20x20 posiciones centrales que se muestran. Si la posición está fuera, CF=1
0B61: 22 B4 2D    ld   ($2DB4),hl	; modifica la posición a la que debe ir el personaje
0B64: 18 A8       jr   $0B0E		; vuelve a probar a ver si encuentra esa posición

; aquí llega si se han probado todas las alternativas y no se encontró un camino
0B66: CD 76 0B    call $0B76		; restaura el buffer de alturas
0B69: A7          and  a			; limpia el flag de acarreo
0B6A: C9          ret

; aquí llega si se encontró un camino
0B6B: 3E 01       ld   a,$01
0B6D: 32 A9 2D    ld   ($2DA9),a	; indica que se ha encontrado un camino en esta iteración del bucle principal
0B70: CD AE 0B    call $0BAE		; elimina todos los rastros de la búsqueda del buffer de alturas
0B73: CD E6 47    call $47E6		; genera todos los comandos para ir desde el origen al destino

0B76: 21 C0 01    ld   hl,$01C0
0B79: 22 8A 2D    ld   ($2D8A),hl	; restaura el buffer de alturas de la pantalla actual
0B7C: FD E5       push iy
0B7E: FD 21 73 2D ld   iy,$2D73		; apunta a los datos del personaje al que sigue la cámara
0B82: CD 8F 0B    call $0B8F		; restaura los mínimos valores visibles de pantalla a los valores del personaje que sigue la cámara
0B85: FD 7E 04    ld   a,(iy+$04)	; obtiene la altura del personaje
0B88: 32 BA 2D    ld   ($2DBA),a	; fija la altura base de la planta con la altura del personaje y los graba en el motor
0B8B: FD E1       pop  iy
0B8D: 37          scf				; fija el flag de acarreo
0B8E: C9          ret

; dada en iy la posición de un personaje, calcula los mínimos valores visibles de pantalla
0B8F: FD 7E 02    ld   a,(iy+$02)		; lee la posición en x del personaje
0B92: E6 F0       and  $F0				; se queda con la parte más significativa
0B94: D6 04       sub  $04				; se queda con la mínima posición visible en X
0B96: 32 A9 27    ld   ($27A9),a
0B99: FD 7E 03    ld   a,(iy+$03)		; lee la posición en y del personaje
0B9C: E6 F0       and  $F0				; se queda con la parte más significativa
0B9E: D6 04       sub  $04
0BA0: 32 9D 27    ld   ($279D),a
0BA3: FD 7E 04    ld   a,(iy+$04)		; lee la altura del personaje
0BA6: CD 73 24    call $2473			; dependiendo de la altura, devuelve la altura base de la planta en b
0BA9: 78          ld   a,b
0BAA: 32 BA 2D    ld   ($2DBA),a		; guarda la altura base de la planta
0BAD: C9          ret

; elimina todos los rastros de la búsqueda del buffer de alturas
0BAE: 01 40 02    ld   bc,$0240			; bc = 24*24
0BB1: 2A 8A 2D    ld   hl,($2D8A)		; obtiene un puntero al buffer de alturas de la pantalla actual
0BB4: 7E          ld   a,(hl)
0BB5: E6 3F       and  $3F
0BB7: 77          ld   (hl),a			; elimina los rastros de la búsqueda del buffer de alturas
0BB8: 23          inc  hl
0BB9: 0B          dec  bc
0BBA: 78          ld   a,b
0BBB: B1          or   c
0BBC: 20 F6       jr   nz,$0BB4			; repite hasta que haya borrado todos los rastros de la búsqueda
0BBE: C9          ret

; rellena en un buffer las alturas de la pantalla actual del personaje indicado por iy, marca las casillas ocupadas por los personajes
; que están cerca de la pantalla actual y por las puertas y limpia las casillas que ocupa el personaje que llama a esta rutina
0BBF: 11 F4 96    ld   de,$96F4		; cambia el puntero al buffer de alturas de la pantalla actual
0BC2: ED 53 8A 2D ld   ($2D8A),de
0BC6: CD 22 2D    call $2D22		; rellena el buffer de alturas con los datos recortados para la pantalla en la que está el personaje indicado por iy
0BC9: 3A 38 30    ld   a,($3038)	; obtiene la posición x de guillermo
0BCC: FD 4E 02    ld   c,(iy+$02)	; obtiene la posición x del personaje
0BCF: CD 75 0C    call $0C75		; calcula la distancia en x entre la parte más significativa de las posiciones a y c, e indica si es >= 2
0BD2: 47          ld   b,a			; b = distancia que les separa en x + 1
0BD3: 30 1F       jr   nc,$0BF4		; si la distancia es >= 2, salta

0BD5: 3A 39 30    ld   a,($3039)	; obtiene la posición y de guillermo
0BD8: FD 4E 03    ld   c,(iy+$03)	; obtiene la posición y del personaje
0BDB: CD 75 0C    call $0C75		; calcula la distancia en y entre la parte más significativa de las posiciones a y c, e indica si es >= 2
0BDE: 4F          ld   c,a			; b = distancia que les separa en x + 1
0BDF: 30 13       jr   nc,$0BF4		; si la distancia es >= 2, salta
0BE1: C5          push bc
0BE2: FD 7E 04    ld   a,(iy+$04)	; obtiene la altura del personaje
0BE5: CD 73 24    call $2473		; dependiendo de la altura, devuelve la altura base de la planta en b
0BE8: 48          ld   c,b
0BE9: 3A 3A 30    ld   a,($303A)	; obtiene la altura de guillermo
0BEC: CD 73 24    call $2473		; dependiendo de la altura, devuelve la altura base de la planta en b
0BEF: 78          ld   a,b
0BF0: B9          cp   c
0BF1: C1          pop  bc
0BF2: 28 23       jr   z,$0C17		; si los personajes están en la misma planta, salta

; aquí llega si la distancia entre guillermo y el personaje es >= 2 en alguna coordenada, o no están en la misma planta
0BF4: 3A 75 2D    ld   a,($2D75)	; obtiene la parte más significativa de la posición en x del personaje que se muestra en pantalla
0BF7: FD 4E 02    ld   c,(iy+$02)	; obtiene la posición x del personaje
0BFA: CD 75 0C    call $0C75		; calcula la distancia entre la parte más significativa de las posiciones a y c, e indica si es >= 2
0BFD: 47          ld   b,a			; b = distancia en x + 1
0BFE: D0          ret  nc			; si la distancia en x es >= 2, sale
0BFF: 3A 76 2D    ld   a,($2D76)	; obtiene la parte más significativa de la posición en y del personaje que se muestra en pantalla
0C02: FD 4E 03    ld   c,(iy+$03)	; obtiene la posición y del personaje
0C05: CD 75 0C    call $0C75		; calcula la distancia entre la parte más significativa de las posiciones a y c, e indica si es >= 2
0C08: 4F          ld   c,a			; c = distancia en y + 1
0C09: D0          ret  nc			; si la distancia en y es >= 2, salta
0C0A: C5          push bc
0C0B: FD 7E 04    ld   a,(iy+$04)	; obtiene la altura del personaje
0C0E: CD 73 24    call $2473		; dependiendo de la altura, devuelve la altura base de la planta en b
0C11: 3A 77 2D    ld   a,($2D77)	; obtiene la altura del personaje al que sigue la cámara
0C14: B8          cp   b
0C15: C1          pop  bc
0C16: C0          ret  nz			; si el personaje no está en la misma planta que el personaje la que sigue la cámara, sale

; aquí llega si al personaje y a guillermo les separa poca distancia en la misma planta, o al personaje y a quien muestra la cámara les separa poca distancia en la misma planta
; bc = distancia en x y en y del personaje que estaba cerca
0C17: FD 22 30 0C ld   ($0C30),iy	; modifica una instrucción
0C1B: 21 BA 2B    ld   hl,$2BBA		; apunta a una dirección que contiene un puntero a los datos de posición de adso
0C1E: 78          ld   a,b			; a = distancia en x + 1
0C1F: FE 01       cp   $01
0C21: 06 05       ld   b,$05		; comprueba 5 personajes
0C23: 20 09       jr   nz,$0C2E		; si la distancia en x + 1 no es 1, salta
0C25: 79          ld   a,c			; a = distancia en y + 1
0C26: FE 01       cp   $01
0C28: 20 04       jr   nz,$0C2E		; si la distancia en y + 1 no es 1, salta

; si la distancia con el personaje que estaba cerca es muy pequeña, empieza a dibujar en guillermo
0C2A: 21 B0 2B    ld   hl,$2BB0		; apunta a una dirección que contiene un puntero a los datos de posición guillermo
0C2D: 04          inc  b			; comprueba 6 personajes

0C2E: C5          push bc
0C2F: 01 00 00    ld   bc,$0000		; instrucción modificada con la dirección de datos del personaje
0C32: 5E          ld   e,(hl)
0C33: 23          inc  hl
0C34: 56          ld   d,(hl)		; de = dirección de los datos de posición del personaje a comprobar
0C35: 23          inc  hl
0C36: 7A          ld   a,d			; a = parte superior de la dirección del personaje a comprobar
0C37: A8          xor  b
0C38: 20 04       jr   nz,$0C3E		; si no coincide con la del personaje, salta
0C3A: 7B          ld   a,e			; a = parte inferior de la dirección del personaje a comprobar
0C3B: A9          xor  c
0C3C: 28 0A       jr   z,$0C48		; si coincide con la del personaje, salta

; aquí llega si el personaje que se le ha pasado a la rutina no es el que se está comprobando
0C3E: E5          push hl
0C3F: D5          push de
0C40: FD E1       pop  iy			; iy apunta a la dirección del personaje que se está comprobando
0C42: 0E 10       ld   c,$10
0C44: CD EF 28    call $28EF		; si la posición del sprite es central y la altura está bien, rellena en el buffer de alturas las posiciones ocupadas por el personaje
0C47: E1          pop  hl

0C48: 01 08 00    ld   bc,$0008		; avanza al siguiente personaje
0C4B: 09          add  hl,bc
0C4C: C1          pop  bc
0C4D: 10 DF       djnz $0C2E		; repite mientras queden personajes por probar

0C4F: FD 21 E4 2F ld   iy,$2FE4		; iy apunta a los datos de las puertas
0C53: 11 05 00    ld   de,$0005		; cada entrada es de 5 bytes

0C56: 3E 0F       ld   a,$0F		; 0x0f = altura en el buffer de alturas de una puerta cerrada
0C58: FD CB 01 76 bit  6,(iy+$01)	; si la puerta está abierta, marca su posición en el buffer de alturas
0C5C: C4 19 0E    call nz,$0E19
0C5F: 11 05 00    ld   de,$0005
0C62: FD 19       add  iy,de		; avanza a la siguiente puerta
0C64: FD 7E 00    ld   a,(iy+$00)
0C67: FE FF       cp   $FF
0C69: 20 EB       jr   nz,$0C56		; repite hasta que se completen las puertas
0C6B: FD 2A 30 0C ld   iy,($0C30)	; recuera la dirección de datos del personaje
0C6F: 0E 00       ld   c,$00
0C71: CD EF 28    call $28EF		; si la posición del sprite es central y la altura está bien, limpia las posiciones que ocupa del buffer de alturas
0C74: C9          ret

; calcula la distancia entre la parte más significativa de las posiciones a y c, e indica si es >= 2
0C75: CB 39       srl  c		; deja en el nibble inferior de c la parte de la posición más significativa
0C77: CB 39       srl  c
0C79: CB 39       srl  c
0C7B: CB 39       srl  c
0C7D: CB 3F       srl  a		; deja en el nibble inferior de a la parte de la posición más significativa
0C7F: CB 3F       srl  a
0C81: CB 3F       srl  a
0C83: CB 3F       srl  a
0C85: 91          sub  c		; a = a - c + 1
0C86: 3C          inc  a
0C87: FE 03       cp   $03		; si a = 0, 1 ó 2, CF = 1. Es decir, si la distancia era -1, 0 ó 1
0C89: C9          ret

; tabla para marcar las posiciones a las que debe ir el personaje
; bytes 0-1: rutina a llamar según la orientación que debe seguir el personaje para marcar la salida de la pantalla
; byte 2: posición x de destino
; byte 3: posición y de destino
0C8A: 	0CAC 16 0C -> (22, 12) -> marca como punto de destino cualquiera que vaya a la pantalla de la derecha
 		0C9A 0C 02 -> (12, 02) -> marca como punto de destino cualquiera que vaya a la pantalla de arriba
 		0CB4 02 0C -> (02, 12) -> marca como punto de destino cualquiera que vaya a la pantalla de izquierda
 		0CB9 0C 16 -> (12, 22) -> marca como punto de destino cualquiera que vaya a la pantalla de abajo

 ; marca como punto de destino cualquiera que vaya a la pantalla de arriba
0C9A: 01 4C 00    ld   bc,$004C		; bc = 76 (X = 4, Y = 3)
0C9D: 11 01 00    ld   de,$0001		; de = 1
0CA0: 2A 8A 2D    ld   hl,($2D8A)	; hl = puntero al buffer de alturas de la pantalla actual
0CA3: 09          add  hl,bc		; obtiene la posición inicial del buffer de tiles

0CA4: 06 10       ld   b,$10		; 16 posiciones
0CA6: CB F6       set  6,(hl)		; indica que es una dirección a la que quiere ir
0CA8: 19          add  hl,de		; avanza la posición del buffer de tiles
0CA9: 10 FB       djnz $0CA6		; repite para las 10 posiciones
0CAB: C9          ret

; marca como punto de destino cualquiera que vaya a la pantalla de la derecha
0CAC: 01 74 00    ld   bc,$0074		; bc = 116 (X = 20, Y = 4)
0CAF: 11 18 00    ld   de,$0018		; de = 24
0CB2: 18 EC       jr   $0CA0		; salta a marcar las posiciones con incremento de +24

; marca como punto de destino cualquiera que vaya a la pantalla de la izquierda
0CB4: 01 63 00    ld   bc,$0063		; bc = 99 (X = 3, Y = 4)
0CB7: 18 F6       jr   $0CAF		; salta a marcar las posiciones con incremento de +24

; marca como punto de destino cualquiera que vaya a la pantalla de abajo
0CB9: 01 E4 01    ld   bc,$01E4		; bc = 484 (X = 4, Y = 20)
0CBC: 18 DF       jr   $0C9D		; salta a marcar las posiciones con incremento de +1

; si la posición no es una de las del centro de la pantalla o la altura del personaje no coincide con la altura base de la planta, sale con CF=1
; en otro caso, devuelve en ix un puntero a la entrada de la tabla de alturas de la posición correspondiente
; llamado con iy = dirección de los datos de posición asociados al personaje/objeto
0CBE: FD 7E 04    ld   a,(iy+$04)	; obtiene la altura del personaje
0CC1: CD 73 24    call $2473		; dependiendo de la altura, devuelve la altura base de la planta en b
0CC4: 3A BA 2D    ld   a,($2DBA)	; obtiene la altura base de la planta
0CC7: B8          cp   b
0CC8: 37          scf
0CC9: C0          ret  nz			; si las alturas son distintas, sale con el CF puesto

0CCA: FD 6E 02    ld   l,(iy+$02)	; hl = posición del personaje
0CCD: FD 66 03    ld   h,(iy+$03)
0CD0: CD 9B 27    call $279B		; ajusta la posición pasada en hl a las 20x20 posiciones centrales que se muestran. Si la posición está fuera, CF=1
0CD3: D8          ret  c			; si la posición está fuera del centro de la pantalla, sale

; indexa en la tabla de alturas con hl y devuelve la dirección correspondiente en ix
0CD4: 7D          ld   a,l
0CD5: 6C          ld   l,h
0CD6: 26 00       ld   h,$00
0CD8: 29          add  hl,hl
0CD9: 29          add  hl,hl
0CDA: 29          add  hl,hl	; hl = hl*8
0CDB: 54          ld   d,h		; de = hl*8 + a
0CDC: 85          add  a,l
0CDD: 5F          ld   e,a
0CDE: 29          add  hl,hl	; hl = hl*16
0CDF: 19          add  hl,de
0CE0: DD 2A 8A 2D ld   ix,($2D8A)	; ix = puntero al buffer de alturas de la pantalla actual
0CE4: EB          ex   de,hl
0CE5: DD 19       add  ix,de		; indexa en la tabla
0CE7: A7          and  a
0CE8: C9          ret

; escribe b bits del comando que se le pasa en hl del personaje pasado en iy
;  iy = apunta a los datos de posición del personaje
;  b = longitud del comando
;  hl = datos del comando
0CE9: FD 7E 09    ld   a,(iy+$09)	; lee el contador
0CEC: FE 08       cp   $08
0CEE: 20 17       jr   nz,$0D07		; si no es 8, salta

; aquí llega cuando se ha procesado un byte completo
0CF0: FD 36 09 00 ld   (iy+$09),$00	; si llega a 8 se reinicia
0CF4: FD 7E 0B    ld   a,(iy+$0b)	; lee el índice de la tabla de bc
0CF7: FD 86 0C    add  a,(iy+$0c)
0CFA: 5F          ld   e,a
0CFB: FD 8E 0D    adc  a,(iy+$0d)
0CFE: 93          sub  e
0CFF: 57          ld   d,a			; de = dirección[indice]
0D00: FD 34 0B    inc  (iy+$0b)		; incrementa el índice de la tabla
0D03: FD 7E 0A    ld   a,(iy+$0a)	; lee el comando y lo escribe en la posición anterior

0D07: 29          add  hl,hl		; mete en el CF el bit más significativo
0D08: FD CB 0A 16 rl   (iy+$0a)		; rota el valor a la izquierda y mete el CF como bit 0
0D0C: FD 34 09    inc  (iy+$09)		; incrementa el contador
0D0F: 05          dec  b
0D10: 20 D7       jr   nz,$0CE9		; mientras que no se haya terminado el comando, copia los bits
0D12: C9          ret

; ---------------- fin del algoritmo de alto nivel para la búsqueda de caminos entre 2 posiciones -------------------------

; ----------- código para procesar los objetos y las puertas -----------------------

; llega con ix = sprite del objeto que se deja
; llega con iy = datos del objeto que se deja
0D13: 3E C9       ld   a,$C9
0D15: 32 64 0D    ld   ($0D64),a		; hace que solo procese un objeto de la lista
0D18: 21 BB 0D    ld   hl,$0DBB			; rutina a la que saltar para procesar los objetos del juego
0D1B: CD 3B 0D    call $0D3B			; llama a la rutina para que se redibuje el objeto
0D1E: AF          xor  a
0D1F: 32 64 0D    ld   ($0D64),a		; restaura la rutina de los objetos
0D22: C9          ret

; rutina llamada cuando se cambia de pantalla para procesar los objetos del juego que podemos coger
0D23: 21 BB 0D    ld   hl,$0DBB			; rutina a la que saltar para procesar los objetos del juego
0D26: DD 21 1B 2F ld   ix,$2F1B			; apunta a los sprites de los objetos del juego
0D2A: FD 21 08 30 ld   iy,$3008			; apunta a los datos de posición de los objetos del juego
0D2E: 18 0B       jr   $0D3B			; procesa los objetos

; rutina llamada cuando se cambia de pantalla para procesar las puertas
0D30: 21 D2 0D    ld   hl,$0DD2			; rutina a la que saltar para procesar los sprites de las puertas
0D33: DD 21 8F 2E ld   ix,$2E8F			; apunta a los sprites de las puertas
0D37: FD 21 E4 2F ld   iy,$2FE4			; apunta a los datos de las puertas

0D3B: 22 4A 0D    ld   ($0D4A),hl		; modifica la instrucción para saber a que rutina saltar
0D3E: FD 7E 00    ld   a,(iy+$00)		; lee un byte y si encuentra 0xff termina
0D41: FE FF       cp   $FF
0D43: C8          ret  z
0D44: CD 4C 0E    call $0E4C			; obtiene en hl la posición en pantalla del objeto. Si no es visible devuelve el CF = 1
0D47: DD E5       push ix				;  si el objeto es visible, salta a la rutina siguiente
0D49: D4 D2 0D    call nc,$0DD2			; instrucción modificada desde fuera
0D4C: DD E1       pop  ix
0D4E: DD 7E 01    ld   a,(ix+$01)		; pone la posición actual del sprite como la posición antigua
0D51: DD 77 03    ld   (ix+$03),a
0D54: DD 7E 02    ld   a,(ix+$02)
0D57: DD 77 04    ld   (ix+$04),a
0D5A: 01 05 00    ld   bc,$0005			; avanza la entrada
0D5D: FD 09       add  iy,bc
0D5F: 01 14 00    ld   bc,$0014			; apunta al siguiente sprite
0D62: DD 09       add  ix,bc
0D64: 00          nop					; cambiado desde fuera (ret o nop)
0D65: 18 D7       jr   $0D3E			; continua procesando los objetos

; ----------- fin del código para procesar los objetos y las puertas -----------------------

; --------------------- código relacionado con las puertas --------------------------------------------

0D67: DD 21 8F 2E ld   ix,$2E8F			; apunta a los sprites de las puertas
0D6B: FD 21 E4 2F ld   iy,$2FE4			; apunta a los datos de las puertas
0D6F: AF          xor  a
0D70: 32 AF 2D    ld   ($2DAF),a		; indica que la puerta no requiere los gráficos flipeados
0D73: FD 7E 00    ld   a,(iy+$00)		; si ha llegado a la última entrada, sale
0D76: FE FF       cp   $FF
0D78: C8          ret  z

; comprueba si hay que abrir o cerrar alguna puerta y actualiza los sprites en consecuencia
0D79: AF          xor  a
0D7A: 32 FF 0D    ld   ($0DFF),a		; modifica una instrucción (inicialmente no hay que redibujar el sprite)
0D7D: DD E5       push ix
0D7F: CD AD 0E    call $0EAD			; comprueba si hay que abrir o cerrar esta puerta
0D82: DD E1       pop  ix
0D84: CD 4C 0E    call $0E4C			; devuelve la posición del objeto en coordenadas de pantalla. Si no es visible devuelve el CF = 1
0D87: DD E5       push ix				; si CF=0, en c devuelve la coordenada y del sprite en pantalla (-16) y en hl devuelve la posición en pantalla del sprite
0D89: D4 D2 0D    call nc,$0DD2			; si la puerta es visible, dibuja el sprite (si ha cambiado el estado de la puerta) y marca las posiciones que ocupa la puerta para no poder avanzar a través de ella
0D8C: DD E1       pop  ix
0D8E: 3A B8 2D    ld   a,($2DB8)		: lee si se va a redibujar la pantalla
0D91: A7          and  a
0D92: 20 1B       jr   nz,$0DAF			; si se va a redibujar la pantalla, pasa a la siguiente puerta

; aquí llega si no se va a redibujar la pantalla
0D94: DD 7E 00    ld   a,(ix+$00)		; lee el sprite de la puerta
0D97: FE FE       cp   $FE
0D99: 28 14       jr   z,$0DAF			; si la puerta no es visible, pasa a la siguiente puerta
0D9B: CB 7F       bit  7,a
0D9D: 28 10       jr   z,$0DAF			; si la puerta no se redibuja, pasa a la siguiente puerta
0D9F: DD E5       push ix
0DA1: FD CB 01 76 bit  6,(iy+$01)		; si la puerta se redibuja, pone un sonido dependiendo de su estado
0DA5: F5          push af
0DA6: C4 1B 10    call nz,$101B			; si el bit 6 era 1, pone el sonido de abrir la puerta
0DA9: F1          pop  af
0DAA: CC 16 10    call z,$1016			; si el bit 6 era 0, pone el sonido de cerrar la puerta
0DAD: DD E1       pop  ix

0DAF: 01 05 00    ld   bc,$0005			; avanza a la siguiente puerta
0DB2: FD 09       add  iy,bc
0DB4: 01 14 00    ld   bc,$0014
0DB7: DD 09       add  ix,bc
0DB9: 18 B8       jr   $0D73

; rutina llamada cuando los objetos del juego son visibles en la pantalla actual
; si no se dibujaba el objeto, ajusta la posición y lo marca para que se dibuje
; ix apunta al sprite del objeto
; iy apunta a los datos del objeto
; hl continene la posición en pantalla del objeto
; c = la coordenada y del sprite en pantalla (-16)
0DBB: FD CB 00 7E bit  7,(iy+$00)	; si el objeto ya se ha cogido, sale
0DBF: C0          ret  nz
0DC0: CB F9       set  7,c			; indica que hay que pintar el objeto
0DC2: DD 71 00    ld   (ix+$00),c	; actualiza la profundidad del objeto dentro del buffer de tiles
0DC5: 7C          ld   a,h
0DC6: D6 08       sub  $08
0DC8: DD 77 02    ld   (ix+$02),a	; modifica la posición y del objeto (-8 pixels)
0DCB: 7D          ld   a,l
0DCC: D6 02       sub  $02
0DCE: DD 77 01    ld   (ix+$01),a	; modifica la posición x del objeto (-8 pixels)
0DD1: C9          ret

; rutina llamada cuando las puertas son visibles en la pantalla actual
; se encarga de modificar la posición del sprite según la orientación, modificar el buffer de alturas para indicar si se puede pasar
;  por la zona de la puerta o no, colocar el gráfico de las puertas y modificar 0x2daf
; ix apunta al sprite de una puerta
; iy apunta a los datos de la puerta
; hl continene la posición en pantalla del objeto
; c tiene la profundidad de la puerta en pantalla
0DD2: EB          ex   de,hl			; de = posición en pantalla del objeto
0DD3: CD B0 2A    call $2AB0			; pone la posición y dimensiones actuales del sprite como posición y dimensiones antiguas
0DD6: C5          push bc
0DD7: CD 7C 0E    call $0E7C			; lee en bc 2 valores relacionados con la orientación y modifica la posición del sprite (en coordenadas locales) según la orientación
0DDA: 21 AD 05    ld   hl,$05AD			; apunta a la tabla de desplazamientos relacionada con las orientaciones de las puertas
0DDD: FD 7E 00    ld   a,(iy+$00)		; lee la orientación de la puerta
0DE0: E6 03       and  $03
0DE2: CD 80 24    call $2480			; modifica la orientación que se le pasa en a con la orientación de la pantalla actual
0DE5: 87          add  a,a				; cada entrada ocupa 8 bytes
0DE6: 87          add  a,a
0DE7: 87          add  a,a
0DE8: CD 2D 16    call $162D			; indexa en la tabla
0DEB: 7E          ld   a,(hl)
0DEC: 83          add  a,e
0DED: 81          add  a,c
0DEE: DD 77 01    ld   (ix+$01),a		; modifica la posición x del sprite
0DF1: 23          inc  hl
0DF2: 7E          ld   a,(hl)
0DF3: 82          add  a,d
0DF4: 80          add  a,b
0DF5: DD 77 02    ld   (ix+$02),a		; modifica la posición y del sprite
0DF8: 23          inc  hl
0DF9: 7E          ld   a,(hl)
0DFA: C1          pop  bc				; recupera la profundidad
0DFB: 81          add  a,c
0DFC: F6 80       or   $80				; instrucción modificada desde fuera. Si se pinta la pantalla, 0x80, en otro caso 0
0DFE: F6 00       or   $00				; instrucción modificada desde fuera (or 0x00 o or 0x80 si se pinta la puerta)
0E00: DD 77 00    ld   (ix+$00),a
0E03: 23          inc  hl
0E04: 3A AF 2D    ld   a,($2DAF)		; lee si la puerta necesita gráficos flipeados o no
0E07: B6          or   (hl)
0E08: 32 AF 2D    ld   ($2DAF),a
0E0B: CD 8C 0E    call $0E8C			; modifica la posición x e y del sprite en la rejilla según los 2 siguientes valores de hl
0E0E: 11 49 AA    ld   de,$AA49			; coloca la dirección del gráfico de la puerta en el sprite
0E11: DD 73 07    ld   (ix+$07),e
0E14: DD 72 08    ld   (ix+$08),d
0E17: 3E 0F       ld   a,$0F

0E19: CD 2C 0E    call $0E2C			; lee en bc un valor relacionado con el desplazamiento de la puerta en el buffer de alturas
0E1C: D8          ret  c				; si el objeto no es visible, sale. En otro caso, devuelve en ix un puntero a la entrada de la tabla de alturas de la posición correspondiente
0E1D: 08          ex   af,af'			; recupera a
0E1E: DD 77 00    ld   (ix+$00),a		; marca la altura de esta posición del buffer de alturas
0E21: DD 09       add  ix,bc
0E23: DD 77 00    ld   (ix+$00),a		; marca la altura de la siguiente posición del buffer de alturas
0E26: DD 09       add  ix,bc
0E28: DD 77 00    ld   (ix+$00),a		; marca la altura de la siguiente posición del buffer de alturas
0E2B: C9          ret

; lee en bc el desplazamiento para el buffer de alturas, y si la puerta es visible devuelve en ix un puntero a la entrada de la tabla de alturas de la posición correspondiente
0E2C: 08          ex   af,af'
0E2D: FD 7E 00    ld   a,(iy+$00)	; obtiene la orientación de la puerta
0E30: E6 03       and  $03
0E32: 21 44 0E    ld   hl,$0E44		; apunta a la tabla de desplazamientos en el buffer de alturas relacionada con la orientación de las puertas
0E35: 87          add  a,a			; cada entrada ocupa 2 bytes
0E36: CD 2D 16    call $162D		; indexa en la tabla
0E39: 4E          ld   c,(hl)
0E3A: 23          inc  hl
0E3B: 46          ld   b,(hl)		; bc = [hl]
0E3C: D5          push de
0E3D: C5          push bc
0E3E: CD BE 0C    call $0CBE		; si la posición no es una de las del centro de la pantalla o la altura del personaje no coincide con la altura base de la planta, sale con CF=1
0E41: C1          pop  bc			;  en otro caso, devuelve en ix un puntero a la entrada de la tabla de alturas de la posición correspondiente
0E42: D1          pop  de
0E43: C9          ret

; tabla de desplazamientos en el buffer de alturas relacionada con la orientación de las puertas
0E44: 	0001 -> +01
		FFE8 -> -24
		FFFF -> -01
		0018 -> +24

; devuelve la posición la entidad en coordenadas de pantalla. Si no es visible sale con CF = 1
; si CF=0, en c devuelve profundidad del sprite y en hl devuelve la posición en pantalla del sprite
0E4C: 3E C9       ld   a,$C9
0E4E: 32 2F 2B    ld   ($2B2F),a	; modifica una instrucción poniendo un ret, para que la rutina de 0x2add devuelva la posición en pantalla del sprite
0E51: CD 5A 0E    call $0E5A		; procesa los objetos

; aquí llega si el sprite es visible
0E54: 4F          ld   c,a			; obtiene la coordenada y del sprite en pantalla -16 (la profundidad)
0E55: AF          xor  a
0E56: 32 2F 2B    ld   ($2B2F),a	; modifica una instrucción poniendo un nop
0E59: C9          ret

0E5A: CD DD 2A    call $2ADD		; procesa el objeto y obtiene su dirección en pantalla

; si el sprite no es visible, llega aquí
0E5D: D1          pop  de			; obtiene la dirección de retorno
0E5E: DD 36 00 FE ld   (ix+$00),$FE ; marca el sprite como no visible
0E62: AF          xor  a
0E63: 37          scf				; pone el flag de acarreo
0E64: 18 F0       jr   $0E56

; comprueba si tiene que flipear los gráficos de las puertas
0E66: 3A AF 2D    ld   a,($2DAF)	; lee el estado de flipx que espera la puerta
0E69: 4F          ld   c,a
0E6A: 3A 78 2D    ld   a,($2D78)	; lee si las puertas están flipeadas o no
0E6D: A9          xor  c
0E6E: C8          ret  z			; si están en el estado que se necesita, sale
0E6F: 79          ld   a,c
0E70: 32 78 2D    ld   ($2D78),a	; en otro caso, flipea los gráficos
0E73: 01 06 28    ld   bc,$2806		; ancho y alto del sprite de la puerta
0E76: 21 49 AA    ld   hl,$AA49		; hl apunta al gráfico de las puertas
0E79: C3 52 35    jp   $3552		; flipea los gráficos de la puerta

; lee en bc 2 valores relacionados con la orientación y modifica la posición del sprite (en coordenadas locales) según la orientación
; ix apunta al sprite de una puerta
0E7C: 21 9D 0E    ld   hl,$0E9D		; apunta a la tabla relacionada con el desplazamiento de las puertas y la orientación
0E7F: 3E 03       ld   a,$03		; orientación hacia +y
0E81: CD 80 24    call $2480		; modifica la orientación que se le pasa en a con la orientación de la pantalla actual
0E84: 87          add  a,a			; a = a*4 (cada entrada ocupa 4 bytes)
0E85: 87          add  a,a
0E86: CD 2D 16    call $162D		; indexa en la tabla
0E89: 4E          ld   c,(hl)		; lee los valores a sumar a la posición en coordenadas de pantalla del sprite de la puerta
0E8A: 23          inc  hl
0E8B: 46          ld   b,(hl)
0E8C: 23          inc  hl
0E8D: DD 7E 12    ld   a,(ix+$12)	; modifica la posición x de la rejilla según la orientación de la cámara con el valor leido
0E90: 86          add  a,(hl)
0E91: DD 77 12    ld   (ix+$12),a
0E94: 23          inc  hl
0E95: DD 7E 13    ld   a,(ix+$13)	; modifica la posición x de la rejilla según la orientación de la cámara con el valor leido
0E98: 86          add  a,(hl)
0E99: DD 77 13    ld   (ix+$13),a
0E9C: C9          ret

; tabla relacionada con el desplazamiento de las puertas y la orientación
; cada entrada ocupa 4 bytes
; byte 0: valor a sumar a la posición x en coordenadas de pantalla del sprite de la puerta
; byte 1: valor a sumar a la posición y en coordenadas de pantalla del sprite de la puerta
; byte 2: valor a sumar a la posición x en coordenadas locales del sprite de la puerta
; byte 3: valor a sumar a la posición y en coordenadas locales del sprite de la puerta
0E9D: 	02 00 00 FF -> +2 00 00 -1
		00 FC FF FF -> 00 -4 -1 -1
		FE 00 FF 00 -> -2 00 -1 00
		00 04 00 00 -> 00 +4 00 00

; comprueba si hay que abrir o cerrar una puerta
; iy apunta a los datos de las puertas
0EAD: FD 7E 01    ld   a,(iy+$01)
0EB0: CB 7F       bit  7,a			; si la puerta se queda fija, sale
0EB2: C0          ret  nz
0EB3: FD 5E 02    ld   e,(iy+$02)	; obtiene las coordenadas x e y de la puerta
0EB6: FD 56 03    ld   d,(iy+$03)
0EB9: 1D          dec  e
0EBA: 1D          dec  e
0EBB: 15          dec  d
0EBC: 15          dec  d
0EBD: E6 1F       and  $1F			; obtiene que puerta es
0EBF: 4F          ld   c,a
0EC0: 21 A6 3C    ld   hl,$3CA6		; apunta a a las puertas que se pueden abrir
0EC3: 7E          ld   a,(hl)
0EC4: F6 10       or   $10			; añade a la máscara la puerta del pasadizo detrás de la cocina
0EC6: A1          and  c			; combina la máscara con la puerta actual
0EC7: 4F          ld   c,a
0EC8: 3A DC 2D    ld   a,($2DDC)	; lee las puertas a las que puede entrar adso
0ECB: 21 D9 2D    ld   hl,$2DD9		; apunta a las puertas a las que puede entrar guillermo
0ECE: CD 6C 0F    call $0F6C		; comprueba si guillermo está cerca de una puerta que no tiene permisos para abrir
0ED1: 38 73       jr   c,$0F46		; si es así, comprueba si hay que cerrarla
0ED3: 3A D9 2D    ld   a,($2DD9)	; lee las puertas a las que puede entrar guillermo
0ED6: 21 DC 2D    ld   hl,$2DDC		; apunta a las puertas a las que puede entrar adso
0ED9: CD 6C 0F    call $0F6C		; comprueba si adso está cerca de una puerta que no tiene permisos para abrir
0EDC: 38 68       jr   c,$0F46		; si es así, comprueba si hay que cerrarla

0EDE: 21 D9 2D    ld   hl,$2DD9		; apunta a los permisos del primer personaje
0EE1: 1C          inc  e
0EE2: 14          inc  d

0EE3: 7E          ld   a,(hl)
0EE4: 23          inc  hl
0EE5: FE FF       cp   $FF
0EE7: 28 5D       jr   z,$0F46		; si se han procesado todas las entradas, salta a ver si hay que cerrar la puerta
0EE9: A1          and  c
0EEA: 20 04       jr   nz,$0EF0		; si este personaje tiene permisos para abrir esta puerta, salta
0EEC: 23          inc  hl
0EED: 23          inc  hl
0EEE: 18 F3       jr   $0EE3		; avanza a las permisos de las puertas del siguiente personaje

; aquí llega si alguien tiene permisos para abrir una puerta
0EF0: CD 7C 0F    call $0F7C		; devuelve la posición del personaje que puede abrir la puerta
0EF3: 93          sub  e
0EF4: FE 04       cp   $04
0EF6: 30 EB       jr   nc,$0EE3		; si no está cerca en x, salta a procesar el siguiente personaje
0EF8: 78          ld   a,b
0EF9: 92          sub  d
0EFA: FE 04       cp   $04			; si no está cerca en y, salta a procesar el siguiente personaje
0EFC: 30 E5       jr   nc,$0EE3
0EFE: FD CB 01 76 bit  6,(iy+$01)	; si la puerta está abierta, sale
0F02: C0          ret  nz
0F03: FD 4E 00    ld   c,(iy+$00)	; guarda la orientación y el estado de la puerta por si hay que restaurarlo luego
0F06: FD 46 01    ld   b,(iy+$01)
0F09: D9          exx
0F0A: FD CB 01 F6 set  6,(iy+$01)	; marca la puerta como abierta
0F0E: 3E 80       ld   a,$80
0F10: 32 FF 0D    ld   ($0DFF),a	; modifica una instrucción para que haya que redibujar un sprite
0F13: FD 7E 04    ld   a,(iy+$04)	; obtiene la altura a la que está situada la puerta
0F16: CD 19 0E    call $0E19		; modifica el buffer de alturas ya que cuando se abre la puerta se debe poder pasar
0F19: FD 35 00    dec  (iy+$00)		; cambia la orientación de la puerta
0F1C: FD CB 01 6E bit  5,(iy+$01)
0F20: 20 06       jr   nz,$0F28		; si el bit 5 está puesto, salta
0F22: FD 34 00    inc  (iy+$00)		; cambia la orientación de la puerta
0F25: FD 34 00    inc  (iy+$00)
0F28: CD 2C 0E    call $0E2C		; lee en bc el desplazamiento de la puerta para el buffer de alturas, y si la puerta es visible
0F2B: DD 09       add  ix,bc		; devuelve en ix un puntero a la entrada de la tabla de alturas de la posición correspondiente
0F2D: DD 09       add  ix,bc
0F2F: D9          exx
0F30: DD 7E 00    ld   a,(ix+$00)	; lee si hay algún personaje en la posición en la que se abre la puerta
0F33: E6 F0       and  $F0
0F35: C8          ret  z			; si no es así, sale
0F36: FD 71 00    ld   (iy+$00),c	; si hay algún personaje, restaura la configuración de la puerta
0F39: FD 70 01    ld   (iy+$01),b
0F3C: AF          xor  a
0F3D: 32 FF 0D    ld   ($0DFF),a	; modifica una instrucción para que no haya que redibujar el sprite
0F40: FD 7E 04    ld   a,(iy+$04)	; obtiene la altura a la que está situada la puerta
0F43: C3 19 0E    jp   $0E19		; modifica el buffer de alturas con la altura de la puerta

; aqui llega para comprobar si hay que cerrar la puerta puerta
0F46: FD CB 01 76 bit  6,(iy+$01)	; si la puerta está cerrada, sale
0F4A: C8          ret  z

0F4B: FD 4E 00    ld   c,(iy+$00)	; guarda la orientación y el estado de la puerta por si hay que restaurarlo luego
0F4E: FD 46 01    ld   b,(iy+$01)
0F51: D9          exx
0F52: 3E 80       ld   a,$80
0F54: 32 FF 0D    ld   ($0DFF),a	; modifica una instrucción para que se redibuje el sprite
0F57: FD 7E 04    ld   a,(iy+$04)	; obtiene la altura a la que está situada la puerta
0F5A: CD 19 0E    call $0E19		; modifica el buffer de alturas las posiciones ocupadas por la puerta para que deje pasar
0F5D: FD CB 01 B6 res  6,(iy+$01)	; indica que la puerta está cerrada
0F61: FD 35 00    dec  (iy+$00)		; cambia la orientación de la puerta
0F64: FD CB 01 6E bit  5,(iy+$01)	; si el bit 5 está puesto, modifica la orientación
0F68: 28 BE       jr   z,$0F28
0F6A: 18 B6       jr   $0F22		; salta para redibujar el sprite

; comprueba si el personaje se acerca a una puerta que no puede abrir, y si es así, la cierra
0F6C: B6          or   (hl)		; combina las puertas a las que pueden entrar
0F6D: 23          inc  hl
0F6E: A1          and  c
0F6F: C0          ret  nz		; si tienen permisos para abrir la puerta, sale

0F70: CD 7C 0F    call $0F7C	; devuelve la posición del personaje que puede abrir la puerta
0F73: 93          sub  e		; compara la coordenada x del personaje con la coordenada x de la puerta
0F74: FE 06       cp   $06
0F76: D0          ret  nc		; si no está cerca sale
0F77: 78          ld   a,b		; repite con la y
0F78: 92          sub  d
0F79: FE 06       cp   $06
0F7B: C9          ret

; devuelve en ab lo que hay en [[hl]] e incrementa hl
0F7C: 7E          ld   a,(hl)		; ab = [hl]
0F7D: 23          inc  hl
0F7E: 46          ld   b,(hl)
0F7F: 23          inc  hl
0F80: E5          push hl
0F81: 6F          ld   l,a			; hl = ba
0F82: 60          ld   h,b
0F83: 7E          ld   a,(hl)		; ab = [hl]
0F84: 23          inc  hl
0F85: 46          ld   b,(hl)
0F86: E1          pop  hl
0F87: C9          ret

; --------------------- fin del código relacionado con las puertas --------------------------------------------

; limita las opciones a probar a la primera opción
0F88: 11 93 05    ld   de,$0593
0F8B: ED 53 A3 05 ld   ($05A3),de	; inicia el puntero al buffer de las alternativas
0F8F: 13          inc  de
0F90: 13          inc  de
0F91: 13          inc  de
0F92: 3E FF       ld   a,$FF		; marca el final del buffer después de la primera entrada
0F94: 12          ld   (de),a
0F95: C9          ret

; ---------------------------- sección de de código relacionada con la música ------------------------

0F96: máscara que indica en qué canales están activos los tonos y el generador de ruido
0F97: copia de la máscara que indica en qué canales están activos los tonos y el generador de ruido

0F98: contador que se va decrementando y al llegar a 0 actualiza las notas

0F99: periodo de la envolvente (byte bajo) relacionado con lo leido en 0x0a-0x0b + 0x0c
0F9A: periodo de la envolvente (byte alto) relacionado con lo leido en 0x0a-0x0b + 0x0c
0F9B: tipo de envolvente relacionado con lo leido en 0x0a-0x0b + 0x0c (solo guarda 4 lsb)

0F9C: periodo del generador de ruido (solo se usan los últimos 5 bits)

; tabla con los datos de generación de cada canal de sonido (registros de PSG + entrada del canal)
0F9D:
00 08 09
0FA0: 36 80 00 00 00 00 00 00 00 00 01 00 00 00 00 00 00 00 00 00 00
02 09 12
0FB8: 36 80 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
04 0A 24
0FD0: 36 80 00 00 00 00 00 00 00 00 00 00 00 00 00 1E 04 20 C7 21 F5

; tabla con tonos de la escala cromática
; la frecuencia se calcula como Freq = (1 MHz)/(16*Tono para el PSG), por lo que cada tono corresponde a:
0FE5: 	0EEE ; 0 -> frecuencia de C 	(octava 0) 16 Hz en el AY-8912, 16.4 teórico
		0E18 ; 1 -> frecuencia de C#	(octava 0) 17 Hz en el AY-8912, 17.3 teórico
		0D4D ; 2 -> frecuencia de D		(octava 0) 18 Hz en el AY-8912, 18.4 teórico
		0C8E ; 3 -> frecuencia de D#	(octava 0) 19 Hz en el AY-8912, 19.4 teórico
		0BDA ; 4 -> frecuencia de E		(octava 0) 20 Hz en el AY-8912, 20.6 teórico
		0B2F ; 5 -> frecuencia de F		(octava 0) 21 Hz en el AY-8912, 21.8 teórico
		0A8F ; 6 -> frecuencia de G		(octava 0) 23 Hz en el AY-8912, 23.1 teórico
		09F7 ; 7 -> frecuencia de G#	(octava 0) 24 Hz en el AY-8912, 24.5 teórico
		0968 ; 8 -> frecuencia de A		(octava 0) 25 Hz en el AY-8912, 26.0 teórico
		08E1 ; 9 -> frecuencia de A#	(octava 0) 27 Hz en el AY-8912, 27.5 teórico
		0861 ; A -> frecuencia de B		(octava 0) 29 Hz en el AY-8912, 29.1 teórico
		07E9 ; B -> frecuencia de B#	(octava 0) 30 Hz en el AY-8912, 30.9 teórico

0FFD: 21 80 14    ld   hl,$1480		; sonido ??? por el canal 1
1000: 18 3D       jr   $103F

1002: 21 96 14    ld   hl,$1496		; sonido de guillermo moviéndose por el canal 3
1005: 18 44       jr   $104B

1007: 21 FE 13    ld   hl,$13FE		; sonido ???
100A: 18 28       jr   $1034

100C: 21 F3 14    ld   hl,$14F3		; sonido ??? por el canal 1
100F: 18 2E       jr   $103F

1011: 21 BA 14    ld   hl,$14BA		; sonido de campanas después de la espiral cuadrada por el canal 1
1014: 18 29       jr   $103F

1016: 21 60 15    ld   hl,$1560		; sonido ??? por el canal 2
1019: 18 2A       jr   $1045

101B: 21 E7 14    ld   hl,$14E7		; sonido ??? por el canal 2
101E: 18 25       jr   $1045

1020: 21 B1 14    ld   hl,$14B1		; apunta a los datos
1023: 18 26       jr   $104B		; inicia el canal 3

1025: 21 9F 14    ld   hl,$149F		; sonido de coger/dejar objeto por el canal 1
1028: 18 1B       jr   $1045

102A: 21 50 15    ld   hl,$1550		; sonido ??? por el canal 1
102D: 18 16       jr   $1045

102F: 21 A8 14    ld   hl,$14A8		; sonido de coger/dejar objeto por el canal 1
1032: 18 11       jr   $1045

1034: DD 21 D0 0F ld   ix,$0FD0		; apunta al registro de control del canal 3
1038: DD 7E 0E    ld   a,(ix+$0e)
103B: A7          and  a
103C: C0          ret  nz
103D: 18 10       jr   $104F

103F: DD 21 A0 0F ld   ix,$0FA0			; apunta a la entrada 1
1043: 18 0A       jr   $104F			; inicia el canal
1045: DD 21 B8 0F ld   ix,$0FB8			; apunta a la entrada 2
1049: 18 04       jr   $104F			; inicia el canal
104B: DD 21 D0 0F ld   ix,$0FD0			; apunta a la entrada 3

; inicia el canal
104F: F3          di					; rellena parte de la entrada seleccionada
1050: DD 36 0E 05 ld   (ix+$0e),$05		; activa el sonido
1054: DD 75 00    ld   (ix+$00),l		; guarda la dirección de los datos de la música
1057: DD 74 01    ld   (ix+$01),h
105A: DD 36 02 01 ld   (ix+$02),$01		; fija la duración de la nota
105E: FB          ei					; habilita las interrupciones
105F: C9          ret

; genera la música (llamado desde la interrupción)
1060: F3          di
1061: F5          push af
1062: 3A AE 0F    ld   a,($0FAE)		; obtiene el valor de la primera entrada + 0x0e
1065: C5          push bc
1066: 4F          ld   c,a
1067: 3A C6 0F    ld   a,($0FC6)		; obtiene el valor de la segunda entrada + 0x0e
106A: B1          or   c
106B: 4F          ld   c,a
106C: 3A DE 0F    ld   a,($0FDE)		; obtiene el valor de la tercera entrada + 0x0e
106F: B1          or   c
1070: E6 01       and  $01				; si alguna de las 3 entradas tenían activo el bit 0, salta, en otro caso finaliza la interrupcion
1072: 20 05       jr   nz,$1079
1074: C1          pop  bc
1075: F1          pop  af
1076: FB          ei
1077: ED 4D       reti

; rutina que actualiza la música (según valga 0x0f98, el tempo es mayor o menor)
1079: E5          push hl
107A: D5          push de
107B: DD E5       push ix
107D: 3A 98 0F    ld   a,($0F98)		; decrementa el tempo de la música, pero lo mantiene entre 0 y [0x1086]
1080: 3D          dec  a
1081: FE FF       cp   $FF
1083: 20 02       jr   nz,$1087
1085: 3E 06       ld   a,$06			; relacionado con el tempo de la música (instrucción modificada desde fuera)
1087: 32 98 0F    ld   ($0F98),a
108A: 3E 3F       ld   a,$3F
108C: 32 96 0F    ld   ($0F96),a		; activa los tonos y el generador de ruido para todos los canales

108F: DD 21 A0 0F ld   ix,$0FA0
1093: CD 4C 11    call $114C			; procesa la primera entrada de sonido
1096: DD 21 B8 0F ld   ix,$0FB8
109A: CD 4C 11    call $114C			; procesa la segunda entrada de sonido
109D: DD 21 D0 0F ld   ix,$0FD0
10A1: CD 4C 11    call $114C			; procesa la tercera entrada de sonido

10A4: DD 21 A0 0F ld   ix,$0FA0			; escribe los datos del canal 0 en el PSG
10A8: CD D0 10    call $10D0
10AB: DD 21 B8 0F ld   ix,$0FB8			; escribe los datos del canal 1 en el PSG
10AF: CD D0 10    call $10D0
10B2: DD 21 D0 0F ld   ix,$0FD0			; escribe los datos del canal 2 en el PSG
10B6: CD D0 10    call $10D0

10B9: 2A 96 0F    ld   hl,($0F96)		; l = máscara de los canales
10BC: 7D          ld   a,l
10BD: BC          cp   h
10BE: 28 09       jr   z,$10C9			; si la máscara ha cambiado, fija el estado de los canales
10C0: 32 97 0F    ld   ($0F97),a		; copia la máscara para evitar fijar el estado si no hay modificaciones
10C3: 4F          ld   c,a
10C4: 3E 07       ld   a,$07			; registro mixer control
10C6: CD 4E 13    call $134E			; escribe en el PSG en qué canales están activos los tonos y el generador de ruido

10C9: DD E1       pop  ix
10CB: D1          pop  de
10CC: E1          pop  hl
10CD: C3 74 10    jp   $1074			; termina la interrupción

; escribe los datos del canal apuntado por ix en el PSG
10D0: DD 6E 0E    ld   l,(ix+$0e)		; lee el registro de control
10D3: CB 45       bit  0,l
10D5: C8          ret  z				; si el canal no está activo, sale
10D6: CB 55       bit  2,l
10D8: C0          ret  nz				; si no hay que actualizar las notas ni las envolventes, sale
10D9: CB 7D       bit  7,l
10DB: C0          ret  nz

10DC: CB 75       bit  6,l			; si el bit 6 = 0, se salta lo siguiente (escribir frecuencia de la nota en el PSG)
10DE: 28 13       jr   z,$10F3
10E0: DD 4E 03    ld   c,(ix+$03)	; lee la frecuencia de la nota (parte inferior)
10E3: DD 7E FD    ld   a,(ix-$03)	; lee el registro del PSG a escribir (frecuencia del canal (8 bits inferiores))
10E6: CD 4E 13    call $134E		; escribe al registro número 'a' del PSG el valor 'c'
10E9: DD 4E 04    ld   c,(ix+$04)	; lee la frecuencia de la nota (parte superior)
10EC: DD 7E FD    ld   a,(ix-$03)
10EF: 3C          inc  a			; registro del PSG a escribir (frecuencia del canal (4 bits superiores))
10F0: CD 4E 13    call $134E

10F3: CB 6D       bit  5,l			; si el bit 5 = 0, se salta lo siguiente (escribir volumen o envolvente deseada)
10F5: 28 32       jr   z,$1129
10F7: CB 65       bit  4,l
10F9: 20 0B       jr   nz,$1106		; si el bit 4 != 0, se generan envolventes para el volumen
10FB: DD 7E FE    ld   a,(ix-$02)	; lee el registro del PSG a escribir (amplitud))
10FE: DD 4E 07    ld   c,(ix+$07)	; lee el volumen
1101: CD 4E 13    call $134E		; escribe en el PSG el nuevo volumen
1104: 18 23       jr   $1129

1106: 3A 99 0F    ld   a,($0F99)	; lee el byte bajo del periodo de la envolvente
1109: 4F          ld   c,a
110A: 3E 0B       ld   a,$0B		; registro PSG del control de envolventes
110C: CD 4E 13    call $134E
110F: 3A 9A 0F    ld   a,($0F9A)	; lee el byte alto del periodo de la envolvente
1112: 4F          ld   c,a
1113: 3E 0C       ld   a,$0C
1115: CD 4E 13    call $134E		; escribe el nuevo periodo de la envolvente (en unidades de 128 microsegundos)
1118: 3A 9B 0F    ld   a,($0F9B)	; lee el tipo de envolvente y lo escribe en el PSG
111B: 4F          ld   c,a
111C: 3E 0D       ld   a,$0D
111E: CD 4E 13    call $134E
1121: DD 7E FE    ld   a,(ix-$02)	; lee el registro del PSG a escribir (amplitud))
1124: 0E 10       ld   c,$10
1126: CD 4E 13    call $134E		; deja el volumen en manos del generador de envolventes

; l = (ix + 0x0e)
1129: 3E 07       ld   a,$07
112B: CB 4D       bit  1,l
112D: 28 11       jr   z,$1140		; si el bit 1 de 0x0e es 0, no activa el generador de ruido
112F: 3E 3F       ld   a,$3F
1131: CB 5D       bit  3,l
1133: 28 0B       jr   z,$1140		; si el bit 3 de 0x0e es 0, se salta lo siguiente
1135: 3A 9C 0F    ld   a,($0F9C)
1138: 4F          ld   c,a
1139: 3E 06       ld   a,$06
113B: CD 4E 13    call $134E		; fija el periodo del generador de ruido
113E: 3E 3F       ld   a,$3F

1140: DD A6 FF    and  (ix-$01)		; se hace un AND con los bits que representan al canal
1143: 4F          ld   c,a
1144: 3A 96 0F    ld   a,($0F96)	; actualiza la configuración del generador de ruido
1147: A9          xor  c
1148: 32 96 0F    ld   ($0F96),a
114B: C9          ret

; procesa un canal de sonido
114C: DD 7E 0E    ld   a,(ix+$0e)		; comprueba si la entrada esta activa
114F: CB 47       bit  0,a
1151: C8          ret  z				; si no es así sale
1152: E6 87       and  $87				; (10000111) ignora los bits que no interesan y actualiza el valor
1154: DD 77 0E    ld   (ix+$0e),a
1157: 3A 98 0F    ld   a,($0F98)		; carga el tempo
115A: A7          and  a
115B: C2 F7 11    jp   nz,$11F7			; si es distinto de 0 se salta la parte de actualización de tonos

115E: DD 35 02    dec  (ix+$02)			; decrementa la duración de la nota actual
1161: C2 F7 11    jp   nz,$11F7			; si no ha concluido todavia, salta
1164: DD 36 0E 01 ld   (ix+$0e),$01		; marca entrada para ser procesada

1168: DD 5E 00    ld   e,(ix+$00)		; carga en de la dirección de la última nota
116B: DD 56 01    ld   d,(ix+$01)
116E: 06 06       ld   b,$06			; 6 entradas en total
1170: 21 06 13    ld   hl,$1306
1173: 1A          ld   a,(de)			; compara el primer byte leido con los comandos posibles
1174: BE          cp   (hl)
1175: 20 11       jr   nz,$1188			; si no es igual, avanza a la siguiente entrada

1177: 23          inc  hl				; si se ha identificado un comando, lee la dirección a saltar
1178: 7E          ld   a,(hl)
1179: 23          inc  hl
117A: 66          ld   h,(hl)
117B: 6F          ld   l,a
117C: 01 6E 11    ld   bc,$116E			; guarda la dirección de retorno (para volver a procesar las entradas)
117F: C5          push bc
1180: EB          ex   de,hl
1181: 23          inc  hl
1182: 4E          ld   c,(hl)			; carga en bc el primer parámetro
1183: 23          inc  hl
1184: 46          ld   b,(hl)
1185: 23          inc  hl
1186: EB          ex   de,hl
1187: E9          jp   (hl)				; salta a la dirección

1188: 23          inc  hl				; avanza a la siguiente entrada
1189: 23          inc  hl
118A: 23          inc  hl
118B: 10 E6       djnz $1173

; aquí llega después de procesar los comandos
118D: FE FF       cp   $FF				; si a = 0xff, terminan las notas
118F: 20 05       jr   nz,$1196			; en otro caso, continua
1191: DD 36 0E 00 ld   (ix+$0e),$00		; marca el canal como no activo
1195: C9          ret

1196: EB          ex   de,hl			; sigue procesando la entrada
1197: 06 01       ld   b,$01
1199: DD 70 11    ld   (ix+$11),b		; pone valores para que se produzcan cambios en la generación de envolventes, el volumen y en la frecuencia base
119C: DD 70 08    ld   (ix+$08),b
119F: DD 70 12    ld   (ix+$12),b
11A2: DD 70 0D    ld   (ix+$0d),b
11A5: 05          dec  b
11A6: DD 70 0C    ld   (ix+$0c),b		; inicia los índices en las tablas de generación de envolventes y de frecuencia base
11A9: DD 70 09    ld   (ix+$09),b
11AC: 4E          ld   c,(hl)			; lee el primer byte de los datos (nota + octava)
11AD: 23          inc  hl
11AE: 7E          ld   a,(hl)			; lee el segundo byte de los datos (duración de la nota)
11AF: 23          inc  hl
11B0: DD 77 02    ld   (ix+$02),a		; guarda la duración de la nota
11B3: CB 79       bit  7,c				; si el bit 7 del primer byte = 1, se activa el generador de ruido
11B5: 28 0D       jr   z,$11C4
11B7: 7E          ld   a,(hl)			; se lee el periodo del generador de ruido y se guarda
11B8: 32 9C 0F    ld   ($0F9C),a
11BB: DD CB 0E CE set  1,(ix+$0e)		; activa los bits 1 y 3
11BF: DD CB 0E DE set  3,(ix+$0e)
11C3: 23          inc  hl

11C4: DD 36 07 00 ld   (ix+$07),$00		; pone el volumen del canal a 0
11C8: DD 75 00    ld   (ix+$00),l		; guarda la dirección actual de notas
11CB: DD 74 01    ld   (ix+$01),h
11CE: DD CB 0E FE set  7,(ix+$0e)		; activa el bit 7 por si se el byte uno no contiene una nota

11D2: 79          ld   a,c
11D3: E6 0F       and  $0F				; si el byte leido & 0x0f = 0x0f, sale
11D5: FE 0F       cp   $0F
11D7: C8          ret  z

11D8: DD CB 0E BE res  7,(ix+$0e)		; desactiva el bit 7 de 0x0e

; si se llega hasta aquí, en a hay una nota de la escala cromática
11DC: 87          add  a,a				; ajusta entrada en tabla de tonos de las notas
11DD: 21 E5 0F    ld   hl,$0FE5
11E0: CD 48 13    call $1348
11E3: 5E          ld   e,(hl)
11E4: 23          inc  hl
11E5: 56          ld   d,(hl)			; de = tono de la nota
11E6: 79          ld   a,c				; obtiene el valor original con el que se indexó
11E7: 0F          rrca					; se queda con los 4 bits más significativos del primer byte leido
11E8: 0F          rrca
11E9: 0F          rrca
11EA: 0F          rrca
11EB: E6 07       and  $07				; obtiene la octava de la nota
11ED: EB          ex   de,hl
11EE: CD 6C 13    call $136C			; hl = hl / (2 ^ a) (ajusta el tono de la octava)

11F1: DD 75 03    ld   (ix+$03),l		; guarda el resultado
11F4: DD 74 04    ld   (ix+$04),h

11F7: DD CB 0E 7E bit  7,(ix+$0e)		; sale si lo que leyó no era una nota
11FB: C0          ret  nz
11FC: DD CB 0E 56 bit  2,(ix+$0e)		; sale si no hay que actualizar envolventes ni el volumen
1200: C0          ret  nz

1201: CD 75 12    call $1275			; actualiza unos registros (comprueba si hay que actualizar la generación de envolventes y el volumen)
1204: DD 35 11    dec  (ix+$11)			; decrementa el contador y si no es 0, sale
1207: C0          ret  nz
1208: DD 35 08    dec  (ix+$08)
120B: CC 31 12    call z,$1231			; actualiza unos registros (comprueba si hay que actualizar el tono base de las notas)

120E: DD 7E 0F    ld   a,(ix+$0f)		; reinicia  los contadores
1211: DD 77 11    ld   (ix+$11),a
1214: DD 7E 13    ld   a,(ix+$13)		; obtiene la modificación del tono
1217: 16 00       ld   d,$00
1219: CB 7F       bit  7,a				; extiende el signo de 0x13 y lo guarda en de
121B: 28 01       jr   z,$121E
121D: 15          dec  d
121E: DD 6E 03    ld   l,(ix+$03)		; hl = frecuencia de la nota
1221: DD 66 04    ld   h,(ix+$04)
1224: 5F          ld   e,a
1225: 19          add  hl,de			; actualiza la frecuencia de la nota
1226: DD 75 03    ld   (ix+$03),l
1229: DD 74 04    ld   (ix+$04),h
122C: DD CB 0E F6 set  6,(ix+$0e)		; indica que hay que cambiar la frecuencia del PSG
1230: C9          ret

; comprueba si hay que actualizar el tono base de las notas
1231: DD 7E 09    ld   a,(ix+$09)		; lee el índice de la tabla
1234: DD 6E 05    ld   l,(ix+$05)		; lee la dirección de los datos
1237: DD 66 06    ld   h,(ix+$06)
123A: CD 48 13    call $1348			; hl = hl + a
123D: 7E          ld   a,(hl)
123E: FE 7F       cp   $7F
1240: 20 10       jr   nz,$1252			; si no leyó 0x7f, salta
1242: 3E FF       ld   a,$FF			; contadores al máximo
1244: DD 77 11    ld   (ix+$11),a
1247: DD 77 0F    ld   (ix+$0f),a
124A: DD 77 08    ld   (ix+$08),a
124D: DD 36 13 00 ld   (ix+$13),$00		; no se modifica el tono de las notas
1251: C9          ret

1252: FE 80       cp   $80
1254: 20 06       jr   nz,$125C			; si no leyó 0x80, salta
1256: AF          xor  a				; limpia el índice de la tabla y vuelve a procesar los datos a partir de esa dirección
1257: DD 77 09    ld   (ix+$09),a
125A: 18 D5       jr   $1231

; en otro caso actualiza los valores
125C: DD 77 08    ld   (ix+$08),a		; actualiza el contador de cambios
125F: 23          inc  hl
1260: 7E          ld   a,(hl)
1261: DD 77 13    ld   (ix+$13),a		; actualiza la modificación de tono
1264: 23          inc  hl
1265: 7E          ld   a,(hl)
1266: DD 77 0F    ld   (ix+$0f),a		; inicia el contador principal y su límite
1269: DD 77 11    ld   (ix+$11),a
126C: DD 7E 09    ld   a,(ix+$09)		; apunta a la siguiente entrada de la tabla
126F: C6 03       add  a,$03
1271: DD 77 09    ld   (ix+$09),a
1274: C9          ret

; comprueba si hay que actualizar la generación de envolventes y el volumen
1275: DD 35 12    dec  (ix+$12)
1278: C0          ret  nz
1279: DD 35 0D    dec  (ix+$0d)
127C: CC 9B 12    call z,$129B		; actualiza unos registros de envolventes y el volumen

127F: DD CB 0E EE set  5,(ix+$0e)	; indica que hay que fijar las envolventes y el volumen
1283: DD 7E 10    ld   a,(ix+$10)
1286: DD 77 12    ld   (ix+$12),a	; vuelve a cargar el contador para la generación de envolventes y modificación de volumen
1289: DD CB 0E 66 bit  4,(ix+$0e)	; si se está usando el generador de envolventes, sale
128D: C0          ret  nz
128E: DD 7E 07    ld   a,(ix+$07)	; lee el volumen de la nota
1291: DD 86 14    add  a,(ix+$14)	; le suma el incremento de volumen
1294: E6 0F       and  $0F
1296: DD 77 07    ld   (ix+$07),a	; actualiza el volumen de la nota
1299: 4F          ld   c,a
129A: C9          ret

; lee valores de la tabla de envolventes y volumen base y actualiza los registros
129B: DD 7E 0C    ld   a,(ix+$0c)	; recupera el índice en la tabla
129E: DD 6E 0A    ld   l,(ix+$0a)	; obtiene la dirección de los datos
12A1: DD 66 0B    ld   h,(ix+$0b)
12A4: CD 48 13    call $1348		; hl = hl + a
12A7: 7E          ld   a,(hl)
12A8: FE 7F       cp   $7F			; si el byte leido no es 0x7f, salta
12AA: 20 10       jr   nz,$12BC
12AC: 3E FF       ld   a,$FF
12AE: DD 77 12    ld   (ix+$12),a	; contadores al máximo y sin modificar el volumen de las notas
12B1: DD 77 10    ld   (ix+$10),a
12B4: DD 77 0D    ld   (ix+$0d),a
12B7: DD 36 14 00 ld   (ix+$14),$00
12BB: C9          ret

12BC: FE 80       cp   $80			; si el byte leido no es 0x80, salta
12BE: 20 06       jr   nz,$12C6
12C0: AF          xor  a
12C1: DD 77 0C    ld   (ix+$0c),a	; reinicia el índice en la tabla y sigue procesando
12C4: 18 D5       jr   $129B

12C6: CB 7F       bit  7,a			; si el bit 7 del byte leido no está activo, salta
12C8: 28 23       jr   z,$12ED		; en otro caso, actualiza el periodo y tipo de envolvente
12CA: E6 0F       and  $0F
12CC: 32 9B 0F    ld   ($0F9B),a	; actualiza el tipo de envolvente
12CF: 23          inc  hl
12D0: 7E          ld   a,(hl)
12D1: 32 99 0F    ld   ($0F99),a	; actualiza el periodo de la envolvente
12D4: 23          inc  hl
12D5: 7E          ld   a,(hl)
12D6: 32 9A 0F    ld   ($0F9A),a
12D9: 23          inc  hl
12DA: 7E          ld   a,(hl)		; lee el nuevo contador
12DB: DD 77 12    ld   (ix+$12),a
12DE: DD 36 0D 01 ld   (ix+$0d),$01
12E2: DD CB 0E E6 set  4,(ix+$0e)	; deja el volumen en manos del generador de envolventes
12E6: DD 7E 0C    ld   a,(ix+$0c)	; avanza el índice de la tabla en 4
12E9: C6 04       add  a,$04
12EB: 18 15       jr   $1302

12ED: DD 77 0D    ld   (ix+$0d),a	; actualiza el segundo contador
12F0: 23          inc  hl
12F1: 7E          ld   a,(hl)
12F2: DD 77 14    ld   (ix+$14),a	; actualiza el volumen base
12F5: 23          inc  hl
12F6: 7E          ld   a,(hl)
12F7: DD 77 10    ld   (ix+$10),a	; actualiza el primer contador y su límite
12FA: DD 77 12    ld   (ix+$12),a
12FD: DD 7E 0C    ld   a,(ix+$0c)	; avanza el índice de la tabla en 3
1300: C6 03       add  a,$03

1302: DD 77 0C    ld   (ix+$0c),a
1305: C9          ret

; tabla de 6 entradas(relacionada con 0x114c y tablas 0x0fac)
; formato:
	byte 1: patron a buscar
	bytes 2 y 3: dirección a la que saltar si se encuentra el patrón
1306: 	FE 131B -> graba una nueva dirección de notas en el canal 2 y la activa
		FD 132A -> graba una nueva dirección de notas en el canal 3 y la activa
		FB 1339 -> graba una nueva dirección de tono base de las notas
		FC 1347 -> no hace nada
		FA 1340 -> graba una nueva dirección de cambios en el volumen y el generador de envolventes
		F9 1318 -> cambia de por bc (cambia a otra posición de la tabla de música)

; rutina que se alcanza con la entrada 5 de 0x1306
1318: 50          ld   d,b	; de = bc
1319: 59          ld   e,c
131A: C9          ret

; rutina que se alcanza con la entrada 0 de 0x1306
131B: ED 43 B8 0F ld   ($0FB8),bc	; graba una nueva dirección de notas en el canal 2
131F: 3E 05       ld   a,$05		; + 0x0e = 5
1321: 32 C6 0F    ld   ($0FC6),a	; y activa el canal 2
1324: 3E 01       ld   a,$01
1326: 32 BA 0F    ld   ($0FBA),a	; pone una duración de nota de 1 unidad
1329: C9          ret

; rutina que se alcanza con la entrada 1 de 0x1306
132A: ED 43 D0 0F ld   ($0FD0),bc	; graba una nueva dirección de notas en el canal 3
132E: 3E 05       ld   a,$05
1330: 32 DE 0F    ld   ($0FDE),a	; y activa el canal 3
1333: 3E 01       ld   a,$01
1335: 32 D2 0F    ld   ($0FD2),a
1338: C9          ret

; rutina que se alcanza con la entrada 2 de 0x1306
1339: DD 71 05    ld   (ix+$05),c	; guarda lo leido en la tabla de cambios del tono base
133C: DD 70 06    ld   (ix+$06),b
133F: C9          ret

; rutina que se alcanza con la entrada 4 de 0x1306
1340: DD 71 0A    ld   (ix+$0a),c	; guarda lo leido en la tabla de cambios en el volumen y el generador de envolventes
1343: DD 70 0B    ld   (ix+$0b),b
1346: C9          ret

; rutina que se alcanza con la entrada 3 de 0x1306
1347: C9          ret

; suma hl + a
1348: 85          add  a,l
1349: 6F          ld   l,a
134A: 8C          adc  a,h
134B: 95          sub  l
134C: 67          ld   h,a
134D: C9          ret

; escribe al registro número 'a' del PSG el valor 'c'
; a = número de registro
; c = valor a escribir
134E: 06 F4       ld   b,$F4	; puerto A del PPI, escribir indice del registro del PSG
1350: ED 79       out  (c),a
1352: 06 F6       ld   b,$F6	; puerto C del PPI
1354: ED 78       in   a,(c)
1356: F6 C0       or   $C0
1358: ED 79       out  (c),a	; selecciona el registro correspondiente del PSG
135A: E6 3F       and  $3F
135C: ED 79       out  (c),a
135E: 06 F4       ld   b,$F4
1360: ED 49       out  (c),c	; escribe el valor al registro correspondiente
1362: 06 F6       ld   b,$F6	; puerto C del PPI
1364: 4F          ld   c,a
1365: F6 80       or   $80
1367: ED 79       out  (c),a	; escribe el dato al registro del PSG
1369: ED 49       out  (c),c
136B: C9          ret

; hl = hl / (2 ^ a)
136C: A7          and  a			; si a = 0, sale
136D: C8          ret  z
136E: CB 3C       srl  h			; divide entre 2
1370: CB 1D       rr   l
1372: 3D          dec  a			; continua mientras a > 0
1373: 20 F9       jr   nz,$136E
1375: C9          ret

; apaga el sonido
1376: 3E 84       ld   a,$84		; para la generación de sonido
1378: 32 AE 0F    ld   ($0FAE),a
137B: 32 C6 0F    ld   ($0FC6),a
137E: 32 DE 0F    ld   ($0FDE),a
1381: 0E 3F       ld   c,$3F		; 0011 1111 (apaga los 3 canales de sonido)
1383: 3E 07       ld   a,$07		; registro 7 (PSG enable)
1385: C3 4E 13    jp   $134E

; ------- fin de sección de código dedicada a la música -------

; ------- datos de la música -------

; tono base de las notas para las voces
1388: 	01 01 01
		02 FF 01
		01 01 01
		80 			-> reinicia y sigue procesando

1390:       01 01 04 02 FF 04-01 01 04 80 0C 01 01 0C ................
13A0: FF 01 7F 01 FF 02 80 01-01 04 80 01 0F 08 0F FF ................
13B0: 0A 7F 0F 01 05 0F FF 09-7F 01 D8 02 80 01 00 01 ................
13C0: 7F

; envolventes y cambios de volumen para las voces
13C1: 01 05 01    ld   bc,$0105
13C4: 7F

13C5:                01 0F 01-01 00 28 0F FF 14 7F 05 ..........(.....
13D0: 01 02 05 02 01 05 FF 0F-01 00 3C 0A FF 14 7F 0F ..........<.....
13E0: 01 0F 01 00 28 0F FF 0F-7F 01 0C 01 01 00 28 0C ....(.........(.
13F0: FF 0A 7F 01 0C 14 02 FF-14 7F 01 0A 0A 7F FB 92 ................
1400: 13 FA CF 13 59 14 FA F3-13 5B 04 59 08 FA CF 13 ....Y....[.Y....
1410: 57 10 59 10 55 10 57 10-59 20 60 20 59 20 60 20 W.Y.U.W.Y ` Y `
1420: 59 08 60 08 59 10 59 14-FA F3 13 5B 04 59 08 FA Y.`.Y.Y....[.Y..
1430: CF 13 57 10 59 10 55 10-57 10 59 20 65 10 62 10 ..W.Y.U.W.Y e.b.
1440: 64 10 60 10 62 40 65 20-67 10 65 10 64 20 60 20 d.`.b@e g.e.d `
1450: 65 20 62 10 64 08 65 08-64 20 60 20 65 10 67 10 e b.d.e.d ` e.g.
1460: 69 10 6A 10 70 20 67 20-65 06 FA F3 13 67 04 65 i.j.p g e....g.e
1470: 06 FA CF 13 62 10 64 10-60 10 62 40 F9 FE 13 FF ....b.d.`.b@....
1480: FB BD 13 FA DF 13 FE 8D-14 82 50 1A FF FB A3 13 ..........P.....
1490: FA DF 13 20 50 FF FB B9-13 FA 9C 13 17 04 FF FB ... P...........
14A0: A3 13 FA CF 13 60 0F FF-FA CF 13 FB A7 13 7B 0F .....`........{.
14B0: FF

; datos de iniciación de la voz para el canal 3
14B1: FB 1388 -> graba una nueva dirección de tono base de las notas
14B4: FA 13C1 -> graba una nueva dirección para las envolventes y cambios de volumen
14B7: 54 -> nota y octava

14B8:                         0A FF FB BD 13 FA AB 13 .......T........
14C0: FE D2 14 6B 04 6B 05 6B-04 6B 05 6B 04 6B 05 6B ...k.k.k.k.k.k.k
14D0: 0F FF FB BD 13 FA AB 13-76 04 76 05 76 04 76 05 ........v.v.v.v.
14E0: 76 04 76 05 76 0F FF FB-B9 13 FA B2 13 82 14 1A v.v.v...........
14F0: 0F 0F FF FB 92 13 FA C5-13 FE 3E 15 4B 1E 4F 01 ..........>.K.O.
1500: FE 47 15 49 28 4F 04 FE-3E 15 4B 1E 4F 01 FE 47 .G.I(O..>.K.O..G
1510: 15 49 28 4F 04 FE 3E 15-4B 1E 4F 01 FE 47 15 49 .I(O..>.K.O..G.I
1520: 28 4F 04 FE 3E 15 4B 1E-4F 01 FE 47 15 49 28 4F (O..>.K.O..G.I(O
1530: 04 FE 3E 15 4B 1E 4F 01-FE 47 15 49 3C FF FB 92 ..>.K.O..G.I<...
1540: 13 FA C5 13 43 1E FF FB-92 13 FA C5 13 43 28 FF ....C........C(.
1550: FB BD 13 FA E9 13 A2 14-1A A2 14 1A A0 1E 19 FF ................
1560: FB BD 13 FA E9 13 A0 1E-19 FF

; ------- fin de los datos de los efectos sonoros del juego -----------

; ---------------------- código y datos relacionados con la generación de las pantallas -----------------------------------

156A-156B: dirección de los datos gráficos que forman la pantalla
156C: si vale 0, indica si la pantalla está iluminada

; tabla de tipos de bloques con los que se forman las pantallas. Cada entrada contiene un puntero a la información del bloque
156D: 	0000 -> 0x00 (0x00) -> este bloque no existe
		1973 -> 0x01 (0x02) -> ladrillo fino negro paralelo a y
		196E -> 0x02 (0x04) -> ladrillo fino rojo paralelo a x
		193C -> 0x03 (0x06)	-> ladrillo gordo negro paralelo a y
		1941 -> 0x04 (0x08) -> ladrillo gordo rojo paralelo a x
		1946 -> 0x05 (0x0a) -> bloque de ventanas pequeñas, ligeramente redondeadas y negras paralelas al eje y
		194B -> 0x06 (0x0c) -> bloque de ventanas pequeñas, ligeramente redondeadas y rojas paralelas al eje x
		1950 -> 0x07 (0x0e) -> barandilla roja paralela al eje y
		1955 -> 0x08 (0x10) -> barandilla roja paralela al eje x
		195A -> 0x09 (0x12) -> columna blanca paralela al eje y
		1969 -> 0x0a (0x14) -> columna blanca paralela al eje x
		1AEF -> 0x0b (0x16) -> escaleras con ladrillo negro en el borde paralela al eje y
		1B28 -> 0x0c (0x18) -> escaleras con ladrillo rojo en el borde paralela al eje x
		1BA0 -> 0x0d (0x1a) -> suelo de baldosas gordas azules
		1BA5 -> 0x0e (0x1c) -> suelo de baldosas rojas y azules formando un efecto tipo ajedrez
		1BAA -> 0x0f (0x1e) -> suelo de baldosas azules
		1BAF -> 0x10 (0x20) -> suelo de baldosas amarillas
		1CB8 -> 0x11 (0x22) -> bloque de arcos que pasan por pares de columnas paralelas al eje y
		1CFD -> 0x12 (0x24) -> bloque de arcos que pasan por pares de columnas paralelas al eje x
		1D23 -> 0x13 (0x26) -> bloque de arcos con columnas paralelas al eje y
		1D48 -> 0x14 (0x28) -> bloque de arcos con columnas paralelas al eje X
		1F5F -> 0x15 (0x2a) -> doble remache amarillo sobre el ladrillo paralelo al eje y
		1F64 -> 0x16 (0x2c) -> doble remache amarillo sobre el ladrillo paralelo al eje x
		17FE -> 0x17 (0x2e) -> bloque sólido de ladrillo fino paralelo al eje x
		18A6 -> 0x18 (0x30) -> bloque sólido de ladrillo fino paralelo al eje y
		17F9 -> 0x19 (0x32) -> mesa blanca paralela al eje x
		18A1 -> 0x1a (0x34) -> mesa blanca paralela al eje y
		1932 -> 0x1b (0x36) -> pequeño pilar de descarga que se coloca junto a una pared en el eje x
		1B9B -> 0x1c (0x38) -> área de terreno roja y negra
		1E0F -> 0x1d (0x3a) -> estanterías de libros paralelas al eje y
		1E33 -> 0x1e (0x3c) -> cama
		1E5F -> 0x1f (0x3e) -> grandes ventanales azules y amarillas paralelos al eje y
		1E9D -> 0x20 (0x40) -> grandes ventanales azules y amarillas paralelos al eje x
		1ECC -> 0x21 (0x42) -> candelabros con 2 velas paralelos al eje x
		1ED6 -> 0x22 (0x44) -> no hace nada
		1EDE -> 0x23 (0x46) -> remache amarillo con soporte paralelo al eje y
		18DA -> 0x24 (0x48) -> esquina de barandilla roja
		1EE3 -> 0x25 (0x4a) -> remache amarillo con soporte paralelo al eje x
		18EF -> 0x26 (0x4c) -> esquina de barandilla roja (2)
		1F1A -> 0x27 (0x4e) -> hueco redondeado para pasar con ladrillos finos rojos y negros paralelo al eje x
		192D -> 0x28 (0x50) -> bloque de ventanas pequeñas, rectangulares y negras paralelas al eje y
		1928 -> 0x29 (0x52) -> bloque de ventanas pequeñas, rectangulares y rojas paralelas al eje x
		191E -> 0x2a (0x54) -> 1 botella y un bote
		1925 -> 0x2b (0x56) -> no hace nada
		1AE9 -> 0x2c (0x58) -> escaleras con ladrillo negro en el borde paralela al eje y (2)
		1A99 -> 0x2d (0x5a) -> escaleras con ladrillo rojo en el borde paralela al eje x (2)
		1726 -> 0x2e (0x5c) -> hueco rectangular para pasar con ladrillos negros finos paralelo al eje y
		177C -> 0x2f (0x5e) -> hueco rectangular para pasar con ladrillos rojos finos paralelo al eje x
		17A4 -> 0x30 (0x60) -> esquina de ladrillo fino negro y rojo
		17AE -> 0x31 (0x62) -> esquina de ladrillo gordo negro y rojo
		1EE8 -> 0x32 (0x64) -> hueco redondeado para pasar con ladrillos finos negros y rojos paralelo al eje y
		1C86 -> 0x33 (0x66) -> esquina de remache amarillo con soporte
		1C96 -> 0x34 (0x68) -> esquina de remache amarillo
		17B8 -> 0x35 (0x6a) -> no hace nada
		1903 -> 0x36 (0x6c) -> esquina de barandilla roja (3)
		1F76 -> 0x37 (0x6e) -> pirámide de ladrillo fino rojo y negro
		18AB -> 0x38 (0x70) -> bloque sólido de ladrillo fino rojo y negro, con baldosas amarillas y negras en la parte superior, paralelo al eje y
		1803 -> 0x39 (0x72) -> bloque sólido de ladrillo fino rojo y negro, con baldosas amarillas y negras en la parte superior, paralelo al eje x
		18CD -> 0x3a (0x74) -> bloque sólido de ladrillo fino rojo y negro, con baldosas amarillas y negras en la parte superior, que crece hacia arriba
		1EC6 -> 0x3b (0x76) -> candelabros con 2 velas paralelos al eje x (2)
		1EA3 -> 0x3c (0x78) -> candelabros con 2 velas paralelos al eje y
		1ED1 -> 0x3d (0x7a) -> candelabros con soporte para la pared y con 2 velas paralelos al eje y
		1937 -> 0x3e (0x7c) -> pequeño pilar de descarga que se coloca junto a una pared en el eje y
		18B1 -> 0x3f (0x7e) -> esquina de ladrillo fino negro y rojo (2)
		18BF -> 0x40 (0x80) -> esquina de ladrillo fino negro y rojo (3)
		1F80 -> 0x41 (0x82) -> ladrillo fino y rojo que forma un triángulo rectángulo paralelo al eje x
		1F86 -> 0x42 (0x84) -> ladrillo fino y negro que forma un triángulo rectángulo paralelo al eje y
		1F2B -> 0x43 (0x86) -> hueco redondeado para pasar con ladrillos finos rojos y negros paralelo al eje y, con pilares gordos entre los huecos
		1F59 -> 0x44 (0x88) -> hueco redondeado para pasar con ladrillos finos rojos y negros paralelo al eje x, con pilares gordos entre los huecos
		1D99 -> 0x45 (0x8a) -> banco para sentarse paralelo al eje x
		1D6B -> 0x46 (0x8c) -> banco para sentarse paralelo al eje y
		1797 -> 0x47 (0x8e) -> esquina de ladrillo fino negro y rojo de muy poca altura
		178A -> 0x48 (0x90) -> esquina de ladrillo gordo negro y rojo de muy poca altura
		1B96 -> 0x49 (0x92) -> esquina plana delimitada con raya negra y con suelo azul
		1D9F -> 0x4a (0x94) -> mesa de trabajo
		1DD8 -> 0x4b (0x96) -> platos
		1DFC -> 0x4c (0x98) -> botellas con asas
		1E06 -> 0x4d (0x9a) -> caldero
		1BB4 -> 0x4e (0x9c) -> esquina plana delimitada con raya negra y con suelo amarillo
		17EF -> 0x4f (0x9e) -> bloque sólido de ladrillo fino rojo y negro, con baldosas azules en la parte superior, paralelo al eje y
		17F4 -> 0x50 (0xa0) -> bloque sólido de ladrillo fino rojo y negro, con la parte superior azul, paralelo al eje y
		1897 -> 0x51 (0xa2) -> bloque sólido de ladrillo fino rojo y negro, con baldosas azules en la parte superior, paralelo al eje x
		189C -> 0x52 (0xa4) -> bloque sólido de ladrillo fino rojo y negro, con la parte superior azul, paralelo al eje x
		17BB -> 0x53 (0xa6) -> bloque sólido de ladrillo fino rojo y negro, con baldosas azules en la parte superior y terminado en escalera, paralelo al eje x
		17E7 -> 0x54 (0xa8) -> bloque sólido de ladrillo fino rojo y negro, con la parte superior azul y terminado en escalera, paralelo al eje x
		1841 -> 0x55 (0xaa) -> bloque sólido de ladrillo fino rojo y negro, con baldosas azules en la parte superior y terminado en escalera, paralelo al eje y
		186D -> 0x56 (0xac) -> bloque sólido de ladrillo fino rojo y negro, con la parte superior azul y terminado en escalera, paralelo al eje y
		1DDD -> 0x57 (0xae) -> craneos humanos
		1B91 -> 0x58 (0xb0) -> restos de esqueletos???
		1914 -> 0x59 (0xb2) -> cara de monstruo con cuernos
		1919 -> 0x5a (0xb4) -> soporte con cruz
		1E01 -> 0x5b (0xb6) -> gran cruz
		1F69 -> 0x5c (0xb8) -> libros de la biblioteca paralelos al eje x
		1ED9 -> 0x5d (0xba) -> libros de la biblioteca paralelos al eje y
		195F -> 0x5e (0xbc) -> parte superior de una muralla con pequeño ventanal ligeramente redondeado y negro paralelo al eje y???
		1964 -> 0x5f (0xbe) -> parte superior de una muralla con pequeño ventanal ligeramente redondeado y rojo paralelo al eje x???

; hl = hl + a
162D: 85          add  a,l
162E: 6F          ld   l,a
162F: 8C          adc  a,h
1630: 95          sub  l
1631: 67          ld   h,a
1632: C9          ret

; comprueba si el tile indicado por hl es visible, y si es así, actualiza el tile mostrado en esta posición y los datos de profundidad asociados
; h = pos en y usando el sistema de coordenadas del buffer de tiles
; l = pos en x usando el sistema de coordenadas del buffer de tiles
; c = número de tile a poner
; ix = puntero a los datos de construcción del bloque

; el buffer de tiles es de 16x20, aunque la rejilla es de 32x36. La parte de la rejilla que se mapea en el buffer de tiles es la central
; (quitandole 8 unidades a la izquierda, derecha arriba y abajo)
1633: 7C          ld   a,h			; coge la posición en y
1634: D6 08       sub  $08			; traslada la posición y 8 unidades hacia arriba para tener la coordenada en el origen
1636: FE 14       cp   $14
1638: D0          ret  nc			; si está fuera de la zona visible en y (y - 8 >= 20), sale
1639: 57          ld   d,a			; d = posición y trasladada

163A: 7D          ld   a,l			; coge la posición en x
163B: D6 08       sub  $08			; traslada la posición x 8 unidades hacia la izquierda para tener la coordenada en el origen
163D: FE 10       cp   $10			; si está fuera de la zona visible en x (x - 8 >= 16), sale
163F: D0          ret  nc
1640: 5F          ld   e,a			; e = posición x trasladada

; aquí llega guardando en de las coordenadas finales en el buffer de tiles, y en hl las antiguas
1641: E5          push hl			; guarda en pila las coordenadas sin trasladar del buffer de tiles (las sacará de la pila la rutina 0x1667)
1642: EB          ex   de,hl		; hl = posiciones calculadas ahora, de = posiciones antiguas
1643: 7D          ld   a,l
1644: 6C          ld   l,h
1645: 26 00       ld   h,$00
1647: 29          add  hl,hl
1648: 29          add  hl,hl
1649: 29          add  hl,hl
164A: 29          add  hl,hl
164B: 29          add  hl,hl
164C: 5D          ld   e,l
164D: 54          ld   d,h
164E: 29          add  hl,hl
164F: 19          add  hl,de
1650: 87          add  a,a
1651: 5F          ld   e,a
1652: 87          add  a,a
1653: 83          add  a,e
1654: 85          add  a,l			; hl = 96*pos y trasladada + 6*pos x trasladada
1655: 6F          ld   l,a
1656: 8C          adc  a,h
1657: 95          sub  l
1658: 67          ld   h,a

1659: 11 80 8D    ld   de,$8D80		; de apunta al inicio del buffer de tiles
165C: 19          add  hl,de		; indexa en el buffer de tiles con las posiciones trasladadas
165D: C3 67 16    jp   $1667		; actualiza los datos del tile actual, según lo que hay en el tile, el nuevo tile a poner y las coordenadas locales de la rejilla

; aquí nunca se llega (???)
1660: 11 80 07    ld   de,$0780
1663: 19          add  hl,de
1664: 71          ld   (hl),c
1665: E1          pop  hl
1666: C9          ret

; graba los datos del tile que hay en hl, según lo que valgan las coordenadas de profundidad actual y c (tile a escribir)
; si ya se había proyectado un tile antes, el nuevo tiene mayor prioridad sobre el viejo
; hl = puntero a los datos del tile actual en el buffer de tiles
; c = número de tile a poner
1667: C5          push bc		; preserva bc y hl
1668: E5          push hl
1669: 23          inc  hl
166A: 23          inc  hl
166B: 54          ld   d,h		; de = hl + 2
166C: 5D          ld   e,l
166D: 23          inc  hl		; hl = hl + 3

; coge los valores del tile de mayor prioridad que hay actualmente en la rejilla
166E: 4E          ld   c,(hl)	; c = anterior profundidad en x ([hl+3])
166F: 23          inc  hl
1670: 46          ld   b,(hl)	; b = anterior profundidad en y ([hl+4])
1671: 23          inc  hl
1672: 7E          ld   a,(hl)	; a = tile anterior con mayor prioridad ([hl+5])

1673: 12          ld   (de),a	; [hl + 2] = a (el tile anterior pasa a tener ahora menor prioridad)
1674: 13          inc  de		; de = hl + 3
1675: 21 DE 1F    ld   hl,$1FDE	; apunta a la profundidad del tile en la rejilla (sistema de coordenadas local de la rejilla)
1678: 7E          ld   a,(hl)	; a = nueva profundidad en x
1679: 12          ld   (de),a	; [hl + 3] = fija la nueva profundidad en x
167A: B9          cp   c		; compara la profundidad en x con la profundidad antigua en x
167B: 30 08       jr   nc,$1685	; si nueva profundidad en x >= vieja profundidad en x, salta
167D: 23          inc  hl
167E: 7E          ld   a,(hl)	; a = nueva profundidad en y
167F: 2B          dec  hl
1680: B8          cp   b		; si la nueva profundidad en y >= que la vieja profundidad en y, salta
1681: 30 02       jr   nc,$1685

1683: 47          ld   b,a		; en otro caso, b = nueva profundidad en y
1684: 4E          ld   c,(hl)	; c = nueva profundidad en x

1685: 23          inc  hl		; hl apunta la nueva profundidad en y (sistema de coordenadas local de la rejilla)
1686: 13          inc  de		; de = hl + 4
1687: 7E          ld   a,(hl)
1688: 12          ld   (de),a	; [hl + 4] = nueva profundidad en y
1689: 13          inc  de		; de = hl + 5
168A: E1          pop  hl
168B: 71          ld   (hl),c	; [hl + 0] = c modificado por anterior y calc1 (vieja profundidad en x)
168C: 23          inc  hl
168D: 70          ld   (hl),b	; [hl + 1] = b modificado por anterior y calc2 (vieja profundidad en y)
168E: EB          ex   de,hl
168F: C1          pop  bc
1690: 71          ld   (hl),c	; [hl + 5] = nuevo tile para de mayor prioridad

1691: E1          pop  hl		; recupera de la pila las coordenadas sin trasladar del buffer de tiles (metidas por la rutina llamante)
1692: C9          ret

; datos acerca de los tiles que forman los bloques
1693: 2A 2C  							; 1 botella y un bote
1695: DE E0 DF 							; gran cruz
1698: FD FC 							; cara de monstruo con cuernos
169A: 5F FE								; soporte con cruz
169C: 1B 3A 3A 							; libros de la biblioteca paralelos al eje y?
169F: 69 39 39							; libros de la biblioteca paralelos al eje x?
16A2: 28 09 29 00						; ladrillo fino negro
16A6: 2B 0A 2D 00						; ladrillo fino rojo
16AA: 23 22 61 29						; bloque de ventanas pequeñas, rectangulares y negras paralelas al eje y
16AE: 26 25 27 2D						; bloque de ventanas pequeñas, rectangulares y rojas paralelas al eje x
16B2: 62 02 63 03						; ladrillo gordo negro
16B6: 6A 06 74 07						; ladrillo gordo rojo
16BA: 23 22 21 29   					; ventanas pequeñas, ligeramente redondeadas y negras
16BE: 26 25 24 2D						; ventanas pequeñas, ligeramente redondeadas y rojas
16C2: 37 36 35 00						; barandilla roja paralela al eje y
16C6: 34 33 32 00						; barandilla roja paralela al eje x
16CA: 99 9A 97 98						; columna amarilla
16CE: 23 21 1B 3A    					; parte superior de una muralla con pequeño ventanal ligeramente redondeado y negro paralelo al eje y???
16D2: 26 24 69 39						; parte superior de una muralla con pequeño ventanal ligeramente redondeado y rojo paralelo al eje x???
16D6: 7F 7E 7D 00						; pequeño pilar de descarga que se coloca junto a una pared en el eje x
16DA: 58 57 56 00  						; pequeño pilar de descarga que se coloca junto a una pared en el eje y
16DE: 41 17 16 1A 14 1D 1E 40 15 1F 20 19	; mesa de trabajo
16EA: 12 B2 B2 45 13 B4 B5 B3 B1		; escaleras con ladrillo negro en el borde paralela al eje y
16F3: 10 81 81 44 11 83 84 82 80		; escaleras con ladrillo rojo en el borde paralela al eje x
16FC: 1C 1B B8 B7 BA B9 B6 BB 28 09		; escaleras con ladrillo negro en el borde paralela al eje y (2)
1706: 6B 69 6C B0 AD AC AF AE 2B 0A 	; escaleras con ladrillo rojo en el borde paralela al eje x (2)
1710: 58 28 51 53 57 55 54 50 52 2B 0A	; hueco rectangular para pasar con ladrillos negros finos paralelo al eje y
171B: 7F 2B 78 7A 7E 7C 7B 77 79 28 09  ; hueco rectangular para pasar con ladrillos rojos finos paralelo al eje x

; características del material 0x2e
1726: 1710			; puntero a los tiles que forman el bloque
FC
F2 01 6D 84
F1 6D

172F:
F7 70 02 84 70
F7 71 03 6D 6D 84 71
FC
F9 6A
FD
F9 6B
FA
FB
F5
F9 61
FD
F9 65
FA
F9 68 80 63 80 69
FB
EF
F7 71 02 6D 6D 71
F9 61
FD
F9 65
FA
F9 66 80 67
F7 70 02 70
F7 71 6D 6D 84 71
F6
F6
F5
FE
FC
F9 62 80 63 80 64
FB
F5
F4
FA
FF

; características del material 0x2f
177C: 	171B		; puntero a los tiles que forman el bloque
FC
F2 01 6D 84
F1 6D 84
E9
EA 172F

; características del material 0x48
178A: 16B2			; puntero a los tiles que forman el bloque
EC 193C
F1
6E
6E
01 EC 41
19
FF

; características del material 0x47
1797: 16A2			; puntero a los tiles que forman el bloque
EC 1973				Call(0x1973);
F1
6E
6E
01
EC 196E
FF

; características del material 0x30
17A4: 16A6			; puntero a los tiles que forman el bloque
EC 196E
6E
19
F5
EC 1973
FF

; características del material 0x31
17AE: 16B6				; puntero a los tiles que forman el bloque
EC 1941			Call(0x1941)
F5
EC 193C
FF

; características del material 0x35
17B8: 1B31				; puntero a los tiles que forman el bloque
FF

; características del material 0x53
17BB: 1B49				; puntero a los tiles que forman el bloque

EC 17EF
F7 70 02 84 70
F7 71 01 84 71
F2 6D 01 84
F9 61
F1 01 84 6D
F2 6D 6D 02
EC 1891
F5
F6
F7 6E 6D
F7 6D 00
EC 1B28
FF

; características del material 0x54
17E7: 1B6D			; puntero a los tiles que forman el bloque
EC 17F4				call(0x17f4);
EA 17C0				ChangePc(0x17c0)

; características del material 0x4f
17EF: 1B49			; puntero a los tiles que forman el bloque
17F1: EA 1805		; ChangePC(0x1805)

; características del material 0x50
17F4: 1B6D			; puntero a los tiles que forman el bloque
17F6: EA 1805		; ChangePC(0x1805)

; características del material 0x19
17F9: 	1B88		; puntero a los tiles que forman el bloque
		EA 1805		; ChangePC(0x1805)

; características del material 0x17
17FE: 	1B31		; puntero a los tiles que forman el bloque
		EA 1805		; ChangePC(0x1805)

; características del material 0x39
1803: 	1B5B		; puntero a los tiles que forman el bloque

1805:
F7 71 71 82 FF			actualizaRegistro(0x71, -(valorRegistro(0x71)) + 0xff);
F7 70 6E 6E 02 84 70	actualizaRegistro(0x70, -(valorRegistro(0x6e) + valorRegistro(0x6e) + 2) + valorRegistro(0x70));
FC
F9 64
FE
F9 69
FA
F9 61 81 65 80 62
FB
F3
FD
FC
F9 66
FE
F9 68
FA
F9 61 81 67 80 61 80 62
FB
F3
F4
FA
F9 66
FE
F9 68
FA
F9 61 81 67 80 63
FF

; características del material 0x55
1841: 1B52			; puntero a los tiles que forman el bloque
EC 1897
F7 71 02 84 71
F7 70 01 84 70
F2 01 6D 84
F9 61
F1 6D 84 01
F2 6D 6D 02
EC 1875
F3
F6
F7 6E 6D
F7 6D 00
EC 1AEF
FF

; características del material 0x56
186D: 1B76			; puntero a los tiles que forman el bloque
EC 189C
EA 1846

; características del material auxiliar llamado desde el material 0x55
1875: 16A2			; puntero a los tiles que forman el bloque
F7 71 6D 6D 84 71
F7 6E 01
FE
FC
F9 61
FD
F9 62
FA
F7 6E 01 6E
FB
F5
F4
FA
FF

; características del material auxiliar llamado desde el material 0x53
1891:	16A6		; puntero a los tiles que forman el bloque
E9
EA 1877

; características del material 0x51
1897: 1B52			; puntero a los tiles que forman el bloque
1899: EA 18AD		; changePC(0x18ad);

; características del material 0x52
189C: 1B76			; puntero a los tiles que forman el bloque
189E: EA 18AD		; changePC(0x18ad);

; características del material 0x1a
18A1: 	1B7F		; puntero a los tiles que forman el bloque
		EA 18AD		; changePC(0x18ad);

; características del material 0x18
18A6: 	1B3A		; puntero a los tiles que forman el bloque
		EA 18AD		; changePC(0x18ad);

; características del material 0x38
18AB: 1B64			; puntero a los tiles que forman el bloque
18AD: E9          	FlipX();
18AE: EA 1805 		ChangePC(0x1805);

; características del material 0x3f
18B1: 	16A6			; puntero a los tiles que forman el bloque
F5
EC 1973				Call(0x1973)
F3
F7 6E 00
EC 196E				Call(0x196e)
FF

; características del material 0x40
18BF:	16A2				; puntero a los tiles que forman el bloque
F3
EC 196E			Call(0x196e)
F5
F7 6E 00
EC 1973			Call(0x1973)
FF

; características del material 0x3a
18CD: 1B5B			; puntero a los tiles que forman el bloque
18CF: F7          rst  $30
18D0: 6D          ld   l,l
18D1: 6D          ld   l,l
18D2: 6E          ld   l,(hl)
18D3: F7          rst  $30
18D4: 6E          ld   l,(hl)
18D5: 00          nop
18D6: EC AB 18    call pe,$18AB
18D9: FF          rst  $38

; características del material 0x24
18DA: 16C2 		; puntero a los tiles que forman el bloque
18DC:
EC 18E7			Call(0x18e7);
F7 6E 00 		actualizaRegistro(0x6e, 00);
F3				decTilePosX();
EC 1955			Call(0x1955);
FF

; características del material auxiliar llamado desde el material 0x24, 0x26 y 0x36
18E7: 16C2		; puntero a los tiles que forman el bloque
18E9:
F7 6D 00		actualizaRegistro(0x6d, 00);
EA 19CA			ChangePC(0x19ca)

; características del material 0x26
18EF: 16C2		; puntero a los tiles que forman el bloque
EC 18E7			Call(0x18e7)
F2 6E 84 6D		UpdateTilePosY(-valorRegistro(0x6e) + valorRegistro(0x6d));
F1 01 6E 6D		UpdateTilePosX(1 + valorRegistro(0x6e) + valorRegistro(0x6d));
F7 6E 00		actualizaRegistro(0x6e, 00);
EC 1955			Call(0x1955)
FF

; características del material 0x36
1903: 16C2 		; puntero a los tiles que forman el bloque
EC 18E7			Call(0x18e7)
F2 6D 01 		UpdateTilePosY(01 + valorRegistro(0x6d));
F1 6D           UpdateTilePosX(valorRegistro(0x6d));
F7 6E 00		actualizaRegistro(0x6e, 00);
EC 1955			Call(0x1955)
FF

; características del material 0x59
1914: 	1698		; puntero a los tiles que forman el bloque
		EA 1920		; ChangePC(0x1920);

; características del material 0x5a
1919: 	169A		; puntero a los tiles que forman el bloque
		EA 1920		; ChangePC(0x1920);

; características del material 0x2a
191E: 	1693		; puntero a los tiles que forman el bloque
1920:
F9 63 80 64			pintaTile(63, decrementaTilePosYyDibujaUnoMas, 64);
FF

1925: 16AE			; puntero a los tiles que forman el bloque
		FF

; características del material 0x29
1928: 16AE			; puntero a los tiles que forman el bloque
		EA 19A9		; ChangePC(0x19a9);

; características del material 0x28
192D: 16AA			; puntero a los tiles que forman el bloque
		EA 1990		; ChangePC(0x1990);

; características del material 0x1b
1932: 	16D6		; puntero a los tiles que forman el bloque
		EA 198C		; ChangePC(0x198c);

; características del material 0x3e
1937: 16DA 			; puntero a los tiles que forman el bloque
		EA 1975		; ChangePC(0x1975);

; características del material 0x03
193C: 	16B2		; puntero a los tiles que forman el bloque
		EA 19AD		; ChangePC(0x19ad);

; características del material 0x04
1941: 	16B6		; puntero a los tiles que forman el bloque
		EA 19C6 	; ChangePC(0x19C6);

; características del material 0x05
1946: 	16BA		; puntero a los tiles que forman el bloque
		EA 1990		; ChangePC(0x1990);

; características del material 0x06
194B: 	16BE		; puntero a los tiles que forman el bloque
		EA 19A9		; ChangePC(0x19a9);

; características del material 0x07
1950: 	16C2		; puntero a los tiles que forman el bloque
		EA 19CA		; ChangePC(0x19ca);

; características del material 0x08
1955:	16C6		; puntero a los tiles que forman el bloque
		EA 19D4		; ChangePC(0x19d4);

; características del material 0x09
195A: 	16CA		; puntero a los tiles que forman el bloque
		EA 1990		; ChangePC(0x1990);

; características del material 0x5e
195F: 	16CE		; puntero a los tiles que forman el bloque
		EA 1990		; ChangePC(0x1990);

; características del material 0x5f
1964: 	16D2		; puntero a los tiles que forman el bloque
		EA 19A9		; ChangePC(0x1990);

; características del material 0x0a
1969: 	16CA		; puntero a los tiles que forman el bloque
		EA 19A9		; ChangePC(0x19a9);

; características del material 0x02
196E: 	16A6		; puntero a los tiles que forman el bloque
		EA 198C		; ChangePC(0x198c);

; características del material 0x01
1973: 	16A2			; puntero a los tiles que forman el bloque

1975:
							// profundidad y en el grid =  profundidad y en el grid- (param2*2 + 1);
F7 71 01 6E 6E 84 71		actualizaRegistro(0x71, -(01 + valorRegistro(0x6e) + valorRegistro(0x6e)) + valorRegistro(0x71));

EF          				IncParam2();

FD 							while (param2 > 0){
  	     						// guarda la posición inicial
FC								pushTilePos();

F9 61 							pintaTile(61, decrementaTilePosY);

FE 								while (param1 > 0){
F9 62 								pintaTile(62, decrementaTilePosY);

									(param1--;)
FA								}

F9 63							pintaTile(63, decrementaTilePosY);

FB          					popTilePos();
F5 								incTilePosX();
F4 								decTilePosY();

								(param2--;)
FA 							}
FF

198C:
E9          				FlipX();
EA 1975						ChangePC(1975);

; código que genera las columnas y más bloques
1990:
; interpretado es:
						// decrementa la profundidad en y del bloque para los personajes no sean tapados por las columnas si pasan por delante de ellas
						// profundidad y en el grid =  profundidad y en el grid- (numColumnas*2 + 1);
F7 71 01 6E 6E 84 71	actualizaRegistro(0x71, -(01 + valorRegistro(0x6e) + valorRegistro(0x6e)) + valorRegistro(0x71));

						// como mínimo pinta una columna
EF						IncParam2();

						// el parámetro 2 indica el número de columnas a pintar
FD						while (param2 > 0){
							// guarda la posición inicial de la columna
FC							pushTilePos();

							// pinta la base de la columna
F9 61						pintaTile(61, decrementaTilePosY);

							// el parámetro 1 indica la altura de la columna
FE 							while (param1 > 0){
								// pinta el tile forma la columna en sí
F9 62							pintaTile(62, decrementaTilePosY);

								(param1--;)
FA							}

							// pinta el capitel de la columna
F9 63 80 64					pintaTile(63, decrementaTilePosYyDibujaUnoMas, 64);

							// actualiza la posición para dibujar la siguiente columna
FB 							popTilePos();
F5 							incTilePosX();
F4 							decTilePosY();

							(param2--;)
FA 						}
FF


19A9: 	E9 -> flipX
		EA 1990 -> changepc(1990)

19AD:
							// profundidad y en el grid =  profundidad y en el grid- (param2*2 + 1);
F7 71 01 6E 6E 84 71		actualizaRegistro(0x71, -(01 + valorRegistro(0x6e) + valorRegistro(0x6e)) + valorRegistro(0x71));

EF          				IncParam2();

FD 							while (param2 > 0){
  	     						// guarda la posición inicial
FC								pushTilePos();

F9 61 							pintaTile(61, decrementaTilePosY);

FE 								while (param1 > 0){

F9 62 80 64							pintaTile(62, decrementaTilePosYyDibujaUnoMas, 64);

									(param1--;)
FA 								}

F9 63 							pintaTile(63, decrementaTilePosY);

FB 								popTilePos();
F5 								incTilePosX();
F4 								decTilePosY();

								(param2--;)
FA 							}
FF

19C6:
E9 				FlipX();
EA 19AD			ChangePC(0x19ad)

19CA:
F7 6E 6E 6D		actualizaRegistro(0x6e, valorRegistro(0x6e) + valorRegistro(0x6d));
F7 6D 01		actualizaRegistro(0x6d, 01);
EA 1975			ChangePC(0x1975)

19D4:
E9				FlipX();
EA 19CA			ChangePC(0x19ca)

; dibuja la pantalla que hay en el buffer de tiles
19D8: 3A 6C 15    ld   a,($156C)	; lee si es una habitación iluminada o no
19DB: A7          and  a
19DC: 28 02       jr   z,$19E0		; si está iluminada, salta
19DE: 3E FF       ld   a,$FF		; color de fondo = negro
19E0: CD 70 1A    call $1A70		; limpia la rejilla y rellena un rectángulo de 256x160 a partir de (32, 0) con el color a
19E3: DD 2A 6A 15 ld   ix,($156A)	; ix = dirección de los datos de la pantalla actual
19E7: DD 23       inc  ix			; avanza el byte de longitud
19E9: 21 67 16    ld   hl,$1667		; modifica un salto de una rutina
19EC: 22 5E 16    ld   ($165E),hl
19EF: 01 C7 7F    ld   bc,$7FC7		; carga abadia8
19F2: ED 49       out  (c),c
19F4: CD 0A 1A    call $1A0A		; genera el escenerio con los datos de abadia8 y lo proyecta a la rejilla
19F7: 01 C0 7F    ld   bc,$7FC0		; carga abadia0
19FA: ED 49       out  (c),c
19FC: 21 60 16    ld   hl,$1660		; modifica un salto de una rutina
19FF: 22 5E 16    ld   ($165E),hl
1A02: 3A 6C 15    ld   a,($156C)	; lee si es una habitación iluminada o no
1A05: A7          and  a
1A06: CA B2 4E    jp   z,$4EB2		; si es una habitación iluminada, dibuja en pantalla el contenido de la rejilla desde el centro hacia afuera
1A09: C9          ret

; genera el escenario a partir de los datos de abadia8 y lo proyecta
; lee la entrada de abadia8 con un bloque de construcción de la pantalla y llama a 0x1bbc
1A0A: DD 7E 00    ld   a,(ix+$00)	; lee un byte
1A0D: FE FF       cp   $FF			; 0xff indica el fin de pantalla
1A0F: C8          ret  z
1A10: E6 FE       and  $FE			; desprecia el bit inferior para indexar
1A12: 21 6D 15    ld   hl,$156D		; apunta a la tabla de tipos de bloques
1A15: 85          add  a,l			; hl = hl + a
1A16: 6F          ld   l,a
1A17: 8C          adc  a,h
1A18: 95          sub  l
1A19: 67          ld   h,a
1A1A: 5E          ld   e,(hl)		; de = puntero a las caracterísitcas del bloque
1A1B: 23          inc  hl
1A1C: 56          ld   d,(hl)
1A1D: ED 53 62 1A ld   ($1A62),de	; modifica una instrucción
1A21: DD 7E 01    ld   a,(ix+$01)	; lee el byte 1
1A24: 4F          ld   c,a
1A25: E6 1F       and  $1F
1A27: 6F          ld   l,a			; l = pos en x del elemento (sistema de coordenadas del buffer de tiles)
1A28: 79          ld   a,c
1A29: 07          rlca
1A2A: 07          rlca
1A2B: 07          rlca
1A2C: E6 07       and  $07
1A2E: 4F          ld   c,a			; c = longitud del elemento en x
1A2F: DD 7E 02    ld   a,(ix+$02)	; lee el byte 2
1A32: 47          ld   b,a
1A33: E6 1F       and  $1F
1A35: 67          ld   h,a			; h = pos en y del elemento (sistema de coordenadas del buffer de tiles)
1A36: 78          ld   a,b
1A37: 07          rlca
1A38: 07          rlca
1A39: 07          rlca
1A3A: E6 07       and  $07
1A3C: 47          ld   b,a			; b = longitud del elemento en y

1A3D: 11 00 00    ld   de,$0000
1A40: ED 53 DE 1F ld   ($1FDE),de	; inicia a (0, 0) la posición del bloque en la rejilla (sistema de coordenadas local de la rejilla)
1A44: DD 7E 00    ld   a,(ix+$00)	; lee el primer byte
1A47: DD 23       inc  ix
1A49: DD 23       inc  ix
1A4B: DD 23       inc  ix			; avanza a la siguiente entrada
1A4D: E6 01       and  $01			; se queda con el bit 0
1A4F: 3E FF       ld   a,$FF
1A51: 28 05       jr   z,$1A58		; si es 0, la entrada es de 3 bytes
1A53: DD 7E 00    ld   a,(ix+$00)	;  en otro caso es de 4
1A56: DD 23       inc  ix
1A58: 32 DD 1F    ld   ($1FDD),a	; graba 0xff o el byte 4 a ???

1A5B: E5          push hl
1A5C: 21 0A 1A    ld   hl,$1A0A
1A5F: E3          ex   (sp),hl		; mete como dirección de retorno la dirección de esta rutina
1A60: E5          push hl
1A61: 21 00 00    ld   hl,$0000		; instrucción modificada desde fuera con la dirección de los datos de construcción del bloque
1A64: 5E          ld   e,(hl)
1A65: 23          inc  hl
1A66: 56          ld   d,(hl)
1A67: 23          inc  hl			; de = puntero del material a los tiles que forman el bloque
1A68: E3          ex   (sp),hl		; guarda en pila un puntero al resto de características del material
1A69: C3 BC 1B    jp   $1BBC		; inicia el buffer con los datos del bloque actual y evalua los parámetros de construcción del bloque

; oculta el área de juego
1A6C: 3E FF       ld   a,$FF
1A6E: 18 0D       jr   $1A7D

; limpia limpia 0x8d80-0x94ff y rellena un rectángulo de 160 de alto por 256 de ancho a partir de la posición (32, 0) con a
1A70: 21 80 8D    ld   hl,$8D80		; apunta a memoria libre
1A73: 11 81 8D    ld   de,$8D81
1A76: 36 00       ld   (hl),$00
1A78: 01 7F 07    ld   bc,$077F
1A7B: ED B0       ldir				; limpia 0x8d80-0x94ff

; rellena un rectángulo de 160 de alto por 256 de ancho a partir de la posición (32, 0) con a
1A7D: 06 A0       ld   b,$A0		; b = 160
1A7F: 32 8B 1A    ld   ($1A8B),a	; modifica el valor con el que rellenar
1A82: 21 08 C0    ld   hl,$C008		; posición (32, 0)
1A85: C5          push bc
1A86: E5          push hl
1A87: 54          ld   d,h			; de = hl
1A88: 5D          ld   e,l
1A89: 13          inc  de
1A8A: 36 00       ld   (hl),$00		; esta instrucción se modifica desde fuera
1A8C: 01 3F 00    ld   bc,$003F
1A8F: ED B0       ldir				; rellena 64 bytes (256 pixels)
1A91: E1          pop  hl
1A92: CD 4D 3A    call $3A4D		; avanza a la siguiente línea
1A95: C1          pop  bc
1A96: 10 ED       djnz $1A85		; repite hasta completar
1A98: C9          ret

; características del material 0x2d
1A99: 1706			; puntero a los tiles que forman el bloque
1A9B:
F7 71 02 6E 6E 84 71
F7 70 01 84 70
FC
FC
F8 69
FE
F8 6A
FA
FB
F4
FC
F8 61
FE
F8 62
FA
F8 63
FB
F4
FD
FC
F8 66
FE
F8 64
FA
F8 65 80 63
FB
F4
F5
FA
F8 66
FE
F8 67
FA
F8 68
FB
F7 6E 00
FE
F5
F6
FC
F9 69
FD
F9 6A
FA
F7 6E 01 6E
FB
FA
FF

; características del material 0x2c
1AE9: 	16FC		; puntero a los tiles que forman el bloque
		E9			FlipX();
		EA 1A9B 	ChangePC(0x1a9b)

; características del material 0x0b
1AEF: 	16EA 			; puntero a los tiles que forman el bloque

// dibuja las escaleras
1AF1:
						// profundidad x en el grid =  profundidad x en el grid - (param1*2 + 2);
F7 70 02 6D 6D 84 70	actualizaRegistro(0x70, -(02 + valorRegistro(0x6d) + valorRegistro(0x6d)) + valorRegistro(0x70));

						// profundidad y en el grid =  profundidad y en el grid- (param2*2 + 1);
F7 71 01 6E 6E 84 71	actualizaRegistro(0x71, -(01 + valorRegistro(0x6e) + valorRegistro(0x6e)) + valorRegistro(0x71));

EF						IncParam2();

FD						while (param2 > 0){
FC							pushTilePos();
FC							pushTilePos();

F9 61 80 65					pintaTile(61, decrementaTilePosYyDibujaUnoMas, 65);

FB 							popTilePos();
F3 							decTilePosX();

FE 							while (param1 > 0){
FC								pushTilePos();
F9 62 80 66 80 67				pintaTile(62, decrementaTilePosYyDibujaUnoMas, 66, decrementaTilePosYyDibujaUnoMas, 67);
FB 								popTilePos();

F4 								decTilePosY();
F3 								decTilePosX();

								(param1--;)
FA							}

F9 63 80 68 80 69			pintaTile(63, decrementaTilePosYyDibujaUnoMas, 68, decrementaTilePosYyDibujaUnoMas, 69);
FB 							popTilePos();
F4 							decTilePosY();
F4 							decTilePosY();
F5 							incTilePosX();

							(param2--;)
FA 						}
F3 						decTilePosX();

F0						IncParam1();

FE 						while (param1 > 0){
F9 64						pintaTile(64, decrementaTilePosY);
F3          				decTilePosX();

							(param1--;)
FA						}
FF

; características del material 0x0c
1B28: 	16F3		; puntero a los tiles que forman el bloque
		E9			FlipX();
		EA F1		ChangePc(0x1af1)

1B2E: 	EB EB EB					; restos de esqueletos???

; datos para la generación de materiales
1B31: 08 76 75 28 29 2B 2D 0A 09 	; bloque sólido de ladrillo fino paralelo al eje x
1B3A: 08 75 76 2B 2D 28 29 09 0A	; bloque sólido de ladrillo fino paralelo al eje y
1B43: 04 04 04						; suelo de baldosas gordas azules
1B46: 01 4E 4D    					; suelo de baldosas rojas y azules formando un efecto tipo ajedrez
; suelo de baldosas azules (los 3 bytes siguientes)
1B49: 05 4F 59 28 29 2B 2D 0A 09 	; bloque sólido de ladrillo fino rojo y negro, con baldosas azules en la parte superior, paralelo al eje y
1B52: 05 59 4F 2B 2D 28 29 09 0A	; bloque sólido de ladrillo fino rojo y negro, con baldosas azules en la parte superior, paralelo al eje x
; suelo de baldosas amarillas (los 3 bytes siguientes)
1B5B: 87 88 CF 28 29 2B 2D 0A 09	; bloque sólido de ladrillo fino rojo y negro, con baldosas amarillas y negras en la parte superior, paralelo al eje x
1B64: 87 CF 88 2B 2D 28 29 09 0A	; bloque sólido de ladrillo fino rojo y negro, con baldosas amarillas y negras en la parte superior, paralelo al eje y
1B6D: FF 45 44 28 29 2B 2D 0A 09	; bloque sólido de ladrillo fino rojo y negro, con la parte superior azul, paralelo al eje y (tb esquina plana delimitada con raya negra y con suelo azul)
1B76: FF 44 45 2B 2D 28 29 09 0A	; bloque sólido de ladrillo fino rojo y negro, con la parte superior azul, paralelo al eje x
1B7F: DB DA D4 D7 DD D8 DC D9 E2	; mesa blanca paralela al eje y
1B88: DB D4 DA D8 DC D7 DD E2 D9    ; mesa blanca paralela al eje x	(tb está la mesa de trabajo)

; características del material 0x58
1B91: 1B2E			; puntero a los tiles que forman el bloque
		EA 1BCF		ChangePc(0x1bcf)

; características del material 0x49
1B96: 1B6D			; puntero a los tiles que forman el bloque
EA 1BCF				ChangePc(0x1bcf)

; características del material 0x1c
1B9B: 	1B31		; puntero a los tiles que forman el bloque
		EA 1BCF		; ChangePC(0x1bcf);

; características del material 0x0d
1BA0: 	1B43		; puntero a los tiles que forman el bloque
		EA 1BCF		; ChangePC(0x1bcf);

; características del material 0x0e
1BA5: 	1B46		; puntero a los tiles que forman el bloque
		EA 1BCF		; ChangePC(0x1bcf);

; características del material 0x0f
1BAA: 	1B49		; puntero a los tiles que forman el bloque
		EA 1BCF		; ChangePC(0x1bcf);

; características del material 0x10
1BAF: 	1B5B		; puntero a los tiles que forman el bloque
		EA 1BCF		; ChangePC(0x1bcf);

; características del material 0x4e
1BB4: 	1B88		; puntero a los tiles que forman el bloque
		EA 1BCF		; ChangePC(0x1bcf);

; inicia la evaluación del bloque actual, pero sin modificar los tiles que forman el bloque
1BB9: C5          push bc
1BBA: 18 0C       jr   $1BC8

; inicia el buffer para la construcción del bloque actual y evalua los parámetros de construcción del bloque
; a = 0xff si la entrada es de 3 bytes o la altura en otro caso
; h = pos inicial del bloque en y (sistema de coordenadas del buffer de tiles)
; l = pos inicial del bloque en x (sistema de coordenadas del buffer de tiles)
; b = lgtud del elemento en y
; c = lgtud del elemento en x
; de = puntero a los tiles que forman el bloque
; sp = puntero a los datos de construcción del bloque
1BBC: C5          push bc		; preserva los parámetros leidos
1BBD: E5          push hl
1BBE: EB          ex   de,hl	; hl = puntero a los tiles que forman el bloque
1BBF: 11 CF 1F    ld   de,$1FCF	; de = buffer de destino
1BC2: 01 0C 00    ld   bc,$000C
1BC5: ED B0       ldir			; copia los datos de los tiles que forman el bloque
1BC7: E1          pop  hl
1BC8: CD B8 1F    call $1FB8	; si la entrada es de 4 bytes, transforma la posición del bloque a coordenadas de la rejilla
1BCB: C1          pop  bc
1BCC: C3 18 20    jp   $2018	; salta al generador de bloques

// dibuja un tipo de suelo
1BCF:

F7 70 02 6E 6E 84 70 	UpdateReg(0x70, -(2 + 2*Param2) + reg(0x70));
F7 71 03 6D 6D 84 71  	UpdateReg(0x71, -(3 + 2*Param1) + reg(0x71));

 						// como mínimo pinta baldosas de 1x1
E0 						IncParam1();
EF 						IncParam2();

						// el parámetro 2 indica el número de filas a pintar
FD 						while (param2 > 0){
							// guarda la posición inicial
FC 							PushTilePos();

							// el parámetro 1 indica el número de columnas a pintar
FE 							while (param1 > 0){
								// pinta 2 filas con tile con forma de X
F9 61 80 61 					DrawTileDecY(0x61, 0x80, 0x61);
F5 								IncTilePosX();
F6								IncTilePosY();

FA 			 				(param1--;)
							}

							// dibuja un borde al lado de la última columna pintada
F9 61 80 62					DrawTileDecY(0x61, 0x80, 0x62);

							// actualiza la posición para dibujar el siguiente bloque
FB							PopTilePos();
F4							DecTilePosY();
F3							DecTilePosX();

FA							(param2--;)
						}
F5 						IncTilePosX();
F4 						DecTilePosY();

						// dibuja el otro borde al lado de la primera columna pintada
FE 						while (param1 > 0){
F9 63 						DrawTileDecY(0x63);
F5							IncTilePosX();

FA		 					(param1--;)
						}
FF

; datos para la generación de materiales
1BF9: D8 95 94 EA D0 DC DB 96 D7 DD DA		; cama
1C04: A7 A5 A3 A1 9F 9D A6 A4 A2 A0 9E 00	; grandes ventanales azules y amarillas paralelos al eje y
1C10: 93 91 8F 8D 8B 89 92 90 8E 8C 8A 00	; grandes ventanales azules y amarillas paralelos al eje x
1C1C: 5F CB CD CA 46 						; candelabros con 2 velas paralelos al eje x
1C21: 5F CB CD CA 46 						; candelabros con 2 velas paralelos al eje x (2)
1C26: 5F CE CD CC 60						; candelabros con 2 velas paralelos al eje y
1C2B: 6D CE CD CC 60						; candelabros con soporte para la pared y con 2 velas paralelos al eje y
1C30: D6 D5 AB								; remache amarillo con soporte paralelo al eje y
1C33: D2 D1 A8  							; remache amarillo con soporte paralelo al eje x
1C36: 28 09 6E 6F 72 71 70 2B 0A 			; hueco redondeado para pasar con ladrillos finos rojos y negros paralelo al eje x
1C3F: 2B 0A 5A 5B 5E 5D 5C 28 09 			; hueco redondeado para pasar con ladrillos finos rojos y negros paralelo al eje y
1C48: C4 C3 C2 C0 C1 BF 9B BC BD BE			; bloque de arcos que pasan por pares de columnas paralelas al eje y
1C52: F6 F5 F4 F2 F3 F1 9B EE EF F0			; bloque de arcos que pasan por pares de columnas paralelas al eje X
1C5C: E3 									; plato
1C5D: 9C 									; calavera
1C5E: 0D 0C 0B 								; caldero
1C61: 31 0F 0E								; botellas con asa
1C64: 67 48 76 08 75 66 68 65 3B 64			; banco para sentarse paralelo al eje y
1C6E: 41 47 75 08 76 40 38 20 42 1F			; banco para sentarse paralelo al eje x
1C78: AA AB AB AA							; doble remache amarillo sobre el ladrillo paralelo al eje y
1C7C: A9 A8 A8 A9							; doble remache amarillo sobre el ladrillo paralelo al eje x
1C80: 3F 3E 3D 3C 3A 39 					; estanterías de libros paralelas al eje y

; características del material 0x33
1C86: 1C30			; puntero a los tiles que forman el bloque

EC 1CA6		Call(0x1ca6);
F7 6E 6D
F7 6D 01
F3
EC 1EE3		Call(0x1ee3);
FF

; características del material 0x34
1C96: 1C78        ; puntero a los tiles que forman el bloque
EC 1CAF
F7
6E
6D
F7
6D
00
F3
EC 64 1F
FF

; características del material auxiliar llamado desde el material 0x33
1CA6: 1C30			; puntero a los tiles que forman el bloque
F7
6D
01 EC DE
1E FF

; características del material auxiliar llamado desde el material 0x34
1CAF: 1C78			; puntero a los tiles que forman el bloque
F7
6D
00
EC 5F 1F
FF

; características del material 0x11
1CB8: 	1C48	; puntero a los tiles que forman el bloque

1CBA:
F7 70 01 70		actualizaRegistro(0x70, 1 + valorRegistro(0x70));
F7 71 01 71     actualizaRegistro(0x70, 1 + valorRegistro(0x71));

F0				IncParam1();

FE 				while (param1 > 0){
F7 71 08 84 71		actualizaRegistro(0x71, -8 + valorRegistro(0x71));
F9 67 80 82 FB 80 82 C8 80 82 C5 80 82 C6 80 82 C7	pintaTile(67, decrementaTilePosYyDibujaUnoMas, FB, decrementaTilePosYyDibujaUnoMas, C8, decrementaTilePosYyDibujaUnoMas, C5, decrementaTilePosYyDibujaUnoMas, C6, decrementaTilePosYyDibujaUnoMas, C7);

1CDA:
F5					IncTilePosX();
F6 					IncTilePosY();
F6					IncTilePosY();
F6 					IncTilePosY();
F9 61 80 62 80 63 80 64	pintaTile(61, decrementaTilePosYyDibujaUnoMas, 62, decrementaTilePosYyDibujaUnoMas, 63, decrementaTilePosYyDibujaUnoMas, 64);
F5					IncTilePosX();
F6 					IncTilePosY();
F6					IncTilePosY();
F9 65 80 66			pintaTile(65, decrementaTilePosYyDibujaUnoMas, 66);
F5					IncTilePosX();
F2 04 				UpdateTilePosY(4);
F9 67 80 68 80 69 80 6A pintaTile(67, decrementaTilePosYyDibujaUnoMas, 68, decrementaTilePosYyDibujaUnoMas, 69, decrementaTilePosYyDibujaUnoMas, 6a);
F5					IncTilePosX();
F2 03 				UpdateTilePosY(3);

					(param1--;)
FA				}
FF

; características del material 0x12
1CFD: 	1C52		; puntero a los tiles que forman el bloque
		E9			; FlipX();
F7 70 01 70 		actualizaRegistro(0x70, 1 + valorRegistro(0x70));
F7 71 01 71 		actualizaRegistro(0x71, 1 + valorRegistro(0x71));

F0 					IncParam1();

FE 					while (param1 > 0){
F7 71 08 84 71			actualizaRegistro(0x71, -8 + valorRegistro(0x71));
F9 67 80 82 FB 80 82 F7 80 82 F8 80 82 F9 80 82 FA pintaTile(67, decrementaTilePosYyDibujaUnoMas, FB, decrementaTilePosYyDibujaUnoMas, F7, decrementaTilePosYyDibujaUnoMas, F8, decrementaTilePosYyDibujaUnoMas, F9, decrementaTilePosYyDibujaUnoMas, FA);

EA 1CDA					ChangePC(0x1cda);

; características del material 0x13
1D23: 	1C48		; puntero a los tiles que forman el bloque

1D25:
FC				pushTilePos();

F2 05 84		updateTilePosY(-5);
F7 6F 0A 6F		actualizaRegistro(0x6f, 0x0a + valorRegistro(0x6f));
EC 1CB8			call(0x1cb8);

1D30:
F7 6F 0A 84 6F	actualizaRegistro(0x6f, -0x0a + valorRegistro(0x6f));

FB				popTilePos();
F0				IncParam1();

FE 				while (param1 > 0){
EC 1D59				call(0x1d59)
F4 					decTilePosY();
F4 					decTilePosY();
F4 					decTilePosY();
F5 					incTilePosX();
F5 					incTilePosX();
F5 					incTilePosX();
EC 1D59				call(0x1d59)
F4 					decTilePosY();
F5 					incTilePosX();

					(param1--;)
FA				}
FF

; características del material 0x14
1D48: 	1C52		; puntero a los tiles que forman el bloque

1D4A:
FC 				pushTilePos();
F2 05 84		updateTilePosY(-5);
F7 6F 0A 6F		actualizaRegistro(0x6f, 0A + valorRegistro(0x6f));
EC 1CFD			call(0x1cfd);
E9				FlipX();
EA 1D30			ChangePC(0x1d30);

1D59: 16CA			; puntero a los tiles que forman el bloque

1D61:
F7 71 01 84 71					actualizaRegistro(0x71, -01 + valorRegistro(0x71));
F9 61 80 62 80 62 80 62 80 63	pintaTile(61, decrementaTilePosYyDibujaUnoMas, 62, decrementaTilePosYyDibujaUnoMas, 62, decrementaTilePosYyDibujaUnoMas, 62, decrementaTilePosYyDibujaUnoMas, 63);
FF

; características del material 0x46
1D6B: 1C64          ; puntero a los tiles que forman el bloque
F6
F5
FC
F9 61 80 62 80 63
FB
F3
F6
FE
FC
F9 61 80 62 80 64 80 65
FB
F3
F6
FA
FC
F9 66 80 67 80 64 80 65
FB
F3
F9 6A 80 68 80 69
FF

; características del material 0x45
1D99: 1C6E			; puntero a los tiles que forman el bloque
	E9          	FlipX();
	EA 1D6D			ChangePc(0x1d6d);

; características del material 0x4a
1D9F: 16DE			; puntero a los tiles que forman el bloque
E9
F6
F5
FC
F9 61 80 62 80 63 80 64
FB
F3
F6
FE
FC
F9 61 80 62 80 82 43 80 66 80 67
FB
F3
F6
FA
FC
F9 68 80 69 80 82 18 80 66 80 67
FB
F3
F9 6A 80 6B 80 6C 80 65
FF

; características del material 0x4b
1DD8: 1C5C			; puntero a los tiles que forman el bloque
1DDA: EA 1DDF		ChangePC(0x1ddf);

; características del material 0x57
1DDD: 1C5D			; puntero a los tiles que forman el bloque
1DDF:
FC 					pushTilePos();
F5 					IncTilePosX();
F4     		 		IncTilePosY();
E4 1DEF 			CallPreserve(0x1def);
FB         			popTilePos();
E9					FlipX();
F7 6D 6E 01			actualizaRegistro(0x6d, valorRegistro(0x6e) + 01);
E4 1DEF				CallPreserve(0x1def);
FF

; características del material auxiliar llamado desde el material 0x57
1DEF: 1C5C			; puntero a los tiles que forman el bloque
FE
F9 61
F7 71 02 84 71
F5
FA
FF

; características del material 0x4c
1DFC: 1C61			; puntero a los tiles que forman el bloque
1DFE: EA 1975     	ChangePc(0x1975);

; características del material 0x5b
1E01: 1695			; puntero a los tiles que forman el bloque
	EA 1E08			ChangePc(0x1e08);

; características del material 0x4d
1E06: 1C5E			; puntero a los tiles que forman el bloque
1E08:
F9 61 80 62 80 63
FF

; características del material 0x1d
1E0F: 	1C80	; puntero a los tiles que forman el bloque
1E01:
E9
F0
EF
FC
F9 61
FE
F9 62 80 63 80 61
FA
FB
F6
F5
FD
FC
F9 64
FE
F9 65 80 66 80 64
FA
FB
F6
F5
FA
FF

; características del material 0x1e
1E33: 	1BF9	; puntero a los tiles que forman el bloque
F7 71 04 84 71
F7 70 01 84 70
FC
F9 69 80 6A 80 6B
FB
F5
FC
F9 61 80 66 80 67 80 68
FB
F5
F4
F9 61 80 62 80 63 80 64 80 65
FF

; características del material 0x1f
1E5F: 1C04		; puntero a los tiles que forman el bloque
1E61:
F7 70 01 84 70
F7 71 03 6D 6D 6D 6D 84 71
F0
EF
FD
FC
FE
FC
F9 61 80 62 80 62 80 63 80 64 80 65 80 66
FB
F5
F4
FC
F9 67 80 68 80 68 80 69 80 6A 80 6B
FB
F5
F4
FA
FB
F2 07 84
FA
FF

; características del material 0x20
1E9D: 1C10		; puntero a los tiles que forman el bloque
	  E9		FlipX();
	  EA 1E61	ChangePC(0x1e61);

; características del material 0x2c
1EA3: 1C26		; puntero a los tiles que forman el bloque
1EA5:
F7 71 01 6D 6D 84 71
F0
EF
FD
FC
FE
FC
F9 61 80 62 80 63 80 64 80 65
FB
F5
F4
FA
FB
F2 05 84
FA
FF

; características del material 0x3b
1EC6: 	1C21		; puntero a los tiles que forman el bloque
1EC8: 	E9          FlipX();
		EA 1EA5		ChangePc(0x1ea5);

; características del material 0x21
1ECC: 	1C1C 		; puntero a los tiles que forman el bloque
		EA 1EC8		ChangePc(0x1ec8);

; características del material 0x3d
1ED1: 	1C2B   		; puntero a los tiles que forman el bloque
		EA 1EA5		ChangePc(0x1ea5);

; características del material 0x22
1ED6: 	1C2B		; puntero a los tiles que forman el bloque
FF

; características del material 0x5d
1ED9: 	169C    	; puntero a los tiles que forman el bloque
		EA 1975		ChangePc(0x1975);

; características del material 0x23
1EDE: 	1C30		; puntero a los tiles que forman el bloque
		EA 1975		ChangePc(0x1975);

; características del material 0x25
1EE3: 	1C33		; puntero a los tiles que forman el bloque
1EE5: 	EA 198C		ChangePc(0x198c);

; características del material 0x32
1EE8: 	1C3F		; puntero a los tiles que forman el bloque
1EEA:
F7 71 01 71
F0
F7 70 01 70
FE
FC
F5
F4
F4
E4 1F20			CallPreserve(0x1f20);
FB
F7 71 04 84 71
F9 65 80 66 80 66 80 66 80 66 80 67 80 64
F5
F6
F9 63 80 69
F5
F2 06
FA
FF

; características del material 0x27
1F1A: 	1C36		; puntero a los tiles que forman el bloque
1F1C:
		E9			FlipX();
		EA 1EEA		ChangePc(0x1eea);

; características del material auxiliar llamado desde el material 0x32
1F20: 1C3F          ; puntero a los tiles que forman el bloque
F7
6D
04
F7
6E
00
EA 8C 19

; características del material 0x43
1F2B: 1C3F			; puntero a los tiles que forman el bloque
F7 6E 6D 01
F7 71 01 71
F7 70 02 84 70
FD
F7 6D 00
E4 1EE8		CallPreserve(0x1ee8);
F5
F5
F4
F4
FC
F7 71 06 84 71
F7 6D 06
F9 68
FE
F9 69
FA
FB
F5
F4
FA
FF

; características del material 0x44
1F59: 1C36			; puntero a los tiles que forman el bloque
1F5B: E9        	FlipX();
1F5C: EA 1F2D		ChangePC(0x1f2d);

; características del material 0x15
1F5F: 	1C78		; puntero a los tiles que forman el bloque
		EA 19AD		; ChangePC(0x19ad)

; características del material 0x16
1F64: 	1C7C		; puntero a los tiles que forman el bloque
		EA 19C6		; ChangePC(0x19c6)

; características del material 0x5c
1F69: 169F			; puntero a los tiles que forman el bloque
		EA 19C6		; ChangePC(0x19c6)

1F6E: 2B 0A 49 4A		; ladrillo fino y rojo que forma un triángulo rectángulo paralelo al eje x
1F72: 28 09 4C 4B		; pirámide de ladrillo fino rojo y negro (y ladrillo fino y rojo que forma un triángulo rectángulo paralelo al eje y)

; características del material 0x37
1F76: 1F72			; puntero a los tiles que forman el bloque
EC 1F86   	Call(0x1f86)
F3
EC 1F80 	Call(0x1f80)
FF

; características del material 0x41
1F80: 1F6E			; puntero a los tiles que forman el bloque
		E9 	FlipX();
		EA 1F88

; características del material 0x42
1F86: 1F72
1F88:
F7 6D 6E 6D
F7 6E 6D 01
F7 71 01 6D 6D 84 71
F7 70 02 6D 6D 84 70
FD
FC
F9 61
FE
F9 62 80 62 80 62
FA
F9 63 80 64
F7 6D 01 84 6D
FB
F5
F4
FA
FF

		// param1 = param 1 + param2
		actualizaRegistro(0x6d, valorRegistro(0x6e) + valorRegistro(0x6d));

		// param2 = param 1 + 1
		actualizaRegistro(0x6e, valorRegistro(0x6d) + 1);

		// pos y en el grid = pos y en el grid - (2*param1 + 1)
		actualizaRegistro(0x71, -(1 + 2*valorRegistro(0x6d)) + reg(0x71));

		// pos x en el grid = pos x en el grid - (2*param1 + 2)
		actualizaRegistro(0x70, -(2 + 2*valorRegistro(0x6d)) + reg(0x70));

		while (param2 > 0){
			PushTilePos();
			DrawTileDecY(0x61);
			while (param1 > 0){
				DrawTileDecY(0x62, 0x80, 0x62, 0x80, 0x62);
				(param1--;)
			}
			DrawTileDecY(0x63, 0x80, 0x64);
			UpdateReg(0x6d, -1 + Param1);
			PopTilepos();
			IncTilePosX();
			DecTilePosY();
			(param2--;)
		}

; si la entrada es de 4 bytes, transforma la posición del bloque a coordenadas de la rejilla
; las ecuaciones de cambio de sistema de coordenadas son:
; mapa de tiles -> rejilla
; Xrejilla = Ymapa + Xmapa - 15
; Yrejilla = Ymapa - Xmapa + 16
; rejilla -> mapa de tiles
; Xmapa = Xrejilla - Ymapa + 15
; Ymapa = Yrejilla + Xmapa - 16
; de esta forma los datos de la rejilla se almacenan en el mapa de tiles de forma que la conversión a la pantalla es directa
; parámetros:
; a = 0xff si la entrada es de 3 bytes o el byte 3 en otro caso
; h = pos del bloque en y (sistema de coordenadas del buffer de tiles)
; l = pos del bloque en x (sistema de coordenadas del buffer de tiles)
1FB8: FE FF       cp   $FF			; si la entrada es de 3 bytes, sale
1FBA: C8          ret  z
1FBB: CB 3F       srl  a			; a = a*2
1FBD: 84          add  a,h
1FBE: 57          ld   d,a			; d = h + a*2
1FBF: 85          add  a,l
1FC0: D6 0F       sub  $0F
1FC2: 5F          ld   e,a			; e = h + l + a*2 - 15
1FC3: 3E 10       ld   a,$10
1FC5: 82          add  a,d			; a = h + a*2 + 16
1FC6: 95          sub  l
1FC7: 57          ld   d,a			; d = h - l + a*2 + 16
1FC8: ED 53 DE 1F ld   ($1FDE),de	; graba las nuevas coordenadas
1FCC: C9          ret

; variables usadas para la generación de los bloques
1FCD-1FDF: 00

; tabla de rutinas relacionada con la construcción de bloques
1FE0: 	2032 -> 0x00 (0xff) recupera la dirección del siguiente bloque a procesar y si se cambiaron las coordenadas x (x = -x), deshace el cambio
		2091 -> 0x01 (0xfe) guarda en la pila la longitud del bloque en y y la posición actual de los datos de construcción del bloque
		209E -> 0x02 (0xfd) guarda en la pila la longitud del bloque en x y la posición actual de los datos de construcción del bloque
		20CF -> 0x03 (0xfc)	guarda en la pila la posición actual en el buffer de tiles
		20D3 -> 0x04 (0xfb)	recupera de la pila la posición almacenada en el buffer de tiles
		20D7 -> 0x05 (0xfa) recupera de la longitud del bloque, la decrementa y si no es cero, vuelve a la dirección que se guardó del bloque
		20E7 -> 0x06 (0xf9) pinta el tile indicado por hl con el siguiente byte leido y cambia la posición de hl (y--)
		20F5 -> 0x07 (0xf8) pinta el tile indicado por hl con el siguiente byte leido y cambia la posición de hl (x++)
		2141 -> 0x08 (0xf7) modifica una posición del buffer de construcción del bloque con una expresión calculada
		204F -> 0x09 (0xf6) cambia la posición de hl (y++)
		2052 -> 0x0a (0xf5) cambia la posición de hl (x++)
		2055 -> 0x0b (0xf4) cambia la posición de hl (y--)
		2058 -> 0x0c (0xf3) cambia la posición de hl (x--)
		205B -> 0x0d (0xf2) modifica la posición en y con la expresión leida
		2066 -> 0x0e (0xf1) modifica la posición en x con la expresión leida
		2077 -> 0x0f (0xf0) incrementa la longitud del bloque en y en el buffer de construcción del bloque
		2071 -> 0x10 (0xef)	incrementa la longitud del bloque en x en el buffer de construcción del bloque
		2083 -> 0x11 (0xee) decrementa la longitud del bloque en y en el buffer de construcción del bloque
		207D -> 0x12 (0xed) decrementa la longitud del bloque en x en el buffer de construcción del bloque
		21B4 -> 0x13 (0xec) interpreta otro bloque modificando los valores de los tiles a usar
		20EE -> 0x14 (0xeb) pinta el tile indicado por hl con el siguiente byte leido y cambia la posición de hl (x--)
		21A1 -> 0x15 (0xea)	cambia el puntero a los datos de construcción del bloque con la primera dirección leida en los datos
		218D -> 0x16 (0xe9) cambia las instrucciones que actualizan la coordenada x de los tiles (incx -> decx)
		218D -> 0x17 (0xe8) cambia las instrucciones que actualizan la coordenada x de los tiles (incx -> decx)
		218D -> 0x18 (0xe7) cambia las instrucciones que actualizan la coordenada x de los tiles (incx -> decx)
		218D -> 0x19 (0xe6) cambia las instrucciones que actualizan la coordenada x de los tiles (incx -> decx)
		218D -> 0x1a (0xe5) cambia las instrucciones que actualizan la coordenada x de los tiles (incx -> decx)
		21AA -> 0x1b (0xe4) interpreta otro bloque sin modificar los valores de los tiles a usar, y cambiando el sentido de las x

; inicia el proceso de interpretación los bytes de construcción de bloques
; sp = puntero a los datos de construcción del bloque
2018: DD E3       ex   (sp),ix		; obtiene el puntero a los datos de construcción del bloque
201A: ED 43 DB 1F ld   ($1FDB),bc

; evalúa los datos de construcción del bloque
; h = pos inicial del bloque en y (sistema de coordenadas del buffer de tiles)
; l = pos inicial del bloque en x (sistema de coordenadas del buffer de tiles)
; b = lgtud del elemento en y
; c = lgtud del elemento en x
; ix = puntero a los datos de construcción del bloque
201E: DD 7E 00    ld   a,(ix+$00)	; lee el primer byte y extrae el número de rutina a usar
2021: DD 23       inc  ix
2023: 2F          cpl				; los comandos se almacenan complementados ya que las rutinas del parser interpretan
2024: 87          add  a,a			;  los valores < 0x60 como números inmediatos que forman parte de las expresiones
2025: E5          push hl
2026: 21 E0 1F    ld   hl,$1FE0		; apunta a una tabla de rutinas
2029: CD 2D 16    call $162D		; hl = hl + a
202C: 5E          ld   e,(hl)
202D: 23          inc  hl
202E: 56          ld   d,(hl)		; de = [hl]
202F: E1          pop  hl
2030: D5          push de			; mete en la pila la rutina a saltar
2031: C9          ret				; salta a la rutina correspondiente

; recupera la dirección del siguiente bloque a procesar y si se cambiaron las coordenadas x (x = -x), deshace el cambio
2032: DD E1       pop  ix			; recupera la dirección del siguiente bloque a procesar
2034: 3A CE 1F    ld   a,($1FCE)	; lee si se cambiaron las operaciones que trabajan con coordenadas x en los tiles (de incx a decx)
2037: A7          and  a
2038: 3E 00       ld   a,$00
203A: 32 CE 1F    ld   ($1FCE),a	; limpia el estado
203D: C0          ret  nz			; si estaban cambiadas las coordenadas, sale

; si no se cambiaron, y restaura el estado de las operaciones
203E: 3E 2C       ld   a,$2C
2040: 32 52 20    ld   ($2052),a	; actualiza las instrucciones de posx++ y posx-- de la posición de los tiles
2043: 32 F8 20    ld   ($20F8),a
2046: 3C          inc  a
2047: 32 58 20    ld   ($2058),a
204A: AF          xor  a
204B: 32 30 22    ld   ($2230),a
204E: C9          ret

; cambia la posición de hl (y++)
204F: 24          inc  h
2050: 18 CC       jr   $201E

; cambia la posición de hl (x++)
2052: 2C          inc  l
2053: 18 C9       jr   $201E

; cambia la posición de hl (y--)
2055: 25          dec  h
2056: 18 C6       jr   $201E

; cambia la posición de hl (x--)
2058: 2D          dec  l
2059: 18 C3       jr   $201E

205B: CD 14 22    call $2214	; lee un valor inmediato o un registro
205E: CD 66 21    call $2166	; modifica c con una expresión
2061: 7C          ld   a,h		; modifica la posición en y con la expresión leida
2062: 81          add  a,c
2063: 67          ld   h,a
2064: 18 B8       jr   $201E

2066: CD 14 22    call $2214	; lee un valor inmediato o un registro
2069: CD 66 21    call $2166	; modifica c con una expresión
206C: 7D          ld   a,l		; modifica la posición en x con la expresión leida
206D: 81          add  a,c
206E: 6F          ld   l,a
206F: 18 AD       jr   $201E

; incrementa la longitud del bloque en x
2071: 0E 01       ld   c,$01
2073: 3E 6E       ld   a,$6E	; entrada de longitud del bloque en x
2075: 18 10       jr   $2087	; longitud del bloque en x = longitud del bloque en x + 1

; incrementa la longitud del bloque en y
2077: 3E 6D       ld   a,$6D	; entrada de longitud del bloque en y
2079: 0E 01       ld   c,$01
207B: 18 0A       jr   $2087	; longitud del bloque en y = longitud del bloque en y + 1

; decrementa la longitud del bloque en x
207D: 3E 6E       ld   a,$6E	; entrada de longitud del bloque en x
207F: 0E FF       ld   c,$FF
2081: 18 04       jr   $2087	; longitud del bloque en x = longitud del bloque en x - 1

; decrementa la longitud del bloque en y
2083: 3E 6D       ld   a,$6D	; entrada de longitud del bloque en y
2085: 0E FF       ld   c,$FF

; modifica el valor de la posición a del buffer de construcción del bloque, sumándole c
2087: C5          push bc
2088: CD 19 22    call $2219		; obtiene el valor de la posición a del buffer de construcción del bloque
208B: 79          ld   a,c
208C: C1          pop  bc
208D: 81          add  a,c			; suma el valor al que se le pasa como parámetro
208E: 12          ld   (de),a		; actualiza las características del material
208F: 18 8D       jr   $201E

2091: 3E 6D       ld   a,$6D
2093: CD 19 22    call $2219		; obtiene la longitud en y del bloque
2096: 28 0D       jr   z,$20A5		; si es != 0, sigue procesando el material, en otro caso salta símbolos hasta que se acaben los datos de construcción

2098: DD E5       push ix
209A: C5          push bc
209B: C3 1E 20    jp   $201E		; sigue procesando el bloque

; guarda en la pila la longitud del bloque en x y la posición actual de los datos de construcción del bloque
209E: 3E 6E       ld   a,$6E
20A0: CD 19 22    call $2219		; obtiene la longitud en x del bloque
20A3: 20 F3       jr   nz,$2098		; si es != 0, sigue procesando el material, en otro caso salta símbolos hasta que se acaben los datos de construcción

; si el bucle no se ejecuta, se salta los comandos intermedios
20A5: 06 01       ld   b,$01		; incialmente estamos dentro de un while
20A7: DD 7E 00    ld   a,(ix+$00)
20AA: DD 23       inc  ix
20AC: DD 23       inc  ix
20AE: FE 82       cp   $82
20B0: 28 F5       jr   z,$20A7		; si es 0x82 (marcador), avanza de 2 en 2
20B2: DD 2B       dec  ix			; en otro caso, de 1 en 1
20B4: 04          inc  b			; suponemos que la instrucción es de un nuevo bucle
20B5: FE FE       cp   $FE			; si encuentra 0xfe y 0xfd (nuevo while) o 0xe8 y 0xe7 (parcheadas???), sigue avanzando
20B7: 28 EE       jr   z,$20A7
20B9: FE FD       cp   $FD
20BB: 28 EA       jr   z,$20A7
20BD: FE E8       cp   $E8
20BF: 28 E6       jr   z,$20A7
20C1: FE E7       cp   $E7
20C3: 28 E2       jr   z,$20A7
20C5: 05          dec  b			; si llega hasta aquí la instrucción no era de un bucle
20C6: FE FA       cp   $FA
20C8: 20 DD       jr   nz,$20A7		; sigue pasando hasta encontrar un fin while
20CA: 10 DB       djnz $20A7		; repite hasta que se llegue al fin del primer bucle
20CC: C3 1E 20    jp   $201E

20CF: E5          push hl
20D0: C3 1E 20    jp   $201E		; sigue procesando los datos del bloque

20D3: E1          pop  hl
20D4: C3 1E 20    jp   $201E		; sigue procesando los datos del bloque

; recupera la longitud y si no es 0, vuelve a saltar a procesar las instrucciones desde la dirección que se guardó. En otro caso, limpia la pila y continúa
20D7: C1          pop  bc			; recupera de la pila la longitud del bloque (bien sea en x o en y)
20D8: 0D          dec  c			; decrementa la longitud
20D9: 28 08       jr   z,$20E3		; si se ha terminado la longitud, saca el otro valor de la pila y salta
20DB: DD E1       pop  ix			; en otro caso, recupera los datos de la secuencia, decrementa la posición y vuelve a procesar el bloque
20DD: DD E5       push ix
20DF: C5          push bc
20E0: C3 1E 20    jp   $201E		; sigue procesando el bloque

20E3: C1          pop  bc			; recupera la posición actual de los datos de construcción del bloque
20E4: C3 1E 20    jp   $201E		; sigue procesando el bloque

; pinta el tile indicado por hl con el siguiente byte leido y cambia la posición de hl (y--)
20E7: CD FC 20    call $20FC
20EA: 25          dec  h		; esta instrucción actualiza una de la rutina anterior
20EB: C3 1E 20    jp   $201E	; sigue procesando el bloque

; pinta el tile indicado por hl con el siguiente byte leido y cambia la posición de hl (x--)
20EE: CD FC 20    call $20FC
20F1: 2D          dec  l		; esta instrucción actualiza una de la rutina anterior
20F2: C3 1E 20    jp   $201E	; sigue procesando el bloque

; pinta el tile indicado por hl con el siguiente byte leido y cambia la posición de hl (x++)
20F5: CD FC 20    call $20FC
20F8: 2C          inc  l		; esta instrucción actualiza una de la rutina anterior
20F9: C3 1E 20    jp   $201E	; sigue procesando el bloque

; lee un byte del buffer de construcción del bloque que indica el número de tile, lee el siguiente byte y lo pinta en hl, modificando hl
;  si el siguiente byte >= 0xc8, sale
;  si el siguiente byte leido es 0x80 dibuja el tile en hl, actualiza las coordenadas y sigue procesando
;  si el siguiente byte leido es 0x81, dibuja el tile en hl y sigue procesando
;  si es otra cosa != 0x00, dibuja el tile en hl, actualiza las coordenadas las veces que haya leido, mira a ver si salta un byte y sale
;  si es otra cosa = 0x00, mira a ver si salta un byte y sale
; hl = posición en el buffer de tiles (sistema de coordenadas del buffer de tiles)
; ix = puntero a los datos de construcción del bloque
20FC: D1          pop  de			; obtiene la dirección de retorno
20FD: 1A          ld   a,(de)
20FE: 32 1B 21    ld   ($211B),a	; modifica una instrucción con el dato leido
2101: 13          inc  de
2102: D5          push de			; graba la nueva dirección de retorno

2103: CD 14 22    call $2214		; lee una posición del buffer de construcción del bloque o un operando
2106: DD 7E 00    ld   a,(ix+$00)	; lee el siguiente byte de los datos de construcción
2109: FE C8       cp   $C8			; si es >= 0xc8, pinta, cambia hl según la operación y sale
210B: 30 0B       jr   nc,$2118
210D: DD 23       inc  ix			; si llega aquí, se usa el byte, por lo que apunta al siguiente elemento
210F: FE 80       cp   $80
2111: 20 0A       jr   nz,$211D		; si el byte leido no era 0x80, salta

; aquí llega si el byte leido es 0x80
2113: CD 18 21    call $2118		; dibuja el tile en hl, actualiza las coordenadas y sigue procesando
2116: 18 EB       jr   $2103

; cuano llega aquí, pinta, hace la operación y sale
2118: CD 33 16    call $1633		; comprueba si el tile indicado por hl es visible, y si es así, actualiza el buffer de tiles
211B: 25          dec  h			; esta instrucción se cambia desde fuera
211C: C9          ret

; aquí llega si el byte leido no es 0x80
211D: FE 81       cp   $81			; si el byte leido no era 0x81, salta
211F: 20 05       jr   nz,$2126

; aquí llega si el byte leido es 0x81
2121: CD 33 16    call $1633		; dibuja el tile en hl y sigue procesando
2124: 18 DD       jr   $2103

; aquí llega si el byte leido no es 0x80 ni 0x81
2126: C5          push bc			; conserva el byte leido anteriormente
2127: CD 14 22    call $2214		; a = número de veces que realizar la operación
212A: 79          ld   a,c
212B: C1          pop  bc
212C: A7          and  a
212D: C4 3A 21    call nz,$213A		; si lo leido es != 0, pinta a veces y realiza la operación a veces

2130: DD 7E 00    ld   a,(ix+$00)
2133: FE C8       cp   $C8			; si es >= 0xc8, sale
2135: D0          ret  nc
2136: DD 23       inc  ix			; salta y sigue procesando
2138: 18 C9       jr   $2103

213A: CD 18 21    call $2118		; pinta y hace la operación
213D: 3D          dec  a
213E: 20 FA       jr   nz,$213A		; repite lo mismo mientras a no sea 0
2140: C9          ret


; modifica la posición del buffer de construcción del bloque (indicada en el primer byte) con una expresión calculada (indicada por los siguientes de bytes)
; h = pos del bloque en y (sistema de coordenadas del buffer de tiles)
; l = pos del bloque en x (sistema de coordenadas del buffer de tiles)
; ix = puntero a los datos de construcción del bloque
2141: DD 7E 00    ld   a,(ix+$00)	; lee un byte
2144: FE 70       cp   $70
2146: F5          push af			; guarda el byte leido
2147: CD 14 22    call $2214		; lee una posición del buffer de construcción del bloque y guarda en de la dirección accedida
214A: D5          push de			; guarda la dirección del buffer obtenida en la rutina anterior
214B: CD 14 22    call $2214		; c = valor inicial
214E: CD 66 21    call $2166		; modifica el valor inicial con sumas de valores o registros y cambios de signo
2151: D1          pop  de			; recupera la dirección obtenida con el primer byte
2152: F1          pop  af			; a = primer byte leido
2153: 38 0C       jr   c,$2161		; si el primer byte leido < 0x70 (no accede a las coordenadas locales del grid), salta

2155: 1A          ld   a,(de)		; lee el valor de la posición a modificar en el buffer de construcción del bloque
2156: A7          and  a
2157: CA 1E 20    jp   z,$201E		; si no se calculan datos locales en la rejilla para el bloque, sale
215A: 79          ld   a,c			; c = valor calculado
215B: FE 64       cp   $64
215D: 38 02       jr   c,$2161		; ajusta el valor a grabar entre 0x00 y 0x64 (0 y 100)
215F: 0E 00       ld   c,$00		; en otro caso lo pone a 0

2161: 79          ld   a,c			; actualiza el valor calculado
2162: 12          ld   (de),a
2163: C3 1E 20    jp   $201E		; continúa generando el bloque

; modifica c con sumas de valores o registros y cambios de signo leidos de los datos de la construcción del bloque
; c = operando 1
; de = puntero a una una posición del buffer de construcción del bloque
; ix = puntero a los datos de construcción del bloque
2166: DD 7E 00    ld   a,(ix+$00)	; lee un byte
2169: FE C8       cp   $C8			; si es >= 0xc8, sale
216B: D0          ret  nc
216C: FE 84       cp   $84
216E: 20 08       jr   nz,$2178		; si no es 0x84, salta
2170: DD 23       inc  ix			; si es 0x84, avanza el puntero y niega el byte leido
2172: 79          ld   a,c			; c = -c
2173: ED 44       neg
2175: 4F          ld   c,a
2176: 18 EE       jr   $2166

; si llega aquí es porque accede a un registro o es un valor inmediato
2178: C5          push bc
2179: CD 14 22    call $2214		; obtiene en c el siguiente byte
217C: 79          ld   a,c
217D: C1          pop  bc
217E: 81          add  a,c			; lo suma con el que ya había
217F: 4F          ld   c,a
2180: 18 E4       jr   $2166

; obtiene en de la dirección de [ix]
2182: DD 5E 00    ld   e,(ix+$00)	; de = [ix]
2185: DD 23       inc  ix
2187: DD 56 00    ld   d,(ix+$00)
218A: DD 23       inc  ix
218C: C9          ret

; cambia las instrucciones que actualizan la coordenada x de los tiles (incx -> decx)
218D: 3E 2D       ld   a,$2D
218F: 32 52 20    ld   ($2052),a
2192: 32 F8 20    ld   ($20F8),a
2195: 3D          dec  a
2196: 32 58 20    ld   ($2058),a
2199: 3E 01       ld   a,$01
219B: 32 30 22    ld   ($2230),a
219E: C3 1E 20    jp   $201E

; h = pos del bloque en y (sistema de coordenadas del buffer de tiles)
; l = pos del bloque en x (sistema de coordenadas del buffer de tiles)
; b = lgtud del elemento en y
; c = lgtud del elemento en x
; ix = puntero a los datos de construcción del bloque
; cambia el puntero a los datos de construcción del bloque
21A1: CD 82 21    call $2182	; obtiene la siguiente dirección de la entrada de materiales
21A4: D5          push de
21A5: DD E1       pop  ix		; ix = de
21A7: C3 1E 20    jp   $201E	; continua evaluando los datos del bloque

21AA: 3E 01       ld   a,$01
21AC: 32 CE 1F    ld   ($1FCE),a	; marca que se realizó un cambio en las operaciones que trabajan con coordenadas x en los tiles
21AF: 11 B9 1B    ld   de,$1BB9		; apunta a la rutina que inicia la evaluación del bloque actual sin modificar los tiles que forman el bloque
21B2: 18 03       jr   $21B7

21B4: 11 BC 1B    ld   de,$1BBC		; apunta a la rutina que inicia la evaluación del bloque actual, modificando los tiles que forman el bloque
21B7: ED 53 EE 21 ld   ($21EE),de	; modifica una instrucción con la dirección
21BB: E5          push hl			; guarda la posición actual en la rejilla
21BC: 3A 52 20    ld   a,($2052)	; obtiene las instrucciones que se usan para tratar las x
21BF: 4F          ld   c,a			; c = lo usado en incTilePosX
21C0: 3A 58 20    ld   a,($2058)
21C3: 47          ld   b,a			; b = lo usado en decTilePosX
21C4: C5          push bc			; guarda los valores usados en las instrucciones incTilePosX y decTilePosX
21C5: 3A F8 20    ld   a,($20F8)
21C8: 4F          ld   c,a			; c = lo usado en DrawTileIncX
21C9: 3A 30 22    ld   a,($2230)
21CC: 47          ld   b,a			; b = xor usado para el posible intercambio entre el reg 0x70 y 0x71
21CD: C5          push bc			; guarda los valores en la pila
21CE: ED 4B DE 1F ld   bc,($1FDE)	; obtiene las posiciones en el sistema de coordenadas de la rejilla y los guarda en pila
21D2: C5          push bc
21D3: ED 4B DB 1F ld   bc,($1FDB)	; obtiene los parámetros para la construcción del bloque y los guarda en pila
21D7: C5          push bc
21D8: 3A DD 1F    ld   a,($1FDD)	; obtiene el parámetro dependiente del byte 4 y lo guarda en pila
21DB: F5          push af

21DC: 11 F0 21    ld   de,$21F0		; guarda la dirección de retorno en pila
21DF: D5          push de
21E0: CD 82 21    call $2182		; obtiene en de el puntero que hay donde están los datos de construcción del bloque
21E3: 3A DD 1F    ld   a,($1FDD)	; a = parámetro dependiente del cuarto byte
21E6: E5          push hl			; mete la posición en la pila
21E7: EB          ex   de,hl		; de = [hl]
21E8: 5E          ld   e,(hl)
21E9: 23          inc  hl
21EA: 56          ld   d,(hl)
21EB: 23          inc  hl
21EC: E3          ex   (sp),hl		; recupera la posición de la pila y mete la dirección de los datos que definen los tiles del bloque
21ED: C3 BC 1B    jp   $1BBC		; instrucción modificada desde fuera

; recupera todos los valores grabados en la pila
21F0: F1          pop  af
21F1: 32 DD 1F    ld   ($1FDD),a
21F4: C1          pop  bc
21F5: ED 43 DB 1F ld   ($1FDB),bc
21F9: C1          pop  bc
21FA: ED 43 DE 1F ld   ($1FDE),bc
21FE: C1          pop  bc
21FF: 79          ld   a,c
2200: 32 F8 20    ld   ($20F8),a
2203: 78          ld   a,b
2204: 32 30 22    ld   ($2230),a
2207: C1          pop  bc
2208: 79          ld   a,c
2209: 32 52 20    ld   ($2052),a
220C: 78          ld   a,b
220D: 32 58 20    ld   ($2058),a
2210: E1          pop  hl
2211: C3 1E 20    jp   $201E

; lee un byte de los datos de construcción del bloque, avanzando el puntero. Si leyó un dato del buffer de construcción del bloque,
; a la salida, de apuntará a dicho registro
; si el byte leido es < 0x60, es un valor y lo devuelve
; si el byte leido es 0x82, sale devolviendo el siguiente byte
; en otro caso, es una operación de lectura de registro de las características del bloque
; ix = puntero a los datos de construcción del bloque
2214: DD 7E 00    ld   a,(ix+$00)	; lee el byte actual e incrementa el puntero
2217: DD 23       inc  ix

2219: 11 CF 1F    ld   de,$1FCF		; apunta al buffer de datos sobre la textura
221C: FE 60       cp   $60			; si el byte leido es < 0x60, comprueba sale
221E: 38 19       jr   c,$2239
2220: FE 82       cp   $82
2222: 20 07       jr   nz,$222B		; si el byte leido != 0x82, salta
2224: DD 7E 00    ld   a,(ix+$00)	; coge el byte siguiente y salta
2227: DD 23       inc  ix
2229: 18 0E       jr   $2239

222B: FE 70       cp   $70			; si el byte leido es < 0x70, salta
222D: 38 02       jr   c,$2231
222F: EE 00       xor  $00			; cambia entre el registro 0x70 y 0x71

2231: D6 61       sub  $61			; a = índice en el buffer de construcción del bloque

; de apunta al comienzo del buffer
2233: 83          add  a,e			; de = de + a
2234: 5F          ld   e,a
2235: 8A          adc  a,d
2236: 93          sub  e
2237: 57          ld   d,a
2238: 1A          ld   a,(de)		; lee la entrada del buffer

2239: 4F          ld   c,a			; comprueba si es 0 antes de salir
223A: A7          and  a
223B: C9          ret
; ---------------------- fin del código y datos relacionados con la generación de las pantallas -----------------------------------

; ??? aquí nunca se llega
223C: 00          nop
223D: C3 9A 24    jp   $249A		; salta al incio real del programa

; restaura la habitación del espejo, cambia la interrupción a un ret, apaga el sonido, obtiene la dirección de la pila al iniciar el juego y salta allí
; probablemente este código se use en conjunción con el del depurador para poder depurar el juego, pero el código que carga el depurador
; ha sido eliminado de la versión final del juego
2240: F3          di
2241: 01 C6 7F    ld   bc,$7FC6
2244: ED 49       out  (c),c			; pone abadia7 en 0x4000
2246: 2A D9 34    ld   hl,($34D9)		; obtiene el puntero a los datos de altura de la habitación del espejo
2249: 36 FF       ld   (hl),$FF			; restaura la altura original del espejo
224B: 01 C0 7F    ld   bc,$7FC0			; restaura la configuración anterior
224E: ED 49       out  (c),c
2250: CD 76 13    call $1376			; apaga el sonido
2253: ED 7B C2 2D ld   sp,($2DC2)		; obtiene la dirección de la pila al iniciar el juego
2257: 3E C9       ld   a,$C9
2259: 38 32 00    ld   ($0038),a		; interrupción = ret
225C: C9          ret

;----------------------- datos y código relacionados con el motor gráfico -------------------------------------
; tabla de rutinas a llamar en 0x2add según la orientación de la cámara
225D:
	248A 2485 248B 2494

2265:
; tabla con datos de la planta baja (0x2255-0x2304) (realmente empieza antes porque en Y = 0 no hay nada)
; X 00 01 02 03 04 05 06 07 08 09 0a 0b 0c 0d 0e 0f  Y
; ================================================== ==
	XX XX XX XX XX XX XX XX XX XX XX XX XX XX XX XX  00
	00 00 00 00 00 00 00 00 27 00 3E 00 00 00 00 00	 01
	00 0A 09 00 07 08 2A 28 26 29 37 38 39 00 00 00	 02
	00 00 02 01 00 0D 0E 24 23 25 2B 2C 2D 00 00 00	 03
	00 00 03 00 1F 00 00 00 22 00 2E 2F 30 00 00 00	 04
	00 00 04 1D 1E 3E 3D 00 21 00 31 32 33 00 00 00	 05
	00 0C 0B 1C 05 06 3C 00 20 00 34 35 36 00 00 00	 06
	00 00 00 0F 10 11 12 00 1B 00 1A 3A 3B 00 00 00	 07
	00 00 00 00 00 00 13 14 15 18 19 00 00 00 00 00	 08
	00 00 00 00 00 00 00 00 16 00 00 00 00 00 00 00	 09
	00 00 00 00 00 00 00 00 17 00 00 00 00 00 00 00	 0a

2305:
; tabla con los datos de la primera planta (realmente empieza antes porque en Y = 0 e Y = 1 no hay nada)
; X 00 01 02 03 04 05 06 07 08 09 0a 0b 0c 0d 0e 0f  Y
; ================================================== ==
	XX XX XX XX XX XX XX XX XX XX XX XX XX XX XX XX  00
	XX XX XX XX XX XX XX XX XX XX XX XX XX XX XX XX  01
	00 45 44 00 48 49 00 00 XX XX XX XX XX XX XX XX  02
	00 00 43 47 4A 00 00 00 XX XX XX XX XX XX XX XX	 03
	00 00 42 00 4B 00 00 00 XX XX XX XX XX XX XX XX	 04
	00 00 41 40 4C 00 00 00 XX XX XX XX XX XX XX XX	 05
	00 3F 46 00 4D 4E 00 00 XX XX XX XX XX XX XX XX	 06

230D:
; tabla con los datos de la segunda planta (realmente empieza antes porque en Y = 0 e Y = 1 no hay nada)
; X 00 01 02 03 04 05 06 07 08 09 0a 0b 0c 0d 0e 0f  Y
; ================================================== ==
	XX XX XX XX XX XX XX XX XX XX XX XX XX XX XX XX  00
	XX XX XX XX XX XX XX XX XX XX XX XX XX XX XX XX  01
	00 67 66 00 65 64 00 00 XX XX XX XX XX XX XX XX  02
	00 00 6A 69 68 00 00 00 XX XX XX XX XX XX XX XX	 03
	00 00 6C 00 6B 00 00 00 XX XX XX XX XX XX XX XX	 04
	00 00 6F 6D 6E 00 00 00 XX XX XX XX XX XX XX XX	 05
	00 73 72 00 71 70 00 00 XX XX XX XX XX XX XX XX	 06

; comprueba si el personaje que se muestra ha cambiado de pantalla y si es así, obtiene los datos de alturas de la nueva pantalla,
; modifica los valores de las posiciones del motor ajustados para la nueva pantalla, inicia los sprites de las puertas y de los objetos
; del juego con la orientación de la pantalla actual y modifica los sprites de los personajes según la orientación de pantalla
2355: 0E 00       ld   c,$00		; inicialmente no ha habido cambios
2357: 21 75 2D    ld   hl,$2D75		; hl apunta a los datos de posición de la pantalla actual
235A: FD 2A 88 2D ld   iy,($2D88)	; iy = puntero con los datos del personaje al que sigue la cámara
235E: FD 7E 02    ld   a,(iy+$02)	; lee la posición en X del personaje actual
2361: E6 F0       and  $F0
2363: BE          cp   (hl)
2364: 28 07       jr   z,$236D		; si la posición en X de la pantalla no ha cambiado, salta

2366: 0C          inc  c			; indica el cambio
2367: 77          ld   (hl),a		; actualiza la posición de la pantalla actual
2368: D6 0C       sub  $0C
236A: 32 E1 2A    ld   ($2AE1),a	; modifica el valor de una rutina

236D: 23          inc  hl
236E: FD 7E 03    ld   a,(iy+$03)	; lee la posición en Y del personaje actual
2371: E6 F0       and  $F0
2373: BE          cp   (hl)
2374: 28 07       jr   z,$237D		; si la posición en Y de la pantalla no ha cambiado, salta

2376: 77          ld   (hl),a		; actualiza la posición de la pantalla actual
2377: 0C          inc  c			; indica el cambio
2378: D6 0C       sub  $0C
237A: 32 EB 2A    ld   ($2AEB),a	; modifica el valor de una rutina

237D: 23          inc  hl
237E: FD 7E 04    ld   a,(iy+$04)	; lee la posición en Z del personaje actual
2381: CD 73 24    call $2473		; dependiendo de la altura, devuelve la altura base de la planta en b
2384: 78          ld   a,b
2385: BE          cp   (hl)
2386: 28 18       jr   z,$23A0		; si la altura no ha cambiado, salta
2388: 32 F9 2A    ld   ($2AF9),a	; modifica el valor de una rutina
238B: 77          ld   (hl),a
238C: 0C          inc  c			; indica el cambio

238D: 21 55 22    ld   hl,$2255		; hl apunta a los datos de la planta baja
2390: A7          and  a
2391: 28 0A       jr   z,$239D		; si la altura es 0, ya está
2393: 21 E5 22    ld   hl,$22E5		; hl apunta a los datos de la primera planta
2396: FE 0B       cp   $0B
2398: 28 03       jr   z,$239D		; si se está en la primera planta, ya está
239A: 21 ED 22    ld   hl,$22ED		; hl apunta a los datos de la segunda planta
239D: 22 EF 23    ld   ($23EF),hl	; modifica el valor de una instrucción según la planta actual

23A0: 79          ld   a,c			; si no ha habido ningún cambio de pantalla, sale
23A1: A7          and  a
23A2: C8          ret  z

23A3: 32 B8 2D    ld   ($2DB8),a	; indica que ha habido un cambio de pantalla
23A6: 3A 77 2D    ld   a,($2D77)	; obtiene la altura base de la planta del personaje que se muestra en pantalla
23A9: FE 16       cp   $16
23AB: 3E 00       ld   a,$00
23AD: 20 17       jr   nz,$23C6		; si no está en la seguda planta, salta (con a = 0)
23AF: 3A 75 2D    ld   a,($2D75)	; lee la coordenada más significativa en x de la pantalla en la que está
23B2: FE 20       cp   $20
23B4: 3E 00       ld   a,$00
23B6: 38 0E       jr   c,$23C6		; si está en una pantalla < 0x20 (pantalla 0x67 o 0x73), salta
23B8: 3E 01       ld   a,$01
23BA: 20 0A       jr   nz,$23C6		; si no está en la 0x20-0x2f, salta (con a = 1)
23BC: 3A 76 2D    ld   a,($2D76)	; lee la coordenada más significativa en y de la pantalla en la que está
23BF: FE 60       cp   $60			; si no está en la 0x60-0x6f (pantalla 0x72), salta (con a = 1)
23C1: 3E 01       ld   a,$01
23C3: 20 01       jr   nz,$23C6
23C5: 3D          dec  a			; a = 0

; aquí llega con a = 0 o a = 1 (encendido/apagado)
23C6: 32 6C 15    ld   ($156C),a	; graba si la pantalla está iluminada o no
23C9: 3E FE       ld   a,$FE
23CB: 32 CF 2F    ld   ($2FCF),a	; marca el sprite de la luz como no visible
23CE: 21 75 2D    ld   hl,$2D75		; en los 4 bits superiores de hl se almacena la parte más significativa de la posición en x del personaje que se muestra en pantalla
23D1: 4E          ld   c,(hl)
23D2: ED 6F       rld  (hl)			; pone en los 4 bits menos significativos de a los 4 bits más significativos de [hl]
23D4: 71          ld   (hl),c		; restaura el valor original
23D5: E6 0F       and  $0F
23D7: 5F          ld   e,a			; e = parte alta de la posición en X del personaje actual (en los 4 bits inferiores)
23D8: E6 01       and  $01
23DA: 47          ld   b,a			; b = pos X & 0x01
23DB: 23          inc  hl
23DC: 4E          ld   c,(hl)		; c = parte alta de la posición en Y del personaje actual
23DD: 79          ld   a,c
23DE: B3          or   e
23DF: 5F          ld   e,a			; e = (Y, X) (desplazamiento dentro del mapa de la planta)
23E0: ED 6F       rld  (hl)			; pone en los 4 bits menos significativos de a los 4 bits más significativos de [hl]
23E2: 71          ld   (hl),c		; restaura el valor original
23E3: E6 01       and  $01			; a = (pos Y & 0x01)

23E5: A8          xor  b			; b = (pos Y & 0x01)^(pos X & 0x01)
23E6: CB 20       sla  b			; b = b*2 (b = 0 ó 2)
23E8: B0          or   b			; a = (((pos Y & 0x01)^(pos X & 0x01)) | ((pos X & 0x01) << 1))
23E9: 32 81 24    ld   ($2481),a	; calcula la orientación de la pantalla actual

23EC: 16 00       ld   d,$00
23EE: 21 55 22    ld   hl,$2255		; instrucción modificada desde fuera para poner en hl la dirección del mapa de la planta
23F1: 19          add  hl,de		; avanza a los datos de la pantalla correspondiente
23F2: 7E          ld   a,(hl)		; lee la pantalla actual
23F3: CD 00 2D    call $2D00		; guarda en 0x156a-0x156b la dirección de los datos de la pantalla actual
23F6: CD 22 2D    call $2D22		; rellena el buffer de alturas con los datos leidos de abadia7.bin y recortados para la pantalla actual
23F9: 3A 81 24    ld   a,($2481)	; lee la orientación de la pantalla que se va a dibujar
23FC: 0F          rrca				; coloca la orientación en los 2 bits superiores para indexar en la tabla (cada entrada son 64 bytes)
23FD: 0F          rrca
23FE: 21 9F 30    ld   hl,$309F		; apunta a la tabla para el cálculo del desplazamiento según la animación de una entidad del juego
2401: 85          add  a,l
2402: 6F          ld   l,a
2403: 8C          adc  a,h
2404: 95          sub  l
2405: 67          ld   h,a			; indexa en la tabla según la orientación
2406: 22 84 2D    ld   ($2D84),hl	; guarda el puntero para luego
2409: 3A 81 24    ld   a,($2481)	; recupera la orientación de la pantalla actual
240C: 87          add  a,a
240D: 21 5D 22    ld   hl,$225D		; apunta a una tabla de rutinas de cambio de sistema de coordenadas
2410: CD 2D 16    call $162D		; hl = hl + a
2413: 5E          ld   e,(hl)
2414: 23          inc  hl
2415: 56          ld   d,(hl)		; de = [hl]
2416: ED 53 01 2B ld   ($2B01),de	; modifica una llamada dependiendo de la orientación de la pantalla
241A: CD 30 0D    call $0D30		; inicia los sprites de las puertas del juego para la habitación actual
241D: CD 23 0D    call $0D23		; inicia los sprites de los objetos del juego para la habitación actual
2420: 21 AE 2B    ld   hl,$2BAE		; apunta a la tabla con datos para los sprites de los personajes
2423: 5E          ld   e,(hl)
2424: 23          inc  hl
2425: 7E          ld   a,(hl)
2426: FE FF       cp   $FF			; mientras no lea 0xff, continua
2428: C8          ret  z
2429: 57          ld   d,a			; de = dirección del sprite asociado al personaje
242A: 23          inc  hl
242B: ED 53 4C 24 ld   ($244C),de	; modifica una instrucción con el primer valor leido (16 bits)
242F: 5E          ld   e,(hl)		; de = siguiente valor
2430: 23          inc  hl
2431: 56          ld   d,(hl)
2432: ED 53 50 24 ld   ($2450),de	; modifica una instrucción con el segundo valor leido (16 bits)
2436: 23          inc  hl			; salta 16 bits y lee el siguiente valor
2437: 23          inc  hl
2438: 23          inc  hl
2439: 5E          ld   e,(hl)
243A: 23          inc  hl
243B: 56          ld   d,(hl)
243C: 23          inc  hl
243D: ED 53 59 2A ld   ($2A59),de	; modifica una instrucción con el tercer valor leido (16 bits)
2441: 5E          ld   e,(hl)		; lee el siguiente valor
2442: 23          inc  hl
2443: 56          ld   d,(hl)
2444: 23          inc  hl
2445: ED 53 84 2A ld   ($2A84),de	; modifica una instrucción
2449: E5          push hl			; guarda la posición de la tabla
244A: DD 21 00 00 ld   ix,$0000		; instrucción modificada desde fuera (pone la dirección del sprite asociado al personaje)
244E: FD 21 00 00 ld   iy,$0000		; instrucción modificada desde fuera (pone la dirección de los datos de posición asociados al personaje)
2452: CD 68 24    call $2468		; procesa los datos del personaje para cambiar la animación y posición del sprite e indicar si es visible o no
2455: FD 4E 0E    ld   c,(iy+$0e)	; lee el valor que indica que tipo de personaje está en una posición
2458: CD EF 28    call $28EF		; si la posición del sprite es central y la altura está bien, pone c en las posiciones que ocupa del buffer de alturas
245B: E1          pop  hl			; recupera la posición de la tabla
245C: 18 C5       jr   $2423		; sigue cogiendo entradas hasta encontrar 0xffff

245E: CD DD 2A    call $2ADD		; comprueba si es visible y si lo es, actualiza su posición si fuese necesario. Si es visible no vuelve, sino que sale a la rutina que lo llamó
2461: DD 36 00 FE ld   (ix+$00),$FE	; marca el sprite como no usado
2465: E1          pop  hl			; saca de la pila la dirección de retorno y la de la tabla de animaciones y sale
2466: E1          pop  hl
2467: C9          ret

; procesa los datos del personaje para cambiar la animación y posición del sprite
;  ix = dirección del sprite correspondiente
;  iy = datos de posición del personaje correspondiente
2468: CD 61 2A    call $2A61	; cambia la animación de los trajes de los monjes según la posición y en contador de animaciones
								;  y obtiene la dirección de los datos de la animación que hay que poner en hl
246B: E5          push hl		; guarda la dirección de la tabla de animaciones
246C: CD 5E 24    call $245E	; comprueba si el sprite es visible y actualiza la posición del sprite. Si el sprite no es visible, no vuelve
246F: E1          pop  hl		; recupera la dirección de la tabla de animaciones
2470: C3 34 2A    jp   $2A34	; actualiza la dirección de gráficos, el ancho y alto del sprite, y flipea los gráficos si es necesario

; dependiendo de la altura, devuelve la altura base de la planta en b
2473: FE 0D       cp   $0D		; 13
2475: 06 00       ld   b,$00
2477: D8          ret  c		; si la altura es < 13 sale con b = 0 (00-12 -> planta baja)
2478: FE 18       cp   $18		; 24
247A: 06 16       ld   b,$16
247C: D0          ret  nc		; si la altura es >= 24 sale con b = 22 (24- -> segunda planta)
247D: 06 0B       ld   b,$0B	; si la altura es >= 13 y < 24 sale con b = 11 (13-23 -> primera planta)
247F: C9          ret

; modifica la orientación que se le pasa en a con la orientación de la pantalla actual
2480: D6 00       sub  $00		; modificado por la orientación con la que entra el personaje a la pantalla
2482: E6 03       and  $03
2484: C9          ret

; realiza el cambio de coordenadas si la orientación la cámara es del tipo 1
2485: 3E 28       ld   a,$28
2487: 94          sub  h
2488: 65          ld   h,l		; y = x
2489: 6F          ld   l,a		; x = 0x28 - y

; realiza el cambio de coordenadas si la orientación la cámara es del tipo 0
248A: C9          ret			; no hace ningún cambio

; realiza el cambio de coordenadas si la orientación la cámara es del tipo 2
248B: 3E 28       ld   a,$28
248D: 94          sub  h
248E: 67          ld   h,a		; y = 0x28 - y
248F: 3E 28       ld   a,$28
2491: 95          sub  l
2492: 6F          ld   l,a		; x = 0x28 - x
2493: C9          ret

; realiza el cambio de coordenadas si la orientación la cámara es del tipo 3
2494: 3E 28       ld   a,$28
2496: 95          sub  l
2497: 6C          ld   l,h		; x = y
2498: 67          ld   h,a		; y = 0x28 - x
2499: C9          ret
;----------------------- fin de los datos y código relacionados con el motor gráfico -------------------------------------

;--------------- aquí llega de 0x0400 una vez que se han cargado los datos a memoria ---------------------------------------
249A: F3          di
249B: 3A FE 00    ld   a,($00FE)	; comprueba si es la primera vez que llega aquí
249E: FE 0D       cp   $0D
24A0: 28 67       jr   z,$2509		; si ya ha entrado aquí, salta la configuración del gate array y la presentación del manuscrito

; inicialización
24A2: 3E 0D       ld   a,$0D
24A4: 32 FE 00    ld   ($00FE),a	; indica que ya ha hecho la inicialización
24A7: 01 8D 7F    ld   bc,$7F8D		; 10001101 (GA select screen mode, rom cfig and int control)
24AA: ED 49       out  (c),c		; fija el modo 1 (320x200 4 colores), deshabilita areas de ROM superior e inferior (solo se accede a la RAM en esas zonas)
24AC: CD 3A 3F    call $3F3A		; pone una paleta de colores negra

24AF: 21 9D 65    ld   hl,$659D		; copia 0x659d-0x759c (las rutinas del manuscrito a pantalla)
24B2: 11 00 C0    ld   de,$C000
24B5: D5          push de
24B6: 01 00 10    ld   bc,$1000
24B9: C5          push bc
24BA: ED B0       ldir

24BC: 01 C5 7F    ld   bc,$7FC5
24BF: ED 49       out  (c),c		; selecciona la configuración (0, 5, 2, 3) (carga abadia6.bin en 0x4000)
24C1: C1          pop  bc
24C2: E1          pop  hl
24C3: 11 00 70    ld   de,$7000		; apunta a una parte de abadia6.bin
24C6: ED B0       ldir				; copia los datos que ha grabado en la memoria de video a abadia6.bin (aunque ya estaban en el destino)
24C8: 01 C0 7F    ld   bc,$7FC0		; restaura la configuración típica (0, 1, 2, 3) (carga abadia2.bin en 0x4000)
24CB: ED 49       out  (c),c

24CD: 3E C3       ld   a,$C3		; coloca el código a ejecutar al producirse una interrupción = jp 0x2d48
24CF: 32 38 00    ld   ($0038),a
24D2: 21 48 2D    ld   hl,$2D48
24D5: 22 39 00    ld   ($0039),hl

24D8: 21 00 80    ld   hl,$8000		; dirección de los datos de la música del manuscrito
24DB: 3E 0B       ld   a,$0B
24DD: 32 86 10    ld   ($1086),a	; cambia un valor relacionado con el tempo de la música
24E0: CD 3F 10    call $103F		; inicializa la tabla del sonido y habilita las interrupciones
24E3: F3          di
24E4: DD 21 00 73 ld   ix,$7300		; apunta al texto del manuscrito de la presentación
24E8: CD 9D 65    call $659D		; dibuja el manuscrito y cuenta la introducción. De aquí vuelve al pulsar espacio
24EB: F3          di

24EC: CD 76 13    call $1376		; apaga el sonido
24EF: CD 3A 3F    call $3F3A		; pone los colores de la paleta a negro

24F2: 21 00 83    ld   hl,$8300		; apunta a los gráficos de abadia3.bin
24F5: 11 00 6D    ld   de,$6D00		; apunta a datos que ya no se usarán (a no ser que se llegue al final del juego, por lo que se copiaron a abadia6.bin)
24F8: 01 00 20    ld   bc,$2000
24FB: ED B0       ldir				; copia los gráficos que componen la abadía y los objetos del juego en 0x6d00-0x8cff

24FD: CD 12 27    call $2712		; limpia las 40 líneas inferiores de la pantalla
2500: CD B6 37    call $37B6		; copia cosas de muchos sitios en 0x0103-0x01a9 (pq??z)
2503: CD 61 3A    call $3A61		; crea la tabla de flipx (0xa100-0xa1ff) para los pixels, obtiene la dirección de abadia7.bin en donde
									;  está la altura del espejo, obtiene la dirección del bloque que forma el espejo de abadia8.bin, y si
									;  estaba abierto, lo cierra
2506: CD D1 3A    call $3AD1		; genera 4 tablas (de 0x100 bytes) para manejo de pixels usando AND y OR en 0x9d00-0xa0ff

; aquí ya se ha completado la inicialización de datos para el juego
; ahora realiza la inicialización para poder empezar a jugar una partida
2509: F3          di
250A: CD 76 13    call $1376		; apaga el sonido
250D: CD BC 32    call $32BC		; lee el estado de las teclas y lo guarda en los buffers de teclado
2510: 3E 2F       ld   a,$2F
2512: CD 82 34    call $3482		; mientras no se suelte el espacio, espera
2515: 20 F2       jr   nz,$2509

2517: CD 1E 38    call $381E		; copia cosas de 0x0103-0x01a9 a muchos sitios (nota: al inicializar se hizo la operación inversa). También inicia
									;  la tabla de sprites y características de los personajes, y limpia los datos de la lógica y variables auxiliares
251A: CD 5C 27    call $275C		; dibuja un rectángulo de 256 de ancho en las 160 líneas superiores de pantalla
251D: CD 2C 27    call $272C		; dibuja el marcador
2520: 3E 06       ld   a,$06
2522: 32 86 10    ld   ($1086),a	; coloca el nuevo tempo de la música
2525: 3E C3       ld   a,$C3		; 0xc3 = instrucción jp xxxx
2527: 32 38 00    ld   ($0038),a	; coloca el código de la IRQ (jp 2d48)

252A: 32 A6 4F    ld   ($4FA6),a	; ???
252D: 32 08 00    ld   ($0008),a	; modifica el código de rst 0x08 y rst 0x10 para que llamen al intérprete de la lógica
2530: 32 10 00    ld   ($0010),a
2533: 21 48 2D    ld   hl,$2D48
2536: 22 39 00    ld   ($0039),hl
2539: 21 D1 3D    ld   hl,$3DD1		; rst 0x08 = jp 0x3dd1
253C: 22 09 00    ld   ($0009),hl
253F: 21 AF 3D    ld   hl,$3DAF		; rst 0x10 = jp 0x3daf
2542: 22 11 00    ld   ($0011),hl

2545: 3A 49 BF    ld   a,($BF49)	; lee abadia3.bin + 0x3f49
2548: 32 18 26    ld   ($2618),a	; sustituye un valor de una instrucción (relacionado con la velocidad del juego)
254B: 2A 50 BF    ld   hl,($BF50)
254E: 22 38 30    ld   ($3038),hl	; coloca la posición incial de guillermo
2551: 24          inc  h
2552: 24          inc  h
2553: 2D          dec  l
2554: 2D          dec  l
2555: 22 47 30    ld   ($3047),hl	; coloca la posición incial de adso
2558: 3A 52 BF    ld   a,($BF52)
255B: 32 3A 30    ld   ($303A),a	; coloca la altura inicial de guillermo y adso
255E: 32 49 30    ld   ($3049),a

2561: 21 59 AB    ld   hl,$AB59		; apunta a los gráficos de los movimientos de los monjes
2564: 11 2E AE    ld   de,$AE2E
2567: D5          push de
2568: 01 D5 02    ld   bc,$02D5		; copia 0xab59-0xae2d a 0xae2e-0xb102
256B: ED B0       ldir
256D: E1          pop  hl			; hl apunta al inicio de los gráficos copiados

256E: 01 05 91    ld   bc,$9105		; gráficos de 5 bytes de ancho, 0x91 bloques de 5 bytes (= 0x2d5)
2571: CD 52 35    call $3552		; obtiene en 0xae2e-0xb102 los gráficos de los monjes flipeados con respecto a x
2574: CD B0 34    call $34B0		; inicia la habitación del espejo y las variables relacionadas con el espejo
2577: CD D2 54    call $54D2		; inicia el día y el momento del día con valores leidos de 0xbf4f y 0xbf4e

257A: 3E 10       ld   a,$10		; dato para que habilite los comandos cuando procese el comportamiento
257C: 32 C0 A2    ld   ($A2C0),a	; inicia el comando de adso
257F: 32 00 A2    ld   ($A200),a	; inicia el comando de malaquías
2582: 32 30 A2    ld   ($A230),a	; inicia el comando del abad
2585: 32 60 A2    ld   ($A260),a	; inicia el comando de berengario
2588: 32 90 A2    ld   ($A290),a	; inicia el comando de severino

258B: AF          xor  a
258C: 32 4B 2D    ld   ($2D4B),a	; resetea el contador de la interrupción

; cuando carga una partida también se llega aquí
258F: F3          di
2590: AF          xor  a
2591: 32 75 2D    ld   ($2D75),a		; inicia la pantalla en la que está el personaje
2594: 32 8F 28    ld   ($288F),a		; inicia el estado de guillermo
2597: 3E 02       ld   a,$02
2599: 32 B1 28    ld   ($28B1),a		; modifica el valor de un argumento de una instrucción del comportamiento de guillermo cuando muere
259C: ED 73 C2 2D ld   ($2DC2),sp		; guarda el valor de la pila con la que se inició el juego

25A0: CD 5C 27    call $275C			; dibuja un rectángulo de 256 de ancho en las 160 líneas superiores de pantalla
25A3: CD 76 13    call $1376			; apaga el sonido
25A6: CD B9 34    call $34B9			; inicia la habitación del espejo
25A9: CD D4 51    call $51D4			; dibuja los objetos que tenemos en el marcador
25AC: CD DF 54    call $54DF			; fija la paleta según el momento del día, muestra el número de día y avanza el momento del día
25AF: CD D3 55    call $55D3			; decrementa el obsequium
25B2: 00          nop					; parámetro de la llamada anterior (decrementar 0 unidades)

25B3: CD 01 50    call $5001			; limpia la parte del marcador donde se muestran las frases
25B6: FB          ei

; el bucle principal del juego empieza aquí
25B7: 00          nop
25B8: 3A 36 30    ld   a,($3036)		; obtiene el contador de la animación de guillermo y modifica una rutina de búsqueda
25BB: 32 90 09    ld   ($0990),a
25BE: CD 11 33    call $3311			; comprueba si se pulsó QR en la habitación del espejo y actúa en consecuencia
25C1: CD 9D 35    call $359D			; comprueba si se pulsó supr pausa, o ctrl+f? o shift+f? y actúa en consecuencia
25C4: CD 89 04    call $0489            ; comprueba si se pulsó ctrl+tab y si es así, intenta grabar las partidas de la memoria a disco
25C7: 3E 07       ld   a,$07
25C9: CD 82 34    call $3482			; comprueba si se ha pulsado el punto del teclado numérico
25CC: C4 4C 3A    call nz,$3A4C			; si se ha pulsado, salta (es un ret, probablemente haya cambiado la dirección de salto)
25CF: CD B6 55    call $55B6			; comprueba si hay que modificar las variables relacionadas con el tiempo (momento del día, combustible de la lámpara, etc)
25D2: CD ED 4F    call $4FED			; ret (probablemente haya cambiado la dirección de salto)
25D5: CD E7 42    call $42E7			; si guillermo ha muerto, calcula el porcentaje de misión completada, lo muestra por pantalla y espera a que se pulse espacio
25D8: CD AC 42    call $42AC            ; actualiza los bonus y si se está leyendo el libro sin los guantes, mata a guillermo
25DB: CD 99 54    call $5499			; si no se ha completado el scroll del cambio del momento del día, lo avanza un paso
25DE: CD EA 3E    call $3EEA			; obtiene el estado de las voces, y ejecuta unas acciones dependiendo del momento del día
25E1: CD D6 41    call $41D6			; comprueba si hay que cambiar el personaje al que sigue la cámara y calcula los bonus que hemos conseguido (interpretado)
25E4: CD 55 23    call $2355			; comprueba si el personaje que se muestra ha cambiado de pantalla y si es así hace muchas cosas
25E7: 3A B8 2D    ld   a,($2DB8)		; si no hay que redibujar la pantalla, salta
25EA: A7          and  a
25EB: 28 05       jr   z,$25F2
25ED: CD D8 19    call $19D8			; dibuja la pantalla actual

25F0: 3E 80       ld   a,$80
25F2: 32 FD 0D    ld   ($0DFD),a		; modifica una instrucción de las rutinas de las puertas indicando que pinta la pantalla
25F5: CD 96 50    call $5096			; comprueba si guillermo y adso cogen o dejan algún objeto
25F8: CD 67 0D    call $0D67			; comprueba si hay que abrir o cerrar alguna puerta y actualiza los sprites de las puertas en consecuencia
25FB: 21 AE 2B    ld   hl,$2BAE			; hl apunta a la tabla de guillermo
25FE: CD 1D 29    call $291D			; comprueba si guillermo puede moverse a donde quiere y actualiza su sprite y el buffer de alturas
2601: CD 64 26    call $2664			; mueve a adso y los monjes
2604: AF          xor  a
2605: 32 B8 2D    ld   ($2DB8),a		; indica que no hay que redibujar la pantalla
2608: 32 A9 2D    ld   ($2DA9),a		; indica que no se ha encontrado ningún camino
260B: CD A3 26    call $26A3			; modifica las características del sprite de la luz si puede ser usada por adso
260E: CD 66 0E    call $0E66			; comprueba si tiene que flipear los gráficos de las puertas y si es así, lo hace
2611: CD 74 53    call $5374			; comprueba si tiene que reflejar los gráficos en el espejo

2614: 3A 4B 2D    ld   a,($2D4B)		; lee el contador que se incrementa en la interrupción
2617: FE 2A       cp   $2A				; modificada desde fuera (a 36)
2619: 38 F9       jr   c,$2614			; espera a que el valor sea >= que el que hay

261B: 3A 36 30    ld   a,($3036)		; si guillermo se está moviendo, pone un sonido
261E: E6 01       and  $01
2620: C4 02 10    call nz,$1002
2623: AF          xor  a
2624: 32 4B 2D    ld   ($2D4B),a		; resetea el contador de la interrupción
2627: CD 74 26    call $2674			; dibuja los sprites
; fin del bucle principal

262A: 3E 42       ld   a,$42
262C: CD 82 34    call $3482		; comprueba si se pulsa escape
262F: CD C6 41    call $41C6		; pone a en 0, para que nunca de como pulsado el escape
2632: CA B7 25    jp   z,$25B7		; si no se pulsa escape, salta al bucle principal

; si se pulsa escape, se salta al depurador, a no ser que se pulse ctrl+shift+escape, que lo que hace es resetear el ordenador
2635: 3E 15       ld   a,$15
2637: CD 82 34    call $3482		; comprueba si se pulsa shift derecho
263A: CA 40 22    jp   z,$2240		; si no se pulsa, restaura la habitación del espejo, cambia la interrupción a un ret,
									;  apaga el sonido, obtiene la dirección de la pila al iniciar el juego y salta allí

263D: 3E 17       ld   a,$17
263F: CD 82 34    call $3482		; comprueba si se pulsa control
2642: CA 40 22    jp   z,$2240		; si no se pulsa, restaura la habitación del espejo, cambia la interrupción a un ret,
									;  apaga el sonido, obtiene la dirección de la pila al iniciar el juego y salta allí

; aquí llega si se está pulsando ctrl+shift derecho+escape
2645: 01 08 00    ld   bc,$0008		; número de datos a copiar
2648: 11 00 00    ld   de,$0000		; destino de los datos
264B: 21 5C 26    ld   hl,$265C		; origen de los datos
264E: ED B0       ldir				; copia los datos
2650: ED 7B C2 2D ld   sp,($2DC2)	; obtiene la dirección de la pila al iniciar el juego
2654: E1          pop  hl
2655: 21 00 00    ld   hl,$0000		; mete un 0, para saltar a la rutina que acaba de escribir
2658: E5          push hl
2659: C3 40 22    jp   $2240		; restaura la habitación del espejo, cambia la interrupción a un ret,
									;  apaga el sonido, obtiene la dirección de la pila al iniciar el juego y salta allí

; nuevo código que copia a 0x0000
265C: 01 89 7F    ld   bc,$7F89		; 10001101 (GA select screen mode, rom cfig and int control)
265F: ED 49       out  (c),c		; fija el modo 1 (320x200 4 colores), deshabilita el área de ROM superior y habilita la inferior
2661: C3 91 05    jp   $0591		; reinicia la máquina


2664: CD 7B 08    call $087B		; ejecuta el comportamiento de adso
2667: CD FD 06    call $06FD		; ejecuta el comportamiento de malaquías
266A: CD 1E 07    call $071E		; ejecuta el comportamiento del abad
266D: CD 30 08    call $0830		; ejecuta el comportamiento de berengario
2670: CD 51 08    call $0851		; ejecuta el comportamiento de severino
2673: C9          ret

; ----------------------- código relacionado con los sprites y la la luz ------------------------------------

; dibuja los sprites
2674: 3A 6C 15    ld   a,($156C)	; lee si la habitación está iluminada o no
2677: A7          and  a
2678: CA 14 49    jp   z,$4914		; si está iluminada, salta a dibujar los sprites

; dibujo de los sprites cuando la habitación no está iluminada
267B: 21 17 2E    ld   hl,$2E17		; hl apunta al primer sprite de los personajes
267E: 11 14 00    ld   de,$0014		; longitud de cada sprite
2681: 7E          ld   a,(hl)
2682: FE FF       cp   $FF
2684: 28 09       jr   z,$268F		; si ha llegado al final, salta
2686: FE FE       cp   $FE
2688: 28 02       jr   z,$268C		; si no es visible, salta la siguiente instrucción
268A: CB BE       res  7,(hl)		; marca el sprite como que no hay que dibujarlo (porque está oscuro)
268C: 19          add  hl,de
268D: 18 F2       jr   $2681		; avanza al siguiente sprite

268F: 3A 2B 2E    ld   a,($2E2B)	; si el sprite de adso es visible, continúa
2692: FE FE       cp   $FE
2694: C8          ret  z
2695: 3A F3 2D    ld   a,($2DF3)	;  y adso tiene la lámpara, continúa
2698: E6 80       and  $80
269A: C8          ret  z

269B: 3E BC       ld   a,$BC
269D: 32 CF 2F    ld   ($2FCF),a	; activa el sprite de la luz
26A0: C3 14 49    jp   $4914		; salta a dibujar los sprites

; modifica las características del sprite de la luz si puede ser usada por adso
26A3: 3E FE       ld   a,$FE
26A5: 32 CF 2F    ld   ($2FCF),a	; desactiva el sprite de la luz
26A8: 3A 6C 15    ld   a,($156C)
26AB: A7          and  a
26AC: C8          ret  z			; si la habitación está iluminada, sale

; aqui llega si es una habitación oscura
26AD: 3A 2B 2E    ld   a,($2E2B)	; si el sprite de adso no es visible, evita que se redibujen los sprites y sale
26B0: FE FE       cp   $FE
26B2: 28 C7       jr   z,$267B

26B4: 3A 2C 2E    ld   a,($2E2C)	; obtiene la posición x del sprite de adso
26B7: 4F          ld   c,a
26B8: E6 03       and  $03
26BA: 32 89 4B    ld   ($4B89),a	; modifica una instrucción con el desplazamiento dentro del tile en x
26BD: ED 44       neg
26BF: C6 04       add  a,$04
26C1: 32 B5 4B    ld   ($4BB5),a	; modifica una instrucción
26C4: 79          ld   a,c
26C5: DD 21 CF 2F ld   ix,$2FCF		; apunta al sprite de la luz
26C9: DD 36 12 FE ld   (ix+$12),$FE	; le da la máxima profundidad al sprite
26CD: DD 36 13 FE ld   (ix+$13),$FE
26D1: E6 FC       and  $FC			; ajusta la posición x del sprite de adso al tile más cercano y la traslada
26D3: D6 08       sub  $08
26D5: 30 01       jr   nc,$26D8
26D7: AF          xor  a
26D8: DD 77 01    ld   (ix+$01),a	; fija la posición x del sprite
26DB: DD 77 03    ld   (ix+$03),a
26DE: 3A 2D 2E    ld   a,($2E2D)	; obtiene la posición y del sprite de adso
26E1: 4F          ld   c,a
26E2: E6 07       and  $07			; obtiene el desplazamiento dentro del tile en y
26E4: FE 04       cp   $04
26E6: 21 EF 00    ld   hl,$00EF		; bytes a rellenar (tile y medio)
26E9: 11 9F 00    ld   de,$009F		; bytes a rellenar (tile)
26EC: 30 01       jr   nc,$26EF		; si es >= 4, salta
26EE: EB          ex   de,hl		; intercambia los rellenos

26EF: 22 6B 4B    ld   ($4B6B),hl	; modifica 2 instrucciones
26F2: ED 53 D1 4B ld   ($4BD1),de
26F6: 79          ld   a,c			; obtiene la posición y del sprite de adso
26F7: E6 F8       and  $F8
26F9: D6 18       sub  $18			; ajusta la posición y del sprite de adso al tile más cercano y la traslada
26FB: 30 01       jr   nc,$26FE
26FD: AF          xor  a
26FE: DD 77 02    ld   (ix+$02),a	; modifica la posición y del sprite
2701: DD 77 04    ld   (ix+$04),a
2704: 21 4B 30    ld   hl,$304B		; apunta al flip de adso
2707: AF          xor  a
2708: CB 46       bit  0,(hl)
270A: 28 02       jr   z,$270E		; si los gráficos no estan flipeados, salta
270C: 3E 29       ld   a,$29
270E: 32 A0 4B    ld   ($4BA0),a	; modifica una instrucción
2711: C9          ret

; ----------------------- fin del código relacionado con los sprites y la la luz ----------------------------------------

; limpia las 40 líneas inferiores de la pantalla
2712: 21 40 C6    ld   hl,$C640		; apunta a memoria de video
2715: 06 08       ld   b,$08		; repite el proceso para 8 bancos
2717: C5          push bc
2718: E5          push hl
2719: 5D          ld   e,l			; de = hl
271A: 54          ld   d,h
271B: 13          inc  de
271C: 36 FF       ld   (hl),$FF
271E: 01 8F 01    ld   bc,$018F		; 5 líneas
2721: ED B0       ldir				; rellena con 0xff desde 0xc640 hasta 0xc7cf
2723: E1          pop  hl
2724: 01 00 08    ld   bc,$0800		; apunta al siguiente banco
2727: 09          add  hl,bc
2728: C1          pop  bc
2729: 10 EC       djnz $2717		; repite hasta terminar
272B: C9          ret

; dibuja el marcador
272C: 01 C7 7F    ld   bc,$7FC7		; fija configuracion 7 (0, 7, 2, 3)
272F: ED 49       out  (c),c
2731: 11 28 63    ld   de,$6328		; apunta a datos del marcador (de 0x6328 a 0x6b27)
2734: 21 48 C6    ld   hl,$C648		; apunta a la dirección en memoria donde se coloca el marcador (32, 160)
2737: 06 04       ld   b,$04
2739: C5          push bc
273A: E5          push hl
273B: 06 08       ld   b,$08		; 8 líneas
273D: C5          push bc
273E: E5          push hl
273F: 01 40 00    ld   bc,$0040		; copia 64 bytes a pantalla (256 pixels)
2742: EB          ex   de,hl
2743: ED B0       ldir
2745: EB          ex   de,hl
2746: E1          pop  hl
2747: 01 00 08    ld   bc,$0800		; pasa a la línea siguiente
274A: 09          add  hl,bc
274B: C1          pop  bc
274C: 10 EF       djnz $273D		; repite para las 8 líneas
274E: E1          pop  hl
274F: 01 50 00    ld   bc,$0050		; apunta a la siguiente línea
2752: 09          add  hl,bc
2753: C1          pop  bc
2754: 10 E3       djnz $2739		; repite para el resto del marcador (en total 32 líneas)

2756: 01 C0 7F    ld   bc,$7FC0		; fija la configuracion 0 (0, 1, 2, 3)
2759: ED 49       out  (c),c
275B: C9          ret

; dibuja un rectángulo de 256 de ancho en las 160 líneas superiores de pantalla
275C: 06 A0       ld   b,$A0		; 160 líneas
275E: 21 00 C0    ld   hl,$C000
2761: C5          push bc
2762: E5          push hl
2763: 5D          ld   e,l			; de = hl + 1
2764: 54          ld   d,h
2765: 13          inc  de
2766: 36 FF       ld   (hl),$FF
2768: 01 08 00    ld   bc,$0008		; rellena 8 bytes con 0xff (32 pixels)
276B: ED B0       ldir
276D: 36 00       ld   (hl),$00
276F: 01 40 00    ld   bc,$0040		; rellena 64 bytes con 0x00 (256 pixels)
2772: ED B0       ldir
2774: 36 FF       ld   (hl),$FF
2776: 01 08 00    ld   bc,$0008		; rellena 8 bytes con 0xff (32 pixels)
2779: ED B0       ldir
277B: E1          pop  hl
277C: CD 4D 3A    call $3A4D		; pasa a la siguiente línea
277F: C1          pop  bc
2780: 10 DF       djnz $2761
2782: C9          ret

; ------------------------ código auxiliar para el movimiento de los personajes --------------------------------------

; devuelve la dirección de la tabla para calcular la altura de las posiciones vecinas según el tamaño de la posición del personaje y la orientación
2783: 21 4D 28    ld   hl,$284D		; apunta a la tabla si el personaje ocupa 4 tiles
2786: FD CB 05 7E bit  7,(iy+$05)
278A: 28 03       jr   z,$278F		; si el bit 7 no está puesto (si el personaje ocupa 4 tiles), salta
278C: 21 6D 28    ld   hl,$286D		; apunta a la tabla si el personaje ocupa sólo 1 tile
278F: FD 7E 01    ld   a,(iy+$01)	; obtiene la orientación del personaje

; hl = hl + 8*a
2792: 87          add  a,a
2793: 87          add  a,a
2794: 87          add  a,a
2795: 85          add  a,l
2796: 6F          ld   l,a
2797: 8C          adc  a,h
2798: 95          sub  l
2799: 67          ld   h,a
279A: C9          ret

; ajusta la posición pasada en hl a las 20x20 posiciones centrales que se muestran. Si la posición está fuera, CF=1
279B: 7C          ld   a,h
279C: D6 00       sub  $00		; instrucción modificada desde fuera con el límite inferior en y
279E: D8          ret  c		; si la posición en y es < el límite inferior en y en esta pantalla, sale
279F: FE 02       cp   $02
27A1: D8          ret  c
27A2: FE 16       cp   $16		; si la posición en y es > el límite superior en y en esta pantalla, sale
27A4: 3F          ccf			; complementa el flag de acarreo
27A5: D8          ret  c

27A6: 67          ld   h,a
27A7: 7D          ld   a,l
27A8: D6 00       sub  $00		; instrucción modificada desde fuera con el límite inferior en x
27AA: D8          ret  c		; si la posición en x es < el límite inferior en x en esta pantalla, sale
27AB: FE 02       cp   $02
27AD: D8          ret  c
27AE: FE 16       cp   $16		; si la posición en x es > el límite superior en x en esta pantalla, sale
27B0: 3F          ccf           ; complementa el flag de acarreo
27B1: D8          ret  c
27B2: 6F          ld   l,a
27B3: C9          ret

; comprueba la altura de las posiciones a las que va a moverse el personaje y las devuelve en a y c
; si el personaje no está visible, se devuelve lo mismo que se pasó en a
; en iy se pasan las características del personaje que se mueve hacia delante
27B4: 47          ld   b,a		; guarda a
27B5: AF          xor  a		; pone que la altura relativa de la planta es 0
27B6: 18 13       jr   $27CB

; comprueba la altura de las posiciones a las que va a moverse el personaje y las devuelve en a y c
; si el personaje no está en la pantalla actual, se devuelve lo mismo que se pasó en a (se supone que ya se ha calculado la diferencia de altura fuera)
; en iy se pasan las características del personaje que se mueve hacia delante
; llamado al pulsar cursor arriba
27B8: 5F          ld   e,a
27B9: FD 7E 04    ld   a,(iy+$04)	; obtiene la altura del personaje
27BC: CD 73 24    call $2473		; dependiendo de la altura, devuelve la altura base de la planta en b
27BF: 3A BA 2D    ld   a,($2DBA)	; obtiene la altura base de la planta en la que está el personaje
27C2: B8          cp   b
27C3: 37          scf
27C4: 7B          ld   a,e
27C5: C0          ret  nz			; si no coincide la planta en la que está el personaje con la que se está mostrando, sale

27C6: FD 7E 04    ld   a,(iy+$04)	; obtiene la altura del personaje
27C9: 90          sub  b			; le resta la altura base de la planta
27CA: 43          ld   b,e

; aquí llega con a = altura relativa dentro de la planta
27CB: 32 1F 28    ld   ($281F),a	; modifica una instrucción
27CE: EB          ex   de,hl
27CF: FD 66 03    ld   h,(iy+$03)	; obtiene la posición global del personaje
27D2: FD 6E 02    ld   l,(iy+$02)
27D5: CD 9B 27    call $279B		; ajusta la posición pasada en hl a las 20x20 posiciones centrales que se muestran. Si la posición está fuera, CF=1
27D8: 78          ld   a,b
27D9: EB          ex   de,hl		; de = posición ajustada a las 20x20 posiciones centrales
27DA: D8          ret  c			; si la posición no es visible, sale

; aquí llega si la posición es visible. en a y en b está el parámetro que se le pasó, pero ya no se usa
27DB: EB          ex   de,hl		; hl = posición ajustada a las 20x20 posiciones centrales
27DC: 7D          ld   a,l			; a = posición x ajustada
27DD: 6C          ld   l,h
27DE: 26 00       ld   h,$00
27E0: 29          add  hl,hl
27E1: 29          add  hl,hl
27E2: 29          add  hl,hl		; hl = pos y ajustada*8
27E3: 54          ld   d,h
27E4: 85          add  a,l
27E5: 5F          ld   e,a			; de = pos x ajustada + pos y ajustada*8
27E6: 29          add  hl,hl		; hl = pos y ajustada*16
27E7: 19          add  hl,de		; hl = pos y ajustada*24 + pos x ajustada
27E8: ED 5B 8A 2D ld   de,($2D8A)	; apunte con de al buffer de alturas
27EC: 19          add  hl,de		; indexa en el buffer de alturas
27ED: EB          ex   de,hl		; de <-> hl
27EE: CD 83 27    call $2783		; devuelve la dirección para calcular la altura de las posiciones vecinas según el tamaño de la posición del personaje y la orientación
27F1: 7E          ld   a,(hl)		; modifica unas instrucciones según los 4 primeros valores leidos de la tabla
27F2: 32 23 28    ld   ($2823),a
27F5: 23          inc  hl
27F6: 7E          ld   a,(hl)
27F7: 32 24 28    ld   ($2824),a
27FA: 23          inc  hl
27FB: 7E          ld   a,(hl)
27FC: 32 2A 28    ld   ($282A),a
27FF: 23          inc  hl
2800: 7E          ld   a,(hl)
2801: 32 2B 28    ld   ($282B),a
2804: 23          inc  hl

2805: 7E          ld   a,(hl)		; lee un desplazamiento de la tabla y la guarda en hl
2806: 23          inc  hl
2807: E5          push hl
2808: 66          ld   h,(hl)
2809: 6F          ld   l,a
280A: 19          add  hl,de		; suma a la posición actual en el buffer de alturas el desplazamiento leido
280B: 11 C5 2D    ld   de,$2DC5		; de apunta a un buffer auxiliar
280E: 06 04       ld   b,$04		; el bucle exterior realiza 4 iteraciones
2810: C5          push bc
2811: E5          push hl
2812: 06 04       ld   b,$04		; el bucle interior realiza 4 iteraciones
2814: C5          push bc
2815: 7E          ld   a,(hl)		; lee el valor de la posición actual del buffer de alturas
2816: FE 10       cp   $10			; comprueba si en esa posición hay algun personaje
2818: 38 04       jr   c,$281E		; si no hay nadie en esa posición, salta
281A: E6 30       and  $30			; se queda sólo con los personajes que hay en la posición
281C: 18 02       jr   $2820		; se salta la siguiente instrucción

281E: D6 00       sub  $00			; instrucción modificada desde fuera con la altura del personaje relativa a la planta actual
2820: 12          ld   (de),a		; guarda el personaje o la diferencia de altura en el buffer
2821: 13          inc  de
2822: 01 00 00    ld   bc,$0000		; instrucción modificada desde fuera con el desplazamiento en el buffer de tiles del bucle interior
2825: 09          add  hl,bc		; cambia la posición del buffer de tiles
2826: C1          pop  bc
2827: 10 EB       djnz $2814
2829: 01 00 00    ld   bc,$0000		; instrucción modificada desde fuera con el desplazamiento en el buffer de tiles del bucle exterior
282C: E1          pop  hl
282D: 09          add  hl,bc		; cambia la posición del buffer de tiles
282E: C1          pop  bc
282F: 10 DF       djnz $2810		; repite hasta completar 16 posiciones

2831: E1          pop  hl
2832: 23          inc  hl
2833: FD CB 05 7E bit  7,(iy+$05)
2837: 28 08       jr   z,$2841		; si el personaje ocupa 4 posiciones en el buffer de alturas, salta. En otro caso (sólo ocupa 1 posición)

2839: 3A C6 2D    ld   a,($2DC6)	; guarda en a y en c el contenido de las 2 posiciones hacia las que avanza el personaje
283C: 4F          ld   c,a
283D: 3A CA 2D    ld   a,($2DCA)
2840: C9          ret

; aquí llega si el personaje ocupa 4 posiciones en el buffer de alturas
2841: 3A C6 2D    ld   a,($2DC6)	; si en las 2 posiciones en las que se avanza no hay lo mismo, sale con valores iguales para a y c
2844: 4F          ld   c,a
2845: 3A C7 2D    ld   a,($2DC7)
2848: B9          cp   c
2849: C8          ret  z
284A: 3E 02       ld   a,$02		; indica que hay una diferencia entre las alturas > 1
284C: C9          ret

; tabla para el cálculo del avance de los personajes según la orientación (para personajes que ocupan 4 tiles)
; bytes 0-1: desplazamiento en el bucle interior del buffer de tiles
; bytes 2-3: desplazamiento en el bucle exterior del buffer de tiles
; bytes 4-5: desplazamiento inicial en el buffer de alturas para el bucle
: byte 6: valor a sumar a la posición x del personaje si avanza en este sentido
: byte 7: valor a sumar a la posición y del personaje si avanza en este sentido
284D: 	0018 FFFF FFD1 01 00 -> +24 -1  -47 [+1 00]
		0001 0018 FFCE 00 FF -> +1  +24 -50 [00 -1]
		FFE8 0001 0016 FF 00 -> -24 +1  +22 [-1 00]
		FFFF FFE8 0019 00 01 -> -1  -24 +25 [00 +1]

; tabla para el cálculo del avance de los personajes según la orientación (para personajes que ocupan 1 tile)
286D: 	0018 FFFF FFEA 01 00 -> +24  -1 -22 [+1 00]
		0001 0018 FFCF 00 FF -> +1  +24 -49 [00 -1]
		FFE8 0001 0016 FF 00 -> -24  +1 +22 [-1 00]
		FFFF FFE8 0031 00 01 -> -1  -24 +49 [00 +1]

; ---------------------- fin del código auxiliar para el movimiento de los personajes --------------------------------------

; rutina del comportamiento de guillermo
; ix que apunta al sprite de guillermo
; iy apunta a los datos de posición de guillermo
288D: 00          nop
288E: 3E 00       ld   a,$00		; instrucción modificada desde fuera y relacionada con 0x2e19
2890: A7          and  a
2891: 28 37       jr   z,$28CA		; si a es 0, salta
2893: 3D          dec  a
2894: C8          ret  z			; si a era 1, sale
2895: 32 8F 28    ld   ($288F),a	; estado de guillermo = estado de guillermo - 1
2898: FE 13       cp   $13
289A: 20 0D       jr   nz,$28A9		; si no es 0x13, salta

; aquí llega si el estado de guillermo es 0x13
289C: 3A B1 28    ld   a,($28B1)
289F: FE 02       cp   $02
28A1: 20 06       jr   nz,$28A9		; si no se modifica el sprite con +2, salta a modificar la y
28A3: FD 35 02    dec  (iy+$02)		; decrementa la posición en x de guillermo
28A6: C3 27 2A    jp   $2A27		; avanza la animación del sprite y lo redibuja

28A9: FE 01       cp   $01			; si se modifica la y del sprite con 1, salta y marca el sprite como inactivo
28AB: 28 18       jr   z,$28C5

28AD: DD 7E 02    ld   a,(ix+$02)
28B0: C6 02       add  a,$02		; modifica la posición y del sprite (esta instrucción se escribe desde fuera)
28B2: DD 77 02    ld   (ix+$02),a
28B5: DD 7E 00    ld   a,(ix+$00)
28B8: E6 3F       and  $3F
28BA: F6 80       or   $80
28BC: DD 77 00    ld   (ix+$00),a	; marca el sprite para dibujar
28BF: 3E FF       ld   a,$FF
28C1: 32 C1 2D    ld   ($2DC1),a	; indica que ha habido movimiento
28C4: C9          ret

; aquí llega si se modifica la y del sprite con 1 y el estado de guillermo es el 0x13
28C5: DD 36 00 FE ld   (ix+$00),$FE	; marca el sprite como inactivo
28C9: C9          ret

; aquí llega si el estado de guillermo es 0, que es el estado normal
28CA: 3A 8F 3C    ld   a,($3C8F)	; si la cámara no sigue a guillermo, sale
28CD: A7          and  a
28CE: C0          ret  nz

28CF: 3E 08       ld   a,$08
28D1: CD 72 34    call $3472		; comprueba si ha cambiado el estado de cursor izquierda
28D4: 0E 01       ld   c,$01
28D6: C2 0C 2A    jp   nz,$2A0C		; si se pulsa cursor izquierda, gira y redibuja el sprite
28D9: 3E 01       ld   a,$01
28DB: CD 72 34    call $3472        ; comprueba si ha cambiado el estado de cursor derecha
28DE: 0E FF       ld   c,$FF
28E0: C2 0C 2A    jp   nz,$2A0C		; si se pulsa cursor derecha, gira y redibuja el sprite

28E3: 3E 00       ld   a,$00
28E5: CD 82 34    call $3482		; si no se ha pulsado el cursor arriba, sale
28E8: C8          ret  z
28E9: CD B8 27    call $27B8		; comprueba la altura de las posiciones a las que va a moverse el personaje y las devuelve en a y c
28EC: C3 54 29    jp   $2954		; si puede moverse hacia delante, actualiza el sprite del personaje

; si la posición del sprite es central y la altura está bien, pone c en las posiciones que ocupa del buffer de alturas
;  iy = dirección de los datos de posición asociados al personaje
;  c = valor a poner en las posiciones que ocupa el personaje del buffer de alturas
28EF: CD BE 0C    call $0CBE		; si la posición no es una de las del centro de la pantalla o la altura del personaje no coincide con
28F2: D8          ret  c			; la altura base de la planta, CF=1, en otro caso ix apunta a la altura de la pos actual

28F3: DD 7E 00    ld   a,(ix+$00)	; obtiene la entrada del buffer de alturas
28F6: E6 0F       and  $0F			; guarda la altura
28F8: B1          or   c			; indica que el personaje está en la posición (x, y)
28F9: DD 77 00    ld   (ix+$00),a	; actualiza el buffer de altura
28FC: FD CB 05 7E bit  7,(iy+$05)	; si el bit 7 del byte 5 está puesto, sale
2900: C0          ret  nz

2901: DD 7E FF    ld   a,(ix-$01)	; indica que el personaje también ocupa la posición (x - 1, y)
2904: E6 0F       and  $0F
2906: B1          or   c
2907: DD 77 FF    ld   (ix-$01),a
290A: DD 7E E8    ld   a,(ix-$18)	; indica que el personaje también ocupa la posición (x, y - 1)
290D: E6 0F       and  $0F
290F: B1          or   c
2910: DD 77 E8    ld   (ix-$18),a
2913: DD 7E E7    ld   a,(ix-$19)	; indica que el personaje también ocupa la posición (x - 1, y - 1)
2916: E6 0F       and  $0F
2918: B1          or   c
2919: DD 77 E7    ld   (ix-$19),a
291C: C9          ret

; comprueba si el personaje puede moverse a donde quiere y actualiza su sprite y el buffer de alturas
; hl apunta a la tabla del personaje a mover
291D: CD F6 2B    call $2BF6		; coloca los parámetros de esta rutina según el personaje de la tabla de hl
2920: DD 21 17 2E ld   ix,$2E17		; apunta a los sprites de los personajes (instrucción modificada desde fuera)
2924: CD B0 2A    call $2AB0		; pone la posición y dimensiones actuales del sprite como posición y dimensiones antiguas
2927: FD 21 36 30 ld   iy,$3036		; apunta a los datos de posición de los personajes (instrucción modificada desde fuera)
292B: 0E 00       ld   c,$00
292D: DD E5       push ix
292F: CD EF 28    call $28EF		; si la posición del sprite es central y la altura está bien, limpia las posiciones que ocupaba el sprite en el buffer de alturas
2932: DD E1       pop  ix
2934: 3A 84 43    ld   a,($4384)	; si malaquías está ascendiendo al morir
2937: A7          and  a
2938: 3E 00       ld   a,$00
293A: 32 84 43    ld   ($4384),a	; pone la variable a 0
293D: CD 45 29    call $2945
2940: FD 4E 0E    ld   c,(iy+$0e)	; lee el valor a poner en el buffer de alturas para indicar que está el personaje
2943: 18 AA       jr   $28EF		; si la posición del sprite es central y la altura está bien, pone c en las posiciones que ocupa del buffer de alturas

2945: C2 27 2A    jp   nz,$2A27		; si malaquías está ascendiendo al morir
2948: FD 7E 00    ld   a,(iy+$00)
294B: E6 01       and  $01
294D: C2 01 2A    jp   nz,$2A01		; si está en medio de un movimiento, incrementa el contador de los bits 0 y 1 del byte 0, avanza la animación del sprite y lo redibuja
2950: 21 8D 28    ld   hl,$288D		; dirección de la rutina que ejecutar para el comportamiento del personaje (instrucción modificada desde fuera)
2953: E9          jp   (hl)			; ejecuta el comportamiento del personaje


; rutina llamada para ver si el personaje avanza
; en a y en c se pasa la diferencia de alturas a la posición a la que quiere avanzar
2954: FD CB 05 A6 res  4,(iy+$05)	; pone a 0 el bit que indica si el personaje está bajando o subiendo
2958: FD CB 05 7E bit  7,(iy+$05)
295C: FD 5E 04    ld   e,(iy+$04)	; e = altura del personaje
295F: 28 56       jr   z,$29B7		; si el personaje ocupa 4 posiciones, salta

; aquí llega si el personaje ocupa una sola posición
;  a = diferencia de altura con la posición más cercana al personaje según la orientación
;  c = diferencia de altura con la posición del personaje + 2 (según la orientación que tenga)
2961: 57          ld   d,a			; d = diferencia de altura con la posición más cercana al personaje según la orientación
2962: 79          ld   a,c			; si en la posición del personaje + 2 (según la orientación que tenga) hay un personaje, sale
2963: FE 10       cp   $10			; si se quiere avanzar a una posición donde hay un personaje, sale
2965: C8          ret  z
2966: FE 20       cp   $20
2968: C8          ret  z

2969: 7A          ld   a,d			; a = diferencia de altura con la posición más cercana al personaje según la orientación
296A: FD CB 05 6E bit  5,(iy+$05)	; si el personaje no está girado en el sentido de subir o bajar en el desnivel, salta
296E: 28 0D       jr   z,$297D

2970: 47          ld   b,a
2971: CD AE 29    call $29AE		; devuelve 0 si la orientación del personaje es 0 o 3, en otro caso devuelve 1
2974: 78          ld   a,b			; cuando va hacia la derecha o hacia abajo, al convertir la posición en 4, solo hay 1 de diferencia
2975: 28 01       jr   z,$2978		;  en cambio, si se va a los otros sentidos al convertir la posición a 4 hay 2 de dif
2977: 79          ld   a,c			; a = diferencia de altura con la posición del personaje + 2 (según la orientación que tenga)
2978: A7          and  a
2979: C0          ret  nz			; si no está a ras de suelo, sale?
297A: C3 FE 29    jp   $29FE

; aquí salta si el bit 5 es 0. Llega con:
;  a = diferencia de altura con la posición más cercana al personaje según la orientación
;  c = diferencia de altura con la posición del personaje + 2 (según la orientación que tenga)
297D: FD 34 04    inc  (iy+$04)		; incrementa la altura del personaje
2980: FE 01       cp   $01
2982: 28 0D       jr   z,$2991		; si se está subiendo una unidad, salta
2984: FD 35 04    dec  (iy+$04)		; deshace el incremento
2987: FE FF       cp   $FF			; si no se está bajando una unidad, sale
2989: C0          ret  nz
298A: FD CB 05 E6 set  4,(iy+$05)	; indica que está bajando
298E: FD 35 04    dec  (iy+$04)		; decrementa la altura del personaje

2991: B9          cp   c			; compara la altura de la posición más cercana al personaje con la siguiente
2992: 20 60       jr   nz,$29F4		;  si las alturas no son iguales, avanza la posición

; aquí llega si avanza y las 2 posiciones siguientes tienen la misma altura
2994: FD 7E 05    ld   a,(iy+$05)	; tan solo deja activo el bit 4, por lo que el personaje pasa de ocupar una posición en el buffer
2997: E6 10       and  $10			;  de alturas a ocupar 4
2999: FD 77 05    ld   (iy+$05),a
299C: E5          push hl
299D: CD E4 29    call $29E4		; actualiza la posición en x y en y del personaje según la orientación hacia la que avanza
29A0: E1          pop  hl
29A1: CD AE 29    call $29AE		; devuelve 0 si la orientación del personaje es 0 o 3, en otro caso devuelve 1
29A4: CC E4 29    call z,$29E4		; actualiza la posición en x y en y del personaje según la orientación hacia la que avanza
29A7: 3E FF       ld   a,$FF
29A9: 32 C1 2D    ld   ($2DC1),a	; indica que ha habido movimiento
29AC: 18 53       jr   $2A01		; incrementa el contador de los bits 0 y 1 del byte 0, avanza la animación del sprite y lo redibuja

; devuelve 0 si la orientación del personaje es 0 o 3, en otro caso devuelve 1
29AE: FD 7E 01    ld   a,(iy+$01)
29B1: E6 03       and  $03
29B3: C8          ret  z
29B4: EE 03       xor  $03
29B6: C9          ret

; aquí salta si el personaje ocupa 4 posiciones. Llega con:
;  a = diferencia de altura con la posicion 1 más cercana al personaje según la orientación
;  c = diferencia de altura con la posicion 2 más cercana al personaje según la orientación
29B7: FE 01       cp   $01
29B9: 28 08       jr   z,$29C3		; si se va hacia arriba, salta
29BB: FE FF       cp   $FF
29BD: 28 0B       jr   z,$29CA		; si se va hacia abajo, salta
29BF: A7          and  a
29C0: C0          ret  nz			; en otro caso, sale si quiere subir o bajar más de una unidad
29C1: 18 31       jr   $29F4		; si no cambia de altura, actualiza la posición según hacia donde se avance, incrementa el contador de los bits 0 y 1 del byte 0, avanza la animación del sprite y lo redibuja

; aquí llega si se sube
29C3: FD 34 04    inc  (iy+$04)		; incrementa la altura del personaje
29C6: 3E 80       ld   a,$80		; cambia el tamaño ocupado en el buffer de alturas de 4 a 1
29C8: 18 05       jr   $29CF

; aquí se llega si se baja
29CA: FD 35 04    dec  (iy+$04)		; decrementa la altura del personaje
29CD: 3E 90       ld   a,$90		; cambia el tamaño ocupado en el buffer de alturas de 4 a 1 e indica que está bajando

29CF: FD 77 05    ld   (iy+$05),a
29D2: E5          push hl
29D3: CD E4 29    call $29E4		; actualiza la posición en x y en y del personaje según la orientación hacia la que avanza
29D6: E1          pop  hl
29D7: CD AE 29    call $29AE		; devuelve 0 si la orientación del personaje es 0 o 3, en otro caso devuelve 1
29DA: C4 E4 29    call nz,$29E4		; actualiza la posición en x y en y del personaje según la orientación hacia la que avanza
29DD: 3E FF       ld   a,$FF
29DF: 32 C1 2D    ld   ($2DC1),a	; indica que ha habido movimiento
29E2: 18 1D       jr   $2A01		; incrementa el contador de los bits 0 y 1 del byte 0, avanza la animación del sprite y lo redibuja

; actualiza la posición en x y en y del personaje según la orientación hacia la que avanza
29E4: 7E          ld   a,(hl)		; lee el incremento en x para la orientación actual
29E5: FD 86 02    add  a,(iy+$02)
29E8: FD 77 02    ld   (iy+$02),a	; modifica la posición en x del personaje
29EB: 23          inc  hl
29EC: 7E          ld   a,(hl)		; lee el incremento en y para la orientación actual
29ED: FD 86 03    add  a,(iy+$03)
29F0: FD 77 03    ld   (iy+$03),a	; modifica la posición en y del personaje
29F3: C9          ret

; actualiza la posición según hacia donde se avance, incrementa el contador de los bits 0 y 1 del byte 0, avanza la animación del sprite y lo redibuja
; aquí salta si las alturas de las 2 posiciones no son iguales. Llega con:
;  a = diferencia de altura con la posición más cercana al personaje según la orientación
;  c = diferencia de altura con la posición del personaje + 2 (según la orientación que tenga)
29F4: 91          sub  c			; halla la diferencia de altura
29F5: 3C          inc  a
29F6: FE 03       cp   $03			; si la diferencia de altura es -1,0 o 1, CF = 0
; ??? para que se hace la comparación si hay un salto incondicional???
29F8: 18 04       jr   $29FE		; actualiza la posición según hacia donde se avance, incrementa el contador de los bits 0 y 1 del byte 0, avanza la animación del sprite y lo redibuja

29FA: FD 73 04    ld   (iy+$04),e	; ??? aquí nunca se llega
29FD: C9          ret

; actualiza la posición según hacia donde se avance, incrementa el contador de los bits 0 y 1 del byte 0, avanza la animación del sprite y lo redibuja
29FE: CD E4 29    call $29E4		; actualiza la posición en x y en y del personaje según la orientación hacia la que avanza

; incrementa el contador de los bits 0 y 1 del byte 0, avanza la animación del sprite y lo redibuja
2A01: FD 7E 00    ld   a,(iy+$00)	; incrementa el contador de los bits 0 y 1
2A04: 3C          inc  a
2A05: E6 03       and  $03
2A07: FD 77 00    ld   (iy+$00),a
2A0A: 18 1B       jr   $2A27		; avanza la animación del sprite y lo redibuja

; aquí llega si se ha pulsado cursor derecha o izquierda
; c = 1 si se pulsó cursor izquierda o -1 si se pulsó cursor derecha
; iy apunta a los datos de posición del personaje
2A0C: FD 36 00 00 ld   (iy+$00),$00	; resetea el contador de la animación
2A10: FD CB 05 7E bit  7,(iy+$05)
2A14: 28 08       jr   z,$2A1E		; si el personaje ocupa más de una casilla en el buffer de alturas, salta
2A16: FD 7E 05    ld   a,(iy+$05)
2A19: EE 20       xor  $20
2A1B: FD 77 05    ld   (iy+$05),a
2A1E: FD 7E 01    ld   a,(iy+$01)	; cambia la orientación del personaje
2A21: 81          add  a,c
2A22: E6 03       and  $03
2A24: FD 77 01    ld   (iy+$01),a

; avanza la animación del sprite y lo redibuja
2A27: CD 61 2A    call $2A61		; cambia la animación de los trajes de los monjes según la posición y el contador de animaciones y obtiene la dirección de los
									;  datos de la animación que hay que poner en hl
2A2A: 3E FF       ld   a,$FF
2A2C: 32 C1 2D    ld   ($2DC1),a	; indica que ha habido movimiento
2A2F: E5          push hl
2A30: CD C9 2A    call $2AC9		; comprueba si el sprite es visible y si es así, actualiza su posición

; aquí solo llega si el sprite es visible
2A33: E1          pop  hl

; aquí se llega desde fuera si un sprite es visible, después de haber actualizado su posición.
;  en hl se apunta a la animación correspondiente para el sprite
;  ix = dirección del sprite correspondiente
;  iy = datos de posición del personaje correspondiente
;  c = posición y en pantalla del sprite
2A34: 7E          ld   a,(hl)
2A35: DD 77 07    ld   (ix+$07),a	; actualiza la dirección de los gráficos del sprite con la animación que toca
2A38: 23          inc  hl
2A39: 7E          ld   a,(hl)
2A3A: DD 77 08    ld   (ix+$08),a
2A3D: 23          inc  hl
2A3E: 7E          ld   a,(hl)
2A3F: DD 77 05    ld   (ix+$05),a	; actualiza el ancho y alto del sprite según la animación que toca
2A42: 23          inc  hl
2A43: 7E          ld   a,(hl)
2A44: DD 77 06    ld   (ix+$06),a
2A47: 3E 80       ld   a,$80		; indica que hay que redibujar el sprite
2A49: B1          or   c			; combina el valor con la posición y de pantalla del sprite
2A4A: DD 77 00    ld   (ix+$00),a
2A4D: FD 7E 01    ld   a,(iy+$01)	; lee la orientación del personaje
2A50: CD 80 24    call $2480		; modifica la orientación que se le pasa en a con la orientación de la pantalla actual
2A53: CB 3F       srl  a
2A55: FD AE 06    xor  (iy+$06)		; comprueba si ha cambiado la orientación del personaje
2A58: C4 3B 35    call nz,$353B		; si es así, salta al método correspondiente (esta llamada se modifica desde fuera) por si hay que flipear los gráficos
2A5B: 3E FF       ld   a,$FF
2A5D: 32 C1 2D    ld   ($2DC1),a	; indica que ha habido movimiento
2A60: C9          ret

; cambia la animación de los trajes de los monjes según la posición y en contador de animaciones y obtiene la dirección de los
;  datos de la animación que hay que poner en hl
;  ix = dirección del sprite correspondiente
;  iy = datos de posición del personaje correspondiente
; al salir en hl se guarda el índice en la tabla de animaciones
2A61: FD 5E 00    ld   e,(iy+$00)	; obtiene la animación del personaje
2A64: FD 7E 01    ld   a,(iy+$01)	; obtiene la orientación del personaje
2A67: CD 80 24    call $2480		; modifica la orientación que se le pasa en a con la orientación de la pantalla actual
2A6A: 57          ld   d,a			; guarda la orientación del personaje en la pantalla actual
2A6B: 87          add  a,a
2A6C: 87          add  a,a			; desplaza la orientación 2 a la izquierda y la combina con la animación
2A6D: B3          or   e			;  para obtener la animación del traje de los monjes
2A6E: 6F          ld   l,a			; guarda en l la animación
2A6F: DD 7E 0B    ld   a,(ix+$0b)	; lee el anitguo valor y se queda con los bits que no son de la animación
2A72: E6 F0       and  $F0
2A74: B5          or   l
2A75: DD 77 0B    ld   (ix+$0b),a	; combina el valor anterior con la animación del traje
2A78: 7A          ld   a,d			; recupera la orientación del personaje en la pantalla actual
2A79: 3C          inc  a
2A7A: E6 02       and  $02			; a indica si el personaje mira hacia la derecha o hacia la izquierda
2A7C: 87          add  a,a			; desplaza 1 bit a la izquierda
2A7D: B3          or   e			; combina con el número de animación actual
2A7E: 87          add  a,a			; desplaza 2 bits a la izquierda (las animaciones de las x y de las y están separadas por 8 entradas)
2A7F: 87          add  a,a
2A80: 6F          ld   l,a			; a = 0 0 0 (si se mueve en x, 0, si se mueve en y, 1) (número de la secuencia de animación (2 bits)) 0 0
2A81: 26 00       ld   h,$00		; hl = índice en la tabla de animaciones
2A83: 11 9F 31    ld   de,$319F		; instrucción modificada desde fuera (con la dirección de la tabla de animaciones para el personaje)
2A86: 7A          ld   a,d
2A87: E6 C0       and  $C0
2A89: FE C0       cp   $C0
2A8B: 28 02       jr   z,$2A8F		; si la dirección que se ha puesto en la instrucción modificada empieza por 0xc0, salta
2A8D: 19          add  hl,de		; indexa en la tabla
2A8E: C9          ret

; aquí llega si la dirección que se ha puesto en la instrucción modificada empieza por 0xc0
; hl = índice en la tabla de animaciones
; e tiene el número de monje que es
2A8F: 7B          ld   a,e			; a = número de monje (0, 2, 4 ó 6)
2A90: EB          ex   de,hl		; de = índice en la tabla de animaciones
2A91: 21 DF 31    ld   hl,$31DF		; apunta a la tabla de animaciones de los monjes
2A94: 19          add  hl,de		; indexa en la tabla de animaciones
2A95: E5          push hl			; guarda la dirección de la tabla de animaciones
2A96: 21 97 30    ld   hl,$3097		; apunta a la tabla con las caras de los monjes (cada entrada ocupa 2 bytes)
2A99: CD 2D 16    call $162D		; hl = hl + a
2A9C: 7E          ld   a,(hl)
2A9D: 23          inc  hl
2A9E: 66          ld   h,(hl)
2A9F: 6F          ld   l,a			; hl = [hl] (puntero a los datos de la cara del monje que se pasa en a)
2AA0: 7B          ld   a,e
2AA1: E6 10       and  $10
2AA3: 28 04       jr   z,$2AA9		; según se mueva en x o en y, pone una cabeza
2AA5: 11 32 00    ld   de,$0032		;  si el bit 4 es 1 (se mueve en y), coge la segunda cara
2AA8: 19          add  hl,de
2AA9: EB          ex   de,hl		; de apunta a los datos de la cara
2AAA: E1          pop  hl			; recupera la dirección de la tabla de animaciones
2AAB: 73          ld   (hl),e
2AAC: 23          inc  hl
2AAD: 72          ld   (hl),d		; sobreescribe los 2 primeros bytes de la entrada de la tabla de animaciones con la dirección de la cara
2AAE: 2B          dec  hl
2AAF: C9          ret

; pone la posición y dimensiones actuales como posición y dimensiones antiguas
2AB0: DD 7E 01    ld   a,(ix+$01)	; copia la posición actual en x y en y como la posición antigua
2AB3: DD 77 03    ld   (ix+$03),a
2AB6: DD 7E 02    ld   a,(ix+$02)
2AB9: DD 77 04    ld   (ix+$04),a
2ABC: DD 7E 05    ld   a,(ix+$05)	; copia el ancho y alto del sprite actual como el ancho y alto antiguos
2ABF: DD 77 09    ld   (ix+$09),a
2AC2: DD 7E 06    ld   a,(ix+$06)
2AC5: DD 77 0A    ld   (ix+$0a),a
2AC8: C9          ret

2AC9: CD DD 2A    call $2ADD			; comprueba si es visible y si lo es, actualiza su posición si fuese necesario. Si es visible no vuelve, sino que sale a la rutina que lo llamó

; aquí llega si el sprite no es visible
2ACC: E1          pop  hl				; saca de la pila la dirección de retorno y la de la tabla de animaciones y sale
2ACD: E1          pop  hl

2ACE: DD 7E 00    ld   a,(ix+$00)		; si el sprite no era visible, sale
2AD1: FE FE       cp   $FE
2AD3: C8          ret  z
2AD4: DD 36 00 80 ld   (ix+$00),$80		; en otro caso, indica que hay que redibujar el sprite
2AD8: DD CB 05 FE set  7,(ix+$05)		; indica que el sprite va a pasar a inactivo, y solo se quiere redibujar la zona que ocupaba
2ADC: C9          ret

; comprueba si el sprite está dentro de la zona visible de pantalla. Si no es así, sale. Si está dentro de la zona visible lo transforma
; a otro sistema de coordenadas. Dependiendo de un parámetro sigue o no. Si sigue actualiza la posición según la orientación
; si no es visible, sale. Si es visible, sale 2 veces (2 pop de pila)
; iy apunta a los datos de posición del personaje asociado
; ix apunta al sprite asociado
2ADD: FD 7E 02    ld   a,(iy+$02)	; coge la coordenada X del personaje
2AE0: D6 00       sub  $00			; modificado desde fuera (4 bits más significativos de la posición X de la pantalla actual - 12)
2AE2: D8          ret  c			; si el objeto en X es < limite inferior visible de X, sale
2AE3: FE 28       cp   $28
2AE5: D0          ret  nc			; si el objeto en X es >= limite superior visible de X, sale
2AE6: 6F          ld   l,a			; l = coordenada X del objeto en la pantalla
2AE7: FD 7E 03    ld   a,(iy+$03)	; coge la coordenada Y del personaje
2AEA: D6 00       sub  $00			; modificado desde fuera (4 bits más significativos de la posición Y de la pantalla actual - 12)
2AEC: D8          ret  c			; si el objeto en Y es < limite inferior visible de Y, sale
2AED: FE 28       cp   $28
2AEF: D0          ret  nc			; si el objeto en Y es >= limite superior visible de Y, sale
2AF0: 67          ld   h,a			; h = coordenada Y del objeto en la pantalla
2AF1: FD 7E 04    ld   a,(iy+$04)	; obtiene la altura del personaje
2AF4: CD 73 24    call $2473		; dependiendo de la altura, devuelve la altura base de la planta en b
2AF7: 78          ld   a,b
2AF8: FE 00       cp   $00			; modificado desde fuera (altura base de la pantalla actual)
2AFA: C0          ret  nz			; si el objeto no está en la misma planta, sale
2AFB: FD 7E 04    ld   a,(iy+$04)
2AFE: 90          sub  b
2AFF: 47          ld   b,a			; b = altura del objeto ajustada para esta pantalla

; al llegar aquí los parámetros son:
; l = coordenada X del objeto en la rejilla
; h = coordenada Y del objeto en la rejilla
; b = altura del objeto en la rejilla ajustada para esta planta
2B00: CD 8A 24    call $248A		; rutina que cambia el sistema de coordenadas dependiendo de la orientación de la pantalla (esta llamada se modifica desde fuera)
2B03: DD 75 12    ld   (ix+$12),l	; graba las nuevas coordenadas x e y en el sprite
2B06: DD 74 13    ld   (ix+$13),h

; convierte las coordenadas en la rejilla a coordenadas de pantalla
2B09: 7C          ld   a,h
2B0A: 85          add  a,l
2B0B: 4F          ld   c,a			; c = pos x + pos y = coordenada y en pantalla
2B0C: 90          sub  b			; le resta la altura (cuanto más alto es el objeto, menor y tiene en pantalla)
2B0D: D8          ret  c			; si la y calculada < 0, sale
2B0E: D6 06       sub  $06			; y calc = y calc - 6 (traslada 6 unidades arriba)
2B10: D8          ret  c			; si y calc < 0, sale
2B11: FE 08       cp   $08
2B13: D8          ret  c			; si y calc < 8, sale
2B14: FE 3A       cp   $3A
2B16: D0          ret  nc			; si y calc  >= 58, sale

; llega aquí si la y calc está entre 8 y 57
2B17: 3C          inc  a			; a = y calc + 1
2B18: 87          add  a,a
2B19: 87          add  a,a			; a = 4*(y calc + 1)
2B1A: 47          ld   b,a			; b = 4*(y calc + 1)
2B1B: 7D          ld   a,l			; a = pos x
2B1C: 94          sub  h			; a = pos x - pos y = coordenada x en pantalla
2B1D: 87          add  a,a			; a = 2*(pos x - pos y)
2B1E: C6 50       add  a,$50		; a = 2*(pos x - pos y) + 80
2B20: D6 28       sub  $28			; 0x28 = 40
2B22: D8          ret  c
2B23: FE 50       cp   $50			; 0x50 = 80
2B25: D0          ret  nc

2B26: 6F          ld   l,a			; l = pos x con nuevo sistema de coordenadas
2B27: 60          ld   h,b			; h = pos y con nuevo sistema de coordenadas

2B28: D1          pop  de			; obtiene la dirección de retorno
2B29: 79          ld   a,c			; a = pos x + pos y = coordenada y en pantalla
2B2A: D6 10       sub  $10			; a = coordenada y en pantalla - 16
2B2C: 30 01       jr   nc,$2B2F		; si la posición en y < 16, pos y = 0
2B2E: AF          xor  a
2B2F: 00          nop				; modificado desde fuera (o es ret o es nop)

; si llega aquí modifica la posición del sprite en pantalla
2B30: 4F          ld   c,a
2B31: 06 00       ld   b,$00		; b = primera entrada
2B33: FD 7E 05    ld   a,(iy+$05)
2B36: CB 7F       bit  7,a
2B38: 20 3E       jr   nz,$2B78		; si el personaje ocupa una posición, salta

2B3A: FD CB 00 46 bit  0,(iy+$00)	; lee el bit 0 del contador de animación
2B3E: 28 01       jr   z,$2B41		; si es 1, avanza a la siguiente entrada
2B40: 04          inc  b

2B41: ED 5B 84 2D ld   de,($2D84)	; obtiene una dirección relacionada con la orientación de la pantalla y la tabla 0x309f
2B45: FD 7E 01    ld   a,(iy+$01)	; obtiene la orientación del personaje
2B48: CD 80 24    call $2480		; modifica la orientación que se le pasa en a con la orientación de la pantalla actual
2B4B: 0F          rrca				; desplaza la orientación 4 bits a la izquierda (cada entrada en la tabla es de 16 bytes)
2B4C: 0F          rrca
2B4D: 0F          rrca
2B4E: 0F          rrca
2B4F: E6 30       and  $30			; a = orientacion*16
2B51: 80          add  a,b			; a = orientacion*16 + 2*b
2B52: 80          add  a,b
2B53: 83          add  a,e			; de = de + a
2B54: 5F          ld   e,a
2B55: 8A          adc  a,d
2B56: 93          sub  e
2B57: 57          ld   d,a

2B58: 1A          ld   a,(de)		; lee un byte de la tabla
2B59: 85          add  a,l			; le suma la x del nuevo sistema de coordenadas
2B5A: FD 86 07    add  a,(iy+$07)	; le suma un desplazamieno
2B5D: 6F          ld   l,a			; actualiza la x
2B5E: 13          inc  de
2B5F: 1A          ld   a,(de)		; lee un byte de la tabla
2B60: 84          add  a,h			; le suma la y del nuevo sistema de coordenadas
2B61: FD 86 08    add  a,(iy+$08)	; le suma un desplazamieno
2B64: 67          ld   h,a			; actualiza la y
2B65: DD 75 01    ld   (ix+$01),l	; graba la posición x del sprite (en bytes)
2B68: DD 74 02    ld   (ix+$02),h	; graba la posición y del sprite (en pixels)
2B6B: DD 7E 00    ld   a,(ix+$00)
2B6E: FE FE       cp   $FE
2B70: C0          ret  nz			; si el sprite no es visible, continua
2B71: DD 75 03    ld   (ix+$03),l	; graba la posición anterior x del sprite (en bytes)
2B74: DD 74 04    ld   (ix+$04),h	; graba la posición anterior y del sprite (en pixels)
2B77: C9          ret

; aquí llega si el personaje ocupa una posición (porque está en los escalones)
2B78: 04          inc  b
2B79: 04          inc  b			; avanza a la tercera entrada
2B7A: FD CB 05 6E bit  5,(iy+$05)
2B7E: 20 BA       jr   nz,$2B3A		; si no está orientado para subir o bajar las escaleras, salta
2B80: 04          inc  b			; avanza a la quinta entrada
2B81: 04          inc  b

; aquí llega si el personaje ocupa una posición y está orientado para subir o bajar las escaleras (ya está apuntando a la 5ª entrada)
2B82: FD 7E 05    ld   a,(iy+$05)
2B85: E6 03       and  $03
2B87: 20 10       jr   nz,$2B99		; esto nunca pasa???
2B89: FD CB 00 46 bit  0,(iy+$00)	; lee el bit 0 del contador de la animación
2B8D: 28 B2       jr   z,$2B41
2B8F: 04          inc  b			; avanza a la sexta entrada

2B90: FD CB 05 66 bit  4,(iy+$05)	; comprueba si está bajando
2B94: 28 AB       jr   z,$2B41
2B96: 04          inc  b			; avanza una entrada
2B97: 18 A8       jr   $2B41

; ??? cuando llega aquí???
2B99: 04          inc  b			; avanza a la octava entrada
2B9A: 04          inc  b
2B9B: 04          inc  b
2B9C: FD CB 05 76 bit  6,(iy+$05)
2BA0: 20 04       jr   nz,$2BA6
2BA2: 04          inc  b			; avanza a la 12ª entrada
2BA3: 04          inc  b
2BA4: 04          inc  b
2BA5: 04          inc  b
2BA6: FE 01       cp   $01			; si los bits 0 y 1 de (iy+05) != 1, salta (entrada 12 o 13)
2BA8: 20 E6       jr   nz,$2B90
2BAA: 04          inc  b			; avanza a la 14ª entrada
2BAB: 04          inc  b
2BAC: 18 E2       jr   $2B90		; salta (entrada 14 o 15)

; tabla con datos para mover los personajes
; la tabla tiene 6 entradas de 10 bytes con el formato:
; byte 0-1: dirección del sprite asociado al personaje
; byte 2-3: dirección a los datos de posición del personaje asociado al sprite
; byte 4-5: dirección de la rutina en la que el personaje piensa
; byte 6-7: rutina a la que llamar si hay que flipear los gráficos
; byte 8-9: dirección de la tabla de animaciones para el personaje
2BAE:	2E17 3036 288D 353B	319F	; guillermo
2BB8:	2E2B 3045 2C3A 34E2	31BF	; adso
2BC2:	2E3F 3054 2C3A 34FB C000	; malaquías
2BCC:	2E53 3063 2C3A 350B	C002	; el abad
2BD6:	2E67 3072 2C3A 351B C004	; berengario
2BE0:	2E7B 3081 2C3A 352B C006	; severino
		FFFF

; tabla de punteros a los parámetros de la rutina
2BEC: 	2922 -> donde copiar la dirección del sprite del personaje actual
		2929 -> donde copiar la dirección de los datos del personaje actual
		2951 -> donde copiar la dirección de la rutina de comportamiento
		2A59 -> donde copiar la rutina a la que llamar para flipear los gráficos
		2A84 -> donde copiar la dirección de la tabla de animaciones para el personaje

; coloca los parámetros de la rutina de 0x2920 para el personaje actual
2BF6: 06 05       ld   b,$05		; 5 valores
2BF8: DD 21 EC 2B ld   ix,$2BEC		; apunta a la tabla de direcciones de los parámetros de la rutina
2BFC: DD 5E 00    ld   e,(ix+$00)	; de = [ix]
2BFF: DD 56 01    ld   d,(ix+$01)
2C02: DD 23       inc  ix
2C04: DD 23       inc  ix
2C06: 7E          ld   a,(hl)		; lee un valor de hl y lo copia a de
2C07: 12          ld   (de),a
2C08: 23          inc  hl
2C09: 13          inc  de
2C0A: 7E          ld   a,(hl)
2C0B: 12          ld   (de),a
2C0C: 23          inc  hl
2C0D: 10 ED       djnz $2BFC		; repite hasta acabar los valores
2C0F: C9          ret


; lee un bit de datos de los comandos del personaje y lo mete en el CF
2C10: FD 7E 09    ld   a,(iy+$09)	; si iy+09 != 0, salta
2C13: A7          and  a
2C14: 20 13       jr   nz,$2C29

; aquí entra si el contador de los bits 0-2 de iy+09 es 0, y el bit 7 de iy+0x09 no es 1
2C16: FD 7E 0C    ld   a,(iy+$0c)	; en 0x0c y 0x0d se guarda un puntero a los datos de los comandos de movimiento del personaje
2C19: FD 86 0B    add  a,(iy+$0b)	; en 0x0b está el índice dentro de los comandos
2C1C: FD 34 0B    inc  (iy+$0b)
2C1F: 6F          ld   l,a
2C20: FD 8E 0D    adc  a,(iy+$0d)
2C23: 95          sub  l
2C24: 67          ld   h,a			; hl = dir(iy+0x0c-iy+0x0d)[iy+0x0b]
2C25: 7E          ld   a,(hl)
2C26: FD 77 0A    ld   (iy+$0a),a	; obtiene un nuevo byte de comandos y lo graba

2C29: FD 7E 09    ld   a,(iy+$09)	; incrementa el contador de los bits 0-2
2C2C: 3C          inc  a
2C2D: E6 07       and  $07
2C2F: FD 77 09    ld   (iy+$09),a
2C32: FD 7E 0A    ld   a,(iy+$0a)	; desplaza los bits de los comandos a la izquierda una posición
2C35: 87          add  a,a
2C36: FD 77 0A    ld   (iy+$0a),a
2C39: C9          ret

; ejecuta los comandos de movimiento para adso y para los monjes
; ix que apunta al sprite del personaje
; iy apunta a los datos de posición del personaje
2C3A: FD CB 09 7E bit  7,(iy+$09)	; si no hay comandos en el buffer, sale
2C3E: C0          ret  nz

2C3F: CD 83 27    call $2783		; devuelve la dirección para calcular la altura de las posiciones vecinas según el tamaño de la posición del personaje y la orientación
2C42: 11 06 00    ld   de,$0006
2C45: 19          add  hl,de		; apunta a la cantidad a sumar a la posición si el personaje sigue avanzando en ese sentido
2C46: E5          push hl
2C47: CD 5C 2D    call $2D5C		; prepara para la copia de datos del personaje al buffer
2C4A: ED B0       ldir				; copia los datos al buffer (0x02-0x0b)
2C4C: CD B8 2C    call $2CB8		; lee en c un comando del personaje
2C4F: E1          pop  hl
2C50: 79          ld   a,c			; a = comando leido
2C51: 0E 01       ld   c,$01		; c = +1
2C53: FE 03       cp   $03
2C55: CA 0C 2A    jp   z,$2A0C		; si obtuvo un 3, se gira a la izquierda
2C58: 0E FF       ld   c,$FF		; c = -1
2C5A: FE 02       cp   $02
2C5C: CA 0C 2A    jp   z,$2A0C		; si obtuvo un 2, se gira a la derecha

2C5F: FD CB 05 7E bit  7,(iy+$05)	; si el personaje ocupa una sola posición en el buffer de alturas, salta
2C63: 20 12       jr   nz,$2C77

; aquí llega si el perosnaje ocupa 4 posiciones en el buffer de alturas, y con c = -1
2C65: FE 01       cp   $01
2C67: 20 04       jr   nz,$2C6D		; si el comando no era 1, salta
2C69: AF          xor  a
2C6A: C3 A0 2C    jp   $2CA0		; si obtuvo un uno, salta a comprobar si se puede mover en esa dirección y si no es así, restaura el estado de posición del personaje

; aquí llega con c = -1 si el personaje ocupa una sola posición en el buffer de alturas o si obtuvo algo distinto de un uno y el personaje ocupa 4 posiciones del buffer de tiles
2C6D: FE 05       cp   $05
2C6F: 3E FF       ld   a,$FF
2C71: 28 2D       jr   z,$2CA0		; comprueba si se puede mover en esa dirección y si no es así, restaura el estado de posición del personaje
2C73: 3E 01       ld   a,$01
2C75: 18 29       jr   $2CA0		; comprueba si se puede mover en esa dirección y si no es así, restaura el estado de posición del personaje

; aqui llega con c = -1 si el personaje ocupa una sola posición en el buffer de alturas
2C77: A7          and  a
2C78: 20 10       jr   nz,$2C8A		; si no obtuvo un 0, salta
2C7A: FD CB 05 6E bit  5,(iy+$05)
2C7E: 28 04       jr   z,$2C84		; si el bit 5 es 0 (si no está girado en un desnivel), salta
2C80: AF          xor  a
2C81: 4F          ld   c,a			; a y c = 0
2C82: 18 1C       jr   $2CA0		; en otro caso, comprueba si se puede mover en esa dirección y si no es así, restaura el estado de posición del personaje

; aquí llega si el personaje ocupa una posición, obtuvo un 0 y el bit 5 era 0 (si no está girado en un desnivel)
2C84: 0E 02       ld   c,$02
2C86: 3E 01       ld   a,$01
2C88: 18 16       jr   $2CA0		; comprueba si se puede mover en esa dirección y si no es así, restaura el estado de posición del personaje

; aquí llega si el personaje ocupa una posición, y no obtuvo un 0
2C8A: FE 01       cp   $01
2C8C: 20 06       jr   nz,$2C94		; si no obtuvo un 1, salta
2C8E: 0E FE       ld   c,$FE
2C90: 3E FF       ld   a,$FF
2C92: 18 0C       jr   $2CA0		; comprueba si se puede mover en esa dirección y si no es así, restaura el estado de posición del personaje

; aquí llega si el personaje ocupa una posición, y no obtuvo un 0 ni un 1
2C94: FE 04       cp   $04
2C96: 20 05       jr   nz,$2C9D		; si no obtuvo un 4, salta
2C98: 0E 01       ld   c,$01
2C9A: 79          ld   a,c

2C9B: 18 03       jr   $2CA0		; comprueba si se puede mover en esa dirección y si no es así, restaura el estado de posición del personaje
2C9D: 0E FF       ld   c,$FF
2C9F: 79          ld   a,c

; comprueba si se puede mover en esa dirección y si no es así, restaura el estado de posición del personaje
; en a pasa la diferencia de altura a donde se mueve, que se usará si el personaje no está en la pantalla actual
2CA0: 47          ld   b,a
2CA1: AF          xor  a
2CA2: 32 C1 2D    ld   ($2DC1),a	; indica que de momento no hay movimiento
2CA5: 78          ld   a,b
2CA6: CD B8 27    call $27B8		; comprueba la altura de las posiciones a las que va a moverse el personaje y las devuelve en a y c
									; si el personaje no está en la pantalla que se muestra, a = lo que se pasó
2CA9: CD 54 29    call $2954		; si puede moverse hacia delante, actualiza el sprite del personaje
2CAC: 3A C1 2D    ld   a,($2DC1)	; si el personaje se ha movido, sale
2CAF: A7          and  a
2CB0: C0          ret  nz
2CB1: CD 5C 2D    call $2D5C		; en otro caso, prepara para la copia de datos del personaje al buffer
2CB4: EB          ex   de,hl
2CB5: ED B0       ldir				; restaura los datos originales ya que no ha podido moverse
2CB7: C9          ret

; lee e interpreta los comandos que se le han pasado al personaje. Según los bits que lea, se devuelven valores:
; * si el personaje ocupa de 4 posiciones:
;   si lee 1 -> devuelve c = 1 -> trata de avanzar una posición hacia delante (con a = 0 y c = -1) -> avanza
;   si lee 010 -> devuelve c = 2 -> gira a la derecha
;   si lee 011 -> devuelve c = 3 -> gira a la izquierda
;   si lee 0010 -> devuelve c = 4 -> trata de avanzar una posición hacia delante (con a = 1 y c = -1) -> sube (y pasa a ocupar una posición)
;   si lee 0011 -> devuelve c = 5 -> trata de avanzar una posición hacia delante (con a = -1 y c = -1) -> baja (y pasa a ocupar una posición)
;   si lee 0001 -> pone el bit 7,(9) y sale 2 rutinas para fuera
;   si lee 0000 -> reinicia el contador, el índice, habilita los comandos, y procesa otro comando
; * si el personaje ocupa de 1 posición:
;   si lee 10 -> devuelve c = 0 -> 	si bit 5 = 1, trata de avanzar una posición hacia delante (con a = 0 y c = 0) -> avanza
;									si bit 5 = 0, sube (y sigue ocupando una posición) (con a = 1 y c = 2)
;   si lee 11 -> devuelve c = 1 -> baja (y sigue ocupando una posición) (con a = -1 y c = -2)
;   si lee 010 -> devuelve c = 2 -> gira a la derecha
;   si lee 011 -> devuelve c = 3 -> gira a la izquierda
;   si lee 0010 -> devuelve c = 4 -> sube (y pasa a ocupar 4 posiciones) (con a = 1 y c = 1)
;   si lee 0011 -> devuelve c = 5 -> baja (y pasa a ocupar 4 posiciones) (con a = -1 y c = -1)
;   si lee 0001 -> pone el bit 7,(9) y sale 2 rutinas para fuera
;   si lee 0000 -> sale con c = 0
2CB8: FD CB 05 7E bit  7,(iy+$05)	; si el personaje ocupa 4 posiciones en el buffer de alturas, salta
2CBC: 28 0D       jr   z,$2CCB

; aqui llega si el personaje ocupa una posicion en el buffer de alturas
2CBE: CD 10 2C    call $2C10		; lee un bit de datos de los comandos del personaje y lo mete en el CF
2CC1: 30 0B       jr   nc,$2CCE		; si ha leido un 0, salta a procesar el resto como si fuera de 4 posiciones
2CC3: CD 10 2C    call $2C10		; lee un bit de datos de los comandos del personaje y lo mete en el CF
2CC6: 0E 00       ld   c,$00
2CC8: CB 11       rl   c			; c = (c << 1) | CF
2CCA: C9          ret

; aqui llega si el personaje ocupa 4 posiciones en el buffer de alturas
2CCB: CD 10 2C    call $2C10		; lee un bit de datos de los comandos del personaje y lo mete en el CF

2CCE: 0E 01       ld   c,$01
2CD0: D8          ret  c			; si ha leido un 1, sale

2CD1: CD 10 2C    call $2C10		; lee un bit de datos de los comandos del personaje y lo mete en el CF
2CD4: 30 06       jr   nc,$2CDC		; si ha leido un 0, salta
2CD6: CD 10 2C    call $2C10		; lee un bit de datos de los comandos del personaje y lo mete en el CF
2CD9: CB 11       rl   c			; c = (c << 1) | CF
2CDB: C9          ret

2CDC: CB 11       rl   c			; c = (c << 1) | CF
2CDE: CD 10 2C    call $2C10		; lee un bit de datos de los comandos del personaje y lo mete en el CF
2CE1: 38 F3       jr   c,$2CD6		; si ha leido un 1, salta
2CE3: CD 10 2C    call $2C10		; lee un bit de datos de los comandos del personaje y lo mete en el CF
2CE6: 38 11       jr   c,$2CF9		; si ha leido un 1, salta

2CE8: 0E 00       ld   c,$00
2CEA: FD CB 05 7E bit  7,(iy+$05)	; si es un personaje que ocupa solo una posición en el buffer de posiciones, sale
2CEE: C0          ret  nz
2CEF: FD 36 0B 00 ld   (iy+$0b),$00 ; reinicia el contador, el índice y habilita los comandos
2CF3: FD 36 09 00 ld   (iy+$09),$00
2CF7: 18 BF       jr   $2CB8

2CF9: FD CB 09 FE set  7,(iy+$09)	; indica que se han acabado los comandos y sale 2 rutinas fuera
2CFD: E1          pop  hl
2CFE: E1          pop  hl
2CFF: C9          ret

; guarda en 0x156a-0x156b la dirección de los datos de la pantalla a
2D00: 32 BD 2D    ld   ($2DBD),a	; guarda la pantalla actual
2D03: 21 00 40    ld   hl,$4000
2D06: A7          and  a
2D07: 28 15       jr   z,$2D1E		; si la pantalla actual no está definida (o es la número 0), salta
2D09: F3          di
2D0A: 01 C7 7F    ld   bc,$7FC7		; carga abadia8
2D0D: ED 49       out  (c),c

2D0F: 47          ld   b,a			; b = pantalla a buscar
2D10: 7E          ld   a,(hl)		; el primer byte indica la longitud de la pantalla en bytes
2D11: 85          add  a,l
2D12: 6F          ld   l,a
2D13: 8C          adc  a,h
2D14: 95          sub  l
2D15: 67          ld   h,a			; incrementa el puntero según ocupe la pantalla
2D16: 10 F8       djnz $2D10		; repite hasta llegar a la pantalla deseada

2D18: 01 C0 7F    ld   bc,$7FC0		; restaura la configuración
2D1B: ED 49       out  (c),c
2D1D: FB          ei
2D1E: 22 6A 15    ld   ($156A),hl	; guarda la dirección de los datos de la pantalla actual
2D21: C9          ret

; rellena el buffer de alturas indicado por 0x2d8a con los datos leidos de abadia7 y recortados para la pantalla del personaje que se le pasa en iy
2D22: 2A 8A 2D    ld   hl,($2D8A)	; hl = obtiene el buffer de alturas a rellenar
2D25: 54          ld   d,h
2D26: 5D          ld   e,l
2D27: 13          inc  de
2D28: 01 3F 02    ld   bc,$023F		; limpia 576 bytes (24x24) = (4 + 16 + 4)x2
2D2B: 36 00       ld   (hl),$00
2D2D: ED B0       ldir

2D2F: CD 8F 0B    call $0B8F		; calcula los mínimos valores visibles de pantalla para la posición del personaje de iy
2D32: A7          and  a
2D33: 21 00 4A    ld   hl,$4A00		; valores de altura de la planta baja
2D36: 28 0A       jr   z,$2D42
2D38: 21 00 4F    ld   hl,$4F00		; valores de altura la primera planta
2D3B: FE 0B       cp   $0B
2D3D: 28 03       jr   z,$2D42
2D3F: 21 80 50    ld   hl,$5080		; valores de altura de la segunda planta

2D42: 22 FB 38    ld   ($38FB),hl	; guarda la dirección dependiente de la planta
2D45: C3 45 39    jp   $3945		; rellena el buffer de pantalla de 0x2d8a con los datos leidos de abadia7 y recortados para la pantalla actual

; ---------------- esta rutina se llama en cada interrupción --------------------------

2D48: F3          di
2D49: F5          push af
2D4A: 3E 00       ld   a,$00		; en la interrupción se cambia el valor de este contador
2D4C: 3C          inc  a
2D4D: 28 03       jr   z,$2D52		; si el contador es 0xff, no modifica el valor
2D4F: 32 4B 2D    ld   ($2D4B),a	; actualiza la variable para la proxima ejecución
2D52: CD 60 10    call $1060		; actualiza la música si fuera necesario
2D55: CD 54 3B    call $3B54		; relacionado con el habla
2D58: F1          pop  af
2D59: FB          ei
2D5A: ED 4D       reti

; prepara para la copia de datos del personaje al buffer
2D5C: FD E5       push iy
2D5E: E1          pop  hl
2D5F: 23          inc  hl			; avanza la posición del puntero hasta los datos de la posición en x
2D60: 23          inc  hl
2D61: 11 68 2D    ld   de,$2D68		; de = destino
2D64: 01 0A 00    ld   bc,$000A		; longitud de los datos
2D67: C9          ret

; buffer auxiliar para los datos
2D68: 01 23 3E 20 12 13 78 04 B9 38

2D72: 00	relacionado con el buffer de teclas de la demo

; usado para simular otra entrada de personaje
2D73: 00          nop
2D74: 00          nop
; posición en X, Y y altura del personaje actual
2D75: 00 00 00

2D78: 01 	; indica si se flipearon los gráficos de las puertas
2D79: 0D 70    ld   bc,$700D
2D7B: 3D          dec  a
2D7C: CD B4 3B    call $3BB4

; copiado en 0x114-0x121
2D7F: 1F 01 04 BC 4F 9F 30 AC 0D 36 30 C0 01 01
	0x2d7f energía (obsequium)
	0x2d80 número de día actual (del 1 al 7)
	0x2d81 momento del día actual
		0 = noche
		1 = prima
		2 = tercia
		3 = sexta
		4 = nona
		5 = visperas
		6 = completas
	0x2d82-0x2d83: puntero a la próxima hora del día
	0x2d84-0x2d85 dirección de la tabla para el cálculo del desplazamiento según la animación de una entidad del juego para la orientación de la pantalla actual
	0x2d86-0x2d87 cantidad de tiempo a esperar para que avance el momento del día (siempre y cuando sea distinto de cero)
	0x2d88-0x2d89 puntero a los datos del personaje actual que se sigue la cámara
	0x2d8a-0x2d8b puntero al buffer de alturas de la pantalla actual (buffer de 576 (24*24) bytes)
	0x2d8c si vale 1 indica que no se ha abierto el espejo. Si vale 0, indica que se ha abierto el espejo

; --- limpia de 0x2d8d a 0x2dd7

2D8D: 07
2D8E: 2313
2D90: 0D20

2D92: F7
2D93: 1838
2D95: E5D5

2D97-2DBB: 00
2DBC: 00 ; si es != 0, contiene el número romano generado para el enigma de la habitación del espejo
2DBD: 00          nop
2DBE: 0000 ; bonus conseguidos
2DC0: 00          nop
2DC1: 00          nop

2DC2: usado para guardar la pila en la inicialización
2DC4: C9          ret

; buffer auxiliar para mover el personaje (usado en la rutina para que guillermo avanza la posición)
2DC5: 38 E1 D1 C1 23 13 10 E8 CD A0 00 7C B5 C8 3A 23

2DD5: 0000
2DD7: 0000

; copiado en 0x122-0x131. puertas a las que pueden entrar los personajes
2DD9: 	08 3038
		08 3047
		1F 3056
		19 3065
		1F 3074
		0C 3083
		FF

; copiado en 0x132-0x154. objetos de los personajes
2DEC: 	01 3038 20 00 FD 00
		01 3047 00 80 02 00
		01 3056 00 80 02 00
		00 3065 00 00 10 00
		00 3074 00 00 00 00
		00 3083 00 00 00 00
		FF

; sprites de los personajes
2E17: FE 1E 42 1E 42 05 22 38B4 05 22 80 00 00 00 00 00 00 00 00 ; guillermo
2E2B: FE 28 32 28 32 05 22 38AA 05 24 80 00 00 00 00 00 00 00 00 ; adso
2E3F: FE 32 32 32 32 05 22 3A2A 05 22 00 00 00 00 00 00 00 00 00 ; malaquías
2E53: FE 32 32 32 32 05 22 3A2A 05 22 00 00 00 00 00 00 00 00 00 ; el abad
2E67: FE 32 32 32 32 05 22 3A2A 05 22 00 00 00 00 00 00 00 00 00 ; berengario
2E7B: FE 32 32 32 32 05 22 3A2A 05 22 00 00 00 00 00 00 00 00 00 ; severino

; sprites de las puertas
2E8F: FE 00 00 00 00 06 28 3A98 06 28 80 00 00 00 00 00 00 00 00 ; puerta de la habitación del abad
2EA3: FE 00 00 00 00 06 28 3A98 06 28 80 00 00 00 00 00 00 00 00 ; puerta de la habitación de los monjes (de al lado de guillermo)
2EB7: FE 00 00 00 00 06 28 3A98 06 28 80 00 00 00 00 00 00 00 00 ; puerta de la habitación de severino
2ECB: FE 00 00 00 00 06 28 3A98 06 28 80 00 00 00 00 00 00 00 00 ; puerta de la salida de las habitaciones hacia la iglesia
2EDF: FE 00 00 00 00 06 28 3A98 06 28 80 00 00 00 00 00 00 00 00 ; puerta de salida del pasadizo de detrás de la cocina
2EF3: FE 00 00 00 00 06 28 3A98 06 28 80 00 00 00 00 00 00 00 00 ; puerta 1 que cierra el paso a la parte izquierda de la planta baja de la abadía
2F07: FE 00 00 00 00 06 28 3A98 06 28 80 00 00 00 00 00 00 00 00 ; puerta 2 que cierra el paso a la parte izquierda de la planta baja de la abadía

; sprites de los objetos
2F1B: FE 00 00 00 00 04 0C 72F0 04 0C 80 00 00 00 00 00 00 00 00 ; libro
2F2F: FE 00 00 00 00 04 0C 89B0 04 0C 80 00 00 00 00 00 00 00 00 ; guantes
2F43: FE 00 00 00 00 04 0C 8980 04 0C 80 00 00 00 00 00 00 00 00 ; gafas
2F57: FE 00 00 00 00 04 0C 8A10 04 0C 80 00 00 00 00 00 00 00 00 ; pergamino
2F6B: FE 00 00 00 00 04 0C 89E0 04 0C 80 00 00 00 00 00 00 00 00 ; llave 1
2F7F: FE 00 00 00 00 04 0C 89E0 04 0C 80 00 00 00 00 00 00 00 00 ; llave 2
2F93: FE 00 00 00 00 04 0C 89E0 04 0C 80 00 00 00 00 00 00 00 00 ; llave 3
2FA7: FE 00 00 00 00 04 0C A006 04 0C 80 00 00 00 00 00 00 00 00 ; ???
2FBB: FE 00 00 00 00 04 0C 72C0 04 0C 80 00 00 00 00 00 00 00 00 ; lámpara
2FCF: FE 00 00 00 00 14 50 0000 14 50 80 00 00 00 00 00 00 FE FE ; sprite de la luz
2FE3: FF

; datos de las puertas del juego. copiado en 0x155-0x174. 5 bytes por entrada
2FE4: 	01 21 61 37 02 ; puerta de la habitación del abad
		02 22 B7 1E 02 ; puerta de la habitación de los monjes (de al lado de guillermo)
		00 04 66 5F 02 ; puerta de la habitación de severino
		03 28 9E 28 02 ; puerta de la salida de las habitaciones hacia la iglesia
		03 10 7E 26 02 ; puerta de salida del pasadizo de detrás de la cocina
		02 E0 60 76 00 ; puerta 1 que cierra el paso a la parte izquierda de la planta baja de la abadía
		02 C0 60 7B 00 ; puerta 2 que cierra el paso a la parte izquierda de la planta baja de la abadía
		FF


; posición de los objetos del juego (copiado en 0x175-0x197). 5 bytes por entrada
3008: 	00 01 34 5E 13
		00 00 6B 55 06
		80 00 EC 2D 00
		00 01 36 5E 13
		00 00 00 00 00
		00 00 00 00 00
		00 00 35 35 13
		00 00 08 08 02
		00 00 08 08 02
		FF

; características de los personajes. 6 entradas de 15 bytes
3036: 	00 01 22 22 00 00 00 FE DE 00 00 00 00 00 10
		00 01 24 24 00 00 00 FE E0 00 FD 00 C0 A2 20
		00 00 26 26 0F 00 00 FE DE 00 FD 00 00 A2 10
		00 00 88 84 02 00 00 FE DE 00 FD 00 30 A2 10
		00 00 28 48 0F 00 00 FE DE 00 FD 00 60 A2 10
		00 00 C8 28 00 00 00 FE DE 00 FD 00 90 A2 10
; -- fin de las 6 entradas de la tabla


3090: 0000
3092: 0000
3094: 00          nop
3095: 00          nop
3096: 00          nop

; tabla con las caras de los monjes
; los datos de las caras para cada monje ocupan 100 bytes y tiene 2 caras (de 50 bytes cada una, una si se mueve en x y otra si se mueve en y)
;  cada cara ocupa 10 pixels de alto
3097: 	B1CB	; puntero a los datos gráficos de la cara de malaquías
		B167	; puntero a los datos gráficos de la cara del abad
309B:	B22F	; puntero a los datos gráficos de la cara de berengario
		B103	; puntero a los datos gráficos de la cara de severino

	; nota: estos no salen en esta tabla pero se listan aquí
		B293 ; puntero a los datos gráficos de la cara de bernardo gui
		B2F7 ; puntero a los datos gráficos de la cara de jorge
		B35B ; puntero a los datos gráficos del encapuchado

; tabla para el cálculo del desplazamiento según la animación de una entidad del juego
; cada tabla es una subtabla según la orientación de la pantalla. Cada entrada de la subtabla es de 16 bytes:
; según una serie de condiciones, se usan 2 byte de la entrada, uno para x (en bytes) y otro para y (en pixels).
; byte 0-1: usados si ocupa 4 posiciones y es el segundo movimiento de la animación
; byte 2-3: usados si ocupa 4 posiciones y es el primer movimiento de la animación
; byte 4-5: usados si ocupa una posición, no está orientado para subir o bajar las escaleras y es el segundo movimiento de la animación
; byte 6-7: usados si ocupa una posición, no está orientado para subir o bajar las escaleras y es el primer movimiento de la animación
; byte 8-9: usados si ocupa una posición, está orientado para subir o bajar las escaleras y es el segundo movimiento de la animación
; byte a-b: usados si ocupa una posición y está bajando las escaleras
; byte c-d: usados si ocupa una posición y está subiendo las escaleras
; byte e-f: ???
309F: 	00 00 FF FE FF 02 FE 00 01 02 00 00 00 FE 00 00 -> [00 00] [-1 -2] [-1 +2] [-2 00] [+1 +2] [00 00] [00 -2] [00 00]
		00 00 FF 02 01 02 00 04 FF 02 FE 06 FE 00 00 00 -> [00 00] [-1 +2] [+1 +2] [00 +4] [-1 +2] [-2 +6] [-2 00] [00 00]
		00 00 01 02 FF 02 00 04 01 02 02 06 02 00 00 00	-> [00 00] [+1 +2] [-1 +2] [00 +4] [+1 +2] [+2 +6] [+2 00] [00 00]
		00 00 01 FE 01 02 02 00 FF 02 00 00	00 FE 00 00 -> [00 00] [+1 -2] [+1 +2] [+2 00] [-1 +2] [00 00] [00 -2] [00 00]

		00 00 FF FE FF 02 FE 00 FF FE FE FC FE FA 00 00 -> [00 00] [-1 -2] [-1 +2] [-2 00] [-1 -2] [-2 -4] [-2 -6] [00 00]
		00 00 FF 02 FF FE FE 00 FF 02 FE 06 FE 00 00 00 -> [00 00] [-1 +2] [-1 -2] [-2 00] [-1 +2] [-2 +6] [-2 00] [00 00]
		00 00 01 02 FF 02 00 04 FF FE 00 02 00 FC 00 00 -> [00 00] [+1 +2] [-1 +2] [00 +4] [-1 -2] [00 +2] [00 -4] [00 00]
		00 00 01 FE FF FE 00 FC FF 02 00 00 00 FE 00 00 -> [00 00] [+1 -2] [-1 -2] [00 -4] [-1 +2] [00 00] [00 -2] [00 00]

		00 00 FF FE 01 FE 00 FC FF FF FE FC FE FA 00 00 -> [00 00] [-1 -2] [+1 -2] [00 -4] [-1 -2] [-2 -4] [-2 -6] [00 00]
		00 00 FF 02 FF FE FE 00 01 FE 00 02 00 FD 00 00 -> [00 00] [-1 +2] [-1 -2] [-2 00] [+1 -2] [00 +2] [00 -3] [00 00]
		00 00 01 02 01 FE 02 00 FF FE 00 02 00 FC 00 00 -> [00 00] [+1 +2] [+1 -2] [+2 00] [-1 -2] [00 +2] [00 -4] [00 00]
		00 00 01 FE FF FE 00 FC 01 FE 02 FC 02 FA 00 00 -> [00 00] [+1 -2] [-1 -2] [00 -4] [+1 -2] [+2 -4] [+2 -6] [00 00]

		00 00 FF FE 01 FE 00 FC	01 02 00 00 00 FE 00 00 -> [00 00] [-1 -2] [+1 -2] [00 -4] [+1 +2] [00 00] [00 -2] [00 00]
		00 00 FF 02 01 02 00 04	01 FE 00 02 00 FC 00 00 -> [00 00] [-1 +2] [+1 +2] [00 +4] [+1 -2] [00 +2] [00 -4] [00 00]
		00 00 01 02 01 FE 02 00 01 02 02 06 02 00 00 00 -> [00 00] [+1 +2] [+1 -2] [+2 00] [+1 +2] [+2 +6] [+2 00] [00 00]
		00 00 01 FE 01 02 02 00 01 FE 02 FC 02 FA 00 00 -> [00 00] [+1 -2] [+1 +2] [+2 00] [+1 -2] [+2 -4] [+2 -6] [00 00]

; cada tabla de animaciones (para adso y guillermo) tiene 8 entradas.
; Las 4 primeras son por si se mueve en el eje x y las otras 4 por si se mueve en el eje Y
; cada entrada son 4 bytes:
; byte 0-1: dirección de los datos gráficos del sprite asociado
; byte 2: ancho del sprite (en bytes)
; byte 3: alto del sprite (en pixels)
; tabla relacionada con la animación de guillermo
319F: 	A3B4 05 22
		A300 05 24
		A3B4 05 22
		A45E 05 22

		A666 04 21
		A508 05 23
		A666 04 21
		A5B7 05 21

; tabla relacionada con la animación de adso
31BF:	A78A 05 20
		A6EA 05 20
		A78A 05 20
		A82A 05 1F
 		A8C5 04 1E
 		A93D 04 1E
 		A8C5 04 1E
 		A9B5 04 1E

; tabla para la animación de los monjes
; cada moje tiene 1 entrada. Cada entrada es de 4 bytes (con estructura similar a la de las animaciones de guillermo y de adso)
31DF:	B103 05 22
		B103 05 24
		B103 05 22
 		B103 05 22

31EF:
 		B135 05 21
 		B135 05 23
 		B135 05 21
 		B135 05 21

; ---------------------- código relacionado con las teclas -------------------------------------------------

; rutina llamada cuando se graban los del teclado al buffer de pulsaciones
31FF: CD BC 32    call $32BC		; lee el estado de las teclas y lo guarda en los buffers de teclado
3202: CD 7E 33    call $337E		; comprueba si se ha terminado el buffer de pulsaciones y si no es así, salta
3205: 38 20       jr   c,$3227

; aquí llega si se ha terminado el buffer de pulsaciones almacenada de la demo
3207: FB          ei
3208: 06 14       ld   b,$14		; 20 veces
320A: C5          push bc
320B: CD 20 10    call $1020		; inicia el canal 3
320E: 01 D0 07    ld   bc,$07D0
3211: CD 0E 49    call $490E		; espera un poco
3214: C1          pop  bc
3215: 10 F3       djnz $320A

; se asegura de que se lean las teclas
3217: 21 BC 32    ld   hl,$32BC
321A: 22 12 33    ld   ($3312),hl	; cambia la forma de leer de la rutina de la QR, para que lea de teclado
321D: AF          xor  a
321E: 32 09 33    ld   ($3309),a	; se asegura de que se obtengan los datos del teclado
3221: 3D          dec  a
3222: 32 69 34    ld   ($3469),a	; se asegura de que la rutina de leer de teclado funcione bien para el teclado
3225: F3          di
3226: C9          ret

; aquí llega si no se ha terminado el buffer de pulsaciones
3227: DD 21 AC 36 ld   ix,$36AC		; ix apunta a la tabla de teclas a grabar
322B: 01 00 08    ld   bc,$0800		; 8 teclas
322E: CD B6 33    call $33B6		; graba en el buffer de pulsaciones el estado de F0-F7
3231: 01 00 08    ld   bc,$0800		; 8 teclas
3234: CD B6 33    call $33B6		; graba en el buffer de pulsaciones el estado de F8-F9, los cursores, espacio y shift
3237: 01 00 08    ld   bc,$0800		; 8 teclas
323A: CD B6 33    call $33B6		; graba en el buffer de pulsaciones el estado de q,r,n,s,y,punto
323D: FD 2B       dec  iy
323F: FD 2B       dec  iy
3241: FD 2B       dec  iy			; apunta a las teclas recien obtenidas
3243: FD 7E 00    ld   a,(iy+$00)
3246: FD BE FC    cp   (iy-$04)
3249: 20 18       jr   nz,$3263		; si cambia alguna de las 8 primeras, graba el nuevo estado en el buffer de pulsaciones
324B: FD 7E 01    ld   a,(iy+$01)
324E: FD BE FD    cp   (iy-$03)
3251: 20 10       jr   nz,$3263		; si cambia alguna de las 8 segundas, graba el nuevo estado en el buffer de pulsaciones
3253: FD 7E 02    ld   a,(iy+$02)
3256: FD BE FE    cp   (iy-$02)
3259: 20 08       jr   nz,$3263		; si cambia alguna de las 8 terceras, graba el nuevo estado en el buffer de pulsaciones

325B: FD 34 FF    inc  (iy-$01)		; si no hay ningún cambio, incrementa el contador que indica el número de veces que no ha habido cambios
325E: 20 13       jr   nz,$3273		;  para el último estado de las teclas, y en ese caso, no graba el nuevo estado
3260: FD 35 FF    dec  (iy-$01)		; si el contador de cambios se desborda, lo deja en 0xff e inicia a 1 el contador del siguiente estado

3263: FD 36 03 01 ld   (iy+$03),$01	; graba el nuevo estado en el buffer de pulsaciones
3267: FD 23       inc  iy
3269: FD 23       inc  iy
326B: FD 23       inc  iy
326D: FD 23       inc  iy
326F: FD 22 D1 33 ld   ($33D1),iy	; graba el puntero del buffer de posiciones

3273: FD 36 00 00 ld   (iy+$00),$00	; marca la nueva entrada como la última, para identificar donde se termina de grabar la demo
3277: FD 36 01 00 ld   (iy+$01),$00
327B: C9          ret

; rutina llamada cuando se leen los datos del buffer de pulsaciones y se copian a los buffers de teclado
327C: F3          di
327D: CD 7E 33    call $337E			; comprueba si se ha terminado el buffer de pulsaciones
3280: 06 01       ld   b,$01
3282: D2 29 36    jp   nc,$3629			; si se ha terminado el buffer, salta y vuelve a iniciar la demo

3285: 3A 72 2D    ld   a,($2D72)		; decrementa el contador de número de veces que no ha cambiado el estado
3288: 3D          dec  a
3289: 20 18       jr   nz,$32A3			; si aún no hay que cambiar el estado, salta
328B: FD 23       inc  iy				; pasa al siguiente estado de teclas almacenado en el buffer
328D: FD 23       inc  iy
328F: FD 23       inc  iy
3291: FD 23       inc  iy
3293: FD 22 D1 33 ld   ($33D1),iy		; actualiza el puntero del buffer de pulsaciones
3297: FD 7E 00    ld   a,(iy+$00)		; si se ha terminado la demo grabada, salta y vuelve a iniciar la demo
329A: FD A6 01    and  (iy+$01)
329D: CA 29 36    jp   z,$3629
32A0: FD 7E 03    ld   a,(iy+$03)		; lee el número de veces que se usa este bloque

32A3: 32 72 2D    ld   ($2D72),a		; actualiza el número de veces a usar este bloque
32A6: DD 21 AC 36 ld   ix,$36AC			; ix apunta a la tabla de teclas que se grabaron en la demo
32AA: CD 94 33    call $3394			; recupera del buffer de pulsaciones el estado del F0-F7 8 teclas y actualiza el buffer donde se guardan las teclas pulsadas
32AD: CD 94 33    call $3394			; recupera del buffer de pulsaciones el estado del F8-F9, los cursores, espacio y shift y actualiza el buffer donde se guardan las teclas pulsadas
32B0: CD 94 33    call $3394			; recupera del buffer de pulsaciones el estado de la q,r,n,s,y,punto y actualiza el buffer donde se guardan las teclas pulsadas
32B3: FD 21 E7 33 ld   iy,$33E7			; coloca el buffer para leer las pulsaciones de las teclas
32B7: 3E 09       ld   a,$09
32B9: 32 09 33    ld   ($3309),a		; se asegura de que se obtengan los datos desde el buffer en vez desde el teclado

; lee el estado de las teclas y lo guarda en los buffers de teclado
32BC: F3          di
32BD: 01 0E F4    ld   bc,$F40E	; 1111 0100 0000 1110 (8255 PPI puerto A)
32C0: ED 49       out  (c),c
32C2: 06 F6       ld   b,$F6
32C4: ED 78       in   a,(c)
32C6: E6 30       and  $30
32C8: 4F          ld   c,a
32C9: F6 C0       or   $C0		; operación PSG escribir índice de registro (activa el 14 para comunicación por el puerto A)
32CB: ED 79       out  (c),a

32CD: ED 49       out  (c),c	; operación PSG: inactivo
32CF: 04          inc  b		; b = 0xf7 escritura al control del 8255 PPI
32D0: 3E 92       ld   a,$92	; 1001 0010 (puerto A: entrada, puerto B: entrada, puerto C superior: salida, puerto C inferior: salida)
32D2: ED 79       out  (c),a
32D4: C5          push bc

32D5: 21 D3 33    ld   hl,$33D3	; apunta al buffer para guardar la última pulsación de cada tecla
32D8: 11 DD 33    ld   de,$33DD ; apunta al buffer donde se guardan los cambios en el estado de la pulsación de las teclas

32DB: CB F1       set  6,c		; operación PSG: leer datos del registro
32DD: 06 F6       ld   b,$F6
32DF: ED 49       out  (c),c
32E1: 06 F4       ld   b,$F4	; puerto A del 8255 PPI
32E3: ED 78       in   a,(c)	; obtiene los datos y los guarda en b
32E5: 47          ld   b,a
32E6: CD 05 33    call $3305	; si hay acarreo, ignora la pulsación de las teclas y coge del buffer IY
32E9: 78          ld   a,b
32EA: B6          or   (hl)		; los combina con los datos anteriores
32EB: 2F          cpl			; los complementa
32EC: 70          ld   (hl),b	; graba el valor leido
32ED: 47          ld   b,a
32EE: 1A          ld   a,(de)	; comprueba si ha habido un cambio en las pulsaciones
32EF: A0          and  b
32F0: B6          or   (hl)
32F1: 12          ld   (de),a	; guarda los cambios
32F2: 0C          inc  c		; pasa a la siguiente línea del teclado
32F3: 13          inc  de		; avanza los buffers de las pulsaciones
32F4: 23          inc  hl
32F5: 79          ld   a,c
32F6: E6 0F       and  $0F
32F8: FE 0A       cp   $0A
32FA: 38 DF       jr   c,$32DB	; mientras no haya terminado las líneas, sigue procesando
32FC: C1          pop  bc
32FD: 3E 82       ld   a,$82	; 1001 0010 (puerto A: salida, puerto B: entrada, puerto C superior: salida, puerto C inferior: salida)
32FF: ED 79       out  (c),a
3301: 05          dec  b
3302: ED 49       out  (c),c	; operación PSG: inactivo
3304: C9          ret

; comprueba si se ignoran las pulsaciones de teclado y se cogen las pulsaciones almacenadas en un buffer
3305: 79          ld   a,c			; obtiene la línea de teclado que está procesando
3306: E6 0F       and  $0F
3308: FE 00       cp   $00			; (este parámetro se modifica desde fuera)
330A: D0          ret  nc			; si la línea a procesar no es mayor que la indicada
330B: FD 46 00    ld   b,(iy+$00)	; coge los datos del buffer apuntado por iy en vez del teclado
330E: FD 23       inc  iy
3310: C9          ret

; comprueba si se pulsó QR en la habitación del espejo y actúa en consecuencia
3311: CD BC 32    call $32BC		; lee el estado de las teclas y lo guarda en los buffers de teclado
3314: 01 C0 7F    ld   bc,$7FC0		; fija la configuración 0 (0, 1, 2, 3)
3317: ED 49       out  (c),c
3319: FB          ei
331A: 3A 8C 2D    ld   a,($2D8C)	; comprueba si se ha abierto el espejo
331D: A7          and  a
331E: C8          ret  z			; si ya se ha abierto, sale

331F: CD F1 33    call $33F1		; comprueba si está delante del espejo y si es así, si se pulsó la Q y la R, devolviendo en e el resultado
3322: 7B          ld   a,e
3323: A7          and  a
3324: C8          ret  z			; si no se pulsó QR en alguna escalera, sale
3325: 3A BC 2D    ld   a,($2DBC)	; obtiene el número romano de la habitación del espejo.
3328: FE 04       cp   $04
332A: 28 08       jr   z,$3334		; si es 4, muere (cuando pasa esto???)
332C: 21 BF 2D    ld   hl,$2DBF		; apunta a los bonus
332F: CB D6       set  2,(hl)		; pone a 1 el bit que indica que se ha pulsado QR en alguna de las escaleras del espejo
3331: BB          cp   e			; si coincide con la escalera del número romano, sobrevive
3332: 28 1A       jr   z,$334E

; si llega aquí, guillermo muere
3334: 3E 01       ld   a,$01
3336: 32 97 3C    ld   ($3C97),a	; indica que guillermo muere
3339: 3E 14       ld   a,$14
333B: 32 8F 28    ld   ($288F),a	; cambia el estado de guillermo

333E: 3E 6B       ld   a,$6B
3340: 2A E0 34    ld   hl,($34E0)	; obtiene el puntero al bloque que forma el espejo
3343: 2B          dec  hl
3344: 2B          dec  hl
3345: CD 72 33    call $3372		; cambia los datos de un bloque de la habitación del espejo para que se abra una trampa y se caiga guillermo
3348: CD 1B 50    call $501B		; escribe en el marcador la frase
334B: 22 							ESTAIS MUERTO, FRAY GUILLERMO, HABEIS CAIDO EN LA TRAMPA
334C: 18 0C       jr   $335A

; si llega aquí, guillermo sobrevive
334E: F3          di
334F: 3E FF       ld   a,$FF
3351: CD 65 33    call $3365		; modifica los datos de altura de la habitación del espejo
3354: 3E 51       ld   a,$51
3356: CD 6F 33    call $336F		; modifica los datos de la habitación del espejo para que el espejo esté abierto
3359: FB          ei

335A: AF          xor  a
335B: 32 75 2D    ld   ($2D75),a	; indica un cambio de pantalla
335E: 32 8C 2D    ld   ($2D8C),a	; indica que se ha abierto el espejo
3361: CD FD 0F    call $0FFD		; reproduce un sonido
3364: C9          ret

; coloca abadía7 en 0x4000 y graba a en la altura de la habitación del espejo
3365: 01 C6 7F    ld   bc,$7FC6
3368: ED 49       out  (c),c
336A: 2A D9 34    ld   hl,($34D9)
336D: 77          ld   (hl),a
336E: C9          ret

; graba a en el bloque que forma el espejo en la habitación el espejo
336F: 2A E0 34    ld   hl,($34E0)		; recupera la dirección del bloque que forma el espejo
3372: 01 C7 7F    ld   bc,$7FC7
3375: ED 49       out  (c),c			; pone abadia8
3377: 77          ld   (hl),a
3378: 01 C0 7F    ld   bc,$7FC0			; restaura la configuración típica
337B: ED 49       out  (c),c
337D: C9          ret

; ccomprueba si se ha terminado el buffer de pulsaciones. Si es así, sale con CF = 0. Si no se ha terminado, carga abadia6.bin en 0x4000
; pone en iy la dirección del buffer de pulsaciones y sale con CF = 1
337E: 2A D1 33    ld   hl,($33D1)		; obtiene el puntero al buffer de pulsaciones de la demo
3381: E5          push hl
3382: 11 F0 6F    ld   de,$6FF0
3385: A7          and  a
3386: ED 52       sbc  hl,de			; comprueba si el puntero llegó al límite
3388: E1          pop  hl
3389: D0          ret  nc				; si hl >= de, sale
338A: 01 C5 7F    ld   bc,$7FC5			; pone abadia6.bin en 0x4000 y pone el flag de acarreo
338D: ED 49       out  (c),c
338F: E5          push hl
3390: FD E1       pop  iy				; iy = dirección actual del buffer de pulsaciones
3392: 37          scf					; pone el flag de acarreo
3393: C9          ret

; recupera del buffer de pulsaciones el estado de 8 teclas y actualiza el buffer donde se guardan las teclas pulsadas
3394: FD 4E 00    ld   c,(iy+$00)	; lee el byte actual
3397: FD 23       inc  iy
3399: 06 08       ld   b,$08		; repite para 8 teclas
339B: C5          push bc
339C: DD 7E 00    ld   a,(ix+$00)	; lee la tecla actual
339F: DD 23       inc  ix
33A1: 11 E7 33    ld   de,$33E7		; buffer donde se colocan las pulsaciones de las teclas para luego leerlas en vez de las pulsaciones de teclado
33A4: CD 8D 34    call $348D		; comprueba si se pulsó la tecla leida en iy+0
33A7: 7E          ld   a,(hl)
33A8: 2F          cpl
33A9: 4F          ld   c,a
33AA: 1A          ld   a,(de)
33AB: A1          and  c
33AC: C1          pop  bc
33AD: CB 11       rl   c			; obtiene el bit actual de la tecla que se ha comprobado
33AF: 30 01       jr   nc,$33B2
33B1: B6          or   (hl)
33B2: 12          ld   (de),a		; actualiza el buffer dependiendo de si se pulsó o no la tecla
33B3: 10 E6       djnz $339B
33B5: C9          ret

; graba en el buffer de pulsaciones el estado de las teclas que se indican en ix
33B6: C5          push bc
33B7: DD 7E 00    ld   a,(ix+$00)	; lee una tecla
33BA: DD 23       inc  ix
33BC: 11 D3 33    ld   de,$33D3		; de guarda apunta a la tabla con la última pulsación del teclado para cada línea
33BF: CD 8D 34    call $348D		; comprueba si se pulsó la tecla a usando el buffer de teclado que se le pasa en de
33C2: 1A          ld   a,(de)		; lee la tecla y comprueba si se pulsó
33C3: A6          and  (hl)
33C4: C6 FF       add  a,$FF		; si no se pulsó, a = 0, por lo que al sumar 0xff no habrá acarreo
33C6: C1          pop  bc
33C7: CB 11       rl   c			; mete si se pulsó o no en c
33C9: 10 EB       djnz $33B6		; repite para el resto de teclas
33CB: FD 71 00    ld   (iy+$00),c	; graba en el buffer de pulsaciones el estado de las teclas que se han comprobado
33CE: FD 23       inc  iy
33D0: C9          ret

33D1-33D2: puntero de las pulsaciones de la demo
33D3-33DC: ultima pulsación del teclado para cada linea
33DD-33E6: cambios de pulsación del teclado para cada linea
33E7-33F0: buffer para almacenar las teclas de la demo

; comprueba si pulsa Q y R en alguna de las escaleras del espejo
; e indica si se ha pulsado QR en alguna escalera y en que escalera se pulsa
33F1: 1E 00       ld   e,$00		; inicialmente e vale 0
33F3: DD 21 36 30 ld   ix,$3036		; apunta a los datos de posición de guillermo
33F7: DD 7E 02    ld   a,(ix+$02)	; lee la posición x
33FA: FE 22       cp   $22
33FC: C0          ret  nz			; si no está en el lugar apropiado, sale
33FD: DD 7E 04    ld   a,(ix+$04)	; si no está a la altura apropiada, sale
3400: FE 1A       cp   $1A
3402: C0          ret  nz
3403: 3E 43       ld   a,$43
3405: CD 82 34    call $3482		; si no se ha pulsado la tecla Q, sale
3408: C8          ret  z
3409: 3E 32       ld   a,$32		; si no se ha pulsado la tecla R, sale
340B: CD 82 34    call $3482		; comprueba si se ha pulsado la tecla con el código a
340E: C8          ret  z
340F: DD 7E 03    ld   a,(ix+$03)	; lee la posición y de guillermo y modifica e según sea esta posición
3412: 1C          inc  e
3413: FE 6D       cp   $6D			; si está en la escalera de la izquierda, sale con e = 1
3415: C8          ret  z
3416: 1C          inc  e
3417: FE 69       cp   $69			; si está en la escalera del centro, sale con e = 2
3419: C8          ret  z
341A: 1C          inc  e
341B: FE 65       cp   $65			; si está en la escalera de la derecha, sale con e = 3
341D: C8          ret  z
341E: 1E 00       ld   e,$00		; si se pulsó QR pero no estaba en alguna escalera, lo ignora
3420: C9          ret

3421: tecla leida
3422: FF
3423-3426: 08 25 4A FF teclas que mueven a la izquierda (cursor izquierda, K, joystick izquierda)
3427-342A: 2F 2F 49 FF teclas de acción (espacio, botón del joystick)
342B-342E: 00 45 48 FF teclas que mueven hacia arriba (cursor arriba, A, joystick arriba)
342F-3432: 01 24 4B FF teclas que mueven a la derecha (cursor derecha, L, joystick derecha)
3433-3436: 02 47 4D FF teclas que mueven hacia abajo (cursor abajo, Z, joystick abajo)

; comprueba si se ha pulsado la tecla que se le pasa como parámetro (o una que haga la misma función). Si es así, no devuelve cero
3437: ED 53 5F 34 ld   ($345F),de	; modifica una instrucción con los datos del buffer
343B: 21 21 34    ld   hl,$3421		; guarda la tecla a comprobar
343E: 77          ld   (hl),a
343F: 23          inc  hl
3440: 23          inc  hl
3441: FE 08       cp   $08			; si es el cursor izquierdo salta
3443: 28 16       jr   z,$345B
3445: 21 27 34    ld   hl,$3427		; si es el espacio salta
3448: FE 2F       cp   $2F
344A: 28 0F       jr   z,$345B
344C: 21 21 34    ld   hl,$3421
344F: FE 03       cp   $03			; si no es alguno de los cursores, salta
3451: 30 08       jr   nc,$345B

3453: 21 2B 34    ld   hl,$342B
3456: 87          add  a,a			; a = tecla*4
3457: 87          add  a,a
3458: CD 2D 16    call $162D		; hl = hl + a

345B: 7E          ld   a,(hl)		; lee lo que había en esa posición
345C: 23          inc  hl
345D: E5          push hl
345E: 11 00 00    ld   de,$0000		; de = buffer destino (el buffer se llena fuera)
3461: CD 8D 34    call $348D		; comprueba si se pulsó la tecla que había en esa posición
3464: E3          ex   (sp),hl		; graba la máscara seleccionada en pila
3465: 20 09       jr   nz,$3470		; si la tecla se pulsó, sale con a != 0
3467: 7E          ld   a,(hl)		; continúa probando teclas alternativas para esa función
3468: FE FF       cp   $FF			; (esta instrucción se cambia desde fuera)
346A: 30 03       jr   nc,$346F		; si ya ha probado todas, sale con a = 0
346C: D1          pop  de
346D: 18 EC       jr   $345B

346F: AF          xor  a
3470: E1          pop  hl
3471: C9          ret

; comprueba si ha habido un cambio en el estado de la tecla con el código a. Si se ha pulsado, no devuelve 0
3472: E5          push hl
3473: D5          push de
3474: 11 DD 33    ld   de,$33DD		; de = cambios de pulsación del teclado para cada linea
3477: CD 37 34    call $3437		; comprueba si ha cambiado el estado de la tecla que se le pasa como parámetro
347A: F5          push af
347B: 1A          ld   a,(de)
347C: B6          or   (hl)
347D: 12          ld   (de),a
347E: F1          pop  af
347F: D1          pop  de
3480: E1          pop  hl
3481: C9          ret

; comprueba si se ha pulsado la tecla con el código a. Si se ha pulsado, no devuelve 0
3482: E5          push hl
3483: D5          push de
3484: 11 D3 33    ld   de,$33D3	; apunta a la tabla con la última pulsación de las teclas
3487: CD 37 34    call $3437	; comprueba si se ha pulsado la tecla con el código a
348A: D1          pop  de
348B: E1          pop  hl
348C: C9          ret

; comprueba si se pulsó una tecla a usando el buffer de teclado que se le pasa en de
348D: 4F          ld   c,a		; c = lo que había en esa posición
348E: CB 3F       srl  a		; c = c/8
3490: CB 3F       srl  a
3492: CB 3F       srl  a
3494: 83          add  a,e		; de = de + c/8 (halla el desplazamiento de la tecla a buscar en el buffer de teclas pulsadas)
3495: 5F          ld   e,a
3496: 8A          adc  a,d
3497: 93          sub  e
3498: 57          ld   d,a
3499: 79          ld   a,c
349A: E6 07       and  $07		; obtiene el bit de la línea
349C: 21 A8 34    ld   hl,$34A8	; apunta a las máscaras de los bits
349F: 85          add  a,l		; indexa en la tabla
34A0: 6F          ld   l,a
34A1: 8C          adc  a,h
34A2: 95          sub  l
34A3: 67          ld   h,a
34A4: 1A          ld   a,(de)	; lee la posición de las teclas pulsadas
34A5: 2F          cpl
34A6: A6          and  (hl)		; comprueba si pulsó la tecla en cuestión
34A7: C9          ret

; máscaras para cada bit
34A8: 01 02 04 08 10 20 40 80


; rutina llamada en la inicialización
34B0: 3E 01       ld   a,$01
34B2: 32 8C 2D    ld   ($2D8C),a	; inicialmente la habitación secreta detrás del espejo no está abierta
34B5: AF          xor  a
34B6: 32 BC 2D    ld   ($2DBC),a	; indica que el número romano de la habitación del espejo no se ha generado todavía

34B9: F3          di
34BA: 01 C6 7F    ld   bc,$7FC6		; carga abadia7.bin
34BD: ED 49       out  (c),c
34BF: 21 DB 34    ld   hl,$34DB		; apunta a los datos de altura para la habitación del espejo si el espejo está cerrado
34C2: ED 5B D9 34 ld   de,($34D9)	; obtiene el puntero en donde copiar los datos de la altura
34C6: 01 05 00    ld   bc,$0005
34C9: ED B0       ldir				; copia los bytes a abadia7.bin

34CB: 3E 11       ld   a,$11
34CD: CD 6F 33    call $336F		; modifica la habitación del espejo para que el espejo aparezca cerrado
34D0: 2B          dec  hl
34D1: 2B          dec  hl			; apunta al principio de la entrada
34D2: 3E 1F       ld   a,$1F
34D4: CD 72 33    call $3372		; modifica la habitación del espejo para que la trampa esté cerrada
34D7: FB          ei				; activa las interrupciones
34D8: C9          ret

34D9-34DA: guarda la dirección de los datos de altura del espejo de abadia7.bin

; datos de altura si el espejo está cerrado
34DB: F5 20 62 0B FF

34E0-34E1: desplazamiento al bloque que forma el espejo en la pantalla del espejo de abadia8.bin

; este método se llama cuando cambia la orientación del sprite de adso y se encarga de flipear los sprites de adso
34E2: 3A 4B 30    ld   a,($304B)		; cambia el estado del bit 1
34E5: EE 01       xor  $01
34E7: 32 4B 30    ld   ($304B),a
34EA: 21 EA A6    ld   hl,$A6EA			; apunta a los sprite de adso de 5 bytes de ancho
34ED: 01 05 5F    ld   bc,$5F05
34F0: CD 52 35    call $3552			; los flipea
34F3: 21 C5 A8    ld   hl,$A8C5			; apunta a los sprite de adso de 4 bytes de ancho
34F6: 01 04 5A    ld   bc,$5A04
34F9: 18 57       jr   $3552			; los flipea

; este método se llama cuando cambia la orientación del sprite de malaquías y se encarga de flipear las caras del sprite
34FB: 3A 5A 30    ld   a,($305A)		; cambia el estado del bit 1
34FE: EE 01       xor  $01
3500: 32 5A 30    ld   ($305A),a
3503: 2A 97 30    ld   hl,($3097)		; hl apunta a los datos de las caras de malaquías
3506: 01 05 14    ld   bc,$1405
3509: 18 47       jr   $3552			; flipea las caras de malaquías

; este método se llama cuando cambia la orientación del sprite del abad y se encarga de flipear las caras del sprite
350B: 3A 69 30    ld   a,($3069)
350E: EE 01       xor  $01
3510: 32 69 30    ld   ($3069),a		; cambia el estado del bit 1
3513: 2A 99 30    ld   hl,($3099)		; hl apunta a los datos de las caras del abad
3516: 01 05 14    ld   bc,$1405
3519: 18 37       jr   $3552			; flipea las caras del abad

; este método se llama cuando cambia la orientación del sprite de berengario y se encarga de flipear las caras del sprite
351B: 3A 78 30    ld   a,($3078)		; cambia el estado del bit 1
351E: EE 01       xor  $01
3520: 32 78 30    ld   ($3078),a
3523: 2A 9B 30    ld   hl,($309B)		; hl apunta a los datos de las caras de berengario
3526: 01 05 14    ld   bc,$1405
3529: 18 27       jr   $3552			; flipea las caras de berengario

; este método se llama cuando cambia la orientación del sprite de severino <y se encarga de flipear las caras del sprite
352B: 3A 87 30    ld   a,($3087)		; cambia el estado del bit 1
352E: EE 01       xor  $01
3530: 32 87 30    ld   ($3087),a
3533: 2A 9D 30    ld   hl,($309D)		; hl apunta a los datos de las caras de severino
3536: 01 05 14    ld   bc,$1405
3539: 18 17       jr   $3552			; flipea las caras de severino


; este método se llama cuando cambia la orientación del sprite de guillermo y se encarga de flipear los sprites de guillermo
353B: 3A 3C 30    ld   a,($303C)	; cambia el estado del bit 1
353E: EE 01       xor  $01
3540: 32 3C 30    ld   ($303C),a
3543: 21 00 A3    ld   hl,$A300		; hl apunta a los gráficos de guillermo de 5 bytes de ancho
3546: 01 05 AE    ld   bc,$AE05		; bc -> indica 5 bytes de ancho y 0x366 bytes (0xae*5)
3549: CD 52 35    call $3552		; flipea respecto a xy los gráficos de guillermo de 5 bytes de ancho
354C: 21 66 A6    ld   hl,$A666		; hl apunta a los gráficos de guillermo de 4 bytes de ancho
354F: 01 04 21    ld   bc,$2104		; bc -> indica 4 bytes de ancho y 0x84 bytes (0x21*4)

; gira con respecto a x una serie de datos gráficos que se le pasan en hl (el ancho de los gráficos se pasa en c y en b un número
;  para calcular cuantos gráficos girar)
3552: C5          push bc			; guarda el parámetro original
3553: 5D          ld   e,l			; de = dirección de los gráficos de origen
3554: 54          ld   d,h
3555: 06 00       ld   b,$00
3557: ED 43 7B 35 ld   ($357B),bc	; se guarda el ancho del objeto en la rutina

355B: 0D          dec  c
355C: 09          add  hl,bc		; hl = apunta al último byte de un grupo de pixels del objeto (dependiente de su ancho)
355D: 06 A1       ld   b,$A1		; en bc se apuntará a la tabla auxiliar para flipx
355F: D9          exx				; intercambia los registros
3560: C1          pop  bc			; recupera el parámetro original
3561: 0C          inc  c
3562: CB 39       srl  c
3564: 69          ld   l,c			; guarda en l el número de intercambios por bloque para que se haya girado completamente el bloque
3565: D9          exx				; intercambia los registros
3566: D5          push de			; guarda la dirección original del objeto
3567: D9          exx

3568: D9          exx
3569: 4E          ld   c,(hl)		; coge el byte a intercambiar
356A: 0A          ld   a,(bc)		; le da la vuelta a los 4 pixels usando la tabla de flipx y lo guarda en a' para después
356B: 08          ex   af,af'
356C: 1A          ld   a,(de)		; coge el otro byte a intercambiar
356D: 4F          ld   c,a
356E: 0A          ld   a,(bc)		; le da la vuelta a los 4 pixels usando la tabla de flipx
356F: 77          ld   (hl),a		; intercambia los valores obtenidos a partir de los bytes leidos
3570: 08          ex   af,af'
3571: 12          ld   (de),a
3572: 2B          dec  hl			; lo prueba para el siguiente byte
3573: 13          inc  de
3574: D9          exx
3575: 2D          dec  l
3576: 20 F0       jr   nz,$3568		; repite hasta que se haya copiado la línea entera

; cuando llega aquí, el bloque que ha procesado está girado perfectamente
3578: D9          exx
3579: E1          pop  hl			; recupera la dirección inicial del objeto

357A: 11 00 00    ld   de,$0000		; este parámetro se llena arriba con el ancho
357D: 19          add  hl,de		; pasa al siguiente bloque
357E: EB          ex   de,hl
357F: 2D          dec  l
3580: 19          add  hl,de		; con hl apunta al último byte de un grupos de pixeles del objeto (dependiente de su ancho)
3581: D9          exx
3582: 10 E0       djnz $3564		; repite hasta terminar
3584: C9          ret

; abre las puertas del ala izquierda de la abadía
3585: 21 02 E0    ld   hl,$E002
3588: 22 FD 2F    ld   ($2FFD),hl
358B: 26 C0       ld   h,$C0
358D: 22 02 30    ld   ($3002),hl
3590: C9          ret

; calcula en hl la posición en la que grabar/cargar los datos, en de apunta a los datos actuales y en bc se indica la longitud de los datos
3591: 25          dec  h
3592: CB F4       set  6,h			; ajusta los bancos a 0x4000-0x49ff
3594: 2E 00       ld   l,$00
3596: 11 00 A2    ld   de,$A200
3599: 01 FF 00    ld   bc,$00FF
359C: C9          ret

; ----------------------------- código relacionado con pausa/cargar/grabar partidas ------------------------------------

; comprueba si se pulsó supr (pausa), o ctrl+f? (grabar partida o grabar demo) o shift+f? (cargar partida o cargar demo) y actúa en consecuencia
359D: 3E 4F       ld   a,$4F		; tecla de suprimir
359F: CD 72 34    call $3472		; comprueba si ha cambiado el estado de suprimir?
35A2: 28 26       jr   z,$35CA		; si no, salta

; aquí llega si se pulsó supr (supr es la pausa)
35A4: F3          di
35A5: 3E 3F       ld   a,$3F
35A7: 32 97 0F    ld   ($0F97),a	; modifica la copia de la máscara con el estado de los canales, para que haya que volver a activarlos
35AA: 4F          ld   c,a
35AB: 3E 07       ld   a,$07
35AD: CD 4E 13    call $134E		; desactiva los 3 canales del sonido
35B0: 21 BC 32    ld   hl,$32BC
35B3: 22 12 33    ld   ($3312),hl	; se asegura que la rutina de la QR lea de teclado
35B6: AF          xor  a
35B7: 32 09 33    ld   ($3309),a	; se asegura de que se obtengan los datos del teclado
35BA: 3D          dec  a
35BB: 32 69 34    ld   ($3469),a	; se asegura de que la rutina de leer de teclado funcione bien para el teclado
35BE: CD BC 32    call $32BC		; lee el estado de las teclas y lo guarda en los buffers de teclado
35C1: 3E 4F       ld   a,$4F
35C3: CD 72 34    call $3472
35C6: 28 F6       jr   z,$35BE		; espera a que se vuelva a pulsar suprimir
35C8: FB          ei
35C9: C9          ret

; aquí llega si no se pulsó supr
35CA: 3E 17       ld   a,$17
35CC: CD 82 34    call $3482		; comprueba si se ha pulsado control
35CF: C4 F2 36    call nz,$36F2		; si se ha pulsado, comprueba si se ha pulsado alguna tecla de función
35D2: 28 4A       jr   z,$361E		; si no se ha pulsado control+tecla de función, salta

; aquí llega si se ha pulsado control+tecla de función
35D4: F3          di
35D5: C5          push bc
35D6: 78          ld   a,b
35D7: FE 01       cp   $01
35D9: 20 1A       jr   nz,$35F5		; si no se ha pulsado ctrl+f9, salta

; código específico si se pulsó ctrl+f9
35DB: 21 FF 31    ld   hl,$31FF
35DE: 22 12 33    ld   ($3312),hl	; hace que en la rutina de la QR se graben las pulsaciones del teclado en el buffer de pulsaciones
35E1: CD 7E 33    call $337E		; comprueba si se ha terminado el buffer de pulsaciones y carga abadia6.bin en 0x4000
35E4: 21 00 40    ld   hl,$4000
35E7: AF          xor  a			; inicia el primer estado de las teclas a 0
35E8: 77          ld   (hl),a
35E9: 23          inc  hl
35EA: 77          ld   (hl),a
35EB: 23          inc  hl
35EC: 77          ld   (hl),a
35ED: 23          inc  hl
35EE: 77          ld   (hl),a
35EF: 23          inc  hl
35F0: 22 D1 33    ld   ($33D1),hl	; guarda el puntero al buffer de pulsaciones
35F3: 06 01       ld   b,$01

35F5: CD 04 37    call $3704	; calcula la posición para grabar los datos 1
35F8: EB          ex   de,hl
35F9: ED B0       ldir			; copia los datos al destino
35FB: E1          pop  hl
35FC: E5          push hl
35FD: D5          push de
35FE: CD 91 35    call $3591	; calcula la posición para grabar los datos 2
3601: EB          ex   de,hl
3602: ED B0       ldir			; copia los datos al destino
3604: D1          pop  de
3605: 21 85 3C    ld   hl,$3C85
3608: 01 C8 00    ld   bc,$00C8
360B: CD 16 36    call $3616	; copia los datos 3 al destino y restaura la configuración 0
360E: C1          pop  bc
360F: 78          ld   a,b
3610: FE 01       cp   $01
3612: 28 39       jr   z,$364D	; si se pulsó control+f9, salta
3614: FB          ei
3615: C9          ret

; copia los datos y restaura la configuración
3616: ED B0       ldir
3618: 01 C0 7F    ld   bc,$7FC0
361B: ED 49       out  (c),c
361D: C9          ret

; aquí llega si no se ha pulsado control y una tecla de función
361E: 00          nop				; estas 2 instrucciones se modifican desde fuera (pero solo se pone nop???)
361F: 00          nop
3620: 3E 15       ld   a,$15
3622: CD 82 34    call $3482		; comprueba si se ha pulsado shift
3625: C4 F2 36    call nz,$36F2		; si se ha pulsado, comprueba si se ha pulsado alguna tecla de función
3628: C8          ret  z			; si no, sale

; aquí también llega si se terminaron las teclas almacenadas en el buffer de pulsaciones
3629: 78          ld   a,b
362A: F3          di
362B: FE 01       cp   $01
362D: 20 1E       jr   nz,$364D		; si no se pulsó shift+f9 salta

; aquí llega si se pulsó shift+f9
362F: 21 00 00    ld   hl,$0000
3632: 22 1E 36    ld   ($361E),hl	; pone 2 nop al llegar al apartado de carga de estados
3635: 21 7C 32    ld   hl,$327C
3638: 22 12 33    ld   ($3312),hl	; se asegura que en la rutina de la QR se lean las pulsaciones del buffer de pulsaciones
363B: 21 00 40    ld   hl,$4000		; inicia la posición del buffer de las teclas de la demo
363E: 22 D1 33    ld   ($33D1),hl
3641: 3E 01       ld   a,$01
3643: 32 72 2D    ld   ($2D72),a	; indica que el primer bloque de pulsaciones se usa sólo una vez
3646: 3E 48       ld   a,$48
3648: 32 69 34    ld   ($3469),a	; se asegura de que la rutina de leer de teclado funcione bien para la demo
364B: 06 01       ld   b,$01

; aqui también llega si se pulsó control+f9
364D: 3A 3C 30    ld   a,($303C)	; lee si los gráficos de adso y guillermo están rotados
3650: 6F          ld   l,a
3651: 3A 4B 30    ld   a,($304B)
3654: 67          ld   h,a
3655: E5          push hl
3656: C5          push bc
3657: CD C4 36    call $36C4		; rota los gráficos de los monjes si fuera necesario
365A: C1          pop  bc
365B: C5          push bc
365C: CD 04 37    call $3704		; calcula en hl la posición en la que grabar datos
365F: 01 20 03    ld   bc,$0320		; no guarda todos los datos (solo hasta 0x309e)
3662: E5          push hl
3663: ED B0       ldir				; graba los datos
3665: E1          pop  hl
3666: E3          ex   (sp),hl
3667: CD 91 35    call $3591		; calcula en hl la posición en la que grabar los datos y los graba
366A: ED B0       ldir
366C: 2A D9 34    ld   hl,($34D9)	; modifica los datos de altura de la habitación del espejo
366F: 36 F5       ld   (hl),$F5
3671: E1          pop  hl
3672: 01 38 03    ld   bc,$0338
3675: 09          add  hl,bc		; apunta a los siguientes datos
3676: 11 85 3C    ld   de,$3C85
3679: 01 98 00    ld   bc,$0098
367C: CD 16 36    call $3616		; copia los datos y restaura la configuración
367F: E1          pop  hl
3680: DD 21 3C 30 ld   ix,$303C		; apunta a la rotación de los gráficos
3684: DD 75 00    ld   (ix+$00),l	; restaura la rotación de guillermo y de adso
3687: DD 74 0F    ld   (ix+$0f),h
368A: AF          xor  a
368B: DD 77 1E    ld   (ix+$1e),a	; fija la rotación de los monjes
368E: DD 77 2D    ld   (ix+$2d),a
3691: DD 77 3C    ld   (ix+$3c),a
3694: DD 77 4B    ld   (ix+$4b),a
3697: CD 1A 37    call $371A
369A: AF          xor  a
369B: 32 6E 41    ld   ($416E),a
369E: 3A BC 2D    ld   a,($2DBC)	; obtiene el número romano de la habitación del espejo
36A1: A7          and  a
36A2: C4 43 56    call nz,$5643		; si se había generado, copia a la cadena del pergamino los números romanos de la habitación del espejo
36A5: E1          pop  hl
36A6: FB          ei
36A7: 76          halt
36A8: F3          di
36A9: C3 8F 25    jp   $258F		; salta al bucle principal

; tabla de teclas a comprobar al tener control pulsado: (F0, F1, F2, F3, F4, F5, F6, F7, F8, F9)
36AC: 0F 0D 0E 05 14 0C 04 0A 0B 03

; código de las teclas cursor arriba, izquierda, abado, derecha, espacio, shift, q, r, n, s
36B6: 00 01 02 08 2F 15 43 32 2E 3C

; código de las teclas 'y', '.'
36C0: 2B 07 07 07

; si hay que girar el gráfico de algún monje, lo hace
36C4: FD E5       push iy
36C6: FD 21 54 30 ld   iy,$3054		; apunta a las caracteristicas de malaquias
36CA: 21 97 30    ld   hl,$3097		; apunta a la tabla con las caras de los monjes
36CD: 06 04       ld   b,$04		; repite 4 veces (para malaquias, el abad, berengario y severino)
36CF: C5          push bc
36D0: 5E          ld   e,(hl)		; lee una dirección y la guarda en de
36D1: 23          inc  hl
36D2: 56          ld   d,(hl)
36D3: 23          inc  hl
36D4: E5          push hl
36D5: FD 7E 06    ld   a,(iy+$06)	; lee si hay que girar el monje
36D8: A7          and  a
36D9: 28 0B       jr   z,$36E6
36DB: FD 36 06 00 ld   (iy+$06),$00
36DF: EB          ex   de,hl
36E0: 01 05 14    ld   bc,$1405		; ancho = 5, numero = 20
36E3: CD 52 35    call $3552		; gira en xy una serie de datos gráficos que se le pasan en hl
36E6: E1          pop  hl
36E7: 01 0F 00    ld   bc,$000F		; avanza a la siguiente entrada
36EA: FD 09       add  iy,bc
36EC: C1          pop  bc
36ED: 10 E0       djnz $36CF		; repite con los monjes que queden
36EF: FD E1       pop  iy
36F1: C9          ret

; llamado si no ha cambiado el estado de suprimir y se ha pulsado control, para comprobar si se ha pulsado alguna de las teclas de función
36F2: 06 0A       ld   b,$0A		; 10 teclas
36F4: 21 AC 36    ld   hl,$36AC		; apunta a la tabla de teclas de función
36F7: 7E          ld   a,(hl)		; lee una tecla
36F8: 23          inc  hl
36F9: E5          push hl
36FA: C5          push bc
36FB: CD 72 34    call $3472		; comprueba si ha habido un cambio de estado en esa tecla
36FE: C1          pop  bc
36FF: E1          pop  hl
3700: C0          ret  nz			; si es así, sale
3701: 10 F4       djnz $36F7		; prueba para el resto de teclas
3703: C9          ret

; calcula en hl la posición en la que grabar/cargar los datos, en de apunta a los datos actuales y en bc se indica la longitud de los datos
3704: 11 00 04    ld   de,$0400
3707: 21 00 54    ld   hl,$5400		; hl = 0x5400 + b*0x400 (por lo que los bancos se almacenan en 0x5800-0x7fff)
370A: 19          add  hl,de
370B: 10 FD       djnz $370A
370D: F3          di
370E: 01 C6 7F    ld   bc,$7FC6		; carga abadia7
3711: ED 49       out  (c),c
3713: 11 7F 2D    ld   de,$2D7F		; origen de los datos a copiar
3716: 01 38 03    ld   bc,$0338		; cantidad de datos a copiar
3719: C9          ret

371A: 3A 30 30    ld   a,($3030)	; obtiene las características de la lámpara
371D: E6 80       and  $80
371F: 28 06       jr   z,$3727		; si la lámpara no está cogida, salta
3721: 21 F3 2D    ld   hl,$2DF3		; indica que adso tiene la lámpara
3724: 22 32 30    ld   ($3032),hl

3727: 0E 80       ld   c,$80		; empieza con el bit 7
3729: 06 08       ld   b,$08		; 8 objetos
372B: DD 21 08 30 ld   ix,$3008		; apunta a los datos de posición de los objetos
372F: C5          push bc
3730: DD 7E 00    ld   a,(ix+$00)
3733: E6 80       and  $80
3735: 28 18       jr   z,$374F		; si el objeto no está cogido, salta
3737: 21 EF 2D    ld   hl,$2DEF		; apunta a los objetos que tiene los personajes
373A: 06 05       ld   b,$05
373C: 7E          ld   a,(hl)
373D: A1          and  c
373E: 20 06       jr   nz,$3746		; si el personaje tiene el objeto, salta
3740: 11 07 00    ld   de,$0007
3743: 19          add  hl,de		; pasa a la siguiente entrada
3744: 10 F6       djnz $373C
3746: 2B          dec  hl
3747: 2B          dec  hl
3748: 2B          dec  hl
3749: DD 75 02    ld   (ix+$02),l	; indica que el personaje tiene el objeto
374C: DD 74 03    ld   (ix+$03),h
374F: 11 05 00    ld   de,$0005		; pasa al siguiente objeto
3752: DD 19       add  ix,de
3754: C1          pop  bc
3755: CB 39       srl  c			; prueba el siguiente bit
3757: 10 D6       djnz $372F		; repite hasta terminar los objetos

3759: 21 83 37    ld   hl,$3783		; apunta a la tabla de datos de posición de los personajes
375C: DD 21 D9 2D ld   ix,$2DD9		; apunta a los permisos de las puertas
3760: FD 21 EC 2D ld   iy,$2DEC		; apunta a los objetos de los personajes
3764: 06 06       ld   b,$06		; 6 personajes
3766: 7E          ld   a,(hl)
3767: DD 77 01    ld   (ix+$01),a	; fija la dirección del personaje para las puertas y los objetos
376A: FD 77 01    ld   (iy+$01),a
376D: 23          inc  hl
376E: 7E          ld   a,(hl)
376F: DD 77 02    ld   (ix+$02),a
3772: FD 77 02    ld   (iy+$02),a
3775: 23          inc  hl
3776: 11 03 00    ld   de,$0003
3779: DD 19       add  ix,de
377B: 11 07 00    ld   de,$0007
377E: FD 19       add  iy,de
3780: 10 E4       djnz $3766		; repite hasta terminar los personajes
3782: C9          ret

3783: 	3038
		3047
		3056
		3065
		3074
		3083

; ------------------------- fin del código relacionado con pausa/cargar/grabar partidas -----------------------------------

; esto no se usa nunca???
378F: 00          nop
3790: 10 F0       djnz $3782
3792: 00          nop
3793: F0          ret  p
3794: F0          ret  p
3795: F0          ret  p
3796: 10 00       djnz $3798
3798: 00          nop
3799: 00          nop
379A: F0          ret  p
379B: 00          nop
379C: 10 10       djnz $37AE
379E: 00          nop
379F: 10 F0       djnz $3791
37A1: 10 00       djnz $37A3
37A3: 00          nop
37A4: C9          ret

; dada en ix una dirección del buffer de tiles, devuelve en hl la dirección relativa a 0x9500
;  si el carry está puesto, no es una dirección válida del buffer de tiles. En otro caso sí
37A5: DD E5       push ix
37A7: E1          pop  hl			; hl = ix (hl = una posición dentro del buffer de tiles)
37A8: 11 80 8D    ld   de,$8D80		; de = inicio del buffer de tiles
37AB: A7          and  a
37AC: ED 52       sbc  hl,de		; hl =  hl - de
37AE: D8          ret  c			; si hl < de, sale con cf = 1
37AF: 11 80 07    ld   de,$0780
37B2: ED 52       sbc  hl,de		; hl = (hl - de) - 0x780
37B4: 3F          ccf				; complementa el flag de acarreo
37B5: C9          ret

; llamado al iniciar valores después de mostrar el pergamino, y sólo la primera vez que se carga el juego
37B6: 21 0E 38    ld   hl,$380E			; rutina de copia de archivos

; realiza una tarea con una serie de bloques de bytes
37B9: 22 D2 37    ld   ($37D2),hl		; escribe la rutina a llamar
37BC: DD 21 DC 37 ld   ix,$37DC			; apunta a la tabla de bloques
37C0: 21 03 01    ld   hl,$0103			; dirección de origen/destino del bloque
37C3: DD 5E 00    ld   e,(ix+$00)		; de = dirección de origen/destino
37C6: DD 56 01    ld   d,(ix+$01)
37C9: 7A          ld   a,d				; si se leyó 0 se termina
37CA: B3          or   e
37CB: C8          ret  z
37CC: DD 4E 02    ld   c,(ix+$02)		; bc = bytes del bloque
37CF: 06 00       ld   b,$00
37D1: CD 0E 38    call $380E			; llama a la rutina que procesa el bloque
37D4: DD 23       inc  ix				; apunta a la siguiente entrada
37D6: DD 23       inc  ix
37D8: DD 23       inc  ix
37DA: 18 E7       jr   $37C3			; repite hasta que se acabe

; tabla con los bloques y los bytes a hacer algo
; estados de los personajes
37DC: 3CA6 05
37DF: 3CC6 03
37E2: 3CE7 03
37E5: 3CFF 03
37E8: 3D11 03

37EB: 2D7F 0E	; obsequium,dia y momento del día, puntero a la próxima hora del día, tabla para la animación de los sprites
				;  personaje al que sigue la cámara, puntero al buffer de alturas, si se ha abierto el espejo
37EE: 2DD9 10	; información sobre las puertas que pueden abrir los personajes
37F1: 2DEC 23	; datos de los objetos que tienen de los personajes
37F4: 2FE4 20	; datos de las puertas del juego
37F7: 3008 23	; posición de los objetos

37FA: 3038 03	; posición de guillermo
37FD: 3047 03	; posición de adso
3800: 3056 03	; posición de malaquias
3803: 3065 03	; posición del abad
3806: 3074 03	; posición de berengario
3809: 3083 03	; posición de severino
380C: 0000

; copia bc bytes de de a hl
; bc = número de bytes a copiar
; hl = destino de los datos
; de = origen de los datos
380E: EB          ex   de,hl
380F: ED B0       ldir			; copia los bytes seleccionados
3811: EB          ex   de,hl
3812: C9          ret

; copia bc bytes de hl a de
3813: ED B0       ldir
3815: C9          ret

; limpia la zona de memoria de hl a hl + bc
3816: 36 00       ld   (hl),$00
3818: 5D          ld   e,l
3819: 54          ld   d,h
381A: 13          inc  de
381B: ED B0       ldir
381D: C9          ret

; inicia la memoria
381E: 21 85 3C    ld   hl,$3C85		; limpia 0x3c85-0x3ca4 (los datos de la lógica)
3821: 01 20 00    ld   bc,$0020
3824: CD 16 38    call $3816
3827: 21 8D 2D    ld   hl,$2D8D		; limpia 0x2d8d-0x2dd8 (variables auxiliares de algunas rutinas)
382A: 01 4B 00    ld   bc,$004B
382D: CD 16 38    call $3816
3830: 21 13 38    ld   hl,$3813		; rutina a llamar
3833: CD B9 37    call $37B9		; copia cosas de 0x0103-0x01a9 a muchos sitios (nota: al inicializar se hizo la operación inversa)

3836: 21 17 2E    ld   hl,$2E17		; apunta a la tabla con datos de los sprites
3839: 11 14 00    ld   de,$0014		; cada sprite ocupa 20 bytes
383C: 7E          ld   a,(hl)		; cuando encuentre una entrada con 0xff sale
383D: FE FF       cp   $FF
383F: 28 05       jr   z,$3846
3841: 36 FE       ld   (hl),$FE		; pone todos los sprites como no visibles
3843: 19          add  hl,de
3844: 18 F6       jr   $383C

3846: DD 21 36 30 ld   ix,$3036		; apunta a la tabla de características de los personajes
384A: 11 0F 00    ld   de,$000F		; cada entrada ocupa 15 bytes
384D: AF          xor  a
384E: 06 06       ld   b,$06		; 6 entradas
3850: DD 77 00    ld   (ix+$00),a	; pone a 0 el contador de la animación del personaje
3853: DD 77 01    ld   (ix+$01),a	; fija la orientación del personaje mirando a +x
3856: DD 77 05    ld   (ix+$05),a	; inicialmente el personaje ocupa 4 posiciones
3859: DD 77 09    ld   (ix+$09),a	; indica que no hay movimientos del personaje que procesar
385C: DD 36 0A FD ld   (ix+$0a),$FD	; acción que se está ejecutando actualmente
3860: DD 77 0B    ld   (ix+$0b),a	; inicia el índice en la tabla de comandos de movimiento
3863: DD 19       add  ix,de		; pasa al siguiente personaje
3865: 10 E9       djnz $3850
3867: C9          ret


; a esta rutina se llama para mostrar el final una vez que se ha completado el juego
3868: 2A 12 33    ld   hl,($3312)
386B: E5          push hl
386C: 21 BC 32    ld   hl,$32BC
386F: 22 12 33    ld   ($3312),hl	; se asegura que la rutina de la QR lea de teclado
3872: AF          xor  a
3873: 32 09 33    ld   ($3309),a
3876: 2A D1 33    ld   hl,($33D1)
3879: 2B          dec  hl
387A: 01 C5 7F    ld   bc,$7FC5		; fija configuracion 5 (0, 5, 2, 3) (carga abadia6.bin en 0x4000)
387D: ED 49       out  (c),c
387F: 7E          ld   a,(hl)
3880: C6 08       add  a,$08
3882: 77          ld   (hl),a
3883: 01 C0 7F    ld   bc,$7FC0		; restuara la configuración típica
3886: ED 49       out  (c),c
3888: E1          pop  hl
3889: 11 FF 31    ld   de,$31FF
388C: A7          and  a
388D: ED 52       sbc  hl,de
388F: CC 95 04    call z,$0495		; salta como si se hubiera pulsado ctrl+tab

3892: CD 3A 3F    call $3F3A		; coloca la paleta negra
3895: 01 C5 7F    ld   bc,$7FC5		; fija configuracion 5 (0, 5, 2, 3) (carga abadia6.bin en 0x4000)
3898: ED 49       out  (c),c
389A: 21 00 70    ld   hl,$7000		; apunta al código y los datos de la rutina del pergamino
389D: 11 00 C0    ld   de,$C000		; apunta al destino
38A0: D5          push de
38A1: 01 00 10    ld   bc,$1000		; 0x1000 bytes
38A4: C5          push bc
38A5: ED B0       ldir				; copia los datos a la pantalla
38A7: 01 C7 7F    ld   bc,$7FC7		; fija la configuración (0, 7, 2, 3) (carga abadia8.bin en 0x4000)
38AA: ED 49       out  (c),c
38AC: 11 00 80    ld   de,$8000		; apunta al destino
38AF: 21 28 6B    ld   hl,$6B28		; origen de los datos
38B2: 01 18 15    ld   bc,$1518		; longitud de los datos
38B5: ED B0       ldir				; copia la música y el texto del pergamino del final
38B7: 01 C0 7F    ld   bc,$7FC0		; restaura la configuración usual
38BA: ED 49       out  (c),c
38BC: 21 D8 8E    ld   hl,$8ED8		; apunta a los datos gráficos del pergamino
38BF: 11 8A 78    ld   de,$788A		; apunta a la dirección donde se espera que estén los datos gráficos del pergamino
38C2: 01 00 06    ld   bc,$0600
38C5: ED B0       ldir				; copia los datos gráficos del pergamino
38C7: 3E 08       ld   a,$08
38C9: 32 86 10    ld   ($1086),a	; cambia el tempo de la música
38CC: C1          pop  bc
38CD: E1          pop  hl
38CE: 11 9D 65    ld   de,$659D		; copia las rutinas del pergamino de la memoria de pantalla a donde estaban al inicio
38D1: ED B0       ldir

38D3: 21 00 80    ld   hl,$8000		; apunta a los datos de la música del pergamino final
38D6: CD 3F 10    call $103F		; incia la música del manuscrito del final
38D9: DD 21 30 83 ld   ix,$8330		; ix apunta al texto a mostrar
38DD: CD 9D 65    call $659D		; llama a la rutina para mostrar el manuscrito
38E0: 18 F1       jr   $38D3		; si se pulsa espacio, vuelve a mostrar el manuscrito del final

; tabla de símbolos de puntuación
38E2: 	C0 -> 0x00 (0xfa) -> ¿
		BF -> 0x01 (0xfb) -> ?
		BB -> 0x02 (0xfc) -> ;
		BD -> 0x03 (0xfd) -> .
		BC -> 0x04 (0xfe) -> ,

; dirección de los datos gráficos del caracter espacio en blanco
38E7: 00 00 00 00 00 00 00 00

; tabla de instrucciones para modificar un bucle del cálculo de alturas
38EF: 	00 00 -> 0 nop, nop (caso imposible)
		3C 00 -> 1 inc a, nop
		00 3D -> 2 nop, dec a
		3D 00 -> 3 dec a, nop
		00 3C -> 4 nop, inc a
		00 00 -> 5 nop, nop (caso imposible)

38CD: 00 4A

; rutina para rellenar alturas
38FD: F5          push af
38FE: 1A          ld   a,(de)		; modifica 2 instrucciones de la rutina
38FF: 32 11 39    ld   ($3911),a
3902: 13          inc  de
3903: 1A          ld   a,(de)
3904: 32 16 39    ld   ($3916),a
3907: F1          pop  af			; a = valor de la altura inicial del bloque
3908: C5          push bc
3909: E5          push hl
390A: F5          push af
390B: 41          ld   b,c			; b = número de unidades en X
390C: 4F          ld   c,a
390D: CD 1D 39    call $391D		; si la posición dada en hl está dentro del buffer, lo modifica con la altura de c
3910: 79          ld   a,c
3911: 3C          inc  a			; instrucción modificada desde fuera para cambiar la altura en el bucle de x
3912: 2C          inc  l
3913: 10 F7       djnz $390C
3915: F1          pop  af
3916: 3C          inc  a			; instrucción modificada desde fuera para cambiar la altura en el bucle de y
3917: E1          pop  hl
3918: 24          inc  h
3919: C1          pop  bc
391A: 10 EC       djnz $3908		; repite hasta completar las unidades en Y
391C: C9          ret

; si la posición dada en hl está dentro del buffer, lo modifica con la altura de c
391D: 7C          ld   a,h
391E: D6 00       sub  $00			; ajusta la coordenada al principio de lo visible en Y
3920: D8          ret  c
3921: FE 18       cp   $18			; si no es visible, sale
3923: D0          ret  nc
3924: E5          push hl
3925: 6F          ld   l,a
3926: 26 00       ld   h,$00
3928: 29          add  hl,hl
3929: 29          add  hl,hl
392A: 29          add  hl,hl
392B: 54          ld   d,h
392C: 5D          ld   e,l
392D: 29          add  hl,hl
392E: 19          add  hl,de
392F: ED 5B 8A 2D ld   de,($2D8A)
3933: 19          add  hl,de
3934: EB          ex   de,hl
3935: E1          pop  hl
3936: 7D          ld   a,l
3937: D6 00       sub  $00			; ajusta la coordenada al principio de lo visible en X
3939: D8          ret  c
393A: FE 18       cp   $18			; si no es visible, sale
393C: D0          ret  nc
393D: 83          add  a,e
393E: 5F          ld   e,a
393F: 8A          adc  a,d
3940: 93          sub  e
3941: 57          ld   d,a
3942: 79          ld   a,c
3943: 12          ld   (de),a
3944: C9          ret

; rellena el buffer de pantalla de 0x2d8a con los datos leidos de abadia7 y recortados para la pantalla actual
3945: DD E5       push ix
3947: DD 2A FB 38 ld   ix,($38FB)	; ix = dirección dependiente de la planta en la que está el personaje
394B: 3A A9 27    ld   a,($27A9)	; recupera la mínima coordenada x visible en pantalla
394E: 32 BA 39    ld   ($39BA),a	; modifica unas instrucciones según esto
3951: 32 38 39    ld   ($3938),a
3954: 32 F0 39    ld   ($39F0),a
3957: 3A 9D 27    ld   a,($279D)	; recupera la mínima coordenada y visible en pantalla
395A: 32 0B 3A    ld   ($3A0B),a	; modifica unas instrucciones según esto
395D: 32 CA 39    ld   ($39CA),a
3960: 32 1F 39    ld   ($391F),a
3963: 01 C6 7F    ld   bc,$7FC6		; carga abadia7
3966: ED 49       out  (c),c
3968: CD 73 39    call $3973		; rellena el buffer de pantalla de 0x2d8a con los datos leidos de abadia7.bin
396B: 01 C0 7F    ld   bc,$7FC0		; restaura la configuración usual
396E: ED 49       out  (c),c
3970: DD E1       pop  ix
3972: C9          ret

entradas:
	byte 0
		bits 7-4: valor inicial de altura
		bit 3: si es 0, entrada de 4 bytes. si es 1, entrada de 5 bytes
		bit 2-0: tipo de elemento de la pantalla
			si es 0, 6 o 7, sale
			si es del 1 al 4 recorta (altura cambiante)
			si es 5, recorta (altura constante)
	byte 1: coordenada X de inicio
	byte 2: coordenada Y de inicio
	byte 3:	si longitud == 4 bytes
		bits 7-4: número de unidades en X
		bits 3-0: número de unidades en Y
			si longitud == 5 bytes
		bits 7-0: número de unidades en X
	byte 4 número de unidades en Y

; ix apunta a los datos de abadia7.bin relacionados con la planta
3973: DD 7E 00    ld   a,(ix+$00)	; lee un byte
3976: FE FF       cp   $FF			; si ha llegado al final de los datos, sale
3978: C8          ret  z
3979: 57          ld   d,a
397A: E6 07       and  $07			; si los 3 bits menos significativos del byte leido son 0, sale
397C: C8          ret  z
397D: FE 06       cp   $06			; si el (dato & 0x07) >= 0x06, sale
397F: D0          ret  nc
3980: CB 5A       bit  3,d			; si la entrada es de 4 bytes, lee en a el último byte y salta
3982: DD 7E 03    ld   a,(ix+$03)
3985: 28 05       jr   z,$398C
3987: DD 46 04    ld   b,(ix+$04)	; en otro caso, lee en b el último byte y salta
398A: 18 0B       jr   $3997

398C: 4F          ld   c,a		; c = byte 3
398D: E6 0F       and  $0F
398F: 47          ld   b,a		; b = 4 bits menos significativos del byte 3
3990: 79          ld   a,c
3991: 0F          rrca
3992: 0F          rrca
3993: 0F          rrca
3994: 0F          rrca
3995: E6 0F       and  $0F		; a = 4 bits más significativos del byte 3

3997: 4F          ld   c,a		; c = valor 1
3998: 7A          ld   a,d		; a = byte 0
3999: 0F          rrca
399A: 0F          rrca
399B: 0F          rrca
399C: 0F          rrca
399D: E6 0F       and  $0F			; obtiene los 4 bits superiores del byte 0
399F: DD 6E 01    ld   l,(ix+$01)	; hl = dirección de los bytes 1 y 2
39A2: DD 66 02    ld   h,(ix+$02)
39A5: DD CB 00 5E bit  3,(ix+$00)
39A9: 28 02       jr   z,$39AD		; avanza la entrada 4 o 5 bytes
39AB: DD 23       inc  ix
39AD: DD 23       inc  ix
39AF: DD 23       inc  ix
39B1: DD 23       inc  ix
39B3: DD 23       inc  ix

; aquí llega con los parámetros:
; a = bits 7-4 del byte 0
; c = longitud del bloque en x
; b = longitud del bloque en y
; l = coordenada x inicial del bloque
; h = coordenada y inicial del bloque
; Si el bit 3 del byte 0 leido es 1, b y c serán números de 8 bits. En otro caso serán de 4 bits
39B5: 08          ex   af,af'		; guarda a
39B6: 04          inc  b
39B7: 0C          inc  c
39B8: 7D          ld   a,l			; coge la coordenada X inicial del bloque
39B9: D6 00       sub  $00			; ajusta la coordenada al principio de lo visible en X
39BB: 30 07       jr   nc,$39C4		; si la coordenada X >= limite inferior en X, salta
39BD: ED 44       neg				; a = diferencia entre el límite inferior en X y la coordenada X
39BF: B9          cp   c			; si la diferencia >= c, pasa a la siguiente entrada
39C0: 30 B1       jr   nc,$3973
39C2: 18 04       jr   $39C8		; en otro caso, comprueba si se ve en y

39C4: FE 18       cp   $18			; si la coordenada X >= limite superior en X, pasa a la siguiente entrada
39C6: 30 AB       jr   nc,$3973

; si llega aquí, es porque esta entrada es válida en x
39C8: 7C          ld   a,h			; coge la coordenada Y de inicio del bloque
39C9: D6 00       sub  $00			; ajusta la posición al principio de lo visible en Y
39CB: 30 07       jr   nc,$39D4		; si la coordenada Y > limite inferior en Y, salta
39CD: ED 44       neg				; a = diferencia entre el límite inferior en y y la coordenada Y
39CF: B8          cp   b			; si la diferencia >= b, pasa a la siguiente entrada
39D0: 30 A1       jr   nc,$3973
39D2: 18 04       jr   $39D8

39D4: FE 18       cp   $18			; si la coordenada Y >= limite superior en Y, pasa a la siguiente entrada
39D6: 30 9B       jr   nc,$3973

; si entra aquí, es porque algo de la entrada es visible
39D8: 7A          ld   a,d			; a = altura inicial del bloque
39D9: E6 07       and  $07			; se queda con los 3 bits inferiores
39DB: FE 05       cp   $05
39DD: 28 0F       jr   z,$39EE		; si es un 5, salta
39DF: 87          add  a,a
39E0: 11 EF 38    ld   de,$38EF		; en otro caso, indexa en la tabla de instrucciones para modificar un bucle del cálculo de alturas
39E3: 83          add  a,e			; de = de + a
39E4: 5F          ld   e,a
39E5: 8A          adc  a,d
39E6: 93          sub  e
39E7: 57          ld   d,a
39E8: 08          ex   af,af'		; recupera el valor del byte 0
39E9: CD FD 38    call $38FD
39EC: 18 85       jr   $3973

; recorta en X
39EE: 7D          ld   a,l			; coge la coordenada X actual de la entrada
39EF: D6 00       sub  $00			; ajusta la coordenada al principio de lo visible en X
39F1: 30 0C       jr   nc,$39FF		; si la coordenada X > limite inferior en X, salta
39F3: 81          add  a,c			; halla la última coordenada X de esta entrada
39F4: FE 18       cp   $18			; si la última coordenada X <= limite superior en X, salta
39F6: 38 02       jr   c,$39FA		;  en otro caso se trunca la última coordenada X al límite de las X
39F8: 3E 18       ld   a,$18

39FA: 4F          ld   c,a			; c = número de elementos a dibujar en X
39FB: 2E 00       ld   l,$00		; l = posición inicial en X
39FD: 18 0A       jr   $3A09		; pasa a recortar en Y

; aquí llega si la coordenada X > limite inferior en X
39FF: 6F          ld   l,a		; l = posición inicial en X
3A00: 81          add  a,c		; suma a la posición inicial el número de elementos en X
3A01: D6 18       sub  $18		; si la coordenada final en X <= limite superior en X, salta
3A03: 38 04       jr   c,$3A09
3A05: ED 44       neg			; a = diferencia entre el límite superior en X y la coordenada final X
3A07: 81          add  a,c
3A08: 4F          ld   c,a		; c = número de elementos a dibujar en X

; aquí llega después de recortar en X
3A09: 7C          ld   a,h			; coge la coordenada Y actual de la entrada
3A0A: D6 00       sub  $00			; ajusta la coordenada al principio de lo visible en Y
3A0C: 30 0C       jr   nc,$3A1A		; si la coordenada Y > limite inferior en Y, salta
3A0E: 80          add  a,b			; halla la última coordenada Y de esta entrada
3A0F: FE 18       cp   $18			; si la última coordenada Y <= limite superior en Y, salta
3A11: 38 02       jr   c,$3A15
3A13: 3E 18       ld   a,$18
3A15: 47          ld   b,a			; b = número de elementos a dibujar en y
3A16: 26 00       ld   h,$00		; h = posición inicial en Y
3A18: 18 0A       jr   $3A24

; aquí llega si la coordenada Y > limite inferior en Y
3A1A: 67          ld   h,a			; h = posición inicial en Y
3A1B: 80          add  a,b			; suma a la posición inicial el número de elementos en Y
3A1C: D6 18       sub  $18			; si la coordenada final en Y <= limite superior en Y, salta
3A1E: 38 04       jr   c,$3A24
3A20: ED 44       neg				; a = diferencia entre el límite superior en Y y la coordenada final Y
3A22: 80          add  a,b
3A23: 47          ld   b,a			; b = número de elementos a dibujar en Y

; aquí llega la entrada una vez que ha sido recortada en X y en Y
; l = posición inicial en X
; h = posición inicial en Y
; c = número de elementos a dibujar en X
; b = número de elementos a dibujar en Y
3A24: 7D          ld   a,l			; a = posición inicial en X
3A25: 6C          ld   l,h			; l = posición inicial en Y
3A26: 26 00       ld   h,$00
3A28: 29          add  hl,hl
3A29: 29          add  hl,hl
3A2A: 29          add  hl,hl
3A2B: 54          ld   d,h			; de = 8*hl
3A2C: 5D          ld   e,l
3A2D: 29          add  hl,hl
3A2E: 19          add  hl,de		; hl = 24*hl
3A2F: ED 5B 8A 2D ld   de,($2D8A)	; lee la dirección del buffer de pantalla
3A33: 85          add  a,l			; hl = hl + pos inicial en X
3A34: 6F          ld   l,a
3A35: 8C          adc  a,h
3A36: 95          sub  l
3A37: 67          ld   h,a
3A38: 19          add  hl,de		; hl = desplazamiento en el buffer de pantalla para la posición inicial en X y en Y
3A39: 11 18 00    ld   de,$0018		; cada línea ocupa 24 bytes
3A3C: 08          ex   af,af'		; recupera los 4 bits más significativos del byte 0
3A3D: C5          push bc
3A3E: E5          push hl
3A3F: 41          ld   b,c			; b = ancho
3A40: 77          ld   (hl),a
3A41: 23          inc  hl
3A42: 10 FC       djnz $3A40		; escribe el valor recorriendo el ancho
3A44: E1          pop  hl
3A45: 19          add  hl,de		; pasa a la siguiente línea
3A46: C1          pop  bc
3A47: 10 F4       djnz $3A3D		; sigue procesando el alto
3A49: C3 73 39    jp   $3973		; continúa procesando el resto de elementos

; aquí debería estar la rutina que dibuja el mapa de la pantalla actual, pero para la versión final se eliminó
3A4C: C9          ret

; devuelve en hl la dirección de la siguiente línea de pantalla
3A4D: 7C          ld   a,h			; pasa al siguiente banco
3A4E: C6 08       add  a,$08
3A50: 38 02       jr   c,$3A54
3A52: 67          ld   h,a
3A53: C9          ret

3A54: 7C          ld   a,h			; si hay acarreo, pasa a la siguiente línea y ajusta para que esté en el rango 0xc000-0xffff
3A55: E6 C7       and  $C7
3A57: 67          ld   h,a
3A58: 3E 50       ld   a,$50
3A5A: 85          add  a,l
3A5B: 6F          ld   l,a
3A5C: D0          ret  nc
3A5D: 8C          adc  a,h
3A5E: 95          sub  l
3A5F: 67          ld   h,a
3A60: C9          ret

; La configuración de memoria al llegar a este punto es:
bancos: (0, 1, 2, 3)
0 -> abadia1 (a partir de 0x0100)
1 -> abadia2
2 -> abadia3
3 -> abadia3 (con un tile sobreescrito y los primeros 0x1000 bytes sobreescritos)
4 -> abadia5
5 -> abadia6
6 -> abadia7
7 -> abadia8

; crea una tabla para hacer flip en x a 4 pixels, y también inicia los datos de la habitación del espejo
3A61: 21 00 A1    ld   hl,$A100		; apunta a la memoria donde crear la tabla
3A64: 7D          ld   a,l
3A65: E6 F0       and  $F0
3A67: 4F          ld   c,a			; c = 4 bits más significativos de l
3A68: 7D          ld   a,l
3A69: E6 0F       and  $0F			; a = 4 bits menos significativos de l
3A6B: CB 11       rl   c
3A6D: 1F          rra
3A6E: CB 11       rl   c
3A70: 1F          rra
3A71: CB 11       rl   c
3A73: 1F          rra
3A74: CB 11       rl   c
3A76: 1F          rra
3A77: CB 11       rl   c
3A79: B1          or   c			; a = b4 b5 b6 b7 b0 b1 b2 b3
3A7A: 77          ld   (hl),a
3A7B: 2C          inc  l
3A7C: 20 E6       jr   nz,$3A64		; completa la tabla

3A7E: 21 86 50    ld   hl,$5086		; apunta a datos de abadia7 (datos de altura de la planta 2)
3A81: 01 C6 7F    ld   bc,$7FC6		; fija configuracion 6 (0, 6, 2, 3)
3A84: ED 49       out  (c),c
3A86: CD C2 3A    call $3AC2		; incrementa hl hasta el final de los datos de altura de la planta 2
3A89: 01 C7 7F    ld   bc,$7FC7		; fija configuracion 7 (0, 7, 2, 3)
3A8C: ED 49       out  (c),c
3A8E: 22 D9 34    ld   ($34D9),hl	; guarda el puntero de fin de tabla (que apunta a los datos de la habitación del espejo)

3A91: 06 72       ld   b,$72		; 114 pantallas
3A93: 21 00 40    ld   hl,$4000		; apunta a datos de abadia8
3A96: 7E          ld   a,(hl)		; lee el número de bytes de la pantalla
3A97: 85          add  a,l
3A98: 6F          ld   l,a			; avanza a la siguiente pantalla
3A99: 8C          adc  a,h
3A9A: 95          sub  l
3A9B: 67          ld   h,a
3A9C: 10 F8       djnz $3A96

; hl apunta a la habitación del espejo
3A9E: 06 00       ld   b,$00		; hasta 256 bloques
3AA0: 7E          ld   a,(hl)		; lee un byte
3AA1: 23          inc  hl
3AA2: FE 1F       cp   $1F			; si no es 0x1f, salta
3AA4: 20 19       jr   nz,$3ABF
3AA6: 7E          ld   a,(hl)		; si es 0x1f, lee los 2 bytes siguientes
3AA7: 23          inc  hl
3AA8: 4E          ld   c,(hl)
3AA9: 2B          dec  hl
3AAA: FE AA       cp   $AA			; si el siguiente byte del bloque no es 0xaa, sigue avanzando
3AAC: 20 11       jr   nz,$3ABF
3AAE: 79          ld   a,c
3AAF: FE 51       cp   $51			; si el segundo byte del bloque no es 0x51, sigue avanzando
3AB1: 20 0C       jr   nz,$3ABF

3AB3: 23          inc  hl			; si llega aquí, los datos de la habitación indican que el espejo está abierto
3AB4: 36 11       ld   (hl),$11		;  por lo que modifica la habitación para que el espejo se cierre
3AB6: 22 E0 34    ld   ($34E0),hl	; guarda el desplazamiento de la pantalla del espejo en abadia8.bin
3AB9: 01 C0 7F    ld   bc,$7FC0		; fija configuracion 0 (0, 1, 2, 3)
3ABC: ED 49       out  (c),c
3ABE: C9          ret

3ABF: 10 DF       djnz $3AA0
3AC1: C9          ret

; incrementa hl hasta encontrar el fin de la tabla
3AC2: 7E          ld   a,(hl)		; lee un byte
3AC3: FE FF       cp   $FF			; 0xff indica el final
3AC5: C8          ret  z
3AC6: CB 5F       bit  3,a
3AC8: 28 01       jr   z,$3ACB
3ACA: 23          inc  hl			; incrementa la dirección 4 o 5 bytes dependiendo del bit 3
3ACB: 23          inc  hl
3ACC: 23          inc  hl
3ACD: 23          inc  hl
3ACE: 23          inc  hl
3ACF: 18 F1       jr   $3AC2

; genera 4 tablas de 0x100 bytes para el manejo de pixels mediante operaciones AND y OR en 0x9d00 a 0xa0ff
3AD1: 01 00 9D    ld   bc,$9D00	; apunta a datos de abadia3 que ya se han copiado antes, por lo que pueden sobreescribirse sin problema
3AD4: 79          ld   a,c		; a = b7 b6 b5 b4 b3 b2 b1 b0
3AD5: E6 F0       and  $F0		; a = b7 b6 b5 b4 0 0 0 0
3AD7: 57          ld   d,a		; d = b7 b6 b5 b4 0 0 0 0
3AD8: 79          ld   a,c		; a = b7 b6 b5 b4 b3 b2 b1 b0
3AD9: 0F          rrca			; a = b0 b7 b6 b5 b4 b3 b2 b1
3ADA: 0F          rrca			; a = b1 b0 b7 b6 b5 b4 b3 b2
3ADB: 0F          rrca			; a = b2 b1 b0 b7 b6 b5 b4 b3
3ADC: 0F          rrca			; a = b3 b2 b1 b0 b7 b6 b5 b4
3ADD: 5F          ld   e,a		; e = b3 b2 b1 b0 b7 b6 b5 b4
3ADE: A1          and  c		; a = b3&b7 b2&b6 b1&b5 b0&b4 b3&b7 b2&b6 b1&b5 b0&b4
3ADF: E6 0F       and  $0F		; a = 0 0 0 0 b3&b7 b2&b6 b1&b5 b0&b4
3AE1: B2          or   d		; a = b7 b6 b5 b4 b3&b7 b2&b6 b1&b5 b0&b4
3AE2: 02          ld   (bc),a	; graba pixel i = (Pi1&Pi0 Pi0) (0->0, 1->1, 2->0, 3->3)

3AE3: 04          inc  b		; apunta a la siguiente tabla
3AE4: 7B          ld   a,e		; a = b3 b2 b1 b0 b7 b6 b5 b4
3AE5: A9          xor  c		; a = b3^b7 b2^b6 b1^b5 b0^b4 b3^b7 b2^b6 b1^b5 b0^b4
3AE6: A1          and  c		; a = (b3^b7)&b7 (b2^b6)&b6 (b1^b5)&b5 (b0^b4)&b4 (b3^b7)&b3 (b2^b6)&b2 (b1^b5)&b1 (b0^b4)&b0
3AE7: E6 0F       and  $0F		; a = 0 0 0 0 (b3^b7)&b3 (b2^b6)&b2 (b1^b5)&b1 (b0^b4)&b0
3AE9: 57          ld   d,a		; d = 0 0 0 0 (b3^b7)&b3 (b2^b6)&b2 (b1^b5)&b1 (b0^b4)&b0
3AEA: 87          add  a,a		; a = 0 0 0 (b3^b7)&b3 (b2^b6)&b2 (b1^b5)&b1 (b0^b4)&b0 0
3AEB: 87          add  a,a		; a = 0 0 (b3^b7)&b3 (b2^b6)&b2 (b1^b5)&b1 (b0^b4)&b0 0 0
3AEC: 87          add  a,a		; a = 0 (b3^b7)&b3 (b2^b6)&b2 (b1^b5)&b1 (b0^b4)&b0 0 0 0
3AED: 87          add  a,a		; a = (b3^b7)&b3 (b2^b6)&b2 (b1^b5)&b1 (b0^b4)&b0 0 0 0 0
3AEE: B2          or   d		; a = (b3^b7)&b3 (b2^b6)&b2 (b1^b5)&b1 (b0^b4)&b0 (b7^b3)&b3 (b6^b2)&b2 (b5^b1)&b1 (b0^b4)&b0
3AEF: 02          ld   (bc),a	; graba pixel i = ((Pi1^Pi0)&Pi1 (Pi1^Pi0)&Pi1) (0->0, 1->0, 2->3, 3->0)

3AF0: 04          inc  b		; apunta a la siguiente tabla
3AF1: 79          ld   a,c		; a = b7 b6 b5 b4 b3 b2 b1 b0
3AF2: E6 0F       and  $0F		; a = 0 0 0 0 b3 b2 b1 b0
3AF4: 57          ld   d,a		; d = 0 0 0 0 b3 b2 b1 b0
3AF5: 7B          ld   a,e		; a = b3 b2 b1 b0 b7 b6 b5 b4
3AF6: A1          and  c		; a = b3&b7 b2&b6 b1&b5 b0&b4 b3&b7 b2&b6 b1&b5 b0&b4
3AF7: E6 F0       and  $F0		; a = b3&b7 b2&b6 b1&b5 b0&b4 0 0 0 0
3AF9: B2          or   d		; a = b3&b7 b2&b6 b1&b5 b0&b4 b3 b2 b1 b0
3AFA: 02          ld   (bc),a	; graba pixel i = (Pi1 Pi1&Pi0) (0->0, 1->0, 2->2, 3->3)

3AFB: 04          inc  b		; apunta a la siguiente tabla
3AFC: 7B          ld   a,e		; a = b3 b2 b1 b0 b7 b6 b5 b4
3AFD: A9          xor  c		; a = b3^b7 b2^b6 b1^b5 b0^b4 b7^b3 b6^b2 b5^b1 b4^b0
3AFE: A1          and  c		; a = (b3^b7)&b7 (b2^b6)&b6 (b1^b5)&b5 (b0^b4)&b4 (b7^b3)&b3 (b6^b2)&b2 (b5^b1)&b1 (b4^b0)&b0
3AFF: E6 F0       and  $F0		; a = (b3^b7)&b7 (b2^b6)&b6 (b1^b5)&b5 (b0^b4)&b4 0 0 0 0
3B01: 57          ld   d,a		; d = (b3^b7)&b7 (b2^b6)&b6 (b1^b5)&b5 (b0^b4)&b4 0 0 0 0
3B02: CB 3F       srl  a		; a = 0 (b3^b7)&b7 (b2^b6)&b6 (b1^b5)&b5 (b0^b4)&b4 0 0 0
3B04: CB 3F       srl  a		; a = 0 0 (b3^b7)&b7 (b2^b6)&b6 (b1^b5)&b5 (b0^b4)&b4 0 0
3B06: CB 3F       srl  a		; a = 0 0 0 (b3^b7)&b7 (b2^b6)&b6 (b1^b5)&b5 (b0^b4)&b4 0
3B08: CB 3F       srl  a		; a = 0 0 0 0 (b3^b7)&b7 (b2^b6)&b6 (b1^b5)&b5 (b0^b4)&b4
3B0A: B2          or   d		; a = (b3^b7)&b7 (b2^b6)&b6 (b1^b5)&b5 (b0^b4)&b4 (b3^b7)&b7 (b2^b6)&b6 (b1^b5)&b5 (b0^b4)&b4
3B0B: 02          ld   (bc),a	; graba pixel i = ((Pi1^Pi0)&Pi0 (Pi1^Pi0)&Pi0) (0->0, 1->3, 2->0, 3->0)

3B0C: 05          dec  b		; apunta a la tabla inicial
3B0D: 05          dec  b
3B0E: 05          dec  b
3B0F: 0C          inc  c		; continua hasta completar los casos posibles
3B10: 20 C2       jr   nz,$3AD4
3B12: C9          ret

; imprime un carácter en el marcador
3B13: 0E FF       ld   c,$FF
3B15: 18 02       jr   $3B19

; imprime el carácter que se le pasa en a en la pantalla
;  usa la posición de pantalla que hay en 0x2d97
3B17: 0E 0F       ld   c,$0F		; c sirve para ajustar el color
3B19: E6 7F       and  $7F			; se asegura de que el caracter esté entre 0 y 127
3B1B: FE 20       cp   $20
3B1D: 11 E7 38    ld   de,$38E7		; de = dirección del espacio en blanco
3B20: 28 0E       jr   z,$3B30		; si el carácter a imprimir es un espacio, salta
3B22: D6 2D       sub  $2D          ; si el carácter a imprimir es < 0x2d, no es imprimible y sale
3B24: D8          ret  c

3B25: 6F          ld   l,a			; cada caracter de la tabla de caracteres ocupa 8 bytes
3B26: 26 00       ld   h,$00		; hl = 8*(a - 0x2d)
3B28: 29          add  hl,hl
3B29: 29          add  hl,hl
3B2A: 29          add  hl,hl
3B2B: 11 00 B4    ld   de,$B400
3B2E: 19          add  hl,de		; la tabla de los gráficos de los caracteres empieza en 0xb400
3B2F: EB          ex   de,hl		; de = dirección del caracter
3B30: 2A 97 2D    ld   hl,($2D97)	; lee la dirección de pantalla por la que va escribiendo actualmente (h = y en pixels, l = x en bytes)
3B33: E5          push hl
3B34: CD 42 3C    call $3C42		; convierte hl a direccion de pantalla
3B37: 06 08       ld   b,$08		; 8 líneas
3B39: 1A          ld   a,(de)		; lee un byte que forma el caracter
3B3A: E6 F0       and  $F0			; se queda con los 4 bits superiores (4 pixels izquierdos del carácter)
3B3C: A9          xor  c
3B3D: 77          ld   (hl),a		; graba el byte en pantalla
3B3E: 1A          ld   a,(de)		; lee el byte que forma el caracter
3B3F: 87          add  a,a
3B40: 87          add  a,a
3B41: 87          add  a,a
3B42: 87          add  a,a			; se queda con los 4 bits inferiores en la parte superior (4 pixels derechos del carácter)
3B43: 23          inc  hl
3B44: A9          xor  c
3B45: 77          ld   (hl),a		; graba el byte en pantalla
3B46: 2B          dec  hl
3B47: CD 4D 3A    call $3A4D		; pasa a la siguiente línea de pantalla
3B4A: 13          inc  de			; apunta al siguiente byte del caracter
3B4B: 10 EC       djnz $3B39		; repite para 8 líneas
3B4D: E1          pop  hl
3B4E: 2C          inc  l			; avanza 8 pixels para la próxima ejecución
3B4F: 2C          inc  l
3B50: 22 97 2D    ld   ($2D97),hl	; graba el nuevo puntero
3B53: C9          ret

; -------------------------- código relacionado con la escritura de las frases por el marcador --------------------------------------
; llamado desde la interrupción
3B54: F3          di
3B55: 3A 9A 2D    ld   a,($2D9A)
3B58: 3C          inc  a
3B59: FE 2D       cp   $2D
3B5B: 32 9A 2D    ld   ($2D9A),a		; si no es 45 sale
3B5E: C0          ret  nz

3B5F: AF          xor  a				; mantiene entre 0 y 44
3B60: 32 9A 2D    ld   ($2D9A),a

3B63: 3A A2 2D    ld   a,($2DA2)		; si no está mostrando una frase, sale
3B66: A7          and  a
3B67: C8          ret  z

3B68: DD E5       push ix
3B6A: E5          push hl
3B6B: 2A 97 2D    ld   hl,($2D97)		; guarda el valor de esta variable, ya que se modificará
3B6E: E5          push hl
3B6F: D5          push de
3B70: C5          push bc
3B71: 08          ex   af,af'
3B72: F5          push af
3B73: CD 20 10    call $1020			; inicia la entrada 3 de la música

3B76: 3A A0 2D    ld   a,($2DA0)
3B79: 3D          dec  a
3B7A: 28 5B       jr   z,$3BD7			; si 0x2ad0 valía 1, salta (se ha terminado una palabra)

3B7C: 2A 9C 2D    ld   hl,($2D9C)		; obtiene la dirección al texto que se está poniendo en el marcador
3B7F: CB 7E       bit  7,(hl)
3B81: 28 05       jr   z,$3B88			; si no tiene puesto el bit 7, salta
3B83: 3E 01       ld   a,$01
3B85: 32 A0 2D    ld   ($2DA0),a		; indica que ha terminado la palabra

3B88: 7E          ld   a,(hl)
3B89: E6 07       and  $07				; se queda con los 3 bits menos significativos de la letra actual
3B8B: 32 89 13    ld   ($1389),a		; modifica los tonos de la voz
3B8E: 32 8F 13    ld   ($138F),a
3B91: ED 44       neg
3B93: 32 8C 13    ld   ($138C),a
3B96: 7E          ld   a,(hl)			; obtiene los 7 bits menos significativos de la letra actual
3B97: E6 7F       and  $7F
3B99: 23          inc  hl
3B9A: 22 9C 2D    ld   ($2D9C),hl		; actualiza el puntero a los datos del texto

; realiza el scroll de la parte del marcador relativa a las frases y pinta el caracter que esté en a
3B9D: F5          push af
3B9E: 21 5A E6    ld   hl,$E65A		; hl apunta a la parte de pantalla de las frases (104, 164)
3BA1: 01 1E 08    ld   bc,$081E		; b = 8 lineas, c = 30 bytes
3BA4: E5          push hl
3BA5: C5          push bc
3BA6: 06 00       ld   b,$00
3BA8: 54          ld   d,h			; de = hl
3BA9: 5D          ld   e,l
3BAA: 1B          dec  de
3BAB: 1B          dec  de
3BAC: ED B0       ldir				; realiza el scroll de 30 bytes a la izquierda
3BAE: C1          pop  bc
3BAF: E1          pop  hl
3BB0: CD 4D 3A    call $3A4D		; pasa a la siguiente línea
3BB3: 10 EF       djnz $3BA4		; completa las 8 líneas

3BB5: 21 2E A4    ld   hl,$A42E		; posición (h = y en pixels, l = x en bytes) (184, 164)
3BB8: 22 97 2D    ld   ($2D97),hl	; fija la posición en la que debe dibujar el caracter (usado por la rutina 0x3b13)
3BBB: C1          pop  bc			; recupera el parámetro con el que se llamó
3BBC: 78          ld   a,b			; obtiene la letra a poner
3BBD: FE 20       cp   $20			; ¿es un espacio en blanco?
3BBF: 3E 06       ld   a,$06
3BC1: 20 01       jr   nz,$3BC4
3BC3: AF          xor  a			; si es un espacio en blanco, pone 0
3BC4: 32 C2 13    ld   ($13C2),a	; modifica la tabla de envolventes y cambios de volumen para la voz
3BC7: 78          ld   a,b
3BC8: CD 13 3B    call $3B13		; imprime un carácter en el marcador
3BCB: F1          pop  af
3BCC: 08          ex   af,af'
3BCD: C1          pop  bc
3BCE: D1          pop  de
3BCF: E1          pop  hl
3BD0: 22 97 2D    ld   ($2D97),hl	; restaura el valor de esta variable, ya que ha sido modificado
3BD3: E1          pop  hl
3BD4: DD E1       pop  ix
3BD6: C9          ret

; aqui llega si se ha terminado una palabra (0x2da0 = 1)
3BD7: 3A 9B 2D    ld   a,($2D9B)	; lee los caracteres que quedan por decir
3BDA: A7          and  a
3BDB: 28 0F       jr   z,$3BEC		; si aun quedan por decir muchos, salta
3BDD: 3D          dec  a
3BDE: 32 9B 2D    ld   ($2D9B),a	; decrementa los caracteres que quedan por decir
3BE1: 3E 20       ld   a,$20
3BE3: 20 B8       jr   nz,$3B9D		; realiza el scroll de la parte del marcador relativa a las frases y pinta un espacio en blanco

3BE5: AF          xor  a			; si la frase ha terminado (caracteres por decir = 0), lo indica
3BE6: 32 A2 2D    ld   ($2DA2),a
3BE9: C3 CB 3B    jp   $3BCB		; restaura los registros y sale

; aquí llega si aún quedan caracteres por decir
3BEC: 32 A0 2D    ld   ($2DA0),a
3BEF: 2A 9E 2D    ld   hl,($2D9E)	; obtiene el puntero a los datos de la voz actual
3BF2: 7E          ld   a,(hl)		; lee un byte
3BF3: FE FF       cp   $FF
3BF5: 20 0C       jr   nz,$3C03		; si no han terminado los datos de la voz, salta
3BF7: 3E 11       ld   a,$11
3BF9: 32 9B 2D    ld   ($2D9B),a	; indica que quedan 11 caracteres por mostrar
3BFC: 3E 01       ld   a,$01
3BFE: 32 A0 2D    ld   ($2DA0),a	; indica que se ha terminado la palabra
3C01: 18 D4       jr   $3BD7

3C03: FE FA       cp   $FA			; si no es >= 0xfa, continua
3C05: 30 21       jr   nc,$3C28
3C07: 23          inc  hl
3C08: FE F9       cp   $F9
3C0A: 0E 20       ld   c,$20		; c = espacio en blanco
3C0C: 38 04       jr   c,$3C12		; si el valor es < 0xf9, salta
3C0E: 0E 00       ld   c,$00		; c = 00, ningún espacio en blanco
3C10: 7E          ld   a,(hl)		; si el valor leido es 0xf9, hay que decir la siguiente palabra siguiendo a la actual
3C11: 23          inc  hl

3C12: 22 9E 2D    ld   ($2D9E),hl	; actualiza la dirección de los datos de la voz

3C15: 21 80 B5    ld   hl,$B580		; apunta a la tabla de palabras
3C18: 47          ld   b,a
3C19: A7          and  a
3C1A: C4 3A 3C    call nz,$3C3A		; si el byte leido no era 0, busca la entrada correspondiente en la tabla de palabras
3C1D: 22 9C 2D    ld   ($2D9C),hl	; guarda la dirección de la palabra
3C20: 79          ld   a,c
3C21: A7          and  a
3C22: CA 76 3B    jp   z,$3B76		; dependiendo de c, salta a realizar el scroll y pinta el caracter, o vuelve al principio a procesar el caracter siguiente
3C25: C3 9D 3B    jp   $3B9D		; realiza el scroll de la parte del marcador relativa a las frases y pinta el caracter que esté en a

; aquí llega si el valor leido es mayor o igual que 0xfa
3C28: D6 FA       sub  $FA
3C2A: 23          inc  hl
3C2B: 22 9E 2D    ld   ($2D9E),hl	; actualiza la dirección de los datos de la frase
3C2E: 21 E2 38    ld   hl,$38E2		; hl apunta a la tabla de símbolos de puntuación
3C31: CD 2D 16    call $162D		; hl = hl + a
3C34: 22 9C 2D    ld   ($2D9C),hl	; cambia la dirección del texto que se está poniendo en el marcador
3C37: C3 76 3B    jp   $3B76

; busca la entrada número b de la tabla de palabras
3C3A: CB 7E       bit  7,(hl)		; busca el fin de la palabra actual
3C3C: 23          inc  hl
3C3D: 28 FB       jr   z,$3C3A		; repite hasta que se acabe la entrada actual
3C3F: 10 F9       djnz $3C3A		; repite hasta encontrar la entrada
3C41: C9          ret

; dado hl (coordenadas Y,X), calcula el desplazamiento correspondiente en pantalla
; al valor calculado se le suma 32 pixels a la derecha (puesto que el área de juego va desde x = 32 a x = 256 + 32 - 1
; l = coordenada X (en bytes)
; h = coordenada Y (en pixels)
3C42: D5          push de
3C43: 7D          ld   a,l
3C44: 08          ex   af,af'
3C45: 7C          ld   a,h
3C46: E6 F8       and  $F8			; obtiene el valor para calcular el desplazamiento dentro del banco de VRAM
3C48: 6F          ld   l,a
3C49: 7C          ld   a,h
3C4A: 26 00       ld   h,$00
3C4C: 29          add  hl,hl		; dentro de cada banco, la línea a la que se quiera ir puede calcularse como (y & 0xf8)*10
3C4D: 54          ld   d,h			;  o lo que es lo mismo, (y >> 3)*0x50
3C4E: 5D          ld   e,l
3C4F: 29          add  hl,hl
3C50: 29          add  hl,hl
3C51: 19          add  hl,de		; hl = desplazamiento dentro del banco
3C52: E6 07       and  $07          ; a = 3 bits menos significativos en y (para calcular al banco de VRAM al que va)
3C54: 87          add  a,a
3C55: 87          add  a,a
3C56: 87          add  a,a			; ajusta los 3 bits
3C57: B4          or   h			; completa el cálculo del banco
3C58: F6 C0       or   $C0			; ajusta para que esté dentro de 0xc000-0xffff
3C5A: 67          ld   h,a
3C5B: 08          ex   af,af'
3C5C: 85          add  a,l			; suma el desplazamiento en x
3C5D: 6F          ld   l,a
3C5E: 8C          adc  a,h
3C5F: 95          sub  l
3C60: 67          ld   h,a
3C61: 11 08 00    ld   de,$0008		; ajusta para que salga 32 pixels más a la derecha
3C64: 19          add  hl,de
3C65: D1          pop  de
3C66: C9          ret
; ----------------------- fin del código relacionado con la escritura de las frases por el marcador -----------------------------

; tabla para modificar el acceso a las habitaciones según las llaves que se tengan. 6 entradas (una por puerta) de 5 bytes
; byte 0: indice de la habitación en la matriz de habitaciones de la planta baja
; byte 1: permisos para esa habitación
; byte 2: indice de la habitación en la matriz de habitaciones de la planta baja
; byte 3: permisos para esa habitación
; byte 4: 0xff
3C67: 	35 01 36 04 FF	; entre la habitación (3, 5) = 0x3e y la (3, 6) = 0x3d hay una puerta (la de la habitación del abad)
		1B 08 2B 02 FF	; entre la habitación (1, b) = 0x00 y la (2, b) = 0x38 hay una puerta (la de la habitación de los monjes)
		56 08 66 02 FF	; entre la habitación (5, 6) = 0x3d y la (6, 6) = 0x3c hay una puerta (la de la habitación de severino)
		29 01 2A 04 FF	; entre la habitación (2, 9) = 0x29 y la (2, a) = 0x37 hay una puerta (la de la salida de las habitaciones hacia la iglesia)
		27 01 28 04 FF	; entre la habitación (2, 7) = 0x28 y la (2, 8) = 0x26 hay una puerta (la del pasadizo de detrás de la cocina)
		75 01 76 04 FF	; entre la habitación (7, 5) = 0x11 y la (7, 6) = 0x12 hay una puerta (la que cierra el paso a la parte izquierda de la planta baja)

; ----------------------- código relacionado con el intérprete del comportamiento de los personajes -----------------------------

3C85-3CA5: variables relacionadas con la lógica

	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	04 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	00

; copiado en 0x103-0x107. posiciones predefinidas de malaquías
3CA6: EF 02
	FA 00 00
3CAB:
	84 48 42 -> iglesia
	2F 37 02 -> refectorio
	37 38 4F -> posición en la mesa que está en la entrada del pasillo para poder subir a la biblioteca
	3A 34 8F -> posición para cerrar el paso al pasillo que lleva a la biblioteca
	5D 77 00 -> posición para cerrar las 2 puertas del ala izquierda de la abadía
	58 2A 00 -> posición en frente de la mesa de la cocina de delante del pasadizo
	35 37 53 -> posición donde deja la llave en la mesa que está en la entrada del pasillo para poder subir a la biblioteca
	BC 18 02 -> posición en su celda
	68 52 02 -> celda de severino

; copiado en 0x108-0x10a. posiciones predefinidas del abad
3CC6: FA 00 00
3CC9:
	88 3C C4 -> posición en el altar de la iglesia
	3D 37 82 -> posición en el refectorio
	54 3C 02 -> posición en su celda
	88 84 C2 -> posición en la entrada de la abadía
	A4 58 40 -> posición de la primera parada durante el discurso de bienvenida
	A5 21 02 -> posición para que entremos a nuestra celda
	9C 2A 02 -> posición en la puerta de acceso de los monjes a la iglesia
	C7 27 00 -> posición en la pantalla en la que presenta a jorge
	68 61 42 -> posición en la puerta de la celda de severino
	3A 34 0F -> posición a la entrada del pasillo por el que se va a las escaleras que suben a la biblioteca

; copiado en 0x10b-0x10d. Estado y posiciones predefinidas de berengario
3CE7: FA 00 00
	8C 48 42 -> iglesia
	32 35 C2 -> refectorio
	3D 5C 8F -> su mesa en el scriptorium
	BC 15 02 -> celda de los monjes
	88 A8 C0 -> salida de la abadía
	52 67 04 -> posición al pie de las escaleras para subir al scriptorium
	68 57 02 -> celda de severino

; copiado en 0x10e-0x110. Estado y posiciones predefinidas de severino/jorge
3CFF: FA 00 00
	8C 4B 42 -> iglesia
	36 35 C2 -> refectorio
	68 55 02 -> celda de verengario
	C9 2A 00 -> cerca de las celdas de los monjes
	19 2B 1A -> habitación donde muere jorge

; copiado en 0x111-0x113. Estado y posiciones predefinidas de adso
3D11: FF 00 00
3D14:	84 4E 42 -> iglesia
		34 39 42 -> refectorio
		A8 18 00 -> celda de guillermo

; tabla de asociación de constantes a direcciones de memoria importantes para el programa (usado por el sistema de script)
3D1D: 	[0x3038] -> 0x00 (0x80) -> posición x de guillermo
		[0x3039] -> 0x01 (0x81) -> posición y de guillermo
		[0x303a] -> 0x02 (0x82) -> altura de guillermo
		[0x3047] -> 0x03 (0x83) -> posición x de adso
		[0x3075] -> 0x04 (0x84) -> posición x de berengario
		[0x3049] -> 0x05 (0x85) -> altura de adso
		[0x3caa] -> 0x06 (0x86) -> a donde va malaquías
		[0x3ca8] -> 0x07 (0x87) -> a donde ha llegado malaquías
		[0x2d81] -> 0x08 (0x88) -> momento del día
		[0x2da1] -> 0x09 (0x89) -> indica si está reproduciendo una frase
		[0x3cc6] -> 0x0a (0x8a) -> a donde ha llegado el abad
		[0x3cc8] -> 0x0b (0x8b) -> a donde va el abad
		[0x3cc7] -> 0x0c (0x8c) -> estado del abad
		[0x2d80] -> 0x0d (0x8d) -> número de día
		[0x3ca9] -> 0x0e (0x8e) -> estado de malaquías
		[0x3c9e] -> 0x0f (0x8f) -> contador usado para ver cuanto tiempo está guillermo en el scriptorium sin obedecer
		[0x3ce9] -> 0x10 (0x90) -> a donde va berengario
		[0x3ce7] -> 0x11 (0x91) -> a donde ha llegado berengario
		[0x3ce8] -> 0x12 (0x92) -> estado de berengario
		[0x3d01] -> 0x13 (0x93) -> a donde va severino
		[0x3cff] -> 0x14 (0x94) -> a donde ha llegado severino
		[0x3d00] -> 0x15 (0x95) -> estado de severino
		[0x3d13] -> 0x16 (0x96) -> a dónde va adso
		[0x3d11] -> 0x17 (0x97) -> a donde ha llegado adso
		[0x3d12] -> 0x18 (0x98) -> estado de adso
		[0x3c98] -> 0x19 (0x99) -> contador
		[0x2dbd] -> 0x1a (0x9a) -> indica el número de pantalla que muestra la cámara
		[0x3c9a] -> 0x1b (0x9b) -> indica si hay que avanzar el momento del día
		[0x3c97] -> 0x1c (0x9c) -> indica si guillermo ha muerto
		[0x3074] -> 0x1d (0x9d) -> posición x de berengario/bernardo gui/encapuchado/jorge
		[0x3ca6] -> 0x1e (0x9e) -> máscara para las puertas donde cada bit indica que puerta se comprueba si se abre
		[0x2ffe] -> 0x1f (0x9f) -> número y estado de la puerta 1 que cierra el paso al ala izquierda de la abadía
		[0x3003] -> 0x20 (0xa0) -> número y estado de la puerta 2 que cierra el paso al ala izquierda de la abadía
		[0x3c99] -> 0x21 (0xa1) -> contador del tiempo de respuesta de guillermo a la pregunta de adso de dormir
		[0x3f0e] -> 0x22 (0xa2) -> modifica la frase que muestra la rutina 0x3f0b
		[0x3c96] -> 0x23 (0xa3) -> indica si están listos para empezar la misa/la comida
		[0x2def] -> 0x24 (0xa4) -> objetos que tiene guillermo
		[0x3c94] -> 0x25 (0xa5) -> indica que berengario le ha dicho al abad que guillermo ha cogido el pergamino
		[0x2e04] -> 0x26 (0xa6) -> objetos que tiene el abad
		[0x3c92] -> 0x27 (0xa7) -> personaje al que sigue la cámara si se está sin pulsar las teclas un rato
		[0x2e0b] -> 0x28 (0xa8) -> objetos de berengario
		[0x0840] -> 0x29 (0xa9) -> ??? no usado ???
		[0x3c95] -> 0x2a (0xaa) -> indica el momento del día de las últimas acciones ejecutadas
		[0x3ca1] -> 0x2b (0xab) -> indica que jorge o bernardo gui están activos para la rutina de pensar de berengario
		[0x3ca2] -> 0x2c (0xac) -> indica si malaquías está muerto o muriéndose
		[0x3ca3] -> 0x2d (0xad) -> indica que jorge está activo para la rutina de pensar de severino
		[0x3ca5] -> 0x2e (0xae) -> más información de estado de severino, berengario y malaquías
		[0x3c9b] -> 0x2f (0xaf) -> indica si guillermo está en su sitio en el refectorio o en misa
		[0x2e0d] -> 0x30 (0xb0) -> máscara con los objetos que puede coger berengario/bernardo gui
		[0x3ca4] -> 0x31 (0xb1) -> ???
		[0x3c9d] -> 0x32 (0xb2) -> valor aleatorio obtenido de los movimientos de adso
		[0x3c90] -> 0x33 (0xb3) -> indica que el pergamino lo tiene el abad en su habitación o está detrás de la habitación del espejo
		[0x3c8c] -> 0x34 (0xb4) -> si se está acabando la noche, se pone a 1. En otro caso, se pone a 0
		[0x3c8d] -> 0x35 (0xb5) -> indica cambios de estado de la lámpara
		[0x3c8e] -> 0x36 (0xb6) -> contador de tiempo que pueden ir a oscuras por la biblioteca
		[0x3c8b] -> 0x37 (0xb7) -> indica que la lámpara se está usando
		[0x2df3] -> 0x38 (0xb8) -> indica si adso tiene la lámpara
		[0x3ca7] -> 0x39 (0xb9) -> si es 0, indica que se ha completado la investigación
		[0x2dff] -> 0x3a (0xba) -> máscara con los objetos que puede coger malaquías
		[0x2dfd] -> 0x3b (0xbb) -> objetos de malaquías
		[0x416e] -> 0x3c (0xbc) -> ???
		[0x3c85] -> 0x3d (0xbd) -> contador usado para matar a guillermo si lee el libro sin los guantes
		[0x2df6] -> 0x3e (0xbe) -> objetos de adso
		[0x2dbe] -> 0x3f (0xbf) -> indica los bonus conseguidos 1
		[0x2dbf] -> 0x40 (0xc0) -> indica los bonus conseguidos 2

; tabla de valores para el computo de la distancia entre personajes, indexada según la orientación del personaje.
; Cada entrada tiene 4 bytes
; byte 0: valor a sumar a la distancia en x del personaje
; byte 1: valor umbral para para decir que el personaje está cerca en x
; byte 2: valor a sumar a la distancia en y del personaje
; byte 3: valor umbral para para decir que el personaje está cerca en y
3D9F: 	06 18 06 0C -> usado cuando la orientación del personaje es 0 (mirando hacia +x)
		06 0C 0C 18 -> usado cuando la orientación del personaje es 1 (mirando hacia -y)
		0C 18 06 0C -> usado cuando la orientación del personaje es 2 (mirando hacia -x)
		06 0C 06 18 -> usado cuando la orientación del personaje es 3 (mirando hacia +y)

; coge valores de la dirección de retorno, interpretando esos valores (lee posiciones de memoria relacionadas, realiza cálculos entre
; ellas hasta encontrar una instrucción de salto o llamada, y actualizando la primera posición de memoria relacionada) (llamado por rst 0x10)
3DAF: E1          pop  hl			; obtiene la dirección de retorno
3DB0: 7E          ld   a,(hl)		; lee el primer valor
3DB1: 23          inc  hl
3DB2: E5          push hl
3DB3: CD C3 3D    call $3DC3		; obtiene en hl una dirección que hay en [0x3d1d + 2*a]
3DB6: 22 C0 3D    ld   ($3DC0),hl	; fija el parámetro de la instrucción con la dirección leida
3DB9: E1          pop  hl
3DBA: CD D9 3D    call $3DD9		; procesa la ristra de bytes para ver si procesa alguna instrucción modificando c
3DBD: E5          push hl
3DBE: 79          ld   a,c			; graba en la dirección el valor leido
3DBF: 32 00 00    ld   ($0000),a	; modificado desde fuera
3DC2: C9          ret

; obtiene en hl una dirección que hay en 0x3d1d + 2*a (quitandole el bit superior)
3DC3: 87          add  a,a			; quita el bit superior e indexa (cada entrada son 2 bytes)
3DC4: 21 1D 3D    ld   hl,$3D1D		; apunta a la tabla de direcciones
3DC7: 85          add  a,l			; hl = hl + 2*a
3DC8: 6F          ld   l,a
3DC9: 8C          adc  a,h
3DCA: 95          sub  l
3DCB: 67          ld   h,a

3DCC: 5E          ld   e,(hl)		; de = [hl]
3DCD: 23          inc  hl
3DCE: 56          ld   d,(hl)
3DCF: EB          ex   de,hl
3DD0: C9          ret

; coge valores de la dirección de retorno, interpretando esos valores (lee posiciones de memoria relacionadas y realiza
;  cálculos entre ellas hasta encontrar una instrucción de salto o llamada) (llamado por rst 0x08)
3DD1: E1          pop  hl			; hl = dirección de retorno
3DD2: CD D9 3D    call $3DD9		; procesa la ristra de bytes para ver si procesa alguna instrucción modificando c
3DD5: E5          push hl			; fija la dirección de retorno después de los bytes que ha procesado
3DD6: 79          ld   a,c			; devuelve si c != 0
3DD7: A7          and  a
3DD8: C9          ret

3DD9: CD 47 3E    call $3E47		; devuelve un dato (en c) relacionado con lo que hay en hl y avanza hl

3DDC: 7E          ld   a,(hl)		; si la siguiente instrucción a ejecutar en hl es:
3DDD: FE 20       cp   $20			;  jr nz,$xxxx, rst 0x10, jp nz,$xxxx, call $xxxxx, rst 0x08, ret, jp $xxxx, jr $xxxx
3DDF: C8          ret  z			;  sale de la rutina (evaluación terminada)
3DE0: FE D7       cp   $D7
3DE2: C8          ret  z
3DE3: FE C2       cp   $C2
3DE5: C8          ret  z
3DE6: FE CD       cp   $CD
3DE8: C8          ret  z
3DE9: FE CF       cp   $CF
3DEB: C8          ret  z
3DEC: FE C9       cp   $C9
3DEE: C8          ret  z
3DEF: FE C3       cp   $C3
3DF1: C8          ret  z
3DF2: FE 18       cp   $18
3DF4: C8          ret  z

; si llega hasta aquí, hay que leer otro operando o ejecutar una instrucción entre 2 operandos
3DF5: 23          inc  hl			; avanza el puntero a datos
3DF6: D1          pop  de			; recupera el posible último valor calculado
3DF7: FE 3D       cp   $3D			; si se encuentra alguna coincidencia con las operaciones, salta
3DF9: 28 43       jr   z,$3E3E		; 0x3d (char '=') -> c = c1 == c2
3DFB: FE 3E       cp   $3E
3DFD: 28 2D       jr   z,$3E2C		; 0x3e (char '>') -> c = c1 >= c2
3DFF: FE 3C       cp   $3C
3E01: 28 32       jr   z,$3E35		; 0x3c (char '<') -> c = c1 < c2
3E03: FE 2A       cp   $2A
3E05: 28 21       jr   z,$3E28		; 0x2a (char '*') -> c = c1 | c2 entre booleanos, c = c1 & c2 entre valores
3E07: FE 26       cp   $26
3E09: 28 19       jr   z,$3E24		; 0x26 (char '&') -> c = c1 & c2 entre booleanos, c = c1 | c2 entre valores
3E0B: FE 2B       cp   $2B
3E0D: 28 11       jr   z,$3E20		; 0x2b (char '+') -> c = c1 + c2
3E0F: FE 2D       cp   $2D
3E11: 28 08       jr   z,$3E1B		; 0x2d (char '-') -> c = c1 - c2

; si llega aquí, es porque no tenía que ejecutar ninguna operación
3E13: D5          push de			; guarda la dirección de retorno (ya que no es un operando)
3E14: C5          push bc			; guarda el último operando obtenido
3E15: 2B          dec  hl			; retrocede el puntero de datos
3E16: CD 47 3E    call $3E47		; devuelve un dato relacionado con lo que hay hl y avanza hl
3E19: 18 C1       jr   $3DDC		; vuelve a comprobar los casos

; aquí salta si encuentra 0x2d (c = c1 - c2)
3E1B: 7B          ld   a,e
3E1C: 91          sub  c

3E1D: 4F          ld   c,a
3E1E: 18 BC       jr   $3DDC

; aquí salta si encuentra 0x2b (c = c1 + c2)
3E20: 79          ld   a,c
3E21: 83          add  a,e
3E22: 18 F9       jr   $3E1D

; aquí salta si encuentra 0x26 (c = c1 & c2 entre booleanos, c1 | c2 entre valores)
3E24: 79          ld   a,c
3E25: B3          or   e
3E26: 18 F5       jr   $3E1D

; aquí salta si encuentra 0x2a (c = c1 | c2 entre booleanos, c1 & c2 entre valores)
3E28: 79          ld   a,c
3E29: A3          and  e
3E2A: 18 F1       jr   $3E1D

; aquí salta si encuentra 0x3e (si c1 >= c2, c = 0, si no, c = 0xff)
3E2C: 7B          ld   a,e		; a = c1
3E2D: B9          cp   c		; lo compara con c2
3E2E: 0E 00       ld   c,$00
3E30: 30 AA       jr   nc,$3DDC	; si c1 >= c2, salta
3E32: 0D          dec  c
3E33: 18 A7       jr   $3DDC

; aquí salta si encuentra 0x3c (si c1 < c2, c = 0, si no, c = 0xff)
3E35: 7B          ld   a,e		; a = c1
3E36: B9          cp   c		; lo compara con c2
3E37: 0E 00       ld   c,$00
3E39: 38 A1       jr   c,$3DDC	; si c2 > c1, salta
3E3B: 0D          dec  c
3E3C: 18 9E       jr   $3DDC

; aquí salta si encuentra 0x3d (si c1 = c2, c = 0, si no, c = 0xff)
3E3E: 79          ld   a,c		; a = c2
3E3F: 0E 00       ld   c,$00
3E41: BB          cp   e		; ¿es igual a c1?
3E42: 28 98       jr   z,$3DDC
3E44: 0D          dec  c
3E45: 18 95       jr   $3DDC

; devuelve en c un dato relacionado con lo que hay en hl y avanza hl. Se usa para obtener valores de direcciones importantes del programa para
;  el sistema de script
;  si es 0x40, devuelve [hl+1]. si es < 0x80, devuelve [hl]. En otro caso, devuelve [0x3d1d + 2*[hl]]
3E47: 7E          ld   a,(hl)		; lee un dato
3E48: 23          inc  hl
3E49: FE 40       cp   $40			; si no es 0x40, salta
3E4B: 20 03       jr   nz,$3E50
3E4D: 4E          ld   c,(hl)		; si es 0x40, devuelve el dato que había después (usado para devolver datos >= 0x80 o datos que tengan)
3E4E: 23          inc  hl			;  el mismo valor que alguna de las instrucciones que hacen para al intérprete
3E4F: C9          ret

3E50: FE 80       cp   $80			; si es < 0x80, sale devolviendo el dato que se leyó
3E52: 4F          ld   c,a
3E53: D8          ret  c
3E54: E5          push hl
3E55: CD C3 3D    call $3DC3		; obtiene en hl una dirección que hay en la tabla de asociación de constantes del script
3E58: 4E          ld   c,(hl)		; devuelve un valor de esa dirección
3E59: E1          pop  hl
3E5A: C9          ret

; ----------------- fin del código relacionado con el intérprete del comportamiento de los personajes -----------------------------

; indica que el personaje no quiere buscar ninguna ruta
3E5B: 3E 01       ld   a,$01
3E5D: 32 9C 3C    ld   ($3C9C),a
3E60: C9          ret

; compara la distancia entre guillermo y el personaje que se le pasa en iy
; si está muy cerca, devuelve 0, en otro caso devuelve algo != 0
; parametros: iy = datos del personaje
3E61: 3A 3A 30    ld   a,($303A)	; a = altura de guillermo
3E64: CD 73 24    call $2473		; b = altura base de la planta en la que está guillermo
3E67: 68          ld   l,b
3E68: FD 7E 04    ld   a,(iy+$04)	; a = altura del personaje
3E6B: CD 73 24    call $2473		; b = altura base de la planta en la que está el personaje
3E6E: 78          ld   a,b
3E6F: BD          cp   l
3E70: C0          ret  nz			; si los personajes no están en la misma planta, sale
3E71: FD 7E 01    ld   a,(iy+$01)	; obtiene la orientación del personaje
3E74: 87          add  a,a			; cada entrada ocupa 4 bytes
3E75: 87          add  a,a
3E76: 21 9F 3D    ld   hl,$3D9F		; indexa en la tabla valores de distancia permisibles según la orientación
3E79: CD 2D 16    call $162D		; hl = hl + a
3E7C: 3A 38 30    ld   a,($3038)	; obtiene la posición x de guillermo
3E7F: 86          add  a,(hl)		; le suma una constante según la orientación
3E80: 23          inc  hl
3E81: FD 96 02    sub  (iy+$02)		; le resta la posición x del personaje
3E84: BE          cp   (hl)
3E85: 30 0E       jr   nc,$3E95		; si la distancia en x entre la posición del abad y de guillermo supera el umbral, salta
3E87: 23          inc  hl
3E88: 3A 39 30    ld   a,($3039)	; obtiene la posición y de guillermo
3E8B: 86          add  a,(hl)		; le suma una constante según la orientación
3E8C: 23          inc  hl
3E8D: FD 96 03    sub  (iy+$03)		; le resta la posición y del personaje
3E90: BE          cp   (hl)
3E91: 30 02       jr   nc,$3E95		; si la distancia en y entre la posición del personaje y de guillermo supera el umbral, salta
3E93: AF          xor  a			; devuelve 0
3E94: C9          ret

3E95: F6 FF       or   $FF
3E97: C9          ret

; si ha llegado al sitio al que quería llegar, avanza el estado
3E98: DD 7E FF    ld   a,(ix-$01)	; obtiene a donde va
3E9B: DD BE FD    cp   (ix-$03)		; lo compara con donde ha llegado
3E9E: C0          ret  nz			; si no ha llegado donde quería ir, sale
3E9F: DD 34 FE    inc  (ix-$02)		; en otro caso avanza el estado
3EA2: AF          xor  a
3EA3: C9          ret

; c = máscara de las puertas que interesan de todas las que pueden abrirse
; modifica la tabla de 0x05cd con información de la tabla de las puertas y entre que habitaciones están
3EA4: DD E5       push ix
3EA6: 3A C0 A2    ld   a,($A2C0)	; lee datos de movimiento de adso
3EA9: 32 9D 3C    ld   ($3C9D),a	; guarda ese valor que luego usará como si fuera un valor aleatorio
3EAC: 3A A6 3C    ld   a,($3CA6)	; obtiene la máscara de las puertas que pueden abrirse
3EAF: A1          and  c
3EB0: 4F          ld   c,a			; c = puertas que puede atravesar el personaje
3EB1: DD 21 67 3C ld   ix,$3C67		; apunta a la tabla con las habitaciones que comunican las puertas
3EB5: 06 06       ld   b,$06		; 6 puertas
3EB7: CB 39       srl  c			; desplaza c a la derecha
3EB9: 3E 3F       ld   a,$3F		; instrucción ccf (complementa el flag de acarreo)
3EBB: 38 01       jr   c,$3EBE		; si puede entrar por esa puerta, salta
3EBD: AF          xor  a
3EBE: 32 D7 3E    ld   ($3ED7),a	; modifica una instrucción
3EC1: 21 CD 05    ld   hl,$05CD		; apunta a las conexiones de las habitaciones de la planta baja
3EC4: DD 7E 00    ld   a,(ix+$00)	; lee el índice en la matriz de habitaciones de la planta baja
3EC7: DD 23       inc  ix
3EC9: FE FF       cp   $FF
3ECB: 28 11       jr   z,$3EDE		; si encuentra 0xff pasa a la siguiente iteración
3ECD: CD 2D 16    call $162D		; hl = hl + a
3ED0: DD 7E 00    ld   a,(ix+$00)	; lee el valor para esa habitación
3ED3: DD 23       inc  ix
3ED5: 5E          ld   e,(hl)		; obtiene las conexiones de esa habitación
3ED6: A7          and  a			; limpia el flag de acarreo
3ED7: 00          nop				; instrucción modificada desde fuera (es ccf o nop) es ccf si el bit de la puerta era 1
3ED8: CD E3 3E    call $3EE3		; si cf = 0 (es decir, si no puede ir a esa puerta), a = a | e. si cf = 1 a = ~a & e
3EDB: 77          ld   (hl),a		; modifica el valor de esa habitación
3EDC: 18 E3       jr   $3EC1
3EDE: 10 D7       djnz $3EB7		; repite hasta acabar las 6 entradas 
3EE0: DD E1       pop  ix
3EE2: C9          ret

; si no hay acarreo, a = a | e. Si hay acarreo, a = ~a & e
3EE3: 30 03       jr   nc,$3EE8
3EE5: 2F          cpl
3EE6: A3          and  e
3EE7: C9          ret
3EE8: B3          or   e
3EE9: C9          ret

; ------------- código y datos relacionados con la búsqueda de caminos en la misma pantalla ----------------------------------

; trata de ejecutar unas acciones dependiendo del momento del día
3EEA: 3A A2 2D    ld   a,($2DA2)	; copia el estado de la reproducción de frases/voces
3EED: 32 A1 2D    ld   ($2DA1),a
3EF0: 2A 88 2D    ld   hl,($2D88)	; hl apunta a los datos del personaje que se muestra en pantalla
3EF3: CB 46       bit  0,(hl)		; si está en medio de una animación, sale
3EF5: C0          ret  nz

3EF6: 3A 9A 3C    ld   a,($3C9A)	; lee si hay que avanzar el momento del día
3EF9: A7          and  a
3EFA: CA F9 5E    jp   z,$5EF9		; si no hay que avanzar el momento del día, trata de ejecutar las acciones programadas según el momento del día

3EFD: 3A A1 2D    ld   a,($2DA1)	; si se está reproduciendo una voz, sale
3F00: A7          and  a
3F01: C0          ret  nz

3F02: 32 9A 3C    ld   ($3C9A),a	; indica que ya no hay que avanzar el momento del día
3F05: CD 3E 55    call $553E		; avanza el momento del día
3F08: C3 F9 5E    jp   $5EF9		; si ha cambiado el momento del día, ejecuta unas acciones dependiendo del momento del día

; pone en el marcador una frase
3F0B: CD 26 50    call $5026        ; pone en el marcador la frase que indica el siguiente byte
	00								; este byte se modifica desde fuera
3F0F: C9          ret

; ejecuta la rutina de hl[c] (a no ser que hl[c] == 0)
3F10: E1          pop  hl			; recupera la dirección de la pila
3F11: 06 01       ld   b,$01		; si entra con c = 0, ejecuta el bucle una vez
3F13: 28 03       jr   z,$3F18
3F15: 41          ld   b,c			; en otro caso, lo ejecuta c veces
3F16: 23          inc  hl
3F17: 23          inc  hl
3F18: 5E          ld   e,(hl)		; de = [hl]
3F19: 23          inc  hl
3F1A: 56          ld   d,(hl)
3F1B: 23          inc  hl
3F1C: 7A          ld   a,d
3F1D: B3          or   e
3F1E: 28 04       jr   z,$3F24		; si [hl] = 0, sale
3F20: 10 F6       djnz $3F18
3F22: EB          ex   de,hl
3F23: E9          jp   (hl)
3F24: E5          push hl
3F25: C9          ret

; ----------------------- código y datos relacionados con la paleta -----------------------------------

; entradas de colores (3, 2, 1, 0 y borde)
3F26: 14 14 14 14 14
3F2B: 0C 14 1C 07 1C
3F30: 14 03 0E 06 14
3F35: 14 00 1D 04 14

; fija los colores del modo de video
3F3A: 21 26 3F    ld   hl,$3F26	; selecciona paleta 0
3F3D: 18 0D       jr   $3F4C
3F3F: 21 2B 3F    ld   hl,$3F2B	; selecciona paleta 1
3F42: 18 08       jr   $3F4C
3F44: 21 30 3F    ld   hl,$3F30	; selecciona paleta 2
3F47: 18 03       jr   $3F4C
3F49: 21 35 3F    ld   hl,$3F35	; selecciona paleta 3

; fija una paleta gráfica en modo 1
3F4C: 3E 04       ld   a,$04	; 4 colores
3F4E: 06 7F       ld   b,$7F	; seleccion de pluma
3F50: 4F          ld   c,a
3F51: 0D          dec  c
3F52: ED 49       out  (c),c	; selecciona color i
3F54: 4E          ld   c,(hl)	: obtiene el color
3F55: 23          inc  hl
3F56: CB F1       set  6,c		; fija el color i con el valor leido (color hardware de la paleta hardware)
3F58: ED 49       out  (c),c
3F5A: 3D          dec  a
3F5B: 20 F3       jr   nz,$3F50	; repite el proceso

3F5D: 0E 10       ld   c,$10
3F5F: ED 49       out  (c),c	; selecciona el borde
3F61: 4E          ld   c,(hl)
3F62: CB F1       set  6,c
3F64: ED 49       out  (c),c	; fija el color del borde
3F66: C9          ret

; ----------------------- fin del código y los datos relacionados con la paleta -----------------------------------

; -------------------- código y datos para el efecto de la espiral -----------------------

; datos auxiliares para trazar la espiral cuadrada
3F67: 48 54 CD C1

; rutina encargada de dibujar y de borra la espiral
3F6B: AF          xor  a
3F6C: DD E5       push ix
3F6E: 1E FF       ld   e,$FF
3F70: CD 7F 3F    call $3F7F		; dibuja la espiral
3F73: 1E 00       ld   e,$00
3F75: CD 7F 3F    call $3F7F		; borra la espiral
3F78: DD E1       pop  ix
3F7A: AF          xor  a
3F7B: 32 75 2D    ld   ($2D75),a	; indica un cambio de pantalla
3F7E: C9          ret

; dibuja la espiral del color indicado por e
3F7F: 21 00 00    ld   hl,$0000			; posición inicial (00, 00)
3F82: DD 21 67 3F ld   ix,$3F67			; graba los datos de ayuda para trazar la espiral cuadrada
3F86: DD 36 00 3F ld   (ix+$00),$3F		; ancho de izquierda a derecha
3F8A: DD 36 01 4F ld   (ix+$01),$4F		; alto de arriba a abajo
3F8E: DD 36 02 3F ld   (ix+$02),$3F		; ancho derecha a izquierda
3F92: DD 36 03 4E ld   (ix+$03),$4E		; alto de abajo a arriba

3F96: 06 20       ld   b,$20			; 32 veces
3F98: AF          xor  a				; a = 0
3F99: C5          push bc
3F9A: DD 46 00    ld   b,(ix+$00)		; lee el contador del ancho y salta
3F9D: 18 07       jr   $3FA6

3F9F: C5          push bc
3FA0: DD 46 00    ld   b,(ix+$00)
3FA3: DD 35 00    dec  (ix+$00)

; dibuja una tira (de color a) de b*8 pixels de ancho y 2 de alto (de izquierda a derecha)
3FA6: DD 35 00    dec  (ix+$00)
3FA9: CD E6 3F    call $3FE6			; pasa hl a coordenadas de pantalla y graba a en esa línea y en la siguiente
3FAC: 2C          inc  l				; pasa al siguiente byte en X
3FAD: 10 FA       djnz $3FA9			; repite hasta que b = 0

; dibuja una tira (de color a) de 8 pixels de ancho y [ix+0x01]*2 de alto (de arriba a abajo)
3FAF: DD 46 01    ld   b,(ix+$01)
3FB2: DD 35 01    dec  (ix+$01)
3FB5: DD 35 01    dec  (ix+$01)
3FB8: CD E6 3F    call $3FE6			; pasa hl a coordenadas de pantalla y graba a en esa línea y en la siguiente
3FBB: 24          inc  h				; pasa a las 2 líneas siguientes en Y
3FBC: 24          inc  h
3FBD: 10 F9       djnz $3FB8

; dibuja una tira (de color a) de [ix+0x02]*8 pixels de ancho y 2 de alto (de derecha a izquierda)
3FBF: DD 46 02    ld   b,(ix+$02)
3FC2: DD 35 02    dec  (ix+$02)
3FC5: DD 35 02    dec  (ix+$02)
3FC8: CD E6 3F    call $3FE6			; pasa hl a coordenadas de pantalla y graba a en esa línea y en la siguiente
3FCB: 2D          dec  l				; retrocede en X
3FCC: 10 FA       djnz $3FC8

; dibuja una tira (de color a) de 8 pixels de ancho y [ix+0x03]*2 de alto (de abajo a arriba)
3FCE: DD 46 03    ld   b,(ix+$03)
3FD1: DD 35 03    dec  (ix+$03)
3FD4: DD 35 03    dec  (ix+$03)
3FD7: CD E6 3F    call $3FE6			; pasa hl a coordenadas de pantalla y graba a en esa línea y en la siguiente
3FDA: 25          dec  h				; pasa a las 2 coordenadas anteriores en Y
3FDB: 25          dec  h
3FDC: 10 F9       djnz $3FD7

3FDE: C1          pop  bc				; recupera el contador
3FDF: AB          xor  e				; cambia el color de las tiras
3FE0: 10 BD       djnz $3F9F			; repite hasta que se acabe

3FE2: CD E6 3F    call $3FE6			; pasa hl a coordenadas de pantalla y graba a en esa línea y en la siguiente
3FE5: C9          ret

; pasa hl a coordenadas de pantalla y graba a en esa línea y en la siguiente
3FE6: E5          push hl
3FE7: C5          push bc
3FE8: F5          push af
3FE9: CD 42 3C    call $3C42		; dado hl (coordenadas Y,X), calcula el desplazamiento correspondiente en pantalla
3FEC: F1          pop  af
3FED: 77          ld   (hl),a		; graba a
3FEE: F5          push af
3FEF: CD 4D 3A    call $3A4D		; pasa a la siguiente línea de pantalla
3FF2: F1          pop  af
3FF3: 77          ld   (hl),a		; graba a
3FF4: C1          pop  bc
3FF5: E1          pop  hl
3FF6: C9          ret

; -------------------- fin del código y los datos para el efecto de la espiral -----------------------

3FF7: 3A FA 2D    ld   a,($2DFA)	; lee si malaquías tiene la lámpara
3FFA: E6 80       and  $80
3FFC: 2A 87 3C    ld   hl,($3C87)	; obtiene el tiempo de uso de la lámpara
3FFF: B4          or   h

; abadia2.bin (0x4000-0x7fff)
4000: B5          or   l
4001: C8          ret  z			; si malaquías no tiene la lámpara y no se ha usado, sale

4002: AF          xor  a
4003: 32 91 3C    ld   ($3C91),a	; indica que se ha usado la lámpara
4006: 6F          ld   l,a
4007: 67          ld   h,a
4008: 22 87 3C    ld   ($3C87),hl	; ponea a 0 el contador de uso de la lámpara
400B: 32 8B 3C    ld   ($3C8B),a	; indica que no se está usando la lámpara
400E: 21 F3 2D    ld   hl,$2DF3
4011: CB BE       res  7,(hl)		; indica que adso no tiene la lámpara
4013: 21 FA 2D    ld   hl,$2DFA
4016: CB BE       res  7,(hl)		; indica que malaquías no tiene la lámpara
4018: CD 45 41    call $4145		; copia en 0x3030 -> 00 00 00 00 00 (limpia los datos de posición de la lámpara)
		3030
		00 00 00 00 00

; deja la llave del pasadizo en la mesa de malaquías
4022: 3A FD 2D    ld   a,($2DFD)	; obtiene los objetos de malaquías
4025: CB 4F       bit  1,a
4027: C8          ret  z			; si no tiene la llave del pasadizo de detrás de la cocina, sale
4028: E6 FD       and  $FD
402A: 32 FD 2D    ld   ($2DFD),a	; le quita la llave del pasadizo de detrás de la cocina
402D: CD 45 41    call $4145		; copia en 0x3026 -> 00 00 35 35 13 (pone la llave3 en la mesa)
		3026
		00 00 35 35 13

4037: 3A EF 2D    ld   a,($2DEF)	; obtiene los objetos que tenemos
403A: E6 DF       and  $DF
403C: 32 EF 2D    ld   ($2DEF),a	; quita las gafas de los objetos que tenemos
403F: 3A 0B 2E    ld   a,($2E0B)	; obtiene los objetos de berengario
4042: E6 DF       and  $DF
4044: 32 0B 2E    ld   ($2E0B),a	; le quita las gafas a berengario
4047: DD E5       push ix
4049: CD D4 51    call $51D4		; dibuja los objetos que tenemos en el marcador
404C: DD E1       pop  ix
404E: CD 45 41    call $4145
		3012						; copia en 0x3012 -> 00 00 00 00 00 (desaparecen las gafas)
		00 00 00 00 00

4058: 21 9B 30    ld   hl,$309B		; puntero a los datos gráficos de la cara de berengario
405B: 11 93 B2    ld   de,$B293		; puntero a los datos gráficos de la cara de bernardo gui
405E: CD A2 40    call $40A2		; modifica la cara apuntada por hl con la que se le pasa en de. Además llama a 0x4145 con lo que hay a continuación
		3073						; coloca la posición incial de bernardo gui en la abadía
		00 88 88 02 00

4068: 21 9D 30    ld   hl,$309D		; puntero a los datos gráficos de la cara de severino
406B: 11 F7 B2    ld   de,$B2F7		; puntero a los datos gráficos de la cara de jorge
406E: CD A2 40    call $40A2		; modifica la cara apuntada por hl con la que se le pasa en de. Además llama a 0x4145 con lo que hay a continuación
		3082						; coloca la posición incial de jorge en la abadía (detrás del espejo)
		03 12 65 18 00

4078: 2A 7E 30    ld   hl,($307E)	; lee la dirección de los datos que guían a berengario
407B: 36 10       ld   (hl),$10		; escribe el valor para que piense un nuevo movimiento
407D: AF          xor  a
407E: 32 7C 30    ld   ($307C),a	; para el contador y el índice de los datos que guían al personaje
4081: 32 8C 30    ld   ($308C),a
4084: 21 9B 30    ld   hl,$309B		; puntero a los datos gráficos de la cara de berengario
4087: 11 F7 B2    ld   de,$B2F7		; puntero a los datos gráficos de la cara de jorge
408A: CD A2 40    call $40A2		; modifica la cara apuntada por hl con la que se le pasa en de. Además llama a 0x4145 con lo que hay a continuación
		3073
		00 C8 24 00 00

4094: CD C4 36    call $36C4		; rota los gráficos de los monjes si fuera necesario
4097: 21 9B 30    ld   hl,$309B		; puntero a los datos gráficos de la cara de berengario
409A: 11 5B B3    ld   de,$B35B		; puntero a los datos gráficos de la cara del encapuchado

; modifica la cara apuntada por hl con la que se le pasa en de. Además llama a 0x4145 con lo que hay a continuación
409D: 73          ld   (hl),e		; [hl] = de
409E: 23          inc  hl
409F: 72          ld   (hl),d
40A0: 23          inc  hl
40A1: C9          ret

; rota los gráficos de los monjes si fuera necesario y modifica la cara apuntada por hl con la que se le pasa en de. Además llama a 0x4145 con lo que hay a continuación
40A2: E5          push hl
40A3: D5          push de
40A4: CD C4 36    call $36C4		; rota los gráficos de los monjes si fuera necesario
40A7: D1          pop  de
40A8: E1          pop  hl
40A9: CD 9D 40    call $409D		; [hl] = de
40AC: C3 45 41    jp   $4145		; copia a la dirección indicada despues de la pila 5 bytes que siguen a la dirección (pero del llamante)

; llamado desde el comportamiento de jorge
40AF: DD E5       push ix
40B1: FD E5       push iy
40B3: DD 21 0F 2E ld   ix,$2E0F		; apunta a la tabla de datos de los objetos de severino
40B7: 18 12       jr   $40CB


40B9: 3A 04 2E    ld   a,($2E04)	; si el abad no tiene el pergamino, sale
40BC: E6 10       and  $10
40BE: C8          ret  z

40BF: AF          xor  a
40C0: 32 06 2E    ld   ($2E06),a	; modifica la máscara de objetos para no coger el pergamino
40C3: DD E5       push ix
40C5: FD E5       push iy
40C7: DD 21 01 2E ld   ix,$2E01		; apunta a la tabla de datos de los objetos del abad

40CB: CD 77 52    call $5277		; deja el pergamino
40CE: FD E1       pop  iy
40D0: DD E1       pop  ix
40D2: AF          xor  a
40D3: 32 93 3C    ld   ($3C93),a	; pone a 0 el contador que se incrementa si no pulsamos los cursores
40D6: C9          ret

40D7: 3E 10       ld   a,$10
40D9: C9          ret

40DA: 32 06 2E    ld   ($2E06),a


; pone el pergamino en la habitación de detrás del espejo
40DD: CD 45 41    call $4145			; copia en 0x3017 -> 00	00 18 64 18
		3017
		00	00 18 64 18

40E7: CD 45 41    call $4145			; copia en 0x3017 -> 00 00 58 3C 02
		3017
		00 00 58 3C 02

40F1: 3E 80       ld   a,$80
40F3: 32 12 2E    ld   ($2E12),a		; le da a jorge el libro

; deja el libro fuera de la abadía
40F6: CD 45 41    call $4145			; copia en 0x3008 -> 80 00 0F 2E 00
		3008
		80 00 0F 2E 00

4100: 3A 91 3C    ld   a,($3C91)		; si no ha desaparecido la lámpara, sale
4103: A7          and  a
4104: C0          ret  nz
4105: 3C          inc  a
4106: 32 91 3C    ld   ($3C91),a		; indicar que la lámpara no está desaparecida

; pone la lámpara en la cocina
4109: CD 45 41    call $4145			; copia en 0x3030 -> 00 00 5A 2A 04
		3030
		00 00 5A 2A 04

; pone la llave de la habitación del abad en el altar
4113: CD 45 41    call $4145			; copia en 0x301C -> 00 00 89 3E 08
		301C
		00 00 89 3E 08

; desaparece la llave de la habitación del abad
411D: CD 45 41    call $4145			; copia en 0x301C -> 00 00 00 00 00
		301C
		00 00 00 00 00 00

; pone la llave 2 en la mesa de malaquías
4127: CD 45 41    call $4145			; copia en 0x3021 -> 00 00 35 35 13
		3021
		00 00 35 35 13

; pone las gafas de guillermo en la habitación iluminada del laberinto
4131: CD 45 41    call $4145			; copia en 0x3012 -> 00 00 1B 23 18
		3012
		00 00 1B 23 18

413B: CD 45 41    call $4145			; copia en 0x301C -> 00 00 00 00 00
		301C
		00 00 00 00 00

; recupera la dirección de pila y copia los 5 bytes siguientes de la pila a la dirección de destino leida de la pila
4145: E1          pop  hl			; recupera la dirección de pila
4146: 5E          ld   e,(hl)		; obtiene una dirección
4147: 23          inc  hl
4148: 56          ld   d,(hl)
4149: 23          inc  hl
414A: 01 05 00    ld   bc,$0005		; copia 5 bytes a esa dirección
414D: ED B0       ldir
414F: C9          ret

4150: 30 0C       jr   nc,$415E		; si no si tenemos los guantes o el estado de jorge no es 0x0d, 0x0e o 0x0f, salta

; aqui llega si tenemos los guantes y el estado de jorge es 0x0d, 0x0e o 0x0f
4152: 3E 32       ld   a,$32
4154: 32 93 3C    ld   ($3C93),a	; indica que no hay que esperar para mostrar a jorge
4157: 3E 05       ld   a,$05
4159: 32 92 3C    ld   ($3C92),a	; indica que la cámara siga a jorge si no se mueve guillermo
415C: AF          xor  a
415D: C9          ret

; si no si tenemos los guantes o el estado de jorge no es 0x0d, 0x0e o 0x0f, comprueba si se pulsaron los cursores de movimiento de guillermo
415E: AF          xor  a
415F: CD 82 34    call $3482		; si se pulsa cursor arriba sale
4162: C0          ret  nz
4163: 3E 08       ld   a,$08
4165: CD 82 34    call $3482		; si se pulsa cursor izquierda sale
4168: C0          ret  nz
4169: 3E 01       ld   a,$01		; comprueba si se pulsa cursor derecha
416B: C3 82 34    jp   $3482

416E: 00          nop				; puesto a 0 al pulsar ctrl+f9

; si tenemos los guantes y el estado de jorge es 0x0d, 0x0e o 0x0f (está hablando sobre el libro), sale con cf = 1, en otro caso con cf = 0
416F: 3A EF 2D    ld   a,($2DEF)	; si no tenemos los guantes, sale
4172: E6 40       and  $40
4174: C8          ret  z

4175: 3A 00 3D    ld   a,($3D00)	; si el estado de jorge es 0x0d, 0x0e o 0x0f, sale con cf = 1, en otro caso con cf = 0
4178: FE 0D       cp   $0D
417A: 37          scf
417B: C8          ret  z

417C: FE 0E       cp   $0E
417E: 37          scf
417F: C8          ret  z

4180: FE 0F       cp   $0F
4182: 37          scf
4183: C8          ret  z

4184: A7          and  a
4185: C9          ret

; comprueba si hay que cambiar el personaje al que sigue la cámara y calcula los bonus que hemos conseguido (interpretado)
4186: CD 91 56    call $5691		; comprueba si hay que cambiar el personaje al que sigue la cámara y calcula los bonus que hemos conseguido (interpretado)
4189: CD 6F 41    call $416F		; si tenemos los guantes y el estado de jorge es 0x0d, 0x0e o 0x0f, sale con cf = 1, en otro caso con cf = 0
418C: CD 50 41    call $4150		; comprueba si se pulsaron los cursores (cf = 1)
418F: 3E 00       ld   a,$00
4191: 20 24       jr   nz,$41B7		; si se ha pulsado el cursor arriba, izquierda o derecha, hace que se siga a guillermo
4193: 3A 93 3C    ld   a,($3C93)	; [0x3c93]++
4196: 3C          inc  a
4197: 32 93 3C    ld   ($3C93),a
419A: FE 32       cp   $32			; si es < 0x32, sale
419C: D8          ret  c

419D: 3D          dec  a
419E: 32 93 3C    ld   ($3C93),a	; deja el contador como estaba
41A1: 3A A1 2D    ld   a,($2DA1)	; lee el estado de las frases
41A4: A7          and  a
41A5: C4 BF 41    call nz,$41BF		; si se está mostrando una frase, restaura el valor del contador de espera del bucle principal
41A8: CC C2 41    call z,$41C2		;  en otro caso, pone a 0 el contador del bucle principal (para que no se espere nada)
41AB: CD 07 10    call $1007		; inicia un sonido en el canal 1
41AE: 3A 8F 3C    ld   a,($3C8F)	; obtiene el personaje al que sigue la cámara
41B1: 4F          ld   c,a
41B2: 3A 92 3C    ld   a,($3C92)	; lee el personaje al que se sigue si guillermo se está quieto
41B5: B9          cp   c
41B6: C8          ret  z			; si son iguales, sale

; aqui también llega si se ha pulsado el cursor arriba, izquierda o derecha, salta
41B7: 32 8F 3C    ld   ($3C8F),a	; hace que la cámara siga al personaje indicado en a
41BA: 32 93 3C    ld   ($3C93),a	; actualiza el contador con el valor introducido
41BD: A7          and  a
41BE: C0          ret  nz			; si el personaje a seguir no es el nuestro, sale

; restaura el valor del contador de espera del bucle principal
41BF: 3A 49 BF    ld   a,($BF49)
41C2: 32 18 26    ld   ($2618),a	; restaura el valor del contador de espera del bucle principal
41C5: C9          ret

; pone a en 0, para que nunca de como pulsada una tecla
41C6: AF          xor  a
41C7: C9          ret

; lee el primer byte de pila y lo graba en 0x3c93
41C8: E1          pop  hl			; obtiene la dirección de retorno
41C9: 7E          ld   a,(hl)		; lee el primer byte y lo graba en 0x3c93
41CA: 23          inc  hl
41CB: 32 93 3C    ld   ($3C93),a
41CE: E5          push hl
41CF: C9          ret

41D0: 78          ld   a,b
41D1: 3D          dec  a
41D2: 32 8F 3C    ld   ($3C8F),a
41D5: C9          ret

; comprueba si hay que cambiar el personaje al que sigue la cámara y calcula los bonus que hemos conseguido (interpretado)
41D6: CD 86 41    call $4186		; comprueba si hay que cambiar el personaje al que sigue la cámara y calcula los bonus que hemos conseguido (interpretado)
41D9: 21 F1 41    ld   hl,$41F1		; hl apunta a la tabla de punteros de los datos de los personajes
41DC: 3A 8F 3C    ld   a,($3C8F)	; lee el personaje al que sigue la cámara
41DF: 87          add  a,a
41E0: CD 2D 16    call $162D		; indexa en la tabla
41E3: 5E          ld   e,(hl)
41E4: 23          inc  hl
41E5: 56          ld   d,(hl)		; de = dirección de los datos del personaje que sigue la camara
41E6: ED 53 88 2D ld   ($2D88),de
41EA: C9          ret

; aquí no se llega nunca???
41EB: 31 38 39    ld   sp,$3938
41EE: 41          ld   b,c
41EF: 40          ld   b,b
41F0: 12          ld   (de),a

; tabla con punteros a los datos de los personajes relacionado con 0x3c8f
41F1: 	3036 -> 0x00 características de guillermo
		3045 -> 0x01 características de adso
		3054 -> 0x02 características de malaquías
		3063 -> 0x03 características del abad
		3072 -> 0x04 características de berengario
		3081 -> 0x05 características de severino

; comprueba si se está agotando la lámpara
41FD: 3A 8D 3C    ld   a,($3C8D)	; lee el estado de la lámpara
4200: 4F          ld   c,a
4201: 3A F3 2D    ld   a,($2DF3)
4204: E6 80       and  $80			; si adso no tiene la lámpara, sale
4206: C8          ret  z

4207: 3A 8B 3C    ld   a,($3C8B)	; si no ha entrado al laberinto/la lampara no se está usando, sale
420A: A7          and  a
420B: C8          ret  z

420C: 3A 6C 15    ld   a,($156C)	; si la pantalla está iluminada, sale
420F: A7          and  a
4210: C8          ret  z

4211: 2A 87 3C    ld   hl,($3C87)	; incrementa el tiempo de uso de la lámpara
4214: 23          inc  hl
4215: 22 87 3C    ld   ($3C87),hl
4218: 7D          ld   a,l
4219: A7          and  a
421A: C0          ret  nz			; si l no es 0, sale

421B: 79          ld   a,c			; a = estado de la lámpara
421C: A7          and  a
421D: C0          ret  nz			; si no ha procesado el cambiado el estado de la lámpara, sale

421E: 7C          ld   a,h			; si el tiempo de uso de la lámpara ha llegado a 0x3xx, sale con c = 1 (se está agotando la lámpara)
421F: 0E 01       ld   c,$01
4221: FE 03       cp   $03
4223: C8          ret  z
4224: 0C          inc  c			; si el tiempo de uso de la lámpara ha llegado a 0x6xx, sale con c = 2 (se ha agotado la lámpara)
4225: FE 06       cp   $06
4227: C8          ret  z
4228: 0E 00       ld   c,$00		; en otro caso, sale con c = 0
422A: C9          ret

; comprueba si se está acabando la noche
422B: 0E 00       ld   c,$00
422D: 2A 86 2D    ld   hl,($2D86)	; obtiene la cantidad de tiempo a esperar para que avance el momento del día
4230: 7C          ld   a,h
4231: B5          or   l
4232: C8          ret  z			; si es 0, sale
4233: 7D          ld   a,l
4234: A7          and  a
4235: C0          ret  nz			; en otro caso, espera si la parte inferior del contador para que pase el momento del día no es 0, sale

4236: 3A 81 2D    ld   a,($2D81)	; si no es de noche, sale
4239: A7          and  a
423A: C0          ret  nz

423B: 7C          ld   a,h			; si la parte superior del contador es 2, sale con c = 1
423C: 0C          inc  c
423D: FE 02       cp   $02
423F: C8          ret  z

4240: 0D          dec  c
4241: A7          and  a
4242: C0          ret  nz			; en otro caso, si no es 0, sale con c = 0

4243: 3C          inc  a
4244: 32 9A 3C    ld   ($3C9A),a	; si es 0, incrementa el momento del día y sale con c = 0
4247: C9          ret

; apaga la luz de la pantalla y le quita el libro a guillermo
4248: 3E 01       ld   a,$01
424A: 32 6C 15    ld   ($156C),a	; indica que la pantalla no está iluminada
424D: CD 6C 1A    call $1A6C		; oculta el área de juego
4250: 3A EF 2D    ld   a,($2DEF)	; le quita el libro a guillermo
4253: E6 7F       and  $7F
4255: 32 EF 2D    ld   ($2DEF),a
4258: 4F          ld   c,a
4259: 3E 80       ld   a,$80
425B: CD DA 51    call $51DA		; actualiza el marcador el marcador para que no se muestre el libro
425E: CD 45 41    call $4145		; copia en 0x3008 -> 00 00 00 00 00 (hace desaparecer el libro)
		3008
		00 00 00 00 00
4268: C9          ret

; ---------------- código para cálcular el porcentaje de misión completada ----------------------------------

; calcula el porcentaje de misión completada y lo guarda en 0x431e
4269: 3A A7 3C    ld   a,($3CA7)	; si 0x3ca7 es 0, muestra el final
426C: A7          and  a
426D: CA 68 38    jp   z,$3868
4270: 3A 80 2D    ld   a,($2D80)	; obtiene el número de día
4273: 3D          dec  a			; ajusta entre 0 y 6
4274: 47          ld   b,a
4275: 87          add  a,a
4276: 4F          ld   c,a
4277: 87          add  a,a
4278: 80          add  a,b
4279: 81          add  a,c
427A: 4F          ld   c,a			; c = 7*(dia - 1)
427B: 3A 81 2D    ld   a,($2D81)	; obtiene el momento del día
427E: 81          add  a,c			; a = 7*(dia - 1) + momento del día
427F: 2A BE 2D    ld   hl,($2DBE)	; lee los bonus conseguidos
4282: 06 10       ld   b,$10		; comprueba 16 bits
4284: 29          add  hl,hl		; hl = hl*2
4285: 30 02       jr   nc,$4289		; si no estaba puesto el bit actual, salta
4287: C6 04       add  a,$04		; por cada bonus, suma 4
4289: 10 F9       djnz $4284		; repite hasta probar los 16 bits del número
428B: FE 05       cp   $05
428D: 30 01       jr   nc,$4290		; si no hemos obtenido una puntuación >= 5, pone la puntuación a 0
428F: AF          xor  a

; aquí llega con a = puntuación obtenida
4290: 01 00 00    ld   bc,$0000		; inicialmente la puntuación = 00
4293: 47          ld   b,a
4294: D6 0A       sub  $0A			; resta 10 a los bonus obtenidos
4296: 38 03       jr   c,$429B		; si el número que quedaba era < 10, salta
4298: 0C          inc  c			; incrementa las decenas
4299: 18 F8       jr   $4293		; repite mientras queden decenas

429B: 21 30 30    ld   hl,$3030		; hl = caracteres ASCII del 00
429E: 09          add  hl,bc		; suma la puntuación obtenida
429F: 22 A9 42    ld   ($42A9),hl	; modifica los datos de la llamada a 0x4145
42A2: CD 45 41    call $4145		; copia en 0x431E -> 20 20 3X 3Y 20 y sale, donde XY es el porcentaje de resolución del juego
		431E
		20 20 30 30 20


; actualiza los bonus si tenemos los guantes, las llaves y algo mas y si se está leyendo el libro sin los guantes, mata a guillermo
42AC: 3A EF 2D    ld   a,($2DEF)	; lee los objetos de guillermo
42AF: 4F          ld   c,a
42B0: E6 4C       and  $4C			; se queda solo con los guantes y las 2 primeras llaves
42B2: 47          ld   b,a
42B3: 3A F6 2D    ld   a,($2DF6)	; lee los objetos de adso
42B6: E6 02       and  $02			; se queda con la llave 3
42B8: B0          or   b
42B9: 47          ld   b,a
42BA: 3A BE 2D    ld   a,($2DBE)	; lee los bonus
42BD: B0          or   b
42BE: 32 BE 2D    ld   ($2DBE),a	; actualiza los bonus
42C1: 79          ld   a,c
42C2: E6 80       and  $80
42C4: C8          ret  z			; si no tenemos el libro, sale

42C5: CB 71       bit  6,c			; si tenemos los guantes, sale
42C7: C0          ret  nz

42C8: 3A 85 3C    ld   a,($3C85)	; incrementa el contador del tiempo que está leyendo el libro sin guantes
42CB: 3C          inc  a
42CC: 32 85 3C    ld   ($3C85),a
42CF: C0          ret  nz

42D0: 3A 19 2E    ld   a,($2E19)	; a = posición en y del sprite de guillermo
42D3: CB 3F       srl  a			; a = a/2
42D5: 32 8F 28    ld   ($288F),a	; cambia el estado de guillermo
42D8: 3E FE       ld   a,$FE
42DA: 32 B1 28    ld   ($28B1),a	; modifica una instrucción que hace que se sume a la posición y del sprite de guillermo -2
42DD: 3E 01       ld   a,$01
42DF: 32 97 3C    ld   ($3C97),a	; mata a guillermo
42E2: CD 1B 50    call $501B		; escribe en el marcador una frase
42E5: 22 							ESTAIS MUERTO, FRAY GUILLERMO, HABEIS CAIDO EN LA TRAMPA
42E6: C9          ret

; si guillermo está muerto, calcula el % de misión completado y lo muestra por pantalla
42E7: 3A 97 3C    ld   a,($3C97)	; lee si guillermo está vivo y si es así, sale
42EA: A7          and  a
42EB: C8          ret  z

42EC: 3E 80       ld   a,$80
42EE: 32 8F 3C    ld   ($3C8F),a	; indica que la camara sigua a guillermo y que lo haga ya
42F1: 3A A1 2D    ld   a,($2DA1)	; si está mostrando una frase/reproduciendo una voz, sale
42F4: A7          and  a
42F5: C0          ret  nz
42F6: CD 6C 1A    call $1A6C		; oculta el área de juego
42F9: CD 69 42    call $4269		; calcula el porcentaje de misión completada y lo guarda en 0x431e
42FC: 21 10 20    ld   hl,$2010		; (h = y en pixels, l = x en bytes) (x = 64, y = 32)
42FF: 22 97 2D    ld   ($2D97),hl	; modifica la variable usada como la dirección para poner caracteres en pantalla
4302: CD EE 4F    call $4FEE		; imprime la frase que sigue a la llamada en la posición de pantalla actual
	48 41 53 20 52 45 53 55 45 4C 54 4F 20 45 4C FF
	HAS RESUELTO EL

4315: 21 0E 30    ld   hl,$300E		; (h = y en pixels, l = x en bytes) (x = 56, y = 48)
4318: 22 97 2D    ld   ($2D97),hl	; modifica la variable usada como la dirección para poner caracteres en pantalla
431B: CD EE 4F    call $4FEE		; imprime la frase que sigue a la llamada en la posición de pantalla actual
	; aquí copia los datos para poner la puntuación del marcador
	20 20 30 20 20
	50 4F 52 20 43 49 45 4E 54 4F FF
	POR CIENTO

432E: 21 0C 40    ld   hl,$400C		; (h = y en pixels, l = x en bytes) (x = 48, y = 64)
4331: 22 97 2D    ld   ($2D97),hl	; modifica la variable usada como la dirección para poner caracteres en pantalla
4334: CD EE 4F    call $4FEE		; imprime la frase que sigue a la llamada en la posición de pantalla actual
	44 45 20 4C 41 20 49 4E 56 45 53 54 49 47 41 43 49 4F 4E FF
	DE LA INVESTIGACION

434B: 21 06 80    ld   hl,$8006		; (h = y en pixels, l = x en bytes) (x = 24, y = 128)
434E: 22 97 2D    ld   ($2D97),hl	; modifica la variable usada como la dirección para poner caracteres en pantalla
4351: CD EE 4F    call $4FEE		; imprime la frase que sigue a la llamada en la posición de pantalla actual
	50 55 4C 53 41 20 45 53 50 41 43 49 4F 20 50 41 52 41 20 45 4D 50 45 5A 41 52 FF
	PULSA ESPACIO PARA EMPEZAR

436F: CD BC 32    call $32BC		; lee los buffers de teclado
4372: 3E 2F       ld   a,$2F
4374: CD 82 34    call $3482
4377: 28 F6       jr   z,$436F		; espera a que se pulse espacio
4379: E1          pop  hl
437A: C3 09 25    jp   $2509		; salta a lo que hay depués de la inicialización

; ---------------- fin del cálculo del porcentaje de misión completada ----------------------------------

; deshabilita el contador para que avance el momento del día de forma automática
437D: 21 00 00    ld   hl,$0000
4380: 22 86 2D    ld   ($2D86),hl
4383: C9          ret

4384: 00          nop				; indica que malaquías está ascendiendo mientras se está muriendo
4385: 00          nop				; no usado (quizas se usaba antes para algo???)

4386: 3A 85 43    ld   a,($4385)	; si ??? no es 0, sale
4389: E6 0F       and  $0F
438B: 32 85 43    ld   ($4385),a
438E: C0          ret  nz
438F: 3E 01       ld   a,$01
4391: 32 84 43    ld   ($4384),a	; indica que malaquías está ascendiendo mientras se está muriendo
4394: 3A 58 30    ld   a,($3058)	; incrementa la altura de malaquías
4397: 3C          inc  a
4398: 32 58 30    ld   ($3058),a
439B: FE 14       cp   $14			; si es < 20, sale
439D: D8          ret  c

; aquí llega cuando malaquías ha desaparecido de la pantalla
439E: AF          xor  a
439F: 32 56 30    ld   ($3056),a	; pone a 0 la posición x de malaquías
43A2: 3E 02       ld   a,$02
43A4: 32 A2 3C    ld   ($3CA2),a	; indica que malaquías ha muerto
43A7: AF          xor  a
43A8: 32 A8 3C    ld   ($3CA8),a	; indica que malaquías ha llegado a la iglesia
43AB: C9          ret

; comprueba que guillermo esté en la posición correcta de misa
43AC: 11 84 4B    ld   de,$4B84		; de = posición de guillermo en misa
43AF: CD C4 43    call $43C4		; comprueba que guillermo esté en la posición determinada por de
43B2: A7          and  a
43B3: C0          ret  nz
43B4: 11 80 30    ld   de,$3080		; de = posición imposible???
43B7: 18 0B       jr   $43C4		; comprueba que guillermo esté en la posición determinada por de

43B9: 11 38 39    ld   de,$3938		; de = posición de guillermo en el refectorio
43BC: CD C4 43    call $43C4		; comprueba que guillermo esté en la posición determinada por de
43BF: A7          and  a
43C0: C0          ret  nz
43C1: 11 20 30    ld   de,$3020		; de = posición imposible???

; comprueba que guillermo esté en una posición determinada (de la planta baja) indicada por de
; devuelve en c: 0, si no está en la habitación de la posición, 2 si está en la habitación de la posición y 1 si está en la posición indicada y con la orientación correcta
43C4: 0E 00       ld   c,$00		; c = 0, no está en su sitio
43C6: 3A 3A 30    ld   a,($303A)	; obtiene la altura de guillermo
43C9: FE 0B       cp   $0B
43CB: 30 1B       jr   nc,$43E8		; si no está en la planta baja (altura >= 0x0b), sale actualizando 0x3c9b
43CD: 3A 38 30    ld   a,($3038)	; lee la posición en x
43D0: AB          xor  e
43D1: 5F          ld   e,a
43D2: 3A 39 30    ld   a,($3039)	; lee la posición en y
43D5: AA          xor  d
43D6: B3          or   e
43D7: FE 10       cp   $10
43D9: 30 0D       jr   nc,$43E8		; si la posición no está en la misma habitación (a >= 0x10), sale actualizando 0x3c9b
43DB: 0E 02       ld   c,$02		; c = 0x02, en la habitación pero no en la posición correcta
43DD: A7          and  a
43DE: 20 08       jr   nz,$43E8		; si no es 0, sale
43E0: 3A 37 30    ld   a,($3037)	; lee la orientación del personaje
43E3: FE 01       cp   $01
43E5: 20 01       jr   nz,$43E8		; si no es igual, sale actualizando 0x3c9b
43E7: 0D          dec  c			; c = 1

43E8: 79          ld   a,c
43E9: 32 9B 3C    ld   ($3C9B),a	; graba el resultado
43EC: C9          ret


43ED: 3A A5 3C    ld   a,($3CA5)
43F0: E6 01       and  $01
43F2: C0          ret  nz			; si ha advertido al abad, sale
43F3: 3A EF 2D    ld   a,($2DEF)	; lee los objetos que tiene guillermo
43F6: E6 10       and  $10
43F8: FE 10       cp   $10
43FA: C8          ret  z			; si tiene el pergamino, sale
43FB: 3A 17 30    ld   a,($3017)	; si el pergamino está cogido, sale
43FE: CB 7F       bit  7,a
4400: C0          ret  nz
4401: 3A 1B 30    ld   a,($301B)	; obtiene la altura del pergamino
4404: CD 73 24    call $2473		; dependiendo de la altura, devuelve la altura base de la planta en b
4407: 78          ld   a,b
4408: A7          and  a
4409: C9          ret

440A: 05CD		; dirección de la tabla de conexiones de la planta en la que está el personaje

; tabla de longitudes de comandos según la orientación
440C: 	01 03 06 03

; tabla de comandos para girar
4410: 	8800 -> 1000 1000 0000 0000 -> comando para avanzar una posición hacia delante
		5100 -> 0101 0001 0000 0000 -> comando para girar a la derecha
		6E20 -> 0110 1110 0010 0000 -> comandos para girar 2 veces a la izquierda
		7100 -> 0111 0001 0000 0000 -> comando para girar a la izquierda

4418: 00  ; orientación resultado del proceso de búsqueda
4419: 00  ; número de iteraciones del proceso de búsqueda

; tabla de comandos si el personaje sube en altura
; cada entrada son 3 bytes (los 2 primeros el comando y el tercero la longitud del comando)
441A: 	8000 02 -> 1000 0000 0000 0000
		2000 04 -> 0010 0000 0000 0000

; tabla de comandos si el personaje baja en altura
; cada entrada son 3 bytes (los 2 primeros el comando y el tercero la longitud del comando)
4420: 	C000 02 -> 1100 0000 0000 0000
		3000 04 -> 0011 0000 0000 0000

; tabla de comandos si el personaje no cambia de altura
; cada entrada son 3 bytes (los 2 primeros el comando y el tercero la longitud del comando)
4426: 	8000 01 -> 1000 0000 0000 0000

; rutina llamada para buscar la ruta desde la posición que se le pasa en 0x2db2-0x2db3 a la que hay en 0x2db4-0x2db5
4429: 2A B4 2D    ld   hl,($2DB4)	; obtiene la posición de destino
442C: CD D4 0C    call $0CD4		; indexa en la tabla de alturas con hl y devuelve la dirección correspondiente en ix
442F: DD CB 00 F6 set  6,(ix+$00)	; marca la posición como objetivo de la búsqueda
4433: 18 35       jr   $446A		; rutina de búsqueda de caminos desde la dirección de origen a la de destino

; rutina llamada para buscar la ruta desde la posición que se le pasa en 0x2db2-0x2db3 a la que hay en 0x2db4-0x2db5 comprobando si es alcanzable
4435: 2A B4 2D    ld   hl,($2DB4)	; obtiene la posición de destino
4438: CD D4 0C    call $0CD4		; indexa en la tabla de alturas con hl y devuelve la dirección correspondiente en ix
443B: ED 73 B0 2D ld   ($2DB0),sp
443F: DD 7E 00    ld   a,(ix+$00)	; lee la altura de esa posición
4442: E6 0F       and  $0F
4444: 32 1C 45    ld   ($451C),a	; modifica una instrucción de la rutina de comprobar vecinos con la altura base
4447: 4F          ld   c,a			; guarda la altura de esa posición para luego
4448: FE 0E       cp   $0E
444A: 3E 00       ld   a,$00
444C: D2 75 45    jp   nc,$4575		; si la altura >= 0x0e, sale devolviendo 0
444F: 3E C9       ld   a,$C9
4451: 32 59 45    ld   ($4559),a	; modifica una instrucción de la rutina de los vecinos con ret
4454: CD 17 45    call $4517		; comprueba 4 posiciones relativas a ix ((x,y),(x,y-1),(x-1,y)(x-1,y-1) y si no hay mucha diferencia de altura, pone el bit 7 de (x,y)
4457: AF          xor  a
4458: 32 59 45    ld   ($4559),a	; deja la rutina como estaba poniendo nop
445B: DD CB 00 7E bit  7,(ix+$00)	; si no se puede alcanzar el destino, sale con a = 0
445F: CA 75 45    jp   z,$4575
4462: DD CB 00 BE res  7,(ix+$00)	; en otro caso, quita marca de posición explorada
4466: DD CB 00 F6 set  6,(ix+$00)	; marca la posición como objetivo de la búsqueda

; rutina de búsqueda de caminos desde la posición que hay en 0x2db2 (destino) a la posicion del buffer de altura que tenga el bit 6 (orígen)
446A: 2A 8A 2D    ld   hl,($2D8A)	; obtiene un puntero al buffer de alturas de la pantalla
446D: 01 28 02    ld   bc,$0228
4470: 5D          ld   e,l			; de = hl
4471: 54          ld   d,h
4472: 09          add  hl,bc		; apunta con hl a la posición (X = 0, Y = 23) del buffer de alturas
4473: EB          ex   de,hl		; de = posición (X = 0, Y = 23) del buffer de alturas, hl = posición (X = 0, Y = 0) del buffer de alturas
4474: DD 2A 8A 2D ld   ix,($2D8A)	; obtiene en ix un puntero al buffer de alturas
4478: 06 18       ld   b,$18		; b = 24 veces
447A: CB FE       set  7,(hl)		; pone el bit 7
447C: DD CB 00 FE set  7,(ix+$00)	; pone el bit 7
4480: DD CB 17 FE set  7,(ix+$17)	; pone el bit 7
4484: 1A          ld   a,(de)
4485: F6 80       or   $80
4487: 12          ld   (de),a		; pone el bit 7
4488: 78          ld   a,b
4489: 01 18 00    ld   bc,$0018
448C: DD 09       add  ix,bc		; avanza ix a la siguiente línea
448E: 47          ld   b,a
448F: 13          inc  de			; incrementa el puntero de la última línea del buffer de alturas
4490: 23          inc  hl			; incrementa el puntero de la última primera del buffer de alturas
4491: 10 E7       djnz $447A		; repite hasta haber puesto el bit 7 de todas las posiciones del borde del buffer de alturas

4493: ED 73 B0 2D ld   ($2DB0),sp
4497: 31 FE 9C    ld   sp,$9CFE		; pone en la pila al final del buffer de sprites
449A: 3E 01       ld   a,$01
449C: 32 19 44    ld   ($4419),a	; inicia el nivel de recursión
449F: ED 5B B2 2D ld   de,($2DB2)	; obtiene la posición inicial ajustada al buffer de alturas y la mete en pila
44A3: D5          push de
44A4: EB          ex   de,hl		; hl = posición inicial ajustada al buffer de alturas y la mete en pila
44A5: CD D4 0C    call $0CD4		; indexa en la tabla de alturas con hl y devuelve la dirección correspondiente en ix
44A8: DD CB 00 FE set  7,(ix+$00)	; marca la posición inicial como explorada
44AC: 21 FF FF    ld   hl,$FFFF
44AF: E5          push hl			; mete en la pila -1
44B0: 21 FE 9C    ld   hl,$9CFE		; hl apunta al final de la pila

44B3: 2B          dec  hl
44B4: 56          ld   d,(hl)
44B5: 2B          dec  hl
44B6: 5E          ld   e,(hl)		; de = valor sacado de la pila
44B7: 7B          ld   a,e
44B8: E6 80       and  $80			; si no recuperó -1, salta a explorar las posiciones vecinas
44BA: 28 14       jr   z,$44D0

; aquí llega si ha terminado una iteración
44BC: AF          xor  a			; a indica que la búsqueda no ha sido fructífera
44BD: 44          ld   b,h			; bc = hl
44BE: 4D          ld   c,l
44BF: ED 72       sbc  hl,sp		; obtiene la diferencia entre el elemento que está procesando y el último metido en la pila
44C1: 69          ld   l,c			; hl = bc
44C2: 60          ld   h,b
44C3: CA 75 45    jp   z,$4575		; si se han procesado todos los elementos, sale
44C6: D5          push de			; en otro caso, mete un -1 para indicar que termina un nivel
44C7: 3A 19 44    ld   a,($4419)	; incrementa el nivel de recursión
44CA: 3C          inc  a
44CB: 32 19 44    ld   ($4419),a
44CE: 18 E3       jr   $44B3		; sigue procesando elementos

; aqui llega si no se leyó -1 de la pila
44D0: E5          push hl			; guarda la posición por la que iba procesando en la pila
44D1: D5          push de			; guarda el valor que se ha obtenido de la pila
44D2: EB          ex   de,hl		; hl = valor sacado de la pila
44D3: CD D4 0C    call $0CD4		; indexa en la tabla de alturas con hl y devuelve la dirección correspondiente en ix
44D6: D1          pop  de			; de = valor que se ha obtenido de la pila
44D7: E1          pop  hl			; hl = posición por la que iba procesando en la pila

44D8: DD 7E 00    ld   a,(ix+$00)	; obtiene la altura de la posición y modifica una instrucción con ese valor
44DB: E6 0F       and  $0F
44DD: 32 1C 45    ld   ($451C),a

; trata de explorar las posiciones que rodean al valor de posición que ha sacado de la pila (si no hay mucha diferencia de altura)

44E0: 3E 02       ld   a,$02		; orientación izquierda
44E2: DD 23       inc  ix			; pasa a la posición (x+1,y)
44E4: 1C          inc  e
44E5: CD 0E 45    call $450E		; si no estaba puesto el bit 7 de la posición actual, comprueba las 4 posiciones relacionadas con ix
									;  ((x,y),(x,y-1),(x-1,y)(x-1,y-1) y si no hay mucha diferencia de altura, pone el bit 7 de (x,y)
44E8: 3E 03       ld   a,$03		; orientación arriba
44EA: 01 E7 FF    ld   bc,$FFE7		; bc = -25
44ED: DD 09       add  ix,bc		; pasa a la posición (x,y-1)
44EF: 1D          dec  e
44F0: 15          dec  d
44F1: CD 0E 45    call $450E		; si no estaba puesto el bit 7 de la posición actual, comprueba las 4 posiciones relacionadas con ix
									;  ((x,y),(x,y-1),(x-1,y)(x-1,y-1) y si no hay mucha diferencia de altura, pone el bit 7 de (x,y)
44F4: 3E 00       ld   a,$00		; orientación derecha
44F6: 01 17 00    ld   bc,$0017		; bc = 23
44F9: DD 09       add  ix,bc		; pasa a la posición (x-1,y)
44FB: 14          inc  d
44FC: 1D          dec  e
44FD: CD 0E 45    call $450E		; si no estaba puesto el bit 7 de la posición actual, comprueba las 4 posiciones relacionadas con ix
									;  ((x,y),(x,y-1),(x-1,y)(x-1,y-1) y si no hay mucha diferencia de altura, pone el bit 7 de (x,y)
4500: 3E 01       ld   a,$01		; orientación abajo
4502: 01 19 00    ld   bc,$0019		; bc = 25
4505: DD 09       add  ix,bc		; pasa a la posición (x,y+1)
4507: 14          inc  d
4508: 1C          inc  e
4509: CD 0E 45    call $450E		; si no estaba puesto el bit 7 de la posición actual, comprueba las 4 posiciones relacionadas con ix
									;  ((x,y),(x,y-1),(x-1,y)(x-1,y-1) y si no hay mucha diferencia de altura, pone el bit 7 de (x,y)

450C: 18 A5       jr   $44B3		; una vez comprobadas las posiciones vecinas, continúa sacando valores de la pila

; si no se había explorado esta posición, comprueba las 4 posiciones vecinas ((x,y),(x,y-1),(x-1,y)(x-1,y-1) y
;  si no hay mucha diferencia de altura, pone el bit 7 de (x,y). también escribe la orientación final en 0x4418
450E: DD 4E 00    ld   c,(ix+$00)	; obtiene el valor del buffer de alturas de la posición actual
4511: 32 18 44    ld   ($4418),a	; graba la orientación final
4514: CB 79       bit  7,c
4516: C0          ret  nz			; si la posición ya ha sido explorada, sale

; comprueba 4 posiciones relativas a ix ((x,y),(x,y-1),(x-1,y)(x-1,y-1) y si no hay mucha diferencia de altura, pone el bit 7 de (x,y)
; aquí llega con:
;  c = contenido del buffer de alturas (sin el bit 7) para una posición próxima a la que estaba el personaje
;  ix = puntero a una posición del buffer de alturas
4517: 79          ld   a,c
4518: E6 3F       and  $3F
451A: 4F          ld   c,a			; quita el bit 7 y 6
451B: 3E 00       ld   a,$00		; instrucción modificada con la altura de la posición principal del personaje en el buffer de alturas
451D: 91          sub  c			; obtiene la diferencia de altura entre el personaje y la posición que se está considerando
451E: 3C          inc  a
451F: FE 03       cp   $03
4521: D0          ret  nc			; si la diferencia de altura es >= 0x02, sale

4522: DD 7E FF    ld   a,(ix-$01)	; compara la altura de la posición de la izquierda con la altura de la posición actual
4525: E6 3F       and  $3F
4527: 91          sub  c
4528: 28 17       jr   z,$4541		; si coincide, salta

452A: 3C          inc  a
452B: FE 03       cp   $03
452D: D0          ret  nc			; si la diferencia de altura es muy grande, sale

452E: 47          ld   b,a			; guarda la diferencia de altura
452F: DD 7E E8    ld   a,(ix-$18)	; obtiene la altura de la posición (x,y-1)
4532: E6 3F       and  $3F
4534: 91          sub  c
4535: C0          ret  nz			; si no coincide la altura con la de (x,y), sale
4536: DD 7E E7    ld   a,(ix-$19)	; obtiene la altura de la posición (x-1,y-1)
4539: E6 3F       and  $3F
453B: 91          sub  c
453C: 3C          inc  a
453D: B8          cp   b
453E: C0          ret  nz			; si la diferencia de altura no coincide con la de (x-1,y), sale
453F: 18 14       jr   $4555		; salta

; aquí llega si la altura de pos (x,y) y de pos (x-1,y) coincide
4541: DD 7E E8    ld   a,(ix-$18)	; obtiene la altura de la posición (x,y-1)
4544: E6 3F       and  $3F
4546: 91          sub  c			; si la diferencia de altura es muy grande, sale
4547: 3C          inc  a
4548: FE 03       cp   $03
454A: D0          ret  nc
454B: 47          ld   b,a
454C: DD 7E E7    ld   a,(ix-$19)	; obtiene la altura de la posición (x-1,y-1)
454F: E6 3F       and  $3F
4551: 91          sub  c
4552: 3C          inc  a			; si la diferencia de altura no coincide con la de (x,y-1), sale
4553: B8          cp   b
4554: C0          ret  nz

; aquí llega si la diferencia de altura entre las 4 posiciones consideradas es pequeña
4555: DD CB 00 FE set  7,(ix+$00)	; pone a 1 el bit 7 de la posición
4559: 00          nop				; modificado desde fuera con un ret o un nop

455A: DD CB 00 BE res  7,(ix+$00)	; pone el bit 7 a 0 (no es una posición explorada)
455E: DD CB 00 76 bit  6,(ix+$00)
4562: 3A 18 44    ld   a,($4418)	; lee el parámetro con el que salta a la rutina
4565: 20 08       jr   nz,$456F		; si el bit 6 es 1 (ha encontrado lo que busca), salta

; si no ha encontrado lo que busca
4567: DD CB 00 FE set  7,(ix+$00)	; pone el bit 7 a 1 (casilla explorada), graba en pila la posición actual y sale
456B: C1          pop  bc
456C: D5          push de
456D: C5          push bc
456E: C9          ret

; aquí llega si el bit 6 es 1 (ha encontrado lo que se buscaba)
456F: C1          pop  bc			; quita la dirección de retorno de la pila
4570: 32 18 44    ld   ($4418),a	; guarda la orientación final
4573: 3E FF       ld   a,$FF		; 0xff indica que la búsqueda fue fructífera

; aquí salta para salir (si no hay más combinaciones o si ha terminado)
4575: 32 B6 2D    ld   ($2DB6),a	; escribe el resultado de la búsqueda
4578: ED 7B B0 2D ld   sp,($2DB0)	; recupera la pila de antes de ejecutar el algoritmo de búsqueda
457C: FB          ei
457D: C9          ret				; sale de la rutina original

; ------------- fin del código y los datos relacionados con la búsqueda de caminos en la misma pantalla --------------------------

; este código no se ejecuta nunca
457E: C4 A9 1E    call nz,$1EA9
4581: 63          ld   h,e

; llamado desde adso cuando se pulsa cursor abajo
; trata de avanzar en la orientación de guillermo
4582: CD 91 45    call $4591		; limpia las posiciones del buffer de alturas que ocupa adso y modifica un par de instrucciones
4585: 3A 37 30    ld   a,($3037)	; obtiene la orientación de guillermo y selecciona una entrada de la tabla según la orientación de guillermo
4588: 3C          inc  a			; 0 -> 1
4589: FE 03       cp   $03			; 1 -> 2
458B: 20 3A       jr   nz,$45C7		; 2 -> 7
458D: 3E 07       ld   a,$07		; 3 -> 4
458F: 18 36       jr   $45C7		; salta a escribir los comandos para avanzar en la orientación a la que mira guillermo
; se trata de avanzar en la orientación a la que mira guillermo, y probando el resto de orientaciones en el sentido de las agujas
; del reloj, excepto la contraria a la orientación de guillermo

4591: 0E 00       ld   c,$00
4593: CD EF 28    call $28EF		; si la posición del sprite es central y la altura está bien, pone c en las posiciones que ocupa del buffer de alturas
4596: 3E C9       ld   a,$C9
4598: 32 59 45    ld   ($4559),a	; modifica una rutina poniendo un ret
459B: DD 7E 00    ld   a,(ix+$00)	; obtiene la altura de la posición principal del personaje en el buffer de alturas
459E: E6 0F       and  $0F
45A0: 32 1C 45    ld   ($451C),a	; pone un parámetro de la rutina
45A3: C9          ret

; llamado desde adso cuando éste le impide avanzar a guillermo
45A4: CD 91 45    call $4591		; limpia las posiciones del buffer de alturas que ocupa adso y modifica un par de instrucciones
; aquí llega con ix apuntando al buffer de alturas de adso
45A7: ED 5B 38 30 ld   de,($3038)	; obtiene la posición de guillermo
45AB: 0E 00       ld   c,$00
45AD: 3A 47 30    ld   a,($3047)	; obtiene la posición x de adso
45B0: 93          sub  e
45B1: 30 04       jr   nc,$45B7		; si adso está a la derecha de guillermo, salta
45B3: ED 44       neg				; en otro caso, pasa la distancia a positivo
45B5: CB D1       set  2,c			; indica que guillermo está a la derecha de adso
45B7: 5F          ld   e,a			; e = distancia en x entre los 2 personajes

45B8: 3A 48 30    ld   a,($3048)	; obtiene la posición y de adso
45BB: 92          sub  d
45BC: 30 04       jr   nc,$45C2		; si adso está detrás de guillermo, salta
45BE: ED 44       neg				; en otro caso, pasa la distancia a positivo
45C0: CB C9       set  1,c			;4 indica que guillermo está detrás de adso
45C2: BB          cp   e			; compara las distancias en ambas coordenadas
45C3: 30 01       jr   nc,$45C6		; si la distancia en Y >= distancia en X, salta
45C5: 0C          inc  c			; modifica la entrada

45C6: 79          ld   a,c			; obtiene el valor calculado

45C7: 87          add  a,a			; cada entrada ocupa 4 bytes
45C8: 87          add  a,a
45C9: 21 1F 46    ld   hl,$461F		; indexa en la tabla de orientaciones a probar para moverse
45CC: CD 2D 16    call $162D		; hl = hl + a
45CF: EB          ex   de,hl		; de apunta a la entrada correspondiente
45D0: 06 03       ld   b,$03		; repite para 3 valores (la orientación contraria a la que se quiere mover no se prueba)
45D2: 1A          ld   a,(de)		; lee un valor de la tabla y lo guarda en c
45D3: 4F          ld   c,a			; orientación del personaje
45D4: C5          push bc
45D5: DD E5       push ix
45D7: D5          push de
45D8: 21 17 46    ld   hl,$4617		; apunta a la tabla de desplazamientos en el buffer de altura según la orientación
45DB: 87          add  a,a			; cada entrada ocupa 2 bytes
45DC: CD 2D 16    call $162D		; hl = hl + a
45DF: 4E          ld   c,(hl)
45E0: 23          inc  hl
45E1: 46          ld   b,(hl)		; lee el desplazamiento según la orientación a probar
45E2: DD 09       add  ix,bc		; calcula la posición en el buffer de alturas
45E4: DD CB 00 BE res  7,(ix+$00)	; quita el bit 7
45E8: DD 4E 00    ld   c,(ix+$00)	; obtiene lo que hay
45EB: CD 17 45    call $4517		; comprueba 4 posiciones relativas a ix ((x,y),(x,y-1),(x-1,y)(x-1,y-1) y si no hay mucha diferencia de altura, pone el bit 7 de (x,y)
45EE: DD CB 00 7E bit  7,(ix+$00)	; si la rutina anterior ha puesto el bit 7 (porque puede avanzarse en esa posición), salta
45F2: 20 12       jr   nz,$4606
45F4: D1          pop  de
45F5: DD E1       pop  ix
45F7: C1          pop  bc
45F8: 13          inc  de			; si no, prueba con otra orientación de la tabla
45F9: 10 D7       djnz $45D2		; repite para las 3 orientaciones que hay

; si llega aquí, el personaje no puede moverse a ninguna de las orientaciones propuestas
45FB: AF          xor  a
45FC: 32 59 45    ld   ($4559),a	; deja como estaba la rutina anterior
45FF: FD 4E 0E    ld   c,(iy+$0e)
4602: CD EF 28    call $28EF		; si la posición del sprite es central y la altura está bien, pone c en las posiciones que ocupa del buffer de alturas
4605: C9          ret

;aquí salta, el personaje va a moverse a la orientación que estaba probando
4606: DD CB 00 BE res  7,(ix+$00)	; quita el bit 7
460A: D1          pop  de
460B: DD E1       pop  ix
460D: C1          pop  bc
460E: CD 3F 46    call $463F		; escribe un comando para avanzar en la nueva orientación del personaje
4611: CD FB 45    call $45FB		; deja la rutina anterior como estaba y pone las posiciones del buffer de alturas del personaje
4614: C3 7B 08    jp   $087B		; vuelve a llamar al comportamiento de adso

; tabla de desplzamientos dentro del buffer de alturas según la orientación (relacionada con 0x461f)
4617: 	0001 = +01 -> 0x00
		FFE8 = -24 -> 0x01
		FFFF = -01 -> 0x02
		0018 = +24 -> 0x03

; tabla de orientaciones a probar para moverse en un determinado sentido
; cada entrada ocupa 4 bytes. Se prueban las orientaciones de cada entrada de izquierda a derecha
; las entradas están ordenadas inteligentemente.
; se pueden distinguir 2 grandes grupos de entradas. El primer grupo de entradas (las 4 primeras)
; da más prioridad a los movimientos a la derecha y el segundo grupo de entradas (las 4 últimas)
; da más prioridad a los movimientos a la izquierda. Dentro de cada grupo de entradas, las 2 primeras
; entradas dan más prioridad a los movimientos hacia abajo, y las otras 2 entradas dan más prioridad
; a los movimientos hacia arriba
461F: 	03 00 02 01	-> 0x00 -> (+y, +x, -x, -y) -> si adso está a la derecha y detrás de guillermo, con dist y >= dist x
		00 03 01 02 -> 0x01 -> (+x, +y, -y, -x) -> si adso está a la derecha y detrás de guillermo, con dist y < dist x
		01 00 02 03 -> 0x02 -> (-y, +x, -x, +y) -> si adso está a la derecha y delante de guillermo, con dist y >= dist x
		00 01 03 02 -> 0x03 -> (+x, -y, +y, -x) -> si adso está a la derecha y delante de guillermo, con dist y < dist x

		03 02 00 01 -> 0x04 -> (+y, -x, +x, -y) -> si adso está a la izquierda y detrás de guillermo, con dist y >= dist x
		02 03 01 00 -> 0x05 -> (-x, +y, -y, +x) -> si adso está a la izquierda y detrás de guillermo, con dist y < dist x
		01 02 00 03 -> 0x06 -> (-y, -x, +x, +y) -> si adso está a la izquierda y delante de guillermo, con dist y >= dist x
		02 01 03 00 -> 0x07 -> (-x, -y, +y, +x) -> si adso está a la izquierda y delante de guillermo, con dist y < dist x

; escribe un comando para cambiar la orientación del personaje y avanzar en esa orientación
;  c = nueva orientación del personaje
463F: 21 4F 46    ld   hl,$464F			; apunta a una rutina (escribe un comando dependiendo de si sube, baja o se mantiene)
4642: 22 01 48    ld   ($4801),hl		; modifica una rutina que llama la siguiente rutina
4645: CD E6 47    call $47E6
4648: 21 60 46    ld   hl,$4660			; apunta a otra rutina
464B: 22 01 48    ld   ($4801),hl		; restaura la rutina original a la que llamaba la rutina anterior
464E: C9          ret

; cambia la orientación del personaje y avanza en esa orientación
; iy apunta a los datos de posición de un personaje
; c = nueva orientación del personaje
464F: FD 7E 01    ld   a,(iy+$01)		; obtiene la orientación del personaje
4652: FD 71 01    ld   (iy+$01),c		; pone la nueva orientación del personaje
4655: B9          cp   c				; comprueba si era la orientación que tenía el personaje
4656: C4 C3 47    call nz,$47C3			; si no era así, escribe unos comandos para cambiar la orientación del personaje
4659: CD B8 27    call $27B8			; comprueba la altura de las posiciones a las que va a moverse el personaje y las devuelve en a y c
465C: CD 29 47    call $4729			; escribe un comando dependiendo de si sube, baja o se mantiene
465F: C9          ret

; ----------------- código relacionado con la reconstrucción de un camino del algoritmo de búsqueda -------------------------

; genera los comandos para seguir un camino en la misma pantalla
4660: ED 73 B0 2D ld   ($2DB0),sp	; guarda la pila actual
4664: F3          di
4665: 3E FF       ld   a,$FF
4667: 32 4B 2D    ld   ($2D4B),a	; pone el contador de la interrupción al máximo para que no se espere nada en el bucle principal
466A: 31 00 00    ld   sp,$0000		; modificado con el tope de la pila que tiene los movimientos realizados
466D: D1          pop  de			; obtiene el movimiento en el tope de la pila
466E: 21 00 95    ld   hl,$9500
4671: 36 FF       ld   (hl),$FF		; marca el final de los movimientos
4673: 23          inc  hl
4674: ED 4B B4 2D ld   bc,($2DB4)	; obtiene la posición a la que debe ir el personaje
4678: 71          ld   (hl),c		;  y la graba al principio del buffer
4679: 23          inc  hl
467A: 70          ld   (hl),b
467B: 23          inc  hl
467C: 3A 18 44    ld   a,($4418)	; lee la orientación resultado
467F: EE 02       xor  $02			; invierte la orientación
4681: 77          ld   (hl),a		; escribe la orientación
4682: 3A 19 44    ld   a,($4419)	; lee el número de iteraciones realizadas
4685: FE 01       cp   $01
4687: 28 4A       jr   z,$46D3		; si es 1, sale

4689: C1          pop  bc			; coge valores de la pila hasta encontrar el marcador de iteración (-1)
468A: 78          ld   a,b
468B: E6 80       and  $80
468D: 28 FA       jr   z,$4689

; aquí llega después de sacar FFFF de la pila
468F: 23          inc  hl
4690: 73          ld   (hl),e		; graba el movimiento del tope de la pila
4691: 23          inc  hl
4692: 72          ld   (hl),d
4693: C1          pop  bc			; obtiene el siguiente valor de la pila
4694: 78          ld   a,b			; a = coordenada y de la posición sacada de la pila
4695: 92          sub  d			; le resta la coordenada y de la posición final
4696: 3C          inc  a			; incrementa a y salta si es >= 3 y < 0, por lo que no salta si la distancia era -1, 0 o 1
4697: FE 03       cp   $03
4699: 30 F8       jr   nc,$4693		; si la distancia en y >= 2, sigue sacando valores de la pila
469B: 32 A8 46    ld   ($46A8),a
469E: 79          ld   a,c			; a = coordenada x de la posición sacada de la pila
469F: 93          sub  e			; le resta la coordenada x de la posición final
46A0: 3C          inc  a
46A1: FE 03       cp   $03
46A3: 30 EE       jr   nc,$4693		; si la distancia en x >= 2, sigue sacando valores de la pila
46A5: 87          add  a,a			; en otro caso, combina las distancias +1 en x y en y en los 4 bits inferiores de a
46A6: 87          add  a,a
46A7: C6 00       add  a,$00		; modificado con la distancia en y entre la posición sacada de la pila y la final
46A9: ED 43 C3 46 ld   ($46C3),bc	; modifica una instrucción con el valor sacado de la pila

46AD: 06 00       ld   b,$00		; prueba la orientación 0
46AF: FE 01       cp   $01			; a = 1 (00 01) cuando la distancia en x es -1 y en y es 0 (x-1,y)
46B1: 28 0F       jr   z,$46C2		; si es igual, salta
46B3: 04          inc  b			; prueba la orientación 1
46B4: FE 06       cp   $06			; a = 6 (01 10) cuando la distancia en x es 0 y en y es 1 (x,y+1)
46B6: 28 0A       jr   z,$46C2		; si es igual, salta
46B8: 04          inc  b			; prueba la orientación 2
46B9: FE 09       cp   $09			; a = 6 (10 01) cuando la distancia en x es 1 y en y es 0 (x+1,y)
46BB: 28 05       jr   z,$46C2		; si es igual, salta
46BD: 04          inc  b			; prueba la orientación 3
46BE: FE 04       cp   $04			; a = 6 (01 00) cuando la distancia en x es 0 y en y es -1 (x,y-1)
46C0: 20 D1       jr   nz,$4693		; si no es ninguno de los 4 casos en los que se ha avanzado una unidad, sigue sacando elementos

; aquí llega si el valor sacado de la pila era una iteración anterior de alguno de los de antes
46C2: 11 00 00    ld   de,$0000		; instrucción modificada con el valor sacado de la pila
46C5: 23          inc  hl
46C6: 70          ld   (hl),b		; graba la orientación del movimiento
46C7: 3A B2 2D    ld   a,($2DB2)	; lee la coordenada x del origen
46CA: BB          cp   e			; si no es la misma que la sacada de la pila, continua procesando una iteración más
46CB: 20 BC       jr   nz,$4689
46CD: 3A B3 2D    ld   a,($2DB3)	; lee la coordenada y del origen
46D0: BA          cp   d			; si no es la misma que la sacada de la pila, continua procesando una iteración más
46D1: 20 B6       jr   nz,$4689

; si llega aquí, ya se ha encontrado el camino completo del destino al origen
46D3: ED 7B B0 2D ld   sp,($2DB0)	; restaura la pila
46D7: FB          ei
46D8: E5          push hl			; obtiene el principio de la pila de movimientos en ix
46D9: DD E1       pop  ix

46DB: FD 46 01    ld   b,(iy+$01)	; obtiene la orientación del personaje
46DE: DD 4E 00    ld   c,(ix+$00)	; lee la orientación que debe tomar
46E1: FD CB 05 7E bit  7,(iy+$05)
46E5: 28 0E       jr   z,$46F5		; si el personaje ocupa 4 posiciones, salta esta parte
46E7: 78          ld   a,b
46E8: A9          xor  c			; compara la orientación del personaje con la que debe tomar
46E9: E6 01       and  $01
46EB: 28 08       jr   z,$46F5		; si el personaje no va a girar noventa grados en x, salta
46ED: FD 7E 05    ld   a,(iy+$05)	; en otro caso, cambia el estado de girado en desnivel
46F0: EE 20       xor  $20
46F2: FD 77 05    ld   (iy+$05),a

46F5: 78          ld   a,b			; a = orientación del personaje
46F6: FD 71 01    ld   (iy+$01),c	; modifica la orientación del personaje con la de la ruta que debe seguir
46F9: B9          cp   c			; comprueba si ha variado su orientación
46FA: C4 C3 47    call nz,$47C3		; si ha variado su orientación, escribe unos comandos para cambiar la orientación del personaje
46FD: DD E5       push ix
46FF: CD B8 27    call $27B8		; comprueba la altura de las posiciones a las que va a moverse el personaje y las devuelve en a y c
4702: CD 29 47    call $4729		; escribe un comando dependiendo de si sube, baja o se mantiene
4705: DD E1       pop  ix

4707: DD 2B       dec  ix			; avanza a la siguiente posición del camino
4709: DD 2B       dec  ix
470B: DD 2B       dec  ix
470D: DD 7E 00    ld   a,(ix+$00)
4710: FE FF       cp   $FF			; si se ha alcanzado la última posición del camino, sale
4712: C8          ret  z
4713: FD 6E 02    ld   l,(iy+$02)	; obtiene la posición del personaje
4716: FD 66 03    ld   h,(iy+$03)
4719: CD 9B 27    call $279B		; ajusta la posición pasada en hl a las 20x20 posiciones centrales que se muestran. Si la posición está fuera, CF=1
471C: DD 5E 01    ld   e,(ix+$01)	; obtiene la posición almacenada en esta posición de la pila
471F: DD 56 02    ld   d,(ix+$02)
4722: A7          and  a
4723: ED 52       sbc  hl,de		; compara la posición del personaje con la de la pila
4725: 28 B4       jr   z,$46DB		; si coincide, es porque comprueba ha llegado a la posición de destino y debe sacar más valores de la pila
4727: 18 DE       jr   $4707		; en otro caso, sigue procesando entradas

; escribe un comando dependiendo de si sube, baja o se mantiene
; llamado con:
;  iy = datos de posición del personaje
;  a y c = altura de las posiciones a las que va a moverse el personaje
4729: FD CB 05 A6 res  4,(iy+$05)		; indica que el personaje no está bajando en altura
472D: FD CB 05 7E bit  7,(iy+$05)
4731: 28 46       jr   z,$4779			; si el personaje ocupa 4 posiciones, salta

; aquí llega si el personaje ocupa una posición
4733: FD CB 05 6E bit  5,(iy+$05)
4737: 28 08       jr   z,$4741			; si el personaje no está girado con respecto al desnivel, salta
4739: D9          exx
473A: 21 1A 44    ld   hl,$441A			; apunta a la tabla de comandos si el personaje sube en altura
473D: D9          exx
473E: C3 B4 47    jp   $47B4

; aquí llega si el personaje ocupa una posición y el bit 5 es 0
4741: FD 34 04    inc  (iy+$04)		; incrementa la altura del personaje
4744: D9          exx
4745: 21 1A 44    ld   hl,$441A		; apunta a la tabla de comandos si el personaje sube en altura
4748: D9          exx
4749: FE 01       cp   $01
474B: 28 0F       jr   z,$475C		; si la diferencia de altura es 1 (está subiendo), salta

474D: D9          exx
474E: 21 20 44    ld   hl,$4420		; apunta a la tabla de comandos si el personaje baja en altura
4751: D9          exx
4752: FD 35 04    dec  (iy+$04)
4755: FD CB 05 E6 set  4,(iy+$05)	; en otro caso, está bajando
4759: FD 35 04    dec  (iy+$04)

475C: B9          cp   c
475D: 20 4F       jr   nz,$47AE		; si las diferencias de altura no son iguales, salta

475F: D9          exx
4760: 23          inc  hl			; pasa a otra entrada de la tabla
4761: 23          inc  hl
4762: 23          inc  hl
4763: D9          exx
4764: FD 7E 05    ld   a,(iy+$05)	; preserva tan solo el bit de si sube y baja (y convierte al personaje en uno de 4 posiciones)
4767: E6 10       and  $10
4769: FD 77 05    ld   (iy+$05),a
476C: E5          push hl
476D: CD E4 29    call $29E4		; actualiza la posición en x y en y del personaje según la orientación hacia la que avanza
4770: E1          pop  hl
4771: CD AE 29    call $29AE		; devuelve 0 si la orientación del personaje es 0 o 3, en otro caso devuelve 1
4774: CC E4 29    call z,$29E4		; actualiza la posición en x y en y del personaje según la orientación hacia la que avanza
4777: 18 3E       jr   $47B7

; aquí llega si el personaje ocupa cuatro posiciones
;  a = diferencia de altura con la posicion 1 más cercana al personaje según la orientación
;  c = diferencia de altura con la posicion 2 más cercana al personaje según la orientación
4779: FE 01       cp   $01
477B: 28 0B       jr   z,$4788		; si está subiendo, salta
477D: FE FF       cp   $FF
477F: 28 13       jr   z,$4794		; si está bajando, salta
4781: D9          exx
4782: 21 26 44    ld   hl,$4426		; apunta a la tabla si el personaje no cambia de altura
4785: D9          exx
4786: 18 26       jr   $47AE

; aquí llega si está subiendo
4788: FD 34 04    inc  (iy+$04)		; incrementa la altura
478B: 3E 80       ld   a,$80
478D: D9          exx
478E: 21 1D 44    ld   hl,$441D		; apunta a la tabla si el personaje sube en altura
4791: D9          exx
4792: 18 0A       jr   $479E

; aquí llega si está bajando
4794: FD 35 04    dec  (iy+$04)		; decrementa la altura
4797: 3E 90       ld   a,$90
4799: D9          exx
479A: 21 23 44    ld   hl,$4423		; apunta a la tabla si el personaje baja en altura
479D: D9          exx

479E: FD 77 05    ld   (iy+$05),a	; actualiza el estado
47A1: E5          push hl
47A2: CD E4 29    call $29E4		; actualiza la posición en x y en y del personaje según la orientación hacia la que avanza
47A5: E1          pop  hl
47A6: CD AE 29    call $29AE		; devuelve 0 si la orientación del personaje es 0 o 3, en otro caso devuelve 1
47A9: C4 E4 29    call nz,$29E4		; actualiza la posición en x y en y del personaje según la orientación hacia la que avanza
47AC: 18 09       jr   $47B7

; aquí llega si las alturas no son iguales o si el personaje ocupa 4 posiciones y no cambia de altura
47AE: 91          sub  c
47AF: 3C          inc  a
47B0: FE 03       cp   $03
47B2: 18 00       jr   $47B4		; salto incondicional ignorando la comparación anterior

47B4: CD E4 29    call $29E4		; actualiza la posición en x y en y del personaje según la orientación hacia la que avanza

47B7: D9          exx
47B8: 56          ld   d,(hl)		; lee en de el comando a poner
47B9: 23          inc  hl
47BA: 5E          ld   e,(hl)
47BB: 23          inc  hl
47BC: 46          ld   b,(hl)		; lee la longitud del comando
47BD: EB          ex   de,hl
47BE: CD E9 0C    call $0CE9		; escribe b bits del comando que se le pasa en hl del personaje pasado en iy
47C1: D9          exx
47C2: C9          ret

; escribe unos comandos para cambiar la orientación del personaje desde la orientación actual a la deseada
;  a = orientación actual del personaje
;  c = orientación que tomará del personaje
47C3: 91          sub  c			; obtiene la diferencia entre las orientaciones
47C4: 30 08       jr   nc,$47CE		; si la diferencia es positiva, salta
47C6: ED 44       neg				; diferencia = -diferencia
47C8: EE 02       xor  $02			; cambia el sentido en x
47CA: 20 02       jr   nz,$47CE
47CC: 3E 02       ld   a,$02		; si era 0, pone 2

47CE: 4F          ld   c,a			; c = orientación final
47CF: 21 0C 44    ld   hl,$440C		; apunta a la tabla de la longitud de los comandos según la orientación
47D2: CD 2D 16    call $162D		; hl = hl + a
47D5: 46          ld   b,(hl)		; lee la longitud del comando
47D6: 21 10 44    ld   hl,$4410		; apunta a la tabla de comandos para girar
47D9: 79          ld   a,c
47DA: 87          add  a,a			; cada entrada ocupa 2 bytes
47DB: CD 2D 16    call $162D		; hl = hl + a
47DE: 56          ld   d,(hl)		; de = valor leido de la tabla
47DF: 23          inc  hl
47E0: 5E          ld   e,(hl)
47E1: EB          ex   de,hl
47E2: CD E9 0C    call $0CE9		; escribe b bits del comando que se le pasa en hl del personaje pasado en iy
47E5: C9          ret

; iy apunta a los datos de posición de un personaje
; c = nueva orientación del personaje
; pude llamar a la rutina 0x4660 o a la 0x464f
; la rutina 0x4660 se encarga de generar todos los comandos para ir desde el origen al destino
; la rutina de 0x464f escribe un comando dependiendo de si sube, baja o se mantiene o de la orientación y sale
47E6: FD 56 03    ld   d,(iy+$03)
47E9: FD 5E 02    ld   e,(iy+$02)
47EC: D5          push de			; guarda en la pila la posición del personaje
47ED: FD 56 01    ld   d,(iy+$01)
47F0: FD 5E 04    ld   e,(iy+$04)
47F3: D5          push de			; guarda en la pila la orientación y altura del personaje

47F4: FD 36 09 00 ld   (iy+$09),$00	; reinicia las acciones del personaje
47F8: FD 36 0B 00 ld   (iy+$0b),$00

47FC: FD 7E 05    ld   a,(iy+$05)
47FF: F5          push af			; guarda el valor de iy+05 (indica para donde se mueve el personaje y su tamaño)
4800: CD 60 46    call $4660		; instrucción modificada desde fuera con la rutina a la que llamar (0x4660 o 0x464f)
4803: F1          pop  af			; restaura el valor anterior de iy+05
4804: FD 77 05    ld   (iy+$05),a	; restaura el valor
4807: 21 00 10    ld   hl,$1000
480A: 06 0C       ld   b,$0C
480C: CD E9 0C    call $0CE9		; escribe un comando para que espere un poco antes de volver a moverse
480F: E1          pop  hl			; restaura la orientación y altura del personaje
4810: FD 75 04    ld   (iy+$04),l
4813: FD 74 01    ld   (iy+$01),h
4816: E1          pop  hl			; restaura la posición del personaje
4817: FD 75 02    ld   (iy+$02),l
481A: FD 74 03    ld   (iy+$03),h

481D: FD 36 09 00 ld   (iy+$09),$00	; reinicia el puntero de las acciones del personaje
4821: FD 36 0B 00 ld   (iy+$0b),$00
4825: C9          ret

; -------------fin del código relacionado con la reconstrucción de un camino del algoritmo de búsqueda -------------------------

; ------------- código relacionado con la búsqueda de caminos entre pantallas ----------------------------------

; busca la pantalla indicada en 0x2db4 empezando en la posición indicada en 0x2db2
4826: 2A B4 2D    ld   hl,($2DB4)	; obtiene la pantalla que se busca
4829: CD B5 48    call $48B5		; dada la posición más significativa de un personaje en hl, indexa en la tabla de la planta y devuelve la entrada en ix
482C: DD CB 00 F6 set  6,(ix+$00)	; marca la pantalla buscada como el destino dentro de la planta

; busca la pantalla indicada que cumpla una máscara que se especifica en 0x48a4, iniciando la búsqueda en la posición indicada en 0x2db2
4830: ED 73 B0 2D ld   ($2DB0),sp	; guarda la pila inicial
4834: 31 FE 9C    ld   sp,$9CFE		; pone como dirección la pila el final del buffer de sprites
4837: ED 5B B2 2D ld   de,($2DB2)	; obtiene la posición del personaje que busca a otro
483B: D5          push de			; guarda en la pila la posición inicial
483C: EB          ex   de,hl
483D: CD B5 48    call $48B5		; dada la posición más significativa de un personaje en hl, indexa en la tabla de la planta y devuelve la entrada en ix
4840: DD CB 00 FE set  7,(ix+$00)	; marca la posición inicial como explorada
4844: 21 FF FF    ld   hl,$FFFF		; mete un -1
4847: E5          push hl
4848: 21 FE 9C    ld   hl,$9CFE		; apunta con hl a la parte procesada de la pila

484B: 2B          dec  hl
484C: 56          ld   d,(hl)
484D: 2B          dec  hl
484E: 5E          ld   e,(hl)		; de = elemento actual de la pila
484F: 7B          ld   a,e
4850: E6 80       and  $80
4852: 28 0D       jr   z,$4861		; si no se ha completado una iteración, salta
4854: AF          xor  a
4855: 44          ld   b,h			; bc = hl
4856: 4D          ld   c,l
4857: ED 72       sbc  hl,sp		; comprueba si ha procesado todos los elementos de la pila
4859: 69          ld   l,c			; hl = bc
485A: 60          ld   h,b
485B: CA 75 45    jp   z,$4575		; si es así, sale
485E: D5          push de			; mete -1 en la pila
485F: 18 EA       jr   $484B		; continúa procesando elementos de la pila

; aquí llega para procesar un elemento de la pila
4861: E5          push hl
4862: D5          push de
4863: EB          ex   de,hl
4864: CD B5 48    call $48B5		; dada la posición más significativa de un personaje en hl, indexa en la tabla de la planta y devuelve la entrada en ix
4867: D1          pop  de
4868: E1          pop  hl
4869: DD 23       inc  ix
486B: 1C          inc  e			; pasa a la posición (x+1,y)
486C: 01 04 02    ld   bc,$0204		; orientación = 2, trata de ir por bit 2
486F: CD 9B 48    call $489B		; comprueba si la posición que se le pasa en ix puede ser accedida, y si es así, si ya se ha explorado anteriormente.
									; si no se había explorado y era la que se buscaba, sale del algoritmo. En otro caso, la mete en pila para explorar desde esa posición
4872: 01 EF FF    ld   bc,$FFEF
4875: DD 09       add  ix,bc		; pasa a la posición (x,y-1)
4877: 01 08 03    ld   bc,$0308		; orientación = 3, trata de ir por bit 3
487A: 1D          dec  e
487B: 15          dec  d
487C: CD 9B 48    call $489B		; comprueba si la posición que se le pasa en ix puede ser accedida, y si es así, si ya se ha explorado anteriormente.
									; si no se había explorado y era la que se buscaba, sale del algoritmo. En otro caso, la mete en pila para explorar desde esa posición
487F: 01 0F 00    ld   bc,$000F
4882: DD 09       add  ix,bc
4884: 14          inc  d
4885: 1D          dec  e
4886: 01 01 00    ld   bc,$0001		; orientación = 0, trata de entrar por bit 1
4889: CD 9B 48    call $489B		; comprueba si la posición que se le pasa en ix puede ser accedida, y si es así, si ya se ha explorado anteriormente.
									; si no se había explorado y era la que se buscaba, sale del algoritmo. En otro caso, la mete en pila para explorar desde esa posición
488C: 01 11 00    ld   bc,$0011
488F: DD 09       add  ix,bc		; pasa a la posición (x,y+1)
4891: 14          inc  d
4892: 1C          inc  e
4893: 01 02 01    ld   bc,$0102		; orientación = 1, trata de ir por bit 2
4896: CD 9B 48    call $489B		; comprueba si la posición que se le pasa en ix puede ser accedida, y si es así, si ya se ha explorado anteriormente.
									; si no se había explorado y era la que se buscaba, sale del algoritmo. En otro caso, la mete en pila para explorar desde esa posición
4899: 18 B0       jr   $484B		; continúa probando combinaciones de la pila

; comprueba si la posición que se le pasa en ix puede ser accedida, y si es así, si ya se ha explorado anteriormente.
; si no se había explorado y era la que se buscaba, sale del algoritmo. En otro caso, la mete en pila para explorar desde esa posición
; c = orientación por la que se quiere salir de la habitación
; b = orientación usada para ir del destino al origen
489B: DD 7E 00    ld   a,(ix+$00)	; obtiene los datos de la habitación
489E: A1          and  c			; si no se puede salir de la habitación por la orientación que se le pasa, sale
489F: C0          ret  nz

48A0: 78          ld   a,b
48A1: DD CB 00 76 bit  6,(ix+$00)	; instrucción modificada desde fuera cambiando el número de bit a comprobar
48A5: C2 6F 45    jp   nz,$456F		; si está puesto el bit que se busca, sale del algoritmo guardando la orientación de destino e indicando que la búsqueda fue fructífera
48A8: DD CB 00 7E bit  7,(ix+$00)	; en otro caso, si la posición ya ha sido explorada, sale
48AC: C0          ret  nz

48AD: DD CB 00 FE set  7,(ix+$00)	; si la posición no se había explorado, la marca como explorada
48B1: C1          pop  bc			; recupera la dirección de retorno
48B2: D5          push de			; mete en la pila la posición actual
48B3: C5          push bc			; vuelve a guardar la dirección de retorno
48B4: C9          ret

; dada la posición más significativa de un personaje en hl, indexa en la tabla de la planta y devuelve la entrada en ix
48B5: 7C          ld   a,h
48B6: 87          add  a,a
48B7: 87          add  a,a
48B8: 87          add  a,a
48B9: 87          add  a,a			; h = h*16
48BA: B5          or   l			; combina la posición en un byte
48BB: 5F          ld   e,a
48BC: 16 00       ld   d,$00		; de guarda la posición del personaje
48BE: DD 2A 0A 44 ld   ix,($440A)
48C2: DD 19       add  ix,de
48C4: C9          ret
; ------------- fin del código relacionado con la búsqueda de caminos entre pantallas ----------------------------------

48C5: C3 9A 24    jp   $249A

; ----------------------------- inicio del dibujado de sprites ------------------------------
; tabla con los datos de los trajes de los monjes para las orientaciones y/o pasos
48C8: 	ABDB -> 0x00
		AB59 -> 0x01
		ABDB -> 0x02
		AC53 -> 0x03
	   	ADBB -> 0x04
   		ACCB -> 0x05
		ADBB -> 0x06
		AD48 -> 0x07
		B090 -> 0x08
		AFA0 -> 0x09
		B090 -> 0x0a
		B01D -> 0x0b
		AEB0 -> 0x0c
		AE2E -> 0x0d
		AEB0 -> 0x0e
		AF28 -> 0x0f

; tabla con el patrón de relleno de la luz
48E8: 	00E0 -> 0x00
		03F8 -> 0x01
		07FC -> 0x02
		07FC -> 0x03
		0FFE -> 0x04
		0FFE -> 0x05
		1FFF -> 0x06
		1FFF -> 0x07
		1FFF -> 0x08
		1FFF -> 0x09
		0FFE -> 0x0a
		0FFE -> 0x0b
		07FC -> 0x0c
		07FC -> 0x0d
		03F8 -> 0x0e
		00E0 -> 0x0f

4908: 0000 ; puntero del buffer de sprites
490A: 0000 ; pila original
490C: 0000 ; pila cuando trabaja con el buffer de sprites

; retardo hasta que bc sea 0
490E: 0B          dec  bc
490F: 78          ld   a,b
4910: B1          or   c
4911: 20 FB       jr   nz,$490E
4913: C9          ret

4914: ED 73 0A 49 ld   ($490A),sp	; guarda la dirección de la pila
4918: 21 00 95    ld   hl,$9500		; hl apunta al comienzo del buffer para los sprites
491B: 22 08 49    ld   ($4908),hl	; guarda el puntero al buffer de sprites
491E: 21 00 00    ld   hl,$0000
4921: 4C          ld   c,h			; inicialmente, no hay ninguna entrada activa (c = 0)
4922: E5          push hl			; guarda un 0 (para indicar que es la última entrada)
4923: 21 17 2E    ld   hl,$2E17		; hl apunta a la primera entrada de los sprites
4926: 11 14 00    ld   de,$0014		; de = 20 bytes por entrada

4929: 7E          ld   a,(hl)		; lee el primer byte de la entrada
492A: FE FF       cp   $FF
492C: 28 0D       jr   z,$493B		; si es 0xff, salta (última entrada)
492E: FE FE       cp   $FE
4930: 28 06       jr   z,$4938		; si era 0xfe, avanza a la siguiente entrada
4932: E5          push hl			;  en otro caso, guarda la dirección de la entrada
4933: CB 7F       bit  7,a			;  si el sprite ha cambiado, incrementa c
4935: 28 01       jr   z,$4938
4937: 0C          inc  c			; marca la entrada como activa
4938: 19          add  hl,de
4939: 18 EE       jr   $4929

; aquí llega una vez que ha metido en la pila las entradas a tratar
493B: ED 73 90 30 ld   ($3090),sp	; guarda la dirección de la pila
493F: F3          di
4940: 79          ld   a,c
4941: A7          and  a
4942: 20 06       jr   nz,$494A		; si había alguna entrada activa, salta
4944: ED 7B 0A 49 ld   sp,($490A)	; recupera la dirección de la pila y sale
4948: FB          ei
4949: C9          ret

; aquí llega si había alguna entrada que había que pintar
; primero se ordenan las entradas según la profundidad por el método de la burbuja mejorado
494A: ED 7B 90 30 ld   sp,($3090)		; recupera la dirección del tope de la pila
494E: 06 00       ld   b,$00			; inicialmente, hay 0 intercambios

4950: D1          pop  de				; recupera las 2 últimas entradas de la pila
4951: E1          pop  hl
4952: 7D          ld   a,l
4953: B4          or   h
4954: 20 06       jr   nz,$495C			; si la segunda entrada no es 0 (el marcador de fin), salta
4956: 78          ld   a,b
4957: A7          and  a
4958: 20 F0       jr   nz,$494A			; si se ha llegado al principio y hubo algún intercambio, vuelve a procesar la pila
495A: 18 13       jr   $496F			; si se llega aquí, la pila ya está ordenada, por lo que comienza a procesarla

; aquí se llega cuando se ha recuperado una entrada que no es la última
495C: 1A          ld   a,(de)
495D: E6 3F       and  $3F
495F: 4F          ld   c,a				; c = profundidad de la última entrada
4960: 7E          ld   a,(hl)
4961: E6 3F       and  $3F				; a = profundida de la penúltima entrada
4963: B9          cp   c				; compara la profundidad de las 2 entradas
4964: 38 03       jr   c,$4969			; si (hl) < (de), realiza un intercambio
4966: E5          push hl				; en otro caso, estos elementos están bien ordenados, descarta la última entrada y comprueba el resto hasta vaciar la pila
4967: 18 E7       jr   $4950

4969: 04          inc  b				; indica que ha intercambiado 2 elementos
496A: D5          push de				; intercambia las entradas
496B: E5          push hl
496C: E1          pop  hl				; el último elemento ya está ordenado
496D: 18 E1       jr   $4950			; vuelve a procesar las entradas

; aquí llega una vez que las entradas de la pila están ordenadas por la profundidad
496F: ED 7B 90 30 ld   sp,($3090)	; recupera la dirección del tope de la pila
4973: ED 73 92 30 ld   ($3092),sp	; guarda la dirección de la pila que apunta al objeto que se está procesando

4977: 21 00 00    ld   hl,$0000
497A: 39          add  hl,sp		; hl apunta a la pila
497B: F3          di
497C: ED 7B 92 30 ld   sp,($3092)	; obtiene la dirección de la pila
4980: D1          pop  de			; recupera el primer valor de la pila
4981: ED 73 92 30 ld   ($3092),sp	; guarda la dirección de la pila
4985: F9          ld   sp,hl		; restaura la dirección  de la pila para no sobreescribir los siguientes valores

4986: FB          ei
4987: 7B          ld   a,e
4988: B2          or   d
4989: CA DF 4B    jp   z,$4BDF		; si de era el último valor de la pila, salta (postprocesa los sprites)

498C: D5          push de
498D: DD E1       pop  ix			; ix = de (valor leido de la pila)
498F: DD CB 00 B6 res  6,(ix+$00)	; pone el bit 6 a 0
4993: DD CB 00 7E bit  7,(ix+$00)
4997: 28 DE       jr   z,$4977		; si el sprite no ha cambiado, sigue procesando el resto de entradas

4999: DD 6E 01    ld   l,(ix+$01)	; obtiene valores de la entrada (pos x1 en bytes, pos y1 en pixels, ancho en bytes, alto en pixels)
499C: DD 66 02    ld   h,(ix+$02)
499F: DD 56 06    ld   d,(ix+$06)
49A2: DD 5E 05    ld   e,(ix+$05)
49A5: CB BB       res  7,e			; el bit7 de la posición 5 tb se usa, así que lo pone a 0 pq no nos interesa ahora
49A7: CD 35 4D    call $4D35		; calcula la posición del tile en el que empieza el sprite y las dimensiones ampliadas del sprite (para abarcar todos los tiles en los que se va a dibujar el sprite)
49AA: ED 53 D7 2D ld   ($2DD7),de	; guarda las dimensiones ampliadas del sprite
49AE: 22 D5 2D    ld   ($2DD5),hl	; guarda la posición del tile en el que empieza el sprite
49B1: DD 6E 03    ld   l,(ix+$03)	; obtiene valores de la entrada (pos x2 en bytes, pos y2 en pixels, ancho2 en bytes, alto2 en pixels)
49B4: DD 66 04    ld   h,(ix+$04)
49B7: DD 56 0A    ld   d,(ix+$0a)
49BA: DD 5E 09    ld   e,(ix+$09)
49BD: CD BF 4C    call $4CBF		; comprueba las dimensiones mínimas del sprite (para borrar el sprite viejo) y actualiza 0x2dd5 y 0x2dd7
49C0: 2A D5 2D    ld   hl,($2DD5)	; obtiene la posición inicial del tile en el que empieza el sprite
49C3: DD 75 0C    ld   (ix+$0c),l
49C6: DD 74 0D    ld   (ix+$0d),h

; dado hl, calcula la coordenada correspondiente del buffer de tiles (buffer de tiles de 16x20, donde cada tile ocupa 16x8)
49C9: 7D          ld   a,l
49CA: E6 FC       and  $FC
49CC: 5F          ld   e,a			; e = posición en x del tile inicial en el que empieza el sprite (en bytes)
49CD: CB 3F       srl  a			; a = e/2
49CF: 83          add  a,e			; de = x + x/2 (ya que en cada byte hay 4 pixels y cada entrada en el buffer de tiles es de 6 bytes)
49D0: 5F          ld   e,a
49D1: 3E 00       ld   a,$00
49D3: 8F          adc  a,a
49D4: 57          ld   d,a
49D5: D5          push de			; guarda el desplazamiento en x

49D6: 6C          ld   l,h
49D7: 26 00       ld   h,$00		; hl = tile inicial en y en el que empieza el sprite (en pixels)
49D9: 29          add  hl,hl
49DA: 29          add  hl,hl
49DB: 5D          ld   e,l
49DC: 54          ld   d,h
49DD: 29          add  hl,hl
49DE: 19          add  hl,de		; hl = hl*12
49DF: D1          pop  de
49E0: 19          add  hl,de		; hl apunta a la línea correspondiente en el buffer de tiles

49E1: 11 94 8B    ld   de,$8B94		; indexa en el buffer de tiles (0x8b94 se corresponde a la posición X = -2, Y = -5 en el buffer de tiles)
49E4: 19          add  hl,de		;  que en pixels es: (X = -32, Y = -40), luego el primer pixel del buffer de tiles en coordenadas de sprite es el (32,40)
49E5: 22 95 30    ld   ($3095),hl	; guarda la dirección del tile actual en el buffer de tiles
49E8: 2A D7 2D    ld   hl,($2DD7)	; obtiene el ancho y el alto del sprite
49EB: DD 75 0E    ld   (ix+$0e),l
49EE: DD 74 0F    ld   (ix+$0f),h
49F1: 7C          ld   a,h			; a = alto del sprite
49F2: 26 00       ld   h,$00		; hl = ancho del sprite
49F4: CD 24 4D    call $4D24		; de = alto del sprite*ancho del sprite
49F7: 2A 08 49    ld   hl,($4908)	; obtiene la dirección del buffer de sprites
49FA: 22 FA 4A    ld   ($4AFA),hl	; modifica una instrucción
49FD: DD 75 10    ld   (ix+$10),l	; guarda la dirección del buffer de sprites
4A00: DD 74 11    ld   (ix+$11),h
4A03: 42          ld   b,d			; bc = de
4A04: 4B          ld   c,e
4A05: E5          push hl			; guarda la dirección del buffer de sprites obtenida
4A06: 09          add  hl,bc
4A07: 22 08 49    ld   ($4908),hl	; guarda la dirección libre del buffer de sprites
4A0A: 11 FE 9C    ld   de,$9CFE		; de = límite del buffer de sprites
4A0D: ED 52       sbc  hl,de		; hl = de - hl
4A0F: D1          pop  de			; recupera la dirección del buffer de sprites
4A10: D2 DF 4B    jp   nc,$4BDF		; si no hay sitio para el sprite, salta pasa vaciar la lista de los procesados y procesa el resto

; aquí llega si hay espacio para procesar el sprite
4A13: DD CB 00 F6 set  6,(ix+$00)	; marca el sprite como procesado
4A17: 6B          ld   l,e			; hl = de = dirección del buffer de sprites obtenida
4A18: 62          ld   h,d
4A19: 13          inc  de
4A1A: 0B          dec  bc
4A1B: 36 00       ld   (hl),$00
4A1D: ED B0       ldir				; limpia la zona asignada del buffer de sprites

4A1F: 01 00 00    ld   bc,$0000
4A22: ED 43 D9 4D ld   ($4DD9),bc	; modifica una instrucción (inicialmente profundidad = 0)
4A26: ED 7B 90 30 ld   sp,($3090)	; recupera la dirección de pila del sprite de mayor prioridad (el primero de la pila)
4A2A: ED 73 0C 49 ld   ($490C),sp

; aquí se llega después de haber pintado un sprite para seguir pintando el siguiente
4A2E: 21 00 00    ld   hl,$0000
4A31: 39          add  hl,sp		; hl apunta a la pila
4A32: F3          di
4A33: ED 7B 0C 49 ld   sp,($490C)	; obtiene la dirección de la pila
4A37: D1          pop  de			; obtiene la dirección del sprite a tratar
4A38: ED 73 0C 49 ld   ($490C),sp	; guarda la nueva dirección de la pila
4A3C: F9          ld   sp,hl		; restaura la dirección  de la pila para no sobreescribir los siguientes valores
4A3D: FB          ei
4A3E: 7A          ld   a,d
4A3F: B3          or   e
4A40: C2 56 4A    jp   nz,$4A56		; si no era el último valor de la pila, salta

; aquí llega si ya se han procesado todos los sprites de la pila (con respecto al sprite actual)
4A43: 01 FC FC    ld   bc,$FCFC		; se le pasa un valor de profundidad muy alto
4A46: 3E 00       ld   a,$00
4A48: 32 85 4D    ld   ($4D85),a	; cambia un ret por un nop
4A4B: CD 9E 4D    call $4D9E		; dibuja en el buffer de sprites los tiles que están delante del sprite
4A4E: 3E C9       ld   a,$C9
4A50: 32 85 4D    ld   ($4D85),a	; cambia un nop por un ret
4A53: C3 77 49    jp   $4977		; salta hasta que la pila esté vacía

; aquí llega si había algún sprite en la pila (0x2dd5 y 0x2dd7 se han calculado para el sprite del tope de la pila), pero
;  aqui llegan también el resto de sprites
4A56: D5          push de			; iy = de = dirección de la entrada del sprite
4A57: FD E1       pop  iy
4A59: FD CB 05 7E bit  7,(iy+$05)	; si el sprite va a desaparecer, salta al siguiente sprite
4A5D: 20 CF       jr   nz,$4A2E

4A5F: 3A D5 2D    ld   a,($2DD5)
4A62: 6F          ld   l,a			; l = posición inicial en x del tile en el que empieza el sprite original (en bytes)
4A63: 3A D7 2D    ld   a,($2DD7)
4A66: 5F          ld   e,a			; e = ancho ampliado del sprite original (en bytes)
4A67: FD 66 01    ld   h,(iy+$01)	; h = posición inicial en x del sprite actual
4A6A: FD 56 05    ld   d,(iy+$05)	; d = ancho del sprite actual
4A6D: CD 54 4D    call $4D54		; comprueba si el sprite actual puede verse en la zona del sprite original. Si no es así, salta
									;  a por otro sprite actual. En otro caso, recorta en x la parte del sprite actual que puede verse
									;  en el sprite original
; en a devuelve la longitud a pintar del sprite actual para la coordenada que se pasa
; en h devuelve la distancia desde el inicio del sprite actual al incio del sprite original (para la coordenada que se pasa)
; en l devuelve la distancia desde el inicio del sprite original al inicio del sprite actual (para la coordenada que se pasa)
4A70: 32 11 4B    ld   ($4B11),a	; modifica unas instrucciones con los datos calculados
4A73: 7C          ld   a,h
4A74: 32 E6 4A    ld   ($4AE6),a
4A77: 32 4E 4B    ld   ($4B4E),a
4A7A: 7D          ld   a,l
4A7B: 32 FE 4A    ld   ($4AFE),a
4A7E: 3A D6 2D    ld   a,($2DD6)
4A81: 6F          ld   l,a			; l = posición inicial en y del tile en el que empieza el sprite original (en bytes)
4A82: 3A D8 2D    ld   a,($2DD8)
4A85: 5F          ld   e,a			; e = alto del sprite original (en pixels)
4A86: FD 66 02    ld   h,(iy+$02)	; h = posición inicial en y del sprite actual
4A89: FD 56 06    ld   d,(iy+$06)	; d = alto del sprite actual
4A8C: CD 54 4D    call $4D54		; comprueba si el sprite actual puede verse en la zona del sprite original. Si no es así, salta
									;  a por otro sprite actual. En otro caso, recorta en y la parte del sprite actual que puede verse
									;  en el sprite original
; en a devuelve la longitud a pintar del sprite actual para la coordenada que se pasa
; en h devuelve la distancia desde el inicio del sprite actual al incio del sprite original (para la coordenada que se pasa)
; en l devuelve la distancia desde el inicio del sprite original al inicio del sprite actual (para la coordenada que se pasa)
4A8F: 32 0E 4B    ld   ($4B0E),a	; modifica unas instrucciones con los datos calculados
4A92: 7C          ld   a,h
4A93: 32 A5 4A    ld   ($4AA5),a
4A96: 7D          ld   a,l
4A97: 32 EE 4A    ld   ($4AEE),a

4A9A: FD 4E 12    ld   c,(iy+$12)	; bc = obtiene la posición del sprite en coordenadas de cámara
4A9D: FD 46 13    ld   b,(iy+$13)
4AA0: CD 9E 4D    call $4D9E		; copia en el buffer de sprites los tiles que están detras del sprite

; al llegar aquí pinta el sprite actual
4AA3: D9          exx
4AA4: 21 00 00    ld   hl,$0000		; instrucción modificada desde fuera (distancia en y desde el inicio del sprite actual al incio del sprite original)
4AA7: 7D          ld   a,l
4AA8: 32 0B 4B    ld   ($4B0B),a	; modifica una instrucción
4AAB: FE 0A       cp   $0A
4AAD: 38 26       jr   c,$4AD5		; si la distancia en y desde el inicio del sprite actual al incio del sprite original < 10, salta
4AAF: FD CB 0B 7E bit  7,(iy+$0b)
4AB3: 20 20       jr   nz,$4AD5		; si no es un monje, salta

; si llega aquí es porque la distancia en y desde el inicio del sprite actual al incio del sprite original es >= 10, por lo que del sprite
;  actual (que es un monje), ya se ha pasado la cabeza. Por ello, obtiene un puntero al traje del monje
4AB5: 7D          ld   a,l
4AB6: D6 0A       sub  $0A
4AB8: 6F          ld   l,a
4AB9: FD 7E 05    ld   a,(iy+$05)	; lee el ancho del sprite actual
4ABC: 32 30 4B    ld   ($4B30),a	; modifica una instrucción
4ABF: CD 24 4D    call $4D24		; de = a*hl
4AC2: FD 7E 0B    ld   a,(iy+$0b)	; a = animación del traje del monje
4AC5: 21 C8 48    ld   hl,$48C8		; apunta a la tabla de los trajes de los monjes
4AC8: 87          add  a,a			; cada entrada son 2 bytes
4AC9: 85          add  a,l			; hl = hl + a
4ACA: 6F          ld   l,a
4ACB: 8C          adc  a,h
4ACC: 95          sub  l
4ACD: 67          ld   h,a
4ACE: 7E          ld   a,(hl)
4ACF: 23          inc  hl
4AD0: 66          ld   h,(hl)		; hl = [hl]
4AD1: 6F          ld   l,a
4AD2: 19          add  hl,de
4AD3: 18 10       jr   $4AE5

; calcula la línea en la que empezar a dibujar el sprite actual (saltandose la distancia entre el inicio del sprite actual y el inicio del sprite original)
4AD5: FD 7E 05    ld   a,(iy+$05)	; obtiene el ancho del sprite actual
4AD8: 32 30 4B    ld   ($4B30),a	; modifica una instrucción
4ADB: CD 24 4D    call $4D24		; de = a*hl
4ADE: FD 6E 07    ld   l,(iy+$07)	; hl = dirección de los datos gráficos del sprite
4AE1: FD 66 08    ld   h,(iy+$08)

4AE4: 19          add  hl,de		; hl = dirección de los datos gráficos del sprite (saltando lo que no se superpone con el área del sprite original en y)
4AE5: 3E 00       ld   a,$00		; instrucción modificada desde fuera (distancia en x desde el inicio del sprite actual al incio del sprite original)
4AE7: 85          add  a,l			; hl = hl + a
4AE8: 6F          ld   l,a
4AE9: 8C          adc  a,h
4AEA: 95          sub  l
4AEB: 67          ld   h,a
4AEC: E5          push hl			; guarda la dirección de los datos gráficos del sprite (saltando lo que no está en el área del sprite original en x y en y)

4AED: 21 00 00    ld   hl,$0000		; instrucción modificada desde fuera (distancia en y desde el inicio del sprite original al incio del sprite actual)
4AF0: 3A D7 2D    ld   a,($2DD7)	; obtiene el ancho ampliado del sprite original
4AF3: 32 54 4B    ld   ($4B54),a	; modifica una instrucción
4AF6: CD 24 4D    call $4D24		; de = a*hl
4AF9: 21 00 95    ld   hl,$9500		; instrucción modificada desde fuera con la posición inicial del buffer de sprites para este sprite
4AFC: 19          add  hl,de		; hl = dirección del buffer de sprites para el sprite original (saltando lo que no puede sobreescribir el sprite actual en y)
4AFD: 3E 00       ld   a,$00		; instrucción modificada desde fuera (distancia en x desde el inicio del sprite original al inicio del sprite actual)
4AFF: 85          add  a,l			; de = hl + a
4B00: 5F          ld   e,a
4B01: 8C          adc  a,h
4B02: 93          sub  e
4B03: 57          ld   d,a			; de = dirección del buffer de sprites para el sprite original (saltando lo que no puede sobreescribir el sprite actual en x y en y)
4B04: E1          pop  hl			; recupera la dirección a los datos gráficos del sprite actual que pueden coincidir con los del sprite original

4B05: 7C          ld   a,h			; si hl == 0 (es el sprite de la luz), salta
4B06: B5          or   l
4B07: CA 60 4B    jp   z,$4B60

4B0A: 0E 00       ld   c,$00		; instrucción modificada desde fuera (distancia en y desde el inicio del sprite actual al incio del sprite original)
4B0C: D9          exx
4B0D: 06 00       ld   b,$00		; instrucción modificada desde fuera (alto a pintar del sprite actual)
4B0F: D9          exx
4B10: 06 00       ld   b,$00		; instrucción modificada desde fuera (ancho a pintar del sprite actual)
4B12: D5          push de			; guarda la dirección del buffer de sprites
4B13: E5          push hl			; guarda la dirección de los datos gráficos
4B14: 7E          ld   a,(hl)		; lee un byte gráfico
4B15: A7          and  a
4B16: 28 12       jr   z,$4B2A		; si es 0, salta al siguiente pixel
4B18: D9          exx
4B19: 6F          ld   l,a			; l = mascara del or
4B1A: 0F          rrca				; a = b3 b2 b1 b0 b7 b6 b5 b4
4B1B: 0F          rrca
4B1C: 0F          rrca
4B1D: 0F          rrca
4B1E: B5          or   l			; a = b7|b3 b6|b2 b5|b1 b4|b0 b7|b3 b6|b2 b5|b1 b4|b0
4B1F: 28 06       jr   z,$4B27		; si es 0, salta (???, no sería 0 antes tb???)
4B21: 2F          cpl				; 0->1
4B22: 67          ld   h,a			; h = máscara del and (los sprites usan el color 0 como transparente)
4B23: D9          exx
4B24: 1A          ld   a,(de)		; lee un byte del buffer de sprites
4B25: D9          exx
4B26: A4          and  h
4B27: B5          or   l			; combina el byte leido
4B28: D9          exx
4B29: 12          ld   (de),a		; escribe el byte en buffer de sprites después de haberlo combinado
4B2A: 13          inc  de			; avanza a la siguiente posición en x dentro del buffer de sprites
4B2B: 23          inc  hl			; avanza a la siguiente posición en x del gráfico
4B2C: 10 E6       djnz $4B14		; repite para el ancho

4B2E: E1          pop  hl
4B2F: 11 00 00    ld   de,$0000		; modificado con el ancho del sprite actual
4B32: 19          add  hl,de		; pasa a la siguiente línea del sprite
4B33: D1          pop  de			; obtiene el puntero al buffer de sprites
4B34: 0C          inc  c
4B35: 79          ld   a,c
4B36: FE 0A       cp   $0A			; si llega a 10, cambia la dirección de los datos gráficos de origen, puesto que se pasa de dibujar
4B38: 20 19       jr   nz,$4B53		;  la cabeza de un monje a dibujar su traje
4B3A: FD 7E 0B    ld   a,(iy+$0b)	; si el bit 7 es 1, salta (no es un monje)
4B3D: CB 7F       bit  7,a
4B3F: 20 12       jr   nz,$4B53

4B41: 21 C8 48    ld   hl,$48C8		; apunta a la tabla de las posiciones de los trajes de los monjes
4B44: 87          add  a,a
4B45: 85          add  a,l
4B46: 6F          ld   l,a
4B47: 8C          adc  a,h
4B48: 95          sub  l
4B49: 67          ld   h,a			; hl = hl + a
4B4A: 7E          ld   a,(hl)
4B4B: 23          inc  hl
4B4C: 66          ld   h,(hl)
4B4D: C6 00       add  a,$00		; instrucción modificada desde fuera (distancia en x desde el inicio del sprite actual al incio del sprite original)
4B4F: 6F          ld   l,a
4B50: 8C          adc  a,h
4B51: 95          sub  l
4B52: 67          ld   h,a			; modifica la dirección de los datos gráficos de origen, para que apunte a la animación del traje del monje

4B53: 3E 00       ld   a,$00		; modificado desde fuera (con el ancho ampliado del sprite original)
4B55: 83          add  a,e			; de = de + a (pasa a la siguiente línea del buffer de sprites)
4B56: 5F          ld   e,a
4B57: 8A          adc  a,d
4B58: 93          sub  e
4B59: 57          ld   d,a
4B5A: D9          exx
4B5B: 10 B2       djnz $4B0F		; repite para las líneas de alto
4B5D: C3 2E 4A    jp   $4A2E		; sigue procesando el resto de sprites de la pila

; aquí llega si el sprite tiene un puntero a datos gráficos = 0 (es el sprite de la luz)
4B60: DD E5       push ix
4B62: 21 E8 48    ld   hl,$48E8		; hl apunta a la tabla con el patrón de relleno de la luz
4B65: D5          push de
4B66: D9          exx
4B67: E1          pop  hl			; obtiene la dirección del buffer de sprites del sprite original
4B68: 5D          ld   e,l			; de = hl
4B69: 54          ld   d,h
4B6A: 01 00 00    ld   bc,$0000		; esto se modifica desde fuera con 0x00ef o 0x009f
4B6D: 36 FF       ld   (hl),$FF
4B6F: 13          inc  de
4B70: ED B0       ldir				; rellena un tile o tile y medio de negro (la parte superior del sprite de la luz)
4B72: D5          push de
4B73: DD E1       pop  ix			; ix apunta a lo que hay después del buffer de tiles
4B75: 11 50 00    ld   de,$0050		; de = 80 (desplazamiento de medio tile)
4B78: D9          exx
4B79: 06 0F       ld   b,$0F		; 15 veces rellena con bloques de 4x4

4B7B: DD E5       push ix
4B7D: 7E          ld   a,(hl)		; lee un valor de la tabla
4B7E: D9          exx
4B7F: 67          ld   h,a
4B80: D9          exx
4B81: 23          inc  hl
4B82: 7E          ld   a,(hl)		; lee otro valor de la tabla
4B83: 23          inc  hl
4B84: D9          exx
4B85: 6F          ld   l,a			; hl = valor de la tabla

4B86: 3E FF       ld   a,$FF		; relleno negro
4B88: 06 00       ld   b,$00		; modificado desde fuera con posición x del sprite de adso dentro del tile
4B8A: 04          inc  b
4B8B: 05          dec  b
4B8C: 28 10       jr   z,$4B9E		; completa la parte de los 16 pixels que sobra por la izquierda según la ampliación de la posición x
4B8E: DD 77 00    ld   (ix+$00),a
4B91: DD 77 14    ld   (ix+$14),a
4B94: DD 77 28    ld   (ix+$28),a
4B97: DD 77 3C    ld   (ix+$3c),a
4B9A: DD 23       inc  ix
4B9C: 10 F0       djnz $4B8E		; completa el relleno de la parte izquierda

; hl contiene el valor leido de la tabla
4B9E: 06 10       ld   b,$10		; 16 bits
4BA0: 29          add  hl,hl		; 0x00 o 0x29 (si los gráficos de adso están flipeados o no)
4BA1: 29          add  hl,hl
4BA2: 38 0C       jr   c,$4BB0		; si el bit más significativo es 1, no rellena de negro el bloque de 4x4
4BA4: DD 77 00    ld   (ix+$00),a	; rellena de negro un bloque de 4x4
4BA7: DD 77 14    ld   (ix+$14),a
4BAA: DD 77 28    ld   (ix+$28),a
4BAD: DD 77 3C    ld   (ix+$3c),a
4BB0: DD 23       inc  ix
4BB2: 10 ED       djnz $4BA1		; completa los 16 bits

4BB4: 06 00       ld   b,$00		; modificado desde fuera con 4 - (posición x del sprite de adso & 0x03)
4BB6: DD 77 00    ld   (ix+$00),a	; completa la parte de los 16 pixels que sobra por la derecha según la ampliación de la posición x
4BB9: DD 77 14    ld   (ix+$14),a
4BBC: DD 77 28    ld   (ix+$28),a
4BBF: DD 77 3C    ld   (ix+$3c),a
4BC2: DD 23       inc  ix
4BC4: 10 F0       djnz $4BB6		; completa la parte derecha

4BC6: DD E1       pop  ix
4BC8: DD 19       add  ix,de		; pasa al siguiente medio tile
4BCA: D9          exx
4BCB: 10 AE       djnz $4B7B		; repite hasta completar los 15 bloques de 4 pixels de alto

4BCD: DD E5       push ix
4BCF: E1          pop  hl
4BD0: 01 00 00    ld   bc,$0000		; esto se modifica desde fuera con 0x00ef o 0x009f
4BD3: 5D          ld   e,l
4BD4: 54          ld   d,h			; de = hl
4BD5: 13          inc  de
4BD6: 36 FF       ld   (hl),$FF		; rellena un tile o tile y medio de negro (la parte inferior del sprite de la luz)
4BD8: ED B0       ldir
4BDA: DD E1       pop  ix
4BDC: C3 2E 4A    jp   $4A2E		; sigue procesando el resto de sprites de la pila

; aquí llega una vez ha procesado todos los sprites que había que redibujar (o si no había más espacio en el buffer de sprites)
4BDF: DD 21 17 2E ld   ix,$2E17			; ix apunta a los sprites
4BE3: DD 7E 00    ld   a,(ix+$00)
4BE6: FE FF       cp   $FF
4BE8: 28 29       jr   z,$4C13			; cuando encuentra el último, sale
4BEA: FE FE       cp   $FE
4BEC: 28 1D       jr   z,$4C0B			; si está inactivo, pasa al siguiente
4BEE: E6 40       and  $40
4BF0: 28 19       jr   z,$4C0B			; si no tiene puesto el bit 6, pasa al siguiente
; aquí llega si el sprite actual tiene puesto a 1 el bit 6 (el sprite ha sido procesado)
4BF2: CD 1A 4C    call $4C1A			; vuelca el buffer del sprite a pantalla, recortando lo que no sea visible
4BF5: DD CB 00 BE res  7,(ix+$00)		; limpia el bit 6 y 7 del byte 0
4BF9: DD CB 00 B6 res  6,(ix+$00)
4BFD: DD CB 05 7E bit  7,(ix+$05)
4C01: 28 08       jr   z,$4C0B			; si el bit 7 del byte 5 es 0, pasa al siguiente sprite
4C03: DD CB 05 BE res  7,(ix+$05)		; en otro caso, lo limpia
4C07: DD 36 00 FE ld   (ix+$00),$FE		; marca el sprite como inactivo
4C0B: 01 14 00    ld   bc,$0014			; pasa al siguiente sprite
4C0E: DD 09       add  ix,bc
4C10: C3 E3 4B    jp   $4BE3

4C13: ED 7B 0A 49 ld   sp,($490A)		; recupera el valor original de la pila
4C17: C3 14 49    jp   $4914			; salta a procesar los objetos que queden

; vuelca el buffer del sprite a la pantalla
4C1A: AF          xor  a
4C1B: 32 A0 4C    ld   ($4CA0),a
4C1E: DD 66 0D    ld   h,(ix+$0d)		; h = posición en y del tile en el que empieza el sprite
4C21: DD 46 0F    ld   b,(ix+$0f)		; b = alto final del sprite (en pixels)
4C24: D9          exx
4C25: 11 00 00    ld   de,$0000
4C28: D9          exx
4C29: 7C          ld   a,h
4C2A: FE C8       cp   $C8				; si la coordenada y >= 200 (no es visible en pantalla), sale
4C2C: D0          ret  nc
4C2D: D6 28       sub  $28
4C2F: 67          ld   h,a				; ajusta la coordenada y
4C30: 30 13       jr   nc,$4C45			; si la coordenada y > 40 (visible en pantalla), salta
4C32: ED 44       neg
4C34: B8          cp   b				; si la distancia desde el punto en que comienza el sprite al primer punto visible >= la altura del sprite, sale (no visible)
4C35: D0          ret  nc
4C36: D9          exx
4C37: 26 00       ld   h,$00
4C39: DD 6E 0E    ld   l,(ix+$0e)		; l = ancho final del sprite (en bytes)
4C3C: CD 24 4D    call $4D24			; de = a*hl (avanza las líneas del sprite no visible)
4C3F: D9          exx
4C40: 78          ld   a,b
4C41: 84          add  a,h				; modifica el alto del sprite por el recorte
4C42: 47          ld   b,a
4C43: 26 00       ld   h,$00			; el sprite empieza en y = 0

4C45: D9          exx
4C46: DD 6E 10    ld   l,(ix+$10)		; hl = dirección del buffer de sprites asignada a este sprite
4C49: DD 66 11    ld   h,(ix+$11)
4C4C: 19          add  hl,de			; salta los bytes no visibles en y
4C4D: D9          exx
4C4E: DD 6E 0C    ld   l,(ix+$0c)		; l = posición en x del tile en el que empieza el sprite (en bytes)
4C51: DD 4E 0E    ld   c,(ix+$0e)		; c = ancho final del sprite (en bytes)
4C54: 7D          ld   a,l
4C55: FE 48       cp   $48				; si la posición en x >= (32 + 256 pixels)
4C57: D0          ret  nc
4C58: D6 08       sub  $08				; ajusta la coordenada x
4C5A: 6F          ld   l,a
4C5B: 30 15       jr   nc,$4C72			; si la posición en x >= 32 pixels, salta
4C5D: ED 44       neg
4C5F: DD BE 0E    cp   (ix+$0e)			; si la distancia desde el punto en que comienza el sprite al primer punto visible >= la anchura del sprite, sale (no visible)
4C62: D0          ret  nc
4C63: 32 A0 4C    ld   ($4CA0),a		; modifica una instrucción con la distancia en x
4C66: D9          exx
4C67: 85          add  a,l				; hl = hl + a (avanza los pixels recortados)
4C68: 6F          ld   l,a
4C69: 8C          adc  a,h
4C6A: 95          sub  l
4C6B: 67          ld   h,a
4C6C: D9          exx
4C6D: 79          ld   a,c				; modifica el ancho a pintar
4C6E: 85          add  a,l
4C6F: 4F          ld   c,a
4C70: 2E 00       ld   l,$00			; el sprite empieza en x = 0

4C72: 79          ld   a,c				; a = ancho del sprite a pintar
4C73: 85          add  a,l				; l = coordenada x inicial
4C74: D6 40       sub  $40				; comprueba si el sprite es más ancho que la pantalla (64*4 = 256)
4C76: 38 07       jr   c,$4C7F
4C78: 32 A0 4C    ld   ($4CA0),a		; modifica una instrucción
4C7B: ED 44       neg
4C7D: 81          add  a,c
4C7E: 4F          ld   c,a				; pone un nuevo ancho para el sprite

4C7F: 79          ld   a,c
4C80: 32 9B 4C    ld   ($4C9B),a		; modifica una instrucción

4C83: 78          ld   a,b				; a = alto del sprite a pintar
4C84: 4F          ld   c,a
4C85: 84          add  a,h				; h = coordenada y inicial
4C86: D6 A0       sub  $A0				; comprueba si el sprite es más alto que la pantalla (160)
4C88: 38 04       jr   c,$4C8E
4C8A: ED 44       neg
4C8C: 81          add  a,c
4C8D: 4F          ld   c,a				; actualiza el alto a pintar

4C8E: 79          ld   a,c
4C8F: 32 96 4C    ld   ($4C96),a	; modifica una instrucción
4C92: CD 42 3C    call $3C42		; dado hl (coordenadas Y,X), calcula el desplazamiento correspondiente en pantalla
									; al valor calculado se le suma 32 pixels a la derecha
4C95: 06 00       ld   b,$00		; instrucción modificada desde fuera (con el alto a pintar)
4C97: E5          push hl			;
4C98: D9          exx
4C99: D1          pop  de			; de = posición en pantalla donde copiar los bytes
4C9A: 01 00 00    ld   bc,$0000		; instrucción modificada desde fuera (con el ancho a pintar)
4C9D: ED B0       ldir				; copia los bytes de ancho del buffer de sprites a pantalla
4C9F: 3E 00       ld   a,$00		; instrucción modificada desde fuera (con la distancia en x de lo que no es visible)
4CA1: 85          add  a,l			; hl = hl + a
4CA2: 6F          ld   l,a
4CA3: 8C          adc  a,h
4CA4: 95          sub  l
4CA5: 67          ld   h,a
4CA6: D9          exx

; devuelve en hl la dirección de la siguiente línea de pantalla
4CA7: 7C          ld   a,h
4CA8: C6 08       add  a,$08
4CAA: 67          ld   h,a			; pasa al siguiente banco
4CAB: E6 38       and  $38
4CAD: 20 0D       jr   nz,$4CBC
4CAF: 7C          ld   a,h
4CB0: D6 08       sub  $08			; vuelve al banco anterior
4CB2: E6 C7       and  $C7
4CB4: 67          ld   h,a
4CB5: 3E 50       ld   a,$50		; cada línea ocupa 0x50 bytes
4CB7: 85          add  a,l			; hl = hl + a
4CB8: 6F          ld   l,a
4CB9: 8C          adc  a,h
4CBA: 95          sub  l
4CBB: 67          ld   h,a

4CBC: 10 D9       djnz $4C97		; repite hasta que no se haya terminado
4CBE: C9          ret

; comprueba las dimensiones mínimas del sprite (para borrar el sprite viejo) y actualiza 0x2dd5 y 0x2dd7
4CBF: 3A D5 2D    ld   a,($2DD5)	; obtiene la posición inicial en x del tile en el que empieza el sprite (Xtile)
4CC2: 95          sub  l
4CC3: 38 1E       jr   c,$4CE3		; si Xtile < X2, salta
4CC5: 4F          ld   c,a			; c = Xtile - X2
4CC6: 3A D7 2D    ld   a,($2DD7)	; obtiene el ancho del sprite ampliado
4CC9: 81          add  a,c			; le suma la diferencia
4CCA: BB          cp   e			; lo compara con el ancho mínimo del sprite
4CCB: 38 01       jr   c,$4CCE		; si el ancho ampliado es menor que el mínimo, salta
4CCD: 5F          ld   e,a			; en otro caso, e = ancho ampliado + Xtile - Xspr (coge el mayor ancho del sprite)

4CCE: 7D          ld   a,l
4CCF: E6 03       and  $03
4CD1: 4F          ld   c,a			; c = posición x dentro del tile actual
4CD2: 7D          ld   a,l
4CD3: E6 FC       and  $FC
4CD5: 32 D5 2D    ld   ($2DD5),a	; actualiza la posición inicial en x del tile en el que empieza el sprite
4CD8: 7B          ld   a,e			; obtiene el ancho del sprite
4CD9: 81          add  a,c
4CDA: C6 03       add  a,$03
4CDC: E6 FC       and  $FC			; redondea el ancho al tile superior
4CDE: 32 D7 2D    ld   ($2DD7),a	; actualiza en ancho del sprite
4CE1: 18 12       jr   $4CF5

; aquí llega si la posición del sprite en x > que el inicio de un tile en x
4CE3: ED 44       neg				; a = diferencia de posición en x del tile a x2
4CE5: 83          add  a,e			; añade al ancho del sprite la diferencia en x entre el inicio del sprite y el del tile asociado al sprite
4CE6: 4F          ld   c,a
4CE7: 3A D7 2D    ld   a,($2DD7)	; a = ancho ampliado del sprite
4CEA: B9          cp   c
4CEB: 30 08       jr   nc,$4CF5		; si el ancho ampliado del sprite >= el ancho mínimo del sprite, comprueba las y
4CED: 79          ld   a,c			; en otro caso, amplia el ancho mínimo del sprite
4CEE: C6 03       add  a,$03
4CF0: E6 FC       and  $FC			; redondea el ancho al tile superior
4CF2: 32 D7 2D    ld   ($2DD7),a	; guarda el ancho del sprite

; ahora hace lo mismo para y
4CF5: 3A D6 2D    ld   a,($2DD6)	; obtiene la posición inicial en y del tile en el que empieza el sprite (Ytile)
4CF8: 94          sub  h
4CF9: 38 1D       jr   c,$4D18		; si Ytile < Y2, salta
4CFB: 4F          ld   c,a			; c = Ytile - Y2
4CFC: 3A D8 2D    ld   a,($2DD8)	; obtiene el alto del sprite ampliado
4CFF: 81          add  a,c
4D00: BA          cp   d			; comprueba con el alto mínimo
4D01: 38 01       jr   c,$4D04		; si el alto ampliado es menor que el mínimo, salta
4D03: 57          ld   d,a

4D04: 7C          ld   a,h
4D05: E6 07       and  $07
4D07: 4F          ld   c,a			; c = posición y dentro del tile actual
4D08: 7C          ld   a,h
4D09: E6 F8       and  $F8
4D0B: 32 D6 2D    ld   ($2DD6),a	; actualiza la posición inicial en y del tile en el que empieza el sprite
4D0E: 7A          ld   a,d			; obtiene el alto del sprite
4D0F: 81          add  a,c
4D10: C6 07       add  a,$07
4D12: E6 F8       and  $F8			; redondea el alto al tile superior
4D14: 32 D8 2D    ld   ($2DD8),a	; actualiza el alto del sprite
4D17: C9          ret

4D18: ED 44       neg				; a = |Ytile - Y2|
4D1A: 82          add  a,d			; resta del alto del sprite lo que sobresale del inicio del tile en y
4D1B: 4F          ld   c,a
4D1C: 3A D8 2D    ld   a,($2DD8)	; a = alto del sprite
4D1F: B9          cp   c
4D20: D0          ret  nc			; si el alto del sprite >= el alto mínimo, sale
4D21: 79          ld   a,c
4D22: 18 EC       jr   $4D10		; redondea el alto al tile superior y actualiza el alto del sprite

; multiplica a por hl y devuelve el resultado en de
4D24: 06 08       ld   b,$08		; 8 bits como mucho
4D26: 11 00 00    ld   de,$0000		; resultado = 0
4D29: CB 3F       srl  a
4D2B: 30 04       jr   nc,$4D31		; si el bit menos significativo del número es 0, salta
4D2D: E5          push hl
4D2E: 19          add  hl,de		; si el bit era 1, suma
4D2F: EB          ex   de,hl
4D30: E1          pop  hl
4D31: 29          add  hl,hl		; hl = hl*2
4D32: 10 F5       djnz $4D29		; repite para el resto de bits
4D34: C9          ret

; devuelve en hl la posición inicial del tile en el que empieza el sprite (h = pos inicial Y en pixels, l = posición inicial X en bytes)
; devuelve en de las dimensiones del sprite ampliadas para abarcar todos los tiles en los que se va a dibujar el sprite
;  en hl se le pasa la posición incial (h = pos Y en pixels, l = pos X en bytes)
;  en de se le pasa las dimensiones del sprite (d = alto en pixels, e = ancho en bytes)
4D35: 7C          ld   a,h
4D36: E6 07       and  $07
4D38: 4F          ld   c,a		; c = h & 0x07 (pos Y dentro del tile actual (en pixels))
4D39: 7C          ld   a,h
4D3A: E6 F8       and  $F8
4D3C: 67          ld   h,a		; h = h & 0xf8 (posición del tile actual en Y (en pixels))
4D3D: 7D          ld   a,l
4D3E: E6 03       and  $03
4D40: 47          ld   b,a		; b = l & 0x03 (pos X dentro del tile actual (en bytes))
4D41: 7D          ld   a,l
4D42: E6 FC       and  $FC
4D44: 6F          ld   l,a		; l = l & 0xfc (posición del tile actual en X (en bytes))
4D45: 7A          ld   a,d
4D46: 81          add  a,c
4D47: C6 07       add  a,$07
4D49: E6 F8       and  $F8
4D4B: 57          ld   d,a		; calcula el alto del objeto para que abarque todos los tiles en los que se va a dibujar (d = (d + (h & 0x07) + 7) & 0xf8)
4D4C: 7B          ld   a,e
4D4D: 80          add  a,b
4D4E: C6 03       add  a,$03
4D50: E6 FC       and  $FC
4D52: 5F          ld   e,a		; calcula el ancho del objeto para que abarque todos los tiles en los que se va a dibujar (e = (d + (l & 0x03) + 3) & 0xfc)
4D53: C9          ret


; dado l y e, y h y d, que son las posiciones iniciales y longitudes de los sprites original y actual, comprueba si el sprite actual puede
;  verse en la zona del sprite original. Si puede verse, lo recorta. En otro caso, salta a por otro sprite actual
; en a devuelve la longitud a pintar del sprite actual para la coordenada que se pasa
; en h devuelve la distancia desde el inicio del sprite actual al incio del sprite original
; en l devuelve la distancia desde el inicio del sprite original al inicio del sprite actual
4D54: 7D          ld   a,l		; a = posición inicial del sprite original
4D55: 94          sub  h		; a = distancia del sprite original al sprite actual
4D56: 28 11       jr   z,$4D69	; si el sprite original empieza en el mismo punto que el sprite actual, salta
4D58: 38 17       jr   c,$4D71	; si el sprite original empieza antes que el actual, salta

; si llega aquí, el sprite actual empieza antes que el sprite original
4D5A: BA          cp   d		; si la distancia entre los sprites es >= que el ancho del sprite actual, el sprite actual no es visible
4D5B: 30 24       jr   nc,$4D81	;  en la zona del sprite original, por lo que salta a procesar otro sprite

4D5D: 67          ld   h,a		; h = distancia desde el inicio del sprite actual al incio del sprite original
4D5E: 2E 00       ld   l,$00
4D60: 83          add  a,e		; si la distancia entre los sprites + la longitud del sprite original >= d, salta
4D61: BA          cp   d
4D62: 30 02       jr   nc,$4D66
4D64: 7B          ld   a,e		; en otro caso, el sprite original está dentro del sprite actual, por lo que dibuja solo la longitud del sprite original
4D65: C9          ret
4D66: 7A          ld   a,d		; como el sprite original no está completamente dentro del sprite actual, dibuja solo la parte del sprite
4D67: 94          sub  h		;  actual que se superpone con el sprite original
4D68: C9          ret

; aquí llega si el sprite actual empieza en el mismo punto que el original
4D69: 21 00 00    ld   hl,$0000
4D6C: 7B          ld   a,e		; a = ancho ampliado del sprite (en bytes)
4D6D: BA          cp   d		; compara el ancho ampliado con el ancho original
4D6E: D8          ret  c		; si el ancho ampliado del sprite original es < que el ancho del sprite actual, sale devolviendo el ancho original
4D6F: 7A          ld   a,d		; en otro caso, devuelve el ancho del sprite actual
4D70: C9          ret

4D71: 26 00       ld   h,$00
4D73: ED 44       neg			; a = distancia entre la posición incial del sprite original y del actual
4D75: 6F          ld   l,a
4D76: BB          cp   e		; si la distancia entre el origen de los 2 sprites es >= que el ancho ampliado del sprite original, salta al siguiente sprite
4D77: 30 08       jr   nc,$4D81
4D79: ED 44       neg
4D7B: 83          add  a,e		; en otro caso, guarda en a la longitud de la parte visible del sprite actual en el sprite original
4D7C: BA          cp   d		; si esa longitud es <= que la longitud del sprite actual, sale
4D7D: D8          ret  c
4D7E: C8          ret  z
4D7F: 7A          ld   a,d		; en otro caso, modifica la longitud a pintar del sprite actual
4D80: C9          ret

4D81: E1          pop  hl		; saca el sprite de la pila
4D82: C3 2E 4A    jp   $4A2E	; sigue procesando el resto de sprites de la pila

4D85: C9          ret				; esta instrucción se cambia desde fuera y puede cambiarse por un nop
4D86: CD A5 37    call $37A5		; devuelve la dirección del buffer de tiles asociada en hl
4D89: D8          ret  c
4D8A: DD CB 00 BE res  7,(ix+$00)	; limpia el bit mas significativo del buffer de tiles
4D8E: C9          ret

4D8F: E1          pop  hl
4D90: 11 80 8D    ld   de,$8D80
4D93: A7          and  a
4D94: ED 52       sbc  hl,de
4D96: D8          ret  c
4D97: 11 80 07    ld   de,$0780
4D9A: ED 52       sbc  hl,de
4D9C: 3F          ccf				; complementa el flag de acarreo
4D9D: C9          ret

; copia en el buffer de sprites los tiles que están entre la profundidad inicial y la final
4D9E: 2A D9 4D    ld   hl,($4DD9)	; obtiene el límite superior de profundidad de la iteración anterior y lo coloca como límite inferior
4DA1: 22 DC 4D    ld   ($4DDC),hl	;  de profundidad para esta iteración
4DA4: 0C          inc  c
4DA5: 04          inc  b
4DA6: ED 43 D9 4D ld   ($4DD9),bc	; coloca el límite superior de profundidad para esta iteración
4DAA: D9          exx
4DAB: ED 5B FA 4A ld   de,($4AFA)	; de = dirección del buffer de sprites asignada
4DAF: D9          exx

4DB0: DD 2A 95 30 ld   ix,($3095)	; ix = posición del buffer de tiles
4DB4: ED 4B D7 2D ld   bc,($2DD7)	; obtiene el ancho y alto del sprite
4DB8: CB 38       srl  b			; b = b/8 (número de tiles que ocupa el sprite en y)
4DBA: CB 38       srl  b
4DBC: CB 38       srl  b
4DBE: CB 39       srl  c			; c = c/4 (número de tiles que ocupa el sprite en x)
4DC0: CB 39       srl  c

4DC2: C5          push bc			; guarda los contadores del bucle
4DC3: DD E5       push ix			; guarda la posición actual en el buffer de tiles
4DC5: D9          exx
4DC6: D5          push de			; guarda la posición actual en el buffer de sprites
4DC7: D9          exx
4DC8: 41          ld   b,c			; b = número de tiles del sprite en x
4DC9: 0E 02       ld   c,$02		; cada tile tiene 2 prioridades
4DCB: 21 E6 4D    ld   hl,$4DE6
4DCE: 22 E4 4D    ld   ($4DE4),hl	; cambia un salto

4DD1: DD 7E 02    ld   a,(ix+$02)	; lee el número de tile de la entrada actual del buffer de tiles
4DD4: A7          and  a
4DD5: 28 44       jr   z,$4E1B		; si no hay un tile, avanza al siguiente tile o a la siguiente prioridad
4DD7: D9          exx
4DD8: 01 00 00    ld   bc,$0000		; instrucción modificada desde fuera con el límite superior de profundidad
4DDB: 21 00 00    ld   hl,$0000		; instrucción modificada desde fuera con el límite inferior de profundidad
4DDE: DD 7E 00    ld   a,(ix+$00)	; lee la profundidad en x del tile actual
4DE1: CB 7F       bit  7,a			; si en esta llamada no se ha pintado en esta posición del buffer de tiles, comprueba si hay que pintar el
									; tile que hay en esta capa de profundidad. Si se ha pintado y el tile de esta capa se había pintado
									; en otra iteración anterior, lo combina sin comprobar la profundidad
4DE3: C2 E6 4D    jp   nz,$4DE6		; instrucción modificada desde fuera (salto cambiado desde fuera)
4DE6: BD          cp   l			; compara la profundidad en x del tile con la profundidad mínima en x
4DE7: DD 7E 01    ld   a,(ix+$01)	; lee la profundidad en y del tile actual
4DEA: 30 05       jr   nc,$4DF1		; si prof tile en x >= profundidad mínima en x, salta
4DEC: BC          cp   h
4DED: 30 02       jr   nc,$4DF1		; si prof tile en y >= profundidad mínima en y, salta
4DEF: 18 29       jr   $4E1A		; avanza al siguiente tile o a la siguiente prioridad (el tile tiene menor profundidad que la mínima)

4DF1: B8          cp   b			; si prof tile en y >= posición en y del sprite
4DF2: 30 26       jr   nc,$4E1A		;  si el sprite queda oculto por el tile, avanza al siguiente tile o a la siguiente prioridad
4DF4: DD 7E 00    ld   a,(ix+$00)	; lee la profundidad en x del tile actual
4DF7: B9          cp   c			; si prof tile en x >= posición en x del sprite
4DF8: 30 20       jr   nc,$4E1A		;  si el sprite queda oculto por el tile, avanza al siguiente tile o a la siguiente prioridad

; aquí llega si el tile tiene mayor profundidad que el mínimo y menor profundidad que el sprite
4DFA: DD CB 00 7E bit  7,(ix+$00)
4DFE: 20 1A       jr   nz,$4E1A		; si el tile actual ya se ha dibujado, avanza al siguiente tile o a la siguiente prioridad
4E00: 21 11 4E    ld   hl,$4E11
4E03: 22 E4 4D    ld   ($4DE4),hl	; modifica un salto para indicar que en esta llamada ha pintado algún tile para esta posición del buffer de tiles
4E06: D5          push de
4E07: CD A5 37    call $37A5		; si ix está dentro del buffer de tiles, cf = 0
4E0A: D1          pop  de
4E0B: 38 04       jr   c,$4E11		; si el tile actual no está dentro del buffer de tiles, salta
4E0D: DD CB 00 FE set  7,(ix+$00)	; indica que se ha procesado este tile

4E11: D5          push de
4E12: D9          exx
4E13: C5          push bc
4E14: CD 49 4E    call $4E49		; combina el tile de ix+2 con lo que haya en la posición actual del buffer de sprites
4E17: C1          pop  bc
4E18: D9          exx
4E19: D1          pop  de

4E1A: D9          exx
4E1B: CD 85 4D    call $4D85		; ret (si no ha terminado de procesar los sprites de la pila) o limpia el bit 7 de (ix+0) del buffer de tiles (si es una posición válida del buffer)
4E1E: DD 23       inc  ix			; pasa al tile de mayor prioridad del buffer de tiles
4E20: DD 23       inc  ix
4E22: DD 23       inc  ix
4E24: 0D          dec  c
4E25: 20 AA       jr   nz,$4DD1		; repite hasta que se hayan completado las prioridades de la entrada del buffer de tiles

4E27: D9          exx
4E28: 13          inc  de			; pasa a la posición del siguiente tile en x del buffer de sprites
4E29: 13          inc  de
4E2A: 13          inc  de
4E2B: 13          inc  de
4E2C: D9          exx
4E2D: 10 9A       djnz $4DC9		; repite mientras no se termine en x
4E2F: D9          exx

4E30: D1          pop  de
4E31: 2A D7 2D    ld   hl,($2DD7)
4E34: 26 00       ld   h,$00		; hl = ancho del sprite
4E36: 29          add  hl,hl
4E37: 29          add  hl,hl
4E38: 29          add  hl,hl		; hl = ancho del sprite*8
4E39: 19          add  hl,de		; pasa a la posición del siguiente tile en y del buffer de sprites
4E3A: EB          ex   de,hl
4E3B: D9          exx
4E3C: DD E1       pop  ix			; recupera la posición del buffer de tiles
4E3E: 01 60 00    ld   bc,$0060
4E41: DD 09       add  ix,bc		; pasa a la siguiente línea del buffer de tiles
4E43: C1          pop  bc
4E44: 05          dec  b			; repite hasta que se acaben los tiles en y
4E45: C2 C2 4D    jp   nz,$4DC2
4E48: C9          ret

; aquí entra con ix apuntando a alguna entrada del buffer de tiles y de apuntando a alguna posición del buffer de sprites
; combina el tile de la entrada actual de ix en la posición actual del buffer de sprites
4E49: 26 00       ld   h,$00
4E4B: DD 6E 02    ld   l,(ix+$02)	; hl = número de tile de la entrada actual
4E4E: 4D          ld   c,l			; c = número de tile de la entrada actual
4E4F: 29          add  hl,hl
4E50: 29          add  hl,hl
4E51: 29          add  hl,hl
4E52: 29          add  hl,hl
4E53: 29          add  hl,hl		; hl = hl*32 (cada tile ocupa 32 bytes)
4E54: 3E 6D       ld   a,$6D		; a partir de 0x6d00 están los gráficos de los tiles que forman las pantallas
4E56: 84          add  a,h
4E57: 67          ld   h,a			; hl = puntero a los datos gráficos del tile correspondiente

4E58: 79          ld   a,c
4E59: FE 0B       cp   $0B			; si el gráfico es menor que el 0x0b (gráficos sin transparencia), salta (caso más sencillo)
4E5B: 3A D7 2D    ld   a,($2DD7)	; a = ancho x del sprite
4E5E: 38 32       jr   c,$4E92
4E60: D6 04       sub  $04			; ancho x = ancho x - 4
4E62: 32 87 4E    ld   ($4E87),a	: modifica una instrucción
4E65: DD CB 02 7E bit  7,(ix+$02)	; comprueba que tabla usar según el número de tile que haya
4E69: D9          exx
4E6A: 26 9D       ld   h,$9D		; tablas 0 y 1
4E6C: 28 02       jr   z,$4E70
4E6E: 26 9F       ld   h,$9F		; tablas 2 y 3
4E70: D9          exx
4E71: 0E 08       ld   c,$08		; c = 8 pixels de alto
4E73: 06 04       ld   b,$04		; b = 4 bytes de ancho (16 pixels)
4E75: 7E          ld   a,(hl)		; obtiene un byte del gráfico
4E76: D9          exx
4E77: 6F          ld   l,a			; indexa en las tablas de ands y ors con el byte del gráfico
4E78: 4E          ld   c,(hl)		; obtiene el or
4E79: 24          inc  h
4E7A: 46          ld   b,(hl)		; obtiene el and
4E7B: 25          dec  h
4E7C: 1A          ld   a,(de)		; obtiene un valor del buffer de sprites
4E7D: A0          and  b			; aplica el valor a las máscaras
4E7E: B1          or   c
4E7F: 12          ld   (de),a		; graba el valor obtenido combinando el fondo con el sprite
4E80: 13          inc  de			; avanza a la siguiente posición del buffer
4E81: D9          exx
4E82: 23          inc  hl			; avanza al siguiente byte del gráfico
4E83: 10 F0       djnz $4E75
4E85: D9          exx
4E86: 3E 00       ld   a,$00		; instrucción modificada desde fuera con el ancho - 4
4E88: 83          add  a,e			; de = de + a (pasa a la siguiente línea del sprite)
4E89: 5F          ld   e,a
4E8A: 8A          adc  a,d
4E8B: 93          sub  e
4E8C: 57          ld   d,a
4E8D: D9          exx
4E8E: 0D          dec  c
4E8F: 20 E2       jr   nz,$4E73		; repite hasta que se complete el alto del tile
4E91: C9          ret

; aquí llega si el número de tile era < 0x0b (son gráficos sin transparencia)
4E92: D6 04       sub  $04			; ancho x = ancho x - 4
4E94: 32 A8 4E    ld   ($4EA8),a	; modifica una instrucción
4E97: E5          push hl
4E98: D9          exx
4E99: E1          pop  hl			; hl = dirección del gráfico
4E9A: 01 04 08    ld   bc,$0804		; 8 pixels de alto, 4 bytes de ancho (16 pixels)
4E9D: 0E 08       ld   c,$08		; esta instrucción no tiene ninguna utilidad aqui (???)
4E9F: ED A0       ldi				; copia los 16 pixels de la linea del tile al buffer de sprites
4EA1: ED A0       ldi
4EA3: ED A0       ldi
4EA5: ED A0       ldi
4EA7: 3E 00       ld   a,$00		; instrucción modificada desde fuera (con el ancho - 4)
4EA9: 83          add  a,e			; de = de + a (pasa a la siguiente línea del sprite)
4EAA: 5F          ld   e,a
4EAB: 8A          adc  a,d
4EAC: 93          sub  e
4EAD: 57          ld   d,a
4EAE: 10 ED       djnz $4E9D		; repite para el resto de líneas del tile
4EB0: D9          exx
4EB1: C9          ret
; ----------------------------- fin del dibujado de sprites ------------------------------

; ------------------- código del dibujado del buffer de tiles -----------------------------------

; dibuja en pantalla el contenido de la rejilla desde el centro hacia afuera
4EB2: 11 A4 C2    ld   de,$C2A4			; de = (144, 64)
4EB5: DD 21 AA 90 ld   ix,$90AA			; ix = (7, 8)

; modifica unas instrucciones
4EB9: 3E 04       ld   a,$04			; inicialmente dibuja 4 posiciones verticales hacia abajo
4EBB: 32 CC 4E    ld   ($4ECC),a
4EBE: 3C          inc  a
4EBF: 32 F3 4E    ld   ($4EF3),a		; inicialmente dibuja 5 posiciones verticales hacia arriba
4EC2: 3E 01       ld   a,$01
4EC4: 32 E1 4E    ld   ($4EE1),a		; inicialmente dibuja 1 posición horizontal hacia la derecha
4EC7: 3C          inc  a
4EC8: 32 05 4F    ld   ($4F05),a		; inicialmente dibuja 2 posiciones horizontal hacia la izquierda

4ECB: 3E 14       ld   a,$14			; instrucción modificada desde fuera
4ECD: FE 14       cp   $14				; si dibuja más de 20 posiciones verticales, sale
4ECF: D0          ret  nc
4ED0: 47          ld   b,a				; b = número de posiciones verticales a dibujar (hacia abajo)
4ED1: 3C          inc  a
4ED2: 3C          inc  a
4ED3: 32 CC 4E    ld   ($4ECC),a		; en la próxima iteración dibujará 2 posiciones verticales más hacia abajo
4ED6: 78          ld   a,b				; a = número de posiciones a dibujar
4ED7: 01 60 00    ld   bc,$0060			; bc = tamaño entre líneas de la rejilla
4EDA: 21 50 00    ld   hl,$0050			; hl = tamaño entre líneas en la memoria de vídeo
4EDD: CD 18 4F    call $4F18			; dibuja a posiciones verticales de la rejilla en la memoria de video
4EE0: 3E 0F       ld   a,$0F			; instrucción modificada desde fuera

4EE2: 47          ld   b,a
4EE3: 3C          inc  a
4EE4: 3C          inc  a
4EE5: 32 E1 4E    ld   ($4EE1),a		; en la próxima iteración dibujará 2 posiciones horizontales más hacia la derecha
4EE8: 78          ld   a,b				; a = número de posiciones horizontales a dibujar
4EE9: 01 06 00    ld   bc,$0006			; bc = tamaño entre posiciones x de la rejilla
4EEC: 21 04 00    ld   hl,$0004			; hl = tamaño entre cada 16 pixels en la memoria de video
4EEF: CD 18 4F    call $4F18			; dibuja a posiciones horizontales de la rejilla en la memoria de video

4EF2: 3E 0F       ld   a,$0F			; instrucción modificada desde fuera
4EF4: 47          ld   b,a
4EF5: 3C          inc  a
4EF6: 3C          inc  a
4EF7: 32 F3 4E    ld   ($4EF3),a		; en la próxima iteración dibujará 2 posiciones verticales más hacia arriba
4EFA: 78          ld   a,b
4EFB: 01 A0 FF    ld   bc,$FFA0			; bc = valor para volver a la línea anterior de la rejilla
4EFE: 21 B0 FF    ld   hl,$FFB0			; hl = valor para volver a la línea anterior de la pantalla
4F01: CD 18 4F    call $4F18			; dibuja a posiciones verticales de la rejilla en la memoria de video
4F04: 3E 0F       ld   a,$0F			; instrucción modificada desde fuera
4F06: 47          ld   b,a
4F07: 3C          inc  a
4F08: 3C          inc  a
4F09: 32 05 4F    ld   ($4F05),a		; en la próxima iteración dibujará 2 posiciones horizontales más hacia la izquierda
4F0C: 78          ld   a,b
4F0D: 01 FA FF    ld   bc,$FFFA			; bc = valor para volver a la anterior posicion x de la rejilla
4F10: 21 FC FF    ld   hl,$FFFC			; bc = valor para volver a la anterior posicion x de la pantalla
4F13: CD 18 4F    call $4F18			; dibuja a posiciones horizontales de la rejilla en la memoria de video
4F16: 18 B3       jr   $4ECB			; repite hasta que se termine

; dibuja a posiciones horizontales o verticales de la rejilla en la memoria de video
; a = número de posiciones a dibujar
; bc = tamaño entre posiciones de la rejilla
; hl = tamaño entre posiciones en la memoria de vídeo
; ix = posición en el buffer
; de = posición en la memoria de vídeo
4F18: 22 35 4F    ld   ($4F35),hl		; rellena unos parámetros
4F1B: ED 43 30 4F ld   ($4F30),bc

4F1F: 47          ld   b,a				; b = número de posiciones a dibujar

4F20: C5          push bc
4F21: DD 7E 02    ld   a,(ix+$02)		; lee el número de gráfico a dibujar (fondo)
4F24: A7          and  a
4F25: C4 3D 4F    call nz,$4F3D			; copia un gráfico 16x8 a la memoria de video (de), combinandolo con lo que había
4F28: DD 7E 05    ld   a,(ix+$05)		; lee el número de gráfico a dibujar (primer plano))
4F2B: A7          and  a
4F2C: C4 3D 4F    call nz,$4F3D			; copia un gráfico 16x8 a la memoria de video (de), combinandolo con lo que había

4F2F: 01 00 00    ld   bc,$0000			; instrucción modificada desde fuera
4F32: DD 09       add  ix,bc			; pasa a la siguiente posición de pantalla
4F34: 21 00 00    ld   hl,$0000			; instrucción modificada desde fuera
4F37: 19          add  hl,de			; pasa a la siguiente posición en la rejilla
4F38: EB          ex   de,hl
4F39: C1          pop  bc
4F3A: 10 E4       djnz $4F20			; repite para el resto de posiciones
4F3C: C9          ret

; copia el gráfico a (16x8) en la memoria de video (de), combinandolo con lo que había
; a = bits 7-0: número de gráfico. El bit 7 = indica que color sirve de máscara (el 2 o el 1)
; de = posición en la memoria de video
4F3D: D5          push de
4F3E: D9          exx				; intercambia todos los registros
4F3F: 26 00       ld   h,$00
4F41: 6F          ld   l,a
4F42: 29          add  hl,hl
4F43: 29          add  hl,hl
4F44: 29          add  hl,hl
4F45: 29          add  hl,hl
4F46: 29          add  hl,hl		; hl = dirección del gráfico (32*a)
4F47: 4F          ld   c,a			; c = número de gráfico
4F48: 3E 6D       ld   a,$6D		; los gráficos de la abadía están a partir de 0x6d00
4F4A: 84          add  a,h
4F4B: 67          ld   h,a			; hl apunta al gráfico correspondiente
4F4C: CB 79       bit  7,c
4F4E: D9          exx				; intercambia todos los registros
4F4F: 26 9D       ld   h,$9D		; dependiendo del bit 7 escoge una tabla AND y OR
4F51: 28 02       jr   z,$4F55		; si el bit 7 no está puesto salta
4F53: 26 9F       ld   h,$9F
4F55: D9          exx				; intercambia todos los registros
4F56: 0E 08       ld   c,$08		; 8 pixels de alto
4F58: 06 04       ld   b,$04		; 4 bytes de ancho (16 pixels)

4F5A: 7E          ld   a,(hl)		; lee un byte del gráfico
4F5B: D9          exx				; intercambia todos los registros
4F5C: 6F          ld   l,a			; indexa en las tablas
4F5D: 4E          ld   c,(hl)		; c = valor de la tabla OR
4F5E: 24          inc  h
4F5F: 46          ld   b,(hl)		; b = valor de la tabla AND
4F60: 1A          ld   a,(de)		; a = lee lo que hay en pantalla
4F61: A0          and  b			; combina el gráfico con lo que hay en pantalla
4F62: B1          or   c
4F63: 12          ld   (de),a		; actualiza la pantalla
4F64: 25          dec  h
4F65: 13          inc  de			; avanza a la siguiente posición en x (pantalla)
4F66: D9          exx
4F67: 23          inc  hl			; avanza al siguiente byte gráfico
4F68: 10 F0       djnz $4F5A		; termina la línea
4F6A: D9          exx
4F6B: 3E FC       ld   a,$FC		; pasa a la siguiente línea de pantalla
4F6D: 83          add  a,e
4F6E: 5F          ld   e,a
4F6F: 3E 07       ld   a,$07
4F71: 8A          adc  a,d
4F72: 57          ld   d,a
4F73: D9          exx
4F74: 0D          dec  c
4F75: 20 E1       jr   nz,$4F58		; repite hasta que se acabe el alto
4F77: D1          pop  de
4F78: C9          ret

4F79: 00          nop
  ld   a,$6D		; los gráficos de la abadía están a partir de 0x6d00
4F4A: 84          add  a,h
4F4B: 67          ld   h,a			; hl apunta al gráfico correspondiente
4F4C: CB 79       bit  7,c
4F4E: D9          exx				; intercambia todos los registros
4F4F: 26 9D       ld   h,$9D		; dependiendo del bit 7 escoge una tabla AND y OR
4F51: 28 02       jr   z,$4F55		; si el bit 7 no está puesto salta
4F53: 26 9F       ld   h,$9F
4F55: D9          exx				; intercambia todos los registros
4F56: 0E 08       ld   c,$08		; 8 pixels de alto
4F58: 06 04       ld   b,$04		; 4 bytes de ancho (16 pixels)

4F5A: 7E          ld   a,(hl)		; lee un byte del gráfico
4F5B: D9          exx				; intercambia todos los registros
4F5C: 6F          ld   l,a			; indexa en las tablas
4F5D: 4E          ld   c,(hl)		; c = valor de la tabla OR
4F5E: 24          inc  h
4F5F: 46          ld   b,(hl)		; b = valor de la tabla AND
4F60: 1A          ld   a,(de)		; a = lee lo que hay en pantalla
4F61: A0          and  b			; combina el gráfico con lo que hay en pantalla
4F62: B1          or   c
4F63: 12          ld   (de),a		; actualiza la pantalla
4F64: 25          dec  h
4F65: 13          inc  de			; avanza a la siguiente posición en x (pantalla)
4F66: D9          exx
4F67: 23          inc  hl			; avanza al siguiente byte gráfico
4F68: 10 F0       djnz $4F5A		; termina la línea
4F6A: D9          exx
4F6B: 3E FC       ld   a,$FC		; pasa a la siguiente línea de pantalla
4F6D: 83          add  a,e
4F6E: 5F          ld   e,a
4F6F: 3E 07       ld   a,$07
4F71: 8A          adc  a,d
4F72: 57          ld   d,a
4F73: D9          exx
4F74: 0D          dec  c
4F75: 20 E1       jr   nz,$4F58		; repite hasta que se acabe el alto
4F77: D1          pop  de
4F78: C9          ret

4F79: 00          nop

; ------------------- fin del dibujado del buffer de tiles -----------------------------------

; tabla de duración de las etapas del día para cada día y periodo del día
4F7A: 	00 00 00 00 00 00 00
		00 00 05 00 05 00 00
		00 00 05 00 05 00 00
		0F 00 00 00 05 00 00
		0F 00 05 00 00 00 00
		0F 00 05 00 05 00 00
		0F 00 00				; el día 7 sólo tiene hasta tercia porque el juego se acaba en ese momento del día

; tabla usada para rellenar el número del día en el marcador
4FA7: 	00 02 00	; -I-
		00 02 02	; -II
		02 02 02	; III
		00 02 01  	; -IV
		00 01 00	; -V-
		00 01 02	; -VI
		01 02 02 	; VII

; tabla de los nombres de los momentos del día
4FBC: 	-NOCHE-
		-PRIMA-
		TERCIA-
		-SEXTA-
		-NONA--
		VISPERAS
		COMPLETAS

4FED: C9          ret

; imprime la frase que sigue a la llamada en la posición de pantalla actual
4FEE: DD E1       pop  ix				; obtiene en ix la dirección de retorno
4FF0: DD 7E 00    ld   a,(ix+$00)		; lee un byte de la dirección de retorno
4FF3: DD 23       inc  ix				; avanza la dirección de retorno y la mete en pila
4FF5: DD E5       push ix
4FF7: FE FF       cp   $FF
4FF9: C8          ret  z				; si lee 0xff, sale
4FFA: E6 7F       and  $7F				; ajusta el caracter entre 0 y 127
4FFC: CD 13 3B    call $3B13			; imprime el caracter que hay en a en la pantalla
4FFF: 18 ED       jr   $4FEE			; repite hasta que se acabe la frase

; limpia la parte del marcador donde se muestran las frases
5001: 06 08       ld   b,$08			; 8 líneas de alto
5003: 21 58 E6    ld   hl,$E658			; apunta a pantalla (96, 164)
5006: 0E 1F       ld   c,$1F
5008: C5          push bc
5009: E5          push hl
500A: 5D          ld   e,l				; de = hl
500B: 54          ld   d,h
500C: 13          inc  de
500D: 36 FF       ld   (hl),$FF
500F: 06 00       ld   b,$00
5011: ED B0       ldir					; repite hasta rellenar 128 pixels de esta línea
5013: E1          pop  hl
5014: CD 4D 3A    call $3A4D			; pasa a la siguiente línea de pantalla
5017: C1          pop  bc
5018: 10 EE       djnz $5008
501A: C9          ret

; pone una frase en pantalla e inicia su sonido (si hay otra frase puesta, se interrumpe)
; parámetro = byte leido después de la dirección desde la que se llamó a la rutina
501B: F3          di
501C: AF          xor  a
501D: 32 A1 2D    ld   ($2DA1),a
5020: 32 A2 2D    ld   ($2DA2),a	; indica que no se está reproduciendo ninguna voz
5023: CD 01 50    call $5001		; limpia la parte del marcador donde se muestran las frases

; pone una frase en pantalla e inicia su sonido (siempre y cuando no esté poniendo una)
; parámetro = byte leido después de la dirección desde la que se llamó a la rutina
5026: E1          pop  hl			; dirección de retorno = dirección de retorno + 1
5027: 23          inc  hl
5028: E5          push hl
5029: 3A A1 2D    ld   a,($2DA1)	; lee si hay alguna voz que se está reproduciendo
502C: A7          and  a
502D: C0          ret  nz			; si se está reproduciendo alguna frase, sale

502E: F3          di
502F: 2B          dec  hl			; apunta al parámetro
5030: 11 59 56    ld   de,$5659		; apunta a la tabla de octavas y notas para las frases del juego
5033: 7E          ld   a,(hl)		; lee el parámetro
5034: EB          ex   de,hl
5035: CD 2D 16    call $162D		; indexa en la tabla según el parámetro
5038: 7E          ld   a,(hl)		; lee la nota y octava de la voz y la graba
5039: 32 B7 14    ld   ($14B7),a	; modifican la nota y la octava de la voz del canal3
503C: EB          ex   de,hl
503D: 46          ld   b,(hl)		; vuelve a leer el parámetro
503E: 23          inc  hl
503F: 3E 01       ld   a,$01		; inicia la reproducción de la voz
5041: 32 A1 2D    ld   ($2DA1),a
5044: 32 A2 2D    ld   ($2DA2),a
5047: 32 A0 2D    ld   ($2DA0),a
504A: 21 00 BB    ld   hl,$BB00		; apunta a la tabla de frases
504D: 78          ld   a,b
504E: A7          and  a
504F: C4 5C 50    call nz,$505C		; avanza hasta la frase que se va a decir
5052: 22 9E 2D    ld   ($2D9E),hl	; guarda el puntero a la frase
5055: AF          xor  a
5056: 32 9B 2D    ld   ($2D9B),a	; pone a 0 los caracteres en blanco que quedan por salir para que la frase haya salido totalmente por pantalla
5059: 37          scf
505A: FB          ei
505B: C9          ret

; avanza en la tabla avanzando b entradas (acabadas en 0xff)
505C: 7E          ld   a,(hl)
505D: 23          inc  hl
505E: FE FF       cp   $FF
5060: 20 FA       jr   nz,$505C
5062: 10 F8       djnz $505C
5064: C9          ret

; imprime S:N o borra S:N dependiendo de 0x3c99
5065: DD E5       push ix
5067: 21 1D A4    ld   hl,$A41D		; coloca la posición (116, 164)
506A: 22 97 2D    ld   ($2D97),hl
506D: 3A 99 3C    ld   a,($3C99)
5070: E6 01       and  $01
5072: 28 0A       jr   z,$507E
5074: CD EE 4F    call $4FEE		; imprime la frase que sigue a la llamada en la posición de pantalla actual
	20 20 20 FF
	[3 espacios]
507B: DD E1       pop  ix
507D: C9          ret

507E: CD EE 4F    call $4FEE		; imprime la frase que sigue a la llamada en la posición de pantalla actual
		53 3A 4E FF
		S : N
5085: DD E1       pop  ix
5087: C9          ret

; ---------------------------- código relacionado con coger/dejar objetos ------------------------------------------

; reproduce un sonido dependiendo de a y c
5088: F5          push af
5089: C5          push bc
508A: A1          and  c
508B: F5          push af
508C: CC 2F 10    call z,$102F
508F: F1          pop  af
5090: C4 25 10    call nz,$1025
5093: C1          pop  bc
5094: F1          pop  af
5095: C9          ret

; comprueba si los personajes cogen o dejan algún objeto, y si es una llave, actualiza sus permisos y si puede leer el pergamino, lo lee
5096: DD 21 EC 2D ld   ix,$2DEC			; apunta a la tabla relacionada con los objetos de los personajes
509A: DD 7E 03    ld   a,(ix+$03)		; lee los objetos que tenemos
509D: 32 99 2D    ld   ($2D99),a		; guarda una copia de los objetos que tenemos
50A0: DD 7E 07    ld   a,(ix+$07)		; lee algo de adso y lo guarda en pila
50A3: F5          push af
50A4: 3A F6 2D    ld   a,($2DF6)		; lee los objetos de adso
50A7: F5          push af				; guarda los objetos de adso
50A8: CD F0 50    call $50F0			; comprueba si los personajes cogen algún objeto
50AB: CD 6D 52    call $526D			; comprueba si se deja algún objeto
50AE: CD 41 52    call $5241			; actualiza las puertas a las que pueden entrar guillermo y adso
50B1: 3A F6 2D    ld   a,($2DF6)		; obtiene los objetos de adso
50B4: 4F          ld   c,a
50B5: F1          pop  af				; recupera los objetos originales de adso
50B6: A9          xor  c				; si han cambiado los objetos de adso, reproduce un sonido
50B7: C4 88 50    call nz,$5088

50BA: 3A F3 2D    ld   a,($2DF3)		; lee el resto de objetos de adso
50BD: 4F          ld   c,a
50BE: F1          pop  af				; lee el resto de objetos al entrar de adso
50BF: A9          xor  c
50C0: C4 88 50    call nz,$5088			; si han cambiado los objetos de adso, reproduce un sonido

50C3: 3A EF 2D    ld   a,($2DEF)		; obtiene los objetos que tiene guillermo
50C6: 4F          ld   c,a
50C7: 3A 99 2D    ld   a,($2D99)		; obtiene los objetos que tenía guillermo al entrar
50CA: A9          xor  c
50CB: F5          push af
50CC: C5          push bc
50CD: C4 88 50    call nz,$5088			; si han cambiado los objetos de guillermo, reproduce un sonido

50D0: E6 30       and  $30				; comprueba si hemos cogido las gafas o el pergamino
50D2: 28 08       jr   z,$50DC			;  si no es así, salta
50D4: 79          ld   a,c
50D5: E6 30       and  $30				; comprueba si tenemos las gafas y el pergamino
50D7: FE 30       cp   $30
50D9: CC 2E 56    call z,$562E			; si no se había generado el número romano del enigma de la habitación del espejo, lo genera

50DC: C1          pop  bc
50DD: F1          pop  af				; si han cambiado los objetos de guillermo
50DE: C4 DA 51    call nz,$51DA			; dibuja los objetos indicados por a en el marcador

50E1: 21 08 30    ld   hl,$3008			; apunta a los datos de posición de los objetos
50E4: 01 05 00    ld   bc,$0005
50E7: 3E FF       ld   a,$FF
50E9: BE          cp   (hl)
50EA: C8          ret  z				; si se pasó la última entrada, sale
50EB: CB 86       res  0,(hl)			; limpia el bit 0
50ED: 09          add  hl,bc
50EE: 18 F9       jr   $50E9

; comprueba si los personajes cogen algún objeto
; ix apunta a la tabla relacionada con los objetos de los personajes
50F0: DD 7E 00    ld   a,(ix+$00)	; si ha pasado el último personaje, sale
50F3: FE FF       cp   $FF
50F5: C8          ret  z

50F6: DD 35 06    dec  (ix+$06)
50F9: DD 7E 06    ld   a,(ix+$06)
50FC: FE FF       cp   $FF
50FE: C2 CC 51    jp   nz,$51CC		; si (ix+$06) no era 0 al entrar, salta al siguiente personaje (acaba de coger/dejar un objeto)
5101: DD 34 06    inc  (ix+$06)
5104: CD 4F 53    call $534F		; modifica una rutina con los datos de posición del personaje y su orientación
5107: DD 7E 04    ld   a,(ix+$04)	; lee los objetos que se pueden coger
510A: DD AE 00    xor  (ix+$00)		; elimina de la lista los que ya tenemos
510D: DD A6 04    and  (ix+$04)		; guarda el resultado
5110: 6F          ld   l,a			; h = bits que indican los objetos que podemos coger (2)
5111: DD 7E 05    ld   a,(ix+$05)	; lee la máscara de los objetos que podemos coger
5114: DD AE 03    xor  (ix+$03)		; elimina de la lista los que ya tenemos
5117: DD A6 05    and  (ix+$05)
511A: 67          ld   h,a			; h = bits que indican los objetos que podemos coger
511B: DD 7E 00    ld   a,(ix+$00)
511E: E6 01       and  $01
5120: 32 54 51    ld   ($5154),a	; modifica una instrucción con el bit 0 de (ix+00)

; aquí llega con hl = máscara de los objetos que podemos coger
5123: DD E5       push ix
5125: D9          exx
5126: 21 00 80    ld   hl,$8000		; inicia la comprobación con el objeto representado por el bit 7 de hl
5129: D9          exx
512A: DD 21 1B 2F ld   ix,$2F1B		; ix apunta a los sprites de los objetos
512E: FD 21 08 30 ld   iy,$3008		; ix apunta a las posiciones de los objetos
5132: 29          add  hl,hl		; pasa el bit más significativo al flag de acarreo
5133: E5          push hl
5134: D2 B1 51    jp   nc,$51B1		; si el bit no era 1, no podemos coger el objeto, por lo que salta al siguiente objeto

5137: FD 7E 00    ld   a,(iy+$00)	; comprueba si el objeto se está cogiendo/dejando
513A: CB 47       bit  0,a
513C: C2 B1 51    jp   nz,$51B1		; si el bit 0 es 1, salta al siguiente objeto (el objeto se está cogiendo/dejando?)
513F: CB 77       bit  6,a
5141: C2 B1 51    jp   nz,$51B1		; si el bit 6 es 1, salta al siguiente objeto (se usa este bit???)
5144: FD 66 03    ld   h,(iy+$03)	; hl = posición del objeto
5147: FD 6E 02    ld   l,(iy+$02)
514A: FD 7E 04    ld   a,(iy+$04)	; a = altura del objeto
514D: FD CB 00 7E bit  7,(iy+$00)	; si el objeto no está cogido, salta
5151: 28 13       jr   z,$5166

; si el objeto está cogido en (iy+$02) y en (iy+$03) se guarda la dirección del personaje que lo tiene
5153: 3E 00       ld   a,$00		; instrucción modificada desde fuera con el bit 1 del byte 0 de la entrada de los objetos de los personajes
5155: A7          and  a			;  (que vale 1 si se le pueden quitar objetos al personaje?)
5156: C2 B1 51    jp   nz,$51B1		; si al personaje no puede quitar objetos, salta al siguiente objeto
5159: E5          push hl
515A: 23          inc  hl
515B: 5E          ld   e,(hl)
515C: 23          inc  hl
515D: 56          ld   d,(hl)		; de = [hl]
515E: EB          ex   de,hl		; hl = dirección de datos del personaje que ha cogido el objeto
515F: 5E          ld   e,(hl)
5160: 23          inc  hl
5161: 56          ld   d,(hl)		; de = posición del personaje que ha cogido el objeto
5162: 23          inc  hl
5163: 7E          ld   a,(hl)		; a = altura del personaje que ha cogido el objeto
5164: EB          ex   de,hl		; hl = posición del personaje que ha cogido el objeto
5165: D1          pop  de

; aqui llega con hl = posición del objeto o posición del personaje que tiene el objeto
5166: D6 00       sub  $00			; instrucción modificada con la altura del personaje
5168: FE 05       cp   $05
516A: 30 45       jr   nc,$51B1		; si la diferencia de alturas es > 5, salta a procesar el siguiente objeto
516C: 7D          ld   a,l			; a = pos x del objeto
516D: FE 00       cp   $00			; instrucción modificada con la posición x del personaje + 2*desplazamiento en x según orientación
516F: 20 40       jr   nz,$51B1		; si el personaje no está al lado del objeto y mirandolo en x, salta a procesar el siguiente objeto
5171: 7C          ld   a,h			; a = pos y del objeto
5172: FE 00       cp   $00			; instrucción modificada con la posición y del personaje + 2*desplazamiento en y según orientación
5174: 20 3B       jr   nz,$51B1		; si el personaje no está al lado del objeto y mirandolo en y, salta a procesar el siguiente objeto
5176: FD CB 00 7E bit  7,(iy+$00)	; si el objeto no está cogido por un personaje, salta
517A: 28 0D       jr   z,$5189

517C: 1A          ld   a,(de)
517D: D9          exx
517E: AD          xor  l			; le quita al personaje el objeto que se está procesando
517F: D9          exx
5180: 12          ld   (de),a
5181: 13          inc  de
5182: 13          inc  de
5183: 13          inc  de
5184: 1A          ld   a,(de)
5185: D9          exx
5186: AC          xor  h			; le quita al personaje el objeto que se está procesando
5187: D9          exx
5188: 12          ld   (de),a

5189: CD CE 2A    call $2ACE		; si el sprite es visible, indica que hay que redibujarlo e indica que pase a inactivo después de resturar la zona que ocupaba
518C: E1          pop  hl			; recupera hl (bits que indican que objetos tenemos que probar a coger)
518D: D1          pop  de			; de = puntero a las caracteristicas de los objetos del personaje
518E: D5          push de
518F: DD E1       pop  ix
5191: FD 73 02    ld   (iy+$02),e	; guarda la dirección de los datos del personaje que tiene el objeto donde antes se guardaba la posición del objeto
5194: FD 72 03    ld   (iy+$03),d
5197: FD 36 00 81 ld   (iy+$00),$81	; indica que el objeto se ha cogido
519B: DD 36 06 10 ld   (ix+$06),$10	; inicia el contador
519F: D9          exx
51A0: DD 7E 00    ld   a,(ix+$00)
51A3: B5          or   l			; indica que el personaje tiene el objeto
51A4: DD 77 00    ld   (ix+$00),a
51A7: DD 7E 03    ld   a,(ix+$03)
51AA: B4          or   h			; indica que el personaje tiene el objeto
51AB: DD 77 03    ld   (ix+$03),a
51AE: D9          exx
51AF: 18 1B       jr   $51CC		; salta al siguiente personaje

; aquí llega para pasar al siguiente objeto
51B1: 01 05 00    ld   bc,$0005		; pasa a la siguiente entrada del objeto
51B4: FD 09       add  iy,bc
51B6: 01 14 00    ld   bc,$0014		; pasa al siguiente sprite del objeto
51B9: DD 09       add  ix,bc
51BB: D9          exx
51BC: CB 3C       srl  h			; prueba el siguiente bit de hl
51BE: CB 1D       rr   l
51C0: D9          exx
51C1: E1          pop  hl
51C2: FD 7E 00    ld   a,(iy+$00)	; si no se ha llegado al último objeto, sigue procesando
51C5: FE FF       cp   $FF
51C7: C2 32 51    jp   nz,$5132

51CA: DD E1       pop  ix
51CC: 01 07 00    ld   bc,$0007		; apunta al siguiente personaje
51CF: DD 09       add  ix,bc
51D1: C3 F0 50    jp   $50F0		; sigue procesando los objetos para el siguiente personaje

; dibuja los objetos que tiene guillermo al marcador
51D4: 3A EF 2D    ld   a,($2DEF)	; lee los objetos que tenemos
51D7: 4F          ld   c,a
51D8: 3E FF       ld   a,$FF

; comprueba si se tienen los objetos que se le pasan en c (se comprueban los indicados por la máscara a), y si se tienen se dibujan
51DA: 5F          ld   e,a			; e = 0xff (8 objetos)
51DB: 51          ld   d,c			; d = objetos que tenemos
51DC: FD 21 08 30 ld   iy,$3008		; apunta a las posiciones sobre los objetos del juego
51E0: DD 21 1B 2F ld   ix,$2F1B		; apunta a sprites de los objetos(referenciadas por 0x3836) 0x2e17-0x2fe2
51E4: 21 F9 C6    ld   hl,$C6F9		; apunta a la memoria de video del primer hueco (100, 176)
51E7: 06 06       ld   b,$06		; hay 6 huecos donde colocar los objetos
51E9: CB 22       sla  d			; pone en el carry el bit más significativo y lo guarda
51EB: 08          ex   af,af'
51EC: 7B          ld   a,e			; si han procesado todos los objetos, sale
51ED: A7          and  a
51EE: C8          ret  z

51EF: C5          push bc			; guarda el contador de huecos de los objetos
51F0: CB 23       sla  e			; avanza el contador
51F2: E5          push hl			; guarda la dirección original
51F3: 30 14       jr   nc,$5209		; si el objeto no se comprueba, pasa al siguiente objeto
51F5: 08          ex   af,af'
51F6: 38 27       jr   c,$521F		; si tenemos el objeto salta, en otro caso limpia el hueco

51F8: 0E 0C       ld   c,$0C		; 12 pixels de alto
51FA: 06 04       ld   b,$04		; 16 pixels de ancho
51FC: E5          push hl			; guarda la dirección actual de pantalla
51FD: 36 00       ld   (hl),$00		; limpia el pixel actual
51FF: 23          inc  hl
5200: 10 FB       djnz $51FD
5202: E1          pop  hl			; recupera la dirección anterior
5203: CD 4D 3A    call $3A4D		; pasa a la siguiente línea
5206: 0D          dec  c			; continua limpiando el hueco
5207: 20 F1       jr   nz,$51FA

5209: E1          pop  hl			; recupera la dirección anterior
520A: 01 05 00    ld   bc,$0005
520D: 09          add  hl,bc		; pasa al siguiente hueco
520E: FD 09       add  iy,bc		; avanza las posiciones sobre los objetos del juego
5210: 01 14 00    ld   bc,$0014
5213: DD 09       add  ix,bc		; avanza a la siguiente entrada de las características del objeto
5215: C1          pop  bc			; recupera el contador de objetos
5216: 78          ld   a,b
5217: FE 04       cp   $04
5219: 20 01       jr   nz,$521C		; al pasar del hueco 3 al 4 hay 4 pixels extra
521B: 23          inc  hl
521C: 10 CB       djnz $51E9		; repite para el resto de objetos
521E: C9          ret

; dibuja un objeto determinado
521F: DD 46 06    ld   b,(ix+$06)	; lee el alto del objeto
5222: DD 4E 05    ld   c,(ix+$05)	; lee el ancho del objeto
5225: CB B9       res  7,c			; pone a 0 el bit 7
5227: D5          push de
5228: DD 5E 07    ld   e,(ix+$07)	; de = dirección de los gráficos del objeto
522B: DD 56 08    ld   d,(ix+$08)
522E: C5          push bc
522F: E5          push hl
5230: 41          ld   b,c			; b = ancho del objeto
5231: 1A          ld   a,(de)		; lee un byte de datos gráficos y lo escribe en pantalla
5232: 77          ld   (hl),a
5233: 13          inc  de
5234: 23          inc  hl
5235: 10 FA       djnz $5231		; repite hasta que se complete el ancho
5237: E1          pop  hl
5238: CD 4D 3A    call $3A4D		; avanza hl a la siguiente linea
523B: C1          pop  bc			; repite hasta que se termine el objeto
523C: 10 F0       djnz $522E
523E: D1          pop  de
523F: 18 C8       jr   $5209		; avanza al siguiente hueco

; actualiza las puertas a las que pueden entrar guillermo y adso
5241: 3A F6 2D    ld   a,($2DF6)	; lee los objetos de adso
5244: E6 02       and  $02			; se queda con la llave 3
5246: 87          add  a,a			; desplaza 3 posiciones a la izquierda
5247: 87          add  a,a
5248: 87          add  a,a
5249: 4F          ld   c,a
524A: 3E EF       ld   a,$EF
524C: 21 DC 2D    ld   hl,$2DDC		; apunta a las puertas que puede abrir adso
524F: A6          and  (hl)			; se queda con el bit 4 (permiso para la puerta del pasadizo de detrás de la cocina)
5250: B1          or   c			; combina con la llave3
5251: 77          ld   (hl),a		; actualiza el valor
5252: 3A EF 2D    ld   a,($2DEF)	; lee los objetos que tiene guillermo
5255: E6 0C       and  $0C			; se queda con la llave 1 y la llave 2
5257: 4F          ld   c,a
5258: CB 91       res  2,c			; se queda sólo con la llave 1 en c
525A: CB 39       srl  c
525C: CB 39       srl  c
525E: CB 39       srl  c			; mueve la llave 1 al bit 0
5260: E6 04       and  $04			; se queda con la llave 2 en a (bit 2)
5262: B1          or   c			; combina a y c
5263: 4F          ld   c,a
5264: 21 D9 2D    ld   hl,$2DD9		; apunta a las puertas que puede abrir guillermo
5267: 3E FA       ld   a,$FA
5269: A6          and  (hl)			; actualiza las puertas que puede abrir guillermo según las llaves que tenga
526A: B1          or   c
526B: 77          ld   (hl),a
526C: C9          ret


; comprueba si dejamos algún objeto y si es así, marca el sprite del objeto para dibujar
526D: 3E 2F       ld   a,$2F
526F: CD 82 34    call $3482		; si no se estaba pulsando el espacio, sale
5272: C8          ret  z
5273: DD 21 EC 2D ld   ix,$2DEC		; apunta a los datos de los objetos de guillermo

; aquí también se llega de otros sitios
5277: DD 7E 03    ld   a,(ix+$03)	; lee los objetos que tenemos
527A: 01 00 08    ld   bc,$0800		; b = 8 objetos
527D: 0C          inc  c			; c = número de objeto del que se está comprobando su posesión
527E: 87          add  a,a
527F: 38 03       jr   c,$5284		; si tiene el objeto que se está comprobando, salta
5281: 10 FA       djnz $527D		; comprueba para todos los objetos
5283: C9          ret

; aquí llega cuando se pulsó espacio y tenía algún objeto (c = número de objeto)
5284: 79          ld   a,c
5285: 32 F4 52    ld   ($52F4),a	; modifica una instrucción con el número de objeto que se está comprobando si se deja
5288: DD 35 06    dec  (ix+$06)		; decrementa el contador
528B: DD 7E 06    ld   a,(ix+$06)
528E: FE FF       cp   $FF
5290: C0          ret  nz			; si no era 0, sale
5291: DD 34 06    inc  (ix+$06)
5294: CD 4F 53    call $534F		; obtiene la posición donde dejará el objeto y la altura a la que está el personaje
5297: C5          push bc
5298: CD 73 24    call $2473		; dependiendo de la altura, devuelve la altura base de la planta en b
529B: 90          sub  b
529C: 32 C1 52    ld   ($52C1),a	; modifica una comparación con la altura relativa del objeto
529F: 3A BA 2D    ld   a,($2DBA)	; obtiene la altura base de la planta en la que está el personaje de la rejilla
52A2: B8          cp   b
52A3: E1          pop  hl			; recupera en hl la posición en la que se dejará el objeto
52A4: DD E5       push ix
52A6: E5          push hl
52A7: 20 3C       jr   nz,$52E5		; si el objeto no se deja en la misma planta, salta
52A9: CD 9B 27    call $279B		; ajusta la posición pasada en hl a las 20x20 posiciones centrales que se muestran. Si la posición está fuera, CF=1
52AC: 38 37       jr   c,$52E5		; si hay acarreo, la posición no está dentro del rectángulo visible, por lo que salta
52AE: CD D4 0C    call $0CD4    	; indexa en la tabla de alturas y devuelve la dirección correspondiente en ix
52B1: DD 7E 00    ld   a,(ix+$00)	; obtiene la entrada correspondiente del buffer de alturas
52B4: 4F          ld   c,a
52B5: E6 F0       and  $F0			; se queda con la parte superior
52B7: 20 29       jr   nz,$52E2		; si hay algún personaje en esa posición, sale
52B9: 79          ld   a,c
52BA: E6 0F       and  $0F			; en otro caso obtiene la altura de esa posición
52BC: FE 0D       cp   $0D			; si se deja en una posición con una altura >= 0x0d, sale
52BE: 30 22       jr   nc,$52E2
52C0: D6 00       sub  $00			; instrucción modificada desde fuera con la altura del personaje que deja el objeto
52C2: FE 05       cp   $05			; si la altura de la posición donde se deja - altura del personaje que deja el objeto >= 0x05, sale
52C4: 30 1C       jr   nc,$52E2
52C6: 79          ld   a,c
52C7: E6 0F       and  $0F			; en otro caso obtiene la altura de esa posición
52C9: DD BE FF    cp   (ix-$01)		; la compara con la de sus vecinos y si no es igual, sale
52CC: 20 14       jr   nz,$52E2
52CE: DD BE E8    cp   (ix-$18)
52D1: 20 0F       jr   nz,$52E2
52D3: DD BE E7    cp   (ix-$19)
52D6: 20 0A       jr   nz,$52E2
52D8: 4F          ld   c,a			; c = altura relativa de la posición en la que se deja el objeto
52D9: 3A BA 2D    ld   a,($2DBA)	; a = altura base de la planta en la que se está
52DC: 81          add  a,c			; a = altura total de la posición en la que se deja el objeto
52DD: D1          pop  de
52DE: DD E1       pop  ix
52E0: 18 11       jr   $52F3		; salta a grabar los datos del objeto y quitarle el objeto al personaje que lo deja

; aqui salta si la altura de la posición donde se deja el objeto y la de sus vecinos no coincide
52E2: E1          pop  hl
52E3: E1          pop  hl
52E4: C9          ret

; aquí llega si el objeto no se deja en la misma planta que la de la pantalla en la que se está o no se deja en la misma habitación
52E5: E1          pop  hl
52E6: DD E1       pop  ix
52E8: DD 6E 01    ld   l,(ix+$01)	; obtiene la dirección de la posición del personaje
52EB: DD 66 02    ld   h,(ix+$02)
52EE: 5E          ld   e,(hl)		; de = posición global del personaje
52EF: 23          inc  hl
52F0: 56          ld   d,(hl)
52F1: 23          inc  hl
52F2: 7E          ld   a,(hl)		; a = altura global del personaje

; aquí también llega si el objeto está en la misma habitación que se muestra en pantalla
52F3: 0E 00       ld   c,$00		; instrucción modificada con el número de objeto que se está dejando
52F5: DD 6E 01    ld   l,(ix+$01)	; hl = dirección de la posición del personaje
52F8: DD 66 02    ld   h,(ix+$02)
52FB: 2B          dec  hl
52FC: 67          ld   h,a			; guarda la orientación en h
52FD: 7E          ld   a,(hl)		; ¡fallo del juego! quiere obtener la orientación del personaje pero ha sobreescrito h
52FE: EE 02       xor  $02
5300: 6F          ld   l,a			; l = supuesta orientación del objeto
5301: E5          push hl
5302: DD 36 06 10 ld   (ix+$06),$10	; inicia el contador para coger/dejar objetos
5306: 79          ld   a,c
5307: 21 00 80    ld   hl,$8000		; empieza a comprobar si tiene el objeto indicado por el bit 7
530A: 3D          dec  a
530B: 28 06       jr   z,$5313		; si hemos modificado la máscara hasta llegar al objeto, sale
530D: CB 3C       srl  h
530F: CB 1D       rr   l
5311: 18 F7       jr   $530A		; en otro caso sigue modificando la máscara
5313: 7D          ld   a,l
5314: 2F          cpl
5315: DD A6 00    and  (ix+$00)		; combina los objetos que tenía para eliminar el que deja
5318: DD 77 00    ld   (ix+$00),a	; combina los objetos que tenía para eliminar el que deja
531B: 7C          ld   a,h
531C: 2F          cpl				; el bit del objeto que se deja está a 0 y el resto de bits a 1
531D: DD A6 03    and  (ix+$03)		; combina los objetos que tenía para eliminar el que deja
5320: DD 77 03    ld   (ix+$03),a	; actualiza los objetos que tenemos

5323: DD 21 1B 2F ld   ix,$2F1B		; apunta a los sprites de los objetos
5327: FD 21 08 30 ld   iy,$3008		; apunta a los datos de posición de los objetos
532B: 79          ld   a,c
532C: 3D          dec  a
532D: 28 0C       jr   z,$533B		; si ha llegado al objeto, sale
532F: 01 14 00    ld   bc,$0014		; avanza el siguiente sprite
5332: DD 09       add  ix,bc
5334: 01 05 00    ld   bc,$0005		; avanza al siguiente dato de posición
5337: FD 09       add  iy,bc
5339: 18 F1       jr   $532C

533B: FD CB 00 BE res  7,(iy+$00)	; indica que no se tiene el objeto
533F: E1          pop  hl
5340: FD 74 04    ld   (iy+$04),h	; guarda la altura de destino del objeto
5343: FD 75 01    ld   (iy+$01),l	; guarda la orientación del objeto
5346: FD 73 02    ld   (iy+$02),e	; guarda la posición global de destino del objeto
5349: FD 72 03    ld   (iy+$03),d
534C: C3 13 0D    jp   $0D13		; salta a la rutina de redibujado de objetos para redibujar solo el objeto que se deja

; modifica una rutina con los datos de posición del personaje y su orientación
; devuelve  en bc la posición del personaje + 2*desplazamiento en según orientación
;  y en a la altura del personaje
534F: DD 5E 01    ld   e,(ix+$01)		; lee la dirección de los datos de posición del personaje
5352: DD 56 02    ld   d,(ix+$02)
5355: 1B          dec  de
5356: 1A          ld   a,(de)			; lee la orientación del personaje
5357: 21 53 28    ld   hl,$2853			; hl apunta a la tabla de desplazamiento a sumar si sigue avanzando en esa orientación
535A: CD 92 27    call $2792			; hl = hl + 8*a
535D: 13          inc  de
535E: 1A          ld   a,(de)			; lee la posición x del personaje
535F: 86          add  a,(hl)			; le suma 2 veces el valor leido de la tabla
5360: 86          add  a,(hl)
5361: 32 6E 51    ld   ($516E),a		; modifica una comparación
5364: 4F          ld   c,a				; guarda en c el valor de posición
5365: 13          inc  de
5366: 23          inc  hl
5367: 1A          ld   a,(de)			; lee la posición y del personaje
5368: 86          add  a,(hl)			; le suma 2 veces el valor leido de la tabla
5369: 86          add  a,(hl)
536A: 32 73 51    ld   ($5173),a		; modifica una comparación
536D: 47          ld   b,a
536E: 13          inc  de
536F: 1A          ld   a,(de)			; lee la altura del personaje
5370: 32 67 51    ld   ($5167),a		; modifica una resta
5373: C9          ret
; ---------------------------- fin del código relacionado con coger/dejar objetos ---------------------------------------

; ------------- código para realizar el efecto del reflejo en el espejo ------------------------

; si el espejo no está abierto, realiza el efecto del espejo
5374: 3A 8C 2D    ld   a,($2D8C)		; lee si está abierta la habitación secreta del espejo
5377: A7          and  a
5378: C8          ret  z				; si está abierta, sale
5379: FD 21 36 30 ld   iy,$3036			; apunta a las características de guillermo
537D: DD 21 53 2E ld   ix,$2E53			; apunta al sprite del abad
5381: 21 DC 9A    ld   hl,$9ADC			; apunta a un buffer para flipear los gráficos
5384: 11 9F 31    ld   de,$319F			; apunta a la tabla de animaciones de guillermo
5387: 01 8D 2D    ld   bc,$2D8D			; apunta a un buffer
538A: CD 9E 53    call $539E			; hace el efecto del espejo en la habitación del espejo para guillermo
538D: 01 92 2D    ld   bc,$2D92			; apunta a un buffer
5390: 21 D6 9B    ld   hl,$9BD6			; apunta a un buffer para flipear los gráficos
5393: 11 BF 31    ld   de,$31BF			; apunta a la tabla de animaciones de adso
5396: FD 21 45 30 ld   iy,$3045			; apunta a las características de adso
539A: DD 21 67 2E ld   ix,$2E67			; apunta al sprite de berengario
										; hace el efecto del espejo en la habitación del espejo para adso

; iy apunta a los datos de posición del personaje
; ix apunta a un sprite
; hl apunta a un buffer para flipear los gráficos
; de apunta a la tabla de animaciones del personaje
; bc apunta a un buffer
539E: C5          push bc
539F: CD AD 53    call $53AD		; hace el efecto del espejo en la habitación del espejo
53A2: C1          pop  bc
53A3: 7D          ld   a,l
53A4: 02          ld   (bc),a		; graba el estado de visibilidad del sprite
53A5: FE FE       cp   $FE			; si el sprite es visible, sale
53A7: C0          ret  nz
53A8: DD CB 0B BE res  7,(ix+$0b)	; indica que el sprite es de un monje
53AC: C9          ret

; si el personaje está frente al espejo, rellena el sprite que se le pasa en ix para realizar el efecto del espejo
; iy apunta a los datos de posición del personaje
; ix apunta a un sprite
; hl apunta a un buffer para flipear los gráficos
; de apunta a la tabla de animaciones del personaje
; bc apunta a un buffer
53AD: 22 83 54    ld   ($5483),hl	; modifica una instrucción con la dirección del buffer
53B0: 2E FE       ld   l,$FE		; indica que inicialmente el sprite no es visible
53B2: 3A A9 27    ld   a,($27A9)	; a = mínima posición x visible en pantalla
53B5: FE 1C       cp   $1C			; si no está en la habitación del espejo, sale
53B7: C0          ret  nz
53B8: 3A 9D 27    ld   a,($279D)	; a = mínima posición y visible en pantalla
53BB: FE 5C       cp   $5C			; si no está en la habitación del espejo, sale
53BD: C0          ret  nz

53BE: 0A          ld   a,(bc)		; obtiene el estado anterior del sprite
53BF: 32 53 54    ld   ($5453),a	; modifica una llamada
53C2: 03          inc  bc
53C3: ED 43 44 54 ld   ($5444),bc	; modifica 2 instrucciones
53C7: ED 43 4C 54 ld   ($544C),bc
53CB: 03          inc  bc
53CC: 03          inc  bc
53CD: ED 43 48 54 ld   ($5448),bc	; modifica 2 instrucciones
53D1: ED 43 50 54 ld   ($5450),bc
53D5: FD 7E 04    ld   a,(iy+$04)	; a = altura del personaje
53D8: CD 73 24    call $2473		; dependiendo de la altura, devuelve la altura base de la planta en b
53DB: 90          sub  b
53DC: FE 08       cp   $08			; si la altura sobre la base de la planta es >= 0x08, sale
53DE: D0          ret  nc
53DF: 78          ld   a,b
53E0: FE 16       cp   $16			; si no está en la segunda planta, sale
53E2: C0          ret  nz

53E3: FD 7E 02    ld   a,(iy+$02)	; a = posición x del personaje
53E6: 47          ld   b,a
53E7: D6 20       sub  $20			; si no está en la zona visible del espejo en x, sale
53E9: D8          ret  c
53EA: FE 0A       cp   $0A
53EC: D0          ret  nc
53ED: FD 7E 03    ld   a,(iy+$03)	; a = posición y del personaje
53F0: D6 62       sub  $62
53F2: D8          ret  c			; si no está en la zona visible del espejo en y, sale
53F3: FE 0A       cp   $0A
53F5: D0          ret  nc

53F6: FD 4E 01    ld   c,(iy+$01)	; c = orientación del personaje
53F9: FD 7E 00    ld   a,(iy+$00)	; a = animación del personaje
53FC: F5          push af			; guarda la animación del personaje
53FD: EE 02       xor  $02			; invierte la animación
53FF: FD 77 00    ld   (iy+$00),a
5402: C5          push bc			; guarda la orientación y la posición en x
5403: 78          ld   a,b			; recupera la posición x del personaje
5404: D6 21       sub  $21
5406: ED 44       neg
5408: C6 21       add  a,$21		; refleja la posición x con respecto al espejo
540A: FD 77 02    ld   (iy+$02),a
540D: 79          ld   a,c
540E: CB 47       bit  0,a
5410: 20 02       jr   nz,$5414		; refleja la orientación del personaje
5412: EE 02       xor  $02
5414: FD 77 01    ld   (iy+$01),a

5417: FD CB 05 7E bit  7,(iy+$05)	; si el personaje ocupa 4 posiciones, salta
541B: 28 03       jr   z,$5420
541D: FD 35 02    dec  (iy+$02)		; decrementa la posición en x

5420: 21 73 54    ld   hl,$5473
5423: 22 59 2A    ld   ($2A59),hl	; modifica la dirección de la rutina encargada de flipear los gráficos
5426: ED 53 84 2A ld   ($2A84),de	; modifica la tabla de animaciones del personaje
542A: DD CB 0B FE set  7,(ix+$0b)	; indica que no es un monje
542E: DD 7E 00    ld   a,(ix+$00)	; lee y preserva el estado del sprite
5431: F5          push af
5432: CD 27 2A    call $2A27		; avanza la animación del sprite y lo redibuja
5435: F1          pop  af
5436: DD 6E 01    ld   l,(ix+$01)	; lee la posición del sprite
5439: DD 66 02    ld   h,(ix+$02)
543C: DD 5E 05    ld   e,(ix+$05)	; lee el ancho y el alto del sprite
543F: DD 56 06    ld   d,(ix+$06)
5442: D9          exx
5443: 2A 8D 2D    ld   hl,($2D8D)	; instrucción modificada desde fuera
5446: ED 5B 8F 2D ld   de,($2D8F)	; instrucción modificada desde fuera
544A: D9          exx
544B: 22 8D 2D    ld   ($2D8D),hl	; instrucción modificada desde fuera
544E: ED 53 8F 2D ld   ($2D8F),de	; instrucción modificada desde fuera
5452: 3E 00       ld   a,$00		; instrucción modificada desde fuera
5454: FE FE       cp   $FE
5456: 28 01       jr   z,$5459		; si el sprite no es visible, no cambia los registros
5458: D9          exx
5459: DD 75 03    ld   (ix+$03),l	; escribe la posición anterior y el anterior ancho y alto del sprite
545C: DD 74 04    ld   (ix+$04),h
545F: DD 73 09    ld   (ix+$09),e
5462: DD 72 0A    ld   (ix+$0a),d
5465: C1          pop  bc
5466: FD 70 02    ld   (iy+$02),b	; restaura la orientación del personaje y la posición en x
5469: FD 71 01    ld   (iy+$01),c
546C: F1          pop  af
546D: FD 77 00    ld   (iy+$00),a	; restaura el contador de animación del personaje
5470: 2E 00       ld   l,$00		; indica que el sprite es visible
5472: C9          ret

; rutina encargada de flipear los gráficos
5473: DD 6E 05    ld   l,(ix+$05)	; obtiene el ancho y el alto del sprite
5476: DD 66 06    ld   h,(ix+$06)
5479: E5          push hl
547A: 7C          ld   a,h
547B: 26 00       ld   h,$00
547D: CD 24 4D    call $4D24		; de = a*hl (de = ancho*alto)
5480: 42          ld   b,d			; bc = de
5481: 4B          ld   c,e
5482: 11 40 9B    ld   de,$9B40		; instrucción modificada desde fuera
5485: D5          push de
5486: DD 6E 07    ld   l,(ix+$07)	; hl = dirección de los gráficos del sprite
5489: DD 66 08    ld   h,(ix+$08)
548C: DD 73 07    ld   (ix+$07),e	; pone la nueva dirección de los gráficos
548F: DD 72 08    ld   (ix+$08),d
5492: ED B0       ldir				; copia los gráficos al destino
5494: E1          pop  hl
5495: C1          pop  bc
5496: C3 52 35    jp   $3552		; flipea los gráficos apuntados por hl según las características indicadas por bc

; ------------- fin del código para realizar el efecto del reflejo en el espejo ------------------------

; si no se ha completado el scroll del cambio del momento del día, lo avanza un paso
5499: 3A A5 2D    ld   a,($2DA5)	; comprueba si se ha completado el scroll del cambio del momento del día
549C: A7          and  a
549D: C8          ret  z			; si ya ha cambiado totalmente el día, sale
549E: 3D          dec  a
549F: 32 A5 2D    ld   ($2DA5),a	; en otro caso, queda una iteración menos
54A2: FE 07       cp   $07
54A4: 3E 20       ld   a,$20		; a = espacio en blanco
54A6: 30 08       jr   nc,$54B0		; si no hay que poner ningún carácter todavía (0x2da5 > 7), salta con espacio
54A8: 2A 82 2D    ld   hl,($2D82)	; obtiene el puntero a la próxima hora del día
54AB: 7E          ld   a,(hl)		; lee un caracter
54AC: 23          inc  hl
54AD: 22 82 2D    ld   ($2D82),hl	; actualiza el puntero

; hace el efecto de scroll del texto del día 8 pixels hacia la izquierda
54B0: 21 0D B4    ld   hl,$B40D		; l = coordenada X (en bytes) + 32 pixels, h = coordenada Y (en pixels)
54B3: 22 97 2D    ld   ($2D97),hl	; graba la posición inicial para el scroll (84, 180)

54B6: 21 EB E6    ld   hl,$E6EB		; apunta a pantalla (44, 180)
54B9: 06 08       ld   b,$08		; b = 8 líneas
54BB: F5          push af
54BC: C5          push bc
54BD: E5          push hl
54BE: 01 0C 00    ld   bc,$000C		; c = 12 bytes
54C1: 54          ld   d,h			; de = hl
54C2: 5D          ld   e,l
54C3: 1B          dec  de
54C4: 1B          dec  de
54C5: ED B0       ldir				; hace el scroll 8 pixels a la izquierda
54C7: E1          pop  hl
54C8: CD 4D 3A    call $3A4D		; pasa a la siguiente línea
54CB: C1          pop  bc
54CC: 10 EE       djnz $54BC		; completa las 8 líneas
54CE: F1          pop  af			; recupera el carácter a imprimir
54CF: C3 17 3B    jp   $3B17		; imprime un carácter

; inicia el día y el momento del día en el que se está
54D2: 3A 4F BF    ld   a,($BF4F)
54D5: 32 80 2D    ld   ($2D80),a	; escribe el día
54D8: 3A 4E BF    ld   a,($BF4E)
54DB: 32 81 2D    ld   ($2D81),a	; escribe el momento del día en el que se está
54DE: C9          ret

; fija la paleta según el momento del día y muestra el número de día
54DF: 3A 81 2D    ld   a,($2D81)	; lee el momento del día en el que se está
54E2: 3D          dec  a
54E3: FE 05       cp   $05
54E5: F5          push af
54E6: DC 44 3F    call c,$3F44		; si a <=, selecciona paleta 2
54E9: F1          pop  af
54EA: F5          push af
54EB: D4 49 3F    call nc,$3F49		; en otro caso, selecciona paleta 3

54EE: 3A 80 2D    ld   a,($2D80)
54F1: CD 59 55    call $5559		; dibuja el número de día en el marcador
54F4: 21 BC 4F    ld   hl,$4FBC
54F7: F1          pop  af			; recupera el momento del día en el que estaba
54F8: 32 81 2D    ld   ($2D81),a
54FB: 3C          inc  a
54FC: 47          ld   b,a
54FD: 87          add  a,a
54FE: 4F          ld   c,a
54FF: 87          add  a,a
5500: 81          add  a,c
5501: 80          add  a,b
5502: CD 2D 16    call $162D		; hl = hl + 7*(a + 1)
5505: 22 82 2D    ld   ($2D82),hl	; apunta al nombre del momento del día
5508: 18 34       jr   $553E		; avanza el momento del día

550A: 3A 80 2D    ld   a,($2D80)	; lee el día
550D: 3D          dec  a			; ajusta para indexar
550E: 47          ld   b,a
550F: 87          add  a,a
5510: 4F          ld   c,a
5511: 87          add  a,a
5512: 80          add  a,b
5513: 81          add  a,c			; a = 7*a
5514: 21 7A 4F    ld   hl,$4F7A		; hl = hl + a
5517: CD 2D 16    call $162D
551A: 3A 81 2D    ld   a,($2D81)	; lee el periodo del día
551D: CD 2D 16    call $162D		; ajusta el índice en la tabla
5520: 66          ld   h,(hl)		; guarda la duración de la etapa del día
5521: 2E 00       ld   l,$00
5523: 22 86 2D    ld   ($2D86),hl
5526: C9          ret

; comprueba si hay que pasar al siguiente momento del día
5527: 3E 06       ld   a,$06
5529: CD 72 34    call $3472		; comprueba si ha cambiado el estado del enter
552C: CD C6 41    call $41C6		; pone a en 0, para que nunca de como pulsado el enter
552F: 20 0D       jr   nz,$553E		; si se pulsó enter, avanza la etapa del día
5531: 2A 86 2D    ld   hl,($2D86)	; si el contador para que pase el momento del día es 0, sale
5534: 7C          ld   a,h
5535: B5          or   l
5536: C8          ret  z

5537: 2B          dec  hl			; decrementa el contador del momento del día y si llega a 0, actualiza el momento del día
5538: 22 86 2D    ld   ($2D86),hl
553B: 7C          ld   a,h
553C: B5          or   l
553D: C0          ret  nz

; actualiza el momento del día
553E: 3A 81 2D    ld   a,($2D81)	; obtiene el momento del día
5541: 3C          inc  a
5542: FE 07       cp   $07			; avanza la hora del día
5544: 20 2F       jr   nz,$5575		; si se salió de la tabla vuelve al primer momento del día
5546: 21 BC 4F    ld   hl,$4FBC
5549: 22 82 2D    ld   ($2D82),hl
554C: 3A 80 2D    ld   a,($2D80)	; avanza un día
554F: 3C          inc  a
5550: 32 80 2D    ld   ($2D80),a	; en el caso de que se haya pasado del séptimo día, vuelve al primer día
5553: FE 08       cp   $08
5555: 38 05       jr   c,$555C
5557: 3E 01       ld   a,$01

; actualiza el día, reflejándolo en el marcador
5559: 32 80 2D    ld   ($2D80),a	; actualiza el día
555C: 3D          dec  a			; ajusta el índice a 0
555D: 4F          ld   c,a
555E: 87          add  a,a
555F: 81          add  a,c			; cada entrada en la tabla ocupa 3 bytes
5560: 21 A7 4F    ld   hl,$4FA7		; indexa en la tabla de los días
5563: CD 2D 16    call $162D
5566: EB          ex   de,hl
5567: 21 51 EE    ld   hl,$EE51		; apunta a pantalla (68, 165)
556A: CD 83 55    call $5583		; coloca el primer número de día en el marcador
556D: CD 83 55    call $5583		; coloca el segundo número de día en el marcador
5570: CD 83 55    call $5583		; coloca el tercer número de día en el marcador
5573: 3E 00       ld   a,$00		; pone la primera hora del día
5575: 32 81 2D    ld   ($2D81),a
5578: 3E 09       ld   a,$09
557A: 32 A5 2D    ld   ($2DA5),a	; 9 posiciones para realizar el scroll del cambio del momento del día
557D: CD 0A 55    call $550A		; pone en 0x2d86 un valor dependiente del día y la hora
5580: C9          ret

; tabla de 8 pixels con colores 3
5581: FF FF

; pone un número de día
5583: E5          push hl			; guarda la dirección de pantalla
5584: 3E 03       ld   a,$03
5586: 32 A8 55    ld   ($55A8),a	; inicialmente inc bc
5589: 1A          ld   a,(de)		; lee un byte de los datos que forman el número del día
558A: 01 49 AB    ld   bc,$AB49		; apunta al 'I'
558D: FE 02       cp   $02
558F: 28 0E       jr   z,$559F		; si se leyó un 2, salta
5591: 01 39 AB    ld   bc,$AB39		; apunta al 'V'
5594: A7          and  a
5595: 20 08       jr   nz,$559F		; si no es un 0, salta
5597: 3E 0B       ld   a,$0B
5599: 32 A8 55    ld   ($55A8),a	; cambia en inc bc por dec bc
559C: 01 81 55    ld   bc,$5581		; apunta a pixels con colores 3, 3, 3, 3

559F: 3E 08       ld   a,$08		; rellena las 8 líneas que ocupa la letra (8x8)
55A1: F5          push af
55A2: 0A          ld   a,(bc)		; lee un byte y lo copia a pantalla
55A3: 77          ld   (hl),a
55A4: 23          inc  hl			; avanza
55A5: 03          inc  bc
55A6: 0A          ld   a,(bc)		; lee otro byte y lo copia a pantalla
55A7: 77          ld   (hl),a
55A8: 03          inc  bc			; instrucción modificada desde fuera (avanza o retrocede)
55A9: 2B          dec  hl
55AA: CD 4D 3A    call $3A4D		; avanza a la siguiente línea de pantalla
55AD: F1          pop  af
55AE: 3D          dec  a
55AF: 20 F0       jr   nz,$55A1		; repite para las 8 líneas
55B1: E1          pop  hl
55B2: 23          inc  hl			; avanza a la siguiente posición
55B3: 23          inc  hl
55B4: 13          inc  de
55B5: C9          ret

; comprueba si hay que modificar las variables relacionadas con el tiempo (momento del día, combustible de la lámpara, etc)
55B6: C5          push bc
55B7: E5          push hl
55B8: D5          push de
55B9: CD 27 55    call $5527		; comprueba si hay que avanzar la etapa del día (si se ha pulsado enter también se cambia)
55BC: CD FD 41    call $41FD		; comprueba si se está usando la lámpara, y si es así, si se está agotando
55BF: 79          ld   a,c
55C0: 32 8D 3C    ld   ($3C8D),a	; actualiza el estado de la lámpara
55C3: CD 2B 42    call $422B		; comprueba si se está acabando la noche
55C6: 79          ld   a,c
55C7: 32 8C 3C    ld   ($3C8C),a	; actualiza la variable que indica si se está acabando la noche
55CA: D1          pop  de
55CB: E1          pop  hl
55CC: C1          pop  bc
55CD: C9          ret

55CE: CD D3 55    call $55D3		; decrementa la vida de guillermo en 2 unidades
55D1: 02
55D2: C9          ret

; decrementa y actualiza en pantalla la barra de energía (obsequium)
55D3: E1          pop  hl			; obtiene la dirección a la que tendría que regresar y lee el byte que hay
55D4: 4E          ld   c,(hl)		; obtiene las unidades de vida a restar
55D5: 23          inc  hl
55D6: E5          push hl			; retornará a la dirección después de ese byte
55D7: 3A 7F 2D    ld   a,($2D7F)	; lee la energía
55DA: 91          sub  c			; le resta las unidades leidas
55DB: 30 0C       jr   nc,$55E9		; si la energía >= 0, salta

; aquí llega si ya no queda energía
55DD: 3A 97 3C    ld   a,($3C97)
55E0: A7          and  a
55E1: 20 05       jr   nz,$55E8		; si guillermo ha muerto, salta
55E3: 3E 0B       ld   a,$0B
55E5: 32 C7 3C    ld   ($3CC7),a	; cambia el estado del abad para que le eche de la abadía
55E8: AF          xor  a			; reinicia el contador

55E9: 32 7F 2D    ld   ($2D7F),a	; actualiza el contador de energía
55EC: 4F          ld   c,a			; guarda el contador
55ED: 21 2A 56    ld   hl,$562A		; apunta a una tabla de pixels para los 4 últimos pixels de la vida
55F0: E6 03       and  $03
55F2: CD 2D 16    call $162D		; indexa en la tabla según los 2 bits menos significativos
55F5: 5E          ld   e,(hl)		; e = valor de la tabla
55F6: 21 1C CF    ld   hl,$CF1C		; apunta a pantalla (252, 177)
55F9: CB 39       srl  c
55FB: CB 39       srl  c
55FD: 79          ld   a,c			; calcula el ancho de la barra de vida readondeada al múltiplo de 4 más cercano
55FE: 16 0F       ld   d,$0F		; valor a escribir
5600: CD 0E 56    call $560E		; dibuja la primera parte de la barra de vida
5603: 3E 01       ld   a,$01		; 4 pixels de ancho
5605: 53          ld   d,e			; valor a escribir dependiendo de la vida que quede
5606: CD 0E 56    call $560E		; dibuja la segunda parte de la barra de vida
5609: 3E 07       ld   a,$07		; obtiene la vida que ha perdido
560B: 91          sub  c
560C: 16 FF       ld   d,$FF		; rellena de negro

; dibuja un rectángulo de a bytes de ancho y 6 líneas de alto (graba d)
560E: A7          and  a			; si a = 0, sale
560F: C8          ret  z
5610: 47          ld   b,a			; b = número de bytes de ancho
5611: C5          push bc
5612: E5          push hl
5613: 06 06       ld   b,$06		; 6 líneas de alto
5615: 72          ld   (hl),d		; escribe en pantalla
5616: CD 4D 3A    call $3A4D		; pasa a la siguiente línea
5619: 10 FA       djnz $5615
561B: E1          pop  hl
561C: C1          pop  bc
561D: 23          inc  hl			; avanza al siguiente byte en x
561E: 10 F1       djnz $5611
5620: C9          ret

; tabla con los números romanos de las escaleras de la habitación del espejo
5621: 	49 58 D8 -> IXX
		58 49 D8 -> XIX
		58 58 C9 -> XXI

; tabla con pixels para rellenar los 4 últimos pixels de la barra de obsequium
562A: FF 7F 3F 1F

; si no se había generado el número romano del enigma de la habitación del espejo, lo genera
562E: 3A BC 2D    ld   a,($2DBC)		; obtiene el número romano del enigma de la habitación del espejo
5631: A7          and  a
5632: 20 07       jr   nz,$563B			; si ya se había calculado el número, salta
5634: ED 5F       ld   a,r				; en otro caso, genera un número aleatorio entre 1 y 3
5636: E6 03       and  $03
5638: 20 01       jr   nz,$563B
563A: 3C          inc  a
563B: C4 43 56    call nz,$5643			; copia a la cadena del pergamino el número generado
563E: CD 26 50    call $5026			; pone en el marcador la frase SECRETUM FINISH AFRICAE, MANUS SUPRA XXX AGE PRIMUM ET SEPTIMUM DE QUATOR
		00								;  (donde XXX es el número generado)
5642: C9          ret

; copia a la cadena del pergamino los números romanos de la habitación del espejo
5643: 32 BC 2D    ld   ($2DBC),a		; obtiene la entrada al número romano de las escaleras en las que hay que pulsar QR frente al espejo
5646: 3D          dec  a
5647: 4F          ld   c,a				; cada entrada ocupa 3 bytes
5648: 87          add  a,a
5649: 81          add  a,c
564A: 21 21 56    ld   hl,$5621			; tabla con los números romanos de las escaleras de la habitación del espejo
564D: CD 2D 16    call $162D			; hl = hl + a
5650: 11 9E B5    ld   de,$B59E			; apunta a los datos de la cadena del pergamino
5653: 01 03 00    ld   bc,$0003
5656: ED B0       ldir					; copia los números romanos a las cadena del pergamino
5658: C9          ret

; tabla de octavas y notas para las frases del juego
5659: 	38 41 41 41 35 45 41 41 41 49 49 54 54 41 41 51
		41 41 54 54 41 41 41 41 41 41 41 41 41 41 41 49
		41 39 39 54 54 41 51 54 54 41 54 54 51 41 39 39
		41 41 39 49 49 35 35 51

; --------------- código relacionado con el cálculo de bonus y cambios de cámara ---------------------------------
5691: CF          rst  $08			; interpreta los comandos que siguen a esta instrucción
		90 -> c1a = [0x3ce9]
		40 FD -> c2a = 0xfd
		3D -> ca = [0x3ce9] == 0xfd ; ca = si berengario va a por el libro
		9D -> c1b = [0x3074]
		50 -> c2b = 0x50
		3C -> cb = c1b < c2b		; cb = si la posición x de berengario es  < 0x50
		26 -> cc = ca & cb
		AB -> cd = [0x3ca1]			; cd = berengario está vivo
		26 -> ce = cc & cd
		90 -> c1f = [0x3ce9]
		40 FE -> c2f = 0xfe			; ce = si berengario/bernardo gui va a por el abad
		3D -> cf = c1f == c2f
		2A -> c = ce | cf
56A1: 20 04       jr   nz,$56A7		; si hay que seguir a berengario
56A3: D7          rst  $10			; interpreta los comandos que siguen a esta instrucción
		A7 04 -> [0x3c92] = 0x04	; indica que la cámara siga a berengario
56A6: C9          ret

56A7: CF          rst  $08			; interpreta los comandos que siguen a esta instrucción
		88 -> c1a = [0x2d81]
		03 -> c2a = 0x03
		3D -> ca = si el momento del día es sexta
		8A -> c1b = [0x3cc6]
		02 -> c2b = 0x02
		3E -> cb = [0x3cc6] >= 2
		26 -> cc = si el momento del día es sexta y y el abad ha llegado a algún sitio interesante
		8C -> c1d = [0x3cc7]
		15 -> c2d = 0x15
		3D -> cd = [0x3cc7] == 0x15
		2A -> ce = (si el momento del día es sexta y y el abad ha llegado a algún sitio interesante) o (el abad va a dejar el pergamino)
		A5 -> c1f = [0x3c94]
		01 -> c2f = 0x01
		3D -> cf = [0x3c94] == 0x01
		2A -> cg = ((si el momento del día es sexta y [0x3cc6] > 2) o ([0x3cc7] == 0x15)) o (el abad va a perdirle a guillermo el pergamino)
		8C -> c1h = [0x3cc7]
		0B -> c2h = 0x0b
		3D -> ch = [0x3cc7] == 0x0b
		2A -> c = (((si el momento del día es sexta y [0x3cc6] > 2) o ([0x3cc7] == 0x15)) o ([0x3c94] == 0x01)) o (si el abad va a echar a guillermo)
56BB: 20 04       jr   nz,$56C1		; si está en una situación interesante
56BD: D7          rst  $10			; interpreta los comandos que siguen a esta instrucción
	A7 03 -> [0x3c92] = 0x03		; indica que la cámara siga al abad
56C0: C9          ret

56C1: CF          rst  $08			; interpreta los comandos que siguen a esta instrucción
		86 -> c1a = [0x3caa]
		40 FE -> c2a = 0xfe
		3D -> ca = [0x3caa] == 0xfe	; si malaquías va a avisar al abad
		88 -> c1b = [0x2d81]
		05 -> c2b = 0x05
		3D -> cb = si el momento del día es vísperas
		8E -> c1c = [0x3ca9]
		06 -> c2c = 0x06
		3C -> cc = [0x3ca9] < 0x06
		26 -> cd = (si el momento del día es vísperas) y (el estado de malaquías < 0x06)
		2A -> c = ((si el momento del día es vísperas) y (el estado de malaquías  < 0x06)) o (si malaquías va a avisar al abad)
56CE: 20 04       jr   nz,$56D4		; si malaquías está en una situación interesante
56D0: D7          rst  $10			; interpreta los comandos que siguen a esta instrucción
		A7 02 -> [0x3c92] = 0x02	; indica que la cámara siga a malaquías
56D3: C9          ret

56D4: CF          rst  $08			; interpreta los comandos que siguen a esta instrucción
	93 -> c1 = [0x3d01]
	40 FF -> c2 = 0xff
	3D -> c = [0x3d01] == 0xff
56D9: 20 04       jr   nz,$56DF		; si severino va a por guillermo
56DB: D7          rst  $10			; interpreta los comandos que siguen a esta instrucción
	A7 05 -> [0x3c92] = 0x05		; indica que la cámara siga a severino
56DE: C9          ret

56DF: D7          rst  $10			; interpreta los comandos que siguen a esta instrucción
	A7 00 -> [0x3c92] = 0x00		; indica que la cámara siga a guillermo

56E2: CF          rst  $08			; interpreta los comandos que siguen a esta instrucción
		A4 -> c1a = [0x2def]
		10 -> c2a = 0x10
		2A -> ca = [0x2def] & 0x10
		10 -> cb = 0x10
		3D -> c = si tenemos el pergamino
56E8: 20 2E       jr   nz,$5718		; si tenemos el pergamino
56EA: CF          rst  $08			; interpreta los comandos que siguen a esta instrucción
		8D -> c1a = [0x2d80]
		03 -> c2a = 0x03
		3D -> ca = si es el tercer día
		88 -> c1b = [0x2d81]
		00 -> c2b = 0x00
		3D -> cb = si es de la noche
		26 -> c = si es el tercer día y es de noche
56F2: 20 05       jr   nz,$56F9		; si es el tercer día y es de noche
56F4: D7          rst  $10			; interpreta los comandos que siguen a esta instrucción
	C0 C0 10 26 -> [0x2dbf] = [0x2dbf] | 0x10	; nos da un bonus

56F9: CF          rst  $08			; interpreta los comandos que siguen a esta instrucción
		A4 -> c1a = [0x2def]
		40 20 -> c2a = 0x20
		2A -> ca = [0x2def] & 0x20
		40 20 -> cb = 0x20
		3D -> c = si guillermo tiene las gafas
5701: 20 05       jr   nz,$5708		; si guillermo tiene las gafas
5703: D7          rst  $10			; interpreta los comandos que siguen a esta instrucción
		C0 C0 01 26 -> [0x2dbf] = [0x2dbf] | 0x01
5708: CF          rst  $08			; interpreta los comandos que siguen a esta instrucción
		9A -> c1a = [0x2dbd]
		0D -> c2a = 0x0d
		3D -> ca = [0x2dbd] == 0x0d
		A7 -> c1b = [0x3c92]
		00 -> c2b = 0x00
		3D -> cb = [0x3c92] == 0x00
		26 -> c = ([0x2dbd] == 0x0d) && ([0x3c92] == 0x00)
5710: 20 06       jr   nz,$5718		; si guillermo entra a la habitación del abad
5712: D7          rst  $10			; interpreta los comandos que siguen a esta instrucción
		C0 C0 40 20 26 -> [0x2dbf] = [0x2dbf] | 0x20	; obtiene un bonus

5718: CF          rst  $08			; interpreta los comandos que siguen a esta instrucción
		88 -> c1a = [0x2d81]
		00 -> c2a = 0x00
		3D -> ca = si es de noche
		80 -> c1b = [0x3038]
		60 -> c2b = 0x60
		3C -> cb = si [0x3038] < 0x60
		26 -> c = es de noche y ([0x3038] < 0x60)
5720: 20 05       jr   nz,$5727		; si es de noche y está en el ala izquierda de la abadía
5722: D7          rst  $10			; interpreta los comandos que siguen a esta instrucción
		BF BF 01 26 -> [0x2dbe] = [0x2dbe] | 0x01	; obtiene un bonus

5727: CF          rst  $08			; interpreta los comandos que siguen a esta instrucción
		82 -> c1 = [0x303a]
		16 -> c2 = 0x16
		3E -> c = [0x303a] >= 0x16
572B: 20 25       jr   nz,$5752		; si guillermo sube a la biblioteca
572D: CF          rst  $08			; interpreta los comandos que siguen a esta instrucción
		A4 -> c1a = [0x2def]
		40 20 -> c2a = 0x20
		2A -> ca = [0x2def] & 0x20
		40 20 -> cb = 0x20
		3D -> c = si guillermo tiene las gafas
5735: 20 06       jr   nz,$573D		; si guillermo tiene las gafas
5737: D7          rst  $10			; interpreta los comandos que siguen a esta instrucción
		BF BF 40 80 26 -> [0x2dbe] = [0x2dbe] | 0x80
573D: CF          rst  $08			; interpreta los comandos que siguen a esta instrucción
		B8 -> c1a = [0x2df3]
		40 80 -> c2a = 0x80
		2A -> ca = [0x2df3] & 0x80
		40 80 -> cb = 0x80
		3D -> c = ([0x2df3] & 0x80) == 0x80
5745: 20 06       jr   nz,$574D		; si adso tiene la lámpara
5747: D7          rst  $10			; interpreta los comandos que siguen a esta instrucción
		BF BF 40 20 26 -> [0x2dbe] = [0x2dbe] | 0x20
574D: D7          rst  $10			; interpreta los comandos que siguen a esta instrucción
		BF BF 10 26 -> [0x2dbe] = [0x2dbe] | 0x10

5752: CF          rst  $08			; interpreta los comandos que siguen a esta instrucción
		9A -> c1 = [0x2dbd]
		72 -> c2 = 0x72
		3D -> compara c1 y c2
5756: 20 05       jr   nz,$575D		; si está en la habitación del espejo
5758: D7          rst  $10			; interpreta los comandos que siguen a esta instrucción
		C0 C0 02 26 -> [0x2dbf] = [0x2dbf] | 0x02
575D: C9          ret
; ------------------------------------------------------

; ------------------ lógica de malaquías ----------------
575E: CF          rst  $08
		AC -> c1a = [0x3ca2]
		02 -> c2a = 0x02
		3D -> c = [0x3ca2] == 0x02	; si malaquías ha muerto, sale
5762: 20 03       jr   nz,$5767
5764: C3 5B 3E    jp   $3E5B		; indica que el personaje no quiere buscar ninguna ruta

5767: CF          rst  $08
		AC -> c1a = [0x3ca2]
		01 -> c2a = 0x01
		3D -> c = [0x3ca2] == 0x01
576B: 20 06       jr   nz,$5773
576C: CD 86 43    call $4386		; si está muriendo, avanza la altura de malaquías
5770: C3 5B 3E    jp   $3E5B		; indica que el personaje no quiere buscar ninguna ruta

5773: CF          rst  $08
		8C -> c1a = [0x3cc7]
		0B -> c2a = 0x0b
		3D -> c = [0x3cc7] == 0x0b
5777: 20 03       jr   nz,$577C		; si el abad está en el estado de echar a guillermo de la abadía
5779: C3 5B 3E    jp   $3E5B		; indica que el personaje no quiere buscar ninguna ruta

577C: CF          rst  $08
		88 -> c1a = [0x2d81]
		00 -> c2a = 0x00
		3D -> ca = [0x2d81] == 0x00
		88 -> c1a = [0x2d81]
		06 -> c1b = 0x06
		3D -> cb = [0x2d81] = 0x06
		2A -> c = ([0x2d81] == 0x00) | ([0x2d81] == 0x06)
5784: 20 07       jr   nz,$578D		; si es de noche o completas
5786: D7          rst  $10
		86 07 -> [0x3caa] = 0x07	; va a su celda
5789: D7          rst  $10
		8E 08 -> [0x3ca9] = 0x08	; pasa al estado 8
578C: C9          ret

578D: CF          rst  $08
		88 -> c1a = [0x2d81]
		05 -> c2a = 0x05
		3D -> c = [0x2d81] == 0x05
5791: C2 89 58    jp   nz,$5889		; si es vísperas
5794: CF          rst  $08
		8E -> c1a = [0x3ca9]
		0C -> c2a = 0x0c
		3D -> c = [0x3ca9] == 0x0c	; si está en el estado 0x0c
5798: 20 12       jr   nz,$57AC
579A: D7          rst  $10
		86 40 FE -> [0x3caa] = 0xfe	; va a buscar al abad
579E: CF          rst  $08
		87 -> c1a = [0x3ca8]
		40 FE -> c2a = 0xfe
		3D -> c = [0x3ca8] == 0xfe
57A3: 20 06       jr   nz,$57AB		; si ha llegado a la posición del abad
57A5: D7          rst  $10
	8C 0B -> [0x3cc7] = 0x0b		; cambia el estado del abad para que eche a guillermo
57A8: D7          rst  $10
		8E 06 -> [0x3ca9] = 0x06	; cambia al estado 6
57AB: C9          ret

57AC: CF          rst  $08
		8E -> c1a = [0x3ca9]
		00 -> c2a = 0x00
		3D -> c = [0x3ca9] = 0x00
57B0: 20 12       jr   nz,$57C4		; si está en el estado 0
57B2: D7          rst  $10
		BA 02 -> [0x2dff] = 0x02	; modifica la máscara de los objetos que puede coger malaquías (puede coger la llave del pasadizo)
57B5: D7          rst  $10
		86 06 -> [0x3caa] = 0x06	; va a la mesa del scriptorium a coger la llave
57B8: CF          rst  $08
		87 -> c1a = [0x3ca8]
		06 -> c2a = 0x06
		3D -> c = [0x3ca8] == 0x06
57BC: 20 05       jr   nz,$57C3		; si ha llegado a la mesa del scriptorium donde está la llave
57BE: D7          rst  $10
		8E 02 -> [0x3ca9] = 0x02	; pasa al estado 2
57C1: 18 01       jr   $57C4
57C3: C9          ret

57C4: CF          rst  $08
		8E -> c1a = [0x3ca9]
		04 -> c2a = 0x04
		3C -> c = [0x3ca9] < 0x04
57C8: 20 40       jr   nz,$580A		; si su estado es < 4
57CA: CF          rst  $08
		82 -> c1a = [0x303a]
		0C -> c2a = 0x0c
		3E -> c = [0x303a] >= 0x0c	; si la altura de guillermo es >= 0x0c
57CE: 20 06       jr   nz,$57D6
57D0: D7          rst  $10
		86 40 FF -> [0x3caa] = 0xff	; va a por guillermo
57D4: 18 04       jr   $57DA
57D6: D7          rst  $10
		8E 04 -> [0x3ca9] = 0x04	; pasa al estado 4
57D9: C9          ret

57DA: CF          rst  $08
		8E -> c1a = [0x3ca9]
		02 -> c2a = 0x02
		3D -> c = [0x3ca9] == 0x02
57DE: 20 10       jr   nz,$57F0		; si está en el estado 2
57E0: CD 61 3E    call $3E61		; compara la distancia entre guillermo y malaquías (si está muy cerca devuelve 0, en otro caso != 0)
57E3: 20 0A       jr   nz,$57EF		; si está cerca
57E5: CD 1B 50    call $501B		; escribe en el marcador la frase
		09          				DEBEIS ABANDONAR EDIFICIO, HERMANO
57E9: D7          rst  $10
		8E 03 -> [0x3ca9] = 0x03	; pasa al estado 3
57EC: D7          rst  $10
		8F 00 -> [0x3c9e] = 0x00	; inicia el contador del tiempo que permite a guillermo estar en el scriptorium
57EF: C9          ret

57F0: CF          rst  $08
		8E -> c1a = [0x3ca9]
		03 -> c2a = 0x03
		3D -> c = [0x3ca9] == 0x03
57F4: 20 14       jr   nz,$580A		; si está en el estado 3
57F6: D7          rst  $10
		8F 8F 01 2B -> [0x3c9e] = [0x3c9e] + 1	; incrementa el contador
57FB: CF          rst  $08
		8F -> c1a = [0x3c9e]
		40 FA -> c2a = 0xfa
		3E -> c = [0x3c9e] >= 0xfa
5800: 20 07       jr   nz,$5809		; si el contador llega al límite tolerable
5802: CD 1B 50    call $501B		; escribe en el marcador la frase
		0A							ADVERTIRE AL ABAD
5806: D7          rst  $10
		8E 0C -> [0x3ca9] = 0x0c	; cambia al estado 0x0c
5809: C9          ret

580A: CF          rst  $08
		8E -> c1a = [0x3ca9]
		04 -> c2a = 0x04
		3D -> c = [0x3ca9] == 0x04
580E: 20 22       jr   nz,$5832		; si está en el estado 4
5810: D7          rst  $10
		86 04 -> [0x3caa] = 0x04	; va a cerrar las puertas del ala izquierda de la abadía
5813: CF          rst  $08
		87 -> c1a = [0x3ca8]
		04 -> c2a = 0x04
		3D -> c = [0x3ca8] == 0x04
5817: 20 18       jr   nz,$5831		; si ha llegado a las puertas del ala izquierda de la abadía
5819: CF          rst  $08
		9D -> c1a = [0x3074]
		62 -> c2a = 0x62
		3C -> ca = [0x3074] < 0x62
		AB -> cb = [0x3ca1]
		26 -> c = ([0x3074] < 0x62) & ([0x3ca1])
581F: 20 03       jr   nz,$5824		; si berengario o bernardo gui no han abandonado el ala izquierda de la abadía
5821: C3 5B 3E    jp   $3E5B			; indica que el personaje no quiere buscar ninguna ruta

5824: D7          rst  $10
		8E 05 -> [0x3ca9] = 0x05	; pasa al estado 5
5827: D7          rst  $10
		9F 9F 7F 2A -> [0x2ffe] = [0x2ffe] & 0x7f	; indica que las puertas ya no permanecen fijas
582C: D7          rst  $10
		A0 A0 7F 2A -> [0x3003] = [0x3003] & 0x7f
5831: C9          ret

5832: CF          rst  $08
		8E -> c1a = [0x3ca9]
		05 -> c2a = 0x05
		3D -> c = [0x3ca9] == 0x05
5836: 20 13       jr   nz,$584B			; si está en el estado 5
5838: D7          rst  $10
		86 05 -> [0x3caa] = 0x05		; se va a la mesa de la cocina de delante del pasadizo
583B: D7          rst  $10
		9E 40 DF -> [0x3ca6] = 0xdf;	; modifica la máscara de las puertas que pueden abrirse
583F: CF          rst  $08
		80 -> c1a = [0x3038]
		60 -> c2a = 0x60
		3C -> c = [0x3038] < 0x60
5843: 20 03       jr   nz,$5848			; si guillermo está en el ala izquierda de la abadía
5845: D7          rst  $10
		8E 0C -> [0x3ca9] = 0x0c		; pasa al estado 0x0c para advertir al abad
5848: C3 98 3E    jp   $3E98			; si ha llegado al sitio al que quería llegar, avanza el estado

584B: CF          rst  $08
		8E -> c1a = [0x3ca9]
		06 -> c2a = 0x06
		3D -> c = [0x3ca9] == 0x06
584F: 20 06       jr   nz,$5857		; si está en el estado 6
5851: D7          rst  $10
		86 00 -> [0x3caa] = 0x00	; va a la iglesia
5854: CD 98 3E    call $3E98		; si ha llegado al sitio al que quería llegar, avanza el estado
5857: CF          rst  $08
		8E -> c1a = [0x3ca9]
		0B -> c2a = 0x0b
		3D -> c = [0x3ca9] == 0x0b
585B: 20 0A       jr   nz,$5867		; si el estado de malaquías es el 0x0b
585D: CF          rst  $08
		89 -> c1a = [0x2da1]
		00 -> c2a = 0x00
		3D -> c = [0x2da1] == 0x00
5861: 20 03       jr   nz,$5866		; si no se está reproduciendo una frase
5863: D7          rst  $10
		AC 01 -> [0x3ca2] = 0x01	; indica que malaquías está muriendo
5866: C9          ret

5867: CF          rst  $08
		8E -> c1a = [0x3ca9]
		07 -> c2a = 0x07
		3D -> c = [0x3ca9] == 0x07
586B: 20 1B       jr   nz,$5888			; si está en el estado 7
586D: CF          rst  $08
		8D -> c1a = [0x2d80]
		05 -> c2a = 0x05
		3D -> c = [0x2d80] == 0x05
5871: 20 14       jr   nz,$5887			; si es el quinto día
5873: CF          rst  $08
		9A -> c1a = [0x2dbd]
		22 -> c2a = 0x22
		3D -> ca = [0x2dbd] == 0x22
		9A -> c1b = [0x2dbd]
		23 -> c2b = 0x23
		3D -> cb = [0x2dbd] == 0x23
		2A -> c = ([0x2dbd] == 0x22) | ([0x2dbd] == 0x23)
587B: 20 0A       jr   nz,$5887			; si está en la iglesia (la comparación con 0x23 no es necesaria?)
587D: D7          rst  $10
		87 01 -> [0x3ca8] = 0x01		; indica que no ha llegado a la iglesia todavía
5880: D7          rst  $10
		8E 0B -> [0x3ca9] = 0x0b		; pasa al estado 0x0b
5883: CD 1B 50    call $501B			; escribe en el marcador la frase
		1F								ERA VERDAD, TENIA EL PODER DE MIL ESCORPIONES
5887: C9          ret
5888: C9          ret

5889: CF          rst  $08
		88 -> c1 = [0x2d81]
		01 -> c2 = 0x01
		3D -> c = [0x2d81] == 0x01
588D: 20 07       jr   nz,$5896			; si es prima
588F: D7          rst  $10
		8E 09 -> [0x3ca9] = 0x09		; cambia al estado 9
5892: D7          rst  $10
		86 00 -> [0x3caa] = 0x00		; va a misa
5895: C9          ret

5896: CF          rst  $08
		87 -> c1 = [0x3ca8]
		02 -> c2 = 0x02
		3D -> c = [0x3ca8] == 0x02
589A: 20 09       jr   nz,$58A5		; si malaquías ha llegado a su puesto en el scriptorium
589C: D7          rst  $10
	8E 00 -> [0x3ca9] = 0x00		; cambia al estado 0
589F: D7          rst  $10
	BA 00 -> [0x2dff] = 0x00		; modifica la máscara de los objetos que puede coger malaquías
58A2: CD 22 40    call $4022		; deja la llave del pasadizo en la mesa de malaquías
58A5: CF          rst  $08
	8E -> c1 = [0x3ca9]
	00 -> c2 = 0x00
	3D -> c = [0x3ca9] == 0x00
58A9: C2 13 59    jp   nz,$5913		; si está en el estado 0
58AC: CD 61 3E    call $3E61		; compara la distancia entre guillermo y malaquías (si está muy cerca devuelve 0, en otro caso != 0)
58AF: C2 0F 59    jp   nz,$590F		; si está cerca de guillermo
58B2: CF          rst  $08
	86 -> c1 = [0x3caa]
	03 -> c2 = 0x03
	3D -> c = [0x3caa] == 0x03
58B6: 20 47       jr   nz,$58FF		; si ha salido a cerrar el paso a guillermo
58B8: CF          rst  $08
	AE -> c1 = [0x3ca5]
	40 80 -> c2 = 0x80
	2A -> c = [0x3ca5] & 0x80
58BD: 20 12       jr   nz,$58D1		; si berengario no ha llegado a su puesto de trabajo
58BF: CF          rst  $08
	81 -> c1 = [0x3039]
	38 -> c2 = 0x38
	3C -> c = [0x3039] < 0x38
58C3: 20 0A       jr   nz,$58CF		; si la posición y de guillermo < 0x38
58C5: D7          rst  $10
		AE AE 40 80 26 -> [0x3ca5] = [0x3ca5] | 0x80
58CB: CD 1B 50    call $501B		; dice la frase
	33								LO SIENTO, VENERABLE HERMANO, NO PODEIS SUBIR A LA BIBLIOTECA
58CF: 18 2D       jr   $58FE

58D1: CF          rst  $08
		AE -> c1 = [0x3ca5]
		40 40 -> c2 = 0x40
		2A -> c = [0x3ca5] & 0x40
58D6: 20 15       jr   nz,$58ED
58D8: CF          rst  $08
		8D -> c1a = [0x2d80]
		02 -> c2a = 0x02
		3D -> ca = [0x2d80] == 0x02
		89 -> cb = [0x2da1]
		26 -> c = ([0x2d80] == 0x02) && ([0x2da1] == 0)
58DE: 20 0B       jr   nz,$58EB	; si es el segundo día y no se está reproduciendo ninguna frase
58E0: D7          rst  $10
		AE AE 40 40 26 -> [0x3ca5] = [0x3ca5] | 0x40
58E6: CD 26 50    call $5026	; dice la frase
	34 							SI LO DESEAIS, BERENGARIO OS MOSTRARA EL SCRIPTORIUM
58EA: C9          ret

58EB: 18 11       jr   $58FE

58ED: CF          rst  $08
		AE -> c1 = [0x3ca5]
		10 -> c2 = 0x10
		2A -> c = [0x3ca5] & 0x10
58F1: 20 0B       jr   nz,$58FE
58F3: CD 61 3E    call $3E61		; compara la distancia entre guillermo y malaquías (si está muy cerca devuelve 0, en otro caso != 0)
58F6: 20 01       jr   nz,$58F9		; si está muy cerca, sale
58F8: C9          ret

; aquí llega si está lejos, pero esto no puede ser, ya que esto está dentro de un (si guillermo está cerca...) (???)
58F9: D7          rst  $10
		AE AE 10 26 -> [0x3ca5] = [0x3ca5] | 0x10 ; ???
58FE: C9          ret

58FF: CD BE 08    call $08BE		; descarta los movimientos pensados e indica que hay que pensar un nuevo movimiento
5902: AF          xor  a
5903: CD 82 34    call $3482		; comprueba si está pulsado el cursor arriba
5906: 20 03       jr   nz,$590B		; si ha pulsado cursor arriba, salta
5908: C3 5B 3E    jp   $3E5B		; indica que el personaje no quiere buscar ninguna ruta

590B: D7          rst  $10
		86 03 -> [0x3caa] = 0x03	; sale a cerrar el paso a guillermo
590E: C9          ret

590F: D7          rst  $10
		86 02 -> [0x3caa] = 0x02	; vuelve a su mesa
5912: C9          ret

5913: CF          rst  $08
		88 -> c1 = [0x2d81]
		02 -> c2 = 0x02
		3D -> c = [0x2d81] == 0x02
5917: 20 25       jr   nz,$593E		; si es tercia
5919: CF          rst  $08
		8E -> c1a = [0x3ca9]
		09 -> c2a = 0x09
		3D -> ca = [0x3ca9] == 0x09
		8D -> c1b = [0x2d80]
		05 -> c2b = 0x05
		3D -> cb = [0x2d80] == 0x05
		26 -> ca = ([0x3ca9] == 0x09) && ([0x2d80] == 0x05)
5921: 20 14       jr   nz,$5937		; si está en el estado 0x09 en el quinto día
5923: D7          rst  $10
		86 08 -> [0x3caa] = 0x08	; va a la celda de severino
5926: CF          rst  $08
		87 -> c1a = [0x3ca8]
		08 -> c2a = 0x08
		3D -> ca = [0x3ca8] == 0x08
		94 -> c1b = [0x3cff]
		02 -> c2b = 0x02
		3D -> cb = [0x3cff]
		26 -> c = ([0x3ca8] == 0x08) && ([0x3cff] == 0x02)
592E: 20 06       jr   nz,$5936		; si malaquías y severino están en la celda de severino
5930: D7          rst  $10
		AD 01 -> [0x3ca3] = 0x01	; mata a severino
5933: D7          rst  $10
		8E 0A -> [0x3ca9] = 0x0a	; cambia al estado 0x0a
5936: C9          ret

5937: D7          rst  $10
		8E 0A -> [0x3ca9] = 0x0a	; cambia al estado 0x0a
593A: D7          rst  $10
		86 02 -> [0x3caa] = 0x02	; va a su mesa de trabajo
593D: C9          ret
593E: C9          ret

; ------------------ fin de la lógica de malaquías ----------------

; ------------------ lógica de berengario/jorge/bernardo ----------------
593F: CF          rst  $08
		AB -> c1a = [0x3ca1]
		01 -> c2a = 0x01
		3D -> c = [0x3ca1] == 0x01
5943: 20 03       jr   nz,$5948		; si jorge no está haciendo nada, sale
5945: C3 5B 3E    jp   $3E5B		; indica que el personaje no quiere buscar ninguna ruta

5948: CF          rst  $08
		8D -> c1a = [0x2d80]
		03 -> c2a = 0x03
		3D -> c = [0x2d80] == 0x03
594C: 20 65       jr   nz,$59B3		; si es el tercer día
594E: CF          rst  $08
		88 -> c1a = [0x2d81]
		01 -> c2a = 0x01
		3D -> c = [0x2d81] == 0x01
5952: 20 03       jr   nz,$5957		; si es prima
5954: C3 5B 3E    jp   $3E5B		; indica que el personaje no quiere buscar ninguna ruta

5957: CF          rst  $08
		88 -> c1a = [0x2d81]
		02 -> c2a = 0x02
		3D -> c = [0x2d81] == 0x02
595B: 20 36       jr   nz,$5993		; si es tercia
595D: CF          rst  $08
		92 -> c1a = [0x3ce8]
		1E -> c2a = 0x1e
		3D -> c = [0x3ce8] == 0x1e
5961: 20 0C       jr   nz,$596F		; si está en el estado 0x1e
5963: CF          rst  $08
		89 -> c1a = [0x2da1]
		00 -> c2a = 0x00
		3D -> c = [0x2da1] == 0x00
5967: 20 03       jr   nz,$596C		; si no está reproduciendo una voz
5969: D7          rst  $10
		92 1F -> [0x3ce8] = 0x1f	; pasa al estado 0x1f
596C: C3 5B 3E    jp   $3E5B		; indica que el personaje no quiere buscar ninguna ruta

596F: CF          rst  $08
		92 -> c1a = [0x3ce8]
		1F -> c2a = 0x1f
		3D -> c = [0x3ce8] == 0x1f
5973: 20 0F       jr   nz,$5984		; si está en el estado 0x1f
5975: CD 61 3E    call $3E61		; compara la distancia entre guillermo y jorge (si está muy cerca devuelve 0, en otro caso != 0)
5978: 20 07       jr   nz,$5981		; si está lejos salta
597A: CD 26 50    call $5026		; pone en el marcador la frase
		32 							SED BIENVENIDO, VENERABLE HERMANO; Y ESCUCHAD LO QUE OS DIGO. LAS VIAS DEL ANTICRISTO SON LENTAS Y TORTUOSAS. LLEGA CUANDO MENOS LO ESPERAS. NO DESPERDICIEIS LOS ULTIMOS DIAS
597E: D7          rst  $10
		9B 01 -> [0x3c9a] = 0x01	; indica que hay que avanzar el momento del día
5981: C3 5B 3E    jp   $3E5B		; indica que el personaje no quiere buscar ninguna ruta

5984: CD 3E 61    call $3E61		; compara la distancia entre guillermo y jorge (si está muy cerca devuelve 0, en otro caso != 0)
5987: 20 07       jr   nz,$5990		; si está lejos de jorge, salta
5989: CD 1B 50    call $501B		; escribe en el marcador la frase
		31 							VENERABLE JORGE, EL QUE ESTA ANTE VOS ES FRAY GUILLERMO, NUESTRO HUESPED
598D: D7
	92 1E -> [0x3ce8] = 0x1e		; pasa al estado 0x1e
5990: C3 5B 3E    jp   $3E5B		; indica que el personaje no quiere buscar ninguna ruta

5993: CF          rst  $08
		88 -> c1a = [0x2d81]
		03 -> c2a = 0x03
		3D -> c = [0x2d81] == 0x03
5997: 20 1A       jr   nz,$59B3		; si es sexta
5999: D7          rst  $10
		90 03 -> [0x3ce9] = 0x03	; se va a la celda de los monjes
599C: D7          rst  $10
		92 00 -> [0x3ce8] = 0x00	; pasa al estado 0

599F: CF          rst  $08
		9D -> c1a = [0x3074]
		60 -> c2a = 0x60
		3D -> c = [0x3074] == 0x60
59A3: 20 04       jr   nz,$59A9		; si la posición x de jorge ??? esto no tiene mucho sentido, porque es una frase que dice adso!!!
59A5: CD 26 50    call $5026      	; pone en el marcador la frase
		27							PRONTO AMANECERA, MAESTRO
59A9: CF          rst  $08
		91 -> c1a = [0x3ce7]
		03 -> c2a = 0x03
		3D -> c = [0x3ce7] == 0x03
59AD: 20 03       jr   nz,$59B2		; si ha llegado a su celda, lo indica
59AF: D7          rst  $10
		AB 01 -> [0x3ca1] = 0x01	; indica que jorge no va a hacer nada más por ahora
59B2: C9          ret


; aquí llega si no es el tercer día
59B3: CF          rst  $08
		88 -> c1a = [0x2d81]
		03 -> c2a = 0x03
		3D -> c = [0x2d81] == 0x03
59B7: 20 04       jr   nz,$59BD		; si es sexta
59B9: D7          rst  $10
		90 01 -> [0x3ce9] = 0x01	; va al refectorio
59BC: C9          ret

59BD: CF          rst  $08
		88 -> c1a = [0x2d81]
		01 -> c2a = 0x01
		3D -> c = [0x2d81] == 0x01
59C1: 20 04       jr   nz,$59C7		; si es prima
59C3: D7          rst  $10
		90 00 -> [0x3ce9] = 0x00	; va a la iglesia
59C6: C9          ret

59C7: CF          rst  $08
		8D -> c1a = [0x2d80]
		05 -> c2a = 0x05
		3D -> c = [0x2d80] == 0x05
59CB: 20 0F       jr   nz,$59DC		; si es el quinto día
59CD: CF          rst  $08
		91 -> c1a = [0x3ce7]
		04 -> c2a = 0x04
		3D -> c = [0x3ce7] == 0x04
59D1: 20 06       jr   nz,$59D9		; si ha llegado a la salida de la abadía, lo indica
59D3: D7          rst  $10
		AB 01 -> [0x3ca1] = 0x01
59D6: D7
		9D 00 -> [0x3074] = 0x00	; posición x de berengario = 0
59D9: D7          rst  $10
		90 04 -> [0x3ce9] = 0x04	; se va de la abadía

59DC: CF          rst  $08
		88 -> c1a = [0x2d81]
		06 -> c2a = 0x06
		3D -> c = [0x2d81] == 0x06
59E0: 20 04       jr   nz,$59E6		; si es completas
59E2: D7          rst  $10
		90 03 -> [0x3ce9] = 0x03	; se va a la celda de los monjes
59E5: C9          ret

59E6: CF          rst  $08
		88 -> c1a = [0x2d81]
		00 -> c2a = 0x00
		3D -> c = [0x2d81] == 0x00	; si es de noche
59EA: C2 34 5A    jp   nz,$5A34
59ED: CF          rst  $08
		8D -> c1a = [0x2d80]
		03 -> c2a = 0x03
		3D -> c = [0x2d80] == 0x03	; si es el tercer día
59F1: C2 30 5A    jp   nz,$5A30
59F4: CF          rst  $08
		92 -> c1a = [0x3ce8]
		06 -> c2a = 0x06
		3D -> c = [0x3ce8] == 0x06
59F8: 20 29       jr   nz,$5A23		; si está en el estado 6
59FA: D7          rst  $10
		B0 40 80 -> [0x2e0d] = 0x80	; modifica la máscara de los objetos que puede coger
59FE: CF          rst  $08
		91 -> c1a = [0x3ce7]
		03 -> c2a = 0x03
		3D -> c = [0x3ce7] == 0x03
5A02: 20 04       jr   nz,$5A08		; si está en su celda
5A04: D7          rst  $10
		90 05 -> [0x3ce9] = 0x05	; indica que va hacia las escaleras al pie del scriptorium
5A07: C9          ret

5A08: D7          rst  $10
		90 40 FD -> [0x3ce9] = 0xfd	; se dirige hacia el libro
5A0C: CF          rst  $08
		A8 -> c1a = [0x2e0b]
		40 80 -> c2a = 0x80
		2A -> ca = [0x2e0b] & 0x80
		40 80 -> cb = 0x80
		3D -> c = ([0x2e0b] & 0x80) == 0x80
5A14: 20 0C       jr   nz,$5A22		; si tiene el libro
5A16: CF          rst  $08
		91 -> c1a = [0x3ce7]
		06 -> c2a = 0x06
		3D -> c = [0x3ce7] == 0x06
5A1A: 20 03       jr   nz,$5A1F		; si ha llegado a la celda de severino
5A1C: D7          rst  $10
		9B 01 -> [0x3c9a] = 0x01	; indica que hay que avanzar el momento del día
5A1F: D7          rst  $10
		90 06 -> [0x3ce9] = 0x06	; se dirige a la celda de severino
5A22: C9          ret

5A23: CF          rst  $08
		91 -> c1a = [0x3ce7]
		03 -> c2a = 0x03
		3D -> c = [0x3ce7] == 0x03	; si está en su celda
5A27: 20 07       jr   nz,$5A30
5A29: D7          rst  $10
		92 06 -> [0x3ce8] = 0x06	; pasa al estado 6
5A2C: CD 94 40    call $4094		; cambia la cara de berengario por la del encapuchado
5A2F: C9          ret

5A30: D7          rst  $10
		90 03 -> [0x3ce9] = 0x03	; se dirige a la celda de los monjes
5A33: C9          ret

5A34: CF          rst  $08
		88 -> c1a = [0x2d81]
		05 -> c2a = 0x05
		3D -> c = [0x2d81] == 0x05
5A38: 20 14       jr   nz,$5A4E		; si es visperas
5A3A: CF          rst  $08
		8D -> c1a = [0x2d80]
		02 -> c2a = 0x02
		3D -> ca = [0x2d80] == 0x02
		8E -> c1b = [0x3ca9]
		04 -> c2b = 0x04
		3C -> cb = [0x3ca9] < 0x04
		26 -> c = ([0x2d80] == 0x02) && ([0x3ca9] < 0x04)
5A42: 20 03       jr   nz,$5A47	; si es el segundo día y malaquías no ha abandonado el scriptorium
5A44: C3 5B 3E    jp   $3E5B			; indica que el personaje no quiere buscar ninguna ruta

5A47: D7          rst  $10
		92 01 -> [0x3ce8] = 0x01	; pasa al estado 1
5A4A: D7
		90 00 -> [0x3ce9] = 0x00	; va a la iglesia
5A4D: C9          ret

5A4E: CF          rst  $08
		8D -> c1 = [0x2d80]
		03 -> c2 = 0x03
		3C -> c = [0x2d80] < 3
5A52: C2 2C 5B    jp   nz,$5B2C		; si es el primer o segundo día
5A55: CF          rst  $08
		92 -> c1 = [0x3ce8]
		04 -> c2 = 0x04
		3D -> c = [0x3ce8] == 0x04
5A59: 20 21       jr   nz,$5A7C		; si está en el estado 4
5A5B: D7          rst  $10
		99 99 01 -> [0x3c98] = [0x3c98] + 1
5A60: CF          rst  $08
		99 -> c1a = [0x3c98]
		41 -> c2a = 0x41
		3C -> ca = [0x3c98] < 0x41
		9A -> c1b = [0x2dbd]
		40 40 -> c2b = 0x40
		3D -> cb = [0x2dbd] == 0x40
		26 -> c = ([0x3c98] < 0x41) && ([0x2dbd] == 0x40)
5A69: 20 0A       jr   nz,$5A75	; si no tiene mucho tiempo el pergamino y no ha cambiado de pantalla
5A6B: CF          rst  $08
		A4 -> c1 = [0x2def]
		10 -> c2 = 0x10
		2A -> c = [0x2def] & 0x10
5A6F: 20 03       jr   nz,$5A74		; si guillermo no tiene el pergamino
5A71: D7          rst  $10
		92 00 -> [0x3ce8] = 0		; cambia el estado de berengario
5A74: C9          ret

5A75: D7          rst  $10
		92 05 -> [0x3ce8] = 5		; cambia el estado de berengario
5A78: CD 7D 43    call $437D		; deshabilita el contador para que avance el momento del día de forma automática
5A7B: C9          ret

5A7C: CF          rst  $08
	92 -> c1 = [0x3ce8]
	05 -> c2 = 0x05
	3D -> c = [0x3ce8] == 0x05
5A80: 20 1B       jr   nz,$5A9D		; si está en el estado 5
5A82: D7          rst  $10
		90 40 FE -> [0x3ce9] = 0xfe	; va hacia la posición del abad
5A86: CF          rst  $08
		91 -> c1 = [0x3ce7]
		40 FE -> c2 = 0xfe
		3D -> c1 = [0x3ce7] == 0xfe
5A8B: 20 0F       jr   nz,$5A9C		; si berengario ha llegado a la posición del abad
5A8D:	D7          rst  $10
		99 40 C9 -> [0x3c98] = 0xc9
5A91: D7          rst  $10
		92 00 -> [0x3ce8] = 0		; cambia el estado de berengario
5A94: D7          rst  $10
		A5 01 -> [0x3c94] = 1		; indica que guillermo ha cogido el pergamino
5A97: D7
		AE AE 01 26 -> [0x3ca5] = [0x3ca5] | 0x01
5A9C: C9          ret

5A9D: CF          rst  $08
		91 -> c1 = [0x3ce7]
		02 -> c2 = 0x02
		3D -> c = [0x3ce7] == 0x02
5AA1: 20 1D       jr   nz,$5AC0		; si ha llegado a su mesa del scriptorium
5AA3: CD ED 43    call $43ED		; comprueba algo relacionado con el pergamino
5AA6: 20 18       jr   nz,$5AC0		; si guillermo ha codigo el pergamino
5AA8: D7          rst  $10
		99 00 -> [0x3c98] = 0x00	; reinicia el contador
5AAB: D7          rst  $10
		92 04 -> [0x3ce8] = 0x04	; pasa al estado 4
5AAE: CD 61 3E    call $3E61		; compara la distancia entre guillermo y berengario(si está muy cerca devuelve 0, en otro caso != 0)
5AB1: 20 06       jr   nz,$5AB9		; si está cerca de guillermo
5AB3: CD 26 50    call $5026		; pone en el marcador la frase
5AB6: 04          					DEJAD EL MANUSCRITO DE VENACIO O ADVERTIRE AL ABAD
5AB7: 18 06       jr   $5ABF
5AB9: D7          rst  $10
		92 05 -> [0x3ce8] = 0x05	; pasa al estado 5
5ABC: CD 7D 43    call $437D		; deshabilita el contador para que avance el momento del día de forma automática
5ABF: C9          ret

5AC0: CF          rst  $08
		AE -> c1a = [0x3ca5]
		40 40 -> c2a = 0x40
		2A -> ca = [0x3ca5] & 0x40
		40 40 -> cb = 0x40
		3D -> cc = ([0x3ca5] & 0x40) == 0x40
		82 -> c1d = [0x303a]
		0D -> c2d = 0x0d
		3E -> cd = [0x303a] >= 0x0d
		26 -> c = (([0x3ca5] & 0x40) == 0x40) && ([0x303a] >= 0x0d)
5ACC: 20 57       jr   nz,$5B25		; si malaquías le ha dicho que berengario le puede enseñar el scriptorium y la altura de guillermo >= 0x0d
5ACE: CF          rst  $08
		AE -> c1 = [0x3ca5]
		10 -> c2 = 0x10
		2A -> c = [0x3ca5] & 0x10
5AD2: 20 25       jr   nz,$5AF9		; si no le había dicho lo de los mejores copistas de occidente
5AD4: D7          rst  $10
		90 40 FF -> [0x3ce9] = 0xff	; berengario va a por guillermo
5AD8: CD 61 3E    call $3E61		; compara la distancia entre guillermo y berengario (si está muy cerca devuelve 0, en otro caso != 0)
5ADB: 20 19       jr   nz,$5AF6		; si está cerca de guillermo
5ADD: CF          rst  $08
		89 -> c1 = [0x2da1]
		00 -> c2 = 0x00
		3D -> c = [0x2da1] == 0x00
5AE1: 20 10       jr   nz,$5AF3		; si no se está reproduciendo una frase
5AE3: D7          rst  $10
		91 40 FF -> [0x3ce7] = 0xff	; indica que berengario ha llegado a donde está guillermo
5AE7: CD BE 08    call $08BE		; descarta los movimientos pensados e indica que hay que pensar un nuevo movimiento
5AEA: D7          rst  $10
		AE AE 10 26 -> [0x3ca5] = [0x3ca5] | 0x10	; indica que ya le ha dicho lo de los mejores copistas
5AEF: CD 26 50    call $5026		; pone en el marcador la frase
5AF2: 35          					AQUI TRABAJAN LOS MEJORES COPISTAS DE OCCIDENTE
5AF3: C3 5B 3E    jp   $3E5B		; indica que el personaje no quiere buscar ninguna ruta

5AF6: C9          ret

5AF7: 18 2C       jr   $5B25		; aquí no se llega nunca???

5AF9: CF          rst  $08
		AE -> c1 = [0x3ca5]
		08 -> c2 = 0x08
		2A -> c = [0x3ca5] & 0x08
5AFD: 20 26       jr   nz,$5B25		; si no le ha dicho lo de venacio
5AFF: D7          rst  $10
		90 02 -> [0x3ce9] = 0x02	; va a su mesa del scriptorium
5B02: CD 61 3E    call $3E61		; compara la distancia entre guillermo y berengario (si está muy cerca devuelve 0, en otro caso != 0)
5B05: 20 12       jr   nz,$5B19		; si está cerca de guillermo
5B07: CF          rst  $08
		91 -> c1a = [0x3ce7]
		02 -> c2a = 0x02
		3D -> ca = [0x3ce7] == 0x02
		89 -> cb = [0x2da1]
		26 -> c = ([0x3ce7] == 0x02) && [0x2da1]
5B0D: 20 09       jr   nz,$5B18		; si berengario ha llegado al scriptorium y no se estaba reproduciendo una frase
5B0F: D7          rst  $10
		AE AE 08 26 -> [0x3ca5] = [0x3ca5] | 0x08	; indica que ya le ha enseñado donde trabaja venacio
5B13: CD 26 50    call $5026		; pone en el marcador la frase
		36 							AQUI TRABAJABA VENACIO
5B18: C9          ret

5B19: CF          rst  $08
		91 -> c1 = [0x3ce7]
		02 -> c2 = 0x02
		3D -> c = [0x3ce7] == 0x02
5B1D: 20 06       jr   nz,$5B25		; si ha llegado a su puesto en el scriptorium y guillermo no le ha seguido
5B1F: D7          rst  $10
		AE AE 40 80 26 -> [0x3ca5] = [0x3ca5] | 0x80	; ??? esto es un bug del juego??? creo que debería ser 0x08 en vez de 0x80
5B25: D7          rst  $10
		92 00 -> [0x3ce8] = 0x00	; cambia el estado de berengario
5B28: D7          rst  $10
		90 02 -> [0x3ce9] = 0x02	; no se mueve de su puesto de trabajo
5B2B: C9          ret

5B2C: CF          rst  $08
		92 -> c1 = [0x3ce8]
		14 -> c2 = 0x14
		3D -> c = [0x3ce8] == 0x14
5B30: 20 0C       jr   nz,$5B3E		; si está en el estado 0x14
5B32: CF          rst  $08
		90 -> c1 = [0x3ce9]
		91 -> c2 = [0x3ce7]
		3D -> c = [0x3ce9] == [0x3ce7]
5B36: 20 05       jr   nz,$5B3D		; si ha llegado al sitio donde quería ir
5B38: D7          rst  $10
		90 B2 03 2A -> [0x3ce9] = [0x3c9d] & 0x03 ; se mueve de forma aleatoria por la abadía
5B3D: C9          ret

5B3E: CF          rst  $08
		8D -> c1 = [0x2d80]
		04 -> c2 = 0x04
		3D -> c = [0x2d80] == 0x04
5B42: C2 C5 5B    jp   nz,$5BC5		; si es el cuarto día
5B45: CF          rst  $08
		90 -> c1a = [0x3ce9]
		40 FE -> c2a = 0xfe
		3D -> ca = [0x3ce9] == 0xfe
		A6 -> c1b = [0x2e04]
		10 -> c2b = 0x10
		2A -> cb = [0x2e04] & 0x10
		10 -> cc = 0x10
		3D -> cd = ([0x2e04] & 0x10) == 0x10
		26 -> ([0x3ce9] == 0xfe) && (([0x2e04] & 0x10) == 0x10)
5B50: 20 0A       jr   nz,$5B5C	; si bernardo va a por el abad y el abad tiene el pergamino
5B52: D7          rst  $10
		92 14 -> [0x3ce8] = 0x14	; cambia el estado de berengario
5B55: D7          rst  $10
		90 01 -> [0x3ce9] = 0x01	; va al refectorio
5B58: D7          rst  $10
		8C 15 -> [0x3cc7] = 0x15	; cambia el estado del abad
5B5B: C9          ret

5B5C: CF          rst  $08
		A8 -> c1a = [0x2e0b]
		10 -> c2a = 0x10
		2A -> ca = [0x2e0b] & 0x10
		10 -> cb = 0x10
		3D -> c = ([0x2e0b] & 0x10) == 0x10
5B62: 20 0B       jr   nz,$5B6F		; si bernardo tiene el pergamino
5B64: D7          rst  $10
		90 40 FE -> [0x3ce9] = 0xfe	; va a por el abad
5B67: CD 43 7D    call $437D		; deshabilita el contador para que avance el momento del día de forma automática
5B6B: D7          rst  $10
		B0 00 -> [0x2e0d] = 0		; cambia la máscara de los objetos que puede coger bernardo
5B6E: C9          ret

5B6F: CF          rst  $08
	B3 -> c1a = [0x3c90]
	01 -> c2a = 0x01
	3D -> ca = [0x3c90] == 0x01
	A6 -> c1b = [0x2e04]
	10 -> c2b = 0x10
	2A -> cb = [0x2e04] & 0x10
	10 -> cc = 0x10
	3D -> cd = ([0x2e04] & 0x10) == 0x10
	2A -> ce = ([0x3c90] == 0x01) || (([0x2e04] & 0x10) == 0x10)
	8C -> c1f = [0x3cc7]
	0B -> c2f = 0x0b
	3D -> cf = [0x3cc7] == 0x0b
	2A -> c = ([0x3c90] == 0x01) || (([0x2e04] & 0x10) == 0x10) || ([0x3cc7] == 0x0b)
5B7D: 20 07       jr  nz,$5B86		; si el pergamino está a buen recaudo o el abad va a echar a guillermo
5B7F: D7          rst  $10
		90 02 -> [0x3ce9] = 0x02	; va a su puesto en el scriptorium
5B82: D7          rst  $10
		92 14 -> [0x3ce8] = 0x14	; cambia el estado de bernardo
5B85: C9          ret

5B86: D7          rst  $10
		B3 00 -> [0x3c90] = 0x00	; indica que el pergamino no se le ha quitado a guillermo
5B89: CD 7D 43    call $437D		; deshabilita el contador para que avance el momento del día de forma automática
5B8C: CF          rst  $08
	A4 -> c1a = [0x2def]
	10 -> c2a = 0x10
	2A -> ca = [0x2def] & 0x10
	10 -> cb = 0x10
	3D -> c = ([0x2def] & 0x10) == 0x10
5B92: 20 2D       jr   nz,$5BC1		; si guillermo tiene le pergamino
5B94: CF          rst  $08
		92 -> c1 = [0x3ce8]
		07 -> c2 = 0x07
		3D -> c = [0x3ce8] == 0x07
5B98: 20 18       jr   nz,$5BB2		; si está en el estado 7
5B9A: D7          rst  $10
		90 40 FF -> [0x3ce9] = 0xff	; va a por guillermo
5B9E: CD 61 3E    call $3E61		; compara la distancia entre guillermo y bernardo gui (si está muy cerca devuelve 0, en otro caso != 0)
5BA1: 20 0D       jr   nz,$5BB0		; si está cerca de guillermo
5BA3: CF          rst  $08
		89 -> c1 = [0x2da1]
		00 -> c2 = 0x00
		3D -> c = [0x2da1] == 0x00
5BA7: 20 07       jr   nz,$5BB0		; si no está mostrando una frase
5BA9: CD 26 50    call $5026		; pone en el marcador la frase
		05          				DADME EL MANUSCRITO, FRAY GUILLERMO
5BAD: CD CE 55    call $55CE		; decrementa la vida de guillermo en 2 unidades
5BB0: 18 0D       jr   $5BBF

5BB2: CD 61 3E    call $3E61		; compara la distancia entre guillermo y bernardo gui (si está muy cerca devuelve 0, en otro caso != 0)
5BB5: 20 04       jr   nz,$5BBB		; si está cerca de guillermo
5BB7: D7          rst  $10
		90 03 -> [0x3ce9] = 0x03	; va a la celda de los monjes
5BBA: C9          ret

5BBB: D7          rst  $10
		92 07 -> [0x3ce8] = 0x07	; cambia el estado de berengario
5BBE: C9          ret
5BBF: 18 04       jr   $5BC5

5BC1: D7          rst  $10
		90 40 FC -> [0x3ce9] = 0xfc	; va a por el pergamino
5BC5: C9          ret

; ------------------ fin de la lógica de berengario/jorge/bernardo gui ----------------

; ------------------ lógica de severino/jorge ----------------

5BC6: CF          rst  $08
		AD -> c1a = [0x3ca3]
		01 -> c2a = 0x01
		3D -> c = [0x3ca3] == 0x01
5BCA: 20 03       jr   nz,$5BCF
5BCC: C3 5B 3E    jp   $3E5B		; indica que el personaje no quiere buscar ninguna ruta

5BCF: CF          rst  $08
		8D -> c1a = [0x2d80]
		06 -> c2a = 0x06
		3E -> c = [0x2d80] >= 0x06
5BD3: C2 B0 5C    jp   nz,$5CB0		; si está en el día 6 o 7, el personaje es jorge y no severino
5BD6: CF          rst  $08
		95 -> c1a = [0x3d00]
		0B -> c2a = 0x0b
		3D -> c = [0x3d00] == 0x0b
5BDA: 20 0F       jr   nz,$5BEB		; si está en el estado 0x0b
5BDC: CF          rst  $08
		89 -> c1a = [0x2da1]
		00 -> c2a = 0x00
		3D -> c = [0x2da1] == 0x00
5BE0: 20 06       jr   nz,$5BE8		; si no está reproduciendo una voz
5BE2: CD AF 40    call $40AF		; deja el libro
5BE5: D7          rst  $10
		95 0C -> [0x3d00] = 0x0c
5BE8: C3 5B 3E    jp   $3E5B		; indica que el personaje no quiere buscar ninguna ruta

5BEB: CF          rst  $08
		95 -> c1a = [0x3d00]
		0C -> c2a = 0x0c
		3D -> c = [0x3d00] == 0x0c
5BEF: 20 14       jr   nz,$5C05		; si está en el estado 0x0c
5BF1: CF          rst  $08
		A4 -> c1a = [0x2def]
		40 80 -> c2a = 0x80
		2A -> c = ([0x2def] & 0x80) == 0
5BF6: 20 03       jr   nz,$5BFB		; si guillermo no tiene el libro
5BF8: C3 5B 3E    jp   $3E5B		; indica que el personaje no quiere buscar ninguna ruta

5BFB: CD 26 50    call $5026		; pone en el marcador la frase
		2E 							ES EL COENA CIPRIANI DE ARISTOTELES. AHORA COMPRENDEREIS POR QUE TENIA QUE PROTEGERLO. CADA PALABRA ESCRITA POR EL FILOSOFO HA DESTRUIDO UNA PARTE DEL SABER DE LA CRISTIANDAD. SE QUE HE ACTUADO SIGUIENDO LA VOLUNTAD DEL SEÑOR... LEEDLO, PUES, FRAY GUILLERMO. DESPUES TE LO MOSTRATE A TI MUCHACHO
5BFF: D7       ld   l,$D7
		95 0D -> [0x3d00] = 0x0d
5C02: C3 5B 3E    jp   $3E5B		; indica que el personaje no quiere buscar ninguna ruta

5C05: CF          rst  $08
		95 -> c1a = [0x3d00]
		0D -> c2a = 0x0d
		3D -> c = [0x3d00] = 0x0d	; si está en el estado 0x0d
5C09: 20 31       jr   nz,$5C3C
5C0B: CF          rst  $08
		A4 -> c1a = [0x2def]
		40 40 -> c2a = 0x40
		2A -> c = ([0x2def] & 0x40) == 0
5C10: 20 1A       jr   nz,$5C2C		; si guillermo no tiene los guantes
5C12: CF          rst  $08
		9C -> c1a = [0x3c97]
		00 -> c2a = 0x00
		3D -> c = [0x3c97] == 0x00
5C16: 20 11       jr   nz,$5C29		; si guillermo sigue vivo
5C18: CF          rst  $08
		9A -> c1a = [0x2dbd]
		72 -> c2a = 0x72
		3D -> ca = [0x2dbd] == 0x72
		89 -> cb = [0x2da1]
		2A -> c = ([0x2dbd] == 0x72) || ([0x2da1] == 0x00)
5C1E: 20 06       jr   nz,$5C26		; si ha salido a la habitación del espejo o ha terminado de reproducir la frase
5C20: D7          rst  $10
		BD 40 FF -> [0x3c85] = 0xff ; pone el contador para matar a guillermo en la siguiente ejecución de lógica por leer el libro sin los guantes
5C24: 18 03       jr   $5C29		; indica que la ejecución de la lógica ha terminado

5C26: D7          rst  $10
		BD 01 -> [0x3c85] = 0x01 	; inicia el contador para matar a guillermo por leer el libro sin los guantes
5C29: C3 5B 3E    jp   $3E5B		; indica que el personaje no quiere buscar ninguna ruta

5C2C: CF          rst  $08
		89 -> c1a = [0x2da1]
		00 -> c2a = 0x00
		3D -> c = [0x2da1] == 0x00
5C30: 20 07       jr   nz,$5C39		; si no se está reproduciendo una frase
5C32: CD 26 50    call $5026		; pone en el marcador la frase
		23							VENERABLE JORGE, VOIS NO PODEIS VERLO, PERO MI MAESTRO LLEVA GUANTES.  PARA SEPARAR LOS FOLIOS TENDRIA QUE HUMEDECER LOS DEDOS EN LA LENGUA, HASTA QUE HUBIERA RECIBIDO SUFICIENTE VENENO
5C36: D7          rst  $10
		95 0E -> [0x3d00] = 0x0e
5C39: C3 5B 3E    jp   $3E5B		; indica que el personaje no quiere buscar ninguna ruta

5C3C: CF          rst  $08
		95 -> c1a = [0x3d00]
		0E -> c2a = 0x0e
		3D -> c = [0x3d00] == 0x0e
5C40: 20 13       jr   nz,$5C55		; si está en el estado 0x0e
5C42: CF          rst  $08
		89 -> c1a = [0x2da1]
		00 -> c2a = 0x00
		3D -> c = [0x2da1] == 0x00
5C46: 20 0A       jr   nz,$5C52		; si no está reproduciendo una frase
5C48: D7          rst  $10
		99 00 -> [0x3c98] = 0x00
5C4B: D7          rst  $10
		95 0F -> [0x3d00] = 0x0f
5C4E: CD 26 50    call $5026		; pone en el marcador la frase
		2F 							FUE UNA BUENA IDEA ¿VERDAD?; PERO YA ES TARDE
5C52: C3 5B 3E    jp   $3E5B		; indica que el personaje no quiere buscar ninguna ruta

5C55: CF          rst  $08
		95 -> c1a = [0x3d00]
		0F -> c2a = 0x0f
		3D -> c = [0x3d00] == 0x0f
5C59: 20 1E       jr   nz,$5C79
5C5B: D7          rst  $10
		99 99 01 2B -> [0x3c98] = [0x3c98] + 1
5C60: CF          rst  $08
		99 -> c1a = [0x3c98]
		28 -> c2a = 0x28
		3D -> c = [0x3c98] == 0x28
5C64: 20 10       jr   nz,$5C76		; si el contador ha llegado al límite
5C66: CD 6C 1A    call $1A6C		; oculta el área de juego
5C69: D7          rst  $10
		93 04 -> [0x3d01] = 0x04
5C6C: CD 48 42    call $4248		; apaga la luz de la pantalla y le quita el libro a guillermo
5C6F: D7          rst  $10
		BC 00 -> [0x416e] = 0x00	; ???
5C72: D7          rst  $10
		95 10 -> [0x3d00] = 0x10
5C75: C9          ret

5C76: C3 5B 3E    jp   $3E5B		; indica que el personaje no quiere buscar ninguna ruta

5C79: CF          rst  $08
		95 -> c1a = [0x3d00]
		10 -> c2a = 0x10
		3D -> c = [0x3d00] == 0x10
5C7D: 20 1C       jr   nz,$5C9B
5C7F: CF          rst  $08
		94 -> c1a = [0x3cff]
		04 -> c2a = 0x04
		2D -> ca = [0x3cff] - 0x04
		9A -> c1b = [0x2dbd]
		67 -> c2b = 0x67
		3D -> cb = [0x2dbd] == 0x67
		26 -> cc = (([0x3cff] - 0x04) == 0) && ([0x2dbd] == 0x67)
		82 -> c1d = [0x303a]
		1E -> c2d = 0x1e
		3C -> cd = [0x303a] < 0x1e
		26 -> c = (([0x3cff] - 0x04) == 0) && ([0x2dbd] == 0x67) && ([0x303a] < 0x1e)
5C8B: 20 0D       jr   nz,$5C9A		; si jorge ha llegado a su destino y guillermo está en la habitación donde se va jorge con el libro y se acerca a éste
5C8D: D7          rst  $10
		B9 00 -> [0x3ca7] = 0x00	; indica que se ha completado la investigación
5C90: D7          rst  $10
		AD 01 -> [0x3ca3] = 0x01	; indica que ha muerto jorge
5C93: CD 1B 50    call $501B		; escribe en el marcador la frase
		24							SE ESTA COMIENDO EL LIBRO, MAESTRO
5C97: D7          rst  $10
		9C 01 -> [0x3c97] = 0x01	; indica que la investigación ha concluido
5C9A: C9          ret

5C9B: CF          rst  $08
		9A -> c1a = [0x2dbd]
		73 -> c2a = 0x73
		3D -> c = [0x2dbd] == 0x73
5C9F: 20 0C       jr   nz,$5CAD		; si se está en la habitación de detrás del espejo, le da un bonus
5CA1: D7          rst  $10
		C0 C0 08 26 -> [0x2dbf] = [0x2dbf] | 0x08
5CA6: CD 1B 50	  call $501B		; escribe en el marcador la frase
		21 							SOIS VOS, GUILERMO... PASAD, OS ESTABA ESPERANDO. TOMAD, AQUI ESTA VUESTRO PREMIO
5CAA: D7
		95 0B -> [0x3d00] = 0x0b	; inicia el estado de la secuencia final
5CAD: C3 5B 3E    jp   $3E5B		; indica que el personaje no quiere buscar ninguna ruta


; aquí llega el día < 6 (si es severino)
5CB0: CF          rst  $08
		88 -> c1a = [0x2d81]
		00 -> c2a = 0x00
		3D -> ca = [0x2d81] == 0x00
		88 -> c1b = [0x2d81]
		06 -> c2b = 0x06
		3D -> cb = [0x2d81] == 0x06
		2A -> c = ([0x2d81] == 0x00) || ([0x2d81] == 0x06)
5CB8: 20 07       jr   nz,$5CC1		; si es de noche o completas
5CBA: D7          rst  $10
		94 02 -> [0x3cff] = 0x02	; se va a su celda
5CBD: D7          rst  $10
		93 02 -> [0x3d01] = 0x02
5CC0: C9          ret

5CC1: CF          rst  $08
		88 -> c1a = [0x2d81]
		01 -> c2a = 0x01
		3D -> c = [0x2d81] == 0x01
5CC5: 20 36       jr   nz,$5CFD		; si es prima
5CC7: CF          rst  $08
		89 -> c1a = [0x2da1]
		01 -> c2a = 0x01
		3E -> c = [0x2da1] >= 0x01
		93 -> c1b = [0x3d01]
		40 FF -> c2b = 0xff
		3D -> c = [0x3d01] == 0xff
		26 -> c = ([0x2da1] >= 0x01) && ([0x3d01] == 0xff)
5CD0: 20 01       jr  nz,$5CD3		; si está reproduciendo una voz y va a por guillermo, sale
5CD2: C9          ret

5CD3: D7          rst  $10
		93 00 -> [0x3d01] = 0x00	; va a la iglesia
5CD6: CF          rst  $08
		8D -> c1a = [0x2d80]
		05 -> c2a = 0x05
		3D -> ca = [0x2d80] == 0x05
		B1 -> c1b = [0x3ca4]
		00 -> c2b = 0x00
		3D -> cb = [0x3ca4] == 0x00
		26 -> c = ([0x2d80] == 0x05) && ([0x3ca4] == 0x00)
5CDE: 20 1C       jr   nz,$5CFC		; si es el quinto día y guillermo no está en el ala izquierda de la abadía
5CE0: CF          rst  $08
		80 -> c1a = [0x3038]
		60 -> c2a = 0x60
		3C -> c = [0x3038] < 0x60
5CE4: 20 04       jr   nz,$5CEA		; si guillermo está en el ala izquierda de la abadía
5CE6: D7          rst  $10
		B1 01 -> [0x3ca4] = 0x01	; indica que guillermo está en el ala izquierda de la abadía
5CE9: C9          ret

5CEA: D7          rst  $10
		93 40 FF -> [0x3d01] = 0xff	; va a por guillermo
5CEE: CF          rst  $08
		94 -> c1a = [0x3cff]
		40 FF -> c2a = 0xff
		3D -> c = [0x3cff] == 0xff
5CF3: 20 07       jr   nz,$5CFC			; si ha llegado a donde está guillermo
5CF5: CD 1B 50    call $501B			; escribe en el marcador la frase
		0F								ESCUCHAD HERMANO, HE ENCONTRADO UN EXTRAÑO LIBRO EN MI CELDA
5CF9: D7          rst  $10
		B1 01 -> [0x3ca4] = 0x01	; indica que ya le ha dado el mensaje
5CFB: 01
5CFC: C9          ret

5CFD: CF          rst  $08
		88 -> c1a = [0x2d81]
		03 -> c2a = 0x03
		3D -> c = [0x2d81] == 0x03
5D01: 20 04       jr   nz,$5D07			; si es sexta
5D03: D7          rst  $10
		93 01 -> [0x3d01] = 0x01
5D06: C9          ret

5D07: CF          rst  $08
		88 -> c1a = [0x2d81]
		05 -> c2a = 0x05
		3C -> c = [0x2d81] < 0x05
5D0B: C2 9D 5D    jp   nz,$5D9D		; si aun no es vísperas
5D0E: CF          rst  $08
		AE -> c1a = [0x3ca5]
		02 -> c1b = 0x02
		2A -> ca = [0x3ca5] & 0x02
		94 -> c1b = [0x3cff]
		02 -> c2b = 0x02
		3E -> cb = [0x3cff] >= 0x02
		26 -> cc = (([0x3ca5] & 0x02) == 0) && ([0x3cff] >= 0x02)
		8D -> c1d = [0x2d80]
		02 -> c2d = 0x02
		3E -> cd = [0x2d80] >= 0x02
		26 -> ce = ((([0x3ca5] & 0x02) == 0) && ([0x3cff] >= 0x02)) && ([0x2d80] >= 0x02)
		8B -> c1f = [0x3cc8]
		40 FF -> c2f = 0xff
		3C -> cf = [0x3cc8] < 0xff
		26 -> c = (((([0x3ca5] & 0x02) == 0) && ([0x3cff] >= 0x02)) && ([0x2d80] >= 0x02)) && ([0x3cc8] < 0xff)
5D1F: 20 37       jp   nz,$5D58		; si no va a su celda, si se está paseando, si el día es >= 2 y si el abad no va a por guillermo
5D21: CF          rst  $08
		AE -> c1a = [0x3ca5]
		04 -> c2a = 0x04
		2A -> ca = [0x3ca5] & 0x04
		89 -> cb = [0x2da1]
		26 -> c = (([0x3ca5] & 0x04) == 0) && ([0x2da1] == 0)
5D27: 20 11       jr   nz,$5D3A		; si severino no se ha presentado y no se está reproduciendo una voz
5D29: CD 61 3E    call $3E61		; compara la distancia entre guillermo y severino (si está muy cerca devuelve 0, en otro caso != 0)
5D2C: 20 0C       jr   nz,$5D3A		; si severino está cerca de guillermo
5D2E: D7          rst  $10
		AE 04 -> [0x3ca5] = 0x04
5D31: D7          rst  $10
		93 40 FF -> [0x3d01] = 0xff	; va a por guillermo
5D35: CD 26 50    call $5026		; pone en el marcador la frase
		37							VENERABLE HERMANO, SOY SEVERINO, EL ENCARGADO DEL HOSPITAL. QUIERO ADVERTIROS QUE EN ESTA ABADIA SUCEDEN COSAS MUY EXTRAÑAS. ALGUIEN NO QUIERE QUE LOS MONJES DECIDAN POR SI SOLOS LO QUE DEBEN SABER
5D39: C9          ret

5D3A: CF          rst  $08
		AE -> c1a = [0x3ca5]
		04 -> c2a = 0x04
		2A -> ca = [0x3ca5] & 0x04
		04 -> cb = 0x04
		3D -> c = ([0x3ca5] & 0x04) == 0x04
5D40: 20 16       jr   nz,$5D58		; si se ha presentado severino, continúa
5D42: D7          rst  $10
		93 40 FF -> [0x3d01] = 0xff	; sigue a guillermo
5D46: CF          rst  $08
		89 -> c1a = [0x2da1]
		00 -> c2a = 0x00
		3D -> c = [0x2da1] == 0x00
5D4A: 20 0B       jr   nz,$5D57		; si ha terminado de hablar
5D4C: D7          rst  $10
		93 02 -> [0x3d01] = 0x02	; va a su celda
5D4F: D7          rst  $10
		94 03 -> [0x3cff] = 0x03
5D52: D7          rst  $10
		AE AE 02 26 -> [0x3ca5] = [0x3ca5] | 0x02	; indica que va a su celda
5D57: C9          ret

5D58: CF          rst  $08
		94 -> c1a = [0x3cff]
		40 FF -> c2a = 0xff
		3D -> c = [0x3cff] == 0xff
5D5D: 20 0E       jr   nz,$5D6D		; si ha llegado a la posición de guillermo
5D5F: CF          rst  $08
		89 -> c1a = [0x2da1]
		00 -> c2a = 0x00
		3D -> c = [0x2da1] == 0x00
5D63: 20 07       jr   nz,$5D6C		; si no se está reproduciendo una voz
5D65: CD 26 50    call $5026		; pone en el marcador la frase
		26 							ES MUY EXTRAÑO, HERMANO GUILLERMO. BERENGARIO TENIA MANCHAS NEGRAS EN LA LENGUA Y EN LOS DEDOS
5D69: D7          rst  $10
		9B 01 -> [0x3c9a] = 0x01	; indica que al acabar la frase avanza el momento del día
5D6C: C9          ret

5D6D: CF          rst  $08
		94 -> c1a = [0x3cff]		; si ha llegado a su celda
		02 -> c2a = 0x02
		3D -> c = [0x3cff] == 0x02
5D71: 20 26       jr   nz,$5D99
5D73: CF          rst  $08
		8D -> c1a = [0x2d80]
		05 -> c2a = 0x05
		3D -> c = [0x2d80] == 0x05
5D77: 20 03       jr   nz,$5D7C		; si es el quinto día
5D79: C3 5B 3E    jp   $3E5B		; indica que el personaje no quiere buscar ninguna ruta

5D7C: CF          rst  $08
		88 -> c1a = [0x2d81]
		02 -> c2a = 0x02
		3D -> ca = [0x2d81] == 0x02
		8D -> c1b = [0x2d80]
		04 -> c2b = 0x04
		3D -> cb = [0x2d80] == 0x04
		26 -> c = ([0x2d81] == 0x02) && ([0x2d80] == 0x04)
5D84: 20 0E       jr   nz,$5D94		; si es tercia del cuarto día
5D86: D7          rst  $10
		93 40 FF -> [0x3d01] = 0xff	; va a por guillermo
5D8A: CD 61 3E    call $3E61		; compara la distancia entre guillermo y severino (si está muy cerca devuelve 0, en otro caso != 0)
5D8D: 20 04       jr   nz,$5D93		; si está lejos, sale
5D8F: CD 26 50    call $5026		; pone en el marcador la frase
		2C         					ESPERAD, HERMANO
5D93: C9          ret

5D94: D7          rst  $10
		93 03 -> [0x3d01] = 0x03	; va a la habitación de al lado de las celdas de los monjes
5D97: 18 03       jr   $5D9C
5D99: D7          rst  $10
		93 02 -> [0x3d01] = 0x02	; va a su celda
5D9C: C9          ret

5D9D: D7          rst  $10
		93 00 -> [0x3d01] = 0x00	; va a la iglesia
5DA0: C9          ret
; -------------------- fin de la lógica de severino/jorge ----------------------------------------

; -------------------- inicio de la lógica de adso ----------------------------------------
5DA1: CF          rst  $08
		A4 -> c1a = [0x2def]
		10 -> c2a = 0x10
		2A -> ca = [0x2def] & 0x10
		10 -> cb = 0x10
		3D -> c = ([0x2def] & 0x10) == 0x10
5DA7: 20 03       jr   nz,$5DAC		; si guillermo tiene el pergamino
5DA9: D7          rst  $10
		B3 00 -> [0x3c90] = 0x00	; lo indica

5DAC: CF          rst  $08
		B4 -> ca = [0x3c8c]
		01 -> cb = 0x01
		3D -> [0x3c8c] == 0x01		; si se está acabando la noche, informa de ello
5DB0: 20 04       jr   nz,$5DB6
5DB2: CD 26 50    call $5026		; pone en el marcador la frase
		27          				PRONTO AMANECERA, MAESTRO

5DB6: CF          rst  $08
		B5 -> ca = [0x3c8d]
		01 -> cb = 0x01
		3D -> c = [0x3c8d] == 0x01	; si ha cambiado el estado de la lámpara a 1
5DBA: 20 07       jr   nz,$5DC3
5DBC: D7          rst  $10
		B5 00 -> [0x3c8d] = 0x00	; indica que se procesado el cambio de estado de la lámpara
5DBF: CD 1B 50    call $501B		; escribe en el marcador la frase
		28 							LA LAMPARA SE AGOTA

5DC3: CF          rst  $08
		B5 -> ca = [0x3c8d]			; si ha cambiado el estado de la lámpara a 2
		02 -> cb = 0x02
		3D -> c = [0x3c8d] == 0x02
5DC7: 20 13       jr   nz,$5DDC
5DC9: D7          rst  $10
		B5 00 -> [0x3c8d] = 0		; indica que se procesado el cambio de estado de la lámpara
5DCC: D7          rst  $10
		B6 32 -> [0x3c8e] = 0x32	; inicia el contador del tiempo que pueden ir a oscuras
5DCF: D7          rst  $10
		B7 00 -> [0x3c8b] = 0x00	; indica que la lámpara ya no se está usando?
5DD2: CD 6C 1A    call $1A6C		; oculta el área de juego
5DD5: CD F7 3F    call $3FF7		; le quita la lámpara a adso y reinicia los contadores?
5DD8: CD 1B 50    call $501B		; escribe en el marcador la frase
		2A 							SE HA AGOTADO LA LAMPARA

5DDC: CF          rst  $08
		9C -> ca = [0x3c97]
		00 -> cb = 0x00
		3D -> c = [0x3c97] == 0
5DE0: 20 4A       jr   nz,$5E2C		; si 0x3c97 == 0

; si guillermo no ha muerto, ejecuta esto
5DE2: CF          rst  $08
		B6 -> [0x3c8e]
		01 -> 0x01
		3E -> [0x3c8e] >= 0x01
5DE6: 20 20       jr   nz,$5E08		; si se ha activado el contador del tiempo a oscuras
5DE8: CF          rst  $08
		82 -> ca = [0x303a]
		40 18 -> cb = 0x18
		3C -> [0x303a] < 0x18
5DED: 20 04       jr   nz,$5DF3		; altura en el escenario de guillermo < 0x18, es decir, si ha salido de la la biblioteca
5DEF: D7          rst  $10
		B6 00 -> [0x3c8e] = 0x00	; si ha salido de la biblioteca, pone el contador a 0
5DF2: C9          ret

; aquí llega si sigue en la biblioteca
5DF3: D7          rst  $10
		B6 B6 01 2D -> [0x3c8e] = [0x3c8e] - 0x01	; decrementa el contador del tiempo que pueden ir a oscuras
5DF8: CF          rst  $08
		B6 -> c1a = [0x3c8e]
		01 -> c2a = 0x01
		3D -> [0x3c8e] == 0x01
5DFC: 20 08       jr   nz,$5E06		; si no es 1, salta
5DFE: D7          rst  $10
		9C 01 -> [0x3c97] = 0x01	; indica que guillermo ha muerto
5E01: CD 1B 50    call $501B		; escribe en el marcador la frase
		2B							JAMAS CONSEGUIREMOS SALIR DE AQUI
5E05: C9          ret

; aquí llega si está activo el contador del tiempo que pueden ir a oscuras, pero aún no se ha terminado
5E06: 18 24       jr   $5E2C

; aquí llega si no se ha activado el contador del tiempo a oscuras
5E08: CF          rst  $08
		85 -> c1a = [0x3049]
		40 18 -> c2a = 0x18
		3E -> c = [0x3049] >= 0x18
5E0D: 20 17       jr   nz,$5E26			; si la altura de adso >= 0x18 (si adso acaba de entrar en la biblioteca)
5E0F: D7          rst  $10
		96 40 FF -> [0x3d13] = 0xff		; indica que adso siga a guillermo
5E13: CF          rst  $08
		B8 -> c1a = [0x2df3]
		40 80 -> c2a = 0x80
		2A -> c = [0x2df3] & 0x80		; si no adso tiene la lámpara
5E18: 20 08       jr   nz,$5E22
5E1A: CD 1B 50    call $501B			; escribe en el marcador la frase
		13								DEBEMOS ENCONTRAR UNA LAMPARA, MAESTRO
5E1E: D7          rst  $10
		B6 64 -> [0x3c8e] = 0x64		; activa el contador del tiempo que pueden a oscuras
5E21: C9          ret

; aqui se llega si adso tiene la lámpara y acaba de entrar a la biblioteca
5E22: D7          rst  $10
		B7 01 -> [0x3c8b] = 0x01
5E25: C9          ret

; aquí llega si adso no está en la biblioteca
5E26: D7          rst  $10
		B7 00 -> [0x3c8b] = 0x00		; indica que la lámpara no se está usando
5E29: D7          rst  $10
		B6 00 -> [0x3c8e] = 0x00		; anula el contador del tiempo que pueden ir a oscuras

; aquí también se llega si guillermo ha muerto
5E2C: CF          rst  $08
		88 -> c1a = [0x2d81]
		03 -> c2a = 0x03
		3D -> c = [0x2d81] == 0x03
5E30: 20 0C       jr   nz,$5E3E			; si está en sexta
5E32: D7          rst  $10
		96 01 -> [0x3d13] = 0x01		; va al refectorio
5E35: D7          rst  $10
		A3 07 -> [0x3c96] = 0x07
5E38: D7          rst  $10
		A2 0C -> [0x3f0e] = 0x0c		; cambia la frase a mostrar por DEBEMOS IR AL REFECTORIO, MAESTRO
5E3B: C3 E5 5E    jp   $5EE5

5E3E: CF          rst  $08
		88 -> c1a = [0x2d81]
		05 -> c2a = 0x05
		3D -> ca = [0x2d81] == 0x05
		88 -> c1b = [0x2d81]
		01 -> c2b = 0x01
		3D -> cb = [0x2d81] == 0x01
		2A -> c = ([0x2d81] == 0x05) || ([0x2d81] == 0x01)
5E46: 20 0C       jr   nz,$5E54		; si es prima o vísperas
5E48: D7          rst  $10
		96 00 -> [0x3d13] = 0x00	; va a la iglesia
5E4B: D7          rst  $10
		A3 01 -> [0x3c96] = 0x01
5E4E: D7          rst $10
		A2 0B -> [0x3f0e] = 0x0b	; cambia la frase a mostrar por DEBEMOS IR A LA IGLESIA, MAESTRO
5E51: C3 E5 5E    jp   $5EE5

; aquí llega si no es prima ni vísperas ni sexta
5E54: CF          rst  $08
		88 -> c1a = [0x2d81]
		06 -> c2a = 0x06
		3D -> c = [0x2d81] == 0x06
5E58: 20 07       jr   nz,$5E61		; si está en completas
5E5A: D7          rst  $10
		98 06 -> [0x3d12] = 0x06	; cambia el estado de adso
5E5D: D7       ld   b,$D7
		96 02 -> [0x3d13] = 0x02	; se dirige a la celda
5E60: C9          ret

; aquí llega si no es prima ni vísperas ni sexta ni completas
5E61: CF          rst  $08
		88 -> c1a = [0x2d81]
		00 -> c2a = 0x00
		3D -> c = [0x2d81] == 0x00
5E65: C2 E0 5E    jp   nz,$5EE0		; si es de noche
5E68: CF          rst  $08
		98 -> c1a = [0x3d12]
		04 -> c2a = 0x04
		3D -> c = [0x3d12] == 0x04
5E6C: 20 40       jr   nz,$5EAE		; si el estado es 4 (se estaba en la celda esperando contestacion)
5E6E: CF          rst  $08
		9A -> c1a = [0x2dbd]
		37 -> c2a = 0x37
		3D -> c = [0x2dbd] == 0x37
5E72: 20 03       jr   nz,$5E77		; si se muestra la pantalla número 0x37 (la de fuera de nuestra celda)
5E74: D7          rst  $10
		9B 02 -> [0x3c9a] = 0x02	; se pasa al siguiente día

5E77: CF          rst  $08
		89 -> c1a = [0x2da1]
		00 -> c2a = 0x00
		3D -> c = [0x2da1] == 0x00
5E7B: 20 30       jr   nz,$5EAD		; si no se está reproduciendo una voz
5E7D: CF          rst  $08
		A1 -> c1a = [0x3c99]
		64 -> c2a = 0x64
		3E -> c = [0x3c99] >= 0x64	; si el contador para contestar es >= 100
5E81: 20 04       jr   nz,$5E87
5E83: D7          rst  $10
		9B 02 -> [0x3c9a] = 0x02	; si tardamos en contestar, pasa al siguiente día
5E86: C9          ret

5E87: D7          rst  $10
		A1 A1 01 2B -> [0x3c99] = [0x3c99] + 0x01	; incrementa el contador
5E8C: CD 65 50    call $5065		; imprime S:N o borra S:N dependiendo del bit 1 de 0x3c99
5E8F: CF          rst  $08
		A1 -> c1a = [0x3c99]
		01 -> c2a = 0x01
		2A -> ca = [0x3c99] & 0x01
		01 -> cb = 0x01
		3D -> c = ([0x3c99] & 0x01) == 0x01
5E95: 20 16       jr   nz,$5EAD		; dependiendo del bit 1, lee el estado del teclado
5E97: 3E 3C       ld   a,$3C
5E99: CD 82 34    call $3482		; comprueba si se ha pulsado la S
5E9C: 20 0C       jr   nz,$5EAA
5E9E: 3E 2E       ld   a,$2E
5EA0: CD 82 34    call $3482		; comprueba si se ha pulsado la N
5EA3: 20 01       jr   nz,$5EA6
5EA5: C9          ret

; aquí llega si se pulsa la N
5EA6: D7          rst  $10
		98 05 -> [0x3d12] = 0x05
5EA9: C9          ret

; aquí llega si se pulsa la S
5EAA: D7          rst  $10
		9B 02 -> [0x3c9a] = 0x02	; se avanza al siguiente día
5EAD: C9          ret

; aqui llega si es de noche y 0x3d12 no era 4
5EAE: D7          rst  $10
		96 40 FF -> [0x3d13] = 0xff	; sigue a guillermo
5EB2: CF          rst  $08
		98 -> c1a = [0x3d12]
		05 -> c2a = 0x05
		3D -> c = [0x3d12] == 0x05
5EB6: 20 0B       jr   nz,$5EC3		; si el estado es 5 (no dormimos)
5EB8: CF          rst  $08
		9A -> c1a = [0x2dbd]
		40 3E -> c2a = 0x03e
		3D -> c = [0x2dbd] == 0x3e
5EBD: 20 01       jr   nz,$5EC0			; si estamos en la pantalla 0x3e, salta
5EBF: C9          ret

; aquí llega si no estamos en nuestra celda
5EC0: D7          rst  $10
		98 06 -> [0x3d12] = 0x06		; si salimos de nuestra celda, cambia al estado 6

5EC3: CF          rst  $08
		98 -> c1a = [0x3d12]
		06 -> c2a = 0x06
		3D -> c = [0x3d12] == 0x06
5EC7: 20 17       jr   nz,$5EE0
5EC9: CD 61 3E    call $3E61			; compara la distancia entre guillermo y adso (si está muy cerca devuelve 0, en otro caso != 0)
5ECC: 20 11       jr   nz,$5EDF			; si no está cerca de guillermo, salta
5ECE: CF          rst  $08
		9A -> c1a = [0x2dbd]
		40 3E -> c2a = 0x03e
		3D -> c = [0x2dbd] == 0x3e
5ED3: 20 0A       jr   nz,$5EDF			; si estamos en la pantalla 0x3e (nuestra celda)
5ED5: D7          rst  $10
		A1 00 -> [0x3c99] = 0x00		; inicia el contador del tiempo de respuesta de guillermo a la pregunta de dormir
5ED8: D7          rst  $10
		98 04 -> [0x3d12] = 0x04
5EDB: CD 26 50    call $5026			; pone en el marcador la frase
		12					a			¿DORMIMOS?, MAESTRO
5EDF: C9          ret

5EE0: D7          rst  $10
		96 40 FF -> [0x3d13] = 0xff		; sigue a guillermo
5EE4: C9          ret


5EE5: CF          rst  $08
		98 -> c1a = [0x3d12]
		A3 -> c2a = [0x3c96]
		3D -> c = c1a == c2a
5EE9: 20 01       jr   nz,$5EEC		; si son iguales, sale
5EEB: C9          ret

5EEC: CD 61 3E    call $3E61		; compara la distancia entre guillermo y adso (si está muy cerca devuelve 0, en otro caso != 0)
5EEF: 20 03       jr   nz,$5EF4		; si no está cerca de guillermo, salta
5EF1: CD 0B 3F    call $3F0B		; pone en el marcador una frase (la frase se cambia dependiendo del estado)
5EF4: D7          rst  $10
		98 A3 -> [0x3d12] = [0x3c96]
5EF7: C9          ret

5EF8: C9          ret
; ------------ fin de la lógica de adso ----------------------------------------

; ------------ lógica dependiente del momento del día ----------------------------------------

; si ha cambiado el momento del día, ejecuta unas acciones dependiendo del momento del día
5EF9: CF          rst  $08			; interpreta los comandos que siguen a esta instrucción
		88 -> c1 = [0x2d81]
		AA -> c2 = [0x3c95]
		3D -> compara c1 y c2
5EFD: 20 03       jr   nz,$5F02		; si no ha cambiado el momento del día, sale
5EFF: C9          ret

5F00: 18 1C       jr   $5F1E		; salta a ret (???)

5F02: D7          rst  $10			; interpreta los comandos que siguen a esta instrucción
		AA 88 -> [0x3c95] = [0x2d81]; pone en 0x3c95 el momento del día
5F05: CD C8 41    call $41C8		; [0x3c93] = dato siguiente
5F08: 00							; datos usados por la llamada anterior
5F09: CF          rst  $08			; interpreta los comandos que siguen a esta instrucción
		88 -> c = [0x2d81]
5F0B: CD 10 3F    call $3F10		; salta a una rutina dependiendo del momento del día actual (en c)
		5F1F -> 0 (noche)
		5F3B -> 1 (prima)
		5F8C -> 2 (tercia)
		5F93 -> 3 (sexta)
		5FA6 -> 4 (nona)
		5FB9 -> 5 (visperas)
		5FBD -> 6 (completas)
		0000
5F1E: C9          ret

; rutina llamada en noche
5F1F: CF          rst  $08			; interpreta los comandos que siguen a esta instrucción
		8D -> c1 = [0x2d80]
		05 -> c2 = 0x05
		3D -> compara c1 y c2
5F23: 20 06       jr   nz,$5F2B		; si no es el día 5, salta
5F25: CD 31 41    call $4131		; pone las gafas de guillermo en la habitación iluminada del laberinto
5F28: CD 13 41    call $4113		; pone la llave de la habitación del altar en el altar

5F2B: CF          rst  $08			; interpreta los comandos que siguen a esta instrucción
		8D -> c1 = [0x2d80]
		06 -> c2 = 0x06
		3D -> compara c1 y c2
5F2F: 20 09       jr   nz,$5F3A		; si no es el día 6, salta
5F31: CD 27 41    call $4127		; pone la llave de la habitación de severino en la mesa de malaquías
5F34: CD 68 40    call $4068		; se cambia la cara de severino por la de jorge y aparece en la habitación del espejo
5F37: D7          rst  $10			; interpreta los comandos que siguen a esta instrucción
		AD 00 -> [0x3ca3] = 0		; indica que jorge está activo
5F3A: C9          ret

; rutina llamada en prima
5F3B: CD 6B 3F    call $3F6B		; dibuja y borra la espiral
5F3E: D7          rst  $10			; interpreta los comandos que siguen a esta instrucción
		9E 40 EF-> [0x3ca6] = 0xef	; modifica la máscara de las puertas que pueden abrirse
5F42: CD 44 3F    call $3F44		; selecciona paleta 2
5F45: CD 85 35    call $3585		; abre las puertas del ala izquierda de la abadía
5F48: CD 0C 10    call $100C		; sonido
5F4B: CF          rst  $08			; interpreta los comandos que siguen a esta instrucción
		8D -> c1 = [0x2d80]
		03 -> c2 = 0x03
		3E -> ¿c1 >= c2?
5F4F: 20 06       jr   nz,$5F57		; si no hemos llegado al tercer día, salta
5F51: CD F7 3F    call $3FF7		; le quita la lámpara a adso y reinicia los contadores de la lámpara
5F54: CD 00 41    call $4100		; si la lámpara estaba desaparecida, aparece en la cocina

5F57: CF          rst  $08			; interpreta los comandos que siguen a esta instrucción
		8D -> c1 = [0x2d80]
		02 -> c2 = 0x02
		3D -> compara c1 y c2
5F5B: 20 03       jr   nz,$5F60		; si no es el día 2, salta
5F5D: CD 37 40    call $4037		; desaparecen las lentes

5F60: CF          rst  $08			; interpreta los comandos que siguen a esta instrucción
		8D -> c1 = [0x2d80]
		03 -> c2 = 0x03
		3D -> compara c1 y c2
5F64: 20 18       jr   nz,$5F7E		; si no es el día 3, salta
5F66: CD F1 40    call $40F1		; le da el libro a jorge
5F69: CD 78 40    call $4078		; cambia la cara de berengario por la de jorge y lo coloca al final del corredor de las celdas
5F6C: D7          rst  $10			; interpreta los comandos que siguen a esta instrucción
		A8 00 -> [0x2e0b] = 0x00	; berengario/jorge no tiene ningún objeto
5F6F: D7          rst  $10			; interpreta los comandos que siguen a esta instrucción
		A6 00 -> [0x2e04] = 0x00	; el abad no tiene ningún objeto
5F72: CF          rst  $08			; interpreta los comandos que siguen a esta instrucción
		A4 -> c1 = [0x2def]
		10 -> c2 = 0x10
		2A -> c = c1 & c2
5F76: 20 06       jr   nz,$5F7E		; si guillermo tiene el pergamino, salta
5F78: CD DD 40    call $40DD		; pone el pergamino en la habitación detrás del espejo
5F7B: D7          rst  $10			; interpreta los comandos que siguen a esta instrucción
		B3 01 -> [0x3c90] = 0x01	; indica que guillermo no tiene el pergamino
5F7E: CF          rst $08			; interpreta los comandos que siguen a esta instrucción
		8D -> c1a = [0x2d80]
		05 -> c2a = 5
		3D -> ca = compara c1 y c2	; ca = si es el quinto día
		A4 -> c1b = [0x2def]
		08 -> c2b = 0x08
		2A -> cb = c1b & c2b		; cb = 0 si no tenemos la llave de la habitación del abad
		26 -> c = ca & cb			; c = si es el quinto día y no tenemos la llave de la habitación del abad
5F86: 20 03       jr   nz,$5F8B		; si es el quinto día y no tenemos la llave de la habitación del abad, ésta desaparece
5F88: CD 1D 41    call $411D		; desaparece la llave 1
5F8B: C9          ret

; rutina llamada en tercia
5F8C: CD 6B 3F    call $3F6B		; dibuja y borra la espiral
5F8F: CD 11 10    call $1011		; pone en el canal 1 el sonido de las campanas
5F92: C9          ret

; rutina llamada en sexta
5F93: CD 0C 10    call $100C
5F96: CF          rst  $08			; interpreta los comandos que siguen a esta instrucción
		8D -> c1 = [0x2d80]
		04 -> c2 = 0x04
		3D -> compara c1 y c2
5F9A: 20 09       jr   nz,$5FA5		; si no es el cuarto día, sale
5F9C: CD 58 40    call $4058		; aparece bernardo en la entrada de la iglesia
5F9F: D7          rst  $10			; interpreta los comandos que siguen a esta instrucción
		AB 00 -> [0x3ca1] = 0x00
5FA2: D7          rst  $10			; interpreta los comandos que siguen a esta instrucción
		B0 10 -> [0x2e0d] = 0x10
5FA5: C9          ret

; rutina llamada en nona
5FA6: CD 6B 3F    call $3F6B		; dibuja y borra la espiral
5FA9: CF          rst  $08			; interpreta los comandos que siguen a esta instrucción
		8D -> c1 = [0x2d80]
		03 -> c2 = 0x03
		3D -> compara c1 y c2
5FAD: 20 06       jr   nz,$5FB5		; si no es el tercer día, salta
5FAF: D7          rst  $10			; interpreta los comandos que siguen a esta instrucción
		AB 01 -> [0x3ca1] = 0x01	; jorge pasa a estar inactivo
5FB2: D7          rst  $10			; interpreta los comandos que siguen a esta instrucción
		9D 00 -> [0x3074] = 0x00	; desaparece jorge
5FB5: CD 11 10    call $1011		; pone en el canal 1 el sonido de las campanas
5FB8: C9          ret

; rutina llamada en visperas
5FB9: CD 0C 10    call $100C		; sonido
5FBC: C9          ret

; rutina llamada en completas
5FBD: CD 6B 3F    call $3F6B		; dibuja y borra la espiral
5FC0: CD 49 3F    call $3F49		; fija la paleta 3
5FC3: D7          rst  $10			; interpreta los comandos que siguen a esta instrucción
	9E 40 DF -> [0x3ca6] = 0xdf		; modifica las puertas que pueden abrirse
5FC7: CD 11 10    call $1011		; pone en el canal 1 el sonido de las campanas
5FCA: C9          ret

; ------------ fin de la lógica dependiente del momento del día ----------------------------------------

; ------------------ lógica del abad ----------------
5FCB: CF          rst  $08
	80 -> c1a = [0x3038]
	60 -> c2a = 0x60
	3C -> ca = c1a < c2a			; ca = 0 si la posición de guillermo es < 0x60
	88 -> c1b = [0x2d81]
	01 -> c2b = 0x01
	3D -> cb = [0x2d81] == 0x01		; cb = 0 si es prima
	8D -> c1c = [0x2d80]
	01 -> c2c = 0x01
	3D -> cc = [0x2d80] == 0x01		; cc = 0 si es el día 1
	2A -> cd = cb | cc				; cd = 0 si es el día 1 o si es prima
	26 -> c = ca & cd				; c = (si la posición de guillermo es < 0x60) y (es el día 1 o es prima)
5FD7: 20 03       jr  nz,$5fdc
5FD9: D7          rst  $10
		8C 0B -> [0x3cc7] = 0x0b	; cambia el estado del abad para que eche a guillermo de la abadía
5FDC: CF          rst  $08
		88 -> c1a = [0x2d81]
		01 -> c2a = 0x01
		3E -> ca = [0x2d81] >= 0x01 ; ca = 0 si el momento del día es >= prima (no es de noche)
		82 -> c1b = [0x303a]
		16 -> c2b = 0x16
		3E -> cb = [0x303a] >= 0x16	; cb = 0 si la altura de guillermo es >= 0x16 (sube a la biblioteca)
		26 -> c = ca & cb			; c = 0 si guillermo sube a la biblioteca cuando no es por la noche
5FE3: 20 07       jr   nz,$5FED		; si guillermo sube a la biblioteca cuando no es de noche, lo echan, en otro caso, salta
5FE6: D7          rst  $10
		8B 09 -> [0x3cc8] = 0x09	; indica que el abad va a la puerta del pasillo que va a la biblioteca
5FE9: D7          rst  $10
		8C 0B -> [0x3cc7] = 0x0b	; cambia el estado del abad para que eche a guillermo de la abadía
5FEC: C9          ret

5FED: CF          rst  $08
		8C -> c1 = [0x3cc7]
		0B -> c2 = 0x0b
		3D -> c = [0x3cc7] == 0x0b	; c = 0 si el abad está en el estado de expulsar a guillermo de la abadia
5FF1: 20 1E       jr   nz,$6011
5FF3: D7          rst  $10
		8B 40 FF -> [0x3cc8] = 0xff	; indica que el abad persigue a guillermo
5FF7: CD 61 3E    call $3E61		; comprueba si el abad está cerca de guillermo
5FFA: 20 14       jr   nz,$6010		; si guillermo no está cerca, sale
5FFC: CF          rst  $08
		9C -> c1 = [0x3c97]
		01 -> c2 = 0x01
		3D -> c = [0x3c97] == 0x01
6000: 20 01       jr   nz,$6003		; si guillermo no está muerto, salta
6002: C9          ret

; aquí llega si guillermo está cerca del abad cuando lo va a echar, pero aún está vivo
6003: CF          rst  $08
		89 -> c1 = [0x2da1]
		00 -> c2 = 0x00
		3D -> c = [0x2da1] == 0
6007: 20 07       jr   nz,$6010		; si se está reproduciendo alguna voz, salta
6009: CD 26 50    call $5026		; en otro caso, pone en el marcador la frase
		0E 							NO HABEIS RESPETADO MIS ORDENES. ABANDONAD PARA SIEMPRE ESTA ABADIA
600D: D7          rst  $10
	9C 01 -> [0x3c97] = 0x01		; mata a guillermo
6010: C9          ret

6011: CF          rst  $08
		9A -> c1a = [0x2dbd]
		0D -> c2a = 0x0d
		3D -> ca = [0x2dbd] == 0x0d	; ca = si la pantalla que se está mostrando actualmente es la del abad
		A7 -> cb = [0x3c92]
		26 -> c = ca & cb			; c = 0 si la pantalla que se está mostrando actualmente es la del abad y la cámara sigue a guillermo
6017: 20 15       jr   nz,$602E
6019: CD 61 3E    call $3E61		; comprueba si el abad está cerca de guillermo
601C: 20 0C       jr   nz,$602A		; si está cerca de guillermo
601E: CD 26 50    call $5026		; pone en el marcador la frase
		29          				HABEIS ENTRADO EN MI CELDA
6022: D7          rst  $10
		8B 40 FF -> [0x3cc8] = 0xff	; va a por guillermo
6026: D7          rst  $10
		8C 0B -> [0x3cc7] = 0x0b	; pone al abad en estado de expulsar a guillermo de la abadia
6029: C9          ret

602A: D7          rst  $10
		8B 02 -> [0x3cc8] = 0x02	; va a su celda
602D: C9          ret


602E: CF          rst  $08
		8B -> c1a = [0x3cc8]
		8A -> c2a = [0x3cc6]
		3D -> ca = [0x3cc6] == [0x3cc8]	; si el abad ha llegado donde quería ir
		8A -> c1b = [0x3cc6]
		02 -> c2b = 0x02
		3D -> cb = [0x3cc6] == 0x02		; si ha llegado a su celda
		26 -> cc = ca & cb
		A6 -> c1d = [0x2e04]
		10 -> c2d = 0x10
		2A -> cd = [0x2e04] & 0x10		; si tiene el pergamino
		10 -> ce = 0x10
		3D -> cf = cd == ce
		26 -> c = cc & cf
603C: 20 16       jr   nz,$6054			; si ha llegado a su celda y tiene el pergamino
603E: D7          rst  $10
		B3 01 -> [0x3c90] = 0x01		; indica que guillermo no tiene el pergamino
6041: CD B9 40   call $40B9				; deja el pergamino
6044: CF         rst  $08
		8C -> c1a = [0x3cc7]
		15 -> c2a = 0x15
		3D -> ca = [0x3cc7] == 0x15
		A6 -> c1b = [0x2e04]
		10 -> c2b = 0x10
		2A -> cb = [0x2e04] & 0x10
		26 -> c = ca & cb
604C: 20 06      jr  nz,$6054			; si está en el estado 0x15 y no tiene el pergamino
604E: D7         rst  $10
		9B 01 -> [0x3c9a] = 0x01			; indica que hay que avanzar el momento del día
6051: D7         rst  $10
		8C 10 -> [0x3cc7] = 0x10			; pasa al estado 0x10

6054: CF          rst  $08
		8C -> ca = [0x3cc7]
		15 -> cb = 0x15
		3D -> c = [0x3cc7] == 0x15
6058: 20 04       jr   nz,$605E			; si está en el estado 0x15
605A: D7          rst  $10
		8B 02 -> [0x3cc8] = 0x02		; se va a su celda
605D: C9          ret

605E: CF          rst  $08
		8C -> ca = [0x3cc7]
		40 80 -> cb = 0x80
		3E -> c = [0x3cc7] >= 0x80
6063: 20 12       jr  nz,$6077			; si el abad tiene puesto el bit 7 de su estado
6065: CF          rst  $08
		89 -> ca = [0x2da1]
		00 -> cb = 0x00
		3D -> c = [0x2da1] == 0x00
6069: 20 07       jr   nz,$6072			; si no está reproduciendo una frase
606B: D7          rst  $10
		8C 8C 7F 2A = [0x3cc7] = [0x3cc7] & 0x7f	; quita el bit 7 de su estado
6070: 18 05       jr   $6077

6072: D7          rst  $10
		8B 40 FF -> [0x3cc8] = 0xff		; va a por guillermo
6076: C9          ret

6077: CF          rst  $08
		88 -> ca = [0x2d81]
		05 -> cb = 0x05
		3D -> c = [0x2d81] == 0x05
607B: 20 17       jr   nz,$6094		; si está en vísperas
607D: D7          rst  $10
		8C 05 -> [0x3cc7] = 0x05	; pasa al estado 5
6080: CD AC 43    call $43AC		; comprueba que guillermo esté en la posición correcta de misa (si vale 0 está en otra habitación, si vale 2 está en la habitación, pero mal situado, y si vale 1 está bien situado)
6083: D7          rst  $10
		8B 00 -> [0x3cc8] = 0x00	; va al altar
6086: D7          rst  $10
		A2 17 -> [0x3f0e] = 0x17	; frase = OREMOS
6089: CF          rst  $08
		8D -> ca = [0x2d80]
		01 -> cb = 0x01
		2D -> c = [0x2d80] - 0x01
608D: CD 87 64    call $6487		; salta a una rutina para comprobar que personajes deben haber llegado
6090: CD 20 65    call $6520		; espera a que el abad, el resto de monjes y guillermo estén en su sitio y si es así avanza el momento del día
6093: C9          ret

6094: CF          rst  $08
		88 -> ca = [0x2d81]
		01 -> cb = 0x01
		3D -> c = [0x2d81] == 0x01
6097: 20 17       jr   nz,$60B1		; si está en prima
609A: D7          rst  $10
		8C 0E -> [0x3cc7] = 0x0e	; pasa al estado 0x0e
609D: CD AC 43    call  $43AC		; comprueba que guillermo esté en la posición correcta de misa (si vale 0 está en otra habitación, si vale 2 está en la habitación, pero mal situado, y si vale 1 está bien situado)
60A0: D7          rst  $10
		8B 00 -> [0x3cc8] = 0x00	; va a misa
60A3: D7          rst  $10
		A2 17 -> [0x3f0e] = 0x17	; frase = OREMOS
60A6: CF          rst  $08
		8D -> ca = [0x2d80]
		02 -> cb = 0x02
		2D -> c = [0x2d80] - 0x02
60AA: CD C0 64    call $64C0		; comprueba si los monjes han llegado a su sitio
60AD: CD 20 65    call $6520		; espera a que el abad, el resto de monjes y guillermo estén en su sitio y si es así avanza el momento del día
60B0: C9          ret

60B1: CF          rst  $08
		88 -> ca = [0x2d81]
		03 -> cb = 0x03
		3D -> c = [0x2d81] == 0x03
60B5: 20 1A       jr   nz,$60D1		; si es sexta
60B7: D7          rst  $10
		8B 01 -> [0x3cc8] = 0x01	; va al refectorio
60BA: CD B9 43    call $43B9		; comprueba si guillermo está en la posición adecuada del receptorio (si vale 0 está en otra habitación, si vale 2 está en la habitación, pero mal situado, y si vale 1 está bien situado)
60BD: D7          rst  $10
		8C 10 -> [0x3cc7] = 0x10 	; pasa al estado 0x10
60C0: D7          rst  $10
		A2 19 -> [0x3f0e] = 0x19	; frase = PODEIS COMER, HERMANOS
60C3: D7          rst  $10
		A3 01 -> [0x3c96] = 0x01	; indica que la comprobacion es negativa inicialmente
60C6: CF          rst  $08
		8D -> c1 = [0x2d80]
		02 -> c2 = 0x02
		2D -> c = [0x2d80] - 0x02
60CA: CD EA 64    call $64EA		; salta a una rutina para comprobar si han llegado los monjes dependiendo de c (día)
60CD: CD 20 65    call $6520		; espera a que el abad, el resto de monjes y guillermo estén en su sitio y si es así avanza el momento del día
60D0: C9          ret

60D1: CF          rst  $08
		88 -> c1a = [0x2d81]
		06 -> c2a = 0x06
		3D -> ca = [0x2d81] == 0x06
		8C -> c1b = [0x3cc7]
		05 -> c2b = 0x05
		3D -> cb = [0x3cc7] == 0x05
		26 -> c = ([0x2d81] == 0x06) && ([0x3cc7] == 0x05)
60D9: 20 0E       jr   nz,$60E9		; si es completas y está en estado 5
60DB: D7          rst  $10
		8C 06 -> [0x3cc7] = 0x06	; pasa al estado 6
60DE: CF          rst  $08
		9A -> c1a = [0x2dbd]
		22 -> c2a = 0x22
		3D -> c = [0x2dbd] == 0x22
60E2: 20 04       jr   nz,$60E8		; si se muestra la pantalla de misa
60E4: CD 26 50    call $5026		; pone en el marcador la frase
		0D 							PODEIS IR A VUESTRAS CELDAS
60E8: C9          ret

60E9: CF          rst  $08
		A5 -> c1a = [0x3c94]
		01 -> c2a = 0x01
		3D -> c = [0x3c94] == 0x01
60ED: 20 3C       jr   nz,$612B		; si berengario le ha avisado de que guillermo ha cogido el pergamino
60EF: D7          rst  $10
		8B 40 FF -> [0x3cc8] = 0xff	; va a por guillermo
60F3: CD D7 40    call $40D7		; a = 0x10 (pergamino)
60F6: CF          rst  $08
		A6 -> c1a = [0x2e04]
		10 -> c2a = 0x10
		2A -> ca = [0x2e04] & 0x10
		10 -> cb = 0x10
		3D -> c = ([0x2e04] & 0x10) == 0x10
60FC: 20 0B       jr   nz,$6109		; si el abad tiene el pergamino
60FE: D7          rst  $10
		8C 15 -> [0x3cc7] = 0x15	; estado = 0x15
6101: D7          rst  $10
		8A 40 FF -> [0x3cc6] = 0xff	; indica que ha llegado a donde estaba guillermo
6105: D7          rst  $10
		A5 00 -> [0x3c94] = 0x00	; limpia el aviso de berengario
6108: C9          ret

6109: CD 61 3E    call $3E61		; compara la distancia entre guillermo y el abad (si está muy cerca devuelve 0, en otro caso != 0)
610C: 20 18       jr   nz,$6126		; si está cerca de guillermo
610E: CF          rst  $08
		99 -> c1a = [0x3c98]
		40 C8 -> c2a = 0xc8
		3E -> c = [0x3c98] >= 0xc8
6113: 20 0A       jr   nz,$611F		; si el contador ha pasado el límite
6115: CD CE 55    call $55CE		; decrementa la vida de guillermo en 2 unidades
6118: CD 26 50    call $5026		; pone en el marcador la frase
		05          				DADME EL MANUSCRITO, FRAY GUILLERMO
611C: D7          rst  $10
		99 00 -> [0x3c98] = 0x00	; reinicia el contador
611F: D7          rst  $10
		99 99 01 2B -> [0x3c98] = [0x3c98] + 0x01	; incrementa el contador
6124: 18 04       jr   $612A

6126: D7          rst  $10
		99 40 C9 -> [0x3c98] = 0xc9;	; pone el contador al máximo
612A: C9          ret

612B: CF          rst  $08
		88 -> c1a = [0x2d81]
		06 -> c2a = 0x06
		3D -> c = [0x2d81] == 0x06
612F: C2 DF 61    jp   nz,$61DF		; si es completas
6132: CF          rst  $08
		8C -> c1a = [0x3cc7]
		06 -> c2a = 0x06
		3D -> c = [0x3cc7] == 0x06
6136: 20 10       jr   nz,$6148		; si está en estado 0x06
6138: CF          rst  $08
		89 -> c1a = [0x2da1]
		00 -> c2a = 0x00
		3D -> c = [0x2da1] == 0x00
613C: 20 09       jr   nz,$6147		; si no se está mostrando una frase
613E: D7          rst  $10
		99 00 -> [0x3c98] = 0x00	; limpia el contador
6141: D7          rst  $10
		8B 05 -> [0x3cc8] = 0x05	; se va a la posición para que entremos a nuestra celda
6144: CD 98 3E    call $3E98		; si ha llegado al sitio al que quería llegar, avanza el estado
6147: C9          ret

6148: CF          rst  $08
		8C -> c1a = [0x3cc7]
		07 -> c2a = 0x07
		3D -> c = [0x3cc7] == 0x07
614C: 20 27       jr   nz,$6175		; si está en estado 0x07
614E: CF          rst  $08
		9A -> c1a = [0x2dbd]
		40 3E -> c2a = 0x3e
		3D -> c = [0x2dbd] == 0x3e
6153: 20 04       jr   nz,$6159		; si guillermo está en su celda
6155: D7          rst  $10
		8C 09 -> [0x3cc7] = 0x09	; pasa al estado 0x09
6158: C9          ret

6159: CD 61 3E    call $3E61		; compara la distancia entre guillermo y el abad (si está muy cerca devuelve 0, en otro caso != 0)
615C: 20 08       jr   nz,$6166		; si no está cerca, salta
615E: D7          rst  $10
		8C 08 -> [0x3cc7] = 0x08	; pasa al estado 0x08
6161: CD 26 50    call $5026		; pone en el marcador la frase
		10 							ENTRAD EN VUESTRA CELDA, FRAY GUILLERMO
6165: C9          ret

6166: D7          rst  $10			; avanza el contador
		99 99 01 2B -> [0x3c98] = [0x3c98] + 0x01
616B: CF          rst $08
	99 -> c1a = [0x3c98]
	32 -> c2a = 0x32
	3E -> c = [0x3c98] >= 0x32
616F: 20 03       jr   nz,$6174		; si el contador pasa el límite tolerable
6171: D7          rst  $10
		8C 08 -> [0x3cc7] = 0x08	; pasa al estado 0x08
6174: C9          ret

6175: CF          rst  $08
		8C -> c1a = [0x3cc7]
		08 -> c2a = 0x08
		3D -> c = [0x3cc7] == 0x08
6179: 20 34       jr   nz,$61AF		; si está en el estado 0x08
617B: CF          rst  $08
		9A -> c1a = [0x2dbd]
		40 3E -> c2a = 0x3e
		3D -> c = [0x2dbd] == 0x3e
6180: 20 04       jr   nz,$6186		; si guillermo ha entrado en su celda
6182: D7          rst  $10
		8C 09 -> [0x3cc7] = 0x09	; pasa al estado 0x09
6185: C9          ret

6186: D7          rst  $10
		99 99 01 2B -> [0x3c98] = [0x3c98] + 1	; incrementa el contador
618B: CF          rst  $08
		99 -> c1a = [0x3c98]
		32 -> c2b = 0x32
		3E -> c = [0x3c98] >= 0x32
618F: 20 03       jr   nz,$6194		; si ha pasado el límite, lo mantiene
6191: D7          rst  $10
		99 32 -> [0x3c98] = 0x32
6194: CD 61 3E    call $3E61		; compara la distancia entre guillermo y el abad (si está muy cerca devuelve 0, en otro caso != 0)
6197: 20 11       jr   nz,$61AA		; si guillermo está cerca
6199: CF          rst  $08
		99 -> c1a = [0x3c98]
		32 -> c2a = 0x32
		3D -> c = [0x3c98] == 0x32
619D: 20 0A       jr   nz,$61A9		; si el contador está al límite
619F: CD CE 55    call $55CE		; decrementa la vida de guillermo en 2 unidades
61A2: CD 26 50    call $5026		; pone en el marcador la frase
		10 							ENTRAD EN VUESTRA CELDA, FRAY GUILLERMO
61A6: D7          rst  $10
		99 00 -> [0x3c98] = 0x00	; reinicia el contador
61A9: C9          ret

61AA: D7          rst  $10
		8B 40 FF -> [0x3cc8] = 0xff	; va a por guillermo
61AE: C9          ret


61AF: CF          rst  $08
		8C -> c1a = [0x3cc7]
		09 -> c2a = 0x09
		3D -> c = [0x3cc7] == 0x09
61B3: 20 1A       jr   nz,$61CF		; si está en el estado 0x09
61B5: CF          rst  $08
		9A -> c1a = [0x2dbd]
		40 3E -> c1b = 0x3e
		3D -> c = [0x2dbd] == 0x3e	; si la pantalla que se está mostrando es la de la celda de guillermo
61BA: 20 08       jr   nz,$61C4
61BC: D7          rst  $10
		8B 06 -> [0x3cc8] = 0x06	; se mueve hacia la puerta
61BE: CD 3E 98    call $3E98		; si ha llegado al sitio al que quería llegar, avanza el estado
61C2: 18 0A       jr   $61CE

61C4: CD BE 08    call $08BE		; descarta los movimientos pensados e indica que hay que pensar un nuevo movimiento
61C7: D7          rst  $10
		8C 08 -> [0x3cc7] = 0x08	; cambia de estado
61CA: D7          rst  $10
		8B 40 FF -> [0x3cc8] = 0xff	; va a por guillermo
61CE: C9          ret

61CF: CF          rst  $08
		8C -> c1a = [0x3cc7]
		0A -> c2a = 0x0a
		3D -> c = [0x3cc7] == 0x0a
61D3: 20 09       jr   nz,$61DE		; si está en el estado 0x0a
61D5: D7          rst  $10
		9B 01 -> [0x3c9a] = 0x01	; indica que hay que avanzar el momento del día
61D8: D7          rst  $10
		9E 9E 40 F7 2A -> [0x3ca6] = [0x3ca6] & 0xf7	; modifica la máscara de puertas que pueden abrirse para que no pueda abrirse la puerta de al lado del a celda de guillermo
61DE: C9          ret

61DF: CF          rst  $08
		88 -> c1a = [0x2d81]
		00 -> c2a = 0x00
		3D -> c = [0x2d81] == 0x00
61E3: C2 45 62    jp   nz,$6245		; si es de noche
61E6: D7          rst  $10
		8B 02 -> [0x3cc8] = 0x02	; va a su celda
61E9: CF          rst  $08
		8C -> c1a = [0x3cc7]
		0A -> c2a = 0x0a
		3D -> ca = [0x3cc7] == 0x0a
		8A -> c1b = [0x3cc6]
		02 -> c2b = 0x02
		3D -> cb = [0x3cc6] == 0x02
		26 -> c = ([0x3cc7] == 0x0a) && ([0x3cc6] == 0x02)
61F1: 20 06       jr   nz,$61F9	; si está en estado 0x0a y ha llegado a su celda
61F3: D7          rst  $10
		99 00 -> [0x3c98] = 0x00	; pone el contador a 0
61F6: D7          rst  $10
		8C 0C -> [0x3cc7] = 0x0c	; pasa a estado 0x0c

61F9: CF          rst  $08
		8C -> c1a = [0x3cc7]
		0C -> c2a = 0x0c
		3D -> c = [0x3cc7] == 0x0c
61FD: 20 20       jr   nz,$621F		; si está en estado 0x0c
61FF: CF          rst  $08
		80 -> c1 = [0x3038]
		60 -> c2 = 0x60
		3E -> c = [0x3038] >= 0x60	; si guillermo no está en el ala izquierda de la abadía
6203: 20 19       jr   nz,$621e
6205: D7          rst  $10
		99 99 01 2B -> [0x3c98] = [0x3c98] + 1	; incrementa el contador
620A: CF          rst  $08
		99 -> c1a = [0x3c98]
		40 FA -> c2a = 0xfa
		3E -> ca = [0x3c98] >= 0xfa
		8D -> c1b = [0x2d80]
		05 -> c2b = 0x05
		3D -> cb = [0x2d80] == 0x05
		A4 -> c1c = [0x2def]
		08 -> c2c = 0x08
		2A -> cc = [0x2def] & 0x08
		08 -> cd = 0x08
		3D -> ce = ([0x2def] & 0x08) == 0x08
		26 -> cf = ([0x2d80] == 0x05) && ([0x2def] & 0x08) == 0x08
		2A -> c = ([0x3c98] >= 0xfa) || ([0x2d80] == 0x05) && ([0x2def] & 0x08) == 0x08
6219: 20 03       jr   nz,$621E	; si el contador ha superado el límite, o es el quinto día y tenemos la llave de la habitación del abad
621B: D7          rst  $10
		8C 0D -> [0x3cc7] = 0x0d	; cambia al estado 0x0d
621E: C9          ret

621F: CF          rst  $08
		8C -> c1 = [0x3cc7]
		0D -> c2 = 0x0d
		3D -> c = [0x3cc7] == 0x0d
6223: 20 1F       jr   nz,$6244		; si está en el estado 0x0d
6225: CF          rst  $08
		80 -> c1a = [0x3038]
		60 -> c2a = 0x60
		3C -> ca = [0x3038] < 0x60
		9A -> c1b = [0x2dbd]
		40 3E -> c2b = 0x3e
		3D -> cb = [0x2dbd] == 0x3e
		2A -> c = ([0x3038] < 0x60) || ([0x2dbd] == 0x3e)
622E: 20 07       jr   nz,$6237		; si guillermo está en el ala izquierda de la abadía o en su celda
6230: D7          rst  $10
		8C 0C -> [0x3cc7] = 0x0c	; cambia al estado 0x0c
6233: D7          rst  $10
		99 32 -> [0x3c98] = 0x32;
6236: C9          ret

6237: CD 61 3E    call $3E61		; compara la distancia entre guillermo y el abad (si está muy cerca, devuelve 0, en otro caso devuelve algo != 0)
623A: 20 03       jr   nz,$623F		; si está muy cerca
623C: D7          rst  $10
		8C 0B -> [0x3cc7] = 0x0b	; cambia al estado para echarlo de la abadía
623F: D7          rst  $10
		8B 40 FF -> [0x3cc8] = 0xff ; va a por guillermo
6243: C9          ret

6244: C9          ret

6245: CF          rst  $08
	8D -> c1 = [0x2d80]
	01 -> c2 = 0x01
	3D -> c = [0x2d80] == 0x01
6249: C2 FA 62    jp   nz,$62FA		; si es el primer día
624C: CF          rst  $08
		88 -> c1 = [0x2d81]
		04 -> c2 = 0x04
		3D -> c = [0x2d81] == 0x04
6250: C2 F9 62    jp   nz,$62F9		; si es nona
6253: CF          rst  $08
		8C -> c1 = [0x3cc7]
		04 -> c2 = 0x04
		3D -> c = [0x3cc7] == 0x04
6257: 20 0D       jr   nz,$6266		; si está en el estado 0x04
6259: D7          rst  $10
		8B 02 -> [0x3cc8] = 0x02	; va a su celda
625C: CF          rst  $08
		8A -> c1 = [0x3cc6]
		02 -> c2 = 0x02
		3D -> c = [0x3cc6] == 0x02
6260: 20 03       jr   nz,$6265		; si ha llegado a su celda
6262: D7          rst  $10
		9B 01 -> [0x3c9a] = 0x01	; indica que hay que avanzar el momento del día
6265: C9          ret

6266: CF          rst  $08
		8C -> c1 = [0x3cc7]
		00 -> c2 = 0x00
		3D -> c = [0x3cc7] == 0x00
626A: 20 17       jr   nz,$6283		; si está en el estado 0x00
626C: CD 61 3E    call $3E61		; compara la distancia entre guillermo y el abad (si está muy cerca devuelve 0, en otro caso != 0)
626F: 20 0E       jr   nz,$627F
6271: CD 26 50    call $5026		; pone en el marcador la frase
	01 							BIENVENIDO A ESTA ABADIA, HERMANO. OS RUEGO QUE ME SIGAIS. HA SUCEDIDO ALGO TERRIBLE
6275: D7          rst  $10
	8C 01 -> [0x3cc7] = 0x01		; cambia al estado 0x01
6278: D7          rst  $10
	8B 40 FF -> [0x3cc8] = 0xff		; va a por guillermo
627C: C9          ret

627D: 18 04       jr   $6283

627F: D7          rst  $10
		8B 03 -> [0x3cc8] = 0x03	; va a la entrada de la abadía
6282: C9          ret

6283: CD 61 3E    call $3E61		; compara la distancia entre guillermo y el abad (si está muy cerca devuelve 0, en otro caso != 0)
6286: C2 F6 62    jp   nz,$62F6		; si no está cerca
6289: CF          rst  $08
		8C -> c1 = [0x3cc7]
		01 -> c2 = 0x01
		3D -> c = [0x3cc7] == 0x01
628D: 20 1A       jr   nz,$62A9		; si está en el estado 0x01
628F: CF          rst  $08
		8B -> c1a = [0x3cc8]
		04 -> c2a = 0x04
		3D -> ca = [0x3cc8] == 0x04
		89 -> cb = [0x2da1]
		26 -> cc = ([0x3cc8] == 0x04) && ([0x2da1] == 0)
6295: 20 05       jr   nz,$629C		; si va a la primera parada y no se está reproduciendo ninguna frase
6297: D7          rst  $10
		8C 02 -> [0x3cc7] = 0x02	; cambia al estado 0x02
629A: 18 0D       jr   $62A9

629C: CF          rst  $08
		89 -> c1 = [0x2da1]
		00 -> c2 = 0x00
		3D -> c = [0x2da1] == 0x00
62A0: 20 07       jr   nz,$62A9		; si no se está reproduciendo una frase
62A2: D7          rst  $10
		8B 04 -> [0x3cc8] = 0x04	; va a la primera parada durante el discurso de bienvenida
62A5: CD 26 50    call $5026		; pone en el marcador la frase
		02							TEMO QUE UNO DE LOS MONJES HA COMETIDO UN CRIMEN. OS RUEGO QUE LO ENCONTREIS ANTES DE QUE LLEGUE BERNARDO GUI, PUES	NO DESEO QUE SE MANCHE EL NOMBRE DE ESTA ABADIA
62A9: CF          rst  $08
		8C -> c1 = [0x3cc7]
		02 -> c2 = 0x02
		3D -> c = [0x3cc7]
62AD: 20 0E       jr   nz,$62BD	; si está en el estado 0x02
62AF: D7          rst  $10
		8B 04 -> [0x3cc8] = 0x04  ; va a la primera parada durante el discurso de bienvenida
62B2: CF          rst  $08
		8A -> c1a = [0x3cc6]
		04 -> c2a = 0x04
		3D -> ca = [0x3cc6] == 0x04
		89 -> cb = [0x2da1]
		26 -> c = ([0x3cc6] == 0x04) && ([0x2da1] == 0x00)
62B8: 20 03       jr   nz,$62BD		; si ha llegado a la primera parada y no está reproduciendo una frase
62BA: D7          rst  $10
		8C 03 -> [0x3cc7] = 0x03	; pasa al estado 0x03
62BD: CF          rst  $08
	8C -> c1 = [0x3cc7]
	03 -> c2 = 0x03
	3D -> c = [0x3cc7] == 0x03
62C1: 20 1A       jr   nz,$62DD		; si está en el estado 0x03
62C3: CF          rst  $08
	8B -> c1a = [0x3cc8]
	05 -> c2a = 0x05
	3D -> ca = [0x3cc8] == 0x05
	89 -> cb = [0x2da1]
	26 -> c = ([0x3cc8] == 0x05) && ([0x2da1] == 0)
62C9: 20 05       jr   nz,$62D0		; si va hacia nuestra celda y no está reproduciendo una voz
62CB: D7          rst  $10
		8C 1F -> [0x3cc7] = 0x1f	; cambia al estado 0x1f
62CE: 18 0D       jr   $62DD

62D0: CF          rst  $08
		89 -> c1 = [0x2da1]
		00 -> c2 = 0x00
		3D -> c = [0x2da1] == 0x00
62D4: 20 07       jr   nz,$62DD		; si no está reproduciendo una voz
62D6: D7          rst  $10
		8B 05 -> [0x3cc8] = 0x05	; va a la entrada de nuestra celda
62D9: CD 26 50    call $5026		; pone en el marcador la frase
		03							DEBEIS RESPETAR MIS ORDENES Y LAS DE LA ABADIA. ASISTIR A LOS OFICIOS Y A LA COMIDA. DE NOCHE DEBEIS ESTAR EN VUESTRA CELDA
62DD: CF          rst  $08
		8C -> c1 = [0x3cc7]
		1F -> c2 = 0x1f
		3D -> c = [0x3cc7] == 0x1f
62E1: 20 12       jr   nz,$62F5		; si está en el estado 0x1f
62E3: D7          rst  $10
		8B 05 -> [0x3cc8] = 0x05	; va a la entrada de nuestra celda
62E6: CF          rst  $08
		8A -> c1a = [0x3cc6]
		05 -> c2a = 0x05
		3D -> ca = [0x3cc6] == 0x05
		89 -> cb = [0x2da1] == 0x00
		26 -> c = ([0x3cc6] == 0x05) && ([0x2da1] == 0x00)
62EC: 20 07       jr   nz,$62F5		; si ha llegado a la entrada de nuestra celda y no está reproduciendo una voz
62EE: D7          rst  $10
		8C 04 -> [0x3cc7] = 0x04	; pasa al estado 0x04
62F1: CD 26 50    call $5026		; pone en el marcador la frase
		07							ESTA ES VUESTRA CELDA, DEBO IRME
62F5: C9          ret

62F6: C3 6C 64    jp   $646C		; le echa una bronca a guillermo

62F9: C9          ret

62FA: CF          rst  $08
		8D -> c1 = [0x2d80]
		02 -> c2 = 0x02
		3D -> c = [0x2d80] == 0x02
62FE: 20 06       jr   nz,$6306		; si es el segundo día
6300: D7          rst  $10
	A2 16 -> [0x3f0e] = 0x16		; frase = DEBEIS SABER QUE LA BIBLIOTECA ES UN LUGAR SECRETO. SOLO MALAQUIAS PUEDE ENTRAR. PODEIS IROS
6303: C3 CF 63    jp   $63CF

6306: CF          rst  $08
		8D -> c1 = [0x2d80]
		03 -> c2 = 0x03
		3D -> c = [0x2d80] == 0x03
630A: 20 2A       jr   nz,$6336		; si es el tercer día
630C: CF          rst  $08
		8C -> c1a = [0x3cc7]
		10 -> c2a = 0x10
		3D -> ca = [0x3cc7] == 0x10
		88 -> c1b = [0x2d81]
		02 -> c2b = 0x02
		3D -> cb = [0x2d81] == 0x02
		26 -> c = ([0x3cc7] == 0x10) && ([0x2d81] == 0x02)
6314: 20 1A       jr   nz,$6330		; si está en el estado 0x10 y el momento del día es tercia
6316: CD 61 3E    call $3E61		; compara la distancia entre guillermo y el abad (si está muy cerca devuelve 0, en otro caso != 0)
6319: 20 04       jr   nz,$631F		; si está cerca de guillermo
631B: D7          rst  $10
		8B 07 -> [0x3cc8] = 0x07	; va a la pantalla en la que presenta a jorge
631E: C9          ret

631F: CF          rst  $08
		92 -> c1 = [0x3ce8]
		1E -> c2 = 0x1e
		3E -> c = [0x3ce8] >= 0x1e
6323: 20 05       jr   nz,$632A		; si el estado de jorge >= 0x1e (ya ha presentado a guillermo ante jorge)
6325: D7          rst  $10
		92 92 01 2D -> [0x3ce8] = [0x3ce8] - 1
632A: D7          rst  $10
		9B 00 -> [0x3c9a] = 0x00	; no hay que avanzar el momento del día
632D: C3 6C 64    jp   $646C		; le echa una bronca a guillermo

6330: D7          rst  $10
		A2 30 -> [0x3f0e] = 0x30	; frase = QUIERO QUE CONOZCAIS AL HOMBRE MAS VIEJO Y SABIO DE LA ABADIA
6333: C3 CF 63    jp  $63CF

6336: CF          rst  $08
		8D -> c1 = [0x2d80]
		04 -> c2 = 0x04
		3D -> c = [0x2d80] == 0x04
633A: 20 06       jr   nz,$6342		; si es el cuarto día
633C: D7          rst  $10
		A2 11 -> [0x3f0e] = 0x11	; frase = HA LLEGADO BERNARDO, DEBEIS ABANDONAR LA INVESTIGACION
633F: C3 CF 63    jp  $63CF

6342: CF          rst  $08
	8D -> c1 = [0x2d80]
	05 -> c2 = 0x05
	3D -> c = [0x2d80] == 0x05
6346: 20 65       jr   nz,$63AD		; si es el quinto día
6348: CF          rst  $08
	88 -> c1 = [0x2d81]
	04 -> c2 = 0x04
	3D -> c = [0x2d81] == 0x04
634C: 20 59       jr   nz,$63A7		; si es nona
634E: CF          rst  $08
	8A -> c1 = [0x3cc6]
	08 -> c2 = 0x08
	3D -> c = [0x3cc6] == 0x08		; si ha llegado a la puerta de la celda de severino
6352: 20 20       jr   nz,$6374
6354: CF          rst  $08
	99 -> c1 = [0x3c98]
	00 -> c2 = 0x00
	3D -> c = [0x3c98] == 0x00
6358: 20 03       jr   nz,$635D		; si no se ha iniciado el contador
635A: CD 2A 10    call $102A		; pone un sonido
635D: D7          rst  $10
	99 99 01 2B -> [0x3c98] = [0x3c98] + 1	; incrementa el contador
6362: CF          rst  $08
		99 -> c1 = [0x3c98]
		1E -> c2 = 0x1e
		3C -> c = [0x3c98] < 0x1e
6366: 20 01       jr   nz,$6369		; si el contador es < 0x1e, sale
6368: C9          ret

6369: D7          rst  $10
	8C 10 -> [0x3cc7] = 0x10		; cambia el estado 0x10
636C: CD 26 50    call $5026		; pone en el marcador la frase
	1C 								DIOS SANTO... HAN ASESINADO A SEVERINO Y LE HAN ENCERRADO
6370: D7          rst  $10
		9B 01 -> [0x3c9a] = 0x01	; avanza el momento del día
6373: C9          ret

6374: CF          rst  $08
		8B -> c1a = [0x3cc8]
		08 -> c2a = 0x08
		3D -> ca = [0x3cc8] == 0x08
		8C -> c1b = [0x3cc7]
		13 -> c2b = 0x13
		3E -> cb = [0x3cc7] == 0x13
		2A -> c = ([0x3cc8] == 0x08) || ([0x3cc7] == 0x13)
637C: 20 21       jr   nz,$639F		; si el abad va a la celda de severino o está en el estado 0x13
637E: D7          rst  $10
	99 00 -> [0x3c9a] = 0x00		; inicia el contador
6381: CF          rst  $08
	8C -> c1 = [0x3cc7]
	13 -> c2 = 0x13
	3D -> c = [0x3cc7] == 0x13
6385: 20 0C       jr   nz,$6393		; si está en el estado 0x13
6387: CD 61 3E    call $3E61		; compara la distancia entre guillermo y el abad (si está muy cerca devuelve 0, en otro caso != 0)
638A: 20 04       jr   nz,$6390		; si está cerca de guillermo
638C: D7          rst  $10
	8B 08 -> [0x3cc8] = 0x08		; va a la puerta de la celda de severino
638F: C9          ret

6390: C3 6C 64    jp   $646C		; le echa una bronca a guillermo

6393: CF          rst  $08
	89 -> c1 = [0x2da1]
	00 -> c2 = 0x00
	3D -> c = [0x2da1] == 0x00
6397: 20 03       jr   nz,$639C		; si no se está reproduciendo una voz
6399: D7          rst  $10
	8C 13 -> [0x3cc7] = 0x13		; pasa al estado 0x13
639C: C9          ret

639D: 18 08       jr   $63A7		; aquí no se llega nunca???

639F: CD 1B 50    call $501B		; escribe en el marcador la frase
		1B							VENID, FRAY GUILLERMO, DEBEMOS ENCONTRAR A SEVERINO
63A3: D7          rst  $10
	8B 08 -> [0x3cc8] = 0x08		; va a la puerta de la celda de severino
63A6: C9          ret

63A7: D7          rst  $10
	A2 1D -> [0x3f0e] = 0x1d		; frase = BERNARDO ABANDONARA HOY LA ABADIA
63AA: C3 CF 63    jp   $63CF

63AD: CF          rst  $08
		8D -> c1 = [0x2d80]
		06 -> c2 = 0x06
		3D -> c = [0x2d80] == 0x06
63B1: 20 06       jr   nz,$63B9		; si es el sexto día
63B3: D7          rst  $10
	A2 1E -> [0x3f0e] = 0x1e		; frase = MAÑANA ABANDONAREIS LA ABADIA
63B6: C3 CF 63    jp   $63CF

63B9: CF          rst  $08
		8D -> c1 = [0x2d80]
		07 -> c2 = 0x07
		3D -> c = [0x2d80] == 0x07
63BD: 20 0F       jr   nz,$63CE		; si es el séptimo día
63BF: D7          rst  $10
	A2 25 -> [0x3f0e] = 0x25		; frase = DEBEIS ABANDONAR YA LA ABADIA
63C2: CF          rst  $08
	88 -> c1 = [0x2d81]
	02 -> c2 = 0x02
	3D -> c = [0x2d81] == 0x02		; si es tercia
63C6: 20 03       jr   nz,$63CB
63C8: D7          rst  $10
	9C 01 -> [0x3c97] = 0x01		; indica que guillermo ha muerto
63CB: C3 CF 63    jp   $63CF

63CE: C9          ret


63CF: CF          rst  $08
		8C -> c1 = [0x3cc7]
		10 -> c2 = 0x10
		3D -> c = [0x3cc7] == 0x10
63D3: 20 03       jr   nz,$63D8		; si está en el estado 0x10
63D5: C3 E2 63    jp   $63E2

63D8: CF          rst  $08
	88 -> c1 = [0x2d81]
	02 -> c2 = 0x02
	3D -> c = [0x2d81] == 0x02
63DC: 20 03       jr   nz,$63E1		; si es tercia
63DE: C3 20 64    jp   $6420

63E1: C9          ret

63E2: CF          rst  $08
		90 -> c1a = [0x3ce9]
		40 FE -> c2a = 0xfe
		3D -> ca = [0x3ce9] == 0xfe
		86 -> c1b = [0x3caa]
		40 FE -> c2b = 0xfe
		3D -> cb = [0x3caa] == 0xfe
		2A -> ([0x3ce9] == 0xfe) || ([0x3caa] == 0xfe)
63EC: 20 18       jr   nz,$6406		; si malaquías o berengario/bernardo van a buscar el abad
63EE: CF          rst  $08
		8B -> c1 = [0x3cc8]
		8A -> c2 = [0x3cc6]
		3D -> c = [0x3cc8] == [0x3cc6]
63F2: 20 03       jr   nz,$63F7		; si el abad ha llegado a donde quería ir
63F4: C3 5B 3E    jp   $3E5B		; indica que el personaje no quiere buscar ninguna ruta

63F7: D7          rst  $10
		8B 02 -> [0x3cc8] = 0x02	; se va a su celda
63FA: CF          rst  $08
	A8 -> c1a = [0x2e0b]
	10 -> c2a = 0x10
	2A -> ca = [0x2e0b] & 0x10
	10 -> cb = 0x10
	3D -> c = ([0x2e0b] & 0x10) == 0x10
6400: 20 03       jr   nz,$6405		; si bernardo tiene el pergamino
6402: D7          rst  $10
	8B 03 -> [0x3cc8] = 0x03		; va a la entrada de la abadía
6405: C9          ret

6406: CF          rst  $08
		A6 -> c1a = [0x2e04]
		10 -> c2a = 0x10
		2A -> ca = [0x2e04] & 0x10
		10 -> cb = 0x10
		3D -> c = ([0x2e04] & 0x10) == 0x10
640C: 20 03       jr   nz,$6411		; si el abad tiene el pergamino
640E: D7          rst  $10
	8B 02 -> [0x3cc8] = 0x02		; va a su celda
6411: CF          rst  $08
	8A -> c1 = [0x3cc6]
	8B -> c2 = [0x3cc8]
	3D -> c = [0x3cc6] == [0x3cc8]
6415: 20 08       jr   nz,$641F		; si el abad ha llegado donde quería ir
6417: D7          rst  $10
		8B B2 03 2A 02 2B -> [0x3cc8] = ([0x3c9d] & 0x03) + 2	; se mueve aleatoriamente
641E: C9          ret
641F: C9          ret

6420: CF          rst  $08
		8C -> c1a = [0x3cc7]
		0E -> c2a = 0x0e
		3D -> c = [0x3cc7] == 0x0e
6424: 20 07       jr   nz,$642D		; si está en el estado 0x0e
6426: CD 26 50    call $5026		; pone en el marcador la frase
		14							VENID AQUI, FRAY GUILLERMO
642A: D7          rst  $10
		8C 11 -> [0x3cc7] = 0x11	; pasa al estado 0x11

642D: CF          rst  $08
		8C -> c1a = [0x3cc7]
		11 -> c2a = 0x11
		3D -> c = [0x3cc7] == 0x11	; si está en el estado 0x11
6431: 20 0C       jr   nz,$643F
6433: CF          rst  $08
		89 -> c1a = [0x2da1]
		00 -> c2a = 0x00
		3D -> c = [0x2da1] == 0x00
6437: 20 06       jr   nz,$643F		; si no está reproduciendo una frase
6439: D7          rst  $10
		8C 12 -> [0x3cc7] = 0x12	; pasa al estado 0x12
643C: D7          rst  $10
		99 00 -> [0x3c98] = 0x00	; inicia el contador
643F: CF          rst  $08
		8C -> c1a = [0x3cc7]
		12 -> c2a = 0x12
		3D -> c = [0x3cc7] == 0x12
6443: 20 0A       jr   nz,$644F		; si está en el estado 0x12
6445: D7          rst  $10
		8C 0F -> [0x3cc7] = 0x0f	; pasa al estado 0x0f
6448: D7          rst  $10
		8B 00 -> [0x3cc8] = 0x00	; va al altar de la iglesia
644B: CD 0B 3F    call $3F0B		; pone en el marcador la frase correspondiente
644E: C9          ret

644F: CF          rst  $08
		8C -> c1a = [0x3cc7]
		0F -> c2a = 0x0f
		3D -> c = [0x3cc7] == 0x0f
6453: 20 16       jr   nz,$646B		; si está en el estado 0x0f
6455: CF          rst  $08
		89 -> c1 = [0x2da1]
		00 -> c2 = 0x00
		3D -> c = [0x2da1] == 0x00
6459: 20 04       jr   nz,$645F		; si no está reproduciendo una voz
645B: D7          rst  $10
		8C 10 -> [0x3cc7] = 0x10	; pasa al estado 0x10
645E: C9          ret

645F: CD 61 3E    call $3E61		; compara la distancia entre guillermo y el abad (si está muy cerca devuelve 0, en otro caso != 0)
6462: 20 01       jr   nz,$6465		; si guillermo está cerca, sale
6464: C9          ret

6465: D7          rst  $10
		8C 12 -> [0x3cc7] = 0x12	; pasa al estado 0x12
6468: C3 6C 64    jp   $646C		; le echa una bronca a guillermo
646B: C9          ret

; le echa una bronca a guillermo
646C: CF          rst  $08
		8C -> c1a = [0x3cc7]
		40 80 -> c2a = 0x80
		3E -> c = [0x3cc7] >= 0x80
6471: 20 01       jr   nz,$6474		; si tiene el bit 7 puesto
6473: C9          ret

6474: CD CE 55    call $55CE		; decrementa la vida de guillermo en 2 unidades
6477: CD BE 08    call $08BE		; descarta los movimientos pensados e indica que hay que pensar un nuevo movimiento
647A: D7          rst  $10
		8C 8C 40 80 2B -> [0x3cc7] = [0x3cc7] + 0x80
6480: CD 1B 50    call $501B		; escribe en el marcador la frase
		08							OS ORDENO QUE VENGAIS
6484: C3 5B 3E    jp   $3E5B		; indica que el personaje no quiere buscar ninguna ruta


; llamado si está en misa (vísperas) y se le pasa en c el día que es
6487: CD 10 3F    call $3F10		; salta a una rutina dependiendo de lo que hay en c
		6498 -> día 1
		6498 -> día 2
		64A2 -> día 3
		6498 -> día 4
		64AA -> día 5
		64BC -> día 6
		0000

; llamado el día 1, 2 y 4
6498: D7          rst  $10
		A3 -> [0x3c96] = lo siguiente:
		91 -> c1a = [0x3ce7]	; a donde ha llegado berengario/bernardo
		97 -> c2a = [0x3d11]	; a donde ha llegado adso
		26 -> ca = c1a | c2a
		94 -> cb = [0x3cff]		; a donde ha llegado severino
		26 -> cc = ca | cb
		87 -> cd = [0x3ca8]		; a donde ha llegado malaquías
		26 -> c = cc | cd
64A1: C9          ret

; llamado el día 3
64A2: D7          rst  $10
		A3 -> [0x3c96] = lo siguiente:
		97 -> c1a = [0x3d11]	; a donde ha llegado adso
		94 -> c2a = [0x3cff]	; a donde ha llegado severino
		26 -> ca = c1a & c2a
		87 -> cb = [0x3ca8]		; a donde ha llegado malaquías
		26 -> c = ca & cb
64A9: C9          ret

; llamado el día 5
64AA: CF          rst  $08
		AC -> ca = [0x3ca2]
		01 -> cb = 0x01
		3E -> c = [0x3ca2] >= 0x01
64AE: 20 08       jp   nz,$64B8		; si malaquías está muriéndose

64B0: D7          rst  $10
		A2 40 20 -> [0x3f0e] = 0x20	; frase = MALAQUIAS HA MUERTO
64B4: D7          rst  $10
		A3 00 -> [0x3c96] = 0x00	; indica que ya están todos en su sitio
64B7: C9          ret

64B8: D7          rst  $10
		A3 01 -> [0x3c96] = 0x01	; indica que aún no están todos en su sitio
64BB: C9          ret


; llamado el día 6
64BC: D7          rst  $10
		A3 97 -> [0x3c96] = [0x3d11] ; si adso está en su sitio
64BF: C9          ret


; llamado si está en misa (prima) y se le pasa en c el día que es
64C0: CD 10 3F    call $3F10		; salta a una rutina dependiendo del día (en c)
		64D1 -> salta si el día es 2
		64D7 -> salta si el día es 3
		64DE -> salta si el día es 4
		6498 -> salta si el día es 5
		64BC -> salta si el día es 6
		64E4 -> salta si el día es 7
		0000

; llamado el día 2
64D1: D7          rst  $10
		A2 15 -> [0x3f0e] = 0x15	; frase = HERMANOS, VENACIO HA SIDO ASESINADO
64D4: C3 98 64    jp   $6498		; espera que estén berengario/bernardo, adso, severino y malaquías

; llamado el día 3
64D7: D7          rst  $10
		A2 18 -> [0x3f0e] = 0x18	; frase = HERMANOS, BERENGARIO HA DESAPARECIDO. TEMO QUE SE HAYA COMETIDO OTRO CRIMEN
64DB: C3 A2 64    jp   $64A2		; espera que estén adso, severino y malaquías

; llamado el día 4
64DE: D7          rst  $10
		A2 1A -> [0x3f0e] = 0x1a	; frase = HERMANOS, HAN ENCONTRADO A BERENGARIO ASESINADO
64E1: C3 A2 64    jp   $64A2		; espera que estén adso, severino y malaquías

; llamado el día 7
64E4: D7          rst  $10
		A2 17 -> [0x3f0e] = 0x17	; frase = OREMOS
64E7: C3 BC 64    jp   $64BC		; espera que esté adso

; llamado si está en el refectorio y se le pasa en c el día que es
64EA: CD 10 3F    call $3F10		; salta a una rutina dependiendo de c
		64FA -> día 2
		650C -> día 3
		650C -> día 4
		651A -> día 5
		651A -> día 6
		0000
64F9: C9          ret

64FA: CF          rst  $08
		91 -> c1a = [0x3ce7]
		01 -> c2a = 0x01
		3D -> ca = [0x3ce7] == 0x01	; si berengario ha llegado al comedor
		97 -> c1b = [0x3d11]
		01 -> c2b = 0x01			; si adso ha llegado al comedor
		3D -> cb = [0x3d11] == 0x01
		26 -> cc = ca & cb
		94 -> c1d = [0x3cff]
		01 -> c2d = 0x01
		3D -> cd = [0x3cff] == 0x01 ; si severino ha llegado al comedor
		26 -> c = cc & cd
6506: 20 03       jr   nz,$650B		; si berengario, severino y adso han llegado al comedor
6508: D7          rst  $10
		A3 00 -> [0x3c96] = 0x00	; indica que todos los monjes están listos
650B: C9          ret

650C: CF          rst  $08
		97 -> c1a = [0x3d11]
		01 -> c2a = 0x01
		3D -> ca = [0x3d11] == 0x01	; si adso ha llegado al comedor
		94 -> c1b = [0x3cff]
		01 -> c2b = 0x01
		3D -> cb = [0x3cff] == 0x01 ; si severino ha llegado al comedor
		26 -> c = ca & cb
6514: 20 03       jr   nz,$6519		; si adso y severino están listos para comer
6516: D7          rst  $10
		A3 00 -> [0x3c96] = 0x00	; lo indica
6519: C9          ret

651A: D7          rst  $10
		A3 97 01 3D -> [0x3c96] = [0x3d11] == 0x01	; si adso está listo
651F: C9          ret

; espera a que el abad, el resto de monjes y guillermo estén en su sitio y si es así avanza el momento del día
6520: CF          rst  $08
		8A -> c1 = [0x3cc6]
		8B -> c2 = [0x3cc8]
		3D -> c = [0x3cc6] == [0x3cc8]
6524: 20 73       jr   nz,$6599		; si el abad ha llegado a donde iba
6526: CF          rst  $08
		A3 -> c1 = [0x3c96]
		00 -> c2 = 0x00
		3D -> c = [0x3c96] == 0x00
652A: 20 6B       jr   nz,$6597		; si los monjes están listos para empezar la misa
652C: CF          rst  $08
		AF -> c1 = [0x3c9b]
		01 -> c2 = 0x01
		3E -> c = [0x3c9b] >= 0x01
6530: 20 52       jp   nz,$6584		; si guillermo por lo menos ha llegado a la habitación
6532: CF          rst  $08
		99 -> c1a = [0x3c98]
		32 -> c2a = 0x32
		3E -> c = [0x3c98] >= 0x32
6536: 20 0C       jp   nz,$6544		; si se ha superado el contador de puntualidad
6538: D7          rst  $10
		99 00 -> [0x3c98] = 0x00	; reinicia el contador
653B: CD 26 50    call $5026		; pone en el marcador la frase
		06 							LLEGAIS TARDE, FRAY GUILLERMO
653F: CD CE 55    call $55CE		; decrementa la vida de guillermo en 2 unidades
6542: 18 3F       jr   $6583

6544: CF          rst  $08
	89 -> c1 = [0x2da1]
	00 -> c2 = 0
	3D -> c = [0x2da1] == 0
6548: 20 22       jr   nz,$656C		; si no se está reproduciendo una voz
654A: CF          rst  $08
		AF -> c1 = [0x3c9b]
		02 -> c2 = 0x02
		3D -> c = [0x3c9b] == 0x02
654E: 20 16       jr   nz,$6566		; si guillermo no está en su sitio
6550: D7          rst  $10			; interpreta los comandos que siguen a esta instrucción
	99 99 01 -> [0x3c98] = [0x3c98] + 0x01
6555: CF          rst  $08
		99 -> c1 = [0x3c98]
		1E -> c2 = 0x1e
		3E -> c = c1 >= c2
6559: 20 0A       jr   nz,$6565		; si el contador pasa el límite
655B: D7          rst  $10
	99 00 -> [0x3c98] = 0x00		; pone el contador a 0
655E: CD 26 50    call $5026		; pone en el marcador la frase
		2D          				OCUPAD VUESTRO SITIO, FRAY GUILLERMO
6562: CD CE 55    call $55CE		; decrementa la vida de guillermo en 2 unidades
6565: C9          ret

6566: CD 0B 3F    call $3F0B		; pone en el marcador la frase que había guardado
6569: D7          rst  $10
		9B 01 -> [0x3c9a] = 0x01	; indica que hay que avanzar el momento del día
656C: CF          rst  $08
		9B -> c1a = [0x3c9a]
		01 -> c2a = 0x01
		3D -> ca = [0x3c9a] == 0x01
		AF -> c1b = [0x3c9b]
		02 -> c2b = 0x02
		3D -> cb = [0x3c9b] == 0x02
		26 -> c = ([0x3c9a] == 0x01) && ([0x3c9b] == 0x02)
6574: 20 0D       jr   nz,$6583		; si hay que avanzar el momento del día y guillermo no está en su sitio
6576: D7          rst  $10
		99 00 -> [0x3c98] = 0x00	; reinicia el contador
6579: D7          rst  $10
		9B 00 -> [0x3c9a] = 0		; indica que no hay que avanzar el momento del día
657C: CD 1B 50    call $501B		; escribe en el marcador la frase
		2D          				OCUPAD VUESTRO SITIO, FRAY GUILLERMO
6580: CD CE 55    call $55CE		; decrementa la vida de guillermo en 2 unidades
6583: C9          ret

; aquí se llega cuando guillermo todavía no ha llegado a la iglesia
6584: CF          rst  $08
		99 -> c1a = [0x3c98]
		40 C8 -> c2a = 0xc8
		3E -> c = [0x3c98] >= 0xc8
6589: 20 07       jr   nz,$6592		; si el contador supera el límite tolerable
658B: D7          rst  $10
		8C 0B -> [0x3cc7] = 0x0b	; cambia al estado de echarle
658E: D7          rst  $10
		9B 01 -> [0x3c9a] = 0x01	; avanza el momento del día
6591: C9          ret

6592: D7          rst  $10
		99 99 01 2B -> [0x3c98] = [0x3c98] + 0x01	; incrementa el contador
6597: 18 03       jr   $659c

6599: D7          rst  $10
		99 00 -> [0x3c98] = 0x00
659C: C9          ret
; ------------------ fin de la lógica del abad ----------------

; -------------------------------- código y datos relacionados con el pergamino --------------------------

; dibuja el pergamino
659D: DD E5       push ix
659F: CD 3A 3F    call $3F3A	; coloca la paleta negra
65A2: CD AF 65    call $65AF	; dibuja el pergamino
65A5: CD 3F 3F    call $3F3F	; coloca la paleta del pergamino
65A8: DD E1       pop  ix
65AA: FB          ei

65AB: CD 25 67    call $6725	; dibuja los textos en el manuscrito mientras no se pulse el espacio
65AE: C9          ret

; dibuja el pergamino
65AF: 21 00 C0    ld   hl,$C000	; apunta a memoria de video
65B2: E5          push hl
65B3: 54          ld   d,h		; de = hl + 1
65B4: 5D          ld   e,l
65B5: 13          inc  de
65B6: 36 00       ld   (hl),$00
65B8: 01 FF 3F    ld   bc,$3FFF	; limpia la memoria de video
65BB: ED B0       ldir
65BD: E1          pop  hl

; deja un rectángulo de 192 pixels de ancho en el medio de la pantalla, el resto limpio
65BE: 0E C8       ld   c,$C8	; c = 200, número de líneas a rellenar
65C0: 06 10       ld   b,$10	; b = 16, ancho de los rellenos
65C2: 3E F0       ld   a,$F0	; a = 240, valor con el que rellenar
65C4: E5          push hl
65C5: 11 40 00    ld   de,$0040	; de = 64, salto entre rellenos
65C8: EB          ex   de,hl	; de = apunta al relleno por la izquierda

65C9: 19          add  hl,de	; hl = apunta al relleno por la derecha
65CA: C5          push bc
65CB: 77          ld   (hl),a	; rellena por la derecha
65CC: ED A0       ldi			; rellena por la izquierda
65CE: C1          pop  bc
65CF: 10 F9       djnz $65CA	; completa 16 bytes (64 pixels)
65D1: E1          pop  hl
65D2: CD F2 68    call $68F2	; pasa a la siguiente línea de pantalla
65D5: 0D          dec  c		; repite para 200 lineas
65D6: 20 E8       jr   nz,$65C0

; limpia las 8 líneas de debajo de la pantalla
65D8: 21 80 C7    ld   hl,$C780	; apunta a una línea (la octava empezando por abajo)
65DB: 06 08       ld   b,$08	; repetir para 8 líneas
65DD: C5          push bc
65DE: E5          push hl
65DF: 5D          ld   e,l		; de = hl
65E0: 54          ld   d,h
65E1: 13          inc  de
65E2: 01 4F 00    ld   bc,$004F
65E5: ED B0       ldir			; copia lo que hay en la primera posición de la línea para el resto de pixels de la línea
65E7: E1          pop  hl
65E8: CD F2 68    call $68F2	; avanza hl 0x0800 bytes y si llega al final, pasa a la siguiente línea (+0x50)
65EB: C1          pop  bc
65EC: 10 EF       djnz $65DD	; repite para las demás líneas

65EE: 21 20 00    ld   hl,$0020	; hl = (00,32)
65F1: CD C7 68    call $68C7	; calcula el desplazamiento en pantalla
65F4: 11 8A 78    ld   de,$788A ; apunta a los datos del pergamino
65F7: CD 1B 66    call $661B	; dibuja la parte superior del pergamino
65FA: 21 DA 00    ld   hl,$00DA	; hl = (00,218)
65FD: CD C7 68    call $68C7	; calcula el desplazamiento en pantalla
6600: 11 0A 7A    ld   de,$7A0A	; rellena la parte derecha del pergamino
6603: CD 2E 66    call $662E
6606: 21 20 00    ld   hl,$0020	; hl = (00,32)
6609: CD C7 68    call $68C7	; calcula el desplazamiento en pantalla
660C: 11 8A 7B    ld   de,$7B8A
660F: CD 2E 66    call $662E	; rellena la parte izquierda del pergamino
6612: 21 20 B8    ld   hl,$B820	; hl = (184,32)
6615: CD C7 68    call $68C7	; calcula el desplazamiento en pantalla
6618: 11 0A 7D    ld   de,$7D0A

; rellena la parte superior (o inferior del pergamino)
661B: 0E 30       ld   c,$30		; 48 bytes (= 192 pixels a rellenar)
661D: 06 08       ld   b,$08		; 8 líneas de alto
661F: E5          push hl
6620: 1A          ld   a,(de)		; lee un byte y lo escribe a la pantalla
6621: 77          ld   (hl),a
6622: CD F2 68    call $68F2		; avanza a la siguiente línea
6625: 13          inc  de			; lee el siguiente byte gráfico
6626: 10 F8       djnz $6620		; rellena las 8 líneas
6628: E1          pop  hl
6629: 23          inc  hl			; pasa al siguiente pixel
662A: 0D          dec  c			; repite hasta rellenar el ancho del pergamino
662B: 20 F0       jr   nz,$661D
662D: C9          ret

; rellena 2 bytes (8 pixels) por cada línea
662E: 06 C0       ld   b,$C0		; b = 192 líneas
6630: 1A          ld   a,(de)		; lee 2 bytes y los escribe a la pantalla
6631: 77          ld   (hl),a
6632: 23          inc  hl
6633: 13          inc  de
6634: 1A          ld   a,(de)
6635: 77          ld   (hl),a
6636: 2B          dec  hl			; retrocede la posición a pintar hasta el inicio de la línea
6637: 13          inc  de
6638: CD F2 68    call $68F2		; avanza a la siguiente línea
663B: 10 F3       djnz $6630		; repite para el resto de líneas
663D: C9          ret

663E: E5          push hl
663F: C5          push bc
6640: 16 00       ld   d,$00
6642: 7D          ld   a,l
6643: C6 04       add  a,$04
6645: 6F          ld   l,a			; avanza la posición 4 pixels en x
6646: 3E 30       ld   a,$30
6648: 91          sub  c			; halla la parte del pergamino que falta por procesar
6649: 87          add  a,a
664A: 87          add  a,a			; pasa a pixels
664B: 5F          ld   e,a			; de = número de pixel después del triángulo en la parte superior del pergamino
664C: EB          ex   de,hl
664D: 29          add  hl,hl		; hl = desplazamiento en los datos del pergamino correspondientes a la parte borrada
664E: 01 8A 78    ld   bc,$788A		; bc apunta a los datos gráficos de la parte superior del pergamino
6651: 09          add  hl,bc
6652: EB          ex   de,hl		; guarda en de el puntero a los datos borrados de la parte superior del pergamino
6653: CD C7 68    call $68C7		; pasa la posición actual a dirección de VRAM
6656: E5          push hl			; guarda la posición actual en pila
6657: 06 08       ld   b,$08		; 8 líneas de alto
6659: 1A          ld   a,(de)		; lee un byte del pergamino y lo escribe en pantalla
665A: 77          ld   (hl),a
665B: CD F2 68    call $68F2		; avanza a la siguiente línea de pantalla
665E: 13          inc  de
665F: 10 F8       djnz $6659		; completa las 8 líneas

6661: E1          pop  hl			; recupera la posición actual y avanza 4 pixels en x
6662: 23          inc  hl
6663: 06 08       ld   b,$08		; copia los siguientes 4 pixels de otras 8 líneas
6665: 1A          ld   a,(de)
6666: 77          ld   (hl),a
6667: CD F2 68    call $68F2		; avanza a la siguiente línea de pantalla
666A: 13          inc  de
666B: 10 F8       djnz $6665

666D: C1          pop  bc
666E: C5          push bc
666F: 79          ld   a,c
6670: 3D          dec  a
6671: 3D          dec  a
6672: 3D          dec  a
6673: 87          add  a,a
6674: 87          add  a,a
6675: 67          ld   h,a
6676: 2E DA       ld   l,$DA		; x = pixel 248
6678: 5F          ld   e,a
6679: 16 00       ld   d,$00
667B: EB          ex   de,hl
667C: 29          add  hl,hl		; hl = desplazamiento a la parte borrada del borde de la derecha del pergamino
667D: 01 0A 7A    ld   bc,$7A0A		; apunta a datos gráficos de la parte derecha del pergamino
6680: 09          add  hl,bc
6681: EB          ex   de,hl
6682: CD C7 68    call $68C7		; pasa la posición actual a dirección de VRAM
6685: 06 08       ld   b,$08		; b = 8 líneas de alto
6687: 1A          ld   a,(de)		; copia 8 pixels
6688: 77          ld   (hl),a
6689: 23          inc  hl
668A: 13          inc  de
668B: 1A          ld   a,(de)
668C: 77          ld   (hl),a
668D: 2B          dec  hl
668E: 13          inc  de
668F: CD F2 68    call $68F2		; pasa a la siguiente línea de pantalla
6692: 10 F3       djnz $6687
6694: C1          pop  bc
6695: E1          pop  hl
6696: C9          ret

; pasa de hoja
6697: 06 2D       ld   b,$2D		; repite para 45 líneas
6699: 0E 03       ld   c,$03		; c = ancho inicial del triángulo (múltiplos de 4)
669B: 21 D3 00    ld   hl,$00D3		; (00, 240) -> posición de inicio
669E: C5          push bc
669F: E5          push hl
66A0: 41          ld   b,c
66A1: CD 06 69    call $6906		; dibuja un triángulo rectángulo de lado b
66A4: 01 D0 07    ld   bc,$07D0
66A7: CD C6 67    call $67C6		; pequeño retardo (20 ms)
66AA: E1          pop  hl			; recupera la posición original
66AB: C1          pop  bc
66AC: CD 3E 66    call $663E		; limpia la parte superior y derecha del borde del pergamino que ha sido borrada
66AF: 2D          dec  l			; x = x - 4
66B0: 2D          dec  l
66B1: 2D          dec  l
66B2: 2D          dec  l
66B3: 0C          inc  c			; incrementa el relleno
66B4: 10 E8       djnz $669E
66B6: CD 3E 66    call $663E		; limpia la parte superior y derecha del borde del pergamino que ha sido borrada

66B9: 06 2E       ld   b,$2E		; repite 46 veces
66BB: 0E 2F       ld   c,$2F		; c = ancho inicial para el triángulo (múltiplos de 4)
66BD: 21 20 04    ld   hl,$0420		; (04, 64) -> posición de inicio
66C0: C5          push bc
66C1: 41          ld   b,c
66C2: E5          push hl
66C3: CD 06 69    call $6906		; dibuja un triángulo rectángulo de lado b
66C6: 01 D0 07    ld   bc,$07D0
66C9: CD C6 67    call $67C6		; pequeño retardo (20 ms)
66CC: E1          pop  hl
66CD: E5          push hl
66CE: 7C          ld   a,h
66CF: D6 04       sub  $04
66D1: 67          ld   h,a			; y = y - 4
66D2: F5          push af
66D3: CD C7 68    call $68C7		; calcula el desplazamiento de las corrdenadas de hl en pantalla
66D6: F1          pop  af
66D7: 5F          ld   e,a
66D8: 16 00       ld   d,$00
66DA: EB          ex   de,hl
66DB: 29          add  hl,hl
66DC: 01 8A 7B    ld   bc,$7B8A
66DF: 09          add  hl,bc		; hl = desplazamiento de los datos borrados de la parte izquierda del pergamino
66E0: EB          ex   de,hl
66E1: 06 04       ld   b,$04		; 4 líneas de alto
66E3: 1A          ld   a,(de)		; copia 8 pixels
66E4: 77          ld   (hl),a
66E5: 13          inc  de
66E6: 23          inc  hl
66E7: 1A          ld   a,(de)
66E8: 77          ld   (hl),a
66E9: 13          inc  de
66EA: 2B          dec  hl
66EB: CD F2 68    call $68F2		; pasa a la siguiente línea de pantalla
66EE: 10 F3       djnz $66E3		; repite hasta completar 4 líneas
66F0: E1          pop  hl
66F1: C1          pop  bc
66F2: C5          push bc
66F3: E5          push hl
66F4: CD 05 67    call $6705		; restaura la parte inferior del pergamino modificada por lado c
66F7: E1          pop  hl
66F8: 7C          ld   a,h			; y = y + 4
66F9: C6 04       add  a,$04
66FB: 67          ld   h,a
66FC: C1          pop  bc
66FD: 0D          dec  c
66FE: 10 C0       djnz $66C0

6700: CD 05 67    call $6705	; restaura la parte inferior del pergamino modificada por lado c
6703: 0E 00       ld   c,$00

; restaura la parte inferior del pergamino modificada por lado c
6705: 79          ld   a,c
6706: 87          add  a,a
6707: 87          add  a,a
6708: 5F          ld   e,a			; e = a*4
6709: 16 00       ld   d,$00
670B: C6 20       add  a,$20
670D: 6F          ld   l,a
670E: 26 B8       ld   h,$B8		; y = 184
6710: CD C7 68    call $68C7		; calcula el desplazamiento de las corrdenadas de hl en pantalla
6713: EB          ex   de,hl
6714: 29          add  hl,hl
6715: 01 0A 7D    ld   bc,$7D0A		; hl = desplazamiento de los datos borrados de la parte inferior del pergamino
6718: 09          add  hl,bc
6719: EB          ex   de,hl
671A: 06 08       ld   b,$08
671C: 1A          ld   a,(de)
671D: 77          ld   (hl),a
671E: 13          inc  de
671F: CD F2 68    call $68F2		; pasa a la siguiente línea de pantalla
6722: 10 F8       djnz $671C
6724: C9          ret

6725: 2E 2C       ld   l,$2C		; l = 44
6727: 26 10       ld   h,$10		; h = 16
6729: 22 0A 68    ld   ($680A),hl	; guarda la posición actual
672C: DD E5       push ix
672E: CD BC 32    call $32BC		; lee el estado de las teclas
6731: FB          ei
6732: 3E 2F       ld   a,$2F		; comprueba si se pulsó el espacio
6734: CD 82 34    call $3482
6737: DD E1       pop  ix
6739: C0          ret  nz			; si se pulsó, sale

673A: DD 7E 00    ld   a,(ix+$00)	; lee el caracter a imprimir
673D: FE 1A       cp   $1A			; si ha encontrado el carácter de fin de pergamino, espera a que se pulse espacio para terminar
673F: 28 EB       jr   z,$672C
6741: DD 23       inc  ix			; apunta al siguiente carácter
6743: FE 0D       cp   $0D
6745: 20 08       jr   nz,$674F		; si no encuentra un carácter de salto de línea, salta
6747: 2A 0A 68    ld   hl,($680A)
674A: CD DE 67    call $67DE
674D: 18 DD       jr   $672C		; sigue procesando la cadena

674F: FE 20       cp   $20			; si no es un espacio, salta
6751: 20 07       jr   nz,$675A
6753: 3E 0A       ld   a,$0A
6755: CD CD 67    call $67CD		; espera un poco y avanza la posición en 10 pixels
6758: 18 D2       jr   $672C		; sigue procesando la cadena

675A: FE 0A       cp   $0A			; si no es el caracter 0x0a, salta
675C: 20 05       jr   nz,$6763
675E: CD F0 67    call $67F0		; espera un rato y pása la página
6761: 18 C9       jr   $672C		; sigue procesando la cadena

6763: 4F          ld   c,a			; guarda una copia del caracter
6764: E6 60       and  $60			; comprueba si es mayúsculas o minúsculas
6766: FE 40       cp   $40
6768: 3E FF       ld   a,$FF
676A: 28 02       jr   z,$676E
676C: 3E 0F       ld   a,$0F
676E: 32 C0 67    ld   ($67C0),a	; rellena un parámetro dependiendo de si es una letra mayúscula o minúscula
6771: 79          ld   a,c			; obtiene el caracter
6772: 21 0C 68    ld   hl,$680C		; apunta a la tabla que indica cómo se forman los caracteres
6775: D6 20       sub  $20			; solo tiene caracteres a partir de 0x20
6777: 87          add  a,a			; cada entrada ocupa 2 bytes
6778: CD 2D 16    call $162D		; hl = hl + a
677B: 5E          ld   e,(hl)		; obtiene un puntero en de
677C: 23          inc  hl
677D: 56          ld   d,(hl)
677E: D5          push de
677F: FD E1       pop  iy			; IY apunta al caracter

6781: 01 20 03    ld   bc,$0320		; pequeño retardo (aprox. 8 ms)
6784: CD C6 67    call $67C6
6787: FD 7E 00    ld   a,(iy+$00)	; obtiene un byte del caracter
678A: FD 23       inc  iy
678C: 4F          ld   c,a			; guarda una copia del caracter
678D: E6 F0       and  $F0
678F: FE F0       cp   $F0
6791: 20 08       jr   nz,$679B		; si no es el último byte del carácter, salta
6793: 79          ld   a,c
6794: E6 0F       and  $0F
6796: CD CD 67    call $67CD		; imprime un espacio y sale al bucle para imprimir más caracteres
6799: 18 91       jr   $672C

679B: 79          ld   a,c			; obtiene el caracter
679C: E6 0F       and  $0F
679E: 2A 0A 68    ld   hl,($680A)	; avanza la posición x según los 4 bits menos significativos del byte leido de dibujo del caracter
67A1: 85          add  a,l
67A2: 6F          ld   l,a
67A3: F5          push af
67A4: 79          ld   a,c
67A5: 07          rlca
67A6: 07          rlca
67A7: 07          rlca
67A8: 07          rlca
67A9: E6 0F       and  $0F
67AB: 84          add  a,h			; avanza la posición y según los 4 bits más significativos del byte leido de dibujo del caracter
67AC: 67          ld   h,a
67AD: CD C7 68    call $68C7		; pasa los pixels a dirección de VRAM
67B0: F1          pop  af
67B1: E6 03       and  $03			; se queda con los 2 bits menos significativos de la posición para saber que pixel pintar
67B3: 47          ld   b,a
67B4: 3E 88       ld   a,$88		; calcula la máscara para el pixel correspondiente
67B6: 28 03       jr   z,$67BB
67B8: 0F          rrca
67B9: 10 FD       djnz $67B8

67BB: 4F          ld   c,a			; guarda la máscara calculada
67BC: 2F          cpl
67BD: A6          and  (hl)			; obtiene el valor del resto de pixels de la pantalla
67BE: 47          ld   b,a
67BF: 3E 00       ld   a,$00		; a se llena desde fuera. a = 0xff si es una mayúscula, o 0x0f si es una minúscula, para pintar en rojo o en negro
67C1: A1          and  c			; activa el pixel pintar
67C2: B0          or   b			; combina con los pixels de pantalla
67C3: 77          ld   (hl),a		; actualiza la memoria de video con el nuevo pixel
67C4: 18 BB       jr   $6781		; repite para el resto de valores de la letra

67C6: 00          nop				; retardo hasta que bc = 0x0000. Cada iteración son 32 ciclos (aprox 10 microsegundos, puesto
67C7: 0B          dec  bc			;  que aunque el Z80 funciona a 4 MHz, la arquitectura del CPC tiene una sincronización para los
67C8: 78          ld   a,b			;  el video que hace que funcione de forma efectiva entorno a los 3.2 MHz)
67C9: B1          or   c
67CA: 20 FA       jr   nz,$67C6
67CC: C9          ret

; aquí salta para imprimir un espacio
67CD: F5          push af
67CE: 01 B8 0B    ld   bc,$0BB8		; espera un poco (aprox. 30 ms)
67D1: CD C6 67    call $67C6
67D4: F1          pop  af
67D5: 2A 0A 68    ld   hl,($680A)	; obtiene la posición actual
67D8: 85          add  a,l
67D9: 6F          ld   l,a
67DA: 22 0A 68    ld   ($680A),hl	; incrementa la posición actual
67DD: C9          ret

; aquí salta para imprimir un retorno de carro
67DE: 01 60 EA    ld   bc,$EA60		; espera un rato (aprox. 600 ms)
67E1: CD C6 67    call $67C6
67E4: 3E 10       ld   a,$10		; calcula la posición de la siguiente línea
67E6: 2E 2C       ld   l,$2C
67E8: 84          add  a,h
67E9: 67          ld   h,a
67EA: 22 0A 68    ld   ($680A),hl
67ED: FE A4       cp   $A4			; se ha llegado a fin de hoja?
67EF: D8          ret  c

; llamado cuando hay que pasar de página
67F0: 21 2C 10    ld   hl,$102C
67F3: 22 0A 68    ld   ($680A),hl	; reinicia la posición al principio de la línea
67F6: 06 03       ld   b,$03
67F8: C5          push bc
67F9: 01 00 00    ld   bc,$0000		; (aprox. 655 ms)
67FC: CD C6 67    call $67C6		; retardo
67FF: C1          pop  bc
6800: 10 F6       djnz $67F8		; repite 3 veces los retardos
6802: DD E5       push ix
6804: CD 97 66    call $6697		; pasa de hoja
6807: DD E1       pop  ix
6809: C9          ret

680A: posición actual en el pergamino (y,x en pixels)

; tabla de punteros a los datos de los caracteres del pergamino (los que apuntan a 0x0000 es que no están definidos)
680C: 0000 ; caracter 0x20: ' '
680E: 0000 ; caracter 0x21: '!'
6810: 0000 ; caracter 0x22: '"'
6812: 0000 ; caracter 0x23: '#'
6814: 0000 ; caracter 0x24: '$'
6816: 0000 ; caracter 0x25: '%'
6818: 0000 ; caracter 0x26: '&'
681A: 0000 ; caracter 0x27: '''
681C: 0000 ; caracter 0x28: '('
681E: 0000 ; caracter 0x29: ')'
6820: 0000 ; caracter 0x2a: '*'
6822: 0000 ; caracter 0x2b: '+'
6824: 6947 ; caracter 0x2c: ','
6826: 694E ; caracter 0x2d: '-'
6828: 695F ; caracter 0x2e: '.'
682A: 0000 ; caracter 0x2f: '/'
682C: 0000 ; caracter 0x30: '0'
682E: 6964 ; caracter 0x31: '1'
6830: 697A ; caracter 0x32: '2'
6832: 699E ; caracter 0x33: '3'
6834: 0000 ; caracter 0x34: '4'
6836: 0000 ; caracter 0x35: '5'
6838: 0000 ; caracter 0x36: '6'
683A: 69BE ; caracter 0x37: '7'
683C: 0000 ; caracter 0x38: '8'
683E: 0000 ; caracter 0x39: '9'
6840: 69D9 ; caracter 0x3a: ':'
6842: 69E2 ; caracter 0x3b: ';'
6844: 0000 ; caracter 0x3c: '<'
6846: 0000 ; caracter 0x3d: '='
6848: 0000 ; caracter 0x3e: '>'
684A: 0000 ; caracter 0x3f: '?'
684C: 0000 ; caracter 0x40: '@'
684E: 6A28 ; caracter 0x41: 'A'
6850: 0000 ; caracter 0x42: 'B'
6852: 6A78 ; caracter 0x43: 'C'
6854: 6AD6 ; caracter 0x44: 'D'
6856: 6B3D ; caracter 0x45: 'E'
6858: 0000 ; caracter 0x46: 'F'
685A: 6B88 ; caracter 0x47: 'G'
685C: 6BF7 ; caracter 0x48: 'H'
685E: 0000 ; caracter 0x49: 'I'
6860: 6C4D ; caracter 0x4a: 'J'
6862: 0000 ; caracter 0x4b: 'K'
6864: 6C8B ; caracter 0x4c: 'L'
6866: 6CCD ; caracter 0x4d: 'M'
6868: 0000 ; caracter 0x4e: 'N'
686A: 6D3D ; caracter 0x4f: 'O'
686C: 6DA8 ; caracter 0x50: 'P'
686E: 0000 ; caracter 0x51: 'Q'
6870: 0000 ; caracter 0x52: 'R'
6872: 6E0C ; caracter 0x53: 'S'
6874: 6E6C ; caracter 0x54: 'T'
6876: 0000 ; caracter 0x55: 'U'
6878: 0000 ; caracter 0x56: 'V'
687A: 0000 ; caracter 0x57: 'W'
687C: 0000 ; caracter 0x58: 'X'
687E: 6EAF ; caracter 0x59: 'Y'
6880: 0000 ; caracter 0x5a: 'Z'
6882: 0000 ; caracter 0x5b: '['
6884: 0000 ; caracter 0x5c: '\'
6886: 0000 ; caracter 0x5d: ']'
6888: 0000 ; caracter 0x5e: '^'
688A: 0000 ; caracter 0x5f: '_'
688C: 0000 ; caracter 0x60: '`'
688E: 6F0F ; caracter 0x61: 'a'
6890: 6F37 ; caracter 0x62: 'b'
6892: 6F66 ; caracter 0x63: 'c'
6894: 6F84 ; caracter 0x64: 'd'
6896: 6FB3 ; caracter 0x65: 'e'
6898: 6FD3 ; caracter 0x66: 'f
689A: 6FF7 ; caracter 0x67: 'g'
689C: 7026 ; caracter 0x68: 'h'
689E: 7055 ; caracter 0x69: 'i'
68A0: 706C ; caracter 0x6a: 'j'
68A2: 708A ; caracter 0x6b: 'q'
68A4: 70AE ; caracter 0x6c: 'l'
68A6: 70C9 ; caracter 0x6d: 'm'
68A8: 7103 ; caracter 0x6e: 'n'
68AA: 7129 ; caracter 0x6f: 'o'
68AC: 714E ; caracter 0x70: 'p'
68AE: 7179 ; caracter 0x71: 'q'
68B0: 71A7 ; caracter 0x72: 'r'
68B2: 71C3 ; caracter 0x73: 's'
68B4: 71DF ; caracter 0x74: 't'
68B6: 7203 ; caracter 0x75: 'u'
68B8: 7229 ; caracter 0x76: 'v'
68BA: 724D ; caracter 0x77: 'w'
68BC: 727B ; caracter 0x78: 'x'
68BE: 7298 ; caracter 0x79: 'y'
68C0: 72C2 ; caracter 0x7a: 'z'
68C2: 0000 ; caracter 0x7b: '{'
68C4: 0000 ; caracter 0x7c: '|'

68C6: 00

; dado hl (coordenadas en pixels), calcula el desplazamiento correspondiente en pantalla
; el valor calculado se hace partiendo de la coordenada x multiplo de 4 más cercana y sumandole 32 pixels a la derecha
; l = coordenada X (en pixels)
; h = coordenada Y (en pixels)
68C7: D5          push de
68C8: CB 3D       srl  l
68CA: CB 3D       srl  l
68CC: 7D          ld   a,l			; a = l / 4 (cada 4 pixels = 1 byte)
68CD: 08          ex   af,af'
68CE: F5          push af
68CF: 7C          ld   a,h
68D0: E6 F8       and  $F8			; obtiene el valor para calcular el desplazamiento dentro del banco de VRAM
68D2: 6F          ld   l,a
68D3: 7C          ld   a,h
68D4: 26 00       ld   h,$00
68D6: 29          add  hl,hl		; dentro de cada banco, la línea a la que se quiera ir puede calcularse como (y & 0xf8)*10
68D7: 54          ld   d,h			;  o lo que es lo mismo, (y >> 3)*0x50
68D8: 5D          ld   e,l
68D9: 29          add  hl,hl
68DA: 29          add  hl,hl
68DB: 19          add  hl,de		; hl = desplazamiento dentro del banco
68DC: E6 07       and  $07			; a = 3 bits menos significativos en y (para calcular al banco de VRAM al que va)
68DE: 87          add  a,a
68DF: 87          add  a,a
68E0: 87          add  a,a			; ajusta los 3 bits
68E1: B4          or   h			; completa el cálculo del banco
68E2: F6 C0       or   $C0			; ajusta para que esté dentro de 0xc000-0xffff
68E4: 67          ld   h,a
68E5: F1          pop  af
68E6: 08          ex   af,af'
68E7: 85          add  a,l			; suma el desplazamiento en x
68E8: 6F          ld   l,a
68E9: 8C          adc  a,h
68EA: 95          sub  l
68EB: 67          ld   h,a
68EC: 11 08 00    ld   de,$0008		; ajusta para que salga 32 pixels más a la derecha
68EF: 19          add  hl,de
68F0: D1          pop  de
68F1: C9          ret

; avanza a la siguiente línea
68F2: 7C          ld   a,h		; avanza hl 0x0800 bytes (pasa a la siguiente línea)
68F3: C6 08       add  a,$08
68F5: 38 02       jr   c,$68F9	; si se pasa de 0xffff, salta
68F7: 67          ld   h,a
68F8: C9          ret
68F9: 7C          ld   a,h
68FA: E6 C7       and  $C7		; ajusta para que el mínimo sea a 0xc000
68FC: 67          ld   h,a
68FD: 3E 50       ld   a,$50	; so hubo acarreo, pasa a la siguiente linea
68FF: 85          add  a,l
6900: 6F          ld   l,a
6901: D0          ret  nc
6902: 8C          adc  a,h
6903: 95          sub  l
6904: 67          ld   h,a
6905: C9          ret

; dibuja un triángulo rectángulo con los catetos paralelos a los ejes de coordenadas y de longitud b
6906: CD C7 68    call $68C7			; calcula el desplazamiento de las corrdenadas de hl en pantalla
6909: 16 00       ld   d,$00			; contador para el bucle exterior

690B: 0E 04       ld   c,$04			; 4 líneas que procesar por iteración

690D: C5          push bc
690E: E5          push hl
690F: 79          ld   a,c
6910: 3D          dec  a
6911: E5          push hl
6912: 21 43 69    ld   hl,$6943			; apunta al patrón de relleno
6915: CD 2D 16    call $162D			; hl = hl + a
6918: 7E          ld   a,(hl)			; lee el byte a escribir
6919: E1          pop  hl				; recupera las coordenadas de pantalla
691A: 1E 00       ld   e,$00			; inicia ???
691C: 32 32 69    ld   ($6932),a		; modifica el parámetro del código con el byte leido

691F: 7A          ld   a,d
6920: BB          cp   e				; si se ha llegado al contador del bucle exterior, salta
6921: 28 0E       jr   z,$6931
6923: 36 F0       ld   (hl),$F0			; escribe 4 pixels a pantalla
6925: 05          dec  b				; repite para el tamaño del triángulo
6926: 20 05       jr   nz,$692D			; si b no es 0, salta
6928: 1C          inc  e				; incrementa el contador del bucle interior
6929: 23          inc  hl				; avanza 4 pixels
692A: 04          inc  b
692B: 18 F2       jr   $691F

692D: 04          inc  b
692E: CD 2D 16    call $162D			; hl = hl + a

6931: 36 00       ld   (hl),$00			; escribe a pantalla (rellena el parámetro desde fuera con el valor que se va a escribir a pantalla)
6933: 23          inc  hl
6934: 36 00       ld   (hl),$00			; limpia restos de una ejecución anterior
6936: E1          pop  hl				; recupera las coordenadas originales de pantalla
6937: CD F2 68    call $68F2			; pasa a la siguiente línea de pantalla
693A: C1          pop  bc
693B: 0D          dec  c				; completa las 4 líneas
693C: 20 CF       jr   nz,$690D
693E: 1C          inc  e				; incrementa el tamaño del área a procesar
693F: 14          inc  d
6940: 10 C9       djnz $690B			; repite b veces
6942: C9          ret

; relleno triangular
6943: F0 E0 C0 80

; datos de los caracteres del pergamino
6947: A2 A3 B2 B3 C3 D2 F4 -> caracter ','
694E: 70 80 91 81 82 92 93 83 73 74 84 75 85 86 86 97 F8  -> caracter '-'
695F: A2 A3 B2 B3 F4 -> caracter '.'
6964: 60 51 42 33 43 53 52 63 62 73 72 83 82 93 92 A3 A2 B3 B2 C3 B4 F5 -> caracter '1'
697A: 60 50 41 32 33 34 35 44 45 46 56 55 65 64 74 73 83 82 92 91 A1 A0 B0 C0 B1 B2 B3 C3 B4 C4 B5 A6 B5 A6 97 F8 -> caracter '2'
699E: 50 41 32 33 34 43 44 45 46 37 46 55 64 73 72 73 74 85 96 95 A6 A5 B5 C4 C3 B3 C2 B2 B1 A0 90 F8 -> caracter '3'
69BE: 50 41 32 33 34 43 44 45 46 37 46 55 64 73 82 83 92 93 A2 A3 B2 B3 C3 B4 81 84 F8 -> caracter '7'
69D9: 72 73 82 83 A2 A3 B2 B3 F4 -> caracter ':'
69E2: 72 73 82 83 A2 A3 B2 B3 C3 D2 F4 -> caracter ';'
69ED: 50 41 52 51 62 61 72 71 82 81 92 91 A2 A1 B2 B1 C1 C0 D0 63 54 45 56 55 66 65 76 75 86 85 96 95 A6 A5 B6 B5 C5 C4 D4 67 58 49 5A 59
	6A 69 7A 79 8A 89 9A 99 AA A9 BA B9 C9 C8 F0 -> este caracter no está en la tabla y es una 'm' un poco distinta de la 'm' que muestra
6A28: 22 13 04 05 06 15 14 25 16 17 27 26 35 36 37 38 47 48 57 58 59 68 79 69 78 7A 8A 89 99 9A 9B AA AB BA BB BC CB DB CC DD DC 60 51 42
	43 44 54 53 52 63 64 73 82 92 A1 B1 C0 D0 C1 D1 D2 C2 D3 C4 83 93 84 94 85 95 86 96 87 97 88 98 65 66 67 FE -> caracter 'A'
6A78: 03 12 21 22 32 31 40 41 42 52 51 50 60 61 62 72 71 70 80 81 82 83 93 92 91 90 A1 A2 B1 C2 B2 A3 B3 C3 D4 C4 B4 A4 A5 B5 C5 D5 D6 C6
	B6 B7 C7 D7 D8 C8 B8 B9 C9 D9 CA BA BB CB BC AD 24 25 26 16 17 07 08 18 19 09 1A 1B 0C 35 36 45 46 55 56 66 65 75 76 85 28 38 48 58 68
	78 88 98 A8 FE -> caracter 'C'
6AD6: 00 10 11 21 12 22 13 23 33 34 24 14 15 25 35 36 26 16 17 27 37 38 28 18 19 29 39 49 4A 3A 2A 2B 3B 3C 4C 4B 5A 5B 5C 6C 6B 6A 7A 7B
	7C 8C 8B 8A 9A 9B 9C AC AB AA BB BA C9 D8 C8 C7 D7 D6 C6 B6 B5 C5 C4 B4 B3 C3 C2 B2 C1 D0 42 52 53 63 62 72 73 83 82 93 92 A3 A5 95 85
	75 65 55 45 66 67 68 69 89 88 87 86 71 FE -> caracter 'D'
6B3D: 20 11 02 03 04 13 14 15 24 34 33 43 42 52 53 63 62 73 72 83 82 92 A2 B1 C0 A4 95 86 85 76 75 66 65 56 55 46 45 36 27 18 09 0A 19 1A
	1B 2B 2A 3A D2 C3 C4 B4 B5 C5 B6 C6 B7 C7 D7 C8 B9 BA AB 60 71 74 77 67 68 58 59 69 6A 5B FE -> caracter 'E'
6B88: 80 91 92 93 83 84 85 76 77 68 78 69 79 7A 6A 6B 6C 7B 8A 8B 9A 9B AA AB BA BB CA CB DA DB EA EB DC C9 D8 D7 E7 E6 D6 E5 D5 C5 D4 E4
	D3 C4 C3 C2 C1 B2 B3 B4 A4 A3 A2 92 93 94 83 82 72 73 74 64 63 62 52 53 54 44 43 42 32 33 34 10 21 22 23 24 15 16 07 17 08 18 09 19 28
	29 1A 2A 39 3A 2B 1C 26 36 46 56 66 76 86 96 A6 B6 C6 D6 D8 C8 FE -> caracter 'G'
6BF7: 00 11 12 13 04 05 06 07 16 15 14 24 25 26 36 35 34 44 45 46 56 55 54 64 65 66 76 75 74 84 85 86 96 95 94 A4 A5 A6 B5 C4 B4 C3 B3 B2
	A2 A1 B0 22 23 32 42 52 62 72 82 92 97 88 79 6A 5A 4A 3A 57 48 39 49 4A 3B 5A 59 69 6A 7A 89 8A 99 9A A9 AA B9 CA BA BB AC FE -> caracter 'H'
6C4D: 3A 2B 2A 1B 1A 0A 09 19 18 27 36 47 37 46 57 56 67 66 77 76 87 86 97 96 A7 A6 B6 C5 D4 D3 C3 D2 C2 C1 B1 B0 A0 A1 B2 A1 91 90 80 81
	71 62 B4 A4 94 84 74 64 54 44 34 25 16 07 55 85 51 FC -> caracter 'J'
6C8B: 10 01 02 03 14 13 23 22 32 33 44 45 46 47 48 39 2A 29 1A 19 09 08 18 17 26 36 35 54 55 56 66 65 64 74 75 76 86 85 84 94 95 96 A5 A4
	B3 C2 B4 B5 B6 C6 B7 C7 B8 C8 B9 C9 BA BB AC A8 98 88 78 68 58 FE -> caracter 'L'
6CCD: B0 B1 A2 A1 92 91 82 81 72 71 62 61 52 51 42 41 31 32 21 20 21 22 13 04 05 14 24 34 44 54 64 74 84 94 A4 B4 C3 D2 D1 D0 15 16 25 26
	27 36 37 46 47 56 57 66 67 76 77 86 87 96 97 A6 A7 B7 B6 C6 D6 D5 C7 D6 18 09 0A 1A 19 29 39 49 59 69 79 89 99 A9 B9 C9 1B 2A 2B 2C 3B
	3C 4B 4C 5B 5C 6B 6C 7B 7C 8B 8C 9B 9C AB AC BC BB CB DA 6A 65 64 FE -> caracter 'M'
6D3D: 12 22 21 32 31 30 40 41 42 52 51 50 60 61 62 72 71 70 80 81 82 92 91 90 A1 A2 B2 B3 C3 C4 B4 C5 D6 C6 C7 B7 B8 B9 A8 A9 AA AB 9B 9A
	99 98 88 89 8A 8B 7B 7A 79 78 68 69 6A 6B 5B 5A 59 58 48 48 49 4A 4B 3B 3A 39 38 29 28 18 27 17 07 06 16 26 15 05 04 14 13 03 13 36
	35 45 46 56 55 56 66 65 75 76 86 85 95 96 A5 A4 57 87 FC -> caracter 'O'
6DA8: 03 04 14 13 12 22 23 24 34 33 32 42 43 44 54 53 52 62 63 64 74 73 72 82 83 84 94 93 92 A2 A3 A4 B4 B3 B2 C2 C3 C4 D3 D2 D1 C0 10 21
	25 16 26 27 17 07 08 18 09 19 1A 1B 1C 0D 2B 2A 29 39 3A 3B 4B 4A 49 59 5A 5B 6B 6A 69 79 7A 7B 89 78 88 98 97 87 77 76 86 75 65 61 70
	37 47 57 67 77 A7 B7 C7 D6 48 FE -> caracter 'P'
6E0C: D0 C1 B2 C2 B3 C3 B4 C4 B5 C5 D6 C6 C7 D7 D8 C8 D9 C9 CA BA BB AC AB AA 9A 9B 9C 9D 8C 8B 8A 7B 7A 69 79 78 68 67 77 76 66 65 75 64
	74 73 63 62 51 52 53 42 43 33 24 25 15 06 16 26 27 17 07 08 18 28 38 49 39 29 19 1A 2A 3A 2B 1C 0D 58 85 94 A3 60 70 71 81 82 92
	93 94 95 96 97 98 A9 B9 FE -> caracter 'S'
6E6C: 20 11 02 12 03 13 04 14 05 15 25 26 16 06 07 17 27 28 18 08 19 29 1A 2A 2B 1B 1C 0D 34 43 44 53 54 63 64 73 74 83 84 93 94 A3 A4 B3
	B4 C4 B5 C5 D5 D6 C6 C7 D7 C8 B8 B9 A9 9A A7 97 87 77 67 57 47 37 FE -> caracter 'T'
6EAF: 20 11 02 03 14 13 12 22 23 24 34 33 32 42 43 44 54 53 52 62 63 64 74 75 76 77 78 79 68 69 6A 5A 59 58 48 49 4A 3A 39 38 28 29 2A 1B
	2A 19 18 08 07 16 27 26 36 47 46 56 66 76 86 85 94 93 A2 A3 A4 B4 B3 B2 C2 C3 C4 D4 D5 C5 C6 B7 A8 99 9A AB AA BB BA CB CA D9 C8 B7 A6
	95 94 93 82 81 90 FE -> caracter 'Y'
6F0F: 40 41 51 52 43 44 54 55 46 65 64 75 74 84 85 95 94 A4 A5 B4 B5 B6 C5 B4 C3 C2 C1 B2 B1 B0 A1 A0 91 90 81 80 71 72 83 F8 -> caracter 'a'
6F37: 01 10 11 12 21 22 32 31 41 42 52 51 61 62 72 71 81 82 92 91 A2 A1 B0 B1 B2 B3 C2 C3 C4 B5 B6 A5 A6 95 96 85 86 75 76 65 66 55 56 45
	44 53 F8 -> caracter 'b'
6F66: B6 B5 C4 C3 C2 B3 B2 B1 B0 A1 A2 92 91 82 81 72 71 62 61 52 51 43 44 45 54 55 56 66 65 F8 -> caracter 'c'
6F84: 50 51 60 61 70 71 80 90 81 91 A0 A1 B0 B1 B2 C1 C2 C3 B4 B5 B6 A5 A4 95 94 85 84 75 74 65 64 55 54 53 44 43 42 33 32 31 22 21 20 11 10 00 F7 -> caracter 'd'
6FB3: A6 B5 C4 C3 C2 B3 B2 B1 B0 A1 A2 91 92 81 82 71 72 61 62 51 52 43 44 45 54 55 56 66 65 74 83 F8 -> caracter 'e'
6FD3: C2 B3 B2 B1 A2 A1 92 91 82 81 72 71 62 61 52 51 42 41 42 31 32 21 22 11 12 03 04 14 15 16 40 41 42 43 44 F7 -> caracter 'f'
6FF7: B3 B2 B1 A2 A1 A0 A0 A0 91 90 81 80 71 70 61 60 50 51 42 43 44 53 54 55 64 56 65 74 75 84 85 94 95 A4 A5 B4 B5 C5 C4 D5 D4 E3 E2 D2
	D1 D0 F7 -> caracter 'g'
7026: 03 02 11 10 10 21 20 31 30 41 40 51 50 61 60 71 70 81 80 91 90 A1 A0 B0 B1 C1 B2 62 53 44 55 54 65 64 75 74 85 84 95 94 A4 A5 B4 B5
	C5 B6 F7 -> caracter 'h'
7055: 50 41 52 51 61 62 72 71 81 82 92 91 A1 A2 B2 B1 C2 B3 21 11 21 22 F5 -> caracter 'i'
706C: 44 53 54 55 64 65 75 74 84 85 95 94 A4 A5 B5 B4 C4 C5 D5 D4 E4 E3 E2 D2 D1 24 14 14 25 F8 -> caracter 'j'
708A: 40 41 42 51 52 61 62 71 72 81 82 91 92 A1 A2 B2 B1 C0 C1 C2 57 56 65 64 74 83 94 95 A5 A6 B5 B6 C6 C7 B8 F9 -> caracter 'q'
70AE: 00 11 22 21 32 31 42 41 52 51 62 61 72 71 82 81 92 91 A2 A1 B0 B1 B2 C2 C3 B4 F5 -> caracter 'l'
70C9: 50 41 52 51 61 62 72 71 81 82 92 91 A1 A2 B2 B1 C2 B3 63 54 45 55 56 66 65 75 76 86 85 95 96 A6 A5 B5 B6 C6 B7 67 58 49 5A 59 69 6A
 	7A 79 89 8A 9A 99 A9 AA BA B9 CA BB BB FC -> caracter 'm'
7103: 50 41 52 51 61 62 72 71 81 82 92 91 A1 A2 B2 B1 C2 B3 63 54 45 55 56 66 65 75 76 86 85 95 96 A6 A5 B5 B6 C6 B7 F8 -> caracter 'n'
7129: 42 43 44 53 54 55 64 65 74 75 84 85 94 95 A5 A4 B5 B4 C3 C2 C1 B2 B1 B0 A1 A0 91 90 81 80 71 70 61 60 51 50 F7 -> caracter 'o'
714E: B3 A3 B4 A5 A6 95 96 85 86 75 76 65 54 55 66 56 45 44 43 52 41 40 51 62 61 72 71 82 81 92 91 A2 A1 B2 B1 C2 C1 D2 D1 E2 E1 E0 F8 -> caracter 'p'
7179: B3 B2 B1 A2 A1 A0 91 90 81 80 71 70 61 60 50 51 42 43 44 53 54 55 56 65 64 75 74 85 84 95 94 A5 A4 B5 B4 C5 C4 D5 D4 E5 E4 E3 E4 E5
	E6 F7 -> caracter 'q'
71A7: B4 C3 C2 B1 B0 B2 A1 A2 91 92 81 82 71 72 61 62 51 40 41 52 43 44 45 54 55 56 65 F8 -> caracter 'r'
71C3: 47 56 55 54 44 43 52 51 61 62 72 73 74 85 86 96 95 A6 A5 B6 B5 C4 C3 B3 B2 B1 C0 F8 -> caracter 's'
71DF: 01 12 23 22 33 32 43 42 53 52 53 62 63 72 73 82 83 92 93 A2 A3 B2 B3 B1 B2 B3 C3 C4 B5 60 51 52 53 54 45 F6 -> caracter 't'
7203: 50 41 52 51 61 62 72 71 81 82 92 91 A1 A2 B2 B1 C2 C3 B4 54 45 56 55 65 66 76 75 85 86 96 95 A5 A6 B6 B5 C6 B7 F8 -> caracter 'u'
7229: 50 41 52 51 61 62 72 71 81 82 92 91 A1 A2 B2 B1 C2 C3 55 56 46 57 66 65 75 76 86 85 95 96 A5 A6 B5 B4 C4 F8-> caracter 'v'
724D: 50 41 52 51 61 62 72 71 81 82 92 91 A1 A2 B2 B1 C2 B3 63 54 45 55 56 66 65 75 76 86 85 95 96 A6 A5 B5 B6 C6 B7 20 21 22 32 33 34 35
	26 F8 40 41-> caracter 'w'
727B: 52 53 62 63 73 74 83 84 93 94 A4 A5 B4 B5 C6 C7 C0 B1 A2 93 74 84 74 65 56 47 F8 -> caracter 'x'
7298: 40 41 51 52 61 62 71 72 81 82 91 92 93 A2 A3 A4 95 96 85 86 75 76 65 66 55 56 46 47 A6 B5 B6 C6 C5 D6 D5 E4 E3 D3 D2 D1 E2 F8 -> caracter 'y'
72C2: 60 51 42 43 44 53 54 55 56 47 56 65 74 83 93 A2 B1 C0 B1 B2 B3 B4 C3 C4 C5 B6 A7 73 74 75 F8 -> caracter 'z'

72E1: 00 55 56 66 65 75 76 86 85 95 96 A6 A5 B5 B6 C6 B7 20 21 22 32 33 34 35 26 F8 -> ??? caracter irreconocible
72FB: 40 41 52 53 62 ; ???

; texto del pergamino de la presentación
7300: 20 59 61 20 61 6C 20 66-69 6E 61 6C 20 64 65 20  Ya al final de
7310: 6D 69 0D 76 69 64 61 20-64 65 20 70 65 63 61 64 mi.vida de pecad
7320: 6F 72 2C 20 6D 69 65 6E-2D 0D 74 72 61 73 20 65 or, mien-.tras e
7330: 73 70 65 72 6F 20 65 6C-20 6D 6F 2D 0D 6D 65 6E spero el mo-.men
7340: 74 6F 20 64 65 20 70 65-72 64 65 72 6D 65 20 65 to de perderme e
7350: 6E 0D 65 6C 20 61 62 69-73 6D 6F 20 73 69 6E 20 n.el abismo sin
7360: 66 6F 6E 64 6F 20 64 65-0D 6C 61 20 64 69 76 69 fondo de.la divi
7370: 6E 69 64 61 64 20 64 65-73 69 65 72 74 61 20 79 nidad desierta y
7380: 0D 73 69 6C 65 6E 63 69-6F 73 61 3B 20 65 6E 20 .silenciosa; en
7390: 65 73 74 61 0D 63 65 6C-64 61 20 64 65 20 6D 69 esta.celda de mi
73A0: 20 71 75 65 72 69 64 6F-0D 6D 6F 6E 61 73 74 65  querido.monaste
73B0: 72 69 6F 20 64 65 20 4D-65 6C 6B 2C 0D 64 6F 6E rio de Melk,.don
73C0: 64 65 20 61 75 6E 20 6D-65 20 72 65 74 69 65 6E de aun me retien
73D0: 65 0D 6D 69 20 63 75 65-72 70 6F 20 70 65 73 61 e.mi cuerpo pesa
73E0: 64 6F 20 79 0D 65 6E 66-65 72 6D 6F 2C 20 6D 65 do y.enfermo, me
73F0: 20 64 69 73 70 6F 6E 67-6F 0D 61 20 64 65 6A 61  dispongo.a deja
7400: 72 20 63 6F 6E 73 74 61-6E 63 69 61 20 65 6E 0D r constancia en.
7410: 65 73 74 65 20 70 65 72-67 61 6D 69 6E 6F 20 64 este pergamino d
7420: 65 20 6C 6F 73 0D 68 65-63 68 6F 73 20 61 73 6F e los.hechos aso
7430: 6D 62 72 6F 73 6F 73 20-79 0D 74 65 72 72 69 62 mbrosos y.terrib
7440: 6C 65 73 20 71 75 65 20-6D 65 20 66 75 65 0D 64 les que me fue.d
7450: 61 64 6F 20 70 72 65 73-65 6E 63 69 61 72 20 65 ado presenciar e
7460: 6E 20 6D 69 0D 6A 75 76-65 6E 74 75 64 2E 0D 0D n mi.juventud...
7470: 20 45 6C 20 53 65 77 6F-72 20 6D 65 20 63 6F 6E  El Sewor me con
7480: 63 65 2D 0D 64 65 20 6C-61 20 67 72 61 63 69 61 ce-.de la gracia
7490: 20 64 65 20 64 61 72 0D-66 69 65 6C 20 74 65 73  de dar.fiel tes
74A0: 74 69 6D 6F 6E 69 6F 20-64 65 20 6C 6F 73 0D 61 timonio de los.a
74B0: 63 6F 6E 74 65 63 69 6D-69 65 6E 74 6F 73 20 71 contecimientos q
74C0: 75 65 20 73 65 0D 70 72-6F 64 75 6A 65 72 6F 6E ue se.produjeron
74D0: 20 65 6E 20 6C 61 20 61-62 61 2D 0D 64 69 61 20  en la aba-.dia
74E0: 63 75 79 6F 20 6E 6F 6D-62 72 65 20 69 6E 2D 0D cuyo nombre in-.
74F0: 63 6C 75 73 6F 20 63 6F-6E 76 69 65 6E 65 20 61 cluso conviene a
7500: 68 6F 72 61 0D 63 75 62-72 69 72 20 63 6F 6E 20 hora.cubrir con
7510: 75 6E 20 70 69 61 64 6F-73 6F 0D 6D 61 6E 74 6F un piadoso.manto
7520: 20 64 65 20 73 69 6C 65-6E 63 69 6F 3B 20 68 61  de silencio; ha
7530: 2D 0D 63 69 61 20 66 69-6E 61 6C 65 73 20 64 65 -.cia finales de
7540: 20 31 33 32 37 2C 0D 63-75 61 6E 64 6F 20 6D 69  1327,.cuando mi
7550: 20 70 61 64 72 65 20 64-65 63 69 2D 0D 64 69 6F  padre deci-.dio
7560: 20 71 75 65 20 61 63 6F-6D 70 61 77 61 72 61 20  que acompawara
7570: 61 0D 66 72 61 79 20 47-75 69 6C 6C 65 72 6D 6F a.fray Guillermo
7580: 20 64 65 20 0D 4F 63 63-61 6D 2C 20 73 61 62 69  de .Occam, sabi
7590: 6F 20 66 72 61 6E 63 69-73 2D 0D 63 61 6E 6F 20 o francis-.cano
75A0: 71 75 65 20 65 73 74 61-62 61 20 61 0D 70 75 6E que estaba a.pun
75B0: 74 6F 20 64 65 20 69 6E-69 63 69 61 72 20 75 6E to de iniciar un
75C0: 61 0D 6D 69 73 69 6F 6E-20 65 6E 20 65 6C 20 64 a.mision en el d
75D0: 65 73 65 6D 2D 0D 70 65-77 6F 20 64 65 20 6C 61 esem-.pewo de la
75E0: 20 63 75 61 6C 20 74 6F-2D 0D 63 61 72 69 61 20  cual to-.caria
75F0: 6D 75 63 68 61 73 20 63-69 75 64 61 2D 0D 64 65 muchas ciuda-.de
7600: 73 20 66 61 6D 6F 73 61-73 20 79 20 61 62 61 2D s famosas y aba-
7610: 0D 64 69 61 73 20 61 6E-74 69 71 75 69 73 69 6D .dias antiquisim
7620: 61 73 2E 20 41 73 69 0D-66 75 65 20 63 6F 6D 6F as. Asi.fue como
7630: 20 6D 65 20 63 6F 6E 76-65 72 2D 0D 74 69 20 61  me conver-.ti a
7640: 6C 20 6D 69 73 6D 6F 20-74 69 65 6D 70 6F 20 65 l mismo tiempo e
7650: 6E 0D 73 75 20 61 6D 61-6E 75 65 6E 73 65 20 79 n.su amanuense y
7660: 20 64 69 73 2D 0D 63 69-70 75 6C 6F 3B 20 79 20  dis-.cipulo; y
7670: 6E 6F 20 74 75 76 65 20-71 75 65 0D 61 72 72 65 no tuve que.arre
7680: 70 65 6E 74 69 72 6D 65-2C 20 70 6F 72 71 75 65 pentirme, porque
7690: 0D 63 6F 6E 20 65 6C 20-66 75 69 20 74 65 73 74 .con el fui test
76A0: 69 67 6F 20 64 65 0D 61-63 6F 6E 74 65 63 69 6D igo de.acontecim
76B0: 69 65 6E 74 6F 73 20 64-69 67 6E 6F 73 0D 64 65 ientos dignos.de
76C0: 20 73 65 72 20 72 65 67-69 73 74 72 61 64 6F 73  ser registrados
76D0: 2C 0D 70 61 72 61 20 6D-65 6D 6F 72 69 61 20 64 ,.para memoria d
76E0: 65 20 6C 6F 73 0D 71 75-65 20 76 65 6E 67 61 6E e los.que vengan
76F0: 20 64 65 73 70 75 65 73-2E 0D 0D 20 41 73 69 2C  despues... Asi,
7700: 20 6D 69 65 6E 74 72 61-73 20 63 6F 6E 0D 6C 6F  mientras con.lo
7710: 73 20 64 69 61 73 20 69-62 61 20 63 6F 6E 6F 63 s dias iba conoc
7720: 69 65 6E 2D 0D 64 6F 20-6D 65 6A 6F 72 20 61 20 ien-.do mejor a
7730: 6D 69 20 6D 61 65 73 2D-0D 74 72 6F 2C 20 6C 6C mi maes-.tro, ll
7740: 65 67 61 6D 6F 73 20 61-20 6C 61 73 0D 66 61 6C egamos a las.fal
7750: 64 61 73 20 64 65 6C 20-6D 6F 6E 74 65 20 64 6F das del monte do
7760: 6E 2D 0D 64 65 20 73 65-20 6C 65 76 61 6E 74 61 n-.de se levanta
7770: 62 61 20 6C 61 0D 61 62-61 64 69 61 2E 20 59 20 ba la.abadia. Y
7780: 79 61 20 65 73 20 68 6F-72 61 0D 64 65 20 71 75 ya es hora.de qu
7790: 65 2C 20 63 6F 6D 6F 20-6E 6F 73 6F 74 72 6F 73 e, como nosotros
77A0: 0D 65 6E 74 6F 6E 63 65-73 2C 20 61 20 65 6C 6C .entonces, a ell
77B0: 61 20 73 65 0D 61 63 65-72 71 75 65 20 6D 69 20 a se.acerque mi
77C0: 72 65 6C 61 74 6F 2C 20-79 0D 6F 6A 61 6C 61 20 relato, y.ojala
77D0: 6D 69 20 6D 61 6E 6F 20-6E 6F 0D 74 69 65 6D 62 mi mano no.tiemb
77E0: 6C 65 20 63 75 61 6E 64-6F 20 6D 65 0D 64 69 73 le cuando me.dis
77F0: 70 6F 6E 67 6F 20 61 20-6E 61 72 72 61 72 20 6C pongo a narrar l
7800: 6F 0D 71 75 65 20 73 75-63 65 64 69 6F 20 64 65 o.que sucedio de
7810: 73 70 75 65 73 2E 2E 2E-0D 0D 0D 0D 0D 0D 61 75 spues.........au
7820: 74 6F 72 3A 20 0D 20 20-20 20 50 61 63 6F 20 4D tor: .    Paco M
7830: 65 6E 65 6E 64 65 7A 0D-0D 67 72 61 66 69 63 6F enendez..grafico
7840: 73 20 79 20 63 61 72 61-74 75 6C 61 3A 20 0D 20 s y caratula: .
7850: 20 20 20 4A 75 61 6E 20-44 65 6C 63 61 6E 0D 0D    Juan Delcan..
7860: 63 6F 70 79 72 69 67 68-74 3A 0D 20 20 20 20 4F copyright:.    O
7870: 70 65 72 61 20 53 6F 66-74 0D 1A 00 00 1A 1A 1A pera Soft.......
7880: 1A 1A 1A 00 00 00 00 00-00 00

; datos gráficos de la parte superior del pergamino
788A: F0 F0 F0 F0 E1 C2
7890: 84 08 F0 C3 84 08 01 01-01 01 87 08 03 0F 0E 0E
78A0: 0E 0E 0F 00 0C 00 00 00-00 00 0F 00 08 00 00 00
78B0: 00 00 0F 00 00 00 00 00-00 00 0F 00 00 00 00 00
78C0: 00 00 0F 00 00 00 00 00-00 00 0F 00 00 00 00 00
78D0: 00 00 0F 00 00 00 00 00-00 00 0F 00 00 00 00 00
78E0: 00 00 0F 00 00 00 00 00-00 00 3C 03 04 08 09 09
78F0: 04 03 F0 0F 00 00 02 02-09 0F F0 0F 00 00 04 04
7900: 02 0F F0 0F 00 00 09 09-04 0F F0 0F 00 00 02 02
7910: 09 0F F0 0F 00 00 04 04-02 0F F0 0F 00 00 09 09
7920: 04 0F F0 0F 00 00 02 02-09 0F F0 0F 00 00 04 04
7930: 02 0F F0 0F 00 00 09 09-04 0F F0 0F 01 02 03 02
7940: 09 0E F0 78 3C 12 1A 09-09 00 F0 F0 E1 C2 C2 84
7950: 84 08 F0 0F 0C 02 0E 0A-0C 03 F0 0F 00 00 04 04
7960: 09 0F F0 0F 00 00 09 09-02 0F F0 0F 00 00 02 02
7970: 04 0F F0 0F 00 00 04 04-09 0F F0 0F 00 00 09 09
7980: 02 0F F0 0F 00 00 02 02-04 0F F0 0F 00 00 04 04
7990: 09 0F F0 0F 00 00 09 09-02 0F F0 0F 00 00 02 02
79A0: 04 0F C3 0E 01 00 04 04-09 0E 0F 00 00 08 08 08
79B0: 00 00 78 34 25 12 12 12-01 00 0F 08 00 08 08 08
79C0: 00 08 0F 00 00 00 00 00-00 00 0F 00 00 00 00 00
79D0: 00 00 0F 00 00 00 00 00-00 00 0F 00 00 00 00 00
79E0: 00 00 0F 00 01 00 00 00-00 00 0F 00 03 00 00 00
79F0: 00 00 3C 03 08 0E 07 07-07 07 F0 3C 12 01 08 08
7A00: 08 08 F0 F0 F0 F0 78 34-12 01

; datos gráficos de la parte derecha del pergamino
7A0A: F0 F0 3C F0 12 F0
7A10: 01 F0 08 78 08 34 08 12-08 01 08 01 08 01 08 16
7A20: 07 3C 00 34 00 34 00 34-00 34 00 34 00 34 00 34
7A30: 00 34 00 34 00 34 00 34-00 34 00 34 00 34 00 34
7A40: 00 34 00 34 00 34 00 34-00 34 00 34 00 3C 01 F0
7A50: 12 F0 07 78 00 78 00 78-00 78 00 78 00 78 00 78
7A60: 00 78 00 78 00 78 00 78-00 78 00 78 00 78 00 78
7A70: 00 78 00 78 00 78 00 78-00 78 00 78 07 78 0F 78
7A80: 3C F0 3C F0 3C F0 3C F0-3C F0 3C F0 34 F0 34 F0
7A90: 34 F0 34 F0 12 F0 12 F0-01 F0 01 F0 00 78 00 78
7AA0: 00 78 00 78 00 78 00 78-00 78 00 78 00 78 00 78
7AB0: 00 78 00 78 00 78 00 78-00 78 00 78 00 78 00 78
7AC0: 00 78 00 78 00 78 00 78-00 78 00 78 00 78 00 78
7AD0: 00 78 00 78 00 78 00 78-00 78 00 78 00 78 00 78
7AE0: 00 78 0F 78 34 F0 12 F0-01 F0 00 78 00 34 00 34
7AF0: 00 34 00 34 00 34 00 34-00 34 00 34 00 34 00 34
7B00: 00 34 00 34 00 34 00 34-00 34 00 34 00 34 00 34
7B10: 00 34 00 34 00 34 00 34-00 34 00 34 00 34 00 34
7B20: 00 34 00 34 00 34 00 34-00 34 00 34 00 34 00 34
7B30: 00 34 00 34 00 34 00 34-00 34 00 34 00 34 00 34
7B40: 00 34 03 78 04 34 00 34-00 34 00 34 00 34 00 34
7B50: 00 34 00 34 00 34 00 34-00 34 00 34 00 34 00 34
7B60: 00 34 00 34 00 34 00 34-00 34 00 34 00 34 00 34
7B70: 00 34 07 3C 08 16 08 01-08 01 08 01 08 12 08 34
7B80: 08 78 01 F0 12 F0 3C F0-F0 F0

; datos gráficos de la parte izquierda del pergamino
7B8A: F0 F0 F0 C3 F0 84
7B90: F0 08 E1 01 C2 01 84 01-08 01 08 01 08 01 86 01
7BA0: C3 0E C2 00 C2 00 C2 00-C2 00 C2 00 C2 00 C2 00
7BB0: C2 00 C2 00 C2 00 C2 00-C2 00 C2 00 C2 00 C2 00
7BC0: C2 00 E1 00 E1 00 E1 00-E1 00 E1 00 E1 00 E1 00
7BD0: E1 00 E1 00 E1 00 E1 00-E1 00 E1 00 E1 00 E1 00
7BE0: E1 00 E1 00 E1 00 E1 00-E1 00 E1 00 E1 00 E1 00
7BF0: F0 08 F0 84 F0 C2 E1 0F-E1 01 E1 00 E1 00 E1 00
7C00: E1 00 E1 00 E1 00 E1 00-E1 00 E1 00 E1 00 E1 00
7C10: E1 00 E1 00 E1 00 E1 00-E1 00 E1 00 E1 00 E1 00
7C20: E1 00 E1 00 E1 00 E1 00-E1 00 E1 00 E1 00 E1 00
7C30: E1 00 E1 00 E1 00 E1 00-E1 00 E1 00 E1 00 E1 00
7C40: E1 00 E1 00 E1 00 E1 00-E1 00 E1 00 E1 00 E1 00
7C50: E1 00 E1 00 E1 00 E1 00-E1 00 E1 00 E1 00 E1 00
7C60: E1 00 E1 00 E1 00 E1 00-E1 00 E1 00 E1 00 E1 00
7C70: E1 00 E1 00 E1 00 E1 00-E1 00 E1 00 E1 00 E1 00
7C80: E1 00 E1 00 E1 00 E1 00-E1 00 E1 00 E1 00 E1 01
7C90: E1 0F F0 C2 F0 84 F0 08-E1 00 C2 00 C2 00 C2 00
7CA0: C2 00 C2 00 C2 00 C2 00-C2 00 C2 00 C2 00 C2 00
7CB0: C2 00 C2 00 C2 00 C2 00-C2 00 C2 00 C2 00 C2 00
7CC0: C2 00 C2 00 C2 00 C2 00-C2 00 C2 00 C2 00 C2 00
7CD0: C2 00 C2 00 C2 00 C2 00-C2 00 C2 00 C2 00 C2 00
7CE0: C2 00 C2 00 C2 00 C2 00-C2 00 C2 00 C2 00 C2 00
7CF0: C2 00 C3 0E 86 01 08 01-08 01 08 01 84 01 C2 01
7D00: E1 01 F0 08 F0 84 F0 C3-F0 F0

; datos gráficos de la parte inferior del pergamino
7D0A: 08 84 C2 E1 F0 F0
7D10: F0 F0 01 01 01 01 08 84-C3 F0 0E 0E 0E 0E 0F 03
7D20: 08 87 00 00 00 00 00 0C-00 0F 00 00 00 00 00 08
7D30: 00 0F 00 00 00 00 00 00-00 0F 00 00 00 00 00 00
7D40: 00 0F 00 00 00 00 00 00-00 0F 00 00 01 03 03 16
7D50: 16 3C 06 0F 0F 0F 0F F0-F0 F0 00 0E 0F 0F 0F F0
7D60: F0 F0 00 00 0E 0F 0F 0F-F0 F0 00 00 00 08 0C 0F
7D70: F0 F0 00 00 00 00 00 00-08 87 00 00 00 00 00 00
7D80: 00 0F 00 00 00 00 00 00-00 0F 00 00 00 00 00 00
7D90: 00 0F 00 00 00 00 00 00-00 0F 00 00 00 00 00 00
7DA0: 00 0F 00 00 00 00 00 00-00 0F 02 02 01 00 00 00
7DB0: 00 0F 00 00 00 08 08 08-0F F0 00 00 00 00 00 00
7DC0: 0F F0 00 00 00 00 00 00-0F F0 00 00 00 00 00 00
7DD0: 0F F0 00 00 00 00 00 00-0F F0 00 00 00 00 00 00
7DE0: 0F F0 08 04 04 02 02 03-1E F0 00 00 00 00 00 0F
7DF0: F0 F0 00 00 01 01 01 0F-E1 F0 04 08 00 00 00 00
7E00: 0F F0 00 00 00 00 00 00-0F F0 00 00 00 00 00 00
7E10: 0F F0 00 00 00 00 00 00-0F F0 00 00 00 00 00 00
7E20: 0F F0 00 00 01 01 01 01-0F E1 08 08 00 00 00 00
7E30: 00 0F 00 00 00 00 00 00-00 0F 00 00 00 00 00 00
7E40: 00 0F 00 00 00 00 00 00-00 0F 00 00 00 00 00 00
7E50: 00 0F 00 00 00 00 00 00-00 0F 00 00 00 00 00 00
7E60: 00 0F 00 00 00 00 00 01-00 0F 00 00 00 00 00 03
7E70: 00 0F 07 07 07 07 0F 08-03 3C 08 08 08 08 01 12
7E80: 3C F0 01 12 34 78 F0 F0-F0 F0

7E8A-7FFF: 00

; ---------------------------- fin del código y los datos relacionados con el pergamino --------------------------

; abadia3.bin (0x8000-0xbfff)

; -------------- inicio de los datos de la melodía del pergamino -------------------------
8000: F9 46 80 01 01 04 02 FF-04 01 01 04 80 01 00 01 .F..............
8010: 7F 01 0F 01 01 00 28 0A-FF 14 7F 01 0F 01 02 00 ......(.........
8020: 28 0A FF 1E 7F 01 0F 01-01 00 1E 0A FF 0F 7F 05 (...............
8030: 01 02 05 02 01 05 FF 0F-01 00 3C 0A FF 14 7F 01 ..........<.....
8040: 0C 14 02 FF 14 7F FA 11-80 FB 0D 80 FE D8 81 5A ...............Z
8050: 10 59 10 57 10 59 10 52-10 52 10 57 10 FA 25 80 .Y.W.Y.R.R.W..%.
8060: 47 08 49 08 4A 08 50 08-FA 1B 80 52 30 FA 11 80 G.I.J.P....R0...
8070: 53 10 FA 25 80 55 08 53-08 52 08 50 08 FA 11 80 S..%.U.S.R.P....
8080: 52 10 FA 25 80 53 08 52-08 50 08 4B 08 FA 11 80 R..%.S.R.P.K....
8090: 50 10 FA 25 80 52 08 50-08 4A 08 50 08 49 08 4A P..%.R.P.J.P.I.J
80A0: 08 FA 1B 80 49 20 FA 11-80 5A 10 FA 25 80 59 04 ....I ...Z..%.Y.
80B0: 5A 04 59 08 FA 11 80 57-10 59 10 52 10 52 10 57 Z.Y....W.Y.R.R.W
80C0: 10 FA 25 80 47 08 49 08-4A 08 50 08 FA 1B 80 52 ..%.G.I.J.P....R
80D0: 30 FA 25 80 55 04 53 04-55 08 57 08 55 08 53 08 0.%.U.S.U.W.U.S.
80E0: 52 08 FA 11 80 53 10 FA-25 80 55 08 53 08 52 08 R....S..%.U.S.R.
80F0: 50 08 FA 11 80 52 10 57-10 FA 25 80 50 04 52 04 P....R.W..%.P.R.
8100: 50 08 FA 1B 80 FD F4 82-42 30 FA 11 80 52 10 FA P.......B0...R..
8110: 25 80 4A 08 50 08 52 08-54 08 FA 11 80 55 10 57 %.J.P.R.T....U.W
8120: 10 59 10 5A 10 FA 25 80-57 08 59 08 5A 08 57 08 .Y.Z..%.W.Y.Z.W.
8130: FA 11 80 59 10 FA 25 80-57 08 59 08 FA 11 80 55 ...Y..%.W.Y....U
8140: 10 FA 25 80 45 08 47 08-49 08 4A 08 50 08 52 08 ..%.E.G.I.J.P.R.
8150: FA 11 80 53 10 FA 25 80-52 04 53 04 52 08 FA 11 ...S..%.R.S.R...
8160: 80 50 10 55 10 4A 10 49-10 FA 1B 80 4A 30 FA 11 .P.U.J.I....J0..
8170: 80 47 10 FA 25 80 52 08-50 08 FA 11 80 52 10 47 .G..%.R.P....R.G
8180: 10 FA 25 80 53 08 52 08-FA 11 80 53 10 FA 25 80 ..%.S.R....S..%.
8190: 47 08 52 08 46 08 50 08-47 08 4A 08 FA 1B 80 49 G.R.F.P.G.J....I
81A0: 30 FA 25 80 42 08 44 08-46 08 47 08 49 08 4A 08 0.%.B.D.F.G.I.J.
81B0: FA 11 80 50 10 4A 10 49-10 FA 25 80 4A 02 49 02 ...P.J.I..%.J.I.
81C0: 4A 04 50 04 52 04 FA 11-80 47 10 46 10 FA 1B 80 J.P.R....G.F....
81D0: FD EB 82 4A 30 F9 46 80-FA 1B 80 FB 0D 80 37 30 ...J0.F.......70
81E0: 35 30 36 30 FA 11 80 32-10 FA 25 80 42 08 40 08 5060...2..%.B.@.
81F0: 3A 08 39 08 FA 1B 80 FD-D9 82 37 20 39 10 3A 20 :.9.......7 9.:
8200: FA 11 80 37 10 39 10 36-10 37 10 32 10 FA 25 80 ...7.9.6.7.2..%.
8210: 42 08 40 08 3A 08 39 08-FA 1B 80 37 30 35 30 33 B.@.:.9....70503
8220: 30 FA 11 80 32 10 FA 25-80 42 08 40 08 3B 08 39 0...2..%.B.@.;.9
8230: 08 FA 1B 80 FE D0 82 3B-20 FA 11 80 37 10 40 10 .......; ...7.@.
8240: 39 10 35 10 3A 10 34 10-FE E2 82 35 10 3A 10 FA 9.5.:.4....5.:..
8250: 1B 80 2A 20 4A 30 FA 11-80 49 10 47 10 45 10 47 ..* J0...I.G.E.G
8260: 10 44 10 40 10 FA 1B 80-45 30 FA 11 80 49 10 47 .D.@....E0...I.G
8270: 10 45 10 FA 1B 80 47 20-FA 11 80 45 10 43 10 42 .E....G ...E.C.B
8280: 10 43 10 45 10 3A 10 42-10 40 10 FD C7 82 FA 1B .C.E.:.B.@......
8290: 80 3B 30 40 30 FA 11 80-3A 10 39 10 37 10 42 10 .;0@0...:.9.7.B.
82A0: FA 25 80 39 08 37 08 36-08 34 08 FA 1B 80 32 30 .%.9.7.6.4....20
82B0: FA 11 80 33 10 32 10 30-10 2A 10 30 10 32 10 37 ...3.2.0.*.0.2.7
82C0: 10 FA 1B 80 27 20 FF FA-1B 80 FB 0D 80 32 30 FF ....' .......20.
82D0: FA 1B 80 FB 0D 80 42 20-FF FA 1B 80 FB 0D 80 3A ......B .......:
82E0: 20 FF FA 11 80 FB 0D 80-39 10 FF FA 1B 80 FB 0D  .......9.......
82F0: 80 47 30 FF FA 1B 80 FB-0D 80 4A 30 FF 00 00 00 .G0.......J0....
; -------------- fin de los datos de la melodía del pergamino -------------

; -------------- inicio de los gráficos de la abadía ----------------------
8300: 00 00 00 00 00 00 00 00-00 00 00 00 00 00 00 00 ................
8310: 00 00 00 00 00 00 00 00-00 00 00 00 00 00 00 00 ................
8320: FC F0 F0 F3 33 F0 F0 CC-00 FC F3 00 00 33 CC 00 ....3........3..
8330: 00 33 CC 00 00 FC F3 00-33 F0 F0 CC FC F0 F0 F3 .3......3.......
8340: F7 EE EE FC F7 BB BB F3-E6 EE FC FF F7 BB F3 FF ................
8350: E6 FC F7 EE F7 F0 FF BB-F0 FE EE EE F3 BA FF BB ................
8360: EE FE EE FC BB BA FF F1-EE FE F4 FF BB B8 F3 FF ................
8370: EE FC FF DD BB F3 FF 77-FC FF DD DD F3 FF 77 77 .......w......ww
8380: 88 00 00 F3 CC 88 B8 FF-33 70 F3 00 00 FF CC 00 ........3p......
8390: 00 F3 00 00 30 CC 88 88-F3 00 00 00 CC 22 22 30 ....0........""0
83A0: CC 00 00 33 33 00 00 CC-00 CC 33 00 00 33 CC 00 ...33.....3..3..
83B0: 00 33 CC 00 00 CC 33 00-33 00 00 CC CC 00 00 33 .3....3.3......3
83C0: FC F8 70 71 F3 D0 D0 F1-B0 FC 70 71 E0 F3 D0 D1 ..pq......pq....
83D0: B0 B0 FC 71 E0 F0 FB F1-B0 B0 F8 FD E0 F0 D8 F3 ...q............
83E0: FC F0 F8 F8 F3 F0 D8 D0-B0 FC F8 F8 F1 F3 D8 D0 ................
83F0: B0 B0 FC F8 F1 F0 F3 D0-B0 B0 B0 FC F1 E0 E0 F3 ................
8400: F0 B3 E0 B3 D0 FC 50 FC-B3 E0 B3 E0 FC 50 FC 50 ......P......P.P
8410: E0 B3 E2 B3 D8 FC A0 FC-B3 E0 73 E0 FC 50 FC 10 ..........s..P..
8420: FE FC FF FC FE F2 FF F3-FC FE FC FF F3 76 F2 FF .............v..
8430: DD FC FE FC 77 F3 76 F2-FC DD FC FE F2 77 F3 FE ....w.v......w..
8440: FC F0 FC F8 F3 F0 FB F8-F0 FC F8 FC F0 FB E8 F3 ................
8450: FC F8 FC B0 FB D8 F3 E0-F8 FC 70 FC F8 F3 D0 FB ..........p.....
8460: 0F FF 0F 0F 1F 00 CF 0F-2E 07 33 0F 2E 0F 1D 8F ..........3.....
8470: 2E 0F 0E 8F 2E 0F 0F 47-2E 0F 0F 47 2E FF FF 47 .......G...G...G
8480: 3F F0 F0 47 7C FF FF 67-FB FF FF 75 F8 FF FF 75 ?..G|..g...u...u
8490: 7F F0 F0 EF 7D FF FF E3-F8 F7 FE F9 E8 F0 F0 F5 ....}...........
84A0: D8 F0 F0 F5 D8 F0 F0 F5-F8 F0 F0 F5 F8 F0 F0 F9 ................
84B0: 7C F0 F3 E3 3E F0 F0 C7-1F FC F3 8F 0F 3F CF 0F |...>........?..
84C0: 0F 7F CF 0F 2F F8 E3 8F-5F F7 FD 4F 8F F8 E3 2F ..../..._..O.../
84D0: 8F 7F CF 2F 8F FB EB 2F-5F F4 F5 4F 3E F3 F8 8F .../.../_..O>...
84E0: 7C F0 F1 C7 7D F0 F6 C7-7C F5 F9 CF 7C F1 F6 C7 |...}...|...|...
84F0: 7C F1 F9 CF 7C F0 F6 C7-7C F1 F9 CF 7C F1 F6 C7 |...|...|...|...
8500: FC F0 CC 00 3F F0 F3 00-0F FC F0 CC 0F 3F F0 F3 ....?........?..
8510: 0F 0F FC F1 0F 0F 3F F1-0F 0F 0F FD 0F 0F 0F 3F ......?........?
8520: CC 00 00 33 F3 00 00 FF-F0 CC 33 FF F0 FB FF FF ...3......3.....
8530: FC F8 FF CC FB F8 FF 00-F8 FC CC 00 F8 F3 00 00 ................
8540: 00 F3 FF FC 30 FF FF C3-F3 FF FC 0F F7 FF C3 0F ....0...........
8550: F7 FC 0F 0F F7 C3 0F 0F-F4 0F 0F 0F C3 0F 0F 0F ................
8560: CC 00 00 30 FF 00 00 F3-FF CC 30 FF FF FF F2 FF ...0......0.....
8570: 33 FE FE FC 00 FE FE F2-00 32 FC FE 00 10 F3 FE 3........2......
8580: CF 0F 0F 0F FF 0F 0F 0F-F3 CF 0F 0F F0 FF 0F 0F ................
8590: F0 F3 CF 0F F0 F0 FB 0F-FC F3 F8 CF 33 CC F8 FB ............3...
85A0: FC F0 F1 88 FF F0 E2 88-FF FC C4 88 FF FF 88 00 ................
85B0: FF FF 00 33 3F FF 00 FF-0F FF 33 FC 0F 7F FF F0 ...3?.....3.....
85C0: 0F 1F F0 F0 0F 3E F0 F0-0F 7D F8 F0 0F F8 F6 F0 .....>...}......
85D0: 1F F0 F0 F0 3F F8 F0 F0-7C F6 F0 F0 F8 F1 F8 F0 ....?...|.......
85E0: FC F0 F0 F0 FF F0 F0 F0-FF FC F0 F0 FF FF F0 F0 ................
85F0: FF FF FC F0 3F FF FF F0-1F FF FF FC 1F FF FF FF ....?...........
8600: F0 F0 F0 F7 F0 F0 F0 FF-F1 F0 FC F6 F0 FC F1 F0 ................
8610: F0 F3 F0 FD F0 F0 FC E2-F0 F0 F3 E6 F0 F0 F0 AA ................
8620: D1 00 FC F8 E2 00 FB F8-C4 00 F8 FC 88 00 E8 F3 ................
8630: 00 00 FC B0 00 00 FB F0-00 00 B8 FC 00 00 F8 FB ................
8640: 0F 0F 0F 0F 0F 0F 0F 1F-0F 0F 0F 7E 0F 0F 1F F8 ...........~....
8650: 0F 0F 1F FC 0F 0F 3E 33-0F 0F 7C C0 0F 0F F8 F0 ......>3..|.....
8660: CC 00 CC 00 33 00 33 00-00 CC 00 CC 00 33 00 33 ....3.3......3.3
8670: 00 30 00 30 00 F3 00 F2-30 FF 30 FE F2 FF F3 FE .0.0....0.0.....
8680: CC 00 CF 0F 33 00 33 0F-00 CC 00 CF 00 33 00 33 ....3.3......3.3
8690: 00 30 00 30 00 F3 00 F2-30 FF 30 FE F2 FF F3 FE .0.0....0.0.....
86A0: C0 FC F0 F3 F0 33 F0 F0-F0 C0 FC F0 F0 F0 33 F0 .....3........3.
86B0: F0 F0 C0 FC F0 F0 F0 33-F0 F0 F0 C0 F0 F0 F0 F0 .......3........
86C0: 0F 0F 0F 0F CF 0F 0F 0F-F3 0F 0F 0F F0 CF 0F 0F ................
86D0: F0 F3 0F 0F F0 F0 CF 0F-FC F0 F3 0F 33 F0 F0 CF ............3...
86E0: FC E3 0F 0F 7E CF 0F 0F-3F 0F 0F 0F 0F 0F 0F 0F ....~...?.......
86F0: 0F 0F 0F 0F 0F 0F 0F 0F-0F 0F 0F 0F 0F 0F 0F 0F ................
8700: 11 33 0F 0F 11 EF 0F 0F-33 EF 0F 0F FF E3 0F 0F .3......3.......
8710: FC E3 0F 0F F0 E3 0F 0F-F0 E3 0F 0F F0 E3 0F 0F ................
8720: FE FC FF FC FE F3 FF FF-FC EF 3F FF F3 8F 3F FF ..........?...?.
8730: DD 0F 3F FC EF 0F 3F FE-EF 0F 3F FE C7 0F 3F FE ..?...?...?...?.
8740: CF 0F 3F FC CF 0F 3F FF-CF 0F 3F FF C7 0F 3F FF ..?...?...?...?.
8750: CF 0F 3F FC CF 0F 3F FE-CF 0F 3F FE C7 0F 3F FE ..?...?...?...?.
8760: CF 0F FC FC CF 3F F0 F3-CF FC F0 FF F7 F0 F3 FF .....?..........
8770: FC F0 FF FC FC F3 FE F2-FC FF FC FE F7 FF F3 FE ................
8780: FC F0 FC F8 F3 FE FB F8-F3 DF F8 FC F3 CF 7E F3 ..............~.
8790: FF CF 1F B0 FB CF 0F F8-FB CF 0F 7C FB CF 0F 7F ...........|....
87A0: FF CF 0F 3E F3 CF 0F 3E-F3 CF 0F 3E F3 CF 0F 3F ...>...>...>...?
87B0: FF CF 0F 3E FB CF 0F 3E-FB CF 0F 3E FB CF 0F 3F ...>...>...>...?
87C0: FF F3 0F 3E F4 F0 CF 3E-F7 F0 F3 3E F3 FC F0 FF ...>...>...>....
87D0: FC FF F0 F2 FB FB FC F2-F8 FC FF F2 F8 F3 F3 FF ................
87E0: FC F0 FC F8 F3 F0 FB F8-F3 FC F8 FC F3 FF F8 F3 ................
87F0: FF CF FC B0 FB CF 3F F0-FB CF 0F FC FB CF 0F 3F ......?........?
8800: FE FC FF FC FE F2 FF C3-FC FE FC 0F F3 76 C3 0F .............v..
8810: DD FC 0F 0F 77 C3 0F 0F-FC 0F 0F 0F C3 0F 0F 0F ....w...........
8820: 0F 0F 0F 3C 0F 0F 0F F3-0F 0F 3C FF 0F 0F F2 FF ...<......<.....
8830: 0F 3C FE FC 0F F3 76 F2-3C DD FC FE F2 77 F3 FE .<....v.<....w..
8840: F8 F4 FF FD F8 F4 FF FD-F8 F4 FF FF F8 F4 FF FF ................
8850: F8 F0 FF CF FC F0 9F 8F-3F F3 0F 0F 0F CF 0F 0F ........?.......
8860: FC F0 FC F8 3F F0 FB F8-0F FC F8 FC 0F 3F E8 F3 ....?........?..
8870: 0F 0F FC B0 0F 0F 3F F0-0F 0F 0F FC 0F 0F 0F 3F ......?........?
8880: 0F CF 0F 0F 1F E3 3F 8F-1F E3 7C CF 3F E3 3F 8F ......?...|.?.?.
8890: 7C FD 4C EF FC F0 FF FB-FB F0 FE FD F8 FC FF FD |.L.............
88A0: CF 0F 0F 0F F3 0F 0F 0F-F0 CF 0F 0F F0 FB 0F 0F ................
88B0: FC F8 CF 0F FB E8 F3 0F-F8 FC B0 CF F8 F3 F0 FB ................
88C0: 57 00 00 00 AE 00 00 00-44 00 00 00 EA 00 11 CC W.......D.......
88D0: F9 EE 32 E2 F8 F1 FC DB-75 FE F5 F9 74 FF F9 DB ..2.....u...t...
88E0: 56 F3 FD E2 32 F0 F1 CC-11 5A 7B 00 00 FF EE 00 V...2....Z{.....
88F0: 00 00 66 00 00 11 F9 88-00 76 F0 E6 11 F8 F0 F1 ..f......v......
8900: 76 F0 F0 F1 F8 F0 F0 E6-F8 F0 F1 8E FE F0 E7 79 v..............y
8910: F9 F9 9E E6 76 E7 79 88-11 E9 E6 00 00 77 88 00 ....v.y......w..
8920: 7C F1 F9 CF 7C F1 F6 C7-7C F0 F9 CF 7C F1 F6 C7 |...|...|...|...
8930: 7C F0 F9 8F 3F F8 F7 8F-0F FF EF 0F 0F 3F 8F 0F |...?........?..
8940: CF 0F 0F 0F F3 0F 0F 0F-FC CF 0F 0F F0 F3 0F 0F ................
8950: 7C F0 CF 0F EF F0 F3 0F-E3 7C F0 CF E3 EF F0 F3 |........|......
8960: E3 E3 7C F0 E3 E3 EF F0-E3 E3 E3 7C 4F E3 E3 EF ..|........|O...
8970: C7 E3 E3 E3 F7 4F E3 E3-FC C7 E3 E3 F0 F4 4F E3 .....O........O.
8980: FC F0 C7 E3 3F F0 F4 4F-0F FC F0 C7 0F 3F F0 F4 ....?..O.....?..
8990: 0F 0F FC F0 0F 0F 3F F0-0F 0F 0F FC 0F 0F 0F 3F ......?........?
89A0: 0F 0F 0F 3F 0F 0F 0F FC-0F 0F 3F F3 0F 0F FC F0 ...?......?.....
89B0: 0F 3F F0 E3 0F FC F0 7F-3F F0 E3 7C FC F0 7F 7C .?......?..|...|
89C0: F0 E3 7C 7C F0 7F 7C 7C-E3 7C 7C 7C 7F 7C 7C 2F ..||..||.|||.||/
89D0: 7C 7C 7C 3E 7C 7C 2F FE-7C 7C 3E F3 7C 2F F2 F1 |||>||/.||>.|/..
89E0: 7C 3E F0 F3 2F F2 F0 CF-3E F0 F3 0F F2 F0 CF 0F |>../...>.......
89F0: F0 F3 0F 0F F0 CF 0F 0F-F3 0F 0F 0F CF 0F 0F 0F ................
8A00: 20 B3 A0 B3 CC DC 50 DD-FF 20 B3 11 FF CC DD 11  .....P.. ......
8A10: FF FF 11 33 3F FF 11 FF-0F FF 33 FC 0F 7F FF F0 ...3?.....3.....
8A20: FC F7 FF FD 33 F7 FF F1-00 FF FF F1 CC 33 FF F1 ....3........3..
8A30: FF FD FF F1 32 F1 FF F1-FE F3 FF F1 DD FD FF F1 ....2...........
8A40: 11 F1 FF F1 99 F1 FF F1-11 F1 FF F1 11 F1 FF F3 ................
8A50: 99 F3 33 CC 11 FD 00 00-11 F1 00 30 99 E2 00 F3 ..3........0....
8A60: 0F 0F 0F 3F 0F 0F 0F DC-0F 0F 3F A0 0F 0F DC 50 ...?......?....P
8A70: 0F 0F E8 B3 0F 0F DC DC-0F 0F FF A0 0F 0F FF DC ................
8A80: 11 44 30 FF 11 00 F3 FF-33 30 FF FF CC F3 FF 33 .D0.....30.....3
8A90: 30 FF CC CC F3 FF FF 33-FF FF 33 CC FF F7 CC FF 0......3..3.....
8AA0: FE FC FC F8 FE F2 FB F8-FC FE F8 FC F3 FE E8 F3 ................
8AB0: FC FC FC B0 33 F7 F3 E0-FF F7 70 FC DD F7 D0 FB ....3.....p.....
8AC0: 33 F7 F0 F8 DD CC FC F8-11 00 33 F8 33 00 00 FC 3.........3.3...
8AD0: FF 00 00 33 DD 00 00 00-11 00 00 30 33 00 00 F3 ...3.......03...
8AE0: FD 00 30 FF F3 00 F3 FF-CC 30 FF FC 00 F3 FF F3 ..0......0......
8AF0: 30 FF FC B0 F3 FF F3 E0-FF FF FC FC FF FF F3 FB 0...............
8B00: 0F 7F FC F3 0F 7F F0 F3-0F 7F F0 C7 0F 7F F0 C7 ................
8B10: 0F 7F F0 8F 0F 7F F0 8F-0F 7F F3 0F 0F 1F CF 0F ................
8B20: 1F FC FF FF 1F FC F3 FF-1F FC F1 FF 1F FC F1 3F ...............?
8B30: 1F FC E3 0F 1F FC E3 0F-1F FC CF 0F 0F 7F 0F 0F ................
8B40: CF 0F 0F 0F 73 0F 0F 0F-B3 CF 0F 0F CC 73 0F 0F ....s........s..
8B50: 20 B3 0F 0F D8 DD 0F 0F-B3 11 0F 0F DD 11 0F 0F  ...............
8B60: F0 F0 F0 F0 F0 F0 F0 F0-F0 F0 F0 F0 F0 F0 F0 F0 ................
8B70: F0 F0 F0 F0 F0 F0 F0 F0-F0 F0 F0 F0 F0 F0 F0 F0 ................
8B80: 0F 0F 0F 3F 0F 0F 0F CC-0F 0F 3F 00 0F 0F CC 00 ...?......?.....
8B90: 0F 3F 00 00 0F CC 00 00-3F 00 00 00 CC 00 00 00 .?......?.......
8BA0: CF 0F 0F 0F 33 0F 0F 0F-00 CF 0F 0F 00 33 0F 0F ....3........3..
8BB0: 00 00 CF 0F 00 00 33 0F-00 00 00 CF 00 00 00 33 ......3........3
8BC0: 4F 0F 0F 0F 4F 0F 0F 0F-6B 0F 0F 0F 79 0F 0F 0F O...O...k...y...
8BD0: F9 0F 0F 0F 7D 0F 1F 0F-6F 0F 1F 0F FD 0F 1E 8F ....}...o.......
8BE0: F0 B3 E0 B3 DC FC 50 FC-FF E0 B3 E0 FF DC FC 50 ......P........P
8BF0: FF FF E2 B3 3F FF EC FC-1F FF FF E0 1F FF FF DC ....?...........
8C00: A0 B3 A0 B3 50 DC 50 DD-B3 20 B3 11 CC 50 DD 11 ....P.P.. ...P..
8C10: 20 B3 11 33 D8 DD 11 CF-B3 11 33 8F DD 11 77 8F  ..3......3...w.
8C20: 0F 1F F4 F0 0F 3E F3 F0-0F 7C F0 FC 0F FB F0 F3 .....>...|......
8C30: 1F F0 FC F0 3E F0 F3 F0-7C FC F0 FC F8 F3 F0 F3 ....>...|.......
8C40: 0F 0F 0F 1F 0F 0F 0F 3E-0F 0F 0F 7C 0F 0F 0F FB .......>...|....
8C50: 0F 0F 1F F0 0F 0F 3E F0-0F 0F 7C FC 0F 0F F8 F3 ......>...|.....
8C60: 87 0F 0F 0F CB 0F 0F 0F-ED 0F 0F 0F F2 0F 0F 0F ................
8C70: FF 87 0F 0F FF CB 0F 0F-FC ED 0F 0F F3 FE 0F 0F ................
8C80: FF FC 87 0F FF F3 CB 0F-FC FF ED 0F F3 FF F2 0F ................
8C90: FF FC FF 87 FF F3 FF C3-FC FF FC ED F3 FF F3 FE ................
8CA0: 0F 0F 0F 3F 0F 0F 0F CC-0F 0F 3F 00 0F 0F CC 00 ...?......?.....
8CB0: 0F 3F CC 00 0F FC F3 00-3F F0 F0 CC FC F0 F0 F3 .?......?.......
8CC0: CF 0F 0F 0F 33 0F 0F 0F-00 CF 0F 0F 00 33 0F 0F ....3........3..
8CD0: 00 33 CF 0F 00 FC F3 0F-33 F0 F0 CF FC F0 F0 F3 .3......3.......
8CE0: CF 0F 0F 0F 33 0F 0F 0F-00 CF 0F 0F 00 33 0F 0F ....3........3..
8CF0: 00 33 CF 0F 00 CC 33 0F-33 00 00 CF CC 00 00 33 .3....3.3......3
8D00: FE FC FF FC FE F2 FF F2-FC FE FC FE F3 FE F2 FE ................
8D10: FF FC FE FC FF F0 FE F2-FC FC FC FE F2 F3 F3 FE ................
8D20: FF FC FF FC FF F2 FF F2-FC FE FC FE F3 FE F2 FE ................
8D30: FF FC FE FC FF F3 FE F2-FC FF FC FE F2 FF F3 FE ................
8D40: FE FC FF FC FE F2 FF F3-FC FE FC FC F3 76 F3 FF .............v..
8D50: DD FC F3 FC 77 F3 FD F2-FC FF FC FE F3 FF F3 FE ....w...........
8D60: FE FC FF FC FE F2 FF F3-FC FE FC FF F3 76 F3 FF .............v..
8D70: DD FC F3 FC 77 F3 FD F3-FC FF FC FF F3 FF F3 FF ....w...........
8D80: FE FC FF FC FE F2 FF F3-FC FE FC FF F3 76 F3 FF .............v..
8D90: DD FC F3 FC 77 F3 FD F3-FC F3 FC FF F3 F0 FB FF ....w...........
8DA0: FF F0 FF FC FF F0 FF F3-FC FC FC FF F3 F3 F2 FF ................
8DB0: FF F0 FE FC FF F0 FE F2-FC FC FC FE F3 F3 F3 FE ................
8DC0: 0F 0F 0F 3C 0F 0F 0F F3-0F 0F 3C FF 0F 0F C0 F3 ...<......<.....
8DD0: 0F 3C 00 30 0F C0 00 F2-3C CC 30 FE F3 F3 F3 FE .<.0....<.0.....
8DE0: FF F0 FF FC FF F0 FF F2-FC FC FC FE F3 F3 F2 FE ................
8DF0: FF F0 FE FC FF F0 FE F2-FC FC FC FE F3 F3 F3 FE ................
8E00: FF F0 FF FC FF F0 FF F2-FC FC FC FE F3 F3 F2 FE ................
8E10: FF F0 FE FC FF F0 FE C3-FC FC FC 0F C3 3F C3 0F .............?..
8E20: 0F 0F 0F 3F 0F 0F 0F CC-0F 0F 3F 00 0F 0F CC 00 ...?......?.....
8E30: 0F 3F CC 00 0F CC 33 00-3F 00 00 CC CC 00 00 33 .?....3.?......3
8E40: FE F0 FF FC FF F0 F0 F3-F8 FC F8 F1 F0 FB E8 F2 ................
8E50: FC F8 FC B0 FB D8 F3 E0-F8 FC 70 FC F8 F3 D0 FB ..........p.....
8E60: FE FC FF FC FE F2 FF F3-FC FE FC FF F3 76 F2 FF .............v..
8E70: DD FC FE FE 77 F3 76 E1-FC DD FC CB F2 77 F3 87 ....w.v......w..
8E80: FE FC FF 87 FE F2 FE 0F-FC FE FC 0F F3 76 E1 0F .............v..
8E90: DD FC ED 0F 77 F3 43 0F-FC DD CB 0F F2 77 87 0F ....w.C......w..
8EA0: FE FC 0F 0F FE F2 0F 0F-FC FE 0F 0F F3 76 0F 0F .............v..
8EB0: DD FC 0F 0F 77 F2 0F 0F-FC DC 0F 0F F2 76 0F 0F ....w........v..
8EC0: FE FC 0F 0F FE F2 0F 0F-FC FE 0F 0F F3 76 0F 0F .............v..
8ED0: DD FC 0F 0F 77 C3 0F 0F-FC 0F 0F 0F C3 0F 0F 0F ....w...........
8EE0: 0F 3F 8F 0F 0F 3F 8F 0F-0F 3F 8F 0F 0F FF EF 0F .?...?...?......
8EF0: 1F 33 99 0F 1F 91 31 0F-0F CC 67 0F 0F 3F 8F 0F .3....1...g..?..
8F00: 0F 0F 0F 2F 0F 0F 0F 2F-0F 0F 0F 4D 0F 0F 0F 09 .../.../...M....
8F10: 0F 0F 0F 08 0F 8F 0F 22-0F 8F 0F 66 1F 07 0F 2B ......."...f...+
8F20: FE FC FF FC FE F2 FF F3-FC FE FC FF F3 FE F3 FF ................
8F30: DD FC 3F FC FF C3 3F FE-FC 0F 3F FE C3 0F 3F FE ..?...?...?...?.
8F40: FF FE EE FC FF BA FF C3-EE FE F4 0F BB B8 C3 0F ................
8F50: EE FC 0F 0F BB C3 0F 0F-FC 0F 0F 0F C3 0F 0F 0F ................
8F60: 0F 0F 0F 0F 0F 0F 0F 3F-0F 0F 0F FF 0F 0F 3F FF .......?......?.
8F70: 0F 0F F7 EE 0F 3C FF BB-0F FE EE EE 3F FE FF BB .....<......?...
8F80: 0F 0F 7C F3 0F 0F 3F E7-0F 0F 0F CF 0F 0F 0F 0F ..|...?.........
8F90: 0F 0F 0F 0F 0F 0F 0F 0F-0F 0F 0F 0F 0F 0F 0F 0F ................
8FA0: 0F 0F FF FF 0F 0F 7F FF-0F 0F 7F FF 0F 0F 7C FF ..............|.
8FB0: 0F 0F 7C F3 0F 0F 7C F0-0F 0F 7C F0 0F 0F 7C F0 ..|...|...|...|.
8FC0: FC F3 EF 0F FC F0 EF 0F-3E F0 EF 0F 3E F0 EF 0F ........>...>...
8FD0: 1F F0 EF 0F 1F F0 EF 0F-0F FC EF 0F 0F 3F 8F 0F .............?..
8FE0: 11 33 F3 8F 11 FC F3 8F-33 F8 F3 8F CF F8 F3 8F .3......3.......
8FF0: 0F 7C F3 8F 0F 7C F3 8F-0F 3F F3 8F 0F 0F EF 0F .|...|...?......
9000: A0 B3 A0 B3 DC DC 50 DD-FF A0 B3 11 FF DC DD 11 ......P.........
9010: FF FF 11 33 FF FF 11 CC-F3 FF 33 00 F0 FF EE 00 ...3......3.....
9020: 00 33 00 33 00 CC 00 CC-33 00 33 00 CC 00 CC 00 .3.3....3.3.....
9030: CC 00 CC 00 FB 00 FB 00-F8 CC B8 CC F8 F3 E8 FB ................
9040: FC F0 F8 70 3F F0 D8 D0-0F FC F8 70 0F 3F D8 D0 ...p?......p.?..
9050: 0F 0F FC 70 0F 0F 3F F0-0F 0F 0F FC 0F 0F 0F 3F ...p..?........?
9060: 0F 3F 00 33 0F CC 00 CC-3F 00 33 00 CC 00 CC 00 .?.3....?.3.....
9070: CC 00 CC 00 F3 00 FB 00-F0 CC B8 CC F0 F3 E8 FB ................
9080: 00 00 00 33 00 00 00 CF-00 00 33 0F 00 00 CF 0F ...3......3.....
9090: 00 33 0F 0F 00 CF 0F 0F-33 0F 0F 0F CF 0F 0F 0F .3......3.......
90A0: 0F 2E 67 0F 2F 3F CF 0F-5D 2E 47 0F 88 AE 47 0F ..g./?..].G...G.
90B0: BB EE 47 0F 99 EE 8F 0F-5D 7F 0F 0F 2F 0F 0F 0F ..G.....].../...
90C0: FC F0 FF F8 F3 FF FF F4-F7 FE FC FE FF 76 F2 FF .............v..
90D0: DD FC FE FC 77 F3 76 F2-FC DD FC FE F2 77 F3 FE ....w.v......w..
90E0: FC F0 FC F8 F3 F0 FB F8-F0 FC F8 FC F0 FB E8 F3 ................
90F0: F8 F8 FC B0 7F F8 73 F0-3E FC D0 FC 1F F3 E0 FB ......s.>.......
9100: 1F F0 FC F8 0F F8 FB F8-0F FC F8 FC 0F 7F E8 F3 ................
9110: 0F 7C FC B0 0F 3E F3 F0-0F 3E B0 FC 0F 1F E0 FB .|...>...>......
9120: 0F 1F FC F8 0F 1F FB F8-0F 1F F8 FC 0F 1F E8 F3 ................
9130: 0F 1F FC B0 0F 1F F3 E0-0F 1F 70 FC 0F 1F D0 FB ..........p.....
9140: 0F 1F FC F8 0F 1F FB F8-0F 1F F8 FC 0F 1F E8 F3 ................
9150: 0F 0F FC B0 0F 0F 3F E0-0F 0F 0F FC 0F 0F 0F 3F ......?........?
9160: 0F CC 8F 0F 0F 7F 8F 8F-0F 4C 9F 47 0F 4C AE 23 .........L.G.L.#
9170: 0F 4C FF AB 0F 2E FF 23-0F 1F DF 47 0F 0F 0F 8F .L.....#...G....
9180: CF 0F 0F 0F 73 0F 0F 0F-D0 CF 0F 0F 70 F3 0F 0F ....s.......p...
9190: D0 F0 CF 0F 70 70 FB 0F-D0 F0 D8 CF 70 70 F8 73 ....pp......pp.s
91A0: 0F 0F 0F 3F 0F 0F 0F DC-0F 0F 3F A0 0F 0F CC 50 ...?......?....P
91B0: 0F 3F 62 B3 0F CC A0 FC-3F 20 73 E0 DC 50 FC 10 .?b.....? s..P..
91C0: CF 0F 0F 0F 73 0F 0F 0F-B3 CF 0F 0F CC 73 0F 0F ....s........s..
91D0: 20 B3 CF 0F D8 CC B3 0F-B3 20 73 CF DC 50 DC 33  ........ s..P.3
91E0: FC F0 FC F8 FB F0 F3 F8-F8 FC F0 F4 F8 FB F0 F3 ................
91F0: FC F8 FC F0 FB F8 FF F0-F8 FC FC FC F8 F3 F3 FF ................
9200: FC F0 FF FF FB F0 F7 FF-F8 FC F4 FF F8 FB F4 F3 ................
9210: FC F8 FC F0 FB F8 F3 F0-F8 F4 F0 FC F8 F3 F0 FB ................
9220: FC F0 FC F8 F3 F0 FB F8-F3 FC F8 FC FF FF F8 F3 ................
9230: FF FF FC F0 FB FF FF F0-F8 FF FC FC F8 F3 F3 FF ................
9240: FC F0 FC F8 FF F0 FB F8-FC FC F8 FC F3 FF F8 F3 ................
9250: FF FF FC F0 FB FF FF F0-F8 FF FF FC F8 F3 FF FF ................
9260: FC F0 FC F8 FF F0 FB F8-FC FC F8 FC F3 FF F8 F3 ................
9270: FF FF FC F0 FB FF FF F0-F8 FF FC FC F8 F3 F3 F3 ................
9280: FC F0 FF F8 F3 F0 FF F8-F0 FC FC FC F0 FB F3 FB ................
9290: FC F8 FF F8 FB F8 FF F8-F8 FC FC FC F8 F3 F3 FB ................
92A0: FC F0 FC F8 F3 F0 FB F8-F0 FC F8 FC F3 33 F0 F3 .............3..
92B0: CC 00 FC F0 FB 00 33 F0-F8 CC FD FC F8 F3 F3 F3 ......3.........
92C0: FC F0 FF F8 FB F0 FF F8-F8 FC FC FC F8 FB F3 FB ................
92D0: FC F8 FF F8 FB F8 FF F8-F8 FC FC FC F8 F3 F3 FB ................
92E0: FC F0 FF F8 FB F0 FF F8-F8 FC FC FC F8 FB F3 FB ................
92F0: FC F8 FF F8 3F F8 FF F8-0F FC FF FC 0F 3F CF 3F ....?........?.?
9300: FC F0 F0 F0 33 F0 F0 F0-00 FC F0 F0 00 33 F0 F0 ....3........3..
9310: 00 33 F0 F0 00 FF F0 F0-33 FF F0 F0 FF FF F0 F0 .3......3.......
9320: 00 33 FF CC 00 FF FF 00-33 FF CC 00 FF FF 00 00 .3......3.......
9330: FF CC 00 00 FF 00 00 00-CC 00 00 00 00 00 00 00 ................
9340: FF CC FC F0 FF 00 33 F0-CC 00 00 FC 00 00 00 33 ......3........3
9350: 00 00 00 33 00 00 00 FF-00 00 33 FF 00 00 FF FF ...3......3.....
9360: FF CC 00 00 FF 00 00 00-CC 00 00 00 00 00 00 00 ................
9370: 00 00 00 33 00 00 00 FF-00 00 33 FF 00 00 FF FF ...3......3.....
9380: 00 00 00 33 00 00 00 FF-00 00 33 FF 00 00 FF FF ...3......3.....
9390: 00 33 FF CC 00 FF FF 00-33 FF CC 00 FF FF 00 00 .3......3.......
93A0: F0 F0 CC 88 F0 F0 F3 88-F0 F0 F0 CC F0 F0 F0 F3 ................
93B0: F0 F0 F0 F0 F0 F0 F0 F0-F0 F0 F0 F0 F0 F0 F0 F0 ................
93C0: FF FF F0 F0 FF FC F0 F0-FF F0 F0 F0 FC F0 F0 F0 ................
93D0: F0 F0 F0 F0 F0 F0 F0 F0-F0 F0 F0 F0 F0 F0 F0 F0 ................
93E0: 0D 3F CF 0B 07 CF 3F 0D-3F 0F 0F CF CF 06 0E 3F .?....?.?......?
93F0: CF 0B 0D 3F 3F 0F 07 CF-0F CF 3F 0F 0E 3F CF 0E ...??.....?..?..
9400: FC F0 F0 F0 37 F0 F0 F0-3F FC F0 F0 CF 37 F0 F0 ....7...?....7..
9410: CF 0B FC F0 3F 0F 37 F0-0F CF 3F FC 0E 3F CF 3F ....?.7...?..?.?
9420: F8 F0 F0 F0 FC F0 F0 F0-FE F0 F0 F0 76 F0 F0 F0 ............v...
9430: 77 F0 F0 F0 77 F8 F0 F0-57 F8 F0 F0 47 FC F0 F0 w...w...W...G...
9440: F0 F0 F0 F1 F0 F0 F0 F7-F0 F0 F0 EE F0 F0 F1 AE ................
9450: F0 F0 F3 2E F0 F0 F7 2E-F0 F0 DD 2E F0 F1 99 2E ................
9460: 47 FC F0 F0 47 FE F0 F0-47 FE F0 F0 47 FF F0 F0 G...G...G...G...
9470: 47 BB F0 F0 47 BB F8 F0-47 99 F8 F0 CF 99 FC F0 G...G...G.......
9480: F0 F1 11 2E F0 F3 11 2E-F0 F7 11 2E F0 EF DD 2E ................
9490: F0 CF 3F 2E F0 FF 0F EE-F0 CC CF FF F0 FF 33 FF ..?...........3.
94A0: FF 11 FC F0 FF CC FE F0-7F 3F FE F0 7F 0F FF F0 .........?......
94B0: FF CF 7F F0 FF 33 7F F0-FF CC FF F0 FF 3F 33 F0 .....3.......?3.
94C0: F0 CF CC FF F0 CF 3F FF-F0 FF 0F EF F0 CC CF EF ......?.........
94D0: F0 CC 33 FF F0 CC 11 7F-F0 CC 11 3F F0 CC 11 2E ..3........?....
94E0: 77 0F FF F0 47 CF 3F F0-47 BB 3F F0 47 88 FF F0 w...G.?.G.?.G...
94F0: 47 88 33 F0 47 88 33 F0-47 88 33 F0 CF 88 33 F0 G.3.G.3.G.3...3.
9500: F0 CC 11 2E F0 CC 11 2E-F0 FF 11 2E F0 CC DD 2E ................
9510: F0 CC 33 2E F0 CC 11 EE-F0 CC 11 3F F0 CC 11 2E ..3........?....
9520: 77 00 33 F0 47 CC 33 F0-47 BB 33 F0 47 88 FF F0 w.3.G.3.G.3.G...
9530: 47 88 33 F0 47 88 33 F0-47 88 33 F0 CF 88 33 F0 G.3.G.3.G.3...3.
9540: F0 CC 11 2E F0 CC 11 2E-F0 FF 11 2E F0 F3 DD 2E ................
9550: F0 F0 FF 2E F0 F0 F3 EE-F0 F0 F0 FF F0 F0 F0 F3 ................
9560: FF 00 33 F0 F3 CC 33 F0-F0 FF 33 F0 F0 F3 FF F0 ..3...3...3.....
9570: F0 F0 FF F0 F0 F0 F3 F0-F0 F0 F0 F0 F0 F0 F0 F0 ................
9580: 0F 7F F0 9F 8F 0F FC 9B-AF 0F 3F 9F 2F 8F 0F 9B ..........?./...
9590: CF AF 0F 7F 33 2F 8F 1F-00 CF AF 3F CC 33 2F 5D ....3/.....?.3/]
95A0: 33 00 DF 33 0C CC 22 DD-3F 33 33 55 CF 0C DD 55 3..3..".?33U...U
95B0: 0F 3F 5D 55 0F CE 5D 33-3F 06 4C DF CF 06 7F 1B .?]U..]3?.L.....
95C0: F0 F0 F0 F3 F0 F0 F0 CF-F0 F0 F3 47 F0 F0 CC 33 ...........G...3
95D0: F0 F1 33 00 F0 F7 0C CC-F1 8F 0F 33 EF 0F 0F 0C ..3........3....
95E0: F1 2F DF FC F1 2F 6F 7C-F0 9F 8F F8 F0 8F 8F F8 ./.../o|........
95F0: F0 EF BF F8 F0 BF EF F8-F0 AF AF F8 F0 AF AF F8 ................
9600: F0 F1 F8 F0 F0 E7 7E F0-F1 8F 1F F8 E7 6F 6F 7E ......~......oo~
9610: 9F 1F 8F 9F BF 0F 0F DF-9F 1F 8F 9F E7 EF 7F 7E ...............~
9620: F3 AF AF FE E7 6F BF 3F-F7 9F CF FF C7 EF 3F 1B .....o.?......?.
9630: C7 3F EE 1B F3 0F 8A 7E-F0 CF 9B F8 F0 F3 FE F0 .?.....~........
9640: F0 AF AF F8 F0 AF AF F8-F0 AF AF F8 F0 AF AF F8 ................
9650: F0 AF AF F8 F0 AF AF F8-F0 AF AF F8 F0 AF AF F8 ................
9660: EF 0F DF 7F F3 8F DF FC-F1 EF FF F8 E7 7F EF 7E ...............~
9670: 9F 1F 8F 9F BF 0F 0F DF-9F 1F 8F 9F E7 EF 7F 7E ...............~
9680: F0 C5 0F F8 F0 8B 0F 7C-F1 09 0F FC F1 0D EF BE .......|........
9690: F1 07 EF 3A F7 CF 0F BE-F1 FF CF 1F F0 F3 EF BE ...:............
96A0: F0 F0 F0 F1 F0 F0 F0 F3-F0 F0 F0 F7 F0 F0 F0 E6 ................
96B0: F0 F0 F0 EE F0 F0 F1 EE-F0 F0 F1 AE F0 F0 F3 2E ................
96C0: F8 F0 F0 F0 FE F0 F0 F0-77 F0 F0 F0 57 F8 F0 F0 ........w...W...
96D0: 47 FC F0 F0 47 FE F0 F0-47 BB F0 F0 47 99 F8 F0 G...G...G...G...
96E0: F0 F0 F3 2E F0 F0 F7 2E-F0 F0 F7 2E F0 F0 FF 2E ................
96F0: F0 F0 DD 2E F0 F1 DD 2E-F0 F1 99 2E F0 F3 99 3F ...............?
9700: 47 88 F8 F0 47 88 FC F0-47 88 FE F0 47 BB 7F F0 G...G...G...G...
9710: 47 CF 3F F0 77 0F FF F0-FF 3F 33 F0 FF CC FF F0 G.?.w....?3.....
9720: F0 F3 88 FF F0 F7 33 FF-F0 F7 CF EF F0 FF 0F EF ......3.........
9730: F0 EF 3F FF F0 EF CC FF-F0 FF 33 FF F0 CC CF FF ..?.......3.....
9740: FF 33 3F F0 FF CF 3F F0-7F 0F FF F0 7F 3F 33 F0 .3?...?......?3.
9750: FF CC 33 F0 EF 88 33 F0-CF 88 33 F0 47 88 33 F0 ..3...3...3.G.3.
9760: F0 FF 0F EE F0 CF 3F 2E-F0 CF DD 2E F0 FF 11 2E ......?.........
9770: F0 CC 11 2E F0 CC 11 2E-F0 CC 11 2E F0 CC 11 3F ...............?
9780: 47 88 33 F0 47 88 33 F0-47 88 FF F0 47 BB 33 F0 G.3.G.3.G...G.3.
9790: 47 CC 33 F0 77 88 33 F0-CF 88 33 F0 47 88 33 F0 G.3.w.3...3.G.3.
97A0: F0 CC 00 EE F0 CC 33 2E-F0 CC DD 2E F0 FF 11 2E ......3.........
97B0: F0 CC 11 2E F0 CC 11 2E-F0 CC 11 2E F0 CC 11 3F ...............?
97C0: 47 88 33 F0 47 88 33 F0-47 88 FF F0 47 BB FC F0 G.3.G.3.G...G...
97D0: 47 FF F0 F0 77 FC F0 F0-FF F0 F0 F0 FC F0 F0 F0 G...w...........
97E0: F0 CC 00 FF F0 CC 33 FC-F0 CC FF F0 F0 FF FC F0 ......3.........
97F0: F0 FF F0 F0 F0 FC F0 F0-F0 F0 F0 F0 F0 F0 F0 F0 ................
9800: FC F0 F0 F0 3F F0 F0 F0-CF FC F0 F0 3F 3F F0 F0 ....?.......??..
9810: 0F CF FC F0 CF 3F 3F F0-FF 1F CF FC 3F DF 7F 3F .....??.....?..?
9820: CF FF 5F CF F3 3F DF 3F-F0 CF FF 0F F0 F3 3F CF .._..?.?......?.
9830: F0 F0 CF FF F0 F0 F3 3F-F0 F0 F0 CF F0 F0 F0 F3 .......?........
9840: 3F 57 FF 3F CC 77 CF FC-00 FF 3F F0 33 CF FC F0 ?W.?.w....?.3...
9850: FF 3F F0 F0 CF FC F0 F0-3F F0 F0 F0 FC F0 F0 F0 .?......?.......
9860: F0 F0 F0 F3 F0 F0 F0 CF-F0 F0 F3 3F F0 F0 CF CC ...........?....
9870: F0 F3 3F 00 F0 CF CC 33-F3 3F 4C FF CF DF 7F CF ..?....3.?L.....
9880: F0 F0 F0 F0 F0 F0 F0 F0-F0 F0 F0 F0 F0 F0 F0 F0 ................
9890: F0 F0 F0 F3 F0 F0 F0 CC-F0 F0 F3 00 F0 F0 CC 00 ................
98A0: 00 33 00 33 00 CC 00 CC-33 00 33 00 CC 00 CC 00 .3.3....3.3.....
98B0: 00 33 00 00 00 CC 00 00-33 00 00 00 CC 00 00 00 .3......3.......
98C0: F0 F0 F0 F0 F0 F0 F0 F0-F0 F0 F0 F0 FC F0 F0 F0 ................
98D0: 33 F3 FC F0 00 CC 33 F0-33 00 00 FC CC 00 00 33 3.....3.3......3
98E0: F0 F0 F0 F0 F0 F0 F0 F0-F0 F0 F0 F0 FC F0 FC F0 ................
98F0: 33 F3 33 F3 00 CC 00 CC-33 00 33 00 CC 00 CC 00 3.3.....3.3.....
9900: 00 33 00 33 00 CC 00 CC-33 00 33 00 CC 00 CC 00 .3.3....3.3.....
9910: 00 33 00 33 00 CC 00 CC-33 00 33 00 CC 00 CC 00 .3.3....3.3.....
9920: F0 F0 F0 F3 F0 F0 F0 CC-F0 F0 F3 00 F0 F0 CC 00 ................
9930: F0 F0 CC 00 F0 F0 FF 00-F0 F0 FF CC F0 F0 FF FF ................
9940: 33 FF CC 00 00 FF FF 00-00 33 FF CC 00 00 FF FF 3........3......
9950: 00 00 33 FF 00 00 00 FF-00 00 00 33 00 00 00 00 ..3........3....
9960: F0 F3 33 FF F0 CC 00 FF-F3 00 00 33 CC 00 00 00 ..3........3....
9970: CC 00 00 00 FF 00 00 00-FF CC 00 00 FF FF 00 00 ................
9980: 00 00 33 FF 00 00 00 FF-00 00 00 33 00 00 00 00 ..3........3....
9990: CC 00 00 00 FF 00 00 00-FF CC 00 00 FF FF 00 00 ................
99A0: CC 00 00 00 FF 00 00 00-FF CC 00 00 FF FF 00 00 ................
99B0: 33 FF CC 00 00 FF FF 00-00 33 FF CC 00 00 FF FF 3........3......
99C0: F0 F0 F0 F0 F0 F0 F0 F0-F0 F0 F0 F0 F0 F3 F0 F3 ................
99D0: FC CC FC CC 33 00 33 00-00 CC 00 CC 00 33 00 33 ....3.3......3.3
99E0: CC 00 CC 00 33 00 33 00-00 CC 00 CC 00 33 00 33 ....3.3......3.3
99F0: CC 00 CC 00 33 00 33 00-00 CC 00 CC 00 33 00 33 ....3.3......3.3
9A00: CC 00 00 00 F3 00 00 00-F0 CC 00 00 F0 F3 00 00 ................
9A10: F0 F0 CC 00 F0 F0 F3 00-F0 F0 F0 CC F0 F0 F0 F3 ................
9A20: F0 F0 F0 F0 F0 F0 F0 F0-F0 F0 F0 F0 F0 F0 F0 F0 ................
9A30: FC F0 F0 F0 33 F0 F0 F0-00 FC F0 F0 00 33 F0 F0 ....3........3..
9A40: CC 00 CC 00 33 00 33 00-00 CC 00 CC 00 33 00 33 ....3.3......3.3
9A50: 00 00 CC 00 00 00 33 00-00 00 00 CC 00 00 00 33 ......3........3
9A60: F0 F0 F0 F0 F0 F0 F0 F0-F0 F0 F0 F0 F0 F0 F0 F3 ................
9A70: F0 F3 FC CC F0 CC 33 00-F3 00 00 CC CC 00 00 33 ......3........3
9A80: 0F FF FF FF 0F 7F FF FF-0F 3F FF FF 0F 1F FF FF .........?......
9A90: CF 0F FF CF BF 0F FF 1F-8F CF CF 5F 8F 3F 1F 5F ..........._.?._
9AA0: FF FF FE F0 FF FF DF F0-FF FF BF F8 FF FF 7F FC ................
9AB0: FF EF FF FC FF DF FF FE-FF BF FF FE 3F 7F FF FE ............?...
9AC0: F0 F0 F0 F0 F0 F0 F0 F0-F0 F0 F0 F0 FC F0 F0 F0 ................
9AD0: 7F F0 F0 F0 7F FC F0 F0-FF FF F0 F0 FF FF FC F0 ................
9AE0: 0F 0F 0F F0 8F 0F 0F 3C-6F 0F 1F 8F 1F 8F FF FF .......<o.......
9AF0: 1F BF FF FF 7F BF FF FF-FF BF FF EF FF BF FF EF ................
9B00: F0 F0 F0 EF F0 F0 F7 1F-F0 F1 8F 0F F0 F7 0F 0F ................
9B10: F1 8F 6F 0F E7 0F 1F 8F-8F 0F 0F 3F 0F 0F 0F BF ..o........?....
9B20: 9F BF FF DF 8F BF FF DF-0F BF FF BF 1F BF FF BF ................
9B30: 9F BF FF 7F 9F BF FF 7F-FF BC E1 0F EF 78 F0 C3 .............x..
9B40: 0F 0F 1F BF 0F 0F FF BF-0F 3F FF BF 0F FF FF BF .........?......
9B50: 0F FF FF BF 3F FF FF BF-3F FF FF BF FF FF FF BF ....?...?.......
9B60: FF FF FF BF FF FF FF 8F-FF FF FF F0 7F FF FE F0 ................
9B70: 7F FF F8 F0 BF FF F0 F0-BF FE F0 F0 DF FC F0 F0 ................
9B80: DF F8 F0 F0 FF F0 F0 F0-FF F0 F0 F0 FE F0 F0 F0 ................
9B90: FE F0 F0 F0 FC F0 F0 F0-F8 F0 F0 F0 F8 F0 F0 F0 ................
9BA0: C7 0F 1F FF C7 0F 3F FF-8F 0F 3F FF 8F 0F 7F FF ......?...?.....
9BB0: 8F 0F 7F FF 8F 0F 7F FF-8F 0F FF FF 8F 0F FF FF ................
9BC0: F0 C7 0F 5F F0 8F 0F 2F-F1 0F 0F 2F F1 0F 0F 7F ..._.../.../....
9BD0: E3 0F 0F FF E3 0F 0F FF-C7 0F 1F FF C7 0F 1F FF ................
9BE0: F0 F0 F0 C7 F0 F0 F1 8F-F0 F0 E3 0F F0 F0 C7 0F ................
9BF0: F0 F0 8F 0F F0 F1 8F 0F-F0 F1 6F 0F F0 E3 1F 8F ..........o.....
9C00: CF 0F FF FF BF 0F FF FF-8F CF FF FF 8F 3F 0F 0F .............?..
9C10: 8F 0F FF FF 8F 0F FF FF-8F 0F FF FF 8F 0F FF FF ................
9C20: FF FF 9F FC FF FC 9F FC-FF F0 9F FC FC F0 9F FC ................
9C30: F0 F0 9F FC F0 F0 9F FC-F0 F0 9F FC F0 F0 FF FC ................
9C40: F0 F0 F0 30 F7 F8 E0 B8-C7 F8 E0 98 C7 F8 E0 DC ...0............
9C50: C7 F8 F0 B8 C7 F8 F0 F0-C7 F8 F1 FE C7 F8 F1 3E ...............>
9C60: FF F0 F1 3E 66 F8 F1 3E-CC 74 F1 3E F3 33 F9 3E ...>f..>.t.>.3.>
9C70: F0 CC 75 3E F0 C4 33 3F-F0 E2 77 FE F0 F3 F8 FC ..u>..3?..w.....
9C80: C0 F0 F0 F0 D1 70 F1 FE-91 70 F1 3E B3 70 F1 3E .....p...p.>.p.>
9C90: D1 F0 F1 3E F0 F0 F1 3E-F7 F8 F1 3E C7 F8 F1 3E ...>...>...>...>
9CA0: C7 F8 F1 3E C7 F8 F1 3E-C7 F8 F1 3E C7 F8 F1 3E ...>...>...>...>
9CB0: C7 F8 F1 3E C7 F8 F1 3E-C7 F8 F1 3E C7 F8 F1 3E ...>...>...>...>
9CC0: C7 F8 F1 FE C7 F8 E2 FC-C7 F8 C4 76 C7 FB 99 F8 ...........v....
9CD0: C7 CC 76 F0 CF 88 74 F0-F7 CC F8 F0 F3 F3 F8 F0 ..v...t.........
9CE0: F0 F0 F0 F3 F0 F0 F0 CD-F0 F0 F3 CF F0 F0 CE 3F ...............?
9CF0: F0 F3 0D 3F F0 CF 07 CF-F3 CF 3F 0F CE 3F CF 0E ...?......?..?..
9D00: F7 F1 F8 F0 BB EF F8 F0-88 CF FC F0 CC 23 7C F0 .............#|.
9D10: FF 23 FF F0 9F EF BB FC-9D F3 00 FF 9F F0 CC 33 .#.............3
9D20: CF FF 5F CF BF 3F DF 3F-8F CF FF 0F 8F 7F 3F CF .._..?.?......?.
9D30: CF 7F CF FF F3 7F F3 3F-E3 FF F0 CF E3 3F F0 F3 .......?.....?..
9D40: E3 1F F0 F0 F3 1F F0 F0-F0 DF F0 F0 F0 F3 F0 F0 ................
9D50: F0 F0 F0 F0 F0 F0 F0 F0-F0 F0 F0 F0 F0 F0 F0 F0 ................
9D60: F0 F0 9F FC F0 F0 F7 F8-F0 F0 F0 F0 F0 F0 F0 F0 ................
9D70: F0 F0 F0 F0 F0 F0 F0 F0-F0 F0 F0 F0 F0 F0 F0 F0 ................
9D80: FC F0 F0 F0 3F F0 F0 F0-0F FC F0 F0 0F 3F F0 F0 ....?........?..
9D90: 0F 0F FC F0 0F 0F 3F F0-0F 0F 0F FC 0F 0F 0F 3E ......?........>
9DA0: 3F 57 FF 3F CC 77 CF DF-00 FF 3F 1F 33 CF EF 1F ?W.?.w....?.3...
9DB0: FF 3F EF 3F CF FC EF FC-3F F0 FF 74 FC F0 CC 74 .?.?....?..t...t
9DC0: F0 F0 88 74 F0 F0 88 FC-F0 F0 BB F0 F0 F0 FC F0 ...t............
9DD0: F0 F0 F0 F0 F0 F0 F0 F0-F0 F0 F0 F0 F0 F0 F0 F0 ................
9DE0: CF 09 02 05 F3 8F 02 05-F0 F7 02 05 F0 F0 CE 05 ................
9DF0: F0 F0 E3 05 F0 F0 F1 0D-F0 F0 F0 CF F0 F0 F0 F3 ................
9E00: 06 0D 0D 3B 06 0E 1D FC-07 8E FE F0 0B BF F0 F0 ...;............
9E10: 0B FC F0 F0 0B F8 F0 F0-3B F0 F0 F0 FC F0 F0 F0 ........;.......
9E20: 8E 0D 0B 17 06 0D 0B 17-06 0D 0B 17 06 0D 0B 17 ................
9E30: 06 0D 0B 17 06 0D 0B 17-06 0D 0B 17 0E 0D 0B 07 ................
9E40: F0 F0 F0 F3 F0 F0 F0 CF-F0 F0 F3 0F F0 F0 CF 0F ................
9E50: F0 F3 0F 0F F0 CF 0F 0F-F3 0F 0F 0F C7 0F 0F 0F ................
9E60: 0F 0F 0F 0F 0F 0F 0F 0F-0F 0F 0F 0F 0F 0F 0F 0F ................
9E70: 0F 0F 0F 0F 0F 0F 0F 0F-0F 0F 0F 0F 0F 0F 0F 0F ................
9E80: 0F 0F 0F 3E 0F 0F 0F BF-0F 0F 3F 17 0F 0F CF 17 ...>......?.....
9E90: 0F 2F 0B 17 0F CD 0B 17-2E 0D 0B 17 CC 0D 0B 17 ./..............
9EA0: E7 0F 0F 0F 9F 0F 0F 0F-8C CF 0F 0F 8C 3B 0F 0F .............;..
9EB0: 8C 09 4F 0F 8C 09 33 0F-8C 09 02 4F 8C 09 02 37 ..O...3....O...7
9EC0: F0 F1 FC F0 F0 F7 FF F0-F0 97 FF F0 F1 AF 7F F0 ................
9ED0: F7 9D 7F F0 17 9D 7F F0-07 1D 7F F8 17 9D 7F FE ................
9EE0: 83 55 37 FF 81 19 9F FF-E0 04 67 7F F0 15 09 7F .U7.......g.....
9EF0: F0 15 0F 7F F0 15 6F 7F-F0 15 7F FC F0 15 7F F0 ......o.........
9F00: F0 15 7F F0 F0 15 7F F0-F0 15 7F F0 F0 15 7F F0 ................
9F10: F0 15 7F F0 F0 17 7F F0-F0 81 7F F0 F0 E0 74 F0 ..............t.
9F20: 00 00 00 00 00 00 00 00-00 00 00 00 00 00 00 00 ................
9F30: 00 00 00 00 00 00 00 00-00 00 00 00 00 00 00 00 ................
9F40: 8C 09 02 04 8C 09 02 04-8C 09 02 04 8C 09 02 04 ................
9F50: 8C 09 02 04 8C 09 02 04-8C 09 02 04 0C 09 02 04 ................
9F60: F1 0F 0F F8 E7 7F EF 7E-9F FF FF 9F BF FF FF DF .......~........
9F70: CF CF 3F 3F E7 3F CF 7E-F3 8F 1F FC F1 FF FF F8 ..??.?.~........
9F80: 00 2E 00 00 01 DF 2E 00-13 89 9B 00 13 89 CF 88 ................
9F90: 13 89 BF 4C 13 EF 6E 26-01 DF 6E 26 00 2E 6E 26 ...L..n&..n&..n&
9FA0: 00 00 6E 04 00 00 37 08-00 00 03 00 00 00 00 00 ..n...7.........
9FB0: 00 77 00 00 00 47 CC 00-77 EF 3F EE 8F 1F 8F 1F .w...G..w.?.....
9FC0: 33 EF 4F 1F 8F 0F 4F 6E-77 8F 2F 1F 47 0F 0F 1F 3.O...Onw./.G...
9FD0: 33 EF 1F EE 00 8F EE 00-00 77 00 00 00 00 00 00 3........w......
9FE0: 01 4C 00 00 17 AE 00 00-7F 4C 00 00 6F 3F 00 44 .L.......L..o?.D
9FF0: 9F E9 CC BF FF EF 3F 6F-66 77 8F 3D 00 11 EF 6A ......?ofw.=...j
A000: 00 00 77 AE 00 00 11 CC-00 00 00 00 00 00 00 00 ..w.............
A010: 00 11 88 00 00 23 6E 00-00 47 1F CC 66 57 0F 2E .....#n..G..fW..
A020: 9F 8F CF DF 0F 6F 1F AE-0F 1F 3F 44 8F 6F 2E 00 .....o....?D.o..
A030: 67 AF 4C 00 11 8F 88 00-00 77 00 00 00 00 00 00 g.L......w......
A040: BF F0 F3 33 CC FC F0 FF-BF 33 F0 DF 9D CC FC 9B ...3.....3......
A050: 9D F3 33 9F 9F F0 CC 9B-DD F0 F3 9F 3F F0 F0 9B ..3.........?...
A060: EF FD 6F CC 17 AF F9 A6-AB 6F FE BF FF 13 BF EF ..o......o......
A070: F3 AF 6F 5F F0 F7 07 BF-71 FF DF F4 30 FE F2 E0 ..o_....q...0...
A080: 00 00 00 00 00 00 00 00-00 00 00 00 00 00 00 00 ................
A090: 00 00 00 00 00 00 00 00-00 00 00 00 00 00 00 00 ................
A0A0: 00 00 00 00 00 00 00 00-00 00 00 00 00 00 00 00 ................
A0B0: 00 00 00 00 00 00 00 00-00 00 00 00 00 00 00 00 ................
A0C0: 8F 0F 0F FF 8F 0F 1F FF-8F 0F 3F FF 8F 0F 7F FF ..........?.....
A0D0: C7 0F FF CF BF 0F FF 1F-8F CF CF 5F 8F 3F 1F 5F ..........._.?._
A0E0: F0 C7 0F 0F F0 CF 0F 0F-F1 2F 0F 0F E3 1F 0F 0F ........./......
A0F0: E3 0F 8F 0F C7 0F 4F 0F-C7 0F 2F 0F C7 0F 1F 3F ......O.../....?
A100: F0 F0 F0 F0 F0 F0 F0 F0-F0 F0 F0 F0 F0 F0 F0 F3 ................
A110: F0 F0 F0 DF F0 F0 F3 1F-F0 F0 CF 0F F0 F3 0F 0F ................
A120: F0 FF FF FF F3 FF FF EF-FF FF FF 9F EF 7F EF 7F ................
A130: 0F 0F EF 7F 0F 0F 2F 1F-8F 0F 2F 0F 8F 0F 2F 0D ....../.../.../.
A140: F9 F0 F0 F0 F7 FC F0 F0-FF FF F8 F0 FF EF 7E F0 ..............~.
A150: FF 9F FF F8 EF 7F FF FE-3F FF FF FF 2F FF FF FF ........?.../...
A160: 4F 0F 2F 09 4F 0F 2F 01-2F 0F 2F 00 2F 0F 2F 08 O./.O./././././.
A170: 1F 0F 2F 09 1F 0F 2F 09-FF F8 E3 0F FC F0 F0 87 ../.../.........
A180: 2F 7F FF FF 2F 0F FF FF-2F 0F 3F FF 2F 0F 0F FF /.../.../.?./...
A190: 2F 0F 0F FF 2F 0F 0F 3F-2F 0F 0F 3F 2F 0F 0F 0F /.../..?/..?/...
A1A0: EF 0F 0F 0F F3 0F 0F 0F-F0 8F 0F 0F F0 E7 0F 1F ................
A1B0: F0 F1 0F 1F F0 F0 8F 2F-F0 F0 C7 2F F0 F0 E3 4F ......./.../...O
A1C0: F0 F0 F1 4F F0 F0 F0 8F-F0 F0 F0 8F F0 F0 F0 C7 ...O............
A1D0: F0 F0 F0 C7 F0 F0 F0 E3-F0 F0 F0 F1 F0 F0 F0 F1 ................
A1E0: 8F 0F FF CF 8F 0F FF 3F-8F 0F CF FF FF FF 3F FF .......?......?.
A1F0: 8F 0F FF FF 8F 0F FF FF-8F 0F FF FF 8F 0F FF FF ................
A200: 0F 7F FF FE 0F 3F FF FE-0F 3F FF FF 0F 1F FF FF .....?...?......
A210: 0F 1F FF FF 0F 1F FF FF-0F 0F FF FF 0F 0F FF FF ................
A220: 5F FF FE F0 BF FF FF F0-BF FF FF F8 1F FF FF F8 _...............
A230: 0F FF FF FC 0F FF FF FC-0F 7F FF FE 0F 7F FF FE ................
A240: FE F0 F0 F0 FF F8 F0 F0-FF FC F0 F0 FF FE F0 F0 ................
A250: FF FF F0 F0 FF EF F8 F0-FF 9F F8 F0 EF 7F FC F0 ................
A260: 8F 0F FF FF 8F 0F FF FF-8F 0F FF FF C7 0F FF CF ................
A270: BF 0F FF 1F 8F CF CF 5F-8F 3F 1F 5F 8F 0F DF 5F ......._.?._..._
A280: F6 F0 F6 F0 9F F8 9F F0-E7 7E EF F8 E7 9F 1F F8 .........~......
A290: F3 AF 0F 7C F3 CF 01 3E-F1 DF 0E 7E F0 CF FF 5F ...|...>...~..._
A2A0: F1 CF 7F 1F F0 EF 0F 1B-F0 FF EE 5F F0 CC 9F 7E ..........._...~
A2B0: F0 E6 57 FE F0 E6 57 DF-F0 F3 57 5F F0 F1 EF 3E ..W...W...W_...>
A2C0: F0 E3 F8 F0 F0 C7 7C F0-F0 E3 F8 F0 F1 EF FF F0 ......|.........
A2D0: E2 33 88 F8 D7 00 11 7C-E3 AA AB F8 F1 DF 7F F0 .3.....|........
A2E0: 00 00 00 00 00 00 00 00-00 00 00 00 00 00 00 00 ................
A2F0: 00 00 00 00 00 00 00 00-00 00 00 00 00 00 00 00 ................
; -------------- fin de los gráficos de la abadía ------------------------

; ------------ inicio de los gráficos de los objetos --------------------
A300: 00 00 11 FF 88 00 00 33-FF CC 00 00 77 CB 6A 00 .......3....w.j.
A310: 00 57 FF 6E 00 00 75 7F-6E 00 00 FF B7 2E 00 77 .W.n..u.n......w
A320: F3 DF 4C 11 F8 F2 DF C4-32 F8 E3 FF CC FC F8 F3 ..L.....2.......
A330: ED EE F8 F4 F0 FF EA F9-FE F0 F0 F7 F8 D5 F3 FD ................
A340: FD F8 D5 CF 7A F1 F8 D5-FF 1F F1 77 99 ED 97 F1 ....z......w....
A350: BF 11 FF B7 F1 8F 88 FF-FE E2 57 5D F7 FF C4 57 ..........W]...W
A360: 99 F3 FF 88 33 32 F0 F4-88 00 32 F0 F4 88 00 32 ....32....2....2
A370: F0 F4 C4 00 32 F0 F4 C4-00 32 F0 F4 C4 00 76 F0 ....2....2....v.
A380: F8 C4 00 BF F0 F0 88 00-BD F0 F0 88 00 BF F0 F1 ................
A390: 00 00 9F F1 FF 00 00 57-F2 F1 00 00 22 F8 FF 00 .......W...."...
A3A0: 00 00 75 EE 00 00 00 33-3D 88 00 00 00 8F 4C 00 ..u....3=.....L.
A3B0: 00 00 77 88 00 00 77 EE-00 00 00 FF FF 00 00 11 ..w...w.........
A3C0: FE 1E 88 00 11 7F DF 88-00 11 D7 DF 88 00 11 ED ................
A3D0: CF 88 00 00 FF 5F 00 00-77 FB 7D 00 00 F8 BF FF ....._..w.}.....
A3E0: 00 11 F0 FF B7 00 32 F0-F3 EE 00 74 F0 F1 FD 00 ......2....t....
A3F0: 74 F0 F0 F1 00 32 F0 F0-F1 00 75 FC F0 E2 00 74 t....2....u....t
A400: F7 FF EE CC 74 FB FF EF-2E 74 F0 FF EF 9F 74 F1 ....t....t....t.
A410: FF EF 5F 32 E3 3F FD EE-11 E3 1F FC C4 11 FA 2F .._2.?........./
A420: FB 88 11 F7 5F E2 00 11-F1 FB E2 00 11 F0 F1 E2 ...._...........
A430: 00 11 F0 F1 E2 00 00 F8-F1 E2 00 00 F8 F0 E2 00 ................
A440: 00 F8 F0 E2 00 00 F8 F1-FF 00 00 FF FF 9F 00 00 ................
A450: 32 3D FF 00 00 33 CB 88-00 00 00 77 00 00 00 00 2=...3.....w....
A460: 77 EE 00 00 00 FF FF 00-00 11 FE 1E 88 00 11 7F w...............
A470: DF 88 00 11 D7 DF 88 00-11 ED CF 88 00 00 FF 5F ..............._
A480: 00 00 77 FB 7D 00 00 F8-BF FF 00 00 F8 FF B7 00 ..w.}...........
A490: 11 F0 F3 EE 00 11 F0 F0-E2 00 11 F0 F0 F7 CC 11 ................
A4A0: F0 F0 C7 2E 11 FF FF ED-6E 00 FC F3 F7 4C 00 FC ........n....L..
A4B0: F4 F3 4C 00 FC F0 F1 CC-00 76 F0 F1 88 00 33 F0 ..L......v....3.
A4C0: F1 00 00 33 FF FF 00 00-74 FF EA 00 00 74 F7 E2 ...3....t....t..
A4D0: 00 00 74 F1 E2 00 00 74-F1 E2 00 11 F8 F1 E2 00 ..t....t........
A4E0: 11 F0 F1 E2 00 33 F0 F0-E2 00 57 F0 F8 EE 77 57 .....3....W...wW
A4F0: F8 F5 F1 9E 65 FE F0 F7-3F 23 7F F8 CF EE 32 1F ....e...?#....2.
A500: 77 57 CC 11 EE 00 33 00-00 11 FF CC 00 00 67 F7 wW....3.......g.
A510: A6 00 00 76 FF 2E 00 00-77 FF 6E 00 00 33 EF 5F ...v....w.n..3._
A520: 00 00 11 F3 5F 00 00 77-3F 6E 00 00 FB BF 4C 00 ...._..w?n....L.
A530: 11 F0 FF DD 00 76 F0 F1-AB CC FA F0 FE D5 2E FA .....v..........
A540: F3 F0 E3 1F F9 F4 F0 F1-9F 74 F8 F0 F1 DF 76 F0 .........t....v.
A550: F0 FF F3 F9 FC F3 FE F9-F9 FF FF F8 F9 F9 FF FF ................
A560: F0 F1 75 FF FF F8 E2 33-F7 FF FC CC 32 F3 FF F7 ..u....3....2...
A570: 00 32 F0 F0 C4 00 32 F0-F0 C4 00 32 F0 F0 C4 00 .2....2....2....
A580: 33 FC F0 AA 00 74 F0 F0-DF 00 77 F8 F0 9F 00 74 3....t....w....t
A590: F6 F1 9F 00 77 F0 F1 2E-00 77 F8 E3 2E 00 33 FC ....w....w....3.
A5A0: D5 A6 00 65 FC 88 CC 00-9F 3F 00 00 00 CF 0F 88 ...e.....?......
A5B0: 00 00 33 FF 00 00 00 00-11 FF CC 00 00 67 F7 A6 ..3..........g..
A5C0: 00 00 76 FF 2E 00 00 77-FF 6E 00 00 33 EF 5F 00 ..v....w.n..3._.
A5D0: 00 11 7B 5F 00 00 FF 3F-6E 00 11 F3 BF 4C 00 32 ..{_...?n....L.2
A5E0: F0 FF CC 00 32 F0 F3 00-00 74 F3 FC 88 00 32 FF ....2....t....2.
A5F0: F0 C4 88 75 FC F0 F7 4C-74 F8 F0 E7 88 32 F1 FC ...u...Lt....2..
A600: E7 88 11 FE F3 FE 4C 00-FE F0 FB 88 00 FF F0 CC ......L.........
A610: 00 00 FF F0 CC 00 11 F7-F0 CC 00 32 F1 F8 CC 00 ...........2....
A620: 32 F1 FF CC 00 32 E3 DA-CC 00 33 F1 1F C4 00 74 2....2....3....t
A630: F0 FE C4 00 77 F0 F0 C4-00 F8 F8 F0 C4 00 FE F4 ....w...........
A640: F0 E6 00 7B F0 F0 F3 88-BD F8 F0 E5 4C BF FC F0 ...{........L...
A650: CF 88 CB FF F9 BF 00 77-00 66 CC 00 00 32 F0 E2 .......w.f...2..
A660: 00 00 76 F0 F7 88 00 77-FF 00 11 BD ED 88 11 FB ..v....w........
A670: CF 88 11 FF DF 88 00 FF-9F 4C 00 74 DF 4C 11 CF .........L.t.L..
A680: DF CC 32 EF DF 00 74 F7-FF 00 F8 F0 C4 00 F8 F3 ..2...t.........
A690: E2 00 F8 FC F1 00 F5 F1-F0 88 F2 F2 F0 88 F8 F0 ................
A6A0: F0 88 76 F3 FE 88 33 FC-F3 00 33 FC F7 44 33 FC ..v...3...3..D3.
A6B0: F3 AE 75 FC F1 97 74 F6-F0 9F 74 F3 F1 2E 74 F1 ..u...t...t...t.
A6C0: FF CC 75 F0 F1 00 74 F8-F1 00 74 F8 F1 00 74 F8 ..u...t...t...t.
A6D0: F1 00 74 F0 F1 00 74 F0-F1 00 F8 F8 F1 00 76 F8 ..t...t.......v.
A6E0: F0 88 11 F0 F3 88 00 FF-EE 00 00 00 FF CC 00 00 ................
A6F0: 55 7B FF 00 00 77 FF FF-88 00 77 FF 1E 88 00 33 U{...w....w....3
A700: 6F DF 88 00 77 EF DB 00-00 11 CF 5B 00 00 11 ED o...w......[....
A710: AE 00 00 76 BE 4C 00 00-FA FF EA 00 11 F1 F7 E2 ...v.L..........
A720: 00 33 F8 F8 F5 00 74 F8-F6 F0 88 F8 F4 F0 F0 88 .3....t.........
A730: F9 FE F3 FB CC F8 FF CF-7E C4 F8 BB FF B7 E2 74 ........~......t
A740: FF EF 9F E2 33 7D FF FE-E2 47 7C F3 F3 C4 23 FC ....3}...G|...#.
A750: F1 F3 88 11 74 F1 E2 00-00 74 F1 E2 00 00 74 F1 ....t....t....t.
A760: E2 00 00 76 F1 E6 00 00-BE F0 C4 00 00 BE F7 CC ...v............
A770: 00 00 BF F0 C4 00 00 75-F7 C8 00 00 33 FC EE 00 .......u....3...
A780: 00 00 76 1F 00 00 00 11-FF 00 00 11 FF 88 00 00 ..v.............
A790: 23 F7 EE 00 00 77 FF FF-00 00 FF EF 3D 00 00 67 #....w......=..g
A7A0: DF AE 00 00 FF DF A6 00-00 FF 8F A6 00 00 33 DB ..............3.
A7B0: 4C 00 00 33 6D 88 00 00-75 FF 00 00 00 FC FC 88 L..3m...u.......
A7C0: 00 11 F2 F1 C4 00 32 F0-F0 C4 00 75 FE F0 C4 00 ......2....u....
A7D0: 76 F3 F0 FF 00 32 F3 FF-CF 88 32 F5 FF ED 88 32 v....2....2....2
A7E0: F0 DF FF 00 11 F1 8F CC-00 00 F9 DB 88 00 00 FC ................
A7F0: FF 88 00 00 FB FF C4 00-00 F8 F6 C4 00 00 F8 F2 ................
A800: C4 00 00 F8 F2 C4 00 00-F8 F4 C4 00 11 F0 F4 C4 ................
A810: 00 11 F0 F4 E2 00 11 F0-F1 CC 00 00 FB FF 2E 00 ................
A820: 00 76 3F CC 00 00 11 CC-00 00 00 00 FF CC 00 00 .v?.............
A830: 11 7B FF 00 00 77 FF FF-88 00 33 FF 1E 88 00 77 .{...w....3....w
A840: 6F DF 00 00 77 EF DB 00-00 44 CF 5B 00 00 11 ED o...w....D.[....
A850: AE 00 00 32 BE 4C 00 00-FC FF 88 00 11 FA F6 88 ...2.L..........
A860: 00 33 F9 F0 CC 00 33 F0-F0 E6 00 11 FF F0 FD 00 .3....3.........
A870: 00 F8 FF 9F 00 00 F8 F7-9F 00 00 F8 F8 EA 00 00 ................
A880: 74 F0 CC 00 00 74 F0 C4-00 00 FA F1 88 00 00 F9 t....t..........
A890: FE 88 00 00 F8 F2 C4 00-00 F8 F2 C4 00 11 F8 F2 ................
A8A0: C4 00 11 F0 F2 E6 00 00-F8 F2 F9 00 11 FC F0 F7 ................
A8B0: 88 11 F6 F0 EF 4C 11 F3-FF F9 CC 00 CB 88 BF 88 .....L..........
A8C0: 00 77 00 66 00 00 77 FF-00 00 BD FF 00 11 FF FD .w.f..w.........
A8D0: 00 11 FF CF 88 77 EF BF-88 33 FE AF 88 00 BF 2D .....w...3.....-
A8E0: 88 77 FB 5F 00 F8 FF AE-00 F8 F1 CC 00 F8 F2 88 .w._............
A8F0: 00 F8 FE CC 00 F9 F8 E2-00 FE F0 F1 00 F8 F0 FF ................
A900: 00 FF F1 FB CC FB FE F2-2E 77 FE F1 AE 33 FF F0 .........w...3..
A910: AE 74 FF F8 EE 74 F0 F7-88 74 F0 E2 00 75 F0 E2 .t...t...t...u..
A920: 00 74 F8 EA 00 74 F8 E2-00 74 F8 EA 00 FC F0 FB .t...t...t......
A930: 00 F8 F0 F9 00 76 F0 E6-00 11 FF 88 00 00 33 FF .....v........3.
A940: 00 00 56 FF 88 00 FF FE-88 00 FF EF 4C 11 FF D7 ..V.........L...
A950: 88 00 FF 5F 4C 11 FF 9E-4C 32 F7 AF 88 32 F0 DF ..._L...L2...2..
A960: 00 76 F0 E6 EE FA F3 F3-9F FA F4 F2 FF FA F8 F4 .v..............
A970: F9 F9 F0 F1 F5 F9 FC F2-F1 F9 FF FE E2 67 FF FF .............g..
A980: CC 47 FF FF 88 33 FF FE-88 00 F9 F8 88 00 F8 F0 .G...3..........
A990: 88 00 F8 F0 CC 11 FE F0-EA 32 F1 F1 AE 33 FC F3 .........2...3..
A9A0: 6A 32 7E F6 4C 65 FB 99-88 32 1E 88 00 11 FF 00 j2~.Le...2......
A9B0: 00 00 00 00 00 00 33 FF-00 00 56 FF 88 00 FF EF ......3...V.....
A9C0: 88 00 FF EF 4C 11 FF D7-88 11 FF 5F 4C 32 FF 9E ....L......_L2..
A9D0: 4C 74 F1 AF 88 F8 FE DF-00 77 FE E6 00 74 F0 C4 Lt.......w...t..
A9E0: CC 33 F3 DD A6 33 FE F7-2E 33 FC F5 6A 11 F8 FD .3...3...3..j...
A9F0: CC 11 F8 EE 00 33 F8 CC-00 67 FF CC 00 76 97 CC .....3...g...v..
AA00: 00 75 FF C4 00 74 F0 E2-00 74 F0 E2 00 76 F0 E2 .u...t...t...v..
AA10: 00 75 F8 F3 00 F8 F6 F1-00 FF F0 F1 EE 9F F8 F3 .u..............
AA20: 3D ED FC E7 6E 77 7B DF-88 00 CC 22 00 F0 88 00 =...nw{...."....
AA30: 77 F8 F0 FF 00 47 FC F1-9E 00 76 7E F3 3F 00 33 w....G....v~.?.3
AA40: BD EF CC 00 00 66 11 00-00 00 00 00 00 00 00 00 .....f..........
AA50: 00 00 00 11 EE 00 00 00-00 77 FD 00 00 00 11 FF .........w......
AA60: F1 00 00 00 77 FC F1 00-00 11 FF F1 FD 00 00 77 ....w..........w
AA70: FC F1 3F 00 11 FF F1 FC-FD 00 77 FC F1 3E F5 11 ..?.......w..>..
AA80: FF F1 FC FC F7 77 FC F1-3E F0 DF F3 F1 FC FC F1 .....w..>.......
AA90: 1F F4 F1 3E F0 F1 3F F5-FC FC F7 F1 FD F5 3E F1 ...>..?.......>.
AAA0: BF F9 F5 F5 FC E3 BF F8-F5 F5 F0 E3 9F F8 F5 F5 ................
AAB0: F0 E7 3F F8 F5 F5 FC C7-BF F8 F7 F3 7C E7 BF F8 ..?.........|...
AAC0: DF CF 7C E7 9F F9 1F CF-FC E7 3F F9 3F F3 F0 C7 ..|.......?.?...
AAD0: BF F9 FD F5 F0 E7 FE F1-F5 F5 F0 F7 F9 F8 F5 F5 ................
AAE0: F0 F6 F6 F0 F5 F5 F0 F1-F8 F1 FD F5 FC F6 F0 F1 ................
AAF0: 3F F3 7C F0 F1 FC FD CF-7C F0 F1 3E E6 CF FC F1 ?.|.....|..>....
AB00: FC FD 88 F3 F0 F1 3E E6-00 F5 F1 FC FD 88 00 F5 ......>.........
AB10: F1 3E E6 00 00 F5 FC FD-88 00 00 F5 3E E6 00 00 .>..........>...
AB20: 00 F4 FD 88 00 00 00 F4-E6 00 00 00 00 F5 88 00 ................
AB30: 00 00 00 62 00 00 00 00-00 FF FF 13 89 13 89 13 ...b............
AB40: 89 01 01 88 13 CC 37 EE-7F FF FF CC 13 EE 37 EE ......7.......7.
AB50: 37 EE 37 EE 37 EE 37 CC-13 72 FF FF FF C8 F7 F7 7.7.7.7..r......
AB60: FF FF EC F7 F9 FF 7E F6-F7 FC C7 3D FE F6 F4 F6 ......~....=....
AB70: 1F FE F7 F8 E3 96 FE F7-F8 F1 3C FE BF FA F1 FD ..........<.....
AB80: EC 8F FB F0 F5 C8 57 7F-FF FC 80 57 FB FF FA 00 ......W....W....
AB90: 22 73 FF FB 80 00 73 FF-FB 80 00 73 FF FB 80 00 "s....s....s....
ABA0: 73 FF FB 80 00 75 FF F7-80 00 FD FF FF 80 00 BE s....u..........
ABB0: FF FE 00 00 BE FF E0 00-00 9F F6 FE 00 00 75 F7 ..............u.
ABC0: F1 00 00 33 F6 FE 00 00-00 71 EE 00 00 00 11 1F ...3.....q......
ABD0: 88 00 00 00 8F 4C 00 00-00 77 88 73 FF FF FE 00 .....L...w.s....
ABE0: F7 FF FF FF 80 FC FF FF-FF 80 F3 F3 FF FE 00 73 ...............s
ABF0: FC FF FD 00 73 FC F0 F3-CC 73 F2 F0 E7 2E 73 FD ....s....s....s.
AC00: FE EF BD 73 EF 3F FB 5F-31 EB 1F FB EE 30 E7 2F ...s.?._1....0./
AC10: FB CC 31 FF 5F FC 80 31-FF FF EC 00 31 FF FE EC ..1._..1....1...
AC20: 00 10 FF FE EC 00 10 FF-FE EC 00 10 FF FE EC 00 ................
AC30: 10 FF FF EC 00 31 FF FF-FE 00 31 FC F7 F9 00 10 .....1....1.....
AC40: F3 FF 97 00 00 76 3D FF-00 00 11 8F 88 00 00 00 .....v=.........
AC50: 77 00 00 73 FF FD FF 88-70 F3 FE E2 00 F6 FC F7 w..s....p.......
AC60: FF 88 72 FF F9 AD 4C 11-F7 FD CF C4 11 F7 FF ED ..r...L.........
AC70: 88 00 FB FF ED 88 00 F8-FF FC 88 00 F8 F3 FF 80 ................
AC80: 00 F6 F0 F3 80 00 F7 F8-F3 80 00 F7 FD FC 00 00 ................
AC90: F7 FE FE 00 00 F7 FE FE-00 00 F7 FE FE 00 10 F7 ................
ACA0: FE FE 00 10 FF FE FF 00-32 FF FF FC 00 75 F7 F7 ........2....u..
ACB0: F3 77 57 FB FA FF 9E 56-FD FF FF 3F 23 D4 F7 C7 .wW....V...?#...
ACC0: EE 32 1F 70 57 CC 11 EE-00 33 00 F5 FF F1 DD 6E .2.pW....3.....n
ACD0: F5 FC FF FF 9F F6 FB FF-FF 9F F7 F7 FF FD DF F9 ................
ACE0: FF FF F1 FF FE F7 FC FE-FE FE F0 F1 FE FE FF F0 ................
ACF0: F5 FF FE BF F0 F5 FF EC-BF FC F2 FF C0 77 FF FF .............w..
AD00: F0 00 73 FF FF C8 00 73-FF FF C8 00 73 FF FF C8 ..s....s....s...
AD10: 00 73 FF FF EA 00 73 FF-FF D7 00 74 FF FE 9F 00 .s....s....t....
AD20: 77 F3 FE 9F 00 F9 FD FD-2E 00 FE F7 EB 2E 00 77 w..............w
AD30: FB DD 2E 00 47 FC C4 CC-00 9F 3F 00 00 00 CF 0F ....G.....?.....
AD40: 88 00 00 33 FF 00 00 00-31 FF FF CC 00 73 FF FF ...3....1....s..
AD50: EC 00 30 FF F8 FA 00 11-F7 F7 F3 88 11 F1 F7 FB ..0.............
AD60: 4C 11 F0 FF EB 2E 10 FC-FF EB AE 31 FE FF F5 44 L..........1...D
AD70: 31 FE FF C4 00 31 FF F3-C0 00 73 FF FC 80 00 73 1....1....s....s
AD80: DF 3F 80 00 73 ED 7B 80-00 72 FF F7 80 00 73 FB .?..s.{..r....s.
AD90: FF C8 00 73 FD FB C8 00-73 FE F7 EC 00 F5 FB FF ...s....s.......
ADA0: EC 88 FF FD FB FB 4C 3E-FE F7 E7 4C DF F7 FE E9 ......L>...L....
ADB0: 88 8F FB EC DB 00 77 30-C0 66 00 F5 FC FF EC 00 ......w0.f......
ADC0: F6 F3 FF C8 00 F7 FF FF-C8 00 F7 FF FC C4 00 FB ................
ADD0: FF F2 CC 00 F9 FC FE 88-00 FC F3 FE CC 00 F4 F3 ................
ADE0: F9 BF 00 72 F1 FF 8F 88-31 F9 FF CF 88 73 FE F3 ...r....1....s..
ADF0: DB 00 73 FF FC E6 00 73-FF FF 80 00 72 FF FF 80 ..s....s....r...
AE00: 00 73 F7 FD 80 00 73 F7-FF 80 00 73 FF FF 80 00 .s....s....s....
AE10: 73 FF FD 80 00 72 FF FD-80 00 F7 F1 FD 80 00 73 s....r.........s
AE20: FF FD C8 00 30 FF FE 80-00 10 F0 E0 00 00 FF C8 ....0...........
AE30: 00 31 FF FF A2 00 31 FF-FF D3 00 71 F7 FF 97 00 .1....1....q....
AE40: 73 F9 FE 97 00 70 FF FE-2E 00 70 F7 ED 2E 00 30 s....p....p....0
AE50: F3 D9 2E 00 47 F3 80 CC-00 9F 3C 00 00 00 CF 0F ....G.....<.....
AE60: 88 00 00 33 FF 00 00 00-72 F3 FF FA 00 73 F7 FF ...3....r....s..
AE70: FB 80 31 FF FF FA 4C 10-F1 FF E9 2E 00 F0 F4 E7 ..1...L.........
AE80: AE 00 F0 F7 D9 44 00 F0-FF C8 00 10 F8 FE C4 00 .....D..........
AE90: 31 FE FF CC 00 31 FE FF-C8 00 31 FE FF C0 00 31 1....1....1....1
AEA0: FF F6 4C 00 31 FF E9 2E-00 70 FD FC 2E 00 F7 FC ..L.1....p......
AEB0: ED 5F 00 F1 FE F6 E2 00-3C FE F7 D9 88 9E F7 F3 ._......<.......
AEC0: CB 4C BF F3 FF CB 88 8F-F9 FF B7 00 77 10 F0 44 .L..........w..D
AED0: 00 FA FF F7 80 00 FD FE-FF 80 00 F7 FF FF 80 00 ................
AEE0: 70 FE F0 80 00 30 F1 FE-80 00 30 F3 FE 00 00 30 p....0....0....0
AEF0: F3 F8 22 00 72 F3 FF D7-00 73 F3 FF 87 00 72 FB ..".r....s....r.
AF00: FF C7 00 72 FD FC 97 00-72 FE F2 66 00 72 FF FE ...r....r..f.r..
AF10: 00 00 72 FF FE 00 00 72-FF FE 00 00 72 FF FE 00 ..r....r....r...
AF20: 00 73 FD FE 00 00 73 FD-FE 00 00 31 FE FE 00 00 .s....s....1....
AF30: 30 FF FC 00 00 00 F0 E0-00 00 6D 32 20 01 00 20 0.........m2 ..
AF40: 02 00 6D 32 01 00 32 01-00 6D 01 00 6D 08 00 6D ..m2..2..m..m..m
AF50: 31 20 20 20 20 06 1E 01-00 1E 07 00 6D 31 20 20 1    .......m1
AF60: 20 20 06 01 00 06 06 00-6D 31 20 20 20 20 01 00   ......m1    ..
AF70: 20 05 00 6D 31 20 20 20-01 00 20 04 00 6D 31 20  ..m1   .. ..m1
AF80: 20 01 00 20 03 00 6D 31-20 01 00 20 02 00 6D 31  .. ..m1 .. ..m1
AF90: 01 00 31 01 00 6D 01 00-6D 08 00 67 75 69 33 20 ..1..m..m..gui3
AFA0: 20 05 22 01 00 22 07 00-67 75 69 33 20 20 05 01  .".."..gui3  ..
AFB0: 00 05 06 00 67 75 69 33-20 20 01 00 20 05 00 67 ....gui3  .. ..g
AFC0: 75 69 33 20 01 00 20 04-00 67 75 69 33 01 00 33 ui3 .. ..gui3..3
AFD0: 03 00 67 75 69 01 00 69-02 00 67 75 01 00 75 01 ..gui..i..gu..u.
AFE0: 00 67 01 00 67 00 00 00-00 00 00 00 00 00 00 00 .g..g...........
AFF0: 00 00 00 00 00 00 00 00-00 00 00 00 00 00 00 00 ................
B000: 00 00 00 00 00 00 00 00-00 00 11 FF 88 00 00 33 ...............3
B010: FF 88 00 00 77 8F 2E 00-00 57 FF 6E 00 00 57 7F ....w....W.n..W.
B020: 6E 00 77 FF 3F 2E 00 74-F3 DF 4C 11 FC E3 DF 4C n.w.?..t..L....L
B030: 32 F4 E3 FF CC FC F2 F3-CF EE F8 F3 F0 FF EA F9 2...............
B040: DD F8 F0 E6 F8 D5 FF 7F-FD F8 D5 CF 3E F1 F8 D5 ............>...
B050: EF 1F F1 77 99 EF 1F F1-BF 11 FF 3F F1 8F 88 FF ...w.......?....
B060: FE E2 57 5D F7 FF C4 57-11 F3 FF 88 22 32 F0 F4 ..W]...W...."2..
B070: 88 00 32 F0 F4 88 00 32-F0 F4 C4 00 32 F0 F4 C4 ..2....2....2...
B080: 00 32 F0 F4 C4 00 76 F0-F8 C4 00 BF F0 F0 88 00 .2....v.........
B090: 9F F0 F0 88 00 BF F0 F1-00 00 9F F0 FD 00 00 57 ...............W
B0A0: F0 E2 00 00 22 F8 E2 00-00 00 77 CC 00 00 00 11 ....".....w.....
B0B0: 0E 00 00 00 00 8F 08 00-00 00 77 88 00 00 77 EE ..........w...w.
B0C0: 00 00 00 FF EE 00 00 11-EF 0F 88 00 11 7F DF 88 ................
B0D0: 00 11 5F DF 88 00 11 CF-CF 88 00 00 FF 5F 00 00 .._.........._..
B0E0: 77 BF 5F 00 00 F8 BF FF-00 11 F0 FF 3F 00 32 F0 w._.........?.2.
B0F0: F3 EE 00 74 F0 F1 FD 00-74 F0 F0 F1 00 32 F0 F0 ...t....t....2..
B100: F1 00 75 00 22 FF FF 88-00 75 F8 BD 88 00 74 F4 ..u."....u....t.
B110: 9E 88 00 32 F1 0F C4 00-32 FF EF CC 00 11 BF A7 ...2....2.......
B120: 88 00 F0 FF A7 88 00 F7-F7 FF 88 10 FF FB DF 88 ................
B130: 30 FF FF EE 00 00 75 FF-88 00 00 FB F9 C4 00 00 0.....u.........
B140: FA F1 AE 00 00 74 F3 9F-00 00 32 F7 7F 00 00 33 .....t....2....3
B150: FD 5F 00 10 F0 F7 DF 00-11 FF FB EE 00 11 FF FD ._..............
B160: DF 00 31 FF FE EE 00 00-00 00 00 00 00 00 FF FF ..1.............
B170: 00 00 11 7E F3 88 00 67-F8 F1 88 00 EB FB FB 00 ...~...g........
B180: 00 DF FC F9 00 00 73 FF-FB 00 00 F5 CF DF 00 10 ......s.........
B190: FE BF EF 88 31 FE FF 3F-00 00 66 FF CC 00 00 BF ....1..?..f.....
B1A0: 6F EE 00 00 CF DF F9 00-00 BF BF F7 00 00 47 F7 o.............G.
B1B0: F5 00 00 F7 FF FD 00 10-F8 FF 2E 00 31 FF E7 EE ............1...
B1C0: 00 73 FF F7 AE 00 73 FF-FB EE 00 00 00 00 00 00 .s....s.........
B1D0: 00 00 33 FF 00 00 00 77-C3 EE 11 FF FF EF 6E 32 ..3....w......n2
B1E0: FC FF CB A6 32 F7 DF F7-6E 32 F0 F7 B5 6A 11 F1 ....2...n2...j..
B1F0: FB 7F CC 32 F7 FD FC C4-75 FF FE FC CC 00 00 00 ...2....u.......
B200: 00 00 00 00 FF 88 00 00-33 E9 4C 00 00 33 FF AE ........3.L..3..
B210: 00 00 FF FF 9F 00 11 F0-EF BF 00 11 F0 F7 AF 88 ................
B220: 11 FE F3 7F 00 32 F3 FB-7D 00 31 FD FD FD 00 00 .....2..}.1.....
B230: 00 70 E0 00 00 00 F7 FF-80 00 30 ED 7F CC 00 73 .p........0....s
B240: FF 9E CC 00 F7 FE 8F C4-30 F7 AF EF CC 73 FB FA ........0....s..
B250: 2F C4 73 F1 FE FF CC 72-FE FF 9F 88 31 FF F3 FF /.s....r....1...
B260: 00 00 00 F0 80 00 00 30-FF EE 00 00 73 9E FD 00 .......0....s...
B270: 00 F7 FF DB 00 10 FF FF-CF 88 10 FF DF BF 00 30 ...............0
B280: F3 FF AF 88 73 FC FF F7-00 73 FF E7 DF 00 30 F1 ....s....s....0.
B290: FB EE 00 00 00 00 FF CC-00 00 11 FD EE 00 00 33 ...............3
B2A0: F8 DF 00 00 33 FC 1F 00-00 23 FC 5B 00 00 32 BF ....3....#.[..2.
B2B0: EA 00 00 FB DA BD 00 33-F9 FC AE 00 F7 FB 7F EE .......3........
B2C0: 10 F7 FD F7 6E 00 31 FF-EC 00 00 73 FD EC 00 00 ....n.1....s....
B2D0: F7 FE 6C 00 00 F7 FF AE-00 00 F7 FB A6 00 00 F7 ..l.............
B2E0: ED CC 00 00 73 ED AE 00-30 E7 FE AE 00 73 FF FB ....s...0....s..
B2F0: CC 00 F3 FF FF 4C 00 00-00 FF CC 00 00 00 F8 E2 .....L..........
B300: 00 00 11 F0 F1 00 00 71-F3 FF 88 00 73 E7 DF 00 .......q....s...
B310: 00 73 FD FB 00 00 F7 FF-FB 00 00 F5 CF DF 00 10 .s..............
B320: FE BF E3 88 31 FE FF FF-80 00 11 FF CC 00 00 32 ....1..........2
B330: F0 C4 00 00 74 F0 E2 00-00 74 FE EE 00 00 F5 FB ....t....t......
B340: 4C 00 10 FF FE EA 00 10-FF FF EA 00 10 F0 F7 4C L..............L
B350: 00 31 FF FB 4C 00 31 FF-F3 88 00 00 FF FE C0 00 .1..L.1.........
B360: 11 F1 FF EC 00 11 F4 F0-FE 00 32 FE F3 FF 80 11 ..........2.....
B370: F7 F7 FF 80 00 F7 F7 FF-80 10 FF FB FE 00 10 FB ................
B380: FB FE 00 31 FD FB FE 00-73 FD FC FF 80 11 88 00 ...1....s.......
B390: 00 00 32 F7 EE 00 00 75-F0 F5 00 00 75 F8 F0 CC ..2....u....u...
B3A0: 00 22 FE F0 CC 00 00 F8-F0 CC 00 31 FC F1 88 00 .".........1....
B3B0: 72 F7 F1 88 00 F7 F9 FD-88 00 F7 FE F5 88 00 FC r...............
B3C0: F0 8F 74 F4 F0 CF 74 F2-F3 9F 74 F1 FD 66 74 F0 ..t...t...t..ft.
B3D0: F1 00 74 F0 F1 00 74 F0-F1 00 74 F0 F1 00 74 F0 ..t...t...t...t.
B3E0: F1 00 74 F0 F1 00 32 F0-F0 88 33 F0 F3 88 00 FF ..t...2...3.....
B3F0: EE 00 00 00 FF CC 00 00-11 3F FF 88 00 33 FF FF .........?...3..
; ------------ fin de los gráficos de los objetos --------------------

; tabla con los datos gráficos de los caracteres que se usan durante el juego
B400: 	00 76 DB DB F3 C3 C3 81 ; 0x2d -> PL
		00 39 6D 60 78 60 2C 98 ; 0x2e -> ET (media t)
		00 FB 66 66 67 66 66 42 ; 0x2f -> TA (media t y media a)
		00 7C EE C6 C6 C6 EE 7C ; 0x30 -> 0
		00 18 38 38 18 18 3E 7C ; 0x31 -> 1
		00 78 FC 9C 38 70 E6 FC ; 0x32 -> 2
		00 7E CC 98 3C 0E CE 7C ; 0x33 -> 3
		00 60 C8 D8 7E 18 18 10 ; 0x34 -> 4
		00 FC 66 60 7C 0E CE 7C ; 0x35 -> 5
		00 3C 60 DC F6 C2 E6 7C ; 0x36 -> 6
		00 7E E6 0E 1C 38 30 30 ; 0x37 -> 7
		00 7C EE C6 7C C6 EE 7C ; 0x38 -> 8
		00 7C CE 86 DE 76 0C 78 ; 0x39 -> 9
		00 00 00 30 30 00 30 30 ; 0x3a -> :
		00 00 00 18 18 00 18 30 ; 0x3b -> ;
		00 00 00 00 00 00 18 30 ; 0x3c -> ,
		00 00 00 00 00 00 1C 1C ; 0x3d -> .
		00 6E DD D8 CE C3 DB 8E ; 0x3e -> |S (usado para vísperas y completas)
		00 7C C6 46 1C 30 00 30 ; 0x3f -> ?
		0C 00 0C 38 62 63 3E 00 ; 0x40 -> ¿
		00 3C 66 C6 FE C6 E6 66 ; 0x41 -> A
		00 D8 EC CC FC C6 E6 DC ; 0x42 -> B
		00 38 6C C6 C0 C2 EE 7C ; 0x43 -> C
		00 DC E6 C6 C6 C6 CC F8 ; 0x44 -> D
		00 DC E6 60 7C 60 E6 DC ; 0x45 -> E
		00 EE 72 60 7C 60 E0 C0 ; 0x46 -> F
		00 3C 66 C0 CE C4 EC 78 ; 0x47 -> G
		00 CC C6 C6 FE C6 C6 66 ; 0x48 -> H
		00 7E 98 30 30 30 1A FC ; 0x49 -> I
		00 3E 0C 0C E6 66 C6 7C ; 0x4a -> J
		00 C0 66 6C 78 78 EC C6 ; 0x4b -> K
		00 C0 E0 60 60 60 FC C2 ; 0x4c -> L
		00 66 FE D6 D6 C6 E6 66 ; 0x4d -> M
		00 CC E6 E6 D6 CE CE 66 ; 0x4e -> N
		00 38 6C C6 C6 C6 EE 7C ; 0x4f -> O
		00 DC 66 66 6E 78 60 60 ; 0x50 -> P
		00 38 6C C6 D6 CC EC 76 ; 0x51 -> Q
		00 DC E6 C6 EC D8 CC C6 ; 0x52 -> R
		00 3C 66 62 3C 46 C6 7C ; 0x53 -> S
		00 FE BA 18 18 18 38 30 ; 0x54 -> T
		00 E6 66 C6 C6 C6 C6 7C ; 0x55 -> U
		00 CE CC C6 C6 C6 6C 38 ; 0x56 -> V
		8C 72 CC E6 F6 D6 CE 64 ; 0x57 -> Ñ
		00 EE C6 6C 38 6C C6 EE ; 0x58 -> X
		00 CC C6 66 3C 18 30 60 ; 0x59 -> Y
		00 76 8C 18 30 60 C2 BC ; 0x5A -> Z
		00 32 F8 E6 00 00 32 F7 ; 0x5B -> [
		EA 00 00 32 F0 F9 00 00 ; 0x5C -> \

; tabla de palabras
B580: 	0x00 -> 53 45 43 52 45 D4 -> SECRET
		0x01 -> 55 CD -> UM
		0x02 -> 46 49 4E 49 D3 -> FINIS
		0x03 -> 41 46 52 49 43 41 C5 -> AFRICAE
		0x04 -> 4D 41 4E 55 D3 -> MANUS
		0x05 -> 53 55 50 52 C1 -> SUPRA
		0x06 -> 41 41 C1 -> AAA (esto se sobreescribe con los números romanos)
		0x07 -> 49 44 4F 4C 55 CD -> IDOLUM
		0x08 -> 41 47 C5 -> AGE
		0x09 -> 50 52 49 CD -> PRIM
		0x0a -> 45 D4 -> ET
		0x0b -> 53 45 50 54 49 CD -> SEPTIM
		0x0c -> 44 C5 -> DE
		0x0d -> 51 55 41 54 55 4F D2 -> QUATUOR
		0x0e -> 42 49 45 CE -> BIEN
		0x0f -> 56 45 4E 49 C4 -> VENID
		0x10 -> CF -> O
		0x11 -> C1 -> A
		0x12 -> 45 53 D4 -> EST
		0x13 -> 41 42 41 44 49 C1 -> ABADIA
		0x14 -> 48 45 52 4D 41 4E CF -> HERMANO
		0x15 -> 4F D3 -> OS
		0x16 -> 52 55 45 47 CF -> RUEGO
		0x17 -> 51 55 C5 -> QUE
		0x18 -> 4D C5 -> ME
		0x19 -> 53 49 C7 -> SIG
		0x1a -> 41 49 D3 -> AIS
		0x1b -> 48 C1 -> HA
		0x1c -> 53 55 43 45 C4 -> SUCED
		0x1d -> 49 44 CF -> IDO
		0x1e -> 41 4C 47 CF -> ALGO
		0x1f -> 54 45 52 52 49 42 4C C5 -> TERRIBLE
		0x20 -> 54 45 4D CF -> TEMO
		0x21 -> 55 CE -> UN
		0x22 -> 4C 4F D3 -> LOS
		0x23 -> 4D 4F 4E 4A C5 -> MONJE
		0x24 -> D3 -> S
		0x25 -> 43 4F CD -> COM
		0x26 -> 43 52 49 4D 45 CE -> CRIMEN
		0x27 -> 4C CF -> LO
		0x28 -> 45 4E 43 4F 4E 54 D2 -> ENCONTR
		0x29 -> 45 49 D3 ->EIS
		0x2a -> 41 4E 54 C5 -> ANTE
		0x2b -> 4C 4C 45 47 D5 -> LLEGU
		0x2c -> C5 -> E
		0x2d -> 42 45 52 4E 41 52 44 CF -> BERNARDO
		0x2e -> 47 55 C9 -> GUI
		0x2f -> 50 55 C5 -> PUE
		0x30 -> 4E CF -> NO
		0x31 -> 53 C5 -> SE
		0x32 -> 4D 41 4E 43 C8 -> MANCH
		0x33 -> 45 CC -> EL
		0x34 -> 4E 4F 4D 42 52 C5 -> NOMBRE
		0x35 -> 44 45 C2 -> DEB
		0x36 -> 52 45 53 50 45 D4 -> RESPET
		0x37 -> 41 D2 -> AR
		0x38 -> 4D C9 -> MI
		0x39 -> 4F 52 44 45 CE -> ORDEN
		0x3a -> 45 D3 -> ES
		0x3b -> D9 -> Y
		0x3c -> 4C 41 D3 -> LAS
		0x3d -> 4C C1 -> LA
		0x3e -> 41 53 49 53 54 49 D2 -> ASISTIR
		0x3f -> 4F 46 49 43 49 4F D3 -> OFICIOS
		0x40 -> 49 44 C1 -> IDA
		0x41 -> 4E 4F 43 48 C5 -> NOCHE
		0x42 -> 45 CE -> EN
		0x43 -> 56 55 45 53 54 D2 -> VUESTR
		0x44 -> 43 45 4C 44 C1 -> CELDA
		0x45 -> 44 45 4A 41 C4 -> DEJAD
		0x46 -> 4D 41 4E 55 53 43 52 49 54 CF -> MANUSCRITO
		0x47 -> 56 45 4E 41 4E 43 49 CF VENANCI0
		0x48 -> 41 44 56 45 52 54 49 D2 -> ADVERTIR
		0x49 -> 41 CC -> AL
		0x4a -> 41 42 41 C4 -> ABAD
		0x4b -> 44 41 C4 -> DAD
		0x4c -> 46 52 41 D9 -> FRAY
		0x4d -> 47 55 49 4C 4C 45 52 4D CF -> GUILLERMO
		0x4e -> 4C 4C 45 C7 -> LLEG
		0x4f -> 54 41 52 44 C5 -> TARDE
		0x50 -> 49 D2 -> IR
		0x51 -> 56 45 4E C7 -> VENG
		0x52 -> 41 42 41 4E 44 4F CE -> ABANDON
		0x53 -> 45 44 49 46 49 43 49 CF -> EDIFICIO
		0x54 -> 45 4D 4F D3 -> EMOS
		0x55 -> 49 47 4C 45 53 49 C1 -> IGLESIA
		0x56 -> 4D 41 45 53 54 52 CF -> MAESTRO
		0x57 -> 52 45 46 45 43 54 4F 52 49 CF -> REFECTORIO
		0x58 -> 50 4F C4 -> POR
		0x59 -> 41 D3 -> AS
		0x5a -> 48 41 42 45 49 D3 -> HABEIS
		0x5b -> 41 44 CF -> ADO
		0x5c -> 4F 52 44 45 4E 45 D3 -> ORDENES
		0x5d -> 41 C4 -> AR
		0x5e -> 50 41 52 C1 -> PARA
		0x5f -> 53 49 45 4D 50 52 C5 -> SIEMPRE
		0x60 -> 45 53 43 55 43 48 41 C4 -> ESCUCHAD
		0x61 -> 48 C5 -> HE
		0x62 -> 45 58 54 52 41 D7 -> EXTRAÑ
		0x63 -> 4C 49 42 52 CF -> LIBRO
		0x64 -> 45 4E 54 D2 -> ENTR
		0x65 -> 49 4E 56 45 53 54 49 47 41 43 49 4F CE -> INVESTIGACION
		0x66 -> 44 4F 52 4D 49 4D 4F D3 -> DORMIMOS
		0x67 -> 55 4E C1 -> UNA
		0x68 -> 4C 41 4D 50 41 52 C1 -> LAMPARA
		0x69 -> 41 51 55 C9 -> AQUI
		0x6a -> 53 49 44 CF -> SIDO
		0x6b -> 41 53 45 53 49 CE -> ASESIN
		0x6c -> 53 41 42 45 D2 -> SABER
		0x6d -> 42 49 42 4C 49 4F 54 45 43 C1 -> BIBLIOTECA
		0x6e -> 4C 55 47 41 D2 -> LUGAR
		0x6f -> 53 4F 4C CF -> SOLO
		0x70 -> 4D 41 4C 41 51 55 49 41 D3 -> MALAQUIAS
		0x71 -> 4F D2 -> OR
		0x72 -> 42 45 52 45 4E 47 41 52 49 CF -> BERENGARIO
		0x73 -> 44 45 53 41 50 41 52 45 43 49 44 CF -> DESAPARECIDO
		0x74 -> 48 41 4C 4C C1 -> HALLA
		0x75 -> 4F 54 52 CF -> OTRO
		0x76 -> 45 D2 -> ER
		0x77 -> 48 41 CE -> HAN
		0x78 -> 53 45 56 45 52 49 4E CF -> SEVERINO
		0x79 -> 44 49 4F D3 -> DIOS
		0x7a -> 53 41 4E 54 CF -> SANTO
		0x7b -> 4C C5 -> LE
		0x7c -> 43 45 52 D2 -> CERR
		0x7d -> 48 4F D9 -> HOY
		0x7e -> 4D 41 57 41 4E C1 -> MAÑANA
		0x7f -> 56 45 D2 -> VER
		0x80 -> 54 45 4E 49 C1 -> TENIA
		0x81 -> 4D 49 CC -> MIL
		0x82 -> 45 53 43 4F 52 50 49 4F 4E 45 D3 -> ESCORPIONES
		0x83 -> 4D 55 45 52 54 CF -> MUERTO
		0x84 -> 53 4F 49 D3 -> SOIS
		0x85 -> 56 4F D3 -> VOS
		0x86 -> 50 41 53 41 C4 -> PASAD
		0x87 -> 41 42 C1 -> ABA
		0x88 -> 45 53 50 45 D2 -> ESPER
		0x89 -> 41 4E 44 CF -> ANDO
		0x8a -> 54 4F 4D 41 C4 -> TOMAD
		0x8b -> 50 52 45 4D 49 CF -> PREMIO
		0x8c -> 43 41 49 44 CF -> CAIDO
		0x8d -> 54 52 41 4D 50 C1 -> TRAMPA
		0x8e -> 56 45 4E 45 52 41 42 4C C5 -> VENERABLE
		0x8f -> 4A 4F 52 47 C5 -> JORGE
		0x90 -> 50 45 52 CF -> PERO
		0x91 -> 4C 4C 45 56 C1 -> LLEVA
		0x92 -> 47 55 41 4E 54 45 D3 -> GUANTES
		0x93 -> 53 45 50 41 52 41 D2 -> SEPARAR
		0x94 -> 46 4F 4C 49 4F D3 -> FOLIOS
		0x95 -> 54 45 4E 44 52 49 C1 -> TENDRIA
		0x96 -> 48 55 4D 45 44 45 43 45 D2 -> HUMEDECER
		0x97 -> 44 45 44 4F D3 -> DEDOS
		0x98 -> 4C 45 4E 47 55 C1 -> LENGUA
		0x99 -> 48 41 53 54 C1 -> HASTA
		0x9a -> 48 55 42 49 45 52 C1 -> HUBIERA
		0x9b -> 52 45 43 49 42 49 44 CF -> RECIBIDO
		0x9c -> 46 49 43 49 45 4E 54 C5 -> SUFICIENTE
		0x9d -> 56 45 4E 45 4E CF -> VENENO
		0x9e -> 49 45 4E 44 CF -> IENDO
		0x9f -> 4D 55 D9 -> MUY
		0xa0 -> 4E 45 47 52 41 D3 -> NEGRAS
		0xa1 -> 50 52 4F 4E 54 CF -> PRONTO
		0xa2 -> 41 4D 41 4E 45 C3 -> AMANEC
		0xa3 -> 45 52 C1 -> ERA
		0xa4 -> 41 47 4F D4 -> AGOT
		0xa5 -> 4A 41 4D 41 D3 -> JAMAS
		0xa6 -> 43 4F 4E 53 45 47 55 49 D2 -> CONSEGUIR
		0xa7 -> 53 41 4C 49 D2 -> SALIR
		0xa8 -> 4F 43 55 50 41 C4 -> OCUPAD
		0xa9 -> 53 49 54 49 CF -> SITIO
		0xaa -> 43 4F 45 4E C1 -> COENA
		0xab -> 43 49 50 52 49 41 4E C9 -> CIPRIANI
		0xac -> 41 52 49 53 54 4F 54 45 4C 45 D3 -> ARISTOTELES
		0xad -> 41 48 4F 52 C1 -> AHORA
		0xae -> 43 4F 4D 50 52 45 4E 44 45 52 45 49 D3 -> COMPRENDEIS
		0xaf -> 50 4F D2 -> POR
		0xb0 -> 50 52 4F 54 45 47 45 52 4C CF -> PROTEGERLO
		0xb1 -> 43 41 44 C1 -> CADA
		0xb2 -> 50 41 4C 41 42 52 C1 -> PALABRA
		0xb3 -> 53 43 52 49 54 C1 -> ESCRITA
		0xb4 -> 46 49 4C 4F 53 4F 46 CF -> FILOSOFO
		0xb5 -> 44 45 53 54 52 55 49 44 CF -> DESTRUIDO
		0xb6 -> 50 41 52 54 C5 -> PARTE
		0xb7 -> 44 45 CC -> DEL
		0xb8 -> 43 52 49 53 54 49 41 4E 44 41 C4 -> CRISTIANDAD
		0xb9 -> 41 43 54 55 41 44 CF -> ACTUADO
		0xba -> 53 49 47 55 49 45 4E 44 CF -> SIGUIENDO
		0xbb -> 56 4F 4C 55 4E 54 41 C4 -> VOLUNTAD
		0xbc -> 53 45 57 4F D2 -> SEÑOR
		0xbd -> 4C 45 45 44 4C CF -> LEEDLO
		0xbe -> 44 45 53 50 55 45 D3 -> DESPUES
		0xbf -> 54 C5 -> TE
		0xc0 -> 4D 4F 53 54 52 41 D2 -> MOSTRAR
		0xc1 -> 54 C9 -> TI
		0xc2 -> 4D 55 43 48 41 43 48 CF -> MUCHACHO
		0xc3 -> 46 55 C5 -> FUE
		0xc4 -> 42 55 45 4E C1 -> BUENA
		0xc5 -> 49 44 45 C1 -> IDEA
		0xc6 -> 51 55 49 45 52 CF -> QUIERO
		0xc7 -> 43 4F 4E 4F 5A C3 -> CONOZC
		0xc8 -> 48 4F 4D 42 52 C5 -> HOMBRE
		0xc9 -> 4D 41 D3 -> MAS
		0xca -> 56 49 45 4A CF -> VIEJO
		0xcb -> 53 41 42 49 CF -> SABIO
		0xcc -> 4E 55 45 53 54 52 CF -> NUESTRO
		0xcd -> 48 55 45 53 50 45 C4 -> HUESPED
		0xce -> 53 45 C4 -> SED
		0xcf -> 56 45 4E 49 44 CF -> VENIDO
		0xd0 -> 44 49 47 CF -> DIGO
		0xd1 -> 56 49 41 D3 -> VIAS
		0xd2 -> 41 4E 54 49 43 52 49 53 54 CF -> ANTICRISTO
		0xd3 -> 53 4F CE -> SON
		0xd4 -> 4C 45 4E 54 41 D3 -> LENTAS
		0xd5 -> 54 4F 52 54 55 4F 53 41 D3 -> TORTUOSAS
		0xd6 -> 4C 4C 45 47 C1 -> LLEGAN
		0xd7 -> 43 55 41 4E 44 CF -> CUANDO
		0xd8 -> 4D 45 4E 4F D3 -> MENOS
		0xd9 -> 44 45 53 50 45 52 44 49 43 49 45 49 D3 -> DESPERDICIESIS
		0xda -> 55 4C 54 49 4D 4F D3 -> ULTIMOS
		0xdb -> 44 49 41 D3 -> DIAS
		0xdc -> 53 49 45 4E 54 CF -> SIENTO
		0xdd -> 53 55 42 49 D2 -> SUBIR
		0xde -> 53 C9 -> SI
		0xdf -> 44 45 53 C5 -> DESE
		0xe0 -> 53 43 52 49 50 54 4F 52 49 55 CD -> SCRIPTORIUM
		0xe1 -> 54 52 41 42 41 CA -> TRABAJ
		0xe2 -> 41 CE -> AN
		0xe3 -> 4D 45 4A 4F 52 45 D3 -> MEJORES
		0xe4 -> 43 4F 50 49 53 54 41 D3 -> COPISTAS
		0xe5 -> 4F 43 43 49 44 45 4E 54 C5 -> OCCIDENTE
		0xe6 -> 53 4F D9 -> SOY
		0xe7 -> 45 4E 43 41 52 47 41 44 CF -> ENCARGADO
		0xe8 -> 48 4F 53 50 49 54 41 CC -> HOSPITAL
		0xe9 -> 45 53 54 C1 -> ESTA
		0xea -> 53 55 43 45 44 45 CE -> SUCEDEN
		0xeb -> 43 4F 53 41 D3 -> COSAS
		0xec -> 41 4C 47 55 49 45 CE -> ALGUIEN
		0xed -> 0xe0 -> 51 55 49 45 52 C5 -> QUIERE
		0xee -> 44 45 43 49 44 41 CE -> DECIDAN

; tabla de frases
BB00: 	0x00 -> 00 F9 01 02 03 FE 04 05 06 07 08 09 F9 01 0A 0B	F9 01 0C 0D FF
				SECRETUM FINISH AFRICAE, MANUS SUPRA XXX AGE PRIMUM ET SEPTIMUM DE QUATOR
		0x01 -> 0E F9 0F F9 10 11 12 F9 11 13 FE 14 FD 15 16 17 18 19 F9 1A FD 1B 1C F9 1D 1E 1F FF
				BIENVENIDO A ESTA ABADIA, HERMANO. OS RUEGO QUE ME SIGAIS. HA SUCEDIDO ALGO TERRIBLE
		0x02 -> 20 17 21 F9 10 0C 22 23 F9 24 1B 25 F9 0A F9 1D 21 26 FD 15 16 17 27 28 F9 29 2A F9 24 0C 17 2B F9 2C 2D 2E FE 2F F9 24 30 0C F9 31 F9 10 17 31 32 F9 2C 33 34 0C 12 F9 11 13 FF
				TEMO QUE UNO DE LOS MONJES HA COMETIDO UN CRIMEN. OS RUEGO QUE LO ENCONTREIS ANTES DE QUE LLEGUE BERNARDO GUI, PUES	NO DESEO QUE SE MANCHE EL NOMBRE DE ESTA ABADIA
		0x03 -> 35 F9 29 36 F9 37 38 F9 24 39 F9 3A 3B 3C 0C 3D 13 FD 3E 11 22 3F 3B 11 3D 25 F9 40 FD 0C 41 35 F9 29 12 F9 37 42 43 F9 11 44 FF
				DEBEIS RESPETAR MIS ORDENES Y LAS DE LA ABADIA. ASISTIR A LOS OFICIOS Y A LA COMIDA. DE NOCHE DEBEIS ESTAR EN VUESTRA CELDA
		0x04 -> 45 33 46 0C 47 10 48 F9 2C 49 4A FF
				DEJAD EL MANUSCRITO DE VENACIO O ADVERTIRE AL ABAD
		0x05 -> 4B F9 18 33 46 FE 4C 4D FF
				DADME EL MANUSCRITO, FRAY GUILLERMO
		0x06 -> 4E F9 1A 4F	FE 4C 4D FF
				LLEGAIS TARDE, FRAY GUILLERMO
		0x07 -> 12 F9 11 3A 43 F9 11 44 FD 35 F9 10	50 F9 18 FF
				ESTA ES VUESTRA CELDA, DEBO IRME
		0x08 ->	15 39 F9 10 17 51 F9 1A FF
				OS ORDENO QUE VENGAIS
		0x09 -> 35 F9 29 52 F9 37 53 FE 14 FF
				DEBEIS ABANDONAR EDIFICIO, HERMANO
		0x0a -> 48 F9 2C 49 4A FF
				ADVERTIRE AL ABAD
		0x0b -> 35 F9 54 50 11 3D 55 FE 56 FF
				DEBEMOS IR A LA IGLESIA, MAESTRO
		0x0c -> 35 F9 54 50 49 57 FE 56 FF
				DEBEMOS IR AL REFECTORIO, MAESTRO
		0x0d -> 58 F9 29 50 11 43 F9 59 44 F9 24 FF
				PODEIS IR A VUESTRAS CELDAS
		0x0e -> 30 5A 36 F9	5B 38 F9 24 5C FD 52 F9 5D 5E 5F 12 F9 11 13 FF
				NO HABEIS RESPETADO MIS ORDENES. ABANDONAD PARA SIEMPRE ESTA ABADIA
		0x0f -> 60 14 FE 61 28 F9 5B 21 62 F9 10 63 42 38 44 FF
				ESCUCHAD HERMANO, HE ENCONTRADO UN EXTRAÑO LIBRO EN MI CELDA
		0x10 -> 64 F9 5D 42 43 F9 11 44 FE 4C 4D FF
				ENTRAD EN VUESTRA CELDA, FRAY GUILLERMO
		0x11 -> 1B 4E F9 5B 2D FE 35 F9 29 52 F9 37 3D 65 FF
				HA LLEGADO BERNARDO, DEBEIS ABANDONAR LA INVESTIGACION
		0x12 -> FA 66 FB FE 56 FF
				¿DORMIMOS?, MAESTRO
		0x13 -> 35 F9 54 28 F9 37 67 68 FE 56 FF
				DEBEMOS ENCONTRAR UNA LAMPARA, MAESTRO
		0x14 -> 0F 69 FE 4C 4D FF
				VENID AQUI, FRAY GUILLERMO
		0x15 -> 14 F9 24 FE 47 1B 6A 6B F9 5B FF
				HERMANOS, VENACIO HA SIDO ASESINADO
		0x16 -> 35 F9 29 6C 17 3D 6D 3A 21 6E 00 F9 10 FD 6F 70 2F F9 0C 64 F9 37 FD 58 F9 29 50 F9 15 FF
				DEBEIS SABER QUE LA BIBLIOTECA ES UN LUGAR SECRETO. SOLO MALAQUIAS PUEDE ENTRAR. PODEIS IROS
		0x17 -> 71 F9 54 FF
				OREMOS
		0x18 -> 14 F9 24 FE 72 1B 73 FD 20 17 31 74 25 F9 0A F9 1D 75 26 FF
				HERMANOS, BERENGARIO HA DESAPARECIDO. TEMO QUE SE HAYA COMETIDO OTRO CRIMEN
		0x19 -> 58 F9 29 25 F9 76 FE 14 F9 24 FF
				PODEIS COMER, HERMANOS
		0x1a -> 14 F9 24 FE 77 28 F9 5B 11 72 6B F9 5B FF
				HERMANOS, HAN ENCONTRADO A BERENGARIO ASESINADO
		0x1b -> 0F FE 4C 4D	FE 35 F9 54 28 F9 37 11 78 FF
				VENID, FRAY GUILLERMO, DEBEMOS ENCONTRAR A SEVERINO
		0x1c -> 79 7A FD FD FD 77 6B F9 5B 11 78 3B 7B 77 42 F9 7C F9 5B FF
				DIOS SANTO... HAN ASESINADO A SEVERINO Y LE HAN ENCERRADO
		0x1d -> 2D 52 F9 37 F9 11 7D 3D 13 FF
				BERNARDO ABANDONARA HOY LA ABADIA
		0x1e -> 7E FE 52 F9 37 F9 29 3D	13 FF
				MAÑANA ABANDONAREIS LA ABADIA
		0x1f -> 76 F9 11 7F F9 4B FE 80 33 58 F9 76 0C 81 82 FF
				ERA VERDAD, TENIA EL PODER DE MIL ESCORPIONES
		0x20 -> 70 1B 83 FF
				MALAQUIAS HA MUERTO
		0x21 -> 84 85 FE 4D FD FD FD 86 FE 15 12 F9 87 88 F9 89 FD 8A FE 69 12 F9 11 43 F9 10 8B FF
				SOIS VOS, GUILERMO... PASAD, OS ESTABA ESPERANDO. TOMAD, AQUI ESTA VUESTRO PREMIO
		0x22 -> 12 F9 1A 83 FE 4C 4D FE 5A 8C 42 3D 8D FF
				ESTAIS MUERTO, FRAY GUILLERMO, HABEIS CAIDO EN LA TRAMPA
		0x23 -> 8E 8F FE 85 30 58 F9 29 7F F9 27 FE 90 38 56 91	92 FD 5E 93 22 94 95 17 96 22 97 42 3D 98 FE 99	17 9A 9B 9C 9D FF
				VENERABLE JORGE, VOIS NO PODEIS VERLO, PERO MI MAESTRO LLEVA GUANTES.  PARA SEPARAR LOS FOLIOS TENDRIA QUE HUMEDECER LOS DEDOS EN LA LENGUA, HASTA QUE HUBIERA RECIBIDO SUFICIENTE VENENO
		0x24 -> 31 12 F9 11 25 F9 9E 33 63 FE 56 FF
				SE ESTA COMIENDO EL LIBRO, MAESTRO
		0x25 -> 35 F9 29 52 F9 37 3B F9 11 3D 13 FF
				DEBEIS ABANDONAR YA LA ABADIA
		0x26 -> 3A 9F 62 F9 10 FE 14 4D FD 72 80 32 F9 59 A0 42 3D 98 3B 42 22 97 FF
				ES MUY EXTRAÑO, HERMANO GUILLERMO. BERENGARIO TENIA MANCHAS NEGRAS EN LA LENGUA Y EN LOS DEDOS
		0x27 -> A1 A2 F9 A3 FE 56 FF
				PRONTO AMANECERA, MAESTRO
		0x28 -> 3D 68 31 A4 F9 11 FF
				LA LAMPARA SE AGOTA
		0x29 -> 5A 64 F9 5B 42 38 44 FF
				HABEIS ENTRADO EN MI CELDA
		0x2a -> 31 1B A4 F9 5B 3D 68 FF
				SE HA AGOTADO LA LAMPARA
		0x2b -> A5 A6 F9 54 A7 0C 69 FF
				JAMAS CONSEGUIREMOS SALIR DE AQUI
		0x2c -> 88 F9 5D FE 14 FF
				ESPERAD, HERMANO
		0x2d -> A8 43 F9 10 A9 FE 4C 4D FF
				OCUPAD VUESTRO SITIO, FRAY GUILLERMO
		0x2e -> 3A 33 AA AB 0C AC FD AD AE AF F9 17 80 17 B0 FD B1 B2 B3 AF 33 B4 1B B5 67 B6 B7 6C 0C 3D B8 FD 31 17 61 B9 BA 3D BB B7 BC FD FD FD BD FE 2F F9 24 FE 4C 4D FD BE BF 27 C0 F9 2C 11 C1 C2 FF
				ES EL COENA CIPRIANI DE ARISTOTELES. AHORA COMPRENDEREIS POR QUE TENIA QUE PROTEGERLO. CADA PALABRA ESCRITA POR EL FILOSOFO HA DESTRUIDO UNA PARTE DEL SABER DE LA CRISTIANDAD. SE QUE HE ACTUADO SIGUIENDO LA VOLUNTAD DEL SEÑOR... LEEDLO, PUES, FRAY GUILLERMO. DESPUES TE LO MOSTRATE A TI MUCHACHO
		0x2f -> C3 67 C4 C5 FA 7F F9 4B FB FC 90 3B F9 11 3A 4F FF
				FUE UNA BUENA IDEA ¿VERDAD?; PERO YA ES TARDE
		0x30 -> C6 17 C7 F9 1A 49 C8 C9 CA 3B CB 0C 3D 13 FF
				QUIERO QUE CONOZCAIS AL HOMBRE MAS VIEJO Y SABIO DE LA ABADIA
		0x31 -> 8E 8F FE 33 17 12 F9 11 2A 85 3A 4C 4D FE CC CD FF
				VENERABLE JORGE, EL QUE ESTA ANTE VOS ES FRAY GUILLERMO, NUESTRO HUESPED
		0x32 -> CE 0E F9 CF FE 8E 14 FC 3B 60 27 17 15 D0 FD 3C D1 B7 D2 D3 D4 3B D5 FD D6 D7 D8 27 88 F9 59 FD 30 D9 22 DA DB FF
				SED BIENVENIDO, VENERABLE HERMANO; Y ESCUCHAD LO QUE OS DIGO. LAS VIAS DEL ANTICRISTO SON LENTAS Y TORTUOSAS. LLEGA CUANDO MENOS LO ESPERAS. NO DESPERDICIEIS LOS ULTIMOS DIAS
		0x33 -> 27 DC FE 8E 14 FE 30 58 F9 29 DD 11 3D 6D FF
				LO SIENTO, VENERABLE HERMANO, NO PODEIS SUBIR A LA BIBLIOTECA
		0x34 -> DE 27 DF F9 1A FE 72 15 C0 F9 11 33 E0 FF
				SI LO DESEAIS, BERENGARIO OS MOSTRARA EL SCRIPTORIUM
		0x35 -> 69 E1 F9 E2 22 E3 E4 0C E5 FF
				AQUI TRABAJAN LOS MEJORES COPISTAS DE OCCIDENTE
		0x36 -> 69 E1 F9 87 47 FF
				AQUI TRABAJABA VENACIO
		0x37 -> 8E 14 FE E6 78 FE 33 E7 B7 E8 FD C6 48 F9 15 17 42 E9 13 EA EB 9F 62 F9 59 FD EC 30 ED 17 22 23 F9 24 EE AF DE 6F F9 24 27 17 35 F9 42 6C FF
				VENERABLE HERMANO, SOY SEVERINO, EL ENCARGADO DEL HOSPITAL. QUIERO ADVERTIROS QUE EN ESTA ABADIA SUCEDEN COSAS MUY EXTRAÑAS. ALGUIEN NO QUIERE QUE LOS MONJES DECIDAN POR SI SOLOS LO QUE DEBEN SABER

		00 00 00 00
		00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
		00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
		00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
		00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
		00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
		00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00

BF00:	7E 3C 7E 3C 7E 3C 7E 3C 7E 3C 7E 3C 7E 3C 7E 3C
		7E 3C 7E 3C 7E 3C 7E 3C 7E 3C 7E 3C 7E 3C 7E 3C
		7E 3C 7E 3C 7E 3C 7E 3C 7E 3C 7E 3C 7E 3C 7E 3C
		7E 3C 7E 3C 7E 3C 7E 3C 7E 3C 7E 3C 7E 3C 7E 3C
		7E 3C 7E 3C 7E 3C 7E 3C 7E 24 7E 3C 7E 3C 04 01
		88 A8 00 3C 7E 3C 7E 3C 7E 3C 7E 3C 7E 3C 7E 3C
		50 10 7E 3C 7E 3C 7E 3C 7E 3C 6E 2C 7E 3C 7E 3C
		7E 3C 7E 3C 7E 3C 7E 3C 7E 3C 7E 3C 7E 3C 7E 3C
		FE BD FE BD FE BD FE BD FE BD FE BD FE BD FF BD
		FE BD FF BD FF BD 00 F7 49 1D D2 00 00 F7 00 F7
		49 1D DC 00 53 B9 00 F7 00 F7 00 F7 00 F7 00 F7
		49 1D DC 00 D2 00 53 B9 00 F7 4C BE 00 23 B0 AB
		FC C8 0A C9 00 00 D2 00 53 B9 4C 00 CF C8 45 00
		55 BE 00 00 58 BE 56 C5 F1 D9 F4 62 2D 65 F4 F4
		62 F4 62 F4 62 F4 62 F4 62 1C 17 4C 02 F4 62 AC
		FF 03 FF 03 FF C7 01 03 01 CB 02 83 05 8A 02 DE
