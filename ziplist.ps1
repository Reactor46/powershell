#

[CmdletBinding()]
Param (
   [parameter(Position=0,
              Mandatory=$false)]
   [ValidateScript({Test-Path $_ -PathType 'Leaf'})]
   [String]
   $Path,
   
   [parameter(Mandatory=$false,
   ParameterSetName="GridView")]
   [Switch]
   $GridView

) #end param

#region ********** Function Get-Filename **********
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
function Get-Filename() {
[CmdletBinding()]
Param (
        [parameter(Mandatory=$true,
                   HelpMessage="ShowDialog box title")]
        [ValidateNotNullOrEmpty()]
        [String]$Title
      ) #end param

  #trap { "An error: $_"; exit 1;}

BEGIN {
  Write-Verbose -Message "Invoking function to obtain the Zip filename to look at";

  Add-Type -AssemblyName "System.Windows.Forms";
  [System.Windows.Forms.OpenFileDialog]$ofd = New-Object -TypeName System.Windows.Forms.OpenFileDialog;

  $myok = [System.Windows.Forms.DialogResult]::OK;
  $retFilename = "";
  $ofd.CheckFileExists = $true;
  $ofd.CheckPathExists = $true;
  $ofd.ShowHelp = $false;
  $ofd.Filter = "Zip files (*.zip)|*.zip|All files (*.*)|*.*";
  $ofd.FilterIndex = 1;
  $ofd.InitialDirectory = "C:\Family\Ian";
  $ofd.Multiselect = $false;
  $ofd.RestoreDirectory = $false;
  $ofd.Title = $Title; # sets the file dialog box title
  $ofd.DefaultExt = "zip";

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


##=============================================
## SCRIPT BODY
## Main routine starts here
##=============================================
Set-StrictMode -Version Latest;
$ErrorActionPreference = 'Stop';

Add-Type -AssemblyName "System.IO.Compression.FileSystem";

if ($PSBoundParameters.ContainsKey('Path')) {
	 # Zip filename supplied at the command line.
   $myzip = $Path;
   Write-Verbose -Message "Zip name supplied is $myzip";
} else {
   # Zip file to look at has not been supplied. Get the filename.
   $myzip = Get-Filename "Get Zip file to list";
}

[UInt16]$counter = 0;

# Variable 'arc' has type of ZipArchive Class.
# System.IO.Compression.ZipArchive Class.
# Returns ZipArchive, The opened zip archive.
$arc = [System.IO.Compression.ZipFile]::OpenRead($myzip);
Write-Output ('Looking at Zip file {0}' -f $myzip);

# Variable 'arcent' has type of:
# System.Collections.ObjectModel.ReadOnlyCollection<ZipArchiveEntry>
# meaning that ZipArchiveEntry Class is wrapped in a ReadOnlyCollection.
# System.IO.Compression.ZipArchiveEntry Class
# System.Collections.ObjectModel.ReadOnlyCollection<T>
$arcent = $arc.Entries;

# Variable 'ZipArcEntry' has type of ZipArchiveEntry
# System.IO.Compression.ZipArchiveEntry
if ($PSCmdlet.ParameterSetName -eq "GridView") {
	$arcent | Select-Object LastWriteTime, Length, Name | Out-GridView -Title 'Zip file contents'
} else {

    foreach ($ZipArcEntry in $arcent)
    {
      $counter++;
      if ($ZipArcEntry.FullName.EndsWith('/')) {
      	$arcname = '(directory)';
      } else {
      	$arcname = $ZipArcEntry.Name;
      }
      	
      Write-Output ("(#{0})`nArchive entry: {1}`nCompressed length: {2} bytes`nUncompressed length: {3} bytes`n" -f
              $counter, `
              $arcname, `
              $ZipArcEntry.CompressedLength, `
              $ZipArcEntry.Length
              );
    } #end foreach loop
    
}

Write-Output ('{0} entries in zip file {1}' -f $arcent.Count, $myzip);
$arc.Dispose();
Write-Output 'All done now!';

##=============================================
## END OF SCRIPT: ziplist.ps1
##=============================================
