#ifndef __HYPERVISOR_H
#define __HYPERVISOR_H

#include <stdint.h>

extern struct {
    uint8_t a;
    uint8_t x;
    uint8_t y;
    uint8_t z;
} hypervisor_result;

void __fastcall__ trigger_hypervisor_trap(uint8_t trap, uint8_t func);

#endif
