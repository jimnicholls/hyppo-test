#ifndef __HYPERVISOR_H
#define __HYPERVISOR_H

extern struct {
    unsigned char a;
    unsigned char x;
    unsigned char y;
    unsigned char z;
} hypervisor_result;

void __fastcall__ trigger_hypervisor_trap_0(unsigned char trap, unsigned char func);

#endif
