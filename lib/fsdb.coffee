
fs = require 'fs'
path = require 'path'
async = require 'async'
YAML = require 'yamljs'

metaRegex = /^\s*(([^\s\d\w])\2{2,})(?:\x20*([a-z]+))?([\s\S]*?)\1/

fsdb =

	findOne: (filepath, test, cb) ->

		res = null

		# console.log 'path:', filepath

		fs.readdir filepath, (err, files) ->
			if err then cb err

			# console.log files

			async.eachSeries files, (filename, cb) ->

				if res?
					cb( new Error 'result already found') # terminate iterator

				else

					filedata = ''
					meta = null

					rs = fs.createReadStream( path.join( filepath, filename ), {encoding: 'utf8'} )
					.on 'err', (err) ->
						cb(err)
					.on 'data', (chunk) ->

						if !meta?

							filedata += chunk

							metaMatch = metaRegex.exec filedata

							if metaMatch

								header = metaMatch[4].trim().replace(/\t/g,'    ')

								meta = YAML.parse( header )

								# console.log meta

								if test.call(meta)
									res = meta 

					.on 'end', ->
						cb()
					
			, (err) ->
				if err and err.message isnt 'result already found' then cb(err)
					
				cb(null, res)


	find: (filepath, test, cb) ->

		res = []

		fs.readdir filepath, (err, files) ->
			if err then cb(err)

			async.eachSeries files, (filename, cb) ->

				filedata = ''
				meta = null

				rs = fs.createReadStream( path.join( filepath, filename ), {encoding: 'utf8'} )
				.on 'err', (err) ->
					cb(err)
				.on 'data', (chunk) ->

					if !meta?

						filedata += chunk

						metaMatch = metaRegex.exec filedata

						if metaMatch

							header = metaMatch[4].trim().replace(/\t/g,'    ')

							meta = YAML.parse( header )

							# console.log meta

							if test.call(meta)
								res.push( meta )

				.on 'end', ->
					cb()

			, (err) ->
				if err then cb(err)
					
				cb(null, res)



module.exports = fsdb
