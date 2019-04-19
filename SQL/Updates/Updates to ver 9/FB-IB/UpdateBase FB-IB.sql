SET SQL DIALECT 3;

CREATE TABLE DCL_SCRIPTS (
    NUMSEQ   INTEGER NOT NULL,
    DCLNAME  VARCHAR(50),
    DCLTEXT  BLOB SUB_TYPE 1 SEGMENT SIZE 80,
    COMMAND  VARCHAR(80),
    IDENT    INTEGER,
    PARENT   INTEGER,
    UPDATES  TIMESTAMP,
    ACTINON  CHAR(1)
);

/******************************************************************************/
/***                           Unique Constraints                           ***/
/******************************************************************************/

ALTER TABLE DCL_SCRIPTS ADD CONSTRAINT UNQ1_DCL_SCRIPTS UNIQUE (IDENT);

/******************************************************************************/
/***                              Primary Keys                              ***/
/******************************************************************************/

ALTER TABLE DCL_SCRIPTS ADD CONSTRAINT PK_DCL_SCRIPTS PRIMARY KEY (NUMSEQ);

/******************************************************************************/
/***                                Indices                                 ***/
/******************************************************************************/

CREATE INDEX DCL_SCRIPTS_IDX2 ON DCL_SCRIPTS (DCLNAME);
CREATE UNIQUE INDEX DCL_SCRIPTS_IDX3 ON DCL_SCRIPTS (IDENT, PARENT);

/******************************************************************************/
/***                                Triggers                                ***/
/******************************************************************************/

SET TERM ^;

/* Trigger: SCRIPTS_BI */
CREATE OR ALTER TRIGGER DCL_SCRIPTS_BI FOR DCL_SCRIPTS
ACTIVE BEFORE INSERT OR UPDATE POSITION 0
AS
BEGIN
  IF (NEW.NUMSEQ IS NULL) THEN
    NEW.NUMSEQ = GEN_ID(MAIN_GENERATOR_ID, 1);

  NEW.UPDATES = 'now';
  IF (INSERTING) THEN
    NEW.ACTINON = 'I';
  IF (UPDATING) THEN
    NEW.ACTINON = 'U';
END^

SET TERM;
^

/******************************************************************************/
/***                              Descriptions                              ***/
/******************************************************************************/

COMMENT ON TABLE DCL_SCRIPTS IS 'Скрипты';

INSERT INTO DCL_SCRIPTS (NUMSEQ, DCLNAME, DCLTEXT, COMMAND, IDENT, PARENT)
SELECT NUMSEQ, DCLNAME, DCLTEXT, COMMAND, IDENT, PARENT FROM SCRIPTS S;

/*-------------------------------------------------------------------------*/
/* Creating new views */
/*-------------------------------------------------------------------------*/

COMMIT;

CREATE TABLE DCL_USERS(UID INTEGER NOT NULL, DCL_USER_NAME VARCHAR(20), DCL_LONG_USER_NAME VARCHAR(30), DCL_USER_PASS VARCHAR(25), DCL_ROLE INTEGER, SHOWINLIST SMALLINT, ACCESSLEVEL SMALLINT);

ALTER TABLE DCL_USERS ADD CONSTRAINT PK_DCL_USERS PRIMARY KEY(UID);

SET TERM ^;

CREATE TRIGGER DCL_USERS_BI FOR DCL_USERS ACTIVE BEFORE INSERT POSITION 0 AS BEGIN IF (NEW.UID IS NULL) THEN NEW.UID = GEN_ID(MAIN_GENERATOR_ID, 1);
END
^

SET TERM;
^

---------------------------------------------------

CREATE TABLE DCL_ROLES(ROLESID INTEGER NOT NULL, ROLENAME VARCHAR(20), LONGROLENAME VARCHAR(30), SHOWINLIST SMALLINT, ROLE_ACCESSLEVEL SMALLINT);

