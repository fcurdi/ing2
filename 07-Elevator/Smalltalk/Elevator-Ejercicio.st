!classDefinition: #ElevatorEmergency category: #'Elevator-Ejercicio'!
Error subclass: #ElevatorEmergency
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Elevator-Ejercicio'!


!classDefinition: #ElevatorTest category: #'Elevator-Ejercicio'!
TestCase subclass: #ElevatorTest
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Elevator-Ejercicio'!

!ElevatorTest methodsFor: 'tests 3' stamp: 'HernanWilkinson 7/10/2011 17:38'!
test09RequestToGoUpAreEnqueueWhenRequestedWhenCabinIsMoving

	| elevatorController |
	elevatorController := ElevatorController new.
	
	elevatorController goUpPushedFromFloor:1.
	elevatorController cabinDoorClosed.
	elevatorController cabinOnFloor:1.
	elevatorController goUpPushedFromFloor:2.
	elevatorController cabinDoorOpened.

	self assert: elevatorController isWorking.
	self assert: elevatorController isCabinWaitingForPeople.
	self assert: elevatorController isCabinDoorOpened.! !

!ElevatorTest methodsFor: 'tests 3' stamp: 'HernanWilkinson 7/10/2011 17:39'!
test10CabinDoorStartClosingAfterWaitingForPeople

	| elevatorController |
	elevatorController := ElevatorController new.
	
	elevatorController goUpPushedFromFloor:1.
	elevatorController cabinDoorClosed.
	elevatorController cabinOnFloor:1.
	elevatorController goUpPushedFromFloor:2.
	elevatorController cabinDoorOpened.
	elevatorController waitForPeopleTimedOut.

	self assert: elevatorController isWorking.
	self assert: elevatorController isCabinStopped.
	self assert: elevatorController isCabinDoorClosing.! !

!ElevatorTest methodsFor: 'tests 3' stamp: 'F C 10/4/2017 20:44:17'!
test11StopsWaitingForPeopleIfCloseDoorIsPressed

	| elevatorController |
	elevatorController := ElevatorController new.
	
	elevatorController goUpPushedFromFloor:1.
	elevatorController cabinDoorClosed.
	elevatorController cabinOnFloor:1.
	elevatorController goUpPushedFromFloor:2.
	elevatorController cabinDoorOpened.

	self assert: elevatorController isWorking.
	self assert: elevatorController isCabinWaitingForPeople.
	self assert: elevatorController isCabinDoorOpened.

	elevatorController closeCabinDoor.

	self assert: elevatorController isWorking.
	self assert: elevatorController isCabinStopped.
	self assert: elevatorController isCabinDoorClosing.
! !

!ElevatorTest methodsFor: 'tests 3' stamp: 'HernanWilkinson 7/10/2011 17:39'!
test12CloseDoorDoesNothingIfIdle

	| elevatorController |
	elevatorController := ElevatorController new.
	
	elevatorController closeCabinDoor.

	self assert: elevatorController isIdle.
	self assert: elevatorController isCabinStopped.
	self assert: elevatorController isCabinDoorOpened.! !

!ElevatorTest methodsFor: 'tests 3' stamp: 'HernanWilkinson 7/10/2011 17:40'!
test13CloseDoorDoesNothingWhenCabinIsMoving

	| elevatorController |
	elevatorController := ElevatorController new.
	
	elevatorController goUpPushedFromFloor:1.
	elevatorController cabinDoorClosed.

	self assert: elevatorController isWorking.
	self assert: elevatorController isCabinMoving.
	self assert: elevatorController isCabinDoorClosed.

	elevatorController closeCabinDoor.

	self assert: elevatorController isWorking.
	self assert: elevatorController isCabinMoving.
	self assert: elevatorController isCabinDoorClosed.! !

!ElevatorTest methodsFor: 'tests 3' stamp: 'HernanWilkinson 7/10/2011 17:40'!
test14CloseDoorDoesNothingWhenOpeningTheDoorToWaitForPeople

	| elevatorController |
	elevatorController := ElevatorController new.
		
	elevatorController goUpPushedFromFloor:1.
	elevatorController cabinDoorClosed.
	elevatorController cabinOnFloor:1.
	
	self assert: elevatorController isWorking.
	self assert: elevatorController isCabinStopped.
	self assert: elevatorController isCabinDoorOpening.

	elevatorController closeCabinDoor.

	self assert: elevatorController isWorking.
	self assert: elevatorController isCabinStopped.
	self assert: elevatorController isCabinDoorOpening.! !


!ElevatorTest methodsFor: 'tests 4' stamp: 'HernanWilkinson 7/10/2011 17:42'!
test15ElevatorHasToEnterEmergencyIfStoppedAndOtherFloorSensorTurnsOn

	| elevatorController |
	elevatorController := ElevatorController new.
	
	elevatorController goUpPushedFromFloor:1.
	elevatorController cabinDoorClosed.
	elevatorController cabinOnFloor:1.
	self 
		should: [ elevatorController cabinOnFloor:0 ]
		raise: ElevatorEmergency 
		withExceptionDo: [ :elevatorEmergency | self assert: elevatorEmergency messageText = 'Sensor de cabina desincronizado' ]! !

