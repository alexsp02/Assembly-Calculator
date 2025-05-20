.begin
CONS .equ 0x3FFFC0
COUT .equ 0x0
CSTAT .equ 0x4
CIN .equ 0x8
CICTL .equ 0xC
.org 2048

prog:	or %r0, 0, %r2
	or %r0, equation, %r5
	or %r0, invalid, %r4
	sethi CONS, %r1

getin:	call iwait
	st %r14, %r5
	call echo
	add %r5, 4, %r5
	add %r2, 1, %r2
	subcc %r2, 3, %r0
	bne getin

valid1:	ld [equation], %r2
	subcc %r2, 48, %r0
	bl error
	subcc %r2, 57, %r0
	bg error

valid3:	ld [equation + 8], %r2
	subcc %r2, 48, %r0
	bl error
	subcc %r2, 57, %r0
	bg error

validop:	ld [equation + 4], %r2
	subcc %r2, 43, %r0
	be a
	subcc %r2, 45, %r0
	be s
	subcc %r2, 42, %r0
	be m
	subcc %r2, 47, %r0
	be d
	subcc %r2, 94, %r0
	be e
	ba error

a:	ld [equation], %r29
	ld [equation + 8], %r30
	sub %r29, 48, %r29
	sub %r30, 48, %r30
	add %r29, %r30, %r31
	call print

s:	ld [equation], %r29
	ld [equation + 8], %r30
	sub %r29, 48, %r29
	sub %r30, 48, %r30
	sub %r29, %r30, %r31
	call print

m:	call mult
	call print

d:	call div
	call print

e:	call exp
	call print

iwait:	clr %r3
	ldub [%r1 + CICTL], %r3
	andcc %r3, 0x80, %r3
	be iwait
	ldub [%r1 + CIN], %r14
	jmpl %r15 +4, %r0
	

error: 	clr %r3
	ldub [%r1 + CSTAT], %r3
	andcc %r3, 0x80, %r3
	be error
	ld %r4, %r2
	orcc %r2, 0, %r0
	be done
	stb %r2, %r1
	add %r4, 4, %r4
	ba error
	
j:	jmpl %r15+4, %r0

mult:	ld [equation], %r29
	ld [equation + 8], %r30
	sub %r29, 48, %r29
	sub %r30, 48, %r30
	clr %r31
lpm:	subcc %r30, 0, %r0
	be j
	sub %r30, 1, %r30
	add %r31, %r29, %r31
	ba lpm

div:	ld [equation], %r29	! %r1 holds numerator
	ld [equation + 8], %r30	! %r2 holds denominator
	sub %r29, 48, %r29
	sub %r30, 48, %r30
	subcc %r30, 0, %r0
	be error
	add %r0, 0, %r31	! Floor divison counter in %r3
lpd:	subcc %r29, %r30, %r0
	bpos dv
	ba j
dv:	sub %r29, %r30, %r29
	add %r31, 1, %r31
	ba lpd
	

exp:	ld [equation], %r29	! DO NOT CHANGE, holds original base
	ld [equation + 8], %r30	! DO NOT CHANGE, holds intial exponent
	sub %r29, 48, %r29
	sub %r30, 48, %r30
	add %r0, 1, %r3	! Outer loop index
	add %r0, %r29, %r31  ! %r5 will hold result
	add %r0, %r29, %r6	 ! CHANGABLE COPY OF %r1
outer:	subcc %r30, %r3, %r0
	be j
	add %r0, 1, %r4	! Inner loop index
	add %r3, 1, %r3
	add %r0, %r31, %r6
	ba inner
inner:	subcc %r29, %r4, %r0
	be outer
	add %r4, 1, %r4
	add %r6, %r31, %r31
	ba inner

echo:	ldub [%r1 + CSTAT], %r3
	andcc %r3, 0x80, %r3
	be echo
	ld %r5, %r27
	stb %r27, %r1
	jmpl %r15+4, %r0

print:	or %r0, 0, %r16
	or %r0, res, %r5
lp:	subcc %r16, 5, %r0
	add %r16, 1, %r16
	be done
	call echo
	add %r5, 4, %r5
	ba lp

done:	halt

equation: .dwb 3

!nums: 48, 49, 50, 51, 52, 53, 54, 55, 56, 57 (0-9)

!ops: 43, 45, 42, 47, 94 (+, -, *, /, ^)

invalid: 44,32,73,110,118,97,108,105,100,32,105,110,112,117,116,33,0

res: 61, 37, 114, 51, 49

.end
