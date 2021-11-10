; Basic sequence for during current steps, and laser pulses.
; NOTE: this assumes that DAC 0 is connected to the command input on an Axon 700B
; NOTE 1: the command gains for voltage clamp has two ranges and are independent of feedback resistor setting,
;             voltage command input has two gain ranges 20mV/V or 100 mV/V,
; NOTE 2: the command gains for current clamp has two ranges and DEPEND on feedback resistor setting,
;         50 MegaOhm:
;             current command input has two gain ranges 4nA/V or 20 nA/V. 
;         500 MegaOhm:
;             current command input has two gain ranges 400pA/V or 2 nA/V.

; For the voltage clamp command:
; this file assumes 20 mV/V.
; this means 1V output at the DAC gives 20mV change in the command potential at amp.
; to get 1mV change at the amp, is 50 mV at the DAC, have to do some scaleing

; For the current clamp command:
; this file assumes 400 pA/V (500 MOhm Feedback).
; this means 1V output at the DAC gives 400 pA current drive at amp.
; to get 1pA change at the amp, is 2.5 mV at the DAC
; the variables here are changed in a script, and must be paired manually, by number, not alias.

            SET 0.1,1000,0        ;Run at 10 kHz, DAC is scaled to millivolts, this means all ticks are 100 microseconds, resolution is 10 microseconds.
            ;gen var for DAC
            VAR V20,DACOUT=0
            VAR V21,DACUPV=429496729
            ;variable for pA stepping (current clamp)
            VAR V1,pAStart=-40
            VAR V2,pATemp=-40
            VAR V3,pAStep=20
            VAR V4,ccStepN=0
            VAR V5,DACUPpA=1073741
            VAR V6,ccDur=s(1)
            VAR V7,ccISI=s(3)
            ;variables for mV stepping (voltage clamp)
            VAR V8,mVStart=-40
            VAR V9,mVTemp=-40
            VAR V10,mVStep=20
            VAR V11,vcStepN=0
            VAR V12,DACUpmV=21474836
            VAR V13,vcDur=s(1)
            VAR V14,vcISI=s(3)
            ;variable to count number of steps (both cc and vc)
            VAR V22,CCNSteps=10
            VAR V23,VCNSteps=10
            ;variables for laser stepping (voltage clamp)
            VAR V15,LStart=-40
            VAR V16,LStep=20
            VAR V17,LSteps=100
            VAR V18,LDur=s(1)
            VAR V19,LISI=s(3)

SETUP:  'i  DAC    0,0             ;ZERO DACs
            DAC    1,0
                                   ;CURRENT STEPPING
BTWN:       DAC    0,0             ;ZERO DACs
            DAC    1,0
            HALT

; Current Clamp stepper
pASq:  'n   MOV    pATemp,pAStart
            MOV    ccStepN,CCNSteps
pALoop:     CALL   pAS              ;Pulse DAC
            ADD    pATemp,pAStep    ;Increment command voltage
            DBNZ   ccStepN,pALoop   ;Check if we are don with loops
            JUMP   BTWN

pAS:        MOV    DACOUT,pATemp
            MUL    DACOUT,DACUPpA   ;set DAC value, multiple copies result to first operand, have to reset
            MARK   pATemp
            DAC    0,DACOUT
            DELAY  ccDur            ;wait for time set
            DAC    0,0              ;set DAC back to zero
            MARK   0
            DELAY  ccISI            ;Start a series of Current Clamp Steps
            RETURN                  ;back to the caller

; Voltage Clamp stepper
mVSq:   'm  MOV    mVTemp,mVStart
            MOV    vcStepN,VCNSteps
mVLoop:     CALL   mVS              ;Pulse DAC
            ADD    mVTemp,mVStep    ;Increment command voltage
            DBNZ   vcStepN,mVLoop   ;Check if we are don with loops
            JUMP   BTWN

mVS:        MOV    DACOUT,mVTemp
            MUL    DACOUT,DACUPmV   ;set DAC value, multiple copies result to first operand, have to reset
            MARK   mVTemp
            DAC    0,DACOUT
            DELAY  vcDur            ;wait for time set
            DAC    0,0              ;set DAC back to zero
            MARK   0
            DELAY  vcISI            ;Start a series of Current Clamp Steps
            RETURN                 ;back to the caller
