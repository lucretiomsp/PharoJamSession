"
I'm a connector use with widget to link to widgets together by create a line between them.
I must be an input or output connector before been link to another connector 
"
Class {
	#name : 'JamConnector',
	#superclass : 'BlElement',
	#instVars : [
		'isOutputConnect',
		'line',
		'connectTo'
	],
	#category : 'PharoJamSession-UIElement',
	#package : 'PharoJamSession',
	#tag : 'UIElement'
}

{ #category : 'calculating' }
JamConnector >> calcMiddleWith: anInteger and: anotherInteger [
	anInteger < anotherInteger
		ifTrue: [ ^ anInteger + (anotherInteger - anInteger / 2) ]
		ifFalse: [ ^ anotherInteger + (anInteger - anotherInteger / 2) ]
	
]

{ #category : 'initialization' }
JamConnector >> checkBeforeDisconnect [

	self connectTo ifNotNil: [ self disconnect ]
]

{ #category : 'connecting' }
JamConnector >> connect: aConnector [

	self checkBeforeDisconnect.
	aConnector checkBeforeDisconnect.
	self connectTo: aConnector parent.
	aConnector connectTo: self parent.
]

{ #category : 'accessing' }
JamConnector >> connectTo [
	^ connectTo
]

{ #category : 'accessing' }
JamConnector >> connectTo: aWidget [

	connectTo := aWidget.
	aWidget ifNil: [
		"parent notifyDisconnection."
		^ self ].
	"parent notifyConnection"
]

{ #category : 'accessing' }
JamConnector >> connectorConnected [
	"Get the correct connector base on if this connector is an output or input"

	connectTo ifNil: [ ^ self ].
	self isOutputConnect
		ifTrue: [ ^ connectTo inputConnect ]
		ifFalse: [ ^ connectTo outputConnect ]
]

{ #category : 'accessing' }
JamConnector >> connectorWhichHaveLine: aConnector [
	aConnector line ifNil: [ ^ self ].
	aConnector line geometry class = BlBezierCurveGeometry
		ifTrue: [ ^ aConnector ]
		ifFalse: [ ^ self ]
]

{ #category : 'connecting' }
JamConnector >> disconnect [

	| aConnector |
	aConnector := self connectorConnected.
	(self connectorWhichHaveLine: aConnector) line: nil.
	self connectTo: nil.
	aConnector connectTo: nil
]

{ #category : 'initialization' }
JamConnector >> initialize [

	super initialize.
	isOutputConnect := false.
	self zIndex: 3.
	self border: (BlBorder paint: Color black width: 2).
	self layout: BlFrameLayout new.
	self geometry: BlCircleGeometry new.
	self border: (BlBorder paint: Color black width: 1).
	self initializeDrag
]

{ #category : 'initialization' }
JamConnector >> initializeDrag [

	self addEventHandlerOn: BlDragStartEvent do: [ :evt |
		evt consumed: true.
		self checkBeforeDisconnect. ].
	self addEventHandlerOn: BlDragEvent do: [ :evt |
		evt consumed: true.
		parent drawALineAt: evt position atConnector: self ].
	self
		addEventHandlerOn: BlDragEndEvent
		do: [ :evt | evt consumed: true ]
]

{ #category : 'accessing' }
JamConnector >> isInputConnect [

	^ false
]

{ #category : 'accessing' }
JamConnector >> isOutputConnect [

	^ isOutputConnect
]

{ #category : 'accessing' }
JamConnector >> isOutputConnect: aBoolean [

	isOutputConnect := aBoolean
]

{ #category : 'initialization' }
JamConnector >> line [
	^line
]

{ #category : 'initialization' }
JamConnector >> line: aPolyLine [

	line := aPolyLine.
]

{ #category : 'initialization' }
JamConnector >> resetInit [

	line := nil.
	self checkBeforeDisconnect
]

{ #category : 'connecting' }
JamConnector >> updateLine [
	"When the widget connected or the widget parent position move and there is another widget connected, we edit our visual connexion line to put it visually connect to the correct widget"

	| points first last midX sizeBound |
	sizeBound := self extent / 2.

	connectTo ifNil: [ ^ self ].
	"connectedWithLine := self connectorWhichHaveLine:
		                     self connectorConnected."
	points := OrderedCollection new.
	first := self positionInSpace.
	last := self connectorConnected positionInSpace.

	midX := self
		        calcMiddleWith: first x + sizeBound x
		        and: last x + sizeBound x.
	points add: first x + sizeBound x @ (first y + sizeBound y).
	points add: midX @ (first y + sizeBound y).
	points add: midX @ (last y + sizeBound y).
	points add: last x + sizeBound x @ (last y + sizeBound y).
	line geometry: (BlBezierCurveGeometry controlPoints: points)
]
