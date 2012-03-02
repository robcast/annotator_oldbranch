/* ***** BEGIN LICENSE BLOCK *****
 * Version: MPL 1.1/GPL 2.0/LGPL 2.1
 *
 * The contents of this file are subject to the Mozilla Public License Version
 * 1.1 (the "License"); you may not use this file except in compliance with
 * the License. You may obtain a copy of the License at
 * http://www.mozilla.org/MPL/
 *
 * Software distributed under the License is distributed on an "AS IS" basis,
 * WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License
 * for the specific language governing rights and limitations under the
 * License.
 *
 * The Original Code is Annozilla.
 *
 * Portions created by the Initial Developer are Copyright (C) 2003
 * the Initial Developer. All Rights Reserved.
 *
 * Contributor(s):
 *  C. Greg Hagerty <cgreg@cgreg.com>
 *   dump to console for debug
 *
 * Alternatively, the contents of this file may be used under the terms of
 * either the GNU General Public License Version 2 or later (the "GPL"), or
 * the GNU Lesser General Public License Version 2.1 or later (the "LGPL"),
 * in which case the provisions of the GPL or the LGPL are applicable instead
 * of those above. If you wish to allow use of your version of this file only
 * under the terms of either the GPL or the LGPL, and not to allow others to
 * use your version of this file under the terms of the MPL, indicate your
 * decision by deleting the provisions above and replace them with the notice
 * and other provisions required by the GPL or the LGPL. If you do not delete
 * the provisions above, a recipient may use your version of this file under
 * the terms of any one of the MPL, the GPL or the LGPL.
 *
 * ***** END LICENSE BLOCK ***** */

/**
 * XPointerService interaction.
 */
function AnnozillaXPointerUtils ()
{
    this.ANNOT_NS = "http://www.w3.org/2000/10/annotation-ns#";
    //Components.utils.import("resource://nsXPointerService.js");  
    this.XPointerService = new XPointerService();

    //this.consoleService = Components.classes['@mozilla.org/consoleservice;1'].getService(Components.interfaces.nsIConsoleService);
}

/* for debug */
/*AnnozillaXPointerUtils.prototype.dumpToConsole =
function (msg) {
    this.consoleService.logStringMessage (msg);
}*/

AnnozillaXPointerUtils.prototype.xptrIsServiceLoaded =
function () {
    return (this.XPointerService != null);
}

AnnozillaXPointerUtils.prototype.xptrResolveFragment =
function (fragment, doc){
    return this.XPointerService.parseXPointerToRange(fragment, doc);
}

AnnozillaXPointerUtils.prototype.xptrResolveAnnotation =
function (annotation, doc) {
    var range = null; // resolved range for xpointer
    // context is full uri including xpointer
    var context = annotation.data.getProperty(this.ANNOT_NS, "context");
    
    if (context) {
	// strip uri down to xpointer
	var index = context.indexOf("#");
	context = context.substring(index + 1);
    // Little hack. FF3 won't allow us to insert data at the root of the document.
    if (context=="xpointer(/html[1])") {
	context = "xpointer(/html[1]/body[1])"
    };
	if (index != -1) {
	    try {
		return this.xptrResolveFragment(context, doc);
	    }
	    catch(e) {
		dump("\nCouldn't resolve annotation " + annotation.annotationURI + ": " + e + "\n");
                dump("context: "+context+"\n");
                this.dumpToConsole("Couldn't resolve annotation " 
                                + annotation.annotationURI + ": " + e + "\n"
                                + "in context: "+context);
	    }
	}
	else {
	    dump("couldn't find # in context: " + context + "\n");
	}
    }
    else {
	dump("couldn't get context for annotation: " + annotation.annotationURI + "\n");
    }
    
    // couldn't resolve annotation
    return null;
}

AnnozillaXPointerUtils.prototype.xptrCreateXPointer =
function (seln, doc) {
    return this.XPointerService.createXPointerFromSelection(seln, doc);
}

AnnozillaXPointerUtils.prototype.xptrMarkElement =
function (element) {
    //this.XPointerService.markElement(element);
}

var gAnnozillaXPointerUtils = new AnnozillaXPointerUtils ();
