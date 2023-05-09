/*  Form1 - form method
 Created by: Kirk as Designer, Created: 02/23/23, 09:00:30
 ------------------
*/

var $ui_msg; $objectName_t : Text
var $avg : Real

If (Form#Null)
	$objectName_t:=String(FORM Event.objectName)
	
	Case of 
		: (Form event code=On Load)  //  catches all objects
			Form.demo_LB:=cs.listbox.new("demo_LB")
			
			Form.demo_LB.setSource(New collection(\
				New object("date"; Current date; "number"; 123); \
				New object("date"; Current date+1; "number"; 456); \
				New object("date"; Current date-2; "number"; 56); \
				New object("date"; Current date-5; "number"; 98); \
				New object("date"; Current date+10; "number"; 3)))
			
		: (Form event code=On Clicked) && ($objectName_t="button")
			
			$avg:=Form.demo_LB.average("number")
			
			
		: (Form event code=On Selection Change)
	End case 
	
	//Form.UI_message($ui_msg)
End if 
