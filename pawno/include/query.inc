#if defined querybuilder_included
	#endinput
#endif
#define querybuilder_included

#if !defined mysql_included
	#endinput
#endif

#if !defined MAX_STRING
	#define MAX_STRING 				255
#endif

#if !defined MAX_QUERY_LEN
	#define MAX_QUERY_LEN 			1024
#endif

#if !defined isnull
	#define isnull(%0) 				((!(%0[0])) || (((%0[0]) == '\1') && (!(%0[1]))))
#endif

#define MAX_TABLE_NAME	 			32
#define MAX_WHERE_NAME      		32
#define MAX_WHERE_CLAUSE_NAME      	32
#define MAX_FIELD_LEN               64
#define MAX_VALUE_LEN               128
#define MAX_INSERT_LEN              256

#define QUERY_BUILDER_PRINT_ERRORS  (1)

#define QueryBuilder_PrintQuery() print(gQueryBuildString)

forward Float:QueryBuilder_GetFloat(field[]);

enum E_QUERY_BUILD_INFO {
    QUERY_BUILD_TABLE[MAX_TABLE_NAME],
	QUERY_BUILD_WHERE[MAX_WHERE_NAME],
	QUERY_BUILD_WHERE_CLAUSE[MAX_WHERE_CLAUSE_NAME],
	QUERY_BUILD_CONNECTIONHANDLE,
	bool:QUERY_BUILD_BUILDING,
}

new gQueryBuildString[MAX_QUERY_LEN];
new gQueryBuildInfo[E_QUERY_BUILD_INFO];

stock QueryBuilder_UpdateTable(table[], where[], whereclause[], connectionHandle = 1) {
	if(mysql_ping(connectionHandle) == -1) {
	    gQueryBuildInfo[QUERY_BUILD_BUILDING] = false;
	    #if QUERY_BUILDER_PRINT_ERRORS
	        printf("Query Builder Error: connection to mysql server is dead.");
		#endif
	    return 0;
	}
	if(isnull(table)) {
	    gQueryBuildInfo[QUERY_BUILD_BUILDING] = false;
	    #if QUERY_BUILDER_PRINT_ERRORS
	        printf("Query Builder Error: failed to update table, table name is null.");
		#endif
	    return 0;
	}
	if(isnull(where)) {
		gQueryBuildInfo[QUERY_BUILD_BUILDING] = false;
	    #if QUERY_BUILDER_PRINT_ERRORS
	        printf("Query Builder Error: failed to update table, \"where\" is null.");
		#endif
	    return 0;
	}
	if(gQueryBuildInfo[QUERY_BUILD_BUILDING]) gQueryBuildString[0] = '\0';
	format(gQueryBuildString, MAX_STRING, "UPDATE `%s` SET ", table);
	format(gQueryBuildInfo[QUERY_BUILD_WHERE], MAX_WHERE_NAME, where);
	format(gQueryBuildInfo[QUERY_BUILD_WHERE_CLAUSE], MAX_WHERE_CLAUSE_NAME, whereclause);
	gQueryBuildInfo[QUERY_BUILD_BUILDING] = true;
	gQueryBuildInfo[QUERY_BUILD_CONNECTIONHANDLE] = connectionHandle;
	return 1;
}

stock QueryBuilder_UpdateString(field[], value[]) {
    if(mysql_ping(gQueryBuildInfo[QUERY_BUILD_CONNECTIONHANDLE]) == -1) {
	    #if QUERY_BUILDER_PRINT_ERRORS
	        printf("Query Builder Error: connection to mysql server is dead.");
		#endif
	    return 0;
	}
	if(!gQueryBuildInfo[QUERY_BUILD_BUILDING]) {
	    #if QUERY_BUILDER_PRINT_ERRORS
	        printf("Query Builder Error: failed to update field \"%s\", query builder is not building.", field);
		#endif
	    return 0;
	}
	if(isnull(field)) {
	    #if QUERY_BUILDER_PRINT_ERRORS
	        printf("Query Builder Error: failed to update field, field name is null.");
		#endif
	    return 0;
	}
	new szQuery_String[MAX_VALUE_LEN+MAX_FIELD_LEN+4];
	format(szQuery_String, sizeof(szQuery_String), "`%s`='%s',", field, value);
	new query_len = strlen(gQueryBuildString), update_len = (strlen(field)+strlen(szQuery_String)), where_len = (strlen(gQueryBuildInfo[QUERY_BUILD_WHERE])+strlen(gQueryBuildInfo[QUERY_BUILD_WHERE_CLAUSE])+8);
	if((MAX_QUERY_LEN - (query_len+update_len)) < where_len) {
	    new where_string[MAX_WHERE_NAME+MAX_WHERE_CLAUSE_NAME+8], iLen = strlen(gQueryBuildString);
	    strdel(gQueryBuildString, iLen-1, iLen);
	    format(where_string, sizeof(where_string), QueryBuilder_IsNumeric(gQueryBuildInfo[QUERY_BUILD_WHERE_CLAUSE]) ? (" WHERE `%s`=%s"):(" WHERE `%s`='%s'"), gQueryBuildInfo[QUERY_BUILD_WHERE], gQueryBuildInfo[QUERY_BUILD_WHERE_CLAUSE]);
	    strcat(gQueryBuildString, where_string);
		if(!mysql_query(gQueryBuildString, .connectionHandle = gQueryBuildInfo[QUERY_BUILD_CONNECTIONHANDLE])) {
		    #if QUERY_BUILDER_PRINT_ERRORS
	        	printf("Query Builder Error: failed to send query \"%s\".", gQueryBuildString);
			#endif
		}
		gQueryBuildString[strlen(gQueryBuildInfo[QUERY_BUILD_TABLE])+12] = '\0';
	}
	strcat(gQueryBuildString, szQuery_String);
	return 1;
}

