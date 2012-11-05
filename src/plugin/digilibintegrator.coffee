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
    
    # monkey patch Annotator.setupAnnotation
    digilib = @options.hooks
    @annotator.setupRangeAnnotation = @annotator.setupAnnotation
    @annotator.setupAnnotation = (annotation, fireEvents=true) ->
      # patched Annotator.setupAnnotation
      # accepts annotations with areas and renders in digilib
      if @selectedAreas? or annotation.areas?
        # do digilib annotations
        console.debug "setupAnnotation for areas!"
        annotation.areas or= @selectedAreas
        # compatibility crap
        annotation.highlights = []
        # setup in digilib
        digilib.setupAnnotation(annotation)
        
        # Fire annotationCreated events so that plugins can react to them.
        if fireEvents
          this.publish('annotationCreated', [annotation])

        annotation
        
      else
        # do old method
        @annotator.setupRangeAnnotation.apply(this, arguments)
        
    # monkey patch Annotator.onEditorSubmit
    @annotator.onEditorSubmit = (annotation) =>
      @annotator.publish('annotationEditorSubmit', [@editor, annotation])
      # accept either @ranges or @areas
      if annotation.ranges? or annotation.areas?
        @annotator.updateAnnotation(annotation)
      else
        @annotator.setupAnnotation(annotation)

        
  # Public: Callback method for annotationDeleted event. Receives an annotation
  # and forwards to digilib.
  #
  # annotation - An annotation Object that was deleted.
  #
  # Returns nothing.
  annotationDeleted: (annotation) ->
    # forward event to digilib
    @options.hooks.annotationDeleted(annotation)
