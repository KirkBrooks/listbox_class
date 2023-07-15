/*  UnitTest class
 Created by: Kirk as Designer, Created: 07/12/23, 15:44:50
 ------------------

$class.expect(<some value>).toEqual(<value or formula>)

*/
Class extends ObjectProto

Class constructor($description : Text)
	Super()
	This._description:=$description
	This._error:=""
	This._formula:=Null
	This._expectValue:=Null
	This._expectValueKind:="undef"
	This._testValue:=Null
	This._result:=False  //  always boolean
	This.ms:=0
	
	//mark:  --- computed attributes
Function get pass : Boolean
	return Bool(This._result)
	
Function get isErr : Boolean
	return This._error#""
	
Function get displayline : Text
	//  return line of text suitable for display in a listbox or text field
	Case of 
		: (This.isErr)
			return "Err "+This._description+": "+String(This._error)
			
		: (This.pass)
			return "✅   "+This._description+"  ("+String(This.ms)+" ms)"
			
		Else 
			return "❌   "+This._description+"  ("+String(This.ms)+" ms)"
	End case 
	
	//mark:  --- Expect
Function expect($valueIn) : cs.UnitTest
	If (Value type($valueIn)=Is undefined)
		This._error:="Value in is undefined."
		return This
	End if 
	
	This._expectValue:=$valueIn
	This._expectValueKind:=This._valueKind($valueIn)
	return This
	
	//mark:  --- matchers
Function toEqual($input) : cs.UnitTest
/* scalar values - no objects or collections
expectedValue and $input must be the same: value and type
for strings this means they match exactly - e.g. case sensitive
- Use .toMatch() for objects and collections
*/
	This._equalTo($input)
	return This
	
Function notToEqual($input) : cs.UnitTest
	This._equalTo()
	This._result:=Not(This._result)
	return This
	
Function toBe($input) : cs.UnitTest
/*  .toBe() depends on the type of value
scalar:  same as toEqual()
object & collection:  means $input evaluates to the same reference as expected value
*/
	var $valueKind : Text
	$valueKind:=This._valueKind($input)
	
	Case of 
		: (This._isScalarValue(This._expectValue))
			return This.toEqual($input)
			
		: ($valueKind="object") && (OB Instance of($input; 4D.Function))  //  evaluate the formula
			This._result:=This.is(This._expectValue; This._eval($input; Copy parameters(2)))
			
		: ($valueKind="collection") && (OB Instance of($input; 4D.Function))  //  evaluate the formula
			This._result:=This.is(This._expectValue; This._eval($input; Copy parameters(2)))
			
		: ($valueKind="object") || ($valueKind="collection")
			This._result:=This.is(This._expectValue; $input)
			
		Else 
			This._error:="Incorrect input data type"
			This._result:=False
	End case 
	
	return This
	
Function toMatch($pattern) : cs.UnitTest
	// applies regex pattern to expectedValue
	
	If (This._expectValueKind#"text")
		This._error:="This test can only be applied to text values"
		This._result:=False
		return This
	End if 
	
	This._result:=Match regex($pattern; This._expectValue; 1)
	return This
	
Function toContain($obj) : cs.UnitTest
	// when the expected value is an object test it contains all the values in $obj
	If (This._expectValueKind#"object")
		This._result:=False
		return This
	End if 
	
	This._result:=This._objectContains(This._expectValue; $obj)
	return This
	
Function notToContain($obj) : cs.UnitTest
	// when the expected value is an object test all the values in $obj
	If (This._expectValueKind#"object")
		This._result:=False
		return This
	End if 
	
	This._result:=Not(This._objectContains(This._expectValue; $obj))
	return This
	
Function notToMatch($formula : 4D.Function) : cs.UnitTest
	var $params : Collection
	This._result:=Not(This.compare(This._expectValue; This._eval($formula; Copy parameters(2)); False))
	return This
	
Function toBeNull() : cs.UnitTest
	This._result:=This._expectValue=Null
	return This
	
Function notToBeNull() : cs.UnitTest
	This._result:=This._expectValue#Null
	return This
	
Function scalarToContain($value : Variant) : cs.UnitTest
	//  value in must be a scalar collection
	If (This._expectValueKind#"collection")
		This._error:="Incorrect expected value - must be scalar collection"
		return This
	End if 
	
	If (Not(This._isScalarValue($value)))
		This._error:="Value must be a number, date, boolean or text."
		return This
	End if 
	
	This._result:=This._expectValue.indexOf($value)>-1
	return This
	
	
	//mark:  --- privates
Function _equalTo($input)
	var $formula : 4D.Function
	var $valueKind : Text
	
	$valueKind:=This._valueKind($input)
	
	Case of 
		: (Not(This._isScalarValue($input)))
			This._error:="Incompatible data type - only scalar values supported."
			This._result:=False
			
		: ($valueKind="object") && (OB Instance of($input; 4D.Function))  //  evaluate the formula
			This._result:=This.compare(This._expectValue; This._eval($input; Copy parameters(2)); True)
			
		: ($valueKind#This._expectValueKind)
			This._error:="Expected value and input are different kinds. "
			This._result:=False
		Else 
			This._result:=This._expectValue=$input
	End case 
	
Function _valueKind($var) : Text
/* returns a text descriptor of the kind of $var
number, date, text, bool, object, collection, null, undef, other(blob, picture, pointer)
*/
	Case of 
		: (Value type($var)=Is undefined)
			return "undef"
		: (Value type($var)=Is object)
			return "object"
		: (Value type($var)=Is collection)
			return "collection"
		: (Value type($var)=Is boolean)
			return "bool"
		: (Value type($var)=Is date)
			return "date"
		: (Value type($var)=Is text)
			return "text"
		: (Value type($var)=Is real) || (Value type($var)=Is longint) || (Value type($var)=Is integer) || (Value type($var)=Is time)
			return "number"
		Else 
			return "other"
	End case 
	
Function _eval($formula : 4D.Function; $params : Collection)->$result : Variant
	var $ms : Integer
	
	$ms:=Milliseconds
	
	This._formula:=$formula
	
	If ($params.length=0)
		$params.push(This._expectValue)
	End if 
	
	$result:=$formula.apply(Null; $params)
	This.ms:=Milliseconds-$ms
	
Function _isScalarValue($value) : Boolean
	return (Value type($value)=Is real) || (Value type($value)=Is text) || (Value type($value)=Is longint) || (Value type($value)=Is date) || (Value type($value)=Is boolean)
	
Function _toEqualObject($obj : Object)
	//  compare $obj to This._expectValue
	
	If (This._expectValueKind#"object")
		This._result:=False
		return 
	End if 
	
	If (JSON Stringify(OB Keys(This._expectValue))#JSON Stringify(OB Keys($obj)))
		This._result:=False
		return 
	End if 
	
	This._result:=This._objectContains(This._expectValue; $obj)
	
Function _objectContains($a : Object; $b : Object) : Boolean
	// return True when $a contains the key:value pairs of $b
	var $key : Text
	
	For each ($key; $b)
		If (Not((This._valueKind($a[$key])=This._valueKind($b[$key])) && ($a[$key]=$b[$key])))
			return False
		End if 
	End for each 
	
	return True
	