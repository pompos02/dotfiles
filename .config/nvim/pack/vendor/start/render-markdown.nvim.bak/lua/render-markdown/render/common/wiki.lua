local Base = require('render-markdown.render.base')

---@class render.md.render.common.Wiki: render.md.Render
---@field private config render.md.link.Config
local Render = setmetatable({}, Base)
Render.__index = Render

---@protected
---@return boolean
function Render:setup()
    self.config = self.context.config.link
    if not self.config.enabled then
        return false
    end
    return true
end

---@protected
function Render:run()
    -- Avoid rendering wiki link glyphs.
end

---@private
---@param col integer
---@param length integer
function Render:hide(col, length)
    self.marks:add(self.config, true, self.node.start_row, col, {
        end_col = col + length,
        conceal = '',
    })
end

return Render
