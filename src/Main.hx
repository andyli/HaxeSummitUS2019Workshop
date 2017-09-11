
import openfl.display.FPS;
import openfl.display.Sprite;
import openfl.geom.Point;
import openfl.events.Event;
import openfl.events.TouchEvent;
import openfl.events.MouseEvent;
import game.*;
using Lambda;

#if MULTIPLAYER
import haxe.Serializer;
import haxe.Unserializer;
import mp.Command;
import mp.Message;
#end

class Main extends Sprite {

	var world:World;
	var state:GameState;
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
		
		openfl.Lib.current.addChild(new FPS(10, 10, 0xffffff));
		
		stage.addEventListener(Event.ENTER_FRAME, update);
		// #if desktop
		stage.addEventListener(MouseEvent.MOUSE_DOWN, onmousedown);
		stage.addEventListener(MouseEvent.MOUSE_MOVE, onmousemove);
		stage.addEventListener(MouseEvent.MOUSE_UP, onmouseup);
		// #else
		// stage.addEventListener(TouchEvent.TOUCH_BEGIN, ontouchdown);
		// stage.addEventListener(TouchEvent.TOUCH_MOVE, ontouchmove);
		// stage.addEventListener(TouchEvent.TOUCH_END, ontouchup);
		// #end
	}
	
	var sprites = new Map();
	function update(_) {
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
				var dir = Math.atan2(cursor.y - stage.stageHeight / 2, cursor.x - stage.stageWidth / 2);
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
			this.scaleX = scale;
			this.scaleY = scale;
			this.x = stage.stageWidth / 2 - player.x * scale;
			this.y = stage.stageHeight / 2 - player.y * scale;
		}

		for(object in state.objects) {
			if(!sprites.exists(object)) {
				var sprite = new Sprite();
				sprites.set(object, sprite);
				sprite.graphics.beginFill(object.color);
				sprite.graphics.drawCircle(0, 0, 100);
				sprite.graphics.endFill();
				addChild(sprite);
			}
			var sprite = sprites.get(object);
			sprite.scaleX = sprite.scaleY = object.size / 100;
			sprite.x = object.x;
			sprite.y = object.y;
		}
		
		for(object in sprites.keys()) {
			if(!state.objects.exists(function(obj) return obj == object)) {
				removeChild(sprites.get(object));
				sprites.remove(object);
			}
		}
	} //update

	var touched:Bool = false;
	var cursor = new Point();
	function onmousedown(e:MouseEvent) {
		touched = true;
		cursor.setTo(e.stageX, e.stageY);
	}
	
	function onmousemove(e:MouseEvent) {
		cursor.setTo(e.stageX, e.stageY);
	}

	function onmouseup(_) {
		touched = false;
	}
	
	function ontouchdown(e:TouchEvent) {
		touched = true;
		cursor.setTo(e.stageX, e.stageY);
	}
	
	function ontouchmove(e:TouchEvent) {
		cursor.setTo(e.stageX, e.stageY);
	}

	function ontouchup(e) {
		touched = false;
	}

} //Main
