package robotlegs.extensions.impl.commands.assets;

import mantle.util.assets.BitmapDataEmbedder;
import mantle.util.time.EnterFrame;
import robotlegs.bender.bundles.mvcs.Command;
import robotlegs.extensions.impl.services.startup.StartupService;
import robotlegs.extensions.impl.signals.startup.AssetsReadySignal;
import robotlegs.extensions.impl.signals.startup.ConfigReadySignal;

using Logger;

/**
 * ...
 * @author Thomas Byrne
 */
class SetupAssetsCommand extends Command
{
	@inject var assetsReady:AssetsReadySignal;
	@inject var startupService:StartupService;
	@inject var configReadySignal:ConfigReadySignal;
	
	public function new() 
	{
		
	}
	
	override public function execute():Void
	{
		startupService.addStartupSignal(assetsReady);
		startupService.addStartupSignal(configReadySignal);
		
		// delay to allow other things to be mapped first
		EnterFrame.delay(BitmapDataEmbedder.init.bind(onBitmapsReady));
	}
	
	function onBitmapsReady() 
	{
		//info("Fonts loaded");
		assetsReady.dispatch();
	}
	
}