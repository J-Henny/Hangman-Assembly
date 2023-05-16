TITLE FinalProject_Hurd.asm


;// Description: This Program performs a simple game of hangman with pre-existing words.
;// Author: Jack Hurd
;// Date Created: 12/09/21

include irvine32.inc

;//prototypes
;=================================================================================================
startGame PROTO pWelcome: PTR DWORD, pRules: PTR DWORD, pPlayOrQuit: PTR DWORD, pMenuOpt: PTR DWORD
;=================================================================================================
getWord PROTO pWordLengths: PTR DWORD, pTotalOffset: PTR DWORD, pCurWordLength: PTR DWORD
;=================================================================================================
errorMessage PROTO pErrorPrompt: PTR DWORD
;=================================================================================================
displayCurrentGuess PROTO pWordDisplay: PTR DWORD, pWhichToGuess: PTR DWORD, pWordOrGuess: PTR DWORD, pCurWordLength: PTR DWORD, pGuessesLeftPrmpt: PTR DWORD, pLetterGuessesLeft: PTR DWORD
;=================================================================================================
guessLetter PROTO pLetterGuessPrompt: PTR DWORD, pletterToGuess: PTR DWORD
;=================================================================================================
findLetter PROTO pWords: PTR DWORD, pCurWordLength: PTR DWORD, pTotalOffset: PTR DWORD, pCurIndex: PTR DWORD, pLetterToGuess: PTR DWORD
;=================================================================================================
updateWord PROTO pWordDisplay: PTR DWORD, pLetterToGuess: PTR DWORD, pIndex: PTR DWORD, pLetterBeenGuessedFlag: PTR DWORD, pNumLettersCorrect: PTR DWORD
;=================================================================================================
guessWord PROTO pGuessedWord: PTR DWORD, pWordGuessPrompt: PTR DWORD
;=================================================================================================
lose PROTO pYouLostPrompt: PTR DWORD
;=================================================================================================
won PROTO pYouWonPrompt: PTR DWORD
;=================================================================================================
checkIfCorrectWord PROTO pWords: PTR DWORD, pCurWordLength: PTR DWORD, pTotalOffset: PTR DWORD, pGuessedWord: PTR DWORD, pWordGuessedFlag: PTR DWORD
;=================================================================================================
displayWordGuessesLeft PROTO pIncorrectWordPrompt: PTR DWORD, pWordGuessesLeftPrmpt: PTR DWORD, pWordGuessesLeft: PTR DWORD
;=================================================================================================
resetValues PROTO pWordDisplay: PTR DWORD, pLetterGuessesLeft: PTR DWORD, pWordGuessesLeft: PTR DWORD, pNumLettersCorrect: PTR DWORD, pTotalOffset: PTR DWORD
;=================================================================================================
showStats PROTO pGamesWon: PTR DWORD, pGamesLost: PTR DWORD, pNumGamesWonPrmpt: PTR DWORD, pNumGamesLostPrmpt: PTR DWORD
;=================================================================================================

;//global constants
letterGuesses = 5d
wordGuesses = 3d
maxWordLength = 13d
numWords = 30d

;//macros
newline TEXTEQU<0ah, 0dh>


;//driver data

.data
;//terminal messages
welcome BYTE "Welcome to the hangman program.", 0h
rules BYTE "The rules are as follows:", newline,
			"You have 3 chances to guess the word. ", newline,
			"You have 5 guesses to guess letters. ", newline,
			"The game ends when you have used all of your word guesses.", newline,
			"If a correct letter is guessed, the letters will be filled into the word.", newline,
			"Once you run out of letter guesses, you may still use your word guesses.",newline,
			"Guessing a correct letter results in no penalty.", 0h
playOrQuit BYTE "Ready to play? Press 1 to Play or 0 to Quit. Or, press 2 to see the current running statistics.", 0h

