window.onload = ->

	Phaser.RandomDataGenerator::color = ->
        r = @between(0, 255)
        g = @between(0, 255)
        b = @between(0, 255)

        Phaser.Color.getColor32(1, r, g, b)

	Phaser.Color.toArray = (color) ->
		[Phaser.Color.getRed(color), Phaser.Color.getGreen(color), Phaser.Color.getBlue(color)]

	start = ->
		w = document.body.offsetWidth
		h = document.body.offsetHeight
		game = new Phaser.Game(w, h, Phaser.AUTO, '', GameState)
		window.game = game

	GameState = 
		preload: (@game) ->
			@uuid = if document.location.hash == ''
				document.location.hash = @game.rnd.uuid()
			else
				document.location.hash.replace /^#/, ''

			@game.rnd.sow(@uuid)

		create: ->
			@game.stage.backgroundColor = @game.rnd.color()

			@speed = 4

			@tile_w = 32
			@tile_h = 32
			@map_w = 64
			@map_h = 64
			@game.world.setBounds(0, 0, @map_w * @tile_w, @map_h * @tile_h);

			@game.input.keyboard.addKeyCapture [
				Phaser.Keyboard.LEFT
				Phaser.Keyboard.RIGHT
				Phaser.Keyboard.UP
				Phaser.Keyboard.DOWN
			]

			@_createPlayer()
			@_createDarkPatches()
			@player.bringToTop()
			@game.camera.follow(@player)

		update: ->
			@_movePlayer()
			@_checkBounds()

			if @game.input.keyboard.isDown(Phaser.Keyboard.R) && @game.input.keyboard.isDown(Phaser.Keyboard.CONTROL)
				document.location.hash = ''
				document.location.reload()

		render: ->
			@game.debug.cameraInfo(@game.camera, 32, 32);

		_createDarkPatches: ->
			scale = 2
			tile_w = @tile_w * scale
			tile_h = @tile_h * scale
			map_w = @map_w / scale
			map_h = @map_h / scale

			@dark_patches = []
			color = Phaser.Color.interpolateColorWithRGB(@game.stage.backgroundColor, 0, 0, 0, 100, 20)
			dark_tex = new Phaser.BitmapData(@game, 'dark', tile_w, tile_h)
			dark_tex.fill.apply dark_tex, Phaser.Color.toArray(color)

			for i in [0..((map_w * map_h) / 2)]
				x = @game.rnd.between(0, map_w - 1)
				y = @game.rnd.between(0, map_h - 1)
				@dark_patches.push @game.add.sprite(x * tile_w, y * tile_h, dark_tex)

		_createPlayer: ->
			x = @game.world.centerX - @tile_w / 2
			y = @game.world.centerY - @tile_h / 2
			player_tex = new Phaser.BitmapData(@game, 'player', @tile_w, @tile_h)
			color = @game.rnd.color()
			player_tex.fill.apply player_tex, Phaser.Color.toArray(color)
			@player = @game.add.sprite(x, y, player_tex)

		_movePlayer: ->
			dir = { x: 0, y: 0 }
			if @game.input.keyboard.isDown(Phaser.Keyboard.LEFT)
				dir.x -= @speed
			if @game.input.keyboard.isDown(Phaser.Keyboard.RIGHT)
				dir.x += @speed
			if @game.input.keyboard.isDown(Phaser.Keyboard.UP)
				dir.y -= @speed
			if @game.input.keyboard.isDown(Phaser.Keyboard.DOWN)
				dir.y += @speed

			@player.x += dir.x
			@player.y += dir.y

		_checkBounds: ->
			left = 0
			right = @game.world.width - @player.width
			top = 0
			bottom = @game.world.height - @player.height

			if @player.x < left
				@player.x = left
			else if @player.x >= right
				@player.x = right
			if @player.y < top
				@player.y = top
			else if @player.y >= bottom
				@player.y = bottom

	start()