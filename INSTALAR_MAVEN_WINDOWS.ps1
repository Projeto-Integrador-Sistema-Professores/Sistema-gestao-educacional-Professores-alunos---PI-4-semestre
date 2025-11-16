# Script de Instalação do Maven no Windows
# Execute como Administrador

Write-Host "=== Instalador de Maven para Windows ===" -ForegroundColor Green
Write-Host ""

# Verificar se já está instalado
$mavenInstalled = Get-Command mvn -ErrorAction SilentlyContinue
if ($mavenInstalled) {
    Write-Host "Maven já está instalado!" -ForegroundColor Yellow
    mvn -version
    exit
}

Write-Host "Maven não encontrado. Iniciando instalação..." -ForegroundColor Yellow
Write-Host ""

# Verificar se Chocolatey está instalado
$chocoInstalled = Get-Command choco -ErrorAction SilentlyContinue

if (-not $chocoInstalled) {
    Write-Host "Chocolatey não encontrado. Instalando Chocolatey..." -ForegroundColor Yellow
    Set-ExecutionPolicy Bypass -Scope Process -Force
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
    iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
    Write-Host "Chocolatey instalado!" -ForegroundColor Green
    Write-Host ""
}

Write-Host "Instalando Maven via Chocolatey..." -ForegroundColor Yellow
choco install maven -y

Write-Host ""
Write-Host "=== Instalação Concluída! ===" -ForegroundColor Green
Write-Host ""
Write-Host "IMPORTANTE: Feche e reabra o terminal para usar o Maven." -ForegroundColor Yellow
Write-Host ""
Write-Host "Para verificar, execute: mvn -version" -ForegroundColor Cyan

