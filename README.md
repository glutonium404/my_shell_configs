Github link: https://github.com/glutonium404/my_shell_configs

For themes. Visit [root loop](https://rootloops.sh/)  

## Setting nerd for on chromeOS

chromeOS doesnt allow custom fonts for terminal
but there is a workaround. follow the steps below:
- open terminal
- hit ctrl + shift + j
- paste the following code in the console and hit enter

this should set up jetbrain mono nerd font in the terminal

```js
term_.prefs_.set('font-family', 'JetBrains Mono Nerd Font, monospace');
term_.prefs_.set('user-css-text', '@font-face {font-family: "JetBrains Mono Nerd Font"; src: url("https://raw.githubusercontent.com/ryanoasis/nerd-fonts/master/patched-fonts/JetBrainsMono/Ligatures/Regular/JetBrainsMonoNerdFont-Regular.ttf"); font-weight: normal; font-style: normal;} x-row {text-rendering: optimizeLegibility;font-variant-ligatures: normal;}')
```

## Current theme

To set the theme:
- copy the code below
- open terminal
- open console with ctrl + shift + j
- copy paste the following code in it and run it

```js
const theme = {
    "background-color": "#262626",
    "foreground-color": "#E5DFF4",
    "cursor-color": "#FCD836",
    "color-palette-overrides": [
        "#271B3A", // black
        "#CD8275", // red
        "#70A97B", // green
        "#AC975C", // yellow
        "#8396D1", // blue
        "#BF7FB9", // magenta
        "#5EA5B2", // cyan
        "#C0AFE1", // white
        "#5B4480", // brightBlack
        "#DC9B90", // brightRed
        "#84BF90", // brightGreen
        "#C3AC70", // brightYellow
        "#9CACDD", // brightBlue
        "#D099CA", // brightMagenta
        "#73BBC8", // brightCyan
        "#F2EFF9" // brightWhite
    ],
}

for(const [key, value] of Object.entries(themes)) {
    term_.prefs_.set(key, value);
}
```
