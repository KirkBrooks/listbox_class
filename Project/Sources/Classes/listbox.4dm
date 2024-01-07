/*  Listbox ()
 Created by: Kirk as Designer
modified: 08/23/2023
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

Class constructor($name : Text)
	ASSERT(Count parameters=1; "The name of the listbox object is required.")

	This.name:=$name  //      the name of the listbox

	This.source:=Null  //  collection/entity selection form[name].data is drawn from
	This.data:=Null
	This.kind:=Is undefined
	This._lastError:=""

	//  use these for the listbox datasource elements
	This._clearDatasources()

	//mark:  --- computed attributes
	//mark: these are the values managed by the 4D listbox
Function get currentItem : Object
	return This._currentItem

Function get position : Integer
	return This._position

Function get selectedItems : Variant
	return This._selectedItems

Function set currentItem($object : Object)
	This._currentItem:=$object

Function set position($pos : Integer)
	This._position:=$pos

Function set selectedItems($selected : Variant)
	This._selectedItems:=$selected
	This._lastSelectedItems:=$selected.copy()

	//mark: class properties
Function get isReady : Boolean
	//  return true when there is data
	return (This.source#Null)

Function get isFormObject : Boolean
	//  true if there is a form object for this listbox
	return OBJECT Get pointer(Object named; This.name)#Null

Function get dataLength : Integer
	If (This.data=Null)
		return 0
	Else
		return This.data.length
	End if

Function get isSelected : Boolean
	return Num(This.position)>0

	//todo:  add isScalar  \\  True when source is a scalar collection

Function get index : Integer
	return This.position-1

Function get isCollection : Boolean
	return This.kind=Is collection

Function get isEntitySelection : Boolean
	return (This.kind=Is object) && (OB Instance of(This.source; 4D.EntitySelection))

Function get dataClass : 4D.DataClass
	// if this is an entity selection listbox return the dataclass
	If (This.isCollection)
		return Null
	End if

	return This._dataclass

Function get error : Text
	return This._lastError

Function get_shortDesc() : Text
	//  return a text description of the listbox contents
	Case of
		: (This.data=Null)
			return "The listbox is empty."
		: (This.isSelected)
			return String(This.selectedItems.length)+" selected out of "+String(This.dataLength)
		Else
			return "0 selected out of "+String(This.dataLength)
	End case

	//MARK:-  setters
Function setSource($source : Variant; $retainSelectedItems : Boolean) : cs.listbox
/*   Set the source data and determine it's kind   */
	var $type : Integer
	$type:=Value type($source)
	This._clearDatasources()

	If ($type=Is collection)
		This.source:=$source
		This.kind:=$type
		This.setData($retainSelectedItems)

		return This
	End if

	If ($type=Is object) && (OB Instance of($source; 4D.EntitySelection))  //   entity selection
		This.source:=$source
		This.kind:=$type
		This._dataclass:=$source.getDataClass()
		This.setData()

		return This
	End if

	This.source:=Null
	This.data:=Null
	This.kind:=Null
	return This

Function setData($retainSelectedItems : Boolean) : cs.listbox
	$retainSelectedItems:=$retainSelectedItems || This._alwaysRetainSelection

	This.data:=This.source  //  blows away currently selected items - if any

	If ($retainSelectedItems)
		return This.reselect()
	End if

	return This

Function insert($index : Integer; $element : Variant) : Object
	// attempts to add the element into data
	// only supports collections

	If (Not(This.isCollection))
		return This._result(False; "Can only insert into collections. ")
	End if

	This.data.insert($index; $element)
	This.reselect()
	return This._result(True)

	//MARK:-
Function get_item()->$value : Variant
	//  gets the current item using the position index
	return (This.isSelected) ? This.data[This.index] : Null

Function redraw() : cs.listbox
	This.data:=This.data
	return This

Function reset() : cs.listbox
	This.setData()
	return This

Function updateEntitySelection() : cs.listbox
	//  if this is an entity selection reloads the entities
	If (Not(This.isEntitySelection))
		This._lastError:="updateEntitySelection(): this is a collecton"
		return This
	End if

	var $entity : 4D.Entity

	For each ($entity; This.source)
		$entity.reload()
	End for each
	return This

Function findRow($criteria : Variant) : Integer
/*  attempts to find the row
criteria is an entity when data is entity selection
criteria is a property for collections or entity selections
and value is the comparator.
*/

	If (Not(This.isEntitySelection)) && (Not(This.isCollection))
		return -1
	End if

	If (Value type($criteria)=Is object) && (This.isEntitySelection)
		return $criteria.indexOf(This.data)+1  //  add 1 for the row number
	End if

	If (Value type($criteria)=Is object)  // collection
		return This.data.indexOf($criteria)+1  //  add 1 for the row number
	End if

	return -1  //

