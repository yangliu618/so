#!/usr/bin/env pwsh

# 设置PowerShell使用UTF-8编码
$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::InputEncoding = [System.Text.Encoding]::UTF8

$direc = Split-Path -Parent $MyInvocation.MyCommand.Path

function Write-Color {
    param(
        [string]$Text,
        [string]$Color
    )
    switch ($Color) {
        "blue" {
            Write-Host $Text -ForegroundColor Cyan
        }
        "red" {
            Write-Host $Text -ForegroundColor Red
        }
        "green" {
            Write-Host $Text -ForegroundColor Green
        }
        default {
            Write-Host $Text
        }
    }
}

function Write-Copyright {
    Write-Host "#####################"
    Write-Color "   SSH Login Platform   " -Color blue
    Write-Host "#####################"
    Write-Host
}

function Write-Underline {
    Write-Host "-----------------------------------------"
}

function Get-HostList {
    $pwFile = Join-Path $direc "password.lst"
    if (-not (Test-Path $pwFile)) {
        Write-Color "Error: password.lst file not found!" -Color red
        Write-Color "Please copy password.lst.simple to password.lst and modify it." -Color red
        return @()
    }
    
    $hosts = @()
    # 使用UTF-8编码读取文件
    $lines = Get-Content -Path $pwFile -Encoding UTF8
    foreach ($line in $lines) {
        if ($line -match '^[^#]') {
            $parts = $line -split ':'
            if ($parts.Length -ge 6) {
                $hosts += @{
                    Number = $parts[0]
                    IP = $parts[1]
                    Port = $parts[2]
                    User = $parts[3]
                    Password = $parts[4]
                    Description = $parts[5]
                }
            }
        }
    }
    return $hosts
}

function Connect-SSH {
    param(
        [string]$IP,
        [string]$Port,
        [string]$User,
        [string]$Password,
        [string]$Description
    )
    
    if ($Password -match '\.pem$') {
        $keyPath = Join-Path $direc "keys\$Password"
        if (Test-Path $keyPath) {
            Write-Color "Connecting to ${IP}:${Port} as ${User} (Key: ${Password})..." -Color green
            ssh -i "$keyPath" "${User}@${IP}" -p $Port
        } else {
            Write-Color "Error: Key file $keyPath not found!" -Color red
        }
    } else {
        Write-Color "Connecting to ${IP}:${Port} as ${User}..." -Color green
        # 使用plink.exe（PuTTY的命令行工具）实现自动输入密码
        # 检查plink.exe是否存在
        $plinkPath = "plink.exe"
        if (Get-Command $plinkPath -ErrorAction SilentlyContinue) {
            try {
                # 使用plink.exe进行连接，自动输入密码
                $command = "$plinkPath -ssh -P $Port -pw $Password ${User}@${IP}"
                Invoke-Expression $command
            } catch {
                Write-Color "Connection error: $($_.Exception.Message)" -Color red
            }
        } else {
            # 如果plink.exe不存在，使用ssh命令并提示用户输入密码
            Write-Host "plink.exe not found. Please enter password manually."
            Write-Host "Command: ssh ${User}@${IP} -p $Port"
            ssh "${User}@${IP}" -p $Port
        }
    }
}

function Main {
    Write-Copyright
    
    while ($true) {
        $hosts = Get-HostList
        if ($hosts.Count -eq 0) {
            break
        }
        
        Write-Host "ID |        Host        | Description"
        Write-Underline
        foreach ($item in $hosts) {
            $number = $item.Number.PadLeft(3)
            $ip = $item.IP.PadRight(18)
            $desc = $item.Description
            Write-Host "$number | $ip | $desc"
        }
        Write-Underline
        
        $number = Read-Host '[*] Select host (enter q to exit)'
        if ($number -eq 'q' -or $number -eq 'quit') {
            break
        }
        
        if ($number -match '^\d+$') {
            $selectedHost = $hosts | Where-Object { $_.Number -eq $number }
            if ($selectedHost) {
                Connect-SSH -IP $selectedHost.IP -Port $selectedHost.Port -User $selectedHost.User -Password $selectedHost.Password -Description $selectedHost.Description
            } else {
                Write-Color "Error: Host number $number not found!" -Color red
            }
        } else {
            Write-Color "Input error!!" -Color red
        }
        
        Write-Host
    }
}

Main
