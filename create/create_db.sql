--  sqlplus sys as sysdba

create user "username" identified by "password";

grant connect, resource to "username";

-- sqlplus