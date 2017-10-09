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

!Cabin methodsFor: 'as yet unclassified' stamp: 'F C 10/4/2017 20:58:18'!
closeDoor

	state closeDoor.! !

!Cabin methodsFor: 'as yet unclassified' stamp: 'F C 10/4/2017 22:18:37'!
closeDoorWhenStopped

	door close.! !

!Cabin methodsFor: 'as yet unclassified' stamp: 'F C 10/4/2017 23:05:58'!
closeDoorWhenWaitingForPeople

	door close.! !

!Cabin methodsFor: 'as yet unclassified' stamp: 'F C 10/4/2017 20:03:48'!
doorClosed
	
	door closed.
	state := MovingCabinState for: self.! !

!Cabin methodsFor: 'as yet unclassified' stamp: 'F C 10/4/2017 23:00:51'!
doorOpenedWithFloorsToGo

	door opened.
	state := WaitingForPeopleCabinState for: self.! !

!Cabin methodsFor: 'as yet unclassified' stamp: 'F C 10/4/2017 23:00:59'!
doorOpenedWithNoFloorsToGo
	
	door opened.
	state := StoppedCabinState for: self.! !

!Cabin methodsFor: 'as yet unclassified' stamp: 'F C 10/4/2017 20:02:35'!
initialize
	
	super initialize.
	state _ StoppedCabinState for: self.
	door _ Door new.! !

!Cabin methodsFor: 'as yet unclassified' stamp: 'F C 10/3/2017 23:36:17'!
isDoorClosed
	
	^door isClosed.! !

!Cabin methodsFor: 'as yet unclassified' stamp: 'F C 10/3/2017 23:31:30'!
isDoorClosing
	
	^door isClosing.! !

!Cabin methodsFor: 'as yet unclassified' stamp: 'F C 10/3/2017 23:20:08'!
isDoorOpened

	^door isOpened.! !

!Cabin methodsFor: 'as yet unclassified' stamp: 'F C 10/3/2017 23:30:27'!
isDoorOpening

	^door isOpening.! !

!Cabin methodsFor: 'as yet unclassified' stamp: 'F C 10/3/2017 23:17:11'!
isMoving

	^state isMoving.! !

!Cabin methodsFor: 'as yet unclassified' stamp: 'F C 10/4/2017 20:32:09'!
isWaitingForPeople

	^state isWaitingForPeople.! !

!Cabin methodsFor: 'as yet unclassified' stamp: 'F C 10/4/2017 20:19:52'!
openDoor

	state openDoor.! !

!Cabin methodsFor: 'as yet unclassified' stamp: 'F C 10/4/2017 23:03:18'!
openDoorWhenOnFloor

	state := StoppedCabinState for: self.
	door open.
! !

!Cabin methodsFor: 'as yet unclassified' stamp: 'F C 10/4/2017 20:07:36'!
openDoorWhenStopped
	
	door open.! !

!Cabin methodsFor: 'as yet unclassified' stamp: 'F C 10/4/2017 23:05:48'!
waitForPeopleTimedOut

	self closeDoorWhenWaitingForPeople.! !


!classDefinition: #CabinState category: #'Elevator-Ejercicio'!
Object subclass: #CabinState
	instanceVariableNames: 'cabin'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Elevator-Ejercicio'!

!CabinState methodsFor: 'as yet unclassified' stamp: 'F C 10/4/2017 20:01:08'!
closeDoor

	self subclassResponsibility.! !

!CabinState methodsFor: 'as yet unclassified' stamp: 'F C 10/4/2017 19:54:11'!
initializeWith: aCabin

	cabin := aCabin.! !

!CabinState methodsFor: 'as yet unclassified' stamp: 'F C 10/3/2017 23:41:43'!
isMoving

	^false.! !

!CabinState methodsFor: 'as yet unclassified' stamp: 'F C 10/3/2017 23:41:49'!
isStopped

	^false.! !

!CabinState methodsFor: 'as yet unclassified' stamp: 'F C 10/4/2017 20:32:49'!
isWaitingForPeople

	^false.! !

