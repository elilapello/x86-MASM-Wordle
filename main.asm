TITLE Final_Project_Lapello.asm

include irvine32.inc

clearEAX TEXTEQU <mov eax, 0>
clearEBX TEXTEQU <mov ebx, 0>
clearECX TEXTEQU <mov ecx, 0>
clearEDX TEXTEQU <mov edx, 0>
newline TEXTEQU <0Ah, 0Dh>

;//PROTOS
menu PROTO
displayError PROTO
coinFlip PROTO
enterTargetWord PROTO, firstUser:BYTE, firstRowMatrix:DWORD
enterGuessWord PROTO, matrix:DWORD, currentGuess:BYTE, firstUser:BYTE
wordsEqual PROTO, guess:DWORD
compareWords PROTO, target:DWORD, guess:DWORD
printRow PROTO, guess:DWORD
twoPlayerGameRound PROTO, coinFlipResultRound:BYTE
twoPlayerGame PROTO, coinFlipResult:BYTE, user1Score:BYTE, user2Score:BYTE
singlePlayerGame PROTO, singleMatrix:DWORD, wordList1:DWORD, wordList2:DWORD, wordList3:DWORD, wordList4:DWORD
singlePlayerGameRound PROTO

.data
twoPlayerMatrix BYTE 30 DUP(7) ;//matrix of size 30, first row is word to be guessed, remaining 5 are potential guesses
singlePlayerMatrix BYTE 30 DUP(7) ;//matrix of size 30, first row is word to be guessed from word list, remaining 5 are potential guesses
;//Note singlePlayerLsit1-3 contain 25 words, and 4 contains 19 words
singlePlayerList1 BYTE "AboutAbyssAdultAmpleAnkleArmorAromaBeganBlindBraidBrickBriskBumpyCabbyCableChildChiveClothClownCometCrateCrawlDaddyDanceDebit"
singlePlayerList2 BYTE "DoggyDoubtEagerEagleEarlyEightEjectEnemyExtraFableFacetFinalGableGradeGreenHorseIchorImageImbueInureKabobKafirKittyMacawMetal"
singlePlayerList3 BYTE "MimicMissyMoneyNicerOasisOwletPanelPanicPhasePhonePlacePurseRanchRifleRugbySabreScowlSevenSharkShirtSnakeSnarkSonnySpadeSpark"
singlePlayerList4 BYTE "SpeltStackStarkStateSteamStickStorySunnySwordTableTodayTouchTowelTradeTraceUdderWatchVistaZebra"

.code
main PROC ;//--------------------------------------------------------------------------------------------------------------------MAIN
call Randomize ;//seed random generator
mainStart:
INVOKE menu ;//display menu
cmp al, 1d ;//check for option 1
je singlePlayer
cmp al, 2d ;//check for option 2
je twoPlayer
cmp al, 3d ;//check for option 3
je exitMain

singlePlayer:
;//run single player game
INVOKE singlePlayerGame, OFFSET singlePlayerMatrix, OFFSET singlePlayerList1, OFFSET singlePlayerList2, OFFSET singlePlayerList3, OFFSET singlePlayerList4
call Crlf ;//newline
call WaitMsg ;//wait for user confirmation
call ClrScr ;//clear screen
jmp mainStart ;//return to main menu

twoPlayer:
INVOKE twoPlayerGame, 0, 0, 0
call Crlf ;//newline
call WaitMsg ;//wait for user confirmation
call ClrScr ;//clear screen
jmp mainStart ;//return to main menu

exitMain:
exit ;//end program
main ENDP

menu PROC ;//--------------------------------------------------------------------------------------------------------------------MENU
;//Desc: Displays a menu for the user to interact with
;//Requires: EDX for writestring, EAX for readdec
;//Returns: User's choice in EAX
.data
menuPrompt BYTE "WORDS Menu", newline,
				"--------------------", newline,
				"1. Single player gamemode.", newline,
				"2. Two player gamemode.", newline,
				"3. Exit", newline,
				"Enter choice: ", 0

.code
push edx ;//save edx
clearEDX 
clearEAX
mov edx, OFFSET menuPrompt ;//load edx with menuPrompt
call WriteString ;//display the menu
call ReadDec ;//read in user choice. choice is stored in eax
pop edx ;//restore edx

ret
menu ENDP

displayError PROC ;//------------------------------------------------------------------------------------------------------------ERROR
;//Desc: Displays an error message, waits for user confirmation
;//Requires: EDX for writestring
;//Returns: Nothing. Displays error

.data
errorPrompt BYTE "Error encountered. Please try again."

.code
push edx ;//save edx
mov edx, OFFSET errorPrompt ;//load edx with errorPrompt
call WriteString ;//display error
call Crlf ;//print newline
call WaitMsg ;//wait for user confirmation

