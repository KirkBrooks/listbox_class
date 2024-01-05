/*  CSSgrid class
 Created by: Kirk as Designer, Created: 12/20/23, 09:02:55
 ------------------

*/
property _listbox : cs.listbox

Class constructor($name : Text)
	This._listbox:=cs.listbox.new($name)
	This._columns:=[]
	This._css:=""  //   css file template
	This._html:=""  //  html file template
	This.lastError:=""
	
	//mark:  --- content
Function setSource($input) : cs.CSSgrid
	//  input is a collection or entity selection
	If (Not(This._listbox.setSource($input).isReady))
		This.lastError:="Invalid data input."
		return This
	End if 
	
	This._columns:=cs._LB_columns.new(This._listbox.source[0])
	return This
	
	//mark:  --- build the header and body divs
Function get bodyDiv : Text
	return This._html
	
Function getBodyDiv->$html : Text
	This.buildHdrDiv().buildBodyDiv()
	PROCESS 4D TAGS(This.tempGrid(); $html; This._hdrDiv+This._bodyDiv)
	
Function buildHdrDiv : cs.CSSgrid
	var $headerDiv; $temp : Text
	var $column : Object
	
	For each ($column; This._columns.getColumns())
		PROCESS 4D TAGS(This.tempHdrCell(); $temp; $column.headerText)
		$headerDiv+=$temp
	End for each 
	
	PROCESS 4D TAGS(This.tempHdr(); $headerDiv; $headerDiv)
	This._hdrDiv:=$headerDiv
	return This
	
Function buildBodyDiv : cs.CSSgrid
	var $body; $row; $tempGridBody; $temp : Text
	var $element; $column : Object
	$body:=""
	
	For each ($element; This._listbox.data)
		$row:=""
		
		For each ($column; This._columns.getColumns())
			PROCESS 4D TAGS(This.tempRowCell(); $temp; This._string($element[$column.name]); "v-"+$column.type)
			$row+=$temp
		End for each 
		
		PROCESS 4D TAGS(This.tempBodyRow(); $row; $row)
		$body+=$row
	End for each 
	
	PROCESS 4D TAGS($tempGridBody; $body; $body)
	This._bodyDiv:=$body
	return This
	
	//mark:  --- templates
Function tempGrid() : Text
	return "<div class='lb-grid'>\n<!--#4DHTML $1--></div>\n"
	
Function tempHdr() : Text
	return "<div class='lb-grid-header'>\n<!--#4DHTML $1--></div>\n"
	
Function tempHdrCell() : Text
	return "<div class='lb-header-cell'>\n<!--#4DHTML $1--></div>\n"
	
Function tempGridBody() : Text
	return "<div class='lb-grid-body'>\n<!--#4DHTML $1--></div>\n"
	
Function tempBodyRow() : Text
	return "<div class='lb-grid-row'>\n<!--#4DHTML $1--></div>\n"
	
Function tempRowCell() : Text
	return "<div class='lb-cell <!--#4DHTML $2-->'>\n<!--#4DHTML $1--></div>\n"
	
	//mark:  --- private
Function _string($value) : Text
	return String($value)
	
	
	