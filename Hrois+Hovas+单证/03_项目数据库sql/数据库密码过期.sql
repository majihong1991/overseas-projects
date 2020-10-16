SELECT * FROM dba_users a where a.username = 'IDMUSER' ;

alter user IDMUSER account unlock; 

alter user IDMUSER identified by Horis123456;
