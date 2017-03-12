create or replace package test_annotations is

  --%suite(annotations)
  --%suitepath(ut_plsql.core)
  
  --%test
  procedure test1;
  --%test
  procedure test2;
  --%test
  procedure test3;
  --%test
  procedure test4;
  --%test
  procedure test5;
  --%test
  procedure test6;
  --%test
  procedure test7;
  --%test
  procedure test8;
  --%test
  procedure test9;

end test_annotations;
/
create or replace package body test_annotations is

  procedure check_annotation_parsing(a_expected ut_annotations.typ_annotated_package, a_parsing_result ut_annotations.typ_annotated_package) is
    procedure check_annotation_params(a_msg varchar2, a_expected ut_annotations.tt_annotation_params, a_actual ut_annotations.tt_annotation_params) is
    begin
      ut.expect(a_actual.count,'['||a_msg||']Check number of annotation params').to_equal(a_expected.count);

      if a_expected.count = a_actual.count and a_expected.count > 0 then
        for i in 1..a_expected.count loop
          if a_expected(i).key is not null then
            ut.expect(a_actual(i).key,'['||a_msg||'('||i||')]Check annotation param key').to_equal(a_expected(i).key);
          else
            ut.expect(a_actual(i).key,'['||a_msg||'('||i||')]Check annotation param key').to_be_null;
          end if;

          if a_expected(i).val is not null then
            ut.expect(a_actual(i).val,'['||a_msg||'('||i||')]Check annotation param value').to_equal(a_expected(i).val);
          else
            ut.expect(a_actual(i).val,'['||a_msg||'('||i||')]Check annotation param value').to_be_null;
          end if;
        end loop;
      end if;
    end;

    procedure check_annotations(a_msg varchar2, a_expected ut_annotations.tt_annotations, a_actual ut_annotations.tt_annotations) is
      l_ind varchar2(500);
    begin
      ut.expect(a_actual.count,'['||a_msg||']Check number of annotations parsed').to_equal(a_expected.count);

      if a_expected.count = a_actual.count and a_expected.count > 0 then
        l_ind := a_expected.first;
        while l_ind is not null loop

          ut.expect(a_actual.exists(l_ind),('['||a_msg||']Check annotation exists')).to_be_true;
          if a_actual.exists(l_ind) then
            check_annotation_params(a_msg||'.'||l_ind,a_expected(l_ind),a_actual(l_ind));
          end if;
          l_ind := a_expected.next(l_ind);
        end loop;
      end if;
    end;

    procedure check_procedures(a_msg varchar2,  a_expected ut_annotations.tt_procedure_list, a_actual ut_annotations.tt_procedure_list) is
      l_found boolean := false;
      l_index pls_integer;
    begin
      ut.expect(a_actual.count,'['||a_msg||']Check number of procedures parsed').to_equal(a_expected.count);

      if a_expected.count = a_actual.count and a_expected.count > 0 then
        for i in 1..a_expected.count loop
          l_found := false;
          l_index := null;
          for j in 1..a_actual.count loop
            if a_expected(i).name = a_actual(j).name then
              l_found:=true;
              l_index := j;
              exit;
            end if;
          end loop;

          ut.expect(l_found,'['||a_msg||']Check procedure exists').to_be_true;
          if l_found then
            check_annotations(a_msg||'.'||a_expected(i).name,a_expected(i).annotations,a_actual(l_index).annotations);
          end if;
        end loop;
      end if;
    end;
  begin
    check_annotations('PACKAGE',a_expected.package_annotations,a_parsing_result.package_annotations);
    check_procedures('PROCEDURES',a_expected.procedure_annotations,a_parsing_result.procedure_annotations);
  end check_annotation_parsing;

  procedure test1 is
    l_source clob;
    l_parsing_result ut_annotations.typ_annotated_package;
    l_expected ut_annotations.typ_annotated_package;
    l_ann_param ut_annotations.typ_annotation_param;

  begin
    l_source := 'PACKAGE test_tt AS
    -- %suite
    -- %displayname(Name of suite)
    -- %suitepath(all.globaltests)
    
    -- %ann1(Name of suite)
    -- wrong line
    -- %ann2(some_value)  
    procedure foo;
  END;';

  --Act
    l_parsing_result := ut_annotations.parse_package_annotations(l_source);
    
  --Assert
    l_ann_param := null;
    l_ann_param.val := 'Name of suite'; 
    l_expected.package_annotations('suite') := cast( null as ut_annotations.tt_annotation_params);
    l_expected.package_annotations('displayname')(1) := l_ann_param;
    
    l_ann_param := null;
    l_ann_param.val := 'all.globaltests';  
    l_expected.package_annotations('suitepath')(1) := l_ann_param;
    
    l_ann_param := null;
    l_ann_param.val := 'some_value';  
    l_expected.procedure_annotations(1).name :='foo';
    l_expected.procedure_annotations(1).annotations('ann2')(1) := l_ann_param;
    
    check_annotation_parsing(l_expected, l_parsing_result);

  end;
  
  procedure test2 is
    l_source clob;
    l_parsing_result ut_annotations.typ_annotated_package;
    l_expected ut_annotations.typ_annotated_package;
    l_ann_param ut_annotations.typ_annotation_param;

  begin
    l_source := 'PACKAGE test_tt AS
    -- %suite
    -- %displayname(Name of suite)
    -- %suitepath(all.globaltests)
    
    -- %ann1(Name of suite)
    -- %ann2(all.globaltests)  
    
    procedure foo;
  END;';

  --Act
    l_parsing_result := ut_annotations.parse_package_annotations(l_source);
    
  --Assert
    l_ann_param := null;
    l_ann_param.val := 'Name of suite'; 
    l_expected.package_annotations('suite') := cast( null as ut_annotations.tt_annotation_params);
    l_expected.package_annotations('displayname')(1) := l_ann_param;
    
    l_ann_param := null;
    l_ann_param.val := 'all.globaltests';  
    l_expected.package_annotations('suitepath')(1) := l_ann_param;
    
    check_annotation_parsing(l_expected, l_parsing_result);

  end;
  
  procedure test3 is
    l_source clob;
    l_parsing_result ut_annotations.typ_annotated_package;
    l_expected ut_annotations.typ_annotated_package;
    l_ann_param ut_annotations.typ_annotation_param;

  begin
    l_source := 'PACKAGE test_tt AS
    -- %suite
    -- %displayname(Name of suite)
    -- %suitepath(all.globaltests)
    
    --%test
    procedure foo;
    
    
    --%beforeeach
    procedure foo2;
    
    --test comment
    -- wrong comment
    
    
    /*
    describtion of the procedure
    */
    --%beforeeach(key=testval)
    PROCEDURE foo3(a_value number default null);
    
    function foo4(a_val number default null
      , a_par varchar2 default := ''asdf'');
  END;';

  --Act
    l_parsing_result := ut_annotations.parse_package_annotations(l_source);
    
  --Assert
    l_ann_param := null;
    l_ann_param.val := 'Name of suite'; 
    l_expected.package_annotations('suite') := cast( null as ut_annotations.tt_annotation_params);
    l_expected.package_annotations('displayname')(1) := l_ann_param;
    
    l_ann_param := null;
    l_ann_param.val := 'all.globaltests';  
    l_expected.package_annotations('suitepath')(1) := l_ann_param;
    
    l_expected.procedure_annotations(1).name := 'foo';
    l_expected.procedure_annotations(1).annotations('test') := cast( null as ut_annotations.tt_annotation_params);
    
    l_expected.procedure_annotations(2).name := 'foo2';
    l_expected.procedure_annotations(2).annotations('beforeeach') := cast( null as ut_annotations.tt_annotation_params);
    
    l_ann_param := null;
    l_ann_param.key := 'key'; 
    l_ann_param.val := 'testval';
    
    l_expected.procedure_annotations(3).name := 'foo3';
    l_expected.procedure_annotations(3).annotations('beforeeach')(1) := l_ann_param;
    
    check_annotation_parsing(l_expected, l_parsing_result);

  end;
  
  procedure test4 is 
    l_source clob;
    l_parsing_result ut_annotations.typ_annotated_package;
    l_expected ut_annotations.typ_annotated_package;
    l_ann_param ut_annotations.typ_annotation_param;

  begin
    l_source := 'PACKAGE test_tt AS
    -- %suite
    -- %displayname(Name of suite)
    -- %suitepath(all.globaltests)
    
    --%test
    procedure foo;
  END;';

  --Act
    l_parsing_result := ut_annotations.parse_package_annotations(l_source);
    
  --Assert
    l_ann_param := null;
    l_ann_param.val := 'Name of suite'; 
    l_expected.package_annotations('suite') := cast( null as ut_annotations.tt_annotation_params);
    l_expected.package_annotations('displayname')(1) := l_ann_param;
    
    l_ann_param := null;
    l_ann_param.val := 'all.globaltests';  
    l_expected.package_annotations('suitepath')(1) := l_ann_param;
    
    l_expected.procedure_annotations(1).name := 'foo';
    l_expected.procedure_annotations(1).annotations('test') := cast( null as ut_annotations.tt_annotation_params);
    
    check_annotation_parsing(l_expected, l_parsing_result);

  end;

  procedure test5 is
    l_source clob;
    l_parsing_result ut_annotations.typ_annotated_package;
    l_expected ut_annotations.typ_annotated_package;
    l_ann_param ut_annotations.typ_annotation_param;

  begin
    l_source := 'PACKAGE test_tt AS
    -- %suite
    -- %displayname(Name of suite)
    -- %suitepath(all.globaltests)
    
    procedure foo;
  END;';

  --Act
    l_parsing_result := ut_annotations.parse_package_annotations(l_source);
    
  --Assert
    l_ann_param := null;
    l_ann_param.val := 'Name of suite'; 
    l_expected.package_annotations('suite') := cast( null as ut_annotations.tt_annotation_params);
    l_expected.package_annotations('displayname')(1) := l_ann_param;
    
    l_ann_param := null;
    l_ann_param.val := 'all.globaltests';  
    l_expected.package_annotations('suitepath')(1) := l_ann_param;
    
    check_annotation_parsing(l_expected, l_parsing_result);

  end;

  procedure test6 is
    l_source clob;
    l_parsing_result ut_annotations.typ_annotated_package;
    l_expected ut_annotations.typ_annotated_package;
    l_ann_param ut_annotations.typ_annotation_param;

  begin
    l_source := 'PACKAGE test_tt accessible by (foo) AS
    -- %suite
    -- %displayname(Name of suite)
    -- %suitepath(all.globaltests)
    
    procedure foo;
  END;';

  --Act
    l_parsing_result := ut_annotations.parse_package_annotations(l_source);
    
  --Assert
    l_ann_param := null;
    l_ann_param.val := 'Name of suite'; 
    l_expected.package_annotations('suite') := cast( null as ut_annotations.tt_annotation_params);
    l_expected.package_annotations('displayname')(1) := l_ann_param;
    
    l_ann_param := null;
    l_ann_param.val := 'all.globaltests';  
    l_expected.package_annotations('suitepath')(1) := l_ann_param;
    
    check_annotation_parsing(l_expected, l_parsing_result);

  end;

  procedure test7 is
    l_source clob;
    l_parsing_result ut_annotations.typ_annotated_package;
    l_expected ut_annotations.typ_annotated_package;
    l_ann_param ut_annotations.typ_annotation_param;

  begin
    l_source := 'PACKAGE test_tt 
    ACCESSIBLE BY (calling_proc)
    authid current_user 
    AS
    -- %suite
    -- %displayname(Name of suite)
    -- %suitepath(all.globaltests)
    
    procedure foo;
  END;';

  --Act
    l_parsing_result := ut_annotations.parse_package_annotations(l_source);
    
  --Assert
    l_ann_param := null;
    l_ann_param.val := 'Name of suite'; 
    l_expected.package_annotations('suite') := cast( null as ut_annotations.tt_annotation_params);
    l_expected.package_annotations('displayname')(1) := l_ann_param;
    
    l_ann_param := null;
    l_ann_param.val := 'all.globaltests';  
    l_expected.package_annotations('suitepath')(1) := l_ann_param;
    
    check_annotation_parsing(l_expected, l_parsing_result);

  end;

  procedure test8 is
    l_source clob;
    l_parsing_result ut_annotations.typ_annotated_package;
    l_expected ut_annotations.typ_annotated_package;
    l_ann_param ut_annotations.typ_annotation_param;

  begin
    l_source := 'PACKAGE test_tt AS
    -- %suite
    --%displayname(name = Name of suite)
    -- %suitepath(key=all.globaltests,key2=foo)
    
    procedure foo;
  END;';

  --Act
    l_parsing_result := ut_annotations.parse_package_annotations(l_source);
    
  --Assert
    l_ann_param := null;
    l_ann_param.key := 'name'; 
    l_ann_param.val := 'Name of suite'; 
    l_expected.package_annotations('suite') := cast( null as ut_annotations.tt_annotation_params);
    l_expected.package_annotations('displayname')(1) := l_ann_param;
    
    l_ann_param := null;
    l_ann_param.key := 'key'; 
    l_ann_param.val := 'all.globaltests';  
    l_expected.package_annotations('suitepath')(1) := l_ann_param;
    
    l_ann_param := null;
    l_ann_param.key := 'key2'; 
    l_ann_param.val := 'foo';  
    l_expected.package_annotations('suitepath')(2) := l_ann_param;
    
    check_annotation_parsing(l_expected, l_parsing_result);

  end;

  procedure test9 is
    l_source clob;
    l_parsing_result ut_annotations.typ_annotated_package;
    l_expected ut_annotations.typ_annotated_package;
    l_ann_param ut_annotations.typ_annotation_param;

  begin
    l_source := 'PACKAGE test_tt AS
    /*
    Some comment
    -- inlined
    */
    -- %suite
    --%displayname(Name of suite)
    -- %suitepath(all.globaltests)
    
    procedure foo;
  END;';

  --Act
    l_parsing_result := ut_annotations.parse_package_annotations(l_source);
    
  --Assert
    l_ann_param := null;
    l_ann_param.val := 'Name of suite'; 
    l_expected.package_annotations('suite') := cast( null as ut_annotations.tt_annotation_params);
    l_expected.package_annotations('displayname')(1) := l_ann_param;
    
    l_ann_param := null;
    l_ann_param.val := 'all.globaltests';  
    l_expected.package_annotations('suitepath')(1) := l_ann_param;
    
    check_annotation_parsing(l_expected, l_parsing_result);

  end;

end test_annotations;
/
