package robotlegs.extensions.impl.services.keyboard;

import mantle.time.EnterFrame;
import openfl.errors.Error;
import openfl.events.EventDispatcher;
import openfl.events.KeyboardEvent;
import org.swiftsuspenders.utils.CallProxy;
import robotlegs.bender.extensions.contextView.ContextView;
import robotlegs.extensions.api.services.keyboard.IKeyboardMap;
import robotlegs.extensions.impl.services.keyboard.BooleanMap.BoolMap;

/**
 * @author P.J.Shand
 */

@:rtti
@:keepSub
class KeyboardMap extends EventDispatcher implements IKeyboardMap
{
	@inject public var contextView:ContextView;
	private var initiated:Bool = false;
	
	private var _keyLookup:Map<Int, Array<Shortcut>>;
	private var _charLookup:Map<String, Array<Shortcut>>;
	private var _shortcuts:Array<Shortcut>;
	
	public static var ACTION_DOWN:String = 'keyDown';
	public static var ACTION_UP:String = 'keyUp';
	private var _traceKeyIDs:Bool = false;
	
	private var strBooleanMaps = new Map<String,BoolMap>();
	private var intBooleanMaps = new Map<Int,BoolMap>();
	
	public function new()
	{
		super();
	}
	
	private function init():Void 
	{
		if (initiated) return;
		initiated = true;
		
		_shortcuts = new Array<Shortcut>();
		_keyLookup = new Map<Int,Array<Shortcut>>();
		_charLookup = new Map<String, Array<Shortcut>>();
		
		contextView.view.stage.addEventListener(KeyboardEvent.KEY_DOWN, OnKeyDown);
		contextView.view.stage.addEventListener(KeyboardEvent.KEY_UP, OnKeyUp);
	}
	
	private function OnKeyDown(e:KeyboardEvent):Void 
	{
		this.dispatchEvent(e);
		if (traceKeyIDs) trace("[KeyboardMap] Down: " + e.keyCode, String.fromCharCode(e.charCode).toLowerCase());
		
		executeList(_keyLookup[e.keyCode], e);
		executeList(_charLookup[String.fromCharCode(e.charCode).toLowerCase()], e);
	}
	
	private function OnKeyUp(e:KeyboardEvent):Void 
	{
		this.dispatchEvent(e);
		if (traceKeyIDs) trace("[KeyboardMap] Up: " + e.keyCode, String.fromCharCode(e.charCode).toLowerCase());
		executeList(_keyLookup[e.keyCode], e);
		executeList(_charLookup[String.fromCharCode(e.charCode).toLowerCase()], e);
	}
	
	public function onDown(callback:Dynamic, charOrKeycode:Dynamic, options:Dynamic = null):Void
	{
		new MapOnDown(this, execute, callback, charOrKeycode, options);
	}
	
	public function map(callback:Dynamic, charOrKeycode:Dynamic, options:Dynamic = null):Void
	{
		init();
		if (Std.is(charOrKeycode, String)) {
			if (cast(charOrKeycode, String).length == 1) addCharShortcut(callback, cast(charOrKeycode, String), options);
			else {
				var keyboardWord = new KeyboardWord(this, callback, cast(charOrKeycode, String), options);
			}
		}
		else if (Std.is(charOrKeycode, Int)) addKeyShortcut(callback, cast(charOrKeycode, Int), options);
		else {
			throw new Error("unknown charOrKeycode type, should be String or Int");
		}
	}
	
	public function mapBool(object:Dynamic, property:String, charOrKeycode:Dynamic, options:Dynamic = null):Void 
	{
		if (Std.is(charOrKeycode, String)) booleanMapStr(cast(charOrKeycode)).map(object, property, charOrKeycode, options);
		else if (Std.is(charOrKeycode, Int)) booleanMapInt(cast(charOrKeycode)).map(object, property, charOrKeycode, options);
	}
	
	private function booleanMapStr(charOrKeycode:String):BoolMap 
	{
		if (strBooleanMaps.get(charOrKeycode) == null) {
			strBooleanMaps[charOrKeycode] = new BoolMap(this);
		}
		return strBooleanMaps[charOrKeycode];
	}
	
	private function booleanMapInt(charOrKeycode:Int):BoolMap 
	{
		if (intBooleanMaps.get(charOrKeycode) == null) {
			intBooleanMaps[charOrKeycode] = new BoolMap(this);
		}
		return intBooleanMaps[charOrKeycode];
	}
	
	private function addCharShortcut(callback:Dynamic, char:String, options:Dynamic=null):Void {
		addShortcut(callback, [char], [], String, options);
	}
	
	private function addKeyShortcut(callback:Dynamic, key:Int, options:Dynamic=null):Void {
		addShortcut(callback, [], [key], Int, options);
	}
	
	private function addShortcut(callback:Dynamic, chars:Array<String>, keys:Array<Int>, type:Dynamic, options:Dynamic = null):Void 
	{	
		var ctrl = false;
		var alt = false;
		var shift = false;
		var action = KeyboardMap.ACTION_UP;
		var params:Dynamic = null;
		
		if (options != null) {
			if (CallProxy.hasField(options, 'ctrl')) ctrl = Reflect.getProperty(options, 'ctrl');
			if (CallProxy.hasField(options, 'alt')) alt = Reflect.getProperty(options, 'alt');
			if (CallProxy.hasField(options, 'shift')) shift = Reflect.getProperty(options, 'shift');
			if (CallProxy.hasField(options, 'action')) action = Reflect.getProperty(options, 'action');
			if (CallProxy.hasField(options, 'params')) params = Reflect.getProperty(options, 'params');
		}
		
		var shortcut = new Shortcut(callback, chars, keys, type, ctrl, alt, shift, action, params);
		for (char in chars) {
			_charLookup[char] = addToList(_charLookup, char, shortcut);
		}
		for (key in keys) {
			_keyLookup[key] = addToList(_keyLookup, key, shortcut);
		}
		
		
	}
	
