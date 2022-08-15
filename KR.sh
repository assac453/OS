#!/bin/bash
# #Разработать скрипт, предоставляющий пользователю интерфейс для создания,
# #инсталляции и просмотра личного crontab-файла пользователя;

# создание временного файла с уникальным именем
TMP="`mktemp /var/tmp/VAGscriptXXXX`"
echo -e "Name of script : $0 \nPID of script : $$ \nDate : `date +\"%d-%m-%Y %H:%M:%S (%Z)\"`" > $TMP

fileName=tmpCrontab.txt
defaultToSave=/var/tmp/$fileName
touch $defaultToSave
statusScript=1

# функции описания сигналов и их вызов
function sigUSR1() {
    trap 'ps -p $$ -o lstart,etime,time', SIGUSR1
}

function sigUSR2() {
    trap 'lsof -p $$', SIGUSR2
}

function sigQUIT() {
    trap '\
    clear
    echo -e "Was recieved sigQuit \nQuiting..."
    if [ -f $TMP ]
    then
        rm $TMP $defaultToSave
    fi
    exit 0
    ', 3
}

function sigTERM() {
    trap '\
    clear
    echo -e "Was recieved sigTERM \nQuiting..."
    if [ -f $TMP ]
    then
        rm $TMP $defaultToSave
    fi
    exit 0
    ', 15
}

function sigINT(){
    trap '\
    clear
    echo "Are you shure to want Exit? [y/n] : "
    read -n 1 n
    if [ "X$n" = "Xy" ]
        then
            clear
            exit 1
    fi' 2
    # 2 - Сигнал остановки процесса пользователем с терминала (CTRL + C)
}

sigINT
sigQUIT
sigTERM
sigUSR1 
sigUSR2

# Обработка ключей
while [ -n "$1" ]
do
    case "$1" in
        -d) option[0]=1 ;;
        -v) option[1]=1 ;;
        -s) option[2]=1 ;;
        -k) option[3]=1 ;;
        -h) option[4]=1 ;;
        *) clear;echo "$1 is not permissible option"; read -n 1 ;;
    esac
    shift
done
#-d - work
if [[ ${option[0]} = 1 ]]
then
    ScriptStartWork="start : `date +"%d.%m.%Y %H:%M:%S (%Z)"`"
    fileForTee="script_VAG.out"
    touch $fileForTee
    clear
    echo "The key -d was detected"
    echo "Choose what need to do with $fileForTee:"
    echo "1.Delete previous $fileForTee"
    echo "2.Continue input in $fileForTee"
    read -n 1 keyD
        if [[ $keyD = "1" ]]; then
            if [[ -f $fileForTee ]]; then
                rm $fileForTee
                touch $fileForTee
                exec &> >(tee $fileForTee)
                else
                echo "Can't delete file."
            fi
        elif [[ $keyD = "2" ]]; then
            if [[ -f $fileForTee ]]; then
                exec &> >(tee -a $fileForTee)
                else
                echo "Can't open file."
            fi
        else
            clear
            echo "Wrong choose. Deleting $fileForTee..."
            read -n 1
            if [[ -f $fileForTee ]]; then
                rm $fileForTee
            fi
        fi
fi

#-v - work
if [[ ${option[1]} = 1 ]]
then
    set -x
fi
#-s - work
if [[ ${option[2]} = 1 ]]
then
    clear
    exmps=$(ps -u | grep ".*$0.*" | wc -l)
    if [ $exmps -ne 0 ]
    then
        exmps=$(( $exmps - 2 ))
        echo "Count of starts scripts $0 : $exmps"
        read -n 1
        exit 3
    fi
fi
#-k - work
if [[ ${option[3]} = 1 ]]
then
    clear
    IFS=' ' read -r -a arrayOfPIDs <<< `pidof -x $0`
    for elementPID in "${arrayOfPIDs[@]}"
    do
        if [[ $elementPID == $$ ]]; then
        echo "Current script"
            echo " |"
            echo "\\|/ "
            echo " V"
        echo "`ps -o pid,ppid,uid,gid,tty,etime,command -p $elementPID`"
            echo " A "
            echo    "/|\\"
            echo " | "
        fi
    done
    unset "arrayOfPIDs[0]"
    for elementPID in "${arrayOfPIDs[@]}"
    do
        echo "`ps -o pid,ppid,uid,gid,tty,etime,command -p $elementPID`"
    done 
    echo -e "\nDo you want to determine the scripts?(y/n)"
        read -n 1 keyK
        case $keyK in
            "y" | "Y") clear
            echo "What i need to use with all scripts"
            echo "1.SIGKILL"
            echo "2.SIGTERM"
            read -n 1 keyKkill
            case $keyKkill in
                1) 
                    for elementPID in "${arrayOfPIDs[@]}"
                    do
                        kill -9 "$elementPID"
                    done 
                    kill -9 $$
                    ;;
                    
                2)
                    for elementPID in "${arrayOfPIDs[@]}"
                    do
                        kill -15 "$elementPID"
                    done 
                    kill -15 $$;;
            esac;;
            "n" | "N") 
            echo "Continue...";;
            *) 
            echo "Wrong. Try again.";;
        esac
    read -n 1
