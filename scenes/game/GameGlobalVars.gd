extends Node

var NetworkCon: svrclt
var IsGame = false
var Playspace: PlayspaceNode
var GameStage = PLAYERTURN
enum{
	ATTACKINGTURN,
	PLAYERTURN
}
var HandCardIdentifier = 0
