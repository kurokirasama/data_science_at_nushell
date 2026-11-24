-- Pandoc Lua filter to rewrite relative image paths for chunkedhtml web books
local prefix = ""

function Meta(meta)
  if meta.image_prefix then
    prefix = pandoc.utils.stringify(meta.image_prefix)
  end
end

function Image(el)
  if prefix ~= ""
    and not el.src:match("^https?://")
    and not el.src:match("^/")
    and not el.src:match("^%.%./")
    and not el.src:match("^data:")
  then
    el.src = prefix .. el.src
  end
  return el
end

return {
  { Meta = Meta },
  { Image = Image }
}
