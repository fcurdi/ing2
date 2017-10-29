!classDefinition: #TusLibrosTest category: #TusLibros!
TestCase subclass: #TusLibrosTest
	instanceVariableNames: 'isbnInCatalog isbnNotInCatalog catalog cart creditCardNumber anotherIsbnInCatalog notExpiredCreditCard expiredCreditCard salesBook'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'TusLibros'!

!TusLibrosTest methodsFor: 'cart' stamp: 'F C 10/29/2017 19:58:22'!
test01ANewCartIsAlwaysEmpty

	self assert: cart isEmpty.! !

!TusLibrosTest methodsFor: 'cart' stamp: 'F C 10/29/2017 19:59:36'!
test02

	cart add: isbnInCatalog.
	
	self deny: cart isEmpty.
	self assert: cart size equals: 1.
	self assert: (cart includes: isbnInCatalog).! !

!TusLibrosTest methodsFor: 'cart' stamp: 'F C 10/29/2017 18:36:50'!
test03

	cart add: 2 of: isbnInCatalog.
	
	self deny: cart isEmpty.
	self assert: cart size equals: 2.
	self assert: (cart quantiyOf: isbnInCatalog) equals: 2.! !

!TusLibrosTest methodsFor: 'cart' stamp: 'F C 10/29/2017 20:00:30'!
test04CannotAddToCartAnItemThatIsNotInCatalog
	
	self should: [cart add: isbnNotInCatalog ] raise: Error withExceptionDo: [ :anError | 
		self assert: anError messageText equals: 'cannot add an isbn that is not in the catalog'.
		self assert: cart isEmpty.
	].! !

!TusLibrosTest methodsFor: 'cart' stamp: 'F C 10/29/2017 20:00:03'!
test05AddingAnInvalidQunatityOfAnItemRaisesAnException

	{ 0 . -1 . 3/2 } do: [ :aQuantity |
		self should: [	cart add: aQuantity of: isbnInCatalog.] raise: Error withExceptionDo: [ :anError | 
			self assert: anError messageText equals: 'invalid quantity'.
			self assert: cart isEmpty.
		].
	].! !


!TusLibrosTest methodsFor: 'cashier' stamp: 'F C 10/29/2017 19:38:20'!
test06CannotCheckoutAnEmptyCart

	| cashier |

	cashier _ Cashier withCart: cart withCreditCard: notExpiredCreditCard andSalesBook: salesBook on: Date today.
	
	self should: [ cashier checkout]
	 	  raise: Error - MessageNotUnderstood 
		  withExceptionDo: [ :anError | 
			self assert: anError messageText  equals: 'cannot create an empty cart'.
			self assert:  salesBook isEmpty.
		  ].
	! !

!TusLibrosTest methodsFor: 'cashier' stamp: 'F C 10/29/2017 19:38:36'!
test07CannotCheckoutWithExpiredCreditCard

	| cashier |

	cart add: isbnInCatalog .
	cashier _  Cashier withCart: cart withCreditCard: expiredCreditCard andSalesBook: salesBook on: Date today.
	
	self should: [ cashier checkout ]
	 	  raise: Error - MessageNotUnderstood 
		  withExceptionDo: [ :anError | 
			self assert: anError messageText  equals: 'cannot checkout with expired credit card'.
			self assert: salesBook isEmpty.
		  ].
	! !

!TusLibrosTest methodsFor: 'cashier' stamp: 'F C 10/29/2017 20:02:38'!
test08CheckoutRegistersTheSaleCorrectlyInTheSalesBook

	| cashier receipt expectedTotal |
	
	cart add: 2 of: isbnInCatalog.
	cart add: 1 of: anotherIsbnInCatalog.
	cashier _ Cashier withCart: cart withCreditCard: notExpiredCreditCard andSalesBook: salesBook on: Date today.
	
	receipt _ cashier checkout.
	expectedTotal _ ((catalog at: isbnInCatalog) * 2) + (catalog at: anotherIsbnInCatalog). 
	
	self assert: salesBook size equals: 1.
	self assert: (salesBook includes: receipt ).
	self assert: receipt amount equals: expectedTotal.
	self assert: (receipt quantityFor: isbnInCatalog) equals: 2.
	self assert: (receipt quantityFor: anotherIsbnInCatalog) equals: 1.	

