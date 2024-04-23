%%clingo 0 instances/env1.lp -
#const n=10.
time(0..n).
%encode tracks.
track(1025, (1, 3)).

track(N, (X, Y)) :- track(N, (Y, X)).

moveDir(0, (0, 1)). %go north 
moveDir(1, (1, 0)). %go east
moveDir(2, (0, -1)). %go south
moveDir(3, (-1, 0)). %go west

revDir(0, 2). revDir(2, 0). revDir(1, 3). revDir(3, 1).

dir2int(n, 0).
dir2int(e, 1).
dir2int(s, 2).
dir2int(w, 3).

agent(A) :- start(agent(A), _, _).
action_type(move_forward). action_type(wait). %todo: add moving left and moving right.
    
{action(agent(A), Action, Timestamp)} :- start(agent(A),(X,Y),dir(D)), action_type(Action), time(Timestamp).
action(agent(A), wait, 0) :- agent(A).
action(agent(A), move_forward, 1) :- agent(A).

%one action for each agent and each timestamp
:- time(T), agent(A), not 1 {action(agent(A), _, T)} 1.

%current_state: agent(A)  is in a cell (X, Y) at timestamp T and goes at Dir (Dir is a number)
    
current_state(agent(A), (X, Y), 0, Dir) :- start(agent(A),(X,Y),dir(D)), dir2int(D, Dir).
    
%this doesn't work

current_state(agent(A), (X +  DX, Y + DY), T + 1, DirOut2) :- 
    current_state(agent(A), (X, Y), T, DirOut),
    action(agent(A), move_forward, T + 1),
    cell((X, Y,), Type),
    cell((X + DX, Y + DX), Type2),
    track(Type, (_, DirOut)),
    track(Type2, (DirIn,DirOut2)),
    revDir(DirIn, DirOut),
    moveDir(DirOut, (DX, DY)).

current_state(agent(A), (X, Y), T + 1, Dir) :- current_state(agent(A), (X, Y), T, Dir), action(agent(A), wait, T + 1).   
:- end(agent(A), (X, Y)), not current_state(agent(A), (X, Y), _, _).


#show action/3.
%#show current_state/4.
