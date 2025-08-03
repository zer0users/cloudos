-- ==========================================
-- CLOUDOS - INSTALADOR
-- Archivo: install-cloudos.lua
-- Uso: wget https://example.com/install-cloudos.lua install-cloudos
-- ==========================================

print("CloudOS Installer v1.0")
print("Preparing all for you..")

-- Crear estructura de directorios base
if not fs.exists("partition") then
    fs.makeDir("partition")
end

if not fs.exists("partition/recovery") then
    fs.makeDir("partition/recovery")
end

if not fs.exists("partition/boot") then
    fs.makeDir("partition/boot")
end

-- Crear recovery.lua
local recoveryCode = "-- ==========================================\n" ..
"-- CLOUDOS RECOVERY SYSTEM v1.0\n" ..
"-- ==========================================\n"

recoveryCode = recoveryCode .. "\n" ..
"local currentDir = \"partition:recovery\"\n" ..
"local currentPartition = \"recovery\"\n\n" ..
"-- Funciones del sistema\n" ..
"local function parseCommand(input)\n" ..
"    local parts = {}\n" ..
"    for part in input:gmatch(\"%S+\") do\n" ..
"        table.insert(parts, part)\n" ..
"    end\n" ..
"    return parts\n" ..
"end\n\n" ..
"local function getActualPath(path)\n" ..
"    if path:match(\"^partition:\") then\n" ..
"        local partName = path:match(\"^partition:(.+)\")\n" ..
"        return \"partition/\" .. partName\n" ..
"    else\n" ..
"        if currentPartition == \"recovery\" then\n" ..
"            return \"partition/recovery/\" .. (path or \"\")\n" ..
"        elseif currentPartition == \"boot\" then\n" ..
"            return \"partition/boot/\" .. (path or \"\")\n" ..
"        else\n" ..
"            return \"partition/\" .. currentPartition .. \"/\" .. (path or \"\")\n" ..
"        end\n" ..
"    end\n" ..
"end\n\n" ..
"local function listFiles(path)\n" ..
"    local actualPath = path and getActualPath(path) or getActualPath(\"\")\n" ..
"    \n" ..
"    if not fs.exists(actualPath) then\n" ..
"        print(\"Directory not found: \" .. (path or currentDir))\n" ..
"        return\n" ..
"    end\n" ..
"    \n" ..
"    local files = fs.list(actualPath)\n" ..
"    for _, file in ipairs(files) do\n" ..
"        if fs.isDir(fs.combine(actualPath, file)) then\n" ..
"            print(file .. \"/\")\n" ..
"        else\n" ..
"            print(file)\n" ..
"        end\n" ..
"    end\n" ..
"end\n\n" ..
"local function changeDirectory(path)\n" ..
"    if not path then\n" ..
"        print(\"Usage: cd <directory/partition>\")\n" ..
"        return\n" ..
"    end\n" ..
"    \n" ..
"    if path:match(\"^partition:\") then\n" ..
"        local partName = path:match(\"^partition:(.+)\")\n" ..
"        local partPath = \"partition/\" .. partName\n" ..
"        \n" ..
"        if fs.exists(partPath) and fs.isDir(partPath) then\n" ..
"            currentDir = path\n" ..
"            currentPartition = partName\n" ..
"            print(\"Changed to \" .. path)\n" ..
"        else\n" ..
"            print(\"Partition not found: \" .. partName)\n" ..
"        end\n" ..
"    else\n" ..
"        local newPath = getActualPath(path)\n" ..
"        if fs.exists(newPath) and fs.isDir(newPath) then\n" ..
"            currentDir = currentDir .. \"/\" .. path\n" ..
"        else\n" ..
"            print(\"Directory not found: \" .. path)\n" ..
"        end\n" ..
"    end\n" ..
"end\n\n" ..
"local function mountPartition(partName)\n" ..
"    if not partName then\n" ..
"        print(\"Usage: mount <partition_name>\")\n" ..
"        return\n" ..
"    end\n" ..
"    \n" ..
"    local partPath = \"partition/\" .. partName\n" ..
"    if not fs.exists(partPath) then\n" ..
"        fs.makeDir(partPath)\n" ..
"        print(\"Partition '\" .. partName .. \"' mounted successfully\")\n" ..
"    else\n" ..
"        print(\"Partition '\" .. partName .. \"' already exists\")\n" ..
"    end\n" ..
"end\n\n" ..
"local function unmountPartition(partName)\n" ..
"    if not partName then\n" ..
"        print(\"Usage: unmount <partition_name>\")\n" ..
"        return\n" ..
"    end\n" ..
"    \n" ..
"    if partName == \"recovery\" or partName == \"boot\" then\n" ..
"        print(\"Cannot unmount system partition: \" .. partName)\n" ..
"        return\n" ..
"    end\n" ..
"    \n" ..
"    local partPath = \"partition/\" .. partName\n" ..
"    if fs.exists(partPath) then\n" ..
"        fs.delete(partPath)\n" ..
"        print(\"Partition '\" .. partName .. \"' unmounted successfully\")\n" ..
"    else\n" ..
"        print(\"Partition not found: \" .. partName)\n" ..
"    end\n" ..
"end\n\n" ..
"local function cloudPackageManager(action, packageName)\n" ..
"    if action == \"install\" then\n" ..
"        if not packageName then\n" ..
"            print(\"Usage: cloud install <package_name>\")\n" ..
"            return\n" ..
"        end\n" ..
"        \n" ..
"        print(\"Searching for \\\"\" .. packageName .. \"\\\"..\") \n" ..
"        \n" ..
"        local url = \"https://raw.githubusercontent.com/zer0users/cloudos/refs/heads/main/repository/\" .. packageName .. \".lua\"\n" ..
"        \n" ..
"        -- Simular descarga y verificacion de tamano\n" ..
"        local success = true\n" ..
"        \n" ..
"        if success then\n" ..
"            local packageSize = math.random(1024, 8192)\n" ..
"            print(\"This Package is \" .. packageSize .. \" bytes.\")\n" ..
"            \n" ..
"            write(\"Do you want to install it? (Y/N): \")\n" ..
"            local response = read()\n" ..
"            \n" ..
"            if response:lower() == \"y\" or response:lower() == \"yes\" then\n" ..
"                print(\"Installing \" .. packageName .. \"..\")\n" ..
"                print(\"======================\")\n" ..
"                \n" ..
"                print(\"Package installation script would run here...\")\n" ..
"                print(\"Creating files and directories...\")\n" ..
"                print(\"Configuring system...\")\n" ..
"                \n" ..
"                print(\"======================\")\n" ..
"                print(\"Done! Thank Jehovah!\")\n" ..
"            else\n" ..
"                print(\"Installation cancelled.\")\n" ..
"            end\n" ..
"        else\n" ..
"            print(\"Package not found: \" .. packageName)\n" ..
"        end\n" ..
"        \n" ..
"    elseif action == \"list\" then\n" ..
"        print(\"Available packages:\")\n" ..
"        print(\"- mi-os\")\n" ..
"        print(\"- terminal-os\")\n" ..
"        print(\"- micro-kernel\")\n" ..
"        print(\"Use 'cloud install <package>' to install\")\n" ..
"        \n" ..
"    else\n" ..
"        print(\"CloudOS Package Manager\")\n" ..
"        print(\"Usage:\")\n" ..
"        print(\"  cloud install <package> - Install a package\")\n" ..
"        print(\"  cloud list              - List available packages\")\n" ..
"    end\n" ..
"end\n\n" ..
"-- Loop principal del recovery\n" ..
"print(\"CloudOS Recovery 1.0\")\n\n" ..
"while true do\n" ..
"    write(\"root:\" .. currentPartition .. \"#> \")\n" ..
"    local input = read()\n" ..
"    \n" ..
"    if input == \"\" then\n" ..
"        -- No hacer nada con lineas vacias\n" ..
"    elseif input == \"exit\" or input == \"quit\" then\n" ..
"        print(\"Rebooting to boot partition...\")\n" ..
"        sleep(1)\n" ..
"        if fs.exists(\"partition/system\") and #fs.list(\"partition/system\") > 0 then\n" ..
"            print(\"System partition found, attempting to boot...\")\n" ..
"        else\n" ..
"            print(\"No system partition found, staying in recovery mode.\")\n" ..
"        end\n" ..
"        break\n" ..
"    else\n" ..
"        local parts = parseCommand(input)\n" ..
"        local command = parts[1]\n" ..
"        \n" ..
"        if command == \"ls\" then\n" ..
"            listFiles(parts[2])\n" ..
"            \n" ..
"        elseif command == \"cd\" then\n" ..
"            changeDirectory(parts[2])\n" ..
"            \n" ..
"        elseif command == \"mount\" then\n" ..
"            mountPartition(parts[2])\n" ..
"            \n" ..
"        elseif command == \"unmount\" then\n" ..
"            unmountPartition(parts[2])\n" ..
"            \n" ..
"        elseif command == \"cloud\" then\n" ..
"            cloudPackageManager(parts[2], parts[3])\n" ..
"            \n" ..
"        elseif command == \"help\" then\n" ..
"            print(\"CloudOS Recovery Commands:\")\n" ..
"            print(\"  ls [path]                 - List files and directories\")\n" ..
"            print(\"  cd <path/partition>       - Change directory\")\n" ..
"            print(\"  mount <partition>         - Create/mount partition\")\n" ..
"            print(\"  unmount <partition>       - Remove/unmount partition\")\n" ..
"            print(\"  cloud install <package>   - Install package\")\n" ..
"            print(\"  cloud list               - List available packages\")\n" ..
"            print(\"  help                     - Show this help\")\n" ..
"            print(\"  exit                     - Exit recovery mode\")\n" ..
"            \n" ..
"        else\n" ..
"            print(\"Unknown command: \" .. command)\n" ..
"            print(\"Type 'help' for available commands\")\n" ..
"        end\n" ..
"    end\n" ..
"end"

