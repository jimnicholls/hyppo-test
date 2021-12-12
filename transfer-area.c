#include <hypervisor.h>
#include <stdio.h>
#include <stdint.h>


void report_success_failure();


void main(void) {
    printf("TEST SETTING THE HYPERVISOR TRANSFER AREA\r\r");

    printf("SETTING A VALID PAGE, SHOULD BE SUCCESSFUL\r");
    trigger_hypervisor_trap_with_y(0, 0x3a, 0x7e);
    report_success_failure();

    printf("\rSETTING AN INVALID PAGE, SHOULD FAIL WITH ERROR 16\r");
    trigger_hypervisor_trap_with_y(0, 0x3a, 0x7f);
    report_success_failure();
}


static void report_success_failure() {
    if (hypervisor_result.c) {
        printf("SUCCESSFUL\r");
    } else {
        printf("FAILED WITH ERROR %hhu\r", hypervisor_geterrorcode());
    }
}
