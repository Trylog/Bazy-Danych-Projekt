delimiter //
CREATE DEFINER = root@localhost
PROCEDURE new_conversation(IN conv_name varchar(32), IN req_invitation tinyint(1), IN cAvatar mediumblob)
SQL SECURITY DEFINER
BEGIN

    DECLARE last_id INT DEFAULT 0;

    DECLARE current_username VARCHAR(100);
    DECLARE current_user_id INT UNSIGNED;

    SET current_username = USER();
    IF current_username = 'root' THEN
        SET current_user_id = 0;
    ELSE
        SET current_user_id = cast(SUBSTRING(current_username, 1, LENGTH(current_username) - LOCATE('@', REVERSE(current_username))) AS UNSIGNED);
    end if;

    INSERT INTO messengerdatabase.conversations (name, creation_date, invitation, avatar, admin_id)
        VALUES (conv_name, NOW(), req_invitation, cAvatar, current_user_id);
    CALL join_conversation(conv_name);
    SET last_id = LAST_INSERT_ID();
    INSERT INTO messengerdatabase.moderators (user_id, conversation_id) VALUES (current_user_id, last_id);
END//
delimiter ;

DELIMITER //
CREATE PROCEDURE join_conversation(IN conv_name varchar(32))
BEGIN
    DECLARE conv_id int unsigned;
    DECLARE current_username VARCHAR(100);
    DECLARE current_user_id INT UNSIGNED;

    SET current_username = USER();
    IF current_username = 'root' THEN
        SET current_user_id = 0;
    ELSE
        SET current_user_id = cast(SUBSTRING(current_username, 1, LENGTH(current_username) - LOCATE('@', REVERSE(current_username))) AS UNSIGNED);
    end if;
    SELECT id FROM messengerdatabase.conversations WHERE name = conv_name INTO conv_id;
    INSERT INTO messengerdatabase.conversation_members (user_id, conversation_id) VALUES (current_user_id, conv_id);
end //
delimiter ;

DELIMITER //
CREATE PROCEDURE send_message(IN cont varchar(1024), IN conversationId int unsigned, IN answerToId int unsigned)
BEGIN
    DECLARE current_username VARCHAR(100);
    DECLARE current_user_id INT UNSIGNED;

    SET current_username = USER();
    IF current_username = 'root' THEN
        SET current_user_id = 0;
    ELSE
        SET current_user_id = cast(SUBSTRING(current_username, 1, LENGTH(current_username) - LOCATE('@', REVERSE(current_username))) AS UNSIGNED);
    end if;
    INSERT INTO messengerdatabase.messages(conversation_id, user_id, content, time_of_writing, answer_to_id)
        VALUES (conversationId, current_user_id, cont, NOW(), answerToId);
end //
delimiter ;

DELIMITER //
CREATE PROCEDURE send_interaction(IN emoticon char, IN msId int unsigned)
BEGIN
    DECLARE current_username VARCHAR(100);
    DECLARE current_user_id INT UNSIGNED;

    SET current_username = USER();
    IF current_username = 'root' THEN
        SET current_user_id = 0;
    ELSE
        SET current_user_id = cast(SUBSTRING(current_username, 1, LENGTH(current_username) - LOCATE('@', REVERSE(current_username))) AS UNSIGNED);
    end if;
    INSERT INTO messengerdatabase.interactions (user_id, type_of_interaction, message_id)
        VALUES (current_user_id, emoticon, msId);
end //
delimiter ;

DELIMITER //
CREATE PROCEDURE add_moderator(IN current_user_id int unsigned, IN current_conversation_id int unsigned)
BEGIN
    DECLARE user_count int;
    SELECT count(id) from messengerdatabase.users WHERE id = current_user_id INTO user_count;
    IF user_count > 0 THEN
        INSERT INTO messengerdatabase.moderators (user_id, conversation_id) VALUES (current_user_id, current_conversation_id);
    ELSE
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: Moderator does not exist as a user.';
    end if;
end //
delimiter ;

DELIMITER //
# usuwanie czatu
create definer = root@localhost procedure chat_delete(IN conv_name varchar(32))
    sql security definer
BEGIN
    DECLARE conv_id int unsigned;
    SELECT id FROM messengerdatabase.conversations WHERE name = conv_name INTO conv_id;
    DELETE FROM messengerdatabase.conversations WHERE id = conv_id;
end //
delimiter ;

DELIMITER //
# wszystkie konwersacje, do ktorych nalezy uzytkownik
create
    definer = root@localhost procedure show_conversations(IN id int unsigned)
BEGIN
    select conversation_id from messengerdatabase.conversation_members where user_id = id;
end //
delimiter ;

DELIMITER //
# wszystkie wiadomości z danej konwersacji
create
    definer = root@localhost procedure show_messages(IN id int unsigned)
BEGIN
    select * from messengerdatabase.messages where conversation_id = id;
end //
delimiter ;

DELIMITER //
# zmiana danych uzytkownika
CREATE PROCEDURE modify_user_data(IN new_first_name VARCHAR(32), IN new_last_name VARCHAR(32), IN new_avatar MEDIUMBLOB)
BEGIN
	DECLARE current_username VARCHAR(100);
    DECLARE current_user_id INT UNSIGNED;

    SET current_username = USER();
    IF current_username = 'root' THEN
        SET current_user_id = 0;
    ELSE
        SET current_user_id = cast(SUBSTRING(current_username, 1, LENGTH(current_username) - LOCATE('@', REVERSE(current_username))) AS UNSIGNED);
    end if;

    UPDATE messengerdatabase.users
    SET first_name = new_first_name, last_name = new_last_name, avatar = new_avatar WHERE id = current_user_id;
