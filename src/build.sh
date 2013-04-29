#!/bin/bash

ca65 chip.asm
ld65 -C linker_config.cfg chip.o -o chip.nes
