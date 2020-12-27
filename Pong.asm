DisplayChar MACRO Char
	            PUSH AX
	            PUSH DX

	            mov  ah,2
	            mov  dl, Char
	            int  21h

	            POP  DX
	            POP  AX
ENDM
MoveCursor MACRO X,Y 
               PUSH AX
	           PUSH DX

	           mov  ah,2
	           mov  dl,X
	           mov  dh,Y
	           int  10h

	           POP  DX   
	           POP  AX
ENDM
GoIntoTextMode MACRO
	               PUSH AX

	               mov  ah,0
	               mov  al,03h
	               int  10h

	               POP  AX

ENDM         
ClearScreen MACRO    
            PUSHALL
			MOV AH, 0
			MOV AL, 03h
            int 10h
			; Code for Hding the blinking Text cursor
			; Looks bad when drawing the game every cycle
			MOV CH, 20H 
			MOV AH, 01H
			INT 10H
            POPALL
ENDM              
FlushKeyBuffer MACRO 
                PUSH AX
	            mov ah,0ch
	            mov al,0
	            int 21h   
	            POP AX
ENDM FlushKeyBuffer     
DisplayMessage MACRO Message
		 MOV 			AH, 9h
		 MOV 			DX, OFFSET Message
		 INT 21h	
ENDM
HideCursor MACRO 
	mov ch, 32
 	mov ah, 1
 	int 10h 

ENDM

; An alternative to POPA which doesn't work in MASM/TASM
; Can be changed to include other registers if necessary.
POPALL MACRO 
	POP DX
	POP CX
	POP BX
	POP AX
ENDM

PUSHALL MACRO 
	PUSH AX
	PUSH BX
	PUSH CX
	PUSH DX
ENDM

.Model SMALL
.STACK 100

.DATA
	 ; Variables here
	 PlayerInitialRow     DB  0CH
	 LeftPlayerIitialCol  DB  2H
	 RightPlayerIitialCol DB  77D
	 PlayerSymbol         EQU "#"
	 BallInititLoc        DB  3D, 11D
     BulletSymbol EQU "O"                 
     PLAYER_WIDTH EQU 3
	 PLAYER_HEIGHT EQU 2
	 CactusNum EQU 2 
	 DynamicBlock1 DB 1
	 DynamicBlock2 DB -1
	 ; Player Scores
	 PlayerOneScore DB 30H
	 PlayerTwoScore DB 30H
	 ; Player DB xPos, yPos, bullets, bulletsInArena
	 PLAYER_DATA_SIZE EQU 4 ; How many bytes does one player occupy in memory
	 PlayerOne DB 02, 12, 3, 0
	 PlayerTwo DB 77, 12, 3, 0
     
	 NumBullets EQU 2 ; Change when adding bounce bullets
	 BulletDataSize EQU 5 ; How many bytes does a single bullet occupy
	 Bullets LABEL BYTE
	 ; Bullet DB xPos, yPos, xVel, yVel, active
	 ; Can split the velocity of each bullet into a seperate "object", having it embedded is cleaner though
	
	 ;Please Make sure for now to put $ at the end of the last bullet buffer till we find out another solution

	 ; Player1 bullets
	 P1Bullet1 DB 40, 12, 2, 0, 0
	 ; Bounce bullets here

	 ; Player2 bullets
	 P2Bullet1 DB 40, 12, -2, 0, 0, '$'
	 ; Bounce bullets here
     

	 ;Displayed messages
	 Welc DB 'Please Enter Your Name:', 13, 10, '$'
	 Hel DB 'Please Enter any key to continue','$'
	 Choices DB '* To start chatting press F1', 13,10,13,10, 09,09,09, '* To start game press F2', 13,10,13,10, 09,09,09,'* To end the program press ESC',13,10, '$'
	 Info DB 13,10,'- You send a chat invitaion to ','$'
	 userName DB 16,?, 16 DUP('$')
	 userNameScore DB "'s Score : ", '$'
	 userName2 DB "Abdelrahman", '$' ; Fixed at Abdelrahman for now but should be whatever User types in chatting screen
	 p1Score DB "Tarek's Score : ", '$'
	 p2Score DB "Abdelrahman's Score :", '$'
	 endGame DB "- To end the game with Abdelrahman, Press F4", '$'
	 endGame1 DB "- To end the game with ", '$'
	 endGame2 DB ", Press F4", '$'
	 WinCondition DB " Wins with score: " , '$'
	 WinScore DB " To ", '$'
	 Test1 DB "Test", '$'
	 Block_Nums DB 6,4,1,9,6,7,3,7,7,8,8,7,9,4,1,5,3,8,5,5,6,7,7,5,1
	 Chars DB '0','1','2','3','4','5','6','7','8','9',"10"
	 authentication DB 0
	 exiting DB 0

	BlockSymbol EQU 178D

	; xPos, yPos, height
	 Block1 DB 20d, 12D, 8D
	 Block2 DB 60d, 10D, 4D

	; xPos, yPos pairs
	 Cactus DB 32d,11d,11d,5d,'$'
	 CactusSymbol EQU 206

