#Requires -Version 3.0

# -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Script: Screenshot.ps1
# Version: 5.0
# Author: Dylan Langston
# Comments: This script was hacked together in my free time and is provided as is. It's intended to be a method of quickly taking license removal screenshots but could be used in many workflows.
#           Tested only on Windows 10 64bit but should (at least kinda) work on any windows machine with Powershell 3.0 or higher.
# Date: 4/2020
# -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# Gets/Sets the default parameters.
param(
  [Parameter(Mandatory = $false,Position = 1,HelpMessage = "Enter Folder to Save Screenshots; path.")]
  [Alias("Path")]
  [System.IO.DirectoryInfo]$Directory = "$env:USERPROFILE\Pictures\Screenshots",# The path to save screenshots
  [Parameter(Mandatory = $false,Position = 2,HelpMessage = "Enter filename for Screenshots; string.")]
  [Alias("File")]
  [string]$FileName = "Screenshot_$(get-date -Format 'MM-dd-yyyy_HHmmss')",# The file name
  [Parameter(Mandatory = $false,Position = 3,HelpMessage = "Enter Color for Border; string.")]
  [string]$BorderColor = "Red",# Color of the selector, valid options are available here https://docs.microsoft.com/en-us/dotnet/api/system.windows.media.colors
  [Parameter(Mandatory = $false,Position = 4,HelpMessage = "Specify if images should open after script exits; true/false.")]
  [Alias("Editor","Viewer","Paint")]
  [ValidatePattern("[Tt][Rr][Uu][Ee]|[Ff][Aa][Ll][Ss][Ee]|1|0")]
  [string]$OpenImages = "true",# Open in default editor app on close
  [Parameter(Mandatory = $false,Position = 5,HelpMessage = "Specify if screenshots folder should open after script exits; true/false.")]
  [ValidatePattern("[Tt][Rr][Uu][Ee]|[Ff][Aa][Ll][Ss][Ee]|1|0")]
  [Alias("folder")]
  [string]$OpenFolder = "false",# Open folder on close
  [Parameter(Mandatory = $false,Position = 6,HelpMessage = "Specify if powershell window should hide on launch; true/false.")]
  [ValidatePattern("[Tt][Rr][Uu][Ee]|[Ff][Aa][Ll][Ss][Ee]|1|0")]
  [Alias("Minimize")]
  [string]$HidePowershell = "true",# Minimize powershell window on launch
  [Parameter(Mandatory = $false,Position = 7,HelpMessage = "Specify if file save prompt should appear on start; true/false.")]
  [ValidatePattern("[Tt][Rr][Uu][Ee]|[Ff][Aa][Ll][Ss][Ee]|1|0")]
  [Alias("prompt")]
  [string]$SaveDialog = "false",# Prompt where to save on launch
  [Parameter(Mandatory = $false,Position = 8,HelpMessage = "Specify the scancode to monitor for; int.")]
  [ValidatePattern("\d+")]
  [Alias("keycode","code")]
  [string]$scanCode = 44,# Default Hotkey is printscreen
  [Parameter(Mandatory = $false,Position = 9,HelpMessage = "Specify if this should run in the system tray; true/false.")]
  [ValidatePattern("[Tt][Rr][Uu][Ee]|[Ff][Aa][Ll][Ss][Ee]|1|0")]
  [Alias("background","systemtray")]
  [string]$runInSystray = "true" # Run Program in system tray
)

# Ensure only once instance of the script is running at a time
# https://stackoverflow.com/a/33574883
#Get array of all powershell scripts currently running
try {
  if ($(Split-Path -Leaf -Path ([Environment]::GetCommandLineArgs()[0])) -match "powershell") {
    $scriptname = $MyInvocation.MyCommand.Name
  } else {
    $scriptname = $(Split-Path -Leaf -Path ([Environment]::GetCommandLineArgs()[0]))
  }
} catch {
  $scriptname = $(Split-Path -Leaf -Path ([Environment]::GetCommandLineArgs()[0]))
}
$PsScriptsRunning = Get-CimInstance win32_process | Where-Object { $_.processname -eq $(Split-Path -Leaf -Path ([Environment]::GetCommandLineArgs()[0])) } | Select-Object commandline,ProcessId
#enumerate each element of array and compare
foreach ($PsCmdLine in $PsScriptsRunning) {
  [int32]$OtherPID = $PsCmdLine.ProcessId
  [string]$OtherCmdLine = $PsCmdLine.commandline
  #Are other instances of this script already running?
  if (($OtherCmdLine -match "$scriptname") -and ($OtherPID -ne $PID)) {
    Write-Output "PID [$OtherPID] is already running this script [$scriptname]. Triggering that instance instead."
    Write-Output "Exiting this instance. (PID=$PID)..."
    $takescreenshot = [System.IO.Path]::GetTempPath() + "screenshot.queue"
    Out-File -Force -FilePath $takescreenshot | Out-Null
    Start-Sleep -Seconds 3
    exit
  }
}

# Remove old quit item.
$quitnow = Resolve-Path $([System.IO.Path]::GetTempPath() + "screenshot.quit")  2> $null
if ($quitnow) {
    Remove-Item -Force $([System.IO.Path]::GetTempPath() + "screenshot.quit") | Out-Null
}

# Convert RunInSysTray to bool
if ($runInSystray -eq "true" -or $runInSystray -eq "1") { $tmpruninsys = $true } else { $tmpruninsys = $false }

