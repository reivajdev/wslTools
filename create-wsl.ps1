function create-alias-wsl {
    param(
        [string]$AliasName     # Nombre del alias
    )

    # Ruta del perfil de PowerShell
    $profilePath = $PROFILE
    # El alias que quieres agregar, dinámicamente
    $aliasCommand = "Set-Alias $AliasName wsl -d $AliasName"
    
    # Ejecutar el alias en la sesión actual
    Invoke-Expression -Command $aliasCommand
    Invoke-Expression -Command "Get-Alias $AliasName"
    # Verificar si el alias ya existe en el perfil
    if (-not (Get-Content $profilePath | Select-String -Pattern "Set-Alias $AliasName wsl -d $AliasName")) {
        # Si no existe, agregar el comando al final del perfil
        Add-Content -Path $profilePath -Value "$aliasCommand`n"
        Write-Host "Alias '$AliasName' agregado al perfil."
    } else {
        Write-Host "El alias '$AliasName' ya existe en el perfil."
    }
}

function create-wsl {
    param (
        [Parameter(Mandatory=$true)]
        [string]$Name,                # Nombre de la distribución
        [string]$ImportPath = "D:\linux_system",  # Ruta para importar
        [string]$Tarball = "D:\linux_system\00.image\debian.tar" # Ruta del archivo TAR
    )

    # Ruta completa para importar
    $FullImportPath = Join-Path -Path $ImportPath -ChildPath $Name

    Write-Host "Importando la distribución WSL '$Name'..." -ForegroundColor Green
    wsl --import $Name $FullImportPath $Tarball

    Write-Host "Configurando '$Name' como la distribución predeterminada..." -ForegroundColor Green
    wsl --set-default $Name
    
    # Configuración de WSL
    wsl -d $Name bash -c "sudo apt install -y vim"

    # Escribir en /etc/wsl.conf
    wsl -d $Name bash -c "echo '[user]' | sudo tee -a /etc/wsl.conf"
    wsl -d $Name bash -c "echo 'default=reivaj2dev' | sudo tee -a /etc/wsl.conf"
    wsl -d $Name bash -c "echo '[network]' | sudo tee -a /etc/wsl.conf"
    wsl -d $Name bash -c "echo 'hostname=$Name' | sudo tee -a /etc/wsl.conf"

    Write-Host "Creando wsl.conf en '$Name'..." -ForegroundColor Green

    # Finalizar la instancia de WSL y configurar .bashrc
    Write-Host "Terminado '$Name'..." -ForegroundColor Green
    wsl -t $Name
    wsl -d $Name bash -c "echo cd ~ >> /home/reivaj2dev/.bashrc"
    wsl -t $Name

    Write-Host "Configuración completada para la distribución '$Name'." -ForegroundColor Green

    # Crear el alias para esta distribución
    create-alias-wsl -AliasName $Name
}
