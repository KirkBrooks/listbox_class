/*  scalar_listbox - form method
 Created by: Kirk as Designer, Created: 07/15/23, 09:13:39
 ------------------
*/

var $objectName : Text
var $scalar_LB : cs.listbox

If (Form=Null)
	return 
End if 

$objectName:=String(FORM Event.objectName)
$scalar_LB:=Form.scalar_LB ? Form.scalar_LB : cs.listbox.new("scalar_LB")

//mark:  --- object actions
Case of 
	: (Form event code=On Load)  //  catches all objects
		Form.scalar_LB:=$scalar_LB
		
		$scalar_LB.setSource(New collection(1; 2; 3; 4; 5; 6; 7; 8; 9; 10))
		
	: (Form event code=On Clicked)
	: (Form event code=On Selection Change)
End case 

//mark:  --- update state and formats
//Form.UI_message($ui_msg)
