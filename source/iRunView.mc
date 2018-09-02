using Toybox.WatchUi;

class iRunView extends WatchUi.DataField {
	hidden var fields;
	
	function initialize() {
	  	DataField.initialize();
	  	fields = new InfoFields();
    }
    
	// Set your layout here. Anytime the size of obscurity of
    // the draw context is changed this will be called.
  	function onLayout(dc) {
	}
    
	function drawLayout(dc) {
        dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_WHITE);
        // horizontal lines
        dc.drawLine(0, 71, 218, 71);
        dc.drawLine(0, 132, 218, 132);
        dc.drawLine(0, 198, 218, 198);
        // vertical lines
        dc.drawLine(109, 0, 109, 71);
        dc.drawLine(65, 71, 65, 132);
        dc.drawLine(153, 71, 153, 132);
        dc.drawLine(109, 132, 109, 198);
    }

    function onUpdate(dc) {
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_WHITE);
        dc.clear();
        
        doHrBackground(dc, fields.hrN);
        textC(dc, 112, 107, Graphics.FONT_NUMBER_MEDIUM, fields.hr);
        textC(dc, 112, 79,  Graphics.FONT_XTINY,  	     "HR");
        
        drawLayout(dc);
        return true;
	}
	
	function doHrBackground(dc, hr) {
        if (hr == null) {
            return;
        }

        var color;
        if (hr >= 186) {
            color = Graphics.COLOR_PURPLE;
        } else if (hr > 177) {
            color = Graphics.COLOR_RED;
        } else if (hr > 140) {
            color = Graphics.COLOR_ORANGE;
        } else if (hr > 135) {
            color = Graphics.COLOR_YELLOW;
        } else if (hr > 116) {
            color = Graphics.COLOR_GREEN;
        } else {
            color = Graphics.COLOR_BLUE;
        }

        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(66, 72, 87, 61);
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
    }
	
   	// The given info object contains all the current workout information.
    // Calculate a value and save it locally in this method.
    // Note that compute() and onUpdate() are asynchronous, and there is no
    // guarantee that compute() will be called before onUpdate().
    function compute(info) {
        // See Activity.Info in the documentation for available information.
        fields.compute(info);
        return 1;
    }
    
    function textL(dc, x, y, font, s) {
        if (s != null) {
            dc.drawText(x, y, font, s, Graphics.TEXT_JUSTIFY_LEFT|Graphics.TEXT_JUSTIFY_VCENTER);
        }
    }

    function textC(dc, x, y, font, s) {
        if (s != null) {
            dc.drawText(x, y, font, s, Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
        }
    }

    function textR(dc, x, y, font, s) {
        if (s != null) {
            dc.drawText(x, y, font, s, Graphics.TEXT_JUSTIFY_RIGHT|Graphics.TEXT_JUSTIFY_VCENTER);
        }
    }

}