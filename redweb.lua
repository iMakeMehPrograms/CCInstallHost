local args = {...}

local modem
local connection_id
local content

local function openHost(name)
  modem = peripheral.find("modem") or error("No modem found.", 1)
  
  rednet.open(peripheral.getName(modem))
  rednet.host("redweb", name)
  if not rednet.isOpen() then
    error("Rednet could not open!", 1)
  end
end

local function closeHost()
  if not rednet.isOpen() then
    error("Rednet was not open in the first place!", 1)
  end
  
  rednet.unhost("redweb")
  rednet.close(modem)
end

local function openClient()
  modem = peripheral.find("modem") or error("No modem found.", 1)
  
  rednet.open(peripheral.getName(modem))
  if not rednet.isOpen() then
    error("Rednet could not open!", 1)
  end
end

local function closeClient()
  if not rednet.isOpen() then
    error("Rednet was not open in the first place!", 1)
  end
  
  rednet.close(modem)
end

local function listServers()
  return rednet.lookup("redweb")
end

local function findServer(name)
  return rednet.lookup("redweb", name)
end

local function getServerContent(server_name) 
  connection_id = findServer(server_name)
  if not connection_id then
    error("Server not found.", 0)
    return nil
  end
  rednet.send(connection_id, "CONTENT", "redweb")
  local id, message = rednet.recieve("redweb", 30)
  if not id then
    error("Server didn't reply.", 0)
    return nil
  end
  return message
end

local function processRequest(request)
  if request == "CONTENT" then
    return content
  end
end

local function waitForRequest(time)
  local id, message
  if time then
    id, message = rednet.recieve("redweb", time)
  else 
    id, message = rednet.recieve("redweb")
  end
  if not id then
      return false
  end
  local reply = processRequest(message)
  rednet.send(id, reply, "redweb")
  return true
end

---------------------------------------------- Border from library functions and nonlibrary runtime ----------------------------------------------
  
if table.getn(args) < 1 then
    error("You must define if the redweb run is a client or a host, i.e: CLIENT | HOST", 1)
end

if args[1] == "HOST" then
  if table.getn(args) < 3 then
    error("You must define two extra arguments when hosting: the file to host as CONTENT and the server name.", 1)
  end
  
  if not fs.exists(args[2]) then
    error("The CONTENT file doesn't exist!", 1)
  end

  content = fs.open(args[2], "r").readAll()
  openHost(args[3])
    
  while true do
    waitForRequest()
  end
    
  closeHost()
else 
  openClient()
  local looping = true
  local command = ""
  local tokens
  local local_content
  while looping do
    command = stdin:read()
    tokens = string.gmatch(command, "%s")
    if tokens[1] == "LIST" then
      print("Available Servers: " .. #listServers())
    elseif tokens[1] == "CONNECT" then
      if table.getn(tokens) < 2 then
        print("Command needs a server argument.")
      else
        local_content = getServerContent(tokens[2])
        print(local_content)
      end
    elseif tokens[1] == "DOWNLOAD" then
      if table.getn(tokens) < 3 then
        print("Command needs server and filename arguments.")
      else
        local_content = getServerContent(tokens[2])
        if fs.exists(tokens[3]) then
          print("File already exists.")
        else
          fs.open(tokens[3], "w")
          fs.write(local_content)
          fs.close()
        end
      end
    elseif tokens[1] == "QUIT" then
      looping = false
    end 
  end
end





      


      

