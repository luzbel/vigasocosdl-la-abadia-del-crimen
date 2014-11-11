CXXFLAGS=-O3 -fPIC -I../core -I../VigasocoLinuxSDL/ `sdl-config --cflags` 
#CXXFLAGS=-g -O3 -fPIC -I../core -I../VigasocoLinuxSDL/ `sdl-config --cflags` -pg
#CXXFLAGS=-g -O3 -fPIC -I../core -I../VigasocoLinuxSDL/ `sdl-config --cflags` 
#CXXFLAGS=-g -fPIC -I../core -I../VigasocoLinuxSDL/ `sdl-config --cflags` 
VPATH=.:../core:../core/abadia:../core/util:../core/systems:../core/pacman

OBJECTS = LinuxSDLInputKeyboardPlugin.o PluginMain.o

../VigasocoLinuxSDL/input/libVigasocoLinuxSDLInputPlugin.so: $(OBJECTS)
#	$(CXX) -g -fPIC -shared $(OBJECTS) -o $@ -pg
	$(CXX) -g -fPIC -shared $(OBJECTS) -o $@ 

clean:
	rm -f $(OBJECTS) ../VigasocoLinuxSDL/input/libVigasocoLinuxSDLInputPlugin.so
