#CXXFLAGS=-g -O3 -fPIC -I../core -I../VigasocoLinuxSDL/ `sdl-config --cflags`
CXXFLAGS=-g -fPIC -I../core -I../VigasocoLinuxSDL/ `sdl-config --cflags`
VPATH=.:../core:../core/abadia:../core/util:../core/systems:../core/pacman

OBJECTS = LinuxSDLDrawPlugin.o LinuxSDLBasicDrawPlugin.o LinuxSDL8bpp.o LinuxSDL32bpp.o LinuxSDLWindow32bpp.o LinuxSDLFullScreen32bpp.o LinuxSDLWindow8bpp.o LinuxSDLFullScreen8bpp.o PluginMain.o 

../VigasocoLinuxSDL/video/libVigasocoLinuxSDLDrawPlugin.so: $(OBJECTS)
	$(CXX) -g -fPIC -shared $(OBJECTS) -o $@

clean:
	rm -f $(OBJECTS) ../VigasocoLinuxSDL/video/libVigasocoLinuxSDLDrawPlugin.so
