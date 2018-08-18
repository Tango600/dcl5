/******************************************************************************/
/*                 Generated by IBExpert 07.12.2015 10:44:29                  */
/******************************************************************************/

/******************************************************************************/
/*        Following SET SQL DIALECT is just for the Database Comparer         */
/******************************************************************************/
SET SQL DIALECT 3;



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
    INI_TYPE         INTEGER DEFAULT 1,
    INI_PARAM_VALUE  BLOB SUB_TYPE 1 SEGMENT SIZE 2048
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
    DCLNAME  CHAR(50),
    DCLTEXT  BLOB SUB_TYPE 1 SEGMENT SIZE 80,
    COMMAND  CHAR(80),
    IDENT    INTEGER,
    PARENT   INTEGER,
    UPDATES  TIMESTAMP,
    ACTINON  CHAR(1)
);

CREATE TABLE DCL_TEMPLATES (
    TEID            INTEGER NOT NULL,
    TEMPL_NAME      VARCHAR(40) NOT NULL,
    TEMPL_DATA      BLOB SUB_TYPE 0 SEGMENT SIZE 80,
    TEMPL_DATATYPE  INTEGER
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
    DCL_USER_PASS       DM_PASSWORD,
    DCL_ROLE            INTEGER,
    SHOWINLIST          SMALLINT,
    ACCESSLEVEL         SMALLINT,
    DBUSER_NAME         VARCHAR(300),
    DBPASS              VARCHAR(40)
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


INSERT INTO DCL_ROLES (ROLESID, ROLENAME, LONGROLENAME, SHOWINLIST, ROLE_ACCESSLEVEL) VALUES (1, 'Admin', '�������������', NULL, 8);
INSERT INTO DCL_ROLES (ROLESID, ROLENAME, LONGROLENAME, SHOWINLIST, ROLE_ACCESSLEVEL) VALUES (2, 'Dir', '��������', 1, 5);
INSERT INTO DCL_ROLES (ROLESID, ROLENAME, LONGROLENAME, SHOWINLIST, ROLE_ACCESSLEVEL) VALUES (3, 'Oper', '��������', 1, 4);

COMMIT WORK;

INSERT INTO DCL_SCRIPTS (NUMSEQ, DCLNAME, DCLTEXT, COMMAND, IDENT, PARENT, UPDATES, ACTINON) VALUES (100107, '��������� �������� ������', NULL, 'BinStore', 1305, 10, '2014-10-03 17:03:22', 'U');

SET BLOBFILE 'NewBase.lob';

INSERT INTO DCL_SCRIPTS (NUMSEQ, DCLNAME, DCLTEXT, COMMAND, IDENT, PARENT, UPDATES, ACTINON) VALUES (1, 'GlobalParams_AP', :h0_2F, NULL, NULL, NULL, '2014-10-09 18:19:04', 'U');
INSERT INTO DCL_SCRIPTS (NUMSEQ, DCLNAME, DCLTEXT, COMMAND, IDENT, PARENT, UPDATES, ACTINON) VALUES (2, '-', NULL, NULL, 1340, 10, '2014-11-10 09:56:59', 'U');
INSERT INTO DCL_SCRIPTS (NUMSEQ, DCLNAME, DCLTEXT, COMMAND, IDENT, PARENT, UPDATES, ACTINON) VALUES (100002, 'Roles', :h2F_103, NULL, NULL, NULL, '2014-10-03 17:12:34', 'U');
INSERT INTO DCL_SCRIPTS (NUMSEQ, DCLNAME, DCLTEXT, COMMAND, IDENT, PARENT, UPDATES, ACTINON) VALUES (100108, 'BinStore', :h132_284, NULL, NULL, NULL, '2014-10-09 15:09:20', 'U');
INSERT INTO DCL_SCRIPTS (NUMSEQ, DCLNAME, DCLTEXT, COMMAND, IDENT, PARENT, UPDATES, ACTINON) VALUES (100004, '����', NULL, 'Roles', 10003, 1289, '2013-07-30 14:43:44', 'U');
INSERT INTO DCL_SCRIPTS (NUMSEQ, DCLNAME, DCLTEXT, COMMAND, IDENT, PARENT, UPDATES, ACTINON) VALUES (100109, 'BinStore_Edit_Scr', :h3B6_23, NULL, NULL, NULL, '2014-10-03 17:18:36', 'U');
INSERT INTO DCL_SCRIPTS (NUMSEQ, DCLNAME, DCLTEXT, COMMAND, IDENT, PARENT, UPDATES, ACTINON) VALUES (100110, 'BinStore_Add_Scr', :h3D9_2C, NULL, NULL, NULL, '2014-10-03 17:00:32', 'I');
INSERT INTO DCL_SCRIPTS (NUMSEQ, DCLNAME, DCLTEXT, COMMAND, IDENT, PARENT, UPDATES, ACTINON) VALUES (3, '����� ��������', NULL, NULL, 1320, 10, '2014-11-10 09:57:33', 'I');
INSERT INTO DCL_SCRIPTS (NUMSEQ, DCLNAME, DCLTEXT, COMMAND, IDENT, PARENT, UPDATES, ACTINON) VALUES (4, '���������', NULL, 'SignScript', 10012, 1320, '2014-11-10 10:02:10', 'U');
INSERT INTO DCL_SCRIPTS (NUMSEQ, DCLNAME, DCLTEXT, COMMAND, IDENT, PARENT, UPDATES, ACTINON) VALUES (5, '���������', NULL, 'RunScript', 10010, 1320, '2014-11-10 10:01:57', 'U');
INSERT INTO DCL_SCRIPTS (NUMSEQ, DCLNAME, DCLTEXT, COMMAND, IDENT, PARENT, UPDATES, ACTINON) VALUES (6, '�������������', NULL, 'ReSignScript', 10014, 1320, '2014-11-10 10:02:26', 'U');
INSERT INTO DCL_SCRIPTS (NUMSEQ, DCLNAME, DCLTEXT, COMMAND, IDENT, PARENT, UPDATES, ACTINON) VALUES (7, 'RunScript', :h405_21, NULL, NULL, NULL, '2014-11-10 10:07:56', 'U');
INSERT INTO DCL_SCRIPTS (NUMSEQ, DCLNAME, DCLTEXT, COMMAND, IDENT, PARENT, UPDATES, ACTINON) VALUES (8, 'SignScript', :h426_20, NULL, NULL, NULL, '2014-11-10 10:07:30', 'U');
INSERT INTO DCL_SCRIPTS (NUMSEQ, DCLNAME, DCLTEXT, COMMAND, IDENT, PARENT, UPDATES, ACTINON) VALUES (9, 'ReSignScript', :h446_22, NULL, NULL, NULL, '2014-11-10 10:08:36', 'U');
INSERT INTO DCL_SCRIPTS (NUMSEQ, DCLNAME, DCLTEXT, COMMAND, IDENT, PARENT, UPDATES, ACTINON) VALUES (100111, 'BinStore_Edit_Dlg', :h468_C5, NULL, NULL, NULL, '2014-10-16 12:00:50', 'U');
INSERT INTO DCL_SCRIPTS (NUMSEQ, DCLNAME, DCLTEXT, COMMAND, IDENT, PARENT, UPDATES, ACTINON) VALUES (100006, 'Global_Params', :h52D_1F6, NULL, NULL, NULL, '2014-10-09 18:17:39', 'U');
INSERT INTO DCL_SCRIPTS (NUMSEQ, DCLNAME, DCLTEXT, COMMAND, IDENT, PARENT, UPDATES, ACTINON) VALUES (100161, 'TemplateCompress', :h723_53, NULL, NULL, NULL, '2014-10-03 17:07:16', 'U');
INSERT INTO DCL_SCRIPTS (NUMSEQ, DCLNAME, DCLTEXT, COMMAND, IDENT, PARENT, UPDATES, ACTINON) VALUES (100162, 'TemplateDeCompress', :h776_55, NULL, NULL, NULL, '2014-10-03 17:07:47', 'U');
INSERT INTO DCL_SCRIPTS (NUMSEQ, DCLNAME, DCLTEXT, COMMAND, IDENT, PARENT, UPDATES, ACTINON) VALUES (100008, 'InitApp', :h7CB_51, NULL, 40001, NULL, '2013-07-30 14:43:44', 'U');
INSERT INTO DCL_SCRIPTS (NUMSEQ, DCLNAME, DCLTEXT, COMMAND, IDENT, PARENT, UPDATES, ACTINON) VALUES (100163, 'TemplateExport', :h81C_93, NULL, NULL, NULL, '2014-10-03 17:08:22', 'U');
INSERT INTO DCL_SCRIPTS (NUMSEQ, DCLNAME, DCLTEXT, COMMAND, IDENT, PARENT, UPDATES, ACTINON) VALUES (100164, 'TemplateImport', :h8AF_89, NULL, NULL, NULL, '2014-10-03 17:08:48', 'U');
INSERT INTO DCL_SCRIPTS (NUMSEQ, DCLNAME, DCLTEXT, COMMAND, IDENT, PARENT, UPDATES, ACTINON) VALUES (100010, 'Orgs', :h938_1DC, NULL, NULL, NULL, '2014-10-03 17:21:13', 'U');
INSERT INTO DCL_SCRIPTS (NUMSEQ, DCLNAME, DCLTEXT, COMMAND, IDENT, PARENT, UPDATES, ACTINON) VALUES (100012, 'Orgs_Set_Main_Scr', :hB14_81, NULL, NULL, NULL, '2013-07-30 14:43:44', 'U');
INSERT INTO DCL_SCRIPTS (NUMSEQ, DCLNAME, DCLTEXT, COMMAND, IDENT, PARENT, UPDATES, ACTINON) VALUES (100014, '�������������', :hB95_5, NULL, 1350, 10, '2013-07-30 14:43:44', 'U');
INSERT INTO DCL_SCRIPTS (NUMSEQ, DCLNAME, DCLTEXT, COMMAND, IDENT, PARENT, UPDATES, ACTINON) VALUES (100016, '����', NULL, NULL, 1289, 10, '2013-07-30 14:43:44', 'U');
INSERT INTO DCL_SCRIPTS (NUMSEQ, DCLNAME, DCLTEXT, COMMAND, IDENT, PARENT, UPDATES, ACTINON) VALUES (100018, 'Users', :hB9A_3C6, NULL, NULL, NULL, '2015-08-06 11:28:10', 'U');
INSERT INTO DCL_SCRIPTS (NUMSEQ, DCLNAME, DCLTEXT, COMMAND, IDENT, PARENT, UPDATES, ACTINON) VALUES (100020, 'RolesMenu', :hF60_369, NULL, NULL, NULL, '2014-10-03 17:12:28', 'U');
INSERT INTO DCL_SCRIPTS (NUMSEQ, DCLNAME, DCLTEXT, COMMAND, IDENT, PARENT, UPDATES, ACTINON) VALUES (100022, 'Roles_AddMenuItem', :h12C9_1EC, NULL, NULL, NULL, '2014-10-03 17:19:08', 'U');
INSERT INTO DCL_SCRIPTS (NUMSEQ, DCLNAME, DCLTEXT, COMMAND, IDENT, PARENT, UPDATES, ACTINON) VALUES (100024, 'Roles_AddMenuItemExec', :h14B5_10B, NULL, NULL, NULL, '2013-07-30 14:43:44', 'U');
INSERT INTO DCL_SCRIPTS (NUMSEQ, DCLNAME, DCLTEXT, COMMAND, IDENT, PARENT, UPDATES, ACTINON) VALUES (100026, 'Roles_AddRoleCallDialog', :h15C0_21, NULL, NULL, NULL, '2013-07-30 14:43:44', 'U');
INSERT INTO DCL_SCRIPTS (NUMSEQ, DCLNAME, DCLTEXT, COMMAND, IDENT, PARENT, UPDATES, ACTINON) VALUES (100028, 'Roles_CopyRole', :h15E1_1A0, NULL, NULL, NULL, '2014-10-03 17:22:47', 'U');
INSERT INTO DCL_SCRIPTS (NUMSEQ, DCLNAME, DCLTEXT, COMMAND, IDENT, PARENT, UPDATES, ACTINON) VALUES (100030, 'Roles_CopyRoleExec', :h1781_6A, NULL, NULL, NULL, '2013-07-30 14:43:44', 'U');
INSERT INTO DCL_SCRIPTS (NUMSEQ, DCLNAME, DCLTEXT, COMMAND, IDENT, PARENT, UPDATES, ACTINON) VALUES (100032, 'Roles_CopyRole_Call', :h17EB_1E, NULL, NULL, NULL, '2013-07-30 14:43:44', 'U');
INSERT INTO DCL_SCRIPTS (NUMSEQ, DCLNAME, DCLTEXT, COMMAND, IDENT, PARENT, UPDATES, ACTINON) VALUES (100034, 'Roles_DelRole', :h1809_CA, NULL, NULL, NULL, '2013-07-30 14:43:44', 'U');
INSERT INTO DCL_SCRIPTS (NUMSEQ, DCLNAME, DCLTEXT, COMMAND, IDENT, PARENT, UPDATES, ACTINON) VALUES (100036, 'Roles_DelRoleExec', :h18D3_58, NULL, NULL, NULL, '2013-07-30 14:43:44', 'U');
INSERT INTO DCL_SCRIPTS (NUMSEQ, DCLNAME, DCLTEXT, COMMAND, IDENT, PARENT, UPDATES, ACTINON) VALUES (100038, 'Roles_DelRoleMenuItem', :h192B_E2, NULL, NULL, NULL, '2013-07-30 14:43:44', 'U');
INSERT INTO DCL_SCRIPTS (NUMSEQ, DCLNAME, DCLTEXT, COMMAND, IDENT, PARENT, UPDATES, ACTINON) VALUES (100040, 'Roles_DelRolesMenuItem', :h1A0D_126, NULL, NULL, NULL, '2014-10-03 17:19:24', 'U');
INSERT INTO DCL_SCRIPTS (NUMSEQ, DCLNAME, DCLTEXT, COMMAND, IDENT, PARENT, UPDATES, ACTINON) VALUES (100042, 'Roles_DelRolesMenuItem_Call', :h1B33_26, NULL, NULL, NULL, '2013-07-30 14:43:44', 'U');
INSERT INTO DCL_SCRIPTS (NUMSEQ, DCLNAME, DCLTEXT, COMMAND, IDENT, PARENT, UPDATES, ACTINON) VALUES (100044, 'Roles_Run_Test_RolesMenu', :h1B59_1C, NULL, NULL, NULL, '2013-07-30 14:43:44', 'U');
INSERT INTO DCL_SCRIPTS (NUMSEQ, DCLNAME, DCLTEXT, COMMAND, IDENT, PARENT, UPDATES, ACTINON) VALUES (100046, 'Roles_Test_RolesMenu', :h1B75_1A3, NULL, NULL, NULL, '2014-10-03 17:19:33', 'U');
INSERT INTO DCL_SCRIPTS (NUMSEQ, DCLNAME, DCLTEXT, COMMAND, IDENT, PARENT, UPDATES, ACTINON) VALUES (100048, '-', NULL, NULL, 1311, 10, '2013-07-30 14:43:44', 'U');
INSERT INTO DCL_SCRIPTS (NUMSEQ, DCLNAME, DCLTEXT, COMMAND, IDENT, PARENT, UPDATES, ACTINON) VALUES (100050, 'SQL Mon', :h1D18_7, NULL, 1501, 10, '2013-07-30 14:43:44', 'U');
INSERT INTO DCL_SCRIPTS (NUMSEQ, DCLNAME, DCLTEXT, COMMAND, IDENT, PARENT, UPDATES, ACTINON) VALUES (100052, 'Set_Org_Scr', :h1D1F_F9, NULL, NULL, NULL, '2013-07-30 14:43:44', 'U');
INSERT INTO DCL_SCRIPTS (NUMSEQ, DCLNAME, DCLTEXT, COMMAND, IDENT, PARENT, UPDATES, ACTINON) VALUES (100054, '������', :h1E18_8, NULL, 1901, 10, '2013-07-30 14:43:44', 'U');
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
INSERT INTO DCL_SCRIPTS (NUMSEQ, DCLNAME, DCLTEXT, COMMAND, IDENT, PARENT, UPDATES, ACTINON) VALUES (100080, '-', NULL, NULL, 1290, 10, '2014-11-10 09:55:25', 'U');
INSERT INTO DCL_SCRIPTS (NUMSEQ, DCLNAME, DCLTEXT, COMMAND, IDENT, PARENT, UPDATES, ACTINON) VALUES (100082, '09.00.83.181', NULL, NULL, 50000, NULL, '2013-07-30 14:43:44', 'U');
INSERT INTO DCL_SCRIPTS (NUMSEQ, DCLNAME, DCLTEXT, COMMAND, IDENT, PARENT, UPDATES, ACTINON) VALUES (100084, 'User_Edit_Dlg', :h1E20_288, NULL, NULL, NULL, '2014-10-03 17:17:19', 'U');
INSERT INTO DCL_SCRIPTS (NUMSEQ, DCLNAME, DCLTEXT, COMMAND, IDENT, PARENT, UPDATES, ACTINON) VALUES (100086, 'User_Edit_Scr', :h20A8_1D, NULL, NULL, NULL, '2013-07-30 14:43:44', 'U');
INSERT INTO DCL_SCRIPTS (NUMSEQ, DCLNAME, DCLTEXT, COMMAND, IDENT, PARENT, UPDATES, ACTINON) VALUES (100088, 'Notify_Add_Scr', :h20C5_BB, NULL, NULL, NULL, '2013-07-30 14:43:44', 'U');
INSERT INTO DCL_SCRIPTS (NUMSEQ, DCLNAME, DCLTEXT, COMMAND, IDENT, PARENT, UPDATES, ACTINON) VALUES (100090, 'Notify_Add', :h2180_1A4, NULL, NULL, NULL, '2013-07-30 14:43:44', 'U');
INSERT INTO DCL_SCRIPTS (NUMSEQ, DCLNAME, DCLTEXT, COMMAND, IDENT, PARENT, UPDATES, ACTINON) VALUES (100092, 'Roles_Notify_Add_Scr', :h2324_29, NULL, NULL, NULL, '2013-07-30 14:43:44', 'U');
INSERT INTO DCL_SCRIPTS (NUMSEQ, DCLNAME, DCLTEXT, COMMAND, IDENT, PARENT, UPDATES, ACTINON) VALUES (100094, 'Notifycations', :h234D_242, NULL, NULL, NULL, '2014-10-03 17:21:09', 'U');
INSERT INTO DCL_SCRIPTS (NUMSEQ, DCLNAME, DCLTEXT, COMMAND, IDENT, PARENT, UPDATES, ACTINON) VALUES (100096, 'Global_Params_Edit_Dlg', :h258F_EC, '', NULL, NULL, '2014-10-03 17:20:59', 'U');
INSERT INTO DCL_SCRIPTS (NUMSEQ, DCLNAME, DCLTEXT, COMMAND, IDENT, PARENT, UPDATES, ACTINON) VALUES (100098, 'Global_Params_Edit_Scr', :h267B_26, NULL, NULL, NULL, '2013-07-30 14:43:44', 'U');
INSERT INTO DCL_SCRIPTS (NUMSEQ, DCLNAME, DCLTEXT, COMMAND, IDENT, PARENT, UPDATES, ACTINON) VALUES (100100, 'Attachments', :h26A1_382, NULL, NULL, NULL, '2014-10-03 17:20:45', 'U');
INSERT INTO DCL_SCRIPTS (NUMSEQ, DCLNAME, DCLTEXT, COMMAND, IDENT, PARENT, UPDATES, ACTINON) VALUES (100102, '�����������', NULL, 'Attachments', 1300, 10, '2013-07-30 14:43:44', 'U');
INSERT INTO DCL_SCRIPTS (NUMSEQ, DCLNAME, DCLTEXT, COMMAND, IDENT, PARENT, UPDATES, ACTINON) VALUES (100104, 'Attachments_Terminate', :h2A23_5B, NULL, NULL, NULL, '2013-07-30 14:43:44', 'U');
INSERT INTO DCL_SCRIPTS (NUMSEQ, DCLNAME, DCLTEXT, COMMAND, IDENT, PARENT, UPDATES, ACTINON) VALUES (100106, '�����', :h2A7E_5, NULL, 999, NULL, '2013-07-30 14:43:44', 'U');

COMMIT WORK;

INSERT INTO DCL_ROLESMENU (ROLEID, MENUITEMID, RM_ID) VALUES (1, 100004, 100001);
INSERT INTO DCL_ROLESMENU (ROLEID, MENUITEMID, RM_ID) VALUES (1, 100107, 100160);
INSERT INTO DCL_ROLESMENU (ROLEID, MENUITEMID, RM_ID) VALUES (1, 100016, 100002);
INSERT INTO DCL_ROLESMENU (ROLEID, MENUITEMID, RM_ID) VALUES (1, 100014, 100003);
INSERT INTO DCL_ROLESMENU (ROLEID, MENUITEMID, RM_ID) VALUES (1, 4, 1055);
INSERT INTO DCL_ROLESMENU (ROLEID, MENUITEMID, RM_ID) VALUES (1, 5, 1056);
INSERT INTO DCL_ROLESMENU (ROLEID, MENUITEMID, RM_ID) VALUES (1, 100008, 100004);
INSERT INTO DCL_ROLESMENU (ROLEID, MENUITEMID, RM_ID) VALUES (1, 6, 1057);
INSERT INTO DCL_ROLESMENU (ROLEID, MENUITEMID, RM_ID) VALUES (1, 2, 1058);
INSERT INTO DCL_ROLESMENU (ROLEID, MENUITEMID, RM_ID) VALUES (1, 3, 1059);
INSERT INTO DCL_ROLESMENU (ROLEID, MENUITEMID, RM_ID) VALUES (1, 100048, 1060);
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

INSERT INTO DCL_USERS (UID, DCL_USER_NAME, DCL_LONG_USER_NAME, DCL_USER_PASS, DCL_ROLE, SHOWINLIST, ACCESSLEVEL, DBUSER_NAME, DBPASS) VALUES (13, 'Oper', '��������', '951', 3, 1, 1, NULL, NULL);
INSERT INTO DCL_USERS (UID, DCL_USER_NAME, DCL_LONG_USER_NAME, DCL_USER_PASS, DCL_ROLE, SHOWINLIST, ACCESSLEVEL, DBUSER_NAME, DBPASS) VALUES (11, 'Admin', '�������������', '789', 1, NULL, 8, NULL, NULL);
INSERT INTO DCL_USERS (UID, DCL_USER_NAME, DCL_LONG_USER_NAME, DCL_USER_PASS, DCL_ROLE, SHOWINLIST, ACCESSLEVEL, DBUSER_NAME, DBPASS) VALUES (12, 'Dir', '��������', '555', 2, 1, 5, NULL, NULL);

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


/******************************************************************************/
/*                                Foreign Keys                                */
/******************************************************************************/

ALTER TABLE DCL_ACTIVE_USERS ADD CONSTRAINT FK_DCL_ACTIVE_USERS_1 FOREIGN KEY (ACTIVE_USER_ID) REFERENCES DCL_USERS (UID) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE DCL_INI_PROFILES ADD CONSTRAINT FK_DCL_INI_PROFILES_1 FOREIGN KEY (INI_USER_ID) REFERENCES DCL_USERS (UID) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE DCL_NOTIFYCATIONS ADD CONSTRAINT FK_DCL_NOTIFYCATIONS_1 FOREIGN KEY (USER_ID) REFERENCES DCL_USERS (UID) ON DELETE CASCADE ON UPDATE CASCADE;
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
