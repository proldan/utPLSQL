create or replace package test_expectations is

  --%suite(Expectations)
  --%suitepath(ut_plsql.core)

  --%beforeall
  procedure create_department_object_type;

  --%afterall
  procedure drop_department_object_type;

  --%test
  procedure test_to_equal;
  
  --%test
  procedure test_to_equal_cursors;
  
  --%test(Test equality check on different cursors)
  procedure test_equal_diff_cursors;
  
  --%test(Test equality check on same cursors)
  procedure test_equal_same_cursors;

end test_expectations;
/
create or replace package body test_expectations is

  procedure restore_asserts(a_assert_results ut_assert_results) is
  begin
    ut_assert_processor.clear_asserts;
  
    if a_assert_results is not null then
      for i in 1 .. a_assert_results.count loop
        ut_assert_processor.add_assert_result(a_assert_results(i));
      end loop;
    end if;
  end;

  procedure test_to_equal is
    l_refcur_actual   sys_refcursor;
    l_refcur_expected sys_refcursor;
    l_null_anydata anydata;
  
    procedure check_failure_for_diff_types(a_type_actual varchar2, a_type_expected varchar2, a_value_actual varchar2, a_values_expected varchar2, a_predefine varchar2 default null) is
      l_assert_results ut_assert_results;
      l_result         integer;
      l_statement      varchar2(32767);
    begin
      l_assert_results := ut_assert_processor.get_asserts_results;
      l_statement := 'declare '||a_predefine||'
  l_actual   ' || a_type_actual || ' := ' || a_value_actual || ';
  l_expected ' || a_type_expected || ' := ' || a_values_expected || ';
begin ut.expect(l_actual).to_equal(l_expected); end;';
      execute immediate l_statement;
      l_result := ut_assert_processor.get_aggregate_asserts_result();
      restore_asserts(l_assert_results);
      ut.expect(l_result, 'check_failure_for_diff_types:'||chr(10)||l_statement).to_equal(ut_utils.tr_failure);
    end check_failure_for_diff_types;
  
    procedure exec_scalar_common(a_type varchar2, a_value_actual varchar2, a_values_expected varchar2, a_results integer) is
      l_assert_results ut_assert_results;
      l_result         integer;
      l_statement      varchar2(32767);
    begin
      l_assert_results := ut_assert_processor.get_asserts_results;

      l_statement := 'declare
  l_actual   ' || a_type || ' := ' || a_value_actual || ';
  l_expected ' || a_type || ' := ' || a_values_expected || ';
