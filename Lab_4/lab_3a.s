#----------------------------------------------------------------
# Program lab_3a.s - Asemblery Laboratorium IS II rok
#----------------------------------------------------------------
#
#  To compile: as -o lab_3a.o lab_3a.s
#  To link:    ld -o lab_3a lab_3a.o
#  To run:     ./lab_3a
#
#----------------------------------------------------------------

	.equ	create_64,	0x55	# create file function
	.equ	close_64,	0x03	# close file function
	.equ	write_64,	0x01	# write data to file function
	.equ	exit_64,	0x3c	# exit program function

	.equ	mode,	0x1ff	# attributes for file creating
	.equ    stderr, 2
	.equ	errval,	2

	.data
	
counter:
	.byte		10	# loop counter we start from 10 and go down
				# each time we will check if value is 0 before jump
file_n:				
	# file name (0 terminated)
	.string	"testfile.txt"

file_h:				# file handle
	.quad		0

txtline:			# text to be written to file
	.ascii	"A line of text\n"

txtlen:				
	# size of written data
	# dot is the address of current position during
	.quad		( . - txtline )

errmsg:				# file error message
	.ascii	"File error!\n"

errlen:
	.quad		( . - errmsg )

allokmsg:			# All OK message
	.ascii	"\nAll is OK - too hard to believe!\n"

alloklen:
	.quad		( . - allokmsg )

	.text
	.global _start

	
_start:
	MOV	$create_64,%rax	# create function
	MOV	$file_n,%rdi	# RDI points to file name
	MOV	$mode,%rsi	# mode of created file in RSI
	SYSCALL
	
	CMP	$0,%rax
	JL	error		# if RAX<0 then something went wrong

	MOV	%rax,file_h	# store file handle returned in EAX

loop:	# label for creating the loop	

	MOV	$write_64,%rax	# write function
	MOV	file_h,%rdi	# file handle in RDI
	MOV	$txtline,%rsi	# RSI points to data buffer
	MOV	txtlen,%rdx	# bytes to be written
	SYSCALL

	CMP	%rdx,%rax
	# jump if not zero 
	JNZ	error		# if RAX<>RDX then something went wrong

	# --------------------------------------------------------------------
	# My new code, that make loop work
	# --------------------------------------------------------------------

	DECB	counter		# decrementing counter with size of byte by one
	JNZ 	loop		# if flag not zero jump to label loop

	# --------------------------------------------------------------------

	MOV	$close_64,%rax	# close function
	MOV	file_h,%rdi	# file handle in RDI
	SYSCALL

	CMP	$0,%rax
	JL	error		# if RAX<0 then something went wrong

all_ok:
	MOV	$write_64,%rax	# write function
	MOV	$stderr,%rdi	# file handle in RDI
	MOV	$allokmsg,%rsi	# RSI points to All OK message
	MOV	alloklen,%rdx	# bytes to be written
	SYSCALL

	XOR	%rdi,%rdi
	JMP	theend

error:
	MOV	$write_64,%rax	# write function
	MOV	$stderr,%rdi	# file handle in RDI
	MOV	$errmsg,%rsi	# RSI points to file error message
	MOV	errlen,%rdx	# bytes to be written
	SYSCALL

	MOV	$errval,%rdi

theend:
	MOV	$exit_64,%rax	# exit program function
	SYSCALL

