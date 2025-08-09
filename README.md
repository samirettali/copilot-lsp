# Copilot LSP Configuration for Neovim

## Features

### Done

- TextDocument Focusing

### In Progress

- Inline Completion
- Next Edit Suggestion
- Uses native LSP Binary

### To Do

- [x] Sign In Flow
- Status Notification

## Usage

```lua
{
    "copilotlsp-nvim/copilot-lsp",
    opts = {},
}
```

## Default configuration

You don't need to configure anything, but you can customize the defaults: `move_count_threshold` is the most important setting - it controls how many cursor moves happen before suggestions are cleared. Higher values make suggestions persist longer.

```lua
require('copilot-lsp').setup({
    nes = {
        auto_trigger = false,
        debounce = 500,
        move_count_threshold = 3,
        distance_threshold = 40,
        clear_on_large_distance = true,
        count_horizontal_moves = true,
        reset_on_approaching = true,
    }
    keymaps = {
        request_nes = nil,
        accept_nes = nil,
        clear_nes = nil,
    },
})
```

### Keymap Configuration

**By default, no keymaps are set** to avoid breaking existing configurations, you need to explicitly set them:

```lua
require('copilot-lsp').setup({
    keymaps = {
        request_nes = "<leader>re",
        accept_nes = "<tab>",
        clear_nes = "<esc>",
    },
})
```

When `accept_nes` is set to `<tab>`, it will fallback to `<C-i>` in normal mode when no suggestion is active (resolving the terminal's inability to distinguish between Tab and Ctrl-I).

### Blink Integration

```lua
return {
    keymap = {
        preset = "super-tab",
        ["<Tab>"] = {
            function(cmp)
                if vim.b[vim.api.nvim_get_current_buf()].nes_state then
                    cmp.hide()
                    return (
                        require("copilot-lsp.nes").apply_pending_nes()
                        and require("copilot-lsp.nes").walk_cursor_end_edit()
                    )
                end
                if cmp.snippet_active() then
                    return cmp.accept()
                else
                    return cmp.select_and_accept()
                end
            end,
            "snippet_forward",
            "fallback",
        },
    },
}
```

It can also be combined with [fang2hou/blink-copilot](https://github.com/fang2hou/blink-copilot) to get inline completions.
Just add the completion source to your Blink configuration and it will integrate

# Requirements

- Copilot LSP installed via Mason or system and on PATH

### Screenshots

#### NES

![JS Correction](https://github.com/user-attachments/assets/8941f8f9-7d1b-4521-b8e9-f1dcd12d31e9)
![Go Insertion](https://github.com/user-attachments/assets/2c0c4ad9-873b-4860-9eff-ecdb76007234)

<https://github.com/user-attachments/assets/1d5bed4a-fd0a-491f-91f3-a3335cc28682>
