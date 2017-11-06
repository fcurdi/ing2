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

!TusLibrosTest methodsFor: 'cart' stamp: 'F C 11/6/2017 00:58:03'!
test04CannotAddToCartAnItemThatIsNotInCatalog
	
	self should: [cart add: isbnNotInCatalog ] raise: Error withExceptionDo: [ :anError | 
		self assert: anError messageText equals: Cart isbnNotInCatalogErrorDescription.
		self assert: cart isEmpty.
	].! !

!TusLibrosTest methodsFor: 'cart' stamp: 'F C 11/6/2017 00:58:17'!
test05AddingAnInvalidQunatityOfAnItemRaisesAnException

	{ 0 . -1 . 3/2 } do: [ :aQuantity |
		self should: [	cart add: aQuantity of: isbnInCatalog.] raise: Error withExceptionDo: [ :anError | 
			self assert: anError messageText equals: Cart invalidQuantityErrorDescription.
			self assert: cart isEmpty.
		].
	].! !


!TusLibrosTest methodsFor: 'cashier' stamp: 'F C 11/6/2017 00:58:31'!
test06CannotCheckoutAnEmptyCart

	self should: [ Cashier withCart: cart withCreditCard: notExpiredCreditCard andSalesBook: salesBook andMerchantProcessor: self on: FixedGregorianDate today. ]
	 	  raise: Error - MessageNotUnderstood 
		  withExceptionDo: [ :anError | 
			self assert: anError messageText  equals: Cashier checkoutEmptyCartErrorDescription.
			self assert:  salesBook isEmpty.
		  ].
	! !