stock QueryBuilder_UpdateFloat(field[], Float:value) {
	new szQuery_String[65];
	format(szQuery_String, sizeof(szQuery_String), "%f", value);
	return QueryBuilder_UpdateString(field, szQuery_String);
}

stock QueryBuilder_UpdateInt(field[], value) {
	new szQuery_String[32];
	format(szQuery_String, sizeof(szQuery_String), "%i", value);
	return QueryBuilder_UpdateString(field, szQuery_String);
}

stock QueryBuilder_UpdateFinish() {
    if(mysql_ping(gQueryBuildInfo[QUERY_BUILD_CONNECTIONHANDLE]) == -1) {
	    #if QUERY_BUILDER_PRINT_ERRORS
	        printf("Query Builder Error: connection to mysql server is dead.");
		#endif
	    return 0;
	}
    if(!gQueryBuildInfo[QUERY_BUILD_BUILDING]) {
	    #if QUERY_BUILDER_PRINT_ERRORS
	        printf("Query Builder Error: failed to finish update, query builder is not building.");
		#endif
	    return 0;
	}
    new where_string[MAX_WHERE_NAME+MAX_WHERE_CLAUSE_NAME+8], iLen = strlen(gQueryBuildString);
    strdel(gQueryBuildString, iLen-1, iLen);
    format(where_string, sizeof(where_string), QueryBuilder_IsNumeric(gQueryBuildInfo[QUERY_BUILD_WHERE_CLAUSE]) ? (" WHERE `%s`=%s"):(" WHERE `%s`='%s'"), gQueryBuildInfo[QUERY_BUILD_WHERE], gQueryBuildInfo[QUERY_BUILD_WHERE_CLAUSE]);
    strcat(gQueryBuildString, where_string);
	if(!mysql_query(gQueryBuildString, .connectionHandle = gQueryBuildInfo[QUERY_BUILD_CONNECTIONHANDLE])) {
	    #if QUERY_BUILDER_PRINT_ERRORS
        	printf("Query Builder Error: failed to send query \"%s\".", gQueryBuildString);
		#endif
	}
	gQueryBuildInfo[QUERY_BUILD_BUILDING] = false;
	gQueryBuildString[0] = '\0';
	return 1;
}

stock QueryBuilder_MultiUpdate(format[], {Float,_}:...) {
    if(mysql_ping(gQueryBuildInfo[QUERY_BUILD_CONNECTIONHANDLE]) == -1) {
	    #if QUERY_BUILDER_PRINT_ERRORS
	        printf("Query Builder Error: connection to mysql server is dead.");
		#endif
	    return 0;
	}
	new pos = -1, fpos = -1, iLen = strlen(format), field[MAX_FIELD_LEN], value[MAX_VALUE_LEN];
	while(++pos < iLen) {
	    fpos = -1;
	    while(++fpos < MAX_WHERE_NAME) field[fpos] = getarg(1 + (pos * 2), fpos);
	    switch(format[pos]) {
	        case 'i', 'd': QueryBuilder_UpdateInt(field, getarg(2 + (pos * 2)));
	        case 'f': QueryBuilder_UpdateFloat(field, Float:getarg(2 + (pos * 2)));
	        case 's': {
	            fpos = -1;
				while((++fpos != MAX_VALUE_LEN)) value[fpos] = getarg(2 + (pos * 2), fpos);
				QueryBuilder_UpdateString(field, value);
 			}
	    }
	}
	return 1;
}

