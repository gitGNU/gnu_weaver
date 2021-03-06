#!/bin/bash

# The source to be tested
cd tests/test_project
echo -ne "#include \"weaver/weaver.h\"\n
#include \"game.h\"\n
int main(int argc, char **argv){
  int num;
  surface *surf;
  num = atoi(argv[1]);
  awake_the_weaver(); // Initializing Weaver API
  surf = new_surface(num, num);
  XSync(_dpy, 1);
  DEBUG_TIMER_START();
  draw_rectangle_mask(surf, 0, 0, num, num);
  XSync(_dpy, 1);
  DEBUG_TIMER_STOP();
  may_the_weaver_sleep();
  return 0;\n
}" > src/game.c
make &> /dev/null

j=1
sum=0
first=0
last=0
echo -n "" > data.txt
while (( $j <= 10000 )); do
    echo $((${j}/100))"%"
    media=$(./test_project $j)
    echo -n ${j}" " >> data.txt
    echo ${media} >> data.txt
    sum=$((${sum}+${media}))
    j=$(($j+100))
done
first=$(./test_project 1)
last=$(./test_project 10000)
b=${first}
a=$(echo "scale=3; (${last}-${first})/10000" | bc)

echo "set output \"draw_rectangle_mask.eps\"" > ../gnuplot_instructions.txt
echo "set terminal postscript eps enhanced;" >> ../gnuplot_instructions.txt
echo "plot \"data.txt\" with lines;" >> ../gnuplot_instructions.txt

echo "\subsection{draw\_rectangle\_mask(a,b,c,d,e)}" >> ../tex/report.tex
echo "Function used for turning transparent a " >> ../tex/report.tex
echo "rectangular area in a surface. " >> ../tex/report.tex
gnuplot ../gnuplot_instructions.txt
mv draw_rectangle_mask.eps ../tex
echo "" >> ../tex/report.tex
echo "\includegraphics{tests/tex/draw_rectangle_mask.eps}" >> ../tex/report.tex
echo "" >> ../tex/report.tex
echo "This graph shows how many nanosseconds this computer needs to turn transparent a \$x \times s\$ surface." >> ../tex/report.tex
echo "" >> ../tex/report.tex
echo "The time, in nanosseconds is " >> ../tex/report.tex
echo "approximated by the function \$f(x)=${a}x+${b}\$." >> ../tex/report.tex
cd -
