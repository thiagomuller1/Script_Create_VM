# Função para validar entrada de números inteiros positivos
function Validate-PositiveInteger {
    param(
        [string]$prompt
    )
    do {
        $input = Read-Host $prompt
    } until ($input -match '^\d+$')
    return $input
}

# Solicitar ao usuário quantos servidores Hyper-V serão usados
$numHyperV = Validate-PositiveInteger "Quantos servidores Hyper-V serão usados?"

# Inicializar lista de servidores
$servers = @()

# Loop para solicitar os nomes dos servidores
for ($i = 1; $i -le $numHyperV; $i++) {
    $hyperVServer = Read-Host "Digite o nome do servidor Hyper-V #$i"
    $servers += $hyperVServer
}

# Inicializar lista de VMs e discos para deploy
$deployData = @()

# Loop para lidar com cada servidor
foreach ($hyperVServer in $servers) {
    # Solicitar ao usuário quantas VMs serão criadas neste servidor
    $numVMs = Validate-PositiveInteger "Quantas VMs serão criadas no servidor ${hyperVServer}:"

    # Loop para lidar com cada VM
    for ($j = 1; $j -le $numVMs; $j++) {
        # Solicitar ao usuário os detalhes da VM
        $vmName = Read-Host "Digite o nome da VM #$j no servidor $hyperVServer"
        $vmGeneration = Read-Host "Digite a geração da VM (Digite '1' para Geração 1 ou '2' para Geração 2) para a VM $vmName no servidor $hyperVServer"
        $image = Read-Host "Digite o caminho para o arquivo ISO da VM $vmName no servidor $hyperVServer"
        $parentFolderPath = Read-Host "Digite o caminho onde a pasta da VM deve residir no servidor $hyperVServer"
        $vmswitch = Read-Host "Digite o nome do vSwitch local para a VM $vmName no servidor $hyperVServer"
        $needVlan = Read-Host "A VM $vmName precisa de uma VLAN? (Digite 's' para sim ou 'n' para não)"

        if ($needVlan -eq "s") {
            $vlan = Validate-PositiveInteger "Digite o número da VLAN para a VM $vmName no servidor $hyperVServer"
        } else {
            $vlan = 0
        }

        $cpu = Validate-PositiveInteger "Digite o número de CPUs para a VM $vmName no servidor $hyperVServer"
        $ramInput = Validate-PositiveInteger "Digite a quantidade de RAM (em GB) para a VM $vmName no servidor $hyperVServer"
        $ram = [math]::round(([double]::Parse($ramInput)) * 1GB)

        # Construir o caminho completo para a pasta da VM
        $path_to_vm = Join-Path -Path $parentFolderPath -ChildPath $vmName

        # Construir o nome do disco VHDX
        if ($vmGeneration -eq "1") {
            $diskName = "${vmName}_1.vhdx"
        } elseif ($vmGeneration -eq "2") {
            $diskName = "${vmName}_C.vhdx"
        }

        $diskSizeInput = Validate-PositiveInteger "Digite o tamanho do disco (em GB) para a VM $vmName no servidor $hyperVServer"
        $diskSize = [math]::round(([double]::Parse($diskSizeInput)) * 1GB)

        # Adicionar dados de deploy à lista
        $deployData += @{
            Server = $hyperVServer
            VMName = $vmName
            VMGeneration = $vmGeneration
            Image = $image
            ParentFolderPath = $parentFolderPath
            VMSwitch = $vmswitch
            NeedVlan = $needVlan
            Vlan = $vlan
            CPU = $cpu
            RAM = $ram
            DiskName = $diskName
            DiskSize = $diskSize
            PathToVM = $path_to_vm
        }
    }
}

# Exibir resumo das VMs e discos a serem criados
Write-Host "`nResumo do Deploy:`n"
$deployData | Format-Table -AutoSize

# Solicitar confirmação antes do deploy
$confirmDeploy = Read-Host "Deseja prosseguir com o deploy das VMs e discos acima? (Digite 's' para sim ou 'n' para não)"

if ($confirmDeploy -eq "s") {
    # Loop para lidar com cada conjunto de dados de deploy
    foreach ($data in $deployData) {
        # Criar a sessão remota
        $session = New-PSSession -ComputerName $data.Server

        # Comandos da sessão remota para criar a VM
        Invoke-Command -Session $session -ScriptBlock {
            param($data)
            
            # Importar módulo Hyper-V
            Import-Module Hyper-V

            # Criar a pasta da VM
            New-Item -Path $data.PathToVM -ItemType Directory

            # Criar uma nova VM com a geração especificada
            if ($data.VMGeneration -eq "1") {
                New-VM -Name $data.VMName -Generation 1 -Path $data.PathToVM
                Set-VMDvdDrive -VMName $data.VMName -Path $data.Image -ControllerNumber 1 -ControllerLocation 0
            } elseif ($data.VMGeneration -eq "2") {
                New-VM -Name $data.VMName -Generation 2 -Path $data.PathToVM
                Add-VMDvdDrive -VMName $data.VMName -Path $data.Image
                Set-VMFirmware -VMName $data.VMName -EnableSecureBoot Off
            } else {
                Write-Host "Opção inválida. Saindo do script."
                Exit
            }

            # Definir a CPU e RAM de inicialização
            Set-VM -Name $data.VMName -ProcessorCount $data.CPU -MemoryStartupBytes $data.RAM

            # Criar o novo disco VHDX - o caminho e tamanho.
            New-VHD -Path "$($data.PathToVM)\$($data.DiskName)" -Fixed -SizeBytes $data.DiskSize

            # Adicionar o novo disco à VM
            Add-VMHardDiskDrive -VMName $data.VMName -Path "$($data.PathToVM)\$($data.DiskName)"

            # Remover a NIC padrão da VM chamada 'Adaptador de Rede'
            Remove-VMNetworkAdapter -VMName $data.VMName

            # Definir a opção "Automatic Stop Action" para "Shut Down the guest operating system"
            Set-VM -Name $data.VMName -AutomaticStopAction ShutDown

            # Definir a opção "Automatic Start Action" para "Nothing"
            Set-VM -Name $data.VMName -AutomaticStartAction Nothing

            # Adicionar uma nova placa de rede à VM
            Add-VMNetworkAdapter -VMName $data.VMName -Name "NetworkAdapter" -SwitchName $data.VMSwitch

            # Conectar a nova placa de rede ao vSwitch "Acesso" se VLAN estiver configurada
            if ($data.NeedVlan -eq "s") {
                Connect-VMNetworkAdapter -VMName $data.VMName -Name "NetworkAdapter" -SwitchName $data.VMSwitch

                # Definir VLAN para a placa de rede da VM
                Set-VMNetworkAdapterVlan -VMName $data.VMName -VMNetworkAdapterName "NetworkAdapter" -Access -VlanId $data.Vlan
            }

            # Iniciar a máquina virtual
            Start-VM -Name $data.VMName
        } -ArgumentList $data

        # Fechar a sessão remota após a execução
        Remove-PSSession $session
    }
} else {
    Write-Host "O deploy foi cancelado pelo usuário."
}
