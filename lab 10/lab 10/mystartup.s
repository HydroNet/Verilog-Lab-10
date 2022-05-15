; mystartup
;Standard definitions of Mode bits and Interrupt (I & F) flags in PSR s
SUP_MODE		EQU	0X13
IRQ_MODE		EQU	0X12
FIQ_MODE		EQU	0X11
USER_MODE		EQU	0X10
I_BIT 			EQU 0x80 ; when I bit is set, IRQ is disabled
F_BIT 			EQU 0x40 ; when F bit is set, FIQ is disabled
	
;Defintions of User Mode Stack and Size
USR_STACK_SIZE	EQU 0x100
SRAM 			EQU 0X40000000
SUP_STACK_SIZE	EQU 0X200
IRQ_STACK_SIZE	EQU 0X300
FIQ_STACK_SIZE	EQU 0X400
STACK_TOP 		EQU SRAM+USR_STACK_SIZE
SUP_TOP			EQU SRAM+SUP_STACK_SIZE
IRQ_TOP			EQU SRAM+IRQ_STACK_SIZE
FIQ_TOP			EQU SRAM+FIQ_STACK_SIZE

	
  AREA    RESET, CODE, READONLY
    ENTRY
	ARM
	;IMPORT USER_CODE
	IMPORT SWI_HANDLER
	;IMPORT IRQ_HANDLER
	;IMPORT FIQ_HANDLER
    
VECTORS

    LDR        PC,Reset_Addr
    LDR        PC,Undef_Addr
    LDR        PC,SWI_Addr
    LDR        PC,PAbt_Addr
    LDR        PC,DAbt_Addr
    NOP
    LDR        PC,IRQ_Addr
    LDR        PC,FIQ_Addr
    
Reset_Addr      DCD        Reset_Handler
Undef_Addr      DCD        UndefHandler
SWI_Addr        DCD        SWI_HANDLER
PAbt_Addr       DCD        PAbtHandler
DAbt_Addr       DCD        DAbtHandler
                DCD        0
                    
IRQ_Addr        DCD        IRQHandler
FIQ_Addr        DCD        FIQHandler
    
;SWIHandler      B        SWIHandler
PAbtHandler     B        PAbtHandler
DAbtHandler     B        DAbtHandler
IRQHandler      B        IRQHandler
FIQHandler      B        FIQHandler
UndefHandler    B        UndefHandler

MAMCR	EQU 0xE01FC000
MAMTIM	EQU 0xE01FC004
Reset_Handler
PINSEL1 	EQU 0XE002C004
EINT0 		EQU 0X1
EINT3 		EQU 0X300
EXTMODE 	EQU 0XE01FC148
EXTPOLAR 	EQU 0XE01FC14C
EXTINT 		EQU 0XE01FC140
UPEDGE		EQU	0X9
	
	LDR R1,=MAMCR
	MOV R0,#0x0
	STR R0,[R1]
	LDR R2,=MAMTIM
	MOV R0,#0x1
	STR R0,[R2]
	MOV R0,#0x2
	STR R0,[R1]
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;SETTING OF THE EXTERNAL INTERRUPTS
	LDR R0, =PINSEL1
	LDR R1, [R0]
	BIC R1, #0X3
	BIC R1, #0X300
	ORR R1, R1, #EINT0 ;SETS 01 VALUE AT BITS 1:0 FOR EINT0
	ORR R1,R1,#EINT3 ;SETS 11 VALUE AT BITS 9:8 FOR EINT3
	STR R1,[R0]
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;EXTMODE SETTING EDGE-SENSITIVITY
	LDR R2, =EXTMODE
	LDR R1, [R2]
	ORR R1,R1,#UPEDGE
	STR R1,[R2]
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;EXTMODE SETTING HIGH ACTIVE
	LDR R2, =EXTPOLAR
	LDR R1, [R2]
	ORR R1,R1,#UPEDGE
	STR R1,[R2]
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;EXTINT SETTING FLAGS AT 0X9 SILENCING INTERRUPTS
	MOV R1, #0X9
	LDR R2, =EXTINT
	STR R1,[R2]
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;ENTER SUPERVISOR MODE
	MOV R14, #SUP_MODE
	ORR R14,R14,#(I_BIT+F_BIT)
	MSR CPSR_c, R14
;INITIALIZE THE STACK, FD
	LDR SP, =SUP_TOP
;LOAD THE START OF ADDRESS OF SUP CODE INTO PC
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;ENTER IRQ MODE
	MOV R14, #IRQ_MODE
	ORR R14,R14,#(I_BIT+F_BIT)
	MSR CPSR_c, R14
;INITIALIZE THE STACK, FD
	LDR SP, =IRQ_TOP
;LOAD THE START OF ADDRESS OF SUP CODE INTO PC
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;ENTER FIQ MODE
	MOV R14, #FIQ_MODE
	ORR R14,R14,#(I_BIT+F_BIT)
	MSR CPSR_c, R14
;INITIALIZE THE STACK, FD
	LDR SP, =FIQ_TOP
;LOAD THE START OF ADDRESS OF SUP CODE INTO PC
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Enter User Mode with interrupts enabled
	MOV 	r14, #USER_MODE
	BIC 	r14,r14,#(I_BIT+F_BIT)
	MSR 	CPSR_c, r14
;initialize the stack, full descending
	LDR 	SP, =STACK_TOP
;load start address of user code into PC
	;LDR 	pc, =USER_CODE

	B SUBRTS

	IMPORT SUBRTS
    END
		