!ElevatorTest methodsFor: 'tests 4' stamp: 'HernanWilkinson 7/10/2011 17:47'!
test16ElevatorHasToEnterEmergencyIfFalling

	| elevatorController |
	elevatorController := ElevatorController new.
	
	elevatorController goUpPushedFromFloor:2.
	elevatorController cabinDoorClosed.
	elevatorController cabinOnFloor:1.
	self 
		should: [ elevatorController cabinOnFloor:0 ]
		raise: ElevatorEmergency 
		withExceptionDo: [ :elevatorEmergency | self assert: elevatorEmergency messageText = 'Sensor de cabina desincronizado'. ]! !

!ElevatorTest methodsFor: 'tests 4' stamp: 'HernanWilkinson 7/10/2011 17:47'!
test17ElevatorHasToEnterEmergencyIfJumpsFloors

	| elevatorController |
	elevatorController := ElevatorController new.
	
	elevatorController goUpPushedFromFloor:3.
	elevatorController cabinDoorClosed.
	self 
		should: [ elevatorController cabinOnFloor: 3 ]
		raise: ElevatorEmergency 
		withExceptionDo: [ :elevatorEmergency | self assert: elevatorEmergency messageText = 'Sensor de cabina desincronizado'. ]! !

!ElevatorTest methodsFor: 'tests 4' stamp: 'HernanWilkinson 7/10/2011 17:48'!
test18ElevatorHasToEnterEmergencyIfDoorClosesAutomatically
	| elevatorController |
	elevatorController := ElevatorController new.
	
	self 
		should: [ elevatorController cabinDoorClosed.]
		raise: ElevatorEmergency 
		withExceptionDo: [ :elevatorEmergency | self assert: elevatorEmergency messageText = 'Sensor de puerta desincronizado' ]! !

!ElevatorTest methodsFor: 'tests 4' stamp: 'HernanWilkinson 7/10/2011 17:48'!
test19ElevatorHasToEnterEmergencyIfDoorClosedSensorTurnsOnWhenClosed

	| elevatorController |
	elevatorController := ElevatorController new.
	
	elevatorController goUpPushedFromFloor:1.
	elevatorController cabinDoorClosed.
	self 
		should: [elevatorController cabinDoorClosed.]
		raise: ElevatorEmergency 
		withExceptionDo: [ :elevatorEmergency | self assert: elevatorEmergency messageText = 'Sensor de puerta desincronizado'. ]! !

!ElevatorTest methodsFor: 'tests 4' stamp: 'HernanWilkinson 7/10/2011 17:49'!
test20ElevatorHasToEnterEmergencyIfDoorClosesWhenOpening
	| elevatorController |
	elevatorController := ElevatorController new.
		
	elevatorController goUpPushedFromFloor:1.
	elevatorController cabinDoorClosed.
	elevatorController cabinOnFloor:1.
	self 
		should: [elevatorController cabinDoorClosed.]
		raise: ElevatorEmergency 
		withExceptionDo: [ :elevatorEmergency | self assert: elevatorEmergency messageText = 'Sensor de puerta desincronizado'.]! !


!ElevatorTest methodsFor: 'tests 2' stamp: 'HernanWilkinson 7/10/2011 17:35'!
test06DoorKeepsOpenedWhenOpeningIsRequested

	| elevatorController |
	elevatorController := ElevatorController new.
	
	self assert: elevatorController isCabinDoorOpened.
	
	elevatorController openCabinDoor.

	self assert: elevatorController isCabinDoorOpened.! !

!ElevatorTest methodsFor: 'tests 2' stamp: 'HernanWilkinson 6/16/2014 13:24'!
test07DoorMustBeOpenedWhenCabinIsStoppedAndClosingDoors

	| elevatorController |
	elevatorController := ElevatorController new.

	elevatorController goUpPushedFromFloor:1.
		
	self assert: elevatorController isWorking.
	self assert: elevatorController isCabinStopped.
	self assert: elevatorController isCabinDoorClosing.
		
	elevatorController openCabinDoor.
	self assert: elevatorController isWorking.
	self assert: elevatorController isCabinStopped.
	self assert: elevatorController isCabinDoorOpening.
! !

!ElevatorTest methodsFor: 'tests 2' stamp: 'HernanWilkinson 7/10/2011 17:36'!
test08CanNotOpenDoorWhenCabinIsMoving

	| elevatorController |
	elevatorController := ElevatorController new.

	elevatorController goUpPushedFromFloor:1.
	elevatorController cabinDoorClosed.
	
	self assert: elevatorController isWorking.
	self assert: elevatorController isCabinMoving.
	self assert: elevatorController isCabinDoorClosed.

	elevatorController openCabinDoor.
	self assert: elevatorController isWorking.
	self assert: elevatorController isCabinMoving.
	self assert: elevatorController isCabinDoorClosed.! !

!ElevatorTest methodsFor: 'tests 2' stamp: 'HernanWilkinson 7/10/2011 17:51'!
test09DoorKeepsOpeneingWhenItIsOpeneing

	| elevatorController |
	elevatorController := ElevatorController new.

	elevatorController goUpPushedFromFloor:1.
	elevatorController cabinDoorClosed.
	elevatorController cabinOnFloor:1.

	self assert: elevatorController isWorking.
	self assert: elevatorController isCabinStopped.
	self assert: elevatorController isCabinDoorOpening.

	elevatorController openCabinDoor.
	self assert: elevatorController isWorking.
	self assert: elevatorController isCabinStopped.
	self assert: elevatorController isCabinDoorOpening.! !