Function doQuery($queryString : Text; $settings : Object) : cs.listbox
	// execute the query on this.source and put the result into this.data
	If ($queryString="")
		return This
	End if

	var $selectedItems : Variant
	$selectedItems:=This._selectedItems.copy()

	If ($settings#Null)
		This.data:=This.source.query($queryString; $settings)

	Else
		This.data:=This.source.query($queryString)

	End if

	return This.reselect($selectedItems)

Function firstOrSelected() : Variant
	// if an item is selected it's returned
	// otherwise the first item is selected and returned
	// null if no data
	If (This.data=Null)
		return Null
	End if

	If (Not(This.isSelected))
		This.selectRow(1)
		return This.data[0]
	End if

	return This.selectedItems[0]

	//mark:  --- updates the form object
Function reselect($selectedItems : Variant) : cs.listbox
	// Note: The command assumes that each object or entity is displayed only once in the list box.
	// If $1 is passed this will be used to set the new selection
	// otherwise the currently selected rows will be used - af any
	$selectedItems:=Count parameters=1 ? $selectedItems : This._selectedItems

	If ($selectedItems#Null)
		LISTBOX SELECT ROWS(*; This.name; $selectedItems; lk replace selection)
	End if
	return This.setScrollPosition()

Function deselect($selectedItems : Variant) : cs.listbox
	// remove selectedItems. If omitted all rows are deselected
	If (This.isCollection)
		$selectedItems:=Count parameters=0 ? [] : $selectedItems
	Else
		$selectedItems:=Count parameters=0 ? This.dataClass.newSelection() : $selectedItems
	End if

	LISTBOX SELECT ROWS(*; This.name; $selectedItems; lk replace selection)
	This._clearDatasources()
	return This.redraw()

Function selectRow($criteria : Variant) : cs.listbox
	// $criteria is either a row number or an object in .data
	// $action is the 4D constant. default = lk add to selection
	var $selectedItems : Variant

	Case of
		: (This.dataLength=0)
			return This

		: (Value type($criteria)#Is real) && (Value type($criteria)#Is longint) && (Value type($criteria)=Is object)
			return This

		: ((Value type($criteria)=Is real) || (Value type($criteria)=Is longint))
			If ($criteria>0) && ($criteria<=This.dataLength)  // select a row #
				If (This.isCollection)
					$selectedItems:=[This.data[$criteria-1]]
				Else   //  entity selection
					$selectedItems:=This.dataClass.newSelection().add(This.data[$criteria-1])
				End if

			Else
				return This  //  just bail out
			End if

		: (Value type($criteria)=Is object) && (This.isEntitySelection)  // .data is entity selection
			$selectedItems:=This.dataClass.newSelection().add($criteria)

		: (Value type($criteria)=Is object) && (This.isCollection)
			$selectedItems:=[$criteria]

	End case

	LISTBOX SELECT ROWS(*; This.name; $selectedItems; lk replace selection)
	return This.setScrollPosition()

Function setScrollPosition($row : Integer) : cs.listbox
	// sets the scroll position. if $row is omitted this.position is used
	// this doesn't change the selected items or currentItem

	$row:=Count parameters=0 ? This.position : $row
	If ($row>0)
		OBJECT SET SCROLL POSITION(*; This.name; $row; *)
	End if

	return This.redraw()

Function next : cs.listbox  // select the next row
	var $row : Integer
	$row:=(This.position+1)>This.dataLength ? 1 : This.position+1
	return This.selectRow($row)

Function prev : cs.listbox  // select the previous row
	var $row : Integer
	$row:=(This.position-1)<1 ? This.dataLength : This.position-1
	return This.selectRow($row)

Function first : cs.listbox  // select the first row
	var $row : Integer
	return This.selectRow(1)

Function last : cs.listbox  // select the last row
	var $row : Integer
	return This.selectRow(This.dataLength)

	//MARK:-  data functions
	//  these are really just wrappers for native functions
	// but are convenient to have
Function indexOf($what : Variant) : Integer
/* attempts to find the index of $what in .data
if this is an entity selection $what must be an entity of that dataclass
if this is a collection $what must be the same type as the collection data
*/
	If ($what=Null) | (This.kind=Null)
		return -1
	End if

	If (This.kind=Is object)  //  entity selection: $what is an entity
		return $what.indexOf(This.data)
	End if

	If (This.kind=Is collection)
		return This.data.indexOf($what)
	End if

Function sum($key : Text) : Real
	//  return the sum of $key if it is a numeric value in this.data
	return (This._keyExists($key)) ? This.data.sum($key) : 0

Function min($key : Text) : Real
	//  return the min of $key if it is a numeric value in this.data
	return (This._keyExists($key)) ? This.data.min($key) : 0

Function max($key : Text) : Real
	//  return the max of $key if it is a numeric value in this.data
	return (This._keyExists($key)) ? This.data.max($key) : 0

Function average($key : Text)->$value : Real
	//  return the average of $key if it is a numeric value in this.data
	return (This._keyExists($key)) ? This.data.average($key) : 0

Function extract($key : Text)->$collection : Collection
	//  return the extracted values of a specific 'column' as a collection
	return (This._keyExists($key)) ? This.data.extract($key) : New collection

Function distinct($key : Text)->$collection : Collection
	//  return the distinct values of a specific 'column' as a collection
	return (This._keyExists($key)) ? This.data.distinct($key) : New collection

Function lastIndexOf($key : Text; $findValue : Variant) : Integer
	return (This._keyExists($key)) ? This.extract($key).lastIndexOf($findValue) : -1

	//MARK:-  ---- utilities
Function _clearDatasources
	//  clear the objects that are set by the listbox object
	// This._lastSelectedItems:=This.selectedItems
	This._currentItem:=Null
	This._position:=0
	This._selectedItems:=Null

Function _result($result : Boolean; $error : Variant) : Object
	Case of
		: (Count parameters=0) || (Bool($result))
			This._lastError:=""
			return New object("success"; True)

		: (Count parameters=2)  // $result=false and an error text
			This._lastError:=String($error)
			return New object("success"; False; "error"; String($error))

		Else   // $result=false and no error text
			This._lastError:="Unspecified error."
			return New object("success"; False; "error"; "Unspecified error.")
	End case

Function _keyExists($key : Text) : Boolean

	return (This.isReady) && (This.data[0][$key]#Null)

Function _keyIsNumber($key : Text) : Boolean
	return This._keyExists($key) && (Value type(This.data[0][$key])=Is real) || (Value type(This.data[0][$key])=Is longint)
