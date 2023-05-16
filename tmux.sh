#!/bin/bash

#### DESCRIPTION: create, attach to tmux sessions


if [[ -z "$1" ]]
then
	echo ""
	echo "    USAGE: $0 [host_group]"
	echo "    EXAMPLE: $0 ceac"
	echo ""
	exit 3
fi

########## ========================================== ###########
########## ================ VARIABLES =============== ###########
########## ========================================== ###########
HOST_GROUP="$1"
SESSION_NAME="$HOST_GROUP"

#### define which hosts are in each group ####
#### todo: stick this in a config file, or grab from env variable, or service discovery or db ####
case $HOST_GROUP  in
    'dbm')
	HOSTS='cl1dbm103 cl1dbm104 cl2dbm101 cl3dbm101 cl4dbm101 cl5dbm102 cl5dbm103 cl6dbm101 cl7dbm101 cl8dbm101 cl9dbm101 cl10dbm101 cl11dbm101 cl12dbm101 cl13dbm101'
        ;;
    'dbs')
	HOSTS='cl1dbs103 cl1dbs104 cl2dbs101 cl3dbs101 cl4dbs101 cl5dbs102 cl5dbs103 cl6dbs101 cl7dbs101 cl8dbs101 cl9dbs101 cl10dbs101 cl11dbs101 cl12dbs101 cl13dbs101'
        ;;
    'dbla')
	HOSTS='baron bartel darga david duda erdos ernst evans gausel geller genov gutman ivanov kamsky mestel milos salov sebag teymor vera vovk zanan zoler'
        ;;
    'dbck')
	HOSTS='ckdbm102 ckdbs102'
        ;;
    'ccc')
        HOSTS='newman gpu101 ccc'
        ;;
    'ca')
        HOSTS='berg bkp101 emms web102 web103 web104 web105 web106 web107 web108 web111 web112 finkel feller filip flores flear furman hulak ward howell karpov varga visser'
        ;;
    'cb')
        HOSTS='arkell kubprod101 gpu101'
        ;;
    'ck')
        HOSTS='ckweb101 ckweb102 ckweb103'
        ;;
    'ceac')
        HOSTS="ceac-101 ceac-102 ceac-103 studer emms analysis101 antic arkell bhat ce101 ce102 ce103 ce104 hansen hebden hort hubner huzman hammer hawkins heberla hector henley hickl honfi krush larsen navara palo panno papp papin rensch newman ross so tromp watson wilder wells wely wolff insightslb101"
        ;;
    'chessx')
        HOSTS='chess2 chess3 chess4 chess5 chess6 chess7 chess8 chess9 chess10 chess11 chess12 chess13 chess14 chess15 chess16 chess17'
        ;;
    'chesskidx')
        HOSTS='chesskid3 chesskid4 chesskid5 chesskid6 chesskid7'
        ;;
    'deploy')
        HOSTS='deploy2 deploy101'
        ;;
     'elk')
        HOSTS='dreev elk101 elk-qa akiba'
        ;;
    'lb')
        HOSTS='larsen landa lastin lukov lb101 lb102 lb103 lb104 bkp101 berg'
        ;;
    'k8s')
        HOSTS='insightslb101 kubprod101 kubprod102 kubprod103 kubprod104 kubprod105 kubprod106 kubprod107 kubprod108 kubprod109 kubprod110 kubprod111 kubprod112 kubprod113 kubprod114 kubprod115'
        ;;
    'lc3')
        HOSTS='cklc101 akiba lc101 mega lc102 deploylc deploycklc rensch wely'
        ;;
    'lc2')
        HOSTS='cklc101 akiba lc101 mega lc102 deploylc deploycklc rensch wely'
        ;;
    'lc')
        HOSTS='cklc101 akiba lc101 mega lc102 deploylc deploycklc rensch wely'
        ;;
    'insights')
        HOSTS=''
        ;;
     'littlef')
        HOSTS='flear flores finkel furman filip feller'
        ;;
    'prvm')
        HOSTS='dake giri graf ribli vm101 jansa'
        ;;
    'web')
        HOSTS='web114 web115 web116 web117 web118 web119 web120 web121 web122 web123 web124 web125 web126 web127 web128 web129 web130 web131 web132 web133 web134 web135'
        ;;
  'others')
        HOSTS='pmm2 emms'
        ;;
  *)
esac

########## ========================================== ###########
########## ================ FUNCTIONS =============== ###########
########## ========================================== ###########
function connectToSession(){
	tmux a -t "${SESSION_NAME}"

}

function doesSessionExist(){
	check=$(tmux has-session -t "$SESSION_NAME" 2> /dev/null)
	if [[ $? -eq 1 ]]
	then
		#### session does not exist. create it ####
		tmux new-session -d -s "${SESSION_NAME}"

		#### connect to admin101 ####
		tmux send-keys -t "=${SESSION_NAME}:=0" "ssh -A root@admin101" Enter
		tmux send-keys -t "=${SESSION_NAME}:=${i}" "bash" Enter
		tmux send-keys -t "=${SESSION_NAME}:=${i}" "export EDITOR=vim" Enter
		tmux send-keys -t "=${SESSION_NAME}:=${i}" "cd /etc/puppet/files" Enter

		echo '0'
	else
		echo '1'
	fi
}

#### create a tmux session named 'SESSION_NAME' ####
function createSession(){
	
	#### check if session exists, if needed create it ####
	if [[ $(doesSessionExist) -eq 1 ]]
	then
		#### if session exists, break out of this function so we don't add duplicate windows ####
		return 0
	fi

	#### add a new window and connect to each host. optionally, run a command on each host ####
	for i in $HOSTS; do 

		#### connection string for reaching hosts ####
		CONNECTION_STRING="ssh -A root@${i}"

		#### create a new window in the tmux session ####
		tmux new-window -d -t "=${SESSION_NAME}" -n "${i}"

		#### enter key strokes into the window we just created, for example a connection string and the command 'date' ####
		tmux send-keys -t "=${SESSION_NAME}:=${i}" "${CONNECTION_STRING}" Enter
		tmux send-keys -t "=${SESSION_NAME}:=${i}" "bash" Enter
		tmux send-keys -t "=${SESSION_NAME}:=${i}" "export EDITOR=vim" Enter

	done


}

########## ========================================== ###########
########## ================ PROGRAM ================= ###########
########## ========================================== ###########
createSession
connectToSession

