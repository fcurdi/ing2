!classDefinition: #TusLibrosTest category: #TusLibros!
TestCase subclass: #TusLibrosTest
	instanceVariableNames: 'isbnInCatalog isbnNotInCatalog catalog cart creditCardNumber anotherIsbnInCatalog notExpiredCreditCard expiredCreditCard salesBook merchantProcessorBehaviour'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'TusLibros'!

!TusLibrosTest methodsFor: 'cart' stamp: 'F C 10/29/2017 19:58:22'!
test01ANewCartIsAlwaysEmpty

	self assert: cart isEmpty.! !

!TusLibrosTest methodsFor: 'cart' stamp: 'FC_LR 10/30/2017 18:27:55'!
test02WhenAddingAnItemToACartThenTheCartContainsIt

	cart add: isbnInCatalog.
	
	self assert: cart size equals: 1.
	self assert: (cart includes: isbnInCatalog).! !

!TusLibrosTest methodsFor: 'cart' stamp: 'FC_LR 10/30/2017 18:28:00'!
test03WhenAddingMultipleItemsToACartThenTheCartContainsThem

	cart add: 2 of: isbnInCatalog.
	
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


!TusLibrosTest methodsFor: 'cashier' stamp: 'FC_LR 11/2/2017 19:51:05'!
test06CannotCheckoutAnEmptyCart

	self should: [ Cashier withCart: cart withCreditCard: notExpiredCreditCard andSalesBook: salesBook andMerchantProcessor: self on: FixedGregorianDate today. ]
	 	  raise: Error - MessageNotUnderstood 
		  withExceptionDo: [ :anError | 
			self assert: anError messageText  equals: 'cannot create an empty cart'.
			self assert:  salesBook isEmpty.
		  ].
	! !

!TusLibrosTest methodsFor: 'cashier' stamp: 'FC_LR 11/2/2017 19:51:02'!
test07CannotCheckoutWithExpiredCreditCard

	cart add: isbnInCatalog .
	
	self should: [ Cashier withCart: cart withCreditCard: expiredCreditCard andSalesBook: salesBook andMerchantProcessor: self on:  FixedGregorianDate today. ]
	 	  raise: Error - MessageNotUnderstood 
		  withExceptionDo: [ :anError | 
			self assert: anError messageText  equals: 'cannot checkout with expired credit card'.
			self assert: salesBook isEmpty.
		  ].
	! !

!TusLibrosTest methodsFor: 'cashier' stamp: 'FC_LR 11/2/2017 19:55:24'!
test08CheckoutRegistersTheSaleCorrectlyInTheSalesBook

	| cashier receipt expectedTotal |
	
	cart add: 2 of: isbnInCatalog.
	cart add: 1 of: anotherIsbnInCatalog.
	merchantProcessorBehaviour  _ [:amount :cretidCard | ].
	cashier _ Cashier withCart: cart withCreditCard: notExpiredCreditCard andSalesBook: salesBook andMerchantProcessor: self on: FixedGregorianDate today.
	
	receipt _ cashier checkout.
	expectedTotal _ ((catalog at: isbnInCatalog) * 2) + (catalog at: anotherIsbnInCatalog). 
	
	self assert: salesBook size equals: 1.
	self assert: (salesBook includes: receipt ).
	self assert: receipt amount equals: expectedTotal.
	self assert: (receipt quantityFor: isbnInCatalog) equals: 2.
	self assert: (receipt quantityFor: anotherIsbnInCatalog) equals: 1.	
	self assert: receipt purchases size equals: 3.

! !


!TusLibrosTest methodsFor: 'setup' stamp: 'FC_LR 10/30/2017 18:17:30'!
setUp

	| expiredDate notExpiredDate |
	
	isbnInCatalog _ '123'.
	anotherIsbnInCatalog _ '789'.
	isbnNotInCatalog _ '456'.
	catalog _ Dictionary new.
	catalog at: isbnInCatalog put: 10.
	catalog at: anotherIsbnInCatalog put: 30.
	cart _ Cart with: catalog.
	expiredDate _ GregorianMonthOfYear current previous.
	notExpiredDate _ GregorianMonthOfYear current.
	notExpiredCreditCard _ CreditCard withOwner: 'pepe' andNumber: '1234678956784235'  andExpiryDate: notExpiredDate.
	expiredCreditCard _ CreditCard withOwner: 'pepe' andNumber: '1234678956784235'  andExpiryDate: expiredDate.
	salesBook _ OrderedCollection new.! !


!TusLibrosTest methodsFor: 'merchant processor simulation' stamp: 'FC_LR 11/2/2017 19:42:00'!
debit: anAmount from: aCreditCard

	^ merchantProcessorBehaviour value: anAmount value: aCreditCard.
! !


