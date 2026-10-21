function CodeBlock(el)
  local new_lines = {}
  for line in el.text:gmatch("([^\n]*)\n?") do
    if not line:match("^%s*#%s*skip%-docker%-exec") then
      table.insert(new_lines, line)
    end
  end
  -- remove any trailing empty string from split
  if #new_lines > 0 and new_lines[#new_lines] == "" then
    table.remove(new_lines)
  end
  el.text = table.concat(new_lines, "\n")
  return el
end
