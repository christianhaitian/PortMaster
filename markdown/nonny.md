

**Features**

-   Can play both standard and multicolor nonograms
    -   Tracks completion status for all puzzles
    -   Tracks time spent on solving each puzzle and records best completion times
    -   Will save your progress on unfinished puzzles
    -   Optional hint system shows you which lines can be further solved
    -   No explicit limits on puzzle size or complexity
    -   Information panel shows details about the current puzzle and shows a snapshot of the puzzle grid
-   Can create both standard and multicolor nonograms
    -   Various drawing tools are available: draw lines, rectangles, and ellipses, or fill regions with a particular color
    -   Allows you to save title, author, and copyright information for each puzzle you create
-   Undo and redo commands can be used while solving or editing puzzles
-   Built-in solver and analysis tool
    -   Will solve most simple puzzles very quickly
    -   Can solve puzzles which require guessing or multi-line reasoning
    -   Can determine whether a puzzle has a unique solution
    -   Can determine whether a puzzle is solvable one line at a time
    -   Can find and display multiple solutions for a puzzle
-   File selector displays puzzle information and allows you to load and save puzzles anywhere and in various file formats
    -   Supports the  [.non format](http://www.lancaster.ac.uk/~simpsons/nonogram/fmt2)  used in Steven Simpson's solver, extended with multicolor support
    -   Supports the .g and .mk formats used in  [Mirek Olšák and Petr Olšák's solver](http://www.olsak.net/grid.html#English)
    -   Supports the .nin format used by  [Jakub Wilk's solver](https://jwilk.net/software/nonogram)


**Controls**

File Menu

Dpad nd and Left stick up/down = up and down
Dpad and Left stick left/right = move through navigation breadcrums
B = up one directory
Y = Home directory
A = Select file
X = Open saved

Puzzle Screen

Dpad and left stick = move selector
A = Select/Unselect
B = Mark X
Y = Toggle hints
X = Analyze and solve
L1/R1 = Zoom out/in
L2/R2 = cycle colors
Right stick = Move puzzle

**Developer Notes:**

Build instructions:

Standard cmake
