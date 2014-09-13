window.onload = ->

	start = ->
		w = document.body.offsetWidth
		h = document.body.offsetHeight
		game = new Phaser.Game(w, h, Phaser.AUTO, '', GameState)

	GameState = 
		speed: 4

		preload: (game) ->

		create: (game) ->
			game.stage.backgroundColor = Phaser.Color.getRandomColor(0, 255, 255)

			w = 40
			h = 40
			x = game.width / 2 - w / 2
			y = game.height / 2 - h / 2
			@player = new Phaser.Rectangle(x, y, w, h)
			@player_color = Phaser.Color.getWebRGB(Phaser.Color.getRandomColor(0, 255, 255))

			game.input.keyboard.addKeyCapture [
				Phaser.Keyboard.LEFT
				Phaser.Keyboard.RIGHT
				Phaser.Keyboard.UP
				Phaser.Keyboard.DOWN
			]

		update: (game) ->
			dir = { x: 0, y: 0 }
			if game.input.keyboard.isDown(Phaser.Keyboard.LEFT)
				dir.x -= @speed
			if game.input.keyboard.isDown(Phaser.Keyboard.RIGHT)
				dir.x += @speed
			if game.input.keyboard.isDown(Phaser.Keyboard.UP)
				dir.y -= @speed
			if game.input.keyboard.isDown(Phaser.Keyboard.DOWN)
				dir.y += @speed

			@player.x += dir.x
			@player.y += dir.y

			left = 0
			right = game.width - @player.width
			top = 0
			bottom = game.height - @player.height

			if @player.x < left
				@player.x = left
			else if @player.x >= right
				@player.x = right
			if @player.y < top
				@player.y = top
			else if @player.y >= bottom
				@player.y = bottom

		render: (game) ->
			game.debug.geom(@player, @player_color)

	start()