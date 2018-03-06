package robotlegs.extensions.impl.signals;
import msignal.Signal;

/**
 * ...
 * @author P.J.Shand
 */
class ModifyConfigSignal extends Signal0
{
	
	public var values:Map<String, Dynamic>;
	public var reload:Bool;
	
	public function new() 
	{
		super();
	}
	
	public function setOne(prop:String, value:Dynamic, reload:Bool = false):Void {
		this.values = new Map();
		this.values[prop] = value;
		this.reload = reload;
		dispatch();
	}
	
	public function setMany(values:Map<String, Dynamic>, reload:Bool = false):Void {
		this.values = values;
		this.reload = reload;
		dispatch();
	}
}
