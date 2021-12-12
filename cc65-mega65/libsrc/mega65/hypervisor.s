.export         _hypervisor_result
.export         _trigger_hypervisor_trap

.import         decsp1
.importzp       sp


trap_reg_base   := $d640


.code
.proc           _trigger_hypervisor_trap
; void __fastcall__ trigger_hypervisor_trap(unsigned char trap, unsigned char func)
.pushcpu
.p4510
        tay                                             ; Save func into y
        ldz     #0                                      ; Load trap into x
.pushcpu
.pc02
        lda     (sp)                                    ; Reg z must be 0
.popcpu
        tax
        sty     trap_reg_base, x                        ; Write func into trap register
        nop                                             ; Mandiatory nop
        sta     _hypervisor_result                      ; Save the regs into _hypervisor_result
        stx     _hypervisor_result+1
        sty     _hypervisor_result+2
        stz     _hypervisor_result+3
        jsr     decsp1                                  ; Clean up the stack
        rts
.popcpu
.endproc


.bss
_hypervisor_result: .res 4                              ; a, x, y, z
