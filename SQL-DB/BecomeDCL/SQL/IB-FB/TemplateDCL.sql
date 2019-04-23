/******************************************************************************/
/*                 Generated by IBExpert 03.10.2014 17:37:30                  */
/******************************************************************************/

SET SQL DIALECT 3;

SET NAMES UTF8;


/******************************************************************************/
/*                                  Domains                                   */
/******************************************************************************/

CREATE DOMAIN DM_PASSWORD AS
VARCHAR(35);



/******************************************************************************/
/*                                 Generators                                 */
/******************************************************************************/

CREATE GENERATOR DCL_SCRIPTS_NEXT_ID;
CREATE GENERATOR GEN_DCL_ACTIVE_USERS_ID;
CREATE GENERATOR GEN_DCL_USER_LOGIN_HISTORY_ID;
CREATE GENERATOR GEN_INI_PROFILES_ID;
CREATE GENERATOR MAIN_GENERATOR_ID;


SET TERM ^ ; 



/******************************************************************************/
/*                             Stored Procedures                              */
/******************************************************************************/

CREATE OR ALTER PROCEDURE ADD_MENU_ITEM_TO_ROLE (
    ROLEID INTEGER,
    MENUITEMID INTEGER)
RETURNS (
    ISAPPEND INTEGER)
AS
BEGIN
  SUSPEND;
END^





CREATE OR ALTER PROCEDURE COPY_ROLE (
    ROLEIDFROM INTEGER,
    ROLEIDTO INTEGER)
AS
BEGIN
  EXIT;
END^





CREATE OR ALTER PROCEDURE DEL_ROLE_AND_MENU (
    ROLEID INTEGER)
AS
BEGIN
  EXIT;
END^





CREATE OR ALTER PROCEDURE DEL_ROLE_MENU (
    ROLEID INTEGER)
AS
BEGIN
  EXIT;
END^





CREATE OR ALTER PROCEDURE FIRST_DAY_OF_MONTH (
    ADATE DATE)
RETURNS (
    RESULT DATE)
AS
BEGIN
  SUSPEND;
END^





CREATE OR ALTER PROCEDURE IS_NUMBER (
    A_VALUE VARCHAR(32))
RETURNS (
    RESULT INTEGER)
AS
BEGIN
  SUSPEND;
END^





CREATE OR ALTER PROCEDURE ROLESMENU_IS_CORRECT
RETURNS (
    NUMSEQ INTEGER,
    DCLNAME VARCHAR(50),
    IDENT INTEGER,
    ROLE_ID INTEGER,
    ROLE_NAME VARCHAR(50))
AS
BEGIN
  SUSPEND;
END^






SET TERM ; ^



/******************************************************************************/
/*                                   Tables                                   */
/******************************************************************************/



CREATE TABLE DCL_ACTIVE_USERS (
    AU_ID                   INTEGER NOT NULL,
    ACTIVE_USER_ID          INTEGER,
    ACTIVE_USER_HOST        VARCHAR(50),
    ACTIVE_USER_IP          VARCHAR(15),
    ACTIVE_USER_DCL_VER     VARCHAR(12),
    ACTIVE_USER_LOGIN_TIME  TIMESTAMP
);

CREATE TABLE DCL_GLOBAL_PARAMS (
    PARAM_ID        INTEGER NOT NULL,
    PARAM_CAPT      VARCHAR(80),
    PARAM_NAME      VARCHAR(80) NOT NULL,
    PARAM_VALUE     VARCHAR(255),
    PARAM_USERID    INTEGER,
    PROGRAMM_PARAM  SMALLINT
);

CREATE TABLE DCL_INI_PROFILES (
    INI_ID           INTEGER NOT NULL,
    INI_USER_ID      INTEGER,
    INI_DIALOG_NAME  VARCHAR(50),
    INI_PARAM_VALUE  BLOB SUB_TYPE 1 SEGMENT SIZE 1024,
    INI_TYPE         INTEGER
);

CREATE TABLE DCL_NOTIFYCATIONS (
    NOTIFY_ID      INTEGER NOT NULL,
    NOTIFY_TIME    TIMESTAMP,
    NOTIFY_ACTION  INTEGER,
    NOTIFY_STATE   INTEGER DEFAULT 0,
    USER_ID        INTEGER,
    NOTIFY_TEXT    VARCHAR(255),
    ADD_DATE       TIMESTAMP
);

CREATE TABLE DCL_ROLES (
    ROLESID           INTEGER NOT NULL,
    ROLENAME          VARCHAR(20),
    LONGROLENAME      VARCHAR(30),
    SHOWINLIST        SMALLINT,
    ROLE_ACCESSLEVEL  SMALLINT
);

CREATE TABLE DCL_ROLES_TO_USERS (
    RU_ID      INTEGER NOT NULL,
    RU_USERID  INTEGER,
    RU_ROLEID  INTEGER
);

CREATE TABLE DCL_ROLESMENU (
    ROLEID      INTEGER NOT NULL,
    MENUITEMID  INTEGER,
    RM_ID       INTEGER NOT NULL
);

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

CREATE TABLE DCL_TEMPLATES (
    TEID        INTEGER NOT NULL,
    TEMPL_NAME  VARCHAR(25) NOT NULL,
    TEMPL_DATA  BLOB SUB_TYPE 0 SEGMENT SIZE 80
);

CREATE TABLE DCL_USER_LOGIN_HISTORY (
    UL_ID           INTEGER NOT NULL,
    UL_USER_ID      INTEGER,
    UL_LOGIN_TIME   TIMESTAMP,
    UL_LOGOFF_TIME  TIMESTAMP,
    UL_HOST_NAME    VARCHAR(50),
    UL_HOST_IP      VARCHAR(15),
    UL_DCL_VER      VARCHAR(12)
);

CREATE TABLE DCL_USERS (
    UID                 INTEGER NOT NULL,
    DCL_USER_NAME       VARCHAR(20),
    DCL_LONG_USER_NAME  VARCHAR(30),
    DCL_USER_PASS       VARCHAR(32),
    DCL_ROLE            INTEGER,
    SHOWINLIST          SMALLINT,
    ACCESSLEVEL         SMALLINT,
    DBUSER_NAME         VARCHAR(300),
    DBPASS              VARCHAR(25)
);

CREATE TABLE ORGANIZATIONS (
    OID       INTEGER NOT NULL,
    ORG_NAME  VARCHAR(101),
    ORD       SMALLINT,
    MAINORG   SMALLINT
);



