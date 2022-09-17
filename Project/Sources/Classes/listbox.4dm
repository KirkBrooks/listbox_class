/*  listbox ()
 Created by: Kirk as Designer, Created: 10/7/21,
 ------------------
Default Names
eg. display data, current item, etc. These are stored in the Form and accessed with

TO USE
/*
add the listbox to the form and set the names
initialize
    Form["listbox name"]:=cs.listbox.new("listbox name")
*/
*/

Class constructor($name : Text; $refs : Object)
	var $key : Text
	// (name{;object})
	ASSERT(Count parameters>=1; "The name of the listbox object is required.")
	
	This.name:=$name  //      the name of the listbox
	
	This.source:=Null  //  collection/entity selection form.<>.data is drawn from
	This.data:=Null
	This.kind:=Null
	
	This.currentItem:=Null
	This.position:=0
	This.selectedItems:=Null
	
Function get dataLength : Integer
	If (This.data=Null)
		return 0
	Else 
		return This.data.length
	End if 
	
Function get isSelected->$isSelected : Boolean
	$isSelected:=This.position>0
	
Function get index->$index : Integer
	$index:=This.position-1
	
Function get_item()->$value : Variant
	//  gets the current item using the position index
	If (This.position>0)
		$value:=This.data[This.index]
	End if 
	
Function get_shortDesc() : Text
	//  return a text description of the listbox contents
	Case of 
		: (This.data=Null)
			return "The listbox is empty."
		Else 
			return String(This.selectedItems.length)+" selected out of "+String(This.data.length)
	End case 
	
	//MARK:-  setters
Function setSource($source : Variant)
/*   Set the source data and determine it's kind   */
	var $type : Integer
	$type:=Value type($source)
	
	Case of 
		: ($type=Is collection)
			This.source:=$source
			This.kind:=$type
			This.setData()
			
		: ($type=Is object)  //   entity selection
			This.source:=$source
			This.kind:=$type
			This.setData()
			
		Else 
			This.source:=Null
			This.data:=Null
			This.kind:=Null
	End case 
	
Function setData
	ASSERT(Count parameters=0)  //  set the data to the source
	This.data:=This.source
	
Function insert($index : Integer; $element : Variant)->$result : Object
	// attempts to add the element into data
	// only supports collections
	
	If (Num(This.kind)=Is collection)
		This.source.insert($index; $element)
		This.data.insert($index; This.source[$index])
		This.redraw()
		
		$result:=This._result(True)
	Else 
		$result:=This._result(False; "Can only insert into collections. ")
	End if 
	
	//MARK:-
Function redraw()
	This.data:=This.data
	
Function reset()
	This.data:=This.source
	
Function refreshSource
	//  if this is an entity selection reloads the records
	If (This.kind=Is object) && (This.source#Null)
		This.source.refresh()
		This.redraw()
	End if 
	
Function updateEntitySelection()
	//  if this is an entity selection reloads the entities
	If (This.kind=Is object)
		var $entity : Object
		
		For each ($entity; This.source)
			$entity.reload()
		End for each 
	End if 
	
Function deselect
	//  clear the current selection
	LISTBOX SELECT ROW(*; This.name; 0; lk remove from selection)
	
Function findRow($criteria : Variant; $value : Variant)->$i : Integer
/*  attempts to select the row 
criteria is an entity when data is entity selection 
criteria is a property for collections or entity selections
and value is the comparator. 
*/
	var $n : Integer
	var $o : Object
	
	$i:=-1
	
	Case of 
		: (This.kind=Null)
		: (This.kind=Is object) && (Value type($criteria)=Is object)
			$i:=This.indexOf($criteria)
			
		: (Value type($criteria)=Is text) && (Count parameters=2)
			$n:=0
			
			For each ($o; This.data)
				
				If ($o[$criteria]=$value)
					$i:=$n
					break
				End if 
				
				$n+=1
			End for each 
			
	End case 
	
	$i+=1  //  add 1 for the row number
	
Function selectRow($criteria : Variant; $value : Variant)
	var $row : Integer
	
	Case of 
		: (Value type($criteria)=Is real)
			$row:=$criteria
		Else 
			$row:=This.findRow($criteria; $value)
	End case 
	
	LISTBOX SELECT ROW(*; This.name; $row; lk replace selection)
	
	//MARK:-  data functions
	//  these are really just wrappers for native functions
	// but are convenient to have
Function indexOf($what : Variant)->$index : Integer
/* attempts to find the index of $what in .data
if this is an entity selection $what must be an entity of that dataclass
if this is a collection $what must be the same type as the collection data
*/
	$index:=-1
	
	Case of 
		: ($what=Null) | (This.kind=Null)
		: (This.kind=Is object)
			$index:=$what.indexOf(This.data)
			
		: (This.kind=Is collection)
			$index:=This.data.indexOf($what)
			
	End case 
	
Function sum($key : Text)->$value : Real
	//  return the sum of $key if it is a numeric value
	If (Value type(This.data[$key])=Is real) || (Value type(This.data[$key])=Is longint)
		$value:=This.data.sum($key)
	End if 
	
Function min($key : Text)->$value : Real
	//  return the min of $key if it is a numeric value
	If (Value type(This.data[$key])=Is real) || (Value type(This.data[$key])=Is longint)
		$value:=This.data.min($key)
	End if 
	
Function max($key : Text)->$value : Real
	//  return the max of $key if it is a numeric value
	If (Value type(This.data[$key])=Is real) || (Value type(This.data[$key])=Is longint)
		$value:=This.data.max($key)
	End if 
	
Function average($key : Text)->$value : Real
	//  return the average of $key if it is a numeric value
	If (Value type(This.data[$key])=Is real) || (Value type(This.data[$key])=Is longint)
		$value:=This.average($key)
	End if 
	
Function extract($key : Text)->$collection : Collection
	//  return the extracted values of a specific 'column' as a collection
	If (This.data[$key]#Null)
		$collection:=This.data.extract($key)
	End if 
	
Function distinct($key : Text)->$collection : Collection
	//  return the distinct values of a specific 'column' as a collection
	If (This.data[$key]#Null)
		$collection:=This.data.distinct($key)
	End if 
	
Function lastIndexOf($key : Text)->$index : Integer
	If (This.data[$key]#Null)
		$index:=This.data.lastIndexOf($key)
	End if 
	
	//MARK:-  ---- utilities
Function _result($result : Boolean; $error : Variant) : Object
	Case of 
		: (Count parameters=0) || (Bool($result))
			return New object("success"; True)
			
		: (Count parameters=2)  // $result=false and an error text
			return New object("success"; False; "error"; String($error))
			
		Else   // $result=false and no error text
			return New object("success"; False; "error"; "Unspecified error.")
	End case 