fs = require 'fs'
path = require 'path'
async = require 'async'
YAML = require('yamljs')

metaRegex = ///
	# allow some space
	^\s*

	# discover our seperator
	(
		([^\s\d\w])\2{2,} # match a symbol character repeated 3 or more times
	) #\1

	# discover our parser
	(?:
		\x20* # allow zero or more space characters, see https://github.com/jashkenas/coffee-script/issues/2668
		(
			[a-z]+  # parser must be lowercase alpha
		) #\3
	)?

	# discover our meta content
	(
		[\s\S]*? # match anything/everything lazily
	) #\4

	# match our seperator (the first group) exactly
	\1
	///

fsdb =

	findOne: (filepath, query, cb) ->

		result = null

		# console.log 'path:', filepath

		fs.readdir filepath, (err, files) ->
			if err then cb err

			# console.log files

			async.eachSeries files, (filename, cb) ->

				if !result?

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

								header = metaMatch[4].trim()

								meta = YAML.parse(
									header.replace(/\t/g,'    ')  # YAML doesn't support tabs that well
								)

								# console.log meta

								queryMatch = true
								for key of query
									if meta[key] != query[key]
										queryMatch = false
								if queryMatch
									result = meta

					.on 'end', ->
						cb(null, meta)

				else
					cb( new Error 'result already found') # terminate iterator

			, (err, res) ->
				if err and err.message isnt 'result already found' then cb(err)
					
				cb(null, result)




module.exports = fsdb