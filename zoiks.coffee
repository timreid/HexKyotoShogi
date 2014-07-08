svgns = 'http://www.w3.org/2000/svg'
xlinkns = "http://www.w3.org/1999/xlink"
hexScale = 1
hexWidth = hexScale * 2
hexHeight = hexScale * Math.sqrt 3

center = (location) ->
	hand1 = [[0,4],[1,3],[2,2],[3,1],[4,0],[4,-1],[4,-2],[4,-3]]
	hand2 = [[0,-4],[-1,-3],[-2,-2],[-3,-1],[-4,0],[-4,1],[-4,2],[-4,3]]
	[x,y] = location
	#TODO: remove this dark evil hack
	y = parseInt y
	switch x
		when "hand1"
			x = hand1[y][0]
			y = hand1[y][1]
		when "hand2"
			x = hand2[y][0]
			y = hand2[y][1]
	cx = x * 0.75 * hexWidth
	cy = y * hexHeight + x * hexHeight * 0.5
	[cx,cy]

hexagonVertices = () ->
	vertices = ""
	for n in [0..6]
		angle = n * Math.PI / 3.0
		px = Math.cos angle
		py = Math.sin angle
		vertices += "#{px}" + "," + "#{py} "
	vertices

pieceVertices = () ->
	alpha = 0.66
	beta = 0.35
	gamma = alpha / 1.2
	delta = 1.115 * alpha - .2
	one = [0,-alpha]
	two = [beta,-gamma]
	three = [0.5, delta]
	four = [-0.5, delta]
	five = [-beta, -gamma]

	[one,two,three,four,five]

class Piece
	constructor: (@sides) ->
		@currentSide = @sides[0]
		[x,y] = @location
		[cx,cy] = center x,y
		group = document.createElementNS svgns, "g"
		node = document.createElementNS svgns, "use"
		node.setAttributeNS xlinkns, "href", "#piece"
		node.setAttribute "class", "piece"
		group.appendChild node

		textNode = document.createElementNS svgns, "text"
		textNode.textContent = @currentSide.symbol
		if @currentSide.name == "king"
			textNode.setAttribute "class", "king"
		else
			textNode.setAttribute "class", "piece"
		group.appendChild textNode
		@node = group
		@update()

	flip: () ->
		if @currentSide == @sides[0]
			@currentSide = @sides[1]
		else
			@currentSide = @sides[0]

	moves: () ->
		@currentSide.moves

	move: (destination) ->
		@location = destination

	render: (svg) ->
		svg.appendChild @node
	update: () ->
		[cx,cy] = center @location
		angle = if @owner == 2 then 180 else 0
		scale = if @currentSide.name == "king" then 1.15 else 1
		transform = "rotate(#{angle} #{cx} #{cy}) translate(#{cx} #{cy}) scale(#{scale})"
		@node.children[1].textContent = @currentSide.symbol
		@node.setAttribute "transform", transform


class SilverBishop extends Piece
	constructor: (@owner) ->
		silverMoves = [{type: "step", value:1},{type: "step", value:2},{type: "step", value:4},{type: "step", value:6},{type: "step", value:8},{type: "step", value:10},{type: "step", value:12}]
		bishopMoves = [{type:"ray", value:2},{type:"ray", value:4},{type:"ray", value:6},{type:"ray", value:8},{type:"ray", value:10},{type:"ray", value:12}]
		if @owner == 1
			@location = [-1,3]
		else
			@location = [1,-3]
		super [{name:"silver", symbol:"銀", moves:silverMoves},{name:"bishop", symbol:"角",moves:bishopMoves}]

class King extends Piece
	constructor: (@owner) ->
		kingMoves = [{type: "step", value:1},{type: "step", value:2},{type: "step", value:3},{type: "step", value:4},{type: "step", value:5},{type: "step", value:6},{type: "step", value:7},{type: "step", value:8},{type: "step", value:9},{type: "step", value:10},{type: "step", value:11},{type: "step", value:12}]
		if @owner == 1
			@location = [0,3]
		else
			@location = [0,-3]
		super [{name:"king", symbol:"王", moves:kingMoves},{name:"king", symbol:"王", moves:kingMoves}]

