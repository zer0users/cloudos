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

-- Función para escribir recovery.lua
local function createRecoverySystem()
    local file = fs.open("partition/recovery/recovery.lua", "w")
    
    file.writeLine("-- CloudOS Recovery System v1.0")
    file.writeLine("")
    file.writeLine("local currentDir = \"partition:recovery\"")
    file.writeLine("local currentPartition = \"recovery\"")
    file.writeLine("")
    file.writeLine("local function parseCommand(input)")
    file.writeLine("    local parts = {}")
    file.writeLine("    for part in input:gmatch(\"%S+\") do")
    file.writeLine("        table.insert(parts, part)")
    file.writeLine("    end")
    file.writeLine("    return parts")
    file.writeLine("end")
    file.writeLine("")
    file.writeLine("local function getActualPath(path)")
    file.writeLine("    if path and path:match(\"^partition:\") then")
    file.writeLine("        local partName = path:match(\"^partition:(.+)\")")
    file.writeLine("        return \"partition/\" .. partName")
    file.writeLine("    else")
    file.writeLine("        if currentPartition == \"recovery\" then")
    file.writeLine("            return \"partition/recovery/\" .. (path or \"\")")
    file.writeLine("        elseif currentPartition == \"boot\" then")
    file.writeLine("            return \"partition/boot/\" .. (path or \"\")")
    file.writeLine("        else")
    file.writeLine("            return \"partition/\" .. currentPartition .. \"/\" .. (path or \"\")")
    file.writeLine("        end")
    file.writeLine("    end")
    file.writeLine("end")
    file.writeLine("")
    file.writeLine("local function listFiles(path)")
    file.writeLine("    local actualPath = path and getActualPath(path) or getActualPath(\"\")")
    file.writeLine("    if not fs.exists(actualPath) then")
    file.writeLine("        print(\"Directory not found: \" .. (path or currentDir))")
    file.writeLine("        return")
    file.writeLine("    end")
    file.writeLine("    local files = fs.list(actualPath)")
    file.writeLine("    for _, file in ipairs(files) do")
    file.writeLine("        if fs.isDir(fs.combine(actualPath, file)) then")
    file.writeLine("            print(file .. \"/\")")
    file.writeLine("        else")
    file.writeLine("            print(file)")
    file.writeLine("        end")
    file.writeLine("    end")
    file.writeLine("end")
    file.writeLine("")
    file.writeLine("local function changeDirectory(path)")
    file.writeLine("    if not path then")
    file.writeLine("        print(\"Usage: cd <directory/partition>\")")
    file.writeLine("        return")
    file.writeLine("    end")
    file.writeLine("    if path:match(\"^partition:\") then")
    file.writeLine("        local partName = path:match(\"^partition:(.+)\")")
    file.writeLine("        local partPath = \"partition/\" .. partName")
    file.writeLine("        if fs.exists(partPath) and fs.isDir(partPath) then")
    file.writeLine("            currentDir = path")
    file.writeLine("            currentPartition = partName")
    file.writeLine("            print(\"Changed to \" .. path)")
    file.writeLine("        else")
    file.writeLine("            print(\"Partition not found: \" .. partName)")
    file.writeLine("        end")
    file.writeLine("    else")
    file.writeLine("        local newPath = getActualPath(path)")
    file.writeLine("        if fs.exists(newPath) and fs.isDir(newPath) then")
    file.writeLine("            currentDir = currentDir .. \"/\" .. path")
    file.writeLine("        else")
    file.writeLine("            print(\"Directory not found: \" .. path)")
    file.writeLine("        end")
    file.writeLine("    end")
    file.writeLine("end")
    file.writeLine("")
    file.writeLine("local function mountPartition(partName)")
    file.writeLine("    if not partName then")
    file.writeLine("        print(\"Usage: mount <partition_name>\")")
    file.writeLine("        return")
    file.writeLine("    end")
    file.writeLine("    local partPath = \"partition/\" .. partName")
    file.writeLine("    if not fs.exists(partPath) then")
    file.writeLine("        fs.makeDir(partPath)")
    file.writeLine("        print(\"Partition '\" .. partName .. \"' mounted successfully\")")
    file.writeLine("    else")
    file.writeLine("        print(\"Partition '\" .. partName .. \"' already exists\")")
    file.writeLine("    end")
    file.writeLine("end")
    file.writeLine("")
    file.writeLine("local function unmountPartition(partName)")
    file.writeLine("    if not partName then")
    file.writeLine("        print(\"Usage: unmount <partition_name>\")")
    file.writeLine("        return")
    file.writeLine("    end")
    file.writeLine("    if partName == \"recovery\" or partName == \"boot\" then")
    file.writeLine("        print(\"Cannot unmount system partition: \" .. partName)")
    file.writeLine("        return")
    file.writeLine("    end")
    file.writeLine("    local partPath = \"partition/\" .. partName")
    file.writeLine("    if fs.exists(partPath) then")
    file.writeLine("        fs.delete(partPath)")
    file.writeLine("        print(\"Partition '\" .. partName .. \"' unmounted successfully\")")
    file.writeLine("    else")
    file.writeLine("        print(\"Partition not found: \" .. partName)")
    file.writeLine("    end")
    file.writeLine("end")
    file.writeLine("")
    file.writeLine("local function cloudPackageManager(action, packageName)")
    file.writeLine("    if action == \"install\" then")
    file.writeLine("        if not packageName then")
    file.writeLine("            print(\"Usage: cloud install <package_name>\")")
    file.writeLine("            return")
    file.writeLine("        end")
    file.writeLine("        print(\"Searching for \\\"\" .. packageName .. \"\\\"..\") ")
    file.writeLine("        local url = \"https://raw.githubusercontent.com/zer0users/cloudos/refs/heads/main/repository/\" .. packageName .. \".lua\"")
    file.writeLine("        ")
    file.writeLine("        -- Try to download the package")
    file.writeLine("        local response = http.get(url)")
    file.writeLine("        if response then")
    file.writeLine("            local content = response.readAll()")
    file.writeLine("            response.close()")
    file.writeLine("            ")
    file.writeLine("            -- Check if content is valid (not 404 page or empty)")
    file.writeLine("            if content and #content > 0 and not content:match(\"404: Not Found\") then")
    file.writeLine("                -- Calculate package size")
    file.writeLine("                local packageSize = #content")
    file.writeLine("                print(\"This Package is \" .. packageSize .. \" bytes.\")")
    file.writeLine("                ")
    file.writeLine("                write(\"Do you want to install it? (Y/N): \")")
    file.writeLine("                local userResponse = read()")
    file.writeLine("                ")
    file.writeLine("                if userResponse:lower() == \"y\" or userResponse:lower() == \"yes\" then")
    file.writeLine("                    print(\"Installing \" .. packageName .. \"..\")")
    file.writeLine("                    print(\"======================\")")
    file.writeLine("                    ")
    file.writeLine("                    -- Execute the downloaded Lua package")
    file.writeLine("                    local func, err = load(content)")
    file.writeLine("                    if func then")
    file.writeLine("                        local success, result = pcall(func)")
    file.writeLine("                        if not success then")
    file.writeLine("                            print(\"Error running package: \" .. tostring(result))")
    file.writeLine("                        end")
    file.writeLine("                    else")
    file.writeLine("                        print(\"Error loading package: \" .. tostring(err))")
    file.writeLine("                    end")
    file.writeLine("                    ")
    file.writeLine("                    print(\"======================\")")
    file.writeLine("                    print(\"Done! Thank Jehovah!\")")
    file.writeLine("                else")
    file.writeLine("                    print(\"Installation cancelled.\")")
    file.writeLine("                end")
    file.writeLine("            else")
    file.writeLine("                print(\"Package not found: \" .. packageName)")
    file.writeLine("            end")
    file.writeLine("        else")
    file.writeLine("            print(\"Package not found: \" .. packageName)")
    file.writeLine("        end")
    file.writeLine("    elseif action == \"list\" then")
    file.writeLine("        print(\"Fetching package list from repository...\")")
    file.writeLine("        local listUrl = \"https://raw.githubusercontent.com/zer0users/cloudos/refs/heads/main/repository/package-list.txt\"")
    file.writeLine("        local response = http.get(listUrl)")
    file.writeLine("        if response then")
    file.writeLine("            local content = response.readAll()")
    file.writeLine("            response.close()")
    file.writeLine("            print(\"Available packages:\")")
    file.writeLine("            for line in content:gmatch(\"[^\\n]+\") do")
    file.writeLine("                if line:match(\"%S\") then")
    file.writeLine("                    print(\"- \" .. line)")
    file.writeLine("                end")
    file.writeLine("            end")
    file.writeLine("            print(\"Use 'cloud install <package>' to install\")")
    file.writeLine("        else")
    file.writeLine("            print(\"Could not fetch package list. Showing cached list:\")")
    file.writeLine("            print(\"Available packages:\")")
    file.writeLine("            print(\"- mi-os\")")
    file.writeLine("            print(\"- terminal-os\")")
    file.writeLine("            print(\"- micro-kernel\")")
    file.writeLine("            print(\"Use 'cloud install <package>' to install\")")
    file.writeLine("        end")
    file.writeLine("    else")
    file.writeLine("        print(\"CloudOS Package Manager\")")
    file.writeLine("        print(\"Usage:\")")
    file.writeLine("        print(\"  cloud install <package> - Install a package\")")
    file.writeLine("        print(\"  cloud list              - List available packages\")")
    file.writeLine("    end")
    file.writeLine("end")
    file.writeLine("")
    file.writeLine("-- Main recovery loop")
    file.writeLine("print(\"CloudOS Recovery 1.0\")")
    file.writeLine("while true do")
    file.writeLine("    write(\"root:\" .. currentPartition .. \"#> \")")
    file.writeLine("    local input = read()")
    file.writeLine("    if input == \"\" then")
    file.writeLine("        -- Skip empty lines")
    file.writeLine("    elseif input == \"exit\" or input == \"quit\" then")
    file.writeLine("        print(\"Rebooting to boot partition...\")")
    file.writeLine("        sleep(1)")
    file.writeLine("        if fs.exists(\"partition/system\") and #fs.list(\"partition/system\") > 0 then")
    file.writeLine("            print(\"System partition found, attempting to boot...\")")
    file.writeLine("        else")
    file.writeLine("            print(\"No system partition found, staying in recovery mode.\")")
    file.writeLine("        end")
    file.writeLine("        break")
    file.writeLine("    else")
    file.writeLine("        local parts = parseCommand(input)")
    file.writeLine("        local command = parts[1]")
    file.writeLine("        if command == \"ls\" then")
    file.writeLine("            listFiles(parts[2])")
    file.writeLine("        elseif command == \"cd\" then")
    file.writeLine("            changeDirectory(parts[2])")
    file.writeLine("        elseif command == \"mount\" then")
    file.writeLine("            mountPartition(parts[2])")
    file.writeLine("        elseif command == \"unmount\" then")
    file.writeLine("            unmountPartition(parts[2])")
    file.writeLine("        elseif command == \"cloud\" then")
    file.writeLine("            cloudPackageManager(parts[2], parts[3])")
    file.writeLine("        elseif command == \"help\" then")
    file.writeLine("            print(\"CloudOS Recovery Commands:\")")
    file.writeLine("            print(\"  ls [path]                 - List files and directories\")")
    file.writeLine("            print(\"  cd <path/partition>       - Change directory\")")
    file.writeLine("            print(\"  mount <partition>         - Create/mount partition\")")
    file.writeLine("            print(\"  unmount <partition>       - Remove/unmount partition\")")
    file.writeLine("            print(\"  cloud install <package>   - Install package\")")
    file.writeLine("            print(\"  cloud list               - List available packages\")")
    file.writeLine("            print(\"  help                     - Show this help\")")
    file.writeLine("            print(\"  exit                     - Exit recovery mode\")")
    file.writeLine("        else")
    file.writeLine("            print(\"Unknown command: \" .. command)")
    file.writeLine("            print(\"Type 'help' for available commands\")")
    file.writeLine("        end")
    file.writeLine("    end")
    file.writeLine("end")
    
    file.close()
