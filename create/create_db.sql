--  sqlplus sys as sysdba

create user USERNAME identified by PASSWORD;

grant connect, resource to USERNAME;

-- sqlplus