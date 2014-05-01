
fsdb = require '../lib/index.js'
should = require 'should'
match = require './doc-meta-match'

describe 'fsdb.findOne()', ->

	it 'matches doc meta prop (id)', (done) ->

		fsdb.findOne './test/docs/*', match(-> @id is 1), (err, doc) -> 
			if err then return done(err)
			should.exist(doc)
			doc.should.have.property('title','Test Doc 1')
			done()

	it 'matches doc meta prop (title)', (done) ->

		fsdb.findOne './test/docs/*', match(-> @title is 'Test Doc 3'), (err, doc) -> 
			if err then return done(err)
			should.exist(doc)
			doc.should.have.property('id', 3 )
			done()

	it 'matches multiple props', (done) ->

		fsdb.findOne './test/docs/*', match(-> @title is 'Test Doc 2' and @id is 2), (err, doc) -> 
			if err then return done(err)
			should.exist(doc)
			doc.should.have.property('id', 2 )
			done()

	it 'returns null if no match', (done) ->

		fsdb.findOne './test/docs/*', match(-> @id is -1), (err, doc) -> 
			if err then return done(err)
			should.not.exist(doc)
			done()

	it 'gets one given only glob', (done) ->

		fsdb.findOne './test/docs/testdoc04.*', (err, doc) ->
			if err then return done(err)
			should.exist(doc)
			doc.should.eql('./test/docs/testdoc04.md')
			done()


describe 'fsdb.findAll()', ->

	it 'finds and returns as array all docs that match', (done) ->

		fsdb.findAll './test/docs/*', match(-> @tags?.some((tag) -> tag is 1)), (err, docs) ->
			if err then return done(err)
			docs.should.have.length(2)
			docs.some( (doc) -> doc.id is 1 ).should.be.ok
			docs.some( (doc) -> doc.id is 5 ).should.be.ok
			done()



