# Mongo-AggregationFramework
Mongo Aggregation framework is not supported by Mongo driver in Pharo, this is a "practical" solution using the "mongo" command line.

You need Mongo-Voyage installed on your image. This script does'nt install it.
```Smalltalk
Metacello new
	githubUser: 'jmari' project: 'MAMongo-AggregationFramework' commitish:'main' path: '';
	baseline:'MAAggregationFramework';
	load
```

Example:
```Smalltalk
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
						'k'->{'$concat'->{'field_'. '$$this.name'}}asDictionary.
						'v'->{'$max'->'$$this.value'} asDictionary 
					}asDictionary 
				} asDictionary 
			} asDictionary 
		} asDictionary 
	} asDictionary .
	result:= aggregator execute.
```
  
  
