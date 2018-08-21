Add-Type -AssemblyName "System.IO.Compression.FileSystem";
$myzip = 'C:\Family\powershell\itextsharp-all-5.4.1.zip';
[Int16]$counter = 0;

# Variable 'arc' has type of ZipArchive Class.
# System.IO.Compression.ZipArchive Class.
$arc = [System.IO.Compression.ZipFile]::OpenRead($myzip);
Write-Host ('Looking at Zip file {0}' -f $myzip);

# Variable 'arcent' has type of:
# System.Collections.ObjectModel.ReadOnlyCollection<ZipArchiveEntry>
# meaning that ZipArchiveEntry Class is wrapped in a ReadOnlyCollection.
# System.IO.Compression.ZipArchiveEntry Class
# System.Collections.ObjectModel.ReadOnlyCollection<T>
$arcent = $arc.Entries;

# Variable 'ZipArcEntry' has type of ZipArchiveEntry
# System.IO.Compression.ZipArchiveEntry
foreach ($ZipArcEntry in $arcent)
{
  $counter++;
  Write-Host ("(#{0})`nArchive entry: {1}`nCompressed length: {2} bytes`nUncompressed length: {3} bytes`n" -f
          $counter, `
          $ZipArcEntry.FullName, `
          $ZipArcEntry.CompressedLength, `
          $ZipArcEntry.Length
          );
}

Write-Host ('Entries in zip file {0}' -f $arcent.Count);
$arc.Dispose();
Write-Host 'All done now!';
