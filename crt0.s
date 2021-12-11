.export         __EXEHDR__: absolute = 1
.export         __LOADADDR__: absolute = 1
.export         __STARTUP__: absolute = 1
.export         _exit

.import         __MAIN_START__, __MAIN_SIZE__, __STACKSIZE__
.import         _clrscr, _conioinit
.import         _main
.import         callmain, donelib, initlib, zerobss

.pushcpu
.setcpu         "65C02"                                 ; Avoid SP being a keyword
.include        "cc65/asminc/zeropage.inc"
.popcpu


; System variables
init_status     := $1104
set_environment := $038d

; VIC registers
vic_base        := $d000
border_col      := vic_base + $20


.segment        "LOADADDR"
        .addr   *+2


.segment        "EXEHDR"
        .addr   @10
        .word   1                                       ; Line number
        .byte   $FE, $02, "0"                           ; BANK 0
        .byte   ":"
        .byte   $9E                                     ; SYS Start
        .byte   <(((startup /  1000) .mod 10) + '0')
        .byte   <(((startup /   100) .mod 10) + '0')
        .byte   <(((startup /    10) .mod 10) + '0')
        .byte   <(((startup /     1) .mod 10) + '0')
        .byte   0                                       ; End of BASIC line
@10:    .word   0                                       ; BASIC end marker


.segment        "STARTUP"
.proc           startup
        sei
        jsr     init
        cli
        jsr     zerobss                                 ; Cannot call any code in the ONCE segment from this point
        jsr     callmain
.endproc                                                ; Falls through to _exit
.proc           _exit                                   ; Must immediately follow startup
        jsr     done
        lda     #0
@10:    sta     border_col
        inc
        bra     @10
.endproc


.segment        "ONCE"
.proc           init
        lda     #1                                      ; Don't call BASIC in the kernel's IRQ handler
        trb     init_status
        jsr     init_memory_map
        jsr     init_cc65
        jsr     _conioinit
       ;jsr     _clrscr
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
        lda     #5                                      ; Map ROM into $C000-$CFFF
        tsb     $d030
        lda     #%101                                   ; … I/O into $D000—$DFFF
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
.popcpu
.endproc


.segment        "INIT"
zp_save:        .res zpspace
