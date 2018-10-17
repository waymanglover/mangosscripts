-- General helper functions for Eluna coding

local function TableToString(table, indent)
    if not table then return "Nil" end
    if not indent then indent = 0 end
    local string = string.rep(" ", indent) .. "{\r\n"
    indent = indent + 2 
    for k, v in pairs(table) do
      string = string .. string.rep(" ", indent)
      if (type(k) == "number") then
        string = string .. "[" .. k .. "] = "
      elseif (type(k) == "string") then
        string = string  .. k ..  "= "  
      else 
        -- Assume guid / uint64
        string = string .. "[" .. GetGUIDLow(k) .. "] = "
      end
      if (type(v) == "number") then
        string = string .. v .. ",\r\n"
      elseif (type(v) == "string") then
        string = string .. "\"" .. v .. "\",\r\n"
      elseif (type(v) == "table") then
        string = string .. TableToString(v, indent + 2) .. ",\r\n"
      else
        string = string .. "\"" .. tostring(v) .. "\",\r\n"
      end
    end
    string = string .. string.rep(" ", indent-2) .. "}"
    return string
end

function DumpTable(table)
    PrintError(TableToString(table))
end