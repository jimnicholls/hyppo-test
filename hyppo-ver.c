#include <hypervisor.h>
#include <stdio.h>

void main(void) {
    hypervisor(0, 0);
    printf("MEGAOS %2hhu.%hhu\r", hypervisor_result.a, hypervisor_result.x);
    printf("HDOS   %2hhu.%hhu\r", hypervisor_result.y, hypervisor_result.z);
}