errorPrompt BYTE "You selected an invalid option. ", 0h
wordDisplay BYTE "_ _ _ _ _ _ _ _ _ _ _ _ _", 0h
wordPrmpt BYTE "Word = ", 0h
guessesLeftPrmpt BYTE " letter guesses left.", 0h
whichToGuess BYTE "Do you wish to guess a letter or the whole word: (1 for letter, 2 for word) ", 0h
letterGuessPrompt BYTE "Guess a letter: ", 0h
wordGuessPrompt BYTE "Guess a word: ", 0h
youLostPrompt BYTE "You lost! Rip...", 0h
youWonPrompt BYTE "***YOU WON!!!***", 0h
incorrectWordPrompt BYTE "That is incorrect. You have ", 0h
wordGuessesLeftPrmpt BYTE " guesses left.",0h
numGamesWonPrmpt BYTE "Number of games won: ", 0h
numGamesLostPrmpt BYTE "Number of games lost: ", 0h


;//variables
gamesWon BYTE 0
gamesLost BYTE 0
words BYTE "SUPERMANPYTHONANXIETYCANOEDOBERMANFRAMEFROSTORANGEFRIGATEBEAUCERONPOSTALSHEETCABINETFLEETHANGMANMISSISSIPPIANDESTROYERMUTTFRUITESPRITPARISIANASSEMBLYCOLORADOANTELOPEMANICKOOLAIDCHRISTMASSANTAENGLANDDITTO"
wordLengths BYTE 8d, 6d, 7d, 5d, 8d, 5d, 5d, 6d, 7d, 9d, 6d, 5d, 7d, 5d, 7d, 13d, 9d, 4d, 5d, 6d, 8d, 8d, 8d, 8d, 5d, 7d, 9d, 5d, 7d, 5d
menuOpt BYTE ?
totalOffset BYTE 0
curWordLength BYTE ?
wordGuessesLeft BYTE 3d
letterGuessesLeft BYTE 5d
wordOrGuess BYTE ?
letterBeenGuessedFlag BYTE 0
wordGuessedFlag BYTE 0
letterToGuess BYTE ?
numLettersCorrect BYTE 0 ;// will be equal to wordlength when won.
curIndex BYTE 0
displayIndex BYTE 0
guessedWord BYTE ?

;//driver code
.code