ALTER TABLE DCL_ROLES ADD CONSTRAINT PK_DCL_ROLES PRIMARY KEY(ROLESID);

SET TERM ^;

/* Trigger: DCL_ROLES_BI */
CREATE OR ALTER TRIGGER DCL_ROLES_BI FOR DCL_ROLES ACTIVE BEFORE INSERT POSITION 0 AS BEGIN IF (NEW.ROLESID IS NULL) THEN NEW.ROLESID = GEN_ID(MAIN_GENERATOR_ID, 1);
END
^

SET TERM;
^

ALTER TABLE ROLESMENU DROP CONSTRAINT FK_ROLESMENU_2;
ALTER TABLE NOTIFYCATIONS DROP CONSTRAINT FK_NOTIFYCATIONS_1;

INSERT INTO DCL_ROLES (ROLESID, ROLENAME, LONGROLENAME, SHOWINLIST, ROLE_ACCESSLEVEL)
SELECT R.ROLEID, R.ROLENAME, R.LONGROLENAME, R.SHOWINLIST, COALESCE(R.USERADMIN, 0) FROM ROLES R;

INSERT INTO DCL_USERS (UID, DCL_USER_NAME, DCL_LONG_USER_NAME, DCL_USER_PASS, DCL_ROLE, SHOWINLIST, ACCESSLEVEL)
SELECT R.ROLEID, R.ROLENAME, R.LONGROLENAME, R.ROLEPASS, R.ROLEID, R.SHOWINLIST, COALESCE(R.USERADMIN, 3) FROM ROLES R;

COMMIT WORK;

CREATE TABLE DCL_GLOBAL_PARAMS(PARAM_ID INTEGER NOT NULL, PARAM_CAPT VARCHAR(70), PARAM_NAME VARCHAR(70) NOT NULL, PARAM_VALUE VARCHAR(255), PARAM_USERID INTEGER, PROGRAMM_PARAM SMALLINT);

ALTER TABLE DCL_GLOBAL_PARAMS ADD CONSTRAINT PK_DCL_GLOBAL_PARAMS PRIMARY KEY (PARAM_ID);
ALTER TABLE DCL_GLOBAL_PARAMS ADD CONSTRAINT UNQ1_DCL_GLOBAL_PARAMS UNIQUE(PARAM_NAME);

SET TERM ^;

/******************************************************************************/
/***                          Triggers for tables                           ***/
/******************************************************************************/

/* Trigger: GLOBAL_PARAMS_BI */
CREATE OR ALTER TRIGGER DCL_GLOBAL_PARAMS_BI FOR DCL_GLOBAL_PARAMS ACTIVE BEFORE INSERT POSITION 0 AS BEGIN IF (NEW.PARAM_ID IS NULL) THEN NEW.PARAM_ID = GEN_ID(MAIN_GENERATOR_ID, 1);
END
^

SET TERM;
^

/******************************************************************************/
/***                              Descriptions                              ***/
/******************************************************************************/

COMMENT ON TABLE DCL_GLOBAL_PARAMS IS 'Параметры запуска системы';

INSERT INTO DCL_GLOBAL_PARAMS (PARAM_NAME, PARAM_VALUE, PROGRAMM_PARAM)
SELECT G.PARAM_NAME, G.PARAM_VALUE, 1 FROM GLOBAL_PARAMS G;

COMMIT WORK;

----------------------------------------------------------------------------------

CREATE TABLE DCL_ROLESMENU(ROLEID INTEGER NOT NULL, MENUITEMID INTEGER, RM_ID INTEGER NOT NULL);

/******************************************************************************/
/***                              Primary Keys                              ***/
/******************************************************************************/

ALTER TABLE DCL_ROLESMENU ADD CONSTRAINT PK_DCL_ROLESMENU PRIMARY KEY(RM_ID);

/******************************************************************************/
/***                                Indices                                 ***/
/******************************************************************************/

