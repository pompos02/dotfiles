local Base = require('render-markdown.render.base')
local Wiki = require('render-markdown.render.common.wiki')

---@class render.md.render.inline.Shortcut: render.md.Render
---@field private config render.md.link.Config
local Render = setmetatable({}, Base)
Render.__index = Render

---@protected
---@return boolean
function Render:setup()
    local callout = self.context.config.resolved:callout(self.node)
    if callout then
        self.context.callout:set(self.node, callout)
        return false
    end
    local checkbox = self.context.config.resolved:checkbox(self.node)
    if checkbox then
        if self.node:after() == ' ' then
            self.context.checkbox:set(self.node, checkbox)
        end
        return false
    end
    self.config = self.context.config.link
    if not self.config.enabled then
        return false
    end
    return true
end

---@protected
function Render:run()
    local _, line = self.node:line('first', 0)
    if line and line:find('[' .. self.node.text .. ']', 1, true) then
        Wiki:execute(self.context, self.marks, self.node)
        return
    end
    local _, _, text = self.node.text:find('^%[%^(.+)%]$')
    if text then
        self:footnote(text)
        return
    end
end

---@private
---@param text string
function Render:footnote(text)
    -- Do not render footnote icons.
end

return Render
