create or replace package test_expectations is

  --%suite(Expectations)
  --%suitepath(ut_plsql.core)

  --%beforeall
  procedure create_department_object_type;

  --%afterall
  procedure drop_department_object_type;

  --%test
  procedure test_to_equal_diff_types;
  --%test
  procedure test_to_equal_diff_vals;
  --%test
  procedure test_to_equal_act_nulls;
  --%test
  procedure test_to_equal_bothnulls_pf;
  --%test
  procedure test_to_equal_bothnulls_f;
  --%test
  procedure test_to_equal_exp_null;
  --%test
  procedure test_to_equal_correct;
  --%test
  procedure test_to_equal_bothnulls_t;
  --%test
  procedure test_to_equal_bothnulls_tp;
  --%test
  procedure test_to_equal_act_null_amsg;
  --%test
  procedure test_to_equal_act_null_emsg;
  --%test
  procedure test_to_equal_msg;
  
  --%test
  procedure test_to_equal_cursors;
  
  --%test(Test equality check on different cursors)
  procedure test_equal_diff_cursors;
  
  --%test(Test equality check on same cursors)
  procedure test_equal_same_cursors;
  
  --%test
  procedure test_to_be_true;
  
  --%test
  procedure test_to_be_false;
  
  --%test
  procedure test_to_be_null_fails;
  
  --%test
  procedure test_to_be_null_seccess;
  
  --%test
  procedure test_to_be_not_null_success;
  
  --%test
  procedure test_to_be_not_null_fails;
  
  --%test
  procedure test_to_be_like;
  
  --%test
  procedure test_to_match;
  
  --%test  
  procedure test_be_between_diff_val;
  --%test
  procedure test_be_between_act_null;
  --%test
  procedure test_be_between_both_null;
  --%test
  procedure test_be_between_exp_null;
  --%test
  procedure test_be_between_correct;
  --%test
  procedure test_be_between_diff_type;
  --%test
  procedure test_be_between_msg;

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
  
  procedure exec_to_be_like(a_type varchar2, a_actual varchar2, a_pattern varchar2, a_escape_char varchar2, a_result integer) is
    l_statement varchar2(32767);
    l_assert_results ut_assert_results;
    l_result integer;
  begin
    l_assert_results := ut_assert_processor.get_asserts_results;
    l_statement := 'declare
l_actual    '||a_type||' := '||a_actual||';
l_pattern   varchar2(32767) := :pattern;
l_escape_char varchar2(32767) := :escape;
begin ut.expect( l_actual ).to_( be_like(l_pattern, l_escape_char) ); end;';
    execute immediate l_statement using a_pattern, a_escape_char;
    l_result := ut_assert_processor.get_aggregate_asserts_result;
    restore_asserts(l_assert_results);
      
    ut.expect(l_result,'exec_to_be_like'||chr(10)||l_statement).to_equal(a_result);
  end;
  
  procedure exec_to_match(a_type varchar2, a_value varchar2, a_pattern varchar2, a_modifiers varchar2, a_result integer) is
    l_statement varchar2(32767);
    l_assert_results ut_assert_results;
    l_result integer;
  begin
    l_assert_results := ut_assert_processor.get_asserts_results;
    
    l_statement := 'declare
l_actual    '||a_type||' := '||a_value||';
l_pattern   varchar2(32767) := :pattern;
l_modifiers varchar2(32767) := :mod;
begin ut.expect( l_actual ).to_match(l_pattern, l_modifiers); end;';
    execute immediate l_statement using a_pattern, a_modifiers;
    l_result := ut_assert_processor.get_aggregate_asserts_result;
    restore_asserts(l_assert_results);
      
    ut.expect(l_result,'exec_to_match'||chr(10)||l_statement).to_equal(a_result);
  end exec_to_match;  
  
  procedure exec_be_between(a_type varchar2, a_actual varchar2, a_expected1 varchar2, a_expected2 varchar2, a_result integer) is
    l_statement varchar2(32767);
    l_assert_results ut_assert_results;
    l_result integer;
  begin
    l_assert_results := ut_assert_processor.get_asserts_results;
      
    l_statement := 'declare
