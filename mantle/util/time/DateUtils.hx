package mantle.util.time;

/**
 * @author Michal Moczynski
 */

class DateUtils
{
	static public inline var SECOND:Float = 1000;
	static public inline var MINUTE:Float = 60 * SECOND;
	static public inline var HOUR:Float = 60 * MINUTE;
	static public inline var DAY:Float = 24 * HOUR;
	static public inline var WEEK:Float = 7 * DAY;
	static public inline var YEAR:Float = 365 * DAY;
	
	static var dayShort:Array<String> =[ "Sun", "Mon", "Tues", "Wed", "Thur", "Fri", "Sat" ];
	static var dayLong:Array<String> =[ "Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday" ];

	static var monthShort:Array<String> = [ "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec" ];
	static var monthLong:Array<String> = [ "January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December" ];
	
	static var monthByShort:Map<String, Int> = ["JAN"=>0, "FEB"=>1, "MAR"=>2, "APR"=>3, "MAY"=>4, "JUN"=>5, "JUL"=>6, "AUG"=>7, "SEP"=>8, "OCT"=>9, "NOV"=>10, "DEC"=>11];
	static var monthByName:Map<String, Int> = ["JANUARY"=>0, "FEBRUARY"=>1, "MARCH"=>2, "APRIL"=>3, "MAY"=>4, "JUNE"=>5, "JULY"=>6, "AUGUST"=>7, "SEPTEMBER"=>8, "OCTOBER"=>9, "NOVEMBER"=>10, "DECEMBER"=>11];
	static var timezoneData:Date;
	/**
	 * @return Returns the difference, in minutes, between universal time (UTC) and the computer's local time.
	 */
	public static function getLocalTimezoneOffset():Float
	{
		#if (flash || js)
			if (timezoneData == null) timezoneData = Date.now();
			return untyped (timezoneData).getTimezoneOffset();
		#end
	}
	public static function localToGlobal(time:Float):Float
	{
		return time + getLocalTimezoneOffset() * MINUTE;
	}
	public static function globalToLocal(time:Float):Float
	{
		return time - getLocalTimezoneOffset() * MINUTE;
	}
	public static function getTimezoneOffset(d:Date):Float
	{
		#if (flash || js)
			return untyped d.getTimezoneOffset();
		#else
			return 0;
		#end
	}
	
	public static function dateFromString( str:String ):Date
	{
		var strings:Array<String> = str.split( " " );
		if(strings.length == 1){
			strings = str.split( "T" );
			if (strings.length == 2){
				return dateTimeOffsetFromString(str);
			}
		}
		
		var year:Int = 0;
		var month:Int = 0;
		var dayOfMonth:Int = 0;
		var hour:Int = 0;
		var minutes:Int = 0;
		var seconds:Int = 0;
		
		if (strings.length < 4) strings = str.split("-");
		
		if (strings.length < 4) {
			
			return formatNotSupported();
		}
			
		for (i in 0 ... strings.length) 
		{
			strings[i] = strings[i].toUpperCase();
			
			if (monthByShort[ strings[i] ] != null)
				month = monthByShort[ strings[i] ];
			else if (monthByName[ strings[i] ] != null)
				month = monthByName[ strings[i] ];				
			else if(strings[i].indexOf(":") != -1)	//time
			{
				var timeStr:Array<String> = strings[i].split(":");
				hour = Std.parseInt( timeStr[0] );
				minutes = Std.parseInt( timeStr[1] );
				if(timeStr.length > 2)
					seconds = Std.parseInt( timeStr[2] );
			}
			else if(strings[i].length == 4)	//year
			{
				year = Std.parseInt(strings[i]);
			}
			else if(strings[i].length == 2)	//year
			{
				dayOfMonth = Std.parseInt(strings[i]);
			}
			
		}
		
		return new Date( year, month, dayOfMonth, hour, minutes, seconds );		
	}
	