main PROC
	
	call Randomize


	start:
	INVOKE startGame, ADDR welcome, ADDR rules, ADDR playOrQuit, ADDR menuOpt
	cmp menuOpt, 0
	je quit
	cmp menuOpt, 1
	je startTheGame
	cmp menuOpt, 2
	je showTheStats
	jmp oops
	
	showTheStats:
	INVOKE showStats, ADDR gamesWon, ADDR gamesLost, ADDR numGamesWonPrmpt, ADDR numGamesLostPrmpt
	jmp start
	
	startTheGame:
	INVOKE resetValues, ADDR wordDisplay, ADDR letterGuessesLeft, ADDR wordGuessesLeft, ADDR numLettersCorrect, ADDR totalOffset
	INVOKE getWord, ADDR wordLengths, ADDR totalOffset, ADDR curWordLength


	displayCurrentState:
	INVOKE displayCurrentGuess, ADDR wordDisplay, ADDR whichToGuess, ADDR wordOrGuess, ADDR curWordLength, ADDR guessesLeftPrmpt, ADDR letterGuessesLeft
	cmp wordOrGuess, 1
	je guessALetter
	cmp wordOrGuess, 2
	je guessAWord
	jmp oops

	guessALetter:
	INVOKE guessLetter, ADDR letterGuessPrompt, ADDR letterToGuess
	INVOKE findLetter, ADDR words, ADDR curWordLength, ADDR totalOffset, ADDR curIndex, ADDR letterToGuess
	cmp letterBeenGuessedFlag, 0
	je fail
	mov edx, OFFSET numLettersCorrect
	movzx eax, BYTE PTR [edx]
	mov edi, OFFSET curWordLength
	movzx ebx, BYTE PTR [edi]
	cmp eax, ebx
	je youWon
	mov al, 0
	mov edx, OFFSET letterBeenGuessedFlag
	mov BYTE PTR [edx], al ;// reset correctLetterFlag
	jmp displayCurrentState
	
	
	fail:
	mov edx, OFFSET letterGuessesLeft
	movzx eax, BYTE PTR [edx]
	cmp eax, 1 ;// out of guesses
	je youLost
	dec eax ;// one less letter guess available
	mov BYTE PTR [edx], al ;// lower number of guesses
	jmp displayCurrentState


	guessAWord:
	INVOKE guessWord, ADDR guessedWord, ADDR wordGuessPrompt
	INVOKE checkIfCorrectWord, ADDR words, ADDR curWordLength, ADDR totalOffset, ADDR guessedWord, ADDR wordGuessedFlag
	mov edx, OFFSET wordGuessedFlag
	movzx eax, BYTE PTR [edx]
	cmp eax, 0
	je incorrectWordGuess
	jmp youWon
	
	incorrectWordGuess:
	mov edx, OFFSET wordGuessesLeft
	movzx eax, BYTE PTR [edx]
	dec eax ;// one less word guess available.
	cmp eax, 0
	je youLost
	mov BYTE PTR [edx], al ;// if word guesses still left, can continue
	INVOKE displayWordGuessesLeft, ADDR incorrectWordPrompt, ADDR wordGuessesLeftPrmpt, ADDR wordGuessesLeft
	jmp displayCurrentState
	
	


	youLost:
	INVOKE lose, ADDR youLostPrompt
	mov edx, OFFSET gamesLost
	movzx eax, BYTE PTR [edx]
	inc eax
	mov BYTE PTR [edx], al
	INVOKE showStats, ADDR gamesWon, ADDR gamesLost, ADDR numGamesWonPrmpt, ADDR numGamesLostPrmpt
	jmp start



	youWon:
	INVOKE won, ADDR youWonPrompt
	mov edx, OFFSET gamesWon
	movzx eax, BYTE PTR [edx]
	inc eax
	mov BYTE PTR [edx], al
	INVOKE showStats, ADDR gamesWon, ADDR gamesLost, ADDR numGamesWonPrmpt, ADDR numGamesLostPrmpt
	jmp start
	

	oops:
	INVOKE errorMessage, ADDR errorPrompt
	jmp start


	quit:



exit
main ENDP

;//helper procs

startGame PROC pWelcome: PTR DWORD, pRules: PTR DWORD, pPlayOrQuit: PTR DWORD, pMenuOpt: PTR DWORD
;//Desc: Initiates the program.
;//Returns: User inputted menu option.
;//Recieves: Prompt messages.
;//Requires: Nothing.
;------------------------------------------------------------
	call clrscr
	mov edx, pWelcome
	call writeString
	call Crlf
	mov edx, pRules
	call writeString
	call Crlf
	mov edx, pPlayOrQuit
	call WriteString
	call Crlf
	call readHex
	mov edi, pMenuOpt
	mov BYTE PTR [edi], al
	ret
startGame ENDP
;-----------------------------------------------------------
errorMessage PROC pErrorPrompt: PTR DWORD
;//Desc: Displays error message.
;//Returns: Nothing.
;//Recieves: Prompt message.
;//Requires: Bad user input for this to be called.
;------------------------------------------------------------

	call ClrScr
	mov edx, pErrorPrompt
	call WriteString
	call WaitMsg
	
	ret
errorMessage ENDP
;-----------------------------------------------------------
getWord PROC pWordLengths: PTR DWORD, pTotalOffset: PTR DWORD, pCurWordLength: PTR DWORD
;//Desc: Selects a word from the word array to use for the game. It works by generating a number within the
;// bounds of the number of words, and cumulatively adds to the offset the length of the current word until we reach the selected word.
;//Returns: The offset of the word we chose and the length of that word.
;//Recieves: The lengths of all words.
;//Requires: nothing.
;------------------------------------------------------------
	
	mov eax, numWords
	call randomRange
	mov ecx, 0
	mov ecx, eax
	dec ecx
	mov edi, pWordLengths
	mov ebx, 0
	countOffset:
	mov esi, pTotalOffset
	mov bl, BYTE PTR [esi]
	mov al, BYTE PTR [edi]
	add bl, al
	mov BYTE PTR [esi], bl
	inc edi
	loop countOffset

	mov edx, pCurWordLength
	mov al, BYTE PTR [edi] ;putting length of selected word into variable for future use.
	mov [edx], al
	
	


	ret