fi
#-h - work 
if [[ ${option[4]} = 1 ]]
then
    clear
    echo "About script:"
    echo "Developer: Vdovenko Aleksey"
    echo "`date +\"%d-%m-%Y %H:%M:%S (%Z)\"`"
    echo "Created temp file name: $TMP"
    echo "System name: `hostname`"
    echo "Current terminal name: `tty`"
    echo "EUID: $EUID, user: `id -un`"
    echo "RUID: `id -ru`, user: `id -run`"
    echo "EGID: `id -g`, group: `id -gn`"
    echo "RGID: `id -rg`, group: `id -rgn`"
    if [ $EUID == 0 ]; then echo "Warning: script was started by root"; fi
    echo "PID: $$"
    echo "Script file name: $0"
    # temp file to format output
    du -h $0 > tmp
    echo "Script size: `awk '{print $1}' tmp`"
    ls -l $0 > tmp
    echo "Access rights: `awk '{print $1}' tmp`"
    rm tmp
    echo "User process owner: `ps -o user= -p $$`"
    echo "Group process owner: `ps -o group= -p $$`"
    echo "Time last modification : `stat -c "%y" $0`"
        echo -e "\nWant to exit?\n(y/n)"
        read -n1 keyHchoice
        case $keyHchoice in
        "y" | "Y") clear
        exit 2;;
        "n" | "N") echo -e '\nContinue...';;
        *) echo -e "\nIncorrect answer, try again";;
        esac
fi

# глобальные переменные
fullPath=*
minutes=*
hours=*
days=*
mounths=*
dayOfWeek=*
# основной цикл (меню)
while [[ $statusScript > 0 ]]
do
    clear
    # если в переменной ничего не было записано
    # ей присваивается значение по умолчанию - *
    if [[ -z $fullPath ]]; then
    fullPath=*
    fi
    if [[ -z $minutes ]]; then
    minutes=*
    fi
    if [[ -z $hours ]]; then
    hours=*
    fi
    if [[ -z $days ]]; then
    days=*
    fi
    if [[ -z $mounths ]]; then
    mounths=*
    fi
    if [[ -z $dayOfWeek ]]; then
    dayOfWeek=*
    fi
    # если запущен с ключом -d, то переменная не пустая.
    # проверка на пустость переменной, если не пуста, то выводим
    if [[ ! -z $ScriptStartWork ]]; then
        echo "$ScriptStartWork"
    fi
    echo "You have : "
    echo "$minutes $hours $days $mounths $dayOfWeek $fullPath"
    echo "Entering:"
    echo "0.Exit"
    echo "1.Change minutes"
    echo "2.Change hours"
    echo "3.Change days"
    echo "4.Change mounths"
    echo "5.Change day of week"
    echo "6.Change path to file for exec"
    echo "7.Change all parameters"
    echo "8.Save changes"
    echo "9.Reset"
    echo "10.See my file"
    echo "11.Delete contents of a file"
    echo "12.Apply crontab"
    echo "13.Show applying crontabs"
    echo "14.Remove all crontabs"
    echo -n "Your choice: ";
    read choice
    case $choice in
    0)# 0.Exit
        #если существует файл $TMP, то удаляем его
        if [ -f $TMP ]
            then
            rm $TMP
        fi
        clear
        rm $defaultToSave
        #если запущен с ключом -d, то выводим время остановки
        #
        if [[ ${option[0]} = 1 ]]
        then
            echo "stop : `date +"%d-%m-%Y %H:%M:%S (%Z)"`"
        fi
        echo "Quiting..."
        statusScript=0
        read -n 1
    ;;
    1) # 1.Change minutes
        echo -n "Enter minutes (0-59): "
        read minutes
    ;;
    2) # 2.Change hours
        echo -n "Enter hours (0-23): "
        read hours
    ;;
    3) # 3.Change days
        echo -n "Enter days (1-31): "
        read days
    ;;
    4) # 4.Change mounths
        echo -n "Enter mounths (1-12): "
        read mounths
    ;;
    5) # 5.Change day of week
        echo -n "Enter day of week (0-6 where 0 is Sunday): "
        read dayOfWeek
    ;;
    6) # 6.Change path to file for exec
        echo -n "Enter full path to exec file :"
        read fullPath
    ;;
    7) # 7.Change all parameters

        clear
        echo -n "Enter minutes (0-59): "
        read minutes
        echo -n "Enter hours (0-23): "
        read hours
        echo -n "Enter days (1-31): "
        read days
        echo -n "Enter mounths (1-12): "
        read mounths
        echo -n "Enter day of week (0-6 where 0 is Sunday): "
        read dayOfWeek
        echo -n "Enter full path to exec file : "
        read fullPath
    ;;
    8) # 8.Save changes
        clear
        echo "Choose what need to do:"
        echo "1.Save only current command"
        echo "2.Add current command to file"
        saving=0
        read saving
        case $saving in
            1)
                echo "$minutes $hours $days $mounths $dayOfWeek $fullPath" > $defaultToSave
            ;;
            2)
                echo "$minutes $hours $days $mounths $dayOfWeek $fullPath" >> $defaultToSave
            ;;
            *)
                clear
                echo "Wrong."
                read -n 1
        esac
            unset saving
    ;;
    9) # 9.Reset
        fullPath=*
        minutes=*
        hours=*
        days=*
        mounths=*
        dayOfWeek=*
    ;;
    10) # 10.See my file
        clear
        echo "File $fileName: "
        echo "`cat $defaultToSave`"
        read -n 1
    ;;
    11) # 11.Delete contents of a file
        clear
        echo "The contents of a file was deleted"
        echo "" > $defaultToSave
        read -n 1
    ;;
    12) # 12.Apply crontab
        clear
        if ! crontab $defaultToSave ; then
        echo "Can't install crontab. Invalid format."
        else
            echo "Crontab file was applying."
        fi
        read -n 1
    ;;
    13) # 13.Show applying crontabs
        clear
        echo "Your crontabs"
        crontab -l
        read -n 1
    ;;
    14) # 14.Remove all crontabs
        clear
        echo "The crontabs were removed"
        crontab -r
        read -n 1
    ;;
    *) # defaults
        clear
        echo "Not correct"
        read -n 1
    esac
    clear
done
set +x
exit 0