select * from all_users;
--创建用户密码
create user hrois_fs_drum identified by hrois_fs_drum;
--创建登录权限
grant create session to hrois_fs_drum;
--将视图赋予用户
grant select on hrois.VIEW_PICKING_FS_DRUM to hrois_fs_drum;
--将试图起别名，不需要前缀
CREATE SYNONYM hrois_fs_drum.VIEW_PICKING_FS_DRUM for hrois.VIEW_PICKING_FS_DRUM;

--select * from VIEW_PICKING_FS_DRUM;