!ElevatorTest methodsFor: 'tests 5' stamp: 'HernanWilkinson 7/10/2011 17:50'!
test21CabinHasToStopOnTheFloorsOnItsWay
	| elevatorController |
	elevatorController := ElevatorController new.
	
	elevatorController goUpPushedFromFloor:1.
	elevatorController cabinDoorClosed.
	elevatorController goUpPushedFromFloor:2.
	elevatorController cabinOnFloor:1.

	self assert: elevatorController isWorking.
	self assert: elevatorController isCabinStopped.
	self assert: elevatorController isCabinDoorOpening.! !

!ElevatorTest methodsFor: 'tests 5' stamp: 'HernanWilkinson 7/10/2011 17:50'!
test22ElevatorCompletesAllTheRequests
	| elevatorController |
	elevatorController := ElevatorController new.
	
	elevatorController goUpPushedFromFloor:1.
	elevatorController cabinDoorClosed.
	elevatorController goUpPushedFromFloor:2.
	elevatorController cabinOnFloor:1.
	elevatorController cabinDoorOpened.
	elevatorController waitForPeopleTimedOut.
	elevatorController cabinDoorClosed.
	elevatorController cabinOnFloor:2.
	
	self assert: elevatorController isWorking.
	self assert: elevatorController isCabinStopped.
	self assert: elevatorController isCabinDoorOpening.! !

!ElevatorTest methodsFor: 'tests 5' stamp: 'HernanWilkinson 7/10/2011 17:50'!
test23CabinHasToStopOnFloorsOnItsWayNoMatterHowTheyWellCalled

	| elevatorController |
	elevatorController := ElevatorController new.
		
	elevatorController goUpPushedFromFloor:2.
	elevatorController cabinDoorClosed.
	elevatorController goUpPushedFromFloor:1.
	elevatorController cabinOnFloor:1.
		
	self assert: elevatorController isWorking.
	self assert: elevatorController isCabinStopped.
	self assert: elevatorController isCabinDoorOpening.! !

!ElevatorTest methodsFor: 'tests 5' stamp: 'HernanWilkinson 7/10/2011 17:51'!
test24CabinHasToStopAndWaitForPeopleOnFloorsOnItsWayNoMatterHowTheyWellCalled

	| elevatorController |
	elevatorController := ElevatorController new.
	
	elevatorController goUpPushedFromFloor:2.
	elevatorController cabinDoorClosed.
	elevatorController goUpPushedFromFloor:1.
	elevatorController cabinOnFloor:1.
	elevatorController cabinDoorOpened.
	elevatorController waitForPeopleTimedOut.
	
	self assert: elevatorController isWorking.
	self assert: elevatorController isCabinStopped.
	self assert: elevatorController isCabinDoorClosing.! !


!ElevatorTest methodsFor: 'tests 1' stamp: 'HernanWilkinson 7/10/2011 17:33'!
test01ElevatorStartsIdleWithDoorOpenOnFloorZero

	| elevatorController |
		
	elevatorController := ElevatorController new.
		
	self assert: elevatorController isIdle.
	self assert: elevatorController isCabinStopped.
	self assert: elevatorController isCabinDoorOpened.
	self assert: elevatorController cabinFloorNumber = 0
! !

!ElevatorTest methodsFor: 'tests 1' stamp: 'HernanWilkinson 7/15/2011 17:53'!
test02CabinDoorStartsClosingWhenElevatorGetsCalled

	| elevatorController |
	elevatorController := ElevatorController new.

	elevatorController goUpPushedFromFloor: 1.
	
	self deny: elevatorController isIdle.
	self assert: elevatorController isWorking.
	
	self assert: elevatorController isCabinStopped.
	self deny: elevatorController isCabinMoving.
	
	self deny: elevatorController isCabinDoorOpened.
	self deny: elevatorController isCabinDoorOpening.
	self assert: elevatorController isCabinDoorClosing.
	self deny: elevatorController isCabinDoorClosed.! !

!ElevatorTest methodsFor: 'tests 1' stamp: 'F C 10/3/2017 23:45:27'!
test03CabinStartsMovingWhenDoorGetsClosed

	| elevatorController |
	elevatorController := ElevatorController new.

	elevatorController goUpPushedFromFloor:1.
	elevatorController cabinDoorClosed.
	
	self deny: elevatorController isIdle.
	self assert: elevatorController isWorking.

	self deny: elevatorController isCabinStopped.
	self assert: elevatorController isCabinMoving.
	
	self deny: elevatorController isCabinDoorOpened.
	self deny: elevatorController isCabinDoorOpening.
	self deny: elevatorController isCabinDoorClosing.
	self assert: elevatorController isCabinDoorClosed.
	! !

!ElevatorTest methodsFor: 'tests 1' stamp: 'F C 10/4/2017 20:22:04'!
test04CabinStopsAndStartsOpeningDoorWhenGetsToDestination

	| elevatorController |
	elevatorController := ElevatorController new.

	elevatorController goUpPushedFromFloor: 1.
	elevatorController cabinDoorClosed.
	elevatorController cabinOnFloor: 1.

	self deny: elevatorController isIdle.
	self assert: elevatorController isWorking.
	
	self assert: elevatorController isCabinStopped.
	self deny: elevatorController isCabinMoving.
			
	self deny: elevatorController isCabinDoorOpened.
	self assert: elevatorController isCabinDoorOpening.
	self deny: elevatorController isCabinDoorClosing.
	self deny: elevatorController isCabinDoorClosed.

	self assert: elevatorController cabinFloorNumber = 1
