TARGETS =	drive.prg \
			hyppo-ver.prg \
			transfer-area.prg

.PHONY: all clean
.SECONDARY:
.SUFFIXES:

all: $(TARGETS)


#-------------------------------------------------------------------------------

AR = ar65
AS = ca65
ASFLAGS = --target none --cpu 4510 -W1
CC = cc65
CFLAGS = --target none --cpu 6502 -I $(MEGA65_INC_DIR) -I $(CC65_MEGA65_INC_DIR) -Oirs
LD = ld65
LDFLAGS = --config mega65.cfg

%.prg: %.o crt0.o mega65.lib cc65-common.lib cc65-cbm.lib cc65-mega65.lib cc65-common.lib cc65-cbm.lib cc65-runtime.lib
	$(LD) $(LDFLAGS) -Ln $*.lbl --mapfile $*.map -o $@ $+

%.o: %.s
	$(AS) $(ASFLAGS) --listing $*.lst --list-bytes 7 -o $@ $^

%.s: %.c
	$(CC) $(CFLAGS) -o $@ $^


#-------------------------------------------------------------------------------

MEGA65_C_MODULES = conio.c memory.c
MEGA65_S_MODULES = fileio.s
MEGA65_LIBC_DIR = mega65-libc/cc65
MEGA65_INC_DIR = $(MEGA65_LIBC_DIR)/include
MEGA65_SRC_DIR = $(MEGA65_LIBC_DIR)/src
MEGA65_LIB_MEMBERS = ${addsuffix ),${addprefix mega65.lib(,$(notdir $(MEGA65_S_MODULES:.s=.o) $(MEGA65_C_MODULES:.c=.o))}}

mega65.lib: $(MEGA65_LIB_MEMBERS)
mega65.lib(%.o): $(MEGA65_SRC_DIR)/%.o
	$(AR) r $@ $^


#-------------------------------------------------------------------------------

CC65_DIR = cc65

CC65_CBM_C_FILES :=
CC65_CBM_S_FILES := filedes.s oserrlist.s oserror.s read.s rwcommon.s write.s
CC65_CBM_SRC_DIR = $(CC65_DIR)/libsrc/cbm
CC65_CBM_C_FILES := $(addprefix $(CC65_CBM_SRC_DIR)/, $(CC65_CBM_C_FILES))
CC65_CBM_S_FILES := $(addprefix $(CC65_CBM_SRC_DIR)/, $(CC65_CBM_S_FILES))
CC65_CBM_LIB_MEMBERS := ${addsuffix ),${addprefix cc65-cbm.lib(,$(notdir $(CC65_CBM_C_FILES:.c=.o) $(CC65_CBM_S_FILES:.s=.o))}}
cc65-cbm.lib: $(CC65_CBM_LIB_MEMBERS)
cc65-cbm.lib(%.o): ASFLAGS = --target none
cc65-cbm.lib(%.o): CFLAGS = --target none -D__CBM__ -DCURS_X=236 -DSCREEN_PTR=
cc65-cbm.lib(%.o): $(CC65_CBM_SRC_DIR)/%.o
	$(AR) r $@ $^

CC65_COMMON_SRC_DIR = $(CC65_DIR)/libsrc/common
CC65_COMMON_C_FILES := $(wildcard $(CC65_COMMON_SRC_DIR)/*.c)
CC65_COMMON_S_FILES := $(wildcard $(CC65_COMMON_SRC_DIR)/*.s)
CC65_COMMON_LIB_MEMBERS := ${addsuffix ),${addprefix cc65-common.lib(,$(notdir $(CC65_COMMON_C_FILES:.c=.o) $(CC65_COMMON_S_FILES:.s=.o))}}
cc65-common.lib: $(CC65_COMMON_LIB_MEMBERS)
cc65-common.lib(%.o): ASFLAGS = --target none
cc65-common.lib(%.o): CFLAGS = --target none
cc65-common.lib(%.o): $(CC65_COMMON_SRC_DIR)/%.o
	$(AR) r $@ $^

CC65_MEGA65_DIR = cc65-mega65
CC65_MEGA65_INC_DIR = $(CC65_MEGA65_DIR)/include
CC65_MEGA65_SRC_DIR = $(CC65_MEGA65_DIR)/libsrc/mega65
CC65_MEGA65_C_FILES := $(wildcard $(CC65_MEGA65_SRC_DIR)/*.c)
CC65_MEGA65_S_FILES := $(wildcard $(CC65_MEGA65_SRC_DIR)/*.s)
CC65_MEGA65_LIB_MEMBERS := ${addsuffix ),${addprefix cc65-mega65.lib(,$(notdir $(CC65_MEGA65_C_FILES:.c=.o) $(CC65_MEGA65_S_FILES:.s=.o))}}
cc65-mega65.lib: $(CC65_MEGA65_LIB_MEMBERS)
cc65-mega65.lib(%.o): ASFLAGS = --target none
cc65-mega65.lib(%.o): CFLAGS = --target none
cc65-mega65.lib(%.o): $(CC65_MEGA65_SRC_DIR)/%.o
	$(AR) r $@ $^

CC65_RUNTIME_SRC_DIR = $(CC65_DIR)/libsrc/runtime
CC65_RUNTIME_SRC_FILES := $(wildcard $(CC65_RUNTIME_SRC_DIR)/*.s)
CC65_RUNTIME_LIB_MEMBERS := ${addsuffix ),${addprefix cc65-runtime.lib(,$(notdir $(CC65_RUNTIME_SRC_FILES:.s=.o))}}
cc65-runtime.lib: $(CC65_RUNTIME_LIB_MEMBERS)
cc65-runtime.lib(%.o): ASFLAGS = --target none
cc65-runtime.lib(%.o): $(CC65_RUNTIME_SRC_DIR)/%.o
	$(AR) r $@ $^


#-------------------------------------------------------------------------------

clean:
	-rm -f *.lib *.lbl *.lst *.map *.o *.prg
	-rm -f $(TARGETS:.prg=.s)
	-rm -f $(CC65_CBM_C_FILES:.c=.o) $(CC65_CBM_C_FILES:.c=.s) $(CC65_CBM_C_FILES:.c=.lst)
	-rm -f $(CC65_CBM_S_FILES:.s=.o) $(CC65_CBM_S_FILES:.s=.lst)
	-rm -f $(CC65_COMMON_C_FILES:.c=.o) $(CC65_COMMON_C_FILES:.c=.s) $(CC65_COMMON_C_FILES:.c=.lst)
	-rm -f $(CC65_COMMON_S_FILES:.s=.o) $(CC65_COMMON_S_FILES:.s=.lst)
	-rm -f $(CC65_MEGA65_C_FILES:.c=.o) $(CC65_MEGA65_C_FILES:.c=.s) $(CC65_MEGA65_C_FILES:.c=.lst)
	-rm -f $(CC65_MEGA65_S_FILES:.s=.o) $(CC65_MEGA65_S_FILES:.s=.lst)
	-rm -f $(CC65_RUNTIME_SRC_FILES:.s=.o) $(CC65_RUNTIME_SRC_FILES:.s=.lst)
	-rm -f $(addprefix $(MEGA65_SRC_DIR)/, $(MEGA65_S_MODULES:.s=.o) $(MEGA65_S_MODULES:.s=.lst))
	-rm -f $(addprefix $(MEGA65_SRC_DIR)/, $(MEGA65_C_MODULES:.c=.o) $(MEGA65_C_MODULES:.c=.s) $(MEGA65_C_MODULES:.c=.lst))
