#ifndef __45IO27_H
#define __45IO27_H

#include <stdint.h>

#define sector_buffer ((uint8_t*)0xde00)

void __fastcall__ map_sector_buffer(void);
void __fastcall__ unmap_sector_buffer(void);

#endif