getWord ENDP
;------------------------------------------------------------
displayCurrentGuess PROC pWordDisplay: PTR DWORD, pWhichToGuess: PTR DWORD, pWordOrGuess: PTR DWORD, pCurWordLength: PTR DWORD, pGuessesLeftPrmpt: PTR DWORD, pLetterGuessesLeft: PTR DWORD
;//Desc: Displays the current state of the game, including the number of letter guesses left, as well as the word with letters/underscores.
;// Recieves the next game decision from the user.
;//Returns: User decision to guess a letter or a word.
;//Recieves: Appropriate prompts.
;//Requires: Game to still not be over.
;------------------------------------------------------------
	
	call ClrScr
	mov esi, pCurWordLength
	movzx ecx, BYTE PTR [esi] ;// since 1 space for every 1 underscore, only need to loop the size of the word.
	mov edx, pWordDisplay 
	printWord:
	mov al, BYTE PTR [edx]
	call WriteChar ;// write letter/underscore
	inc edx
	mov al, BYTE PTR [edx]
	call WriteChar ;// write space
	inc edx
	loop printWord
	call WriteChar
	call WriteChar
	mov edx, pLetterGuessesLeft
	movzx eax, BYTE PTR [edx]
	call writeDec
	mov edx, pGuessesLeftPrmpt
	call writeString
	call Crlf
	mov edx, pWhichToGuess
	call writeString
	call readHex
	mov edi, pWordOrGuess
	mov BYTE PTR [edi], al


	ret
displayCurrentGuess ENDP
;-----------------------------------------------------------
guessLetter PROC pLetterGuessPrompt: PTR DWORD, pletterToGuess: PTR DWORD
;//Desc: Stores the letter entered by the user in memory.
;//Returns: The letter in memory.
;//Recieves: User input.
;//Requires: nothing.
;------------------------------------------------------------
	call clrScr
	mov edx, pLetterGuessPrompt
	call writeString
	call ReadChar
	cmp al, 41h
	jae withinLowerBound
	
	withinLowerBound:
	cmp al, 5Ah
	jbe isUpper
	
	sub al, 32d ;// convert to Upper
	
	isUpper:
	mov edi, pLetterToGuess
	mov BYTE PTR [edi], al


	ret
guessLetter ENDP
;-------------------------------------------------------------
findLetter PROC pWords: PTR DWORD, pCurWordLength: PTR DWORD, pTotalOffset: PTR DWORD, pCurIndex: PTR DWORD, pLetterToGuess: PTR DWORD
;//Desc: Iterates through the word with the entered letter to see if the letter is in the word or not. Uses a recursive approach.
;//Returns: Sets a flag if the letter was found in the word.
;//Recieves: The letter, and the word.
;//Requires: nothing.
;------------------------------------------------------------
	;//before anything, check if we've gone too far from the word length
	mov edi, pCurWordLength
	mov al, BYTE PTR [edi]
	mov esi, pCurIndex
	movzx ebx, BYTE PTR [esi]
	cmp al, bl
	je endOfWord
	;// if not, begin check.
	mov esi, pWords
	mov edi, pTotalOffset
	movzx eax, BYTE PTR [edi]
	add esi, eax ;// now at correct word
	mov edi, pCurIndex
	movzx eax, BYTE PTR [edi]
	add esi, eax ;// now at correct letter in word.
	mov al, BYTE PTR [esi]
	mov edx, pLetterToGuess
	cmp al, BYTE PTR [edx]
	je letterMatches
	;// if letter doesnt match, prepare for recursive call
	mov edx, pCurIndex
	movzx eax, BYTE PTR [edx]
	inc eax
	mov BYTE PTR [edx], al ;// index is now updated
	INVOKE findLetter, pWords, pCurWordLength, pTotalOffset, pCurIndex, pLetterToGuess ;// recursive call
	jmp endOfWord
	
	
	letterMatches:
	INVOKE updateWord, ADDR wordDisplay, ADDR letterToGuess, pCurIndex, ADDR letterBeenGuessedFlag, ADDR numLettersCorrect ;// use this index to know where we need to change.
	mov edx, pCurIndex
	movzx eax, BYTE PTR [edx]
	inc eax
	mov BYTE PTR [edx], al
	INVOKE findLetter, pWords, pCurWordLength, pTotalOffset, pCurIndex, pLetterToGuess ;// recursive call again after updating.
	
	endOfWord:
	mov edx, pCurIndex
	mov eax, 0
	mov BYTE PTR [edx], al

	ret
