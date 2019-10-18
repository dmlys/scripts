set arname=%name%-%ver%-%vcver%-%1.zip
7z a -tzip %arname% lib bin include\log4cplus -x!bin\x*
