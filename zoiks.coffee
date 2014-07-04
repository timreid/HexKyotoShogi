svgns = 'http://www.w3.org/2000/svg'
xlinkns = "http://www.w3.org/1999/xlink"
hexScale = 1
hexWidth = hexScale * 2
hexHeight = hexScale * Math.sqrt 3

center = (location) ->
	hand1 = [[0,4],[1,3],[2,2],[3,1],[4,0],[4,-1],[4,-2],[4,-3]]
	hand2 = [[0,-4],[-1,-3],[-2,-2],[-3,-1],[-4,0],[-4,1],[-4,2],[-4,3]]
	[x,y] = location
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
		@dirty()
		# svg.appendChild group

	flip: () ->
		if @currentSide == @sides[0]
			@currentSide = @sides[1]
		else
			@currentSide = @sides[0]
		@moves = @currentSide.moves
		#update display???
		#@dirty()

	moves: () ->
		@currentSide.moves

	# move: (destination) ->
	# 	@location = destination
	# 	@dirty()

	dirty: () ->
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

class HexKyotoShogi
	constructor: () ->
		@svg = initSVG()
		@board = new Board()
		@hand1 = new Hand("hand1")
		@hand2 = new Hand("hand2")
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
		@state = {currentPlayer: 1, phase: "selectPiece"}

		for i,col of @board.hexes
			for j, hex of col
				@svg.appendChild hex.node

		for hex in @hand1.hexes
			@svg.appendChild hex.node

		for hex in @hand2.hexes
			@svg.appendChild hex.node

		for i,col of @board.glass
			for j, hex of col
				@svg.appendChild hex.node

		for piece in @pieces
			@svg.appendChild piece.node

	pieceAt: (location) ->
		target = null
		for own i,piece of @pieces
			if piece.location[0] == location[0] and piece.location[1] == location[1]
				target = piece
		target

	capture: (piece) ->
		#change owner
		if piece.owner == 1
			owner = 2
			hand = @hand2
		else
			owner = 1
			hand = @hand1
		piece.owner = owner
		hand.add piece

	move: (piece, destination) ->
		#handle moving out of hand
		if piece.location[0] == "hand1"
			@hand1.remove piece
		if piece.location[0] == "hand2"
			@hand2.remove piece
		#handle capture
		victim = @pieceAt destination
		if victim?
			@capture victim
		piece.location = destination
		piece.flip()
		piece.dirty()


buildHexes = (state, handler) ->
	hexes = []
	for i,n of [4,5,6,7,6,5,4]
		column = []
		for j in [0..n-1]
			x = i - 3
			y = j - Math.min i,3
			hex = new Hex [x,y], state, handler
			column.push hex
		hexes.push column
	hexes

clickHandler = (something) ->
	console.log something

makeClickHandler = (location) ->
	(event) -> clickHandler location

class Hex
	constructor: (@location, @state, eventHandlerFactory) ->
		[cx,cy] = center @location
		@node = document.createElementNS svgns, "use"
		@node.setAttributeNS xlinkns, "href", "#hexagon"
		@node.setAttribute "transform", "translate(#{"" + cx + " " + cy})"
		@node.setAttribute "data-id", @location
		@node.setAttribute "class", @state
		if eventHandlerFactory?
			@node.addEventListener "click", eventHandlerFactory(@location), false
		@dirty()

	dirty: () ->
		@node.setAttribute "class", @state


class Hand
	constructor: (@location) ->
		@hexes = for i in [0..7]
			c = center [@location, i]
			new Hex c, "glassoff"
		@locations = []
	add: (piece) ->
		@locations.push piece
		#piece.move [@location,n]
		@dirty()
	remove: (piece) ->
		console.log "remove"
		#remove it
		n = undefined
		for i, maybe of @locations
			if maybe == piece
				n = i
		@locations.splice n,1
		@dirty()
	dirty: () ->
		for i,piece of @locations
			piece.location = [@location,i]
			piece.dirty()

class Board
	constructor: () ->
		@hexes = buildHexes("board", makeClickHandler)
		@glass = buildHexes("glassoff")
		

		# for i,n of [4,5,6,7,6,5,4]
		# 	for j in [0..n-1]
		# 		[x,y] = [i - 3, j - Math.min i,3]
		# 		boardHex = new Hex x, y, "board", makeClickHandler()
		# 		@setHex x, y, boardHex
		# 		glassHex = new Hex x, y, "glassoff"
		# 		@setGlass x, y, glassHex
	
	getHex: (x,y) ->
		i = x + 3
		j = y + Math.min i,3
		@hexes[i][j]

	# setHex: (x,y,s) ->
	# 	i = x + 3
	# 	j = y + Math.min i,3
	# 	@hexes[i][j] = s

	getGlass: (x, y) ->
		#state of hex x,y
		i = x + 3
		j = y + Math.min i,3
		@glass[i][j]

	setGlass: (x,y,s) ->
		#set state of hex x,y to s
		hex = @getGlass x,y
		hex.state = s
		hex.dirty()

	glassOn: (x,y) ->
		@setGlass x,y, "glasson"

	clearGlass: () ->
		for i,col of @glass
			for j, hex of col
				hex.state = "glassoff"
				hex.dirty()

game = new HexKyotoShogi()