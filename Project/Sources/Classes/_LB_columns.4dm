/* Purpose: manages defining columns based on an object or entity selection
 ------------------
_LB_columns ()
 Created by: Kirk as Designer, Created: 12/20/23, 09:46:19

$input:   dataclass, entity or object
   dataclass or entity
        set up 'columns' with 1 column for each file/calculated value

   object
        set up columns with 1 column for each value except objects and collections

COLUMN OBJECT
The columns will be used to configure listbox objects and HTML renderings

 {name: <field name>;
  isEnterable: bool;
  fieldType: int;
  valueType: text;
  headerText: <default name>;
  isHidden: bool;
  format: <>;
  width: 0 
 }
*/

Class constructor($input : Object)
	This._colSrc:=[]  //  all possible columns for the listbox
	This._columns:=[]  //  the columns actually being used in the listbox
	Case of 
		: (OB Instance of($input; 4D.DataClass))
			This._configDataclass($input)
		: (OB Instance of($input; 4D.Entity))
			This._configDataclass($input.getDataClass())
		Else 
			This._configObject($input)
	End case 
	
Function get isReady : Boolean
	return This._colSrc.length>0
	
	//mark:  --- column functions
Function getColumns : Collection
	return This._columns
	
Function get nColumns : Integer
	return This._columns.length
	
Function get nVisibleColumns : Integer
	return This._columns.query("isVisible = :1"; True).length
	
Function getColName($i : Integer) : Text
	return This._getColumnAttr($i; "name")
	
Function getColHeader($i : Integer) : Text
	return This._getColumnAttr($i; "headerText")
	
Function getColFormat($i : Integer) : Text
	return This._getColumnAttr($i; "format")
	
Function getColEnterable($i : Integer) : Boolean
	return Bool(This._getColumnAttr($i; "isEnterable"))
	
Function getColIsEntity($i : Integer) : Boolean
	return Bool(This._getColumnAttr($i; "isEntity"))
	
Function getColIsHidden($i : Integer) : Boolean
	return Bool(This._getColumnAttr($i; "isHidden"))
	
Function getColWidth($i : Integer) : Integer
	return This._getColumnAttr($i; "width")
	
	//mark: set column values
Function setColHidden($i : Integer; $bool : Boolean) : cs._LB_columns
	This._setColumnAttr($i; "isHidden"; $bool)
	return This
	
Function get nSrc : Integer
	return This._colSrc.length
	
	//mark:  --- private
Function _getColumnAttr($i : Integer; $attr : Text) : Variant
	return (This.isReady) && ($i<=This.nColumns) ? This._columns[$i-1][$attr] : ""
	
Function _setColumnAttr($i : Integer; $attr; $value)
	If (Not(This.isReady) || ($i>This.nColumns)) || ($value=Null)
		return 
	End if 
	
	This._columns[$i-1][$attr]:=$value  // always write to the source
	//  did anything change the visibility of a column
	If ($attr="isHidden")
		This._columns:=This._colSrc.query("isHidden = :1"; False)
	End if 
	
Function _configObject($input : Object)
	This._columns:=[]
	
Function _configDataclass($input : Object)
	// we only allow Storage and Calculated attributes
	// and their value types must NOT BE object, collection, entity selection
	var $attr; $obj : Object
	var $name : Text
	
	This._colSrc:=[]
	This._dataclass:=$input
	
	For each ($name; This._dataclass)
		If ($attr.fieldType=Is collection) || ($attr.fieldType=Is object)
			// this will also filter relatedEntites and relatedEntity
			continue
		End if 
		
		$attr:=This._dataclass[$name]
		$obj:={name: $attr.name}
		$obj.isEntity:=True
		$obj.headerText:=This._prettyText($name)
		$obj.fieldType:=$attr.fieldType
		$obj.kind:=$attr.kind
		$obj.type:=$attr.type
		$obj.indexed:=$attr.indexed
		$obj.isHidden:=False
		$obj.isEnterable:=False
		$obj.format:=This._defaultFormat($obj.fieldType)
		$obj.width:=This._defaultWidth($obj.fieldType)
		
		This._colSrc.push($obj)
	End for each 
	
	This._columns:=This._colSrc  //  default to showing all columns
	
Function _prettyText($text : Text) : Text
	// try to make $text look nice
	var $col : Collection
	var $word : Text
	
	$text:=This._reverseCamelCase($text)
	$text:=Replace string($text; "_"; " ")
	$col:=Split string($text; " ")
	$text:=""
	For each ($word; $col)
		$word[[1]]:=Uppercase($word[[1]])
		$text+=($word#Null ? " " : "")+$word
	End for each 
	
	return $text
	
Function _reverseCamelCase($text : Text) : Text
	var $pattern; $new : Text
	ARRAY LONGINT($pos; 0)
	ARRAY LONGINT($len; 0)
	
	$pattern:="[a-z][A-Z]"
	
	While (Match regex($pattern; $text; 1; $pos; $len))
		$new:=Substring($text; $pos{1}; $len{1})+" "+Substring($text; $pos{2}; $len{2})
		$text:=Replace string($text; Substring($text; $pos{0}; $len{0}); $new)
	End while 
	
	return $text
	
Function _defaultWidth($type : Integer) : Integer
	// WAGs for column width based on type
	Case of 
		: ($type=Is boolean)  // assume a checkbox
			return 30
		: ($type=Is date) || ($type=Is time)  // assume mm/dd/yyyy
			return 70
		: ($type=Is real)  // ###,###,##0.00
			return 80
		: ($type=Is text)
			return 225
		Else 
			return 100
	End case 
	
Function _defaultFormat($type : Integer) : Variant
	// WAGs for column width based on type
	Case of 
		: ($type=Is boolean)  // assume a checkbox
			return ""
		: ($type=Is date)  // assume mm/dd/yyyy
			return System date abbreviated
		: ($type=Is time)
			return System time PM label
		: ($type=Is real)  // ###,###,##0.00
			return " ###,###,##0.00;- ###,###,##0.00; -"
		: ($type=Is text)
			return ""
		Else 
			return ""
	End case 
	