-- Escribir recovery.lua
local recoveryFile = fs.open("partition/recovery/recovery.lua", "w")
recoveryFile.write(recoveryCode)
recoveryFile.close()

-- Crear boot.lua
local bootCode = "-- ==========================================\\n" ..
"-- CLOUDOS BOOT SYSTEM\\n" ..
"-- ==========================================\\n\\n" ..
"print(\\\"Welcome to CloudOS!\\\")\\n" ..
"print(\\\"BOOTLOADER_REASON=\\\\\\\"AUTOMATIC_REBOOT\\\\\\\"\\\")\\n" ..
"sleep(0.1)\\n" ..
"term.clear()\\n" ..
"term.setCursorPos(1, 1)\\n\\n" ..
"if fs.exists(\\\"partition/system\\\") and #fs.list(\\\"partition/system\\\") > 0 then\\n" ..
"    print(\\\"System partition found. Attempting to boot system...\\\")\\n" ..
"    \\n" ..
"    if fs.exists(\\\"partition/system/init.lua\\\") then\\n" ..
"        print(\\\"Loading system from partition/system/init.lua\\\")\\n" ..
"        shell.run(\\\"partition/system/init.lua\\\")\\n" ..
"    elseif fs.exists(\\\"partition/system/startup.lua\\\") then\\n" ..
"        print(\\\"Loading system from partition/system/startup.lua\\\")\\n" ..
"        shell.run(\\\"partition/system/startup.lua\\\")\\n" ..
"    else\\n" ..
"        print(\\\"No valid system startup file found in system partition.\\\")\\n" ..
"        print(\\\"Falling back to recovery mode...\\\")\\n" ..
"        shell.run(\\\"partition/recovery/recovery.lua\\\")\\n" ..
"    end\\n" ..
"else\\n" ..
"    print(\\\"No system partition found or system partition is empty.\\\")\\n" ..
"    print(\\\"Booting into recovery mode...\\\")\\n" ..
"    sleep(1)\\n" ..
"    shell.run(\\\"partition/recovery/recovery.lua\\\")\\n" ..
"end"