end

-- Función para escribir boot.lua
local function createBootSystem()
    local file = fs.open("partition/boot/boot.lua", "w")
    
    file.writeLine("-- CloudOS Boot System")
    file.writeLine("print(\"Welcome to CloudOS!\")")
    file.writeLine("print(\"BOOTLOADER_REASON=\\\"AUTOMATIC_REBOOT\\\"\")")
    file.writeLine("sleep(0.1)")
    file.writeLine("term.clear()")
    file.writeLine("term.setCursorPos(1, 1)")
    file.writeLine("")
    file.writeLine("if fs.exists(\"partition/system\") and #fs.list(\"partition/system\") > 0 then")
    file.writeLine("    print(\"System partition found. Attempting to boot system...\")")
    file.writeLine("    if fs.exists(\"partition/system/init.lua\") then")
    file.writeLine("        print(\"Loading system from partition/system/init.lua\")")
    file.writeLine("        shell.run(\"partition/system/init.lua\")")
    file.writeLine("    elseif fs.exists(\"partition/system/startup.lua\") then")
    file.writeLine("        print(\"Loading system from partition/system/startup.lua\")")
    file.writeLine("        shell.run(\"partition/system/startup.lua\")")
    file.writeLine("    else")
    file.writeLine("        print(\"No valid system startup file found in system partition.\")")
    file.writeLine("        print(\"Falling back to recovery mode...\")")
    file.writeLine("        shell.run(\"partition/recovery/recovery.lua\")")
    file.writeLine("    end")
    file.writeLine("else")
    file.writeLine("    print(\"No system partition found or system partition is empty.\")")
    file.writeLine("    print(\"Booting into recovery mode...\")")
    file.writeLine("    sleep(1)")
    file.writeLine("    shell.run(\"partition/recovery/recovery.lua\")")
    file.writeLine("end")
    
    file.close()
