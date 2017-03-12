create or replace package test_expectations is

  --%suite(Testing expectation)
  --%suitepath(ut_plsql.core)

  --%beforeall
  procedure create_department_object_type;

  --%afterall
  procedure drop_department_object_type;

  --%test
  procedure test_to_equal;

end test_expectations;
/
create or replace package body test_expectations is

  procedure test_to_equal is
    l_date            date := sysdate;
    l_refcur_actual   sys_refcursor;
    l_refcur_expected sys_refcursor;
  
    l_actual_ts   timestamp(9) := to_timestamp('2016-09-06 22:36:11.123456789', 'yyyy-mm-dd hh24:mi:ss.ff');
    l_expected_ts timestamp(9) := to_timestamp('2016-09-06 22:36:11.123456789', 'yyyy-mm-dd hh24:mi:ss.ff');
  
    l_actual_ts_ltz   timestamp(9) with local time zone := to_timestamp('2016-09-06 22:36:11.123456789', 'yyyy-mm-dd hh24:mi:ss.ff');
    l_expected_ts_ltz timestamp(9) with local time zone := to_timestamp('2016-09-06 22:36:11.123456789', 'yyyy-mm-dd hh24:mi:ss.ff');
  
    l_actual_ts_tz   timestamp(9) with local time zone := to_timestamp('2016-09-06 22:36:11.123456789', 'yyyy-mm-dd hh24:mi:ss.ff');
    l_expected_ts_tz timestamp(9) with local time zone := to_timestamp('2016-09-06 22:36:11.123456789', 'yyyy-mm-dd hh24:mi:ss.ff');
    
    l_actual_int_d2s interval day to second := '2 01:00:00';
    l_expected_int_d2s interval day to second := '2 01:00:00';
    
    l_actual_int_y2m interval year to month := '1-1';
    l_expected_int_y2m interval year to month := '1-1';
  
    l_null_bool    boolean;
    l_null_blob    blob;
    l_null_clob    clob;
    l_null_date    date;
    l_null_number  number;
    l_null_ts      timestamp;
    l_null_ts_ltz  timestamp with local time zone;
    l_null_ts_tz   timestamp with time zone;
    l_null_varchar varchar2(4000);
    l_null_anydata anydata;
  begin
  
    -- positive cases
    ut.expect(12345, 'Check number equality').to_equal(12345);
  
    ut.expect('Abc', 'Varchar equality').to_equal('Abc');
  
    ut.expect(l_date, 'Date equality').to_equal(l_date);
  
    open l_refcur_actual for
      select * from user_objects where rownum <= 4;
    open l_refcur_expected for
      select * from user_objects where rownum <= 4;
    ut.expect(l_refcur_actual, 'Cursor equality').to_equal(l_refcur_expected);
  
    ut.expect(to_blob('Abc'), 'Blob equality').to_equal(to_blob('Abc'));
  
    ut.expect(false, 'Boolean equality').to_equal(false);
    ut.expect(true, 'Boolean equality').to_equal(true);
  
    ut.expect(to_clob('Abc'), 'Clob equality').to_equal(to_clob('Abc'));
  
    ut.expect(l_actual_ts, 'Timestamp equality').to_equal(l_expected_ts);
    ut.expect(l_actual_ts_ltz, 'Timestamp equality').to_equal(l_expected_ts_ltz);
    ut.expect(l_actual_ts_tz, 'Timestamp equality').to_equal(l_expected_ts_tz);
    ut.expect(l_actual_int_d2s, 'Interval day to second  equality').to_equal(l_expected_int_d2s);
    ut.expect(l_actual_int_y2m, 'Interval year to month equality').to_equal(l_expected_int_y2m);
  
    execute immediate 'begin ut.expect(anydata.convertobject(department$(''hr'')), ''Anydata equality'').to_equal(anydata.convertobject(department$(''hr''))); end;';
  
    ut.expect(l_null_bool).to_equal(l_null_bool);
    ut.expect(l_null_blob).to_equal(l_null_blob);
    ut.expect(l_null_clob).to_equal(l_null_clob);
    ut.expect(l_null_date).to_equal(l_null_date);
    ut.expect(l_null_number).to_equal(l_null_number);
    ut.expect(l_null_ts).to_equal(l_null_ts);
    ut.expect(l_null_ts_ltz).to_equal(l_null_ts_ltz);
    ut.expect(l_null_ts_tz).to_equal(l_null_ts_tz);
    ut.expect(l_null_varchar).to_equal(l_null_varchar);
    ut.expect(l_null_anydata).to_equal(l_null_anydata);

    execute immediate 'declare
  l_expected department$;
  l_actual   department$;
