<#

.SYNOPSIS
Permission seeking utility with recursive capabilities.

.DESCRIPTION
This tool is used to be allowed to recursively get information down a Windows file system in a depth-first manner.
This tool requires extreme caution when using, because some edge cases can cause the depth-first search to recurse
into a infinite loop; really meaning when the file system bottoms out.

This issue is still being considered on ways to address the fix, as well as the required -Init field. Which may seem
ambigious, however it controls the depth order of the recursive function correctly. 

Note: -Init will ALWAYS be set during the instantiation of this recursive call. DO NOT EVER attempt to call Get-Permission
with -Init set to $False. This will potentially produce the edge case as discussed above.

Calling Get-Permission requires the following field:
    -Folder [relative/path]
    -Depth_Set [Int]
    -Init $True

This recursive call when used correctly will return a depth-first manner of the directory passed and "diving" as deep
as what -Depth_Set is assigned to. Any directories with a depth less than the -Depth_Set will move back up the recurse 
list faster.

For each iteration, this tool will show the current depth, the location of the dive, the identies of the users who
have access, as well as the variety of permissions, access, and flags associated with that user.

.EXAMPLE
Get-Permissions -Folder folderName -Depth_Set 1 -Init $True
.EXAMPLE
Get-Permissions -Folder local\folder -Depth_Set 2 -Init $True

.NOTES
Author: Vincent Nigro
Last Updated: 11/1/2019
Version: 0.0.1

.LINK
https://github.com/xTriixrx

#>
function Get-Permissions
{
    param(
        [Parameter(Mandatory=$True)]
        [ValidateNotNull()]
        [String]
        $Folder,
        [Parameter(Mandatory=$True)]
        [ValidateNotNull()]
        [Int]
        $Depth_Set,
        [Parameter(Mandatory=$True)]
        [ValidateNotNull()]
        [Boolean]
        $Init,
        [Parameter(Mandatory=$False)]
        [ValidateNotNull()]
        [Int]
        $Depth
        )

        if($Init -eq $True -and $Depth) {
            Write-Output "InvalidParameterException: -Depth should not be set during recursive initialization (-Init). See Get-Help Get-Permissions for more information." 
            return
        }
        
        if($Init) {
            $Depth = 0;
        }
        else {
            $Depth = $Depth + 1;
        }

    Foreach ($Item in Get-ChildItem $Folder) {
        #$TAB = "`t" * $Depth;

        Write-Output "Depth: $Depth" " ";

        $Location = $Folder + '\' + $Item;
        Write-Output "Location" -------- $Location;  

        (get-acl $Location).access | select `
		    @{Label="Identity";Expression={$_.IdentityReference}}, `
		    @{Label="Right";Expression={$_.FileSystemRights}}, `
		    @{Label="Access";Expression={$_.AccessControlType}}, `
		    @{Label="Inherited";Expression={$_.IsInherited}}, `
		    @{Label="Inheritance Flags";Expression={$_.InheritanceFlags}}, `
		    @{Label="Propagation Flags";Expression={$_.PropagationFlags}} | ft -auto

        Write-Output " " " " " ";
        if ($Depth -ne $Depth_Set) {
            if (Test-Path $Location -PathType Container) {
                Get-Permissions -Folder $Location -Depth_Set $Depth_Set -Init $False -Depth $Depth;
            }
        }
    } # End of Foreach
}