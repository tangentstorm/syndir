PRAGMA foreign_keys=OFF;
BEGIN TRANSACTION;
CREATE TABLE ops ( id integer primary key, op string unique, doc string, args string );
INSERT INTO ops VALUES(1,'ins','list insert','nid ix new');
INSERT INTO ops VALUES(2,'del','list delete','nid ix old');
INSERT INTO ops VALUES(3,'put','list append','nid new');
INSERT INTO ops VALUES(4,'pop','list drop last','nid old');
INSERT INTO ops VALUES(5,'atk','set at key','nid key new old');
INSERT INTO ops VALUES(6,'ati','set at idx','nid idx new old');
INSERT INTO ops VALUES(7,'txt','narrative text','str');
INSERT INTO ops VALUES(8,'rem','remark (comment)','str');
INSERT INTO ops VALUES(9,'new','new node','nid typ');
INSERT INTO ops VALUES(10,'key','new key','nid key');
CREATE TABLE commits ( id integer primary key, hash text, note string );
CREATE TABLE tokens ( id integer primary key, text text unique );
CREATE TABLE items ( id integer primary key, tok integer, foreign key(tok) references tokens(id) );
CREATE TABLE changes ( id integer primary key, "commit" integer, seq integer not null, op text, args string, foreign key(op) references ops(op), foreign key ("commit") references commits(id), unique("commit",seq) );
CREATE TABLE branches ( id integer primary key, name text, head integer, foreign key(head) references commits(id));
CREATE TABLE tags ( id integer primary key, name text, "commit" integer, foreign key("commit") references commits(id));
COMMIT;
