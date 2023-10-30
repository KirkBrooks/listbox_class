/*  HTMLtable class
 Created by: Kirk Brooks as Designer, Created: 10/25/23, 09:38:41
 ------------------
 create an HTML table based on a Listbox class
Linking listbox class data to columns
  The table is drawn from This._listbox.data so the reference to 
 that data is This._listbox.data[property]. The euquvalent of This[property]
 in the listbox object. 

COLUMN
  property: ""  // the name of the property from _listbox
  header:{ label: "" }  // default is property
  body: {format: "", width: 0, dataType: 0}
  footer: {function: <4D Formula>}

*/
property _listbox : cs.listbox

Class constructor($id : Text)
	This[""]:=Current method name()
	This._id:=$id ? $id : "htmlTable"
	This._class:=""  //  class for <table>
	This._rowClass:=""  //  class for rows
	This._PKproperty:=""  //  name of PK property in listbox.data elements
	
	This._listbox:=Null
	This._columns:=[]
	This._errors:=[]
	
	//mark:  --- getters
Function get isReady : Boolean
	//  true if the class is properly initialized
	return (This._listbox#Null)
	
Function get tableClass : Text
	return This._class
	
Function set tableClass($class : Text)
	This._class:=$class
	
Function get rowClass : Text
	return This._rowClass
	
Function set rowClass($class : Text)
	This._rowClass:=$class
	
Function get PKproperty : Text
	return This._PKproperty
	
Function set PKproperty($property : Text)
	If (Not(This._isValidProperty($property)))
		This._err("'"+$property+"' is not a valid property of listbox:"+This._listbox.name)
	End if 
	
	This._PKproperty:=$property
	
	//mark:  --- functions
Function setListbox($class : cs.listbox) : cs.HTMLtable
	This._errors:=[]
	
	If ($class=Null)
		This._err("Not a valid listbox class.")
		return This
	End if 
	
	This._listbox:=$class
	return This
	
Function insertColumn($property : Text; $options : Object) : cs.HTMLtable
	var $colObj : Object
	
	If (Not(This.isReady)) || (Not(This._listbox.isReady))
		This._err("Not ready")
		return This
	End if 
	
	If (Not(This._isValidProperty($property)))
		This._err("'"+$property+"' is not a valid property of listbox:"+This._listbox.name)
		return This
	End if 
	
	$colObj:=This._columnObject($property; $options)
	This._columns.push($colObj)
	return This
	
Function deleteColumn($col : Variant) : cs.HTMLtable
	//   $col is the property name or index
	var $indx : Integer
	
	$indx:=-1
	
	If (Value type($col)=Is text)
		$indx:=This._columns.indexOf(This._columns.query("property = :1"; $col).first())
	End if 
	
	If (Value type($col)=Is real) || (Value type($col)=Is integer)
		$indx:=$col
	End if 
	
	If ($indx>-1)
		This._columns.remove($indx)
	End if 
	
	return This
	
Function getTable()->$html : Text
	//  build the html based on the 
	var $col; $element : Object
	var $rowHtml; $rowTemplate : Text
	
	$html:=This._tableTag()+"\n"
	// Header
	For each ($col; This._columns)
		
	End for each 
	
	// loop each column build a template to use Process tags on each element
	$rowTemplate:=This._rowTemplate()
	
	//  loop through the listbox data
	For each ($element; This._listbox.data)
		PROCESS 4D TAGS($rowTemplate; $rowHtml; $element)
		$html+=$rowHtml+"\n"
	End for each 
	
	$html+="</table>\n"
	
Function allFields() : cs.HTMLtable
	// quick table of all fields of the listbox data
	var $property : Text
	
	This._columns:=[]
	
	For each ($property; This._listbox.data.first())
		This.insertColumn($property)
	End for each 
	return This
	
	//mark:  --- private
Function _tableTag()->$tag : Text
	//  return the opening table tag
	$tag:="<table id='"+This._id+"'"
	$tag+=This._class#"" ? " class='"+This._class+"'" : ""
	$tag+=">"
	
Function _rowTemplate() : Text
	// $id is the id property - not the actual id value
	// loop through columns and build the template for table rows
	var $col : Object
	var $template : Text
	
	$template:="<tr"
	$template+=This.PKproperty="" ? "" : " id='<!--#4DTEXT $1."+This.PKproperty+"-->'"
	$template+=This._rowClass="" ? "" : " class='"+This._rowClass+"'"
	$template+=">"
	
	For each ($col; This._columns)
		$template+=This._cellTemplate($col.property; $col.body.format)
	End for each 
	$template+="</tr>"
	return $template
	
Function _cellTemplate($property : Text; $format) : Text
	//  $property is the name of the property to write in the cell
	If (Value type($format)=Is text) || (Value type($format)=Is real) || (Value type($format)=Is integer)
		return "<td><!--#4DEVAL String($1."+$property+";"+String($format)+")--></td>"
	End if 
	
	return "<td><!--#4DTEXT $1."+$property+"--></td>"
	
Function _columnObject($property : Text; $options : Object)->$colObj : Object
	// this might become a class
	$colObj:={}
	$colObj.property:=$property
	$colObj.header:={}
	$colObj.header.label:=$options.label ? $options.label : $property
	
Function _isValidProperty($property : Text)->$ok : Boolean
	//  true when $property is a valid property of _listbox
	var $obj : Object
	
	If (Not(This._listbox.isReady)) || (This._listbox.data=Null)
		return False
	End if 
	
	$obj:=This._listbox.data.first()
	$property:=Replace string($property; "()"; "")
	
	If (Value type($obj[$property])=Is object) && (OB Instance of($obj[$property]; 4D.Function))
		return True
	End if 
	
	return $obj[$property]#Null
	
Function _err($text : Text)
	This._errors.insert(0; $text)
	
	