local M = {}

local document_highlight_method = vim.lsp.protocol.Methods.textDocument_documentHighlight
local attach_group = vim.api.nvim_create_augroup("CustomLspDocumentHighlight", { clear = true })

local function ensure_reference_highlights()
    local fallback_links = {
        LspReferenceText = "Visual",
        LspReferenceRead = "Visual",
        LspReferenceWrite = "Visual",
    }

    for name, link in pairs(fallback_links) do
        local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = name, link = true })
        if not ok or not hl or (hl.link == nil and not hl.bg and not hl.ctermbg) then
            vim.api.nvim_set_hl(0, name, { link = link })
        end
    end
end

local function buffer_autocmds(client, bufnr)
    if not client or not client.supports_method(document_highlight_method) then
        return
    end

    local group = vim.api.nvim_create_augroup("LspDocumentHighlight" .. bufnr, { clear = true })

    vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
        group = group,
        buffer = bufnr,
        callback = vim.lsp.buf.document_highlight,
        desc = "Highlight symbol under cursor",
    })

    vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI", "BufLeave" }, {
        group = group,
        buffer = bufnr,
        callback = vim.lsp.buf.clear_references,
        desc = "Clear highlighted symbol references",
    })
end

M.setup = function()
    ensure_reference_highlights()

    vim.api.nvim_create_autocmd("LspAttach", {
        group = attach_group,
        callback = function(args)
            local client = vim.lsp.get_client_by_id(args.data.client_id)
            buffer_autocmds(client, args.buf)
        end,
        desc = "Enable document highlights when LSP attaches",
    })

    -- Handle any buffers that already have an attached client (e.g. after a reload)
    for _, client in pairs(vim.lsp.get_clients()) do
        for bufnr in pairs(client.attached_buffers or {}) do
            buffer_autocmds(client, bufnr)
        end
    end
end

return M
