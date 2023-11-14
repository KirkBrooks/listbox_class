//%attributes = {}
/* Purpose: 
 ------------------
Adress_to_htmlTable ()
 Created by: Kirk as Designer, Created: 11/14/23, 11:00:07
*/
#DECLARE : Text
var $class : cs.HTMLtable
var $html : Text

$class:=cs.HTMLtable.new().setListbox(AddressAll("htmlTable"))  //  
$class.PKproperty:="ID"
$class.insertColumn("oneLine()").insertColumn("latitude"; {body: {format: "##0.00"}})
return $class.getTable()
