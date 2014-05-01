

YAML = require 'yamljs'
metaRegex = /^\s*(([^\s\d\w])\2{2,})(?:\x20*([a-z]+))?([\s\S]*?)\1/
fs = require 'fs'

module.exports = (matchFunc) ->

	return (file,cb) ->

		fs.readFile file, (err,data) ->
			if err then return cb(err)

			match = metaRegex.exec( data )

			if match
				meta = YAML.parse( match[4].trim().replace(/\t/g,'    ') )

				if matchFunc.call(meta)

					return cb( null, meta )

			cb(null,false)




