
#!/bin/bash

#*******************************************************************************
# (\_/)   Author: Bradley Stradling
# (o.o)   Date of first revision: 10/17/20
#(")_(")  Lincense: https://unlicense.org/
#*******************************************************************************
# (\_/)   Script to parse a password on your local system to test it against
# (*.*)   the rockyou.txt wordlist or any other wordlist with one string per 
#(")_(")  line.
#*******************************************************************************

red=`tput setaf 1`
green=`tput setaf 2`
yellow=`tput setaf 3`
reset=`tput sgr0`

help() {
echo -e "Example run \"./Did_You_Get_Rocked.sh --wordlist \/usr\/share\/wordlists\/rock_you.txt --password abadpassword --minimum 6\""
} # need to check for escapes here

for ((i = 0 ; i <= 6 ; i++));
do
  if [[ -z "$i" ]]; then
    echo "Please pass all needed options and parameters. Use -h to see help. Exiting"
    exit 1
  fi
done

if [[ $1 == "-h" ]]; then
help
exit
fi

if [[ $1 == "--wordlist" ]]; then
wordlist="$2"
  else 
    echo "Not sure what option that was...exiting"
    exit 1
fi

if [[ $3 == "--password" ]]; then
password="$4"
  else 
    echo "Not sure what option that was...exiting"
    exit 1
fi

if [[ $5 == "--minimum" ]]; then
minimum="$6"
  else 
    echo "Not sure what option that was...exiting"
    exit 1
fi

if [[ -r ${wordlist} ]]; then
echo "Wordlist located succesfully at ${wordlist}"
  else
    echo "Unable to locate readable worklist at ${wordlist}. Exiting..."
    exit 1
fi


# generate array of password parsed as an array
for ((i = 0 ; i <= $((${#password}-${minimum})) ; i++));
do
  temp1="${password:$i}"
  pass_Array_Left[$i]=${temp1}
done

for ((i = 1 ; i <= $((${#password}-${minimum})) ; i++));
do
  temp2="${password::-$i}"
  pass_Array_Right[$i]=${temp2}
done

pass_Array_Combined=(${pass_Array_Left[@]})

for ((i = $((${#pass_Array_Left[@]}+1)); i <= $((${#pass_Array_Left[@]}+${#pass_Array_Right[@]})); i++));
do
  pass_Array_Combined[$i]="${pass_Array_Right[$(($i-${#pass_Array_Left[@]}))]}"
done

# test output the parsed password array combined
: '
for stringy_Boi in ${pass_Array_Combined[@]};
do 
  echo "${stringy_Boi} from combined array"
done
'

# this should be refactored to only pull the first field so files with a $string $hash can be used to save
# storage space
match_Found=0
while read line; do

  if [[ $#line < $minimum ]]; then
    echo "${line} is too short to match!"
    continue
  fi
  if [[ $line == $password ]]; then
    echo "${red}Looks like pwnage for sure as ${line} == ${password}!!!${reset}"
    match_Found=1
    break
  fi
  for password_Parsed in ${pass_Array_Combined[@]}; do
    if [[ $line == $password_Parsed ]]; then
      {
      echo "${yellow}Looks like partial pwnage as ${password} contains ${line}!!!${reset}"
      match_Found=1
      }
    fi
  done
done < ${wordlist}

if [[ "${match_Found}" == "0" ]]; then
  echo "${green}Looks like no matches were found! Congratz!${reset}"
fi