stock QueryBuilder_UpdateStringSingle(table[], where[], whereclause[], field[], value[], connectionHandle = 1) {
    if(mysql_ping(connectionHandle) == -1) {
	    #if QUERY_BUILDER_PRINT_ERRORS
	        printf("Query Builder Error: connection to mysql server is dead.");
		#endif
	    return 0;
	}
	if(gQueryBuildInfo[QUERY_BUILD_BUILDING]) {
	    #if QUERY_BUILDER_PRINT_ERRORS
	        printf("Query Builder Error: failed to single update, query builder is already building.");
		#endif
	    return 0;
	}
	if(isnull(table) || isnull(where) || isnull(whereclause) || isnull(field)) {
		#if QUERY_BUILDER_PRINT_ERRORS
	        printf("Query Builder Error: failed to single update, null value specified.");
		#endif
	    return 0;
	}
	QueryBuilder_UpdateTable(table, where, whereclause);
	QueryBuilder_UpdateString(field, value);
	QueryBuilder_UpdateFinish();
	return 1;
}

stock QueryBuilder_UpdateIntSingle(table[], where[], whereclause[], field[], value, connectionHandle = 1) {
	new szQuery_String[32];
	format(szQuery_String, sizeof(szQuery_String), "%i", value);
	return QueryBuilder_UpdateStringSingle(table, where, whereclause, field, szQuery_String, connectionHandle);
}

stock QueryBuilder_UpdateFloatSingle(table[], where[], whereclause[], field[], Float:value, connectionHandle = 1) {
	new szQuery_String[65];
	format(szQuery_String, sizeof(szQuery_String), "%f", value);
	return QueryBuilder_UpdateStringSingle(table, where, whereclause, field, szQuery_String, connectionHandle);
}

stock QueryBuilder_FetchRecord(table[], field[], record[], fetchstr[], limit = 0, connectionHandle = 1) {
    if(mysql_ping(connectionHandle) == -1) {
	    #if QUERY_BUILDER_PRINT_ERRORS
	        printf("Query Builder Error: connection to mysql server is dead.");
		#endif
	    return 0;
	}
	new szFetchQuery[128];
	if(QueryBuilder_IsNumeric(record)) format(szFetchQuery, sizeof(szFetchQuery), !limit? ("SELECT * FROM %s WHERE %s = %i"):("SELECT * FROM %s WHERE %s = %i LIMIT %i"), table, field, strval(record), limit);
	else format(szFetchQuery, sizeof(szFetchQuery), !limit? ("SELECT * FROM %s WHERE %s = '%s'"):("SELECT * FROM %s WHERE %s = '%s' LIMIT %i"), table, field, record, limit);
	if(!mysql_query(szFetchQuery, .connectionHandle = connectionHandle)) {
	    #if QUERY_BUILDER_PRINT_ERRORS
        	printf("Query Builder Error: failed to send query \"%s\".", szFetchQuery);
		#endif
	}
	gQueryBuildInfo[QUERY_BUILD_CONNECTIONHANDLE] = connectionHandle;
	mysql_store_result(connectionHandle);
	if(mysql_fetch_row_format(fetchstr, .connectionHandle = connectionHandle)) return 1;
	return 0;
}

stock QueryBuilder_GetInt(field[]) return strval(QueryBuilder_GetStr(field));

stock Float:QueryBuilder_GetFloat(field[]) return floatstr(QueryBuilder_GetStr(field));

stock QueryBuilder_GetStr(field[]) {
	new szSQLResult[MAX_VALUE_LEN];
    if(mysql_ping(gQueryBuildInfo[QUERY_BUILD_CONNECTIONHANDLE]) == -1) {
	    #if QUERY_BUILDER_PRINT_ERRORS
	        printf("Query Builder Error: connection to mysql server is dead.");
		#endif
	    return szSQLResult;
	}
	mysql_fetch_field_row(szSQLResult, field, .connectionHandle = gQueryBuildInfo[QUERY_BUILD_CONNECTIONHANDLE]);
	if(!strcmp(szSQLResult, "NULL", true) || !strcmp(szSQLResult, "(NULL)", true)) szSQLResult[0] = '\0';
	return szSQLResult;
}

stock QueryBuilder_GetStrEx(field[], dest[], size = sizeof dest, bool:pack = false) {
    new szSQLResult[MAX_VALUE_LEN];
    if(mysql_ping(gQueryBuildInfo[QUERY_BUILD_CONNECTIONHANDLE]) == -1) {
	    #if QUERY_BUILDER_PRINT_ERRORS
	        printf("Query Builder Error: connection to mysql server is dead.");
		#endif
	    return;
	}
	mysql_fetch_field_row(szSQLResult, field, .connectionHandle = gQueryBuildInfo[QUERY_BUILD_CONNECTIONHANDLE]);
	if(!strcmp(szSQLResult, "NULL", true) || !strcmp(szSQLResult, "(NULL)", true)) szSQLResult[0] = '\0';
	if(pack) strpack(dest, szSQLResult, size);
	else strmid(dest, szSQLResult, 0, size, size);
	return;
}

