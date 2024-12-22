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
