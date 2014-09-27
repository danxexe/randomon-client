window.onload = ->

	start = ->
		w = document.body.offsetWidth
		h = document.body.offsetHeight
		game = new Phaser.Game(w, h, Phaser.AUTO, '', GameState)

		game.state.add 'game', GameState, true
		game.state.add 'battle', BattleState

		window.s = GameState


	GameState = 
		_setupGUI: ->
			@gui = new dat.GUI()
			state = @
			@gui_controller =
				triggerBattle: ->
					state._battle()

			@gui.add(@gui_controller, 'triggerBattle').name('Battle!')

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

			@player = @_createPlayer(@world.player?.id)
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

		update: ->
			@grass_layer.debug = false
			@game.physics.arcade.overlap @player, @grass_layer, =>
				@grass_layer.debug = true

			@_movePlayer() unless @disable_input
			@_checkBounds()

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
			tile_w = @tile_w * scale
			tile_h = @tile_h * scale
			map_w = @map_w / scale
			map_h = @map_h / scale

			color = Phaser.Color.interpolateColorWithRGB(@game.stage.backgroundColor, 0, 0, 0, 100, 20)
			map_tiles = new Phaser.BitmapData(@game, 'map-tiles', tile_w * 2, tile_h)
			@game.cache.addBitmapData('map-tiles', map_tiles)
			map_tiles.rect tile_w, 0, tile_w, tile_h, Phaser.Color.getWebRGB(color)

			@map = @game.add.tilemap(null, tile_w, tile_h, map_w, map_h)
			@map.addTilesetBitmapData map_tiles, 0, tile_w, tile_h

			@grass_layer = @map.createBlankLayer 'grass', map_w, map_h, tile_w, tile_h, @group

			for i in [0..((map_w * map_h) / 2)]
				x = @game.rnd.between(0, map_w - 1)
				y = @game.rnd.between(0, map_h - 1)
				tile = @map.putTile(1, x, y, 'grass')

			@map.setCollision 1, true, 'grass'

		_generatePlayerId: ->
			@game.rnd.uuid()

		_createPlayer: (id = null) ->
			player_id = if id? then id else @_generatePlayerId()
			@game.rnd.sow(player_id)

			x = @game.world.centerX - @tile_w / 2
			y = @game.world.centerY - @tile_h / 2
			player_tex = new Phaser.BitmapData(@game, null, @tile_w, @tile_h)
			color = @game.rnd.color()
			player_tex.fill.apply player_tex, Phaser.Color.toArray(color)
			player = @group.add @game.add.sprite(x, y, player_tex)
			player.id = player_id
			player

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

			if @player.sync && (dir.x != 0 || dir.y != 0)
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