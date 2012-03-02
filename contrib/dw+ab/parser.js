		function parser (id) {
			return document.URL;
		}
		
		
		function showResults () {
			var o = parseUri.options;
			var strictMode = $('strictMode').checked;
			
			o.strictMode = strictMode;
			var items = parseUri(document.URL);
			var query = items[o.q.name];
			
			
			for (var i = 0; i < o.key.length; i++) {
				items[o.key[i]] = escapeHtml(items[o.key[i]]);
			}
			for (var p in query) {
				if (query.hasOwnProperty(p)) {
					query[p] = escapeHtml(query[p]);
				}
			}
			var anchor =  items.anchor;
			var source = items.source;
			var queryPn = query.pn;
			var queryUrl = query.url;
			return ("\n" + "page number: "+ queryPn + "\n" +"url: "+ queryUrl);
		}
		
		function escapeHtml (html) {
			var replacements = {
				'&': '&amp;',
				'<': '&lt;',
				'>': '&gt;'
			};
			return html.replace(/[&<>]/g, function ($0) {return replacements[$0];});
		}
		
		function parseUri (str) {
			var	o   = parseUri.options,
			m   = o.parser[o.strictMode ? "strict" : "loose"].exec(str),
			uri = {},
			i   = 14;

			while (i--) uri[o.key[i]] = m[i] || "";

			uri[o.q.name] = {};
			uri[o.key[12]].replace(o.q.parser, function ($0, $1, $2) {
			if ($1) uri[o.q.name][$1] = $2;
			});

			return uri;
	};

	parseUri.options = {
		strictMode: false,
		key: ["source","protocol","authority","userInfo","user","password","host","port","relative","path","directory","file","query","anchor"],
		q:   {
			name:   "queryKey",
			parser: /(?:^|&)([^&=]*)=?([^&]*)/g
		},
		parser: {
			strict: /^(?:([^:\/?#]+):)?(?:\/\/((?:(([^:@]*)(?::([^:@]*))?)?@)?([^:\/?#]*)(?::(\d*))?))?((((?:[^?#\/]*\/)*)([^?#]*))(?:\?([^#]*))?(?:#(.*))?)/,
			loose:  /^(?:(?![^:@]+:[^:@\/]*@)([^:\/?#.]+):)?(?:\/\/)?((?:(([^:@]*)(?::([^:@]*))?)?@)?([^:\/?#]*)(?::(\d*))?)(((\/(?:[^?#](?![^?#\/]*\.[^?#\/.]+(?:[?#]|$)))*\/?)?([^?#\/]*))(?:\?([^#]*))?(?:#(.*))?)/
		}
	};

