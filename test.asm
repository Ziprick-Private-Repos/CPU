org $0
offset @512

Start:
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