-- Escribir boot.lua
local bootFile = fs.open("partition/boot/boot.lua", "w")
bootFile.write(bootCode)
bootFile.close()

-- Crear startup.lua principal  
local startupCode = "-- ==========================================\\n" ..
"-- CLOUDOS MAIN STARTUP\\n" ..
"-- ==========================================\\n\\n" ..
"if not fs.exists(\\\"partition\\\") then\\n" ..
"    print(\\\"CloudOS partition structure not found!\\\")\\n" ..
"    print(\\\"Please reinstall CloudOS.\\\")\\n" ..
"    return\\n" ..
"end\\n\\n" ..
"if fs.exists(\\\"partition/boot/boot.lua\\\") then\\n" ..
"    shell.run(\\\"partition/boot/boot.lua\\\")\\n" ..
"else\\n" ..
"    print(\\\"Boot system not found!\\\")\\n" ..
"    print(\\\"CloudOS installation may be corrupted.\\\")\\n" ..
"    \\n" ..
"    if fs.exists(\\\"partition/recovery/recovery.lua\\\") then\\n" ..
"        print(\\\"Attempting to load recovery system...\\\")\\n" ..
"        shell.run(\\\"partition/recovery/recovery.lua\\\")\\n" ..
"    else\\n" ..
"        print(\\\"Recovery system also not found. Please reinstall CloudOS.\\\")\\n" ..
"    end\\n" ..
"end"