.CODE
MAIN PROC FAR
	; Code here
	; Initializing DS
	     MOV            AX, @DATA
	     MOV            DS, AX

	; Chaning video mode
	     GoIntoTextMode

	CMP authentication, 1
	JZ OptionsScreen
	; Main Screen
	Home:
		 ;ClearScreen
		 
		;Display the Message in the middle of the main screen
		;Move Cursor 
		 MoveCursor 0AH, 0AH

		;Display welcome message
		 DisplayMessage Welc
	
	;Get user's name
		;Move Cursor 
  		 MoveCursor 0CH, 0CH

		; This part isn't repeated that much, probably doesn't need a macro
		; Take the username as an input
		 MOV 			AH, 0Ah
		 MOV 			DX, OFFSET userName
		 INT 21h

		;Validate the name
		 CMP userName+2, 41h 
		 JB Home 
		 
		 CMP userName+2, 5Ah
		 JBE Welcome 		; if in range A:Z
		 JA Check 			; If greater than A and not in range A:Z, check for a:z
			
	Check:
		 CMP userName+2,61h
		 JB Home 
		 CMP userName+2, 7Ah
		 JA Home  			; If not a letter, clear

	
	Welcome:				;Welcome the user
		MOV SI, OFFSET authentication
		MOV BYTE PTR [SI], 1
		;Move Cursor
		 MoveCursor 0AH, 0DH

		;Display "press any key to continue" message
		 DisplayMessage Hel

		;Get any key as an indicatr to continue
		 MOV 			AH, 0
		 INT 16h

	OptionsScreen:
		 ClearScreen
		;Move Cursor
		 MoveCursor 18H, 0AH
		;Display Options
		 DisplayMessage Choices
			
	;Get User's choice
	CHS:
		 MOV 			AH, 0
		 INT 16h
		
		;Check user's input
		 CMP AH, 1   		       ; Check for ESC
		 JNZ NotExit
		 JMP Exit
		 NotExit:
		 CMP AH, 3Ch 		       ; Check for F2
		 JNZ NotF2
		 CALL ResetRound           ; Reset the player positions
		 MOV PlayerOneScore, 30H   ; Reset both players' scores
		 MOV PlayerTwoScore, 30H
		 JMP GameLoop
		 NotF2:
		 CMP AH, 3Bh 		       ; Check for F1
		 JNZ CHS 			       ; if the pressed key not an option, loop till it is

	Chatting:		
		;To be Continued "D
		;Move cursor to the footer

		 MoveCursor 00H, 15H
		
		
	; Loading the character, number of loops and preparing the interrupt 
		 MOV 			CX, 79
		 MOV 			AH, 2
		 MOV 			DL, '-'
 	;Draw the dashed line
	Footer:
		 INT 21h
		 LOOP Footer
		 
		; Show info message
		 DisplayMessage Info
		
	 	; Just to hold the program to see the above changes till we decide what to do next
		 MOV 			AH, 0
		 INT 16h
		 JMP Exit
		
	GameLoop:    

		; Check if Any player Won

		MOV AL, PlayerOneScore
		MOV AH, PlayerTwoScore
		CMP AL, 35H
		JNZ Skip
		CALL WinScreen
		JMP OptionsScreen
		JMP Skiip
		Skip:
		CMP AH, 35H
		JNZ Skiip
		CALL WinScreen
		JMP OptionsScreen
		SKiip:

		; Get player input    
		; Currently only getting local player input

		 CALL GetPlayerInput      

		; Game logic 
		 CALL Logic
		 

		 CALL StaticLayout
		; Draw The Player at their proper position, derived from player input


		 CALL Draw
		 
	     ; TODO: Move ball
	     ; Might get changed depending on the game
		 LEA SI, endGame
		 MOV BH, [SI]
		 CMP BH, 1

		 JNZ GameLoop

		 LEA SI, authentication
		 MOV BH, [SI] 
		 CMP BH, 1
		 JNZ DONTDOIT
		 JMP OptionsScreen
		 DONTDOIT:
	Exit:
		; Exits the program
		 MOV            AH, 4CH
		 INT            21H

MAIN ENDP

; The main logic of the game
Logic PROC
; Checking for all bullet collisions with P1
; Need to loop every bullet over all of the player's blocks
	; LEA SI, PlayerOne
	; MOV DL, BYTE PTR [SI]		; DL carries the X coordinate (Columns) for P1
	; MOV DH , BYTE PTR [SI + 1]  ; DH carries the Y coordinate (Rows) for P1
	; MOV AH , PLAYER_HEIGHT
	; MOV CL, NumBullets
	; MOV CH, 0

; Check whether both players ran out of bullets and they have no bullets in arena
; If so, reset round

	LEA DI, P1Bullet1			; Starting with bullet 1
	LEA SI, Cactus ; To Iterate on the cactus objects to check collisions ,  [SI] and [SI+1] are xPos and yPos of the cactus



; Cactus collisions logic:
							; iterate on Cactus Buffer
							; 1- for each cactus
							; 2- check first bullet1
							; 3- if the bullet hits => CactusHit
							; 4- if not, check bullet2
							; 5- if bullet2 hits => CactusHit
							; 6- if not => go to the next cactus
 
