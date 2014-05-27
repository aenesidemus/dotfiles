
   #!/bin/bash
      VERSION=0.2
         
# This script is in the public domain and comes with no warranty.   

# Current Parameters
# -m - change to previous month
# +m - change to next month
# reset - set the calendar to the current month and year.
# mm yyyy - print a menu the main calendar of mm and yyyy. 
# <no parameters> - print the menu with the saved month and year or
#                   function the same as 'reset'.


#----------------------------------------------------------------------------
# Global Variables
#----------------------------------------------------------------------------
# Choose our menu format
CAL_FORMAT=${CAL_FORMAT:-fluxbox}

# Yes not supported for fluxbox
# remove this check if fluxbox ever supports a dynamic menu.
if [ $CAL_FORMAT == "fluxbox" ]; then
# Included environment set for testing.
CAL_DYNAMIC="${CAL_DYNAMIC:-NO}"
else
CAL_DYNAMIC="${CAL_DYNAMIC:-YES}"
fi


# Working Files
#-------------------------------------
# Store our own name
CAL_SCRIPT="$HOME/.fluxbox/cal/updatecal.sh"
# Choose our calendar output file
CAL_FILE="$(dirname $CAL_SCRIPT)/calendar-menu"
# TODO: after thought mid development of v0.2, this file should be a settings
# file that gets sourced.  It should also be created if it doesn't exist.
CAL_ROOT="$(dirname $CAL_SCRIPT)/root"



#----------------------------------------------------------------------------
# Intialize Format Variables
#----------------------------------------------------------------------------
init_menu_format () {
# this function is designed to initialize our menu format
# currently we only support fluxbox.
case $CAL_FORMAT in
fluxbox)
BEGIN="[begin] (Calendar v$VERSION)"
SUBMENU="  [submenu] (%LABEL%)"
EXECUTE="    [exec] (%LABEL%) {%COMMAND%}"
NOP="    [nop] (%LABEL%)"
SUBEND="  [end]"
END="[end]"
;;
openbox)
# This is unsupported and untested but checked against openbox
# website and should function.  My particular concerns are with
# << and >> being in the id of the sub menus.
BEGIN="<openbox_pipe_menu><separator label=\"Calendar v$VERSION\" />"
SUBMENU="<menu id=\"calendar-%LABEL%\" label=\"%LABEL%\">"
EXECUTE="<item label=\"%LABEL%\">\"%COMMAND%\"</item>"
NOP="<item label=\"%LABEL%\" />"
SUBEND="</menu>"
END="</openbox_pipe_menu>"
;;
*)
echo "ERROR: unsupported menu format.  Try CAL_FORMAT=fluxbox $0 reset"
;;
esac
}
init_menu_format

#----------------------------------------------------------------------------
# Function Definitions
#----------------------------------------------------------------------------


# -------------------------------------

cal_get_root () {
# obtains the current month and year of the main calendar by grabbing it from
# the $CAL_ROOT file.  This function was made incase the format of the
# $CAL_ROOT file changes over multipule versions.  At the moment, it is the
# only line and the first line in the file.
cat $CAL_ROOT | sed -n 1p
}


cal_getCurrent () {
# Obsolete function to attempt to extract the month and year from the calendar
# menu file.  This is a very bad and messy function.  It is left here just in
# case I need to to canibalize it later.

# horrible check to see if I was given anything
if [ $1 ]; then
echo $1 $2
else
# rips out 3 months
MONTH_TXT=$(cat $CAL_FILE | sed -n -r -e 's@.*([A-Z][a-z]* [0-9][0-9][0-9][0-9]).*@\1@p' | gawk '{print $1}')
# crappy fix to got the middle, current month
MONTH_TXT2=$(echo $MONTH_TXT | gawk '{print $2}')
YEAR=$(cat $CAL_FILE | sed -n -r -e 's@.*([A-Z][a-z]* [0-9][0-9][0-9][0-9]).*@\1@p' | gawk '{print $2}')
# another crappy fix but end of year compliant.  appending 'sort -u' to the above would give 2 years.
YEAR2=$(echo $YEAR | gawk '{print $2}')
MONTH_COUNT=1
for TEST_MONTH in January February March April May June July August September October November December; do
if [ $MONTH_TXT2 == $TEST_MONTH ]; then
CURRENT_MONTH=$MONTH_COUNT
else
let "MONTH_COUNT++"
fi
done
echo $CURRENT_MONTH $YEAR2
fi
}

