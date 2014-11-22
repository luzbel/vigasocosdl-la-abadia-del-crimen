CXXFLAGS=-O3 -fPIC -I../core -I../VigasocoLinuxSDL/ `sdl-config --cflags`
VPATH=.:../core:../core/abadia:../core/util:../core/systems:../core/pacman

OBJECTS = SDLInputKeyboardPlugin.o PluginMain.o

../VigasocoSDL/input/libVigasocoSDLInputPlugin.so: $(OBJECTS)
	$(CXX) -fPIC -shared $(OBJECTS) -o $@

clean:
	rm -f $(OBJECTS) ../VigasocoSDL/input/libVigasocoSDLInputPlugin.so
