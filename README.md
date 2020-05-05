# ipvalidation
ARM Assembly, Raspberry Pi 4.

An assembly language program that  validates an IP address given in
dotted quad notation, e.g. 192.168.10.1, and if valid, convert it to its corresponding 32-
bit representation. The IP address is supplied as a command line argument to the
program. Only one such argument should be supplied. A valid IP address must
only contain digits and periods. There should be exactly four numbers in the range 0-255 and
three periods separating them.

I first validate the command line argument. For any errors that are found, I display
an appropriate error message and quit. For valid addresses, I convert each of the
four numbers into an equivalent 8-bit pattern. I then combine these four patterns
together into the 32-bit representation. This sequence of 32 bits are then  printed out
on the screen.



![Image](https://github.com/KrikorHerlopian1/ipvalidation/blob/master/Screen%20Shot%202020-04-02%20at%201.44.25%20AM.png?raw=true)
