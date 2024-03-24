local args = {...}

if table.getn(args) < 2 then
  error("Two arguments must be given: a vaild HTTP URL where the raw file is hosted, and an ending filename.", 1)
else
  print("Arguments are: " .. args[1] .. " and " .. args[2])
  local http_grabber = http.get(args[1]).readAll()
  if h then
    if not fs.exists(args[2]) then
      f = fs.open(args[2], "w")
      f.write(http_grabber)
      f.close()
      print("File " .. args[2] .. " was downloaded successfully.")
    else
      print("File already exists, should this update and replace it? [y/n]")
      local event, char = os.pullEvent("char")
      if char == "y" then
        f = fs.open(args[2], "w+")
        f.write(http_grabber)
        f.close()
        print("File overrided.")
      else 
        print("Cancelling action.")
      end
    end
  else
    error("HTTP URL not found.", 1)
  end
end