END //
delimiter ;

DELIMITER //
# usuniecie uzytkownika z konwersacji
CREATE PROCEDURE remove_user_from_conversation(IN conv_name varchar(32))
BEGIN
    DECLARE conv_id INT UNSIGNED;
    DECLARE current_username VARCHAR(100);
    DECLARE current_user_id INT UNSIGNED;

    SET current_username = USER();
    IF current_username = 'root' THEN
        SET current_user_id = 0;
    ELSE
        SET current_user_id = cast(SUBSTRING(current_username, 1, LENGTH(current_username) - LOCATE('@', REVERSE(current_username))) AS UNSIGNED);
    end if;

    SELECT id FROM messengerdatabase.conversations WHERE name = conv_name INTO conv_id;

    DELETE FROM messengerdatabase.conversation_members WHERE user_id = current_user_id AND conversation_id = conv_id;
END //
delimiter ;

DELIMITER //
# usuniecie wiadomosci uzytkownika
CREATE PROCEDURE delete_message(IN messages_id INT UNSIGNED)
BEGIN
    DECLARE current_username VARCHAR(100);
    DECLARE current_user_id INT UNSIGNED;

    SET current_username = USER();
    IF current_username = 'root' THEN
        SET current_user_id = 0;
    ELSE
        SET current_user_id = cast(SUBSTRING(current_username, 1, LENGTH(current_username) - LOCATE('@', REVERSE(current_username))) AS UNSIGNED);
    end if;
    #CALL delete_message_reactions(messages_id);
    DELETE FROM messengerdatabase.messages WHERE id = messages_id AND user_id = current_user_id;

END //
delimiter ;

DELIMITER //
# zmiana danych konwersacji
CREATE PROCEDURE modify_conversation_data(IN conv_name varchar(32), IN new_name VARCHAR(32), IN new_invitation BOOL, IN new_avatar MEDIUMBLOB)
BEGIN
    DECLARE conv_id INT UNSIGNED;
    SELECT id FROM messengerdatabase.conversations WHERE name = conv_name INTO conv_id;

    UPDATE messengerdatabase.conversations SET name = new_name, invitation = new_invitation, avatar = new_avatar WHERE id = conv_id;
END //
delimiter ;

DELIMITER //
# usuwanie moderatora przez moderatora
CREATE PROCEDURE delete_moderator_by_moderator(IN new_user_id INT UNSIGNED,IN conv_name varchar(32))
BEGIN

	DECLARE conv_id INT UNSIGNED;
	SELECT id FROM messengerdatabase.conversations WHERE name = conv_name INTO conv_id;

	INSERT INTO messengerdatabase.moderators (user_id, conversation_id)
	VALUES (new_user_id, conv_id);

END //
delimiter ;

DELIMITER //
# usuwanie moderatora
CREATE PROCEDURE delete_moderator(IN conv_name varchar(32))
BEGIN
    DECLARE conv_id INT UNSIGNED;
    DECLARE current_username VARCHAR(100);
    DECLARE current_user_id INT UNSIGNED;

    SET current_username = USER();
    IF current_username = 'root' THEN
        SET current_user_id = 0;
    ELSE
        SET current_user_id = cast(SUBSTRING(current_username, 1, LENGTH(current_username) - LOCATE('@', REVERSE(current_username))) AS UNSIGNED);
    end if;

	SELECT id FROM messengerdatabase.conversations WHERE name = conv_name INTO conv_id;

	DELETE FROM messengerdatabase.moderators WHERE user_id = current_user_id AND conversation_id = conv_id;

END //
delimiter ;

DELIMITER //
# usuwanie uzytkownika
CREATE PROCEDURE remove_user_from_portal(IN removed_user_id INT UNSIGNED)
BEGIN
	DELETE FROM messengerdatabase.moderators WHERE user_id = removed_user_id;
	DELETE FROM messengerdatabase.conversation_members WHERE user_id = removed_user_id;
	UPDATE messengerdatabase.users SET avatar = null, status = 'not active', is_deleted = 'true' WHERE id = removed_user_id;
END //
delimiter ;

DELIMITER //
# wszytstkich reakcji z wiadomości
CREATE PROCEDURE delete_message_reactions(IN removed_messages_id INT UNSIGNED)
BEGIN
    DELETE FROM messengerdatabase.interactions WHERE message_id = removed_messages_id;
END //
delimiter ;

DELIMITER //
CREATE PROCEDURE add_new_user(IN pass VARCHAR(32),IN new_first_name VARCHAR(32), IN new_last_name VARCHAR(32), IN new_avatar MEDIUMBLOB)
BEGIN
    DECLARE new_username INT UNSIGNED DEFAULT 0;
    INSERT INTO messengerdatabase.users (first_name, last_name, avatar, status, is_deleted) VALUES (new_first_name, new_last_name, new_avatar, 'not active', 'no');
    SET new_username = LAST_INSERT_ID();
    SET @create_user_query = CONCAT('CREATE USER "', new_username, '"@"localhost" IDENTIFIED BY "', pass, '"');
        PREPARE create_user_stmt FROM @create_user_query;
        EXECUTE create_user_stmt;
        DEALLOCATE PREPARE create_user_stmt;
    SET @grant_privileges_query = CONCAT('GRANT EXECUTE ON `', 'messengerdatabase', '`.* TO "', new_username, '"@"localhost"');
        PREPARE grant_privileges_stmt FROM @grant_privileges_query;
        EXECUTE grant_privileges_stmt;
        DEALLOCATE PREPARE grant_privileges_stmt;
    FLUSH PRIVILEGES;
end //
