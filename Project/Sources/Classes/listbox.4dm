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
	ASSERT:C1129(Count parameters:C259>=1; "The name of the listbox object is required.")
	
	This:C1470.name:=$name  //      the name of the listbox
	
	This:C1470.source:=Null:C1517  //  collection/entity selection form.<>.data is drawn from
	This:C1470.data:=Null:C1517
	This:C1470.kind:=Null:C1517
	
	This:C1470.currentItem:=Null:C1517
	This:C1470.position:=0
	This:C1470.selectedItems:=Null:C1517
	
Function get dataLength : Integer
	If (This:C1470.data=Null:C1517)
		return 0
	Else 
		return This:C1470.data.length
	End if 
	
Function get isSelected->$isSelected : Boolean
	$isSelected:=This:C1470.position>0
	
Function get index->$index : Integer
	$index:=This:C1470.position-1
	
Function get_item()->$value : Variant
	//  gets the current item using the position index
	If (This:C1470.position>0)
		$value:=This:C1470.data[This:C1470.index]
	End if 
	
Function get_shortDesc() : Text
	//  return a text description of the listbox contents
	Case of 
		: (This:C1470.data=Null:C1517)
			return "The listbox is empty."
		Else 
			return String:C10(This:C1470.selectedItems.length)+" selected out of "+String:C10(This:C1470.data.length)
	End case 
	
	//MARK:-  setters
Function setSource($source : Variant)
/*   Set the source data and determine it's kind   */
	var $type : Integer
	$type:=Value type:C1509($source)
	
	Case of 
		: ($type=Is collection:K8:32)
			This:C1470.source:=$source
			This:C1470.kind:=$type
			This:C1470.setData()
			
		: ($type=Is object:K8:27)  //   entity selection
			This:C1470.source:=$source
			This:C1470.kind:=$type
			This:C1470.setData()
			
		Else 
			This:C1470.source:=Null:C1517
			This:C1470.data:=Null:C1517
			This:C1470.kind:=Null:C1517
	End case 
	
Function setData
	ASSERT:C1129(Count parameters:C259=0)  //  set the data to the source
	This:C1470.data:=This:C1470.source
	
Function insert($index : Integer; $element : Variant)->$result : Object
	// attempts to add the element into data
	// only supports collections
	
	If (Num:C11(This:C1470.kind)=Is collection:K8:32)
		This:C1470.source.insert($index; $element)
		This:C1470.data.insert($index; This:C1470.source[$index])
		This:C1470.redraw()
		
		$result:=result_object(True:C214)
	Else 
		$result:=result_object(False:C215; "Can only insert into collections. ")
	End if 
	
	//MARK:-
Function redraw()
	This:C1470.data:=This:C1470.data
	
Function reset()
	This:C1470.data:=This:C1470.source
	
Function refreshSource
	//  if this is an entity selection reloads the records
	If (This:C1470.kind=Is object:K8:27) && (This:C1470.source#Null:C1517)
		This:C1470.source.refresh()
		This:C1470.redraw()
	End if 
	
Function updateEntitySelection()
	//  if this is an entity selection reloads the entities
	If (This:C1470.kind=Is object:K8:27)
		var $entity : Object
		
		For each ($entity; This:C1470.source)
			$entity.reload()
		End for each 
	End if 
	
Function deselect
	//  clear the current selection
	LISTBOX SELECT ROW:C912(*; This:C1470.name; 0; lk remove from selection:K53:3)
	
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
		: (This:C1470.kind=Null:C1517)
		: (This:C1470.kind=Is object:K8:27) && (Value type:C1509($criteria)=Is object:K8:27)
			$i:=This:C1470.indexOf($criteria)
			
		: (Value type:C1509($criteria)=Is text:K8:3) && (Count parameters:C259=2)
			$n:=0
			
			For each ($o; This:C1470.data)
				
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
		: (Value type:C1509($criteria)=Is real:K8:4)
			$row:=$criteria
		Else 
			$row:=This:C1470.findRow($criteria; $value)
	End case 
	
	LISTBOX SELECT ROW:C912(*; This:C1470.name; $row; lk replace selection:K53:1)
	
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
		: ($what=Null:C1517) | (This:C1470.kind=Null:C1517)
		: (This:C1470.kind=Is object:K8:27)
			$index:=$what.indexOf(This:C1470.data)
			
		: (This:C1470.kind=Is collection:K8:32)
			$index:=This:C1470.data.indexOf($what)
			
	End case 
	
Function sum($key : Text)->$value : Real
	//  return the sum of $key if it is a numeric value
	If (Value type:C1509(This:C1470.data[$key])=Is real:K8:4) || (Value type:C1509(This:C1470.data[$key])=Is longint:K8:6)
		$value:=This:C1470.data.sum($key)
	End if 
	
Function min($key : Text)->$value : Real
	//  return the min of $key if it is a numeric value
	If (Value type:C1509(This:C1470.data[$key])=Is real:K8:4) || (Value type:C1509(This:C1470.data[$key])=Is longint:K8:6)
		$value:=This:C1470.data.min($key)
	End if 
	
Function max($key : Text)->$value : Real
	//  return the max of $key if it is a numeric value
	If (Value type:C1509(This:C1470.data[$key])=Is real:K8:4) || (Value type:C1509(This:C1470.data[$key])=Is longint:K8:6)
		$value:=This:C1470.data.max($key)
	End if 
	
Function average($key : Text)->$value : Real
	//  return the average of $key if it is a numeric value
	If (Value type:C1509(This:C1470.data[$key])=Is real:K8:4) || (Value type:C1509(This:C1470.data[$key])=Is longint:K8:6)
		$value:=This:C1470.average($key)
	End if 
	
Function extract($key : Text)->$collection : Collection
	//  return the extracted values of a specific 'column' as a collection
	If (This:C1470.data[$key]#Null:C1517)
		$collection:=This:C1470.data.extract($key)
	End if 
	
Function distinct($key : Text)->$collection : Collection
	//  return the distinct values of a specific 'column' as a collection
	If (This:C1470.data[$key]#Null:C1517)
		$collection:=This:C1470.data.distinct($key)
	End if 
	
Function lastIndexOf($key : Text)->$index : Integer
	If (This:C1470.data[$key]#Null:C1517)
		$index:=This:C1470.data.lastIndexOf($key)
	End if 
	