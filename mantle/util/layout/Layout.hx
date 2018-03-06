package mantle.util.layout;
import mantle.util.geom.Matrix;
import mantle.util.geom.Rectangle;
import mantle.util.layout.LayoutEngine;
import mantle.util.ds.WeakMap;
import mantle.util.layout.Layout.ILayoutTracker;
import mantle.util.layout.LayoutEngine.ILayoutSizeProvider;
import mantle.util.layout.LayoutFrame;
import mantle.util.layout.StageSizeProvider;
import mantle.util.layout.adapters.DisplayListAdapter;
import mantle.util.layout.adapters.StarlingAdapter;

using Logger;

/**
 * ...
 * @author Thomas Byrne
 */
class Layout
{
	static private var inited:Bool;
	
	static private var rootToAddresses:Map<ILayoutAdapter, Map<String, LayoutFrame>>;
	static private var layoutToAddress:Map<LayoutFrame, String>;
	static private var stageSize:StageSizeProvider;
	
	static private var subjectSubjectTypes:Array<Class<Dynamic>>;
	static private var subjectAdapterTypes:Array<Class<Dynamic>>;
	
	static private var adapterLookup:WeakMap<Dynamic, ILayoutAdapter> = new WeakMap<Dynamic, ILayoutAdapter>();
	static private var engineLookup:Map<ILayoutAdapter, LayoutFrame> = new Map<ILayoutAdapter, LayoutFrame>();
	
	static private function init() 
	{
		if (inited) return;
		inited = true;
		
		stageSize = new StageSizeProvider();
		
		subjectSubjectTypes = [];
		subjectAdapterTypes = [];
		#if openfl
		subjectSubjectTypes.push(openfl.display.DisplayObject);
		subjectAdapterTypes.push(mantle.util.layout.adapters.DisplayListAdapter);
		#elseif flash
		subjectSubjectTypes.push(flash.display.DisplayObject);
		subjectAdapterTypes.push(mantle.util.layout.adapters.DisplayListAdapter);
		#end
		
		#if starling
		subjectSubjectTypes.push(starling.display.DisplayObject);
		subjectAdapterTypes.push(mantle.util.layout.adapters.StarlingAdapter);
		#end
		
		rootToAddresses = new Map<ILayoutAdapter, Map<String, LayoutFrame>>();
		layoutToAddress = new Map<LayoutFrame, String>();
	}
	public static function setNaturalSize(w:Float, h:Float) : Void
	{
		init();
		stageSize.setNaturalSize(w, h);
	}
	public static function add(subject:Dynamic) : ILayoutTracker
	{
		init();
		
		if (Std.is(subject, ILayoutAdapter)){
			return cast _addStrict(cast subject, false);
		}
		
		var layoutSubject:ILayoutAdapter;
		
		for (i in 0 ... subjectSubjectTypes.length) {
			var type = subjectSubjectTypes[i];
			if (Std.is(subject, type) ){
				var adapter = Type.createInstance(subjectAdapterTypes[i], [subject]);
				adapterLookup.set(subject, adapter);
				return untyped _addStrict(adapter, false);
			}
		}
		
		// Couldn't match to an adapter, attempt with subject
		//return untyped _addStrict(subject, false);
		Logger.warn(Layout, "Couldn't find adapter for display: " + Type.getClassName(Type.getClass(subject)) );
		return null;
	}
	public static function remove(subject:Dynamic, ?adapter:ILayoutAdapter) : Void
	{
		if (Std.is(subject, ILayoutAdapter)){
			return removeStrict(cast subject);
		}
		if(adapter == null){
			adapter = adapterLookup.get(subject);
			if (adapter == null){
				Logger.warn(Layout, "Couldn't find adapter for display: " + Type.getClassName(Type.getClass(subject)) );
				return;
			}
		}
		adapterLookup.remove(subject);
		removeStrict(adapter);
	}

	public static function addFrame(subject:Dynamic) : IFrameTracker
	{
		init();
		
		if (Std.is(subject, IFrameTracker)){
			return _addStrict(cast subject, true);
		}
		
		var layoutSubject:ILayoutAdapter;
		
		for (i in 0 ... subjectSubjectTypes.length) {
			var type = subjectSubjectTypes[i];
			if (Std.is(subject, type) ){
				return _addStrict(Type.createInstance(subjectAdapterTypes[i], [subject]), true);
			}
		}
		
		// Couldn't match to an adapter, attempt with subject
		//return _addStrict(subject, true);
		Logger.warn(Layout, "Couldn't find adapter for display: " + Type.getClassName(Type.getClass(subject)) );
		return null;
	}
	
	public static function addStrict(layoutSubject:ILayoutAdapter) : ILayoutTracker
	{
		return untyped _addStrict(layoutSubject, false);
	}
	public static function removeStrict(layoutSubject:ILayoutAdapter) : Void
	{
		var layout:Null<LayoutFrame> = engineLookup.get(layoutSubject);
		if (layout == null){
			Logger.warn(Layout, "Couldn't find layout for adapter: " + Type.getClassName(Type.getClass(layoutSubject)));
			if ( layoutSubject != null)
				layoutSubject.dispose();
			return;
		}
		engineLookup.remove(layoutSubject);
		removeLayout(layout);
	}

