	.arch	armv7
	.cpu	cortex-a53
	.fpu	neon-fp-armv8
	.global	main
	.text

main:
	mov	R3, R0		@ R3 <- R0
	str	R0, [SP,#-4]	@ store contents of R0 (#args+1) into byte
				@ address stored in [SP-4 bytes]

	str	R1, [SP,#-8]	@ store contents of R1 (arg1) into byte
				@ address stored in [SP - 8 bytes]

	cmp	R3, #2		@ is #args + 1 equal to 2?
				@ if not, write msg to user and exit

	bne	endProgram	@ if more or less arguments than 1 args passed,
				@ exit program

startChecking:
	ldr 	R3, [SP,#-8]	@ load R3 with value located in byte address
				@ contained in [SP,#-8] (i.e. arg1)
	add	R3, R3, #4	@ change R3 to addr of next char in arg1
	ldr	R3, [R3]	@ load R3 with value in byte address in R3
	mov	R4, #0		@ initialize R4 (loop index for each number part)
	mov 	R8, #0
	mov	R9, #0
	ldr	R5, =firstpartes @first number part until dot will be added here
	ldr	R2, =answer    @ we will store final answer here.
	mov	R12, #0		@ this will keep index of looping over entire IP address.
	mov	R1, #0		@ this will keep number of dots.
	
loop:
	ldrb	R6, [R3,R12]	@ load R6 with value at address R3+R4 bytes
				@ i.e., char in arg1 
	cmp	R4, #0
	bne	checkDot	@in case 	4 not zero, we want to check if dot.If R4 is zero, it should be at 					@least one number.
	sub	R6, R6, #48 	@sub 48 , ascii code of 0.
	cmp	R6, #9		@ compare to 9, if greater than its not a number.So wrong IP format.
	bgt	wrongFormat
	add	R6, R6, #48	@Add back 48 after correct validation.
	strb	R6, [R5], #1	@store in firstpartes.
	add	R12, R12, #1	
	add	R4, R4, #1	
	b	loop		@keep looping until we hit dot or in case of last part number 0 or new line.

checkDot:
	cmp	R1, #3		@R1 keeps number of dots, in case last dot. We need to check for new line or 					@0.
	beq	checkNewLine
	cmp	R6, #46		@check for dot.
	beq	stop6		@in case it is process the part of number we got.
	b	do1	
	
checkNewLine:
	cmp	R6, #10		@we will be checing this part if R1=3, so we got past by our last dot.
	beq	stop6		
	cmp	R6, #0	
	beq	stop6

do1:
	cmp	R4, #2		@in case more than three numbers typed for some part of ip, wrong format.
				@should be only maximum 3 digits before dot.
	bgt	wrongFormat
	sub	R6, R6, #48
	cmp	R6, #9
	bgt	wrongFormat
	add	R6, R6, #48
	strb	R6, [R5], #1	@store in firstpartes
	add	R12, R12, #1	@update loop index over entire ip string. (192.168.0.1)
	add	R4, R4, #1	@update loop index over entire ip string. (192.168.0.1)
	b	loop

stop7:
	mov	R9, #0
	push	{R5-R10}
	bl	stop4		@lets change number we processed to binary representation.
	ldr	R5, =firstpartes @ lets rewrite on firstpartes the next part of number ( one after next dot)
	add	R12, R12, #1	@update loop index
	mov	R4, #0		@reset R4 to #0 for next part of the number we process
				@like 192.168 we were done with 192., now moving 168.We reset R4 TO 0.
	add	R1, R1, #1	@update number of dots read.
	cmp	R1, #4		@in case 4, no more to read print result.
	beq	printResult
	b	loop

stop6:
	mov	R9, #0
	push	{R5-R10}
	bl	stop4 		@lets change number we processed to binary representation.
				@ we are passing to stop4, R1 number of dots.R4 length of number - 1.
				@ R2 where we want to write result.
	
	ldr	R5, =firstpartes @ lets rewrite on firstpartes the next part of number ( one after next dot)
	add	R12, R12, #1	@update loop index
	mov	R4, #0		@reset R4 to #0 for next part of the number we process
				@like 192.168 we were done with 192., now moving 168.We reset R4 TO 0.

	add	R1, R1, #1	@update number of dots read.
	cmp	R1, #4		@in case 4, no more to read print result.
	beq	printResult
	b	loop
stop4:
	mov	R6, #0		@index to loop over part of number we are changing.
stop:
	ldr	R5, =firstpartes
	cmp	R6, R4		@R4 is length of current number - 1 we converting.
	bge	stop1		@once done converting "192" string to 192 number, lets move to convert to 					@binary.
	ldrb	R7,[R5,R6]	@lets read first value
	sub	R7,#48		
	cmp 	R4, #2		@in case R4 aka length of number - 1 is 2, multiply first value by 100
				@second value by 10 , third value by 1.
				@for ex. 192 = 100*1 + 9*10 + 2*1
	bgt	mul10 

	cmp 	R4, #1		@in case R4 aka length of number - 1 is 1, multiply first value by 10
				@second value by 1.
				@for ex. 20 = 2*10 + 0*1

	bgt	mul102		
				@in case R4 aka length of number - 1 is neither 1 or 2, just multiply by 1.
	add	R9, R7 ,R9	@ we will store result of calculation in R9
	add	R6,R6,#1	@update loop index.
	b	stop
mul102:
	cmp 	R6, #0		@if R6 is 0, we are processing the 3 in 32.	
	beq	mul101
	mov	R10, #1		@else we are processing the 2 in 32
	mul	R8, R7, R10
	add	R9, R8, R9	@add to R9.
	add	R6,R6,#1
	b	stop

mul10:
	cmp 	R6, #0		@if R6 is 0, we are processing the 1 in 192.
	beq	mul100
	cmp 	R6, #1		@if R6 is 1, we are processing the 9 in 192.
	beq	mul101
	mov	R10, #1		@else  we are processing the 2 in 192.
	mul	R8, R7, R10
	add	R9, R8, R9
	add	R6,R6,#1
	b	stop
mul100:
	mov	R10, #100 	@Multiply by 100 since in like 192, we are at the 1.
	mul	R8, R7, R10
	add	R6,R6,#1
	add	R9, R8, R9	@store result in R9.
	b	stop
mul101:
	mov	R10, #10
	mul	R8, R7, R10
	add	R6,R6,#1
	add	R9, R8
	b	stop


/*
	below functions are very easy. So in case number is 192, we will first compare to 128.
	If its greater or equal ! than our first bit is 1, else our first bit is 0.
	in case greater we do 192 - 128 = 64. We move to compare with 64(shift right by 1 that is divide by 		2)
	now, if greater or equal ! THan our
	second bit is 1, else our second bit is 0. In case of 192 we now have first 2 bits 11.
	We continue this time doing 64 - 64 = 0 and compare this new number to 32, in case greater or equal
	than out third bit is 1  else its 0. In the case of 192 now we have 110...We do not subtract the 	 third time because 0 less than 32. 
	We do this for 128, 64,32,16,4,2,1 to get out 8 bit number. So 192 = 11000000. We add dot to last 
	part ( unless fourth number). Result stored in answer, R2 holds it.
*/
stop1:
	mov	R10, #128
	cmp	R9,#255		@ we have to check it should not be number bigger than 255. Else invalid IP.
	bgt	wrongFormat
	cmp	R9,#0		@ neither less than 0 IP.
	blt	wrongFormat
	b	print

print:
	cmp	R9, R10
	bge	minus
	mov	R6, #'0'
	strb	R6, [R2], #1
	lsr	R10, R10, #1 	// divide by 2, 128/2 = 64, 64/2 = 32.
	b	movone

minus:
	sub	R9, R9, R10
	mov	R6, #'1'	
	strb	R6, [R2], #1
	lsr	R10, R10, #1	// divide by 2, 128/2 = 64, 64/2 = 32.
	b	movone

movone:	
	cmp	R9, R10
	bge	minus2
	mov	R6, #'0'
	strb	R6, [R2], #1
	cmp	R10, #1
	beq	movone8
	lsr	R10, R10, #1
	b	movone
minus2:
	sub	R9, R9, R10
	mov	R6, #'1'	
	strb	R6, [R2], #1
	cmp	R10, #1
	beq	movone8
	lsr	R10, R10, #1
	b	movone


movone8:
	cmp	R1, #3 		@in case R1 is 3, we will not append dot to last part of the number.
				@so 192.168.0.1 we append dot to 192, 168, and 0. But 1 NO!.
				@ R1 holds number of dots.
	bne	movon9
	pop	{R5-R10}
	mov	pc, lr
movon9:
	mov	R6, #46
	strb	R6, [R2], #1
	pop	{R5-R10}
	mov	pc, lr
	

@print the result onto screen.
printResult:
	mov	R0, #1
	ldr	R1, =answer
	mov	R2, #answerlen
	bl	write		
	
done:
	mov	R0, #0
	mov	R7, #1
	swi	0


@print invalid format
wrongFormat:
	@put out error message 
	mov	R0, #1
	ldr	R1, =errormsg2
	mov	R2, #errormsg2len
	bl	write
	b	done

@should provide only one  command line argument, print error message.
endProgram:
	@put out error message 
	mov	R0, #1
	ldr	R1, =errormsg1
	mov	R2, #errormsg1len
	bl	write
	b	done


.data
errormsg1: .ascii	"Provide one command line argument only.No more no less.\n"
	  .equ		errormsg1len, (.-errormsg1)

errormsg2: .ascii	"Invalid IP Address\n"
	  .equ		errormsg2len, (.-errormsg2)

firstpartes: .space	3, 0		@ maximum each part of ip should be 3 numbers, between 0 and 255.
	   .ascii	"\n"
	   .equ	firstpartlen, (.-firstpartes)
answer: .space	37, 0			@ 37 , 32 bits 4 dots plus new line.
	   .ascii	"\n"
	   .equ	answerlen, (.-answer)




