Class {
	#name : #MAFieldTestObj,
	#superclass : #Object,
	#instVars : [
		'value',
		'name',
		'label',
		'type'
	],
	#category : #'MAMongo-AggregationFramework-Tests'
}

{ #category : #'instance creation' }
MAFieldTestObj class >> fromField: anVottunField [
	| instance |
	instance := self new.
	instance class allInstVarNames do:[ :k |
		(anVottunField includesKey:k) ifTrue:[ instance instVarNamed:k put:(anVottunField at:k) ] ].
			
	^ instance 
]

{ #category : #accessing }
MAFieldTestObj >> label [
	^ label
]

{ #category : #accessing }
MAFieldTestObj >> label: anObject [
	label := anObject
]

{ #category : #accessing }
MAFieldTestObj >> name [
	^ name
]

{ #category : #accessing }
MAFieldTestObj >> name: anObject [
	name := anObject
]

{ #category : #accessing }
MAFieldTestObj >> type [
	^ type
]

{ #category : #accessing }
MAFieldTestObj >> type: anObject [
	type := anObject
]

{ #category : #accessing }
MAFieldTestObj >> value [
	^ value
]

{ #category : #accessing }
MAFieldTestObj >> value: anObject [
	value := anObject
]
