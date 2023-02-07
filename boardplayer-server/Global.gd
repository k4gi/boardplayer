extends Node


var opponents = {}
# a dictionary keeping pairs of multiplayer peer ids so the server knows who to send moves to
# will keep two entries for each game, one in format opponent_id1: opponent_id2, and the other opponent_id2: opponent_id1
#this way all the server will need to do is look up an rpc's peer id to find its destination

#var player_names = {}
#i'm not doing this yet but it would be nice if you could set your display name. instead of just using IDs.
#i can use a dictionary to store them. player_id: player_name
#simple as

var player_names = []
#because we're not worrying about names we'll just have ID numbers
