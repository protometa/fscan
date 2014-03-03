
fs = require 'fs'
fp = require 'path'
async = require 'async'


scan = (dir, test, found) ->
	# scans filepath and calls found on every hit
	# iteration can be broken if found returns false
	# calls found with null result to end

	# console.log 'path:', filepath

	fs.readdir dir, (err, files) ->
		if err then found err

		async.eachSeries files, (name, done) ->

			path = fp.join( dir, name )

			fs.readFile path, {encoding: 'utf8'}, (err, filedata) ->
				if err then found(err)
				
				test path, filedata, (testRes) ->
					# if test simply returns true return path by default, otherwise return testRes as is
					if testRes is true then res = path else res = testRes

					stop = !found( null, res ) 

					done(stop) # if callback returns false stops eachSeries with err signal

		, (err) ->
			if err isnt true # catch stop signal
				found(err,null)


fsdb =

	# returns cursor
	find: ([dir, test, mode]..., cb) ->
		dir ?= './'
		test ?= (-> true)
		mode ?= 'lazy'

		# TODO ... use walk maybe

	# returns single doc
	findOne: (dir, test, cb) ->
		scan dir, test, (err, doc) ->
			cb(err,doc)
			return false # stop scanning early

	# returns all in array
	findAll: (dir, test, cb) ->
		res = []
		scan dir, test, (err, doc) ->
			if doc? and not err?
				res.push(doc)
			else
				cb(err,res) # will callback after null result recieved
		



module.exports = fsdb