CREATE INDEX DCL_ROLESMENU_IDX1 ON DCL_ROLESMENU(ROLEID, MENUITEMID);

/******************************************************************************/
/***                                Triggers                                ***/
/******************************************************************************/

SET TERM ^;

/******************************************************************************/
/***                          Triggers for tables                           ***/
/******************************************************************************/

/* Trigger: ROLESMENU_BI */
CREATE OR ALTER TRIGGER DCL_ROLESMENU_BI FOR DCL_ROLESMENU ACTIVE BEFORE INSERT POSITION 0 AS BEGIN IF (NEW.RM_ID IS NULL) THEN NEW.RM_ID = GEN_ID(MAIN_GENERATOR_ID, 1);
END
^

SET TERM;
^

/******************************************************************************/
/***                              Descriptions                              ***/
/******************************************************************************/

COMMENT ON TABLE DCL_ROLESMENU IS 'Меню ролей';

SET TERM ^;

CREATE OR ALTER PROCEDURE ROLESMENU_IS_CORRECT RETURNS(NUMSEQ INTEGER, DCLNAME CHAR(50), IDENT INTEGER, ROLE_ID INTEGER, ROLE_NAME VARCHAR(50))
AS
DECLARE VARIABLE HEAD_EXISTS INTEGER;
DECLARE VARIABLE PARENT INTEGER;
BEGIN
FOR SELECT R.ROLESID, R.LONGROLENAME FROM DCL_ROLES R
ORDER BY R.LONGROLENAME
INTO :ROLE_ID, :ROLE_NAME
DO
FOR SELECT D.NUMSEQ, D.IDENT, D.PARENT FROM DCL_ROLESMENU RM, DCL_ROLES R, DCL_SCRIPTS D
WHERE R.ROLESID = RM.ROLEID AND
      RM.MENUITEMID = D.NUMSEQ AND
      R.ROLESID = :ROLE_ID
INTO :NUMSEQ, :IDENT, :PARENT
DO
BEGIN
SELECT COUNT(*) FROM DCL_ROLESMENU RM, DCL_ROLES R, DCL_SCRIPTS D
WHERE R.ROLESID = RM.ROLEID AND
    RM.MENUITEMID = D.NUMSEQ AND
    D.IDENT = :PARENT AND
    R.ROLESID = :ROLE_ID
INTO :HEAD_EXISTS;
IF (:HEAD_EXISTS = 0) THEN
BEGIN
FOR SELECT S.NUMSEQ, S.DCLNAME, S.IDENT FROM DCL_SCRIPTS S
    WHERE S.IDENT = :PARENT
    INTO :NUMSEQ, :DCLNAME, :IDENT
DO
  SUSPEND;
END
END
END
^

SET TERM;
^

/******************************************************************************/
/***                          Fields descriptions                           ***/
/******************************************************************************/

COMMENT ON COLUMN DCL_ROLESMENU.ROLEID IS 'ID роли';

COMMENT ON COLUMN DCL_ROLESMENU.MENUITEMID IS 'ID элемента меню к роли';

INSERT INTO DCL_ROLESMENU (ROLEID, MENUITEMID)
SELECT R.ROLEID, R.MENUITEMID FROM ROLESMENU R;

COMMIT WORK;
----------------------------------------------------------------------------

CREATE TABLE DCL_NOTIFYCATIONS(NOTIFY_ID INTEGER NOT NULL, NOTIFY_TIME TIMESTAMP, NOTIFY_ACTION INTEGER, NOTIFY_STATE INTEGER DEFAULT 0, USER_ID INTEGER, NOTIFY_TEXT VARCHAR(255), ADD_DATE TIMESTAMP);

/******************************************************************************/
/***                              Primary Keys                              ***/
/******************************************************************************/

ALTER TABLE DCL_NOTIFYCATIONS ADD CONSTRAINT PK_DCL_NOTIFYCATIONS PRIMARY KEY(NOTIFY_ID);

