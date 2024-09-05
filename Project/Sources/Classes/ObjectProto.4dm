/*  ObjectProto class
 Created by: Kirk as Designer, Created: 05/27/23, 13:22:33
 ------------------
 Provide some missing functions on objects. 
It would be nice if this was exposed in 4D - but it's not
Note that you must pass in the object each of these functions applies to.
We are mimicking the behaviour and functions of the actual object proto class
the only way to have access to This, for instance, would be to instantiate this
class using composition - passing in the object at construction. 

=== Comparing Objects & collections ===
There are two ways to think about comparing objects: 
1) are the two references actually the same object
2) do the objects containt the same key:value pairs

If $a and $b are both references to the same object $a is $b and thus they are also equal
If $a and $b have the same keys and values they are equal, but actually two different objects

Comparisons involving objects with $useExact are True when $a IS $b
$a and $b are EQUAL when they have the same key:value pairs

*/
Class constructor
	
Function is($obj_a : Variant; $obj_b : Variant) : Boolean
	return (New collection($obj_a).indexOf($obj_b)>=0)
	
Function keys($obj : Object) : Collection
	return (Value type($obj)=Is object) ? OB Keys($obj) : New collection
	
Function values($obj : Object) : Collection
	return (Value type($obj)=Is object) ? OB Values($obj) : New collection
	
Function create($obj : Object) : Object
	return OB Copy($obj)
	
Function hasOwn($obj : Object; $property : Text) : Boolean
	// returns true if the specified property is a direct property of the object — even if the property value is null or undefined. 
	return $obj=Null ? False : OB Is defined($obj; $property)
	
