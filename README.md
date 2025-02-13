# x86 MASM Wordle
A CLI-based Wordle game implemented with x86 MASM Assembly Language. Built using Kip Irvine's `Irvine32.inc` library. 
Follow these <a name="tag" href="https://www.asmirvine.com/gettingStartedVS2022/index.htm" target="_blank">instructions</a> to set up the required development environment to run the project.
## How To Play
First run the program in the required environment. You will then be prompted to choose either the single player or two player gamemode. 
### Single Player
If **single player** is selected you will be given six attempts to guess the chosen word that has been randomly selected from a word bank. The boxes corresponding to each character of the word will change color based on if the character you enetered is:\ * In the word and in the correct position\ * In the word but in the incorrect position\ * Not in the word\
### Two Player
If **two player** is selected a coin toss will initiate and the winner will guess first. The game will play the same as it does in single player mode for the first players turn. Player two will then get thei chance at guessing the randomly selected word. The winner is decided by who guessed their word in the fewest tries. If there is a tie a coin toss is initiated to determine the winner.