! !


!TusLibrosTest methodsFor: 'setup' stamp: 'F C 10/29/2017 19:34:47'!
setUp

	| expiredDate notExpiredDate |
	
	isbnInCatalog _ '123'.
	anotherIsbnInCatalog _ '789'.
	isbnNotInCatalog _ '456'.
	catalog _ Dictionary new.
	catalog at: isbnInCatalog put: 10.
	catalog at: anotherIsbnInCatalog put: 30.
	cart _ Cart with: catalog.
	expiredDate _ (Date year: Date today year yearNumber month: Date today month previous monthIndex day: 1) month.
	notExpiredDate _ (Date year: Date today year yearNumber month: Date today month monthIndex day: 1) month.
	notExpiredCreditCard _ CreditCard withOwner: 'pepe' andNumber: '1234678956784235'  andExpiryDate: notExpiredDate.
	expiredCreditCard _ CreditCard withOwner: 'pepe' andNumber: '1234678956784235'  andExpiryDate: expiredDate.
	salesBook _ OrderedCollection new.! !


!classDefinition: #Cart category: #TusLibros!
Object subclass: #Cart
	instanceVariableNames: 'items catalog'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'TusLibros'!

!Cart methodsFor: 'as yet unclassified' stamp: 'FC_LR 10/26/2017 20:25:30'!
add: anItem 
	
	self add: 1 of: anItem.! !

!Cart methodsFor: 'as yet unclassified' stamp: 'F C 10/29/2017 18:40:57'!
add: aQuantity of: anItem 
	
	(catalog includesKey: anItem) ifFalse: [self error: 'cannot add an isbn that is not in the catalog'].
	(aQuantity isInteger and: [ aQuantity strictlyPositive ]) ifFalse: [self error: 'invalid quantity'].
	items add: anItem withOccurrences: aQuantity.! !

!Cart methodsFor: 'as yet unclassified' stamp: 'F C 10/29/2017 18:53:35'!
catalog

	^catalog copy.! !

!Cart methodsFor: 'as yet unclassified' stamp: 'FC_LR 10/26/2017 20:05:45'!
includes: anItem 
	
	^items includes: anItem.! !

!Cart methodsFor: 'as yet unclassified' stamp: 'FC_LR 10/26/2017 20:36:07'!
initializeWith: aCatalog 
	
	items _ Bag new.
	catalog _ aCatalog. ! !

!Cart methodsFor: 'as yet unclassified' stamp: 'FC_LR 10/26/2017 19:54:37'!
isEmpty
	
	^items isEmpty.! !

!Cart methodsFor: 'as yet unclassified' stamp: 'F C 10/29/2017 18:52:26'!
itemsDo: aBlockClosure

	items do: [ :item | aBlockClosure value: item ].! !

!Cart methodsFor: 'as yet unclassified' stamp: 'FC_LR 10/26/2017 20:20:10'!
quantiyOf: anItem 
	
	^items occurrencesOf: anItem.! !

!Cart methodsFor: 'as yet unclassified' stamp: 'FC_LR 10/26/2017 20:03:19'!
size
	
	^items size.! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

!classDefinition: 'Cart class' category: #TusLibros!
Cart class
	instanceVariableNames: ''!

!Cart class methodsFor: 'as yet unclassified' stamp: 'FC_LR 10/26/2017 20:35:55'!
with: aCatalog 
	
	^ self new initializeWith: aCatalog.! !


!classDefinition: #Cashier category: #TusLibros!
Object subclass: #Cashier
	instanceVariableNames: 'cart creditCard salesBook date'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'TusLibros'!

