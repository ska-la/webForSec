  INSERT INTO evout (EVENT,POBJECT,INFO,MISC) VALUES (133,1626,6,-1);
  INSERT INTO events   (D,T,PCARD,PUSER,PCOMPUTER,APPLICATION,EVENT,STATUS,POBJECT,PKEY,PALEVEL,PGLEVEL,COMMENTTYPE,COMMENT,PAZONEIN,PAZONEOUT,PVIDEO,PCARDTYPE,DFROM,DTO,PMAKET,LOBJECT)    VALUES ((select ( datediff(day from date '1-Jan-0001' to current_date) + 1 ) from rdb$database),(select datediff(millisecond from time '0:00:00.000' to current_time) from rdb$database),0,6,13,5,127,Null,1626,0,0,0,133,Null,0,0,0,0,Null,Null,0,Null);
  commit;

