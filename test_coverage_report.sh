#!/bin/bash

# StreetBite Test Coverage Report Generator
# This script runs all tests with coverage and generates detailed reports

echo "🧪 StreetBite Test Coverage Analysis"
echo "=================================="

# Clean previous coverage data
echo "🧹 Cleaning previous coverage data..."
rm -rf coverage/
flutter clean

# Install dependencies
echo "📦 Installing dependencies..."
flutter pub get

# Run tests with coverage
echo "🔍 Running tests with coverage analysis..."
flutter test --coverage

# Check if coverage was generated
if [ ! -d "coverage" ]; then
    echo "❌ Coverage data not generated. Please check test execution."
    exit 1
fi

# Generate HTML coverage report (requires lcov)
if command -v genhtml &> /dev/null; then
    echo "📊 Generating HTML coverage report..."
    genhtml coverage/lcov.info -o coverage/html
    echo "✅ HTML coverage report generated in coverage/html/"
    echo "📖 Open coverage/html/index.html in your browser to view the report"
else
    echo "⚠️  genhtml not found. Install lcov to generate HTML reports:"
    echo "   macOS: brew install lcov"
    echo "   Ubuntu: sudo apt-get install lcov"
fi

# Display coverage summary
echo ""
echo "📈 Coverage Summary:"
echo "==================="

if command -v lcov &> /dev/null; then
    lcov --summary coverage/lcov.info
else
    echo "📄 Raw coverage data available in coverage/lcov.info"
fi

# Test quality metrics
echo ""
echo "🎯 Test Quality Metrics:"
echo "======================="

# Count test files
unit_tests=$(find test/unit -name "*_test.dart" | wc -l)
widget_tests=$(find test/widget -name "*_test.dart" | wc -l)
integration_tests=$(find test/integration -name "*_test.dart" | wc -l)
performance_tests=$(find test/performance -name "*_test.dart" | wc -l)

echo "📋 Unit Tests: $unit_tests files"
echo "🎨 Widget Tests: $widget_tests files"
echo "🔗 Integration Tests: $integration_tests files"
echo "⚡ Performance Tests: $performance_tests files"

total_tests=$((unit_tests + widget_tests + integration_tests + performance_tests))
echo "📊 Total Test Files: $total_tests"

# Source file count for coverage calculation
source_files=$(find lib -name "*.dart" | wc -l)
echo "📁 Source Files: $source_files"

if [ $source_files -gt 0 ]; then
    test_ratio=$((total_tests * 100 / source_files))
    echo "📈 Test-to-Source Ratio: $test_ratio%"
fi

echo ""
echo "✅ Coverage analysis complete!"
echo "🎯 Target: 90%+ unit test coverage, 80%+ widget test coverage"