	static private function dateTimeOffsetFromString(str:String) 
	{
		var localOffset = getLocalTimezoneOffset();
		if(str.charAt(str.length-1) == "Z"){
			var lastDot = str.lastIndexOf(".");
			if (lastDot == 19){
				// Example: 2016-10-11T12:25:21.968Z
				str = str.substr(0, lastDot);
				var hrs:Int = Std.int(Math.abs(localOffset) / 60);
				var mins:Int = Std.int(Math.abs(localOffset) - hrs * 60);
				if (localOffset > 0){
					str += "+" + pad(hrs) + ":" + pad(mins);
				}else{
					str += "-" + pad(hrs) + ":" + pad(mins);
				}
			}
		}
		// Example: 2016-06-23T00:00:00-04:00 or 2017-04-22T23:05:56+0000
		if ((str.length != 25 && str.length != 24) || str.charAt(10) != "T"){
			return formatNotSupported();
		}
		var year = Std.parseInt(str.substr(0, 4));
		var month = Std.parseInt(str.substr(5, 2))-1;
		var date = Std.parseInt(str.substr(8, 2));
		
		var hour = Std.parseInt(str.substr(11, 2));
		var mins = Std.parseInt(str.substr(14, 2));
		var secs = Std.parseInt(str.substr(17, 2));
		
		var zoneSign = str.substr(19, 1);
		var zoneHour;
		var zoneMins;
		if(str.substr(23, 1) == ":"){
			zoneHour = Std.parseInt(str.substr(20, 2));
			zoneMins = Std.parseInt(str.substr(23, 2));
		}else{
			zoneHour = 0;
			zoneMins = Std.parseInt(str.substr(20, 4));
		}
		
		var date = new Date(year, month, date, hour, mins, secs);
		
		var zoneOffset = ((zoneHour * 60) + zoneMins);
		if (zoneSign == "-") zoneOffset = -zoneOffset;
		
		//trace(getLocalTimezoneOffset());
		var zoneDif = localOffset - zoneOffset;
		
		if (zoneDif == 0){
			return date;
		}else{
			return Date.fromTime(date.getTime() + zoneDif * 60 * 1000);
		}
	}
	
	static private function pad(num:Int, count:Int=2) : String
	{
		var str = Std.string(num);
		while (str.length < count){
			str = "0" + str;
		}
		return str;
	}
	
	/*static public function twitterFormatDate( str:String ) :String
	{
		var date:Date = dateFromString( str );
		var result:String = DateTools.format( date, "%k:%M %p - %d %b %Y") + monthShortCamelByNumber[ date.getMonth() ] + " " + date.getFullYear();
		return result;
	}*/
	
	static private function formatNotSupported():Date
	{
		trace( "Format not supported" );
		return null;
	}
	
	// Taken from haxe.DateTools, added support for more standard tokens
	// compatible with the `strftime` standard format
	public static function format( d : Date, f : String ) : String {
		var r = new StringBuf();
		var p = 0;
		while( true ){
			var np = f.indexOf("%", p);
			if( np < 0 )
				break;

			r.addSub(f, p, np - p);
			var length = 1;
			if (f.charAt(np + 1) == "-") length++;
			r.add( __format_get(d, f.substr(np+1,length) ) );

			p = np+length+1;
		}
		r.addSub(f,p,f.length-p);
		return r.toString();
	}
	private static inline function __format_get( d : Date, e : String ) : String {
		return switch( e ){
			case "%":
				"%";
			case "C":
				untyped StringTools.lpad(Std.string(Std.int(d.getFullYear()/100)),"0",2);
			case "d":
				untyped StringTools.lpad(Std.string(d.getDate()),"0",2);
			case "-d":
				untyped Std.string(d.getDate());
			case "D":
				format(d,"%m/%d/%y");
			case "e":
				untyped Std.string(d.getDate());
			case "f":
				Std.string(d.getTime() % 1000);
			case "F":
				format(d,"%Y-%m-%d");
			case "H","k":
				untyped StringTools.lpad(Std.string(d.getHours()),if( e == "H" ) "0" else " ",2);
			case "-H":
				untyped Std.string(d.getHours());
			case "I","l":
				var hour = d.getHours()%12;
				untyped StringTools.lpad(Std.string(hour == 0 ? 12 : hour),if( e == "I" ) "0" else " ",2);
			case "-I":
				var hour = d.getHours()%12;
				untyped Std.string(hour == 0 ? 12 : hour);
			case "m":
				untyped StringTools.lpad(Std.string(d.getMonth() + 1), "0", 2);
			case "-m":
				untyped Std.string(d.getMonth()+1);
			case "M":
				untyped StringTools.lpad(Std.string(d.getMinutes()),"0",2);
			case "-M":
				untyped Std.string(d.getMinutes());
			case "n":
				"\n";
			case "p":
				untyped if( d.getHours() > 11 ) "pm"; else "am";
			case "P":
				untyped if( d.getHours() > 11 ) "PM"; else "AM";
			case "r":
				format(d,"%I:%M:%S %p");
			case "R":
				format(d,"%H:%M");
			case "s":
				Std.string(Std.int(d.getTime()/1000));
			case "S":
				untyped StringTools.lpad(Std.string(d.getSeconds()),"0",2);
			case "-S":
				untyped Std.string(d.getSeconds());
			case "t":
				"\t";
			case "T":
				format(d,"%H:%M:%S");
			case "u":
				untyped{
					var t = d.getDay();
					if( t == 0 ) "7"; else Std.string(t);
				}
			case "w":
				untyped Std.string(d.getDay());
			case "y":
				untyped StringTools.lpad(Std.string(d.getFullYear()%100),"0",2);
			case "Y":
				untyped Std.string(d.getFullYear());
			case "a":
				dayShort[d.getDay()];
			case "A":
				dayLong[d.getDay()];
			case "b":
				monthShort[d.getMonth()];
			case "B":
				monthLong[d.getMonth()];
			case "z":
				Std.string(getTimezoneOffset(d));
			case "-z":
				StringTools.lpad(Std.string(getTimezoneOffset(d)), "0", 4);
			case "Z":
				Std.string(getTimezoneOffset(d) / 60);
			case "-Z":
				Std.string(getTimezoneOffset(d) / 60);
				StringTools.lpad(Std.string(getTimezoneOffset(d) / 60), "0", 2);
			default:
				throw "Date.format %"+e+"- not implemented yet.";
		}
	}
	