/******************************************************************************/
/***                                Triggers                                ***/
/******************************************************************************/

SET TERM ^;

/******************************************************************************/
/***                          Triggers for tables                           ***/
/******************************************************************************/

/* Trigger: NOTIFYCATIONS_BI0 */
CREATE OR ALTER TRIGGER DCL_NOTIFYCATIONS_BI0 FOR DCL_NOTIFYCATIONS ACTIVE BEFORE INSERT POSITION 0 AS BEGIN IF (NEW.NOTIFY_ID IS NULL) THEN NEW.NOTIFY_ID = GEN_ID(MAIN_GENERATOR_ID, 1);
IF (INSERTING) THEN
NEW.ADD_DATE = 'now';
END
^

SET TERM;
^

DROP VIEW ROLESTOMENU;

CREATE VIEW ROLESTOMENU(ROLEID, ROLENAME, LONGROLENAME, MENUITEMID, DCLNAME) AS SELECT R.ROLESID ROLEID, R.ROLENAME,
                                                                                       R.LONGROLENAME, RM.MENUITEMID,
                                                                                       D.DCLNAME FROM DCL_ROLESMENU RM, DCL_ROLES R, DCL_SCRIPTS D
WHERE R.ROLESID = RM.ROLEID AND
RM.MENUITEMID = D.NUMSEQ;

SET TERM ^;

CREATE OR ALTER PROCEDURE ADD_MENU_ITEM_TO_ROLE(ROLEID INTEGER, MENUITEMID INTEGER) RETURNS(ISAPPEND INTEGER)
AS
DECLARE VARIABLE TMP1 INTEGER;
BEGIN
SELECT COUNT(R.ROLEID) FROM DCL_ROLESMENU R
WHERE R.ROLEID = :ROLEID AND
R.MENUITEMID = :MENUITEMID
INTO TMP1;
IF (:TMP1 = 0) THEN
BEGIN
INSERT INTO DCL_ROLESMENU (ROLEID, MENUITEMID)
VALUES (:ROLEID, :MENUITEMID);
ISAPPEND = 1;
SUSPEND;
END
ELSE
BEGIN
ISAPPEND = 0;
SUSPEND;
END
END
^

SET TERM;
^

SET TERM ^;

CREATE OR ALTER PROCEDURE COPY_ROLE(ROLEIDFROM INTEGER, ROLEIDTO INTEGER)
AS
BEGIN
INSERT INTO DCL_ROLESMENU (ROLEID, MENUITEMID)
SELECT :ROLEIDTO, MENUITEMID FROM DCL_ROLESMENU R
WHERE R.ROLEID = :ROLEIDFROM;
END
^

SET TERM;
^

SET TERM ^;

CREATE OR ALTER PROCEDURE DEL_ROLE_AND_MENU(ROLEID INTEGER)
AS
BEGIN
DELETE FROM DCL_ROLESMENU R
WHERE R.ROLEID = :ROLEID AND
R.ROLEID NOT IN (SELECT U1.DCL_ROLE FROM DCL_USERS U1);
DELETE FROM DCL_ROLES R
WHERE R.ROLESID = :ROLEID AND
R.ROLESID NOT IN (SELECT U1.DCL_ROLE FROM DCL_USERS U1);
END
^

SET TERM;
^

SET TERM ^;

CREATE OR ALTER PROCEDURE DEL_ROLE_MENU(ROLEID INTEGER)
AS
BEGIN
DELETE FROM DCL_ROLESMENU R
WHERE R.ROLEID = :ROLEID AND
R.ROLEID NOT IN (SELECT U1.DCL_ROLE FROM DCL_USERS U1);
END
^

SET TERM;
^

CREATE GENERATOR GEN_DCL_ACTIVE_USERS_ID;

CREATE TABLE DCL_ACTIVE_USERS(AU_ID INTEGER NOT NULL, ACTIVE_USER_ID INTEGER, ACTIVE_USER_HOST VARCHAR(50), ACTIVE_USER_IP VARCHAR(15), ACTIVE_USER_DCL_VER VARCHAR(12), ACTIVE_USER_LOGIN_TIME TIMESTAMP);