!CabinState methodsFor: 'as yet unclassified' stamp: 'F C 10/4/2017 20:01:04'!
openDoor

	self subclassResponsibility.! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

!classDefinition: 'CabinState class' category: #'Elevator-Ejercicio'!
CabinState class
	instanceVariableNames: ''!

!CabinState class methodsFor: 'as yet unclassified' stamp: 'F C 10/4/2017 19:59:03'!
for: aCabin

	^self new initializeWith: aCabin.! !


!classDefinition: #MovingCabinState category: #'Elevator-Ejercicio'!
CabinState subclass: #MovingCabinState
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Elevator-Ejercicio'!

!MovingCabinState methodsFor: 'as yet unclassified' stamp: 'F C 10/4/2017 22:50:29'!
closeDoor
! !

!MovingCabinState methodsFor: 'as yet unclassified' stamp: 'F C 10/3/2017 23:41:55'!
isMoving

	^true.! !

!MovingCabinState methodsFor: 'as yet unclassified' stamp: 'F C 10/4/2017 22:50:25'!
openDoor
	! !


!classDefinition: #StoppedCabinState category: #'Elevator-Ejercicio'!
CabinState subclass: #StoppedCabinState
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Elevator-Ejercicio'!

!StoppedCabinState methodsFor: 'as yet unclassified' stamp: 'F C 10/4/2017 22:17:36'!
closeDoor
	
	cabin closeDoorWhenStopped.! !

!StoppedCabinState methodsFor: 'as yet unclassified' stamp: 'F C 10/3/2017 23:42:03'!
isStopped

	^true.! !

!StoppedCabinState methodsFor: 'as yet unclassified' stamp: 'F C 10/4/2017 20:05:39'!
openDoor

	cabin openDoorWhenStopped.! !


!classDefinition: #WaitingForPeopleCabinState category: #'Elevator-Ejercicio'!
CabinState subclass: #WaitingForPeopleCabinState
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Elevator-Ejercicio'!

!WaitingForPeopleCabinState methodsFor: 'as yet unclassified' stamp: 'F C 10/4/2017 22:27:13'!
closeDoor

	cabin closeDoorWhenWaitingForPeople.! !

!WaitingForPeopleCabinState methodsFor: 'as yet unclassified' stamp: 'F C 10/4/2017 20:32:55'!
isWaitingForPeople

	^true.! !

!WaitingForPeopleCabinState methodsFor: 'as yet unclassified' stamp: 'F C 10/4/2017 22:51:13'!
openDoor

! !


!classDefinition: #ControllerState category: #'Elevator-Ejercicio'!
Object subclass: #ControllerState
	instanceVariableNames: 'controller'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Elevator-Ejercicio'!

!ControllerState methodsFor: 'as yet unclassified' stamp: 'F C 10/4/2017 20:52:59'!
initializeWith: aController

	controller := aController.! !

!ControllerState methodsFor: 'as yet unclassified' stamp: 'F C 10/3/2017 23:55:35'!
isIdle

	^false.! !

!ControllerState methodsFor: 'as yet unclassified' stamp: 'F C 10/3/2017 23:55:42'!
isWorking

	^false.! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

!classDefinition: 'ControllerState class' category: #'Elevator-Ejercicio'!
ControllerState class
	instanceVariableNames: ''!

!ControllerState class methodsFor: 'as yet unclassified' stamp: 'F C 10/4/2017 20:49:48'!
for: aController

	^self new initializeWith: aController.! !


!classDefinition: #IdleControllerState category: #'Elevator-Ejercicio'!
ControllerState subclass: #IdleControllerState
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Elevator-Ejercicio'!

!IdleControllerState methodsFor: 'as yet unclassified' stamp: 'F C 10/4/2017 23:09:12'!
closeCabinDoor
! !

!IdleControllerState methodsFor: 'as yet unclassified' stamp: 'F C 10/4/2017 21:44:28'!
doorClosed

	controller doorClosedWhenIdle.! !

!IdleControllerState methodsFor: 'as yet unclassified' stamp: 'F C 10/3/2017 23:08:52'!
isIdle
	
	^true.! !


