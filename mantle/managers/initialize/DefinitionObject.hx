package mantle.managers.initialize;

import mantle.managers.state.StateManager;
import msignal.Signal.Signal0;

/**
 * ...
 * @author P.J.Shand
 */

class DefinitionObject
{
	var parent:Dynamic;
	var ViewClass:Class<Dynamic>;
	var stateManager:StateManager;
	var params:Array<Dynamic>;
	var onActive:Signal0;
	
	public function new(parent:Dynamic, ViewClass:Class<Dynamic>, stateManager:StateManager, params:Array<Dynamic>=null) 
	{
		this.parent = parent;
		this.ViewClass = ViewClass;
		this.stateManager = stateManager;
		this.params = params;
		if (this.params == null) {
			this.params = [];
		}
		
		onActive = Reflect.getProperty(stateManager, "onActive");
		onActive.addOnce(initialize);
		var result:Bool = stateManager.check();
		if (result) {
			onActive.remove(initialize);
			initialize();
		}
	}
	
	public function initialize():Void
	{
		onActive.remove(initialize);
		var sceneView:Dynamic = Type.createInstance(ViewClass, params);
		Reflect.callMethod(parent, parent.addChild, [sceneView]);
	}
	
}