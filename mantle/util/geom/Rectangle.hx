package mantle.util.geom;

/**
 * ...
 * @author Thomas Byrne
 */
#if openfl

import openfl.geom.Rectangle as BaseRectangle;

#elseif flash

import flash.geom.Rectangle as BaseRectangle;

#end

@:forward()
abstract Rectangle(BaseRectangle) to BaseRectangle from BaseRectangle{
	
	public static var temp:Rectangle = new BaseRectangle();
	static var pool:Array<Rectangle> = [];
	
	
	public function new(x:Float = 0, y:Float = 0, width:Float = 0, height:Float = 0){
		if (pool.length > 0){
			this = pool.pop();
			this.setTo(x, y, width, height);
		}else{
			this = new BaseRectangle(x, y, width, height);
		}
	}
	
	public function clone (?ret:Rectangle):Rectangle {
		if (ret == null){
			ret = new Rectangle();
		}
		
		ret.setTo(this.x, this.y, this.width, this.height);
		return ret;
		
	}
	
	public function intersection (toIntersect:Rectangle, ?ret:Rectangle):Rectangle {
		
		if (ret == null){
			ret = new Rectangle();
		}
		
		var x0 = this.x < toIntersect.x ? toIntersect.x : this.x;
		var x1 = this.right > toIntersect.right ? toIntersect.right : this.right;
		
		if (x1 <= x0) {
			ret.setTo(0, 0, 0, 0);
			return ret;
			
		}
		
		var y0 = this.y < toIntersect.y ? toIntersect.y : this.y;
		var y1 = this.bottom > toIntersect.bottom ? toIntersect.bottom : this.bottom;
		
		if (y1 <= y0) {
			ret.setTo(0, 0, 0, 0);
			return ret;
		}
		ret.setTo(x0, y0, x1 - x0, y1 - y0);
		return ret;
		
	}
	
	public function union (toUnion:Rectangle, ?ret:Rectangle):Rectangle {
		
		if (ret == null) ret = new Rectangle();
		
		if (this.width == 0 || this.height == 0) {
			ret.setTo(toUnion.x, toUnion.y, toUnion.width, toUnion.height);
			return ret;
			
		} else if (toUnion.width == 0 || toUnion.height == 0) {
			ret.setTo(this.x, this.y, this.width, this.height);
			return ret;
			
		}
		
		var x0 = this.x > toUnion.x ? toUnion.x : this.x;
		var x1 = this.right < toUnion.right ? toUnion.right : this.right;
		var y0 = this.y > toUnion.y ? toUnion.y : this.y;
		var y1 = this.bottom < toUnion.bottom ? toUnion.bottom : this.bottom;
		
		ret.setTo(x0, y0, x1 - x0, y1 - y0);
		return ret;
		
	}
	
	public function returnToPool():Void{
		pool.push(this);
	}
	
	
}