# pomysly na trigger:
# 1. zmiana statusu aktywnosci uzytkownika po zalogowaniu
# 2. dodatkowa tabela przechowujaca informacje o edycji wiadomosci
# 3. dodatkowa tabela przechowujaca informacje o edycji danych konwersacji

# USER_DEL tworzy rekord w tabeli removed_users z danymi usunietego uzytkownika
CREATE TRIGGER USER_DEL AFTER DELETE ON messengerdatabase.users
    FOR EACH ROW
    BEGIN
        INSERT INTO messengerdatabase.removed_users (id, first_name, last_name)
        VALUES (old.id, old.first_name, old.last_name);
    END;

# CON_DEL usuwa dane konwersacji we wszystkich tabelach z kluczem obcym zanim usunie rekord z tabeli conversations
CREATE TRIGGER CON_DEL BEFORE DELETE ON messengerdatabase.conversations
    FOR EACH ROW
    BEGIN
        DELETE FROM messengerdatabase.conversation_members
        WHERE conversation_id = old.id;
        DELETE FROM messengerdatabase.messages
        WHERE conversation_id = old.id;
        DELETE FROM messengerdatabase.moderators
        WHERE conversation_id = old.id;
    END;

