# 從網頁下載
function WebDL {
    param (
        [Parameter(Position = 0, ParameterSetName = "", Mandatory)]
        [String] $Url,
        [Parameter(ParameterSetName = "")]
        [String] $Path,
        [Switch] $TempPath,
        [Parameter(ParameterSetName = "")]
        [String] $Name,
        [Switch] $OpenDir
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
        [string] $Name,
        [Parameter(ParameterSetName = "")]
        [String] $Path,
        [Switch] $TempPath,
        [Parameter(ParameterSetName = "")]
        [string] $ListPath,
        [switch] $OpenDir,
        [Parameter(ParameterSetName = "Info")]
        [switch] $Info
    )
    # 獲取清單
    $ListPath = "raw.githubusercontent.com/hunandy14/PtSoftDL/master/SoftList.json"
    $Json = Invoke-RestMethod $ListPath
    # 下載
    if ($Name) {
        $Node = $Json.Default.$Name
        $Url = $Node.Url 
        WebDL $Url -Path:$Path -TempPath:$TempPath -OpenDir:$OpenDir
    } elseif ($Info) {
        $Json.Default.PSObject.Properties.Value
    }
}
# PtSoftDL 'DiskGenius'
# PtSoftDL -Info
