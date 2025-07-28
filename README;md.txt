# 🛠️ Script de Gerenciamento do Active Directory via PowerShell

Este script PowerShell foi desenvolvido para auxiliar administradores de rede a realizar tarefas comuns de gerenciamento no Active Directory de forma simples, segura e automatizada, utilizando uma interface de menu no terminal.

---

## 📋 Funcionalidades

- 🔐 Autoelevação com UAC (executa como administrador automaticamente)
- 👤 Inativar conta de usuário
- ✅ Reativar conta de usuário
- ❌ Deletar conta de usuário
- 🔁 Resetar senha de usuário
- 📆 Exibe data/hora e usuário atual
- 🖥️ Interface de menu interativa no console PowerShell

---

## 💻 Requisitos

### ✅ Sistema Operacional
- Windows 10, 11 ou Server 2016/2019/2022

### ✅ Permissões
- O script **deve ser executado como administrador**
- Usuário deve ter permissões para manipular contas do AD

### ✅ Módulo PowerShell necessário
- `ActiveDirectory` (incluso no RSAT)

### 📥 Instalação do módulo Active Directory (RSAT)

#### Opção 1: via interface gráfica (Windows 10/11 Pro)
1. Acesse **Configurações > Aplicativos > Recursos Opcionais**
2. Clique em **Adicionar um recurso**
3. Instale: `RSAT: Ferramentas de administração de diretório ativo`

#### Opção 2: via PowerShell

```powershell
Get-WindowsCapability -Name RSAT* -Online | Where-Object Name -like "*Directory*" | Add-WindowsCapability -Online




##🧑‍💻 Autor
##Wagner Fernandes
##📧 [wagnerviniciusoficial@gmail.com]
##🔗 github.com/wagnercf##