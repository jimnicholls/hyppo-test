AS = ca65
ASFLAGS = --target none --cpu 4510 -W1
LD = ld65
LDFLAGS = --config mega65.cfg

TARGETS =

.SUFFIXES:

.PHONY: all clean
all: $(TARGETS)
clean:
	-rm -f *.lbl *.lst *.map *.o *.prg

%.prg: %.o
	$(LD) $(LDFLAGS) -Ln $*.lbl --mapfile $*.map -o $*.prg $^

%.o: %.s
	$(AS) $(ASFLAGS) --listing $*.lst --list-bytes 7 -o $*.o $^
