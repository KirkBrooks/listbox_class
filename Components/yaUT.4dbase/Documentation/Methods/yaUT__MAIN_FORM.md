<!-- Type your summary here -->
## Description

This method opens the Main Window. From this window you can execute the unit test methods created in the database. To call it simply execute the method:

```
Show_UnitTestForm
```

To be included methods names must begin with “yaut_”

A given method can have any number of tests included in it. A good practice is to create one test for each ‘module’ or section of your database. 

## Example Unit test method

```4d
// yaut_demo
#DECLARE->$testCol : Collection
var $test : Object
var $str : Text

$testCol:=[Current method name] 
$test:=cs.UnitTest  //  make the constructor

//mark:  --- create the individal tests
$testCol.push($test.new("1 is equal to 1").expect(1).toEqual(1))
$testCol.push($test.new("1 is not equal to 5").expect(1).not().toEqual(5))
$testCol.push($test.new("1 is not null").expect(1).not().toBeNull())
$testCol.push("This is a break line")
$str:="This is a line of text"
$testCol.push($test.new("$str contains 'line of text'").expect($str).toMatch("l[\\w ]+text"))
$testCol.push($test.new("$str contains 'line of text'").expect($str).toMatch(123))
```

A unit test method will return a collection of test objects or text labels. When the method is run each test is evaluated and them results can be read from each element of the collection. 

Running methods from the Main Window provides an easy way to visualize these results but you can run the test methods and evaluate the results yourself as well. 
