Class {
	#name : #MAActivityTestObj,
	#superclass : #Object,
	#instVars : [
		'product',
		'issuer_email',
		'workflow_id',
		'in_batch_id',
		'out_batch_id',
		'is_qc',
		'field_set',
		'primary_key',
		'primary_value',
		'id',
		'modified',
		'svg_qr_files',
		'graphic_show_role',
		'unique_codes',
		'role',
		'is_final_step',
		'user',
		'qrcode',
		'eps_qr_files',
		'no_out_badge',
		'evidence',
		'blockchain',
		'product_step',
		'final_qr_code_url_value',
		'transaction_address',
		'locations',
		'qr_code_url_value',
		'workflow',
		'show_role',
		'created'
	],
	#category : #'MAMongo-AggregationFramework-Tests'
}

{ #category : #'instance creation' }
MAActivityTestObj class >> fromActivity: anActivity [
	| instance fields |
	
	fields := OrderedCollection new.
	instance := self new.
	(anActivity at:#field_set) do:[ :k |
		fields add: (MAFieldTestObj fromField: k)
		].

	instance class allInstVarNames do:[ :k |
		(anActivity includesKey:k) ifTrue:[ instance instVarNamed:k put:(anActivity at:k) ] ].
					
					
	instance field_set: fields asArray.			
	^ instance 
]

{ #category : #testing }
MAActivityTestObj class >> isVoyageRoot [
	^ true
]

{ #category : #testing }
MAActivityTestObj class >> voyageCollectionName [
	^ 'MAFieldTestObj'
]

{ #category : #accessing }
MAActivityTestObj >> blockchain [
	^ blockchain
]

{ #category : #accessing }
MAActivityTestObj >> blockchain: anObject [
	blockchain := anObject
]

{ #category : #accessing }
MAActivityTestObj >> created [
	^ created
]

{ #category : #accessing }
MAActivityTestObj >> created: anObject [
	created := anObject
]

{ #category : #accessing }
MAActivityTestObj >> eps_qr_files [
	^ eps_qr_files
]

{ #category : #accessing }
MAActivityTestObj >> eps_qr_files: anObject [
	eps_qr_files := anObject
]

{ #category : #accessing }
MAActivityTestObj >> evidence [
	^ evidence
]

{ #category : #accessing }
MAActivityTestObj >> evidence: anObject [
	evidence := anObject
]

{ #category : #accessing }
MAActivityTestObj >> field_set [
	^ field_set
]

{ #category : #accessing }
MAActivityTestObj >> field_set: anObject [
	field_set := anObject
]

{ #category : #accessing }
MAActivityTestObj >> final_qr_code_url_value [
	^ final_qr_code_url_value
]

{ #category : #accessing }
MAActivityTestObj >> final_qr_code_url_value: anObject [
	final_qr_code_url_value := anObject
]

{ #category : #accessing }
MAActivityTestObj >> graphic_show_role [
	^ graphic_show_role
]

{ #category : #accessing }
MAActivityTestObj >> graphic_show_role: anObject [
	graphic_show_role := anObject
]

{ #category : #accessing }
MAActivityTestObj >> id [
	^ id
]

{ #category : #accessing }
MAActivityTestObj >> id: anObject [
	id := anObject
]

{ #category : #accessing }
MAActivityTestObj >> in_batch_id [
	^ in_batch_id
]

{ #category : #accessing }
MAActivityTestObj >> in_batch_id: anObject [
	in_batch_id := anObject
]

{ #category : #accessing }
MAActivityTestObj >> is_final_step [
	^ is_final_step
]

{ #category : #accessing }
MAActivityTestObj >> is_final_step: anObject [
	is_final_step := anObject
]

{ #category : #accessing }
MAActivityTestObj >> is_qc [
	^ is_qc
]

{ #category : #accessing }
MAActivityTestObj >> is_qc: anObject [
	is_qc := anObject
]

{ #category : #accessing }
MAActivityTestObj >> issuer_email [
	^ issuer_email
]

{ #category : #accessing }
MAActivityTestObj >> issuer_email: anObject [
	issuer_email := anObject
]

{ #category : #accessing }
MAActivityTestObj >> locations [
	^ locations
]

{ #category : #accessing }
MAActivityTestObj >> locations: anObject [
	locations := anObject
]

{ #category : #accessing }
MAActivityTestObj >> modified [
	^ modified
]

{ #category : #accessing }
MAActivityTestObj >> modified: anObject [
	modified := anObject
]

{ #category : #accessing }
MAActivityTestObj >> no_out_badge [
	^ no_out_badge
]

{ #category : #accessing }
MAActivityTestObj >> no_out_badge: anObject [
	no_out_badge := anObject
]

{ #category : #accessing }
MAActivityTestObj >> out_batch_id [
	^ out_batch_id
]

{ #category : #accessing }
MAActivityTestObj >> out_batch_id: anObject [
	out_batch_id := anObject
]

{ #category : #accessing }
MAActivityTestObj >> primary_key [
	^ primary_key
]

{ #category : #accessing }
MAActivityTestObj >> primary_key: anObject [
	primary_key := anObject
]

{ #category : #accessing }
MAActivityTestObj >> primary_value [
	^ primary_value
]

{ #category : #accessing }
MAActivityTestObj >> primary_value: anObject [
	primary_value := anObject
]

{ #category : #accessing }
MAActivityTestObj >> product [
	^ product
]

{ #category : #accessing }
MAActivityTestObj >> product: anObject [
	product := anObject
]

{ #category : #accessing }
MAActivityTestObj >> product_step [
	^ product_step
]

{ #category : #accessing }
MAActivityTestObj >> product_step: anObject [
	product_step := anObject
]

{ #category : #accessing }
MAActivityTestObj >> qr_code_url_value [
	^ qr_code_url_value
]

{ #category : #accessing }
MAActivityTestObj >> qr_code_url_value: anObject [
	qr_code_url_value := anObject
]

{ #category : #accessing }
MAActivityTestObj >> qrcode [
	^ qrcode
]

{ #category : #accessing }
MAActivityTestObj >> qrcode: anObject [
	qrcode := anObject
]

{ #category : #accessing }
MAActivityTestObj >> role [
	^ role
]

{ #category : #accessing }
MAActivityTestObj >> role: anObject [
	role := anObject
]

{ #category : #accessing }
MAActivityTestObj >> show_role [
	^ show_role
]

{ #category : #accessing }
MAActivityTestObj >> show_role: anObject [
	show_role := anObject
]

{ #category : #'as yet unclassified' }
MAActivityTestObj >> simplify [
	| i |
	i := SCJsonObject new.
			i out_batch_id: self out_batch_id.
	self field_set do:[: aField |
		i at: aField name put: aField value first ]. 
	^ i
]

{ #category : #accessing }
MAActivityTestObj >> svg_qr_files [
	^ svg_qr_files
]

{ #category : #accessing }
MAActivityTestObj >> svg_qr_files: anObject [
	svg_qr_files := anObject
]

{ #category : #accessing }
MAActivityTestObj >> transaction_address [
	^ transaction_address
]

{ #category : #accessing }
MAActivityTestObj >> transaction_address: anObject [
	transaction_address := anObject
]

{ #category : #accessing }
MAActivityTestObj >> unique_codes [
	^ unique_codes
]

{ #category : #accessing }
MAActivityTestObj >> unique_codes: anObject [
	unique_codes := anObject
]

{ #category : #accessing }
MAActivityTestObj >> user [
	^ user
]

{ #category : #accessing }
MAActivityTestObj >> user: anObject [
	user := anObject
]

{ #category : #accessing }
MAActivityTestObj >> workflow [
	^ workflow
]

{ #category : #accessing }
MAActivityTestObj >> workflow: anObject [
	workflow := anObject
]

{ #category : #accessing }
MAActivityTestObj >> workflow_id [
	^ workflow_id
]

{ #category : #accessing }
MAActivityTestObj >> workflow_id: anObject [
	workflow_id := anObject
]
