package mantle.util.assets;
import com.imagination.texturePacker.api.convert.starling.IStarlingPackage;
import openfl.display.BitmapData;
import openfl.utils.Dictionary;
import starling.textures.Texture;
#if swc
import org.osflash.signals.Signal;
#else
import msignal.Signal.Signal0;
#end
import starling.textures.TextureAtlas;

/**
 * ...
 * @author Michal Moczynski
 */
class AssetsManager
{
//	static private var textures:Array<Texture> = new Array<Texture>();
	static private var textures:Map<String, Texture> = new Map();
	static private var atlases:Array<TextureAtlas> = [];
	static private var starlingPackages:Array<IStarlingPackage>;
	#if swc
	static public var texturesReady:Signal = new Signal();
	#else
	static public var texturesReady:Signal0 = new Signal0();
	#end	
	static public var ready:Bool;

	public function new():Void
	{
		
	}
	
	public static function get( id:String ):Texture
	{
		if (hasTexture(id)){
			return getTexture(id);
		}else{
			for (pack in starlingPackages){
				var texture = pack.textureByName(id);
				if (texture != null) return texture;
			}
		}
		return null;
	}
	
	public static function getTexture( id:String ):Texture
	{
		if ( textures[id] != null )
		{
			return textures[id];
		}
		
		for (i in 0...atlases.length) 
		{
			var t:Texture = atlases[i].getTexture(id);
			if (t != null) return t;
		}
		return null;
	}

	public static function hasTexture( id:String ):Bool
	{
		if (textures.exists(id) == true) return true;
		for (i in 0...atlases.length) 
		{
			var t:Texture = atlases[i].getTexture(id);
			if (t != null) return true;
		}
		return false;
	}

	public static function addTextureFromBitmapData( bmpDta:BitmapData, id:String ):Void
	{
		if ( textures[id] != null )
		{
			
		}
		else
		{
			textures[id] = Texture.fromBitmapData( bmpDta, bmpDta.width <= 2048 && bmpDta.height <= 2048  );
		}
		
	}
	
	static public function addTextureAtlas(textureAtlas:TextureAtlas) 
	{
		atlases.push(textureAtlas);
	}
	
	static public function setStarlingPackages(value:Array<IStarlingPackage>) 
	{
		var valid = [];
		for (pack in value){
			if (pack != null) valid.push(pack);
		}
		starlingPackages = valid;
	}
	
}