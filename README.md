# floatodo.nvim

A minimalist floating TODO manager for Neovim using markdown.

📌 Quickly jot down daily tasks in a floating window. Each day starts with a new date heading and two fresh TODOs. Your list is saved to a persistent markdown file of your choice.

---
## ✨ Features

- 📅 Automatically inserts a `## YYYY-MM-DD` heading for today
- 📝 Starts each day with two empty `- [ ]` TODOs
- 🔝 Prepends new entries at the top of the file
- 📁 Saves to a persistent markdown file (default: `~/.todo.md`)
- 💾 Auto-saves on close (`q` or `<Esc>`)
- 📏 Customizable floating window size
- 🔄 Toggle with a keybinding (e.g. `<leader>td`)

---
## 📦 Installation

### 🔹 Using [Lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
return {
  "debsishu/floatodo.nvim",
  config = function()
    require("floatodo").setup({
      path = "~/todo.md",
      width_percent = 0.8,
      height_percent = 0.8,
      insert_on_open = false,
    })
    vim.keymap.set("n", "<leader>td", function()
      require("floatodo").floatodo_toggle()
    end, { desc = "Toggle Floating TODO" })
  end,
}
```
### 🔹 Using [Packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use({
  "debsishu/floatodo.nvim",
  config = function()
    require("floatodo").setup({
      path = "~/todo.md",
      width_percent = 0.8,
      height_percent = 0.8,
      insert_on_open = true,
    })

    vim.keymap.set("n", "<leader>td", function()
      require("floatodo").floatodo_toggle()
    end, { desc = "Toggle Floating TODO" })
  end,
})
```

### 📂 Example

```markdown
# TODOs

## 2025-06-28
- [ ] .
- [ ] .

## 2025-06-27
- [x] Finish floatodo.nvim
- [ ] Update README
```
