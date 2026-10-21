-- Pandoc Lua filter to hide '# skip-docker-exec' lines from code blocks in compiled output
function CodeBlock(el)
  local lines = {}
  local text = el.text:gsub("\r\n", "\n"):gsub("\r", "\n")
  for line in (text .. "\n"):gmatch("([^\n]*)\n") do
    if not line:match("^[ \t]*#%s*skip%-docker%-exec") then
      table.insert(lines, line)
    end
  end
  el.text = table.concat(lines, "\n")
  return el
end
