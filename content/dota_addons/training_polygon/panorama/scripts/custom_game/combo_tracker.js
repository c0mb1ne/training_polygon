const shardsContainer=$('#ComboContainer')
const animTarget=$('#ComboTextContainer')//this panel is getting animations
const textPanel=$('#ComboDisplay')
let comboText="x10"

/* let test=createShatter(1,shardsContainer) */

 

function createShatter(intNumber,panelContainer){
    let labelContainer=$.CreatePanel('Panel',panelContainer,"shard_"+intNumber.toString())
    labelContainer.AddClass('LabelContainer')
    let labelLabel=$.CreatePanel('Label',labelContainer,"shard_lable_"+intNumber.toString())
    labelLabel.AddClass('ComboLabel')
    labelLabel.text=comboText
    labelContainer.AddClass('piece'+intNumber.toString())
    labelContainer.AddClass('ShatterPiece')
    return labelContainer 
}

function createShatters(panelContainer){
    let pieces = []
    for (let i = 1; i < 49; i++){
        pieces.push(createShatter(i, panelContainer))
    }
    return pieces   // was missing
}

let testpieces = createShatters(shardsContainer)
 
function test(){ 
    $.Msg('test', testpieces.length)
    animateShatters(testpieces)
}
function reset(){
    $.Msg('test', testpieces.length)
    resetShatters(testpieces)
}
function animateShatters(arrPieces){   
    for (const piece of arrPieces){  
        piece.AddClass('Shattered') 
    }
} 
function resetShatters(arrPieces){
    $.Each(shardsContainer.Children(), function( oPanel )
	{
		oPanel.DeleteAsync(0)
	});
    testpieces = createShatters(shardsContainer)
}
/* shardsContainer.style.transform='translate3d(0px, 0px, 0px) rotateZ(0deg) rotatey(0deg)' */
/* shardsContainer.style.transform='translate3d(0px, 0px, 0px) rotateZ(0deg) rotatey(50deg)' */

/* animTarget.style['opacity-mask-scale']="100%" */  
 