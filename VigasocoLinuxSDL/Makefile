CXXFLAGS=-g -O3 -I../core `sdl-config --cflags`
VPATH=.:../core:../core/abadia:../core/util:../core/systems:../core/pacman

# en OBJECTS_CORE falta Operations.o ??
OBJECTS_CORE = AbadiaDriver.o FontManager.o GameDriver.o ICriticalSection.o InputPort.o IThread.o TimingHandler.o Vigasoco.o FileLoader.o GameDataEntity.o GfxData.o InputHandler.o IPalette.o NormalLoadHandler.o PacmanDriver.o UncompressedLoader.o cpc6128.o DskReader.o

OBJECTS_ABADIA = Abad.o AccionesDia.o Adso.o Berengario.o Bernardo.o BuscadorRutas.o Comandos.o Controles.o EntidadJuego.o FijarOrientacion.o GeneradorPantallas.o GestorFrases.o Guillermo.o InfoJuego.o Jorge.o Juego.o Logica.o Malaquias.o Marcador.o MezcladorSprites.o Monje.o MotorGrafico.o Objeto.o Paleta.o Pergamino.o PergaminoTextos.o PersonajeConIA.o Personaje.o Puerta.o RejillaPantalla.o Severino.o Sprite.o SpriteLuz.o SpriteMonje.o TransformacionesCamara.o

OBJECTS_PACMAN = BlueGhost.o Character.o CoinInsertedState.o CoinInsertedSubstates.o CommonCutscene.o DemoState.o DemoSubstates.o Difficulty.o FirstCutscene.o Game.o GameSettings.o Ghost.o GhostDeadSubstates.o GhostMoveAtHomeActions.o GhostMoveWhenKilledActions.o InitState.o InitSubstate.o OrangeGhost.o Pacman.o PacmanDeadSubstates.o Path.o PinkGhost.o PlayerLevelState.o PlayingState.o PlayingSubstates.o RedGhost.o ScheduledTasks.o Scheduler.o SecondCutscene.o Task.o ThirdCutscene.o Video.o Writer.o

OBJECTS_SDL = PluginHandler.o RDTSCTimer.o LinuxSDLCriticalSection.o LinuxSDLPalette.o LinuxSDLThread.o VigasocoLinuxSDL.o LinuxSDLMain.o

OBJECTS = $(OBJECTS_CORE) $(OBJECTS_ABADIA) $(OBJECTS_PACMAN) $(OBJECTS_SDL) 

VigasocoLinuxSDL: $(OBJECTS)
	$(CXX) -g $(OBJECTS) `sdl-config --libs` -o VigasocoLinuxSDL

clean:
	rm -f $(OBJECTS) VigasocoLinuxSDL
