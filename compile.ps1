<#
.SYNOPSIS

Compiles a Java program.

.DESCRIPTION

Compiles a Java program. The CLASSPATH used is a CONSTANT declared
in the 'Variable/constant declarations' section. This may have to
be updated depending upon the program being compiled.

.PARAMETER JavaFilename

(optional) the Java program to compile in the format of
<programname>.java. If a parameter is not supplied, an internal
function is invoked to obtain the Java program.

.EXAMPLE

./compile.ps1

As a parameter has not been supplied, an internal function is invoked
to obtain the Java filename.

.EXAMPLE

./compile.ps1 myfile.java

The Java program to compile is supplied as a parameter. Error message:

Error: file myfile.java not found to compile

is displayed if, for example, file 'myfile.java' cannot be found or
doesn't exist.

.EXAMPLE

./compile.ps1 -JavaFilename myfile.java

Using a named parameter to supply the Java program
to compile.

.INPUTS

None, no .NET Framework types of objects are used as input.

.OUTPUTS

No .NET Framework types of objects are output from this script.

Java CLASS files created withing the last few minutes are listed
if the compile is successful. In the event of an unsuccessful
compile, Java errors are shown in the usual way.

.NOTES

File Name    : compile.ps1
Author       : Ian Molloy
Last updated : 2020-04-12

.LINK

JDK 14 Documentation
https://docs.oracle.com/en/java/javase/14/

javac - Java programming language compiler
http://docs.oracle.com/javase/8/docs/technotes/tools/windows/javac.html

#>

[CmdletBinding()]
Param (
   [parameter(Position=0,
              Mandatory=$false)]
   [ValidateScript({Test-Path $_ -PathType 'Leaf'})]
   [String]
   $JavaFilename
) #end param

#################################################
#region ***** function Get-Script-Info *****
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
function Get-ScriptInfo
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
#endregion ***** end of function Get-Script-Info *****

#------------------------------------------------------------------------------

