##[Ps1 To Exe]
##
##Kd3HDZOFADWE8uO1
##Nc3NCtDXTlaDjofG5iZk2VzvRWYufIudvKSpxY+4+vnQnyrOR5YbSFBkqirzCVuoTfMWWudbvdIeNQ==
##Kd3HFJGZHWLWoLaVvnQmhQ==
##LM/RF4eFHHGZ7/LW5jpj8Fn3Ig==
##K8rLFtDXTiW5
##OsHQCZGeTiiZ4tI=
##OcrLFtDXTiW5
##LM/BD5WYTiiZ4tI=
##McvWDJ+OTiiZ4tI=
##OMvOC56PFnzN8u+Vs1Q=
##M9jHFoeYB2Hc8u+Vs1Q=
##PdrWFpmIG2HcofKIo2QX
##OMfRFJyLFzWE8uK1
##KsfMAp/KUzWI0g==
##OsfOAYaPHGbQvbyVvnQltRi7Ig==
##LNzNAIWJGmPcoKHc7Do3uAu/DDhlPovK2Q==
##LNzNAIWJGnvYv7eVvnRU907vVm0vLseC+aGmw4+57enq2w==
##M9zLA5mED3nfu77Q7TV64AuzAks5a8SPvLLnxpj86OvrtSDLSpx0
##NcDWAYKED3nfu77Q7TV64AuzAks5a8SPvLLnxpj86OvrtSDLSpx0
##OMvRB4KDHmHQvbyVvnRg5EzgR3ooaKU=
##P8HPFJGEFzWE8pHQ7SBi91KO
##KNzDAJWHD2fS8u+Vgw==
##P8HSHYKDCX3N8u+Vgw==
##LNzLEpGeC3fMu77Ro2k3hQ==
##L97HB5mLAnfMu77Ro2k3hQ==
##P8HPCZWEGmaZ7/K1
##L8/UAdDXTlaDjofG5iZk2VzvRWYufIudvKSpxY+4+vnQlCvcbYgdX1E322n/AUWpTOALUOYBu9cQURI5YfEE7/zSCdsKpLAPk6N7bqW6tLMrFFbQ7K/E4Ta46qnvIi1mZUXxb+9+AD/UimTFTg0=
##Kc/BRM3KXhU=
##
##
##fd6a9f26a06ea3bc99616d4851b372ba
##🧑‍💻 Autor
##Wagner Fernandes
##📧 [wagnerviniciusoficial@gmail.com]
##🔗 github.com/wagnercf##

# Definir codificação UTF-8 para entrada e saída
[Console]::InputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# --- BLOCO DE AUTO-ELEVAÇÃO VIA UAC ---
# Verifica se o script JÁ ESTÁ rodando com privilégios de administrador.
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "Este script requer privilegios de administrador. Solicitando elevacao..." -ForegroundColor Yellow

    try {
        $arguments = "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`" -WindowStyle Minimized"
        Start-Process -FilePath "powershell.exe" `
                      -ArgumentList $arguments `
                      -Verb RunAs `
                      -Wait `
                      -ErrorAction SilentlyContinue
    } catch {
        Write-Host "ERRO: Falha ao tentar elevar privilegios. Certifique-se de ter permissoes de administrador e que o UAC esta configurado." -ForegroundColor Red
        Write-Host "Mensagem de erro: $_" -ForegroundColor Red
        Read-Host "Pressione Enter para fechar..."
    }
    Exit
}
# --- FIM DO BLOCO DE AUTO-ELEVAÇÃO ---

# --- CARREGAMENTO DO MÓDULO E VARIÁVEIS GLOBAIS ---
Import-Module ActiveDirectory

$domain = "INICIOBANCO.FINALBANCO" # Dominio do local
$baseDN = "OU=INICIOBANCO,DC=MEIOBANCO,DC=FINALBANCO" # Domínio base para construção dos caminhos
$data = (Get-Date).ToString("dd/MM/yyyy HH:mm:ss") # Data atual

# --- FUNÇÕES GERAIS ---

function Set-ConsoleCustomization {
    $Host.UI.RawUI.ForegroundColor = "White"
    $Host.UI.RawUI.BackgroundColor = "Black"

    $RawUI = $Host.UI.RawUI
    $NewSize = $RawUI.WindowSize
    $NewSize.Width = 90
    $NewSize.Height = 40
    $RawUI.WindowSize = $NewSize
    $RawUI.BufferSize = $NewSize

    Clear-Host
}

function Show-UserInfo {
    $user = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
    Write-Host "Usuario: $user" -ForegroundColor White
}

