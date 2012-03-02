function openWindow(adr, target) {
	overview = window.open(adr,target,"").focus();
    return false;
}

function showMetadata(show) {
	// show or hide option div
	var elem = getElement("metadata");
	showElement(elem, show);
}
      		
function showInfo(show)  {
	// show or hide option div
	var elem =getElement("infos");
	showElement(elem, show);
}

function showInfo1(show)  {
	// show or hide option div
	var elem =getElement("infos1");
	showElement(elem, show);
}

function showSearch(show) {
	// show or hide option div
	var elem = getElement("search");
	showElement(elem, show);
}

function showLogIn(show) {
	// show or hide option div
	var elem = getElement("login");
	showElement(elem, show);
}

function annotateWholePage(show) {
	// show or hide option div
	var elem = getElement("annotateWhole");
	showElement(elem, show);
}

function annotateMultiplePage(show) {
	// show or hide option div
	var elem = getElement("annotateMultiple");
	showElement(elem, show);
}

function showSignUp(show) {
	// show or hide option div
	var elem = getElement("signup");
	showElement(elem, show);
}


function go(characterNormalization) {
	window.location.href = characterNormalization;
}

function GetSelectedItem() {
	chosen = "";
	len = document.f1.r1.length;
	for (i = 0; i <len; i++) {
		if (document.f1.r1[i].checked) {
			chosen = document.f1.r1[i].value;
		}
     }
	window.location=chosen;
}

function GetSelectedItem1() {
	chosen = "";
	len = document.f2.r2.length;
	for (i = 0; i <len; i++) {
		if (document.f2.r2[i].checked) {
			chosen = document.f2.r2[i].value;
		}
	}
	window.location=chosen;
} 
      		
function getBrowserType1() {
	var bt;
	if (navigator.userAgent.indexOf('Firefox') != -1) {
		if (/Firefox[\/\s](\d+\.\d+)/.test(navigator.userAgent)) {
			var ffversion=new Number(RegExp.$1)
			if (ffversion>=3.6) {
				bt=  "3.6";
			}else if (ffversion>=3.5) {
				bt="3.5";
			}
		}
	}else if (navigator.userAgent.indexOf('MSIE') != -1) {
		if (/MSIE (\d+\.\d+);/.test(navigator.userAgent)) {
   			var ieversion=new Number(RegExp.$1)
   			if (ieversion>=8){
   				bt= "IE8";
   			}else if (ieversion>=7) {
   				bt="IE7";
            }
   		}	
     }else if (navigator.userAgent.indexOf('Opera') != -1) {
            	bt ="OPERA";
     }else if (navigator.userAgent.indexOf('Safari') != -1) {
            	bt ="SAFARI";
     }else if (navigator.userAgent.indexOf('Chrome') != -1) {
            	bt ="SAFARI";
     }else
            	bt= "n/a";
            
     if (bt=="IE8") {
         		document.write('<link media="screen" rel="stylesheet" href="template/docuviewer_css_IE8" type="text/css"/>');
     }
}

function getAufloesung() {
	var screenW = 1024;
	if (parseInt(navigator.appVersion)>3) {
		screenW = screen.width;
 	}else if (navigator.appName == "Netscape" && parseInt(navigator.appVersion)==3 && navigator.javaEnabled()) {
		var jToolkit = java.awt.Toolkit.getDefaultToolkit();
		var jScreenSize = jToolkit.getScreenSize();
 		screenW = jScreenSize.width;
 	}if (screenW <= 1024) {	
		document.write('<link media="screen" rel="stylesheet" href="template/docuviewer_css" type="text/css">');	
    }else {
		document.write('<link media="screen" rel="stylesheet" href="template/docuviewerBig_css" type="text/css">');
	}
}


function fontSize(s) {
	var p = document.getElementsByClassName('pageContent');
	for(i=0;i<p.length;i++) {
		if(p[i].style.fontSize) {
			var s;
		} else {
			var s;
		}		        
		p[i].style.fontSize = s+"px"
	}
	$.cookie('TEXT_SIZE',s, { path: '/', expires: 10000 }); 
}

function montre(id)	{
	with (document)	{
	if (getElementById)
		getElementById('smenu').style.display = 'block';
	else if (all)
		all[id].style.display = 'block';
	else
		layers[id].display = 'block';
	}
}

function cache(id)	{
	with (document)	{
	if (getElementById)
		getElementById('smenu').style.display = 'none';
	else if (all)
		all[id].style.display = 'none';
	else
		layers[id].display = 'none';
	}
}
		    
function dictionaryView() {
	jQuery('a.textPollux').live('click', function()	{
		newwindow=window.open($(this).attr('href'),'','menubar=no, location,width=500,height=600,top=180, left=700, toolbar=no, scrollbars=1');
		if (window.focus) { 
			newwindow.focus(); 
		}
		return false;});
}
		    
function dictionaryView1() {
	//window.location.reload();
}      		