ALTER TABLE DCL_ACTIVE_USERS ADD CONSTRAINT PK_DCL_ACTIVE_USERS PRIMARY KEY(AU_ID);

/******************************************************************************/
/***                                Triggers                                ***/
/******************************************************************************/

SET TERM ^;

/******************************************************************************/
/***                          Triggers for tables                           ***/
/******************************************************************************/

/* Trigger: DCL_ACTIVE_USERS_BI */
CREATE OR ALTER TRIGGER DCL_ACTIVE_USERS_BI FOR DCL_ACTIVE_USERS ACTIVE BEFORE INSERT POSITION 0 AS BEGIN IF (NEW.AU_ID IS NULL) THEN NEW.AU_ID = GEN_ID(GEN_DCL_ACTIVE_USERS_ID, 1);
IF (INSERTING) THEN
IF (NEW.ACTIVE_USER_LOGIN_TIME IS NULL) THEN
NEW.ACTIVE_USER_LOGIN_TIME = 'now';
END
^

SET TERM;
^

CREATE GENERATOR GEN_DCL_USER_LOGIN_HISTORY_ID;

CREATE TABLE DCL_USER_LOGIN_HISTORY(UL_ID INTEGER NOT NULL, UL_USER_ID INTEGER, UL_LOGIN_TIME TIMESTAMP, UL_LOGOFF_TIME TIMESTAMP, UL_HOST_NAME VARCHAR(50), UL_HOST_IP VARCHAR(15), UL_DCL_VER VARCHAR(12));

ALTER TABLE DCL_USER_LOGIN_HISTORY ADD CONSTRAINT PK_DCL_USER_LOGIN_HISTORY PRIMARY KEY(UL_ID);

/******************************************************************************/
/***                                Triggers                                ***/
/******************************************************************************/

SET TERM ^;

/******************************************************************************/
/***                          Triggers for tables                           ***/
/******************************************************************************/

/* Trigger: DCL_USER_LOGIN_HISTORY_BI */
CREATE OR ALTER TRIGGER DCL_USER_LOGIN_HISTORY_BI FOR DCL_USER_LOGIN_HISTORY ACTIVE BEFORE INSERT POSITION 0 AS BEGIN IF (NEW.UL_ID IS NULL) THEN NEW.UL_ID = GEN_ID(GEN_DCL_USER_LOGIN_HISTORY_ID, 1);
END
^

SET TERM;
^

/******************************************************************************/
/***                                 Tables                                 ***/
/******************************************************************************/

CREATE GENERATOR GEN_INI_PROFILES_ID;

CREATE TABLE DCL_INI_PROFILES(INI_ID INTEGER NOT NULL, INI_USER_ID INTEGER, INI_DIALOG_NAME VARCHAR(50), INI_PARAM_VALUE VARCHAR(1100));

/******************************************************************************/
/***                              Primary Keys                              ***/
/******************************************************************************/

ALTER TABLE DCL_INI_PROFILES ADD CONSTRAINT PK_INI_PROFILES PRIMARY KEY(INI_ID);

/******************************************************************************/
/***                                Triggers                                ***/
/******************************************************************************/

SET TERM ^;

/* Trigger: INI_PROFILES_BI */
CREATE OR ALTER TRIGGER INI_PROFILES_BI FOR DCL_INI_PROFILES ACTIVE BEFORE INSERT POSITION 0 AS BEGIN IF (NEW.INI_ID IS NULL) THEN NEW.INI_ID = GEN_ID(GEN_INI_PROFILES_ID, 1);
END
^

SET TERM;
^

