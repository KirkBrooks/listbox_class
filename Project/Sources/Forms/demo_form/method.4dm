/*  demo_form - form method
 Created by: Kirk as Designer, Created: 07/12/23, 09:24:06
 ------------------
This form demonstrates uses for the listbox class and my suggestions for best practice intializing and
working with them. 

I used a second listbox for displaying the Address details mainly to have a reson for a second listbox. 
It's not a bad way to quickly dislpay a record. The main point is to show how easy it is to manage 
multiple listboxes on a form when each one has its own class. 

I avoid putting code in form objects. With ORDA it's possible to implement a true MVC approach to 
managing a form but that is down the drain when you start loading up form objects with code. By 
handling all the form actions from the form method you have much better visibility on what the
form is doing. You can still hand off longer operations to other methods, for example. 

While we don't stictly have a 'controller' object using the form method as the primary
controller of the form objects is a good start. Avoid managing data in the form method and avoid 
managing form objects in the data classes. (Yes, I violate this with the two functions in the listbox
class that deal with selecting rows.)

Bear in mind you can hand off an instance of the listbox class to another method. You could also hand
off the $class.data. This is really the point - the listbox class makes managing the data in the listbox
easy to do. With ORDA you don't need to use the listbox form object to access the data. You have the data
and you have the selected data. Use that and the listbox will update itself. 

And - yes - this does mean most of your old, cherished, classic code for managing listboxes is not 
particularly helpful. The good news is you need hardly any of it to work with ORDA anyway!

RECORD vs COLLECTION DATA
This is an interesting feature. The source of the address data is a data generator - it's all fake. 
The records and the JSON file have the same data but in slightly different formats and different
property names. I wanted to show how easy it is to switch between displaying collection and 
entity selection data in the same listbox wo you can toggle between the two. The lsitbox behaves
exactly the same way with either data source but you can see the difference in the underlying objects
in the detail section. 

Note this is why some of the actions, notably the query seciton, looks more complicated. It's really
not very complicated if you take out the tricky source switching I've done. 

BTW - this also illustrates how to change the datasource on a collection based listbox. 

EDITING THE DATA
I purposely made everything non-enterable to avoid too much complication stemming from you being able to switch 
between displaying the JSON or record based data. In practice if you have a form that allows this sort
of thing it's going to require a bit of fiddling to manage between what you do with the two kinds of 
data. It's not hard but it's tedious. My intent was to show how flexible the listbox class and more agnostic
to the data type. 

NOTES ON THE QUERY SCHEME
The query scheme is mainly to show how to take advantage of the source and data properties but 
there's no reason you couldn't be doing queries on another source and populating the listbox with 
the results too. 

The data in the records is the same as in the collection. However, the property names in the 
collection are different and that's why there's a little extra code to manage that. 

*/

var $objectName; $queryStr; $property : Text
var $address_LB; $detail_LB : cs.listbox
var $collection : Collection
var $i : Integer

If (Form=Null)
	return 
End if 

$objectName:=String(FORM Event.objectName)

/*  this is optional but I find it really useful to put the listbox class into an object
when the object is delcared as the class it gives you the correct dropdowns and typeahead
prompts for the class. 

Why am I checking Form.address_LB=Null ? 
Because the listbox class is not tied to the form it can be populated before the form
is opened or it could be saved and reused. On the other hand I always want $address_LB
to be a valid class because I use it a the bottom of the form to set the state of some
form objects. 
*/
$address_LB:=(Form.address_LB=Null) ? cs.listbox.new("address_LB") : Form.address_LB
$detail_LB:=(Form.detail_LB=Null) ? cs.listbox.new("detail_LB") : Form.detail_LB



//mark:  --- object actions
Case of 
	: (Form event code=On Load)
		//  this is used for the inputs from the query bar
		Form.queryParameters:=New object("street"; ""; "city"; ""; "state"; ""; "zip"; "")
		
		//mark:  --- the data
/*  for this demo I'm going to load the ADDRESS records as an ENTITY SELECTION first
We can also load the same data as a COLLECTION from a JSON file
		
This is to show how the listbox is agnostic to the type of data it's 
handling. 
*/
		Form.entitySelection:=Address_getRecords
		Form.collectionData:=ReadAddressDataFile
		
		
		//mark:  ---  the listboxes