ret
displayError ENDP

twoPlayerGame PROC, coinFlipResultGame:BYTE, user1Score:BYTE, user2Score:BYTE ;//------------------------------------------------2GAME
;//Desc: Runs the two player game version of words
;//Requires: twoPlayerGameRound procedure, coinFlipResult passed as 0 to start
;//Returns: runs a full cycle of twoPlayerGame

.data
quitPrompt BYTE "Enter 99 to quit the game. Enter anything else to continue: ", 0
gameOverPrompt1 BYTE "Game over!", newline, "Scores: ", newline, "|USER 1|: ", 0 
gameOverPrompt2 BYTE "|USER 2|: ", 0
user1WinsGame BYTE "User 1 wins!", 0
user2WinsGame BYTE "User 2 wins!", 0
tieGamePrompt BYTE "There is a tie! Flipping a coin.", newline, 0

.code
call coinFlip ;//flip a coin
mov coinFlipResultGame, bl ;//store result

round1:
mov edx, OFFSET quitPrompt ;//print option to quit
call WriteString
clearEAX
call ReadDec ;//read user choice
cmp al, 99 ;//if user enteers 99 quit the game
je gameOver ;//if not play normally
INVOKE twoPlayerGameRound, coinFlipResultGame ;//run a round
cmp coinFlipResultGame, 0d ;//check which user went first
je changeUser2ScoreR1 ;//change user score based on who played, if user 1 was first change user 2 score
jne changeUser1ScoreR1 ;//if user 2 was first change user 1 score

changeUser1ScoreR1:
cmp edx, 1d ;//check if user won
jne user1Round2 ;//if not switch to nexr user
inc user1Score ;//change user score
jmp user1Round2 ;//switch to next user

changeUser2ScoreR1:
cmp edx, 1d ;//check if user won
jne user2Round2 ;//if not switch to next user
inc user2Score ;//change user scoe
jmp user2Round2 ;//switch to next user

user2Round2:
mov edx, OFFSET quitPrompt ;//print option to quit
call WriteString
clearEAX
call ReadDec ;//read user choice
cmp al, 99 ;//if user enteers 99 quit the game
je gameOver ;//if not play normally
mov coinFlipResultGame, 1d ;//swap to user 2 for round 2
INVOKE twoPlayerGameRound, coinFlipResultGame
cmp coinFlipResultGame, 0d ;//make sure user 2 chose the target word
jne changeUser1ScoreR2 ;//change user 1 score

changeUser1ScoreR2:
cmp edx, 1d ;//check if user 1 won
jne user1Round3 ;//if not user 1 picks the next word
inc user1Score ;//up user 1 score
jmp user1Round3 ;//user 1 picks next word

user1Round2:
mov edx, OFFSET quitPrompt ;//print option to quit
call WriteString
clearEAX
call ReadDec ;//read user choice
cmp al, 99 ;//if user enteers 99 quit the game
je gameOver ;//if not play normally
mov coinFlipResultGame, 0d ;//swap to user 1 for round 2
INVOKE twoPlayerGameRound, coinFlipResultGame
cmp coinFlipResultGame, 0d ;//make sure user 1 chose target
je changeUser2ScoreR2 ;//change user 2 score

changeUser2ScoreR2:
cmp edx, 1d ;//check if user 2 won
jne user2Round3 ;//if not user 2 picks the next word
inc user2Score ;//if so up score
jmp user2Round3 ;//user 2 picks next word

user2Round3:
mov edx, OFFSET quitPrompt ;//print option to quit
call WriteString
clearEAX
call ReadDec ;//read user choice
cmp al, 99 ;//if user enteers 99 quit the game
je gameOver ;//if not play normally
mov coinFlipResultGame, 1d ;//swap to user 2 for round 3
INVOKE twoPlayerGameRound, coinFlipResultGame
cmp coinFlipResultGame, 0d ;//make sure user 2 chose target
jne changeUser1ScoreR3 ;//change user 1 score

changeUser1ScoreR3:
cmp edx, 1d ;//check if user 1 won
jne user1Round4 ;//if not user 1 picks the next word
inc user1Score ;//up user 1 score
jmp user1Round4 ;//user 1 picks next word

user1Round3:
mov edx, OFFSET quitPrompt ;//print option to quit
call WriteString
clearEAX
call ReadDec ;//read user choice
cmp al, 99 ;//if user enteers 99 quit the game
je gameOver ;//if not play normally
mov coinFlipResultGame, 0d ;//swap to user 1 for round 3
INVOKE twoPlayerGameRound, coinFlipResultGame
cmp coinFlipResultGame, 0d ;//make sure user 1 chose target
je changeUser2ScoreR3 ;//change user 2 score

