svgns = 'http://www.w3.org/2000/svg'
xlinkns = "http://www.w3.org/1999/xlink"
hexScale = 1
hexWidth = hexScale * 2
hexHeight = hexScale * Math.sqrt 3

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
	constructor: (@location, @sides) ->
		@scale = 1
		@currentSide = @sides[0]
		@inHand = false

		group = document.createElementNS svgns, "g"
		node = document.createElementNS svgns, "use"
		node.setAttributeNS xlinkns, "href", "#piece"
		node.setAttribute "class", "piece"
		group.appendChild node

		@textNode = document.createElementNS svgns, "text"
		@textNode.textContent = @currentSide.symbol
		@textNode.setAttribute "class", "piece"
		
		group.appendChild @textNode
		@node = group
		@update()

		@location.setPiece @

	flip: () ->
		if @currentSide == @sides[0]
			@currentSide = @sides[1]
		else
			@currentSide = @sides[0]

	moves: () ->
		@currentSide.moves

	render: (svg) ->
		svg.appendChild @node

	update: () ->
		[cx,cy] = @location.center
		angle = if @owner == 2 then 180 else 0
		transform = "rotate(#{angle} #{cx} #{cy}) translate(#{cx} #{cy}) scale(#{@scale})"
		@node.children[1].textContent = @currentSide.symbol
		@node.setAttribute "transform", transform


class SilverBishop extends Piece
	constructor: (@owner, @location) ->
		silverMoves = [{type: "step", value:1},{type: "step", value:2},{type: "step", value:4},{type: "step", value:6},{type: "step", value:8},{type: "step", value:10},{type: "step", value:12}]
		bishopMoves = [{type:"ray", value:2},{type:"ray", value:4},{type:"ray", value:6},{type:"ray", value:8},{type:"ray", value:10},{type:"ray", value:12}]
		super @location, [{name:"silver", symbol:"銀", moves:silverMoves},{name:"bishop", symbol:"角",moves:bishopMoves}]

class King extends Piece
	constructor: (@owner, @location) ->
		kingMoves = [{type: "step", value:1},{type: "step", value:2},{type: "step", value:3},{type: "step", value:4},{type: "step", value:5},{type: "step", value:6},{type: "step", value:7},{type: "step", value:8},{type: "step", value:9},{type: "step", value:10},{type: "step", value:11},{type: "step", value:12}]
		super @location, [{name:"king", symbol:"王", moves:kingMoves},{name:"king", symbol:"王", moves:kingMoves}]
		@scale = 1.15
		@textNode.setAttribute "class", "king"
		@update()

class Challenger extends Piece
	constructor: (@owner, @location) ->
		kingMoves = [{type: "step", value:1},{type: "step", value:2},{type: "step", value:3},{type: "step", value:4},{type: "step", value:5},{type: "step", value:6},{type: "step", value:7},{type: "step", value:8},{type: "step", value:9},{type: "step", value:10},{type: "step", value:11},{type: "step", value:12}]
		super @location, [{name:"king", symbol:"玉", moves:kingMoves},{name:"king", symbol:"玉", moves:kingMoves}]
		@scale = 1.15
		@textNode.setAttribute "class", "king"
		@update()

class GoldKnight extends Piece
	constructor: (@owner, @location) ->
		goldMoves = [{type: "step", value:1},{type: "step", value:2},{type: "step", value:3},{type: "step", value:5},{type: "step", value:7},{type: "step", value:9},{type: "step", value:11}, {type:"step", value:12}]
		knightMoves = [{type:"jump", value: 1}, {type:"jump", value: 2}]
		super @location, [{name:"gold", symbol:"金", moves:goldMoves},{name:"knight", symbol:"桂",moves:knightMoves}]

class PawnRook extends Piece
	constructor: (@owner, @location) ->
		pawnMoves = [{type:"step", value:1}]
		rookMoves = [{type:"ray", value:1},{type:"ray", value:3},{type:"ray", value:5},{type:"ray", value:7},{type:"ray", value:9},{type:"ray", value:11}]
		super @location, [{name:"pawn", symbol:"歩", moves:pawnMoves},{name:"rook", symbol:"飛",moves:rookMoves}]

class TokinLance extends Piece
	constructor: (@owner, @location) ->
		tokinMoves = [{type: "step", value:1},{type: "step", value:2},{type: "step", value:3},{type: "step", value:5},{type: "step", value:7},{type: "step", value:9},{type: "step", value:11}, {type:"step", value:12}]
		lanceMoves = [{type:"ray", value:1}]
		super @location, [{name:"tokin", symbol:"と", moves:tokinMoves},{name:"lance", symbol:"香",moves:lanceMoves}]

