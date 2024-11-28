#!/bin/bash
# Customize these variables:
current_year=$(date +%Y)
month=$1
desired_weekday=$2  # Monday (0 for Sunday, 2 for Tuesday, etc.)
desired_occurrence=$3  # 3rd occurrence
year=${4:-$current_year}

first_day_of_month=$(date -d "1 $month $year" +%s)
first_day_weekday=$(date -d "@$first_day_of_month" +%w)

weekday_diff=$((desired_weekday - first_day_weekday))
if (( weekday_diff < 0 )); then
    weekday_diff=$((weekday_diff + 7))
fi

day_of_month=$((weekday_diff + 1 + (desired_occurrence - 1) * 7))

final_date=$(date -d "$day_of_month $month $year" +%F)
echo "$final_date"
#echo "The $desired_occurrence of the weekday $desired_weekday of $month $year is: $final_date"

