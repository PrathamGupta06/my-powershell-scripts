Function Save-Office-Tool {
    Param ()
    $releases_url = 'https://api.github.com/repos/YerongAI/Office-Tool/releases/latest'
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $releases = Invoke-RestMethod -uri $releases_url
    $latestRelease = $releases.assets | Where-Object { $_.browser_download_url.EndsWith('exe') } | Select-Object -First 1
    Invoke-WebRequest -Uri $latestRelease.browser_download_url -OutFile ("ignore\Office_Tool.exe")
}


Save-Office-Tool