findLetter ENDP
;-------------------------------------------------------------
updateWord PROC pWordDisplay: PTR DWORD, pLetterToGuess: PTR DWORD, pIndex: PTR DWORD, pLetterBeenGuessedFlag: PTR DWORD, pNumLettersCorrect: PTR DWORD
;//Desc: updates the state of the display with the new letters.
;//Returns: The updated number of letters guessed correctly by the user.
;//Recieves: The original number of letters found from previous turns.
;//Requires: A letter guessed to be in the word selected for the round.
;------------------------------------------------------------
	mov esi, pWordDisplay
	mov edi, pIndex
	movzx eax, BYTE PTR [edi]
	add esi, eax
	add esi, eax ;// account for the spaces in the word display
	mov edx, pLetterToGuess
	mov bl, BYTE PTR [edx]
	mov BYTE PTR [esi], bl
	mov edi, pLetterBeenGuessedFlag
	mov al, 1 ;// flag that a guessed letter was found in the word.
	mov BYTE PTR [edi], al
	mov edx, pNumLettersCorrect
	movzx eax, BYTE PTR [edx]
	inc eax
	mov BYTE PTR [edx], al ;// update number of letters in word gotten.


	

	ret
updateWord ENDP
;-------------------------------------------------------------
lose PROC pYouLostPrompt: PTR DWORD
;//Desc: Displays a message to the user that they lost this round. :(
;//Returns: Nothing.
;//Recieves: Prompt message.
;//Requires: nothing.
;------------------------------------------------------------
	mov edx, pYouLostPrompt
	call writeString

	ret
lose ENDP
;-------------------------------------------------------------
won PROC pYouWonPrompt: PTR DWORD
;//Desc: Displays a message to the user that they won this round :)
;//Returns: nothing.
;//Recieves: Prompt messaage.
;//Requires: nothing.
;------------------------------------------------------------
	mov edx, pYouWonPrompt
	call writeString
	ret
won ENDP
;-------------------------------------------------------------
guessWord PROC pGuessedWord: PTR DWORD, pWordGuessPrompt: PTR DWORD
;//Desc: Gets the word the user guesses to check if its the correct word.
;//Returns: The guessed word in memory for future checking.
;//Recieves: Prompts, and user input.
;//Requires: nothing.
;------------------------------------------------------------
	call ClrScr
	mov edx, pWordGuessPrompt
	call WriteString
	mov edx, pGuessedWord
	mov ecx, maxWordLength
	call ReadString

	ret