class GoldKnight extends Piece
	constructor: (@owner) ->
		goldMoves = [{type: "step", value:1},{type: "step", value:2},{type: "step", value:3},{type: "step", value:5},{type: "step", value:7},{type: "step", value:9},{type: "step", value:11}, {type:"step", value:12}]
		knightMoves = [{type:"jump", value: 1}, {type:"jump", value: 2}]
		if @owner == 1
			@location = [1,2]
		else
			@location = [-1,-2]
		super [{name:"gold", symbol:"金", moves:goldMoves},{name:"knight", symbol:"桂",moves:knightMoves}]

class PawnRook extends Piece
	constructor: (@owner) ->
		pawnMoves = [{type:"step", value:1}]
		rookMoves = [{type:"ray", value:1},{type:"ray", value:3},{type:"ray", value:5},{type:"ray", value:7},{type:"ray", value:9},{type:"ray", value:11}]
		if @owner == 1
			@location = [2,1]
		else
			@location = [-2,-1]
		super [{name:"pawn", symbol:"歩", moves:pawnMoves},{name:"rook", symbol:"飛",moves:rookMoves}]

class TokinLance extends Piece
	constructor: (@owner) ->
		tokinMoves = [{type: "step", value:1},{type: "step", value:2},{type: "step", value:3},{type: "step", value:5},{type: "step", value:7},{type: "step", value:9},{type: "step", value:11}, {type:"step", value:12}]
		lanceMoves = [{type:"ray", value:1}]
		if @owner == 1
			@location = [-2,3]
		else
			@location = [2,-3]
		super [{name:"tokin", symbol:"と", moves:tokinMoves},{name:"lance", symbol:"香",moves:lanceMoves}]



