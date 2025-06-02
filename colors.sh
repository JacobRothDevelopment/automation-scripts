#!/bin/bash

# more here on colors:
# https://stackoverflow.com/q/5947742
# https://misc.flogisoft.com/bash/tip_colors_and_formatting

no_format='\e[0m'

# text, background, text light, background light
color_spots=(3 4 9 10)

# regular, bright, dim, underline, blink, reverse, hidden
effects=(0 1 2 4 5 7 8)

echo -e "Basic Colors ";

for((a=0;a<4;a++)); do
    color_spot=${color_spots[$a]};
    
    for((i=0;i<8;i++)); do
        
        for((j=0;j<6;j++)); do
            effect=${effects[$j]}
            color_string="\e[${effect};${color_spot}${i}m"
            echo -ne "${color_string}\\$color_string${no_format}";
            echo -ne "\t"
        done
        echo -ne "\n"
    done
done

echo "-----------------------------------------------------------------------------------------"
echo -e "Remove Formatting: \\$no_format${no_format}";
echo -e "Reference:         misc.flogisoft.com/bash/tip_colors_and_formatting${no_format}";

echo "-----------------------------------------------------------------------------------------"
echo -e "256 Colors";

for fgbg in 38 48; do
    for color in {0..255} ; do # Colors
        # Display the color
        spaces=$(printf "%8s" $color)
        printf "\e[${fgbg};5;%sm  %13s\e[0m" $color "\\e[38;5;${color}m"
        # Display 6 colors per lines
        if [ $((($color + 1) % 6)) == 4 ] ; then
            echo # New line
        fi
    done
    echo # New line
    
done