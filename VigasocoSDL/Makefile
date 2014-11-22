CXXFLAGS=-O3 -I../core `sdl-config --cflags`
#CXXFLAGS=-g -I../core `sdl-config --cflags`
VPATH=.:../core:../core/abadia:../core/util:../core/systems

# en OBJECTS_CORE falta Operations.o ??
OBJECTS_CORE = AbadiaDriver.o FontManager.o GameDriver.o ICriticalSection.o InputPort.o IThread.o TimingHandler.o Vigasoco.o FileLoader.o GameDataEntity.o GfxData.o InputHandler.o IPalette.o NormalLoadHandler.o UncompressedLoader.o cpc6128.o DskReader.o

OBJECTS_ABADIA = Abad.o AccionesDia.o Adso.o Berengario.o Bernardo.o BuscadorRutas.o Comandos.o Controles.o EntidadJuego.o FijarOrientacion.o GeneradorPantallas.o GestorFrases.o Guillermo.o InfoJuego.o Jorge.o Juego.o Logica.o Malaquias.o Marcador.o MezcladorSprites.o Monje.o MotorGrafico.o Objeto.o Paleta.o Pergamino.o PergaminoTextos.o PersonajeConIA.o Personaje.o Puerta.o RejillaPantalla.o Severino.o Sprite.o SpriteLuz.o SpriteMonje.o TransformacionesCamara.o

OBJECTS_SDL = PluginHandler.o SDLTimer.o SDLCriticalSection.o SDLPalette.o SDLThread.o VigasocoSDL.o SDLMain.o

OBJECTS = $(OBJECTS_CORE) $(OBJECTS_ABADIA) $(OBJECTS_SDL) 

VigasocoSDL: $(OBJECTS)
	$(CXX) $(OBJECTS) `sdl-config --libs` -o VigasocoSDL

clean:
	rm -f $(OBJECTS) VigasocoSDL