CactusCollisions:
	
	forEachBullet:					; 1- for each cactus, check all the bullets
		MOV CH , 0 				  ; Will be used for jumping when checking x+1 and x
		MOV AL, BYTE PTR [DI + 4] ; Carries the current bullet's active flag
		CMP AL, 1				  ; Checking if the bullet is active
		JNZ InactiveBullet		  ; If not, skip the collision check
	
		MOV BL, BYTE PTR [DI]	  ; Otherwise, load xPos and yPos into BL and BH
		MOV BH, BYTE PTR [DI + 1]
	
		MOV CL, BYTE PTR [SI]		; Stores the cactus's xPos
		CMP BL, CL					;Check if the bullet xPos is the same as a cactus xPos
		JZ ChecksStart				; If the bullet's xPos and the cactus's xPos match, got a hit, don't increment CH

		INC CL						; x = x+1
		CMP BL,CL					; If the bullet's xPos = cactus's xPos + 1, got a hit, don't increment CH
		JZ ChecksStart

		; If the bullet's xPos doesn't match neither the cactus's Xpos or Xpos + 1, no hit, check the next bullet.
		JNZ nextBullet				; if not , check next bullet

ChecksStart:	
		;if a bullet hits a cactus
		MOV AL, [SI+1]				;get yPos of cactus
		CMP BH, AL					; check yPos of cactus with yPos of bullet
		JZ UpperPart				; if equal , the bullet hit the upper part , so reflect the bullet with angle 30
		JL nextBullet				; if the bullet passed above the cactus, then no need to further ckecking
		INC AL						; increase yPos of cactus to get the middle part
		CMP BH, AL					; if the bullet hit the middle part
		JZ MiddlePart				; reflect it with 0 angle
		INC AL						; increase yPos to get the lower part
		CMP BH, AL					; check 
		JZ LowerPart				; if equal , the bullet hit the lower part and should be reflected with 60 angle
		JG nextBullet				; if not, the bullet didn't hit the cactus >> go check the next bullet
UpperPart:
		MOV BH, [DI+2]
		CMP BH, 0 				; if the bullet was going from right to left, make it go from left to right with 45 degree
		JL Increase
		MOV BH, -2				; else if the bullet was going from left to right, make it go from right to left with 45 degree
		JMP MOVE
	Increase:
		MOV BH, 2
		MOV [DI+2], BH
		MOV BH, -2
		MOV [DI +3], BH
		JMP nextBullet
	MOVE:
		MOV [DI+2], BH
		MOV [DI+3], BH
		JMP nextBullet
MiddlePart: ;reverse the sign for xVel, make the bullet go to the oppsite direction in the same horizontal line
		MOV BH, 0
		SUB BH, BYTE PTR [DI+2]
		MOV [DI+2], BH

		JMP nextBullet
LowerPart:
		MOV BH, [DI+2]
		CMP BH, 0
		JL Increase2
		MOV BH, -2
		MOV [DI+2], BH
		MOV BH, 2
		MOV [DI+3], BH
		JMP nextBullet
	Increase2:
		MOV BH, 2
		MOV [DI+2], BH
		MOV [DI+3], BH
		JMP nextBullet

	InactiveBullet:			; If the current bullet is inactive, check the next one
	nextBullet:					
		ADD DI, BulletDataSize		; Loads the next bullet's data
		MOV BL, [DI]				; check if we check all the bullets
		CMP BL, '$'					; if we checked all the bullets, go to the next cactus
		JZ ResetBullet				; If we finished checking all bullets, reset the current bullet, check the next cactus
		JMP forEachBullet			; if not, continue with the current cactus

	ResetBullet:					; Added this label and its repective JZ as "JNZ forEachBullet" was out of jump range
	LEA DI, P1Bullet1				; reset the pointer to the first bullet

	NextCactus:
		ADD SI, 2
		MOV BL, [SI]
		CMP BL, '$'					; if we finish checking for all cactuses
		JZ stopIterate				; stop iterating 
		JMP CactusCollisions		; if not, go to the next cactus

stopIterate:
	LEA SI, PlayerOne
	MOV DL, BYTE PTR [SI]		; DL carries the X coordinate (Columns) for P1
	MOV DH , BYTE PTR [SI + 1]  ; DH carries the Y coordinate (Rows) for P1
	MOV AH , PLAYER_HEIGHT
	MOV CL, NumBullets
	MOV CH, 0
	LEA DI, P1Bullet1			; Starting with bullet 1
