.export         _map_sector_buffer
.export         _unmap_sector_buffer


.p4510


.code
.proc           _map_sector_buffer
; void __fastcall__ map_sector_buffer(void)
        lda     $d030                                   ; Unmap the colour RAM at $DC00 - $DFFF if it's mapped
        sta     saved_d030
        and     #%11111110
        sta     $d030
        lda     #$81                                    ; Map the sector buffer at $DE00 - $DFFF
        sta     $d680
        rts
.endproc


.code
.proc           _unmap_sector_buffer
; void __fastcall__ unmap_sector_buffer(void)
        lda     #$82                                    ; Unmap the sector buffer at $DE00 - $DFFF
        sta     $d680
        lda     saved_d030                              ; Map the colour RAM at $DC00 if it was previously mapped
        sta     $d030
        rts
.endproc


.bss

saved_d030:     .res 1
