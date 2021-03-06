<#
.SYNOPSIS

Copies a file and inserts the current date/time partway through
the name of the copied file.

.DESCRIPTION

By copying a file and inserting the current date/time partway through
the name of the copied file, a 'backup copy' is made of the original
file. This means we can make amendments to the original file and have
a backup copy should we have the need to revert to it. The date and
time show when the file was copied and by having a time component, we
can make more than one copy of a file per day.

File 'fred.txt', for example, will be copied to a file named with a
format of 'fred_2018-04-22T14-52-26.txt'. The file when copied can be
set to ReadOnly if required.

The date/time component used is:

<filename>_YYYY-MM-DDTHH-MM-SS.<filename extension>

.EXAMPLE

PS> ./DateCopy-File.ps1

A filename to copy has not been supplied so an internal function will be
invoked to obtain the file to copy.

.EXAMPLE

PS> ./DateCopy-File.ps1 myfile.txt

The filename supplied will be copied to a file with the name format
of myfile_YYYY-MM-DDTHH-MM-SS.txt.

.EXAMPLE

PS> ./DateCopy-File.ps1 -Path myfile.txt

The filename supplied will be copied to a file with the name format
of myfile_YYYY-MM-DDTHH-MM-SS.txt.

.EXAMPLE

PS> ./DateCopy-File.ps1 myfile.txt -ReadOnly

The filename supplied will be copied to a file with the name format
of myfile_YYYY-MM-DDTHH-MM-SS.txt and set to ReadOnly upon completion.

.EXAMPLE

PS> ./DateCopy-File.ps1 -Path myfile.txt -ReadOnly

The filename supplied will be copied to a file with the name format
of myfile_YYYY-MM-DDTHH-MM-SS.txt and set to ReadOnly upon completion.

.INPUTS

None, no .NET Framework types of objects are used as input.

.OUTPUTS

No .NET Framework types of objects are output from this script.

.NOTES

File Name    : DateCopy-File.ps1
Author       : Ian Molloy
Last updated : 2020-03-28

.LINK

Date and time format - ISO 8601
https://www.iso.org/iso-8601-date-and-time-format.html

ISO 8601 Data elements and interchange formats
https://en.wikipedia.org/wiki/ISO_8601

Namespace:   System.IO.Path Class
https://msdn.microsoft.com/en-us/library/system.io.path(v=vs.110).aspx

Microsoft.PowerShell.Management
https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.management/?view=powershell-5.1

#>

[CmdletBinding()]
Param (
   [parameter(Position=0,
              Mandatory=$false)]
   [ValidateScript({Test-Path $_ -PathType 'Leaf'})]
   [String]
   $Path,

   [parameter(Position=1,
              Mandatory=$false)]
   [Switch]
   $ReadOnly
) #end param

