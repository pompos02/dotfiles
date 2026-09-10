local function dap(method)
    return function()
        require("dap")[method]()
    end
end

return {
    "igorlfs/nvim-dap-view",
    dependencies = {
        "mfussenegger/nvim-dap",
    },
    cmd = {
        "DapClearBreakpoints",
        "DapContinue",
        "DapDisconnect",
        "DapEval",
        "DapNew",
        "DapPause",
        "DapRestartFrame",
        "DapSetLogLevel",
        "DapShowLog",
        "DapStepInto",
        "DapStepOut",
        "DapStepOver",
        "DapTerminate",
        "DapToggleBreakpoint",
        "DapToggleRepl",
        "DapViewClose",
        "DapViewHover",
        "DapViewOpen",
        "DapViewToggle",
    },
    keys = {
        { "<F5>", dap("continue"), desc = "Debug: Start/continue" },
        { "<leader>db", dap("toggle_breakpoint"), desc = "Debug: Toggle breakpoint" },
        {
            "<leader>DB",
            function()
                require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: "))
            end,
            desc = "Debug: Conditional breakpoint",
        },
        { "<leader>Dl", dap("run_last"), desc = "Debug: Run last" },
        { "<leader>dt", "<cmd>DapViewToggle<cr>", desc = "Debug: Toggle view" },
    },
    config = function()
        local dap = require("dap")
        local dapview = require("dap-view")

        local session_keymaps = {
            { "n", "<leader>n", dap.step_over, desc = "Debug: Step over" },
            { "n", "<leader>s", dap.step_into, desc = "Debug: Step into" },
            { "n", "<leader>o", dap.step_out, desc = "Debug: Step out" },
            { "n", "sc", dap.run_to_cursor, desc = "Debug: Run to cursor" },
            { "n", "zd", dap.focus_frame, desc = "Debug: Focus current frame" },
            { "n", "<leader>Dr", dap.repl.toggle, desc = "Debug: Toggle REPL" },
            { "n", "<leader>Dt", dap.terminate, desc = "Debug: Terminate" },
            { { "n", "v" }, "<leader>De", dapview.hover, desc = "Debug: Evaluate expression" },
        }

        local function enable_session_keymaps()
            vim.g.dap_session_active = true
            for _, keymap in ipairs(session_keymaps) do
                vim.keymap.set(keymap[1], keymap[2], keymap[3], { desc = keymap.desc })
            end
            vim.cmd.redrawstatus()
        end

        local function disable_session_keymaps()
            vim.g.dap_session_active = false
            for _, keymap in ipairs(session_keymaps) do
                pcall(vim.keymap.del, keymap[1], keymap[2])
            end
            vim.cmd.redrawstatus()
        end

        dap.adapters.gdb = {
            type = "executable",
            command = "gdb",
            args = { "--interpreter=dap", "--eval-command", "set print pretty on" },
        }

        local function executable()
            return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
        end

        local configurations = {
            {
                name = "Launch executable",
                type = "gdb",
                request = "launch",
                program = executable,
                cwd = "${workspaceFolder}",
                stopAtBeginningOfMainSubprogram = false,
            },
            {
                name = "Launch executable with arguments",
                type = "gdb",
                request = "launch",
                program = executable,
                args = function()
                    return require("dap.utils").splitstr(vim.fn.input("Arguments: "))
                end,
                cwd = "${workspaceFolder}",
                stopAtBeginningOfMainSubprogram = false,
            },
            {
                name = "Attach to process",
                type = "gdb",
                request = "attach",
                program = executable,
                pid = function()
                    local name = vim.fn.input("Executable name (filter): ")
                    return require("dap.utils").pick_process({ filter = name })
                end,
                cwd = "${workspaceFolder}",
            },
            {
                name = "Attach to gdbserver :1234",
                type = "gdb",
                request = "attach",
                target = "localhost:1234",
                program = executable,
                cwd = "${workspaceFolder}",
            },
        }

        dap.configurations.c = configurations
        dap.configurations.cpp = configurations
        dap.configurations.rust = configurations

        dapview.setup({ auto_toggle = true })

        dap.listeners.after.event_initialized.dap_keymaps = enable_session_keymaps
        dap.listeners.after.event_terminated.dap_keymaps = disable_session_keymaps
        dap.listeners.after.event_exited.dap_keymaps = disable_session_keymaps
    end,
}
