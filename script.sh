#!/bin/bash
# #Разработать скрипт, предоставляющий пользователю интерфейс для создания, 
# #инсталляции и просмотра личного crontab-файла пользователя;

fullPath=*
minutes=*
hours=*
days=*
mounths=*
dayOfWeek=*
fileName=tmpCrontab.txt
defaultToSave=/var/tmp/$fileName
statusScript=1
while [[ $statusScript > 0 ]]
do
	clear
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
	read statusScript
	case $statusScript in
	0)
		clear
		rm $defaultToSave
		exit 0
	;;
	1)
		echo -n "Enter minutes (0-59): "
		read minutes
	;;
	2)
		echo -n "Enter hours (0-23): "
		read hours
	;;
	3)
		echo -n "Enter days (1-31): "
		read days
	;;
	4)
		echo -n "Enter mounths (1-12): "
		read mounths
	;;
	5)
		echo -n "Enter day of week (0-6 where 0 is Sunday): "
		read dayOfWeek
	;;
	6)
		echo -n "Enter full path to exec file :"
		read fullPath 
	;;
	7)
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
	8)
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
	9)
		fullPath=*
		minutes=*
		hours=*
		days=*
		mounths=*
		dayOfWeek=*
	;;
	10)
		clear
		echo "File $fileName: "
		echo "`cat $defaultToSave`"
		read -n 1
	;;
	11)
		clear
		echo "The contents of a file was deleted"
		echo "" > $defaultToSave
		read -n 1
	;;
	12)
		clear
		echo "Crontab file was applying"
		crontab $defaultToSave
		read -n 1
	;;
	13)
		clear
		echo "Your crontabs"
		crontab -l
		read -n 1
	;;
	14)
		clear
		echo "The crontabs were removed"
		crontab -r
		read -n 1
	;;
	*)
		clear
		echo "Not correct"
		read -n 1
esac	
	clear
done