BulletPlayer1Col:
	MOV AL, BYTE PTR [DI + 4] ; Carries the current bullet's active flag
	CMP AL, 1				  ; Checking if the bullet is active
	JNZ InactiveBullet1		  ; If not, skip the collision check
	MOV BL, BYTE PTR [DI]	  ; Otherwise, load xPos and yPos into BL and BH
	MOV BH, BYTE PTR [DI + 1]

	CMP BL, 2				  ; Checking if the bullet is near P1
	JA NotNearP1 			  ; If the bullet's xPos ≠ 2 (not near P1), check the next bullet, EDIT THIS IF WE NEED TO CHECK PAST THE FACE
	CheckPlayer1CollisionsY:
		;Check First Player Row
		CMP BH, DH	; Comparing Y coordinates
		JNZ NoP1Hit ; If the y coordinate doesn't match, bail
		; If both the x and y coordiantes match, it's a hit!
		ADD PlayerTwoScore, 1 ;Add one to the other player's score
		MOV BYTE PTR [DI + 4], 00D       ;Deactivate this bullet's active flag
		MOV BYTE PTR [DI], 40D
		MOV BYTE PTR [DI + 1], 12D
		; Move the bullet to the middle
		; Check whether this buller belongs to P1 or P2
		CMP CL, 2        ;If CL = 2, it's bullet one belonging to player one
		JNZ P2
		DEC BYTE PTR [SI + 3]     ;So, decrement player one's bullet count in the arena
		JMP EndDecrement1
		P2:
		LEA SI, PlayerTwo ; Otherwise, load P2 in SI , decrement his bullet count then load P1 is SI again 
		DEC BYTE PTR [SI + 3]
		LEA SI, PlayerOne
		EndDecrement1:
		CALL ResetRound
		; I'll cause it to abort further checking for now until we get a proper score update procedure
		JMP EndPlayer1Checks

		; Checks here
		NoP1Hit:
		DEC DH					; Going 1 block up
		DEC AH   				; Decrement the number of player blocks left to check
		CMP AH, 0        		; If no blocks are left, on to the next bullet
		JNZ CheckPlayer1CollisionsY


	InactiveBullet1:			; If the current bullet is inactive, check the next one
	NotNearP1:					; Jump here if the bullet's xPos > 2
	ADD DI, BulletDataSize		; Loads the next bullet's data
	LOOP BulletPlayer1Col		; Loops to check the rest of the bullets with P1
	EndPlayer1Checks:			; Jump here if the player was hit, TEMPORARY


; Checking for all bullet collisions with P2
; Need to loop every bullet over all of the player's blocks
	LEA SI, PlayerTwo
	MOV DL, BYTE PTR [SI]		; DL carries the X coordinate (Columns) for P2
	MOV DH , BYTE PTR [SI + 1]  ; DH carries the Y coordinate (Rows) for P2
	MOV AH , PLAYER_HEIGHT
	MOV CL, NumBullets
	MOV CH, 0
	LEA DI, P1Bullet1			; Starting with bullet 1

BulletPlayer2Col:
	MOV AL, BYTE PTR [DI + 4] ; Carries the current bullet's active flag
	CMP AL, 1				  ; Checking if the bullet is active
	JNZ InactiveBullet2		  ; If not, skip the collision check
	MOV BL, BYTE PTR [DI]	  ; Otherwise, load xPos and yPos into BL and BH
	MOV BH, BYTE PTR [DI + 1]
	CMP BL, 77				  ; Checking if the bullet is near P2
	JB NotNearP2			  ; If the bullet's xPos ≠ 77 (not near P2), check the next bullet, EDIT THIS IF WE NEED TO CHECK PAST THE FACE
	CheckPlayer2CollisionsY:
		CMP BH,DH	; Comparing Y coordinates
		JNZ NoP2Hit ; If the y coordinate doesn't match, bail
		; If both the x and y coordiantes match, it's a hit!
		ADD PlayerOneScore, 1
		MOV BYTE PTR [DI + 4], 0D ; Setting the bullet's active flag to false
		MOV BYTE PTR [DI], 40D    ; Putting the inactive bullet in the middle
		MOV BYTE PTR [DI + 1], 12D 
		; Check whether this bullet belongs to P1 or P2
		CMP CL, 2        ;If CL = 2, it's bullet one belonging to player one
		JZ P1           ; decrement player one's bullet count
		DEC BYTE PTR [SI + 3]     ; Otherwise, decrement player two's bullet count
		JMP EndDecrement2
		P1:
		LEA SI, PlayerOne ; Otherwise, load P1 in SI , decrement his bullet count then load P2 is SI again 
		DEC BYTE PTR [SI + 3]
		LEA SI, PlayerTwo
		EndDecrement2:
		CALL ResetRound
		; I'll cause it to abort further checking for now until we get a proper score update procedure
		JMP EndPlayer2Checks

		; Checks here
		NoP2Hit:
		DEC DH					; Going 1 block up
		DEC AH   				; Decrement the number of player blocks left to check
		CMP AH, 0        		; If no blocks are left, on to the next bullet
		JNZ CheckPlayer2CollisionsY

	InactiveBullet2:			; If the current bullet is inactive, check the next one
	NotNearP2:					; Jump here if the bullet's xPos > 2
	ADD DI, BulletDataSize		; Loads the next bullet's data
	LOOP BulletPlayer2Col		; Loops to check the rest of the bullets with P2
	EndPlayer2Checks:			; Jump here if the player was hit, TEMPORARY

; Now to move the bullets
; Deactivate bullets out of bound
; Loops on P1's bullets first, then P2's bullets
	MOV CH, 0
	MOV CL, NumBullets
	LEA SI, P1Bullet1
	LEA DI, PlayerOne 			; Used to decrement the player's bulletsInArenaFlag
								; Assuming for now that each player has one bullet
							    ; TODO : CHANGE NUMBULLETS OR MAKE IT DEPEND ON DATA SIZE
	MOV AX, NumBullets			; Getting the number of bullets each player has, assuming that each player has 1/2 of the total bullets
	MOV BL, 2
	DIV BL
	MOV AH,AL					; Since AL is already used
	MOV BL, 0

