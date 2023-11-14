//%attributes = {}

var $entity : cs.ADDRESSEntity
$entity:=ds.ADDRESS.query("street = :1"; "4496 Leo Street").first()


$entity.state:="XX"
$entity.save()
