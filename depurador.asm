; ------------ Desensamblado comentado del depurador que trae "La abadía del crimen", por Manuel Abadía  -----------
; el depurador se comienza a cargar en 0x6200. Las referencias al depurador en el código original se han 
; eliminado, pero probablemente este depurador fue usado por Paco Menendez para depurar el juego.
; el depurador interactua  con una rom de expansión que no tenemos, por lo que no sabemos que código
; se recibe desde la rom de expansión
; ------------------------------------------------------------------------------------------------------------------



; ------------------- código copiado al cargar el depurador ---------------------
; aquí llega después de volver del programa cuando se ha pulsado la opción correr el programa
0048: F5          push af
0049: 22 79 00    ld   ($0079),hl	; guarda af y hl
004C: E1          pop  hl
004D: 22 75 00    ld   ($0075),hl
0050: 3E 00       ld   a,$00		; modificado con el contador
0052: D6 01       sub  $01			; decrementa el contador
0054: 38 05       jr   c,$005B		; si el contador es 0, salta

0056: 32 51 00    ld   ($0051),a	; si el contador no es 0, lo decrementa y sigue ejecutando
0059: 18 19       jr   $0074

; aquí llega si el contador es 0
005B: 2A 75 00    ld   hl,($0075)	; recupera af y hl
005E: E5          push hl
005F: 2A 79 00    ld   hl,($0079)
0062: F1          pop  af
0063: 00          nop				; modificado desde fuera con la condición para meter en la pila el registro de la condición
0064: E5          push hl
0065: E1          pop  hl
0066: 7D          ld   a,l
0067: E6 00       and  $00			; modificado con la parte inferior de la máscara de la condición
0069: EE 00       xor  $00			; modificado con la parte inferior del valor de la condición
006B: 20 07       jr   nz,$0074		; si no se cumple la condición, sigue ejecutando
006D: 7C          ld   a,h
006E: E6 00       and  $00			; modificado con la parte superior de la máscara de la condición
0070: EE 00       xor  $00			; modificado con la parte superior del valor de la condición
0072: 28 0A       jr   z,$007E		; si se cumple la condición, salta al depurador

; aquí salta para seguir ejecutando código
0074: 21 00 00    ld   hl,$0000		; recupera af y hl
0077: E5          push hl
0078: 21 00 00    ld   hl,$0000
007B: F1          pop  af
007C: 00          nop				; aquí se guarda el valor que había en la posición del break point activo
007D: C9          ret				; salta al pc

; aquí llega si se pulsa 2 en el menu que sale al pulsar escape en el depurador (salto a mons)
007E: 60          ld   h,b			; hl = bc
007F: 69          ld   l,c
0080: 01 C4 7F    ld   bc,$7FC4		; fija configuracion 4 (0, 4, 2, 3)
0083: ED 49       out  (c),c
0085: C3 6C 6C    jp   $6C6C		; muestra el depurador

; aquí salta si se pulsa J, después de restaurar los registros, meter en 0x0075-0x0076 af, meter en 0x0079-0x007a hl, y bc en hl
0088: 01 C0 7F    ld   bc,$7FC0
008B: ED 49       out  (c),c		; fija la configuración 0 (0, 1, 2, 3)
008D: 44          ld   b,h			; bc = hl
008E: 4D          ld   c,l
008F: 37          scf				; pone a 1 el flag de acarreo
0090: 38 09       jr   c,$009B		; cambiado desde fuera (jr c o jr nc), según la dirección del break point activo y el pc

; si se va a ejectuar, recupera hl y af y salta al PC
0092: 2A 75 00    ld   hl,($0075)
0095: E5          push hl
0096: 2A 79 00    ld   hl,($0079)
0099: F1          pop  af
009A: C9          ret

; aquí llega si se ha saltado a donde estaba un break point
009B: E1          pop  hl			; obtiene la dirección de retorno y la avanza en una unidad
009C: 23          inc  hl
009D: E5          push hl
009E: 18 D4       jr   $0074		; ejecuta el código desde la siguiente instrucción

; devuelve en a un byte leido de hl fijando la configuración original (luego restaura la configuración de depuración)
00A0: 01 C0 7F    ld   bc,$7FC0		; fija configuracion 0 (0, 1, 2, 3)
00A3: ED 49       out  (c),c
00A5: 7E          ld   a,(hl)

00A6: 0E C4       ld   c,$C4		; fija configuracion 4 (0, 4, 2, 3)
00A8: ED 49       out  (c),c
00AA: C9          ret

; fija configuracion 0 (0, 1, 2, 3), escribe a en hl y fija configuracion 4 (0, 4, 2, 3)
00AB: 01 C0 7F    ld   bc,$7FC0		; fija configuracion 0 (0, 1, 2, 3)
00AE: ED 49       out  (c),c
00B0: 77          ld   (hl),a		; modifica un valor
00B1: 18 F3       jr   $00A6

; aquí llega si se pulsa 1 en el menu que sale al pulsar escape en el depurador (correr el programa)
00B3: C1          pop  bc			; recupera la dirección de retorno
00B4: 01 30 00    ld   bc,$0030
00B7: C5          push bc			; pone 0x0030 como dirección de retorno (en donde hay un jp 0x0048)
00B8: 3A 34 65    ld   a,($6534)	; obtiene el modo de pantalla en el que se estaba
00BB: 01 8C 7F    ld   bc,$7F8C		; gate array -> 10001100 (select screen mode, rom cfig and int control)
00BE: B1          or   c			; deshabilita la rom superior e inferior
00BF: 4F          ld   c,a			; combina el modo de pantalla
00C0: ED 49       out  (c),c
00C2: 01 C0 7F    ld   bc,$7FC0		; fija configuracion 0 (0, 1, 2, 3)
00C5: ED 49       out  (c),c
00C7: C3 00 01    jp   $0100		; salta al inicio del programa

; fija configuracion 5 (0, 5, 2, 3), copia 0x4000 bytes de hl a de y fija configuracion 4 (0, 4, 2, 3)
00CA: 01 C5 7F    ld   bc,$7FC5		; fija configuracion 5 (0, 5, 2, 3)
00CD: ED 49       out  (c),c
00CF: 01 00 40    ld   bc,$4000		; 0x4000 bytes
00D2: ED B0       ldir
00D4: 01 C4 7F    ld   bc,$7FC4		; fija configuracion 4 (0, 4, 2, 3)
00D7: ED 49       out  (c),c
00D9: C9          ret
00DA-00FF: 00
; ------------------- fin del código copiado al cargar el depurador ---------------------

; tabla de mnemónicos (separados por 0x0d)
4000: 	0x00 -> nop
		0x01 -> ld bc,G
		0x02 -> ld (bc),a
 		0x03 -> inc bc
 		0x04 -> inc b
 		0x05 -> dec b
 		0x06 -> ld b,N
 		0x07 -> rlca
 		0x08 -> ex af,af'
 		0x09 -> add,I,bc
 		0x0a -> ld a,(bc)
 		0x0b -> dec bc
 		0x0c -> inc c
 		0x0d -> dec c
 		0x0e -> ld c,N
 		0x0f -> rrca
 		0x10 -> djnz D
 		0x11 -> ld de,G
 		0x12 -> ld (de),a
 		0x13 -> inc de
 		0x14 -> inc d
 		0x15 -> dec d
 		0x16 -> ld d,N
 		0x17 -> rla
 		0x18 -> jr D
 		0x19 -> add I,de
 		0x1a -> ld a,(de)
 		0x1b -> dec de
 		0x1c -> inc e
 		0x1d -> dec e
  		0x1e -> ld e,N
 		0x1f -> rra
 		0x20 -> jr nz,D
 		0x21 -> ld I,G
 		0x22 -> ld (G),I
 		0x23 -> inc I
 		0x24 -> inc h
 		0x25 -> dec h
 		0x26 -> ld h,N
 		0x27 -> daa
 		0x28 -> jr z,D
 		0x29 -> add I,I
 		0x2a -> ld I,(G)
 		0x2b -> dec I
 		0x2c -> inc l
 		0x2d -> dec l
 		0x2e -> ld l,N
 		0x2f -> cpl
 		0x30 -> jr nc,D
 		0x31 -> ld sp,G
 		0x32 -> ld (G),a
 		0x33 -> inc sp
 		0x34 -> inc (H)
 		0x35 -> dec (H)
 		0x36 -> ld (H),N
 		0x37 -> scf
 		0x38 -> jr c,D
 		0x39 -> add I,sp
 		0x3a -> ld a,(G)
 		0x3b -> dec sp
 		0x3c -> inc a
 		0x3d -> dec a
 		0x3e -> ld a,N
 		0x3f -> ccf
 		0x40 -> ld b,b
 		0x41 -> ld b,c
 		0x42 -> ld b,d
		0x43 -> ld b,d
		0x44 -> ld b,h
 		0x45 -> ld b,l
 		0x46 -> ld b,(H)
 		0x47 -> ld b,a
 		0x48 -> ld c,b
 		0x49 -> ld c,c
 		0x4a -> ld c,d
 		0x4b -> ld c,e
 		0x4c -> ld c,h
 		0x4d -> ld c,l
 		0x4e -> ld c,(H)
 		0x4f -> ld c,a
 		0x50 -> ld d,b
 		0x51 -> ld d,c
 		0x52 -> ld d,d
 		0x53 -> ld d,e
 		0x54 -> ld d,h
 		0x55 -> ld d,l
 		0x56 -> ld d,(H)
 		0x57 -> ld d,a
 		0x58 -> ld e,b
 		0x59 -> ld e,c
 		0x5a -> ld e,d
 		0x5b -> ld e,e
		0x5c -> ld e,h
 		0x5d -> ld e,l
  		0x5e -> ld e,(H)
 		0x5f -> ld e,a
 		0x60 -> ld h,b
 		0x61 -> ld h,c
 		0x62 -> ld h,d
 		0x63 -> ld h,e
 		0x64 -> ld h,h
 		0x65 -> ld h,l
 		0x66 -> ld h,(H)
 		0x67 -> ld h,a
 		0x68 -> ld l,b
 		0x69 -> ld l,c
 		0x6a -> ld l,d
 		0x6b -> ld l,e
 		0x6c -> ld l,h
 		0x6d -> ld l,l
 		0x6e -> ld l,(H)
 		0x6f -> ld (H),a
 		0x70 -> ld (H),b
 		0x71 -> ld (H),c
 		0x72 -> ld (H),d
 		0x73 -> ld (H),e
 		0x74 -> ld (H),h
 		0x75 -> ld (H),l
 		0x76 -> halt
 		0x77 -> ld (H),a
 		0x78 -> ld a,b
 		0x79 -> ld a,c
 		0x7a -> ld a,d
 		0x7b -> ld a,e
 		0x7c -> ld a,h
  		0x7d -> ld a,l
  		0x7e -> ld a,(H)
  		0x7f -> ld a,a
  		0x80 -> add a,b
  		0x81 -> add a,c
  		0x82 -> add a,d
  		0x83 -> add a,e
  		0x84 -> add a,h
  		0x85 -> add a,l
  		0x86 -> add a,(H)
  		0x87 -> add a,a
  		0x88 -> adc a,b
  		0x89 -> adc a,c
  		0x8a -> adc a,d
  		0x8b -> adc a,e
  		0x8c -> adc a,h
  		0x8d -> adc a,l
  		0x8e -> adc a,(H)
  		0x8f -> adc a,a
  		0x90 -> sub b
  		0x91 -> sub c
  		0x92 -> sub d
  		0x93 -> sub e
  		0x94 -> sub h
  		0x95 -> sub l
  		0x96 -> sub (H)
  		0x97 -> sub a
  		0x98 -> sbc a,b
  		0x99 -> sbc a,c
  		0x9a -> sbc a,d
  		0x9b -> sbc a,e
  		0x9c -> sbc a,h
  		0x9d -> sbc a,l
  		0x9e -> sbc a,(H)
  		0x9f -> sbc a,a
  		0xa0 -> and b
  		0xa1 -> and c
  		0xa2 -> and d
  		0xa3 -> and e
  		0xa4 -> and h
  		0xa5 -> and l
  		0xa6 -> and (H)
  		0xa7 -> and a
  		0xa8 -> xor b
  		0xa9 -> xor c
  		0xaa -> xor d
  		0xab -> xor e
  		0xac -> xor h
  		0xad -> xor l
  		0xae -> xor (H)
  		0xaf -> xor a
  		0xb0 -> or b
  		0xb1 -> or c
  		0xb2 -> or d
  		0xb3 -> or e
  		0xb4 -> or h
  		0xb5 -> or l
  		0xb6 -> or (H)
  		0xb7 -> or a
  		0xb8 -> cp b
  		0xb9 -> cp c
  		0xba -> cp d
  		0xbb -> cp e
  		0xbc -> cp h
  		0xbd -> cp l
  		0xbe -> cp (H)
  		0xbf -> cp a
  		0xc0 -> ret nz
  		0xc1 -> pop bc
  		0xc2 -> jp nz,G
  		0xc3 -> jp G
  		0xc4 -> call nz,G
  		0xc5 -> push bc
  		0xc6 -> add a,N
  		0xc7 -> rst 0
  		0xc8 -> ret z
  		0xc9 -> ret
  		0xca -> jp z,G
  		0xcb -> C
  		0xcc -> call z,G
  		0xcd -> call G
  		0xce -> adc a,N
  		0xcf -> rst 8
  		0xd0 -> ret nc
  		0xd1 -> pop de
  		0xd2 -> jp nc,G
  		0xd3 -> out (N),a
  		0xd4 -> call nc,G
  		0xd5 -> push de
  		0xd6 -> sub N
  		0xd7 -> rst 16
  		0xd8 -> ret c
  		0xd9 -> exx
  		0xda -> jp c,G
  		0xdb -> in a,(N)
  		0xdc -> call c,G
  		0xdd -> X
  		0xde -> sbc a,N
  		0xdf -> rst 24
  		0xe0 -> ret po
  		0xe1 -> pop I
  		0xe2 -> jp po,G
  		0xe3 -> ex (sp),I
  		0xe4 -> call po,G
  		0xe5 -> push I
  		0xe6 -> and N
  		0xe7 -> rst 32
  		0xe8 -> ret pe
  		0xe9 -> jp (I)
  		0xea -> jp pe,G
  		0xeb -> ex de,I
  		0xec -> call pe,G
  		0xed -> E
  		0xee -> xor N
  		0xef -> rst 40
  		0xf0 -> ret p
  		0xf1 -> pop af
  		0xf2 -> jp p,G
  		0xf3 -> di
  		0xf4 -> call p,G
  		0xf5 -> push af
  		0xf6 -> or n
  		0xf7 -> rst 48
  		0xf8 -> ret m
  		0xf9 -> ld sp,I
  		0xfa -> jp m,G
  		0xfb -> ei
  		0xfc -> call m,G
  		0xfd -> Y
  		0xfe -> cp N
  		0xff -> rst 56

466E-4A37: 00

; tabla de mnemónicos auxiliar para 0xcb (los de tipo C) (separados por 0x0d)
4A38: 	0x00 -> rlc b
		0x01 -> rlc c
		0x02 -> rlc d
		0x03 -> rlc e
		0x04 -> rlc h
		0x05 -> rlc l
		0x06 -> rlc (H)
		0x07 -> rlc a
		0x08 -> rrc b
		0x09 -> rrc c
		0x0a -> rrc d
		0x0b -> rrc e
		0x0c -> rrc h
		0x0d -> rrc l
		0x0e -> rr c (H)
		0x0f -> rrc a
		0x10 -> rl b
 		0x11 -> rl c
		0x12 -> rl d
		0x13 -> rl e
		0x14 -> rl h
		0x15 -> rl l
		0x16 -> rl (H)
 		0x17 -> rl a
		0x18 -> rr b
		0x19 -> rr c
		0x1a -> rr d
		0x1b -> rr e
		0x1c -> rr h
		0x1d -> rr l
		0x1e -> rr (H)
		0x1f -> rr a
		0x20 -> sla b
		0x21 -> sla c
		0x22 -> sla d
		0x23 -> sla e
		0x24 -> sla h
		0x25 -> sl a l
		0x26 -> sla (H)
		0x27 -> sla a
		0x28 -> sra b
		0x29 -> sra c
		0x2a -> sra d
		0x2b -> sra e
		0x2c -> sra h
		0x2d -> sra l
		0x2e -> sra (H)
		0x2f -> sra a
		0x30 ->
		0x31 ->
		0x32 ->
		0x33 ->
		0x34 ->
		0x35 ->
		0x36 ->
		0x37 ->
		0x38 -> srl b
		0x39 -> srl c
		0x3a -> srl d
		0x3b -> srl e
		0x3c -> srl h
		0x3d -> srl l
		0x3e -> srl (H)
		0x3f -> srl a
		0x40 -> bit 0,b
		0x41 -> bit 0,c
		0x42 -> bit 0,d
		0x43 -> bit 0,e
		0x44 -> bit 0,h
		0x45 -> bit 0,l
		0x46 -> bit 0,(H)
		0x47 -> bit 0,a
		0x48 -> bit 1,b
		0x49 -> bit 1,c
		0x4a -> bit 1,d
		0x4b -> bit 1,e
		0x4c -> bit 1,h
		0x4d -> bit 1,l
		0x4e -> bit 1,(H)
		0x4f -> bit 1,a
		0x50 -> bit 2,b
		0x51 -> bit 2,c
		0x52 -> bit 2,d
		0x53 -> bit 2,e
		0x54 -> bit 2,h
		0x55 -> bit 2,l
		0x56 -> bit 2,(H)
		0x57 -> bit 2,a
		0x58 -> bit 3,b
		0x59 -> bit 3,c
		0x5a -> bit 3,d
		0x5b -> bit 3,e
		0x5c -> bit 3,h
		0x5d -> bit 3,l
		0x5e -> bit 3,(H)
		0x5f -> bit 3,a
		0x60 -> bit 4,b
		0x61 -> bit 4,c
		0x62 -> bit 4,d
		0x63 -> bit 4,e
		0x64 -> bit 4,h
		0x65 -> bit 4,l
		0x66 -> bit 4,(H)
		0x67 -> bit 4,a
		0x68 -> bit 5,b
		0x69 -> bit 5,c
		0x6a -> bit 5,d
		0x6b -> bit 5,e
		0x6c -> bit 5,h
		0x6d -> bit 5,l
		0x6e -> bit 5,(H)
		0x6f -> bit 5,a
		0x70 -> bit 6,b
		0x71 -> bit 6,c
		0x72 -> bit 6,d
		0x73 -> bit 6,e
		0x74 -> bit 6,h
		0x75 -> bit 6,l
		0x76 -> bit 6,(H)
		0x77 -> bit 6,a
		0x78 -> bit 7,b
		0x79 -> bit 7,c
		0x7a -> bit 7,d
		0x7b -> bit 7,e
		0x7c -> bit 7,h
		0x7d -> bit 7,l
		0x7e -> bit 7,(H)
		0x7f -> bit 7,a
		0x80 -> res 0,b
		0x81 -> res 0,c
		0x82 -> res 0,d
		0x83 -> res 0,e
		0x84 -> res 0,h
		0x85 -> res 0,l
		0x86 -> res 0,(H)
		0x87 -> res 0,a
		0x88 -> res 1,b
		0x89 -> res 1,c
		0x8a -> res 1,d
		0x8b -> res 1,e
		0x8c -> res 1,h
		0x8d -> res 1,l
		0x8e -> res 1,(H)
		0x8f -> res 1,a
		0x90 -> res 2,b
		0x91 -> res 2,c
		0x92 -> res 2,d
		0x93 -> res 2,e
		0x94 -> res 2,h
		0x95 -> res 2,l
		0x96 -> res 2,(H)
		0x97 -> res 2,a
		0x98 -> res 3,b
		0x99 -> res 3,c
		0x9a -> res 3,d
		0x9b -> res 3,e
		0x9c -> res 3,h
		0x9d -> res 3,l
		0x9e -> res 3,(H)
		0x9f -> res 3,a
		0xa0 -> res 4,b
		0xa1 -> res 4,c
		0xa2 -> res 4,d
		0xa3 -> res 4,e
		0xa4 -> res 4,h
		0xa5 -> res 4,l
		0xa6 -> res 4,(H)
		0xa7 -> res 4,a
		0xa8 -> res 5,b
		0xa9 -> res 5,c
		0xaa -> res 5,d
		0xab -> res 5,e
		0xac -> res 5,h
		0xad -> res 5,l
		0xae -> res 5,(H)
		0xaf -> res 5,a
		0xb0 -> res 6,b
		0xb1 -> res 6,c
		0xb2 -> res 6,d
		0xb3 -> res 6,e
		0xb4 -> res 6,h
		0xb5 -> res 6,l
		0xb6 -> res 6,(H)
		0xb7 -> res 6,a
		0xb8 -> res 7,b
		0xb9 -> res 7,c
		0xba -> res 7,d
		0xbb -> res 7,e
		0xbc -> res 7,h
		0xbd -> res 7,l
		0xbe -> res 7,(H)
		0xbf -> res 7,a
		0xc0 -> set 0,b
		0xc1 -> set 0,c
		0xc2 -> set 0,d
		0xc3 -> set 0,e
		0xc4 -> set 0,h
		0xc5 -> set 0,l
		0xc6 -> set 0,(H)
		0xc7 -> set 0,a
		0xc8 -> set 1,b
		0xc9 -> set 1,c
		0xca -> set 1,d
		0xcb -> set 1,e
		0xcc -> set 1,h
		0xcd -> set 1,l
		0xce -> set 1,(H)
		0xcf -> set 1,a
		0xd0 -> set 2,b
		0xd1 -> set 2,c
		0xd2 -> set 2,d
		0xd3 -> set 2,e
		0xd4 -> set 2,h
		0xd5 -> set 2,l
		0xd6 -> set 2,(H)
		0xd7 -> set 2,a
		0xd8 -> set 3,b
		0xd9 -> set 3,c
		0xda -> set 3,d
		0xdb -> set 3,e
		0xdc -> set 3,h
		0xdd -> set 3,l
		0xde -> set 3,(H)
		0xdf -> set 3,a
		0xe0 -> set 4,b
		0xe1 -> set 4,c
		0xe2 -> set 4,d
		0xe3 -> set 4,e
		0xe4 -> set 4,h
		0xe5 -> set 4,l
		0xe6 -> set 4,(H)
		0xe7 -> set 4,a
		0xe8 -> set 5,b
		0xe9 -> set 5,c
		0xea -> set 5,d
		0xeb -> set 5,e
		0xec -> set 5,h
		0xed -> set 5,l
		0xee -> set 5,(H)
		0xef -> set 5,a
		0xf0 -> set 6,b
		0xf1 -> set 6,c
		0xf2 -> set 6,d
		0xf3 -> set 6,e
		0xf4 -> set 6,h
		0xf5 -> set 6,l
		0xf6 -> set 6,(H)
		0xf7 -> set 6,a
		0xf8 -> set 7,b
		0xf9 -> set 7,c
		0xfa -> set 7,d
		0xfb -> set 7,e
		0xfc -> set 7,h
		0xfd -> set 7,l
		0xfe -> set 7,(H)
		0xff -> set 7,a