guessWord ENDP
;-------------------------------------------------------------
checkIfCorrectWord PROC pWords: PTR DWORD, pCurWordLength: PTR DWORD, pTotalOffset: PTR DWORD, pGuessedWord: PTR DWORD, pWordGuessedFlag: PTR DWORD
;//Desc: Iteratively checks the user guessed word is the word for this round.
;//Returns: Sets a flag if the words are equivalent.
;//Recieves: The two words to check with each other.
;//Requires: nothing.
;------------------------------------------------------------
	mov esi, pWords
	mov edx, pCurWordLength
	mov edi, pTotalOffset
	movzx eax, BYTE PTR [edi]
	add esi, eax
	movzx ecx, BYTE PTR [edx]
	mov edi, pGuessedWord
	mov edx, 0 ;// holds number of matching letters
	check:
	mov al, BYTE PTR [esi]
	mov bl, BYTE PTR [edi]
	cmp bl, 41h
	jae upperTest1
	jmp makeUpper
	
	upperTest1:
	cmp bl, 5Ah
	jbe itsUpperCase
	jmp makeUpper
	
	makeUpper:
	sub bl, 32d
	
	itsUpperCase:
	
	cmp al, bl
	je sameLetter
	jmp wrongGuess
	
	sameLetter:
	inc edx
	
	nextLetter:
	inc esi
	inc edi
	loop check


	
	mov edi, pCurWordLength
	movzx eax, BYTE PTR [edi]
	cmp eax, edx
	jne wrongGuess
	
	sameWord:
	mov esi, pWordGuessedFlag
	mov eax, 1
	mov BYTE PTR [esi], al
	
	wrongGuess:
	
	
	ret
checkIfCorrectWord ENDP
;------------------------------------------------------------
displayWordGuessesLeft PROC pIncorrectWordPrompt: PTR DWORD, pWordGuessesLeftPrmpt: PTR DWORD, pWordGuessesLeft: PTR DWORD
;//Desc: Displays the number of word guesses left.
;//Returns: nothing.
;//Recieves: The correct prompts, and correct number of guesses left.
;//Requires: enough guesses to be able to invoke.
;------------------------------------------------------------
	mov edx, pIncorrectWordPrompt
	call writeString
	mov esi, pWordGuessesLeft
	mov eax, 0
	mov al, BYTE PTR [esi]
	call writeDec
	mov edx, pWordGuessesLeftPrmpt
	call writeString
	call crlf
	call waitmsg
	
	ret
displayWordGuessesLeft ENDP
;------------------------------------------------------------
resetValues PROC pWordDisplay: PTR DWORD, pLetterGuessesLeft: PTR DWORD, pWordGuessesLeft: PTR DWORD, pNumLettersCorrect: PTR DWORD, pTotalOffset: PTR DWORD
;//Desc: Resets necessary values at the beginning of the next round, so everything works fine the next round.
;//Returns: Resetted values into memory.
;//Recieves: Necessary variables that were changed from the previous round
;//Requires: The user must play again if we are invoking this.
;------------------------------------------------------------

	
	mov esi, pLetterGuessesLeft ;// resetting variables
	mov eax, 5d
	mov BYTE PTR [esi], al
	mov esi, pWordGuessesLeft
	mov eax, 3d
	mov BYTE PTR [esi], al
	mov esi, pNumLettersCorrect
	mov eax, 0
	mov BYTE PTR [esi], al
	mov esi, pTotalOffset
	mov BYTE PTR [esi], al
	
	mov ecx, maxWordLength ;// resetting display
	mov esi, pWordDisplay
	clearIt:
	mov eax, '_'
	mov BYTE PTR [esi], al
	inc esi
	mov eax, ' '
	mov BYTE PTR [esi], al
	inc esi
	loop clearIt
	

	ret
resetValues ENDP
;------------------------------------------------------------
showStats PROC pGamesWon: PTR DWORD, pGamesLost: PTR DWORD, pNumGamesWonPrmpt: PTR DWORD, pNumGamesLostPrmpt: PTR DWORD
;//Desc: Displays running statistics from past games
;//Returns: nothing.
;//Recieves: Necessary prompts, and proper number of games won/lost.
;//Requires: Rounds to be continuously running. Values are reset once the user quits.
;------------------------------------------------------------
	call crlf
	mov edx, pNumGamesWonPrmpt
	call writeString
	mov esi, pGamesWon
	mov al, BYTE PTR [esi]
	call writeDec
	call crlf
	mov edx, pNumGamesLostPrmpt
	call writeString
	mov esi, pGamesLost
	mov al, BYTE PTR [esi]
	call writeDec
	call crlf
	call waitmsg
	

	ret
showStats ENDP


end main