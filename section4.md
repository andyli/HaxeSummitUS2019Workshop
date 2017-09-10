# Section 4 - Using NodeJS

In this section, we will detour a little bit and look at writing [NodeJS](https://nodejs.org/) programs in Haxe.

We will look at
 * using native libraries (writing externs)
 * NodeJS basics (CLI, NPM)

Before we start, make sure you have installed NodeJS, and the `node` and `npm` command line program is available.

## using native libraries

From time to time we will need to access platform API and native libraries.

For most platform APIs, they are already available in the Haxe standard library that comes with any Haxe installation. They reside in the package of the same name as the target. For instance, the JavaScript and HTML DOM APIs are reside in the [`js` package](http://api.haxe.org/js/index.html). Those target packages come with a `Lib` class, which contains most commonly used native top-level functions.

For NodeJS support, we may use the [hxnodejs](http://lib.haxe.org/p/hxnodejs/) library, which is maintained by the Haxe Foundation. To install it, simply run `haxelib install hxnodejs`.

Let's try to use some NodeJS APIs. Create a new file, `Server.hx`, with the content as follows:

```haxe
import js.node.Fs; // https://devdocs.io/node/fs

class Server {
    static function main():Void {
        // read and print the list of files of the current directory
        Fs.readdir(".", function(error, files) {
            trace(files);
        });
    }
}
```

Compile the program with a hxml as follows:

```
-main Server
-lib hxnodejs
-js server.js
```

Once it is compiled, we can run it with the command as follows:

```sh
node server.js
```

We can see that using native APIs is not much different from using Haxe APIs, except that we have to install some library. Libraries that expose native APIs contain a bunch of [externs](https://haxe.org/manual/lf-externs.html), which are Haxe types that tell the Haxe compiler about the type signatures of the native APIs. Notice that for some targets, e.g. Java, C#, and Flash, the Haxe compiler is smart enough to consume the type information available in the native library, so we don't really need externs for those targets. Instead, we just need to use `-java-lib path/to/foo.jar` to use a Java library, for example.

Let's take a look at the [extern class of the Node fs module](https://github.com/HaxeFoundation/hxnodejs/blob/4.0.9/src/js/node/Fs.hx#L269-L270) we have just used:

```haxe
package js.node;

import haxe.extern.EitherType;
import js.Error;
import js.node.Buffer;

typedef FsPath = EitherType<String,Buffer>;

/* ...some other types */

@:jsRequire("fs")
extern class Fs {
    static function readdir(path:FsPath, callback:Error->Array<String>->Void):Void;

    /* ...some other members */
}
```

The `extern` keyword denotes that it is an extern class. The `@:jsRequire("fs")` metadata tells that the type can be loaded at runtime by calling `require("fs")`, which is the NodeJS way of loading modules. The members of the class are just written normally, with the exception that the function bodies are left out, since the implementation is given by the runtime or external library.