MoveBullets:
	MOV AL, BYTE PTR [SI + 4]	; Get the current bullet's active flag
	CMP AL, 1					; Compare it to 1
	JNZ DontMove				; If the flag is not 1 (ie. inactive), skip the drawing
	MOV DL, BYTE PTR [SI]		; Current bullet xPos
	MOV DH, BYTE PTR [SI + 1]   ; Current bullet yPos

	CMP DL, 1
	JL DeactivateBullet
	CMP DL, 79
	JG DeactivateBullet

	CMP DH, 1
	JL DeactivateBullet
	CMP DH, 15
	JG DeactivateBullet

	JMP DontDeactivateBullet

	DeactivateBullet:
	MOV BYTE PTR [SI + 4], 0 ; Setting the bullet's active flag to false
	MOV BYTE PTR [SI], 40   ; Putting the inactive bullet in the middle
	MOV BYTE PTR [SI + 1], 12 
	DEC BYTE PTR [DI + 3]   ; Decrementing the player's bullets in arena
	JMP DontMove

	DontDeactivateBullet:
	
	MOV BL, BYTE PTR [SI + 2]	; Current bullet xVel
	MOV BH, BYTE PTR [SI + 3]	; Current bullet yVel

	ADD DL, BL
	ADD DH, BH

	; Might need some way to add a delay/ do this ever x*100 cycles
	MOV BYTE PTR [SI], DL		; Moving the bullet on the x
	MOV BYTE PTR [SI + 1], DH   ; Moving the bullet on the y

	DontMove:
	DEC AH						
	JNZ DontChangePlayer		; If the player has more bullets in the arena, continue checking
	ADD DI, PLAYER_DATA_SIZE	; Otherwise, check the next player
	MOV AX, NumBullets			; Reseting AL so it check for player2's bullets (the second half of the bullets)
	MOV BL, 2
	DIV BL
	MOV AH,AL					; Cleanup
	MOV AL,0
	MOV BL,0
	DontChangePlayer:
		ADD SI, BulletDataSize
		LOOP MoveBullets

	
	MOV BH,0 ; For some reason, without this line, the drawing goes haywire

	; After all the logic is done, Check if all bullets are out of the screen and both players have run out of bullets
	LEA SI, PlayerOne
	LEA DI, PlayerTwo
	CMP BYTE PTR [SI + 2], 0
	JNZ NotOutOfBullets
	CMP BYTE PTR [SI + 3], 0
	JNZ NotOutOfBullets
	CMP BYTE PTR [DI + 2], 0
	JNZ NotOutOfBullets
	CMP BYTE PTR [DI + 3], 0
	JNZ NotOutOfBullets
	CALL ResetRound
	NotOutOfBullets:

	RET
Logic ENDP

