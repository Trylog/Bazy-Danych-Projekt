CREATE PROCEDURE new_conversation(IN conv_name varchar(32), IN req_invitation tinyint(1), IN cAvatar mediumblob)
BEGIN
    DECLARE current_user_id int unsigned DEFAULT USER();

    INSERT INTO messengerdatabase.conversations (name, creation_date, invitation, avatar, admin_id)
        VALUES (conv_name, NOW(), req_invitation, cAvatar, current_user_id);
    CALL join_conversation(conv_name);
END;

CREATE PROCEDURE join_conversation(IN conv_name varchar(32))
BEGIN
    DECLARE conv_id int unsigned;
    DECLARE current_user_id int unsigned DEFAULT USER();
    SELECT id FROM messengerdatabase.conversations WHERE name = conv_name INTO conv_id;
    INSERT INTO messengerdatabase.conversation_members (user_id, conversation_id) VALUES (current_user_id, conv_id);
end;

CREATE PROCEDURE send_message(IN cont varchar(1024), IN conversationId int unsigned, IN answerToId int unsigned)
BEGIN
    DECLARE current_user_id int unsigned DEFAULT USER();
    INSERT INTO messengerdatabase.messages(conversation_id, user_id, content, time_of_writing, answer_to_id)
        VALUES (conversationId, current_user_id, cont, NOW(), answerToId);
end;

CREATE PROCEDURE send_interaction(IN emoticon char, IN msId int unsigned)
BEGIN
    DECLARE current_user_id int unsigned DEFAULT USER();
    INSERT INTO messengerdatabase.interactions (user_id, type_of_interaction, message_id)
        VALUES (current_user_id, emoticon, msId);
end;

create
    definer = root@localhost procedure add_moderator(IN current_user_id int unsigned,
                                                    IN current_conversation_id int unsigned)
BEGIN
    INSERT INTO messengerdatabase.moderators (user_id, conversation_id)
        VALUES (current_user_id, current_conversation_id);
end;
# usuwanie czatu
create
    definer = root@localhost procedure chat_delete(IN conv_name varchar(32))
BEGIN
    DECLARE conv_id int unsigned;
    SELECT id FROM messengerdatabase.conversations WHERE name = conv_name INTO conv_id;
    DELETE FROM messengerdatabase.conversations
        WHERE id = conv_id;
end;
# wszystkie konwersacje, do ktorych nalezy uzytkownik
create
    definer = root@localhost procedure show_conversations(IN id int unsigned)
BEGIN
    select conversation_id from messengerdatabase.conversation_members where user_id = id;
end;
# wszystkie wiadomości z danej konwersacji
create
    definer = root@localhost procedure show_messages(IN id int unsigned)
BEGIN
    select * from messengerdatabase.messages where conversation_id = id;
end;
# zmiana danych uzytkownika
CREATE PROCEDURE modify_user_data(IN new_first_name VARCHAR(32),
                                  IN new_last_name VARCHAR(32),
                                  IN new_avatar MEDIUMBLOB)
BEGIN
	DECLARE current_user_id int unsigned DEFAULT USER();

    UPDATE messengerdatabase.users
    SET first_name = new_first_name,
        last_name = new_last_name,
        avatar = new_avatar
    WHERE id = current_user_id;
END;
# usuniecie uzytkownika z konwersacji
CREATE PROCEDURE remove_user_from_conversation(IN conv_name varchar(32))
BEGIN
    DECLARE conv_id INT UNSIGNED;
    DECLARE current_user_id INT UNSIGNED DEFAULT USER();

    SELECT id FROM messengerdatabase.conversations WHERE name = conv_name INTO conv_id;

    DELETE FROM messengerdatabase.conversation_members
    WHERE user_id = current_user_id AND conversation_id = conv_id;
END;
# usuniecie wiadomosci uzytkownika
CREATE PROCEDURE delete_messages_for_user(IN messages_id INT UNSIGNED)
BEGIN
    DECLARE current_user_id int unsigned DEFAULT USER();
    # przed usunieciem wiadomosci sprawdzamy czy nie jest ona reakcja
    # jesli jest - usuwamy z tabeli reakcje
    CALL delete_reaction_for_user(messages_id);

    DELETE messages
    FROM messages
    JOIN moderators ON moderators.user_id = current_user_id
    WHERE messages.conversation_id = moderators.conversation_id AND  messages.id = messages_id;
END;
# zmiana danych konwersacji
CREATE PROCEDURE modify_conversation_data(IN conv_name varchar(32),
										  IN new_name VARCHAR(32),
                                          IN new_invitation BOOL,
                                          IN new_avatar MEDIUMBLOB)
BEGIN

DECLARE conv_id INT UNSIGNED;
SELECT id FROM messengerdatabase.conversations WHERE name = conv_name INTO conv_id;

    UPDATE messengerdatabase.conversations
    SET name = new_name,
        invitation = new_invitation,
        avatar = new_avatar
    WHERE id = conv_id;
END;
# usuwanie moderatora przez moderatora
CREATE PROCEDURE delete_moderator_by_moderator(IN new_user_id INT UNSIGNED,IN conv_name varchar(32))
BEGIN

	DECLARE conv_id INT UNSIGNED;
	SELECT id FROM messengerdatabase.conversations WHERE name = conv_name INTO conv_id;

	INSERT INTO messengerdatabase.moderators (user_id, conversation_id)
	VALUES (new_user_id, conv_id);

END;
# usuwanie moderatora
CREATE PROCEDURE delete_moderator(IN conv_name varchar(32))
BEGIN
    DECLARE current_user_id INT UNSIGNED DEFAULT USER();
	DECLARE conv_id INT UNSIGNED;

	SELECT id FROM messengerdatabase.conversations WHERE name = conv_name INTO conv_id;

	DELETE FROM messengerdatabase.moderators
	WHERE user_id = current_user_id AND conversation_id = conv_id;

END;
# usuwanie uzytkownika
CREATE PROCEDURE remove_user_from_portal(IN removed_user_id INT UNSIGNED)
BEGIN
	DELETE FROM messengerdatabase.moderators
	WHERE user_id = removed_user_id;

	DELETE FROM messengerdatabase.conversation_members
	WHERE user_id = removed_user_id;

	#todo: Usunięcie z wiadomosci

	DELETE FROM messengerdatabase.users
	WHERE id = removed_user_id;

END;
# usuniecie reakcji
CREATE PROCEDURE delete_reaction_for_user(IN removed_messages_id INT UNSIGNED)
BEGIN
    DELETE FROM interactions WHERE message_id = removed_messages_id;
END;



