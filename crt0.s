.export         __EXEHDR__: absolute = 1
.export         __LOADADDR__: absolute = 1
.export         __STARTUP__: absolute = 1
.export         _exit

.import         _main
.import         __MAIN_START__, __MAIN_SIZE__           ; Linker generated
.import         __STACKSIZE__                           ; … from the configure file


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
        jsr     _main
.endproc

.proc           _exit
        sei
        lda     #0
@10:    sta     border_col
        inc
        bra     @10
.endproc


.segment        "ONCE"

.proc           init
        jsr     init_irqhandler
        jsr     init_memory_map
        rts
.endproc

.proc           init_irqhandler: near
        lda     #1                                      ; Don't call BASIC in the kernel IRQ handler
        trb     init_status
.endproc

.proc           init_memory_map: near
        lda     #5                                      ; Map ROM into $C000-$CFFF
        tsb     $d030
        lda     #%101                                   ; … I/O into $D000—$DFFF
        sta     $1
        lda     #0                                      ; … bank 0 RAM into $0000 - $BFFF
        tax
        tay
        ldz     #%10000011                              ; … and kernel into $E000—$FFFF
        map
        eom
        jsr     set_environment
        rts
.endproc