StaticLayout PROC 
	; this procedure draws the fixed layout { Till now => Chat & Players' Scores }

	CALL waitForNewVR
	ClearScreen

	; Chat Upper border
		MoveCursor 00H, 16d
		; Loading the character, number of loops and preparing the interrupt 
		 	MOV 			CX, 80
		 	MOV 			AH, 2
		 	MOV 			DL, '-'
 		;Draw the dashed line
		chatWindow:
			 INT 21h
		 	LOOP chatWindow

	; Players' Scores
	; This code Displays the first player's score
	MoveCursor 01H, 17d
	LEA SI, userName
	ADD SI, 2
	DisplayMessage SI
	DEC SI
	MOV AL, 01D
	ADD AL, [SI]
	MoveCursor AL, 17D
	DisplayMessage UserNameScore ; Length of UserNameScore is 11D
	Add Al, 11D
	MoveCursor Al, 17D
	DisplayChar PlayerOneScore
	MoveCursor 30H, 17d
	DisplayMessage userName2
	MOV AL, 30H 
	ADD AL, 11D ;This should be length of userName2 Which is fixed at Abdelrahman For Now
	DisplayMessage UserNameScore
	ADD AL, 11D
	DisplayChar PlayerTwoScore

	; Break dashed line
		MoveCursor 00H, 18d
 			MOV 			CX, 80
		 	MOV 			AH, 2
		 	MOV 			DL, '-'
 		;Draw the dashed line
		chatWindow2:
			 INT 21h
		 	LOOP chatWindow2
	; Chat Bottom border
		MoveCursor 00H, 23d
			 MOV 			CX, 80
			 MOV 			AH, 2
			 MOV 			DL, '-'
 		;Draw the dashed line
		dashline:
			 INT 21h
		 	LOOP dashline
	; Info message
		MoveCursor 03H, 24d
		DisplayMessage endGame1
		; Length of endGame1 Message is 23D, Length of userName2 is 11D
		; Length of engGame2 Message is 10D
		MOV AL, 03H
		ADD AL, 23D
		MoveCursor AL, 24D
		DisplayMessage userName2
		ADD AL, 11D
		MoveCursor AL, 24D
		DisplayMessage endGame2
	RET
StaticLayout ENDP

Draw PROC
	; Draw left Player first
	; Move the cursor to row 0AH, column 2, output "#"
	; Row 0BH, column 2, output
	; Row 0CH, column 2, output
	; Then the right Player
	; Same as the left Player but move to row 77D   

	
	; Flicker solution found at: https://stackoverflow.com/questions/43794402/avoid-blinking-flickering-when-drawing-graphics-in-8086-real-mode
	; Comment this when using emu8086
	; DL carries the X coordinate (Columns), DH carries the Y coordinate (Rows)
	LEA SI, PlayerOne
	MOV DL, BYTE PTR [SI]                    
	MOV CL , PLAYER_WIDTH
DrawLeftPlayerX:   
	MOV CH , PLAYER_HEIGHT
	MOV DH , BYTE PTR [SI + 1]
	DrawLeftPlayerY:
		MoveCursor     DL,DH
		DisplayChar    PlayerSymbol
		DEC DH    
		DEC CH
		CMP CH, 0        
		JNZ DrawLeftPlayerY
	DEC DL
	DEC CL
	CMP CL, 0     
	JNZ DrawLeftPlayerX

; Prepare to draw the right Player		
	LEA SI, PlayerTwo
	MOV DL, BYTE PTR [SI]                     
	MOV CL , PLAYER_WIDTH

DrawRightPlayerX:   
	MOV CH , PLAYER_HEIGHT
	MOV DH , BYTE PTR [SI + 1]
	DrawRightPlayerY:
		MoveCursor     DL,DH
		DisplayChar    PlayerSymbol
		DEC DH    
		DEC CH
		CMP CH, 0        
		JNZ DrawRightPlayerY
	INC DL
	DEC CL
	CMP CL, 0     
	JNZ DrawRightPlayerX

	; Looping over all bullets
	MOV CH, 0
	MOV CL, NumBullets
	LEA SI, P1Bullet1
DrawBullets:
	MOV AL, BYTE PTR [SI + 4]	; Get the current bullet's active flag
	CMP AL, 1					; Compare it to 1 
	JNZ DontDraw				; If the flag is not 1 (ie. inactive), skip the drawing
	; If the bullet is to be drawn, we need to move the cursor to its x and y positions
	; I'll store them in DL,DH 
	MOV DL, BYTE PTR [SI]
	MOV DH, BYTE PTR [SI + 1]
	MoveCursor DL, DH
	DisplayChar BulletSymbol
	
	DontDraw:
		ADD SI, BulletDataSize
		LOOP DrawBullets
		
	
; Preparing to draw the first obstacle
; Remember, The first byte is the xPos, the second byte is yPos, and the third byte is the height of the obstacle
	 MOV SI, OFFSET Block1		  	; Points at the first byte
	 MOV CX,0						; Clearing CX
	 MOV CL, BYTE PTR [SI + 2]	    ; Putting the height inside CL
 
	 MOV DL, BYTE PTR [SI]			; Putting the xPos in DL
	 MOV DH, BYTE PTR [SI] + 1		; Putting the yPos in DH

; Drawing the first block (Bottom up)
DrawBlockOne:
	 MoveCursor DL,DH				
	 DisplayChar BlockSymbol
	 DEC DH
	 LOOP DrawBlockOne


; Preparing to draw the second obstacle
; Remember, The first byte is the xPos, the second byte is yPos, and the third byte is the height of the obstacle
	 MOV SI, OFFSET Block2			; Points at the first byte
	 MOV CX,0						; Clearing CX
	 MOV CL, BYTE PTR [SI + 2]		; Putting the height inside CL
 
	 MOV DL, BYTE PTR [SI]			; Putting the xPos in DL
	 MOV DH, BYTE PTR [SI] + 1		; Putting the yPos in DH

; Drawing the second block (Bottom up)
DrawBlockTwo:
	 MoveCursor DL,DH
	 DisplayChar BlockSymbol
	 DEC DH
	 LOOP DrawBlockTwo

MOV SI, OFFSET Cactus
MOV CX, 0
MOV CL, CactusNum
DrawCactus:
	MOV DL, [SI] 					;xPos of the upper part of the cactus
	MOV DH, [SI+1]					;yPos of the upper part of the cactus

	PUSH CX 						; we save the value of the iterate of the outer loop to be able to use CX for the two loops 
	MOV CX, 3
	DrawCactusBlock:				; this loop draws the 3 parts of the cactus {Upper, Middle, Lower}
		MoveCursor DL, DH
		DisplayChar CactusSymbol
		INC DH
		LOOP DrawCactusBlock
	POP CX							; pop the outer loop iterator

	ADD SI, 2						; get the next cactus
	LOOP DrawCactus

	RET
Draw ENDP

; VR stands for "Vertical Refresh"
; Temporary solution until we get paging figured out
waitForNewVR PROC
 	 MOV DX, 3DAH
 
	;Wait for bit 3 to be zero (not in VR).
	;We want to detect a 0->1 transition.
	_WAITFOREND:
		IN AL, DX
		TEST AL, 08H
		JNZ _WAITFOREND

	;WAIT FOR BIT 3 TO BE ONE (IN VR)
	_WAITFORNEW:
		IN AL, DX
		TEST AL, 08H
		JZ _WAITFORNEW
	 

 	 RET
 	 waitForNewVR ENDP

; Gets input for both players locally
GetPlayerInput PROC
	; Checking input for P1
     PUSH CX
	 LEA SI, PlayerOne
     MOV CL, BYTE PTR [SI + 1]
     MOV AH,1
     INT 16H    
	 
	 CMP AH, 3Eh
	 JNZ continue
	 LEA SI, exiting
	 MOV BYTE PTR [SI], 1
	 JMP exitGame

	continue:
	; Checks if the user pressed F4
	; If so, goes back to the main menu
	; TODO: SHOW THE SCORE FOR 5 SECONDS THEN GO TO THE MAIN MENU/OPTIONS MENU
	; Note that choosing to play a game again after leaving the first one picks up exactly where the first left off
	; Might need to keep an array of initial values to re-initialize the game again.
	 CMP AH, 62D
	; So, you might wonder, why did I do this peculiar jump
	; Well, it seems that conditional jumps (JNZ, JG, etc...) have less range than unconditional jumps (JMP)
	; Since I converted the macro to a procedure and made it longer, the distance between the below jump and the label has grown
	; Check this for more information: https://stackoverflow.com/questions/39427980/relative-jump-out-of-range-by
	 JNZ SKIP_JUMP
	 JMP OptionsScreen
	SKIP_JUMP:
	; Checks if player1 pressed W
	; If so, decrements the y position of the Player (since the y axis points down)
     CMP AH, 17D
     JZ MoveUpP1
    
	; Same as the up check but increments the y position
     CMP AH, 31D
     JZ MoveDownP1
     JMP EndMoveCheckP1
     
MoveUpP1:    
	  ; Checks if PlayerOne is moving up & out of the game boundary
	   CMP CL, 1
	   JZ EndMoveCheckP1
       DEC CL
       JMP EndMoveCheckP1
MoveDownP1:     
	  ; Checks if PlayerOne is moving down & out of the game boundary
	   CMP CL, 15D
	   JZ EndMoveCheckP1
       INC CL                  
       JMP EndMoveCheckP1

EndMoveCheckP1:
       MOV BYTE PTR [SI + 1], CL

	; If P1 pressed D, check if they have any bullets in the arena
	; If so, ignore the input
	; Otherwise, CALL Player1Shoot
	CMP AH, 32D
	JNZ EndShootCheckP1 ; If the player didn't press D, don't check for bullets

	LEA SI, PlayerOne
	MOV AL, BYTE PTR [SI + 3]
	CMP AL, 0
	JNZ EndShootCheckP1 ; If the player has any bullets in the arena, don't shoot any more bullets
	MOV AL, BYTE PTR[SI + 2]
	CMP AL, 0
	JZ EndShootCheckP1  ; If the player has no bullets left to shoot, don't shoot
	CALL Player1Shoot
	EndShootCheckP1:
; ============================================================================================================================================;
	
	; Checking input for P2
	 LEA SI, PlayerTwo
     MOV CL, BYTE PTR [SI + 1]
     MOV AH,1
     INT 16H    

	; TODO: Check for player2 shooting, check if the player has any bullets in the arena
	; TODO: CHECK IF THE OTHER USER PRESSED F4

	; Checks if player2 pressed up arrow
	; If so, decrements the y position of the Player (since the y axis points down)
     CMP AH, 72D
     JZ MoveUpP2
    
	; Same as the up check but increments the y position
     CMP AH, 80D
     JZ MoveDownP2

     JMP EndInputP2
     
MoveUpP2:     
	  ; Checks if PlayerTwo is moving up & out of the game boundary
	   CMP CL, 1
	   JZ EndInputP2
       DEC CL
       JMP EndInputP2
MoveDownP2:   
	  ; Checks if PlayerTwo is moving up & out of the game boundary
	   CMP CL, 15D
	   JZ EndInputP2
       INC CL                  
       JMP EndInputP2

EndInputP2:
       MOV BYTE PTR [SI + 1], CL
       POP CX  


	; If P2 pressed the left arrow, check if they have any bullets in the arena
	; If so, ignore the input
	; Otherwise, CALL Player2Shoot
	CMP AH, 75D
	JNZ EndShootCheckP2 ; If the player didn't press D, don't check for bullets

	LEA SI, PlayerTwo
	MOV AL, BYTE PTR [SI + 3]
	CMP AL, 0
	JNZ EndShootCheckP2 ; If the player has any bullets in the arena, don't shoot any more bullets
	MOV AL, BYTE PTR[SI + 2]
	CMP AL, 0
	JZ EndShootCheckP2  ; If the player has no bullets left to shoot, don't shoot
	CALL Player2Shoot

	EndShootCheckP2:
	       
       FlushKeyBuffer
exitGame:
	   RET
ENDP              
	
; If so, sets the bullet's active flag to 1, changes the location so it's right in front of the player
; Otherwise, ignore the user's input
Player1Shoot PROC
	; Will be used to get the xPos and yPos of P1
	LEA SI, PlayerOne
	; Will be used to spawn the bullet in front of the player and set it as active
	LEA DI, P1Bullet1

	; AL = P1.xPos, AH = P1.yPos
	MOV AL, BYTE PTR [SI]
	MOV AH, BYTE PTR [SI + 1]
	DEC BYTE PTR[SI + 2]      ; Decrease the player's bullet stash by 1
	; Incrementing AL so that it's now in front of the player
	INC AL

	MOV BYTE PTR [DI],AL
	MOV BYTE PTR [DI + 1], AH
	MOV BYTE PTR [DI + 4], 1
	MOV BYTE PTR [SI+3],1

	MOV BYTE PTR [DI+2],2 
	MOV BYTE PTR [DI+3],0

	RET
Player1Shoot ENDP
Player2Shoot PROC
	; Will be used to get the xPos and yPos of P1
	LEA SI, PlayerTwo
	; Will be used to spawn the bullet in front of the player and set it as active
	LEA DI, P2Bullet1

	; AL = P2.xPos, AH = P2.yPos
	MOV AL, BYTE PTR [SI]
	MOV AH, BYTE PTR [SI + 1]
	DEC BYTE PTR [SI + 2]     ; Decrease the player's bullet stash by 1
	; Decrementing AL so that it's now in front of the player
	DEC AL

	MOV BYTE PTR [DI],AL		; Spawning the bullet in front of the player
	MOV BYTE PTR [DI + 1], AH
	MOV BYTE PTR [DI + 4], 1	; Setting the bullet's active flage
	MOV BYTE PTR [SI+3],1		; Setting the player's bulletsInArenaFlag
	MOV BYTE PTR [DI+2], -2		; reset the player xVel incase it was changed by an object
	MOV BYTE PTR [DI+3],0		; reset the player yVel incase it was changed by an object
	RET
Player2Shoot ENDP

ResetRound PROC
	; Load PlayerOne and Reset it's positions, Numbullets and bullet count
	LEA SI, PlayerOne
	MOV AL, LeftPlayerIitialCol
	MOV BYTE PTR [SI], AL
	MOV AL, PlayerInitialRow
	MOV BYTE PTR [SI + 1], AL
	MOV BYTE PTR [SI + 2], 3
	MOV BYTE PTR [SI + 3], 0
	; Load Player Two and Do the same
	LEA SI, PlayerTwo
	MOV AL, RightPlayerIitialCol
	MOV BYTE PTR [SI], AL
	MOV AL, PlayerInitialRow
	MOV BYTE PTR [SI + 1], AL
	MOV BYTE PTR [SI + 2], 3
	MOV BYTE PTR [SI + 3], 0
	; Now loop on all bullets in the arena that are active and deactivate them
	LEA DI, P1Bullet1 ; Starting with Bullet 1
	MOV CL, NumBullets
	MOV CH, 00D
	GetToWork:
	MOV BYTE PTR [DI], 40D
	MOV BYTE PTR [DI + 1], 12D
	MOV BYTE PTR [DI + 4], 0
	ADD DI, BulletDataSize
	LOOP GetToWork
	RET
ResetRound ENDP

WinScreen PROC 
	ClearScreen
	; Test 1
	MOV DL, 9D
	Loopy:
	MOV DH, 80D
	Loopx:
	DisplayChar " "
	DEC DH
	JNZ Loopx
	DEC DL
	JNZ Loopy
	MOV AH, AL
	ADD AH, 10
	Final:
	DisplayChar " "
	DEC DH
	JNZ Final

	MOV AL, 40D
	MoveCursor AL, 12D
	CMP PlayerOneScore, 35H         ; Check if the winner is P1
	JZ SKIP1
	JMP Player2
	SKIP1:
	LEA SI, userName
	DisplayMessage SI             ;I don't know why this won't work
	ADD AL, [SI - 1]
	MoveCursor AL, 12D
	DisplayMessage WinCondition
	ADD AL, 18D
	MoveCursor AL, 12D
	DisplayChar PlayerOnescore
	ADD AL, 1D
	MoveCursor AL, 12D
	DisplayMessage WinScore
	ADD AL, 4D
	MoveCursor AL, 12D
	DisplayChar PlayerTwoScore
	JMP SKIP2

	Player2:

	LEA SI, userName2
	;ADD SI, 2         ;userName2 is fixed for now but will be needed when it's variable
	DisplayMessage SI
	;ADD AL, [SI - 1]  ;Same as above
	ADD AL, 11D
	MoveCursor AL, 12D
	DisplayMessage WinCondition
	ADD AL, 18D
	MoveCursor AL, 12D
	DisplayChar PlayerOnescore
	ADD AL, 1D
	MoveCursor AL, 12D
	DisplayMessage WinScore
	ADD AL, 4D
	MoveCursor AL, 12D
	DisplayChar PlayerTwoScore
SKIP2:
	MOV AH, 02H
	INT 1AH
	MOV AL, DH
	ADD AL, 5D
Time:
	MOV AH, 02H
	INT 1AH
	CMP AL, DH
	JAE Time

	RET
WinScreen ENDP

; End file and tell the assembler what the main subroutine is
    END MAIN 

