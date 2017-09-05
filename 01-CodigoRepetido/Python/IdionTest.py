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
import time


class CustomerBook:
    CUSTOMER_NAME_CAN_NOT_BE_EMPTY = 'Customer name can not be empty'
    CUSTOMER_ALREADY_EXIST = 'Customer already exists'
    INVALID_CUSTOMER_NAME = 'Invalid customer name'

    def __init__(self):
        self.customerNames = set()

    def addCustomerNamed(self, name):
        # El motivo por el cual se hacen estas verificaciones y se levanta esta excepcion es por motivos del
        # ejercicio - Hernan.
        if not name:
            raise ValueError(self.__class__.CUSTOMER_NAME_CAN_NOT_BE_EMPTY)
        if self.includesCustomerNamed(name):
            raise ValueError(self.__class__.CUSTOMER_ALREADY_EXIST)

        self.customerNames.add(name)

    def isEmpty(self):
        return self.numberOfCustomers() == 0

    def numberOfCustomers(self):
        return len(self.customerNames)

    def includesCustomerNamed(self, name):
        return name in self.customerNames

    def removeCustomerNamed(self, name):
        # Esta validacion mucho sentido no tiene, pero esta puesta por motivos del ejericion - Hernan
        if not self.includesCustomerNamed(name):
            raise KeyError(self.__class__.INVALID_CUSTOMER_NAME)

        self.customerNames.remove(name)


class IdionTest(unittest.TestCase):

    def setUp(self):
        self.customerBook = CustomerBook()

    def testAddingCustomerShouldNotTakeMoreThan50Milliseconds(self):
        self.assertThatAnOperationDoesNotTakeMoreThanMilliseconds(lambda: self.customerBook.addCustomerNamed('John Lennon'), 50)

    def testRemovingCustomerShouldNotTakeMoreThan100Milliseconds(self):
        paulMcCartney = 'Paul McCartney'
        self.customerBook.addCustomerNamed(paulMcCartney)

        self.assertThatAnOperationDoesNotTakeMoreThanMilliseconds(lambda: self.customerBook.removeCustomerNamed(paulMcCartney), 100)

    def testCanNotAddACustomerWithEmptyName(self):

        def assertions(anException):
            self.assertEquals(anException.message, CustomerBook.CUSTOMER_NAME_CAN_NOT_BE_EMPTY)
            self.assertTrue(self.customerBook.isEmpty())

        self.anOperationShouldFailWithExceptionAndAssert(lambda: self.customerBook.addCustomerNamed(''), ValueError, assertions)

    def testCanNotRemoveNotAddedCustomer(self):
        self.customerBook.addCustomerNamed('Paul McCartney')

        def assertions(anException):
            self.assertEquals(anException.message, CustomerBook.INVALID_CUSTOMER_NAME),
            self.assertTrue(self.customerBook.numberOfCustomers() == 1),
            self.assertTrue(self.customerBook.includesCustomerNamed('Paul McCartney'))

        self.anOperationShouldFailWithExceptionAndAssert(lambda: self.customerBook.removeCustomerNamed('John Lennon'), KeyError, assertions)

    def anOperationShouldFailWithExceptionAndAssert(self, anOperation, exception, assertions):
        try:
            anOperation()
            self.fail()
        except exception as anException:
            assertions(anException)

    def assertThatAnOperationDoesNotTakeMoreThanMilliseconds(self, anOperation, milliseconds):
        timeBeforeRunning = time.time()
        anOperation()
        timeAfterRunning = time.time()
        self.assertTrue((timeAfterRunning - timeBeforeRunning) * 1000 < milliseconds)


if __name__ == "__main__":
    unittest.main()