#region ***** Function Get-Filename *****
#* Function: Get-Filename
#* Last modified: 2017-02-11
#* Author: Ian Molloy
#*
#* Arguments:
#* Title - the title displayed on the dialog box window.
#*
#* See also:
#* OpenFileDialog Class.
#* http://msdn.microsoft.com/en-us/library/system.windows.forms.openfiledialog.aspx
#* =============================================
#* Purpose:
#* Displays a standard dialog box that prompts
#* the user to open a file.
#* =============================================
function Get-Filename {
[CmdletBinding()]
Param (
        [parameter(Mandatory=$true,
                   HelpMessage="ShowDialog box title")]
        [ValidateNotNullOrEmpty()]
        [String]$Title
      ) #end param

  #trap { "An error: $_"; exit 1;}

BEGIN {
  Write-Verbose -Message "Invoking function to obtain the Java filename to compile";

  Add-Type -AssemblyName "System.Windows.Forms";
  # Displays a standard dialog box that prompts the user
  # to open (select) a file.
  [System.Windows.Forms.OpenFileDialog]$ofd = New-Object -TypeName System.Windows.Forms.OpenFileDialog;

  # The dialog box return value is OK (usually sent
  # from a button labeled OK). This indicates the
  # user has selected a file.
  $myok = [System.Windows.Forms.DialogResult]::OK;
  $retFilename = "";
  $ofd.CheckFileExists = $true;
  $ofd.CheckPathExists = $true;
  $ofd.ShowHelp = $false;
  $ofd.Filter = "Java files (*.java)|*.java|All files (*.*)|*.*";
  $ofd.FilterIndex = 1;
  $ofd.InitialDirectory = "C:\Ian\Java";
  $ofd.Multiselect = $false;
  $ofd.RestoreDirectory = $false;
  $ofd.Title = $Title; # sets the file dialog box title
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
#endregion ***** End of function getFilename *****

#------------------------------------------------------------------------------

#region ***** Function printcharacter *****
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
function printcharacter {
param (
        [parameter(Position=0,
                   Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [Char]$char,
        [parameter(Position=1,
                   Mandatory=$true)]
        [ValidateRange(1,70)]
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
#endregion ***** End of function printcharacter *****

#------------------------------------------------------------------------------

#region ***** Function printblanklines *****
#
# Prints the number of blank lines specified.
# Parameters:
# lines - the number of blank lines to print.
#
function printblanklines {
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
#endregion ***** End of function printblanklines *****

#------------------------------------------------------------------------------

#region ***** Variable/constant declarations *****
Write-Verbose -Message "Declaring variables and constants";

#New-Variable -Name "JARPATH" -Option Constant -Value 'C:\Program Files\Java\lib2\*';

#New-Variable -Name "JAR1" -Option Constant -Value 'C:\Program Files\Java\lib\StreamBootstrapper.class';

# Variable/constant declarations.
#New-Variable -Name APACHE_HOME -Option Constant -Value 'C:\Program Files\Java\commons-io-2.4';
New-Variable -Name "CPATH" -Option Constant -Value ".";
New-Variable -Name "JAVA_TOP" -Option Constant -Value "C:\Program Files\Java\jdk-14";
New-Variable -Name "EXE" -Option Constant -Value "$JAVA_TOP\bin\javac.exe";
$ProgramName = "";
Write-Verbose -Message "Java CLASSPATH used is:`n$CPATH";
#endregion ***** End of Variable/constant declarations *****

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
# SCRIPT BODY
# Main routine starts here
#------------------------------------------------------------------------------
Set-StrictMode -Version Latest;

Get-ScriptInfo;

# The location of JAVA_TOP changes due to Java updates to new
# versions. Check the location really exists and that we've
# not forgotten to change it to the most recent Java update
# file path.
if (-not (Test-Path -Path $JAVA_TOP))
{
    throw [System.IO.DirectoryNotFoundException] "JAVA_TOP $JAVA_TOP not found";
}

if ($PSBoundParameters.ContainsKey('JavaFilename')) {
   # A Java filename has been supplied. Use it.
   $ProgramName = $JavaFilename;
   Write-Output "Program name supplied is $ProgramName";
} else {
   # Java file to compile has not been supplied. Get the filename.
   $ProgramName = Get-Filename "Get Java file to compile";
}

Set-Variable -Name ProgramName -Option ReadOnly;

if (Test-Path -Path $ProgramName)
{
  printblanklines 2;
  printcharacter "=" 50;

  $dd = Get-Date -Format "dddd, dd MMMM yyyy HH:mm:ss";
  Write-Output "Compiling program $ProgramName on $dd";
  Write-Output "";

  try {
    & $EXE -Xlint:all -Xmaxerrs 10 -Xmaxwarns 10 -Xdiags:verbose -classpath $CPATH $ProgramName;
  } catch {
    Write-Error -Message "Java compile failed";
  }

  $rc = $LASTEXITCODE;
  Write-Output "exitcode = $rc";

  Write-Output "`nFile $ProgramName compiled";

  if ($rc -eq 0) {
     Write-Output "Exit code = $rc";
     printblanklines 2;
     printcharacter "=" 50;

     # Show the resultant class files recently compiled.
     Write-Output "Java CLASS files created within the last few minutes";

     Get-ChildItem -Filter '*.class' -File |
         Where-Object {$_.LastWriteTime -ge (Get-Date).AddMinutes(-5)} |
         Sort-Object -Property LastWriteTime;
     printblanklines 2;
     $dd = Get-Date -Format "HH:mm:ss";
     Write-Output "Current time is: $dd";

  } else {
    Write-Warning -Message "Process exited with exit code $rc";
  }

  printcharacter "=" 50;
  printblanklines 2;

}
else
{
  Write-Error -Message "File $ProgramName not found to compile" `
              -Category ObjectNotFound `
              -CategoryActivity "Java compile" `
              -CategoryReason "File not found to compile";

}

exit $rc;

##=============================================
## END OF SCRIPT: compile.ps1
##=============================================
