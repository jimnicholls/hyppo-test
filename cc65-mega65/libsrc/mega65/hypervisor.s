.export         _hypervisor_geterrorcode
.export         _hypervisor_result
.export         _trigger_hypervisor_trap
.export         _trigger_hypervisor_trap_with_y

.import         incsp1, incsp2
.importzp       sp



trap_reg_base   := $d640



.macro          ldaspz
.pushcpu
.pc02
        lda     (sp)                                    ; Actually (sp), z
.popcpu
.endmacro



.code
.proc           _hypervisor_geterrorcode
; uint8_t __fastcall__ hypervisor_geterrorcode();
.pushcpu
.p4510
        lda     _hypervisor_result+4                    ; If the c flag was set by the last trap it was successful
        beq     @10                                     ; … so force the error code to be zero
        lda     #0
        bra     @20
@10:    lda     #$38                                    ; Trigger hypervisor service $00:$38 (Get Current Error Code)
        sta     trap_reg_base
        nop                                             ; Mandiatory nop
@20:    ldx     #0                                      ; Force x to zero because __fastcall__ has x:a as the return value
        rts                                             ; Error code returned in a
.popcpu
.endproc



.code
.proc           _trigger_hypervisor_trap
; void __fastcall__ trigger_hypervisor_trap(uint8_t trap, uint8_t func)
.pushcpu
.p4510
        tay                                             ; Save func into y
        ldz     #0                                      ; Load trap into x
        ldaspz
        tax
        sty     trap_reg_base, x                        ; Write func into trap register x
        nop                                             ; Mandiatory nop
        jsr     store_hypervisor_result
        jsr     incsp1                                  ; Clean up the stack
        rts
.popcpu
.endproc



.code
.proc           _trigger_hypervisor_trap_with_y
; void __fastcall__ trigger_hypervisor_trap_with_y(uint8_t trap, uint8_t func, uint8_t y_arg)
.pushcpu
.p4510
        tay                                             ; Move y_arg into y
        ldz     #1                                      ; Load trap into x
        ldaspz
        tax
        dez                                             ; Load func into a
        ldaspz
        sta     trap_reg_base, x                        ; Write func into trap register x
        nop                                             ; Mandiatory nop
        jsr     store_hypervisor_result
        jsr     incsp2                                  ; Clean up the stack
        rts
.popcpu
.endproc



.code
.proc           store_hypervisor_result
.pushcpu
.p4510
        sta     _hypervisor_result                      ; Save a into _hypervisor_result.a
        stx     _hypervisor_result+1                    ; Save x into _hypervisor_result.x
        sty     _hypervisor_result+2                    ; Save y into _hypervisor_result.y
        stz     _hypervisor_result+3                    ; Save z into _hypervisor_result.z
        php                                             ; Save the c flag into _hypervisor_result.c
        pla
        and     #1
        sta     _hypervisor_result+4
        rts
.popcpu
.endproc



.bss
_hypervisor_result: .res 4                              ; a, x, y, z