changeUser2ScoreR3:
cmp edx, 1d ;//check if user 2 won
jne user2Round4 ;//if not user 2 picks the next word
inc user2Score ;//if so up score
jmp user2Round4 ;//user 2 picks next word

user2Round4:
mov edx, OFFSET quitPrompt ;//print option to quit
call WriteString
clearEAX
call ReadDec ;//read user choice
cmp al, 99 ;//if user enteers 99 quit the game
je gameOver ;//if not play normally
mov coinFlipResultGame, 1d ;//swap to user 2 for round 4
INVOKE twoPlayerGameRound, coinFlipResultGame
cmp edx, 1d
jne gameOver
inc user1Score
jmp gameOver

user1Round4:
mov edx, OFFSET quitPrompt ;//print option to quit
call WriteString
clearEAX
call ReadDec ;//read user choice
cmp al, 99 ;//if user enteers 99 quit the game
je gameOver ;//if not play normally
mov coinFlipResultGame, 0d ;//swap to user 1 for round 4
INVOKE twoPlayerGameRound, coinFlipResultGame
cmp edx, 1d
jne gameOver
inc user2Score
jmp gameOver

gameOver:
clearEAX 
mov edx, OFFSET gameOverPrompt1 ;//load first prompt
call WriteString ;//print it
mov al, user1Score ;//load user1Score
call WriteDec ;//print it
call Crlf ;//newline
mov edx, OFFSET gameOverPrompt2 ;//load second prompt
call WriteString ;//print it
mov al, user2Score ;//load user2Score
call WriteDec ;//print it
call Crlf ;//newline
mov al, user1Score ;//al holds user 1 score
cmp user2Score, al ;//check who won
je tieGame ;//if equal, tie
jl user1Wins ;//if less, user1Wins
jg user2Wins ;//if greater, user2Wins

tieGame:
mov edx, OFFSET tieGamePrompt ;//load prompt
call WriteString ;//print it
call coinFlip ;//flip a coin, result in ebx
cmp bl, 1d ;//check result
je user2Wins ;//1 for user 2
jne user1Wins ;//0 for user 1

user1Wins:
mov edx, OFFSET user1WinsGame ;//load winning prompt
call WriteString ;//print it
ret

user2Wins:
mov edx, OFFSET user2WinsGame ;//load winning prompt
call WriteString ;//print it
ret
twoPlayerGame ENDP

singlePlayerGame PROC, singleMatrix:DWORD, wordList1:DWORD, wordList2:DWORD, wordList3:DWORD, wordList4:DWORD ;//------------------------------------------------------------1GAME
;//Desc: runs the single player version of the words game
;//Requires: singlePlayerGameRound procedure, offset of singlePlayerMatrix passed, each word list's offset passed
;//Returns: A playable round of the words game

mov edi, singleMatrix ;//edi holds first row of matrix
mov eax, 4 ;//eax has 4 for random words list generation
call RandomRange
cmp al, 0d ;//check for group 1
je list1
cmp al, 1d ;//check for group 2
je list2
cmp al, 2d ;//check for group 3
je list3
cmp al, 3d ;//check for group 4
je list4

list1:
mov esi, wordList1 ;//esi has list 1 offset
mov eax, 25 ;//generate a random number from 0-24
call RandomRange
mov ebx, 5 ;//bl holds 5 to multiply eax by 5 for 5 byte in word
mul ebx ;//multiply
add esi, eax
mov ecx, 5 ;//set ecx to 5 for string copy
cld ;//direction forward
rep movsb ;//copy word to first row of matrix
INVOKE Str_ucase, singleMatrix ;//uppercase string
INVOKE singlePlayerGameRound ;//run a round of the game
jmp endGame 

list2:
mov esi, wordList2 ;//esi has list 1 offset
mov eax, 25 ;//generate a random number from 0-24
call RandomRange
mov ebx, 5 ;//bl holds 5 to multiply eax by 5 for 5 byte in word
mul ebx
add esi, eax
mov ecx, 5 ;//set ecx to 5 for string copy
cld ;//direction forward
rep movsb ;//copy word to first row of matrix
INVOKE Str_ucase, singleMatrix ;//uppercase string
INVOKE singlePlayerGameRound ;//run a round of the game
jmp endGame 

list3:
mov esi, wordList3 ;//esi has list 1 offset
mov eax, 25 ;//generate a random number from 0-24
call RandomRange
mov ebx, 5 ;//bl holds 5 to multiply eax by 5 for 5 byte in word
mul ebx ;//multiply
add esi, eax
mov ecx, 5 ;//set ecx to 5 for string copy
cld ;//direction forward
rep movsb ;//copy word to first row of matrix
INVOKE Str_ucase, singleMatrix ;//uppercase string
INVOKE singlePlayerGameRound ;//run a round of the game
jmp endGame 