#region ***** Function Get-OldFilename *****
#* Function: Get-OldFilename
#* Last modified: 2017-10-22
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
#* the user to select a filename.
#* =============================================
function Get-OldFilename {
[CmdletBinding()]
[OutputType([System.String])]
Param (
        [parameter(Position=0,
                   Mandatory=$true,
                   HelpMessage="ShowDialog box title")]
        [ValidateNotNullOrEmpty()]
        [String]$Boxtitle
      ) #end param

BEGIN {
  Write-Verbose -Message "Invoking function to obtain the to file to copy";

  Add-Type -AssemblyName "System.Windows.Forms";
  [System.Windows.Forms.OpenFileDialog]$ofd = New-Object -TypeName System.Windows.Forms.OpenFileDialog;

  $myok = [System.Windows.Forms.DialogResult]::OK;
  $retFilename = "";
  $ofd.AddExtension = $false;
  $ofd.CheckFileExists = $true;
  $ofd.CheckPathExists = $true;
  $ofd.DefaultExt = ".txt";
  $ofd.Filter = "Text files (*.txt)|*.txt|All files (*.*)|*.*";
  $ofd.InitialDirectory = "C:\Family\powershell";
  $ofd.Multiselect = $false;
  $ofd.Title = $Boxtitle; # sets the file dialog box title
  $ofd.ShowHelp = $false;
  $ofd.RestoreDirectory = $false;
  Set-Variable -Name 'ofd' -Option ReadOnly;

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
#endregion ***** End of function Get-OldFilename *****

#region ***** Function Get-NewFilename *****
#* Function: Get-NewFilename
#* Last modified: 2017-10-22
#* Author: Ian Molloy
#*
#* Arguments:
#* filename - the filename from which to create the new
#* filename.
#*
#* See also:
#* OpenFileDialog Class.
#* http://msdn.microsoft.com/en-us/library/system.windows.forms.openfiledialog.aspx
#* =============================================
#* Purpose:
#* Creates the new filename from the filename supplied. This
#* function is designed to cater for the fact that not all
#* files have a file extension. Most do of course.
#* =============================================
function Get-NewFilename {
[CmdletBinding()]
[OutputType([System.String])]
Param (
        [parameter(Position=0,
                   Mandatory=$true,
                   HelpMessage="The filename to rename")]
        [ValidateNotNullOrEmpty()]
        [String]$OldFilename
      ) #end param

BEGIN {
  # Date format used to help rename the file from the original
  # filename provided.
  $mask = '_yyyy-MM-ddTHH-mm-ss';
  $timestamp = (Get-Date).ToString($mask);
  Set-Variable -Name 'mask', 'timestamp' -Option ReadOnly;

  # Get the absolute path without the filename or extension
  $f1 = [System.io.Path]::GetDirectoryName($OldFilename);

  # Get the filename itself without the path or extension
  $f2 = [System.io.Path]::GetFileNameWithoutExtension($OldFilename);

  # Get the extension (including the period "."), or empty
  # if variable 'OldFilename' does not contain an extension.
  $f3 = [System.io.Path]::GetExtension($OldFilename);

  # Character used to separate directory levels in a path
  $slash = [System.io.Path]::DirectorySeparatorChar;
  Set-Variable -Name 'f1', 'f2', 'f3', 'slash' -Option ReadOnly;

  $newFilename = ("{0}{1}{2}{3}" -f $f1, $slash, $f2, $timestamp);

  if (-not ([System.String]::IsNullOrEmpty($f3))) {
      # This filename has a file extension. Insert it
      # into our new filename
      $newFilename = ("$($newFilename){0}" -f $f3);
  }

}

PROCESS {}

END {
  return $newFilename;
}

}
#endregion ***** End of function Get-NewFilename *****

##=============================================
## SCRIPT BODY
## Main routine starts here
##=============================================
Set-StrictMode -Version Latest;
$ErrorActionPreference = "Stop";

Invoke-Command -ScriptBlock {

   Write-Host '';
   Write-Host ('Today is {0:dddd, dd MMMM yyyy}' -f (Get-Date));

   $script = $MyInvocation.MyCommand.Name;
   $scriptPath = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition;
   Write-Host ('Running script {0} in directory {1}' -f $script,$scriptPath);

}

# With a small sleep delay at the start of the program,
# it helps ensure we can never have two timestamps the
# same because we have at least two seconds delay between
# each run of the program.
Start-Sleep -Seconds 2.0;

if ($PSBoundParameters.ContainsKey('Path')) {
   # Use the filename supplied.
   $oldFilename = Resolve-Path -LiteralPath $Path;
} else {
   # Filename has not been supplied. Execute function Get-OldFilename
   # to allow the user to select a file to copy.
   $oldFilename = Get-OldFilename -Boxtitle 'File to copy';
}
Set-Variable -Name 'oldFilename' -Option ReadOnly;

$newFilename = Get-NewFilename -OldFilename $oldFilename;
Set-Variable -Name 'newFilename' -Option ReadOnly;

Write-Output ("`nFile we want to copy: {0}" -f $oldFilename);
Write-Output ("New filename = {0}" -f $newFilename);
Copy-Item -Path $oldFilename -Destination $newFilename;

if (Test-Path -Path $newFilename) {
  # Set the value of the 'LastWriteTime' property of the file just copied
  # to the current date/time rather than keep the value of the file it
  # was copied from. If we didn't do this, both the original file and the
  # file we've copied will have the same 'LastWriteTime' property. The
  # original file has the earlier 'LastWriteTime' property.
  Set-ItemProperty -Path $newFilename -Name LastWriteTime -Value (Get-Date);

  if ($PSBoundParameters.ContainsKey('ReadOnly')) {
     # Set the value of the 'IsReadOnly' property of the file just copied
     # to true making it read only.
     Set-ItemProperty -Path $newFilename -Name 'IsReadOnly' -Value $True;
  }

  Get-ChildItem -Path $newFilename;
}

##=============================================
## END OF SCRIPT: DateCopy-File.ps1
##=============================================
