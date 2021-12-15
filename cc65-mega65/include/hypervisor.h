#ifndef __HYPERVISOR_H
#define __HYPERVISOR_H

#include <stdbool.h>
#include <stdint.h>


extern uint8_t _hypervisor_trap;
extern uint8_t _hypervisor_a;
extern uint8_t _hypervisor_x;
extern uint8_t _hypervisor_y;
extern uint8_t _hypervisor_z;

extern struct {
    uint8_t a;
    uint8_t x;
    uint8_t y;
    uint8_t z;
    uint8_t c;
} hypervisor_result;

extern uint8_t hypervisor_transfer_area[256];

uint8_t __fastcall__ hypervisor_geterrorcode(void);
void __fastcall__ _enter_hypervisor();
void __fastcall__ _enter_hypervisor_x();
void __fastcall__ _enter_hypervisor_xy();
void __fastcall__ _enter_hypervisor_xyz();

#define hypervisor(func, sub_func) do { \
    _hypervisor_a = sub_func; \
    _hypervisor_trap = 0x40 + func; \
    _enter_hypervisor(); \
} while (0);

#define hypervisor_with_x(func, sub_func, x_arg) do { \
    _hypervisor_x = x_arg; \
    _hypervisor_a = sub_func; \
    _hypervisor_trap = 0x40 + func; \
    _enter_hypervisor_x(); \
} while (0);

#define hypervisor_with_y(func, sub_func, y_arg) do { \
    _hypervisor_y = y_arg; \
    _hypervisor_a = sub_func; \
    _hypervisor_trap = 0x40 + func; \
    _enter_hypervisor_xy(); \
} while (0);

#define hypervisor_with_xy(func, sub_func, x_arg, y_arg) do { \
    _hypervisor_y = y_arg; \
    _hypervisor_x = x_arg; \
    _hypervisor_a = sub_func; \
    _hypervisor_trap = 0x40 + func; \
    _enter_hypervisor_xy(); \
} while (0);

#define hypervisor_with_xyz(func, sub_func, x_arg, y_arg, z_arg) do { \
    _hypervisor_z = z_arg; \
    _hypervisor_y = y_arg; \
    _hypervisor_x = x_arg; \
    _hypervisor_a = sub_func; \
    _hypervisor_trap = 0x40 + func; \
    _enter_hypervisor_xyz(); \
} while (0);


#define hypervisor_success() hypervisor_result.c

#endif
