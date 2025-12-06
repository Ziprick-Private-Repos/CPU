org $0
offset @0

lod #1
mov r2,r1
lod #$b8

Start:
<<<<<<< HEAD
	lod #2
	mov r4,r1
	lod #$0
	mov r2,r1
	lod #1
	divs
	cmps
	bgr LoopForever
	halt

LoopForever:
	bra LoopForever

;	ssfp
;	bra Main
	
;xVar:
;	dbh #a

;Main:
;	gsfp #10
;	ldm xVar
;	xor r1
;	stb xVar
;	bra Main
=======
	sub r2
	;bra Start
	halt
>>>>>>> 9f674d08e67f18741919f40807e1d20b45181972
