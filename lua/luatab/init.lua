local function tabName(bufnr)
    local file = vim.fn.bufname(bufnr)
    local buftype = vim.fn.getbufvar(bufnr, '&buftype')
    local filetype = vim.fn.getbufvar(bufnr, '&filetype')
    if file == '' then
        return '[No Name]'
    elseif buftype == 'help' then
        return 'help:' .. vim.fn.fnamemodify(file, ':t:r')
    elseif buftype == 'quickfix' then
        return 'quickfix'
    elseif filetype == 'TelescopePrompt' then
        return 'Telescope'
    elseif file:sub(file:len()-2, file:len()) == 'FZF' then
        return 'FZF'
    elseif buftype == 'terminal' then
        return 'zsh'
    end
    return vim.fn.pathshorten(vim.fn.fnamemodify(file, ':p:~:t'))
end

local function tabModified(bufnr)
    return vim.fn.getbufvar(bufnr, '&modified') == 1 and '[+] ' or ''
end

local function tabWindowCount(current)
    local nwins = vim.fn.tabpagewinnr(current, '$')
    return nwins > 1 and '(' .. nwins .. ') ' or ''
end

local function tabDevicon(bufnr, isSelected)
    local dev, devhl
    local file = vim.fn.bufname(bufnr)
    local buftype = vim.fn.getbufvar(bufnr, '&buftype')
    local filetype = vim.fn.getbufvar(bufnr, '&filetype')
    if buftype == 'terminal' then
        dev, devhl = require'nvim-web-devicons'.get_icon('zsh')
    elseif filetype == 'fugitive' then
        dev, devhl = require'nvim-web-devicons'.get_icon('git')
    elseif filetype == 'vimwiki' then
        dev, devhl = require'nvim-web-devicons'.get_icon('markdown')
    else
        dev, devhl = require'nvim-web-devicons'.get_icon(file, vim.fn.getbufvar(bufnr, '&filetype'))
    end
    if dev then
        return (isSelected and '%#'..devhl..'#' or '') .. dev .. (isSelected and '%#TabLineSel#' or '')
    end
    return ''
end

local function tabSeparator(current)
    return ' ' .. (current < vim.fn.tabpagenr('$') and '%#TabLine#|' or '')
end

local function formatTab(current)
    local t = vim.fn.tabpagenr()
    local isSelected = vim.fn.tabpagenr() == current
    local buflist = vim.fn.tabpagebuflist(current)
    local winnr = vim.fn.tabpagewinnr(current)
    local bufnr = buflist[winnr]
    local file = vim.fn.bufname(bufnr)
    local hl = (isSelected and '%#TabLineSel#' or '%#TabLine#')

    return hl .. ' ' ..
        tabWindowCount(current) ..
        tabName(bufnr) .. ' ' ..
        tabModified(bufnr) ..
        tabDevicon(bufnr, isSelected) ..
        tabSeparator(current)
end

local function tabline()
    local i = 1
    local line = ''
    while i <= vim.fn.tabpagenr('$') do
        line = line .. formatTab(i)
        i = i + 1
    end
    return  line .. '%T%#TabLineFill#%='
end

local M = {
    tabline = tabline,
    formatTab = formatTab,
    tabSeparator = tabSeparator,
    tabWindowCount = tabWindowCount,
    tabName = tabName,
    tabModified = tabModified,
    tabDevicon = tabDevicon,
}

return M