# Plugin to use Annotator inside digilib.
#
class Annotator.Plugin.DigilibIntegrator extends Annotator.Plugin
  # - annotationDeleted: An annotation has been deleted.
  events:
    'annotationDeleted': 'annotationDeleted'

  # Options Object
  options:
    # method instances
    hooks: null

  # Public: Initialises the plugin and modifies @annotator methods to
  # deal with digilib annotations.
  #
  # Returns nothing.
  pluginInit: ->
    console.debug "DigilibIntegrator plugin init"
    
    # monkey-patch Annotator.setupAnnotation
    @annotator.digilib = @options.hooks
    @annotator.setupRangeAnnotation = @annotator.setupAnnotation
    @annotator.setupAnnotation = @_setupAnnotation
        
    this
        
  # patched Annotator.setupAnnotation: accepts annotations with areas and renders in digilib
  #
  # Public: Initialises an annotation either from an object representation or
  # an annotation created with Annotator#createAnnotation(). It finds the
  # selected range and higlights the selection in the DOM.
  #
  # annotation - An annotation Object to initialise.
  # fireEvents - Will fire the 'annotationCreated' event if true.
  #
  # Returns the initialised annotation.
  _setupAnnotation: (annotation, fireEvents=true) ->
      if @selectedAreas? or annotation.areas?
        # do digilib annotations
        console.debug "setupAnnotation for areas!"
        annotation.areas or= @selectedAreas
        # compatibility crap
        annotation.highlights = []
        annotation.ranges = []
        # setup in digilib
        @digilib.setupAnnotation(annotation)
        
        # Fire annotationCreated events so that plugins can react to them.
        if fireEvents
          this.publish('annotationCreated', [annotation])

        annotation
        
      else
        # do old method
        this.setupRangeAnnotation.apply(this, arguments)

  # Public: Callback method for annotationDeleted event. Receives an annotation
  # and forwards to digilib.
  #
  # annotation - An annotation Object that was deleted.
  #
  # Returns nothing.
  annotationDeleted: (annotation) ->
    # forward event to digilib
    @options.hooks.annotationDeleted(annotation)