! !

!ElevatorTest methodsFor: 'tests 1' stamp: 'HernanWilkinson 7/15/2011 18:00'!
test05ElevatorGetsIdleWhenDoorGetOpened

	| elevatorController |
	elevatorController := ElevatorController new.
	
	elevatorController goUpPushedFromFloor: 1.
	elevatorController cabinDoorClosed.
	elevatorController cabinOnFloor: 1.
	elevatorController cabinDoorOpened.
		
	self assert: elevatorController isIdle.
	self deny: elevatorController isWorking.
		
	self assert: elevatorController isCabinStopped.
	self deny: elevatorController isCabinMoving.

	self assert: elevatorController isCabinDoorOpened.
	self deny: elevatorController isCabinDoorOpening.
	self deny: elevatorController isCabinDoorClosing.
	self deny: elevatorController isCabinDoorClosed.
		
	self assert: elevatorController cabinFloorNumber = 1! !


!classDefinition: #Cabin category: #'Elevator-Ejercicio'!
Object subclass: #Cabin
	instanceVariableNames: 'door state'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Elevator-Ejercicio'!

!Cabin methodsFor: 'testing' stamp: 'F C 10/8/2017 23:44:54'!
isDoorClosed
	
	^door isClosed.! !

!Cabin methodsFor: 'testing' stamp: 'F C 10/3/2017 23:31:30'!
isDoorClosing
	
	^door isClosing.! !

!Cabin methodsFor: 'testing' stamp: 'F C 10/3/2017 23:20:08'!
isDoorOpened

	^door isOpened.! !

!Cabin methodsFor: 'testing' stamp: 'F C 10/3/2017 23:30:27'!
isDoorOpening

	^door isOpening.! !

!Cabin methodsFor: 'testing' stamp: 'F C 10/3/2017 23:17:11'!
isMoving

	^state isMoving.! !

!Cabin methodsFor: 'testing' stamp: 'F C 10/8/2017 23:45:23'!
isStopped

	^state isStopped.! !

!Cabin methodsFor: 'testing' stamp: 'F C 10/4/2017 20:32:09'!
isWaitingForPeople

	^state isWaitingForPeople.! !


!Cabin methodsFor: 'operating' stamp: 'F C 10/4/2017 20:58:18'!
closeDoor

	state closeDoor.! !

!Cabin methodsFor: 'operating' stamp: 'F C 10/8/2017 22:44:45'!
closeDoorWhenMoving! !

!Cabin methodsFor: 'operating' stamp: 'F C 10/4/2017 22:18:37'!
closeDoorWhenStopped

	door close.! !

!Cabin methodsFor: 'operating' stamp: 'F C 10/8/2017 23:02:35'!
closeDoorWhenWaitingForPeople

	door closeWhenWaitingForPeople.! !

!Cabin methodsFor: 'operating' stamp: 'F C 10/4/2017 20:19:52'!
openDoor

	state openDoor.! !

!Cabin methodsFor: 'operating' stamp: 'F C 10/8/2017 22:45:38'!
openDoorWhenMoving! !

!Cabin methodsFor: 'operating' stamp: 'F C 10/8/2017 23:16:54'!
openDoorWhenOnFloor

	state := WaitingForPeopleCabinState for: self.
	door open.
! !

!Cabin methodsFor: 'operating' stamp: 'F C 10/4/2017 20:07:36'!
openDoorWhenStopped
	
	door open.! !

!Cabin methodsFor: 'operating' stamp: 'F C 10/8/2017 22:47:23'!
openDoorWhenWaitingForPeople! !

!Cabin methodsFor: 'operating' stamp: 'F C 10/4/2017 23:05:48'!
waitForPeopleTimedOut

	self closeDoorWhenWaitingForPeople.! !


!Cabin methodsFor: 'initialization' stamp: 'F C 10/4/2017 20:02:35'!
initialize
	
	super initialize.
	state _ StoppedCabinState for: self.
	door _ Door new.! !


!Cabin methodsFor: 'sensor' stamp: 'F C 10/4/2017 20:03:48'!
doorClosed
	
	door closed.
	state := MovingCabinState for: self.! !

!Cabin methodsFor: 'sensor' stamp: 'F C 10/4/2017 23:00:51'!
doorOpenedWithFloorsToGo

	door opened.
	state := WaitingForPeopleCabinState for: self.! !

!Cabin methodsFor: 'sensor' stamp: 'F C 10/4/2017 23:00:59'!
doorOpenedWithNoFloorsToGo
	
	door opened.
	state := StoppedCabinState for: self.! !


!classDefinition: #CabinState category: #'Elevator-Ejercicio'!
Object subclass: #CabinState
	instanceVariableNames: 'cabin'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Elevator-Ejercicio'!

!CabinState methodsFor: 'testing' stamp: 'F C 10/3/2017 23:41:43'!
isMoving

	^false.! !

!CabinState methodsFor: 'testing' stamp: 'F C 10/3/2017 23:41:49'!
isStopped

	^false.! !

!CabinState methodsFor: 'testing' stamp: 'F C 10/4/2017 20:32:49'!
isWaitingForPeople

	^false.! !


!CabinState methodsFor: 'operating' stamp: 'F C 10/4/2017 20:01:08'!
closeDoor

	self subclassResponsibility.! !

