	function navInit() {
		var navContainer = dojo.byId("nav");

		for (var i=0; i<navContainer.childNodes.length; i++) {
			if (navContainer.childNodes[i].nodeName == "LI") {
				var navLi = navContainer.childNodes[i];
				navLi.onmouseover = function() {
						this.className = this.className.concat(" over");
					}

				navLi.onmouseout = function() {
						this.className = this.className.replace(/\sover/, "");
						this.className = this.className.replace(/over/, "");
			    }
			}
		}
	}
	
	dojo.addOnLoad(navInit);
