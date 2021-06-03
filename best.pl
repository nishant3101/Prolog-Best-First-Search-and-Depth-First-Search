%find path controls the whole flow of the initial system.
%State record is kept as [State, Parent, Distance from source, heuristic]

%[State,Paremt,Distance_from_parent,heuristic value]

:-dynamic(distance_gen/3).
:-dynamic(heuristics/3).
:-[depth].
%--------------------------------------------------Creating knowledge base----------------------------------------

check_h:-csv_read_file('C:/Users/hp/Desktop/IIITD/SEM-7/AI/Assignment-2/AI-A2-Nishant-2017171/heuristic_data.csv',Rows1,[functor(heuristic_data), arity(48)]),maplist(assert, Rows1),
setof([A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P,Q,R,S,T,U,V,W,X,Y,Z,AA,AB,AC,AD,AE,AF,AG,AH,AI,AJ,AK,AL,AM,AN,AO,AP,AQ,AR,AS,AT,AU,AV], heuristic_data(A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P,Q,R,S,T,U,V,W,X,Y,Z,AA,AB,AC,AD,AE,AF,AG,AH,AI,AJ,AK,AL,AM,AN,AO,AP,AQ,AR,AS,AT,AU,AV), AZ),nl,extract_header_h(AZ).


assign_head_h([H|T],H).
remove_head_h([_|T],T).
extract_header_h(Data):-
	assign_head_h(Data,H),
	remove_head_h(Data,NewData),
	remove_head_h(H,Header),
	%print(Header),nl,nl,nl,
	%print(NewData),nl,nl,nl,
	%print_for_single_city(NewData,Header).
	pred_gen_all_city_h(NewData,Header).

extractdistances_h([Cityname|Distances],Cityname,Distances).

pred_gen_single_city_h(_,[]).
pred_gen_single_city_h([City1name|[CurDist|OtherDist]],[City2name|Tcity2]):-
	%atom_number(CurDist,CurDist1),
	asserta(heuristics(City1name,City2name,CurDist)),
	asserta(heuristics(City2name,City1name,CurDist)),
	%print(City1name),nl,print(City2name),nl,print(CurDist),nl,
	pred_gen_single_city_h([City1name|OtherDist],Tcity2).


print_for_single_city_h([H|T],Distances):-
	pred_gen_single_city_h(H,Distances).

pred_gen_all_city_h([],_):-
	write('Heuristics added in the knowledge base').

pred_gen_all_city_h([H|T],Distances):-
	pred_gen_single_city_h(H,Distances),
	pred_gen_all_city_h(T,Distances).

%------------------------------------------------------------------
start:-
	write('Source City:'),
	read(City1),
	write('Destination City:'),
	read(City2),
	write('1 for DFS and 2 for Best First Search'),
	read(X),
	find_option(X,City1,City2).

find_option(1,City1,City2):-
	write('Executing Depth first search method'),nl,nl,
	find_dfs(City1,City2).

find_option(2,City1,City2):-
	write('Executing Best first search method'),nl,nl,
	find_path(City1,City2).
%----------------------------------------------------------Best First code--------------------------------------------

find_path(Start,Goal):-
	empty_closed(Closed),
	empty_open(Open),
	heuristics(Start,Goal,H),
	insert_state_in_open([Start,nil,0,H],Open,New_open),
	search_further(New_open,Closed,Goal).

empty_closed([]).
empty_open([]).

reverse_print_stack(S) :-
	empty_stack(S).
reverse_print_stack(S) :-
	stack([State,_,_,_], Rest, S),
	%reverse_print_stack(Rest),
	write(State), nl.

empty_stack([]).
stack(Start,Es,[Start|Es]).


%3 cases for search :- 1. what if open is empty. 2. What is the next state is goal, 3. more search requried
search_further(Open,_,_):-
	empty_open(Open),
	write('No path found'),nl.

search_further(Open,Closed,Goal):-
	pop_from_open([Current_state,Parent,Costbob,_],Open,_),
	Current_state=Goal,
	write('Path found:'),nl,
	printsolution_h([Current_state, Parent,_, _],Closed),
	pop_from_open([Last_state,_,Cost,_],Closed,_),
	distance_gen(Last_state,Goal,X),
	Total_cost is X + Cost,nl,
	write('Total_cost is:'),nl,
	print(Costbob),!.
	%reverse_print_stack(Closed),
	%write(Goal).

search_further(Open,Closed,Goal):-
	pop_from_open([Current_state,Parent,D,H],Open,New_open),
	find_children_nodes([Current_state,Parent,D,H],New_open,Closed,Children,Goal),
	insert_list_in_open(Children,New_open,Updated_open),
	insert_in_closed([[Current_state,Parent,D,H]],Closed,New_closed),
	search_further(Updated_open,New_closed,Goal),!.

%define pop_from_open, insert_in_open,insert_in_closed,find_children_nodes,member_closed,member_open

find_children_nodes([Parent_node,_,Parent_dist, _],Updated_open,Updated_closed,Children,Goal) :-
	findall(Child, find_child([Parent_node,_,Parent_dist, _],Updated_open, Updated_closed, Child,Goal),Children).

find_child([Parent_node,_,Parent_dist, _], Updated_open,Updated_closed,[Next,Parent_node,New_Dist,H], Goal) :-
	distance_gen(Parent_node,Next,Dist),
	not(member_open([Next,_,_,_],Updated_open)),
	not(member_closed([Next,_,_, _],Updated_closed)),
	New_Dist is Parent_dist + Dist ,
	heuristics(Next, Goal, H).

%--------------------------------------------------HELPER FUNCTIONS------------------------------------------------------------

comparator([_,_,_,H1], [_,_,_,H2]):-
	H1=<H2.


insert_state_in_open(Current_state,[],[Current_state]):-!.
insert_state_in_open(Current_state,[H|T],[Current_state,H|T]):-
	comparator(Current_state,H).

insert_state_in_open(Current_state,[H|T],[H|T1]):-
	insert_state_in_open(Current_state,T,T1).

insert_list_in_open([],L,L).
insert_list_in_open([State|T],L,Lnew):-
	insert_state_in_open(State,L,Lmid),
	insert_list_in_open(T,Lmid,Lnew).

member_open(State,Open):-
	member(State,Open).

member_closed(State,Closed):-
	member(State,Closed).

add_if_not_in_set(X, S, S) :-
	member(X, S), !.

add_if_not_in_set(X, S, [X | S]).

insert_in_closed([], S, S).
insert_in_closed([H | T], S, S_new) :-
	insert_in_closed(T, S, S2),
	add_if_not_in_set(H, S2, S_new),!.

pop_from_open(E, [E | T], T).
pop_from_open(E, [E | T], _).

member(X, [X | _]).
member(X, [Y | T]) :- member(X, T).

printsolution_h([State, nil,_, _], _) :-
	write(State), nl,!.

printsolution_h([State, Parent, _, _], Closed_set):-
	not(same(State,Parent)),
	member_closed([Parent, Grandparent, _, _],Closed_set),
	printsolution_h([Parent, Grandparent,_, _],Closed_set),
	write(State), nl.

same(X1,X1).