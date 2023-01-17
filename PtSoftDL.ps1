# 從網頁下載
function WebDL {
    param (
        [Parameter(Position = 0, ParameterSetName = "", Mandatory)]
        [string] $Url,
        [Parameter(ParameterSetName = "")]
        [string] $Path,
        [switch] $TempPath,
        [Parameter(ParameterSetName = "")]
        [string] $Name,
        [switch] $OpenDir
    )
    # 參數設定
    $Dsk = $([Environment]::GetFolderPath('Desktop'))
    $Url -match "[^/]+(?!.*/)" |Out-Null # 獲取連結中的檔名
    $UrlFileName = $Matches[0]
    # 沒有檔名使用自動檔名
    if (!$Name) { $Name = $UrlFileName }
    # 沒有路徑預設存到桌面
    if (!$Path) {
        if ($TempPath) {
            $Path = $env:TEMP+"\WebDL"
        } else { $Path = $Dsk }
    }
    if (!(Test-Path $Path)) {
        New-Item $Path -ItemType:Directory -Force |Out-Null
    }
    # 目標檔案完整路徑
    $DstPath  = "$Path\$Name"
    # 下載
    Start-BitsTransfer $Url $Path
    # 打開資料夾
    if ($OpenDir) { explorer.exe $DstPath }
    return $DstPath
} # WebDL "https://github.com/hunandy14/PtSoftDL/raw/master/soft/DG5461441_x64.zip"



# 下載攜帶版軟體
function PtSoftDL {
    param (
        [Parameter(Position = 0, ParameterSetName = "Down", Mandatory)]
        [array] $Name,
        [Parameter(ParameterSetName = "")]
        [string] $Path,
        [switch] $TempPath,
        [Parameter(ParameterSetName = "")]
        [string] $ListPath,
        [Parameter(ParameterSetName = "Info")]
        [switch] $Info
    )
    # 獲取清單
    if (!$Path) { $Path = $([Environment]::GetFolderPath('Desktop')) }
    if ($TempPath) {
        $Path = $env:TEMP+"\PtSoftDL"
        if (!(Test-Path $Path -PathType:Container)) { New-Item $Path -ItemType:Directory -Force |Out-Null }
    }
    $Json = Invoke-RestMethod "raw.githubusercontent.com/hunandy14/PtSoftDL/master/SoftList.json"
    # 下載
    if ($Name) {
        if ($Name -isnot [array]) { $Name = @($Name) }
        $Name|ForEach-Object{
            $Node = $Json.Default.$_
            $Url = $Node.Url 
            $SoftPath = WebDL $Url -TempPath
            # 解壓縮到桌面
            $ExpandDir = $Node.ExpandDir
            if ($ExpandDir) {
                $ExpandDir = "$Path\$ExpandDir"
            } else { $ExpandDir = $Path }
            Expand-Archive $SoftPath $ExpandDir -Force
            # 儲存到暫存時自動打開資料夾
            if ($TempPath) { explorer.exe $Path }
        }
    } elseif ($Info) {
        return $Json.Default.PSObject.Properties.Value
    }
}
# PtSoftDL DiskGenius
# PtSoftDL Snipaste
# PtSoftDL Dism++
# PtSoftDL CrystalDiskInfo,CrystalDiskMark -Path Z:\Work
# PtSoftDL Snipaste -TempPath
# PtSoftDL -Info
