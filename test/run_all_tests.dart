import 'dart:io';

/// Comprehensive test runner for StreetBite app
/// This script runs all test categories and generates reports
void main() async {
  print('🧪 Starting StreetBite Comprehensive Test Suite...\n');

  final testResults = <String, bool>{};
  
  // 1. Unit Tests
  print('📋 Running Unit Tests...');
  testResults['Unit Tests'] = await runTestCategory('test/unit/');
  
  // 2. Widget Tests  
  print('\n🎨 Running Widget Tests...');
  testResults['Widget Tests'] = await runTestCategory('test/widget/');
  
  // 3. Performance Tests
  print('\n⚡ Running Performance Tests...');
  testResults['Performance Tests'] = await runTestCategory('test/performance/');
  
  // 4. Integration Tests (if available)
  print('\n🔗 Running Integration Tests...');
  testResults['Integration Tests'] = await runTestCategory('test/integration/');
  
  // Generate Summary Report
  print('\n' + '='*60);
  print('📊 TEST EXECUTION SUMMARY');
  print('='*60);
  
  int passed = 0;
  int total = testResults.length;
  
  testResults.forEach((category, success) {
    final status = success ? '✅ PASSED' : '❌ FAILED';
    print('$category: $status');
    if (success) passed++;
  });
  
  print('\nOverall Result: $passed/$total test categories passed');
  
  if (passed == total) {
    print('🎉 All test categories completed successfully!');
    print('✅ StreetBite app is ready for deployment!');
  } else {
    print('⚠️  Some test categories failed. Please review and fix issues.');
    exit(1);
  }
}

Future<bool> runTestCategory(String testPath) async {
  try {
    final result = await Process.run(
      'flutter',
      ['test', testPath, '--reporter=expanded'],
      runInShell: true,
    );
    
    if (result.exitCode == 0) {
      print('✅ Tests in $testPath completed successfully');
      return true;
    } else {
      print('❌ Tests in $testPath failed');
      print('Error output: ${result.stderr}');
      return false;
    }
  } catch (e) {
    print('❌ Error running tests in $testPath: $e');
    return false;
  }
}