class HexKyotoShogi
	constructor: () ->
		body = (document.getElementsByTagName "body")[0]
		@svg = document.createElementNS svgns, "svg"
		@svg.setAttribute "height", "100%"
		@svg.setAttribute "width", "100%"
		gridHeight = (Math.sqrt 3) * 9.5
		@svg.setAttribute "viewBox", "-5 #{-gridHeight/2.0} 10 #{gridHeight}"
		body.appendChild @svg
		defs = document.createElementNS svgns, "defs"
		hex = document.createElementNS svgns, "polygon"
		hex.setAttribute "id", "hexagon"
		hex.setAttribute "points", hexagonVertices()
		defs.appendChild hex
		piece = document.createElementNS svgns, "polygon"
		piece.setAttribute "id", "piece"
		piece.setAttribute "points", pieceVertices()
		defs.appendChild piece
		@svg.appendChild defs


		@board = new Board()

		@pieces = [
			new Challenger 1, (@board.getHex [0,3])
			new SilverBishop 1, (@board.getHex [-1,3])
			new GoldKnight 1, (@board.getHex [1,2])
			new TokinLance 1, (@board.getHex [-2,3])
			new PawnRook 1, (@board.getHex [2,1])
			new King 2, (@board.getHex [0,-3])
			new SilverBishop 2, (@board.getHex [1,-3])
			new GoldKnight 2, (@board.getHex [-1,-2])
			new TokinLance 2, (@board.getHex [2,-3])
			new PawnRook 2, (@board.getHex [-2,-1])
		]

		@board.render(@svg)

		for piece in @pieces
			piece.render(@svg)

		@state = {currentPlayer: 1, phase: "selectPiece"}

		firebase = new Firebase "https://hexkyotoshogi.firebaseio.com/"
		@events = firebase.child "events"
		@events.on "child_added", (snapshot, previousName) => @handleMove snapshot.val()

		auth = new FirebaseSimpleLogin firebase, (error, user) =>
		  if error then console.log error
		  else
		  	if user then console.log('User ID: ' + user.uid + ', Provider: ' + user.provider)
		  	else console.log "logged out, for some reason"

		@selectPiece()

	handleMove: (move) ->
		console.log "incoming move: ", move
		#called when firebase sends us a new move
		#todo: handle moves from hand
		#todo: error checking?
		if move.from == "hand"
			switch @state.currentPlayer
				when 1 then hand = @board.hand1
				when 2 then hand = @board.hand2
			for piece in hand.locations
				if piece.currentSide.name == move.piece
					movingPiece = piece
		else
			#we are on the board
			fromHex = @board.getHex move.from
			movingPiece = fromHex.getPiece()
		
		toHex = @board.getHex move.to
		@move movingPiece, toHex
		@nextPlayer()

		@selectPiece()

	nextPlayer: ->
		switch @state.currentPlayer
			when 1 then @state.currentPlayer = 2
			when 2 then @state.currentPlayer = 1

	move: (piece, hex) ->
		if piece.inHand
			switch piece.owner
				when 1 then @board.hand1.remove piece
				when 2 then @board.hand2.remove piece
		else
			piece.location.removePiece()
			victim = hex.getPiece()
			if victim? then @capture victim

		if hex.inHand
			switch piece.owner
				when 1 then @hand1.add piece
				when 2 then @hand2.add piece
		else
			hex.setPiece piece
		piece.flip()
		piece.update()

	capture: (piece) ->
		if piece.owner == 1
			piece.owner = 2
			piece.location.removePiece()
			@board.hand2.add piece
		else
			piece.owner = 1
			piece.location.removePiece()
			@board.hand1.add piece

	selectPiece: () ->
		console.log "selectPiece"
		@board.clearGlass()

		makeClickHandler = (piece) => (event) => (console.log "select piece", piece); @selectMove piece

		for piece in @pieces
			if piece.owner == @state.currentPlayer
				piece.location.glassOn()
				piece.location.addClickListener (makeClickHandler piece)

	selectMove: (selectedPiece) ->
		console.log "selectMove", selectedPiece
		@board.clearGlass()

		makeClickHandler = (move) =>
			(event) => @confirmMove selectedPiece, move
		
		makeBackClickHandler = () =>
			(event) => @selectPiece()

		selectedPiece.location.glassOn()
		selectedPiece.location.addClickListener makeBackClickHandler()

		for hex in @validMoves selectedPiece
			# hex = @board.getHex move
			hex.glassOn()
			#this was move before it was hex... did it work out?
			hex.addClickListener (makeClickHandler hex)


	confirmMove: (selectedPiece, moveHex) ->
		console.log "confirmMove", selectedPiece, moveHex
		@board.clearGlass()

		makeClickHandler = () =>
			(event) => @pushMove selectedPiece, moveHex
		
		makeBackClickHandler = () =>
			(event) => @selectMove selectedPiece
		
		moveHex.glassOn()
		moveHex.addClickListener makeClickHandler()

		selectedPiece.location.glassOn()
		selectedPiece.location.addClickListener (makeBackClickHandler selectedPiece)

	pushMove: (piece, hex) ->
		console.log "pushing move", piece, hex
		#todo: push to firebase
		@events.push
			piece: piece.currentSide.name
			from: if piece.inHand then "hand" else piece.location.index
			to: hex.index


	validMoves: (piece) ->
		step = (source, direction) =>
			[x,y] = source.index
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
			if location? and (@board.getHex location).getPiece()?.owner != @state.currentPlayer
				@board.getHex location
			else
				undefined

		ray = (source, direction) =>
			locations = []
			cast = (location) =>
				if location?
					if !location.getPiece()
						locations.push location
						cast (step location, direction)
					else
						if location.getPiece().owner != @state.currentPlayer
							locations.push location
			cast (step source, direction)
			locations

		processMove = (move) ->
			#player move isomorphism: player 2's directions are 6 more than player 1, mod 12
			direction = move.value
			if piece.owner == 2 then direction = (direction + 6) % 12
			moves = switch move.type
				when "step"
					x = step piece.location, direction
					if x? then [x] else []

				#the knight jumps are handled as two steps
				#7 and 8 are synthetic versions for player 2
				when "jump"
					switch direction
						when 1
							x = step (step piece.location, 1), 2
							if x? then [x] else []
						when 2
							x = step (step piece.location, 1), 12
							if x? then [x] else []
						when 7
							x = step (step piece.location, 7), 8
							if x? then [x] else []
						when 8
							x = step (step piece.location, 7), 6
							if x? then [x] else []
				when "ray"
					ray piece.location, direction
			moves

		locations = []
		if piece.inHand
			#any empty space is valid
			for col in @board.hexes
				for hex in col
					if !hex.getPiece()? then locations.push hex
		else
			for move in piece.moves()
				locations = locations.concat (processMove move)
		locations

