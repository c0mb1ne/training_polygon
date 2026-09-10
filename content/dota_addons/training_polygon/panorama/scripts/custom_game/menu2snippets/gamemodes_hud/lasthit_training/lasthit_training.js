$.Msg('lasthit_training menu hud loaded')
GameEvents.SendCustomGameEventToServer (
	"get_lasthit_training_starting_items",
	{
	}
);

function startGame() {
	var errorMsg=$('#errorMsg')

	var selectedLane="";
	$.Each($('#laneSelector').Children(), function(oPanel) {
		if (oPanel.checked) {
			selectedLane=oPanel.id
		}
	})
	var selectedSide="";
	$.Each($('#sideSelector').Children(), function(oPanel) {
		if (oPanel.checked) {
			selectedSide=oPanel.id
		}
	})
    GameEvents.SendCustomGameEventToServer("activate_game_mode",
	{
		gameModeName: "lasthit_training",
		defaultHero: defaultHero,
		selectedLane: selectedLane,
		selectedSide: selectedSide
	});
}

function saveData(data){
    $.Msg(JSON.stringify(data));
	for (let category in data){
		drawCategory(category,data[category])
	}
}
function drawCategory(categoryName,data){
	/* $.Msg(categoryName) */
	let categoryContainer=$.CreatePanel('Panel',$('#startingItemsContainer'),categoryName+'_container')
	categoryContainer.AddClass('ColNoFill')
	let categoryLabel=$.CreatePanel('Label',categoryContainer,categoryName+'_label')
	categoryLabel.text='#'+categoryName
	let iconsContainer=$.CreatePanel('Panel',categoryContainer,categoryName+'_icon_container')
	iconsContainer.AddClass('itemIconContainer')
	for (let itemInd in data){
		drawItemIcon(data[itemInd])
	}
}
function drawItemIcon(itemName){
	$.Msg(itemName)
}
$('#midLane').checked=true; 
$('#direside').checked=true; 
let defaultHero="npc_dota_hero_antimage"
let HeroPicker = CreateHeroPicker($('#heroPickerContainer'), {
	defaultHero: defaultHero,
	onSelect: function(hero) { defaultHero = hero }
})

GameEvents.Subscribe("lasthit_training_spell_table", saveData);
