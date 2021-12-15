#include <hypervisor.h>
#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>


#define MAX_INPUT_LINE 80
#define MAX_COMMAND_LEN 3
static char         input_line[MAX_INPUT_LINE];
static char* const  cmd = input_line;
static char* const  arg = input_line + MAX_COMMAND_LEN + 1;

static uint8_t      current_partition;


static void     close_all(void);
static void     close_directory(void);
static void     close_file(void);
static uint8_t  hdos_get_current_partition(void);
static uint8_t  hdos_get_default_partition(void);
static void     open_directory(void);
static void     read_input_line(void);
static void     report_success_or_failed(void);
static void     select_partition(void);


static const char* const help_text = (
"SEL NUM        SELECT SD CARD PARTITION                                  $00:$06"
"CWD            CHANGE WORKING DIRECTORY                                  $00:$0C"
"OPD            OPEN DIRECTORY                                            $00:$12"
"RNX            READ NEXT DIRECTORY ENTRY                                 $00:$14"
"CLD FNUM       CLOSE DIRECTORY                                           $00:$16"
"OPF            OPEN FILE                                                 $00:$18"
"RDF            READ FROM A FILE                                          $00:$1A"
"CLF FNUM       CLOSE A FILE                                              $00:$20"
"CLA            CLOSE ALL OPEN FILES                                      $00:$22"
"SFN NAME       SET THE CURRENT FILENAME                                  $00:$2E"
"FFI            FIND FIRST MATCHING FILE                                  $00:$30"
"FNX            FIND NEXT MATCHING FILE                                   $00:$32"
"FIN            FIND MATCHING FILE (ONE ONLY)                             $00:$34"
"LFM ADDR       LOAD A FILE INTO MAIN/CHIP MEMORY AT $00XXXXXX            $00:$36"
"CRT            CHANGE TO ROOT DIRECTORY                                  $00:$3C"
"LFA ADDR       LOAD A FILE INTO ATTIC/HYPER MEMORY AT $08XXXXXX          $00:$3E"
"AT0            ATTACH A D81 DISK IMAGE TO DRIVE 0                        $00:$40"
"DET            DETACH ALL D81 DISK IMAGES                                $00:$42"
"WRE            WRITE ENABLE ALL CURRENTLY ATTACHED D81 DISK IMAGES       $00:$44"
"AT1            ATTACH A D81 DISK IMAGE TO DRIVE 1                        $00:$46"
"\r\r"
"H              HELP\r"
"X              EXIT"
);


void main(void) {
    printf("\x93\x02\x9a      DISK/STORAGE HYPERVISOR CALLS          H FOR HELP          X TO EXIT      \r\r");
    printf("      DEFAULT PARTITION: %hhu\r", hdos_get_default_partition());
    current_partition = hdos_get_current_partition();
    for (;;) {
        memset(input_line, 0, MAX_INPUT_LINE - 1);
        printf("\r\x05%hhu> ", current_partition);
        read_input_line();
        putchar('\x9a');
        putchar('\r');
        if (strncmp("X", cmd, 1) == 0) {
            break;
        } else if (strncmp("H", cmd, 1) == 0) {
            puts(help_text);
        } else if (strncmp("SEL", cmd, 3) == 0) {
            select_partition();
        } else if (strncmp("OPD", cmd, 3) == 0) {
            open_directory();
        } else if (strncmp("CLD", cmd, 3) == 0) {
            close_directory();
        } else if (strncmp("CLF", cmd, 3) == 0) {
            close_file();
        } else if (strncmp("CLA", cmd, 3) == 0) {
            close_all();
        } else {
            puts("\a\x81? DID NOT RECOGNISE COMMAND                  H FOR HELP          X TO EXIT");
        }
    }
    putchar('\x05');
}


static void read_input_line(void)
{
    char* p = input_line;
    char c;
    uint8_t i;
    for (;;) {
        c = (char)fgetc(stdin);
        if (c >= 'A' && c <= 'Z') {
            break;
        }
    }
    for(i = 0; i < MAX_INPUT_LINE; ++i) {
        if (c == '\r') {
            *p = '\0';
            return;
        } else {
            *p = c;
            ++p;
        }
        c = (char)fgetc(stdin);
    }
    input_line[MAX_INPUT_LINE - 1] = '\0';
}


static void close_all(void) {
    hypervisor(0x00, 0x22);
    report_success_or_failed();
}


static void close_directory(void) {
    int part = atoi(arg);
    if (part < 0 || part > 255) {
        puts("\a\x81? FILE NUMBER MUST BE BETWEEN 0 AND 255");
    } else {
        hypervisor_with_x(0x00, 0x16, part);
        report_success_or_failed();
    }
}


static void close_file(void) {
    int part = atoi(arg);
    if (part < 0 || part > 255) {
        puts("\a\x81? FILE NUMBER MUST BE BETWEEN 0 AND 255");
    } else {
        hypervisor_with_x(0x00, 0x20, part);
        report_success_or_failed();
    }
}


static uint8_t hdos_get_current_partition(void) {
    hypervisor(0x00, 0x04);
    return hypervisor_result.a;
}


static uint8_t hdos_get_default_partition(void) {
    hypervisor(0x00, 0x02);
    return hypervisor_result.a;
}


static void open_directory(void) {
    hypervisor(0x00, 0x12);
    if (hypervisor_success()) {
        printf("OPENED DIRECTORY AS FILE NUMBER %hhu\r", hypervisor_result.a);
    }
    report_success_or_failed();
}


static void report_success_or_failed(void) {
    if (hypervisor_success()) {
        printf(
            "OK          A = %03hhu, X = %03hhu, Y = %03hhu, Z = %03hhu\r",
            hypervisor_result.a, hypervisor_result.x, hypervisor_result.y, hypervisor_result.z
        );
    } else {
        printf("\a\x1C! FAILED WITH ERROR %hhu\r", hypervisor_geterrorcode());
    }
}


static void select_partition(void) {
    int part = atoi(arg);
    if (part < 0 || part > 255) {
        puts("\a\x81? NUMBER MUST BE BETWEEN 0 AND 255");
    } else {
        hypervisor_with_x(0x00, 0x06, part);
        report_success_or_failed();
        current_partition = hdos_get_current_partition();
    }
}
