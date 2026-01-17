var publish_url = "http://combine.pro.host1530666.serv66.hostland.pro/training.php";
var dev_url = 'http://training/training.php';
mainPanel = $("#lalka").GetParent()
getLeaderBoardData('s')

function alonahui(asd) {
	anus = $("#anus")
}

function getLeaderBoardData(asda){
	$.AsyncWebRequest (
		publish_url + '?leaderboard=1',
        {
            type: 'GET',
            success: function (data) { 
                leaderData = JSON.parse(data)
                makeLeaderBoard(leaderData)
                $.Msg('nice')
            }
        }
	);
}

function refreshLeaderBoardData(asda){
	$.AsyncWebRequest (
		publish_url+'?leaderboard=1',
        {
            type: 'GET',
            success: function (data) {
                leaderData = JSON.parse(data)
                refreshLeaderBoard(leaderData)
                $.Msg('nice')
            }
        }
	);
}

function makeLeaderPos(steam,score,num){
	var Pos = $.CreatePanel('Panel', mainPanel, 'pos_num_' + num)
	Pos.AddClass("leaderboardPos")
	var numPanel = $.CreatePanel('Label', Pos, 'num_' + num)
	numPanel.text = num
	numPanel.AddClass("posNum")
	var avatar = $.CreatePanel('DOTAAvatarImage', Pos, 'avatar_' + num)
	avatar.steamid = steam
	var desc = $.CreatePanel('Panel', Pos, 'desc_' + num)
	desc.AddClass("leaderboardDesc")
	var score_text = $.CreatePanel('Label', desc, 'score_label' + num)
	score_text.text = 'Score:'
	var score_num = $.CreatePanel('Label', desc, 'score_' + num)
	score_num.text = score
}

function refreshLeaderBoard(data) {
	for (var i = 0; i < 10; i++)
		refreshLeaderPos(data.steam[i], data.score[i], i + 1)
}

function refreshLeaderPos(steam, score, num) {
	var avatar = $('#avatar_' + num)
	avatar.steamid = steam
	var score_num = $('#score_' + num)
	score_num.text = score
}

function makeLeaderBoard(data) {
	for (var i = 0; i <10; i++)
		makeLeaderPos(data.steam[i], data.score[i], i + 1))
}

 GameEvents.Subscribe("end_evasion_game", refreshLeaderBoardData);