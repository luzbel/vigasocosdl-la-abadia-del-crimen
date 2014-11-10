all:
	cd LinuxSDLInputKeyboardPlugin && make
	cd LinuxSDLVideoPlugins && make
	cd VigasocoLinuxSDL && make

clean:
	cd LinuxSDLInputKeyboardPlugin && make clean
	cd LinuxSDLVideoPlugins && make clean
	cd VigasocoLinuxSDL && make clean
	
