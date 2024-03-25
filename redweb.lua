local modem
local connection_id
local content

local function openHost(name)
  modem = peripheral.find("modem") or error("No modem found.", 1)
  
  rednet.open(modem)
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
  
  rednet.open(modem)
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

local function waitForRequest(time)
  local id, message
  if time then
    id, message = rednet.recieve("redweb", time)
  else 
    id, message = rednet.recieve("redweb")
  end
  local reply = processRequest(message)
  rednet.send(id, reply, "redweb")
end








