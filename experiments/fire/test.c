#include <stdio.h>
#include <SDL2/SDL.h>

main() {

	/* Final output */
	printf("vid: %x\ncent: %x\nshown: %x\n", SDL_INIT_EVERYTHING, SDL_WINDOWPOS_CENTERED_MASK, SDL_WINDOW_SHOWN);
	printf("int: %lu\n", sizeof(int));
}