class Hex
	constructor: (@index, style) ->
		[x,y] = @index
		cx = x * 0.75 * hexWidth
		cy = y * hexHeight + x * hexHeight * 0.5
		@center = [cx,cy]
		@glassState = "off"

		@node = document.createElementNS svgns, "g"
		@node.setAttribute "transform", "translate(#{"" + cx + " " + cy})"
		@node.setAttribute "data-id", @index

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
		if @piece? then @piece.update()

	getPiece: () ->
		@piece

	setPiece: (piece) ->
		@piece = piece
		piece.location = @

	removePiece: () ->
		delete @piece?.location
		delete @piece

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
	constructor: (@owner) ->
		@indices = switch @owner
			when 1 then [[0,4],[1,3],[2,2],[3,1],[4,0],[4,-1],[4,-2],[4,-3]]
			when 2 then [[0,-4],[-1,-3],[-2,-2],[-3,-1],[-4,0],[-4,1],[-4,2],[-4,3]]
		@locations = []
		@hexes = for i in [0..7]
			hex = new Hex @indices[i], "off"
			hex.inHand = true
			hex
		
	getHex: (i) -> @hexes[i]

	add: (piece) ->
		i = @locations.push piece
		piece.location = @getHex i
		piece.inHand = true
		#do we need this update?
		@update()

	remove: (piece) ->
		n = undefined
		for i, maybe of @locations
			if maybe == piece
				n = i
		@locations.splice n,1
		piece.inHand = false
		piece.location.removePiece()
		@update()

	render: (svg) ->
		for hex in @hexes
			hex.render svg

	update: () ->
		for i,piece of @locations
			piece.location = @getHex i
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

		@hand1 = new Hand(1)
		@hand2 = new Hand(2)
	
	getHex: (index) ->
		findIt = (thing) ->

		console.log "getHex", index
		[x,y] = index
		if x > 3 or y > 3 or x + y > 3
			#we are talking about the hand
			i = @hand1.indices.indexOf index
			if i == -1
				i = @hand2.indices.indexOf index
				if i == -1 then throw new Error "no good man"
				hex = @hand2.getHex i
			else
				hex = @hand1.getHex i
		else	
			i = x + 3
			j = y + Math.min i,3
			hex = @hexes[i][j]
		hex

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