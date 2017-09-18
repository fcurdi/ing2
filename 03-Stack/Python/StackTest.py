#
# Developed by 10Pines SRL
# License: 
# This work is licensed under the 
# Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License. 
# To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/3.0/ 
# or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, 
# California, 94041, USA.
#  

import unittest


class Stack:
    STACK_EMPTY_DESCRIPTION = 'Stack is empty'

    def __init__(self):
        self._top = NoStackTop()

    def push(self, anObject):
        self._top = ConcreteStackTop(anObject, self._top)

    def pop(self):
        topElement = self._top.value()
        self._top = self._top.stackedUpon()
        return topElement

    def top(self):
        return self._top.value()

    def isEmpty(self):
        return self._top.isEmpty()

    def size(self):
        return self._top.size()


class StackTop:

    def stackedUpon(self):
        self.shouldBeImplementedBySubclass()

    def value(self):
        self.shouldBeImplementedBySubclass()

    def isEmpty(self):
        self.shouldBeImplementedBySubclass()

    def size(self):
        self.shouldBeImplementedBySubclass()

    def shouldBeImplementedBySubclass(self):
        raise NotImplementedError('Should be implemented by the subclass')


class ConcreteStackTop(StackTop):

    def __init__(self, value, stackTop):
        self._value = value
        self._stackedUpon = stackTop

    def stackedUpon(self):
        return self._stackedUpon

    def value(self):
        return self._value

    def isEmpty(self):
        return False

    def size(self):
        return 1 + self._stackedUpon.size()


class NoStackTop(StackTop):

    def stackedUpon(self):
        raise Exception(Stack.STACK_EMPTY_DESCRIPTION)

    def value(self):
        raise Exception(Stack.STACK_EMPTY_DESCRIPTION)

    def isEmpty(self):
        return True

    def size(self):
        return 0

class StackTest(unittest.TestCase):
    def testStackShouldBeEmptyWhenCreated(self):
        stack = Stack()

        self.assertTrue(stack.isEmpty())

    def testPushAddElementsToTheStack(self):
        stack = Stack()
        stack.push('something')

        self.assertFalse(stack.isEmpty())

    def testPopRemovesElementsFromTheStack(self):
        stack = Stack()
        stack.push("Something")
        stack.pop()

        self.assertTrue(stack.isEmpty())

    def testPopReturnsLastPushedObject(self):
        stack = Stack()
        pushedObject = "Something"
        stack.push(pushedObject)
        self.assertEquals(pushedObject, stack.pop())

    def testStackBehavesLIFO(self):
        firstPushed = "First"
        secondPushed = "Second"
        stack = Stack()
        stack.push(firstPushed)
        stack.push(secondPushed)

        self.assertEquals(secondPushed, stack.pop())
        self.assertEquals(firstPushed, stack.pop())
        self.assertTrue(stack.isEmpty())

    def testTopReturnsLastPushedObject(self):
        stack = Stack()
        pushedObject = "Something"

        stack.push(pushedObject)

        self.assertEquals(pushedObject, stack.top())

    def testTopDoesNotRemoveObjectFromStack(self):
        stack = Stack()
        pushedObject = "Something"

        stack.push(pushedObject)

        self.assertEquals(1, stack.size())
        stack.top()
        self.assertEquals(1, stack.size())

    def testCanNotPopWhenThereAreNoObjectsInTheStack(self):
        stack = Stack()

        try:
            stack.pop()
            self.fail()
        except Exception as stackIsEmpty:
            self.assertEquals(Stack.STACK_EMPTY_DESCRIPTION, stackIsEmpty.message)

    def testCanNotTopWhenThereAreNoObjectsInTheStack(self):
        stack = Stack()

        try:
            stack.top()
            self.fail()
        except Exception as stackIsEmpty:
            self.assertEquals(Stack.STACK_EMPTY_DESCRIPTION, stackIsEmpty.message)


if __name__ == "__main__":
    unittest.main()