class HexKyotoShogi
	constructor: () ->
		initSVG = () ->
			body = (document.getElementsByTagName "body")[0]
			svg = document.createElementNS svgns, "svg"
			svg.setAttribute "height", "100%"
			svg.setAttribute "width", "100%"
			gridHeight = (Math.sqrt 3) * 9.5
			svg.setAttribute "viewBox", "-5 #{-gridHeight/2.0} 10 #{gridHeight}"
			body.appendChild svg

			defs = document.createElementNS svgns, "defs"

			hex = document.createElementNS svgns, "polygon"
			hex.setAttribute "id", "hexagon"
			hex.setAttribute "points", hexagonVertices()
			defs.appendChild hex

			piece = document.createElementNS svgns, "polygon"
			piece.setAttribute "id", "piece"
			piece.setAttribute "points", pieceVertices()

			defs.appendChild piece

			svg.appendChild defs
			svg
		@svg = initSVG()
		@board = new Board()
		@board.render(@svg)
		@pieces = [
			new King(1),
			new King(2),
			new SilverBishop(1),
			new SilverBishop(2),
			new GoldKnight(1),
			new GoldKnight(2),
			new PawnRook(1),
			new PawnRook(2),
			new TokinLance(1),
			new TokinLance(2)
		]
		for piece in @pieces
			piece.render(@svg)
		@state = {currentPlayer: 1, phase: "selectPiece"}

		@selectPiece()

	pieceAt: (location) ->
			target = undefined
			for own i,piece of @pieces
				if piece.location[0] == location[0] and piece.location[1] == location[1]
					target = piece
			target

	capture: (piece) ->
		#change owner
		if piece.owner == 1
			owner = 2
			hand = @board.hand2
		else
			owner = 1
			hand = @board.hand1
		piece.owner = owner
		hand.add piece

	move: (piece, destination) ->
		#handle moving out of hand
		if piece.location[0] == "hand1"
			@board.hand1.remove piece
		if piece.location[0] == "hand2"
			@board.hand2.remove piece
		#handle capture
		victim = @pieceAt destination
		if victim?
			@capture victim
		piece.move destination
		piece.flip()
		piece.update()

	selectPiece: () ->
		console.log "selectPiece"
		@board.clearGlass()

		makeClickHandler = (piece) => (event) => (console.log "select piece", piece); @selectMove piece

		for piece in @pieces
			if piece.owner == @state.currentPlayer
				hex = @board.getHex piece.location
				hex.glassOn()
				hex.addClickListener (makeClickHandler piece)

	selectMove: (selectedPiece) ->
		console.log "selectMove", selectedPiece
		@board.clearGlass()

		makeClickHandler = (move) =>
			(event) => @confirmMove selectedPiece, move
		
		makeBackClickHandler = () =>
			(event) => @selectPiece()

		backHex = @board.getHex selectedPiece.location
		backHex.glassOn()
		backHex.addClickListener makeBackClickHandler()


		LLL = (@validMoves selectedPiece)
		console.log "valid moves are:", LLL
		for move in LLL
			hex = @board.getHex move
			hex.glassOn()
			hex.addClickListener (makeClickHandler move)


	confirmMove: (selectedPiece, selectedMove) ->
		console.log "confirmMove", selectedPiece, selectedMove
		@board.clearGlass()

		makeClickHandler = () =>
			(event) =>
				console.log "confirmed move"
				@performMove selectedPiece, selectedMove
		
		makeBackClickHandler = () =>
			(event) =>
				console.log "going back"
				@selectMove selectedPiece
		
		hex = @board.getHex selectedMove
		hex.glassOn()
		hex.addClickListener (makeClickHandler piece)

		hex = @board.getHex selectedPiece.location
		hex.glassOn()
		hex.addClickListener (makeBackClickHandler piece)

	performMove: (selectedPiece, selectedMove) ->
		console.log "perform move", selectedPiece, selectedMove
		@board.clearGlass()

		@move selectedPiece, selectedMove
		if @state.currentPlayer == 1
			@state.currentPlayer = 2
		else
			@state.currentPlayer = 1
		@selectPiece()

	validMoves: (piece) ->
		stepFrom = (source, direction) =>
			[x,y] = source
			location = switch direction
				when 1 then [x, y - 1] unless x + y == -3 or y == -3
				when 2 then [x + 1, y - 2] unless y < -1 or x + y == -3
				when 3 then [x + 1, y - 1] unless x == 3 or y == -3
				when 4 then [x + 2, y - 1] unless x > 1 or y == -3 or x + y == 3
				when 5 then [x + 1, y] unless x == 3 or x + y == 3
				when 6 then [x + 1, y + 1] unless x + y > 1 or y == 3 or x == 3
				when 7 then [x, y + 1] unless y == 3 or x + y == 3
				when 8 then [x - 1, y + 2] unless y > 1 or x == -3
				when 9 then [x - 1, y + 1] unless x == -3 or y == 3
				when 10 then [x - 2, y + 1] unless x < -1 or x + y == -3 or y == 3
				when 11 then [x - 1, y] unless x == -3 or x + y == -3
				when 12 then [x - 1, y - 1] unless x + y < -1 or x == -3 or y == -3
			if location? and (@pieceAt location)?.owner != @state.currentPlayer
				location
			else
				undefined

		ray = (source, direction) =>
			locations = []
			step = (location) =>
				if location != undefined
					who = @pieceAt location
					if who?
						if who.owner != @state.currentPlayer
							locations.push location
					else
						#no one here
						locations.push location
						next = stepFrom location, direction
						step next

			step (stepFrom source, direction)
			locations

		processMove = (player, source, move) ->
			#player move isomorphism: player 2's directions are 6 more than player 1, mod 12
			value = move.value
			if player == 2 then value = (value + 6) % 12
			[x,y] = source
			moves = switch move.type
				when "step"
					d = stepFrom source, value
					if d?
						[d]
					else
						false

				#the knight jumps are handled as two steps
				#7 and 8 are synthetic versions for player 2
				when "jump"
					switch value
						when 1 then [stepFrom (stepFrom source, 1), 2]
						when 2 then [stepFrom (stepFrom source, 1), 12]
						when 7 then [stepFrom (stepFrom source, 7), 8]
						when 8 then [stepFrom (stepFrom source, 7), 6]

				when "ray"
					ray source, value
			moves

		locations = []
		if piece.location[0] == "hand1" or piece.location[0] == "hand2"
			#any empty space is valid
			for col in @board.hexes
				for hex in col
					who = @pieceAt hex.location
					if !who? then locations.push hex.location
		else
			for move in piece.moves()
				validMoves = processMove piece.owner, piece.location, move
				console.log "valid moves:", validMoves
				if validMoves
					locations = locations.concat validMoves
		locations

