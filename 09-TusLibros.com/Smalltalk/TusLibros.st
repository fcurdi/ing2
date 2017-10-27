!classDefinition: #TusLibrosTest category: #TusLibros!
TestCase subclass: #TusLibrosTest
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'TusLibros'!

!TusLibrosTest methodsFor: 'as yet unclassified' stamp: 'FC_LR 10/26/2017 20:38:46'!
test01WhenCreateACartThenIsEmpty

	| cart |
	
	cart _ Cart with: Set new.
	
	self assert: cart isEmpty.! !

!TusLibrosTest methodsFor: 'as yet unclassified' stamp: 'FC_LR 10/26/2017 20:38:30'!
test02

	| cart isbn |
	
	isbn _ '123'.
	cart  _ Cart with: (Set with: isbn).
	cart add: isbn.
	
	self deny: cart isEmpty.
	self assert: cart size equals: 1.
	self assert: (cart includes: isbn).! !

!TusLibrosTest methodsFor: 'as yet unclassified' stamp: 'FC_LR 10/26/2017 20:38:16'!
test03

	| cart isbn |
	
	isbn _ '123'.
	cart  _ Cart with: (Set with: isbn).
	cart add: 2 of: isbn.
	
	self deny: cart isEmpty.
	self assert: cart size equals: 2.
	self assert: (cart quantiyOf: isbn) equals: 2.! !

!TusLibrosTest methodsFor: 'as yet unclassified' stamp: 'FC_LR 10/26/2017 20:52:49'!
test04

	| cart isbn |
	
	isbn _ '321'.
	cart  _ Cart with: (Set with: '123').
	
	self should: [cart add: isbn] raise: Error withExceptionDo: [ :anError | 
		self assert: anError messageText equals: 'cannot add an isbn that is not in the catalog'.
		self assert: cart isEmpty.
	].! !

!TusLibrosTest methodsFor: 'as yet unclassified' stamp: 'FC_LR 10/26/2017 21:01:17'!
test05

	| cart isbn |
	
	isbn _ '123'.
	cart  _ Cart with: (Set with: isbn).

	{ 0 . -1 . 3/2 } do: [ :aQuantity |
		self should: [	cart add: aQuantity of: isbn.] raise: Error withExceptionDo: [ :anError | 
			self assert: anError messageText equals: 'invalid quantity'.
			self assert: cart isEmpty.
		].
	].! !


!classDefinition: #Cart category: #TusLibros!
Object subclass: #Cart
	instanceVariableNames: 'items catalog'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'TusLibros'!

!Cart methodsFor: 'as yet unclassified' stamp: 'FC_LR 10/26/2017 20:25:30'!
add: anItem 
	
	self add: 1 of: anItem.! !

!Cart methodsFor: 'as yet unclassified' stamp: 'FC_LR 10/26/2017 20:59:55'!
add: aQuantity of: anItem 
	
	(catalog includes: anItem) ifFalse: [self error: 'cannot add an isbn that is not in the catalog'].
	(aQuantity isInteger and: [ aQuantity strictlyPositive ]) ifFalse: [self error: 'invalid quantity'].
	items add: anItem withOccurrences: aQuantity.! !

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
