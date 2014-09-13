window.onload = ->

	game_state = 
		preload: ->

		create: (game) ->
			w = 40
			h = 40
			x = game.width / 2 - w / 2
			y = game.height / 2 - h / 2
			@player = new Phaser.Rectangle(x, y, w, h)

		render: ->
			game.debug.geom(@player,'#0fffff')

	w = document.body.offsetWidth
	h = document.body.offsetHeight
	game = new Phaser.Game(w, h, Phaser.AUTO, '', game_state)
