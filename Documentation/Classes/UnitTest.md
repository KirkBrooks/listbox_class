<!-- Type your summary here -->

## UnitTest Class

Light-weight unit testing for 4D.

The class can be used to create and evaluate a test in a single line or can be pushed onto a collection for further examination. 

### Install

Simply add the class to a project.

There is no UI for the class itself. The **ObjectProto** class is required also.

### Tests

There are three steps required to set up a test:

1) Instantiate the class with the description of what the test does
2) Enter the expected result of the test
3) Choose a ‘matcher’ function to evaluate an input and set the result

They must be done in order and the recommended pattern is to declare a constructor first because generally you’ll be making a lot of tests and having the constructor makes it easier and more readable.

```4D
$test:=cs.UnitTest   // constructor

$tests:=New Collection
$tests.push($test.new("1 is equal to 1").expect(1).toEqual(1))
$tests.push($test.new("1 is equal to 1")not().expect(1).toEqual(2))
```

`UnitTest` has a property: displayLine that summarizes each test into a single line. 

```
$test:=cs.UnitTest   // constructor

$tests:=""
$tests+=$test.new("1 is equal to 1").expect(1).toEqual(1).displayLine
$tests+=$test.new("1 is equal to 1")not().expect(1).toEqual(2).displayLine
ALERT($tests)
```

The `.displayLine` property is an easy way to see the results of the test.

- ✅   1 is equal to 1  (0 ms)
- ❌   1 is equal to 2  (0 ms)
- ⚠️ 1 is not equal to 2: Incompatible data type - only scalar values and formulas supported.

These are the three types of display you may see. Each is a text string and may be displayed in an alert.

If you wanted to have the results of each test for deeper analysis push them onto a collection and hand it off to a form. 

### Using Formulas for test values

`expect()` and most matcher functions can take a [4D Formula][https://developer.4d.com/docs/API/FunctionClass/]  as an input as long as the formula evaluates to an object, collection, number, boolean, date or text. There are several benefits chief among them is the ability to call Project methods and evaluate the results. 

```
$test:=cs.UnitTest   // constructor

$tests:=""
$tests+=$test.new("10+20 = 30").expect(Formula($1+$2);10;20).toEqual(30).displayLine
$tests+=$test.new("10+20 = 30").expect(Formula(MyMethod);10;20).toEqual(30).displayLine

ALERT($tests)

//  code for MyMethod
#DECLARE($a:real; $b:real):real
return $a + $b
```

Line 4 is a formula built on the fly that takes two arguments. Line 5 is a formula that calls a project method and passes the two parameters. 



### **Properties and Functions**

| Property    | Return Type | Descripton                                                   |
| ----------- | ----------- | ------------------------------------------------------------ |
| pass        | Boolean     | True when the test passes                                    |
| isErr       | Boolean     | True if there is an error                                    |
| error       | Text        |                                                              |
| description | Text        |                                                              |
| matcher     | Text        | name of matcher function. If `not()` is used it appears in the text. |
| displayline | Text        | Returns a text suitable for display in a listbox or text field based on the state of the object.<br />Ex:  ✅   get_item() should be null  (0 ms) |

| Function Name   | Parameters                                   | Return Type | Description                                                  |
| --------------- | -------------------------------------------- | ----------- | ------------------------------------------------------------ |
| Constructor     | `$description: Text`                         | cs.UnitTest | Initializes the object and sets the description.             |
| expect          | `$valueIn: Variant`                          | cs.UnitTest | The expected value or a Formula that evaluates to the expected value. |
|        **Matchers**                                                                   ||||
| toEqual         | `$input: Variant`                            | cs.UnitTest | Checks if input is equal to an expected value.<br />Input may be a **Formula** that evaluates to the expected value.<br />Otherwise it is a scalar value and must be the same data kind as expected value. |
| toBe            | `$input:Variant`                             | cs.UnitTest | Checks if an input is the same as the expected value depending on its type.<br />Input may be a **Formula** that evaluates to the expected value.<br />If dealing with an object or collection checks to see if this is they are the same _reference_ - that is, the same object and not simply the same values. Use `.toEqual()` or `.toContain()` to check values. |
| toMatch         | `$pattern: Text`                             | cs.UnitTest | Checks if a regular expression pattern matches the expected value.<br />Expected value must be text. |
| toContain       | `$input`                                  | cs.UnitTest | If the expected value is an object or entity checks to see if it contains  all the values in the input object.<br />Input may be a **Formula** that evaluates to an object or entity. |
| toBeNull        | None                                         | cs.UnitTest | Checks if the expected value is null.                        |
| not | None | cs.UnitTest | Reverses the reslut of the matcher. Basically syntatic sugar. |
| **Other Functions** |  |  |  |
| getExpectedValue | None | Variant | Returns the expected value |
| getExpectedValueStr | None | Text | Stringified expected value |
| getTestValue | None | Variant | Returns the test value |
| getTestValueStr | None | Text | Stringified test value |

​	
