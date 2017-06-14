create database ircrecon_db; 
use ircrecon_db; 
create table event (nick char(10),target char(255),line char(255)); 
ALTER TABLE event ADD insertime timestamp NOT NULL; 
grant usage on *.* to ircrecon@localhost identified by 'n0t_seriou5'; 
grant all privileges on ircrecon_db.* to ircrecon@localhost; 
flush privileges; 
##view latest 
select * from ircrecon_db.event order by insertime desc limit 24; 
