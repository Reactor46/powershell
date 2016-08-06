<#
.SYNOPSIS

Runs a Java program.

.DESCRIPTION

Runs a Java program that has already been compiled. The CLASSPATH used
is a CONSTANT declared in the 'Variable/constant declarations' section.
This may have to be updated depending upon the program being run.

.PARAMETER JavaFilename

(optional) the Java program to run in the format of
<programname>.java. If a parameter is not supplied, an internal
function is invoked to obtain the Java program.

.EXAMPLE

./run_java.ps1

As a parameter has not been supplied, an internal function is invoked
to obtain the Java filename.

.EXAMPLE

./run_java.ps1 myfile.java

The Java program to execute is supplied as a parameter. Error message:

Error: file myfile.java not found to run

is displayed if, for example, file 'myfile.java' cannot be found or
doesn't exist.

.EXAMPLE

./run_java.ps1 -JavaFilename myfile.java

Using a named parameter to supply the Java program to execute.

.INPUTS

None. No .NET Framework types of objects are used as input.

.OUTPUTS

None. No .NET Framework types of objects are output from this script.

.NOTES

File Name    : run_java.ps1
Author       : Ian Molloy
Last updated : 2016-06-14

#>

[cmdletbinding()]
Param (
   [parameter(Position=0,
              Mandatory=$false)]
   [String]
   $JavaFilename
) #end param

  trap { "An error: $_"; exit 1;}

#################################################
#region ********** function Get-Script-Info **********
##=============================================
## Function: Get-Script-Info
## Created: 2013-05-25
## Author: Ian Molloy
## Arguments: none
##=============================================
## Purpose: displays the script name and folder from
## where the script is running from.
## Returns: N/A
##=============================================
function Get-ScriptInfo()
{
   Write-Verbose -Message "Displaying script information";

   if ($MyInvocation.ScriptName) {
       $scriptname = Split-Path -Leaf $MyInvocation.ScriptName;
       $scriptdir = Split-Path -Parent $MyInvocation.ScriptName;
       Write-Output "`nExecuting script ""$scriptname"" in folder ""$scriptdir""";
   } else {
       $MyInvocation.MyCommand.Definition;
   }

}
#endregion ********** end of function Get-Script-Info **********

#------------------------------------------------------------------------------