list4:
mov esi, wordList1 ;//esi has list 1 offset
mov eax, 19 ;//generate a random number from 0-24
call RandomRange
mov ebx, 5 ;//bl holds 5 to multiply eax by 5 for 5 byte in word
mul ebx ;//multiply
add esi, eax
mov ecx, 5 ;//set ecx to 5 for string copy
cld ;//direction forward
rep movsb ;//copy word to first row of matrix
INVOKE Str_ucase, singleMatrix ;//uppercase string
INVOKE singlePlayerGameRound ;//run a round of the game
jmp endGame 

endGame:
ret
singlePlayerGame ENDP

singlePlayerGameRound PROC ;//---------------------------------------------------------------------------------------------------SINGLEGAME
;//Desc: runs a round of the single player game
;//Requires: all procedures required for core gameplay mechanics
;//Returns: a playable round of the single player game

.data
correctPrompt BYTE "Congratulations you have won the game!", 0
outPrompt BYTE "You are out of guesses.", 0

.code
guess1:
INVOKE enterGuessWord, OFFSET singlePlayerMatrix, 1d, 1d ;//take user guess
INVOKE compareWords, OFFSET singlePlayerMatrix, OFFSET singlePlayerMatrix + 5 ;//color the spaces of the word
INVOKE printRow, OFFSET singlePlayerMatrix + 5 ;//print the row
INVOKE wordsEqual, OFFSET singlePlayerMatrix + 5 ;//check if words are equal
cmp al, 1d ;//if word is equal
je wordIsCorrect ;//end
jne guess2 ;//if not move to next guess

guess2:
INVOKE enterGuessWord, OFFSET singlePlayerMatrix, 2d, 1d ;//take user guess
INVOKE compareWords, OFFSET singlePlayerMatrix, OFFSET singlePlayerMatrix + 10 ;//color the spaces of the word
INVOKE printRow, OFFSET singlePlayerMatrix + 10 ;//print the row
INVOKE wordsEqual, OFFSET singlePlayerMatrix + 10 ;//check if words are equal
cmp al, 1d ;//if word is equal
je wordIsCorrect ;//end
jne guess3 ;//if not move to next guess

guess3:
INVOKE enterGuessWord, OFFSET singlePlayerMatrix, 3d, 1d ;//take user guess
INVOKE compareWords, OFFSET singlePlayerMatrix, OFFSET singlePlayerMatrix + 15 ;//color the spaces of the word
INVOKE printRow, OFFSET singlePlayerMatrix + 15 ;//print the row
INVOKE wordsEqual, OFFSET singlePlayerMatrix + 15 ;//check if words are equal
cmp al, 1d ;//if word is equal
je wordIsCorrect ;//end
jne guess4 ;//if not move to next guess

guess4:
INVOKE enterGuessWord, OFFSET singlePlayerMatrix, 4d, 1d ;//take user guess
INVOKE compareWords, OFFSET singlePlayerMatrix, OFFSET singlePlayerMatrix + 20 ;//color the spaces of the word
INVOKE printRow, OFFSET singlePlayerMatrix + 20 ;//print the row
INVOKE wordsEqual, OFFSET singlePlayerMatrix + 20 ;//check if words are equal
cmp al, 1d ;//if word is equal
je wordIsCorrect ;//end
jne guess5 ;//if not move to next guess

guess5:
INVOKE enterGuessWord, OFFSET singlePlayerMatrix, 5d, 1d ;//take user guess
INVOKE compareWords, OFFSET singlePlayerMatrix, OFFSET singlePlayerMatrix + 25
INVOKE printRow, OFFSET singlePlayerMatrix + 25 ;//print the row
INVOKE wordsEqual, OFFSET singlePlayerMatrix + 25 ;//check if words are equal
cmp al, 1d ;//if word is equal
je wordIsCorrect ;//end
jne outofGuesses

wordIsCorrect:
mov edx, OFFSET correctPrompt ;//load success message
call WriteString ;//print it
jmp endGame ;//end game

outOfGuesses:
mov edx, OFFSET outPrompt ;//load failure message
call WriteString ;//print it
jmp endGame ;//end game

endGame:
ret
singlePlayerGameRound ENDP

twoPlayerGameRound PROC, coinFlipResultRound:BYTE  ;//---------------------------------------------------------------------------ROUND
;//Desc: runs the two player version of the words game
;//Requires: procedures for the core mechanics of the game
;//Returns: A two player version of words!

.data
correctWordPrompt BYTE "You have guessed the word successfully!", 0
outOfGuessesPrompt BYTE "You have ran out of guesses!", 0

.code
roundStart:
INVOKE enterTargetWord, coinFlipResultRound, OFFSET twoPlayerMatrix ;//prompt first user to enter word to be guessed
call ClrScr
jmp guess1 ;//move to guess 1