!TusLibrosTest methodsFor: 'merchant processor' stamp: 'FC_LR 11/2/2017 19:48:55'!
test09CannotCheckoutWithStolenCreditCard
	
	| cashier |
	
	cart add: isbnInCatalog.
	merchantProcessorBehaviour _ [ :amount :creditCard |  self error: 'cannot checkout with stolen credit card' ].
	cashier _ Cashier withCart: cart withCreditCard: notExpiredCreditCard andSalesBook: salesBook andMerchantProcessor: self on:  FixedGregorianDate today.
	
	self should: [ cashier checkout ]
	 	  raise: Error - MessageNotUnderstood 
		  withExceptionDo: [ :anError | 
			self assert: anError messageText  equals: 'cannot checkout with stolen credit card'.
			self assert: salesBook isEmpty.
		  ].
	
	
	! !

!TusLibrosTest methodsFor: 'merchant processor' stamp: 'FC_LR 11/2/2017 19:53:50'!
test10CannotCheckoutWithCreditCardWithInsuficientFunds
	
	| cashier |
	
	cart add: isbnInCatalog.
	merchantProcessorBehaviour _ [ :amount :creditCard |  self error: 'cannot checkout with credit card with insuficient funds' ].
	cashier _ Cashier withCart: cart withCreditCard: notExpiredCreditCard andSalesBook: salesBook andMerchantProcessor: self on:  FixedGregorianDate today.
	
	self should: [ cashier checkout ]
	 	  raise: Error - MessageNotUnderstood 
		  withExceptionDo: [ :anError | 
			self assert: anError messageText  equals: 'cannot checkout with credit card with insuficient funds'.
			self assert: salesBook isEmpty.
		  ].
	
	
	! !

!TusLibrosTest methodsFor: 'merchant processor' stamp: 'FC_LR 11/2/2017 19:59:55'!
test11CheckoutInteractsWithMerchantProcessor
	| cashier |
	
	cart add: 1 of: isbnInCatalog.

	merchantProcessorBehaviour  _ [:amount :cretidCard | 
		self assert: amount equals: (catalog at: isbnInCatalog).
		self assert: cretidCard equals: notExpiredCreditCard.
	].
	cashier _ Cashier withCart: cart withCreditCard: notExpiredCreditCard andSalesBook: salesBook andMerchantProcessor: self on: FixedGregorianDate today.
	
	cashier checkout.
! !


!TusLibrosTest methodsFor: 'rest interface' stamp: 'FC_LR 11/2/2017 20:30:39'!
test12CannotCreateCartIfClientIdIsInvalid

	| restInterface |
	
	restInterface _ RestInterface withClientIds: (Dictionary new).
	
	self should: [ restInterface createCartWithClientId: 7092 andPassword: 'myPassword'.]
	 	  raise: Error - MessageNotUnderstood 
		  withExceptionDo: [ :anError | 
			self assert: anError messageText  equals: 'cannot create cart if user is invalid'.
		  ].! !

!TusLibrosTest methodsFor: 'rest interface' stamp: 'FC_LR 11/2/2017 20:40:33'!
test13CannotCreateCartWithValidClientIdButInvalidPassword

	| restInterface clientsData |
	
	clientsData _ Dictionary new.
	clientsData at: 7092 put: 'myPassword'.
	restInterface _ RestInterface withClientIds: clientsData.
	
	self should: [ restInterface createCartWithClientId: 7092 andPassword: 'invalidPassword'.]
	 	  raise: Error - MessageNotUnderstood 
		  withExceptionDo: [ :anError | 
			self assert: anError messageText  equals: 'cannot create cart if password is wrong'.
		  ].! !

!TusLibrosTest methodsFor: 'rest interface' stamp: 'FC_LR 11/2/2017 20:45:55'!
test14CreateCardWithValidUserAndPasswordResultsInAnEmptyCart

	| restInterface clientsData cartId |
	
	clientsData _ Dictionary new.
	clientsData at: 7092 put: 'myPassword'.
	restInterface _ RestInterface withClientIds: clientsData.
	cartId _ restInterface createCartWithClientId: 7092 andPassword: 'myPassword'.
	
	self assert: (restInterface listCart: cartId) isEmpty.! !

!TusLibrosTest methodsFor: 'rest interface' stamp: 'FC_LR 11/2/2017 21:13:25'!
test15CannotCreateCartIfClientIdIsInvalid
! !


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

!Cart methodsFor: 'as yet unclassified' stamp: 'FC_LR 10/30/2017 20:07:20'!
items

	^items copy.! !

!Cart methodsFor: 'as yet unclassified' stamp: 'FC_LR 10/26/2017 20:20:10'!
quantiyOf: anItem 
	
	^items occurrencesOf: anItem.! !

!Cart methodsFor: 'as yet unclassified' stamp: 'FC_LR 10/26/2017 20:03:19'!
size
	
	^items size.! !

!Cart methodsFor: 'as yet unclassified' stamp: 'FC_LR 10/30/2017 20:11:50'!
total

	^items 
		inject: 0
		into: [ :sum :item |  sum + (catalog at:item) ].! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