Function defineProperty($obj : Object; $property : Text; $value)
	If ($obj#Null)
		$obj[$property]:=$value
	End if 
	
Function defineProperties($obj : Object; $properties : Object)
	// defines new or modifies existing properties directly on an object,
	var $key : Text
	
	If ($obj#Null)
		For each ($key; $properties)
			If (Value type($properties[$key])=Is object)
				$obj[$key]:=$obj[$key]=Null ? New object() : $obj[$key]
				
				This.defineProperties($obj[$key]; $properties[$key])
			Else 
				$obj[$key]:=$properties[$key]
			End if 
			
		End for each 
	End if 
	
Function fromEntries($entries : Collection)->$object : Object
	var $i : Integer
	var $collection : Collection
	$object:=New object()
	
	If ($collection.length>0) && ($collection.length%2=0)
		For ($i; 0; $collection.length-1; 2)
			$object[String($collection[$i])]:=$collection[$i+1]
		End for 
	End if 
	
Function objCompare($obj_a : Object; $obj_b : Object) : Object
	// recursively compares the object values
	var $keys_a; $keys_b : Collection
	var $key : Text
	
	If (This.is($obj_a; $obj_b))
		return New object("is"; True; "equal"; True)
	End if 
	
	$keys_a:=OB Keys($obj_a)
	If ($keys_a.length#OB Keys($obj_b).length)
		return New object("is"; False; "equal"; False)
	End if 
	
	For each ($key; $keys_a)
		Case of 
			: ($obj_b[$key]=Null)
				return New object("is"; False; "equal"; False)
				
			: (Value type($obj_a[$key])=Is object)
				If (Not(This.objCompare($obj_a[$key]; $obj_b[$key]).equal))
					return New object("is"; False; "equal"; False)
				End if 
				
			: (Value type($obj_a[$key])=Is collection)
				If (Not(This.colCompare($obj_a[$key]; $obj_b[$key]).equal))
					return New object("is"; False; "equal"; False)
				End if 
				
			Else 
				If (Not(This.compare($obj_a[$key]; $obj_b[$key])))
					return New object("is"; False; "equal"; False)
				End if 
		End case 
	End for each 
	
	return New object("is"; False; "equal"; True)
	
Function colCompare($col_a : Collection; $col_b : Collection) : Object
	If (This.is($col_a; $col_b))
		return New object("is"; True; "equal"; True)
	End if 
	
	If ($col_a.length#$col_b.length)
		return New object("is"; False; "equal"; False)
	End if 
	
	var $i : Integer
	
	For ($i; 0; $col_a.length-1)
		If (Not(This.compare($col_a[$i]; $col_b[$i])))
			return New object("is"; False; "equal"; False)
		End if 
	End for 
	
	return New object("is"; False; "equal"; True)
	
Function getObjectValueByPath($object : Object; $path : Text)->$value : Variant
/* Return the value in object by dot notation path
Supports getting values from a string path. For an entity this
can also be a path along a relation as long as it's a many to one
	
COLLECTIONS
3 syntax for collections:
 collection                            the collection is returned
 collection[n]                         n is the index. Returns null if invalid index
 collection[<property> = '<criteria>'] performs a simple query on <property> = criteria
	
The query returns only the first element found or null.
*/
	var $path_c : Collection
	var $property_t; $queryStr : Text
	var $done : Boolean
	var $i; $valueType : Integer
	ARRAY LONGINT($aLen; 0)
	ARRAY LONGINT($aPos; 0)
	
	$path_c:=Split string($path; "."; sk ignore empty strings+sk trim spaces)
	
	If ($path_c.length>0)
		$value:=$object
		
		For each ($property_t; $path_c) While ((Value type($value)#Is undefined) & (Not($done)))
			$i:=-1
			$queryStr:=""
			
			Case of 
				: (Match regex("(.+)\\[(\\d+)\\]"; $property_t; 1; $aPos; $aLen))  //  a collection index
					$i:=Num(Substring($property_t; $aPos{2}; $aLen{2}))
					$property_t:=Substring($property_t; $aPos{1}; $aLen{1})
					
				: (Match regex("(.+)\\[(.+)\\]"; $property_t; 1; $aPos; $aLen))  //    a collection query
					$queryStr:=Substring($property_t; $aPos{2}; $aLen{2})
					$property_t:=Substring($property_t; $aPos{1}; $aLen{1})
					
			End case 
			
			$valueType:=Value type($value)
			
			Case of 
				: ($valueType#Is object) & ($valueType#Is collection)
					$value:=$value[$property_t]
					$done:=True
					
				: ($i>-1)  //  collection index
					If ($i<=($value[$property_t].length-1))
						$value:=$value[$property_t][$i]
					Else 
						$value:=Null
					End if 
					
				: ($queryStr#"")
					var $temp_c : Collection
					$temp_c:=$value[$property_t]
					$temp_c:=$temp_c.query($queryStr)
					
					If ($temp_c.length>0)
						$value:=$temp_c[0]
					Else 
						$value:=Null
					End if 
					
				Else   //  return the collection or object
					$value:=$value[$property_t]
					
			End case 
		End for each 
		
	End if 
	
Function getObjectValueByColl($object : Object; $keys : Collection) : Variant
	//  returns for the path described by the colleciton
	var $container; $key : Variant
	$container:=$object
	
	For each ($key; $keys)
		Case of 
			: (Value type($key)=Is real) && (Value type($container)#Is collection) && Not(OB Instance of($container; 4D.EntitySelection))
				return Null
			: (Value type($key)=Is real) && ($container.length<($key+1))
				return Null
			Else 
				$container:=$container[$key]
		End case 
		
		If ($container=Null)
			break
		End if 
	End for each 
	
	return $container
	
Function compareStrings($str_a : Text; $str_b : Text; $options : Object) : Boolean
	var $const : Integer
	
	$const:=(Bool($options.strict)) ? sk strict : sk case insensitive
	$const+=(Bool($options.charCodes)) ? sk char codes : 0
	$const+=(Not(Bool($options.diacritical))) ? sk diacritic insensitive : 0
	
	return Compare strings($str_a; $str_b; $const)=0
	
Function compare($value_a; $value_b; $useExact : Boolean) : Boolean
/*  compares $value_a to $value_b
by default compares values to values
$useExact to 
*/
	var $valueType_a; $valueType_b : Integer
	var $options; $dataClass : Object
	
	$valueType_a:=Value type($value_a)
	$valueType_b:=Value type($value_b)
	
	Case of 
		: ($valueType_a=Is undefined) || ($valueType_b=Is undefined) || ($valueType_a#$valueType_b)
			return False
			
		: ($valueType_a=Is text)  //  uses compareStrings().  useExact to match case and diacriticals
			$options:=New object()
			If ($useExact)
				$options:=New object("diacritical"; True; "strict"; True)
			End if 
			
			return This.compareStrings($value_a; $value_b; $options)
			
		: ($valueType_a=Is longint) || ($valueType_a=Is date) || ($valueType_a=Is boolean) || ($valueType_a=Is time)
			return $value_a=$value_b
		: ($valueType_a=Is real)
			return Round($value_b; 14)=Round($value_a; 14)  // deal with rounding errors
			
		: ($valueType_a=Is picture)  //  uses Equal pictures
			var $picMask : Picture
			return Equal pictures($value_a; $value_b; $picMask)
			
		: ($valueType_b=Is object) && (OB Instance of($value_b; 4D.Entity))  //  comparing entities
			$dataClass:=$value_b.getDataClass()
			
			Case of 
				: (Not(OB Instance of($value_a; 4D.Entity)))
					return False  //  expected an object, not an entity
					
				: ($dataClass#$value_a.getDataClass())
					return False
					
				: ($value_b.getDataClass().getInfo().primaryKey=$value_a.getDataClass().getInfo().primaryKey)
					return True
					
			End case 
			
		: ($valueType_a=Is collection)  // exact match - order and content
			return Generate digest(JSON Stringify array($value_a); MD5 digest)=Generate digest(JSON Stringify array($value_b); MD5 digest)
			
		: ($valueType_b=Is object)
			return $useExact ? Bool(This.objCompare($value_a; $value_b).is) : Bool(This.objCompare($value_a; $value_b).equal)
			
		: ($valueType_b=Is collection)
			return $useExact ? Bool(This.colCompare($value_a; $value_b).is) : Bool(This.colCompare($value_a; $value_b).equal)
			
	End case 
	
	return False
	
	//mark:  --- private functions
Function _strIsInteger($str : Text) : Boolean
	//  true when all chars of $str are numbers
	var $pos; $len : Integer
	
	If (Count parameters=0)
		return 
	End if 
	
	If (Match regex("\\d+"; $str; 1; $pos; $len))
		return $len=Length($str)
	End if 
	