TARGETS = get-hypervisor-version.prg

.PHONY: all clean
.SECONDARY:
.SUFFIXES:

all: $(TARGETS)


#-------------------------------------------------------------------------------

AR = ar65
AS = ca65
ASFLAGS = --target none --cpu 4510 -W1
CC = cc65
CFLAGS = --target none --cpu 65c02
LD = ld65
LDFLAGS = --config mega65.cfg

%.prg: crt0.o %.o mega65.lib cc65-runtime.lib cc65-common.lib
	$(LD) $(LDFLAGS) -Ln $*.lbl --mapfile $*.map -o $@ $+

%.o: %.s
	$(AS) $(ASFLAGS) --listing $*.lst --list-bytes 7 -o $@ $^

%.s: %.c
	$(CC) $(CFLAGS) -o $@ $^


#-------------------------------------------------------------------------------

MEGA65_S_MODULES = fileio.s
MEGA65_C_MODULES = conio.c memory.c
MEGA65_LIBC_DIR = mega65-libc/cc65
MEGA65_INC_DIR = $(MEGA65_LIBC_DIR)/include
MEGA65_SRC_DIR = $(MEGA65_LIBC_DIR)/src
MEGA65_LIB_MEMBERS = ${addsuffix ),${addprefix mega65.lib(,$(notdir $(MEGA65_S_MODULES:.s=.o) $(MEGA65_C_MODULES:.c=.o))}}

mega65.lib: $(MEGA65_LIB_MEMBERS)
mega65.lib(%.o): CFLAGS += -I $(MEGA65_INC_DIR) -Oirs
mega65.lib(%.o): $(MEGA65_SRC_DIR)/%.o
	$(AR) r $@ $^


#-------------------------------------------------------------------------------

CC65 = cc65

CC65_RUNTIME_SRC_DIR = $(CC65)/libsrc/runtime
CC65_RUNTIME_SRC_FILES := $(wildcard $(CC65_RUNTIME_SRC_DIR)/*.s)
CC65_RUNTIME_LIB_MEMBERS := ${addsuffix ),${addprefix cc65-runtime.lib(,$(notdir $(CC65_RUNTIME_SRC_FILES:.s=.o))}}
cc65-runtime.lib: $(CC65_RUNTIME_LIB_MEMBERS)
cc65-runtime.lib(%.o): ASFLAGS = --target none --cpu 65c02
cc65-runtime.lib(%.o): $(CC65_RUNTIME_SRC_DIR)/%.o
	$(AR) r $@ $^

CC65_COMMON_SRC_DIR = $(CC65)/libsrc/common
CC65_COMMON_C_FILES := $(wildcard $(CC65_COMMON_SRC_DIR)/*.c)
CC65_COMMON_S_FILES := $(wildcard $(CC65_COMMON_SRC_DIR)/*.s)
CC65_COMMON_LIB_MEMBERS := ${addsuffix ),${addprefix cc65-common.lib(,$(notdir $(CC65_COMMON_C_FILES:.c=.o) $(CC65_COMMON_S_FILES:.s=.o))}}
cc65-common.lib: $(CC65_COMMON_LIB_MEMBERS)
cc65-common.lib(%.o): ASFLAGS = --target none --cpu 65c02
cc65-common.lib(%.o): CFLAGS += -Oirs
cc65-common.lib(%.o): $(CC65_COMMON_SRC_DIR)/%.o
	$(AR) r $@ $^


#-------------------------------------------------------------------------------

clean:
	-rm -f *.lib *.lbl *.lst *.map *.o *.prg
	-rm -f $(CC65_COMMON_C_FILES:.c=.o) $(CC65_COMMON_C_FILES:.c=.s) $(CC65_COMMON_C_FILES:.c=.lst)
	-rm -f $(CC65_COMMON_S_FILES:.s=.o) $(CC65_COMMON_S_FILES:.s=.lst)
	-rm -f $(CC65_RUNTIME_SRC_FILES:.s=.o) $(CC65_RUNTIME_SRC_FILES:.s=.lst)
	-rm -f $(addprefix $(MEGA65_SRC_DIR)/, $(MEGA65_S_MODULES:.s=.o) $(MEGA65_S_MODULES:.s=.lst))
	-rm -f $(addprefix $(MEGA65_SRC_DIR)/, $(MEGA65_C_MODULES:.c=.o) $(MEGA65_C_MODULES:.c=.s) $(MEGA65_C_MODULES:.c=.lst))
