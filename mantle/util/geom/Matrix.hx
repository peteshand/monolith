package mantle.util.geom;

import mantle.util.geom.Point;

/**
 * ...
 * @author Thomas Byrne
 */
 
#if openfl

import openfl.geom.Matrix as BaseMatrix;

#elseif flash

import flash.geom.Matrix as BaseMatrix;

#end

@:forward(a, b, c, d, tx, ty, clone, concat, copyColumnFrom, copyColumnTo, copyFrom, copyRowFrom, copyRowTo, createBox, createGradientBox, toString, setTo, scale, rotate, translate, invert, identity)
abstract Matrix(BaseMatrix) to BaseMatrix from BaseMatrix{
	
	public static var temp:Matrix = new BaseMatrix();
	static var pool:Array<Matrix> = [];
	
	
	public function new(a:Float = 1, b:Float = 0, c:Float = 0, d:Float = 1, tx:Float = 0, ty:Float = 0){
		if (pool.length > 0){
			this = pool.pop();
			this.setTo(a, b, c, d, tx, ty);
		}else{
			this = new BaseMatrix(a, b, c, d, tx, ty);
		}
	}
	public function deltaTransformPoint(pos:Point, ?ret:Point):Point{
		if (ret == null) ret = new Point();
		var px = pos.x;
		var py = pos.y;
		ret.x = px * this.a + py * this.c;
		ret.y = px * this.b + py * this.d;
		return ret;
	}
	public function transformPoint(pos:Point, ?ret:Point):Point{
		if (ret == null) ret = new Point();
		var px = pos.x;
		var py = pos.y;
		ret.x = px * this.a + py * this.c + this.tx;
		ret.y = px * this.b + py * this.d + this.ty;
		return ret;
	}
	
	public function returnToPool():Void{
		pool.push(this);
	}
}