
var $ui_msg; $objectName : Text
var $Address_LB : cs.listbox

If (Form=Null)
	return 
End if 

$objectName:=String(FORM Event.objectName)
$Address_LB:=Form.Address_LB=Null ? AddressAll("Address_LB") : Form.Address_LB

//mark:  --- object actions
Case of 
	: (FORM Event.code=On Load)  //  catches all objects
		Form.Address_LB:=$Address_LB
		
		
	: (FORM Event.code=On Clicked)
	: (FORM Event.code=On Selection Change)
		
		
		
End case 

//mark:  --- update state and formats
//Form.UI_message($ui_msg)
