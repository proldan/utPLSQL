@@lib/RunTest.sql "ut_expectations/common/ut.expect.not_to_equal.scalar.common.sql 'blob' 'to_blob(''abc'')' 'to_blob(''abd'')' 'ut_utils.tr_success'"
@@lib/RunTest.sql "ut_expectations/common/ut.expect.not_to_equal.scalar.common.sql 'boolean' 'true' 'false' 'ut_utils.tr_success'"
@@lib/RunTest.sql "ut_expectations/common/ut.expect.not_to_equal.scalar.common.sql 'clob' '''Abc''' '''abc''' 'ut_utils.tr_success'"
@@lib/RunTest.sql "ut_expectations/common/ut.expect.not_to_equal.scalar.common.sql 'date' 'sysdate' 'sysdate-1' 'ut_utils.tr_success'"
@@lib/RunTest.sql "ut_expectations/common/ut.expect.not_to_equal.scalar.common.sql 'number' '0.1' '0.3' 'ut_utils.tr_success'"
@@lib/RunTest.sql "ut_expectations/common/ut.expect.not_to_equal.scalar.common.sql 'timestamp' 'systimestamp' 'systimestamp' 'ut_utils.tr_success'"
@@lib/RunTest.sql "ut_expectations/common/ut.expect.not_to_equal.scalar.common.sql 'timestamp with local time zone' 'systimestamp' 'systimestamp' 'ut_utils.tr_success'"
@@lib/RunTest.sql "ut_expectations/common/ut.expect.not_to_equal.scalar.common.sql 'timestamp with time zone' 'systimestamp' 'systimestamp' 'ut_utils.tr_success'"
@@lib/RunTest.sql "ut_expectations/common/ut.expect.not_to_equal.scalar.common.sql 'varchar2(4000)' '''Abc''' '''abc''' 'ut_utils.tr_success'"
@@lib/RunTest.sql "ut_expectations/common/ut.expect.not_to_equal.scalar.common.sql 'interval day to second' '''2 01:00:00''' '''2 01:00:01''' 'ut_utils.tr_success'"
@@lib/RunTest.sql "ut_expectations/common/ut.expect.not_to_equal.scalar.common.sql 'interval year to month' '''1-1''' '''1-2''' 'ut_utils.tr_success'"
