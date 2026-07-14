return {
	-- Gradually increase difficulty
	[100810] = {
		values = {
			difficulty = 0.25
		}
	},
	[101313] = {
		difficulty = 1
	},
	-- [Karto] I ain't no mission_script guy, so I believe disabling those scripted spawns WILL reduce chance to spawn scripted dozers. I can't deal with 4 of them.
	[100500] = {
		values = {
			enabled = false
		}
	},
	[100503] = {
		values = {
			enabled = false
		}
	}
}
