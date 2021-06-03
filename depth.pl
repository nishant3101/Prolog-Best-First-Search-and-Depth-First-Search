
:-dynamic(distance_gen/3).

%--------------------------------------------------Creating knowledge base----------------------------------------

check:-csv_read_file('C:/Users/hp/Desktop/IIITD/SEM-7/AI/Assignment-2/AI-A2-Nishant-2017171/roaddistance1.csv',Rows,[functor(citydist), arity(21)]),maplist(assert, Rows),
setof([A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P,Q,R,S,T,U], citydist(A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P,Q,R,S,T,U), Z),nl,extract_header(Z).


assign_head([H|T],H).
remove_head([_|T],T).
extract_header(Data):-
	assign_head(Data,H),
	remove_head(Data,NewData),
	remove_head(H,Header),
	%print(Header),nl,nl,nl,
	%print(NewData),nl,nl,nl,
	%print_for_single_city(NewData,Header).
	pred_gen_all_city(NewData,Header).

extractdistances([Cityname|Distances],Cityname,Distances).

pred_gen_single_city(_,[]).

pred_gen_single_city([City1name|[CurDist|OtherDist]],[City2name|Tcity2]):-
	%atom_number(CurDist,CurDist1),
	asserta(distance_gen(City1name,City2name,CurDist)),
	asserta(distance_gen(City2name,City1name,CurDist)),
	%print(City1name),nl,print(City2name),nl,print(CurDist),nl,
	pred_gen_single_city([City1name|OtherDist],Tcity2).


print_for_single_city([H|T],Distances):-
	pred_gen_single_city(H,Distances).

pred_gen_all_city([],_):-
	write('Distances added in the knowledge base').

pred_gen_all_city([H|T],Distances):-
	pred_gen_single_city(H,Distances),
	pred_gen_all_city(T,Distances).



%----------------------------------------------------------DFS CODE--------------------------------------------------------------------

find_dfs(Start,Goal):-
	empty_open(Start_open),
	stack([Start,nil,0],Start_open,Open),
	empty_closed(Closed),
	search(Open,Closed,Goal).

search(Open,_,_):-
	empty_open(Open),
	write('No path found').

search(Open,Closed,Goal):-
	stack([State,Parent,Cost],_,Open),
	State=Goal,
	write('Path found:'),nl,
	%print(Closed),nl,
	printsolution_dfs([State,Parent,Cost],Closed),nl,
	write('Total cost is:'),nl,
	print(Cost).

search(Open,Closed,Goal):-
	stack([State,Parent,D],Popped_open,Open),
	find_children([State,Parent,D],Popped_open,Closed,Children),
	add_to_stack(Children, Popped_open, Updated_open),
	insert_in_closed([[State,Parent,D]],Closed,Updated_closed),
	search(Updated_open,Updated_closed,Goal),!.

find_children([State,_,D], Rest_open_stack, Closed_set, Children) :-
	findall(Child, moves_dfs([State,_,D], Rest_open_stack, Closed_set, Child), Children).

moves_dfs([State,_,OldDist], Rest_open_stack, Closed_set, [Next,State,NewDist]) :-
	distance_gen(State,Next,Dist),
	NewDist is OldDist+Dist,
	%Dist is NewDist - OldDist,
	%is(NewDist,+(OldDist,Dist)),
	not(member_stack([Next,_,_], Rest_open_stack)),
	not(member_set([Next,_,_], Closed_set)).


printsolution_dfs([State, nil,_], _) :- 
	write(State), nl.

printsolution_dfs([State, Parent,_], Closed_set) :-
	not(same(State,Parent)),
	member_set([Parent, Grandparent,_], Closed_set),
	printsolution_dfs([Parent, Grandparent,_], Closed_set),
	write(State), nl.

%-----------------------------------------HELPER FUNCTIONS-------------------------------------------------------

same(X1,X1).

empty_open([]).

stack(Start,Es,[Start|Es]).

empty_closed([]).

member(X, [X | _]).
member(X, [Y | T]) :- member(X, T).

member_set(State,Closed):-
	member(State,Closed).


add_to_stack(List, Stack, Result) :-
	append(List, Stack, Result).

member_stack(Element, Stack) :-
	member(Element, Stack).

member_closed(State,Closed):-
	member(State,Closed).

add_if_not_in_set(X, S, S) :-
	member(X, S), !.

add_if_not_in_set(X, S, [X | S]).

insert_in_closed([], S, S).
insert_in_closed([H | T], S, S_new) :-
	insert_in_closed(T, S, S2),
	add_if_not_in_set(H, S2, S_new),!.
