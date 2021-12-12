#ifndef __HYPERVISOR_H
#define __HYPERVISOR_H

#include <stdint.h>

extern struct {
    uint8_t a;
    uint8_t x;
    uint8_t y;
    uint8_t z;
    uint8_t c;
} hypervisor_result;

extern uint8_t hypervisor_transfer_area[256];

uint8_t __fastcall__ hypervisor_geterrorcode();
void __fastcall__ trigger_hypervisor_trap(uint8_t trap, uint8_t func);
void __fastcall__ trigger_hypervisor_trap_with_y(uint8_t trap, uint8_t func, uint8_t y_arg);

#endif
