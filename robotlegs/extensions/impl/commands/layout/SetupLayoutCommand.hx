package robotlegs.extensions.impl.commands.layout;

import mantle.util.geom.Rectangle;
import mantle.managers.layout2.LayoutManager;
import mantle.util.layout.Layout;
import robotlegs.bender.bundles.mvcs.Command;
import robotlegs.extensions.api.model.config.IConfigModel;

/**
 * ...
 * @author Thomas Byrne
 */
class SetupLayoutCommand extends Command
{
	
	@inject public var configModel:IConfigModel;

	public function new() 
	{
		
	}
	override public function execute():Void
	{
		if (configModel.naturalSize != null) {
			#if starling
			mantle.managers.layout2.LayoutManager.assetDimensions = new Rectangle(0, 0, configModel.naturalSize[0], configModel.naturalSize[1]);
			#end
			
			Layout.setNaturalSize(configModel.naturalSize[0], configModel.naturalSize[1]);
		}
	}
	
}