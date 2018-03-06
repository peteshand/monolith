package robotlegs.extensions.impl.commands.keyboard;
import mantle.util.app.App;
import mantle.time.GlobalTime;
import openfl.display.StageDisplayState;
import openfl.ui.Keyboard;
import robotlegs.bender.bundles.mvcs.Command;
import robotlegs.bender.extensions.contextView.ContextView;

import robotlegs.extensions.api.services.keyboard.IKeyboardMap;
using Logger;

/**
 * ...
 * @author P.J.Shand
 */
class BaseKeyCommand extends Command 
{
	@inject public var contextView:ContextView;
	@inject public var keyboardMap:IKeyboardMap;
	//@inject public var configModel:CoreConfigModel;
	
	public function new() { }
	
	override public function execute():Void
	{
		keyboardMap.map(App.exit, Keyboard.Q, { ctrl:true } );
		
		// Fullscreen is done on a per platform basis within platform-specific commands
		//keyboardMap.map(GoFullScreen, Keyboard.F, { ctrl:true } );
		keyboardMap.map(TimeOffset, Keyboard.MINUS, { shift:true, alt:true, params:[-1000] } );
		keyboardMap.map(TimeOffset, Keyboard.EQUAL, { shift:true, alt:true, params:[1000] } );
		keyboardMap.map(PausePlayback, Keyboard.NUMBER_8, { shift:true, alt:true, params:[false] } );
		keyboardMap.map(PausePlayback, Keyboard.NUMBER_9, { shift:true, alt:true, params:[true] } );
		
		keyboardMap.map(ResetTimeOffset, Keyboard.NUMBER_0, { shift:true, alt:true } );
		
		#if (debug && starling)
			keyboardMap.map(RefreshContext, Keyboard.C, { alt:true, ctrl:true, shift:true } );
			
			//keyboardMap.map(SaveToConfig, Keyboard.S, { alt:true, ctrl:true, shift:true } );
			//keyboardMap.map(SaveLocationToConfig, Keyboard.A, { alt:true, ctrl:true, shift:true } );
			
		#end
		
		keyboardMap.map(TestCriticalError, Keyboard.Q, { alt:true, ctrl:true, shift:true } );
	}
	
	function TestCriticalError() 
	{
		criticalError("Critical Error Test");
	}
	
	/*function SaveLocationToConfig() 
	{
		configModel.setLocation("test", "seed");
	}
	
	function SaveToConfig() 
	{
		configModel.set("test", "test");
	}*/
	
	#if starling
	function RefreshContext() 
	{
		starling.core.Starling.current.context.dispose();
	}
	#end
	
	function PausePlayback(value:Bool) 
	{
		GlobalTime.pause = value;
	}
	
	function TimeOffset(offset:Int) 
	{
		GlobalTime.offset += offset;
	}
	
	function ResetTimeOffset() 
	{
		GlobalTime.offset += 0;
	}
	
	/*private function GoFullScreen():Void 
	{
		#if air3
			contextView.view.stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
			
			if (contextView.view.stage.nativeWindow != null) {	//seems to be null on the tablet		
				contextView.view.stage.nativeWindow.activate();
			}
		#else
			contextView.view.stage.displayState = StageDisplayState.FULL_SCREEN;
		#end
	}*/
}