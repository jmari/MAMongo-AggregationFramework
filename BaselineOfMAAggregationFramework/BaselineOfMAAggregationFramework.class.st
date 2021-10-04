Class {
	#name : #BaselineOfMAAggregationFramework,
	#superclass : #BaselineOf,
	#category : #BaselineOfMAAggregationFramework
}

{ #category : #baselines }
BaselineOfMAAggregationFramework >> baseline: spec [
	<baseline>
	spec for: #common do: [ 
		self json: spec.
		spec
		package: 'MAMongo-AggregationFramework' with:[ spec requires: #('SCouchDB' 'Voyage') ].
		self groups: spec.
	]

]

{ #category : #'as yet unclassified' }
BaselineOfMAAggregationFramework >> groups: spec [
	spec 
		group: 'default' with: #('MAMongo-AggregationFramework')
]

{ #category : #'instance creation' }
BaselineOfMAAggregationFramework >> json: spec [
	spec 
		baseline: 'SCouchDB' with: [ spec repository: 'github://jmari/SCouchDB/repository' ];
		import: 'json'
]