stock QueryBuilder_GetRowCount(table[], connectionHandle = 1) {
	if(mysql_ping(connectionHandle) == -1) {
	    #if QUERY_BUILDER_PRINT_ERRORS
	        printf("Query Builder Error: connection to mysql server is dead.");
		#endif
	    return 0;
	}
	if(isnull(table)) {
	    #if QUERY_BUILDER_PRINT_ERRORS
	        printf("Query Builder Error: could not get row count, table specified is null.");
		#endif
	    return 0;
	}
	new szMySQLQuery[24+MAX_FIELD_LEN];
	format(szMySQLQuery, sizeof(szMySQLQuery), "SELECT COUNT(*) FROM %s", table);
	if(!mysql_query(szMySQLQuery, .connectionHandle = connectionHandle)) {
	    #if QUERY_BUILDER_PRINT_ERRORS
        	printf("Query Builder Error: failed to send query: \"%s\".", szMySQLQuery);
		#endif
	}
	mysql_store_result(connectionHandle);
	new rowcount = mysql_fetch_int(connectionHandle);
	mysql_free_result(connectionHandle);
	return rowcount;
}

stock QueryBuilder_MultiGet(getformat[], {Float,_}:...) {
    if(mysql_ping(gQueryBuildInfo[QUERY_BUILD_CONNECTIONHANDLE]) == -1) {
	    #if QUERY_BUILDER_PRINT_ERRORS
	        printf("Query Builder Error: connection to mysql server is dead.");
		#endif
	    return 0;
	}
	new pos = -1, fpos = -1, iLen = strlen(getformat), field[MAX_FIELD_LEN], value[MAX_VALUE_LEN];
	while(++pos < iLen) {
	    fpos = -1;
	    while(++fpos < MAX_WHERE_NAME) field[fpos] = getarg(1 + (pos * 2), fpos);
	    switch(getformat[pos]) {
	        case 'i', 'd': setarg(2 + (pos * 2), 0, QueryBuilder_GetInt(field));
	        case 'f': setarg(2 + (pos * 2), 0, _:Float:QueryBuilder_GetFloat(field));
	        case 's': {
	            fpos = -1;
	            QueryBuilder_GetStrEx(field, value);
	            new iStrLen = strlen(value);
				while((++fpos != iStrLen)) setarg(2 + (pos * 2), fpos, value[fpos]);
 			}
	    }
	}
	return 1;
}

stock QueryBuilder_Insert(table[], insformat[], {Float,_}:...) {
	new szInsertQuery[MAX_INSERT_LEN], insert_pos, value_pos, pos = -1, fpos = -1, iInsLen, iLen = strlen(insformat), field[MAX_FIELD_LEN], value[MAX_VALUE_LEN], insert[MAX_VALUE_LEN];
	format(szInsertQuery, sizeof(szInsertQuery), "INSERT INTO `%s`(", table);
	insert_pos = strlen(szInsertQuery);
	strcat(szInsertQuery, ") VALUES (");
	value_pos = strlen(szInsertQuery);
	while(++pos < iLen) {
	    fpos = -1;
	    while(++fpos < MAX_WHERE_NAME) field[fpos] = getarg(2 + (pos * 2), fpos);
	    format(insert, sizeof(insert), (pos+1 == iLen) ? ("`%s`"):("`%s`,"), field);
	    strins(szInsertQuery, insert, insert_pos);
	    iInsLen = strlen(insert);
	    insert_pos += iInsLen;
	    value_pos += iInsLen;
	    switch(insformat[pos]) {
	        case 'i', 'd': {
	            format(insert, sizeof(insert), (pos+1 == iLen) ? ("%i"):("%i,"), getarg(3 + (pos * 2)));
	            strins(szInsertQuery, insert, value_pos);
	    		value_pos += strlen(insert);
	        } case 'f': {
	        	format(insert, sizeof(insert), (pos+1 == iLen) ? ("%f"):("%f,"), Float:getarg(3 + (pos * 2)));
	            strins(szInsertQuery, insert, value_pos);
	            value_pos += strlen(insert);
	        } case 's': {
	            fpos = -1;
				while((++fpos != MAX_VALUE_LEN)) value[fpos] = getarg(3 + (pos * 2), fpos);
				format(insert, sizeof(insert), (pos+1 == iLen) ? ("'%s'"):("'%s',"), value);
	            strins(szInsertQuery, insert, value_pos);
	            value_pos += strlen(insert);
 			}
	    }
	}
	strcat(szInsertQuery, ")");
	mysql_query(szInsertQuery);
}

stock QueryBuilder_IsNumeric(string[]) {
    for(new i=0; i < strlen(string); i++) if(string[i] > '9' || string[i] < '0') return 0;
    return 1;
}