/******************************************************************************/
/*                                   Views                                    */
/******************************************************************************/


/* View: ROLESTOMENU */
CREATE VIEW ROLESTOMENU(
    ROLEID,
    ROLENAME,
    LONGROLENAME,
    MENUITEMID,
    DCLNAME)
AS
select R.ROLESID ROLEID, R.ROLENAME, R.LONGROLENAME, RM.MENUITEMID, D.DCLNAME
from DCL_ROLESMENU RM, DCL_ROLES R, DCL_SCRIPTS D
where R.ROLESID = RM.ROLEID and
      RM.MENUITEMID = D.NUMSEQ
;



/* View: V_ATTACHMENTS */
CREATE VIEW V_ATTACHMENTS(
    MON$ATTACHMENT_ID,
    MON$SERVER_PID,
    MON$STATE,
    MON$ATTACHMENT_NAME,
    MON$USER,
    MON$ROLE,
    MON$REMOTE_PROTOCOL,
    MON$REMOTE_ADDRESS,
    MON$REMOTE_PID,
    MON$CHARACTER_SET_ID,
    MON$TIMESTAMP,
    MON$GARBAGE_COLLECTION,
    MON$REMOTE_PROCESS,
    MON$STAT_ID)
AS
select * from MON$ATTACHMENTS a
;


INSERT INTO DCL_ROLES (ROLESID, ROLENAME, LONGROLENAME, SHOWINLIST, ROLE_ACCESSLEVEL) VALUES (1, 'Admin', '�������������', NULL, 8);
INSERT INTO DCL_ROLES (ROLESID, ROLENAME, LONGROLENAME, SHOWINLIST, ROLE_ACCESSLEVEL) VALUES (2, 'Dir', '��������', 1, 5);
INSERT INTO DCL_ROLES (ROLESID, ROLENAME, LONGROLENAME, SHOWINLIST, ROLE_ACCESSLEVEL) VALUES (3, 'Oper', '��������', 1, 4);

COMMIT WORK;

INSERT INTO DCL_SCRIPTS (NUMSEQ, DCLNAME, DCLTEXT, COMMAND, IDENT, PARENT, UPDATES, ACTINON) VALUES (100107, '��������� �������� ������', NULL, 'BinStore', 1305, 10, '2014-10-03 17:03:22', 'U');

SET BLOBFILE 'TemplateDCL.lob';

