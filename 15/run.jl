mutable struct GameState
    map::Matrix{Char}
    robot::CartesianIndex{2}
    moves::String
end

const DIRS = Dict(
    '<' => CartesianIndex(0, -1),
    'v' => CartesianIndex(1, 0),
    '^' => CartesianIndex(-1, 0),
    '>' => CartesianIndex(0, 1),
)

function read_input(path)
    fh = open(path)
    map = nothing
    j, ry, rx = 1, 1, 1
    while true
        line = readline(fh)
        if line == ""
            break
        end
        row = reshape(Vector{Char}(line), 1, :)
        i = findfirst('@', line)
        if i !== nothing
            ry, rx = j, i
            row[1, i] = '.'
        end
        map = map === nothing ? row : vcat(map, row)
        j += 1
    end
    moves = ""
    while !eof(fh)
        moves = moves * readline(fh)
    end
    GameState(map, CartesianIndex(ry, rx), moves)
end

function coords(state, c)
    map(x -> 100x[1] + x[2] - 101, findall(isequal(c), state.map))
end

function run_moves(state, move_fun)
    for i in 1:length(state.moves)
        move_fun(state, DIRS[state.moves[i]])
    end
end

function make_move(state, move)
    x = state.robot
    line = ""
    i = 1
    while true
        c = state.map[x .+ i.*move]
        line *= c
        if c == '#'
            break
        end
        i += 1
    end
    fi = findfirst('.', line)
    if fi === nothing
        return
    end
    bi = findfirst('O', line)
    if bi !== nothing && bi < fi
        state.map[x .+ bi.*move] = '.'
        state.map[x .+ fi.*move] = 'O'
    end
    state.robot += move
end

function make_move_big(state, move)
    x = state.robot + move
    if canmove(x, state, move)
        push(x, state, move)
        state.robot = x
    end
end

function canmove(x, state, move)
    if state.map[x] == '#'
        return false
    end
    if state.map[x] == '.'
        return true
    end
    if move[1] == 0
        return canmove(x + 2move, state, move)
    end
    o = state.map[x] == '[' ? CartesianIndex(0, 1) : CartesianIndex(0, -1)
    canmove(x + move, state, move) && canmove(x + move + o, state, move)
end

function push(x, state, move)
    if state.map[x] == '.'
        return
    end
    if move[1] == 0
        push(x + 2move, state, move)
        state.map[x + 2move] = state.map[x + move]
        state.map[x + move] = state.map[x]
        state.map[x] = '.'
    else
        o = state.map[x] == '[' ? CartesianIndex(0, 1) : CartesianIndex(0, -1)
        push(x + move, state, move)
        push(x + move + o, state, move)
        state.map[x + move] = state.map[x]
        state.map[x] = '.'
        state.map[x + move + o] = state.map[x + o]
        state.map[x + o] = '.'
    end
end

function pprint(state)
    m = copy(state.map)
    m[state.robot] = '@'
    for row in eachrow(m)
        println(join(row, ""))
    end
end

function enlarge(old)
    new = GameState(
        Matrix{Char}(undef, size(old.map, 1), 2size(old.map, 2)), 
        CartesianIndex(old.robot[1], 2old.robot[2]-1),
        old.moves)
    for idx in CartesianIndices(old.map)
        sym = old.map[idx] == 'O' ? ['[', ']'] : [old.map[idx], old.map[idx]]
        new.map[idx[1], 2idx[2]-1:2idx[2]] = sym
    end
    new
end

function main()
    state = read_input(ARGS[1])
    run_moves(state, make_move)
    pprint(state)
    println("Task 1: $(sum(coords(state, 'O')))")
    state = read_input(ARGS[1])
    state = enlarge(state)
    run_moves(state, make_move_big)
    pprint(state)
    println("Task 2: $(sum(coords(state, '[')))")
end

@time main()