!Cashier methodsFor: 'as yet unclassified' stamp: 'F C 10/29/2017 19:56:21'!
checkout

	| catalog total purchases receipt |

	cart isEmpty ifTrue: [ self error: 'cannot create an empty cart' ].

	(creditCard expiryDate year yearNumber >= date year yearNumber and: [ creditCard expiryDate monthIndex >= date month monthIndex]) 
		ifFalse: [ self error: 'cannot checkout with expired credit card' ].
		
	catalog _ cart catalog.	
	total _ 0.
	purchases _ OrderedCollection new.
	cart itemsDo: [ :item | 
		total _ total + (catalog at: item).
		purchases add: item.
	].
	self debit.
	receipt _ Receipt with: total andPurchases: purchases.
	salesBook add: receipt.
	^receipt.
	
	! !

!Cashier methodsFor: 'as yet unclassified' stamp: 'F C 10/29/2017 19:11:29'!
debit
! !

!Cashier methodsFor: 'as yet unclassified' stamp: 'F C 10/29/2017 19:31:08'!
initializeWithCart: aCart andCreditCard: aCreditCard andSalesBook: aSalesBook andDate: aDate

	cart _ aCart.
	creditCard _ aCreditCard.
	salesBook _ aSalesBook.
	date _ aDate.! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

!classDefinition: 'Cashier class' category: #TusLibros!
Cashier class
	instanceVariableNames: ''!

!Cashier class methodsFor: 'as yet unclassified' stamp: 'F C 10/29/2017 19:30:10'!
withCart: aCart withCreditCard: aCreditCard andSalesBook: aSalesBook on: aDate

	^self new initializeWithCart: aCart andCreditCard: aCreditCard andSalesBook: aSalesBook andDate: aDate.! !


!classDefinition: #CreditCard category: #TusLibros!
Object subclass: #CreditCard
	instanceVariableNames: 'owner number expiryDate'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'TusLibros'!

!CreditCard methodsFor: 'as yet unclassified' stamp: 'F C 10/29/2017 19:24:22'!
expiryDate

	^expiryDate.! !

!CreditCard methodsFor: 'as yet unclassified' stamp: 'F C 10/29/2017 19:23:41'!
initializeWith: anOwner andNumber: aNumber andExpiryDate: aMonthOfYear

	owner _ anOwner.
	number _ aNumber.
	expiryDate _ aMonthOfYear.! !

!CreditCard methodsFor: 'as yet unclassified' stamp: 'F C 10/29/2017 19:24:04'!
number

	^number.! !

!CreditCard methodsFor: 'as yet unclassified' stamp: 'F C 10/29/2017 19:23:51'!
owner

	^owner.! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

!classDefinition: 'CreditCard class' category: #TusLibros!
CreditCard class
	instanceVariableNames: ''!

!CreditCard class methodsFor: 'as yet unclassified' stamp: 'F C 10/29/2017 19:23:12'!
withOwner: anOwner andNumber: aNumber andExpiryDate: aMonthOfYear

	^self new initializeWith: anOwner andNumber: aNumber andExpiryDate: aMonthOfYear.! !


!classDefinition: #Receipt category: #TusLibros!
Object subclass: #Receipt
	instanceVariableNames: 'amount purchases'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'TusLibros'!

!Receipt methodsFor: 'as yet unclassified' stamp: 'F C 10/29/2017 19:47:30'!
amount

	^amount.! !

!Receipt methodsFor: 'as yet unclassified' stamp: 'F C 10/29/2017 19:48:56'!
initailizeWith: aNumber andPurchases: aCollectionOfPurchases

	amount _ aNumber.
	purchases _ aCollectionOfPurchases.! !

!Receipt methodsFor: 'as yet unclassified' stamp: 'F C 10/29/2017 19:47:36'!
purchases

	^purchases copy.! !

!Receipt methodsFor: 'as yet unclassified' stamp: 'F C 10/29/2017 19:56:48'!
quantityFor: anItem

	^purchases occurrencesOf: anItem.! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

!classDefinition: 'Receipt class' category: #TusLibros!
Receipt class
	instanceVariableNames: ''!

!Receipt class methodsFor: 'as yet unclassified' stamp: 'F C 10/29/2017 19:49:01'!
with: aNumber andPurchases: aCollectionOfPurchases

	^self new initailizeWith: aNumber andPurchases: aCollectionOfPurchases.! !