guess1:
INVOKE enterGuessWord, OFFSET twoPlayerMatrix, 1d, coinFlipResultRound ;//take first user guess
INVOKE compareWords, OFFSET twoPlayerMatrix, OFFSET twoPlayerMatrix + 5 ;//compare words
INVOKE printRow, OFFSET twoPlayerMatrix + 5 ;//print the row
INVOKE wordsEqual, OFFSET twoPlayerMatrix + 5 ;//result of this proc is 1 in eax if words are equal, 0 if not
cmp al, 1d ;//check if word is correct
je wordIsCorrect ;//if so end
jne guess2 ;//if not move to next guess

guess2:
INVOKE enterGuessWord, OFFSET twoPlayerMatrix, 2d, coinFlipResultRound ;//take first user guess
INVOKE compareWords, OFFSET twoPlayerMatrix, OFFSET twoPlayerMatrix + 10 ;//compare words
INVOKE printRow, OFFSET twoPlayerMatrix + 10 ;//print the row
INVOKE wordsEqual, OFFSET twoPlayerMatrix + 10 ;//result of this proc is 1 in eax if words are equal, 0 if not
cmp al, 1d ;//check if word is correct
je wordIsCorrect ;//if so end
jne guess3 ;//if not move to next guess

guess3:
INVOKE enterGuessWord, OFFSET twoPlayerMatrix, 3d, coinFlipResultRound ;//take first user guess
INVOKE compareWords, OFFSET twoPlayerMatrix, OFFSET twoPlayerMatrix + 15 ;//compare words
INVOKE printRow, OFFSET twoPlayerMatrix + 15 ;//print the row
INVOKE wordsEqual, OFFSET twoPlayerMatrix + 15 ;//result of this proc is 1 in eax if words are equal, 0 if not
cmp al, 1d ;//check if word is correct
je wordIsCorrect ;//if so end
jne guess4 ;//if not move to next guess

guess4:
INVOKE enterGuessWord, OFFSET twoPlayerMatrix, 4d, coinFlipResultRound ;//take first user guess
INVOKE compareWords, OFFSET twoPlayerMatrix, OFFSET twoPlayerMatrix + 20 ;//compare words
INVOKE printRow, OFFSET twoPlayerMatrix + 20 ;//print the row
INVOKE wordsEqual, OFFSET twoPlayerMatrix + 20 ;//result of this proc is 1 in eax if words are equal, 0 if not
cmp al, 1d ;//check if word is correct
je wordIsCorrect ;//if so end
jne guess5 ;//if not move to next guess

guess5:
INVOKE enterGuessWord, OFFSET twoPlayerMatrix, 5d, coinFlipResultRound ;//take first user guess
INVOKE compareWords, OFFSET twoPlayerMatrix, OFFSET twoPlayerMatrix + 25 ;//compare words
INVOKE printRow, OFFSET twoPlayerMatrix + 25 ;//print the row
INVOKE wordsEqual, OFFSET twoPlayerMatrix + 25 ;//result of this proc is 1 in eax if words are equal, 0 if not
cmp al, 1d ;//check if word is correct
je wordIsCorrect ;//if so end
jne outOfGuesses ;//if not also end

wordIsCorrect:
mov edx, OFFSET correctWordPrompt ;//print congratulations message
call WriteString
mov edx, 1d ;//edx holds 1 if user wins round
call Crlf ;//print newline
ret

outOfGuesses:
mov edx, OFFSET outOfGuessesPrompt ;//print congratulations message
call WriteString
mov edx, 0d ;//edx holds 0 if user loses round
call Crlf ;//print newline
ret
twoPlayerGameRound ENDP

coinFlip PROC ;//----------------------------------------------------------------------------------------------------------------FLIP
;//Desc: flips a coin to see if user1 or user2 goes first
;//Requires: eax for random generation and div, edx for writestring and div, ebx for div and to hold result
;//Returns: result of 0 in ebx for user1 first, and reuslt of 1 in ebx for user2 first

.data
user1WinsPrompt BYTE "User 1 has won the coin toss!", 0
user2WinsPrompt BYTE "User 2 has won the coin toss!", 0

.code
;//clear regs
clearEAX ;//eax for random range
clearEBX ;//ebx to divide and hold result
clearEDX ;//edx to hold remainder and print prompt

mov eax, 10000d ;//eax has large number for random range
call RandomRange
mov ebx, 2 ;//ebx is divisor
div ebx ;//divide number in eax
cmp dl, 0d ;//check for remainder of 0
je user1Wins ;//if so user 1 wins
cmp dl, 1d ;//check for remainder of 1
je user2Wins ;//if so user 2 wins

