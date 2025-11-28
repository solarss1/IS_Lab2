/*************************************************************
 * Онтологія: Тварини, анатомія та середовище існування
 *************************************************************/

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% ОГОЛОШЕННЯ КЛАСІВ
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

class(entity).
class(living_organism).
class(animal).
class(vertebrate).
class(mammal).
class(bird).
class(fish).

class(domestic_animal).
class(wild_animal).
class(fur_bearing_animal).

class(dog).
class(cat).
class(cow).
class(horse).

class(body_part).
class(tail).
class(paw).
class(head).
class(fur).

class(environment).
class(habitat).
class(dog_house).
class(barn).
class(forest).
class(river).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% ІЄРАРХІЯ is_a (успадкування)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Верхній рівень
is_a(living_organism, entity).
is_a(animal, living_organism).
is_a(vertebrate, animal).
is_a(mammal, vertebrate).

% Інші гілки
is_a(bird, vertebrate).
is_a(fish, vertebrate).

% Домашні / дикі
is_a(domestic_animal, mammal).
is_a(wild_animal, mammal).

% Конкретні види як практичні класи
is_a(dog, domestic_animal).
is_a(cat, domestic_animal).
is_a(cow, domestic_animal).
is_a(horse, domestic_animal).

% Хутрові тварини
is_a(fur_bearing_animal, mammal).
is_a(dog, fur_bearing_animal).
is_a(cat, fur_bearing_animal).

% Анатомія
is_a(body_part, entity).
is_a(tail, body_part).
is_a(paw, body_part).
is_a(head, body_part).
is_a(fur, body_part).

% Середовище
is_a(environment, entity).
is_a(habitat, environment).
is_a(dog_house, habitat).
is_a(barn, habitat).
is_a(forest, habitat).
is_a(river, habitat).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% ВІДНОШЕННЯ part_of (частина-ціле)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Частини тіла собаки як класу
part_of(tail, dog).
part_of(paw, dog).
part_of(head, dog).

% Частини кота
part_of(tail, cat).
part_of(paw, cat).
part_of(head, cat).

% Шерсть як частина частин
part_of(fur, tail).
part_of(fur, paw).
part_of(fur, head).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% ВІДНОШЕННЯ lives_in (живе_в)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% На рівні класів
lives_in(dog, dog_house).
lives_in(cat, house).        
lives_in(cow, barn).
lives_in(horse, barn).
lives_in(wild_animal, forest).
lives_in(fish, river).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% ІНСТАНСИ (instance_of)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Собаки
instance_of(bobik, dog).
instance_of(rex, dog).

% Коти
instance_of(murchik, cat).
instance_of(luna, cat).

% Корови
instance_of(zorka, cow).
instance_of(milka, cow).

% Коні
instance_of(spirit, horse).
instance_of(bay, horse).

% Будки
instance_of(dog_house_1, dog_house).
instance_of(dog_house_2, dog_house).

% Хліви
instance_of(barn_1, barn).
instance_of(barn_2, barn).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% ДОПОМІЖНІ ПРАВИЛА УСПАДКУВАННЯ
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Транзитивне is_a
isa_transitive(X, Y) :-
    is_a(X, Y).
isa_transitive(X, Y) :-
    is_a(X, Z),
    isa_transitive(Z, Y).

% Включно з самим собою (зручно для властивостей)
isa_or_self(X, X).
isa_or_self(X, Y) :-
    isa_transitive(X, Y).

% Транзитивне part_of
part_of_transitive(X, Y) :-
    part_of(X, Y).
part_of_transitive(X, Y) :-
    part_of(X, Z),
    part_of_transitive(Z, Y).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% ГРАФ ЗВ'ЯЗКІВ edge/2
%% (один крок по будь-якому відношенню)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

edge(X, Y) :- is_a(X, Y).
edge(X, Y) :- is_a(Y, X).

edge(X, Y) :- part_of(X, Y).
edge(X, Y) :- part_of(Y, X).

edge(X, Y) :- lives_in(X, Y).
edge(X, Y) :- lives_in(Y, X).

edge(Inst, Class) :- instance_of(Inst, Class).
edge(Class, Inst) :- instance_of(Inst, Class).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% ЗАГАЛЬНИЙ ПРЕДИКАТ connected/2
%% Чи існує хоч якийсь ланцюжок зв'язків між X та Y?
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

connected(X, Y) :-
    path(X, Y, [X]).

% Прямий зв'язок
path(X, Y, _) :-
    edge(X, Y), !.

% Непрямий (рекурсивний) зв'язок
path(X, Y, Visited) :-
    edge(X, Z),
    \+ member(Z, Visited),
    path(Z, Y, [Z|Visited]).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% ПРАВИЛА ДЛЯ НЕТРИВІАЛЬНИХ ЗАПИТІВ
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% has_part(Whole, Part):
% Чи є Part частиною Whole (на рівні класів + транзитивно)?
has_part(Whole, Part) :-
    part_of_transitive(Part, Whole).

% parts_of(Whole, Part):
% універсальний, щоб питати "які частини має X?"
parts_of(Whole, Part) :-
    part_of_transitive(Part, Whole).

% has_fur(X):
% Має шерсть, якщо:
% - X є (прямо або через is_a) fur_bearing_animal, або
% - у X чи його частин є fur як part_of
has_fur(X) :-
    % Як клас: належить до хутрових
    isa_or_self(X, fur_bearing_animal), !.
has_fur(X) :-
    % Як клас: fur є частиною X
    part_of_transitive(fur, X), !.
has_fur(Inst) :-
    % Як інстанс: його клас має шерсть
    instance_of(Inst, Class),
    has_fur(Class).

% all_fur_bearing(X):
% Генерує всі X, які мають шерсть.
all_fur_bearing(X) :-
    ( class(X) ; instance_of(X, _) ),
    has_fur(X).

% lives_in_instance(Inst, Place):
% Де живе конкретний інстанс, успадковуючи з класу.
lives_in_instance(Inst, Place) :-
    instance_of(Inst, Class),
    lives_in(Class, Place).

% all_ancestors(Class, Ancestor):
% Усі предки класу у ієрархії is_a.
all_ancestors(Class, Ancestor) :-
    isa_transitive(Class, Ancestor).

% related_via(X, Y):
% Синонім до connected/2 для людських формулювань.
related_via(X, Y) :-
    connected(X, Y).

