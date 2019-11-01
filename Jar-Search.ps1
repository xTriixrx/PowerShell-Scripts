<#

.SYNOPSIS
Tool for tracking and searching jar files and inner components in a Windows file system.

.DESCRIPTION
Jar-Search currently has 4 different sets of functionality captured by the required parameter -Stype:
    - Search All        (SALL)
    - List Classes      (LCLS)
    - List Local Jars   (LLJR)
    - List System Jars  (LSJR)

All parameters (-Stype, -Class, -Jarfile, -Drives) are passed as strings, ensure to enclose with " " to ensure safety.

Search All (SALL) is dependant on -Class being passed a class name that may exist within a set of .jar files.

List Classes (LCLS) is dependant on -Jarfile being passed a jar file name that does exist within the current working directory.
    Note: This function does not have safety checking for if a file exists within the directory.

List Local Jars (LLJR) is not dependant on any other parameters and just returns the list of any jar files in the current working directory.

List System Jars (LSJR) is dependant on -Drives being passed 1 or more locations to search recursively from (such as a C or D drive).
    Note: This function does not have safety checking for if a file system exists before checking, be sure that the file systems passed exist.

.EXAMPLE
Jar-Search -Stype "SALL" -Class "ClassToSearch"

ClassToSearch is any class name without the .class extension.
.EXAMPLE
Jar-Search -Stype "LCLS" -Jarfile "somefilethatendswith.jar"
.EXAMPLE
Jar-Search -Stype "LLJR"
.EXAMPLE
Jar-Search -Stype "LSJR" -Drives "c:\"
.EXAMPLE
Jar-Search -Stype "LSJR" -Drives "c:\ d:\"
Note: Be sure to add space between multiple drives and following the colon with a backslash.

.NOTES
Author: Vincent Nigro
Last Updated: 11/1/2019
Version: 0.0.1

.LINK
https://github.com/xTriixrx

#>
function Jar-Search
{
    param(
        [Parameter(Mandatory=$True)]
        [ValidateNotNull()]
        [String]
        $Stype,
        [Parameter(Mandatory=$False)]
        [ValidateNotNull()]
        [String]
        $Class,
        [Parameter(Mandatory=$False)]
        [ValidateNotNull()]
        [String]
        $Jarfile,
        [Parameter(Mandatory=$False)]
        [ValidateNotNull()]
        [String]
        $Drives
    )

    $DATE = (Get-Date).ToString("MM-dd-yyyy");
    $TMPFILE =  $DATE + "_tmp.txt"
    $CMD = ""
    switch($Stype) {
        "SALL" {
            if (!$Class) {
                Write-Output "InvalidParameterException: Search All (SALL) requires -Class. 'Get-Help Jar-Search' for more information."
                return
            }
            $CMD = "forfiles /S /M *.jar /C `"cmd /c jar -tvf @file | findstr /C:`"" + $Class + "`" && echo @path`" > " + $TMPFILE      
        }
        "LCLS" {
            if (!$Jarfile) {
                Write-Output "InvalidParameterException: List Classes (LCLS) requires -Jarfile. 'Get-Help Jar-Search' for more information."
                return
            }
            $CMD = "jar -tvf " + $Jarfile + " | findstr /C:`"`.class`" > " + $TMPFILE
            
        }
        "LLJR" {
            $CMD = "dir /S /b *.jar > " + $TMPFILE
        }
        "LSJR" {
            if (!$Drives) {
                Write-Output "InvalidParameterException: List System Jars (LSJR) requires -Drives. 'Get-Help Jar-Search' for more information."
                return
            }
            $CMD = "dir " + $Drives + " /S /b | findstr /E /C:`".jar`" > " + $TMPFILE        
        }
    }
    cmd /c $CMD
    Get-Content -Path $TMPFILE
    Remove-Item $TMPFILE
}