ALTER TABLE DCL_ACTIVE_USERS ADD CONSTRAINT FK_DCL_ACTIVE_USERS_1 FOREIGN KEY(ACTIVE_USER_ID) REFERENCES DCL_USERS(UID) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE DCL_INI_PROFILES ADD CONSTRAINT FK_DCL_INI_PROFILES_1 FOREIGN KEY(INI_USER_ID) REFERENCES DCL_USERS(UID) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE DCL_NOTIFYCATIONS ADD CONSTRAINT FK_DCL_NOTIFYCATIONS_1 FOREIGN KEY(USER_ID) REFERENCES DCL_USERS(UID);
ALTER TABLE DCL_ROLESMENU ADD CONSTRAINT FK_DCL_ROLESMENU_1 FOREIGN KEY(MENUITEMID) REFERENCES DCL_SCRIPTS(NUMSEQ) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE DCL_ROLESMENU ADD CONSTRAINT FK_DCL_ROLESMENU_2 FOREIGN KEY(ROLEID) REFERENCES DCL_ROLES(ROLESID) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE DCL_USERS ADD CONSTRAINT FK_DCL_USERS_1 FOREIGN KEY(DCL_ROLE) REFERENCES DCL_ROLES(ROLESID) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE DCL_USER_LOGIN_HISTORY ADD CONSTRAINT FK_DCL_USER_LOGIN_HISTORY_1 FOREIGN KEY(UL_USER_ID) REFERENCES DCL_USERS(UID) ON DELETE CASCADE ON UPDATE CASCADE;

CREATE TABLE DCL_ROLES_TO_USERS (
    RU_ID      INTEGER NOT NULL,
    RU_USERID  INTEGER,
    RU_ROLEID  INTEGER
);

ALTER TABLE DCL_ROLES_TO_USERS ADD CONSTRAINT PK_DCL_ROLES_TO_USERS PRIMARY KEY (RU_ID);


/******************************************************************************/
/***                              Foreign Keys                              ***/
/******************************************************************************/

ALTER TABLE DCL_ROLES_TO_USERS ADD CONSTRAINT FK_DCL_ROLES_TO_USERS_1 FOREIGN KEY (RU_USERID) REFERENCES DCL_USERS (UID) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE DCL_ROLES_TO_USERS ADD CONSTRAINT FK_DCL_ROLES_TO_USERS_2 FOREIGN KEY (RU_ROLEID) REFERENCES DCL_ROLES (ROLESID) ON DELETE CASCADE ON UPDATE CASCADE;

SET TERM ^ ;



/******************************************************************************/
/***                          Triggers for tables                           ***/
/******************************************************************************/



/* Trigger: DCL_ROLES_TO_USERS_BI */
CREATE OR ALTER TRIGGER DCL_ROLES_TO_USERS_BI FOR DCL_ROLES_TO_USERS
ACTIVE BEFORE INSERT POSITION 0
as
begin
  if (new.ru_id is null) then
    new.ru_id = gen_id(main_generator_id,1);
end
^


SET TERM ; ^

COMMENT ON TABLE DCL_ROLES_TO_USERS IS 
'Таблица множественной связи ролей с пользователем';


CREATE TABLE DCL_TEMPLATES (
    TEID        INTEGER NOT NULL,
    TEMPL_NAME  VARCHAR(25) NOT NULL,
    TEMPL_DATA  BLOB SUB_TYPE 0 SEGMENT SIZE 80
);


SET TERM ^ ;

CREATE OR ALTER TRIGGER DCL_TEMPLATES_BI FOR DCL_TEMPLATES
ACTIVE BEFORE INSERT POSITION 0
as
begin
  if (new.teid is null) then
    new.teid = gen_id(main_generator_id,1);
end
^

SET TERM ; ^


COMMENT ON TABLE DCL_TEMPLATES IS 
'Шаблоны отчётов';

COMMIT WORK;


insert into DCL_TEMPLATES (TEMPL_NAME, TEMPL_DATA)
select TEMPL_NAME, TEMPL_DATA from TEMPL;


COMMIT WORK;
