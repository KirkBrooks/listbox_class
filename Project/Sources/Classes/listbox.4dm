/*  Listbox ()
 Created by: Kirk as Designer
 ------------------
Default Names
eg. display data, current item, etc. These are stored in the Form and accessed with

TO USE
  You can instantiate the class into any variable. This makes it easy to do testing.
    $class:=cs.listbox.new("test_LB")
  To use the class in a form you can use the following code. Put it at the top of the form method:
    var $my_LB : cs.listbox
	$my_LB:=Form.my_LB || cs.listbox.new("my_LB")  // instantiate the class if it isn't already on the form

	If(Form event.code="On Load")
		Form.my_LB:=$my_LB
		$my_LB.setSource( {{Form.my_collection}})  // set the source data for the listbox
	end if

	Using $my_LB is a convenient way to have the listbox object available in the form methods.

  Setup the listbox object:
	Set the data source to Form.my_LB.data
	Set the Data Source -Current Item to Form.my_LB.currentItem
	Set the Data Source -Position to Form.my_LB.position
	Set the Data Source -Selected Items to Form.my_LB.selectedItems

You can change the contents of the listbox by calling .setSource()

In the form method you can:

   If($my_LB.isSelected)
     $my_LB.currentItem["some property"]:= "new value"
   End if

*/

property name : Text  //      the name of the listbox object
property source : Variant  //  collection/entity selection form[name].data is drawn from
property dataClass : 4D.DataClass  // of source when it's an entity selection
property data : Variant  //   selection of This.source displayed in the listbox
property kind : Integer  //   4D data type of This.source:  is collection | is object(entity selection)
property _lastError : Text
// these properties are used on the Form
property selectedItems : Variant  // entity selection or collection of selected items
property position : Integer  //      row of first selected item
property currentItem : Object  //    select item if entity selection or collection contains objects


Class constructor($name : Text; $source)
	ASSERT($name#""; "The name of the listbox object is required.")
	
	This.name:=$name
	This.source:=Null
	This.data:=Null
	This.kind:=Is undefined
	This._lastError:=""
	
	//  use these for the listbox datasource elements
	This._clearDatasources()
	
	Case of 
		: (Count parameters=1)
			// nothing else
		: (Value type($source)=Is object) && (OB Instance of($source; 4D.EntitySelection))
			This.setSource($source)
			
		: (Value type($source)=Is collection)
			This.setSource($source)
	End case 
	
	
	//mark:  --- computed attributes
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
	
Function get error : Text
	return This._lastError
	
Function get shortDesc() : Text
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
Function setSource($source : Variant) : cs.listbox
/*   Set the source data and determine it's kind   */
	var $type : Integer
	$type:=Value type($source)
	This._clearDatasources()
	
	If ($type=Is collection)
		This.source:=$source
		This.kind:=$type
		This.dataClass:=Null
		This.setData()
		
		return This
	End if 
	
	If ($type=Is object) && (OB Instance of($source; 4D.EntitySelection))  //   entity selection
		This.source:=$source
		This.kind:=$type
		This.dataClass:=$source.getDataClass()
		
		This.setData()
		
		return This
	End if 
	
	This.source:=Null
	This.data:=Null
	This.kind:=-1
	return This
	
Function setData : cs.listbox
	This.data:=This.source
	return This
	
Function insert($index : Integer; $element : Variant) : Object
	// attempts to add the element into data
	// only supports collections
	
	If (Not(This.isCollection))
		return This._result(False; "Can only insert into collections. ")
	End if 
	
	This.data.insert($index; $element)
	This.redraw()
	return This._result(True)
	
	//MARK:-
Function get_item()->$value : Variant
	//  gets the current item using the position index. Usually this is the same 
	//  as currentItem unless the collection does not contain objects
	return (This.isSelected) ? This.data[This.index] : Null
	
Function redraw() : cs.listbox
	This.data:=This.data  //  forces form object redraw itself
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
	
	var $entity : Object
	
	For each ($entity; This.source)
		$entity.reload()
	End for each 
	return This
	
Function findRow($criteria : Variant) : Integer
/*  attempts to select the row
criteria is an entity when data is entity selection
criteria is a object for collections
*/
	
	If (This.isEntitySelection) && (Value type($criteria)=Is object) && (OB Instance of($criteria; 4D.Entity))
		// $criteria is an object. .indexOf() returns the position of the entity in an entity selection.
		return $criteria.indexOf(This.data)+1  //  add 1 for the row number
	End if 
	
	If (This.isCollection) && (Value type($criteria)=Is object)
		return This.data.indexOf($criteria)+1  //  add 1 for the row number
	End if 
	
	return -1  //
	
Function doQuery($queryString : Text; $settings : Object) : cs.listbox
	// execute the query on this.source and put the result into this.data
	If ($queryString="")
		return This
	End if 
	
	If ($settings#Null)
		This.data:=This.source.query($queryString; $settings)
		return This.first()
	End if 
	
	This.data:=This.source.query($queryString)
	return This.redraw().first()
	
	//mark:  --- updates the form object
Function deselect : cs.listbox
	//  clear the current selection
	LISTBOX SELECT ROW(*; This.name; 0; lk remove from selection)
	This._clearDatasources()
	return This
	
Function selectRow($criteria : Variant; $value : Variant) : cs.listbox
	var $row : Integer
	If (This.dataLength=0)
		return This
	End if 
	
	Case of 
		: (Value type($criteria)=Is real) && ($criteria<=This.dataLength)
			$row:=$criteria
		: (Value type($criteria)=Is object)
			$row:=This.findRow($criteria)
		Else 
			$row:=-1
	End case 
	
	If ($row>0)
		This.currentItem:=This.data[$row-1]
		This.position:=$row
		If (This.isCollection)
			This.selectedItems:=[This.currentItem]
		Else 
			This.selectedItems:=This.dataClass.newSelection()
			This.selectedItems.add(This.selectedItems)
		End if 
	Else 
		This.currentItem:=Null
		This.selectedItems:=Null
		This.position:=0
	End if 
	
	LISTBOX SELECT ROW(*; This.name; $row; lk replace selection)
	
	If ($row>2)
		OBJECT SET SCROLL POSITION(*; This.name; $row; *)
	End if 
	
	return This
	
Function next : cs.listbox  // select the next row
	var $row : Integer
	If (This.dataLength=0)
		return This
	End if 
	
	$row:=(This.position+1)>This.dataLength ? 1 : This.position+1
	return This.selectRow($row)
	
Function prev : cs.listbox  // select the previous row
	var $row : Integer
	If (This.dataLength=0)
		return This
	End if 
	
	$row:=(This.position-1)<1 ? This.dataLength : This.position-1
	return This.selectRow($row)
	
Function first : cs.listbox  // select the first row
	var $row : Integer
	If (This.dataLength=0)
		return This
	End if 
	
	return This.selectRow(1)
	
Function last : cs.listbox  // select the last row
	var $row : Integer
	If (This.dataLength=0)
		return This
	End if 
	
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
	This.currentItem:=Null
	This.position:=0
	This.selectedItems:=Null
	
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
	