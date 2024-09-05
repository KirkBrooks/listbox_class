<!-- Type your summary here -->

## TestMethod class

This class is used by the **FullTest** class. It runs a test method. A test method is a method containing a number of Unit Tests which are collected in a collection. This class will take that method and run all the tests and make the results available. 

## **Setting up a Test Method**

A test method only requires you put each test into a collection and return that collection. Here’s the basic set up:

```4d
#DECLARE->$testsRun : Collection  //  the method returns a collection of the tests run
var $test : Object

$test:=cs.UnitTest  //  this is the test constructor
$testsRun:=[]  //  collection of tests to run

//mark:  --- create unit tests
```

Note: on line 4 you will use `$test:=cs.yaUT.UnitTest` if **yaUT** is a component. 

From this point on you just add your specific unit tests: 

```
$testsRun.push($test.new("1 is equal to 1").expect(1).toEqual(1))
$testsRun.push($test.new("1 is not equal to 5").expect(1).not().toEqual(5))
// ...
```

UnitTest has a special function called `.insertComment()`. This does just that - allows you to add a comment line to the collection. This is useful for identifying different blocks of test in a longer method. 

```
// I can insert a comment line into the collection
$testsRun.push($test.new().insertComment("This is my comment "))
```

### Running a TestMethod

If you are doing a FullTest you won’t need to think about this. However, you may want to run your test methods by itself. You can simply run the method. UnitTests are evaluated when the method runs. The test and the results are all collected in the collection. You can put a break point at the end of the method to look at those results in the debugger. 

Another option is to instantiate `TestMethod` class and run the tests from there. This is handy when you want to quickly look at the results of a test method in a simple ALERT. Here’s how you do that:

```
cs.TestMethod.new("yaUT_example_1").run().displayAlert()
```

Pretty cool. You instantiate the class by giving it the method to run. Add the `.run()` function and then the `.displayAlert()` function. A nice little one-liner to see the results of your method. 

You can also use `TestMethod` to write the results to a file. You pass a `file handle` to the class:

```
var $class : cs.TestMethod

$class:=cs.TestMethod.new("yaUT_example_1").run()

$file:=Folder(fk desktop folder).file("testlog.txt")
$class.writeToLog($file.open("write"))
SHOW ON DISK($file.platformPath)
```

### **Properties and Functions**

| Property    | Return Type | Descripton                                                   |
| ----------- | ----------- | ------------------------------------------------------------ |
| pass        | Boolean     | True when all tests in the method pass                       |
| isErr       | Boolean     | True if there is an error                                    |
| error       | Text        | Description of the error                                     |
| isValid     | Boolean     | True if the method exists                                    |
| countTests  | Integer     | Number of tests in the method                                |
| displayline | Text        | Returns a text suitable for display in a listbox or text field based on the state of the object. Ex: ✅ get_item() should be null (0 ms) |
| countPass   | Integer     | Number of tests passed                                       |
| countFail   | Integer     | Number of tests failed                                       |
| countErr    | Integer     | Number of errors                                             |
| name        | text        | Method name                                                  |

| Function Name  | Parameters  | Return Type   | Description                                                  |
| -------------- | ----------- | ------------- | ------------------------------------------------------------ |
| run            | none        | cs.TestMethod | Runs the tests in the method                                 |
| getResults     | none        | Collection    | Returns a scalar collection of the displayline for each test and comment |
| getFullResults | none        | Collections   | Returns the full collection of tests and comments            |
| writeToLog     | File Handle | none          | Writes the result collection to the file                     |
