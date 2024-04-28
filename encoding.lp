%%clingo 0 instances/env4.lp -
#const n=9.
time(1..n).

%encode tracks.

%straight tracks
track(1025, (1, 3)).
track(32800, (0, 2)).

track(4608, (3, 2)).
track(16386, (2, 1)).
track(72, (0, 1)).
track(2064, (0, 3)).

%simple switch
track(3089, (3, 1)).
track(3089, (3, 0)).

track(37408, (3, 2)).
track(37408, (0, 2)).

track(17411, (2, 3)).
track(17411, (1, 3)).

track(32872, (0, 1)).
track(32872, (0, 2)).

track(49186, (0, 2)).
track(49186, (2, 1)).

track(1097, (1, 3)).
track(1097, (0, 1)).

track(34864, (3, 0)).
track(34864, (0, 2)).

track(5633, (3, 1)).
track(5633, (3, 2)).

%diamond crossing

track(33825, (0, 2)).
track(33825, (1, 3)).

%diamond plus crossing
track(38433, (0, 2)).
track(38433, (1, 3)).
track(38433, (3, 2)).

track(50211, (0, 2)).
track(50211, (1, 3)).
track(50211, (2, 1)).

track(33897, (0, 2)).
track(33897, (1, 3)).
track(33897, (0, 1)).

track(35889, (0, 2)).
track(35889, (1, 3)).
track(35889, (0, 3)).

track(38505, (0, 2)).
track(38505, (1, 3)).
track(38505, (3, 2)).
track(38505, (0, 1)).

track(38505, (0, 2)).
track(38505, (1, 3)).
track(38505, (2, 1)).
track(38505, (0, 3)).

%double curve crossing
track(20994, (1, 2)).
track(20994, (2, 3)).

track(16458, (0, 1)).
track(16458, (1, 2)).

track(2136, (0, 1)).
track(2136, (3, 0)).

track(6672, (2, 3)).
track(6672, (3, 0)).

%track end
track(8192, (2, end)).
track(4, (1, end)).
track(128, (0, end)).
track(256, (3, end)).

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

%define tracks where we can turn left or right. This does not work with symmetrical switch
move(Type, DirL, move_left) :- track(Type, (DirIn, DirL)), track(Type, (DirIn, DirR)), (DirR - DirL) \ 4 = 1, |DirR - DirIn| = 2.
move(Type, DirR, move_right) :- track(Type, (DirIn, DirL)), track(Type, (DirIn, DirR)), (DirR - DirL) \ 4 = 1, |DirL - DirIn| = 2.

%define tracks where we move forward. 
move(Type, DirOut, move_forward) :- track(Type, (DirIn, DirOut)), |DirOut - DirIn| = 2.
move(Type, DirOut, move_forward) :- track(Type, (DirIn, DirOut)),
    not move(Type, DirOut, move_left),
    not move(Type, DirOut, move_right).    
    
agent(A) :- start(agent(A), _, _).
action_type(move_forward). action_type(wait).
action_type(move_left). action_type(move_right).
    
{action(agent(A), Action, Timestamp)} :- start(agent(A),(X,Y),dir(D)), action_type(Action), time(Timestamp).
    
%action(agent(A), wait, 0) :- agent(A).
%one action for each agent and each timestamp
:- time(T), agent(A), not 1 {action(agent(A), _, T)} 1.
     
current_state(agent(A), (X, Y), 0, Dir) :- start(agent(A),(X,Y),dir(D)), dir2int(D, Dir).  
    
current_state(agent(A), (X +  DX, Y + DY), T + 1, DirOut2) :- 
    current_state(agent(A), (X, Y), T, DirOut),
    action(agent(A), Action, T + 1),
    cell((X, Y,), Type),
    cell((X + DX, Y + DY), Type2),
    track(Type, (_, DirOut)),
    track(Type2, (DirIn,DirOut2)),
    move(Type, DirOut, Action),
    revDir(DirIn, DirOut),
    moveDir(DirOut, (DX, DY)).

current_state(agent(A), (X, Y), T + 1, Dir) :- current_state(agent(A), (X, Y), T, Dir), action(agent(A), wait, T + 1).
    
:- action(agent(A), _, T), not current_state(agent(A), _, T, _).

:-current_state(agent(A1), (X, Y), T, _), current_state(agent(A2), (X, Y), T, _), A1 < A2.
    
%agents have to reach destination
:- end(agent(A), (X, Y)), not current_state(agent(A), (X, Y), _, _).

    
#show action/3.
%#show current_state/4.
%#show move/3.
