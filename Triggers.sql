# pomysly na trigger:
# 1. zmiana statusu aktywnosci uzytkownika po zalogowaniu
# 2. dodatkowa tabela przechowujaca informacje o edycji wiadomosci
# 3. dodatkowa tabela przechowujaca informacje o edycji danych konwersacji

# USER_DEL tworzy rekord w tabeli removed_users z danymi usunietego uzytkownika
CREATE TRIGGER USER_DEL before DELETE ON messengerdatabase.users
    FOR EACH ROW
    BEGIN
        INSERT INTO messengerdatabase.removed_users (id, first_name, last_name)
        VALUES (old.id, old.first_name, old.last_name);
    END;


