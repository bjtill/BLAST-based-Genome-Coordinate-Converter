#!/bin/bash
#October 09, 2025 BT

#Code to test checking for dependencies required for BGC Version 1.0

echo "Program Dependency Evaluator For: BGC Version 1.0"  

g=$(date +"%Y_%m_%d_%H_%M")

echo "Moving into a dedicated directory named DependencyTester_BGC_V1_0 appended with the date and time."  
mkdir DependencyTester_BGC_1_0_${g} 
cd DependencyTester_BGC_1_0_${g}

if command -v yad >/dev/null 2>&1 ; then
    echo "yad command found" >> tmpreportDTT
else
    echo "yad command not found. Try to install from a terminal window. Type the command and follow the instructions for installation. This is usually apt or snap, and may require administrator privileges." >> tmpreportDTT
fi

if command -v zenity >/dev/null 2>&1 ; then
    echo "zenity command found" >> tmpreportDTT
else
    echo "zenity command not found. Try to install from a terminal window. Type the command and follow the instructions for installation. This is usually apt or snap, and may require administrator privileges." >> tmpreportDTT
fi

if command -v curl >/dev/null 2>&1 ; then
    echo "curl command found" >> tmpreportDTT
else
    echo "curl command not found. Try to install from a terminal window. Type the command and follow the instructions for installation. This is usually apt or snap, and may require administrator privileges." >> tmpreportDTT
fi


if command -v tr >/dev/null 2>&1 ; then
    echo "tr command found" >> tmpreportDTT
else
    echo "tr command not found. Try to install from a terminal window. Type the command and follow the instructions for installation. This is usually apt or snap, and may require administrator privileges." >> tmpreportDTT
fi


if command -v blastn >/dev/null 2>&1 ; then
    echo "blast command found" >> tmpreportDTT
else
    echo "ncbi-blast+ not found. Try to install from a terminal window. Type the command and follow the instructions for installation. This is usually apt or snap, and may require administrator privileges." >> tmpreportDTT
fi

if command -v awk >/dev/null 2>&1 ; then
    echo "awk command found" >> tmpreportDTT
else
    echo "awk command not found. Try to install from a terminal window. Type the command and follow the instructions for installation. This is usually apt or snap, and may require administrator privileges." >> tmpreportDTT
fi

if command -v grep >/dev/null 2>&1 ; then
    echo "grep command found" >> tmpreportDTT
else
    echo "grep command not found. Try to install from a terminal window. Type the command and follow the instructions for installation. This is usually apt or snap, and may require administrator privileges." >> tmpreportDTT
fi

if command -v wc >/dev/null 2>&1 ; then
    echo "wc command found" >> tmpreportDTT
else
    echo "wc command not found. Try to install from a terminal window. Type the command and follow the instructions for installation. This is usually apt or snap, and may require administrator privileges." >> tmpreportDTT
fi

if command -v sed >/dev/null 2>&1 ; then
    echo "sed command found" >> tmpreportDTT
else
    echo "sed command not found. Try to install from a terminal window. Type the command and follow the instructions for installation. This is usually apt or snap, and may require administrator privileges." >> tmpreportDTT
fi

if command -v datamash >/dev/null 2>&1 ; then
    echo "datamash command found" >> tmpreportDTT
 
else
    echo "datamash command not found. Try to install from a terminal window. Type the command and follow the instructions for installation. This is usually apt or snap, and may require administrator privileges." >> tmpreportDTT
fi

if command -v printf >/dev/null 2>&1 ; then
    echo "printf command found" >> tmpreportDTT
 
else
    echo "printf command not found. Try to install from a terminal window. Type the command and follow the instructions for installation. This is usually apt or snap, and may require administrator privileges." >> tmpreportDTT
fi


echo "See the log file for a record of the dependency status." 

awk -v var=$g 'BEGIN{print "Program Dependency Evaluator For Program: BGC Version 1.0. Executed on:", var}1' tmpreportDTT > ${g}_BGC_Dependencies.log
rm tmpreportDTT 