user1Wins:
mov edx, OFFSET user1WinsPrompt ;//load prompt
call WriteString ;//print prompt
call Crlf ;//print newline
mov ebx, 0 ;//ebx holds result
jmp coinTossEnd

user2Wins:
mov edx, OFFSET user2WinsPrompt ;//load prompt
call WriteString ;//print prompt
call Crlf ;//print newline
mov ebx, 1 ;//ebx holds result
jmp coinTossEnd

coinTossEnd:
ret
coinFlip ENDP

enterTargetWord PROC, firstUser:BYTE, firstRowMatrix:DWORD ;//-------------------------------------------------------------------TARGET
;//Desc: Takes a target word from the user and stores it in the top row of the twoPlayerMatrix, uses error checking
;//Requires: edx, eax, and ecx for readstring and writestring, 
;//          1 to be passed in firstUser for user 1 going first, 2 to be passed for vice versa,
;//          firstRowMatrix should have the starting address of twoPlayerMatrix (this is to fill the first row with the word to be guessed)
;//Returns: Top row of twoPlayerMatrix has the word to be guessed

.data
user1PromptTarget BYTE "|USER 1| Enter word to be guessed: ", 0
user2PromptTarget BYTE "|USER 2| Enter word to be guessed: ", 0
lengthErrorMsgTarget BYTE "|ERROR| Word entered is insufficient in length.", 0
nonLetterErrorMsgTarget BYTE "|ERROR| Word entered contains non-letter characters.", 0

.code
enterTargetWordStart:
cmp firstUser, 0d ;//check if user 1 is first
je user1First
cmp firstUser, 1d ;//check if user 2 is first
je user2First

user1First:
mov edx, OFFSET user1PromptTarget ;//load user1Prompt
call WriteString ;//print user1Prompt
mov edx, firstRowMatrix ;//edx has first row of matrix address to be filled with ReadString
clearEAX ;//eax will hold number of bytes entered
mov ecx, 7 ;//ecx has max number of bytes to be entered. it is equal to 7 for error checking
call ReadString ;//read user entered word
INVOKE Str_ucase, firstRowMatrix ;//make string all uppercase for error checking
jmp errorCheckLength

user2First:
mov edx, OFFSET user2PromptTarget ;//load user2Prompt
call WriteString ;//print user2Prompt
mov edx, firstRowMatrix ;//edx has first row of matrix address to be filled with ReadString
clearEAX ;//eax will hold number of bytes entered
mov ecx, 7 ;//ecx has max number of bytes to be entered. it is equal to 7 for error checking
call ReadString ;//read user entered word
INVOKE Str_ucase, firstRowMatrix ;//make string all uppercase for error checking
jmp errorCheckLength

;//check entered string for errors
errorCheckLength:
cmp eax, 5d ;//check length of string
jl lengthError ;//if too small dispay error
jg lengthError ;//if too big display error
mov ecx, 0d ;//reset ecx to check for non letters, ecx is a counter
jmp errorCheckNonLetters

errorCheckNonLetters:
cmp ecx, 5d
je errorChecksPassed
cmp byte ptr[edx], 41h ;//check if char is not a letter
jl nonLetterError ;//display error if so
cmp byte ptr[edx], 5Ah ;//do the same as above
jg nonLetterError
inc edx ;//move to next char
inc ecx ;//up counter to tell when whole string has been searched
jmp errorCheckNonLetters

lengthError:
mov edx, OFFSET lengthErrorMsgTarget ;//load error msg
call WriteString ;//print error msg
call Crlf ;//print newline
call WaitMsg ;//wait for user confirmation
call Crlf ;//print newline
jmp enterTargetWordStart ;//restart procedure

nonLetterError:
mov edx, OFFSET nonLetterErrorMsgTarget
call WriteString
call Crlf
call WaitMsg ;//wait for user confirmation
call Crlf ;//print newline
jmp enterTargetWordStart

errorChecksPassed:
ret ;//end proc. first row of matrix has word to be guessed
enterTargetWord ENDP

enterGuessWord PROC, matrix:DWORD, currentGuess:BYTE, firstUser:BYTE ;//---------------------------------------------------------GUESS
;//Desc: takes a word to be guessed from the user, currentGuess will be used to determine which row in the matrix to fill
;//Requires: esi to hold offset of matrix, offset of matrix to be passed as matrix, a number from 1-5 to be passed as currentGuess,
;//          result of coin flip passed as firstUser
;//Returns: row for current guess filled with guessed word

.data
user1PromptGuess BYTE "|USER 1| Enter guess: ", 0
user2PromptGuess BYTE "|USER 2| Enter guess: ", 0
lengthErrorMsgGuess BYTE "|ERROR| Word entered is insufficient in length.", 0
nonLetterErrorMsgGuess BYTE "|ERROR| Word entered contains non-letter characters.", 0

