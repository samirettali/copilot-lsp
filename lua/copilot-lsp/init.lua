local config = require("copilot-lsp.config")

---@class copilotlsp
---@field defaults copilotlsp.config
---@field config copilotlsp.config
---@field setup fun(opts?: copilotlsp.config): nil
local M = {}

M.defaults = config.defaults
M.config = config.config

---@param opts? copilotlsp.config configuration to merge with defaults
function M.setup(opts)
    config.setup(opts)
    M.config = config.config

    vim.lsp.config("copilot_ls", {
        on_init = function(client)
            vim.api.nvim_create_autocmd("BufEnter", {
                callback = function()
                    local td_params = vim.lsp.util.make_text_document_params()
                    client:notify("textDocument/didFocus", {
                        textDocument = {
                            uri = td_params.uri,
                        },
                    })
                end,
                group = vim.api.nvim_create_augroup("copilot_ls", { clear = true }),
                desc = "Trigger when entering a buffer",
            })

            if M.config.nes.auto_trigger then
                local debounced_request =
                    require("copilot-lsp.util").debounce(require("copilot-lsp.nes").request_nes, M.config.nes.debounce)
                vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
                    group = vim.api.nvim_create_augroup("copilot-lsp", { clear = true }),
                    callback = function()
                        debounced_request(client)
                    end,
                    desc = "Debounced request for Copilot NES",
                })
            end

            if M.config.keymaps.request_nes then
                vim.keymap.set("n", M.config.keymaps.request_nes, function()
                    require("copilot-lsp.nes").request_nes(client)
                end, { desc = "Request Copilot NES" })
            end

            if M.config.keymaps.accept_nes then
                local is_tab = M.config.keymaps.accept_nes:lower() == "<tab>"
                vim.keymap.set("n", M.config.keymaps.accept_nes, function()
                    local bufnr = vim.api.nvim_get_current_buf()
                    local state = vim.b[bufnr].nes_state
                    if state then
                        local _ = require("copilot-lsp.nes").walk_cursor_start_edit()
                            or (
                                require("copilot-lsp.nes").apply_pending_nes()
                                and require("copilot-lsp.nes").walk_cursor_end_edit()
                            )
                        return nil
                    else
                        -- Only fallback to <C-i> if the mapped key is <tab>
                        -- This resolves terminal's inability to distinguish between TAB and <C-i>
                        if is_tab then
                            return "<C-i>"
                        end
                        return nil
                    end
                end, {
                    desc = "Accept Copilot NES",
                    expr = is_tab,
                })
            end

            if M.config.keymaps.clear_nes then
                vim.keymap.set("n", M.config.keymaps.clear_nes, function()
                    if not require("copilot-lsp.nes").clear() then
                        return M.config.keymaps.clear_nes
                    end

                    return nil
                end, { desc = "Clear Copilot NES", expr = true })
            end
        end,
    })

    vim.lsp.enable("copilot_ls")
end

return M