class Hex
	constructor: (@location, style) ->
		[cx,cy] = center @location
		@glassState = "off"

		@node = document.createElementNS svgns, "g"
		@node.setAttribute "transform", "translate(#{"" + cx + " " + cy})"
		@node.setAttribute "data-id", @location

		board = document.createElementNS svgns, "use"
		board.setAttributeNS xlinkns, "href", "#hexagon"
		board.setAttribute "class", style
		
		@glass = document.createElementNS svgns, "use"
		@glass.setAttributeNS xlinkns, "href", "#hexagon"
		@glass.setAttribute "class", "off"

		@node.appendChild board
		@node.appendChild @glass

	render: (svg) ->
		svg.appendChild @node

	update: () ->
		@glass.setAttribute "class", @glassState

	glassOn: () ->
		@glassState = 'on'
		@update()

	glassOff: () ->
		@glassState = 'off'
		@removeClickListener()
		@update()

	addClickListener: (listener) ->
		@glass.addEventListener "click", listener, false
		@eventListener = listener

	removeClickListener: () ->
		@glass.removeEventListener "click", @eventListener, false
		delete @eventListener


class Hand
	constructor: (@location) ->
		@locations = []
		@hexes = for i in [0..7]
			new Hex [@location,i], "off"
		
	getHex: (location) ->
		[x,y] = location
		@hexes[y]

	add: (piece) ->
		@locations.push piece
		piece.location = [@location, @locations.length]
		@update()

	remove: (piece) ->
		n = undefined
		for i, maybe of @locations
			if maybe == piece
				n = i
		@locations.splice n,1
		@update()

	render: (svg) ->
		for hex in @hexes
			hex.render svg

	update: () ->
		for i,piece of @locations
			piece.location = [@location,i]
			piece.update()

	clearGlass: () ->
		for hex in @hexes
			hex.glassOff()

class Board
	constructor: () ->
		@hexes = []
		for i,n of [4,5,6,7,6,5,4]
			column = []
			for j in [0..n-1]
				[x,y] = [i - 3, j - Math.min i,3]
				column.push (new Hex [x,y], "board")
			@hexes.push column
		@hand1 = new Hand("hand1")
		@hand2 = new Hand("hand2")
	
	getHex: (location) ->
		[x,y] = location
		console.log "getHex", location
		switch x
			when "hand1" then @hand1.getHex location
			when "hand2" then @hand2.getHex location
			else
				i = x + 3
				j = y + Math.min i,3
				@hexes[i][j]

	clearGlass: () ->
		for col in @hexes
			for hex in col
				hex.glassOff()
		@hand1.clearGlass()
		@hand2.clearGlass()

	render: (svg) ->
		for col in @hexes
			for hex in col
				hex.render svg
		@hand1.render svg
		@hand2.render svg
	
	update: () ->
		for hex in @hexes
			hex.update()
		@hand1.update()
		@hand2.update()

game = new HexKyotoShogi()