!CabinState methodsFor: 'operating' stamp: 'F C 10/4/2017 20:01:04'!
openDoor

	self subclassResponsibility.! !


!CabinState methodsFor: 'initialization' stamp: 'F C 10/4/2017 19:54:11'!
initializeWith: aCabin

	cabin := aCabin.! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

!classDefinition: 'CabinState class' category: #'Elevator-Ejercicio'!
CabinState class
	instanceVariableNames: ''!

!CabinState class methodsFor: 'instance creation' stamp: 'F C 10/4/2017 19:59:03'!
for: aCabin

	^self new initializeWith: aCabin.! !


!classDefinition: #MovingCabinState category: #'Elevator-Ejercicio'!
CabinState subclass: #MovingCabinState
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Elevator-Ejercicio'!

!MovingCabinState methodsFor: 'operating' stamp: 'F C 10/8/2017 22:44:50'!
closeDoor

	cabin closeDoorWhenMoving.! !

!MovingCabinState methodsFor: 'operating' stamp: 'F C 10/8/2017 22:45:29'!
openDoor
	
	cabin openDoorWhenMoving.! !


!MovingCabinState methodsFor: 'testing' stamp: 'F C 10/3/2017 23:41:55'!
isMoving

	^true.! !


!classDefinition: #StoppedCabinState category: #'Elevator-Ejercicio'!
CabinState subclass: #StoppedCabinState
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Elevator-Ejercicio'!

!StoppedCabinState methodsFor: 'operating' stamp: 'F C 10/4/2017 22:17:36'!
closeDoor
	
	cabin closeDoorWhenStopped.! !

!StoppedCabinState methodsFor: 'operating' stamp: 'F C 10/4/2017 20:05:39'!
openDoor

	cabin openDoorWhenStopped.! !


!StoppedCabinState methodsFor: 'testing' stamp: 'F C 10/3/2017 23:42:03'!
isStopped

	^true.! !


!classDefinition: #WaitingForPeopleCabinState category: #'Elevator-Ejercicio'!
CabinState subclass: #WaitingForPeopleCabinState
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Elevator-Ejercicio'!

!WaitingForPeopleCabinState methodsFor: 'operating' stamp: 'F C 10/4/2017 22:27:13'!
closeDoor

	cabin closeDoorWhenWaitingForPeople.! !

!WaitingForPeopleCabinState methodsFor: 'operating' stamp: 'F C 10/8/2017 22:47:17'!
openDoor

	cabin openDoorWhenWaitingForPeople.! !


!WaitingForPeopleCabinState methodsFor: 'testing' stamp: 'F C 10/4/2017 20:32:55'!
isWaitingForPeople

	^true.! !


!classDefinition: #ControllerState category: #'Elevator-Ejercicio'!
Object subclass: #ControllerState
	instanceVariableNames: 'controller'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Elevator-Ejercicio'!

!ControllerState methodsFor: 'testing' stamp: 'F C 10/3/2017 23:55:35'!
isIdle

	^false.! !

!ControllerState methodsFor: 'testing' stamp: 'F C 10/3/2017 23:55:42'!
isWorking

	^false.! !


!ControllerState methodsFor: 'sensor' stamp: 'F C 10/8/2017 23:56:18'!
doorClosed
	
	self subclassResponsibility.! !

!ControllerState methodsFor: 'sensor' stamp: 'F C 10/8/2017 23:56:23'!
doorOpened
	
	self subclassResponsibility.! !


!ControllerState methodsFor: 'operating' stamp: 'F C 10/8/2017 23:55:59'!
closeCabinDoor

	self subclassResponsibility.! !

!ControllerState methodsFor: 'operating' stamp: 'F C 10/8/2017 23:56:03'!
openCabinDoor

	self subclassResponsibility.! !


!ControllerState methodsFor: 'initialization' stamp: 'F C 10/4/2017 20:52:59'!
initializeWith: aController

	controller := aController.! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

!classDefinition: 'ControllerState class' category: #'Elevator-Ejercicio'!
ControllerState class
	instanceVariableNames: ''!

!ControllerState class methodsFor: 'instance creation' stamp: 'F C 10/4/2017 20:49:48'!
for: aController

	^self new initializeWith: aController.! !


!classDefinition: #IdleControllerState category: #'Elevator-Ejercicio'!
ControllerState subclass: #IdleControllerState
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Elevator-Ejercicio'!

!IdleControllerState methodsFor: 'sensor' stamp: 'F C 10/4/2017 21:44:28'!
doorClosed

	controller doorClosedWhenIdle.! !

!IdleControllerState methodsFor: 'sensor' stamp: 'F C 10/8/2017 23:58:51'!
doorOpened

	controller doorOpenedWhenIdle.! !


!IdleControllerState methodsFor: 'testing' stamp: 'F C 10/3/2017 23:08:52'!
isIdle
	
	^true.! !


!IdleControllerState methodsFor: 'operating' stamp: 'F C 10/8/2017 23:53:30'!
closeCabinDoor

	controller closeCabinDoorWhenIdle.! !

!IdleControllerState methodsFor: 'operating' stamp: 'F C 10/8/2017 23:57:42'!
openCabinDoor

	controller openCabinDoorWhenIdle.! !


!classDefinition: #WorkingControllerState category: #'Elevator-Ejercicio'!
ControllerState subclass: #WorkingControllerState
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Elevator-Ejercicio'!