l_actual   '||a_type||' := '||a_actual||';
l_expected_1 '||a_type||' := '||a_expected1||';
l_expected_2 '||a_type||' := '||a_expected2||';
begin ut.expect(l_actual).to_be_between(l_expected_1,l_expected_2); end;';
    execute immediate l_statement;
    l_result := ut_assert_processor.get_aggregate_asserts_result;
    restore_asserts(l_assert_results);

    ut.expect(l_result,'exec_be_between'||chr(10)||l_statement).to_equal(a_result);
  end;  
    
  procedure exec_be_between_diff_types(a_type varchar2, a_type2 varchar2, a_actual varchar2, a_expected1 varchar2, a_expected2 varchar2, a_result integer) is
    l_statement varchar2(32767);
    l_assert_results ut_assert_results;
    l_result integer;
  begin
    l_assert_results := ut_assert_processor.get_asserts_results;
      
    l_statement := 'declare
l_actual   '||a_type||' := '||a_actual||';
l_expected_1 '||a_type2||' := '||a_expected1||';
l_expected_2 '||a_type2||' := '||a_expected2||';
begin ut.expect(l_actual).to_be_between(l_expected_1,l_expected_2); end;';
    execute immediate l_statement;
    l_result := ut_assert_processor.get_aggregate_asserts_result;
    restore_asserts(l_assert_results);

    ut.expect(l_result,'exec_be_between_diff_types'||chr(10)||l_statement).to_equal(a_result);
  end;  
    
  procedure exec_be_between_with_msg(a_type varchar2, a_actual varchar2, a_expected1 varchar2, a_expected2 varchar2) is
    l_statement varchar2(32767);
    l_assert_results ut_assert_results;
    l_result ut_assert_result;
    l_test_message varchar2(30) := 'A test message';
  begin
    l_assert_results := ut_assert_processor.get_asserts_results;
      
    l_statement := 'declare
