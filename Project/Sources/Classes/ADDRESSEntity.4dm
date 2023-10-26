
Class extends Entity

Function oneLine()->$text : Text
	//  return the address in 1 line
	
	$text:=This.street ? This.street+", " : ""
	$text+=This.street2 ? This.street2+", " : ""
	$text+=This.city ? This.city+", " : ""
	$text+=This.state ? This.state+" " : ""
	$text+=This.zip ? This.zip : ""
	
	return $text
	
	