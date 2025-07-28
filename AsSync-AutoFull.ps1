## Autor
##Wagner Fernandes
## [wagnerviniciusoficial@gmail.com]
## github.com/wagnercf##

# Definir codificacao UTF-8 para entrada e saida
[Console]::InputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# --- BLOCO DE AUTO-ELEVACAO VIA UAC ---
# Verifica se o script JA ESTA rodando com privilegios de administrador.
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "Este script requer privilegios de administrador. Solicitando elevacao..." -ForegroundColor Yellow

    try {
        $arguments = "-NoProfile -ExecutionPolicy Bypass -File `\"$PSCommandPath`\" -WindowStyle Minimized"
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
# --- FIM DO BLOCO DE AUTO-ELEVACAO ---

# --- CARREGAMENTO DO MODULO E VARIAVEIS GLOBAIS ---
Import-Module ActiveDirectory

$dominio = "INICIOBANCO.FINALBANCO" # Dominio do local
$baseDN = "OU=BANCO,DC=INICIO BANCO,DC=FINAL BANCO" # Dominio base para construcao dos caminhos
$data = (Get-Date).ToString("dd/MM/yyyy HH:mm:ss") # Data atual

# --- FUNCOES GERAIS ---

function Definir-CustomizacaoConsole {
    $Host.UI.RawUI.ForegroundColor = "White"
    $Host.UI.RawUI.BackgroundColor = "Black"

    $RawUI = $Host.UI.RawUI
    $NovoTamanho = $RawUI.WindowSize
    $NovoTamanho.Width = 90
    $NovoTamanho.Height = 40
    $RawUI.WindowSize = $NovoTamanho
    $RawUI.BufferSize = $NovoTamanho

    Clear-Host
}

# Aplica as customizacoes ao iniciar
Definir-CustomizacaoConsole

# --- BLOCO DE AUTO-ELEVACAO VIA UAC ---
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "Este script requer privilegios de administrador. Solicitando elevacao..." -ForegroundColor Yellow

    try {
        $arguments = "-NoProfile -ExecutionPolicy Bypass -File `\"$PSCommandPath`\" -WindowStyle Minimized"
        Start-Process -FilePath "powershell.exe" 
                      -Verb RunAs 
                      -ArgumentList $arguments 
                      -Wait 
                      -ErrorAction SilentlyContinue 

    }
    catch {
        Write-Host "ERRO: Falha ao tentar elevar privilegios. Certifique-se de ter permissoes de administrador e que o UAC esta configurado." -ForegroundColor Red
        Write-Host "Mensagem de erro: $_" -ForegroundColor Red
        Read-Host "Pressione Enter para fechar..."
    }
    Exit
}
# --- FIM DO BLOCO DE AUTO-ELEVACAO ---

# --- Funcoes do Script Principal ---

function Mostrar-Menu {
    Clear-Host
    Write-Host "==============================================" -ForegroundColor Yellow
    Write-Host "|          MENU DE GERENCIAMENTO AD          |" -ForegroundColor Yellow
    Write-Host "==============================================" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "==============================================" -ForegroundColor White
    Mostrar-InformacaoUsuario
    Write-Host " Voce esta utilizando a versao full   " -ForegroundColor White
    Write-Host " Data: $data                  " -ForegroundColor Cyan
    Write-Host "==============================================" -ForegroundColor White
    Write-Host ""
    Write-Host "==============================================" -ForegroundColor White
    Write-Host " 1) Criar usuario no AD" -ForegroundColor White
    Write-Host " 2) Inativar usuario no AD" -ForegroundColor White
    Write-Host " 3) Reativar usuario no AD" -ForegroundColor White
    Write-Host " 4) Deletar usuario" -ForegroundColor White
    Write-Host " 5) Resetar a senha" -ForegroundColor White
    Write-Host " 6) Desbloquear usuario" -ForegroundColor White
    Write-Host " 7) Associar computador no AD" -ForegroundColor White
    Write-Host " 8) Desassociar computador" -ForegroundColor White
    Write-Host " 9) Deletar computador" -ForegroundColor White
    Write-Host " 10) Alterar ramal" -ForegroundColor White
    Write-Host " 11) Sincronizar AD" -ForegroundColor White
    Write-Host " 12) Listar usuarios" -ForegroundColor White
    Write-Host " 13) Listar computadores" -ForegroundColor White
    Write-Host " 14) Mover objeto para outra OU" -ForegroundColor White
    Write-Host " 15) Adicionar usuario a um grupo" -ForegroundColor White
    Write-Host " 16) Remover usuario de um grupo" -ForegroundColor White
    Write-Host " 17) Verificar membros de um grupo" -ForegroundColor White
    Write-Host " 18) Alterar atributos de um usuario" -ForegroundColor White
    Write-Host " 19) Exportar relatorio de usuarios" -ForegroundColor White
    Write-Host " 20) Exportar relatorio de computadores" -ForegroundColor White
    Write-Host " 21) Exportar relatorio de grupos" -ForegroundColor White
    Write-Host ""
    Write-Host " 0) Sair do script" -ForegroundColor Yellow
    Write-Host "==============================================" -ForegroundColor White
    Write-Host ""
}

