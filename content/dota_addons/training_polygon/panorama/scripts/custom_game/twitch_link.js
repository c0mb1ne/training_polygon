var twitch=$.GetContextPanel().GetAttributeString("twitch", "")
$('#link').text=twitch
var live=$.GetContextPanel().GetAttributeString("live", "")
if (live=="live"){
	$('#redC').style['visibility']='visible;'
	$('#liveL').style['visibility']='visible;'
	$.GetContextPanel().AddClass("liveAnim")

}