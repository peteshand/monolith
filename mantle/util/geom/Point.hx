package mantle.util.geom;

/**
 * ...
 * @author Thomas Byrne
 */
#if openfl

import openfl.geom.Point as BasePoint;

#elseif flash

import flash.geom.Point as BasePoint;

#end

@:forward(x, y, length, copyFrom, distance, equals, normalize, offset, setTo, toString)
abstract Point(BasePoint) to BasePoint from BasePoint{
	
	public static var temp:Point = new BasePoint();
	static var pool:Array<Point> = [];
	
	
	public function new(x:Float = 0, y:Float = 0){
		if (pool.length > 0){
			this = pool.pop();
			this.setTo(x, y);
		}else{
			this = new BasePoint(x, y);
		}
	}
	
	public function add(v:Point, ?ret:Point):Point
	{
		if (ret == null) ret = new Point();
		ret.x = v.x + this.x;
		ret.y = v.y + this.y;
		return ret;
	}
	public function clone(?ret:Point):Point
	{
		if (ret == null) ret = new Point();
		ret.x = this.x;
		ret.y = this.y;
		return ret;
	}
	public function interpolate(pt1:Point, pt2:Point, f:Float, ?ret:Point):Point
	{
		if (ret == null) ret = new Point();
		ret.x = pt2.x + f * (pt1.x - pt2.x);
		ret.y = pt2.y + f * (pt1.y - pt2.y);
		return ret;
	}
	public function polar(len:Float, angle:Float, ?ret:Point):Point
	{
		if (ret == null) ret = new Point();
		ret.x = len * Math.cos (angle);
		ret.y = len * Math.sin (angle);
		return ret;
	}
	public function subtract(v:Point, ?ret:Point):Point
	{
		if (ret == null) ret = new Point();
		ret.x = this.x - v.x;
		ret.y = this.y - v.y;
		return ret;
	}
	
	public function returnToPool():Void{
		pool.push(this);
	}
}