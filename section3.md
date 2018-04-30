# Section 3 - Game building with Heaps

In this section, we will look at
- using Haxe libraries and frameworks
- the Heaps framework and game architecture

## Using Haxe libraries and frameworks

> **If I have seen further, it is by standing on the shoulders of giants.**  
> Isaac Newton (1675)

Like in any other programming languages, libraries and frameworks are major building blocks for our program.

Haxe comes with its official library manager called **Haxelib**. For beginner and simple projects, we recommending using Haxelib to manage the project dependencies. Mainly because it comes with the standard Haxe installation, so no extra work is needed to set it up.

For tutorial purpose, let's start with the official project manager: Haxelib.

#### Setup Haxelib

If you have never run Haxelib before, run the following code to set it up:

```
haxelib setup
```

It will then prompt you to input a path, such path will be used to store the downloaded library source codes. We recommend using a folder in the home directory (e.g. `~/haxelib`) or in the Document directory (e.g. `C:\Users\(User_Name)\Documents\haxelib`).

#### Install a Haxe library

To install a library:

```
haxelib install <library-name>
```

For example:

```
haxelib install format
```

#### Use a Haxe library

Then in your `build.hxml`, add a library flag to use the library in your project:

```
-lib <library-name>
```

For example:

```
-lib format
```

After that, you can use the Types (i.e. Classes, Enums, etc) provided by the [format](https://github.com/HaxeFoundation/format) library

## Game Frameworks

Haxe is famous for its game-building capability. There are a lot of game framework written in Haxe. We are going to pick one and build a simple game in this tutorial: **Heaps**.

(For curious minds: some other Haxe game frameworks could be found with these keywords: `Kha`, `OpenFL`, `Luxe`)

#### Install Heaps

```
haxelib install heaps
```

## Game architecture

Most game engines work in this way:

The core of a game usually consists of a main game loop, which is a function written by us as game developers. In general, the loop runs about 30-60 times per second. During each iteration, the user input will be processed, game state will be updated, and the visuals on the screen will be updated. 

In Heaps, the main game loop is already provided, all we have to do is to `extends hxd.App` and override its `update` method, which is run per iteration step. Input events are dispatched from `stage`. We can listen to them by `stage.addEventTarget(eventHandler)`. 2D visuals are generally handled by `h2d.Sprite` and its subclasses.
