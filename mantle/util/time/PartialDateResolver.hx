package mantle.util.time;

/**
 * ...
 * @author Thomas Byrne
 */
class PartialDateResolver
{
		
	private static var MINUTE_PARSER:EReg = ~/(\d\d)(?::(\d\d))?/;
	private static var TIME_PARSER:EReg = ~/(\d\d):(\d\d)(?::(\d\d))?/;
	private static var DAY_PARSER:EReg = ~/(\d\d) (\d\d):(\d\d)(?::(\d\d))?/;
	private static var MONTH_PARSER:EReg = ~/(\d\d)-(\d\d) (\d\d):(\d\d)(?::(\d\d))?/;
	private static var YEAR_PARSER:EReg = ~/(\d\d\d\d)-(\d\d)-(\d\d) (\d\d):(\d\d)(?::(\d\d))?/;
	
	
	public static function getTime(timecode:String):Float 
	{
		if (YEAR_PARSER.match(timecode)) {
			
			var date:Date = new Date(Std.parseInt(YEAR_PARSER.matched(1)),
									 Std.parseInt(YEAR_PARSER.matched(2)) - 1,
									 Std.parseInt(YEAR_PARSER.matched(3)),
									 Std.parseInt(YEAR_PARSER.matched(4)),
									 Std.parseInt(YEAR_PARSER.matched(5)),
									 getInt(YEAR_PARSER, 6));
			return date.getTime();
		}
		throw "Unreadable date format";
	}
	
	
	public static function getTriggerTime(fromTime:Float, timecode:String, ?looping:Looping, onlyAfter:Bool=true):Null<Float> 
	{
		var fromDate:Date = Date.fromTime(fromTime);
		var fullYear:Int = fromDate.getFullYear();
		var month:Int = fromDate.getMonth();
		var date:Int = fromDate.getDate();
		var day:Int = fromDate.getDay();
		var hours:Int = fromDate.getHours();
		var mins:Int = fromDate.getMinutes();
		var secs:Int = fromDate.getSeconds();
		
		var scopeHour:Bool = false;
		var scopeDate:Bool = false;
		var scopeMonth:Bool = false;
		var scopeYear:Bool = false;
		
		if (looping == null) looping = Looping.ONCE;
		
		switch(looping) {
			case Looping.HOURLY:
				if (MINUTE_PARSER.match(timecode)) {
					mins = Std.parseInt(MINUTE_PARSER.matched(1));
					secs = getInt(MINUTE_PARSER, 2);
					scopeHour = true;
				}else{
					return null;
				}
				
			case Looping.DAILY:
				if (TIME_PARSER.match(timecode)) {
					hours = Std.parseInt(TIME_PARSER.matched(1));
					mins = Std.parseInt(TIME_PARSER.matched(2));
					secs = getInt(TIME_PARSER, 3);
					scopeDate = true;
				}else{
					return null;
				}
				
			case Looping.WEEKLY:
				if (DAY_PARSER.match(timecode)) {
					var newDay:Int = Std.parseInt(DAY_PARSER.matched(1));
					if (newDay < day) {
						newDay += 7;
					}
					date += newDay - day;
					hours = Std.parseInt(DAY_PARSER.matched(2));
					mins = Std.parseInt(DAY_PARSER.matched(3));
					secs = getInt(DAY_PARSER, 4);
				}else{
					return null;
				}
				
			case Looping.MONTHLY:
				if (DAY_PARSER.match(timecode)) {
					date = Std.parseInt(DAY_PARSER.matched(1));
					hours = Std.parseInt(DAY_PARSER.matched(2));
					mins = Std.parseInt(DAY_PARSER.matched(3));
					secs = getInt(DAY_PARSER, 4);
					scopeMonth = true;
				}else{
					return null;
				}
				
			case Looping.YEARLY:
				if (MONTH_PARSER.match(timecode)) {
					month = Std.parseInt(MONTH_PARSER.matched(1)) - 1;
					date = Std.parseInt(MONTH_PARSER.matched(2));
					hours = Std.parseInt(MONTH_PARSER.matched(3));
					mins = Std.parseInt(MONTH_PARSER.matched(4));
					secs = getInt(MONTH_PARSER, 5);
					scopeYear = true;
				}else{
					return null;
				}
				
			case Looping.ONCE:
				if (YEAR_PARSER.match(timecode)) {
					fullYear = Std.parseInt(YEAR_PARSER.matched(1));
					month = Std.parseInt(YEAR_PARSER.matched(2)) - 1;
					date = Std.parseInt(YEAR_PARSER.matched(3));
					hours = Std.parseInt(YEAR_PARSER.matched(4));
					mins = Std.parseInt(YEAR_PARSER.matched(5));
					secs = getInt(YEAR_PARSER, 6);
				}else{
					return null;
				}
		}
		var ret:Date = new Date(fullYear, month, date, hours, mins, secs);
		if (onlyAfter && (scopeHour || scopeDate || scopeMonth || scopeYear) && fromDate.getTime() > ret.getTime()) {
			if (scopeHour) {
				hours++;
			}else if (scopeDate) {
				date++;
			}else if (scopeMonth) {
				month++;
			}else {
				fullYear++;
			}
			ret = new Date(fullYear, month, date, hours, mins, secs);
		}
		var retTime = ret.getTime();
		if (onlyAfter && retTime < fromTime){
			return null;
		}else{
			return retTime;
		}
	}
	
	/*@inline
	static private function match(reg:EReg, str:String):Array<String> 
	{
		var ret:Array<String> = [];
		while (reg.match(str) {
			ret.push(reg.matched();
		}
		return ret;
	}*/
	
	@inline
	static private function getInt(reg:EReg, ind:Int):Int 
	{
		try{
			var value:Dynamic = reg.matched(ind);
			if (value == null) {
				return 0;
			}else {
				return Std.parseInt(value);
			}
		}catch (e:Dynamic) {
			return 0;
		}
	}
	
}



@:enum
abstract Looping(String)
{
    var HOURLY = "hourly";
    var DAILY = "daily";
    var WEEKLY = "weekly";
    var MONTHLY = "monthly";
    var YEARLY = "yearly";
    var ONCE = "once";
}

abstract PartialDateTime(String) from String to String
{
	public function new(string:String) {
		this = string;
	}
}