begin  ut.expect(l_actual).to_equal(l_expected); end;';
      execute immediate l_statement;
      l_result := ut_assert_processor.get_aggregate_asserts_result();
      restore_asserts(l_assert_results);
      
      ut.expect(l_result,'exec_scalar_common:'||chr(10)||l_statement).to_equal(a_results);
    end exec_scalar_common;
    
    procedure exec_scalar_common_with_nulls(a_type varchar2, a_value_actual varchar2, a_values_expected varchar2, a_results integer, a_null_are_equal varchar2,a_predefine varchar2 default null) is
      l_assert_results ut_assert_results;
      l_result         integer;
      l_statement      varchar2(32767);
    begin
      l_assert_results := ut_assert_processor.get_asserts_results;
      
      l_statement :=  'declare '||a_predefine||'
      l_actual   ' || a_type || ' := ' || a_value_actual || ';
      l_expected ' || a_type || ' := ' || a_values_expected || ';
      l_nulls_are_equal boolean := ' || a_null_are_equal || ';
    begin  ut.expect(l_actual).to_equal(l_expected, l_nulls_are_equal); end;';
      execute immediate l_statement;
      l_result := ut_assert_processor.get_aggregate_asserts_result();
      restore_asserts(l_assert_results);
      
      ut.expect(l_result, 'exec_scalar_common_with_nulls:'||chr(10)||l_statement).to_equal(a_results);
    end exec_scalar_common_with_nulls;
    
    procedure exec_scalar_null_value_text(a_type varchar2, a_value_actual varchar2, a_values_expected varchar2, a_method varchar2) is
      l_assert_results ut_assert_results;
      l_result_text    varchar2(32767);
      l_statement      varchar2(4000);
      l_statement2     varchar2(4000);
    begin
      l_assert_results := ut_assert_processor.get_asserts_results;
      
      l_statement := 'declare
      l_actual   ' || a_type || ' := ' || a_value_actual || ';
      l_expected ' || a_type || ' := ' || a_values_expected || ';
    begin  ut.expect(l_actual).to_equal(l_expected); end;';
      l_statement2 := 'declare l_res ut_assert_result := :a_assert; begin :l_res := l_res.'||a_method||'; end;';
      
      execute immediate l_statement;
      execute immediate l_statement2 using in ut_assert_processor.get_asserts_results()(1), out l_result_text;
      
      restore_asserts(l_assert_results);
      
      ut.expect(l_result_text
               ,'exec_scalar_null_value_text:'||chr(10)||l_statement||chr(10)||l_statement2).to_equal('NULL');
    end exec_scalar_null_value_text;
    
    procedure exec_scalar_value_text(a_type varchar2, a_value_actual varchar2, a_values_expected varchar2) is
      l_assert_results ut_assert_results;
      l_result_text    varchar2(32767);
      l_test_message   varchar2(30) := 'A test message';
      l_statement      varchar2(4000);
    begin
      l_assert_results := ut_assert_processor.get_asserts_results;
      
      l_statement :='declare
      l_actual   ' || a_type || ' := ' || a_value_actual || ';
      l_expected ' || a_type || ' := ' || a_values_expected || ';
      begin  ut.expect(l_actual, :test_message).to_equal(l_expected); end;';
      execute immediate l_statement using l_test_message;
      l_result_text := ut_assert_processor.get_asserts_results()(1).message;
      restore_asserts(l_assert_results);
      
      ut.expect(l_result_text
               ,'exec_scalar_value_text:'||chr(10)||l_statement).to_be_like('%'||l_test_message||'%');
    end exec_scalar_value_text;
    
  begin
   
    --different types
    check_failure_for_diff_types('blob', 'clob', 'to_blob(''ABC'')', '''ABC''');
    check_failure_for_diff_types('clob', 'varchar2(4000)', '''Abc''', '''Abc''');
    check_failure_for_diff_types('date', 'timestamp', 'sysdate', 'sysdate');
    check_failure_for_diff_types('timestamp with local time zone', 'timestamp', 'sysdate', 'sysdate');
    check_failure_for_diff_types('timestamp with local time zone', 'timestamp with time zone', 'sysdate', 'sysdate');
    check_failure_for_diff_types('number', 'varchar2(4000)', '1', '''1''');
    check_failure_for_diff_types('interval day to second', 'interval year to month', '''2 01:00:00''', '''1-1''');
    check_failure_for_diff_types('anydata','anydata', 'anydata.convertObject(cast(null as department$))','anydata.convertObject(cast(null as department1$))');
  
    --different values
    exec_scalar_common('blob', 'to_blob(''abc'')', 'to_blob(''abd'')', ut_utils.tr_failure);
    exec_scalar_common('boolean', 'true', 'false', ut_utils.tr_failure);
    exec_scalar_common('clob', '''Abc''', '''abc''', ut_utils.tr_failure);
    exec_scalar_common('date', 'sysdate', 'sysdate-1', ut_utils.tr_failure);
    exec_scalar_common('number', '0.1', '0.3', ut_utils.tr_failure);
    exec_scalar_common('timestamp', 'systimestamp', 'systimestamp', ut_utils.tr_failure);
    exec_scalar_common('timestamp with local time zone', 'systimestamp', 'systimestamp', ut_utils.tr_failure);
    exec_scalar_common('timestamp with time zone', 'systimestamp', 'systimestamp', ut_utils.tr_failure);
    exec_scalar_common('varchar2(4000)', '''Abc''', '''abc''', ut_utils.tr_failure);
    exec_scalar_common('interval day to second', '''2 01:00:00''', '''2 01:00:01''', ut_utils.tr_failure);
    exec_scalar_common('interval year to month', '''1-1''', '''1-2''', ut_utils.tr_failure);
    exec_scalar_common('anydata', 'anydata.convertObject(department$(''hr''))', 'anydata.convertObject(department$(''it''))', ut_utils.tr_failure);

    -- actuals are null    
    exec_scalar_common('blob', 'NULL', 'to_blob(''abc'')', ut_utils.tr_failure);
    exec_scalar_common('boolean', 'NULL', 'true', ut_utils.tr_failure);
    exec_scalar_common('clob', 'NULL', '''abc''', ut_utils.tr_failure);
    exec_scalar_common('date', 'NULL', 'sysdate', ut_utils.tr_failure);
    exec_scalar_common('number', 'NULL', '1', ut_utils.tr_failure);
    exec_scalar_common('timestamp', 'NULL', 'systimestamp', ut_utils.tr_failure);
    exec_scalar_common('timestamp with local time zone', 'NULL', 'systimestamp', ut_utils.tr_failure);
    exec_scalar_common('timestamp with time zone', 'NULL', 'systimestamp', ut_utils.tr_failure);
    exec_scalar_common('varchar2(4000)', 'NULL', '''abc''', ut_utils.tr_failure);
    exec_scalar_common('interval day to second', 'NULL', '''2 01:00:00''', ut_utils.tr_failure);
    exec_scalar_common('interval year to month', 'NULL', '''1-1''', ut_utils.tr_failure);
    exec_scalar_common('anydata', 'anydata.convertObject(cast (null as department$))', 'anydata.convertObject(department$(''hr''))', ut_utils.tr_failure);

    --both are null without null equality parameter
    exec_scalar_common_with_nulls('blob', 'NULL', 'NULL', ut_utils.tr_failure, 'false');
    exec_scalar_common_with_nulls('boolean', 'NULL', 'NULL', ut_utils.tr_failure, 'false');
    exec_scalar_common_with_nulls('clob', 'NULL', 'NULL', ut_utils.tr_failure, 'false');
    exec_scalar_common_with_nulls('date', 'NULL', 'NULL', ut_utils.tr_failure, 'false');
    exec_scalar_common_with_nulls('number', 'NULL', 'NULL', ut_utils.tr_failure, 'false');
    exec_scalar_common_with_nulls('timestamp', 'NULL', 'NULL', ut_utils.tr_failure, 'false');
    exec_scalar_common_with_nulls('timestamp with local time zone', 'NULL', 'NULL', ut_utils.tr_failure, 'false');
    exec_scalar_common_with_nulls('timestamp with time zone', 'NULL', 'NULL', ut_utils.tr_failure, 'false');
    exec_scalar_common_with_nulls('varchar2(4000)', 'NULL', 'NULL', ut_utils.tr_failure, 'false');
    exec_scalar_common_with_nulls('interval day to second', 'NULL', 'NULL', ut_utils.tr_failure, 'false');
    exec_scalar_common_with_nulls('interval year to month', 'NULL', 'NULL', ut_utils.tr_failure, 'false');
    exec_scalar_common_with_nulls('anydata', 'anydata.convertObject(cast(null as department$))', 'anydata.convertObject(cast(null as department$))', ut_utils.tr_failure, 'false');

    -- both null without null euqality
    ut_assert_processor.nulls_Are_equal(false);
    exec_scalar_common('blob', 'NULL', 'NULL', ut_utils.tr_failure);
    exec_scalar_common('boolean', 'NULL', 'NULL', ut_utils.tr_failure);
    exec_scalar_common('clob', 'NULL', 'NULL', ut_utils.tr_failure);
    exec_scalar_common('date', 'NULL', 'NULL', ut_utils.tr_failure);
    exec_scalar_common('number', 'NULL', 'NULL', ut_utils.tr_failure);
    exec_scalar_common('timestamp', 'NULL', 'NULL', ut_utils.tr_failure);
    exec_scalar_common('timestamp with local time zone', 'NULL', 'NULL', ut_utils.tr_failure);
    exec_scalar_common('timestamp with time zone', 'NULL', 'NULL', ut_utils.tr_failure);
    exec_scalar_common('varchar2(4000)', 'NULL', 'NULL', ut_utils.tr_failure);
    exec_scalar_common('interval day to second', 'NULL', 'NULL', ut_utils.tr_failure);
    exec_scalar_common('interval year to month', 'NULL', 'NULL', ut_utils.tr_failure);
    exec_scalar_common('anydata', 'anydata.convertObject(cast(null as department$))', 'anydata.convertObject(cast(null as department$))', ut_utils.tr_failure);
    ut_assert_processor.nulls_Are_equal(ut_assert_processor.gc_default_nulls_are_equal);

    --expected is null
    exec_scalar_common('blob', 'to_blob(''abc'')', 'NULL', ut_utils.tr_failure);
    exec_scalar_common('boolean', 'true', 'NULL', ut_utils.tr_failure);
    exec_scalar_common('clob', '''abc''', 'NULL', ut_utils.tr_failure);
    exec_scalar_common('date', 'sysdate', 'NULL', ut_utils.tr_failure);
    exec_scalar_common('number', '1234', 'NULL', ut_utils.tr_failure);
    exec_scalar_common('timestamp', 'systimestamp', 'NULL', ut_utils.tr_failure);
    exec_scalar_common('timestamp with local time zone', 'systimestamp', 'NULL', ut_utils.tr_failure);
    exec_scalar_common('timestamp with time zone', 'systimestamp', 'NULL', ut_utils.tr_failure);
    exec_scalar_common('varchar2(4000)', '''abc''', 'NULL', ut_utils.tr_failure);
    exec_scalar_common('interval day to second', '''2 01:00:00''', 'NULL', ut_utils.tr_failure);
    exec_scalar_common('interval year to month', '''1-1''', 'NULL', ut_utils.tr_failure);
    exec_scalar_common('anydata', 'anydata.convertObject(department$(''hr''))', 'anydata.convertObject(cast(null as department$))', ut_utils.tr_failure);

    --equal values
    exec_scalar_common('blob', 'to_blob(''Abc'')', 'to_blob(''abc'')', ut_utils.tr_success);
    exec_scalar_common('boolean', 'false', 'false', ut_utils.tr_success);
    exec_scalar_common('clob', '''Abc''', '''Abc''', ut_utils.tr_success);
    exec_scalar_common('date', 'sysdate', 'sysdate', ut_utils.tr_success);
    exec_scalar_common('number', '12345', '12345', ut_utils.tr_success);
    exec_scalar_common('timestamp(9)', 'to_Timestamp(''2016 123456789'',''yyyy ff'')', 'to_Timestamp(''2016 123456789'',''yyyy ff'')', ut_utils.tr_success);
    exec_scalar_common('timestamp(9) with local time zone', 'to_Timestamp(''2016 123456789'',''yyyy ff'')', 'to_Timestamp(''2016 123456789'',''yyyy ff'')',ut_utils.tr_success);
    exec_scalar_common('timestamp(9) with time zone', 'to_Timestamp(''2016 123456789'',''yyyy ff'')', 'to_Timestamp(''2016 123456789'',''yyyy ff'')', ut_utils.tr_success);
    exec_scalar_common('varchar2(4000)', '''Abc''', '''Abc''', ut_utils.tr_success);
    exec_scalar_common('interval day to second', '''2 01:00:00''', '''2 01:00:00''', ut_utils.tr_success);
    exec_scalar_common('interval year to month', '''1-1''', '''1-1''', ut_utils.tr_success);
    exec_scalar_common('anydata', 'anydata.convertObject(department$(''hr''))', 'anydata.convertObject(department$(''hr''))', ut_utils.tr_success);

    --both are equal with nulls equality (session)
    exec_scalar_common('blob', 'NULL', 'NULL', ut_utils.tr_success);
    exec_scalar_common('boolean', 'NULL', 'NULL', ut_utils.tr_success);
    exec_scalar_common('clob', 'NULL', 'NULL', ut_utils.tr_success);
    exec_scalar_common('date', 'NULL', 'NULL', ut_utils.tr_success);
    exec_scalar_common('number', 'NULL', 'NULL', ut_utils.tr_success);
    exec_scalar_common('timestamp', 'NULL', 'NULL', ut_utils.tr_success);
    exec_scalar_common('timestamp with local time zone', 'NULL', 'NULL', ut_utils.tr_success);
    exec_scalar_common('timestamp with time zone', 'NULL', 'NULL', ut_utils.tr_success);
    exec_scalar_common('varchar2(4000)', 'NULL', 'NULL', ut_utils.tr_success);
    exec_scalar_common('interval day to second', 'NULL', 'NULL', ut_utils.tr_success);
    exec_scalar_common('interval year to month', 'NULL', 'NULL', ut_utils.tr_success);
    exec_scalar_common('anydata', 'anydata.convertObject(cast(null as department$))', 'anydata.convertObject(cast(null as department$))', ut_utils.tr_success);

    --buth are equal with nulls equality (param)
    exec_scalar_common_with_nulls('blob', 'NULL', 'NULL', ut_utils.tr_success, 'true');
    exec_scalar_common_with_nulls('boolean', 'NULL', 'NULL', ut_utils.tr_success, 'true');
    exec_scalar_common_with_nulls('clob', 'NULL', 'NULL', ut_utils.tr_success, 'true');
    exec_scalar_common_with_nulls('date', 'NULL', 'NULL', ut_utils.tr_success, 'true');
    exec_scalar_common_with_nulls('number', 'NULL', 'NULL', ut_utils.tr_success, 'true');
    exec_scalar_common_with_nulls('timestamp', 'NULL', 'NULL', ut_utils.tr_success, 'true');
    exec_scalar_common_with_nulls('timestamp with local time zone', 'NULL', 'NULL', ut_utils.tr_success, 'true');
    exec_scalar_common_with_nulls('timestamp with time zone', 'NULL', 'NULL', ut_utils.tr_success, 'true');
    exec_scalar_common_with_nulls('varchar2(4000)', 'NULL', 'NULL', ut_utils.tr_success, 'true');
    exec_scalar_common_with_nulls('interval day to second', 'NULL', 'NULL', ut_utils.tr_success, 'true');
    exec_scalar_common_with_nulls('interval year to month', 'NULL', 'NULL', ut_utils.tr_success, 'true');
    exec_scalar_common_with_nulls('anydata', 'anydata.convertObject(cast(null as department$))', 'anydata.convertObject(cast(null as department$))', ut_utils.tr_success, 'true');
    
    --PutsNullIntoStringValueWhenActualIsNull
    exec_scalar_null_value_text('blob', 'NULL', 'to_blob(''abc'')', 'actual_value_string');
    exec_scalar_null_value_text('boolean', 'NULL', 'false', 'actual_value_string');
    exec_scalar_null_value_text('clob', 'NULL', '''abc''', 'actual_value_string');
    exec_scalar_null_value_text('date', 'NULL', 'sysdate', 'actual_value_string');
    exec_scalar_null_value_text('number', 'NULL', '1234', 'actual_value_string');
    exec_scalar_null_value_text('timestamp', 'NULL', 'systimestamp', 'actual_value_string');
    exec_scalar_null_value_text('timestamp with local time zone', 'NULL', 'systimestamp', 'actual_value_string');
    exec_scalar_null_value_text('timestamp with time zone', 'NULL', 'systimestamp', 'actual_value_string');
    exec_scalar_null_value_text('varchar2(4000)', 'NULL', '''abc''', 'actual_value_string');
    exec_scalar_null_value_text('interval day to second', 'NULL', '''2 01:00:00''', 'actual_value_string');
    exec_scalar_null_value_text('interval year to month', 'NULL', '''1-1''', 'actual_value_string');
    exec_scalar_null_value_text('anydata', 'anydata.convertObject(cast(null as department$))', 'anydata.convertObject(department$(''hr''))', 'actual_value_string');

    --PutsNullIntoStringValueWhenExpectedIsNull
    exec_scalar_null_value_text('blob', 'to_blob(''abc'')', 'NULL', 'expected_value_string');
    exec_scalar_null_value_text('boolean', 'false', 'NULL', 'expected_value_string');
    exec_scalar_null_value_text('clob', '''abc''', 'NULL', 'expected_value_string');
    exec_scalar_null_value_text('date', 'sysdate', 'NULL', 'expected_value_string');
    exec_scalar_null_value_text('number', '1234', 'NULL', 'expected_value_string');
    exec_scalar_null_value_text('timestamp', 'systimestamp', 'NULL', 'expected_value_string');
    exec_scalar_null_value_text('timestamp with local time zone', 'systimestamp', 'NULL', 'expected_value_string');
    exec_scalar_null_value_text('timestamp with time zone', 'systimestamp', 'NULL', 'expected_value_string');
    exec_scalar_null_value_text('varchar2(4000)', '''abc''', 'NULL', 'expected_value_string');
    exec_scalar_null_value_text('interval day to second', '''2 01:00:00''', 'NULL', 'expected_value_string');
    exec_scalar_null_value_text('interval year to month', '''1-1''', 'NULL', 'expected_value_string');    
    exec_scalar_null_value_text('anydata', 'anydata.convertObject(department$(''hr''))', 'anydata.convertObject(cast(null as department$))', 'expected_value_string');    

    --GivesTheProvidedTextAsMessage
    exec_scalar_value_text('blob', 'to_blob(''abc'')', 'to_blob(''abc'')');
    exec_scalar_value_text('boolean', 'true', 'true');
    exec_scalar_value_text('clob', '''abc''', '''abc''');
    exec_scalar_value_text('date', 'sysdate', 'sysdate');
    exec_scalar_value_text('number', '1', '1');
    exec_scalar_value_text('timestamp', 'sysdate', 'sysdate');
    exec_scalar_value_text('timestamp with local time zone', 'sysdate', 'sysdate');
    exec_scalar_value_text('timestamp with time zone', 'sysdate', 'sysdate');
    exec_scalar_value_text('varchar2(100)', '''abc''', '''abc''');
    exec_scalar_value_text('interval day to second', '''2 01:00:00''', '''2 01:00:00''');
    exec_scalar_value_text('interval year to month', '''1-1''', '''1-1''');
    exec_scalar_value_text('anydata', 'anydata.convertObject(department$(''hr''))', 'anydata.convertObject(department$(''hr''))');
  
 
  
  end test_to_equal;
  
  procedure test_to_equal_cursors is
    l_actual   SYS_REFCURSOR;
    l_expected SYS_REFCURSOR;
    l_result   ut_assert_result;
    l_expected_string  varchar2(32767);
    l_actual_string    varchar2(32767);
  begin

    open l_actual for select level lvl from dual connect by level <4;
    open l_expected for select level lvl from dual connect by level <3;
    ut.expect(l_actual).to_equal(l_expected);

    l_result := treat( ut_assert_processor.get_asserts_results()(1) as ut_assert_result );
    l_expected_string := l_result.expected_value_string;
    l_actual_string := l_result.actual_value_string;
    
    ut.expect(l_expected_string).not_to(equal('NULL'));
    ut.expect(l_actual_string).not_to(equal('NULL'));

  end;
  
  procedure test_equal_diff_cursors is
    l_actual   SYS_REFCURSOR;
    l_expected SYS_REFCURSOR;
    l_result   integer;
  begin

    open l_actual for select level lvl from dual connect by level <4;
    open l_expected for select level lvl from dual connect by level <3;
    ut.expect(l_actual).to_equal(l_expected);
    l_result :=  ut_assert_processor.get_aggregate_asserts_result();
    ut_assert_processor.clear_asserts;
    
    ut.expect(l_result).to_equal(ut_utils.tr_failure);
  end;
  
  procedure test_equal_same_cursors is
    l_actual   SYS_REFCURSOR;
    l_expected SYS_REFCURSOR;
    l_result   integer;
  begin

    open l_actual for select level lvl from dual connect by level <3;
    open l_expected for select level lvl from dual connect by level <3;
    ut.expect(l_actual,'Check equality check on same cursors fails').to_equal(l_expected);
  end;  

  procedure create_department_object_type is
    pragma autonomous_transaction;
  begin
    execute immediate 'create or replace type department$ as object(dept_name varchar2(30))';
    execute immediate 'create or replace type department1$ as object(dept_name varchar2(30))';
  end;

  procedure drop_department_object_type is
    pragma autonomous_transaction;
  begin
    execute immediate 'drop type department$';
    execute immediate 'drop type department1$';
  end;

end test_expectations;
/
