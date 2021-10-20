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
	collection: #MAActivityTestObj;
	project:{
		'field_set'->{
			'$arrayToObject'->{
				'$map'->{
					'input'->'$field_set'.
					'in'->{
						'k'->{'$concat'->{'field_'. '$$this.name'}}asDictionary.
						'v'->{'$max'->'$$this.value'} asDictionary 
					}asDictionary 
				} asDictionary 
			} asDictionary 
		} asDictionary 
	} asDictionary .
	result:= aggregator execute.

	self assert:  ( result allSatisfy:[ :activity | activity allSatisfy:[:f | f value isArray not ]])

	
]

{ #category : #tests }
MAMongoAgreggationTests >> testCache [
	| result aggregator time1 time2 |
	aggregator := MAMongoAggregation new.
	aggregator 
	database:self database;
	cacheForPowerOfTenSeconds: 2 "100 seconds";
	collection: #MAActivityTestObj;
	match: { 
		'workflow'->'00 Descarga FORM'.
		'product_step'->1.
		'$and'-> {  
			{'field_set'->
				{'$elemMatch'->{
					'name'->'Cliente'. 				
					'value'-> 'Alcudia Park'.
					} asDictionary.
				} asDictionary.
			} asDictionary.
			
			{'field_set'->
				{'$elemMatch'->{
					'name'->'FechaHora'. 				
					'value'->{'$gt' ->((Date today - 10000 days) asDate yyyymmdd)} asDictionary 
					} asDictionary.
				} asDictionary. 
			} asDictionary.
		} "and is an array"
	} asDictionary;
	limit:10000;
	unwind: '$field_set';
	project:{
		'field_key'->'$field_set.name'.
		'field_value'->'$field_set.value'.
	} asDictionary;
	match:{'field_key'->'Neto_[kg]'} asDictionary;
	unwind:'$field_value'.
	aggregator removeOldTmpFiles.


	time1:=[result := aggregator execute] timeToRun.
	time2:=[result := aggregator execute] timeToRun.
	time1 inspect.time2 inspect.
	self assert: (time1/100) > time2.
	self assert:  ( result allSatisfy:[ :activity | activity field_value isNumber])
]

{ #category : #tests }
MAMongoAgreggationTests >> testCacheOneSecond [
	| result aggregator time1 time2 |
	aggregator := MAMongoAggregation new.
	aggregator 
	database:self database;
	cacheForPowerOfTenSeconds: 0 "1 second cache";
	collection: #MAActivityTestObj;
	match: { 
		'workflow'->'00 Descarga FORM'.
		'product_step'->1.
		'$and'-> {  
			{'field_set'->
				{'$elemMatch'->{
					'name'->'Cliente'. 				
					'value'-> 'Alcudia Park'.
					} asDictionary.
				} asDictionary.
			} asDictionary.
			
			{'field_set'->
				{'$elemMatch'->{
					'name'->'FechaHora'. 				
					'value'->{'$gt' ->((Date today - 10000 days) asDate yyyymmdd)} asDictionary 
					} asDictionary.
				} asDictionary. 
			} asDictionary.
		} "and is an array"
	} asDictionary;
	limit:10000;
	unwind: '$field_set';
	project:{
		'field_key'->'$field_set.name'.
		'field_value'->'$field_set.value'.
	} asDictionary;
	match:{'field_key'->'Neto_[kg]'} asDictionary;
	unwind:'$field_value'.
	aggregator removeOldTmpFiles.


	time1:=[result := aggregator execute] timeToRun.
	Delay forSeconds: 3.
	time2:=[result := aggregator execute] timeToRun.
	time1 inspect.time2 inspect.
	self deny: (time1/100) > time2.
	self assert:  ( result allSatisfy:[ :activity | activity field_value isNumber])
]

{ #category : #tests }
MAMongoAgreggationTests >> testError [
	| aggregator limit|
	aggregator := MAMongoAggregation new.
	limit := 10.
	aggregator 
	database:self database;
	collection: #MAActivityTestObj;
	match: { 
		'workflow'->'00 Descarga FORM'.
		'product_step'->1.
		'$and'-> {  
			{'field_set'->
				{'$elemMatch'->{
					'name'->'Cliente'. 				
					'value'-> 'Alcudia Park'.
					} asDictionary.
				} asDictionary.
			} asDictionary.
			
			{'field_set'->
				{'$eleatch'->{
					'name'->'FechaHora'. 				
					'value'->{'$gt' ->((Date today - 10000 days) asDate yyyymmdd)} asDictionary 
					} asDictionary.
				} asDictionary. 
			} asDictionary.
		} "and is an array"
	} asDictionary;
	sort: { 
		'in_batch_id'->1.
	 } asDictionary;
	limit: limit.
	self should: [aggregator execute] raise: Error. 

]

{ #category : #tests }
MAMongoAgreggationTests >> testGroup [
	| result aggregator |
	aggregator := MAMongoAggregation new.
	aggregator 
	database:self database;
	collection: #MAActivityTestObj;
	limit:10000;
	match:{
		'workflow'->'00 Descarga FORM'.
		'product_step'->1.
	} asDictionary;
	project:{
		'workflow'->1.
		'product_step'->1.
		'field_set'->{
			'$arrayToObject'->{
				'$map'->{
					'input'->'$field_set'.
					'in'->{
						'k'->{'$concat'->{'field_'. '$$this.name'}}asDictionary.
						'v'->{'$max'->'$$this.value'} asDictionary 
					}asDictionary 
				} asDictionary 
			} asDictionary 
		} asDictionary 
	} asDictionary;	
	project: {
		'cliente'->'$field_set.field_cliente'.  
		'neto'->'$field_set.field_Neto_[kg]'
	} asDictionary;
	group:{
		'_id'->'$Cliente'.
		'peso_total'->({'$sum'->'$neto'} asDictionary )
	} asDictionary.
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
	collection: #MAActivityTestObj;
	match: { 
		'workflow'->'00 Descarga FORM'.
		'product_step'->1.
		'$and'-> {  
			{'field_set'->
				{'$elemMatch'->{
					'name'->'Cliente'. 				
					'value'-> 'Alcudia Park'.
					} asDictionary.
				} asDictionary.
			} asDictionary.
			
			{'field_set'->
				{'$elemMatch'->{
					'name'->'FechaHora'. 				
					'value'->{'$gt' ->((Date today - 10000 days) asDate yyyymmdd)} asDictionary 
					} asDictionary.
				} asDictionary. 
			} asDictionary.
		} "and is an array"
	} asDictionary;
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
	collection: #MAActivityTestObj;
	match: { 
		'workflow'->'00 Descarga FORM'.
		'product_step'->1.
		'$and'-> {  
			{'field_set'->
				{'$elemMatch'->{
					'name'->'Cliente'. 				
					'value'-> 'Alcudia Park'.
					} asDictionary.
				} asDictionary.
			} asDictionary.
			
			{'field_set'->
				{'$elemMatch'->{
					'name'->'FechaHora'. 				
					'value'->{'$gt' ->((Date today - 10000 days) asDate yyyymmdd)} asDictionary 
					} asDictionary.
				} asDictionary. 
			} asDictionary.
		} "and is an array"
	} asDictionary.

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
	collection: #MAActivityTestObj;
	match: { 
		'workflow'->'00 Descarga FORM'.
		'product_step'->1.
		'$and'-> {  
			{'field_set'->
				{'$elemMatch'->{
					'name'->'Cliente'. 				
					'value'-> 'Alcudia Park'.
					} asDictionary.
				} asDictionary.
			} asDictionary.
			
			{'field_set'->
				{'$elemMatch'->{
					'name'->'FechaHora'. 				
					'value'->{'$gt' ->((Date today - 10000 days) asDate yyyymmdd)} asDictionary 
					} asDictionary.
				} asDictionary. 
			} asDictionary.
		} "and is an array"
	} asDictionary;
	project: {
		'field_keys'->'$field_set.name'.
		'field_values'->'$field_set.value'.
	} asDictionary.	
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
	collection: #MAActivityTestObj;
	match: { 
		'workflow'->'00 Descarga FORM'.
		'product_step'->1.
		'$and'-> {  
			{'field_set'->
				{'$elemMatch'->{
					'name'->'Cliente'. 				
					'value'-> 'Alcudia Park'.
					} asDictionary.
				} asDictionary.
			} asDictionary.
			
			{'field_set'->
				{'$elemMatch'->{
					'name'->'FechaHora'. 				
					'value'->{'$gt' ->((Date today - 10000 days) asDate yyyymmdd)} asDictionary 
					} asDictionary.
				} asDictionary. 
			} asDictionary.
		} "and is an array"
	} asDictionary;
	sort: { 
		'in_batch_id'->1.
	 } asDictionary;
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
	collection: #MAActivityTestObj;
	match: { 
		'workflow'->'00 Descarga FORM'.
		'product_step'->1.
		'$and'-> {  
			{'field_set'->
				{'$elemMatch'->{
					'name'->'Cliente'. 				
					'value'-> 'Alcudia Park'.
					} asDictionary.
				} asDictionary.
			} asDictionary.
			
			{'field_set'->
				{'$elemMatch'->{
					'name'->'FechaHora'. 				
					'value'->{'$gt' ->((Date today - 10000 days) asDate yyyymmdd)} asDictionary 
					} asDictionary.
				} asDictionary. 
			} asDictionary.
		} "and is an array"
	} asDictionary;
	limit:10000;
	unwind: '$field_set';
	project:{
		'field_key'->'$field_set.name'.
		'field_value'->'$field_set.value'.
	} asDictionary;
	match:{'field_key'->'Neto_[kg]'} asDictionary;
	unwind:'$field_value'.
	
	result := aggregator execute.

	self assert:  ( result allSatisfy:[ :activity | activity field_value isNumber])
]