!TusLibrosTest methodsFor: 'cashier' stamp: 'F C 11/6/2017 00:58:40'!
test07CannotCheckoutWithExpiredCreditCard

	cart add: isbnInCatalog .
	
	self should: [ Cashier withCart: cart withCreditCard: expiredCreditCard andSalesBook: salesBook andMerchantProcessor: self on:  FixedGregorianDate today. ]
	 	  raise: Error - MessageNotUnderstood 
		  withExceptionDo: [ :anError | 
			self assert: anError messageText  equals: Cashier checkoutWithExpiredCreditCardErrorDescription.
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


!TusLibrosTest methodsFor: 'setup' stamp: 'F C 11/6/2017 01:10:04'!
setUp

	| expiredDate notExpiredDate clientInfo |
	
	isbnInCatalog _ '123'.
	anotherIsbnInCatalog _ '789'.
	isbnNotInCatalog _ '456'.
	catalog _ Dictionary new.
	catalog at: isbnInCatalog put: 10.
	catalog at: anotherIsbnInCatalog put: 30.
	
	cart _ Cart with: catalog.
	
	expiredDate _ GregorianMonthOfYear current previous.
	notExpiredDate _ GregorianMonthOfYear current.
	notExpiredCreditCard _ CreditCard withOwner: 'pepe' andNumber: '1234678956784235'  andExpirationDate: notExpiredDate.
	expiredCreditCard _ CreditCard withOwner: 'pepe' andNumber: '1234678956784235'  andExpirationDate: expiredDate.
	
	salesBook _ OrderedCollection new.
	merchantProcessorBehaviour _ [:amount :creditCard | ].
	
	nonExistentCartId _ '7777'.
	validClientId _ 7092.
	invalidClientId _ 123.
	validPassword _ 'myPassword'.
	invalidPassword _ 'wrongPassword'.
	clientInfo _ Dictionary new.
	clientInfo at: validClientId put: validPassword.
	clock _ ChangeableClock new.
	restInterface _ RestInterface withClientInfo: clientInfo andCatalog: catalog andMerchantProcessor: self andClock: clock.
	emptyCartId _ restInterface createCartWithClientId: validClientId andPassword: validPassword.! !


!TusLibrosTest methodsFor: 'merchant processor simulation' stamp: 'F C 11/6/2017 00:58:54'!
debit: anAmount from: aCreditCard

	^merchantProcessorBehaviour value: anAmount value: aCreditCard.
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


!TusLibrosTest methodsFor: 'rest interface' stamp: 'F C 11/6/2017 00:59:23'!
test12CannotCreateCartIfClientIdIsInvalid
	
	self should: [ restInterface createCartWithClientId: invalidClientId andPassword: ''.]
	 	  raise: Error - MessageNotUnderstood 
		  withExceptionDo: [ :anError | 
			self assert: anError messageText  equals: RestInterface invalidCredentialsErrorDescription.
		  ].! !

!TusLibrosTest methodsFor: 'rest interface' stamp: 'F C 11/6/2017 00:59:32'!
test13CannotCreateCartWithValidClientIdButInvalidPassword
	
	self should: [ restInterface createCartWithClientId: validClientId andPassword: invalidPassword.]
	 	  raise: Error - MessageNotUnderstood 
		  withExceptionDo: [ :anError | 
			self assert: anError messageText  equals: RestInterface invalidCredentialsErrorDescription.
		  ].! !

!TusLibrosTest methodsFor: 'rest interface' stamp: 'FC_LR 11/5/2017 18:24:46'!
test14CreateCardWithValidUserAndPasswordResultsInAnEmptyCart
	
	self assert: (restInterface listCart: emptyCartId) isEmpty.! !

!TusLibrosTest methodsFor: 'rest interface' stamp: 'F C 11/6/2017 00:59:46'!
test15CannotAddItemToNonexistentCart
	
	self should: [ restInterface addTo: nonExistentCartId quantity: 1 of: isbnInCatalog.]
		raise: Error - MessageNotUnderstood 
		withExceptionDo: [ :anError | 
			self assert: anError messageText  equals: RestInterface invalidCartIdErrorDescription.
	].
! !

!TusLibrosTest methodsFor: 'rest interface' stamp: 'F C 11/6/2017 01:12:05'!
test16CannotAddItemThatIsNotInCatalog
	
	self should: [ restInterface addTo: emptyCartId quantity: 1 of: isbnNotInCatalog.]
		raise: Error - MessageNotUnderstood 
		withExceptionDo: [ :anError | 
			self assert: anError messageText  equals: Cart isbnNotInCatalogErrorDescription.
			self assert: (restInterface listCart: emptyCartId) isEmpty.
	].
! !

!TusLibrosTest methodsFor: 'rest interface' stamp: 'F C 11/6/2017 01:12:26'!
test17CannotAddAnInvalidQuantityOfAnItem

	{ 0 . -1 . 3/2 } do: [ :aQuantity |
		self should: [	restInterface addTo: emptyCartId quantity: aQuantity of: isbnInCatalog.] raise: Error withExceptionDo: [ :anError | 
			self assert: anError messageText equals: Cart invalidQuantityErrorDescription.
			self assert: (restInterface listCart: emptyCartId) isEmpty.
		].
	].
! !

!TusLibrosTest methodsFor: 'rest interface' stamp: 'F C 11/6/2017 00:36:20'!
test18WhenAddingMultipleItemToACartThenTheCartContainsThem
	
	|  listCart |
	
	restInterface addTo: emptyCartId quantity: 2 of: isbnInCatalog.
	listCart _ restInterface listCart: emptyCartId.
	
	self assert: listCart size equals: 2.
	self assert: (listCart occurrencesOf: isbnInCatalog) equals: 2.
	
! !

!TusLibrosTest methodsFor: 'rest interface' stamp: 'F C 11/6/2017 01:01:07'!
test19CannotListANonexistentCart

	self should: [ restInterface listCart: nonExistentCartId .]
		raise: Error - MessageNotUnderstood 
		withExceptionDo: [ :anError | 
			self assert: anError messageText  equals: RestInterface invalidCartIdErrorDescription.
	].
! !

!TusLibrosTest methodsFor: 'rest interface' stamp: 'F C 11/6/2017 01:13:04'!
test20ListCartShowsCartContentsCorrectly
	
	|  listCart cartId |

	cartId _ emptyCartId.
	restInterface addTo: cartId quantity: 2 of: isbnInCatalog.
	restInterface addTo: cartId quantity: 1 of:anotherIsbnInCatalog.
	listCart _ restInterface listCart: cartId.
	
	self assert: listCart size equals: 3.
	self assert: (listCart occurrencesOf: isbnInCatalog) equals: 2.
	self assert: (listCart occurrencesOf: anotherIsbnInCatalog ) equals: 1.
! !

!TusLibrosTest methodsFor: 'rest interface' stamp: 'F C 11/6/2017 01:01:13'!
test21CannotCheckoutANonexistentCart
	
	self should: [ restInterface checkoutCart:  nonExistentCartId andCreditCardNumber: notExpiredCreditCard
						number andExpirationDate: notExpiredCreditCard
						expirationDate andOwner: notExpiredCreditCard owner.]
		raise: Error - MessageNotUnderstood 
		withExceptionDo: [ :anError | 
			self assert: anError messageText  equals: RestInterface invalidCartIdErrorDescription.
	].
! !

!TusLibrosTest methodsFor: 'rest interface' stamp: 'F C 11/6/2017 01:01:28'!
test22CannotCheckoutAnEmptyCart

	self should: [ restInterface checkoutCart: emptyCartId andCreditCardNumber: notExpiredCreditCard
						number andExpirationDate: notExpiredCreditCard
						expirationDate andOwner: notExpiredCreditCard owner.]
		raise: Error - MessageNotUnderstood 
		withExceptionDo: [ :anError | 
			self assert: anError messageText  equals: Cashier checkoutEmptyCartErrorDescription.
	].
! !

!TusLibrosTest methodsFor: 'rest interface' stamp: 'F C 11/6/2017 01:01:37'!
test23CannotCheckoutWithExpiredCreditCard

	| cartId |
	cartId _ emptyCartId.
	restInterface addTo: cartId quantity: 2 of: isbnInCatalog.
	
	self should: [ restInterface checkoutCart: cartId andCreditCardNumber: expiredCreditCard
						number andExpirationDate: expiredCreditCard
						expirationDate andOwner: expiredCreditCard owner.]
		raise: Error - MessageNotUnderstood 
		withExceptionDo: [ :anError | 
			self assert: anError messageText  equals: Cashier checkoutWithExpiredCreditCardErrorDescription.
	].
	! !

!TusLibrosTest methodsFor: 'rest interface' stamp: 'F C 11/6/2017 01:13:24'!
test24CheckoutCalculatesTotalCorrectly

	|  cartId receipt expectedTotal |

	cartId _ emptyCartId.
	restInterface addTo: cartId quantity: 2 of: isbnInCatalog.
	
	receipt _ restInterface checkoutCart: cartId andCreditCardNumber: notExpiredCreditCard 
		number andExpirationDate: notExpiredCreditCard expirationDate andOwner: notExpiredCreditCard owner.
		
	expectedTotal _ ((catalog at: isbnInCatalog) * 2).
	
	self assert: receipt amount equals: expectedTotal.
	self assert: (receipt quantityFor: isbnInCatalog) equals: 2.
	self assert: receipt purchases size equals: 2.
! !

!TusLibrosTest methodsFor: 'rest interface' stamp: 'F C 11/6/2017 01:14:01'!
test25CannotCheckoutACartThatWasAlreadyPaidFor

	| cartId |
	
	cartId _ emptyCartId.
	restInterface addTo: cartId quantity: 2 of:isbnInCatalog.
	
	restInterface checkoutCart: cartId andCreditCardNumber: notExpiredCreditCard 
		number andExpirationDate: notExpiredCreditCard expirationDate andOwner: notExpiredCreditCard owner.

	self should: [ restInterface checkoutCart: cartId andCreditCardNumber: notExpiredCreditCard 
						number andExpirationDate: notExpiredCreditCard
						expirationDate andOwner: notExpiredCreditCard owner.]
		raise: Error - MessageNotUnderstood 
		withExceptionDo: [ :anError | 
			self assert: anError messageText  equals: RestInterface invalidCartIdErrorDescription.
	].
	
	
	
	
! !

!TusLibrosTest methodsFor: 'rest interface' stamp: 'F C 11/6/2017 01:02:00'!
test26CannotListPurchasesIfClientIdIsInvalid

	
	self should: [ restInterface listPurchases: invalidClientId withPassword: ''.]
		raise: Error - MessageNotUnderstood 
		withExceptionDo: [ :anError | 
			self assert: anError messageText  equals: RestInterface invalidCredentialsErrorDescription.
	].
! !

!TusLibrosTest methodsFor: 'rest interface' stamp: 'F C 11/6/2017 01:02:08'!
test27CannotListPurchasesWithValidClientIdButInvalidPassword
	
	
	self should: [ restInterface listPurchases: validClientId withPassword: invalidPassword .]
		raise: Error - MessageNotUnderstood 
		withExceptionDo: [ :anError | 
			self assert: anError messageText  equals: RestInterface invalidCredentialsErrorDescription.
	].
! !

!TusLibrosTest methodsFor: 'rest interface' stamp: 'F C 11/6/2017 01:14:50'!
test28ListPurchasesShowsAllPurchasesForAClientID	

	| cartId purchases receipt |
	
	cartId _ emptyCartId.
	restInterface addTo: cartId quantity: 2 of: isbnInCatalog.
	
	receipt _ restInterface checkoutCart: cartId andCreditCardNumber: notExpiredCreditCard 
		number andExpirationDate: notExpiredCreditCard expirationDate andOwner: notExpiredCreditCard owner.
	
	purchases _ restInterface listPurchases: validClientId withPassword: validPassword.
	
	self assert: purchases size equals: 1.
	self assert: (purchases includes: receipt).
	
! !

!TusLibrosTest methodsFor: 'rest interface' stamp: 'F C 11/6/2017 01:02:23'!
test29CannotInteractWithExpiredCart

	| performForExpiredCart |
	
	performForExpiredCart _ [ :aBlockClosure | 
		| cartId |
		cartId _ restInterface createCartWithClientId: validClientId andPassword: validPassword.
		clock advance: (Duration minutes: 30).
		aBlockClosure value: cartId.
		clock reset.
	 ].
	
	performForExpiredCart value: [ :cartId|
		self should: [ restInterface addTo: cartId quantity: 1 of: isbnInCatalog. ]
			  raise:  Error - MessageNotUnderstood
		  	  withExceptionDo: [ :anError |
				self assert: anError messageText equals: RestInterface invalidCartIdErrorDescription.
		].
	].
	

	performForExpiredCart value: [ :cartId |
		self should: [ restInterface checkoutCart: cartId andCreditCardNumber: notExpiredCreditCard number andExpirationDate: notExpiredCreditCard expirationDate andOwner: notExpiredCreditCard owner]
			  raise:  Error - MessageNotUnderstood
			  withExceptionDo: [ :anError |
				self assert: anError messageText equals: RestInterface invalidCartIdErrorDescription.
		].
	].


	performForExpiredCart value: [ :cartId |
		self should: [ restInterface listCart: cartId ]
			  raise:  Error - MessageNotUnderstood
			  withExceptionDo: [ :anError |
				self assert: anError messageText equals: RestInterface invalidCartIdErrorDescription.
		].	
	].

! !

!TusLibrosTest methodsFor: 'rest interface' stamp: 'F C 11/6/2017 00:38:49'!
test30CartTimeToLiveResetsWithEachOperation
	
	| doTest cartId |
	
	cartId _ emptyCartId.
	
	doTest _ [ :aBlockClosure |
			
			clock advance: (Duration minutes: 20).
	
			aBlockClosure value.
	
			clock advance: (Duration minutes: 20).
	
			self shouldnt: [ restInterface listCart: cartId ] raise: Error.	
			
			clock reset.			
	].

	doTest value: [ restInterface addTo: cartId quantity: 1 of: isbnInCatalog. ].
	doTest value: [ restInterface listCart: cartId ].

	
	

	
	

	
	
	
	! !


!classDefinition: #Cart category: #TusLibros!
Object subclass: #Cart
	instanceVariableNames: 'items catalog'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'TusLibros'!

!Cart methodsFor: 'testing' stamp: 'FC_LR 10/26/2017 20:05:45'!
includes: anItem 
	
	^items includes: anItem.! !

!Cart methodsFor: 'testing' stamp: 'FC_LR 10/26/2017 19:54:37'!
isEmpty
	
	^items isEmpty.! !

!Cart methodsFor: 'testing' stamp: 'FC_LR 10/26/2017 20:20:10'!
quantiyOf: anItem 
	
	^items occurrencesOf: anItem.! !

!Cart methodsFor: 'testing' stamp: 'FC_LR 10/26/2017 20:03:19'!
size
	
	^items size.! !

!Cart methodsFor: 'testing' stamp: 'FC_LR 10/30/2017 20:11:50'!
total

	^items 
		inject: 0
		into: [ :sum :item |  sum + (catalog at:item) ].! !


!Cart methodsFor: 'accessing' stamp: 'F C 10/29/2017 18:53:35'!
catalog

	^catalog copy.! !

!Cart methodsFor: 'accessing' stamp: 'FC_LR 10/30/2017 20:07:20'!
items

	^items copy.! !


!Cart methodsFor: 'adding' stamp: 'FC_LR 10/26/2017 20:25:30'!
add: anItem 
	
	self add: 1 of: anItem.! !

!Cart methodsFor: 'adding' stamp: 'F C 11/6/2017 00:23:28'!
add: aQuantity of: anItem 
	
	(catalog includesKey: anItem) ifFalse: [self error: Cart isbnNotInCatalogErrorDescription ].
	
	(aQuantity isInteger and: [ aQuantity strictlyPositive ]) ifFalse: [self error: Cart invalidQuantityErrorDescription].
	
	items add: anItem withOccurrences: aQuantity.! !


!Cart methodsFor: 'initialization' stamp: 'FC_LR 10/26/2017 20:36:07'!
initializeWith: aCatalog 
	
	items _ Bag new.
	catalog _ aCatalog. ! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

!classDefinition: 'Cart class' category: #TusLibros!
Cart class
	instanceVariableNames: ''!

!Cart class methodsFor: 'error descriptions' stamp: 'F C 11/6/2017 00:23:43'!
invalidQuantityErrorDescription

	^'invalid quantity'.! !

!Cart class methodsFor: 'error descriptions' stamp: 'F C 11/6/2017 00:22:45'!
isbnNotInCatalogErrorDescription

	^'cannot add an isbn that is not in the catalog'.! !


!Cart class methodsFor: 'instance creation' stamp: 'FC_LR 10/26/2017 20:35:55'!
with: aCatalog 
	
	^ self new initializeWith: aCatalog.! !


!classDefinition: #Cashier category: #TusLibros!
Object subclass: #Cashier
	instanceVariableNames: 'cart creditCard salesBook date merchatProcessor'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'TusLibros'!

!Cashier methodsFor: 'checkout' stamp: 'FC_LR 10/30/2017 20:17:20'!
checkout

	| total receipt |
	
	total _ cart total.
	self debit: total from: creditCard.
	receipt _ Receipt with: total andPurchases: cart items.
	salesBook add: receipt.
	^receipt.
	
	! !


!Cashier methodsFor: 'initialization' stamp: 'FC_LR 11/2/2017 19:37:35'!
initializeWithCart: aCart andCreditCard: aCreditCard andSalesBook: aSalesBook andMerchantProcessor: aMerchantProcessor on: aDate

	cart _ aCart.
	creditCard _ aCreditCard.
	salesBook _ aSalesBook.
	date _ aDate.
	merchatProcessor _ aMerchantProcessor.! !


!Cashier methodsFor: 'merchant processor' stamp: 'FC_LR 11/2/2017 19:49:52'!
debit: total from: creditCard

	merchatProcessor debit: total from: creditCard.! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

!classDefinition: 'Cashier class' category: #TusLibros!
Cashier class
	instanceVariableNames: ''!

!Cashier class methodsFor: 'error descriptions' stamp: 'F C 11/6/2017 00:25:39'!
checkoutEmptyCartErrorDescription

	^'cannot checkout an empty cart'.! !

!Cashier class methodsFor: 'error descriptions' stamp: 'F C 11/6/2017 00:25:54'!
checkoutWithExpiredCreditCardErrorDescription

	^'cannot checkout an empty cart'.! !


!Cashier class methodsFor: 'instance creation' stamp: 'F C 11/6/2017 00:27:30'!
withCart: aCart withCreditCard: aCreditCard andSalesBook: aSalesBook andMerchantProcessor: aMerchantProcessor on: aDate 

	aCart isEmpty ifTrue: [ self error: Cashier checkoutEmptyCartErrorDescription ].
	
	(aCreditCard isExpiredOn: aDate) ifTrue: [ self error: Cashier checkoutWithExpiredCreditCardErrorDescription ].

	^self new initializeWithCart: aCart andCreditCard: aCreditCard andSalesBook: aSalesBook andMerchantProcessor: aMerchantProcessor on: aDate.! !


!classDefinition: #ChangeableClock category: #TusLibros!
Object subclass: #ChangeableClock
	instanceVariableNames: 'dateAndTime offset'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'TusLibros'!

!ChangeableClock methodsFor: 'time managment' stamp: 'F C 11/5/2017 23:23:01'!
advance: aDuration

	offset _ aDuration.! !

!ChangeableClock methodsFor: 'time managment' stamp: 'F C 11/5/2017 23:19:53'!
reset

	offset _ Duration seconds: 0.! !


!ChangeableClock methodsFor: 'time' stamp: 'F C 11/5/2017 23:46:56'!
now

	^DateAndTime unixTimeSeconds: DateAndTime now unixTimeSeconds + offset totalSeconds. ! !


!ChangeableClock methodsFor: 'initialization' stamp: 'F C 11/5/2017 23:23:43'!
initialize

	offset _ Duration seconds: 0.! !


!classDefinition: #CreditCard category: #TusLibros!
Object subclass: #CreditCard
	instanceVariableNames: 'owner number expirationDate'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'TusLibros'!

!CreditCard methodsFor: 'accessing' stamp: 'F C 11/6/2017 00:30:32'!
expirationDate

	^expirationDate.! !

!CreditCard methodsFor: 'accessing' stamp: 'F C 10/29/2017 19:24:04'!
number

	^number.! !

!CreditCard methodsFor: 'accessing' stamp: 'F C 10/29/2017 19:23:51'!
owner

	^owner.! !


!CreditCard methodsFor: 'initialization' stamp: 'F C 11/6/2017 00:30:23'!
initializeWith: anOwner andNumber: aNumber andExpirationDate: aMonthOfYear

	owner _ anOwner.
	number _ aNumber.
	expirationDate _ aMonthOfYear.! !


!CreditCard methodsFor: 'testing' stamp: 'F C 11/6/2017 00:30:45'!
isExpiredOn: aDate

	^expirationDate < aDate.! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

!classDefinition: 'CreditCard class' category: #TusLibros!
CreditCard class
	instanceVariableNames: ''!

!CreditCard class methodsFor: 'instance creation' stamp: 'F C 11/6/2017 00:29:58'!
withOwner: anOwner andNumber: aNumber andExpirationDate: aMonthOfYear

	^self new initializeWith: anOwner andNumber: aNumber andExpirationDate: aMonthOfYear.! !


!classDefinition: #Receipt category: #TusLibros!
Object subclass: #Receipt
	instanceVariableNames: 'amount purchases'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'TusLibros'!

!Receipt methodsFor: 'accessing' stamp: 'F C 10/29/2017 19:47:30'!
amount

	^amount.! !

!Receipt methodsFor: 'accessing' stamp: 'F C 10/29/2017 19:47:36'!
purchases

	^purchases copy.! !

!Receipt methodsFor: 'accessing' stamp: 'F C 10/29/2017 19:56:48'!
quantityFor: anItem

	^purchases occurrencesOf: anItem.! !


!Receipt methodsFor: 'initialization' stamp: 'F C 10/29/2017 19:48:56'!
initailizeWith: aNumber andPurchases: aCollectionOfPurchases

	amount _ aNumber.
	purchases _ aCollectionOfPurchases.! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

!classDefinition: 'Receipt class' category: #TusLibros!
Receipt class
	instanceVariableNames: ''!

!Receipt class methodsFor: 'instance creation' stamp: 'F C 10/29/2017 19:49:01'!
with: aNumber andPurchases: aCollectionOfPurchases

	^self new initailizeWith: aNumber andPurchases: aCollectionOfPurchases.! !


!classDefinition: #RestInterface category: #TusLibros!
Object subclass: #RestInterface
	instanceVariableNames: 'clientIdsAndPasswords carts catalog nextCartId salesBook merchantProcessor purchasesByUser userByCart clock cartsExpiration'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'TusLibros'!

!RestInterface methodsFor: 'interface' stamp: 'F C 11/6/2017 01:08:12'!
addTo: cartId quantity: aQuantity of: anItem 
	
	| cart |
	
	self perform: [
		cart _ carts at: cartId.
	
		(catalog includesKey: anItem) ifFalse: [self error: Cart isbnNotInCatalogErrorDescription].
	
		(aQuantity isInteger and: [ aQuantity strictlyPositive ]) ifFalse: [self error: Cart invalidQuantityErrorDescription].
	
		cart add: aQuantity of: anItem.	
	] andRefreshTtlOnNotExpired: cartId.
			
			
			

	
	
	
! !

!RestInterface methodsFor: 'interface' stamp: 'F C 11/6/2017 00:56:34'!
checkoutCart: aCartId andCreditCardNumber: aCreditCardNumber andExpirationDate: anExpirationDate andOwner: anOwner

	| receipt clientId purchases |
	
	self assertValidCart: aCartId.

	receipt _ (Cashier
		 withCart: (carts at: aCartId) 
		withCreditCard: (CreditCard withOwner: anOwner andNumber: aCreditCardNumber andExpirationDate: anExpirationDate) 
		andSalesBook: salesBook 
		andMerchantProcessor: merchantProcessor 
		on: FixedGregorianDate today) checkout.
	
	clientId _ userByCart at: aCartId.
	purchases _ purchasesByUser at: clientId ifAbsent: [ purchasesByUser at: clientId put: (OrderedCollection new).].
	purchases add: receipt.

	carts removeKey: aCartId.
	cartsExpiration removeKey: aCartId.
	userByCart removeKey: aCartId.
	
	^receipt.! !

!RestInterface methodsFor: 'interface' stamp: 'F C 11/6/2017 00:48:58'!
createCartWithClientId: aClientId andPassword: aPassword 

	|cartId |
	
	^self do: [
		cartId _ self generateCartId.
		carts at: cartId put:(Cart with: catalog).
	
		userByCart at: cartId put: aClientId.
		cartsExpiration at: cartId put: clock now.
	
		cartId.		
	] authenticatedWith: aClientId and: aPassword.

! !

!RestInterface methodsFor: 'interface' stamp: 'F C 11/6/2017 01:08:17'!
listCart: cartId

	^self perform: [ 	(carts at: cartId) items. ] andRefreshTtlOnNotExpired: cartId.
	
! !

!RestInterface methodsFor: 'interface' stamp: 'F C 11/6/2017 01:03:37'!
listPurchases: aClientId withPassword: aPassword 

	^self do: [ purchasesByUser at: aClientId. ] 
		 authenticatedWith: aClientId
 		 and: aPassword. ! !


!RestInterface methodsFor: 'asserts' stamp: 'F C 11/6/2017 01:08:25'!
assertValidCart: cartId

	| creationDate |
	
	(carts includesKey: cartId) ifFalse: [self error: RestInterface invalidCartIdErrorDescription].

	creationDate _ cartsExpiration at: cartId.

	(clock now unixTimeSeconds - creationDate unixTimeSeconds) >= ((Duration minutes: 30) totalSeconds) ifTrue: [ 
		carts removeKey: cartId.
		userByCart removeKey: cartId.
		cartsExpiration removeKey: cartId.
		self error: RestInterface invalidCartIdErrorDescription.
	]. 
! !

!RestInterface methodsFor: 'asserts' stamp: 'F C 11/6/2017 00:50:54'!
do: aBlockClosure authenticatedWith: clientId and: password

	| clientPassword |
	
	clientPassword _ clientIdsAndPasswords at: clientId ifAbsent: [ self error: RestInterface invalidCredentialsErrorDescription ].
	clientPassword = password ifFalse: [ self error: RestInterface invalidCredentialsErrorDescription ].
	
	^aBlockClosure value.! !

!RestInterface methodsFor: 'asserts' stamp: 'F C 11/6/2017 01:07:54'!
perform: aBlockClosure andRefreshTtlOnNotExpired: cartId

	| result |
	
	self assertValidCart: cartId.

	result _ aBlockClosure value.

	cartsExpiration at: cartId put: clock now.
	
	^result.! !


!RestInterface methodsFor: 'initialization' stamp: 'F C 11/6/2017 00:53:01'!
initilizeWithClientIds: clientInfo andCatalog: aCatalog andMerchantProcessor: aMerchantProcessor andClock: aClock
	
	clientIdsAndPasswords _ clientInfo.
	carts _ Dictionary new.
	nextCartId _ 0.
	catalog _ aCatalog.
	salesBook _ OrderedCollection new.
	merchantProcessor _ aMerchantProcessor.
	userByCart _ Dictionary new.
	purchasesByUser _ Dictionary new.
	clock _ aClock.
	cartsExpiration _ Dictionary new.
	! !


!RestInterface methodsFor: 'generate' stamp: 'F C 11/6/2017 00:41:05'!
generateCartId	
	
	| cartId |
	
	cartId _ nextCartId.
	nextCartId _ nextCartId + 1.
	
	^ cartId.! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

!classDefinition: 'RestInterface class' category: #TusLibros!
RestInterface class
	instanceVariableNames: ''!

!RestInterface class methodsFor: 'error descriptions' stamp: 'F C 11/6/2017 00:51:44'!
invalidCartIdErrorDescription

	^'invalid cart id'.! !

!RestInterface class methodsFor: 'error descriptions' stamp: 'F C 11/6/2017 00:50:31'!
invalidCredentialsErrorDescription

	^'invalid credentials'.! !


!RestInterface class methodsFor: 'instance creation' stamp: 'F C 11/6/2017 00:53:26'!
withClientInfo: clientInfo andCatalog: aCatalog andMerchantProcessor: aMerchantProcessor andClock: aClock
	
	^ self new initilizeWithClientIds: clientInfo andCatalog: aCatalog andMerchantProcessor: aMerchantProcessor andClock: aClock! !
