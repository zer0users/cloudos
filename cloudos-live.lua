-- Este es el instalador principal que se ejecuta con: install-cloudos
local function createStartup()
    print("Preparing all for you..")
    
    -- Crear el archivo startup.lua
    local startup = [[
-- CloudOS Startup
print("Welcome to CloudOS!")
sleep(0.1)

-- Crear estructura de particiones si no existe
if not fs.exists("partition") then
    fs.makeDir("partition")
    fs.makeDir("partition/recovery")
    fs.makeDir("partition/boot")
    
    -- Crear recovery.lua
    local recoveryFile = fs.open("partition/recovery/recovery.lua", "w")
    recoveryFile.write([[
-- CloudOS Recovery 1.0
local currentPath = "partition:recovery"

-- Variables globales del sistema
local packages = {}
local bootloader_reason = "AUTOMATIC_REBOOT"

-- Funciones del sistema
local function downloadPackage(packageName)
    local url = "https://raw.githubusercontent.com/zer0users/cloudos/refs/heads/main/repository/" .. packageName .. ".lua"
    local response = http.get(url)
    if response then
        local content = response.readAll()
        response.close()
        return content
    end
    return nil
end

local function executePackage(content)
    local func, err = load(content, "package", "t", _ENV)
    if func then
        return pcall(func)
    else
        print("Error loading package: " .. err)
        return false
    end
end

local function listDirectory(path)
    if path:match("^partition:") then
        local partitionName = path:match("^partition:(.+)")
        if fs.exists("partition/" .. partitionName) then
            return fs.list("partition/" .. partitionName)
        else
            print("Partition not found: " .. partitionName)
            return {}
        end
    else
        if fs.exists(path) then
            return fs.list(path)
        else
            print("Directory not found: " .. path)
            return {}
        end
    end
end

local function changeDirectory(path)
    if path:match("^partition:") then
        local partitionName = path:match("^partition:(.+)")
        if fs.exists("partition/" .. partitionName) then
            currentPath = path
            return true
        else
            print("Partition not found: " .. partitionName)
            return false
        end
    else
        if fs.exists(path) then
            currentPath = path
            return true
        else
            print("Directory not found: " .. path)
            return false
        end
    end
end

-- Mostrar información de inicio
term.clear()
term.setCursorPos(1, 1)
print("Welcome to CloudOS!")
print("BOOTLOADER_REASON=\"" .. bootloader_reason .. "\"")
sleep(0.1) -- Mostrar por menos de 0.1 segundos
term.clear()
term.setCursorPos(1, 1)

print("CloudOS Recovery 1.0")

-- Loop principal del sistema
while true do
    write("root:" .. (currentPath:match("partition:(.+)") or currentPath) .. "#> ")
    local input = read()
    local command = {}
    
    for word in input:gmatch("%S+") do
        table.insert(command, word)
    end
    
    if #command == 0 then
        -- Comando vacío, continuar
    elseif command[1] == "ls" then
        local path = command[2] or currentPath
        local files = listDirectory(path)
        for _, file in ipairs(files) do
            print(file)
        end
        
    elseif command[1] == "cd" then
        if command[2] then
            if changeDirectory(command[2]) then
                -- Cambio exitoso
            end
        else
            print("Usage: cd <directory/partition>")
        end
        
    elseif command[1] == "mount" then
        if command[2] then
            local partitionName = command[2]
            fs.makeDir("partition/" .. partitionName)
            print("Partition '" .. partitionName .. "' mounted successfully")
        else
            print("Usage: mount <partition_name>")
        end
        
    elseif command[1] == "unmount" then
        if command[2] then
            local partitionName = command[2]
            if fs.exists("partition/" .. partitionName) then
                fs.delete("partition/" .. partitionName)
                print("Partition '" .. partitionName .. "' unmounted successfully")
                if currentPath == "partition:" .. partitionName then
                    currentPath = "partition:recovery"
                end
            else
                print("Partition not found: " .. partitionName)
            end
        else
            print("Usage: unmount <partition_name>")
        end
        
    elseif command[1] == "cloud" then
        if command[2] == "install" then
            if command[3] then
                local packageName = command[3]
                print("Searching for \"" .. packageName .. "\"..")
                
                local packageContent = downloadPackage(packageName)
                if packageContent then
                    local size = #packageContent
                    print("This Package is " .. size .. " bytes.")
                    write("Do you want to install it? (Y/N): ")
                    local confirm = read():lower()
                    
                    if confirm == "y" or confirm == "yes" then
                        print("Installing " .. packageName .. "..")
                        print("======================")
                        
                        local success, err = executePackage(packageContent)
                        
                        print("======================")
                        if success then
                            print("Done! Thank Jehovah!")
                        else
                            print("Installation failed: " .. (err or "Unknown error"))
                        end
                    else
                        print("Installation cancelled.")
                    end
                else
                    print("Package not found: " .. packageName)
                end
            else
                print("Usage: cloud install <package_name>")
            end
            
        elseif command[2] == "list" then
            print("Available packages:")
            print("- mi-os")
            print("- basic-shell")
            print("- file-manager")
            print("(This would normally fetch from repository)")
            
        else
            print("CloudOS Package Manager")
            print("Usage:")
            print("  cloud install <package>  - Install a package")
            print("  cloud list              - List available packages")
        end
        
    elseif command[1] == "help" then
        print("CloudOS Recovery Commands:")
        print("  ls [path]               - List files and directories")
        print("  cd <path>              - Change directory")
        print("  mount <partition>      - Create/mount a partition")
        print("  unmount <partition>    - Delete/unmount a partition")
        print("  cloud install <pkg>    - Install a package")
        print("  cloud list             - List available packages")
        print("  help                   - Show this help")
        print("  exit                   - Exit CloudOS")
        
    elseif command[1] == "exit" then
        print("Goodbye!")
        break
        
    else
        print("Unknown command: " .. command[1])
        print("Type 'help' for available commands")
    end
end
]])
    recoveryFile.close()
    
    -- Crear boot.lua
    local bootFile = fs.open("partition/boot/boot.lua", "w")
    bootFile.write([[
-- CloudOS Boot Loader
-- Verifica si existe la partición system, si no, ejecuta recovery

if fs.exists("partition/system") and #fs.list("partition/system") > 0 then
    -- La partición system existe y no está vacía
    print("Booting from system partition...")
    if fs.exists("partition/system/boot.lua") then
        shell.run("partition/system/boot.lua")
    elseif fs.exists("partition/system/startup.lua") then
        shell.run("partition/system/startup.lua")
    else
        print("No bootable system found, falling back to recovery...")
        shell.run("partition/recovery/recovery.lua")
    end
else
    -- No hay sistema instalado, ejecutar recovery
    shell.run("partition/recovery/recovery.lua")
end
]])
    bootFile.close()
end

-- Ejecutar boot.lua
if fs.exists("partition/boot/boot.lua") then
    shell.run("partition/boot/boot.lua")
else
    print("Error: Boot partition not found!")
end
]]
    
    local file = fs.open("startup.lua", "w")
    file.write(startup)
    file.close()
    
    print("Done! Rebooting..")
    sleep(1)
    os.reboot()
end