INSERT INTO DCL_SCRIPTS (NUMSEQ, DCLNAME, DCLTEXT, COMMAND, IDENT, PARENT, UPDATES, ACTINON) VALUES (100002, 'Roles', :h0_103, NULL, NULL, NULL, '2014-10-03 17:12:34', 'U');
INSERT INTO DCL_SCRIPTS (NUMSEQ, DCLNAME, DCLTEXT, COMMAND, IDENT, PARENT, UPDATES, ACTINON) VALUES (100108, 'BinStore', :h103_249, NULL, NULL, NULL, '2014-10-03 17:13:01', 'U');
INSERT INTO DCL_SCRIPTS (NUMSEQ, DCLNAME, DCLTEXT, COMMAND, IDENT, PARENT, UPDATES, ACTINON) VALUES (100004, '����', NULL, 'Roles', 10003, 1289, '2013-07-30 14:43:44', 'U');
INSERT INTO DCL_SCRIPTS (NUMSEQ, DCLNAME, DCLTEXT, COMMAND, IDENT, PARENT, UPDATES, ACTINON) VALUES (100109, 'BinStore_Edit_Scr', :h34C_23, NULL, NULL, NULL, '2014-10-03 17:18:36', 'U');
INSERT INTO DCL_SCRIPTS (NUMSEQ, DCLNAME, DCLTEXT, COMMAND, IDENT, PARENT, UPDATES, ACTINON) VALUES (100110, 'BinStore_Add_Scr', :h36F_2C, NULL, NULL, NULL, '2014-10-03 17:00:32', 'I');
INSERT INTO DCL_SCRIPTS (NUMSEQ, DCLNAME, DCLTEXT, COMMAND, IDENT, PARENT, UPDATES, ACTINON) VALUES (100111, 'BinStore_Edit_Dlg', :h39B_9D, NULL, NULL, NULL, '2014-10-03 17:05:13', 'U');
INSERT INTO DCL_SCRIPTS (NUMSEQ, DCLNAME, DCLTEXT, COMMAND, IDENT, PARENT, UPDATES, ACTINON) VALUES (100006, 'Global_Params', :h438_1CD, NULL, NULL, NULL, '2014-10-03 17:22:30', 'U');
INSERT INTO DCL_SCRIPTS (NUMSEQ, DCLNAME, DCLTEXT, COMMAND, IDENT, PARENT, UPDATES, ACTINON) VALUES (100161, 'TemplateCompress', :h605_53, NULL, NULL, NULL, '2014-10-03 17:07:16', 'U');
INSERT INTO DCL_SCRIPTS (NUMSEQ, DCLNAME, DCLTEXT, COMMAND, IDENT, PARENT, UPDATES, ACTINON) VALUES (100162, 'TemplateDeCompress', :h658_55, NULL, NULL, NULL, '2014-10-03 17:07:47', 'U');
INSERT INTO DCL_SCRIPTS (NUMSEQ, DCLNAME, DCLTEXT, COMMAND, IDENT, PARENT, UPDATES, ACTINON) VALUES (100008, 'InitApp', :h6AD_51, NULL, 40001, NULL, '2013-07-30 14:43:44', 'U');
INSERT INTO DCL_SCRIPTS (NUMSEQ, DCLNAME, DCLTEXT, COMMAND, IDENT, PARENT, UPDATES, ACTINON) VALUES (100163, 'TemplateExport', :h6FE_93, NULL, NULL, NULL, '2014-10-03 17:08:22', 'U');
INSERT INTO DCL_SCRIPTS (NUMSEQ, DCLNAME, DCLTEXT, COMMAND, IDENT, PARENT, UPDATES, ACTINON) VALUES (100164, 'TemplateImport', :h791_89, NULL, NULL, NULL, '2014-10-03 17:08:48', 'U');
INSERT INTO DCL_SCRIPTS (NUMSEQ, DCLNAME, DCLTEXT, COMMAND, IDENT, PARENT, UPDATES, ACTINON) VALUES (100010, 'Orgs', :h81A_1DC, NULL, NULL, NULL, '2014-10-03 17:21:13', 'U');
INSERT INTO DCL_SCRIPTS (NUMSEQ, DCLNAME, DCLTEXT, COMMAND, IDENT, PARENT, UPDATES, ACTINON) VALUES (100012, 'Orgs_Set_Main_Scr', :h9F6_81, NULL, NULL, NULL, '2013-07-30 14:43:44', 'U');
INSERT INTO DCL_SCRIPTS (NUMSEQ, DCLNAME, DCLTEXT, COMMAND, IDENT, PARENT, UPDATES, ACTINON) VALUES (100014, '�������������', :hA77_5, NULL, 1350, 10, '2013-07-30 14:43:44', 'U');
INSERT INTO DCL_SCRIPTS (NUMSEQ, DCLNAME, DCLTEXT, COMMAND, IDENT, PARENT, UPDATES, ACTINON) VALUES (100016, '����', NULL, NULL, 1289, 10, '2013-07-30 14:43:44', 'U');
INSERT INTO DCL_SCRIPTS (NUMSEQ, DCLNAME, DCLTEXT, COMMAND, IDENT, PARENT, UPDATES, ACTINON) VALUES (100018, 'Users', :hA7C_353, NULL, NULL, NULL, '2014-10-03 17:19:46', 'U');
INSERT INTO DCL_SCRIPTS (NUMSEQ, DCLNAME, DCLTEXT, COMMAND, IDENT, PARENT, UPDATES, ACTINON) VALUES (100020, 'RolesMenu', :hDCF_369, NULL, NULL, NULL, '2014-10-03 17:12:28', 'U');
INSERT INTO DCL_SCRIPTS (NUMSEQ, DCLNAME, DCLTEXT, COMMAND, IDENT, PARENT, UPDATES, ACTINON) VALUES (100022, 'Roles_AddMenuItem', :h1138_1EC, NULL, NULL, NULL, '2014-10-03 17:19:08', 'U');
INSERT INTO DCL_SCRIPTS (NUMSEQ, DCLNAME, DCLTEXT, COMMAND, IDENT, PARENT, UPDATES, ACTINON) VALUES (100024, 'Roles_AddMenuItemExec', :h1324_10B, NULL, NULL, NULL, '2013-07-30 14:43:44', 'U');
INSERT INTO DCL_SCRIPTS (NUMSEQ, DCLNAME, DCLTEXT, COMMAND, IDENT, PARENT, UPDATES, ACTINON) VALUES (100026, 'Roles_AddRoleCallDialog', :h142F_21, NULL, NULL, NULL, '2013-07-30 14:43:44', 'U');
INSERT INTO DCL_SCRIPTS (NUMSEQ, DCLNAME, DCLTEXT, COMMAND, IDENT, PARENT, UPDATES, ACTINON) VALUES (100028, 'Roles_CopyRole', :h1450_1A0, NULL, NULL, NULL, '2014-10-03 17:22:47', 'U');
INSERT INTO DCL_SCRIPTS (NUMSEQ, DCLNAME, DCLTEXT, COMMAND, IDENT, PARENT, UPDATES, ACTINON) VALUES (100030, 'Roles_CopyRoleExec', :h15F0_6A, NULL, NULL, NULL, '2013-07-30 14:43:44', 'U');
INSERT INTO DCL_SCRIPTS (NUMSEQ, DCLNAME, DCLTEXT, COMMAND, IDENT, PARENT, UPDATES, ACTINON) VALUES (100032, 'Roles_CopyRole_Call', :h165A_1E, NULL, NULL, NULL, '2013-07-30 14:43:44', 'U');
INSERT INTO DCL_SCRIPTS (NUMSEQ, DCLNAME, DCLTEXT, COMMAND, IDENT, PARENT, UPDATES, ACTINON) VALUES (100034, 'Roles_DelRole', :h1678_CA, NULL, NULL, NULL, '2013-07-30 14:43:44', 'U');
INSERT INTO DCL_SCRIPTS (NUMSEQ, DCLNAME, DCLTEXT, COMMAND, IDENT, PARENT, UPDATES, ACTINON) VALUES (100036, 'Roles_DelRoleExec', :h1742_58, NULL, NULL, NULL, '2013-07-30 14:43:44', 'U');
INSERT INTO DCL_SCRIPTS (NUMSEQ, DCLNAME, DCLTEXT, COMMAND, IDENT, PARENT, UPDATES, ACTINON) VALUES (100038, 'Roles_DelRoleMenuItem', :h179A_E2, NULL, NULL, NULL, '2013-07-30 14:43:44', 'U');
INSERT INTO DCL_SCRIPTS (NUMSEQ, DCLNAME, DCLTEXT, COMMAND, IDENT, PARENT, UPDATES, ACTINON) VALUES (100040, 'Roles_DelRolesMenuItem', :h187C_126, NULL, NULL, NULL, '2014-10-03 17:19:24', 'U');
INSERT INTO DCL_SCRIPTS (NUMSEQ, DCLNAME, DCLTEXT, COMMAND, IDENT, PARENT, UPDATES, ACTINON) VALUES (100042, 'Roles_DelRolesMenuItem_Call', :h19A2_26, NULL, NULL, NULL, '2013-07-30 14:43:44', 'U');
INSERT INTO DCL_SCRIPTS (NUMSEQ, DCLNAME, DCLTEXT, COMMAND, IDENT, PARENT, UPDATES, ACTINON) VALUES (100044, 'Roles_Run_Test_RolesMenu', :h19C8_1C, NULL, NULL, NULL, '2013-07-30 14:43:44', 'U');
INSERT INTO DCL_SCRIPTS (NUMSEQ, DCLNAME, DCLTEXT, COMMAND, IDENT, PARENT, UPDATES, ACTINON) VALUES (100046, 'Roles_Test_RolesMenu', :h19E4_1A3, NULL, NULL, NULL, '2014-10-03 17:19:33', 'U');
INSERT INTO DCL_SCRIPTS (NUMSEQ, DCLNAME, DCLTEXT, COMMAND, IDENT, PARENT, UPDATES, ACTINON) VALUES (100048, '-', NULL, NULL, 1311, 10, '2013-07-30 14:43:44', 'U');
INSERT INTO DCL_SCRIPTS (NUMSEQ, DCLNAME, DCLTEXT, COMMAND, IDENT, PARENT, UPDATES, ACTINON) VALUES (100050, 'SQL Mon', :h1B87_7, NULL, 1501, 10, '2013-07-30 14:43:44', 'U');
INSERT INTO DCL_SCRIPTS (NUMSEQ, DCLNAME, DCLTEXT, COMMAND, IDENT, PARENT, UPDATES, ACTINON) VALUES (100052, 'Set_Org_Scr', :h1B8E_F9, NULL, NULL, NULL, '2013-07-30 14:43:44', 'U');
INSERT INTO DCL_SCRIPTS (NUMSEQ, DCLNAME, DCLTEXT, COMMAND, IDENT, PARENT, UPDATES, ACTINON) VALUES (100054, '������', :h1C87_8, NULL, 1901, 10, '2013-07-30 14:43:44', 'U');
INSERT INTO DCL_SCRIPTS (NUMSEQ, DCLNAME, DCLTEXT, COMMAND, IDENT, PARENT, UPDATES, ACTINON) VALUES (100056, '���� �����', NULL, 'RolesMenu', 10002, 1289, '2013-07-30 14:43:44', 'U');
INSERT INTO DCL_SCRIPTS (NUMSEQ, DCLNAME, DCLTEXT, COMMAND, IDENT, PARENT, UPDATES, ACTINON) VALUES (100058, '���������', NULL, NULL, 10, NULL, '2013-07-30 14:43:44', 'U');
INSERT INTO DCL_SCRIPTS (NUMSEQ, DCLNAME, DCLTEXT, COMMAND, IDENT, PARENT, UPDATES, ACTINON) VALUES (100060, '�����������', NULL, 'Orgs', 9002, 2, '2013-07-30 14:43:44', 'U');
INSERT INTO DCL_SCRIPTS (NUMSEQ, DCLNAME, DCLTEXT, COMMAND, IDENT, PARENT, UPDATES, ACTINON) VALUES (100062, '���������', NULL, 'Global_Params', 1401, 10, '2013-07-30 14:43:44', 'U');
INSERT INTO DCL_SCRIPTS (NUMSEQ, DCLNAME, DCLTEXT, COMMAND, IDENT, PARENT, UPDATES, ACTINON) VALUES (100064, '������������', NULL, 'Users', 10001, 1289, '2013-07-30 14:43:44', 'U');
INSERT INTO DCL_SCRIPTS (NUMSEQ, DCLNAME, DCLTEXT, COMMAND, IDENT, PARENT, UPDATES, ACTINON) VALUES (100066, '������ ���������� DCL5', NULL, NULL, 0, NULL, '2013-07-30 14:43:44', 'U');
INSERT INTO DCL_SCRIPTS (NUMSEQ, DCLNAME, DCLTEXT, COMMAND, IDENT, PARENT, UPDATES, ACTINON) VALUES (100068, '�����������', NULL, NULL, 2, NULL, '2013-07-30 14:43:44', 'U');
INSERT INTO DCL_SCRIPTS (NUMSEQ, DCLNAME, DCLTEXT, COMMAND, IDENT, PARENT, UPDATES, ACTINON) VALUES (100070, NULL, NULL, NULL, 20001, NULL, '2013-07-30 14:43:44', 'U');
INSERT INTO DCL_SCRIPTS (NUMSEQ, DCLNAME, DCLTEXT, COMMAND, IDENT, PARENT, UPDATES, ACTINON) VALUES (100072, ' v. 1.2', NULL, NULL, 20052, NULL, '2014-10-03 17:20:15', 'U');
INSERT INTO DCL_SCRIPTS (NUMSEQ, DCLNAME, DCLTEXT, COMMAND, IDENT, PARENT, UPDATES, ACTINON) VALUES (100074, '-', NULL, NULL, 1302, 10, '2013-07-30 14:43:44', 'U');
INSERT INTO DCL_SCRIPTS (NUMSEQ, DCLNAME, DCLTEXT, COMMAND, IDENT, PARENT, UPDATES, ACTINON) VALUES (100076, '-', NULL, NULL, 1500, 10, '2013-07-30 14:43:44', 'U');
INSERT INTO DCL_SCRIPTS (NUMSEQ, DCLNAME, DCLTEXT, COMMAND, IDENT, PARENT, UPDATES, ACTINON) VALUES (100078, '-', NULL, NULL, 1900, 10, '2013-07-30 14:43:44', 'U');
INSERT INTO DCL_SCRIPTS (NUMSEQ, DCLNAME, DCLTEXT, COMMAND, IDENT, PARENT, UPDATES, ACTINON) VALUES (100080, '-', NULL, NULL, 1292, 10, '2013-07-30 14:43:44', 'U');
INSERT INTO DCL_SCRIPTS (NUMSEQ, DCLNAME, DCLTEXT, COMMAND, IDENT, PARENT, UPDATES, ACTINON) VALUES (100082, '09.00.83.181', NULL, NULL, 50000, NULL, '2013-07-30 14:43:44', 'U');
INSERT INTO DCL_SCRIPTS (NUMSEQ, DCLNAME, DCLTEXT, COMMAND, IDENT, PARENT, UPDATES, ACTINON) VALUES (100084, 'User_Edit_Dlg', :h1C8F_288, NULL, NULL, NULL, '2014-10-03 17:17:19', 'U');
INSERT INTO DCL_SCRIPTS (NUMSEQ, DCLNAME, DCLTEXT, COMMAND, IDENT, PARENT, UPDATES, ACTINON) VALUES (100086, 'User_Edit_Scr', :h1F17_1D, NULL, NULL, NULL, '2013-07-30 14:43:44', 'U');
INSERT INTO DCL_SCRIPTS (NUMSEQ, DCLNAME, DCLTEXT, COMMAND, IDENT, PARENT, UPDATES, ACTINON) VALUES (100088, 'Notify_Add_Scr', :h1F34_BB, NULL, NULL, NULL, '2013-07-30 14:43:44', 'U');
INSERT INTO DCL_SCRIPTS (NUMSEQ, DCLNAME, DCLTEXT, COMMAND, IDENT, PARENT, UPDATES, ACTINON) VALUES (100090, 'Notify_Add', :h1FEF_1A4, NULL, NULL, NULL, '2013-07-30 14:43:44', 'U');
INSERT INTO DCL_SCRIPTS (NUMSEQ, DCLNAME, DCLTEXT, COMMAND, IDENT, PARENT, UPDATES, ACTINON) VALUES (100092, 'Roles_Notify_Add_Scr', :h2193_29, NULL, NULL, NULL, '2013-07-30 14:43:44', 'U');
INSERT INTO DCL_SCRIPTS (NUMSEQ, DCLNAME, DCLTEXT, COMMAND, IDENT, PARENT, UPDATES, ACTINON) VALUES (100094, 'Notifycations', :h21BC_242, NULL, NULL, NULL, '2014-10-03 17:21:09', 'U');
INSERT INTO DCL_SCRIPTS (NUMSEQ, DCLNAME, DCLTEXT, COMMAND, IDENT, PARENT, UPDATES, ACTINON) VALUES (100096, 'Global_Params_Edit_Dlg', :h23FE_EC, '', NULL, NULL, '2014-10-03 17:20:59', 'U');
INSERT INTO DCL_SCRIPTS (NUMSEQ, DCLNAME, DCLTEXT, COMMAND, IDENT, PARENT, UPDATES, ACTINON) VALUES (100098, 'Global_Params_Edit_Scr', :h24EA_26, NULL, NULL, NULL, '2013-07-30 14:43:44', 'U');
INSERT INTO DCL_SCRIPTS (NUMSEQ, DCLNAME, DCLTEXT, COMMAND, IDENT, PARENT, UPDATES, ACTINON) VALUES (100100, 'Attachments', :h2510_382, NULL, NULL, NULL, '2014-10-03 17:20:45', 'U');
INSERT INTO DCL_SCRIPTS (NUMSEQ, DCLNAME, DCLTEXT, COMMAND, IDENT, PARENT, UPDATES, ACTINON) VALUES (100102, '�����������', NULL, 'Attachments', 1300, 10, '2013-07-30 14:43:44', 'U');
INSERT INTO DCL_SCRIPTS (NUMSEQ, DCLNAME, DCLTEXT, COMMAND, IDENT, PARENT, UPDATES, ACTINON) VALUES (100104, 'Attachments_Terminate', :h2892_5B, NULL, NULL, NULL, '2013-07-30 14:43:44', 'U');
INSERT INTO DCL_SCRIPTS (NUMSEQ, DCLNAME, DCLTEXT, COMMAND, IDENT, PARENT, UPDATES, ACTINON) VALUES (100106, '�����', :h28ED_5, NULL, 999, NULL, '2013-07-30 14:43:44', 'U');