function Mostrar-InformacaoUsuario {
    $usuario = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
    Write-Host "Usuario: $usuario         " -ForegroundColor Green
}


function Delete-Computer {
    $computername = Read-Host "Digite o nome do computador para deletar"
    try {
        Remove-ADComputer -Identity $computername -Confirm:$false -ErrorAction Stop
        Write-Host "Computador $computername deletado com sucesso." -ForegroundColor Green
    } catch {
        Write-Host "Erro ao deletar computador: $_" -ForegroundColor Red
    }
}

function Change-Extension {
    $username = Read-Host "Digite o nome do usuario"
    $extension = Read-Host "Digite o novo ramal"
    try {
        Set-ADUser -Identity $username -OfficePhone $extension -ErrorAction Stop
        Write-Host "Ramal do usuario $username alterado para $extension." -ForegroundColor Green
    } catch {
        Write-Host "Erro ao alterar ramal: $_" -ForegroundColor Red
    }
}

function Sync-AD {
    param (
        [string]$ComputerName = "SRVAD01"
    )
    $credential = Get-Credential -Message "Digite suas credenciais para sincronizar o AD (ex: dominio\usuario)"
    Write-Host "Sincronizando AD..." -ForegroundColor Yellow
    try {
        Invoke-Command -ComputerName $ComputerName -Credential $credential -ScriptBlock {
            Import-Module ADSync -ErrorAction Stop
            Start-ADSyncSyncCycle -PolicyType Delta -ErrorAction Stop
        } -ErrorAction Stop
        Write-Host "Sincronizacao concluida." -ForegroundColor Green
    } catch {
        Write-Host "Erro ao sincronizar AD: $_" -ForegroundColor Red
    }
}

function List-Users {
    Write-Host "Escolha a OU base para listar usuarios:" -ForegroundColor Cyan
    Write-Host "1 - Departamentos"
    Write-Host "2 - Consultoria"
    Write-Host "3 - Filiais"
    Write-Host "4 - Usuarios de Servicos de TI"
    $baseOUChoice = Read-Host "Digite o numero correspondente"

    if ($baseOUChoice -eq "1") {
        $subOUName = Read-Host "Digite o setor (ex: T.I, RH, Financeiro)"
    } elseif ($baseOUChoice -eq "2") {
        $subOUName = Read-Host "Digite o nome da empresa (ex: EmpresaX, EmpresaY)"
    } elseif ($baseOUChoice -eq "3") {
        $subOUName = Read-Host "Digite o nome da filial (ex: Bahia, Betim, Cambe)"
    } elseif ($baseOUChoice -eq "4") {
        $subOUName = Read-Host "Digite o nome da sub-OU (ex: BI, Conceito, SAP, RM)"
    } else {
        Write-Host "Opcao invalida." -ForegroundColor Red
        return
    }

    $ouPath = Get-FullOUPath -baseOUChoice $baseOUChoice -subOUName $subOUName

    if ($ouPath) {
        try {
            Get-ADUser -Filter * -SearchBase $ouPath -ErrorAction Stop | Select-Object Name, SamAccountName, Enabled | Format-Table -AutoSize
        } catch {
            Write-Host "Erro ao listar usuarios: $_" -ForegroundColor Red
        }
    }
}

