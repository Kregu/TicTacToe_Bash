#!/bin/bash
clear
echo
echo "Wellcome to 'TicTacToe'"
echo
echo "Controls:"
echo "0|1|2"
echo "3|4|5"
echo "6|7|8"
echo

read -p "Press Enter to Start"

declare -r EMPTY='_'
declare -r X='X'
declare -r O='O'
declare -r TIE='T'
declare -r NO_ONE='N'
declare -r BOARD_LEN=9
move=''

get_confirm() {
  while true
  do
    read x
    case "$x" in
      y | yes | Y | Yes | YES | "" )
        return 0;;
      n | no | N | No | NO )
        return 1;;
      *) echo "Please enter yes or no" ;;
    esac
  done
}

check_collision() {
	eval tmp=\${"row${coordinatesY[$move]}[${coordinatesX[$move]}]"}
    if [ "$tmp" == "_" ]; then	
        return 1
    else
        return 0
    fi
}


display_board() {
	clear
	printf "|%1s|%1s|%1s|\n" ${board[0]} ${board[1]} ${board[2]}
	printf "|%1s|%1s|%1s|\n" ${board[3]} ${board[4]} ${board[5]}
	printf "|%1s|%1s|%1s|\n" ${board[6]} ${board[7]} ${board[8]}
	echo
}


fillboard() {
	board=( $EMPTY $EMPTY $EMPTY $EMPTY $EMPTY $EMPTY $EMPTY $EMPTY $EMPTY )
}



humanPiece() {
	echo -n "Do you require the first move? Y/n: "
	if get_confirm ; then
		human=$X
	else
		human=$O
	fi
}

opponent() {
	if [[ $1 == $X ]]; then 
		echo "$O"
	else
		echo "$X"
	fi		
}


repeat() {
	echo -n "Do you want repeat Game? Y/n: "
	if get_confirm ; then
    return 0
  fi
		echo "Game over."
		exit
}



askHumanMove() {
	while true; do
		echo "Where will you move? 0..8"
		read move
		[[ ! "$move" =~ ^[0-8]$ ]] ||	break
	done
}


winner() {
	declare -r TOTAL_ROWS=8
	declare -i row

  win0=(0 1 2)
  win1=(3 4 5)
  win2=(6 7 8)
  win3=(0 3 6)
  win4=(1 4 7)
  win5=(2 5 8)
  win6=(0 4 8)
  win7=(2 4 6)

  for ((row=0; row < TOTAL_ROWS; row++)); do
    if [[ "${board[$((win$row[0]))]}" != "$EMPTY" ]] \
      && [[ "${board[$((win$row[0]))]}" == "${board[$((win$row[1]))]}" \
      && "${board[$((win$row[1]))]}" == "${board[$((win$row[2]))]}" ]]; then
      echo "${board[$((win$row[0]))]}"
      return
    fi
  done

  local position

  for position in "${board[@]}"; do
  	if [[ "$position" == "$EMPTY" ]]; then
  		echo $NO_ONE
  		return
  	fi
  done

  echo $TIE
}


computerMove() {
	move=0
	local found=false

	while [[ $found != true ]] && [[ $move -lt $BOARD_LEN ]]; do
		if [[ "${board[$move]}" == $EMPTY ]]; then
			board[$move]=$computer

			if [[ $(winner) == $computer ]]; then 
				found=true
			fi
			board[$move]=$EMPTY
		fi
		if [[ $found != true ]]; then
			move=$move+1
		fi
	done


	if [[ $found != true ]]; then
		move=0
		while [[ $found != true ]] && [[ $move -lt $BOARD_LEN ]]; do
			if [[ "${board[$move]}" == $EMPTY ]]; then
				board[$move]=$human
				if [[ $(winner) == $human ]]; then 
				  found=true
				fi
				board[$move]=$EMPTY
			fi
			if [[ $found != true ]]; then
				move=$move+1
			fi
		done
	fi


	if [[ $found != true ]]; then
		move=0
		local -i i=0

		best_moves=( 4 0 2 6 8 1 3 5 7 )
		while [[ $found != true ]] && [[ $i -lt $BOARD_LEN ]]; do
			move="${best_moves[$i]}"

			if [[ "${board[$move]}" == $EMPTY ]]; then
				found=true
				break
			fi
			i=$i+1
		done
	fi

}


while true; do
  fillboard

  humanPiece
  computer=$(opponent $human)

  turn=$X
  display_board

	while [[ $(winner) == $NO_ONE ]]; do

	  if [[ $turn == $human ]]; then

      askHumanMove
			while [[ ! "${board[$move]}" == "_" ]]; do
				echo "already occupied"
				askHumanMove
			done

      board[$move]=$human
    else
      computerMove
      board[$move]=$computer
		fi

		display_board
		turn=$(opponent $turn)

	done

	if [[ $(winner) == $computer ]]; then
		echo "Computer Win!"
	elif [[ $(winner) == $human ]]; then
		echo "Human Win!"
	else
		echo "It's tie!"
	fi

	if repeat; then
		fillboard
	fi

done