!WorkingControllerState methodsFor: 'operating' stamp: 'F C 10/4/2017 20:54:43'!
closeCabinDoor
	
	controller closeCabinDoorWhenWorking.! !

!WorkingControllerState methodsFor: 'operating' stamp: 'F C 10/9/2017 00:00:41'!
openCabinDoor

	controller openCabinDoorWhenWorking.! !


!WorkingControllerState methodsFor: 'testing' stamp: 'F C 10/3/2017 23:55:52'!
isWorking

	^true.! !


!WorkingControllerState methodsFor: 'sensor' stamp: 'F C 10/4/2017 21:49:59'!
doorClosed

	controller doorClosedWhenWorking.! !

!WorkingControllerState methodsFor: 'sensor' stamp: 'F C 10/9/2017 00:02:22'!
doorOpened

	controller doorOpenedWhenWorking.! !


!classDefinition: #Door category: #'Elevator-Ejercicio'!
Object subclass: #Door
	instanceVariableNames: 'state'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Elevator-Ejercicio'!

!Door methodsFor: 'testing' stamp: 'F C 10/3/2017 23:36:28'!
isClosed
	
	^state isClosed.
	! !

!Door methodsFor: 'testing' stamp: 'F C 10/3/2017 23:31:41'!
isClosing

	^state isClosing.! !

!Door methodsFor: 'testing' stamp: 'F C 10/8/2017 23:21:54'!
isOpened

	^state isOpened.! !

!Door methodsFor: 'testing' stamp: 'F C 10/3/2017 23:30:42'!
isOpening

	^state isOpening.! !


!Door methodsFor: 'initialization' stamp: 'F C 10/4/2017 22:45:43'!
initialize

	super initialize.
	state := OpenedDoorState for: self.! !


!Door methodsFor: 'sensor' stamp: 'F C 10/8/2017 23:33:30'!
closed

	state closed.! !

!Door methodsFor: 'sensor' stamp: 'F C 10/8/2017 23:18:56'!
closedWhenClosed

	ElevatorEmergency signal: 'Sensor de puerta desincronizado'.! !

!Door methodsFor: 'sensor' stamp: 'F C 10/8/2017 23:29:08'!
closedWhenClosing

	state := ClosedDoorState for: self.! !

!Door methodsFor: 'sensor' stamp: 'F C 10/8/2017 22:54:56'!
closedWhenOpened

	ElevatorEmergency signal: 'Sensor de puerta desincronizado'.! !

!Door methodsFor: 'sensor' stamp: 'F C 10/8/2017 22:56:34'!
closedWhenOpening

	ElevatorEmergency signal: 'Sensor de puerta desincronizado'.! !

!Door methodsFor: 'sensor' stamp: 'F C 10/8/2017 23:34:37'!
opened

	state opened.
	! !

!Door methodsFor: 'sensor' stamp: 'F C 10/8/2017 23:37:21'!
openedWhenClosed

	ElevatorEmergency signal: 'Sensor de puerta desincronizado'.! !

!Door methodsFor: 'sensor' stamp: 'F C 10/8/2017 23:37:25'!
openedWhenClosing

	ElevatorEmergency signal: 'Sensor de puerta desincronizado'.! !

!Door methodsFor: 'sensor' stamp: 'F C 10/8/2017 23:37:29'!
openedWhenOpened

	ElevatorEmergency signal: 'Sensor de puerta desincronizado'.! !

!Door methodsFor: 'sensor' stamp: 'F C 10/8/2017 23:37:39'!
openedWhenOpening

	state := OpenedDoorState for: self.! !


!Door methodsFor: 'operating' stamp: 'F C 10/8/2017 23:38:08'!
close

	state close.! !

!Door methodsFor: 'operating' stamp: 'F C 10/8/2017 23:26:26'!
closeWhenClosed

	! !

!Door methodsFor: 'operating' stamp: 'F C 10/8/2017 23:28:29'!
closeWhenClosing! !

!Door methodsFor: 'operating' stamp: 'F C 10/8/2017 23:30:42'!
closeWhenOpened

	state := ClosingDoorState for: self.! !

!Door methodsFor: 'operating' stamp: 'F C 10/8/2017 23:31:57'!
closeWhenOpening

	state := ClosingDoorState for: self.! !

!Door methodsFor: 'operating' stamp: 'F C 10/8/2017 23:16:39'!
closeWhenWaitingForPeople

	state isOpening ifFalse: [ self close].! !

!Door methodsFor: 'operating' stamp: 'F C 10/8/2017 23:38:44'!
open

	state open.! !

!Door methodsFor: 'operating' stamp: 'F C 10/8/2017 23:27:43'!
openWhenClosed

	state := OpeningDoorState for: self.! !

!Door methodsFor: 'operating' stamp: 'F C 10/8/2017 23:29:50'!
openWhenClosing

	state := OpeningDoorState for: self.! !

!Door methodsFor: 'operating' stamp: 'F C 10/8/2017 23:31:15'!
openWhenOpened! !

!Door methodsFor: 'operating' stamp: 'F C 10/8/2017 23:32:29'!
openWhenOpening! !


!classDefinition: #DoorState category: #'Elevator-Ejercicio'!
Object subclass: #DoorState
	instanceVariableNames: 'door'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Elevator-Ejercicio'!

!DoorState methodsFor: 'testing' stamp: 'F C 10/3/2017 23:34:22'!
isClosed

	^false.! !

