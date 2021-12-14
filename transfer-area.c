#include <hypervisor.h>
#include <stdio.h>
#include <stdint.h>


static void try(uint8_t page_num);


void main(void) {
    uint8_t page_num;

    printf("TEST SETTING THE HYPERVISOR TRANSFER AREA\r\r");

    page_num = ((uint16_t)hypervisor_transfer_area) >> 8;
    printf("SETTING A VALID PAGE $%02hhX, SHOULD BE SUCCESSFUL\r", page_num);
    try(page_num);

    page_num = 0x7f;
    printf("\rSETTING AN INVALID PAGE $%02hhX, SHOULD FAIL WITH ERROR 16\r", page_num);
    try(page_num);
}


static void try(uint8_t page_num) {
    hypervisor_with_y(0, 0x3a, page_num);
    if (hypervisor_result.c) {
        printf("SUCCESSFUL\r");
    } else {
        printf("FAILED WITH ERROR %hhu\r", hypervisor_geterrorcode());
    }
}
