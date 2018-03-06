package mantle.util.font;
import openfl.Assets;
import starling.text.BitmapFont;
import starling.text.TextField;
import starling.textures.Texture;

/**
 * ...
 * @author P.J.Shand
 */
class FontUtil
{

	public function new() 
	{
		
	}
	
	static public function generateStarlingBMF(dir:String, fileName:String, size:Float, format:String="png"):BitmapFont
	{
		var fontPath:String = dir + "/" + fileName + "_" + size + "." + format;
		var xmlPath:String = dir + "/" + fileName + "_" + size + ".fnt";
		
		var texture:Texture = Texture.fromBitmapData(Assets.getBitmapData(fontPath), false);
        var xml:Xml = Xml.parse(Assets.getText(xmlPath)).firstElement();
		
        var bitmapFont = new BitmapFont(texture, xml);
		#if starling2
			TextField.registerCompositor(bitmapFont, bitmapFont.name);
		#else
			TextField.registerBitmapFont(bitmapFont, bitmapFont.name);
		#end
		return bitmapFont;
	}
	
}