!classDefinition: 'Cart class' category: #TusLibros!
Cart class
	instanceVariableNames: ''!

!Cart class methodsFor: 'as yet unclassified' stamp: 'FC_LR 10/26/2017 20:35:55'!
with: aCatalog 
	
	^ self new initializeWith: aCatalog.! !


!classDefinition: #Cashier category: #TusLibros!
Object subclass: #Cashier
	instanceVariableNames: 'cart creditCard salesBook date merchatProcessor'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'TusLibros'!

!Cashier methodsFor: 'as yet unclassified' stamp: 'FC_LR 10/30/2017 20:17:20'!
checkout

	| total receipt |
	
	total _ cart total.
	self debit: total from: creditCard.
	receipt _ Receipt with: total andPurchases: cart items.
	salesBook add: receipt.
	^receipt.
	
	! !

!Cashier methodsFor: 'as yet unclassified' stamp: 'FC_LR 11/2/2017 19:49:52'!
debit: total from: creditCard

	merchatProcessor debit: total from: creditCard.! !

!Cashier methodsFor: 'as yet unclassified' stamp: 'FC_LR 11/2/2017 19:37:35'!
initializeWithCart: aCart andCreditCard: aCreditCard andSalesBook: aSalesBook andMerchantProcessor: aMerchantProcessor on: aDate

	cart _ aCart.
	creditCard _ aCreditCard.
	salesBook _ aSalesBook.
	date _ aDate.
	merchatProcessor _ aMerchantProcessor.! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

!classDefinition: 'Cashier class' category: #TusLibros!
Cashier class
	instanceVariableNames: ''!

!Cashier class methodsFor: 'as yet unclassified' stamp: 'FC_LR 11/2/2017 19:36:47'!
withCart: aCart withCreditCard: aCreditCard andSalesBook: aSalesBook andMerchantProcessor: aMerchantProcessor on: aDate 

	aCart isEmpty ifTrue: [ self error: 'cannot create an empty cart' ].
	
	(aCreditCard isExpiredOn: aDate) ifTrue: [ self error: 'cannot checkout with expired credit card' ].

	^self new initializeWithCart: aCart andCreditCard: aCreditCard andSalesBook: aSalesBook andMerchantProcessor: aMerchantProcessor on: aDate.! !


!classDefinition: #CreditCard category: #TusLibros!
Object subclass: #CreditCard
	instanceVariableNames: 'owner number expiryDate'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'TusLibros'!

!CreditCard methodsFor: 'as yet unclassified' stamp: 'F C 10/29/2017 19:23:41'!
initializeWith: anOwner andNumber: aNumber andExpiryDate: aMonthOfYear

	owner _ anOwner.
	number _ aNumber.
	expiryDate _ aMonthOfYear.! !

!CreditCard methodsFor: 'as yet unclassified' stamp: 'FC_LR 10/30/2017 20:22:39'!
isExpiredOn: aDate

	^expiryDate  < aDate.! !

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


!classDefinition: #RestInterface category: #TusLibros!
Object subclass: #RestInterface
	instanceVariableNames: 'clientsData carts catalog nextCartId'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'TusLibros'!

!RestInterface methodsFor: 'as yet unclassified' stamp: 'FC_LR 11/2/2017 21:05:23'!
createCartWithClientId: aClientId andPassword: aPassword 

	| clientPassword cart cartId |
	
	clientPassword _ clientsData at: aClientId ifAbsent: [ self error: 'cannot create cart if user is invalid'].
	
	clientPassword = aPassword ifFalse: [ self error: 'cannot create cart if password is wrong'].
	
	cart _ Cart with: catalog.
	cartId _ self generateCartId.
	
	carts at: cartId put: cart.
	
	^cartId.! !

!RestInterface methodsFor: 'as yet unclassified' stamp: 'FC_LR 11/2/2017 21:08:30'!
generateCartId	
	
	| cartId |
	
	"por seguridad no deberia ser secuencial"
	
	cartId _ nextCartId.
	nextCartId _ nextCartId + 1.
	
	^ cartId.! !

!RestInterface methodsFor: 'as yet unclassified' stamp: 'FC_LR 11/2/2017 21:07:46'!
initilizeWithClientIds: aClientsData 
	
	clientsData _ aClientsData.
	carts _ Dictionary new.
	nextCartId _ 0.! !

!RestInterface methodsFor: 'as yet unclassified' stamp: 'FC_LR 11/2/2017 21:11:16'!
listCart: aCartId
	
	^(carts at: aCartId ifAbsent: [self error: 'invalid cart id']) items.! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

!classDefinition: 'RestInterface class' category: #TusLibros!
RestInterface class
	instanceVariableNames: ''!

!RestInterface class methodsFor: 'as yet unclassified' stamp: 'FC_LR 11/2/2017 20:24:50'!
withClientIds: clientIds
	
	^ self new initilizeWithClientIds: clientIds.! !
