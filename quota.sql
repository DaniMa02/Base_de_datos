DECLARE
    v_increase_quota NUMBER := 4; 
BEGIN
    FOR user_rec IN (
        SELECT u.username,
               COALESCE(q.bytes, 0) / (1024*1024) AS current_quota_mbs, 
               COALESCE(q.max_bytes, 0) / (1024*1024) AS max_quota_mbs 
        FROM dba_users u
        LEFT JOIN dba_ts_quotas q ON u.username = q.username
        WHERE u.account_status = 'OPEN' -- Filtrar usuarios que no son del sistema
    )
    LOOP
        IF user_rec.current_quota_mbs = user_rec.max_quota_mbs THEN
            EXECUTE IMMEDIATE 'ALTER USER ' || user_rec.username || ' QUOTA ' || (user_rec.max_quota_mbs + v_increase_quota) || 'M ON USERS';
        END IF;
    END LOOP;
END;
/
