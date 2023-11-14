//%attributes = {}


$entity:=ds.ADDRESS.query("street = :1"; "4496 Leo Street").first()


$entity.state:="XX"
$entity.save()
