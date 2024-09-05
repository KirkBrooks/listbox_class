/*  UnitTest class
 Created by: Kirk as Designer, Created: 07/12/23, 15:44:50
 https://github.com/KirkBrooks/yaUT
 ------------------

$class.expect(<some value>).toEqual(<value or formula>)

*/
Class extends ObjectProto

Class constructor($description : Text)
	Super()
	This._description:=$description
	This._error:=$description="" ? "Constructor: A description is required" : ""
	This._expectValue:=Null
	This._expectFormula:=Null  //  formula of expected value
	This._expectValueKind:="undef"
	This._matcher:=""
	This._testValue:=Null  //  formula of test value
	This._testFormula:=Null
	This._testValueKind:="undef"
	This._result:=False  //  always boolean
	This.__not:=False
	This.ms:=0

	//mark:  --- computed attributes
Function get description : Text
	return This._description
Function get pass : Boolean
	return This.__not ? Not(This._result) : This._result
	
Function get isErr : Boolean
	return This._error#""
	
Function get error : Text
	return String(This._error)
	
Function get displayline : Text
	//  return line of text suitable for display in a listbox or text field
	Case of
		: (This.isErr)
			return "⚠️ "+This._description+": "+String(This._error)

		: (This.pass)
			return "✅   "+This._description+"  ("+String(This.ms)+" ms)"

		Else
			return "❌   "+This._description+"  ("+String(This.ms)+" ms)"
	End case 
	
Function get matcher : Text
	return This.__not ? "not."+This._matcher : This._matcher
	
	//mark:  --- Expect
Function expect() : cs.UnitTest
	If (This.isErr)
		return This
	End if 
	
	var $params : Collection
	$params:=Copy parameters
	
	If (Count parameters=0) || (Value type($params[0])=Is undefined)
		This._error:="Expect(): no parameters"
		return This
	End if 
	
	If (Value type($params[0])=Is object) && (OB Instance of($params[0]; 4D.Function))
		// evaluate the formula and use the result as the expected value
		This._expectFormula:=$params[0]
		This._expectValue:=This._eval($params)
		This._expectValueKind:=This._valueKind(This._expectValue)
		return This
	End if 
	
	This._expectValue:=$params[0]  //  any other params are ignored
	This._expectValueKind:=This._valueKind($params[0])
	return This

	//mark:  --- matchers
Function toEqual() : cs.UnitTest
/*  toEqual(<formula, value>; <params to formula>)
sets _testValue
_testValue must be the same kind as _expectedValue
value:   an object, collection or scalar value
formula: evaluates to _testValue
*/
	var $params : Collection
	$params:=Copy parameters
	
	This._matcher:="toEqual"
	If (Not(This._paramCheck($params)))
		return This
	End if 
	
	This._equalTo()
	return This
	
Function toBe() : cs.UnitTest
/*  .toBe() depends on the type of expectedValue and the parameters
	
expectedValue is scalar:  same as toEqual()
expectedValue is object, entity or collection and $1 is:
formula:  evaluate the formula and compare to exptectedValue
object:   compare properties of $1 to expectedValue object
	
*/
	var $params : Collection
	$params:=Copy parameters
	
	This._matcher:="toBe"
	If (Not(This._paramCheck($params)))
		return This
	End if 
	
	Case of 
		: (This._isScalarValue(This._expectValue))
			This._result:=This.compare(This._expectValue; This._testValue; True)  //  strict
			return This
			
		: (This._expectValueKind="object") || (This._expectValueKind="collection")
			This._result:=This.is(This._expectValue; This._testValue)
		Else 
			This._error:="toBe(): Incorrect input data type"
			This._result:=False
	End case

	return This

Function toMatch($pattern) : cs.UnitTest
	// applies regex pattern to expectedValue
	var $params : Collection
	var $pos; $len : Integer
	$params:=Copy parameters
	
	This._matcher:="toMatch"
	If (Not(This._paramCheck($params)))
		return This
	End if 

	This._result:=Match regex(This._testFormula; This._expectValue; 1; $pos; $len)
	This._testValue:=This._result ? Substring(This._expectValue; $pos; $len) : ""
	return This

