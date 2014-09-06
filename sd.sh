#							   +----+----+----+----+
# 							   |    |    |    |    |
# Author: Mark David Scott Cunningham			   | M  | D  | S  | C  |
# 							   +----+----+----+----+
# Created: 2013-07-19
# Updated: 2014-06-04
#
#
#!/bin/bash

## How to math in bash
# https://www.shell-tips.com/2010/06/14/performing-math-calculation-in-bash/

clear; echo "$0 $@"
scale="scale=3"
dataFormat="%12s %12s %12s %12s\n"
statsFormat="%12s %12s %12s %12s %12s %12s %12s\n"
x=("$@") # Data Set
n=${#x[@]} # Population
echo

# Total
total=0 # Initialization
for (( i=0 ; i<$n ; i++ )); do
    total=$(echo "$scale;$total+${x[$i]}" | bc)
done

# Average
xbar=$(echo "$scale;$total/$n" | bc)

# Squared Residuals
for (( i=0 ; i<$n ; i++ )); do
    uhat[$i]=$(echo "$scale;${x[i]}-$xbar" | bc)
    sr[$i]=$(echo "$scale;(${x[$i]}-$xbar)^2" | bc)
done

# Sum of Squared Residuals
ssr=0 # Initialization
for (( i=0 ; i<$n ; i++ )); do
    ssr=$(echo "$scale;$ssr+${sr[$i]}" | bc)
done

# Variance
v=$(echo "$scale;$ssr/$n" | bc)

# Standard Deviation
sdpop=$(echo "$scale;sqrt($ssr/$n)" | bc)
sdsmp=$(echo "$scale;sqrt($ssr/($n-1))" | bc)

# Zscore (standard deviations from the mean)
for (( i=0 ; i<$n ; i++ )); do
    zscore[$i]=$(echo "$scale;${uhat[$i]}/$sdpop" | bc)
done

# Display all Data w/ Header
displayData(){
echo "POPULATION:"
printf "$dataFormat" "Data" "Z-score" "Uhat" "Uhat^2"
for (( i=0 ; i<$n ; i++ )); do
    printf "$dataFormat" "${x[$i]}" "${zscore[$i]}" "${uhat[$i]}" "${sr[$i]}"
done
echo
}

# Display Stats
displayStats(){
echo "SUMMARY STATISTICS:"
printf "$statsFormat" "Total" "N" "Mean" "SSR" "Var" "SD[pop]" "SD[smp]"
printf "$statsFormat" "$total" "$n" "$xbar" "$ssr" "$v" "$sdpop" "$sdsmp"
echo
}

# Confidence Intervals
displayConf(){
echo "CONFIDENCE INTERVALS:"
printf "$dataFormat" "68% Conf:" "$(echo "$scale;$xbar - $sdpop" | bc)" "- 1s +" "$(echo "$scale;$xbar + $sdpop" | bc )"
printf "$dataFormat" "95% Conf:" "$(echo "$scale;$xbar - $sdpop * 2" | bc)" "- 2s +" "$(echo "$scale;$xbar + $sdpop * 2" | bc)"
printf "$dataFormat" "99% Conf:" "$(echo "$scale;$xbar - $sdpop * 3" | bc)" "- 3s +" "$(echo "$scale;$xbar + $sdpop * 3" | bc)"
echo
}

# Output to screen
displayStats
displayConf
#displayData
