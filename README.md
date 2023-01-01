# Maintenance Man!
A prototype physics / puzzle game built with LÖVE.

Check out the **[video demo](https://youtu.be/KcPpZiQwE0c)** for example gameplay.

## Overview

Inspired by the old gag, "How many people does it take to change a lightbulb?", _Maintenance Man_ gives us an answer once and for all.

Using the **Men At Work**<sup>TM</sup> crate that dispenses a new Maintenance Man at the touch of a button, it's up to you to **hold ladders** in place and **throw bulbs** around until you manage to get a lightbulb in the fixture, lighting up the room and winning the game.

## Controls

**Move**

<kbd>w</kbd>
<kbd>a</kbd>
<kbd>s</kbd>
<kbd>d</kbd>

<kbd>←</kbd>
<kbd>↑</kbd>
<kbd>↓</kbd>
<kbd>→</kbd>
 
**Jump**

<kbd>________</kbd>

**Hire a maintenance man**

<kbd>x</kbd>

**Hold a ladder**

<kbd>l</kbd>

**Throw a lightbulb**

<kbd>e</kbd>

**Menu**

<kbd>Esc</kbd>

## Running on the web

With node installed, run `npm build` to generate an updated web build in the root directory. Deploy the following files to a web server and it should run just fine.

- `game.data`
- `game.js`
- `index.html`
- `love.js`
- `love.wasm`

**NOTE**: Opening the index.html file locally doesn't work - a web server is needed (if using VSCode, you can easily install an extensiopn for this).

## Running locally with LÖVE

In addition to cloning the repository, you will need to [download](https://love2d.org/#download) and install LÖVE if you don't have it already. Follow the specific instructions for your OS below.

### Windows:

- If given the option, install LÖVE to `"C:\Program Files\LOVE\love.exe"`
 - Alternatively, make a note of the installation path, and update `run.bat` to replace `"C:\Program Files\LOVE\love.exe"` with the correct path.
- Open a terminal in the project folder and execute `.\run.bat`. This will run LÖVE and point it at the project folder.


### Linux:

- After installing LÖVE, verify that the  `love` command is available and working in your terminal. Don't forget to start a new terminal session after installing!
- Navigate to the project root directory and execute `love .`

### MacOS

- Ensure you install LÖVE in the Applications folder.
- Add an alias to your terminal resource configuration (e.g. `~/.bashrc`, `~/.zshrc`, `~/.bash_profile`) as below:

`alias love="/Applications/love.app/Contents/MacOS/love"`

- In a new terminal session, navigate to the project root directory and execute `love .` 


If you get stuck further installation instructions and help is available on the official [Love2d Wiki](https://love2d.org/wiki/Getting_Started).

## Overview of the codebase

`main.lua` is the entry point for the program. After importing the code, the first thing the runtime does is call `love.load()`. This is called once only. Most of the setup work is done here:

- Loading assets
- Initializing the map and the physics world
- Creating tables to hold the player character and other physics objects
- Loading the menu screen

After this, the entire programv essentially boils down to two functions, invoked repeatedly in succession:

`love.update()`

`love.draw()`

These two functions constitute the game loop. The `update` function is where the heavy lifting happens:

- Physics calculations, which are mostly handled by the `love.physics` API, a wrapper for the Box2D physics engine.
- Determining what graphics should be drawn, e.g. specific animation frames, the background image, whether a bulb is on or off depending on whether the win condition is met, etc.

Then in `draw` the  `love.graphics()` API is invoked to render the frame to the screen.

## Shoutouts

All "dependencies" are simply copied-and-pasted code which I've discovered from two main sources:

- [Sheepolution](https://sheepolution.com/learn/book/contents), a great starting point for learning Lua for games, and an introduction to the [Classic](https://github.com/rxi/classic/blob/master/classic.lua) library which I have used widely in this project.
- [DevJeeper's "Platformer Tutorial Series"](https://www.youtube.com/@DevJeeper), particularly for its introduction to [Tiled](https://www.mapeditor.org/) and [STI](https://github.com/karai17/Simple-Tiled-Implementation)

For the images and audio assets I have the following people to thank:
- [Jonny Wildman](https://www.linkedin.com/in/jonathan-wildman-aa3855118/)
  - Composed, recorded and mixed three original tracks for the menu music, in-game music, and win music
  - Directed, recorded, and mixed audio for the sound effects, and performed most of them himself (a few were provided by yours truly!)

- [Lakshmi Haridas](https://www.linkedin.com/in/lakshmiharidas/) provided the cartoon for the Maintenance Man himself