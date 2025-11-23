-- Run Python file or selection in new window below with <leader>rr
vim.keymap.set("n", "<leader>rr", function()
    vim.cmd("15split") -- Creates a 15-line high split
    vim.cmd("terminal python " .. vim.fn.expand("%"))
end, { buffer = true, desc = "Run Python file in new window below" })

vim.keymap.set("v", "<leader>rr", function()
    -- Use modern API to get visual selection
    local lines = vim.fn.getregion(vim.fn.getpos("."), vim.fn.getpos("v"))

    if not lines or #lines == 0 then
        vim.notify("No code selected", vim.log.levels.WARN)
        return
    end

    local code = table.concat(lines, "\n")

    -- Create terminal split
    vim.cmd("15split")

    -- Use jobstart to send code via stdin - handles long/multi-line code better
    local job_id = vim.fn.jobstart({ "python3" }, {
        on_exit = function(_, exit_code)
            if exit_code ~= 0 then
                print("Python execution failed with exit code: " .. exit_code)
            end
        end,
    })

    -- Send code via stdin and close
    vim.fn.chansend(job_id, code .. "\n")
    vim.fn.chanclose(job_id, "stdin")
end, { buffer = true, desc = "Run Python selection via stdin" })
