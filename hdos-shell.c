#include <hypervisor.h>
#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>


#define MAX_COMMAND_LEN 3
#define MAX_INPUT_LINE 80

static char         input_line[MAX_INPUT_LINE];
static char* const  cmd = input_line;
static char* const  arg = input_line + MAX_COMMAND_LEN + 1;

static uint8_t      current_partition;


static bool     arg_to_uint8(char* c, uint8_t *v);
static void     change_to_root(void);
static void     close_all(void);
static void     close_directory(void);
static void     close_file(void);
static void     find(void);
static void     find_first(void);
static void     find_next(void);
static uint8_t  hdos_get_current_partition(void);
static uint8_t  hdos_get_default_partition(void);
static void     open_directory(void);
static void     print_dirent_in_hypervisor_transfer_area(void);
static void     read_input_line(void);
static void     read_next_dirent(void);
static void     report_success_or_failed(void);
static void     set_current_filename(void);
static void     select_partition(void);


static const char* const help_text = (
"\x05""SEL NUM        SELECT SD CARD PARTITION                                  $00:$06"
"\x9a""CWD            CHANGE WORKING DIRECTORY                                  $00:$0C"
"\x05""OPD            OPEN DIRECTORY                                            $00:$12"
"\x05""RNX FNUM       READ NEXT DIRECTORY ENTRY                                 $00:$14"
"\x05""CLD FNUM       CLOSE DIRECTORY                                           $00:$16"
"\x9a""OPF            OPEN FILE                                                 $00:$18"
"\x9a""RDF            READ FROM A FILE                                          $00:$1A"
"\x05""CLF FNUM       CLOSE A FILE                                              $00:$20"
"\x05""CLA            CLOSE ALL OPEN FILES                                      $00:$22"
"\x05""SFN NAME       SET THE CURRENT FILENAME                                  $00:$2E"
"\x05""FFI            FIND FIRST MATCHING FILE                                  $00:$30"
"\x05""FNX            FIND NEXT MATCHING FILE                                   $00:$32"
"\x05""FND            FIND MATCHING FILE (ONE ONLY)                             $00:$34"
"\x9a""LFM ADDR       LOAD A FILE INTO MAIN/CHIP MEMORY AT $00XXXXXX            $00:$36"
"\x05""CRT NUM        CHANGE TO ROOT DIRECTORY (AND SELECT SD CARD PARTITION)   $00:$3C"
"\x9a""LFA ADDR       LOAD A FILE INTO ATTIC/HYPER MEMORY AT $08XXXXXX          $00:$3E"
"\x9a""AT0            ATTACH A D81 DISK IMAGE TO DRIVE 0                        $00:$40"
"\x9a""DET            DETACH ALL D81 DISK IMAGES                                $00:$42"
"\x9a""WRE            WRITE ENABLE ALL CURRENTLY ATTACHED D81 DISK IMAGES       $00:$44"
"\x9a""AT1            ATTACH A D81 DISK IMAGE TO DRIVE 1                        $00:$46"
"\x05\r\r"
"H              HELP\r"
"X              EXIT"
);


typedef union {
    uint8_t             value;
    struct {
        unsigned int    read_only       : 1;
        unsigned int    hidden          : 1;
        unsigned int    system          : 1;
        unsigned int    vol_label       : 1;
        unsigned int    subdirectory    : 1;
        unsigned int    archive         : 1;
        unsigned int    device          : 1;
    };
} hdos_attrs;

typedef struct {
    char                lfn[64];
    uint8_t             lfn_length;
    char                sfn[13];
    uint32_t            first_cluster;
    uint32_t            size;
    hdos_attrs          attributes;
} hdos_direntry;


