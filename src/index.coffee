
fs = require 'fs'
fp = require 'path'
async = require 'async'
g = require 'glob'


# scans files and calls found on every match
# files is array of file paths
# match is function to test each file against
# found is callback on match
# iteration can be broken if found returns false
# calls found with null result to end
scan = (files, match, found) ->

	async.eachSeries files, (file, done) ->

		match file, (err,matched) ->
			if err then return done(err)

			if matched

				# if match func simply returns true then return file path by default
				# otherwise returns matched result as is
				res = if matched is true then file else matched

				stop = !found( null, res )

			done(stop) # if found callback returns false this stops eachSeries with err signal of true

	, (err) ->
		if err isnt true # ignore stop signal
			found(err)


fsdb =

	# returns cursor
	find: ([dir, match, mode]..., cb) ->
		dir ?= './'
		match ?= (-> true)
		mode ?= 'lazy'

		# TODO ... use walk maybe

	# returns single doc
	findOne: (glob, [match]..., cb) ->

		g glob, (err, files) ->
			if err then return cb(err)

			if !match? then return cb(null,files[0])

			scan files, match, (err, doc) ->
				cb(err,doc)
				return false # stop scanning early

	# returns all in array
	findAll: (glob, [match]..., cb) ->

		g glob, (err, files) ->
			if err then return cb(err)

			if !match? then return cb(null,files)

			res = []
			scan files, match, (err, doc) ->
				if err
					cb(err)
					return false

				if doc?
					res.push(doc)
				else

					cb(null,res) # will callback after null result recieved
		



module.exports = fsdb
