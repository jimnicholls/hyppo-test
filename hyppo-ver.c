#include <hypervisor.h>
#include <stdio.h>

void main(void) {
    trigger_hypervisor_trap(0, 0);
    printf("MEGAOS %2hhu.%hhu\r", hypervisor_result.a, hypervisor_result.x);
    printf("DOS    %2hhu.%hhu\r", hypervisor_result.y, hypervisor_result.z);
}
