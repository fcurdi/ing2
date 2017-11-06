!classDefinition: #TusLibrosTest category: #TusLibros!
TestCase subclass: #TusLibrosTest
	instanceVariableNames: 'isbnInCatalog isbnNotInCatalog catalog cart creditCardNumber anotherIsbnInCatalog notExpiredCreditCard expiredCreditCard salesBook merchantProcessorBehaviour restInterface validClientId invalidClientId validPassword invalidPassword nonExistentCartId emptyCartId clock'
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


!TusLibrosTest methodsFor: 'cashier' stamp: 'FC_LR 11/5/2017 16:42:29'!
test06CannotCheckoutAnEmptyCart

	self should: [ Cashier withCart: cart withCreditCard: notExpiredCreditCard andSalesBook: salesBook andMerchantProcessor: self on: FixedGregorianDate today. ]
	 	  raise: Error - MessageNotUnderstood 
		  withExceptionDo: [ :anError | 
			self assert: anError messageText  equals: 'cannot checkout an empty cart'.
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

!TusLibrosTest methodsFor: 'cashier' stamp: 'FC_LR 11/5/2017 18:13:12'!
test08CheckoutRegistersTheSaleCorrectlyInTheSalesBook

	| cashier receipt expectedTotal |
	
	cart add: 2 of: isbnInCatalog.
	cart add: 1 of: anotherIsbnInCatalog.
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


!TusLibrosTest methodsFor: 'setup' stamp: 'FC_LR 11/5/2017 20:28:20'!
setUp

	| expiredDate notExpiredDate clientsData |
	
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
	salesBook _ OrderedCollection new.
	merchantProcessorBehaviour _ [:amount :creditCard|].
	
	nonExistentCartId _ '7777'.
	validClientId _ 7092.
	invalidClientId _ 123.
	validPassword _ 'myPassword'.
	invalidPassword _ 'wrongPassword'.
	clientsData _ Dictionary new.
	clientsData at: validClientId put: validPassword.
	clock _ ChangeableClock new.
	restInterface _ RestInterface withClientIds: clientsData andCatalog: catalog andMerchantProcessor: self andClock: clock.
	emptyCartId _ restInterface createCartWithClientId: validClientId andPassword: validPassword.! !


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


!TusLibrosTest methodsFor: 'rest interface' stamp: 'FC_LR 11/5/2017 18:43:09'!
test12CannotCreateCartIfClientIdIsInvalid
	
	self should: [ restInterface createCartWithClientId: invalidClientId andPassword: ''.]
	 	  raise: Error - MessageNotUnderstood 
		  withExceptionDo: [ :anError | 
			self assert: anError messageText  equals: 'invalid credentials'.
		  ].! !

!TusLibrosTest methodsFor: 'rest interface' stamp: 'FC_LR 11/5/2017 18:43:14'!
test13CannotCreateCartWithValidClientIdButInvalidPassword
	
	self should: [ restInterface createCartWithClientId: validClientId andPassword: invalidPassword.]
	 	  raise: Error - MessageNotUnderstood 
		  withExceptionDo: [ :anError | 
			self assert: anError messageText  equals: 'invalid credentials'.
		  ].! !

!TusLibrosTest methodsFor: 'rest interface' stamp: 'FC_LR 11/5/2017 18:24:46'!
test14CreateCardWithValidUserAndPasswordResultsInAnEmptyCart
	
	self assert: (restInterface listCart: emptyCartId) isEmpty.! !

!TusLibrosTest methodsFor: 'rest interface' stamp: 'FC_LR 11/5/2017 18:21:24'!
test15CannotAddItemToNonexistentCart
	
	self should: [ restInterface addToCartWithId: nonExistentCartId andIsbn: isbnInCatalog quantity: 1.]
		raise: Error - MessageNotUnderstood 
		withExceptionDo: [ :anError | 
			self assert: anError messageText  equals: 'cannot add item to nonexistent cart'.
	].
! !

!TusLibrosTest methodsFor: 'rest interface' stamp: 'FC_LR 11/2/2017 21:13:25'!
test15CannotCreateCartIfClientIdIsInvalid
! !

!TusLibrosTest methodsFor: 'rest interface' stamp: 'FC_LR 11/5/2017 18:25:05'!
test16CannotAddItemWithIsbnFromOtherEditorial
	
	self should: [ restInterface addToCartWithId: emptyCartId andIsbn: isbnNotInCatalog quantity: 1.]
		raise: Error - MessageNotUnderstood 
		withExceptionDo: [ :anError | 
			self assert: anError messageText  equals: 'cannot add item with isbn from other editorial'.
			self assert: (restInterface listCart: emptyCartId) isEmpty.
	].
! !

!TusLibrosTest methodsFor: 'rest interface' stamp: 'FC_LR 11/5/2017 18:25:23'!
test17CannotAddItemWithInvalidQuantity

	{ 0 . -1 . 3/2 } do: [ :aQuantity |
		self should: [	restInterface addToCartWithId: emptyCartId andIsbn: isbnInCatalog quantity: aQuantity.] raise: Error withExceptionDo: [ :anError | 
			self assert: anError messageText equals: 'invalid quantity'.
			self assert: (restInterface listCart: emptyCartId) isEmpty.
		].
	].
! !

!TusLibrosTest methodsFor: 'rest interface' stamp: 'FC_LR 11/5/2017 18:25:51'!
test18WhenAddingMultipleItemToACartThenTheCartContainsThem
	
	|  listCart |
	
	restInterface addToCartWithId: emptyCartId andIsbn: isbnInCatalog quantity: 2.
	listCart _ restInterface listCart: emptyCartId.
	
	self assert: listCart size equals: 2.
	self assert: (listCart occurrencesOf: isbnInCatalog) equals: 2.
	
! !

!TusLibrosTest methodsFor: 'rest interface' stamp: 'FC_LR 11/5/2017 18:26:08'!
test19CannotListANonexistentCart

	self should: [ restInterface listCart: nonExistentCartId .]
		raise: Error - MessageNotUnderstood 
		withExceptionDo: [ :anError | 
			self assert: anError messageText  equals: 'cannot list nonexistent cart'.
	].
! !

!TusLibrosTest methodsFor: 'rest interface' stamp: 'FC_LR 11/5/2017 18:26:40'!
test20ListCart
	
	|  listCart cartId |

	cartId _ emptyCartId.
	restInterface addToCartWithId: cartId andIsbn: isbnInCatalog quantity: 2.
	restInterface addToCartWithId: cartId andIsbn: anotherIsbnInCatalog quantity: 1.
	listCart _ restInterface listCart: cartId.
	
	self assert: listCart size equals: 3.
	self assert: (listCart occurrencesOf: isbnInCatalog) equals: 2.
	self assert: (listCart occurrencesOf: anotherIsbnInCatalog ) equals: 1.
! !

!TusLibrosTest methodsFor: 'rest interface' stamp: 'FC_LR 11/5/2017 18:27:09'!
test21CannotCheckoutANonexistentCart
	
	self should: [ restInterface checkoutCart:  nonExistentCartId andCreditCardNumber: notExpiredCreditCard
						number andExpirationDate: notExpiredCreditCard
						expirationDate andOwner: notExpiredCreditCard owner.]
		raise: Error - MessageNotUnderstood 
		withExceptionDo: [ :anError | 
			self assert: anError messageText  equals: 'cannot checkout a nonexistent cart'.
	].
! !

!TusLibrosTest methodsFor: 'rest interface' stamp: 'FC_LR 11/5/2017 18:27:26'!
test22CannotCheckoutAnEmptyCart

	self should: [ restInterface checkoutCart: emptyCartId andCreditCardNumber: notExpiredCreditCard
						number andExpirationDate: notExpiredCreditCard
						expirationDate andOwner: notExpiredCreditCard owner.]
		raise: Error - MessageNotUnderstood 
		withExceptionDo: [ :anError | 
			self assert: anError messageText  equals: 'cannot checkout an empty cart'.
	].
! !

!TusLibrosTest methodsFor: 'rest interface' stamp: 'FC_LR 11/5/2017 18:27:50'!
test23CannotCheckoutWithExpiredCreditCard

	| cartId |
	cartId _ emptyCartId.
	restInterface addToCartWithId: cartId andIsbn: isbnInCatalog quantity: 2.
	
	self should: [ restInterface checkoutCart: cartId andCreditCardNumber: expiredCreditCard
						number andExpirationDate: expiredCreditCard
						expirationDate andOwner: expiredCreditCard owner.]
		raise: Error - MessageNotUnderstood 
		withExceptionDo: [ :anError | 
			self assert: anError messageText  equals: 'cannot checkout with expired credit card'.
	].
	! !

!TusLibrosTest methodsFor: 'rest interface' stamp: 'FC_LR 11/5/2017 18:28:23'!
test24Checkout

	|  cartId receipt expectedTotal |

	cartId _ emptyCartId.
	restInterface addToCartWithId: cartId andIsbn: isbnInCatalog quantity: 2.
	
	receipt _ restInterface checkoutCart: cartId andCreditCardNumber: notExpiredCreditCard 
		number andExpirationDate: notExpiredCreditCard expirationDate andOwner: notExpiredCreditCard owner.
		
	expectedTotal _ ((catalog at: isbnInCatalog) * 2).
	
	self assert: receipt amount equals: expectedTotal.
	self assert: (receipt quantityFor: isbnInCatalog) equals: 2.
	self assert: receipt purchases size equals: 2.
! !

!TusLibrosTest methodsFor: 'rest interface' stamp: 'FC_LR 11/5/2017 18:28:47'!
test25CheckoutAndCheckout

	| cartId |
	
	cartId _ emptyCartId.
	restInterface addToCartWithId: cartId andIsbn: isbnInCatalog quantity: 2.
	
	restInterface checkoutCart: cartId andCreditCardNumber: notExpiredCreditCard 
		number andExpirationDate: notExpiredCreditCard expirationDate andOwner: notExpiredCreditCard owner.

	self should: [ restInterface checkoutCart: cartId andCreditCardNumber: notExpiredCreditCard 
						number andExpirationDate: notExpiredCreditCard
						expirationDate andOwner: notExpiredCreditCard owner.]
		raise: Error - MessageNotUnderstood 
		withExceptionDo: [ :anError | 
			self assert: anError messageText  equals: 'cannot checkout a nonexistent cart'.
	].
	
	
	
	
! !

!TusLibrosTest methodsFor: 'rest interface' stamp: 'FC_LR 11/5/2017 18:43:48'!
test26CannotListPurchasesIfClientIdIsInvalid

	
	self should: [ restInterface listPurchases: invalidClientId withPassword: ''.]
		raise: Error - MessageNotUnderstood 
		withExceptionDo: [ :anError | 
			self assert: anError messageText  equals: 'invalid credentials'.
	].
! !

!TusLibrosTest methodsFor: 'rest interface' stamp: 'FC_LR 11/5/2017 18:43:54'!
test27CannotListPurchasesWithValidClientIdButInvalidPassword
	
	
	self should: [ restInterface listPurchases: validClientId withPassword: invalidPassword .]
		raise: Error - MessageNotUnderstood 
		withExceptionDo: [ :anError | 
			self assert: anError messageText  equals: 'invalid credentials'.
	].
! !

!TusLibrosTest methodsFor: 'rest interface' stamp: 'FC_LR 11/5/2017 18:30:38'!
test28ListPurchases		

	| cartId purchases receipt |
	
	cartId _ emptyCartId.
	restInterface addToCartWithId: cartId andIsbn: isbnInCatalog quantity: 2.
	
	receipt _ restInterface checkoutCart: cartId andCreditCardNumber: notExpiredCreditCard 
		number andExpirationDate: notExpiredCreditCard expirationDate andOwner: notExpiredCreditCard owner.
	
	purchases _ restInterface listPurchases: validClientId withPassword: validPassword.
	
	self assert: purchases size equals: 1.
	self assert: (purchases includes: receipt).
	
! !

!TusLibrosTest methodsFor: 'rest interface' stamp: 'FC_LR 11/5/2017 20:43:47'!
test29CannotInteractWithExpiredCart

	| cartId |
	
	cartId _ emptyCartId.
	clock advance: (Duration minutes: 30).
	
	self should: [ restInterface addToCartWithId: cartId andIsbn: isbnInCatalog quantity: 1. ]
		  raise:  Error - MessageNotUnderstood
		  withExceptionDo: [ :anError |
			self assert: anError messageText equals: 'invalid cart id'
	].

	self should: [ restInterface addToCartWithId: cartId andIsbn: isbnInCatalog  quantity: 1 ]
		  raise:  Error - MessageNotUnderstood
		  withExceptionDo: [ :anError |
			self assert: anError messageText equals: 'invalid cart id'
	].

	self should: [ restInterface listCart: cartId ]
		  raise:  Error - MessageNotUnderstood
		  withExceptionDo: [ :anError |
			self assert: anError messageText equals: 'invalid cart id'
	].! !

!TusLibrosTest methodsFor: 'rest interface' stamp: 'FC_LR 11/5/2017 21:08:19'!
test30CartTimeToLiveResetsWithEachOperation
	
	| doTest cartId |
	
	cartId _ emptyCartId.
	
	doTest _ [ :aBlockClosure |
			
			clock advance: (Duration minutes: 20).
	
			aBlockClosure value.
	
			clock advance: (Duration minutes: 20).
	
			self assert: (restInterface listCart: cartId) isEmpty.	
			
			clock reset.			
	].

	doTest value: [ restInterface addToCartWithId: cartId andIsbn: isbnInCatalog quantity: 1].
	doTest value: [ restInterface listCart: cartId ].

	
	

	
	

	
	
	
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

!Cashier class methodsFor: 'as yet unclassified' stamp: 'FC_LR 11/5/2017 16:42:04'!
withCart: aCart withCreditCard: aCreditCard andSalesBook: aSalesBook andMerchantProcessor: aMerchantProcessor on: aDate 

	aCart isEmpty ifTrue: [ self error: 'cannot checkout an empty cart' ].
	
	(aCreditCard isExpiredOn: aDate) ifTrue: [ self error: 'cannot checkout with expired credit card' ].

	^self new initializeWithCart: aCart andCreditCard: aCreditCard andSalesBook: aSalesBook andMerchantProcessor: aMerchantProcessor on: aDate.! !


!classDefinition: #ChangeableClock category: #TusLibros!
Object subclass: #ChangeableClock
	instanceVariableNames: 'now'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'TusLibros'!

!ChangeableClock methodsFor: 'as yet unclassified' stamp: 'FC_LR 11/5/2017 20:41:43'!
advance: aDuration

	now _ DateAndTime fromSeconds: now unixTimeSeconds + aDuration seconds. ! !

!ChangeableClock methodsFor: 'as yet unclassified' stamp: 'FC_LR 11/5/2017 20:25:04'!
initialize

	now _ DateAndTime now.! !

!ChangeableClock methodsFor: 'as yet unclassified' stamp: 'FC_LR 11/5/2017 20:30:26'!
now

	^now.! !

!ChangeableClock methodsFor: 'as yet unclassified' stamp: 'FC_LR 11/5/2017 21:00:21'!
reset

	now _ DateAndTime now.! !


!classDefinition: #CreditCard category: #TusLibros!
Object subclass: #CreditCard
	instanceVariableNames: 'owner number expiryDate'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'TusLibros'!

!CreditCard methodsFor: 'as yet unclassified' stamp: 'FC_LR 11/5/2017 16:26:29'!
expirationDate

	^expiryDate.! !

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
	instanceVariableNames: 'clientsData carts catalog nextCartId salesBook merchantProcessor purchasesByUser userByCart clock cartsTtl'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'TusLibros'!

!RestInterface methodsFor: 'as yet unclassified' stamp: 'FC_LR 11/5/2017 21:08:45'!
addToCartWithId: aCartId andIsbn: anIsbn quantity: aQuantity 
	
	| cart |
	
	self assertValidCart: aCartId.
	
	cart _ carts at: aCartId.
	
	(catalog includesKey: anIsbn) ifFalse: [self error: 'cannot add item with isbn from other editorial'].
	
	(aQuantity isInteger and: [ aQuantity strictlyPositive ]) ifFalse: [self error: 'invalid quantity'].
	
	cart add: aQuantity of: anIsbn.
	
	self refreshCartTtl: aCartId.
	
	
! !

!RestInterface methodsFor: 'as yet unclassified' stamp: 'FC_LR 11/5/2017 21:08:53'!
assertValidCart: cartId

	| creationDate |
	
		self halt.
	
	(carts includesKey: cartId) ifFalse: [self error: 'invalid cart id'].

	creationDate _ cartsTtl at: cartId.
	
	(creationDate unixTimeSeconds - clock now unixTimeSeconds) > 1800 ifTrue: [
		carts removeKey: cartId.
		userByCart removeKey: cartId.
		cartsTtl removeKey: cartId.
		self error: 'invalid cart id'.
	]. 



! !

!RestInterface methodsFor: 'as yet unclassified' stamp: 'FC_LR 11/5/2017 18:43:34'!
checkCredentials: clientId and: password

	| clientPassword |
	
	clientPassword _ clientsData at: clientId ifAbsent: [ self error: 'invalid credentials'].
	clientPassword = password ifFalse: [ self error: 'invalid credentials'].! !

!RestInterface methodsFor: 'as yet unclassified' stamp: 'FC_LR 11/5/2017 20:51:53'!
checkoutCart: aCartId andCreditCardNumber: aCreditCardNumber andExpirationDate: anExpirationDate andOwner: anOwner

	| cart  creditCard cashier receipt clientId purchases |
	
	self assertValidCart: aCartId.
	
	cart _ carts at: aCartId.
	
	creditCard _ CreditCard withOwner: anOwner andNumber: aCreditCardNumber andExpiryDate: anExpirationDate.

	cashier _ Cashier withCart: cart withCreditCard: creditCard andSalesBook: salesBook andMerchantProcessor: merchantProcessor on: FixedGregorianDate today.
	
	receipt _ cashier checkout.
	
	carts removeKey: aCartId.
	cartsTtl removeKey: aCartId.
	userByCart removeKey: aCartId.
	
	clientId _ userByCart at: aCartId.
	purchases _ purchasesByUser at: clientId ifAbsent: [ purchasesByUser at: clientId put: (OrderedCollection new).].
	purchases add: receipt.
	
	^receipt.! !

!RestInterface methodsFor: 'as yet unclassified' stamp: 'FC_LR 11/5/2017 19:10:14'!
createCartWithClientId: aClientId andPassword: aPassword 

	| cart cartId |
	
	self checkCredentials: aClientId and: aPassword.
	
	cart _ Cart with: catalog.
	cartId _ self generateCartId.
	
	carts at: cartId put: cart.
	
	userByCart at: cartId put: aClientId.
	cartsTtl at: cartId put: clock now.
	
	^cartId.! !

!RestInterface methodsFor: 'as yet unclassified' stamp: 'FC_LR 11/2/2017 21:08:30'!
generateCartId	
	
	| cartId |
	
	"por seguridad no deberia ser secuencial"
	
	cartId _ nextCartId.
	nextCartId _ nextCartId + 1.
	
	^ cartId.! !

!RestInterface methodsFor: 'as yet unclassified' stamp: 'FC_LR 11/5/2017 20:33:48'!
initilizeWithClientIds: aClientsData andCatalog: aCatalog andMerchantProcessor: aMerchantProcessor andClock: aClock
	
	clientsData _ aClientsData.
	carts _ Dictionary new.
	nextCartId _ 0.
	catalog _ aCatalog.
	salesBook _ OrderedCollection new.
	merchantProcessor _ aMerchantProcessor.
	userByCart _ Dictionary new.
	purchasesByUser _ Dictionary new.
	clock _ aClock.
	cartsTtl _ Dictionary new.
	! !

!RestInterface methodsFor: 'as yet unclassified' stamp: 'FC_LR 11/5/2017 20:52:11'!
listCart: aCartId

	self assertValidCart: aCartId.
	self refreshCartTtl: aCartId.
	
	^(carts at: aCartId) items.! !

!RestInterface methodsFor: 'as yet unclassified' stamp: 'FC_LR 11/5/2017 19:34:33'!
listPurchases: aClientId withPassword: aPassword 

	self checkCredentials: aClientId and: aPassword.
	
	^purchasesByUser at: aClientId.! !

!RestInterface methodsFor: 'as yet unclassified' stamp: 'FC_LR 11/5/2017 20:50:49'!
refreshCartTtl: cartId

	cartsTtl at: cartId put: clock now.

	

	! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

!classDefinition: 'RestInterface class' category: #TusLibros!
RestInterface class
	instanceVariableNames: ''!

!RestInterface class methodsFor: 'as yet unclassified' stamp: 'FC_LR 11/5/2017 18:59:08'!
withClientIds: clientIds andCatalog: aCatalog andMerchantProcessor: aMerchantProcessor andClock: aClock
	
	^ self new initilizeWithClientIds: clientIds andCatalog: aCatalog andMerchantProcessor: aMerchantProcessor andClock: aClock! !
