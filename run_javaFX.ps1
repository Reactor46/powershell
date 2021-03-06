<#
.SYNOPSIS

Runs a JavaFX program.

.DESCRIPTION

Note the distinction between Java and JavaFX.

Runs a JavaFX program that has already been compiled. The
variable 'PATH_TO_FX' points to wherever the JavaFX runtime
libraries have been installed. The variable is a CONSTANT
declared in the 'Variable/constant declarations' section and
may have to be changed whenever the JavaFX runtime libraries
are updated.

.PARAMETER JavaFilename

(optional) the JavaFX program to run in the format of
<programname>.java. If a parameter is not supplied, an internal
function is invoked to obtain the JavaFX filename.

.EXAMPLE

./run_javaFX.ps1

As a parameter has not been supplied, an internal function is invoked
to obtain the JavaFX filename.

.EXAMPLE

./run_java.ps1 myfile.java

The Java program to execute is supplied as a parameter. Error message:

Error: file myfile.java not found to run

is displayed if, for example, file 'myfile.java' cannot be found or
doesn't exist.

.EXAMPLE

./run_javaFX.ps1 -JavaFilename myfile.java

Using a named parameter to supply the Java program to execute.

.INPUTS

None. No .NET Framework types of objects are used as input.

.OUTPUTS

None. No .NET Framework types of objects are output from this script.

.NOTES

File Name    : run_javaFX.ps1
Author       : Ian Molloy
Last updated : 2019-06-05

.LINK

JavaFX API docs
https://openjfx.io/javadoc/12/
https://docs.oracle.com/javafx/2/api/index.html

JDK 12 Documentation (in general)
https://docs.oracle.com/en/java/javase/12/

Java SE Version 12 API docs
https://docs.oracle.com/en/java/javase/12/docs/api/index.html

javac - Java programming language compiler
http://docs.oracle.com/javase/8/docs/technotes/tools/windows/javac.html

JavaFX Introduction
https://www.ntu.edu.sg/home/ehchua/programming/java/Javafx1_intro.html

Getting Started with JavaFX 12
https://openjfx.io/openjfx-docs/#install-javafx

#>

[CmdletBinding()]
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

#region ********** Function Get-Filename **********
#* Function: Get-Filename
#* Last modified: 2017-01-15
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
#* Displays a standard dialog box that prompts
#* the user to open a (JavaFX) file.
#* =============================================
function Get-Filename() {
[CmdletBinding()]
Param (
        [parameter(Mandatory=$true,
                   HelpMessage="ShowDialog box title")]
        [ValidateNotNullOrEmpty()]
        [String]$title
      ) #end param

BEGIN {
  Write-Verbose -Message "Invoking function to obtain the JavaFX filename to run";

  Add-Type -AssemblyName "System.Windows.Forms";
  [System.Windows.Forms.OpenFileDialog]$ofd = New-Object -TypeName 'System.Windows.Forms.OpenFileDialog';

  $myok = [System.Windows.Forms.DialogResult]::OK;
  $retFilename = "";
  $ofd.CheckFileExists = $true;
  $ofd.CheckPathExists = $true;
  $ofd.ShowHelp = $false;
  $ofd.Filter = "Java files (*.java)|*.java|All files (*.*)|*.*";
  $ofd.FilterIndex = 1;
  $ofd.InitialDirectory = "C:\Family\Ian";
  $ofd.Multiselect = $false;
  $ofd.RestoreDirectory = $false;
  $ofd.Title = $title; # sets the file dialog box title
  $ofd.DefaultExt = "java";
}

PROCESS {
  if ($ofd.ShowDialog() -eq $myok) {
     $retFilename = $ofd.FileName;
  } else {
     Throw "No file chosen or selected";
  }
}

END {
  $ofd.Dispose();
  return $retFilename;
}
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
        [System.Byte]$num
      ) #end param

BEGIN {
  $fred = "";
}

PROCESS {}

