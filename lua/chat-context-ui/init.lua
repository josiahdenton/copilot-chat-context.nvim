local M = {}

local ui = require("chat-context-ui.ui.menu")
local assistant = require("chat-context-ui.assistant")
local contexts = require("chat-context-ui.contexts")
local menu = require("chat-context-ui.menu")
local store = require("chat-context-ui.store")

local notify = require("chat-context-ui.external.notify")
local chat = require("chat-context-ui.external.chat")
local config = require("chat-context-ui.config")

--- setup should be called before require("chat-context-ui").open()
--- @param opts ?ccc.PluginOpts
M.setup = function(opts)
    -- load dependencies
    notify.setup()
    chat.setup()
    config.setup(opts or {})
    store.setup(opts or {})
end

--- @param state ccc.State
local setup_autocmds = function(state)
    vim.api.nvim_create_autocmd({ "TabEnter" }, {
        group = vim.api.nvim_create_augroup("chat-context-ui.tab.move", { clear = true }),
        callback = function()
            ui.move(state)
        end,
    })
end

--- opens the main UI context management window as a floating window on the RHS
M.open = function()
    local state = store.state()
    if vim.api.nvim_buf_is_valid(state.menu.bufnr) then
        return -- noop when trying to double open
    end

    setup_autocmds(state)
    -- if store loaded, let's just ui.open again + re-register actions + contexts...
    if state.loaded then
        store.remap()
        ui.open(state)
        return
    end

    assistant.attach(state)
    contexts.attach(state)
    menu.attach(state)
    store.load()
    ui.open(state)
end

return M
