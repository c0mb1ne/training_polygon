$.Msg('lasthit_training menu hud loaded')


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
		drawItemIcon(data[itemInd],iconsContainer)
	}
}
function drawItemIcon(item,parentPanel){
	let itemName = item.item_name;
    let price = item.price;
	let icon=$.CreatePanel('DOTAAbilityImage',parentPanel,'icon_'+itemName)
	icon.abilityname=itemName
	icon.AddClass('itemIcon')
	icon.SetPanelEvent(
    "onmouseover",
		function() {
			$.DispatchEvent("DOTAShowAbilityTooltip", icon, itemName);
		}
	)
	icon.SetPanelEvent(
		"onmouseout",
		function() {
			$.DispatchEvent("DOTAHideAbilityTooltip", icon);
		}
	)
	startBuyController.RegisterShopItem(icon,price)
	/* $.Msg(itemName) */
}
let startBuyController = {
	itemMap: {},
	buyDisplayPanel: null,
	buyDisplayArray: [],
	maxBudget: 0,
	currentBudget: 0,
	budgetDisplayPanel: null,
	Init: function(){
		this.buyDisplayPanel=$('#boughtItems')
		this.maxBudget=700
		this.currentBudget=this.maxBudget
		this.budgetDisplayPanel=$('#budgetDisplay')
		this.budgetDisplayPanel.text=this.currentBudget
	},
	RegisterShopItem: function(panel,price){
		this.itemMap[panel.abilityname]={itemPanel:panel,price:price}
		this.RefreshAvailability(panel)
		panel.SetPanelEvent(
        "onactivate",
			() => {
				this.BuyItem(panel)
			}
		)
	},
	GetPanelPrice: function(panel){
		return this.itemMap[panel.abilityname].price
	},
	GetNamePrice: function(item_name){
		return this.itemMap[item_name].price
	},
	RefreshAvailability: function(panel){
		let price=this.GetPanelPrice(panel)
		if (price<=this.currentBudget){
			panel.AddClass('availableItem')
		}else{
			panel.RemoveClass('availableItem')
		}
	},
	CreateBoughtIcon: function(item_name){
		let bougthIcon=$.CreatePanel('DOTAAbilityImage',this.buyDisplayPanel,'icon_b_'+item_name)
		bougthIcon.abilityname=item_name
		bougthIcon.AddClass('boughtItemIcon')
		bougthIcon.SetPanelEvent(
        "onactivate",
			() => {
				this.SellItem(bougthIcon)
			}
		)
	},
	BuyItem: function(panel){
		let item_name=panel.abilityname
		let price=this.GetPanelPrice(panel)
		if (price<=this.currentBudget){
			this.currentBudget=this.currentBudget-price
			this.CreateBoughtIcon(item_name)
			//add price refresh here
			//add buy sound
		}else{
			//add error sound 
		}
		this.UpdateBudget()
	},
	SellItem: function(panel){
		let price=this.GetPanelPrice(panel)
		this.currentBudget=this.currentBudget+price
		panel.DeleteAsync(0)
		this.UpdateBudget()
	},
	UpdateBudget: function(){
		this.budgetDisplayPanel.text=this.currentBudget
		this.UpdateAvailability()
	},
	UpdateAvailability: function(){
		Object.values(this.itemMap).forEach(entry => {
			this.RefreshAvailability(entry.itemPanel)
		})
	}
}
startBuyController.Init()
$('#midLane').checked=true; 
$('#direside').checked=true; 
let defaultHero="npc_dota_hero_antimage"
let HeroPicker = CreateHeroPicker($('#heroPickerContainer'), {
	defaultHero: defaultHero,
	onSelect: function(hero) { defaultHero = hero }
})

GameEvents.SendCustomGameEventToServer (
	"get_lasthit_training_starting_items",
	{
	}
);


GameEvents.Subscribe("lasthit_training_spell_table", saveData);
