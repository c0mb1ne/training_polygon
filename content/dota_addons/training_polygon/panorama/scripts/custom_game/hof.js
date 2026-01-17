var playerID=Players.GetLocalPlayer()


function checkForSelecting(interval) {
	function checking() {
		var selectedUnits = Players.GetSelectedEntities(playerID)
		$.Msg(selectedUnits)
		$.Schedule(interval, checking)
	}
	checking();
}

checkForSelecting(0.5)