!classDefinition: #WorkingControllerState category: #'Elevator-Ejercicio'!
ControllerState subclass: #WorkingControllerState
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Elevator-Ejercicio'!

!WorkingControllerState methodsFor: 'as yet unclassified' stamp: 'F C 10/4/2017 20:54:43'!
closeCabinDoor
	
	controller closeCabinDoorWhenWorking.! !

!WorkingControllerState methodsFor: 'as yet unclassified' stamp: 'F C 10/4/2017 21:49:59'!
doorClosed

	controller doorClosedWhenWorking.! !

!WorkingControllerState methodsFor: 'as yet unclassified' stamp: 'F C 10/3/2017 23:55:52'!
isWorking

	^true.! !


!classDefinition: #Door category: #'Elevator-Ejercicio'!
Object subclass: #Door
	instanceVariableNames: 'state'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Elevator-Ejercicio'!

!Door methodsFor: 'as yet unclassified' stamp: 'F C 10/3/2017 23:29:09'!
close

	state := state close.! !

!Door methodsFor: 'as yet unclassified' stamp: 'F C 10/4/2017 22:22:07'!
closed

	state := state closed.! !

!Door methodsFor: 'as yet unclassified' stamp: 'F C 10/4/2017 22:45:43'!
initialize

	super initialize.
	state := OpenedDoorState for: self.! !

!Door methodsFor: 'as yet unclassified' stamp: 'F C 10/3/2017 23:36:28'!
isClosed
	
	^state isClosed.
	! !

!Door methodsFor: 'as yet unclassified' stamp: 'F C 10/3/2017 23:31:41'!
isClosing

	^state isClosing.! !

!Door methodsFor: 'as yet unclassified' stamp: 'F C 10/3/2017 23:45:40'!
isOpened

	^state isOpened .! !

!Door methodsFor: 'as yet unclassified' stamp: 'F C 10/3/2017 23:30:42'!
isOpening

	^state isOpening.! !

!Door methodsFor: 'as yet unclassified' stamp: 'F C 10/3/2017 23:50:25'!
open

	state := state open.! !

!Door methodsFor: 'as yet unclassified' stamp: 'F C 10/4/2017 21:59:32'!
opened

	state := OpenedDoorState for: self.! !


!classDefinition: #DoorState category: #'Elevator-Ejercicio'!
Object subclass: #DoorState
	instanceVariableNames: 'door'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Elevator-Ejercicio'!

!DoorState methodsFor: 'as yet unclassified' stamp: 'F C 10/3/2017 23:35:35'!
close

	self subclassResponsibility.! !

!DoorState methodsFor: 'as yet unclassified' stamp: 'F C 10/4/2017 21:57:52'!
initializeWith: aDoor

	door := aDoor.! !

!DoorState methodsFor: 'as yet unclassified' stamp: 'F C 10/3/2017 23:34:22'!
isClosed

	^false.! !

!DoorState methodsFor: 'as yet unclassified' stamp: 'F C 10/3/2017 23:34:19'!
isClosing

	^false.! !

!DoorState methodsFor: 'as yet unclassified' stamp: 'F C 10/3/2017 23:34:24'!
isOpened

	^false.! !

!DoorState methodsFor: 'as yet unclassified' stamp: 'F C 10/3/2017 23:34:15'!
isOpening

	^false.! !

!DoorState methodsFor: 'as yet unclassified' stamp: 'F C 10/4/2017 00:03:24'!
open

	^self subclassResponsibility.! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

!classDefinition: 'DoorState class' category: #'Elevator-Ejercicio'!
DoorState class
	instanceVariableNames: ''!

!DoorState class methodsFor: 'as yet unclassified' stamp: 'F C 10/4/2017 21:57:40'!
for: aDoor

	^self new initializeWith: aDoor.! !


!classDefinition: #ClosedDoorState category: #'Elevator-Ejercicio'!
DoorState subclass: #ClosedDoorState
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Elevator-Ejercicio'!

!ClosedDoorState methodsFor: 'as yet unclassified' stamp: 'F C 10/4/2017 20:55:17'!
close
	
	^self.! !