COMMIT WORK;

INSERT INTO DCL_ROLESMENU (ROLEID, MENUITEMID, RM_ID) VALUES (1, 100004, 100001);
INSERT INTO DCL_ROLESMENU (ROLEID, MENUITEMID, RM_ID) VALUES (1, 100107, 100160);
INSERT INTO DCL_ROLESMENU (ROLEID, MENUITEMID, RM_ID) VALUES (1, 100016, 100002);
INSERT INTO DCL_ROLESMENU (ROLEID, MENUITEMID, RM_ID) VALUES (1, 100014, 100003);
INSERT INTO DCL_ROLESMENU (ROLEID, MENUITEMID, RM_ID) VALUES (1, 100008, 100004);
INSERT INTO DCL_ROLESMENU (ROLEID, MENUITEMID, RM_ID) VALUES (1, 100050, 100005);
INSERT INTO DCL_ROLESMENU (ROLEID, MENUITEMID, RM_ID) VALUES (1, 100054, 100006);
INSERT INTO DCL_ROLESMENU (ROLEID, MENUITEMID, RM_ID) VALUES (1, 100056, 100007);
INSERT INTO DCL_ROLESMENU (ROLEID, MENUITEMID, RM_ID) VALUES (1, 100058, 100008);
INSERT INTO DCL_ROLESMENU (ROLEID, MENUITEMID, RM_ID) VALUES (1, 100060, 100009);
INSERT INTO DCL_ROLESMENU (ROLEID, MENUITEMID, RM_ID) VALUES (1, 100062, 100010);
INSERT INTO DCL_ROLESMENU (ROLEID, MENUITEMID, RM_ID) VALUES (1, 100064, 100011);
INSERT INTO DCL_ROLESMENU (ROLEID, MENUITEMID, RM_ID) VALUES (1, 100066, 100012);
INSERT INTO DCL_ROLESMENU (ROLEID, MENUITEMID, RM_ID) VALUES (1, 100068, 100013);
INSERT INTO DCL_ROLESMENU (ROLEID, MENUITEMID, RM_ID) VALUES (1, 100070, 100014);
INSERT INTO DCL_ROLESMENU (ROLEID, MENUITEMID, RM_ID) VALUES (1, 100072, 100015);
INSERT INTO DCL_ROLESMENU (ROLEID, MENUITEMID, RM_ID) VALUES (1, 100074, 100016);
INSERT INTO DCL_ROLESMENU (ROLEID, MENUITEMID, RM_ID) VALUES (1, 100076, 100017);
INSERT INTO DCL_ROLESMENU (ROLEID, MENUITEMID, RM_ID) VALUES (1, 100078, 100018);
INSERT INTO DCL_ROLESMENU (ROLEID, MENUITEMID, RM_ID) VALUES (1, 100080, 100019);
INSERT INTO DCL_ROLESMENU (ROLEID, MENUITEMID, RM_ID) VALUES (1, 100082, 100020);
INSERT INTO DCL_ROLESMENU (ROLEID, MENUITEMID, RM_ID) VALUES (2, 100008, 100021);
INSERT INTO DCL_ROLESMENU (ROLEID, MENUITEMID, RM_ID) VALUES (2, 100050, 100022);
INSERT INTO DCL_ROLESMENU (ROLEID, MENUITEMID, RM_ID) VALUES (2, 100054, 100023);
INSERT INTO DCL_ROLESMENU (ROLEID, MENUITEMID, RM_ID) VALUES (2, 100058, 100024);
INSERT INTO DCL_ROLESMENU (ROLEID, MENUITEMID, RM_ID) VALUES (2, 100060, 100025);
INSERT INTO DCL_ROLESMENU (ROLEID, MENUITEMID, RM_ID) VALUES (2, 100066, 100026);
INSERT INTO DCL_ROLESMENU (ROLEID, MENUITEMID, RM_ID) VALUES (2, 100068, 100027);
INSERT INTO DCL_ROLESMENU (ROLEID, MENUITEMID, RM_ID) VALUES (2, 100070, 100028);
INSERT INTO DCL_ROLESMENU (ROLEID, MENUITEMID, RM_ID) VALUES (2, 100072, 100029);
INSERT INTO DCL_ROLESMENU (ROLEID, MENUITEMID, RM_ID) VALUES (2, 100074, 100030);
INSERT INTO DCL_ROLESMENU (ROLEID, MENUITEMID, RM_ID) VALUES (2, 100076, 100031);
INSERT INTO DCL_ROLESMENU (ROLEID, MENUITEMID, RM_ID) VALUES (2, 100078, 100032);
INSERT INTO DCL_ROLESMENU (ROLEID, MENUITEMID, RM_ID) VALUES (2, 100080, 100033);
INSERT INTO DCL_ROLESMENU (ROLEID, MENUITEMID, RM_ID) VALUES (2, 100082, 100034);
INSERT INTO DCL_ROLESMENU (ROLEID, MENUITEMID, RM_ID) VALUES (1, 100102, 100035);
INSERT INTO DCL_ROLESMENU (ROLEID, MENUITEMID, RM_ID) VALUES (3, 100068, 100036);
INSERT INTO DCL_ROLESMENU (ROLEID, MENUITEMID, RM_ID) VALUES (3, 100072, 100037);
INSERT INTO DCL_ROLESMENU (ROLEID, MENUITEMID, RM_ID) VALUES (3, 100082, 100038);
INSERT INTO DCL_ROLESMENU (ROLEID, MENUITEMID, RM_ID) VALUES (3, 100008, 100039);
INSERT INTO DCL_ROLESMENU (ROLEID, MENUITEMID, RM_ID) VALUES (3, 100054, 100040);
INSERT INTO DCL_ROLESMENU (ROLEID, MENUITEMID, RM_ID) VALUES (3, 100058, 100041);
INSERT INTO DCL_ROLESMENU (ROLEID, MENUITEMID, RM_ID) VALUES (3, 100070, 100042);
INSERT INTO DCL_ROLESMENU (ROLEID, MENUITEMID, RM_ID) VALUES (3, 100074, 100043);
INSERT INTO DCL_ROLESMENU (ROLEID, MENUITEMID, RM_ID) VALUES (3, 100076, 100044);
INSERT INTO DCL_ROLESMENU (ROLEID, MENUITEMID, RM_ID) VALUES (3, 100066, 100045);

