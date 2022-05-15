				GLOBAL	delay10uss
				GLOBAL	LCD_pinss
				GLOBAL	LCD_inits
				GLOBAL	LCD_cmds
				GLOBAL	LCD_chars
				GLOBAL	LCD_clear
				GLOBAL 	LCD_strings
				AREA	lcd_subss, CODE, READONLY

PINSEL1			EQU		0xE002C004
PINSEL2			EQU		0xE002C014
IO0DIR			EQU		0xE0028008
IO1DIR			EQU		0xE0028018
IO0SET			EQU		0xE0028004
IO0CLR			EQU		0xE002800C
IO1SET			EQU		0xE0028014
IO1CLR			EQU		0xE002801C
	
LCD_DATA		EQU		0x00FF0000		;P1.16 - P1.23
LCD_RS			EQU		0x01000000		;P1.24
LCD_E			EQU		0x02000000		;P1.25
LCD_RW			EQU		0x00400000		;P0.22
LCD_LIGHT		EQU		0x40000000		;P0.30

CLOCK			EQU		12000000
DELAY10U		EQU		(CLOCK/400000)
		
delay10uss		STMFD	SP!, {r0, LR}
				MRS		r0, CPSR
				STMFD	SP!, {r0}
				
				LDR		r0, =DELAY10U
LOOP			SUBS	r0, r0, #1
				BNE		LOOP
				
				LDMFD	SP!, {r0}
				MSR		CPSR_f, r0
				LDMFD	SP!, {r0, PC}
				
LCD_pinss		STMFD	SP!, {r0-r2, LR}
				MRS		r0, CPSR
				STMFD	SP!, {r0}
				
				;Set P0.22 & P0.30 as GPIO
				LDR		r1, =PINSEL1
				LDR		r0, [r1]			;read contents of PINSEL1 save into r0
				LDR		r2, =0x30003000
				BIC		r0, r0, r2	;modify conents by clearing [13:12] and [29:28]
				STR		r0, [r1]			;write value back into PINSEL1
				;Set P1.16-P1.23 as GPIO
				LDR		r1, =PINSEL2
				LDR		r0, [r1]			;read contents of PINSEL2 save into r0
				BIC		r0, r0, #0x8			;modify contents by clearing bit 3
				STR		r0, [r1]			;write value back into PINSEL2
				;Set P0.22 & P0.30 as outputs
				LDR		r1, =IO0DIR
				LDR		r0, [r1]			;read contents of IO0DIR
				LDR		r2, =0x40400000
				ORR		r0, r0, r2		;modify contents to set Bit 22 and 30
				STR		r0, [r1]			;write back into IO0DIR
				;Set P1.16 - P1.23 as outputs
				LDR		r1, =IO1DIR
				LDR		r0, [r1]			;read contents of IO1DIR
				LDR		r2, =0x3FF0000
				ORR		r0, r0, r2		;modify contents to set Bits [25:16]
				STR		r0, [r1]			;write back into IO1DIR
				;Turn backlight on
				LDR		r3, =IO0SET
				LDR		r0, =LCD_LIGHT
				STR		r0, [r3]
				
				LDMFD	SP!, {r0}
				MSR		CPSR_f, r0
				LDMFD	SP!, {r0-r2, PC}
				
LCD_cmds		STMFD	SP!, {r0-r5, LR}
				MRS		r0, CPSR
				STMFD	SP!, {r0}
				
				LDR		r1, =IO1SET
				LDR		r2, =IO1CLR
				LDR		r3, =IO0SET
				LDR		r4, =IO0CLR
				
				LSL		r6, #16		;r6 contains command, shift by 16 to align
				
				LDR		r0, =LCD_DATA
				STR		r0, [r2]		;Clear data line
				STR		r6, [r1]		;Send command
				
				LDR		r0, =LCD_RS
				STR		r0, [r2]		;RS = 0
				LDR		r0, =LCD_RW
				STR		r0, [r4]		;RW = 0
				LDR		r0, =LCD_E
				STR		r0, [r2]		;E = 0
				BL		delay10uss
				
				LDR		r0, =LCD_E
				STR		r0, [r1]		;E = 1
				BL		delay10uss
				
				LDR		r0, =LCD_E
				STR		r0, [r2]		;E = 0
				MOV		r5, #4