	private function executeList(shortcuts:Array<Shortcut>, e:KeyboardEvent):Void 
	{
		if (shortcuts == null) return;
		
		for (shortcut in shortcuts) {
			if (shortcut.ctrl == e.ctrlKey && shortcut.shift == e.shiftKey && shortcut.alt == e.altKey && shortcut.action == e.type) {
				KeyboardMap.execute(shortcut.callback, shortcut.params);	
			}
		}
	}
	
	private static function execute(callback:Dynamic, params:Dynamic):Void
	{
		if (params != null) {
			if (Std.is(params, Array)) {
				var array:Array<Dynamic> = untyped params;
				switch array.length {
					case 0: callback();
					case 1: callback(params[0]);
					case 2: callback(params[0], params[1]);
					case 3: callback(params[0], params[1], params[2]);
					case 4: callback(params[0], params[1], params[2], params[3]);
					case 5: callback(params[0], params[1], params[2], params[3], params[4]);
					case 6: callback(params[0], params[1], params[2], params[3], params[4], params[5]);
					case 7: callback(params[0], params[1], params[2], params[3], params[4], params[5], params[6]);
					case 8: callback(params[0], params[1], params[2], params[3], params[4], params[5], params[6], params[7]);
				}
			}
			else {
				callback(params);
			}
		}
		else callback();
	}
	
	private function addToList(lookup:Dynamic, key:Dynamic, shortcut:Shortcut):Array<Shortcut> 
	{
		//_keyLookup:Map<Int, Array<Shortcut>>;
		//var _charLookup:;
		//_charLookup.
		
		var list:Array<Shortcut> = null;
		if (Std.is(key, String)) {
			var _lookupStr:Map<String, Array<Shortcut>> = cast(lookup);
			if (_lookupStr != null) list = _lookupStr.get(key);
		}
		else if (Std.is(key, Int)) {
			var _lookupInt:Map<Int, Array<Shortcut>> = cast(lookup);
			if (_lookupInt != null) list = _lookupInt.get(key);
		}
		//var list:Array<Shortcut> = lookup[key];
		if (list == null) list = new Array<Shortcut>();
		list.push(shortcut);
		return list;
	}
	
	public var traceKeyIDs(get, set):Bool;
	
	public function get_traceKeyIDs():Bool 
	{
		return _traceKeyIDs;
	}
	
	public function set_traceKeyIDs(value:Bool):Bool 
	{
		_traceKeyIDs = value;
		return value;
	}
}

class Shortcut {
	var type:Dynamic;
	
	public var callback:Dynamic;
	
	public var ctrl:Bool;
	public var shift:Bool;
	public var alt:Bool;
	public var action:String;
	public var params:Dynamic;
	
	public var chars:Array<String>;
	public var keys:Array<Int>;
	
	public function new(callback:Dynamic, chars:Array<String>, keys:Array<Int>, type:Dynamic, ctrl:Bool, alt:Bool, shift:Bool, action:String, params:Dynamic)
	{	
		this.callback = callback;
		this.chars = chars;
		this.keys = keys;
		this.type = type;
		this.ctrl = ctrl;
		this.alt = alt;
		this.shift = shift;
		this.action = action;
		this.params = params;
	}
}

class KeyboardWord
{
	private var count:Int = 0;
	private var split:Array<String>;
	private var callback:Dynamic;
	private var params:Dynamic;
	
	public function new(keyboardMap:KeyboardMap, callback:Dynamic, charOrKeycode:String, options:Dynamic = null)
	{
		if (options != null) {
			//params = options["params"];
			params = Reflect.getProperty(options, "params");
		}
		else {
			options = {};
		}
		
		this.callback = callback;
		split = charOrKeycode.split("");
		for (i in 0...split.length)
		{
			//options["params"] = [i];
			Reflect.setProperty(options, "params", [i]);
			keyboardMap.map(CountFunction, split[i], options );
		}	
		keyboardMap.addEventListener(KeyboardEvent.KEY_UP, OnKeyUp);
	}
	
	private function OnKeyUp(e:KeyboardEvent):Void 
	{
		var character:String = String.fromCharCode(e.charCode);
		for (i in 0...split.length)
		{
			if (split[i] == character) return;
		}
		count = 0;
	}
	
	private function CountFunction(index:Int):Void 
	{
		if (count == index) {
			count++;
			if (count == split.length) {
				count = 0;
				if (params != null) callback(params);
				else callback();
			}
		}
	}
}

class MapOnDown
{
	private var keyboardMap:IKeyboardMap;
	private var callback:Dynamic;
	private var charOrKeycode:Dynamic;
	private var options:Dynamic;
	private var execute:Dynamic -> Dynamic -> Void;
	
	public function new(keyboardMap:IKeyboardMap, execute:Dynamic -> Dynamic -> Void, callback:Dynamic, charOrKeycode:Dynamic, options:Dynamic = null)
	{
		this.keyboardMap = keyboardMap;
		this.execute = execute;
		this.callback = callback;
		this.charOrKeycode = charOrKeycode;
		this.options = options;
		
		keyboardMap.map(OnPress, charOrKeycode, { action:KeyboardMap.ACTION_DOWN } );
		keyboardMap.map(OnRelease, charOrKeycode, { action:KeyboardMap.ACTION_UP } );
	}
	
	function OnPress() 
	{
		EnterFrame.add(OnTick);
	}
	
	function OnRelease() 
	{
		EnterFrame.remove(OnTick);
	}
	
	function OnTick() 
	{
		execute(callback, options.params);
	}
}