#region ********** Function getFilename **********
#* Function: getFilename
#* Created: 2016-06-12
#* Author: Ian Molloy
#*
#* Arguments:
#* title - the title displayed on the dialog box window.
#*
#* See also:
#* OpenFileDialog Class.
#* http://msdn.microsoft.com/en-us/library/system.windows.forms.openfiledialog.aspx
#* =============================================
#* Purpose:
#* Invokes the .NET 'ShowDialog' method enabling
#* the user to select a filename.
#* =============================================
function Get-Filename() {
[cmdletbinding()]
Param (
        [parameter(Mandatory=$true,
                   HelpMessage="ShowDialog box title")]
        [ValidateNotNullOrEmpty()]
        [String]$title
      ) #end param

  trap { "An error: $_"; exit 1;}

  Write-Verbose -Message "Invoking function to obtain the Java filename to compile";

  [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null;
  [System.Windows.Forms.OpenFileDialog]$ofd = New-Object -TypeName System.Windows.Forms.OpenFileDialog;

  $retval = New-Object -TypeName System.Windows.Forms.DialogResult;
  $myok = [System.Windows.Forms.DialogResult]::OK;
  $retFilename = "";
  $ofd.ShowHelp = $false;
  $ofd.Filter = "Java files (*.java)|*.java|All files (*.*)|*.*" ;
  $ofd.FilterIndex = 1;
  $ofd.Title = $title;
  $ofd.Multiselect = $false;
  $ofd.DefaultExt = "java";
  $ofd.InitialDirectory = "C:\Family\Ian";

  if ($ofd.ShowDialog() -eq $myok) {
     $retFilename = $ofd.FileName;
  } else {
     Throw "No file chosen or selected";
  }

  $ofd.Dispose();

  return $retFilename;
}
#endregion ********** End of function getFilename **********

#------------------------------------------------------------------------------

#region ********** Function printcharacter **********
#
# Prints a character a number of times on the same line
# without any line breaks.
# Parameters:
# char - the character to print.
# num - the number of times the character shall be printed.
#
# Note:
# This has been written to take into account PowerShell ISE which
# doesn't seem very console minded.
#
function printcharacter() {
param (
        [parameter(Position=0,
                   Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [Char]$char,
        [parameter(Position=1,
                   Mandatory=$true)]
        [ValidateRange(1,100)]
        [Int32]$num
      ) #end param

  $str = New-Object -TypeName System.String($char, $num);
  Write-Output $str;

}
#endregion ********** End of function printcharacter **********

#------------------------------------------------------------------------------

#region ********** Function blanklines **********
#
# Prints the number of blank lines specified.
# Parameters:
# lines - the number of blank lines to print.
#
function blanklines() {
param (
        [parameter(Position=0,
                   Mandatory=$true)]
        [ValidateRange(1,15)]
        [Int32]$lines
      ) #end param

  $myarray = 1..$lines;
  for ($m=0; $m -lt $myarray.length; $m++) {
     $myarray[$m] = ' ';
  }
  Write-Output $myarray;

}
#endregion ********** End of function blanklines **********

#------------------------------------------------------------------------------

#region ********** Variable/constant declarations **********
Write-Verbose -Message "Declaring variables and constants";

New-Variable -Name ORACLE_HOME -Option Constant -Value 'C:\oracle\product\11.2.0\client_1';
New-Variable -Name APACHE_HOME -Option Constant -Value 'C:\Program Files\Java\commons-io-2.4';
New-Variable -Name CPATH -Option Constant -Value ".;$APACHE_HOME\commons-io-2.4.jar";
New-Variable -Name JAVA_TOP -Option Constant -Value "C:\Program Files\Java\jdk1.8.0_92";
New-Variable -Name EXE -Option Constant -Value "$JAVA_TOP\bin\java.exe";
$ProgramName = "";
Write-Verbose -Message "Java CLASSPATH used is:`n$CPATH";
$rc = -1;
#endregion ********** End of Variable/constant declarations **********

# *****
# The Call Operator "&"
# The little call operator "&" gives you great discretionary power
# over the execution of PowerShell commands. If you place this
# operator in front of a string (or a string variable), the string
# will be interpreted as a command and executed just as if you had
# input it directly into the console.
# http://powershell.com/cs/blogs/ebook/archive/2009/03/30/chapter-12-command-discovery-and-scriptblocks.aspx#building-scriptblocks
# *****


#------------------------------------------------------------------------------
# Main routine starts here
#------------------------------------------------------------------------------

Get-ScriptInfo;

if ($PSBoundParameters.ContainsKey('JavaFilename')) {
   $ProgramName = $JavaFilename;
   Write-Output "Program name supplied is $ProgramName";
} else {
   # Java file to run has not been supplied. Get the filename.
   $ProgramName = Get-Filename "Get Java file to run";
}

Set-Variable -Name ProgramName -Option ReadOnly;

if (Test-Path $ProgramName)
{

  $dd = Get-Date -Format "dddd, dd MMMM yyyy HH:mm:ss";
  Write-Output "Running program $ProgramName on $dd";

  # Strip off the file extension.
  $Prog = [System.IO.Path]::GetFileNameWithoutExtension($ProgramName);

  blanklines 3
  printcharacter "=" 50
  & $EXE -classpath $CPATH $Prog
  $rc = $LASTEXITCODE;

  printcharacter "=" 50
  blanklines 3
  $dd = Get-Date -Format "HH:mm:ss";
  Write-Output "Process exited at $dd with exit code $rc"
  Write-Output "Java $ProgramName completed"

} else {
  Write-Error -Message "File $ProgramName not found to run" `
              -Category ObjectNotFound `
              -CategoryActivity "Java execute" `
              -CategoryReason "File not found to execute";
}

exit $rc;
# ***** end of script *****
