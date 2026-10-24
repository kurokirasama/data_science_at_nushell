-- Pandoc Lua filter to hide '# skip-docker-exec' lines and annotations from code blocks in compiled output
function CodeBlock(el)
  local lines = {}
  local text = el.text:gsub("\r\n", "\n"):gsub("\r", "\n")
  for line in (text .. "\n"):gmatch("([^\n]*)\n") do
    if not line:match("#%s*skip%-docker%-exec") then
      table.insert(lines, line)
    else
      -- If the line has code before '# skip-docker-exec', keep the code part
      local code_before = line:match("^(.-)%s*#%s*skip%-docker%-exec.*$")
      if code_before and code_before:match("%S") then
        table.insert(lines, code_before)
      end
    end
  end

  -- Trim any leading empty lines resulting from stripped headers
  while #lines > 0 and lines[1]:match("^%s*$") do
    table.remove(lines, 1)
  end
  -- Trim any trailing empty lines
  while #lines > 0 and lines[#lines]:match("^%s*$") do
    table.remove(lines, #lines)
  end

  el.text = table.concat(lines, "\n")
  return el
end
