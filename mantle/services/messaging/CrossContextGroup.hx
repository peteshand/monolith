package mantle.services.messaging;

import msignal.Signal.AnySignal;
import msignal.Signal.Signal1;
import openfl.events.Event;
import openfl.events.EventDispatcher;

/**
 * ...
 * @author pjshand
 */
@:internal
class CrossContextGroup<Type1>
{
	public var groupID:String;
	private var signal = new Signal1<Type1>();
	public var valueClasses(get, set):Type1;
	
	public function new(groupID:String)
	{
		this.groupID = groupID;
	}
	
	public function add(listener:Type1->Void):Void
	{
		signal.add(listener);
	}
	
	public function addOnce(listener:Type1->Void):Void
	{
		signal.addOnce(listener);
	}
	
	public function dispatch(value:Type1):Void
	{
		signal.dispatch(value);
	}
	
	public function remove(listener:Type1->Void):Void
	{
		signal.remove(listener);
	}
	
	public function removeAll():Void
	{
		signal.removeAll();
	}
	
	public function get_valueClasses():Type1
	{
		return cast signal.valueClasses;
	}
	
	public function set_valueClasses(value:Type1):Type1
	{
		signal.valueClasses = cast value;
		return value;
	}
}