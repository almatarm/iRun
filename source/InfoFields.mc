using Toybox.Time as Time;
using Toybox.System as Sys;

class InfoFields {
	
	// last 60 seconds - 'current speed' samples
    hidden var lastSecs = new [60];
    hidden var curPos;
    hidden var mPreviousTimer;

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
    
    var calories;
    
    
    var alertLabel;
    var alertValue;
    
    var calAlert  = null;
    var distAlert = null;
    
    var alertTime;
	var alertType;
	var calAlertFreq  = 50;
	var distAlertFreq = 1000; // meter 
	
	var userZones;
	var cadenceZones = [144, 153, 164, 174, 183, 200];
	  
	  
	var workout = null;
//    	"#F720#T600&HZ4%Warm up#R5%Repeat 5 Times#T120&HZ4%Run#T60&HZ2%Rest#T60&HZ4%Run#T90&HZ2%Rest#E#%Cool down"; 
//    	"#T10%Warm Up#T9&HZ3#T5%Rest#T5%Cool Down#";
//    	"#T120&HZ1%Hello#";
//		"#T07%Startup#R3#T05%Run#T05%Rest#E#T10%Cool Down#";
    
	var inWktStep = false;
    var wktPtr = 0;
    
    var wktDuration = null;
    var wktDurationN = null;
    var wktMsg = null;
    var wktMsgColor = Graphics.COLOR_TRANSPARENT;
    var wktMsgPostTime = null;
    var wktMinHR = null;
    var wktMaxHR = null;
    var wktRepeat = null;
    var wktCurrentRepeat = null;
    var wktRepeatStartPtr = null;
    var wktFullTime = null;
    var wktEndTime = null;
	  
	function initialize() {
		var profile = UserProfile.getProfile();
        var sport 	= UserProfile.getCurrentSport();
        userZones   = UserProfile.getHeartRateZones(sport);
        
        counter = 0;
        alertTime = 0;
        
        for (var i = 0; i < lastSecs.size(); ++i) {
            lastSecs[i] = 0.0;
        }
        curPos = 0;
        
        workout = Application.getApp().getProperty("workout");
        
//        for(var i = 0; i < 5; i++) {
//        	System.println("Zone " + (i+1) + ":  " + userZones[i] + " - " + userZones[i+1]);
//        }
	}
	
	function compute(info) {
		var status = getActivityStatus(info);
		if (status == 0) { return; } //Activity paused
		
		counter++;
		if(counter - alertTime > 3) {
			alertLabel = null;
			if(alertType == 1) {
				calAlert = null;
			} else if (alertType == 2) {
				distAlert = null;
			}
		}
		
		//Pace
       	if (info.currentSpeed != null && info.currentSpeed > 0) {
        	var idx = curPos % lastSecs.size();
            curPos++;
            lastSecs[idx] = info.currentSpeed;
       	}
		var avg10s = getNAvg(lastSecs, curPos, 10);
        pace10s =  fmtSecs(toPace(avg10s));
        paceAvg = fmtSecs(toPace(info.averageSpeed));
        
        //Timer
        var elapsed = info.timerTime;
        var elapsedSecs = null;
        if (elapsed != null) {
            elapsed /= 1000;

            if (elapsed >= 3600) {
                elapsedSecs = (elapsed.toLong() % 60).format("%02d");
            }
        }

        timer = fmtSecs(elapsed);
        timerSecs = elapsedSecs;

		//Time
        time = fmtTime(Sys.getClockTime());
        wktEndTime = fmtTime(Sys.getClockTime());
        		
        //HR	
		hr = toStr(info.currentHeartRate);
		hrN = info.currentHeartRate;
        hrZoneColor = zoneColor(hrN, userZones);
        hrZone = zoneNumber(hrN, userZones).format("%.1f");
        
        //Cadence
        cadence = toStr(info.currentCadence);
        cadenceN = info.currentCadence;
        cadenceZoneColor = zoneColor(cadenceN, cadenceZones);
        
        //Distance
        distance = toDistanceStr(info.elapsedDistance);
        
        //Calories
        calories = info.calories;
        
        //Alerts
        if(calories != null && calories != 0 
        	&& calories % calAlertFreq == 0 
        	&& counter - alertTime > 10) {  	
        	calAlert = calories;
        	alertTime = counter;
        } else if(info.elapsedDistance != null && info.elapsedDistance > 10
        	&& info.elapsedDistance.toNumber() % distAlertFreq < 6 
        	&& counter - alertTime > 10) {
        	distAlert = distance;
        	alertTime = counter;
    	}
    	
    	if(calAlert != null) {
    		alertLabel = "CALORIES";
    		alertValue = calAlert;
    		alertType  = 1; 
    	} else if(distAlert != null) {
    		alertLabel = "DISTANCE";
    		alertValue = distAlert;
    		alertType  = 2;
    	}
    	
    	if(workout != null && workout.length() > 0) {
    		processWorkout(info, status);
    	}
    }
    
