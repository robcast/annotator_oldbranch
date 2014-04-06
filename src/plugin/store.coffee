Annotator = require('annotator')
Util = Annotator.Util
$ = Util.$
_t = Util.TranslationString


# Public: The Store plugin can be used to persist annotations to a database
# running on your server. It has a simple customisable interface that can be
# implemented with any web framework. It works by listening to events published
# by the Annotator and making appropriate requests to the server depending on
# the event.
#
# The store handles five distinct actions "read", "search", "create", "update"
# and "destroy". The requests made can be customised with options when the
# plugin is added to the Annotator.
class Store

  # User customisable options available.
  options:

    # Custom meta data that will be attached to every annotation that is sent
    # to the server. This _will_ override previous values.
    #
    # @slatedForDeprecation 2.1.0
    annotationData: null

    # Should the plugin emulate HTTP methods like PUT and DELETE for
    # interaction with legacy web servers? Setting this to `true` will fake
    # HTTP `PUT` and `DELETE` requests with an HTTP `POST`, and will set the
    # request header `X-HTTP-Method-Override` with the name of the desired
    # method.
    emulateHTTP: false

    # Should the plugin emulate JSON POST/PUT payloads by sending its requests
    # as application/x-www-form-urlencoded with a single key, "json"
    emulateJSON: false

    # A set of custom headers that will be sent with every request. See also the
    # setHeader method.
    headers: {}

    # This is the API endpoint. If the server supports Cross Origin Resource
    # Sharing (CORS) a full URL can be used here.
    prefix: '/store'

    # The server URLs for each available action. These URLs can be anything but
    # must respond to the appropraite HTTP method. The token ":id" can be used
    # anywhere in the URL and will be replaced with the annotation id.
    #
    # read:    GET
    # create:  POST
    # update:  PUT
    # destroy: DELETE
    # search:  GET
    urls:
      create: '/annotations'
      read: '/annotations/:id'
      update: '/annotations/:id'
      destroy: '/annotations/:id'
      search: '/search'

  # Public: The contsructor initailases the Store instance. It requires the
  # Annotator#element and an Object of options.
  #
  # element - This must be the Annotator#element in order to listen for events.
  # options - An Object of key/value user options.
  #
  # Examples
  #
  #   store = new Annotator.Plugin.Store(Annotator.element, {
  #     prefix: 'http://annotateit.org',
  #     annotationData: {
  #       uri: window.location.href
  #     }
  #   })
  #
  # Returns a new instance of Store.
  constructor: (options) ->
    @options = $.extend(true, {}, @options, options)

  # Public: Callback method for annotationCreated event. Receives an annotation
  # and sends a POST request to the sever using the URI for the "create" action.
  #
  # annotation - An annotation Object that was created.
  #
  # Examples
  #
  #   store.annotationCreated({text: "my new annotation comment"})
  #   # => Results in an HTTP POST request to the server containing the
  #   #    annotation as serialised JSON.
  #
  # Returns a jqXHR object.
  create: (annotation) ->
    this._apiRequest('create', annotation)

  # Public: Callback method for annotationUpdated event. Receives an annotation
  # and sends a PUT request to the sever using the URI for the "update" action.
  #
  # annotation - An annotation Object that was updated.
  #
  # Examples
  #
  #   store.annotationUpdated({id: "blah", text: "updated annotation comment"})
  #   # => Results in an HTTP PUT request to the server containing the
  #   #    annotation as serialised JSON.
  #
  # Returns a jqXHR object.
  update: (annotation) ->
    this._apiRequest('update', annotation)

  # Public: Callback method for annotationDeleted event. Receives an annotation
  # and sends a DELETE request to the server using the URI for the destroy
  # action.
  #
  # annotation - An annotation Object that was deleted.
  #
  # Examples
  #
  #   store.annotationDeleted({text: "my new annotation comment"})
  #   # => Results in an HTTP DELETE request to the server.
  #
  # Returns a jqXHR object.
  delete: (annotation) ->
    this._apiRequest('destroy', annotation)

  # Public: Searches for annotations matching the specified query.
  #
  # Returns a Promise resolving to the query results and query metadata.
  query: (queryObj) ->
    dfd = $.Deferred()
    this._apiRequest('search', queryObj)
    .done (obj) ->
      rows = obj.rows
      delete obj.rows
      dfd.resolve(rows, obj)
    .fail ->
      dfd.reject.apply(dfd, arguments)
    return dfd.promise()

  # Public: Set a custom HTTP header to be sent with every request.
  #
  # key   - The header name.
  # value - The header value.
  #
  # Examples:
  #
  #   store.setHeader('X-My-Custom-Header', 'MyCustomValue')
  #
  # Returns nothing.
  setHeader: (key, value) ->
    this.options.headers[key] = value

  # Callback method for Store#loadAnnotationsFromSearch(). Processes the data
  # returned from the server (a JSON array of annotation Objects) and updates
  # the registry as well as loading them into the Annotator.
  # Returns the jQuery XMLHttpRequest wrapper enabling additional callbacks to
  # be applied as well as custom error handling.
  #
  # action    - The action String eg. "read", "search", "create", "update"
  #             or "destory".
  # obj       - The data to be sent, either annotation object or query string.
  # onSuccess - A callback Function to call on successful request.
  #
  # Examples:
  #
  #   store._apiRequest('read', {id: 4}, (data) -> console.log(data))
  #   # => Outputs the annotation returned from the server.
  #
  # Returns XMLHttpRequest object.
  _apiRequest: (action, obj) ->
    id = obj && obj.id
    url = this._urlFor(action, id)
    options = this._apiRequestOptions(action, obj)

    request = $.ajax(url, options)

    # Append the id and action to the request object
    # for use in the error callback.
    request._id = id
    request._action = action
    request

  # Builds an options object suitable for use in a jQuery.ajax() call.
  #
  # action    - The action String eg. "read", "search", "create", "update"
  #             or "destroy".
  # obj       - The data to be sent, either annotation object or query string.
  #
  # Returns Object literal of $.ajax() options.
  _apiRequestOptions: (action, obj) ->
    method = this._methodFor(action)

    opts =
      type: method,
      dataType: "json",
      error: this._onError,
      headers: this.options.headers

    # If emulateHTTP is enabled, we send a POST and put the real method in an
    # HTTP request header.
    if @options.emulateHTTP and method in ['PUT', 'DELETE']
      opts.headers = $.extend(opts.headers, {'X-HTTP-Method-Override': method})
      opts.type = 'POST'

    # Don't JSONify obj if making search request.
    if action is "search"
      opts = $.extend(opts, data: obj)
      return opts

    # Add annotationData to object, if specified
    #
    # @slatedForDeprecation 2.1.0
    if @options.annotationData?
      Util.deprecationWarning("Use of the annotationData option to the Store
                               plugin is deprecated and will be removed in a
                               future version. Please use hooks to
                               beforeAnnotationCreated and
                               beforeAnnotationUpdated to replicate this
                               behaviour.")
      $.extend(obj, @options.annotationData)

    data = obj && JSON.stringify(obj)

    # If emulateJSON is enabled, we send a form request (the correct
    # contentType will be set automatically by jQuery), and put the
    # JSON-encoded payload in the "json" key.
    if @options.emulateJSON
      opts.data = {json: data}
      if @options.emulateHTTP
        opts.data._method = method
      return opts

    opts = $.extend(opts, {
      data: data
      contentType: "application/json; charset=utf-8"
    })
    return opts

  # Builds the appropriate URL from the options for the action provided.
  #
  # action - The action String.
  # id     - The annotation id as a String or Number.
  #
  # Examples
  #
  #   store._urlFor('update', 34)
  #   # => Returns "/store/annotations/34"
  #
  #   store._urlFor('search')
  #   # => Returns "/store/search"
  #
  # Returns URL String.
  _urlFor: (action, id) ->
    url = if @options.prefix? then @options.prefix else ''
    url += @options.urls[action]
    # If there's a '/:id' in the URL, either fill in the ID or remove the
    # slash:
    url = url.replace(/\/:id/, if id? then '/' + id else '')
    # If there's a bare ':id' in the URL, then substitute directly:
    url = url.replace(/:id/, if id? then id else '')

    url

  # Maps an action to an HTTP method.
  #
  # action - The action String.
  #
  # Examples
  #
  #   store._methodFor('read')    # => "GET"
  #   store._methodFor('update')  # => "PUT"
  #   store._methodFor('destroy') # => "DELETE"
  #
  # Returns HTTP method String.
  _methodFor: (action) ->
    table =
      create: 'POST'
      read: 'GET'
      update: 'PUT'
      destroy: 'DELETE'
      search: 'GET'

    table[action]

  # jQuery.ajax() callback. Displays an error notification to the user if
  # the request failed.
  #
  # xhr - The jXMLHttpRequest object.
  #
  # Returns nothing.
  _onError: (xhr) ->
    action  = xhr._action
    message = _t("Sorry we could not ") + action + _t(" this annotation")

    if xhr._action == 'search'
      message = _t("Sorry we could not search the store for annotations")
    else if xhr._action == 'read' && !xhr._id
      message = _t("Sorry we could not ") +
                action +
                _t(" the annotations from the store")

    switch xhr.status
      when 401
        message = _t("Sorry you are not allowed to ") +
                  action +
                  _t(" this annotation")
      when 404
        message = _t("Sorry we could not connect to the annotations store")
      when 500
        message = _t("Sorry something went wrong with the annotation store")

    Annotator.showNotification message, Annotator.Notification.ERROR

    console.error _t("API request failed:") + " '#{xhr.status}'"

Annotator.Plugin.register('Store', Store)

module.exports = Store