51BE-5207: 00

; tabla de mnemónicos auxiliar para 0xed (los de tipo E) (separados por 0x0d)
5208: 	0x40 -> in b,(c)
		0x41 -> out (c),b
		0x42 -> sbc hl,bc
		0x43 -> ld (G),bc
		0x44 -> neg
		0x45 -> retn
		0x46 -> im 0
		0x47 -> ldi,a
		0x48 -> in (c),c
		0x49 -> out (c),c
		0x4a -> adc hl,bc
		0x4b -> ld bc,(G)
		0x4c ->
		0x4d -> reti
		0x4e ->
		0x4f -> ld r,a
		0x50 -> in d,(c)
		0x51 -> out (c),d
		0x52 -> sbc hl,de
		0x53 -> ld (G),de
		0x54 ->
		0x55 ->
		0x56 -> im 1
		0x57 -> ld a,i
		0x58 -> in e,(c)
		0x59 -> out (c),e
		0x5a -> adc hl,de
		0x5b -> ld de,(G)
		0x5c ->
		0x5d ->
		0x5e -> im 2
		0x5f -> ld a,r
		0x60 -> in h,(c)
		0x61 -> out (c),h
		0x62 -> sbc hl,hl
		0x63 -> ld (G),hl
		0x64 ->
		0x65 ->
		0x66 ->
		0x67 -> rrd
		0x68 -> in l,(c)
		0x69 -> out (c),l
		0x6a -> adc hl,hl
		0x6b -> ld hl,(G)
		0x6c ->
		0x6d ->
		0x6e ->
		0x6f -> rld
		0x70 -> in f,(c)
		0x71 ->
		0x72 -> sbc hl,sp
		0x73 -> ld (G),hl
		0x74 ->
		0x75 ->
		0x76 ->
		0x77 ->
		0x78 -> in a,(c)
		0x79 -> out (c),a
		0x7a -> adc hl,sp
		0x7b -> ld sp,(G)
		0x7c ->
		0x7d ->
		0x7e ->
		0x7f ->
		0x80 ->
		0x81 ->
		0x82 ->
		0x83 ->
		0x84 ->
		0x85 ->
		0x86 ->
		0x87 ->
		0x88 ->
		0x89 ->
		0x8a ->
		0x8b ->
		0x8c ->
		0x8d ->
		0x8e ->
		0x8f ->
		0x90 ->
		0x91 ->
		0x92 ->
		0x93 ->
		0x94 ->
		0x95 ->
		0x96 ->
		0x97 ->
		0x98 ->
		0x99 ->
		0x9a ->
		0x9b ->
		0x9c ->
		0x9d ->
		0x9e ->
		0x9f ->
		0xa0 -> ldi
		0xa1 -> cpi
		0xa2 -> ini
		0xa3 -> outi
		0xa4 ->
		0xa5 ->
		0xa6 ->
		0xa7 ->
		0xa8 -> ldd
		0xa9 -> cpd
		0xaa -> ind
		0xab -> outd
		0xac ->
		0xad ->
		0xae ->
		0xaf ->
		0xb0 -> ldir
		0xb1 -> cpir
		0xb2 -> inir
		0xb3 -> otir
		0xb4 ->
		0xb5 ->
		0xb6 ->
		0xb7 ->
		0xb8 -> lddr
		0xb9 -> cpdr
		0xba -> indr
		0xbb -> otdr

5403-59D7: 00

