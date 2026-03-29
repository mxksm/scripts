# Quality of Life Scripts

## pdf

The ```pdf.zsh``` script helps open pdf files using sioyek, appends ```.pdf``` at the end so it doesn't have to be specified, and opening the ```main.pdf``` file by default if none specified.

## work

The ```work``` is an extensive script for writing homeworks/notes in latex/typst for specific courses.
Use ```work --help``` to see all options.

Example Usage:
+ ```git clone https://github.com/mxksm/templates.git ~/.templates```
+ ```mkdir -p university/4_year/2_semester/cs525```
+ Now using ```work -n cs525``` (or a substring of the course name ```work -n 525```) will automatically create a new latest homework folder, depending on the current latest homework, and also update the title to match the homework number.

Future Work:
+ Switch to using typst native templates instead of manually copying.