l_actual   '||a_type||' := '||a_actual||';
l_expected_1 '||a_type||' := '||a_expected1||';
l_expected_2 '||a_type||' := '||a_expected2||';
l_test_message varchar2(30) := :p1;
begin ut.expect(l_actual, l_test_message).to_be_between(l_expected_1,l_expected_2); end;';
    execute immediate l_statement using l_test_message;
    l_result := ut_assert_processor.get_asserts_results()(1);
    restore_asserts(l_assert_results);

    ut.expect(l_result.message,'exec_be_between_with_msg'||chr(10)||l_statement).to_equal(l_test_message);
  end;  

  procedure test_to_equal_diff_types is  
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
  end;
  procedure test_to_equal_diff_vals is  
  begin
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
  end;
  procedure test_to_equal_act_nulls is  
  begin
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
  end;
  procedure test_to_equal_bothnulls_pf is  
  begin
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
  end;
  procedure test_to_equal_bothnulls_f is  
  begin
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
  end;
  procedure test_to_equal_exp_null is  
  begin
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
  end;
  procedure test_to_equal_correct is  
  begin
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
  end;
  procedure test_to_equal_bothnulls_t is  
  begin
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
  end;
  procedure test_to_equal_bothnulls_tp is  
  begin
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
  end;    
  procedure test_to_equal_act_null_amsg is  
  begin
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
  end;    
  procedure test_to_equal_act_null_emsg is  
  begin
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
  end;
  procedure test_to_equal_msg is  
  begin
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
  end test_to_equal_msg;
  
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
  begin

    open l_actual for select level lvl from dual connect by level <3;
    open l_expected for select level lvl from dual connect by level <3;
    ut.expect(l_actual,'Check equality check on same cursors fails').to_equal(l_expected);
  end;  
  
  procedure test_to_be_true is
    l_results ut_assert_results;
    l_result integer;
  begin
    -- check false
    l_results := ut_assert_processor.get_asserts_results;
    ut.expect( 1 = 0 ).to_be_true();
    l_result := ut_assert_processor.get_aggregate_asserts_result();
    restore_asserts(l_results);
    
    ut.expect(l_result,'Validate 1=0 expectation fails').to_equal(ut_utils.tr_failure);
    
    --check null
    l_results := ut_assert_processor.get_asserts_results;
    ut.expect( 1 = null ).to_be_true();
    l_result := ut_assert_processor.get_aggregate_asserts_result();
    restore_asserts(l_results);
    
    ut.expect(l_result,'Validate 1=null expectation fails').to_equal(ut_utils.tr_failure);
    
    --check true
    ut.expect( 1 = 1,'Validate 1=1 expectation succeeds').to_be_true();
  end test_to_be_true;
  
  procedure test_to_be_false is
    l_results ut_assert_results;
    l_result integer;
  begin
    -- check false
    l_results := ut_assert_processor.get_asserts_results;
    ut.expect( 1 = 1 ).to_be_false();
    l_result := ut_assert_processor.get_aggregate_asserts_result();
    restore_asserts(l_results);
    
    ut.expect(l_result,'Validate 1=1 expectation fails').to_equal(ut_utils.tr_failure);
    
    --check null
    l_results := ut_assert_processor.get_asserts_results;
    ut.expect( 1 = null ).to_be_false();
    l_result := ut_assert_processor.get_aggregate_asserts_result();
    restore_asserts(l_results);
    
    ut.expect(l_result,'Validate 1=null expectation fails').to_equal(ut_utils.tr_failure);
    
    --check true
    ut.expect( 1 = 0,'Validate 1=0 expectation succeeds').to_be_false();
  end;  
  
  procedure exec_unuary_comparator(a_type varchar2, a_actual_value varchar2, a_method varchar2, a_result integer) is
    l_statement varchar2(32767);
    l_assert_results ut_assert_results;
    l_result integer;
  begin
    l_assert_results := ut_assert_processor.get_asserts_results;
    
    l_statement := 'declare
    l_actual   '||a_type||' := '||a_actual_value||';
  begin ut.expect(l_actual).'||a_method||'(); end;';
    execute immediate l_statement;
    l_result :=  ut_assert_processor.get_aggregate_asserts_result();
    restore_asserts(l_assert_results);
    
    ut.expect(l_result, 'exec_unuary_comparator'||chr(10)||l_statement).to_equal(a_result);
  end exec_unuary_comparator;
  
  procedure test_to_be_null_fails is
    l_cursor sys_refcursor;
  begin
    ut.expect( l_cursor,'Gives a success when the Cursor is null').to_be_null();
    
    exec_unuary_comparator('blob', 'to_blob(''abc'')', 'to_be_null', ut_utils.tr_failure);
    exec_unuary_comparator('boolean', 'true', 'to_be_null', ut_utils.tr_failure);
    exec_unuary_comparator('clob', '''abc''', 'to_be_null', ut_utils.tr_failure);
    exec_unuary_comparator('date', 'sysdate', 'to_be_null', ut_utils.tr_failure);
    exec_unuary_comparator('number', '1234', 'to_be_null', ut_utils.tr_failure);
    exec_unuary_comparator('timestamp', 'systimestamp', 'to_be_null', ut_utils.tr_failure);
    exec_unuary_comparator('timestamp with local time zone', 'systimestamp', 'to_be_null', ut_utils.tr_failure);
    exec_unuary_comparator('timestamp with time zone', 'systimestamp', 'to_be_null', ut_utils.tr_failure);
    exec_unuary_comparator('varchar2(4000)', '''abc''', 'to_be_null', ut_utils.tr_failure);
    exec_unuary_comparator('anydata', 'anydata.convertObject(department$(''hr''))', 'to_be_null', ut_utils.tr_failure);
  end;
  
  procedure test_to_be_null_seccess is
  begin   
    exec_unuary_comparator('blob', 'NULL', 'to_be_null', ut_utils.tr_success);
    exec_unuary_comparator('boolean', 'NULL', 'to_be_null', ut_utils.tr_success);
    exec_unuary_comparator('clob', 'NULL', 'to_be_null', ut_utils.tr_success);
    exec_unuary_comparator('date', 'NULL', 'to_be_null', ut_utils.tr_success);
    exec_unuary_comparator('number', 'NULL', 'to_be_null', ut_utils.tr_success);
    exec_unuary_comparator('timestamp', 'NULL', 'to_be_null', ut_utils.tr_success);
    exec_unuary_comparator('timestamp with local time zone', 'NULL', 'to_be_null', ut_utils.tr_success);
    exec_unuary_comparator('timestamp with time zone', 'NULL', 'to_be_null', ut_utils.tr_success);
    exec_unuary_comparator('varchar2(4000)', 'NULL', 'to_be_null', ut_utils.tr_success);
    exec_unuary_comparator('anydata', 'NULL', 'to_be_null', ut_utils.tr_success);
    exec_unuary_comparator('anydata', 'anydata.convertObject(cast(null as department$))', 'to_be_null', ut_utils.tr_success);
    
  end test_to_be_null_seccess;
  
  procedure test_to_be_not_null_success is
    l_cursor sys_refcursor;
  begin
    open l_cursor for select * from dual;
    ut.expect( l_cursor,'Gives a success when the Cursor is not null').to_be_not_null();
    
    exec_unuary_comparator('blob', 'to_blob(''abc'')', 'to_be_not_null', ut_utils.tr_success);
    exec_unuary_comparator('boolean', 'true', 'to_be_not_null', ut_utils.tr_success);
    exec_unuary_comparator('clob', '''abc''', 'to_be_not_null', ut_utils.tr_success);
    exec_unuary_comparator('date', 'sysdate', 'to_be_not_null', ut_utils.tr_success);
    exec_unuary_comparator('number', '1234', 'to_be_not_null', ut_utils.tr_success);
    exec_unuary_comparator('timestamp', 'systimestamp', 'to_be_not_null', ut_utils.tr_success);
    exec_unuary_comparator('timestamp with local time zone', 'systimestamp', 'to_be_not_null', ut_utils.tr_success);
    exec_unuary_comparator('timestamp with time zone', 'systimestamp', 'to_be_not_null', ut_utils.tr_success);
    exec_unuary_comparator('varchar2(4000)', '''abc''', 'to_be_not_null', ut_utils.tr_success);
    exec_unuary_comparator('anydata', 'anydata.convertObject(department$(''hr''))', 'to_be_not_null', ut_utils.tr_success);    
  end test_to_be_not_null_success;
  
  procedure test_to_be_not_null_fails is
  begin
    exec_unuary_comparator('blob', 'NULL', 'to_be_not_null', ut_utils.tr_failure);
    exec_unuary_comparator('boolean', 'NULL', 'to_be_not_null', ut_utils.tr_failure);
    exec_unuary_comparator('clob', 'NULL', 'to_be_not_null', ut_utils.tr_failure);
    exec_unuary_comparator('date', 'NULL', 'to_be_not_null', ut_utils.tr_failure);
    exec_unuary_comparator('number', 'NULL', 'to_be_not_null', ut_utils.tr_failure);
    exec_unuary_comparator('timestamp', 'NULL', 'to_be_not_null', ut_utils.tr_failure);
    exec_unuary_comparator('timestamp with local time zone', 'NULL', 'to_be_not_null', ut_utils.tr_failure);
    exec_unuary_comparator('timestamp with time zone', 'NULL', 'to_be_not_null', ut_utils.tr_failure);
    exec_unuary_comparator('varchar2(4000)', 'NULL', 'to_be_not_null', ut_utils.tr_failure);
    exec_unuary_comparator('anydata', 'NULL', 'to_be_not_null', ut_utils.tr_failure);
    exec_unuary_comparator('anydata', 'anydata.convertObject(cast(null as department$))', 'to_be_not_null', ut_utils.tr_failure);
  end test_to_be_not_null_fails;
  
  procedure test_to_be_like is

  begin
    exec_to_be_like('varchar2(100)', '''Stephen_King''', 'Ste__en%', '', ut_utils.tr_success);
    exec_to_be_like('varchar2(100)', '''Stephen_King''', 'Ste__en\_K%', '\', ut_utils.tr_success);
    exec_to_be_like('clob', 'rpad(''a'',32767,''a'')||''Stephen_King''', 'a%Ste__en%', '', ut_utils.tr_success);
    exec_to_be_like('clob', 'rpad(''a'',32767,''a'')||''Stephen_King''', 'a%Ste__en\_K%', '\', ut_utils.tr_success);
    exec_to_be_like('varchar2(100)', '''Stephen_King''', 'Ste_en%', '', ut_utils.tr_failure);
    exec_to_be_like('varchar2(100)', '''Stephen_King''', 'Stephe\__%', '\', ut_utils.tr_failure);
    exec_to_be_like('clob', 'rpad(''a'',32767,''a'')||''Stephen_King''', 'a%Ste_en%', '', ut_utils.tr_failure);
    exec_to_be_like('clob', 'rpad(''a'',32767,''a'')||''Stephen_King''', 'a%Stephe\__%', '\', ut_utils.tr_failure);
    exec_to_be_like('number', '12345', 'a%Stephe\__%', '\', ut_utils.tr_failure);
  end;
  
  procedure test_to_match is
  begin
    exec_to_match('varchar2(100)', '''Stephen''', '^Ste(v|ph)en$', '', ut_utils.tr_success);
    exec_to_match('varchar2(100)', '''sTEPHEN''', '^Ste(v|ph)en$', 'i', ut_utils.tr_success);
    exec_to_match('clob', 'rpad('', '',32767)||''Stephen''', 'Ste(v|ph)en$', '', ut_utils.tr_success);
    exec_to_match('clob', 'rpad('', '',32767)||''sTEPHEN''', 'Ste(v|ph)en$', 'i', ut_utils.tr_success);
    exec_to_match('varchar2(100)', '''Stephen''', '^Steven$', '', ut_utils.tr_failure);
    exec_to_match('varchar2(100)', '''sTEPHEN''', '^Steven$', 'i', ut_utils.tr_failure);
    exec_to_match('clob', 'rpad('', '',32767)||''Stephen''', '^Stephen', '', ut_utils.tr_failure);
    exec_to_match('clob', 'rpad('', '',32767)||''sTEPHEN''', '^Stephen', 'i', ut_utils.tr_failure);
  end;
  
  procedure test_be_between_diff_val is    
  begin
    --GivesFailureForDifferentValues
    exec_be_between('date', 'sysdate+2', 'sysdate-1', 'sysdate', ut_utils.tr_failure);
    exec_be_between('number', '0.1', '0.3', '0.5', ut_utils.tr_failure);
    exec_be_between('timestamp', 'systimestamp', 'systimestamp', 'systimestamp', ut_utils.tr_failure);
    exec_be_between('timestamp with local time zone', 'systimestamp', 'systimestamp', 'systimestamp', ut_utils.tr_failure);
    exec_be_between('timestamp with time zone', 'systimestamp', 'systimestamp', 'systimestamp', ut_utils.tr_failure);
  end;
  
  procedure test_be_between_act_null is
  begin
    --GivesFailureWhenActualIsNull
    exec_be_between('date', 'NULL', 'sysdate-1', 'sysdate', ut_utils.tr_failure);
    exec_be_between('number', 'NULL', '0', '1', ut_utils.tr_failure);
    exec_be_between('timestamp', 'NULL', 'systimestamp-1', 'systimestamp', ut_utils.tr_failure);
    exec_be_between('timestamp with local time zone', 'NULL', 'systimestamp-1', 'systimestamp', ut_utils.tr_failure);
    exec_be_between('timestamp with time zone', 'NULL', 'systimestamp-1', 'systimestamp', ut_utils.tr_failure);
  end;
  
  procedure test_be_between_both_null is
  begin
    --GivesFailureWhenBothActualAndExpectedRangeIsNull
    exec_be_between('date', 'NULL', 'NULL', 'NULL', ut_utils.tr_failure);
    exec_be_between('number', 'NULL', 'NULL', 'NULL', ut_utils.tr_failure);
    exec_be_between('timestamp', 'NULL', 'NULL', 'NULL', ut_utils.tr_failure);
    exec_be_between('timestamp with local time zone', 'NULL', 'NULL', 'NULL', ut_utils.tr_failure);
    exec_be_between('timestamp with time zone', 'NULL', 'NULL', 'NULL', ut_utils.tr_failure);
  end;

  procedure test_be_between_exp_null is
  begin
    --GivesFailureWhenExpectedRangeIsNull
    exec_be_between('date', 'sysdate', 'NULL', 'sysdate', ut_utils.tr_failure);
    exec_be_between('number', '1234', 'NULL', '1234', ut_utils.tr_failure);
    exec_be_between('timestamp', 'systimestamp', 'NULL', 'systimestamp', ut_utils.tr_failure);
    exec_be_between('timestamp with local time zone', 'systimestamp', 'NULL', 'systimestamp', ut_utils.tr_failure);
    exec_be_between('timestamp with time zone', 'systimestamp', 'NULL', 'systimestamp', ut_utils.tr_failure);

    exec_be_between('date', 'sysdate', 'sysdate', 'NULL', ut_utils.tr_failure);
    exec_be_between('number', '1234', '1234', 'NULL', ut_utils.tr_failure);
    exec_be_between('timestamp', 'systimestamp', 'systimestamp', 'NULL', ut_utils.tr_failure);
    exec_be_between('timestamp with local time zone', 'systimestamp', 'systimestamp', 'NULL', ut_utils.tr_failure);
    exec_be_between('timestamp with time zone', 'systimestamp', 'systimestamp', 'NULL', ut_utils.tr_failure);

    exec_be_between('date', 'sysdate', 'NULL', 'NULL', ut_utils.tr_failure);
    exec_be_between('number', '1234', 'NULL', 'NULL', ut_utils.tr_failure);
    exec_be_between('timestamp', 'systimestamp', 'NULL', 'NULL', ut_utils.tr_failure);
    exec_be_between('timestamp with local time zone', 'systimestamp', 'NULL', 'NULL', ut_utils.tr_failure);
    exec_be_between('timestamp with time zone', 'systimestamp', 'NULL', 'NULL', ut_utils.tr_failure);
  end;
  
  procedure test_be_between_correct is
  begin
    --GivesTrueForCorrectValues
    exec_be_between('date', 'sysdate', 'sysdate-1', 'sysdate+1', ut_utils.tr_success);
    exec_be_between('number', '0.4', '0.3', '0.5', ut_utils.tr_success);
    exec_be_between('varchar2(50)', '''b''', '''a''', '''c''', ut_utils.tr_success);
    exec_be_between('timestamp', 'systimestamp', 'systimestamp-1', 'systimestamp', ut_utils.tr_success);
    exec_be_between('timestamp with local time zone', 'systimestamp', 'systimestamp-1', 'systimestamp', ut_utils.tr_success);
    exec_be_between('timestamp with time zone', 'systimestamp', 'systimestamp-1', 'systimestamp', ut_utils.tr_success);
  end;
 
  procedure test_be_between_diff_type is
  begin
    --GivesSuccessWhenDifferentTypes
    exec_be_between_diff_types('varchar2(4000)', 'number', '''1''', '0', '2', ut_utils.tr_success);
    exec_be_between_diff_types('number', 'varchar2(4000)', '1', '''0''', '''2''', ut_utils.tr_success);
  end;
  
  procedure test_be_between_msg is
  begin
    --GivesTheProvidedTextAsMessage
    exec_be_between_with_msg('date', 'sysdate', 'sysdate-1', 'sysdate+1');
    exec_be_between_with_msg('number', '0.4', '0.3', '0.5');
    exec_be_between_with_msg('timestamp', 'systimestamp', 'systimestamp-1', 'systimestamp');
    exec_be_between_with_msg('timestamp with local time zone', 'systimestamp', 'systimestamp-1', 'systimestamp');
    exec_be_between_with_msg('timestamp with time zone', 'systimestamp', 'systimestamp-1', 'systimestamp');
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