COMMIT WORK;

INSERT INTO DCL_USERS (UID, DCL_USER_NAME, DCL_LONG_USER_NAME, DCL_USER_PASS, DCL_ROLE, SHOWINLIST, ACCESSLEVEL) VALUES (13, 'Oper', '��������', '951', 3, 1, 1);
INSERT INTO DCL_USERS (UID, DCL_USER_NAME, DCL_LONG_USER_NAME, DCL_USER_PASS, DCL_ROLE, SHOWINLIST, ACCESSLEVEL) VALUES (11, 'Admin', '�������������', '789', 1, NULL, 8);
INSERT INTO DCL_USERS (UID, DCL_USER_NAME, DCL_LONG_USER_NAME, DCL_USER_PASS, DCL_ROLE, SHOWINLIST, ACCESSLEVEL) VALUES (12, 'Dir', '��������', '555', 2, 1, 5);

COMMIT WORK;

INSERT INTO ORGANIZATIONS (OID, ORG_NAME, ORD, MAINORG) VALUES (1, '���� �����������', NULL, 1);

COMMIT WORK;



/******************************************************************************/
/*                             Unique Constraints                             */
/******************************************************************************/

ALTER TABLE DCL_GLOBAL_PARAMS ADD CONSTRAINT UNQ1_DCL_GLOBAL_PARAMS UNIQUE (PARAM_USERID, PARAM_NAME);
ALTER TABLE DCL_SCRIPTS ADD CONSTRAINT UNQ1_DCL_SCRIPTS UNIQUE (IDENT);


