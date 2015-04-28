# config-parser
Parser to read and write a config file. Done as an exercise/challenge
<br>
<br>
The file follow these rules
<br>
<br>
The file is broken up into named sections. The name of each section is enclosed by square brackets, and the opening bracket must be placed in column 0.
<br>
<br>
The first non-blank line in a file must be a section heading.
<br>
<br>
Each line is terminated by a CR/LF pair (on all platforms).
<br>
<br>
Whitespace between the opening bracket and the first non-whitespace character of the section name is discarded, as is any whitespace between the last character of the section name and the closing bracket. The following section names are all identical
<br>
<br>
Each non blank line of the file inside a section consists of a key and a value, separated by a colon. Whitespace surrounding the colon is discarded, so the following lines are identical
<br>
<br>
Key names within each section must be unique (but key names may be reused in different sections).
<br>
<br>
Each section name must be unique within the file.
<br>
<br>
Each key must begin in column zero.
<br>
<br>
Long lines may be wrapped by continuing them onto the next line and placing one or more whitespace characters in column zero.
<br>
<br>
When reading the file in, the combination CR/LF followed by whitespace is treated as if it were just the whitespace. Only the value component of a line may be wrapped.
<br>
<br>
The parser supports the following operations:
<br>
<br>
Create a parser object given a file name.
<br>
Get a string value associated with a given section and key names.
<br>
Get an integer value associated with a given section and key names.
<br>
Get a floating point value associated with a given section and key names.
<br>
Set a string value for a given section and key names, writing the new file to disk.
<br>
Set an integer value for a given section and key names, writing the new file to disk.
<br>
Set a floating point value for a given section and key names, writing the new file to disk.
<br>
