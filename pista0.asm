; ------------- código que hay en la pista 0, sector 0 del disco del juego ---------------------------
;  (aquí llega después de poner "|cpm" el el AMSDOS)
0100: F3          di
0101: 31 00 01    ld   sp,$0100		; pone la pila
0104: 21 00 04    ld   hl,$0400
0107: E5          push hl           ; mete como dirección de retorno 0x400
0108: 01 8C 7F    ld   bc,$7F8C     ; gate array -> 10001100 (select screen mode, rom cfig and int control)
010B: ED 49       out  (c),c        ;  selecciona el modo 0 y deshabilita la rom superior e inferior
010D: CD 82 01    call $0182		; escribe la paleta de colores para la imagen de presentación
		14 1B 1F 1C 00 1D 0E 05 0D 15 04 0C 06 03 0B 14 07 	; color del borde y de las plumas (del 15 al 0)

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
0156: C9          ret				; salta al inicio del juego (0x0400)

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

; escribe la paleta de colores para la imagen de presentación
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
		01 -> número de pista (modificada desde fuera)
		00 -> cabeza 0
		21 -> número de sector inicial de la lectura
		01 -> número de bytes por sector (en múltiplos de 0x100)
		2F -> número de sector final de la lectura
		0E -> longitud de separación (GAP3)
		1F -> no usado

; -------------------- esta parte de código no se usa nunca -----------------------
022C: 3E 08       ld   a,$08		; comando para obtener información del estado
022E: CD F8 01    call $01F8		; espera a que la unidad esté lista, y si se puede, se mandan datos
0231: CD CD 01    call $01CD		; lee los bytes que manda la unidad de disco después de un comando, y los guarda en un buffer
0234: C9          ret

; espera una cantidad de tiempo proporcional a a y de
0235: F5          push af
0236: 1B          dec  de
0237: 7B          ld   a,e
0238: B2          or   d
0239: 20 FB       jr   nz,$0236		; mientras de no sea 0, lo decrementa
023B: F1          pop  af
023C: 3D          dec  a			; repite a veces
023D: 20 F6       jr   nz,$0235
023F: C9          ret

; escribe el comando apuntado por de a la unidad
0240: 1A          ld   a,(de)
0241: 13          inc  de
0242: F5          push af
0243: 1A          ld   a,(de)
0244: CD F8 01    call $01F8		; espera a que la unidad esté lista, y si se puede, se mandan datos
0247: 13          inc  de
0248: F1          pop  af
0249: 3D          dec  a
024A: 20 F6       jr   nz,$0242
024C: C9          ret

; lee los bytes que manda la unidad de disco después de un comando, y los guarda en un buffer
024D: E5          push hl
024E: D5          push de
024F: 16 00       ld   d,$00
0251: 21 64 00    ld   hl,$0064
0254: E5          push hl
0255: ED 78       in   a,(c)
0257: FE C0       cp   $C0
0259: 38 FA       jr   c,$0255
025B: 0C          inc  c
025C: ED 78       in   a,(c)
025E: 0D          dec  c
025F: 77          ld   (hl),a
0260: 23          inc  hl
0261: 14          inc  d
0262: 3E 05       ld   a,$05
0264: 3D          dec  a
0265: 20 00       jr   nz,$0267
; la rutina está incompleta...
;  de 0x267 a 0x3ff hay 0x00
; -----------------------------------------------------------------
