CXXFLAGS=-g -O3 -fPIC -I../core -I../VigasocoLinuxSDL/ `sdl-config --cflags`
VPATH=.:../core:../core/abadia:../core/util:../core/systems:../core/pacman

OBJECTS = LinuxSDLBasicDrawPlugin.o LinuxSDLWindow32bpp.o PluginMain.o

../VigasocoLinuxSDL/video/libVigasocoLinuxSDLDrawPlugin.so: $(OBJECTS)
	$(CXX) -g -fPIC -shared $(OBJECTS) -o $@

clean:
	rm -f $(OBJECTS) ../VigasocoLinuxSDL/video/libVigasocoLinuxSDLDrawPlugin.so
