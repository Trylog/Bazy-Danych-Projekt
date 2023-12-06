CREATE USER 'username'@'host' IDENTIFIED BY 'password';
GRANT SELECT ON messengerdatabase.* TO 'username'@'host';
GRANT EXECUTE ON PROCEDURE messengerdatabase.new_conversation TO 'username'@'host';
GRANT EXECUTE ON PROCEDURE messengerdatabase.join_conversation TO 'username'@'host';
GRANT EXECUTE ON PROCEDURE messengerdatabase.send_message TO 'username'@'host';
GRANT EXECUTE ON PROCEDURE messengerdatabase.send_interaction TO 'username'@'host';