Function toContain($obj) : cs.UnitTest
/* when expected value is an object:
  - if $1 is an object test expectedValue is an object too
          and expectedValue contains the same properties and values as $1
 when expected value is a collection:
  - if count parameters = 1 use expectedValue.indexOf
  - if count parameters = 2 use expectedValue.query($1+" = :1"; $2)
otherwise - data type mismatch
*/
	var $params : Collection
	$params:=Copy parameters
	
	This._matcher:="toContain"
	If (Not(This._paramCheck($params)))
		return This
	End if 
	
	If (This._expectValueKind#"object")
		This._result:=False
		return This
	End if 
	
	This._result:=This._objectContains(This._expectValue; This._testValue)
	return This

Function toBeNull() : cs.UnitTest
	If (This.isErr)
		return This
	End if 
	
	This._matcher:="toBeNull"
	This._result:=This._expectValue=Null
	return This
	
Function not() : cs.UnitTest
	//  reverse the result value
	If (This.isErr)
		return This
	End if 
	
	This.__not:=True
	return This
	
	//mark:  --- other functions
Function getExpectedValue : Variant
	return This._expectValue
	
Function getExpectedValueStr : Text
	return JSON Stringify(This._expectValue)
	
Function getTestValue : Variant
	return This._testValue
	
Function getTestValueStr : Variant
	return JSON Stringify(This._testValue)
	
	//mark:  --- privates
Function _paramCheck($params : Collection) : Boolean
	// error & param checking
	
	If (This.isErr)
		return False  //  stop at the first error
	End if 
	
	If ($params.length=0) || (Value type($params[0])=Is undefined)
		This._error:=This._matcher+": no parameters"
		return False
	End if 
	
	If (Value type($params[0])=Is object) && (OB Instance of($params[0]; 4D.Function))
		// evaluate the formula and use the result as the expected value
		This._testFormula:=$params[0]
		This._testValue:=This._eval($params)
		This._testValueKind:=This._valueKind(This._testValue)
		
		If (This._testValueKind#This._expectValueKind)
			This._error:=This._matcher+": expected value and test value are different types"
			return False
		End if 
		
		return True
	End if 

	If (This._matcher="toMatch")
		If (This._expectValueKind#"text")
			This._error:="toMatch(): This test can only be applied to text values"
			This._result:=False
			return False
		End if 

		//  input must be a regex pattern
		If (Value type($params[0])#Is text)
			This._error:="toMatch(): parameter must be text"
			This._result:=False
			return False
		End if 
		
		This._testFormula:=$params[0]
		This._testValueKind:="text"
		return True
	End if 
	
	This._testValue:=$params[0]  // any other parameters are ignored
	This._testValueKind:=This._valueKind(This._testValue)
	
	If (This._testValueKind#This._expectValueKind)
		This._error:=This._matcher+": expected value and test value are different types"
		return False
	End if 
	
	return True
	
Function _equalTo()
	var $result : Object
	
	Case of 
		: (This._testValueKind#This._expectValueKind)
			This._error:="_equalTo(): Expected value and test value are different data types. "
			This._result:=False
			
		: (This._expectValueKind="object")
			This._result:=This.objCompare(This._expectValue; This._testValue; True).equal
			
		: (This._expectValueKind="collection")
			This._result:=This.colCompare(This._expectValue; This._testValue; True).equal
			
		: (Not(This._isScalarValue(This._testValue)))
			This._error:="_equalTo(): Incompatible data type - only object, collection and scalar values supported."
			This._result:=False
			
		Else 
			This._result:=This._expectValue=This._testValue
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
	
Function _eval($params : Collection)->$result : Variant
	//  evaluate a formula. $params[0] must be the formula
	//  any other collection elements are passed into formula as parameters
	
	var $ms : Integer
	var $formula : 4D.Function
	
	$ms:=Milliseconds
	$formula:=$params.shift()  //  shift the first element to the variable
	$result:=$formula.apply(Null; $params)
	This.ms:=Milliseconds-$ms

Function _isScalarValue($value) : Boolean
	If ($value=Null)
		return False
	End if 

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

	// if the keys match we only need to check the values do too
	This._result:=This._objectContains(This._expectValue; $obj)

Function _objectContains($a : Object; $b : Object) : Boolean
	// return True when $a contains the key:value pairs of $b
	var $key : Text

	For each ($key; $b)
		If (Value type($a[$key])=Is null)
			return False
		End if 
		
		If (Not(This._valueKind($a[$key])=This._valueKind($b[$key])))
			return False
		End if 
		
		If (Value type($a[$key])=Is object) && (Not(This.objCompare($a[$key]; $b[$key]).equal))
			return False
		End if 
		
		If (Value type($a[$key])=Is collection)
			// collections are matched but not iterated
			If (JSON Stringify($a[$key])#JSON Stringify($b[$key]))
				return False
			End if 
		End if 
		
		If (This._isScalarValue($a[$key])) && ($a[$key]#$b[$key])
			return False
		End if 
		
	End for each 
	
	return True
