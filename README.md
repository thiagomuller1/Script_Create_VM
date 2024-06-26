# Powershell Script Cria Servidores Virtuais Hyper-v

# Pré-Requisitos
- Usuario Com Privilegios Administrativos Nos Servidores Hyper-v
- WinRM Habilitado No Servidor de Origem e Nos Servidores De Destino
  Você Pode Verificar Com o Comando *Get-Service WinRM* e Ativar Com *Enable-PSRemoting*
- Sistemas Operacionais Posteriores a Windows Server 2008
- Firewall Precisa Permitir o Tráfego de Entrada na Porta 5985 para HTTP e a Porta 5986 para HTTPS
  Pode Configurar Utilizando o cmdlet *New-NetFirewallRule -Name "WinRM Port 5985" -DisplayName "WinRM Port 5985" -Enabled True -Direction Inbound -Protocol TCP -LocalPort 5985 -Action Allow*
  
# Perguntas Solicitadas Pelo Script
- Quantos Servidores Hyper-v Serão Usados:?
- Digite o nome do Servidor Hyper-v:
- Quantas VM's Serão Criadas no Servidor:
- Digite o nome da VM:
- Digite a Geração da VM (1 ou 2)
- Digite o Caminho Para o Arquivo ISO:
- Digite o Caminho onde a Pasta da VM Deve Residir no Servidor Hyper-v:
- Digite o nome do vSwitch para VM:
- A VM Precisará de uma VLAN?:
- Digite o número da VLAN: (Se a Resposta For Sim no Passo Anterior)
- Digite o Número de CPUS:
- Digite a Quantidade de RAM:
- Digite o tamanho do Disco:
- *Mostra resumo do Deploy*
- Deseja Processeguir com o Deploy?:

# Configurações Automatizadas Pelo Script
- Cria VM Geração 1 ou 2
- Cria o Disco Tipo Fixo
- Cria o Disco Com Nome da VM No Padrão "VM_1.vhdx" (Geração 1)
- Cria o Disco Com Nome da VM No Padrão "VM_C.vhdx" (Geração 2)
- Cria Memória Com a Opção Dinamica Desabilitada
- Desabilita Secure Boot
- Inicialização de Boot na ISO
- Anexa ISO na IDE Controller 1 (Ger1) e SCSI (Ger2)
- Anexa vSwitch do Hyper-v
- Configura Vlan (Caso Preenchido)
- Cria o Diretório Com Nome Da VM
- Seleciona a Opção "Nothing" Para o "Automatic Start Action" Nas Configurações Da VM
- Seleciona a Opção "Shut Down" Para o "Automatic Stop Action" Nas Configurações Da VM
- Liga a VM Após o Deploy

# Diagrama Ambiente Teste
![Azure_Diagram](https://github.com/thiagomuller1/Script_Create_VM/assets/87444620/18b99c56-647e-4152-bde3-d0545f79150e)

# Perguntas Solicitadas Pelo Script
![Requirements](https://github.com/thiagomuller1/Script_Create_VM/assets/87444620/0129abc3-c080-45da-824d-fc37d4c895d3)

# Confirmação De Deploy
![Deploy](https://github.com/thiagomuller1/Script_Create_VM/assets/87444620/3e80d2f7-04e0-4f7e-ab0a-0153d68bcd6d)

# Hyper-v 01 Sem VM's
![hpv01](https://github.com/thiagomuller1/Script_Create_VM/assets/87444620/bc644135-4147-451e-90ae-80d62aed962c)

# Hyper-v 02 Sem VM's
![hpv02](https://github.com/thiagomuller1/Script_Create_VM/assets/87444620/f0fb66a0-6ee6-4b32-8c75-d6c931c34c17)

# Confirmando Deploy
![Creation](https://github.com/thiagomuller1/Script_Create_VM/assets/87444620/533df2b0-ada2-4c68-a10f-ec4d5799eaaf)

# VM Geração 1 Criada
![VM_G1](https://github.com/thiagomuller1/Script_Create_VM/assets/87444620/e1d9b82f-a3a8-42e7-a893-650003da8f16)

# VM Geração 2 Criada
![VM_G2](https://github.com/thiagomuller1/Script_Create_VM/assets/87444620/2131d0a3-4bbf-49b7-bbfb-818e93db14ae)

# Configurações VM Geração 1
![Settings_VM_G1](https://github.com/thiagomuller1/Script_Create_VM/assets/87444620/a629b950-78b6-4035-94a2-3642d3eebef9)

# Configurações VM Geração 2
![Settings_VM_G2](https://github.com/thiagomuller1/Script_Create_VM/assets/87444620/60f3d91e-2883-4c2f-b98b-3d22bd127970)
