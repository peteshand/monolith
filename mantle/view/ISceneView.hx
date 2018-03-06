package mantle.view;

import mantle.managers.state.StateManager;
import mantle.managers.transition.Transition;

/**
 * @author P.J.Shand
 */
interface ISceneView
{
	var transition:Transition;
	var state:StateManager;
}