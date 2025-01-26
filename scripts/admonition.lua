

local admonitions = {
  warning   = {pandoc.Str("Warning981267")},
  note      = {pandoc.Str("Note981267")},
  tip       = {pandoc.Str("Tip981267")},
  important = {pandoc.Str("Important981267")},
  caution   = {pandoc.Str("Caution981267")},
  sidebar   = {pandoc.Str("Sidebar981267")},
  informalexample   = {pandoc.Str("Informalexample981267")},
  }

function Div(el)
  local admonition_text = admonitions[el.classes[1]]
  if admonition_text then
    table.insert(el.content, 1,
        pandoc.Para{ pandoc.Strong(admonition_text)})
  end
  return el
end
