//%attributes = {}
/*  Another take on creating a listbox with html
This time we use CSS Grid

The basic idea is each element of the listbox is a CSS grid defining the
columns a property is in.

The listbox itself is a grid of rows.

BENEFITS OF THIS APPROACH
 - each listbox row can have multiple rows of data
 - a column can span more than one row
 - reactive

THE GRID DIV
	<div class='lb-grid'>                          $tempGrid

		<div class='lb-grid-header'>               $tempHdr
			<div class='lb-header-cell'>kind</div> $textHdrCell
		</div>

		<div class='lb-grid-body'>                 $tempBody
			<div class='lb-grid-row'>              $tempRow
				<div class='lb-cell'>kind</div>    $tempRowCell
			</div>
		</div>
	</div

*/

var $columns : cs._LB_columns
var $CSSgrid : cs.CSSgrid
var $html : Text

$columns:=cs._LB_columns.new(ds.ADDRESS)

$CSSgrid:=cs.CSSgrid.new().setSource(ds.ADDRESS.all().slice(0; 25))

$html:=$CSSgrid.getBodyDiv()
SET TEXT TO PASTEBOARD($html)









////mark:  --- templates
//// these templates are used to build the elements of the grid
//var $headerRow; $tempRowCell; $tempRow; $tempHdr; $tempGrid; $temp : Text

//$tempGrid:="<div class='lb-grid'>\n"
//$tempGrid+="<!--#4DHTML $1-->"
//$tempGrid+="</div>\n"

//$tempHdr:="<div class='lb-grid-header'>\n"
//$tempHdr+="<!--#4DHTML $1-->"
//$tempHdr+="</div>\n"

//$tempHdrCell:="<div class='lb-header-cell'><!--#4DHTML $1--></div>\n"

//$tempGridBody:="<div class='lb-grid-body'>\n"
//$tempGridBody+="<!--#4DHTML $1-->"
//$tempGridBody+="</div>\n"

//$tempRow:="<div class='lb-grid-row'>\n"
//$tempRow+="<!--#4DHTML $1-->"
//$tempRow+="</div>\n"

//$tempRowCell:="<div class='lb-cell'><!--#4DHTML $1--></div>\n"

////mark:  ---  get some records
//var $adrs_LB : cs.listbox
//$adrs_LB:=cs.listbox.new("adrs_LB").setSource(ds.ADDRESS.all().slice(0; 25))

//// decide on the fields
//$fields:=["kind"; "street"; "city"; "state"; "zip"; "source"; "latitude"; "longitude"]

////mark:  --- divs
//// these are the specific divs that make up the grid
//var $headerDiv : Text

////mark:  header div
//$headerDiv:=""
//For each ($field; $fields)
//PROCESS 4D TAGS($tempHdrCell; $temp; $field)
//$headerDiv+=$temp
//End for each 

//PROCESS 4D TAGS($tempHdr; $headerDiv; $headerDiv)
//SET TEXT TO PASTEBOARD($headerDiv)

////mark:  body div
//$body:=""

//For each ($entity; $es)
//$row:=""

//For each ($field; $fields)
//PROCESS 4D TAGS($tempRowCell; $temp; String($entity[$field]))
//$row+=$temp
//End for each 

//PROCESS 4D TAGS($tempRow; $row; $row)
//$body+=$row
//End for each 

//PROCESS 4D TAGS($tempGridBody; $body; $body)
//SET TEXT TO PASTEBOARD($body)

////mark:  --- complete the grid

//PROCESS 4D TAGS($tempGrid; $html; $headerDiv+"\n"+$body)
//SET TEXT TO PASTEBOARD($html)