function List-Computers {
    Write-Host "Escolha a OU base para listar computadores:" -ForegroundColor Cyan
    Write-Host "1 - Departamentos"
    Write-Host "2 - Consultoria"
    Write-Host "3 - Filiais"
    Write-Host "4 - Usuarios de Servicos de TI"
    $baseOUChoice = Read-Host "Digite o numero correspondente"

    if ($baseOUChoice -eq "1") {
        $subOUName = Read-Host "Digite o setor (ex: T.I, RH, Financeiro)"
    } elseif ($baseOUChoice -eq "2") {
        $subOUName = Read-Host "Digite o nome da empresa (ex: EmpresaX, EmpresaY)"
    } elseif ($baseOUChoice -eq "3") {
        $subOUName = Read-Host "Digite o nome da filial (ex: Bahia, Betim, Cambe)"
    } elseif ($baseOUChoice -eq "4") {
        $subOUName = Read-Host "Digite o nome da sub-OU (ex: BI, Conceito, SAP, RM)"
    } else {
        Write-Host "Opcao invalida." -ForegroundColor Red
        return
    }

    $ouPath = Get-FullOUPath -baseOUChoice $baseOUChoice -subOUName $subOUName

    if ($ouPath) {
        try {
            Get-ADComputer -Filter * -SearchBase $ouPath -ErrorAction Stop | Select-Object Name, Enabled | Format-Table -AutoSize
        } catch {
            Write-Host "Erro ao listar computadores: $_" -ForegroundColor Red
        }
    }
}

function Move-Object {
    $object = Read-Host "Digite o nome do usuario ou computador"
    Write-Host "Escolha a OU base de destino:" -ForegroundColor Cyan
    Write-Host "1 - Departamentos"
    Write-Host "2 - Consultoria"
    Write-Host "3 - Filiais"
    Write-Host "4 - Usuarios de Servicos de TI"
    $baseOUChoice = Read-Host "Digite o numero correspondente"

    if ($baseOUChoice -eq "1") {
        $subOUName = Read-Host "Digite o setor (ex: T.I, RH, Financeiro)"
    } elseif ($baseOUChoice -eq "2") {
        $subOUName = Read-Host "Digite o nome da empresa (ex: EmpresaX, EmpresaY)"
    } elseif ($baseOUChoice -eq "3") {
        $subOUName = Read-Host "Digite o nome da filial (ex: Bahia, Betim, Cambe)"
    } elseif ($baseOUChoice -eq "4") {
        $subOUName = Read-Host "Digite o nome da sub-OU (ex: BI, Conceito, SAP, RM)"
    } else {
        Write-Host "Opcao invalida." -ForegroundColor Red
        return
    }

    $newOU = Get-FullOUPath -baseOUChoice $baseOUChoice -subOUName $subOUName

    if ($newOU) {
        try {
            Get-ADObject -Filter { Name -eq $object } -ErrorAction Stop | Move-ADObject -TargetPath $newOU -ErrorAction Stop
            Write-Host "Objeto $object movido para $newOU com sucesso." -ForegroundColor Green
        } catch {
            Write-Host "Erro ao mover objeto: $_" -ForegroundColor Red
        }
    }
}

function Add-UserToGroup {
    $username = Read-Host "Digite o nome do usuario"
    $group = Read-Host "Digite o nome do grupo"
    try {
        $user = Get-ADUser -Identity $username -ErrorAction Stop
        $groupObj = Get-ADGroup -Identity $group -ErrorAction Stop
        Add-ADGroupMember -Identity $group -Members $username -ErrorAction Stop
        Write-Host "Usuario $username adicionado ao grupo $group com sucesso." -ForegroundColor Green
    } catch {
        Write-Host "Erro ao adicionar usuario ao grupo: $_" -ForegroundColor Red
    }
}

function Remove-UserFromGroup {
    $username = Read-Host "Digite o nome do usuario"
    $group = Read-Host "Digite o nome do grupo"
    try {
        Remove-ADGroupMember -Identity $group -Members $username -Confirm:$false -ErrorAction Stop
        Write-Host "Usuario $username removido do grupo $group com sucesso." -ForegroundColor Green
    } catch {
        Write-Host "Erro ao remover usuario do grupo: $_" -ForegroundColor Red
    }
}

function Get-GroupMembers {
    $group = Read-Host "Digite o nome do grupo"
    try {
        Get-ADGroupMember -Identity $group -ErrorAction Stop | Select-Object Name, SamAccountName | Format-Table -AutoSize
    } catch {
        Write-Host "Erro ao listar membros do grupo: $_" -ForegroundColor Red
    }
}

function Set-UserAttributes {
    $username = Read-Host "Digite o nome do usuario"
    $attribute = Read-Host "Digite o atributo a ser alterado (ex: Title, Department)"
    $value = Read-Host "Digite o novo valor"
    try {
        Set-ADUser -Identity $username -Replace @{ $attribute = $value } -ErrorAction Stop
        Write-Host "Atributo $attribute do usuario $username alterado para $value com sucesso." -ForegroundColor Green
    } catch {
        Write-Host "Erro ao alterar atributo: $_" -ForegroundColor Red
    }
}

