CREATE ROLE backbase;
GRANT create session TO backbase;
GRANT create table TO backbase;
GRANT create view TO backbase;
GRANT create sequence TO backbase;
GRANT create trigger TO backbase;
GRANT create procedure TO backbase;

CREATE USER portal_e PROFILE DEFAULT IDENTIFIED BY b4ckb4s3 DEFAULT TABLESPACE users TEMPORARY TABLESPACE temp ACCOUNT UNLOCK;
GRANT backbase to portal_e;
ALTER USER portal_e quota unlimited on users;

CREATE USER cs_e PROFILE DEFAULT IDENTIFIED BY b4ckb4s3 DEFAULT TABLESPACE users TEMPORARY TABLESPACE temp ACCOUNT UNLOCK;
GRANT backbase to cs_e;
ALTER USER cs_e quota unlimited on users;

CREATE USER auditing_e PROFILE DEFAULT IDENTIFIED BY b4ckb4s3 DEFAULT TABLESPACE users TEMPORARY TABLESPACE temp ACCOUNT UNLOCK;
GRANT backbase to auditing_e;
ALTER USER auditing_e quota unlimited on users;

CREATE USER provisioning_e PROFILE DEFAULT IDENTIFIED BY b4ckb4s3 DEFAULT TABLESPACE users TEMPORARY TABLESPACE temp ACCOUNT UNLOCK;
GRANT backbase to provisioning_e;
ALTER USER provisioning_e quota unlimited on users;

CREATE USER publishing_e PROFILE DEFAULT IDENTIFIED BY b4ckb4s3 DEFAULT TABLESPACE users TEMPORARY TABLESPACE temp ACCOUNT UNLOCK;
GRANT backbase to publishing_e;
ALTER USER publishing_e quota unlimited on users;

CREATE USER rendition_e PROFILE DEFAULT IDENTIFIED BY b4ckb4s3 DEFAULT TABLESPACE users TEMPORARY TABLESPACE temp ACCOUNT UNLOCK;
GRANT backbase to rendition_e;
ALTER USER rendition_e quota unlimited on users;

CREATE USER tar_e PROFILE DEFAULT IDENTIFIED BY b4ckb4s3 DEFAULT TABLESPACE users TEMPORARY TABLESPACE temp ACCOUNT UNLOCK;
GRANT backbase to tar_e;
ALTER USER tar_e quota unlimited on users;
