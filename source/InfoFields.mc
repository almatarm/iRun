using Toybox.Time as Time;
using Toybox.System as Sys;

class InfoFields {
	
	// last 60 seconds - 'current speed' samples
    hidden var lastSecs = new [60];
    hidden var curPos;

	var counter;
	
	var hr;
	var hrZone;
	var hrN;
	var hrZoneColor;
	
	var cadence;
    var cadenceN;
    var cadenceZoneColor;
    
	var distance;
	
	var timer;
    var timerSecs;
    var pace10s;
    var paceAvg;
    var time;
    
	var userZones;
	var cadenceZones = [144, 153, 164, 174, 183, 200];

	function initialize() {
		var profile = UserProfile.getProfile();
        var sport = UserProfile.getCurrentSport();
        userZones = UserProfile.getHeartRateZones(sport);
        
        counter = 0;
        
        for (var i = 0; i < lastSecs.size(); ++i) {
            lastSecs[i] = 0.0;
        }
        curPos = 0;
        
//        for(var i = 0; i < 5; i++) {
//        	System.println("Zone " + (i+1) + ":  " + userZones[i] + " - " + userZones[i+1]);
//        }
	}
	
	function compute(info) {
		counter++;
		
       if (info.currentSpeed != null && info.currentSpeed > 0) {
            var idx = curPos % lastSecs.size();
            curPos++;
            lastSecs[idx] = info.currentSpeed;
        }

        var avg10s = getNAvg(lastSecs, curPos, 10);
        var elapsed = info.elapsedTime;
        var elapsedSecs = null;

        if (elapsed != null) {
            elapsed /= 1000;

            if (elapsed >= 3600) {
                elapsedSecs = (elapsed.toLong() % 60).format("%02d");
            }
        }

        timer = fmtSecs(elapsed);
        timerSecs = elapsedSecs;
        pace10s =  fmtSecs(toPace(avg10s));
        paceAvg = fmtSecs(toPace(info.averageSpeed));
        time = fmtTime(Sys.getClockTime());        
        		
        		
		hr = toStr(info.currentHeartRate);
		hrN = info.currentHeartRate;
        hrZoneColor = zoneColor(hrN, userZones);
        hrZone = zoneNumber(hrN, userZones).format("%.1f");
        
        cadence = toStr(info.currentCadence);
        cadenceN = info.currentCadence;
        cadenceZoneColor = zoneColor(cadenceN, cadenceZones);
        
        distance = toDistance(info.elapsedDistance);
    }
	
	function zoneColor(value, zones) {
		if(value == null) {
			return Graphics.COLOR_TRANSPARENT;
		}
		
		if(value > zones[4]) {
    		return Graphics.COLOR_PURPLE;	//Zone 5
    	} else if(value > zones[3]) {
    		return Graphics.COLOR_RED;		//Zone 4
    	} else if(value > zones[2]) {
    		return Graphics.COLOR_ORANGE;	//Zone 3
    	} else if(value > zones[1]) {
    		return Graphics.COLOR_GREEN;	//Zone 2
    	} else if(value > zones[0]) {
    		return Graphics.COLOR_BLUE;		//Zone 1
    	}
	}
	
    function zoneNumber(value, zones) {
    	if(value == null) { return 0; }
    	var subValue = 0;
    	if(value > zones[5]) {
    		return 6;
    	}
    	
    	for(var i = 4; i >=0; i--) {
    		if(value > zones[i]) {
    			var zone = i + 1;
    			var range =  zones[i + 1] - zones[i];
    			var subValue = (value - zones[i]) * 1.00 / range;
    			return zone + subValue;
			}
    	}
		return 0;    	     
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
        return dist.format("%.2f");
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
    
        function getAverage(a) {
        var count = 0;
        var sum = 0.0;
        for (var i = 0; i < a.size(); ++i) {
            if (a[i] > 0.0) {
                count++;
                sum += a[i];
            }
        }
        if (count > 0) {
            return sum / count;
        } else {
            return null;
        }
    }

    function getNAvg(a, curIdx, n) {
        var start = curIdx - n;
        if (start < 0) {
            start += a.size();
        }
        var count = 0;
        var sum = 0.0;
        for (var i = start; i < (start + n); ++i) {
            var idx = i % a.size();
            if (a[idx] > 0.0) {
                count++;
                sum += a[idx];
            }
        }
        if (count > 0) {
            return sum / count;
        } else {
            return null;
        }
    }
    
       
}