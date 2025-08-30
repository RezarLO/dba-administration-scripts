
-- Created Definiation table containing affected tables/columns/policy 

CREATE TABLE USED_TABLES (
    OWNER        VARCHAR2(128) NOT NULL,
    TABLE_NAME   VARCHAR2(128) NOT NULL,
    COLUMN_NAME  VARCHAR2(128) NOT NULL,
    REDACT_TYPE  VARCHAR2(30)  NOT NULL, -- e.g. 'NUMBER' or 'VARCHAR' or 'DATE'
    STATUS_MSG   VARCHAR2(4000)          -- audit column (success/error details)
);



-- this is where the magic happens :
DECLARE
    CURSOR c_tables IS
        SELECT ROWID rid,
               OWNER,
               TABLE_NAME,
               COLUMN_NAME,
               REDACT_TYPE
          FROM USED_TABLES;

    v_sql         VARCHAR2(4000);
    v_policy_name VARCHAR2(128);
    v_errmsg      VARCHAR2(4000);
BEGIN
    FOR r IN c_tables LOOP
        v_policy_name := 'REDACT_' || r.TABLE_NAME;

        BEGIN
            -- Ensure policy exists on the table (with minimal condition)
            v_sql := 'BEGIN SYS.DBMS_REDACT.ADD_POLICY(' ||
                     'object_schema => ''' || r.OWNER || ''',' ||
                     'object_name   => ''' || r.TABLE_NAME || ''',' ||
                     'policy_name   => ''' || v_policy_name || ''',' ||
                     'expression    => ''1=1''); END;';
            EXECUTE IMMEDIATE v_sql;
        EXCEPTION
            WHEN OTHERS THEN
                -- ORA-28069 = policy already exists, skip
                IF SQLCODE != -28069 THEN
                    v_errmsg := 'FAILED (ADD_POLICY): ' || SQLERRM;
                    UPDATE USED_TABLES
                       SET STATUS_MSG = v_errmsg
                     WHERE ROWID = r.rid;
                    CONTINUE;
                END IF;
        END;

        -- Build redaction for column depending on type
        IF r.REDACT_TYPE = 'NUMBER' THEN
            v_sql := 'BEGIN SYS.DBMS_REDACT.ALTER_POLICY(' ||
                     'object_schema => ''' || r.OWNER || ''',' ||
                     'object_name   => ''' || r.TABLE_NAME || ''',' ||
                     'policy_name   => ''' || v_policy_name || ''',' ||
                     'action        => SYS.DBMS_REDACT.ADD_COLUMN,' ||
                     'column_name   => ''' || r.COLUMN_NAME || ''',' ||
                     'function_type => SYS.DBMS_REDACT.REGEXP,' ||
                     'regexp_pattern => SYS.DBMS_REDACT.RE_PATTERN_ANY_DIGIT,' ||
                     'regexp_replace_string => SYS.DBMS_REDACT.RE_REDACT_WITH_SINGLE_X); END;';

        ELSIF r.REDACT_TYPE = 'VARCHAR' THEN
            v_sql := 'BEGIN SYS.DBMS_REDACT.ALTER_POLICY(' ||
                     'object_schema => ''' || r.OWNER || ''',' ||
                     'object_name   => ''' || r.TABLE_NAME || ''',' ||
                     'policy_name   => ''' || v_policy_name || ''',' ||
                     'action        => SYS.DBMS_REDACT.ADD_COLUMN,' ||
                     'column_name   => ''' || r.COLUMN_NAME || ''',' ||
                     'function_type => SYS.DBMS_REDACT.RANDOM); END;';

        ELSIF r.REDACT_TYPE = 'DATE' THEN
            v_sql := 'BEGIN SYS.DBMS_REDACT.ALTER_POLICY(' ||
                     'object_schema       => ''' || r.OWNER || ''',' ||
                     'object_name         => ''' || r.TABLE_NAME || ''',' ||
                     'policy_name         => ''' || v_policy_name || ''',' ||
                     'action              => SYS.DBMS_REDACT.ADD_COLUMN,' ||
                     'column_name         => ''' || r.COLUMN_NAME || ''',' ||
                     'function_type       => SYS.DBMS_REDACT.PARTIAL,' ||
                     'function_parameters => ''m1d1Y''); END;';

        ELSE
            UPDATE USED_TABLES
               SET STATUS_MSG = 'SKIPPED: Unsupported REDACT_TYPE (' || r.REDACT_TYPE || ')'
             WHERE ROWID = r.rid;
            CONTINUE;
        END IF;

        -- Execute and audit
        BEGIN
            EXECUTE IMMEDIATE v_sql;
            UPDATE USED_TABLES
               SET STATUS_MSG = 'SUCCESS: Column ' || r.COLUMN_NAME || ' redacted under ' || v_policy_name
             WHERE ROWID = r.rid;
        EXCEPTION
            WHEN OTHERS THEN
                IF SQLCODE = -28104 THEN
                    UPDATE USED_TABLES
                       SET STATUS_MSG = 'SKIPPED: Column already redacted'
                     WHERE ROWID = r.rid;
                ELSE
                    v_errmsg := 'FAILED (ALTER_POLICY): ' || SQLERRM;
                    UPDATE USED_TABLES
                       SET STATUS_MSG = v_errmsg
                     WHERE ROWID = r.rid;
                END IF;
        END;
    END LOOP;
END;
/