	static var lastFormat:String;
	static var lastFormatEx:EReg;
	static var lastFormatParts:Array<FormatPart>;
	public static function parse( datetime : String, format : String ) : Date {
		var regex:EReg;
		var parts:Array<FormatPart>;
		if (lastFormat == format){
			regex = lastFormatEx;
			parts = lastFormatParts;
		}else{
			var p = 0;
			parts = [];
			while( true ){
				var np = format.indexOf("%", p);
				if( np < 0 )
					break;
				
				var length = 1;
				if (format.charAt(np + 1) == "-") length++;
				
				var part = format.substr(np+1, length);
				var reg:String = getRegEx(part, parts);
				
				length++; // To take the leading %
				format = format.substr(0, np) + reg + format.substr(np + length);
				np += (reg.length - part.length);
				
				p = np;
			}
			regex = new EReg(format, "");
			lastFormat = format;
			lastFormatEx = regex;
			lastFormatParts = parts;
		}
		if (regex.match(datetime.toUpperCase())){
			var year:Null<Int> = null, yearShort:Null<Int> = null, century:Null<Int> = null, month:Null<Int> = null, date:Null<Int> = null;
			var hour12:Null<Int> = null, hour24:Null<Int> = null, pm:Null<Bool> = null, millisecond:Float = 0; 
			for (i in 0 ... parts.length){
				var value:String = regex.matched(i + 1);
				var part = parts[i];
				switch(part){
					case FormatPart.CENTURY:
						century = Std.parseInt(value);
					case FormatPart.YEAR:
						year = Std.parseInt(value);
					case FormatPart.YEAR_SHORT:
						yearShort = Std.parseInt(value);
					case FormatPart.MONTH:
						month = Std.parseInt(value) - 1;
					case FormatPart.MONTH_SHORT:
						month = monthByShort.get(value);
					case FormatPart.MONTH_LONG:
						month = monthByName.get(value);
					case FormatPart.DATE:
						date = Std.parseInt(value);
					case FormatPart.HOUR_12:
						hour12 = Std.parseInt(value);
					case FormatPart.HOUR_24:
						hour24 = Std.parseInt(value);
					case FormatPart.MERIDIAN:
						pm = value == "PM";
					case FormatPart.MINUTE:
						millisecond += Std.parseInt(value) * MINUTE;
					case FormatPart.SECOND:
						millisecond += Std.parseInt(value) * SECOND;
					case FormatPart.MILLISECOND:
						millisecond += Std.parseInt(value);
					default:
						// ignore
				}
			}
			if (year == null && yearShort != null){
				if (century != null){
					year = century * 100 + yearShort;
				}else{
					var now = Date.now();
					var nowYear = now.getFullYear();
					var nowCentury = Math.round(nowYear / 100) * 100;
					if (nowYear % 100 < 50) nowCentury -= 100;
					var dif1 = Math.abs(nowYear - (yearShort + nowCentury));
					var dif2 = Math.abs(nowYear - (yearShort + nowCentury + 100));
					if (dif1 < dif2){
						year = yearShort + nowCentury;
					}else{
						year = yearShort + nowCentury + 100;
					}
				}
			}
			if (hour24 == null && hour12 != null && pm != null){
				hour24 = hour12 + (pm ? 12 : 0);
			}
			
			var dateReady = (year != null && month != null && date != null);
			var timeReady = (hour24 != null);
			
			if (!dateReady && !timeReady) return null;
			
			var minutes:Int = 0;
			var secs:Int = 0;
			if (timeReady){
				minutes = Std.int(millisecond / MINUTE);
				millisecond -= minutes * MINUTE;
				secs = Std.int(millisecond / SECOND);
				millisecond -= secs * SECOND;
			}else{
				hour24 = 0;
				millisecond = 0;
			}
			
			if (!dateReady){
				var now = Date.now();
				year = now.getFullYear();
				month = now.getMonth();
				date = now.getDate();
			}
			var ret = new Date(year, month, date, hour24, minutes, secs);
			#if (flash || js)
			untyped ret.setMilliseconds(millisecond);
			#end
			return ret;
			
		}else{
			// Format didn't match;
			return null;
		}
	}
	
