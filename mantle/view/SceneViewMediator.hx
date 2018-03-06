package mantle.view;
import mantle.managers.state.StateManager;
import mantle.time.Delay;
import robotlegs.bender.bundles.mvcs.Mediator;
import robotlegs.bender.extensions.mediatorMap.api.IMediatorMap;

/**
 * ...
 * @author P.J.Shand
 */
class SceneViewMediator extends Mediator 
{
	@inject public var view:ISceneView;
	@inject public var mediatorMap:IMediatorMap;
	private var stateManager:StateManager;
	
	public function new() { }	
	
	override public function initialize():Void
	{
		addStateManager();
	}
	
	function addStateManager() 
	{
		if (view.transition == null) Delay.nextFrame(addStateManager);
		else {
			stateManager = view.state;
			stateManager.attachTransition(view.transition);
			var active:Bool = stateManager.check();
			if (active) {
				view.transition.value = -1;
				view.transition.Show();
			}
		}
	}
	
	override public function destroy():Void
	{
		if (stateManager != null){
			stateManager.removeTransition(view.transition);
			stateManager.dispose();
		}
	}
}