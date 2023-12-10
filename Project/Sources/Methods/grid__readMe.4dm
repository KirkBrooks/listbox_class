//%attributes = {}

$objects:={\
Text: {type: "text"; text: "Name :"; top: 57; left: 25; width: 91; height: 16}; \
Text1: {type: "text"; text: "Email :"; top: 97; left: 25; width: 91; height: 16}; \
Text2: {type: "text"; text: "Password :"; top: 137; left: 25; width: 91; height: 16}; \
Input: {type: "input"; left: 130; top: 57; width: 267; height: 17; dataSource: "Form.data.name"; placeholder: "   must be unique"}; \
Input1: {type: "input"; left: 130; top: 97; width: 267; height: 17; dataSource: "Form.data.email"; placeholder: "   joe@email.com"}; \
password: {type: "input"; left: 130; top: 137; width: 247; height: 17; dataSource: "Form.data.password"; placeholder: "  minimum of 16 characters"}; \
formerror: {type: "input"; left: 28; top: 174; width: 369; height: 65; enterable: False; contextMenu: "none"; focusable: False; borderStyle: "none"; fill: "transparent"; dataSource: "Form.error"; stroke: "#ff0000"}; \
btn_submit: {type: "button"; text: "Submit"; top: 230; left: 282; width: 117; height: 24; events: []; style: "roundedBevel"}; \
passwordLength: {type: "input"; left: 383; top: 137; width: 14; height: 17; dataSource: ""; placeholder: "  minimum of 16 characters"; borderStyle: "none"; fill: "transparent"; enterable: False; dataSourceTypeHint: "integer"; stroke: "#c0c0c0"}; \
Text3: {type: "text"; text: "New Customer"; top: 11; left: 12; width: 333; height: 32; fontSize: 24}\
}

// loop through objects and find limits of the form
$top:=10000
$left:=10000
$bottom:=0
$right:=0

For each ($key; $objects)
	$object:=$objects[$key]
	
	If ($object.top<$top)
		$top:=$object.top
	End if 
	
	If ($object.left<$left)
		$left:=$object.left
	End if 
	
	If ($object.top+$object.height>$bottom)
		$bottom:=$object.top+$object.height
	End if 
	
	If ($object.left+$object.width>$right)
		$right:=$object.left+$object.width
	End if 
	
End for each 

// The objects will be displayed in a grid
// Each object is placed relative to the top left corner of the grid so
// we need to calculate the offset of the grid from the top left corner of the form
$offsetTop:=$top*-1
$offsetLeft:=$left*-1

$rowHeight:=20
$colWidth:=40

// Loop through each object and calculate:
// row:
// column:
// rowSpan:
// colSpan:
// rounded to the nearest row or column

For each ($key; $objects)
	$object:=$objects[$key]
	
	$object.row:=Round(($object.top+$offsetTop)/$rowHeight; 0)
	$object.column:=Round(($object.left+$offsetLeft)/$colWidth; 0)
	$object.rowSpan:=Round(($object.top+$offsetTop+$object.height)/$rowHeight; 0)-$object.row
	$object.colSpan:=Round(($object.left+$offsetLeft+$object.width)/$colWidth; 0)-$object.column
End for each 