    function processWorkout(info, status) {
    	if(status != 1) { 
    		return; // Return if not running
    	}
    	
//    	if(wktFullTime == null) {
//    		wktFullTime = computeWorkoutFullTime();
//    	}
    	
    	if(wktMsgPostTime != null && info.elapsedTime - wktMsgPostTime > 3000) {
    		wktMsg = null;
    	}
    	
    	if(wktDurationN != null) {
    		if(wktFullTime != null) { wktFullTime--;}
    		wktDurationN--;
    		wktDuration = fmtSecs(wktDurationN);
    		if(wktDurationN == 0) {
    			wktDurationN = null;
    			wktDuration  = null;
    			wktMinHR = null;
    			wktMaxHR = null;
    			inWktStep = false;
    		}
    	}
    	
    	if(wktMinHR != null && info.currentHeartRate < wktMinHR
    		&& info.elapsedTime - wktMsgPostTime > 20000) {
    		wktMsg = "Below HR\n+" + ( wktMinHR - info.currentHeartRate ).format("%d");
    		wktMsgColor = Graphics.COLOR_YELLOW;
    		wktMsgPostTime = info.elapsedTime;
    	}
    	
    	if(wktMaxHR != null && info.currentHeartRate > wktMaxHR 
    		&& info.elapsedTime - wktMsgPostTime > 20000) {
    		wktMsg = "Above HR\n" + (info.currentHeartRate - wktMinHR ).format("%d");
    		wktMsgColor = Graphics.COLOR_YELLOW;
    		wktMsgPostTime = info.elapsedTime;
    	}
    	
    	var curWktStep = null;
    	if(!inWktStep) {
    		var nextStepPtr = workout.substring(wktPtr + 1, workout.length()).find("#");
    		nextStepPtr = nextStepPtr == null ? workout.length() : nextStepPtr + wktPtr + 1;
    		curWktStep = workout.substring(wktPtr, nextStepPtr);
    		wktPtr = nextStepPtr;		
    	}
    	
    	if( curWktStep != null && curWktStep.length() > 0) {
    		if(curWktStep.length() == 1) {
    			wktMsg = "Workout Ended!";
    			wktMsgColor = Graphics.COLOR_GREEN;
    			wktMsgPostTime = info.elapsedTime;
    			return;
    		} 
    		
    		wktMsg = curWktStep.find("%") != null ? curWktStep.substring(curWktStep.find("%") + 1, curWktStep.length()) : "";
//    		wktMsg = curWktStep.substring(curWktStep.find("%") + 1, curWktStep.length());
    		
    		curWktStep = curWktStep.find("%") != null ? curWktStep.substring(0, curWktStep.find("%")) : curWktStep;
    		
    		while(curWktStep.length() != 0) {
    			curWktStep = curWktStep.substring(1, curWktStep.length());
    			var cond = curWktStep.substring(0, curWktStep.find("&") == null ?
    				curWktStep.length() : curWktStep.find("&"));
    			
    			
    			//FullTime
    			if(cond.substring(0,1).equals("F")) {
    				wktFullTime = cond.substring(1, cond.length()).toNumber();
    				inWktStep = false;
    			}
    			
    			//Duration	
    			if(cond.substring(0,1).equals("T")) {
    				wktDurationN = cond.substring(1, cond.length()).toNumber();
    				wktMsg += "\n" + fmtSecs(wktDurationN);
    				inWktStep = true;
    			}
    			
    			//Heart Rate
    			if(cond.substring(0,1).equals("H")) {
    				if(cond.substring(1,2).equals("Z")) { //Zoned Heart Rate
    					var zone = cond.substring(2,3).toNumber();
    					wktMinHR = userZones[zone -1];
    					wktMaxHR = userZones[zone];
    					wktMsg += "\n Zone " + zone.format("%d");
    				}
    				inWktStep = true;
    			}
    			
    			if(cond.substring(0,1).equals("R")) {
    				wktRepeat = cond.substring(1,cond.length()).toNumber();
    				wktCurrentRepeat = 1;
    				wktRepeatStartPtr = wktPtr;
    				wktMsg = null;    				
    				inWktStep = false;
    			}
    			
    			if(cond.substring(0,1).equals("E")) {
    				if(wktCurrentRepeat != wktRepeat) {
    					wktCurrentRepeat++;
    					wktPtr = wktRepeatStartPtr;
    				} else {
    					wktRepeat = null;
    				}
    				inWktStep = false;
    			}
    			
    			curWktStep  = curWktStep.substring(cond.length(), curWktStep.length());
    			wktMsgColor = Graphics.COLOR_DK_GRAY;
    		}	
    		wktMsgPostTime = info.elapsedTime;
    	}
    }
    
//    function computeWorkoutFullTime() {
//    	var fullTime = 0;
//    	var wktPtr = 0;
//    	var repeatFactor = null;
//    	var repeatTime = 0;
//    	var curWktStep = null;
//    	var nextStepPtr = null;
//    	
//    	do {
//    		nextStepPtr = workout.substring(wktPtr + 1, workout.length()).find("#");
//    		nextStepPtr = nextStepPtr == null ? workout.length() : nextStepPtr + wktPtr + 1;
//    		curWktStep = workout.substring(wktPtr, nextStepPtr);
//    		wktPtr = nextStepPtr;
//    		
//    		curWktStep = curWktStep.find("%") != null ? curWktStep.substring(0, curWktStep.find("%")) : curWktStep;
//    		
//    		while(curWktStep.length() != 0) {
//    			curWktStep = curWktStep.substring(1, curWktStep.length());
//    			var cond = curWktStep.substring(0, curWktStep.find("&") == null ?
//    				curWktStep.length() : curWktStep.find("&"));
//    			
//    			//Duration	
//    			if(cond.substring(0,1).equals("T")) {
//    				if(repeatFactor == null) {
//    					fullTime += cond.substring(1, cond.length()).toNumber();
//    				} else {
//						repeatTime += cond.substring(1, cond.length()).toNumber();
//    				}
//    			}
//    			
//    			if(cond.substring(0,1).equals("R")) {
//    				repeatFactor = cond.substring(1,cond.length()).toNumber();
//    				repeatTime = 0;
//    			}
//    			
//    			if(cond.substring(0,1).equals("E")) {
//    				fullTime += repeatFactor * repeatTime;
//    				repeatFactor = null;
//    			}    			
//    		}	
//    	} while (wktPtr < workout.length() );
//    	return fullTime;
//    }
	
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
    	
    	return Graphics.COLOR_TRANSPARENT;
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
        var dist;
        if (Sys.getDeviceSettings().distanceUnits == Sys.UNIT_METRIC) {
            dist = d / 1000.0;
        } else {
            dist = d / 1609.0;
        }
        return dist;        
    }
    
    function toDistanceStr(d) {
        if (d == null) {
            return "0.00";
        }
        var dist = toDistance(d);
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
    
    // -1: Did not start
    //  0: pause
    //  1: Running
    function getActivityStatus(info) {
        var currentTimer = info.timerTime;
        var status = ( currentTimer == null || currentTimer == 0) ? -1 : 
        	mPreviousTimer == null ? 1 : 
        	mPreviousTimer != currentTimer? 1 :
        	0;  
        mPreviousTimer = currentTimer;
        return status;    	
    } 
    
       
}