!ClosedDoorState methodsFor: 'as yet unclassified' stamp: 'F C 10/4/2017 22:41:36'!
closed

	ElevatorEmergency signal: 'Sensor de puerta desincronizado'.! !

!ClosedDoorState methodsFor: 'as yet unclassified' stamp: 'F C 10/3/2017 23:34:45'!
isClosed

	^true.! !

!ClosedDoorState methodsFor: 'as yet unclassified' stamp: 'F C 10/4/2017 21:59:06'!
open

	^OpeningDoorState for: door.! !


!classDefinition: #ClosingDoorState category: #'Elevator-Ejercicio'!
DoorState subclass: #ClosingDoorState
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Elevator-Ejercicio'!

!ClosingDoorState methodsFor: 'as yet unclassified' stamp: 'F C 10/4/2017 22:19:12'!
closed

	^ClosedDoorState for: door.! !

!ClosingDoorState methodsFor: 'as yet unclassified' stamp: 'F C 10/3/2017 23:32:53'!
isClosing
	
	^true.! !

!ClosingDoorState methodsFor: 'as yet unclassified' stamp: 'F C 10/4/2017 21:59:16'!
open
	
	^OpeningDoorState for: door.! !


!classDefinition: #OpenedDoorState category: #'Elevator-Ejercicio'!
DoorState subclass: #OpenedDoorState
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Elevator-Ejercicio'!

!OpenedDoorState methodsFor: 'as yet unclassified' stamp: 'F C 10/4/2017 21:58:42'!
close

	^ClosingDoorState for: door.! !

!OpenedDoorState methodsFor: 'as yet unclassified' stamp: 'F C 10/4/2017 23:12:21'!
closed

	ElevatorEmergency signal: 'Sensor de puerta desincronizado'.! !

!OpenedDoorState methodsFor: 'as yet unclassified' stamp: 'F C 10/3/2017 23:23:36'!
isOpened

	^true.! !

!OpenedDoorState methodsFor: 'as yet unclassified' stamp: 'F C 10/4/2017 00:03:58'!
open
	
	^self.! !


!classDefinition: #OpeningDoorState category: #'Elevator-Ejercicio'!
DoorState subclass: #OpeningDoorState
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Elevator-Ejercicio'!

!OpeningDoorState methodsFor: 'as yet unclassified' stamp: 'F C 10/4/2017 23:15:12'!
close

	^self.! !

!OpeningDoorState methodsFor: 'as yet unclassified' stamp: 'F C 10/4/2017 22:42:09'!
closed
	
	ElevatorEmergency signal: 'Sensor de puerta desincronizado'.! !

!OpeningDoorState methodsFor: 'as yet unclassified' stamp: 'F C 10/3/2017 23:35:19'!
isOpening

	^true.! !

!OpeningDoorState methodsFor: 'as yet unclassified' stamp: 'F C 10/4/2017 20:24:33'!
open

	^self.! !


!classDefinition: #ElevatorController category: #'Elevator-Ejercicio'!
Object subclass: #ElevatorController
	instanceVariableNames: 'cabin state floorsToGo currentFloor'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Elevator-Ejercicio'!

!ElevatorController methodsFor: 'as yet unclassified' stamp: 'F C 10/4/2017 21:44:06'!
cabinDoorClosed

	state doorClosed.! !

!ElevatorController methodsFor: 'as yet unclassified' stamp: 'F C 10/4/2017 20:51:37'!
cabinDoorOpened

	floorsToGo isEmpty 
		ifTrue: [ 
			state := IdleControllerState for: self.
			cabin doorOpenedWithNoFloorsToGo.
		]
		ifFalse: [
			cabin doorOpenedWithFloorsToGo.
		].
	
! !

!ElevatorController methodsFor: 'as yet unclassified' stamp: 'F C 10/3/2017 23:52:42'!
cabinFloorNumber
	
	^currentFloor.! !

