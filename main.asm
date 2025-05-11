; test.asm - contains a main loop
.cpu 6502
.equ outputData, 0x1700
.equ outputDataSettings, 0x1701
.equ outputInterrupt, 0x1702
.equ outputInterruptSettings, 0x1703 ; first pin output for new data, second pin input for new data accepted

.equ delayX, 0x40
.equ delayY, 0x41
.equ loop, 0x42

.equ status, 0x43
.equ note, 0x44
.equ volume, 0x45
.org 0x0200

main:
    LDA #0x00
    STA outputData
    STA outputInterrupt

    LDA #0xFF
    STA outputDataSettings

    LDA #0b11111101
    STA outputInterruptSettings

    LDA #0b1
    STA outputInterrupt
    LDA #0b0
    STA outputInterrupt


    LDA 0xFF
    STA delayX
    STA delayY
    JSR bpm_delay
    JSR bpm_delay
    JSR bpm_delay
    JSR bpm_delay
    JSR bpm_delay

main_loop:
    LDA #0b10011001
    STA status
    LDA #0x7F
    STA volume
    LDA #0x33
    STA note

    JSR write_note
    LDA #0xAA
    STA delayX
    STA delayY
    JSR bpm_delay
    JMP main_loop

write_value:
    LDA status,X
    STA outputData
    LDA #0b1
    STA outputInterrupt
    LDA #0b0
    STA outputInterrupt
    wait_loop: 
        CMP outputInterrupt
        BEQ wait_loop
    RTS

write_note: ; sends 3 bytes according to the offset in X register (will modify A and X register)
    LDX #0x00
    JSR write_value
    LDX #0x01
    JSR write_value
    LDX #0x02
    JSR write_value
    RTS

bpm_delay: ; loads from delayX and delayY, and then waits for that long
    LDX delayX
    delay_loop_1:
        LDY delayY
        delay_loop_2:
            DEY
            BNE delay_loop_2
        DEX
        BNE delay_loop_1
    RTS