Class {
	#name : #MAMongoAggregation,
	#superclass : #Object,
	#instVars : [
		'query',
		'database',
		'collection',
		'outFilename',
		'pathToMongoExecutable',
		'limit',
		'expressionCounter',
		'materialize',
		'cacheTime'
	],
	#category : #'MAMongo-AggregationFramework-Core'
}

{ #category : #stages }
MAMongoAggregation >> addFields: anExpression [
	self query add: (Array with:(self nextStage) with:'{$addFields:', (self serializer serialize: anExpression),'}')
	
]

{ #category : #stages }
MAMongoAggregation >> bucket: anExpression [
	self query add:(Array with:(self nextStage) with:'{$bucket:', (self serializer serialize: anExpression),'}')
	
]

{ #category : #stages }
MAMongoAggregation >> bucketAuto: anExpression [
	self query add:(Array with:(self nextStage) with:'{$bucketAuto:', (self serializer serialize: anExpression),'}')
	
]

{ #category : #execution }
MAMongoAggregation >> buildCommand [

	| queryString orderedQuery |
	queryString := WriteStream on: String new.
	orderedQuery := (self query sort:[ :a :b | a first < b first ]) collect:[:e | e last ].
	queryString 
		nextPutAll:'[';
		nextPutAll:	(',' join: orderedQuery);
		nextPutAll:']'.
		

	^ (self pathToMongoExecutable ,'mongo --eval ''' ,
		'DBQuery.shellBatchSize = ', limit asString,';', 
		'db.getCollection("', self collection  ,'")', '.aggregate(',
		queryString contents , ');'' ',
		self database,
		' 1>' , self outFilename)
	


]

{ #category : #execution }
MAMongoAggregation >> buildErrorMessage [

	^ self outFilename asFileReference readStream contents.

		

]

{ #category : #'as yet unclassified' }
MAMongoAggregation >> cacheForPowerOfTenSeconds: anInteger [
	cacheTime :=  anInteger
]

{ #category : #'as yet unclassified' }
MAMongoAggregation >> cacheTime [
	"as duration"
	^ (10 ** cacheTime) asDuration
]

{ #category : #execution }
MAMongoAggregation >> cleanMongoSpecialTags:line [
	"cleans ObjectId and NumberLong"
	| newLine |

	newLine := self cleanMongoSpecialTags: line tag:  'ObjectId'.
	newLine := self cleanMongoSpecialTags: newLine tag:  'NumberLong'.
	newLine := self cleanMongoSpecialTags: newLine tag:  'ISODate'.
	^ newLine 
]

{ #category : #execution }
MAMongoAggregation >> cleanMongoSpecialTags:line tag: aTagName [ 
	"cleans ObjectId and NumberLong"
	| newLine tagPos endParentesis |

	newLine := WriteStream on:String new.
	tagPos := line findString: aTagName startingAt: 1.
	(tagPos = 0) 
	ifTrue:[ newLine nextPutAll:line ]
	ifFalse:[
		(line copyFrom: 1 to: tagPos -1) putOn:newLine.
		endParentesis := line indexOf: $) startingAt: tagPos.
		(line copyFrom: tagPos + aTagName size + 1 to: endParentesis -1) putOn:newLine.
		(line copyFrom: endParentesis + 1 to: line size) putOn: newLine ].
	
	^ newLine contents
]

{ #category : #stages }
MAMongoAggregation >> collStats: anExpression [
	self query add:(Array with:(self nextStage) with:'{$collStats:', (self serializer  serialize: anExpression),'}')
	
]

{ #category : #accessing }
MAMongoAggregation >> collection [
	^ collection
]

{ #category : #accessing }
MAMongoAggregation >> collection: anObject [
	collection := anObject
]

{ #category : #stages }
MAMongoAggregation >> count: anExpression [
	self query add:(Array with:(self nextStage) with:'{$count:', (self serializer serialize: anExpression),'}')
	
]

{ #category : #stages }
MAMongoAggregation >> currentOp: anExpression [
	self query add:(Array with:(self nextStage) with:'{$currentOp:', (self serializer serialize: anExpression),'}')
	
]

{ #category : #accessing }
MAMongoAggregation >> database [
	^ database
]

{ #category : #accessing }
MAMongoAggregation >> database: anObject [
"	foo                   foo database on local machine
  	192.168.0.5/foo       foo database on 192.168.0.5 machine
  	192.168.0.5:9999/foo  foo database on 192.168.0.5 machine on port 9999"
	
	database := anObject
]

{ #category : #accessing }
MAMongoAggregation >> execute [ 
	| readStream line records |
	
	self executeCommand.
	readStream := self outFilename asFileReference readStream .
	
	records := OrderedCollection new.
	[ readStream atEnd ] whileFalse:[
		line := readStream nextLine.
		(line notEmpty and:[line first = ${]) ifTrue:
			[records add: (materialize 
							ifTrue:[self materializer materializeFromString:  (self cleanMongoSpecialTags:line)]
							ifFalse:[self materializer readFromString:  (self cleanMongoSpecialTags:line)])]
	].
	expressionCounter := 0.
	self removeOldTmpFiles.
	^ records
]

{ #category : #execution }
MAMongoAggregation >> executeCommand [
	| result |
	self outFilename asFileReference exists ifFalse:[ 
		result :=LibC runCommand: self buildCommand.
		result = 0 ifFalse:[ Error signal:(self buildErrorMessage) ] ].

	
	


]

{ #category : #stages }
MAMongoAggregation >> facet: anExpression [
	self query add:(Array with:(self nextStage) with:'{$facet:', (self serializer serialize: anExpression),'}')
	
]

{ #category : #stages }
MAMongoAggregation >> geoNear: anExpression [
	self query add:(Array with:(self nextStage) with:'{$geoNear:', (self serializer serialize: anExpression),'}')
	
]

{ #category : #stages }
MAMongoAggregation >> graphLookup: anExpression [
	self query add:(Array with:(self nextStage) with:'{$graphLookup:', (self serializer serialize: anExpression),'}')
	
]

{ #category : #stages }
MAMongoAggregation >> group: anExpression [
		self query add:(Array with:(self nextStage) with:'{$group:', (self serializer serialize: anExpression),'}')
]

{ #category : #stages }
MAMongoAggregation >> indexStats: anExpression [
	self query add:(Array with:(self nextStage) with:'{$indexStats:', (self serializer serialize: anExpression),'}')
	
]

{ #category : #initialization }
MAMongoAggregation >> initialize [ 
	"expressionCounter set the sorting order of stages, just for future optimization"
	"cacheTime is used to build the output filename, it is 10**cacheTime and divides current time in millisecons, so all the times you call within the period results in the same filename=hash+time div: 10**cacheTime"
	super initialize.
	limit := 300.
	materialize:= false.
	expressionCounter := 0. 
	cacheTime := 0. 
	
]

{ #category : #stages }
MAMongoAggregation >> limit: anExpression [
	self query add:(Array with:(self nextStage) with:'{$limit:', (self serializer serialize: anExpression),'}').
	limit := anExpression asInteger.
	
]

{ #category : #stages }
MAMongoAggregation >> listLocalSessions: anExpression [
	self query add:(Array with:(self nextStage) with:'{$listLocalSessions:', (self serializer serialize: anExpression),'}')
	
]

{ #category : #stages }
MAMongoAggregation >> listSessions: anExpression [
	self query add:(Array with:(self nextStage) with:'{$listSessions:', (self serializer serialize: anExpression),'}')
	
]

{ #category : #stages }
MAMongoAggregation >> lookUp: anExpression [
	self query add:(Array with:(self nextStage) with:'{$lookup:', (self serializer serialize: anExpression),'}')
	
]

{ #category : #stages }
MAMongoAggregation >> match: aMatchExpression [
	self query add:(Array with:(self nextStage) with:'{$match:', (self serializer serialize:aMatchExpression),'}')
]

{ #category : #accessing }
MAMongoAggregation >> materialize [
	materialize:= true.
]

{ #category : #accessing }
MAMongoAggregation >> materializer [
	^ SCMaterializer  
]

{ #category : #stages }
MAMongoAggregation >> merge: anExpression [
	self query add:(Array with:(self nextStage) with:'{$merge:', (self serializer serialize: anExpression),'}')
	
]

{ #category : #stages }
MAMongoAggregation >> nextStage [
	^ expressionCounter := expressionCounter + 1
]

{ #category : #stages }
MAMongoAggregation >> out: anExpression [
	self query add:(Array with:(self nextStage) with:'{$out:', (self serializer serialize: anExpression),'}')
]

{ #category : #files }
MAMongoAggregation >> outFilename [
	"same namefile for n fraction of seconds"
	| timePart |
	timePart := (DateAndTime now asUnixTime  / (10 ** cacheTime)) asInteger.	 
	^ outFilename ifNil:[ outFilename := '/tmp/tmpmongoq' , self query hash hex , timePart asString, '.out']
]

{ #category : #execution }
MAMongoAggregation >> pathToMongoExecutable [
	^ pathToMongoExecutable ifNil:[ pathToMongoExecutable := '' ]
	
	


]

{ #category : #execution }
MAMongoAggregation >> pathToMongoExecutable: pathShouldEndWithSlash [
	pathToMongoExecutable := pathShouldEndWithSlash
	
	


]

{ #category : #stages }
MAMongoAggregation >> planCacheStats: anExpression [
	self query add:(Array with:(self nextStage) with:'{$planCacheStats:', (self serializer serialize: anExpression),'}')
	
]

{ #category : #stages }
MAMongoAggregation >> project: anExpression [
	self query add:(Array with:(self nextStage) with:'{$project:', (self serializer serialize: anExpression),'}')
]

{ #category : #accessing }
MAMongoAggregation >> query [ 
	^ query ifNil:[ query := OrderedCollection new ]
]

{ #category : #stages }
MAMongoAggregation >> redact: anExpression [
	self query add:(Array with:(self nextStage) with:'{$redact:', (self serializer serialize: anExpression),'}')
	
]

{ #category : #files }
MAMongoAggregation >> removeOldTmpFiles [
	| oldFilename tmpDir |
	 
	oldFilename := 'tmpmongoq' , self query hash hex.
	tmpDir := '/tmp/' asFileReference.
	tmpDir entries do:[ :anEntry | 
		((anEntry basename includesSubstring: oldFilename) and:[
			(self outFilename includesSubstring: anEntry basename) not ])
		ifTrue:[ anEntry asFileReference delete ] ]. 
	outFilename := nil
]

{ #category : #stages }
MAMongoAggregation >> replaceRoot: anExpression [
	self query add:(Array with:(self nextStage) with:'{$replaceRoot:', (self serializer serialize: anExpression),'}')
	
]

{ #category : #stages }
MAMongoAggregation >> replaceWith: anExpression [
	self query add:(Array with:(self nextStage) with:'{$replaceWith:', (self serializer serialize: anExpression),'}')
	
]

{ #category : #stages }
MAMongoAggregation >> sample: anExpression [
	self query add:(Array with:(self nextStage) with:'{$sample:', (self serializer serialize: anExpression),'}')
	
]

{ #category : #stages }
MAMongoAggregation >> search: anExpression [
	self query add:(Array with:(self nextStage) with:'{$search:', (self serializer serialize: anExpression),'}')
	
]

{ #category : #accessing }
MAMongoAggregation >> serializer [
	^ SCSerializer new plainJson;encodeSingleQuote 
]

{ #category : #stages }
MAMongoAggregation >> set: anExpression [
	self query add:(Array with:(self nextStage) with:'{$set:', (self serializer serialize: anExpression),'}')
	
]

{ #category : #stages }
MAMongoAggregation >> setWindowFields: anExpression [
	self query add:(Array with:(self nextStage) with:'{$setWindowFields:', (self serializer serialize: anExpression),'}')
	
]

{ #category : #stages }
MAMongoAggregation >> skip: anExpression [
	self query add:(Array with:(self nextStage) with:'{$skip', (self serializer serialize: anExpression),'}')
	
]

{ #category : #stages }
MAMongoAggregation >> sort: anExpression [
	self query add:(Array with:(self nextStage) with:'{$sort:', (self serializer serialize: anExpression),'}')
	
]

{ #category : #stages }
MAMongoAggregation >> sortByCount: anExpression [
	self query add:(Array with:11 with:'{$sortByCount:', (self serializer serialize: anExpression),'}')
	
]

{ #category : #stages }
MAMongoAggregation >> unset: anExpression [
	self query add:(Array with:(self nextStage) with:'{$unset', (self serializer serialize: anExpression),'}')
	
]

{ #category : #stages }
MAMongoAggregation >> unwind: anExpression [
		self query add:(Array with:(self nextStage) with:'{$unwind:', (self serializer serialize: anExpression),'}')
]