function Disable-User {
    $username = Read-Host "Digite o nome do usuario para inativar"

    if ([string]::IsNullOrWhiteSpace($username)) {
        Write-Host "Nenhum nome de usuario foi fornecido." -ForegroundColor Yellow
        return
    }

    try {
        Disable-ADAccount -Identity $username -ErrorAction Stop
        Write-Host "Usuario '$username' inativado com sucesso." -ForegroundColor Green
    } catch {
        Write-Host "Erro: Usuario '$username' nao encontrado ou nao foi possível inativar." -ForegroundColor Red
    }
}

function Enable-User {
    $username = Read-Host "Digite o nome do usuario para reativar"

    if ([string]::IsNullOrWhiteSpace($username)) {
        Write-Host "Nenhum nome de usuario foi fornecido." -ForegroundColor Yellow
        return
    }

    try {
        Enable-ADAccount -Identity $username -ErrorAction Stop
        Write-Host "Usuario '$username' reativado com sucesso." -ForegroundColor Green
    } catch {
        Write-Host "Erro: Usuario '$username' nao encontrado ou nao foi possivel reativar." -ForegroundColor Red
    }
}

function Remove-User {
    $username = Read-Host "Digite o nome do usuario para deletar"

    if ([string]::IsNullOrWhiteSpace($username)) {
        Write-Host "Nenhum nome de usuario foi fornecido." -ForegroundColor Yellow
        return
    }

    try {
        Remove-ADUser -Identity $username -Confirm:$false -ErrorAction Stop
        Write-Host "Usuario '$username' deletado com sucesso." -ForegroundColor Green
    } catch {
        Write-Host "Erro: Usuario '$username' nao encontrado ou nao foi possível deletar." -ForegroundColor Red
    }
}

function Reset-Password {
    $username = Read-Host "Digite o nome do usuario para resetar a senha"

    if ([string]::IsNullOrWhiteSpace($username)) {
        Write-Host "Nenhum nome de usuario foi fornecido." -ForegroundColor Yellow
        return
    }

    $newPassword = Read-Host "Digite a nova senha" -AsSecureString

    try {
        Set-ADAccountPassword -Identity $username -NewPassword $newPassword -Reset -ErrorAction Stop
        Write-Host "Senha do usuario '$username' resetada com sucesso." -ForegroundColor Green
    } catch {
        Write-Host "Erro: Nao foi possível resetar a senha para '$username'. Verifique se o usuario existe e se voce tem permissao." -ForegroundColor Red
    }
}


function Show-Menu {
    Clear-Host
    Write-Host "==============================================" -ForegroundColor Yellow
    Write-Host "|          MENU DE GERENCIAMENTO AD          |" -ForegroundColor Yellow
    Write-Host "==============================================" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "==============================================" -ForegroundColor White
    Show-UserInfo
    Write-Host " Voce esta utilizando a versao minima   " -ForegroundColor White
    Write-Host " Data: $data                  " -ForegroundColor Cyan
    Write-Host "==============================================" -ForegroundColor White
    Write-Host ""
    Write-Host "==============================================" -ForegroundColor White
    Write-Host " 1) Bloquear usuario                       " -ForegroundColor White
    Write-Host " 2) Desbloquear usuario                       " -ForegroundColor White
    Write-Host " 3) Deletar usuario                        " -ForegroundColor White
    Write-Host " 4) Resetar a senha                        " -ForegroundColor White
    Write-Host "                                           " -ForegroundColor DarkGray
    Write-Host " 0) Sair do menu                           " -ForegroundColor Red
    Write-Host "==============================================" -ForegroundColor White
    Write-Host ""
}

# --- INICIAR ---
Set-ConsoleCustomization

do {
    Show-Menu
    $input = Read-Host "Digite o numero correspondente a opcao desejada"
    switch ($input) {
        '1' { Disable-User }
        '2' { Enable-User }
        '3' { Remove-User }
        '4' { Reset-Password }
        '0' { Write-Host "Saindo do menu..." -ForegroundColor Red }
        default { Write-Host "Opcao invalida, tente novamente." -ForegroundColor Red }
    }

    if ($input -ne '0') {
        Write-Host ""
        Write-Host "Pressione Enter para continuar..." -ForegroundColor Gray
        $null = Read-Host
    }

} until ($input -eq '0')

Write-Host "`nMenu finalizado. Pressione Enter para fechar o console." -ForegroundColor Gray
Read-Host


##🧑‍💻 Autor
##Wagner Fernandes
##📧 [wagnerviniciusoficial@gmail.com]
##🔗 github.com/wagnercf##