delay40			BL		delay10uss
				SUBS	r5, r5, #1
				BNE		delay40
				
				LDMFD	SP!, {r0}
				MSR		CPSR_f, r0
				LDMFD	SP!, {r0-r5, PC}
				
LCD_chars		STMFD	SP!, {r0-r5, LR}
				MRS		r0, CPSR
				STMFD	SP!, {r0}
				
				LDR		r1, =IO1SET
				LDR		r2, =IO1CLR
				LDR		r3, =IO0SET
				LDR		r4, =IO0CLR
				
				LSL		r6, #16		;r6 contains command, shift by 16 to align
				
				LDR		r0, =LCD_DATA
				STR		r0, [r2]		;Clear data line
				STR		r6, [r1]		;Send command
				
				LDR		r0, =LCD_RS
				STR		r0, [r1]		;RS = 1
				LDR		r0, =LCD_RW
				STR		r0, [r4]		;RW = 0
				LDR		r0, =LCD_E
				STR		r0, [r2]		;E = 0
				BL		delay10uss
				
				LDR		r0, =LCD_E
				STR		r0, [r1]		;E = 1
				BL		delay10uss
				
				LDR		r0, =LCD_E
				STR		r0, [r2]		;E = 0
				MOV		r5, #4
delay40m		BL		delay10uss
				SUBS	r5, r5, #1
				BNE		delay40m
				
				LDMFD	SP!, {r0}
				MSR		CPSR_f, r0
				LDMFD	SP!, {r0-r5, PC}				
				
LCD_inits		STMFD	SP!, {r0-r6, LR}
				MRS		r0, CPSR
				STMFD	SP!, {r0}
				
				LDR		r1, =IO1SET
				LDR		r2, =IO1CLR
				LDR		r3, =IO0SET
				LDR		r4, =IO0CLR
				
				
				LDR		r0, =LCD_RS
				STR		r0, [r2]		;RS = 0
				LDR		r0, =LCD_RW
				STR		r0, [r4]		;RW = 0
				LDR		r0, =LCD_E
				STR		r0, [r2]		;E = 0
				LDR		r5, =0x5DC
delay15m		BL		delay10uss
				SUBS	r5, r5, #1
				BNE		delay15m
				
				MOV		r6, #0x30
				BL		LCD_cmds		;send 1st time
				LDR		r5, =0x19A
delay4m			BL		delay10uss
				SUBS	r5, r5, #1
				BNE		delay4m
				
				BL		LCD_cmds		;send 2nd time
				MOV		r5, #10
delay100u		BL		delay10uss
				SUBS	r5, r5, #1
				BNE		delay100u
				
				BL		LCD_cmds		;send 3rd time
				LDR		r5, =0x19A
delay4m1		BL		delay10uss
				SUBS	r5, r5, #1
				BNE		delay4m1
				
				LDR		r6, =0x38
				BL		LCD_cmds
				LDR		r6, =0x0C
				BL		LCD_cmds
				LDR		r6, =0x01
				BL		LCD_cmds
				LDR		r6, =0x06
				BL		LCD_cmds
				
				LDR		r0, =LCD_LIGHT
				STR		r0, [r4]
				
				LDMFD	SP!, {r0}
				MSR		CPSR_f, r0
				LDMFD	SP!, {r0-r6, PC}

LCD_strings		STMFD	SP!, {r0-r5, LR}
				MRS		r0, CPSR
				STMFD	SP!, {r0}
				BL		LCD_cmds	;send command to set curosr position
				MOV		r5, #200
delay200m		BL		delay10uss
				SUBS	r5, r5, #1
				BNE		delay200m

stringloop		LDRB	r6, [r8], #1	;get a character from string, post index by 1 passed through r8
				CMP		r6, #0			;check for end of string
				BEQ		exit			;leave if end found
				BL		LCD_chars
				B		stringloop
exit
				LDMFD	SP!, {r0}
				MSR		CPSR_f, r0
				LDMFD	SP!, {r0-r5, PC}
				
LCD_clear		STMFD	SP!, {r0-r6, LR}
				MRS		r0, CPSR
				STMFD	SP!, {r0}
				
				LDR		r6, =0x01
				BL		LCD_cmds
				
				LDMFD	SP!, {r0}
				MSR		CPSR_f, r0
				LDMFD	SP!, {r0-r6, PC}	
				
				END