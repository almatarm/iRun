using Toybox.WatchUi;
using Toybox.Attention as Attn;

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
        dc.drawLine(0,  72, 218,  72);
        dc.drawLine(0, 132, 218, 132);
        dc.drawLine(0, 198, 218, 198);
        
        // vertical lines
        dc.drawLine(109,  0,  109,  72);
        dc.drawLine( 72,  72,  72, 132);
        dc.drawLine(144,  72, 144, 132);
        dc.drawLine(109, 132, 109, 198);    
    }

    function onUpdate(dc) {
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_WHITE);
        dc.clear();
        
        //Cadence
        drawBackground(dc, fields.cadenceZoneColor, 00, 73, 72, 60);
        textC(dc, 36, 107, Graphics.FONT_NUMBER_MEDIUM, fields.cadence);
        textC(dc, 36, 79, Graphics.FONT_XTINY,  "CAD");
                
        //HR
		drawBackground(dc, fields.hrZoneColor, 145, 73, 73, 60);
        textC(dc, 180, 107, Graphics.FONT_NUMBER_MEDIUM, 
        	fields.counter % 3 == 0 ? fields.hr : fields.hrZone);
        textC(dc, 180, 79,  Graphics.FONT_XTINY,  	     "HR");
        
        //Distance 
        textC(dc, 66, 154, Graphics.FONT_NUMBER_MEDIUM, fields.distance);
        textR(dc, 105, 186, Graphics.FONT_XTINY, 
    		System.getDeviceSettings().distanceUnits == System.UNIT_METRIC? "km" : "mi");
        
        //Calories
        if(fields.wktDuration == null) {
			textL(dc, 36, 45, Graphics.FONT_NUMBER_MEDIUM,  fields.calories);
	        textL(dc, 55, 18, Graphics.FONT_XTINY,  "CAL");
        } else {
        	if(fields.counter % 3 == 0 && fields.wktFullTime != null) {
		        textL(dc, 36, 45, Graphics.FONT_NUMBER_MEDIUM,  InfoFields.fmtSecs(fields.wktFullTime));
		        textL(dc, 55, 18, Graphics.FONT_XTINY,  "F TIM");
		        
	        } else {
		        textL(dc, 36, 45, Graphics.FONT_NUMBER_MEDIUM,  fields.wktDuration);
		        textL(dc, 55, 18, Graphics.FONT_XTINY,  "I TIM");
	        }
        } 
        
		//Timer
		textL(dc, 112, 45, Graphics.FONT_NUMBER_MEDIUM,  fields.timer);
        if (fields.timerSecs != null) {
            var length = dc.getTextWidthInPixels(fields.timer, Graphics.FONT_NUMBER_MEDIUM);
            textL(dc, 112 + length + 1, 55, Graphics.FONT_NUMBER_MILD, fields.timerSecs);
        }
        textL(dc, 120, 18, Graphics.FONT_XTINY,  "TIMER");
        
        //Pace
        textC(dc, 109, 107, Graphics.FONT_NUMBER_MEDIUM, fields.pace10s);
        textC(dc, 109,  79, Graphics.FONT_XTINY,  		 "PACE");
		
		//Average Pace
		textC(dc, 150, 154, Graphics.FONT_NUMBER_MEDIUM, fields.paceAvg);
        textL(dc, 124, 186, Graphics.FONT_XTINY, "A PACE");

		//Time
        textL(dc, 75, 206, Graphics.FONT_TINY, fields.time);        

        drawBattery(dc);
        drawLayout(dc);

		if(fields.alertLabel != null) {
			alert(dc, fields.alertLabel, fields.alertValue);
		}  
		
		if(fields.wktMsg != null) {
			workoutMessage(dc, fields.wktMsg, fields.wktMsgColor);
			if(fields.wktRepeat != null) {
				textC(dc, 109,  45, Graphics.FONT_TINY, 
					"Repeat " + fields.wktCurrentRepeat.format("%d") + "/" + fields.wktRepeat.format("%d"));
			}
		}
		
        return true;
	}
	
	function drawBackground(dc, color, x, y, w, h) {
		if (color == null) { return; }
		dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(x, y, w, h);
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
	}
	
	function drawBackgroundCircle(dc, color, x, y, r) {
		if (color == null) { return; }
		dc.setColor(color, Graphics.COLOR_TRANSPARENT);
		dc.fillCircle(x, y, r);
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
	}
		
	function alert(dc, label, value) {
		if (Attention has :backlight) {
 		   Attention.backlight(true);
		}
		
		if (Attention has :playTone && System.getTimer() %4 == 0 ) {
		   Attention.playTone(Attention.TONE_LOUD_BEEP);
		}
		
		drawBackgroundCircle(dc, Graphics.COLOR_DK_GRAY, 109, 109, 109);
		drawBackgroundCircle(dc, Graphics.COLOR_BLUE,    109, 109, 107);
		drawBackgroundCircle(dc, Graphics.COLOR_DK_GRAY, 109, 109, 92);
		drawBackgroundCircle(dc, Graphics.COLOR_WHITE,   109, 109, 90);
		textC(dc, 109, 120, Graphics.FONT_NUMBER_THAI_HOT, value);
        textC(dc, 109,  65, Graphics.FONT_TINY,  	  	   label);
	}
	
	function workoutMessage(dc, message, borderColor) {
		if (Attention has :backlight) {
 		   Attention.backlight(true);
		}
		
		if (Attention has :playTone && System.getTimer() %3 == 0) {
			
		   Attention.playTone(Attention.TONE_LOUD_BEEP);
		}
		
		drawBackgroundCircle(dc, Graphics.COLOR_DK_GRAY, 109, 109, 109);
		drawBackgroundCircle(dc, borderColor,   		 109, 109, 107);
		drawBackgroundCircle(dc, Graphics.COLOR_DK_GRAY, 109, 109, 92);
		drawBackgroundCircle(dc, Graphics.COLOR_WHITE,   109, 109, 90);
		textC(dc, 109, 120, Graphics.FONT_MEDIUM, message);
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
    
    function drawBattery(dc) {
        var pct = System.getSystemStats().battery;
        dc.drawRectangle(120, 202, 18, 11);
        dc.fillRectangle(138, 205, 2, 5);

        var color = Graphics.COLOR_GREEN;
        if (pct < 25) {
            color = Graphics.COLOR_RED;
        } else if (pct < 40) {
            color = Graphics.COLOR_YELLOW;
        }
        dc.setColor(color, Graphics.COLOR_TRANSPARENT);

        var width = (pct * 16.0 / 100 + 0.5).toLong();
        if (width > 0) {
            //Sys.println("" + pct + "=" + width);
            if (width > 16) {
                width = 16;
            }
            dc.fillRectangle(121, 203, width, 9);
        }
    }
    

}