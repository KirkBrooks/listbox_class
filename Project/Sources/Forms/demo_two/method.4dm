/*  demo_two - form method
 Created by: Kirk as Designer,

*/

var $objectName; $queryStr; $property; $name : Text
var $address_LB; $detail_LB : cs.listbox
var $obj : Object
var $collection : Collection
var $i : Integer

If (Form=Null)
	return 
End if 

$address_LB:=(Form.address_LB=Null) ? cs.listbox.new("address_LB") : Form.address_LB
$detail_LB:=(Form.detail_LB=Null) ? cs.listbox.new("detail_LB") : Form.detail_LB
$objectName:=String(FORM Event.objectName)

If (Form event code=On Timer)  //  set this selection in the listbox
/*  This only runs if we just selected a new listbox (data set)
AND there was something selected when we changed. That selection was blown
away when we loaded the class into the form. 
However, since we copied the selectedItems before that happened we can 
restore the listbox selection now. 
*/
	SET TIMER(0)  //  turn the time off
	LISTBOX SELECT ROWS(*; "address_LB"; Form.setSelection; lk replace selection)
	Form.setSelection:=Null
End if 

//mark:  --- object actions
Case of 
	: (Form event code=On Load)
		
		Form.listboxesDropDown:=New object(\
			"values"; Form.listboxes.extract("name"); \
			"index"; -1; \
			"currentValue"; "Select a data set")
		
		//  this is used for the query bar
		Form.queryParameters:=New object("street"; ""; "city"; ""; "state"; ""; "zip"; "")
		
		// the listboxes
		Form.address_LB:=$address_LB
		$address_LB.setSource(Form.entitySelection)
		
		Form.detail_LB:=$detail_LB  //  you don't need to load any data into the listbox to initialize it
		
	: ($objectName="listboxesDropDown")
		
		If (Form event code=On Data Change) && (Form.listboxesDropDown.currentValue#"")
			$collection:=Form.listboxes.query("name = :1"; Form.listboxesDropDown.currentValue)
			
			If ($collection.length=0)
				return 
			End if 
			
			$address_LB:=$collection[0].listbox.restore("address_LB")  //  get the listbox class selected
			
			If ($address_LB.selectedItems#Null)  //  are there any selected items?
				Form.setSelection:=$address_LB.selectedItems  // we will restore the selection once the listbox object is loaded
				SET TIMER(-1)  // will execute right after this event
			End if 
			
			Form.address_LB:=$address_LB  //  now the form is populated with the selected listbox class
			
		End if 
		
	: ($objectName="btn_save")
/*  This is simply going to prompt the user for a name and push the current .data
entity selection into a new class in the dropdown list.
		
To COPY or Not to COPY
As is each new data set contains the same references as the parent - so changes 
made to one appear on the other. If that's not what you want for some reason 
use $address_LB.data.copy() 
*/
		
		$name:=Request("What do you want to call this data set?")
		
		If (OK=1) && ($name#"")
			Form.listboxes.push(New object(\
				"name"; $name; \
				"listbox"; cs.listbox.new("address_LB").setSource($address_LB.data)))
			// update the dropdown collection
			Form.listboxesDropDown.values:=Form.listboxes.extract("name")
		End if 
		
	: ($objectName="btn_clearQuery")
		OBJECT SET VALUE("qry_@"; "")
		$address_LB.reset()
		
	: ($objectName="qry_@") && (Form event code=On After Edit)  //  one of the query fields
/*  Our little query widget will work just fine as is because it doesn't care how the
listbox is populated or which class is installed. Also, when we switch between one class
and another whatever was in .data stays as it was. But in those cases the user may have 
forgotten what criteria they are looking at. We can save the query values with the listbox
class. A class is just an object and we can add properties to it as we like. 
		
Take a look at the form and notice I associated a datasource with each of the query 
parameters. For example, Form.address_LB.qry_street. These will be added to the class as
needed and updated as needed. And since they are simple properties of the class they 
follow the class. 
		
Best of all the user can pick right up where they left off when the class is restored. 
		
Here's how that works.
  Form.queryParameters is going to be passed into the query. It's populated with whatever
data the user enters into the query fields. 
		
Form.queryParameters.street:=$objectName="qry_street" ? "@"+Get edited text+"@" : Form.queryParameters.street
This line says: 
   if the current object ($objectName) is "qry_street" then put the edited text in the parameters
   it it's not then keep what's already there
*/
		//  update the query parameters
		Form.queryParameters.street:=$objectName="qry_street" ? "@"+Get edited text+"@" : Form.queryParameters.street
		Form.queryParameters.city:=$objectName="qry_city" ? Get edited text+"@" : Form.queryParameters.city
		Form.queryParameters.state:=$objectName="qry_state" ? Get edited text+"@" : Form.queryParameters.state
		Form.queryParameters.zip:=$objectName="qry_zip" ? Get edited text+"@" : Form.queryParameters.zip
		
/*  build the query string
Loop through each of these parameters and If there is anything in them add it to the 
query string. We are doing a simple search so all we need to do is 'AND' each parameter
		
What does "("+$property+" = :"+$property+")" mean?
		
The loop is looking at the properties of Form.queryParameters - street, city, state, zip
I made sure to name the properties in Form.queryParameters to match the field names of ADDRESS
Finally, the property names in Form.queryParameters can be anything - so why not make them the 
name of the field we are searching on?
		
So, 
  "("+$property+" = :"+$property+")"
becomes 
  "(zip = :zip)" and in Form.queryParameters.zip the value is "@9403@"
*/
		$queryStr:=""
		
		For each ($property; Form.queryParameters)
			If (Form.queryParameters[$property]#"")
				$queryStr+=$queryStr#"" ? " AND " : ""
				$queryStr+="("+$property+" = :"+$property+")"
			End if 
		End for each 
		
/* now query the listbox source and put the results into listbox data
It doesn't matter if there are empty parameters, only the params in the query string are used. 
*/
		If ($queryStr#"")
			$address_LB.data:=$address_LB.source.query($queryStr; New object("parameters"; Form.queryParameters))
			$address_LB.redraw()
		Else 
			$address_LB.reset()
		End if 
		
	: ($objectName="address_LB")
		//  manage the user actions on the listbox
		Case of 
			: (Form event code=On Selection Change)  //  put the selected address into the detail listbox
				//  convert the object or entity into a key:value collection and display in the detail listbox
				
				$collection:=New collection()
				For each ($property; OB Keys($address_LB.currentItem))
					$collection.push(New object("key"; $property; "value"; $address_LB.currentItem[$property]))
				End for each 
				
				$detail_LB.setSource($collection)
		End case 
		
End case 

//mark:  --- update state, formats, etc.

// update a text variable showing the displayed state of the listbox
OBJECT SET VALUE("address_LB_state"; $address_LB.get_shortDesc())
// but we could use it for the window title too
SET WINDOW TITLE($address_LB.get_shortDesc())
//  hide the detail listbox if there is no selected address
OBJECT SET VISIBLE(*; "detail_LB"; $address_LB.isSelected)