; tabla de caracteres (cada carácter ocupa 8 bytes)
59D8: 	00 00 00 00 00 00 00 00 -> 0x20 (' ')
		18 18 18 18 18 00 18 00 -> 0x21 ('!')
		6C 6C 6C 00 00 00 00 00 -> 0x22 ('"')
 		6C 6C FE 6C FE 6C 6C 00 -> 0x23 ('#')
 		18 3E 58 3C 1A 7C 18 00 -> 0x24 ('$')
 		00 C6 CC 18 30 66 C6 00 -> 0x25 ('%')
 		38 6C 38 76 DC CC 76 00 -> 0x26 ('&')
 		18 18 30 00 00 00 00 00 -> 0x27 (''')
 		0C 18 30 30 30 18 0C 00 -> 0x28 ('(')
 		30 18 0C 0C 0C 18 30 00 -> 0x29 (')')
 		00 66 3C FF 3C 66 00 00 -> 0x2a ('*')
 		00 18 18 7E 18 18 00 00 -> 0x2b ('+')
 		00 00 00 00 00 18 18 30 -> 0x2c (',')
 		00 00 00 7E 00 00 00 00 -> 0x2d ('-')
 		00 00 00 00 00 18 18 00 -> 0x2e ('.')
 		06 0C 18 30 60 C0 80 00 -> 0x2f ('/')
 		7C C6 CE D6 E6 C6 7C 00 -> 0x30 ('0')
 		18 38 18 18 18 18 7E 00 -> 0x31 ('1')
 		3C 66 06 3C 60 66 7E 00 -> 0x32 ('2')
 		3C 66 06 1C 06 66 3C 00 -> 0x33 ('3')
 		1C 3C 6C CC FE 0C 1E 00 -> 0x34 ('4')
 		7E 62 60 7C 06 66 3C 00 -> 0x35 ('5')
 		3C 66 60 7C 66 66 3C 00 -> 0x36 ('6')
 		7E 66 06 0C 18 18 18 00 -> 0x37 ('7')
 		3C 66 66 3C 66 66 3C 00 -> 0x38 ('8')
 		3C 66 66 3E 06 66 3C 00 -> 0x39 ('9')
 		00 00 18 18 00 18 18 00 -> 0x3a (':')
 		00 00 18 18 00 18 18 30 -> 0x3b (';')
 		0C 18 30 60 30 18 0C 00 -> 0x3c ('<')
 		00 00 7E 00 00 7E 00 00 -> 0x3d ('=')
 		60 30 18 0C 18 30 60 00 -> 0x3e ('>')
 		3C 66 66 0C 18 00 18 00 -> 0x3f ('?')
 		7C C6 DE DE DE C0 7C 00 -> 0x40 ('@')
 		18 3C 66 66 7E 66 66 00 -> 0x41 ('A')
 		FC 66 66 7C 66 66 FC 00 -> 0x42 ('B')
 		3C 66 C0 C0 C0 66 3C 00 -> 0x43 ('C')
 		F8 6C 66 66 66 6C F8 00 -> 0x44 ('D')
 		FE 62 68 78 68 62 FE 00 -> 0x45 ('E')
 		FE 62 68 78 68 60 F0 00 -> 0x46 ('F')
 		3C 66 C0 C0 CE 66 3E 00 -> 0x47 ('G')
 		66 66 66 7E 66 66 66 00 -> 0x48 ('H')
 		7E 18 18 18 18 18 7E 00 -> 0x49 ('I')
 		1E 0C 0C 0C CC CC 78 00 -> 0x4a ('J')
 		E6 66 6C 78 6C 66 E6 00 -> 0x4b ('K')
 		F0 60 60 60 62 66 FE 00 -> 0x4c ('L')
 		C6 EE FE FE D6 C6 C6 00 -> 0x4d ('M')
 		C6 E6 F6 DE CE C6 C6 00 -> 0x4e ('N')
 		38 6C C6 C6 C6 6C 38 00 -> 0x4f ('O')
 		FC 66 66 7C 60 60 F0 00 -> 0x50 ('P')
 		38 6C C6 C6 DA CC 76 00 -> 0x51 ('Q')
 		FC 66 66 7C 6C 66 E6 00 -> 0x52 ('R')
 		3C 66 60 3C 06 66 3C 00 -> 0x53 ('S')
 		7E 5A 18 18 18 18 3C 00 -> 0x54 ('T')
 		66 66 66 66 66 66 3C 00 -> 0x55 ('U')
 		66 66 66 66 66 3C 18 00 -> 0x56 ('V')
 		C6 C6 C6 D6 FE EE C6 00 -> 0x57 ('W')
 		C6 6C 38 38 6C C6 C6 00 -> 0x58 ('X')
 		66 66 66 3C 18 18 3C 00 -> 0x59 ('Y')
 		FE C6 8C 18 32 66 FE 00 -> 0x5a ('Z')
 		3C 30 30 30 30 30 3C 00 -> 0x5b ('[')
 		C0 60 30 18 0C 06 02 00 -> 0x5c ('\')
 		3C 0C 0C 0C 0C 0C 3C 00 -> 0x5d (']')
 		18 3C 7E 18 18 18 18 00 -> 0x5e ('^')
        00 00 00 00 00 00 00 FF -> 0x5f ('_')
 		30 18 0C 00 00 00 00 00 -> 0x60 ('`')
 		00 00 78 0C 7C CC 76 00 -> 0x61 ('a')
 		E0 60 7C 66 66 66 DC 00 -> 0x62 ('b')
 		00 00 3C 66 60 66 3C 00 -> 0x63 ('c')
 		1C 0C 7C CC CC CC 76 00 -> 0x64 ('d')
 		00 00 3C 66 7E 60 3C 00 -> 0x65 ('e')
 		1C 36 30 78 30 30 78 00 -> 0x66 ('f')
 		00 00 3E 66 66 3E 06 7C -> 0x67 ('g')
		E0 60 6C 76 66 66 E6 00 -> 0x68 ('h')
 		18 00 38 18 18 18 3C 00 -> 0x69 ('i')
 		06 00 0E 06 06 66 66 3C -> 0x6a ('j')
 		E0 60 66 6C 78 6C E6 00 -> 0x6b ('k')
 		38 18 18 18 18 18 3C 00 -> 0x6c ('l')
 		00 00 6C FE D6 D6 C6 00 -> 0x6d ('m')
 		00 00 DC 66 66 66 66 00 -> 0x6e ('n')
 		00 00 3C 66 66 66 3C 00 -> 0x6f ('o')
 		00 00 DC 66 66 7C 60 F0 -> 0x70 ('p')
 		00 00 76 CC CC 7C 0C 1E -> 0x71 ('q')
 		00 00 DC 76 60 60 F0 00 -> 0x72 ('r')
 		00 00 3C 60 3C 06 7C 00 -> 0x73 ('s')
 		30 30 7C 30 30 36 1C 00 -> 0x74 ('t')
 		00 00 66 66 66 66 3E 00 -> 0x75 ('u')
 		00 00 66 66 66 3C 18 00 -> 0x76 ('v')
 		00 00 C6 D6 D6 FE 6C 00 -> 0x77 ('w')
 		00 00 C6 6C 38 6C C6 00 -> 0x78 ('x')
 		00 00 66 66 66 3E 06 7C -> 0x79 ('y')
 		00 00 7E 4C 18 32 7E 00 -> 0x7a ('z')
 		0E 18 18 70 18 18 0E 00 -> 0x7b ('{')
 		18 18 18 18 18 18 18 00 -> 0x7c ('|')
 		70 18 18 0E 18 18 70 00 -> 0x7d ('}')
 		76 DC 00 00 00 00 00 00 -> 0x7e ('~')
 		CC 33 CC 33 CC 33 CC 33 -> 0x7f (caracter para relleno)

5CD8-61FF:00

; -------------------- inicio del código que carga el depurador ---------------------------------
6200: 11 48 00    ld   de,$0048		; apunta al destino
6203: 01 B4 00    ld   bc,$00B4		; número de bytes a copiar
6206: 21 26 6E    ld   hl,$6E26		; apunta al código a copiar
6209: ED B0       ldir				; realiza la copia

620B: 3E C3       ld   a,$C3
620D: 32 30 00    ld   ($0030),a	; cambia el código de 0x30 (rst 0x30) para que salta a 0x0048
6210: 21 48 00    ld   hl,$0048
6213: 22 31 00    ld   ($0031),hl

6216: 21 7C 00    ld   hl,$007C
6219: 22 36 65    ld   ($6536),hl	; pone como break point activo 0x007c
621C: C3 7E 00    jp   $007E		; carga abadia5.bin en 0x4000 y salta a 0x6c6c
; -------------------- fin del código que carga el depurador ---------------------------------

; a este código no se llama nunca
621F: 06 0F       ld   b,$0F
6221: 21 01 00    ld   hl,$0001
6224: DD 21 01 00 ld   ix,$0001
6228: FD 21 01 00 ld   iy,$0001
622C: 11 14 00    ld   de,$0014
622F: 3E 07       ld   a,$07
6231: 23          inc  hl
6232: DD 23       inc  ix
6234: FD 23       inc  iy
6236: 1B          dec  de
6237: 10 F8       djnz $6231
6239: C9          ret

; ----------------------------------- código principal del depurador ---------------------------------------------
; una vez que se ha iniciado el depurador se salta aquí
623A: CD 12 67    call $6712		; muestra los registros y sus valores, e indica cual está seleccionado
623D: CD F5 69    call $69F5		; escribe el prompt
6240: CD 80 6B    call $6B80		; imprime el estado de los break points (y si hay alguno activo, su dirección)
6243: 21 00 00    ld   hl,$0000		; hl = 0
6246: 5D          ld   e,l			; de = 0
6247: 55          ld   d,l
6248: CD B8 6A    call $6AB8		; graba e imprime la condición actual
624B: CD 42 6B    call $6B42		; escribe el contador
624E: CD 60 64    call $6460		; muestra un volcado de la memoria de una zona o el código que hay en esa zona de memoria
6251: CD 34 68    call $6834		; muestra las 3 columnas de la parte inferior de la pantalla con el volcado de la memoria

; bucle principal del depurador
6254: DD 21 83 62 ld   ix,$6283		; apunta a la tabla de teclas y rutinas a las que llamar
6258: 3E 42       ld   a,$42
625A: CD 98 63    call $6398		; comprueba si se pulsó el escape
625D: C2 52 6D    jp   nz,$6D52		; si se pulsó el escape, salta
6260: DD 7E 00    ld   a,(ix+$00)	; lee una tecla
6263: FE FF       cp   $FF
6265: 28 ED       jr   z,$6254		; si ya se ha llegado a la última, salta

6267: CD 98 63    call $6398		; comprueba si se pulsó la tecla leida
626A: 20 08       jr   nz,$6274		; si se ha pulsado, salta
626C: DD 23       inc  ix			; avanza a la siguiente entrada
626E: DD 23       inc  ix
6270: DD 23       inc  ix
6272: 18 EC       jr   $6260		; continúa probando el resto de teclas

; aquí llega si se ha pulsado una tecla de la lista
6274: DD 6E 01    ld   l,(ix+$01)	; obtiene la dirección de la rutina asociada a la tecla
6277: DD 66 02    ld   h,(ix+$02)
627A: 11 54 62    ld   de,$6254
627D: D5          push de			; mete en la pila la dirección de retorno
627E: ED 73 C3 62 ld   ($62C3),sp
6282: E9          jp   (hl)			; salta a la rutina correspondiente

; tabla de teclas y rutinas a las que llamar (cada entrada ocupa 3 bytes)
6283: 	02 6427 -> cursor abajo -> avanza una posición de memoria
		00 642C -> cursor arriba -> retrocede una posición de memoria
		08 6436 -> cursor izquierda -> retrocede 8 posiciones de memoria
		01 6431 -> cursor derecha -> avanza 8 posiciones de memoria
		26 69DA -> 'M' -> se situa en la posición de memoria que se introduce
		07 67BD -> '.' -> avanza circularmente el registro seleccionado
		32 6BE6 -> 'R' -> modifica el registro seleccionado con el valor introducido
		33 6C0E -> 'T' -> copia unos bytes del origen al destino
		40 6A1E -> '1' -> pone el break point 1 en la dirección de memoria actual
		41 6B5C -> '2' -> pone el break point 2 en la dirección de memoria actual
		10 6A45 -> 'CLR' -> limpia los break point
		23 63E0 -> 'I' -> pide un valor y modifica lo que hay en la dirección de memoria actual
		43 6B28 -> 'Q' -> modifica el contador
		1B 6A60 -> 'P' -> modifica la condición del break point activo
		2D 6A01 -> 'J' -> lee la dirección de salto (0 era donde se quedó), restaura los registros y salta
		35 6458 -> 'F' -> cambia lo que se muestra en la parte derecha (el desensamblado o la memoria) 
		2F 63FF -> espacio -> avanza la posición actual según lo que ocupe la instrucción actual
		FF
; ------------------------------- fin del código principal del depurador -----------------------------------------

; ------------------------ código encargado de escribir caracteres y posicionar el cursor -------------------------
; pone el cursor en la posición indicada por hl (h = posición en x, l = posición en y) (origen = 1,1)
62B7: 25          dec  h
62B8: 2D          dec  l
62B9: 7D          ld   a,l
62BA: 6C          ld   l,h
62BB: 67          ld   h,a
62BC: 22 C0 62    ld   ($62C0),hl
62BF: C9          ret

62C0: 35 ; posición x del cursor
62C1: 13 ; posición y del cursor
62C2: 00 ; modo de funcionamiento de la rutina de 0x62c5

62C3-62C4: aquí guarda la pila

; si 0x62c2 es 0, escribe el carácter que se pasa en a, si es 1, fija la posición x del cursor, y si es 2, fija la posición y del cursor
; caracteres especiales: 0x1f -> cambia de estado y espera a que se le pase la posición del cursor
; caracteres especiales: 0x0d -> retorno de carro
; caracteres especiales: 0x0a -> avance de línea
; caracteres especiales: 0x08 -> retroceder la posición x del cursor
; caracteres especiales: 0x18 -> invertir el color del texto
; caracteres especiales: 0x12 -> borrar hasta el final de la línea
62C5: C5          push bc
62C6: 4F          ld   c,a			; guarda el parámetro en c
62C7: 3A C2 62    ld   a,($62C2)	; lee la función a realizar
62CA: FE 01       cp   $01
62CC: 20 0B       jr   nz,$62D9		; si no es 1, salta

; aquí llega si 0x62c2 == 0x01, con c = parámetro de la rutina
62CE: 3C          inc  a
62CF: 32 C2 62    ld   ($62C2),a	; cambia el estado para fijar la posición en y
62D2: 79          ld   a,c			; restaura el parámetro
62D3: 3D          dec  a
62D4: 32 C0 62    ld   ($62C0),a	; fija la posición x del cursor
62D7: C1          pop  bc
62D8: C9          ret

; aquí llega si 0x62c2 != 0x01
62D9: FE 02       cp   $02
62DB: 20 0B       jr   nz,$62E8		; si no es 2, salta

; aquí llega si 0x62c2 == 0x02, con c = parámetro de la rutina
62DD: AF          xor  a
62DE: 32 C2 62    ld   ($62C2),a	; cambia el estado para imprimir un carácter
62E1: 79          ld   a,c			; lee el parámetro
62E2: 3D          dec  a
62E3: 32 C1 62    ld   ($62C1),a	; fija la posición y del cursor
62E6: C1          pop  bc
62E7: C9          ret

; aquí llega si 0x62c2 == 0, con c = parámetro
62E8: 79          ld   a,c			; lee el carácter
62E9: FE 20       cp   $20
62EB: 38 1F       jr   c,$630C		; si es un caracter no imprimible, salta
62ED: D6 20       sub  $20			; en otro caso ajusta el número para la tabla de caracteres
62EF: E5          push hl
62F0: D5          push de
62F1: CD 6B 63    call $636B		; dado un caracter en a, devuelve en de un puntero a los datos que forman el caracter y en hl la posición de pantalla en donde grabarlo
62F4: 06 08       ld   b,$08		; 8 líneas
62F6: 1A          ld   a,(de)		; lee 8 pixels del caracter
62F7: EE 00       xor  $00			; instrucción modificada desde fuera (por si se quiere cambiar el color)
62F9: 77          ld   (hl),a		; escribe en pantalla los 8 pixels
62FA: 7C          ld   a,h
62FB: C6 08       add  a,$08		; pasa a la siguiente línea de pantalla
62FD: 67          ld   h,a
62FE: 13          inc  de
62FF: 10 F5       djnz $62F6		; completa las 8 líneas
6301: 3A C0 62    ld   a,($62C0)	; avanza el cursor 8 pixels
6304: 3C          inc  a
6305: 32 C0 62    ld   ($62C0),a
6308: D1          pop  de
6309: E1          pop  hl
630A: C1          pop  bc
630B: C9          ret

; aquí llega si es un carácter no imprimible
630C: C1          pop  bc
630D: FE 1F       cp   $1F
630F: 20 06       jr   nz,$6317		; si se le pasa el carácter '?', cambia de estado y espera a que se le pasen las nuevas posiciones del cursor
6311: 3E 01       ld   a,$01
6313: 32 C2 62    ld   ($62C2),a
6316: C9          ret

6317: FE 0D       cp   $0D			; si se lee CR (carriage return)
6319: 20 05       jr   nz,$6320
631B: AF          xor  a
631C: 32 C0 62    ld   ($62C0),a	; pasa a la posición 0 en x
631F: C9          ret

6320: FE 0A       cp   $0A			; si se lee LF (line feed)
6322: 20 08       jr   nz,$632C
6324: 3A C1 62    ld   a,($62C1)
6327: 3C          inc  a
6328: 32 C1 62    ld   ($62C1),a	; pasa a la siguiente línea
632B: C9          ret

632C: FE 08       cp   $08			; si se lee BS (backspace)
632E: 20 08       jr   nz,$6338
6330: 3A C0 62    ld   a,($62C0)	; retrocede la posición del cursor en x
6333: 3D          dec  a
6334: 32 C0 62    ld   ($62C0),a
6337: C9          ret

6338: FE 18       cp   $18			; si se lee 0x18
633A: 20 08       jr   nz,$6344
633C: 3A F8 62    ld   a,($62F8)	; se cambia el color del texto
633F: 2F          cpl
6340: 32 F8 62    ld   ($62F8),a
6343: C9          ret

6344: FE 12       cp   $12			; si se lee 0x12, limpia desde la posición x hasta el final de la línea
6346: C0          ret  nz			;  en otro caso, sale

6347: C5          push bc
6348: E5          push hl
6349: D5          push de
634A: CD 6B 63    call $636B		; dado un caracter en a, devuelve en de un puntero a los datos que forman el caracter y en hl la posición de pantalla en donde grabarlo
634D: 3A C0 62    ld   a,($62C0)	; lee la posición x del cursor
6350: ED 44       neg
6352: C6 50       add  a,$50
6354: 28 B2       jr   z,$6308		; si ha llegado al final de la línea en x, sale

; limpia lo que falta hasta llegar al final de línea
6356: 4F          ld   c,a			; c = 80 - pos x
6357: 06 08       ld   b,$08		; 8 líneas de alto
6359: C5          push bc
635A: E5          push hl
635B: 36 00       ld   (hl),$00		; limpia 8 pixels
635D: 23          inc  hl
635E: 0D          dec  c
635F: 20 FA       jr   nz,$635B		; repite hasta llegar al final de esta línea
6361: E1          pop  hl
6362: 7C          ld   a,h
6363: C6 08       add  a,$08		; pasa a la siguiente línea de pantalla
6365: 67          ld   h,a
6366: C1          pop  bc
6367: 10 F0       djnz $6359		; repite para 8 líneas
6369: 18 9D       jr   $6308

; dado un caracter en a, devuelve en de un puntero a los datos que forman el caracter y en hl la posición de pantalla en donde grabarlo
636B: 6F          ld   l,a
636C: 26 00       ld   h,$00		; hl = a
636E: 29          add  hl,hl
636F: 29          add  hl,hl
6370: 29          add  hl,hl		; hl = a*8 (cada caracter ocupa 8 bytes)
6371: 11 D8 59    ld   de,$59D8		; de apunta a la tabla de caracteres
6374: 19          add  hl,de		; indexa en la tabla
6375: EB          ex   de,hl		; de = datos que forman del caracter
6376: 21 00 00    ld   hl,$0000
6379: 3A C1 62    ld   a,($62C1)	; lee la posición y del cursor
637C: A7          and  a			; a = b7 b6 b5 b4 b3 b2 b1 b0
637D: 1F          rra				; a = 0 b7 b6 b5 b4 b3 b2 b1, CF = b0
637E: CB 1D       rr   l			; l = b0 0 0 0 0 0 0 0
6380: 1F          rra				; a = 0 0 b7 b6 b5 b4 b3 b2, CF = b1
6381: CB 1D       rr   l			; l = b1 b0 0 0 0 0 0 0
6383: 47          ld   b,a			; b = 0 0 b7 b6 b5 b4 b3 b2, CF = 0
6384: 4D          ld   c,l			; c = b1 b0 0 0 0 0 0 0
6385: 1F          rra				; a = 0 0 0 b7 b6 b5 b4 b3, CF = b2
6386: CB 1D       rr   l			; l = b2 b1 b0 0 0 0 0 0
6388: 1F          rra				; a = 0 0 0 0 b7 b6 b5 b4, CF = b3
6389: CB 1D       rr   l			; l = b3 b2 b1 b0 0 0 0 0
638B: F6 C0       or   $C0			; a = 1 1 0 0 b7 b6 b5 b4
638D: 67          ld   h,a			; hl = 1 1 0  0  b7 b6 b5 b4  b2 b1 b0 0 0 0 0 0
									; bc = 0 0 b7 b6 b5 b4 b3 b2  b1 b0 0  0 0 0 0 0
638E: 09          add  hl,bc
638F: 3A C0 62    ld   a,($62C0)	; lee la posición x del cursor
6392: 85          add  a,l
6393: 6F          ld   l,a
6394: 8C          adc  a,h
6395: 95          sub  l
6396: 67          ld   h,a			; hl = hl + a
6397: C9          ret
; ------------------------ fin del código encargado de escribir caracteres y posicionar el cursor -------------------------

; ------------------------ código relacionado con la pulsación de teclas --------------------------------
; comprueba si se pulsó la tecla a. si se pulsó devuelve NZ
6398: F3          di
6399: C5          push bc
639A: F5          push af
639B: 01 0E F4    ld   bc,$F40E		; 1111 0100 0000 1110 (8255 PPI puerto A)
639E: ED 49       out  (c),c
63A0: 06 F6       ld   b,$F6
63A2: ED 78       in   a,(c)
63A4: E6 30       and  $30
63A6: 4F          ld   c,a
63A7: F6 C0       or   $C0
63A9: ED 79       out  (c),a		; operación PSG escribir índice de registro (activa el 14 para comunicación por el puerto A)
63AB: ED 49       out  (c),c		; operación PSG: inactivo
63AD: 04          inc  b			; apunta al puerto de control del 8255 PPI
63AE: 3E 92       ld   a,$92
63B0: ED 79       out  (c),a		; 1001 0010 (puerto A: entrada, puerto B: entrada, puerto C superior: salida, puerto C inferior: salida)
63B2: F1          pop  af
63B3: C5          push bc

63B4: 47          ld   b,a			; b = tecla a comprobar
63B5: E6 07       and  $07			; obtiene el bit de la línea a comprobar
63B7: 87          add  a,a
63B8: 87          add  a,a
63B9: 87          add  a,a
63BA: F6 47       or   $47
63BC: 32 DD 63    ld   ($63DD),a	; modifica una instrucción para comprobar el bit correspondiente
63BF: 78          ld   a,b			; lee la tecla a comprobar
63C0: 0F          rrca
63C1: 0F          rrca
63C2: 0F          rrca
63C3: E6 0F       and  $0F			; halla la línea correspondiente
63C5: B1          or   c
63C6: F6 40       or   $40
63C8: 4F          ld   c,a
63C9: 06 F6       ld   b,$F6		; operación PSG: leer datos del registro (linea a)
63CB: ED 49       out  (c),c
63CD: 06 F4       ld   b,$F4
63CF: ED 78       in   a,(c)
63D1: C1          pop  bc
63D2: F5          push af			; guarda la línea leida
63D3: 3E 82       ld   a,$82
63D5: ED 79       out  (c),a		; 1001 0010 (puerto A: salida, puerto B: entrada, puerto C superior: salida, puerto C inferior: salida)
63D7: 05          dec  b
63D8: ED 49       out  (c),c		; operación PSG: inactivo
63DA: F1          pop  af			; recupera la línea leida
63DB: 2F          cpl				; las teclas pulsadas ahora están a 1
63DC: CB 57       bit  2,a			; instrucción modificada desde fuera para comprobar el bit correspondiente
63DE: C1          pop  bc
63DF: C9          ret
; ------------------------ fin del código relacionado con la pulsación de teclas --------------------------------

; aquí llega si se ha pulsado 'I'
63E0: CD 72 65    call $6572		; llama a la rutina de impresión de caracteres y de cambio de posición del texto según los valores que haya después de la llamada
		1F 30 14 -> cambia el cursor a la posición (0x30, 0x14)
		49 3A 20 5F 08 FF -> I: _ (y retrocede el cursor una posición)
63EC: CD 01 69    call $6901		; lee hasta 20 caracteres de teclado e interpreta los caracteres en binario o en hexadecimal para devolver el número convertido en hl
63EF: 7D          ld   a,l			; guarda los 2 últimos dígitos leidos
63F0: 2A 22 65    ld   hl,($6522)	; obtiene la dirección de memoria actual
63F3: CD AB 00    call $00AB		; fija configuracion 0 (0, 1, 2, 3), escribe a en hl y fija configuracion 4 (0, 4, 2, 3)
63F6: CD 60 64    call $6460		; muestra un volcado de la memoria de una zona o el código que hay en esa zona de memoria
63F9: CD 34 68    call $6834		; muestra las 3 columnas de la parte inferior de la pantalla con el volcado de la memoria
63FC: C3 F5 69    jp   $69F5		; escribe el prompt

; aquí llega si se ha pulsado espacio
63FF: CD F5 69    call $69F5		; escribe el prompt
6402: DD 2A 22 65 ld   ix,($6522)	; obtiene la dirección de memoria actual
6406: CD 8F 65    call $658F		; lee una instrucción y muestra el mnemónico asociado por pantalla
6409: CD F5 69    call $69F5		; escribe el prompt
640C: 3A 2D 65    ld   a,($652D)	; incrementa la dirección con la longitud de la instrucción
640F: 3C          inc  a
6410: 2A 22 65    ld   hl,($6522)
6413: 85          add  a,l
6414: 6F          ld   l,a
6415: 8C          adc  a,h
6416: 95          sub  l
6417: 67          ld   h,a
6418: 22 22 65    ld   ($6522),hl
641B: CD 60 64    call $6460		; muestra un volcado de la memoria de una zona o el código que hay en esa zona de memoria
641E: 3E 2F       ld   a,$2F
6420: CD 98 63    call $6398		; comprueba si se pulsó la tecla a
6423: CA 34 68    jp   z,$6834		; si se soltó el espacio, muestra las 3 columnas de la parte inferior de la pantalla con el volcado de la memoria
6426: C9          ret

; aquí llega si se pulsó cursor abajo
6427: 11 01 00    ld   de,$0001		; desplazamiento = 1
642A: 18 0D       jr   $6439		; desplaza la posición actual de memoria y actualiza

; aquí llega si se pulsó cursor arriba
642C: 11 FF FF    ld   de,$FFFF		; desplazamiento = -1
642F: 18 08       jr   $6439		; desplaza la posición actual de memoria y actualiza

; aquí llega si se pulsó cursor derecha
6431: 11 08 00    ld   de,$0008		; desplazamiento = 8
6434: 18 03       jr   $6439		; desplaza la posición actual de memoria y actualiza

; aquí llega si se pulsó cursor izquierda
6436: 11 F8 FF    ld   de,$FFF8		; desplazamiento = -8

6439: 2A 22 65    ld   hl,($6522)	; obtiene la dirección actual desde la que se desensambla y que se muestra el volcado
643C: 19          add  hl,de		; le suma el desplazamiento y la actualiza
643D: 22 22 65    ld   ($6522),hl
6440: CD 34 68    call $6834		; muestra las 3 columnas de la parte inferior de la pantalla con el volcado de la memoria
6443: 3E 17       ld   a,$17
6445: CD 98 63    call $6398		; comprueba si se pulsó control
6448: 01 98 3A    ld   bc,$3A98
644B: CC 6C 65    call z,$656C		; si no se pulsó, hace un pequeño retardo hasta que bc sea 0
644E: DD 7E 00    ld   a,(ix+$00)
6451: CD 98 63    call $6398		; comprueba si se pulsó la tecla a
6454: CA 60 64    jp   z,$6460		; si se ha soltado la tecla que hizo que se llegara a esta rutina, muestra un volcado de la memoria
6457: C9          ret				;  de una zona o el código que hay en esa zona de memoria

; aquí llega si se ha pulsado 'F'
6458: 3A 35 65    ld   a,($6535)	; cambia lo que se muestra en la parte derecha (el desensamblado o la memoria)
645B: EE 01       xor  $01
645D: 32 35 65    ld   ($6535),a

; muestra un volcado de la memoria de una zona o el código que hay en esa zona de memoria
6460: 3A 35 65    ld   a,($6535)	; lee si hay que mostrar la memoria o desensamblar el código
6463: A7          and  a
6464: 28 56       jr   z,$64BC		; si hay que desensamblar el código, salta

; aquí llega para mostrar la memoria
6466: 21 03 2A    ld   hl,$2A03		; posición inicial del cursor
6469: ED 5B 22 65 ld   de,($6522)	; obtiene la dirección de memoria inicial a mostrar
646D: 06 0C       ld   b,$0C		; muestra 12 líneas de memoria
646F: C5          push bc
6470: E5          push hl
6471: CD B7 62    call $62B7		; pone el cursor en la posición indicada por hl (h = posición en x, l = posición en y)
6474: 7A          ld   a,d
6475: CD FC 65    call $65FC		; imprime d
6478: 7B          ld   a,e
6479: CD FC 65    call $65FC		; imprime e
647C: 3E 20       ld   a,$20
647E: CD C5 62    call $62C5		; imprime un espacio
6481: 3E 20       ld   a,$20
6483: CD C5 62    call $62C5		; imprime un espacio

6486: 06 08       ld   b,$08		; 8 bytes
6488: D5          push de
6489: EB          ex   de,hl
648A: C5          push bc
648B: CD A0 00    call $00A0		; devuelve en a un byte leido de hl fijando la configuración original (luego restaura la configuración de depuración)
648E: CD FC 65    call $65FC		; dado un número en a, imprime en la posición actual el valor en hexadecimal del número
6491: 3E 20       ld   a,$20
6493: CD C5 62    call $62C5		; imprime un espacio
6496: 23          inc  hl
6497: C1          pop  bc
6498: 10 F0       djnz $648A		; continúa con la impresión de los 8 bytes
649A: E1          pop  hl

649B: 3E 20       ld   a,$20
649D: CD C5 62    call $62C5		; imprime un espacio
64A0: 06 08       ld   b,$08		; 8 bytes
64A2: C5          push bc
64A3: CD A0 00    call $00A0		; devuelve en a un byte leido de hl fijando la configuración original (luego restaura la configuración de depuración)
64A6: E6 7F       and  $7F
64A8: FE 20       cp   $20
64AA: 30 02       jr   nc,$64AE		; si no es carácter imprimible, lo muestra
64AC: 3E 2E       ld   a,$2E		; en otro caso muestra un '.'
64AE: CD C5 62    call $62C5
64B1: 23          inc  hl
64B2: C1          pop  bc
64B3: 10 ED       djnz $64A2		; completa los 8 bytes

64B5: EB          ex   de,hl
64B6: E1          pop  hl
64B7: 2C          inc  l			; avanza el cursor a la siguiente línea
64B8: C1          pop  bc
64B9: 10 B4       djnz $646F		; repite hasta completar las 12 líneas
64BB: C9          ret

; aqui llega si hay que desensamblar el código
64BC: DD 2A 22 65 ld   ix,($6522)	; obtiene la dirección de memoria de la primera instrucción
64C0: CD 72 65    call $6572		; llama a la rutina de impresión de caracteres y de cambio de posición del texto según los valores que haya después de la llamada
		1F 01 0C FF -> cambia la posición del cursor a (0x01, 0x0c)
64C7: 06 0C       ld   b,$0C		; 12 líneas
64C9: 21 03 2A    ld   hl,$2A03		; posición inicial del cursor
64CC: C5          push bc
64CD: E5          push hl
64CE: CD D7 64    call $64D7		; cambia la posición del cursor, desensambla una instrucción y muestra la dirección de la instrucción, los bytes que la forman y su mnemónico
64D1: E1          pop  hl
64D2: 2C          inc  l			; avanza el cursor a la siguiente línea
64D3: C1          pop  bc
64D4: 10 F6       djnz $64CC		; completa las 12 líneas
64D6: C9          ret

; cambia la posición del cursor, desensambla una instrucción y muestra la dirección de la instrucción, los bytes que la forman y su mnemónico
64D7: DD E5       push ix
64D9: E5          push hl
64DA: CD B7 62    call $62B7		; pone el cursor en la posición indicada por hl (h = posición en x, l = posición en y)
64DD: 3E 12       ld   a,$12
64DF: CD C5 62    call $62C5		; borra hasta el final de la línea
64E2: E1          pop  hl
64E3: E5          push hl
64E4: 7C          ld   a,h
64E5: C6 16       add  a,$16		; avanza 16 posiciones en x
64E7: 67          ld   h,a
64E8: CD B7 62    call $62B7		; pone el cursor en la posición indicada por hl (h = posición en x, l = posición en y)
64EB: CD 8F 65    call $658F		; lee una instrucción y muestra el mnemónico asociado por pantalla
64EE: E1          pop  hl
64EF: CD B7 62    call $62B7		; pone el cursor en la posición indicada por hl (h = posición en x, l = posición en y)
64F2: 3E 20       ld   a,$20
64F4: CD C5 62    call $62C5		; imprime un espacio en blanco
64F7: 3E 20       ld   a,$20
64F9: CD C5 62    call $62C5		; imprime un espacio en blanco
64FC: E1          pop  hl
64FD: 7C          ld   a,h
64FE: CD FC 65    call $65FC		; imprime la dirección de la instrucción
6501: 7D          ld   a,l
6502: CD FC 65    call $65FC
6505: 3E 20       ld   a,$20
6507: CD C5 62    call $62C5		; imprime un espacio en blanco
650A: 3A 2D 65    ld   a,($652D)	; lee los bytes leidos en la instrucción
650D: 3C          inc  a
650E: 47          ld   b,a			; repite la longitud de la instrucción (bytes leidos + 1)
650F: C5          push bc
6510: 3E 20       ld   a,$20
6512: CD C5 62    call $62C5		; escribe un espacio
6515: CD A0 00    call $00A0		; devuelve en a un byte leido de hl fijando la configuración original (luego restaura la configuración de depuración)
6518: CD FC 65    call $65FC		; dado un número en a, imprime en la posición actual el valor en hexadecimal del número
651B: 23          inc  hl
651C: C1          pop  bc
651D: 10 F0       djnz $650F		; completa los bytes de la instrucción
651F: DD 23       inc  ix
6521: C9          ret

6522-6537: usado para almacenar datos del depurador

; usado para comparar mnemónicos y procesarlos (cada entrada tiene 3 bytes)
6538: 	44  66B0 -> D
		43  66D6 -> C
		4E  6620 -> N
		59  6686 -> Y
		58  665C -> X
		47  65E3 -> G
		48  6641 -> H
		49  662E -> I
		45  66F2 -> E
		FF

6554-656B: usado para almacenar datos del depurador

; pequeño retardo hasta que bc sea 0
656C: 0B          dec  bc
656D: 78          ld   a,b
656E: B1          or   c
656F: 20 FB       jr   nz,$656C
6571: C9          ret

; llama a la rutina de impresión de caracteres y de cambio de posición del texto según los valores que haya después de la llamada
6572: E1          pop  hl			; obtiene la dirección de retorno
6573: 7E          ld   a,(hl)		; lee el parámetro y guarda la nueva dirección de retorno
6574: 23          inc  hl
6575: E5          push hl
6576: FE FF       cp   $FF			; si se lee 0xff, sale
6578: C8          ret  z
6579: E6 7F       and  $7F			; ajusta el caracter a 0x00-0x7f
657B: CD C5 62    call $62C5		; si 0x62c2 es 0, escribe el carácter que se pasa en a, si es 1, fija la posición x del cursor, y si es 2, fija la posición y del cursor
657E: 18 F2       jr   $6572		; repite hasta encontrar 0xff

; avanza hl hasta encontrar el mnemónico número a
6580: 2A 24 65    ld   hl,($6524)	; obtiene el puntero a las cadenas de los mnemónicos
6583: A7          and  a
6584: C8          ret  z			; si a es 0, sale
6585: 47          ld   b,a			; repite a veces
6586: 7E          ld   a,(hl)		; lee un byte de hl
6587: 23          inc  hl
6588: FE 0D       cp   $0D			; repite hasta encontrar el caracter 0x0d
658A: 20 FA       jr   nz,$6586
658C: 10 F8       djnz $6586
658E: C9          ret

; lee una instrucción y muestra el mnemónico asociado por pantalla
658F: 21 3D 66    ld   hl,$663D		; hl apunta a la cadena hl
6592: 22 26 65    ld   ($6526),hl	; inicia la cadena 1 a hl
6595: 22 28 65    ld   ($6528),hl   ; inicia la cadena 2 a hl
6598: 21 00 40    ld   hl,$4000
659B: 22 24 65    ld   ($6524),hl	; inicia el puntero a las cadenas de los mnemónicos
659E: AF          xor  a
659F: 32 56 66    ld   ($6656),a	; inicialmente hay un nop en esta rutina
65A2: 32 2C 65    ld   ($652C),a	; indica que de momento no se ha procesado una posible instrucción con ix++ o iy++
65A5: 32 2D 65    ld   ($652D),a	; pone a 0 el número de bytes leidos

; a veces llega aquí al procesar alguna letra de un mnemónico
65A8: DD E5       push ix
65AA: E3          ex   (sp),hl		; intercambia hl y el contenido de la pila
65AB: CD A0 00    call $00A0		; devuelve en a un byte leido de hl fijando la configuración original (luego restaura la configuración de depuración)
65AE: E1          pop  hl			; recupera lo escrito
65AF: CD 80 65    call $6580		; avanza hl hasta encontrar el mnemónico número a

; a veces llega aquí al procesar alguna letra de un mnemónico
65B2: 7E          ld   a,(hl)		; lee un byte del mnemónico
65B3: 22 2A 65    ld   ($652A),hl	; guarda la posición actual del mnemónico
65B6: 11 38 65    ld   de,$6538		; de apunta a una tabla con letras y rutinas relacionadas
65B9: EB          ex   de,hl

65BA: BE          cp   (hl)			; compara la primera letra del mnemónico con el valor de la tabla
65BB: 28 13       jr   z,$65D0		; si coincide, salta
65BD: CB 7E       bit  7,(hl)
65BF: 20 05       jr   nz,$65C6		; si está puesto el bit 7, salta (fin de tabla)
65C1: 23          inc  hl
65C2: 23          inc  hl
65C3: 23          inc  hl
65C4: 18 F4       jr   $65BA		; avanza a la siguiente entrada y sigue comprobando

65C6: FE 0D       cp   $0D			; si se llegó al final de la tabla y se encontró fín de mnemónico (0x0d), sale
65C8: C8          ret  z

65C9: CD C5 62    call $62C5		; escribe el carácter leido
65CC: EB          ex   de,hl
65CD: 23          inc  hl
65CE: 18 E2       jr   $65B2		; pasa a analizar el siguiente byte

; aquí llega si se encontró una letra de las de la tabla
65D0: 01 DD 65    ld   bc,$65DD
65D3: C5          push bc			; guarda la dirección de retorno
65D4: 23          inc  hl
65D5: 7E          ld   a,(hl)		; hl = dirección asociada a la letra en la tabla
65D6: 23          inc  hl
65D7: 66          ld   h,(hl)
65D8: 6F          ld   l,a
65D9: 11 2D 65    ld   de,$652D		; de apunta a la dirección donde se guarda el número de bytes leidos de la instrucción
65DC: E9          jp   (hl)			; salta a la rutina correspondiente para tratar el caso específico

; aquí suele llegar después de ejecutar el código especifico de alguna entrada de la tabla (aunque a veces cambia la dirección de retorno)
65DD: 2A 2A 65    ld   hl,($652A)	; hl = puntero a la cadena del mnemónico
65E0: 23          inc  hl			; avanza a la siguiente posición
65E1: 18 CF       jr   $65B2		; continúa procesando el mnemónico

; rutina que procesa los mnemónicos que tienen una G, imprimiendo (en hexadecimal) los 2 bytes siguientes
65E3: EB          ex   de,hl
65E4: 34          inc  (hl)			; indica que ha cogido 2 bytes
65E5: 34          inc  (hl)
65E6: DD 23       inc  ix			; avanza al siguiente byte de la instrucción
65E8: DD E5       push ix
65EA: E3          ex   (sp),hl
65EB: 23          inc  hl
65EC: CD A0 00    call $00A0		; devuelve en a un byte leido de hl fijando la configuración original (luego restaura la configuración de depuración)
65EF: E1          pop  hl
65F0: CD FC 65    call $65FC		; dado un número en a, imprime en la posición actual el valor en hexadecimal del número
65F3: DD E5       push ix
65F5: E3          ex   (sp),hl
65F6: CD A0 00    call $00A0		; devuelve en a un byte leido de hl fijando la configuración original (luego restaura la configuración de depuración)
65F9: E1          pop  hl
65FA: DD 23       inc  ix			; avanza al siguiente byte de la instrucción

; dado un número en a, imprime en la posición actual el valor en hexadecimal del número
65FC: CD 07 66    call $6607		; devuelve en bc los 2 caracteres ASCII que representan en hexadecimal el número pasado en a
65FF: 79          ld   a,c
6600: CD C5 62    call $62C5		; escribe en pantalla el dígito más significativo
6603: 78          ld   a,b
6604: C3 C5 62    jp   $62C5		; escribe en pantalla el dígito menos significativo

; devuelve en bc los 2 caracteres ASCII que representan en hexadecimal el número pasado en a
6607: 4F          ld   c,a
6608: CD 16 66    call $6616	; convierte los 4 bits menos significativos de a en un dígito hexadecimal imprimible
660B: 47          ld   b,a		; guarda el dígito menos significativo en b
660C: 79          ld   a,c
660D: 0F          rrca
660E: 0F          rrca
660F: 0F          rrca
6610: 0F          rrca
6611: CD 16 66    call $6616	; convierte los 4 bits menos significativos de a en un dígito hexadecimal imprimible
6614: 4F          ld   c,a		; guarda el dígito más significativo en c
6615: C9          ret

; convierte los 4 bits menos significativos de a en un dígito hexadecimal imprimible
6616: E6 0F       and  $0F
6618: C6 30       add  a,$30
661A: FE 3A       cp   $3A
661C: D8          ret  c
661D: C6 07       add  a,$07
661F: C9          ret

; rutina que procesa los mnemónicos que tienen una N, imprimiendo el número hexadecimal del byte siguiente
6620: DD 23       inc  ix			; avanza al siguiente byte de la instrucción
6622: EB          ex   de,hl
6623: 34          inc  (hl)			; indica que ha cogido un byte
6624: DD E5       push ix
6626: DD E3       ex   (sp),ix
6628: CD A0 00    call $00A0		; devuelve en a un byte leido de hl fijando la configuración original (luego restaura la configuración de depuración)
662B: E1          pop  hl
662C: 18 CE       jr   $65FC		; dado un número en a, imprime en la posición actual el valor en hexadecimal del número

; rutina que procesa los mnemónicos que tienen una I, imprimiendo una cadena para cargar un registro con un valor
662E: 2A 26 65    ld   hl,($6526)	; lee la cadena del registro a cargar
6631: E5          push hl
6632: C3 72 65    jp   $6572		; llama a la rutina de impresión de caracteres y de cambio de posición del texto según los valores que haya después de la llamada
		69 78 FF -> ix
6638: C9          ret

		69 79 FF -> iy
663C: C9          ret

		68 6C FF -> hl
6640: C9          ret

; rutina que procesa los mnemónicos que tienen una H, imprimiendo una cadena de registro
6641: 2A 28 65    ld   hl,($6528)	; obtiene el puntero a la cadena a mostrar
6644: E5          push hl
6645: C3 72 65    jp   $6572		; llama a la rutina de impresión de caracteres y de cambio de posición del texto según los valores que haya después de la llamada
		69 78 2B 00 00 FF -> ix+
664E: 18 06       jr   $6656

		69 79 2B 00 00 FF -> iy+

6656: 00          nop				; instrucción modificada desde fuera (nop o ret)
6657: DD 23       inc  ix
6659: EB          ex   de,hl
665A: 34          inc  (hl)			; indica que ha cogido un byte
665B: C9          ret

; rutina que procesa los mnemónicos que tienen una X, copia el byte siguiente a la cadena ix+ y sigue procesando instrucciones
665C: 3E 01       ld   a,$01
665E: 32 2C 65    ld   ($652C),a	; indica que se ha procesado una posible instrucción con ix++ o iy++
6661: 21 35 66    ld   hl,$6635		; apunta a la cadena ix
6664: 22 26 65    ld   ($6526),hl
6667: 21 48 66    ld   hl,$6648		; apunta a la cadena ix+
666A: 22 28 65    ld   ($6528),hl
666D: DD E5       push ix
666F: E3          ex   (sp),hl
6670: 23          inc  hl			; salta 2 bytes de la instrucción
6671: 23          inc  hl
6672: CD A0 00    call $00A0		; devuelve en a un byte leido de hl fijando la configuración original (luego restaura la configuración de depuración)
6675: E1          pop  hl
6676: CD 07 66    call $6607		; devuelve en bc los 2 caracteres ASCII que representan en hexadecimal el número pasado en a
6679: ED 43 4B 66 ld   ($664B),bc	; guarda los 2 caracteres en la cadena ix+ formando ix+XX
667D: DD 23       inc  ix
667F: EB          ex   de,hl
6680: 34          inc  (hl)			; indica que se ha cogido un byte
6681: 21 A8 65    ld   hl,$65A8		; cambia la dirección de retorno para que continue procesando el comando
6684: E3          ex   (sp),hl
6685: C9          ret

; rutina que procesa los mnemónicos que tienen una Y, copia el byte siguiente a la cadena iy+ y sigue procesando instrucciones
6686: 3E 01       ld   a,$01
6688: 32 2C 65    ld   ($652C),a	; indica que se ha procesado una posible instrucción con ix++ o iy++
668B: 21 39 66    ld   hl,$6639		; apunta a la cadena iy
668E: 22 26 65    ld   ($6526),hl
6691: 21 50 66    ld   hl,$6650		; apunta a la cadena iy+
6694: 22 28 65    ld   ($6528),hl
6697: DD E5       push ix
6699: E3          ex   (sp),hl
669A: 23          inc  hl			; salta 2 bytes de la instrucción
669B: 23          inc  hl
669C: CD A0 00    call $00A0		; devuelve en a un byte leido de hl fijando la configuración original (luego restaura la configuración de depuración)
669F: E1          pop  hl
66A0: CD 07 66    call $6607		; devuelve en bc los 2 caracteres ASCII que representan en hexadecimal el número pasado en a
66A3: ED 43 53 66 ld   ($6653),bc	; guarda los 2 caracteres en la cadena iy+ formando iy+XX
66A7: DD 23       inc  ix
66A9: EB          ex   de,hl
66AA: 34          inc  (hl)			; indica que se ha cogido un byte
66AB: 21 A8 65    ld   hl,$65A8
66AE: E3          ex   (sp),hl
66AF: C9          ret				; cambia la dirección de retorno para que continue procesando el comando

; rutina que procesa los mnemónicos que tienen una D, calcula la dirección del salto y la imprime
66B0: DD E5       push ix
66B2: E1          pop  hl			; hl = ix
66B3: 23          inc  hl
66B4: 23          inc  hl			; hl apunta a la dirección de la siguiente instrucción
66B5: DD 23       inc  ix			; avanza hasta el desplazamiento
66B7: DD E5       push ix
66B9: E3          ex   (sp),hl
66BA: CD A0 00    call $00A0		; devuelve en a un byte leido de hl fijando la configuración original (luego restaura la configuración de depuración)
66BD: E1          pop  hl			; recupera la dirección de la siguiente instrucción
66BE: CB 7F       bit  7,a
66C0: 20 07       jr   nz,$66C9		; si es un salto con desplazamiento negativo, salta
66C2: 85          add  a,l
66C3: 6F          ld   l,a
66C4: 8C          adc  a,h
66C5: 95          sub  l
66C6: 67          ld   h,a			; hl = hl + a
66C7: 18 05       jr   $66CE

; aquí llega si es un salto con desplazamiento negativo
66C9: 85          add  a,l			; suma el desplazamiento negativo teniendo en cuenta el acarreo
66CA: 6F          ld   l,a
66CB: 38 01       jr   c,$66CE
66CD: 25          dec  h
66CE: 7C          ld   a,h
66CF: CD FC 65    call $65FC		; imprime el primer byte de la dirección de salto
66D2: 7D          ld   a,l
66D3: C3 FC 65    jp   $65FC		; imprime el segundo byte de la dirección de salto

; rutina que procesa los mnemónicos que tienen una C
66D6: 21 38 4A    ld   hl,$4A38		; apunta a la tabla de las cadenas con las frases para las operaciones de bits
66D9: 22 24 65    ld   ($6524),hl	; fija la dirección a partir de la que obtener mnemónicos
66DC: 21 A8 65    ld   hl,$65A8		; cambia la dirección de retorno para seguir procesando comandos
66DF: E3          ex   (sp),hl
66E0: 3A 2C 65    ld   a,($652C)	; comprueba si se ha procesado una instrucción ix++ o iy++
66E3: DD 23       inc  ix			; avanza al siguiente byte de la instrucción
66E5: EB          ex   de,hl
66E6: 34          inc  (hl)			; indica que se ha cogido un byte
66E7: A7          and  a			; si no se ha procesado una instrucción ix++ o iy++, sale
66E8: C8          ret  z

; aquí llega si se ha procesado una instrucción ix++ o iy++
66E9: DD 23       inc  ix
66EB: 34          inc  (hl)			; indica que se ha cogido otro byte
66EC: 3E C9       ld   a,$C9
66EE: 32 56 66    ld   ($6656),a	; pone un ret en una rutina (para que no indique que ha cogido otro byte)
66F1: C9          ret

; rutina que procesa los mnemónicos que tienen una E
66F2: 21 08 52    ld   hl,$5208		; apunta a la tabla de las cadenas con las frases para las operaciones que empiezan por 0xed
66F5: 22 24 65    ld   ($6524),hl	; fija la dirección a partir de la que obtener mnemónicos
66F8: E1          pop  hl
66F9: DD 23       inc  ix			; avanza al siguiente byte de la instrucción
66FB: EB          ex   de,hl
66FC: 34          inc  (hl)
66FD: DD E5       push ix
66FF: E3          ex   (sp),hl
6700: CD A0 00    call $00A0		; devuelve en a un byte leido de hl fijando la configuración original (luego restaura la configuración de depuración)
6703: E1          pop  hl
6704: D6 40       sub  $40			; si el byte leido es < 0x40, sale
6706: D8          ret  c
6707: FE 7C       cp   $7C			; si el byte leido es >= 0xbc, sale
6709: D0          ret  nc
670A: 21 B2 65    ld   hl,$65B2		; pone la dirección de retorno
670D: E5          push hl
670E: CD 80 65    call $6580		; avanza hl hasta encontrar el mnemónico número a
6711: C9          ret

; muestra los registros y sus valores, e indica cual está seleccionado
6712: DD 21 54 65 ld   ix,$6554		; apunta a la dirección donde se guardan los registros
6716: CD 72 65    call $6572		; llama a la rutina de impresión de caracteres y de cambio de posición del texto según los valores que haya después de la llamada
		1F 01 03 FF -> coloca el cursor en (1, 3)
671D: 06 0A       ld   b,$0A		; 10 registros de 16 bits
671F: C5          push bc
6720: CD D2 67    call $67D2		; escribe 6 espacios, 4 dígitos hexadecimales correspondientes a lo que hay en ix (que lo carga en hl) y 3 espacios

6723: 06 09       ld   b,$09		; 9 posiciones de memoria a partir de donde apunta el registro
6725: C5          push bc
6726: CD A0 00    call $00A0		; devuelve en a un byte leido de hl fijando la configuración original (luego restaura la configuración de depuración)
6729: CD FC 65    call $65FC		; dado un número en a, imprime en la posición actual el valor en hexadecimal del número
672C: 3E 20       ld   a,$20
672E: CD C5 62    call $62C5		; imprime un espacio en blanco
6731: 23          inc  hl			; pasa a la siguiente posición
6732: C1          pop  bc
6733: 10 F0       djnz $6725		; repite hasta completar 9 bytes

6735: CD 2A 68    call $682A		; avanza el cursor hasta el inicio de la siguiente línea
6738: C1          pop  bc
6739: DD 23       inc  ix			; pasa hasta el siguiente registro
673B: DD 23       inc  ix
673D: 10 E0       djnz $671F		; repite hasta completar los registros de 16 bits

673F: CD D2 67    call $67D2		; escribe 6 espacios, 4 dígitos hexadecimales correspondientes a lo que hay en ix (que lo carga en hl) y 3 espacios
6742: DD 7E 00    ld   a,(ix+$00)	; lee los flags
6745: DD 23       inc  ix			; avanza al siguiente registro
6747: DD 23       inc  ix
6749: CD F4 67    call $67F4		; escribe una cadena mostrando el estado de los flags
674C: CD 2A 68    call $682A		; avanza el cursor hasta el inicio de la siguiente línea

674F: CD D2 67    call $67D2		; escribe 6 espacios, 4 dígitos hexadecimales correspondientes a lo que hay en ix (que lo carga en hl) y 3 espacios
6752: DD 7E 00    ld   a,(ix+$00)	; lee los flags
6755: CD F4 67    call $67F4		; escribe una cadena mostrando el estado de los flags
6758: CD 72 65    call $6572		; llama a la rutina de impresión de caracteres y de cambio de posición del texto según los valores que haya después de la llamada
	1F 01 03 -> coloca el cursor en (1, 3)
	20 20 50 C3 0D 0A -> "  PC\n"
	20 20 53 D0 0D 0A -> "  SP\n"
	20 20 49 D9 0D 0A -> "  IY\n"
	20 20 49 D8 0D 0A -> "  IX\n"
	20 20 48 CC 0D 0A -> "  HL\n"
	20 20 48 CC 27 20 0D 0A -> "  HL' \n"
	20 20 44 C5 0D 0A -> "  DE\n"
	20 20 44 C5 27 20 0D 0A -> "  DE' \n"
	20 20 42 C3 0D 0A -> "  BC\n"
	20 20 42 C3 27 20 0D 0A -> "  BC' \n"
	20 20 41 C6 0D 0A -> "  AF\n"
	20 20 41 C6 27 FF -> "  AF'"

67AC: 3A 2E 65    ld   a,($652E)	; lee el registro seleccionado
67AF: 21 03 02    ld   hl,$0203		; posición inicial del primer registro seleccionado (2,3)
67B2: 85          add  a,l
67B3: 6F          ld   l,a
67B4: CD B7 62    call $62B7		; coloca el cursor en la posición del registro seleccionado
67B7: 3E 3E       ld   a,$3E
67B9: CD C5 62    call $62C5		; escribe el carácter '>' al lado del registro seleccionado
67BC: C9          ret

; aquí llega si se ha pulsado '.'
67BD: 01 98 3A    ld   bc,$3A98
67C0: CD 6C 65    call $656C		; pequeño retardo hasta que bc sea 0
67C3: 3A 2E 65    ld   a,($652E)	; avanza circularmente el registro seleccionado
67C6: 3C          inc  a
67C7: FE 0C       cp   $0C
67C9: 38 01       jr   c,$67CC
67CB: AF          xor  a
67CC: 32 2E 65    ld   ($652E),a
67CF: C3 58 67    jp   $6758		; actualiza los registros

; escribe 6 espacios, 4 dígitos hexadecimales correspondientes a lo que hay en ix (que lo carga en hl) y 3 espacios
67D2: CD 72 65    call $6572		; llama a la rutina de impresión de caracteres y de cambio de posición del texto según los valores que haya después de la llamada
		20 20 20 20 20 20 FF -> escribe 6 espacios
67DC: DD 6E 00    ld   l,(ix+$00)	; lee 2 bytes
67DF: DD 66 01    ld   h,(ix+$01)
67E2: E5          push hl
67E3: 7C          ld   a,h			; lee los 8 bits superiores
67E4: CD FC 65    call $65FC		; dado un número en a, imprime en la posición actual el valor en hexadecimal del número
67E7: 7D          ld   a,l			; lee los 8 bits inferiores
67E8: CD FC 65    call $65FC		; dado un número en a, imprime en la posición actual el valor en hexadecimal del número
67EB: CD 72 65    call $6572		; llama a la rutina de impresión de caracteres y de cambio de posición del texto según los valores que haya después de la llamada
		20 20 20 FF -> escribe 3 espacios
67F2: E1          pop  hl
67F3: C9          ret

; escribe una cadena mostrando el estado de los flags
67F4: 4F          ld   c,a			; guarda los flags en c
67F5: CB 79       bit  7,c
67F7: 3E 50       ld   a,$50
67F9: 28 02       jr   z,$67FD
67FB: 3E 4D       ld   a,$4D
67FD: CD C5 62    call $62C5		; si está a 1 el flag de signo escribe M en otro caso escribe P
6800: 3E 2C       ld   a,$2C
6802: CD C5 62    call $62C5		; escribe una coma

6805: CB 71       bit  6,c
6807: 20 05       jr   nz,$680E		; si está a 1 el flag de cero, escribe Z, en otro caso escribe NZ
6809: 3E 4E       ld   a,$4E
680B: CD C5 62    call $62C5
680E: 3E 5A       ld   a,$5A
6810: CD C5 62    call $62C5
6813: 3E 2C       ld   a,$2C
6815: CD C5 62    call $62C5		; escribe una coma

6818: CB 41       bit  0,c
681A: 20 05       jr   nz,$6821		; si está puesto el flag de acarreo, escribe C, en otro caso escribe NC
681C: 3E 4E       ld   a,$4E
681E: CD C5 62    call $62C5
6821: CD 72 65    call $6572		; además de la C escribe 3 espacios
		43 20 20 20 FF
6829: C9          ret

; avanza el cursor hasta el inicio de la siguiente línea
682A: 3E 0D       ld   a,$0D
682C: CD C5 62    call $62C5		; escribe CR, LF
682F: 3E 0A       ld   a,$0A
6831: C3 C5 62    jp   $62C5

; muestra las 3 columnas de la parte inferior de la pantalla con el volcado de la memoria
6834: 2A 22 65    ld   hl,($6522)	; obtiene la dirección de memoria inicial que se muestra o se desensambla en la parte derecha de la pantalla
6837: 11 0B 00    ld   de,$000B		; le resta 0x0b
683A: A7          and  a
683B: ED 52       sbc  hl,de
683D: EB          ex   de,hl		; de = dirección inicial a mostrar
683E: 21 11 03    ld   hl,$0311		; posición inicial del cursor (0x03, 0x11)
6841: 06 03       ld   b,$03		; repetir para 3 columnas
6843: C5          push bc
6844: E5          push hl
6845: 06 08       ld   b,$08		; cada columna tiene 8 filas
6847: C5          push bc
6848: E5          push hl
6849: CD B7 62    call $62B7		; pone el cursor en la posición indicada por hl (h = posición en x, l = posición en y)
684C: 7A          ld   a,d
684D: CD FC 65    call $65FC		; imprime la parte más significativa de la dirección actual
6850: 7B          ld   a,e
6851: CD FC 65    call $65FC		; imprime la parte menos significativa de la dirección actual
6854: 3E 20       ld   a,$20
6856: CD C5 62    call $62C5		; imprime un espacio en blanco
6859: 3E 20       ld   a,$20
685B: CD C5 62    call $62C5		; imprime un espacio en blanco
685E: EB          ex   de,hl
685F: CD A0 00    call $00A0		; devuelve en a un byte leido de hl fijando la configuración original (luego restaura la configuración de depuración)
6862: CD FC 65    call $65FC		; dado un número en a, imprime en la posición actual el valor en hexadecimal del número
6865: 3E 20       ld   a,$20
6867: CD C5 62    call $62C5		; imprime un espacio en blanco
686A: CD A0 00    call $00A0		; devuelve en a un byte leido de hl fijando la configuración original (luego restaura la configuración de depuración)
686D: E6 7F       and  $7F
686F: FE 20       cp   $20
6871: 30 02       jr   nc,$6875		; si lo que había en la dirección de memoria leida no es imprimible, salta
6873: 3E 20       ld   a,$20
6875: CD C5 62    call $62C5		; en otro caso escribe el carácter
6878: EB          ex   de,hl
6879: E1          pop  hl
687A: 13          inc  de
687B: 2C          inc  l			; pasa a la siguiente línea de pantalla
687C: C1          pop  bc
687D: 10 C8       djnz $6847		; completa las 8 líneas de una columna
687F: E1          pop  hl
6880: 7C          ld   a,h
6881: C6 0D       add  a,$0D		; avanza el cursor en x
6883: 67          ld   h,a
6884: C1          pop  bc
6885: 10 BC       djnz $6843		; completa las 3 columnas
6887: CD 72 65    call $6572		; llama a la rutina de impresión de caracteres y de cambio de posición del texto según los valores que haya después de la llamada
		1F 0F 14 -> pone el cursor en (0x0f, 0x14)
		3E -> escribe '>'
		1F 1A 14 -> pone el cursor en (0x1a, 0x14)
		3C FF -> escribe '<'
6893: C9          ret

; lee hasta 20 caracteres y los almacena en un buffer, junto con dos números asociado a cada caracter
6894: DD 21 49 69 ld   ix,$6949		; apunta a un buffer para almacenar los caracteres que se lean
6898: 21 85 69    ld   hl,$6985
689B: 7E          ld   a,(hl)		; lee un byte
689C: FE FF       cp   $FF
689E: 28 F8       jr   z,$6898		; si encuentra 0xff, vuelve a empezar desde el principio de la tabla
68A0: E5          push hl
68A1: CD 98 63    call $6398		; comprueba si se pulsó la tecla a
68A4: E1          pop  hl
68A5: 20 06       jr   nz,$68AD		; si se ha pulsado, salta
68A7: 23          inc  hl			; en otro caso, avanza a la siguiente entrada
68A8: 23          inc  hl
68A9: 23          inc  hl
68AA: 23          inc  hl
68AB: 18 EE       jr   $689B

68AD: 7E          ld   a,(hl)
68AE: FE 18       cp   $18
68B0: 20 08       jr   nz,$68BA		; si se lee la tecla 0x18 (símbolo de pound y flecha arriba)
68B2: ED 7B C3 62 ld   sp,($62C3)	; cancela el comando
68B6: CD F5 69    call $69F5		; escribe el prompt
68B9: C9          ret

; aquí llega si no se lee la tecla 0x18
68BA: E5          push hl
68BB: CD 98 63    call $6398		; comprueba si se pulsó la tecla a
68BE: E1          pop  hl
68BF: 20 EC       jr   nz,$68AD		; espera a que se suelte la tecla o que cancele la operación
68C1: 23          inc  hl			; avanza al siguiente byte de la tabla
68C2: 7E          ld   a,(hl)		; lee el carácter ASCII que representa a la tecla pulsada
68C3: FE 08       cp   $08
68C5: 20 13       jr   nz,$68DA		; si no es DEL, salta
68C7: DD 2B       dec  ix			; retrocede en el buffer
68C9: 3E 20       ld   a,$20
68CB: CD C5 62    call $62C5		; imprime un espacio
68CE: 3E 08       ld   a,$08
68D0: CD C5 62    call $62C5		; retrocede la posición x del cursor
68D3: 3E 08       ld   a,$08
68D5: CD C5 62    call $62C5		; retrocede la posición x del cursor
68D8: 18 1A       jr   $68F4

; si no se pulsó DEL llega aquí
68DA: DD 77 00    ld   (ix+$00),a
68DD: FE 0D       cp   $0D			; si se pulsó RETURN, sale de la rutina
68DF: C8          ret  z

68E0: CD C5 62    call $62C5		; en otro caso, imprime el carácter por pantalla
68E3: 7E          ld   a,(hl)
68E4: FE 40       cp   $40
68E6: 28 0A       jr   z,$68F2		; si se pulsó '@', salta

68E8: 23          inc  hl
68E9: 7E          ld   a,(hl)		; lee el siguiente byte y lo copia en el buffer
68EA: DD 77 14    ld   (ix+$14),a
68ED: 23          inc  hl
68EE: 7E          ld   a,(hl)		; lee el siguiente byte y lo copia en el buffer
68EF: DD 77 28    ld   (ix+$28),a

; aquí también llega si se pulsó '|'
68F2: DD 23       inc  ix
68F4: 3E 5F       ld   a,$5F
68F6: CD C5 62    call $62C5		; escribe '_'
68F9: 3E 08       ld   a,$08
68FB: CD C5 62    call $62C5		; retrocede el cursor una posición
68FE: C3 98 68    jp   $6898		; salta a seguir comprobando valores de la tabla

; lee hasta 20 caracteres de teclado e interpreta los caracteres en binario o en hexadecimal para devolver el número convertido en hl
6901: CD 94 68    call $6894		; lee hasta 20 caracteres y los almacena en un buffer, junto con dos números asociado a cada caracter
6904: 21 00 00    ld   hl,$0000		; hl = 0 (en hl se guardará el número leido)
6907: 55          ld   d,l			; de = 0 (en de se guardará la máscara del número leido)
6908: 5D          ld   e,l
6909: DD 21 49 69 ld   ix,$6949		; apunta al buffer de los caracteres leidos

690D: DD 7E 00    ld   a,(ix+$00)	; lee un carácter
6910: FE 0D       cp   $0D
6912: C8          ret  z			; si encuentra el return, sale
6913: FE 40       cp   $40
6915: 28 18       jr   z,$692F		; si encuentra '@', salta

6917: 29          add  hl,hl		; hl = hl*16
6918: 29          add  hl,hl
6919: 29          add  hl,hl
691A: 29          add  hl,hl
691B: DD 7E 14    ld   a,(ix+$14)	; obtiene el valor numérico del carácter y lo combina en l
691E: 85          add  a,l
691F: 6F          ld   l,a
6920: EB          ex   de,hl
6921: 29          add  hl,hl		; hl = hl*16
6922: 29          add  hl,hl
6923: 29          add  hl,hl
6924: 29          add  hl,hl
6925: DD 7E 28    ld   a,(ix+$28)	; obtiene la máscara del carácter y la combina en l
6928: 85          add  a,l
6929: 6F          ld   l,a
692A: EB          ex   de,hl
692B: DD 23       inc  ix			; avanza a la siguiente posición en los buffers
692D: 18 DE       jr   $690D		; continúa procesando

; aquí llega si se encuentra '@' (pasa al modo de bits)
692F: DD 23       inc  ix
6931: DD 7E 00    ld   a,(ix+$00)	; avanza al siguiente carácter
6934: FE 0D       cp   $0D
6936: C8          ret  z			; si es return sale
6937: 29          add  hl,hl		; hl = hl*2
6938: DD 7E 14    ld   a,(ix+$14)	; obtiene el valor numérico del carácter y lo combina en l
693B: 85          add  a,l
693C: 6F          ld   l,a
693D: EB          ex   de,hl
693E: 29          add  hl,hl		; hl = hl*2
693F: DD 7E 28    ld   a,(ix+$28)	; obtiene la máscara del carácter (solo un bit) y la combina en l
6942: E6 01       and  $01
6944: 85          add  a,l
6945: 6F          ld   l,a
6946: EB          ex   de,hl
6947: 18 E6       jr   $692F		; continúa procesando

; buffer para almacenar los caracteres que se lean (hasta 20 caracteres)
6949: 32 35 34 0D 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00

; aquí se almacena el número (hasta 20 dígitos)
695D: 02 05 04 09 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00

; aquí se almacena (aquí se almacena la máscara)
6971: 0F 0F 0F 0F 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00

; tabla con las teclas que pueden leerse (cada entrada ocupa 4 bytes)
6985: 	20 30 00 0F -> tecla '0'
		40 31 01 0F -> tecla '1'
		41 32 02 0F -> tecla '2'
		39 33 03 0F -> tecla '3'
		38 34 04 0F -> tecla '4'
		31 35 05 0F -> tecla '5'
		30 36 06 0F -> tecla '6'
		29 37 07 0F -> tecla '7'
		28 38 08 0F -> tecla '8'
		21 39 09 0F -> tecla '9'
		45 41 0A 0F -> tecla 'A'
		36 42 0B 0F -> tecla 'B'
		3E 43 0C 0F -> tecla 'C'
		3D 44 0D 0F -> tecla 'D'
		3A 45 0E 0F -> tecla 'E'
		35 46 0F 0F -> tecla 'F'
		3F 58 00 00 -> tecla 'X'
		4F 08 00 00 -> tecla 'DEL'
		1A 40 00 00 -> tecla '@'
		12 0D 00 00 -> tecla 'RETURN'
		18 00 00 00 -> tecla del símbolo de pound y flecha arriba
		FF

; aquí llega si se ha pulsado la 'M'
69DA: 21 14 30    ld   hl,$3014
69DD: CD B7 62    call $62B7		; pone el cursor en la posición indicada por hl (h = posición en x, l = posición en y)
69E0: CD 72 65    call $6572		; llama a la rutina de impresión de caracteres y de cambio de posición del texto según los valores que haya después de la llamada
		4D 3A 20 5F 08 FF -> M: _ (y retrocede en x la posición del cursor)
69E9: CD 01 69    call $6901		; lee hasta 20 caracteres de teclado e interpreta los caracteres en binario o en hexadecimal para devolver el número convertido en hl
69EC: 22 22 65    ld   ($6522),hl	; modifica la posición de memoria que se muestra
69EF: CD 60 64    call $6460		; muestra un volcado de la memoria de una zona o el código que hay en esa zona de memoria
69F2: CD 34 68    call $6834		; muestra las 3 columnas de la parte inferior de la pantalla con el volcado de la memoria

; escribe el prompt
69F5: CD 72 65    call $6572		; llama a la rutina de impresión de caracteres y de cambio de posición del texto según los valores que haya después de la llamada
		1F 2F 14 -> cambia el cursor a (0x2f, 0x14)
		3E -> '>'
		12 -> borra hasta el final de la línea
		5F -> '_'
		08 FF -> retrocede la posición x del cursor
6A00: C9          ret

; aquí llega si se ha pulsado la 'J'
6A01: 21 14 30    ld   hl,$3014
6A04: CD B7 62    call $62B7		; pone el cursor en la posición indicada por hl (h = posición en x, l = posición en y)
6A07: CD 72 65    call $6572		; llama a la rutina de impresión de caracteres y de cambio de posición del texto según los valores que haya después de la llamada
		4A 3A 20 5F 08 FF -> J: _ (y retrocede la posición del cursor una unidad)
6A10: CD 01 69    call $6901		; lee hasta 20 caracteres de teclado e interpreta los caracteres en binario o en hexadecimal para devolver el número convertido en hl
6A13: 7C          ld   a,h
6A14: B5          or   l
6A15: CA CF 6C    jp   z,$6CCF		; si se leyó 0, salta
6A18: 22 54 65    ld   ($6554),hl	;  en otro caso, modifica el PC y salta
6A1B: C3 CF 6C    jp   $6CCF

; aquí llega si se ha pulsado '1'
6A1E: 3A 33 65    ld   a,($6533)	; lee el estado de los break points
6A21: A7          and  a			; modifica los flags para saber si hay o no algún break point activo
6A22: 3A 7C 00    ld   a,($007C)	; lee el valor que había en la posición del break point
6A25: 2A 36 65    ld   hl,($6536)	; obtiene en hl la dirección del break point activo
6A28: C4 AB 00    call nz,$00AB		; si hay algún break point activo, fija configuracion 0 (0, 1, 2, 3), escribe a en hl y fija configuracion 4 (0, 4, 2, 3)
6A2B: 2A 22 65    ld   hl,($6522)
6A2E: 22 36 65    ld   ($6536),hl	; se pone la dirección actual como la del break point activo
6A31: 2A 22 65    ld   hl,($6522)
6A34: 22 36 65    ld   ($6536),hl
6A37: CD A0 00    call $00A0		; devuelve en a un byte leido de hl fijando la configuración original (luego restaura la configuración de depuración)
6A3A: 32 7C 00    ld   ($007C),a	; guarda el valor que hay en la posición donde se ha puesto el break point
6A3D: 3E 01       ld   a,$01
6A3F: 32 33 65    ld   ($6533),a	; indica que el break point 1 está activo
6A42: C3 80 6B    jp   $6B80		; imprime el estado de los break points (y si hay alguno activo, su dirección)

; aquí llega si se ha pulsado 'CLR'
6A45: 3A 33 65    ld   a,($6533)	; lee el estado de los break points
6A48: A7          and  a			; modifica los flags para saber si hay o no algún break point activo
6A49: 3A 7C 00    ld   a,($007C)	; obtiene el valor que había en la posición del break point
6A4C: 2A 36 65    ld   hl,($6536)	; obtiene en hl la dirección del break point activo
6A4F: C4 AB 00    call nz,$00AB		; si hay algún break point activo, fija configuracion 0 (0, 1, 2, 3), escribe a en hl y fija configuracion 4 (0, 4, 2, 3)
6A52: AF          xor  a
6A53: 32 33 65    ld   ($6533),a	; indica que no hay ningún break point activo
6A56: CD 80 6B    call $6B80		; imprime el estado de los break points (y si hay alguno activo, su dirección)
6A59: CD 60 64    call $6460		; muestra un volcado de la memoria de una zona o el código que hay en esa zona de memoria
6A5C: CD 34 68    call $6834		; muestra las 3 columnas de la parte inferior de la pantalla con el volcado de la memoria
6A5F: C9          ret

; aquí llega si se ha pulsado 'P'
6A60: CD 72 65    call $6572		; llama a la rutina de impresión de caracteres y de cambio de posición del texto según los valores que haya después de la llamada
		1F 30 14 -> cambia la posición del cursor a (0x30, 0x14)
		51 75 65 3F 08 FF -> Que? (y retrocede el cursor una posición)
6A6C: DD 21 09 6B ld   ix,$6B09		; apunta a la tabla de teclas para fijar las condiciones
6A70: DD 7E 00    ld   a,(ix+$00)	; lee una tecla
6A73: FE FF       cp   $FF
6A75: 28 E9       jr   z,$6A60		; si se han procesado todas las teclas, vuelve al inicio y repite otra vez
6A77: CD 98 63    call $6398		; comprueba si se pulsó la tecla a
6A7A: 20 0C       jr   nz,$6A88		; si se ha pulsado la tecla leida, salta
6A7C: DD 23       inc  ix			;  en otro caso, avanza a la siguiente entrada
6A7E: DD 23       inc  ix
6A80: DD 23       inc  ix
6A82: DD 23       inc  ix
6A84: DD 23       inc  ix
6A86: 18 E8       jr   $6A70		; continúa probando teclas

; aqui llega si se ha pulsado una tecla de la lista
6A88: DD 7E 00    ld   a,(ix+$00)	; lee la tecla que se ha pulsado
6A8B: CD 98 63    call $6398		; comprueba si se pulsó la tecla a
6A8E: 20 F8       jr   nz,$6A88		; espera a que se suelte la tecla
6A90: DD 6E 01    ld   l,(ix+$01)
6A93: DD 66 02    ld   h,(ix+$02)	; lee la instrucción para meter en pila el registro indicado
6A96: 22 63 00    ld   ($0063),hl	; modifica el código del depurador con la instrucción
6A99: DD 6E 03    ld   l,(ix+$03)	; lee los caracteres asociados a la tecla
6A9C: DD 66 04    ld   h,(ix+$04)
6A9F: 22 D3 6A    ld   ($6AD3),hl	; modifica la frase a imprimir
6AA2: 22 AE 6A    ld   ($6AAE),hl	; modifica la cadena de la condición
6AA5: 21 14 30    ld   hl,$3014
6AA8: CD B7 62    call $62B7		; pone el cursor en la posición indicada por hl (h = posición en x, l = posición en y)
6AAB: CD 72 65    call $6572		; llama a la rutina de impresión de caracteres y de cambio de posición del texto según los valores que haya después de la llamada
	XX XX 3D 20 DF 08 FF -> los 2 caracteres sobreescritos + "= _" (y retrocede el cursor una posición)
6AB5: CD 01 69    call $6901		; lee hasta 20 caracteres de teclado e interpreta los caracteres en binario o en hexadecimal para devolver el número convertido en hl

; graba e imprime la condición actual
6AB8: 22 31 65    ld   ($6531),hl	; escribe el valor de la condición
6ABB: ED 53 2F 65 ld   ($652F),de	; escribe la máscara de la condición
6ABF: CD F5 69    call $69F5		; escribe el prompt
6AC2: CD 72 65    call $6572		; llama a la rutina de impresión de caracteres y de cambio de posición del texto según los valores que haya después de la llamada
		1F 14 01 -> situa el cursor en (0x14, 0x01)
		43 4F 4E 44 49 43 49 4F 4E 3A 3A A0 48 4C 3D A0 FF -> CONDICION: HL=
6AD8: 2A 31 65    ld   hl,($6531)
6ADB: ED 5B 2F 65 ld   de,($652F)
6ADF: 7D          ld   a,l
6AE0: B4          or   h
6AE1: B2          or   d
6AE2: B3          or   e
6AE3: 28 16       jr   z,$6AFB		; si hl y de son 0, salta
6AE5: 7C          ld   a,h
6AE6: CD FC 65    call $65FC		; imprime h
6AE9: 7D          ld   a,l
6AEA: CD FC 65    call $65FC		; imprime l
6AED: 3E 20       ld   a,$20
6AEF: CD C5 62    call $62C5		; imprime un espacio
6AF2: 7A          ld   a,d
6AF3: CD FC 65    call $65FC		; imprime d
6AF6: 7B          ld   a,e
6AF7: CD FC 65    call $65FC		; imprime e
6AFA: C9          ret

; aquí salta si la condición es 0
6AFB: CD 72 65    call $6572		; llama a la rutina de impresión de caracteres y de cambio de posición del texto según los valores que haya después de la llamada
		4E 4F 4E 45 20 20 20 20 A0 FF -> NONE
6B08: C9          ret

; tabla para fijar las condiciones (cada entrada son 5 bytes)
6B09: 	2C E500 48 4C -> tecla 'H' -> HL
 		3D D500 44 45 -> tecla 'D' -> DE
 		36 C500 42 43 -> tecla 'B' -> BC
 		45 F500 41 46 -> tecla 'A' -> AF
 		3F E5DD 49 58 -> tecla 'X' -> IX
 		2B E5FD 49 59 -> tecla 'Y' -> IY
 		FF

; aquí llega si se ha pulsado 'Q'
6B28: CD 72 65    call $6572		; llama a la rutina de impresión de caracteres y de cambio de posición del texto según los valores que haya después de la llamada
		1F 30 14 -> cambia la posición del cursor a (0x30, 0x14)
		43 6F 6E 74 61 64 6F 72 3D 20 DF 08 FF -> Contador= _ (y retrocede un espacio)
6B3B: CD 01 69    call $6901		; lee hasta 20 caracteres de teclado e interpreta los caracteres en binario o en hexadecimal para devolver el número convertido en hl
6B3E: 7D          ld   a,l
6B3F: 32 51 00    ld   ($0051),a	; modifica el contador con los 2 últimos bytes leidos

; escribe el contador
6B42: CD 72 65    call $6572		; llama a la rutina de impresión de caracteres y de cambio de posición del texto según los valores que haya después de la llamada
		1F 37 01 ->  situa el cursor en (0x37, 0x01)
		63 6F 6E 74 61 64 6F 72 3D A0 FF -> CONTADOR=
6B53: 3A 51 00    ld   a,($0051)   	; lee el contador
6B56: CD FC 65    call $65FC		; dado un número en a, imprime en la posición actual el valor en hexadecimal del número
6B59: C3 F5 69    jp   $69F5		; escribe el prompt

; aquí llega si se ha pulsado '2'
6B5C: 3A 33 65    ld   a,($6533)    ; lee el estado de los break points
6B5F: A7          and  a            ; modifica los flags para saber si hay o no algún break point activo
6B60: 3A 7C 00    ld   a,($007C)    ; lee el valor que había en la posición del break point
6B63: 2A 36 65    ld   hl,($6536)   ; obtiene en hl la dirección del break point activo
6B66: C4 AB 00    call nz,$00AB     ; si hay algún break point activo, fija configuracion 0 (0, 1, 2, 3), escribe a en hl y fija configuracion 4 (0, 4, 2, 3)
6B69: 2A 22 65    ld   hl,($6522)
6B6C: 22 36 65    ld   ($6536),hl   ; se pone la dirección actual como la del break point activo
6B6F: 2A 22 65    ld   hl,($6522)
6B72: 22 36 65    ld   ($6536),hl
6B75: CD A0 00    call $00A0        ; devuelve en a un byte leido de hl fijando la configuración original (luego restaura la configuración de depuración)
6B78: 32 7C 00    ld   ($007C),a    ; guarda el valor que hay en la posición donde se ha puesto el break point
6B7B: 3E 02       ld   a,$02
6B7D: 32 33 65    ld   ($6533),a    ; indica que el break point 2 está activo

; imprime el estado de los break points (y si hay alguno activo, su dirección)
6B80: 21 01 01    ld   hl,$0101
6B83: CD B7 62    call $62B7		; pone el cursor en la posición (1,1)
6B86: CD 72 65    call $6572		; llama a la rutina de impresión de caracteres y de cambio de posición del texto según los valores que haya después de la llamada
	20 20 20 20 20 20 20 20 20 20 20 20 20 FF -> imprime 13 espacios
6B97: 21 01 01    ld   hl,$0101
6B9A: CD B7 62    call $62B7		; pone el cursor en la posición (1,1)
6B9D: 21 CD 6B    ld   hl,$6BCD		; apunta a una cadena de texto
6BA0: 3A 33 65    ld   a,($6533)	; lee el estado de los break points
6BA3: 87          add  a,a			; a = a*8
6BA4: 87          add  a,a
6BA5: 87          add  a,a
6BA6: 85          add  a,l			; hl = hl + a
6BA7: 6F          ld   l,a
6BA8: 8C          adc  a,h
6BA9: 95          sub  l
6BAA: 67          ld   h,a

6BAB: 06 08       ld   b,$08		; 8 caracteres de longitud
6BAD: 7E          ld   a,(hl)
6BAE: 23          inc  hl
6BAF: E6 7F       and  $7F
6BB1: CD C5 62    call $62C5		; lee un byte y lo escribe en pantalla
6BB4: 10 F7       djnz $6BAD

6BB6: 3E 20       ld   a,$20
6BB8: CD C5 62    call $62C5		; escribe un espacio
6BBB: 3A 33 65    ld   a,($6533)	; si no hay ningún break point puesto, sale
6BBE: A7          and  a
6BBF: C8          ret  z

; imprime la dirección del break point activo
6BC0: 3A 37 65    ld   a,($6537)
6BC3: CD FC 65    call $65FC		; dado un número en a, imprime en la posición actual el valor en hexadecimal del número
6BC6: 3A 36 65    ld   a,($6536)
6BC9: CD FC 65    call $65FC		; dado un número en a, imprime en la posición actual el valor en hexadecimal del número
6BCC: C9          ret

6BCD: 	4E 6F 20 62 72 65 61 6B -> No break
		42 72 65 61 6B 20 31 3D -> Break 1=
		42 72 65 61 6B 20 32 BD -> Break 2=
6BE5: C9          ret

; aquí llega si se ha pulsado 'R'
6BE6: 21 14 30    ld   hl,$3014
6BE9: CD B7 62    call $62B7		; pone el cursor en la posición indicada por hl (h = posición en x, l = posición en y)
6BEC: CD 72 65    call $6572		; llama a la rutina de impresión de caracteres y de cambio de posición del texto según los valores que haya después de la llamada
		52 3A 20 5F 08 FF -> R: _ (y retrocede el cursor una posición)
6BF5: CD 01 69    call $6901		; lee hasta 20 caracteres de teclado e interpreta los caracteres en binario o en hexadecimal para devolver el número convertido en hl
6BF8: 11 54 65    ld   de,$6554		; de apunta al primer registro
6BFB: 3A 2E 65    ld   a,($652E)	; obtiene el registro seleccionado actualmente
6BFE: 87          add  a,a
6BFF: 83          add  a,e
6C00: 5F          ld   e,a
6C01: 8A          adc  a,d
6C02: 93          sub  e
6C03: 57          ld   d,a			; de apunta al registro seleccionado
6C04: EB          ex   de,hl
6C05: 73          ld   (hl),e		; modifica el valor del registro seleccionado con lo que se ha leido
6C06: 23          inc  hl
6C07: 72          ld   (hl),d
6C08: CD 12 67    call $6712		; muestra los registros y sus valores, e indica cual está seleccionado
6C0B: C3 F5 69    jp   $69F5		; escribe el prompt

; aquí llega si se ha pulsado 'T'
6C0E: 21 14 30    ld   hl,$3014
6C11: CD B7 62    call $62B7		; pone el cursor en la posición indicada por hl (h = posición en x, l = posición en y)
6C14: CD 72 65    call $6572		; llama a la rutina de impresión de caracteres y de cambio de posición del texto según los valores que haya después de la llamada
		66 72 6F 6D 3A 20 DF 08 FF -> from: _ (y retrocede una unidad la posición del cursor)
6C20: CD 01 69    call $6901		; lee hasta 20 caracteres de teclado e interpreta los caracteres en binario o en hexadecimal para devolver el número convertido en hl
6C23: E5          push hl			; guarda la dirección leida
6C24: CD F5 69    call $69F5		; escribe el prompt
6C27: 21 14 30    ld   hl,$3014
6C2A: CD B7 62    call $62B7		; pone el cursor en la posición indicada por hl (h = posición en x, l = posición en y)
6C2D: CD 72 65    call $6572		; llama a la rutina de impresión de caracteres y de cambio de posición del texto según los valores que haya después de la llamada
		74 6F 3A 20 DF 08 FF -> to: _ (y retrocede una unidad la posición del cursor)
6C37: CD 01 69    call $6901		; lee hasta 20 caracteres de teclado e interpreta los caracteres en binario o en hexadecimal para devolver el número convertido en hl
6C3A: E5          push hl			; guarda la dirección leida
6C3B: CD F5 69    call $69F5		; escribe el prompt
6C3E: 21 14 30    ld   hl,$3014
6C41: CD B7 62    call $62B7		; pone el cursor en la posición indicada por hl (h = posición en x, l = posición en y)
6C44: CD 72 65    call $6572		; llama a la rutina de impresión de caracteres y de cambio de posición del texto según los valores que haya después de la llamada
		63 75 61 6E 74 6F 73 3A 20 DF 08 FF -> cuantos: _ (y retrocede una unidad la posición del cursor)
6C53: CD 01 69    call $6901		; lee hasta 20 caracteres de teclado e interpreta los caracteres en binario o en hexadecimal para devolver el número convertido en hl
6C56: 44          ld   b,h			; bc = número de bytes a copiar
6C57: 4D          ld   c,l
6C58: D1          pop  de			; de = dirección del to
6C59: E1          pop  hl			; hl = dirección del from
6C5A: C5          push bc
6C5B: CD A0 00    call $00A0		; devuelve en a un byte leido de hl fijando la configuración original (luego restaura la configuración de depuración)
6C5E: EB          ex   de,hl
6C5F: CD AB 00    call $00AB		; fija configuracion 0 (0, 1, 2, 3), escribe a en hl y fija configuracion 4 (0, 4, 2, 3)
6C62: EB          ex   de,hl
6C63: C1          pop  bc
6C64: 0B          dec  bc
6C65: 78          ld   a,b
6C66: B1          or   c
6C67: 20 F1       jr   nz,$6C5A		; copia bytes del from al to mientras bc > 0
6C69: C3 F5 69    jp   $69F5		; escribe el prompt

; ---------------- inicio real del depurador ---------------------------
6C6C: 22 64 65    ld   ($6564),hl	; guarda bc
6C6F: ED 53 60 65 ld   ($6560),de	; guarda de
6C73: 2A 79 00    ld   hl,($0079)	; lee la dirección donde se guarda hl
6C76: 22 5C 65    ld   ($655C),hl	; guarda hl
6C79: 2A 75 00    ld   hl,($0075)	; lee la dirección de af
6C7C: 22 68 65    ld   ($6568),hl	; guarda af
6C7F: E1          pop  hl			; recupera la dirección de retorno
6C80: ED 73 56 65 ld   ($6556),sp	; guarda el sp real
6C84: E5          push hl			; guarda de nuevo la dirección de retorno
6C85: 2B          dec  hl
6C86: 22 54 65    ld   ($6554),hl	; guarda el pc
6C89: DD 22 5A 65 ld   ($655A),ix	; guarda ix
6C8D: FD 22 58 65 ld   ($6558),iy	; guarda iy
6C91: 3A 7C 00    ld   a,($007C)	; lee el valor que había en el break point activo
6C94: 2A 36 65    ld   hl,($6536)	; lee la dirección del break point activo
6C97: CD AB 00    call $00AB		; fija configuracion 0 (0, 1, 2, 3), escribe a en hl y fija configuracion 4 (0, 4, 2, 3)
6C9A: F3          di
6C9B: D9          exx
6C9C: 22 5E 65    ld   ($655E),hl	; guarda hl'
6C9F: ED 53 62 65 ld   ($6562),de	; guarda de'
6CA3: ED 43 66 65 ld   ($6566),bc	; guarda bc'
6CA7: D9          exx
6CA8: 08          ex   af,af'
6CA9: F5          push af
6CAA: E1          pop  hl
6CAB: 22 6A 65    ld   ($656A),hl	; guarda af'
6CAE: 08          ex   af,af'

6CAF: 11 00 40    ld   de,$4000
6CB2: 21 00 40    ld   hl,$4000		; ???
6CB5: CD CA 00    call $00CA		; fija configuracion 5 (0, 5, 2, 3), copia 0x4000 bytes de hl a de y fija configuracion 4 (0, 4, 2, 3)
6CB8: 3E 5F       ld   a,$5F
6CBA: CD C5 62    call $62C5		; escribe '_' en la posición actual del cursor
6CBD: 3E 2F       ld   a,$2F
6CBF: CD 98 63    call $6398		; comprueba si se pulsó el espacio
6CC2: 28 F9       jr   z,$6CBD		; mientras no se pulse el espacio, salta

6CC4: CD 17 6E    call $6E17		; limpia la memoria de video
6CC7: 01 8E 7F    ld   bc,$7F8E		; 10001110 (GA select screen mode, rom cfig and int control)
6CCA: ED 49       out  (c),c		; selecciona el modo 2 y deshabilita la rom superior e inferior
6CCC: C3 3A 62    jp   $623A		; salta al bucle principal del depurador

; ---------------- fin del inicio real del depurador ---------------------------

; aquí llega después de pulsar 'J'
6CCF: 2A 31 65    ld   hl,($6531)	; obtiene la máscara de la condición
6CD2: ED 5B 2F 65 ld   de,($652F)	; obtiene el valor de la condición
6CD6: 3A 33 65    ld   a,($6533)	; lee el estado de los break points
6CD9: FE 02       cp   $02
6CDB: 28 06       jr   z,$6CE3		; si está activo el número 2, salta
6CDD: 21 00 00    ld   hl,$0000		; sino, pone a 0 la condición y la máscara
6CE0: 11 00 00    ld   de,$0000

6CE3: 7C          ld   a,h			; modifica unas instrucciones
6CE4: 32 71 00    ld   ($0071),a
6CE7: 7D          ld   a,l
6CE8: 32 6A 00    ld   ($006A),a
6CEB: 7B          ld   a,e
6CEC: 32 68 00    ld   ($0068),a
6CEF: 7A          ld   a,d
6CF0: 32 6F 00    ld   ($006F),a

6CF3: 2A 36 65    ld   hl,($6536)	; hl = dirección del break point activo
6CF6: ED 5B 54 65 ld   de,($6554)	; de = dirección del PC
6CFA: 7B          ld   a,e
6CFB: AD          xor  l
6CFC: AA          xor  d
6CFD: AC          xor  h			; si el pc coincide con el break point activo, termina la ejecución
6CFE: 3E 38       ld   a,$38		; jr c
6D00: 28 02       jr   z,$6D04
6D02: 3E 30       ld   a,$30		; jr nc
6D04: 32 90 00    ld   ($0090),a	; modifica una instrucción
6D07: 7E          ld   a,(hl)		; lee lo que hay en la posición del break point y lo guarda
6D08: 32 7C 00    ld   ($007C),a
6D0B: 36 F7       ld   (hl),$F7		; modifica lo que había en la posición del break point con rst 0x048
6D0D: 2A 6A 65    ld   hl,($656A)	; hl = af'

6D10: 11 00 C0    ld   de,$C000
6D13: 21 00 40    ld   hl,$4000
6D16: CD CA 00    call $00CA		; fija configuracion 5 (0, 5, 2, 3), copia 0x4000 bytes de hl a de y fija configuracion 4 (0, 4, 2, 3)
6D19: F3          di
6D1A: 08          ex   af,af'
6D1B: E5          push hl			; bug!?! hl ha sido sobreescrito y ya no contiene af'
6D1C: F1          pop  af
6D1D: 08          ex   af,af'
6D1E: D9          exx
6D1F: ED 4B 66 65 ld   bc,($6566)	; restaura bc'
6D23: ED 5B 62 65 ld   de,($6562)	; restaura de'
6D27: 2A 5E 65    ld   hl,($655E)	; restaura hl'
6D2A: D9          exx
6D2B: FB          ei
6D2C: FD 2A 58 65 ld   iy,($6558)	; restaura iy
6D30: DD 2A 5A 65 ld   ix,($655A)	; restaura ix
6D34: ED 7B 56 65 ld   sp,($6556)	; restaura sp
6D38: 2A 54 65    ld   hl,($6554)	; restaura el pc y lo mete en la pila
6D3B: E5          push hl
6D3C: ED 5B 60 65 ld   de,($6560)	; restaura de
6D40: 2A 5C 65    ld   hl,($655C)	; restaura hl
6D43: 22 79 00    ld   ($0079),hl
6D46: 2A 68 65    ld   hl,($6568)	; restaura af
6D49: 22 75 00    ld   ($0075),hl
6D4C: 2A 64 65    ld   hl,($6564)	; hl = bc original
6D4F: C3 88 00    jp   $0088		; salta a ejecutar el código

; aquí llega si se pulsó el escape
6D52: 01 8E 7F    ld   bc,$7F8E
6D55: CD 17 6E    call $6E17		; limpia la memoria de video
6D58: 31 FF BF    ld   sp,$BFFF		; pone la pila en ???
6D5B: CD 72 65    call $6572		; llama a la rutina de impresión de caracteres y de cambio de posición del texto según los valores que haya después de la llamada
		1F 01 05 -> pone el cursor en (1, 5)
		31 2D 20 43 4F 52 52 45 52 20 45 4C 20 50 52 4F 47 52 41 4D C1 0D 0A 0A -> 1- CORRER EL PROGRAMA
		32 2D 20 53 41 4C 54 4F 20 41 20 4D 4F 4E D3 0D 0A 0A -> 2- SALTO A MONS
		33 2D 20 52 45 43 49 42 49 D2 FF -> 3- RECIBIR

6D96: 21 52 6D    ld   hl,$6D52		; guarda la dirección de esta rutina como dirección de retorno
6D99: E5          push hl

6D9A: 3E 40       ld   a,$40
6D9C: CD 98 63    call $6398		; comprueba si se pulsó 1
6D9F: C2 B3 00    jp   nz,$00B3		; si se pulsó 1, salta
6DA2: 3E 41       ld   a,$41
6DA4: CD 98 63    call $6398		; comprueba si se pulsó 2
6DA7: C2 7E 00    jp   nz,$007E		; si se pulsó 2, salta
6DAA: 3E 39       ld   a,$39
6DAC: CD 98 63    call $6398		; comprueba si se pulsó 3
6DAF: C2 B4 6D    jp   nz,$6DB4		; si se pulsó 3, salta
6DB2: 18 E6       jr   $6D9A		; repite hasta que se pulse alguna opción

; aquí salta si se pulsó 3 (recibir)
6DB4: CD 17 6E    call $6E17		; limpia la memoria de video
6DB7: CD 72 65    call $6572		; llama a la rutina de impresión de caracteres y de cambio de posición del texto según los valores que haya después de la llamada
		1F 01 05 -> posiciona el cursor en (1, 5)
		45 53 43 20 50 41 52 41 20 43 4F 52 54 41 D2 FF -> ESC PARA CORTAR
6DCD: 21 00 01    ld   hl,$0100		; guarda la dirección en donde empezar a copiar los datos

6DD0: E5          push hl
6DD1: CD ED 6D    call $6DED		; ??? (hace algo con la rom de expansión 6, pero al no tenerla, no se sabe que hace)
6DD4: 3A 10 6E    ld   a,($6E10)
6DD7: A7          and  a
6DD8: 20 0A       jr   nz,$6DE4		; si ha terminado de copiar los datos?, salta
6DDA: 3A 11 6E    ld   a,($6E11)	; lee el byte recibido
6DDD: E1          pop  hl			; obtiene la dirección en donde copiarlo
6DDE: CD AB 00    call $00AB		; fija configuracion 0 (0, 1, 2, 3), escribe a en hl y fija configuracion 4 (0, 4, 2, 3)
6DE1: 23          inc  hl			; avanza a la siguiente dirección
6DE2: 18 EC       jr   $6DD0

; aquí llega si 0x6e10 no es 0 (si se ha terminado de copiar los datos?)
6DE4: 3E 42       ld   a,$42
6DE6: CD 98 63    call $6398		; comprueba si se pulsó escape
6DE9: E1          pop  hl
6DEA: C0          ret  nz			; si se pulsó, sale
6DEB: 18 E3       jr   $6DD0		; en otro caso salta a recibir

; rutina que carga la rom de expansión 6 y hace algo
6DED: 01 06 DF    ld   bc,$DF06		; selecciona la rom de expansión 6 (???) (estará disponible en 0xc000-0xffff)
6DF0: ED 49       out  (c),c
6DF2: 01 86 7F    ld   bc,$7F86		; gate array -> 10000110 (select screen mode, rom cfig and int control)
6DF5: ED 49       out  (c),c		; selecciona el modo 2 y deshabilita la rom inferior, pero no la superior
6DF7: DD 21 13 6E ld   ix,$6E13		; apunta a los punteros para guardar los datos y el estado???
6DFB: 3E 02       ld   a,$02
6DFD: FD 21 8E 6E ld   iy,$6E8E		; apunta a parte del código de ejecución del depurador???
6E01: CD C2 C4    call $C4C2		; ???
6E04: 01 00 DF    ld   bc,$DF00		; selecciona la rom de expansión de basic (estará disponible en 0xc000-0xffff)
6E07: ED 49       out  (c),c
6E09: 01 8E 7F    ld   bc,$7F8E		; 10001110 (GA select screen mode, rom cfig and int control)
6E0C: ED 49       out  (c),c		; selecciona el modo 2 y deshabilita la rom superior e inferior
6E0E: C9          ret

; variables modificadas por la rom de expansión
6E0F: 00
6E10: 02
6E11: 01
6E12: 00 

6E13-6E14: 6E11
6E15-6E16: 6E0F

; limpia la memoria de video
6E17: 21 00 C0    ld   hl,$C000
6E1A: 11 01 C0    ld   de,$C001
6E1D: 01 FF 3F    ld   bc,$3FFF
6E20: 36 00       ld   (hl),$00
6E22: ED B0       ldir
6E24: C9          ret

6E25: 00          nop

; ------------------- código copiado a 0x0048-0x00ff ---------------------
6E26: F5          push af
6E27: 22 79 00    ld   ($0079),hl
6E2A: E1          pop  hl
6E2B: 22 75 00    ld   ($0075),hl
6E2E: 3E 00       ld   a,$00
6E30: D6 01       sub  $01
6E32: 38 05       jr   c,$6E39
6E34: 32 51 00    ld   ($0051),a
6E37: 18 19       jr   $6E52
6E39: 2A 75 00    ld   hl,($0075)
6E3C: E5          push hl
6E3D: 2A 79 00    ld   hl,($0079)
6E40: F1          pop  af
6E41: 00          nop
6E42: E5          push hl
6E43: E1          pop  hl
6E44: 7D          ld   a,l
6E45: E6 00       and  $00
6E47: EE 00       xor  $00
6E49: 20 07       jr   nz,$6E52
6E4B: 7C          ld   a,h
6E4C: E6 00       and  $00
6E4E: EE 00       xor  $00
6E50: 28 0A       jr   z,$6E5C
6E52: 21 00 00    ld   hl,$0000
6E55: E5          push hl
6E56: 21 00 00    ld   hl,$0000
6E59: F1          pop  af
6E5A: 00          nop
6E5B: C9          ret
6E5C: 60          ld   h,b
6E5D: 69          ld   l,c
6E5E: 01 C4 7F    ld   bc,$7FC4
6E61: ED 49       out  (c),c
6E63: C3 6C 6C    jp   $6C6C
6E66: 01 C0 7F    ld   bc,$7FC0
6E69: ED 49       out  (c),c
6E6B: 44          ld   b,h
6E6C: 4D          ld   c,l
6E6D: 37          scf
6E6E: 38 09       jr   c,$6E79
6E70: 2A 75 00    ld   hl,($0075)
6E73: E5          push hl
6E74: 2A 79 00    ld   hl,($0079)
6E77: F1          pop  af
6E78: C9          ret
6E79: E1          pop  hl
6E7A: 23          inc  hl
6E7B: E5          push hl
6E7C: 18 D4       jr   $6E52
6E7E: 01 C0 7F    ld   bc,$7FC0
6E81: ED 49       out  (c),c
6E83: 7E          ld   a,(hl)
6E84: 0E C4       ld   c,$C4
6E86: ED 49       out  (c),c
6E88: C9          ret
6E89: 01 C0 7F    ld   bc,$7FC0
6E8C: ED 49       out  (c),c
6E8E: 77          ld   (hl),a
6E8F: 18 F3       jr   $6E84
6E91: C1          pop  bc
6E92: 01 30 00    ld   bc,$0030
6E95: C5          push bc
6E96: 3A 34 65    ld   a,($6534)
6E99: 01 8C 7F    ld   bc,$7F8C
6E9C: B1          or   c
6E9D: 4F          ld   c,a
6E9E: ED 49       out  (c),c
6EA0: 01 C0 7F    ld   bc,$7FC0
6EA3: ED 49       out  (c),c
6EA5: C3 00 01    jp   $0100
6EA8: 01 C5 7F    ld   bc,$7FC5
6EAB: ED 49       out  (c),c
6EAD: 01 00 40    ld   bc,$4000
6EB0: ED B0       ldir
6EB2: 01 C4 7F    ld   bc,$7FC4
6EB5: ED 49       out  (c),c
6EB7: C9          ret
6EB8: 00          nop
6EB9: 00          nop
6EBA: 00          nop
6EBB: 00          nop
6EBC: 00          nop
6EBD: 00          nop
6EBE: FF          rst  $38
6EBF: 6A          ld   l,d
6EC0: 01 00 01    ld   bc,$0100
6EC3: 00          nop
6EC4: FF          rst  $38
6EC5: 00          nop
6EC6: 00          nop
6EC7: 00          nop
6EC8: 00          nop
6EC9: 00          nop
6ECA: 00          nop
6ECB: 00          nop
6ECC: 00          nop
6ECD: 00          nop
6ECE: 00          nop
6ECF: 00          nop
6ED0: 00          nop
6ED1: 00          nop
6ED2: 00          nop
6ED3: 00          nop
6ED4: 00          nop
6ED5: 00          nop
6ED6: 00          nop
6ED7: 00          nop
6ED8: 00          nop
6ED9: 00          nop
6EDA: 00          nop
6EDB: 00          nop
6EDC: 00          nop
6EDD: 00          nop
6EDE: 00          nop
6EDF: 00          nop
; ------------------- fin del código copiado a 0x0048-0x00ff ---------------------

6EE0: BA 5E 9A 5E BA 5E BA 5E-BA 5E BA 5E BA 5E BA 5E .^.^.^.^.^.^.^.^
6EF0: BA 5E BA 5E BA 5E BA 5E-BA 5E BA 5E BA 5E BA 5E .^.^.^.^.^.^.^.^
6F00: 8A 0A 8A 0A 8A 0A 8A 0A-8A 0A 8A 0A 8A 0A 8A 0A ................
6F10: 8A 0A 8A 0A 8A 0A 8A 0A-8A 0A 8A 0A 8A 0A 8A 0A ................
6F20: 8A 0A 8A 0A 8A 0A 8A 0A-8A 0A 8A 0A 8A 0A 8A 0A ................
6F30: 8A 0A 8A 0A 8A 0A 8A 0A-8A 0A 8A 0A 8A 0A 8A 0A ................
6F40: 8A 0A 8A 0A 8A 0A 8A 0A-8A 0A 8A 0A 8A 0A 8A 0A ................
6F50: 8A 0A 8A 0A 8A 0A 8A 0A-8A 0A 8A 0A 8A 0A 8A 0A ................
6F60: 08 08 8A 0A 8A 0A 8A 0A-8A 0A 8A 0A 8A 0A 8A 0A ................
6F70: 8A 0A 8A 0A 8A 0A 8A 0A-8A 0A 8A 0A 8A 0A 8A 0A ................
6F80: 9A 5E BA 5E 9A 5E 9A 5E-9A 5E 9A 4E 9A 5E BA 5E .^.^.^.^.^.N.^.^
6F90: 9A 5E 9A 5E 9A 5E BA 5E-9A 5E 9A 5E BA 5E 9A 5E .^.^.^.^.^.^.^.^
6FA0: 9A 5E 9A 5E 9A 5E 9A 5E-9A 5E BA 5E BA 5E BA 5E .^.^.^.^.^.^.^.^
6FB0: BA 5E 9A 5E BA 5E BA 5E-9A 5E 9A 5E BA 5E BA 5E .^.^.^.^.^.^.^.^
6FC0: BA 5E 9A 5E 9A 5E 9A 5E-9A 5E 9A 5E BA 5E BA 5E .^.^.^.^.^.^.^.^
6FD0: 9A 5E 9A 5E 9A 5E BA 5E-9A 5E BA 5E 9A 5E BA 5E .^.^.^.^.^.^.^.^
6FE0: 9A 4E 9A 5E 9A 5E BA 5E-9A 5E 9A 5E 9A 5E BA 5E .N.^.^.^.^.^.^.^
6FF0: 9A 5E 9A 5E 9A 4E 92 1A-9A 5E BA 5E 9A 5E 82 0A .^.^.N...^.^.^..
7000: 99 80 99 80 99 80 99 80-99 80 99 80 99 80 99 80 ................
7010: 99 80 99 80 99 80 99 80-99 80 99 80 99 80 99 80 ................
7020: 99 80 99 80 99 80 99 80-99 80 99 80 99 80 99 80 ................
7030: 99 80 99 80 99 80 99 80-99 80 99 80 99 80 99 80 ................
7040: 99 80 99 80 99 80 99 80-99 80 99 80 99 80 99 80 ................
7050: 99 80 99 80 99 80 99 80-99 80 99 80 99 80 99 80 ................
7060: 99 80 99 80 99 80 99 80-99 80 99 80 99 80 99 80 ................
7070: 99 80 99 80 91 80 99 80-99 80 99 80 99 80 99 80 ................
7080: DF 82 DF 82 DF 82 DF 82-DF 82 DF 82 DF 82 DF 82 ................
7090: DF 82 DF 82 DD 82 DF 82-DF 82 DF 82 DF 82 DD 82 ................
70A0: DF 82 DF 82 DF 82 DF 82-DF 82 DF 82 DF 82 DF 82 ................
70B0: DF 82 DF 82 DF 82 DF 82-DF 82 DF 82 DF 82 DF 82 ................
70C0: DF 82 DF 82 DF 82 DF 82-DF 82 DF 82 DF 82 DF 82 ................
70D0: DF 82 DF 82 DF 82 DF 82-DF 82 DF 82 DD 82 DF 82 ................
70E0: DF 82 DF 82 DF 82 DF 82-DF 82 DF 82 DF 82 DF 82 ................
70F0: DF 82 DF 82 DF 82 DF 82-DF 82 DF 82 DF 82 DF 82 ................
7100: 99 80 99 80 99 80 99 80-99 80 99 80 99 80 99 80 ................
7110: 99 80 99 80 99 80 99 80-99 80 99 80 99 80 99 80 ................
7120: 99 80 99 80 99 80 99 80-99 80 99 80 99 80 99 80 ................
7130: 99 80 99 80 99 80 99 80-99 80 99 80 99 80 99 80 ................
7140: 99 80 99 80 99 80 99 80-99 80 99 80 99 80 99 80 ................
7150: 99 80 99 80 99 80 99 80-99 80 99 80 99 80 99 80 ................
7160: 18 00 99 80 99 80 99 80-99 80 99 80 99 80 99 80 ................
7170: 99 80 99 80 99 80 99 80-99 80 89 80 99 80 99 80 ................
7180: 9F 82 DF 82 9F 80 9F 82-9F 82 9F 82 DF 82 DF 82 ................
7190: DF 82 DF 82 DF 82 DF 82-DF 82 DF 82 DF 82 DF 82 ................
71A0: DF 82 DF 82 DF 82 DF 80-DF 82 DF 82 DF 82 DF 82 ................
71B0: DF 82 9F 80 DF 82 DF 80-DF 82 DF 82 DF 80 DF 82 ................
71C0: DF 82 DF 82 9F 82 DF 82-9F 82 9F 82 DB 82 DF 82 ................
71D0: 9F 82 DF 82 DF 80 DF 80-DF 82 9F 82 DF 80 DF 82 ................
71E0: 9F 82 9F 82 DF 82 DF 80-9F 82 9F 80 DF 80 DF 82 ................
71F0: 9F 82 9F 82 DF 80 9D 80-DF 82 DF 82 DF 82 19 80 ................
7200: 32 D6 32 D6 32 D6 32 D6-32 D6 32 D6 32 D6 32 D6 2.2.2.2.2.2.2.2.
7210: 32 D6 32 D6 32 D6 32 D6-32 D6 32 D6 32 D6 32 D6 2.2.2.2.2.2.2.2.
7220: 32 D6 32 D6 32 D6 32 D6-32 D6 32 D6 32 D6 32 D6 2.2.2.2.2.2.2.2.
7230: 32 D6 32 D6 32 D6 32 D6-32 96 32 D6 32 D6 32 D6 2.2.2.2.2.2.2.2.
7240: 32 D6 32 D6 32 D6 32 D6-32 96 32 96 32 D6 32 D6 2.2.2.2.2.2.2.2.
7250: 32 D6 32 96 32 D6 32 D6-32 86 32 D6 32 D6 32 D6 2.2.2.2.2.2.2.2.
7260: 32 96 32 96 32 D6 32 D6-32 96 32 96 32 D6 32 D6 2.2.2.2.2.2.2.2.
7270: 32 96 32 D6 32 D6 32 D6-32 96 32 D6 32 D6 32 D6 2.2.2.2.2.2.2.2.
7280: 3A F6 7E F6 7E F6 3E F6-3A F6 7A F6 3A F6 7E F6 :.~.~.>.:.z.:.~.
7290: 7A F6 7E F6 7A F6 7E F6-3A F6 3A F6 7E F6 7A F6 z.~.z.~.:.:.~.z.
72A0: 7E F6 7E F6 7E F6 7E F6-3E F6 3E F6 7A F6 7E F6 ~.~.~.~.>.>.z.~.
72B0: 3E F6 7E F6 7E F6 7E F6-7E F6 7E F6 7E F6 7E F6 >.~.~.~.~.~.~.~.
72C0: 3A F6 3E F6 7E F6 7E F6-7E F6 3A F6 7E F6 7A F6 :.>.~.~.~.:.~.z.
72D0: 3E F6 3E F6 3E F6 7E F6-7E F6 3E F6 7E F6 7E F6 >.>.>.~.~.>.~.~.
72E0: 7E F6 3E F6 7E F6 7E F6-3E F6 3E F6 7E F6 7A F6 ~.>.~.~.>.>.~.z.
72F0: 7A F6 3A F6 7E F6 7E F6-7E F6 7A F6 7A F6 3E F6 z.:.~.~.~.z.z.>.
7300: 32 D6 32 D6 32 D6 32 D6-32 D6 32 D6 32 D6 32 D6 2.2.2.2.2.2.2.2.
7310: 32 D6 32 D6 32 D6 32 D6-32 D6 32 D6 32 D6 32 D6 2.2.2.2.2.2.2.2.
7320: 32 D2 32 D6 32 D6 32 D6-32 D6 32 D6 32 D6 32 D6 2.2.2.2.2.2.2.2.
7330: 32 D6 32 D6 32 D6 32 D6-32 D6 32 D6 32 D6 32 D6 2.2.2.2.2.2.2.2.
7340: 32 D6 32 D6 32 D6 32 D6-32 D6 32 D6 32 D6 32 D6 2.2.2.2.2.2.2.2.
7350: 32 D6 32 D6 32 D6 32 D6-32 D6 32 D6 32 D6 32 D6 2.2.2.2.2.2.2.2.
7360: 10 14 32 D2 32 D6 32 D6-32 D6 32 D6 32 D6 32 D6 ..2.2.2.2.2.2.2.
7370: 32 D6 32 D6 32 D6 32 D6-32 D6 22 C6 32 D6 32 D6 2.2.2.2.2.".2.2.
7380: 3A F6 3A F6 3A F6 3A F6-3A F6 3A F6 3A F6 3E F6 :.:.:.:.:.:.:.>.
7390: 3E F6 3A F6 7A F6 7A F6-7E F6 7E F6 7E F6 7A F6 >.:.z.z.~.~.~.z.
73A0: 3E F6 7A F6 7A F6 72 F6-72 F6 7A F6 7E F6 7E F6 >.z.z.r.r.z.~.~.
73B0: 7A F6 3E F6 7E F6 7A F6-7E F6 7A F6 7E F6 7E F6 z.>.~.z.~.z.~.~.
73C0: 3E F6 3E F6 3A F6 3A F6-3A F6 3E F6 3E F6 3A F6 >.>.:.:.:.>.>.:.
73D0: 3A F6 3A F6 7E F6 3A F6-3A F6 3A F6 3A F6 7E F6 :.:.~.:.:.:.:.~.
73E0: 3A F6 3E F6 3A F6 3A F6-3A F6 3A F6 7A F6 3E F6 :.>.:.:.:.:.z.>.
73F0: 3A F6 3E F6 3E F6 32 D6-3E F6 3E F6 7E F6 32 D6 :.>.>.2.>.>.~.2.
7400: DF A8 D3 A0 D7 A0 D7 A0-D7 A8 D3 A0 C7 A0 D7 A0 ................
7410: D3 A0 D3 A0 D7 A0 D7 A0-C3 A0 D3 A0 D7 A0 D7 A0 ................
7420: D3 A0 C3 A0 D7 A0 D7 A0-83 A0 83 A0 D3 A0 D7 A0 ................
7430: C3 A0 C3 A0 D7 A0 D7 A0-C3 A0 C3 A0 D7 A0 D7 A0 ................
7440: 83 A0 C3 A0 C3 A0 D7 A0-83 A0 83 A0 C3 A0 D3 A0 ................
7450: 83 A0 C3 A0 D7 A0 D7 A0-83 A0 C3 A0 D7 A0 D7 A0 ................
7460: 83 A0 83 A0 D7 A0 D7 A0-83 A0 83 A0 C7 A0 93 A0 ................
7470: C3 A0 83 A0 D7 A0 D7 A0-83 A0 83 A0 D7 A0 D7 A0 ................
7480: DF EC FF EC FF EC FF EC-DF EC FF EC FF EC FF EC ................
7490: FF EC FF EC FF EC FF EC-FF EC DF EC FF EC FF EC ................
74A0: FF EC DF EC FF EC FF EC-FF EC DF EC FF EC FF EC ................
74B0: FF EC FF EC FF EC FF EC-DF EC FF EC FF EC FF EC ................
74C0: FF EC FF EC FF EC FF EC-DF EC FF EC DF EC FF EC ................
74D0: FF EC FF EC FF EC FF EC-DF EC FF EC FF EC FF EC ................
74E0: FF EC DF EC FF EC FF EC-DF EC FF EC FF EC FF EC ................
74F0: FF EC FF EC FF EC FF EC-FF EC DF EC FF EC FF EC ................
7500: D7 A0 D3 A0 D7 A0 D7 A0-D3 A0 D3 A0 D7 A0 93 A0 ................
7510: D3 A0 D7 A0 D7 A0 D7 A0-D3 A0 D3 A0 D7 A0 D7 A0 ................
7520: D3 A0 D3 A0 D7 A0 D7 A0-D3 A0 D3 A0 D7 A0 D7 A0 ................
7530: D3 A0 D7 A0 D7 A0 D7 A0-D3 A0 D7 A0 D7 A0 D7 A0 ................
7540: D3 A0 D3 A0 D7 A0 D7 A0-D3 A0 D3 A0 D7 A0 D7 A0 ................
7550: D7 A0 D7 A0 D7 A0 D7 A0-D3 A0 D7 A0 D7 A0 D7 A0 ................
7560: 10 00 D3 A0 D7 A0 D7 A0-D3 A0 D3 A0 D7 A0 D7 A0 ................
7570: D3 A0 D3 A0 D7 A0 D7 A0-D3 A0 C7 A0 D7 A0 D7 A0 ................
7580: DF EC FF EC DF EC DF EC-DF EC FF EC FF EC FF EC ................
7590: FF EC FF EC DF EC FF EC-DF EC FF EC FF EC FF EC ................
75A0: DF EC FF EC FF EC DF EC-DF EC DF EC DF EC FF EC ................
75B0: DF EC DF EC DF EC FF EC-DF EC DF EC FF EC FF EC ................
75C0: FF EC DF EC FF EC DF EC-FF EC FF EC FF EC FF E8 ................
75D0: FF EC DF EC FF EC FF EC-FF EC FF EC FF EC FF EC ................
75E0: DF EC FF EC FF EC DF EC-DF EC FF EC DF EC FF EC ................
75F0: FF EC FF EC DF EC D7 E8-FF EC FF E8 FF EC D7 A8 ................
7600: BE 22 AE 02 AE 02 AE 02-AE 02 AE 02 AE 02 AE 02 ."..............
7610: AE 02 AE 02 AE 02 AE 02-AE 02 AE 02 AE 02 AE 02 ................
7620: AE 02 AE 02 AE 02 AE 02-AE 02 AE 02 AE 02 AE 02 ................
7630: AE 02 AE 02 AE 02 AE 02-AE 02 AE 02 AE 02 AE 02 ................
7640: AE 02 AE 02 AE 02 AE 02-AA 02 AE 02 AE 02 AE 02 ................
7650: AE 02 AE 02 AE 02 AE 02-AE 02 AE 02 AE 02 AE 02 ................
7660: AE 02 AE 02 AE 02 AE 02-AA 02 AE 02 AE 02 AE 02 ................
7670: AE 02 AE 02 A6 02 AE 02-AE 02 AE 02 AE 02 AE 02 ................
7680: FE 32 FE 36 FE 36 FE 36-FE 36 FE 36 FE 36 FE 32 .2.6.6.6.6.6.6.2
7690: FE 36 FE 36 FE 36 FE 32-FE 32 FE 32 FE 36 FE 32 .6.6.6.2.2.2.6.2
76A0: FE 36 FE 36 FE 36 FE 36-FE 36 FE 36 FE 32 FE 36 .6.6.6.6.6.6.2.6
76B0: FE 36 FE 36 FE 36 FE 36-FE 36 FE 36 FE 32 FE 36 .6.6.6.6.6.6.2.6
76C0: FE 36 FE 36 FE 32 FE 32-FE 36 FE 36 FE 36 FE 32 .6.6.2.2.6.6.6.2
76D0: FE 36 FE 36 FE 36 FE 32-FE 36 FE 36 FE 32 FE 32 .6.6.6.2.6.6.2.2
76E0: FE 36 FE 36 FE 32 FE 32-FE 32 FE 36 FE 32 FE 36 .6.6.2.2.2.6.2.6
76F0: FE 36 FE 36 FE 32 FE 36-FE 36 FE 36 FE 36 FE 32 .6.6.2.6.6.6.6.2
7700: AE 02 AE 02 AE 02 AE 02-AE 02 AE 02 AE 02 AE 02 ................
7710: AE 02 AE 02 AE 02 AE 02-AE 02 AE 02 AE 02 AE 02 ................
7720: AE 02 AE 02 AE 02 AE 02-AE 02 AE 02 AE 02 AE 02 ................
7730: AE 02 AE 02 AE 02 AE 02-AE 02 AE 02 AE 02 AE 02 ................
7740: AE 02 AE 02 AE 02 AE 02-AE 02 AE 02 AE 02 AE 02 ................
7750: AE 02 AE 02 AE 02 AE 02-AE 02 AE 02 AE 02 AE 02 ................
7760: 0C 00 AA 02 AE 02 AE 02-AE 02 AE 02 AE 02 AE 02 ................
7770: AE 02 AE 02 AE 02 AE 02-AE 02 AE 02 AE 02 AE 02 ................
7780: FE 36 FE 36 FE 32 FE 36-FE 36 FE 32 FE 36 FE 36 .6.6.2.6.6.2.6.6
7790: FE 36 FE 36 FE 32 FE 36-FE 36 FE 32 FE 36 FE 36 .6.6.2.6.6.2.6.6
77A0: FE 36 FE 32 FE 32 FE 32-FE 36 FE 36 FE 36 FE 36 .6.2.2.2.6.6.6.6
77B0: FE 36 FE 36 FE 36 FE 36-FE 36 FE 32 FE 36 FE 36 .6.6.6.6.6.2.6.6
77C0: FE 32 FE 32 FE 36 FE 36-FE 36 FE 32 FE 32 FE 32 .2.2.6.6.6.2.2.2
77D0: FE 36 FE 36 FE 36 FE 32-FE 36 FE 32 FE 32 FE 36 .6.6.6.2.6.2.2.6
77E0: FE 32 FE 32 FE 36 FE 32-FE 36 FE 36 FE 36 FE 36 .2.2.6.2.6.6.6.6
77F0: FE 36 FE 32 FE 32 FE 12-FE 36 FE 32 FE 36 BE 02 .6.2.2...6.2.6..
7800: 44 0D 00 09 00 09 00 09-00 09 00 09 00 09 00 09 D...............
7810: 00 09 00 09 00 09 00 09-00 09 00 09 00 09 00 09 ................
7820: 00 09 00 09 00 09 00 09-00 09 00 09 00 09 00 09 ................
7830: 00 09 00 09 00 09 00 09-00 09 00 09 00 09 00 09 ................
7840: 00 09 00 09 00 09 00 09-00 09 00 09 00 09 00 09 ................
7850: 00 09 00 09 00 09 00 09-00 09 00 09 00 09 00 09 ................
7860: 00 09 00 09 00 09 00 09-00 09 00 09 00 09 00 09 ................
7870: 00 09 00 09 00 01 00 09-00 09 00 09 00 09 00 09 ................
7880: 56 1D 56 1D 56 1D 54 1D-56 1D 56 1D 56 1D 56 1D V.V.V.T.V.V.V.V.
7890: 56 1D 56 1D 56 1D 56 1D-56 1D 56 1D 56 1D 56 1D V.V.V.V.V.V.V.V.
78A0: 56 1D 56 1D 56 1D 56 1D-56 1D 56 1D 56 1D 56 1D V.V.V.V.V.V.V.V.
78B0: 56 1D 56 1D 56 1D 56 1D-56 1D 56 1D 56 1D 56 1D V.V.V.V.V.V.V.V.
78C0: 56 1D 56 1D 56 1D 56 1D-56 1D 56 1D 56 1D 56 1D V.V.V.V.V.V.V.V.
78D0: 56 1D 56 1D 54 1D 56 1D-56 1D 56 1D 56 1D 56 1D V.V.T.V.V.V.V.V.
78E0: 56 1D 56 1D 56 1D 56 1D-56 1D 56 1D 56 1D 56 1D V.V.V.V.V.V.V.V.
78F0: 56 1D 56 1D 56 1D 56 1D-56 1D 56 1D 54 1D 56 1D V.V.V.V.V.V.T.V.
7900: 00 09 00 09 00 09 00 09-00 09 00 09 00 09 00 09 ................
7910: 00 09 00 09 00 09 00 09-00 09 00 09 00 09 00 09 ................
7920: 00 09 00 09 00 09 00 09-00 09 00 09 00 09 00 09 ................
7930: 00 09 00 09 00 09 00 09-00 09 00 09 00 09 00 09 ................
7940: 00 09 00 09 00 09 00 09-00 09 00 09 00 09 00 09 ................
7950: 00 09 00 09 00 09 00 09-00 09 00 09 00 09 00 09 ................
7960: 00 08 00 09 00 09 00 09-00 09 00 09 00 09 00 09 ................
7970: 00 09 00 09 00 09 00 09-00 09 00 09 00 09 00 09 ................
7980: 56 1D 56 1D 56 1D 54 1D-56 1D 54 1D 56 1D 56 1D V.V.V.T.V.T.V.V.
7990: 56 1D 56 1D 56 1D 56 1D-56 1D 56 1D 56 1D 56 1D V.V.V.V.V.V.V.V.
79A0: 56 1D 56 1D 56 1D 56 1D-56 1D 56 1D 56 1D 56 1D V.V.V.V.V.V.V.V.
79B0: 56 1D 54 1D 56 1D 56 1D-56 1D 56 1D 56 1D 56 1D V.T.V.V.V.V.V.V.
79C0: 56 1D 56 1D 56 1D 56 1D-56 1D 56 1D 56 1D 56 1D V.V.V.V.V.V.V.V.
79D0: 56 1D 56 1D 56 1D 56 1D-54 1D 56 1D 56 1D 56 1D V.V.V.V.T.V.V.V.
79E0: 54 1D 54 1D 54 1D 56 1D-56 1D 56 1D 56 1D 56 1D T.T.T.V.V.V.V.V.
79F0: 56 1D 56 1D 56 1D 16 0D-56 1D 56 1D 56 1D 44 0D V.V.V...V.V.V.D.
7A00: 83 14 83 10 83 10 83 10-83 10 83 10 83 10 83 10 ................
7A10: 83 10 83 10 83 10 83 10-83 10 83 10 83 10 83 10 ................
7A20: 83 10 83 10 83 10 83 10-83 10 83 10 83 10 83 10 ................
7A30: 83 10 83 10 83 10 83 10-83 10 83 10 83 10 83 10 ................
7A40: 83 10 83 10 83 10 83 10-83 10 83 10 83 10 83 10 ................
7A50: 83 10 83 10 83 10 83 10-83 10 83 10 83 10 83 10 ................
7A60: 83 10 83 10 83 10 83 10-83 10 83 10 83 10 83 10 ................
7A70: 83 10 83 10 83 10 83 10-83 10 83 10 83 10 83 10 ................
7A80: D7 54 F7 54 F7 54 F7 54-D7 54 F7 54 F7 54 F7 54 .T.T.T.T.T.T.T.T
7A90: F7 54 F7 54 F7 54 F7 54-F7 54 F7 54 F7 54 F7 54 .T.T.T.T.T.T.T.T
7AA0: F7 54 F7 54 F7 54 F7 54-F7 54 F7 54 F7 54 F7 54 .T.T.T.T.T.T.T.T
7AB0: F7 54 F7 54 F7 54 F7 54-F7 54 F7 54 F7 54 F7 54 .T.T.T.T.T.T.T.T
7AC0: F7 54 D7 54 F7 54 F7 54-D7 54 F7 54 F7 54 F7 54 .T.T.T.T.T.T.T.T
7AD0: F7 54 F7 54 F7 54 F7 54-F7 54 F7 54 F7 54 F7 54 .T.T.T.T.T.T.T.T
7AE0: F7 54 D7 54 F7 54 F7 54-F7 54 F7 54 F7 54 F7 54 .T.T.T.T.T.T.T.T
7AF0: F7 54 F7 54 F7 54 F7 54-F7 54 F7 54 F7 54 F7 54 .T.T.T.T.T.T.T.T
7B00: 83 10 83 10 83 10 83 10-83 10 83 10 83 10 83 10 ................
7B10: 83 10 83 10 83 10 83 10-83 10 83 10 83 10 83 10 ................
7B20: 83 10 83 10 83 10 83 10-83 10 83 10 83 10 83 10 ................
7B30: 83 10 83 10 83 10 83 10-83 10 83 10 83 10 83 10 ................
7B40: 83 10 83 10 83 10 83 10-83 10 83 10 83 10 83 10 ................
7B50: 83 10 83 10 83 10 83 10-83 10 83 10 83 10 83 10 ................
7B60: 00 10 83 10 83 10 83 10-83 10 83 10 83 10 83 10 ................
7B70: 83 10 83 10 83 10 83 10-83 10 83 00 83 10 83 10 ................
7B80: D7 54 F7 54 D7 54 97 54-97 54 F7 54 D7 54 F7 54 .T.T.T.T.T.T.T.T
7B90: D7 54 D7 54 D7 54 F7 54-D7 54 D7 54 F7 54 F7 54 .T.T.T.T.T.T.T.T
7BA0: D7 54 D7 54 F7 54 F7 54-D7 54 D7 54 D7 54 D7 54 .T.T.T.T.T.T.T.T
7BB0: D7 54 D7 54 F7 54 F7 54-D7 54 F7 54 F7 54 F7 54 .T.T.T.T.T.T.T.T
7BC0: F7 54 D7 54 D7 54 D7 54-D7 54 D7 54 D7 54 F7 54 .T.T.T.T.T.T.T.T
7BD0: 97 54 D7 54 D7 54 F7 54-F7 54 D7 54 F7 54 F7 54 .T.T.T.T.T.T.T.T
7BE0: D7 54 D7 54 97 54 D7 54-D7 54 F7 54 D7 54 F7 54 .T.T.T.T.T.T.T.T
7BF0: 97 54 D7 54 F7 54 D3 50-D7 54 D7 54 F7 54 83 10 .T.T.T.P.T.T.T..
7C00: 0B 16 0B 12 0B 12 0B 12-0B 16 0B 12 0B 12 0B 12 ................
7C10: 0B 12 0B 12 0B 12 0B 12-0B 12 0B 12 0B 12 0B 12 ................
7C20: 0B 12 0B 12 0B 12 0B 12-0B 12 0B 12 0B 12 0B 12 ................
7C30: 0B 12 0B 12 0B 12 0B 12-0B 12 0B 12 0B 12 0B 12 ................
7C40: 0B 12 0B 12 0B 12 0B 12-0B 12 0B 12 0B 12 0B 12 ................
7C50: 0B 12 0B 12 0B 12 0B 12-0B 12 0B 12 0B 12 0B 12 ................
7C60: 0B 12 0B 12 0B 12 0B 12-0B 12 0B 12 0B 12 0B 12 ................
7C70: 0B 12 0B 12 03 12 0B 12-0B 12 0B 12 0B 12 0B 12 ................
7C80: 9B 56 BF 56 9F 56 BF 56-BB 56 BF 56 9F 56 BB 56 .V.V.V.V.V.V.V.V
7C90: BF 56 9B 56 BF 56 BF 56-BB 56 AF 56 BF 56 BF 56 .V.V.V.V.V.V.V.V
7CA0: BB 56 BF 56 BF 56 BF 56-9B 56 BF 56 BF 56 BF 56 .V.V.V.V.V.V.V.V
7CB0: 9F 56 BF 56 BF 56 BF 56-AB 56 BF 56 BF 56 BF 56 .V.V.V.V.V.V.V.V
7CC0: BF 56 BB 56 BF 56 BF 56-BF 56 BF 56 BF 56 BF 56 .V.V.V.V.V.V.V.V
7CD0: BF 56 BF 56 BF 56 BF 56-AF 56 BF 56 BB 56 BB 56 .V.V.V.V.V.V.V.V
7CE0: BF 56 BF 56 9F 56 BF 56-BF 56 9F 56 BB 56 9F 56 .V.V.V.V.V.V.V.V
7CF0: AB 56 BF 56 BF 56 BF 56-BB 56 BF 56 BF 56 8F 56 .V.V.V.V.V.V.V.V
7D00: 0B 12 0B 12 0B 12 0B 12-0B 12 0B 12 0B 12 0B 12 ................
7D10: 0B 12 0B 12 0B 12 0B 12-0B 12 0B 12 0B 12 0B 12 ................
7D20: 0B 12 0B 12 0B 12 0B 12-0B 12 0B 12 0B 12 0B 12 ................
7D30: 0B 12 0B 12 0B 12 8B 12-0B 12 0B 12 0B 12 0B 12 ................
7D40: 0B 12 0B 12 0B 12 0B 12-0B 12 0B 12 0B 12 0B 12 ................
7D50: 0B 12 0B 12 0B 12 0B 12-0B 12 0B 12 0B 12 0B 12 ................
7D60: 08 10 0B 12 0B 12 0B 12-0B 12 0B 12 0B 12 0B 12 ................
7D70: 0B 12 0B 12 0B 12 0B 12-0B 12 0B 02 0B 12 8B 12 ................
7D80: 9B 56 8F 56 AF 56 BF 56-BF 56 8F 56 AF 56 BB 56 .V.V.V.V.V.V.V.V
7D90: BB 56 BB 56 BF 56 BF 56-BF 56 BF 56 BB 56 BF 56 .V.V.V.V.V.V.V.V
7DA0: AB 56 BB 56 BF 56 BF 56-BF 56 BF 56 BF 56 BF 56 .V.V.V.V.V.V.V.V
7DB0: BF 56 BF 56 BF 56 BF 56-BF 56 BB 56 BF 56 BF 56 .V.V.V.V.V.V.V.V
7DC0: BB 56 BF 56 AF 56 BF 56-BB 56 BF 56 BB 56 BB 56 .V.V.V.V.V.V.V.V
7DD0: BB 56 BB 56 BF 56 BB 56-9F 56 BF 56 BB 56 BF 56 .V.V.V.V.V.V.V.V
7DE0: BB 56 AB 56 AF 56 BB 56-BB 56 BB 56 BB 56 BB 56 .V.V.V.V.V.V.V.V
7DF0: BB 56 BB 56 AF 56 9F 16-BB 56 BB 56 BF 56 8B 16 .V.V.V...V.V.V..
7E00: 0E AC 02 A8 02 A8 02 A8-06 A8 02 A8 02 A8 02 A8 ................
7E10: 02 A8 02 A8 02 A8 02 A8-02 A8 02 A8 02 A8 02 A8 ................
7E20: 02 A8 02 A8 02 A8 02 A8-02 A8 02 A8 02 A8 02 A8 ................
7E30: 02 A8 02 A8 02 A8 02 A8-02 A8 02 A8 02 A8 02 A8 ................
7E40: 02 A8 02 A8 02 A8 02 A8-02 A8 02 A8 02 A8 02 A8 ................
7E50: 02 A8 02 A8 02 A8 02 A8-02 A8 02 A8 02 A8 02 A8 ................
7E60: 02 A8 02 A8 02 A8 02 A8-02 A8 02 A8 02 A8 02 A8 ................
7E70: 02 A8 02 A8 02 A0 02 A8-02 A8 02 A8 02 A8 02 A8 ................
7E80: 0E FE 0E FE 0E FE 0E FE-0E FE 0E FE 0E FE 0E FE ................
7E90: 0E FE 0E FE 0E FE 0E FE-0E FE 0E FE 0E FE 0E FE ................
7EA0: 0E FE 0E FE 0E FE 0E FE-0E FE 0E FE 0E FE 0E FE ................
7EB0: 0E FE 0E FE 0E FE 0E FE-0E FE 0E FE 0E FE 0E FE ................
7EC0: 0E FE 0E FE 0E FE 0E FE-0E FE 0E FE 0E FE 0E FE ................
7ED0: 0E FE 0E FE 0E FE 0E FE-0E FE 0E FE 0E FE 0E FE ................
7EE0: 0E FE 0E FE 0E FE 0E FE-0E FE 0E FE 0E FE 0E FE ................
7EF0: 0E FE 0E FE 0E FE 0E FE-0E FE 0E FE 0E FE 0E FE ................
7F00: 02 A8 02 A8 02 A8 02 A8-02 A8 02 A8 02 A8 02 A8 ................
7F10: 02 A8 02 A8 02 A8 02 A8-02 A8 02 A8 02 A8 02 A8 ................
7F20: 02 A8 02 A8 02 A8 02 A8-02 A8 02 A8 02 A8 02 A8 ................
7F30: 02 A8 02 A8 02 A8 02 A8-02 A8 02 A8 02 A8 02 A8 ................
7F40: 02 A8 02 A8 02 A8 02 A8-02 A8 02 A8 02 A8 02 A8 ................
7F50: 02 A8 02 A8 02 A8 02 A8-02 A8 02 A8 02 A8 02 A8 ................
7F60: 00 08 02 A8 02 A8 02 A8-02 A8 02 A8 02 A8 02 A8 ................
7F70: 02 A8 02 A8 02 A8 02 A8-02 A8 02 A8 02 A8 02 A8 ................
7F80: 0E FE 0E FE 0E FE 0E FE-0E FE 0E FE 0E FE 0E FE ................
7F90: 0E FE 0E FE 0E FE 0E FE-0E FE 0E FE 06 FE 0E FE ................
7FA0: 0E FE 0E FE 0E FE 0E FE-0E FE 0E FE 0E FE 0E FE ................
7FB0: 0E FE 0E FE 0E FE 0E FE-0E FE 0E FE 0E FE 0E FE ................
7FC0: 0E FE 06 FE 0E FE 0E FE-0E FE 0E FE 0E FE 0E FE ................
7FD0: 0E FE 0E FE 0E FE 0E FE-0E FE 0E FE 0E FE 0E FE ................
7FE0: 0E FE 0E FE 0E FE 0E FE-0E FE 0E FE 0E FE 0E FE ................
7FF0: 0E FE 0E FE 0E FE 06 FC-0E FE 0E FE 0E FE 02 AC ................