END {
  Write-Output $fred.PadRight($num, $char);
}

}
#endregion ********** End of function printcharacter **********

#------------------------------------------------------------------------------

#region ********** Function printblanklines **********
#
# Prints the number of blank lines specified.
# Parameters:
# lines - the number of blank lines to print.
#
function printblanklines() {
param (
        [parameter(Position=0,
                   Mandatory=$true)]
        [ValidateRange(1,15)]
        [System.Byte]$lines
      ) #end param

BEGIN {
  $blankline = ([Char]0X0D + [Char]0X0A);
}

PROCESS {

  for ($i=0; $i -lt $lines; $i++) {
      Write-Output $blankline;
  }

}

END {}

}
#endregion ********** End of function printblanklines **********

#------------------------------------------------------------------------------

#region ********** Variable/constant declarations **********
Write-Verbose -Message "Declaring variables and constants";

#New-Variable -Name APACHE_HOME -Option Constant -Value 'C:\Program Files\Java\commons-io-2.4';
#New-Variable -Name "CPATH" -Option Constant -Value '.;C:\Program Files\Java\javafx-sdk-12.0.1\lib\*;C:\Program Files\Java\javafx-sdk-12.0.1\bin\*';
New-Variable -Name "PATH_TO_FX" -Option Constant -Value 'C:\Program Files\Java\javafx-sdk-12.0.1\lib';
New-Variable -Name "JAVA_TOP" -Option Constant -Value "C:\Program Files\Java\jdk-12.0.1";
New-Variable -Name "JAVAEXE" -Option Constant -Value "$JAVA_TOP\bin\java.exe";
$ProgramName = "";
Write-Verbose -Message "JavaFX CLASSPATH used is:`n$($PATH_TO_FX)";
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

# The location of JAVA_TOP changes due to Java updates to new
# versions. Check the location really exists and that we've
# not forgotten to change it to the most recent Java version.
if (-not (Test-Path -Path $JAVA_TOP))
{
    throw [System.IO.DirectoryNotFoundException] "JAVA_TOP $JAVA_TOP not found";
}


# The location of the JavaFX runtime location changes due
# to updates to new versions. Check the location really
# exists and that we've not forgotten to change it to the
# most recent update.
if (-not (Test-Path -Path $PATH_TO_FX))
{
    throw [System.IO.DirectoryNotFoundException] "JavaFX runtime location $($PATH_TO_FX) not found";
}

if ($PSBoundParameters.ContainsKey('JavaFilename')) {
   $ProgramName = $JavaFilename;
   Write-Output "Program name supplied is $ProgramName";
} else {
   # Java file to run has not been supplied. Get the filename.
   $ProgramName = Get-Filename "Get JavaFX file to run";
}

Set-Variable -Name ProgramName -Option ReadOnly;

if (Test-Path -Path $ProgramName)
{

  $dd = Get-Date -Format "dddd, dd MMMM yyyy HH:mm:ss";
  Write-Output "Running program $ProgramName on $dd";

  # Strip off the file extension.
  $Prog = [System.IO.Path]::GetFileNameWithoutExtension($ProgramName);

  printblanklines 2
  printcharacter "=" 50
  #& $JAVAEXE -classpath $CPATH $Prog
  & $JAVAEXE --module-path $PATH_TO_FX --add-modules javafx.controls $Prog
  $rc = $LASTEXITCODE;

  printcharacter "=" 50
  printblanklines 2
  $dd = Get-Date -Format "HH:mm:ss";
  Write-Output "Process exited at $dd with exit code $rc"
  Write-Output "JavaFX $ProgramName completed"

} else {
  Write-Error -Message "File $ProgramName not found to run" `
              -Category ObjectNotFound `
              -CategoryActivity "JavaFX execute" `
              -CategoryReason "File not found to execute";
}

exit $rc;
##=============================================
## END OF SCRIPT: run_javaFX.ps1
##=============================================
