/*  JSON_4Dstringify class
 Created by: Kirk as Designer, Created: 12/10/23, 09:03:14
 ------------------
return 4D code describing an object or collection
this code can be pasted into a method or class
doesn't handle: blobs, pointers, entities,
*/

Class constructor($src : Variant)
	This.code:=""
	
	If (Value type($src)=Is object)
		This.code:=This._encodeObject($src)
		return 
	End if 
	
	If (Value type($src)=Is collection)
		This.code:=This._encodeCollection($src)
		return 
	End if 
	
	This.code:="Unsurpported data"
	
	//mark:  --- 
Function _evalValue($value) : Text
	Case of 
		: (Value type($value)=Is object)
			return This._encodeObject($value)
		: (Value type($value)=Is collection)
			return This._encodeCollection($value)
		Else 
			return This._encodeValue($value)
	End case 
	
Function _encodeObject($obj : Object) : Text
	var $code; $key : Text
	
	If ($obj=Null) || (OB Is empty($obj))
		return "{}"
	End if 
	
	For each ($key; $obj)
		$code+=($code#"" ? "; \\ \n" : "")
		$code+=$key+":"+This._evalValue($obj[$key])
	End for each 
	
	return "{"+$code+"}"
	
Function _encodeCollection($col : Collection) : Text
	var $code; $key : Text
	var $value : Variant
	
	If ($col=Null) || ($col.length=0)
		return "[]"
	End if 
	
	For each ($value; $col)
		$code+=($code#"" ? "; \\ \n" : "")
		$code+=This._evalValue($value)
	End for each 
	
	return "["+$code+"]"
	
Function _encodeValue($value) : Variant
	// return a value we can paste into the method
	Case of 
		: (Value type($value)=Is text)
			return "\""+$value+"\""
		: (Value type($value)=Is date)
			return "!"+String($value)+"!"
		: (Value type($value)=Is longint)\
			 || (Value type($value)=Is integer)\
			 || (Value type($value)=Is real)\
			 || (Value type($value)=Is time)\
			 || (Value type($value)=Is boolean)
			return String($value)
			
		Else   // unsupported value type
			return "\"[unsupported value type]\""
	End case 