!DoorState methodsFor: 'testing' stamp: 'F C 10/3/2017 23:34:19'!
isClosing

	^false.! !

!DoorState methodsFor: 'testing' stamp: 'F C 10/3/2017 23:34:24'!
isOpened

	^false.! !

!DoorState methodsFor: 'testing' stamp: 'F C 10/3/2017 23:34:15'!
isOpening

	^false.! !


!DoorState methodsFor: 'initialization' stamp: 'F C 10/4/2017 21:57:52'!
initializeWith: aDoor

	door := aDoor.! !


!DoorState methodsFor: 'operating' stamp: 'F C 10/3/2017 23:35:35'!
close

	self subclassResponsibility.! !

!DoorState methodsFor: 'operating' stamp: 'F C 10/4/2017 00:03:24'!
open

	^self subclassResponsibility.! !


!DoorState methodsFor: 'sensor' stamp: 'F C 10/8/2017 23:17:48'!
closed

	self subclassResponsibility.! !

!DoorState methodsFor: 'sensor' stamp: 'F C 10/8/2017 23:34:55'!
opened

	self subclassResponsibility.! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

!classDefinition: 'DoorState class' category: #'Elevator-Ejercicio'!
DoorState class
	instanceVariableNames: ''!

!DoorState class methodsFor: 'instance creation' stamp: 'F C 10/4/2017 21:57:40'!
for: aDoor

	^self new initializeWith: aDoor.! !


!classDefinition: #ClosedDoorState category: #'Elevator-Ejercicio'!
DoorState subclass: #ClosedDoorState
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Elevator-Ejercicio'!

!ClosedDoorState methodsFor: 'operating' stamp: 'F C 10/8/2017 23:26:03'!
close
	
	door closeWhenClosed.! !

!ClosedDoorState methodsFor: 'operating' stamp: 'F C 10/8/2017 23:27:11'!
open

	door openWhenClosed.! !


!ClosedDoorState methodsFor: 'testing' stamp: 'F C 10/3/2017 23:34:45'!
isClosed

	^true.! !


!ClosedDoorState methodsFor: 'sensor' stamp: 'F C 10/8/2017 23:19:06'!
closed

	door closedWhenClosed.! !

!ClosedDoorState methodsFor: 'sensor' stamp: 'F C 10/8/2017 23:35:08'!
opened

	door openedWhenClosed.! !


!classDefinition: #ClosingDoorState category: #'Elevator-Ejercicio'!
DoorState subclass: #ClosingDoorState
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Elevator-Ejercicio'!

!ClosingDoorState methodsFor: 'testing' stamp: 'F C 10/3/2017 23:32:53'!
isClosing
	
	^true.! !


!ClosingDoorState methodsFor: 'operating' stamp: 'F C 10/8/2017 23:28:22'!
close

	door closeWhenClosing.! !

!ClosingDoorState methodsFor: 'operating' stamp: 'F C 10/8/2017 23:29:38'!
open
	
	door openWhenClosing.! !


!ClosingDoorState methodsFor: 'sensor' stamp: 'F C 10/8/2017 23:28:50'!
closed

	door closedWhenClosing.! !

!ClosingDoorState methodsFor: 'sensor' stamp: 'F C 10/8/2017 23:35:40'!
opened

	door openedWhenClosing.! !


!classDefinition: #OpenedDoorState category: #'Elevator-Ejercicio'!
DoorState subclass: #OpenedDoorState
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Elevator-Ejercicio'!

!OpenedDoorState methodsFor: 'operating' stamp: 'F C 10/8/2017 23:30:23'!
close

	door closeWhenOpened.! !

!OpenedDoorState methodsFor: 'operating' stamp: 'F C 10/8/2017 23:31:09'!
open
	
	door openWhenOpened.! !


!OpenedDoorState methodsFor: 'testing' stamp: 'F C 10/3/2017 23:23:36'!
isOpened

	^true.! !


!OpenedDoorState methodsFor: 'sensor' stamp: 'F C 10/8/2017 22:54:50'!
closed

	door closedWhenOpened.! !

!OpenedDoorState methodsFor: 'sensor' stamp: 'F C 10/8/2017 23:36:07'!
opened

	door openedWhenOpened.! !


!classDefinition: #OpeningDoorState category: #'Elevator-Ejercicio'!
DoorState subclass: #OpeningDoorState
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Elevator-Ejercicio'!

!OpeningDoorState methodsFor: 'operating' stamp: 'F C 10/8/2017 23:31:45'!
close

	door closeWhenOpening.! !

!OpeningDoorState methodsFor: 'operating' stamp: 'F C 10/8/2017 23:32:22'!
open

	door openWhenOpening.! !


!OpeningDoorState methodsFor: 'testing' stamp: 'F C 10/3/2017 23:35:19'!
isOpening

	^true.! !


!OpeningDoorState methodsFor: 'sensor' stamp: 'F C 10/8/2017 22:56:44'!
closed
	
	door closedWhenOpening.! !

!OpeningDoorState methodsFor: 'sensor' stamp: 'F C 10/8/2017 23:36:27'!
opened

	door openedWhenOpening.! !


!classDefinition: #ElevatorController category: #'Elevator-Ejercicio'!
Object subclass: #ElevatorController
	instanceVariableNames: 'cabin state floorsToGo currentFloor'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Elevator-Ejercicio'!

