%%clingo 0 instances/env2.lp -
%%file encoding_orig.lp
%%clingo 0 instances/env4.lp -



% #const n=5.

%_________________Encode Tracks____________________

% straight tracks
track(1025, (1, 3)). track(32800, (0, 2)). track(4608, (3, 2)). track(16386, (2, 1)). track(72, (0, 1)). track(2064, (0, 3)).

% simple switch
track(3089, (3, 1)). track(3089, (3, 0)). track(37408, (3, 2)). track(37408, (0, 2)). track(17411, (2, 3)). track(17411, (1, 3)).
track(32872, (0, 1)). track(32872, (0, 2)). track(49186, (0, 2)). track(49186, (2, 1)). track(1097, (1, 3)). track(1097, (0, 1)).
track(34864, (3, 0)). track(34864, (0, 2)). track(5633, (3, 1)). track(5633, (3, 2)).

% diamond crossing
track(33825, (0, 2)). track(33825, (1, 3)).

% diamond plus crossing
track(38433, (0, 2)). track(38433, (1, 3)). track(38433, (3, 2)). track(50211, (0, 2)). track(50211, (1, 3)). track(50211, (2, 1)).
track(33897, (0, 2)). track(33897, (1, 3)). track(33897, (0, 1)). track(35889, (0, 2)). track(35889, (1, 3)). track(35889, (0, 3)).
track(38505, (0, 2)). track(38505, (1, 3)). track(38505, (3, 2)). track(38505, (0, 1)).
track(52275, (0, 2)). track(52275, (1, 3)). track(52275, (2, 1)). track(52275, (0, 3)).

% double curve crossing
track(20994, (1, 2)). track(20994, (2, 3)). track(16458, (0, 1)). track(16458, (1, 2)). 
track(2136, (0, 1)). track(2136, (3, 0)). track(6672, (2, 3)). track(6672, (3, 0)).

% track end
% track(8192, (2, end)). track(4, (1, end)). track(128, (0, end)). track(256, (3, end)).

track(N, (X, Y)) :- track(N, (Y, X)).

moveDir(0, (-1, 0)). % go north 
moveDir(1, (0, 1)). % go east
moveDir(2, (1, 0)). % go south
moveDir(3, (0, -1)). % go west

revDir(0, 2). revDir(2, 0). revDir(1, 3). revDir(3, 1).

dir2int(n, 0).
dir2int(e, 1).
dir2int(s, 2).
dir2int(w, 3).

% move left: track turns left, other option exists
move(Type, DirL, move_left):- track(Type, (DirIn, DirL)), track(Type, (DirIn, DirR)), DirL = DirIn + 1, DirL != DirR.
move(Type, 0, move_left):- track(Type, (3, 0)), track(Type, (3, DirR)), DirR > 0.

% move right: track turns right, other option exists
move(Type, DirR, move_right):- track(Type, (DirIn, DirL)), track(Type, (DirIn, DirR)), DirR = DirIn - 1, DirL != DirR.
move(Type, 3, move_right):- track(Type, (0, 3)), track(Type, (0, DirL)), DirL < 3.

    
move(Type, DirOut, move_forward) :- track(Type, (DirIn, DirOut)), |DirOut - DirIn| = 2.
move(Type, DirOut, move_forward) :- track(Type, (DirIn, DirOut)),
    not move(Type, DirOut, move_left),
    not move(Type, DirOut, move_right).    

%_________________Generate__________________________

agent(A) :- start(agent(A), _, _, _).
action_type(move_forward). action_type(wait). action_type(move_left). action_type(move_right).

#program base. 
action(agent(A), wait, 0) :- agent(A).
current_state(agent(A), (Y,X), 0, Dir) :- start(agent(A),(Y,X),_,dir(D)), dir2int(D, Dir).
    
#program check(t).
:- end(agent(A), (Y,X), LatestArrival), query(t), not current_state(agent(A), (Y,X), t, _).
    
% construct the table for the original plan
orig(agent(A), (Y,X), t-1, (NextY, NextX)) :- current_state(agent(A), (Y,X), t-1, _), current_state(agent(A), (NextY, NextX), t, _).

#program step(t).
% one action for each agent and each timestamp   
1 {action(agent(A), Action, t): action_type(Action)} 1 :- agent(A).

% cant do anything other than wait before earliest departure time
:- start(agent(A), _, EarliestDeparture, _), current_state(agent(A), (Y,X), t, DirOut), EarliestDeparture > t, not action(agent(A), wait, t).

% position in the next timestep changes based on track type and movement 
current_state(agent(A), (Y + DY, X+DX), t, DirOut2) :- current_state(agent(A), (Y,X), t - 1, DirOut),
    action(agent(A), Action, t), cell((Y,X), Type), cell((Y + DY, X+DX), Type2),
    track(Type, (_, DirOut)), track(Type2, (DirIn,DirOut2)), move(Type, DirOut, Action),
    revDir(DirIn, DirOut), moveDir(DirOut, (DY,DX)).

% when waiting the position doesn't change
current_state(agent(A), (Y,X), t, Dir) :- current_state(agent(A), (Y,X), t - 1, Dir), action(agent(A), wait, t).

:- action(agent(A), _, t), not current_state(agent(A), _, t, _).

% vertex conflict
:- current_state(agent(A1), (Y,X), t, _), current_state(agent(A2), (Y,X), t, _), A1 < A2.
:- current_state(agent(A), (Y, X), t, _), current_state(agent(B), (Y, X), t - 1, _), A != B.

    
#show action/3.
#show orig/4.