
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
	var stage = hxd.Stage.getInstance();
	var root:Sprite;
	var connected = false;
	var id:Null<Int> = null;
	#if MULTIPLAYER
	var ws:haxe.net.WebSocket;
	#end
	
	public function new() {
		super();
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
			world = new World();
			id = world.createPlayer().id;
		#end

		hxd.Stage.getInstance().addEventTarget(onEvent);
	}
	
	var sprites = new Map();
	override function update(_) {
		#if MULTIPLAYER
			ws.process();
			if(state == null) return; // not ready
		#else
			state = world.update();
		#end

		if (root == null) {
			root = new Sprite(s2d);
		}

		// handle move
		var player = state.objects.find(function(o) return o.id == id);
		if(player != null) {
			// move player
			if(touched) {
				var dir = Math.atan2(cursor.y - stage.height / 2, cursor.x - stage.width / 2);
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

			// update camera
			var scale = 40 / player.size;
			root.scaleX = root.scaleY = root.scaleX + (scale - root.scaleX) * 0.25;
			root.x = stage.width / 2 - player.x * root.scaleX;
			root.y = stage.height / 2 - player.y * root.scaleX;
		}

		for(object in state.objects) {
			if(!sprites.exists(object)) {
				var size = 100;
				var g = new Graphics(root);
				g.beginFill(object.color);
				g.drawCircle(0, 0, size/2);
				g.endFill();
				sprites.set(object, g);
			}
			var sprite = sprites.get(object);
			sprite.scaleX = sprite.scaleY = object.size / 100;
			sprite.x = object.x;
			sprite.y = object.y;
		}
		
		for(object in sprites.keys()) {
			if(!state.objects.exists(function(obj) return obj == object)) {
				sprites.get(object).remove();
				sprites.remove(object);
			}
		}
	} //update

	function onEvent(event:Event) {
		switch(event.kind) {
			case EMove:
				onmousemove();
			case EPush:
				onmousedown();
			case ERelease:
				onmouseup();
			case _: //pass
		}
	}

	var touched:Bool = false;
	var cursor = {x:0.0, y:0.0};
	function onmousedown() {
		touched = true;
		cursor.x = stage.mouseX;
		cursor.y = stage.mouseY;
	}
	
	function onmousemove() {
		cursor.x = stage.mouseX;
		cursor.y = stage.mouseY;
	}

	function onmouseup() {
		touched = false;
	}
	
	function ontouchdown() {
		touched = true;
		cursor.x = stage.mouseX;
		cursor.y = stage.mouseY;
	}
	
	function ontouchmove() {
		cursor.x = stage.mouseX;
		cursor.y = stage.mouseY;
	}

	function ontouchup() {
		touched = false;
	}

	static function main():Void {
		var e = new h3d.Engine(true, 4);
		e.onReady = function() {
			new Main();
		}
		e.init();
	}

}
