using Toybox.WatchUi;

class iRunView extends WatchUi.DataField {

	function initialize() {
	}
    
	// Set your layout here. Anytime the size of obscurity of
    // the draw context is changed this will be called.
  	function onLayout(dc) {
	  	DataField.initialize();
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
        
        drawLayout(dc);
        return true;
	}
	
   	// The given info object contains all the current workout information.
    // Calculate a value and save it locally in this method.
    // Note that compute() and onUpdate() are asynchronous, and there is no
    // guarantee that compute() will be called before onUpdate().
    function compute(info) {
        // See Activity.Info in the documentation for available information.
        return 0.0;
    }
    
   

}