	static function _addStrict(layoutSubject:ILayoutAdapter, frame:Bool) : IFrameTracker
	{
		init();
		
		var address:String = getAddress(layoutSubject);
		
		var root = layoutSubject.stage;
		var addresses = rootToAddresses.get(root);
		var sizeProv:ILayoutSizeProvider = null;
		if (addresses==null) {
			addresses = new Map<String, LayoutFrame>();
			rootToAddresses.set(root, addresses);
		}else {
			sizeProv = findParent(addresses, address);
		}
		var level:Int = 0;
		var parent = layoutSubject.parent;
		while (parent != root) {
			level++;
			parent = parent.parent;
		}
		if (sizeProv == null) {
			sizeProv = stageSize;
		}
		if(frame){
			var ret = new LayoutFrame(layoutSubject, requestContext, sizeProv);
			engineLookup.set(layoutSubject, ret);
			ret.frame();
			return ret;
		}else {
			var engine = new LayoutEngine(layoutSubject, requestContext, sizeProv, level);
			engineLookup.set(layoutSubject, engine);
			return engine;
		}
	}
	
	static private function requestContext(from:LayoutFrame) 
	{
		var address:String = getAddress(from.layoutSubject);
		layoutToAddress.set(from, address);
		
		var root = from.layoutSubject.stage;
		var addresses = rootToAddresses.get(root);
		addresses.set(address, from);
	}
	
	static private function removeLayout(from:LayoutFrame) 
	{
		var address:String = layoutToAddress.get(from);
		if (address != null) {
			layoutToAddress.remove(from);
			
			var root = from.layoutSubject.stage;
			var addresses = rootToAddresses.get(root);
			addresses.remove(address);
			
			from.layoutSubject.dispose();
		}
		from.dispose();
	}
	
	static private function findParent(addresses:Map<String, LayoutFrame>, address:String) 
	{
		var bestMatch = null;
		var bestLength:Int = 0;
		for (addr in addresses.keys()) {
			if (address.indexOf(addr) == 0) {
				if (bestMatch==null || bestLength < addr.length) {
					bestMatch = addresses.get(addr);
					bestLength = addr.length;
				}
			}
		}
		return bestMatch;
	}
	
	static private function getAddress(layoutSubject:ILayoutAdapter) 
	{
		var addr:String = "";
		
		if (layoutSubject.parent == null){
			Logger.warn(Layout, "Attempting to get layout address of non-added display");
			return addr;
		}
		
		var root = layoutSubject.stage;
		while (layoutSubject.parent != root) {
			var ind = layoutSubject.parent.getChildIndex(layoutSubject);
			if (addr.length > 0) {
				addr = pad(ind, 5) + "_" + addr;
			}else {
				addr = Std.string(pad(ind, 5));
			}
			layoutSubject = layoutSubject.parent;
		}
		
		return addr;
	}
	
	static private function pad(num:Int, count:Int) : String
	{
		var ret:String = Std.string(num);
		while (ret.length < count) {
			ret = "0" + ret;
		}
		return ret;
	}
	
}

interface ILayoutAdapter
{
	var added(get, never):Bool;
	
	var width(get, set):Float;
	var height(get, set):Float;
	var transformationMatrix(get, set):Matrix;
	var clipRect(get, set):Rectangle;
	
	var stage(get, null):ILayoutAdapter;
	var parent(get, null):ILayoutAdapter;
	
	function dispose():Void;
	function forceRemove():Void;
	
	function getTransformationMatrix(targetSpace:Dynamic, ?resultMatrix:Matrix):Matrix;
	function getChildIndex(child:Dynamic):Int;
}

interface ILayoutTracker extends IFrameTracker
{
	function align(xFract:Float, yFract:Float, ?xOffset:Float, ?yOffset:Float) : ILayoutTracker;
	function alignOffset(xOffset:Float, yOffset:Float) : ILayoutTracker;
	
	function center(xFract:Float, yFract:Float, ?xOffset:Float, ?yOffset:Float) : ILayoutTracker;
	function centerOffset(xOffset:Float, yOffset:Float) : ILayoutTracker;
	
	function pos(x:Float, y:Float) : ILayoutTracker;
	
	function fill() : ILayoutTracker;
	function noScale() : ILayoutTracker;
	function scale(mode:LayoutScaleMode) : ILayoutTracker;
	function scaleX(mode:LayoutScaleMode) : ILayoutTracker;
	function scaleY(mode:LayoutScaleMode) : ILayoutTracker;
	
	function ratio(mode:LayoutRatioMode) : ILayoutTracker;
	function bounds(mode:LayoutBoundsMode) : ILayoutTracker;
	
	function update() : Void;
	function everyFrame() : ILayoutTracker;
	
	function remove() : Void;
	
	var alignXFract(get, set):Float;
	var alignYFract(get, set):Float;
	var alignXOffset(get, set):Float;
	var alignYOffset(get, set):Float;
	
	var centerXFract(get, set):Null<Float>;
	var centerYFract(get, set):Null<Float>;
	var centerXOffset(get, set):Float;
	var centerYOffset(get, set):Float;
	
}

interface IFrameTracker
{
	function pad(l:Float = 0, t:Float = 0, r:Float = 0, b:Float = 0) : IFrameTracker;
	function size(w:Float, h:Float) : IFrameTracker;
	function frame() : IFrameTracker;
	//function releaseFrame() : ILayoutTracker;
}

@:enum
abstract LayoutScaleMode(String) from String
{
    var UP_ONLY = "upOnly";
    var DOWN_ONLY = "downOnly";
    var ALWAYS = "always";
    var NEVER = "never";
}

@:enum
abstract LayoutRatioMode(String)
{
    var STRETCH = "stretch";
    var CROP = "crop";
    var PAD = "pad";
    var HORIZONTAL = "horizontal";
    var VERTICAL = "vertical";
}

@:enum
abstract LayoutBoundsMode(String)
{
    var OBJECT = "object";
    var NATURAL = "natural";
}

@:enum
abstract LayoutSpaceMode(String)
{
    var GLOBAL = "global";
    var LOCAL = "local";
    var INHERIT = "inherit";
}