function Export-UserReport {
    Write-Host "Escolha a OU base para exportar usuarios:" -ForegroundColor Cyan
    Write-Host "1 - Departamentos"
    Write-Host "2 - Consultoria"
    Write-Host "3 - Filiais"
    Write-Host "4 - Usuarios de Servicos de TI"
    $baseOUChoice = Read-Host "Digite o numero correspondente"

    if ($baseOUChoice -eq "1") {
        $subOUName = Read-Host "Digite o setor (ex: T.I, RH, Financeiro)"
    } elseif ($baseOUChoice -eq "2") {
        $subOUName = Read-Host "Digite o nome da empresa (ex: EmpresaX, EmpresaY)"
    } elseif ($baseOUChoice -eq "3") {
        $subOUName = Read-Host "Digite o nome da filial (ex: Bahia, Betim, Cambe)"
    } elseif ($baseOUChoice -eq "4") {
        $subOUName = Read-Host "Digite o nome da sub-OU (ex: BI, Conceito, SAP, RM)"
    } else {
        Write-Host "Opcao invalida." -ForegroundColor Red
        return
    }

    $ouPath = Get-FullOUPath -baseOUChoice $baseOUChoice -subOUName $subOUName
    $outputFile = Read-Host "Digite o nome do arquivo de saida (ex: usuarios.csv)"

    if ($ouPath) {
        try {
            Get-ADUser -Filter * -SearchBase $ouPath -ErrorAction Stop | Select-Object Name, SamAccountName, Enabled | Export-Csv -Path $outputFile -NoTypeInformation -ErrorAction Stop
            Write-Host "Relatorio de usuarios exportado para $outputFile com sucesso." -ForegroundColor Green
        } catch {
            Write-Host "Erro ao exportar relatorio: $_" -ForegroundColor Red
        }
    }
}

function Export-ComputerReport {
    Write-Host "Escolha a OU base para exportar computadores:" -ForegroundColor Cyan
    Write-Host "1 - Departamentos"
    Write-Host "2 - Consultoria"
    Write-Host "3 - Filiais"
    Write-Host "4 - Usuarios de Servicos de TI"
    $baseOUChoice = Read-Host "Digite o numero correspondente"

    if ($baseOUChoice -eq "1") {
        $subOUName = Read-Host "Digite o setor (ex: T.I, RH, Financeiro)"
    } elseif ($baseOUChoice -eq "2") {
        $subOUName = Read-Host "Digite o nome da empresa (ex: EmpresaX, EmpresaY)"
    } elseif ($baseOUChoice -eq "3") {
        $subOUName = Read-Host "Digite o nome da filial (ex: Bahia, Betim, Cambe)"
    } elseif ($baseOUChoice -eq "4") {
        $subOUName = Read-Host "Digite o nome da sub-OU (ex: BI, Conceito, SAP, RM)"
    } else {
        Write-Host "Opcao invalida." -ForegroundColor Red
        return
    }

    $ouPath = Get-FullOUPath -baseOUChoice $baseOUChoice -subOUName $subOUName
    $outputFile = Read-Host "Digite o nome do arquivo de saida (ex: computadores.csv)"

    if ($ouPath) {
        try {
            Get-ADComputer -Filter * -SearchBase $ouPath -ErrorAction Stop | Select-Object Name, Enabled, LastLogonDate | Export-Csv -Path $outputFile -NoTypeInformation -ErrorAction Stop
            Write-Host "Relatorio de computadores exportado para $outputFile com sucesso." -ForegroundColor Green
        } catch {
            Write-Host "Erro ao exportar relatorio: $_" -ForegroundColor Red
        }
    }
}

function Export-GroupReport {
    $setor = Read-Host "Digite o setor (ex: T.I, RH, Financeiro)"
    $ouPath = "OU=Grupos,OU=$setor,OU=Departamentos,$baseDN"
    $outputFile = Read-Host "Digite o nome do arquivo de saida (ex: grupos.csv)"
    try {
        Get-ADGroup -Filter * -SearchBase $ouPath -ErrorAction Stop | 
        Select-Object Name, SamAccountName, GroupCategory, GroupScope | 
        Export-Csv -Path $outputFile -NoTypeInformation -ErrorAction Stop
        Write-Host "Relatorio de grupos exportado para $outputFile com sucesso." -ForegroundColor Green
    } catch {
        Write-Host "Erro ao exportar relatorio de grupos: $_" -ForegroundColor Red
    }
}
