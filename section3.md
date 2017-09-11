# Section 3 - Game building with OpenFL

In this section, we will look at
- using Haxe libraries and frameworks
- the OpenFL framework and game architecture

## Using Haxe libraries and frameworks

> **If I have seen further, it is by standing on the shoulders of giants.**  
> Isaac Newton (1675)

Like in any other programming languages, libraries and frameworks are major building blocks for our program.

Haxe comes with its official library manager called **Haxelib**. For beginner and simple projects, we recommending using Haxelib to manage the project dependencies. Mainly because it comes with the standard Haxe installation, so no extra work is needed to set it up.

However, for larger and serious projects, we don't really recommend Haxelib mostly because it lacks a robust mechanism to pin down exact versions of the project dependencies. It could be very painful if you cannot compile your months-old code, or it compiles but does not work as before. So, it is recommend to seek for other solutions that reproduce your project exactly, even after months or years. (Advertisement: you may want to have a look at [Lix](https://github.com/lix-pm/lix.client))

For tutorial purpose, let's start with the official project manager: Haxelib.

#### Setup Haxelib

If you have never run Haxelib before, run the following code to set it up:

```
haxelib setup
```

It will then prompt you to input a path, such path will be used to store the downloaded library source codes.

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

Haxe is famous for its game-building capability. There are a lot of game framework written in Haxe. We are going to pick one and build a simple game in this tutorial: **OpenFL**.

(For curious babies: some other Haxe game frameworks could be found with these keywords: `NME`, `Kha`, `Heaps`, `Luxe`)

#### Install OpenFL

```
haxelib install lime
haxelib install openfl
```

#### Create a new OpenFL project

If you are using HaxeDevelop, you can create a new OpenFL project by navigating through the menu bar: `Project > New > OpenFL Project`

Otherwise, you can run the following openfl command:

```
openfl create project
```

#### Build and Run

To build and run, execute one of the following commands in your OpenFL project:

```
openfl test html5
openfl test mac
(etc...)
```

## Game architecture

Most game engines work in this way:

The core of a game usually consists of a main game loop, which is a function written by us as game developers. In general, the loop runs about 30-60 times per second. During each iteration, the user input will be processed, game state will be updated, and the visuals on the screen will be updated. 

In OpenFL, the main game loop is usually created by listening to the `ENTER_FRAME` event. Inputs are handled by listen to various events in `KeyboardEvent`, `TouchEvent`, `MouseEvent`. Visuals are generally handled by `DisplayObject` and its subclasses.