# Prompt where to save file
#Thanks, https://gallery.technet.microsoft.com/scriptcenter/GUI-popup-FileSaveDialog-813a4966
if ($SaveDialog -eq "true" -or $SaveDialog -eq "1") {
  if ($runInSystray -eq $false) {
    [void][System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
    $AsktoSave = $false
    $SaveFileDialog = (New-Object windows.forms.savefiledialog)
    $SaveFileDialog.initialDirectory = $env:USERPROFILE
    $SaveFileDialog.title = "Save Screenshot"
    $SaveFileDialog.filter = "PNG|*.png|All Files|*.*"
    $SaveFileDialog.ShowHelp = $False
    $SaveFileDialog.OverwritePrompt = $False
    Write-Output "Where would you like to save the screenshot?... (see File Save Dialog)"
    $result = $SaveFileDialog.ShowDialog()
    if ($result -eq "OK") {
      $Directory = Split-Path $SaveFileDialog.filename
      $FileName = [System.IO.Path]::GetFileNameWithoutExtension($SaveFileDialog.filename)
    } else {
      Write-Output "Using Defaults instead."
    }
  } else { $AsktoSave = $true }
} else {
  if ($tmpruninsys -eq $true -and (-not ($FileName -match "Screenshot_\d{2}-\d{2}-\d{4}_\d{6}"))) {
    Write-Output "Can't run in System Tray and have custom filename specified at launch. Run with '-prompt 1' if you'd like to enter a custom name every time you save."
  } else {
    # Make sure the screenshots folder exists, create it otherwise
    New-Item -ItemType Directory -Force -Path $Directory | Out-Null
  }
}

# Minimize powershell window if not already hidden on launch and the hide powershell param is not set to false.
if ($HidePowershell -eq "true" -or $HidePowershell -eq "1") {
  if ($null -eq $(Get-CimInstance win32_process | Where-Object { $_.processname -eq 'powershell.exe' -and $_.ProcessId -eq $pid -and $_.commandline -match $("-WindowStyle Hidden") })) {
    Add-Type -Name Window -Namespace Console -MemberDefinition '
        [DllImport("Kernel32.dll")]
        public static extern IntPtr GetConsoleWindow();

        [DllImport("user32.dll")]
        public static extern bool ShowWindow(IntPtr hWnd, Int32 nCmdShow);
        '
    $consolePtr = [Console.Window]::GetConsoleWindow()
    [Console.Window]::ShowWindow($consolePtr,0) | Out-Null
  }
}

# Thanks to the following resources which proved super helpful
# https://devblogs.microsoft.com/scripting/beginning-use-of-powershell-runspaces-part-2/
# https://learn-powershell.net/2015/11/30/create-a-mouse-cursor-tracker-using-powershell-and-wpf/
$ParamList = @{
  Folder = $Directory
  BorderColor = $BorderColor
  Name = $FileName
  runInSystray = $tmpruninsys
  scanCode = $scanCode
  AsktoSave = $AsktoSave
  OpenImages = $OpenImages
  OpenFolder = $OpenFolder
  scriptname = $scriptname
}
$Runspacehash = [hashtable]::Synchronized(@{})
$Runspacehash.host = $Host
$Runspacehash.runspace = [runspacefactory]::CreateRunspace()
$Runspacehash.runspace.ApartmentState = “STA”
$Runspacehash.runspace.ThreadOptions = "UseNewThread”
$Runspacehash.runspace.Open()
$Runspacehash.psCmd = { Add-Type -AssemblyName PresentationFramework,System.Windows.Forms }.GetPowerShell()
$Runspacehash.runspace.SessionStateProxy.SetVariable("Runspacehash",$Runspacehash)
$Runspacehash.psCmd.runspace = $Runspacehash.runspace
$Runspacehash.Handle = $Runspacehash.psCmd.AddScript({
    param($Folder,$BorderColor,$Name,$runInSystray,$scanCode,$AsktoSave,$OpenImages,$OpenFolder,$scriptname)

    $ErrorActionPreference = 'SilentlyContinue'

    # This tip from http://stackoverflow.com/questions/3358372/windows-forms-look-different-in-powershell-and-powershell-ise-why/3359274#3359274
    [System.Windows.Forms.Application]::EnableVisualStyles();

    # If running Windows 10 setup workspace switching, Thanks to https://gallery.technet.microsoft.com/scriptcenter/Powershell-commands-to-d0e79cc5
    if ($PSVersionTable.PSVersion.Major -lt 6) {
        $OSVer = $PSVersionTable.BuildVersion.Major
        $OSBuild = $PSVersionTable.BuildVersion.Build
        }
    else {
        $OSVer = [Environment]::OSVersion.Version.Major
        $OSBuild = [Environment]::OSVersion.Version.Build
    }
    if ($OSVer -ge 10)
    {
        if ($OSBuild -ge 14392)
        {
            $Windows1607 = $TRUE
            $Windows1803 = $FALSE
            $Windows1809 = $FALSE
            if ($OSBuild -ge 17134)
            {
                $Windows1607 = $FALSE
                $Windows1803 = $TRUE
                $Windows1809 = $FALSE
            }
            if ($OSBuild -ge 17661)
            {
                $Windows1607 = $FALSE
                $Windows1803 = $FALSE
                $Windows1809 = $TRUE
            }
Add-Type -Language CSharp -TypeDefinition @"
using System;
using System.Text;
using System.Collections.Generic;
using System.Runtime.InteropServices;
using System.ComponentModel;

// Based on http://stackoverflow.com/a/32417530, Windows 10 SDK and github projects Grabacr07/VirtualDesktop and mzomparelli/zVirtualDesktop

namespace VirtualDesktop
{
	internal static class Guids
	{
		public static readonly Guid CLSID_ImmersiveShell = new Guid("C2F03A33-21F5-47FA-B4BB-156362A2F239");
		public static readonly Guid CLSID_VirtualDesktopManagerInternal = new Guid("C5E0CDCA-7B6E-41B2-9FC4-D93975CC467B");
		public static readonly Guid CLSID_VirtualDesktopManager = new Guid("AA509086-5CA9-4C25-8F95-589D3C07B48A");
		public static readonly Guid CLSID_VirtualDesktopPinnedApps = new Guid("B5A399E7-1C87-46B8-88E9-FC5747B171BD");
	}

	[StructLayout(LayoutKind.Sequential)]
	internal struct Size
	{
		public int X;
		public int Y;
	}

	[StructLayout(LayoutKind.Sequential)]
	internal struct Rect
	{
		public int Left;
		public int Top;
		public int Right;
		public int Bottom;
	}

	internal enum APPLICATION_VIEW_CLOAK_TYPE : int
	{
		AVCT_NONE = 0,
		AVCT_DEFAULT = 1,
		AVCT_VIRTUAL_DESKTOP = 2
	}

	internal enum APPLICATION_VIEW_COMPATIBILITY_POLICY : int
	{
		AVCP_NONE = 0,
		AVCP_SMALL_SCREEN = 1,
		AVCP_TABLET_SMALL_SCREEN = 2,
		AVCP_VERY_SMALL_SCREEN = 3,
		AVCP_HIGH_SCALE_FACTOR = 4
	}

	[ComImport]
// https://github.com/mzomparelli/zVirtualDesktop/wiki: Updated interfaces in Windows 10 build 17134, 17661, and 17666
$(if ($Windows1607) {@"
// Windows 10 1607 and Server 2016:
	[InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
	[Guid("9AC0B5C8-1484-4C5B-9533-4134A0F97CEA")]
"@ })
$(if ($Windows1803) {@"
// Windows 10 1803:
	[InterfaceType(ComInterfaceType.InterfaceIsIInspectable)]
	[Guid("871F602A-2B58-42B4-8C4B-6C43D642C06F")]
"@ })
$(if ($Windows1809) {@"
// Windows 10 1809:
	[InterfaceType(ComInterfaceType.InterfaceIsIInspectable)]
	[Guid("372E1D3B-38D3-42E4-A15B-8AB2B178F513")]
"@ })
	internal interface IApplicationView
	{
		int SetFocus();
		int SwitchTo();
		int TryInvokeBack(IntPtr /* IAsyncCallback* */ callback);
		int GetThumbnailWindow(out IntPtr hwnd);
		int GetMonitor(out IntPtr /* IImmersiveMonitor */ immersiveMonitor);
		int GetVisibility(out int visibility);
		int SetCloak(APPLICATION_VIEW_CLOAK_TYPE cloakType, int unknown);
		int GetPosition(ref Guid guid /* GUID for IApplicationViewPosition */, out IntPtr /* IApplicationViewPosition** */ position);
		int SetPosition(ref IntPtr /* IApplicationViewPosition* */ position);
		int InsertAfterWindow(IntPtr hwnd);
		int GetExtendedFramePosition(out Rect rect);
		int GetAppUserModelId([MarshalAs(UnmanagedType.LPWStr)] out string id);
		int SetAppUserModelId(string id);
		int IsEqualByAppUserModelId(string id, out int result);
		int GetViewState(out uint state);
		int SetViewState(uint state);
		int GetNeediness(out int neediness);
		int GetLastActivationTimestamp(out ulong timestamp);
		int SetLastActivationTimestamp(ulong timestamp);
		int GetVirtualDesktopId(out Guid guid);
		int SetVirtualDesktopId(ref Guid guid);
		int GetShowInSwitchers(out int flag);
		int SetShowInSwitchers(int flag);
		int GetScaleFactor(out int factor);
		int CanReceiveInput(out bool canReceiveInput);
		int GetCompatibilityPolicyType(out APPLICATION_VIEW_COMPATIBILITY_POLICY flags);
		int SetCompatibilityPolicyType(APPLICATION_VIEW_COMPATIBILITY_POLICY flags);
$(if ($Windows1607) {@"
		int GetPositionPriority(out IntPtr /* IShellPositionerPriority** */ priority);
		int SetPositionPriority(IntPtr /* IShellPositionerPriority* */ priority);
"@ })
		int GetSizeConstraints(IntPtr /* IImmersiveMonitor* */ monitor, out Size size1, out Size size2);
		int GetSizeConstraintsForDpi(uint uint1, out Size size1, out Size size2);
		int SetSizeConstraintsForDpi(ref uint uint1, ref Size size1, ref Size size2);
$(if ($Windows1607) {@"
		int QuerySizeConstraintsFromApp();
"@ })
		int OnMinSizePreferencesUpdated(IntPtr hwnd);
		int ApplyOperation(IntPtr /* IApplicationViewOperation* */ operation);
		int IsTray(out bool isTray);
		int IsInHighZOrderBand(out bool isInHighZOrderBand);
		int IsSplashScreenPresented(out bool isSplashScreenPresented);
		int Flash();
		int GetRootSwitchableOwner(out IApplicationView rootSwitchableOwner);
		int EnumerateOwnershipTree(out IObjectArray ownershipTree);
		int GetEnterpriseId([MarshalAs(UnmanagedType.LPWStr)] out string enterpriseId);
		int IsMirrored(out bool isMirrored);
$(if ($Windows1803) {@"
		int Unknown1(out int unknown);
		int Unknown2(out int unknown);
		int Unknown3(out int unknown);
		int Unknown4(out int unknown);
"@ })
$(if ($Windows1809) {@"
		int Unknown1(out int unknown);
		int Unknown2(out int unknown);
		int Unknown3(out int unknown);
		int Unknown4(out int unknown);
		int Unknown5(out int unknown);
		int Unknown6(int unknown);
		int Unknown7();
		int Unknown8(out int unknown);
		int Unknown9(int unknown);
		int Unknown10(int unknownX, int unknownY);
		int Unknown11(int unknown);
		int Unknown12(out Size size1);
"@ })
	}

	[ComImport]
	[InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
$(if ($Windows1607) {@"
// Windows 10 1607 and Server 2016:
	[Guid("2C08ADF0-A386-4B35-9250-0FE183476FCC")]
"@ })
$(if ($Windows1803) {@"
// Windows 10 1803:
	[Guid("2C08ADF0-A386-4B35-9250-0FE183476FCC")]
"@ })
$(if ($Windows1809) {@"
// Windows 10 1809:
	[Guid("1841C6D7-4F9D-42C0-AF41-8747538F10E5")]
"@ })
	internal interface IApplicationViewCollection
	{
		int GetViews(out IObjectArray array);
		int GetViewsByZOrder(out IObjectArray array);
		int GetViewsByAppUserModelId(string id, out IObjectArray array);
		int GetViewForHwnd(IntPtr hwnd, out IApplicationView view);
		int GetViewForApplication(object application, out IApplicationView view);
		int GetViewForAppUserModelId(string id, out IApplicationView view);
		int GetViewInFocus(out IntPtr view);
$(if ($Windows1803 -or $Windows1809) {@"
// Windows 10 1803 and 1809:
		int Unknown1(out IntPtr view);
"@ })
		void RefreshCollection();
		int RegisterForApplicationViewChanges(object listener, out int cookie);
$(if ($Windows1607) {@"
// Windows 10 1607 and Server 2016:
		int RegisterForApplicationViewPositionChanges(object listener, out int cookie);
"@ })
$(if ($Windows1803) {@"
// Windows 10 1803:
		int RegisterForApplicationViewPositionChanges(object listener, out int cookie);
"@ })
		int UnregisterForApplicationViewChanges(int cookie);
	}

	[ComImport]
	[InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
	[Guid("FF72FFDD-BE7E-43FC-9C03-AD81681E88E4")]
	internal interface IVirtualDesktop
	{
		bool IsViewVisible(IApplicationView view);
		Guid GetId();
	}

	[ComImport]
	[InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
	[Guid("F31574D6-B682-4CDC-BD56-1827860ABEC6")]
	internal interface IVirtualDesktopManagerInternal
	{
		int GetCount();
		void MoveViewToDesktop(IApplicationView view, IVirtualDesktop desktop);
		bool CanViewMoveDesktops(IApplicationView view);
		IVirtualDesktop GetCurrentDesktop();
		void GetDesktops(out IObjectArray desktops);
		[PreserveSig]
		int GetAdjacentDesktop(IVirtualDesktop from, int direction, out IVirtualDesktop desktop);
		void SwitchDesktop(IVirtualDesktop desktop);
		IVirtualDesktop CreateDesktop();
		void RemoveDesktop(IVirtualDesktop desktop, IVirtualDesktop fallback);
		IVirtualDesktop FindDesktop(ref Guid desktopid);
	}

	[ComImport]
	[InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
	[Guid("A5CD92FF-29BE-454C-8D04-D82879FB3F1B")]
	internal interface IVirtualDesktopManager
	{
		bool IsWindowOnCurrentVirtualDesktop(IntPtr topLevelWindow);
		Guid GetWindowDesktopId(IntPtr topLevelWindow);
		void MoveWindowToDesktop(IntPtr topLevelWindow, ref Guid desktopId);
	}

	[ComImport]
	[InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
	[Guid("4CE81583-1E4C-4632-A621-07A53543148F")]
	internal interface IVirtualDesktopPinnedApps
	{
		bool IsAppIdPinned(string appId);
		void PinAppID(string appId);
		void UnpinAppID(string appId);
		bool IsViewPinned(IApplicationView applicationView);
		void PinView(IApplicationView applicationView);
		void UnpinView(IApplicationView applicationView);
	}

	[ComImport]
	[InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
	[Guid("92CA9DCD-5622-4BBA-A805-5E9F541BD8C9")]
	internal interface IObjectArray
	{
		void GetCount(out int count);
		void GetAt(int index, ref Guid iid, [MarshalAs(UnmanagedType.Interface)]out object obj);
	}

	[ComImport]
	[InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
	[Guid("6D5140C1-7436-11CE-8034-00AA006009FA")]
	internal interface IServiceProvider10
	{
		[return: MarshalAs(UnmanagedType.IUnknown)]
		object QueryService(ref Guid service, ref Guid riid);
	}

	internal static class DesktopManager
	{
		static DesktopManager()
		{
			var shell = (IServiceProvider10)Activator.CreateInstance(Type.GetTypeFromCLSID(Guids.CLSID_ImmersiveShell));
			VirtualDesktopManagerInternal = (IVirtualDesktopManagerInternal)shell.QueryService(Guids.CLSID_VirtualDesktopManagerInternal, typeof(IVirtualDesktopManagerInternal).GUID);
			VirtualDesktopManager = (IVirtualDesktopManager)Activator.CreateInstance(Type.GetTypeFromCLSID(Guids.CLSID_VirtualDesktopManager));
			ApplicationViewCollection = (IApplicationViewCollection)shell.QueryService(typeof(IApplicationViewCollection).GUID, typeof(IApplicationViewCollection).GUID);
			VirtualDesktopPinnedApps = (IVirtualDesktopPinnedApps)shell.QueryService(Guids.CLSID_VirtualDesktopPinnedApps, typeof(IVirtualDesktopPinnedApps).GUID);
		}

		internal static IVirtualDesktopManagerInternal VirtualDesktopManagerInternal;
		internal static IVirtualDesktopManager VirtualDesktopManager;
		internal static IApplicationViewCollection ApplicationViewCollection;
		internal static IVirtualDesktopPinnedApps VirtualDesktopPinnedApps;

		internal static IVirtualDesktop GetDesktop(int index)
		{	// get desktop with index
			int count = VirtualDesktopManagerInternal.GetCount();
			if (index < 0 || index >= count) throw new ArgumentOutOfRangeException("index");
			IObjectArray desktops;
			VirtualDesktopManagerInternal.GetDesktops(out desktops);
			object objdesktop;
			desktops.GetAt(index, typeof(IVirtualDesktop).GUID, out objdesktop);
			Marshal.ReleaseComObject(desktops);
			return (IVirtualDesktop)objdesktop;
		}

		internal static int GetDesktopIndex(IVirtualDesktop desktop)
		{ // get index of desktop
			int index = -1;
			Guid IdSearch = desktop.GetId();
			IObjectArray desktops;
			VirtualDesktopManagerInternal.GetDesktops(out desktops);
			object objdesktop;
			for (int i = 0; i < VirtualDesktopManagerInternal.GetCount(); i++)
			{
				desktops.GetAt(i, typeof(IVirtualDesktop).GUID, out objdesktop);
				if (IdSearch.CompareTo(((IVirtualDesktop)objdesktop).GetId()) == 0)
				{ index = i;
					break;
				}
			}
			Marshal.ReleaseComObject(desktops);
			return index;
		}

		internal static IApplicationView GetApplicationView(this IntPtr hWnd)
		{ // get application view to window handle
			IApplicationView view;
			ApplicationViewCollection.GetViewForHwnd(hWnd, out view);
			return view;
		}

		internal static string GetAppId(IntPtr hWnd)
		{ // get Application ID to window handle
			string appId;
			hWnd.GetApplicationView().GetAppUserModelId(out appId);
			return appId;
		}
	}

	public class WindowInformation
	{ // stores window informations
		public string Title { get; set; }
		public int Handle { get; set; }
	}

	public class Desktop
	{
		private IVirtualDesktop ivd;
		private Desktop(IVirtualDesktop desktop) { this.ivd = desktop; }

		public override int GetHashCode()
		{ // Get hash
			return ivd.GetHashCode();
		}

		public override bool Equals(object obj)
		{ // Compares with object
			var desk = obj as Desktop;
			return desk != null && object.ReferenceEquals(this.ivd, desk.ivd);
		}

		public static int Count
		{ // Returns the number of desktops
			get { return DesktopManager.VirtualDesktopManagerInternal.GetCount(); }
		}

		public static Desktop Current
		{ // Returns current desktop
			get { return new Desktop(DesktopManager.VirtualDesktopManagerInternal.GetCurrentDesktop()); }
		}

		public static Desktop FromIndex(int index)
		{ // Create desktop object from index 0..Count-1
			return new Desktop(DesktopManager.GetDesktop(index));
		}

		public static Desktop FromWindow(IntPtr hWnd)
		{ // Creates desktop object on which window <hWnd> is displayed
			if (hWnd == IntPtr.Zero) throw new ArgumentNullException();
			Guid id = DesktopManager.VirtualDesktopManager.GetWindowDesktopId(hWnd);
			return new Desktop(DesktopManager.VirtualDesktopManagerInternal.FindDesktop(ref id));
		}

		public static int FromDesktop(Desktop desktop)
		{ // Returns index of desktop object or -1 if not found
			return DesktopManager.GetDesktopIndex(desktop.ivd);
		}

		public static Desktop Create()
		{ // Create a new desktop
			return new Desktop(DesktopManager.VirtualDesktopManagerInternal.CreateDesktop());
		}

		public void Remove(Desktop fallback = null)
		{ // Destroy desktop and switch to <fallback>
			IVirtualDesktop fallbackdesktop;
			if (fallback == null)
			{ // if no fallback is given use desktop to the left except for desktop 0.
				Desktop dtToCheck = new Desktop(DesktopManager.GetDesktop(0));
				if (this.Equals(dtToCheck))
				{ // desktop 0: set fallback to second desktop (= "right" desktop)
					DesktopManager.VirtualDesktopManagerInternal.GetAdjacentDesktop(ivd, 4, out fallbackdesktop); // 4 = RightDirection
				}
				else
				{ // set fallback to "left" desktop
					DesktopManager.VirtualDesktopManagerInternal.GetAdjacentDesktop(ivd, 3, out fallbackdesktop); // 3 = LeftDirection
				}
			}
			else
				// set fallback desktop
				fallbackdesktop = fallback.ivd;

			DesktopManager.VirtualDesktopManagerInternal.RemoveDesktop(ivd, fallbackdesktop);
		}

		public bool IsVisible
		{ // Returns <true> if this desktop is the current displayed one
			get { return object.ReferenceEquals(ivd, DesktopManager.VirtualDesktopManagerInternal.GetCurrentDesktop()); }
		}

		public void MakeVisible()
		{ // Make this desktop visible
			DesktopManager.VirtualDesktopManagerInternal.SwitchDesktop(ivd);
		}

		public Desktop Left
		{ // Returns desktop at the left of this one, null if none
			get
			{
				IVirtualDesktop desktop;
				int hr = DesktopManager.VirtualDesktopManagerInternal.GetAdjacentDesktop(ivd, 3, out desktop); // 3 = LeftDirection
				if (hr == 0)
					return new Desktop(desktop);
				else
					return null;
			}
		}

		public Desktop Right
		{ // Returns desktop at the right of this one, null if none
			get
			{
				IVirtualDesktop desktop;
				int hr = DesktopManager.VirtualDesktopManagerInternal.GetAdjacentDesktop(ivd, 4, out desktop); // 4 = RightDirection
				if (hr == 0)
					return new Desktop(desktop);
				else
					return null;
			}
		}

		public void MoveWindow(IntPtr hWnd)
		{ // Move window <hWnd> to this desktop
			if (hWnd == IntPtr.Zero) throw new ArgumentNullException();
			if (hWnd == GetConsoleWindow())
			{ // own window
				try // the easy way (powershell's own console)
				{
					DesktopManager.VirtualDesktopManager.MoveWindowToDesktop(hWnd, ivd.GetId());
				}
				catch // powershell in cmd console
				{
					IApplicationView view;
					DesktopManager.ApplicationViewCollection.GetViewForHwnd(hWnd, out view);
					DesktopManager.VirtualDesktopManagerInternal.MoveViewToDesktop(view, ivd);
				}
			}
			else
			{ // window of other process
				IApplicationView view;
				DesktopManager.ApplicationViewCollection.GetViewForHwnd(hWnd, out view);
				DesktopManager.VirtualDesktopManagerInternal.MoveViewToDesktop(view, ivd);
			}
		}

		public bool HasWindow(IntPtr hWnd)
		{ // Returns true if window <hWnd> is on this desktop
			if (hWnd == IntPtr.Zero) throw new ArgumentNullException();
			return ivd.GetId() == DesktopManager.VirtualDesktopManager.GetWindowDesktopId(hWnd);
		}

		public static bool IsWindowPinned(IntPtr hWnd)
		{ // Returns true if window <hWnd> is pinned to all desktops
			if (hWnd == IntPtr.Zero) throw new ArgumentNullException();
			return DesktopManager.VirtualDesktopPinnedApps.IsViewPinned(hWnd.GetApplicationView());
		}

		public static void PinWindow(IntPtr hWnd)
		{ // pin window <hWnd> to all desktops
			if (hWnd == IntPtr.Zero) throw new ArgumentNullException();
			var view = hWnd.GetApplicationView();
			if (!DesktopManager.VirtualDesktopPinnedApps.IsViewPinned(view))
			{ // pin only if not already pinned
				DesktopManager.VirtualDesktopPinnedApps.PinView(view);
			}
		}

		public static void UnpinWindow(IntPtr hWnd)
		{ // unpin window <hWnd> from all desktops
			if (hWnd == IntPtr.Zero) throw new ArgumentNullException();
			var view = hWnd.GetApplicationView();
			if (DesktopManager.VirtualDesktopPinnedApps.IsViewPinned(view))
			{ // unpin only if not already unpinned
				DesktopManager.VirtualDesktopPinnedApps.UnpinView(view);
			}
		}

		public static bool IsApplicationPinned(IntPtr hWnd)
		{ // Returns true if application for window <hWnd> is pinned to all desktops
			if (hWnd == IntPtr.Zero) throw new ArgumentNullException();
			return DesktopManager.VirtualDesktopPinnedApps.IsAppIdPinned(DesktopManager.GetAppId(hWnd));
		}

		public static void PinApplication(IntPtr hWnd)
		{ // pin application for window <hWnd> to all desktops
			if (hWnd == IntPtr.Zero) throw new ArgumentNullException();
			string appId = DesktopManager.GetAppId(hWnd);
			if (!DesktopManager.VirtualDesktopPinnedApps.IsAppIdPinned(appId))
			{ // pin only if not already pinned
				DesktopManager.VirtualDesktopPinnedApps.PinAppID(appId);
			}
		}

		public static void UnpinApplication(IntPtr hWnd)
		{ // unpin application for window <hWnd> from all desktops
			if (hWnd == IntPtr.Zero) throw new ArgumentNullException();
			var view = hWnd.GetApplicationView();
			string appId = DesktopManager.GetAppId(hWnd);
			if (DesktopManager.VirtualDesktopPinnedApps.IsAppIdPinned(appId))
			{ // unpin only if already pinned
				DesktopManager.VirtualDesktopPinnedApps.UnpinAppID(appId);
			}
		}

		// get window handle of current console window (even if powershell started in cmd)
		[DllImport("Kernel32.dll")]
		public static extern IntPtr GetConsoleWindow();

		// get handle of active window
		[DllImport("user32.dll")]
		public static extern IntPtr GetForegroundWindow();

		// prepare callback function for window enumeration
		private delegate bool CallBackPtr(int hwnd, int lParam);
		private static CallBackPtr callBackPtr = Callback;
		// list of window informations
		private static List<WindowInformation> WindowInformationList = new List<WindowInformation>();

		// enumerate windows
		[DllImport("User32.dll", SetLastError = true)]
		[return: MarshalAs(UnmanagedType.Bool)]
		private static extern bool EnumWindows(CallBackPtr lpEnumFunc, IntPtr lParam);

		// get window title length
		[DllImport("User32.dll", CharSet = CharSet.Auto, SetLastError = true)]
		private static extern int GetWindowTextLength(IntPtr hWnd);

		// get window title
		[DllImport("User32.dll", CharSet = CharSet.Auto, SetLastError = true)]
		private static extern int GetWindowText(IntPtr hWnd, StringBuilder lpString, int nMaxCount);

		// callback function for window enumeration
		private static bool Callback(int hWnd, int lparam)
		{
			int length = GetWindowTextLength((IntPtr)hWnd);
			if (length > 0)
			{
				StringBuilder sb = new StringBuilder(length + 1);
				if (GetWindowText((IntPtr)hWnd, sb, sb.Capacity) > 0)
				{ WindowInformationList.Add(new WindowInformation {Handle = hWnd, Title = sb.ToString()}); }
			}
			return true;
		}

		// get list of all windows with title
		public static List<WindowInformation> GetWindows()
		{
			WindowInformationList = new List<WindowInformation>();
			EnumWindows(callBackPtr, IntPtr.Zero);
			return WindowInformationList;
		}

		// find first window with string in title
		public static WindowInformation FindWindow(string WindowTitle)
		{
			WindowInformationList = new List<WindowInformation>();
			EnumWindows(callBackPtr, IntPtr.Zero);
			WindowInformation result = WindowInformationList.Find(x => x.Title.IndexOf(WindowTitle, StringComparison.OrdinalIgnoreCase) >= 0);
			return result;
		}
	}
}
"@
        }
    }

    # Used for debugging
    Function Write-Log {
        Param(
        [Parameter(Mandatory=$True)]
        [string]
        $Message,
        [Parameter(Mandatory=$False)]
        [ValidateSet("INFO","WARN","ERROR","FATAL","DEBUG")]
        [String]
        $Level = "INFO",
        [Parameter(Mandatory=$False)]
        [string]
        $Logfile = "$(gc env:userprofile)\Desktop\screenshots_log_$(Get-Date -Format "MM-dd-yyyy").log"
        )
        $Stamp = (Get-Date).toString("yyyy/MM/dd HH:mm:ss.fff")
        $Line = "Time: $Stamp - Level: $Level - Message: $Message"
        Add-Content $Logfile -Value $Line
    }

    #The about page
    function about {
      $global:state = 99
      [System.Windows.Forms.MessageBox]::Show("Screenshot Powershell Utility version 4.1`r`n`r`nCreated by Dylan Langston") | Out-null
    }

    #Takes Screenshot
    function takescreenshot {
      if ($AsktoSave -eq $true) {
        $SaveFileDialog = (New-Object windows.forms.savefiledialog)
        $SaveFileDialog.initialDirectory = $env:USERPROFILE
        $SaveFileDialog.title = "Save Screenshot"
        $SaveFileDialog.filter = "PNG|*.png|All Files|*.*"
        $SaveFileDialog.ShowHelp = $False
        $SaveFileDialog.OverwritePrompt = $False
        $result = $SaveFileDialog.ShowDialog()
        if ($result -eq "OK") {
          $global:Folder = Split-Path $SaveFileDialog.filename
          $global:Name = [System.IO.Path]::GetFileNameWithoutExtension($SaveFileDialog.filename)
          $global:File = "$Folder\" + "$Name"
        } else {
          $global:Name = "Screenshot_$(get-date -Format 'MM-dd-yyyy_HHmmss')"
          $global:File = "$Folder\" + "$Name"
        }
      }
      if ($ResetFilename -eq $true -and $AsktoSave -ne $true) {
        $global:Name = "Screenshot_$(get-date -Format 'MM-dd-yyyy_HHmmss')"
        $global:File = "$Folder\" + "$Name"
      }
      remove-job -Name "activewindows" -Force | Out-Null
      (getActive($([io.path]::GetFileNameWithoutExtension($scriptname)))) | Out-Null
      $Window.width = $Screen.width
      $Border.width = $Screen.width
      $Window.height = $Screen.height
      $Border.height = $Screen.height
      $Window.Cursor = "Cross"
      if ($OSVer -ge 10){ if ($OSBuild -ge 14392){
        if (-not ([VirtualDesktop.Desktop]::Current).HasWindow($scripthandle)) {
            ([VirtualDesktop.Desktop]::Current).MoveWindow($scripthandle)
        }
      }}
      $Window.Activate()
      $global:recentlist = @()
      $global:screenshotcounter = 1
      $global:konami = @()
      $global:state = 0
      # Sends Middle Mouse button which ensures the window is in focus.
      $signature=@' 
      [DllImport("user32.dll",CharSet=CharSet.Auto, CallingConvention=CallingConvention.StdCall)]
      public static extern void mouse_event(long dwFlags, long dx, long dy, long cButtons, long dwExtraInfo);
'@ 
      $SendMouseClick = Add-Type -memberDefinition $signature -name "Win32MouseEventNew" -namespace Win32Functions -passThru 
      $SendMouseClick::mouse_event(0x00000020, 0, 0, 0, 0);
      $SendMouseClick::mouse_event(0x00000040, 0, 0, 0, 0);
    }

    # Get List of Active Windows
    function getActive() {
      param(
        [string]
        $scriptname = "foo"
      )
      Start-Job -Name "activewindows" -ScriptBlock {
        param(
          [string]
          $scriptname = "foo",
          [int]
          $PID1 = 0
        )
        function getActive() {
            param(
              [string]
              $scriptname1 = "foo",
              [int]
              $PID2 = 0
            )
            $blacklist = @("explorer", "g2mstart", "g2mlauncher", $scriptname1) #List of processes to ignore
            $whitelist = @("SupportFlow") #List of processes to add to the list of active windows, even if not responding.
            try {
            Add-Type @"
      using System;
      using System.Runtime.InteropServices;
      public class GetRecent {
        [DllImport("user32.dll")]
        public static extern IntPtr GetWindow(IntPtr handle, int uCmd);
        [DllImport("user32.dll")]
        public static extern IntPtr GetForegroundWindow();
      }
"@
            $processes = Get-Process
            $CurrentHNDL = $(($processes) | Where-Object { $_.Id -eq $PID2 }).MainWindowHandle
            $FirstWindow = $([GetRecent]::GetWindow($([GetRecent]::GetForegroundWindow()),[int]1))
            $CurrentWindow = $FirstWindow
            $handles = @()
            $LOOP = $true
            while ($LOOP) {
              if ($CurrentWindow -ne $CurrentHNDL) {
                $handles += $CurrentWindow
                $CurrentWindow = $([GetRecent]::GetWindow($CurrentWindow,[int]3))
              }
              else { $LOOP = $false }
            }
            $processesMWH = $processes.MainWindowHandle
            $zorder = @()
            [array]::Reverse($handles)
            foreach ($handle in $handles) {
              if ($processesMWH -contains $handle) {
                $zorder += $(($processesMWH | Where-Object { $_ -eq $handle }))
              }
              if ($zorder.length -eq 15) {
                break
              }
            }
            $recentlist = @()
            foreach ($z in $zorder) {
              $recentlisttmp = $processes[$([array]::IndexOf($processesMWH,$z))]
              # Verifies the process is responding (or isn't responding but is on the whitelist) and isn't on the blacklist. If this isn't true then it's skipped, otherwise it's appended to the recentlist.
              if ($($recentlisttmp.Responding -or $($Whitelist.Contains($recentlisttmp.name))) -and $(-not $blacklist.Contains($recentlisttmp.name))) { $recentlist += $recentlisttmp }
            }
            } catch {
              $recentlist = @()
            }
            $recentlist = $recentlist + @("end")
            return $recentlist
        }
        (getActive $scriptname $PID1)
      } -ArgumentList $scriptname,$PID
    }

    # Function that monitors for a specific keypress as a trigger
    # Thanks to, https://hinchley.net/articles/creating-a-key-logger-via-a-global-system-hook-using-powershell/
    function monitorKey {
      param(
        [int]
        $scanCode = 55
      )
      if ($(Get-Job -Name "checkforkey").State -eq "Running") {
        sendKey ($scanCode) # Ends the keyboard monitor process by pressing the key
      }
      Remove-Job -Name "checkforkey" -Force
      Start-Job -Name "checkforkey" -ScriptBlock {
        param(
          [int]
          $scanCode = 55
        )
        Write-Output $PID
        function checkKey () {
          param(
            [int]
            $scanCode1 = 55
          )
          if (-not ([System.Management.Automation.PSTypeName]'Key').Type) {
            Add-Type -TypeDefinition @"
using System;
using System.IO;
using System.Diagnostics;
using System.Runtime.InteropServices;
using System.Windows.Forms;
using System.Management.Automation;
using System.Management.Automation.Runspaces;

namespace Key {
  public static class Program {
    public const int WH_KEYBOARD_LL = 13;
    public const int WM_KEYDOWN = 0x0100;
    public static int scanCode = 55;

    public static HookProc hookProc = HookCallback;
    public static IntPtr hookId = IntPtr.Zero;

    [StructLayout(LayoutKind.Sequential)]
    public class KBDLLHOOKSTRUCT {
      public uint vkCode;
      public uint scanCode;
      public KBDLLHOOKSTRUCTFlags flags;
      public uint time;
      public UIntPtr dwExtraInfo;
    }

    [Flags]
    public enum KBDLLHOOKSTRUCTFlags : uint {
      LLKHF_EXTENDED = 0x01,
      LLKHF_INJECTED = 0x10,
      LLKHF_ALTDOWN = 0x20,
      LLKHF_UP = 0x80,
    }

    public static void Main() {
      hookId = SetHook(hookProc);
      Application.Run();
      UnhookWindowsHookEx(hookId);
    }

    public static void setScanCode(int newCode) {
        scanCode = newCode;
        Main();
    }

    public static IntPtr SetHook(HookProc hookProc) {
      IntPtr moduleHandle = GetModuleHandle(Process.GetCurrentProcess().MainModule.ModuleName);
      return SetWindowsHookEx(WH_KEYBOARD_LL, hookProc, moduleHandle, 0);
    }

    public delegate IntPtr HookProc(int nCode, IntPtr wParam, IntPtr lParam);

    public static IntPtr HookCallback(int nCode, IntPtr wParam, IntPtr lParam) {
      if (nCode >= 0 && wParam == (IntPtr)WM_KEYDOWN) {
      KBDLLHOOKSTRUCT kbd = (KBDLLHOOKSTRUCT) Marshal.PtrToStructure(lParam, typeof(KBDLLHOOKSTRUCT));
      Console.WriteLine("scancode: " + kbd.vkCode); // write scan code to console, uncomment this line when trying to find the scancode for a specific key
      if (kbd.vkCode == scanCode) {
        using (PowerShell initialPowerShell = PowerShell.Create(RunspaceMode.CurrentRunspace)){
            initialPowerShell.Commands.AddScript("Write-verbose \"" + ((kbd.vkCode).ToString()) + "\" -v");
            initialPowerShell.Invoke();
        }
        Application.Exit();
        return (IntPtr)1;
        }
      }
      return CallNextHookEx(hookId, nCode, wParam, lParam);
    }

    [DllImport("user32.dll")]
    public static extern IntPtr SetWindowsHookEx(int idHook, HookProc lpfn, IntPtr hMod, uint dwThreadId);

    [DllImport("user32.dll")]
    public static extern bool UnhookWindowsHookEx(IntPtr hhk);

    [DllImport("user32.dll")]
    public static extern IntPtr CallNextHookEx(IntPtr hhk, int nCode, IntPtr wParam, IntPtr lParam);

    [DllImport("kernel32.dll")]
    public static extern IntPtr GetModuleHandle(string lpModuleName);
  }
}
"@ -ReferencedAssemblies System.Windows.Forms
          }
          try {
            $key = ([Key.Program]::setScanCode($scanCode1) 4>&1)
            if (([int]($key.ToString())) -eq $scanCode1) {
              return $true
            } else {
              return $false
            }
          }
          catch {
            return $false
          }
        }
        checkKey ($scanCode)
      } -ArgumentList $scanCode | Out-Null
    }

    # Emulates a keypress using the scancode. Used on exit.
    function sendKey {
      param(
        [int]
        $scanCode = 55
      )
      Add-Type @"
using System;
using System.Collections.Generic;
using System.Runtime.InteropServices;

public static class KBEmulator {
    public enum InputType : uint {
        INPUT_MOUSE = 0,
        INPUT_KEYBOARD = 1,
        INPUT_HARDWARE = 3
    }

    [Flags]
    internal enum KEYEVENTF : uint
    {
        KEYDOWN = 0x0,
        EXTENDEDKEY = 0x0001,
        KEYUP = 0x0002,
        SCANCODE = 0x0008,
        UNICODE = 0x0004
    }

    [Flags]
    internal enum MOUSEEVENTF : uint
    {
        ABSOLUTE = 0x8000,
        HWHEEL = 0x01000,
        MOVE = 0x0001,
        MOVE_NOCOALESCE = 0x2000,
        LEFTDOWN = 0x0002,
        LEFTUP = 0x0004,
        RIGHTDOWN = 0x0008,
        RIGHTUP = 0x0010,
        MIDDLEDOWN = 0x0020,
        MIDDLEUP = 0x0040,
        VIRTUALDESK = 0x4000,
        WHEEL = 0x0800,
        XDOWN = 0x0080,
        XUP = 0x0100
    }

    // Master Input structure
    [StructLayout(LayoutKind.Sequential)]
    public struct lpInput {
        internal InputType type;
        internal InputUnion Data;
        internal static int Size { get { return Marshal.SizeOf(typeof(lpInput)); } }
    }

    // Union structure
    [StructLayout(LayoutKind.Explicit)]
    internal struct InputUnion {
        [FieldOffset(0)]
        internal MOUSEINPUT mi;
        [FieldOffset(0)]
        internal KEYBDINPUT ki;
        [FieldOffset(0)]
        internal HARDWAREINPUT hi;
    }

    // Input Types
    [StructLayout(LayoutKind.Sequential)]
    internal struct MOUSEINPUT
    {
        internal int dx;
        internal int dy;
        internal int mouseData;
        internal MOUSEEVENTF dwFlags;
        internal uint time;
        internal UIntPtr dwExtraInfo;
    }

    [StructLayout(LayoutKind.Sequential)]
    internal struct KEYBDINPUT
    {
        internal short wVk;
        internal short wScan;
        internal KEYEVENTF dwFlags;
        internal int time;
        internal UIntPtr dwExtraInfo;
    }

    [StructLayout(LayoutKind.Sequential)]
    internal struct HARDWAREINPUT
    {
        internal int uMsg;
        internal short wParamL;
        internal short wParamH;
    }

    private class unmanaged {
        [DllImport("user32.dll", SetLastError = true)]
        internal static extern uint SendInput (
            uint cInputs,
            [MarshalAs(UnmanagedType.LPArray)]
            lpInput[] inputs,
            int cbSize
        );

        [DllImport("user32.dll", CharSet = CharSet.Unicode, SetLastError = true)]
        public static extern short VkKeyScan(char ch);
    }

    internal static uint SendInput(uint cInputs, lpInput[] inputs, int cbSize) {
        return unmanaged.SendInput(cInputs, inputs, cbSize);
    }

    public static void SendScanCode(short scanCode) {
        lpInput[] KeyInputs = new lpInput[1];
        lpInput KeyInput = new lpInput();
        // Generic Keyboard Event
        KeyInput.type = InputType.INPUT_KEYBOARD;
        KeyInput.Data.ki.wScan = 0;
        KeyInput.Data.ki.wVk = 0;
        KeyInput.Data.ki.time = 0;
        KeyInput.Data.ki.dwExtraInfo = UIntPtr.Zero;


        // Push the correct key
        KeyInput.Data.ki.wVk = scanCode;
        KeyInput.Data.ki.dwFlags = KEYEVENTF.KEYDOWN;
        KeyInputs[0] = KeyInput;
        SendInput(1, KeyInputs, lpInput.Size);

        // Release the key
        KeyInput.Data.ki.dwFlags = KEYEVENTF.KEYUP;
        KeyInputs[0] = KeyInput;
        SendInput(1, KeyInputs, lpInput.Size);

        return;
    }
}
"@
      [KBEmulator]::SendScanCode($scanCode)
    }

    # Get Window
    function getWindow {
      # Thanks to https://gallery.technet.microsoft.com/scriptcenter/Get-the-position-of-a-c91a5f1f
      # Thanks to https://github.com/ShareX/ShareX/blob/e81176a8398993d3208f9ca83b0422f6e53ef48d/ShareX.HelpersLib/Helpers/CaptureHelpers.cs#L310
      if (-not ([System.Management.Automation.PSTypeName]'Window').Type) {
        Add-Type -AssemblyName UIAutomationClient
        Add-Type @"
      using System;
      using System.Runtime.InteropServices;
      public class Window {
        [DllImport(@"dwmapi.dll")]
        public static extern int DwmGetWindowAttribute(IntPtr hwnd, int dwAttribute, out RECT pvAttribute, int cbAttribute);
        [DllImport("user32.dll")]
        public static extern bool ShowWindowAsync(IntPtr hWnd, Int32 nCmdShow);
        [DllImport("user32.dll")]
        public static extern int SetForegroundWindow(IntPtr hwnd);
        [DllImport("user32.dll")]
        public static extern IntPtr GetForegroundWindow();
        [DllImport("user32.dll", SetLastError=true)]
        public static extern int GetWindowLong(IntPtr hWnd, int nIndex);
        public enum Dwmwindowattribute
        {
          DwmwaExtendedFrameBounds = 9
        }
        public static bool DWMWA_EXTENDED_FRAME_BOUNDS(IntPtr handle, out RECT rectangle)
        {
        RECT rect;
        var result = DwmGetWindowAttribute(handle, (int)Dwmwindowattribute.DwmwaExtendedFrameBounds,
            out rect, Marshal.SizeOf(typeof(RECT)));
        rectangle = rect;
        return result >= 0;
        }
      }
      public struct RECT
      {
        public int Left;        // x position of upper-left corner
        public int Top;         // y position of upper-left corner
        public int Right;       // x position of lower-right corner
        public int Bottom;      // y position of lower-right corner
      }
"@
      }
      #Prompt which window to display, https://docs.microsoft.com/en-us/powershell/scripting/samples/multiple-selection-list-boxes?view=powershell-6
      $form = New-Object System.Windows.Forms.Form
      $form.Size = New-Object System.Drawing.Size (298,290)
      $form.StartPosition = 'CenterScreen'
      $form.ShowIcon = $False
      $form.MaximizeBox = $false
      $form.MinimizeBox = $False
      $form.SizeGripStyle = "Hide"
      $form.FormBorderStyle = "FixedDialog"
      $form.ShowInTaskbar = $False
      $form.text = 'Select an Window to Capture:'
      $listBox = New-Object System.Windows.Forms.Listbox
      $listBox.Location = New-Object System.Drawing.Point (10,10)
      $listBox.Size = New-Object System.Drawing.Size (260,200)
      $listboxhndl = @()
      foreach ($process in $recentlist) {
        # Exit when at the end of the list
        if ($process -eq "end") {break}
        # Use Process Description, main Window title, or process name (in that order) to populate list. We create a second list with the handles in the same order so we can use those again later.
        $listboxhndl += $($process.MainWindowHandle)
        if ($null -ne ($process.Description)) {
          # Check if there are multiple processes with the same Description, if so include the ID in the selection
          if (($recentlist.Description | Where-Object { $_ -eq $process.Description }).count -gt 1) {
            $listBox.Items.Add("$($process.Description) - ID:$($process.id)")
          } else { $listBox.Items.Add("$($process.Description)") }
        } elseif ($null -ne ($process.MainWindowTitle) -and ($process.MainWindowTitle).length -lt 50) { # If the Window title is more than 50 characters long we just use the process name.
          # Check if there are multiple processes with the same Window Title, if so include the ID in the selection
          if (($recentlist.MainWindowTitle | Where-Object { $_ -eq $process.MainWindowTitle }).count -gt 1) {
            $listBox.Items.Add("$($process.MainWindowTitle) - ID:$($process.id)")
          } else { $listBox.Items.Add("$($process.MainWindowTitle)") }
        } else {
          # Check if there are multiple processes with the same name, if so include the ID in the selection
          if (($recentlist.Name | Where-Object { $_ -eq $process.Name }).count -gt 1) {
            $listBox.Items.Add("$((Get-Culture).TextInfo.ToTitleCase($process.Name)) - ID:$($process.id)")
          } else { $listBox.Items.Add("$((Get-Culture).TextInfo.ToTitleCase($process.Name))") }
        }
      }
      $listbox.SetSelected(0,$true)
      $form.Controls.Add($listBox)
      $OKButton = New-Object System.Windows.Forms.Button
      $OKButton.Location = New-Object System.Drawing.Point (60,220)
      $OKButton.Size = New-Object System.Drawing.Size (75,23)
      $OKButton.text = 'OK'
      $OKButton.DialogResult = [System.Windows.Forms.DialogResult]::Ok
      $form.AcceptButton = $OKButton
      $form.Controls.Add($OKButton)
      $CancelButton = New-Object System.Windows.Forms.Button
      $CancelButton.Location = New-Object System.Drawing.Point (150,220)
      $CancelButton.Size = New-Object System.Drawing.Size (75,23)
      $CancelButton.text = 'Cancel'
      $CancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
      $form.CancelButton = $CancelButton
      $form.Controls.Add($CancelButton)
      $form.Topmost = $true
      # Display Window Prompt
      $result = $form.ShowDialog()
      if ($result -eq [System.Windows.Forms.DialogResult]::Ok)
      {
        # Get Window from List
        $w = $listBox.SelectedItems
        $WindowObject = $recentlist | Where-Object { $_.MainWindowHandle -eq $($listboxhndl[$([array]::IndexOf($($listBox.Items),$([string]$w)))]) } | ForEach-Object {
          # Reorder Recents List to move selected item to top of list
          $global:recentlist = @($_) + ($recentlist -ne $_)
          # Get Window Info
          [int]$Handle = $_.MainWindowHandle
          $WindowLong = [string]$([Window]::GetWindowLong($Handle,-16))
          $global:ScriptHandle = [Window]::GetForegroundWindow()
          # Check if one Windows 10
          if ($OSVer -ge 10){ if ($OSBuild -ge 14392){
              # Make Workspace with Window Visable.
              ([VirtualDesktop.Desktop]::FromWindow($Handle)).MakeVisible()
            }
          }
          # Check if Window is Maxmized or not. Show the window in the same way.
          if ($WindowLong -eq 399441920 -or $WindowLong -eq -1781596160) { [Window]::ShowWindowAsync($Handle,3) } else { [Window]::ShowWindowAsync($Handle,4) }
          [Window]::SetForegroundWindow($Handle)
          Start-Sleep -Milliseconds 200
          $Rectangle = New-Object RECT
          $Return = [Window]::DWMWA_EXTENDED_FRAME_BOUNDS($Handle,[ref]$Rectangle)
          if ($Return) {
            $Height = $Rectangle.bottom - $Rectangle.Top
            $Width = $Rectangle.right - $Rectangle.left
            $Size = New-Object System.Management.Automation.Host.Size -ArgumentList $Width,$Height
            $TopLeft = New-Object System.Management.Automation.Host.Coordinates -ArgumentList $Rectangle.left,$Rectangle.Top
            $BottomRight = New-Object System.Management.Automation.Host.Coordinates -ArgumentList $Rectangle.right,$Rectangle.bottom
            $Object = [pscustomobject]@{
              Size = $Size
              TopLeft = $TopLeft
              BottomRight = $BottomRight
            }
            $Object.PSTypeNames.insert(0,'System.Automation.WindowInfo')
            $Object
          }
        }
        # Set border to the window size.
        # Old Code, didn't work in many monitor configurations (specificially ones I was trying to use lol)
        # This has Multimonitor support but it could probably be improved... Not sure specifically how though. Written trial by fire style since there are so many monitor configs.
        # Supporting them all is kinda impossible but this code hopefully interates on the older versions and supports more monitor configs. ? 
        [int]$monitorRight = $([math]::abs($Screen.Width - $([int]$WindowObject.BottomRight.x) + $Screen.Left))
        [int]$monitorBottom = $([math]::abs($Screen.height - $([int]$WindowObject.BottomRight.y) + $Screen.Top))
        # Fix Problem Apps, certain apps return the wrong size. This corrects it but requires that the app be manaully added to the list and so is currently disabled until it can be improved.
        #$promlemList = "Microsoft Outlook.*|foo.*"
        #$check = [regex]::matches($w, $problemList)
        #if ($check.groups.count -gt 0) {
            #$monitorRight = $monitorRight - 8
            #$monitorBottom = $monitorBottom + 8
        #}
        [int]$monitorLeft = $screen.width - ([int]$monitorRight + [int]$WindowObject.Size.width)
        [int]$monitorTop = $Screen.Height - ([int]$monitorBottom + [int]$WindowObject.Size.height)
        if ($monitorLeft -lt 0) { 
            $monitorRight = $monitorRight - $monitorLeft
            $monitorLeft = 0
        }
        if ($monitorTop -lt 0) {
            $monitorBottom = $monitorBottom - $monitorTop
            $monitorTop = 0
        }
        if ($([int]$WindowObject.BottomRight.x) -gt $Screen.width) { $monitorRight = 0 }
        if ($([int]$WindowObject.BottomRight.y) -gt $Screen.height) { $monitorBottom = 0 }
        $Border.BorderThickness = "$monitorLeft, $monitorTop, $monitorRight, $monitorBottom" # Set Border
        $global:state = 3 # Crop Image and Display
      }
      else {
        $global:state = 1 # Reset
      }
    }

    # Function Takes the current size and crops the framebuffer
    function cropImage {
      if (-not $(Test-Path "$File.png")) {
        $Window.height = 0
        $Window.Opacity = 0
        if ($Window.height -eq 0) {
          # Get drawn rectangle and take screenshot
          $bitmap = New-Object System.Drawing.Bitmap $($Screen.width - [int]$($border.BorderThickness.left + $border.BorderThickness.right)),$($Screen.height - [int]$($border.BorderThickness.Top + $border.BorderThickness.bottom))
          if (-not $($bitmap.Size)) {
            # If no border was drawn then take screenshot of entire screen
            $bitmap = New-Object System.Drawing.Bitmap $($Screen.width),$($Screen.height)
            $graphic = [System.Drawing.Graphics]::FromImage($bitmap)
            $graphic.CopyFromScreen($Screen.X,$Screen.Y,0,0,$bitmap.Size)
          }
          else {
            $graphic = [System.Drawing.Graphics]::FromImage($bitmap)
            $graphic.CopyFromScreen($($border.BorderThickness.left + $Screen.X),$($border.BorderThickness.Top + $Screen.Y),0,0,$bitmap.Size)
          }
          # Save Image to Stream
          $Stream = New-Object System.IO.MemoryStream
          $bitmap.Save($Stream,'PNG')
          $bitmap.close()
          $Window.Cursor = "Arrow"
          # Save Stream to File
          $Save = New-Object IO.FileStream "$File.png",'Append','Write','Read'
          $Stream.WriteTo($Save)
          $Save.close()
          $Save.Dispose()
          # Set Border color to windows Accent, https://stackoverflow.com/a/33058136
          Add-Type @"
    using System;
    using System.Runtime.InteropServices;
    using System.Windows;
    public static class NativeMethods
    {
        [DllImport("dwmapi.dll", EntryPoint="#127")]
        public static extern void DwmGetColorizationParameters(ref DWMCOLORIZATIONcolors colors);
        public static uint red(DWMCOLORIZATIONcolors colors)
        {
            return (byte)(colors.ColorizationColor >> 16);
        }
        public static uint green(DWMCOLORIZATIONcolors colors)
        {
            return (byte)(colors.ColorizationColor >> 8);
        }
        public static uint blue(DWMCOLORIZATIONcolors colors)
        {
            return (byte)(colors.ColorizationColor);
        }
    }

    public struct DWMCOLORIZATIONcolors
    {
        public uint ColorizationColor,
            ColorizationAfterglow,
            ColorizationColorBalance,
            ColorizationAfterglowBalance,
            ColorizationBlurBalance,
            ColorizationGlassReflectionIntensity,
            ColorizationOpaqueBlend;
    }
"@
          $color = New-Object DWMCOLORIZATIONcolors
          [NativeMethods]::DwmGetColorizationParameters([ref]$color)
          $Border.BorderBrush = "" + $("#" + "FF" + [Convert]::ToString(([NativeMethods]::red($color) * 3 / 4),16).ToUpper().PadLeft(2,'0') + [Convert]::ToString(([NativeMethods]::green($color) * 3 / 4),16).ToUpper().PadLeft(2,'0') + [Convert]::ToString(([NativeMethods]::blue($color) * 3 / 4),16).ToUpper().PadLeft(2,'0'))
          # Set background to Cropped Image
          $cropped.Source = "$File.png"
          $cropped.Opacity = 1
          $Border.Opacity = 1
          $dashed.Opacity = 0
          $Window.height = $Screen.height
          $Window.background = "#64000000"
          $Window.Opacity = 1
          if ($(($border.BorderThickness.bottom + $border.BorderThickness.Top) - $Window.height) -ge 0) {
            $Border.BorderThickness = "0,0,0,0"
          }
          $global:state = 4 # Prompt to save
        }
      }
    }

    # Function saves the screenshot.
    function saveScreenshot {
      if ($screenshotcounter -gt 1) { $filename = "$Name" + "_" + $screenshotcounter + ".png" } else { $filename = "$Name.png" }
      if (([System.Management.Automation.PSTypeName]'Window').Type) {
        if ($OSBuild -ge 14392) { ([VirtualDesktop.Desktop]::FromWindow($ScriptHandle)).MakeVisible() } # Set Workspace to same as script
        [Window]::SetForegroundWindow($ScriptHandle) # Set Window as Active
      }
      start-sleep -Milliseconds 100
      [Window]::SetForegroundWindow($ScriptHandle)
      $oReturn = [System.Windows.Forms.MessageBox]::Show("Save: " + """$filename""`r`n@ ""$Folder\""?","Save",[System.Windows.Forms.MessageBoxButtons]::OkCancel,[System.Windows.Forms.MessageBoxIcon]::Question)
      switch ($oReturn) {
        "Ok" {
          $Border.Opacity = "0"
          $cropped.Opacity = "0"
          $cropped.Source = $Stream
          [gc]::Collect()
          [gc]::WaitForPendingFinalizers()
          if ($(Test-Path "$File.png")) {
            $global:screenshotcounter++
            $global:File = "$Folder\" + "$Name" + "_" + $screenshotcounter
            $oReturn = [System.Windows.Forms.MessageBox]::Show("Take another screenshot?","",[System.Windows.Forms.MessageBoxButtons]::YesNo,[System.Windows.Forms.MessageBoxIcon]::Question)
            switch ($oReturn) {
              "Yes" {
                $Border.BorderBrush = "#00000000"
                $Window.Cursor = "Cross"
                $global:state = 0 # Waiting
              }
              "No" {
                if ($runInSystray -eq "true" -or $runInSystray -eq "1") {
                  $Window.background = "#64000000"
                  $cropped.Source = $Stream
                  [gc]::Collect()
                  [gc]::WaitForPendingFinalizers()
                  $global:ResetFilename = $true
                  # Check that file exist
                  if (Test-Path "$Folder\$Name.png") {
                    if ($OpenImages -eq "true" -or $OpenImages -eq "1") { # Open in editor of choice
                      Get-Item "$Folder\$Name*.png" | Invoke-Item
                    }
                    if ($OpenFolder -eq "true" -or $OpenFolder -eq "1") { # Open folder
                      Invoke-Item "$Folder\"
                    }
                  }
                  monitorKey ($scanCode)
                  $global:state = 99
                } else {
                  $Window.background = "Black"
                  $Window.height = 0
                  $Window.close()
                }
              }
            }
          }
        }
        "Cancel" {
          if ($runInSystray -eq "true" -or $runInSystray -eq "1") {
            $global:ResetFilename = $true
          }
          $global:state = 1 # Reset
        }
      }
    }

    # Setup program vars
    $global:screenshotcounter = 1
    $File = "$Folder\" + "$Name"
    $global:state = 99 #Waiting
    $Screen = [System.Windows.Forms.SystemInformation]::VirtualScreen
    $ResetFilename = $false

    # Setup Menubar
    if ($runInSystray -eq "true" -or $runInSystray -eq "1") {
      $ResetFilename = $true
      function New-MenuItem {
        param(
          [string]
          $Text = "Placeholder Text",

          $MyScriptPath,

          $ScriptVariables,

          $function,

          [switch]
          $ExitOnly = $false
        )
        #Initialization
        $MenuItem = New-Object System.Windows.Forms.MenuItem
        #Apply desired text
        if ($Text) {
          $MenuItem.text = $Text
        }
        #Apply click event logic
        if ($MyScriptPath -and !$ExitOnly) {
          $MenuItem | Add-Member -Name MyScriptPath -Value $MyScriptPath -MemberType NoteProperty
          $MenuItem.Add_Click({
              try {
                $MyScriptPath = $This.MyScriptPath #Used to find proper path during click event

                if (Test-Path $MyScriptPath) {
                  Start-Process -FilePath "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" -ArgumentList "-NoProfile -NoLogo -ExecutionPolicy Bypass -File `"$MyScriptPath`" $ScriptVariables" -ErrorAction Stop
                } else {
                  throw "Could not find at path: $MyScriptPath"
                }
              } catch {
                $Text = $This.text
                [System.Windows.Forms.MessageBox]::Show("Failed to launch $Text`n`n$_") > $null
              }
            })
        }
        #Call Function on click event instead
        if ($function -and !$ExitOnly) {
          $MenuItem | Add-Member -Name function -Value $function -MemberType NoteProperty
          $MenuItem.Add_Click({
              try {
                $function = $This.function #Used to find proper path during click event
                & "$function"
              } catch {
                $Text = $This.text
                [System.Windows.Forms.MessageBox]::Show("Failed to call &$Text`n`n$_") > $null
              }
            })
        }
        #Provide a way to exit the launcher
        if ($ExitOnly -and !$MyScriptPath) {
          $MenuItem.Add_Click({
              $Form.close()
              $Window.close()
            })
        }
        #Return our new MenuItem
        $MenuItem
      }

      #Create Form to serve as a container for our components
      $Form = New-Object System.Windows.Forms.Form
      #Configure our form to be hidden
      $Form.BackColor = "Magenta" #Pick a color you won't use again and match it to the TransparencyKey property
      $Form.TransparencyKey = "Magenta"
      $Form.ShowInTaskbar = $false
      $Form.FormBorderStyle = "None"

      # base64 encoded icon
      $base64 = "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"

      # Create a streaming image by streaming the base64 string to a bitmap streamsource
      $bitmap = New-Object System.Windows.Media.Imaging.BitmapImage
      $bitmap.BeginInit()
      $bitmap.StreamSource = [System.IO.MemoryStream][System.Convert]::FromBase64String($base64)
      $bitmap.EndInit()
      $bitmap.Freeze()
      # Convert the bitmap into an icon
      $image = [System.Drawing.Bitmap][System.Drawing.Image]::FromStream($bitmap.StreamSource)
      $icon = [System.Drawing.Icon]::FromHandle($image.GetHicon())

      #Initialize/configure necessary components
      $SystrayLauncher = New-Object System.Windows.Forms.NotifyIcon
      $SystrayLauncher.Icon = $icon
      $SystrayLauncher.text = "Screenshot"
      $SystrayLauncher.Visible = $true

      $ContextMenu = New-Object System.Windows.Forms.ContextMenu

      $takeScreenshot = New-MenuItem -text "Take Screenshot" -Function "takescreenshot"
      $about = New-MenuItem -text "About" -Function "about"
      #$RestartRemoteComputer = New-MenuItem -Text "Restart Remote PC" -MyScriptPath "C:\scripts\restartpc.ps1"
      $ExitLauncher = New-MenuItem -text "Exit" -ExitOnly

      #Add menu items to context menu
      $ContextMenu.MenuItems.AddRange($takeScreenshot)
      $ContextMenu.MenuItems.AddRange($about)
      #$ContextMenu.MenuItems.AddRange($RestartRemoteComputer)
      $ContextMenu.MenuItems.AddRange($ExitLauncher)

      #Add components to our form
      $SystrayLauncher.ContextMenu = $ContextMenu

      $SystrayLauncher.add_MouseDown({
          if ($_.Button -eq [System.Windows.Forms.MouseButtons]::left) {
            takescreenshot
          } else {
            $SystrayLauncher.Show($SystrayLauncher.ContextMenu,0)
          }
        })
    }


    # Thanks, https://blogs.technet.microsoft.com/stephap/2012/04/23/building-forms-with-powershell-part-1-the-form/
    # Build the GUI for the screenshot screen
    [xml]$xaml = @"
    <Window
    xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
    xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
    x:Name="Window" WindowStartupLocation = "0" Title="Screenshot"
    Width = "0" Height = "0" ShowInTaskbar = "true" ResizeMode = "NoResize"
    Topmost = "True" WindowStyle = "0" AllowsTransparency="True" Background="#64000000" >
        <Border BorderBrush="#00000000" BorderThickness="1" HorizontalAlignment="Stretch" VerticalAlignment="Stretch" Name="Border" Width = "80" Height = "200" Margin="0" Opacity="0" >
            <Grid ShowGridLines='False'>
                <Grid.ColumnDefinitions>
                    <ColumnDefinition Width="*"/>
                </Grid.ColumnDefinitions>
                <Grid.RowDefinitions>
                    <RowDefinition Height = '*'/>
                </Grid.RowDefinitions>
                <Rectangle x:Name='outline' Stroke="White" StrokeThickness="1"/>
                <Rectangle x:Name='dashed' Stroke="#CB000000" StrokeDashArray="4,3" StrokeThickness="3"/>
                <Image x:Name='cropped' Stretch="None"></Image>
            </Grid>
        </Border>
    </Window>
"@
    $reader = (New-Object System.Xml.XmlNodeReader $xaml)
    $Window = [Windows.Markup.XamlReader]::Load($reader)

    # region Connect to Controls
    $xaml.SelectNodes("//*[@*[contains(translate(name(.),'n','N'),'Name')]]") | ForEach-Object {
      New-Variable -Name $_.Name -Value $Window.FindName($_.Name) -Force -ErrorAction SilentlyContinue -Scope Global
    }

    # init Cursor location
    $global:downx = 0
    $global:downy = 0

    $global:firstrun = $true
    $global:counter = 10000
    $Window.Add_SourceInitialized({
        # init Window
        if ($runInSystray -eq "true" -or $runInSystray -eq "1") {
          $Window.width = 0
          $Border.width = 0
          $Window.height = 0
          $Border.height = 0
        } else {
          $Window.width = $Screen.width
          $Border.width = $Screen.width
          $Window.height = $Screen.width
          $Border.height = $Screen.width
        }

        $Window.left = $Screen.Left
        $Window.Top = $Screen.Top
        $outline.Stroke = $BorderColor
        $Color = [System.Drawing.Color]::FromName($BorderColor)
        $Border.background = "" + $("#" + "64" + [Convert]::ToString($Color.R,16).ToUpper().PadLeft(2,'0') + [Convert]::ToString($Color.G,16).ToUpper().PadLeft(2,'0') + [Convert]::ToString($Color.B,16).ToUpper().PadLeft(2,'0'))

        # Setup Timer, this loops and checks the current application state taking the correct action.
        $Script:timer = New-Object System.Windows.Threading.DispatcherTimer
        $timer.Interval = [timespan]"0:0:0.001"
        $timer.Add_Tick({
            if ($firstrun -eq $true) {
                $global:scripthandle = $((Get-Process -id $PID).MainWindowHandle)
                $Window.ShowInTaskbar = $false
                $global:firstrun = $false
            }

            if ($global:state -eq 2) { # Init Draw Boundry
              if (-not $(Test-Path "$File.png")) {
                $Window.background = "#01000000"
                $Border.BorderBrush = "#64000000"
                $Border.Opacity = "1"
                $dashed.Opacity = 1
                $Mouse = [System.Windows.Forms.Cursor]::Position
                $global:downx = $Mouse.x - $Screen.Left
                $global:downy = $Mouse.y - $Screen.Top
                $newright = $Screen.width - $downx
                $newbottom = $Screen.height - $downy
                $Border.BorderThickness = "$downx,$downy,$newright,$newbottom"
                $global:state = 0
              }
              else {
                while (Test-Path "$File.png") {
                  $global:screenshotcounter++
                  $global:File = "$Folder\" + "$Name" + "_" + $screenshotcounter
                }
                $oReturn = [System.Windows.Forms.MessageBox]::Show($("Specified Filename already exists, saving as `r`n" + $File + ".png"),"",[System.Windows.Forms.MessageBoxButtons]::Ok)

                $Border.BorderBrush = "#00000000"
                $Window.Cursor = "Cross"
                $global:state = 0 # Waiting
              }
            }


            if ($global:state -eq 3) { # Crop Image and Display
              cropImage
            }

            if ($global:state -eq 4) { # Prompt to Save Screenshots
              saveScreenshot
            }

            if ($global:state -eq 5) { # Exit
              $oReturn = [System.Windows.Forms.MessageBox]::Show("Exit without saving?","Exit",[System.Windows.Forms.MessageBoxButtons]::OkCancel,[System.Windows.Forms.MessageBoxIcon]::Warning)
              switch ($oReturn) {
                "OK" {
                  if ($runInSystray -eq "true" -or $runInSystray -eq "1") {
                    # Check that file exist
                    if (Test-Path "$Folder\$Name.png") {
                      if ($OpenImages -eq "true" -or $OpenImages -eq "1") { # Open in editor of choice
                        Get-Item "$Folder\$Name*.png" | Invoke-Item
                      }
                      if ($OpenFolder -eq "true" -or $OpenFolder -eq "1") { # Open folder
                        Invoke-Item "$Folder\"
                      }
                    }
                    monitorKey ($scanCode)
                    $monitorKeyPID = Receive-Job -Name "checkforkey"
                    $Window.background = "#64000000"
                    $global:state = 99
                  } else {
                    $Window.background = "Black"
                    $Window.height = 0
                    $Window.close()
                  }
                }
                "Cancel" {
                  $global:state = $returnState
                }
              }
            }

            if ($global:state -eq 6) { # Get Window
              getWindow
            }

            if ($global:state -eq 1) { # Reset
              $Border.Opacity = "0"
              $cropped.Opacity = "0"
              $cropped.Source = $Stream
              [gc]::Collect()
              [gc]::WaitForPendingFinalizers()
              Remove-Item "$File.png" -Force
              if (-not $(Test-Path "$File.png")) {
                $Window.background = "#64000000"
                $Window.Cursor = "Cross"
                $global:state = 0
              }
            }

            if ($global:state -eq 99) { # Waiting
              #GC
              if ($global:counter -ge 5000) {
                  [gc]::Collect()
                  [gc]::WaitForPendingFinalizers()
                  $global:counter = 0
              } else {
                  $global:counter = $global:counter + 1
              }
              if ($runInSystray -eq "true" -or $runInSystray -eq "1") {
                $Window.width = 0
                $Border.width = 0
                $Window.height = 0
                $Border.height = 0
                $keypressed = (Receive-Job -Name "checkforkey")
                if ($keypressed -eq $true) {
                  takescreenshot
                }
                $queued = Resolve-Path $([System.IO.Path]::GetTempPath() + "screenshot.queue")  2> $null
                if ($queued) {
                  Remove-Item $([System.IO.Path]::GetTempPath() + "screenshot.queue")
                  takescreenshot
                }
                $quitnow = Resolve-Path $([System.IO.Path]::GetTempPath() + "screenshot.quit")  2> $null
                if ($quitnow) {
                  Remove-Item -Force $([System.IO.Path]::GetTempPath() + "screenshot.quit")
                  start-sleep -Milliseconds 100
                  $Form.close()
                  $Window.close()
                }
              } else {
                takescreenshot
              }
            }

            if ($global:state -eq 0) { # Currently Drawing Border
              $Mouse = [System.Windows.Forms.Cursor]::Position
              #Old Code
              #$x = $Mouse.x
              #$y = $Mouse.y
              #New Multimonitor code
              $x = $Mouse.x - $Screen.Left
              $y = $Mouse.y - $Screen.Top
              $bottom = $border.BorderThickness.bottom

              # Get the Active Windows List
              if (($recentlist)[-1] -ne "end") {
                $global:recentlist = $global:recentlist + (receive-job -Name "activewindows")
              }

              # Top Left
              if (($x -lt $downx) -and ($y -lt $downy)) {
                $newright = $Window.width - $downx
                $newbottom = $Window.height - $downy
                $Border.BorderThickness = "$x,$y,$newright,$newbottom"
              }
              # Top Right
              if (($x -lt $downx) -and ($y -ge $downy)) {
                $newright = $Window.width - $downx
                $newbottom = $Window.height - $y
                $Border.BorderThickness = "$x,$downy,$newright,$newbottom"
              }
              # Bottom Left
              if (($x -ge $downx) -and ($y -lt $downy)) {
                $newright = $Window.width - $x
                $newbottom = $Window.height - $downy
                $Border.BorderThickness = "$downX,$y,$newright,$newbottom"
              }
              # Bottom Right
              if (($x -ge $downx) -and ($y -ge $downy)) {
                $newright = $Window.width - $x
                $newbottom = $Window.height - $y
                $Border.BorderThickness = "$downx,$downy,$newright,$newbottom"
              }
            }
          })
        # Start Monitoring for Key
        if ($runInSystray -eq "true" -or $runInSystray -eq "1") {
          monitorKey ($scanCode)
          $monitorKeyPID = Receive-Job -Name "checkforkey"
        }
        # Start timer
        $timer.Start()
        if (-not $timer.IsEnabled) {
          $Window.close()
        }
      })
    $Window.Add_Closed({
        # Cleanup
        sendKey ($scanCode) # Ends the keyboard monitor process by pressing the key
        Remove-Job -Name "checkforkey"
        $Script:Timer.Stop()
        $Stream.close()
        [gc]::Collect()
        [gc]::WaitForPendingFinalizers()
      })
    $Window.Add_MouseRightButtonUp({
        if ($global:state -ne 99) {
          $returnState = $global:state
          $global:state = 5 # Exit
        }
      })
    $Window.Add_MouseLeftButtonDown({
        if ($global:state -ne 99) {
          $global:state = 2 # Drawing Boundry
        }
      })
    $Window.Add_MouseLeftButtonUp({
        if ($global:state -ne 99) {
          $global:state = 3 # Crop Image and Display
        }
      })
    $Window.Add_KeyDown({
        if ($global:state -ne 99) {
          if (($_.Key -eq "Escape") -or ($_.Key -eq "Enter")) {
            $returnState = $global:state
            $global:state = 5 # Exit
          }
          elseif ($_.Key -eq "Space") {
            [System.Windows.Forms.Messagebox]::Show($("Filename: $File.png"),"",[System.Windows.Forms.MessageBoxButtons]::Ok,[System.Windows.Forms.MessageBoxIcon]::Information) # Filename
          }
          elseif ($_.Key -eq "Tab" -or $_.Key -eq "Shift" -or $_.Key -eq "Rightshift") {
            # Check if the recent list has been returned, if not try and loop to get it. 
            if (($recentlist)[-1] -eq "end") {
              $global:state = 6 # Get Window size and crop
            } else {
              if ($c -ge 40) {$c = 30} else {$c = 0}
              while ($c -le 40) {
                start-sleep -Milliseconds 50
                $global:recentlist = $global:recentlist + (receive-job -Name "activewindows")
                if (($recentlist)[-1] -eq "end") {$c = 40}
                $c++
              }
              if (($recentlist)[-1] -eq "end") {
                $global:state = 6 # Get Window size and crop
              } else { [System.Windows.Forms.Messagebox]::Show(("The Active Windows list is still loading or there was an error in getting the list. Please try again in a moment."),"",[System.Windows.Forms.MessageBoxButtons]::Ok,[System.Windows.Forms.MessageBoxIcon]::Error) }
            }
          }
          elseif ([string]$_.Key -match '^(D|NumPad)[0-9]+$') {
            $monitorCount = ([System.Windows.Forms.SystemInformation]::MonitorCount)
            # If 0 take screenshot of entire desktop
            if (($_.Key -replace '\D+([0-9]+)','$1') -eq 0) {
              $global:state = 99 # Do nothing for a second.
              $Border.BorderThickness = "0,0,0,0"
              $global:state = 3 # Crop Image and Display
            }
            # If larger than the number of monitors then generate error.
            elseif (($_.Key -replace '\D+([0-9]+)','$1') -gt $monitorCount) {
              [System.Windows.Forms.Messagebox]::Show($("Monitor " + [string]($_.Key -replace '\D+([0-9]+)','$1') + " does not exist."),"",[System.Windows.Forms.MessageBoxButtons]::Ok,[System.Windows.Forms.MessageBoxIcon]::Information)
            }
            # Take screenshot of monitor.
            # Rewrote in version 5 for multimonitor support. 
            elseif (($_.Key -replace '\D+([0-9]+)','$1') -le $monitorCount) {
              $global:state = 99 # Do nothing for a second.
              # This gets the bounds of the monitor # of the key you pressed.
              if (([System.Windows.Forms.Screen]::AllScreens -match ("display")).bounds.Y -lt 0) {
                if (([System.Windows.Forms.Screen]::AllScreens -match ("display" + ($_.Key -replace '\D+([0-9]+)','$1'))).bounds.Y -lt 0) {
                  [int]$monitorTop = "0"
                } else {
                  [int]$monitorTop = $Screen.Height - ([System.Windows.Forms.Screen]::AllScreens -match ("display" + ($_.Key -replace '\D+([0-9]+)','$1'))).bounds.Height
                }
                [int]$monitorBottom = "0"
              } else {
                [int]$monitorTop = ([System.Windows.Forms.Screen]::AllScreens -match ("display" + ($_.Key -replace '\D+([0-9]+)','$1'))).bounds.Top
                [int]$monitorBottom = ($Screen.height - ([System.Windows.Forms.Screen]::AllScreens -match ("display" + ($_.Key -replace '\D+([0-9]+)','$1'))).bounds.bottom)
              }
              if (([System.Windows.Forms.Screen]::AllScreens -match ("display")).bounds.X -lt 0) {
                [int]$monitorLeft = ([System.Windows.Forms.Screen]::AllScreens -match ("display" + ($_.Key -replace '\D+([0-9]+)','$1'))).bounds.Width - [Math]::abs(([System.Windows.Forms.Screen]::AllScreens -match ("display" + ($_.Key -replace '\D+([0-9]+)','$1'))).bounds.X)
                [int]$monitorRight = ($Screen.width -  ([System.Windows.Forms.Screen]::AllScreens -match ("display" + ($_.Key -replace '\D+([0-9]+)','$1'))).bounds.width - ([System.Windows.Forms.Screen]::AllScreens -match ("display" + ($_.Key -replace '\D+([0-9]+)','$1'))).bounds.Right)
              } else {
                [int]$monitorLeft = ([System.Windows.Forms.Screen]::AllScreens -match ("display" + ($_.Key -replace '\D+([0-9]+)','$1'))).bounds.left
                [int]$monitorRight = ($Screen.width - ([System.Windows.Forms.Screen]::AllScreens -match ("display" + ($_.Key -replace '\D+([0-9]+)','$1'))).bounds.right)
              }
              $Border.BorderThickness = "$monitorLeft, $monitorTop, $monitorRight, $monitorBottom" # Set Border
              $global:state = 3 # Crop Image and Display
            }
          }
          # Konami Code easter egg :P
          elseif ([string]$_.Key -match '^(Up|Down|Left|Right)$') {
            $global:konami = @($global:konami + @([string]$_.Key))
            if ($konami.length -ge 8) {
              [array]::Reverse($konami)
              if ($konami[0] -eq "Right" -and $konami[1] -eq "Left" -and $konami[2] -eq "Right" -and $konami[3] -eq "Left" -and $konami[4] -eq "Down" -and $konami[5] -eq "Down" -and $konami[6] -eq "Up" -and $konami[7] -eq "Up") {
                $base64 = "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"
                $bitmap = New-Object System.Windows.Media.Imaging.BitmapImage
                $bitmap.BeginInit()
                $bitmap.StreamSource = [System.IO.MemoryStream][System.Convert]::FromBase64String($base64)
                $bitmap.EndInit()
                $bitmap.Freeze()
                $img = [System.Drawing.Image]::FromStream($bitmap.StreamSource)
                $form = new-object Windows.Forms.Form
                $form.Width = $img.Size.Width;
                $form.Height =  $img.Size.Height;
                $form.FormBorderStyle = "none"
                $form.MaximizeBox = $false
                $form.MinimizeBox = $false
                $form.BackColor = "Gray"
                $form.TransparencyKey = "Gray"
                $form.startposition = "centerscreen"
                $form.ShowInTaskbar = $false
                $pictureBox = new-object Windows.Forms.PictureBox
                $pictureBox.Width =  $img.Size.Width;
                $pictureBox.Height =  $img.Size.Height;
                $pictureBox.Image = $img;
                $pictureBox.Add_Click({$form.close()})
                $form.controls.add($pictureBox)
                $form.TopMost = $true;
                $Wi.ShowInTaskbar
                $form.ShowDialog()
                $global:konami = @()
              }
              [array]::Reverse($konami)
            }
          }
          else {
            # Controls
            [System.Windows.Forms.Messagebox]::Show($("Script Controls`r`n————————————————————————————`r`n`r`nLeft Mouse`t—`tDraw Boundry`r`n`r`nTab/Shift`t`t—`tCapture window`r`n`r`n`t`t`t0 captures the entire desktop, `r`nNumber Keys`t—`t1 for the first monitor,`r`n`t`t`t2 for the second, etc...`r`n`r`nEnter/`r`nEscape/`t`t—`tExit`r`nRight Mouse`r`n`r`nSpace`t`t—`tGet current filename"),"Controls",[System.Windows.Forms.MessageBoxButtons]::Ok)
          }
        }
      })
    [void]$Window.ShowDialog()
  }).AddParameters($ParamList)
$Runspacehash.psCmd.Invoke()
$Runspacehash.psCmd.Dispose()

# Check that file exist
if ($runInSystray -eq "false" -or $runInSystray -eq "0") {
  if (Test-Path "$Directory\$FileName.png") {
    if ($OpenImages -eq "true" -or $OpenImages -eq "1") { # Open in editor of choice
      Get-Item "$Directory\$FileName*.png" | Invoke-Item
    }
    if ($OpenFolder -eq "true" -or $OpenFolder -eq "1") { # Open folder
      Invoke-Item "$Directory\"
    }
  }
}

#Show Powershell window again
if ($HidePowershell -eq "true" -or $HidePowershell -eq "1") {
  if ($null -eq $(Get-CimInstance win32_process | Where-Object { $_.processname -eq 'powershell.exe' -and $_.ProcessId -eq $pid -and $_.commandline -match $("-WindowStyle Hidden") })) {
    [Console.Window]::ShowWindow($consolePtr,4) | Out-Null
  }
}
