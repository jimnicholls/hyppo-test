.export         _hypervisor_geterrorcode
.export         _hypervisor_result
.export         _hypervisor_transfer_area
.export         __hypervisor_trap
.export         __hypervisor_a
.export         __hypervisor_x
.export         __hypervisor_y
.export         __hypervisor_z
.export         __enter_hypervisor
.export         __enter_hypervisor_x
.export         __enter_hypervisor_xy
.export         __enter_hypervisor_xyz

.import         incsp1, incsp2
.importzp       sp


.p4510



.code
.proc           _hypervisor_geterrorcode
; uint8_t __fastcall__ hypervisor_geterrorcode();
        lda     _hypervisor_result+4                    ; If the c flag was set by the last trap it was successful
        beq     @10                                     ; … so force the error code to be zero
        lda     #0
        bra     @20
@10:    lda     #$38                                    ; Trigger hypervisor service $00:$38 (Get Current Error Code)
        sta     $d640
        nop                                             ; Mandiatory nop
@20:    ldx     #0                                      ; Force x to zero because __fastcall__ has x:a as the return value
        rts                                             ; Error code returned in a
.endproc



;
; !!! SELF-MODIFYING CODE
;
; The C macros in hypervisor.h will change this code.
;

__enter_hypervisor_xyz:
        ldz     #0
__hypervisor_z  := * - 1

__enter_hypervisor_xy:
        ldy     #0
__hypervisor_y  := * - 1

__enter_hypervisor_x:
        ldx     #0
__hypervisor_x  := * - 1

__enter_hypervisor:
        lda     #0
__hypervisor_a  := * - 1

        sta     $d600
__hypervisor_trap := * - 2

        nop
        sta     _hypervisor_result                      ; Save a into _hypervisor_result.a
        stx     _hypervisor_result+1                    ; Save x into _hypervisor_result.x
        sty     _hypervisor_result+2                    ; Save y into _hypervisor_result.y
        stz     _hypervisor_result+3                    ; Save z into _hypervisor_result.z
        php                                             ; Save the c flag into _hypervisor_result.c
        pla
        and     #1
        sta     _hypervisor_result+4
        rts



.bss
_hypervisor_result: .res 5                              ; a, x, y, z, c



.segment        "TRANSAREA"
.align $100
_hypervisor_transfer_area: .res $100
