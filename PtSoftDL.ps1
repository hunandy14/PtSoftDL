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
        [switch] $OpenDir,
        [switch] $OpenFile,
        [switch] $PassThru
    )
    # 參數設定
    $UrlFileName = ($Url -split "/")[-1]
    # 沒有檔名使用自動檔名
    if (!$Name) { $Name = $UrlFileName }
    # 沒有路徑預設存到桌面
    if (!$Path) {
        if ($TempPath) {
            $Path = $env:TEMP+"\WebDL"
        } else {
            $Dsk = [Environment]::GetFolderPath('Desktop')
            $Path = $Dsk
        }
    }
    if (!(Test-Path $Path)) {
        New-Item $Path -ItemType:Directory -Force |Out-Null
    }
    # 目標檔案完整路徑
    $FilePath = Join-Path $Path $Name
    # 下載
    (New-Object Net.WebClient).DownloadFile($Url, $FilePath)
    # 打開資料夾
    if ($OpenDir)  { explorer.exe $Path }
    if ($OpenFile) { explorer.exe $FilePath }
    # 返回下載後的完整路徑
    if ($PassThru) { return $FilePath }
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
        Write-Host "即將開始下載: "
        $Name|ForEach-Object{
            # 獲取下載路徑
            $Node = $Json.Default.$_
            $Url = $Node.Url 
            # 處理解壓路徑
            $ExpandDir = $Node.ExpandDir
            if ($ExpandDir) {
                $ExpandDir = "$Path\$ExpandDir"
            } else { $ExpandDir = $Path }
            
            # 下載
            $SoftPath = WebDL $Url -TempPath -PassThru -EA Stop
            # 解壓
            Expand-Archive $SoftPath $ExpandDir -Force -EA Stop
            
            # 顯示信息
            Write-Host "  [OK]:: $ExpandDir"
            
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
