package mantle.managers.initialize;
import mantle.managers.state.StateManager;

/**
 * ...
 * @author P.J.Shand
 */
class InitializeManager 
{
	public function new() 
	{
		
	}
	
	public static function define(parent:Dynamic, view:Class<Dynamic>, stateManager:StateManager, params:Array<Dynamic>=null):DefinitionObject 
	{
		return new DefinitionObject(parent, view, stateManager, params);
	}
}