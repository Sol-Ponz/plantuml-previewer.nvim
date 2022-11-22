# plantuml-previewer.nvim

textbased plantuml previewer for Neovim.

# Demo

[Screencast from 2022年11月23日 00時02分38秒.webm](https://user-images.githubusercontent.com/118619725/203348074-6e62de3c-dd83-4224-bd60-561960a1fd97.webm)


# Quick Start

add below setting in your `init.lua`.
```lua
require("plantuml-previewer").setup {
    plantuml_jar = "/path/to/plantuml.jar",
    java_command = "/path/to/java",
}
```

# Available Command

* `OutputTxtUml` : Render pu files in text files. Normally this command is automatically executed when saving the pu file, but it is also possible to execute it manually.
* `PngUml` : Render pu files as png files.
* `PreviewUtxtUml` : Splits the pane vertically and shows a preview of the pu file. The preview is automatically updated when you save the pu file.
