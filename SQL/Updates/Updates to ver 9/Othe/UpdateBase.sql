SET SQL DIALECT 3;

CREATE TABLE DCL_SCRIPTS (
    NUMSEQ   INTEGER NOT NULL,
    DCLNAME  CHAR(50),
    DCLTEXT  BLOB SUB_TYPE 1 SEGMENT SIZE 80,
    COMMAND  CHAR(80),
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


INSERT INTO DCL_SCRIPTS (NUMSEQ, DCLNAME, DCLTEXT, COMMAND, IDENT, PARENT)
SELECT NUMSEQ, DCLNAME, DCLTEXT, COMMAND, IDENT, PARENT FROM SCRIPTS S;

/*-------------------------------------------------------------------------*/
/* Creating new views */
/*-------------------------------------------------------------------------*/

COMMIT;

CREATE TABLE DCL_USERS(UID INTEGER NOT NULL, DCL_USER_NAME VARCHAR(20), DCL_LONG_USER_NAME VARCHAR(30), DCL_USER_PASS VARCHAR(25), DCL_ROLE INTEGER, SHOWINLIST SMALLINT, ACCESSLEVEL SMALLINT);

ALTER TABLE DCL_USERS ADD CONSTRAINT PK_DCL_USERS PRIMARY KEY(UID);

---------------------------------------------------

CREATE TABLE DCL_ROLES(ROLESID INTEGER NOT NULL, ROLENAME VARCHAR(20), LONGROLENAME VARCHAR(30), SHOWINLIST SMALLINT, ROLE_ACCESSLEVEL SMALLINT);

ALTER TABLE DCL_ROLES ADD CONSTRAINT PK_DCL_ROLES PRIMARY KEY(ROLESID);

ALTER TABLE ROLESMENU DROP CONSTRAINT FK_ROLESMENU_2;
ALTER TABLE NOTIFYCATIONS DROP CONSTRAINT FK_NOTIFYCATIONS_1;

INSERT INTO DCL_ROLES (ROLESID, ROLENAME, LONGROLENAME, SHOWINLIST, ROLE_ACCESSLEVEL)
SELECT R.ROLEID, R.ROLENAME, R.LONGROLENAME, R.SHOWINLIST, COALESCE(R.USERADMIN, 0) FROM ROLES R;

INSERT INTO DCL_USERS (UID, DCL_USER_NAME, DCL_LONG_USER_NAME, DCL_USER_PASS, DCL_ROLE, SHOWINLIST, ACCESSLEVEL)
SELECT R.ROLEID, R.ROLENAME, R.LONGROLENAME, R.ROLEPASS, R.ROLEID, R.SHOWINLIST, COALESCE(R.USERADMIN, 3) FROM ROLES R;

COMMIT WORK;

CREATE TABLE DCL_GLOBAL_PARAMS(PARAM_ID INTEGER NOT NULL, PARAM_CAPT VARCHAR(70), PARAM_NAME VARCHAR(70) NOT NULL, PARAM_VALUE VARCHAR(255), PARAM_USERID INTEGER, PROGRAMM_PARAM SMALLINT);

ALTER TABLE DCL_GLOBAL_PARAMS ADD CONSTRAINT UNQ1_DCL_GLOBAL_PARAMS UNIQUE(PARAM_NAME);


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


DROP VIEW ROLESTOMENU;

CREATE VIEW ROLESTOMENU(ROLEID, ROLENAME, LONGROLENAME, MENUITEMID, DCLNAME) AS SELECT R.ROLESID ROLEID, R.ROLENAME,
                                                                                       R.LONGROLENAME, RM.MENUITEMID,
                                                                                       D.DCLNAME FROM DCL_ROLESMENU RM, DCL_ROLES R, DCL_SCRIPTS D
WHERE R.ROLESID = RM.ROLEID AND
RM.MENUITEMID = D.NUMSEQ;


CREATE TABLE DCL_ACTIVE_USERS(AU_ID INTEGER NOT NULL, ACTIVE_USER_ID INTEGER, ACTIVE_USER_HOST VARCHAR(50), ACTIVE_USER_IP VARCHAR(15), ACTIVE_USER_DCL_VER VARCHAR(12), ACTIVE_USER_LOGIN_TIME TIMESTAMP);

ALTER TABLE DCL_ACTIVE_USERS ADD CONSTRAINT PK_DCL_ACTIVE_USERS PRIMARY KEY(AU_ID);

/******************************************************************************/
/***                                Triggers                                ***/
/******************************************************************************/

CREATE TABLE DCL_USER_LOGIN_HISTORY(UL_ID INTEGER NOT NULL, UL_USER_ID INTEGER, UL_LOGIN_TIME TIMESTAMP, UL_LOGOFF_TIME TIMESTAMP, UL_HOST_NAME VARCHAR(50), UL_HOST_IP VARCHAR(15), UL_DCL_VER VARCHAR(12));

ALTER TABLE DCL_USER_LOGIN_HISTORY ADD CONSTRAINT PK_DCL_USER_LOGIN_HISTORY PRIMARY KEY(UL_ID);

/******************************************************************************/
/***                                Triggers                                ***/
/******************************************************************************/

CREATE TABLE DCL_INI_PROFILES(INI_ID INTEGER NOT NULL, INI_USER_ID INTEGER, INI_DIALOG_NAME VARCHAR(50), INI_PARAM_VALUE VARCHAR(1100));

/******************************************************************************/
/***                              Primary Keys                              ***/
/******************************************************************************/

ALTER TABLE DCL_INI_PROFILES ADD CONSTRAINT PK_INI_PROFILES PRIMARY KEY(INI_ID);


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


CREATE TABLE DCL_TEMPLATES (
    TEID        INTEGER NOT NULL,
    TEMPL_NAME  VARCHAR(25) NOT NULL,
    TEMPL_DATA  BLOB
);



insert into DCL_TEMPLATES (TEMPL_NAME, TEMPL_DATA)
select TEMPL_NAME, TEMPL_DATA from TEMPL;



COMMIT WORK;
