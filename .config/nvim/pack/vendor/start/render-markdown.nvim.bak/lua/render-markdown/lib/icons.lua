---@class render.md.icon.Provider
---@field name? string
---@field get fun(filetype: string): string?, string?

---@class render.md.icon.Providers
local Providers = {}

---@return render.md.icon.Provider?
function Providers.MiniIcons()
    local has, icons = pcall(require, 'mini.icons')
    if not has or not icons then
        return nil
    end
    local getter = icons.get
    if not getter then
        return nil
    end
    -- selene: allow(global_usage)
    -- additional check recommended by author
    if not _G.MiniIcons then
        return nil
    end
    ---@type render.md.icon.Provider
    return {
        name = 'mini.icons',
        get = function(filetype)
            return getter('filetype', filetype)
        end,
    }
end

---@return render.md.icon.Provider?
function Providers.DevIcons()
    local has, icons = pcall(require, 'nvim-web-devicons')
    if not has or not icons then
        return nil
    end
    local getter = icons.get_icon_by_filetype
    if not getter then
        return nil
    end
    ---@type render.md.icon.Provider
    return {
        name = 'nvim-web-devicons',
        get = function(filetype)
            return getter(filetype)
        end,
    }
end

---@return render.md.icon.Provider
function Providers.None()
    ---@type render.md.icon.Provider
    return {
        name = nil,
        get = function()
            return nil, nil
        end,
    }
end

---@class render.md.Icons
---@field private provider? render.md.icon.Provider
local M = {}

---@return string?
function M.name()
    return M.resolve().name
end

---@param name string
---@return string?, string?
function M.get(name)
    -- handle input possibly being an extension rather than a language name
    local filetype = vim.filetype.match({ filename = 'a.' .. name }) or name
    return M.resolve().get(filetype)
end

---@private
---@return render.md.icon.Provider
function M.resolve()
    -- Always resolve to a no-op provider to avoid rendering icons.
    M.provider = M.provider or Providers.None()
    return M.provider
end

return M
