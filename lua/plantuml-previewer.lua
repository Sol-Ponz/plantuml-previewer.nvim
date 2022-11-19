local g_init_done = false

local error_log = function(string)
    tag = "[plantuml-previewer] "
    string = tag .. tostring(string)
    vim.schedule(function() vim.notify(string, vim.log.levels["ERROR"], {title = "plantuml-previewer"}) end)
end

local is_exist = function(filename)
    local f = io.open(filename, "rwx")
    if f ~= nil then
        io.close(f)
        return true
    end
    return false
end

local previewer = {}
previewer.init = function(opts)
    g_init_done = true
    
    if not opts then
        error_log("setup requires option.")
        return
    end
    if not opts.plantuml_jar then
        error_log("setup requires plantuml.jar destination.")
        return
    end

    local plantuml_jar     = opts.plantuml_jar
    local java_command     = opts.java_command or "java"
    local output_dir       = opts.output_dir or os.getenv("HOME") .. "/plantuml_output/"
    local output_txt_style = opts.output_txt_style or "utxt"
    local disable_number   = opts.disable_number or true
    local auto_reload      = opts.auto_reload or true

    vim.api.nvim_exec(string.format("silent !%s -version", java_command), false)
    if vim.api.nvim_get_vvar("shell_error") ~= 0 then
        error_log(string.format("setup option 'java_command(%s)' is invalid", java_command))
        return
    end

    if not is_exist(plantuml_jar) then
        error_log(string.format("setup option 'plantuml_jar'(%s) is invalid.", plantuml_jar))
        return
    end
    
    vim.api.nvim_create_autocmd({"BufNewfile", "BufRead"}, {
        pattern = "*.utxt",
        callback = function()
            vim.opt["filetype"] = "utxt"
            if disable_number then
                vim.api.nvim_set_option_value("relativenumber", false, {scope="local"})
                vim.api.nvim_set_option_value("number", false, {scope="local"})
            end
            if auto_reload then
                vim.api.nvim_set_option_value("autoread", true, {scope="local"})
            end
        end,
    })
    vim.api.nvim_create_autocmd({"BufNewfile", "BufRead"}, {
        pattern = "*.pu",
        callback = function()
            vim.api.nvim_create_user_command(
            "OutputTxtUml",
            function()
                vim.api.nvim_exec("silent !" .. java_command .. " -jar " .. plantuml_jar .. " -o " .. output_dir .. output_txt_style .. " -" .. output_txt_style .. " %:p", false)
            end,
            {}
            )
            vim.api.nvim_create_user_command(
            "PngUml",
            function()
                vim.api.nvim_exec("silent !" .. java_command .. " -jar " .. plantuml_jar ..  " -o " .. output_dir .. "png %:p", false)
            end,
            {}
            )
            vim.api.nvim_create_user_command(
            "PreviewUtxtUml",
            function()
                vim.api.nvim_exec("vs " .. output_dir .. output_txt_style .. "/%:t:r." .. output_txt_style, false)
            end,
            {}
            )
        end,
    })
    vim.api.nvim_create_autocmd("BufWritePost", {
        pattern = "*.pu",
        callback = function()
            vim.api.nvim_exec("OutputTxtUml", false)
        end,
    })
end

local M = {}

M.setup = function(opts)
    if g_init_done then
        return
    end
    previewer.init(opts)
end

return M
