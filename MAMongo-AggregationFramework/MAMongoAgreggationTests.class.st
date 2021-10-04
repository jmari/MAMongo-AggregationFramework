Class {
	#name : #MAMongoAgreggationTests,
	#superclass : #TestCase,
	#instVars : [
		'collection',
		'jsonStream',
		'activitiesCollection',
		'repository'
	],
	#category : #'MAMongo-AggregationFramework-Tests'
}

{ #category : #initialization }
MAMongoAgreggationTests >> database [ 
	^ 'MAMongoAggregation-Test'

	

]

{ #category : #initialization }
MAMongoAgreggationTests >> host [ 
	^ 'localhost'

	

]

{ #category : #initialization }
MAMongoAgreggationTests >> jsonFile [ 
	| working |
	working := FileSystem disk workingDirectory.
	^ working / 'pharo-local' / 'iceberg' / 'jmari' / 'MAMongo-AggregationFramework' / 'activities.json' 
	

]

{ #category : #initialization }
MAMongoAgreggationTests >> setUp [

	repository := VOMongoRepository host:self host database:self database.
	SCObjectsCache instance flush.
	jsonStream := self jsonFile asFileReference readStream. 
	activitiesCollection := self superComplexJsonStructure.
	activitiesCollection do:[ :anActivity | repository save: anActivity ].
	

]

{ #category : #tests }
MAMongoAgreggationTests >> superComplexJsonStructure [
	^ SCMaterializer materializeFrom: jsonStream
]

{ #category : #initialization }
MAMongoAgreggationTests >> tearDown [
	repository removeAll: MAActivityTestObj.
	repository reset.
	repository dropDatabase.

	

]

{ #category : #tests }
MAMongoAgreggationTests >> testArrayToObject [
	| result aggregator |
	aggregator := MAMongoAggregation new.
	aggregator 
	database:self database;
	collection: #MAFieldTestObj;
	project:{
		'field_set'->{
			'$arrayToObject'->{
				'$map'->{
					'input'->'$field_set'.
					'in'->{
						'k'->{'$concat'->{'field_'. '$$this.name'}}asSCJsonObject.
						'v'->{'$max'->'$$this.value'} asSCJsonObject 
					}asSCJsonObject 
				} asSCJsonObject 
			} asSCJsonObject 
		} asSCJsonObject 
	} asSCJsonObject .
	result:= aggregator execute.

	self assert:  ( result allSatisfy:[ :activity | activity allSatisfy:[:f | f value isArray not ]])

	
]

{ #category : #tests }
MAMongoAgreggationTests >> testError [
	| aggregator limit|
	aggregator := MAMongoAggregation new.
	limit := 10.
	aggregator 
	database:self database;
	collection: #MAFieldTestObj;
	match: { 
		'workflow'->'00 Descarga FORM'.
		'product_step'->1.
		'$and'-> {  
			{'field_set'->
				{'$elemMatch'->{
					'name'->'Cliente'. 				
					'value'-> 'Alcudia Park'.
					} asSCJsonObject.
				} asSCJsonObject.
			} asSCJsonObject.
			
			{'field_set'->
				{'$eleatch'->{
					'name'->'FechaHora'. 				
					'value'->{'$gt' ->((Date today - 90 days) asDate yyyymmdd)} asDictionary 
					} asSCJsonObject.
				} asSCJsonObject. 
			} asSCJsonObject.
		} "and is an array"
	} asSCJsonObject;
	sort: { 
		'in_batch_id'->1.
	 } asSCJsonObject;
	limit: limit.
	self should: [aggregator execute] raise: Error. 

]

{ #category : #tests }
MAMongoAgreggationTests >> testGroup [
	| result aggregator |
	aggregator := MAMongoAggregation new.
	aggregator 
	database:self database;
	collection: #MAFieldTestObj;
	limit:10000;
	match:{
		'workflow'->'00 Descarga FORM'.
		'product_step'->1.
	} asSCJsonObject;
	project:{
		'workflow'->1.
		'product_step'->1.
		'field_set'->{
			'$arrayToObject'->{
				'$map'->{
					'input'->'$field_set'.
					'in'->{
						'k'->{'$concat'->{'field_'. '$$this.name'}}asSCJsonObject.
						'v'->{'$max'->'$$this.value'} asSCJsonObject 
					}asSCJsonObject 
				} asSCJsonObject 
			} asSCJsonObject 
		} asSCJsonObject 
	} asSCJsonObject;	
	project: {
		'cliente'->'$field_set.field_cliente'.  
		'neto'->'$field_set.field_Neto_[kg]'
	} asSCJsonObject;
	group:{
		'_id'->'$Cliente'.
		'peso_total'->({'$sum'->'$neto'} asSCJsonObject )
	} asSCJsonObject.
	result:= aggregator execute.

	self assert:  ( result allSatisfy:[ :activity | activity peso_total isNumber])

	
]

{ #category : #tests }
MAMongoAgreggationTests >> testLimit [
	| result aggregator limit field |
	aggregator := MAMongoAggregation new.
	limit := 10.
	aggregator 
	database:self database;
	collection: #MAFieldTestObj;
	match: { 
		'workflow'->'00 Descarga FORM'.
		'product_step'->1.
		'$and'-> {  
			{'field_set'->
				{'$elemMatch'->{
					'name'->'Cliente'. 				
					'value'-> 'Alcudia Park'.
					} asSCJsonObject.
				} asSCJsonObject.
			} asSCJsonObject.
			
			{'field_set'->
				{'$elemMatch'->{
					'name'->'FechaHora'. 				
					'value'->{'$gt' ->((Date today - 90 days) asDate yyyymmdd)} asDictionary 
					} asSCJsonObject.
				} asSCJsonObject. 
			} asSCJsonObject.
		} "and is an array"
	} asSCJsonObject;
		limit: limit.
	result := aggregator execute.
	self assert:  ( result allSatisfy:[ :activity |  
		field:= activity field_set selectFirst:[:f| f name = 'Cliente' ]. 
		field value first	= 'Alcudia Park' ]).
	self assert: result size equals: limit 
]

{ #category : #tests }
MAMongoAgreggationTests >> testMatch [
	| result aggregator field |
	aggregator := MAMongoAggregation new.
	aggregator 
	database:self database;
	collection: #MAFieldTestObj;
	match: { 
		'workflow'->'00 Descarga FORM'.
		'product_step'->1.
		'$and'-> {  
			{'field_set'->
				{'$elemMatch'->{
					'name'->'Cliente'. 				
					'value'-> 'Alcudia Park'.
					} asSCJsonObject.
				} asSCJsonObject.
			} asSCJsonObject.
			
			{'field_set'->
				{'$elemMatch'->{
					'name'->'FechaHora'. 				
					'value'->{'$gt' ->((Date today - 90 days) asDate yyyymmdd)} asDictionary 
					} asSCJsonObject.
				} asSCJsonObject. 
			} asSCJsonObject.
		} "and is an array"
	} asSCJsonObject.

	result := aggregator execute.
	self assert:  ( result allSatisfy:[ :activity |  
		field:= activity field_set selectFirst:[:f| f name = 'Cliente' ]. 
		field value first	= 'Alcudia Park' ]).
]

{ #category : #tests }
MAMongoAgreggationTests >> testProject [
	| result aggregator limit|
	aggregator := MAMongoAggregation new.
	limit := 10.
	aggregator 
	database:self database;
	collection: #MAFieldTestObj;
	match: { 
		'workflow'->'00 Descarga FORM'.
		'product_step'->1.
		'$and'-> {  
			{'field_set'->
				{'$elemMatch'->{
					'name'->'Cliente'. 				
					'value'-> 'Alcudia Park'.
					} asSCJsonObject.
				} asSCJsonObject.
			} asSCJsonObject.
			
			{'field_set'->
				{'$elemMatch'->{
					'name'->'FechaHora'. 				
					'value'->{'$gt' ->((Date today - 90 days) asDate yyyymmdd)} asDictionary 
					} asSCJsonObject.
				} asSCJsonObject. 
			} asSCJsonObject.
		} "and is an array"
	} asSCJsonObject;
	project: {
		'field_keys'->'$field_set.name'.
		'field_values'->'$field_set.value'.
	} asSCJsonObject.	
	result := aggregator execute.
	self assert:  ( result allSatisfy:[ :activity | activity field_values anySatisfy:[:value | value first  = 'Alcudia Park' ]]).
	
]

{ #category : #tests }
MAMongoAgreggationTests >> testSort [
	| result aggregator limit|
	aggregator := MAMongoAggregation new.
	limit := 10.
	aggregator 
	database:self database;
	collection: #MAFieldTestObj;
	match: { 
		'workflow'->'00 Descarga FORM'.
		'product_step'->1.
		'$and'-> {  
			{'field_set'->
				{'$elemMatch'->{
					'name'->'Cliente'. 				
					'value'-> 'Alcudia Park'.
					} asSCJsonObject.
				} asSCJsonObject.
			} asSCJsonObject.
			
			{'field_set'->
				{'$elemMatch'->{
					'name'->'FechaHora'. 				
					'value'->{'$gt' ->((Date today - 90 days) asDate yyyymmdd)} asDictionary 
					} asSCJsonObject.
				} asSCJsonObject. 
			} asSCJsonObject.
		} "and is an array"
	} asSCJsonObject;
	sort: { 
		'in_batch_id'->1.
	 } asSCJsonObject;
	limit: limit.
	result := aggregator execute.
	self assert:  ( result isSortedBy:[:a :b | a in_batch_id < b in_batch_id ]).
	self assert: result size equals: limit 
]

{ #category : #tests }
MAMongoAgreggationTests >> testUnwind [
	| result aggregator |
	aggregator := MAMongoAggregation new.
	aggregator 
	database:self database;
	collection: #MAFieldTestObj;
	match: { 
		'workflow'->'00 Descarga FORM'.
		'product_step'->1.
		'$and'-> {  
			{'field_set'->
				{'$elemMatch'->{
					'name'->'Cliente'. 				
					'value'-> 'Alcudia Park'.
					} asSCJsonObject.
				} asSCJsonObject.
			} asSCJsonObject.
			
			{'field_set'->
				{'$elemMatch'->{
					'name'->'FechaHora'. 				
					'value'->{'$gt' ->((Date today - 90 days) asDate yyyymmdd)} asDictionary 
					} asSCJsonObject.
				} asSCJsonObject. 
			} asSCJsonObject.
		} "and is an array"
	} asSCJsonObject;
	limit:10000;
	unwind: '$field_set';
	project:{
		'field_key'->'$field_set.name'.
		'field_value'->'$field_set.value'.
	} asSCJsonObject;
	match:{'field_key'->'Neto_[kg]'} asSCJsonObject;
	unwind:'$field_value'.
	
	result := aggregator execute.

	self assert:  ( result allSatisfy:[ :activity | activity field_value isNumber])
]