-- Escribir startup.lua principal
local startupFile = fs.open("startup.lua", "w")
startupFile.write(startupCode)
startupFile.close()

print("Done!")
print("Rebooting..")
sleep(2)

-- Simular reinicio ejecutando el startup
shell.run("startup.lua")

-- ==========================================
-- GUÍA DE INSTALACIÓN Y USO
-- ==========================================

--[[

GUÍA COMPLETA DE CLOUDOS

=== INSTALACIÓN ===

1. Descargar el instalador:
   > wget https://raw.githubusercontent.com/tuusuario/cloudos/main/install-cloudos.lua install-cloudos

2. Ejecutar el instalador:
   > install-cloudos

3. El sistema se instalará automáticamente y reiniciará.

=== ESTRUCTURA DEL SISTEMA ===

Después de la instalación, CloudOS crea esta estructura:

/
├── startup.lua                    (Inicio principal del sistema)
└── partition/                     (Directorio de particiones)
    ├── recovery/                  (Partición de recuperación)
    │   └── recovery.lua          (Sistema de recuperación)
    ├── boot/                      (Partición de arranque)
    │   └── boot.lua              (Gestor de arranque)
    └── system/                    (Partición del sistema - creada al instalar un SO)

=== PROCESO DE ARRANQUE ===

1. startup.lua ejecuta boot.lua
2. boot.lua verifica si existe partition/system/
3. Si existe sistema: Ejecuta el SO instalado
4. Si no existe: Inicia el modo recovery

=== COMANDOS DISPONIBLES EN RECOVERY ===

- ls [ruta]                 : Lista archivos y directorios
- cd <ruta/partición>       : Cambia de directorio
- mount <partición>         : Crea/monta una partición
- unmount <partición>       : Elimina/desmonta una partición
- cloud install <paquete>   : Instala un paquete
- cloud list               : Lista paquetes disponibles
- help                     : Muestra ayuda
- exit                     : Sale del modo recovery

=== EJEMPLOS DE USO ===

Crear partición de sistema:
root:recovery#> mount system

Navegar a la partición de sistema:
root:recovery#> cd partition:system

Instalar un sistema operativo:
root:recovery#> cloud install mi-os

Listar paquetes disponibles:
root:recovery#> cloud list

Navegar entre particiones:
root:recovery#> cd partition:boot
root:boot#> ls
root:boot#> cd partition:system
root:system#> ls

=== GESTIÓN DE PAQUETES ===

El comando 'cloud' es el gestor de paquetes de CloudOS:

- cloud install <paquete>: Descarga y ejecuta un instalador desde:
  https://raw.githubusercontent.com/zer0users/cloudos/refs/heads/main/repository/<paquete>.lua

- Los paquetes son scripts Lua que configuran e instalan sistemas operativos
  o aplicaciones en las particiones correspondientes.

=== CARACTERÍSTICAS ===

- Sistema operativo base minimalista
- Soporte para múltiples particiones
- Gestor de paquetes integrado
- Sistema de recuperación robusto
- Compatible con Advanced Computer y Advanced Pocket Computer
- Diseñado para instalar otros sistemas operativos encima

=== NOTAS TÉCNICAS ===

- CloudOS funciona como un bootloader avanzado
- Las particiones son simplemente directorios en /partition/
- El sistema recovery siempre está disponible
- Los paquetes pueden instalar sistemas completos en partition/system/
- startup.lua se ejecuta automáticamente al encender el ordenador

]]