hdos_attrs is_vfat(hdos_attrs a) {
    a.read_only = 1;
    return a;
}


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
        } else if (strncmp("RNX", cmd, 3) == 0) {
            read_next_dirent();
        } else if (strncmp("CLD", cmd, 3) == 0) {
            close_directory();
        } else if (strncmp("CLF", cmd, 3) == 0) {
            close_file();
        } else if (strncmp("CLA", cmd, 3) == 0) {
            close_all();
        } else if (strncmp("SFN", cmd, 3) == 0) {
            set_current_filename();
        } else if (strncmp("FFI", cmd, 3) == 0) {
            find_first();
        } else if (strncmp("FNX", cmd, 3) == 0) {
            find_next();
        } else if (strncmp("FND", cmd, 3) == 0) {
            find();
        } else if (strncmp("CRT", cmd, 3) == 0) {
            change_to_root();
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


static bool arg_to_uint8(char* c, uint8_t *v) {
    int i = strlen(c) == 0 ? -1 : atoi(c);
    if (i < 0 || i > 255) {
        puts("\a\x81? ARG MUST BE BETWEEN 0 AND 255");
        return false;
    } else {
        *v = i;
        return true;
    }
}


static void change_to_root(void) {
    uint8_t part;
    if (arg_to_uint8(arg, &part)) {
        hypervisor_with_x(0x00, 0x3c, part);
        report_success_or_failed();
        current_partition = hdos_get_current_partition();
    }
}


static void close_all(void) {
    hypervisor(0x00, 0x22);
    report_success_or_failed();
}


static void close_directory(void) {
    uint8_t fnum;
    if (arg_to_uint8(arg, &fnum)) {
        hypervisor_with_x(0x00, 0x16, fnum);
        report_success_or_failed();
    }
}


static void close_file(void) {
    uint8_t fnum;
    if (arg_to_uint8(arg, &fnum)) {
        hypervisor_with_x(0x00, 0x20, fnum);
        report_success_or_failed();
    }
}


static void find(void) {
    hypervisor(0x00, 0x34);
    report_success_or_failed();
}


static void find_first(void) {
    hypervisor(0x00, 0x30);
    if (hypervisor_success()) {
        printf("OPENED DIRECTORY AS FILE NUMBER %hhu\r", hypervisor_result.a);
    }
    report_success_or_failed();
}


static void find_next(void) {
    hypervisor(0x00, 0x32);
    report_success_or_failed();
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


static void print_dirent_in_hypervisor_transfer_area(void) {
    hdos_direntry* const dirent = (hdos_direntry*) hypervisor_transfer_area;
    printf(
        "%s (%s)\rSIZE: %lld, FIRST CLUSTER: %lld, "
        "ATTRIBUTES: %c%c%c%c%c%c%c- (%hhd)\r",
        dirent->lfn, dirent->sfn, dirent->size, dirent->first_cluster,
        dirent->attributes.read_only    ? 'R' : '-',
        dirent->attributes.hidden       ? 'H' : '-',
        dirent->attributes.system       ? 'S' : '-',
        dirent->attributes.vol_label    ? 'L' : '-',
        dirent->attributes.subdirectory ? 'D' : '-',
        dirent->attributes.archive      ? 'A' : '-',
        dirent->attributes.device       ? 'V' : '-',
        dirent->attributes.value
    );
}


static void read_next_dirent(void) {
    uint8_t fnum;
    if (arg_to_uint8(arg, &fnum)) {
        hypervisor_with_xy(0x00, 0x14, fnum, hypervisor_transfer_page);
        if (hypervisor_success()) {
            print_dirent_in_hypervisor_transfer_area();
        }
        report_success_or_failed();
    }
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


static void set_current_filename(void) {
    if (strlen(arg) == 0) {
        puts("\a\x81? ARG REQUIRED");
    } else {
        strncpy(hypervisor_transfer_area, arg, 255);
        hypervisor_transfer_area[255] = '\0';
        hypervisor_with_y(0x00, 0x2e, hypervisor_transfer_page);
        report_success_or_failed();
    }
}


static void select_partition(void) {
    uint8_t part;
    if (arg_to_uint8(arg, &part)) {
        hypervisor_with_x(0x00, 0x06, part);
        report_success_or_failed();
        current_partition = hdos_get_current_partition();
    }
}
