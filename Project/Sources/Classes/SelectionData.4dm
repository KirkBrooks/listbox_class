/*  SelectionData class
 Created by: Kirk as Designer, Created: 10/30/23, 10:20:29
 ------------------
 

*/
property _header : Object
property _dataclass : 4D.DataClass

Class constructor($name : Text)
	This._name:=$name ? $name : Lowercase(Substring(Generate UUID; 12; 8))
	This.clear()
	
	
	//mark:  --- functions
Function clearErr : cs.SelectionData
/* Clears the error field. If the source is valid it leaves it intact.
Basically only works for errors not generated by setSource()
 */
	If (This._source=Null) && (This._kind=Is undefined)
		return This  //  do nothing
	End if 
	
	This._lastError:=""
	return This
	
Function clear : cs.SelectionData
	//  clears the class
	This._source:=Null
	This._nColumns:=0
	This._kind:=Is undefined
	This._dataclass:=Null
	This._lastError:=""
	return This
	
Function setSource($input) : cs.SelectionData
	If (This.isErr)
		return This
	End if 
	
	If (Value type($input)=Is object) && (OB Instance of($input; 4D.EntitySelection))
		This._source:=$input
		This._kind:=Is object
		This._dataclass:=$input.getDataClass()
		This._lastError:=""
		This._set_n_cols()
		return This
	End if 
	
	If (Value type($input)=Is collection)
		This._source:=$input
		This._kind:=Is collection
		This._dataclass:=Null
		This._lastError:=""
		This._set_n_cols()
		return This
	End if 
	
	This._source:=Null  //  entity selection or collection
	This._kind:=Is undefined
	This._nColumns:=0
	This._header:=Null
	This._dataclass:=Null
	This._lastError:="$input must be collection or entity selection."
	return This
	
Function setHeaders($header : Object) : cs.SelectionData
/*  If Parameters=0 
     set headers as property name  - see This._set_n_cols
 If Parameters=1 AND $header=object
    loop through properties and set header as property name or $col
This._header is an object where 
*/
	var $attr : Text
	
	If (Count parameters=0)
		This._set_n_cols()
		return This
	End if 
	
	For each ($attr; OB Keys($header))
		If (This._header[$attr]#Null)
			This._header[$attr]:=$header[$attr]
		End if 
	End for each 
	return This
	
	//mark:  --- computed attr
Function get name : Text
	return This._name
	
Function get isReady : Boolean
	return (This._source#Null)  //  return true when there is data
	
Function get isErr : Boolean
	return This._lastError#""
	
Function get error : Text
	return This._lastError
	
Function get length : Integer
	If (This.isReady)
		return This._source.length
	Else 
		return 0
	End if 
	
Function get isCollection : Boolean
	return (This.isReady) && (This._kind=Is collection)
	
Function get isEntitySelection : Boolean
	return (This.isReady) && (This._kind=Is object)
	
Function get dataClassName : Text
	If (Not(This.isEntitySelection))
		return ""
	End if 
	
	return This._dataclass.getInfo().name
	
Function get header : Object
	return This._header
	//mark:  --- private
Function _set_n_cols
	var $attr : Text
	
	This._header:={}
	This._nColumns:=0
	
	If (This.isCollection) && (This.length=0)
		return 
	End if 
	
	If (This.isCollection)
		For each ($attr; OB Keys(This._source[0]))
			This._nColumns+=1
			This._header[$attr]:=$attr  //  this is the default column header
		End for each 
		
		return 
	End if 
	
	If (This.isEntitySelection)
		
		For each ($attr; This._dataclass)
			
			If ((This._dataclass[$attr].kind="storage") || (This._dataclass[$attr].kind="calculated"))
				This._nColumns+=1
				This._header[$attr]:=$attr  //  this is the default column header
			End if 
			
		End for each 
		return 
	End if 
	
	