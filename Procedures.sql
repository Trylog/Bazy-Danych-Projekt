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

