
fsdb = require 'docpad-fsdb'
should = require 'should'

describe '#findOne()', ->

	it 'matches doc meta prop (id)', (done) ->

		fsdb.findOne './test/docs/', {id: 1}, (err, doc) -> 
			if err then return done(err)
			doc.should.have.property('title','Test Doc 1')
			done()

	it 'matches doc meta prop (title)', (done) ->

		fsdb.findOne './test/docs/', {title: 'Test Doc 3'}, (err, doc) -> 
			if err then return done(err)
			doc.should.have.property('id', 3 )
			done()

	it 'matches multiple props', (done) ->

		fsdb.findOne './test/docs/', {title: 'Test Doc 2', id: 2}, (err, doc) -> 
			if err then return done(err)
			doc.should.have.property('id', 2 )
			done()

	it 'returns null if no match', (done) ->

		fsdb.findOne './test/docs/', {id: -1}, (err, doc) -> 
			if err then return done(err)
			should.not.exist(doc)
			done()


describe '#find()', ->

	it 'finds all docs with matching meta'


	