/* for this demo I know the listboxes aren't populated before the form opens. 
In this line I'm going to put the data I want to work with into $address_LB
and then put $address_LB into Form.
		
.setSource() loads a collection or entity selection and configures the class 
for that kind of data. 
*/
		Form.address_LB:=$address_LB.setSource(Form.entitySelection)
		
		// this is the listbox that shows the record detail on the right side of the form
		Form.detail_LB:=$detail_LB  //  you don't need to load any data into the listbox to initialize it
		
		//  these two collections are here to swap between a collection and record detail data
		Form.es_properties:=New collection(Null; "street"; "city"; "state"; "zip")
		Form.co_properties:=New collection(Null; "StreetAddress"; "City"; "State"; "ZipCode")
		
		
	: ($objectName="btn_dataType")
/* Toggles the data between entity selection and collection
The collection object have different properties than the records do. 
There are 2 things I need to change: 
1)  change the name of the datasource for the 4 columns in the address listbox
2)  load the other data into it
*/
		If ($address_LB.isEntitySelection)
			For ($i; 1; 4)
				LISTBOX SET COLUMN FORMULA(*; "column"+String($i); "This."+Form.co_properties[$i]; Is text)
			End for 
			
			$address_LB.setSource(Form.collectionData)
		Else 
			For ($i; 1; 4)
				LISTBOX SET COLUMN FORMULA(*; "column"+String($i); "This."+Form.es_properties[$i]; Is text)
			End for 
			$address_LB.setSource(Form.entitySelection)
		End if 
		
	: ($objectName="btn_clearQuery")
		OBJECT SET VALUE("qry_@"; "")
		$address_LB.reset()
		
	: ($objectName="qry_@") && (Form event code=On After Edit)  //  one of the query fields changed
		//mark:  --- query the listbox
/*  There is a great deal more detailed commentary about how this query works on the demo_two form.
Here we have 4 inputs for search values for the 4 columns. 
		
I'm going to use Form.queryParameters to hold the values the query will use and pass this object
into .query() as 'parameters'. 
see:  https://developer.4d.com/docs/API/DataClassClass#query:~:text=Passing%20parameters%20to%20formulas
*/
		If ($objectName="qry_street")
			Form.queryParameters.street:=Get edited text+"@"
		End if 
		
		//  here's the same code written using the ternary operator
		Form.queryParameters.city:=$objectName="qry_city" ? Get edited text+"@" : Form.queryParameters.city
		Form.queryParameters.state:=$objectName="qry_state" ? Get edited text+"@" : Form.queryParameters.state
		Form.queryParameters.zip:=$objectName="qry_zip" ? Get edited text+"@" : Form.queryParameters.zip
		
		//  build the query string. I'm using 
		$queryStr:=""
		
		If ($address_LB.isEntitySelection)
			//  the $property names on the form are the same as in the ADDRESS table
			
			For each ($property; Form.queryParameters)
				If (Form.queryParameters[$property]#"")
					$queryStr+=$queryStr#"" ? " AND " : ""
					$queryStr+="("+$property+" = :"+$property+")"
				End if 
			End for each 
		End if 
		
		If ($address_LB.isCollection)
			// the $property names of in the collection are not the same as here on the form
			// I use a quick and dirty lookup scheme to map them.
			
			For ($i; 1; 4)
				$property:=Form.es_properties[$i]
				
				If (Form.queryParameters[$property]#"")
					$queryStr+=$queryStr#"" ? " AND " : ""
					$queryStr+="("+Form.co_properties[$i]+" = :"+$property+")"
				End if 
				
			End for 
		End if 
		
/*  the qeury string is 
  now query the listbox source and put the results into listbox data
To do this pass the query string and settings object to .doQuery()
Using .doQuery() insures the listbox is properly redraw after the query.
*/
		
		If ($queryStr#"")
			$address_LB.doQuery($queryStr; New object("parameters"; Form.queryParameters))
		Else 
			$address_LB.reset()
		End if 
		
	: ($objectName="address_LB")
		//  manage the user actions on the listbox
		Case of 
			: (Form event code=On Selection Change)  //  put the selected address into the detail listbox
				//  convert the object or entity into collection
				// => notice this code doesn't care whether this is the collection or entity selection data
				$collection:=New collection()
				For each ($property; OB Keys($address_LB.currentItem))
					$collection.push(New object("key"; $property; "value"; $address_LB.currentItem[$property]))
				End for each 
				
				$detail_LB.setSource($collection)
		End case 
		
End case 

//mark:  --- update state, formats, etc.
OBJECT SET TITLE(*; "btn_dataType"; $address_LB.isEntitySelection ? "Entity Selection" : "Collection")
// update a text variable showing the displayed state of the listbox
OBJECT SET VALUE("address_LB_state"; $address_LB.get_shortDesc())
// but we could use it for the window title too
SET WINDOW TITLE($address_LB.get_shortDesc())
//  hide the detail listbox if there is no selected address
OBJECT SET VISIBLE(*; "detail_LB"; $address_LB.isSelected)

