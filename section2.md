# Section 2 - Haxe programming basics

In this section, we will look at
 * VSCode project setup
 * basic building blocks

## VSCode project setup

Currently, one the best IDEs with Haxe support is [Visual Studio Code](https://code.visualstudio.com/). Once the base VSCode is installed, install the [Haxe Extension Pack](https://marketplace.visualstudio.com/items?itemName=vshaxe.haxe-extension-pack).

Let's keep using our hello world project. Open VSCode, then open the hello world project folder by "File" -> "Open...".

The Haxe language support extension automatic detects the present of `.hxml` file. It allows us to use the hotkey `ctrl`+`shift`+`b` (or `command`+`shift`+`b` for Mac) to build the project.

## syntax, type system, and other building blocks

Let's take a closer look at our `HelloWorld.hx` source code:

```haxe
class HelloWorld {
    static function main() {
        trace("Hello, World!");
    }
}
```

In Haxe, each `.hx` source file is a *module*, in which there can be zero, one, or more *types*. `class` is one of the most common kinds of type being used. There are also `interface`, `typedef`, `enum`, and `abstract`, which we will cover some of them later.

In our `HelloWorld` module, we defined a `HelloWorld` class, and tell the Haxe compiler that this is the main entry point of the program by `-main HelloWorld`. A main class should have a special `main()` static function, to be called when the program starts.

In our `main()`, we used `trace()`, which is a special function for debugging. By default, `trace()` will print out its argument to the console.

### Defining variables

Use the `var` keyword to declare a variable.

```haxe
class HelloWorld {
    static function main() {
        var str = "Hello, World!";
        trace(str); // Hello, World!
    }
}
```

Each variable has a type. A variable of `String` (a sequence of characters) cannot store a `Float` (a floating point number). There will be compilation error if we try to do so:

```haxe
class HelloWorld {
    static function main() {
        var str = "Hello, World!";
        str = 123.45; // Float should be String
        trace(str);
    }
}
```

It helps us by preventing us to use invalid operation to a value of incompatible type. For example, we can multiply a `Float` number, but not multiply a `String`.

```haxe
class HelloWorld {
    static function main() {
        var f = 123.45;
        trace(f * 2); // 246.9

        var str = "Hello, World!";
        trace(str * 2); // compilation error
    }
}
```

We can force the compiler to ignore the type error and output the expression as is, but then the program's behavior will be undefined (mostly depended on the target).

```haxe
class HelloWorld {
    static function main() {
        var str = "Hello, World!";
        trace(untyped str * 2);
        /*
            interp: error
            js: NaN
            python: Hello, World!Hello, World!
        */
    }
}
```

Notice how some of the targets produce somewhat reasonable outputs, but different from each other. It is exactly why cross-platform development can be painful - we have to remember in what cases, the behavior will be different across platforms. Haxe helps by defining a single reasonable behavior across all its targets, and prevent us from doing tricky things that may lead to inconsistent behavior across targets.

### Defining functions

Let's say we are in fact interested in Python's behavior - to repeat the `String` by n times. To do this in a cross-platform way, we have to define our own function.

```haxe
class HelloWorld {
    static function repeat(str:String, n:Int):String {
        var result = "";
        for (i in 0...n)
            result += str; // same as `result = result + str;`
        return result;
    }
    static function main() {
        var str = "Hello, World!";
        trace(repeat(str, 2)); // Hello, World!Hello, World!
    }
}
```

The above `repeat()` implementation is not the best in anyway, but we will use it for learning a few things.

Notice how I declare the function arguments inside the brackets, with their type information (`:String` and `:Int`). The type annotations are optional, but for documentation purpose, we usually add them anyway. Here we used another build-in type, `Int`, which is integer.

After the close bracket, there is another type annotation (`:String`), which defines the return type of the `repeat()` function. It is also optional, but good to include anyway. Notice we didn't add one to `main()`. To define a return type for `main()`, we may use `Void`, which means nothing, because we do not `return` anything from `main()`;

We used a loop expression in `repeat()`. Specifically, it is a [for-loop](https://haxe.org/manual/expression-for.html). Its syntax is `for (variable in start...end) ...`. It introduces a variable, and the variable's value will go from `start` to `end` (excluding `end`). In the case of our `repeat(str, 2)`, the `i` in the for-loop will be `0` and then `1`, resulting in running the content of the loop twice.

When we want to repeat more than one expression in the loop body, we can use a block expression, which is exactly a group of expressions. For example, if we want to print out the loop variable in the for-loop:

```haxe
static function repeat(str:String, n:Int):String {
    var result = "";
    for (i in 0...n) {
        trace("i is " + i);
        result += str;
    }
    return result;
}
```

Did you notice that we have been using block expressions as function bodies? So, right, a function with a single expression doesn't need a wrapping `{}`:

```haxe
function hello(name) trace("Hello, " + name + "!");
```

Sometimes we want to loop in a different way (for example we may want `i`'s value to go from `n` to `0` instead of `0` to `n`), we have to use a [while-loop](https://haxe.org/manual/expression-while.html) (or a [do-while-loop](https://haxe.org/manual/expression-do-while.html)), which is more flexible. Rewriting our `repeat()` with a while-loop, we will have:

```haxe
static function repeat(str:String, n:Int):String {
    var result = "";
    var i = 0; // loop variable
    while (i < n) { // loop condition
        result += str;
        i = i + 1; // modify the loop variable in each iteration
    }
    return result;
}
```

There is a third way to perform repeating tasks - recursion, which is calling the same function within the function body. Rewriting our `repeat()` with recursion, we will have:

```haxe
static function repeat(str:String, n:Int):String {
    if (n < 0)
        throw "n cannot be less than 0";
    else if (n == 0)
        return "";
    else
        return str + repeat(str, n - 1); // call `repeat()` again
}
```

Recursion solves problems by using the [divide and conquer](https://en.wikipedia.org/wiki/Divide_and_conquer_algorithm) technique. It is particularly important and popular in the [functional programming](https://en.wikipedia.org/wiki/Functional_programming) paradigm. If you are not used to this way of thinking, spend some time to understand why the recursion version of `repeat()` works.

You should have noticed that we also added input validation in the recursion version. When `n` is negative, the repeat operation doesn't make sense, so we just `throw` an error. We should also do that even when using for or while loop:

```haxe
static function repeat(str:String, n:Int):String {
    if (n < 0)
        throw "n cannot be less than 0";

    var result = "";
    for (i in 0...n)
        result += str;
    return result;
}
```

Let's see what happen when there is an error. Modify `main()` to call `repeat(str, -1)`, compile and run, we will get:

```
HelloWorld.hx:4: characters 12-17 : n cannot be less than 0
HelloWorld.hx:13: characters 14-29 : Called from
?:1: characters 1048575-8796094070782 : Called from
Aborted
The terminal process terminated with exit code: 1
```

The program terminated immediately when the error is thrown. Sometimes we want to handle the error and let the program continue. To do so, we can use `try ... catch(v) ...`:

```haxe
class HelloWorld {
    static function repeat(str:String, n:Int):String {
        if (n < 0)
            throw "n cannot be less than 0";

        var result = "";
        for (i in 0...n)
            result += str;
        return result;
    }
    static function main() {
        var str = "Hello, World!";

        try {
            trace(repeat(str, -1));
        } catch(e:String) {
            trace("There is an error... the error is: " + e);
            trace("Let's repeat 1 time instead: ");
            trace(repeat(str, 1));
        }
    }
}
```

### Packages, modules, and classes

Right now, the `repeat()` function is completed with error handling. To make it reusable in another project, let's move it to its own module.

Create a folder, named `utils`. Within the `utils` folder, create `RepeatString.hx` file, with the content as follows:

```haxe
package utils;
class RepeatString {
    static public function repeat(str:String, n:Int):String { // notice `public`
        if (n < 0)
            throw "n cannot be less than 0";

        var result = "";
        for (i in 0...n)
            result += str;
        return result;
    }
}
```

Modify `HelloWorld.hx` to:

```haxe
class HelloWorld {
    static function main() {
        var str = "Hello, World!";
        trace(utils.RepeatString.repeat(str, 2)); // Generally, use the `.` notation to access members of something.
    }
}
```

Referencing the `RepeatString` class with `utils.RepeatString` is tedious. We can add an `import` statement at the top such that we can use `RepeatString` directly:

```haxe
import utils.RepeatString;
class HelloWorld {
    static function main() {
        var str = "Hello, World!";
        trace(RepeatString.repeat(str, 2));
    }
}
```

To further simplify things, we can import the `repeat()` function directly:

```haxe
import utils.RepeatString.repeat;
class HelloWorld {
    static function main() {
        var str = "Hello, World!";
        trace(repeat(str, 2));
    }
}
```

Moreover, wildcards (`*`) can be used to import every type or every public static member of a type:

```haxe
import utils.*; // import all the types in the utils package

import utils.RepeatString.*; // import all the public static member of `RepeatString`
```

### Conditional compilation

The `repeat()` looks really nice now, and it works in every Haxe target, including Python. But think about it, we already knew that we can use `str * number` to repeat a `String`, can we just use that for the Python target, and use our implementation for all other targets?

Why not.

```haxe
package utils;
class RepeatString {
    static public function repeat(str:String, n:Int):String {
        if (n < 0)
            throw "n cannot be less than 0";

        #if python
            return untyped str * n;
        #else
            var result = "";
            for (i in 0...n)
                result += str;
            return result;
        #end
    }
}
```

#### Exercise

 1. Try to compare the Python output before and after using conditional compilation.

 2. Add the `inline` keyword in front of `static public function repeat(...`, see how it affects the Python output and the JS output.

### Array

We have used `String`, a sequence of characters. What if we want to store a sequence of value of arbitrary type? Use `Array`.


```haxe
class HelloWorld {
    static function main() {
        // to define an Array, use the square brackets
        var numbers = [1, 2, 3, 4, 5];

        // also use square brackets for accessing the elements
        // notice that the array "index" starts from 0
        var thirdElement = numbers[2];
        trace(thirdElement); // 3

        // an Array is "iterable"
        for (element in numbers) {
            trace(element); //1, 2, 3, 4, 5
        }

        // an Array is "mutable"
        numbers.push(6); // add 6 to the end
        trace(numbers); // [1, 2, 3, 4, 5, 6]

        var lastElement = numbers.pop(); // remove the last element
        trace(lastElement); // 6
        trace(numbers); // [1, 2, 3, 4, 5]

        // to create an empty Array, use [] or new
        var emptyArray = [];
        var alsoEmptyArray = new Array();
    }
}
```

#### Exercise

Can you complete the following `RepeatValue.repeat` function, such that `utils.RepeatValue.repeatInt(1, 3)` returns `[1, 1, 1]`, and `utils.RepeatValue.repeat(3.14, 3)` returns `[3.14, 3.14, 3.14]`?

```haxe
package utils;
class RepeatValue {
    static public function repeatInt(value:Int, n:Int):Array<Int> {
        throw "implement this";
    }

    // `repeatInt` can only repeat `Int`, the following can repeat any type!
    // Notice the `<T>` "type parameter"!
    static public function repeat<T>(value:T, n:Int):Array<T> {
        throw "implement this";
    }
}
```

### Class instance

Previously, we have been defining `static` functions, which are members of the class itself. Notice we have used `Array`'s `.push()` and `.pop()` methods, and those are the members of an `Array` "instance".

Classes are good for modeling objects that have a mutable state, as well as a set of methods that depends on its state.

Let's try define our own classes, `Person` and `SecretAgent`:

```haxe
class Person {
    private var name:String;
    public function new(name:String) {
        this.name = name;
    }
    public function getName():String {
        return name;
    }
}

class SecretAgent extends Person {
    override public function getName():String {
        return "Smith";
    }
}

class HelloWorld {
    static function askName(p:Person):Void {
        trace(p.getName());
    }
    static function main() {
        var andy = new Person("Andy");
        askName(andy); // Andy
        var kevin = new SecretAgent("Kevin");
        askName(kevin); // Smith
    }
}
```

Notice how `SecretAgent` inherits the constructor of `Person` and overrides the `getName()` method.

### Anonymous object

We don't always have to create a class to store a bunch of data. Most of the time, we can simply use an anonymous object.

```haxe
class HelloWorld {
    static function main() {
        var andy = {
            name: "Andy",
            occupation: "researcher"
        };
        var kevin = {
            name: "Kevin",
            occupation: "secret agent"
        };
        trace(andy.name); // Andy
        trace(kevin.name); // Kevin
    }
}
```

Notice that there is no concept of private, so `kevin` cannot really protect it's real `name` by itself.

An anonymous object is anonymous because it is an object without a class. Although without a class, there is still a structural type associated with the object.

For the above example, the type of `andy` and `kevin` can be declared as follows:

```haxe
// give the structural type an "alise" for easy reference
typedef Person = {
    name:String,
    occupation:String
}

class HelloWorld {
    static function main() {
        var andy:Person = {
            name: "Andy",
            occupation: "researcher"
        };
        var kevin:Person = {
            name: "Kevin",
            occupation: "secret agent"
        };
        trace(andy.name); // Andy
        trace(kevin.name); // Kevin

        trace(andy.height); // error: Person has no field height
    }
}
```