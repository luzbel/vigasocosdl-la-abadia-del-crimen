#CXXFLAGS=-g -O3 -fPIC -I../core -I../VigasocoLinuxSDL/ `sdl-config --cflags`
CXXFLAGS=-g -fPIC -I../core -I../VigasocoLinuxSDL/ `sdl-config --cflags`
VPATH=.:../core:../core/abadia:../core/util:../core/systems:../core/pacman

#OBJECTS = LinuxSDLDrawPlugin.o LinuxSDLBasicDrawPlugin.o LinuxSDL8bpp.o LinuxSDL16bpp.o LinuxSDL24bpp.o LinuxSDL32bpp.o LinuxSDLGris8bpp.o \
#LinuxSDLWindow32bpp.o LinuxSDLFullScreen32bpp.o \
#LinuxSDLWindow24bpp.o LinuxSDLFullScreen24bpp.o \
#LinuxSDLWindow16bpp.o LinuxSDLFullScreen16bpp.o \
#LinuxSDLWindow8bpp.o LinuxSDLFullScreen8bpp.o \
#LinuxSDLWindowGris8bpp.o \
#PluginMain.o 

OBJECTS = SDLDrawPlugin.o SDLVideoPlugins.o SDLDrawPlugin8bpp.o SDLDrawPlugin24bpp.o SDLDrawPluginPaletaGrises8bpp.o PluginMain.o

../VigasocoLinuxSDL/video/libVigasocoLinuxSDLDrawPlugin.so: $(OBJECTS)
	$(CXX) -g -fPIC -shared $(OBJECTS) -o $@

# para comprobar que no le faltan dependencias por resolver a la libreria
test: test.o
	$(CXX) -g test.o -o test -L ../VigasocoLinuxSDL/video/ -l VigasocoLinuxSDLDrawPlugin `sdl-config --libs`

clean:
	rm -f $(OBJECTS) ../VigasocoLinuxSDL/video/libVigasocoLinuxSDLDrawPlugin.so test
