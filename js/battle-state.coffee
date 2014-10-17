BattleState = 
	_setupGUI: ->
		state = @
		game = @game
		gui = @gui = new dat.GUI()
		@gui_controller =
			run: ->
				gui.destroy()
				game.state.start 'game'

		Object.defineProperty @gui_controller, 'show_sprites',
			get: ->
				if localStorage.getItem('battle.show_sprites')? then JSON.parse(localStorage.getItem('battle.show_sprites')) else true
			set: (val) ->
				localStorage.setItem('battle.show_sprites', val)
				state._showSprites val

		Object.defineProperty @gui_controller, 'show_stats',
			get: ->
				if localStorage.getItem('battle.show_stats')? then JSON.parse(localStorage.getItem('battle.show_stats')) else true
			set: (val) ->
				localStorage.setItem('battle.show_stats', val)
				state._showStats val

		@gui.add(@gui_controller, 'run').name('Run!')
		@gui.add(@gui_controller, 'show_sprites').name('Show sprites')
		@gui.add(@gui_controller, 'show_stats').name('Show stats')

	_showSprites: (visible) ->
		@enemy.sprite.visible = visible
		@player.sprite.visible = visible

	_showStats: (visible) ->
		if visible then $('#overlay').show() else $('#overlay').hide()

	create: ->
		BootState.ensurePlayerId()
		BootState.ensureWorldId()
		BootState.ensureEncounters()

		@_setupGUI()

		@stage.backgroundColor = 0xffffff
		@world.setBounds(0, 0, @camera.width, @camera.height)

		@game.rnd.randomize()
		@enemy = @_createCreature(x: @world.centerX + 200, y: 100, lv: @game.rnd.between(1, 100))
		@enemy.showStats('enemy-stats')
		@_createCreatureInfo(@enemy, x: 40, y: 30)
		@player = @_createCreature(x: 200, y: 400, scale: 16 * 3, seed: @world.player_id)
		@player.showStats('player-stats')
		@_createCreatureInfo(@player, x: @camera.width - 600, y: @camera.height - 200)

		@_showSprites(@gui_controller.show_sprites)
		@_showStats(@gui_controller.show_stats)

	_createCreature: (options = {}) ->
		options.scale ?= 16
		unless options.seed?
			@game.rnd.sow([Math.random()])
			options.seed = @game.rnd.pick(@world.encounters)

		creature = new Creature @game, 
			x: options.x
			y: options.y
			scale: options.scale
			color: 0x000000
			w: 7
			h: 8
			seed: options.seed
			lv: options.lv

		creature.addTo @game
		creature

	_createCreatureInfo: (creature, options = {}) ->
		info = @game.add.group()
		info.x = options.x
		info.y = options.y

		lv = if creature.lv == 100 then "Lv 100" else "Lv " + ("00" + creature.lv).slice(-2)

		@game.add.text 0, 0, "Unknown", { font: "40px Minecraftia" }, info
		window.t = @game.add.text 366, 10, lv, { font: "30px Minecraftia", align: 'right' }, info
		@game.add.text 0, 50, "HP", { font: "28px Minecraftia" }, info
		hp_bar = @game.add.graphics(60, 58, info)
		hp_bar.lineStyle(4, 0x000000, 1)
		hp_bar.beginFill(0x9DE0AD, 1)
		hp_bar.drawRect(0, 0, 400, 24)

window.BattleState = BattleState