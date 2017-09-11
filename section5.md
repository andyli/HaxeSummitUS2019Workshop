# Section 5 - Multiplayer

In this section, we will add multiplayer functionality into our game.

## Server-client architecture

There are many ways to implement a multiplayer game. One particular way we are going to use is a server-centric solution. We let the clients to send control signals to the server. The server will then handle the game logic, updates the states of each player and the game world. The game state information will be sent to each client, and the clients will render the graphics according to the game state.

This architecture has the benefit that players wouldn't be able to cheat by modifying the client, since the game logic is handled by the server. In fact, the game logic is not compiled into the client at all.

Moving the game logic to server is as simple as calling the `game.World` functions in `Server`, and removing all references of the `game.World` in the client.

Concretely, in the beginning, the client will connect to a predefined server. Once connected, the server will create a player in the game world, and send the current game state to the client. The client will render the graphics. When the mouse is pressed, the client will send the direction info to the server. The server will update the game state and send the updated info to the clients. This keeps repeating until the client disconnect or the server is shut down.

## Enum

There are a number of messages that clients will send to the server:

 * join a game
 * change movement direction
 * start moving
 * stop moving

To encode those messages, we can use enum, which is a type of a group of possible values.

Create a `mp.Command` enum type:

```haxe
package mp;
enum Command {
	Join;
	SetDirection(dir:Float);
	StartMove;
	StopMove;
}
```

Let's see how we can use enum:

```haxe
function receive(command:Command) {
    switch command {
        case Join:
            // ... world.createPlayer() ...

        case SetDirection(dir):
            // ... client.player.dir = dir;

        case StartMove:
            // ... client.player.speed = 3;

        case StopMove:
            // ... client.player.speed = 0;
    }
}
```

The benefit of using enum is that, the number of possible values is limited. A `Command` will always be one of the 4 kinds we defined (or `null`). When we implement the `receive()` function, if we accidentally added an extra kind or didn't handle one value kind, the Haxe compiler will complain.

This compile-time checked safety is very useful in building cross-target application. Remember that the same `Command` enum is being used in both server and client source code. When we change `Command`, the Haxe compiler will make sure our usages in both server and client are correct. This is not the case if we used different languages for the two sides: If we write the client in C++ and server in JS, we will need to write separated `Command` types in the two languages. If we change the JS `Command` and forget to update the C++ one, the C++ source code will still compile, but when a client connect to the server, the server will not understand the commands sent by the client.

Similar to `Command`, let's define the `Message` that server sends to clients:

```haxe
package mp;
import game.*;
enum Message {
	Joined(id:Int); // the server assigns an id to the client
	State(state:GameState);
}
```

## Serialization

We have seen how WebSocket works - building up connection and sending `String` messages between each others. To convert `Command` and `Message` to and from `String`, we can use `haxe.Serializer` and `haxe.Unserializer`. The two classes are provided by the Haxe standard library and work in all targets. The encoded `String` can be decoded into Haxe values as long as the same Haxe type exists in the decoding program.

```haxe
import haxe.*;
class HelloWorld {
    static function main() {
        var value = [1, 2, 3];
        var encodedStr = Serializer.run(value);
        trace(encodedStr); // ai1i2i3h
        var decodedValue = Unserializer.run(encodedStr);
        trace(decodedValue); // [1,2,3]
    }
}
```

We can see that it is really easy to share things, including types and runtime values, between Haxe programs.

## Put all the pieces together

You should now be able to implement multiplayer to the game. Some additional tips and details:

 * Assume there is only one game world and all player connecting to the server will join the same world.

 * The server should maintain an `Array` of players and their associated WebSocket connections.

 * The client will first send an `Join` message once connected to the server. The server will reply with `Joined(id)`. The client should save the id.

 * Use `haxe.Timer` to implement the game loop in the server.
 
 * In each iteration of the game loop,
   * update the game world
   * send the game state to all connected clients
   * perform any clean up as needed (e.g. removing disconnected clients.

 * When the client receives a `State(state)`, it should save it, and render it during `update()`.

 * When the player press down, release, or move the cursor, the client no longer need to update the state, but just send a `Command` to the server.