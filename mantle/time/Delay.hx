/*The MIT License (MIT)

Copyright (c) 2015 P.J.Shand

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.*/

package mantle.time;

import haxe.Constraints.Function;

/**
 * ...
 * @author P.J.Shand
 */

class Delay 
{
	private static var delayObjects:Array<IDelayObject>;
	
	static function __init__() { 
       delayObjects = new Array<IDelayObject>();
	   EnterFrame.add(OnTick);
    }
	
	static private function OnTick() 
	{
		var i:Int = 0;
		while (i < delayObjects.length) 
		{
			if (delayObjects[i].complete) {
				delayObjects[i].dispatch();
				delayObjects.splice(i, 1);
			}
			else i++;
		}
	}
	
	public function new() { }
	
	public static function nextFrame(callback:Function, params:Array<Dynamic>=null):Void
	{
		Delay.byFrames(1, callback, params);
	}
	
	public static function byFrames(frames:Int, callback:Function, params:Array<Dynamic>=null):Void 
	{
		delayObjects.push(new FrameDelay(frames, callback, params));
	}
	
	public static function byTime(duration:Float, callback:Function, params:Array<Dynamic>=null, timeUnit:TimeUnit=null, precision:Bool=false):Void 
	{
		if (timeUnit == null) timeUnit = TimeUnit.SECONDS;
		delayObjects.push(new TimeDelay(duration, callback, params, timeUnit, precision));
	}
	
	public static function killDelay(callback:Function):Void 
	{
		var i = delayObjects.length - 1;
		while (i >= 0) {
			if (delayObjects[i].callback == callback) {
				delayObjects.splice(i, 1);
			}
			i--;
		}
	}
}