	static private function getRegEx(part:String, parts:Array<FormatPart>) : String
	{
		return switch(part){
			case "%":
				"%";
			case "C":
				parts.push(FormatPart.CENTURY);
				"(\\d+)";
			case "d" | "-d" | "e":
				parts.push(FormatPart.DATE);
				"(\\d+)";
			case "D":
				getRegEx("%m", parts) + "/" + getRegEx("%d", parts) + "/" + getRegEx("%y", parts);
			case "f":
				parts.push(FormatPart.MILLISECOND);
				"(\\d+)";
			case "F":
				getRegEx("%Y", parts) + "-" + getRegEx("%m", parts) + "-" + getRegEx("%d", parts);
			case "H" | "-H":
				parts.push(FormatPart.HOUR_24);
				"(\\d+)";
			case "k":
				parts.push(FormatPart.HOUR_24);
				"( ?\\d+)";
			case "I" | "-I":
				parts.push(FormatPart.HOUR_12);
				"(\\d+)";
			case "l":
				parts.push(FormatPart.HOUR_12);
				"( ?\\d+)";
			case "m" | "-m":
				parts.push(FormatPart.MONTH);
				"(\\d+)";
			case "M" | "-M":
				parts.push(FormatPart.MINUTE);
				"(\\d+)";
			case "n":
				"\n";
			case "p" | "P":
				parts.push(FormatPart.MERIDIAN);
				"([AP]M)";
			case "r":
				getRegEx("%I", parts) + ":" + getRegEx("%M", parts) + ":" + getRegEx("%S", parts) + " " + getRegEx("%p", parts);
			case "R":
				getRegEx("%H", parts) + ":" + getRegEx("%M", parts);
			case "s" | "S" | "-S":
				parts.push(FormatPart.SECOND);
				"(\\d+)";
			case "t":
				"\t";
			case "T":
				getRegEx("%H", parts) + ":" + getRegEx("%M", parts) + ":" + getRegEx("%S", parts);
			case "u":
				parts.push(FormatPart.DAY_ONE);
				"(\\d+)";
			case "w":
				parts.push(FormatPart.DAY_ZERO);
				"(\\d+)";
			case "y":
				parts.push(FormatPart.YEAR_SHORT);
				"(\\d+)";
			case "Y":
				parts.push(FormatPart.YEAR);
				"(\\d+)";
			case "a":
				parts.push(FormatPart.DAY_SHORT);
				"(" + dayShort.join("|").toUpperCase() + ")";
			case "A":
				parts.push(FormatPart.DAY_LONG);
				"(" + dayLong.join("|").toUpperCase() + ")";
			case "b":
				parts.push(FormatPart.MONTH_SHORT);
				"(" + monthShort.join("|").toUpperCase() + ")";
			case "B":
				parts.push(FormatPart.MONTH_LONG);
				"(" + monthLong.join("|").toUpperCase() + ")";
			default:
				throw "Date.parse %"+part+"- not implemented yet.";
		}
	}
}

enum FormatPart
{
	CENTURY;
	DAY_ZERO;
	DAY_ONE;
	DAY_SHORT;
	DAY_LONG;
	DATE;
	MONTH;
	MONTH_SHORT;
	MONTH_LONG;
	YEAR;
	YEAR_SHORT;
	HOUR_24;
	HOUR_12;
	MERIDIAN;
	MINUTE;
	SECOND;
	MILLISECOND;
}