/******************************************************************************/
/*                                Primary Keys                                */
/******************************************************************************/

ALTER TABLE DCL_ACTIVE_USERS ADD CONSTRAINT PK_DCL_ACTIVE_USERS PRIMARY KEY (AU_ID);
ALTER TABLE DCL_GLOBAL_PARAMS ADD CONSTRAINT PK_DCL_GLOBAL_PARAMS PRIMARY KEY (PARAM_ID);
ALTER TABLE DCL_INI_PROFILES ADD CONSTRAINT PK_INI_PROFILES PRIMARY KEY (INI_ID);
ALTER TABLE DCL_NOTIFYCATIONS ADD CONSTRAINT PK_DCL_NOTIFYCATIONS PRIMARY KEY (NOTIFY_ID);
ALTER TABLE DCL_ROLES ADD CONSTRAINT PK_DCL_ROLES PRIMARY KEY (ROLESID);
ALTER TABLE DCL_ROLESMENU ADD CONSTRAINT PK_DCL_ROLESMENU PRIMARY KEY (RM_ID);
ALTER TABLE DCL_ROLES_TO_USERS ADD CONSTRAINT PK_DCL_ROLES_TO_USERS PRIMARY KEY (RU_ID);
ALTER TABLE DCL_SCRIPTS ADD CONSTRAINT PK_DCL_SCRIPTS PRIMARY KEY (NUMSEQ);
ALTER TABLE DCL_TEMPLATES ADD CONSTRAINT PK_DCL_TEMPLATES PRIMARY KEY (TEID);
ALTER TABLE DCL_USERS ADD CONSTRAINT PK_DCL_USERS PRIMARY KEY (UID);
ALTER TABLE DCL_USER_LOGIN_HISTORY ADD CONSTRAINT PK_DCL_USER_LOGIN_HISTORY PRIMARY KEY (UL_ID);
ALTER TABLE ORGANIZATIONS ADD CONSTRAINT PK_ORGANIZATIONS PRIMARY KEY (OID);


/******************************************************************************/
/*                                Foreign Keys                                */
/******************************************************************************/