cal_get_previous () {
# print the previous month and year as "mm yyyy"
root_date=$(cal_get_root)

root_month="$(echo $root_date | gawk '{print $1}')" 
root_month="${root_month##0}"

root_year="$(echo $root_date | gawk '{print $2}')"

let "previous_month = root_month - 1"
if [ "$previous_month" -lt 1 ]; then
previous_month=12
let "previous_year = root_year - 1"
else
previous_year=$root_year
fi
echo "$previous_month $previous_year"
}

cal_get_next () {
# print the next month and year as "mm yyyy"
root_date=$(cal_get_root)

root_month="$(echo $root_date | gawk '{print $1}')" 
root_month="${root_month##0}"

root_year="$(echo $root_date | gawk '{print $2}')"

let "next_month = root_month + 1"
if [ "$next_month" -gt 12 ]; then
next_month=1
let "next_year = root_year + 1"
else
next_year=$root_year
fi
echo "$next_month $next_year"
}

cal_set_root () {
# Sets the root date in the $CAL_ROOT file.
case $1 in
reset)
if [ -f "$CAL_ROOT" ]; then
sed -i "1s@^.*@$(date '+%m %Y')@" $CAL_ROOT
else
date '+%m %Y' > $CAL_ROOT
fi
;;

-m)
if [ -f "$CAL_ROOT" ]; then
sed -i "1s@^.*@$(cal_get_previous)@" $CAL_ROOT
else
date '+%m %Y' > $CAL_ROOT
fi
;;

+m)
if [ -f "$CAL_ROOT" ]; then
sed -i "1s@^.*@$(cal_get_next)@" $CAL_ROOT
else
date '+%m %Y' > $CAL_ROOT
fi
;;