end

-- Función para escribir startup.lua
local function createMainStartup()
    local file = fs.open("startup.lua", "w")
    
    file.writeLine("-- CloudOS Main Startup")
    file.writeLine("if not fs.exists(\"partition\") then")
    file.writeLine("    print(\"CloudOS partition structure not found!\")")
    file.writeLine("    print(\"Please reinstall CloudOS.\")")
    file.writeLine("    return")
    file.writeLine("end")
    file.writeLine("")
    file.writeLine("if fs.exists(\"partition/boot/boot.lua\") then")
    file.writeLine("    shell.run(\"partition/boot/boot.lua\")")
    file.writeLine("else")
    file.writeLine("    print(\"Boot system not found!\")")
    file.writeLine("    print(\"CloudOS installation may be corrupted.\")")
    file.writeLine("    if fs.exists(\"partition/recovery/recovery.lua\") then")
    file.writeLine("        print(\"Attempting to load recovery system...\")")
    file.writeLine("        shell.run(\"partition/recovery/recovery.lua\")")
    file.writeLine("    else")
    file.writeLine("        print(\"Recovery system also not found. Please reinstall CloudOS.\")")
    file.writeLine("    end")
    file.writeLine("end")
    
    file.close()
end

-- Ejecutar las funciones de creación
createRecoverySystem()
createBootSystem()
createMainStartup()

print("Done!")
print("Rebooting..")
sleep(2)

-- Ejecutar el startup
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