ALTER TABLE DCL_ACTIVE_USERS ADD CONSTRAINT FK_DCL_ACTIVE_USERS_1 FOREIGN KEY (ACTIVE_USER_ID) REFERENCES DCL_USERS (UID) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE DCL_INI_PROFILES ADD CONSTRAINT FK_DCL_INI_PROFILES_1 FOREIGN KEY (INI_USER_ID) REFERENCES DCL_USERS (UID) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE DCL_NOTIFYCATIONS ADD CONSTRAINT FK_DCL_NOTIFYCATIONS_1 FOREIGN KEY (USER_ID) REFERENCES DCL_USERS (UID);
ALTER TABLE DCL_ROLESMENU ADD CONSTRAINT FK_DCL_ROLESMENU_1 FOREIGN KEY (MENUITEMID) REFERENCES DCL_SCRIPTS (NUMSEQ) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE DCL_ROLESMENU ADD CONSTRAINT FK_DCL_ROLESMENU_2 FOREIGN KEY (ROLEID) REFERENCES DCL_ROLES (ROLESID) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE DCL_ROLES_TO_USERS ADD CONSTRAINT FK_DCL_ROLES_TO_USERS_1 FOREIGN KEY (RU_USERID) REFERENCES DCL_USERS (UID) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE DCL_ROLES_TO_USERS ADD CONSTRAINT FK_DCL_ROLES_TO_USERS_2 FOREIGN KEY (RU_ROLEID) REFERENCES DCL_ROLES (ROLESID) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE DCL_USERS ADD CONSTRAINT FK_DCL_USERS_1 FOREIGN KEY (DCL_ROLE) REFERENCES DCL_ROLES (ROLESID) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE DCL_USER_LOGIN_HISTORY ADD CONSTRAINT FK_DCL_USER_LOGIN_HISTORY_1 FOREIGN KEY (UL_USER_ID) REFERENCES DCL_USERS (UID) ON DELETE CASCADE ON UPDATE CASCADE;


/******************************************************************************/
/*                                  Indices                                   */
/******************************************************************************/

CREATE INDEX DCL_ROLESMENU_IDX1 ON DCL_ROLESMENU (ROLEID, MENUITEMID);
CREATE INDEX DCL_SCRIPTS_IDX2 ON DCL_SCRIPTS (DCLNAME);
CREATE UNIQUE INDEX DCL_SCRIPTS_IDX3 ON DCL_SCRIPTS (IDENT, PARENT);


/******************************************************************************/
/*                                  Triggers                                  */
/******************************************************************************/


SET TERM ^ ;



/******************************************************************************/
/*                            Triggers for tables                             */
/******************************************************************************/



/* Trigger: DCL_ACTIVE_USERS_BI */
CREATE OR ALTER TRIGGER DCL_ACTIVE_USERS_BI FOR DCL_ACTIVE_USERS
ACTIVE BEFORE INSERT POSITION 0
as
begin
  if (new.au_id is null) then
    new.au_id = gen_id(gen_dcl_active_users_id,1);
  if (inserting) then
    if (new.active_user_login_time is null) then
      new.active_user_login_time='now';
end
^

/* Trigger: DCL_GLOBAL_PARAMS_BI */
CREATE OR ALTER TRIGGER DCL_GLOBAL_PARAMS_BI FOR DCL_GLOBAL_PARAMS
ACTIVE BEFORE INSERT POSITION 0
as
begin
  if (new.param_id is null) then
    new.param_id = gen_id(main_generator_id,1);
end
^

/* Trigger: DCL_NOTIFYCATIONS_BI0 */
CREATE OR ALTER TRIGGER DCL_NOTIFYCATIONS_BI0 FOR DCL_NOTIFYCATIONS
ACTIVE BEFORE INSERT POSITION 0
as
begin
  if (new.NOTIFY_ID is null) then
    new.NOTIFY_ID = gen_id(MAIN_GENERATOR_ID, 1);
  if (inserting) then
    new.add_date = 'now';
end
^

/* Trigger: DCL_ROLESMENU_BI */
CREATE OR ALTER TRIGGER DCL_ROLESMENU_BI FOR DCL_ROLESMENU
ACTIVE BEFORE INSERT POSITION 0
as
begin
  if (new.rm_id is null) then
    new.rm_id = gen_id(main_generator_id,1);
end
^

/* Trigger: DCL_ROLES_BI */
CREATE OR ALTER TRIGGER DCL_ROLES_BI FOR DCL_ROLES
ACTIVE BEFORE INSERT POSITION 0
as
begin
  if (new.rolesid is null) then
    new.rolesid = gen_id(main_generator_id,1);
end
^

/* Trigger: DCL_ROLES_TO_USERS_BI */
CREATE OR ALTER TRIGGER DCL_ROLES_TO_USERS_BI FOR DCL_ROLES_TO_USERS
ACTIVE BEFORE INSERT POSITION 0
as
begin
  if (new.ru_id is null) then
    new.ru_id = gen_id(main_generator_id,1);
end
^

/* Trigger: DCL_SCRIPTS_BI */
CREATE OR ALTER TRIGGER DCL_SCRIPTS_BI FOR DCL_SCRIPTS
ACTIVE BEFORE INSERT OR UPDATE POSITION 0
as
begin
  if (new.NUMSEQ is null) then
    new.NUMSEQ = gen_id(DCL_SCRIPTS_NEXT_ID, 1);

  new.UPDATES = 'now';
  if (inserting) then
    new.ACTINON = 'I';
  if (updating) then
    new.ACTINON = 'U';
end
^

/* Trigger: DCL_TEMPLATES_BI */
CREATE OR ALTER TRIGGER DCL_TEMPLATES_BI FOR DCL_TEMPLATES
ACTIVE BEFORE INSERT POSITION 0
as
begin
  if (new.teid is null) then
    new.teid = gen_id(main_generator_id,1);
end
^

/* Trigger: DCL_USERS_BI */
CREATE OR ALTER TRIGGER DCL_USERS_BI FOR DCL_USERS
ACTIVE BEFORE INSERT POSITION 0
as
begin
  if (new.uid is null) then
    new.uid = gen_id(main_generator_id,1);
end
^

/* Trigger: DCL_USER_LOGIN_HISTORY_BI */
CREATE OR ALTER TRIGGER DCL_USER_LOGIN_HISTORY_BI FOR DCL_USER_LOGIN_HISTORY
ACTIVE BEFORE INSERT POSITION 0
as
begin
  if (new.UL_ID is null) then
    new.UL_ID = gen_id(GEN_DCL_USER_LOGIN_HISTORY_ID, 1);
end
^

/* Trigger: INI_PROFILES_BI */
CREATE OR ALTER TRIGGER INI_PROFILES_BI FOR DCL_INI_PROFILES
ACTIVE BEFORE INSERT POSITION 0
as
begin
  if (new.ini_id is null) then
    new.ini_id = gen_id(gen_ini_profiles_id,1);
