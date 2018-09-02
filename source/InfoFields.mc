using Toybox.Time as Time;
using Toybox.System as Sys;

class InfoFields {

	var hr;
	var hrN;
	var hrZoneColor;
	
	var userZones;

	function initialize() {
		var profile = UserProfile.getProfile();
        var sport = UserProfile.getCurrentSport();
        userZones = UserProfile.getHeartRateZones(sport);
        
//        for(var i = 0; i < 5; i++) {
//        	System.println("Zone " + (i+1) + ":  " + userZones[i] + " - " + userZones[i+1]);
//        }
	}
	
	function compute(info) {
		hr = toStr(info.currentHeartRate);
		hrN = info.currentHeartRate;
        hrZoneColor = zoneColor(hrN, userZones);
	}
	
	function zoneColor(value, zones) {
		if(value > zones[4]) {
    		return Graphics.COLOR_PURPLE;	//Zone 5
    	} else if(value > zones[3]) {
    		return Graphics.COLOR_BLUE;		//Zone 4
    	} else if(value > zones[2]) {
    		return Graphics.COLOR_GREEN;	//Zone 3
    	} else if(value > zones[1]) {
    		return Graphics.COLOR_ORANGE;	//Zone 2
    	} else if(value > zones[0]) {
    		return Graphics.COLOR_RED;		//Zone 1
    	}
	}
	
	function toPace(speed) {
        if (speed == null || speed == 0) {
            return null;
        }


        var settings = Sys.getDeviceSettings();
        var unit = 1609; // miles
        if (settings.paceUnits == Sys.UNIT_METRIC) {
            unit = 1000; // km
        }
        return unit / speed;
    }
    
    function toDistance(d) {
        if (d == null) {
            return "0.00";
        }

        var dist;
        if (Sys.getDeviceSettings().distanceUnits == Sys.UNIT_METRIC) {
            dist = d / 1000.0;
        } else {
            dist = d / 1609.0;
        }
        return dist.format("%.2f", dist);
    }
    
    function toStr(o) {
        if (o != null) {
            return "" + o;
        } else {
            return "---";
        }
    }

    function fmtSecs(secs) {
        if (secs == null) {
            return "--:--";
        }

        var s = secs.toLong();
        var hours = s / 3600;
        s -= hours * 3600;
        var minutes = s / 60;
        s -= minutes * 60;
        var fmt;
        if (hours > 0) {
            fmt = "" + hours + ":" + minutes.format("%02d");
        } else {
            fmt = "" + minutes + ":" + s.format("%02d");
        }

        return fmt;
    }

    function fmtTime(clock) {
        var h = clock.hour;
        if (!Sys.getDeviceSettings().is24Hour) {
            if (h > 12) {
                h -= 12;
            } else if (h == 0) {
                h += 12;
            }
        }
        return "" + h + ":" + clock.min.format("%02d");
    }
       
}