.code
;//check which guess the user is currently on
cmp currentGuess, 1d ;//check for guess 1
je firstGuess
cmp currentGuess, 2d ;//check for guess 2
je secondGuess
cmp currentGuess, 3d ;//check for guess 3
je thirdGuess
cmp currentGuess, 4d ;//check for guess 4
je fourthGuess
cmp currentGuess, 5d ;//check for guess 5
je fifthGuess

firstGuess: ;//row 1 of matrix is used to store target word
add matrix, 5d ;//move to row 2 of matrix 
jmp enterGuessWordStart
secondGuess:
add matrix, 10d ;//move to row 3 of matrix 
jmp enterGuessWordStart
thirdGuess:
add matrix, 15d ;//move to row 4 of matrix 
jmp enterGuessWordStart
fourthGuess:
add matrix, 20d ;//move to row 5 of matrix 
jmp enterGuessWordStart
fifthGuess:
add matrix, 25d ;//move to rwow 6 of matrix 
jmp enterGuessWordStart

enterGuessWordStart:
cmp firstUser, 0d ;//check if user1 was the first user
je user2Guesses ;//if so user2 will guess
cmp firstUser, 1d ;//check if user2 was the first user
je user1Guesses ;//if so user1 will guess

user1Guesses:
mov edx, OFFSET user1PromptGuess ;//load user1Prompt
call WriteString ;//print user1Prompt
mov edx, matrix ;//edx has the offset of the matrix row to be filled
clearEAX ;//eax will hold number of bytes entered
mov ecx, 7 ;//ecx has max number of bytes to be entered. it is equal to 7 for error checking
call ReadString ;//read user entered word
INVOKE Str_ucase, matrix ;//make string all uppercase for error checking
jmp errorCheckLength

user2Guesses:
mov edx, OFFSET user2PromptGuess ;//load user2Prompt
call WriteString ;//print user2Prompt
mov edx, matrix ;//edx has the offset of the matrix row to be filled
clearEAX ;//eax will hold number of bytes entered
mov ecx, 7 ;//ecx has max number of bytes to be entered. it is equal to 7 for error checking
call ReadString ;//read user entered word
INVOKE Str_ucase, matrix ;//make string all uppercase for error checking
jmp errorCheckLength

errorCheckLength:
cmp eax, 5d ;//check length of string
jl lengthError ;//if too small dispay error
jg lengthError ;//if too big display error
mov ecx, 0d ;//reset ecx to check for non letters, ecx is a counter
jmp errorCheckNonLetters

errorCheckNonLetters:
cmp ecx, 5d ;//check if whole word has been searched
je errorChecksPassed ;//if so error check is passed
cmp byte ptr[edx], 41h ;//check if char is not a letter
jl nonLetterError ;//display error if so
cmp byte ptr[edx], 5Ah ;//do the same as above
jg nonLetterError
inc edx ;//move to next char
inc ecx ;//up counter to tell when whole string has been searched
jmp errorCheckNonLetters

lengthError:
mov edx, OFFSET lengthErrorMsgGuess ;//load error msg
call WriteString ;//print error msg
call Crlf ;//print newline
call WaitMsg ;//wait for user confirmation
call Crlf ;//print newline
jmp enterGuessWordStart ;//restart procedure

nonLetterError:
mov edx, OFFSET nonLetterErrorMsgGuess ;//load prompt
call WriteString ;//print prompt
call Crlf ;//print newline
call WaitMsg ;//wait for user confirmation
call Crlf ;//print newline
jmp enterGuessWordStart ;//restart procedure

errorChecksPassed:
ret
enterGuessWord ENDP

compareWords PROC, target:DWORD, guess:DWORD ;//---------------------------------------------------------------------------------COMPARE
;//Desc: check if a character is in the target word, if it is in the correct place the char will be replaced with a 2.
;//      if it is not in the correct place but is in the word it will be replaced with 1, 
;//      and if it isnt in the word it will be replaced with 0.
;//      2 means color blue, 1 means color yellow, 0 means color black.
;//Requires: offset of target and guess row, eax, for comparisons, ebx as an offset, edx as an offset, ecx as a counter
;//Returns: row of matrix where word used to be is replaced by values based on whether chars were equal or not

push ebx ;//ebx will act as added offset

mov esi, guess ;//esi has offset of guess row
mov edi, target ;//edi has offset of top row
mov ebx, 0 ;//ebx will start as zero for checkInWord
mov ecx, 0 ;//ecx starts at 0
mov edx, 0 ;//edx will be added offset for edi

checkChars:
cmp ecx, 5 ;//check if whole word has been compared
je compareWordsEnd ;//if so end the procedure
mov al, byte ptr[esi] ;//load current char into al
cmp al, byte ptr[edi+edx] ;//check if it is equal
je colorBlue ;//if so it will be blue
jne checkInWord ;//if not check rest of word