end
^

/* Trigger: ORGANIZATIONS_BI */
CREATE OR ALTER TRIGGER ORGANIZATIONS_BI FOR ORGANIZATIONS
ACTIVE BEFORE INSERT POSITION 0
as
begin
  if (new.oid is null) then
    new.oid = gen_id(main_generator_id,1);
end
^

SET TERM ; ^



/******************************************************************************/
/*                             Stored Procedures                              */
/******************************************************************************/


SET TERM ^ ;

CREATE OR ALTER PROCEDURE ADD_MENU_ITEM_TO_ROLE (
    ROLEID INTEGER,
    MENUITEMID INTEGER)
RETURNS (
    ISAPPEND INTEGER)
AS
declare variable TMP1 integer;
begin
  select count(R.ROLEID)
  from DCL_ROLESMENU R
  where R.ROLEID = :ROLEID and
        R.MENUITEMID = :MENUITEMID
  into TMP1;
  if (:TMP1 = 0) then
  begin
    insert into DCL_ROLESMENU (ROLEID, MENUITEMID)
    values (:ROLEID, :MENUITEMID);
    ISAPPEND = 1;
    suspend;
  end
  else
  begin
    ISAPPEND = 0;
    suspend;
  end
end^


CREATE OR ALTER PROCEDURE COPY_ROLE (
    ROLEIDFROM INTEGER,
    ROLEIDTO INTEGER)
AS
begin
  insert into DCL_ROLESMENU(ROLEID, MENUITEMID)
  select :ROLEIDTO, MENUITEMID
  from DCL_ROLESMENU R
  where R.ROLEID = :ROLEIDFROM;
end^


CREATE OR ALTER PROCEDURE DEL_ROLE_AND_MENU (
    ROLEID INTEGER)
AS
begin
  delete from DCL_rolesmenu r where r.roleid=:roleid and r.roleid not in (select u1.dcl_role from dcl_users u1);
  Delete from DCL_roles r where r.rolesid=:roleid and r.rolesid not in (select u1.dcl_role from dcl_users u1);
end^


CREATE OR ALTER PROCEDURE DEL_ROLE_MENU (
    ROLEID INTEGER)
AS
begin
    delete from DCL_rolesmenu r where r.roleid=:roleid and r.roleid not in (select u1.dcl_role from dcl_users u1);
end^


CREATE OR ALTER PROCEDURE FIRST_DAY_OF_MONTH (
    ADATE DATE)
RETURNS (
    RESULT DATE)
AS
begin
if (:adate is null) then adate='now';
Result=ADate-EXTRACT(DAY FROM ADate) + 1;
  suspend;
end^


CREATE OR ALTER PROCEDURE IS_NUMBER (
    A_VALUE VARCHAR(32))
RETURNS (
    RESULT INTEGER)
AS
declare variable I integer;
declare variable J integer;
begin
  result = 0;
  a_value = trim(a_value);
  IF (a_value IS NULL OR char_length(a_value) = 0) then begin
    suspend;
    exit;
  end
  i = 1;
  j = CHAR_LENGTH(a_value);
  while (i <= j) do begin
    IF (substring(a_value FROM i FOR 1) BETWEEN '0' AND '9'
     OR (i =1 AND substring(a_value FROM 1 FOR 1) IN ('-', '+')
       AND CHAR_LENGTH(a_value) > 1 )) then
      result = 1;
    else begin
      result = 0;
      Break;
    end
    i = i + 1;
  end
  suspend;
end^


CREATE OR ALTER PROCEDURE ROLESMENU_IS_CORRECT
RETURNS (
    NUMSEQ INTEGER,
    DCLNAME VARCHAR(50),
    IDENT INTEGER,
    ROLE_ID INTEGER,
    ROLE_NAME VARCHAR(50))
AS
declare variable HEAD_EXISTS integer;
declare variable PARENT integer;
begin
for select r.rolesid, r.longrolename from DCL_roles r order by r.longrolename into :role_id, :role_name do
for select d.numseq, d.ident, d.parent from DCL_RolesMenu rm, DCL_Roles r, DCL_SCRIPTS d where r.rolesid=rm.roleid and rm.MENUITEMID=d.numseq and r.rolesid=:role_id into :numseq, :ident, :parent do
begin
    select count(*) from DCL_RolesMenu rm, DCL_Roles r, DCL_SCRIPTS d where r.rolesid=rm.roleid and rm.MENUITEMID=d.numseq and d.ident=:parent and r.rolesid=:role_id into :head_exists;
    if (:head_exists=0) then
    begin
        for select s.numseq, s.dclname, s.ident from DCL_scripts s where s.ident=:parent into :numseq, :dclname, :ident do suspend;
    end
end
end^



SET TERM ; ^


/******************************************************************************/
/*                                Descriptions                                */
/******************************************************************************/

DESCRIBE TABLE DCL_GLOBAL_PARAMS
'��������� ������� �������';

DESCRIBE TABLE DCL_ROLESMENU
'���� �����';

DESCRIBE TABLE DCL_ROLES_TO_USERS
'������� ������������� ����� ����� � �������������';

DESCRIBE TABLE DCL_SCRIPTS
'�������';

DESCRIBE TABLE DCL_TEMPLATES
'������� �������';

DESCRIBE TABLE ORGANIZATIONS
'�����������';



/******************************************************************************/
/*                                Descriptions                                */
/******************************************************************************/

DESCRIBE PROCEDURE ADD_MENU_ITEM_TO_ROLE
'���������� ������ ���� � ����';

DESCRIBE PROCEDURE COPY_ROLE
'Копирование роли';

DESCRIBE PROCEDURE FIRST_DAY_OF_MONTH
'������ ���� ������';

DESCRIBE PROCEDURE IS_NUMBER
'�������� �������� �� ������ ������';

DESCRIBE PROCEDURE ROLESMENU_IS_CORRECT
'�������� ������������ ���� �����';



/******************************************************************************/
/*                                Descriptions                                */
/******************************************************************************/

DESCRIBE GENERATOR MAIN_GENERATOR_ID
'���� ������� �� ����';



/******************************************************************************/
/*                            Fields descriptions                             */
/******************************************************************************/

DESCRIBE FIELD ROLEID TABLE DCL_ROLESMENU
'ID ����';

DESCRIBE FIELD MENUITEMID TABLE DCL_ROLESMENU
'ID �������� ���� � ����';
