local Base = require('render-markdown.render.base')
local colors = require('render-markdown.core.colors')

---@class render.md.render.inline.Code: render.md.Render
---@field private config render.md.code.Config
local Render = setmetatable({}, Base)
Render.__index = Render

---@protected
---@return boolean
function Render:setup()
    self.config = self.context.config.code
    if not self.config.enabled then
        return false
    end
    if not self.config.inline then
        return false
    end
    return true
end

---@protected
function Render:run()
    local highlight = self.config.highlight_inline
    self.marks:over(self.config, 'code_background', self.node, {
        priority = self.config.priority,
        hl_group = highlight,
    })
    -- Skip adding inline padding glyphs.
end

---@private
---@param highlight string
---@param left boolean
function Render:padding(highlight, left)
    -- No-op: glyph rendering removed.
end

return Render