checkInWord:
cmp ebx, 5 ;//check if whole word has been searched
je colorblack ;//if so char does not exist so color black
cmp al, byte ptr[edi+ebx] ;//cmp char to current char in target
je colorYellow ;//if it is equal color yellow
inc ebx ;//if not move to next target char
jmp checkInWord ;//continue


colorBlue:
mov byte ptr[esi], 2d ;//char is replaced with 2 for blue color
;//move to next char and inc loop counter
inc esi
inc ecx
inc edx
mov ebx, 0 ;//reset ebx
jmp checkChars ;//continue

colorYellow:
mov byte ptr[esi], 1d ;//char is replaced with 1 for yellow color
;//move to next char and inc loop counter
inc esi
inc ecx
inc edx
mov ebx, 0 ;//reset ebx
jmp checkChars ;//continue

colorblack:
mov byte ptr[esi], 0d ;//char is replaced with 0 for black color
;//move to next char and inc loop counter
inc esi
inc ecx
inc edx
mov ebx, 0 ;//reset ebx
jmp checkChars ;//continue

compareWordsEnd:
pop ebx
ret
compareWords ENDP

wordsEqual PROC, guess:DWORD ;//-------------------------------------------------------------------------------------------------EQUAL
;//Desc: compares traget word and guess word and checks if they are equal
;//Requires: offsets of target and guess words, eax to return a boolean value, 
;//          esi and edi to hold word offsets for cmpsb, ecx as a counter for repe
;//Returns: 1 in eax if words are equal, 0 if not

push edx ;//restore edx

mov esi, guess ;//esi holds guess word values
mov ecx, 5d ;//ecx is set till 5 for loop
clearEDX ;//edx will tally number of correct chars

compareLoop:
cmp byte ptr[esi], 2d ;//check if char was equal
jne notEqual ;//if not word is not equal
inc edx ;//if so increment tally
inc esi ;//move to next char
loop compareLoop ;//loop through word
jmp isEqual ;//if loop finishes word is equal

isEqual:
mov eax, 1 ;//if equal return 1
jmp wordsEqualEnd

notEqual:
mov eax, 0 ;//if not equal return 0
jmp wordsEqualEnd

wordsEqualEnd:
pop edx ;//restore edx
ret ;//return
wordsEqual ENDP

printRow PROC, guess:DWORD ;//---------------------------------------------------------------------------------------------------PRINT
;//Desc: checks the current guess with the target word. prints a row of the game with blue or yellow 
;//      colors to show the user what they got correct.
;//Requires: correct offset of current guess' row.
;//Returns: Prints the row in the game with the user's current guess

push eax
clearEAX
mov esi, guess
mov ecx, 0 ;//ecx will be a counter
;//set color names to values
blue = 1d
yellow = 14d
black = 0d
white = 15d

printRowStart:
mov al, 7Ch ;//print the first bar
call WriteChar
jmp printRowCheck ;//check the row

printRowCheck:
cmp ecx, 5d ;//see if whole row has been printed
je printRowEnd ;//if so end
cmp byte ptr[esi], 2d ;//check if blue
je printBlue
cmp byte ptr[esi], 1d ;//check if yellow
je printYellow
cmp byte ptr[esi], 0d ;//check if white
je printblack

printBlue:
mov al, blue+(blue*16) ;//eax holds 1 for set text color
call SetTextColor
mov al, 5Fh ;//print an underscore with color background
call WriteChar
mov al, white ;//reset color to black for seperating bar
call SetTextColor
mov al, 7Ch ;//eax has seperating bar char
call WriteChar ;//print it
inc ecx ;//inc counter
inc esi ;//move to next char
jmp printRowCheck ;//repeat

printYellow:
mov al, yellow+(yellow*16) ;//eax holds 1 for set text color
call SetTextColor
mov al, 5Fh ;//print an underscore with color background
call WriteChar
mov al, white ;//reset color to black for seperating bar
call SetTextColor
mov al, 7Ch ;//eax has seperating bar char
call WriteChar ;//print it
inc ecx ;//inc counter
inc esi ;//move to next char
jmp printRowCheck ;//repeat

printBlack:
mov al, black+(black*16) ;//eax holds 1 for set text color
call SetTextColor
mov al, 5Fh ;//print an underscore with color background
call WriteChar
mov al, white ;//reset color to black for seperating bar
call SetTextColor
mov al, 7Ch ;//eax has seperating bar char
call WriteChar ;//print it
inc ecx ;//inc counter
inc esi ;//move to next char
jmp printRowCheck ;//repeat

printRowEnd:
call Crlf ;//newline
pop eax ;//restore eax
ret
printRow ENDP

end MAIN
