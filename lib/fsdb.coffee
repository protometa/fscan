
fs = require 'fs'
path = require 'path'
async = require 'async'


scan = (filepath, test, found) ->
	# scans filepath and calls found on every hit
	# iteration can be broken if found returns false
	# calls found with null result to end

	# console.log 'path:', filepath

	fs.readdir filepath, (err, files) ->
		if err then found err

		async.eachSeries files, (filename, done) ->

			fs.readFile path.join( filepath, filename ), {encoding: 'utf8'}, (err, filedata) ->
				if err then found(err)
				
				if testRes = test( path.join( filepath, filename ), filedata)
					# if test simply returns true return filepath by default, otherwise return testRes as is
					if testRes is true then res = filepath else res = testRes

					stop = !found( null, res ) 

				done(stop) # if callback returns false stops scanning with err signal

		, (err) ->
			if err isnt true # catch stop signal
				found(err,null)


fsdb =

	find: ([filepath, test, mode]..., cb) ->
		filepath ?= './'
		test ?= (-> true)
		mode ?= 'lazy'

		# TODO ...


	findOne: (filepath, test, cb) ->
		scan filepath, test, (err, doc) ->
			cb(err,doc)
			return false # stop scanning


	findAll: (filepath, test, cb) ->
		res = []
		scan filepath, test, (err, doc) ->
			if doc? and not err?
				res.push(doc)
			else
				cb(err,res) # will callback after null result recieved
		



module.exports = fsdb
