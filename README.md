MoveUserData
============

MoveUserData is a Windows batch script that can be used to move all of the user
data files from one local drive or volume to another.

Note that this script is intended to be run from the Windows Pre Installation
Environment (e.g. Windows Installer). As a result, the source and destination
drives are not likely to be C:, D: when copying but will usually follow those
letters when Windows is running.

```
Usage: Usage: MoveUserData.bat <SrcDrive> <DestDrive> [RealSrcDrive] [RealDestDrive]

Arguments
	<SrcDrive> The source drive to copy user data from (e.g. F:)
	<DestDrive> The destination drive to copy user data to (e.g. E:)
	<RealSrcDrive> The drive letter of the source when running live
		in Windows. This argument is optional, if not specified will default
		to C:
	<RealDestDrive> The drive letter of the destination when running live in
		Windows. This argument is optional, if not specified will default to
		D:

Example: MoveUserData.bat F: E: C: D:

	Moves the Users and ProgramData folders found on drive F: to drive E:. Rewrites
	all junctions and symlinks pointing to C: to D:.
```