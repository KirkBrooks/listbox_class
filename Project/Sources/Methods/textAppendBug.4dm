//%attributes = {}

var $text : Text

$text:="<tr>"
$text+="<td><!--#4DTEXT $1 --></td>"
$text+="</tr>"

TRACE
$text+="< tr>"
$text[[Length($text)-3]]:="/"


$text:=Insert string($text; "</tr>"; 100)



$text:="<td><!--#4DTEXT $1 --></td>"

TRACE
$text:="<tr>"+$text+"</tr>"
