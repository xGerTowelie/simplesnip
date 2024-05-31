# Introduction
This is a very simple nvim plugin to insert code snippets into the current buffer. The plugin is only pasting the snippets content. There are no placeholder or anything else. Just the static content. (for now)

# Installation & Setup
The installation can be done very easly with lazy. We have 3 configs we can override:

```
return {
    'xGerTowelie/simplesnip',
    opts = {
        snippets_path = '/home/marcel/snippets',
        keymap_select = '<leader>ss',
        keymap_add = '<leader>sa',
    },
}
```

# Usage
## Inserting snippet
When using the configured `keymap_select` telescope shows all snippets in the configured folder.

## Saving new snippet
When in visual mode, select the code/text you want to save. Then enter a name for the snippet. The snippet will then be placed in the configured directory.
