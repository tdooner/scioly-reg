

function addLoadEvent(func) {
    var oldonload = window.onload;
    if (typeof window.onload != 'function') {
        window.onload = func;
    } else {
        window.onload = function() {
            oldonload();
            func();
        }
    }
}

function prepareMenu() {
  	if (!document.getElementsByTagName) return false;
  	if (!document.getElementById) return false;
  	
  	if (!document.getElementById("topnav")) return false;
  	var topnav = document.getElementById("topnav");
  	
  	var root_li = topnav.getElementsByTagName("li");
  	for (var i = 0; i < root_li.length; i++) {
  	    var li = root_li[i];
  	    var child_ul = li.getElementsByTagName("ul");
  	    if (child_ul.length >= 1) {
  	        li.onmouseover = function () {
  	            if (!this.getElementsByTagName("ul")) return false;
  	            var ul = this.getElementsByTagName("ul");
  	            ul[0].style.display = "block";
  	            return true;
  	        }
  	        li.onmouseout = function () {
  	            if (!this.getElementsByTagName("ul")) return false;
  	            var ul = this.getElementsByTagName("ul");
  	            ul[0].style.display = "none";
  	            return true;
  	        }
  	    }
  	}
  	
  	return true;
}

addLoadEvent(prepareMenu);