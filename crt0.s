.export         __EXEHDR__: absolute = 1
.export         __LOADADDR__: absolute = 1
.export         __STARTUP__: absolute = 1
.export         _exit

.import         __MAIN_START__, __MAIN_SIZE__, __STACKSIZE__
.import         _main
.import         callmain, donelib, initlib, zerobss

.pushcpu
.setcpu         "65C02"                                 ; Avoid SP being a keyword
.include        "cc65/asminc/zeropage.inc"
.popcpu


; System variables
init_status     := $1104
set_environment := $038d


.segment        "LOADADDR"
        .addr   *+2


.segment        "EXEHDR"
        .addr   @10
        .word   1                                       ; Line number
        .byte   $FE, $02, "0"                           ; BANK 0
        .byte   ":"
        .byte   $9E                                     ; SYS startup
        .byte   <(((startup /  1000) .mod 10) + '0')
        .byte   <(((startup /   100) .mod 10) + '0')
        .byte   <(((startup /    10) .mod 10) + '0')
        .byte   <(((startup /     1) .mod 10) + '0')
        .byte   0                                       ; End of BASIC line
@10:    .word   0                                       ; BASIC end marker


.segment        "STARTUP"
.proc           startup
        sei
        tsx                                             ; Save the system stack ptr
        stx     sp_save
        jsr     init
        jsr     zerobss
        cli
        jsr     callmain
.endproc                                                ; Falls through to _exit
.proc           _exit                                   ; Must immediately follow startup
        sei
        jsr     done
        ldx     sp_save                                 ; Restore stack pointer
        txs
        rts
.endproc


.segment        "ONCE"
.proc           init
        lda     #1                                      ; Don't call BASIC in the kernel's IRQ handler
        trb     init_status
        jsr     init_memory_map
        jsr     init_cc65
        rts
.endproc


.segment        "ONCE"
.proc           init_cc65
.pushcpu
.setcpu         "65C02"                                 ; Avoid SP being a keyword
        ldx     #zpspace - 1                            ; Save zero-page locations
@10:    lda     sp, x
        sta     zp_save, x
        dex
        bpl     @10
        lda     #<(__MAIN_START__ + __MAIN_SIZE__)      ; Set up the stack
        ldx     #>(__MAIN_START__ + __MAIN_SIZE__)
        sta     sp
        stx     sp+1
        jsr     initlib                                 ; Clears the I flag
        rts
.popcpu
.endproc


.segment        "ONCE"
.proc           init_memory_map
        lda     $d030                                   ; Map ROM into $C000-$CFFF
        sta     d030_save
        ora     #%100000
        sta     $d030
        lda     $01                                     ; … I/O into $D000—$DFFF
        sta     mmu_save
        ora     #%00000101
        and     #%11111101
        sta     $1
        lda     #0                                      ; … bank 0 RAM into $0000 - $BFFF
        tax
        tay
        ldz     #%10000011                              ; … and kernel into $E000—$FFFF
        jsr     set_environment
        map
        eom
        rts
.endproc


.segment        "CODE"
.proc           done
.pushcpu
.setcpu         "65C02"                                 ; Avoid SP being a keyword
        jsr     donelib
        ldx     #zpspace - 1                            ; Restore zero-page locations
@10:    lda     zp_save, x
        sta     sp, x
        dex
        bpl     @10
        rts
        lda     mmu_save                                ; Restore memory configuration
        sta     $01                                     ; … but DON'T restore the memory map!
        lda     d030_save                               ; … We're still executing, and the kernel
        sta     $d030                                   ; … will take care of that
        lda     #1                                      ; Resume calling BASIC in the kernel's IRQ handler
        tsb     init_status                             ; … once the kernel clears the I flag
        rts
.popcpu
.endproc


.segment        "INIT"
d030_save:      .res 1
mmu_save:       .res 1
sp_save:        .res 1
zp_save:        .res zpspace