begin ut.expect( anydata.convertObject(l_actual) ).to_equal( anydata.convertObject(l_expected) ); end;';
  
    execute immediate 'declare
  l_expected department$ := department$(:hr);
  l_actual   department$ := department$(:hr);
begin ut.expect( anydata.convertObject(l_actual) ).to_equal( anydata.convertObject(l_expected) ); end;'
      using 'hr';
      
    --negative cases
    --different types
    ut.expect(to_blob('ABC')).not_to(equal(to_clob('ABC')));
    ut.expect(to_clob('ABC')).not_to(equal('ABC'));
    ut.expect(l_actual_ts_ltz).not_to(equal(l_expected_ts));
    ut.expect(l_actual_ts_ltz).not_to(equal(l_expected_ts_tz));
    ut.expect(l_actual_int_d2s).not_to(equal('1'));
    ut.expect(l_actual_int_d2s).not_to(equal(l_expected_int_y2m));
    ut.expect(l_actual_int_y2m).not_to(equal(l_expected_int_d2s));   
    
    --different values
    ut.expect(12345).not_to(equal(0));
    ut.expect(sysdate).not_to(equal(sysdate+1));
    
    l_actual_ts := systimestamp;
    l_expected_ts := systimestamp;
    ut.expect(l_actual_ts).not_to(equal(l_expected_ts));
    
    l_actual_ts_ltz := systimestamp;
    l_expected_ts_ltz := systimestamp;
    ut.expect(l_actual_ts_ltz).not_to(equal(l_expected_ts_ltz));
  
    l_actual_ts_tz := systimestamp;
    l_expected_ts_tz := systimestamp;
    ut.expect(l_actual_ts_tz).not_to(equal(l_expected_ts_tz));
    
    --compare to null
    ut.expect(l_actual_ts_tz).not_to(equal(l_expected_ts_tz));
/*
@@lib/RunTest.sql "ut_expectations/common/ut.expect.to_be_between.scalar.common.sql 'date' 'NULL' 'sysdate-1' 'sysdate' 'ut_utils.tr_failure'"
@@lib/RunTest.sql "ut_expectations/common/ut.expect.to_be_between.scalar.common.sql 'number' 'NULL' '0' '1' 'ut_utils.tr_failure'"
@@lib/RunTest.sql "ut_expectations/common/ut.expect.to_be_between.scalar.common.sql 'timestamp' 'NULL' 'systimestamp-1' 'systimestamp' 'ut_utils.tr_failure'"
@@lib/RunTest.sql "ut_expectations/common/ut.expect.to_be_between.scalar.common.sql 'timestamp with local time zone' 'NULL' 'systimestamp-1' 'systimestamp' 'ut_utils.tr_failure'"
@@lib/RunTest.sql "ut_expectations/common/ut.expect.to_be_between.scalar.common.sql 'timestamp with time zone' 'NULL' 'systimestamp-1' 'systimestamp' 'ut_utils.tr_failure'"
*/
  
  end test_to_equal;

  procedure create_department_object_type is
    pragma autonomous_transaction;
  begin
    execute immediate 'create or replace type department$ as object(dept_name varchar2(30))';
  end;

  procedure drop_department_object_type is
    pragma autonomous_transaction;
  begin
    execute immediate 'drop type department$';
  end;

end test_expectations;
/
