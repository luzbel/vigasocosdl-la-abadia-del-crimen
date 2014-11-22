CXXFLAGS=-O3 -fPIC -I../core -I../VigasocoLinuxSDL/ `sdl-config --cflags`
#CXXFLAGS=-g -fPIC -I../core -I../VigasocoLinuxSDL/ `sdl-config --cflags`
VPATH=.:../core:../core/abadia:../core/util:../core/systems:../core/pacman

OBJECTS = SDLDrawPlugin.o SDLVideoPlugins.o SDLDrawPlugin8bpp.o SDLDrawPlugin24bpp.o SDLDrawPluginPaletaGrises8bpp.o PluginMain.o

../VigasocoSDL/video/libVigasocoSDLDrawPlugin.so: $(OBJECTS)
	$(CXX) -g -fPIC -shared $(OBJECTS) -o $@

# para comprobar que no le faltan dependencias por resolver a la libreria
test: test.o
	$(CXX) -g test.o -o test -L ../VigasocoSDL/video/ -l VigasocoSDLDrawPlugin `sdl-config --libs`

clean:
	rm -f $(OBJECTS) ../VigasocoLinuxSDL/video/libVigasocoLinuxSDLDrawPlugin.so test