!ElevatorController methodsFor: 'testing' stamp: 'F C 10/3/2017 23:36:07'!
isCabinDoorClosed
	
	^cabin isDoorClosed.! !

!ElevatorController methodsFor: 'testing' stamp: 'F C 10/3/2017 23:31:18'!
isCabinDoorClosing

	^cabin isDoorClosing.! !

!ElevatorController methodsFor: 'testing' stamp: 'F C 10/3/2017 23:19:05'!
isCabinDoorOpened

	^cabin isDoorOpened.! !

!ElevatorController methodsFor: 'testing' stamp: 'F C 10/3/2017 23:30:14'!
isCabinDoorOpening

	^cabin isDoorOpening.! !

!ElevatorController methodsFor: 'testing' stamp: 'F C 10/3/2017 23:16:32'!
isCabinMoving
	
	^cabin isMoving.! !

!ElevatorController methodsFor: 'testing' stamp: 'F C 10/3/2017 23:15:15'!
isCabinStopped
	
	^self isCabinMoving not.! !

!ElevatorController methodsFor: 'testing' stamp: 'F C 10/4/2017 20:32:16'!
isCabinWaitingForPeople

	^cabin isWaitingForPeople.! !

!ElevatorController methodsFor: 'testing' stamp: 'F C 10/3/2017 23:07:38'!
isIdle

	^state isIdle.! !

!ElevatorController methodsFor: 'testing' stamp: 'F C 10/9/2017 00:08:17'!
isWorking

	^state isWorking.! !


!ElevatorController methodsFor: 'sensor' stamp: 'F C 10/4/2017 21:44:06'!
cabinDoorClosed

	state doorClosed.! !

!ElevatorController methodsFor: 'sensor' stamp: 'F C 10/9/2017 00:10:25'!
cabinDoorOpened

	floorsToGo isEmpty 
		ifTrue: [ 
			state := IdleControllerState for: self.
			cabin doorOpenedWithNoFloorsToGo.
		]
		ifFalse: [
			cabin doorOpenedWithFloorsToGo.
		].
	
	"aca habria que mandarselo al state. El state me puede decir si tengo pisos para ir o no, osea si
	esta idle o working??"
	
! !

!ElevatorController methodsFor: 'sensor' stamp: 'F C 10/4/2017 22:39:42'!
cabinOnFloor: floor

	floor = (currentFloor + 1) ifFalse: [ ElevatorEmergency signal: 'Sensor de cabina desincronizado'].

	currentFloor := floor.
	floorsToGo remove: floor ifAbsent: [ ]. "dudoso que no haga nada. Si bien es porque floor puede ser uno por el que paso pero el cual nadie pidio ir"
	cabin openDoorWhenOnFloor.! !

!ElevatorController methodsFor: 'sensor' stamp: 'F C 10/8/2017 23:55:10'!
doorClosedWhenIdle

	ElevatorEmergency signal: 'Sensor de puerta desincronizado'.! !

!ElevatorController methodsFor: 'sensor' stamp: 'F C 10/4/2017 21:50:25'!
doorClosedWhenWorking

	cabin doorClosed.! !

!ElevatorController methodsFor: 'sensor' stamp: 'F C 10/8/2017 23:59:14'!
doorOpenedWhenIdle

	ElevatorEmergency signal: 'Sensor de puerta desincronizado'.! !

!ElevatorController methodsFor: 'sensor' stamp: 'F C 10/9/2017 00:11:02'!
doorOpenedWhenWorking

	cabin doorOpened.! !

!ElevatorController methodsFor: 'sensor' stamp: 'F C 10/4/2017 20:51:47'!
goUpPushedFromFloor: floor

	state _ WorkingControllerState for: self.
	cabin closeDoor.
	floorsToGo add: floor.! !

!ElevatorController methodsFor: 'sensor' stamp: 'F C 10/4/2017 20:42:47'!
waitForPeopleTimedOut

	cabin waitForPeopleTimedOut.! !


!ElevatorController methodsFor: 'accessing' stamp: 'F C 10/3/2017 23:52:42'!
cabinFloorNumber
	
	^currentFloor.! !


!ElevatorController methodsFor: 'operating' stamp: 'F C 10/4/2017 20:48:02'!
closeCabinDoor

	state closeCabinDoor.! !

!ElevatorController methodsFor: 'operating' stamp: 'F C 10/8/2017 23:53:47'!
closeCabinDoorWhenIdle! !

!ElevatorController methodsFor: 'operating' stamp: 'F C 10/4/2017 20:55:06'!
closeCabinDoorWhenWorking
	
	cabin closeDoor.! !

!ElevatorController methodsFor: 'operating' stamp: 'F C 10/9/2017 00:12:33'!
openCabinDoor
	
	state openCabinDoor.! !

!ElevatorController methodsFor: 'operating' stamp: 'F C 10/8/2017 23:57:49'!
openCabinDoorWhenIdle! !

!ElevatorController methodsFor: 'operating' stamp: 'F C 10/9/2017 00:01:28'!
openCabinDoorWhenWorking

	cabin openDoor.! !


!ElevatorController methodsFor: 'initialize' stamp: 'F C 10/9/2017 00:08:24'!
initialize

	super initialize.
	state _ IdleControllerState for: self.
	floorsToGo _ OrderedCollection new.
	cabin _ Cabin new.
	currentFloor := 0.! !
