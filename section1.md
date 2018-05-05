# Section 1 - Getting started

In this section, we will look at
 * What is Haxe?
 * Haxe showcases - who is using Haxe and what people build with it.
 * How to download and install Haxe.

## What is Haxe?

A programming language designed to be a multi-target. Multi-target means a Haxe program can be (cross-)compiled into different binary or source code formats. This makes Haxe highly platform independent.

### What problems a multi-target language can solve?

There are many different application platforms, like Android, iOS, Windows, Mac, and Linux. The following scenarios are very common:

 * To develop an application that can be run on multiple platforms for maximizing the potential user amount. e.g. A mobile app that available to both Android and iOS.

 * To develop an application that contains components in different platforms. e.g. A web site that comprises of server-side business logic (runs in server, using e.g. PHP) and client-side UI scripting (runs in browsers, using JS).

 * The same individual developer/company works on projects to projects, jumping between different platforms.

 * Old platforms become deprecated and existing applications have to be converted to new platforms. e.g. The Flash browser plug-in is about to be discontinued, so existing Flash contents have to be ported to HTML5.

Most platforms officially support only 1-2 languages, e.g. Android supports Java/Kotlin, the web supports JavaScript. Using a non-multi-target language that is not officially supported usually implies poor runtime performance and poor development experience. For example, although it is possible to write a JavaScript application for Android, a Java Android app will usually run faster and consume less power. Accessing Android APIs in JavaScript also requires wrappers, which easily become outdated and impose additional runtime/development overhead. That means, traditionally, targeting multiple platforms requires using multiple different languages.

Haxe, designed to be a multi-target, helps in the following ways:

 * Low runtime overhead by-design and sophisticated compile-time optimizations make Haxe programs have similar or even better runtime performance than programs written in the target language.

 * Haxe compiler does its best to emit readable target code. Debugging Haxe programs is similar to debugging programs written in the target language.

 * The Haxe standard library and many third-party Haxe libraries provide cross-platform APIs, offers a "write once, compile and run everywhere" experience.

 * Haxe allows using APIs and libraries in the target language in several simple ways (externs, reflection etc.).

 * Conditional compilation, compile-time macros, and other features make customizing for each platform easy.

## Haxe showcases

 * [HaxeFlixel showcase](http://haxeflixel.com/showcase/)
 * [OpenFL showcase](http://www.openfl.org/showcase/)
 * [Shiro Games](http://shirogames.com/) (Nicolas Cannasse, the Haxe creator's game company)
 * [Verb](http://verbnurbs.com/) (cross-platform NURBS library)
 * [Net Wars](http://www.netwars-project.com/webdoc) (an award-winning website featuring interactive video, infographics, social media etc.)

## How to download and install Haxe

Simply use the installer (for Windows/Mac) or the software package (for Linux) in the [haxe.org download page](https://haxe.org/download/) to install.

Once installed, a number of components should be available:

 * the Haxe compiler with the Haxe standard library
 * the `haxelib` package manager
 * the [Neko virtual machine](http://nekovm.org/)

Make sure the command line (i.e. terminal for Unix or command prompt/powershell for Windows) can access the above tools. Let's run the commands as follows:

```sh
haxe -version
```

```sh
haxelib version
```

```sh
neko -version
```

Version numbers of the corresponding programs will be printed.

### Hello World

Create a folder for storing the hello world project. Within the folder, create a Haxe source file, named `HelloWorld.hx`, with the content as follows:

```haxe
class HelloWorld {
    static function main() {
        trace("Hello, World!");
    }
}
```

Create a build configuration file, named `build.hxml`, with the content as follows:
```
-main HelloWorld
--interp
```

Open a command line window and run the commands as follows:

```sh
# change directory to the project folder
cd path/to/hello_world_project

# compile
haxe build.hxml
```

It should prints `HelloWorld.hx:3: Hello, World!`.

What we have just done is to let the Haxe compiler interpret the Haxe code written in the `HelloWorld` class.

Notice that the content of `build.hxml` is simply the command line arguments for the Haxe compiler. It means, our `haxe build.hxml` command is the same as `haxe -main HelloWorld --interp`.

Let's try to target JavaScript. To do so, replace `--interp` with `-js HellowWorld.js`, and then compile again. A `HellowWorld.js` file will be created in the project folder.

The list of targets and other compiler parameters can be found using `haxe --help`.
