
import hxd.*;
import h2d.*;
import game.*;
using Lambda;

#if MULTIPLAYER
import haxe.Serializer;
import haxe.Unserializer;
import mp.Command;
import mp.Message;
#end

class Main extends App {

	var world:World;
	var state:GameState;
	var window = hxd.Window.getInstance();
	var connected = false;
	var id:Null<Int> = null;
	var touched:Bool = false;
	var sprites:Map<Int, Graphics> = new Map();
	#if MULTIPLAYER
	var ws:haxe.net.WebSocket;
	#end

	override function init() {
		trace("built at " + BuildInfo.getBuildDate());

		#if MULTIPLAYER
			ws = haxe.net.WebSocket.create("ws://127.0.0.1:8888");
			ws.onopen = function() ws.sendString(Serializer.run(Join));
			ws.onmessageString = function(msg) {
				var msg:Message = Unserializer.run(msg);
				switch msg {
					case Joined(id): this.id = id;
					case State(state): this.state = state;
				}
			}
		#else
			world = new World(s2d.width, s2d.height);
			id = world.createPlayer().id;
		#end

		window.addEventTarget(onEvent);
	}

	override function update(_) {
		#if MULTIPLAYER
			ws.process();
			if(state == null) return; // not ready
		#else
			state = world.update();
		#end

		// handle move
		var player = state.objects.find(function(o) return o.id == id);
		if(player != null) {
			// move player
			if(touched) {
				// https://math.stackexchange.com/questions/1201337/finding-the-angle-between-two-points
				var dir = Math.atan2(window.mouseY - player.y, window.mouseX - player.x);
				#if MULTIPLAYER
					if(player.speed == 0) ws.sendString(Serializer.run(StartMove));
					ws.sendString(Serializer.run(SetDirection(dir)));
				#else
					player.speed = 3;
					player.dir = dir;
				#end
			} else {
				#if MULTIPLAYER
					if(player.speed != 0) ws.sendString(Serializer.run(StopMove));
				#else
					player.speed = 0;
				#end
			}
		}

		for(object in state.objects) {
			if(!sprites.exists(object.id)) {
				var size = 100;
				var g = new Graphics(s2d);
				g.beginFill(object.color);
				g.drawCircle(0, 0, size/2);
				g.endFill();

				if (object.id == id) {
					g.beginFill(0x000000);
					g.drawCircle(0, 0, 20);
					g.endFill();
				}
				sprites.set(object.id, g);
			}
			var sprite = sprites.get(object.id);
			sprite.scaleX = sprite.scaleY = object.size / 100;
			sprite.x = object.x;
			sprite.y = object.y;
		}
		
		for(objectId in sprites.keys()) {
			if(!state.objects.exists(function(obj) return obj.id == objectId)) {
				sprites.get(objectId).remove();
				sprites.remove(objectId);
			}
		}
	}

	function onEvent(event:Event) {
		switch(event.kind) {
			case EPush:
				touched = true;
			case ERelease, EReleaseOutside:
				touched = false;
			case _: //pass
		}
	}

	static function main():Void {
		h3d.Engine.ANTIALIASING = 1;
		new Main();
	}

}
