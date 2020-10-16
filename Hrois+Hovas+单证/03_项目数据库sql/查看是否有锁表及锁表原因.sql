--查看是否存在锁表
select a.object_name,
       b.session_id,
       c.serial#,
       c.program,
       c.username,
       c.command,
       c.machine,
       c.lockwait
  from all_objects a, v$locked_object b, v$session c
 where a.object_id = b.object_id
   and c.sid = b.session_id;
   
--查询锁表原因
select l.session_id sid,
       s.serial#,
       l.locked_mode,
       l.oracle_username,
       s.user#,
       l.os_user_name,
       s.machine,
       s.terminal,
       a.sql_text,
       a.action
  from v$sqlarea a, v$session s, v$locked_object l
 where l.session_id = s.sid
   and s.prev_sql_addr = a.address
 order by sid, s.serial#;

--解锁方法 146为锁住的进程号，即spid
alter system kill session '146';