!ElevatorController methodsFor: 'as yet unclassified' stamp: 'F C 10/4/2017 22:39:42'!
cabinOnFloor: floor

	floor = (currentFloor + 1) ifFalse: [ ElevatorEmergency signal: 'Sensor de cabina desincronizado'].

	currentFloor := floor.
	floorsToGo remove: floor ifAbsent: [ ]. "dudoso que no haga nada. Si bien es porque floor puede ser uno por el que paso pero el cual nadie pidio ir"
	cabin openDoorWhenOnFloor.! !

!ElevatorController methodsFor: 'as yet unclassified' stamp: 'F C 10/4/2017 20:48:02'!
closeCabinDoor

	state closeCabinDoor.! !

!ElevatorController methodsFor: 'as yet unclassified' stamp: 'F C 10/4/2017 20:55:06'!
closeCabinDoorWhenWorking
	
	cabin closeDoor.! !

!ElevatorController methodsFor: 'as yet unclassified' stamp: 'F C 10/4/2017 21:45:08'!
doorClosedWhenIdle

	ElevatorEmergency signal: 'Sensor de puerta desincronizado'.! !

!ElevatorController methodsFor: 'as yet unclassified' stamp: 'F C 10/4/2017 21:50:25'!
doorClosedWhenWorking

	cabin doorClosed.! !

!ElevatorController methodsFor: 'as yet unclassified' stamp: 'F C 10/4/2017 20:51:47'!
goUpPushedFromFloor: floor

	state _ WorkingControllerState for: self.
	cabin closeDoor.
	floorsToGo add: floor.! !

!ElevatorController methodsFor: 'as yet unclassified' stamp: 'F C 10/4/2017 20:53:52'!
initialize
	super initialize.
	state _ IdleControllerState for: self.
	floorsToGo _ OrderedCollection new.
	cabin _ Cabin new.
	currentFloor := 0.! !

!ElevatorController methodsFor: 'as yet unclassified' stamp: 'F C 10/3/2017 23:36:07'!
isCabinDoorClosed
	
	^cabin isDoorClosed.! !

!ElevatorController methodsFor: 'as yet unclassified' stamp: 'F C 10/3/2017 23:31:18'!
isCabinDoorClosing

	^cabin isDoorClosing.! !

!ElevatorController methodsFor: 'as yet unclassified' stamp: 'F C 10/3/2017 23:19:05'!
isCabinDoorOpened

	^cabin isDoorOpened.! !

!ElevatorController methodsFor: 'as yet unclassified' stamp: 'F C 10/3/2017 23:30:14'!
isCabinDoorOpening

	^cabin isDoorOpening.! !

!ElevatorController methodsFor: 'as yet unclassified' stamp: 'F C 10/3/2017 23:16:32'!
isCabinMoving
	
	^cabin isMoving.! !

!ElevatorController methodsFor: 'as yet unclassified' stamp: 'F C 10/3/2017 23:15:15'!
isCabinStopped
	
	^self isCabinMoving not.! !

!ElevatorController methodsFor: 'as yet unclassified' stamp: 'F C 10/4/2017 20:32:16'!
isCabinWaitingForPeople

	^cabin isWaitingForPeople.! !

!ElevatorController methodsFor: 'as yet unclassified' stamp: 'F C 10/3/2017 23:07:38'!
isIdle

	^state isIdle.! !

!ElevatorController methodsFor: 'as yet unclassified' stamp: 'F C 10/3/2017 23:14:04'!
isWorking

	^self isIdle not.! !

!ElevatorController methodsFor: 'as yet unclassified' stamp: 'F C 10/3/2017 23:56:44'!
openCabinDoor
	
	cabin openDoor.! !

!ElevatorController methodsFor: 'as yet unclassified' stamp: 'F C 10/4/2017 20:42:47'!
waitForPeopleTimedOut

	cabin waitForPeopleTimedOut.! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

!classDefinition: 'ElevatorController class' category: #'Elevator-Ejercicio'!
ElevatorController class
	instanceVariableNames: ''!

!ElevatorController class methodsFor: 'as yet unclassified' stamp: 'F C 10/4/2017 21:03:06'!
desynchronizedSensorErrorDescription
	
	^'Sensor de cabina desincronizado'.! !
