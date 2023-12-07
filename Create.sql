CREATE DATABASE messengerDatabase CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;

CREATE TABLE messages(id INT unsigned NOT NULL PRIMARY KEY auto_increment,
						conversation_id INT unsigned NOT NULL,
						user_id INT unsigned NOT NULL,
                        content VARCHAR(1024),
                        time_of_writing datetime,
                        answer_to_id INT unsigned);
CREATE TABLE users(id INT unsigned not null primary key auto_increment,
					first_name varchar(32) NOT NULL,
                    last_name varchar(32) NOT NULL,
                    avatar mediumblob,
                    status enum('active', 'not active'));
CREATE TABLE removed_users(id INT unsigned not null auto_increment primary key,
                            first_name varchar(32) NOT NULL,
                            last_name varchar(32) NOT NULL);
CREATE TABLE conversations(id int unsigned not null primary key auto_increment,
							name varchar(32) NOT NULL,
                            creation_date datetime,
                            invitation bool,
                            avatar mediumblob,
                            admin_id int unsigned NOT NULL);
CREATE TABLE conversation_members(user_id int unsigned not null,
									conversation_id int unsigned not null);
CREATE TABLE moderators(user_id int unsigned not null,
						conversation_id int unsigned not null);
CREATE TABLE interactions(id int unsigned not null primary key auto_increment,
							user_id int unsigned not null,
                            type_of_interaction character,
                            message_id int unsigned NOT NULL);

###TODO implement date format change into database (date -> datetime)


ALTER TABLE messages ADD constraint FK_conversation_id foreign key (conversation_id)
										references conversations(id);
ALTER TABLE messages ADD constraint FK_user_id foreign key (user_id)
										references users(id);
ALTER TABLE messages ADD constraint FK_removed_user_id foreign key (user_id)
										references removed_users(id);
ALTER TABLE messages ADD constraint FK_answer_to_id foreign key (answer_to_id)
										references messages(id);

ALTER TABLE conversation_members ADD constraint FK_cm_user_id foreign key (user_id)
										references users(id);
ALTER TABLE conversation_members ADD constraint FK_cm_conversation_id foreign key (conversation_id)
										references conversations(id);

ALTER TABLE interactions ADD constraint FK_i_user_id foreign key (user_id)
								references users(id);
ALTER TABLE interactions ADD constraint FK_i_removed_user_id foreign key (user_id)
								references removed_users(id);
ALTER TABLE interactions ADD constraint FK_i_message_id foreign key (message_id)
								references messages(id);

ALTER TABLE moderators ADD constraint FK_m_user_id foreign key (user_id)
                                references users(id);
ALTER TABLE moderators ADD constraint FK_m_conversation_id foreign key (conversation_id)
                                references conversations(id);