*)
# bash magic to get a month and year from $1 if this function is
# called as: cal_set_root 'mm yyyy'
month=${1%% [0-9]*}
year=${1##[0-9]* }
if [ $month == $year ]; then
year=$2
fi
# zeros on the front will output an error message. And the number
# will not be mathched.
if [[ ${month##0} -gt 0 && ${month##0} -lt 13 && \
${year##0} -gt 0 ]]; then 
if [ -f "$CAL_ROOT" ]; then
sed -i "1s@^.*@$month $year@" $CAL_ROOT
else
# lets initialize it for the user if they tried and failed to pass
# appropriate numbers into the script
sed -i "1s@^.*@$(date '+%m %Y')@" $CAL_ROOT
fi
else
# The root file does not exist and the user supplied a bad date.
date '+%m %Y' > $CAL_ROOT
fi
;;
esac
}


# -------------------------------------
cal_print_line () {
# Find and replace %LABEL% and %COMMAND% in a suplied string.

# Be sure to quote the string variable
original_string="$1"
# This value will replace %LABEL% in string
label="$2"
# This value will replace %COMMAND% in string
command="$3"

# If no label, print the string supplied as is. This supports
# a cleaner looking cal_print_calendar function.
if [ "$label" ]; then
# Replace all %LABEL% flags
temp_string=${original_string//"%LABEL%"/$label}
if [ "$command" ]; then
# Replace all %COMMAND% flags
final_string=${temp_string//"%COMMAND%"/$command}
else
final_string=${temp_string}
fi
else
final_string=${original_string}
fi

echo "$final_string"
}

cal_get_line () {
# This function prints a line from the output of 'cal'
# $1 - Line number
# $2 - month - mm
# $3 - year - yyyy

# Note! if $2 or $3 is undefined. cal prints the current month in the
# current year.

# if $2 is passed as "mm yyyy" e.g. cal_get_line "8 2009".  Then cal
# will still print a single month. $3 would not be needed at that point.

# if $2 is a single number and $3 is undefined, cal will print an
# entire year. sed will then grab a line that would have a week from
# 3 different months.

cal $2 $3 | sed -n ${1}p
}

cal_print_calendar () {
# Echos each of the 8 lines from the output of 'cal' as the %LABEL% to the
# cal_format_line command.

# TODO: this function may call another function to determine if each week
# is going to be a non operational line or if it is going to be a sub
# menu. This would be for an appointment keeping feature.

# See notes in cal_get_line for mm and yyyy specifics
# $1 - month - mm
# $2 - year - yyyy

#     Month Year   
cal_print_line "$NOP" "$(cal_get_line 1 $1 $2)"
# Su Mo Tu We Th Fr Sa
cal_print_line "$NOP" "$(cal_get_line 2 $1 $2)"
# print the weeks
cal_print_line "$NOP" "$(cal_get_line 3 $1 $2)"
cal_print_line "$NOP" "$(cal_get_line 4 $1 $2)"
cal_print_line "$NOP" "$(cal_get_line 5 $1 $2)"
cal_print_line "$NOP" "$(cal_get_line 6 $1 $2)"

# The last week may be line 6, 7, or 8 depending on the number of days
# in the month and what day the month starts.
lastline="$(cal_get_line 7 $1 $2)"
if [ "$lastline" ]; then
cal_print_line "$NOP" "$lastline"
fi

lastline="$(cal_get_line 8 $1 $2)"
if [ "$lastline" ]; then
cal_print_line "$NOP" "$lastline"
fi
}


#----------------------------------------
cal_print_dynamic_menu () {
cal_print_line "$BEGIN"

cal_print_line "$SUBMENU" "Tools"
cal_print_line "$EXECUTE" "Current Month" "$CAL_SCRIPT reset"
cal_print_line "$EXECUTE" "Reverse" "$CAL_SCRIPT -m"
cal_print_line "$EXECUTE" "Forward" "$CAL_SCRIPT +m"
cal_print_line "$SUBEND"

cal_print_line "$SUBMENU" "<<"
cal_print_calendar "$(cal_get_previous)"
cal_print_line "$SUBEND"

cal_print_calendar "$(cal_get_root)"

cal_print_line "$SUBMENU" ">>"
cal_print_calendar "$(cal_get_next)"
cal_print_line "$SUBEND"

cal_print_line "$END"
}

cal_print_static_menu () {
# Send everything into a file.  By using cat, we can prevent delays from
# writing to the file and fluxbox trying to display the file.
cat > $CAL_FILE << EOF1
$(cal_print_dynamic_menu)
EOF1
}

cal_print_menu () {
case $CAL_DYNAMIC in
YES)
cal_print_dynamic_menu
;;
NO)
cal_print_static_menu
;;
*)
cal_print_dynamic_menu
;;
esac
}


# --------------------------------------------
# Command Processing
# --------------------------------------------

COMMAND=$1
# Optional - may be supplied as one "mm yyyy" or as
# two commandline options.
DATE="$1 $2"
case $COMMAND in
reset)
cal_set_root reset
cal_print_menu
;;
-m)
cal_set_root -m
cal_print_menu
;;
+m)
cal_set_root +m
cal_print_menu
;;
*)
# Call the script with no parameters to print the menu with the date that
# is stored in the root file. Otherwise we want to print the menu with
# the supplied date.
if [[ ! -f "$CAL_ROOT" || "$DATE" ]]; then
cal_set_root $DATE
fi
cal_print_menu
;;
esac
