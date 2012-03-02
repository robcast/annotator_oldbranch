// dwinter 
// Initalisiert den annotator (http://okfn.org/projects/annotator/) benoetigt File 	
// annotator-full.min.js 
// setzt die fuer die mit den AnnotationManager notwendigen parameter.


generateBaseURL = function(){
    return window.location.host+window.location.pathname;
}

generateDocuviewerUrl = function() {
   var anchor, i, items, o, p, query, queryPn, queryUrl, source, strictMode;
   o = parseUri.options;
   strictMode = $("strictMode").checked;
   o.strictMode = strictMode;
   items = parseUri(document.URL);
   query = items[o.q.name];
   i = 0;
   while (i < o.key.length) {
       items[o.key[i]] = escapeHtml(items[o.key[i]]);
       i++;
   }
   for (p in query) {
	if (query.hasOwnProperty(p)) {
           query[p] = escapeHtml(query[p]);
	}
   }
   anchor = items.anchor;
   source = items.source;
   queryPn = query.pn;
   queryUrl = unescape(query.url);
   return "pn=" + queryPn + "&" + "url=" + queryUrl;
};



initialize_annotator = function() {

   this.options = {

       user:{ user: {id:  'itgroup',
		      name: 'itgroup',
		      password: 'XX'},
	       userString: function(user){return(user.name)},
	       userId: function(user){return(user.id)}
	     },
       store: {
           prefix: 
           'http://virtuoso.mpiwg-berlin.mpg.de:8080/AnnotationManager/annotator',

           annotationData: {
               uri: window.location.href.split(/#|\?/).shift() + '?' + generateDocuviewerUrl() || '',
               mode: 'annotator'
           },
           loadFromSearch: {
               uri: window.location.href.split(/#|\?/).shift() + '?' + generateDocuviewerUrl() || '',
               all_fields: 1
           }
       }
   }

   $('.pageContent').annotator()
      .annotator('addPlugin',
                  'Store',this.options.store)
       .annotator('addPlugin', 'Permissions',this.options.user)


};

function changeUser(identifier,password){
   $('.pageContent').data().annotator.plugins.Permissions.user.id=identifier;
   $('.pageContent').data().annotator.plugins.Permissions.user.password=password;
};