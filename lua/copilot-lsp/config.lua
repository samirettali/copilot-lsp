---@class copilotlsp.config.keymaps
---@field request_nes? string? Keymap to request a suggestion
---@field accept_nes? string? Keymap to accept a suggestion
---@field clear_nes? string? Keymap to clear a suggestion

---@class copilotlsp.config.nes
---@field auto_trigger boolean Whether to automatically trigger suggestions
---@field debounce integer Debounce time in milliseconds
---@field move_count_threshold integer Number of cursor movements before clearing suggestion
---@field distance_threshold integer Maximum line distance before clearing suggestion
---@field clear_on_large_distance boolean Whether to clear suggestion when cursor is far away
---@field count_horizontal_moves boolean Whether to count horizontal cursor movements
---@field reset_on_approaching boolean Whether to reset counter when approaching suggestion

local M = {}

---@class copilotlsp.config
---@field nes copilotlsp.config.nes
---@field keymaps copilotlsp.config.keymaps
M.defaults = {
    nes = {
        auto_trigger = false,
        debounce = 500,
        move_count_threshold = 3,
        distance_threshold = 40,
        clear_on_large_distance = true,
        count_horizontal_moves = true,
        reset_on_approaching = true,
    },
    keymaps = {
        request_nes = nil,
        accept_nes = nil,
        clear_nes = nil,
    },
}

---@type copilotlsp.config
M.config = vim.deepcopy(M.defaults)

---@param opts? copilotlsp.config configuration to merge with defaults
function M.setup(opts)
    opts = opts or {}
    M.config = vim.tbl_deep_extend("force", M.defaults, opts)
end

return M
