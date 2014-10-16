window.onload = ->

	start = ->
		game = new Phaser.Game('100%', '100%', Phaser.AUTO, '')

		game.state.add 'boot', BootState
		game.state.add 'game', GameState
		game.state.add 'battle', BattleState

		game.state.start('boot')

		window.s = GameState
		window.g = game

	BootState = 
		init: ->
			# @game.stage.disableVisibilityChange = true
			@game.scale.scaleMode = Phaser.ScaleManager.RESIZE

		create: ->
			@game.state.start('game')

	GameState = 
		resize: ->
			@game.scale.refresh()

		_setupGUI: ->
			@gui = new dat.GUI()
			state = @
			@gui_controller =
				triggerBattle: ->
					state._battle()
				clearData: ->
					localStorage.clear()

			@gui.add(@gui_controller, 'triggerBattle').name('Battle!')
			@gui.add(@gui_controller, 'clearData').name('Clear data')

		_battle: ->
			@disable_input = true
			@group.x = @group.pivot.x = @player.x + @player.width / 2
			@group.y = @group.pivot.y = @player.y + @player.height / 2
			@camera.focusOnXY @player.x, @player.y

			@game.add.tween(@group).to({ rotation: 3 }, 1000, Phaser.Easing.Linear.None, true)
			@game.add.tween(@group).to({ alpha: 0 }, 1000, Phaser.Easing.Linear.None, true)
			@game.add.tween(@group.scale).to({ x: 80, y: 80 }, 1000, Phaser.Easing.Linear.None, true).onComplete.add ->
				@gui.destroy()
				@game.state.start 'battle'
			, @

		preload: ->
			@game.scale.scaleMode = Phaser.ScaleManager.RESIZE

		create: ->
			@_setupGUI()

			@offline = document.location.search.match(/offline=true/)?
			@light_bg = document.location.search.match(/light_bg=true/)?

			@server_url = window.env.GAME_SERVER_URL || "ws://localhost:4000/ws"
			@socket = new Phoenix.Socket(@server_url) unless @offline || @socket

			@game.physics.startSystem(Phaser.Physics.ARCADE)

			@speed = 4

			@tile_w = 32
			@tile_h = 32
			@map_w = 64
			@map_h = 64
			@game.world.setBounds(0, 0, @map_w * @tile_w, @map_h * @tile_h)

			@game.input.keyboard.addKeyCapture [
				Phaser.Keyboard.LEFT
				Phaser.Keyboard.RIGHT
				Phaser.Keyboard.UP
				Phaser.Keyboard.DOWN
			]

			@group = @game.add.group()
			@disable_input = false

			@player = @_createLocalPlayer()
			@game.physics.enable(@player)

			if @world.player?
				@player.x = @world.player.x
				@player.y = @world.player.y

			@game.time.events.loop(Phaser.Timer.SECOND * 2, (-> @sync() if @sync), @player) unless @offline
			@_createWorld()

			@player.bringToTop()
			@game.camera.follow(@player)

			@others = {}

			@world.encounters = @encounters = [
				@game.rnd.uuid()
				@game.rnd.uuid()
				@game.rnd.uuid()
				@game.rnd.uuid()
			]

			@_connectToServer() unless @offline

			# Randomize seed after everything is done
			@game.rnd.sow([Math.random()])

		update: ->
			@_movePlayer() unless @disable_input
			@_checkBounds()

			if @delta.x != 0 || @delta.y != 0

				# Cleanup old colliding tiles
				for tile in @colliding_tiles
					@map.putTile(1, tile.x, tile.y, 'grass')
				@colliding_tiles = []

				# Update new colliding tiles
				@game.physics.arcade.overlap @player, @grass_layer, (_, tile) =>
					@colliding_tiles.push @map.putTile(2, tile.x, tile.y, 'grass')
					@_battle() if @game.rnd.between(1, 200) == 1

			if @game.input.keyboard.isDown(Phaser.Keyboard.R) && @game.input.keyboard.isDown(Phaser.Keyboard.CONTROL)
				document.location.hash = ''
				document.location.reload()

		render: ->
			# @game.debug.cameraInfo(@game.camera, 32, 32);

		shutdown: ->
			@world.player =
				id: @player.id
				x: @player.x
				y: @player.y

		_getOrGenerateWordId: ->
			if document.location.hash == ''
				document.location.hash = @game.rnd.uuid()
			else
				document.location.hash.replace /^#/, ''

		_createWorld: ->
			@world_id = @_getOrGenerateWordId()
			@game.rnd.sow(@world_id)

			if @light_bg
				@game.stage.backgroundColor = 0xffffff
			else
				@game.stage.backgroundColor = @game.rnd.color()

			scale = 2
			@grass_tile_w = @tile_w * scale
			@grass_tile_h = @tile_h * scale
			@grass_map_w = @map_w / scale
			@grass_map_h = @map_h / scale

			# Create tiles

			colors = []
			colors.push Phaser.Color.interpolateColorWithRGB(@game.stage.backgroundColor, 0, 0, 0, 100, 20)
			colors.push Phaser.Color.interpolateColorWithRGB(colors[0], 0, 0, 0, 100, 10)

			map_tiles = new Phaser.BitmapData(@game, 'map-tiles', @grass_tile_w * (colors.length + 1), @grass_tile_h)
			@game.cache.addBitmapData('map-tiles', map_tiles)
			for color, i in colors
				map_tiles.rect @grass_tile_w * (i + 1), 0, @grass_tile_w, @grass_tile_h, Phaser.Color.getWebRGB(color)

			# Create map

			@map = @game.add.tilemap(null, @grass_tile_w, @grass_tile_h, @grass_map_w, @grass_map_h)
			@map.addTilesetBitmapData map_tiles, 0, @grass_tile_w, @grass_tile_h

			@_createGrass()

			@colliding_tiles = []

		_createGrass: ->
			@grass_layer.destroy() if @grass_layer?
			@grass_layer = @map.createBlankLayer 'grass', @grass_map_w, @grass_map_h, @grass_tile_w, @grass_tile_h, @group

			for i in [0..((@grass_map_w * @grass_map_h) / 2)]
				x = @game.rnd.between(0, @grass_map_w - 1)
				y = @game.rnd.between(0, @grass_map_h - 1)
				tile = @map.putTile(1, x, y, 'grass')

			@map.setCollision [1, 2], true, 'grass'

		_generatePlayerId: ->
			@game.rnd.uuid()

		_createPlayer: (player_id) ->
			@game.rnd.sow(player_id)

			x = @game.world.centerX - @tile_w / 2
			y = @game.world.centerY - @tile_h / 2
			player_tex = new Phaser.BitmapData(@game, null, @tile_w, @tile_h)
			color = @game.rnd.color()
			player_tex.fill.apply player_tex, Phaser.Color.toArray(color)
			player = @group.add @game.add.sprite(x, y, player_tex)
			player.id = player_id
			player

		_createLocalPlayer: ->
			unless player_id = localStorage.getItem('player_id')
				player_id = @_generatePlayerId()
				localStorage.setItem('player_id', player_id)

			@_createPlayer(player_id)

		_movePlayer: ->
			@delta = { x: 0, y: 0 }
			if @game.input.keyboard.isDown(Phaser.Keyboard.LEFT)
				@delta.x -= @speed
			if @game.input.keyboard.isDown(Phaser.Keyboard.RIGHT)
				@delta.x += @speed
			if @game.input.keyboard.isDown(Phaser.Keyboard.UP)
				@delta.y -= @speed
			if @game.input.keyboard.isDown(Phaser.Keyboard.DOWN)
				@delta.y += @speed

			@player.x += @delta.x
			@player.y += @delta.y

			if @player.sync && (@delta.x != 0 || @delta.y != 0)
				@player.sync()

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

		_connectToServer: ->
			player = @player
			others = @others
			gameState = @

			@socket.join "world", @world_id, {player: player.id}, (chan) ->

				chan.on "join", (message) ->
					player.sync = ->
						chan.send("sync", player: @id, x: @x, y: @y)

				chan.on "player:entered", (msg) ->
					if (player_id = msg.player)? && !others[player_id]?
						new_player = gameState._createPlayer(player_id)
						others[player_id] = new_player
						player.bringToTop()

				chan.on "player:left", (msg) ->
					player_id = msg.player
					if (other_player = others[player_id])?
						delete others[player_id]
						other_player.destroy()

				chan.on "player:sync", (msg) ->
					player_id = msg.player
					if !(other_player = others[player_id])?
						new_player = gameState._createPlayer(player_id)
						other_player = others[player_id] = new_player
						player.bringToTop()

					other_player.x = msg.x
					other_player.y = msg.y


	start()